package Koha::Patron::Message::Preference;

# Copyright Koha-Suomi Oy 2016
#
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

use Koha::Database;
use Koha::Exceptions;
use Koha::Patron::Categories;
use Koha::Patron::Message::Attributes;
use Koha::Patron::Message::Preferences;
use Koha::Patron::Message::Transport::Preferences;
use Koha::Patron::Message::Transport::Types;
use Koha::Patron::Message::Transports;
use Koha::Patrons;

use base qw(Koha::Object);

=head1 NAME

Koha::Patron::Message::Preference - Koha Patron Message Preference object class

=head1 API

=head2 Class Methods

=cut

=head3 new

my $preference = Koha::Patron::Message::Preference->new({
   borrowernumber => 123,
   #categorycode => 'ABC',
   message_attribute_id => 4,
   message_transport_types => ['email', 'sms'], # see documentation below
   wants_digest => 1,
   days_in_advance => 7,
});

Takes either borrowernumber or categorycode, but not both.

days_in_advance may not be available. See message_attributes table for takes_days
configuration.

wants_digest may not be available. See message_transports table for is_digest
configuration.

You can instantiate a new object without custom validation errors, but when
storing, validation may throw exceptions. See C<validate()> for more
documentation.

C<message_transport_types> is a parameter that is not actually a column in this
Koha-object. Given this parameter, the message transport types will be added as
related transport types for this object. For get and set, you can access them via
subroutine C<message_transport_types()> in this class.

=cut

sub new {
    my ($class, $params) = @_;

    my $types = $params->{'message_transport_types'};
    delete $params->{'message_transport_types'};

    my $self = $class->SUPER::new($params);

    $self->_set_message_transport_types($types);

    return $self;
}

=head3 new_from_default

my $preference = Koha::Patron::Message::Preference->new_from_default({
    borrowernumber => 123,
    categorycode   => 'ABC',   # if not given, patron's categorycode will be used
    message_attribute_id => 1,
});

NOTE: This subroutine initializes and STORES the object (in order to set
message transport types for the preference), so no need to call ->store when
preferences are initialized via this method.

Stores default messaging preference for C<categorycode> to patron for given
C<message_attribute_id>.

Throws Koha::Exceptions::MissingParameter if any of following is missing:
- borrowernumber
- message_attribute_id

Throws Koha::Exceptions::ObjectNotFound if default preferences are not found.

=cut

sub new_from_default {
    my ($class, $params) = @_;

    my @required = qw(borrowernumber message_attribute_id);
    foreach my $p (@required) {
        Koha::Exceptions::MissingParameter->throw(
            error => "Missing required parameter '$p'.",
        ) unless exists $params->{$p};
    }
    unless ($params->{'categorycode'}) {
        my $patron = Koha::Patrons->find($params->{borrowernumber});
        $params->{'categorycode'} = $patron->categorycode;
    }

    my $default = Koha::Patron::Message::Preferences->find({
        categorycode => $params->{'categorycode'},
        message_attribute_id => $params->{'message_attribute_id'},
    });
    Koha::Exceptions::ObjectNotFound->throw(
        error => 'Default messaging preference for given categorycode and'
        .' message_attribute_id cannot be found.',
    ) unless $default;
    $default = $default->unblessed;

    # Add a new messaging preference for patron
    my $self = $class->SUPER::new({
        borrowernumber => $params->{'borrowernumber'},
        message_attribute_id => $default->{'message_attribute_id'},
        days_in_advance => $default->{'days_in_advance'},
        wants_digest => $default->{'wants_digest'},
    })->store;

    # Set default messaging transport types
    my $default_transport_types =
    Koha::Patron::Message::Transport::Preferences->search({
        borrower_message_preference_id =>
                    $default->{'borrower_message_preference_id'}
    });
    while (my $transport = $default_transport_types->next) {
        Koha::Patron::Message::Transport::Preference->new({
            borrower_message_preference_id => $self->borrower_message_preference_id,
            message_transport_type => $transport->message_transport_type,
        })->store;
    }

    return $self;
}

=head3 message_name

$preference->message_name

Gets message_name for this messaging preference.

Setter not implemented.

=cut

sub message_name {
    my ($self) = @_;

    if ($self->{'_message_name'}) {
        return $self->{'_message_name'};
    }
    $self->{'_message_name'} = Koha::Patron::Message::Attributes->find({
        message_attribute_id => $self->message_attribute_id,
    })->message_name;
    return $self->{'_message_name'};
}

=head3 message_transport_types

$preference->message_transport_types
Returns a HASHREF of message transport types for this messaging preference, e.g.
if ($preference->message_transport_types->{'email'}) {
    # email is one of the transport preferences
}

$preference->message_transport_types('email', 'sms');
Sets the given message transport types for this messaging preference

=cut

sub message_transport_types {
    my $self = shift;

    unless (@_) {
        if ($self->{'_message_transport_types'}) {
            return $self->{'_message_transport_types'};
        }
        map {
            my $transport = Koha::Patron::Message::Transports->find({
                message_attribute_id => $self->message_attribute_id,
                message_transport_type => $_->message_transport_type,
                is_digest => $self->wants_digest
            });
            unless ($transport) {
                my $logger = Koha::Logger->get;
                $logger->warn(
                    $self->message_name . ' has no transport with '.
                    $_->message_transport_type . ' (digest: '.
                    ($self->wants_digest ? 'yes':'no').').'
                );
            }
            $self->{'_message_transport_types'}->{$_->message_transport_type}
                = $transport ? $transport->letter_code : ' ';
        }
        Koha::Patron::Message::Transport::Preferences->search({
            borrower_message_preference_id => $self->borrower_message_preference_id,
        })->as_list;
        return $self->{'_message_transport_types'} || {};
    }
    else {
        $self->_set_message_transport_types(@_);
        return $self;
    }
}

=head3 set

$preference->set({
    message_transport_types => ['sms', 'phone'],
    wants_digest => 0,
})->store;

Sets preference object values and additionally message_transport_types if given.

=cut

sub set {
    my ($self, $params) = @_;

    my $mtt = $params->{'message_transport_types'};
    delete $params->{'message_transport_types'};

    $self->SUPER::set($params) if $params;
    if ($mtt) {
        $self->message_transport_types($mtt);
    }

    return $self;
}

=head3 store

Makes a validation before actual Koha::Object->store so that proper exceptions
can be thrown. See C<validate()> for documentation about exceptions.

=cut

sub store {
    my $self = shift;

    $self->validate->SUPER::store(@_);

    # store message transport types
    if (exists $self->{'_message_transport_types'}) {
        Koha::Patron::Message::Transport::Preferences->search({
            borrower_message_preference_id =>
                $self->borrower_message_preference_id,
        })->delete;
        foreach my $type (keys %{$self->{'_message_transport_types'}}) {
            Koha::Patron::Message::Transport::Preference->new({
                borrower_message_preference_id =>
                    $self->borrower_message_preference_id,
                message_transport_type => $type,
            })->store;
        }
    }

    return $self;
}

=head3 validate

Makes a basic validation for object.

Throws following exceptions regarding parameters.
- Koha::Exceptions::MissingParameter
- Koha::Exceptions::TooManyParameters
- Koha::Exceptions::BadParameter

See $_->parameter to identify the parameter causing the exception.

Throws Koha::Exceptions::DuplicateObject if this preference already exists.

Returns Koha::Patron::Message::Preference object.

=cut

sub validate {
    my ($self) = @_;

    if ($self->borrowernumber && $self->categorycode) {
        Koha::Exceptions::TooManyParameters->throw(
            error => 'Both borrowernumber and category given, only one accepted',
        );
    }
    if (!$self->borrowernumber && !$self->categorycode) {
        Koha::Exceptions::MissingParameter->throw(
            error => 'borrowernumber or category required, none given',
        );
    }
    if ($self->borrowernumber) {
        Koha::Exceptions::BadParameter->throw(
            error => 'Patron not found.',
            parameter => 'borrowernumber',
        ) unless Koha::Patrons->find($self->borrowernumber);
    }
    if ($self->categorycode) {
        Koha::Exceptions::BadParameter->throw(
            error => 'Category not found.',
            parameter => 'categorycode',
        ) unless Koha::Patron::Categories->find($self->categorycode);
    }

    if (!$self->in_storage) {
        my $previous = Koha::Patron::Message::Preferences->search({
            borrowernumber => $self->borrowernumber,
            categorycode   => $self->categorycode,
            message_attribute_id => $self->message_attribute_id,
        });
        if ($previous->count) {
            Koha::Exceptions::DuplicateObject->throw(
                error => 'A preference for this borrower/category and'
                .' message_attribute_id already exists',
            );
        }
    }

    my $attr = Koha::Patron::Message::Attributes->find(
        $self->message_attribute_id
    );
    unless ($attr) {
        Koha::Exceptions::BadParameter->throw(
            error => 'Message attribute with id '.$self->message_attribute_id
            .' not found',
            parameter => 'message_attribute_id'
        );
    }
    if (defined $self->days_in_advance) {
        if ($attr && $attr->takes_days == 0) {
            Koha::Exceptions::BadParameter->throw(
                error => 'days_in_advance cannot be defined for '.
                $attr->message_name . '.',
                parameter => 'days_in_advance',
            );
        }
        elsif ($self->days_in_advance < 0 || $self->days_in_advance > 30) {
            Koha::Exceptions::BadParameter->throw(
                error => 'days_in_advance has to be a value between 0-30 for '.
                $attr->message_name . '.',
                parameter => 'days_in_advance',
            );
        }
    }
    if (defined $self->wants_digest) {
        my $transports = Koha::Patron::Message::Transports->search({
            message_attribute_id => $self->message_attribute_id,
            is_digest            => $self->wants_digest ? 1 : 0,
        });
        Koha::Exceptions::BadParameter->throw(
            error => (!$self->wants_digest ? 'Digest must be selected'
                                           : 'Digest cannot be selected')
            . ' for '.$attr->message_name.'.',
            parameter => 'wants_digest',
        ) if $transports->count == 0;
    }

    return $self;
}

sub _set_message_transport_types {
    my $self = shift;

    return unless $_[0];

    $self->{'_message_transport_types'} = undef;
    my $types = ref $_[0] eq "ARRAY" ? $_[0] : [@_];
    return unless $types;
    $self->_validate_message_transport_types({ message_transport_types => $types });
    foreach my $type (@$types) {
        unless (exists $self->{'_message_transport_types'}->{$type}) {
            my $transport = Koha::Patron::Message::Transports->find({
                message_attribute_id => $self->message_attribute_id,
                message_transport_type => $type
            });
            unless ($transport) {
                Koha::Exceptions::BadParameter->throw(
                    error => 'No transport configured for '.$self->message_name.
                        " transport type $type.",
                    parameter => 'message_transport_types'
                );
            }
            if (defined $self->borrowernumber) {
                my $patron = Koha::Patrons->find($self->borrowernumber);
                if ($type eq 'email') {
                    if ( !$patron->email )
                    {
                        Koha::Exceptions::BadParameter->throw(
                            error => 'Patron has not set email address, '.
                                     'cannot use email as message transport',
                            parameter => 'message_transport_types'
                        );
                    }
                }
                elsif ($type eq 'sms') {
                    if ( !$patron->smsalertnumber ){
                        Koha::Exceptions::BadParameter->throw(
                            error => 'Patron has not set sms number, '.
                                     'cannot set sms as message transport',
                            parameter => 'message_transport_types'
                        );
                    }
                }
            }
            $self->{'_message_transport_types'}->{$type}
                = $transport->letter_code;
        }
    }
    return $self;
}

sub _validate_message_transport_types {
    my ($self, $params) = @_;

    if (ref($params) eq 'HASH' && $params->{'message_transport_types'}) {
        if (ref($params->{'message_transport_types'}) ne 'ARRAY') {
            $params->{'message_transport_types'} = [$params->{'message_transport_types'}];
        }
        my $types = $params->{'message_transport_types'};

        foreach my $type (@{$types}) {
            unless (Koha::Patron::Message::Transport::Types->find({
                message_transport_type => $type
            })) {
                Koha::Exceptions::BadParameter->throw(
                    error => "Message transport type '$type' does not exist",
                    parameter => 'message_transport_types',
                );
            }
        }
        return $types;
    }
}

=head3 type

=cut

sub _type {
    return 'BorrowerMessagePreference';
}

=head1 AUTHOR

Lari Taskula <lari.taskula@hypernova.fi>

=cut

1;
