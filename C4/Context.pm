# Copyright 2002 Katipo Communications
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

# $Id$

package C4::Context;
use strict;
use DBI;

use vars qw($VERSION $AUTOLOAD),
	qw($context),
	qw(@context_stack);

$VERSION = do { my @v = '$Revision$' =~ /\d+/g;
		shift(@v) . "." . join("_", map {sprintf "%03d", $_ } @v); };

=head1 NAME

C4::Context - Maintain and manipulate the context of a Koha script

=head1 SYNOPSIS

  use C4::Context;

  use C4::Context("/path/to/koha.conf");

  $config_value = C4::Context->config("config_variable");
  $db_handle = C4::Context->dbh;
  $stopwordhash = C4::Context->stopwords;

=head1 DESCRIPTION

When a Koha script runs, it makes use of a certain number of things:
configuration settings in F</etc/koha.conf>, a connection to the Koha
database, and so forth. These things make up the I<context> in which
the script runs.

This module takes care of setting up the context for a script:
figuring out which configuration file to load, and loading it, opening
a connection to the right database, and so forth.

Most scripts will only use one context. They can simply have

  use C4::Context;

at the top.

Other scripts may need to use several contexts. For instance, if a
library has two databases, one for a certain collection, and the other
for everything else, it might be necessary for a script to use two
different contexts to search both databases. Such scripts should use
the C<&set_context> and C<&restore_context> functions, below.

By default, C4::Context reads the configuration from
F</etc/koha.conf>. This may be overridden by setting the C<$KOHA_CONF>
environment variable to the pathname of a configuration file to use.

=head1 METHODS

=over 2

=cut
#'
# In addition to what is said in the POD above, a Context object is a
# reference-to-hash with the following fields:
#
# config
#	A reference-to-hash whose keys and values are the
#	configuration variables and values specified in the config
#	file (/etc/koha.conf).
# dbh
#	A handle to the appropriate database for this context.
# dbh_stack
#	Used by &set_dbh and &restore_dbh to hold other database
#	handles for this context.

use constant CONFIG_FNAME => "/etc/koha.conf";
				# Default config file, if none is specified

$context = undef;		# Initially, no context is set
@context_stack = ();		# Initially, no saved contexts

# read_config_file
# Reads the specified Koha config file. Returns a reference-to-hash
# whose keys are the configuration variables, and whose values are the
# configuration values (duh).
# Returns undef in case of error.
sub read_config_file
{
	my $fname = shift;	# Config file to read
	my $retval = {};	# Return value: ref-to-hash holding the
				# configuration

	open (CONF, $fname) or return undef;

	while (<CONF>)
	{
		my $var;		# Variable name
		my $value;		# Variable value

		chomp;
		s/#.*//;		# Strip comments
		next if /^\s*$/;	# Ignore blank lines

		# Look for a line of the form
		#	var = value
		if (!/^\s*(\w+)\s*=\s*(.*?)\s*$/)
		{
			# FIXME - Complain about bogus line
			next;
		}

		# Found a variable assignment
		# FIXME - Ought to complain is this line sets a
		# variable that was already set.
		$var = $1;
		$value = $2;
		$retval->{$var} = $value;
	}
	close CONF;

	return $retval;
}

sub import
{
	my $package = shift;
	my $conf_fname = shift;		# Config file name
	my $context;

	# Create a new context from the given config file name, if
	# any, then set it as the current context.
	$context = new C4::Context($conf_fname);
	return undef if !defined($context);
	$context->set_context;
}

=item new

  $context = new C4::Context;
  $context = new C4::Context("/path/to/koha.conf");

Allocates a new context. Initializes the context from the specified
file, which defaults to either the file given by the C<$KOHA_CONF>
environment variable, or F</etc/koha.conf>.

C<&new> does not set this context as the new default context; for
that, use C<&set_context>.

=cut
#'
sub new
{
	my $class = shift;
	my $conf_fname = shift;		# Config file to load
	my $self = {};

	# check that the specified config file exists
	undef $conf_fname unless (defined $conf_fname && -e $conf_fname);
	# Figure out a good config file to load if none was specified.
	if (!defined($conf_fname))
	{
		# If the $KOHA_CONF environment variable is set, use
		# that. Otherwise, use the built-in default.
		$conf_fname = $ENV{"KOHA_CONF"} ||
				CONFIG_FNAME;
	}
	$self->{"config_file"} = $conf_fname;

	# Load the desired config file.
	$self->{"config"} = &read_config_file($conf_fname);
	return undef if !defined($self->{"config"});

	$self->{"dbh"} = undef;		# Database handle
	$self->{"stopwords"} = undef; # stopwords list

	bless $self, $class;
	return $self;
}

=item set_context

  $context = new C4::Context;
  $context->set_context();
or
  set_context C4::Context $context;

  ...
  restore_context C4::Context;

In some cases, it might be necessary for a script to use multiple
contexts. C<&set_context> saves the current context on a stack, then
sets the context to C<$context>, which will be used in future
operations. To restore the previous context, use C<&restore_context>.

=cut
#'
sub set_context
{
	my $self = shift;
	my $new_context;	# The context to set

	# Figure out whether this is a class or instance method call.
	#
	# We're going to make the assumption that control got here
	# through valid means, i.e., that the caller used an instance
	# or class method call, and that control got here through the
	# usual inheritance mechanisms. The caller can, of course,
	# break this assumption by playing silly buggers, but that's
	# harder to do than doing it properly, and harder to check
	# for.
	if (ref($self) eq "")
	{
		# Class method. The new context is the next argument.
		$new_context = shift;
	} else {
		# Instance method. The new context is $self.
		$new_context = $self;
	}

	# Save the old context, if any, on the stack
	push @context_stack, $context if defined($context);

	# Set the new context
	$context = $new_context;
}

=item restore_context

  &restore_context;

Restores the context set by C<&set_context>.

=cut
#'
sub restore_context
{
	my $self = shift;

	if ($#context_stack < 0)
	{
		# Stack underflow.
		die "Context stack underflow";
	}

	# Pop the old context and set it.
	$context = pop @context_stack;

	# FIXME - Should this return something, like maybe the context
	# that was current when this was called?
}

=item config

  $value = C4::Context->config("config_variable");

  $value = C4::Context->config_variable;

Returns the value of a variable specified in the configuration file
from which the current context was created.

The second form is more compact, but of course may conflict with
method names. If there is a configuration variable called "new", then
C<C4::Config-E<gt>new> will not return it.

=cut
#'
sub config
{
	my $self = shift;
	my $var = shift;		# The config variable to return

	return undef if !defined($context->{"config"});
			# Presumably $self->{config} might be
			# undefined if the config file given to &new
			# didn't exist, and the caller didn't bother
			# to check the return value.

	# Return the value of the requested config variable
	return $context->{"config"}{$var};
}

=item preference

  $sys_preference = C4::Context->preference("some_variable");

Looks up the value of the given system preference in the
systempreferences table of the Koha database, and returns it. If the
variable is not set, or in case of error, returns the undefined value.

=cut
#'
# FIXME - The preferences aren't likely to change over the lifetime of
# the script (and things might break if they did change), so perhaps
# this function should cache the results it finds.
sub preference
{
	my $self = shift;
	my $var = shift;		# The system preference to return
	my $retval;			# Return value
	my $dbh = C4::Context->dbh;	# Database handle
	my $sth;			# Database query handle

	# Look up systempreferences.variable==$var
	$retval = $dbh->selectrow_array(<<EOT);
		SELECT	value
		FROM	systempreferences
		WHERE	variable='$var'
		LIMIT	1
EOT
	return $retval;
}

# AUTOLOAD
# This implements C4::Config->foo, and simply returns
# C4::Context->config("foo"), as described in the documentation for
# &config, above.

# FIXME - Perhaps this should be extended to check &config first, and
# then &preference if that fails. OTOH, AUTOLOAD could lead to crappy
# code, so it'd probably be best to delete it altogether so as not to
# encourage people to use it.
sub AUTOLOAD
{
	my $self = shift;

	$AUTOLOAD =~ s/.*:://;		# Chop off the package name,
					# leaving only the function name.
	return $self->config($AUTOLOAD);
}

# _new_dbh
# Internal helper function (not a method!). This creates a new
# database connection from the data given in the current context, and
# returns it.
sub _new_dbh
{
	my $db_driver = $context->{"config"}{"db_scheme"} || "mysql";
		# FIXME - It should be possible to use "MySQL" instead
		# of "mysql", "PostgreSQL" instead of "Pg", and so
		# forth.
	my $db_name   = $context->{"config"}{"database"};
	my $db_host   = $context->{"config"}{"hostname"};
	my $db_user   = $context->{"config"}{"user"};
	my $db_passwd = $context->{"config"}{"pass"};

	return DBI->connect("DBI:$db_driver:$db_name:$db_host",
			    $db_user, $db_passwd);
}

=item dbh

  $dbh = C4::Context->dbh;

Returns a database handle connected to the Koha database for the
current context. If no connection has yet been made, this method
creates one, and connects to the database.

This database handle is cached for future use: if you call
C<C4::Context-E<gt>dbh> twice, you will get the same handle both
times. If you need a second database handle, use C<&new_dbh> and
possibly C<&set_dbh>.

=cut
#'
sub dbh
{
	my $self = shift;

	# If there's already a database handle, return it.
	return $context->{"dbh"} if defined($context->{"dbh"});

	# No database handle yet. Create one.
	$context->{"dbh"} = &_new_dbh();

	return $context->{"dbh"};
}

=item new_dbh

  $dbh = C4::Context->new_dbh;

Creates a new connection to the Koha database for the current context,
and returns the database handle (a C<DBI::db> object).

The handle is not saved anywhere: this method is strictly a
convenience function; the point is that it knows which database to
connect to so that the caller doesn't have to know.

=cut
#'
sub new_dbh
{
	my $self = shift;

	return &_new_dbh();
}

=item set_dbh

  $my_dbh = C4::Connect->new_dbh;
  C4::Connect->set_dbh($my_dbh);
  ...
  C4::Connect->restore_dbh;

C<&set_dbh> and C<&restore_dbh> work in a manner analogous to
C<&set_context> and C<&restore_context>.

C<&set_dbh> saves the current database handle on a stack, then sets
the current database handle to C<$my_dbh>.

C<$my_dbh> is assumed to be a good database handle.

=cut
#'
sub set_dbh
{
	my $self = shift;
	my $new_dbh = shift;

	# Save the current database handle on the handle stack.
	# We assume that $new_dbh is all good: if the caller wants to
	# screw himself by passing an invalid handle, that's fine by
	# us.
	push @{$context->{"dbh_stack"}}, $context->{"dbh"};
	$context->{"dbh"} = $new_dbh;
}

=item restore_dbh

  C4::Context->restore_dbh;

Restores the database handle saved by an earlier call to
C<C4::Context-E<gt>set_dbh>.

=cut
#'
sub restore_dbh
{
	my $self = shift;

	if ($#{$context->{"dbh_stack"}} < 0)
	{
		# Stack underflow
		die "DBH stack underflow";
	}

	# Pop the old database handle and set it.
	$context->{"dbh"} = pop @{$context->{"dbh_stack"}};

	# FIXME - If it is determined that restore_context should
	# return something, then this function should, too.
}

=item stopwords

  $dbh = C4::Context->stopwords;

Returns a hash with stopwords.

This hash is cached for future use: if you call
C<C4::Context-E<gt>stopwords> twice, you will get the same hash without real DB access

=cut
#'
sub stopwords
{
	my $retval = {};

	# If the hash already exists, return it.
	return $context->{"stopwords"} if defined($context->{"stopwords"});

	# No hash. Create one.
	$context->{"stopwords"} = &_new_stopwords();

	return $context->{"stopwords"};
}

# _new_stopwords
# Internal helper function (not a method!). This creates a new
# hash with stopwords
sub _new_stopwords
{
	my $dbh = C4::Context->dbh;
	my $stopwordlist;
	my $sth = $dbh->prepare("select word from stopwords");
	$sth->execute;
	while (my $stopword = $sth->fetchrow_array) {
		my $retval = {};
		$stopwordlist->{$stopword} = uc($stopword);
	}
	return $stopwordlist;
}

1;
__END__

=back

=head1 ENVIRONMENT

=over 4

=item C<KOHA_CONF>

Specifies the configuration file to read.

=back

=head1 SEE ALSO

DBI(3)

=head1 AUTHOR

Andrew Arensburger <arensb at ooblick dot com>

=cut
