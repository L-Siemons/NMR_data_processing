#!/usr/bin/env python


d = '''

This function removes comments from proc.com files
it writes out a new proc.com file

note: it only removes lines where the first non space character 
is a '#'

'''
import argparse
import sys

parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter, description=d, epilog=" ")
parser.add_argument("-f", type=str, default='N/A',  help="proc.com file")
parser.add_argument("-o", type=str, default='proc_noComments.com', help="name of the output file")

args = parser.parse_args()

if args.f == 'N/A':
    print 'Please specify a proc.com file'
    sys.exit()

f = open(args.f, 'r')
o = open(args.o, 'w')

o.write('#!/bin/csh\n')
for i in f.readlines():
    split = i.split()
    check =True
    try:
        if split[0][0] == '#':
            if split[0][0] != '!':
                print 'removing comment: ', i.rstrip()
                check = False 
        if check == True:
            o.write(i)

    except IndexError:
        pass

o.close()
f.close()