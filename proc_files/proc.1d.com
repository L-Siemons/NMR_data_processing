#!/bin/csh

### 1D PROCESSING ###

nmrPipe    -in bruker.fid                               \
| nmrPipe  -fn EM -lb 0.3  \
| nmrPipe  -fn ZF -auto                                 \
| nmrPipe  -fn FT -auto                                 \
| nmrPipe  -fn PS -p0 17.8 -p1 0.00 -di -verb         \
| nmrPipe  -fn POLY -auto\
	-ov -out spectrum.ft
