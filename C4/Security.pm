package C4::Security; #asummes C4/Security

#requires DBI.pm to be installed
#uses DBD:Pg

use strict;
require Exporter;
use DBI;
use C4::Database;
use C4::Format;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);
@EXPORT = qw(&Login &CheckAccess);
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
 
sub Login {
  my ($env)=@_;
  my $dbh=C4Connect;
  my @branches;
  my $query = "select * from branches order by branchname";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  while (my $branchrec=$sth->fetchrow_hashref) {
    my $branchdet = 
     fmtstr($env,$branchrec->{'branchcode'},"L2")." ".$branchrec->{'branchname'};
    push @branches,$branchdet;
  }
  $sth->finish;
  my $valid = "f";
  &startint($env,"Logging In");
  until ($valid eq "t") {
    my ($reason,$username,$password,$branch) = logondialog ($env,"Logon to System",\@branches);
    $username = uc $username;
    $password = uc $password;
    my $query = "select * from users where usercode = '$username' and password ='$password'";
    $sth=$dbh->prepare($query);
    $sth->execute;
#          debug_msg("",$query);
    if (my $userrec = $sth->fetchrow_hashref) {
    if ($userrec->{'usercode'} ne ''){
      if ($branch ne "") {
        $valid = "t";
        my @dummy = split ' ', $branch;
        $branch = $dummy[0];
        $env->{'usercode'} = $username;
        $env->{'branchcode'} = $branch;
      }
     
    } else {
      debug_msg("","not found");
    }
    }
    $sth->finish;
  }
  $dbh->disconnect;
  &endint();
}
  
sub CheckAccess {
  my ($env)=@_;
  }
    
END { }       # module clean-up code here (global destructor)
    
