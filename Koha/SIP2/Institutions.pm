package Koha::SIP2::Institutions;

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

use Koha::SIP2::Institution;

use base qw(Koha::Objects);

=head1 NAME

Koha::SIP2::Institutions- Koha SipInstitution Object set class

=head1 API

=head2 Class Methods

=cut

=head3 get_for_config

Returns the institutions hashref as expected by C4/SIP/Sip/Configuration->new;

=cut

sub get_for_config {
    my ($self) = @_;

    my $institutions = $self->search();
    my $return_hash;

    while ( my $sip2_institution = $institutions->next() ) {
        $return_hash->{ $sip2_institution->name } = $sip2_institution->get_for_config();
    }
    return $return_hash;
}

=head3 type

=cut

sub _type {
    return 'SipInstitution';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::SIP2::Institution';
}

1;
