#!/usr/bin/perl -w


$number = 0 ;
$blah = "> ";
while ($number >= 0 ) {
	print $blah;
	$number = <STDIN>;
	if ($number >= 0 ) {
		if ($number % 2 == 0 ) {
			print "Even\n";
		}
		else {
			print "Odd\n";
		}
	}
}
print "Bye\n";

