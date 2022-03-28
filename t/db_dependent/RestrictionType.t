#!/usr/bin/perl

use Modern::Perl;

use C4::Context;
use Koha::Database;
use t::lib::TestBuilder;

use Test::More tests => 3;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;
my $builder = t::lib::TestBuilder->new;

use_ok('Koha::RestrictionType');
use_ok('Koha::RestrictionTypes');

$dbh->do(q|DELETE FROM borrower_debarments|);
Koha::RestrictionTypes->search->delete;

$builder->build({
    source => 'DebarmentType',
    value  => {
        code         => 'ONE',
        display_text => 'One',
        ronly        => 1,
        dflt         => 0
    }
});
$builder->build({
    source => 'DebarmentType',
    value  => {
        code         => 'TWO',
        display_text => 'Two',
        ronly        => 1,
        dflt         => 1
    }
});

# keyed_on_code
my $keyed = Koha::RestrictionTypes->keyed_on_code;
my $expecting = {
    ONE => {
        code         => 'ONE',
        display_text => 'One',
        ronly        => 1,
        dflt         => 0
    },
    TWO => {
        code         => 'TWO',
        display_text => 'Two',
        ronly        => 1,
        dflt         => 1
    }
};

is_deeply($keyed, $expecting, 'keyed_on_code returns correctly');

$schema->storage->txn_rollback;
