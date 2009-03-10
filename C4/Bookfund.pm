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


use strict;
# use Smart::Comments;

use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 3.00;

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
    &GetBookFund &GetBookFunds &GetBookFundsId &GetBookFundBreakdown &GetCurrencies
    &NewBookFund
    &ModBookFund &ModCurrencies
    &SearchBookFund
    &Countbookfund 
    &ConvertCurrency
    &DelBookFund
);

=head1 FUNCTIONS

=cut

#-------------------------------------------------------------#

=head2 GetBookFund

$dataaqbookfund = &GetBookFund($bookfundid);

this function get the bookfundid, bookfundname, the bookfundgroup,  the branchcode
from aqbookfund table for bookfundid given on input arg.
return: 
C<$dataaqbookfund> is a hashref full of bookfundid, bookfundname, bookfundgroup,
and branchcode.

=cut

sub GetBookFund {
    my $bookfundid = shift;
    my $branchcode = shift;
    $branchcode=($branchcode?$branchcode:'');
    my $dbh = C4::Context->dbh;
    my $query = "
        SELECT
            bookfundid,
            bookfundname,
            bookfundgroup,
            branchcode
        FROM aqbookfund
        WHERE bookfundid = ?
        AND branchcode = ?";
    my $sth=$dbh->prepare($query);
    $sth->execute($bookfundid,$branchcode);
    my $data=$sth->fetchrow_hashref;
    return $data;
}


=head3 GetBookFundsId

$sth = &GetBookFundsId
Read on aqbookfund table and execute a simple SQL query.

return:
$sth->execute. Don't forget to fetch row from the database after using
this function by using, for example, $sth->fetchrow_hashref;

C<@results> is an array of id existing on the database.

=cut

sub GetBookFundsId {
    my @bookfundids_loop;
    my $dbh= C4::Context->dbh;
    my $query = "
        SELECT bookfundid,branchcode
        FROM aqbookfund
    ";
    my $sth = $dbh->prepare($query);
    $sth->execute;
    return $sth;
}

#-------------------------------------------------------------#

=head3 GetBookFunds

@results = &GetBookFunds;

Returns a list of all book funds.

C<@results> is an array of references-to-hash, whose keys are fields from the aqbookfund and aqbudget tables of the Koha database. Results are ordered
alphabetically by book fund name.

=cut

sub GetBookFunds {
    my ($branch) = @_;
    my $dbh      = C4::Context->dbh;
    my $userenv  = C4::Context->userenv;
    my $strsth;

    if ( $branch ne '' ) {
        $strsth = "
        SELECT *
        FROM   aqbookfund
        LEFT JOIN aqbudget ON aqbookfund.bookfundid=aqbudget.bookfundid
        WHERE  startdate<now()
            AND enddate>now()
            AND (aqbookfund.branchcode='' OR aqbookfund.branchcode= ? )
      GROUP BY aqbookfund.bookfundid ORDER BY bookfundname";
    }
    else {
        $strsth = "
            SELECT *
            FROM   aqbookfund
            LEFT JOIN aqbudget ON aqbookfund.bookfundid=aqbudget.bookfundid
            WHERE startdate<now()
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

@currencies = &GetCurrencies;

Returns the list of all known currencies.

C<$currencies> is a array; its elements are references-to-hash, whose
keys are the fields from the currency table in the Koha database.

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

( $spent, $comtd ) = &GetBookFundBreakdown( $id, $start, $end );

returns the total comtd & spent for a given bookfund, and a given year
used in acqui-home.pl

=cut

sub GetBookFundBreakdown {
    my ( $id, $start, $end ) = @_;
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
        LEFT JOIN aqbookfund ON (aqorderbreakdown.bookfundid=aqbookfund.bookfundid and aqorderbreakdown.branchcode=aqbookfund.branchcode)
        LEFT JOIN aqbudget ON (aqbudget.bookfundid=aqbookfund.bookfundid and aqbudget.branchcode=aqbookfund.branchcode)
        WHERE  aqorderbreakdown.bookfundid=?
            AND (datecancellationprinted IS NULL OR datecancellationprinted='0000-00-00')
            AND ((budgetdate >= ? and budgetdate < ?) OR (startdate>=? and enddate<=?))
    ";
    my $sth = $dbh->prepare($query);
    $sth->execute( $id, $start, $end, $start, $end );

    my ($spent) = 0;
    while ( my $data = $sth->fetchrow_hashref ) {
        if ( $data->{'subscription'} == 1 ) {
            $spent += $data->{'quantity'} * $data->{'unitprice'};
        }
        else {
            $spent += ( $data->{'unitprice'} ) * ($data->{'quantityreceived'}?$data->{'quantityreceived'}:0);

        }
    }

    # then do a seperate query for commited totals, (pervious single query was
    # returning incorrect comitted results.

    $query = "
        SELECT  quantity,datereceived,freight,unitprice,
                listprice,ecost,quantityreceived AS qrev,
                subscription,title,itemtype,aqorders.biblionumber,
                aqorders.booksellerinvoicenumber,
                quantity-quantityreceived AS tleft,
                aqorders.ordernumber AS ordnum,entrydate,budgetdate
        FROM    aqorders
        LEFT JOIN biblioitems ON biblioitems.biblioitemnumber=aqorders.biblioitemnumber
        LEFT JOIN aqorderbreakdown ON aqorders.ordernumber=aqorderbreakdown.ordernumber
        WHERE   bookfundid=?
            AND (budgetdate >= ? AND budgetdate < ?)
            AND (datecancellationprinted IS NULL OR datecancellationprinted='0000-00-00')
    ";

    $sth = $dbh->prepare($query);
#      warn "$start $end";     
    $sth->execute( $id, $start, $end );

    my $comtd=0;

    while ( my $data = $sth->fetchrow_hashref ) {
        my $left = $data->{'tleft'};
        if ( (!$left && (!$data->{'datereceived'}||$data->{'datereceived'} eq '0000-00-00') ) || $left eq '' ) {
            $left = $data->{'quantity'};
        }
        if ( $left && $left > 0 ) {
            my $subtotal = $left * $data->{'ecost'};
            $data->{subtotal} = $subtotal;
            $data->{'left'} = $left;
            $comtd += $subtotal;
        }
#         use Data::Dumper; warn Dumper($data);    
    }

    $sth->finish;
    return ( $spent, $comtd );
}

=head3 NewBookFund

&NewBookFund(bookfundid, bookfundname, branchcode);

this function create a new bookfund into the database.

=cut 

sub NewBookFund{
    my ($bookfundid, $bookfundname, $branchcode) = @_;
    $branchcode = undef unless $branchcode;
    my $dbh = C4::Context->dbh;
    my $query = "
        INSERT
        INTO aqbookfund
            (bookfundid, bookfundname, branchcode)
        VALUES
            (?, ?, ?)
    ";
    my $sth=$dbh->prepare($query);
    $sth->execute($bookfundid,$bookfundname,"$branchcode");
}

#-------------------------------------------------------------#

=head3 ModBookFund

&ModBookFund($bookfundname,$bookfundid,$current_branch, $branchcode)

This function updates the bookfundname and the branchcode in the aqbookfund table.

=cut

# FIXME: use placeholders,  ->prepare(), ->execute()

sub ModBookFund {
    my ($bookfundname,$bookfundid,$current_branch, $branchcode) = @_;

    my $dbh = C4::Context->dbh;

    my $retval = $dbh->do("
     UPDATE aqbookfund
        SET    bookfundname = '$bookfundname', 
               branchcode = '$branchcode'
        WHERE  bookfundid = '$bookfundid'
        AND branchcode = '$current_branch'
    ");

    ### $retval

    # budgets depending on a bookfund must have the same branchcode

    # if the bookfund branchcode is set, and previous update is successfull, then update aqbudget.branchcode too.
    if (defined $branchcode && $retval > 0) {
        my $query = "UPDATE  aqbudget  
            SET     branchcode = ?
            WHERE   bookfundid = ? ";

        my $sth=$dbh->prepare($query);
        $sth->execute($branchcode, $bookfundid) ;
    }
}

#-------------------------------------------------------------#

=head3 SearchBookFund

@results = SearchBookFund(
        $bookfundid,$filter,$filter_bookfundid,
        $filter_bookfundname,$filter_branchcode);

this function searchs among the bookfunds corresponding to our filtering rules.

=cut

sub SearchBookFund {
    my $dbh = C4::Context->dbh;
    my ($filter,
        $filter_bookfundid,
        $filter_bookfundname,
        $filter_branchcode
       ) = @_;

    my @bindings;

    my $query = "
        SELECT  bookfundid,
                bookfundname,
                bookfundgroup,
                branchcode
        FROM aqbookfund
        WHERE 1 ";

    if ($filter) {
        if ($filter_bookfundid) {
            $query.= "AND bookfundid = ?";
            push @bindings, $filter_bookfundid;
        }
        if ($filter_bookfundname) {
            $query.= "AND bookfundname like ?";
            push @bindings, '%'.$filter_bookfundname.'%';
        }
        if ($filter_branchcode) {
            $query.= "AND branchcode = ?";
            push @bindings, $filter_branchcode;
        }
    }
    $query.= "ORDER BY bookfundid";

    my $sth = $dbh->prepare($query);
    $sth->execute(@bindings);
    my @results;
    while (my $row = $sth->fetchrow_hashref) {
        push @results, $row;
    }
    return @results;
}

#-------------------------------------------------------------#

=head3 ModCurrencies

&ModCurrencies($currency, $newrate);

Sets the exchange rate for C<$currency> to be C<$newrate>.

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

$number = Countbookfund($bookfundid);

this function count the number of bookfund with id given on input arg.
return :
the result of the SQL query as a number.

=cut

sub Countbookfund {
    my $bookfundid = shift;
    my $branchcode = shift;
    my $dbh = C4::Context->dbh;
    my $query ="
        SELECT COUNT(*)
        FROM  aqbookfund
        WHERE bookfundid = ?
        AND   branchcode = ?
    ";
    my $sth = $dbh->prepare($query);
    $sth->execute($bookfundid,"$branchcode");
    return $sth->fetchrow;
}


#-------------------------------------------------------------#

=head3 ConvertCurrency

$foreignprice = &ConvertCurrency($currency, $localprice);

Converts the price C<$localprice> to foreign currency C<$currency> by
dividing by the exchange rate, and returns the result.

If no exchange rate is found, C<&ConvertCurrency> assumes the rate is one
to one.

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
    unless($cur) {
        $cur = 1;
    }
    return ( $price / $cur );
}

#-------------------------------------------------------------#

=head3 DelBookFund

&DelBookFund($bookfundid);
this function delete a bookfund which has $bokfundid as parameter on aqbookfund table and delete the approriate budget.

=cut

sub DelBookFund {
    my $bookfundid = shift;
    my $branchcode=shift;
    my $dbh = C4::Context->dbh;
    my $query = "
        DELETE FROM aqbookfund
        WHERE bookfundid=?
        AND branchcode=?
    ";
    my $sth=$dbh->prepare($query);
    $sth->execute($bookfundid,$branchcode);
    $sth->finish;
    $query = "
        DELETE FROM aqbudget where bookfundid=? and branchcode=?
    ";
    $sth=$dbh->prepare($query);
    $sth->execute($bookfundid,$branchcode);
    $sth->finish;
}

END { }    # module clean-up code here (global destructor)

1;

__END__

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut
