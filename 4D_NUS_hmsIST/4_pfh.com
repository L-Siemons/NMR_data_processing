#!/bin/tcsh

# here we just re-organize the spectrum again
# Note the binary name needs to be the same and the 
# dimensions need to be changed 

# collect spectra
echo 'collecting spectrum'
xyz2pipe -in ./ft1/testnus%04d.ft1.phf                      \
    | phf2pipe_v211_64b -xN 92 -yN 92 -zN 128 -user 0 -dim 3 \
    | pipe2xyz -out ./yzx/test%03d.ist.ft1 -ov
