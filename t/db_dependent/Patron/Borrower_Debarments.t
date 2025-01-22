#!/usr/bin/perl

use Modern::Perl;

use C4::Context;

use Koha::Database;
use Koha::DateUtils qw(dt_from_string);
use Koha::Patrons;
use Koha::Account;
use Koha::ActionLogs;

use t::lib::Mocks;
use t::lib::TestBuilder;

use Test::NoWarnings;
use Test::More tests => 40;

use_ok('Koha::Patron::Debarments');

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;
my $dbh     = C4::Context->dbh;

my $library = $builder->build(
    {
        source => 'Branch',
    }
);

my $patron_category = $builder->build( { source => 'Category' } );
my $patron          = $builder->build_object(
    {
        class => 'Koha::Patrons',
        value => {
            firstname    => 'my firstname',
            surname      => 'my surname',
            categorycode => $patron_category->{categorycode},
            branchcode   => $library->{branchcode},
        }
    }
);
my $borrowernumber = $patron->borrowernumber;

my $success = Koha::Patron::Debarments::AddDebarment(
    {
        borrowernumber => $borrowernumber,
        expiration     => '9999-06-10',
        type           => 'MANUAL',
        comment        => 'Test 1',
    }
);
is( $success, 1, "AddDebarment returned true" );

my $restrictions    = $patron->restrictions;
my $THE_restriction = $restrictions->next;
is( $restrictions->count,         1,            '$patron->restrictions returns 1 restriction' );
is( $THE_restriction->type->code, 'MANUAL',     "Correctly stored 'type'" );
is( $THE_restriction->expiration, '9999-06-10', "Correctly stored 'expiration'" );
is( $THE_restriction->comment,    'Test 1',     "Correctly stored 'comment'" );

$success = Koha::Patron::Debarments::AddDebarment(
    {
        borrowernumber => $borrowernumber,
        comment        => 'Test 2',
    }
);

$restrictions    = $patron->restrictions;
$THE_restriction = $restrictions->last;
is( $restrictions->count,         2,        '$patron->restrictions returns 2 restrictions' );
is( $THE_restriction->type->code, 'MANUAL', "Correctly stored 'type'" );
is( $THE_restriction->expiration, undef,    "Correctly stored debarrment with no expiration" );
is( $THE_restriction->comment,    'Test 2', "Correctly stored 'comment'" );

Koha::Patron::Debarments::ModDebarment(
    {
        borrower_debarment_id => $THE_restriction->borrower_debarment_id,
        comment               => 'Test 3',
        expiration            => '9998-06-10',
    }
);

$restrictions    = $patron->restrictions;
$THE_restriction = $restrictions->last;
is( $restrictions->count,      2,        '$patron->restrictions returns 2 restrictions' );
is( $THE_restriction->comment, 'Test 3', "ModDebarment functions correctly" );

$patron = $patron->get_from_storage;
is( $patron->debarred,        '9999-06-10',     "Field borrowers.debarred set correctly" );
is( $patron->debarredcomment, "Test 1\nTest 3", "Field borrowers.debarredcomment set correctly" );

Koha::Patron::Debarments::AddUniqueDebarment(
    {
        borrowernumber => $borrowernumber,
        type           => 'OVERDUES'
    }
);

$restrictions = $patron->restrictions->search(
    {
        type => 'OVERDUES',
    }
);
$THE_restriction = $restrictions->next;
is(
    $restrictions->count, 1,
    '$patron->restrictions->search({ type => "OVERDUES" }) returns 1 OVERDUES restriction after running AddUniqueDebarment once'
);
is( $THE_restriction->type->code, 'OVERDUES', "AddOverduesDebarment created new debarment correctly" );

Koha::Patron::Debarments::AddUniqueDebarment(
    {
        borrowernumber => $borrowernumber,
        expiration     => '9999-11-09',
        type           => 'OVERDUES'
    }
);

$restrictions = $patron->restrictions->search(
    {
        type => 'OVERDUES',
    }
);
$THE_restriction = $restrictions->next;
is(
    $restrictions->count, 1,
    '$patron->restrictions->search({ type => "OVERDUES" }) returns 1 OVERDUES restriction after running AddUniqueDebarent twice'
);
is( $THE_restriction->expiration, '9999-11-09', "AddUniqueDebarment updated the OVERDUES restriction correctly" );

my $delUniqueDebarment = Koha::Patron::Debarments::DelUniqueDebarment( {} );
is( $delUniqueDebarment, undef, "DelUniqueDebarment without the arguments 'borrowernumber' and 'type' returns undef" );

$restrictions = $patron->restrictions->search(
    {
        type => 'OVERDUES',
    }
);
is(
    $restrictions->count, 1,
    "DelUniqueDebarment without the arguments 'borrowernumber' and 'type' does not delete the debarment"
);

$delUniqueDebarment = Koha::Patron::Debarments::DelUniqueDebarment(
    {
        borrowernumber => $borrowernumber,
    }
);
is( $delUniqueDebarment, undef, "DelUniqueDebarment without the argument 'type' returns undef" );

$restrictions = $patron->restrictions->search(
    {
        type => 'OVERDUES',
    }
);
is( $restrictions->count, 1, "DelUniqueDebarment without the argument 'type' does not delete the debarment" );

$delUniqueDebarment = Koha::Patron::Debarments::DelUniqueDebarment( { type => 'OVERDUES' } );
is( $delUniqueDebarment, undef, "DelUniqueDebarment without the argument 'borrowernumber' returns undef" );

$restrictions = $patron->restrictions->search(
    {
        type => 'OVERDUES',
    }
);
is( $restrictions->count, 1, "DelUniqueDebarment without the argument 'borrowerumber' does not delete the debarment" );

$delUniqueDebarment = Koha::Patron::Debarments::DelUniqueDebarment(
    {
        borrowernumber => $borrowernumber,
        type           => 'SUSPENSION',
    }
);
is( $delUniqueDebarment, undef, "DelUniqueDebarment with wrong arguments returns undef" );

$restrictions = $patron->restrictions->search(
    {
        type => 'OVERDUES',
    }
);
is( $restrictions->count, 1, "DelUniqueDebarment with wrong arguments does not delete the debarment" );

$delUniqueDebarment = Koha::Patron::Debarments::DelUniqueDebarment(
    {
        borrowernumber => $borrowernumber,
        type           => 'OVERDUES',
    }
);
is( $delUniqueDebarment, 1, "DelUniqueDebarment returns 1" );

$restrictions = $patron->restrictions->search(
    {
        type => 'OVERDUES',
    }
);
is( $restrictions->count, 0, "DelUniqueDebarment functions correctly" );

$restrictions = $patron->restrictions;
while ( my $restriction = $restrictions->next ) {
    Koha::Patron::Debarments::DelDebarment( $restriction->borrower_debarment_id );
}

$restrictions = $patron->restrictions;
is( $restrictions->count, 0, "DelDebarment functions correctly" );

$dbh->do(q|UPDATE borrowers SET debarred = '1970-01-01'|);
is(
    Koha::Patrons->find($borrowernumber)->is_debarred, undef,
    'A patron with a debarred date in the past is not debarred'
);

$dbh->do(q|UPDATE borrowers SET debarred = NULL|);
is( Koha::Patrons->find($borrowernumber)->is_debarred, undef, 'A patron without a debarred date is not debarred' );

$dbh->do(q|UPDATE borrowers SET debarred = '9999-12-31'|);   # Note: Change this test before the first of January 10000!
is(
    Koha::Patrons->find($borrowernumber)->is_debarred, '9999-12-31',
    'A patron with a debarred date in the future is debarred'
);

# Test patrons merge
my $borrowernumber2 = Koha::Patron->new(
    {
        firstname    => 'my firstname bis',
        surname      => 'my surname bis',
        categorycode => $patron_category->{categorycode},
        branchcode   => $library->{branchcode},
    }
)->store->borrowernumber;
my $debarreddate2    = '9999-06-10';    # Be sure to be in the future
my $debarredcomment2 = 'Test merge';
Koha::Patron::Debarments::AddDebarment(
    {
        borrowernumber => $borrowernumber2,
        expiration     => $debarreddate2,
        type           => 'MANUAL',
        comment        => $debarredcomment2,
    }
);
my $borrowernumber3 = Koha::Patron->new(
    {
        firstname    => 'my firstname ter',
        surname      => 'my surname ter',
        categorycode => $patron_category->{categorycode},
        branchcode   => $library->{branchcode},
    }
)->store->borrowernumber;
Koha::Patrons->find($borrowernumber3)->merge_with( [$borrowernumber2] );
is(
    Koha::Patrons->find($borrowernumber3)->debarred,
    $debarreddate2, 'Koha::Patron->merge_with() transfers well debarred'
);
is(
    Koha::Patrons->find($borrowernumber3)->debarredcomment,
    $debarredcomment2, 'Koha::Patron->merge_with() transfers well debarredcomment'
);

# Test removing debartments after payment
$builder->build(
    {
        source => 'RestrictionType',
        value  => {
            code               => 'TEST',
            display_text       => 'This is a test.',
            is_system          => 0,
            is_default         => 0,
            lift_after_payment => 1,
            fee_limit          => 5
        }
    }
);

$builder->build(
    {
        source => 'RestrictionType',
        value  => {
            code               => 'TEST2',
            display_text       => 'This too is a test.',
            is_system          => 0,
            is_default         => 0,
            lift_after_payment => 1,
            fee_limit          => 0
        }
    }
);

my $patron4 = Koha::Patron->new(
    {
        firstname    => 'First',
        surname      => 'Sur',
        categorycode => $patron_category->{categorycode},
        branchcode   => $library->{branchcode},
    }
)->store;

my $account = $patron4->account;
my $line1   = $account->add_debit( { type => 'ACCOUNT', amount => 10, interface => 'commandline' } );

Koha::Patron::Debarments::AddDebarment(
    {
        borrowernumber => $patron4->borrowernumber,
        expiration     => '9999-06-10',
        type           => 'TEST',
        comment        => 'Test delete'
    }
);

Koha::Patron::Debarments::AddDebarment(
    {
        borrowernumber => $patron4->borrowernumber,
        expiration     => '9999-10-10',
        type           => 'TEST2',
        comment        => 'Test delete again',
    }
);

$restrictions = $patron4->restrictions;

is( $restrictions->count, 2, "->restrictions returns 2 restrictions before payment" );

$account->pay( { amount => 5 } );
$restrictions = $patron4->restrictions;
is( $restrictions->count,            1,       "->restrictions returns 1 restriction after paying half of the fee" );
is( $restrictions->next->type->code, "TEST2", "Restriction left has type value 'TEST2'" );

$account->pay( { amount => 5 } );
$restrictions = $patron4->restrictions;
is( $restrictions->count, 0, "->restrictions returns 0 restrictions after paying all fees" );

$schema->storage->txn_rollback;

subtest 'BorrowersLog tests' => sub {

    plan tests => 16;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { debarred => undef, debarredcomment => undef, }
        }
    );

    my $type = $builder->build_object( { class => 'Koha::Patron::Restriction::Types' } );

    foreach my $type (qw{CREATE_RESTRICTION MODIFY_RESTRICTION DELETE_RESTRICTION}) {
        is(
            Koha::ActionLogs->search( { module => 'MEMBERS', action => $type, object => $patron->id } )->count, 0,
            "No prior '$type' logs"
        );
    }

    t::lib::Mocks::mock_preference( 'BorrowersLog', 0 );

    my $add_comment    = 'AddDebarment comment';
    my $add_expiration = dt_from_string()->add( days => 1 );

    Koha::Patron::Debarments::AddDebarment(
        {
            borrowernumber => $patron->id,
            expiration     => $add_expiration,
            type           => $type->code,
            comment        => $add_comment,
        }
    );

    my $restrictions = $patron->restrictions;
    is( $restrictions->count, 1, 'Only one restriction present' );

    my $restriction = $restrictions->next;

    my $mod_comment    = 'ModDebarment comment';
    my $mod_expiration = dt_from_string()->add( days => 5 );

    Koha::Patron::Debarments::ModDebarment(
        {
            borrower_debarment_id => $restriction->id,
            comment               => $mod_comment,
            expiration            => $mod_expiration,
        }
    );

    Koha::Patron::Debarments::DelDebarment( $restriction->id );

    is( $patron->restrictions->count, 0, 'No restrictions present' );

    foreach my $type (qw{CREATE_RESTRICTION MODIFY_RESTRICTION DELETE_RESTRICTION}) {
        is(
            Koha::ActionLogs->search( { module => 'MEMBERS', action => $type, object => $patron->id } )->count, 0,
            "No added '$type' logs"
        );
    }

    t::lib::Mocks::mock_preference( 'BorrowersLog', 1 );

    Koha::Patron::Debarments::AddDebarment(
        {
            borrowernumber => $patron->id,
            expiration     => $add_expiration,
            type           => $type->code,
            comment        => $add_comment,
        }
    );

    $restrictions = $patron->restrictions;
    is( $restrictions->count, 1, 'Only one restriction present' );

    $restriction = $restrictions->next;

    Koha::Patron::Debarments::ModDebarment(
        {
            borrower_debarment_id => $restriction->id,
            comment               => $mod_comment,
            expiration            => $mod_expiration,
        }
    );

    Koha::Patron::Debarments::DelDebarment( $restriction->id );

    is( $patron->restrictions->count, 0, 'No restrictions present' );

    my $add_logs =
        Koha::ActionLogs->search( { module => 'MEMBERS', action => 'CREATE_RESTRICTION', object => $patron->id } );
    my $mod_logs =
        Koha::ActionLogs->search( { module => 'MEMBERS', action => 'MODIFY_RESTRICTION', object => $patron->id } );
    my $del_logs =
        Koha::ActionLogs->search( { module => 'MEMBERS', action => 'DELETE_RESTRICTION', object => $patron->id } );

    is( $add_logs->count, 1, 'Restriction creation logged' );
    like( $add_logs->next->info, qr/$add_comment/ );

    is( $mod_logs->count, 1, 'Restriction modification logged' );
    like( $mod_logs->next->info, qr/$mod_comment/ );

    is( $del_logs->count, 1, 'Restriction deletion logged' );
    like( $del_logs->next->info, qr/$mod_comment/, 'Deleted restriction contains last known comment' );

    $schema->storage->txn_rollback;
};
