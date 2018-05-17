package Koha::Patron::Message::Preferences;

# Copyright Koha-Suomi Oy 2016
#
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

use C4::Context;

use Koha::Database;
use Koha::Patron::Message::Attributes;
use Koha::Patron::Message::Preference;
use Koha::Patron::Message::Transports;

use Data::Dumper;

use base qw(Koha::Objects);

=head1 NAME

Koha::Patron::Message::Preferences - Koha Patron Message Preferences object class

=head1 API

=head2 Class Methods

=cut

=head3 find_with_message_name

Koha::Patron::Message::Preferences->find_with_message_name({
    borrowernumber => 123,
    message_name => 'Hold_Filled',
});

Converts C<message_name> into C<message_attribute_id> and continues find.

=cut

sub find_with_message_name {
    my ($self, $id) = @_;

    if (ref($id) eq "HASH" && $id->{'message_name'}) {
        my $attr = Koha::Patron::Message::Attributes->find({
            message_name => $id->{'message_name'},
        });
        $id->{'message_attribute_id'} = ($attr) ?
                    $attr->message_attribute_id : undef;
        delete $id->{'message_name'};
    }

    return $self->SUPER::find($id);
}

=head3 get_options

my $messaging_options = Koha::Patron::Message::Preferences->get_options

Returns an ARRAYref of HASHrefs on available messaging options.

=cut

sub get_options {
    my ($self) = @_;

    my $transports = Koha::Patron::Message::Transports->search(undef,
        {
            join => ['message_attribute'],
            '+select' => ['message_attribute.message_name', 'message_attribute.takes_days'],
            '+as' => ['message_name', 'takes_days'],
        });

    my $choices;
    while (my $transport = $transports->next) {
        my $name = $transport->get_column('message_name');
        $choices->{$name}->{'message_attribute_id'} = $transport->message_attribute_id;
        $choices->{$name}->{'message_name'}         = $name;
        $choices->{$name}->{'takes_days'}           = $transport->get_column('takes_days');
        $choices->{$name}->{'has_digest'}           ||= 1 if $transport->is_digest;
        $choices->{$name}->{'has_digest_off'}       ||= 1 if !$transport->is_digest;
        $choices->{$name}->{'transport_'.$transport->get_column('message_transport_type')} = ' ';
    }

    my @return = values %$choices;
    @return = sort { $a->{message_attribute_id} <=> $b->{message_attribute_id} } @return;

    return \@return;
}

=head3 search

Koha::Patron::Message::Preferences->search_with_message_name({
    borrowernumber => 123,
    message_name => 'Hold_Filled',
});

Converts C<message_name> into C<message_attribute_id> and continues search. Use
Koha::Patron::Message::Preferences->search with a proper join for more complicated
searches.

=cut

sub search_with_message_name {
    my ($self, $params, $attributes) = @_;

    if (ref($params) eq "HASH" && $params->{'message_name'}) {
        my $attr = Koha::Patron::Message::Attributes->find({
            message_name => $params->{'message_name'},
        });
        $params->{'message_attribute_id'} = ($attr) ?
                    $attr->message_attribute_id : undef;
        delete $params->{'message_name'};
    }

    return $self->SUPER::search($params, $attributes);
}

sub TO_JSON {
    my ($self) = @_;

    my $preferences = {};
    my $options = $self->get_options;
    foreach my $preference ($self->as_list) {
        $preferences->{$preference->message_name} = $preference->TO_JSON({
            options => $options
        });
    }

    # If some preferences are not stored even though they are valid options,
    # then add those options to the returned HASHref as well
    foreach my $option (@$options) {
        unless ($preferences->{$option->{'message_name'}}) {
            my $message_attribute_id = Koha::Patron::Message::Attributes->find({
                message_name => $option->{'message_name'}
            })->message_attribute_id;
            $preferences->{$option->{'message_name'}} =
                Koha::Patron::Message::Preference->new({
                    borrowernumber => -1,
                    message_attribute_id => $message_attribute_id,
                })->TO_JSON({ options => $options });
        }
    }

    return $preferences;
}

sub _log_action_buffer {
    return 0 unless C4::Context->preference("BorrowersLog");
    my $self = shift;
    my ($logEntries, $borrowernumber) = @_;
    return 0 unless $logEntries;

    if (scalar(@$logEntries)) {
        my $d = Data::Dumper->new([$logEntries]);
        $d->Indent(0);
        $d->Purity(0);
        $d->Terse(1);
        C4::Log::logaction('MEMBERS', 'MOD MTT', $borrowernumber, $d->Dump($logEntries));
    }
    else {
        C4::Log::logaction('MEMBERS', 'MOD MTT', $borrowernumber, 'All message_transport_types removed')
    }

    return 1;
}

=head3 type

=cut

sub _type {
    return 'BorrowerMessagePreference';
}

sub object_class {
    return 'Koha::Patron::Message::Preference';
}

=head1 AUTHOR

Lari Taskula <lari.taskula@jns.fi>

=cut

1;
