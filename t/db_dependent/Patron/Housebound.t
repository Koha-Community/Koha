#!/usr/bin/perl
use Modern::Perl;

use C4::Members;
use C4::Circulation;
use Koha::Database;
use Koha::Patrons;

use Test::More tests => 6;

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

# patron_choosers and patron_deliverers Tests

# Current Patron Chooser / Deliverer count
my $orig_del_count = Koha::Patrons->housebound_deliverers->count;
my $orig_cho_count = Koha::Patrons->housebound_choosers->count;

# We add one, just in case the above is 0, so we're guaranteed one of each.
my $patron_chooser = $builder->build({ source => 'Borrower' });
$builder->build({
    source => 'BorrowerAttribute',
    value  => {
        borrowernumber => $patron_chooser->{borrowernumber},
        code           => 'HSBND',
        attribute      => 'CHO',
        password       => undef,
    },
});

my $patron_deliverer = $builder->build({ source => 'Borrower' });
$builder->build({
    source => 'BorrowerAttribute',
    value  => {
        borrowernumber => $patron_deliverer->{borrowernumber},
        code           => 'HSBND',
        attribute      => 'DEL',
        password       => undef,
    },
});

# Test housebound_choosers
is(Koha::Patrons->housebound_choosers->count, $orig_cho_count + 1, "Correct count of choosers.");
is(Koha::Patrons->housebound_deliverers->count, $orig_del_count + 1, "Correct count of deliverers");

isa_ok(Koha::Patrons->housebound_choosers->next, "Koha::Patron");
isa_ok(Koha::Patrons->housebound_deliverers->next, "Koha::Patron");

$schema->storage->txn_rollback;

1;
