package C4::Bookfund;

# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

# $Id$


use strict;


use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = do { my @v = '$Revision$' =~ /\d+/g; shift(@v) . "." . join( "_", map { sprintf "%03d", $_ } @v ); };

=head1 NAME

C4::Bookfund - Koha functions for dealing with bookfund, currency & money.

=head1 SYNOPSIS

use C4::Bookfund;

=head1 DESCRIPTION

the functions in this modules deal with bookfund, currency and money.
They allow to get and/or set some informations for a specific budget or currency.

=cut

@ISA    = qw(Exporter);
@EXPORT = qw(
    &GetBookFund &GetBookFunds &GetBookFundBreakdown &GetCurrencies
    &ModBookFund &ModCurrencies
    &Countbookfund
    &ConvertCurrency
);

=head1 FUNCTIONS

=over 2

=cut

#-------------------------------------------------------------#

=head3 GetBookFund

=over 4

$dataaqbookfund = &GetBookFund($bookfundid);

this function get the bookfundid, bookfundname, the bookfundgroup,  the branchcode
from aqbookfund table for bookfundid given on input arg.
return: 
C<$dataaqbookfund> is a hashref full of bookfundid, bookfundname, bookfundgroup,
and branchcode.

=back

=cut

sub GetBookFund {
    my $bookfundid = @_;
    my $dbh = C4::Context->dbh;
    my $query = "
        SELECT
            bookfundid,
            bookfundname,
            bookfundgroup,
            branchcode
        FROM aqbookfund
        WHERE bookfundid = ?
    ";
    my $sth=$dbh->prepare($query);
    return $sth->fetchrow_hashref;
}

#-------------------------------------------------------------#

=head3 GetBookFunds

=over 4

@results = &GetBookFunds;

Returns a list of all book funds.

C<@results> is an array of references-to-hash, whose keys are fields from the aqbookfund and aqbudget tables of the Koha database. Results are ordered
alphabetically by book fund name.

=back

=cut

sub GetBookFunds {
    my ($branch) = @_;
    my $dbh      = C4::Context->dbh;
    my $userenv  = C4::Context->userenv;
    my $branch   = $userenv->{branch};
    my $strsth;

    if ( $branch ne '' ) {
        $strsth = "
        SELECT *
        FROM   aqbookfund,aqbudget
        WHERE  aqbookfund.bookfundid=aqbudget.bookfundid
            AND startdate<now()
            AND enddate>now()
            AND (aqbookfund.branchcode IS NULL OR aqbookfund.branchcode='' OR aqbookfund.branchcode= ? )
      GROUP BY aqbookfund.bookfundid ORDER BY bookfundname";
    }
    else {
        $strsth = "
            SELECT *
            FROM   aqbookfund,
                   aqbudget
            WHERE aqbookfund.bookfundid=aqbudget.bookfundid
                AND startdate<now()
                AND enddate>now()
            GROUP BY aqbookfund.bookfundid ORDER BY bookfundname
        ";
    }
    my $sth = $dbh->prepare($strsth);
    if ( $branch ne '' ) {
        $sth->execute($branch);
    }
    else {
        $sth->execute;
    }
    my @results = ();
    while ( my $data = $sth->fetchrow_hashref ) {
        push( @results, $data );
    }
    $sth->finish;
    return @results;
}

#-------------------------------------------------------------#

=head3 GetCurrencies

=over 4

@currencies = &GetCurrencies;

Returns the list of all known currencies.

C<$currencies> is a array; its elements are references-to-hash, whose
keys are the fields from the currency table in the Koha database.

=back

=cut

sub GetCurrencies {
    my $dbh = C4::Context->dbh;
    my $query = "
        SELECT *
        FROM   currency
    ";
    my $sth = $dbh->prepare($query);
    $sth->execute;
    my @results = ();
    while ( my $data = $sth->fetchrow_hashref ) {
        push( @results, $data );
    }
    $sth->finish;
    return @results;
}

#-------------------------------------------------------------#

=head3 GetBookFundBreakdown

=over 4

( $spent, $comtd ) = &GetBookFundBreakdown( $id, $year, $start, $end );

returns the total comtd & spent for a given bookfund, and a given year
used in acqui-home.pl

=back

=cut

sub GetBookFundBreakdown {
    my ( $id, $year, $start, $end ) = @_;
    my $dbh = C4::Context->dbh;

    # if no start/end dates given defaut to everything
    if ( !$start ) {
        $start = '0000-00-00';
        $end   = 'now()';
    }

    # do a query for spent totals.
    my $query = "
        SELECT quantity,datereceived,freight,unitprice,listprice,ecost,
               quantityreceived,subscription
        FROM   aqorders
        LEFT JOIN aqorderbreakdown ON aqorders.ordernumber=aqorderbreakdown.ordernumber
        WHERE  bookfundid=?
            AND (datecancellationprinted IS NULL OR datecancellationprinted='0000-00-00')
            AND ((datereceived >= ? and datereceived < ?) OR (budgetdate >= ? and budgetdate < ?))
    ";
    my $sth = $dbh->prepare($query);
    $sth->execute( $id, $start, $end, $start, $end );

    my $spent = 0;
    while ( my $data = $sth->fetchrow_hashref ) {
        if ( $data->{'subscription'} == 1 ) {
            $spent += $data->{'quantity'} * $data->{'unitprice'};
        }
        else {

            my $leftover = $data->{'quantity'} - $data->{'quantityreceived'};
            $spent += ( $data->{'unitprice'} ) * $data->{'quantityreceived'};

        }
    }

    # then do a seperate query for commited totals, (pervious single query was
    # returning incorrect comitted results.

    my $query = "
        SELECT  quantity,datereceived,freight,unitprice,
                listprice,ecost,quantityreceived AS qrev,
                subscription,title,itemtype,aqorders.biblionumber,
                aqorders.booksellerinvoicenumber,
                quantity-quantityreceived AS tleft,
                aqorders.ordernumber AS ordnum,entrydate,budgetdate,
                booksellerid,aqbasket.basketno
        FROM    aqorderbreakdown,
                aqbasket,
                aqorders
        LEFT JOIN biblioitems ON biblioitems.biblioitemnumber=aqorders.biblioitemnumber
        WHERE   bookfundid=?
            AND aqorders.ordernumber=aqorderbreakdown.ordernumber
            AND aqorders.basketno=aqbasket.basketno
            AND (budgetdate >= ? AND budgetdate < ?)
            AND (datecancellationprinted IS NULL OR datecancellationprinted='0000-00-00')
    ";

    my $sth = $dbh->prepare($query);
    $sth->execute( $id, $start, $end );

    my $comtd;

    my $total = 0;
    while ( my $data = $sth->fetchrow_hashref ) {
        my $left = $data->{'tleft'};
        if ( !$left || $left eq '' ) {
            $left = $data->{'quantity'};
        }
        if ( $left && $left > 0 ) {
            my $subtotal = $left * $data->{'ecost'};
            $data->{subtotal} = $subtotal;
            $data->{'left'} = $left;
            $comtd += $subtotal;
        }
    }

    $sth->finish;
    return ( $spent, $comtd );
}

#-------------------------------------------------------------#

=head3 ModBookFund

=over 4

&ModBookFund($bookfundname,$branchcode,$bookfundid);
this function update the bookfundname and the branchcode on aqbookfund table
on database.

=back

=cut

sub ModBookFund {
    my ($bookfundname,$branchcode,$bookfundid) = @_;
    my $dbh = C4::Context->dbh;
    my $query = "
        UPDATE aqbookfund
        SET    bookfundname = ?,
               branchcode = ?
        WHERE  bookfundid = ?
    ";
    my $sth=$dbh->prepare($query);
    $sth->execute($bookfundname,$branchcode,$bookfundid);
# budgets depending on a bookfund must have the same branchcode
# if the bookfund branchcode is set
    if (defined $branchcode) {
        $query = "
            UPDATE aqbudget
            SET branchcode = ?
        ";
        $sth=$dbh->prepare($query);
        $sth->execute($branchcode);
    }
}

#-------------------------------------------------------------#

=head3 ModCurrencies

=over 4

&ModCurrencies($currency, $newrate);

Sets the exchange rate for C<$currency> to be C<$newrate>.

=back

=cut

sub ModCurrencies {
    my ( $currency, $rate ) = @_;
    my $dbh = C4::Context->dbh;
    my $query = "
        UPDATE currency
        SET    rate=?
        WHERE  currency=?
    ";
    my $sth = $dbh->prepare($query);
    $sth->execute( $rate, $currency );
}

#-------------------------------------------------------------#

=head3 Countbookfund

=over 4

$data = Countbookfund($bookfundid);

this function count the number of bookfund with id given on input arg.
return :
the result of the SQL query as an hashref.

=back

=cut

sub Countbookfund {
    my $bookfundid = @_;
    my $dbh = C4::Context->dbh;
    my $query ="
        SELECT COUNT(*)
        FROM   aqbookfund
        WHERE bookfundid = ?
    ";
    my $sth = $dbh->prepare($query);
    $sth->execute($bookfundid);
    return $sth->fetchrow_hashref;
}


#-------------------------------------------------------------#

=head3 ConvertCurrency

=over 4

$foreignprice = &ConvertCurrency($currency, $localprice);

Converts the price C<$localprice> to foreign currency C<$currency> by
dividing by the exchange rate, and returns the result.

If no exchange rate is found, C<&ConvertCurrency> assumes the rate is one
to one.

=back

=cut

sub ConvertCurrency {
    my ( $currency, $price ) = @_;
    my $dbh = C4::Context->dbh;
    my $query = "
        SELECT rate
        FROM   currency
        WHERE  currency=?
    ";
    my $sth = $dbh->prepare($query);
    $sth->execute($currency);
    my $cur = ( $sth->fetchrow_array() )[0];
    if ( $cur == 0 ) {
        $cur = 1;
    }
    return ( $price / $cur );
}


END { }    # module clean-up code here (global destructor)

1;

__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut
