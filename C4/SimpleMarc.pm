#!/usr/bin/perl

# $Id$

package C4::SimpleMarc;

# Routines for handling import of MARC data into Koha db

# Koha library project  www.koha.org

# Licensed under the GPL


# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;

# standard or CPAN modules used
use DBI;

# Koha modules used

require Exporter;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);
@EXPORT = qw(
	&extractmarcfields 
	&parsemarcfileformat 
	&taglabel
	%tagtext
	%tagmap
);
%EXPORT_TAGS = ( );     # eg: TAG => [ qw!name1 name2! ],

# your exported package globals go here,
# as well as any optionally exported functions

@EXPORT_OK   = qw(
	%tagtext
	%tagmap
);

# non-exported package globals go here
use vars qw(@more $stuff);

# initalize package globals, first exported ones

my $Var1   = '';
my %Hashit = ();

# then the others (which are still accessible as $Some::Module::stuff)
my $stuff  = '';
my @more   = ();

# all file-scoped lexicals must be created before
# the functions below that use them.

# file-private lexicals go here
my $priv_var    = '';
my %secret_hash = ();

# here's a file-private function as a closure,
# callable as &$priv_func;  it cannot be prototyped.
my $priv_func = sub {
  # stuff goes here.
  };
  
# make all your functions, whether exported or not;
#------------------------------------------------

#------------------
# Constants

my %tagtext = (
    'LDR' => 'Leader',
    '001' => 'Control number',
    '003' => 'Control number identifier',
    '005' => 'Date and time of latest transaction',
    '006' => 'Fixed-length data elements -- additional material characteristics',
    '007' => 'Physical description fixed field',
    '008' => 'Fixed length data elements',
    '010' => 'LCCN',
    '015' => 'National library CN',
    '020' => 'ISBN',
    '022' => 'ISSN',
    '024' => 'Other standard ID',
    '035' => 'System control number',
    '037' => 'Source of acquisition',
    '040' => 'Cataloging source',
    '041' => 'Language code',
    '043' => 'Geographic area code',
    '043' => 'Publishing country code',
    '050' => 'Library of Congress call number',
    '055' => 'Canadian classification number',
    '060' => 'National Library of Medicine call number',
    '082' => 'Dewey decimal call number',
    '100' => 'Main entry -- Personal name',
    '110' => 'Main entry -- Corporate name',
    '130' => 'Main entry -- Uniform title',
    '240' => 'Uniform title',
    '245' => 'Title statement',
    '246' => 'Varying form of title',
    '250' => 'Edition statement',
    '256' => 'Computer file characteristics',
    '260' => 'Publication, distribution, etc.',
    '263' => 'Projected publication date',
    '300' => 'Physical description',
    '306' => 'Playing time',
    '440' => 'Series statement / Added entry -- Title',
    '490' => 'Series statement',
    '500' => 'General note',
    '504' => 'Bibliography, etc. note',
    '505' => 'Formatted contents note',
    '508' => 'Creation/production credits note',
    '510' => 'Citation/references note',
    '511' => 'Participant or performer note',
    '520' => 'Summary, etc. note',
    '521' => 'Target audience note (ie age)',
    '530' => 'Additional physical form available note',
    '538' => 'System details note',
    '586' => 'Awards note',
    '600' => 'Subject added entry -- Personal name',
    '610' => 'Subject added entry -- Corporate name',
    '650' => 'Subject added entry -- Topical term',
    '651' => 'Subject added entry -- Geographic name',
    '656' => 'Index term -- Occupation',
    '700' => 'Added entry -- Personal name',
    '710' => 'Added entry -- Corporate name',
    '730' => 'Added entry -- Uniform title',
    '740' => 'Added entry -- Uncontrolled related/analytical title',
    '800' => 'Series added entry -- Personal name',
    '830' => 'Series added entry -- Uniform title',
    '852' => 'Location',
    '856' => 'Electronic location and access',
);

# tag, subfield, field name, repeats, striptrailingchars
my %tagmap=(
    '010'=>{'a'=>{name=> 'lccn',	rpt=>0, striptrail=>' ' 	}},
    '015'=>{'a'=>{name=> 'lccn',	rpt=>0	}},
    '020'=>{'a'=>{name=> 'isbn',	rpt=>0	}},
    '022'=>{'a'=>{name=> 'issn',	rpt=>0	}},
    '082'=>{'a'=>{name=> 'dewey',	rpt=>0	}},
    '100'=>{'a'=>{name=> 'author',	rpt=>0, striptrail=>',:;/-'	}},
    '245'=>{'a'=>{name=> 'title',	rpt=>0, striptrail=>',:;/'	},
            'b'=>{name=> 'subtitle',	rpt=>0, striptrail=>',:;/'	}},
    '260'=>{'a'=>{name=> 'place',	rpt=>0, striptrail=>',:;/-'	},
            'b'=>{name=> 'publisher',	rpt=>0, striptrail=>',:;/-'	},
            'c'=>{name=> 'year' ,	rpt=>0, striptrail=>'.,:;/-'	}},
    '300'=>{'a'=>{name=> 'pages',	rpt=>0, striptrail=>',:;/-'	},
            'c'=>{name=> 'size',	rpt=>0, striptrail=>',:;/-'	}},
    '362'=>{'a'=>{name=> 'volume-number',	rpt=>0	}},
    '440'=>{'a'=>{name=> 'seriestitle',	rpt=>0, striptrail=>',:;/'	},
            'v'=>{name=> 'volume-number',rpt=>0	}},
    '490'=>{'a'=>{name=> 'seriestitle',	rpt=>0, striptrail=>',:;/'	},
            'v'=>{name=> 'volume-number',rpt=>0	}},
    '700'=>{'a'=>{name=> 'addtional-author-illus',rpt=>1, striptrail=>',:;/'	}},
    '5xx'=>{'a'=>{name=> 'notes',	rpt=>1	}},
    '65x'=>{'a'=>{name=> 'subject',	rpt=>1, striptrail=>'.,:;/-'	}},
);


#------------------
sub extractmarcfields {
    use strict;
    # input
    my (
	$record,	# pointer to list of MARC field hashes.
			# Example: $record->[0]->{'tag'} = '100' # Author
			# 	$record->[0]->{'subfields'}->{'a'} = subfieldvalue
    )=@_;

    # return 
    my $bib;		# pointer to hash of named output fields
			# Example: $bib->{'author'} = "Twain, Mark";

    my $debug=0;

    my (
	$field, 	# hash ref
	$value, 
	$subfield,	# Marc subfield [a-z]
	$fieldname,	# name of field "author", "title", etc.
	$strip,		# chars to remove from end of field
	$stripregex,	# reg exp pattern
    );
    my ($lccn, $isbn, $issn,    
	$publicationyear, @subjects, $subject,
	$controlnumber, 
	$notes, $additionalauthors, $illustrator, $copyrightdate, 
	$s, $subdivision, $subjectsubfield,
    );

    print "<PRE>\n" if $debug;

    if ( ref($record) eq "ARRAY" ) {
        foreach $field (@$record) {

	    # Check each subfield in field
	    foreach $subfield ( keys %{$field->{subfields}} ) {
		# see if it is defined in our Marc to koha mapping table
	    	if ( $fieldname=$tagmap{ $field->{'tag'} }->{$subfield}->{name} ) {
		    # Yes, so keep the value
		    if ( ref($field->{'subfields'}->{$subfield} ) eq 'ARRAY' ) {
		        # if it was an array, just keep first element.
		        $bib->{$fieldname}=$field->{'subfields'}->{$subfield}[0];
		    } else {
		        $bib->{$fieldname}=$field->{'subfields'}->{$subfield};
		    } # if array
		    print "$field->{'tag'} $subfield $fieldname=$bib->{$fieldname}\n" if $debug;
		    # see if this field should have trailing chars dropped
	    	    if ($strip=$tagmap{ $field->{'tag'} }->{$subfield}->{striptrail} ) {
			$strip=~s//\\/; # backquote each char
			$stripregex='[ ' . $strip . ']+$';  # remove trailing spaces also
			$bib->{$fieldname}=~s/$stripregex//;
			# also strip leading spaces
			$bib->{$fieldname}=~s/^ +//;
		    } # if strip
		    print "Found subfield $field->{'tag'} $subfield " .
			"$fieldname = $bib->{$fieldname}\n" if $debug;
		} # if tagmap exists

	    } # foreach subfield


	    if ($field->{'tag'} eq '001') {
		$bib->{controlnumber}=$field->{'indicator'};
	    }
	    if ($field->{'tag'} eq '015') {
		$bib->{lccn}=$field->{'subfields'}->{'a'};
		$bib->{lccn}=~s/^\s*//;
		$bib->{lccn}=~s/^C//;
		($bib->{lccn}) = (split(/\s+/, $bib->{lccn}))[0];
	    }


		if ($field->{'tag'} eq '260') {

		    $publicationyear=$field->{'subfields'}->{'c'};
		    if ($publicationyear=~/c(\d\d\d\d)/) {
			$copyrightdate=$1;
		    }
		    if ($publicationyear=~/[^c](\d\d\d\d)/) {
			$publicationyear=$1;
		    } elsif ($copyrightdate) {
			$publicationyear=$copyrightdate;
		    } else {
			$publicationyear=~/(\d\d\d\d)/;
			$publicationyear=$1;
		    }
		}
		if ($field->{'tag'} eq '700') {
		    my $name=$field->{'subfields'}->{'a'};
		    if ( defined($field->{'subfields'}->{'e'}) 
		        and  $field->{'subfields'}->{'e'}=~/ill/) {
			$illustrator=$name;
		    } else {
			$additionalauthors.="$name\n";
		    }
		}
		if ($field->{'tag'} =~/^5/) {
		    $notes.="$field->{'subfields'}->{'a'}\n";
		}
		if ($field->{'tag'} =~/65\d/) {
		    my $sub;
		    my $subject=$field->{'subfields'}->{'a'};
		    $subject=~s/\.$//;
		    print "Subject=$subject\n" if $debug;
		    foreach $subjectsubfield ( 'x','y','z' ) {
		      if ($subdivision=$field->{'subfields'}->{$subjectsubfield}) {
			if ( ref($subdivision) eq 'ARRAY' ) {
			    foreach $s (@$subdivision) {
				$s=~s/\.$//;
				$subject.=" -- $s";
			    } # foreach subdivision
			} else {
			    $subdivision=~s/\.$//;
			    $subject.=" -- $subdivision";
			} # if array
		      } # if subfield exists
		    } # foreach subfield
		    print "Subject=$subject\n" if $debug;
		    push @subjects, $subject;
		} # if tag 65x


        } # foreach field
	($publicationyear	) && ($bib->{publicationyear}=$publicationyear  );
	($copyrightdate		) && ($bib->{copyrightdate}=$copyrightdate  );
	($additionalauthors	) && ($bib->{additionalauthors}=$additionalauthors  );
	($illustrator		) && ($bib->{illustrator}=$illustrator  );
	($notes			) && ($bib->{notes}=$notes  );
	($#subjects		) && ($bib->{subject}=\@subjects  );

	# Misc cleanup
	if ($bib->{dewey}) {
	    $bib->{dewey}=~s/\///g;	# drop any slashes
	}

	if ($bib->{lccn}) {
	   ($bib->{lccn}) = (split(/\s+/, $bib->{lccn}))[0]; # only keep first word
	}

	if ( $bib->{isbn} ) {
	    $bib->{isbn}=~s/[^\d]*//g;	# drop non-digits
	};

	if ( $bib->{issn} ) {
	    $bib->{issn}=~s/^\s*//;
	    ($bib->{issn}) = (split(/\s+/, $bib->{issn}))[0];
	};

	if ( $bib->{'volume-number'} ) {
	    if ($bib->{'volume-number'}=~/(\d+).*(\d+)/ ) {
		$bib->{'volume'}=$1;
		$bib->{'number'}=$2;
	    } else {
		$bib->{volume}=$bib->{'volume-number'};
	    }
	    delete $bib->{'volume-number'};
	} # if volume-number

    } else {
	print "Error: extractmarcfields: input ref $record is " .
		ref($record) . " not ARRAY. Contact sysadmin.\n";
    }
    print "</PRE>\n" if $debug;

    return $bib;

} # sub extractmarcfields
#---------------------------------

#--------------------------
# Parse MARC data in file format with control-character separators
#   May be multiple records.
sub parsemarcfileformat {
    use strict;
    # Input is one big text string
    my $data=shift;
    # Output is list of records.  Each record is list of field hashes
    my @records;

    my $splitchar=chr(29);
    my $splitchar2=chr(30);
    my $splitchar3=chr(31);
    my $debug=0;
    my $record;
    foreach $record (split(/$splitchar/, $data)) {
	my @record;
	my $directory=0;
	my $tagcounter=0;
	my %tag;
	my $field;

	my $leader=substr($record,0,24);
	print "<pre>parse Leader:$leader</pre>\n" if $debug;
	push (@record, {
		'tag' => 'LDR',
		'indicator' => $leader ,
	} );

	$record=substr($record,24);
	foreach $field (split(/$splitchar2/, $record)) {
	    my %field;
	    my $tag;
	    my $indicator;
	    unless ($directory) {
		# If we didn't already find a directory, extract one.
		$directory=$field;
		my $itemcounter=1;
		my $counter2=0;
		my $item;
		my $length;
		my $start;
		while ($item=substr($directory,0,12)) {
		    # Pull out location of first field
		    $tag=substr($directory,0,3);
		    $length=substr($directory,3,4);
		    $start=substr($directory,7,6);

		    # Bump to next directory entry
		    $directory=substr($directory,12);
		    $tag{$counter2}=$tag;
		    $counter2++;
		}
		$directory=1;
		next;
	    }
	    $tag=$tag{$tagcounter};
	    $tagcounter++;
	    $field{'tag'}=$tag;
	    my @subfields=split(/$splitchar3/, $field);
	    $indicator=$subfields[0];
	    $field{'indicator'}=$indicator;
	    print "<pre>parse indicator:$indicator</pre>\n" if $debug;
	    my $firstline=1;
	    unless ($#subfields==0) {
		my %subfields;
		my @subfieldlist;
		my $i;
		for ($i=1; $i<=$#subfields; $i++) {
		    my $text=$subfields[$i];
		    my $subfieldcode=substr($text,0,1);
		    my $subfield=substr($text,1);
		    # if this subfield already exists, do array
		    if ($subfields{$subfieldcode}) {
			my $subfieldlist=$subfields{$subfieldcode};
			if ( ref($subfieldlist) eq 'ARRAY' ) {
                            # Already an array, add on to it
			    print "$tag Adding to array $subfieldcode -- $subfield<br>\n" if $debug;
			    @subfieldlist=@$subfieldlist;
			    push (@subfieldlist, $subfield);
			} else {
                            # Change simple value to array
			    print "$tag Arraying $subfieldcode -- $subfield<br>\n" if $debug;
			    @subfieldlist=($subfields{$subfieldcode}, $subfield);
			}
			# keep new array
			$subfields{$subfieldcode}=\@subfieldlist;
		    } else {
			# subfield doesn't exist yet, keep simple value
			$subfields{$subfieldcode}=$subfield;
		    }
		}
		$field{'subfields'}=\%subfields;
	    }
	    push (@record, \%field);
	} # foreach field in record
	push (@records, \@record);
	# $counter++;
    }
    print "</pre>" if $debug;
    return @records;
} # sub parsemarcfileformat

#----------------------------------------------
sub taglabel {
    my ($tag)=@_;

    return $tagtext{$tag};

} # sub taglabel

#---------------------------------------------
# $Log$
# Revision 1.4  2002/10/05 09:53:11  arensb
# Merged with arensb-context branch: use C4::Context->dbh instead of
# &C4Connect, and generally prefer C4::Context over C4::Database.
#
# Revision 1.3.2.1  2002/10/04 02:57:38  arensb
# Removed useless "use C4::Database;" line.
#
# Revision 1.3  2002/08/14 18:12:52  tonnesen
# Added copyright statement to all .pl and .pm files
#
# Revision 1.2  2002/07/02 20:30:15  tonnesen
# Merged SimpleMarc.pm over from rel-1-2
#
# Revision 1.1.2.4  2002/06/28 14:36:47  amillar
# Fix broken logic on illustrator vs. add'l author
#
# Revision 1.1.2.3  2002/06/26 20:54:32  tonnesen
# use warnings breaks on perl 5.005...
#
# Revision 1.1.2.2  2002/06/26 15:52:55  amillar
# Fix display of marc tag labels and indicators
#
# Revision 1.1.2.1  2002/06/26 07:27:35  amillar
# Moved acqui.simple MARC handling to new module SimpleMarc.pm
#
