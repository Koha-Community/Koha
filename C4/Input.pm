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
use C4::Context;

use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 0.01;

=head1 NAME

C4::Input - Miscellaneous sanity checks

=head1 SYNOPSIS

  use C4::Input;

=head1 DESCRIPTION

This module provides functions to see whether a given library card
number or ISBN is valid.

=head1 FUNCTIONS

=over 2

=cut

@ISA = qw(Exporter);
@EXPORT = qw(
	&checkdigit &checkvalidisbn
);

# FIXME - This is never used.
#sub checkflds {
#  my ($env,$reqflds,$data) = @_;
#  my $numrflds = @$reqflds;
#  my @probarr;
#  my $i = 0;
#  while ($i < $numrflds) {
#    if ($data->{@$reqflds[$i]} eq "") {
#      push(@probarr, @$reqflds[$i]);
#    }
#    $i++
#  }
#  return (\@probarr);
#}

=item checkdigit

  $valid = &checkdigit($env, $cardnumber);

Takes a card number, computes its check digit, and compares it to the
checkdigit at the end of C<$cardnumber>. Returns a true value iff
C<$cardnumber> has a valid check digit.

C<$env> is ignored.

=cut
#'
sub checkdigit {

	my ($env,$infl, $nounique) =  @_;
	$infl = uc $infl;


	#Check to make sure the cardnumber is unique

	#FIXME: We should make the error for a nonunique cardnumber
	#different from the one where the checkdigit on the number is
	#not correct

	unless ( $nounique ) 
	{
		my $dbh=C4::Context->dbh;
		my $query=qq{SELECT * FROM borrowers WHERE cardnumber="$infl"};
		my $sth=$dbh->prepare($query);
		$sth->execute;
		my %results = $sth->fetchrow_hashref();
		if ( $sth->rows != 0 )
		{
			return 0;
		}
	}

	if (C4::Context->preference("checkdigit") eq "none") {
		return 1;
	} else {
		my @weightings = (8,4,6,3,5,2,1);
		my $sum;
		my $i = 1;
		my $valid = 0;

		foreach $i (1..7) {
			my $temp1 = $weightings[$i-1];
			my $temp2 = substr($infl,$i,1);
			$sum += $temp1 * $temp2;
		}
		my $rem = ($sum%11);
		if ($rem == 10) {
		$rem = "X";
		}
		if ($rem eq substr($infl,8,1)) {
			$valid = 1;
		}
		return $valid;
	}
} # sub checkdigit

=item checkvalidisbn

  $valid = &checkvalidisbn($isbn);

Returns a true value iff C<$isbn> is a valid ISBN: it must be ten
digits long (counting "X" as a digit), and must have a valid check
digit at the end.

=cut
#'
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
        
	#return 0 if $q is not ten digits long
	if (length($q)!=10) {
		return 0;
	}
	
	#If we get to here, length($q) must be 10
        my $checksum=substr($q,9,1);
        my $isbn=substr($q,0,9);
        my $i;
        my $c=0;
        for ($i=0; $i<9; $i++) {
            my $digit=substr($q,$i,1);
            $c+=$digit*(10-$i);
        }
	$c %= 11;
        ($c==10) && ($c='X');
        $isbngood = $c eq $checksum;

        return $isbngood;

} # sub checkvalidisbn

END { }       # module clean-up code here (global destructor)

1;
__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut
