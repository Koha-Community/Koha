package Koha::Patron::Consents;

# Copyright 2018 Rijksmuseum
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

use base qw(Koha::Objects);

use C4::Context;
use Koha::Patron::Consent;
use Koha::Plugins;

=head1 NAME

Koha::Patron::Consents

=head1 DESCRIPTION

Koha::Objects class for handling patron consents

=head1 API

=head2 Class Methods

=head3 available_types

    Returns an HASHref of available consent types like:
        { type1 => {}, type2 => {}, .. }

    Checks PrivacyPolicyConsent preference and any patron_consent_type plugins (if pref enabled).

    Note: The plugins return an ARRAYref with type, title and description like:
        [ my_type => { title => { lang => 1, .. }, description => { lang => 2, .. } } ]

=cut

sub available_types {
    my ($self) = shift;
    my $response = {};
    $response->{GDPR_PROCESSING} = 1 if C4::Context->preference('PrivacyPolicyConsent');
    foreach my $return ( Koha::Plugins->call('patron_consent_type') ) {
        next if ref($return) ne 'ARRAY' or @$return != 2;    # ignoring bad input
        $response->{ $return->[0] } = $return->[1];
    }
    return $response;
}

=head3 _type

=cut

sub _type {
    return 'PatronConsent';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::Patron::Consent';
}

1;
