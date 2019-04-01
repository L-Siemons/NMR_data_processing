#!/bin/tcsh

# Here we unpack the ser file. All the sweep widths and carriers can be taken as 
# normal. However note that the modes are Real for the indirect dimensions 

# for 4D NUS processing with HMSist the yN must be 8 and the aN must be 1 as below. 
# the points in the Z dimension are simply the total number of fids collected (number of lines in nuslist)

# note if you get funny behavior with the indirect dimensions try changing -DMX to -AMX (or visa versa)

echo 'converting from bruker to pipe'
bruk2pipe -in ../ser  \
  -bad 0.0 -ext -aswap -DMX -decim 1792 -dspfvs 20 -grpdly 67.9841766357422  \
  -xN         2048  -yN           8  -zN        2941   -aN           1  \
  -xT         1024  -yT           8  -zT        2941   -aT           1  \
  -xMODE            DQD  -yMODE           Real  -zMODE      Real     -aMODE        Real \
  -xSW        11160.714  -ySW         3219.575  -zSW         3219.575  -aSW         2120.441  \
  -xOBS         800.280  -yOBS         201.235  -zOBS         201.235  -aOBS         800.280  \
  -xCAR           0.250  -yCAR          22.700  -zCAR          22.700  -aCAR           0.250  \
  -xLAB              1H  -yLAB            13Cy  -zLAB            13Cz  -aLAB             1Ha  \
  -ndim               3  -aq2D         Complex                         \
  | nmrPipe -ov -out ./fid/nuss.fid 


# Fourier transform 1H direct dimension and phase it. 
# to save computational time I highly suggest taking the region of interest in the
# direct dimension.

# steps
#   1) comment out the -EXT lines and process. 
#   2) then open data/testnus.ft1 with nmrDraw and phase the first 1D
#   3) add the correct phase and then set the -EXT and re-process 

echo 'transforming the direct dimension'
nmrPipe -in ./fid/nuss.fid                              \
  | nmrPipe  -fn SP -off 0.48 -end 0.98 -pow 2 -c 0.5   \
  | nmrPipe  -fn ZF -auto                               \
  | nmrPipe  -fn FT -verb                               \
  | nmrPipe  -fn PS -p0 -137  -p1 0.0    -di          \
  | nmrPipe  -fn EXT -x1  1.7ppm -xn -1.ppm -sw       \
#  | nmrPipe  -fn EXT -x1  0.21ppm -xn 0.17ppm -sw       \
  | nmrPipe  -out ./data/testnus.ft1 -ov
