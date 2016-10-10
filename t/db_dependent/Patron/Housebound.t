#!/usr/bin/perl
use Modern::Perl;

use C4::Members;
use C4::Circulation;
use Koha::Database;
use Koha::Patrons;

use Test::More tests => 2;

use_ok('Koha::Patron');

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;

my $patron = $builder->build({ source => 'Borrower' });
my $profile = $builder->build({
    source => 'HouseboundProfile',
    value  => {
        borrowernumber => $patron->{borrowernumber},
    },
});

# Test housebound_profile
is(
    Koha::Patrons->find($patron->{borrowernumber})
          ->housebound_profile->frequency,
    $profile->{frequency},
    "Fetch housebound_profile."
);

$schema->storage->txn_rollback;

1;
