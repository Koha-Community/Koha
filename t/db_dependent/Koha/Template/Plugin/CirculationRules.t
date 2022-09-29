#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 8;

use C4::Context;
use C4::Circulation qw(AddIssue);
use Koha::Database;
use Koha::CirculationRules;

use t::lib::TestBuilder;
use t::lib::Mocks;

BEGIN {
    use_ok('Koha::Template::Plugin::CirculationRules');
}

my $schema  = Koha::Database->schema;
my $builder = t::lib::TestBuilder->new;

$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;

$dbh->do('DELETE FROM circulation_rules');
Koha::CirculationRules->set_rules(
    {
        categorycode => undef,
        branchcode   => undef,
        itemtype     => undef,
        rules        => {
            reservesallowed         => 25,
            issuelength             => 14,
            lengthunit              => 'days',
            renewalsallowed         => 1,
            renewalperiod           => 7,
            norenewalbefore         => undef,
            auto_renew              => 0,
            fine                    => .10,
            chargeperiod            => 1,
            renewalsallowed         => 111,
            unseen_renewals_allowed => 222,
        }
    }
);

my $plugin = Koha::Template::Plugin::CirculationRules->new();
ok( $plugin, "initialized CirculationRules plugin" );

my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
my $biblio = $builder->build_sample_biblio();

t::lib::Mocks::mock_userenv( { branchcode => $patron->branchcode } );

# Item at each patron branch
my $item = $builder->build_sample_item(
    {
        biblionumber => $biblio->biblionumber,
        homebranch   => $patron->branchcode
    }
);

my $issue = AddIssue( $patron, $item->barcode );

my $rules = $plugin->Renewals( $patron->id, $item->id );

is( $rules->{unseen_allowed},   222, "Unseen allowed is correct" );
is( $rules->{remaining},        111, "Remaining is correct" );
is( $rules->{unseen_count},     0,   "Unseen count is correct" );
is( $rules->{unseen_remaining}, 222, "Unseen remaining is correct" );
is( $rules->{count},            0,   "Count renewals is correct" );
is( $rules->{allowed},          111, "Allowed is correct" );

$schema->storage->txn_rollback;

1;
