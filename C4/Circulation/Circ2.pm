package C4::Circulation::Circ2;

#package to deal with Returns
#written 3/11/99 by olwen@katipo.co.nz


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
# use warnings;
require Exporter;
use DBI;
use C4::Context;
#use C4::Accounts;
#use C4::InterfaceCDK;
#use C4::Circulation::Main;
#use C4::Format;
#use C4::Circulation::Renewals;
#use C4::Scan;
use C4::Stats;
use C4::Reserves2;
#use C4::Search;
#use C4::Print;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&getbranches &getprinters &getpatroninformation &currentissues &getissues &getiteminformation &findborrower &issuebook &returnbook &find_reserves &transferbook &decode
calc_charges);
%EXPORT_TAGS = ( );     # eg: TAG => [ qw!name1 name2! ],
		  
# your exported package globals go here,
# as well as any optionally exported functions

@EXPORT_OK   = qw($Var1 %Hashit);


# non-exported package globals go here
#use vars qw(@more $stuff);
	
# initalize package globals, first exported ones

my $Var1   = '';
my %Hashit = ();
		    
# then the others (which are still accessible as $Some::Module::stuff)
my $stuff  = '';
my @more   = ();
	
# all file-scoped lexicals must be created before
# the functions below that use them.
		
# file-private lexicals go here
my $priv_var    = '';
my %secret_hash = ();
			    
# here's a file-private function as a closure,
# callable as &$priv_func;  it cannot be prototyped.
my $priv_func = sub {
  # stuff goes here.
};
						    
# make all your functions, whether exported or not;


sub getbranches {
# returns a reference to a hash of references to branches...
    my %branches;
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare("select * from branches");
    $sth->execute;
    while (my $branch=$sth->fetchrow_hashref) {
	my $tmp = $branch->{'branchcode'}; my $brc = $dbh->quote($tmp);
	my $query = "select categorycode from branchrelations where branchcode = $brc";
	my $nsth = $dbh->prepare($query);
	$nsth->execute;
	while (my ($cat) = $nsth->fetchrow_array) {
	    $branch->{$cat} = 1;
	}
	$nsth->finish;
	$branches{$branch->{'branchcode'}}=$branch;
    }
    return (\%branches);
}


sub getprinters {
    my ($env) = @_;
    my %printers;
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare("select * from printers");
    $sth->execute;
    while (my $printer=$sth->fetchrow_hashref) {
	$printers{$printer->{'printqueue'}}=$printer;
    }
    return (\%printers);
}



sub getpatroninformation {
# returns 
    my ($env, $borrowernumber,$cardnumber) = @_;
    my $dbh = C4::Context->dbh;
    my $query;
    my $sth;
    if ($borrowernumber) {
	$query = "select * from borrowers where borrowernumber=$borrowernumber";
    } elsif ($cardnumber) {
	$query = "select * from borrowers where cardnumber=$cardnumber";
    } else {
	$env->{'apierror'} = "invalid borrower information passed to getpatroninformation subroutine";
	return();
    }
    $env->{'mess'} = $query;
    $sth = $dbh->prepare($query);
    $sth->execute;
    my $borrower = $sth->fetchrow_hashref;
    my $flags = patronflags($env, $borrower, $dbh);
    $sth->finish;
    $borrower->{'flags'}=$flags;
    return($borrower, $flags);
}

sub decode {
    my ($encoded) = @_;
    my $seq = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789+-';
    my @s = map { index($seq,$_); } split(//,$encoded);
    my $l = ($#s+1) % 4;
    if ($l)
    {
	if ($l == 1)
	{
	    print "Error!";
	    return;
	}
	$l = 4-$l;
	$#s += $l;
    }
    my $r = '';
    while ($#s >= 0)
    {
	my $n = (($s[0] << 6 | $s[1]) << 6 | $s[2]) << 6 | $s[3];
	$r .=chr(($n >> 16) ^ 67) .
	     chr(($n >> 8 & 255) ^ 67) .
	     chr(($n & 255) ^ 67);
	@s = @s[4..$#s];
    }
    $r = substr($r,0,length($r)-$l);
    return $r;
}




sub getiteminformation {
# returns a hash of item information given either the itemnumber or the barcode
    my ($env, $itemnumber, $barcode) = @_;
    my $dbh = C4::Context->dbh;
    my $sth;
    if ($itemnumber) {
	$sth=$dbh->prepare("select * from biblio,items,biblioitems where items.itemnumber=$itemnumber and biblio.biblionumber=items.biblionumber and biblioitems.biblioitemnumber = items.biblioitemnumber");
    } elsif ($barcode) {
	my $q_barcode=$dbh->quote($barcode);
	$sth=$dbh->prepare("select * from biblio,items,biblioitems where items.barcode=$q_barcode and biblio.biblionumber=items.biblionumber and biblioitems.biblioitemnumber = items.biblioitemnumber");
    } else {
	$env->{'apierror'}="getiteminformation() subroutine must be called with either an itemnumber or a barcode";
	# Error condition.  
	return();
    }
    $sth->execute;
    my $iteminformation=$sth->fetchrow_hashref;
    $sth->finish;
    if ($iteminformation) {
	$sth=$dbh->prepare("select date_due from issues where itemnumber=$iteminformation->{'itemnumber'} and isnull(returndate)");
	$sth->execute;
	my ($date_due) = $sth->fetchrow;
	$iteminformation->{'date_due'}=$date_due;
	$sth->finish;
	#$iteminformation->{'dewey'}=~s/0*$//;
	($iteminformation->{'dewey'} == 0) && ($iteminformation->{'dewey'}='');
	$sth=$dbh->prepare("select * from itemtypes where itemtype='$iteminformation->{'itemtype'}'");
	$sth->execute;
	my $itemtype=$sth->fetchrow_hashref;
	$iteminformation->{'loanlength'}=$itemtype->{'loanlength'};
	$iteminformation->{'notforloan'}=$itemtype->{'notforloan'};
	$sth->finish;
    }
    return($iteminformation);
}

sub findborrower {
# returns an array of borrower hash references, given a cardnumber or a partial
# surname 
    my ($env, $key) = @_;
    my $dbh = C4::Context->dbh;
    my @borrowers;
    my $q_key=$dbh->quote($key);
    my $sth=$dbh->prepare("select * from borrowers where cardnumber=$q_key");
    $sth->execute;
    if ($sth->rows) {
	my ($borrower)=$sth->fetchrow_hashref;
	push (@borrowers, $borrower);
    } else {
	$q_key=$dbh->quote("$key%");
	$sth->finish;
	$sth=$dbh->prepare("select * from borrowers where surname like $q_key");
	$sth->execute;
	while (my $borrower = $sth->fetchrow_hashref) {
	    push (@borrowers, $borrower);
	}
    }
    $sth->finish;
    return(\@borrowers);
}


sub transferbook {
# transfer book code....
    my ($tbr, $barcode, $ignoreRs) = @_;
    my $messages;
    my %env;
    my $dotransfer = 1;
    my $branches = getbranches();
    my $iteminformation = getiteminformation(\%env, 0, $barcode);
# bad barcode..
    if (not $iteminformation) {
	$messages->{'BadBarcode'} = $barcode;
	$dotransfer = 0;
    }
# get branches of book...
    my $hbr = $iteminformation->{'homebranch'};
    my $fbr = $iteminformation->{'holdingbranch'};
# if is permanent...
    if ($branches->{$hbr}->{'PE'}) {
	$messages->{'IsPermanent'} = $hbr;
    }
# cant transfer book if is already there....
    if ($fbr eq $tbr) {
	$messages->{'DestinationEqualsHolding'} = 1;
	$dotransfer = 0;
    }
# check if it is still issued to someone, return it...
    my ($currentborrower) = currentborrower($iteminformation->{'itemnumber'});
    if ($currentborrower) {
	returnbook($barcode, $fbr);
	$messages->{'WasReturned'} = $currentborrower;
    }
# find reserves.....
    my ($resfound, $resrec) = CheckReserves($iteminformation->{'itemnumber'});
    if ($resfound and not $ignoreRs) {
	$resrec->{'ResFound'} = $resfound;
	$messages->{'ResFound'} = $resrec;
	$dotransfer = 0;
    }
#actually do the transfer....
    if ($dotransfer) {
	dotransfer($iteminformation->{'itemnumber'}, $fbr, $tbr);
	$messages->{'WasTransfered'} = 1;
    } 
    return ($dotransfer, $messages, $iteminformation);
}

sub dotransfer {
    my ($itm, $fbr, $tbr) = @_;
    my $dbh = C4::Context->dbh;
    $itm = $dbh->quote($itm);
    $fbr = $dbh->quote($fbr);
    $tbr = $dbh->quote($tbr);
    #new entry in branchtransfers....
    my $query = "insert into branchtransfers (itemnumber, frombranch, datearrived, tobranch) 
                                      values($itm, $fbr, now(), $tbr)";
    my $sth = $dbh->prepare($query);
    $sth->execute; 
    $sth->finish;
    #update holdingbranch in items .....
    # FIXME - Use $dbh->do()
    $query = "update items set datelastseen = now(), holdingbranch=$tbr where items.itemnumber=$itm";
    $sth = $dbh->prepare($query);
    $sth->execute; 
    $sth->finish;
    return;
}


sub issuebook {
    my ($env, $patroninformation, $barcode, $responses, $date) = @_;
    my $dbh = C4::Context->dbh;
    my $iteminformation = getiteminformation($env, 0, $barcode);
    my ($datedue);
    my ($rejected,$question,$defaultanswer,$questionnumber, $noissue);
    my $message;
    SWITCH: {
	if ($patroninformation->{'gonenoaddress'}) {
	    $rejected="Patron is gone, with no known address.";
	    last SWITCH;
	}
	if ($patroninformation->{'lost'}) {
	    $rejected="Patron's card has been reported lost.";
	    last SWITCH;
	}
	if ($patroninformation->{'debarred'}) {
	    $rejected="Patron is Debarred";
	    last SWITCH;
	}
	my $amount = checkaccount($env,$patroninformation->{'borrowernumber'}, $dbh,$date);
	if ($amount > 5 && $patroninformation->{'categorycode'} ne 'L' &&
                           $patroninformation->{'categorycode'} ne 'W' &&
                           $patroninformation->{'categorycode'} ne 'I' && 
                           $patroninformation->{'categorycode'} ne 'B' &&
                           $patroninformation->{'categorycode'} ne 'P') {
	    $rejected = sprintf "Patron owes \$%.02f.", $amount;
	    last SWITCH;
	}
	unless ($iteminformation) {
	    $rejected = "$barcode is not a valid barcode.";
	    last SWITCH;
	}
	if ($iteminformation->{'notforloan'} == 1) {
	    $rejected="Reference item: not for loan.";
	    last SWITCH;
	}
	if ($iteminformation->{'wthdrawn'} == 1) {
	    $rejected="Item withdrawn.";
	    last SWITCH;
	}
	if ($iteminformation->{'restricted'} == 1) {
	    $rejected="Restricted item.";
	    last SWITCH;
	}
	my ($currentborrower) = currentborrower($iteminformation->{'itemnumber'});
	if ($currentborrower eq $patroninformation->{'borrowernumber'}) {
# Already issued to current borrower
	    my ($renewstatus) = renewstatus($env,$dbh,$patroninformation->{'borrowernumber'}, $iteminformation->{'itemnumber'});
	    if ($renewstatus == 0) {
		$rejected="No more renewals allowed for this item.";
		last SWITCH;
	    } else {
		if ($responses->{4} eq '') {
		    $questionnumber = 4;
		    $question = "Book is issued to this borrower.\nRenew?";
		    $defaultanswer = 'Y';
		    last SWITCH;
		} elsif ($responses->{4} eq 'Y') {
		    my $charge = calc_charges($env, $dbh, $iteminformation->{'itemnumber'}, $patroninformation->{'borrowernumber'});
		    if ($charge > 0) {
			createcharge($env, $dbh, $iteminformation->{'itemnumber'}, $patroninformation->{'borrowernumber'}, $charge);
			$iteminformation->{'charge'} = $charge;
		    }
		    &UpdateStats($env,$env->{'branchcode'},'renew',$charge,'',$iteminformation->{'itemnumber'},$iteminformation->{'itemtype'});
		    renewbook($env,$dbh, $patroninformation->{'borrowernumber'}, $iteminformation->{'itemnumber'});
		    $noissue=1;
		} else {
		    $rejected=-1;
		    last SWITCH;
		}
	    }
	} elsif ($currentborrower ne '') {
	    my ($currborrower, $cbflags) = getpatroninformation($env,$currentborrower,0);
	    if ($responses->{1} eq '') {
		$questionnumber=1;
		$question = "Issued to $currborrower->{'firstname'} $currborrower->{'surname'} ($currborrower->{'cardnumber'}).\nMark as returned?";
		$defaultanswer='Y';
		last SWITCH;
	    } elsif ($responses->{1} eq 'Y') {
		returnbook($iteminformation->{'barcode'}, $env->{'branch'});
	    } else {
		$rejected=-1;
		last SWITCH;
	    }
	}

	my ($restype, $res) = CheckReserves($iteminformation->{'itemnumber'});
	if ($restype) {
	    my $resbor = $res->{'borrowernumber'};
	    if ($resbor eq $patroninformation->{'borrowernumber'}) {
		FillReserve($res);
	    } elsif ($restype eq "Waiting") {
		my ($resborrower, $flags)=getpatroninformation($env, $resbor,0);
		my $branches = getbranches();
		my $branchname = $branches->{$res->{'branchcode'}}->{'branchname'};
		if ($responses->{2} eq '') {
		    $questionnumber=2;
		    $question="<font color=red>Waiting</font> for $resborrower->{'firstname'} $resborrower->{'surname'} ($resborrower->{'cardnumber'}) at $branchname \nAllow issue?";
		    $defaultanswer='N';
		    last SWITCH;
		} elsif ($responses->{2} eq 'N') {
		    $rejected=-1;
		    last SWITCH;
		} else {
		    if ($responses->{3} eq '') {
			$questionnumber=3;
			$question="Cancel reserve for $resborrower->{'firstname'} $resborrower->{'surname'} ($resborrower->{'cardnumber'})?";
			$defaultanswer='N';
			last SWITCH;
		    } elsif ($responses->{3} eq 'Y') {
			CancelReserve(0, $res->{'itemnumber'}, $res->{'borrowernumber'});
		    }
		}
	    } elsif ($restype eq "Reserved") {
		my ($resborrower, $flags)=getpatroninformation($env, $resbor,0);
		my $branches = getbranches();
		my $branchname = $branches->{$res->{'branchcode'}}->{'branchname'};
		if ($responses->{5} eq '') {
		    $questionnumber=5;
		    $question="Reserved for $resborrower->{'firstname'} $resborrower->{'surname'} ($resborrower->{'cardnumber'}) since $res->{'reservedate'} \nAllow issue?";
		    $defaultanswer='N';
		    last SWITCH;
		} elsif ($responses->{5} eq 'N') {
		    if ($responses->{6} eq '') {
			$questionnumber=6;
			$question="Set reserve for $resborrower->{'firstname'} $resborrower->{'surname'} ($resborrower->{'cardnumber'}) to waiting and transfer to $branchname?";
			$defaultanswer='N';
		    } elsif ($responses->{6} eq 'Y') {
			my $tobrcd = ReserveWaiting($res->{'itemnumber'}, $res->{'borrowernumber'});
			transferbook($tobrcd, $barcode, 1);
			$message = "Item should now be waiting at $branchname";
		    }
		    $rejected=-1;
		    last SWITCH;
		} else {
		    if ($responses->{7} eq '') {
			$questionnumber=7;
			$question="Cancel reserve for $resborrower->{'firstname'} $resborrower->{'surname'} ($resborrower->{'cardnumber'})?";
			$defaultanswer='N';
			last SWITCH;
		    } elsif ($responses->{7} eq 'Y') {
			CancelReserve(0, $res->{'itemnumber'}, $res->{'borrowernumber'});
		    }
		}
	    }
	}
    }
    my $dateduef;
    unless (($question) || ($rejected) || ($noissue)) {
	my $loanlength=21;
	if ($iteminformation->{'loanlength'}) {
	    $loanlength=$iteminformation->{'loanlength'};
	}
	my $ti=time;
	my $datedue=time+($loanlength)*86400;
	my @datearr = localtime($datedue);
	$dateduef = (1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
	if ($env->{'datedue'}) {
	    $dateduef=$env->{'datedue'};
	}
	$dateduef=~ s/2001\-4\-25/2001\-4\-26/;
	my $sth=$dbh->prepare("insert into issues (borrowernumber, itemnumber, date_due, branchcode) values ($patroninformation->{'borrowernumber'}, $iteminformation->{'itemnumber'}, '$dateduef', '$env->{'branchcode'}')");
	$sth->execute;
	$sth->finish;
	$iteminformation->{'issues'}++;
	$sth=$dbh->prepare("update items set issues=$iteminformation->{'issues'},datelastseen=now() where itemnumber=$iteminformation->{'itemnumber'}");
	$sth->execute;
	$sth->finish;
	my $charge=calc_charges($env, $dbh, $iteminformation->{'itemnumber'}, $patroninformation->{'borrowernumber'});
	if ($charge > 0) {
	    createcharge($env, $dbh, $iteminformation->{'itemnumber'}, $patroninformation->{'borrowernumber'}, $charge);
	    $iteminformation->{'charge'}=$charge;
	}
	&UpdateStats($env,$env->{'branchcode'},'issue',$charge,'',$iteminformation->{'itemnumber'},$iteminformation->{'itemtype'});
    }
    if ($iteminformation->{'charge'}) {
	$message=sprintf "Rental charge of \$%.02f applies.", $iteminformation->{'charge'};
    }
    return ($iteminformation, $dateduef, $rejected, $question, $questionnumber, $defaultanswer, $message);
}



sub returnbook {
    my ($barcode, $branch) = @_;
    my %env;
    my $messages;
    my $doreturn = 1;
# get information on item
    my ($iteminformation) = getiteminformation(\%env, 0, $barcode);
    if (not $iteminformation) {
	$messages->{'BadBarcode'} = $barcode;
	$doreturn = 0;
    }
# find the borrower
    my ($currentborrower) = currentborrower($iteminformation->{'itemnumber'});
    if ((not $currentborrower) && $doreturn) {
	$messages->{'NotIssued'} = $barcode;
	$doreturn = 0;
    }
# check if the book is in a permanent collection....
    my $hbr = $iteminformation->{'homebranch'};
    my $branches = getbranches();
    if ($branches->{$hbr}->{'PE'}) {
	$messages->{'IsPermanent'} = $hbr;
    }
# check that the book has been cancelled
    if ($iteminformation->{'wthdrawn'}) {
	$messages->{'wthdrawn'} = 1;
	$doreturn = 0;
    }
# update issues, thereby returning book (should push this out into another subroutine
    my ($borrower) = getpatroninformation(\%env, $currentborrower, 0);
    if ($doreturn) {	# FIXME - perl -wc complains about this line.
	doreturn($borrower->{'borrowernumber'}, $iteminformation->{'itemnumber'});
	$messages->{'WasReturned'};
    }
    ($borrower) = getpatroninformation(\%env, $currentborrower, 0);
# transfer book
    my ($transfered, $mess, $item) = transferbook($branch, $barcode, 1);
    if ($transfered) {	# FIXME - perl -wc complains about this line.
	$messages->{'WasTransfered'};
    }
# fix up the accounts.....
    if ($iteminformation->{'itemlost'}) {	# FIXME - perl -wc complains about this line.
	updateitemlost($iteminformation->{'itemnumber'});
	fixaccountforlostandreturned($iteminformation, $borrower);
	$messages->{'WasLost'};
    }
# fix up the overdues in accounts...
    fixoverduesonreturn($borrower->{'borrowernumber'}, $iteminformation->{'itemnumber'});
# find reserves.....
    my ($resfound, $resrec) = CheckReserves($iteminformation->{'itemnumber'});
    if ($resfound) {
	$resrec->{'ResFound'} = $resfound;
	$messages->{'ResFound'} = $resrec;
    }
# update stats?
    UpdateStats(\%env, $branch ,'return','0','',$iteminformation->{'itemnumber'});
    return ($doreturn, $messages, $iteminformation, $borrower);
}


sub doreturn {
    my ($brn, $itm) = @_;
    my $dbh = C4::Context->dbh;
    $brn = $dbh->quote($brn);
    $itm = $dbh->quote($itm);
    my $query = "update issues set returndate = now() where (borrowernumber = $brn) 
        and (itemnumber = $itm) and (returndate is null)";
    my $sth = $dbh->prepare($query);
    $sth->execute;
    $sth->finish;
    $query="update items set datelastseen=now() where itemnumber=$itm";
    $sth=$dbh->prepare($query);
    $sth->execute;
    $sth->finish;
    return;
}

sub updateitemlost{
  my ($itemno)=@_;
  my $dbh = C4::Context->dbh;
  # FIXME - Use $dbh->do();
  my $query="update items set itemlost=0 where itemnumber=$itemno";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
}

sub fixaccountforlostandreturned {
    my ($iteminfo, $borrower) = @_;
    my %env;
    my $dbh = C4::Context->dbh;
    my $itm = $dbh->quote($iteminfo->{'itemnumber'});
# check for charge made for lost book
    my $query = "select * from accountlines where (itemnumber = $itm) 
                          and (accounttype='L' or accounttype='Rep') order by date desc";
    my $sth = $dbh->prepare($query);
    $sth->execute;
    if (my $data = $sth->fetchrow_hashref) {
# writeoff this amount 
	my $offset;
	my $amount = $data->{'amount'};
	my $acctno = $data->{'accountno'};
	my $amountleft;
	if ($data->{'amountoutstanding'} == $amount) {
	    $offset = $data->{'amount'};
	    $amountleft = 0;
	} else {
	    $offset = $amount - $data->{'amountoutstanding'};
	    $amountleft = $data->{'amountoutstanding'} - $amount;
	}
	my $uquery = "update accountlines set accounttype = 'LR',amountoutstanding='0'
		  where (borrowernumber = '$data->{'borrowernumber'}')
		  and (itemnumber = $itm) and (accountno = '$acctno') ";
	my $usth = $dbh->prepare($uquery);
	$usth->execute;
	$usth->finish;
#check if any credit is left if so writeoff other accounts
	my $nextaccntno = getnextacctno(\%env,$data->{'borrowernumber'},$dbh);
	if ($amountleft < 0){
	    $amountleft*=-1;
	}
	if ($amountleft > 0){
	    my $query = "select * from accountlines where (borrowernumber = '$data->{'borrowernumber'}') 
                                                      and (amountoutstanding >0) order by date";
	    my $msth = $dbh->prepare($query);
	    $msth->execute;
      # offset transactions
	    my $newamtos;
	    my $accdata;
	    while (($accdata=$msth->fetchrow_hashref) and ($amountleft>0)){
		if ($accdata->{'amountoutstanding'} < $amountleft) {
		    $newamtos = 0;
		    $amountleft = $amountleft - $accdata->{'amountoutstanding'};
		}  else {
		    $newamtos = $accdata->{'amountoutstanding'} - $amountleft;
		    $amountleft = 0;
		}
		my $thisacct = $accdata->{'accountno'};
		my $updquery = "update accountlines set amountoutstanding= '$newamtos'
		                 where (borrowernumber = '$data->{'borrowernumber'}') 
                                   and (accountno='$thisacct')";
		my $usth = $dbh->prepare($updquery);
		$usth->execute;
		$usth->finish;
		$updquery = "insert into accountoffsets 
		          (borrowernumber, accountno, offsetaccount,  offsetamount)
		          values
		          ('$data->{'borrowernumber'}','$accdata->{'accountno'}','$nextaccntno','$newamtos')";
		$usth = $dbh->prepare($updquery);
		$usth->execute;
		$usth->finish;
	    }
	    $msth->finish;
	}
	if ($amountleft > 0){
	    $amountleft*=-1;
	}
	my $desc="Book Returned ".$iteminfo->{'barcode'};
	$uquery = "insert into accountlines
		  (borrowernumber,accountno,date,amount,description,accounttype,amountoutstanding)
		  values ('$data->{'borrowernumber'}','$nextaccntno',now(),0-$amount,'$desc',
		  'CR',$amountleft)";
	$usth = $dbh->prepare($uquery);
	$usth->execute;	    
	$usth->finish;
	$uquery = "insert into accountoffsets
		  (borrowernumber, accountno, offsetaccount,  offsetamount)
		  values ($borrower->{'borrowernumber'},$data->{'accountno'},$nextaccntno,$offset)";
	$usth = $dbh->prepare($uquery);
	$usth->execute;
	$usth->finish;
	$uquery = "update items set paidfor='' where itemnumber=$itm";
	$usth = $dbh->prepare($uquery);
	$usth->execute;
	$usth->finish;
    }
    $sth->finish;
    return;
}

sub fixoverduesonreturn {
    my ($brn, $itm) = @_;
    my $dbh = C4::Context->dbh;
    $itm = $dbh->quote($itm);
    $brn = $dbh->quote($brn);
# check for overdue fine
    my $query = "select * from accountlines where (borrowernumber=$brn) 
                           and (itemnumber = $itm) and (accounttype='FU' or accounttype='O')";
    my $sth = $dbh->prepare($query);
    $sth->execute;
# alter fine to show that the book has been returned
    if (my $data = $sth->fetchrow_hashref) {
	my $query = "update accountlines set accounttype='F' where (borrowernumber = $brn) 
                           and (itemnumber = $itm) and (acccountno='$data->{'accountno'}')";
	my $usth=$dbh->prepare($query);
	$usth->execute();
	$usth->finish();
    }
    $sth->finish;
    return;
}

sub patronflags {
# Original subroutine for Circ2.pm
    my %flags;
    my ($env, $patroninformation, $dbh) = @_;
    my $amount = checkaccount($env, $patroninformation->{'borrowernumber'}, $dbh);
    if ($amount > 0) { 
	my %flaginfo;
	$flaginfo{'message'}= sprintf "Patron owes \$%.02f", $amount; 
	if ($amount > 5) {
	    $flaginfo{'noissues'} = 1;
	}
	$flags{'CHARGES'} = \%flaginfo;
    } elsif ($amount < 0){
       my %flaginfo;
       $amount = $amount*-1;
       $flaginfo{'message'} = sprintf "Patron has credit of \$%.02f", $amount;
       	$flags{'CHARGES'} = \%flaginfo;
    }
    if ($patroninformation->{'gonenoaddress'} == 1) {
	my %flaginfo;
	$flaginfo{'message'} = 'Borrower has no valid address.'; 
	$flaginfo{'noissues'} = 1;
	$flags{'GNA'} = \%flaginfo;
    }
    if ($patroninformation->{'lost'} == 1) {
	my %flaginfo;
	$flaginfo{'message'} = 'Borrower\'s card reported lost.'; 
	$flaginfo{'noissues'} = 1;
	$flags{'LOST'} = \%flaginfo;
    }
    if ($patroninformation->{'debarred'} == 1) {
	my %flaginfo;
	$flaginfo{'message'} = 'Borrower is Debarred.'; 
	$flaginfo{'noissues'} = 1;
	$flags{'DBARRED'} = \%flaginfo;
    }
    if ($patroninformation->{'borrowernotes'}) {
	my %flaginfo;
	$flaginfo{'message'} = "$patroninformation->{'borrowernotes'}";
	$flags{'NOTES'} = \%flaginfo;
    }
    my ($odues, $itemsoverdue) 
                  = checkoverdues($env, $patroninformation->{'borrowernumber'}, $dbh);
    if ($odues > 0) {
	my %flaginfo;
	$flaginfo{'message'} = "Yes";
	$flaginfo{'itemlist'} = $itemsoverdue;
	foreach (sort {$a->{'date_due'} cmp $b->{'date_due'}} @$itemsoverdue) {
	    $flaginfo{'itemlisttext'}.="$_->{'date_due'} $_->{'barcode'} $_->{'title'} \n";
	}
	$flags{'ODUES'} = \%flaginfo;
    }
    my ($nowaiting, $itemswaiting) 
                  = CheckWaiting($patroninformation->{'borrowernumber'});
    if ($nowaiting > 0) {
	my %flaginfo;
	$flaginfo{'message'} = "Reserved items available";
	$flaginfo{'itemlist'} = $itemswaiting;
	$flags{'WAITING'} = \%flaginfo;
    }
    return(\%flags);
}


sub checkoverdues {
# From Main.pm, modified to return a list of overdueitems, in addition to a count
  #checks whether a borrower has overdue items
  my ($env, $bornum, $dbh)=@_;
  my @datearr = localtime;
  my $today = ($datearr[5] + 1900)."-".($datearr[4]+1)."-".$datearr[3];
  my @overdueitems;
  my $count = 0;
  my $query = "SELECT * FROM issues,biblio,biblioitems,items 
                       WHERE items.biblioitemnumber = biblioitems.biblioitemnumber 
                         AND items.biblionumber     = biblio.biblionumber 
                         AND issues.itemnumber      = items.itemnumber 
                         AND issues.borrowernumber  = $bornum 
                         AND issues.returndate is NULL 
                         AND issues.date_due < '$today'";
  my $sth = $dbh->prepare($query);
  $sth->execute;
  while (my $data = $sth->fetchrow_hashref) {
      push (@overdueitems, $data);
      $count++;
  }
  $sth->finish;
  return ($count, \@overdueitems);
}

sub currentborrower {
# Original subroutine for Circ2.pm
    my ($itemnumber) = @_;
    my $dbh = C4::Context->dbh;
    my $q_itemnumber = $dbh->quote($itemnumber);
    my $sth=$dbh->prepare("select borrowers.borrowernumber from
    issues,borrowers where issues.itemnumber=$q_itemnumber and
    issues.borrowernumber=borrowers.borrowernumber and issues.returndate is
    NULL");
    $sth->execute;
    my ($borrower) = $sth->fetchrow;
    return($borrower);
}

sub checkreserve {
# Stolen from Main.pm
  # Check for reserves for biblio 
  my ($env,$dbh,$itemnum)=@_;
  my $resbor = "";
  my $query = "select * from reserves,items 
    where (items.itemnumber = '$itemnum')
    and (reserves.cancellationdate is NULL)
    and (items.biblionumber = reserves.biblionumber)
    and ((reserves.found = 'W')
    or (reserves.found is null)) 
    order by priority";
  my $sth = $dbh->prepare($query);
  $sth->execute();
  my $resrec;
  my $data=$sth->fetchrow_hashref;
  while ($data && $resbor eq '') {
    $resrec=$data;
    my $const = $data->{'constrainttype'};
    if ($const eq "a") {
      $resbor = $data->{'borrowernumber'};
    } else {
      my $found = 0;
      my $cquery = "select * from reserveconstraints,items 
         where (borrowernumber='$data->{'borrowernumber'}') 
         and reservedate='$data->{'reservedate'}'
         and reserveconstraints.biblionumber='$data->{'biblionumber'}'
         and (items.itemnumber=$itemnum and 
         items.biblioitemnumber = reserveconstraints.biblioitemnumber)";
      my $csth = $dbh->prepare($cquery);
      $csth->execute;
      if (my $cdata=$csth->fetchrow_hashref) {$found = 1;}
      if ($const eq 'o') {
        if ($found eq 1) {$resbor = $data->{'borrowernumber'};}
      } else {
        if ($found eq 0) {$resbor = $data->{'borrowernumber'};}
      }
      $csth->finish();
    }
    $data=$sth->fetchrow_hashref;
  }
  $sth->finish;
  return ($resbor,$resrec);
}

sub currentissues {
# New subroutine for Circ2.pm
    my ($env, $borrower) = @_;
    my $dbh = C4::Context->dbh;
    my %currentissues;
    my $counter=1;
    my $borrowernumber = $borrower->{'borrowernumber'};
    my $crit='';
    if ($env->{'todaysissues'}) {
	my @datearr = localtime(time());
	my $today = (1900+$datearr[5]).sprintf "%02d", ($datearr[4]+1).sprintf "%02d", $datearr[3];
	$crit=" and issues.timestamp like '$today%' ";
    }
    if ($env->{'nottodaysissues'}) {
	my @datearr = localtime(time());
	my $today = (1900+$datearr[5]).sprintf "%02d", ($datearr[4]+1).sprintf "%02d", $datearr[3];
	$crit=" and !(issues.timestamp like '$today%') ";
    }
    my $select="select * from issues,items,biblioitems,biblio where
       borrowernumber='$borrowernumber' and issues.itemnumber=items.itemnumber and
       items.biblionumber=biblio.biblionumber and
       items.biblioitemnumber=biblioitems.biblioitemnumber and returndate is null
       $crit order by issues.date_due";
#    warn $select;
    my $sth=$dbh->prepare($select);
    $sth->execute;
    while (my $data = $sth->fetchrow_hashref) {
	$data->{'dewey'}=~s/0*$//;
	($data->{'dewey'} == 0) && ($data->{'dewey'}='');
	my @datearr = localtime(time());
	my $todaysdate = (1900+$datearr[5]).sprintf ("%0.2d", ($datearr[4]
	+1)).sprintf ("%0.2d", $datearr[3]);
	my $datedue=$data->{'date_due'};
	$datedue=~s/-//g;
	if ($datedue < $todaysdate) {
	    $data->{'overdue'}=1;
	}
	my $itemnumber=$data->{'itemnumber'};
	$currentissues{$counter}=$data;
	$counter++;
    }
    $sth->finish;
    return(\%currentissues);
}

sub getissues {
# New subroutine for Circ2.pm
    my ($borrower) = @_;
    my $dbh = C4::Context->dbh;
    my $borrowernumber = $borrower->{'borrowernumber'};
    my $brn =$dbh->quote($borrowernumber);
    my %currentissues;
    my $select = "select issues.timestamp, issues.date_due, items.biblionumber,
                         items.barcode, biblio.title, biblio.author, biblioitems.dewey, 
                         biblioitems.subclass 
                    from issues,items,biblioitems,biblio
                   where issues.borrowernumber = $brn 
                     and issues.itemnumber = items.itemnumber 
                     and items.biblionumber = biblio.biblionumber 
                     and items.biblioitemnumber = biblioitems.biblioitemnumber 
                     and issues.returndate is null
                         order by issues.date_due";
#    warn $select;
    my $sth=$dbh->prepare($select);
    $sth->execute;
    my $counter = 0;
    while (my $data = $sth->fetchrow_hashref) {
	$data->{'dewey'} =~ s/0*$//;
	($data->{'dewey'} == 0) && ($data->{'dewey'} = '');
	my @datearr = localtime(time());
	my $todaysdate = (1900+$datearr[5]).sprintf ("%0.2d", ($datearr[4]+1)).sprintf ("%0.2d", $datearr[3]);
	my $datedue = $data->{'date_due'};
	$datedue =~ s/-//g;
	if ($datedue < $todaysdate) {
	    $data->{'overdue'} = 1;
	}
	$currentissues{$counter} = $data;
	$counter++;
    }
    $sth->finish;
    return(\%currentissues);
}

sub checkwaiting {
#Stolen from Main.pm
  # check for reserves waiting
  my ($env,$dbh,$bornum)=@_;
  my @itemswaiting;
  my $query = "select * from reserves
    where (borrowernumber = '$bornum')
    and (reserves.found='W') and cancellationdate is NULL";
  my $sth = $dbh->prepare($query);
  $sth->execute();
  my $cnt=0;
  if (my $data=$sth->fetchrow_hashref) {
    $itemswaiting[$cnt] =$data;
    $cnt ++
  }
  $sth->finish;
  return ($cnt,\@itemswaiting);
}

# FIXME - This is nearly-identical to &C4::Accounts::checkaccount
sub checkaccount  {
# Stolen from Accounts.pm
  #take borrower number
  #check accounts and list amounts owing
  my ($env,$bornumber,$dbh,$date)=@_;
  my $select="Select sum(amountoutstanding) from accountlines where
  borrowernumber=$bornumber and amountoutstanding<>0";
  if ($date ne ''){
    $select.=" and date < '$date'";
  }
#  print $select;
  my $sth=$dbh->prepare($select);
  $sth->execute;
  my $total=0;
  while (my $data=$sth->fetchrow_hashref){
    $total=$total+$data->{'sum(amountoutstanding)'};
  }
  $sth->finish;
  # output(1,2,"borrower owes $total");
  #if ($total > 0){
  #  # output(1,2,"borrower owes $total");
  #  if ($total > 5){
  #    reconcileaccount($env,$dbh,$bornumber,$total);
  #  }
  #}
  #  pause();
  return($total);
}    

sub renewstatus {
# Stolen from Renewals.pm
  # check renewal status
  my ($env,$dbh,$bornum,$itemno)=@_;
  my $renews = 1;
  my $renewokay = 0;
  my $q1 = "select * from issues 
    where (borrowernumber = '$bornum')
    and (itemnumber = '$itemno') 
    and returndate is null";
  my $sth1 = $dbh->prepare($q1);
  $sth1->execute;
  if (my $data1 = $sth1->fetchrow_hashref) {
    my $q2 = "select renewalsallowed from items,biblioitems,itemtypes
       where (items.itemnumber = '$itemno')
       and (items.biblioitemnumber = biblioitems.biblioitemnumber) 
       and (biblioitems.itemtype = itemtypes.itemtype)";
    my $sth2 = $dbh->prepare($q2);
    $sth2->execute;     
    if (my $data2=$sth2->fetchrow_hashref) {
      $renews = $data2->{'renewalsallowed'};
    }
    if ($renews > $data1->{'renewals'}) {
      $renewokay = 1;
    }
    $sth2->finish;
  }   
  $sth1->finish;
  return($renewokay);    
}

sub renewbook {
# Stolen from Renewals.pm
  # mark book as renewed
  my ($env,$dbh,$bornum,$itemno,$datedue)=@_;
  $datedue=$env->{'datedue'};
  if ($datedue eq "" ) {    
    my $loanlength=21;
    my $query= "Select * from biblioitems,items,itemtypes
       where (items.itemnumber = '$itemno')
       and (biblioitems.biblioitemnumber = items.biblioitemnumber)
       and (biblioitems.itemtype = itemtypes.itemtype)";
    my $sth=$dbh->prepare($query);
    $sth->execute;
    if (my $data=$sth->fetchrow_hashref) {
      $loanlength = $data->{'loanlength'}
    }
    $sth->finish;
    my $ti = time;
    my $datedu = time + ($loanlength * 86400);
    my @datearr = localtime($datedu);
    $datedue = (1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
  }
  my @date = split("-",$datedue);
  my $odatedue = ($date[2]+0)."-".($date[1]+0)."-".$date[0];
  my $issquery = "select * from issues where borrowernumber='$bornum' and
    itemnumber='$itemno' and returndate is null";
  my $sth=$dbh->prepare($issquery);
  $sth->execute;
  my $issuedata=$sth->fetchrow_hashref;
  $sth->finish;
  my $renews = $issuedata->{'renewals'} +1;
  my $updquery = "update issues 
    set date_due = '$datedue', renewals = '$renews'
    where borrowernumber='$bornum' and
    itemnumber='$itemno' and returndate is null";
  $sth=$dbh->prepare($updquery);
  
  $sth->execute;
  $sth->finish;
  return($odatedue);
}

# FIXME - This is almost, but not quite, identical to
# &C4::Circulation::Issues::calc_charges and
# &C4::Circulation::Renewals2::calc_charges.
# Pick one and stick with it.
sub calc_charges {
# Stolen from Issues.pm
# calculate charges due
    my ($env, $dbh, $itemno, $bornum)=@_;
#    if (!$dbh){
#      $dbh=C4Connect();
#    }
    my $charge=0;
#    open (FILE,">>/tmp/charges");
    my $item_type;
    my $q1 = "select itemtypes.itemtype,rentalcharge from items,biblioitems,itemtypes 
    where (items.itemnumber ='$itemno')
    and (biblioitems.biblioitemnumber = items.biblioitemnumber) 
    and (biblioitems.itemtype = itemtypes.itemtype)";
    my $sth1= $dbh->prepare($q1);
#    print FILE "$q1\n";
    $sth1->execute;
    if (my $data1=$sth1->fetchrow_hashref) {
	$item_type = $data1->{'itemtype'};
	$charge = $data1->{'rentalcharge'};
#	print FILE "charge is $charge\n";
	my $q2 = "select rentaldiscount from borrowers,categoryitem 
	where (borrowers.borrowernumber = '$bornum') 
	and (borrowers.categorycode = categoryitem.categorycode)
	and (categoryitem.itemtype = '$item_type')";
	my $sth2=$dbh->prepare($q2);
#	warn $q2;
	$sth2->execute;
	if (my $data2=$sth2->fetchrow_hashref) {
	    my $discount = $data2->{'rentaldiscount'};
#	    print FILE "discount is $discount";
	    if ($discount eq 'NULL') {
	      $discount=0;
	    }
	    $charge = ($charge *(100 - $discount)) / 100;
	}
	$sth2->finish;
    }      
    $sth1->finish;
#    close FILE;
    return ($charge);
}

sub createcharge {
#Stolen from Issues.pm
    my ($env,$dbh,$itemno,$bornum,$charge) = @_;
    my $nextaccntno = getnextacctno($env,$bornum,$dbh);
    my $query = "insert into accountlines (borrowernumber,itemnumber,accountno,date,amount, description,accounttype,amountoutstanding) values ($bornum,$itemno,$nextaccntno,now(),$charge,'Rental','Rent',$charge)";
    my $sth = $dbh->prepare($query);
    $sth->execute;
    $sth->finish;
}


sub getnextacctno {
# Stolen from Accounts.pm
    my ($env,$bornumber,$dbh)=@_;
    my $nextaccntno = 1;
    my $query = "select * from accountlines where (borrowernumber = '$bornumber') order by accountno desc";
    my $sth = $dbh->prepare($query);
    $sth->execute;
    if (my $accdata=$sth->fetchrow_hashref){
	$nextaccntno = $accdata->{'accountno'} + 1;
    }
    $sth->finish;
    return($nextaccntno);
}

sub find_reserves {
# Stolen from Returns.pm
    my ($itemno) = @_;
    my %env;
    my $dbh = C4::Context->dbh;
    my ($itemdata) = getiteminformation(\%env, $itemno,0);
    my $bibno = $dbh->quote($itemdata->{'biblionumber'});
    my $bibitm = $dbh->quote($itemdata->{'biblioitemnumber'});
    my $query = "select * from reserves where ((found = 'W') or (found is null)) 
                       and biblionumber = $bibno and cancellationdate is NULL
                       order by priority, reservedate ";
    my $sth = $dbh->prepare($query);
    $sth->execute;
    my $resfound = 0;
    my $resrec;
    my $lastrec;
# print $query;
    while (($resrec = $sth->fetchrow_hashref) && (not $resfound)) {
	$lastrec = $resrec;
	my $brn = $dbh->quote($resrec->{'borrowernumber'});
	my $rdate = $dbh->quote($resrec->{'reservedate'});
	my $bibno = $dbh->quote($resrec->{'biblionumber'});
	if ($resrec->{'found'} eq "W") {
	    if ($resrec->{'itemnumber'} eq $itemno) {
		$resfound = 1;
	    }
        } else {
	    if ($resrec->{'constrainttype'} eq "a") {
		$resfound = 1;
	    } else {
                my $conquery = "select * from reserveconstraints where borrowernumber = $brn 
                     and reservedate = $rdate and biblionumber = $bibno and biblioitemnumber = $bibitm";
		my $consth = $dbh->prepare($conquery);
		$consth->execute;
		if (my $conrec = $consth->fetchrow_hashref) {
		    if ($resrec->{'constrainttype'} eq "o") {
			$resfound = 1;
		    }
		}
		$consth->finish;
	    }
	}
	if ($resfound) {
            my $updquery = "update reserves set found = 'W', itemnumber = '$itemno'
                  where borrowernumber = $brn and reservedate = $rdate and biblionumber = $bibno";
	    my $updsth = $dbh->prepare($updquery);
	    $updsth->execute;
	    $updsth->finish;
	}
    }
    $sth->finish;
    return ($resfound,$lastrec);
}

END { }       # module clean-up code here (global destructor)
