package Koha::Patron::Message::Preference;

# Copyright Koha-Suomi Oy 2016
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.a
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use Koha::Database;
use Koha::Exceptions;
use Koha::Patron::Categories;
use Koha::Patron::Message::Attributes;
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

=cut

sub new {
    my ($class, $params) = shift;

    my $self = $class->SUPER::new(@_);

    return $self;
}

=head3 store

Makes a validation before actual Koha::Object->store so that proper exceptions
can be thrown. See C<validate()> for documentation about exceptions.

=cut

sub store {
    my $self = shift;

    return $self->validate->SUPER::store(@_);
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
            parameter => ['borrowernumber', 'categorycode'],
        );
    }
    if (!$self->borrowernumber && !$self->categorycode) {
        Koha::Exceptions::MissingParameter->throw(
            error => 'borrowernumber or category required, none given',
            parameter => ['borrowernumber', 'categorycode'],
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

    my $attr;
    if ($self->days_in_advance || $self->wants_digest) {
        $attr = Koha::Patron::Message::Attributes->find(
            $self->message_attribute_id
        );
    }
    if ($self->days_in_advance) {
        if ($attr && $attr->takes_days == 0) {
            Koha::Exceptions::BadParameter->throw(
                error => 'days_in_advance cannot be defined for '.
                $attr->message_name . ' .',
                parameter => 'days_in_advance',
            );
        }
        elsif ($self->days_in_advance < 0 || $self->days_in_advance > 30) {
            Koha::Exceptions::BadParameter->throw(
                error => 'days_in_advance has to be a value between 0-30 for '.
                $attr->message_name . ' .',
                parameter => 'days_in_advance',
            );
        }
    }
    if ($self->wants_digest) {
        my $transports = Koha::Patron::Message::Transports->search({
            message_attribute_id => $self->message_attribute_id,
            is_digest            => 1,
        });
        Koha::Exceptions::BadParameter->throw(
            error => 'Digest not available for '.$attr->message_name.' .',
            parameter => 'wants_digest',
        ) if $transports->count == 0;
    }

    return $self;
}

=head3 type

=cut

sub _type {
    return 'BorrowerMessagePreference';
}

=head1 AUTHOR

Lari Taskula <lari.taskula@jns.fi>

=cut

1;
