package C4::Stats; #asummes C4/Stats

#requires DBI.pm to be installed
#uses DBD:Pg

use strict;
require Exporter;
use DBI;
use C4::Database;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);
@EXPORT = qw(&UpdateStats &statsreport &Count &Overdues &TotalOwing
&TotalPaid &getcharges &Getpaidbranch &unfilledreserves);
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

sub UpdateStats {
  #module to insert stats data into stats table
  my ($env,$branch,$type,$amount,$other,$itemnum,$itemtype)=@_;
  my $dbh=C4Connect();
  my $branch=$env->{'branchcode'};
  my $user = $env->{'usercode'};
  my $sth=$dbh->prepare("Insert into statistics
     (datetime,branch,type,usercode,value,other,itemnumber,itemtype) 
     values (now(),'$branch',
     '$type','$user','$amount','$other','$itemnum','$itemtype')");
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
}

sub statsreport {
  #module to return a list of stats for a given day,time,branch type
  #or to return search stats
  my ($type,$time)=@_;
  my @data;
#  print "here";
#  if ($type eq 'issue'){
    @data=circrep($time,$type);
#  }
  return(@data);
}

sub circrep {
  my ($time,$type)=@_;
  my $dbh=C4Connect;
  my $query="Select * from statistics";
  if ($time eq 'today'){
    $query=$query." where type='$type' and datetime
    >=datetime('yesterday'::date)";
  }
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $i=0;
  my @results;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]="$data->{'datetime'}\t$data->{'branch'}";
    $i++;
  }
  $sth->finish;
#  print $query;
  $dbh->disconnect;
  return(@results);

}

sub Count {
  my ($type,$branch,$time,$time2)=@_;
  my $dbh=C4Connect;
  my $query="Select count(*) from statistics where type='$type'";
  $query.=" and datetime >= '$time' and datetime< '$time2' and branch='$branch'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
#  print $query;
  $dbh->disconnect;
  return($data->{'count(*)'});
}

sub Overdues{
  my $dbh=C4Connect;
  my $query="Select count(*) from issues where date_due >= now()";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $count=$sth->fetchrow_hashref;
  $sth->finish;
  $dbh->disconnect;
  return($count->{'count(*)'});  
}

sub TotalOwing{
  my ($type)=@_;
  my $dbh=C4Connect;
  my $query="Select sum(amountoutstanding) from accountlines";
  if ($type eq 'fine'){
    $query=$query." where accounttype='F' or accounttype='FN'";
  }
  my $sth=$dbh->prepare($query);
#  print $query;
  $sth->execute;
   my $total=$sth->fetchrow_hashref;
   $sth->finish;
  $dbh->disconnect; 
  return($total->{'sum(amountoutstanding)'});
}

sub TotalPaid {
  my ($time)=@_;
  my $dbh=C4Connect;
  my $query="Select * from accountlines,borrowers where accounttype = 'Pay' 
  and accountlines.borrowernumber = borrowers.borrowernumber";
  if ($time eq 'today'){
    $query=$query." and date = now()";
  } else {
    $query.=" and date='$time'";
  }
#  $query.=" order by timestamp";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my @results;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
   $sth->finish;
  $dbh->disconnect; 
#  print $query;
  return(@results);
}

sub getcharges{
  my($borrowerno,$timestamp)=@_;
  my $dbh=C4Connect;
  my $timestamp2=$timestamp-1;
  my $query="Select * from accountlines where borrowernumber=$borrowerno
  and timestamp <= '$timestamp' and accounttype <> 'Pay' and
  accounttype <> 'W'";
  my $sth=$dbh->prepare($query);
#  print $query,"<br>";
  $sth->execute;
  my $i=0;
  my @results;
  while (my $data=$sth->fetchrow_hashref){
    if ($data->{'timestamp'} == $timestamp){
      $results[$i]=$data;
      $i++;
    }
  }
  $dbh->disconnect;
  return(@results);
}

sub Getpaidbranch{
  my($date)=@_;
  my $dbh=C4Connect;
  my $query="select * from statistics where type='payment' and datetime='$date'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
#  print $query;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  $dbh->disconnect;
  return($data->{'branch'});
}

sub unfilledreserves {
  my $dbh=C4Connect;
  my $query="select *,biblio.title from reserves,reserveconstraints,biblio,borrowers,biblioitems where found <> 'F' and cancellationdate
is NULL and biblio.biblionumber=reserves.biblionumber and
reserves.constrainttype='o'
and (reserves.biblionumber=reserveconstraints.biblionumber
and reserves.borrowernumber=reserveconstraints.borrowernumber)
and
reserves.borrowernumber=borrowers.borrowernumber and
biblioitems.biblioitemnumber=reserveconstraints.biblioitemnumber order by
biblio.title,reserves.reservedate";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $i=0;
  my @results;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $query="select *,biblio.title from reserves,biblio,borrowers where found <> 'F' and cancellationdate
is NULL and biblio.biblionumber=reserves.biblionumber and reserves.constrainttype='a' and
reserves.borrowernumber=borrowers.borrowernumber
order by
biblio.title,reserves.reservedate";
  $sth=$dbh->prepare($query);
  $sth->execute;
  while (my $data=$sth->fetchrow_hashref){
    @results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return($i,\@results);
}

END { }       # module clean-up code here (global destructor)
  
    
