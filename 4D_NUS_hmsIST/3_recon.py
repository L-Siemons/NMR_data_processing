from multiprocessing.dummy import Pool as ThreadPool 
import glob
import os
from tqdm import tqdm

'''
This program reconstructs the FIDs in parallel using the hmsIST binary
The only thing that needs to be changed are the config, spectrum details and 
the paths to the binaries and nuslist

In practice I have always run the reconstruction on a HPC server where each 
process in the pool was submitted as a separate job. The approach here 
can be used on NMRbox though!
'''




### config ###
cores = 7
names = glob.glob('ft1/testnus*.ft1')
iterations =  400

#spectrum details
yN = 92
zN = 92
aN = 128

#paths 
hmsIST = 'hmsIST_v211_64b'
nuslist = 'nuslist'

## functions ##

def recon(name):
    
    outName = name+'.phf'
    command = './%s -dim 3 -incr 1 -i_mult 0.98 -e_mult 0.98 ' % (hmsIST)
    size = '-xN %i -yN %i -zN %i ' % (yN, zN, aN)
    otheropetions = '-user 0 -itr %i -verb 0 -ref 0 -xc 1.0 -yc 1.0 -zc 0.5 -vlist %s' % (iterations, nuslist)
    fileIO = ' -in %s -out %s ' %(name, outName)

    total = command + size + otheropetions +fileIO
    #print total
    os.system(total)
    pbar.update(1)


#Here we do the work
pbar = tqdm(total=len(names))
pool = ThreadPool(cores) 
pool.map(recon, names)
pool.close()
pool.join()