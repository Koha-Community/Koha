#!/usr/bin/perl

use Modern::Perl;
use Test::NoWarnings;
use Test::More tests => 2;

use Koha::Authority::MergeRequest;
use Koha::Authority::MergeRequests;
use Koha::Database;
use Koha::DateUtils qw/dt_from_string/;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

subtest "Tests for cron_cleanup" => sub {
    plan tests => 3;

    my $dt = dt_from_string;
    $dt->subtract( hours => 2 );
    my $req1 = Koha::Authority::MergeRequest->new(
        {
            authid    => 1,
            done      => 2,
            timestamp => $dt,
        }
    )->store;

    $dt->subtract( days => 30 );
    my $req2 = Koha::Authority::MergeRequest->new(
        {
            authid    => 2,
            done      => 1,
            timestamp => $dt,
        }
    )->store;

    # Now test two cleanup calls
    # First call should only remove req2; second call should reset req1
    Koha::Authority::MergeRequests->cron_cleanup( { reset_hours => 3 } );
    $req1->discard_changes;    # requery
    is( $req1->done, 2, 'My request was not touched' );
    $req2->discard_changes;    # requery
    is( $req2->in_storage, 0, 'Second request removed' );
    Koha::Authority::MergeRequests->cron_cleanup( { reset_hours => 1 } );
    $req1->discard_changes;    # requery
    is( $req1->done, 0, 'Yes, we got a reset' );
};

$schema->storage->txn_rollback;
