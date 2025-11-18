package Koha::SIP2::Account::SystemPreferenceOverride;

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

use Koha::Database;

use base qw(Koha::Object);

=head1 NAME

Koha::SIP2::Account::SystemPreferenceOverride - Koha SIP2 Account System Preference Override Object class

=head1 API

=head2 Class Methods

=cut

=head3 get_for_config

Returns the system preference override hashref as expected by C4/SIP/Sip/Configuration->new;

=cut

sub get_for_config {
    my ($self) = @_;

    return {
        'variable' => $self->variable,
        'value'    => $self->value,
    };
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'SipAccountSystemPreferenceOverride';
}

1;
