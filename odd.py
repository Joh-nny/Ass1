#!/usr/bin/python
import sys

number = 0
blah = "> "
while number >= 0:
    sys.stdout.write(blah)
    number = int(sys.stdin.readline())
    if number >= 0:
        if number % 2 == 0:
            print  "Even"
        else:
            print "Odd"
print "Bye"

