package C4::Maintainance; #asummes C4/Maintainance

#package to deal with marking up output

use strict;
use C4::Database;

require Exporter;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);
@EXPORT = qw(&listsubjects &updatesub);
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
  my $query="update bibliosubject set subject='$sub' where subject='$oldsub'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
}
END { }       # module clean-up code here (global destructor)
    
