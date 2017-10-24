#!/bin/csh

xyz2pipe -in fid/test%03d.fid -x -verb                   \
#     Add solvent filter                                      \
      |   nmrPipe  -fn SOL                                    \
#     window function (sine bell)                             \
      |   nmrPipe  -fn SP -off 0.4  -end 0.98 -pow 2 -c .5    \
#     Zero fill                                               \
      |   nmrPipe  -fn ZF -auto                               \
#     Fourier transform                                       \
      |   nmrPipe  -fn FT                                     \
#     phase correction                                        \
      |   nmrPipe  -fn PS -p0 10.4 -p1 -21. -di               \
#     Delete part of the spectrum (in this case it didnt have anthing in it) \
      |   nmrPipe  -fn EXT  -sw  -xn 5ppm -x1 11ppm            \
#     Transpose                                               \
      |   nmrPipe  -fn TP                                     \
#      window function (sine bell)                             \
      |   nmrPipe  -fn SP -off 0.5  -end 0.98 -pow 2 -c .5    \
#     Zero fill                                               \
      |   nmrPipe  -fn ZF -auto                               \
#     Fourier transform                                       \
      |   nmrPipe  -fn FT                                     \
#     phase correction                                        \
      |   nmrPipe  -fn PS -p0 -91.6 -p1 0  -di               \
#     Transpose                                               \
      |   nmrPipe  -fn TP                                     \
#write out the 2D planes                                     \
      |   pipe2xyz -out ft/test%03d.ft2 -x -ov              \

#now process the 3D cube                                   \
xyz2pipe -in ft/test%03d.ft2  -z -verb                     \
#     window function (sine bell)                             \
     |   nmrPipe -fn SP -off 0.5 -end 0.98 -pow 2 -c .5   \
#     Zero fill                                               \
     |   nmrPipe -fn ZF -auto                              \
#     Fourier transform                                       \
     |   nmrPipe -fn FT -alt                       \
#     phase correction                                        \
     |   nmrPipe -fn PS -p0 -11.5 -p1 14. -di                 \
#     Transpose Y and Z dimensions I think ...                 \
     |   nmrPipe -fn ZTP                                       \
#     write out the planes                                     \
     |   pipe2xyz -out ft/test%03d.ft3  -z

# Here we write out the complete cube 
xyz2pipe -in ft/test%03d.ft3 | nmrPipe -ov -verb -out test.ft3
# calculate the projections ... useful for phasing!
proj3D.tcl test.ft3
