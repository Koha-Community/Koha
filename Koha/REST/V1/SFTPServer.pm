package Koha::REST::V1::SFTPServer;

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

use Mojo::Base 'Mojolicious::Controller';

use Koha::SFTP::Servers;

use Try::Tiny qw( catch try );

=head1 API

=head2 Methods

=head3 test

Controller method that invokes Koha::SFTP::Server->test_conn

=cut

sub test {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $sftp_server = Koha::SFTP::Servers->find( $c->param('sftp_server_id') );
        return $c->render_resource_not_found("FTP/SFTP Server")
            unless $sftp_server;

        my $sftp_server_test_conn = $sftp_server->test_conn;

        return $c->render(
            status  => 200,
            openapi => $sftp_server_test_conn,
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

1;
