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

use Test::More tests => 2;
use Test::MockModule;

use Koha::ArticleRequest::Status;
use Koha::ArticleRequests;
use Koha::Database;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'requested() tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $library_1 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library_2 = $builder->build_object( { class => 'Koha::Libraries' } );

    my $patron = $builder->build_object( { class => 'Koha::Patrons', value => { branchcode => $library_1->id, flags => 1 } } );
    t::lib::Mocks::mock_userenv( { patron => $patron } );

    # FIXME: we moved past this pattern. This method should be refactored
    #        as ->filter_by_requested
    Koha::ArticleRequests->delete;

    my $ar_mock = Test::MockModule->new('Koha::ArticleRequest');
    $ar_mock->mock( 'notify', sub { ok( 1, '->notify() called' ); } );

    my $ar_1 = $builder->build_object(
        {   class => 'Koha::ArticleRequests',
            value => { status => Koha::ArticleRequest::Status::Requested, branchcode => $library_1->id }
        }
    );

    my $ar_2 = $builder->build_object(
        {   class => 'Koha::ArticleRequests',
            value => { status => Koha::ArticleRequest::Status::Requested, branchcode => $library_2->id }
        }
    );

    my $ar_3 = $builder->build_object(
        {   class => 'Koha::ArticleRequests',
            value => { status => Koha::ArticleRequest::Status::Pending, branchcode => $library_2->id }
        }
    );

    my $requested = Koha::ArticleRequests->requested;
    is( $requested->count,        2,                                       'Two article requests with the REQUESTED status' );
    is( $requested->next->status, Koha::ArticleRequest::Status::Requested, 'Status is correct' );
    is( $requested->next->status, Koha::ArticleRequest::Status::Requested, 'Status is correct' );

    my $requested_branch = Koha::ArticleRequests->requested( $library_1->id );
    is( $requested_branch->count, 1, 'One article request with the REQUESTED status, for the selected branchcode' );
    is( $requested_branch->next->status, Koha::ArticleRequest::Status::Requested, 'Status is correct' );

    $schema->storage->txn_rollback;
};

subtest 'filter_by_current / filter_by_finished tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $ar_requested = $builder->build_object(
        {
            class => 'Koha::ArticleRequests',
            value => { status => Koha::ArticleRequest::Status::Requested }
        }
    );
    my $ar_pending = $builder->build_object(
        {
            class => 'Koha::ArticleRequests',
            value => { status => Koha::ArticleRequest::Status::Pending }
        }
    );
    my $ar_processing = $builder->build_object(
        {
            class => 'Koha::ArticleRequests',
            value => { status => Koha::ArticleRequest::Status::Processing }
        }
    );
    my $ar_completed = $builder->build_object(
        {
            class => 'Koha::ArticleRequests',
            value => { status => Koha::ArticleRequest::Status::Completed }
        }
    );
    my $ar_cancelled = $builder->build_object(
        {
            class => 'Koha::ArticleRequests',
            value => { status => Koha::ArticleRequest::Status::Canceled }
        }
    );

    my $article_requests = Koha::ArticleRequests->search(
        {
            id => [
                $ar_requested->id, $ar_pending->id, $ar_processing->id,
                $ar_completed->id, $ar_cancelled->id
            ]
        }
    );

    my $current_article_requests = $article_requests->filter_by_current;

    is( $current_article_requests->count, 3, 'Count is correct' );

    my $finished_article_requests = $article_requests->filter_by_finished;

    is( $finished_article_requests->count, 2, 'Count is correct' );

    $schema->storage->txn_rollback;
};
