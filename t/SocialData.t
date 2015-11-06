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

use Test::More;
use Test::MockModule;

use Module::Load::Conditional qw/check_install/;

BEGIN {
    if ( check_install( module => 'Test::DBIx::Class' ) ) {
        plan tests => 6;
    } else {
        plan skip_all => "Need Test::DBIx::Class"
    }
}

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

1;
