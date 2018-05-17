package Koha::REST::V1::Patron::Message::Preference;

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

use Koha::Patron::Message::Attributes;
use Koha::Patron::Message::Preferences;
use Koha::Patron::Message::Transport::Types;
use Koha::Patron::Message::Transports;

use Try::Tiny;

sub list {
    my $c = shift->openapi->valid_input or return;

    my $enabled = _check_system_preferences($c);
    return $enabled if $enabled;

    my $borrowernumber = $c->validation->param('borrowernumber');
    my $categorycode   = $c->validation->param('categorycode');

    my $found = $borrowernumber
        ? Koha::Patrons->find($borrowernumber)
        : Koha::Patron::Categories->find($categorycode);

    return try {
        die unless $found;
        my $preferences = Koha::Patron::Message::Preferences->search({
            borrowernumber => $borrowernumber,
            categorycode   => $categorycode,
        });

        return $c->render(status => 200, openapi => $preferences);
    }
    catch {
        unless ($found) {
            return $c->render( status  => 400, openapi => {
                error => "Patron or category not found" } );
        }
        Koha::Exceptions::rethrow_exception($_);
    };
}

sub edit {
    my $c = shift->openapi->valid_input or return;

    my $enabled = _check_system_preferences($c);
    return $enabled if $enabled;

    my $borrowernumber = $c->validation->param('borrowernumber');
    my $categorycode   = $c->validation->param('categorycode');
    my $body           = $c->validation->param('body');

    my $found = $borrowernumber
        ? Koha::Patrons->find($borrowernumber)
        : Koha::Patron::Categories->find($categorycode);

    return try {
        die unless $found;
        my $actionLog = [];
        foreach my $in (keys %{$body}) {
            my $preference =
                Koha::Patron::Message::Preferences->find_with_message_name({
                    borrowernumber => $borrowernumber,
                    categorycode => $categorycode,
                    message_name => $in
                });

            # Format wants_digest and days_in_advance values
            my $wants_digest = $body->{$in}->{'digest'} ?
                $body->{$in}->{'digest'}->{'value'} ? 1 : 0 : $preference ?
                $preference->wants_digest ? 1 : 0 : 0;
            my $days_in_advance = $body->{$in}->{'days_in_advance'} ?
                defined $body->{$in}->{'days_in_advance'}->{'value'} ?
                    $body->{$in}->{'days_in_advance'}->{'value'} : undef : undef;

            # HASHref for updated preference
            my @transport_types;
            foreach my $mtt (keys %{$body->{$in}->{'transport_types'}}) {
                if ($body->{$in}->{'transport_types'}->{$mtt}) {
                    push @transport_types, $mtt;
                }
            }
            my $edited_preference = {
                wants_digest => $wants_digest,
                days_in_advance => $days_in_advance,
                message_transport_types => \@transport_types
            };

            # Unless a preference for this message name exists, create it
            unless ($preference) {
                my $attr = Koha::Patron::Message::Attributes->find({
                    message_name => $in
                });
                unless ($attr) {
                    Koha::Exceptions::BadParameter->throw(
                        error => "Message type $in not found."
                    );
                }
                $edited_preference->{'message_attribute_id'} =
                        $attr->message_attribute_id;
                if ($borrowernumber) {
                    $edited_preference->{'borrowernumber'}=$found->borrowernumber;
                } else {
                    $edited_preference->{'categorycode'}=$found->categorycode;
                }
                $preference = Koha::Patron::Message::Preference->new(
                    $edited_preference)->store;
            }
            # Otherwise, modify the already-existing one
            else {
                $preference->set($edited_preference)->store;
            }
            $preference->_push_to_action_buffer($actionLog);
        }

        # Finally, return the preferences
        my $preferences = Koha::Patron::Message::Preferences->search({
            borrowernumber => $borrowernumber,
            categorycode   => $categorycode,
        });
        $preferences->_log_action_buffer($actionLog, $borrowernumber);

        return $c->render( status => 200, openapi => $preferences);
    }
    catch {
        unless ($found) {
            return $c->render( status  => 400, openapi => {
                error => "Patron or category not found" } );
        }
        if ($_->isa('Koha::Exceptions::BadParameter')) {
            return $c->render( status => 400, openapi => { error => $_->error });
        }
        Koha::Exceptions::rethrow_exception($_);
    };
}

sub _check_system_preferences {
    my $c = shift;
    if ( ! C4::Context->preference('EnhancedMessagingPreferences') ) {
        return $c->render( status => 403, openapi => {
            error => "Enhanced messaging preferences are not enabled"});
    }
    if (($c->stash('is_owner_access') || $c->stash('is_guarantor_access'))
        && ! C4::Context->preference('EnhancedMessagingPreferencesOPAC')) {
        return $c->render( status => 403, openapi => {
            error => "Patrons does not have access to enhanced messaging"
                    ." preferences" });
    }
    return;
}

1;
