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

        my $letter = C4::Letters::GetPreparedLetter(
            module      => 'members',
            letter_code => '2FA_OTP_TOKEN',
            branchcode  => $patron->branchcode,
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

1;
