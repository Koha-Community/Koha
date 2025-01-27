package Koha::Auth::Client::OAuth;

# Copyright Theke Solutions 2022
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

use JSON         qw( decode_json );
use MIME::Base64 qw{ decode_base64url };
use Koha::Patrons;
use Mojo::UserAgent;
use Mojo::Parameters;

use base qw( Koha::Auth::Client );

=head1 NAME

Koha::Auth::Client::OAuth - Koha OAuth Client

=head1 API

=head2 Class methods

=head3 _get_data_and_patron

    my $mapping = $object->_get_data_and_patron(
        {   provider => $provider,
            data     => $data,
            config   => $config
        }
    );

Maps OAuth raw data to a patron schema, and returns a patron if it can.

=cut

sub _get_data_and_patron {
    my ( $self, $params ) = @_;

    my $provider = $params->{provider};
    my $data     = $params->{data};
    my $config   = $params->{config};

    my $patron;
    my $mapped_data;

    my $mapping    = decode_json( $provider->mapping );
    my $matchpoint = $provider->matchpoint;

    if ( $data->{id_token} ) {
        my ( $header_part, $claims_part, $footer_part ) = split( /\./, $data->{id_token} );

        my $claim = decode_json( decode_base64url($claims_part) );

        foreach my $key ( keys %$mapping ) {
            my $pkey = $mapping->{$key};
            $mapped_data->{$key} = $claim->{$pkey}
                if defined $claim->{$pkey};
        }

        my $value = $mapped_data->{$matchpoint};

        my $matchpoint_rs = Koha::Patrons->search( { $matchpoint => $value } );

        if ( defined $value and $matchpoint_rs->count ) {
            $patron = $matchpoint_rs->next;
        }
    }

    if ( defined $config->{userinfo_url} ) {
        my $access_token = $data->{access_token};
        my $ua           = Mojo::UserAgent->new;
        my $tx           = $ua->get( $config->{userinfo_url} => { Authorization => "Bearer $access_token" } );
        my $code         = $tx->res->code || 'No response';

        return if $code ne '200';
        my $claim =
              $tx->res->headers->content_type =~ m!^(application/json|text/javascript)(;\s*charset=\S+)?$!
            ? $tx->res->json
            : Mojo::Parameters->new( $tx->res->body )->to_hash;

        foreach my $key ( keys %$mapping ) {
            my $pkey  = $mapping->{$key};
            my $value = $self->_traverse_hash( { base => $claim, keys => $pkey } );
            $mapped_data->{$key} = $value
                if defined $value;
        }

        unless ($patron) {
            my $value = $mapped_data->{$matchpoint};

            my $matchpoint_rs = Koha::Patrons->search( { $matchpoint => $value } );

            if ( defined $value and $matchpoint_rs->count ) {
                $patron = $matchpoint_rs->next;
            }
        }

    }

    return ( $mapped_data, $patron );
}

1;
