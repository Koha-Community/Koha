package C4::ILSDI::Utility;

# Copyright 2009 SARL Biblibre
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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
use warnings;

use C4::Members;
use C4::Items;
use C4::Circulation;
use C4::Biblio;
use C4::Reserves qw(GetReservesFromBorrowernumber);
use C4::Context;
use C4::Branch qw/GetBranchName/;
use Digest::MD5 qw(md5_base64);

use vars qw($VERSION @ISA @EXPORT);

BEGIN {

    # set the version for version checking
    $VERSION = 3.00;
    require Exporter;
    @ISA    = qw(Exporter);
    @EXPORT = qw(
      &BorrowerExists &CanBookBeReserved &Availability
    );
}

=head1 NAME

C4::ILS-DI::Utility - ILS-DI Utilities

=cut

=head2 BorrowerExists

Checks, for a given userid and password, if the borrower exists.

	if ( BorrowerExists($userid, $password) ) {
		# Do stuff
	}

=cut

sub BorrowerExists {
    my ( $userid, $password ) = @_;
    $password = md5_base64($password);
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT COUNT(*) FROM borrowers WHERE userid =? and password=? ");
    $sth->execute( $userid, $password );
    return $sth->fetchrow;
}

=head2 CanBookBeReserved

Checks if a book (at bibliographic level) can be reserved by a borrower.

	if ( CanBookBeReserved($borrower, $biblionumber) ) {
		# Do stuff
	}

=cut

sub CanBookBeReserved {
    my ( $borrower, $biblionumber ) = @_;

    my $MAXIMUM_NUMBER_OF_RESERVES = C4::Context->preference("maxreserves");
    my $MAXOUTSTANDING             = C4::Context->preference("maxoutstanding");

    my $out = 1;

    if ( $borrower->{'amountoutstanding'} > $MAXOUTSTANDING ) {
        $out = undef;
    }
    if ( $borrower->{gonenoaddress} eq 1 ) {
        $out = undef;
    }
    if ( $borrower->{lost} eq 1 ) {
        $out = undef;
    }
    if ( $borrower->{debarred} ) {
        $out = undef;
    }
    my @reserves = GetReservesFromBorrowernumber( $borrower->{'borrowernumber'} );
    if ( $MAXIMUM_NUMBER_OF_RESERVES && scalar(@reserves) >= $MAXIMUM_NUMBER_OF_RESERVES ) {
        $out = undef;
    }
    foreach my $res (@reserves) {
        if ( $res->{'biblionumber'} == $biblionumber ) {
            $out = undef;
        }
    }
    my $issues = GetPendingIssues( $borrower->{'borrowernumber'} );
    foreach my $issue (@$issues) {
        if ( $issue->{'biblionumber'} == $biblionumber ) {
            $out = undef;
        }
    }

    return $out;
}

=head2 Availability

Returns, for an itemnumber, an array containing availability information.

	my ($biblionumber, $status, $msg, $location) = Availability($id);

=cut

sub Availability {
    my ($itemnumber) = @_;
    my $item = GetItem( $itemnumber, undef, undef );

    if ( not $item->{'itemnumber'} ) {
        return ( undef, 'unknown', 'Error: could not retrieve availability for this ID', undef );
    }

    my $biblionumber = $item->{'biblioitemnumber'};
    my $location     = GetBranchName( $item->{'holdingbranch'} );

    if ( $item->{'notforloan'} ) {
        return ( $biblionumber, 'not available', 'Not for loan', $location );
    } elsif ( $item->{'onloan'} ) {
        return ( $biblionumber, 'not available', 'Checked out', $location );
    } elsif ( $item->{'itemlost'} ) {
        return ( $biblionumber, 'not available', 'Item lost', $location );
    } elsif ( $item->{'wthdrawn'} ) {
        return ( $biblionumber, 'not available', 'Item withdrawn', $location );
    } elsif ( $item->{'damaged'} ) {
        return ( $biblionumber, 'not available', 'Item damaged', $location );
    } else {
        return ( $biblionumber, 'available', undef, $location );
    }

    die Data::Dumper::Dumper($item);
}

1;
