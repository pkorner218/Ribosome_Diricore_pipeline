#!/usr/bin/env python
#

"""
"""

import os
import sys
from itertools import imap
import logging
log = logging.getLogger(__name__)
log.setLevel(logging.DEBUG)

import numpy
from numpy import zeros, empty, r_
import h5py
from HTSeq import GenomicArrayOfSets, BAM_Reader, GenomicInterval

sys.path.append(os.path.join(os.path.dirname(__file__), '../lib/'))
from transcriptcoordinates import TranscriptCoordinates


def read_transcripts(h5fn, stranded=True):
    h5file = h5py.File(h5fn, 'r')

    # extract data
    tids = h5file["tid"][:]
    coordlut = h5file["coordlut"][:]
    coordmap = h5file["coordmap"][:]
    strands = h5file["strand"][:]
    chroms = h5file["chrom"][:]

    a = GenomicArrayOfSets("auto", stranded=stranded)
    ts = dict()
    tidlengths = empty(len(tids), dtype="uint32")
    for itid, tid in enumerate(tids):
        nexons, coordmappos = coordlut[itid]
        is_plus = strands[itid]
        strand = "+" if is_plus else "-"
        chrom = str(chroms[itid])

        txcoords = coordmap[coordmappos:(coordmappos + nexons)]

        for start, end in txcoords:
            iv = GenomicInterval(chrom, start, end, strand)
            a[iv] += tid

        tc = TranscriptCoordinates(txcoords, strand)
        ts[tid] = tc
        tidlengths[itid] = tc.length

    tid2idx = {v: i for (i, v) in enumerate(tids)}

    return a, ts, tid2idx, tidlengths


def process_bam(bamfile, a, ts, tid2idx, tidlengths, min_aqual=0):
    tidarraypos = tidlengths.cumsum()
    totallength = tidarraypos[-1]
    # make tidarraypos "left-based"
    tidarraypos = r_[[0], tidarraypos[:-1]]

    lastseq = None  # use sequence as caching key
    last_counts_pos = None

    b = BAM_Reader(bamfile)
    counts = zeros(totallength, dtype="uint32")

    #print("counts: ", counts)

    for iread, read in enumerate(b):
        # progress indication
        if iread % 1000000 == 0:
            log.info("%d reads done" % iread)

        if not read.aligned or read.aQual < min_aqual or read.not_primary_alignment:
            continue

        if read.read.seq == lastseq:
            counts_pos = last_counts_pos
        else:
            # get pos of most 5' pos
            cops = sorted(read.cigar, key=lambda co: co.ref_iv.start)
            if any((co.type in {"D", "I"} for co in cops)):
                continue

            mcops = filter(lambda co: co.type == "M", cops)
            if read.iv.strand == "+":
                pos = mcops[0].ref_iv.start
            else:
                pos = mcops[-1].ref_iv.end - 1

            try:
                overlapping_tids = a[read.iv.chrom][read.iv.strand][pos]
            except KeyError:
                overlapping_tids = []

            counts_pos = []
            for tid in overlapping_tids:
                tc = ts[tid]
                txrelpos = tc.to_transcript_coordinate(pos)
                tididx = tid2idx[tid]
                assert 0 <= txrelpos < tidlengths[tididx]
                tidpos = tidarraypos[tididx]
                counts_pos.append(tidpos + txrelpos)

            last_counts_pos = counts_pos

        #print("counts now: ", counts)
        #print("counts_pos: ", counts_pos)
	#print("type counts: ", type(counts))
	#print("type counts_pos: ", type(counts_pos))

	counts_pos = numpy.asarray(counts_pos)
	#print("type counts_pos 2 : ", type(counts_pos))
	counts_pos = counts_pos.astype(int)


        counts[counts_pos] += 1

        lastseq = read.read.seq
    return counts


def write_counts(h5file, dsname, counts):

    print("dsname", dsname)

    h5file.create_dataset(dsname, data=counts, compression=9)
    h5file.flush()

    return


def main():
    import argparse
    ap = argparse.ArgumentParser(description="")
    ap.add_argument('-t', '--transcript-data-file', required=True)
    ap.add_argument('-b', '--baminfo', help="file with two columns: name<TAB>bamfile", required=True)
    ap.add_argument('-o', '--outfile', required=True)
    ap.add_argument('-a', '--min-aqual', default=0, type=int, required=False)
    ap.add_argument('-v', '--verbose', action="count", default=0, required=False)
    ap.add_argument('-q', '--quiet', action="store_true", default=False, required=False)

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

    h5file = h5py.File(args.outfile, 'w')

    bams = map(lambda l: l.rstrip().split("\t", 1), open(args.baminfo))

    log.info("Processing transcript data file '%s'" % args.transcript_data_file)
    a, ts, tid2idx, tidlengths = read_transcripts(args.transcript_data_file)
    log.info("Processing transcript data file '%s' [DONE]" % args.transcript_data_file)

    for bamname, bamfile in bams:
       	bamname = bamname + ".fastq.gz" 
        log.info("Processing BAM file '%s'" % bamname)
        counts = process_bam(bamfile, a, ts, tid2idx, tidlengths, args.min_aqual)
        write_counts(h5file, "/counts/%s" % bamname, counts)
        log.info("Processing BAM file '%s' [DONE]" % bamname)

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
