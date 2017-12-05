#!/bin/csh

# This script is for processing hcc(co)nh experiment. 
# In this case the bruker sequence hccconhgpwg3d2
# was run with 955, 44, 156 points in each dimension
#
# This script is written up to demonstrate how to use linear prediction
# on multiple dimensions. In the 3D case we do the following:
# 1) process the X dimension
# 2) process the Z dimension in a 'gentle' window function
# 3) then we linear predict in the Y dimension 
# 4) importantly now we reverse the the processing carried out in step 2
# 5) then we do the linear prediction in the Z dimension and do 'proper' processing
# 6) so then in the end we want to process the dimension that decays the most first
#
# Note: remember as a rule of thumb you shouldn't have an LP order larger than 1/3 of 
# your real points.
#
# Author: Lucas Siemons
#

# since the phases are listed multiple times I have stored them as variables 

set phX0=0.0
set phX1=0.0

set phY0=0.0
set phY1=0.0

set phZ0=0.0
set phZ1=0.0

echo 'carrying out processing with LP. I may Take some time'

xyz2pipe -in fid/test%03d.fid -x -verb                        \
# Process the direct dimension (X: HN)                        \
      |   nmrPipe  -fn SOL                                    \
      |   nmrPipe  -fn SP -off 0.4  -end 0.98 -pow 2 -c .5    \
      |   nmrPipe  -fn ZF -auto                               \
      |   nmrPipe  -fn ZF -zf 1                               \
      |   nmrPipe  -fn FT                                     \
      |   nmrPipe  -fn PS -p0 $phX0 -p1 $phX1 -di             \
      |   nmrPipe  -fn EXT  -sw  -xn 5ppm -x1 11ppm           \
#     process the Z dimension (Z: aliphatic H)                \
      |   nmrPipe  -fn ZTP                                    \
      |   nmrPipe  -fn EM -lb 0.5 -c 0.5                      \
      |   nmrPipe  -fn ZF -zf 1                               \
      |   nmrPipe  -fn FT -alt                                \
      |   nmrPipe  -fn PS -p0 $phZ0 -p1 $phZ1 -di             \
      |   nmrPipe  -fn ZTP                                    \
#     now we do the linear prediction on Y (Y: N)             \
      |   nmrPipe  -fn TP                                     \
      |   nmrPipe  -fn LP -ord 8 -fb -verb                    \
      |   nmrPipe  -fn SP -off 0.5  -end 0.98 -pow 2 -c .5    \
      |   nmrPipe  -fn ZF -auto                               \
      |   nmrPipe  -fn FT -alt                                \
      |   nmrPipe  -fn PS -p0 $phY0 -p1 $phY1  -di            \
      |   nmrPipe  -fn TP                                     \
      |   pipe2xyz -out ft/test%03d.ft2 -x -ov                \

#now process the 3D cube                                      \


# now we need to undo the processing that we did in the       \
# third dim so that we can apply LP                           \
# hence we use the hilbert transform to regenerate the        \
# imaginary part                                              \
xyz2pipe -in ft/test%03d.ft2 -verb                            \
 | nmrPipe -fn ZTP                                            \
 | nmrPipe -fn HT -auto                                       \
 | nmrPipe -fn PS -p0 $phZ0 -p1 $phZ1 -inv                    \
 | nmrPipe -fn FT -alt -inv                                   \
 | nmrPipe -fn ZF -zf 1 -inv                                  \
 | nmrPipe -fn EM -lb 0.5 -c 0.5 -inv                         \
 | nmrPipe -fn LP -ord 15 -fb -verb                           \
# Normal processing of Z (Z:  aliphatic H )                   \
 | nmrPipe -fn SP -off 0.5  -end 0.98 -pow 2 -c .5            \
 | nmrPipe -fn ZF -auto                                       \
 | nmrPipe -fn FT -alt                                        \
 | nmrPipe -fn PS -p0 $phZ0 -p1 $phZ1 -di                     \
# next two lines swap dimensions 2 and 3                      \
 | nmrPipe -fn TP                                             \
 | nmrPipe -fn ZTP                                            \
 | pipe2xyz -out ft/test%03d.ft3 

# Here we write out the complete cube 
xyz2pipe -in ft/test%03d.ft3 | nmrPipe -ov -verb -out test_LP.ft3
# calculate the projections ... useful for phasing!
proj3D.tcl test.ft3
