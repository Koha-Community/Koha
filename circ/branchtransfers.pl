#!/usr/bin/perl

#script to execute branch transfers of books

# Copyright 2000-2002 Katipo Communications
# copyright 2010 BibLibre
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

use Modern::Perl;
use CGI qw ( -utf8 );
use C4::Circulation;
use C4::Output;
use C4::Reserves;
use C4::Biblio;
use C4::Items;
use C4::Auth qw/:DEFAULT get_session/;
use C4::Koha;
use C4::Members;
use Koha::BiblioFrameworks;
use Koha::AuthorisedValues;
use Koha::Holds;
use Koha::Items;
use Koha::Patrons;
use Koha::Checkouts;

###############################################
#  Getting state

my $query = new CGI;

if (!C4::Context->userenv){
	my $sessionID = $query->cookie("CGISESSID");
    my $session;
	$session = get_session($sessionID) if $sessionID;
	if (!$session or $session->param('branch') eq 'NO_LIBRARY_SET'){
		# no branch set we can't transfer
		print $query->redirect("/cgi-bin/koha/circ/selectbranchprinter.pl");
		exit;
	}
}

#######################################################################################
# Make the page .....
my ($template, $user, $cookie, $flags ) = get_template_and_user(
    {
        template_name   => "circ/branchtransfers.tt",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { circulate => "circulate_remaining_permissions" },
    }
);

my $messages;
my $found;
my $reserved;
my $waiting;
my $reqmessage;
my $cancelled;
my $setwaiting;

my $request        = $query->param('request')        || '';
my $borrowernumber = $query->param('borrowernumber') ||  0;
my $tobranchcd     = $query->param('tobranchcd')     || '';

my $ignoreRs = 0;
############
# Deal with the requests....
if ( $request eq "KillWaiting" ) {
    my $item = $query->param('itemnumber');
    my $holds = Koha::Holds->search({
        itemnumber     => $item,
        borrowernumber => $borrowernumber
    });
    if ( $holds->count ) {
        $holds->next->cancel;
        $cancelled   = 1;
        $reqmessage  = 1;
    } # FIXME else?
}
elsif ( $request eq "SetWaiting" ) {
    my $item = $query->param('itemnumber');
    ModReserveAffect( $item, $borrowernumber );
    $ignoreRs    = 1;
    $setwaiting  = 1;
    $reqmessage  = 1;
}
elsif ( $request eq 'KillReserved' ) {
    my $biblionumber = $query->param('biblionumber');
    my $holds = Koha::Holds->search({
        biblionumber   => $biblionumber,
        borrowernumber => $borrowernumber
    });
    if ( $holds->count ) {
        $holds->next->cancel;
        $cancelled   = 1;
        $reqmessage  = 1;
    } # FIXME else?
}

# collect the stack of books already transfered so they can printed...
my @trsfitemloop;
my $transfered;
my $barcode = $query->param('barcode');
# remove leading/trailing whitespace
defined $barcode and $barcode =~ s/^\s*|\s*$//g;  # FIXME: barcodeInputFilter
# warn "barcode : $barcode";
if ($barcode) {

    ( $transfered, $messages ) =
      transferbook( $tobranchcd, $barcode, $ignoreRs );
    my $item = Koha::Items->find({ barcode => $barcode });
    $found = $messages->{'ResFound'};
    if ($transfered) {
        my %item;
        my $biblio = $item->biblio;
        my $frbranchcd =  C4::Context->userenv->{'branch'};
        $item{'biblionumber'}          = $item->biblionumber;
        $item{'itemnumber'}            = $item->itemnumber;
        $item{'title'}                 = $biblio->title;
        $item{'author'}                = $biblio->author;
        $item{'itemtype'}              = $biblio->biblioitem->itemtype;
        $item{'ccode'}                 = $item->ccode;
        $item{'itemcallnumber'}        = $item->itemcallnumber;
        my $av = Koha::AuthorisedValues->search({ category => 'LOC', authorised_value => $item->location });
        $item{'location'}              = $av->count ? $av->next->lib : '';
        $item{counter}  = 0;
        $item{barcode}  = $barcode;
        $item{frombrcd} = $frbranchcd;
        $item{tobrcd}   = $tobranchcd;
        push( @trsfitemloop, \%item );
    }
}

foreach ( $query->param ) {
    (next) unless (/bc-(\d*)/);
    my $counter = $1;
    my %item;
    my $bc    = $query->param("bc-$counter");
    my $frbcd = $query->param("fb-$counter");
    my $tobcd = $query->param("tb-$counter");
    $counter++;
    $item{counter}  = $counter;
    $item{barcode}  = $bc;
    $item{frombrcd} = $frbcd;
    $item{tobrcd}   = $tobcd;
    my $item = Koha::Items->find({ barcode => $bc });
    my $biblio = $item->biblio;
    $item{'biblionumber'}          = $item->biblionumber;
    $item{'itemnumber'}            = $item->itemnumber;
    $item{'title'}                 = $biblio->title;
    $item{'author'}                = $biblio->author;
    $item{'itemtype'}              = $biblio->biblioitem->itemtype;
    $item{'ccode'}                 = $item->ccode;
    $item{'itemcallnumber'}        = $item->itemcallnumber;
    my $av = Koha::AuthorisedValues->search({ category => 'LOC', authorised_value => $item->location });
    $item{'location'}              = $av->count ? $av->next->lib : '';
    push( @trsfitemloop, \%item );
}

my $itemnumber;
my $biblionumber;

#####################

if ($found) {
    my $res = $messages->{'ResFound'};
    $itemnumber = $res->{'itemnumber'};

    if ( $res->{'ResFound'} eq "Waiting" ) {
        $waiting = 1;
    }
    elsif ( $res->{'ResFound'} eq "Reserved" ) {
        $reserved  = 1;
        $biblionumber = $res->{'biblionumber'};
    }
}

my @errmsgloop;
foreach my $code ( keys %$messages ) {
    if ( $code ne 'WasTransfered' ) {
        my %err;
        if ( $code eq 'BadBarcode' ) {
            $err{msg}        = $messages->{'BadBarcode'};
            $err{errbadcode} = 1;
        }
        elsif ( $code eq "NotAllowed" ) {
            warn "NotAllowed: $messages->{'NotAllowed'} to branchcode " . $messages->{'NotAllowed'};
            # Do we really want a error log message here? --atz
            $err{errnotallowed} =  1;
            my ( $tbr, $typecode ) = split( /::/,  $messages->{'NotAllowed'} );
            $err{tbr}      = $tbr;
            $err{code}     = $typecode;
        }
        elsif ( $code eq 'WasReturned' ) {
            $err{errwasreturned} = 1;
            $err{borrowernumber} = $messages->{'WasReturned'};
            my $patron = Koha::Patrons->find( $messages->{'WasReturned'} );
            if ( $patron ) { # Just in case...
                $err{patron} = $patron;
            }
        }
        $err{errdesteqholding} = ( $code eq 'DestinationEqualsHolding' );
        push( @errmsgloop, \%err );
    }
}

# use Data::Dumper;
# warn "FINAL ============= ".Dumper(@trsfitemloop);

my $pending_checkout_notes = Koha::Checkouts->search({ noteseen => 0 })->count;

$template->param(
    found                   => $found,
    reserved                => $reserved,
    waiting                 => $waiting,
    borrowernumber          => $borrowernumber,
    itemnumber              => $itemnumber,
    barcode                 => $barcode,
    biblionumber            => $biblionumber,
    tobranchcd              => $tobranchcd,
    reqmessage              => $reqmessage,
    cancelled               => $cancelled,
    setwaiting              => $setwaiting,
    trsfitemloop            => \@trsfitemloop,
    errmsgloop              => \@errmsgloop,
    CircAutocompl           => C4::Context->preference("CircAutocompl"),
    pending_checkout_notes  => $pending_checkout_notes,
);

# Checking if there is a Fast Cataloging Framework
$template->param( fast_cataloging => 1 ) if Koha::BiblioFrameworks->find( 'FA' );

output_html_with_http_headers $query, $cookie, $template->output;

