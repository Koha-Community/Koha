#!/usr/bin/perl

package C4::Barcodes;

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
use C4::Barcodes::hbyymmincr;
use C4::Barcodes::annual;
use C4::Barcodes::incremental;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
use vars qw($debug $cgi_debug);	# from C4::Debug, of course
use vars qw($max $prefformat);

BEGIN {
    $VERSION = 0.01;
	require Exporter;
    @ISA = qw(Exporter);
    @EXPORT_OK = qw();
}

sub _prefformat {
	unless (defined $prefformat) {
		unless ($prefformat = C4::Context->preference('autoBarcode')) {
			carp "The autoBarcode syspref is missing/undefined.  Assuming 'incremental'.";
			$prefformat = 'incremental';
		}
	}
	return $prefformat;
}

sub initial {
	return '0000001';
}
sub width {
	return undef;
}
sub process_head($$;$$) {	# (self,head,whole,specific)
	my $self = shift;
	return shift;			# Default: just return the head unchanged.
}
sub process_tail($$;$$) {	# (self,tail,whole,specific)
	my $self = shift;
	return shift;			# Default: just return the tail unchanged.
}
sub is_max ($;$) {
	my $self = shift;
	ref($self) or carp "Called is_max on a non-object: '$self'";
	(@_) and $self->{is_max} = shift;
	return $self->{is_max} || 0;
}
sub value ($;$) {
	my $self = shift;
	if (@_) {
		my $value = shift;
		if (defined $value) {
			$debug and print STDERR "    setting barcode value to $value\n";
		} else {
			warn "Error: UNDEF argument to value";
		}
		$self->{value} = $value;
	}
	return $self->{value};
}
sub autoBarcode (;$) {
	(@_) or return _prefformat;
	my $self = shift;
	my $value = $self->{autoBarcode} or return _prefformat;
	$value =~ s/^.*:://;	# in case we get C4::Barcodes::incremental, we just want 'incremental'
	return $value;
}
sub parse ($;$) {	# return 3 parts of barcode: non-incrementing, incrementing, non-incrementing
	my $self = shift;
	my $barcode = (@_) ? shift : $self->value;
	unless ($barcode =~ /(.*?)(\d+)$/) {	# non-greedy match in first part
		carp "Barcode '$barcode' has no incrementing part!";
		return ($barcode,undef,undef);
	}
	$debug and warn "Barcode '$barcode' parses into: '$1', '$2', ''";
	return ($1,$2,'');	# the third part is in anticipation of barcodes that include checkdigits
}
sub max ($;$) {
	my $self = shift;
	if ($self->{is_max}) {
		$debug and print STDERR "max taken from Barcodes value $self->value\n";
		return $self->value;
	}
	$debug and print STDERR "Retrieving max database query.\n";
	return $self->db_max;
}
sub db_max () {
	my $self = shift;
	my $query = "SELECT max(abs(barcode)) FROM items LIMIT 1"; # Possible problem if multiple barcode types populated
	my $sth = C4::Context->dbh->prepare($query);
	$sth->execute();
	return $sth->fetchrow_array || $self->initial;
}
sub next_value ($;$) {
	my $self = shift;
	my $specific = (scalar @_) ? 1 : 0;
	my $max = $specific ? shift : $self->max;		# optional argument, i.e. next_value after X
	unless ($max) {
		warn "No max barcode ($self->autoBarcode format) found.  Using initial value.";
		return $self->initial;
	}
	$debug and print STDERR "(current) max barcode found: $max\n";
	my ($head,$incr,$tail) = $self->parse($max);	# for incremental, you'd get ('',the_whole_barcode,'')
	unless (defined $incr) {
		warn "No incrementing part of barcode ($max) returned by parse.";
		return undef;
	}
	my $x = length($incr);		# number of digits
	$incr =~ /^9+$/ and $x++;	# if they're all 9's, we need an extra.
		# Note, this enlargement might be undesireable for some barcode formats.
		# Those should override next_value() to work accordingly.
	$incr++;
	my $width = $self->width || undef;
	# we would want to use %$x.$xd, but that would break on large values, like 2160700004168
	# so we let the object tell us if it has a width to focus on.  If not, we use float.
	my $format = ($width ? '%'."$width.$width".'d' : '%.0f');
	$debug and warn "sprintf(\"$format\",$incr)";
	$head = $self->process_head($head,$max,$specific);
	$tail = $self->process_tail($tail,$max,$specific);
	my $next_value = $head . sprintf($format,$incr) . $tail;
	$debug and print STDERR "(  next ) max barcode found: $next_value\n";
	return $next_value;
}
sub next ($;$) {
	my $self = shift or return undef;
	(@_) and $self->{next} = shift;
	return $self->{next};
}
sub previous ($;$) {
	my $self = shift or return undef;
	(@_) and $self->{previous} = shift;
	return $self->{previous};
}
sub serial ($;$) {
	my $self = shift or return undef;
	(@_) and $self->{serial} = shift;
	return $self->{serial};
}
sub default_self (;$) {
	(@_) or carp "default_self called with no argument.  Reverting to _prefformat.";
	my $autoBarcode = (@_) ? shift : _prefformat;
	$autoBarcode =~ s/^.*:://;  # in case we get C4::Barcodes::incremental, we just want 'incremental'
	return {
		is_max => 0,
		autoBarcode => $autoBarcode,
		   value => undef,
		previous => undef,
		  'next' => undef,
		serial => 1
	};
}

our $types = {
	annual      => sub {C4::Barcodes::annual->new_object(@_);     },
	incremental => sub {C4::Barcodes::incremental->new_object(@_);},
	hbyymmincr  => sub {C4::Barcodes::hbyymmincr->new_object(@_); },
	OFF         => sub {C4::Barcodes::OFF->new_object(@_);        },
};

sub new {
	my $class_or_object = shift;
	my $type = ref($class_or_object) || $class_or_object;
	my $from_obj = ref($class_or_object) ? 1 : 0;	# are we building off another Barcodes object?
	if ($from_obj) {
		$debug and print STDERR "Building new(@_) from old Barcodes object\n"; 
	}
	my $autoBarcodeType = (@_) ? shift : $from_obj ? $class_or_object->autoBarcode : _prefformat;
	$autoBarcodeType =~ s/^.*:://;	# in case we get C4::Barcodes::incremental, we just want 'incremental'
	unless ($autoBarcodeType) {
		carp "No autoBarcode format found.";
		return undef;
	}
	unless (defined $types->{$autoBarcodeType}) {
		carp "The autoBarcode format '$autoBarcodeType' is unrecognized.";
		return undef;
	}
	carp "autoBarcode format = $autoBarcodeType" if $debug;
	my $self;
	if ($autoBarcodeType eq 'OFF') {
 		$self = $class_or_object->default_self($autoBarcodeType);
		return bless $self, $class_or_object;
	} elsif ($from_obj) {
		$class_or_object->autoBarcode eq $autoBarcodeType
			or carp "Cannot create Barcodes object (type '$autoBarcodeType') from " . $class_or_object->autoBarcode . " object!";
		$self = $class_or_object->new_object(@_);
		$self->serial($class_or_object->serial + 1);
		if ($class_or_object->is_max) {
			$debug and print STDERR "old object was max: ", $class_or_object->value, "\n";
			$self->previous($class_or_object);
			$class_or_object->next($self);
			$self->value($self->next_value($class_or_object->value));
			$self->is_max(1) and $class_or_object->is_max(0);  # new object is max, old object is no longer max
		} else {
			$self->value($self->next_value);
		}
	} else {
		$debug and print STDERR "trying to create new $autoBarcodeType\n";
		$self = &{$types->{$autoBarcodeType}} (@_);
		$self->value($self->next_value) and $self->is_max(1);
		$self->serial(1);
	}
	if ($self) {
		return $self;
	}
	carp "Failed new C4::Barcodes::$autoBarcodeType";
	return undef;
}

sub new_object {
	my $class_or_object = shift;
	my $type = ref($class_or_object) || $class_or_object;
	my $from_obj = ref($class_or_object) ? 1 : 0;   # are we building off another Barcodes object?
	my $self = $class_or_object->default_self($from_obj ? $class_or_object->autoBarcode : 'incremental');
	bless $self, $type;
	return $self;
}
1;
__END__

=doc

=head1 Barcodes

Note that the object returned by new is actually of the type requested (or set by syspref).
For example, C4::Barcodes::annual

The specific C4::Barcodes::* modules correspond to the autoBarcode syspref values.

The default behavior here in Barcodes should be essentially a more flexible version of "incremental".

=head1 Adding New Barcode Types

To add a new barcode format, a developer should:

	create a module in C4/Barcodes/, like C4/Barcodes/my_new_format.pm;
	add to the $types hashref in this file; 
	add tests under the "t" directory; and
	edit autoBarcode syspref to include new type.
	
=head2 Adding a new module

Each new module that needs differing behavior must override these subs:

	new_object
	initial
	db_max
	parse

Or else the CLASS subs will be used.

=head2 $types hashref

The hash referenced can be thought of as the constructor farm for all the C4::Barcodes types.  
Each value should be a reference to a sub that calls the module constructor.

=head1 Notes

You would think it might be easy to handle incremental barcodes, but in practice even commonly used values,
like the IBM "Boulder" format can cause problems for sprintf.  Basically, the value is too large for the 
%d version of an integer, and we cannot count on perl having been compiled with support for quads 
(64-bit integers).  So we have to use floats or increment a piece of it and return the rejoined fragments.

=cut

