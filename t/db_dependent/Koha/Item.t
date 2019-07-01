#!/usr/bin/perl

# Copyright 2019 Koha Development team
#
# This file is part of Koha
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

use C4::Biblio;

use Koha::Items;
use Koha::Database;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'hidden_in_opac() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $item  = $builder->build_sample_item({ itemlost => 2 });
    my $rules = {};

    # disable hidelostitems as it interteres with OpachiddenItems for the calculation
    t::lib::Mocks::mock_preference( 'hidelostitems', 0 );

    ok( !$item->hidden_in_opac, 'No rules passed, shouldn\'t hide' );
    ok( !$item->hidden_in_opac({ rules => $rules }), 'Empty rules passed, shouldn\'t hide' );

    # enable hidelostitems to verify correct behaviour
    t::lib::Mocks::mock_preference( 'hidelostitems', 1 );
    ok( $item->hidden_in_opac, 'Even with no rules, item should hide because of hidelostitems syspref' );

    # disable hidelostitems
    t::lib::Mocks::mock_preference( 'hidelostitems', 0 );
    my $withdrawn = $item->withdrawn + 1; # make sure this attribute doesn't match

    $rules = { withdrawn => [$withdrawn], itype => [ $item->itype ] };

    ok( $item->hidden_in_opac({ rules => $rules }), 'Rule matching itype passed, should hide' );



    $schema->storage->txn_rollback;
};

subtest 'has_pending_hold() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $dbh = C4::Context->dbh;
    my $item  = $builder->build_sample_item({ itemlost => 0 });
    my $itemnumber = $item->itemnumber;

    # disable AllowItemsOnHoldCheckout as it ignores pending holds
    $dbh->do("INSERT INTO tmp_holdsqueue (surname,borrowernumber,itemnumber) VALUES ('Clamp',42,$itemnumber)");
    ok( $item->has_pending_hold, "Yes, we have a pending hold");
    $dbh->do("DELETE FROM tmp_holdsqueue WHERE itemnumber=$itemnumber");
    ok( !$item->has_pending_hold, "We don't have a pending hold if nothing in the tmp_holdsqueue");

    $schema->storage->txn_rollback;
};

subtest "as_marc_field() tests" => sub {

    my $mss = C4::Biblio::GetMarcSubfieldStructure( '', { unsafe => 1 } );

    my @schema_columns = $schema->resultset('Item')->result_source->columns;
    my @mapped_columns = grep { exists $mss->{'items.'.$_} } @schema_columns;

    plan tests => 2 * (scalar @mapped_columns + 1) + 1;

    $schema->storage->txn_begin;

    my $item = $builder->build_sample_item;

    # Tests with the mss parameter
    my $marc_field = $item->as_marc_field({ mss => $mss });

    is(
        $marc_field->tag,
        $mss->{'items.itemnumber'}[0]->{tagfield},
        'Generated field set the right tag number'
    );

    foreach my $column ( @mapped_columns ) {
        my $tagsubfield = $mss->{ 'items.' . $column }[0]->{tagsubfield};
        is( $marc_field->subfield($tagsubfield),
            $item->$column, "Value is mapped correctly for column $column" );
    }

    # Tests without the mss parameter
    $marc_field = $item->as_marc_field();

    is(
        $marc_field->tag,
        $mss->{'items.itemnumber'}[0]->{tagfield},
        'Generated field set the right tag number'
    );

    foreach my $column (@mapped_columns) {
        my $tagsubfield = $mss->{ 'items.' . $column }[0]->{tagsubfield};
        is( $marc_field->subfield($tagsubfield),
            $item->$column, "Value is mapped correctly for column $column" );
    }

    my $unmapped_subfield = Koha::MarcSubfieldStructure->new(
        {
            frameworkcode => '',
            tagfield      => $mss->{'items.itemnumber'}[0]->{tagfield},
            tagsubfield   => 'X',
        }
    )->store;

    $mss = C4::Biblio::GetMarcSubfieldStructure( '', { unsafe => 0 } );
    my @unlinked_subfields;
    push @unlinked_subfields, X => 'Something weird';
    $item->more_subfields_xml( C4::Items::_get_unlinked_subfields_xml( \@unlinked_subfields ) )->store;

    $marc_field = $item->as_marc_field;
    is( scalar $marc_field->subfield('X'), 'Something weird', 'more_subfield_xml is considered' );

    $schema->storage->txn_rollback;
};
