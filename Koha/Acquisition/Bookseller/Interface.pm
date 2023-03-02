package Koha::Acquisition::Bookseller::Interface;

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
use Koha::Encryption;

use base qw( Koha::Object );

=head1 NAME

Koha::Acquisition::Bookseller::Interface - Koha Bookseller interface Object class

=head1 API

=head2 Class Methods

=cut

=head3 store

    $self->store;

Specific store method to encrypt the password.

=cut

sub store {
    my ($self) = @_;

    if ( $self->password ) {
        $self->password(Koha::Encryption->new->encrypt_hex($self->password));
    }

    return $self->SUPER::store;
}

=head3 plain_text_password

    my $plain_text_password = $self->plain_text_password;

Decrypt the password and return its plain text form.

=cut

sub plain_text_password {
    my ($self) = @_;
    return Koha::Encryption->new->decrypt_hex($self->password)
        if $self->password;
}

=head3 _type

=cut

sub _type {
    return 'AqbooksellerInterface';
}

1;
