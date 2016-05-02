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

use Test::More tests => 2;

use t::lib::TestBuilder;

use C4::Accounts qw( manualinvoice );
use C4::Circulation qw( CanBookBeIssued );

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new();

my $item = $builder->build(
    {
        source => 'Item',
        value  => {
            notforloan => 0,
            withdrawn  => 0
        }
    }
);

my $patron = $builder->build(
    {
        source => 'Borrower',
    }
);
my $guarantee = $builder->build(
    {
        source => 'Borrower',
        value  => {
            guarantorid => $patron->{borrowernumber},
        }
    }
);

C4::Context->set_preference( 'NoIssuesChargeGuarantees', '5.00' );

my ( $issuingimpossible, $needsconfirmation ) = CanBookBeIssued( $patron, $item->{barcode} );
is( $issuingimpossible->{DEBT_GUARANTEES}, undef, "Patron can check out item" );

manualinvoice( $guarantee->{borrowernumber}, undef, undef, 'L', 10.00 );
( $issuingimpossible, $needsconfirmation ) = CanBookBeIssued( $patron, $item->{barcode} );
is( $issuingimpossible->{DEBT_GUARANTEES} + 0, '10.00' + 0, "Patron cannot check out item due to debt for guarantee" );

$schema->storage->txn_rollback;

1;
