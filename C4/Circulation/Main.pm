package C4::Circulation::Main; #asummes C4/Circulation/Main

#package to deal with circulation 


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
use C4::Circulation::Issues;
use C4::Circulation::Returns;
use C4::Circulation::Renewals;
use C4::Circulation::Borrower;
use C4::Reserves;
use C4::Search;
use C4::InterfaceCDK;
use C4::Security;
use C4::Format;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&pastitems &checkoverdues &previousissue 
&checkreserve &checkwaiting &scanbook &scanborrower &getbranch &getprinter);
%EXPORT_TAGS = ( );     # eg: TAG => [ qw!name1 name2! ],
		  
# your exported package globals go here,
# as well as any optionally exported functions

@EXPORT_OK   = qw($Var1 %Hashit);


# non-exported package globals go here
use vars qw(@more $stuff);
	
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

sub getbranch {
  my ($env) = @_;
  my $dbh = C4Connect;
  my $query = "select * from branches order by branchcode";
  my $sth = $dbh->prepare($query);
  $sth->execute;
  if ($sth->rows>1) {
      my @branches;
      while (my $data = $sth->fetchrow_hashref) {
	push @branches,$data;
      }
      brmenu ($env,\@branches);
  } else {
      my $data = $sth->fetchrow_hashref;
      $env->{'branchcode'}=$data->{'branchcode'};
  }
  my $query = "select * from branches  
    where branchcode = '$env->{'branchcode'}'";
  $sth = $dbh->prepare($query);
  $sth->execute;
  my $data = $sth->fetchrow_hashref;
  $env->{'brdata'} = $data;
  $env->{'branchname'} = $data->{'branchname'};
  $sth->finish;
  $dbh->disconnect;
}

sub getprinter {
  my ($env) = @_;
  my $dbh = C4Connect;
  my $query = "select * from printers order by printername";
  my $sth = $dbh->prepare($query);
  $sth->execute;
  if ($sth->rows>1) {
      my @printers;
      while (my $data = $sth->fetchrow_hashref) {
	push @printers,$data;
      }
      prmenu ($env,\@printers);
  } else {
      my $data=$sth->fetchrow_hashref;
      $env->{'queue'}=$data->{'printqueue'};
      $env->{'printtype'}=$data->{'printtype'};
  }
  $sth->finish;
  $dbh->disconnect;
  }
		      
sub pastitems{
  #Get list of all items borrower has currently on issue
  my ($env,$bornum,$dbh)=@_;
  my $query1 = "select * from issues  where (borrowernumber=$bornum)
    and (returndate is null) order by date_due";
  my $sth=$dbh->prepare($query1);
  $sth->execute;
  my $i=0;
  my @items;
  my @items2;
  while (my $data1=$sth->fetchrow_hashref) {
    my $data = itemnodata($env,$dbh,$data1->{'itemnumber'}); #C4::Search
    my @date = split("-",$data1->{'date_due'});
    my $odate = (@date[2]+0)."-".(@date[1]+0)."-".@date[0];
    my $line = C4::Circulation::Issues::formatitem($env,$data,$odate,"");
    $items[$i]=$line;
    $i++;
  }
  $sth->finish();
  return(\@items,\@items2);
}

sub checkoverdues{
  #checks whether a borrower has overdue items
  my ($env,$bornum,$dbh)=@_;
  my @datearr = localtime;
  my $today = ($datearr[5] + 1900)."-".($datearr[4]+1)."-".$datearr[3];
  my $query = "Select count(*) from issues where borrowernumber=$bornum and
        returndate is NULL and date_due < '$today'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data = $sth->fetchrow_hashref;
  $sth->finish;
  return $data->{'count(*)'};
}

sub previousissue {
  my ($env,$itemnum,$dbh,$bornum)=@_;
  my $sth=$dbh->prepare("Select 
     firstname,surname,issues.borrowernumber,cardnumber,returndate
     from issues,borrowers where 
     issues.itemnumber='$itemnum' and
     issues.borrowernumber=borrowers.borrowernumber 
     and issues.returndate is NULL");
  $sth->execute;
  my $borrower=$sth->fetchrow_hashref;
  my $canissue = "Y";
  $sth->finish;
  my $newdate;
  if ($borrower->{'borrowernumber'} ne ''){
    if ($bornum eq $borrower->{'borrowernumber'}){
      # no need to issue
      my ($renewstatus) = C4::Circulation::Renewals::renewstatus($env,$dbh,$bornum,$itemnum);
      my ($resbor,$resrec) = checkreserve($env,$dbh,$itemnum);
      if ($renewstatus == "0") {
        info_msg($env,"</S>Issued to this borrower - No renewals<!S>");
	$canissue = "N";
      } elsif ($resbor ne "") {
        my $resp = C4::InterfaceCDK::msg_ny($env,"Book is issued to this borrower",
	  "and is reserved - Renew?");
        if ($resp eq "Y") {
	  $newdate = C4::Circulation::Renewals::renewbook($env,$dbh,$bornum,$itemnum);
	  $canissue = "R";
	} else {
	  $canissue = "N";
	}
      } else {
        my $resp = C4::InterfaceCDK::msg_yn($env,"Book is issued to this borrower", "Renew?");
        if ($resp eq "Y") {
          $newdate = C4::Circulation::Renewals::renewbook($env,$dbh,$bornum,$itemnum);
     	  $canissue = "R";
        } else {
          $canissue = "N";
        }
      }    
    } else {
      my $text="Issued to $borrower->{'firstname'} $borrower->{'surname'} ($borrower->{'cardnumber'})";    
      my $resp = C4::InterfaceCDK::msg_yn($env,$text,"Mark as returned?");
      if ( $resp eq "Y") {
        &returnrecord($env,$dbh,$borrower->{'borrowernumber'},$itemnum);
      }	else {
        $canissue = "N";
      }
    }
  } 
  return($borrower->{'borrowernumber'},$canissue,$newdate);
}


sub checkreserve{
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
  if (my $data=$sth->fetchrow_hashref) {
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
  }
  $sth->finish;
  return ($resbor,$resrec);
}

sub checkwaiting{
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
    @itemswaiting[$cnt] =$data;
    $cnt ++
  }
  $sth->finish;
  return ($cnt,\@itemswaiting);
}

sub scanbook {
  my ($env,$interface)=@_;
  #scan barcode
  my ($number,$reason)=dialog("Book Barcode:");
  $number=uc $number;
  return ($number,$reason);
}

sub scanborrower {
  my ($env,$interface)=@_;
  #scan barcode
  my ($number,$reason,$book)=C4::InterfaceCDK::borrower_dialog($env); #C4::InterfaceCDK
  $number= $number;
  $book=uc $book;
  return ($number,$reason,$book);
}


END { }       # module clean-up code here (global destructor)
