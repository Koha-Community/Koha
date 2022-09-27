package C4::ILSDI::Services;

# Copyright 2009 SARL Biblibre
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

use C4::Members;
use C4::Items qw( get_hostitemnumbers_of );
use C4::Circulation qw( CanBookBeRenewed barcodedecode CanBookBeIssued AddRenewal );
use C4::Accounts;
use C4::Reserves qw( CanBookBeReserved IsAvailableForItemLevelRequest CalculatePriority AddReserve CanItemBeReserved CanReserveBeCanceledFromOpac );
use C4::Context;
use C4::Auth;
use CGI qw ( -utf8 );
use DateTime;
use C4::Auth;
use Koha::DateUtils qw( dt_from_string );
use C4::AuthoritiesMarc qw( GetAuthorityXML );

use Koha::Biblios;
use Koha::Checkouts;
use Koha::I18N qw(__);
use Koha::Items;
use Koha::Libraries;
use Koha::Patrons;

=head1 NAME

C4::ILS-DI::Services - ILS-DI Services

=head1 DESCRIPTION

Each function in this module represents an ILS-DI service.
They all takes a CGI instance as argument and most of them return a
hashref that will be printed by XML::Simple in opac/ilsdi.pl

=head1 SYNOPSIS

    use C4::ILSDI::Services;
    use XML::Simple;
    use CGI qw ( -utf8 );

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
            my ( $biblionumber, $status, $msg, $location, $itemcallnumber ) = _availability($id);

            $out .= "  <dlf:record>\n";
            $out .= "    <dlf:bibliographic id=\"" . ( $biblionumber || $id ) . "\" />\n";
            $out .= "    <dlf:items>\n";
            $out .= "      <dlf:item id=\"" . $id . "\">\n";
            $out .= "        <dlf:simpleavailability>\n";
            $out .= "          <dlf:identifier>" . $id . "</dlf:identifier>\n";
            $out .= "          <dlf:availabilitystatus>" . $status . "</dlf:availabilitystatus>\n";
            if ($msg)      { $out .= "          <dlf:availabilitymsg>" . $msg . "</dlf:availabilitymsg>\n"; }
            if ($location) { $out .= "          <dlf:location>" . $location . "</dlf:location>\n"; }
            if ($itemcallnumber) { $out .= "          <dlf:itemcallnumber>" . $itemcallnumber. "</dlf:itemcallnumber>\n"; }
            $out .= "        </dlf:simpleavailability>\n";
            $out .= "      </dlf:item>\n";
            $out .= "    </dlf:items>\n";
            $out .= "  </dlf:record>\n";
        } else {
            my $status;
            my $msg;
            my $items = Koha::Items->search({ biblionumber => $id });
            if ($items->count) {
                # Open XML
                $out .= "  <dlf:record>\n";
                $out .= "    <dlf:bibliographic id=\"" .$id. "\" />\n";
                $out .= "    <dlf:items>\n";
                # We loop over the items to clean them
                while ( my $item = $items->next ) {
                    my $itemnumber = $item->itemnumber;
                    my ( $biblionumber, $status, $msg, $location, $itemcallnumber ) = _availability($itemnumber);
                    $out .= "      <dlf:item id=\"" . $itemnumber . "\">\n";
                    $out .= "        <dlf:simpleavailability>\n";
                    $out .= "          <dlf:identifier>" . $itemnumber . "</dlf:identifier>\n";
                    $out .= "          <dlf:availabilitystatus>" . $status . "</dlf:availabilitystatus>\n";
                    if ($msg)      { $out .= "          <dlf:availabilitymsg>" . $msg . "</dlf:availabilitymsg>\n"; }
                    if ($location) { $out .= "          <dlf:location>" . $location . "</dlf:location>\n"; }
                    if ($itemcallnumber) { $out .= "          <dlf:itemcallnumber>" . $itemcallnumber. "</dlf:itemcallnumber>\n"; }
                    $out .= "        </dlf:simpleavailability>\n";
                    $out .= "      </dlf:item>\n";
                }
                # Close XML
                $out .= "    </dlf:items>\n";
                $out .= "  </dlf:record>\n";
            } else {
                $status = "unknown";
                $msg    = "Error: could not retrieve availability for this ID";
            }
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
        my $biblio = Koha::Biblios->find( $biblionumber );
        unless ( $biblio ) {
            push @records, { code => "RecordNotFound" };
            next;
        }

        my $biblioitem = $biblio->biblioitem->unblessed;

        my $record = $biblio->metadata->record({ embed_items => 1 });
        if ($record) {
            $biblioitem->{marcxml} = $record->as_xml_record();
        }

        # Get most of the needed data
        my $biblioitemnumber = $biblioitem->{'biblioitemnumber'};
        my $checkouts = Koha::Checkouts->search(
            { biblionumber => $biblionumber },
            {
                join => 'item',
                '+select' => ['item.barcode'],
                '+as'     => ['barcode'],
            }
        )->unblessed;
        foreach my $checkout (@$checkouts) {
            delete $checkout->{'borrowernumber'};
        }
        my @items            = $biblio->items->as_list;

        $biblioitem->{items}->{item} = [];

        # We loop over the items to clean them
        foreach my $item (@items) {
            my %item = %{ $item->unblessed };

            # This hides additionnal XML subfields, we don't need these info
            delete $item{'more_subfields_xml'};

            # Display branch names instead of branch codes
            my $home_library    = $item->home_branch;
            my $holding_library = $item->holding_branch;
            $item{'homebranchname'}    = $home_library    ? $home_library->branchname    : '';
            $item{'holdingbranchname'} = $holding_library ? $holding_library->branchname : '';

            if ($item->location) {
                my $authorised_value = Koha::AuthorisedValues->find_by_koha_field({ kohafield => 'items.location', authorised_value => $item->location });
                if ($authorised_value) {
                    $item{location_description} = $authorised_value->opac_description;
                }
            }

            if ($item->itype) {
                my $itemtype = Koha::ItemTypes->find($item->itype);
                if ($itemtype) {
                    $item{itype_description} = $itemtype->description;
                }
            }

            my $transfer = $item->get_transfer;
            if ($transfer) {
                $item{transfer} = {
                    datesent => $transfer->datesent,
                    frombranch => $transfer->frombranch,
                    tobranch => $transfer->tobranch,
                };
            }

            push @{ $biblioitem->{items}->{item} }, \%item;
        }

        # Holds
        my $holds = $biblio->current_holds->unblessed;
        foreach my $hold (@$holds) {
            delete $hold->{'borrowernumber'};
        }

        # Hashref building...
        $biblioitem->{'reserves'}->{'reserve'} = $holds;
        $biblioitem->{'issues'}->{'issue'}     = $checkouts;

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
    - userid
        - email
    - borrowernumber
    - firstname
        - surname

=cut

sub LookupPatron {
    my ($cgi) = @_;

    my $id      = $cgi->param('id');
    if(!$id) {
        return { message => 'PatronNotFound' };
    }

    my $patrons;
    my $passed_id_type = $cgi->param('id_type');
    if($passed_id_type) {
        $patrons = Koha::Patrons->search( { $passed_id_type => $id } );
    } else {
        foreach my $id_type ('cardnumber', 'userid', 'email', 'borrowernumber',
                     'surname', 'firstname') {
            $patrons = Koha::Patrons->search( { $id_type => $id } );
            last if($patrons->count);
        }
    }
    unless ( $patrons->count ) {
        return { message => 'PatronNotFound' };
    }

    return { id => $patrons->next->borrowernumber };
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
    my $username = $cgi->param('username');
    my $password = $cgi->param('password');
    my ($status, $cardnumber, $userid) = C4::Auth::checkpw( $username, $password );
    if ( $status == 1 ) {
        # Track the login
        C4::Auth::track_login_daily( $userid );
        # Get the borrower
        my $patron = Koha::Patrons->find( { userid => $userid } );
        return { id => $patron->borrowernumber };
    }
    elsif ( $status == -2 ){
        return { code => 'PasswordExpired' };
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
  - show_attributes (Optional, default 0)
    whether or not to return additional patron attributes, when enabled the attributes
    are limited to those marked as opac visible only.

=cut

sub GetPatronInfo {
    my ($cgi) = @_;

    # Get Member details
    my $borrowernumber = $cgi->param('patron_id');
    my $patron = Koha::Patrons->find( $borrowernumber );
    return { code => 'PatronNotFound' } unless $patron;

    # Cleaning the borrower hashref
    my $borrower = $patron->unblessed;
    $borrower->{charges} = sprintf "%.02f", $patron->account->non_issues_charges; # FIXME Formatting should not be done here
    my $library = Koha::Libraries->find( $borrower->{branchcode} );
    $borrower->{'branchname'} = $library ? $library->branchname : '';
    delete $borrower->{'userid'};
    delete $borrower->{'password'};

    # Contact fields management
    if ( defined $cgi->param('show_contact') && $cgi->param('show_contact') eq "0" ) {

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
    if ( $cgi->param('show_fines') && $cgi->param('show_fines') eq "1" ) {
        $borrower->{fines}{fine} = $patron->account->lines->unblessed;
    }

    # Reserves management
    if ( $cgi->param('show_holds') && $cgi->param('show_holds') eq "1" ) {

        # Get borrower's reserves
        my $holds = $patron->holds;
        while ( my $hold = $holds->next ) {

            my ( $item, $biblio, $biblioitem ) = ( {}, {}, {} );
            # Get additional informations
            if ( $hold->itemnumber ) {    # item level holds
                $item       = Koha::Items->find( $hold->itemnumber );
                $biblio     = $item->biblio;
                $biblioitem = $biblio->biblioitem;

                # Remove unwanted fields
                $item = $item->unblessed;
                delete $item->{more_subfields_xml};
                $biblio     = $biblio->unblessed;
                $biblioitem = $biblioitem->unblessed;
            }

            # Add additional fields
            my $unblessed_hold = $hold->unblessed;
            $unblessed_hold->{item}       = { %$item, %$biblio, %$biblioitem };
            my $library = Koha::Libraries->find( $hold->branchcode );
            my $branchname = $library ? $library->branchname : '';
            $unblessed_hold->{branchname} = $branchname;
            $biblio = Koha::Biblios->find( $hold->biblionumber ); # Should be $hold->get_biblio
            $unblessed_hold->{title} = $biblio ? $biblio->title : ''; # Just in case, but should not be needed

            push @{ $borrower->{holds}{hold} }, $unblessed_hold;

        }
    }

    # Issues management
    if ( $cgi->param('show_loans') && $cgi->param('show_loans') eq "1" ) {
        my $per_page = $cgi->param('loans_per_page');
        my $page = $cgi->param('loans_page');

        my $pending_checkouts = $patron->pending_checkouts;

        if ($page || $per_page) {
            $page ||= 1;
            $per_page ||= 10;
            $borrower->{total_loans} = $pending_checkouts->count();
            $pending_checkouts = $pending_checkouts->search(undef, {
                rows => $per_page,
                page => $page,
            });
        }

        my @checkouts;
        while ( my $c = $pending_checkouts->next ) {
            # FIXME We should only retrieve what is needed in the template
            my $issue = $c->unblessed_all_relateds;
            delete $issue->{'more_subfields_xml'};
            push @checkouts, $issue
        }
        $borrower->{'loans'}->{'loan'} = \@checkouts;
    }

    my $show_attributes = $cgi->param('show_attributes');
    if ( $show_attributes && $show_attributes eq "1" ) {
        # FIXME Regression expected here, we do not retrieve the same field as previously
        # Waiting for answer on bug 14257 comment 15
        $borrower->{'attributes'} = [
            map {
                $_->type->opac_display
                  ? {
                    %{ $_->unblessed },
                    %{ $_->type->unblessed },
                    value             => $_->attribute,   # Backward compatibility
                    value_description => $_->description, # Awkward retro-compability...
                  }
                  : ()
            } $patron->extended_attributes->search->as_list
        ];
    }

    # Add is expired information
    $borrower->{'is_expired'} = $patron->is_expired ? 1 : 0;

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
    my $patron = Koha::Patrons->find( $borrowernumber );
    return { code => 'PatronNotFound' } unless $patron;

    # Return the results
    return {
        type   => $patron->categorycode,
        status => 0, # TODO
        expiry => $patron->dateexpiry,
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
    my $patron = Koha::Patrons->find( $borrowernumber );
    return { code => 'PatronNotFound' } unless $patron;

    my $borrower = $patron->unblessed;
    # Get the item, or return an error code if not found
    my $itemnumber = $cgi->param('item_id');
    my $item = Koha::Items->find($itemnumber);
    return { code => 'RecordNotFound' } unless $item;

    my @availablefor;

    # Reserve level management
    my $biblionumber = $item->biblionumber;
    my $canbookbereserved = CanBookBeReserved( $borrower, $biblionumber );
    if ($canbookbereserved->{status} eq 'OK') {
        push @availablefor, 'title level hold';
        my $canitembereserved = IsAvailableForItemLevelRequest($item, $patron);
        if ($canitembereserved) {
            push @availablefor, 'item level hold';
        }
    }

    # Reserve cancellation management
    my $holds = $patron->holds;
    my @reserveditems;
    while ( my $hold = $holds->next ) { # FIXME This could be improved
        push @reserveditems, $hold->itemnumber;
    }
    if ( grep { $itemnumber eq $_ } @reserveditems ) {
        push @availablefor, 'hold cancellation';
    }

    # Renewal management
    my @renewal = CanBookBeRenewed( $patron, $item->checkout ); # TODO: Error if issue not found?
    if ( $renewal[0] ) {
        push @availablefor, 'loan renewal';
    }

    # Issuing management
    my $barcode = $item->barcode || '';
    $barcode = barcodedecode($barcode) if $barcode;
    if ($barcode) {
        my ( $issuingimpossible, $needsconfirmation ) = CanBookBeIssued( $patron, $barcode );

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
    my $patron = Koha::Patrons->find( $borrowernumber );
    return { code => 'PatronNotFound' } unless $patron;

    # Get the item, or return an error code
    my $itemnumber = $cgi->param('item_id'); # TODO: Refactor and send issue_id instead?
    my $item = Koha::Items->find($itemnumber);

    return { code => 'RecordNotFound' } unless $item;

    my $issue = $item->checkout;
    return unless $issue; # FIXME should be handled

    # Add renewal if possible
    my @renewal = CanBookBeRenewed( $patron, $issue );
    if ( $renewal[0] ) { AddRenewal( $borrowernumber, $itemnumber, undef, undef, undef, undef, 0 ); }


    # Hashref building
    my $out;
    $out->{'renewals'} = $issue->renewals_count;
    # FIXME Unusual date formatting
    $out->{date_due}   = dt_from_string($issue->date_due)->strftime('%Y-%m-%d %H:%M');
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
  - start_date (Optional)
    date after which hold request is no longer needed if the document has not been made available
  - expiry_date (Optional)
    date after which item returned to shelf if item is not picked up

=cut

sub HoldTitle {
    my ($cgi) = @_;

    # Get the borrower or return an error code
    my $borrowernumber = $cgi->param('patron_id');
    my $patron = Koha::Patrons->find( $borrowernumber );
    return { code => 'PatronNotFound' } unless $patron;


    # If borrower is restricted return an error code
    return { code => 'PatronRestricted' } if $patron->is_debarred;

    # Check for patron expired, category and syspref settings
    return { code => 'PatronExpired' } if ($patron->category->effective_BlockExpiredPatronOpacActions && $patron->is_expired);

    # Get the biblio record, or return an error code
    my $biblionumber = $cgi->param('bib_id');
    my $biblio = Koha::Biblios->find( $biblionumber );
    return { code => 'RecordNotFound' } unless $biblio;

    my @hostitems = get_hostitemnumbers_of($biblionumber);
    my @itemnumbers;
    if (@hostitems){
        push(@itemnumbers, @hostitems);
    }

    my $items = Koha::Items->search({ -or => { biblionumber => $biblionumber, itemnumber => { in => \@itemnumbers } } });

    unless ( $items->count ) {
        return { code => 'NoItems' };
    }

    my $title = $biblio ? $biblio->title : '';

    # Check if the biblio can be reserved
    my $code = CanBookBeReserved( $borrowernumber, $biblionumber )->{status};
    return { code => $code } unless ( $code eq 'OK' );

    my $branch;

    # Pickup branch management
    if ( $cgi->param('pickup_location') ) {
        $branch = $cgi->param('pickup_location');
        return { code => 'LocationNotFound' } unless Koha::Libraries->find($branch);
    } else { # if the request provide no branch, use the borrower's branch
        $branch = $patron->branchcode;
    }

    my $destination = Koha::Libraries->find($branch);
    return { code => 'libraryNotPickupLocation' } unless $destination->pickup_location;
    return { code => 'cannotBeTransferred' } unless $biblio->can_be_transferred({ to => $destination });

    my $resdate = $cgi->param('start_date');
    my $expdate = $cgi->param('expiry_date');

    # Add the reserve
    #    $branch,    $borrowernumber, $biblionumber,
    #    $constraint, $bibitems,  $priority, $resdate, $expdate, $notes,
    #    $title,      $checkitem, $found
    my $priority= C4::Reserves::CalculatePriority( $biblionumber );
    AddReserve(
        {
            branchcode       => $branch,
            borrowernumber   => $borrowernumber,
            biblionumber     => $biblionumber,
            priority         => $priority,
            reservation_date => $resdate,
            expiration_date  => $expdate,
            title            => $title,
        }
    );

    # Hashref building
    my $out;
    $out->{'title'}           = $title;
    my $library = Koha::Libraries->find( $branch );
    $out->{'pickup_location'} = $library ? $library->branchname : '';

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
  - start_date (Optional)
    date after which hold request is no longer needed if the item has not been made available
  - expiry_date (Optional)
    date after which item returned to shelf if item is not picked up

=cut

sub HoldItem {
    my ($cgi) = @_;

    # Get the borrower or return an error code
    my $borrowernumber = $cgi->param('patron_id');
    my $patron = Koha::Patrons->find( $borrowernumber );
    return { code => 'PatronNotFound' } unless $patron;

    # If borrower is restricted return an error code
    return { code => 'PatronRestricted' } if $patron->is_debarred;

    # Check for patron expired, category and syspref settings
    return { code => 'PatronExpired' } if ($patron->category->effective_BlockExpiredPatronOpacActions && $patron->is_expired);

    # Get the biblio or return an error code
    my $biblionumber = $cgi->param('bib_id');
    my $biblio = Koha::Biblios->find( $biblionumber );
    return { code => 'RecordNotFound' } unless $biblio;

    my $title = $biblio ? $biblio->title : '';

    # Get the item or return an error code
    my $itemnumber = $cgi->param('item_id');
    my $item = Koha::Items->find($itemnumber);
    return { code => 'RecordNotFound' } unless $item;

    # If the biblio does not match the item, return an error code
    return { code => 'RecordNotFound' } if $item->biblionumber ne $biblio->biblionumber;

    # Pickup branch management
    my $branch;
    if ( $cgi->param('pickup_location') ) {
        $branch = $cgi->param('pickup_location');
        return { code => 'LocationNotFound' } unless Koha::Libraries->find($branch);
    } else { # if the request provide no branch, use the borrower's branch
        $branch = $patron->branchcode;
    }

    # Check for item disponibility
    my $canitembereserved = C4::Reserves::CanItemBeReserved( $patron, $item, $branch )->{status};
    return { code => $canitembereserved } unless $canitembereserved eq 'OK';

    my $resdate = $cgi->param('start_date');
    my $expdate = $cgi->param('expiry_date');

    # Add the reserve
    my $priority = C4::Reserves::CalculatePriority($biblionumber);
    AddReserve(
        {
            branchcode       => $branch,
            borrowernumber   => $borrowernumber,
            biblionumber     => $biblionumber,
            priority         => $priority,
            reservation_date => $resdate,
            expiration_date  => $expdate,
            title            => $title,
            itemnumber       => $itemnumber,
        }
    );

    # Hashref building
    my $out;
    my $library = Koha::Libraries->find( $branch );
    $out->{'pickup_location'} = $library ? $library->branchname : '';

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
    my $patron = Koha::Patrons->find( $borrowernumber );
    return { code => 'PatronNotFound' } unless $patron;

    # Get the reserve or return an error code
    my $reserve_id = $cgi->param('item_id');
    my $hold = Koha::Holds->find( $reserve_id );
    return { code => 'RecordNotFound' } unless $hold;

    # Check if reserve belongs to the borrower and if it is in a state which allows cancellation
    return { code => 'BorrowerCannotCancelHold' } unless CanReserveBeCanceledFromOpac( $reserve_id, $borrowernumber );

    $hold->cancel;

    return { code => 'Canceled' };
}

=head2 _availability

Returns, for an itemnumber, an array containing availability information.

 my ($biblionumber, $status, $msg, $location) = _availability($id);

=cut

sub _availability {
    my ($itemnumber) = @_;
    my $item = Koha::Items->find($itemnumber);

    unless ( $item ) {
        return ( undef, __('unknown'), __('Error: could not retrieve availability for this ID'), undef );
    }

    my $biblionumber = $item->biblioitemnumber;
    my $library = Koha::Libraries->find( $item->holdingbranch );
    my $location = $library ? $library->branchname : '';
    my $itemcallnumber = $item->itemcallnumber;

    if ( $item->is_notforloan ) {
        return ( $biblionumber, __('not available'), __('Not for loan'), $location, $itemcallnumber );
    } elsif ( $item->onloan ) {
        return ( $biblionumber, __('not available'), __('Checked out'), $location, $itemcallnumber );
    } elsif ( $item->itemlost ) {
        return ( $biblionumber, __('not available'), __('Item lost'), $location, $itemcallnumber );
    } elsif ( $item->withdrawn ) {
        return ( $biblionumber, __('not available'), __('Item withdrawn'), $location, $itemcallnumber );
    } elsif ( $item->damaged ) {
        return ( $biblionumber, __('not available'), __('Item damaged'), $location, $itemcallnumber );
    } else {
        return ( $biblionumber, __('available'), undef, $location, $itemcallnumber );
    }
}

1;
