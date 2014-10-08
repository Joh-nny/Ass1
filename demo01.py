# Thiago de Oliveira Favero
# Assignment 1 - Demo 01 - 08/10/2014
# Source: http://www.tutorialspoint.com/python/nested_if_statements_in_python.htm

#!/usr/bin/python

var = 100
if var < 200:
   print "Expression value is less than 200"
   if var == 150:
      print "Which is 150"
   elif var == 100:
      print "Which is 100"
   elif var == 50:
      print "Which is 50"
elif var < 50:
   print "Expression value is less than 50"
else:
   print "Could not find true expression"

print "Good bye!"