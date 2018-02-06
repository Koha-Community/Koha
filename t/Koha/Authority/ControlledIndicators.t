#!/usr/bin/perl

use Modern::Perl;
use Data::Dumper qw/Dumper/;
use MARC::Record;
use MARC::Field;
use Test::More tests => 2;

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

subtest "Tests for sub _thesaurus_info" => sub {
    plan tests => 10;

    t::lib::Mocks::mock_preference('AuthorityControlledIndicators', q|marc21,600,ignored,ind2:thesaurus|);
    my $oInd = Koha::Authority::ControlledIndicators->new;

    my $record = MARC::Record->new;
    $record->append_fields(
        MARC::Field->new( '008', (' 'x11).'a' ),
        MARC::Field->new( '040', '', '', f => 'very_special' ),
    );

    # Case 1: LOC code a in auth record should become 0 in 6XX ind2
    my $res = $oInd->get({
        flavour => "MARC21",
        report_tag  => '100',
        auth_record => $record,
        biblio_tag  => '600',
    });
    is( $res->{ind2}, '0', 'Indicator matched for LOC headings' );
    is( $res->{sub2}, undef, 'No subfield 2' );

    # Case 2: Code n (Not applicable) should become 4 (source not specified)
    $record->field('008')->update( (' 'x11).'n' );
    $res = $oInd->get({
        flavour => "MARC21",
        report_tag  => '100',
        auth_record => $record,
        biblio_tag  => '600',
    });
    is( $res->{ind2}, '4', 'Source not specified' );
    is( $res->{sub2}, undef, 'No subfield 2' );

    # Case 3: AAT thesaurus (and subfield $2)
    $record->field('008')->update( (' 'x11).'r' );
    $res = $oInd->get({
        flavour => "MARC21",
        report_tag  => '100',
        auth_record => $record,
        biblio_tag  => '600',
    });
    is( $res->{ind2}, '7', 'AAT, see subfield 2' );
    is( $res->{sub2}, 'aat', 'Subfield 2 verified' );

    # Case 4: Code z triggers a fetch from 040$f (and subfield $2)
    $record->field('008')->update( (' 'x11).'z' );
    $res = $oInd->get({
        flavour => "MARC21",
        report_tag  => '100',
        auth_record => $record,
        biblio_tag  => '600',
    });
    is( $res->{ind2}, '7', 'Code z, see subfield 2' );
    is( $res->{sub2}, 'very_special', 'Subfield 2 from 040$f' );

    # Case 5: Code e does not belong in 008/11
    $record->field('008')->update( (' 'x11).'e' );
    $res = $oInd->get({
        flavour => "MARC21",
        report_tag  => '100',
        auth_record => $record,
        biblio_tag  => '600',
    });
    is( $res->{ind2}, '4', 'Code e triggers not specified' );
    is( $res->{sub2}, undef, 'No subfield 2' );
};
