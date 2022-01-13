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
use Auth::GoogleAuth;

use base qw( Auth::GoogleAuth );

=head1 NAME

Koha::Auth::TwoFactorAuth- Koha class deal with Two factor authentication

=head1 SYNOPSIS

use Koha::Auth::TwoFactorAuth;

my $secret = Koha::AuthUtils::generate_salt( 'weak', 16 );
my $auth = Koha::Auth::TwoFactorAuth->new(
    { patron => $patron, secret => $secret } );
my $secret32 = $auth->generate_secret32;
my $ok = $auth->verify($pin_code, 1, $secret32);

It's based on Auth::GoogleAuth

=head2 METHODS

=head3 new

    $obj = Koha::Auth::TwoFactorAuth->new({ patron => $p, secret => $s });

=cut

sub new {
    my ($class, $params) = @_;
    my $patron   = $params->{patron};
    my $secret   = $params->{secret};
    my $secret32 = $params->{secret32};

    if (!$secret && !$secret32){
        $secret32 = $patron->secret;
    }

    my $issuer = $patron->library->branchname;
    my $key_id = sprintf "%s_%s",
      $issuer, ( $patron->email || $patron->userid );

    return $class->SUPER::new(
        {
            ( $secret   ? ( secret   => $secret )   : () ),
            ( $secret32 ? ( secret32 => $secret32 ) : () ),
            issuer => $issuer,
            key_id => $key_id,
        }
    );
}

1;
