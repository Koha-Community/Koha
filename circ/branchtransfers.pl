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
use CGI             qw ( -utf8 );
use C4::Circulation qw( transferbook barcodedecode );
use C4::Output      qw( output_html_with_http_headers );
use C4::Reserves    qw( ModReserve ModReserveAffect );
use C4::Auth        qw( get_session get_template_and_user );
use C4::Members;
use Koha::BiblioFrameworks;
use Koha::AuthorisedValues;
use Koha::Holds;
use Koha::Items;
use Koha::Patrons;

###############################################
#  Getting state

my $query = CGI->new;

if ( !C4::Context->userenv ) {
    my $sessionID = $query->cookie("CGISESSID");
    my $session;
    $session = get_session($sessionID) if $sessionID;
    if ( !$session ) {

        # no branch set we can't transfer
        print $query->redirect("/cgi-bin/koha/circ/set-library.pl");
        exit;
    }
}

#######################################################################################
# Make the page .....
my ( $template, $user, $cookie, $flags ) = get_template_and_user(
    {
        template_name => "circ/branchtransfers.tt",
        query         => $query,
        type          => "intranet",
        flagsrequired => { circulate => "circulate_remaining_permissions" },
    }
);

# Check transfers is allowed from system preference
if ( C4::Context->preference("IndependentBranchesTransfers") && !C4::Context->IsSuperLibrarian() ) {
    print $query->redirect("/cgi-bin/koha/errors/403.pl");
    exit;
}

my $messages;
my $found;
my $reserved;
my $waiting;
my $hold_transferred;
my $hold_processed;
my $reqmessage;
my $cancelled;
my $settransit;

my $op             = $query->param('op')             || '';
my $borrowernumber = $query->param('borrowernumber') || 0;
my $tobranchcd     = $query->param('tobranchcd')     || '';
my $trigger        = 'Manual';

my $ignoreRs = 0;
############
# Deal with the requests....
if ( $op eq "cud-KillWaiting" ) {
    my $item  = $query->param('itemnumber');
    my $holds = Koha::Holds->search(
        {
            itemnumber     => $item,
            borrowernumber => $borrowernumber
        }
    );
    if ( $holds->count ) {
        $holds->next->cancel;
        $cancelled  = 1;
        $reqmessage = 1;
    }    # FIXME else?
} elsif ( $op eq "cud-SetTransit" ) {
    my $item       = $query->param('itemnumber');
    my $reserve_id = $query->param('reserve_id');
    ModReserveAffect( $item, $borrowernumber, 1, $reserve_id );
    $ignoreRs   = 1;
    $settransit = 1;
    $reqmessage = 1;
    $trigger    = 'Reserve';
} elsif ( $op eq 'cud-KillReserved' ) {
    my $biblionumber = $query->param('biblionumber');
    my $reserve_id   = $query->param('reserve_id');
    my $hold         = Koha::Holds->find( { reserve_id => $reserve_id } );
    if ($hold) {
        $hold->cancel;
        $cancelled  = 1;
        $reqmessage = 1;
    }    # FIXME else?
}

# collect the stack of books already transferred so they can printed...
my @trsfitemloop;
my $transferred;
my $barcode = $query->param('barcode');

# remove leading/trailing whitespace
$barcode = barcodedecode($barcode) if $barcode;
if ( $op eq 'cud-transfer' && $barcode ) {

    ( $transferred, $messages ) = transferbook(
        {
            from_branch     => C4::Context->userenv->{'branch'},
            to_branch       => $tobranchcd,
            barcode         => $barcode,
            ignore_reserves => $ignoreRs,
            trigger         => $trigger
        }
    );
    my $item = Koha::Items->find( { barcode => $barcode } );
    $found = $messages->{'ResFound'} unless $settransit;
    if ($transferred) {
        my %trsfitem;
        my $frbranchcd = C4::Context->userenv->{'branch'};
        $trsfitem{item}     = $item;
        $trsfitem{counter}  = 0;
        $trsfitem{frombrcd} = $frbranchcd;
        $trsfitem{tobrcd}   = $tobranchcd;
        push( @trsfitemloop, \%trsfitem );
    }
}

foreach ( $query->param ) {
    (next) unless (/bc-(\d*)/);
    my $counter = $1;
    my %trsfitem;
    my $bc    = $query->param("bc-$counter");
    my $frbcd = $query->param("fb-$counter");
    my $tobcd = $query->param("tb-$counter");
    $counter++;
    $trsfitem{counter}  = $counter;
    $trsfitem{frombrcd} = $frbcd;
    $trsfitem{tobrcd}   = $tobcd;
    my $item = Koha::Items->find( { barcode => $bc } );
    $trsfitem{item} = $item;
    push( @trsfitemloop, \%trsfitem );
}

my $itemnumber;
my $biblionumber;

#####################

my $hold;
my $patron;
my $found_biblio;
if ($found) {
    $hold = Koha::Holds->find(
        { reserve_id => $found->{reserve_id} },
        { prefetch   => [ 'item', 'patron' ] }
    );
    $itemnumber     = $found->{'itemnumber'};
    $borrowernumber = $found->{'borrowernumber'};
    $patron         = Koha::Patrons->find($borrowernumber);
    $found_biblio   = Koha::Biblios->find( $found->{'biblionumber'} );

    if ( $found->{'ResFound'} eq "Waiting" ) {
        $waiting = 1;
    } elsif ( $found->{'ResFound'} eq "Transferred" ) {
        $hold_transferred = 1;
    } elsif ( $found->{'ResFound'} eq "Processing" ) {
        $hold_processed = 1;
    } elsif ( $found->{'ResFound'} eq "Reserved" ) {
        $reserved     = 1;
        $biblionumber = $found->{'biblionumber'};
    }
}

my @errmsgloop;
foreach my $code ( keys %$messages ) {
    if ( $code ne 'WasTransfered' ) {
        my %err;
        if ( $code eq 'BadBarcode' ) {
            $err{msg}        = $messages->{'BadBarcode'};
            $err{errbadcode} = 1;
        } elsif ( $code eq "NotAllowed" ) {
            warn "NotAllowed: $messages->{'NotAllowed'} to branchcode " . $messages->{'NotAllowed'};

            # Do we really want a error log message here? --atz
            $err{errnotallowed} = 1;
            my ( $tbr, $typecode ) = split( /::/, $messages->{'NotAllowed'} );
            $err{tbr}  = $tbr;
            $err{code} = $typecode;
        } elsif ( $code eq 'WasReturned' ) {
            $err{errwasreturned} = 1;
            $err{borrowernumber} = $messages->{'WasReturned'};
            my $patron = Koha::Patrons->find( $messages->{'WasReturned'} );
            if ($patron) {    # Just in case...
                $err{patron} = $patron;
            }
        } elsif ( $code eq 'DestinationEqualsHolding' ) {
            $err{errdesteqholding} = 1;
        }
        push( @errmsgloop, \%err ) if ( keys %err );
    }
}

# use Data::Dumper;
# warn "FINAL ============= ".Dumper(@trsfitemloop);

$template->param(
    found              => $found,
    hold               => $hold,
    reserved           => $reserved,
    waiting            => $waiting,
    transferred        => $hold_transferred,
    processing         => $hold_processed,
    borrowernumber     => $borrowernumber,
    itemnumber         => $itemnumber,
    barcode            => $barcode,
    biblionumber       => $biblionumber,
    tobranchcd         => $tobranchcd,
    reqmessage         => $reqmessage,
    cancelled          => $cancelled,
    settransit         => $settransit,
    trsfitemloop       => \@trsfitemloop,
    errmsgloop         => \@errmsgloop,
    PatronAutoComplete => C4::Context->preference("PatronAutoComplete"),
    patron             => $patron,
    found_biblio       => $found_biblio,
);

# Checking if there is a Fast Cataloging Framework
$template->param( fast_cataloging => 1 ) if Koha::BiblioFrameworks->find('FA');

output_html_with_http_headers $query, $cookie, $template->output;

