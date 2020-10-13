#!/usr/bin/env python
#

"""
"""

import os

from itertools import product, repeat, imap

import h5py
from numpy import newaxis


_BASES = "ACGT"
CODONS = list(imap(lambda t: "".join(t), product(*repeat(_BASES, 3))))


normalize_within_genes = lambda a: a / a.sum(axis=2)[:, :, newaxis].astype(float)


def calculate_subsequence_shift(condinfo, refinfo, min_reads):
    refsampleid, reffn = refinfo
    condsampleid, condfn = condinfo

    refdata = h5py.File(reffn, 'r')[refsampleid][:]
    conddata = h5py.File(condfn, 'r')[condsampleid][:]

    w = (refdata.sum(axis=2) >= min_reads).all(axis=1) & (conddata.sum(axis=2) >= min_reads).all(axis=1)

    refnorm = normalize_within_genes(refdata[w])
    condnorm = normalize_within_genes(conddata[w])

    shifts = (condnorm.mean(axis=0) - refnorm.mean(axis=0)) / refnorm.mean(axis=0)

    return shifts, w


def write_shifts(outfile, shifts):
    outfh = open(outfile, 'w')

    # write header
    outfh.write("\t".join(CODONS))
    outfh.write("\n")

    for row in shifts:
        # each row describes a subsequence pos.
        outfh.write("\t".join(map(str, row)))
        outfh.write("\n")

    outfh.close()


def main():
    import argparse
    ap = argparse.ArgumentParser(description="")
    ap.add_argument('-o', '--outfile', required=True)
    ap.add_argument('-m', '--min-reads', type=int, default=100, required=False)
    ap.add_argument(dest="condinfo", help="<sampleid>,<h5filename>", nargs=1)
    ap.add_argument(dest="refinfo", help="<sampleid>,<h5filename>", nargs=1)

    args = ap.parse_args()

    condinfo = args.condinfo[0].split(",", 1)
    refinfo = args.refinfo[0].split(",", 1)

    if not os.access(condinfo[1], os.R_OK):
        ap.error("Can't read file: %s" % condinfo[1])

    if not os.access(refinfo[1], os.R_OK):
        ap.error("Can't read file: %s" % refinfo[1])

    if not os.access(os.path.dirname(args.outfile), os.W_OK):
        ap.error("Can't write outfile")

    shifts, w = calculate_subsequence_shift(condinfo, refinfo, args.min_reads)
    #print(w.sum())

    write_shifts(args.outfile, shifts)

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
