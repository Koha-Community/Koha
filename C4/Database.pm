package C4::Database; #assumes C4/Database

use strict;
require Exporter;
use DBI;
use vars qw($VERSION @ISA @EXPORT);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&C4Connect &sqlinsert &sqlupdate &getmax &makelist
&OpacConnect);

sub C4Connect  {
  my $dbname="c4"; 
   my ($database,$hostname,$user,$pass,%configfile);
   open (KC, "/etc/koha.conf");
   while (<KC>) {
     chomp;
     (next) if (/^\s*#/);
     if (/(.*)\s*=\s*(.*)/) {
       my $variable=$1;
       my $value=$2;
       # Clean up white space at beginning and end
       $variable=~s/^\s*//g;
       $variable=~s/\s*$//g;
       $value=~s/^\s*//g;
       $value=~s/\s*$//g;
       $configfile{$variable}=$value;
     }
   }
   $database=$configfile{'database'};
   $hostname=$configfile{'hostname'};
   $user=$configfile{'user'};
   $pass=$configfile{'pass'};
    
   my $dbh=DBI->connect("DBI:mysql:$database:$hostname",$user,$pass);
  return $dbh;
}    

sub Opaconnect  {
  my $dbname="c4"; 
#  my $dbh = DBI->connect("dbi:Pg:dbname=$dbname", "chris", "");
   my $database='c4test';
   my $hostname='localhost';
   my $user='hdl';
   my $pass='testing';
   my $dbh=DBI->connect("DBI:mysql:$database:$hostname",$user,$pass);
  return $dbh;
}    

sub sqlinsert {
  my ($table,%data)=@_;
  my $dbh=C4Connect;
  my $query="INSERT INTO $table \(";
  while (my ($key,$value) = each %data){
    if ($key ne 'type' && $key ne 'updtype'){
      $query=$query."$key,";
    }
  }
  $query=~ s/\,$/\)/;
  $query=$query." VALUES (";
  while (my ($key,$value) = each %data){
    if ($key ne 'type' && $key ne 'updtype'){
      $query=$query."'$value',";
    }
  }
  $query=~ s/\,$/\)/;
  print $query;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
}

sub sqlupdate {
  my ($table,$keyfld,$keyval,%data)=@_;
  my $dbh=C4Connect;
  my $query="UPDATE $table SET ";
  my @sets;
  my @keyarr = split("\t",$keyfld);
  my @keyvalarr = split("\t",$keyval);
  my $numkeys = @keyarr;
  while (my ($key,$value) = each %data){
    if (($key ne 'type')&&($key ne 'updtype')){
      my $temp = " ".$key."='".$value."' "; 
      push(@sets,$temp);
    }
  }
  my $fsets = join(",", @sets);
  $query=$query.$fsets." WHERE $keyarr[0] = '$keyvalarr[0]'";
  if ($numkeys > 1) {
    my $i = 1;
    while ($i < $numkeys) {
      $query=$query." AND $keyarr[$i] = '$keyvalarr[$i]'";
      $i++;
    }
  }  
#  $query=~ s/\,$/\)/;
  print $query;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
}


sub getmax {
  my ($table,$item)=@_;
  my $dbh=C4Connect;
  my $sth=$dbh->prepare("Select max($item) from $table");
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  $dbh->disconnect;
  return($data);
}

sub makelist {
  my ($table,$kfld,$dfld)=@_;
  my $data;
  my $dbh=C4Connect;
  my $sth=$dbh->prepare("Select $kfld,$dfld from $table order by $dfld");
  $sth->execute;
  while (my $drec=$sth->fetchrow_hashref) {
    $data = $data."\t".$drec->{$kfld}."\t".$drec->{$dfld};
  }	
  $sth->finish;
  $dbh->disconnect;
  return($data);
}
END { }       # module clean-up code here (global destructor)
