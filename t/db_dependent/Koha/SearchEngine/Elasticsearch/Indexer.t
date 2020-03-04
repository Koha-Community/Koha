#!/usr/bin/perl

# Copyright 2015 Catalyst IT
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

use Test::More tests => 2;
use Test::MockModule;
use t::lib::Mocks;

use MARC::Record;

use Koha::Database;

my $schema = Koha::Database->schema();

use_ok('Koha::SearchEngine::Elasticsearch::Indexer');

SKIP: {

    eval { Koha::SearchEngine::Elasticsearch->get_elasticsearch_params; };

    skip 'Elasticsearch configuration not available', 1
        if $@;

subtest 'create_index() tests' => sub {
    plan tests => 6;
    my $se = Test::MockModule->new( 'Koha::SearchEngine::Elasticsearch' );
    $se->mock( '_read_configuration', sub {
            my ($self, $sub ) = @_;
            my $method = $se->original( '_read_configuration' );
            my $conf = $method->( $self );
            $conf->{index_name} .= '__test';
            return $conf;
        });

    my $indexer;
    ok(
        $indexer = Koha::SearchEngine::Elasticsearch::Indexer->new({ 'index' => 'biblios' }),
        'Creating a new indexer object'
    );

    is(
        $indexer->create_index(),
        Koha::SearchEngine::Elasticsearch::Indexer::INDEX_STATUS_OK(),
        'Creating an index'
    );

    my $marc_record = MARC::Record->new();
    $marc_record->append_fields(
        MARC::Field->new('001', '1234567'),
        MARC::Field->new('020', '', '', 'a' => '1234567890123'),
        MARC::Field->new('245', '', '', 'a' => 'Title')
    );
    my $records = [$marc_record];

    my $response = $indexer->update_index([1], $records);
    is( $response->{errors}, 0, "no error on update_index" );
    is( scalar(@{$response->{items}}), 1, "1 item indexed" );
    is( $response->{items}[0]->{index}->{_id},"1", "We should get a string matching the bibnumber passed in");

    is(
        $indexer->drop_index(),
        Koha::SearchEngine::Elasticsearch::Indexer::INDEX_STATUS_RECREATE_REQUIRED(),
        'Dropping the index'
    );
};
}
