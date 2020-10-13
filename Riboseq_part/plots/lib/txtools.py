from transcriptcoordinates import TranscriptCoordinates

from numpy import array


def validate_and_extract_cds(fs):
    """
    Validates CDS, start_codon, and stop_codon features.
    Returns a tuple of a TranscriptCoordinates object and (CDS start, CDS stop).

    Raises a ValueError if the CDS is invalid.
    """

    fs = sorted(fs, key=lambda f: f.iv.start)

    exonf = filter(lambda f: f.type == "exon", fs)
    cdsf = filter(lambda f: f.type == "CDS", fs)
    startf = filter(lambda f: f.type == "start_codon", fs)
    stopf = filter(lambda f: f.type == "stop_codon", fs)

    strands = map(lambda f: f.iv.strand, fs)
    assert len(set(strands)) == 1
    strand = strands[0]

    coordmap = array(map(lambda f: (f.iv.start, f.iv.end), exonf))
    tc = TranscriptCoordinates(coordmap, strand)

    validstart = sum(((f.iv.end - f.iv.start) for f in startf)) == 3
    validstop = sum(((f.iv.end - f.iv.start) for f in stopf)) == 3
    validcds = sum(((f.iv.end - f.iv.start) for f in cdsf)) % 3 == 0

    if not (validstart and validstop and validcds):
        raise ValueError("Invalid CDS")

    if strand == "+":
        cdsstart = tc.to_transcript_coordinate(cdsf[0].iv.start)
        cdsend = tc.to_transcript_coordinate(cdsf[-1].iv.end - 1) + 1
    else:
        cdsstart = tc.to_transcript_coordinate(cdsf[-1].iv.end - 1)
        cdsend = tc.to_transcript_coordinate(cdsf[0].iv.start) + 1

    return tc, (cdsstart, cdsend)
