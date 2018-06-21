package Koha::REST::V1::Notice;

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

use Koha::Notice::Messages;

use Try::Tiny;

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $params = $c->req->query_params->to_hash;
            $params = _between_time_queued($params); # Construct 'time_queued'
        my $notices;
        if (keys %$params) {
            my @valid_params = Koha::Notice::Messages->columns;
            foreach my $key (keys %$params) {
                delete $params->{$key} unless grep { $key eq $_ } @valid_params;
            }
            $notices = Koha::Notice::Messages->search($params);
        } else {
            $notices = Koha::Notice::Messages->search;
        }

        return $c->render(status => 200, openapi => $notices);
    }
    catch {
        Koha::Exceptions::rethrow_exception($_);
    };
}

sub get {
    my $c = shift->openapi->valid_input or return;

    my $message_id = $c->validation->param('message_id');
    my $notice;
    return try {
        $notice = Koha::Notice::Messages->find($message_id);

        unless ($notice) {
            return $c->render( status  => 404,
                               openapi => { error => "Notice not found" } );
        }

        return $c->render(status => 200, openapi => $notice);
    }
    catch {
        Koha::Exceptions::rethrow_exception($_);
    };
}

sub add {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $body = $c->req->json;

        my $notice = Koha::Notice::Message->new($body)->store;
           $notice = Koha::Notice::Messages->find($notice->message_id);
        return $c->render(status => 201, openapi => $notice);
    }
    catch {
        Koha::Exceptions::rethrow_exception($_);
    };
}

sub edit {
    my $c = shift->openapi->valid_input or return;

    my $notice;
    return try {
        my $message_id = $c->validation->param('message_id');
        $notice = Koha::Notice::Messages->find($message_id);
        my $body = $c->req->json;

        $notice->set($body);
        return $c->render( status => 204, openapi => {}) unless $notice->is_changed;
        $notice->store;
        return $c->render( status => 200, openapi => $notice);
    }
    catch {
        unless ($notice) {
            return $c->render( status  => 404,
                               openapi => { error => "Notice not found" } );
        }
        Koha::Exceptions::rethrow_exception($_);
    };
}

sub patch {
    return edit(@_);
}

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $notice = Koha::Notice::Messages->find($c->validation->param('message_id'));
    unless ($notice) {
        return $c->render( status  => 404,
                           openapi => { error => "Notice not found" } );
    }

    my $res = $notice->delete;

    if ($res eq '1') {
        return $c->render( status => 204, openapi => {});
    } elsif ($res eq '-1') {
        return $c->render( status => 404, openapi => {});
    } else {
        return $c->render( status => 400, openapi => {});
    }
}

sub resend {
    my $c = shift->openapi->valid_input or return;

    my $notice;
    return try {
        my $message_id = $c->validation->param('message_id');
        $notice = Koha::Notice::Messages->find($message_id);
        $notice->status('pending')->store;
        C4::Log::logaction(
            "NOTICES",
            "RESEND",
            $notice->borrowernumber,
            '{"message_id": '.$message_id.'}',
            'rest'
        );
        return $c->render( status => 204, openapi => {});
    }
    catch {
        unless ($notice) {
            return $c->render( status  => 404,
                               openapi => { error => "Notice not found" } );
        }
        Koha::Exceptions::rethrow_exception($_);
    };
}

sub _between_time_queued {
    my ($params) = @_;

    return $params if      $params->{'time_queued'};
    return $params if (   !$params->{'time_queued_start'}
                       && !$params->{'time_queued_end'} );

    my $start = $params->{'time_queued_start'};
    my $end   = $params->{'time_queued_end'};

    if ($start && !$end) {
        $params->{'time_queued'} = { '>=', $start };
    }
    elsif (!$start && $end) {
        $params->{'time_queued'} = { '<=', $end };
    }
    else {
        $params->{'time_queued'} = { '-between', [$start, $end] };
    }

    delete $params->{'time_queued_start'};
    delete $params->{'time_queued_end'};
    return $params;
}

1;
