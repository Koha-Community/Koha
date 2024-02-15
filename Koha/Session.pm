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

sub _get_session_params {
    my $class          = shift;
    my $storage_method = C4::Context->preference('SessionStorage');
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
    my $sessionID = $args->{sessionID};
    my $params = $class->_get_session_params();
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
