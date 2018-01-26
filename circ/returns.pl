#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
#           2006 SAN-OP
#           2007-2010 BibLibre, Paul POULAIN
#           2010 Catalyst IT
#           2011 PTFS-Europe Ltd.
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

=head1 returns.pl

script to execute returns of books

=cut

use strict;
use warnings;

# FIXME There are weird things going on with $patron and $borrowernumber in this script

use CGI qw ( -utf8 );
use DateTime;
use C4::Context;
use C4::Auth qw/:DEFAULT get_session/;
use C4::Output;
use C4::Circulation;
use C4::Print;
use C4::Reserves;
use C4::Biblio;
use C4::Items;
use C4::Members;
use C4::Members::Messaging;
use C4::Koha;   # FIXME : is it still useful ?
use C4::RotatingCollections;
use Koha::AuthorisedValues;
use Koha::DateUtils;
use Koha::Calendar;
use Koha::BiblioFrameworks;
use Koha::Holds;
use Koha::Items;
use Koha::Patrons;

my $query = new CGI;

#getting the template
my ( $template, $librarian, $cookie, $flags ) = get_template_and_user(
    {
        template_name   => "circ/returns.tt",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { circulate => "circulate_remaining_permissions" },
    }
);

my $sessionID = $query->cookie("CGISESSID");
my $session = get_session($sessionID);
if ($session->param('branch') eq 'NO_LIBRARY_SET'){
    # no branch set we can't return
    print $query->redirect("/cgi-bin/koha/circ/selectbranchprinter.pl");
    exit;
}

# Print a reserve slip on this page
if ( $query->param('print_slip') ) {
    $template->param(
        print_slip     => 1,
        borrowernumber => scalar $query->param('borrowernumber'),
        biblionumber   => scalar $query->param('biblionumber'),
    );
}

#####################
#Global vars
my $printers = GetPrinters();
my $userenv = C4::Context->userenv;
my $userenv_branch = $userenv->{'branch'} // '';
my $printer = $userenv->{'branchprinter'} // '';
my $forgivemanualholdsexpire = $query->param('forgivemanualholdsexpire');

my $overduecharges = (C4::Context->preference('finesMode') && C4::Context->preference('finesMode') ne 'off');
 #
# Some code to handle the error if there is no branch or printer setting.....
#

# Set up the item stack ....
my %returneditems;
my %riduedate;
my %riborrowernumber;
my @inputloop;
foreach ( $query->param ) {
    my $counter;
    if (/ri-(\d*)/) {
        $counter = $1;
        if ($counter > 20) {
            next;
        }
    }
    else {
        next;
    }

    my %input;
    my $barcode        = $query->param("ri-$counter");
    my $duedate        = $query->param("dd-$counter");
    my $borrowernumber = $query->param("bn-$counter");
    $counter++;

    # decode barcode    ## Didn't we already decode them before passing them back last time??
    $barcode =~ s/^\s*|\s*$//g; # remove leading/trailing whitespace
    $barcode = barcodedecode($barcode) if(C4::Context->preference('itemBarcodeInputFilter'));

    ######################
    #Are these lines still useful ?
    $returneditems{$counter}    = $barcode;
    $riduedate{$counter}        = $duedate;
    $riborrowernumber{$counter} = $borrowernumber;

    #######################
    $input{counter}        = $counter;
    $input{barcode}        = $barcode;
    $input{duedate}        = $duedate;
    $input{borrowernumber} = $borrowernumber;
    push( @inputloop, \%input );
}

############
# Deal with the requests....

if ($query->param('WT-itemNumber')){
	updateWrongTransfer ($query->param('WT-itemNumber'),$query->param('WT-waitingAt'),$query->param('WT-From'));
}

if ( $query->param('reserve_id') ) {
    my $itemnumber     = $query->param('itemnumber');
    my $borrowernumber = $query->param('borrowernumber');
    my $reserve_id     = $query->param('reserve_id');
    my $diffBranchReturned = $query->param('diffBranch');
    my $cancel_reserve = $query->param('cancel_reserve');
    # fix up item type for display
    my $item = Koha::Items->find( $itemnumber );
    my $biblio = $item->biblio;

    if ( $cancel_reserve ) {
        my $hold = Koha::Holds->find( $reserve_id );
        if ( $hold ) {
            $hold->cancel( { charge_cancel_fee => !$forgivemanualholdsexpire } );
        } # FIXME else?
    } else {
        my $diffBranchSend = ($userenv_branch ne $diffBranchReturned) ? $diffBranchReturned : undef;
        # diffBranchSend tells ModReserveAffect whether document is expected in this library or not,
        # i.e., whether to apply waiting status
        ModReserveAffect( $itemnumber, $borrowernumber, $diffBranchSend, $reserve_id );
    }
#   check if we have other reserves for this document, if we have a return send the message of transfer
    my ( $messages, $nextreservinfo ) = GetOtherReserves($itemnumber);

    my $patron = Koha::Patrons->find( $nextreservinfo );
    my $name   = $patron ? $patron->surname . ", " . $patron->title . " " . $patron->firstname : '';
    if ( $messages->{'transfert'} ) {
        $template->param(
            itemtitle      => $biblio->title,
            itemnumber     => $item->itemnumber,
            itembiblionumber => $biblio->biblionumber,
            iteminfo       => $biblio->author,
            name           => $name,
            borrowernumber => $borrowernumber,
            borcnum        => $patron->cardnumber,
            borfirstname   => $patron->firstname,
            borsurname     => $patron->surname,
            borcategory    => $patron->category->description,
            diffbranch     => 1,
        );
    }
}

my $borrower;
my $returned = 0;
my $messages;
my $issue;
my $itemnumber;
my $barcode     = $query->param('barcode');
my $exemptfine  = $query->param('exemptfine');
if (
  $exemptfine &&
  !C4::Auth::haspermission(C4::Context->userenv->{'id'}, {'updatecharges' => 'writeoff'})
) {
    # silently prevent unauthorized operator from forgiving overdue
    # fines by manually tweaking form parameters
    undef $exemptfine;
}
my $dropboxmode = $query->param('dropboxmode');
my $dotransfer  = $query->param('dotransfer');
my $canceltransfer = $query->param('canceltransfer');
my $dest = $query->param('dest');
my $calendar    = Koha::Calendar->new( branchcode => $userenv_branch );
#dropbox: get last open day (today - 1)
my $today       = DateTime->now( time_zone => C4::Context->tz());
my $dropboxdate = $calendar->addDate($today, -1);

my $return_date_override = $query->param('return_date_override');
my $return_date_override_remember =
  $query->param('return_date_override_remember');
if ($return_date_override) {
    if ( C4::Context->preference('SpecifyReturnDate') ) {
        my $return_date_override_dt = eval {dt_from_string( $return_date_override ) };
        if ( $return_date_override_dt ) {
            # note that we've overriden the return date
            $template->param( return_date_was_overriden => 1);
            # Save the original format if we are remembering for this series
            $template->param(
                return_date_override          => $return_date_override,
                return_date_override_remember => 1
            ) if ($return_date_override_remember);

            $return_date_override =
              DateTime::Format::MySQL->format_datetime( $return_date_override_dt );
        }
    }
    else {
        $return_date_override = q{};
    }
}

if ($dotransfer){
# An item has been returned to a branch other than the homebranch, and the librarian has chosen to initiate a transfer
    my $transferitem = $query->param('transferitem');
    my $tobranch     = $query->param('tobranch');
    ModItemTransfer($transferitem, $userenv_branch, $tobranch);
}

if ($canceltransfer){
    $itemnumber=$query->param('itemnumber');
    DeleteTransfer($itemnumber);
    if($dest eq "ttr"){
        print $query->redirect("/cgi-bin/koha/circ/transferstoreceive.pl");
        exit;
    } else {
        $template->param( transfercancelled => 1);
    }
}

# actually return book and prepare item table.....
my $returnbranch;
if ($barcode) {
    $barcode =~ s/^\s*|\s*$//g; # remove leading/trailing whitespace
    $barcode = barcodedecode($barcode) if C4::Context->preference('itemBarcodeInputFilter');
    my $item = Koha::Items->find({ barcode => $barcode });

    if ( $item ) {
        $itemnumber = $item->itemnumber;
        # Check if we should display a checkin message, based on the the item
        # type of the checked in item
        my $itemtype = Koha::ItemTypes->find( $item->effective_itemtype );
        if ( $itemtype && $itemtype->checkinmsg ) {
            $template->param(
                checkinmsg     => $itemtype->checkinmsg,
                checkinmsgtype => $itemtype->checkinmsgtype,
            );
        }

        # make sure return branch respects home branch circulation rules, default to homebranch
        my $hbr = GetBranchItemRule($item->homebranch, $itemtype ? $itemtype->itemtype : undef )->{'returnbranch'} || "homebranch";
        $returnbranch = $hbr ne 'noreturn' ? $item->$hbr : $userenv_branch; # can be noreturn, homebranch or holdingbranch

        my $materials = $item->materials;
        my $descriptions = Koha::AuthorisedValues->get_description_by_koha_field({frameworkcode => '', kohafield =>'items.materials', authorised_value => $materials });
        $materials = $descriptions->{lib} // $materials;

        my $checkout = $item->checkout;
        my $biblio   = $item->biblio;
        $template->param(
            title            => $biblio->title,
            homebranch       => $item->homebranch,
            holdingbranch    => $item->holdingbranch,
            returnbranch     => $returnbranch,
            author           => $biblio->author,
            itembarcode      => $item->barcode,
            itemtype         => $item->effective_itemtype,
            ccode            => $item->ccode,
            itembiblionumber => $biblio->biblionumber,
            biblionumber     => $biblio->biblionumber,
            borrower         => $borrower,
            additional_materials => $materials,
            issue            => $checkout,
        );
    } # FIXME else we should not call AddReturn but set BadBarcode directly instead

    my %input = (
        counter => 0,
        first   => 1,
        barcode => $barcode,
    );


    # do the return
    ( $returned, $messages, $issue, $borrower ) =
      AddReturn( $barcode, $userenv_branch, $exemptfine, $dropboxmode, $return_date_override, $dropboxdate );

    if ($returned) {
        my $time_now = DateTime->now( time_zone => C4::Context->tz )->truncate( to => 'minute');
        my $date_due_dt = dt_from_string( $issue->date_due, 'sql' );
        my $duedate = $date_due_dt->strftime('%Y-%m-%d %H:%M');
        $returneditems{0}      = $barcode;
        $riborrowernumber{0}   = $borrower->{'borrowernumber'};
        $riduedate{0}          = $duedate;
        $input{borrowernumber} = $borrower->{'borrowernumber'};
        $input{duedate}        = $duedate;
        unless ( $dropboxmode ) {
            $input{return_overdue} = 1 if (DateTime->compare($date_due_dt, DateTime->now()) == -1);
        } else {
            $input{return_overdue} = 1 if (DateTime->compare($date_due_dt, $dropboxdate) == -1);
        }
        push( @inputloop, \%input );

        if ( C4::Context->preference("FineNotifyAtCheckin") ) {
            my $patron = Koha::Patrons->find( $borrower->{borrowernumber} );
            my $balance = $patron->account->balance;

            if ($balance > 0) {
                $template->param( fines => sprintf("%.2f", $balance) );
                $template->param( fineborrowernumber => $borrower->{'borrowernumber'} );
            }
        }

        if (C4::Context->preference("WaitingNotifyAtCheckin") ) {
            #Check for waiting holds
            my $patron = Koha::Patrons->find( $borrower->{borrowernumber} );
            my $waiting_holds = $patron->holds->search({ found => 'W', branchcode => $userenv_branch })->count;
            if ($waiting_holds > 0) {
                $template->param(
                    waiting_holds       => $waiting_holds,
                    holdsborrowernumber => $borrower->{'borrowernumber'},
                    holdsfirstname => $borrower->{'firstname'},
                    holdssurname => $borrower->{'surname'},
                );
            }
        }
    } elsif ( C4::Context->preference('ShowAllCheckins') and !$messages->{'BadBarcode'} ) {
        $input{duedate}   = 0;
        $returneditems{0} = $barcode;
        $riduedate{0}     = 0;
        push( @inputloop, \%input );
    }
    $template->param( privacy => $borrower->{privacy} );
}
$template->param( inputloop => \@inputloop );

my $found    = 0;
my $waiting  = 0;
my $reserved = 0;

# new op dev : we check if the document must be returned to his homebranch directly,
#  if the document is transfered, we have warning message .

if ( $messages->{'WasTransfered'} ) {
    $template->param(
        found          => 1,
        transfer       => 1,
        itemnumber     => $itemnumber,
    );
}

if ( $messages->{'NeedsTransfer'} ){
    $template->param(
        found          => 1,
        needstransfer  => $messages->{'NeedsTransfer'},
        itemnumber     => $itemnumber,
    );
}

if ( $messages->{'Wrongbranch'} ){
    $template->param(
        wrongbranch => 1,
        rightbranch => $messages->{'Wrongbranch'}->{'Rightbranch'},
    );
}

# case of wrong transfert, if the document wasn't transfered to the right library (according to branchtransfer (tobranch) BDD)

if ( $messages->{'WrongTransfer'} and not $messages->{'WasTransfered'}) {
    $template->param(
        WrongTransfer  => 1,
        TransferWaitingAt => $messages->{'WrongTransfer'},
        WrongTransferItem => $messages->{'WrongTransferItem'},
        itemnumber => $itemnumber,
    );

    my $reserve    = $messages->{'ResFound'};
    if ( $reserve ) {
        my $patron = Koha::Patrons->find( $reserve->{'borrowernumber'} );
        my $name = $patron->surname . ", " . $patron->title . " " . $patron->firstname;
        $template->param(
            # FIXME The full patron object should be passed to the template
                wname           => $name,
                wborfirstname   => $patron->firstname,
                wborsurname     => $patron->surname,
                wborcategory    => $patron->category->description,
                wbortitle       => $patron->title,
                wborphone       => $patron->phone,
                wboremail       => $patron->email,
                streetnumber    => $patron->streetnumber,
                address         => $patron->address,
                address2        => $patron->address2,
                city            => $patron->city,
                zipcode         => $patron->zipcode,
                state           => $patron->state,
                country         => $patron->country,
                wborrowernumber => $reserve->{'borrowernumber'},
                wborcnum        => $patron->cardnumber,
        );
    }
    $template->param(
        wtransfertFrom  => $userenv_branch,
    );
}

#
# reserve found and item arrived at the expected branch
#
if ( $messages->{'ResFound'}) {
    my $reserve    = $messages->{'ResFound'};
    my $patron = Koha::Patrons->find( $reserve->{borrowernumber} );
    my $holdmsgpreferences =  C4::Members::Messaging::GetMessagingPreferences( { borrowernumber => $reserve->{'borrowernumber'}, message_name   => 'Hold_Filled' } );
    if ( $reserve->{'ResFound'} eq "Waiting" or $reserve->{'ResFound'} eq "Reserved" ) {
        if ( $reserve->{'ResFound'} eq "Waiting" ) {
            $template->param(
                waiting      => ($userenv_branch eq $reserve->{'branchcode'} ? 1 : 0 ),
            );
        } elsif ( $reserve->{'ResFound'} eq "Reserved" ) {
            $template->param(
                intransit    => ($userenv_branch eq $reserve->{'branchcode'} ? 0 : 1 ),
                transfertodo => ($userenv_branch eq $reserve->{'branchcode'} ? 0 : 1 ),
                reserve_id   => $reserve->{reserve_id},
                reserved     => 1,
            );
        }

        # same params for Waiting or Reserved
        $template->param(
            # FIXME The full patron object should be passed to the template
            found          => 1,
            name           => $patron->surname . ", " . $patron->title . " " . $patron->firstname,
            borfirstname   => $patron->firstname,
            borsurname     => $patron->surname,
            borcategory    => $patron->category->description,
            bortitle       => $patron->title,
            borphone       => $patron->phone,
            boremail       => $patron->email,
            boraddress     => $patron->address,
            boraddress2    => $patron->address2,
            streetnumber   => $patron->streetnumber,
            city           => $patron->city,
            zipcode        => $patron->zipcode,
            state          => $patron->state,
            country        => $patron->country,
            borcnum        => $patron->cardnumber,
            debarred       => $patron->debarred,
            gonenoaddress  => $patron->gonenoaddress,
            barcode        => $barcode,
            destbranch     => $reserve->{'branchcode'},
            borrowernumber => $reserve->{'borrowernumber'},
            itemnumber     => $reserve->{'itemnumber'},
            reservenotes   => $reserve->{'reservenotes'},
            reserve_id     => $reserve->{reserve_id},
            bormessagepref => $holdmsgpreferences->{'transports'},
        );
    } # else { ; }  # error?
}

# Error Messages
my @errmsgloop;
foreach my $code ( keys %$messages ) {
    my %err;
    my $exit_required_p = 0;
    if ( $code eq 'BadBarcode' ) {
        $err{badbarcode} = 1;
        $err{msg}        = $messages->{'BadBarcode'};
    }
    elsif ( $code eq 'NotIssued' ) {
        $err{notissued} = 1;
        $err{msg} = '';
        $err{msg} = $messages->{'IsPermanent'} if $messages->{'IsPermanent'};
    }
    elsif ( $code eq 'LocalUse' ) {
        $err{localuse} = 1;
    }
    elsif ( $code eq 'WasLost' ) {
        $err{waslost} = 1;
        $exit_required_p = 1 if C4::Context->preference("BlockReturnOfLostItems");
    }
    elsif ( $code eq 'LostItemFeeRefunded' ) {
        $template->param( LostItemFeeRefunded => 1 );
    }
    elsif ( $code eq 'ResFound' ) {
        ;    # FIXME... anything to do here?
    }
    elsif ( $code eq 'WasReturned' ) {
        ;    # FIXME... anything to do here?
    }
    elsif ( $code eq 'WasTransfered' ) {
        ;    # FIXME... anything to do here?
    }
    elsif ( $code eq 'withdrawn' ) {
        $err{withdrawn} = 1;
        $exit_required_p = 1 if C4::Context->preference("BlockReturnOfWithdrawnItems");
    }
    elsif ( ( $code eq 'IsPermanent' ) && ( not $messages->{'ResFound'} ) ) {
        if ( $messages->{'IsPermanent'} ne $userenv_branch ) {
            $err{ispermanent} = 1;
            $err{msg}         = $messages->{'IsPermanent'};
        }
    }
    elsif ( $code eq 'WrongTransfer' ) {
        ;    # FIXME... anything to do here?
    }
    elsif ( $code eq 'WrongTransferItem' ) {
        ;    # FIXME... anything to do here?
    }
    elsif ( $code eq 'NeedsTransfer' ) {
    }
    elsif ( $code eq 'Wrongbranch' ) {
    }
    elsif ( $code eq 'Debarred' ) {
        $err{debarred}            = $messages->{'Debarred'};
        $err{debarcardnumber}     = $borrower->{cardnumber};
        $err{debarborrowernumber} = $borrower->{borrowernumber};
        $err{debarname}           = "$borrower->{firstname} $borrower->{surname}";
    }
    elsif ( $code eq 'PrevDebarred' ) {
        $err{prevdebarred}        = $messages->{'PrevDebarred'};
    }
    elsif ( $code eq 'ForeverDebarred' ) {
        $err{foreverdebarred}        = $messages->{'ForeverDebarred'};
    }
    elsif ( $code eq 'NotForLoanStatusUpdated' ) {
        $err{NotForLoanStatusUpdated} = $messages->{NotForLoanStatusUpdated};
    }
    elsif ( $code eq 'DataCorrupted' ) {
        $err{data_corrupted} = 1;
    }
    else {
        die "Unknown error code $code";    # note we need all the (empty) elsif's above, or we die.
        # This forces the issue of staying in sync w/ Circulation.pm
    }
    if (%err) {
        push( @errmsgloop, \%err );
    }
    last if $exit_required_p;
}
$template->param( errmsgloop => \@errmsgloop );

#set up so only the last 8 returned items display (make for faster loading pages)
my $returned_counter = ( C4::Context->preference('numReturnedItemsToShow') ) ? C4::Context->preference('numReturnedItemsToShow') : 8;
my $count = 0;
my @riloop;
my $shelflocations =
  { map { $_->{authorised_value} => $_->{lib} } Koha::AuthorisedValues->get_descriptions_by_koha_field( { frameworkcode => '', kohafield => 'items.location' } ) };
foreach ( sort { $a <=> $b } keys %returneditems ) {
    my %ri;
    if ( $count++ < $returned_counter ) {
        my $bar_code = $returneditems{$_};
        if ($riduedate{$_}) {
            my $duedate = dt_from_string( $riduedate{$_}, 'sql');
            $ri{year}  = $duedate->year();
            $ri{month} = $duedate->month();
            $ri{day}   = $duedate->day();
            $ri{hour}   = $duedate->hour();
            $ri{minute}   = $duedate->minute();
            $ri{duedate} = output_pref($duedate);
            my $patron = Koha::Patrons->find( $riborrowernumber{$_} );
            unless ( $dropboxmode ) {
                $ri{return_overdue} = 1 if (DateTime->compare($duedate, DateTime->now()) == -1);
            } else {
                $ri{return_overdue} = 1 if (DateTime->compare($duedate, $dropboxdate) == -1);
            }
            $ri{borrowernumber} = $patron->borrowernumber;
            $ri{borcnum}        = $patron->cardnumber;
            $ri{borfirstname}   = $patron->firstname;
            $ri{borsurname}     = $patron->surname;
            $ri{bortitle}       = $patron->title;
            $ri{bornote}        = $patron->borrowernotes;
            $ri{borcategorycode}= $patron->categorycode;
            $ri{borissuescount} = $patron->checkouts->count;
        }
        else {
            $ri{borrowernumber} = $riborrowernumber{$_};
        }

        my $item = Koha::Items->find({ barcode => $bar_code });
        my $biblio = $item->biblio;
        # FIXME pass $item to the template and we are done here...
        $ri{itembiblionumber}    = $biblio->biblionumber;
        $ri{itemtitle}           = $biblio->title;
        $ri{itemauthor}          = $biblio->author;
        $ri{itemcallnumber}      = $item->itemcallnumber;
        $ri{dateaccessioned}     = $item->dateaccessioned;
        $ri{itemtype}            = $item->effective_itemtype;
        $ri{itemnote}            = $item->itemnotes;
        $ri{itemnotes_nonpublic} = $item->itemnotes_nonpublic;
        $ri{ccode}               = $item->ccode;
        $ri{enumchron}           = $item->enumchron;
        $ri{itemnumber}          = $item->itemnumber;
        $ri{barcode}             = $bar_code;
        $ri{homebranch}          = $item->homebranch;
        $ri{holdingbranch}       = $item->holdingbranch;

        $ri{location}         = $biblio->{'location'};
        my $shelfcode = $ri{'location'};
        $ri{'location'} = $shelflocations->{$shelfcode} if ( defined( $shelfcode ) && defined($shelflocations) && exists( $shelflocations->{$shelfcode} ) );

    }
    else {
        last;
    }
    push @riloop, \%ri;
}

$template->param(
    riloop         => \@riloop,
    printer        => $printer,
    errmsgloop     => \@errmsgloop,
    exemptfine     => $exemptfine,
    dropboxmode    => $dropboxmode,
    dropboxdate    => output_pref($dropboxdate),
    forgivemanualholdsexpire => $forgivemanualholdsexpire,
    overduecharges => $overduecharges,
    AudioAlerts        => C4::Context->preference("AudioAlerts"),
);

$itemnumber = GetItemnumberFromBarcode( $barcode );
if ( $itemnumber ) {
    my ( $holdingBranch, $collectionBranch ) = GetCollectionItemBranches( $itemnumber );
    if ( $holdingBranch and $collectionBranch ) {
        $holdingBranch //= '';
        $collectionBranch //= $returnbranch;
        if ( ! ( $holdingBranch eq $collectionBranch ) ) {
            $template->param(
              collectionItemNeedsTransferred => 1,
              collectionBranch => $collectionBranch,
              itemnumber => $itemnumber,
            );
        }
    }
}

# Checking if there is a Fast Cataloging Framework
$template->param( fast_cataloging => 1 ) if Koha::BiblioFrameworks->find( 'FA' );

# actually print the page!
output_html_with_http_headers $query, $cookie, $template->output;
