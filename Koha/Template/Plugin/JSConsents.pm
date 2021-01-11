package Koha::Template::Plugin::JSConsents;

# Copyright 2021 PTFS Europe
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

use Template::Plugin;
use base qw( Template::Plugin );
use MIME::Base64 qw{ decode_base64 };
use JSON qw{ decode_json };
use Encode qw{ encode_utf8 };

use C4::Context;

sub all {
    my ( $self, $filter ) = @_;

    my $consents = C4::Context->preference('CookieConsentedJS');
    if ( length $consents > 0 ) {
        my $decoded_consents  = decode_base64($consents);
        my $convert_to_utf8   = encode_utf8($decoded_consents);
        my $consents_array    = decode_json $convert_to_utf8;
        my @filtered_consents = grep { $_->{$filter} } @{$consents_array};
        return \@filtered_consents;
    } else {
        return [];
    }
}

1;

=head1 NAME

Koha::Template::Plugin::JSConsents - TT Plugin for Javascript consents
Provided by CookieConsentedJS syspref

=head1 SYNOPSIS

[% USE JSConsents %]

[% JSConsents.all() %]

=head1 ROUTINES

=head2 all

In a template, you can get the all Javascript snippets
that require consent using the following TT:
[% JSConsents.all() %]
The consents are returned in an array of hashes

=head1 AUTHOR

Andrew Isherwood <andrew.isherwood@ptfs-europe.com>

=cut
