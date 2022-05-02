#!/usr/bin/perl

use Modern::Perl;

use C4::Context;
use Koha::Database;
use t::lib::TestBuilder;

use Test::More tests => 6;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;
my $builder = t::lib::TestBuilder->new;

use_ok('Koha::RestrictionType');
use_ok('Koha::RestrictionTypes');

$dbh->do(q|DELETE FROM borrower_debarments|);
$dbh->do(q|DELETE FROM debarment_types|);

$builder->build({
    source => 'DebarmentType',
    value  => {
        code         => 'ONE',
        display_text => 'One',
        is_system     => 1,
        default_value    => 0,
        can_be_added_manually => 0
    }
});
$builder->build({
    source => 'DebarmentType',
    value  => {
        code         => 'TWO',
        display_text => 'Two',
        is_system     => 1,
        default_value    => 1,
        can_be_added_manually => 0
    }
});
$builder->build({
    source => 'DebarmentType',
    value  => {
        code         => 'THREE',
        display_text => 'Three',
        is_system     => 1,
        default_value    => 0,
        can_be_added_manually => 0
    }
});
$builder->build({
    source => 'DebarmentType',
    value  => {
        code         => 'FOUR',
        display_text => 'Four',
        is_system     => 0,
        default_value    => 0,
        can_be_added_manually => 0
    }
});
$builder->build({
    source => 'DebarmentType',
    value  => {
        code         => 'FIVE',
        display_text => 'Five',
        is_system     => 0,
        default_value    => 0,
        can_be_added_manually => 0
    }
});

# Can we create RestrictionTypes
my $created = Koha::RestrictionTypes->find({ code => 'ONE' });
ok( $created->display_text eq 'One', 'Restrictions created');

# Can we delete RestrictionTypes, when appropriate
my $deleted = Koha::RestrictionTypes->find({ code => 'FOUR' })->delete;
ok( $deleted, 'Restriction deleted');
my $not_deleted = Koha::RestrictionTypes->find({ code => 'TWO' })->delete;
ok( !$not_deleted, 'Read only restriction not deleted');

# Add a patron with a debarment
my $library = $builder->build({ source => 'Branch' });

my $patron_category = $builder->build({ source => 'Category' });
my $borrowernumber = Koha::Patron->new({
    firstname =>  'my firstname',
    surname => 'my surname',
    categorycode => $patron_category->{categorycode},
    branchcode => $library->{branchcode},
})->store->borrowernumber;

Koha::Patron::Debarments::AddDebarment({
    borrowernumber => $borrowernumber,
    expiration => '9999-06-10',
    type => 'FIVE',
    comment => 'Test 1',
});

# Now delete a code and check debarments using that code switch to
# using the default
my $to_delete = Koha::RestrictionTypes->find({ code => 'FIVE' })->delete;
my $debarments = Koha::Patron::Debarments::GetDebarments({
    borrowernumber => $borrowernumber
});
is( $debarments->[0]->{type}, 'TWO', 'Debarments update with restrictions' );

$schema->storage->txn_rollback;
