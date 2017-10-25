#!/bin/csh

nmrPipe -in ./test.fid \
      |   nmrPipe  -fn SOL                                    \
      |   nmrPipe  -fn SP -off 0.4  -end 0.98 -pow 2 -c .5    \
      |   nmrPipe  -fn ZF -auto                               \
      |   nmrPipe  -fn FT                                     \
      |   nmrPipe  -fn PS -p0 0. -p1 0.0 -di               \
      |   nmrPipe  -fn EXT  -sw  -xn -1 ppm -x1 6 ppm         \
      |   nmrPipe  -fn TP                                     \
      |   nmrPipe  -fn SP -off 0.5  -end 0.98 -pow 2 -c .5    \
      |   nmrPipe  -fn ZF -auto                               \
      |   nmrPipe  -fn FT -alt                                   \
      |   nmrPipe  -fn PS -p0 180 -p1 0  -di                  \
      |   nmrPipe  -fn CS -ls 10ppm -sw                         \
      |   nmrPipe  -fn TP                                     \
      |   pipe2xyz -out ./ft/test%03d.ft2 -ov 

xyz2pipe -in ./ft/test%03d.ft2 | nmrPipe -ov -verb -out test.ft2

echo 'changing the dimensions in the 2D slices'
cd ft/
sethdr test001.ft2 -ndim 2
sethdr test002.ft2 -ndim 2
cd ../
