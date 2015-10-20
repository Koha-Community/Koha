#!/usr/bin/perl
#
#Testing C4 SocialData

use Modern::Perl;
use Test::More tests => 6;
use Test::MockModule;

BEGIN {
    use_ok('C4::SocialData');
}

use Test::DBIx::Class {
    schema_class => 'Koha::Schema',
    connect_info => ['dbi:SQLite:dbname=:memory:','',''],
    connect_opts => { name_sep => '.', quote_char => '`', },
    fixture_class => '::Populate',
}, 'SocialData', 'Biblioitem' ;

fixtures_ok [
    Biblioitem => [
        ['biblionumber', 'isbn'],
        [1, '0-596-52674-1'],
        [2, '0-596-00289-0'],
    ],
    SocialData => [
        [
            'isbn',            'num_critics',
            'num_critics_pro', 'num_quotations',
            'num_videos',      'score_avg',
            'num_scores'
        ],
        [ '0-596-52674-1', 1, 2, 3, 4, 5.2, 6 ],
        [ '0-596-00289-0', 2, 3, 4, 5, 6.2, 7 ]
    ],
], 'add fixtures';

my $db = Test::MockModule->new('Koha::Database');
$db->mock( _new_schema => sub { return Schema(); } );

my $data = C4::SocialData::get_data();
is( $data, undef, 'get_data should return undef if no param given');

$data = C4::SocialData::get_data('0-596-52674-1');
is( $data->{isbn}, '0-596-52674-1', 'get_data should return the matching row');

my $report =  C4::SocialData::get_report('0-596-52674-1');

is( $report->{'without'}->[0]->{'original'},
    '0-596-52674-1', 'testing get_report gives isbn' );

is( $report->{'without'}->[0]->{'isbn'}, '9780596526740',
    'testing get_report' );
