#!/bin/csh
# note: -yMODE           Real 


bruk2pipe -in ./ser \
  -bad 0.0 -aswap -DMX -decim 1564 -dspfvs 21 -grpdly 76  \
  -xN              2048  -yN                 2  -zN               536  \
  -xT              1024  -yT                 1  -zT               268  \
  -xMODE            DQD  -yMODE           Real  -zMODE        Complex  \
  -xSW        12787.724  -ySW         5030.181  -zSW         5030.181  \
  -xOBS         800.254  -yOBS         201.223  -zOBS         201.223  \
  -xCAR           4.771  -yCAR           2.740  -zCAR          24.739  \
  -xLAB              1H  -yLAB        coupling  -zLAB             13C  \
  -ndim               3  -aq2D          States                         \
  -out ./fid/test%03d.fid -verb -ov

# this is to deal with it only being a pseudo 3D
xyz2pipe -in ./fid/test%03d.fid \
  | nmrPipe -fn TP  -auto \
  | nmrPipe -fn ZTP -auto \
  | nmrPipe -fn TP -auto \
  | nmrPipe -out test.fid -ov -verb
