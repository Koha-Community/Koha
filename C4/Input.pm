package C4::Input; #assumes C4/Input


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

use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);
@EXPORT = qw(
	&checkflds &checkdigit &checkvalidisbn
);
 
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
} # sub checkdigit

#--------------------------------------
# Determine if a number is a valid ISBN number, according to length
#   of 10 digits and valid checksum
sub checkvalidisbn {
        use strict; 
        my ($q)=@_ ;	# Input: ISBN number

        my $isbngood = 0; # Return: true or false

        $q=~s/x$/X/g;           # upshift lower case X
        $q=~s/[^X\d]//g;
        $q=~s/X.//g;
        if (length($q)==10) {
            my $checksum=substr($q,9,1);
            my $isbn=substr($q,0,9);
            my $i;  
            my $c=0;
            for ($i=0; $i<9; $i++) { 
                my $digit=substr($q,$i,1);
                $c+=$digit*(10-$i);
            }
	    $c=$c%11;  # % is the modulus function
            ($c==10) && ($c='X');
            if ($c eq $checksum) {
                $isbngood=1;
            } else {
                $isbngood=0;
            }
        } else {
            $isbngood=0;
        } # if length good

        return $isbngood;

} # sub checkvalidisbn

 
END { }       # module clean-up code here (global destructor)
