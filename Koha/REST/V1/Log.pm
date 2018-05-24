package Koha::REST::V1::Log;

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use Mojo::Base 'Mojolicious::Controller';
use C4::Log;

sub get {
    my $c = shift->openapi->valid_input or return;

    my $params = $c->req->params->to_hash;

    my $logs = C4::Log::GetLogs($params->{datefrom}, $params->{dateto}, $params->{user}, $params->{modules} , $params->{action}, $params->{object}, $params->{info}, $params->{interfaces});
    unless ($logs) {
        return $c->render( status => 404, openapi =>
            {error => "Missing log data"});
    }

    return $c->render( status => 200, openapi => $logs);
}

sub add {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $params = $c->req->params->to_hash;

        C4::Log::logaction($params->{module}, $params->{action}, $params->{object}, $params->{info});
        return $c->render( status => 200, openapi => {} );
    }
    catch {
        Koha::Exceptions::rethrow_exception($_);
    };
}

1;
