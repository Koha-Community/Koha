package Koha::REST::V1::ERM::EUsage::CounterRegistry;

# Copyright 2023 PTFS Europe

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
use HTTP::Request;
use LWP::UserAgent;
use Scalar::Util qw( blessed );
use JSON         qw( from_json decode_json encode_json );
use Try::Tiny    qw( catch try );

use Koha::Exceptions;

=head1 API

=head2 Methods

=head3 list

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    my $args = $c->param('q');
    my $json = JSON->new;

    my @query_params_array =
        map { $_ ? $json->decode($_) : () } $args;

    my $search_string = $query_params_array[0]->{name};

    my $url     = 'https://registry.countermetrics.org/api/v1/platform/';
    my $request = HTTP::Request->new(
        GET => $url,
    );

    my $ua       = LWP::UserAgent->new;
    my $response = $ua->simple_request($request);

    if ( $response->code >= 400 ) {
        my $result = decode_json( $response->decoded_content );
        my $message;
        if ( ref($result) eq 'ARRAY' ) {
            for my $r (@$result) {
                $message .= $r->{message};
            }
        } else {
            $message = $result->{message} || $result->{Message} || q{};
            if ( $result->{errors} ) {
                for my $e ( @{ $result->{errors} } ) {
                    $message .= $e->{message};
                }
            }
        }
        warn sprintf "ERROR - Counter registry API %s returned %s - %s\n", $url,
            $response->code, $message;
        if ( $response->code == 404 ) {
            Koha::Exceptions::ObjectNotFound->throw($message);
        } elsif ( $response->code == 401 ) {
            Koha::Exceptions::Authorization::Unauthorized->throw($message);
        } else {
            die sprintf "ERROR requesting Counter registry API\n%s\ncode %s: %s\n", $url,
                $response->code,
                $message;
        }
    } elsif ( $response->code == 204 ) {    # No content
        return;
    }

    my $result = decode_json( $response->decoded_content );

    my @counter_5_supporting_platforms;
    foreach my $platform (@$result) {
        my $name_check = index( lc $platform->{name}, lc $search_string );
        my @services   = grep { $_->{counter_release} eq '5' } @{ $platform->{sushi_services} };
        if (   scalar(@services) > 0
            && $name_check != -1
            && scalar( @{ $platform->{reports} } ) > 0 )
        {
            $platform->{sushi_services} = \@services;
            push @counter_5_supporting_platforms, $platform;
        }
    }

    return $c->render(
        status  => 200,
        openapi => \@counter_5_supporting_platforms
    );
}

1;
