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
use C4::Date;
use Date::Manip;
use C4::Suggestions;
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
@EXPORT = qw(&newsubscription &modsubscription &getsubscriptions &getsubscription &getsubscriptionfrombiblionumber
			&modsubscriptionhistory
			&getserials &serialchangestatus
			&Find_Next_Date, &Get_Next_Seq
			&hassubscriptionexpired &subscriptionexpirationdate &subscriptionrenew);

sub newsubscription {
	my ($auser,$aqbooksellerid,$cost,$aqbudgetid,$biblionumber,
		$startdate,$periodicity,$dow,$numberlength,$weeklength,$monthlength,
		$add1,$every1,$whenmorethan1,$setto1,$lastvalue1,
		$add2,$every2,$whenmorethan2,$setto2,$lastvalue2,
		$add3,$every3,$whenmorethan3,$setto3,$lastvalue3,
		$numberingmethod, $status, $notes) = @_;
	my $dbh = C4::Context->dbh;
	#save subscription
	my $sth=$dbh->prepare("insert into subscription (librarian,aqbooksellerid,cost,aqbudgetid,biblionumber,
							startdate,periodicity,dow,numberlength,weeklength,monthlength,
							add1,every1,whenmorethan1,setto1,lastvalue1,
							add2,every2,whenmorethan2,setto2,lastvalue2,
							add3,every3,whenmorethan3,setto3,lastvalue3,
							numberingmethod, status, notes) values 
							(?,?,?,?,?,?,?,?,?,
							 ?,?,?,?,?,?,?,?,?,?,
							 ?,?,?,?,?,?,?,?,?,?)");
	$sth->execute($auser,$aqbooksellerid,$cost,$aqbudgetid,$biblionumber,
					format_date_in_iso($startdate),$periodicity,$dow,$numberlength,$weeklength,$monthlength,
					$add1,$every1,$whenmorethan1,$setto1,$lastvalue1,
					$add2,$every2,$whenmorethan2,$setto2,$lastvalue2,
					$add3,$every3,$whenmorethan3,$setto3,$lastvalue3,
	 				$numberingmethod, $status, $notes);
	#then create the 1st waited number
	my $subscriptionid = $dbh->{'mysql_insertid'};
	$sth = $dbh->prepare("insert into subscriptionhistory (biblionumber, subscriptionid, histstartdate, enddate, missinglist, recievedlist, opacnote, librariannote) values (?,?,?,?,?,?,?,?)");
	$sth->execute($biblionumber, $subscriptionid, format_date_in_iso($startdate), 0, "", "", 0, $notes);
	# reread subscription to get a hash (for calculation of the 1st issue number)
	$sth = $dbh->prepare("select * from subscription where subscriptionid = ? ");
	$sth->execute($subscriptionid);
	my $val = $sth->fetchrow_hashref;

	# calculate issue number
	my $serialseq = Get_Seq($val);
	$sth = $dbh->prepare("insert into serial (serialseq,subscriptionid,biblionumber,status, planneddate) values (?,?,?,?,?)");
	$sth->execute($serialseq, $subscriptionid, $val->{'biblionumber'}, 1, format_date_in_iso($startdate));

	# next issue number
	#my ($newserialseq,$newlastvalue1,$newlastvalue2,$newlastvalue3,$newinnerloop1,$newinnerloop2,$newinnerloop3) = Get_Next_Seq($val);
	# next date (calculated from actual date & frequency parameters)
	#my $nextplanneddate = Get_Next_Date($startdate,$val);
# 	$sth = $dbh->prepare("update subscription set lastvalue1=?, lastvalue2=?,lastvalue3=?,
# 													innerloop1=?,innerloop2=?,innerloop3=?
# 													where subscriptionid = ?");
# 	$sth->execute($newlastvalue1,$newlastvalue2,$newlastvalue3,$newinnerloop1,$newinnerloop2,$newinnerloop3,$subscriptionid);
# 	$sth->finish;  
	return $subscriptionid;
}
sub getsubscription {
	my ($subscriptionid) = @_;
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare('select subscription.*,subscriptionhistory.*,aqbudget.bookfundid,aqbooksellers.name as aqbooksellername,biblio.title as bibliotitle 
							from subscription 
							left join subscriptionhistory on subscription.subscriptionid=subscriptionhistory.subscriptionid
							left join aqbudget on subscription.aqbudgetid=aqbudget.aqbudgetid 
							left join aqbooksellers on subscription.aqbooksellerid=aqbooksellers.id 
							left join biblio on biblio.biblionumber=subscription.biblionumber 
							where subscription.subscriptionid = ?');
	$sth->execute($subscriptionid);
	my $subs = $sth->fetchrow_hashref;
	return $subs;
}

sub getsubscriptionfrombiblionumber {
	my ($biblionumber) = @_;
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare('select subscriptionid from subscription where biblionumber=?');
	$sth->execute($biblionumber);
	my $subscriptionid = $sth->fetchrow;
	return $subscriptionid;
}

sub modsubscription {
	my ($auser,$aqbooksellerid,$cost,$aqbudgetid,$startdate,
					$periodicity,$dow,$numberlength,$weeklength,$monthlength,
					$add1,$every1,$whenmorethan1,$setto1,$lastvalue1,$innerloop1,
					$add2,$every2,$whenmorethan2,$setto2,$lastvalue2,$innerloop2,
					$add3,$every3,$whenmorethan3,$setto3,$lastvalue3,$innerloop3,
					$numberingmethod, $status, $biblionumber, $notes, $subscriptionid)= @_;
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("update subscription set librarian=?, aqbooksellerid=?,cost=?,aqbudgetid=?,startdate=?,
						 periodicity=?,dow=?,numberlength=?,weeklength=?,monthlength=?,
						add1=?,every1=?,whenmorethan1=?,setto1=?,lastvalue1=?,innerloop1=?,
						add2=?,every2=?,whenmorethan2=?,setto2=?,lastvalue2=?,innerloop2=?,
						add3=?,every3=?,whenmorethan3=?,setto3=?,lastvalue3=?,innerloop3=?,
						numberingmethod=?, status=?, biblionumber=?, notes=? where subscriptionid = ?");
	$sth->execute($auser,$aqbooksellerid,$cost,$aqbudgetid,$startdate,
					$periodicity,$dow,$numberlength,$weeklength,$monthlength,
					$add1,$every1,$whenmorethan1,$setto1,$lastvalue1,$innerloop1,
					$add2,$every2,$whenmorethan2,$setto2,$lastvalue2,$innerloop2,
					$add3,$every3,$whenmorethan3,$setto3,$lastvalue3,$innerloop3,
					$numberingmethod, $status, $biblionumber, $notes, $subscriptionid);
	$sth->finish;

}

sub getsubscriptions {
	my ($title,$ISSN) = @_;
	my $dbh = C4::Context->dbh;
	my $sth;
	$sth = $dbh->prepare("select subscription.subscriptionid,biblio.title,biblioitems.issn from subscription,biblio,biblioitems where  biblio.biblionumber = biblioitems.biblionumber and biblio.biblionumber=subscription.biblionumber and (biblio.title like ? or biblioitems.issn = ? )");
	$sth->execute("%$title%",$ISSN);
	my @results;
	while (my $line = $sth->fetchrow_hashref) {
		push @results, $line;
	}
	return @results;
}

sub modsubscriptionhistory {
	my ($subscriptionid,$histstartdate,$enddate,$recievedlist,$missinglist,$opacnote,$librariannote)=@_;
	my $dbh=C4::Context->dbh;
	my $sth = $dbh->prepare("update subscriptionhistory set histstartdate=?,enddate=?,recievedlist=?,missinglist=?,opacnote=?,librariannote=? where subscriptionid=?");
	$sth->execute($histstartdate,$enddate,$recievedlist,$missinglist,$opacnote,$librariannote,$subscriptionid);
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
		$line->{"planneddate"} = format_date($line->{"planneddate"});
		push @serials,$line;
	}
	return @serials;
}

sub serialchangestatus {
	my ($serialid,$serialseq,$planneddate,$status)=@_;
# 	warn "($serialid,$serialseq,$planneddate,$status)";
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
		# next issue number
		my ($newserialseq,$newlastvalue1,$newlastvalue2,$newlastvalue3,$newinnerloop1,$newinnerloop2,$newinnerloop3) = Get_Next_Seq($val);
		# next date (calculated from actual date & frequency parameters)
		my $nextplanneddate = Get_Next_Date($planneddate,$val);
		$sth = $dbh->prepare("insert into serial (serialseq,subscriptionid,biblionumber,status, planneddate) values (?,?,?,?,?)");
		$sth->execute($newserialseq, $subscriptionid, $val->{'biblionumber'}, 1, $nextplanneddate);
		$sth = $dbh->prepare("update subscription set lastvalue1=?, lastvalue2=?,lastvalue3=?,
														innerloop1=?,innerloop2=?,innerloop3=?
														where subscriptionid = ?");
		$sth->execute($newlastvalue1,$newlastvalue2,$newlastvalue3,$newinnerloop1,$newinnerloop2,$newinnerloop3,$subscriptionid);
	}
}

sub Get_Next_Date(@) {
	my ($planneddate,$subscription) = @_;
	my $resultdate;
	if ($subscription->{periodicity} == 1) {
		$resultdate=DateCalc($planneddate,"1 day");
	}
	if ($subscription->{periodicity} == 2) {
		$resultdate=DateCalc($planneddate,"1 week");
	}
	if ($subscription->{periodicity} == 3) {
		$resultdate=DateCalc($planneddate,"2 weeks");
	}
	if ($subscription->{periodicity} == 4) {
		$resultdate=DateCalc($planneddate,"3 weeks");
	}
	if ($subscription->{periodicity} == 5) {
		$resultdate=DateCalc($planneddate,"1 month");
	}
	if ($subscription->{periodicity} == 6) {
		$resultdate=DateCalc($planneddate,"2 months");
	}
	if ($subscription->{periodicity} == 7) {
		$resultdate=DateCalc($planneddate,"3 months");
	}
	if ($subscription->{periodicity} == 8) {
		$resultdate=DateCalc($planneddate,"1 quarter");
	}
	if ($subscription->{periodicity} == 9) {
		$resultdate=DateCalc($planneddate,"2 weeks");
	}
	if ($subscription->{periodicity} == 10) {
		$resultdate=DateCalc($planneddate,"1 year");
	}
	if ($subscription->{periodicity} == 11) {
		$resultdate=DateCalc($planneddate,"2 years");
	}
    return format_date_in_iso($resultdate);
}

sub Get_Seq {
	my ($val) =@_;
	my $calculated = $val->{numberingmethod};
	my $x=$val->{'lastvalue1'};
	$calculated =~ s/\{X\}/$x/g;
	my $y=$val->{'lastvalue2'};
	$calculated =~ s/\{Y\}/$y/g;
	my $z=$val->{'lastvalue3'};
	$calculated =~ s/\{Z\}/$z/g;
	return $calculated;
}

sub Get_Next_Seq {
	my ($val) =@_;
	my ($calculated,$newlastvalue1,$newlastvalue2,$newlastvalue3,$newinnerloop1,$newinnerloop2,$newinnerloop3);
	$calculated = $val->{numberingmethod};
	# calculate the (expected) value of the next issue recieved.
	$newlastvalue1 = $val->{lastvalue1};
	# check if we have to increase the new value.
	$newinnerloop1 = $val->{innerloop1}+1;
	$newinnerloop1=0 if ($newinnerloop1 >= $val->{every1});
	$newlastvalue1 += $val->{add1} if ($newinnerloop1<1); # <1 to be true when 0 or empty.
	$newlastvalue1=$val->{setto1} if ($newlastvalue1>$val->{whenmorethan1}); # reset counter if needed.
	$calculated =~ s/\{X\}/$newlastvalue1/g;
	
	$newlastvalue2 = $val->{lastvalue2};
	# check if we have to increase the new value.
	$newinnerloop2 = $val->{innerloop2}+1;
	$newinnerloop2=0 if ($newinnerloop2 >= $val->{every2});
	$newlastvalue2 += $val->{add2} if ($newinnerloop2<1); # <1 to be true when 0 or empty.
	$newlastvalue2=$val->{setto2} if ($newlastvalue2>$val->{whenmorethan2}); # reset counter if needed.
	$calculated =~ s/\{Y\}/$newlastvalue2/g;
	
	$newlastvalue3 = $val->{lastvalue3};
	# check if we have to increase the new value.
	$newinnerloop3 = $val->{innerloop3}+1;
	$newinnerloop3=0 if ($newinnerloop3 >= $val->{every3});
	$newlastvalue3 += $val->{add3} if ($newinnerloop3<1); # <1 to be true when 0 or empty.
	$newlastvalue3=$val->{setto3} if ($newlastvalue3>$val->{whenmorethan3}); # reset counter if needed.
	$calculated =~ s/\{Z\}/$newlastvalue3/g;
	return ($calculated,$newlastvalue1,$newlastvalue2,$newlastvalue3,$newinnerloop1,$newinnerloop2,$newinnerloop3);
}

# the subscription has expired when the next issue to arrive is out of subscription limit.
sub hassubscriptionexpired {
	my ($subscriptionid) = @_;
	my $dbh = C4::Context->dbh;
	my $subscription = getsubscription($subscriptionid);
	# we don't do the same test if the subscription is based on X numbers or on X weeks/months
	if ($subscription->{numberlength}) {
		my $sth = $dbh->prepare("select count(*) from serial where subscriptionid=?  and planneddate>=?");
		$sth->execute($subscriptionid,$subscription->{planneddate});
		my $res = $sth->fetchrow;
		if ($subscription->{numberlength}>=$res) {
			return 0;
		} else {
			return 1;
		}
	} else {
		#a little bit more tricky if based on X weeks/months : search if the latest issue waited is not after subscription startdate + duration
		my $sth = $dbh->prepare("select max(planneddate) from serial where subscriptionid=?");
		$sth->execute($subscriptionid);
		my $res = ParseDate(format_date_in_iso($sth->fetchrow));
		my $endofsubscriptiondate;
		$endofsubscriptiondate = DateCalc(format_date_in_iso($subscription->{startdate}),$subscription->{monthlength}." months") if ($subscription->{monthlength});
		$endofsubscriptiondate = DateCalc(format_date_in_iso($subscription->{startdate}),$subscription->{weeklength}." weeks") if ($subscription->{weeklength});
		return 1 if ($res >= $endofsubscriptiondate);
		return 0;
	}
}

sub subscriptionexpirationdate {
	my ($subscriptionid) = @_;
	my $dbh = C4::Context->dbh;
	my $subscription = getsubscription($subscriptionid);
	my $enddate=$subscription->{startdate};
	# we don't do the same test if the subscription is based on X numbers or on X weeks/months
	if ($subscription->{numberlength}) {
		#calculate the date of the last issue.
		for (my $i=1;$i<=$subscription->{numberlength};$i++) {
			$enddate = Get_Next_Date($enddate,$subscription);
		}
	} else {
		$enddate = DateCalc(format_date_in_iso($subscription->{startdate}),$subscription->{monthlength}." months") if ($subscription->{monthlength});
		$enddate = DateCalc(format_date_in_iso($subscription->{startdate}),$subscription->{weeklength}." weeks") if ($subscription->{weeklength});
	}
# 	$enddate=format_date_in_iso($enddate);
# 	warn "END : $enddate";
	return $enddate;
}

sub subscriptionrenew {
	my ($subscriptionid,$user,$startdate,$numberlength,$weeklength,$monthlength,$note) = @_;
	my $dbh = C4::Context->dbh;
	my $subscription = getsubscription($subscriptionid);
	my $sth = $dbh->prepare("select * from biblio,biblioitems where biblio.biblionumber=biblioitems.biblionumber and biblio.biblionumber=?");
	$sth->execute($subscription->{biblionumber});
	my $biblio = $sth->fetchrow_hashref;
	newsuggestion($user,$subscription->{bibliotitle},$biblio->{author},$biblio->{publishercode},$biblio->{note},,,,,$subscription->{biblionumber});
	# renew subscription
	$sth=$dbh->prepare("update subscription set startdate=?,numberlength=?,weeklength=?,monthlength=?");
	$sth->execute(format_date_in_iso($startdate),$numberlength,$weeklength,$monthlength);
}
END { }       # module clean-up code here (global destructor)
