#!/usr/bin/perl

# Please use 8-character tabs for this file (indents are every 4 characters)

# written 8/5/2002 by Finlay
# script to execute issuing of books

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
use CGI;
use C4::Circulation::Circ2;
use C4::Search;
use C4::Members;
use C4::Output;
use C4::Print;
use DBI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Koha;
use HTML::Template;
use C4::Date;
use Date::Manip;
use C4::Biblio;
use C4::Reserves2;
use C4::Circulation::Date;

#
# PARAMETERS READING
#
my $query = new CGI;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => 'circ/circulation.tmpl',
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { circulate => 1 },
    }
);
my $branches = getbranches();
# my $printers = getprinters();
# my $printer = getprinter($query, $printers);

my $findborrower = $query->param('findborrower');
$findborrower =~ s|,| |g;
$findborrower =~ s|'| |g;
my $borrowernumber = $query->param('borrnumber');
# new op dev the branch and the printer are now defined by the userenv
my $branch = C4::Context->userenv->{'branch'};
my $printer=C4::Context->userenv->{'branchprinter'};

my $barcode = $query->param('barcode') || '';
my $year=$query->param('year');
my $month=$query->param('month');
my $day=$query->param('day');
my $stickyduedate=$query->param('stickyduedate');
my $issueconfirmed = $query->param('issueconfirmed');
my $cancelreserve  = $query->param('cancelreserve');
my $organisation   = $query->param('organisations');
my $print = $query->param('print');

#set up cookie.....
# my $branchcookie;
# my $printercookie;
# if ($query->param('setcookies')) {
# 	$branchcookie = $query->cookie(-name=>'branch', -value=>"$branch", -expires=>'+1y');
# 	$printercookie = $query->cookie(-name=>'printer', -value=>"$printer", -expires=>'+1y');
# }

my %env; # FIXME env is used as an "environment" variable. Could be dropped probably...
#
my $print; 
$env{'branchcode'}= $branch;
$env{'printer'}= $printer;
$env{'organisation'} = $organisation;
# $env{'queue'}=$printer;

my @datearr = localtime(time());
# FIXME - Could just use POSIX::strftime("%Y%m%d", localtime);
my $todaysdate =
    ( 1900 + $datearr[5] )
  . sprintf( "%0.2d", ( $datearr[4] + 1 ) )
  . sprintf( "%0.2d", ( $datearr[3] ) );

# check and see if we should print
if ( $barcode eq '' && $print eq 'maybe' ) {
    $print = 'yes';
}

my $inprocess = $query->param('inprocess');
if ($barcode eq ''){
        $inprocess='';
}
else {
}

if ($barcode eq '' && $query->param('charges') eq 'yes'){
        $template->param( PAYCHARGES=>'yes',
        bornum=>$borrowernumber);
   }

if ( $print eq 'yes' && $borrowernumber ne '' ) {
    printslip( \%env, $borrowernumber );
    $query->param( 'borrnumber', '' );
    $borrowernumber = '';
}

#
# STEP 2 : FIND BORROWER
# if there is a list of find borrowers....
#
my $borrowerslist;
my $message;
if ($findborrower) {
    my ( $count, $borrowers ) =
      BornameSearch( \%env, $findborrower, 'cardnumber', 'web' );
    my @borrowers = @$borrowers;
    if ( $#borrowers == -1 ) {
        $query->param( 'findborrower', '' );
        $message = "'$findborrower'";
    }
    elsif ( $#borrowers == 0 ) {
        $query->param( 'borrnumber', $borrowers[0]->{'borrowernumber'} );
        $query->param( 'barcode',    '' );
        $borrowernumber = $borrowers[0]->{'borrowernumber'};
    }
    else {
        $borrowerslist = \@borrowers;
    }
}

# get the borrower information.....
my $borrower;
my $picture;
my @lines;
if ($borrowernumber) {
    $borrower = getpatroninformation( \%env, $borrowernumber, 0 );
    my ( $od, $issue, $fines ) = borrdata2( \%env, $borrowernumber );
    my $warningdate =
      DateCalc( $borrower->{'expiry'},
        "- " . C4::Context->preference('NotifyBorrowerDeparture') . "  days" );
    my $warning = Date_Cmp( ParseDate("today"), $warningdate );
    if ( $warning > 0 ) {

        #borrowercard expired
        $template->param( warndeparture => $warning );
    }
    my ($reserved_num,$reserved_waiting) = CheckWaiting($borrowernumber);
    if ($reserved_num > 0) {
           for (my $i = 0; $i < $reserved_num; $i++) {
                     my ($count,$line) = getbiblio($reserved_waiting->[$i]->{'biblionumber'});
                     push(@lines, $line);
           }
          # warn Dumper(@lines);
    }
    
    $template->param(
        overduecount => $od,
        issuecount   => $issue,
        finetotal    => $fines,
	returned_reserve => \@lines,
    );
    my $htdocs = C4::Context->config('intrahtdocs');
    $picture = "/borrowerimages/" . $borrowernumber . ".jpg";
    if ( -e $htdocs . "$picture" ) {
        $template->param( picture => $picture );
    }
}

#
# STEP 3 : ISSUING
#
#

if ($barcode) {
    $barcode = cuecatbarcodedecode($barcode);
    my ( $datedue, $invalidduedate ) = fixdate( $year, $month, $day );
    if ($issueconfirmed) {
        issuebook( \%env, $borrower, $barcode, $datedue, $cancelreserve );
	$inprocess=1;
    }
    else {
        my ( $error, $question ) =
          canbookbeissued( \%env, $borrower, $barcode, $year, $month, $day, $inprocess );
        my $noerror    = 1;
        my $noquestion = 1;
        foreach my $impossible ( keys %$error ) {
            $template->param(
                $impossible => $$error{$impossible},
                IMPOSSIBLE  => 1
            );
            $noerror = 0;
        }
        foreach my $needsconfirmation ( keys %$question ) {
            $template->param(
                $needsconfirmation => $$question{$needsconfirmation},
                NEEDSCONFIRMATION  => 1
            );
            $noquestion = 0;
        }
        $template->param(
            day   => $day,
            month => $month,
            year  => $year
        );
        if ( $noerror && ( $noquestion || $issueconfirmed ) ) {
            issuebook( \%env, $borrower, $barcode, $datedue );
	    $inprocess=1;
        }
    }
}

# reload the borrower info for the sake of reseting the flags.....
if ($borrowernumber) {
    $borrower = getpatroninformation( \%env, $borrowernumber, 0 );
}

##################################################################################
# BUILD HTML
# show all reserves of this borrower, and the position of the reservation ....
if ($borrowernumber) {
# new op dev
# now we show the status of the borrower's reservations
	my @borrowerreserv = FastFindReserves(0,$borrowernumber);
	my @reservloop;
	foreach my $num_res (@borrowerreserv) {
		my %getreserv;
		my %env;
		my $getiteminfo = getiteminformation(\%env,$num_res->{'itemnumber'});
		my $itemtypeinfo = getitemtypeinfo($getiteminfo->{'itemtype'});
		my ($transfertwhen,$transfertfrom,$transfertto) = checktransferts($num_res->{'itemnumber'});

		$getreserv{waiting} = 0;
		$getreserv{transfered} = 0;
		$getreserv{nottransfered} = 0;

		$getreserv{reservedate} = format_date($num_res->{'reservedate'});
		$getreserv{biblionumber} = $getiteminfo->{'biblionumber'};
		$getreserv{title} = $getiteminfo->{'title'};
		$getreserv{itemtype} = $itemtypeinfo->{'description'};
		$getreserv{author} = $getiteminfo->{'author'};
		$getreserv{barcodereserv} = $getiteminfo->{'barcode'};
		$getreserv{itemcallnumber} = $getiteminfo->{'itemcallnumber'};
# 		check if we have a waitin status for reservations
		if ($num_res->{'found'} eq 'W'){
			$getreserv{color} = 'reserved';
			$getreserv{waiting} = 1; 
		}

# 		check transfers with the itemnumber foud in th reservation loop
		if ($transfertwhen){
		$getreserv{color} = 'transfered';
		$getreserv{transfered} = 1;
		$getreserv{datesent} = format_date($transfertwhen);
		$getreserv{frombranch} = getbranchname($transfertfrom);
		}

		if (($getiteminfo->{'holdingbranch'} ne $num_res->{'branchcode'}) and not $transfertwhen){
		$getreserv{nottransfered} = 1;
		$getreserv{nottransferedby} = getbranchname($getiteminfo->{'holdingbranch'});
		}

# 		if we don't have a reserv on item, we put the biblio infos and the waiting position	
		if ($getiteminfo->{'title'} eq '' ){
			my $getbibinfo = bibitemdata($num_res->{'biblionumber'});
			my $getbibtype = getitemtypeinfo($getbibinfo->{'itemtype'});
			$getreserv{color} = 'inwait';
			$getreserv{title} = $getbibinfo->{'title'};
			$getreserv{waitingposition} = $num_res->{'priority'};
			$getreserv{nottransfered} = 0;
			$getreserv{itemtype} = $getbibtype->{'description'};
			$getreserv{author} = $getbibinfo->{'author'};
			$getreserv{itemcallnumber} = '----------';
			
 		}

		push(@reservloop, \%getreserv);
	}
	# return result to the template
	$template->param(reservloop => \@reservloop);

}


# make the issued books table.....
my $todaysissues = '';
my $previssues   = '';
my @realtodayissues;
my @realprevissues;
my $allowborrow;
if ($borrower) {

# get each issue of the borrower & separate them in todayissues & previous issues
    my @todaysissues;
    my @previousissues;
    my $issueslist = getissues($borrower);

    # split in 2 arrays for today & previous
    my $dbh = C4::Context->dbh;
    foreach my $it ( keys %$issueslist ) {
        my $issuedate = $issueslist->{$it}->{'timestamp'};
        $issuedate =~ s/-//g;
        $issuedate = substr( $issuedate, 0, 8 );
        if ( $todaysdate == $issuedate ) {
	        ($issueslist->{$it}->{'charge'}, $issueslist->{$it}->{'itemtype_charge'})=calc_charges($dbh,$issueslist->{$it}->{'itemnumber'},$borrower->{'borrowernumber'});
	        $issueslist->{$it}->{'charge'} = sprintf("%.2f",$issueslist->{$it}->{'charge'});
	        ($issueslist->{$it}->{'can_renew'}, $issueslist->{$it}->{'can_renew_error'}) =renewstatus(\%env,$borrower->{'borrowernumber'}, $issueslist->{$it}->{'itemnumber'});
		my ($restype,$reserves)=CheckReserves($issueslist->{$it}->{'itemnumber'});
		if ($restype){
		    $issueslist->{$it}->{'can_renew'}=0;
		}
		push @todaysissues, $issueslist->{$it};
        }
        else {
                ($issueslist->{$it}->{'charge'}, $issueslist->{$it}->{'itemtype_charge'})=calc_charges($dbh,$issueslist->{$it}->{'itemnumber'},$borrower->{'borrowernumber'});
	        $issueslist->{$it}->{'charge'} = sprintf("%.2f",$issueslist->{$it}->{'charge'});
	        ($issueslist->{$it}->{'can_renew'}, $issueslist->{$it}->{'can_renew_error'}) =renewstatus(\%env,$borrower->{'borrowernumber'}, $issueslist->{$it}->{'itemnumber'});
	        my ($restype,$reserves)=CheckReserves($issueslist->{$it}->{'itemnumber'});
	        if ($restype){
		    $issueslist->{$it}->{'can_renew'}=0;
		}
	        push @previousissues, $issueslist->{$it};
        }
    }
    my $od;    # overdues
    my $i = 0;
    my $togglecolor;

    # parses today & build Template array
    foreach my $book ( sort { $b->{'timestamp'} <=> $a->{'timestamp'} }
        @todaysissues )
    {
        my $dd      = $book->{'date_due'};
        my $datedue = $book->{'date_due'};
        $dd = format_date($dd);
        $datedue =~ s/-//g;
        if ( $datedue < $todaysdate ) {
            $od = 1;
        }
        else {
            $od = 0;
        }
        if ( $i % 2 ) {
            $togglecolor = 0;
        }
        else {
            $togglecolor = 1;
        }
        $book->{'togglecolor'} = $togglecolor;
        $book->{'od'}          = $od;
        $book->{'dd'}          = $dd;
        if ( $book->{'author'} eq '' ) {
            $book->{'author'} = ' ';
        }
        push @realtodayissues, $book;
        $i++;
    }

    # parses previous & build Template array
    $i = 0;
    foreach my $book ( sort { $a->{'date_due'} cmp $b->{'date_due'} }
        @previousissues )
    {
        my $dd      = $book->{'date_due'};
        my $datedue = $book->{'date_due'};
        $dd = format_date($dd);
        my $pcolor = '';
        my $od     = '';
        $datedue =~ s/-//g;
        if ( $datedue < $todaysdate ) {
            $od = 1;
        }
        else {
            $od = 0;
        }
        if ( $i % 2 ) {
            $togglecolor = 0;
        }
        else {
            $togglecolor = 1;
        }
        $book->{'togglecolor'} = $togglecolor;
        $book->{'dd'}          = $dd;
        $book->{'od'}          = $od;
        if ( $book->{'author'} eq '' ) {
            $book->{'author'} = ' ';
        }
        push @realprevissues, $book;
        $i++;
    }
}

my @values;
my %labels;
my $CGIselectborrower;
if ($borrowerslist) {
    foreach (
        sort {
            $a->{'surname'}
              . $a->{'firstname'} cmp $b->{'surname'}
              . $b->{'firstname'}
        } @$borrowerslist
      )
    {
        push @values, $_->{'borrowernumber'};
        $labels{ $_->{'borrowernumber'} } =
"$_->{'surname'}, $_->{'firstname'} ... ($_->{'cardnumber'} - $_->{'categorycode'}) ...  $_->{'streetaddress'} ";
    }
    $CGIselectborrower = CGI::scrolling_list(
        -name     => 'borrnumber',
        -values   => \@values,
        -labels   => \%labels,
        -size     => 7,
        -multiple => 0
    );
}

#title

my ( $patrontable, $flaginfotable ) = patrontable($borrower);
my $amountold = $borrower->{flags}->{'CHARGES'}->{'message'} || 0;
my @temp = split( /\$/, $amountold );

my $CGIorganisations;
my $member_of_institution;
if ( C4::Context->preference("memberofinstitution") ) {
    my $organisations = get_institutions();
    my @orgs;
    my %org_labels;
    foreach my $organisation ( keys %$organisations ) {
        push @orgs, $organisation;
        $org_labels{$organisation} =
          $organisations->{$organisation}->{'surname'};
    }
    $member_of_institution = 1;
    $CGIorganisations = CGI::popup_menu(
        -id       => 'organisations',
        -name     => 'organisations',
        -labels   => \%org_labels,
        -values   => \@orgs,

    );
}

$amountold = $temp[1];
$template->param(
    findborrower      => $findborrower,
    borrower          => $borrower,
    borrowernumber    => $borrowernumber,
    branch            => $branch,
    printer           => $printer,
    printername       => $printer,
    firstname         => $borrower->{'firstname'},
    surname           => $borrower->{'surname'},
    categorycode      => $borrower->{'categorycode'},
    streetaddress     => $borrower->{'streetaddress'},
    emailaddress      => $borrower->{'emailaddress'},
    borrowernotes     => $borrower->{'borrowernotes'},
    city              => $borrower->{'city'},
    phone             => $borrower->{'phone'},
    cardnumber        => $borrower->{'cardnumber'},
    amountold         => $amountold,
    barcode           => $barcode,
    stickyduedate     => $stickyduedate,
    message           => $message,
    CGIselectborrower => $CGIselectborrower,
    todayissues       => \@realtodayissues,
    previssues        => \@realprevissues,
    inprocess         => $inprocess,
    memberofinstution => $member_of_institution,                                                                 
    CGIorganisations => $CGIorganisations, 
);

# set return date if stickyduedate
if ($stickyduedate) {
    my $t_year  = "year" . $year;
    my $t_month = "month" . $month;
    my $t_day   = "day" . $day;
    $template->param(
        $t_year  => 1,
        $t_month => 1,
        $t_day   => 1,
    );
}


# if ($branchcookie) {
#     $cookie=[$cookie, $branchcookie, $printercookie];
# }

output_html_with_http_headers $query, $cookie, $template->output;

####################################################################
# Extra subroutines,,,

sub patrontable {
    my ($borrower)    = @_;
    my $flags         = $borrower->{'flags'};
    my $flaginfotable = '';
    my $flaginfotext;

    #my $flaginfotext='';
    my $flag;
    my $color = '';
    foreach $flag ( sort keys %$flags ) {

        #    	my @itemswaiting='';
        $flags->{$flag}->{'message'} =~ s/\n/<br>/g;
        if ( $flags->{$flag}->{'noissues'} ) {
            $template->param(
                flagged  => 1,
                noissues => 'true',
            );
            if ( $flag eq 'GNA' ) {
                $template->param( gna => 'true' );
            }
            if ( $flag eq 'LOST' ) {
                $template->param( lost => 'true' );
            }
            if ( $flag eq 'DBARRED' ) {
                $template->param( dbarred => 'true' );
            }
            if ( $flag eq 'CHARGES' ) {
                $template->param(
                    charges    => 'true',
                    chargesmsg => $flags->{'CHARGES'}->{'message'}
                );
            }
	    if ($flag eq 'CREDITS') {
		$template->param(
		    credits => 'true',
	            creditsmsg => $flags->{'CREDITS'}->{'message'}
		);
	    }
        }
        else {
            if ( $flag eq 'CHARGES' ) {
                $template->param(
                    charges    => 'true',
                    flagged    => 1,
                    chargesmsg => $flags->{'CHARGES'}->{'message'}
                );
            }
            if ($flag eq 'CREDITS') {
		$template->param(
		    credits => 'true',
		    creditsmsg => $flags->{'CREDITS'}->{'message'}
                );
            }

# FIXME this part can be removed if we keep new display of reserves "reservloop"
#             if ( $flag eq 'WAITING' ) {
#                 my $items = $flags->{$flag}->{'itemlist'};
#                 my @itemswaiting;
#                 foreach my $item (@$items) {
#                     my ($iteminformation) =
#                       getiteminformation( \%env, $item->{'itemnumber'}, 0 );
#                     $iteminformation->{'branchname'} =
#                       $branches->{ $iteminformation->{'holdingbranch'} }
#                       ->{'branchname'};
#                     push @itemswaiting, $iteminformation;
#                 }
#                 $template->param(
#                     flagged      => 1,
#                     waiting      => 'true',
#                     waitingmsg   => $flags->{'WAITING'}->{'message'},
#                     itemswaiting => \@itemswaiting,
#                 );
#             }
            if ( $flag eq 'ODUES' ) {
                $template->param(
                    odues    => 'true',
                    flagged  => 1,
                    oduesmsg => $flags->{'ODUES'}->{'message'}
                );

                my $items = $flags->{$flag}->{'itemlist'};
                {
                    my @itemswaiting;
                    foreach my $item (@$items) {
                        my ($iteminformation) =
                          getiteminformation( \%env, $item->{'itemnumber'}, 0 );
                        push @itemswaiting, $iteminformation;
                    }
                }
                if ( $query->param('module') ne 'returns' ) {
                    $template->param( nonreturns => 'true' );
                }
            }
            if ( $flag eq 'NOTES' ) {
                $template->param(
                    notes    => 'true',
                    flagged  => 1,
                    notesmsg => $flags->{'NOTES'}->{'message'}
                );
            }
        }
    }
    return ( $patrontable, $flaginfotext );
}

sub cuecatbarcodedecode {
    my ($barcode) = @_;
    chomp($barcode);
    my @fields = split( /\./, $barcode );
    my @results = map( decode($_), @fields[ 1 .. $#fields ] );
    if ( $#results == 2 ) {
        return $results[2];
    }
    else {
        return $barcode;
    }
}

# Local Variables:
# tab-width: 8
# End:
