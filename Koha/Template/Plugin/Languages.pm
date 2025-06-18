package Koha::Template::Plugin::Languages;

# Copyright 2012 ByWater Solutions
# Copyright 2013-2014 BibLibre
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

use Template::Plugin;
use base qw( Template::Plugin );

use C4::Koha;
use C4::Languages;

sub GetByISOCode {
    my ( $self, $lang, $code ) = @_;
    $lang = substr( $lang, 0, 2 );    #Get db code from Koha lang value
    my $rfc         = C4::Languages::get_rfc4646_from_iso639($code);
    my $description = C4::Languages::language_get_description( $rfc, $lang, 'language' );
    return $description;
}

1;

=head1 NAME

Koha::Template::Plugin::Languages - TT Plugin for languages

=head1 SYNOPSIS

[% USE Languages %]

[% Languages.GetByISOCode( 'LANG', 'ISO639CODE' ) %]

=head1 ROUTINES

=head2 GetByISOCode

In a template, you can get the description for an language value with
the following TT code: [% Languages.GetByISOCode( 'LANGUAGE', 'ISO639CODE' ) %]


=head1 AUTHOR

Nick Clemens <nick@bywatersolutions.com>

=cut
