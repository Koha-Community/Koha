#!/usr/bin/perl

use Modern::Perl;

use C4::Context;
use YAML::Syck;

use Koha::SearchMarcMaps;
use Koha::SearchFields;

my $dbh = C4::Context->dbh;


$dbh->do(q|INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type)
        VALUES('SearchEngine','Zebra','Choose format to display postal addresses','','Choice')|);


$dbh->do(q|DROP TABLE IF EXISTS search_marc_to_field|);
$dbh->do(q|DROP TABLE IF EXISTS search_marc_map|);
$dbh->do(q|DROP TABLE IF EXISTS search_field|);

# This specifies the fields that will be stored in the search engine.
$dbh->do(q|
    CREATE TABLE `search_field` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `name` varchar(255) NOT NULL COMMENT 'the name of the field as it will be stored in the search engine',
      `label` varchar(255) NOT NULL COMMENT 'the human readable name of the field, for display',
      `type` ENUM('string', 'date', 'number', 'boolean', 'sum') NOT NULL COMMENT 'what type of data this holds, relevant when storing it in the search engine',
      PRIMARY KEY (`id`),
      UNIQUE KEY (`name`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci
|);

# This contains a MARC field specifier for a given index, marc type, and marc
# field.
$dbh->do(q|
    CREATE TABLE `search_marc_map` (
        id int(11) NOT NULL AUTO_INCREMENT,
        index_name ENUM('biblios','authorities') NOT NULL COMMENT 'what storage index this map is for',
        marc_type ENUM('marc21', 'unimarc', 'normarc') NOT NULL COMMENT 'what MARC type this map is for',
        marc_field VARCHAR(255) NOT NULL COMMENT 'the MARC specifier for this field',
        PRIMARY KEY(`id`),
        unique key( index_name, marc_field, marc_type),
        INDEX (`index_name`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci
|);

# This joins the two search tables together. We can have any combination:
# one marc field could have many search fields (maybe you want one value
# to go to 'author' and 'corporate-author) and many marc fields could go
# to one search field (e.g. all the various author fields going into
# 'author'.)
#
# a note about the sort field:
# * if all the entries for a mapping are 'null', nothing special is done with that mapping.
# * if any of the entries are not null, then a __sort field is created in ES for this mapping. In this case:
#   * any mapping with sort == false WILL NOT get copied into a __sort field
#   * any mapping with sort == true or is null WILL get copied into a __sort field
#   * any sorts on the field name will be applied to $fieldname.'__sort' instead.
# this means that we can have search for author that includes 1xx, 245$c, and 7xx, but the sort only applies to 1xx.
$dbh->do(q|
    CREATE TABLE `search_marc_to_field` (
        search_marc_map_id int(11) NOT NULL,
        search_field_id int(11) NOT NULL,
        facet boolean DEFAULT FALSE COMMENT 'true if a facet field should be generated for this',
        suggestible boolean DEFAULT FALSE COMMENT 'true if this field can be used to generate suggestions for browse',
        sort boolean DEFAULT NULL COMMENT 'true/false creates special sort handling, null doesn''t',
        PRIMARY KEY(search_marc_map_id, search_field_id),
        FOREIGN KEY(search_marc_map_id) REFERENCES search_marc_map(id) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY(search_field_id) REFERENCES search_field(id) ON DELETE CASCADE ON UPDATE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci
|);

my $mappings_yaml = C4::Context->config('intranetdir') . '/admin/searchengine/elasticsearch/mappings.yaml';
my $indexes = LoadFile( $mappings_yaml );

while ( my ( $index_name, $fields ) = each %$indexes ) {
    while ( my ( $field_name, $data ) = each %$fields ) {
        my $field_type = $data->{type};
        my $field_label = $data->{label};
        my $mappings = $data->{mappings};
        my $search_field = Koha::SearchFields->find_or_create({ name => $field_name, label => $field_label, type => $field_type }, { key => 'name' });
        for my $mapping ( @$mappings ) {
            my $marc_field = Koha::SearchMarcMaps->find_or_create({ index_name => $index_name, marc_type => $mapping->{marc_type}, marc_field => $mapping->{marc_field} });
            $search_field->add_to_search_marc_maps($marc_field, { facet => $mapping->{facet}, suggestible => $mapping->{suggestible}, sort => $mapping->{sort} } );
        }
    }
}
