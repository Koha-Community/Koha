package C4::ILSDI::Services;

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
use C4::Branch;
use C4::Accounts;
use C4::Biblio;
use C4::Reserves qw(AddReserve GetReservesFromBiblionumber GetReservesFromBorrowernumber CanBookBeReserved CanItemBeReserved IsAvailableForItemLevelRequest);
use C4::Context;
use C4::AuthoritiesMarc;
use XML::Simple;
use HTML::Entities;
use CGI;
use DateTime;
use C4::Auth;

=head1 NAME

C4::ILS-DI::Services - ILS-DI Services

=head1 DESCRIPTION

Each function in this module represents an ILS-DI service.
They all takes a CGI instance as argument and most of them return a 
hashref that will be printed by XML::Simple in opac/ilsdi.pl

=head1 SYNOPSIS

	use C4::ILSDI::Services;
	use XML::Simple;
	use CGI;

	my $cgi = new CGI;

	$out = LookupPatron($cgi);

	print CGI::header('text/xml');
	print XMLout($out,
		noattr => 1, 
		noescape => 1,
		nosort => 1,
                xmldecl => '<?xml version="1.0" encoding="UTF-8" ?>',
		RootName => 'LookupPatron', 
		SuppressEmpty => 1);

=cut

=head1 FUNCTIONS

=head2 GetAvailability

Given a set of biblionumbers or itemnumbers, returns a list with 
availability of the items associated with the identifiers.

Parameters:

=head3 id (Required)

list of either biblionumbers or itemnumbers

=head3 id_type (Required)

defines the type of record identifier being used in the request, 
possible values:

  - bib
  - item

=head3 return_type (Optional)

requests a particular level of detail in reporting availability, 
possible values:

  - bib
  - item

=head3 return_fmt (Optional)

requests a particular format or set of formats in reporting 
availability 

=cut

sub GetAvailability {
    my ($cgi) = @_;

    my $out = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n";
    $out .= "<dlf:collection\n";
    $out .= "  xmlns:dlf=\"http://diglib.org/ilsdi/1.1\"\n";
    $out .= "  xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\n";
    $out .= "  xsi:schemaLocation=\"http://diglib.org/ilsdi/1.1\n";
    $out .= "    http://diglib.org/architectures/ilsdi/schemas/1.1/dlfexpanded.xsd\">\n";

    foreach my $id ( split( / /, $cgi->param('id') ) ) {
        if ( $cgi->param('id_type') eq "item" ) {
            my ( $biblionumber, $status, $msg, $location ) = _availability($id);

            $out .= "  <dlf:record>\n";
            $out .= "    <dlf:bibliographic id=\"" . ( $biblionumber || $id ) . "\" />\n";
            $out .= "    <dlf:items>\n";
            $out .= "      <dlf:item id=\"" . $id . "\">\n";
            $out .= "        <dlf:simpleavailability>\n";
            $out .= "          <dlf:identifier>" . $id . "</dlf:identifier>\n";
            $out .= "          <dlf:availabilitystatus>" . $status . "</dlf:availabilitystatus>\n";
            if ($msg)      { $out .= "          <dlf:availabilitymsg>" . $msg . "</dlf:availabilitymsg>\n"; }
            if ($location) { $out .= "          <dlf:location>" . $location . "</dlf:location>\n"; }
            $out .= "        </dlf:simpleavailability>\n";
            $out .= "      </dlf:item>\n";
            $out .= "    </dlf:items>\n";
            $out .= "  </dlf:record>\n";
        } else {
            my $status;
            my $msg;
            my $biblioitem = ( GetBiblioItemByBiblioNumber( $id, undef ) )[0];
            if ($biblioitem) {

            } else {
                $status = "unknown";
                $msg    = "Error: could not retrieve availability for this ID";
            }
            $out .= "  <dlf:record>\n";
            $out .= "    <dlf:bibliographic id=\"" . $id . "\" />\n";
            $out .= "    <dlf:simpleavailability>\n";
            $out .= "      <dlf:identifier>" . $id . "</dlf:identifier>\n";
            $out .= "      <dlf:availabilitystatus>" . $status . "</dlf:availabilitystatus>\n";
            $out .= "      <dlf:availabilitymsg>" . $msg . "</dlf:availabilitymsg>\n";
            $out .= "    </dlf:simpleavailability>\n";
            $out .= "  </dlf:record>\n";
        }
    }
    $out .= "</dlf:collection>\n";

    return $out;
}

=head2 GetRecords

Given a list of biblionumbers, returns a list of record objects that 
contain bibliographic information, as well as associated holdings and item
information. The caller may request a specific metadata schema for the 
record objects to be returned.

This function behaves similarly to HarvestBibliographicRecords and 
HarvestExpandedRecords in Data Aggregation, but allows quick, real time 
lookup by bibliographic identifier.

You can use OAI-PMH ListRecords instead of this service.

Parameters:

  - id (Required)
	list of system record identifiers
  - id_type (Optional)
	Defines the metadata schema in which the records are returned, 
	possible values:
  	  - MARCXML

=cut

sub GetRecords {
    my ($cgi) = @_;

    # Check if the schema is supported. For now, GetRecords only supports MARCXML
    if ( $cgi->param('schema') and $cgi->param('schema') ne "MARCXML" ) {
        return { code => 'UnsupportedSchema' };
    }

    my @records;

    # Loop over biblionumbers
    foreach my $biblionumber ( split( / /, $cgi->param('id') ) ) {

        # Get the biblioitem from the biblionumber
        my $biblioitem = ( GetBiblioItemByBiblioNumber( $biblionumber, undef ) )[0];
        if ( not $biblioitem->{'biblionumber'} ) {
            $biblioitem->{code} = "RecordNotFound";
        }

        my $embed_items = 1;
        my $record = GetMarcBiblio($biblionumber, $embed_items);
        if ($record) {
            $biblioitem->{marcxml} = $record->as_xml_record();
        }

        # We don't want MARC to be displayed
        delete $biblioitem->{'marc'};

        # Get most of the needed data
        my $biblioitemnumber = $biblioitem->{'biblioitemnumber'};
        my $reserves         = GetReservesFromBiblionumber({ biblionumber => $biblionumber });
        my $issues           = GetBiblioIssues($biblionumber);
        my $items            = GetItemsByBiblioitemnumber($biblioitemnumber);

        # We loop over the items to clean them
        foreach my $item (@$items) {

            # This hides additionnal XML subfields, we don't need these info
            delete $item->{'more_subfields_xml'};

            # Display branch names instead of branch codes
            $item->{'homebranchname'}    = GetBranchName( $item->{'homebranch'} );
            $item->{'holdingbranchname'} = GetBranchName( $item->{'holdingbranch'} );
        }

        # Hashref building...
        $biblioitem->{'items'}->{'item'}       = $items;
        $biblioitem->{'reserves'}->{'reserve'} = $reserves;
        $biblioitem->{'issues'}->{'issue'}     = $issues;

        push @records, $biblioitem;
    }

    return { record => \@records };
}

=head2 GetAuthorityRecords

Given a list of authority record identifiers, returns a list of record 
objects that contain the authority records. The function user may request 
a specific metadata schema for the record objects.

Parameters:

  - id (Required)
    list of authority record identifiers
  - schema (Optional)
    specifies the metadata schema of records to be returned, possible values:
      - MARCXML

=cut

sub GetAuthorityRecords {
    my ($cgi) = @_;

    # If the user asks for an unsupported schema, return an error code
    if ( $cgi->param('schema') and $cgi->param('schema') ne "MARCXML" ) {
        return { code => 'UnsupportedSchema' };
    }

    my @records;

    # Let's loop over the authority IDs
    foreach my $authid ( split( / /, $cgi->param('id') ) ) {

        # Get the record as XML string, or error code
        push @records, GetAuthorityXML($authid) || { code => 'RecordNotFound' };
    }

    return { record => \@records };
}

=head2 LookupPatron

Looks up a patron in the ILS by an identifier, and returns the borrowernumber.

Parameters:

  - id (Required)
	an identifier used to look up the patron in Koha
  - id_type (Optional)
	the type of the identifier, possible values:
	- cardnumber
	- firstname
	- userid
	- borrowernumber

=cut

sub LookupPatron {
    my ($cgi) = @_;

    # Get the borrower...
    my $borrower = GetMember($cgi->param('id_type') => $cgi->param('id'));
    if ( not $borrower->{'borrowernumber'} ) {
        return { message => 'PatronNotFound' };
    }

    # Build the hashref
    my $patron->{'id'} = $borrower->{'borrowernumber'};
    return { code => 'PatronNotFound' } unless $$borrower{borrowernumber};

    # ...and return his ID
    return $patron;
}

=head2 AuthenticatePatron

Authenticates a user's login credentials and returns the identifier for 
the patron.

Parameters:

  - username (Required)
    user's login identifier (userid or cardnumber)
  - password (Required)
    user's password

=cut

sub AuthenticatePatron {
    my ($cgi) = @_;
    my ($status, $cardnumber, $userid) = C4::Auth::checkpw( C4::Context->dbh, $cgi->param('username'), $cgi->param('password') );
    if ( $status ) {
        # Get the borrower
        my $borrower = GetMember( cardnumber => $cardnumber );
        my $patron->{'id'} = $borrower->{'borrowernumber'};
        return $patron;
    }
    else {
        return { code => 'PatronNotFound' };
    }
}

=head2 GetPatronInfo

Returns specified information about the patron, based on options in the 
request. This function can optionally return patron's contact information, 
fine information, hold request information, and loan information.

Parameters:

  - patron_id (Required)
	the borrowernumber
  - show_contact (Optional, default 1)
	whether or not to return patron's contact information in the response
  - show_fines (Optional, default 0)
	whether or not to return fine information in the response
  - show_holds (Optional, default 0)
	whether or not to return hold request information in the response
  - show_loans (Optional, default 0)
	whether or not to return loan information request information in the response 

=cut

sub GetPatronInfo {
    my ($cgi) = @_;

    # Get Member details
    my $borrowernumber = $cgi->param('patron_id');
    my $borrower = GetMemberDetails( $borrowernumber );
    return { code => 'PatronNotFound' } unless $$borrower{borrowernumber};

    # Cleaning the borrower hashref
    $borrower->{'charges'}    = $borrower->{'flags'}->{'CHARGES'}->{'amount'};
    $borrower->{'branchname'} = GetBranchName( $borrower->{'branchcode'} );
    delete $borrower->{'flags'};
    delete $borrower->{'userid'};
    delete $borrower->{'password'};

    # Contact fields management
    if ( $cgi->param('show_contact') eq "0" ) {

        # Define contact fields
        my @contactfields = (
            'email',              'emailpro',           'fax',                 'mobile',          'phone',             'phonepro',
            'streetnumber',       'zipcode',            'city',                'streettype',      'B_address',         'B_city',
            'B_email',            'B_phone',            'B_zipcode',           'address',         'address2',          'altcontactaddress1',
            'altcontactaddress2', 'altcontactaddress3', 'altcontactfirstname', 'altcontactphone', 'altcontactsurname', 'altcontactzipcode'
        );

        # and delete them
        foreach my $field (@contactfields) {
            delete $borrower->{$field};
        }
    }

    # Fines management
    if ( $cgi->param('show_fines') eq "1" ) {
        my @charges;
        for ( my $i = 1 ; my @charge = getcharges( $borrowernumber, undef, $i ) ; $i++ ) {
            push( @charges, @charge );
        }
        $borrower->{'fines'}->{'fine'} = \@charges;
    }

    # Reserves management
    if ( $cgi->param('show_holds') eq "1" ) {

        # Get borrower's reserves
        my @reserves = GetReservesFromBorrowernumber( $borrowernumber, undef );
        foreach my $reserve (@reserves) {

            # Get additional informations
            my $item = GetBiblioFromItemNumber( $reserve->{'itemnumber'}, undef );
            my $branchname = GetBranchName( $reserve->{'branchcode'} );

            # Remove unwanted fields
            delete $item->{'marc'};
            delete $item->{'marcxml'};
            delete $item->{'more_subfields_xml'};

            # Add additional fields
            $reserve->{'item'}       = $item;
            $reserve->{'branchname'} = $branchname;
            $reserve->{'title'}      = GetBiblio( $reserve->{'biblionumber'} )->{'title'};
        }
        $borrower->{'holds'}->{'hold'} = \@reserves;
    }

    # Issues management
    if ( $cgi->param('show_loans') eq "1" ) {
        my $issues = GetPendingIssues($borrowernumber);
        foreach my $issue ( @$issues ){
            $issue->{'issuedate'} = $issue->{'issuedate'}->strftime('%Y-%m-%d %H:%M');
            $issue->{'date_due'} = $issue->{'date_due'}->strftime('%Y-%m-%d %H:%M');
        }
        $borrower->{'loans'}->{'loan'} = $issues;
    }

    return $borrower;
}

=head2 GetPatronStatus

Returns a patron's status information.

Parameters:

  - patron_id (Required)
	the borrower ID

=cut

sub GetPatronStatus {
    my ($cgi) = @_;

    # Get Member details
    my $borrowernumber = $cgi->param('patron_id');
    my $borrower = GetMemberDetails( $borrowernumber );
    return { code => 'PatronNotFound' } unless $$borrower{borrowernumber};

    # Return the results
    return {
        type   => $$borrower{categorycode},
        status => 0, # TODO
        expiry => $$borrower{dateexpiry},
    };
}

=head2 GetServices

Returns information about the services available on a particular item for 
a particular patron.

Parameters:

  - patron_id (Required)
	a borrowernumber
  - item_id (Required)
	an itemnumber
=cut

sub GetServices {
    my ($cgi) = @_;

    # Get the member, or return an error code if not found
    my $borrowernumber = $cgi->param('patron_id');
    my $borrower = GetMemberDetails( $borrowernumber );
    return { code => 'PatronNotFound' } unless $$borrower{borrowernumber};

    # Get the item, or return an error code if not found
    my $itemnumber = $cgi->param('item_id');
    my $item = GetItem( $itemnumber );
    return { code => 'RecordNotFound' } unless $$item{itemnumber};

    my @availablefor;

    # Reserve level management
    my $biblionumber = $item->{'biblionumber'};
    my $canbookbereserved = CanBookBeReserved( $borrower, $biblionumber );
    if ($canbookbereserved eq 'OK') {
        push @availablefor, 'title level hold';
        my $canitembereserved = IsAvailableForItemLevelRequest($itemnumber);
        if ($canitembereserved) {
            push @availablefor, 'item level hold';
        }
    }

    # Reserve cancellation management
    my @reserves = GetReservesFromBorrowernumber( $borrowernumber, undef );
    my @reserveditems;
    foreach my $reserve (@reserves) {
        push @reserveditems, $reserve->{'itemnumber'};
    }
    if ( grep { $itemnumber eq $_ } @reserveditems ) {
        push @availablefor, 'hold cancellation';
    }

    # Renewal management
    my @renewal = CanBookBeRenewed( $borrowernumber, $itemnumber );
    if ( $renewal[0] ) {
        push @availablefor, 'loan renewal';
    }

    # Issuing management
    my $barcode = $item->{'barcode'} || '';
    $barcode = barcodedecode($barcode) if ( $barcode && C4::Context->preference('itemBarcodeInputFilter') );
    if ($barcode) {
        my ( $issuingimpossible, $needsconfirmation ) = CanBookBeIssued( $borrower, $barcode );

        # TODO push @availablefor, 'loan';
    }

    my $out;
    $out->{'AvailableFor'} = \@availablefor;

    return $out;
}

=head2 RenewLoan

Extends the due date for a borrower's existing issue.

Parameters:

  - patron_id (Required)
	a borrowernumber
  - item_id (Required)
	an itemnumber
  - desired_due_date (Required)
	the date the patron would like the item returned by 

=cut

sub RenewLoan {
    my ($cgi) = @_;

    # Get borrower infos or return an error code
    my $borrowernumber = $cgi->param('patron_id');
    my $borrower = GetMemberDetails( $borrowernumber );
    return { code => 'PatronNotFound' } unless $$borrower{borrowernumber};

    # Get the item, or return an error code
    my $itemnumber = $cgi->param('item_id');
    my $item = GetItem( $itemnumber );
    return { code => 'RecordNotFound' } unless $$item{itemnumber};

    # Add renewal if possible
    my @renewal = CanBookBeRenewed( $borrowernumber, $itemnumber );
    if ( $renewal[0] ) { AddRenewal( $borrowernumber, $itemnumber ); }

    my $issue = GetItemIssue($itemnumber);

    # Hashref building
    my $out;
    $out->{'renewals'} = $issue->{'renewals'};
    $out->{date_due}   = $issue->{date_due}->strftime('%Y-%m-%d %H:%S');
    $out->{'success'}  = $renewal[0];
    $out->{'error'}    = $renewal[1];

    return $out;
}

=head2 HoldTitle

Creates, for a borrower, a biblio-level hold reserve.

Parameters:

  - patron_id (Required)
	a borrowernumber
  - bib_id (Required)
	a biblionumber
  - request_location (Required)
	IP address where the end user request is being placed
  - pickup_location (Optional)
	a branch code indicating the location to which to deliver the item for pickup
  - needed_before_date (Optional)
	date after which hold request is no longer needed
  - pickup_expiry_date (Optional)
	date after which item returned to shelf if item is not picked up 

=cut

sub HoldTitle {
    my ($cgi) = @_;

    # Get the borrower or return an error code
    my $borrowernumber = $cgi->param('patron_id');
    my $borrower = GetMemberDetails( $borrowernumber );
    return { code => 'PatronNotFound' } unless $$borrower{borrowernumber};

    # Get the biblio record, or return an error code
    my $biblionumber = $cgi->param('bib_id');
    my $biblio = GetBiblio( $biblionumber );
    return { code => 'RecordNotFound' } unless $$biblio{biblionumber};
    
    my $title = $$biblio{title};

    # Check if the biblio can be reserved
    return { code => 'NotHoldable' } unless CanBookBeReserved( $borrowernumber, $biblionumber ) eq 'OK';

    my $branch;

    # Pickup branch management
    if ( $cgi->param('pickup_location') ) {
        $branch = $cgi->param('pickup_location');
        my $branches = GetBranches;
        return { code => 'LocationNotFound' } unless $$branches{$branch};
    } else { # if the request provide no branch, use the borrower's branch
        $branch = $$borrower{branchcode};
    }

    # Add the reserve
    #    $branch,    $borrowernumber, $biblionumber,
    #    $constraint, $bibitems,  $priority, $resdate, $expdate, $notes,
    #    $title,      $checkitem, $found
    my $priority= C4::Reserves::CalculatePriority( $biblionumber );
    AddReserve( $branch, $borrowernumber, $biblionumber, 'a', undef, $priority, undef, undef, undef, $title, undef, undef );

    # Hashref building
    my $out;
    $out->{'title'}           = $title;
    $out->{'pickup_location'} = GetBranchName($branch);

    # TODO $out->{'date_available'}  = '';

    return $out;
}

=head2 HoldItem

Creates, for a borrower, an item-level hold request on a specific item of 
a bibliographic record in Koha.

Parameters:

  - patron_id (Required)
	a borrowernumber
  - bib_id (Required)
	a biblionumber
  - item_id (Required)
	an itemnumber
  - pickup_location (Optional)
	a branch code indicating the location to which to deliver the item for pickup
  - needed_before_date (Optional)
	date after which hold request is no longer needed
  - pickup_expiry_date (Optional)
	date after which item returned to shelf if item is not picked up 

=cut

sub HoldItem {
    my ($cgi) = @_;

    # Get the borrower or return an error code
    my $borrowernumber = $cgi->param('patron_id');
    my $borrower = GetMemberDetails( $borrowernumber );
    return { code => 'PatronNotFound' } unless $$borrower{borrowernumber};

    # Get the biblio or return an error code
    my $biblionumber = $cgi->param('bib_id');
    my $biblio = GetBiblio($biblionumber);
    return { code => 'RecordNotFound' } unless $$biblio{biblionumber};

    my $title = $$biblio{title};

    # Get the item or return an error code
    my $itemnumber = $cgi->param('item_id');
    my $item = GetItem( $itemnumber );
    return { code => 'RecordNotFound' } unless $$item{itemnumber};

    # If the biblio does not match the item, return an error code
    return { code => 'RecordNotFound' } if $$item{biblionumber} ne $$biblio{biblionumber};

    # Check for item disponibility
    my $canitembereserved = C4::Reserves::CanItemBeReserved( $borrowernumber, $itemnumber );
    my $canbookbereserved = C4::Reserves::CanBookBeReserved( $borrowernumber, $biblionumber );
    return { code => 'NotHoldable' } unless $canbookbereserved eq 'OK' and $canitembereserved eq 'OK';

    # Pickup branch management
    my $branch;
    if ( $cgi->param('pickup_location') ) {
        $branch = $cgi->param('pickup_location');
        my $branches = GetBranches();
        return { code => 'LocationNotFound' } unless $$branches{$branch};
    } else { # if the request provide no branch, use the borrower's branch
        $branch = $$borrower{branchcode};
    }

    # Add the reserve
    #    $branch,    $borrowernumber, $biblionumber,
    #    $constraint, $bibitems,  $priority, $resdate, $expdate, $notes,
    #    $title,      $checkitem, $found
    my $priority= C4::Reserves::CalculatePriority( $biblionumber );
    AddReserve( $branch, $borrowernumber, $biblionumber, 'a', undef, $priority, undef, undef, undef, $title, $itemnumber, undef );

    # Hashref building
    my $out;
    $out->{'pickup_location'} = GetBranchName($branch);

    # TODO $out->{'date_available'} = '';

    return $out;
}

=head2 CancelHold

Cancels an active reserve request for the borrower.

Parameters:

  - patron_id (Required)
        a borrowernumber
  - item_id (Required)
        a reserve_id

=cut

sub CancelHold {
    my ($cgi) = @_;

    # Get the borrower or return an error code
    my $borrowernumber = $cgi->param('patron_id');
    my $borrower = GetMemberDetails( $borrowernumber );
    return { code => 'PatronNotFound' } unless $$borrower{borrowernumber};

    # Get the reserve or return an error code
    my $reserve_id = $cgi->param('item_id');
    my $reserve = C4::Reserves::GetReserve($reserve_id);
    return { code => 'RecordNotFound' } unless $reserve;
    return { code => 'RecordNotFound' } unless ($reserve->{borrowernumber} == $borrowernumber);

    C4::Reserves::CancelReserve({reserve_id => $reserve_id});

    return { code => 'Canceled' };
}

=head2 _availability

Returns, for an itemnumber, an array containing availability information.

 my ($biblionumber, $status, $msg, $location) = _availability($id);

=cut

sub _availability {
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
}

1;
