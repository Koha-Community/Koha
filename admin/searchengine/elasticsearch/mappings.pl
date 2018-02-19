#!/usr/bin/perl

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
use CGI;
use C4::Koha;
use C4::Output;
use C4::Auth;

use Koha::SearchEngine::Elasticsearch;
use Koha::SearchMarcMaps;
use Koha::SearchFields;

my $input = new CGI;
my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {   template_name   => 'admin/searchengine/elasticsearch/mappings.tt',
        query           => $input,
        type            => 'intranet',
        authnotrequired => 0,
        flagsrequired   => { superlibrarian => 1 },                          # Create a specific permission?
    }
);

my $index = $input->param('index') || 'biblios';
my $op    = $input->param('op')    || 'list';
my @messages;

my $database = Koha::Database->new();
my $schema   = $database->schema;

my $marc_type = lc C4::Context->preference('marcflavour');

if ( $op eq 'edit' ) {

    $schema->storage->txn_begin;

    my @field_name = $input->param('search_field_name');
    my @field_label = $input->param('search_field_label');
    my @field_type = $input->param('search_field_type');

    my @index_name          = $input->param('mapping_index_name');
    my @search_field_name  = $input->param('mapping_search_field_name');
    my @mapping_sort        = $input->param('mapping_sort');
    my @mapping_facet       = $input->param('mapping_facet');
    my @mapping_suggestible = $input->param('mapping_suggestible');
    my @mapping_marc_field  = $input->param('mapping_marc_field');

    eval {

        for my $i ( 0 .. scalar(@field_name) - 1 ) {
            my $field_name = $field_name[$i];
            my $field_label = $field_label[$i];
            my $field_type = $field_type[$i];
            my $search_field = Koha::SearchFields->find( { name => $field_name }, { key => 'name' } );
            $search_field->label($field_label);
            $search_field->type($field_type);
            $search_field->store;
        }

        Koha::SearchMarcMaps->search( { marc_type => $marc_type, } )->delete;

        for my $i ( 0 .. scalar(@index_name) - 1 ) {
            my $index_name          = $index_name[$i];
            my $search_field_name  = $search_field_name[$i];
            my $mapping_marc_field  = $mapping_marc_field[$i];
            my $mapping_facet       = $mapping_facet[$i];
            my $mapping_suggestible = $mapping_suggestible[$i];
            my $mapping_sort        = $mapping_sort[$i];
            $mapping_sort = undef if $mapping_sort eq 'undef';

            my $search_field = Koha::SearchFields->find({ name => $search_field_name }, { key => 'name' });
            # TODO Check mapping format
            my $marc_field = Koha::SearchMarcMaps->find_or_create({ index_name => $index_name, marc_type => $marc_type, marc_field => $mapping_marc_field });
            $search_field->add_to_search_marc_maps($marc_field, { facet => $mapping_facet, suggestible => $mapping_suggestible, sort => $mapping_sort } );

        }
    };
    if ($@) {
        push @messages, { type => 'error', code => 'error_on_update', message => $@, };
        $schema->storage->txn_rollback;
    } else {
        push @messages, { type => 'message', code => 'success_on_update' };
        $schema->storage->txn_commit;
    }
}
elsif( $op eq 'reset' || $op eq 'reset_confirmed' ) {
    Koha::SearchMarcMaps->delete;
    Koha::SearchFields->delete;
    Koha::SearchEngine::Elasticsearch->reset_elasticsearch_mappings;
    push @messages, { type => 'message', code => 'success_on_reset' };
}
elsif( $op eq 'reset_confirm' ) {
    $template->param( reset_confirm => 1 );
}


my @indexes;

for my $index_name (qw| biblios authorities |) {
    my $search_fields = Koha::SearchFields->search(
        { 'search_marc_map.index_name' => $index_name, 'search_marc_map.marc_type' => $marc_type, },
        {   join => { search_marc_to_fields => 'search_marc_map' },
            '+select' => [ 'search_marc_to_fields.facet', 'search_marc_to_fields.suggestible', 'search_marc_to_fields.sort', 'search_marc_map.marc_field' ],
            '+as'     => [ 'facet',                       'suggestible',                       'sort',                       'marc_field' ],
            order_by => { -asc => [qw/name marc_field/] }
        }
    );

    my @mappings;
    while ( my $s = $search_fields->next ) {
        push @mappings,
          { search_field_name  => $s->name,
            search_field_label => $s->label,
            search_field_type  => $s->type,
            marc_field         => $s->get_column('marc_field'),
            sort               => $s->get_column('sort') // 'undef', # To avoid warnings "Use of uninitialized value in lc"
            suggestible        => $s->get_column('suggestible'),
            facet              => $s->get_column('facet'),
          };
    }

    push @indexes, { index_name => $index_name, mappings => \@mappings };
}

my $search_fields = $schema->resultset('SearchField')->search;
my @all_search_fields = $search_fields->search( {}, { order_by => ['name'] } );
$template->param(
    indexes           => \@indexes,
    all_search_fields => \@all_search_fields,
    messages          => \@messages,
);

output_html_with_http_headers $input, $cookie, $template->output;
