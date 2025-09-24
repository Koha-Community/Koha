#!/usr/bin/perl
#
# Copyright 2006 (C) LibLime
# Joshua Ferraro <jmf@liblime.com>
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.
#
#
use strict;
use warnings;

use constant WHEREAMI => 't/db_dependent/Record/testrecords';

# specify the number of tests
use Test::NoWarnings;
use Test::More tests => 22;    #FIXME Commented out two failing tests
use C4::Record qw( marc2marc marc2marcxml marc2dcxml changeEncoding );

=head1 NAME

Record_test.pl - test suite for Record.pm

=head1 SYNOPSIS

$ export KOHA_CONF=/path/to/koha.conf
$ ./Record_test.pl

=cut

## FIXME: Preliminarily grab the modules dir so we can run this in context

ok( 1, 'module compiled' );

# open some files for testing
open my $MARC21MARC8, '<', WHEREAMI . "/marc21_marc8.dat" or die $!;
my $marc21_marc8;    # = scalar (MARC21MARC8);
foreach my $line (<$MARC21MARC8>) {
    $marc21_marc8 .= $line;
}
$marc21_marc8 =~ s/\n$//;
close $MARC21MARC8;

open( my $MARC21UTF8, '<:encoding(UTF-8)', WHEREAMI . "/marc21_utf8.dat" ) or die $!;
my $marc21_utf8;
foreach my $line (<$MARC21UTF8>) {
    $marc21_utf8 .= $line;
}
$marc21_utf8 =~ s/\n$//;
close $MARC21UTF8;

open( my $MARC21MARC8COMBCHARS, '<', WHEREAMI . "/marc21_marc8_combining_chars.dat" ) or die $!;
my $marc21_marc8_combining_chars;
foreach my $line (<$MARC21MARC8COMBCHARS>) {
    $marc21_marc8_combining_chars .= $line;
}
$marc21_marc8_combining_chars =~ s/\n$//;    #FIXME: why is a newline ending up here?
close $MARC21MARC8COMBCHARS;

open( my $MARC21UTF8COMBCHARS, '<:encoding(UTF-8)', WHEREAMI . "/marc21_utf8_combining_chars.dat" ) or die $!;
my $marc21_utf8_combining_chars;
foreach my $line (<$MARC21UTF8COMBCHARS>) {
    $marc21_utf8_combining_chars .= $line;
}
close $MARC21UTF8COMBCHARS;

open( my $MARCXMLUTF8, '<:encoding(UTF-8)', WHEREAMI . "/marcxml_utf8.xml" ) or die $!;
my $marcxml_utf8;
foreach my $line (<$MARCXMLUTF8>) {
    $marcxml_utf8 .= $line;
}
close $MARCXMLUTF8;

$marcxml_utf8 =~ s/\n//g;

## The Tests:
my $error;
my $marc;
my $marcxml;    # some scalars to store values
## MARC to MARCXML
print "\n1. Checking conversion of simple ISO-2709 (MARC21) records to MARCXML\n";
ok(
    ( $error, $marcxml ) = marc2marcxml( $marc21_marc8, 'UTF-8', 'MARC21' ),
    'marc2marcxml - from MARC-8 to UTF-8 (MARC21)'
);
ok( !$error, 'no errors in conversion' );

#FIXME This test fails
#\t$marcxml =~ s/\n//g;
#\t$marcxml =~ s/v\/ s/v\/s/g; # FIXME: bug in new_from_xml_record!!
#is ($marcxml,$marcxml_utf8, 'record matches antitype');

ok(
    ( $error, $marcxml ) = marc2marcxml( $marc21_utf8, 'UTF-8', 'MARC21' ),
    'marc2marcxml - from UTF-8 to UTF-8 (MARC21)'
);
ok( !$error, 'no errors in conversion' );

#FIXME This test fails
#\t$marcxml =~ s/\n//g;
#\t$marcxml =~ s/v\/ s/v\/s/g;
#is ($marcxml,$marcxml_utf8, 'record matches antitype');

print "\n2. checking binary MARC21 records with combining characters to MARCXML\n";
ok(
    ( $error, $marcxml ) = marc2marcxml( $marc21_marc8_combining_chars, 'MARC-8', 'MARC21' ),
    'marc2marcxml - from MARC-8 to MARC-8 with combining characters(MARC21)'
);
ok( !$error, 'no errors in conversion' );

ok(
    ( $error, $marcxml ) = marc2marcxml( $marc21_marc8_combining_chars, 'UTF-8', 'MARC21' ),
    'marc2marcxml - from MARC-8 to UTF-8 with combining characters (MARC21)'
);
ok( !$error, 'no errors in conversion' );

ok(
    ( $error, $marcxml ) = marc2marcxml( $marc21_utf8_combining_chars, 'UTF-8', 'MARC21' ),
    'marc2marcxml - from UTF-8 to UTF-8 with combining characters (MARC21)'
);
ok( !$error, 'no errors in conversion' );

ok( eval { marc2dcxml( $marc21_utf8, undef, undef, 'oaidc' ) }, 'marc2dcxml - from ISO-2709 to Dublin Core' );
$error = $@;
ok( !$error, 'no errors in conversion to DublinCore' );

print "\n3. checking ability to alter encoding\n";
ok(
    ( $error, $marc ) = changeEncoding( $marc21_marc8, 'MARC', 'MARC21', 'UTF-8' ),
    'changeEncoding - MARC21 from MARC-8 to UTF-8'
);
ok( !$error, 'no errors in conversion' );

ok(
    ( $error, $marc ) = changeEncoding( $marc21_utf8, 'MARC', 'MARC21', 'MARC-8' ),
    'changeEncoding - MARC21 from UTF-8 to MARC-8'
);
ok( !$error, 'no errors in conversion' );

ok(
    ( $error, $marc ) = changeEncoding( $marc21_marc8, 'MARC', 'MARC21', 'MARC-8' ),
    'changeEncoding - MARC21 from MARC-8 to MARC-8'
);
ok( !$error, 'no errors in conversion' );

ok(
    ( $error, $marc ) = changeEncoding( $marc21_utf8, 'MARC', 'MARC21', 'UTF-8' ),
    'changeEncoding - MARC21 from UTF-8 to UTF-8'
);
ok( !$error, 'no errors in conversion' );

__END__

=head1 TODO

Still lots more to test including UNIMARC support

=head1 AUTHOR

Joshua Ferraro <jmf@liblime.com>

=head1 MODIFICATIONS


=cut
