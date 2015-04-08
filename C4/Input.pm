package C4::Input; #assumes C4/Input


# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use strict;
use warnings;

require Exporter;
use C4::Context;
use CGI;

use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 3.07.00.049;

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
	&checkdigit
);

=item checkdigit

  $valid = &checkdigit($cardnumber $nounique);

Takes a card number, computes its check digit, and compares it to the
checkdigit at the end of C<$cardnumber>. Returns a true value iff
C<$cardnumber> has a valid check digit.

=cut

#'
sub checkdigit ($;$) {

	my ($infl, $nounique) =  @_;
	$infl = uc $infl;

	# Check to make sure the cardnumber is unique

	#FIXME: We should make the error for a nonunique cardnumber
	#different from the one where the checkdigit on the number is
	#not correct

	unless ( $nounique )
	{
		my $query=qq{SELECT * FROM borrowers WHERE cardnumber=?};
		my $sth=C4::Context->prepare($query);
		$sth->execute($infl);
		my %results = $sth->fetchrow_hashref();
		if ( $sth->rows != 0 )
		{
			return 0;
		}
	}
	if (C4::Context->preference("checkdigit") eq "none") {
		return 1;
	}

	my @weightings = (8,4,6,3,5,2,1);
	my $sum;
	foreach my $i (1..7) {
		my $temp1 = $weightings[$i-1];
		my $temp2 = substr($infl,$i,1);
		$sum += $temp1 * $temp2;
	}
	my $rem = ($sum%11);
	if ($rem == 10) {
		$rem = "X";
	}
	if ($rem eq substr($infl,8,1)) {
		return 1;
	}
	return 0;
} # sub checkdigit

END { }       # module clean-up code here (global destructor)

1;
__END__

=back

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

=cut
