package C4::Debug;

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

use Exporter;

# use CGI;
use vars qw($VERSION @ISA @EXPORT $debug $cgi_debug);
# use vars qw(@EXPORT_OK %EXPORT_TAGS);

BEGIN {
    $VERSION = 3.07.00.049;	# set the version for version checking
	@ISA       = qw(Exporter);
	@EXPORT    = qw($debug $cgi_debug);
	# @EXPOR_OK    = qw();
	# %EXPORT_TAGS = ( all=>[qw($debug $cgi_debug)], );
}

BEGIN {
	# this stuff needs a begin block too, since dependencies might alter their compilations
	# for example, adding DataDumper

	$debug = $ENV{KOHA_DEBUG} || $ENV{DEBUG} || 0;

	# CGI->new conflicts w/ some upload functionality, 
	# since we would get the "first" CGI object here.
	# Instead we have to parse for ourselves if we want QUERY_STRING triggers.
	#	my $query = CGI->new();		# conflicts!
	#	$cgi_debug = $ENV{KOHA_CGI_DEBUG} || $query->param('debug') || 0;

	$cgi_debug = $ENV{KOHA_CGI_DEBUG} || 0;
	unless ($cgi_debug or not $ENV{QUERY_STRING}) {
		foreach (split /\&/,  $ENV{QUERY_STRING}) {
			/^debug\=(.+)$/ or next;
			$cgi_debug = $1;
			last;
		}
	}
	unless ($debug =~ /^\d$/) {
		warn "Invalid \$debug value attempted: $debug";
		$debug=1;
	}
	unless ($cgi_debug =~ /^\d$/) {
		$debug and
		warn "Invalid \$cgi_debug value attempted: $cgi_debug";
		$cgi_debug=1;
	}
}

# sub import {
# 	print STDERR __PACKAGE__ . " (Debug) import @_\n";
# 	C4::Debug->export_to_level(1, @_);
# }

1;
__END__

=head1 NAME 

C4::Debug - Standardized, centralized, exported debug switches.

=head1 SYNOPSIS

	use C4::Debug;

=head1 DESCRIPTION

The purpose of this module is to centralize some of the "switches" that turn debugging
off and on in Koha.  Most often, this functionality will be provided via C4::Context.
C4::Debug is separate to preserve the relatively stable state of Context, and 
because other code will use C4::Debug without invoking Context.

Although centralization is our intention, 
for logical and security reasons, several approaches to debugging need to be 
kept separate.  Information useful to developers in one area will not necessarily
be useful or even available to developers in another area. 

For example, the designer of template-influenced javascript my want to be able to
trigger javascript's alert function to display certain variable values, to verify
the template selection is being performed correctly.  For this purpose the presence
of a javascript "debug" variable might be a good switch.  

Meanwhile, where security coders (say, for LDAP Auth) will appreciate low level feedback about
Authentication transactions, an environmental system variable might be a good switch.  
However, clearly we would not want to expose that same information (e.g., entire LDAP records)
to the web interface based on a javascript variable (even if it were possible)!  

All that is a long way of saying THERE ARE SECURITY IMPLICATIONS to turning on 
debugging in various parts of the system, so don't treat them all the same or confuse them.

=head1 VARIABLES / AREAS

=head2 $debug - System, general
The general purpose debug switch.  

=head3 How to Set $debug:

=over

=item environmental variable DEBUG or KOHA_DEBUG.  In bash, you might do:

	export KOHA_DEBUG=1;
	perl t/Auth.t;

=item Keep in mind that your webserver will not be running in the same environment as your shell.
However, for development purposes, the same effect can be had by using Apache's SET_ENV
command with ERROR_LOG enabled for your VirtualHost.  Not intended for production systems.

=item You can force the value from perl directly, like:

	use C4::Debug;
	use C4::Dates;
	BEGIN { $C4::Debug::debug = 1; }
	# now any other dependencies that also use C4::Debug will have debugging ON.

=back

=head2 $cgi_debug (CGI params) The web-based debug switch.

=head3 How to Set $cgi_debug:

=over

=item From a web browser, for example by supplying a non-zero debug parameter (1 to 9):

	http://www.mylibrary.org/cgi-bin/koha/opac-search.pl?q=history&debug=1

=item Or in HTML, add a similar input parameter:

	<input type="hidden" name="debug" value="1" />

=item Or from shell (or Apache), set KOHA_CGI_DEBUG.

=back 

The former methods mean $cgi_debug is exposed.  Do NOT use it to trigger any actions that you would
not allow a (potentially anonymous) end user to perform.  Dumping sensitive data, directory listings, or 
emailing yourself a test message would all be bad actions to tie to $cgi_debug.

=head1 OTHER SOURCES of Debug Switches

=head2 System Preferences

=cut

=head2 Database Debug

Debugging at the database level might be useful.  Koha does not currently integrate any such 
capability.

=head1 CONVENTIONS

Debug values range from 0 to 9.  At zero (the default), debugging is off.  

=head1 AUTHOR

Joe Atzberger
atz AT liblime DOT com

=head1 SEE ALSO

CGI(3)

C4::Context

=cut

