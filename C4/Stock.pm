package C4::Stock; #asummes C4/Stock.pm

use strict;
require Exporter;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
use C4::Database;

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);
@EXPORT = qw(&stockreport);
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

sub stockreport {
  my $dbh=C4Connect;
  my @results;
  my $query="Select count(*) from items where homebranch='C'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $count=$sth->fetchrow_hashref;
  $results[0]="$count->{'count'}\t Levin";
  $sth->finish;
  $query="Select count(*) from items where homebranch='F'";
  $sth=$dbh->prepare($query);
  $sth->execute;
  $count=$sth->fetchrow_hashref;
  $results[1]="$count->{'count'}\t Foxton";
  $sth->finish;
  $dbh->disconnect;
  return(@results);
}

END { }       # module clean-up code here (global destructor)
  
    
