#!/usr/bin/perl
## Exports bibliographic data from Koha to an ISO2709 (MARC or UNIMARC)
## or MARCXML file
# Copyright 2006 (C) Metavore Inc.
# Joshua Ferraro <jmf@liblime.com>
#
# use perldoc export.pl for nicely formatted documentation

=head1 NAME

export.pl - export bibliographic data from Koha to an ISO2709 or MARCXML file.

=head1 SYNOPSIS

./export.pl --format=MARCXML --encoding=UTF-8 --ignoreerrors

=head1 PREREQUISITES

Koha - (http://koha.org) :-)

MARC::File::XML - version 0.83 or greater

MARC::Record - version 2.0RC1 or greater available from Sourceforge

=head1 TODO

handle UNIMARC encodings using new MARC::File::XML settings

=cut 

use strict; use warnings;
use C4::Biblio;
use C4::Auth;
use Getopt::Long;

use MARC::Record;
use MARC::Batch;
use MARC::File::XML;
use MARC::Charset;

my $USAGE = "
USAGE: export.pl -[options]

Exports bibliographic data from Koha to an ISO2709 or MARCXML file.

OPTIONS:
 -format <format>    MARC, MARCXML [MARC]
 -e <encoding>       MARC-8 or UTF-8 [UTF-8]
 -ignoreerrors       Ignore encoding errors 
 -assumeunicode      Assume Unicode when unsure of encoding
 -file <filename>    Filename to store dump [koha.mrc]
 -h                  This file

EXAMPLES: 
\$ ./export.pl --format=MARCXML --encoding=UTF-8 -file=2005-05-23-koha.mrc --ignoreerrors

";

my $VERSION = '.02';

# get the command-line options
my ($format,$encoding,$ignoreerrors,$assumeunicode,$outfile,$help) = ('MARC','UTF-8','','','koha.mrc','');
GetOptions(
	'format:s' 		=> \$format,
	'encoding:s'		=> \$encoding,
	ignoreerrors		=> \$ignoreerrors,
	assumeunicode		=> \$assumeunicode,
	'outfile:s'		=> \$outfile,
	h					=> \$help,
);
if ($help) {die $USAGE};

# open our filehandle, if UTF-8, set the utf8 flag for Perl
if ((!$encoding) || (lc($encoding) =~ /^utf-?8$/o)) {
	open (OUT,">utf8",$outfile);
} else {
	open(OUT,">$outfile") or die $!;
}

# set the MARC::Charset flags specified by user
if ($ignoreerrors) {
	MARC::Charset->ignore_errors(1);
}
if ($assumeunicode) {
	MARC::Charset->assume_unicode(1);
}

# open a coneection to the db
my $dbh=C4::Context->dbh;
my $sth=$dbh->prepare("select bibid from marc_biblio order by bibid");
$sth->execute();
while (my ($bibid) = $sth->fetchrow) {
	my $record = MARCgetbiblio($dbh,$bibid);
	if ((!$format) || (lc($format) =~ /^marc$/o)) { # plain ole binary MARC
		if (lc($encoding) =~ /^utf-?8$/o) {
			my $xml = $record->as_xml_record();
			my $newrecord = MARC::Record::new_from_xml($xml,$encoding);
			print OUT $newrecord->as_usmarc();
		} else {
			print OUT $record->as_usmarc();
		}
	} elsif (lc($format) =~ /^marc-?xml$/o) { # MARCXML format
		my $xml = $record->as_xml_record($encoding);
		print OUT $xml;
	}
}
close(OUT);
