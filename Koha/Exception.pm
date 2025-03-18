package Koha::Exception;

# Copyright 2018, 2022 Koha Development Team
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

use Exception::Class (
    'Koha::Exception' => { description => "Something went wrong!" },
);

sub full_message {
    my $self = shift;

    # If a message was passed manually, use it
    return sprintf "Exception '%s' thrown '%s'\n", ref($self), $self->message
        if $self->message;

    my $field_hash = $self->field_hash;

    my $description = $self->description;
    my @fields;

    foreach my $key ( sort keys %$field_hash ) {
        push @fields, $key . " => " . $field_hash->{$key}
            if defined $field_hash->{$key};
    }

    return
        sprintf "Exception '%s' thrown '%s'" . ( @fields ? " with %s" : "" ) . "\n",
        ref($self), $description, ( @fields ? join ', ', @fields : () );
}

=head1 NAME

Koha::Exception - Base class for exceptions

=head1 Exceptions

=head2 Koha::Exception

Generic exception.

=head1 Class methods

=head2 full_message

Generic method for exception stringifying.

=head2 description

=cut

1;
