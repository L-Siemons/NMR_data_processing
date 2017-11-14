#!/bin/csh

echo 'processing using a Gm window function, edit g2 as required'
echo 'to get rid of the sinc wiggles, this is in Hz and depends on the'
echo 'sweep width, generally we don't change g1 and g3'

nmrPipe -in ./test.fid \
      |   nmrPipe  -fn GM -g1 0. -g2 12 -g3 0.0 -c 0.5        \
      |   nmrPipe  -fn ZF -auto                               \
      |   nmrPipe  -fn FT                                     \
      |   nmrPipe  -fn PS -p0 0. -p1 0. -di               \
      |   nmrPipe  -fn EXT  -sw  -xn -1 ppm -x1 6 ppm         \
      |   nmrPipe  -fn TP                                     \
      |   nmrPipe  -fn GM -g1 0. -g2 20 -g3 0.0 -c 0.50       \
      |   nmrPipe  -fn ZF -auto                               \
      |   nmrPipe  -fn FT -alt                                   \
      |   nmrPipe  -fn PS -p0 180 -p1 0  -di                  \
      |   nmrPipe  -fn CS -ls 10ppm -sw                         \
      |   nmrPipe  -fn TP                                     \
      |   nmrPipe  -fn POLY -auto \
      |   pipe2xyz -out ./ft/test%03d.ft2 -ov 

xyz2pipe -in ./ft/test%03d.ft2 | nmrPipe -ov -verb -out test.ft2

echo 'changing the dimensions in the 2D slices'
cd ft/
sethdr test001.ft2 -ndim 2
sethdr test002.ft2 -ndim 2
cd ../

echo 'notes at the end:'
echo '' 
