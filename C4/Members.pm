# -*- tab-width: 8 -*-

package C4::Members;

# Copyright 2000-2003 Katipo Communications
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

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

$VERSION = 0.01;

=head1 NAME

C4::Members - Perl Module containing convenience functions for member handling

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 FUNCTIONS

=over 2

=cut

@ISA = qw(Exporter);
@EXPORT = qw();

@EXPORT_OK = qw(
	&fixup_cardnumber
    );

################################################################################

=item fixup_cardnumber

Warning: The caller is responsible for locking the members table in write
mode, to avoid database corruption.

=cut

use vars qw( @weightings );
my @weightings = (8,4,6,3,5,2,1);

sub fixup_cardnumber ($) {
    my($cardnumber) = @_;
    my $autonumber_members = C4::Context->boolean_preference('autoMemberNum');
    $autonumber_members = 0 unless defined $autonumber_members;
    # Find out whether member numbers should be generated
    # automatically. Should be either "1" or something else.
    # Defaults to "0", which is interpreted as "no".

    if ($cardnumber !~ /\S/ && $autonumber_members) {
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("select max(substring(borrowers.cardnumber,2,7)) from borrowers");
	$sth->execute;

	my $data=$sth->fetchrow_hashref;
	$cardnumber=$data->{'max(substring(borrowers.cardnumber,2,7))'};
	$sth->finish;

	# purpose: generate checksum'd member numbers.
	# We'll assume we just got the max value of digits 2-8 of member #'s
	# from the database and our job is to increment that by one,
	# determine the 1st and 9th digits and return the full string.

	if (! $cardnumber) { 			# If DB has no values,
	    $cardnumber = 1000000;		# start at 1000000
	} else {
	    $cardnumber += 1;
	}

	my $sum = 0;
	for (my $i = 0; $i < 8; $i += 1) {
	    # read weightings, left to right, 1 char at a time
	    my $temp1 = $weightings[$i];

	    # sequence left to right, 1 char at a time
	    my $temp2 = substr($cardnumber,$i,1);

	    # mult each char 1-7 by its corresponding weighting
	    $sum += $temp1 * $temp2;
	}

	my $rem = ($sum%11);
	$rem = 'X' if $rem == 10;

	$cardnumber="V$cardnumber$rem";
    }
    return $cardnumber;
}

1;
