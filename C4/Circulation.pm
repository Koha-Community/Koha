package C4::Circulation; #asummes C4/Circulation

#package to deal with circulation 

use strict;
require Exporter;
use DBI;
use C4::Database;
use C4::Circulation::Issues;
use C4::Circulation::Returns;
use C4::Circulation::Renewals;
use C4::Circulation::Borrower;
use C4::Reserves;
#use C4::Interface;
use C4::Security;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&Start_circ &scanborrower);
#@EXPORT = qw(&Start_circ checkoverdues);
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

sub Start_circ{
  my ($env)=@_;
  #connect to database
  #start interface
  &startint($env,'Circulation');
  my $donext = 'Circ';
  my $reason;
  my $data;
  while ($donext ne 'Quit') {
    if ($donext  eq "Circ") {
      clearscreen();        
      ($reason,$data) = menu($env,'console','Circulation', 
        ('Issues','Returns','Borrower Enquiries','Reserves','Log In'));
      #debug_msg($env,"data = $data");
    } else {
      $data = $donext;
    }
    if ($data eq 'Issues') {  
      $donext=Issue($env); #C4::Circulation::Issues
      #debug_msg("","do next $donext");
    } elsif ($data eq 'Returns') {
      $donext=Returns($env); #C4::Circulation::Returns
    } elsif ($data eq 'Borrower Enquiries'){
      $donext=Borenq($env); #C4::Circulation::Borrower
    } elsif ($data eq 'Reserves'){
      $donext=EnterReserves($env); #C4::Reserves
    } elsif ($data eq 'Log In') {
      &endint($env);
      &Login($env);   #C4::Security
      &startint($env,'Circulation');
    } elsif ($data eq 'Quit') { 
      $donext = $data;
    }
    #debug_msg($env,"donext -  $donext");
  }
  &endint($env)  
}

sub pastitems{
  #Get list of all items borrower has currently on issue
  my ($env,$bornum,$dbh)=@_;
  my $sth=$dbh->prepare("Select * from issues,items,biblio
    where borrowernumber=$bornum and issues.itemnumber=items.itemnumber
    and items.biblionumber=biblio.biblionumber
    and returndate is null
    order by date_due");
  $sth->execute;
  my $i=0;
  my @items;
  my @items2;
  #$items[0]=" "x29;
  #$items2[0]=" "x29;
  $items[0]=" "x72;
  $items2[0]=" "x72;
  while (my $data=$sth->fetchrow_hashref) {
     my $line = "$data->{'date_due'} $data->{'title'}";
     # $items[$i]=fmtstr($env,$line,"L29");
     $items[$i]=fmtstr($env,$line,"L72");
     $i++;
  }
  return(\@items,\@items2);
  $sth->finish;
}

sub checkoverdues{
  #checks whether a borrower has overdue items
  my ($env,$bornum,$dbh)=@_;
  my $sth=$dbh->prepare("Select * from issues,items,biblio where
  borrowernumber=$bornum and issues.itemnumber=items.itemnumber and
  items.biblionumber=biblio.biblionumber");
  $sth->execute;
  my $row=1;
  my $col=40;
  while (my $data=$sth->fetchrow_hashref){
    output($row,$col,$data->{'title'});
    $row++;
  }
  $sth->finish;
}

sub previousissue {
  my ($env,$itemnum,$dbh,$bornum)=@_;
  my $sth=$dbh->prepare("Select firstname,surname,issues.borrowernumber,cardnumber,returndate
  from issues,borrowers where 
  issues.itemnumber='$itemnum' and
  issues.borrowernumber=borrowers.borrowernumber and issues.returndate is
NULL");
  $sth->execute;
  my $borrower=$sth->fetchrow_hashref;
  $sth->finish;
  if ($borrower->{'borrowernumber'} ne ''){
    if ($bornum eq $borrower->{'borrowernumber'}){
      # no need to issue
      my ($renewstatus) = &renewstatus($env,$dbh,$bornum,$itemnum);
      my $resp = &msg_yn("Book is issued to this borrower", "Renew?");
      if ($resp == "y") {
        &renewbook($env,$dbh,$bornum,$itemnum);
      }	 
      
    } else {
      my $text="Issued to $borrower->{'firstname'} $borrower->{'surname'} ($borrower->{'cardnumber'})";    
      my $resp = &msg_yn($text,"Mark as returned?");
      if ($resp == "y") {
        &returnrecord($env,$dbh,$borrower->{'borrowernumber'},$itemnum);
	# can issue
      } else {
        # can't issue
      }	
    }
  } 
  return($borrower->{'borrowernumber'});
  $sth->finish;
}


sub checkreserve{
  # Check for reserves for biblio 
  # does not look at constraints yet
  my ($env,$dbh,$itemnum)=@_;
  my $resbor = "";
  my $query = "select * from reserves,items 
  where (items.itemnumber = '$itemnum')
  and (items.biblionumber = reserves.biblionumber)
  and (reserves.found is null) order by priority";
  my $sth = $dbh->prepare($query);
  $sth->execute();
  if (my $data=$sth->fetchrow_hashref) {
    $resbor = $data->{'borrowernumber'}; 
  }
  return ($resbor);
  $sth->finish;
}

sub checkwaiting{
  # check for reserves waiting
  my ($env,$dbh,$bornum)=@_;
  my @itemswaiting="";
  my $query = "select * from reserves
  where (borrowernumber = '$bornum')
  and (reserves.found='W')";
  my $sth = $dbh->prepare($query);
  $sth->execute();
  if (my $data=$sth->fetchrow_hashref) {
    push @itemswaiting,$data->{'itemnumber'}; 
  }
  return (\@itemswaiting);
  $sth->finish;
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
  my ($number,$reason,$book)=&borrower_dialog($env); #C4::Interface
  $number= $number;
  $book=uc $book;
  return ($number,$reason,$book);
}


END { }       # module clean-up code here (global destructor)
