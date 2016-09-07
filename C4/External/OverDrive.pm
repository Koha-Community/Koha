package C4::External::OverDrive;

# Copyright (c) 2013 ByWater
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

use strict;
use warnings;

use Koha;
use JSON;
use Koha::Caches;
use HTTP::Request;
use HTTP::Request::Common;
use LWP::Authen::Basic;
use LWP::UserAgent;

BEGIN {
    require Exporter;
    our @ISA = qw( Exporter ) ;
    our @EXPORT = qw(
        IsOverDriveEnabled
        GetOverDriveToken
    );
}

sub _request {
    my ( $request ) = @_;
    my $ua = LWP::UserAgent->new( agent => "Koha " . $Koha::VERSION );

    my $response;
    eval {
        $response = $ua->request( $request ) ;
    };
    if ( $@ )  {
        warn "OverDrive request failed: $@";
        return;
    }

    return $response;
}

=head1 NAME

C4::External::OverDrive - Retrieve OverDrive content availability information

=head2 FUNCTIONS

This module provides content search for OverDrive,

=over

=item IsOverDriveEnabled

Returns 1 if all of the necessary system preferences for OverDrive are set.

=back

=cut

sub IsOverDriveEnabled {
    return (
        C4::Context->preference( 'OverDriveClientKey' ) &&
        C4::Context->preference( 'OverDriveClientSecret' )
    );
}

=over

=item GetOverDriveToken

Fetches an OAuth2 auth token for the OverDrive API, reusing an existing token in
Memcache if possible.

Returns the token ( as "bearer ..." )  or undef on failure.

=back

=cut

sub GetOverDriveToken {
    my $key = C4::Context->preference( 'OverDriveClientKey' );
    my $secret = C4::Context->preference( 'OverDriveClientSecret' );

    return unless ( $key && $secret ) ;

    my $cache;

    eval { $cache = Koha::Caches->get_instance() };

    my $token;
    $cache and $token = $cache->get_from_cache( "overdrive_token" ) and return $token;

    my $request = HTTP::Request::Common::POST( 'https://oauth.overdrive.com/token', [
        grant_type => 'client_credentials'
    ] ) ;
    $request->header( Authorization => LWP::Authen::Basic->auth_header( $key, $secret ) );

    my $response = _request( $request ) or return;
    if ( $response->header('Content-Type') !~ m!application/json! ) {
        warn "Could not connect to OverDrive: " . $response->message;
        return;
    }
    my $contents = from_json( $response->decoded_content );

    if ( !$response->is_success ) {
        warn "Could not log into OverDrive: " . ( $contents ? $contents->{'error_description'} : $response->decoded_content );
        return;
    }

    $token = $contents->{'token_type'} . ' ' . $contents->{'access_token'};

    # Fudge factor to prevent spurious failures
    $cache
      and $cache->set_in_cache( 'overdrive_token', $token,
        { expiry => $contents->{'expires_in'} - 5 } );

    return $token;
}

1;
__END__

=head1 NOTES

=cut

=head1 AUTHOR

Jesse Weaver <pianohacker@gmail.com>

=cut
