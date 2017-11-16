#!/bin/csh

# In this experiment we had some issues with the base line. 
# In order to tackle this we used a weaker solvent filter 
# |   nmrPipe  -fn POLY -time -auto \
#
# Instead of the stronger filter 
# |   nmrPipe  -fn SOL \
#
# this is an important consideration if you then 
# have a baseline correction later on. 


xyz2pipe -in fid/test%03d.fid -x -verb                   \
      |   nmrPipe  -fn POLY -time -auto \
      |   nmrPipe  -fn SP -off 0.4  -end 0.98 -pow 2 -c .5    \
      |   nmrPipe  -fn ZF -auto                               \
      |   nmrPipe  -fn FT                              \
      |   nmrPipe  -fn PS -p0 197.2 -p1 205 -di               \
      |   nmrPipe  -fn EXT  -sw  -xn 5.5ppm -x1 14ppm                     \
      |   nmrPipe  -fn TP                                     \
      |   nmrPipe  -fn SP -off 0.5  -end 0.98 -pow 2 -c .5    \
      |   nmrPipe  -fn ZF -auto                               \
      |   nmrPipe  -fn FT                                \
      |   nmrPipe  -fn PS -p0 90 -p1 0  -di               \
      |   nmrPipe  -fn TP                                     \
      |   pipe2xyz -out ft/test%03d.ft2 -x -ov              \


xyz2pipe -in ft/test%03d.ft2  -z -verb                     \
     |   nmrPipe -fn SP -off 0.5 -end 0.98 -pow 2 -c .5   \
     |   nmrPipe -fn ZF -auto                              \
     |   nmrPipe -fn FT -alt                             \
     |   nmrPipe -fn PS -p0 0. -p1 0 -di                 \
     |   nmrPipe -fn ZTP                                 \
     |   nmrPipe -POLY  -auto                                \
     |   pipe2xyz -out ft/test%03d.ft3  -z

xyz2pipe -in ft/test%03d.ft3 | nmrPipe -ov -verb -out test.ft3
proj3D.tcl test.ft3

