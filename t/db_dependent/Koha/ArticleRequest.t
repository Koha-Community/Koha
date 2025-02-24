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

use Test::NoWarnings;
use Test::More tests => 7;
use Test::MockModule;
use Test::Exception;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::ArticleRequests;
use Koha::Exceptions::ArticleRequest;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'request() tests' => sub {

    plan tests => 13;

    $schema->storage->txn_begin;

    my $amount = 0;

    my $patron_mock = Test::MockModule->new('Koha::Patron');
    $patron_mock->mock( 'article_request_fee', sub { return $amount; } );

    my $patron = $builder->build_object( { class => 'Koha::Patrons', value => { lastseen => undef } } );
    my $item   = $builder->build_sample_item;

    my $ar_module = mock_article_request_module();

    my $ar = $builder->build_object(
        {
            class => 'Koha::ArticleRequests',
            value => {
                borrowernumber => $patron->id,
                biblionumber   => $item->biblionumber,
                debit_id       => undef,
            }
        }
    );

    t::lib::Mocks::mock_preference( 'TrackLastPatronActivityTriggers', '' );
    $ar->request()->discard_changes;

    is( $ar->status, Koha::ArticleRequest::Status::Requested );
    ok( defined $ar->created_on, 'created_on is set' );

    is( $ar->debit_id,             undef, 'No fee linked' );
    is( $patron->account->balance, 0,     'No outstanding fees' );
    $patron->discard_changes;
    is( $patron->lastseen, undef, 'Patron activity not tracked when article is not a valid trigger' );

    # set a fee amount
    $amount = 10;

    $ar = $builder->build_object(
        {
            class => 'Koha::ArticleRequests',
            value => {
                borrowernumber => $patron->id,
                biblionumber   => $item->biblionumber,
                itemnumber     => $item->id,
            }
        }
    );

    t::lib::Mocks::mock_preference( 'TrackLastPatronActivityTriggers', 'article' );
    $ar->request()->discard_changes;

    is( $ar->status, Koha::ArticleRequest::Status::Requested );
    is( $ar->itemnumber, $item->id, 'itemnumber set' );
    ok( defined $ar->created_on, 'created_on is set' );

    ok( defined $ar->debit_id, 'Fee linked' );
    is( $patron->account->balance, $amount, 'Outstanding fees with the right value' );
    $patron->discard_changes;
    isnt( $patron->lastseen, undef, 'Patron activity tracked when article is a valid trigger' );

    $schema->storage->txn_rollback;
};

subtest 'set_pending() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
    my $biblio = $builder->build_sample_biblio;

    my $ar_module = mock_article_request_module();

    my $ar = $builder->build_object(
        {
            class => 'Koha::ArticleRequests',
            value => {
                borrowernumber => $patron->id,
                biblionumber   => $biblio->id,
            }
        }
    );

    $ar->set_pending()->discard_changes;

    is( $ar->status, Koha::ArticleRequest::Status::Pending );
    ok( defined $ar->created_on, 'created_on is set' );

    $schema->storage->txn_rollback;
};

subtest 'process() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $ar_module = mock_article_request_module();

    my $ar = $builder->build_object(
        {
            class => 'Koha::ArticleRequests',
            value => { status => Koha::ArticleRequest::Status::Requested }
        }
    );

    $ar->process()->discard_changes;

    is( $ar->status, Koha::ArticleRequest::Status::Processing );

    $schema->storage->txn_rollback;
};

subtest 'complete() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $ar_module = mock_article_request_module();

    my $ar = $builder->build_object(
        {
            class => 'Koha::ArticleRequests',
            value => { status => Koha::ArticleRequest::Status::Requested }
        }
    );

    $ar->complete()->discard_changes;

    is( $ar->status, Koha::ArticleRequest::Status::Completed );

    $schema->storage->txn_rollback;
};

subtest 'cancel() tests' => sub {

    plan tests => 11;

    $schema->storage->txn_begin;

    my $amount = 11;

    my $patron_mock = Test::MockModule->new('Koha::Patron');
    $patron_mock->mock( 'article_request_fee', sub { return $amount; } );

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
    my $item   = $builder->build_sample_item;

    my $ar_module = mock_article_request_module();

    my $ar = $builder->build_object(
        {
            class => 'Koha::ArticleRequests',
            value => {
                borrowernumber => $patron->id,
                biblionumber   => $item->biblionumber,
                itemnumber     => $item->id,
            }
        }
    );

    $ar->request()->discard_changes;

    is( $ar->status, Koha::ArticleRequest::Status::Requested );
    is( $ar->itemnumber, $item->id, 'itemnumber set' );
    ok( defined $ar->debit_id, 'Fee linked' );
    is( $patron->account->balance, $amount, 'Outstanding fees with the right value' );

    my $payed_amount = 5;
    $patron->account->pay( { amount => $payed_amount, interface => 'intranet', lines => [ $ar->debit ] } );
    is( $patron->account->balance, $amount - $payed_amount, 'Outstanding fees with the right value' );

    my $reason = "Hey, ho";
    my $notes  = "Let's go!";

    $ar->cancel( { cancellation_reason => $reason, notes => $notes } )->discard_changes;

    is( $ar->status,              Koha::ArticleRequest::Status::Canceled );
    is( $ar->cancellation_reason, $reason, 'Cancellation reason stored correctly' );
    is( $ar->notes,               $notes,  'Notes stored correctly' );

    is( $patron->account->balance, -$payed_amount, 'The patron has a credit balance' );

    $schema->storage->txn_rollback;
};

subtest 'store' => sub {
    plan tests => 3;
    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'ArticleRequestsSupportedFormats', 'SCAN' );
    my $ar = $builder->build_object( { class => 'Koha::ArticleRequests', value => { format => 'PHOTOCOPY' } } );
    throws_ok { $ar->format('test')->store } 'Koha::Exceptions::ArticleRequest::WrongFormat',
        'Format not supported';
    is( $@->format, 'test', 'Passed format returned with the exception' );
    t::lib::Mocks::mock_preference( 'ArticleRequestsSupportedFormats', 'SCAN|PHOTOCOPY|ELSE' );
    lives_ok { $ar->format('PHOTOCOPY')->store } 'Now we do support it';

    $schema->storage->txn_rollback;
};

sub mock_article_request_module {
    my $ar_mock = Test::MockModule->new('Koha::ArticleRequest');
    $ar_mock->mock( 'notify', sub { ok( 1, '->notify() called' ); } );
    $ar_mock->mock(
        'format',
        sub {
            my $formats = C4::Context->multivalue_preference('ArticleRequestsSupportedFormats');
            return $formats->[ int( rand( scalar @$formats ) ) ];
        }
    );
    return $ar_mock;
}
