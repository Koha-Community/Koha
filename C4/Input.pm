package C4::Input; #asummes C4/Input

#package to deal with marking up output

use strict;
require Exporter;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);
@EXPORT = qw(&checkflds &checkdigit);
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
 
sub checkflds {
  my ($env,$reqflds,$data) = @_;
  my $numrflds = @$reqflds;
  my @probarr;
  my $i = 0;
  while ($i < $numrflds) {
    if ($data->{@$reqflds[$i]} eq "") {
      push(@probarr, @$reqflds[$i]);
    }  
    $i++
  }
  return (\@probarr);
}

sub checkdigit {
  my ($env,$infl) =  @_;
  $infl = uc $infl;
  my @weightings = (8,4,6,3,5,2,1);
  my $sum;
  my $i = 1;
  my $valid = 0;
  #  print $infl."<br>";
  while ($i <8) {
    my $temp1 = $weightings[$i-1];
    my $temp2 = substr($infl,$i,1);
    $sum = $sum + ($temp1*$temp2);
#    print "$sum $temp1 $temp2<br>";
    $i++;
  }
  my $rem = ($sum%11);
  if ($rem == 10) {
    $rem = "X";
  }  
  #print $rem."<br>";
  if ($rem eq substr($infl,8,1)) {
    $valid = 1;
  }
  return $valid;
}
 
END { }       # module clean-up code here (global destructor)
    
