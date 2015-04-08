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

use C4::Bookseller::Contact;

# set the version for version checking
our $VERSION   = 3.07.00.049;
our @EXPORT_OK = qw(
  GetBookSeller GetBooksellersWithLateOrders GetBookSellerFromId
  ModBookseller
  DelBookseller
  AddBookseller
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

=head2 GetBookSeller

@results = GetBookSeller($searchstring);

Looks up a book seller. C<$searchstring> is a string to look for in the
book seller's name.

C<@results> is an array of hash_refs whose keys are the fields of of the
aqbooksellers table in the Koha database.

=cut

sub GetBookSeller {
    my $searchstring = shift;
    $searchstring = q{%} . $searchstring . q{%};
    my $query = "
        SELECT aqbooksellers.*, count(*) AS basketcount
        FROM aqbooksellers
        LEFT JOIN aqbasket ON aqbasket.booksellerid = aqbooksellers.id
        WHERE name LIKE ? GROUP BY aqbooksellers.id ORDER BY name
    ";

    my $dbh           = C4::Context->dbh;
    my $sth           = $dbh->prepare($query);
    $sth->execute($searchstring);
    my $resultset_ref = $sth->fetchall_arrayref( {} );
    return @{$resultset_ref};
}

sub GetBookSellerFromId {
    my $id = shift or return;
    my $dbh = C4::Context->dbh;
    my $vendor =
      $dbh->selectrow_hashref( 'SELECT * FROM aqbooksellers WHERE id = ?',
        {}, $id );
    if ($vendor) {
        ( $vendor->{basketcount} ) = $dbh->selectrow_array(
            'SELECT count(*) FROM aqbasket where booksellerid = ?',
            {}, $id );
        ( $vendor->{subscriptioncount} ) = $dbh->selectrow_array(
            'SELECT count(*) FROM subscription WHERE aqbooksellerid = ?',
            {}, $id );
        $vendor->{'contacts'} = C4::Bookseller::Contact->get_from_bookseller($id);
    }
    return $vendor;
}

#-----------------------------------------------------------------#

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
            AND aqorders.rrp <> 0
            AND aqorders.ecost <> 0
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

#--------------------------------------------------------------------#

=head2 AddBookseller

$id = &AddBookseller($bookseller);

Creates a new bookseller. C<$bookseller> is a reference-to-hash whose
keys are the fields of the aqbooksellers table in the Koha database.
All fields must be present.

Returns the ID of the newly-created bookseller.

=cut

sub AddBookseller {
    my ($data, $contacts) = @_;
    my $dbh    = C4::Context->dbh;
    my $query = q|
        INSERT INTO aqbooksellers
            (
                name,      address1,      address2,     address3, address4,
                postal,    phone,         accountnumber,fax,      url,
                active,    listprice,     invoiceprice, gstreg,
                listincgst,invoiceincgst, gstrate,      discount, notes,
                deliverytime
            )
        VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) |
      ;
    my $sth = $dbh->prepare($query);
    $sth->execute(
        $data->{'name'},         $data->{'address1'},
        $data->{'address2'},     $data->{'address3'},
        $data->{'address4'},     $data->{'postal'},
        $data->{'phone'},        $data->{'accountnumber'},
        $data->{'fax'},          $data->{'url'},
        $data->{'active'},       $data->{'listprice'},
        $data->{'invoiceprice'}, $data->{'gstreg'},
        $data->{'listincgst'},   $data->{'invoiceincgst'},
        $data->{'gstrate'},      $data->{'discount'},
        $data->{notes},          $data->{deliverytime},
    );

    # return the id of this new supplier
    my $id = $dbh->{'mysql_insertid'};
    if ($id && $contacts) {
        foreach my $contact (@$contacts) {
            $contact = C4::Bookseller::Contact->new( $contact )
                unless ref $contacts eq 'C4::Bookseller::Contact';
            $contact->bookseller($id);
            $contact->save();
        }
    }
    return $id;
}

#-----------------------------------------------------------------#

=head2 ModBookseller

ModBookseller($bookseller);

Updates the information for a given bookseller. C<$bookseller> is a
reference-to-hash whose keys are the fields of the aqbooksellers table
in the Koha database. It must contain entries for all of the fields.
The entry to modify is determined by C<$bookseller-E<gt>{id}>.

The easiest way to get all of the necessary fields is to look up a
book seller with C<&GetBookseller>, modify what's necessary, then call
C<&ModBookseller> with the result.

=cut

sub ModBookseller {
    my ($data, $contacts) = @_;
    my $dbh    = C4::Context->dbh;
    return unless $data->{'id'};
    my $query  = 'UPDATE aqbooksellers
        SET name=?,address1=?,address2=?,address3=?,address4=?,
            postal=?,phone=?,accountnumber=?,fax=?,url=?,
            active=?,listprice=?, invoiceprice=?,
            gstreg=?,listincgst=?,invoiceincgst=?,
            discount=?,notes=?,gstrate=?,deliverytime=?
        WHERE id=?';
    my $sth = $dbh->prepare($query);
    my $cnt = $sth->execute(
        $data->{'name'},         $data->{'address1'},
        $data->{'address2'},     $data->{'address3'},
        $data->{'address4'},     $data->{'postal'},
        $data->{'phone'},        $data->{'accountnumber'},
        $data->{'fax'},          $data->{'url'},
        $data->{'active'},       $data->{'listprice'},
        $data->{'invoiceprice'}, $data->{'gstreg'},
        $data->{'listincgst'},   $data->{'invoiceincgst'},
        $data->{'discount'},     $data->{'notes'},
        $data->{'gstrate'},      $data->{deliverytime},
        $data->{'id'}
    );
    $contacts ||= $data->{'contacts'};
    my $contactquery = "DELETE FROM aqcontacts WHERE booksellerid = ?";
    my @contactparams = ($data->{'id'});
    if ($contacts) {
        foreach my $contact (@$contacts) {
            $contact = C4::Bookseller::Contact->new( $contact )
                unless ref $contacts eq 'C4::Bookseller::Contact';
            $contact->bookseller($data->{'id'});
            $contact->save();
            push @contactparams, $contact->id if $contact->id;
        }
        if ($#contactparams > 0) {
            $contactquery .= ' AND id NOT IN (' . ('?, ' x ($#contactparams - 1)) . '?);';
        }
    }
    $sth = $dbh->prepare($contactquery);
    $sth->execute(@contactparams);
    return $cnt;
}

=head2 DelBookseller

DelBookseller($booksellerid);

delete the supplier record identified by $booksellerid
This sub assumes it is called only if the supplier has no order.

=cut

sub DelBookseller {
    my $id  = shift;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare('DELETE FROM aqbooksellers WHERE id=?');
    return $sth->execute($id);
}

1;

__END__

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

=cut
