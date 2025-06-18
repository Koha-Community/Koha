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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

=head1 NAME

Koha::Template::Plugin::TablesSettings

=head2 SYNOPSIS

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
        var table_settings = [% TablesSettings.GetTableSettings( 'module', 'page', 'table', 'json' ) | $raw %];
        var table = $("#id").kohaTable({ "autoWidth": false }, table_settings );
    </script>

This plugin allows to get the column configuration for a table. It should be used both in table markup
and as the input for datatables visibility settings to take full effect.

=cut

use Modern::Perl;

use Template::Plugin;
use base qw( Template::Plugin );

use JSON qw( to_json );

use C4::Context;
use C4::Utils::DataTables::TablesSettings;

=head1 FUNCTIONS

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
    foreach my $keys (@$columns) {
        if ( $keys->{'columnname'} eq $column_name ) {
            return $keys->{'is_hidden'};
        }
    }
    return 0;
}

=head3 GetTableSettings

[% SET table_settings = GetTableSettings( module, page, table ) %]

This method is used to retrieve the tables settings (like table_settings.default_display_length and
table_settings.default_sort_order).
They can be passed to the DataTable constructor (for iDisplayLength and order parameters)

=cut

sub GetTableSettings {
    my ( $self, $module, $page, $table, $format ) = @_;
    $format //= q{};

    my $settings = C4::Utils::DataTables::TablesSettings::get_table_settings( $module, $page, $table );
    my $columns  = C4::Utils::DataTables::TablesSettings::get_columns( $module, $page, $table );

    $settings = {
        %$settings,
        columns => $columns,
        module  => $module,
        page    => $page,
        table   => $table,
    };

    return $format eq 'json'
        ? to_json( $settings || {} )
        : $settings;
}

1;
