package C4::Reserves2; #assumes C4/Reserves2


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
use DBI;
use C4::Database;
#use C4::Accounts;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&FindReserves &CheckReserves &CheckWaiting &CancelReserve &FillReserve &ReserveWaiting &CreateReserve &updatereserves &getreservetitle &Findgroupreserve &CalcReserveFee);

						    
# make all your functions, whether exported or not;

sub FindReserves {
  my ($bib,$bor)=@_;
  my $dbh=C4Connect;
  my $query="SELECT *,reserves.branchcode AS branchcode, biblio.title AS btitle
                      FROM borrowers,reserves,biblio ";
  if ($bib){
      $bib = $dbh->quote($bib);
      if ($bor ne ''){
	  $bor = $dbh->quote($bor);
          $query .=  " where reserves.biblionumber   = $bib
                         and borrowers.borrowernumber = $bor 
                         and reserves.borrowernumber = borrowers.borrowernumber 
                         and biblio.biblionumber     = $bib 
                         and cancellationdate is NULL 
                         and (found <> 'F' or found is NULL)";
      } else {
          $query .= " where reserves.borrowernumber = borrowers.borrowernumber
                        and biblio.biblionumber     = $bib 
                        and reserves.biblionumber   = $bib
                        and cancellationdate is NULL 
                        and (found <> 'F' or found is NULL)";
      }
  } else {
      $query .= " where borrowers.borrowernumber = $bor 
                    and reserves.borrowernumber  = borrowers.borrowernumber 
                    and reserves.biblionumber    = biblio.biblionumber 
                    and cancellationdate is NULL and 
                    (found <> 'F' or found is NULL)";
  }
  $query.=" order by priority";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $i=0;
  my @results;
  while (my $data=$sth->fetchrow_hashref){
      if ($data->{'constrainttype'} eq "o") {
	  my $bibres = getreservetitle($data->{'biblionumber'},$data->{'borrowernumber'},$data->{'reservedate'},$data->{'timestamp'});
	  foreach my $key (keys %$bibres) {
	      $data->{$key} = $bibres->{$key};
	  }
      }
      $results[$i]=$data;
      $i++;
  }
#  print $query;
  $sth->finish;
  $dbh->disconnect;
  return($i,\@results);
}

sub CheckReserves {
    my ($item) = @_;
    my $dbh=C4Connect;
    my $qitem=$dbh->quote($item);
# get the biblionumber...
    my $sth=$dbh->prepare("select biblionumber, biblioitemnumber from items where itemnumber=$qitem");
    $sth->execute;
    my ($biblio, $bibitem) = $sth->fetchrow_array;
    $sth->finish;
    $dbh->disconnect;
# get the reserves...
    my ($count, @reserves) = Findgroupreserve($bibitem, $biblio);
    my $priority = 10000000; 
    my $highest;
    if ($count) {
	foreach my $res (@reserves) {
	    if ($res->{'itemnumber'} == $item) {
		return ("Waiting", $res);
	    } else {
		if ($res->{'priority'} < $priority) {
		    $priority = $res->{'priority'};
		    $highest = $res;
		}
	    }
	}
	$highest->{'itemnumber'} = $item;
	return ("Reserved", $highest);
    } else {
	return (0, 0);
    }
}

sub CancelReserve {
    my ($biblio, $item, $borr) = @_;
    my $dbh=C4Connect;
    if (($item and $borr) and (not $biblio)) {
# removing a waiting reserve record....
	$item = $dbh->quote($item);
	$borr = $dbh->quote($borr);
# update the database...
        my $query = "update reserves set cancellationdate = now(), 
                                         found            = Null, 
                                         priority         = 0 
                                   where itemnumber       = $item 
                                     and borrowernumber   = $borr";
	my $sth = $dbh->prepare($query);
	$sth->execute;
	$sth->finish;
    }
    if (($biblio and $borr) and (not $item)) {
# removing a reserve record....
	my $q_biblio = $dbh->quote($biblio);
	$borr = $dbh->quote($borr);
# fix up the priorities on the other records....
	my $query = "SELECT priority FROM reserves 
                                    WHERE biblionumber   = $q_biblio 
                                      AND borrowernumber = $borr
                                      AND cancellationdate is NULL 
                                      AND (found <> 'F' or found is NULL)";
	my $sth=$dbh->prepare($query);
	$sth->execute;
	my ($priority) = $sth->fetchrow_array;
	$sth->finish;
# update the database, removing the record...
        my $query = "update reserves set cancellationdate = now(), 
                                         found            = Null, 
                                         priority         = 0 
                                   where biblionumber     = $q_biblio 
                                     and borrowernumber   = $borr
                                     and cancellationdate is NULL 
                                     and (found <> 'F' or found is NULL)";
	my $sth = $dbh->prepare($query);
	$sth->execute;
	$sth->finish;
# now fix the priority on the others....
	fixpriority($priority, $biblio);
    }
    $dbh->disconnect;
}


sub FillReserve {
    my ($res) = @_;
    my $dbh=C4Connect;
# removing a waiting reserve record....
    my $biblio = $res->{'biblionumber'}; my $qbiblio = $dbh->quote($biblio);
    my $borr = $res->{'borrowernumber'}; $borr = $dbh->quote($borr);
    my $resdate = $res->{'reservedate'}; $resdate = $dbh->quote($resdate);
# update the database...
    my $query = "UPDATE reserves SET found            = 'F', 
                                     priority         = 0 
                               WHERE biblionumber     = $qbiblio
                                 AND reservedate      = $resdate
                                 AND borrowernumber   = $borr";
    my $sth = $dbh->prepare($query);
    $sth->execute;
    $sth->finish;
    $dbh->disconnect;
# now fix the priority on the others....
    fixpriority($res->{'priority'}, $biblio);
}

sub fixpriority {
    my ($priority, $biblio) =  @_;
    my $dbh = C4Connect;
    my ($count, $reserves) = FindReserves($biblio);
    foreach my $rec (@$reserves) {
	if ($rec->{'priority'} > $priority) {
	    my $newpr = $rec->{'priority'};      $newpr = $dbh->quote($newpr - 1);
	    my $nbib = $rec->{'biblionumber'};   $nbib = $dbh->quote($nbib);
	    my $nbor = $rec->{'borrowernumber'}; $nbor = $dbh->quote($nbor);
	    my $nresd = $rec->{'reservedate'};   $nresd = $dbh->quote($nresd);
            my $query = "UPDATE reserves SET priority = $newpr 
                               WHERE biblionumber     = $nbib 
                                 AND borrowernumber   = $nbor
                                 AND reservedate      = $nresd";
	    my $sth = $dbh->prepare($query);
	    $sth->execute;
	    $sth->finish;
	} 
    }
    $dbh->disconnect;
}



sub ReserveWaiting {
    my ($item, $borr) = @_;
    my $dbh = C4Connect;
    $item = $dbh->quote($item);
    $borr = $dbh->quote($borr);
# get priority and biblionumber....
    my $query = "SELECT reserves.priority     as priority, 
                        reserves.biblionumber as biblionumber,
                        reserves.branchcode   as branchcode 
                      FROM reserves,items 
                     WHERE reserves.biblionumber   = items.biblionumber 
                       AND items.itemnumber        = $item 
                       AND reserves.borrowernumber = $borr 
                       AND reserves.cancellationdate is NULL
                       AND (reserves.found <> 'F' or reserves.found is NULL)";
    my $sth = $dbh->prepare($query);
    $sth->execute;
    my $data = $sth->fetchrow_hashref;
    $sth->finish;
    my $biblio = $data->{'biblionumber'};
    my $q_biblio = $dbh->quote($biblio);
# update reserves record....
    $query = "UPDATE reserves SET priority = 0, found = 'W', itemnumber = $item 
                            WHERE borrowernumber = $borr AND biblionumber = $q_biblio";
    $sth = $dbh->prepare($query);
    $sth->execute;
    $sth->finish;
    $dbh->disconnect;
# now fix up the remaining priorities....
    fixpriority($data->{'priority'}, $biblio);
    my $branchcode = $data->{'branchcode'};
    return $branchcode;
}

sub CheckWaiting {
    my ($borr)=@_;
    my $dbh = C4Connect;
    $borr = $dbh->quote($borr);
    my @itemswaiting;
    my $query = "SELECT * FROM reserves
                         WHERE borrowernumber = $borr
                           AND reserves.found = 'W' 
                           AND cancellationdate is NULL";
    my $sth = $dbh->prepare($query);
    $sth->execute();
    my $cnt=0;
    if (my $data=$sth->fetchrow_hashref) {
	@itemswaiting[$cnt] =$data;
	$cnt ++;
    }
    $sth->finish;
    return ($cnt,\@itemswaiting);
}

sub Findgroupreserve {
  my ($bibitem,$biblio)=@_;
  my $dbh=C4Connect;
  $bibitem=$dbh->quote($bibitem);
  my $query = "SELECT reserves.biblionumber               AS biblionumber, 
                      reserves.borrowernumber             AS borrowernumber, 
                      reserves.reservedate                AS reservedate, 
                      reserves.branchcode                 AS branchcode, 
                      reserves.cancellationdate           AS cancellationdate, 
                      reserves.found                      AS found, 
                      reserves.reservenotes               AS reservenotes, 
                      reserves.priority                   AS priority, 
                      reserves.timestamp                  AS timestamp, 
                      reserveconstraints.biblioitemnumber AS biblioitemnumber, 
                      reserves.itemnumber                 AS itemnumber 
                 FROM reserves LEFT JOIN reserveconstraints
                   ON reserves.biblionumber = reserveconstraints.biblionumber
                WHERE reserves.biblionumber = $biblio
                  AND ( ( reserveconstraints.biblioitemnumber = $bibitem 
                      AND reserves.borrowernumber = reserveconstraints.borrowernumber
                      AND reserves.reservedate    =reserveconstraints.reservedate )
                   OR reserves.constrainttype='a' )
                  AND reserves.cancellationdate is NULL
                  AND (reserves.found <> 'F' or reserves.found is NULL)";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $i=0;
  my @results;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return($i,@results);
}

sub CreateReserve {
  my ($env,$branch,$borrnum,$biblionumber,$constraint,$bibitems,$priority,$notes,$title)= @_;
  my $fee=CalcReserveFee($env,$borrnum,$biblionumber,$constraint,$bibitems);
  my $dbh = &C4Connect;
  my $const = lc substr($constraint,0,1);
  my @datearr = localtime(time);
  my $resdate =(1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];                   
  #eval {                                                           
  # updates take place here             
  if ($fee > 0) {           
#    print $fee;
    my $nextacctno = &getnextacctno($env,$borrnum,$dbh);   
    my $updquery = "insert into accountlines       
    (borrowernumber,accountno,date,amount,description,accounttype,amountoutstanding)                                              
						          values
    ($borrnum,$nextacctno,now(),$fee,'Reserve Charge - $title','Res',$fee)";          
    my $usth = $dbh->prepare($updquery);                      
    $usth->execute;             
    $usth->finish;                        
  }                     
  #if ($const eq 'a'){
    my $query="insert into reserves
   (borrowernumber,biblionumber,reservedate,branchcode,constrainttype,priority,reservenotes)
    values (?, ?, ?, ?, ?, ?, ?)";   
    my $sth = $dbh->prepare($query);                        
    $sth->execute($borrnum,
    		  $biblionumber,
		  $resdate,
		  $branch,
		  $const,
		  $priority,
		  $notes);
    $sth->finish;
  #}
  if (($const eq "o") || ($const eq "e")) {     
    my $numitems = @$bibitems;             
    my $i = 0;                                        
    while ($i < $numitems) {   
      my $biblioitem = @$bibitems[$i];   
      my $query = "insert into
      reserveconstraints                          
      (borrowernumber,biblionumber,reservedate,biblioitemnumber)         
      values
      ('$borrnum','$biblionumber','$resdate','$biblioitem')";                 
      my $sth = $dbh->prepare($query);                    
      $sth->execute();
      $sth->finish;
      $i++;                         
    }                                   
  } 
#  print $query;
  $dbh->disconnect();         
  return();   
}             

sub CalcReserveFee {
    my ($env,$borrnum,$biblionumber,$constraint,$bibitems) = @_;        
    #check for issues;    
    my $dbh = &C4Connect;           
    my $const = lc substr($constraint,0,1); 
    my $query = "SELECT categorycode FROM borrowers WHERE borrowernumber = ?";   
    my $sth = $dbh->prepare($query);                       
    $sth->execute($borrnum);
    my ($categorycode) = $sth->fetchrow_array;
    $sth->finish();

    my %itemtypes;
    my $query = "SELECT biblioitems.itemtype, biblioitems.biblioitemnumber 
                   FROM biblio, biblioitems 
                  WHERE biblio.biblionumber = ?
                    AND biblio.biblionumber = biblioitems.biblionumber";
    $sth = $dbh->prepare($query);
    $sth->execute($biblionumber);
    while (my $data = $sth->fetchrow_hashref) {
	if ($const eq "a") {
	    $itemtypes{$data->{'itemtype'}} = 1;
	} else {
	    foreach my $bibitem (@$bibitems) {
		$itemtypes{$data->{'itemtype'}} = 1 if $bibitem == $data->{'biblioitemnumber'};
	    }
	}
    }
    $sth->finish;
    $query = "SELECT itemtype, reservecharge FROM categoryitem WHERE categorycode = ?";
    $sth = $dbh->prepare($query);
    $sth->execute($categorycode);
    my $fee = 0;
    while (my $data = $sth->fetchrow_hashref) {
	if ($itemtypes{$data->{'itemtype'}}) {
	    $fee = $data->{'reservecharge'} if $fee < $data->{'reservecharge'};
	}
    }
    $sth->finish;
    $dbh->disconnect();   
    return $fee;                                      
}                   

sub getnextacctno {                                                           
  my ($env,$bornumber,$dbh)=@_;           
  my $nextaccntno = 1;      
  my $query = "select * from accountlines                             
  where (borrowernumber = '$bornumber')                               
  order by accountno desc";                       
  my $sth = $dbh->prepare($query);                                  
  $sth->execute;                    
  if (my $accdata=$sth->fetchrow_hashref){    
    $nextaccntno = $accdata->{'accountno'} + 1;           
  }                       
  $sth->finish;                                       
  return($nextaccntno);                   
}     

sub updatereserves{
  #subroutine to update a reserve 
  my ($rank, $biblio, $borrower, $del, $branch)=@_;
  my $dbh = C4Connect;
  my $query = "UPDATE reserves ";
  if ($del == 0) {
    $query.="SET priority='$rank', branchcode='$branch' WHERE
    biblionumber=$biblio AND borrowernumber=$borrower";
  } else {
    $query="SELECT * FROM reserves WHERE biblionumber=$biblio AND
    borrowernumber=$borrower";
    my $sth=$dbh->prepare($query);
    $sth->execute;
    my $data=$sth->fetchrow_hashref;
    $sth->finish;
    $query="SELECT * FROM reserves WHERE biblionumber=$biblio AND 
    priority > '$data->{'priority'}' AND cancellationdate is NULL 
    order by priority";
    my $sth2=$dbh->prepare($query) || die $dbh->errstr;
    $sth2->execute || die $sth2->errstr;
    while (my $data=$sth2->fetchrow_hashref){
      $data->{'priority'}--;
      $query="Update reserves set priority=$data->{'priority'} where
      biblionumber=$data->{'biblionumber'} and
      borrowernumber=$data->{'borrowernumber'}";
      my $sth3=$dbh->prepare($query);
      $sth3->execute || die $sth3->errstr;
      $sth3->finish;
    }
    $sth2->finish;
    $query="update reserves set cancellationdate=now() where biblionumber=$biblio 
    and borrowernumber=$borrower";    
  }
  my $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;  
  $dbh->disconnect;
}

sub getreservetitle {
    my ($biblio,$bor,$date,$timestamp)=@_;
    my $dbh=C4Connect;
    my $query = "SELECT biblioitems.volumeddesc AS volumeddesc,
                        itemtypes.description    AS itemtype,
                        itemtypes.publictype    AS publictype
                   FROM reserveconstraints,biblioitems,itemtypes 
                  WHERE reserveconstraints.biblioitemnumber = biblioitems.biblioitemnumber
                    AND biblioitems.itemtype                = itemtypes.itemtype
                    AND reserveconstraints.biblionumber     = $biblio 
                    AND reserveconstraints.borrowernumber   = $bor 
                    AND reserveconstraints.reservedate      = '$date'";
    my $sth=$dbh->prepare($query);
    $sth->execute;
    my $data=$sth->fetchrow_hashref;
    $sth->finish;
    $dbh->disconnect;
# print $query;
    return($data);
}





			
END { }       # module clean-up code here (global destructor)
