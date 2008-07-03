#!/usr/bin/perl

package C4::Barcodes::hbyymmincr;

# Copyright 2008 LibLime
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
use warnings;

use Carp;

use C4::Context;
use C4::Debug;
use C4::Dates;

use vars qw($VERSION @ISA);
use vars qw($debug $cgi_debug);	# from C4::Debug, of course
use vars qw($branch $width);

BEGIN {
    $VERSION = 0.01;
    @ISA = qw(C4::Barcodes);
}

INIT {
	$branch = '';
	$width = 4;		# FIXME: 4 is too small for sizeable or multi-branch libraries.
}
# Generates barcode where hb = home branch Code, yymm = year/month catalogued, incr = incremental number,
# 	increment resets yearly -fbcit

sub db_max ($;$) {
	my $self = shift;
	my $query = "SELECT MAX(SUBSTRING(barcode,-$width)), barcode FROM items WHERE barcode REGEXP ? GROUP BY barcode";
	$debug and print STDERR "(hbyymmincr) db_max query: $query\n";
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
	my $year = substr($iso,2,2);    # i.e. "08" for 2008
	my $andtwo = $width+2;
	$sth->execute("^[a-zA-Z]{1,}" . $year . "[0-9]{$andtwo}");	# the extra two digits are the month.  we don't care what they are, just that they are there.
	unless ($sth->rows) {
		warn "No existing hbyymmincr barcodes found.  Reverting to initial value.";
		return $self->initial;
	}
	my ($row) = $sth->fetchrow_hashref;
	my $max = $row->{barcode};
	warn "barcode max (hbyymmincr format): $max" if $debug;
	return ($max || 0);
}

sub initial () {
	my $self = shift;
	# FIXME: populated branch?
	my $iso = C4::Dates->new->output('iso'); 	# like "2008-07-02"
	return $self->branch . substr($iso,2,2) . substr($iso,5,2) . sprintf('%' . "$width.$width" . 'd',1);
}

sub parse ($;$) {   # return 3 parts of barcode: non-incrementing, incrementing, non-incrementing
	my $self = shift;
	my $barcode = (@_) ? shift : $self->value;
	my $branch = $self->branch;
	unless ($barcode =~ /($branch\d{4})(\d+)$/) {
		carp "Barcode '$barcode' has no incrementing part!";
		return ($barcode,undef,undef);
	}
	$debug and warn "Barcode '$barcode' parses into: '$1', '$2', ''";
	return ($1,$2,'');  # the third part is in anticipation of barcodes that include checkdigits
}

sub branch ($;$) {
	my $self = shift;
	(@_) and $self->{branch} = shift;
	return $self->{branch};
}
sub width ($;$) {
	my $self = shift;
	(@_) and $width = shift;	# hitting the class variable.
	return $width;
}
sub process_head($$;$$) {	# (self,head,whole,specific)
	my ($self,$head,$whole,$specific) = @_;
	$specific and return $head;	# if this is built off an existing barcode, just return the head unchanged.
	$head =~ s/\d{4}$//;		# else strip the old yymm
	my $iso = C4::Dates->new->output('iso'); 	# like "2008-07-02"
	return $head . substr($iso,2,2) . substr($iso,5,2);
}

sub new_object {
	$debug and warn "hbyymmincr: new_object called";
	my $class_or_object = shift;
	my $type = ref($class_or_object) || $class_or_object;
	my $from_obj = ref($class_or_object) ? 1 : 0;   # are we building off another Barcodes object?
	my $self = $class_or_object->default_self('hbyymmincr');
	bless $self, $type;
	$self->branch(@_ ? shift : $from_obj ? $class_or_object->branch : $branch);
		# take the branch from argument, or existing object, or default
	use Data::Dumper;
	$debug and print STDERR "(hbyymmincr) new_object: ", Dumper($self), "\n";
	return $self;
}

1;
__END__

=doc 

This format is deprecated and SHOULD NOT BE USED.

It is fairly clear the originator of the format did not intend to accomodate 
multiple branch libraries, given that the format caps the available namespace to
10,000 barcodes per year TOTAL.  

Also, the question of what to do with an item that changes branch is unsettled.  
Nothing prevents the barcode from working fine, but it will look out of place
with the old branchcode in it.  Rebarcoding a single item is trivial, but if you
consider the scenario of branches being consolidated, it is an unnecessary 
burden to force the rebarcoding of thousands of items, especially when the format
will limit you to under 10,000 on the year!

The main purpose of the format seems to be to get the branch code into the barcode.
This is wholly unnecessary, since the barcodes can be printed with the branchcode
directly on it, without it being part of the barcode itself.  

The API for this module should exist almost exclusively through C4::Barcodes.  
One novel aspect of this format is the fact that the barcode is tied to a branch.  

=cut
