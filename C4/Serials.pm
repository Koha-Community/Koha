package C4::Serials; #assumes C4/Serials.pm

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

# $Id$

use strict;
use C4::Date;
use Date::Manip;
use C4::Suggestions;
use C4::Biblio;
use C4::Search;
require Exporter;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = do { my @v = '$Revision$' =~ /\d+/g;
        shift(@v) . "." . join("_", map {sprintf "%03d", $_ } @v); };


=head1 NAME

C4::Serials - Give functions for serializing.

=head1 SYNOPSIS

  use C4::Serials;

=head1 DESCRIPTION

Give all XYZ functions

=head1 FUNCTIONS

=cut
@ISA = qw(Exporter);
@EXPORT = qw(
    &NewSubscription &ModSubscription &DelSubscription &GetSubscriptions &GetSubscription
    &CountSubscriptionFromBiblionumber &GetSubscriptionsFromBiblionumber
    &GetFullSubscriptionsFromBiblionumber &GetNextSeq
    &ModSubscriptionHistory &NewIssue &ItemizeSerials
    &GetSerials &GetLatestSerials &ModSerialStatus
    &HasSubscriptionExpired &GetSubscriptionExpirationDate &ReNewSubscription
    &GetSuppliersWithLateIssues &GetLateIssues &GetMissingIssues
    &GetDistributedTo &SetDistributedto &serialchangestatus
    &getroutinglist &delroutingmember &addroutingmember &reorder_members
    &check_routing &getsupplierbyserialid &updateClaim &removeMissingIssue &abouttoexpire
    &old_newsubscription &old_modsubscription &old_getserials &Get_Next_Date
);

=head2 GetSuppliersWithLateIssues

=over 4

%supplierlist = &GetSuppliersWithLateIssues

this function get all suppliers with late issues.

return :
the supplierlist into a hash. this hash containts id & name of the supplier

=back

=cut
sub GetSuppliersWithLateIssues {
    my $dbh = C4::Context->dbh;
    my $query = qq|
        SELECT DISTINCT id, name
        FROM            subscription, serial
        LEFT JOIN       aqbooksellers ON subscription.aqbooksellerid = aqbooksellers.id
        WHERE           subscription.subscriptionid = serial.subscriptionid
        AND             (planneddate < now() OR serial.STATUS = 3 OR serial.STATUS = 4)
    |;
    my $sth = $dbh->prepare($query);
    $sth->execute;
    my %supplierlist;
    while (my ($id,$name) = $sth->fetchrow) {
        $supplierlist{$id} = $name;
    }
    if(C4::Context->preference("RoutingSerials")){
	$supplierlist{''} = "All Suppliers";
    }
    return %supplierlist;
}

=head2 GetLateIssues

=over 4

@issuelist = &GetLateIssues($supplierid)

this function select late issues on database

return :
the issuelist into an table. Each line of this table containts a ref to a hash which it containts
name,title,planneddate,serialseq,serial.subscriptionid from tables : subscription, serial & biblio

=back

=cut
sub GetLateIssues {
    my ($supplierid) = @_;
    my $dbh = C4::Context->dbh;
    my $sth;
    if ($supplierid) {
        my $query = qq |
            SELECT     name,title,planneddate,serialseq,serial.subscriptionid
            FROM       subscription, serial, biblio
            LEFT JOIN  aqbooksellers ON subscription.aqbooksellerid = aqbooksellers.id
            WHERE      subscription.subscriptionid = serial.subscriptionid
            AND        ((planneddate < now() AND serial.STATUS =1) OR serial.STATUS = 3)
            AND        subscription.aqbooksellerid=$supplierid
            AND        biblio.biblionumber = subscription.biblionumber
            ORDER BY   title
        |;
        $sth = $dbh->prepare($query);
    } else {
        my $query = qq|
            SELECT     name,title,planneddate,serialseq,serial.subscriptionid
            FROM       subscription, serial, biblio
            LEFT JOIN  aqbooksellers ON subscription.aqbooksellerid = aqbooksellers.id
            WHERE      subscription.subscriptionid = serial.subscriptionid
            AND        ((planneddate < now() AND serial.STATUS =1) OR serial.STATUS = 3)
            AND        biblio.biblionumber = subscription.biblionumber
            ORDER BY   title
        |;
        $sth = $dbh->prepare($query);
    }
    $sth->execute;
    my @issuelist;
    my $last_title;
    my $odd=0;
    my $count=0;
    while (my $line = $sth->fetchrow_hashref) {
        $odd++ unless $line->{title} eq $last_title;
        $line->{title} = "" if $line->{title} eq $last_title;
        $last_title = $line->{title} if ($line->{title});
        $line->{planneddate} = format_date($line->{planneddate});
        $line->{'odd'} = 1 if $odd %2 ;
	$count++;
        push @issuelist,$line;
    }
    return $count,@issuelist;
}

=head2 GetSubscriptionHistoryFromSubscriptionId

=over 4

$sth = GetSubscriptionHistoryFromSubscriptionId()
this function just prepare the SQL request.
After this function, don't forget to execute it by using $sth->execute($subscriptionid)
return :
$sth = $dbh->prepare($query).

=back

=cut
sub GetSubscriptionHistoryFromSubscriptionId() {
    my $dbh = C4::Context->dbh;
    my $query = qq|
        SELECT *
        FROM   subcriptionhistory
        WHERE  subscriptionid = ?
    |;
    return $dbh->prepare($query);
}

=head2 GetSerialStatusFromSerialId

=over 4

$sth = GetSerialStatusFromSerialId();
this function just prepare the SQL request.
After this function, don't forget to execute it by using $sth->execute($serialid)
return :
$sth = $dbh->prepare($query).

=back

=cut
sub GetSerialStatusFromSerialId(){
    my $dbh = C4::Context->dbh;
    my $query = qq|
        SELECT status
        FROM   serial
        WHERE  serialid = ?
    |;
    return $dbh->prepare($query);
}


=head2 GetSubscription

=over 4

$subs = GetSubscription($subscriptionid)
this function get the subscription which has $subscriptionid as id.
return :
a hashref. This hash containts
subscription, subscriptionhistory, aqbudget.bookfundid, biblio.title

=back

=cut
sub GetSubscription {
    my ($subscriptionid) = @_;
    my $dbh = C4::Context->dbh;
    my $query =qq(
        SELECT  subscription.*,
                subscriptionhistory.*,
                aqbudget.bookfundid,
                aqbooksellers.name AS aqbooksellername,
                biblio.title AS bibliotitle
       FROM subscription
       LEFT JOIN subscriptionhistory ON subscription.subscriptionid=subscriptionhistory.subscriptionid
       LEFT JOIN aqbudget ON subscription.aqbudgetid=aqbudget.aqbudgetid
       LEFT JOIN aqbooksellers ON subscription.aqbooksellerid=aqbooksellers.id
       LEFT JOIN biblio ON biblio.biblionumber=subscription.biblionumber
       WHERE subscription.subscriptionid = ?
    );
    my $sth = $dbh->prepare($query);
    $sth->execute($subscriptionid);
    my $subs = $sth->fetchrow_hashref;
    return $subs;
}

=head2 GetSubscriptionsFromBiblionumber

=over 4

\@res = GetSubscriptionsFromBiblionumber($biblionumber)
this function get the subscription list. it reads on subscription table.
return :
table of subscription which has the biblionumber given on input arg.
each line of this table is a hashref. All hashes containt
startdate, histstartdate,opacnote,missinglist,recievedlist,periodicity,status & enddate

=back

=cut
sub GetSubscriptionsFromBiblionumber {
    my ($biblionumber) = @_;
    my $dbh = C4::Context->dbh;
    my $query = qq(
        SELECT subscription.*,
               subscriptionhistory.*,
               aqbudget.bookfundid,
               aqbooksellers.name AS aqbooksellername,
               biblio.title AS bibliotitle
       FROM subscription
       LEFT JOIN subscriptionhistory ON subscription.subscriptionid=subscriptionhistory.subscriptionid
       LEFT JOIN aqbudget ON subscription.aqbudgetid=aqbudget.aqbudgetid
       LEFT JOIN aqbooksellers ON subscription.aqbooksellerid=aqbooksellers.id
       LEFT JOIN biblio ON biblio.biblionumber=subscription.biblionumber
       WHERE subscription.biblionumber = ?
    );
    my $sth = $dbh->prepare($query);
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
=head2 GetFullSubscriptionsFromBiblionumber

=over 4

   \@res = GetFullSubscriptionsFromBiblionumber($biblionumber)
   this function read on serial table.

=back

=cut
sub GetFullSubscriptionsFromBiblionumber {
    my ($biblionumber) = @_;
    my $dbh = C4::Context->dbh;
    my $query=qq|
                SELECT  serial.serialseq,
                        serial.planneddate,
                        serial.publisheddate,
                        serial.status,
                        serial.notes,
                        year(serial.publisheddate) AS year,
                        aqbudget.bookfundid,aqbooksellers.name AS aqbooksellername,
                        biblio.title AS bibliotitle
                FROM serial
                LEFT JOIN subscription ON
                    (serial.subscriptionid=subscription.subscriptionid AND subscription.biblionumber=serial.biblionumber)
                LEFT JOIN aqbudget ON subscription.aqbudgetid=aqbudget.aqbudgetid 
                LEFT JOIN aqbooksellers on subscription.aqbooksellerid=aqbooksellers.id
                LEFT JOIN biblio on biblio.biblionumber=subscription.biblionumber
                WHERE subscription.biblionumber = ?
                ORDER BY year,serial.publisheddate,serial.subscriptionid,serial.planneddate
    |;

    my $sth = $dbh->prepare($query);
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
        } else {
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


=head2 GetSubscriptions

=over 4

@results = GetSubscriptions($title,$ISSN,$biblionumber);
this function get all subscriptions which has title like $title,ISSN like $ISSN and biblionumber like $biblionumber.
return:
a table of hashref. Each hash containt the subscription.

=back

=cut
sub GetSubscriptions {
    my ($title,$ISSN,$biblionumber) = @_;
    return unless $title or $ISSN or $biblionumber;
    my $dbh = C4::Context->dbh;
    my $sth;
    if ($biblionumber) {
        my $query = qq(
            SELECT subscription.subscriptionid,biblio.title,biblioitems.issn,subscription.notes,biblio.biblionumber
            FROM   subscription,biblio,biblioitems
            WHERE   biblio.biblionumber = biblioitems.biblionumber
                AND biblio.biblionumber = subscription.biblionumber
                AND biblio.biblionumber=?
            ORDER BY title
        );
    $sth = $dbh->prepare($query);
    $sth->execute($biblionumber);
    } else {
        if ($ISSN and $title){
            my $query = qq|
                SELECT subscription.subscriptionid,biblio.title,biblioitems.issn,subscription.notes,biblio.biblionumber
                FROM   subscription,biblio,biblioitems
                WHERE  biblio.biblionumber = biblioitems.biblionumber
                    AND biblio.biblionumber= subscription.biblionumber
                    AND (biblio.title LIKE ? or biblioitems.issn = ?)
                ORDER BY title
            |;
            $sth = $dbh->prepare($query);
            $sth->execute("%$title%",$ISSN);
        }
        else{
            if ($ISSN){
                my $query = qq(
                    SELECT subscription.subscriptionid,biblio.title,biblioitems.issn,subscription.notes,biblio.biblionumber
                    FROM   subscription,biblio,biblioitems
                    WHERE  biblio.biblionumber = biblioitems.biblionumber
                        AND biblio.biblionumber=subscription.biblionumber
                        AND biblioitems.issn = ?
                    ORDER BY title
                );
                $sth = $dbh->prepare($query);
                $sth->execute($ISSN);
            } else {
                my $query = qq(
                    SELECT subscription.subscriptionid,biblio.title,biblioitems.issn,subscription.notes,biblio.biblionumber
                    FROM   subscription,biblio,biblioitems
                    WHERE  biblio.biblionumber = biblioitems.biblionumber
                        AND biblio.biblionumber=subscription.biblionumber
                        AND biblio.title LIKE ?
                    ORDER BY title
                );
                $sth = $dbh->prepare($query);
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

=head2 GetSerials

=over 4

($totalissues,@serials) = GetSerials($subscriptionid);
this function get every serial not arrived for a given subscription
as well as the number of issues registered in the database (all types)
this number is used to see if a subscription can be deleted (=it must have only 1 issue)

=back

=cut
sub GetSerials {
    my ($subscriptionid) = @_;
    my $dbh = C4::Context->dbh;
    # OK, now add the last 5 issues arrives/missing
    my $query = qq|
        SELECT   serialid,serialseq, status, planneddate,notes
        FROM     serial
        WHERE    subscriptionid = ?
        AND      (status in (2,4,5))
        ORDER BY serialid DESC
    |;
    my $sth=$dbh->prepare($query);
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
    my $query = qq|
        SELECT serialid,serialseq, status, publisheddate, planneddate,notes 
        FROM   serial
        WHERE  subscriptionid = ? AND status NOT IN (2,4,5)
    |;
    my $sth=$dbh->prepare($query);
    $sth->execute($subscriptionid);
    while(my $line = $sth->fetchrow_hashref) {
        $line->{"status".$line->{status}} = 1; # fills a "statusX" value, used for template status select list
        $line->{"publisheddate"} = format_date($line->{"publisheddate"});
        $line->{"planneddate"} = format_date($line->{"planneddate"});
        push @serials,$line;
    }
    my $query = qq|
        SELECT count(*)
        FROM   serial
        WHERE  subscriptionid=?
    |;
    $sth=$dbh->prepare($query);
    $sth->execute($subscriptionid);
    my ($totalissues) = $sth->fetchrow;
    return ($totalissues,@serials);
}

=head2 GetLatestSerials

=over 4

\@serials = GetLatestSerials($subscriptionid,$limit)
get the $limit's latest serials arrived or missing for a given subscription
return :
a ref to a table which it containts all of the latest serials stored into a hash.

=back

=cut
sub GetLatestSerials {
    my ($subscriptionid,$limit) = @_;
    my $dbh = C4::Context->dbh;
    # status = 2 is "arrived"
    my $strsth=qq(
        SELECT   serialid,serialseq, status, planneddate
        FROM     serial
        WHERE    subscriptionid = ?
        AND      (status =2 or status=4)
        ORDER BY planneddate DESC LIMIT 0,$limit
    );
    my $sth=$dbh->prepare($strsth);
    $sth->execute($subscriptionid);
    my @serials;
    while(my $line = $sth->fetchrow_hashref) {
        $line->{"status".$line->{status}} = 1; # fills a "statusX" value, used for template status select list
        $line->{"planneddate"} = format_date($line->{"planneddate"});
        push @serials,$line;
    }
#     my $query = qq|
#         SELECT count(*)
#         FROM   serial
#         WHERE  subscriptionid=?
#     |;
#     $sth=$dbh->prepare($query);
#     $sth->execute($subscriptionid);
#     my ($totalissues) = $sth->fetchrow;
    return \@serials;
}

=head2 GetDistributedTo

=over 4

$distributedto=GetDistributedTo($subscriptionid)
This function select the old previous value of distributedto in the database.

=back

=cut
sub GetDistributedTo {
    my $dbh = C4::Context->dbh;
    my $distributedto;
    my $subscriptionid = @_;
    my $query = qq|
        SELECT distributedto
        FROM   subscription
        WHERE  subscriptionid=?
    |;
    my $sth = $dbh->prepare($query);
    $sth->execute($subscriptionid);
    return ($distributedto) = $sth->fetchrow;
}

=head2 GetNextSeq

=over 4

GetNextSeq($val)
$val is a hashref containing all the attributes of the table 'subscription'
This function get the next issue for the subscription given on input arg
return:
all the input params updated.

=back

=cut
sub GetNextSeq {
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


sub New_Get_Next_Seq {
    my ($val) =@_;
    my ($calculated,$newlastvalue1,$newlastvalue2,$newlastvalue3,$newinnerloop1,$newinnerloop2,$newinnerloop3);
    my $pattern = $val->{numberpattern};
    my @seasons = ('nothing','Winter','Spring','Summer','Autumn');
    my @southern_seasons = ('','Summer','Autumn','Winter','Spring');
    $calculated = $val->{numberingmethod};
    $newlastvalue1 = $val->{lastvalue1};
    $newlastvalue2 = $val->{lastvalue2};
    $newlastvalue3 = $val->{lastvalue3};
    if($newlastvalue3 > 0){ # if x y and z columns are used
	$newlastvalue3 = $newlastvalue3+1;
	if($newlastvalue3 > $val->{whenmorethan3}){
	    $newlastvalue3 = $val->{setto3};
	    $newlastvalue2++;
	    if($newlastvalue2 > $val->{whenmorethan2}){
		$newlastvalue1++;
		$newlastvalue2 = $val->{setto2};
	    }
	}
	$calculated =~ s/\{X\}/$newlastvalue1/g;
	if($pattern == 6){
	    if($val->{hemisphere} == 2){
		my $newlastvalue2seq = $southern_seasons[$newlastvalue2];
		$calculated =~ s/\{Y\}/$newlastvalue2seq/g;
	    } else {
		my $newlastvalue2seq = $seasons[$newlastvalue2];
		$calculated =~ s/\{Y\}/$newlastvalue2seq/g;
	    }
	} else {
	    $calculated =~ s/\{Y\}/$newlastvalue2/g;
	}
	$calculated =~ s/\{Z\}/$newlastvalue3/g;
    }
    if($newlastvalue2 > 0 && $newlastvalue3 < 1){ # if x and y columns are used
	$newlastvalue2 = $newlastvalue2+1;
	if($newlastvalue2 > $val->{whenmorethan2}){
	    $newlastvalue2 = $val->{setto2};
	    $newlastvalue1++;
	}
	$calculated =~ s/\{X\}/$newlastvalue1/g;
	if($pattern == 6){
	    if($val->{hemisphere} == 2){
		my $newlastvalue2seq = $southern_seasons[$newlastvalue2];
		$calculated =~ s/\{Y\}/$newlastvalue2seq/g;
	    } else {
		my $newlastvalue2seq = $seasons[$newlastvalue2];
		$calculated =~ s/\{Y\}/$newlastvalue2seq/g;
	    }
	} else {
	    $calculated =~ s/\{Y\}/$newlastvalue2/g;
	}
    }
    if($newlastvalue1 > 0 && $newlastvalue2 < 1 && $newlastvalue3 < 1){ # if column x only
	$newlastvalue1 = $newlastvalue1+1;
	if($newlastvalue1 > $val->{whenmorethan1}){
	    $newlastvalue1 = $val->{setto2};
	}
	$calculated =~ s/\{X\}/$newlastvalue1/g;
    }
    return ($calculated,$newlastvalue1,$newlastvalue2,$newlastvalue3);
}


=head2 GetNextDate

=over 4

$resultdate = GetNextDate($planneddate,$subscription)

this function get the date after $planneddate.
return:
the date on ISO format.

=back

=cut
sub GetNextDate(@) {
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

=head2 GetSeq

=over 4

$calculated = GetSeq($val)
$val is a hashref containing all the attributes of the table 'subscription'
this function transforms {X},{Y},{Z} to 150,0,0 for example.
return:
the sequence in integer format

=back

=cut
sub GetSeq {
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

=head2 GetSubscriptionExpirationDate

=over 4

$sensddate = GetSubscriptionExpirationDate($subscriptionid)

this function return the expiration date for a subscription given on input args.

return
the enddate

=back

=cut
sub GetSubscriptionExpirationDate {
    my ($subscriptionid) = @_;
    my $dbh = C4::Context->dbh;
    my $subscription = GetSubscription($subscriptionid);
    my $enddate=$subscription->{startdate};
    # we don't do the same test if the subscription is based on X numbers or on X weeks/months
    if ($subscription->{numberlength}) {
        #calculate the date of the last issue.
        for (my $i=1;$i<=$subscription->{numberlength};$i++) {
            $enddate = GetNextDate($enddate,$subscription);
        }
    }
    else {
        $enddate = DateCalc(format_date_in_iso($subscription->{startdate}),$subscription->{monthlength}." months") if ($subscription->{monthlength});
        $enddate = DateCalc(format_date_in_iso($subscription->{startdate}),$subscription->{weeklength}." weeks") if ($subscription->{weeklength});
    }
    return $enddate;
}

=head2 CountSubscriptionFromBiblionumber

=over 4

$subscriptionsnumber = CountSubscriptionFromBiblionumber($biblionumber)
this count the number of subscription for a biblionumber given.
return :
the number of subscriptions with biblionumber given on input arg.

=back

=cut
sub CountSubscriptionFromBiblionumber {
    my ($biblionumber) = @_;
    my $dbh = C4::Context->dbh;
    my $query = qq|
        SELECT count(*)
        FROM   subscription
        WHERE  biblionumber=?
    |;
    my $sth = $dbh->prepare($query);
    $sth->execute($biblionumber);
    my $subscriptionsnumber = $sth->fetchrow;
    return $subscriptionsnumber;
}


=head2 ModSubscriptionHistory

=over 4

ModSubscriptionHistory($subscriptionid,$histstartdate,$enddate,$recievedlist,$missinglist,$opacnote,$librariannote);

this function modify the history of a subscription. Put your new values on input arg.

=back

=cut
sub ModSubscriptionHistory {
    my ($subscriptionid,$histstartdate,$enddate,$recievedlist,$missinglist,$opacnote,$librariannote)=@_;
    my $dbh=C4::Context->dbh;
    my $query = qq(
        UPDATE subscriptionhistory 
        SET histstartdate=?,enddate=?,recievedlist=?,missinglist=?,opacnote=?,librariannote=?
        WHERE subscriptionid=?
    );
    my $sth = $dbh->prepare($query);
    $recievedlist =~ s/^,//g;
    $missinglist =~ s/^,//g;
    $opacnote =~ s/^,//g;
    $sth->execute($histstartdate,$enddate,$recievedlist,$missinglist,$opacnote,$librariannote,$subscriptionid);
}

=head2 ModSerialStatus

=over 4

ModSerialStatus($serialid,$serialseq, $publisheddate,$planneddate,$status,$notes)

This function modify the serial status. Serial status is a number.(eg 2 is "arrived")
Note : if we change from "waited" to something else,then we will have to create a new "waited" entry

=back

=cut
sub ModSerialStatus {
    my ($serialid,$serialseq, $publisheddate,$planneddate,$status,$notes)=@_;
    # 1st, get previous status :
    my $dbh = C4::Context->dbh;
    my $query = qq|
        SELECT subscriptionid,status
        FROM   serial
        WHERE  serialid=?
    |;
    my $sth = $dbh->prepare($query);
    $sth->execute($serialid);
    my ($subscriptionid,$oldstatus) = $sth->fetchrow;
    # change status & update subscriptionhistory
    if ($status eq 6){
        DelIssue($serialseq, $subscriptionid)
    } else {
        my $query = qq(
            UPDATE serial
            SET    serialseq=?,publisheddate=?,planneddate=?,status=?,notes=?
            WHERE  serialid = ?
        );
        $sth = $dbh->prepare($query);
        $sth->execute($serialseq,$publisheddate,$planneddate,$status,$notes,$serialid);
        my $query = qq(
            SELECT missinglist,recievedlist
            FROM   subscriptionhistory
            WHERE  subscriptionid=?
        );
        $sth = $dbh->prepare($query);
        $sth->execute($subscriptionid);
        my ($missinglist,$recievedlist) = $sth->fetchrow;
        if ($status eq 2) {
            $recievedlist .= ",$serialseq";
        }
        $missinglist .= ",$serialseq" if ($status eq 4) ;
        $missinglist .= ",not issued $serialseq" if ($status eq 5);
        my $query = qq(
            UPDATE subscriptionhistory
            SET    recievedlist=?, missinglist=?
            WHERE  subscriptionid=?
        );
        $sth=$dbh->prepare($query);
        $sth->execute($recievedlist,$missinglist,$subscriptionid);
    }
    # create new waited entry if needed (ie : was a "waited" and has changed)
    if ($oldstatus eq 1 && $status ne 1) {
        my $query = qq(
            SELECT *
            FROM   subscription
            WHERE  subscriptionid = ?
        );
        $sth = $dbh->prepare($query);
        $sth->execute($subscriptionid);
        my $val = $sth->fetchrow_hashref;
        # next issue number
        my ($newserialseq,$newlastvalue1,$newlastvalue2,$newlastvalue3,$newinnerloop1,$newinnerloop2,$newinnerloop3) = GetNextSeq($val);
        # next date (calculated from actual date & frequency parameters)
        my $nextpublisheddate = GetNextDate($publisheddate,$val);
        NewIssue($newserialseq, $subscriptionid, $val->{'biblionumber'}, 1, $nextpublisheddate,0);
        my $query = qq|
            UPDATE subscription
            SET    lastvalue1=?, lastvalue2=?, lastvalue3=?,
                   innerloop1=?, innerloop2=?, innerloop3=?
            WHERE  subscriptionid = ?
        |;
        $sth = $dbh->prepare($query);
        $sth->execute($newlastvalue1,$newlastvalue2,$newlastvalue3,$newinnerloop1,$newinnerloop2,$newinnerloop3,$subscriptionid);
    }
}

=head2 ModSubscription

=over 4

this function modify a subscription. Put all new values on input args.

=back

=cut
sub ModSubscription {
    my ($auser,$aqbooksellerid,$cost,$aqbudgetid,$startdate,
        $periodicity,$dow,$numberlength,$weeklength,$monthlength,
        $add1,$every1,$whenmorethan1,$setto1,$lastvalue1,$innerloop1,
        $add2,$every2,$whenmorethan2,$setto2,$lastvalue2,$innerloop2,
        $add3,$every3,$whenmorethan3,$setto3,$lastvalue3,$innerloop3,
        $numberingmethod, $status, $biblionumber, $notes, $letter, $subscriptionid)= @_;
    my $dbh = C4::Context->dbh;
    my $query = qq|
        UPDATE subscription
        SET     librarian=?, aqbooksellerid=?,cost=?,aqbudgetid=?,startdate=?,
                periodicity=?,dow=?,numberlength=?,weeklength=?,monthlength=?,
                add1=?,every1=?,whenmorethan1=?,setto1=?,lastvalue1=?,innerloop1=?,
                add2=?,every2=?,whenmorethan2=?,setto2=?,lastvalue2=?,innerloop2=?,
                add3=?,every3=?,whenmorethan3=?,setto3=?,lastvalue3=?,innerloop3=?,
                numberingmethod=?, status=?, biblionumber=?, notes=?, letter=?
        WHERE subscriptionid = ?
    |;
    my $sth=$dbh->prepare($query);
    $sth->execute($auser,$aqbooksellerid,$cost,$aqbudgetid,$startdate,
        $periodicity,$dow,$numberlength,$weeklength,$monthlength,
        $add1,$every1,$whenmorethan1,$setto1,$lastvalue1,$innerloop1,
        $add2,$every2,$whenmorethan2,$setto2,$lastvalue2,$innerloop2,
        $add3,$every3,$whenmorethan3,$setto3,$lastvalue3,$innerloop3,
        $numberingmethod, $status, $biblionumber, $notes, $letter, $subscriptionid);
    $sth->finish;
}


=head2 NewSubscription

=over 4

$subscriptionid = &NewSubscription($auser,$aqbooksellerid,$cost,$aqbudgetid,$biblionumber,
    $startdate,$periodicity,$dow,$numberlength,$weeklength,$monthlength,
    $add1,$every1,$whenmorethan1,$setto1,$lastvalue1,$innerloop1,
    $add2,$every2,$whenmorethan2,$setto2,$lastvalue2,$innerloop2,
    $add3,$every3,$whenmorethan3,$setto3,$lastvalue3,$innerloop3,
    $numberingmethod, $status, $notes)

Create a new subscription with value given on input args.

return :
the id of this new subscription

=back

=cut
sub NewSubscription {
    my ($auser,$aqbooksellerid,$cost,$aqbudgetid,$biblionumber,
        $startdate,$periodicity,$dow,$numberlength,$weeklength,$monthlength,
        $add1,$every1,$whenmorethan1,$setto1,$lastvalue1,$innerloop1,
        $add2,$every2,$whenmorethan2,$setto2,$lastvalue2,$innerloop2,
        $add3,$every3,$whenmorethan3,$setto3,$lastvalue3,$innerloop3,
        $numberingmethod, $status, $notes) = @_;
    my $dbh = C4::Context->dbh;
#save subscription (insert into database)
    my $query = qq|
        INSERT INTO subscription
            (librarian,aqbooksellerid,cost,aqbudgetid,biblionumber,
            startdate,periodicity,dow,numberlength,weeklength,monthlength,
            add1,every1,whenmorethan1,setto1,lastvalue1,innerloop1,
            add2,every2,whenmorethan2,setto2,lastvalue2,innerloop2,
            add3,every3,whenmorethan3,setto3,lastvalue3,innerloop3,
            numberingmethod, status, notes)
        VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
        |;
    my $sth=$dbh->prepare($query);
    $sth->execute(
        $auser,$aqbooksellerid,$cost,$aqbudgetid,$biblionumber,
        format_date_in_iso($startdate),$periodicity,$dow,$numberlength,$weeklength,$monthlength,
        $add1,$every1,$whenmorethan1,$setto1,$lastvalue1,$innerloop1,
        $add2,$every2,$whenmorethan2,$setto2,$lastvalue2,$innerloop2,
        $add3,$every3,$whenmorethan3,$setto3,$lastvalue3,$innerloop3,
        $numberingmethod, $status, $notes);

#then create the 1st waited number
    my $subscriptionid = $dbh->{'mysql_insertid'};
    my $query = qq(
        INSERT INTO subscriptionhistory
            (biblionumber, subscriptionid, histstartdate, enddate, missinglist, recievedlist, opacnote, librariannote)
        VALUES (?,?,?,?,?,?,?,?)
        );
    $sth = $dbh->prepare($query);
    $sth->execute($biblionumber, $subscriptionid, format_date_in_iso($startdate), 0, "", "", "", $notes);

# reread subscription to get a hash (for calculation of the 1st issue number)
    my $query = qq(
        SELECT *
        FROM   subscription
        WHERE  subscriptionid = ?
    );
    $sth = $dbh->prepare($query);
    $sth->execute($subscriptionid);
    my $val = $sth->fetchrow_hashref;

# calculate issue number
    my $serialseq = GetSeq($val);
    my $query = qq|
        INSERT INTO serial
            (serialseq,subscriptionid,biblionumber,status, planneddate)
        VALUES (?,?,?,?,?)
    |;
    $sth = $dbh->prepare($query);
    $sth->execute($serialseq, $subscriptionid, $val->{'biblionumber'}, 1, format_date_in_iso($startdate));
    return $subscriptionid;
}


=head2 ReNewSubscription

=over 4

ReNewSubscription($subscriptionid,$user,$startdate,$numberlength,$weeklength,$monthlength,$note)

this function renew a subscription with values given on input args.

=back

=cut
sub ReNewSubscription {
    my ($subscriptionid,$user,$startdate,$numberlength,$weeklength,$monthlength,$note) = @_;
    my $dbh = C4::Context->dbh;
    my $subscription = GetSubscription($subscriptionid);
    my $query = qq|
        SELECT *
        FROM   biblio,biblioitems
        WHERE  biblio.biblionumber=biblioitems.biblionumber
        AND    biblio.biblionumber=?
    |;
    my $sth = $dbh->prepare($query);
    $sth->execute($subscription->{biblionumber});
    my $biblio = $sth->fetchrow_hashref;
    NewSuggestion($user,$subscription->{bibliotitle},$biblio->{author},$biblio->{publishercode},$biblio->{note},'','','','','',$subscription->{biblionumber});
    # renew subscription
    my $query = qq|
        UPDATE subscription
        SET    startdate=?,numberlength=?,weeklength=?,monthlength=?
        WHERE  subscriptionid=?
    |;
    $sth=$dbh->prepare($query);
    $sth->execute(format_date_in_iso($startdate),$numberlength,$weeklength,$monthlength, $subscriptionid);
}


=head2 NewIssue

=over 4

NewIssue($serialseq,$subscriptionid,$biblionumber,$status, $publisheddate, $planneddate)

Create a new issue stored on the database.
Note : we have to update the recievedlist and missinglist on subscriptionhistory for this subscription.

=back

=cut
sub NewIssue {
    my ($serialseq,$subscriptionid,$biblionumber,$status, $publisheddate, $planneddate) = @_;
    my $dbh = C4::Context->dbh;
    my $query = qq|
        INSERT INTO serial
            (serialseq,subscriptionid,biblionumber,status,publisheddate,planneddate)
        VALUES (?,?,?,?,?,?)
    |;
    my $sth = $dbh->prepare($query);
    $sth->execute($serialseq,$subscriptionid,$biblionumber,$status,$publisheddate, $planneddate);
    my $query = qq|
        SELECT missinglist,recievedlist
        FROM   subscriptionhistory
        WHERE  subscriptionid=?
    |;
    $sth = $dbh->prepare($query);
    $sth->execute($subscriptionid);
    my ($missinglist,$recievedlist) = $sth->fetchrow;
    if ($status eq 2) {
        $recievedlist .= ",$serialseq";
    }
    if ($status eq 4) {
        $missinglist .= ",$serialseq";
    }
    my $query = qq|
        UPDATE subscriptionhistory
        SET    recievedlist=?, missinglist=?
        WHERE  subscriptionid=?
    |;
    $sth=$dbh->prepare($query);
    $sth->execute($recievedlist,$missinglist,$subscriptionid);
}

sub serialchangestatus {
    my ($serialid,$serialseq,$planneddate,$status,$notes)=@_;
    # 1st, get previous status : if we change from "waited" to something else, then we will have to create a new "waited" entry
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("select subscriptionid,status from serial where serialid=?");
    $sth->execute($serialid);
    my ($subscriptionid,$oldstatus) = $sth->fetchrow;
    # change status & update subscriptionhistory
    if ($status eq 6){
	delissue($serialseq, $subscriptionid)
    }else{
	$sth = $dbh->prepare("update serial set serialseq=?,planneddate=?,status=?,notes=? where serialid = ?");
	$sth->execute($serialseq,$planneddate,$status,$notes,$serialid);
	$sth = $dbh->prepare("select missinglist,recievedlist from subscriptionhistory where subscriptionid=?");
	$sth->execute($subscriptionid);
	my ($missinglist,$recievedlist) = $sth->fetchrow;
	if ($status eq 2) {
	    $recievedlist .= "| $serialseq";
	    $recievedlist =~ s/^\| //g;
	}
	$missinglist .= "| $serialseq" if ($status eq 4) ;
	$missinglist .= "| not issued $serialseq" if ($status eq 5);
	$missinglist =~ s/^\| //g;
	$sth=$dbh->prepare("update subscriptionhistory set recievedlist=?, missinglist=? where subscriptionid=?");
	$sth->execute($recievedlist,$missinglist,$subscriptionid);
    }
    # create new waited entry if needed (ie : was a "waited" and has changed)
    if ($oldstatus eq 1 && $status ne 1) {
	$sth = $dbh->prepare("select * from subscription where subscriptionid = ? ");
	$sth->execute($subscriptionid);
	my $val = $sth->fetchrow_hashref;
	# next issue number
	my ($newserialseq,$newlastvalue1,$newlastvalue2,$newlastvalue3) = New_Get_Next_Seq($val);
	my $nextplanneddate = Get_Next_Date($planneddate,$val);
	newissue($newserialseq, $subscriptionid, $val->{'biblionumber'}, 1, $nextplanneddate);
	$sth = $dbh->prepare("update subscription set lastvalue1=?, lastvalue2=?,lastvalue3=? where subscriptionid = ?");
	$sth->execute($newlastvalue1,$newlastvalue2,$newlastvalue3,$subscriptionid);
    }
}


=head2 ItemizeSerials

=over 4

ItemizeSerials($serialid, $info);
$info is a hashref containing  barcode branch, itemcallnumber, status, location
$serialid the serialid
return :
1 if the itemize is a succes.
0 and @error else. @error containts the list of errors found.

=back

=cut
sub ItemizeSerials {
    my ($serialid, $info) =@_;
    my $now = ParseDate("today");
    $now = UnixDate($now,"%Y-%m-%d");

    my $dbh= C4::Context->dbh;
    my $query = qq|
        SELECT *
        FROM   serial
        WHERE  serialid=?
    |;
    my $sth=$dbh->prepare($query);
    $sth->execute($serialid);
    my $data=$sth->fetchrow_hashref;
    if(C4::Context->preference("RoutingSerials")){
        # check for existing biblioitem relating to serial issue
	my($count, @results) = getbiblioitembybiblionumber($data->{'biblionumber'});
	my $bibitemno = 0;
	for(my $i=0;$i<$count;$i++){
	    if($results[$i]->{'volumeddesc'} eq $data->{'serialseq'}.' ('.$data->{'planneddate'}.')'){
		$bibitemno = $results[$i]->{'biblioitemnumber'};
		last;
	    }
	}
	if($bibitemno == 0){
	    # warn "need to add new biblioitem so copy last one and make minor changes";
	    my $sth=$dbh->prepare("SELECT * FROM biblioitems WHERE biblionumber = ? ORDER BY biblioitemnumber DESC");
	    $sth->execute($data->{'biblionumber'});
	    my $biblioitem;
	    my $biblioitem = $sth->fetchrow_hashref;
	    $biblioitem->{'volumedate'} = format_date_in_iso($data->{planneddate});
	    $biblioitem->{'volumeddesc'} = $data->{serialseq}.' ('.format_date($data->{'planneddate'}).')';
	    $biblioitem->{'dewey'} = $info->{itemcallnumber};
	    if ($info->{barcode}){ # only make biblioitem if we are going to make item also
		$bibitemno = newbiblioitem($biblioitem);
	    }
	}
    }
	
    my $bibid=MARCfind_MARCbibid_from_oldbiblionumber($dbh,$data->{biblionumber});
    my $fwk=MARCfind_frameworkcode($dbh,$bibid);
    if ($info->{barcode}){
        my @errors;
        my $exists = itemdata($info->{'barcode'});
        push @errors,"barcode_not_unique" if($exists);
        unless ($exists){
            my $marcrecord = MARC::Record->new();
            my ($tag,$subfield)=MARCfind_marc_from_kohafield($dbh,"items.barcode",$fwk);
            my $newField = MARC::Field->new(
                "$tag",'','',
                "$subfield" => $info->{barcode}
            );
            $marcrecord->insert_fields_ordered($newField);
            if ($info->{branch}){
                my ($tag,$subfield)=MARCfind_marc_from_kohafield($dbh,"items.homebranch",$fwk);
                #warn "items.homebranch : $tag , $subfield";
                if ($marcrecord->field($tag)) {
                    $marcrecord->field($tag)->add_subfields("$subfield" => $info->{branch})
                } else {
                    my $newField = MARC::Field->new(
                        "$tag",'','',
                        "$subfield" => $info->{branch}
                    );
                    $marcrecord->insert_fields_ordered($newField);
                }
                my ($tag,$subfield)=MARCfind_marc_from_kohafield($dbh,"items.holdingbranch",$fwk);
                #warn "items.holdingbranch : $tag , $subfield";
                if ($marcrecord->field($tag)) {
                    $marcrecord->field($tag)->add_subfields("$subfield" => $info->{branch})
                } else {
                    my $newField = MARC::Field->new(
                        "$tag",'','',
                        "$subfield" => $info->{branch}
                    );
                    $marcrecord->insert_fields_ordered($newField);
                }
            }
            if ($info->{itemcallnumber}){
                my ($tag,$subfield)=MARCfind_marc_from_kohafield($dbh,"items.itemcallnumber",$fwk);
                #warn "items.itemcallnumber : $tag , $subfield";
                if ($marcrecord->field($tag)) {
                    $marcrecord->field($tag)->add_subfields("$subfield" => $info->{itemcallnumber})
                } else {
                    my $newField = MARC::Field->new(
                        "$tag",'','',
                        "$subfield" => $info->{itemcallnumber}
                    );
                    $marcrecord->insert_fields_ordered($newField);
                }
            }
            if ($info->{notes}){
                my ($tag,$subfield)=MARCfind_marc_from_kohafield($dbh,"items.itemnotes",$fwk);
                # warn "items.itemnotes : $tag , $subfield";
                if ($marcrecord->field($tag)) {
                    $marcrecord->field($tag)->add_subfields("$subfield" => $info->{notes})
                } else {
                    my $newField = MARC::Field->new(
                    "$tag",'','',
                    "$subfield" => $info->{notes}
                );
                    $marcrecord->insert_fields_ordered($newField);
                }
            }
            if ($info->{location}){
                my ($tag,$subfield)=MARCfind_marc_from_kohafield($dbh,"items.location",$fwk);
                # warn "items.location : $tag , $subfield";
                if ($marcrecord->field($tag)) {
                    $marcrecord->field($tag)->add_subfields("$subfield" => $info->{location})
                } else {
                    my $newField = MARC::Field->new(
                        "$tag",'','',
                        "$subfield" => $info->{location}
                    );
                    $marcrecord->insert_fields_ordered($newField);
                }
            }
            if ($info->{status}){
                my ($tag,$subfield)=MARCfind_marc_from_kohafield($dbh,"items.notforloan",$fwk);
                # warn "items.notforloan : $tag , $subfield";
                if ($marcrecord->field($tag)) {
                $marcrecord->field($tag)->add_subfields("$subfield" => $info->{status})
                } else {
                    my $newField = MARC::Field->new(
                        "$tag",'','',
                        "$subfield" => $info->{status}
                    );
                    $marcrecord->insert_fields_ordered($newField);
                }
            }
	    if(C4::Context->preference("RoutingSerials")){
		my ($tag,$subfield)=MARCfind_marc_from_kohafield($dbh,"items.dateaccessioned",$fwk);
		if ($marcrecord->field($tag)) {
		    $marcrecord->field($tag)->add_subfields("$subfield" => $now)
		} else {
		    my $newField = MARC::Field->new(
			"$tag",'','',
			"$subfield" => $now
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

=head2 HasSubscriptionExpired

=over 4

1 or 0 = HasSubscriptionExpired($subscriptionid)

the subscription has expired when the next issue to arrive is out of subscription limit.

return :
1 if true, 0 if false.

=back

=cut
sub HasSubscriptionExpired {
    my ($subscriptionid) = @_;
    my $dbh = C4::Context->dbh;
    my $subscription = GetSubscription($subscriptionid);
    # we don't do the same test if the subscription is based on X numbers or on X weeks/months
    if ($subscription->{numberlength}) {
        my $query = qq|
            SELECT count(*)
            FROM   serial
            WHERE  subscriptionid=? AND planneddate>=?
        |;
        my $sth = $dbh->prepare($query);
        $sth->execute($subscriptionid,$subscription->{startdate});
        my $res = $sth->fetchrow;
        if ($subscription->{numberlength}>=$res) {
            return 0;
        } else {
            return 1;
        }
    } else {
        #a little bit more tricky if based on X weeks/months : search if the latest issue waited is not after subscription startdate + duration
        my $query = qq|
            SELECT max(planneddate)
            FROM   serial
            WHERE  subscriptionid=?
        |;
        my $sth = $dbh->prepare($query);
        $sth->execute($subscriptionid);
        my $res = ParseDate(format_date_in_iso($sth->fetchrow));
        my $endofsubscriptiondate;
        $endofsubscriptiondate = DateCalc(format_date_in_iso($subscription->{startdate}),$subscription->{monthlength}." months") if ($subscription->{monthlength});
        $endofsubscriptiondate = DateCalc(format_date_in_iso($subscription->{startdate}),$subscription->{weeklength}." weeks") if ($subscription->{weeklength});
        return 1 if ($res >= $endofsubscriptiondate);
        return 0;
    }
}

=head2 SetDistributedto

=over 4

SetDistributedto($distributedto,$subscriptionid);
This function update the value of distributedto for a subscription given on input arg.

=back

=cut
sub SetDistributedto {
    my ($distributedto,$subscriptionid) = @_;
    my $dbh = C4::Context->dbh;
    my $query = qq|
        UPDATE subscription
        SET    distributedto=?
        WHERE  subscriptionid=?
    |;
    my $sth = $dbh->prepare($query);
    $sth->execute($distributedto,$subscriptionid);
}

=head2 DelSubscription

=over 4

DelSubscription($subscriptionid)
this function delete the subscription which has $subscriptionid as id.

=back

=cut
sub DelSubscription {
    my ($subscriptionid) = @_;
    my $dbh = C4::Context->dbh;
    $subscriptionid=$dbh->quote($subscriptionid);
    $dbh->do("DELETE FROM subscription WHERE subscriptionid=$subscriptionid");
    $dbh->do("DELETE FROM subscriptionhistory WHERE subscriptionid=$subscriptionid");
    $dbh->do("DELETE FROM serial WHERE subscriptionid=$subscriptionid");
}

=head2 DelIssue

=over 4

DelIssue($serialseq,$subscriptionid)
this function delete an issue which has $serialseq and $subscriptionid given on input arg.

=back

=cut
sub DelIssue {
    my ($serialseq,$subscriptionid) = @_;
    my $dbh = C4::Context->dbh;
    my $query = qq|
        DELETE FROM serial
        WHERE       serialseq= ?
        AND         subscriptionid= ?
    |;
    my $sth = $dbh->prepare($query);
    $sth->execute($serialseq,$subscriptionid);
}

sub GetMissingIssues {
    my ($supplierid,$serialid) = @_;
    my $dbh = C4::Context->dbh;
    my $sth;
    my $byserial='';
    if($serialid) {
	$byserial = "and serialid = ".$serialid;
    }
    if ($supplierid) {
	$sth = $dbh->prepare("SELECT serialid,aqbooksellerid,name,title,planneddate,serialseq,serial.subscriptionid,claimdate
                                  FROM subscription, serial, biblio
                                  LEFT JOIN aqbooksellers ON subscription.aqbooksellerid = aqbooksellers.id
                                  WHERE subscription.subscriptionid = serial.subscriptionid AND
                                  serial.STATUS = 4 and
                                  subscription.aqbooksellerid=$supplierid and
                                  biblio.biblionumber = subscription.biblionumber ".$byserial." order by title
                                  ");
    } else {
	$sth = $dbh->prepare("SELECT serialid,aqbooksellerid,name,title,planneddate,serialseq,serial.subscriptionid,claimdate
                                  FROM subscription, serial, biblio
                                  LEFT JOIN aqbooksellers ON subscription.aqbooksellerid = aqbooksellers.id
                                  WHERE subscription.subscriptionid = serial.subscriptionid AND
                                  serial.STATUS =4 and
                                  biblio.biblionumber = subscription.biblionumber ".$byserial." order by title
                                  ");
    }
    $sth->execute;
    my @issuelist;
    my $last_title;
    my $odd=0;
    my $count=0;
    while (my $line = $sth->fetchrow_hashref) {
	$odd++ unless $line->{title} eq $last_title;
	$last_title = $line->{title} if ($line->{title});
	$line->{planneddate} = format_date($line->{planneddate});
	$line->{claimdate} = format_date($line->{claimdate});
	$line->{'odd'} = 1 if $odd %2 ;
	$count++;
	push @issuelist,$line;
    }
    return $count,@issuelist;
}

sub removeMissingIssue {
    my ($sequence,$subscriptionid) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT * FROM subscriptionhistory WHERE subscriptionid = ?");
    $sth->execute($subscriptionid);
    my $data = $sth->fetchrow_hashref;
    my $missinglist = $data->{'missinglist'};
    my $missinglistbefore = $missinglist;
    # warn $missinglist." before";
    $missinglist =~ s/($sequence)//;
    # warn $missinglist." after";
    if($missinglist ne $missinglistbefore){
	$missinglist =~ s/\|\s\|/\|/g;
	$missinglist =~ s/^\| //g;
	$missinglist =~ s/\|$//g;
	my $sth2= $dbh->prepare("UPDATE subscriptionhistory
                                       SET missinglist = ?
                                       WHERE subscriptionid = ?");
        $sth2->execute($missinglist,$subscriptionid);
    }
}

sub updateClaim {
    my ($serialid) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("UPDATE serial SET claimdate = now()
                                   WHERE serialid = ?
                                   ");
    $sth->execute($serialid);
}

sub getsupplierbyserialid {
    my ($serialid) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT serialid, serial.subscriptionid, aqbooksellerid
                                   FROM serial, subscription
                                   WHERE serial.subscriptionid = subscription.subscriptionid
                                   AND serialid = ?
                                   ");
    $sth->execute($serialid);
    my $line = $sth->fetchrow_hashref;
    my $result = $line->{'aqbooksellerid'};
    return $result;
}

sub check_routing {
    my ($subscriptionid) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT count(routingid) routingids FROM subscriptionroutinglist, subscription
                              WHERE subscription.subscriptionid = subscriptionroutinglist.subscriptionid
                              AND subscription.subscriptionid = ? ORDER BY ranking ASC
                              ");
    $sth->execute($subscriptionid);
    my $line = $sth->fetchrow_hashref;
    my $result = $line->{'routingids'};
    return $result;
}

sub addroutingmember {
    my ($bornum,$subscriptionid) = @_;
    my $rank;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT max(ranking) rank FROM subscriptionroutinglist WHERE subscriptionid = ?");
    $sth->execute($subscriptionid);
    while(my $line = $sth->fetchrow_hashref){
	if($line->{'rank'}>0){
	    $rank = $line->{'rank'}+1;
	} else {
	    $rank = 1;
	}
    }
    $sth = $dbh->prepare("INSERT INTO subscriptionroutinglist VALUES (null,?,?,?,null)");
    $sth->execute($subscriptionid,$bornum,$rank);
}

sub reorder_members {
    my ($subscriptionid,$routingid,$rank) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT * FROM subscriptionroutinglist WHERE subscriptionid = ? ORDER BY ranking ASC");
    $sth->execute($subscriptionid);
    my @result;
    while(my $line = $sth->fetchrow_hashref){
	push(@result,$line->{'routingid'});
    }
    # To find the matching index
    my $i;
    my $key = -1; # to allow for 0 being a valid response
    for ($i = 0; $i < @result; $i++) {
	if ($routingid == $result[$i]) {
	    $key = $i; # save the index
	    last;
	}
    }
    # if index exists in array then move it to new position
    if($key > -1 && $rank > 0){
	my $new_rank = $rank-1; # $new_rank is what you want the new index to be in the array
	my $moving_item = splice(@result, $key, 1);
	splice(@result, $new_rank, 0, $moving_item);
    }
    for(my $j = 0; $j < @result; $j++){
	my $sth = $dbh->prepare("UPDATE subscriptionroutinglist SET ranking = '" . ($j+1) . "' WHERE routingid = '". $result[$j]."'");
	$sth->execute;
    }
}

sub delroutingmember {
    # if $routingid exists then deletes that row otherwise deletes all with $subscriptionid
    my ($routingid,$subscriptionid) = @_;
    my $dbh = C4::Context->dbh;
    if($routingid){
	my $sth = $dbh->prepare("DELETE FROM subscriptionroutinglist WHERE routingid = ?");
	$sth->execute($routingid);
	reorder_members($subscriptionid,$routingid);
    } else {
	my $sth = $dbh->prepare("DELETE FROM subscriptionroutinglist WHERE subscriptionid = ?");
	$sth->execute($subscriptionid);
    }
}

sub getroutinglist {
    my ($subscriptionid) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT routingid, borrowernumber,
                              ranking, biblionumber FROM subscriptionroutinglist, subscription
                              WHERE subscription.subscriptionid = subscriptionroutinglist.subscriptionid
                              AND subscription.subscriptionid = ? ORDER BY ranking ASC
                              ");
    $sth->execute($subscriptionid);
    my @routinglist;
    my $count=0;
    while (my $line = $sth->fetchrow_hashref) {
	$count++;
	push(@routinglist,$line);
    }
    return ($count,@routinglist);
}

# is the subscription about to expire? - check if penultimate issue.
sub abouttoexpire { 
    my ($subscriptionid) = @_;
    my $dbh = C4::Context->dbh;
    my $subscription = getsubscription($subscriptionid);
    # we don't do the same test if the subscription is based on X numbers or on X weeks/months
    if ($subscription->{numberlength}) {
	my $sth = $dbh->prepare("select count(*) from serial where subscriptionid=?  and planneddate>=?");
	$sth->execute($subscriptionid,$subscription->{startdate});
	my $res = $sth->fetchrow;
	warn "length: ".$subscription->{numberlength}." vs count: ".$res;
	if ($subscription->{numberlength}==$res) {
	    return 1;
	} else {
	    return 0;
	}
    } else {
	# a little bit more tricky if based on X weeks/months : search if the latest issue waited is not after subscription startdate + duration
	my $sth = $dbh->prepare("select max(planneddate) from serial where subscriptionid=?");
	$sth->execute($subscriptionid);
	my $res = ParseDate(format_date_in_iso($sth->fetchrow));
	my $endofsubscriptiondate;
	$endofsubscriptiondate = DateCalc(format_date_in_iso($subscription->{startdate}),$subscription->{monthlength}." months") if ($subscription->{monthlength});
	$endofsubscriptiondate = DateCalc(format_date_in_iso($subscription->{startdate}),$subscription->{weeklength}." weeks") if ($subscription->{weeklength});
	warn "last: ".$endofsubscriptiondate." vs currentdate: ".$res;
	my $per = $subscription->{'periodicity'};
	my $x = 0;
	if ($per == 1) { $x = '1 day'; }
	if ($per == 2) { $x = '1 week'; }
	if ($per == 3) { $x = '2 weeks'; }
	if ($per == 4) { $x = '3 weeks'; }
	if ($per == 5) { $x = '1 month'; }
	if ($per == 6) { $x = '2 months'; }
	if ($per == 7 || $per == 8) { $x = '3 months'; }
	if ($per == 9) { $x = '6 months'; }
	if ($per == 10) { $x = '1 year'; }
	if ($per == 11) { $x = '2 years'; }
	my $datebeforeend = DateCalc($endofsubscriptiondate,"- ".$x); # if ($subscription->{weeklength});
	warn "DATE BEFORE END: $datebeforeend";
	return 1 if ($res >= $datebeforeend && $res < $endofsubscriptiondate);
	return 0;
    }
}

sub old_newsubscription {
            my ($auser,$aqbooksellerid,$cost,$aqbudgetid,$biblionumber,
		                $startdate,$periodicity,$firstacquidate,$dow,$irregularity,$numberpattern,$numberlength,$weeklength,$monthlength,
		                $add1,$every1,$whenmorethan1,$setto1,$lastvalue1,
		                $add2,$every2,$whenmorethan2,$setto2,$lastvalue2,
		                $add3,$every3,$whenmorethan3,$setto3,$lastvalue3,
		                $numberingmethod, $status, $callnumber, $notes, $hemisphere) = @_;
            my $dbh = C4::Context->dbh;
            #save subscription
            my $sth=$dbh->prepare("insert into subscription (librarian,aqbooksellerid,cost,aqbudgetid,biblionumber,
		                                                startdate,periodicity,firstacquidate,dow,irregularity,numberpattern,numberlength,weeklength,monthlength,
		                                                        add1,every1,whenmorethan1,setto1,lastvalue1,
		                                                        add2,every2,whenmorethan2,setto2,lastvalue2,
		                                                        add3,every3,whenmorethan3,setto3,lastvalue3,
		                                                        numberingmethod, status, callnumber, notes, hemisphere) values
                                                          (?,?,?,?,?,?,?,?,?,?,?,
							                                                               ?,?,?,?,?,?,?,?,?,?,?,
							                                                               ?,?,?,?,?,?,?,?,?,?,?,?)");
        $sth->execute($auser,$aqbooksellerid,$cost,$aqbudgetid,$biblionumber,
	    format_date_in_iso($startdate),$periodicity,format_date_in_iso($firstacquidate),$dow,$irregularity,$numberpattern,$numberlength,$weeklength,$monthlength,
	                                            $add1,$every1,$whenmorethan1,$setto1,$lastvalue1,
	                                            $add2,$every2,$whenmorethan2,$setto2,$lastvalue2,
	                                            $add3,$every3,$whenmorethan3,$setto3,$lastvalue3,
	                                            $numberingmethod, $status,$callnumber, $notes, $hemisphere);
        #then create the 1st waited number
        my $subscriptionid = $dbh->{'mysql_insertid'};
        my $enddate = subscriptionexpirationdate($subscriptionid);

        $sth = $dbh->prepare("insert into subscriptionhistory (biblionumber, subscriptionid, histstartdate, enddate, missinglist, recievedlist, opacnote, librariannote) values (?,?,?,?,?,?,?,?)");
        $sth->execute($biblionumber, $subscriptionid, format_date_in_iso($startdate), format_date_in_iso($enddate), "", "", "", $notes);
        # reread subscription to get a hash (for calculation of the 1st issue number)
        $sth = $dbh->prepare("select * from subscription where subscriptionid = ? ");
        $sth->execute($subscriptionid);
        my $val = $sth->fetchrow_hashref;

        # calculate issue number
        my $serialseq = Get_Seq($val);
        $sth = $dbh->prepare("insert into serial (serialseq,subscriptionid,biblionumber,status, planneddate) values (?,?,?,?,?)");
        $sth->execute($serialseq, $subscriptionid, $val->{'biblionumber'}, 1, format_date_in_iso($startdate));
        return $subscriptionid;
}

sub old_modsubscription {
            my ($auser,$aqbooksellerid,$cost,$aqbudgetid,$startdate,
		                                        $periodicity,$firstacquidate,$dow,$irregularity,$numberpattern,$numberlength,$weeklength,$monthlength,
		                                        $add1,$every1,$whenmorethan1,$setto1,$lastvalue1,$innerloop1,
		                                        $add2,$every2,$whenmorethan2,$setto2,$lastvalue2,$innerloop2,
		                                        $add3,$every3,$whenmorethan3,$setto3,$lastvalue3,$innerloop3,
		                                        $numberingmethod, $status, $biblionumber, $callnumber, $notes, $hemisphere, $subscriptionid)= @_;
            my $dbh = C4::Context->dbh;
            my $sth=$dbh->prepare("update subscription set librarian=?, aqbooksellerid=?,cost=?,aqbudgetid=?,startdate=?,
                                                   periodicity=?,firstacquidate=?,dow=?,irregularity=?,numberpattern=?,numberlength=?,weeklength=?,monthlength=?,
                                                  add1=?,every1=?,whenmorethan1=?,setto1=?,lastvalue1=?,innerloop1=?,
                                                  add2=?,every2=?,whenmorethan2=?,setto2=?,lastvalue2=?,innerloop2=?,
                                                  add3=?,every3=?,whenmorethan3=?,setto3=?,lastvalue3=?,innerloop3=?,
                                                  numberingmethod=?, status=?, biblionumber=?, callnumber=?, notes=?, hemisphere=? where subscriptionid = ?");
        $sth->execute($auser,$aqbooksellerid,$cost,$aqbudgetid,$startdate,
	                                            $periodicity,$firstacquidate,$dow,$irregularity,$numberpattern,$numberlength,$weeklength,$monthlength,
	                                            $add1,$every1,$whenmorethan1,$setto1,$lastvalue1,$innerloop1,
	                                            $add2,$every2,$whenmorethan2,$setto2,$lastvalue2,$innerloop2,
	                                            $add3,$every3,$whenmorethan3,$setto3,$lastvalue3,$innerloop3,
	                                            $numberingmethod, $status, $biblionumber, $callnumber, $notes, $hemisphere, $subscriptionid);
        $sth->finish;


        $sth = $dbh->prepare("select * from subscription where subscriptionid = ? ");
        $sth->execute($subscriptionid);
        my $val = $sth->fetchrow_hashref;

        # calculate issue number
        my $serialseq = Get_Seq($val);
        $sth = $dbh->prepare("UPDATE serial SET serialseq = ? WHERE subscriptionid = ?");
        $sth->execute($serialseq,$subscriptionid);

        my $enddate = subscriptionexpirationdate($subscriptionid);
        $sth = $dbh->prepare("update subscriptionhistory set enddate=?");
        $sth->execute(format_date_in_iso($enddate));
}

sub old_getserials {
            my ($subscriptionid) = @_;
            my $dbh = C4::Context->dbh;
            # status = 2 is "arrived"
            my $sth=$dbh->prepare("select serialid,serialseq, status, planneddate,notes,routingnotes from serial where subscriptionid = ? and status <>2 and status <>4 and status <>5");    
          $sth->execute($subscriptionid);
        my @serials;
        my $num = 1;
        while(my $line = $sth->fetchrow_hashref) {
	                    $line->{"status".$line->{status}} = 1; # fills a "statusX" value, used for template status select list
	                    $line->{"planneddate"} = format_date($line->{"planneddate"});
	                    $line->{"num"} = $num;
	                    $num++;
	                    push @serials,$line;
	            }
        $sth=$dbh->prepare("select count(*) from serial where subscriptionid=?");
        $sth->execute($subscriptionid);
        my ($totalissues) = $sth->fetchrow;
        return ($totalissues,@serials);
}

sub Get_Next_Date(@) {
    my ($planneddate,$subscription) = @_;
    my @irreg = split(/\|/,$subscription->{irregularity});

    my ($year, $month, $day) = UnixDate($planneddate, "%Y", "%m", "%d");
    my $dayofweek = Date_DayOfWeek($month,$day,$year);
    my $resultdate;
    #       warn "DOW $dayofweek";
    if ($subscription->{periodicity} == 1) {
	for(my $i=0;$i<@irreg;$i++){
	    if($dayofweek == 7){ $dayofweek = 0; }
	    if(in_array(($dayofweek+1), @irreg)){
		$planneddate = DateCalc($planneddate,"1 day");
		$dayofweek++;
	    }
	}
	$resultdate=DateCalc($planneddate,"1 day");
    }
    if ($subscription->{periodicity} == 2) {
	my $wkno = Date_WeekOfYear($month,$day,$year,1);
	for(my $i = 0;$i < @irreg; $i++){
	    if($wkno > 52) { $wkno = 0; } # need to rollover at January
	    if($irreg[$i] == ($wkno+1)){
		$planneddate = DateCalc($planneddate,"1 week");
		$wkno++;
	    }
	}
	$resultdate=DateCalc($planneddate,"1 week");
    }
    if ($subscription->{periodicity} == 3) {
	my $wkno = Date_WeekOfYear($month,$day,$year,1);
	for(my $i = 0;$i < @irreg; $i++){
	    if($wkno > 52) { $wkno = 0; } # need to rollover at January
	    if($irreg[$i] == ($wkno+1)){
		$planneddate = DateCalc($planneddate,"2 weeks");
		$wkno++;
	    }
	}
	$resultdate=DateCalc($planneddate,"2 weeks");
    }
    if ($subscription->{periodicity} == 4) {
	my $wkno = Date_WeekOfYear($month,$day,$year,1);
	for(my $i = 0;$i < @irreg; $i++){
	    if($wkno > 52) { $wkno = 0; } # need to rollover at January
	    if($irreg[$i] == ($wkno+1)){
		$planneddate = DateCalc($planneddate,"3 weeks");
		$wkno++;
	    }
	}
	$resultdate=DateCalc($planneddate,"3 weeks");
    }
    if ($subscription->{periodicity} == 5) {
	for(my $i = 0;$i < @irreg; $i++){
	    # warn $irreg[$i];
	    # warn $month;
	    if($month == 12) { $month = 0; } # need to rollover to check January
	    if($irreg[$i] == ($month+1)){ # check next one to see if is to be skipped
		$planneddate = DateCalc($planneddate,"1 month");
		$month++; # to check if following ones are to be skipped too
	    }
	}
	$resultdate=DateCalc($planneddate,"1 month");
	# warn "Planneddate2: $planneddate";
    }
    if ($subscription->{periodicity} == 6) {
	for(my $i = 0;$i < @irreg; $i++){
	    if($month == 12) { $month = 0; } # need to rollover to check January
	    if($irreg[$i] == ($month+1)){ # check next one to see if is to be skipped
		$planneddate = DateCalc($planneddate,"2 months");
		$month++; # to check if following ones are to be skipped too
	    }
	}
	$resultdate=DateCalc($planneddate,"2 months");
    }
    if ($subscription->{periodicity} == 7) {
	for(my $i = 0;$i < @irreg; $i++){
	    if($month == 12) { $month = 0; } # need to rollover to check January
	    if($irreg[$i] == ($month+1)){ # check next one to see if is to be skipped
		$planneddate = DateCalc($planneddate,"3 months");
		$month++; # to check if following ones are to be skipped too
	    }
	}
	$resultdate=DateCalc($planneddate,"3 months");
    }
    if ($subscription->{periodicity} == 8) {
	for(my $i = 0;$i < @irreg; $i++){
	    if($month == 12) { $month = 0; } # need to rollover to check January
	    if($irreg[$i] == ($month+1)){ # check next one to see if is to be skipped
		$planneddate = DateCalc($planneddate,"3 months");
		$month++; # to check if following ones are to be skipped too
	    }
	}
	$resultdate=DateCalc($planneddate,"3 months");
    }
    if ($subscription->{periodicity} == 9) {
	for(my $i = 0;$i < @irreg; $i++){
	    if($month == 12) { $month = 0; } # need to rollover to check January
	    if($irreg[$i] == ($month+1)){ # check next one to see if is to be skipped
		$planneddate = DateCalc($planneddate,"6 months");
		$month++; # to check if following ones are to be skipped too
	    }
	}
	$resultdate=DateCalc($planneddate,"6 months");
    }
    if ($subscription->{periodicity} == 10) {
	$resultdate=DateCalc($planneddate,"1 year");
    }
    if ($subscription->{periodicity} == 11) {
	$resultdate=DateCalc($planneddate,"2 years");
    }
    #    warn "date: ".$resultdate;
    return format_date_in_iso($resultdate);
}


END { }       # module clean-up code here (global destructor)

1;
