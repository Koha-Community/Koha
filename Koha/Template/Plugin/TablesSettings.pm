package Koha::Template::Plugin::TablesSettings;

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

=head1 NAME

Koha::Template::Plugin::TablesSettings

=head2 SYNOPSYS

    [% USE TablesSettings %]

    . . .

    [% UNLESS TablesSettings.is_hidden( 'module', 'page', 'table', 'column') %]
        <th id="column" data-colname="column">Column title</th>
    [% END %]

    . . .

    [% UNLESS TablesSettings.is_hidden( 'module', 'page', 'table', 'column') %]
        <td>[% row.column %]</td>
    [% END %]

    . . .

    <script>
        var columns_settings = [% TablesSettings.GetColumns( 'module', 'page', 'table', 'json' ) | $raw %];
        var table = KohaTable("id", { "bAutoWidth": false }, columns_settings );
    </script>

This plugin allows to get the column configuration for a table. It should be used both in table markup
and as the input for datatables visibility settings to take full effect.

=cut

use Modern::Perl;

use Template::Plugin;
use base qw( Template::Plugin );

use YAML qw( LoadFile );
use JSON qw( to_json );

use C4::Context qw( config );
use C4::Utils::DataTables::TablesSettings;

=head1 FUNCTIONS

=head2 GetColumns

    <script>
        var tables_settings = [% TablesSettings.GetColumns( 'module', 'page', 'table', 'json' ) | $raw %];
        var table = KohaTable("id", { "bAutoWidth": false }, tables_settings );
    </script>

Used to get the full column settings configuration for datatables, usually requires a format of 'json' to pass into
datatables instantiator.

=cut

sub GetColumns {
    my ( $self, $module, $page, $table, $format ) = @_;
    $format //= q{};

    my $columns = C4::Utils::DataTables::TablesSettings::get_columns( $module, $page, $table );

    return $format eq 'json'
        ? to_json( $columns )
        : $columns
}

=head2 is_hidden

    [% UNLESS TablesSettings.is_hidden( 'module', 'page', 'table', 'column') %]
        <th id="column" data-colname="column">Column title</th>
    [% END %]

Used to fetch an individual columns display status so we can fully hide a column in the markup for cases where
it may contain confidential information and should be fully hidden rather than just hidden from display.

=cut

sub is_hidden {
    my ( $self, $module, $page, $table, $column_name ) = @_;
    my $columns = C4::Utils::DataTables::TablesSettings::get_columns( $module, $page, $table );
    foreach my $keys(@$columns){
        if($keys->{'columnname'} eq $column_name){
            return $keys->{'is_hidden'};
        }
    }
    return 0;
}

1;
