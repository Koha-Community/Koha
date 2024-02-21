package Koha::Session;

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
use CGI::Session;

use C4::Context;
use Koha::Caches;

=head1 NAME

Koha::Session - Session class for Koha

=head1 SYNOPSIS

  use Koha::Session;
  my $session = Koha::Session->get_session({ sessionID => $sessionID});

=head1 DESCRIPTION

This simple class exposes some basic methods for managing user sessions.

=head1 METHODS

=head2 get_session

  my $session = Koha::Session->get_session({ sessionID => $sessionID});

Given a session ID, retrieves the CGI::Session object used to store
the session's state.  The session object can be used to store
data that needs to be accessed by different scripts during a
user's session.

If the C<$sessionID> parameter is an empty string, a new session
will be created.

=cut

sub _get_session_params {
    my ( $class, $args ) = @_;
    my $storage_method = $args->{storage_method};
    $storage_method ||= C4::Context->preference('SessionStorage') || 'file';
    if ( $storage_method eq 'mysql' ) {
        my $dbh = C4::Context->dbh;
        return { dsn => "serializer:yamlxs;driver:MySQL;id:md5", dsn_args => { Handle => $dbh } };
    } elsif ( $storage_method eq 'Pg' ) {
        my $dbh = C4::Context->dbh;
        return { dsn => "serializer:yamlxs;driver:PostgreSQL;id:md5", dsn_args => { Handle => $dbh } };
    } elsif ( $storage_method eq 'memcached' && Koha::Caches->get_instance->memcached_cache ) {
        my $memcached = Koha::Caches->get_instance()->memcached_cache;
        return { dsn => "serializer:yamlxs;driver:memcached;id:md5", dsn_args => { Memcached => $memcached } };
    } else {

        # catch all defaults to tmp should work on all systems
        my $dir      = C4::Context::temporary_directory;
        my $instance = C4::Context->config('database')
            ;    #actually for packages not exactly the instance name, but generally safer to leave it as it is
        return { dsn => "serializer:yamlxs;driver:File;id:md5", dsn_args => { Directory => "$dir/cgisess_$instance" } };
    }
    return;
}

sub get_session {
    my ( $class, $args ) = @_;
    my $sessionID      = $args->{sessionID};
    my $storage_method = $args->{storage_method};
    my $params         = $class->_get_session_params( { storage_method => $storage_method } );
    my $session;
    if ($sessionID) {    # find existing
        CGI::Session::ErrorHandler->set_error(q{});    # clear error, cpan issue #111463
        $session = CGI::Session->load( $params->{dsn}, $sessionID, $params->{dsn_args} );
    } else {
        $session = CGI::Session->new( $params->{dsn}, $sessionID, $params->{dsn_args} );

        # no need to flush here
    }
    return $session;
}

1;
