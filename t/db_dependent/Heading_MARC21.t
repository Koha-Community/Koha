#!/usr/bin/perl
#
# This Koha test module is a stub!  
# Add more tests here!!!

use strict;
use warnings;

use Test::More tests => 10;
use C4::Context;

BEGIN {
        use_ok('C4::Heading', qw( field new_from_field display_form search_form ));
}

SKIP: {
    skip "MARC21 heading tests not applicable to UNIMARC", 2 if C4::Context->preference('marcflavour') eq 'UNIMARC';
    my $field = MARC::Field->new( '650', ' ', '2', a => 'Uncles', x => 'Fiction' );
    my $heading = C4::Heading->new_from_field($field);
    is($heading->display_form(), 'Uncles--Fiction', 'Display form generation');
    is($heading->search_form(), 'Uncles generalsubdiv Fiction', 'Search form generation');
    is($heading->{thesaurus}, 'mesh', 'Thesaurus generation');

    $field = MARC::Field->new( '830', ' ', '4', a => 'The dark is rising ;', v => '3' );
    $heading = C4::Heading->new_from_field($field);
    is($heading->display_form(), 'The dark is rising ;', 'Display form generation');
    is($heading->search_form(), 'The dark is rising', 'Search form generation');
    ok( !defined $heading->{thesaurus}, 'Thesaurus is not generated outside of 6XX fields');

    $field = MARC::Field->new( '100', '1', '', a => 'Yankovic, Al', d => '1959-' );
    $heading = C4::Heading->new_from_field($field);
    is($heading->display_form(), 'Yankovic, Al 1959-', 'Display form generation');
    is($heading->search_form(), 'Yankovic, Al 1959', 'Search form generation');
    ok( !defined $heading->{thesaurus}, 'Thesaurus is not generated outside of 6XX fields');

}
