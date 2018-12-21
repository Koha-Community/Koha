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
use Data::Printer;

use C4::SelfService;
use C4::SelfService::BlockManager;

# NOTE
#
# This controller is for Koha-Suomi 3.16 ported operations. For new patron related
# endpoints, use /api/v1/patrons and Koha::REST::V1::Patron controller instead

=head2 borrower_ss_blocks -feature

=cut

sub ss_block_delete {
    my $logger = Koha::Logger->get();
    my $c = shift->openapi->valid_input or return;

    my $payload;
    try {
        my $borrower_ss_block_id = $c->validation->param('borrower_ss_block_id');

        #If we didn't get any exceptions, we succeeded
        $payload = {};
        $payload->{deleted_count} = C4::SelfService::BlockManager::deleteBlock($borrower_ss_block_id);
        $payload->{deleted_count} = 0 if $payload->{deleted_count} == 0E0;

        return $c->render(status => 200, openapi => $payload);

    } catch {
        $logger->warn(np($_)) if $logger->is_warn();
        return Koha::Exceptions::rethrow_exception($_);
    };
}

sub ss_blocks_delete {
    my $logger = Koha::Logger->get();
    my $c = shift->openapi->valid_input or return;

    my $payload;
    try {
        my $borrowernumber = $c->validation->param('borrowernumber');

        #If we didn't get any exceptions, we succeeded
        $payload = {};
        $payload->{deleted_count} = C4::SelfService::BlockManager::deleteBorrowersBlocks($borrowernumber);
        $payload->{deleted_count} = 0 if $payload->{deleted_count} == 0E0;

        return $c->render(status => 200, openapi => $payload);

    } catch {
        $logger->warn(np($_)) if $logger->is_warn();
        return Koha::Exceptions::rethrow_exception($_);
    };
}

sub ss_block_get {
    my $logger = Koha::Logger->get();
    my $c = shift->openapi->valid_input or return;

    my $payload;
    try {
        my $borrowernumber       = $c->param('borrowernumber'); # Mojolicious::Plugin::Swagger
        my $borrower_ss_block_id = $c->validation->param('borrower_ss_block_id');

        #If we didn't get any exceptions, we succeeded
        my $block = C4::SelfService::BlockManager::getBlock($borrower_ss_block_id);
        return $c->render(status => 200, openapi => $block->swaggerize()) if $block;
        return $c->render(status => 404, openapi => {error => "No such self-service block"}) unless $block;

    } catch {
        $logger->warn(np($_)) if $logger->is_warn();
        return Koha::Exceptions::rethrow_exception($_);
    };
}

sub ss_block_has {
    my $logger = Koha::Logger->get();
    my $c = shift->openapi->valid_input or return;

    my $payload;
    try {
        my $borrowernumber = $c->param('borrowernumber');
        my $branchcode = $c->validation->param('branchcode');

        #If we didn't get any exceptions, we succeeded
        my $block = C4::SelfService::BlockManager::hasBlock($borrowernumber, $branchcode);
        return $c->render(status => 200, openapi => $block->swaggerize()) if $block;
        return $c->render(status => 204, openapi => {}) unless $block;

    } catch {
        $logger->warn(np($_)) if $logger->is_warn();
        return Koha::Exceptions::rethrow_exception($_);
    };
}

sub ss_blocks_list {
    my $logger = Koha::Logger->get();
    my $c = shift->openapi->valid_input or return;

    try {
        my $borrowernumber = $c->validation->param('borrowernumber');

        #If we didn't get any exceptions, we succeeded
        my $blocks = C4::SelfService::BlockManager::listBlocks($borrowernumber, DateTime->now(time_zone => C4::Context->tz()));
        if ($blocks && @$blocks) {
            @$blocks = map {$_->swaggerize()} @$blocks;
            return $c->render(status => 200, openapi => $blocks);
        }
        return $c->render( status => 404, openapi => { error => "No self-service blocks" } );

    } catch {
        $logger->warn(np($_)) if $logger->is_warn();
        return Koha::Exceptions::rethrow_exception($_);
    };
}

sub ss_blocks_post {
    my $logger = Koha::Logger->get();
    my $c = shift->openapi->valid_input or return;

    try {
        my $borrowernumber       = $c->validation->param('borrowernumber');
        my $block = $c->validation->param('borrower_ss_block');
        $block->{borrowernumber} = $borrowernumber if $borrowernumber;

        #If we didn't get any exceptions, we succeeded
        $block = C4::SelfService::BlockManager::createBlock($block);
        C4::SelfService::BlockManager::storeBlock($block);
        return $c->render(status => 200, openapi => $block->swaggerize());

    } catch {
        $logger->warn(np($_)) if $logger->is_warn();
        if (blessed($_) && $_->isa('Koha::Exception::UnknownObject')) {
            return $c->render( status => 404, openapi => { error => "$_" } );
        }
        return Koha::Exceptions::rethrow_exception($_);
    };
}

sub ss_blocks_put {
    my $logger = Koha::Logger->get();
    my $c = shift->openapi->valid_input or return;

    try {
        my $borrowernumber       = $c->validation->param('borrowernumber');
        my $borrower_ss_block_id = $c->validation->param('borrower_ss_block_id');
        my $block = $c->validation->param('borrower_ss_block');
        $block->{borrowernumber} = $borrowernumber if $borrowernumber;
        $block->{borrower_ss_block_id} = $borrower_ss_block_id if $borrower_ss_block_id;

        #If we didn't get any exceptions, we succeeded
        $block = C4::SelfService::BlockManager::storeBlock($block);
        return $c->render(status => 200, openapi => $block);

    } catch {
        $logger->warn(np($_)) if $logger->is_warn();
        if (blessed($_) && $_->isa('Koha::Exception::UnknownObject')) {
            return $c->render( status => 404, openapi => { error => "$_" } );
        }
        return Koha::Exceptions::rethrow_exception($_);
    };
}

########################################################################################################################

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
            age            => $borrower->get_age || '',
            fines          => $ilsBorrower->fines_amount ? $ilsBorrower->fines_amount+0 : 0,
            language       => 'fin' || '',
            charge_privileges_denied    => _bool(!$ilsBorrower->charge_ok),
            renewal_privileges_denied   => _bool(!$ilsBorrower->renew_ok),
            recall_privileges_denied    => _bool(!$ilsBorrower->recall_ok),
            hold_privileges_denied      => _bool(!$ilsBorrower->hold_ok),
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

sub get_self_service_status {
    my $c = shift->openapi->valid_input or return;

    my $payload;
    try {
        my $patron = Koha::Patrons->cast($c->validation->param('cardnumber'));
        my $branchcode = $c->validation->param('branchcode');
        my $ilsPatron = C4::SIP::ILS::Patron->new($patron->cardnumber);
        C4::SelfService::CheckSelfServicePermission($ilsPatron, $branchcode, 'accessMainDoor');
        #If we didn't get any exceptions, we succeeded
        $payload = {permission => Mojo::JSON->true};
        return $c->render(status => 200, openapi => $payload);

    } catch {
        if (not(blessed($_) && $_->can('rethrow'))) {
            return $c->render( status => 500, openapi => { error => "$_" } );
        }
        elsif ($_->isa('Koha::Exception::UnknownObject')) {
            return $c->render( status => 404, openapi => { error => "No such cardnumber" } );
        }
        elsif ($_->isa('Koha::Exception::SelfService::OpeningHours')) {
            $payload = {
                permission => Mojo::JSON->false,
                error => ref($_),
                startTime => $_->startTime,
                endTime => $_->endTime,
            };
            return $c->render( status => 200, openapi => $payload );
        }
        elsif ($_->isa('Koha::Exception::SelfService::PermissionRevoked')) {
            $payload = {
                permission     => Mojo::JSON->false,
                error          => ref($_),
            };
            $payload->{expirationdate} = $_->{expirationdate} if $_->{expirationdate};
            return $c->render( status => 200, openapi => $payload );
        }
        elsif ($_->isa('Koha::Exception::SelfService')) {
            $payload = {
                permission => Mojo::JSON->false,
                error => ref($_),
            };
            return $c->render( status => 200, openapi => $payload );
        }
        elsif ($_->isa('Koha::Exception::FeatureUnavailable')) {
            return $c->render( status => 501, openapi => { error => "$_" } );
        }
        else {
            return $c->render( status => 501, openapi => { error => $_->trace->as_string } );
        }
    };
}

sub _bool {
    return $_[0] ? Mojo::JSON->true : Mojo::JSON->false;
}

1;
