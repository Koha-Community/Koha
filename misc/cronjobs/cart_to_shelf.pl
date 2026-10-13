#!/usr/bin/perl
#-----------------------------------
# Copyright 2009 PTFS Inc.
#
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.
#-----------------------------------

=head1 NAME

cart_to_shelf.pl  cron script to set items with location of CART to original shelving location after X hours.
                  Execute with --help for usage.

=cut

use strict;
use warnings;

use Koha::Script -cron;
use C4::Items qw( CartToShelf );

use C4::Context;

my $opt = Koha::Script->describe_options(
    'Set any item with a location of CART back to its original shelving location once the given number of hours have passed.

%c %o',
    [
        'hours|h=i', 'hours that need to pass before an item is returned to its original shelving location',
        {
            required  => 1,
            callbacks => {
                'a positive integer' => sub {
                    my $v = shift;
                    return 1 if $v > 0;
                    die "--hours must be a positive integer (got $v)\n";
                },
            },
        }
    ],
    {
        epilog =>
            "Examples:\n  %c --hours 24\n    Move any item that has been on the cart for more than 24 hours back to its original shelving location.\n",
    },
);

my $query =
    "SELECT itemnumber FROM items WHERE location = 'CART' AND TIMESTAMPDIFF(HOUR, items.timestamp, NOW() ) >= ?";
my $sth = C4::Context->dbh->prepare($query);
$sth->execute( $opt->hours );
while ( my ($itemnumber) = $sth->fetchrow_array ) {
    CartToShelf($itemnumber);
}

