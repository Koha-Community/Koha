package Koha::Biblios;

# Copyright ByWater Solutions 2015
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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;


use Koha::Database;

use Koha::Biblio;
use Koha::Libraries;

use base qw(Koha::Objects Koha::Objects::Record::Collections);

=head1 NAME

Koha::Biblios - Koha Biblio object set class

=head1 API

=head2 Class methods

=head3 pickup_locations

    my $biblios = Koha::Biblios->search(...);
    my $pickup_locations = $biblios->pickup_locations({ patron => $patron });

For a given resultset, it returns all the pickup locations.

Throws a I<Koha::Exceptions::MissingParameter> exception if the B<mandatory> parameter I<patron>
is not passed.

=cut

sub pickup_locations {
    my ( $self, $params ) = @_;

    Koha::Exceptions::MissingParameter->throw( parameter => 'patron' )
      unless exists $params->{patron};

    my $patron = $params->{patron};

    my @pickup_locations;
    foreach my $biblio ( $self->as_list ) {
        push @pickup_locations,
          $biblio->pickup_locations( { patron => $patron } )
          ->_resultset->get_column('branchcode')->all;
    }

    return Koha::Libraries->search(
        {
            branchcode => \@pickup_locations
        },
        { order_by => ['branchname'] }
    );
}

=head2 Internal methods

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
            s/${quotes}${context}\.(age_restriction|cn_class|cn_item|cn_sort|cn_source|cn_suffix|collection_issn|collection_title|collection_volume|ean|edition_statement|illustrations|isbn|issn|item_type|lc_control_number|notes|number|pages|publication_place|publication_year|publisher|material_size|serial_total_issues|url|volume|volume_date|volume_description)${quotes}/${quotes}${context}\.biblioitem\.$1${quotes}/g;
    } else {
        $query =~
            s/${quotes}(age_restriction|cn_class|cn_item|cn_sort|cn_source|cn_suffix|collection_issn|collection_title|collection_volume|ean|edition_statement|illustrations|isbn|issn|item_type|lc_control_number|notes|number|pages|publication_place|publication_year|publisher|material_size|serial_total_issues|url|volume|volume_date|volume_description)${quotes}/${quotes}biblioitem\.$1${quotes}/g;
    }

    return $query;
}

=head3 _type

=cut

sub _type {
    return 'Biblio';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::Biblio';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
