package Koha::REST::V1::Patrons;

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

use Koha::Database;
use Koha::Exceptions;
use Koha::Patrons;
use C4::Letters qw( GetPreparedLetter EnqueueLetter SendQueuedMessages );

use List::MoreUtils qw(any);
use Scalar::Util qw( blessed );
use Try::Tiny qw( catch try );

=head1 NAME

Koha::REST::V1::Patrons

=head1 API

=head2 Methods

=head3 list

Controller function that handles listing Koha::Patron objects

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {

        my $query = {};
        my $restricted = $c->param('restricted');
        $c->req->params->remove('restricted');
        $query->{debarred} = { '!=' => undef }
            if $restricted;

        my $patrons_rs = Koha::Patrons->search($query);
        my $patrons    = $c->objects->search( $patrons_rs );

        return $c->render(
            status  => 200,
            openapi => $patrons
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 get

Controller function that handles retrieving a single Koha::Patron object

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $patron_id = $c->param('patron_id');
        my $patron    = $c->objects->find( Koha::Patrons->search_limited, $patron_id );

        unless ($patron) {
            return $c->render(
                status  => 404,
                openapi => { error => "Patron not found." }
            );
        }

        return $c->render(
            status  => 200,
            openapi => $patron
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 add

Controller function that handles adding a new Koha::Patron object

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    return try {

        Koha::Database->new->schema->txn_do(
            sub {

                my $body = $c->req->json;

                my $extended_attributes = delete $body->{extended_attributes} // [];

                my $patron = Koha::Patron->new_from_api($body)->store;

                my $overrides = $c->stash('koha.overrides');
                if ( $overrides->{welcome_yes}
                    || ( C4::Context->preference("AutoEmailNewUser") && !$overrides->{welcome_no} ) )
                {

                    # if we manage to find a valid email address, send notice
                    if ( $patron->notice_email_address ) {
                        my $letter = GetPreparedLetter(
                            module      => 'members',
                            letter_code => 'WELCOME',
                            branchcode  => $patron->branchcode,
                            ,
                            lang   => $patron->lang || 'default',
                            tables => {
                                'branches'  => $patron->branchcode,
                                'borrowers' => $patron->borrowernumber,
                            },
                            want_librarian => 1,
                        );

                        if ($letter) {
                            my $message_id = EnqueueLetter(
                                {
                                    letter                 => $letter,
                                    borrowernumber         => $patron->id,
                                    to_address             => $patron->notice_email_address,
                                    message_transport_type => 'email'
                                }
                            );
                            SendQueuedMessages( { message_id => $message_id } );
                        }
                    }
                }

                $patron->extended_attributes(
                    [
                        map { { code => $_->{type}, attribute => $_->{value} } }
                          @$extended_attributes
                    ]
                );
                if ( C4::Context->preference('EnhancedMessagingPreferences') ) {
                    C4::Members::Messaging::SetMessagingPreferencesFromDefaults(
                        {
                            borrowernumber => $patron->borrowernumber,
                            categorycode   => $patron->categorycode,
                        }
                    );
                }

                $c->res->headers->location($c->req->url->to_string . '/' . $patron->borrowernumber);
                return $c->render(
                    status  => 201,
                    openapi => $patron->to_api
                );
            }
        );
    }
    catch {

        my $to_api_mapping = Koha::Patron->new->to_api_mapping;

        if ( blessed $_ ) {
            if ( $_->isa('Koha::Exceptions::Object::DuplicateID') ) {
                return $c->render(
                    status  => 409,
                    openapi => { error => $_->error, conflict => $_->duplicate_id }
                );
            }
            elsif ( $_->isa('Koha::Exceptions::Patron::InvalidUserid') ) {
                return $c->render(
                    status  => 400,
                    openapi => { error => "Problem with ". $_->userid }
                );
            }
            elsif ( $_->isa('Koha::Exceptions::Object::FKConstraint') ) {
                return $c->render(
                    status  => 400,
                    openapi => {
                            error => "Given "
                            . $to_api_mapping->{ $_->broken_fk }
                            . " does not exist"
                    }
                );
            }
            elsif ( $_->isa('Koha::Exceptions::BadParameter') ) {
                return $c->render(
                    status  => 400,
                    openapi => {
                            error => "Given "
                            . $to_api_mapping->{ $_->parameter }
                            . " does not exist"
                    }
                );
            }
            elsif (
                $_->isa('Koha::Exceptions::Patron::MissingMandatoryExtendedAttribute')
              )
            {
                return $c->render(
                    status  => 400,
                    openapi => { error => "$_" }
                );
            }
            elsif (
                $_->isa('Koha::Exceptions::Patron::Attribute::InvalidType')
              )
            {
                return $c->render(
                    status  => 400,
                    openapi => { error => "$_" }
                );
            }
            elsif (
                $_->isa('Koha::Exceptions::Patron::Attribute::NonRepeatable')
              )
            {
                return $c->render(
                    status  => 400,
                    openapi => { error => "$_" }
                );
            }
            elsif (
                $_->isa('Koha::Exceptions::Patron::Attribute::UniqueIDConstraint')
              )
            {
                return $c->render(
                    status  => 400,
                    openapi => { error => "$_" }
                );
            }
        }

        $c->unhandled_exception($_);
    };
}


=head3 update

Controller function that handles updating a Koha::Patron object

=cut

sub update {
    my $c = shift->openapi->valid_input or return;

    my $patron = Koha::Patrons->find( $c->param('patron_id') );

    unless ($patron) {
         return $c->render(
             status  => 404,
             openapi => { error => "Patron not found" }
         );
     }

    return try {
        my $body = $c->req->json;
        my $user = $c->stash('koha.user');

        if (
                $patron->is_superlibrarian
            and !$user->is_superlibrarian
            and (  exists $body->{email}
                or exists $body->{secondary_email}
                or exists $body->{altaddress_email} )
          )
        {
            foreach my $email_field ( qw(email secondary_email altaddress_email) ) {
                my $exists_email = exists $body->{$email_field};
                next unless $exists_email;

                # exists, verify if we are asked to change it
                my $put_email      = $body->{$email_field};
                # As of writing this patch, 'email' is the only unmapped field
                # (i.e. it preserves its name, hence this fallback)
                my $db_email_field = $patron->to_api_mapping->{$email_field} // 'email';
                my $db_email       = $patron->$db_email_field;

                return $c->render(
                    status  => 403,
                    openapi => { error => "Not enough privileges to change a superlibrarian's email" }
                  )
                  unless ( !defined $put_email and !defined $db_email )
                  or (  defined $put_email
                    and defined $db_email
                    and $put_email eq $db_email );
            }
        }

        $patron->set_from_api($body)->store;
        $patron->discard_changes;
        return $c->render( status => 200, openapi => $patron->to_api );
    }
    catch {
        unless ( blessed $_ && $_->can('rethrow') ) {
            return $c->render(
                status  => 500,
                openapi => {
                    error => "Something went wrong, check Koha logs for details."
                }
            );
        }
        if ( $_->isa('Koha::Exceptions::Object::DuplicateID') ) {
            return $c->render(
                status  => 409,
                openapi => { error => $_->error, conflict => $_->duplicate_id }
            );
        }
        elsif ( $_->isa('Koha::Exceptions::Patron::InvalidUserid') ) {
            return $c->render(
                status  => 400,
                openapi => { error => "Problem with ". $_->userid }
            );
        }
        elsif ( $_->isa('Koha::Exceptions::Object::FKConstraint') ) {
            return $c->render(
                status  => 400,
                openapi => { error => "Given " .
                            $patron->to_api_mapping->{$_->broken_fk}
                            . " does not exist" }
            );
        }
        elsif ( $_->isa('Koha::Exceptions::MissingParameter') ) {
            return $c->render(
                status  => 400,
                openapi => {
                    error      => "Missing mandatory parameter(s)",
                    parameters => $_->parameter
                }
            );
        }
        elsif ( $_->isa('Koha::Exceptions::BadParameter') ) {
            return $c->render(
                status  => 400,
                openapi => {
                    error      => "Invalid parameter(s)",
                    parameters => $_->parameter
                }
            );
        }
        elsif ( $_->isa('Koha::Exceptions::NoChanges') ) {
            return $c->render(
                status  => 204,
                openapi => { error => "No changes have been made" }
            );
        }
        else {
            $c->unhandled_exception($_);
        }
    };
}

=head3 delete

Controller function that handles deleting a Koha::Patron object

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $patron = Koha::Patrons->find( $c->param('patron_id') );

    unless ( $patron ) {
        return $c->render(
            status  => 404,
            openapi => { error => "Patron not found" }
        );
    }

    return try {

        my $safe_to_delete = $patron->safe_to_delete;

        if ( !$safe_to_delete ) {
            # Pick the first error, if any
            my ( $error ) = grep { $_->type eq 'error' } @{ $safe_to_delete->messages };
            unless ( $error ) {
                Koha::Exception->throw('Koha::Patron->safe_to_delete returned false but carried no error message');
            }

            my $error_descriptions = {
                has_checkouts  => 'Pending checkouts prevent deletion',
                has_debt       => 'Pending debts prevent deletion',
                has_guarantees => 'Patron is a guarantor and it prevents deletion',
                is_anonymous_patron => 'Anonymous patron cannot be deleted',
            };

            if ( any { $error->message eq $_ } keys %{$error_descriptions} ) {
                return $c->render(
                    status  => 409,
                    openapi => {
                        error      => $error_descriptions->{ $error->message },
                        error_code => $error->message,
                    }
                );
            } else {
                Koha::Exception->throw( 'Koha::Patron->safe_to_delete carried an unexpected message: ' . $error->message );
            }
        }

        return $patron->_result->result_source->schema->txn_do(
            sub {
                $patron->move_to_deleted;
                $patron->delete;

                return $c->render(
                    status  => 204,
                    openapi => q{}
                );
            }
        );
    } catch {

        $c->unhandled_exception($_);
    };
}

=head3 guarantors_can_see_charges

Method for setting whether guarantors can see the patron's charges.

=cut

sub guarantors_can_see_charges {
    my $c = shift->openapi->valid_input or return;

    return try {
        if ( C4::Context->preference('AllowPatronToSetFinesVisibilityForGuarantor') ) {
            my $patron = $c->stash( 'koha.user' );
            my $privacy_setting = ($c->req->json->{allowed}) ? 1 : 0;

            $patron->privacy_guarantor_fines( $privacy_setting )->store;

            return $c->render(
                status  => 200,
                openapi => {}
            );
        }
        else {
            return $c->render(
                status  => 403,
                openapi => {
                    error =>
                      'The current configuration doesn\'t allow the requested action.'
                }
            );
        }
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 guarantors_can_see_checkouts

Method for setting whether guarantors can see the patron's checkouts.

=cut

sub guarantors_can_see_checkouts {
    my $c = shift->openapi->valid_input or return;

    return try {
        if ( C4::Context->preference('AllowPatronToSetCheckoutsVisibilityForGuarantor') ) {
            my $patron = $c->stash( 'koha.user' );
            my $privacy_setting = ( $c->req->json->{allowed} ) ? 1 : 0;

            $patron->privacy_guarantor_checkouts( $privacy_setting )->store;

            return $c->render(
                status  => 200,
                openapi => {}
            );
        }
        else {
            return $c->render(
                status  => 403,
                openapi => {
                    error =>
                      'The current configuration doesn\'t allow the requested action.'
                }
            );
        }
    }
    catch {
        $c->unhandled_exception($_);
    };
}

1;
