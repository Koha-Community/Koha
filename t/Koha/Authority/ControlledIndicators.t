#!/usr/bin/perl

use Modern::Perl;
use Data::Dumper qw/Dumper/;
use MARC::Record;
use MARC::Field;
use Test::More tests => 1;

use t::lib::Mocks;
use Koha::Authority::ControlledIndicators;

subtest "Simple tests" => sub {
    plan tests => 10;

    t::lib::Mocks::mock_preference('AuthorityControlledIndicators', q|
marc21,600,ind1:auth1,ind2:x
marc21,700,ind1:auth2,
marc21,800,ind1:,
    |);

    my $oInd = Koha::Authority::ControlledIndicators->new;

    is_deeply( $oInd->get({}), {}, 'Empty hash for no parameters' );
    my $record = MARC::Record->new;
    $record->append_fields(
        MARC::Field->new( '100', '3', '4', a => 'My name' ),
    );
    my $res = $oInd->get({
        flavour => "MARC21",
        report_tag  => '100',
        auth_record => $record,
        biblio_tag  => '600',
    });
    is( $res->{ind1}, '3', 'Check 1st indicator' );
    is( exists $res->{ind2}, 1, 'Check existence of 2nd indicator key' );
    is( $res->{ind2}, 'x', 'Check 2nd indicator value' );

    $res = $oInd->get({
        flavour => "MARC21",
        report_tag  => '100',
        auth_record => $record,
        biblio_tag  => '700',
    });
    is( $res->{ind1}, '4', 'Check 1st indicator' );
    is( exists $res->{ind2}, '', 'Check if 2nd indicator key does not exist' );

    $res = $oInd->get({
        flavour => "MARC21",
        report_tag  => '100',
        auth_record => $record,
        biblio_tag  => '800',
    });
    is( $res->{ind1}, '', 'ind1: clears 1st indicator' );
    is( exists $res->{ind2}, '', 'Check if 2nd indicator key does not exist' );

    # Test caching
    t::lib::Mocks::mock_preference('AuthorityControlledIndicators', q{} );
    $res = $oInd->get({
        flavour => "MARC21",
        report_tag  => '100',
        auth_record => $record,
        biblio_tag  => '700',
    });
    is( $res->{ind1}, '4', 'Cache not cleared yet' );
    $oInd->clear;
    $res = $oInd->get({
        flavour => "MARC21",
        report_tag  => '100',
        auth_record => $record,
        biblio_tag  => '700',
    });
    is_deeply( $res, {}, 'Cache cleared' );
};
