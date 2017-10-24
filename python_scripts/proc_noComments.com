xyz2pipe -in fid/test%03d.fid -x -verb                   \
      |   nmrPipe  -fn SOL                                    \
      |   nmrPipe  -fn SP -off 0.4  -end 0.98 -pow 2 -c .5    \
      |   nmrPipe  -fn ZF -auto                               \
      |   nmrPipe  -fn FT                                     \
      |   nmrPipe  -fn PS -p0 10.4 -p1 -21. -di               \
      |   nmrPipe  -fn EXT  -sw  -xn 5ppm -x1 11ppm            \         
      |   nmrPipe  -fn TP                                     \
      |   nmrPipe  -fn SP -off 0.5  -end 0.98 -pow 2 -c .5    \
      |   nmrPipe  -fn ZF -auto                               \
      |   nmrPipe  -fn FT                                     \
      |   nmrPipe  -fn PS -p0 -91.6 -p1 0  -di               \
      |   nmrPipe  -fn TP                                     \
      |   pipe2xyz -out ft/test%03d.ft2 -x -ov              \
xyz2pipe -in ft/test%03d.ft2  -z -verb                     \
     |   nmrPipe -fn SP -off 0.5 -end 0.98 -pow 2 -c .5   \
     |   nmrPipe -fn ZF -auto                              \
     |   nmrPipe -fn FT -alt                       \
     |   nmrPipe -fn PS -p0 -11.5 -p1 14. -di                 \
     |   nmrPipe -fn ZTP                                       \
     |   pipe2xyz -out ft/test%03d.ft3  -z
xyz2pipe -in ft/test%03d.ft3 | nmrPipe -ov -verb -out test.ft3
proj3D.tcl test.ft3
