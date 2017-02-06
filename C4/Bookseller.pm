package C4::Bookseller;

# Copyright 2000-2002 Katipo Communications
# Copyright 2010 PTFS Europe
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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use strict;
use warnings;

use base qw( Exporter );

our @EXPORT_OK = qw(
  GetBooksellersWithLateOrders
);

=head1 NAME

C4::Bookseller - Koha functions for dealing with booksellers.

=head1 SYNOPSIS

use C4::Bookseller;

=head1 DESCRIPTION

The functions in this module deal with booksellers. They allow to
add a new bookseller, to modify it or to get some informations around
a bookseller.

=head1 FUNCTIONS

=head2 GetBooksellersWithLateOrders

%results = GetBooksellersWithLateOrders( $delay, $estimateddeliverydatefrom, $estimateddeliverydateto );

Searches for suppliers with late orders.

=cut

sub GetBooksellersWithLateOrders {
    my ( $delay, $estimateddeliverydatefrom, $estimateddeliverydateto ) = @_;
    my $dbh = C4::Context->dbh;

    # FIXME NOT quite sure that this operation is valid for DBMs different from Mysql, HOPING so
    # should be tested with other DBMs

    my $query;
    my @query_params = ();
    my $dbdriver = C4::Context->config("db_scheme") || "mysql";
    $query = "
        SELECT DISTINCT aqbasket.booksellerid, aqbooksellers.name
        FROM aqorders LEFT JOIN aqbasket ON aqorders.basketno=aqbasket.basketno
        LEFT JOIN aqbooksellers ON aqbasket.booksellerid = aqbooksellers.id
        WHERE
            ( datereceived = ''
            OR datereceived IS NULL
            OR aqorders.quantityreceived < aqorders.quantity
            )
            AND aqorders.quantity - COALESCE(aqorders.quantityreceived,0) <> 0
            AND aqbasket.closedate IS NOT NULL
    ";
    if ( defined $delay && $delay >= 0 ) {
        $query .= " AND (closedate <= DATE_SUB(CAST(now() AS date),INTERVAL ? + COALESCE(aqbooksellers.deliverytime,0) DAY)) ";
        push @query_params, $delay;
    } elsif ( $delay && $delay < 0 ){
        warn 'WARNING: GetBooksellerWithLateOrders is called with a negative value';
        return;
    }
    if ( defined $estimateddeliverydatefrom ) {
        $query .= '
            AND ADDDATE(aqbasket.closedate, INTERVAL COALESCE(aqbooksellers.deliverytime,0) DAY) >= ?';
            push @query_params, $estimateddeliverydatefrom;
            if ( defined $estimateddeliverydateto ) {
                $query .= ' AND ADDDATE(aqbasket.closedate, INTERVAL COALESCE(aqbooksellers.deliverytime, 0) DAY) <= ?';
                push @query_params, $estimateddeliverydateto;
            } else {
                    $query .= ' AND ADDDATE(aqbasket.closedate, INTERVAL COALESCE(aqbooksellers.deliverytime, 0) DAY) <= CAST(now() AS date)';
            }
    }
    if ( defined $estimateddeliverydateto ) {
        $query .= ' AND ADDDATE(aqbasket.closedate, INTERVAL COALESCE(aqbooksellers.deliverytime,0) DAY) <= ?';
        push @query_params, $estimateddeliverydateto;
    }

    my $sth = $dbh->prepare($query);
    $sth->execute( @query_params );
    my %supplierlist;
    while ( my ( $id, $name ) = $sth->fetchrow ) {
        $supplierlist{$id} = $name;
    }

    return %supplierlist;
}

1;

__END__

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

=cut
