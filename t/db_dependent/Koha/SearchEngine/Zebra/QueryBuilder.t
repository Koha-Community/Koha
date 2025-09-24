#!/usr/bin/perl
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 3;
use t::lib::Mocks;
use t::lib::TestBuilder;
use Test::MockModule;

use Koha::Database;
use Koha::SearchEngine::Zebra::QueryBuilder;

my $schema = Koha::Database->new->schema;

subtest 'build_query_compat() SearchLimitLibrary tests' => sub {

    plan tests => 18;

    $schema->storage->txn_begin;

    my $builder = t::lib::TestBuilder->new;

    my $branch_1 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $branch_2 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $group    = $builder->build_object(
        {
            class => 'Koha::Library::Groups',
            value => {
                ft_search_groups_opac  => 1,
                ft_search_groups_staff => 1,
                parent_id              => undef,
                branchcode             => undef
            }
        }
    );
    my $group_1 = $builder->build_object(
        {
            class => 'Koha::Library::Groups',
            value => {
                parent_id  => $group->id,
                branchcode => $branch_1->id
            }
        }
    );
    my $group_2 = $builder->build_object(
        {
            class => 'Koha::Library::Groups',
            value => {
                parent_id  => $group->id,
                branchcode => $branch_2->id
            }
        }
    );
    my $groupid     = $group->id;
    my @branchcodes = sort { $a cmp $b } ( $branch_1->id, $branch_2->id );

    my $query_builder = Koha::SearchEngine::Zebra::QueryBuilder->new( { index => $Koha::SearchEngine::BIBLIOS_INDEX } );
    t::lib::Mocks::mock_preference( 'SearchLimitLibrary', 'both' );
    my ( undef, undef, undef, undef, undef, $limit, $limit_cgi, $limit_desc, undef ) =
        $query_builder->build_query_compat( undef, undef, undef, ["branch:CPL"], undef, undef, undef, undef );
    is( $limit,      "(homebranch= CPL or holdingbranch= CPL)", "Branch limit expanded to home/holding branch" );
    is( $limit_desc, "(homebranch: CPL or holdingbranch: CPL)", "Limit description correctly expanded" );
    is( $limit_cgi,  "&limit=branch%3ACPL",                     "Limit cgi does not get expanded" );
    ( undef, undef, undef, undef, undef, $limit, $limit_cgi, $limit_desc, undef ) = $query_builder->build_query_compat(
        undef, undef, undef, ["multibranchlimit:$groupid"], undef, undef, undef,
        undef
    );
    is(
        $limit,
        "(homebranch= $branchcodes[0] or homebranch= $branchcodes[1] or holdingbranch= $branchcodes[0] or holdingbranch= $branchcodes[1])",
        "Multibranch limit expanded to home/holding branches"
    );
    is(
        $limit_desc,
        "(homebranch: $branchcodes[0] or homebranch: $branchcodes[1] or holdingbranch: $branchcodes[0] or holdingbranch: $branchcodes[1])",
        "Multibranch limit description correctly expanded"
    );
    is( $limit_cgi, "&limit=multibranchlimit%3A$groupid", "Multibranch limit cgi does not get expanded" );

    t::lib::Mocks::mock_preference( 'SearchLimitLibrary', 'homebranch' );
    ( undef, undef, undef, undef, undef, $limit, $limit_cgi, $limit_desc, undef ) =
        $query_builder->build_query_compat( undef, undef, undef, ["branch:CPL"], undef, undef, undef, undef );
    is( $limit,      "(homebranch= CPL)",   "branch limit expanded to home branch" );
    is( $limit_desc, "(homebranch: CPL)",   "limit description correctly expanded" );
    is( $limit_cgi,  "&limit=branch%3ACPL", "limit cgi does not get expanded" );
    ( undef, undef, undef, undef, undef, $limit, $limit_cgi, $limit_desc, undef ) = $query_builder->build_query_compat(
        undef, undef, undef, ["multibranchlimit:$groupid"], undef, undef, undef,
        undef
    );
    is(
        $limit, "(homebranch= $branchcodes[0] or homebranch= $branchcodes[1])",
        "branch limit expanded to home branch"
    );
    is(
        $limit_desc, "(homebranch: $branchcodes[0] or homebranch: $branchcodes[1])",
        "limit description correctly expanded"
    );
    is( $limit_cgi, "&limit=multibranchlimit%3A$groupid", "Limit cgi does not get expanded" );

    t::lib::Mocks::mock_preference( 'SearchLimitLibrary', 'holdingbranch' );
    ( undef, undef, undef, undef, undef, $limit, $limit_cgi, $limit_desc, undef ) =
        $query_builder->build_query_compat( undef, undef, undef, ["branch:CPL"], undef, undef, undef, undef );
    is( $limit,      "(holdingbranch= CPL)", "branch limit expanded to holding branch" );
    is( $limit_desc, "(holdingbranch: CPL)", "Limit description correctly expanded" );
    is( $limit_cgi,  "&limit=branch%3ACPL",  "Limit cgi does not get expanded" );
    ( undef, undef, undef, undef, undef, $limit, $limit_cgi, $limit_desc, undef ) = $query_builder->build_query_compat(
        undef, undef, undef, ["multibranchlimit:$groupid"], undef, undef, undef,
        undef
    );
    is(
        $limit, "(holdingbranch= $branchcodes[0] or holdingbranch= $branchcodes[1])",
        "branch limit expanded to holding branch"
    );
    is(
        $limit_desc, "(holdingbranch: $branchcodes[0] or holdingbranch: $branchcodes[1])",
        "Limit description correctly expanded"
    );
    is( $limit_cgi, "&limit=multibranchlimit%3A$groupid", "Limit cgi does not get expanded" );

};

subtest "Handle search filters" => sub {
    plan tests => 7;

    my $qb;

    ok(
        $qb = Koha::SearchEngine::Zebra::QueryBuilder->new( { 'index' => 'biblios' } ),
        'Creating new query builder object for biblios'
    );

    my $filter = Koha::SearchFilter->new(
        {
            name   => "test",
            query  => q|{"operands":["cat","bat","rat"],"indexes":["kw","ti","au"],"operators":["AND","OR"]}|,
            limits => q|{"limits":["mc-itype,phr:BK","mc-itype,phr:MU","available"]}|,
        }
    )->store;
    my $filter_id = $filter->id;

    my ( undef, undef, undef, undef, undef, $limit, $limit_cgi, $limit_desc ) =
        $qb->build_query_compat( undef, undef, undef, ["search_filter:$filter_id"] );

    is(
        $limit,
        q{(kw=(cat) AND ti=(bat) OR au=(rat)) and (mc-itype,phr=BK or mc-itype,phr=MU) and (( (allrecords,AlwaysMatches='') and (not-onloan-count,st-numeric >= 1) and (lost,st-numeric=0) ))},
        "Limit correctly formed"
    );
    is( $limit_cgi, "&limit=search_filter%3A$filter_id", "CGI limit is not expanded" );
    is(
        $limit_desc,
        q{(kw=(cat) AND ti=(bat) OR au=(rat)) and (mc-itype,phr=BK or mc-itype,phr=MU) and (( (allrecords,AlwaysMatches='') and (not-onloan-count,st-numeric >= 1) and (lost,st-numeric=0) ))},
        "Limit description is correctly expanded"
    );

    $filter = Koha::SearchFilter->new(
        {
            name   => "test",
            query  => q|{"operands":["su:biography"],"indexes":[],"operators":[]}|,
            limits => q|{"limits":[]}|,
        }
    )->store;
    $filter_id = $filter->id;

    ( undef, undef, undef, undef, undef, $limit, $limit_cgi, $limit_desc ) =
        $qb->build_query_compat( undef, undef, undef, ["search_filter:$filter_id"] );

    is( $limit,      q{((su=biography))},                 "Limit correctly formed for ccl type query" );
    is( $limit_cgi,  "&limit=search_filter%3A$filter_id", "CGI limit is not expanded" );
    is( $limit_desc, q{((su=biography))},                 "Limit description is correctly handled for ccl type query" );

};
