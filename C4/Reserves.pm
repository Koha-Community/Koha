package C4::Reserves;

# $Id$

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

# FIXME - I suspect that this module is obsolete.

use strict;
require Exporter;
use DBI;
use C4::Context;
use C4::Format;
use C4::Accounts;
use C4::Stats;
#use C4::InterfaceCDK;
#use C4::Interface::ReserveentCDK;
use C4::Circulation::Main;
use C4::Circulation::Borrower;
use C4::Search;
use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);
@EXPORT = qw(&EnterReserves CalcReserveFee CreateReserve );

# FIXME - This doesn't appear to ever be used, except in modules that
# appear to be obsolete.
sub EnterReserves{
  my ($env)=@_;
  my $titlepanel = titlepanel($env,"Reserves","Enter Selection");
  my @flds = ("No of entries","Barcode","ISBN","Title","Keywords","Author","Subject");
  my @fldlens = ("5","15","15","50","50","50","50");
  my ($reason,$num,$itemnumber,$isbn,$title,$keyword,$author,$subject) =
     FindBiblioScreen($env,"Reserves",7,\@flds,\@fldlens);
  my $donext ="Circ";
  if ($reason ne "") {
    $donext = $reason;
  } else {
    my %search;
    $search{'title'}= $title;
    $search{'keyword'}=$keyword;
    $search{'author'}=$author;
    $search{'subject'}=$subject;
    $search{'item'}=$itemnumber;
    $search{'isbn'}=$isbn;
    my @results;
    my $count;
    if ($num < 1 ) {
      $num = 30;
    }
    my $offset = 0;
    my $title = titlepanel($env,"Reserves","Searching");
    if ($itemnumber ne '' || $isbn ne ''){
      ($count,@results)=&CatSearch($env,'precise',\%search,$num,$offset);
    } else {
      if ($subject ne ''){
        ($count,@results)=&CatSearch($env,'subject',\%search,$num,$offset);
      } else {
        if ($keyword ne ''){
          ($count,@results)=&KeywordSearch($env,'intra',\%search,$num,$offset);
        } else {
          ($count,@results)=&CatSearch($env,'loose',\%search,$num,$offset);
        }
      }
    }
    my $no_ents = @results;
    my $biblionumber;
    if ($no_ents > 0) {
      if ($no_ents == 1) {
        my @ents = split("\t",@results[0]);
        $biblionumber  = @ents[2];
      } else {
        my %biblio_xref;
        my @bibtitles;
        my $i = 0;
        my $line;
        while ($i < $no_ents) {
          my @ents = split("\t",@results[$i]);
          $line = fmtstr($env,@ents[1],"L70");
	  my $auth = substr(@ents[0],0,30);
	  substr($line,(70-length($auth)-2),length($auth)+2) = "  ".$auth;
          @bibtitles[$i]=$line;
          $biblio_xref{$line}=@ents[2];
          $i++;
        }
        my $title = titlepanel($env,"Reserves","Select Title");
      	my ($results,$bibres) = SelectBiblio($env,$count,\@bibtitles);
        if ($results eq "") {
       	  $biblionumber = $biblio_xref{$bibres};
        } else {
	  $donext = $results;
	}
      }

      if ($biblionumber eq "") {
        error_msg($env,"No items found");
      } else {
        my @items = GetItems($env,$biblionumber);
      	my $cnt_it = @items;
	my $dbh = C4::Context->dbh;
        my $query = "";
	my $sth = $dbh->prepare("Select * from biblio where biblionumber = ?");
	$sth->execute($biblionumber);
	my $data=$sth->fetchrow_hashref;
	$sth->finish;
        my @branches;
        my $sth=$dbh->prepare("select * from branches where issuing=1 order by branchname");
        $sth->execute;
        while (my $branchrec=$sth->fetchrow_hashref) {
          my $branchdet =
            fmtstr($env,$branchrec->{'branchcode'},"L2")." ".$branchrec->{'branchname'};
          push @branches,$branchdet;
        }
	$sth->finish;
        $donext = "";
	while ($donext eq "") {
          my $title = titlepanel($env,"Reserves","Create Reserve");
       	  my ($reason,$borcode,$branch,$constraint,$bibitems) =
            MakeReserveScreen($env, $data, \@items, \@branches);
      	  if ($borcode ne "") {
   	    my ($borrnum,$borrower) = findoneborrower($env,$dbh,$borcode);
       	    if ($reason eq "") {
       	      if ($borrnum ne "") {
	        my $fee =
                  CalcReserveFee($env,$borrnum,$biblionumber,$constraint,$bibitems);
                  CreateReserve($env,$branch,$borrnum,$biblionumber,$constraint,$bibitems,$fee);
                $donext = "Circ"
              }

            } else {
       	      $donext = $reason;
	    }
	  } else { $donext = "Circ" }
	}
      }
    }
  }
  return ($donext);
}

# FIXME - A functionally identical version of this function appears in
# C4::Reserves2. Pick one and stick with it.
sub CalcReserveFee {
  my ($env,$borrnum,$biblionumber,$constraint,$bibitems) = @_;
  #check for issues;
  my $dbh = C4::Context->dbh;
  my $const = lc substr($constraint,0,1);
  my $sth = $dbh->prepare("select * from borrowers,categories
    where (borrowernumber = ?)
    and (borrowers.categorycode = categories.categorycode)");
  $sth->execute($borrnum);
  my $data = $sth->fetchrow_hashref;
  $sth->finish();
  my $fee = $data->{'reservefee'};
  my $cntitems = @->$bibitems;
  if ($fee > 0) {
    # check for items on issue
    # first find biblioitem records
    my @biblioitems;
    my $sth1 = $dbh->prepare("select * from biblio,biblioitems
       where (biblio.biblionumber = ?)
       and (biblio.biblionumber = biblioitems.biblionumber)");
    $sth1->execute($biblionumber);
    while (my $data1=$sth1->fetchrow_hashref) {
      if ($const eq "a") {
        push @biblioitems,$data1;
     } else {
        my $found = 0;
        my $x = 0;
	while ($x < $cntitems) {
          if (@$bibitems->{'biblioitemnumber'} == $data->{'biblioitemnumber'}) {
	    $found = 1;
	  }
	  $x++;
        }
	if ($const eq 'o') {if ($found == 1) {push @biblioitems,$data;}
	} else {if ($found == 0) {push @biblioitems,$data;} }
      }
    }
    $sth1->finish;
    my $cntitemsfound = @biblioitems;
    my $issues = 0;
    my $x = 0;
    my $allissued = 1;
    while ($x < $cntitemsfound) {
      my $bitdata = @biblioitems[$x];
      my $sth2 = $dbh->prepare("select * from items
        where biblioitemnumber = ?");
      $sth2->execute($bitdata->{'biblioitemnumber'});
      while (my $itdata=$sth2->fetchrow_hashref) {
        my $sth3 = $dbh->prepare("select * from issues
           where itemnumber = ? and returndate is null");
	$sth3->execute($itdata->{'itemnumber'});
	if (my $isdata=$sth3->fetchrow_hashref) { } else {$allissued = 0; }
      }
      $x++;
    }
    if ($allissued == 0) {
      my $rsth = $dbh->prepare("select * from reserves
        where biblionumber = ?");
      $rsth->execute($biblionumber);
      if (my $rdata = $rsth->fetchrow_hashref) { } else {
        $fee = 0;
      }
    }
  }
  return $fee;
} # end CalcReserveFee

# FIXME - A somewhat different version of this function appears in
# C4::Reserves2. Pick one and stick with it.
sub CreateReserve {
  my ($env,$branch,$borrnum,$biblionumber,$constraint,$bibitems,$fee) = @_;
  my $dbh = C4::Context->dbh;
  #$dbh->{RaiseError} = 1;
  #$dbh->{AutoCommit} = 0;
  my $const = lc substr($constraint,0,1);
  my @datearr = localtime(time);
  my $resdate = (1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
  #eval {
    # updates take place here
    if ($fee > 0) {
      my $nextacctno = &getnextacctno($env,$borrnum,$dbh);
      my $usth = $dbh->prepare("insert into accountlines
         (borrowernumber,accountno,date,amount,description,accounttype,amountoutstanding)
          values (?,?,now(),?,'Reserve Charge','Res',?)");
      $usth->execute($borrnum,$nextacctno,$fee,$fee);
      $usth->finish;
    }
    my $sth = $dbh->prepare("insert into reserves (borrowernumber,biblionumber,reservedate,branchcode,constrainttype) values (?,?,?,?,?)");
    $sth->execute($borrnum,$biblionumber,$resdate,$branch,$const);
    if (($const eq "o") || ($const eq "e")) {
      my $numitems = @$bibitems;
      my $i = 0;
      while ($i < $numitems) {
        my $biblioitem = @$bibitems[$i];
        my $sth = $dbh->prepare("insert into reserveconstraints
    	   (borrowernumber,biblionumber,reservedate,biblioitemnumber)
    	   values (?,?,?,?)");
    	$sth->execute($borrnum,$biblionumber,$resdate,$biblioitem);
	$i++;
      }
    }
  UpdateStats($env,'branch','reserve',$fee);
  #$dbh->commit();
  #};
  #if (@_) {
  #  # update failed
  #  my $temp = @_;
  #  #  error_msg($env,"Update failed");
  #  $dbh->rollback();
  #}
  return();
} # end CreateReserve
