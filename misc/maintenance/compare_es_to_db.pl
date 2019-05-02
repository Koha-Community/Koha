#! /usr/bin/perl
#
# This compares record counts from a Koha database to Elasticsearch

# Copyright 2019 ByWater Solutions
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

compare_es_to_db.pl - compares record counts from a Koha database to Elasticsearch

=head1 SYNOPSIS

B<compare_es_to_db.pl>

=cut

use Modern::Perl;
use Koha::Items;
use Koha::SearchEngine::Elasticsearch;
use Array::Utils qw( array_diff );

use Koha::Biblios;
use Koha::Authorities;

foreach my $index ( ('biblios','authorities') ){
    print "=================\n";
    print "Checking $index\n";
    my @db_records = $index eq 'biblios' ? Koha::Biblios->search()->get_column('biblionumber') : Koha::Authorities->search()->get_column('authid');

    my $searcher = Koha::SearchEngine::Elasticsearch->new({ index => $index });
    my $es = $searcher->get_elasticsearch();
    my $count = $es->indices->stats( index => $searcher->get_elasticsearch_params->{index_name} )
        ->{_all}{primaries}{docs}{count};
    print "Count in db for $index is " . scalar @db_records . ", count in Elasticsearch is $count\n";

    # Otherwise, lets find all the ES ids
    my $scroll = $es->scroll_helper(
        index => $searcher->get_elasticsearch_params->{index_name},
        size => 5000,
        body => {
            query => {
                match_all => {}
            },
            stored_fields => []
        },
        scroll_in_qs => 1,
    );

    my @es_ids;

    my $i = 1;
    print "Fetching Elasticsearch records ids";
    while (my $doc = $scroll->next ){
        print "." if !($i % 500);
        print "\nFetching next 5000" if !($i % 5000);
        push @es_ids, $doc->{_id};
        $i++;
    }
    print "\nComparing arrays, this may take a while\n";

    # And compare the arrays
    my @diff = array_diff(@db_records, @es_ids );
    print "All records match\n" unless @diff;
    foreach my $problem (@diff){
        print "Record #$problem is not in both sources\n";
    }
}
