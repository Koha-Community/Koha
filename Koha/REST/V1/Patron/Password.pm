package Koha::REST::V1::Patron::Password;

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

use C4::Context;
use C4::Members;
use Koha::AuthUtils qw(hash_password);
use Koha::Database;
use Koha::Patron::Password::Recovery qw(
    SendPasswordRecoveryEmail
    ValidateBorrowernumber
    CompletePasswordRecovery
);
use Koha::Patrons;

use Koha::Exceptions;

use Try::Tiny;

sub recovery {
    my $c = shift->openapi->valid_input or return;

    my $patron;
    return try {
        my $body = $c->req->json;

        unless (C4::Context->preference('OpacPasswordChange') and
                C4::Context->preference('OpacPasswordReset'))
        {
            return $c->render(status => 403, openapi => {
                error => 'Password recovery is disabled.'
            });
        }

        unless (defined $body->{userid} or defined $body->{cardnumber}) {
            Koha::Exceptions::BadParameter->throw(
                error => 'Either userid or cardnumber must be given.'
            );
        }

        my $patron = Koha::Patrons->search({
            email => $body->{email},
            '-or' => {
                userid => $body->{userid},
                cardnumber => $body->{cardnumber},
            }
        })->next;

        unless ($patron) {
            Koha::Exceptions::Patron::NotFound->throw(
                error => 'Patron not found'
            );
        }

        my $resend = ValidateBorrowernumber($patron->borrowernumber);

        SendPasswordRecoveryEmail($patron, $patron->email, $resend);

        return $c->render(status => 201, openapi => {
            status => 1,
            to_address => $patron->email
        });
    }
    catch {
        if ($_->isa('Koha::Exceptions::BadParameter')) {
            return $c->render(status => 400, openapi => { error => $_->error });
        }
        elsif ($_->isa('Koha::Exceptions::Patron::NotFound')) {
            return $c->render(status => 404, openapi => { error => $_->error });
        }
        Koha::Exceptions::rethrow_exception($_);
    };
}

sub complete_recovery {
    my $c = shift->openapi->valid_input or return;

    my $rs = Koha::Database->new->schema->resultset('BorrowerPasswordRecovery');
    return try {
        my $body = $c->req->json;

        my $password_recovery = $rs->find({
            uuid => $body->{uuid}
        });
        unless ($password_recovery) {
            return $c->render(status => 404, openapi => {
                error => 'Password recovery request with given uuid not found.'
            });
        }

        my $patron = Koha::Patrons->find($password_recovery->borrowernumber);
        my $categorycode = $patron->categorycode;
        my ($success, $error, $errmsg) = C4::Members::ValidateMemberPassword(
            $categorycode, $body->{new_password}, $body->{confirm_new_password}
        );
        if ($error) {
            return $c->render(status => 400, openapi => {
                error => $errmsg
            });
        }
        my $password = $body->{new_password};
        $patron->update_password( $patron->userid, hash_password($password) );
        return $c->render(status => 200, openapi => {});
    }
    catch {
        Koha::Exceptions::rethrow_exception($_);
    };
}

1;
