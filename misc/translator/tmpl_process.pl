#!/usr/bin/perl

use strict;
use Getopt::Long;

my (@in_files, $str_file, $split_char, $recursive, $type, $out_dir, $in_dir, @excludes, $filter);
my $help;
my $exclude_regex;

$split_char = '	';

GetOptions(
	'input|i=s'	=> \@in_files,
	'outputdir|o=s' => \$out_dir,
	'str-file|s=s' => \$str_file,
	'recursive|r' => \$recursive,
	'filter=s' => \$filter,
	'type=s' => \$type,
	'exclude=s' => \@excludes,
	'sep=s' => \$split_char,
	'help'	=> sub { help() },
) || usage();

# utiliser glob() pour tous les fichiers d'un repertoire

my $action = shift or usage();
my %strhash = ();

# Checks for missing input and string list arguments

if( !@in_files || !defined($str_file) )
{
	usage("You must at least specify input and string list filenames.");
}

# Type match defaults to *.tmpl if not specified
$type = "tmpl|inc" if !defined($type);

$filter = "./text-extract.pl -f" if !defined($filter);
# Input is not a file nor a directory
if( !(-d $in_files[0]) && !(-f $in_files[0]))
{
	usage("Unknown input. Input must a file or a directory. (Symbolic links are not supported for the moment.)");
}
elsif( -d $in_files[0] )
{
	# input is a directory, generates list of files to process
	$in_dir = $in_files[0];
	$in_dir =~ s/\/$//; # strips the trailing / if any

	print "Generating list of files to process...\n";
	
	@in_files = ();
	@in_files = &listfiles(\@in_files, $in_dir, $type, $recursive);

	if(scalar(@in_files) == 0)
	{
		warn "Nothing to process in $in_dir matching *.$type.";
		exit -1;
	}
}

# Generates the global exclude regular expression
$exclude_regex =  "(".join("|", @excludes).")" if @excludes;

if( $action eq "create" )
{
	# updates the list. As the list is empty, every entry will be added
	%strhash = &update_strhash(\%strhash, \@in_files, $exclude_regex, $filter);
	# saves the list to the file
	write_strhash(\%strhash, $str_file, "\t");
}
elsif( $action eq "update" )
{
	# restores the string list from file
	%strhash = &restore_strhash(\%strhash, $str_file, $split_char);
	# updates the list, adding new entries if any
	%strhash = &update_strhash(\%strhash, \@in_files, $exclude_regex, $filter);
	# saves the list to the file
	write_strhash(\%strhash, $str_file, $split_char);
}
elsif( $action eq "install" )
{
	if(!defined($out_dir))
	{
		usage("You must specify an output directory when using the install method.");
	}
	
	if( $in_dir eq $out_dir )
	{
		warn "You must specify a different input and output directory.\n";
		exit -1;
	}

	# restores the string list from file
	%strhash = &restore_strhash(\%strhash, $str_file, $split_char);
	# creates the new tmpl file using the new translation
	&install_strhash(\%strhash, \@in_files, $in_dir, $out_dir);
}
else
{
	usage("Unknown action specified.");
}

exit 0;

##########################################################
# Creates the new template files in the output directory #
##########################################################

sub install_strhash
{
	my($strhash, $in_files, $in_dir, $out_dir) = @_;

	my $fh_in; my $fh_out; # handles for input and output files
	my $tmp_dir; # temporary directory name (used to create destination dir)

	$out_dir =~ s/\/$//; # chops the trailing / if any.

	# Processes every entry found.
	foreach my $file (@{$in_files})
	{
		if( !open($fh_in, "< $file") )
		{
			warn "Can't open $file : $!\n";
			next;
		}

		# generates the name of the output file
		my $out_file = $file;

		if(!defined $in_dir)
		{
			# processing single files not an entire directory
			$out_file = "$out_dir/$file";
		}
		else
		{
			$out_file =~ s/^$in_dir/$out_dir/;
		}

		my $slash = rindex($out_file, "\/");
		$tmp_dir = substr($out_file, 0, $slash); #gets the directory where the file will be saved

		# the file doesn't exist
		if( !(-f $tmp_dir) && !(-l $tmp_dir) && !(-e $tmp_dir) )
		{
			if(!mkdir($tmp_dir,0775)) # creates with rwxrwxr-x permissions
			{
				warn("Make directory $tmp_dir : $!");
				close($fh_in);
				exit(1);
			}
		}
		elsif((-f $tmp_dir) || (-l $tmp_dir))
		{
			warn("Unable to create directory $tmp_dir.\n A file or symbolic link with the same name already exists.");
			close($fh_in);
			exit(1);
		}
		
		# opens handle for output
		if( !open($fh_out, "> $out_file") )
		{
			warn "Can't write $out_file : $!\n";
			close($fh_in);
			next;
		}

		print "Generating $out_file...\n";

		while(my $line = <$fh_in>)
		{
			foreach my $text (sort  {length($b) <=> length($a)} keys %{$strhash})
			{
				# Test if the key has been translated
				if( %{$strhash}->{$text} != 1 )
				{
					# Does the line contains text that needs to be changed ?
					if( $line =~ /$text/ && %{$strhash}->{$text} ne "IGNORE")
					{
						# changing text
						my $subst = %{$strhash}->{$text};
						$line =~ s/(\W)$text(\W)/$1$subst$2/g;
					}
				}
			}
			$line =~ s/\<TMPL_(.*?)\>/\<\!-- TMPL_$1 --\>/g;
			$line =~ s/\<\/TMPL_(.*?)\>/\<\!-- \/TMPL_$1 --\>/g;
			# Writing the modified (or not) line to output
			printf($fh_out "%s", $line);
		}

		close($fh_in);
		close($fh_out);
	}
}

########################################################
# Updates the string list hash with the new components #
########################################################

sub update_strhash
{
	my($strhash, $in_files, $exclude, $filter)= @_;

	my $fh;

	# Processes every file entries
	foreach my $in (@{$in_files})
	{

		print "Processing $in...\n";

		# Creates a filehandle containing all the strings returned by
		# the plain text program extractor
		open($fh, "$filter $in |") or print "$filter $in : $!";
		next $in if !defined $fh;

		# Processes every string returned
		while(my $str = <$fh>)
		{
			$str =~ s/[\n\r\f]+$//; # chomps the trailing \n (or <cr><lf> if file was edited with Windows)
			$str =~ s/^\s+//; # remove trailing blanks, ':' or '*'
			$str =~ s/\s*\**:*\s*$//;

			# the line begins with letter(s) followed by optional words and/or spaces
			if($str =~ /^[ ]*[\w]+[ \w]*/)
			{
				# the line is to be excluded ?
				if( !(defined($exclude) && ($str =~ /$exclude/o) && $str>0) )
				{
					if( !defined(%{$strhash}->{$str}) )
					{
						# the line is not already in the list so add it
						%{$strhash}->{$str}=1;
					}
				}
			}
		}

		close($fh);
	}

	return %{$strhash};
}

#####################################################
# Reads the input file and returns a generated hash #
#####################################################

sub restore_strhash
{
	my($strhash, $str_file, $split_char) = @_;
	
	my $fh;
	
	open($fh, "< $str_file") or die "$str_file : $!";
	
	print "Restoring string list from $str_file...\n";
	
	while( my $line = <$fh> )
	{
		chomp $line;

		# extracts the two fields
		my ($original, $translated) = split(/$split_char/, $line, 2);

		if($translated ne "*****")
		{
			# the key has been translated
			%{$strhash}->{$original} = $translated;
		}
		else
		{
			# the key exist but has no translation.
			%{$strhash}->{$original} = 1;
		}

	}

	close($fh);

	return %{$strhash};
}

#########################################
# Writes the string hashtable to a file #
#########################################

sub write_strhash
{
	my($strhash, $str_file, $split_char) = @_;

	my $fh;

	# Opens a handle for saving the list
	open($fh, "> $str_file") or die "$str_file : $!";

	print "Writing string list to $str_file...\n";

	foreach my $str(sort {uc($a) cmp uc($b) || length($a) <=> length($b)} keys %{$strhash})
	{
		if(%{$strhash}->{$str} != 1)
		{
			printf($fh "%s%s%s\n", $str, $split_char, %{$strhash}->{$str});
		}
		else
		{
			printf($fh "%s%s%s\n", $str, $split_char,"*****") unless ($str >0);
		}
	}

	close($fh);
}

########################################################
# List the contents of dir matching the pattern *.type #
########################################################

sub listfiles
{
	my($in_files, $dir, $type, $recursive) = @_;

	my $dir_h;
#	my @types = split(/ /,$type);
	opendir($dir_h, $dir) or warn("Can't open $dir : $!\n");

	my @tmp_list = grep(!/^\.\.?$/, readdir($dir_h));

	closedir($dir_h);

	foreach my $tmp_file (@tmp_list)
	{

		if( $recursive && (-d "$dir/$tmp_file") ) # entry is a directory
		{
			@{$in_files} = listfiles($in_files, "$dir/$tmp_file", $type);
		}
		elsif( $tmp_file =~ /\.$type$/ )
		{
			push(@{$in_files}, "$dir/$tmp_file");
		}
	}
	return @{$in_files};
}

######################################
# DEBUG ROUTINE                      #
# Prints the contents of a hashtable #
######################################

sub print_strhash
{
	my($strhash, $split_char) = @_;
	
	foreach my $str(sort keys %{$strhash})
	{
		if(%{$strhash}->{$str} != 1)
		{
			printf("%s%s%s\n", $str, $split_char, %{$strhash}->{$str});
		}
		else
		{
			printf("%s%s\n", $str, $split_char);
		}
	}
}	

#########################################
# Short help messsage printing function #
#########################################

sub usage
{
	warn join(" ", @_)."\n" if @_;
	warn <<EOF;

Usage : $0 method -i input.tmpl|/input/dir -s strlist.file
        [-o /output/dir] [options]

where method can be :
  * create : creates the string list from scratch using the input files.
  * update : updates an existing string list, adding the new strings to
             the list, leaving the others alone.
  * install : creates the new .tmpl files using the string list config file
              (--outputdir must be used to specify the output directory).

Use $0 --help for a complete listing of options.
EOF
	exit(1);
}

##############################################
# Long help message describing every options #
##############################################

sub help
{
	warn <<EOF;
Usage : $0 method [options]
        
where method can be :
  * create : creates the string list from scratch using the input files.
  * update : updates an existing string list, adding the new strings to
             the list, leaving the others alone.
  * install : creates the new .tmpl files using the string list config file
              (-o must be used to specify the output directory).

options can be :

  -i or --input=
     Specify the input to process. Input can be a file or a directory.
     When input is a directory, files matching the --type option will be
     processed.
     When using files, the parameter can be repeated to process a list
     of files.
   
  Example: $0 create -i foo.tmpl --input=bar.tmpl -s foobar.txt

  -s or --str-file=
     Specify the file where the different strings will be stored.

  -o or --outputdir=
     Specify the output directory to use when generating the translated
     input files.

  -r or --recursive
     Use the recursive mode to process every entry in subdirectories.
     Note: Symbolic links used to link directories are not supported.

  --type=
     Defines the type of files to match when input is a directory.
     By default --type=tmpl

  --exclude=regex
     Use this option to exclude some entries extracted by the program.
     This option can be repeated to exclude many types of strings.

  Example: $0 create -i foo.tmpl -s foo.txt --exclude=^\[0-9\]+\$
   will create a list from foo.tmpl called foo.txt where lines
   composed of numbers only are excluded. Special characters need to
   be escaped.

  --filter=
     Specify the program to use to extract plain text from files.
     Default is str-extract which means str-extract must be in the path
     in order to use it.

  --sep=char
     Use this option to specify the char to be used to separate entries
     in the string list file.

  --help
     This help message.
EOF
	exit(0);
}
