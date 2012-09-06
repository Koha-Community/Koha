package Koha::Template::Plugin::KohaAuthorisedValues;

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

use C4::Koha;

=pod

This plugin allows one to get the description for an authorised value
from within a template.

First, include the line '[% USE KohaAuthorisedValues %]' at the top
of the template to enable the plugin.

To use, call KohaAuthorisedValues.GetByCode with the category
of the authorised value, the code to look up, and optionally,
the OPAC flag ( if set, it will return the OPAC description rather
than the Intranet description ).

For example: [% KohaAuthorisedValues.GetByCode( 'LOST', item.itemlost, 1 ) %]
will print the OPAC description for the LOST value stored in item.itemlost.

=cut

sub GetByCode {
    my ( $self, $category, $code, $opac ) = @_;
    return GetAuthorisedValueByCode( $category, $code, $opac );
}

1;
