"""
Routine for barplot of codons
"""

import colorsys

from numpy import arange, ceil, log2, sign, atleast_1d
from matplotlib import pyplot, transforms


_CODON_TABLE_STR = """
TTT     Phe F
TTC     Phe F
TTA     Leu L
TTG     Leu L
CTT     Leu L
CTC     Leu L
CTA     Leu L
CTG     Leu L
ATT     Ile I
ATC     Ile I
ATA     Ile I
ATG     Met M
GTT     Val V
GTC     Val V
GTA     Val V
GTG     Val V
TCT     Ser S
TCC     Ser S
TCA     Ser S
TCG     Ser S
CCT     Pro P
CCC     Pro P
CCA     Pro P
CCG     Pro P
ACT     Thr T
ACC     Thr T
ACA     Thr T
ACG     Thr T
GCT     Ala A
GCC     Ala A
GCA     Ala A
GCG     Ala A
TAT     Tyr Y
TAC     Tyr Y
TAA     STOP *
TAG     STOP *
CAT     His H
CAC     His H
CAA     Gln Q
CAG     Gln Q
AAT     Asn N
AAC     Asn N
AAA     Lys K
AAG     Lys K
GAT     Asp D
GAC     Asp D
GAA     Glu E
GAG     Glu E
TGT     Cys C
TGC     Cys C
TGA     STOP *
TGG     Trp W
CGT     Arg R
CGC     Arg R
CGA     Arg R
CGG     Arg R
AGT     Ser S
AGC     Ser S
AGA     Arg R
AGG     Arg R
GGT     Gly G
GGC     Gly G
GGA     Gly G
GGG     Gly G
"""
_CODON_TABLE = dict(map(lambda fields: (fields[0], fields[1]), map(lambda line: line.strip().split(), filter(None, _CODON_TABLE_STR.splitlines()))))
_AA_COLMAP = dict([(x, colorsys.hls_to_rgb(i / float(len(sorted(set(_CODON_TABLE.values())))), 0.5, 0.5)) for (i, x) in enumerate(sorted(set(_CODON_TABLE.values())))])
_AA_SHORTNAME = dict(map(lambda fields: (fields[0], fields[2]), map(lambda line: line.strip().split(), filter(None, _CODON_TABLE_STR.splitlines()))))


def codon_barplot(heights, labels, **kwargs):
    if not len(heights) == len(labels):
        raise ValueError

    figsize = kwargs.get("figsize", (12, 9))
    sort_aa = kwargs.get("sort_aa", False)
    remove_stop = kwargs.get("remove_stop", False)
    axylabel = kwargs.get("axylabel", None)
    ylimits = kwargs.get("ylimits", None)
    grid = kwargs.get("grid", False)

    if remove_stop:
        remove_idx = [(_CODON_TABLE[x] == "STOP") for x in labels]
        labels = [labels[i] for i in xrange(len(labels)) if not remove_idx[i]]
        heights = [heights[i] for i in xrange(len(heights)) if not remove_idx[i]]

    if sort_aa:
        # re-order by amino acid
        sorted_codons = [k for (k, v) in sorted(_CODON_TABLE.items(), key=lambda (k, v): (v, k))]
        #sorted_codons = [k for (k, v) in sorted(_CODON_TABLE.items(), key=lambda (k, v): (k.count("A") + k.count("T"), k))]  # orders by AT richness
        sort_idx = sorted(range(len(labels)), key=lambda i: sorted_codons.index(labels[i]))
        labels = [labels[i] for i in sort_idx]
        heights = [heights[i] for i in sort_idx]

    heights = atleast_1d(heights)

    colors = [_AA_COLMAP[_CODON_TABLE[x]] for x in labels]

    fig = pyplot.figure(figsize=figsize)
    ax = fig.add_subplot(1, 1, 1)

    pos_x = 0.5 + arange(len(heights))

    ax.bar(pos_x, heights, color=colors, align="center")
    ax.set_xticks(pos_x)
    ax.set_xticklabels(labels, rotation=60, ha="center", va="top")

    # transforms.blended_transform_factory
    maxabsshift = max(abs(heights)) * 1.1
    ylim_order = 2 ** ceil(log2(maxabsshift))
    ylim = ylim_order * ceil(maxabsshift / ylim_order)

    pos_text_trans = ax.transData + transforms.ScaledTranslation(0.0, 9. / 72, fig.dpi_scale_trans)
    neg_text_trans = ax.transData + transforms.ScaledTranslation(0.0, -9. / 72, fig.dpi_scale_trans)
    for i in xrange(len(heights)):
        if sign(heights[i]) < 0:
            texttrans = neg_text_trans
        else:
            texttrans = pos_text_trans

        ax.text(pos_x[i], heights[i], _AA_SHORTNAME[labels[i]], transform=texttrans, ha="center", va="center")

    if ylimits is None:
        ax.set_ylim((-1 * ylim, ylim))
    else:
        ax.set_ylim((ylimits[0], ylimits[1]))

    ax.set_xlim((0, len(heights)))

    if grid:
        neg_grid_trans = ax.transScale + ax.transLimits + ((ax.transAxes + transforms.ScaledTranslation(0.0, -16. / 72, fig.dpi_scale_trans)) + ax.transAxes.inverted())
        for i in xrange(pos_x.size):
            if heights[i] < 0:
                ax.axvline(pos_x[i], 0, neg_grid_trans.transform((0.0, heights[i]))[1], zorder=-1, color="grey", alpha=0.3)
            else:
                ax.axvline(pos_x[i], 0, 0.5, zorder=-1, color="grey", alpha=0.3)

    ax.set_xlabel("Codon")
    if axylabel is not None:
        ax.set_ylabel(axylabel)

    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.get_xaxis().tick_bottom()
    ax.get_yaxis().tick_left()

    return fig
