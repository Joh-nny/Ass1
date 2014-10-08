# Thiago de Oliveira Favero
# Assignment 1 - Demo 00 - 08/10/2014
# Source (adapted): http://code.activestate.com/recipes/578937-greatest-common-divisor/

#!/usr/bin/python

a = 120
b = 95
r=a

while r:
    r=a%b; a=b; b=r 
print a