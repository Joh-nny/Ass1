#!/usr/bin/perl

use List::MoreUtils qw(firstidx);

sub treat_print {
	my ($line, $expr) = @_;

	if ($line =~ /^\s*print\s*"(.*)"\s*$/ && $expr == 0) {
	
		# Python's print print a new-line character by default
		# so we need to add it explicitly to the Perl print statement
		print "print \"$1\\n\";\n";

	} elsif ($line =~ /^\s*print\s*"(.*)"\s*$/ && $expr == 1) {

		print "print \"$1\\n\"";

	} else {
		
		print "print ";
		$line =~ s/^\s*print\s*//g;
		treat_exp($line, 0);

		if ($expr == 0) {
			print ", \"\\n\";\n";
		} else {
			print ", \"\\n\"";
		}
	}
}

sub treat_if_while_sl {
	my ($line) = @_;

	if ($line =~ /.*if.*/) {

		print "if (";
		$line =~ s/^\s*if\s*//g;

	} else {

		print "while (";
		$line =~ s/^\s*while\s*//g;

	}

	treat_exp($line, 0);

	if ($line =~ /.*sys.stdout.write.*/) {
		$new_line = $line;
		$new_line =~ s/.*sys/sys/;
		treat_sys_write($new_line);
		print "}\n";
	} else {
		print ";\n}\n";
	}

}

sub treat_if_while_ml {
	my ($line, $count) = @_;

	#print ("HERE\n");

	$tabs = 0;

	foreach $key (sort keys %hash) {
		if ($key == $count) {
			last;
		}
		if ($key ne "") {
			$tabs++;
		}
	}

	for ($i = 0; $i < $tabs; $i++) {
		print "\t";
	}

	if ($line =~ /.*if.*/) {

		print "if (";
		$line =~ s/^\s*if\s*//g;

	} else {

		print "while (";
		$line =~ s/^\s*while\s*//g;

	}
	treat_exp($line, 1);
}

sub treat_sys_write {
	my ($line) = @_;

	$string = $line;
	$string =~ s/^\s*sys.stdout.write\("//;
	$string =~ s/^.*\K\"\).*\n$//;

	print "print \"$string\";\n";

	$new_line = $line;
	$new_line =~ s/.*\)//;
	$new_line =~ s/;\s*//;
	#print "new => $new_line\n";
	if ($new_line ne "") {
		print "\t";
		treat_exp($new_line, 0);
		print ";\n"
	}
}

sub treat_exp {
	my ($line, $option) = @_;

	for $word (split(/\s/, $line)) {

		#print "WORD => $word\n";

		if ($word ne "\s" && $word =~ /^\s*print.*/) {

			$print = $line;
			$new_line = $line;

			$print =~ s/.*print/print/;
			$print =~ s/print.*\K;.*//g;
			$new_line =~ s/.*;\s*//g;
			#$new_line =~ s/print.*\K.*\n//g;

			#print "print => $print\n";
			#print "new => $new_line\n";
			#print "line => $line\n";

			treat_print($print, 1);
			if ($new_line ne $line) {
				print ";\n\t";
				treat_exp($new_line);
			} 
			return;

		} elsif ($word ne "\s" && $word =~ /.*sys.stdout.write.*/) {
			return;

		} elsif ($word ne "\s" && $word =~ /^[a-zA-Z][a-zA-Z0-9_]*$/ && $word ne ("and" || "or" || "not") && $word ne ("break") && $word ne ("continue")) {
			
			print "\$$word ";
		
		} elsif ($word ne "\s" && $word =~ /^.*[\+\-\*\/\%\:\=\!\<\>\;\&\|\^\~].*$/) {
			
			$prev = $word;
			$post = $word;
			$op = $word;

			while ($post =~ /[\+\-\*\/\%\:\=\!\<\>\;\&\|\^\~]/) {
				
				$prev =~ s/[a-zA-Z0-9]*\K.*//g;
				if ($prev =~ /^[a-zA-Z][a-zA-Z0-9_]*$/) {
					$prev = '$'.$prev;
				}

				$post =~ s/[a-zA-Z0-9]*[\+\-\*\/\%\:\=\!\<\>\;\&\|\^\~]*//;
				$op =~ s/^[a-zA-Z0-9]*//;
				$op =~ s/[^\+\-\*\/\%\:\=\!\<\>\;\&\|\^\~]//g;

				if ($op eq "<>") {
					$op = "!=";
				}

				if ($op eq ":" && $option == 0) {
					print "$prev) {\n\t";
				} elsif ($op eq ":" && $option == 1) {
					print "$prev) {\n";
				} elsif ($op eq ";") {
					print "$prev;\n\t";
				} elsif ($op eq "~") {
					print "$op";
				} elsif ($prev eq "") {
					print "$op ";	
				} else {
					print "$prev $op ";
				}

				$prev = $post;
				$op = $post;
			}

			#print "post => $post\n";

			if ($post eq "break") {
				print "last ";
			} elsif ($post eq "continue") {
				print "next ";
			} elsif ($post =~ /^[a-zA-Z][a-zA-Z0-9_]*$/) {
				print "\$$post ";
			} elsif ($post ne ""){
				print "$post ";
			}
		
		} elsif ($word ne "") {

			if ($word eq "break") {
				print "last ";
			} elsif ($word eq "continue") {
				print "next ";
			} else {
				print "$word ";
			}
		}
	}
}

$count = 0;
$last_count = 0;

while ($line = <>) {

	if ($line =~ /^#!/ && $. == 1) {
	
		# translate #! line 
		print "#!/usr/bin/perl -w\n";

	} elsif ($line =~ /^\s*#/ || $line =~ /^\s*$/) {
	
		# Blank & comment lines can be passed unchanged
		print $line;

	} else {

		$line =~ /^(\s*)/;
		$count = length($1);

		#foreach $value (@spaces) {
		#	print "value => $value\n";
		#}

		#print "last => $last_count\n";
		#print "count => $count\n";

		if ($count < $last_count) {

			#print "count => $count\n";

			foreach $key (sort {$b <=> $a} keys %hash) {

				$tabs = 0;

				#print "key out => $key\n";
				if ($hash{$key} eq "false") {

					foreach $key2 (sort keys %hash) {
						#print "key in => $key2\n";
						if ($key2 == $key) {
							last;
						}
						if ($key2 ne "") {
							$tabs++;
						}
					}

					for ($i = 0; $i < $tabs; $i++) {
						print "\t";
					}
					print "}\n";
					$hash{$key} = "true";

					if ($key == $count) {
						last;
					}
				}
			}
		}

		if ($line =~ /^\s*print.*/) {
		
			$tabs = 0;

			foreach $key (sort keys %hash) {
				if ($key == $count) {
					last;
				}
				if ($key ne "") {
					$tabs++;
				}
			}

			for ($i = 0; $i < $tabs; $i++) {
				print "\t";
			}

			treat_print($line, 0);

		#} elsif ($line =~ /^\s*if.*\:.+$/) {

		#	treat_if_sl($line);

		#} elsif ($line =~ /^\s*while.*:.+/) {

		#	treat_while_sl($line);

		} elsif ($line =~ /^\s*if.*\:.+/ || $line =~ /^\s*while.*\:.+/) {

			#$index = firstidx {$_ eq $count} @spaces;

			#print "index => $index\n";

			treat_if_while_sl($line);

		} elsif ($line =~ /^\s*if.*\:$/ || $line =~ /^\s*while.*\:$/) {

			#print "count => $count\n";

			if (!exists($hash{$count}) || (exists($hash{$count}) && $hash{$count} eq "true")) {

				$hash{$count} = "false";

			}

			treat_if_while_ml($line, $count);

		} elsif ($line =~ /^\s*[a-zA-Z][a-zA-Z0-9_]*\s*=.*$/) {
	  	
	  		#print "count => $count\n";
	  		
	  		$tabs = 0;

			foreach $key (sort keys %hash) {
				#print "key => $key\n";
				if ($key == $count) {
					last;
				}
				if ($key ne "") {
					$tabs++;
				}
			}

			for ($i = 0; $i < $tabs; $i++) {
				print "\t";
			}

	  		treat_exp($line, 0);
	  		print ";\n";

	  	} elsif ($line =~ /^\s*break\s*$/) {

	  		$tabs = 0;

			foreach $key (sort keys %hash) {
				if ($key == $count) {
					last;
				}
				if ($key ne "") {
					$tabs++;
				}
			}

			for ($i = 0; $i < $tabs; $i++) {
				print "\t";
			}

			print "last;\n";

		} elsif ($line =~ /^\s*continue\s*$/) {

	  		$tabs = 0;

			foreach $key (sort keys %hash) {
				if ($key == $count) {
					last;
				}
				if ($key ne "") {
					$tabs++;
				}
			}

			for ($i = 0; $i < $tabs; $i++) {
				print "\t";
			}

			print "next;\n";

		} elsif ($line =~ /^\s*sys.stdout.write\(".*"\)\s*$/) {

			$tabs = 0;

			foreach $key (sort keys %hash) {
				if ($key == $count) {
					last;
				}
				if ($key ne "") {
					$tabs++;
				}
			}

			for ($i = 0; $i < $tabs; $i++) {
				print "\t";
			}

			treat_sys_write($line);
	
		} else {
	
			# Lines we can't translate are turned into comments
			print "#$line\n";

		}
	}
	#print "last => $last_count\n";
	#print "count => $count\n";
	$last_count = $count;
}

foreach $key (sort {$b <=> $a} keys %hash) {

	$tabs = 0;

	#print "key out => $key\n";
	if ($hash{$key} eq "false") {

		foreach $key2 (sort keys %hash) {
			#print "key in => $key2\n";
			if ($key2 == $key) {
				last;
			}
			if ($key2 ne "") {
				$tabs++;
			}
		}

		for ($i = 0; $i < $tabs; $i++) {
			print "\t";
		}
		print "}\n";
	}
}
