#!/opt/homebrew/bin/python3
import glob
import sys

depth = sys.argv[1]
pulse_seq_search = sys.argv[2]

depth = ''.join(['*/' for i in range(int(depth))])

print('looking in: ',  depth +'pulseprogram')
files = glob.glob(depth + 'pulseprogram')


for i in files:

	f = open(i)
	seq_name = f.readlines()[1].strip()
	f.close()

	if pulse_seq_search in seq_name:
		print(i+'\t'+seq_name)
