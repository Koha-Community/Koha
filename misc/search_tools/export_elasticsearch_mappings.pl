#!/usr/bin/perl

# This inserts records from a Koha database into elastic search

# Copyright 2014 Catalyst IT
#
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

=head1 NAME

export_elasticsearch_mappings.pl - export search_marc_map, search_marc_to_field and search_field tables to YAML

=head1 SYNOPSIS

B<export_elasticsearch_mappings.pl>
[B<-t|--type>]
[B<--man>]

=head1 DESCRIPTION

Export search_marc_map, search_marc_to_field and search_field tables to YAML.

=head1 OPTIONS

=over

=item B<-t|--type>=C<marc21|unimarc|normarc>

Only export a specific marc type. All if empty.

=item B<--man>

Full documentation.

=back

=head1 IMPLEMENTATION

=cut

use Modern::Perl;

use Koha::Database;
use Koha::SearchFields;
use Koha::SearchMarcMaps;

use YAML;
use Getopt::Long;
use Pod::Usage;

my $type = '';
my $man;

GetOptions(
    't|type=s'  => \$type,
    'man'       => \$man,
);

pod2usage( -exitstatus => 0, -verbose => 2 ) if $man;

if ( $type && $type !~ /^(marc21|unimarc|normarc)$/ ) {
    print "Bad marc type provided.\n";
    pod2usage(1);
}

my $schema = Koha::Database->new()->schema();

my $search_fields = Koha::SearchFields->search();

my $yaml = {};
while ( my $search_field = $search_fields->next ) {

    my $marc_to_fields = $schema->resultset('SearchMarcToField')->search( { search_field_id => $search_field->id } );

    while ( my $marc_to_field = $marc_to_fields->next ) {
        my $marc_map = Koha::SearchMarcMaps->find( $marc_to_field->search_marc_map_id );

        next if $type && $marc_map->marc_type ne $type;

        $yaml->{ $marc_map->index_name }{ $search_field->name }{label} = $search_field->label;
        $yaml->{ $marc_map->index_name }{ $search_field->name }{type} = $search_field->type;
        $yaml->{ $marc_map->index_name }{ $search_field->name }{facet_order} = $search_field->facet_order;

        push (@{ $yaml->{ $marc_map->index_name }{ $search_field->name }{mappings} },
            {
                facet   => $marc_to_field->facet || '',
                marc_type => $marc_map->marc_type,
                marc_field => $marc_map->marc_field,
                sort        => $marc_to_field->sort,
                suggestible => $marc_to_field->suggestible || ''
            });

    }
}

print Dump($yaml);
