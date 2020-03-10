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

use Test::More tests => 3;
use t::lib::TestBuilder;
use t::lib::Mocks;

use C4::Circulation;
use C4::Reserves;
use Koha::DateUtils qw( dt_from_string );

my $builder = t::lib::TestBuilder->new;

my $library = $builder->build( { source => 'Branch' } );
my @got;
my @wanted;

#Transfert on unknown barcode
my $item = $builder->build_sample_item();
my $badbc = $item->barcode;
$item->delete;

my ( $dotransfer, $messages ) = C4::Circulation::transferbook( $library->{branchcode}, $badbc );
is( $dotransfer, 0, "Can't transfer a bad barcode");
is_deeply( $messages, { BadBarcode => $badbc }, "We got the expected barcode");

subtest 'transfer an issued item' => sub {
    plan tests => 3;

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

    AddReserve({
        branchcode     => $item->homebranch,
        borrowernumber => $patron->borrowernumber,
        biblionumber   => $item->biblionumber,
        itemnumber     => $item->itemnumber,
    });
    ($dotransfer, $messages ) = transferbook( $library->branchcode, $item->barcode );
    is( $messages->{ResFound}->{ResFound}, 'Reserved', "We found the reserve");
    is( $messages->{ResFound}->{itemnumber}, $item->itemnumber, "We got the reserve info");
};
