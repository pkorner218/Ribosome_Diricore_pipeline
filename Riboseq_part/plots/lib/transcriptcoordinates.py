import numpy


def check_increasing(coordinatemap):
    """
    Sanity check that checks whether all coordinates are in increasing order, and no interval is zero-length
    """

    # flatten, trick to check along 1st dimension and 2nd in a single go
    return (numpy.diff(coordinatemap.flatten()) > 0).all()


class BaseTranscriptCoordinates(object):
    def __init__(self, coordinatemap, copy=True):
        if not hasattr(coordinatemap, "ndim"):
            raise ValueError("Need numpy array or compatible")

        if not coordinatemap.ndim == 2 and coordinatemap.shape[1] == 2:
            raise ValueError("Invalid coordinate dimensions/shape")

        if copy:
            self.coordinatemap = coordinatemap.copy()
        else:
            self.coordinatemap = coordinatemap

        self.runningsum = numpy.diff(self.coordinatemap).cumsum().astype(coordinatemap.dtype)
        self.length = int(self.runningsum[-1])
        self._genomic_coordinate_buffer = numpy.empty((10, 2), dtype=coordinatemap.dtype)

    def _local_to_iv_relative(self, pos):
        iiv = numpy.searchsorted(self.runningsum, pos, side="right")
        if iiv > 0:
            l = pos - self.runningsum[iiv - 1]
        else:
            l = pos

        return iiv, l

    def to_genomic_coordinate(self, pos):
        if not 0 <= pos < self.length:
            raise ValueError("pos out of range")

        iiv, l = self._local_to_iv_relative(pos)
        gc = self.coordinatemap[iiv][0] + l

        return gc

    def to_genomic_interval(self, a, b):
        if not 0 <= a < self.length:
            raise ValueError("a not in range")

        if not 0 < b <= self.length:
            raise ValueError("b not in range")

        if a == b:
            p = self.to_genomic_coordinate(a)
            return numpy.array([[p, p]])
        elif b < a:
            a, b = b, a

        iiva, la = self._local_to_iv_relative(a)
        iivb, lb = self._local_to_iv_relative(b - 1)  # NOTE: b is end non-inclusive

        gca = self.coordinatemap[iiva][0] + la
        gcb = self.coordinatemap[iivb][0] + lb + 1

        if iiva == iivb:
            return numpy.array([[gca, gcb]])
        else:
            n = iivb - iiva + 1
            if n > self._genomic_coordinate_buffer.shape[0]:
                # buffer not big enough (more exons than capable), so construct new array obj
                aiv = [gca, self.coordinatemap[iiva][1]]
                biv = [self.coordinatemap[iivb][0], gcb]
                return numpy.r_[[aiv], self.coordinatemap[iiva + 1:iivb], [biv]]
            else:
                self._genomic_coordinate_buffer[0, 0] = gca
                self._genomic_coordinate_buffer[0, 1] = self.coordinatemap[iiva][1]
                self._genomic_coordinate_buffer[1:(n - 1)] = self.coordinatemap[(iiva + 1):iivb]
                self._genomic_coordinate_buffer[n - 1, 0] = self.coordinatemap[iivb][0]
                self._genomic_coordinate_buffer[n - 1, 1] = gcb
                return self._genomic_coordinate_buffer[:n]

    def to_transcript_coordinate(self, pos):
        a = pos >= self.coordinatemap[:, 0]
        b = pos < self.coordinatemap[:, 1]
        w = (a & b)
        n = w.sum()
        if n < 1:
            raise ValueError("pos not in interval")
        if n > 1:
            raise ValueError("invalid interval")

        iiv = w.argmax()
        if iiv > 0:
            l = self.runningsum[iiv - 1]
        else:
            l = 0

        tc = l + (pos - self.coordinatemap[iiv, 0])

        return tc

    def to_transcript_interval(self, a, b):
        raise NotImplementedError()


class NegativeStrandTranscriptCoordinates(BaseTranscriptCoordinates):
    def __init__(self, coordinatemap, copy=True):
        super(NegativeStrandTranscriptCoordinates, self).__init__(coordinatemap, copy)

    def to_genomic_coordinate(self, pos):
        # BaseTranscriptCoordinates deals in forward coordinates
        # query is in reverse coordinates
        revpos = self.length - 1 - pos
        return super(NegativeStrandTranscriptCoordinates, self).to_genomic_coordinate(revpos)

    def to_genomic_interval(self, a, b):
        reva = self.length - b
        revb = self.length - a
        return super(NegativeStrandTranscriptCoordinates, self).to_genomic_interval(reva, revb)

    def to_transcript_coordinate(self, pos):
        tc = super(NegativeStrandTranscriptCoordinates, self).to_transcript_coordinate(pos)
        # tc is in forward coordinates
        revtc = self.length - 1 - tc
        return revtc

    def to_transcript_interval(self, *args):
        raise NotImplementedError()


class TranscriptCoordinates(object):
    def __new__(cls, coordinatemap, strand="+", copy=True):
        if cls is TranscriptCoordinates:
            if strand == "+":
                o = super(TranscriptCoordinates, cls).__new__(BaseTranscriptCoordinates)
            else:
                o = super(TranscriptCoordinates, cls).__new__(NegativeStrandTranscriptCoordinates)
        else:
            o = super(TranscriptCoordinates, cls).__new__(cls, coordinatemap, copy)

        o.__init__(coordinatemap, copy)
        return o
