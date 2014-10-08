# Thiago de Oliveira Favero
# COMP2041 - Assignment 1
# 08/10/2014

#!/usr/bin/perl

# Function: print_tabs
# Objective: make the correct indentation of the program
sub print_tabs {
	my ($count, $tabs) = @_;

	# Search in the sorted hash for the key that matches the number of spaces of the current line. 
	# For each key that doesn't match a tab must be printed
	foreach my $key (sort keys %hash) {
		if ($key == $count) {
			last;
		}
		if ($key ne "") {
			$tabs++;
		}
	}

	# Print the correct number of tabs
	for (my $i = 0; $i < $tabs; $i++) {
		print "\t";
	}
}

# Function: close_braces
# Objective: close the correct braces of ifs, whiles and fors
sub close_braces {
	my ($count) = @_;

	# Loop through the reversed order of hash
	foreach my $key (sort {$b <=> $a} keys %hash) {

		my $tabs = 0;

		# If the current brace is open
		if ($hash{$key} eq "false") {

			# Loop through the ordered hash until find the current key in reversed order
			foreach my $key2 (sort keys %hash) {

				if ($key2 == $key) {
					last;
				}
				if ($key2 ne "") {
					$tabs++;
				}
			}

			# Print the tabs, close the brace and mark it as closed
			for (my $i = 0; $i < $tabs; $i++) {
				print "\t";
			}

			print "}\n";
			$hash{$key} = "true";

			# Exits when all the braces that must be closed are closed
			if ($key == $count) {
				last;
			}
		}
	}
}

# Function: treat_print
# Objective: deal with the print cases
sub treat_print {
	my ($line, $expr) = @_;

	# Print without parameters
	if ($line =~ /^\s*print\s*$/) {
		
		print "print \"\\n\""
	
	# Print with string
	} elsif ($line =~ /^\s*print\s*"(.*)"\s*$/) {
	
		# Python's print print a new-line character by default
		# so we need to add it explicitly to the Perl print statement
		print "print \"$1\\n\"";

	# Print with string and variable
	} elsif ($line =~ /^\s*print\s*"(.*)"\s*,.*$/) {

		my @string = split (/"/, $line);
		my $variable = $line;
		$variable =~ s/[^\,]*\,\s*//;
		$variable =~ s/\n$//;

		print "print \"@string[1] \$$variable\\n\""; 

	# Print with variables/expressions
	} else {
		
		print "print ";
		$line =~ s/^\s*print\s*//;
		treat_exp($line, 0);

		print ", \"\\n\"";
	}
}

# Function: treat_if_while_for_sl
# Objective: deal with the single-lines ifs, whiles and fors 
sub treat_if_while_for_sl {
	my ($line, $count) = @_;

	my $new = $line;

	# elif case
	if ($line =~ /.*elif.*/) {

		# print the correspondent perl command and treat the arguments
		print "elsif (";
		$line =~ s/^\s*elif\s*//;
		$line =~ s/([^\:]*)\K:.*//;

		treat_exp($line, 0, 0, 0);
		print ") {\n";

	# if case
	} elsif ($line =~ /.*if.*/) {

		print "if (";
		$line =~ s/^\s*if\s*//;
		$line =~ s/([^\:]*)\K:.*//;

		treat_exp($line, 0, 0, 0);
		print ") {\n";

	# else case
	} elsif ($line =~ /.*else.*/) {

		print "else {\n";

	# while case
	} elsif ($line =~ /.*while.*/) {

		print "while (";
		$line =~ s/^\s*while\s*//;
		$line =~ s/([^\:]*)\K:.*//;

		treat_exp($line, 0, 0, 0);
		print ") {\n";

	# for case
	} else {

		# separates the for variable and parameters
		my $variable = $line;
		$variable =~ s/\s*for\s//;
		$variable =~ s/^[a-zA-Z][a-zA-Z0-9_]*\K.*\n$//;

		my $param = $line;
		$param =~ s/.*in\s//;

		# if the parameter contains the range function
		if ($param =~ /range.*/) {
			
			# separates the arguments of the function
			my $arg = $param;
			$arg =~ s/[^\(]*\(//;
			$arg =~ s/[^\)]*\K\):.*//;

			# checks if the range contains one or two arguments
			if ($arg =~ /\,/) {

				# separates the first and second argument
				my $start = $arg;
				$start =~ s/[^\,]*\K\,.*\n$//;
			
				my $finish = $arg;
				$finish =~ s/[^\,]*\,\s*//;

				# check if the first argument is a number or a expression
				if ($start =~ /^[0-9]+$/) {
					print "foreach \$$variable ($start..";
				} else {
					print "foreach \$$variable (";
					treat_exp($start, 0, 0, 0);
					print "..";
				}

				# check if the second argument is a number or an expression
				if ($finish =~ /^[0-9]+$/) {
					$finish--;
					print "$finish) {\n";
				} else {
					treat_exp($finish, 0, 0, 0);
					print "- 1) {\n";
				}
		
			# range with only one argument
			} else {

				my $finish = $arg;
				$finish =~ s/.*\K\n$//;

				# checks if the argument is a number or an expression
				if ($finish =~ /^[0-9]+$/) {
					$finish--;
					print "foreach \$$variable (0..$finish) {\n";
				} else {
					print "foreach \$$variable (0..";
					treat_exp($finish, 0, 0, 0);
					print "- 1) {\n";
				}
			}

		# for parameter is a string
		} else {

			# use the split function to loop through each character of the string
			my $arg = $param;
			$arg =~ s/\"//;
			$arg =~ s/.*\K\".*\n$//;

			print "foreach \$$variable (split \/\/\, \"$arg\") {\n";
		}
	}

	# isolate the expressions after the ':' and treat then 
	$new =~ s/[^\:]*\:\s*//;

	treat_exp($new, 0, $count, 1);

	print ";\n";

	print_tabs($count, 0);

	print "}\n";

	# mark the brace as closed
	$hash{$count} = "true";
}

# Function: treat_if_while_for_ml
# Objective: deal with the multi-lines ifs, whiles and fors 
sub treat_if_while_for_ml {
	my ($line) = @_;

	# The function is almost identical of treat_if_while_for_sl function except that 
	# doesn't contains the last part where the expressions after the ':' are treated  

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

		my $variable = $line;
		$variable =~ s/\s*for\s//;
		$variable =~ s/^[a-zA-Z][a-zA-Z0-9_]*\K.*\n$//;

		my $param = $line;
		$param =~ s/.*in\s//;

		if ($param =~ /range.*/) {
			my $arg = $param;
			$arg =~ s/[^\(]*\(//;
			$arg =~ s/[^\)]*\K\):.*//;

			if ($arg =~ /\,/) {
				my $start = $arg;
				$start =~ s/[^\,]*\K\,.*\n$//;
			
				my $finish = $arg;
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
			my $arg = $param;
			$arg =~ s/\"//;
			$arg =~ s/.*\K\".*\n$//;

			print "foreach \$$variable (split \/\/\, \"$arg\") {\n";
		}
	}
}

# Function: treat_sys_write
# Objective: deal with the sys.stdout.write function
sub treat_sys_write {
	my ($line, $count) = @_;

	my $string = $line;

	# checks if the argument of the function is a quoted string
	if ($string =~ /"/) {

		# isolate and print the string
		$string =~ s/^\s*sys.stdout.write\(\s*"//;
		$string =~ s/[^\"]*\K\".*\n*$//;

		print "print \"$string\"";
	
	# argument is a variable that contains a string
	} else {

		$string =~ s/^\s*sys.stdout.write\(\s*//;
		$string =~ s/[^\)]*\K\).*\n*$//;

		print "print \$$string";
	}
}

# Function: treat_sys_read
# Objective: deal with the sys.stdin.readline function
sub treat_sys_read {
	my ($line, $count) = @_;

	# isolate the expression before the function and treat it if it exists
	my $new_line = $line;
	$new_line =~ s/^.*\Ksys.stdin.readline.*\n*$//;

	if ($new_line ne ""){
		treat_exp($new_line, 0, $count, 0);
	}

	print "<STDIN>";
}

# Function: treat_int
# Objective: deal with the int function
sub treat_int {
	my ($line, $count) = @_;

	# isolate the expression before the function and treat it if it exists
	my $new_line = $line;
	$new_line =~ s/^.*\Kint.*\n*$//;

	treat_exp($new_line, 0, $count, 0);

	# isolate the parameters of the function
	my $param = $line;
	$param =~ s/^.*int\(//;
	$param =~ s/[^\)]*\K\).*\n*$//;

	# check if the parameter is the function sys.stdin.readline
	if ($param =~ /sys.stdin.readline/) {
		treat_sys_read($param, $count);
	
	# check if the parameter is empty
	} elsif ($param eq "") {
		print "0";
	
	# parameter is an integer or a string
	} else {
		
		# check if the parameter is a string
		if ($param =~ /^".*"$/) {
			my @param = split(/"/, $param);
			my $integer = int(@param[1]);

		# parameter is an integer
		} else {
			my $integer = int($param);
		}
		print "$integer";
	} 
}

# Function: treat_exp
# Objective: deal with the expressions
sub treat_exp {
	my ($line, $option, $count, $tabs) = @_;

	# print the correct number of tabs before analysing the expression
	print_tabs($count, $tabs);

	# check if the expression is the print function
	if ($line =~ /^\s*print.*/) {
		
		if ($line =~ /;/) {

			my $new_line = $line;
			$new_line =~ s/^\s*print[^\;]*\K.*//;

			treat_print($new_line); 
			print ";\n";

			$new_line = $line;
			$new_line =~ s/^\s*print[^\;]*\;//;

			treat_exp($new_line, 0, $count, 1);
		
		} else {
			treat_print($line); 
		}

		return;

	# check if the expression is the sys.stdout.write function
	} elsif ($line =~ /sys.stdout.write/) {
		
		if ($line =~ /;/) {

			my $new_line = $line;
			$new_line =~ s/^\s*sys.stdout.write[^\;]*\K.*//;

			treat_sys_write($new_line, $count); 
			print ";\n";

			$new_line = $line;
			$new_line =~ s/^\s*sys.stdout.write[^\;]*\;//;
			#print "new => $new_line";
			#$new_line =~ s/[^\;]*\K[\;]+//;

			treat_exp($new_line, 0, $count, 1);
		
		} else {
			treat_sys_write($line, $count); 
		}

		return;
	
	# check if the expression is a string attribution
	} elsif ($line =~ /^\s*[a-zA-Z][a-zA-Z0-9_]*\s*=\s*".*"\s*$/) {

		my $variable = $line;
		$variable =~ s/^\s*//;
		$variable =~ s/[a-zA-Z][a-zA-Z0-9_]*\K.*\n*$//;

		my @string = split (/"/, $line);
	
		print "\$$variable = \"@string[1]\"";
		return;

	# check if the expression is the int function
	} elsif ($line =~ /int(.*)/) {

		treat_int($line, $count);
		return;
	
	# check if the expression is the sys.stdin.readline function
	} elsif ($line =~ /sys.stdin.readline/) {

		treat_sys_read($line, $count);
		return;

	}

	# splits the line into the spaces
	for $word (split(/\s/, $line)) {

		# check if the current word is a variable
		if ($word ne "\s" && $word =~ /^[a-zA-Z][a-zA-Z0-9_]*$/ && $word ne ("not") && $word ne ("or") && $word ne ("and") && $word ne ("break") && $word ne ("continue")) {
			
			print "\$$word ";
		
		# check if the current word contains a operator
		} elsif ($word ne "\s" && $word =~ /^.*[\+\-\*\/\%\:\=\!\<\>\;\&\|\^\~\(\)].*$/) {
			
			my $prev = $word;
			my $post = $word;
			my $op = $word;

			# repeat while all the word is analysed 
			while ($post =~ /[\+\-\*\/\%\:\=\!\<\>\;\&\|\^\~\(\)]/) {
				
				# isolate the word before the first operator
				$prev =~ s/[a-zA-Z0-9]*\K.*//;
				if ($prev =~ /^[a-zA-Z][a-zA-Z0-9_]*$/ && $prev ne ("not") && $prev ne ("or") && $prev ne ("and") && $prev ne ("break") && $prev ne ("continue")) {
					$prev = '$'.$prev;
				}

				# isolate the word after the first operator
				$post =~ s/[a-zA-Z0-9]*[\+\-\*\/\%\:\=\!\<\>\;\&\|\^\~\(\)]*//;

				# isolate the first operator 
				$op =~ s/^[a-zA-Z0-9]*//;
				$op =~ s/([^a-zA-Z0-9"]*)\K.*//;

				# print the correct output depending of the current operator
				if ($op eq "<>") {
					$op = "!=";
				}
				
				if ($op eq ";") {
					print "$prev;\n\t";
				} elsif ($op eq ");") {
					print "$prev );\n\t";
				} elsif ($op eq "~") {
					print "$op";
				} elsif ($prev eq "") {
					print "$op ";	
				} else {
					print "$prev $op ";
				}

				# update the variables to continue the analysis
				$prev = $post;
				$op = $post;
			}

			# print the correct output depending of the last word
			if ($post eq "break") {
				print "last ";
			} elsif ($post eq "continue") {
				print "next ";
			} elsif ($post =~ /^[a-zA-Z][a-zA-Z0-9_]*$/) {
				print "\$$post ";
			} elsif ($post ne ""){
				print "$post ";
			}
		
		# current word is a number or and reserved word
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

my $count = 0;
my $last_count = 0;

while ($line = <>) {

	# first line of the program
	if ($line =~ /^#!/ && $. == 1) {
	
		print "#!/usr/bin/perl -w\n";

	# comment or blank line
	} elsif ($line =~ /^\s*#/ || $line =~ /^\s*$/) {
	
		print $line;

	# ignores the import line
	} elsif ($line =~ /^\s*import.*/) {

		print "\n";

	} else {

		# get the number of spaces before the first character
		$line =~ /^(\s*)/;
		$count = length($1);

		# check if there are braces to be closed
		if ($count < $last_count && $hash{$count} eq "false") {

			close_braces($count);
			
		}

		# line contains the print function
		if ($line =~ /^\s*print.*/) {

			print_tabs($count, 0);

			treat_print($line);

			print ";\n";

		# line contains a single-line if, while or for 
		} elsif ($line =~ /^\s*elif.*\:.+/ || $line =~ /^\s*if.*\:.+/ || $line =~ /^\s*else.*\:.+/ || $line =~ /^\s*while.*\:.+/ || $line =~ /^\s*for.*\:.+/) {

			if (!exists($hash{$count}) || (exists($hash{$count}) && $hash{$count} eq "true")) {

				$hash{$count} = "false";

			}

			print_tabs($count, 0);

			treat_if_while_for_sl($line, $count);

		# line contains a multi-line if, while or for 
		} elsif ($line =~ /^\s*elif.*\:$/ || $line =~ /^\s*if.*\:$/ || $line =~ /^\s*else.*\:$/ || $line =~ /^\s*while.*\:$/ || $line =~ /^\s*for.*\:$/) {

			if (!exists($hash{$count}) || (exists($hash{$count}) && $hash{$count} eq "true")) {

				$hash{$count} = "false";

			}

			print_tabs($count, 0);

			treat_if_while_for_ml($line);

		# line contains the int function
		} elsif ($line =~ /int(.*)/) {

			treat_int($line, $count);
			print ";\n";

		# line contains the sys.stdin.readline function
		} elsif ($line =~ /sys.stdin.readline/) {

			treat_sys_read($line, $count);
			print ";\n";

		# line contains an attribution expression
		} elsif ($line =~ /^\s*[a-zA-Z][a-zA-Z0-9_]*\s*=.*$/) {
	  	
	  		print_tabs($count, 0);

	  		treat_exp($line, 0);
	  		print ";\n";

	  	# line contains the break command
	  	} elsif ($line =~ /^\s*break\s*$/) {

	  		print_tabs($count, 0);
			print "last;\n";

		# line contains the continue command
		} elsif ($line =~ /^\s*continue\s*$/) {

			print_tabs($count, 0);
			print "next;\n";

		# line contains the sys.stdout.write function
		} elsif ($line =~ /^\s*sys.stdout.write\(.*\)\s*$/) {

			print_tabs($count, 0);
			treat_sys_write($line);
			print ";\n";

		# line can't be translated
		} else {
			print "#$line\n";
		}
	} 
	# update the variables
	$last_count = $count;
}

# close the remaining open braces after finishing the program
close_braces(0);
