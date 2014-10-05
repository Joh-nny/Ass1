#!/usr/bin/perl

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
		treat_exp($line);

		if ($expr == 0) {
			print ", \"\\n\";\n";
		} else {
			print ", \"\\n\"";
		}
	}
}

sub treat_if {
	my ($line) = @_;

	print "if (";
	$line =~ s/^\s*if\s*//g;
	treat_exp($line);
	print ";\n}\n";

}

sub treat_while {
	my ($line) = @_;

	print "while (";
	$line =~ s/^\s*while\s*//g;
	treat_exp($line);
	print ";\n}\n";

}

sub treat_exp {
	my ($line) = @_;

	for $word (split(/\s/, $line)) {

		#print "$word\n";

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

		} elsif ($word ne "\s" && $word =~ /^[a-zA-Z][a-zA-Z0-9_]*$/) {
			
			print "\$$word ";
		
		} elsif ($word ne "\s" && $word =~ /^.*[\+\-\*\/\%\:\=\!\<\>\;].*$/) {
			
			$prev = $word;
			$post = $word;
			$op = $word;

			while ($post =~ /[\+\-\*\/\%\:\=\!\<\>\;]/) {
				
				$prev =~ s/[a-zA-Z0-9]*\K.*//g;
				$post =~ s/[a-zA-Z0-9]*[\+\-\*\/\%\:\=\!\<\>\;]*//;
				$op =~ s/^[a-zA-Z0-9]*//;
				$op =~ s/[^\+\-\*\/\%\:\=\!\<\>\;]//g;

				if ($prev eq "") {
					print "$op ";
				} elsif ($op eq ":") {
					print "$prev) {\n\t";
				} elsif ($op eq ";") {
					print "$prev;\n\t";
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
		
		treat_print($line, 0);

	} elsif ($line =~ /^\s*if.*/) {

		treat_if($line);

	} elsif ($line =~ /^\s*while.*/) {

		treat_while($line);
	
	} elsif ($line =~ /^\s*[a-zA-Z][a-zA-Z0-9_]*\s*=.*$/) {
	  	
	  	treat_exp($line);
	  	print ";\n";
	
	} else {
	
		# Lines we can't translate are turned into comments
		print "#$line\n";

	}
}
