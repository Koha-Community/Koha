package Koha::SIP2::SystemPreferenceOverrides;

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

use Koha::SIP2::SystemPreferenceOverride;

use base qw(Koha::Objects);

=head1 NAME

Koha::SIP2::SystemPreferenceOverrides - Koha SIP2 System Preference Overrid Object set class

=head1 API

=head2 Class Methods

=cut

=head3 get_for_config

Returns the server params hashref as expected by C4/SIP/Sip/Configuration->new;

=cut

sub get_for_config {
    my ($self) = @_;

    my $sys_pref_overrides = $self->search();
    my $return_hash;

    while ( my $sys_pref_override = $sys_pref_overrides->next() ) {
        $return_hash->{ $sys_pref_override->variable } = $sys_pref_override->value;
    }
    return $return_hash;
}

=head3 type

=cut

sub _type {
    return 'SipSystemPreferenceOverride';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::SIP2::SystemPreferenceOverride';
}

1;
