package Koha::Template::Plugin::HtmlId;

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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use parent qw( Template::Plugin::Filter );

=head1 NAME

Koha::Template::Plugin::HtmlId - Filter characters for HTML IDs

=head1 SYNOPSIS

    [% USE HtmlId %]

    <div id=[% var | HtmlId %]></div>

It will replace characters that are not valid for HTML IDs with an underscore (_)

=cut

=head2 filter

Missing POD for filter.

=cut

sub filter {
    my ( $self, $text ) = @_;

    return $text =~ s/[^a-zA-Z0-9-]+/_/gr;
}

1;
