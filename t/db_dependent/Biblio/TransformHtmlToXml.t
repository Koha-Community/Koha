#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 4;
use XML::Simple;

use C4::Biblio qw/TransformHtmlToXml/;

my $tags= [ '001', '100',  '245', '245' ];
my $subfields = [ '', 'a', 'a', 'c' ];
my $values = [ '12345', 'author', 'title', 'resp' ];
my $ind = [ '  ', '00', ' 9', '  ' ];

my $xml = TransformHtmlToXml( $tags, $subfields, $values, $ind, undef, 'MARC21' );
my $xmlh = XML::Simple->new->XMLin( $xml );

# check number of controlfields
is( ref $xmlh->{record}->{controlfield}, 'HASH', 'One controlfield' );
# check datafields
my $cnt = @{$xmlh->{record}->{datafield}};
is( $cnt, 2, 'Two datafields' );
# check value of 245c
is( $xmlh->{record}->{datafield}->[1]->{subfield}->[1]->{content}, 'resp', 'Check value' );
# check second indicator of 245
is( $xmlh->{record}->{datafield}->[1]->{ind2}, '9', 'Check indicator' );
