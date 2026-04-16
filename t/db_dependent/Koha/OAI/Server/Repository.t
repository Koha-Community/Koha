#!/usr/bin/perl

# This file is part of Koha
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
use Test::NoWarnings;
use Test::More tests => 3;    # N + 1 (NoWarnings)
use Test::MockModule;
use Test::Exception;

use MARC::Record;
use MARC::File::XML;

use Koha::Caches;
use Koha::Database;
use Koha::OAI::Server::Repository;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

# Helper: build a repository object, silencing the Identify output
sub _build_repository {
    my $repository;
    my $stdout;
    local *STDOUT;
    open STDOUT, '>', \$stdout;
    $repository = Koha::OAI::Server::Repository->new();
    return $repository;
}

subtest 'get_biblio_marcxml() expanded_avs tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    # disable config, we are gonna force it
    t::lib::Mocks::mock_preference( 'marcflavour',      'MARC21' );
    t::lib::Mocks::mock_preference( 'OAI-PMH:ConfFile', 1 );          # so it loads the mocked one
    t::lib::Mocks::mock_preference( 'OpacHiddenItems',  '' );
    t::lib::Mocks::mock_preference( 'OpacSuppression',  0 );

    my $library =
        $builder->build_object( { class => 'Koha::Libraries', value => { branchname => q{Nick's Library} } } );
    my $item = $builder->build_sample_item( { library => $library->id } );

    my $cache = Koha::Caches->get_instance;
    $cache->clear_from_cache("MarcCodedFields-");

    # Clear GetAuthorisedValueDesc-generated cache
    $cache->clear_from_cache("libraries:name");
    $cache->clear_from_cache("itemtype:description:en");
    $cache->clear_from_cache("cn_sources:description");

    my $cgi = Test::MockModule->new('CGI');
    $cgi->mock( 'Vars', sub { ( 'verb', 'Identify' ); } );
    my $yaml = Test::MockModule->new('YAML::XS');
    $yaml->mock(
        'LoadFile',
        sub {
            return {
                format => {
                    not_expanded => {
                        include_items => 1,
                        expanded_avs  => 0,
                    },
                    expanded => {
                        include_items => 1,
                        expanded_avs  => 1,
                    }
                }
            };
        }
    );

    my $repository = _build_repository();

    # not expanded case
    my ($xml)      = $repository->get_biblio_marcxml( $item->biblionumber, 'not_expanded' );
    my $record     = MARC::Record->new_from_xml($xml);
    my $item_field = $record->field('952');

    is( $item_field->subfield('a'), $library->branchcode );

    # expanded case
    ($xml) = $repository->get_biblio_marcxml( $item->biblionumber, 'expanded' );
    $record     = MARC::Record->new_from_xml($xml);
    $item_field = $record->field('952');

    is( $item_field->subfield('a'), $library->branchname );

    $schema->storage->txn_rollback;
};

subtest 'get_biblio_marcxml() OpacSuppression tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'marcflavour',      'MARC21' );
    t::lib::Mocks::mock_preference( 'OAI-PMH:ConfFile', 0 );
    t::lib::Mocks::mock_preference( 'OpacHiddenItems',  '' );

    my $biblio = $builder->build_sample_biblio();

    my $cgi = Test::MockModule->new('CGI');
    $cgi->mock( 'Vars', sub { ( 'verb', 'Identify' ); } );

    my $repository = _build_repository();

    # Suppression disabled: record returned regardless of flag
    t::lib::Mocks::mock_preference( 'OpacSuppression', 0 );
    $biblio->opac_suppressed(1)->store;
    my ($xml) = $repository->get_biblio_marcxml( $biblio->biblionumber, 'oai_dc' );
    ok( $xml, 'Record returned when OpacSuppression is disabled even if opac_suppressed is set' );

    # Suppression enabled, record not suppressed: record returned
    t::lib::Mocks::mock_preference( 'OpacSuppression', 1 );
    $biblio->opac_suppressed(0)->store;
    ($xml) = $repository->get_biblio_marcxml( $biblio->biblionumber, 'oai_dc' );
    ok( $xml, 'Record returned when OpacSuppression is enabled but record is not suppressed' );

    # Suppression enabled, record suppressed: no record
    t::lib::Mocks::mock_preference( 'OpacSuppression', 1 );
    $biblio->opac_suppressed(1)->store;
    ($xml) = $repository->get_biblio_marcxml( $biblio->biblionumber, 'oai_dc' );
    is( $xml, undef, 'Record hidden when OpacSuppression is enabled and record is suppressed' );

    # Suppression disabled again: record returned
    t::lib::Mocks::mock_preference( 'OpacSuppression', 0 );
    ($xml) = $repository->get_biblio_marcxml( $biblio->biblionumber, 'oai_dc' );
    ok( $xml, 'Record returned again after OpacSuppression is disabled' );

    $schema->storage->txn_rollback;
};
