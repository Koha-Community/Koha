package C4::Input; #assumes C4/Input

use strict;
require Exporter;

use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);
@EXPORT = qw(&checkflds &checkdigit);
 
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
    
