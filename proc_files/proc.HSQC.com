#!/bin/csh


nmrPipe -in test.fid\
# solvent filter                                      \
#| nmrPipe  -fn SOL                                    \
# window function (sine bell I think)                 \
| nmrPipe  -fn SP -off 0.5 -end 0.98 -pow 2 -c 0.5    \
# Zero fill                                           \
| nmrPipe  -fn ZF -auto                               \
# Fourier transform                                   \
| nmrPipe  -fn FT                                     \
#  phase correction                                    \
| nmrPipe  -fn PS -p0 0.0  -p1 0.0 -di                 \
# remove some of the spectrum                          \
#| nmrPipe  -fn EXT -left -sw -verb                    \
# transpose                                           \
| nmrPipe  -fn TP                                     \
# window function (sine bell I think)                 \
| nmrPipe -fn LP -ord 8 -fb -verb \
| nmrPipe  -fn SP -off 0.5 -end 0.98 -pow 1 -c 1.0    \
# Zero fill                                           \
| nmrPipe  -fn ZF -auto                               \
# Fourier transform                                   \
| nmrPipe  -fn FT -alt                                     \
#  phase correction                                    \
| nmrPipe  -fn PS -p0 -90 -p1 180 -di                \
# transpose                                           \
| nmrPipe  -fn TP                                     \
   -verb -ov -out test.ft2
   
