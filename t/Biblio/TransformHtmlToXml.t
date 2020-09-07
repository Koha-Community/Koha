#!/usr/bin/perl

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

use Modern::Perl;

use Test::More tests => 3;
use t::lib::Mocks;

use XML::Simple;

use C4::Biblio qw/TransformHtmlToXml/;


sub run_tests {

    my ($marc_flavour) = @_;

    t::lib::Mocks::mock_preference('marcflavour', $marc_flavour);

    my ( $tags, $subfields );
    if ( $marc_flavour eq 'UNIMARC' ) {
        $tags= [ '001', '600',  '200', '200', '400' ];
        $subfields = [ '', 'a', 'a', 'c', 'a' ];
    } else {
        $tags= [ '001', '100',  '245', '245', '400' ];
        $subfields = [ '', 'a', 'a', 'c', 'a' ];
    }
    my $values = [ '12345', 'author', 'title', 'resp', '' ];
    my $ind = [ '  ', '00', ' 9', '  ', ' ' ];

    my $xml = TransformHtmlToXml( $tags, $subfields, $values, $ind, undef, $marc_flavour );
    my $xmlh = XML::Simple->new->XMLin( $xml );

    # check number of controlfields
    is( ref $xmlh->{record}->{controlfield}, 'HASH', 'One controlfield' );
    # check datafields
    my $cnt = @{$xmlh->{record}->{datafield}};
    if ( $marc_flavour eq 'UNIMARC' ) {
        is( $cnt, 3, 'Three datafields' ); # 100$a is automatically created
    } else {
        is( $cnt, 2, 'Two datafields' );
    }
    # check value of 245c
    is( $xmlh->{record}->{datafield}->[1]->{subfield}->[1]->{content}, 'resp', 'Check value' );
    # check second indicator of 245
    is( $xmlh->{record}->{datafield}->[1]->{ind2}, '9', 'Check indicator' );
}

subtest "->TransformHtmlToXml (MARC21) tests" => sub {

    plan tests => 4;
    run_tests('MARC21');
};

subtest "->TransformHtmlToXml (UNIMARC) tests" => sub {

    plan tests => 4;
    run_tests('UNIMARC');
};

subtest "->TransformHtmlToXml (NORMARC) tests" => sub {
    plan tests => 4;
    run_tests('NORMARC');
};

