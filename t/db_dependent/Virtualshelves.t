#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 2;

use C4::Context;
use Koha::DateUtils;
use Koha::Virtualshelves;
use Koha::Virtualshelfshares;

use t::lib::TestBuilder;

my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;

$dbh->do(q|DELETE FROM virtualshelves|);
$dbh->do(q|DELETE FROM virtualshelfshares|);

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
    is( ref($@), 'Koha::Exceptions::Virtualshelves::DuplicateObject' );
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

subtest 'Sharing' => sub {
    plan tests => 18;
    my $patron_wants_to_share = $builder->build({
        source => 'Borrower',
    });
    my $share_with_me = $builder->build({
        source => 'Borrower',
    });
    my $just_another_patron = $builder->build({
        source => 'Borrower',
    });

    my $number_of_shelves_shared = Koha::Virtualshelfshares->search->count;
    is( $number_of_shelves_shared, 0, 'No shelves should exist' );

    my $shelf_to_share = Koha::Virtualshelf->new({
            shelfname => "my first shelf",
            owner => $patron_wants_to_share->{borrowernumber},
            category => 1,
        }
    )->store;

    my $shelf_not_to_share = Koha::Virtualshelf->new({
            shelfname => "my second shelf",
            owner => $patron_wants_to_share->{borrowernumber},
            category => 1,
        }
    )->store;

    my $shared_shelf = eval { $shelf_to_share->share };
    is ( ref( $@ ), 'Koha::Exceptions::Virtualshelves::InvalidKeyOnSharing', 'Do not share if no key given' );
    $shared_shelf = eval { $shelf_to_share->share('this is a valid key') };
    is( ref( $shared_shelf ), 'Koha::Virtualshelfshare', 'On sharing, the method should return a valid Koha::Virtualshelfshare object' );

    my $another_shared_shelf = eval { $shelf_to_share->share('this is another valid key') }; # Just to have 2 shares in DB

    $number_of_shelves_shared = Koha::Virtualshelfshares->search->count;
    is( $number_of_shelves_shared, 2, '2 shares should have been inserted' );

    my $is_accepted = eval {
        $shared_shelf->accept( 'this is an invalid key', $share_with_me->{borrowernumber} );
    };
    is( $is_accepted, undef, 'The share should have not been accepted if the key is invalid' );
    is( ref( $@ ), 'Koha::Exceptions::Virtualshelves::InvalidInviteKey', 'accept with an invalid key should raise an exception' );

    $is_accepted = $shared_shelf->accept( 'this is a valid key', $share_with_me->{borrowernumber} );
    ok( defined($is_accepted), 'The share should have been accepted if the key valid' );

    is( $shelf_to_share->is_shared, 1 );
    is( $shelf_not_to_share->is_shared, 0 );

    is( $shelf_to_share->is_shared_with( $patron_wants_to_share->{borrowernumber} ), 0 , "The shelf should not be shared with the owner" );
    is( $shelf_to_share->is_shared_with( $share_with_me->{borrowernumber} ), 1 , "The shelf should be shared with share_with_me" );
    is( $shelf_to_share->is_shared_with( $just_another_patron->{borrowernumber} ), 0, "The shelf should not be shared with just_another_patron" );

    is( $shelf_to_share->remove_share( $just_another_patron->{borrowernumber} ), 0, 'No share should be removed if the share has not been done with this patron' );
    $number_of_shelves_shared = Koha::Virtualshelfshares->search->count;
    is( $number_of_shelves_shared, 2, 'To be sure no shares have been removed' );

    is( $shelf_not_to_share->remove_share( $share_with_me->{borrowernumber} ), 0, '0 share should have been removed if the shelf is not share' );
    $number_of_shelves_shared = Koha::Virtualshelfshares->search->count;
    is( $number_of_shelves_shared, 2, 'To be sure no shares have been removed' );

    is( $shelf_to_share->remove_share( $share_with_me->{borrowernumber} ), 1, '1 share should have been removed if the shelf was shared with this patron' );
    $number_of_shelves_shared = Koha::Virtualshelfshares->search->count;
    is( $number_of_shelves_shared, 1, 'To be sure the share has been removed' );
};
