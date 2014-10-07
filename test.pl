#!/usr/bin/perl -w

$answer = 41 ;
$blah = 2 ;
if ($answer > 0) {
	$blah = $blah + 2;
	$answer = $answer + $blah ;
}
if ($answer == 43 and $blah == 2) {
	$answer = $answer - 1 ;
}
print $answer , "\n";
