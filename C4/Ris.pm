package C4::Ris;

# Original script :
## marc2ris: converts MARC21 and UNIMARC datasets to RIS format
##           See comments below for compliance with other MARC dialects
##
## usage: perl marc2ris < infile.marc > outfile.ris
##
## Dependencies: perl 5.6.0 or later
##               MARC::Record
##               MARC::Charset
##
## markus@mhoenicka.de 2002-11-16

##   This program is free software; you can redistribute it and/or modify
##   it under the terms of the GNU General Public License as published by
##   the Free Software Foundation; either version 2 of the License, or
##   (at your option) any later version.
##   
##   This program is distributed in the hope that it will be useful,
##   but WITHOUT ANY WARRANTY; without even the implied warranty of
##   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##   GNU General Public License for more details.

##   You should have received a copy of the GNU General Public License
##   along with this program; if not, write to the Free Software
##   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

## Some background about MARC as understood by this script
## The default input format used in this script is MARC21, which
## superseded USMARC and CANMARC. The specification can be found at:
## http://lcweb.loc.gov/marc/
## UNIMARC follows the specification at:
## http://www.ifla.org/VI/3/p1996-1/sec-uni.htm
## UKMARC support is a bit shaky because there is no specification available
## for free. The wisdom used in this script was taken from a PDF document
## comparing UKMARC to MARC21 found at:
## www.bl.uk/services/bibliographic/marcchange.pdf


# Modified 2008 by BibLibre for Koha
# Modified 2011 by Catalyst
# Modified 2011 by Equinox Software, Inc.
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.
#
#

#use strict;
#use warnings;

use List::MoreUtils qw/uniq/;
use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 3.07.00.049;

@ISA = qw(Exporter);

# only export API methods

@EXPORT = qw(
  &marc2ris
);


=head1 marc2bibtex - Convert from UNIMARC to RIS

  my ($ris) = marc2ris($record);

Returns a RIS scalar

C<$record> - a MARC::Record object

=cut

sub marc2ris {
    my ($record) = @_;
    my $output;

    my $marcflavour = C4::Context->preference("marcflavour");
    my $intype = lc($marcflavour);
    my $marcprint = 0; # Debug flag;

    # Let's redirect stdout
    open my $oldout, ">&STDOUT";
    my $outvar;
    close STDOUT;
    open STDOUT,'>', \$outvar;


	## First we should check the character encoding. This may be
	## MARC-8 or UTF-8. The former is indicated by a blank, the latter
	## by 'a' at position 09 (zero-based) of the leader
	my $leader = $record->leader();
	if ($intype eq "marc21") {
	    if ($leader =~ /^.{9}a/) {
		print "<marc>---\r\n<marc>UTF-8 data\r\n" if $marcprint;
		$utf = 1;
	    }
	    else {
		print "<marc>---\r\n<marc>MARC-8 data\r\n" if $marcprint;
	    }
	}
	## else: other MARC formats do not specify the character encoding
	## we assume it's *not* UTF-8

	## start RIS dataset
	&print_typetag($leader);

	## retrieve all author fields and collect them in a list
	my @author_fields;

	if ($intype eq "unimarc") {
	    ## Fields 700, 701, and 702 can contain author names
	    @author_fields = ($record->field('700'), $record->field('701'), $record->field('702'));
	}
	else {  ## marc21, ukmarc
	    ## Field 100 sometimes carries main author
	    ## Field(s) 700 carry added entries - personal names
	    @author_fields = ($record->field('100'), $record->field('700'));
	}

	## loop over all author fields
	foreach my $field (@author_fields) {
	    if (length($field)) {
		my $author = &get_author($field);
		print "AU  - ",&charconv($author),"\r\n";
	    }
	}

	# ToDo: should we specify anonymous as author if we didn't find
	# one? or use one of the corporate/meeting names below?

	## add corporate names or meeting names as editors ??
	my @editor_fields;

	if ($intype eq "unimarc") {
	    ## Fields 710, 711, and 712 can carry corporate names
	    ## Field(s) 720, 721, 722, 730 have additional candidates
	    @editor_fields = ($record->field('710'), $record->field('711'), $record->field('712'), $record->field('720'), $record->field('721'), $record->field('722'), $record->field('730'));
	}
	else { ## marc21, ukmarc
	    ## Fields 110 and 111 carry the main entries - corporate name and
	    ## meeting name, respectively
	    ## Field(s) 710, 711 carry added entries - personal names
	    @editor_fields = ($record->field('110'), $record->field('111'), $record->field('710'), $record->field('711'));
	}

	## loop over all editor fields
	foreach my $field (@editor_fields) {
	    if (length($field)) {
		my $editor = &get_editor($field);
		print "ED  - ",&charconv($editor),"\r\n";
	    }
	}

	## get info from the title field
	if ($intype eq "unimarc") {
	    &print_title($record->field('200'));
	}
	else { ## marc21, ukmarc
	    &print_title($record->field('245'));
	}

	## series title
	if ($intype eq "unimarc") {
	    &print_stitle($record->field('225'));
	}
	else { ## marc21, ukmarc
	    &print_stitle($record->field('490'));
	}

	## ISBN/ISSN
	if ($intype eq "unimarc") {
	    &print_isbn($record->field('010'));
	    &print_issn($record->field('011'));
	}
	elsif ($intype eq "ukmarc") {
	    &print_isbn($record->field('021'));
	    ## this is just an assumption
	    &print_issn($record->field('022'));
	}
	else { ## assume marc21
	    &print_isbn($record->field('020'));
	    &print_issn($record->field('022'));
	}

	if ($intype eq "marc21") {
	    &print_loc_callno($record->field('050'));
	    &print_dewey($record->field('082'));
	}
	## else: unimarc, ukmarc do not seem to store call numbers?
     
	## publication info
	if ($intype eq "unimarc") {
	    &print_pubinfo($record->field('210'));
	}
	else { ## marc21, ukmarc
            if ($record->field('264')) {
                 &print_pubinfo($record->field('264'));
            }
            else {
            &print_pubinfo($record->field('260'));
            }
	}

	## 6XX fields contain KW candidates. We add all of them to a

    my @field_list;
    if ($intype eq "unimarc") {
        @field_list = ('600', '601', '602', '604', '605', '606','607', '608', '610', '615', '620', '660', '661', '670', '675', '676', '680', '686');
    } elsif ($intype eq "ukmarc") {
        @field_list = ('600', '610', '611', '630', '650', '651','653', '655', '660', '661', '668', '690', '691', '692', '695');
    } else { ## assume marc21
        @field_list = ('600', '610', '611', '630', '650', '651','653', '654', '655', '656', '657', '658');
    }

    my @kwpool;
    for my $f ( @field_list ) {
        my @fields = $record->field($f);
        push @kwpool, ( get_keywords("$f",$record->field($f)) );
    }

    # Remove duplicate
    @kwpool = uniq @kwpool;

    for my $kw ( @kwpool ) {
        print "KW  - ", &charconv($kw), "\r\n";
    }

	## 5XX have various candidates for notes and abstracts. We pool
	## all notes-like stuff in one list.
	my @notepool;

	## these fields have notes candidates
	if ($intype eq "unimarc") {
	    foreach ('300', '301', '302', '303', '304', '305', '306', '307', '308', '310', '311', '312', '313', '314', '315', '316', '317', '318', '320', '321', '322', '323', '324', '325', '326', '327', '328', '332', '333', '336', '337', '345') {
		&pool_subx(\@notepool, $_, $record->field($_));
	    }
	}
	elsif ($intype eq "ukmarc") {
	    foreach ('500', '501', '502', '503', '504', '505', '506', '508', '514', '515', '516', '521', '524', '525', '528', '530', '531', '532', '533', '534', '535', '537', '538', '540', '541', '542', '544', '554', '555', '556', '557', '561', '563', '580', '583', '584', '586') {
		&pool_subx(\@notepool, $_, $record->field($_));
        }
	}
	else { ## assume marc21
	    foreach ('500', '501', '502', '504', '505', '506', '507', '508', '510', '511', '513', '514', '515', '516', '518', '521', '522', '524', '525', '526', '530', '533', '534', '535') {
		&pool_subx(\@notepool, $_, $record->field($_));
	    }
	}

	my $allnotes = join "; ", @notepool;

	if (length($allnotes) > 0) {
	    print "N1  - ", &charconv($allnotes), "\r\n";
	}

	## 320/520 have the abstract
	if ($intype eq "unimarc") {
	    &print_abstract($record->field('320'));
	}
	elsif ($intype eq "ukmarc") {
	    &print_abstract($record->field('512'), $record->field('513'));
	}
	else { ## assume marc21
	    &print_abstract($record->field('520'));
	}
    
    # 856u has the URI
    if ($record->field('856')) {
        print_uri($record->field('856'));
    }

	## end RIS dataset
	print "ER  - \r\n";

    # Let's re-redirect stdout
    close STDOUT;
    open STDOUT, ">&", $oldout;
    
    return $outvar;

}


##********************************************************************
## print_typetag(): prints the first line of a RIS dataset including
## the preceeding newline
## Argument: the leader of a MARC dataset
## Returns: the value at leader position 06 
##********************************************************************
sub print_typetag {
  my ($leader)= @_;
    ## the keys of typehash are the allowed values at position 06
    ## of the leader of a MARC record, the values are the RIS types
    ## that might appropriately represent these types.
    my %ustypehash = (
		    "a" => "BOOK",
		    "c" => "MUSIC",
		    "d" => "MUSIC",
		    "e" => "MAP",
		    "f" => "MAP",
		    "g" => "ADVS",
		    "i" => "SOUND",
		    "j" => "SOUND",
		    "k" => "ART",
		    "m" => "DATA",
		    "o" => "GEN",
		    "p" => "GEN",
		    "r" => "ART",
		    "t" => "GEN",
		);
    
    my %unitypehash = (
		    "a" => "BOOK",
		    "b" => "BOOK",
		    "c" => "MUSIC",
		    "d" => "MUSIC",
		    "e" => "MAP",
		    "f" => "MAP",
		    "g" => "ADVS",
		    "i" => "SOUND",
		    "j" => "SOUND",
		    "k" => "ART",
		    "l" => "ELEC",
		    "m" => "ADVS",
		    "r" => "ART",
		);
    
    ## The type of a MARC record is found at position 06 of the leader
    my $typeofrecord = substr($leader, 6, 1);

    ## ToDo: for books, field 008 positions 24-27 might have a few more
    ## hints

    my %typehash;
    
    ## the ukmarc here is just a guess
    if ($intype eq "marc21" || $intype eq "ukmarc") {
	%typehash = %ustypehash;
    }
    elsif ($intype eq "unimarc") {
	%typehash = %unitypehash;
    }
    else {
	## assume MARC21 as default
	%typehash = %ustypehash;
    }

    if (!exists $typehash{$typeofrecord}) {
	print "TY  - BOOK\r\n"; ## most reasonable default
	warn ("no type found - assume BOOK") if $marcprint;
    }
    else {
	print "TY  - $typehash{$typeofrecord}\r\n";
    }

    ## use $typeofrecord as the return value, just in case
    $typeofrecord;
}

##********************************************************************
## normalize_author(): normalizes an authorname
## Arguments: authorname subfield a
##            authorname subfield b
##            authorname subfield c
##            name type if known: 0=direct order
##                               1=only surname or full name in
##                                 inverted order
##                               3=family, clan, dynasty name
## Returns: the normalized authorname
##********************************************************************
sub normalize_author {
    my($rawauthora, $rawauthorb, $rawauthorc, $nametype) = @_;

    if ($nametype == 0) {
	# ToDo: convert every input to Last[,(F.|First)[ (M.|Middle)[,Suffix]]]
	warn("name >>$rawauthora<< in direct order - leave as is") if $marcprint;
	return $rawauthora;
    }
    elsif ($nametype == 1) {
	## start munging subfield a (the real name part)
	## remove spaces after separators
	$rawauthora =~ s%([,.]+) *%$1%g;

	## remove trailing separators after spaces
	$rawauthora =~ s% *[,;:/]*$%%;

	## remove periods after a non-abbreviated name
	$rawauthora =~ s%(\w{2,})\.%$1%g;

	## start munging subfield b (something like the suffix)
	## remove trailing separators after spaces
	$rawauthorb =~ s% *[,;:/]*$%%;

	## we currently ignore subfield c until someone complains
	if (length($rawauthorb) > 0) {
	    return join ",", ($rawauthora, $rawauthorb);
	}
	else {
	    return $rawauthora;
	}
    }
    elsif ($nametype == 3) {
	return $rawauthora;
    }
}

##********************************************************************
## get_author(): gets authorname info from MARC fields 100, 700
## Argument: field (100 or 700)
## Returns: an author string in the format found in the record
##********************************************************************
sub get_author {
    my ($authorfield) = @_;
    my ($indicator);

    ## the sequence of the name parts is encoded either in indicator
    ## 1 (marc21) or 2 (unimarc)
    if ($intype eq "unimarc") {
	$indicator = 2;
    }
    else { ## assume marc21
	$indicator = 1;
    }

    print "<marc>:Author(Ind$indicator): ", $authorfield->indicator("$indicator"),"\r\n" if $marcprint;
    print "<marc>:Author(\$a): ", $authorfield->subfield('a'),"\r\n" if $marcprint;
    print "<marc>:Author(\$b): ", $authorfield->subfield('b'),"\r\n" if $marcprint;
    print "<marc>:Author(\$c): ", $authorfield->subfield('c'),"\r\n" if $marcprint;
    print "<marc>:Author(\$h): ", $authorfield->subfield('h'),"\r\n" if $marcprint;
    if ($intype eq "ukmarc") {
	my $authorname = $authorfield->subfield('a') . "," . $authorfield->subfield('h');
	normalize_author($authorname, $authorfield->subfield('b'), $authorfield->subfield('c'), $authorfield->indicator("$indicator"));
    }
    else {
	normalize_author($authorfield->subfield('a'), $authorfield->subfield('b'), $authorfield->subfield('c'), $authorfield->indicator("$indicator"));
    }
}

##********************************************************************
## get_editor(): gets editor info from MARC fields 110, 111, 710, 711
## Argument: field (110, 111, 710, or 711)
## Returns: an author string in the format found in the record
##********************************************************************
sub get_editor {
    my ($editorfield) = @_;

    if (!$editorfield) {
	return;
    }
    else {
	print "<marc>Editor(\$a): ", $editorfield->subfield('a'),"\r\n" if $marcprint;
	print "<marc>Editor(\$b): ", $editorfield->subfield('b'),"\r\n" if $marcprint;
	print "<marc>editor(\$c): ", $editorfield->subfield('c'),"\r\n" if $marcprint;
	return $editorfield->subfield('a');
    }
}

##********************************************************************
## print_title(): gets info from MARC field 245
## Arguments: field (245)
## Returns: 
##********************************************************************
sub print_title {
    my ($titlefield) = @_;
    if (!$titlefield) {
	print "<marc>empty title field (245)\r\n" if $marcprint;
	warn("empty title field (245)") if $marcprint;
    }
    else {
	print "<marc>Title(\$a): ",$titlefield->subfield('a'),"\r\n" if $marcprint;
	print "<marc>Title(\$b): ",$titlefield->subfield('b'),"\r\n" if $marcprint;
	print "<marc>Title(\$c): ",$titlefield->subfield('c'),"\r\n" if $marcprint;
    
	## The title is usually written in a very odd notation. The title
	## proper ($a) often ends with a space followed by a separator like
	## a slash or a colon. The subtitle ($b) doesn't start with a space
	## so simple concatenation looks odd. We have to conditionally remove
	## the separator and make sure there's a space between title and
	## subtitle

	my $clean_title = $titlefield->subfield('a');

	my $clean_subtitle = $titlefield->subfield('b');
	$clean_title =~ s% *[/:;.]$%%;
	$clean_subtitle =~ s%^ *(.*) *[/:;.]$%$1%;

	if (length($clean_title) > 0
	    || (length($clean_subtitle) > 0 && $intype ne "unimarc")) {
	    print "TI  - ", &charconv($clean_title);

	    ## subfield $b is relevant only for marc21/ukmarc
	    if (length($clean_subtitle) > 0 && $intype ne "unimarc") {
		print ": ",&charconv($clean_subtitle);
	    }
	    print "\r\n";
	}

	## The statement of responsibility is just this: horrors. There is
	## no formal definition how authors, editors and the like should
	## be written and designated. The field is free-form and resistant
	## to all parsing efforts, so this information is lost on me
    }
}

##********************************************************************
## print_stitle(): prints info from series title field
## Arguments: field 
## Returns: 
##********************************************************************
sub print_stitle {
    my ($titlefield) = @_;

    if (!$titlefield) {
	print "<marc>empty series title field\r\n" if $marcprint;
    }
    else {
	print "<marc>Series title(\$a): ",$titlefield->subfield('a'),"\r\n" if $marcprint;
	my $clean_title = $titlefield->subfield('a');

	$clean_title =~ s% *[/:;.]$%%;

	if (length($clean_title) > 0) {
	    print "T2  - ", &charconv($clean_title),"\r\n";
	}

	if ($intype eq "unimarc") {
	    print "<marc>Series vol(\$v): ",$titlefield->subfield('v'),"\r\n" if $marcprint;
	    if (length($titlefield->subfield('v')) > 0) {
		print "VL  - ", &charconv($titlefield->subfield('v')),"\r\n";
	    }
	}
    }
}

##********************************************************************
## print_isbn(): gets info from MARC field 020
## Arguments: field (020)
##********************************************************************
sub print_isbn {
    my($isbnfield) = @_;

    if (!$isbnfield || length ($isbnfield->subfield('a')) == 0) {
	print "<marc>no isbn found (020\$a)\r\n" if $marcprint;
	warn("no isbn found") if $marcprint;
    }
    else {
	if (length ($isbnfield->subfield('a')) < 10) {
	    print "<marc>truncated isbn (020\$a)\r\n" if $marcprint;
	    warn("truncated isbn") if $marcprint;
	}

	my $isbn = substr($isbnfield->subfield('a'), 0, 10);
	print "SN  - ", &charconv($isbn), "\r\n";
    }
}

##********************************************************************
## print_issn(): gets info from MARC field 022
## Arguments: field (022)
##********************************************************************
sub print_issn {
    my($issnfield) = @_;

    if (!$issnfield || length ($issnfield->subfield('a')) == 0) {
	print "<marc>no issn found (022\$a)\r\n" if $marcprint;
	warn("no issn found") if $marcprint;
    }
    else {
	if (length ($issnfield->subfield('a')) < 9) {
	    print "<marc>truncated issn (022\$a)\r\n" if $marcprint;
	    warn("truncated issn") if $marcprint;
	}

	my $issn = substr($issnfield->subfield('a'), 0, 9);
	print "SN  - ", &charconv($issn), "\r\n";
    }
}

###
# print_uri() prints info from 856 u 
###
sub print_uri {
    my @f856s = @_;

    foreach my $f856 (@f856s) {
        if (my $uri = $f856->subfield('u')) {
	        print "UR  - ", charconv($uri), "\r\n";
        }
    }
}

##********************************************************************
## print_loc_callno(): gets info from MARC field 050
## Arguments: field (050)
##********************************************************************
sub print_loc_callno {
    my($callnofield) = @_;

    if (!$callnofield || length ($callnofield->subfield('a')) == 0) {
	print "<marc>no LOC call number found (050\$a)\r\n" if $marcprint;
	warn("no LOC call number found") if $marcprint;
    }
    else {
	print "AV  - ", &charconv($callnofield->subfield('a')), " ", &charconv($callnofield->subfield('b')), "\r\n";
    }
}

##********************************************************************
## print_dewey(): gets info from MARC field 082
## Arguments: field (082)
##********************************************************************
sub print_dewey {
    my($deweyfield) = @_;

    if (!$deweyfield || length ($deweyfield->subfield('a')) == 0) {
	print "<marc>no Dewey number found (082\$a)\r\n" if $marcprint;
	warn("no Dewey number found") if $marcprint;
    }
    else {
	print "U1  - ", &charconv($deweyfield->subfield('a')), " ", &charconv($deweyfield->subfield('2')), "\r\n";
    }
}

##********************************************************************
## print_pubinfo(): gets info from MARC field 260
## Arguments: field (260)
##********************************************************************
sub print_pubinfo {
    my($pubinfofield) = @_;

    if (!$pubinfofield) {
    print "<marc>no publication information found (260/264)\r\n" if $marcprint;
	warn("no publication information found") if $marcprint;
    }
    else {
	## the following information is available in MARC21:
	## $a place -> CY
	## $b publisher -> PB
	## $c date -> PY
	## the corresponding subfields for UNIMARC:
	## $a place -> CY
	## $c publisher -> PB
	## $d date -> PY

	## all of them are repeatable. We pool all places into a
	## comma-separated list in CY. We also pool all publishers
	## into a comma-separated list in PB.  We break the rule with
	## the date field because this wouldn't make much sense. In
	## this case, we use the first occurrence for PY, the second
	## for Y2, and ignore the rest

	my @pubsubfields = $pubinfofield->subfields();
	my @cities;
	my @publishers;
	my $pycounter = 0;

	my $pubsub_place;
	my $pubsub_publisher;
	my $pubsub_date;

	if ($intype eq "unimarc") {
	    $pubsub_place = "a";
	    $pubsub_publisher = "c";
	    $pubsub_date = "d";
	}
	else { ## assume marc21
	    $pubsub_place = "a";
	    $pubsub_publisher = "b";
	    $pubsub_date = "c";
	}
	    
	## loop over all subfield list entries
	for my $tuple (@pubsubfields) {
	    ## each tuple consists of the subfield code and the value
	    if (@$tuple[0] eq $pubsub_place) {
		## strip any trailing crap
		$_ = @$tuple[1];
		s% *[,;:/]$%%;
		## pool all occurrences in a list
		push (@cities, $_);
	    }
	    elsif (@$tuple[0] eq $pubsub_publisher) {
		## strip any trailing crap
		$_ = @$tuple[1];
		s% *[,;:/]$%%;
		## pool all occurrences in a list
		push (@publishers, $_);
	    }
	    elsif (@$tuple[0] eq $pubsub_date) {
		## the dates are free-form, so we want to extract
		## a four-digit year and leave the rest as
		## "other info"
		$protoyear = @$tuple[1];
		print "<marc>Year (260\$c): $protoyear\r\n" if $marcprint;

		## strip any separator chars at the end
		$protoyear =~ s% *[\.;:/]*$%%;

		## isolate a four-digit year. We discard anything
		## preceeding the year, but keep everything after
		## the year as other info.
		$protoyear =~ s%\D*([0-9\-]{4})(.*)%$1///$2%;

		## check what we've got. If there is no four-digit
		## year, make it up. If digits are replaced by '-',
		## replace those with 0s

		if (index($protoyear, "/") == 4) {
		    ## have year info
		    ## replace all '-' in the four-digit year
		    ## by '0'
		    substr($protoyear,0,4) =~ s!-!0!g;
		}
		else {
		    ## have no year info
		    print "<marc>no four-digit year found, use 0000\r\n" if $marcprint;
		    $protoyear = "0000///$protoyear";
		    warn("no four-digit year found, use 0000") if $marcprint;
		}

		if ($pycounter == 0 && length($protoyear)) {
		    print "PY  - $protoyear\r\n";
		}
		elsif ($pycounter == 1 && length($_)) {
		    print "Y2  - $protoyear\r\n";
		}
		## else: discard
	    }
	    ## else: discard
	}

	## now dump the collected CY and PB lists
	if (@cities > 0) {
	    print "CY  - ", &charconv(join(", ", @cities)), "\r\n";
	}
	if (@publishers > 0) {
	    print "PB  - ", &charconv(join(", ", @publishers)), "\r\n";
	}
    }
}

##********************************************************************
## get_keywords(): prints info from MARC fields 6XX
## Arguments: list of fields (6XX)
##********************************************************************
sub get_keywords {
    my($fieldname, @keywords) = @_;

    my @kw;
    ## a list of all possible subfields
    my @subfields = ('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'x', 'y', 'z', '2', '3', '4');

    ## loop over all 6XX fields
    foreach my $kwfield (@keywords) {
	if ($kwfield != undef) {
	    ## authornames get special treatment
	    if ($fieldname eq "600") {
		my $val = normalize_author($kwfield->subfield('a'), $kwfield->subfield('b'), $kwfield->subfield('c'), $kwfield->indicator('1'));
        push @kw, $val;
		print "<marc>Field $kwfield subfield a:", $kwfield->subfield('a'), "\r\n<marc>Field $kwfield subfield b:", $kwfield->subfield('b'), "\r\n<marc>Field $kwfield subfield c:", $kwfield->subfield('c'), "\r\n" if $marcprint;
	    }
	    else {
		## retrieve all available subfields
		@kwsubfields = $kwfield->subfields();
		
		## loop over all available subfield tuples
        foreach my $kwtuple (@kwsubfields) {
		    ## loop over all subfields to check
            foreach my $subfield (@subfields) {
			## [0] contains subfield code
			if (@$kwtuple[0] eq $subfield) {
			    ## [1] contains value, remove trailing separators
			    @$kwtuple[1] =~ s% *[,;.:/]*$%%;
			    if (length(@$kwtuple[1]) > 0) {
                push @kw, @$kwtuple[1];
				print "<marc>Field $fieldname subfield $subfield:", @$kwtuple[1], "\r\n" if $marcprint;
			    }
			    ## we can leave the subfields loop here
			    last;
			}
		    }
		}
	    }
	}
    }
    return @kw;
}

##********************************************************************
## pool_subx(): adds contents of several subfields to a list
## Arguments: reference to a list
##            field name
##            list of fields (5XX)
##********************************************************************
sub pool_subx {
    my($aref, $fieldname, @notefields) = @_;

    ## we use a list that contains the interesting subfields
    ## for each field
    # ToDo: this is apparently correct only for marc21
    my @subfields;

    if ($fieldname eq "500") {
	@subfields = ('a');
    }
    elsif ($fieldname eq "501") {
	@subfields = ('a');
    }
    elsif ($fieldname eq "502") {
	@subfields = ('a');
	    }
    elsif ($fieldname eq "504") {
	@subfields = ('a', 'b');
    }
    elsif ($fieldname eq "505") {
	@subfields = ('a', 'g', 'r', 't', 'u');
    }
    elsif ($fieldname eq "506") {
	@subfields = ('a', 'b', 'c', 'd', 'e');
    }
    elsif ($fieldname eq "507") {
	@subfields = ('a', 'b');
    }
    elsif ($fieldname eq "508") {
	@subfields = ('a');
    }
    elsif ($fieldname eq "510") {
	@subfields = ('a', 'b', 'c', 'x', '3');
    }
    elsif ($fieldname eq "511") {
	@subfields = ('a');
    }
    elsif ($fieldname eq "513") {
	@subfields = ('a', 'b');
    }
    elsif ($fieldname eq "514") {
	@subfields = ('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'm', 'u', 'z');
    }
    elsif ($fieldname eq "515") {
	@subfields = ('a');
    }
    elsif ($fieldname eq "516") {
	@subfields = ('a');
    }
    elsif ($fieldname eq "518") {
	@subfields = ('a', '3');
    }
    elsif ($fieldname eq "521") {
	@subfields = ('a', 'b', '3');
    }
    elsif ($fieldname eq "522") {
	@subfields = ('a');
    }
    elsif ($fieldname eq "524") {
	@subfields = ('a', '2', '3');
    }
    elsif ($fieldname eq "525") {
	@subfields = ('a');
    }
    elsif ($fieldname eq "526") {
	@subfields = ('a', 'b', 'c', 'd', 'i', 'x', 'z', '5');
    }
    elsif ($fieldname eq "530") {
	@subfields = ('a', 'b', 'c', 'd', 'u', '3');
    }
    elsif ($fieldname eq "533") {
	@subfields = ('a', 'b', 'c', 'd', 'e', 'f', 'm', 'n', '3');
    }
    elsif ($fieldname eq "534") {
	@subfields = ('a', 'b', 'c', 'e', 'f', 'k', 'l', 'm', 'n', 'p', 't', 'x', 'z');
    }
    elsif ($fieldname eq "535") {
	@subfields = ('a', 'b', 'c', 'd', 'g', '3');
    }

    ## loop over all notefields
    foreach my $notefield (@notefields) {
	if ($notefield != undef) {
	    ## retrieve all available subfield tuples
	    @notesubfields = $notefield->subfields();

	    ## loop over all subfield tuples
        foreach my $notetuple (@notesubfields) {
		## loop over all subfields to check
        foreach my $subfield (@subfields) {
		    ## [0] contains subfield code
		    if (@$notetuple[0] eq $subfield) {
			## [1] contains value, remove trailing separators
			print "<marc>field $fieldname subfield $subfield: ", @$notetuple[1], "\r\n" if $marcprint;
			@$notetuple[1] =~ s% *[,;.:/]*$%%;
			if (length(@$notetuple[1]) > 0) {
			    ## add to list
			    push @{$aref}, @$notetuple[1];
			}
			last;
		    }
		}
	    }
	}
    }
}

##********************************************************************
## print_abstract(): prints abstract fields
## Arguments: list of fields (520)
##********************************************************************
sub print_abstract {
    # ToDo: take care of repeatable subfields
    my(@abfields) = @_;

    ## we check the following subfields
    my @subfields = ('a', 'b');

    ## we generate a list for all useful strings
    my @abstrings;

    ## loop over all abfields
    foreach my $abfield (@abfields) {
        foreach my $field (@subfields) {
            if ( length( $abfield->subfield($field) ) > 0 ) {
                my $ab = $abfield->subfield($field);

                print "<marc>field 520 subfield $field: $ab\r\n" if $marcprint;

                ## strip trailing separators
                $ab =~ s% *[;,:./]*$%%;

                ## add string to the list
                push( @abstrings, $ab );
            }
        }
    }

    my $allabs = join "; ", @abstrings;

    if (length($allabs) > 0) {
	print "N2  - ", &charconv($allabs), "\r\n";
    }

}

    
    
##********************************************************************
## charconv(): converts to a different charset based on a global var
## Arguments: string
## Returns: string
##********************************************************************
sub charconv {
    if ($utf) {
	## return unaltered if already utf-8
	return @_;
    }
    elsif ($uniout eq "t") {
	## convert to utf-8
	return marc8_to_utf8("@_");
    }
    else {
	## return unaltered if no utf-8 requested
	return @_;
    }
}
1;
