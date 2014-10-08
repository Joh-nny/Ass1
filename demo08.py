# Thiago de Oliveira Favero
# Assignment 1 - Demo 08 - 08/10/2014
# Source (adapted): http://www.cse.unsw.edu.au/~cs2041/14s2/assignments/python2perl/examples/3/odd.py

#!/usr/bin/python
import sys

number = 0
string = "> "
while number >= 0:
    sys.stdout.write(string)
    number = int(sys.stdin.readline())
    if number >= 0:
        if number % 2 == 0:
            print  "Even"
        else:
            print "Odd"
print "Bye"