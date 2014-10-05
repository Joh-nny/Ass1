#!/usr/bin/perl

sub treat_print {
	my ($line) = @_;

	if ($line =~ /^\s*print\s*"(.*)"\s*$/) {
	
		# Python's print print a new-line character by default
		# so we need to add it explicitly to the Perl print statement
		print "print \"$1\\n\";\n";

	} else {
		
		print "print ";
		$line =~ s/^\s*print\s*//g;
		treat_exp($line);
		print ", \"\\n\";\n";
	}
}

sub treat_exp {
	my ($line) = @_;

	for $word (split(/\s/, $line)) {

		#print "$word\n";

		if ($word ne "\s" && $word =~ /^[a-zA-Z][a-zA-Z0-9_]*$/) {
			
			print "\$$word ";
		
		} elsif ($word ne "\s" && $word =~ /^.*[\+\-\*\/\%].*$/) {
			
			$prev = $word;
			$post = $word;
			$op = $word;

			while ($post =~ /[\+\-\*\/\%]/) {
				
				$prev =~ s/[a-zA-Z0-9]*\K.*//g;
				$post =~ s/[a-zA-Z0-9]*[\+\-\*\/\%]*//;
				$op =~ s/^[a-zA-Z0-9]*//;
				$op =~ s/[^\+\-\*\/\%]//g;

				if ($prev eq "") {
					print "$op ";
				} else {
					print "$prev $op ";
				}

				$prev = $post;
				$op = $post;
			}

			if ($post ne ""){
				print "$post ";
			}

		} else {

			print "$word ";

		}
	}
}

while ($line = <>) {
	if ($line =~ /^#!/ && $. == 1) {
	
		# translate #! line 
		print "#!/usr/bin/perl -w\n";

	} elsif ($line =~ /^\s*#/ || $line =~ /^\s*$/) {
	
		# Blank & comment lines can be passed unchanged
		print $line;

	} elsif ($line =~ /^\s*print.*/) {
		treat_print($line);
	

	#} elsif ($line =~ /^\s*print\s*"(.*)"\s*$/) {
	
		# Python's print print a new-line character by default
		# so we need to add it explicitly to the Perl print statement
	#	print "print \"$1\\n\";\n";

	#} elsif ($line =~ /^\s*print\s*[a-zA-Z0-9_]*\s*$/) {

		# print with variable
	#	$variable = $line;
	#	$variable =~ s/^\s*//g;
	#	$variable =~ s/print\s*//;
	#	$variable =~ s/.*\K\n//;

	#	print "print \"\$$variable\\n\";\n";
	
	} #elsif ($line =~ /^\s*[a-zA-Z0-9_]*\s*=\s*[0-9]*$/) {

		# Numeric constants
		#$variable = $line;
		#$value = $line;
		#$variable =~ s/^\s*//g;
		#$variable =~ s/[a-zA-Z0-9_]*\K.*//;
		#$variable =~ s/.*\K\n//;
		#$value =~ s/.*=\s*//g;
		#$value =~ s/.*\K\n//;

		#print "\$$variable = $value;\n";

	  elsif ($line =~ /^\s*[a-zA-Z][a-zA-Z0-9_]*\s*=.*$/) {
	  	treat_exp($line);
	  	print ";\n";
	
	} else {
	
		# Lines we can't translate are turned into comments
		print "#$line\n";

	}
}
