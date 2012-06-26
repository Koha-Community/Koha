package C4::Utils;

# Copyright 2007 Liblime
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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.


# Useful code I didn't feel like duplicating all over the place.
#

use strict;
use warnings;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $debug);

BEGIN {
	require Exporter;
    $VERSION = 3.07.00.049;        # set the version for version checking
	$debug = $ENV{DEBUG} || 0;
	@ISA    = qw(Exporter);
	@EXPORT_OK = qw(&maxwidth &hashdump);
	%EXPORT_TAGS = ( all => [qw(&maxwidth &hashdump)], );
}


sub maxwidth {
	(@_) or return 0;
	return (sort {$a <=> $b} map {length} @_)[-1];
}

sub hashdump {
	my $pre = shift;
	my $val  = shift;
	if (ref($val) =~ /HASH/) {
		print "$pre = HASH w/ " . scalar(keys %$val) . " keys.\n";
		my $w2 = maxwidth(keys %$val);
		foreach (sort keys %$val) {
			&hashdump($pre . '->{' . sprintf('%' . $w2 .'s', $_) . '}', $val->{$_});
		}
		print "\n";
	} elsif (ref($val) =~ /ARRAY/) {
		print "$pre = ARRAY w/ " . scalar(@$val) . " members.\n";
		my $w2 = maxwidth(@$val);
		foreach (@$val) {
			&hashdump($pre . '->{' . sprintf('%' . $w2 .'s', $_) . '}', $_);
		}
		print "\n";
	} else {
		print "$pre = $val\n";
	}
}

1;
__END__
