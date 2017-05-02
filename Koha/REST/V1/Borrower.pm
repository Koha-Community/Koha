package Koha::REST::V1::Borrower;

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
use Mojo::JSON;

use C4::SIP::ILS::Patron;

use Koha::Auth::Challenge::Password;

use Scalar::Util qw( blessed );
use Try::Tiny;

# NOTE
#
# This controller is for Koha-Suomi 3.16 ported operations. For new patron related
# endpoints, use /api/v1/patrons and Koha::REST::V1::Patron controller instead
sub status {
    my $c = shift->openapi->valid_input or return;

    my $username = $c->validation->param('uname');
    my $password = $c->validation->param('passwd');
    my ($borrower, $error);
    return try {

        $borrower = Koha::Auth::Challenge::Password::challenge(
                $username,
                $password
        );
        my $ilsBorrower = C4::SIP::ILS::Patron->new($borrower->userid);

        my $payload = {
            borrowernumber => 0+$borrower->borrowernumber,
            cardnumber     => $borrower->cardnumber || '',
            surname        => $borrower->surname || '',
            firstname      => $borrower->firstname || '',
            homebranch     => $borrower->branchcode || '',
            fines          => $ilsBorrower->fines_amount ? $ilsBorrower->fines_amount+0 : 0,
            language       => 'fin' || '',
            charge_privileges_denied    => _bool($ilsBorrower->charge_ok),
            renewal_privileges_denied   => _bool($ilsBorrower->renew_ok),
            recall_privileges_denied    => _bool($ilsBorrower->recall_ok),
            hold_privileges_denied      => _bool($ilsBorrower->hold_ok),
            card_reported_lost          => _bool($ilsBorrower->card_lost),
            too_many_items_charged      => _bool($ilsBorrower->too_many_charged),
            too_many_items_overdue      => _bool($ilsBorrower->too_many_overdue),
            too_many_renewals           => _bool($ilsBorrower->too_many_renewal),
            too_many_claims_of_items_returned => _bool($ilsBorrower->too_many_claim_return),
            too_many_items_lost         => _bool($ilsBorrower->too_many_lost),
            excessive_outstanding_fines => _bool($ilsBorrower->excessive_fines),
            recall_overdue              => _bool($ilsBorrower->recall_overdue),
            too_many_items_billed       => _bool($ilsBorrower->too_many_billed),
        };
        return $c->render( status => 200, openapi => $payload );
    } catch {
        if (blessed($_)){
            if ($_->isa('Koha::Exception::LoginFailed')) {
                return $c->render( status => 400, openapi => { error => $_->error } );
            }
        }
        Koha::Exceptions::rethrow_exception($_);
    };
}

sub _bool {
    return $_[0] ? Mojo::JSON->true : Mojo::JSON->false;
}

1;
