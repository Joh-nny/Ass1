# Thiago de Oliveira Favero
# Assignment 1 - Demo 07 - 08/10/2014
# Source: http://www.cse.unsw.edu.au/~cs2041/14s2/assignments/python2perl/examples/3/prime1.py

#!/usr/bin/python

count = 0
for i in range(2, 100):
    k = i/2
    j = 2
    for j in range(2, k + 1):
        k = i % j
        if k == 0:
            count = count - 1
            break
        k = i/2
    count = count + 1
print count