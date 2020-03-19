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

use Test::More tests => 4;
use t::lib::TestBuilder;
use t::lib::Mocks;

use C4::Circulation;
use C4::Reserves;
use Koha::DateUtils qw( dt_from_string );

my $builder = t::lib::TestBuilder->new;

subtest 'transfer a non-existant item' => sub {
    plan tests => 2;

    my $library = $builder->build( { source => 'Branch' } );

    #Transfert on unknown barcode
    my $item  = $builder->build_sample_item();
    my $badbc = $item->barcode;
    $item->delete;

    my ( $dotransfer, $messages ) =
      C4::Circulation::transferbook( $library->{branchcode}, $badbc );
    is( $dotransfer, 0, "Can't transfer a bad barcode" );
    is_deeply(
        $messages,
        { BadBarcode => $badbc },
        "We got the expected barcode"
    );
};

#FIXME:'UseBranchTransferLimits tests missing

subtest 'transfer already at destination' => sub {
    plan tests => 5;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } )->store;
    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode } );

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { branchcode => $library->branchcode }
        }
    );

    my $item = $builder->build_sample_item(
        {
            library => $library->branchcode,
        }
    );

    my ($dotransfer, $messages ) = transferbook( $library->branchcode, $item->barcode );
    is( $dotransfer, 0, 'Transfer of reserved item failed with ignore reserves: true' );
    is_deeply(
        $messages,
        { 'DestinationEqualsHolding' => 1 },
        "We got the expected failure message: DestinationEqualsHolding"
    );

    # We are making sure there is no regression, feel free to change the behavior if needed.
    # * Contrary to the POD, if ignore_reserves is not passed (or is false), any item reserve
    #   found will override all other measures that may prevent transfer and force a transfer.
    AddReserve({
        branchcode     => $item->homebranch,
        borrowernumber => $patron->borrowernumber,
        biblionumber   => $item->biblionumber,
        itemnumber     => $item->itemnumber,
    });

    ($dotransfer, $messages ) = transferbook( $library->branchcode, $item->barcode );
    is( $dotransfer, 1, 'Transfer of reserved item succeeded without ignore reserves' );
    is( $messages->{ResFound}->{ResFound}, 'Reserved', "We found the reserve");
    is( $messages->{ResFound}->{itemnumber}, $item->itemnumber, "We got the reserve info");
};

subtest 'transfer an issued item' => sub {
    plan tests => 5;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } )->store;
    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode } );

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { branchcode => $library->branchcode }
        }
    );

    my $item = $builder->build_sample_item(
        {
            library => $library->branchcode,
        }
    );

    my $dt_to = dt_from_string();
    my $issue = AddIssue( $patron->unblessed, $item->barcode, $dt_to );

    # We are making sure there is no regression, feel free to change the behavior if needed.
    # * WasReturned does not seem like a variable that should contain a borrowernumber
    # * Should we return even if the transfer did not happen? (same branches)
    my ($dotransfer, $messages) = transferbook( $library->branchcode, $item->barcode );
    is( $messages->{WasReturned}, $patron->borrowernumber, 'transferbook should have return a WasReturned flag is the item was issued before the transferbook call');

    # Reset issue
    $issue = AddIssue( $patron->unblessed, $item->barcode, $dt_to );

    # We are making sure there is no regression, feel free to change the behavior if needed.
    # * Contrary to the POD, if ignore_reserves is not passed (or is false), any item reserve
    #   found will override all other measures that may prevent transfer and force a transfer.
    AddReserve({
        branchcode     => $item->homebranch,
        borrowernumber => $patron->borrowernumber,
        biblionumber   => $item->biblionumber,
        itemnumber     => $item->itemnumber,
    });

    ($dotransfer, $messages ) = transferbook( $library->branchcode, $item->barcode );
    is( $dotransfer, 1, 'Transfer of reserved item succeeded without ignore reserves' );
    is( $messages->{ResFound}->{ResFound}, 'Reserved', "We found the reserve");
    is( $messages->{ResFound}->{itemnumber}, $item->itemnumber, "We got the reserve info");
    is( $messages->{WasReturned}, $patron->borrowernumber, "We got the return info");
};

subtest 'ignore_reserves flag' => sub {
    plan tests => 10;
    my $library = $builder->build_object( { class => 'Koha::Libraries' } )->store;
    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode } );

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { branchcode => $library->branchcode }
        }
    );

    my $item = $builder->build_sample_item(
        {
            library => $library->branchcode,
        }
    );

    AddReserve({
        branchcode     => $item->homebranch,
        borrowernumber => $patron->borrowernumber,
        biblionumber   => $item->biblionumber,
        itemnumber     => $item->itemnumber,
    });

    # We are making sure there is no regression, feel free to change the behavior if needed.
    # * Contrary to the POD, if ignore_reserves is not passed (or is false), any item reserve
    #   found will override all other measures that may prevent transfer and force a transfer.
    my ($dotransfer, $messages ) = transferbook( $library->branchcode, $item->barcode );
    is( $dotransfer, 1, 'Transfer of reserved item succeeded without ignore reserves' );
    is( $messages->{ResFound}->{ResFound}, 'Reserved', "We found the reserve");
    is( $messages->{ResFound}->{itemnumber}, $item->itemnumber, "We got the reserve info");

    my $ignore_reserves = 0;
    ($dotransfer, $messages ) = transferbook( $library->branchcode, $item->barcode, $ignore_reserves );
    is( $dotransfer, 1, 'Transfer of reserved item succeeded with ignore reserves: false' );
    is( $messages->{ResFound}->{ResFound}, 'Reserved', "We found the reserve");
    is( $messages->{ResFound}->{itemnumber}, $item->itemnumber, "We got the reserve info");

    $ignore_reserves = 1;
    ($dotransfer, $messages ) = transferbook( $library->branchcode, $item->barcode, $ignore_reserves );
    is( $dotransfer, 0, 'Transfer of reserved item failed with ignore reserves: true' );
    is_deeply(
        $messages,
        { 'DestinationEqualsHolding' => 1 },
        "We got the expected failure message: DestinationEqualsHolding"
    );
    isnt( $messages->{ResFound}->{ResFound}, 'Reserved', "We did not return that we found a reserve");
    isnt( $messages->{ResFound}->{itemnumber}, $item->itemnumber, "We did not return the reserve info");
};
