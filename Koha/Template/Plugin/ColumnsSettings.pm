package Koha::Template::Plugin::ColumnsSettings;

# This file is part of Koha.
#
# Copyright BibLibre 2014
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

use YAML qw( LoadFile );
use JSON qw( to_json );

use C4::Context qw( config );
use C4::Utils::DataTables::ColumnsSettings;

=pod

This plugin allows to get the column configuration for a table.

First, include the line '[% USE Tables %]' at the top
of the template to enable the plugin.

To use, call ColumnsSettings.GetColumns with the module, the page and the table where the template is called.

For example: [% ColumnsSettings.GetColumns( 'circ', 'circulation', 'holdst' ) %]

=cut

sub GetColumns {
    my ( $self, $module, $page, $table, $format ) = @_;
    $format //= q{};

    my $columns = C4::Utils::DataTables::ColumnsSettings::get_columns( $module, $page, $table );

    return $format eq 'json'
        ? to_json( $columns )
        : $columns
}

1;
