package Koha::Auth::TwoFactorAuth;

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
use GD::Barcode;
use MIME::Base64 qw( encode_base64 );

use C4::Letters;
use Koha::Exceptions;
use Koha::Exceptions::Patron;

use base qw( Auth::GoogleAuth );

=head1 NAME

Koha::Auth::TwoFactorAuth- Koha class deal with Two factor authentication

=head1 SYNOPSIS

use Koha::Auth::TwoFactorAuth;

my $secret = Koha::AuthUtils::generate_salt( 'weak', 16 );
my $auth = Koha::Auth::TwoFactorAuth->new({ patron => $patron, secret => $secret });
my $image_src = $auth->qr_code;
my $ok = $auth->verify( $pin_code, 1 );

It's based on Auth::GoogleAuth

=head2 METHODS

=head3 new

    $obj = Koha::Auth::TwoFactorAuth->new({ patron => $p, secret => $s });

    Patron is mandatory.
    Secret is optional, defaults to patron's secret.
    Passing secret32 overrules secret! Secret32 should be base32.

=cut

sub new {
    my ($class, $params) = @_;
    my $patron   = $params->{patron};
    my $secret32 = $params->{secret32};
    my $secret = $params->{secret};

    # FIXME Raise an exception if the syspref is disabled

    Koha::Exceptions::MissingParameter->throw("Mandatory patron parameter missing")
        unless $patron && ref($patron) eq 'Koha::Patron';

    my $type = 'secret32';
    if( $secret32 ) {
        Koha::Exceptions::BadParameter->throw("Secret32 should be base32")
            if $secret32 =~ /[^a-z2-7]/;
    } elsif( $secret ) {
        $type = 'secret';
    } elsif( $patron->secret ) {
        $secret32 = $patron->decoded_secret; # saved already in base32
    } else {
        Koha::Exceptions::MissingParameter->throw("No secret passed or patron has no secret");
    }

    my $issuer = Encode::encode_utf8($patron->library->branchname);
    my $key_id = sprintf "%s_%s",
      $issuer, ( $patron->email || $patron->userid );

    return $class->SUPER::new({
        $type => $secret32 || $secret,
        issuer => $issuer,
        key_id => $key_id,
    });
}

=head3 qr_code

    my $image_src = $auth->qr_code;

    Replacement for (unsafer) Auth::GoogleAuth::qr_code.
    Returns the data URL to fill the src attribute of the
    image tag on the registration form.

=cut

sub qr_code {
    my ( $self ) = @_;

    my $otpauth = $self->SUPER::qr_code( undef, undef, undef, 1);
        # no need to pass secret, key and issuer again
    my $qrcode = GD::Barcode->new( 'QRcode', $otpauth, { Ecc => 'M', ModuleSize => 4 } );
    my $data = $qrcode->plot->png;
    return "data:image/png;base64,". encode_base64( $data, q{} ); # does not contain newlines
}

1;
