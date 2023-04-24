package Koha::REST::V1::Illbackends;

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

use Koha::Illrequest::Config;
use Koha::Illrequests;

=head1 NAME

Koha::REST::V1::Illbackends

=head2 Operations

=head3 list

Return a list of available ILL backends and its capabilities

=cut

sub list {
    my $c = shift->openapi->valid_input;

    my $config = Koha::Illrequest::Config->new;
    my $backends = $config->available_backends;

    my @data;
    foreach my $b ( @$backends ) {
        my $backend = Koha::Illrequest->new->load_backend( $b );
        push @data, {
            ill_backend_id => $b,
            capabilities => $backend->capabilities,
        };
    }
    return $c->render( status => 200, openapi => \@data );
}

=head3 list_statuses

Return a list of existing ILL statuses

=cut

sub list_statuses {
    my $c = shift->openapi->valid_input;

    my $backend_id = $c->validation->param('ill_backend_id');

    #FIXME: Currently fetching all requests, it'd be great if we could fetch distinct(status).
    # Even doing it with distinct status, we need the ILL request object, so that strings_map works and
    # the ILL request returns the correct status and info respective to its backend.
    my $ill_requests = Koha::Illrequests->search(
            {backend => $backend_id},
            # {
            #     columns => [ qw/status/ ],
            #     group_by => [ qw/status/ ],
            # }
        );

    my @data;
    while (my $request = $ill_requests->next) {
        my $status_data = $request->strings_map;

        foreach my $status_class ( qw(status_alias status) ){
            if ($status_data->{$status_class}){
                push @data, {
                    $status_data->{$status_class}->{str} ? (str => $status_data->{$status_class}->{str}) :
                        $status_data->{$status_class}->{code} ? (str => $status_data->{$status_class}->{code}) : (),
                    $status_data->{$status_class}->{code} ? (code => $status_data->{$status_class}->{code}) : (),
                }
            }
        }
    }

    # Remove duplicate statuses
    my %seen;
    @data =  grep { my $e = $_; my $key = join '___', map { $e->{$_}; } sort keys %$_;!$seen{$key}++ } @data;

    return $c->render( status => 200, openapi => \@data );
}

=head3 get

Get one backend

=cut

sub get {
    my $c = shift->openapi->valid_input;

    my $backend_id = $c->validation->param('ill_backend_id');

    return try {
        my $backend = Koha::Illrequest->new->load_backend( $backend_id );
        return $c->render(
            status => 200,
            openapi => {
                ill_backend_id => $backend_id,
                capabilities => $backend->capabilities
            }
        );
    } catch {
        return $c->render(
            status => 404,
            openapi => { error => "ILL backend does not exist" }
        );
    };
}

1;
