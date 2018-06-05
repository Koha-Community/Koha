package C4::Context;

# Copyright 2002 Katipo Communications
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

use Modern::Perl;

use vars qw($AUTOLOAD $context @context_stack);
BEGIN {
	if ($ENV{'HTTP_USER_AGENT'})	{
		require CGI::Carp;
        # FIXME for future reference, CGI::Carp doc says
        #  "Note that fatalsToBrowser does not work with mod_perl version 2.0 and higher."
		import CGI::Carp qw(fatalsToBrowser);
			sub handle_errors {
			    my $msg = shift;
			    my $debug_level;
			    eval {C4::Context->dbh();};
			    if ($@){
				$debug_level = 1;
			    } 
			    else {
				$debug_level =  C4::Context->preference("DebugLevel");
			    }

                print q(<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
                            "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
                       <html lang="en" xml:lang="en"  xmlns="http://www.w3.org/1999/xhtml">
                       <head><title>Koha Error</title></head>
                       <body>
                );
				if ($debug_level eq "2"){
					# debug 2 , print extra info too.
					my %versions = get_versions();

		# a little example table with various version info";
					print "
						<h1>Koha error</h1>
						<p>The following fatal error has occurred:</p> 
                        <pre><code>$msg</code></pre>
						<table>
						<tr><th>Apache</th><td>  $versions{apacheVersion}</td></tr>
						<tr><th>Koha</th><td>    $versions{kohaVersion}</td></tr>
						<tr><th>Koha DB</th><td> $versions{kohaDbVersion}</td></tr>
						<tr><th>MySQL</th><td>   $versions{mysqlVersion}</td></tr>
						<tr><th>OS</th><td>      $versions{osVersion}</td></tr>
						<tr><th>Perl</th><td>    $versions{perlVersion}</td></tr>
						</table>";

				} elsif ($debug_level eq "1"){
					print "
						<h1>Koha error</h1>
						<p>The following fatal error has occurred:</p> 
                        <pre><code>$msg</code></pre>";
				} else {
					print "<p>production mode - trapped fatal error</p>";
				}       
                print "</body></html>";
			}
		#CGI::Carp::set_message(\&handle_errors);
		## give a stack backtrace if KOHA_BACKTRACES is set
		## can't rely on DebugLevel for this, as we're not yet connected
		if ($ENV{KOHA_BACKTRACES}) {
			$main::SIG{__DIE__} = \&CGI::Carp::confess;
		}

        # Redefine multi_param if cgi version is < 4.08
        # Remove the "CGI::param called in list context" warning in this case
        require CGI; # Can't check version without the require.
        if (!defined($CGI::VERSION) || $CGI::VERSION < 4.08) {
            no warnings 'redefine';
            *CGI::multi_param = \&CGI::param;
            use warnings 'redefine';
            $CGI::LIST_CONTEXT_WARN = 0;
        }
    }  	# else there is no browser to send fatals to!
}

use Carp;
use DateTime::TimeZone;
use Encode;
use File::Spec;
use Module::Load::Conditional qw(can_load);
use POSIX ();
use ZOOM;

use C4::Boolean;
use C4::Debug;
use Koha::Caches;
use Koha::Config::SysPref;
use Koha::Config::SysPrefs;
use Koha::Config;
use Koha;

=head1 NAME

C4::Context - Maintain and manipulate the context of a Koha script

=head1 SYNOPSIS

  use C4::Context;

  use C4::Context("/path/to/koha-conf.xml");

  $config_value = C4::Context->config("config_variable");

  $koha_preference = C4::Context->preference("preference");

  $db_handle = C4::Context->dbh;

  $Zconn = C4::Context->Zconn;

=head1 DESCRIPTION

When a Koha script runs, it makes use of a certain number of things:
configuration settings in F</etc/koha/koha-conf.xml>, a connection to the Koha
databases, and so forth. These things make up the I<context> in which
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
F</etc/koha/koha-conf.xml>. This may be overridden by setting the C<$KOHA_CONF>
environment variable to the pathname of a configuration file to use.

=head1 METHODS

=cut

#'
# In addition to what is said in the POD above, a Context object is a
# reference-to-hash with the following fields:
#
# config
#    A reference-to-hash whose keys and values are the
#    configuration variables and values specified in the config
#    file (/etc/koha/koha-conf.xml).
# dbh
#    A handle to the appropriate database for this context.
# dbh_stack
#    Used by &set_dbh and &restore_dbh to hold other database
#    handles for this context.
# Zconn
#     A connection object for the Zebra server

$context = undef;        # Initially, no context is set
@context_stack = ();        # Initially, no saved contexts

=head2 db_scheme2dbi

    my $dbd_driver_name = C4::Context::db_schema2dbi($scheme);

This routines translates a database type to part of the name
of the appropriate DBD driver to use when establishing a new
database connection.  It recognizes 'mysql' and 'Pg'; if any
other scheme is supplied it defaults to 'mysql'.

=cut

sub db_scheme2dbi {
    my $scheme = shift // '';
    return $scheme eq 'Pg' ? $scheme : 'mysql';
}

sub import {
    # Create the default context ($C4::Context::Context)
    # the first time the module is called
    # (a config file can be optionaly passed)

    # default context already exists?
    return if $context;

    # no ? so load it!
    my ($pkg,$config_file) = @_ ;
    my $new_ctx = __PACKAGE__->new($config_file);
    return unless $new_ctx;

    # if successfully loaded, use it by default
    $new_ctx->set_context;
    1;
}

=head2 new

  $context = new C4::Context;
  $context = new C4::Context("/path/to/koha-conf.xml");

Allocates a new context. Initializes the context from the specified
file, which defaults to either the file given by the C<$KOHA_CONF>
environment variable, or F</etc/koha/koha-conf.xml>.

It saves the koha-conf.xml values in the declared memcached server(s)
if currently available and uses those values until them expire and
re-reads them.

C<&new> does not set this context as the new default context; for
that, use C<&set_context>.

=cut

#'
# Revision History:
# 2004-08-10 A. Tarallo: Added check if the conf file is not empty
sub new {
    my $class = shift;
    my $conf_fname = shift;        # Config file to load
    my $self = {};

    # check that the specified config file exists and is not empty
    undef $conf_fname unless 
        (defined $conf_fname && -s $conf_fname);
    # Figure out a good config file to load if none was specified.
    unless ( defined $conf_fname ) {
        $conf_fname = Koha::Config->guess_koha_conf;
        unless ( $conf_fname ) {
            warn "unable to locate Koha configuration file koha-conf.xml";
            return;
        }
    }

    my $conf_cache = Koha::Caches->get_instance('config');
    my $config_from_cache;
    if ( $conf_cache->cache ) {
        $self = $conf_cache->get_from_cache('koha_conf');
    }
    unless ( $self and %$self ) {
        $self = Koha::Config->read_from_file($conf_fname);
        if ( $conf_cache->memcached_cache ) {
            # FIXME it may be better to use the memcached servers from the config file
            # to cache it
            $conf_cache->set_in_cache('koha_conf', $self)
        }
    }
    unless ( exists $self->{config} or defined $self->{config} ) {
        warn "The config file ($conf_fname) has not been parsed correctly";
        return;
    }

    $self->{"Zconn"} = undef;    # Zebra Connections
    $self->{"userenv"} = undef;        # User env
    $self->{"activeuser"} = undef;        # current active user
    $self->{"shelves"} = undef;
    $self->{tz} = undef; # local timezone object

    bless $self, $class;
    $self->{db_driver} = db_scheme2dbi($self->config('db_scheme'));  # cache database driver
    return $self;
}

=head2 set_context

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
    my $new_context;    # The context to set

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

=head2 restore_context

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

=head2 config

  $value = C4::Context->config("config_variable");

  $value = C4::Context->config_variable;

Returns the value of a variable specified in the configuration file
from which the current context was created.

The second form is more compact, but of course may conflict with
method names. If there is a configuration variable called "new", then
C<C4::Config-E<gt>new> will not return it.

=cut

sub _common_config {
	my $var = shift;
	my $term = shift;
    return if !defined($context->{$term});
       # Presumably $self->{$term} might be
       # undefined if the config file given to &new
       # didn't exist, and the caller didn't bother
       # to check the return value.

    # Return the value of the requested config variable
    return $context->{$term}->{$var};
}

sub config {
	return _common_config($_[1],'config');
}
sub zebraconfig {
	return _common_config($_[1],'server');
}
sub ModZebrations {
	return _common_config($_[1],'serverinfo');
}

=head2 preference

  $sys_preference = C4::Context->preference('some_variable');

Looks up the value of the given system preference in the
systempreferences table of the Koha database, and returns it. If the
variable is not set or does not exist, undef is returned.

In case of an error, this may return 0.

Note: It is impossible to tell the difference between system
preferences which do not exist, and those whose values are set to NULL
with this method.

=cut

my $syspref_cache = Koha::Caches->get_instance('syspref');
my $use_syspref_cache = 1;
sub preference {
    my $self = shift;
    my $var  = shift;    # The system preference to return

    return $ENV{"OVERRIDE_SYSPREF_$var"}
        if defined $ENV{"OVERRIDE_SYSPREF_$var"};

    $var = lc $var;

    if ($use_syspref_cache) {
        $syspref_cache = Koha::Caches->get_instance('syspref') unless $syspref_cache;
        my $cached_var = $syspref_cache->get_from_cache("syspref_$var");
        return $cached_var if defined $cached_var;
    }

    my $syspref;
    eval { $syspref = Koha::Config::SysPrefs->find( lc $var ) };
    my $value = $syspref ? $syspref->value() : undef;

    if ( $use_syspref_cache ) {
        $syspref_cache->set_in_cache("syspref_$var", $value);
    }
    return $value;
}

sub boolean_preference {
    my $self = shift;
    my $var = shift;        # The system preference to return
    my $it = preference($self, $var);
    return defined($it)? C4::Boolean::true_p($it): undef;
}

=head2 enable_syspref_cache

  C4::Context->enable_syspref_cache();

Enable the in-memory syspref cache used by C4::Context. This is the
default behavior.

=cut

sub enable_syspref_cache {
    my ($self) = @_;
    $use_syspref_cache = 1;
    # We need to clear the cache to have it up-to-date
    $self->clear_syspref_cache();
}

=head2 disable_syspref_cache

  C4::Context->disable_syspref_cache();

Disable the in-memory syspref cache used by C4::Context. This should be
used with Plack and other persistent environments.

=cut

sub disable_syspref_cache {
    my ($self) = @_;
    $use_syspref_cache = 0;
    $self->clear_syspref_cache();
}

=head2 clear_syspref_cache

  C4::Context->clear_syspref_cache();

cleans the internal cache of sysprefs. Please call this method if
you update the systempreferences table. Otherwise, your new changes
will not be seen by this process.

=cut

sub clear_syspref_cache {
    return unless $use_syspref_cache;
    $syspref_cache->flush_all;
}

=head2 set_preference

  C4::Context->set_preference( $variable, $value, [ $explanation, $type, $options ] );

This updates a preference's value both in the systempreferences table and in
the sysprefs cache. If the optional parameters are provided, then the query
becomes a create. It won't update the parameters (except value) for an existing
preference.

=cut

sub set_preference {
    my ( $self, $variable, $value, $explanation, $type, $options ) = @_;

    my $variable_case = $variable;
    $variable = lc $variable;

    my $syspref = Koha::Config::SysPrefs->find($variable);
    $type =
        $type    ? $type
      : $syspref ? $syspref->type
      :            undef;

    $value = 0 if ( $type && $type eq 'YesNo' && $value eq '' );

    # force explicit protocol on OPACBaseURL
    if ( $variable eq 'opacbaseurl' && $value && substr( $value, 0, 4 ) !~ /http/ ) {
        $value = 'http://' . $value;
    }

    if ($syspref) {
        $syspref->set(
            {   ( defined $value ? ( value       => $value )       : () ),
                ( $explanation   ? ( explanation => $explanation ) : () ),
                ( $type          ? ( type        => $type )        : () ),
                ( $options       ? ( options     => $options )     : () ),
            }
        )->store;
    } else {
        $syspref = Koha::Config::SysPref->new(
            {   variable    => $variable_case,
                value       => $value,
                explanation => $explanation || undef,
                type        => $type,
                options     => $options || undef,
            }
        )->store();
    }

    if ( $use_syspref_cache ) {
        $syspref_cache->set_in_cache( "syspref_$variable", $value );
    }

    return $syspref;
}

=head2 delete_preference

    C4::Context->delete_preference( $variable );

This deletes a system preference from the database. Returns a true value on
success. Failure means there was an issue with the database, not that there
was no syspref of the name.

=cut

sub delete_preference {
    my ( $self, $var ) = @_;

    if ( Koha::Config::SysPrefs->find( $var )->delete ) {
        if ( $use_syspref_cache ) {
            $syspref_cache->clear_from_cache("syspref_$var");
        }

        return 1;
    }
    return 0;
}

=head2 Zconn

  $Zconn = C4::Context->Zconn

Returns a connection to the Zebra database

C<$self> 

C<$server> one of the servers defined in the koha-conf.xml file

C<$async> whether this is a asynchronous connection

=cut

sub Zconn {
    my ($self, $server, $async ) = @_;
    my $cache_key = join ('::', (map { $_ // '' } ($server, $async )));
    if ( (!defined($ENV{GATEWAY_INTERFACE})) && defined($context->{"Zconn"}->{$cache_key}) && (0 == $context->{"Zconn"}->{$cache_key}->errcode()) ) {
        # if we are running the script from the commandline, lets try to use the caching
        return $context->{"Zconn"}->{$cache_key};
    }
    $context->{"Zconn"}->{$cache_key}->destroy() if defined($context->{"Zconn"}->{$cache_key}); #destroy old connection before making a new one
    $context->{"Zconn"}->{$cache_key} = &_new_Zconn( $server, $async );
    return $context->{"Zconn"}->{$cache_key};
}

=head2 _new_Zconn

$context->{"Zconn"} = &_new_Zconn($server,$async);

Internal function. Creates a new database connection from the data given in the current context and returns it.

C<$server> one of the servers defined in the koha-conf.xml file

C<$async> whether this is a asynchronous connection

C<$auth> whether this connection has rw access (1) or just r access (0 or NULL)

=cut

sub _new_Zconn {
    my ( $server, $async ) = @_;

    my $tried=0; # first attempt
    my $Zconn; # connection object
    my $elementSetName;
    my $index_mode;
    my $syntax;

    $server //= "biblioserver";

    if ( $server eq 'biblioserver' ) {
        $index_mode = $context->{'config'}->{'zebra_bib_index_mode'} // 'dom';
    } elsif ( $server eq 'authorityserver' ) {
        $index_mode = $context->{'config'}->{'zebra_auth_index_mode'} // 'dom';
    }

    if ( $index_mode eq 'grs1' ) {
        $elementSetName = 'F';
        $syntax = ( $context->preference("marcflavour") eq 'UNIMARC' )
                ? 'unimarc'
                : 'usmarc';

    } else { # $index_mode eq 'dom'
        $syntax = 'xml';
        $elementSetName = 'marcxml';
    }

    my $host = $context->{'listen'}->{$server}->{'content'};
    my $user = $context->{"serverinfo"}->{$server}->{"user"};
    my $password = $context->{"serverinfo"}->{$server}->{"password"};
    eval {
        # set options
        my $o = new ZOOM::Options();
        $o->option(user => $user) if $user && $password;
        $o->option(password => $password) if $user && $password;
        $o->option(async => 1) if $async;
        $o->option(cqlfile=> $context->{"server"}->{$server}->{"cql2rpn"});
        $o->option(cclfile=> $context->{"serverinfo"}->{$server}->{"ccl2rpn"});
        $o->option(preferredRecordSyntax => $syntax);
        $o->option(elementSetName => $elementSetName) if $elementSetName;
        $o->option(databaseName => $context->{"config"}->{$server}||"biblios");

        # create a new connection object
        $Zconn= create ZOOM::Connection($o);

        # forge to server
        $Zconn->connect($host, 0);

        # check for errors and warn
        if ($Zconn->errcode() !=0) {
            warn "something wrong with the connection: ". $Zconn->errmsg();
        }
    };
    return $Zconn;
}

# _new_dbh
# Internal helper function (not a method!). This creates a new
# database connection from the data given in the current context, and
# returns it.
sub _new_dbh
{

    Koha::Database->schema({ new => 1 })->storage->dbh;
}

=head2 dbh

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
    my $params = shift;
    my $sth;

    unless ( $params->{new} ) {
        return Koha::Database->schema->storage->dbh;
    }

    return Koha::Database->schema({ new => 1 })->storage->dbh;
}

=head2 new_dbh

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

    return &dbh({ new => 1 });
}

=head2 set_dbh

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

=head2 restore_dbh

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

=head2 queryparser

  $queryparser = C4::Context->queryparser

Returns a handle to an initialized Koha::QueryParser::Driver::PQF object.

=cut

sub queryparser {
    my $self = shift;
    unless (defined $context->{"queryparser"}) {
        $context->{"queryparser"} = &_new_queryparser();
    }

    return
      defined( $context->{"queryparser"} )
      ? $context->{"queryparser"}->new
      : undef;
}

=head2 _new_queryparser

Internal helper function to create a new QueryParser object. QueryParser
is loaded dynamically so as to keep the lack of the QueryParser library from
getting in anyone's way.

=cut

sub _new_queryparser {
    my $qpmodules = {
        'OpenILS::QueryParser'           => undef,
        'Koha::QueryParser::Driver::PQF' => undef
    };
    if ( can_load( 'modules' => $qpmodules ) ) {
        my $QParser     = Koha::QueryParser::Driver::PQF->new();
        my $config_file = $context->config('queryparser_config');
        $config_file ||= '/etc/koha/searchengine/queryparser.yaml';
        if ( $QParser->load_config($config_file) ) {
            # Set 'keyword' as the default search class
            $QParser->default_search_class('keyword');
            # TODO: allow indexes to be configured in the database
            return $QParser;
        }
    }
    return;
}

=head2 userenv

  C4::Context->userenv;

Retrieves a hash for user environment variables.

This hash shall be cached for future use: if you call
C<C4::Context-E<gt>userenv> twice, you will get the same hash without real DB access

=cut

#'
sub userenv {
    my $var = $context->{"activeuser"};
    if (defined $var and defined $context->{"userenv"}->{$var}) {
        return $context->{"userenv"}->{$var};
    } else {
        return;
    }
}

=head2 set_userenv

  C4::Context->set_userenv($usernum, $userid, $usercnum,
                           $userfirstname, $usersurname,
                           $userbranch, $branchname, $userflags,
                           $emailaddress, $branchprinter, $shibboleth);

Establish a hash of user environment variables.

set_userenv is called in Auth.pm

=cut

#'
sub set_userenv {
    shift @_;
    my ($usernum, $userid, $usercnum, $userfirstname, $usersurname, $userbranch, $branchname, $userflags, $emailaddress, $branchprinter, $shibboleth)=
    map { Encode::is_utf8( $_ ) ? $_ : Encode::decode('UTF-8', $_) } # CGI::Session doesn't handle utf-8, so we decode it here
    @_;
    my $var=$context->{"activeuser"} || '';
    my $cell = {
        "number"     => $usernum,
        "id"         => $userid,
        "cardnumber" => $usercnum,
        "firstname"  => $userfirstname,
        "surname"    => $usersurname,
        #possibly a law problem
        "branch"     => $userbranch,
        "branchname" => $branchname,
        "flags"      => $userflags,
        "emailaddress"     => $emailaddress,
        "branchprinter"    => $branchprinter,
        "shibboleth" => $shibboleth,
    };
    $context->{userenv}->{$var} = $cell;
    return $cell;
}

sub set_shelves_userenv {
	my ($type, $shelves) = @_ or return;
	my $activeuser = $context->{activeuser} or return;
	$context->{userenv}->{$activeuser}->{barshelves} = $shelves if $type eq 'bar';
	$context->{userenv}->{$activeuser}->{pubshelves} = $shelves if $type eq 'pub';
	$context->{userenv}->{$activeuser}->{totshelves} = $shelves if $type eq 'tot';
}

sub get_shelves_userenv {
	my $active;
	unless ($active = $context->{userenv}->{$context->{activeuser}}) {
		$debug and warn "get_shelves_userenv cannot retrieve context->{userenv}->{context->{activeuser}}";
		return;
	}
	my $totshelves = $active->{totshelves} or undef;
	my $pubshelves = $active->{pubshelves} or undef;
	my $barshelves = $active->{barshelves} or undef;
	return ($totshelves, $pubshelves, $barshelves);
}

=head2 _new_userenv

  C4::Context->_new_userenv($session);  # FIXME: This calling style is wrong for what looks like an _internal function

Builds a hash for user environment variables.

This hash shall be cached for future use: if you call
C<C4::Context-E<gt>userenv> twice, you will get the same hash without real DB access

_new_userenv is called in Auth.pm

=cut

#'
sub _new_userenv
{
    shift;  # Useless except it compensates for bad calling style
    my ($sessionID)= @_;
     $context->{"activeuser"}=$sessionID;
}

=head2 _unset_userenv

  C4::Context->_unset_userenv;

Destroys the hash for activeuser user environment variables.

=cut

#'

sub _unset_userenv
{
    my ($sessionID)= @_;
    undef $context->{"activeuser"} if ($context->{"activeuser"} eq $sessionID);
}


=head2 get_versions

  C4::Context->get_versions

Gets various version info, for core Koha packages, Currently called from carp handle_errors() sub, to send to browser if 'DebugLevel' syspref is set to '2'.

=cut

#'

# A little example sub to show more debugging info for CGI::Carp
sub get_versions {
    my %versions;
    $versions{kohaVersion}  = Koha::version();
    $versions{kohaDbVersion} = C4::Context->preference('version');
    $versions{osVersion} = join(" ", POSIX::uname());
    $versions{perlVersion} = $];
    {
        no warnings qw(exec); # suppress warnings if unable to find a program in $PATH
        $versions{mysqlVersion}  = `mysql -V`;
        $versions{apacheVersion} = (`apache2ctl -v`)[0];
        $versions{apacheVersion} = `httpd -v`             unless  $versions{apacheVersion} ;
        $versions{apacheVersion} = `httpd2 -v`            unless  $versions{apacheVersion} ;
        $versions{apacheVersion} = `apache2 -v`           unless  $versions{apacheVersion} ;
        $versions{apacheVersion} = `/usr/sbin/apache2 -v` unless  $versions{apacheVersion} ;
    }
    return %versions;
}

=head2 timezone

  my $C4::Context->timzone

  Returns a timezone code for the instance of Koha

=cut

sub timezone {
    my $self = shift;

    my $timezone = C4::Context->config('timezone') || $ENV{TZ} || 'local';
    if ( !DateTime::TimeZone->is_valid_name( $timezone ) ) {
        warn "Invalid timezone in koha-conf.xml ($timezone)";
        $timezone = 'local';
    }

    return $timezone;
}

=head2 tz

  C4::Context->tz

  Returns a DateTime::TimeZone object for the system timezone

=cut

sub tz {
    my $self = shift;
    if (!defined $context->{tz}) {
        my $timezone = $self->timezone;
        $context->{tz} = DateTime::TimeZone->new(name => $timezone);
    }
    return $context->{tz};
}


=head2 IsSuperLibrarian

    C4::Context->IsSuperLibrarian();

=cut

sub IsSuperLibrarian {
    my $userenv = C4::Context->userenv;

    unless ( $userenv and exists $userenv->{flags} ) {
        # If we reach this without a user environment,
        # assume that we're running from a command-line script,
        # and act as a superlibrarian.
        carp("C4::Context->userenv not defined!");
        return 1;
    }

    return ($userenv->{flags}//0) % 2;
}

=head2 interface

Sets the current interface for later retrieval in any Perl module

    C4::Context->interface('opac');
    C4::Context->interface('intranet');
    my $interface = C4::Context->interface;

=cut

sub interface {
    my ($class, $interface) = @_;

    if (defined $interface) {
        $interface = lc $interface;
        if ($interface eq 'opac' || $interface eq 'intranet' || $interface eq 'sip' || $interface eq 'commandline') {
            $context->{interface} = $interface;
        } else {
            warn "invalid interface : '$interface'";
        }
    }

    return $context->{interface} // 'opac';
}

# always returns a string for OK comparison via "eq" or "ne"
sub mybranch {
    C4::Context->userenv           or return '';
    return C4::Context->userenv->{branch} || '';
}

=head2 only_my_library

    my $test = C4::Context->only_my_library;

    Returns true if you enabled IndependentBranches and the current user
    does not have superlibrarian permissions.

=cut

sub only_my_library {
    return
         C4::Context->preference('IndependentBranches')
      && C4::Context->userenv
      && !C4::Context->IsSuperLibrarian()
      && C4::Context->userenv->{branch};
}

=head3 temporary_directory

Returns root directory for temporary storage

=cut

sub temporary_directory {
    my ( $class ) = @_;
    return C4::Context->config('tmp_path') || File::Spec->tmpdir;
}


1;

__END__

=head1 ENVIRONMENT

=head2 C<KOHA_CONF>

Specifies the configuration file to read.

=head1 SEE ALSO

XML::Simple

=head1 AUTHORS

Andrew Arensburger <arensb at ooblick dot com>

Joshua Ferraro <jmf at liblime dot com>

