#!/bin/tcsh

# Here we do the normal nmrpipe processing. I just decided to do
# linear prediction in two dimensions. 

# Do the FT
echo 'doing the FT ... time for a coffee break'
xyz2pipe -in ./yzx/test%03d.ist.ft1 -verb -x  \
   # In Cy                                    \
   | nmrPipe -fn EXT -time -sw                \
   | nmrPipe -fn SP -off 0.50 -pow 2 -c 1.0   \
   | nmrPipe -fn ZF -auto                     \
   | nmrPipe -fn FT -alt                      \
   | nmrPipe -fn PS -p0 90 -p1 180. -di       \
   # process the Ha dim for lp in Ha          \
   | nmrPipe -fn ZTP                          \
   | nmrPipe -fn EXT -time -sw                \
   | nmrPipe -fn EM -lb 0.5 -c 0.5            \
   | nmrPipe -fn ZF -zf 1                     \
   | nmrPipe -fn FT -alt                      \
   | nmrPipe -fn PS -p0 0.0 -p1 0. -di        \
   | nmrPipe -fn ZTP                          \
   # In Cz                                    \
   | nmrPipe -fn TP                           \
   | nmrPipe -fn EXT -time -sw                \
   | nmrPipe -fn LP -ord 8 -fb -verb          \
   | nmrPipe -fn SP -off 0.50 -pow 2 -c 1.0   \
   | nmrPipe -fn ZF -auto                     \
   | nmrPipe -fn FT -alt                      \
   | nmrPipe -fn PS -p0 90. -p1 180. -di      \
   | nmrPipe -fn TP                           \
   # In Ha                                    \
   | nmrPipe -fn ZTP                          \
   | nmrPipe -fn HT -auto                     \
   | nmrPipe -fn PS -p0 0.0 -p1 0. -di -inv   \
   | nmrPipe -fn FT -alt -inv                 \
   | nmrPipe -fn ZF -zf 1 -inv                \
   | nmrPipe -fn EM -lb 0.5 -c 0.5 -inv       \
   | nmrPipe -fn LP -ord 8 -fb -verb          \
   #Now we do normal processing!              \ 
   | nmrPipe -fn SP -off 0.50 -pow 2 -c 0.50  \
   | nmrPipe -fn ZF -auto                     \
   | nmrPipe -fn FT -alt                      \
   | nmrPipe -fn PS -p0 0.0 -p1 0. -di        \
   | nmrPipe -fn POLY -auto                   \
   | nmrPipe -fn ZTP                          \
   | nmrPipe -fn ATP                          \
   | nmrPipe -fn ZTP                          \
   | pipe2xyz -out ./reconV2_lp/test%03d%03d.ist.ft4 -ov -verb 

#potentially write out a MASSIVE hyper-cube
echo 'writing out the hyper cube, could be massive'
xyz2pipe -in reconV2_lp/test%03d%03d.ist.ft4 | nmrPipe -ov -out testV2.ist.ft4 

echo 'making the projections'
proj4D.tcl -in  reconV2_lp/test%03d%03d.ist.ft4
