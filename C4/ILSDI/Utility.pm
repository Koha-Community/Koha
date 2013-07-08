package C4::ILSDI::Utility;

# Copyright 2009 SARL Biblibre
# Copyright 2011 software.coop and MJ Ray
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
use C4::Reserves qw(GetReservesFromBorrowernumber CanBookBeReserved);
use C4::Context;
use C4::Branch qw/GetBranchName/;
use Digest::MD5 qw(md5_base64);

use vars qw($VERSION @ISA @EXPORT);

BEGIN {

    # set the version for version checking
    $VERSION = 3.07.00.049;
    require Exporter;
    @ISA    = qw(Exporter);
    @EXPORT = qw(
      &BorrowerExists &Availability
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
    } elsif ( $item->{'withdrawn'} ) {
        return ( $biblionumber, 'not available', 'Item withdrawn', $location );
    } elsif ( $item->{'damaged'} ) {
        return ( $biblionumber, 'not available', 'Item damaged', $location );
    } else {
        return ( $biblionumber, 'available', undef, $location );
    }

    die Data::Dumper::Dumper($item);
}

1;
