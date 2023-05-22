#!/usr/bin/perl

# Copyright 2012, 2023 Koha development team
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

use t::lib::TestBuilder;

use Koha::Database;
use C4::SocialData qw( get_data get_report );

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

$schema->storage->txn_begin;

# trivial data for trivial tests
Koha::Biblioitems->search->update({ isbn => undef });
$builder->build({ source => 'Biblioitem', value => { isbn => '0-596-52674-1' } });
$builder->build({ source => 'Biblioitem', value => { isbn => '0-596-00289-0' } });
$builder->build({ source => 'SocialData', value => { isbn => '0-596-52674-1', score_avg => 6.5 } });
$builder->build({ source => 'SocialData', value => { isbn => '0-596-00289-0', score_avg => 7 } });

subtest 'get_data' => sub {
    plan tests => 3;

    my $data = C4::SocialData::get_data();
    is( $data, undef, 'get_data should return undef if no param given');

    $data = C4::SocialData::get_data('0-596-52674-1');
    is( $data->{isbn}, '0-596-52674-1', 'get_data should return the matching row');
    is( sprintf("%3.1f", $data->{score_avg}), 6.5, 'check score_avg');
};

subtest 'get_report' => sub {
    plan tests => 3;

    my $report =  C4::SocialData::get_report();
    # if isbn not normalized, social data not found, resulting in without key
    is( $report->{'without'}->[0]->{'original'}, '0-596-52674-1', 'testing get_report gives isbn' );
    is( $report->{'without'}->[0]->{'isbn'}, '9780596526740', 'testing get_report' );

    # test if we can get with key instead
    $schema->resultset('SocialData')->search({ isbn => '0-596-52674-1' })->next->update({ isbn => '9780596526740' });
    $report =  C4::SocialData::get_report();
    is( $report->{with}->[0]->{isbn}, '9780596526740', 'this isbn has social data' );
};

$schema->storage->txn_rollback;
