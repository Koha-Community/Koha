package Koha::Old::Biblios;

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

use base qw(Koha::Objects Koha::Objects::Record::Collections);

use Koha::Old::Biblio;

=head1 NAME

Koha::Old::Biblios - Koha Old::Biblio Object set class

=head1 API

=head2 Class Methods

=cut

=head2 Internal Methods

=head3 api_query_fixer

    $query_string = $biblios->api_query_fixer( $query_string, $context, $no_quotes );

Method that takes care of adjusting I<$query_string> as required. An optional I<$context> parameter
will be used to prefix the relevant query atoms if present. A I<$no_quotes> boolean parameter
can be passed to choose not to use quotes on matching. This is particularly useful in the context of I<order_by>.

=cut

sub api_query_fixer {
    my ( $self, $query, $context, $no_quotes ) = @_;

    my $quotes = $no_quotes ? '' : '"';

    if ($context) {
        $query =~
            s/${quotes}${context}\.(age_restriction|cn_class|cn_item|cn_sort|cn_source|cn_suffix|collection_issn|collection_title|collection_volume|ean|edition_statement|illustrations|isbn|issn|item_type|lc_control_number|notes|number|pages|publication_place|publication_year|publisher|material_size|serial_total_issues|url|volume|volume_date|volume_description)${quotes}/${quotes}${context}\.deletedbiblioitem\.$1${quotes}/g;
    } else {
        $query =~
            s/${quotes}(age_restriction|cn_class|cn_item|cn_sort|cn_source|cn_suffix|collection_issn|collection_title|collection_volume|ean|edition_statement|illustrations|isbn|issn|item_type|lc_control_number|notes|number|pages|publication_place|publication_year|publisher|material_size|serial_total_issues|url|volume|volume_date|volume_description)${quotes}/${quotes}deletedbiblioitem\.$1${quotes}/g;
        $query =~    # handle ambiguous 'biblionumber'
            s/${quotes}(biblio_id)${quotes}/${quotes}me\.$1${quotes}/g;
    }

    return $query;
}

=head3 _type

=cut

sub _type {
    return 'Deletedbiblio';
}

=head3 object_class

Single object class

=cut

sub object_class {
    return 'Koha::Old::Biblio';
}

1;
