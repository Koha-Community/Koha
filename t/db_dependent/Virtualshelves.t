#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 1;

use C4::Context;
use Koha::DateUtils;
use Koha::Virtualshelf;
use Koha::Virtualshelves;

use t::lib::TestBuilder;

my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;

$dbh->do(q|DELETE FROM virtualshelves|);

my $builder = t::lib::TestBuilder->new;

subtest 'CRUD' => sub {
    plan tests => 13;
    my $patron = $builder->build({
        source => 'Borrower',
    });

    my $number_of_shelves = Koha::Virtualshelves->search->count;

    is( $number_of_shelves, 0, 'No shelves should exist' );

    my $shelf = Koha::Virtualshelf->new({
            shelfname => "my first shelf",
            owner => $patron->{borrowernumber},
            category => 1,
        }
    )->store;

    is( ref( $shelf ), 'Koha::Virtualshelf', 'The constructor should return a valid object' );

    $number_of_shelves = Koha::Virtualshelves->search->count;
    is( $number_of_shelves, 1, '1 shelf should have been inserted' );
    is( $shelf->allow_add, 0, 'The default value for allow_add should be 1' );
    is( $shelf->allow_delete_own, 1, 'The default value for allow_delete_own should be 0' );
    is( $shelf->allow_delete_other, 0, 'The default value for allow_delete_other should be 0' );
    is( output_pref($shelf->created_on), output_pref(dt_from_string), 'The creation time should have been set to today' );

    my $retrieved_shelf = Koha::Virtualshelves->find( $shelf->shelfnumber );

    is( $retrieved_shelf->shelfname, $shelf->shelfname, 'Find should correctly return the shelfname' );

    # Insert with the same name
    eval {
        $shelf = Koha::Virtualshelf->new({
                shelfname => "my first shelf",
                owner => $patron->{borrowernumber},
                category => 1,
            }
        )->store;
    };
    is( ref($@), 'Koha::Exception::DuplicateObject' );
    $number_of_shelves = Koha::Virtualshelves->search->count;
    is( $number_of_shelves, 1, 'To be sure the number of shelves is still 1' );

    my $another_patron = $builder->build({
        source => 'Borrower',
    });

    $shelf = Koha::Virtualshelf->new({
            shelfname => "my first shelf",
            owner => $another_patron->{borrowernumber},
            category => 1,
        }
    )->store;
    $number_of_shelves = Koha::Virtualshelves->search->count;
    is( $number_of_shelves, 2, 'Another patron should be able to create a shelf with an existing shelfname');

    my $is_deleted = Koha::Virtualshelves->find( $shelf->shelfnumber )->delete;
    is( $is_deleted, 1, 'The shelf has been deleted correctly' );
    $number_of_shelves = Koha::Virtualshelves->search->count;
    is( $number_of_shelves, 1, 'To be sure the shelf has been deleted' );
};
