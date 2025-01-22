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

use Test::NoWarnings;
use Test::More tests => 8;

use t::lib::TestBuilder;
use t::lib::Mocks;

use C4::Circulation qw( CanBookBeIssued );
use Koha::Account;
use Koha::Account::Lines;
use Koha::Account::Offsets;
use Koha::Patron::Relationship;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new();

my $item = $builder->build_sample_item;

my $patron_category = $builder->build(
    {
        source => 'Category',
        value  => {
            categorycode   => 'NOT_X', category_type => 'P', enrolmentfee => 0, noissueschargeguarantees => 0,
            noissuescharge => 0,       noissueschargeguarantorswithguarantees => 0
        }
    }
);
my $patron = $builder->build_object(
    {
        class => 'Koha::Patrons',
        value => {
            categorycode => $patron_category->{categorycode},
        }
    }
);

my $guarantee = $builder->build_object(
    {
        class => 'Koha::Patrons',
        value => {
            categorycode => $patron_category->{categorycode},
        }
    }
);

my $r = $builder->build_object(
    {
        class => 'Koha::Patron::Relationships',
        value => {
            guarantor_id => $patron->id,
            guarantee_id => $guarantee->id,
            relationship => 'parent',
        }
    }
);

t::lib::Mocks::mock_preference( 'NoIssuesChargeGuarantees', '5.00' );
t::lib::Mocks::mock_preference( 'AllowFineOverride',        '' );

my ( $issuingimpossible, $needsconfirmation ) = CanBookBeIssued( $patron, $item->barcode );
is( $issuingimpossible->{DEBT_GUARANTEES}, undef, "Patron can check out item" );

my $account = Koha::Account->new( { patron_id => $guarantee->id } );
$account->add_debit( { amount => 10.00, type => 'LOST', interface => 'test' } );
( $issuingimpossible, $needsconfirmation ) = CanBookBeIssued( $patron, $item->barcode );
is( $issuingimpossible->{DEBT_GUARANTEES} + 0, '10.00' + 0, "Patron cannot check out item due to debt for guarantee" );

$patron->category->noissueschargeguarantees(11);
( $issuingimpossible, $needsconfirmation ) = CanBookBeIssued( $patron, $item->barcode );
is(
    $issuingimpossible->{DEBT_GUARANTEES}, undef,
    "Patron can check out item as the patron category limit is now higher than 10"
);

my $accountline = Koha::Account::Lines->search( { borrowernumber => $guarantee->id } )->next();
is( $accountline->amountoutstanding + 0, 10,     "Found 10.00 amount outstanding" );
is( $accountline->debit_type_code,       "LOST", "Debit type is LOST" );

my $offset = Koha::Account::Offsets->search( { debit_id => $accountline->id } )->next();
is( $offset->type,       'CREATE', 'Got CREATE offset type' );
is( $offset->amount + 0, 10,       'Got amount of $10.00' );

$schema->storage->txn_rollback;

