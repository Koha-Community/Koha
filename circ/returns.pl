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

use Carp 'verbose';
$SIG{ __DIE__ } = sub { Carp::confess( @_ ) };

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
use C4::Branch; # GetBranches GetBranchName
use C4::Koha;   # FIXME : is it still useful ?
use C4::RotatingCollections;
use Koha::DateUtils;
use Koha::Calendar;

my $query = new CGI;

#getting the template
my ( $template, $librarian, $cookie ) = get_template_and_user(
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
        borrowernumber => $query->param('borrowernumber'),
        biblionumber   => $query->param('biblionumber'),
    );
}

#####################
#Global vars
my $branches = GetBranches();
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

if ( $query->param('resbarcode') ) {
    my $item           = $query->param('itemnumber');
    my $borrowernumber = $query->param('borrowernumber');
    my $resbarcode     = $query->param('resbarcode');
    my $diffBranchReturned = $query->param('diffBranch');
    my $iteminfo   = GetBiblioFromItemNumber($item);
    my $cancel_reserve = $query->param('cancel_reserve');
    # fix up item type for display
    $iteminfo->{'itemtype'} = C4::Context->preference('item-level_itypes') ? $iteminfo->{'itype'} : $iteminfo->{'itemtype'};

    if ( $cancel_reserve ) {
        CancelReserve({ borrowernumber => $borrowernumber, itemnumber => $item, charge_cancel_fee => !$forgivemanualholdsexpire });
    } else {
        my $diffBranchSend = ($userenv_branch ne $diffBranchReturned) ? $diffBranchReturned : undef;
        # diffBranchSend tells ModReserveAffect whether document is expected in this library or not,
        # i.e., whether to apply waiting status
        ModReserveAffect( $item, $borrowernumber, $diffBranchSend);
    }
#   check if we have other reserves for this document, if we have a return send the message of transfer
    my ( $messages, $nextreservinfo ) = GetOtherReserves($item);

    my $borr = GetMember( borrowernumber => $nextreservinfo );
    my $name   = $borr->{'surname'} . ", " . $borr->{'title'} . " " . $borr->{'firstname'};
    if ( $messages->{'transfert'} ) {
        $template->param(
            itemtitle      => $iteminfo->{'title'},
            itemnumber     => $iteminfo->{'itemnumber'},
            itembiblionumber => $iteminfo->{'biblionumber'},
            iteminfo       => $iteminfo->{'author'},
            tobranchname   => GetBranchName($messages->{'transfert'}),
            name           => $name,
            borrowernumber => $borrowernumber,
            borcnum        => $borr->{'cardnumber'},
            borfirstname   => $borr->{'firstname'},
            borsurname     => $borr->{'surname'},
            diffbranch     => 1,
        );
    }
}

my $borrower;
my $returned = 0;
my $messages;
my $issueinformation;
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
if ($barcode) {
    $barcode =~ s/^\s*|\s*$//g; # remove leading/trailing whitespace
    $barcode = barcodedecode($barcode) if C4::Context->preference('itemBarcodeInputFilter');
    $itemnumber = GetItemnumberFromBarcode($barcode);

#
# save the return
#

    # get biblio description
    my $biblio = GetBiblioFromItemNumber($itemnumber);
    # fix up item type for display
    $biblio->{'itemtype'} = C4::Context->preference('item-level_itypes') ? $biblio->{'itype'} : $biblio->{'itemtype'};

    # Check if we should display a checkin message, based on the the item
    # type of the checked in item
    my $itemtype = C4::ItemType->get( $biblio->{'itemtype'} );
    if ( $itemtype->{'checkinmsg'} ) {
        $template->param(
            checkinmsg     => $itemtype->{'checkinmsg'},
            checkinmsgtype => $itemtype->{'checkinmsgtype'},
        );
    }

    # make sure return branch respects home branch circulation rules, default to homebranch
    my $hbr = GetBranchItemRule($biblio->{'homebranch'}, $itemtype->{itemtype})->{'returnbranch'} || "homebranch";
    my $returnbranch = $biblio->{$hbr} ;

    $template->param(
        title            => $biblio->{'title'},
        homebranch       => $biblio->{'homebranch'},
        holdingbranch    => $biblio->{'holdingbranch'},
        returnbranch     => $returnbranch,
        author           => $biblio->{'author'},
        itembarcode      => $biblio->{'barcode'},
        itemtype         => $biblio->{'itemtype'},
        ccode            => $biblio->{'ccode'},
        itembiblionumber => $biblio->{'biblionumber'},
        biblionumber     => $biblio->{'biblionumber'},
        borrower         => $borrower,
        additional_materials => $biblio->{'materials'},
    );

    my %input = (
        counter => 0,
        first   => 1,
        barcode => $barcode,
    );

    # do the return
    ( $returned, $messages, $issueinformation, $borrower ) =
      AddReturn( $barcode, $userenv_branch, $exemptfine, $dropboxmode, $return_date_override, $dropboxdate );

    if ($returned) {
        my $time_now = DateTime->now( time_zone => C4::Context->tz )->truncate( to => 'minute');
        my $duedate = $issueinformation->{date_due}->strftime('%Y-%m-%d %H:%M');
        $returneditems{0}      = $barcode;
        $riborrowernumber{0}   = $borrower->{'borrowernumber'};
        $riduedate{0}          = $duedate;
        $input{borrowernumber} = $borrower->{'borrowernumber'};
        $input{duedate}        = $duedate;
        unless ( $dropboxmode ) {
            $input{return_overdue} = 1 if (DateTime->compare($issueinformation->{date_due}, DateTime->now()) == -1);
        } else {
            $input{return_overdue} = 1 if (DateTime->compare($issueinformation->{date_due}, $dropboxdate) == -1);
        }
        push( @inputloop, \%input );

        if ( C4::Context->preference("FineNotifyAtCheckin") ) {
            my ( $od, $issue, $fines ) = GetMemberIssuesAndFines( $borrower->{'borrowernumber'} );
            if ($fines && $fines > 0) {
                $template->param( fines => sprintf("%.2f",$fines) );
                $template->param( fineborrowernumber => $borrower->{'borrowernumber'} );
            }
        }

        if (C4::Context->preference("WaitingNotifyAtCheckin") ) {
            #Check for waiting holds
            my @reserves = GetReservesFromBorrowernumber($borrower->{'borrowernumber'});
            my $waiting_holds = 0;
            foreach my $num_res (@reserves) {
                if ( $num_res->{'found'} eq 'W' && $num_res->{'branchcode'} eq $userenv_branch) {
                    $waiting_holds++;
                }
            }
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
    my $branchname = $branches->{ $reserve->{'branchcode'} }->{'branchname'};
    my $borr = C4::Members::GetMember( borrowernumber => $reserve->{'borrowernumber'} );
    my $name = $borr->{'surname'} . ", " . $borr->{'title'} . " " . $borr->{'firstname'};
    $template->param(
            wname           => $name,
            wborfirstname   => $borr->{'firstname'},
            wborsurname     => $borr->{'surname'},
            wbortitle       => $borr->{'title'},
            wborphone       => $borr->{'phone'},
            wboremail       => $borr->{'email'},
            wborstnum       => $borr->{streetnumber},
            wboraddress     => $borr->{'address'},
            wboraddress2    => $borr->{'address2'},
            wborcity        => $borr->{'city'},
            wborzip         => $borr->{'zipcode'},
            wborrowernumber => $reserve->{'borrowernumber'},
            wborcnum        => $borr->{'cardnumber'},
            wtransfertFrom  => $userenv_branch,
    );
}

#
# reserve found and item arrived at the expected branch
#
if ( $messages->{'ResFound'}) {
    my $reserve    = $messages->{'ResFound'};
    my $branchname = $branches->{ $reserve->{'branchcode'} }->{'branchname'};
    my $borr = C4::Members::GetMember( borrowernumber => $reserve->{'borrowernumber'} );

    if ( $reserve->{'ResFound'} eq "Waiting" or $reserve->{'ResFound'} eq "Reserved" ) {
        if ( $reserve->{'ResFound'} eq "Waiting" ) {
            $template->param(
                waiting      => ($userenv_branch eq $reserve->{'branchcode'} ? 1 : 0 ),
            );
        } elsif ( $reserve->{'ResFound'} eq "Reserved" ) {
            $template->param(
                intransit    => ($userenv_branch eq $reserve->{'branchcode'} ? 0 : 1 ),
                transfertodo => ($userenv_branch eq $reserve->{'branchcode'} ? 0 : 1 ),
                resbarcode   => $barcode,
                reserved     => 1,
            );
        }

        # same params for Waiting or Reserved
        $template->param(
            found          => 1,
            currentbranch  => $branches->{$userenv_branch}->{'branchname'},
            destbranchname => $branches->{ $reserve->{'branchcode'} }->{'branchname'},
            name           => $borr->{'surname'} . ", " . $borr->{'title'} . " " . $borr->{'firstname'},
            borfirstname   => $borr->{'firstname'},
            borsurname     => $borr->{'surname'},
            bortitle       => $borr->{'title'},
            borphone       => $borr->{'phone'},
            boremail       => $borr->{'email'},
            boraddress     => $borr->{'address'},
            boraddress2    => $borr->{'address2'},
            borstnum       => $borr->{streetnumber},
            borcity        => $borr->{'city'},
            borzip         => $borr->{'zipcode'},
            borcnum        => $borr->{'cardnumber'},
            debarred       => $borr->{'debarred'},
            gonenoaddress  => $borr->{'gonenoaddress'},
            barcode        => $barcode,
            destbranch     => $reserve->{'branchcode'},
            borrowernumber => $reserve->{'borrowernumber'},
            itemnumber     => $reserve->{'itemnumber'},
            reservenotes   => $reserve->{'reservenotes'},
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
        $err{msg} = $branches->{ $messages->{'IsPermanent'} }->{'branchname'} if $messages->{'IsPermanent'};
    }
    elsif ( $code eq 'LocalUse' ) {
        $err{localuse} = 1;
    }
    elsif ( $code eq 'WasLost' ) {
        $err{waslost} = 1;
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
            $err{msg}         =
              $branches->{ $messages->{'IsPermanent'} }->{'branchname'};
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
my $shelflocations = GetKohaAuthorisedValues('items.location','');
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
            my $b      = C4::Members::GetMember( borrowernumber => $riborrowernumber{$_} );
            unless ( $dropboxmode ) {
                $ri{return_overdue} = 1 if (DateTime->compare($duedate, DateTime->now()) == -1);
            } else {
                $ri{return_overdue} = 1 if (DateTime->compare($duedate, $dropboxdate) == -1);
            }
            $ri{borrowernumber} = $b->{'borrowernumber'};
            $ri{borcnum}        = $b->{'cardnumber'};
            $ri{borfirstname}   = $b->{'firstname'};
            $ri{borsurname}     = $b->{'surname'};
            $ri{bortitle}       = $b->{'title'};
            $ri{bornote}        = $b->{'borrowernotes'};
            $ri{borcategorycode}= $b->{'categorycode'};
        }
        else {
            $ri{borrowernumber} = $riborrowernumber{$_};
        }

        #        my %ri;
        my $biblio = GetBiblioFromItemNumber(GetItemnumberFromBarcode($bar_code));
        my $item   = GetItem( GetItemnumberFromBarcode($bar_code) );
        # fix up item type for display
        $biblio->{'itemtype'} = C4::Context->preference('item-level_itypes') ? $biblio->{'itype'} : $biblio->{'itemtype'};
        $ri{itembiblionumber}    = $biblio->{'biblionumber'};
        $ri{itemtitle}           = $biblio->{'title'};
        $ri{itemauthor}          = $biblio->{'author'};
        $ri{itemcallnumber}      = $biblio->{'itemcallnumber'};
        $ri{itemtype}            = $biblio->{'itemtype'};
        $ri{itemnote}            = $biblio->{'itemnotes'};
        $ri{itemnotes_nonpublic} = $item->{'itemnotes_nonpublic'};
        $ri{ccode}               = $biblio->{'ccode'};
        $ri{itemnumber}          = $biblio->{'itemnumber'};
        $ri{barcode}             = $bar_code;
        $ri{homebranch}          = $item->{'homebranch'};
        $ri{holdingbranch}       = $item->{'holdingbranch'};

        $ri{location}         = $biblio->{'location'};
        my $shelfcode = $ri{'location'};
        $ri{'location'} = $shelflocations->{$shelfcode} if ( defined( $shelfcode ) && defined($shelflocations) && exists( $shelflocations->{$shelfcode} ) );

    }
    else {
        last;
    }
    push @riloop, \%ri;
}
my ($genbrname, $genprname);
if (my $b = $branches->{$userenv_branch}) {
    $genbrname = $b->{'branchname'};
}
if (my $p = $printers->{$printer}) {
    $genprname = $p->{'printername'};
}
$template->param(
    riloop         => \@riloop,
    genbrname      => $genbrname,
    genprname      => $genprname,
    branchname     => $genbrname,
    printer        => $printer,
    errmsgloop     => \@errmsgloop,
    exemptfine     => $exemptfine,
    dropboxmode    => $dropboxmode,
    dropboxdate    => output_pref($dropboxdate),
    forgivemanualholdsexpire => $forgivemanualholdsexpire,
    overduecharges => $overduecharges,
    AudioAlerts        => C4::Context->preference("AudioAlerts"),
    BlockReturnOfWithdrawnItems => C4::Context->preference("BlockReturnOfWithdrawnItems"),
);

$itemnumber = GetItemnumberFromBarcode( $barcode );
if ( $itemnumber ) {
   my ( $holdingBranch, $collectionBranch ) = GetCollectionItemBranches( $itemnumber );
    $holdingBranch //= '';
    $collectionBranch //= '';
    if ( ! ( $holdingBranch eq $collectionBranch ) ) {
        $template->param(
          collectionItemNeedsTransferred => 1,
          collectionBranch => GetBranchName($collectionBranch),
        );
    }
}

# actually print the page!
output_html_with_http_headers $query, $cookie, $template->output;
