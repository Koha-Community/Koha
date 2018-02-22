#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 6;
use Test::Warn;

use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Circulation;
use C4::Context;
use Koha::Checkouts;
use Koha::Database;
use Koha::Patrons;

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;

my $library = $builder->build({ source => 'Branch' });

C4::Context->_new_userenv('xxx');
C4::Context->set_userenv(0,0,0,'firstname','surname', $library->{branchcode}, $library->{branchname}, '', '', '');

my $patron_category = $builder->build({ source => 'Category', value => { category_type => 'P', enrolmentfee => 0 } });
my $patron = $builder->build({ source => 'Borrower', value => { branchcode => $library->{branchcode}, categorycode => $patron_category->{categorycode} } } );

my $biblioitem = $builder->build( { source => 'Biblioitem' } );
my $item = $builder->build(
    {
        source => 'Item',
        value  => {
            homebranch    => $library->{branchcode},
            holdingbranch => $library->{branchcode},
            notforloan    => 0,
            itemlost      => 0,
            withdrawn     => 0,
            biblionumber  => $biblioitem->{biblionumber},
        }
    }
);

subtest 'anonymous patron' => sub {
    plan tests => 2;
    # The next call will raise an error, because data are not correctly set
    t::lib::Mocks::mock_preference('AnonymousPatron', '');
    my $issue = C4::Circulation::AddIssue( $patron, $item->{barcode} );
    eval { C4::Circulation::MarkIssueReturned( $patron->{borrowernumber}, $item->{itemnumber}, 'dropbox_branch', 'returndate', 2 ) };
    like ( $@, qr<Fatal error: the patron \(\d+\) .* AnonymousPatron>, 'AnonymousPatron is not set - Fatal error on anonymization' );
    Koha::Checkouts->find( $issue->issue_id )->delete;

    my $anonymous_borrowernumber = Koha::Patron->new({categorycode => $patron_category->{categorycode}, branchcode => $library->{branchcode} })->store->borrowernumber;
    t::lib::Mocks::mock_preference('AnonymousPatron', $anonymous_borrowernumber);
    $issue = C4::Circulation::AddIssue( $patron, $item->{barcode} );
    eval { C4::Circulation::MarkIssueReturned( $patron->{borrowernumber}, $item->{itemnumber}, 'dropbox_branch', 'returndate', 2 ) };
    is ( $@, q||, 'AnonymousPatron is set correctly - no error expected');
};

my ( $issue_id, $issue );
# The next call will return undef for invalid item number
eval { $issue_id = C4::Circulation::MarkIssueReturned( $patron->{borrowernumber}, 'invalid_itemnumber', 'dropbox_branch', 'returndate', 0 ) };
is( $@, '', 'No die triggered by invalid itemnumber' );
is( $issue_id, undef, 'No issue_id returned' );

# In the next call we return the item and try it another time
$issue = C4::Circulation::AddIssue( $patron, $item->{barcode} );
eval { $issue_id = C4::Circulation::MarkIssueReturned( $patron->{borrowernumber}, $item->{itemnumber}, undef, undef, 0 ) };
is( $issue_id, $issue->issue_id, "Item has been returned (issue $issue_id)" );
eval { $issue_id = C4::Circulation::MarkIssueReturned( $patron->{borrowernumber}, $item->{itemnumber}, undef, undef, 0 ) };
is( $@, '', 'No crash on returning item twice' );
is( $issue_id, undef, 'Cannot return an item twice' );

$schema->storage->txn_rollback;
