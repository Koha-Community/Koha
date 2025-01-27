#!/usr/bin/perl

# This inserts records from a Koha database into elastic search

# Copyright 2020 Koha Development Team
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

=item B<-t|--type>=C<marc21|unimarc>

Only export a specific marc type. All if empty.

=item B<--man>

Full documentation.

=back

=head1 IMPLEMENTATION

=cut

use Modern::Perl;
use Encode;

use Koha::Script;
use Koha::Database;
use Koha::SearchFields;
use Koha::SearchMarcMaps;
use Koha::SearchEngine::Elasticsearch;

use YAML::XS;
use Getopt::Long qw( GetOptions );
use Pod::Usage   qw( pod2usage );

my $type = '';
my $man;

GetOptions(
    't|type=s' => \$type,
    'man'      => \$man,
);

pod2usage( -exitstatus => 0, -verbose => 2 ) if $man;

if ( $type && $type !~ /^(marc21|unimarc)$/ ) {
    print "Bad marc type provided.\n";
    pod2usage(1);
}

my $mappings = Koha::SearchEngine::Elasticsearch::raw_elasticsearch_mappings($type);

binmode STDOUT, ":encoding(UTF-8)";
print Encode::decode_utf8( YAML::XS::Dump($mappings) );
