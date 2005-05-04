#!/usr/bin/perl 
#-----------------------------------
# Script Name: reservelist.pl
# Script Version: 1.0
# Date:  2003/9/18
# Author:  Stephen Hedges  shedges@skemotah.com
# Description: produces a comma separated list of currently
#    available reserves, with item and borrower details
# Usage: reservelist.pl.
# Revision History:
#    1.0  2003/9/18:  original version
#    1.1  2003/10/1:  modified to load into a MySQL table
#-----------------------------------

use lib '/usr/local/koha/intranet/modules/';

use strict;
use C4::Context;
use C4::Search;

my ($biblionumber,$barcode,$holdingbranch,$pickbranch,$notes,$cardnumber,$lastname,$firstname,$phone,$title,$callno,$rdate,$borrno);

my $dbh   = C4::Context->dbh;

$dbh->do("DELETE FROM reservelist");  # clear the old table for new info

my $sth=$dbh->prepare("SELECT biblionumber,reserves.branchcode,reservenotes,borrowers.borrowernumber,cardnumber,surname,firstname,phone,reservedate FROM reserves,borrowers WHERE reserves.borrowernumber=borrowers.borrowernumber AND priority=1 AND cancellationdate IS NULL GROUP BY biblionumber");

my $sth_load=$dbh->prepare("INSERT INTO reservelist (biblionumber,barcode,lastname,firstname,phone,borrowernumber,cardnumber,reservedate,title,callno,holdingbranch,pickbranch,notes) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)");

$sth->execute();      # get the list of biblionumbers for unfilled reserves

GETIT: while (my $data=$sth->fetchrow_hashref){
    $biblionumber = $data->{'biblionumber'};   # get the basic reserve info
    $pickbranch = $data->{'branchcode'};
    $notes = $data->{'reservenotes'};
    $borrno = $data->{'borrowernumber'};
    $cardnumber = $data->{'cardnumber'};
    $lastname = $data->{'surname'};
    $firstname = $data->{'firstname'};
    $phone = $data->{'phone'};
    $rdate = $data->{'reservedate'};
    my @items = ItemInfo(undef,$biblionumber,''); # get the items for this biblio
    my @itemorder;   #  prepare a new array to hold re-ordered items

# The following lines take the retrieved items and run them through various
# tests to decide if they are to be used and then put them in the preferred
# 'pick' order.
    foreach my $itm (@items) {
	if ($itm->{"datedue"} eq "Reserved") {   # is item ready for member?
	    if ($itm->{'holdingbranch'} eq $pickbranch) {
		$itemorder[0]=$itm;
	    } elsif ($itm->{'homebranch'} eq 'NPL') {
		$itemorder[1]=$itm;
	    } elsif ($itm->{'homebranch'} eq 'CPL') {
		$itemorder[2]=$itm;
	    } elsif ($itm->{'homebranch'} eq 'COV') {
		$itemorder[3]=$itm;
	    } elsif ($itm->{'homebranch'} eq 'GPL') {
		$itemorder[4]=$itm;
	    } elsif ($itm->{'homebranch'} eq 'ALB') {
		$itemorder[5]=$itm;
	    } elsif ($itm->{'homebranch'} eq 'PPL') {
		$itemorder[6]=$itm;
	    } elsif ($itm->{'homebranch'} eq 'APL') {
		$itemorder[7]=$itm;
	    }
	}
    }
    my $count = @itemorder;
    next GETIT if $count<1;  # if the re-ordered array is empty, skip to next
    PREP: foreach my $itmlist (@itemorder) {
	if ($itmlist) {
	    $barcode = $itmlist->{'barcode'};
	    $holdingbranch = $itmlist->{'holdingbranch'};
	    $title = $itmlist->{'title'};
	    $callno = $itmlist->{'classification'};
	    last PREP;    # we only want the first def item in the array
	}
    }
    $sth_load->execute($biblionumber,$barcode,$lastname,$firstname,$phone,$borrno,$cardnumber,$rdate,$title,$callno,$holdingbranch,$pickbranch,$notes);
    $sth_load->finish;
}
$sth->finish;
$dbh->disconnect;
