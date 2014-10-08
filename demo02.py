# Thiago de Oliveira Favero
# Assignment 1 - Demo 02 - 08/10/2014
# Source (adapted): http://www.tutorialspoint.com/python/python_nested_loops.htm

#!/usr/bin/python

i = 2
while(i < 100):
    j = 2
    while(j <= (i/j)):
        if not(i%j): break
        j = j + 1
    if (j > i/j) : print i
    i = i + 1

print "Good bye!"