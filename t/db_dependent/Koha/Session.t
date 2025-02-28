#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 2;

use t::lib::TestBuilder;
use t::lib::Mocks;
use C4::Auth;
use Koha::Session;

my $schema  = Koha::Database->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'basic session fetch' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $patron =
        $builder->build_object( { class => 'Koha::Patrons', value => { userid => 'superman' } } );

    my $basic_session = C4::Auth::create_basic_session( { patron => $patron, interface => 'staff' } );
    is( $basic_session->param('id'), 'superman', 'basic session created as expected' );
    $basic_session->flush;

    my $session = Koha::Session->get_session( { sessionID => $basic_session->id } );
    is( $session->param('id'), 'superman', 'basic session fetched as expected' );

    $schema->storage->txn_rollback;
};

subtest 'test session driver' => sub {
    plan tests => 3;

    t::lib::Mocks::mock_preference( 'SessionStorage', 'mysql' );
    my $params = Koha::Session->_get_session_params();
    is( $params->{dsn}, 'serializer:yamlxs;driver:MySQL;id:md5', 'dsn setup correctly' );

    t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );
    $params = Koha::Session->_get_session_params();
    is( $params->{dsn}, 'serializer:yamlxs;driver:File;id:md5', 'dsn setup correctly' );

    t::lib::Mocks::mock_preference( 'SessionStorage', 'memcached' );
    $params = Koha::Session->_get_session_params();
    is( $params->{dsn}, 'serializer:yamlxs;driver:memcached;id:md5', 'dsn setup correctly' );
};
