package C4::Maintainance; #asummes C4/Maintainance

#package to deal with marking up output

use strict;
use C4::Database;

require Exporter;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);
@EXPORT = qw(&listsubjects &updatesub &shiftgroup &deletedbib &undeletebib
&updatetype);
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
 
sub listsubjects {
  my ($sub,$num,$offset)=@_;
  my $dbh=C4Connect;
  my $query="Select * from bibliosubject where subject like '$sub%' group by subject";
  if ($num != 0){
    $query.=" limit $offset,$num";
  }
  my $sth=$dbh->prepare($query);
#  print $query;
  $sth->execute;
  my @results;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return($i,\@results);
}

sub updatesub{
  my ($sub,$oldsub)=@_;
  my $dbh=C4Connect;
  $sub=$dbh->quote($sub);
  $oldsub=$dbh->quote($oldsub);
  my $query="update bibliosubject set subject=$sub where subject=$oldsub";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
}

sub shiftgroup{
  my ($bib,$bi)=@_;
  my $dbh=C4Connect;
  my $query="update biblioitems set biblionumber=$bib where biblioitemnumber=$bi";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
  $query="update items set biblionumber=$bib where biblioitemnumber=$bi";
  $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
}

sub deletedbib{
  my ($title)=@_;
  my $dbh=C4Connect;
  my $query="Select * from deletedbiblio where title like '$title%' order by title";
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
  return($i,\@results);
}

sub undeletebib{
  my ($bib)=@_;
  my $dbh=C4Connect;
  my $query="select * from deletedbiblio where biblionumber=$bib";
  my $sth=$dbh->prepare($query);                         
  $sth->execute;             
  if (my @data=$sth->fetchrow_array){  
    $sth->finish;                      
    $query="Insert into biblio values (";    
    foreach my $temp (@data){                
      $temp=~ s/\'/\\\'/g;                      
      $query=$query."'$temp',";      
    }                
    $query=~ s/\,$/\)/;    
    #   print $query;                    
    $sth=$dbh->prepare($query);    
    $sth->execute;          
    $sth->finish;          
  }
  $query="Delete from deletedbiblio where biblionumber=$bib";
  $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
}

sub updatetype{
  my ($bi,$type)=@_;
  my $dbh=C4Connect;
  my $sth=$dbh->prepare("Update biblioitems set itemtype='$type' where biblioitemnumber=$bi");
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
}
END { }       # module clean-up code here (global destructor)
    
