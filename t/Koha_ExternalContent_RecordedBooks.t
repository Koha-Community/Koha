#!/usr/bin/env perl

use Modern::Perl;

use t::lib::Mocks;
use Test::More;
use Test::MockModule;

use Module::Load::Conditional qw( can_load );

plan tests => 3;

SKIP: {
    skip "cannot find WebService::ILS::RecordedBooks::Partner", 5
      unless can_load( modules => { 'WebService::ILS::RecordedBooks::Patron' => undef } );

    use_ok('Koha::ExternalContent::RecordedBooks');

    t::lib::Mocks::mock_preference('SessionStorage','tmp');

    t::lib::Mocks::mock_preference('RecordedBooksLibraryID', 'DUMMY');
    t::lib::Mocks::mock_preference('RecordedBooksClientSecret', 'DUMMY');
    t::lib::Mocks::mock_preference('RecordedBooksDomain', 'DUMMY');

    my $client = Koha::ExternalContent::RecordedBooks->new();
    local $@;
    eval { $client->search({query => "art"}) };
    ok($@ =~ /not authorized/, "Invalid RecordedBooks partner credentials");

    SKIP: {
        skip "no RecordedBooks partner credentials", 1 unless $ENV{RECORDEDBOOKS_TEST_LIBRARY_ID};

        t::lib::Mocks::mock_preference('RecordedBooksLibraryID', $ENV{RECORDEDBOOKS_TEST_LIBRARY_ID});
        t::lib::Mocks::mock_preference('RecordedBooksClientSecret', $ENV{RECORDEDBOOKS_TEST_CLIENT_SECRET});
        t::lib::Mocks::mock_preference('RecordedBooksDomain', $ENV{RECORDEDBOOKS_TEST_DOMAIN});

        $client = Koha::ExternalContent::RecordedBooks->new();
        my $res = $client->search({query => "art"});
        ok($res->{items}, "search")
    }
}
