package C4::Bull; #assumes C4/Bull.pm


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
require Exporter;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.01;

=head1 NAME

C4::Bull - Give functions for serializing.

=head1 SYNOPSIS

  use C4::Bull;

=head1 DESCRIPTION

Give all XYZ functions

=cut

@ISA = qw(Exporter);
@EXPORT = qw(&newsubscription &modsubscription &getsubscriptions &getsubscription
	&modsubscriptionhistory
			&getserials &serialchangestatus
			&Initialize_Sequence &Find_Next_Date, &Get_Next_Seq);

sub newsubscription {
	my ($auser,$aqbooksellerid,$cost,$aqbudgetid,$biblionumber,$startdate,$periodicity,$dow,$numberlength,$weeklength,$monthlength,$seqnum1,$seqnum1,$seqtype1,$freq1, $step1,$seqnum2,$seqnum2,$seqtype2,$freq2, $step2,$seqnum3,$seqnum3,$seqtype3,$freq3, $step3, $numberingmethod, $arrivalplanified, $status, $notes) = @_;
	my $dbh = C4::Context->dbh;
	#save subscription
	my $sth=$dbh->prepare("insert into subscription (librarian, aqbooksellerid,cost,aqbudgetid,biblionumber,startdate, periodicity,dow,numberlength,weeklength,monthlength,seqnum1,startseqnum1,seqtype1,freq1,step1,seqnum2,startseqnum2,seqtype2,freq2, step2, seqnum3,startseqnum3,seqtype3, freq3, step3,numberingmethod, arrivalplanified, status, notes, pos1, pos2, pos3) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?, 0, 0, 0)");
	$sth->execute($auser,$aqbooksellerid,$cost,$aqbudgetid,$biblionumber,$startdate,$periodicity,$dow,$numberlength,$weeklength,$monthlength,$seqnum1,$seqnum1,$seqtype1,$freq1, $step1,$seqnum2,$seqnum2,$seqtype2,$freq2, $step2,$seqnum3,$seqnum3,$seqtype3,$freq3, $step3, $numberingmethod, $arrivalplanified, $status, $notes);
	#then create the 1st waited number
	my $subscriptionid = $dbh->{'mysql_insertid'};
	$sth = $dbh->prepare("insert into subscriptionhistory (biblionumber, subscriptionid, startdate, enddate, missinglist, recievedlist, opacnote, librariannote) values (?,?,?,?,?,?,?,?)");
	$sth->execute($biblionumber, $subscriptionid, $startdate, 0, "", "", 0, $notes);
	$sth = $dbh->prepare("insert into serial (biblionumber, subscriptionid, serialseq, status, planneddate) values (?,?,?,?,?)");
	$sth->execute($biblionumber, $subscriptionid, Initialize_Sequence($numberingmethod, $seqnum1, $seqtype1, $freq1, $step1, $seqnum2, $seqtype2, $freq2, $step2, $seqnum3, $seqtype3, $freq3, $step3), $status, C4::Bull::Find_Next_Date());
	$sth->finish;  

}
sub getsubscription {
	my ($subscriptionid) = @_;
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare('select subscription.*,aqbudget.bookfundid,aqbooksellers.name as aqbooksellername,biblio.title as bibliotitle 
							from subscription 
							left join aqbudget on subscription.aqbudgetid=aqbudget.aqbudgetid 
							left join aqbooksellers on subscription.aqbooksellerid=aqbooksellers.id 
							left join biblio on biblio.biblionumber=subscription.biblionumber 
							where subscriptionid = ?');
	$sth->execute($subscriptionid);
	my $subs = $sth->fetchrow_hashref;
	return $subs;
}

sub modsubscription {
	my ($auser,$aqbooksellerid,$cost,$aqbudgetid,$startdate,
					$periodicity,$dow,$numberlength,$weeklength,$monthlength,
					$seqnum1,$startseqnum1,$seqtype1,$freq1,$step1,
					$seqnum2,$startseqnum2,$seqtype2,$freq2,$step2,
					$seqnum3,$startseqnum3,$seqtype3,$freq3,$step3,
					$numberingmethod, $arrivalplanified, $status, $biblionumber, $notes, $subscriptionid)= @_;
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("update subscription set librarian=?, aqbooksellerid=?,cost=?,aqbudgetid=?,startdate=?, periodicity=?,dow=?,numberlength=?,weeklength=?,monthlength=?,seqnum1=?,startseqnum1=?,seqtype1=?,freq1=?,step1=?,seqnum2=?,startseqnum2=?,seqtype2=?,freq2=?, step2=?, seqnum3=?,startseqnum3=?,seqtype3=?, freq3=?, step3=?,numberingmethod=?, arrivalplanified=?, status=?, biblionumber=?, notes=? where subscriptionid = ?");
	$sth->execute($auser,$aqbooksellerid,$cost,$aqbudgetid,$startdate,
					$periodicity,$dow,$numberlength,$weeklength,$monthlength,
					$seqnum1,$startseqnum1,$seqtype1,$freq1,$step1,
					$seqnum2,$startseqnum2,$seqtype2,$freq2,$step2,
					$seqnum3,$startseqnum3,$seqtype3,$freq3,$step3,
					$numberingmethod, $arrivalplanified, $status, $biblionumber, $notes, $subscriptionid);
	$sth->finish;

}

sub getsubscriptions {
	my ($title,$ISSN) = @_;
	my $dbh = C4::Context->dbh;
	my $sth;
	$sth = $dbh->prepare("select subscription.subscriptionid,biblio.title,biblioitems.issn from subscription,biblio,biblioitems where  biblio.biblionumber = biblioitems.biblionumber and biblio.biblionumber=subscription.biblionumber and (biblio.title like ? or biblioitems.issn = ? )");
	$sth->execute($title,$ISSN);
	my @results;
	while (my $line = $sth->fetchrow_hashref) {
		push @results, $line;
	}
	return @results;
}

sub modsubscriptionhistory {
	my ($subscriptionid,$startdate,$enddate,$recievedlist,$missinglist,$opacnote,$librariannote)=@_;
	my $dbh=C4::Context->dbh;
	my $sth = $dbh->prepare("update subscriptionhistory set startdate=?,enddate=?,recievedlist=?,missinglist=?,opacnote=?,librariannote=? where subscriptionid=?");
	$sth->execute($startdate,$enddate,$recievedlist,$missinglist,$opacnote,$librariannote,$subscriptionid);
}
# get every serial not arrived for a given subscription.
sub getserials {
	my ($subscriptionid) = @_;
	my $dbh = C4::Context->dbh;
	# status = 2 is "arrived"
	my $sth=$dbh->prepare("select serialid,serialseq, status, planneddate from serial where subscriptionid = ? and status <>2 and status <>4");
	$sth->execute($subscriptionid);
	my @serials;
	while(my $line = $sth->fetchrow_hashref) {
		$line->{"status".$line->{status}} = 1; # fills a "statusX" value, used for template status select list
		push @serials,$line;
	}
	return @serials;
}

sub serialchangestatus {
	my ($serialid,$serialseq,$planneddate,$status)=@_;
	warn "($serialid,$serialseq,$planneddate,$status)";
# 	return 1;
	# 1st, get previous status : if we change from "waited" to something else, then we will have to create a new "waited" entry
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare("select subscriptionid,status from serial where serialid=?");
	$sth->execute($serialid);
	my ($subscriptionid,$oldstatus) = $sth->fetchrow;
	# change status & update subscriptionhistory
	$sth = $dbh->prepare("update serial set serialseq=?,planneddate=?,status=? where serialid = ?");
	$sth->execute($serialseq,$planneddate,$status,$serialid);
	$sth = $dbh->prepare("select missinglist,recievedlist from subscriptionhistory where subscriptionid=?");
	$sth->execute($subscriptionid);
	my ($missinglist,$recievedlist) = $sth->fetchrow;
	if ($status eq 2) {
		$recievedlist .= ",$serialseq";
	}
	if ($status eq 4) {
		$missinglist .= ",$serialseq";
	}
	$sth=$dbh->prepare("update subscriptionhistory set recievedlist=?, missinglist=? where subscriptionid=?");
	$sth->execute($recievedlist,$missinglist,$subscriptionid);
	# create new waited entry if needed (ie : was a "waited" and has changed)
	if ($oldstatus eq 1 && $status ne 1) {
	   $sth = $dbh->prepare("select * from subscription where subscriptionid = ? ");
	   $sth->execute($subscriptionid);
	   my $val = $sth->fetchrow_hashref;
	   $sth = $dbh->prepare("insert into serial (serialseq,subscriptionid,biblionumber,status, planneddate) values (?,?,?,?,?)");
	   my ($temp, $X, $Y, $Z, $pos1, $pos2, $pos3) = Get_Next_Seq($val->{'numberingmethod'},$val->{'seqnum1'},$val->{'freq1'}, $val->{'step1'}, $val->{'seqtype1'}, $val->{'seqnum2'}, $val->{'freq2'}, $val->{'step2'}, $val->{'seqtype2'}, $val->{'seqnum3'}, $val->{'freq3'}, $val->{'step3'}, $val->{'seqtype3'}, $val->{'pos1'}, $val->{'pos2'}, $val->{'pos3'});
	   $sth->execute($temp, $subscriptionid, $val->{'biblionumber'}, 1, 0);
	   $sth = $dbh->prepare("update subscription set seqnum1=?, seqnum2=?,seqnum3=?,pos1=?,pos2=?,pos3=? where subscriptionid = ?");
	   $sth->execute($X, $Y, $Z, $pos1, $pos2, $pos3, $subscriptionid);

	}
}
sub GetValue(@) {
    my $seq = shift;
    my $X = shift;
    my $Y = shift;
    my $Z = shift;

    return $X if ($seq eq 'X');
    return $Y if ($seq eq 'Y');
    return $Z if ($seq eq 'Z');
    return "5 Syntax Error in Sequence";
}


sub Initialize_Sequence(@) {
	my $sequence = shift;
	my $X = shift;
	my $seqtype1 = shift;
	my $freq1 = shift;
	my $step1 = shift;
	my $Y = shift;
	my $seqtype2 = shift;
	my $freq2 = shift;
	my $step2 = shift;
	my $Z = shift;
	my $seqtype3 = shift;
	my $freq3 = shift;
	my $step3 = shift;
	my $finalstring = "";
	my @string = split //, $sequence;
	my $etat = 0;
	
	for (my $i = 0; $i < (scalar @string); $i++) {
		if ($string[$i] ne '{') {
			if (!$etat) {
				$finalstring .= $string[$i];
			} else {
				return "1 Syntax Error in Sequence";
			}
		} else {
			return "3 Syntax Error in Sequence"
					if ($string[$i + 1] ne 'X' && $string[$i + 1] ne 'Y' && $string[$i + 1] ne 'Z');  
			$finalstring .= GetValue($string[$i + 1], $X, $Y, $Z);
			$i += 2;
		}
	}
	return "$finalstring";
}

sub Find_Next_Date(@) {
    return "2004-29-03";
}

sub Step(@) {
	my $seqnum1 = shift;
	my $seqtype1 = shift;
	my $freq1 = shift;
	my $step1 = shift;
	my $seqnum2 = shift;
	my $seqtype2 = shift;
	my $freq2 = shift;
	my $step2 = shift;
	my $seqnum3 = shift;
	my $seqtype3 = shift;
	my $freq3 = shift;
	my $step3 = shift;
	my $pos1 = shift;
	my $pos2 = shift;
	my $pos3 = shift; 

	$seqnum1 += $step1 if ($seqtype1 == 1);
	if ($seqtype1 == 2) {
		$pos1 += 1;
		if ($pos1 >= $freq1) {
			$pos1 = 0;
			$seqnum1 += $step1;
		}
	}

	$seqnum2 += $step2 if ($seqtype2 == 1);
	if ($seqtype2 == 2) {
		$pos2 += 1;
		if ($pos2 >= $freq2) {
			$pos2 = 0;
			$seqnum2 += $step2;
		}
	}

	$seqnum3 += $step3 if ($seqtype3 == 1);
	if ($seqtype3 == 2) {
		$pos3 += 1;
		if ($pos3 >= $freq3) {
			$pos3 = 0;
			$seqnum3 += $step3;
		}
	}
    
#    $Y += $step2; if ($seqtype2 == 1);
 #   if ($seqtype2 == 2) { $pos2 += 1; if ($pos2 >= $freq2) {
	#$pos2 = 0; $Y += $step2; } }


   # $Z += $step3; if ($seqtype3 == 1);
   # if ($seqtype3 == 2) { $pos3 += 1; if ($pos3 >= $freq3) {
#	$pos3 = 0; $Z += $step3; } }

    return ($seqnum1, $seqnum2, $seqnum3, $pos1, $pos2, $pos3);
}

sub Get_Next_Seq(@) {
    my $sequence = shift;
    my $seqnum1 = shift;
    my $freq1 = shift;
    my $step1 = shift;
    my $seqtype1 = shift;
    my $seqnum2 = shift;
    my $freq2 = shift;
    my $step2 = shift;
    my $seqtype2 = shift;
    my $seqnum3 = shift;
    my $freq3 = shift;
    my $step3 = shift;
    my $seqtype3 = shift;
    my $pos1 = shift;
    my $pos2 = shift;
    my $pos3 = shift;

    return ("$sequence", $seqnum1, $seqnum2, $seqnum3)
	if (!defined($seqnum1) && !defined($seqnum2) && !defined($seqnum3));
	
    ($seqnum1, $seqnum2, $seqnum3, $pos1, $pos2, $pos3) = 
	Step($seqnum1, $seqtype1, $freq1, $step1, $seqnum2, $seqtype2, $freq2, 
	          $step2, $seqnum3, $seqtype3, $freq3, $step3, $pos1, $pos2, $pos3);
			  
    return (Initialize_Sequence($sequence, $seqnum1, $seqtype1,
				$freq1, $step1, $seqnum2, $seqtype2, $freq2,
				$step2, $seqnum3, $seqtype3, $freq3, $step3),
	        $seqnum1, $seqnum2, $seqnum3, $pos1, $pos2, $pos3);
}

END { }       # module clean-up code here (global destructor)
