#!/usr/bin/env python
#

"""
"""

import os
import sys
from itertools import imap

sys.path.append(os.path.join(os.path.dirname(__file__), '../lib/'))
from plotutils.codon_barplot import codon_barplot
from calculate_subsequence_shift import calculate_subsequence_shift, CODONS

print("now in plot_subsequence_shifts.py")

LEVELNAMES = ["f9", "f12", "f15", "f18"]

def create_subseq_shift_plot(shifts, w, min_reads, keep_stop=False, ylimits=1, title=None, supertitle=None):
    fig = codon_barplot(shifts, CODONS, figsize=(20, 13), sort_aa=True, remove_stop=not keep_stop, ylimits=ylimits, grid=False)

    fig.text(fig.subplotpars.right, fig.subplotpars.top, "%s genes (min_reads=%d)" % (w.sum(), min_reads), va="top", ha="right", size=13)

    if title:
        fig.text(0.5, 0.95, title, size=21, ha="center", va="center")

    if supertitle:
        fig.text(0.5, 0.975, supertitle, size=11, ha="center", va="center")

    return fig


line2fields = lambda line: line.rstrip("\n").split("\t")


def parse_contrast(fh):
    l = list()
    for fields in imap(line2fields, fh):
        condsampleid, refsampleid = fields

	print("condsampleid: ",condsampleid)
	print("refsampleid: ",refsampleid)
	print("fields", fields)

        l.append((condsampleid, refsampleid))

    return l


def parse_sample_names(fh):
    d = dict()
    for fields in imap(line2fields, fh):

        print ("here...", fields)

        identifier, name = fields
        assert identifier not in d
        d[identifier] = name

	print("d", d)

    return d


def main():
    import argparse
    ap = argparse.ArgumentParser(description="")
    ap.add_argument('-s', '--keep-stop', action="store_true", default=False, required=False)
    ap.add_argument('-o', '--outbase', required=True)
    ap.add_argument('-m', '--min-reads', type=int, default=640, required=False)
    ap.add_argument('--y-limits', metavar="MIN,MAX", default=None, required=False)
    ap.add_argument('--sample-names', metavar="FILE", required=False)
    ap.add_argument('--contrasts', metavar="FILE", required=True)
    ap.add_argument('h5file', metavar="HDF5_FILE", nargs=1)

    args = ap.parse_args()

    ylims_str = args.y_limits
    if ylims_str is None:
        ylimits = None
    else:
        ylimits = map(float, ylims_str.split(","))

    contrasts = parse_contrast(open(args.contrasts))

    print("contrasts: ", contrasts)	

    h5fn = args.h5file[0]
    assert os.access(h5fn, os.R_OK)

    if args.sample_names:
        sample_names = parse_sample_names(open(args.sample_names))
	print("sample_names: ", sample_names)
	print("contrasts: ", contrasts)

        for record in contrasts:
            print ("record: ", record)
	    print ("record 0: ", record[0])
	    print ("record 1: ", record[1])

            assert record[0] in sample_names
            assert record[1] in sample_names
    else:
        sample_names = None

    for condsampleid, refsampleid in contrasts:
        shifts, w = calculate_subsequence_shift((condsampleid, h5fn), (refsampleid, h5fn), args.min_reads)
        assert len(shifts) == len(LEVELNAMES)

        for ilevel in xrange(len(shifts)):
            levelname = LEVELNAMES[ilevel]

            supertitle = "%s vs. %s (%s)" % (condsampleid, refsampleid, levelname)

            if sample_names:

		print("sample_names :", sample_names)
                condname = sample_names[condsampleid]
                ctrlname = sample_names[refsampleid]

		print("condname: ", condname)
		print("ctrlname: ", ctrlname)

                title = "%s vs. %s (pos %s)" % (condname, ctrlname, levelname)
                outfile = "%s%s_vs_%s.%s_vs_%s.%s.subsequence_shift_plot.pdf" % (args.outbase, condsampleid, refsampleid, condname, ctrlname, levelname)
            else:
                title = None
                outfile = "%s%s_vs_%s.%s.subsequence_shift_plot.pdf" % (args.outbase, condsampleid, refsampleid, levelname)

	    ylimits = [-1,1]
	    print('ylimits at end', ylimits)

            print("Plotting %s vs. %s; %s" % (condsampleid, refsampleid, levelname))
            fig = create_subseq_shift_plot(shifts[ilevel], w, args.min_reads, args.keep_stop, ylimits, title, supertitle)
            fig.savefig(outfile, format="pdf")
            del fig

    return


if __name__ == "__main__":
    main()
