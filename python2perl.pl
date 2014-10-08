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

		if ($hash{$key} eq "false") {

			foreach $key2 (sort keys %hash) {

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
		
		print "print \"\\n\""
	
	} elsif ($line =~ /^\s*print\s*"(.*)"\s*$/) {
	
		# Python's print print a new-line character by default
		# so we need to add it explicitly to the Perl print statement
		print "print \"$1\\n\"";

	} else {
		
		print "print ";
		$line =~ s/^\s*print\s*//;
		treat_exp($line, 0);

		print ", \"\\n\"";
	}
}

sub treat_if_while_for_sl {
	my ($line, $count) = @_;

	$new = $line;

	if ($line =~ /.*elif.*/) {

		print "elsif (";
		$line =~ s/^\s*elif\s*//;
		$line =~ s/([^\:]*)\K:.*//;

		treat_exp($line, 0, 0, 0);
		print ") {\n";

	} elsif ($line =~ /.*if.*/) {

		print "if (";
		$line =~ s/^\s*if\s*//;
		$line =~ s/([^\:]*)\K:.*//;

		treat_exp($line, 0, 0, 0);
		print ") {\n";

	} elsif ($line =~ /.*else.*/) {

		print "else {\n";

	} elsif ($line =~ /.*while.*/) {

		print "while (";
		$line =~ s/^\s*while\s*//;
		$line =~ s/([^\:]*)\K:.*//;

		treat_exp($line, 0, 0, 0);
		print ") {\n";

	} else {

		$variable = $line;
		$variable =~ s/\s*for\s//;
		$variable =~ s/^[a-zA-Z][a-zA-Z0-9_]*\K.*\n$//;

		$param = $line;
		$param =~ s/.*in\s//;

		if ($param =~ /range.*/) {
			$arg = $param;
			$arg =~ s/[^\(]*\(//;
			$arg =~ s/[^\)]*\K\):.*//;

			if ($arg =~ /\,/) {
				$start = $arg;
				$start =~ s/[^\,]*\K\,.*\n$//;
			
				$finish = $arg;
				$finish =~ s/[^\,]*\,\s*//;

				if ($start =~ /^[0-9]+$/) {
					print "foreach \$$variable ($start..";
				} else {
					print "foreach \$$variable (";
					treat_exp($start, 0, 0, 0);
					print "..";
				}

				if ($finish =~ /^[0-9]+$/) {
					$finish--;
					print "$finish) {\n";
				} else {
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

	$new =~ s/[^\:]*\:\s*//;

	treat_exp($new, 0, $count, 1);

	print ";\n";

	print_tabs($count, 0);

	print "}\n";

	$hash{$count} = "true";

}

sub treat_if_while_for_ml {
	my ($line) = @_;

	if ($line =~ /.*elif.*/) {

		print "elsif (";
		$line =~ s/^\s*elif\s*//;
		$line =~ s/([^\:]*)\K:$//;

		treat_exp($line, 1, 0, 0);
		print ") {\n";

	} elsif ($line =~ /.*if.*/) {

		print "if (";
		$line =~ s/^\s*if\s*//;
		$line =~ s/([^\:]*)\K:$//;

		treat_exp($line, 1, 0, 0);
		print ") {\n";

	} elsif ($line =~ /.*else.*/) {

		print "else {\n";

	} elsif ($line =~ /.*while.*/) {

		print "while (";
		$line =~ s/^\s*while\s*//;
		$line =~ s/([^\:]*)\K:$//;

		treat_exp($line, 1, 0, 0);
		print ") {\n";
	
	} else {

		$variable = $line;
		$variable =~ s/\s*for\s//;
		$variable =~ s/^[a-zA-Z][a-zA-Z0-9_]*\K.*\n$//;

		$param = $line;
		$param =~ s/.*in\s//;

		if ($param =~ /range.*/) {
			$arg = $param;
			$arg =~ s/[^\(]*\(//;
			$arg =~ s/[^\)]*\K\):.*//;

			if ($arg =~ /\,/) {
				$start = $arg;
				$start =~ s/[^\,]*\K\,.*\n$//;
			
				$finish = $arg;
				$finish =~ s/[^\,]*\,\s*//;

				if ($start =~ /^[0-9]+$/) {
					print "foreach \$$variable ($start..";
				} else {
					print "foreach \$$variable (";
					treat_exp($start, 0, 0, 0);
					print "..";
				}

				if ($finish =~ /^[0-9]+$/) {
					$finish--;
					print "$finish) {\n";
				} else {
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
		$string =~ s/[^\"]*\K\".*\n*$//;

		print "print \"$string\"";
	
	} else {

		$string =~ s/^\s*sys.stdout.write\(\s*//;
		$string =~ s/[^\)]*\K\).*\n*$//;

		print "print \$$string";
	}
}

sub treat_sys_read {
	my ($line, $count) = @_;

	$new_line = $line;
	$new_line =~ s/^.*\Ksys.stdin.readline.*\n*$//;

	if ($new_line ne ""){
		treat_exp($new_line, 0, $count, 0);
	}

	print "<STDIN>";
}

sub treat_int {
	my ($line, $count) = @_;

	$new_line = $line;
	$new_line =~ s/^.*\Kint.*\n*$//;

	treat_exp($new_line, 0, $count, 0);

	$param = $line;
	$param =~ s/^.*int\(//;
	$param =~ s/[^\)]*\K\).*\n*$//;

	if ($param =~ /sys.stdin.readline/) {
		treat_sys_read($param, $count);
	
	} elsif ($param eq "") {
		print "0";
	
	} else {
		
		if ($param =~ /^".*"$/) {
			@param = split(/"/, $param);
			$integer = int(@param[1]);
		} else {
			$integer = int($param);
		}
		print "$integer";
	} 
}

sub treat_exp {
	my ($line, $option, $count, $tabs) = @_;

	print_tabs($count, $tabs);

	if ($line =~ /^\s*print.*/) {
		
		treat_print($line);
		return;

	} elsif ($line =~ /sys.stdout.write/) {
		treat_sys_write($line, $count);

		#$new_line = $line;
		#$new_line =~ s/.*\)//;
		#$new_line =~ s/\;*\s*\n*//;
		#print "new => $new_line\n";
		#if ($new_line ne "") {
	#		print ";\n";
		#	treat_exp($new_line, 0, $count, 1);
		#}
		return;
	
	} elsif ($line =~ /^\s*[a-zA-Z][a-zA-Z0-9_]*\s*=\s*".*"\s*$/) {

		$variable = $line;
		$variable =~ s/^\s*//;
		$variable =~ s/[a-zA-Z][a-zA-Z0-9_]*\K.*\n*$//;

		@string = split (/"/, $line);

		print "\$$variable = \"@string[1]\"";
		return;

	} elsif ($line =~ /int(.*)/) {

		treat_int($line, $count);
		return;
	
	} elsif ($line =~ /sys.stdin.readline/) {

		treat_sys_read($line, $count);
		return;

	}

	for $word (split(/\s/, $line)) {

		if ($word ne "\s" && $word =~ /^[a-zA-Z][a-zA-Z0-9_]*$/ && $word ne ("and" || "or" || "not") && $word ne ("break") && $word ne ("continue")) {
			
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

		if ($count < $last_count && $hash{$count} eq "false") {

			close_braces($count);
			
		}

		if ($line =~ /^\s*print.*/) {

			print_tabs($count, 0);

			treat_print($line);

			print ";\n";

		} elsif ($line =~ /^\s*elif.*\:.+/ || $line =~ /^\s*if.*\:.+/ || $line =~ /^\s*else.*\:.+/ || $line =~ /^\s*while.*\:.+/ || $line =~ /^\s*for.*\:.+/) {

			if (!exists($hash{$count}) || (exists($hash{$count}) && $hash{$count} eq "true")) {

				$hash{$count} = "false";

			}

			print_tabs($count, 0);

			treat_if_while_for_sl($line, $count);

		} elsif ($line =~ /^\s*elif.*\:$/ || $line =~ /^\s*if.*\:$/ || $line =~ /^\s*else.*\:$/ || $line =~ /^\s*while.*\:$/ || $line =~ /^\s*for.*\:$/) {

			if (!exists($hash{$count}) || (exists($hash{$count}) && $hash{$count} eq "true")) {

				$hash{$count} = "false";

			}

			print_tabs($count, 0);

			treat_if_while_for_ml($line);

		} elsif ($line =~ /int(.*)/) {

			treat_int($line, $count);
			print ";\n";

		} elsif ($line =~ /sys.stdin.readline/) {

			treat_sys_read($line, $count);
			print ";\n";

		} elsif ($line =~ /^\s*[a-zA-Z][a-zA-Z0-9_]*\s*=.*$/) {
	  	
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
	$last_count = $count;
}

close_braces(0);
