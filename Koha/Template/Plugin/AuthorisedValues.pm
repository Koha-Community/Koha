package Koha::Template::Plugin::AuthorisedValues;

# Copyright ByWater Solutions 2012

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use Template::Plugin;
use base qw( Template::Plugin );

use Encode qw{encode decode};

use C4::Koha;

=pod

To use, first, include the line '[% USE AuthorisedValues %]' at the top
of the template to enable the plugin.

Now, in a template, you can get the description for an authorised value with
the following TT code: [% AuthorisedValues.GetByCode( 'CATEGORY', 'AUTHORISED_VALUE_CODE', 'IS_OPAC' ) %]

The parameters are identical to those used by the subroutine C4::Koha::GetAuthorisedValueByCode.

=cut

sub GetByCode {
    my ( $self, $category, $code, $opac ) = @_;
    return encode( 'UTF-8', GetAuthorisedValueByCode( $category, $code, $opac ) );
}

1;
