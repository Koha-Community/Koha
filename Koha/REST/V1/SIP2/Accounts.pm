package Koha::REST::V1::SIP2::Accounts;

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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Mojo::Base 'Mojolicious::Controller';

use Koha::SIP2::Accounts;

use Try::Tiny qw( catch try );

=head1 API

=head2 Methods

=head3 list

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $accounts = $c->objects->search( Koha::SIP2::Accounts->new );
        return $c->render( status => 200, openapi => $accounts );
    } catch {
        $c->unhandled_exception($_);
    };

}

=head3 get

Controller function that handles retrieving a single Koha::SIP2::Account object

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $account = $c->objects->find( Koha::SIP2::Accounts->search, $c->param('sip_account_id') );

        return $c->render_resource_not_found("Account")
            unless $account;

        return $c->render(
            status  => 200,
            openapi => $account
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 add

Controller function that handles adding a new Koha::SIP2::Account object

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    return try {
        Koha::Database->new->schema->txn_do(
            sub {

                my $body = $c->req->json;

                my $custom_item_fields          = delete $body->{custom_item_fields}          // [];
                my $item_fields                 = delete $body->{item_fields}                 // [];
                my $custom_patron_fields        = delete $body->{custom_patron_fields}        // [];
                my $patron_attributes           = delete $body->{patron_attributes}           // [];
                my $screen_msg_regexs           = delete $body->{screen_msg_regexs}           // [];
                my $sort_bin_mappings           = delete $body->{sort_bin_mappings}           // [];
                my $system_preference_overrides = delete $body->{system_preference_overrides} // [];

                my $account = Koha::SIP2::Account->new_from_api($body)->store;
                $account->custom_item_fields($custom_item_fields);
                $account->item_fields($item_fields);
                $account->custom_patron_fields($custom_patron_fields);
                $account->patron_attributes($patron_attributes);
                $account->screen_msg_regexs($screen_msg_regexs);
                $account->sort_bin_mappings($sort_bin_mappings);
                $account->system_preference_overrides($system_preference_overrides);

                $c->res->headers->location( $c->req->url->to_string . '/' . $account->sip_account_id );
                return $c->render(
                    status  => 201,
                    openapi => $c->objects->to_api($account),
                );
            }
        );
    } catch {

        my $to_api_mapping = Koha::SIP2::Account->new->to_api_mapping;

        if ( blessed $_ ) {
            if ( $_->isa('Koha::Exceptions::Object::DuplicateID') ) {
                return $c->render(
                    status  => 409,
                    openapi => { error => $_->error, conflict => $_->duplicate_id }
                );
            } elsif ( $_->isa('Koha::Exceptions::BadParameter') ) {
                return $c->render(
                    status  => 400,
                    openapi => { error => "Given " . $to_api_mapping->{ $_->parameter } . " does not exist" }
                );
            }
        }

        $c->unhandled_exception($_);
    };
}

=head3 update

Controller function that handles updating a Koha::SIP2::Account object

=cut

sub update {
    my $c = shift->openapi->valid_input or return;

    my $account = Koha::SIP2::Accounts->find( $c->param('sip_account_id') );

    return $c->render_resource_not_found("Account")
        unless $account;

    return try {
        Koha::Database->new->schema->txn_do(
            sub {

                my $body = $c->req->json;

                my $custom_item_fields          = delete $body->{custom_item_fields}          // [];
                my $item_fields                 = delete $body->{item_fields}                 // [];
                my $custom_patron_fields        = delete $body->{custom_patron_fields}        // [];
                my $patron_attributes           = delete $body->{patron_attributes}           // [];
                my $screen_msg_regexs           = delete $body->{screen_msg_regexs}           // [];
                my $sort_bin_mappings           = delete $body->{sort_bin_mappings}           // [];
                my $system_preference_overrides = delete $body->{system_preference_overrides} // [];

                $account->set_from_api($body)->store;
                $account->custom_item_fields($custom_item_fields);
                $account->item_fields($item_fields);
                $account->custom_patron_fields($custom_patron_fields);
                $account->patron_attributes($patron_attributes);
                $account->screen_msg_regexs($screen_msg_regexs);
                $account->sort_bin_mappings($sort_bin_mappings);
                $account->system_preference_overrides($system_preference_overrides);

                return $c->render(
                    status  => 200,
                    openapi => $c->objects->to_api($account),
                );
            }
        );
    } catch {
        my $to_api_mapping = Koha::SIP2::Account->new->to_api_mapping;

        if ( blessed $_ ) {
            if ( $_->isa('Koha::Exceptions::BadParameter') ) {
                return $c->render(
                    status  => 400,
                    openapi => { error => "Given " . $to_api_mapping->{ $_->parameter } . " does not exist" }
                );
            }
        }

        $c->unhandled_exception($_);
    };
}

=head3 delete

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $account = Koha::SIP2::Accounts->find( $c->param('sip_account_id') );

    return $c->render_resource_not_found("Account")
        unless $account;

    return try {
        $account->delete;
        return $c->render_resource_deleted;
    } catch {
        $c->unhandled_exception($_);
    };
}

1;
