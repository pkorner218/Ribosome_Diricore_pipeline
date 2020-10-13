#!/usr/bin/env python
#

"""
"""

from __future__ import absolute_import
import os
import sys

import numpy as np

import matplotlib
if os.environ.get('DISPLAY','') == '':
#    print('no display found. Using non-interactive Agg backend')
    matplotlib.use('Agg')

from matplotlib import pyplot
from matplotlib.patches import Rectangle
from matplotlib.font_manager import FontProperties
import seaborn
seaborn.reset_orig()
import numpy

sys.path.append(os.path.join(os.path.dirname(__file__), '../lib/'))
from plottxcoords import get_means, read_sampleinfo ##############


SUBPLOTSIZE = (6, 6 * 10 / 16.)
SUBPLOTPARS = {"left": 0.125, "right": 0.9, "top": 0.9, "bottom": 0.1, "wspace": 0.2, "hspace": 0.2}

XTICKFONT = FontProperties(weight="bold", size=10) # original 18
YTICKFONT = FontProperties(weight="bold", size=12)
LABELFONT = FontProperties(weight="bold", size=8) # original 13
TITLEFONT = FontProperties(weight="bold", size=22)


def calc_figsize(fignrc, subplotsize, subplotpars):
    # fignrc is (nrow, ncol)
    # but subplotsize is (x, y)
    x = fignrc[1] * subplotsize[0] / \
            (subplotpars.get("right", 1.0) - subplotpars.get("left", 0.0) - subplotpars.get("wspace", 0.0))
    y = fignrc[0] * subplotsize[1] / \
            (subplotpars.get("top", 1.0) - subplotpars.get("bottom", 0.0) - subplotpars.get("hspace", 0.0))
 
#    print("x",y)
#    print("y",y)

    return (x, y)


def plot_5p_rpf_density_difference(h5fn, pairs, codongroups, h5mapsfn, min_reads=100, ylim=None, prettynames=None, centered_at_x0=False):
    # assume samples is list of (cond, ref, color)
    # assume codondata is map of aa -> indexname

    if centered_at_x0:
       ## X = numpy.arange(-30, 31)
       X = numpy.arange(-30,71)
       ###X = numpy.arange(-30,141)
    else:
       ## X = numpy.arange(-30, 31) + 1
       X = numpy.arange(-30,71) + 1
       ###X = numpy.arange(-30,141) + 1
 #Y = numpy.arange(-70,71)

    figsize = calc_figsize((len(pairs), len(codongroups)), SUBPLOTSIZE, SUBPLOTPARS)
    fig, axs = pyplot.subplots(len(pairs), len(codongroups), sharex=True, sharey=True, squeeze=False, figsize=figsize)

#    print ("pairs",pairs)


    for i_pair, pairdata in enumerate(pairs):
#	print ("i_pair",i_pair)
#	print ("pairdata",pairdata)

        refsampleid, condsampleid, linecolor = pairdata
        samples = [(h5fn, condsampleid, None), (h5fn, refsampleid, None)]
        means, passing_cutoff = get_means(samples, codongroups, h5mapsfn, min_reads, intersect=True, smooth3nt=True)

    h5fn = str(h5fn) 
    h5fn = h5fn.split("files/")[1]
    outstring = "./plots/" + str(h5fn) + "_temp_rpf_file.txt"
    outstring = outstring.replace(".txcoord_counts.hdf5","")

    with open(outstring,"a") as outfile:

#	print (".............................")
#	print ("HERE")
#	print (outfile)
#	print(".............................")

        for x in codongroups:
            x = str(x)
            x = x.replace("set([","")
            x = x.replace("])","")
            outfile.write(str(x)+"\n")
            #outfile.write("processed means codons:" + str(codongroups) + "\n")
        outfile.write("processed means: \n")

        meanslist = means.tolist()

        outfile.write(str(meanslist))
        outfile.write("\n"+"****"+"\n")

        outfile.close()


#	print ("get_means",get_means(samples, codongroups, h5mapsfn, min_reads, intersect=True, smooth3nt=True))
#	print ("what if intersect = False",get_means(samples, codongroups, h5mapsfn, min_reads, intersect=False))

        assert len(passing_cutoff) == len(codongroups)

        assert means.shape[1] == len(codongroups)

        for j, codongroup in enumerate(codongroups):
            ws = passing_cutoff[j]
            assert len(ws) == 2
            assert (ws[1] == ws[0]).all(), "Assumed if intersect==True"
          
#            print ("ws",ws)
#	    print ("len(axs..)",len(axs[i_pair][j]))

            ax = axs[i_pair][j]

#            print("axs parts",axs[i_pair][j])
#	    print("ax parts",[i_pair][j])
#	    print("ax",ax)

#	    print("X",X)	
#            print ("means[1,j])",means[1, j])
#            print ("means[0,j]",means[0, j])
	    
#            print (len(means[1, j]))
#	    print (len(means[0, j])) 	

	    ax.plot(X + 0.5, means[1, j] - means[0, j], color=linecolor, linewidth=3.0, alpha=0.65)

#	    print('X tickmark here', X)	

            ax.set_xticks((X + 0.5)[X % 5 == 0])					###
            ax.set_xticklabels(map(str, X[X % 5 == 0]), fontproperties=XTICKFONT)	###
            ax.xaxis.set_ticks_position('bottom')
            ax.set_xlim(X.min(), X.max())

            ax.spines['top'].set_visible(False)
            ax.spines['right'].set_visible(False)
            ax.get_xaxis().tick_bottom()
            ax.get_yaxis().tick_left()

            ax.set_title("%s" % (",".join(sorted(codongroup)), ), fontproperties=TITLEFONT)

            ylabel = "%s vs %s" % (refsampleid, condsampleid)

            if prettynames is not None:
                ylabel = "%s vs %s\n(%s)" % (prettynames[refsampleid], prettynames[condsampleid], ylabel)

            ax.set_ylabel(ylabel, ha="center", va="center", labelpad=20, fontproperties=LABELFONT)

            ax.axhline(0.0, linewidth=1.25, linestyle="--", color="#3c3c3c")

            ax.text(0.985, 0.98, "$n = %d$" % ws[0].sum(), ha="right", va="top", transform=ax.transAxes, fontsize=13, weight="bold")

    if ylim is not None and ylim != 'None':
        axs[0][0].set_ylim(ylim)

    for i in xrange(len(pairs)):
        for j in xrange(len(codongroups)):

#	    print('j',j)
#	    print('i',i)

            ax = axs[i][j]

#	    print('ax',ax)	

#	    print('ax.get here', ax.get_yticks())
#	    print('ax.get_ylabel',ax.get_yticklabels())	


            pyplot.setp(ax.get_yticklabels(), visible=True)
#            print ('ax.set at begin',ax.set_yticklabels(ax.get_yticks(), fontproperties=YTICKFONT))

	    #if ax.set_yticklabels(ax.get_yticks(), fontproperties=YTICKFONT) != []:
	    #	for item in ax.set_yticklabels(ax.get_yticks(), fontproperties=YTICKFONT):
	#		print('item',item)

	    #print('ax.get_yticks',ax.get_yticks())
	    #ele = ax.get_yticks()
	    #for arr in ele:
	    #	print ('array', arr) 
	#	print ('type arr',type(arr))
	#	arr = round(arr,2)
	#	print ('arr now', arr)
#
#		print ('ele now',ele)
            ax.set_yticklabels(np.float32(ax.get_yticks()), fontproperties=YTICKFONT)

#            print('final ax set',ax.set_yticklabels(np.float32(ax.get_yticks()), fontproperties=YTICKFONT))

#				for number in np.nditer(arr):
#					print('number',number)



#			print('type item',type(item))
#			yticker = (item.get_text())
#			print('yticker',yticker)
#			print('typeyticker',type(yticker))
#
#			yticker = float(yticker)
#			yticker = round(yticker,2)
#			print('rounded yticker', yticker)
#
#			print('ax.get',ax.get_yticks())

###			item = ax.text(s,X,str(yticker),fontproperties=YTICKFONT)
#			print('item0',item[0])
#			print('item1',item[1])
#			print('type0',type(item[0]))
#			print('type1',type(item[1]))
#			if type(item) == int:
#				item = round(item,2)
#				print('item rounded')
# 	    print('final ax set',ax.set_yticklabels(ele, fontproperties=YTICKFONT))

    for i in xrange(len(pairs)):
        for j in xrange(len(codongroups)):
            ax = axs[i][j]
            rectheight = (ax.get_ylim()[1] - ax.get_ylim()[0]) * 0.025
            rectbottom = ax.get_ylim()[0] + 0.4 * rectheight
            ax.add_patch(Rectangle((0.5, rectbottom), 3, rectheight, facecolor="black", edgecolor="none"))

    return fig


def main():
    import argparse
    ap = argparse.ArgumentParser(description="")
    ap.add_argument('--y-limits', default=None, required=False)
    ap.add_argument('--centered-at-x0', action="store_true", default=False, required=False)
    ap.add_argument('-c', '--contrasts', required=False)
    ap.add_argument('-n', '--sample-names', default=None, required=False)
    ap.add_argument('-o', '--outfile', metavar="PDF", required=False)
    ap.add_argument('-m', '--min-reads', type=int, default=100, required=False)
    ap.add_argument(dest="h5file", metavar="HDF5FILE", nargs=1)
    ap.add_argument(dest="h5mapsfile", metavar="HDF5MAPSFILE", nargs=1)
    ap.add_argument(dest="codongroups", metavar="CODON,CODON,[...]", nargs="+")
    ap.add_argument('-yx',type=int,required=False)



    args = ap.parse_args()

    h5mapsfn = args.h5mapsfile[0]

    pairs = read_sampleinfo(args.contrasts)

    print("pairs",pairs)
    print(dict(read_sampleinfo(args.sample_names)))

    if args.sample_names is not None:
        sample_names = dict(read_sampleinfo(args.sample_names))

        for (refsampleid, condsampleid, linecolor) in pairs:
            assert refsampleid in sample_names
            assert condsampleid in sample_names
    else:
        sample_names = None

    ylim = args.y_limits ###########
    print(ylim, "given y-axis limits")

#    print('ylim here almost end', ylim)
#   negative ylim, positive ylim    


#    ylim = '-5.5,0.4' ############


#    print('ylim now',ylim)

    if ylim is not None and ylim != 'None':
        ylim = map(float, ylim.split(","))[:2]

    	print('y-axis limit after mapping', ylim)


    	if ylim[1] < 0:
        	ylim = [ylim[1],ylim[0]]

    	print('y axis limit after swap', ylim)
    	print("")

    codongroups = map(lambda s: set(s.split(",")), args.codongroups)
    print(codongroups)
#    outfile = open('/DATA/pkoerner/packages/diricore/working_version/tests/actualpipe/plots/bin/plot_rpf.txt','a')

    fig = plot_5p_rpf_density_difference(args.h5file[0], pairs, codongroups, h5mapsfn, args.min_reads, ylim, sample_names, args.centered_at_x0)
    
#    print("now print")
#    outfile.write(str(args.h5file[0])+'\t'+str(pairs)+'\t'+str(codongroups)+'\t'+str(h5mapsfn)+'\t'+str(args.min_reads)+'\n')
#    outfile.close()

    fig.savefig(args.outfile, format="pdf")

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
