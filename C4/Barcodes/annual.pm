package C4::Barcodes::annual;

# Copyright 2008 LibLime
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

use Carp;

use C4::Context;
use C4::Debug;
use C4::Dates;

use vars qw($VERSION @ISA);
use vars qw($debug $cgi_debug);	# from C4::Debug, of course
use vars qw($width);

BEGIN {
    $VERSION = 3.07.00.049;
    @ISA = qw(C4::Barcodes);
	$width = 4;
}

sub db_max ($;$) {
	my $self = shift;
	my $query = "SELECT max(substring_index(barcode,'-',-1)) AS chunk,barcode FROM items WHERE barcode LIKE ? GROUP BY barcode";
		# FIXME: unreasonably expensive query on large datasets
	my $sth = C4::Context->dbh->prepare($query);
	my ($iso);
	if (@_) {
		my $input = shift;
		$iso = C4::Dates->new($input,'iso')->output('iso'); # try to set the date w/ 2nd arg
		unless ($iso) {
			warn "Failed to create 'iso' Dates object with input '$input'.  Reverting to today's date.";
			$iso = C4::Dates->new->output('iso');	# failover back to today
		}
	} else {
		$iso = C4::Dates->new->output('iso');
	}
	my $year = substr($iso,0,4);	# YYYY
	$sth->execute("$year-%");
	my $row = $sth->fetchrow_hashref;
	warn "barcode db_max (annual format, year $year): $row->{barcode}" if $debug;
	return $row->{barcode};
}

sub initial () {
	my $self = shift;
	return substr(C4::Dates->new->output('iso'),0,4) .'-'. sprintf('%'."$width.$width".'d', 1);
}

sub parse ($;$) {
	my $self = shift;
    my $barcode = (@_) ? shift : $self->value;
	unless ($barcode =~ /(\d{4}-)(\d+)$/) {    # non-greedy match in first part
		carp "Barcode '$barcode' has no incrementing part!";
		return ($barcode,undef,undef);
	}
	$debug and warn "Barcode '$barcode' parses into: '$1', '$2', ''";
	return ($1,$2,'');  # the third part is in anticipation of barcodes that include checkdigits
}
sub width ($;$) {
	my $self = shift;
	(@_) and $width = shift;	# hitting the class variable.
	return $width;
}
sub process_head($$;$$) {	# (self,head,whole,specific)
	my ($self,$head,$whole,$specific) = @_;
	$specific and return $head;	# if this is built off an existing barcode, just return the head unchanged.
	return substr(C4::Dates->new->output('iso'),0,4) . '-';	# else get new YYYY-
}

sub new_object {
	my $class = shift;
	my $type = ref($class) || $class;
	my $self = $type->default_self('annual');
	return bless $self, $type;
}

1;
__END__

