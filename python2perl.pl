#!/usr/bin/perl

sub print_tabs {
	my ($count, $tabs) = @_;

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
}

sub close_braces {
	my ($count) = @_;

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

sub treat_print {
	my ($line, $expr) = @_;

	if ($line =~ /^\s*print\s*$/) {
		
		print "print \"\\n\";\n"
	
	} elsif ($line =~ /^\s*print\s*"(.*)"\s*$/ && $expr == 0) {
	
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

sub treat_if_while_for_sl {
	my ($line, $count) = @_;

	$new_line = $line;
	$original_line = $line;

	if ($line =~ /.*elif.*/) {

		print "elsif (";
		$line =~ s/^\s*elif\s*\(*//g;
		$line =~ s/.*\K\)*\:.*//g;

		treat_exp($line, 0, 0, 0);
		print ") {\n";

	} elsif ($line =~ /.*if.*/) {

		print "if (";
		$line =~ s/^\s*if\s*\(*//g;
		$line =~ s/.*\K\)*\:.*//g;

		treat_exp($line, 0, 0, 0);
		print ") {\n";

	} elsif ($line =~ /.*else.*/) {

		print "else {\n";

	} elsif ($line =~ /.*while.*/) {

		print "while (";
		$line =~ s/^\s*while\s*\(*//g;
		$line =~ s/.*\K\)*\:.*//g;

		treat_exp($line, 0, 0, 0);
		print ") {\n";

	} else {

		$variable = $line;
		$variable =~ s/\s*for\s//;
		$variable =~ s/^[a-zA-Z][a-zA-Z0-9_]*\K.*\n$//;

		$param = $line;
		$param =~ s/.*in\s//;

		#print "param => $param\n";

		if ($param =~ /range.*/) {
			$arg = $param;
			$arg =~ s/.*\(//;
			$arg =~ s/.*\K\).*//;

			if ($arg =~ /\,/) {
				$start = $arg;
				$start =~ s/[0-9]+\K\,.*\n$//;
			
				$finish = $arg;
				$finish =~ s/.*\,\s*//;
				if ($finish =~ /^[0-9]+$/) {
					$finish--;
					print "foreach \$$variable ($start..$finish) {\n";
				} else {
					print "foreach \$$variable ($start..";
					treat_exp($finish, 0, 0, 0);
					print "- 1) {\n";
				}
		
			} else {
				$finish = $arg;
				$finish =~ s/.*\K\n$//;
				if ($finish =~ /^[0-9]+$/) {
					$finish--;
					print "foreach \$$variable (0..$finish) {\n";
				} else {
					print "foreach \$$variable (0..";
					treat_exp($finish, 0, 0, 0);
					print "- 1) {\n";
				}
			}
		} else {
			$arg = $param;
			$arg =~ s/\"//;
			$arg =~ s/.*\K\".*\n$//;

			print "foreach \$$variable (split \/\/\, \"$arg\") {\n";
		}
	}

	$new_line =~ s/.*\:\s*//;

	#print "new => $new_line\n";

	treat_exp($new_line, 0, $count, 1);

	print ";\n";

	print_tabs($count, 0);

	print "}\n";

	#print "$count => $hash{$count}\n";

	$hash{$count} = "true";

	#if ($line =~ /.*sys.stdout.write.*/) {
	#	$new_line = $line;
	#	$new_line =~ s/.*sys/sys/;
	#	treat_sys_write($new_line);
	#	print "}\n";
	#} else {
	#	print ";\n}\n";
	#}

}

sub treat_if_while_for_ml {
	my ($line) = @_;

	#print ("HERE\n");

	if ($line =~ /.*elif.*/) {

		print "elsif (";
		$line =~ s/^\s*elif\s*\(*//;
		$line =~ s/.*\K\)+\:$//;
		$line =~ s/.*\K\:$//;

		treat_exp($line, 1, 0, 0);
		print ") {\n";

	} elsif ($line =~ /.*if.*/) {

		print "if (";
		$line =~ s/^\s*if\s*\(*//g;
		$line =~ s/.*\K\)+\:$//g;
		$line =~ s/.*\K\:$//g;

		#print "=> $line\n";

		treat_exp($line, 1, 0, 0);
		print ") {\n";

	} elsif ($line =~ /.*else.*/) {

		print "else {\n";

	} elsif ($line =~ /.*while.*/) {

		print "while (";
		$line =~ s/^\s*while\s*\(*//g;
		$line =~ s/.*\K\)*\:$//g;

		treat_exp($line, 1, 0, 0);
		print ") {\n";
	
	} else {

		$variable = $line;
		$variable =~ s/\s*for\s//;
		$variable =~ s/^[a-zA-Z][a-zA-Z0-9_]*\K.*\n$//;

		$param = $line;
		$param =~ s/.*in\s//;

		#print "param => $param\n";

		if ($param =~ /range.*/) {
			$arg = $param;
			$arg =~ s/.*\(//;
			$arg =~ s/.*\K\).*//;

			if ($arg =~ /\,/) {
				$start = $arg;
				$start =~ s/[0-9]+\K\,.*\n$//;
			
				$finish = $arg;
				$finish =~ s/.*\,\s*//;
				if ($finish =~ /^[0-9]+$/) {
					$finish--;
					print "foreach \$$variable ($start..$finish) {\n";
				} else {
					print "foreach \$$variable ($start..";
					treat_exp($finish, 0, 0, 0);
					print "- 1) {\n";
				}
		
			} else {
				$finish = $arg;
				$finish =~ s/.*\K\n$//;
				if ($finish =~ /^[0-9]+$/) {
					$finish--;
					print "foreach \$$variable (0..$finish) {\n";
				} else {
					print "foreach \$$variable (0..";
					treat_exp($finish, 0, 0, 0);
					print "- 1) {\n";
				}
			}
		} else {
			$arg = $param;
			$arg =~ s/\"//;
			$arg =~ s/.*\K\".*\n$//;

			print "foreach \$$variable (split \/\/\, \"$arg\") {\n";
		}
	}
}

sub treat_sys_write {
	my ($line, $count) = @_;

	$string = $line;

	if ($string =~ /"/) {
		$string =~ s/^\s*sys.stdout.write\(\s*"//;
		$string =~ s/^.*\K\"\).*\n$//;

		print "print \"$string\"";
	
	} else {

		$string =~ s/^\s*sys.stdout.write\(\s*//;
		$string =~ s/^.*\K\).*\n*$//;

		print "print \$$string";
	}
}

sub treat_exp {
	my ($line, $option, $count, $tabs) = @_;

	print_tabs($count, $tabs);

	if ($line =~ /sys.stdout.write/) {
		treat_sys_write($line, $count);

		$new_line = $line;
		$new_line =~ s/.*\)//;
		$new_line =~ s/\;*\s*\n*//;
		#print "new => $new_line\n";
		if ($new_line ne "") {
			print ";\n";
			treat_exp($new_line, 0, $count, 1);
		}
		return;
	
	} elsif ($line =~ /^\s*[a-zA-Z][a-zA-Z0-9_]*\s*=\s*".*"\s*$/) {

		$variable = $line;
		$variable =~ s/^\s*//;
		$variable =~ s/[a-zA-Z][a-zA-Z0-9_]*\K.*\n*$//;

		@string = split (/"/, $line);

		print "\$$variable = \"@string[1]\"";
		return;
	}

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
				treat_exp($new_line, $option, $count, $tabs);
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

	} elsif ($line =~ /^\s*import.*/) {

		print "\n";

	} else {

		$line =~ /^(\s*)/;
		$count = length($1);

		#print "last => $last_count\n";
		#print "count => $count\n";

		if ($count < $last_count && $hash{$count} eq "false") {

			#print "count => $count\n";
			close_braces($count);
			
		}

		if ($line =~ /^\s*print.*/) {

			print_tabs($count, 0);

			treat_print($line, 0);

		} elsif ($line =~ /^\s*elif.*\:.+/ || $line =~ /^\s*if.*\:.+/ || $line =~ /^\s*else.*\:.+/ || $line =~ /^\s*while.*\:.+/ || $line =~ /^\s*for.*\:.+/) {

			if (!exists($hash{$count}) || (exists($hash{$count}) && $hash{$count} eq "true")) {

				$hash{$count} = "false";

			}

			print_tabs($count, 0);

			treat_if_while_for_sl($line, $count);

		} elsif ($line =~ /^\s*elif.*\:$/ || $line =~ /^\s*if.*\:$/ || $line =~ /^\s*else.*\:$/ || $line =~ /^\s*while.*\:$/ || $line =~ /^\s*for.*\:$/) {

			#print "count => $count\n";

			if (!exists($hash{$count}) || (exists($hash{$count}) && $hash{$count} eq "true")) {

				$hash{$count} = "false";

			}

			print_tabs($count, 0);

			treat_if_while_for_ml($line);

		} elsif ($line =~ /^\s*[a-zA-Z][a-zA-Z0-9_]*\s*=.*$/) {
	  	
	  		#print "count => $count\n";
	  		print_tabs($count, 0);

	  		treat_exp($line, 0);
	  		print ";\n";

	  	} elsif ($line =~ /^\s*break\s*$/) {

	  		print_tabs($count, 0);
			print "last;\n";

		} elsif ($line =~ /^\s*continue\s*$/) {

			print_tabs($count, 0);
			print "next;\n";

		} elsif ($line =~ /^\s*sys.stdout.write\(.*\)\s*$/) {

			print_tabs($count, 0);
			treat_sys_write($line);
			print ";\n";

		} else {
	
			# Lines we can't translate are turned into comments
			print "#$line\n";

		}
	}
	#print "last => $last_count\n";
	#print "count => $count\n";
	$last_count = $count;
}

close_braces(0);
