#!/usr/bin/perl

while ($line = <>) {

	for $word (split(/\s/, $line)){

		print "$word\n";
	}
}