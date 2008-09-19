package C4::Dates;
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
use Exporter;
use POSIX qw(strftime);
use Date::Calc qw(check_date check_time);
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
use vars qw($debug $cgi_debug);

BEGIN {
	$VERSION = 0.04;
	@ISA = qw(Exporter);
	@EXPORT_OK = qw(format_date_in_iso format_date);
}

use vars qw($prefformat);
sub _prefformat {
    unless (defined $prefformat) {
        $prefformat = C4::Context->preference('dateformat');
    }
    return $prefformat;
}

our %format_map = ( 
	  iso  => 'yyyy-mm-dd', # plus " HH:MM:SS"
	metric => 'dd/mm/yyyy', # plus " HH:MM:SS"
	  us   => 'mm/dd/yyyy', # plus " HH:MM:SS"
	  sql  => 'yyyymmdd    HHMMSS',
);
our %posix_map = (
	  iso  => '%Y-%m-%d',	# or %F, "Full Date"
	metric => '%d/%m/%Y',
	  us   => '%m/%d/%Y',
	  sql  => '%Y%m%d    %H%M%S',
);

our %dmy_subs = (			# strings to eval  (after using regular expression returned by regexp below)
							# make arrays for POSIX::strftime()
	  iso  => '[(($6||0),($5||0),($4||0),$3, $2 - 1, $1 - 1900)]',		
	metric => '[(($6||0),($5||0),($4||0),$1, $2 - 1, $3 - 1900)]',
	  us   => '[(($6||0),($5||0),($4||0),$2, $1 - 1, $3 - 1900)]',
	  sql  => '[(($6||0),($5||0),($4||0),$3, $2 - 1, $1 - 1900)]',
);

sub regexp ($;$) {
	my $self = shift;
	my $delim = qr/:?\:|\/|-/;	# "non memory" cluster: no backreference
	my $format = (@_) ? shift : $self->{'dateformat'};	# w/o arg. relies on dateformat being defined
	($format eq 'sql') and 
	return qr/^(\d{4})(\d{2})(\d{2})(?:\s{4}(\d{2})(\d{2})(\d{2}))?/;
	($format eq 'iso') and 
	return qr/^(\d{4})$delim(\d{2})$delim(\d{2})(?:(?:\s{1}|T)(\d{2})\:?(\d{2})\:?(\d{2}))?Z?/;
	return qr/^(\d{2})$delim(\d{2})$delim(\d{4})(?:\s{1}(\d{2})\:?(\d{2})\:?(\d{2}))?/;  # everything else
}

sub dmy_map ($$) {
	my $self = shift;
	my $val  = shift 					or return undef;
	my $dformat = $self->{'dateformat'} or return undef;
	my $re = $self->regexp();
	my $xsub = $dmy_subs{$dformat};
	$debug and print STDERR "xsub: $xsub \n";
	if ($val =~ /$re/) {
		my $aref = eval $xsub;
        _check_date_and_time($aref);
		return  @{$aref}; 
	}
	# $debug and 
	carp "Illegal Date '$val' does not match '$dformat' format: " . $self->visual();
	return 0;
}

sub _check_date_and_time {
    my $chron_ref = shift;
    my ($year, $month, $day) = _chron_to_ymd($chron_ref);
    unless (check_date($year, $month, $day)) {
        carp "Illegal date specified (year = $year, month = $month, day = $day)";
    }
    my ($hour, $minute, $second) = _chron_to_hms($chron_ref);
    unless (check_time($hour, $minute, $second)) {
        carp "Illegal time specified (hour = $hour, minute = $minute, second = $second)";
    }
}

sub _chron_to_ymd {
    my $chron_ref = shift;
    return ($chron_ref->[5] + 1900, $chron_ref->[4] + 1, $chron_ref->[3]);
}

sub _chron_to_hms {
    my $chron_ref = shift;
    return ($chron_ref->[2], $chron_ref->[1], $chron_ref->[0]);
}

sub new {
	my $this = shift;
	my $class = ref($this) || $this;
	my $self = {};
	bless $self, $class;
	return $self->init(@_);
}
sub init ($;$$) {
	my $self = shift;
	my $dformat;
	$self->{'dateformat'} = $dformat = (scalar(@_) >= 2) ? $_[1] : _prefformat();
	($format_map{$dformat}) or croak 
		"Invalid date format '$dformat' from " . ((scalar(@_) >= 2) ? 'argument' : 'system preferences');
	$self->{'dmy_arrayref'} = [((@_) ? $self->dmy_map(shift) : localtime )] ;
	$debug and warn "(during init) \@\$self->{'dmy_arrayref'}: " . join(' ',@{$self->{'dmy_arrayref'}}) . "\n";
	return $self;
}
sub output ($;$) {
	my $self = shift;
	my $newformat = (@_) ? _recognize_format(shift) : _prefformat();
	return (eval {POSIX::strftime($posix_map{$newformat}, @{$self->{'dmy_arrayref'}})} || undef);
}
sub today ($;$) {		# NOTE: sets date value to today (and returns it in the requested or current format)
	my $class = shift;
	$class = ref($class) || $class;
	my $format = (@_) ? _recognize_format(shift) : _prefformat();
	return $class->new()->output($format);
}
sub _recognize_format($) {
	my $incoming = shift;
	($incoming eq 'syspref') and return _prefformat();
	(scalar grep (/^$incoming$/, keys %format_map) == 1) or croak "The format you asked for ('$incoming') is unrecognized.";
	return $incoming;
}
sub DHTMLcalendar ($;$) {	# interface to posix_map
	my $class = shift;
	my $format = (@_) ? shift : _prefformat();
	return $posix_map{$format};	
}
sub format {	# get or set dateformat: iso, metric, us, etc.
	my $self = shift;
	(@_) or return $self->{'dateformat'}; 
	$self->{'dateformat'} = _recognize_format(shift);
}
sub visual {
	my $self = shift;
	if (@_) {
		return $format_map{ _recognize_format(shift) };
	}
	$self eq __PACKAGE__ and return $format_map{_prefformat()};
	return $format_map{ eval { $self->{'dateformat'} } || _prefformat()} ;
}

# like the functions from the old C4::Date.pm
sub format_date {
	return __PACKAGE__ -> new(shift,'iso')->output((@_) ? shift : _prefformat());
}
sub format_date_in_iso {
	return __PACKAGE__ -> new(shift,_prefformat())->output('iso');
}

1;
__END__

=head1 C4::Dates.pm - a more object-oriented replacement for Date.pm.

The core problem to address is the multiplicity of formats used by different Koha 
installations around the world.  We needed to move away from any hard-coded values at
the script level, for example in initial form values or checks for min/max date. The
reason is clear when you consider string '07/01/2004'.  Depending on the format, it 
represents July 1st (us), or January 7th (metric), or an invalid value (iso).

The formats supported by Koha are:
    iso - ISO 8601 (extended)
    us - U.S. standard
    metric - European standard (slight misnomer, not really decimalized metric)
    sql - log format, not really for human consumption

=head2 ->new([string_date,][date_format])

Arguments to new() are optional.  If string_date is not supplied, the present system date is
used.  If date_format is not supplied, the system preference from C4::Context is used. 

Examples:

		my $now   = C4::Dates->new();
		my $date1 = C4::Dates->new("09-21-1989","us");
		my $date2 = C4::Dates->new("19890921    143907","sql");

=head2 ->output([date_format])

The date value is stored independent of any specific format.  Therefore any format can be 
invoked when displaying it. 

		my $date = C4::Dates->new();    # say today is July 12th, 2010
		print $date->output("iso");     # prints "2010-07-12"
		print "\n";
		print $date->output("metric");  # prints "12-07-2010"

However, it is still necessary to know the format of any incoming date value (e.g., 
setting the value of an object with new()).  Like new(), output() assumes the system preference
date format unless otherwise instructed.

=head2 ->format([date_format])

With no argument, format returns the object's current date_format.  Otherwise it attempts to 
set the object format to the supplied value.

Some previously desireable functions are now unnecessary.  For example, you might want a 
method/function to tell you whether or not a Dates.pm object is of the 'iso' type.  But you 
can see by this example that such a test is trivial to accomplish, and not necessary to 
include in the module:

		sub is_iso {
			my $self = shift;
			return ($self->format() eq "iso");
		}

Note: A similar function would need to be included for each format. 

Instead a dependent script can retrieve the format of the object directly and decide what to
do with it from there:

		my $date = C4::Dates->new();
		my $format = $date->format();
		($format eq "iso") or do_something($date);

Or if you just want to print a given value and format, no problem:

		my $date = C4::Dates->new("1989-09-21", "iso");
		print $date->output;

Alternatively:

		print C4::Dates->new("1989-09-21", "iso")->output;

Or even:

		print C4::Dates->new("21-09-1989", "metric")->output("iso");

=head2 "syspref" -- System Preference(s)

Perhaps you want to force data obtained in a known format to display according to the user's system
preference, without necessarily knowing what that preference is.  For this purpose, you can use the
psuedo-format argument "syspref".  

For example, to print an ISO date (from the database) in the <systempreference> format:

		my $date = C4::Dates->new($date_from_database,"iso");
		my $datestring_for_display = $date->output("syspref");
		print $datestring_for_display;

Or even:

		print C4::Dates->new($date_from_database,"iso")->output("syspref");

If you just want to know what the <systempreferece> is, a default Dates object can tell you:

		C4::Dates->new()->format();

=head2 ->DHMTLcalendar([date_format])

Returns the format string for DHTML Calendar Display based on date_format.  
If date_format is not supplied, the return is based on system preference.

		C4::Dates->DHTMLcalendar();	#  e.g., returns "%m/%d/%Y" for 'us' system preference

=head3 Error Handling

Some error handling is provided in this module, but not all.  Requesting an unknown format is a 
fatal error (because it is programmer error, not user error, typically).  

Scripts must still perform validation of user input.  Attempting to set an invalid value will 
return 0 or undefined, so a script might check as follows:

		my $date = C4::Dates->new($input) or deal_with_it("$input didn't work");

To validate before creating a new object, use the regexp method of the class:

		$input =~ C4::Dates->regexp("iso") or deal_with_it("input ($input) invalid as iso format");
		my $date = C4::Dates->new($input,"iso");

More verbose debugging messages are sent in the presence of non-zero $ENV{"DEBUG"}.

Notes: if the date in the db is null or empty, interpret null expiration to mean "never expires".

=head3 _prefformat()

This internal function is used to read the preferred date format
from the system preference table.  It reads the preference once, 
then caches it.

This replaces using the package variable $prefformat directly, and
specifically, doing a call to C4::Context->preference() during
module initialization.  That way, C4::Dates no longer has a
compile-time dependency on having a valid $dbh.

=head3 TO DO

If the date format is not in <systempreference>, we should send an error back to the user. 
This kind of check should be centralized somewhere.  Probably not here, though.

=cut

