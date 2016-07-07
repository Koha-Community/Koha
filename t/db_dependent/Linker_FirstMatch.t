#!/usr/bin/perl
#
# This file is part of Koha.
#
# Copyright (C) 2011  Jared Camins-Esakov <jcamins@cpbibliography.com>
# Copyright (C) 2016  Mark Tompsett <mtompset@hotmail.com>
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

use MARC::Record;
use MARC::Field;
use MARC::File::XML;
use C4::Heading;
use C4::Linker::FirstMatch;
use Test::MockModule;
use t::lib::Mocks qw( mock_preference );
use t::lib::TestBuilder;

BEGIN {
    use_ok('C4::Linker');
}

# Mock C4::Heading->authorities() so tests will all pass.
# This completely bypasses any search engine calls.
my $authid;
my $mock_heading = Test::MockModule->new('C4::Heading');
$mock_heading->mock( authorities => sub { return [ { authid => $authid } ]; } );

# Run tests for both logic cases (UNIMARC / non-UNIMARC)
subtest 'MARC21' => sub {
    plan tests => 2;
    t::lib::Mocks::mock_preference( 'marcflavour', 'MARC21' );
    run_tests();
};

subtest 'UNIMARC' => sub {
    plan tests => 2;
    t::lib::Mocks::mock_preference( 'marcflavour', 'UNIMARC' );
    run_tests();
};

sub run_tests {

    # Set up just a single authority record to find and use.
    my $builder = t::lib::TestBuilder->new();
    my $schema  = $builder->schema();
    $schema->storage->txn_begin;

    $builder->delete( { source => 'AuthHeader' } );

    my $auth_header = $builder->build(
        {
            source => 'AuthHeader'
        }
    );

    $authid = $auth_header->{authid};

    # Set the data up to match nicely.
    my $marc_flavour = C4::Context->preference('MARCFlavour');
    my $auth         = get_authority_record( $marc_flavour, $authid );
    my $fake_marc    = $auth->as_usmarc();
    my $fake_xml     = $auth->as_xml($authid);

    my $auth_header_record = $schema->resultset('AuthHeader')->find(
        {
            authid => $authid
        }
    );
    $auth_header_record->marcxml($fake_xml);
    $auth_header_record->marc($fake_marc);
    $auth_header_record->update;

    # Find a particular series field.
    my $fieldmatch;
    if ( C4::Context->preference('MARCFlavour') eq 'UNIMARC' ) {
        $fieldmatch = '2..';
    }
    else {
        $fieldmatch = '1..';
    }
    my $bibfield = $auth->field($fieldmatch);

    # Convert it to a 6xx series field.
    my $tag     = $bibfield->tag();
    my $new_tag = $tag;
    $new_tag =~ s/^./6/xsm;
    my @subfields    = $bibfield->subfields();
    my $new_bibfield = MARC::Field->new(
        $new_tag,
        $bibfield->indicator(1),
        $bibfield->indicator(2), @subfields
    );

    # Can we build a heading from it?
    my $heading;
    ok(
        defined(
            $heading = C4::Heading->new_from_bib_field( $new_bibfield, q{} )
        ),
        'Creating heading from bib field'
    );

    # Now test to see if C4::Linker can find it.
    my $authmatch;
    my $fuzzy;
    my $linker = C4::Linker::FirstMatch->new();
    ( $authmatch, $fuzzy ) = $linker->get_link($heading);
    is( $authmatch, $authid, 'Matched existing heading' );

    $schema->storage->txn_rollback;

    return;
}

sub get_authority_record {
    my ( $marc_flavour, $auth_id ) = @_;
    my $main_heading_field = ( $marc_flavour eq 'UNIMARC' ) ? '200' : '100';
    my $auth = MARC::Record->new();
    $auth->append_fields(
        MARC::Field->new( '001', $auth_id ),
        MARC::Field->new(
            $main_heading_field, q{ }, q{ },
            a => 'Geisel, Theodor Seuss,',
            d => '1904-1991'
        )
    );
    return $auth;
}
