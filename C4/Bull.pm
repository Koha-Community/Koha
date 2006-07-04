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
use C4::Biblio;
use C4::Search;
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
@EXPORT = qw(&newsubscription &modsubscription &delsubscription &getsubscriptions &getsubscription 
			&getsubscriptionfrombiblionumber &get_subscription_list_from_biblionumber
			&get_full_subscription_list_from_biblionumber 
			&modsubscriptionhistory &newissue &serialsitemize
			&getserials &getlatestserials &serialchangestatus
			&Find_Next_Date &Get_Next_Seq
			&hassubscriptionexpired &subscriptionexpirationdate &subscriptionrenew
			&getSupplierListWithLateIssues &GetLateIssues &serialdelete &getlatestserials
			);

sub getSupplierListWithLateIssues {
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare("SELECT DISTINCT id, name
							FROM subscription, serial
							LEFT JOIN aqbooksellers ON subscription.aqbooksellerid = aqbooksellers.id
							WHERE subscription.subscriptionid = serial.subscriptionid AND
							(planneddate < now( ) OR serial.STATUS = 3)
							");
	$sth->execute;
	my %supplierlist;
	while (my ($id,$name) = $sth->fetchrow) {
		$supplierlist{$id} = $name;
	}
	return %supplierlist;
}
sub GetLateIssues {
	my ($supplierid) = @_;
	my $dbh = C4::Context->dbh;
	my $sth;
	if ($supplierid) {
		$sth = $dbh->prepare("SELECT name,title,planneddate,serialseq,serial.subscriptionid
							FROM subscription, serial, biblio
							LEFT JOIN aqbooksellers ON subscription.aqbooksellerid = aqbooksellers.id
							WHERE subscription.subscriptionid = serial.subscriptionid AND
							((planneddate < now() and serial.STATUS =1) OR serial.STATUS = 3) and
							subscription.aqbooksellerid=$supplierid and
							biblio.biblionumber = subscription.biblionumber order by title
							");
	} else {
		$sth = $dbh->prepare("SELECT name,title,planneddate,serialseq,serial.subscriptionid
							FROM subscription, serial, biblio
							LEFT JOIN aqbooksellers ON subscription.aqbooksellerid = aqbooksellers.id
							WHERE subscription.subscriptionid = serial.subscriptionid AND
							((planneddate < now() and serial.STATUS <=3) OR serial.STATUS = 3) and
							biblio.biblionumber = subscription.biblionumber order by title
							");
	}
	$sth->execute;
	my @issuelist;
	my $last_title;
	my $odd=0;
	while (my $line = $sth->fetchrow_hashref) {
		$odd++ unless $line->{title} eq $last_title;
		$line->{title} = "" if $line->{title} eq $last_title;
		$last_title = $line->{title} if ($line->{title});
		$line->{planneddate} = format_date($line->{planneddate});
		$line->{'odd'} = 1 if $odd %2 ;
		push @issuelist,$line;
	}
	return @issuelist;
}

sub newsubscription {
	my ($auser,$aqbooksellerid,$cost,$aqbudgetid,$biblionumber,
		$startdate,$periodicity,$dow,$numberlength,$weeklength,$monthlength,
		$add1,$every1,$whenmorethan1,$setto1,$lastvalue1,$innerloop1,
		$add2,$every2,$whenmorethan2,$setto2,$lastvalue2,$innerloop2,
		$add3,$every3,$whenmorethan3,$setto3,$lastvalue3,$innerloop3,
		$numberingmethod, $status, $notes) = @_;
	my $dbh = C4::Context->dbh;
	#save subscription
	my $sth=$dbh->prepare("insert into subscription (librarian,aqbooksellerid,cost,aqbudgetid,biblionumber,
							startdate,periodicity,dow,numberlength,weeklength,monthlength,
							add1,every1,whenmorethan1,setto1,lastvalue1,innerloop1,
							add2,every2,whenmorethan2,setto2,lastvalue2,innerloop2,
							add3,every3,whenmorethan3,setto3,lastvalue3,innerloop3,
							numberingmethod, status, notes) values 
							(?,?,?,?,?,?,?,?,?,
							 ?,?,?,?,?,?,?,?,?,?,
							 ?,?,?,?,?,?,?,?,?,?,?,?,?)");
	$sth->execute($auser,$aqbooksellerid,$cost,$aqbudgetid,$biblionumber,
					format_date_in_iso($startdate),$periodicity,$dow,$numberlength,$weeklength,$monthlength,
					$add1,$every1,$whenmorethan1,$setto1,$lastvalue1,$innerloop1,
					$add2,$every2,$whenmorethan2,$setto2,$lastvalue2,$innerloop2,
					$add3,$every3,$whenmorethan3,$setto3,$lastvalue3,$innerloop3,
	 				$numberingmethod, $status, $notes);
	#then create the 1st waited number
	my $subscriptionid = $dbh->{'mysql_insertid'};
	$sth = $dbh->prepare("insert into subscriptionhistory (biblionumber, subscriptionid, histstartdate, enddate, missinglist, recievedlist, opacnote, librariannote) values (?,?,?,?,?,?,?,?)");
	$sth->execute($biblionumber, $subscriptionid, format_date_in_iso($startdate), 0, "", "", "", $notes);
	# reread subscription to get a hash (for calculation of the 1st issue number)
	$sth = $dbh->prepare("SELECT * from subscription where subscriptionid = ? ");
	$sth->execute($subscriptionid);
	my $val = $sth->fetchrow_hashref;

	# calculate issue number
	my $serialseq = Get_Seq($val);
	$sth = $dbh->prepare("insert into serial (serialseq,subscriptionid,biblionumber,status, planneddate) values (?,?,?,?,?)");
	$sth->execute($serialseq, $subscriptionid, $val->{'biblionumber'}, 1, format_date_in_iso($startdate));
	return $subscriptionid;
}

sub getsubscription {
	my ($subscriptionid) = @_;
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare('SELECT subscription.*,subscriptionhistory.*,aqbudget.bookfundid,aqbooksellers.name as aqbooksellername,biblio.title as bibliotitle 
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
	my $sth = $dbh->prepare('SELECT count(*) from subscription where biblionumber=?');
	$sth->execute($biblionumber);
	my $subscriptionsnumber = $sth->fetchrow;
	return $subscriptionsnumber;
}

sub get_subscription_list_from_biblionumber {
	my ($biblionumber) = @_;
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare('SELECT subscription.*,subscriptionhistory.*,  aqbudget.bookfundid,aqbooksellers.name as aqbooksellername,biblio.title as bibliotitle 
							from subscription 
							left join subscriptionhistory on subscription.subscriptionid=subscriptionhistory.subscriptionid
							left join aqbudget on subscription.aqbudgetid=aqbudget.aqbudgetid 
							left join aqbooksellers on subscription.aqbooksellerid=aqbooksellers.id 
							left join biblio on biblio.biblionumber=subscription.biblionumber 
							where subscription.biblionumber = ?');
	$sth->execute($biblionumber);
	my @res;
	while (my $subs = $sth->fetchrow_hashref) {
		$subs->{startdate} = format_date($subs->{startdate});
		$subs->{histstartdate} = format_date($subs->{histstartdate});
		$subs->{opacnote} =~ s/\n/\<br\/\>/g;
		$subs->{missinglist} =~ s/\n/\<br\/\>/g;
		$subs->{recievedlist} =~ s/\n/\<br\/\>/g;
		$subs->{"periodicity".$subs->{periodicity}} = 1;
		$subs->{"status".$subs->{'status'}} = 1;
		if ($subs->{enddate} eq '0000-00-00') {
			$subs->{enddate}='';
		} else {
			$subs->{enddate} = format_date($subs->{enddate});
		}
		push @res,$subs;
	}
	return \@res;
}

sub get_full_subscription_list_from_biblionumber {
  my ($biblionumber) = @_;
  my $dbh = C4::Context->dbh;
  my $sth = $dbh->prepare('
  SELECT serial.serialseq,serial.planneddate, serial.publisheddate, serial.status, serial.notes,
    year(serial.publisheddate) as year,
    aqbudget.bookfundid,aqbooksellers.name as aqbooksellername,biblio.title as bibliotitle
  FROM serial 
        LEFT JOIN subscription ON 
          (serial.subscriptionid=subscription.subscriptionid AND subscription.biblionumber=serial.biblionumber)
        LEFT JOIN aqbudget ON subscription.aqbudgetid=aqbudget.aqbudgetid 
        LEFT JOIN aqbooksellers on subscription.aqbooksellerid=aqbooksellers.id 
        LEFT JOIN biblio on biblio.biblionumber=subscription.biblionumber 
  WHERE subscription.biblionumber = ? 
  ORDER BY year,serial.publisheddate,serial.subscriptionid,serial.planneddate');
	$sth->execute($biblionumber);
	my @res;
	my $year;
	my $startdate;
	my $aqbooksellername;
	my $bibliotitle;
	my @loopissues;
	my $first;
	my $previousnote="";
	while (my $subs = $sth->fetchrow_hashref) {
### BUG To FIX: When there is no published date, will create many null ids!!!

		if ($year and ($year==$subs->{year})){
			if ($first eq 1){$first=0;}
			my $temp=$res[scalar(@res)-1]->{'serials'};
			push @$temp,
                {'publisheddate' =>format_date($subs->{'publisheddate'}),
                'planneddate' => format_date($subs->{'planneddate'}), 
                'serialseq' => $subs->{'serialseq'},
                "status".$subs->{'status'} => 1,
                'notes' => $subs->{'notes'} eq $previousnote?"":$subs->{notes},
                };
		}else {
			$first=1 if (not $year);
			$year= $subs->{'year'};
			$startdate= format_date($subs->{'startdate'});
			$aqbooksellername= $subs->{'aqbooksellername'};
			$bibliotitle= $subs->{'bibliotitle'};
			my @temp;
			push @temp,
				{'publisheddate' =>format_date($subs->{'publisheddate'}),
                'planneddate' => format_date($subs->{'planneddate'}), 
				'serialseq' => $subs->{'serialseq'},
				"status".$subs->{'status'} => 1,
				'notes' => $subs->{'notes'} eq $previousnote?"":$subs->{notes},
				};
			
			push @res,{
				'year'=>$year,
				'startdate'=>$startdate,
				'aqbooksellername'=>$aqbooksellername,
				'bibliotitle'=>$bibliotitle,
				'serials'=>\@temp,
				'first'=>$first 
			};
		}
		$previousnote=$subs->{notes};
	}
	return \@res;
}


sub modsubscription {
	my ($auser,$aqbooksellerid,$cost,$aqbudgetid,$startdate,
					$periodicity,$dow,$numberlength,$weeklength,$monthlength,
					$add1,$every1,$whenmorethan1,$setto1,$lastvalue1,$innerloop1,
					$add2,$every2,$whenmorethan2,$setto2,$lastvalue2,$innerloop2,
					$add3,$every3,$whenmorethan3,$setto3,$lastvalue3,$innerloop3,
					$numberingmethod, $status, $biblionumber, $notes, $letter, $subscriptionid)= @_;
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("update subscription set librarian=?, aqbooksellerid=?,cost=?,aqbudgetid=?,startdate=?,
						 periodicity=?,dow=?,numberlength=?,weeklength=?,monthlength=?,
						add1=?,every1=?,whenmorethan1=?,setto1=?,lastvalue1=?,innerloop1=?,
						add2=?,every2=?,whenmorethan2=?,setto2=?,lastvalue2=?,innerloop2=?,
						add3=?,every3=?,whenmorethan3=?,setto3=?,lastvalue3=?,innerloop3=?,
						numberingmethod=?, status=?, biblionumber=?, notes=?, letter=? where subscriptionid = ?");
	$sth->execute($auser,$aqbooksellerid,$cost,$aqbudgetid,$startdate,
					$periodicity,$dow,$numberlength,$weeklength,$monthlength,
					$add1,$every1,$whenmorethan1,$setto1,$lastvalue1,$innerloop1,
					$add2,$every2,$whenmorethan2,$setto2,$lastvalue2,$innerloop2,
					$add3,$every3,$whenmorethan3,$setto3,$lastvalue3,$innerloop3,
					$numberingmethod, $status, $biblionumber, $notes, $letter, $subscriptionid);
	$sth->finish;

}

sub delsubscription {
	my ($subscriptionid) = @_;
	my $dbh = C4::Context->dbh;
	$subscriptionid=$dbh->quote($subscriptionid);
	$dbh->do("delete from subscription where subscriptionid=$subscriptionid");
	$dbh->do("delete from subscriptionhistory where subscriptionid=$subscriptionid");
	$dbh->do("delete from serial where subscriptionid=$subscriptionid");
}
sub getsubscriptions {
	my ($title,$ISSN,$biblionumber) = @_;
	return unless $title or $ISSN or $biblionumber;
	my $dbh = C4::Context->dbh;
	my $sth;
	if ($biblionumber) {
		$sth = $dbh->prepare("SELECT subscription.subscriptionid,biblio.title,biblioitems.issn,subscription.notes,biblio.biblionumber from subscription,biblio,biblioitems where  biblio.biblionumber = biblioitems.biblionumber and biblio.biblionumber=subscription.biblionumber and biblio.biblionumber=? order by title");
		$sth->execute($biblionumber);
	} else {
		if ($ISSN and $title)
		{
			$sth = $dbh->prepare("SELECT subscription.subscriptionid,biblio.title,biblioitems.issn,subscription.notes,biblio.biblionumber from subscription,biblio,biblioitems where  biblio.biblionumber = biblioitems.biblionumber and biblio.biblionumber=subscription.biblionumber and (biblio.title like ? or biblioitems.issn = ? order by title )");
			$sth->execute("%$title%",$ISSN);
		}
		else
		{
			if ($ISSN)
			{
				$sth = $dbh->prepare("SELECT subscription.subscriptionid,biblio.title,biblioitems.issn,subscription.notes,biblio.biblionumber from subscription,biblio,biblioitems where  biblio.biblionumber = biblioitems.biblionumber and biblio.biblionumber=subscription.biblionumber and biblioitems.issn = ? order by title");
				$sth->execute($ISSN);
			}
			else
			{
				$sth = $dbh->prepare("SELECT subscription.subscriptionid,biblio.title,biblioitems.issn,subscription.notes,biblio.biblionumber from subscription,biblio,biblioitems where  biblio.biblionumber = biblioitems.biblionumber and
 biblio.biblionumber=subscription.biblionumber and biblio.title like ?  order by title");
				$sth->execute("%$title%");
			}
		}
	}
	my @results;
	my $previoustitle="";
	my $odd=1;
	while (my $line = $sth->fetchrow_hashref) {
		if ($previoustitle eq $line->{title}) {
			$line->{title}="";
			$line->{issn}="";
			$line->{toggle} = 1 if $odd==1;
		} else {
			$previoustitle=$line->{title};
			$odd=-$odd;
			$line->{toggle} = 1 if $odd==1;
		}
		push @results, $line;
	}
	return @results;
}

sub modsubscriptionhistory {
	my ($subscriptionid,$histstartdate,$enddate,$recievedlist,$missinglist,$opacnote,$librariannote)=@_;
	my $dbh=C4::Context->dbh;
	my $sth = $dbh->prepare("
  UPDATE subscriptionhistory 
  SET histstartdate=?,enddate=?,recievedlist=?,missinglist=?,opacnote=?,librariannote=? 
  WHERE subscriptionid=?");
	$recievedlist =~ s/^,//g;
	$missinglist =~ s/^,//g;
	$opacnote =~ s/^,//g;
	$sth->execute($histstartdate,$enddate,$recievedlist,$missinglist,$opacnote,$librariannote,$subscriptionid);
}

# get every serial not arrived for a given subscription
# as well as the number of issues registered in the database (all types)
# this number is used to see if a subscription can be deleted (=it must have only 1 issue)
sub getserials {
	my ($subscriptionid) = @_;
	my $dbh = C4::Context->dbh;
	# OK, now add the last 5 issues arrives/missing
	my $sth=$dbh->prepare("select serialid,serialseq, status, planneddate,notes from serial where subscriptionid = ? and (status in (2,4,5)) order by serialid desc");
	$sth->execute($subscriptionid);
	my $counter=0;
	my @serials;
	while((my $line = $sth->fetchrow_hashref) && $counter <5) {
		$counter++;
		$line->{"status".$line->{status}} = 1; # fills a "statusX" value, used for template status select list
		$line->{"planneddate"} = format_date($line->{"planneddate"});
		push @serials,$line;
	}
	
	# status = 2 is "arrived"
	my $sth=$dbh->prepare("
  SELECT serialid,serialseq, status, publisheddate, planneddate,notes 
  FROM serial 
  WHERE subscriptionid = ? AND status NOT IN (2,4,5)");
	$sth->execute($subscriptionid);
	while(my $line = $sth->fetchrow_hashref) {
		$line->{"status".$line->{status}} = 1; # fills a "statusX" value, used for template status select list
		$line->{"publisheddate"} = format_date($line->{"publisheddate"});
		$line->{"planneddate"} = format_date($line->{"planneddate"});
		push @serials,$line;
	}
	$sth=$dbh->prepare("SELECT count(*) FROM serial WHERE subscriptionid=?");
	$sth->execute($subscriptionid);
	my ($totalissues) = $sth->fetchrow;
	return ($totalissues,@serials);
}

# get the $limit's latest serials arrived or missing for a given subscription
sub getlatestserials{
	my ($subscriptionid,$limit) =@_;
	my $dbh = C4::Context->dbh;
	# status = 2 is "arrived"
	my $strsth="SELECT serialid,serialseq, status, planneddate FROM serial WHERE subscriptionid = ? AND (status =2 or status=4) ORDER BY planneddate DESC LIMIT 0,$limit";
	my $sth=$dbh->prepare($strsth);
	$sth->execute($subscriptionid);
	my @serials;
	while(my $line = $sth->fetchrow_hashref) {
		$line->{"status".$line->{status}} = 1; # fills a "statusX" value, used for template status select list
		$line->{"planneddate"} = format_date($line->{"planneddate"});
		push @serials,$line;
	}
	$sth=$dbh->prepare("SELECT count(*) from serial where subscriptionid=?");
	$sth->execute($subscriptionid);
	my ($totalissues) = $sth->fetchrow;
	return \@serials;
}

sub serialchangestatus {
	my ($serialid,$serialseq, $publisheddate,$planneddate,$status,$notes)=@_;
# 	warn "($serialid,$serialseq,$planneddate,$status)";
	# 1st, get previous status : if we change from "waited" to something else, then we will have to create a new "waited" entry
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare("SELECT subscriptionid,status from serial where serialid=?");
	$sth->execute($serialid);
	my ($subscriptionid,$oldstatus) = $sth->fetchrow;
	# change status & update subscriptionhistory
	if ($status eq 6){
		delissue($serialseq, $subscriptionid) 
	}else{
		$sth = $dbh->prepare("update serial set serialseq=?,publisheddate=?,planneddate=?,status=?,notes=? where serialid = ?");
		$sth->execute($serialseq,$publisheddate,$planneddate,$status,$notes,$serialid);
		$sth = $dbh->prepare("SELECT missinglist,recievedlist from subscriptionhistory where subscriptionid=?");
		$sth->execute($subscriptionid);
		my ($missinglist,$recievedlist) = $sth->fetchrow;
		if ($status eq 2) {
			$recievedlist .= ",$serialseq";
		}
		$missinglist .= ",$serialseq" if ($status eq 4) ;
		$missinglist .= ",not issued $serialseq" if ($status eq 5);
		$sth=$dbh->prepare("update subscriptionhistory set recievedlist=?, missinglist=? where subscriptionid=?");
		$sth->execute($recievedlist,$missinglist,$subscriptionid);
	}
	# create new waited entry if needed (ie : was a "waited" and has changed)
	if ($oldstatus eq 1 && $status ne 1) {
		$sth = $dbh->prepare("SELECT * from subscription where subscriptionid = ? ");
		$sth->execute($subscriptionid);
		my $val = $sth->fetchrow_hashref;
		# next issue number
		my ($newserialseq,$newlastvalue1,$newlastvalue2,$newlastvalue3,$newinnerloop1,$newinnerloop2,$newinnerloop3) = Get_Next_Seq($val);
		# next date (calculated from actual date & frequency parameters)
		my $nextpublisheddate = Get_Next_Date($publisheddate,$val);
		newissue($newserialseq, $subscriptionid, $val->{'biblionumber'}, 1, $nextpublisheddate,0);
		$sth = $dbh->prepare("update subscription set lastvalue1=?, lastvalue2=?,lastvalue3=?,
														innerloop1=?,innerloop2=?,innerloop3=?
														where subscriptionid = ?");
		$sth->execute($newlastvalue1,$newlastvalue2,$newlastvalue3,$newinnerloop1,$newinnerloop2,$newinnerloop3,$subscriptionid);
	}
}

sub newissue {
	my ($serialseq,$subscriptionid,$biblionumber,$status, $publisheddate, $planneddate) = @_;
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare("
  INSERT INTO serial 
    (serialseq,subscriptionid,biblionumber,status,publisheddate,planneddate) 
  VALUES (?,?,?,?,?,?)");
	$sth->execute($serialseq,$subscriptionid,$biblionumber,$status,$publisheddate, $planneddate);
	$sth = $dbh->prepare("SELECT missinglist,recievedlist from subscriptionhistory where subscriptionid=?");
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
}

=head2 serialsitemize

  serialitemize($serialid, $info);
  $info is a hashref containing  barcode branch, itemcallnumber, status, location
  $serialid the serialid
=cut
sub serialsitemize {
	my ($serialid, $info) =@_;

	my $dbh= C4::Context->dbh;
	my $sth=$dbh->prepare("SELECT * from serial WHERE serialid=?");
	$sth->execute($serialid);
	my $data=$sth->fetchrow_hashref;
	my $bibid=MARCfind_MARCbibid_from_oldbiblionumber($dbh,$data->{biblionumber});
	my $fwk=MARCfind_frameworkcode($dbh,$bibid);
	if ($info->{barcode}){
		my @errors;
		my $exists = itemdata($info->{'barcode'});
		push @errors,"barcode_not_unique" if($exists);
		unless ($exists){
			my $marcrecord = MARC::Record->new();
			my ($tag,$subfield)=MARCfind_marc_from_kohafield($dbh,"items.barcode",$fwk);
# 			warn "items.barcode : $tag , $subfield";
			my $newField = MARC::Field->new(
				"$tag",'','',
				"$subfield" => $info->{barcode}
			);
			$marcrecord->insert_fields_ordered($newField);
			if ($info->{branch}){
				my ($tag,$subfield)=MARCfind_marc_from_kohafield($dbh,"items.homebranch",$fwk);
# 				warn "items.homebranch : $tag , $subfield";
				if ($marcrecord->field($tag)) {
					$marcrecord->field($tag)->add_subfields("$subfield" => $info->{branch})
				}else {
					my $newField = MARC::Field->new(
						"$tag",'','',
						"$subfield" => $info->{branch}
					);
					$marcrecord->insert_fields_ordered($newField);
				}
				my ($tag,$subfield)=MARCfind_marc_from_kohafield($dbh,"items.holdingbranch",$fwk);
# 				warn "items.holdingbranch : $tag , $subfield";
				if ($marcrecord->field($tag)) {
					$marcrecord->field($tag)->add_subfields("$subfield" => $info->{branch})
				}else {
					my $newField = MARC::Field->new(
						"$tag",'','',
						"$subfield" => $info->{branch}
					);
					$marcrecord->insert_fields_ordered($newField);
				}
			}
			if ($info->{itemcallnumber}){
				my ($tag,$subfield)=MARCfind_marc_from_kohafield($dbh,"items.itemcallnumber",$fwk);
# 				warn "items.itemcallnumber : $tag , $subfield";
				if ($marcrecord->field($tag)) {
					$marcrecord->field($tag)->add_subfields("$subfield" => $info->{itemcallnumber})
				}else {
					my $newField = MARC::Field->new(
						"$tag",'','',
						"$subfield" => $info->{itemcallnumber}
					);
					$marcrecord->insert_fields_ordered($newField);
				}
			}
			if ($info->{notes}){
				my ($tag,$subfield)=MARCfind_marc_from_kohafield($dbh,"items.itemnotes",$fwk);
# 				warn "items.itemnotes : $tag , $subfield";
				if ($marcrecord->field($tag)) {
					$marcrecord->field($tag)->add_subfields("$subfield" => $info->{notes})
				}else {
					my $newField = MARC::Field->new(
						"$tag",'','',
						"$subfield" => $info->{notes}
					);
					$marcrecord->insert_fields_ordered($newField);
				}
			}
			if ($info->{location}){
				my ($tag,$subfield)=MARCfind_marc_from_kohafield($dbh,"items.location",$fwk);
# 				warn "items.location : $tag , $subfield";
				if ($marcrecord->field($tag)) {
					$marcrecord->field($tag)->add_subfields("$subfield" => $info->{location})
				}else {
					my $newField = MARC::Field->new(
						"$tag",'','',
						"$subfield" => $info->{location}
					);
					$marcrecord->insert_fields_ordered($newField);
				}
			}
			if ($info->{status}){
				my ($tag,$subfield)=MARCfind_marc_from_kohafield($dbh,"items.notforloan",$fwk);
# 				warn "items.notforloan : $tag , $subfield";
				if ($marcrecord->field($tag)) {
					$marcrecord->field($tag)->add_subfields("$subfield" => $info->{status})
				}else {
					my $newField = MARC::Field->new(
						"$tag",'','',
						"$subfield" => $info->{status}
					);
					$marcrecord->insert_fields_ordered($newField);
				}
			}
			NEWnewitem($dbh,$marcrecord,$bibid);
			return 1;
		}
		return (0,@errors);
	}
}

sub delissue {
	my ($serialseq,$subscriptionid) = @_;
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare("delete from serial where serialseq= ? and subscriptionid= ? ");
	$sth->execute($serialseq,$subscriptionid);
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
		$resultdate=DateCalc($planneddate,"3 months");
	}
	if ($subscription->{periodicity} == 9) {
		$resultdate=DateCalc($planneddate,"6 months");
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
		my $sth = $dbh->prepare("SELECT count(*) from serial where subscriptionid=?  and planneddate>=?");
		$sth->execute($subscriptionid,$subscription->{startdate});
		my $res = $sth->fetchrow;
		if ($subscription->{numberlength}>=$res) {
			return 0;
		} else {
			return 1;
		}
	} else {
		#a little bit more tricky if based on X weeks/months : search if the latest issue waited is not after subscription startdate + duration
		my $sth = $dbh->prepare("SELECT max(planneddate) from serial where subscriptionid=?");
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
	my $sth = $dbh->prepare("SELECT * from biblio,biblioitems where biblio.biblionumber=biblioitems.biblionumber and biblio.biblionumber=?");
	$sth->execute($subscription->{biblionumber});
	my $biblio = $sth->fetchrow_hashref;
	newsuggestion($user,$subscription->{bibliotitle},$biblio->{author},$biblio->{publishercode},$biblio->{note},'','','','','',$subscription->{biblionumber});
	# renew subscription
	$sth=$dbh->prepare("update subscription set startdate=?,numberlength=?,weeklength=?,monthlength=? where subscriptionid=?");
	$sth->execute(format_date_in_iso($startdate),$numberlength,$weeklength,$monthlength, $subscriptionid);
}
END { }       # module clean-up code here (global destructor)
