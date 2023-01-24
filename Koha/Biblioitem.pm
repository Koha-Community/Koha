package Koha::Biblioitem;

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

use base qw(Koha::Object);

=head1 NAME

Koha::Biblioitem - Koha Biblioitem Object class

=head1 API

=head2 Class methods

=head3 public_read_list

This method returns the list of publicly readable database fields for both API and UI output purposes

=cut

sub public_read_list {
    return [
        'volume',           'number',                'isbn',
        'issn',             'ean',                   'publicationyear',
        'publishercode',    'volumedate',            'columedesc',
        'collectiontitle',  'collectionissn',        'collectionvolume',
        'editionstatement', 'editionresponsibility', 'pages',
        'place',            'lccn',                  'url',
        'cn_source',        'cn_class',              'cn)item',
        'cn_suffix',        'cn_sort',               'agerestriction',
        'totalissues'
    ];
}

=head3 to_api_mapping

This method returns the mapping for representing a Koha::Biblioitem object
on the API.

=cut

sub to_api_mapping {
    return {
        agerestriction   => 'age_restriction',
        biblionumber     => 'biblio_id',
        biblioitemnumber => undef, # meaningless
        collectionissn   => 'collection_issn',
        collectiontitle  => 'collection_title',
        collectionvolume => 'collection_volume',
        editionresponsibility => undef, # obsolete, not mapped
        editionstatement => 'edition_statement',
        illus            => 'illustrations',
        itemtype         => 'item_type',
        lccn             => 'lc_control_number',
        place            => 'publication_place',
        publicationyear  => 'publication_year',
        publishercode    => 'publisher',
        size             => 'material_size',
        totalissues      => 'serial_total_issues',
        volumedate       => 'volume_date',
        volumedesc       => 'volume_description',
    };
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'Biblioitem';
}

1;
