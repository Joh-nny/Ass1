#!/usr/bin/perl -w

print "Enter a number: ";
$a = int(sys.stdin.readline()) ;
if ($a < 0 ) {
	print "negative\n";
}
elsif ($a == 0 ) {
	print "teste";
}
elsif ($a < 10 ) {
	print "small\n";
}
else {
	print "large\n";
}
