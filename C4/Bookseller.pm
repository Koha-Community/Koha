package C4::Bookseller;

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

use vars qw($VERSION @ISA @EXPORT);

BEGIN {
	# set the version for version checking
	$VERSION = 3.01;
    require Exporter;
	@ISA    = qw(Exporter);
	@EXPORT = qw(
		&GetBookSeller &GetBooksellersWithLateOrders &GetBookSellerFromId
		&ModBookseller
		&DelBookseller
		&AddBookseller
	);
}


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

@results = &GetBookSeller($searchstring);

Looks up a book seller. C<$searchstring> may be either a book seller
ID, or a string to look for in the book seller's name.

C<@results> is an array of references-to-hash, whose keys are the fields of of the
aqbooksellers table in the Koha database.

=cut

# FIXME: This function is badly named.  It should be something like 
# SearchBookSellersByName.  It is NOT a singular return value.

sub GetBookSeller($) {
    my ($searchstring) = @_;
    my $dbh = C4::Context->dbh;
    my $query = "SELECT * FROM aqbooksellers WHERE name LIKE ?";
    my $sth =$dbh->prepare($query);
    $sth->execute( "$searchstring%" );
    my @results;
    # count how many baskets this bookseller has.
    # if it has none, the bookseller can be deleted
    my $sth2 = $dbh->prepare("SELECT count(*) FROM aqbasket WHERE booksellerid=?");
    while ( my $data = $sth->fetchrow_hashref ) {
        $sth2->execute($data->{id});
        $data->{basketcount} = $sth2->fetchrow();
        push( @results, $data );
    }
    $sth->finish;
    return  @results ;
}


sub GetBookSellerFromId($) {
	my ($id) = shift or return undef;
	my $dbh = C4::Context->dbh();
	my $query = "SELECT * FROM aqbooksellers WHERE id = ?";
	my $sth =$dbh->prepare($query);
	$sth->execute( $id );
	if (my $data = $sth->fetchrow_hashref()){
		my $sth2 = $dbh->prepare("SELECT count(*) FROM aqbasket WHERE booksellerid=?");
		$sth2->execute($id);
		$data->{basketcount}=$sth2->fetchrow();
		return ($data);
	}
	return 0;
}
#-----------------------------------------------------------------#

=head2 GetBooksellersWithLateOrders

%results = &GetBooksellersWithLateOrders;

Searches for suppliers with late orders.

=cut

sub GetBooksellersWithLateOrders {
    my ($delay,$branch) = @_; 	# FIXME: Branch argument unused.
    my $dbh   = C4::Context->dbh;

# FIXME NOT quite sure that this operation is valid for DBMs different from Mysql, HOPING so
# should be tested with other DBMs

    my $strsth;
    my $dbdriver = C4::Context->config("db_scheme") || "mysql";
    if ( $dbdriver eq "mysql" ) {
        $strsth = "
            SELECT DISTINCT aqbasket.booksellerid, aqbooksellers.name
            FROM aqorders LEFT JOIN aqbasket ON aqorders.basketno=aqbasket.basketno
            LEFT JOIN aqbooksellers ON aqbasket.booksellerid = aqbooksellers.id
            WHERE (closedate < DATE_SUB(CURDATE( ),INTERVAL $delay DAY)
                AND (datereceived = '' OR datereceived IS NULL))
        ";
    }
    else {
        $strsth = "
            SELECT DISTINCT aqbasket.booksellerid, aqbooksellers.name
            FROM aqorders LEFT JOIN aqbasket ON aqorders.basketno=aqbasket.basketno
            LEFT JOIN aqbooksellers ON aqbasket.aqbooksellerid = aqbooksellers.id
            WHERE (closedate < (CURDATE( )-(INTERVAL $delay DAY)))
                AND (datereceived = '' OR datereceived IS NULL))
        ";
    }

    my $sth = $dbh->prepare($strsth);
    $sth->execute;
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
    my ($data) = @_;
    my $dbh = C4::Context->dbh;
    my $query = "
        INSERT INTO aqbooksellers
            (
                name,      address1,      address2,   address3,      address4,
                postal,    phone,         fax,        url,           contact,
                contpos,   contphone,     contfax,    contaltphone,  contemail,
                contnotes, active,        listprice,  invoiceprice,  gstreg,
                listincgst,invoiceincgst, specialty,  discount,      invoicedisc,
                nocalc,    notes
            )
        VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
    ";
    my $sth = $dbh->prepare($query);
    $sth->execute(
        $data->{'name'},         $data->{'address1'},
        $data->{'address2'},     $data->{'address3'},
        $data->{'address4'},     $data->{'postal'},
        $data->{'phone'},        $data->{'fax'},
        $data->{'url'},          $data->{'contact'},
        $data->{'contpos'},      $data->{'contphone'},
        $data->{'contfax'},      $data->{'contaltphone'},
        $data->{'contemail'},    $data->{'contnotes'},
        $data->{'active'},       $data->{'listprice'},
        $data->{'invoiceprice'}, $data->{'gstreg'},
        $data->{'listincgst'},   $data->{'invoiceincgst'},
        $data->{'specialty'},    $data->{'discount'},
        $data->{'invoicedisc'},  $data->{'nocalc'},
        $data->{'notes'}
    );

    # return the id of this new supplier
    # FIXME: no protection against simultaneous addition: max(id) might be wrong!
    $query = "
        SELECT max(id)
        FROM   aqbooksellers
    ";
    $sth = $dbh->prepare($query);
    $sth->execute;
    return scalar($sth->fetchrow);
}

#-----------------------------------------------------------------#

=head2 ModSupplier

&ModSupplier($bookseller);

Updates the information for a given bookseller. C<$bookseller> is a
reference-to-hash whose keys are the fields of the aqbooksellers table
in the Koha database. It must contain entries for all of the fields.
The entry to modify is determined by C<$bookseller-E<gt>{id}>.

The easiest way to get all of the necessary fields is to look up a
book seller with C<&booksellers>, modify what's necessary, then call
C<&ModSupplier> with the result.

=cut

sub ModBookseller {
    my ($data) = @_;
    my $dbh    = C4::Context->dbh;
    my $query = "
        UPDATE aqbooksellers
        SET name=?,address1=?,address2=?,address3=?,address4=?,
            postal=?,phone=?,fax=?,url=?,contact=?,contpos=?,
            contphone=?,contfax=?,contaltphone=?,contemail=?,
            contnotes=?,active=?,listprice=?, invoiceprice=?,
            gstreg=?, listincgst=?,invoiceincgst=?,
            specialty=?,discount=?,invoicedisc=?,nocalc=?, notes=?
        WHERE id=?
    ";
    my $sth    = $dbh->prepare($query);
    $sth->execute(
        $data->{'name'},         $data->{'address1'},
        $data->{'address2'},     $data->{'address3'},
        $data->{'address4'},     $data->{'postal'},
        $data->{'phone'},        $data->{'fax'},
        $data->{'url'},          $data->{'contact'},
        $data->{'contpos'},      $data->{'contphone'},
        $data->{'contfax'},      $data->{'contaltphone'},
        $data->{'contemail'},    $data->{'contnotes'},
        $data->{'active'},       $data->{'listprice'},
        $data->{'invoiceprice'}, $data->{'gstreg'},
        $data->{'listincgst'},   $data->{'invoiceincgst'},
        $data->{'specialty'},    $data->{'discount'},
        $data->{'invoicedisc'},  $data->{'nocalc'},
        $data->{'notes'},        $data->{'id'}
    );
    $sth->finish;
}

=head2 DelBookseller

&DelBookseller($booksellerid);

delete the supplier identified by $booksellerid
This sub can be called only if the supplier has no order.

=cut
sub DelBookseller {
    my ($id) = @_;
    my $dbh=C4::Context->dbh;
    my $sth=$dbh->prepare("DELETE FROM aqbooksellers WHERE id=?");
    $sth->execute($id);
}

1;

__END__

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut
