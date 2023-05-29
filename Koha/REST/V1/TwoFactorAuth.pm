package Koha::REST::V1::TwoFactorAuth;

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
use Try::Tiny;

use C4::Letters qw( GetPreparedLetter );

=head1 NAME

Koha::REST::V1::TwoFactorAuth

=head1 API

=head2 Methods

=head3 send_otp_token

Will send an email with the OTP token needed to complete the second authentication step.

=cut


sub send_otp_token {

    my $c = shift->openapi->valid_input or return;

    my $patron = Koha::Patrons->find( $c->stash('koha.user')->borrowernumber );

    return try {

        my $code = Koha::Auth::TwoFactorAuth->new({patron => $patron})->code;
        my $letter = C4::Letters::GetPreparedLetter(
            module      => 'members',
            letter_code => '2FA_OTP_TOKEN',
            branchcode  => $patron->branchcode,
            substitute  => { otp_token => $code },
            tables      => {
                borrowers => $patron->unblessed,
            }
        );
        my $message_id = C4::Letters::EnqueueLetter(
            {
                letter                 => $letter,
                borrowernumber         => $patron->borrowernumber,
                message_transport_type => 'email'
            }
        );
        C4::Letters::SendQueuedMessages({message_id => $message_id});

        my $message = C4::Letters::GetMessage($message_id);

        if ( $message->{status} eq 'sent' ) {
            return $c->render(status => 200, openapi => {});
        } elsif ( $message->{status} eq 'failed' ) {
            return $c->render(status => 400, openapi => { error => 'email_not_sent'});
        }
    }
    catch {
        $c->unhandled_exception($_);
    };

}

=head3 registration

Ask for a registration secret. It will return a QR code image and a secret32.

The secret must be sent back to the server with the pin code for the verification step.

=cut

sub registration {

    my $c = shift->openapi->valid_input or return;

    my $patron = Koha::Patrons->find( $c->stash('koha.user')->borrowernumber );

    return try {
        my $secret = Koha::AuthUtils::generate_salt( 'weak', 16 );
        my $auth   = Koha::Auth::TwoFactorAuth->new(
            { patron => $patron, secret => $secret } );

        my $response = {
            issuer   => Encode::decode_utf8($auth->issuer),
            key_id   => Encode::decode_utf8($auth->key_id),
            qr_code  => $auth->qr_code,
            secret32 => $auth->secret32,

            # IMPORTANT: get secret32 after qr_code call !
        };
        $auth->clear;

        return $c->render(status => 201, openapi => $response);
    }
    catch {
        $c->unhandled_exception($_);
    };

}

=head3 verification

Verify the registration, get the pin code and the secret retrieved from the registration.

The 2FA_ENABLE notice will be generated if the pin code is correct, and the patron will have their two-factor authentication setup completed.

=cut

sub verification {

    my $c = shift->openapi->valid_input or return;

    my $patron = Koha::Patrons->find( $c->stash('koha.user')->borrowernumber );

    return try {

        my $pin_code = $c->param('pin_code');
        my $secret32 = $c->param('secret32');

        my $auth     = Koha::Auth::TwoFactorAuth->new(
            { patron => $patron, secret32 => $secret32 } );

        my $verified = $auth->verify(
            $pin_code,
            1,        # range
            $secret32,
            undef,    # timestamp (defaults to now)
            30,       # interval (default 30)
        );

        unless ($verified) {
            return $c->render(
                status  => 400,
                openapi => { error => "Invalid pin" }
            );
        }

        # FIXME Generate a (new?) secret
        $patron->encode_secret($secret32);
        $patron->auth_method('two-factor')->store;
        if ( $patron->notice_email_address ) {
            $patron->queue_notice(
                {
                    letter_params => {
                        module      => 'members',
                        letter_code => '2FA_ENABLE',
                        branchcode  => $patron->branchcode,
                        lang        => $patron->lang,
                        tables      => {
                            branches  => $patron->branchcode,
                            borrowers => $patron->id
                        },
                    },
                    message_transports => ['email'],
                }
            );
        }

        return $c->render(status => 204, openapi => {});
    }
    catch {
        $c->unhandled_exception($_);
    };

}

1;
