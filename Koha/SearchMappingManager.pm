package Koha::SearchMappingManager;

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
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

use Carp;

use Koha::Database;

=head1 NAME

Koha::SearchMappingManager - Manager for operating on search field mappings

=head1 SYNOPSIS

This class helps to interface with the complex internals of the koha.search_*-tables
and their respective Koha::Objects in a correct manner.

=cut




=head2 get_search_mappings

    my $search_fields = Koha::SearchMappingManager::get_search_mappings({index_name => 'biblios|authorities'});

    while ( my $search_field = $search_fields->next ) {
        $sub->(
            $search_field->get_column('name'),
            $search_field->get_column('type'),
            $search_field->get_column('facet'),
            $search_field->get_column('suggestible'),
            $search_field->get_column('sort'),
            $search_field->get_column('marc_type'),
            $search_field->get_column('marc_field'),
        );
    }

Get each entry from the searchengine mappings tables.

@PARAMS HASHRef of keys:
        index_name => 'biblios|authorities' #Which Koha record types to look for
        name       => 'title'               #The koha.search_fields.name
@RETURNS Koha::Schma::Resultset::SearchField with enriched fields from other relevant tables
@THROWS die when parameters are not properly given. Should throw a Koha::Exception::BadParameter,
            but pushing all those Exceptions to the community version would take ages.

=cut

sub get_search_mappings {
    my ($params) = @_;
    die "get_search_mappings():> parameter 'index_name' is missing" unless ($params->{index_name});

    my $search = {
        'search_marc_map.index_name' => $params->{index_name},
    };
    $search->{'me.name'} = $params->{name} if $params->{name};

    return Koha::Database->schema->resultset('SearchField')->search(
        $search,
        {   join => { search_marc_to_fields => 'search_marc_map' },
            '+select' => [
                'search_marc_to_fields.facet',
                'search_marc_to_fields.suggestible',
                'search_marc_to_fields.sort',
                'search_marc_map.marc_type',
                'search_marc_map.marc_field',
            ],
            '+as'     => [
                'facet',
                'suggestible',
                'sort',
                'marc_type',
                'marc_field',
            ],
        }
    );
}

=head2 flush

    Koha::SearchMappingManager::flush();

Removes all entries from the Koha's search mapping tables

=cut

sub flush {
    my $schema = Koha::Database->schema;
    $schema->resultset('SearchField')->delete_all();
    $schema->resultset('SearchMarcMap')->delete_all();
    $schema->resultset('SearchMarcToField')->delete_all();
}


=head2 add_mapping

    Koha::SearchMappingManager::add_mapping({name => 'ln-test',
                                             label => 'original language',
                                             type => 'keyword',
                                             index_name => 'biblios',
                                             marc_type => 'marc21',
                                             marc_field => '024a',
                                             facet => 1,
                                             suggestible => 1,
                                             sort => 1});

=cut

sub add_mapping {
    my ($params) = @_;

    my $search_field = Koha::SearchFields->find_or_create({  name =>  $params->{name} ,
                                                             label => $params->{label},
                                                             type =>  $params->{type} ,},
                                                          { key => 'name' });

    my $marc_field = Koha::SearchMarcMaps->find_or_create({ index_name => $params->{index_name},
                                                            marc_type  => $params->{marc_type} ,
                                                            marc_field => $params->{marc_field}, });

    ##update_or_create
    my $p = {
        search_field_id => $search_field->id,
        search_marc_map_id => $marc_field->id,
    };
    $p->{facet}       = $params->{facet}       if $params->{facet};
    $p->{suggestible} = $params->{suggestible} if $params->{suggestible};
    $p->{sort}        = $params->{sort}        if $params->{sort};
    Koha::Database->schema->resultset('SearchMarcToField')->update_or_create($p);
}

1;
