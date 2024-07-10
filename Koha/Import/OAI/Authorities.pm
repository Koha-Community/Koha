package Koha::Import::OAI::Authorities;

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

use Modern::Perl;

use Koha::Import::OAI::Authority;

use base qw(Koha::Objects);

=head1 NAME

Koha::Import::OAI::Authorities

This object represents a collection of OAI-PMH records being imported as authorities

=head1 API

=head2 Methods


=head3 type

=cut

sub _type {
    return 'ImportOaiAuthority';
}

=head3 object_class

Koha::Object class

=cut

sub object_class {
    return 'Koha::Import::OAI::Authority';
}
1;
