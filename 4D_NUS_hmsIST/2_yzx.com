# This script places the data in a yzx format needed for the hmsIST reconstruction, 

# echo 'deleting ft1/ ... Hope nothing important was there!'
rm -r ft1/

# make planes for reconstruction
echo 'creating the yzx format'
nmrPipe -in ./data/testnus.ft1 \
  | nmrPipe -fn ZTP            \
  | nmrPipe -fn TP             \
  | pipe2xyz -out ./ft1/testnus%04d.ft1 
