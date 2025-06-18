package Koha::Object::Message;

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

use base qw(Class::Accessor);

use Koha::Exceptions;

__PACKAGE__->mk_ro_accessors(qw( message payload type ));

=head1 NAME

Koha::Object::Message - Class encapsulating action feedback messages in Koha::Object-derived classes

=head1 SYNOPSIS

  my ($self, $params) = @_;
  push @{$self->{_messages}} = Koha::Object::Message->new($params);

=head1 API

=head2 Class methods

=head3 new

    my $message = Koha::Object::Message->new(
        {
            message => $some_message,
          [ type    => 'error',
            payload => $payload ]
        }
    );

Create a new Koha::Object::Message object.

=cut

sub new {
    my ( $class, $params ) = @_;

    my $message = $params->{message};
    my $type    = $params->{type} // 'error';
    my $payload = $params->{payload};

    Koha::Exceptions::MissingParameter->throw("Mandatory parameter missing: 'message'")
        unless $message;

    my $self = $class->SUPER::new(
        {
            message => $message,
            type    => $type,
            payload => $payload,
        }
    );

    return $self;
}

=head1 AUTHOR

Tomas Cohen Arazi, E<lt>tomascohen@theke.ioE<gt>

=cut

1;
