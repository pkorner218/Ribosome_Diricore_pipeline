#!/usr/bin/env python
#

import os
import sys
from itertools import imap, product, groupby, repeat, chain
import cPickle
import gzip
import logging

import h5py
from numpy import zeros

from HTSeq import GenomicArrayOfSets, GenomicArray, GFF_Reader, BAM_Reader, SAM_Reader

sys.path.append(os.path.join(os.path.dirname(__file__), '../lib/'))
from txtools import validate_and_extract_cds
from filelock import FileLock


LOOKATCODONS = [3, 4, 5, 6]
RPF_OVERHANG_SIZE = 18
_BASES = "ACGT"

print("now in extract_subsequences.py") 

log = logging.getLogger(__name__)
log.setLevel(logging.DEBUG)


def read_transcriptdata(gtffn):
    gid_key = lambda f: (f.iv.chrom, f.attr.get("gene_id"))
    tid_key = lambda f: f.attr.get("transcript_id")
    sort_key = lambda f: f.iv.start

    tidtc = dict()
    tid2gid = dict()

    a = GenomicArrayOfSets("auto", stranded=True)

    gtf = GFF_Reader(gtffn)

    for (chrom, gid), ggfiter in groupby(gtf, gid_key):
        for tid, tgfiter in groupby(ggfiter, tid_key):
            fs = sorted(tgfiter, key=sort_key)

            exonfs = filter(lambda f: f.type == "exon", fs)
            cdsfs = filter(lambda f: f.type == "CDS", fs)
            if not any(exonfs) or not any(cdsfs):
                continue

            try:
                tc, (cdsstart, cdsend) = validate_and_extract_cds(fs)
            except ValueError:
                continue

            tidtc[tid] = tc, (cdsstart, cdsend)
            for efs in exonfs:
                a[efs.iv] += tid

            tid2gid[tid] = gid

    return a, tidtc, tid2gid


def count_subsequences(readiter, a, tidtc, tid2gid, framefilter, min_aqual):
    gids = sorted(set(tid2gid.itervalues()))
    gid2idx = {gid: i for (i, gid) in enumerate(gids)}
    codon2idx = {codon: i for (i, codon) in enumerate(("".join(t) for t in product(*repeat(_BASES, 3))))}
    A = zeros((len(gids), len(LOOKATCODONS), len(codon2idx)), dtype=int)

    unmappable_chroms = set()

    for iread, read in enumerate(readiter):
        if (iread % 1000000) == 0 and (iread > 0):
            log.info("%d alignments processed" % iread)

        if read.aQual < min_aqual or read.not_primary_alignment or not read.aligned:
            continue

        if len(read.read.seq) < (LOOKATCODONS[-1] + 1) * 3:
            continue

        if any((co.type in {"D", "I"} for co in read.cigar)):
            continue

        mapivs = map(lambda co: co.ref_iv, filter(lambda co: co.type == "M", read.cigar))
        try:
            tids = reduce(set.intersection, imap(lambda (iv, s): s, chain(*imap(lambda iv: a[iv].steps(), mapivs))))
        except KeyError:
            chroms = set(map(lambda iv: iv.chrom, mapivs))
            assert len(chroms) == 1
            unmappable_chroms.update(chroms)
            continue

        if not any(tids):
            continue

        gids = map(tid2gid.get, tids)

        if len(set(gids)) > 1:
            # ambiguous in geneID
            continue

        offsets = list()
        cdslengths = list()
        for tid in sorted(tids):
            tc, (cdsstart, cdsend) = tidtc[tid]
            if read.iv.strand == "+":
                offset = tc.to_transcript_coordinate(mapivs[0].start) - cdsstart
            else:
                offset = tc.to_transcript_coordinate(mapivs[-1].end - 1) - cdsstart

            offsets.append(offset)
            cdslengths.append(cdsend - cdsstart)

        frames = map(lambda x: x % 3, offsets)
        infputr = map(lambda x: x < -RPF_OVERHANG_SIZE, offsets)
        intputr = map(lambda i: offsets[i] >= (cdslengths[i] - RPF_OVERHANG_SIZE), xrange(len(tids)))

        incds = [not (infputr[i] or intputr[i]) for i in xrange(len(tids))]

        if not any(incds):
            continue

        incdsframes = [frames[i] for i in xrange(len(tids)) if incds[i]]

        if not len(set(incdsframes)) == 1:
            # see e.g.: chr1:1,565,013-1,565,062 (MIB2)
            continue

        frame = incdsframes[0]

        if framefilter is not None and frame != framefilter:
            continue

        codons = [read.read.seq[x:(x + 3)] for x in [x * 3 - frame for x in LOOKATCODONS]]

        igid = gid2idx[gids[0]]
        for i in xrange(len(LOOKATCODONS)):
            try:
                icodon = codon2idx[codons[i]]
            except KeyError:
                assert "N" in codons[i]
                continue

            A[igid, i, icodon] += 1

    log.info("%d alignments processed" % iread)
    log.warning("Skipped chroms: %s" % ", ".join(sorted(unmappable_chroms)))

    return A


def write_counts(outfile, samplename, counts):
    with FileLock(outfile, timeout=100, delay=0.1):
        h5file = h5py.File(outfile)

        chunkdim0 = 80000 / counts.itemsize / counts.shape[1] / counts.shape[2]
        chunkdim0 = min(counts.shape[0], chunkdim0)
        chunks = (chunkdim0, counts.shape[1], counts.shape[2])

        samplename = samplename + ".fastq.gz"

        h5file.create_dataset("/%s" % samplename, data=counts, chunks=chunks, compression=4)

        h5file.close()
        del h5file


def main():
    import argparse
    ap = argparse.ArgumentParser(description="")

    ap.add_argument('-v', '--verbose', action="count", default=0, required=False)
    ap.add_argument('-q', '--quiet', action="store_true", default=False, required=False)

    sp = ap.add_subparsers(dest="subparser")

    # run subparser
    mp = sp.add_parser("run")
    mp.add_argument('--tss-ignore-dist', help="TODO: implement", default=None)
    mp.add_argument('-a', '--min-qual', type=int, default=0)

    ag = mp.add_mutually_exclusive_group()
    ag.add_argument('--pool-three-frames', action="store_true", default=False)
    ag.add_argument('-f', '--frame-filter', type=int, default=0)

    mp.add_argument('-o', '--outfile', metavar="FILE", required=True)

    mp.add_argument(dest="transcriptinfofile", metavar="TXINFOFILE", nargs=1)
    mp.add_argument(dest="infile", metavar="SAMPLENAME,BAMFILE", nargs=1)

    # createindex subparser
    ip = sp.add_parser("createindex")
    ip.add_argument('-o', '--outfile', metavar="FILE", required=True)
    ip.add_argument(dest="gtffile", metavar="FILE", nargs=1)

    args = ap.parse_args()

    lh = logging.StreamHandler()
    lf = logging.Formatter("[%(asctime)s] %(message)s", "%c")
    lh.setFormatter(lf)

    if args.quiet:
        lh.setLevel(logging.ERROR)
    elif args.verbose == 0:
        lh.setLevel(logging.WARNING)
    elif args.verbose == 1:
        lh.setLevel(logging.INFO)
    elif args.verbose > 1:
        lh.setLevel(logging.DEBUG)

    log.addHandler(lh)

    if args.subparser == "createindex":
        if not os.access(os.path.dirname(args.outfile), os.W_OK):
            ap.error("Can't write to directory of outfile")

        a, tidtc, tid2gid = read_transcriptdata(args.gtffile[0])

        fh = gzip.open(args.outfile, 'wb', 4)
        cPickle.dump((a, tidtc, tid2gid), fh)
        fh.close()
    elif args.subparser == "run":
        samplename, infile = args.infile[0].split(",", 1)
        if infile == "-":
            infh = sys.stdin
            readiter = SAM_Reader(infh)
        else:
            # assume BAM file input
            readiter = BAM_Reader(infile)

        min_aqual = args.min_qual
        if min_aqual < 0:
            ap.error("Quality must be >= 0")

        if args.pool_three_frames:
            framefilter = None
        else:
            framefilter = args.frame_filter
            if not 0 <= framefilter < 3:
                ap.error("Invalid frame")

        a, tidtc, tid2gid = cPickle.load(gzip.open(args.transcriptinfofile[0]))
        counts = count_subsequences(readiter, a, tidtc, tid2gid, framefilter, min_aqual)

        write_counts(args.outfile, samplename, counts)

    return


if __name__ == "__main__":
    from signal import signal, SIGPIPE, SIG_DFL
    signal(SIGPIPE, SIG_DFL)

    try:
        main()
    except IOError as e:
        if e.errno != 32:
            raise
    except KeyboardInterrupt as e:
        pass
