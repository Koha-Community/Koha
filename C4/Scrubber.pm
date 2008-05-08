package C4::Scrubber;
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
use HTML::Scrubber;

use C4::Context;
use C4::Debug;

use vars qw($VERSION @ISA);
use vars qw(%scrubbertypes $scrubbertype);

BEGIN {
	$VERSION = 0.01;
	# @ISA = qw(HTML::Scrubber);
}

INIT {
	%scrubbertypes = (
		default => {},	# place holder, default settings are below as fallbacks in call to constructor
		    tag => {},	# uses defaults
		comment => {
			allow   => [qw( br b i em big small )],
		},
		staff   => {
			default => [ 1 =>{'*'=>1} ],
			comment => 1,
		},
	);
}


sub new {
	my $fakeself = shift;	# not really OO, we return an HTML::Scrubber object.
	my $type  = (@_) ? shift : 'default';
	exists $scrubbertypes{$type} or croak "New called with unrecognized type '$type'";
	$debug and print STDERR "Building new Scrubber of type '$type'\n";
	my $settings = $scrubbertypes{$type};
	my $scrubber = HTML::Scrubber->new(
		allow   => exists $settings->{allow}   ? $settings->{allow}   : [],
		rules   => exists $settings->{rules}   ? $settings->{rules}   : [],
		default => exists $settings->{default} ? $settings->{default} : [ 0 =>{'*'=>0} ],
		comment => exists $settings->{comment} ? $settings->{comment} : 0,
		process => 0,
	);
	return $scrubber;
}


1;
__END__

=head1 C4::Sanitize

Standardized wrapper with settings for building HTML::Scrubber tailored to various koha inputs.
More verbose debugging messages are sent in the presence of non-zero $ENV{"DEBUG"}.

The default is to scrub everything, leaving no markup at all.  This is compatible with the expectations
for Tags.

=head2 

=head3 TO DO: Add real perldoc

=head2

=cut

