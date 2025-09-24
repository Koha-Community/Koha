# This file is part of Koha
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use Test::More tests => 2;
use Test::NoWarnings;

use Koha::ActionLogs;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

subtest 'Test Koha::Patrons::merge' => sub {

    plan tests => 3;
    my $builder = t::lib::TestBuilder->new;

    my $keeper = $builder->build_object( { class => 'Koha::Patrons' } );

    my $borrower1 = $builder->build( { source => 'Borrower' } );
    my $borrower2 = $builder->build( { source => 'Borrower' } );
    my $borrower3 = $builder->build( { source => 'Borrower' } );
    my $borrower4 = $builder->build( { source => 'Borrower' } );

    #test with BorrowersLog on
    t::lib::Mocks::mock_preference( 'BorrowersLog', 1 );

    my $results = $keeper->merge_with( [ $borrower1->{borrowernumber}, $borrower2->{borrowernumber} ] );

    my $log = Koha::ActionLogs->search(
        {
            module => 'MEMBERS',
            action => 'PATRON_MERGE',
            object => $keeper->id
        },
        { order_by => { -desc => "timestamp" } }
    );

    my $info_borrower1 =
          $borrower1->{firstname} . " "
        . $borrower1->{surname} . " ("
        . $borrower1->{cardnumber}
        . ") has been merged into "
        . $keeper->firstname . " "
        . $keeper->surname . " ("
        . $keeper->cardnumber . ")";

    is(
        $log->search( { info => $info_borrower1 } )->count, 1,
        "GetLogs returns results in the log viewer for the merge of " . $borrower1->{borrowernumber}
    );

    my $info_borrower2 =
          $borrower2->{firstname} . " "
        . $borrower2->{surname} . " ("
        . $borrower2->{cardnumber}
        . ") has been merged into "
        . $keeper->firstname . " "
        . $keeper->surname . " ("
        . $keeper->cardnumber . ")";

    is(
        $log->search( { info => $info_borrower2 } )->count, 1,
        "GetLogs returns results in the log viewer for the merge of " . $borrower2->{borrowernumber}
    );

    #test with BorrowersLog off
    t::lib::Mocks::mock_preference( 'BorrowersLog', 0 );

    $keeper = $builder->build_object( { class => 'Koha::Patrons' } );

    $results = $keeper->merge_with( [ $borrower3->{borrowernumber}, $borrower4->{borrowernumber} ] );

    $log = Koha::ActionLogs->search(
        {
            module => 'MEMBERS',
            action => 'PATRON_MERGE',
            object => $keeper->id
        },
        { order_by => { -desc => "timestamp" } }
    );

    is(
        $log->count, 0,
        "GetLogs didn't log anything"
    );
};

$schema->storage->txn_rollback;
