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
use Test::More tests => 10;
use C4::Context;

use C4::Circulation qw( TooMany AddIssue CanBookBeIssued );
use C4::Biblio;
use C4::Items;
use C4::Members;
use C4::Context;

use Koha::DateUtils qw( dt_from_string );
use Koha::Database;
use Koha::Checkouts;
use Koha::CirculationRules;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

our $dbh = C4::Context->dbh;

$dbh->do(q|DELETE FROM issues|);
$dbh->do(q|DELETE FROM circulation_rules|);

my $builder = t::lib::TestBuilder->new();

my $branch = $builder->build({
    source => 'Branch',
});

my $patron_category = $builder->build({ source => 'Category', value => { categorycode => 'NOT_X', category_type => 'P', enrolmentfee => 0 } });
my $patron = $builder->build_object({
    class => 'Koha::Patrons',
    value => {
        branchcode => $branch->{branchcode},
        debarred => undef,
        categorycode => $patron_category->{categorycode},
    },
});

my $item = $builder->build_sample_item(
    {
        library => $branch->{branchcode},
    }
);

Koha::CirculationRules->search()->delete();
Koha::CirculationRules->set_rules(
    {
        branchcode   => $branch->{branchcode},
        categorycode => undef,
        itemtype     => undef,
        rules        => {
            maxissueqty       => 2,
            maxonsiteissueqty => 1,
            lengthunit        => 'days',
            issuelength       => 5,
            hardduedate        => undef,
            hardduedatecompare => 0,
        }
    }
);

t::lib::Mocks::mock_userenv({ patron => $patron });

t::lib::Mocks::mock_preference('AllowTooManyOverride', 0);

# Add onsite checkout
C4::Circulation::AddIssue( $patron, $item->barcode, dt_from_string, undef, dt_from_string, undef, { onsite_checkout => 1 } );

my ( $impossible, $messages );
t::lib::Mocks::mock_preference('SwitchOnSiteCheckouts', 0);
( $impossible, undef, undef, $messages ) = C4::Circulation::CanBookBeIssued( $patron, $item->barcode );
is( $impossible->{NO_RENEWAL_FOR_ONSITE_CHECKOUTS}, 1, 'Do not renew on-site checkouts' );

t::lib::Mocks::mock_preference('SwitchOnSiteCheckouts', 1);
( $impossible, undef, undef, $messages ) = C4::Circulation::CanBookBeIssued( $patron, $item->barcode );
is( $messages->{ONSITE_CHECKOUT_WILL_BE_SWITCHED}, 1, 'If SwitchOnSiteCheckouts, switch the on-site checkout' );
is( exists $impossible->{TOO_MANY}, '', 'If SwitchOnSiteCheckouts, switch the on-site checkout' );
C4::Circulation::AddIssue( $patron, $item->barcode, undef, undef, undef, undef, { switch_onsite_checkout => 1 } );
my $issue = Koha::Checkouts->find( { itemnumber => $item->itemnumber } );
is( $issue->onsite_checkout, 0, 'The issue should have been switched to a regular checkout' );
my $five_days_after = dt_from_string->add( days => 5 )->set( hour => 23, minute => 59, second => 0 );
is( dt_from_string($issue->date_due, 'sql'), $five_days_after, 'The date_due should have been set depending on the circ rules when the on-site checkout has been switched' );

# Specific case
t::lib::Mocks::mock_preference('ConsiderOnSiteCheckoutsAsNormalCheckouts', 1);
my $another_item = $builder->build_sample_item(
    {
        biblionumber => $item->biblionumber,
        library      => $branch->{branchcode},
    }
);

C4::Circulation::AddIssue( $patron, $another_item->barcode, dt_from_string, undef, dt_from_string, undef, { onsite_checkout => 1 } );
( $impossible, undef, undef, $messages ) = C4::Circulation::CanBookBeIssued( $patron, $another_item->barcode );
is( $messages->{ONSITE_CHECKOUT_WILL_BE_SWITCHED}, 1, 'Specific case 1 - Switch is allowed' );
is( exists $impossible->{TOO_MANY}, '', 'Specific case 1 - Switch is allowed' );

my $yet_another_item = $builder->build_sample_item(
    {
        biblionumber => $item->biblionumber,
        library      => $branch->{branchcode},
    }
);

( $impossible, undef, undef, undef ) = C4::Circulation::CanBookBeIssued( $patron, $yet_another_item->barcode );
is( $impossible->{TOO_MANY}, 'TOO_MANY_CHECKOUTS', 'Not a specific case, $delta should not be incremented' );

Koha::CirculationRules->search()->delete();
Koha::CirculationRules->set_rules(
    {
        branchcode   => $branch->{branchcode},
        categorycode => undef,
        itemtype     => undef,
        rules        => {
            maxissueqty       => 2,
            maxonsiteissueqty => 1,
        }
    }
);
( $impossible, undef, undef, $messages ) = C4::Circulation::CanBookBeIssued( $patron, $another_item->barcode );
is( $messages->{ONSITE_CHECKOUT_WILL_BE_SWITCHED}, 1, 'Specific case 2 - Switch is allowed' );
is( exists $impossible->{TOO_MANY}, '', 'Specific case 2 - Switch is allowed' );

$schema->storage->txn_rollback;

