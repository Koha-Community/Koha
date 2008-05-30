#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
#           2006 SAN-OP
#           2007 BibLibre, Paul POULAIN
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

=head1 returns.pl

script to execute returns of books

=cut

use strict;
use CGI;
use C4::Context;
use C4::Auth qw/:DEFAULT get_session/;
use C4::Output;
use C4::Circulation;
use C4::Dates qw/format_date/;
use Date::Calc qw/Add_Delta_Days/;
use C4::Calendar;
use C4::Print;
use C4::Reserves;
use C4::Biblio;
use C4::Items;
use C4::Members;
use C4::Branch; # GetBranchName
use C4::Koha;   # FIXME : is it still useful ?

my $query = new CGI;

if (!C4::Context->userenv){
	my $sessionID = $query->cookie("CGISESSID");
	my $session = get_session($sessionID);
	if ($session->param('branch') eq 'NO_LIBRARY_SET'){
		# no branch set we can't return
		print $query->redirect("/cgi-bin/koha/circ/selectbranchprinter.pl");
		exit;
	}
} 

#getting the template
my ( $template, $librarian, $cookie ) = get_template_and_user(
    {
        template_name   => "circ/returns.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { circulate => 1 },
    }
);

#####################
#Global vars
my $branches = GetBranches();
my $printers = GetPrinters();

#my $branch  = C4::Context->userenv?C4::Context->userenv->{'branch'}:"";
my $printer = C4::Context->userenv?C4::Context->userenv->{'branchprinter'}:"";
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
    (next) unless (/ri-(\d*)/);
    my %input;
    my $counter = $1;
    (next) if ( $counter > 20 );
    my $barcode        = $query->param("ri-$counter");
    my $duedate        = $query->param("dd-$counter");
    my $borrowernumber = $query->param("bn-$counter");
    $counter++;

    # decode barcode
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
    # set to waiting....
    my $iteminfo   = GetBiblioFromItemNumber($item);
    # fix up item type for display
    $iteminfo->{'itemtype'} = C4::Context->preference('item-level_itypes') ? $iteminfo->{'itype'} : $iteminfo->{'itemtype'};
    my $diffBranchSend;
    
#     addin in ModReserveAffect the possibility to check if the document is expected in this library or not,
# if not we send a value in reserve waiting for not implementting waiting status
    if ($diffBranchReturned) {
        $diffBranchSend = $diffBranchReturned;
    }
    else {
        $diffBranchSend = undef;
    }
    ModReserveAffect( $item, $borrowernumber,$diffBranchSend);
#   check if we have other reservs for this document, if we have a return send the message of transfer
    my ( $messages, $nextreservinfo ) = GetOtherReserves($item);

    my $branchname = GetBranchName( $messages->{'transfert'} );
    my ($borr) = GetMemberDetails( $nextreservinfo, 0 );
    my $borcnum = $borr->{'cardnumber'};
    my $name    =
      $borr->{'surname'} . ", " . $borr->{'title'} . " " . $borr->{'firstname'};
    my $slip = $query->param('resslip');


    if ( $messages->{'transfert'} ) {
        $template->param(
            itemtitle      => $iteminfo->{'title'},
			itembiblionumber => $iteminfo->{'biblionumber'},
            iteminfo       => $iteminfo->{'author'},
            tobranchname   => $branchname,
            name           => $name,
            borrowernumber => $borrowernumber,
            borcnum        => $borcnum,
            borfirstname   => $borr->{'firstname'},
            borsurname     => $borr->{'surname'},
            diffbranch     => 1
        );
    }
}

my $borrower;
my $returned = 0;
my $messages;
my $issueinformation;
my $barcode = $query->param('barcode');
# strip whitespace
# $barcode =~ s/\s*//g; - use barcodedecode for this; whitespace is not invalid.
my $exemptfine = $query->param('exemptfine');
my $dropboxmode= $query->param('dropboxmode');
my $calendar = C4::Calendar->new(  branchcode => C4::Context->userenv->{'branch'} );
	#dropbox: get last open day (today - 1)
my $dropboxdate = $calendar->addDate(C4::Dates->new(), -1 );
my $dotransfer = $query->param('dotransfer');
if ($dotransfer){
	# An item has been returned to a branch other than the homebranch, and the librarian has choosen to initiate a transfer
	my $transferitem=$query->param('transferitem');
	my $tobranch=$query->param('tobranch');
	ModItemTransfer($transferitem, C4::Context->userenv->{'branch'}, $tobranch); 
}

# actually return book and prepare item table.....
if ($barcode) {
    $barcode = barcodedecode($barcode)  if(C4::Context->preference('itemBarcodeInputFilter'));
#
# save the return
#
    ( $returned, $messages, $issueinformation, $borrower ) =
      AddReturn( $barcode, C4::Context->userenv->{'branch'}, $exemptfine, $dropboxmode);
    # get biblio description
    my $biblio = GetBiblioFromItemNumber($issueinformation->{'itemnumber'});
    # fix up item type for display
    $biblio->{'itemtype'} = C4::Context->preference('item-level_itypes') ? $biblio->{'itype'} : $biblio->{'itemtype'};

    $template->param(
        title            => $biblio->{'title'},
        homebranch       => $biblio->{'homebranch'},
        author           => $biblio->{'author'},
        itembarcode      => $biblio->{'barcode'},
        itemtype         => $biblio->{'itemtype'},
        ccode            => $biblio->{'ccode'},
        itembiblionumber => $biblio->{'biblionumber'},    
    );
    if ($returned) {
        $returneditems{0}    = $barcode;
        $riborrowernumber{0} = $borrower->{'borrowernumber'};
        $riduedate{0}        = $issueinformation->{'date_due'};
        my %input;
        $input{counter}        = 0;
        $input{first}          = 1;
        $input{barcode}        = $barcode;
        $input{duedate}        = $riduedate{0};
        $input{borrowernumber} = $riborrowernumber{0};
        push( @inputloop, \%input );

        # check if the branch is the same as homebranch
        # if not, we want to put a message
        if ( $biblio->{'homebranch'} ne C4::Context->userenv->{'branch'} ) {
            $template->param( homebranch => $biblio->{'homebranch'} );
        }
    }
    elsif ( !$messages->{'BadBarcode'} ) {
        my %input;
        $input{counter} = 0;
        $input{first}   = 1;
        $input{barcode} = $barcode;
        $input{duedate} = 0;

        $returneditems{0} = $barcode;
        $riduedate{0}     = 0;
        if ( $messages->{'wthdrawn'} ) {
            $input{withdrawn}      = 1;
            $input{borrowernumber} = "Item Cancelled";
            $riborrowernumber{0}   = 'Item Cancelled';
        }
        else {
            $input{borrowernumber} = "&nbsp;";
            $riborrowernumber{0} = '&nbsp;';
        }
        push( @inputloop, \%input );
    }
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
    );
}

if ( $messages->{'NeedsTransfer'} ){
	$template->param(
		found          => 1,
		needstransfer  => 1,
		itemnumber => $issueinformation->{'itemnumber'}
	);
}

if ( $messages->{'Wrongbranch'} ){
	$template->param(
		wrongbranch => 1,
	);
}

# adding a case of wrong transfert, if the document wasn't transfered in the good library (according to branchtransfer (tobranch) BDD)

if ( $messages->{'WrongTransfer'} and not $messages->{'WasTransfered'}) {
	$template->param(
        WrongTransfer  => 1,
        TransferWaitingAt => $messages->{'WrongTransfer'},
        WrongTransferItem => $messages->{'WrongTransferItem'},
    );

    my $reserve        = $messages->{'ResFound'};
    my $branchname = $branches->{ $reserve->{'branchcode'} }->{'branchname'};
    my ($borr) = GetMemberDetails( $reserve->{'borrowernumber'}, 0 );
    my $name =
      $borr->{'surname'} . " " . $borr->{'title'} . " " . $borr->{'firstname'};
        $template->param(
            wname           => $name,
            wborfirstname   => $borr->{'firstname'},
            wborsurname     => $borr->{'surname'},
            wbortitle       => $borr->{'title'},
            wborphone       => $borr->{'phone'},
            wboremail       => $borr->{'email'},
            wboraddress  => $borr->{'address'},
            wboraddress2 => $borr->{'address2'},
            wborcity        => $borr->{'city'},
            wborzip         => $borr->{'zipcode'},
            wborrowernumber => $reserve->{'borrowernumber'},
            wborcnum        => $borr->{'cardnumber'},
            wtransfertFrom    => C4::Context->userenv->{'branch'},
        );
}


#
# reserve found and item arrived at the expected branch
#
if ( $messages->{'ResFound'}) {
    my $reserve        = $messages->{'ResFound'};
    my $branchname = $branches->{ $reserve->{'branchcode'} }->{'branchname'};
    my ($borr) = GetMemberDetails( $reserve->{'borrowernumber'}, 0 );
    if ( $reserve->{'ResFound'} eq "Waiting" ) {
        if ( C4::Context->userenv->{'branch'} eq $reserve->{'branchcode'} ) {
            $template->param( waiting => 1 );
        }
        else {
            $template->param( waiting => 0 );
        }

        $template->param(
            found          => 1,
            name           => $borr->{'surname'} . " " . $borr->{'title'} . " " . $borr->{'firstname'},
            borfirstname   => $borr->{'firstname'},
            borsurname     => $borr->{'surname'},
            bortitle       => $borr->{'title'},
            borphone       => $borr->{'phone'},
            boremail       => $borr->{'email'},
            boraddress  => $borr->{'address'},
            boraddress2  => $borr->{'address2'},
            borcity        => $borr->{'city'},
            borzip         => $borr->{'zipcode'},
            borrowernumber => $reserve->{'borrowernumber'},
            borcnum        => $borr->{'cardnumber'},
            debarred       => $borr->{'debarred'},
            gonenoaddress  => $borr->{'gonenoaddress'},
            currentbranch  => $branches->{C4::Context->userenv->{'branch'}}->{'branchname'},
            itemnumber       => $reserve->{'itemnumber'},
            barcode     => $barcode,
        );

    }
    if ( $reserve->{'ResFound'} eq "Reserved" ) {
       # my @da         = localtime( time() );
       # my $todaysdate = sprintf( "%0.2d/%0.2d/%0.4d", ( $datearr[3] + 1 ),( $datearr[4] + 1 ),( $datearr[5] + 1900 ) );
		# FIXME - use Dates obj , locale. AND, why [4]+1 ??
        if ( C4::Context->userenv->{'branch'} eq $reserve->{'branchcode'} ) {
            $template->param( intransit => 0 );
        }
        else {
            $template->param( intransit => 1 );
        }

        $template->param(
            found          => 1,
            currentbranch  => $branches->{C4::Context->userenv->{'branch'}}->{'branchname'},
            destbranchname =>
              $branches->{ $reserve->{'branchcode'} }->{'branchname'},
            destbranch	   => $reserve->{'branchcode'},
            transfertodo => ( C4::Context->userenv->{'branch'} eq $reserve->{'branchcode'} ? 0 : 1 ),
            reserved => 1,
            resbarcode       => $barcode,
          #  today            => $todaysdate,
            itemnumber       => $reserve->{'itemnumber'},
            borsurname       => $borr->{'surname'},
            bortitle         => $borr->{'title'},
            borfirstname     => $borr->{'firstname'},
            borrowernumber   => $reserve->{'borrowernumber'},
            borcnum          => $borr->{'cardnumber'},
            borphone         => $borr->{'phone'},
            boraddress    => $borr->{'address'},
            boraddress2    => $borr->{'address2'},
            borsub           => $borr->{'suburb'},
            borcity          => $borr->{'city'},
            borzip           => $borr->{'zipcode'},
            boremail         => $borr->{'email'},
            debarred         => $borr->{'debarred'},
            gonenoaddress    => $borr->{'gonenoaddress'},
            barcode          => $barcode
        );
    }
}

# Error Messages
my @errmsgloop;
foreach my $code ( keys %$messages ) {

    #    warn $code;
    my %err;
    my $exit_required_p = 0;
    if ( $code eq 'BadBarcode' ) {
        $err{badbarcode} = 1;
        $err{msg}        = $messages->{'BadBarcode'};
    }
    elsif ( $code eq 'NotIssued' ) {
        $err{notissued} = 1;
        $err{msg} = $branches->{ $messages->{'IsPermanent'} }->{'branchname'};
    }
    elsif ( $code eq 'WasLost' ) {
        $err{waslost} = 1;
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
    elsif ( $code eq 'wthdrawn' ) {
        $err{withdrawn} = 1;
        $exit_required_p = 1;
    }
    elsif ( ( $code eq 'IsPermanent' ) && ( not $messages->{'ResFound'} ) ) {
        if ( $messages->{'IsPermanent'} ne C4::Context->userenv->{'branch'} ) {
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
		
    else {
        die "Unknown error code $code";    # XXX
    }
    if (%err) {
        push( @errmsgloop, \%err );
    }
    last if $exit_required_p;
}
$template->param( errmsgloop => \@errmsgloop );

# patrontable ....
if ($borrower) {
    my $flags = $borrower->{'flags'};
    my @flagloop;
    my $flagset;
    foreach my $flag ( sort keys %$flags ) {
        my %flaginfo;
        unless ($flagset) { $flagset = 1; }
        $flaginfo{redfont} = ( $flags->{$flag}->{'noissues'} );
        $flaginfo{flag}    = $flag;
        if ( $flag eq 'CHARGES' ) {
            $flaginfo{msg}            = $flag;
            $flaginfo{charges}        = 1;
            $flaginfo{borrowernumber} = $borrower->{borrowernumber};
        }
        elsif ( $flag eq 'WAITING' ) {
            $flaginfo{msg}     = $flag;
            $flaginfo{waiting} = 1;
            my @waitingitemloop;
            my $items = $flags->{$flag}->{'itemlist'};
            foreach my $item (@$items) {
                my $biblio =
                  GetBiblioFromItemNumber( $item->{'itemnumber'});
                my %waitingitem;
                $waitingitem{biblionum} = $biblio->{'biblionumber'};
                $waitingitem{barcode}   = $biblio->{'barcode'};
                $waitingitem{title}     = $biblio->{'title'};
                $waitingitem{brname}    =
                  $branches->{ $biblio->{'holdingbranch'} }
                  ->{'branchname'};
                push( @waitingitemloop, \%waitingitem );
            }
            $flaginfo{itemloop} = \@waitingitemloop;
        }
        elsif ( $flag eq 'ODUES' ) {
            my $items = $flags->{$flag}->{'itemlist'};
            my @itemloop;
            foreach my $item ( sort { $a->{'date_due'} cmp $b->{'date_due'} }
                @$items )
            {
                my $biblio =
                  GetBiblioFromItemNumber( $item->{'itemnumber'});
                my %overdueitem;
                $overdueitem{duedate}   = format_date( $item->{'date_due'} );
                $overdueitem{biblionum} = $biblio->{'biblionumber'};
                $overdueitem{barcode}   = $biblio->{'barcode'};
                $overdueitem{title}     = $biblio->{'title'};
                $overdueitem{brname}    =
                  $branches->{ $biblio->{'holdingbranch'} }
                  ->{'branchname'};
                push( @itemloop, \%overdueitem );
            }
            $flaginfo{itemloop} = \@itemloop;
            $flaginfo{overdue}  = 1;
        }
        else {
            $flaginfo{other} = 1;
            $flaginfo{msg}   = $flags->{$flag}->{'message'};
        }
        push( @flagloop, \%flaginfo );
    }
    $template->param(
        flagset          => $flagset,
        flagloop         => \@flagloop,
        riborrowernumber => $borrower->{'borrowernumber'},
        riborcnum        => $borrower->{'cardnumber'},
        riborsurname     => $borrower->{'surname'},
        ribortitle       => $borrower->{'title'},
        riborfirstname   => $borrower->{'firstname'}
    );
}

#set up so only the last 8 returned items display (make for faster loading pages)
my $count = 0;
my @riloop;
foreach ( sort { $a <=> $b } keys %returneditems ) {
    my %ri;
    if ( $count < 8 ) {
        my $barcode = $returneditems{$_};
        my $duedate = $riduedate{$_};
        my $overduetext;
        my $borrowerinfo;
        if ($duedate) {
            my @tempdate = split( /-/, $duedate );
            $ri{year}  = $tempdate[0];
            $ri{month} = $tempdate[1];
            $ri{day}   = $tempdate[2];
            my $duedatenz  = "$tempdate[2]/$tempdate[1]/$tempdate[0]";
            my @datearr    = localtime( time() );
            my $todaysdate =
                $datearr[5] . '-'
              . sprintf( "%0.2d", ( $datearr[4] + 1 ) ) . '-'
              . sprintf( "%0.2d", $datearr[3] );
		  # FIXME - todaysdate isn't used, and what date _is_ it ?
            $ri{duedate} = format_date($duedate);
            my ($borrower) =
              GetMemberDetails( $riborrowernumber{$_}, 0 );
            $ri{borrowernumber} = $borrower->{'borrowernumber'};
            $ri{borcnum}        = $borrower->{'cardnumber'};
            $ri{borfirstname}   = $borrower->{'firstname'};
            $ri{borsurname}     = $borrower->{'surname'};
            $ri{bortitle}       = $borrower->{'title'};
            $ri{bornote}        = $borrower->{'borrowernotes'};
        }
        else {
            $ri{borrowernumber} = $riborrowernumber{$_};
        }

        #        my %ri;
        my $biblio = GetBiblioFromItemNumber(GetItemnumberFromBarcode($barcode));
        # fix up item type for display
        $biblio->{'itemtype'} = C4::Context->preference('item-level_itypes') ? $biblio->{'itype'} : $biblio->{'itemtype'};
        $ri{itembiblionumber} = $biblio->{'biblionumber'};
        $ri{itemtitle}        = $biblio->{'title'};
        $ri{itemauthor}       = $biblio->{'author'};
        $ri{itemtype}         = $biblio->{'itemtype'};
        $ri{ccode}            = $biblio->{'ccode'};
        $ri{barcode}          = $barcode;
    }
    else {
        last;
    }
    $count++;
    push( @riloop, \%ri );
}
$template->param( riloop => \@riloop );

$template->param(
    genbrname               => $branches->{C4::Context->userenv->{'branch'}}->{'branchname'},
    genprname               => $printers->{$printer}->{'printername'},
    branchname              => $branches->{C4::Context->userenv->{'branch'}}->{'branchname'},
    printer                 => $printer,
    errmsgloop              => \@errmsgloop,
    exemptfine              => $exemptfine,
    dropboxmode              => $dropboxmode,
    dropboxdate				=> $dropboxdate->output(),
	overduecharges          => $overduecharges,
);

# actually print the page!
output_html_with_http_headers $query, $cookie, $template->output;
