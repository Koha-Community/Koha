package Koha::Result::Boolean;

# Copyright ByWater Solutions 2021
# Copyright Theke Solutions   2021
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use overload
    bool => \&as_bool,
    '==' => \&equals;

use Koha::Object::Message;

=head1 NAME

Koha::Result::Boolean - Booleans, with extra Koha

=head1 API

=head2 Class methods

=head3 new

    my $bool = Koha::Result::Boolean->new( $value );

Constructor method to generate a Koha::Result::Boolean object. I<value> is
a boolean expression.

=cut

sub new {
    my ( $class, $value ) = @_;

    $value //= 1;    # default to true
    $value = ($value) ? 1 : 0;

    my $self = {
        value     => $value,
        _messages => [],
    };

    return bless( $self, $class );
}

=head3 set_value

    $bool->set_value(1);
    $bool->set_value(0);

Set the boolean value for the object.

=cut

sub set_value {
    my ( $self, $value ) = @_;

    $self->{value} = ($value) ? 1 : 0;

    return $self;
}

=head3 messages

    my @messages = @{ $bool->messages };

Returns the I<Koha::Object::Message> objects that were recorded.

=cut

sub messages {
    my ($self) = @_;

    $self->{_messages} = []
        unless defined $self->{_messages};

    return $self->{_messages};
}

=head3 add_message

    $bool->add_message(
        {
            message => $message,
          [ type    => 'error',
            payload => $payload ]
        }
    );

Adds a message.

=cut

sub add_message {
    my ( $self, $params ) = @_;

    push @{ $self->{_messages} }, Koha::Object::Message->new($params);

    return $self;
}

=head2 Internal methods

=head3 as_bool

Internal method that exposes the boolean value of the object as a scalar.

=cut

sub as_bool {
    my ($self) = @_;

    return $self->{value} + 0;
}

=head3 equals

Internal method implementing equality comparison in scalar context.

=cut

sub equals {
    my ( $first, $second, $flipped ) = @_;

    return ($flipped)
        ? $first == $second->as_bool
        : $first->as_bool == $second;
}

=head1 AUTHORS

Tomas Cohen Arazi, E<lt>tomascohen@theke.ioE<gt>

=cut

1;
