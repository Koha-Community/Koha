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

use POSIX qw(strftime);

use Test::More tests => 36;
use Test::MockModule;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Database;
use Koha::Biblio;
use Koha::Notice::Messages;
use Koha::Patron;
use Koha::Library::Group;
use Koha::CirculationRules;
use Koha::Caches;
use Koha::DateUtils qw( dt_from_string );
use Try::Tiny;

BEGIN {
    use_ok('Koha::ArticleRequest');
    use_ok('Koha::ArticleRequests');
    use_ok('Koha::ArticleRequest::Status');
}

my $schema = Koha::Database->new()->schema();
$schema->storage->txn_begin();
my $builder = t::lib::TestBuilder->new;
our $cache = Koha::Caches->get_instance;

my $dbh = C4::Context->dbh;

$dbh->do("DELETE FROM circulation_rules");

my $item = $builder->build_sample_item;
my $biblio = $item->biblio;

my $branch   = $builder->build({ source => 'Branch' });
my $category = $builder->build({ source => 'Category' });
my $patron   = $builder->build_object({
    class => 'Koha::Patrons',
    value => {
        categorycode => $category->{categorycode},
        branchcode   => $branch->{branchcode},
        flags        => 1,# superlibrarian
    },
});
ok( $patron->id, 'Koha::Patron created' );
my $patron_2 = $builder->build_object({ class => 'Koha::Patrons', value => { flags => 0 } });

# store
Koha::Notice::Messages->delete;
my $article_request_title = 'an article request title';
my $article_request = Koha::ArticleRequest->new(
    {
        borrowernumber => $patron->id,
        biblionumber   => $item->biblionumber,
        itemnumber     => $item->itemnumber,
        title          => $article_request_title,
    }
)->request();

my $notify_message = Koha::Notice::Messages->search->next;
is( $notify_message->letter_code, "AR_".Koha::ArticleRequest::Status::Requested);
# Default AR_PROCESSING template content "Title: <<article_requests.title>>"
like( $notify_message->content, qr{Title: $article_request_title}, 'Values from article_requests table must be fetched for the notification' );

$article_request = Koha::ArticleRequests->find( $article_request->id );
ok( $article_request->id, 'Koha::ArticleRequest created' );
is( $article_request->status, Koha::ArticleRequest::Status::Requested, 'New article request has status of Open' );
isnt( $article_request->created_on, undef, 'New article request has created_on date set' );
isnt( $article_request->updated_on, undef, 'New article request has updated_on date set' );

# process
Koha::Notice::Messages->delete;
$article_request->process();
$notify_message = Koha::Notice::Messages->search->next;
is( $notify_message->letter_code, "AR_".Koha::ArticleRequest::Status::Processing);
is( $article_request->status, Koha::ArticleRequest::Status::Processing, '$ar->process() changes status to Processing' );
isnt( $article_request->updated_on, undef, 'Updated article request has an updated_on date set' );

# complete
$article_request->complete();
is( $article_request->status, Koha::ArticleRequest::Status::Completed, '$ar->complete() changes status to Completed' );

# cancel
$article_request->cancel();
is( $article_request->status, Koha::ArticleRequest::Status::Canceled, '$ar->complete() changes status to Canceled' );
$article_request->set_pending();

is( $article_request->biblio->id,   $biblio->id, '$ar->biblio() gets corresponding Koha::Biblio object' );
is( $article_request->item->id,     $item->id,   '$ar->item() gets corresponding Koha::Item object' );
is( $article_request->borrower->id, $patron->id, '$ar->borrower() gets corresponding Koha::Patron object' );

my $rule = Koha::CirculationRules->set_rule(
    {
        categorycode => undef,
        itemtype     => undef,
        branchcode   => undef,
        rule_name    => 'article_requests',
        rule_value   => 'yes',
    }
);
ok( $biblio->can_article_request($patron), 'Record is requestable with rule type yes' );
is( $biblio->article_request_type($patron), 'yes', 'Biblio article request type is yes' );
ok( $item->can_article_request($patron),   'Item is requestable with rule type yes' );
is( $item->article_request_type($patron), 'yes', 'Item article request type is yes' );
$rule->delete();

$rule = Koha::CirculationRules->set_rule(
    {
        categorycode => undef,
        itemtype     => undef,
        branchcode   => undef,
        rule_name    => 'article_requests',
        rule_value   => 'bib_only',
    }
);
ok( $biblio->can_article_request($patron), 'Record is requestable with rule type bib_only' );
is( $biblio->article_request_type($patron), 'bib_only', 'Biblio article request type is bib_only' );
ok( !$item->can_article_request($patron),  'Item is not requestable with rule type bib_only' );
is( $item->article_request_type($patron), 'bib_only', 'Item article request type is bib_only' );
$rule->delete();

$rule = Koha::CirculationRules->set_rule(
    {
        categorycode => undef,
        itemtype     => undef,
        branchcode   => undef,
        rule_name    => 'article_requests',
        rule_value   => 'item_only',
    }
);
ok( $biblio->can_article_request($patron), 'Record is requestable with rule type item_only' );
is( $biblio->article_request_type($patron), 'item_only', 'Biblio article request type is item_only' );
ok( $item->can_article_request($patron),   'Item is not requestable with rule type item_only' );
is( $item->article_request_type($patron), 'item_only', 'Item article request type is item_only' );
$rule->delete();

$rule = Koha::CirculationRules->set_rule(
    {
        categorycode => undef,
        itemtype     => undef,
        branchcode   => undef,
        rule_name    => 'article_requests',
        rule_value   => 'no',
    }
);
ok( !$biblio->can_article_request($patron), 'Record is requestable with rule type no' );
is( $biblio->article_request_type($patron), 'no', 'Biblio article request type is no' );
ok( !$item->can_article_request($patron),   'Item is not requestable with rule type no' );
is( $item->article_request_type($patron), 'no', 'Item article request type is no' );
$rule->delete();

subtest 'search_limited' => sub {
    plan tests => 2;
    my $nb_article_requests = Koha::ArticleRequests->count;

    my $group_1 = Koha::Library::Group->new( { title => 'TEST Group 1', ft_hide_patron_info => 1 } )->store;
    my $group_2 = Koha::Library::Group->new( { title => 'TEST Group 2', ft_hide_patron_info => 1 } )->store;
    Koha::Library::Group->new({ parent_id => $group_1->id,  branchcode => $patron->branchcode })->store();
    Koha::Library::Group->new({ parent_id => $group_2->id,  branchcode => $patron_2->branchcode })->store();
    t::lib::Mocks::mock_userenv( { patron => $patron } ); # Is superlibrarian
    is( Koha::ArticleRequests->search_limited->count, $nb_article_requests, 'Koha::ArticleRequests->search_limited should return all article requests for superlibrarian' );
    t::lib::Mocks::mock_userenv( { patron => $patron_2 } ); # Is restricted
    is( Koha::ArticleRequests->search_limited->count, 0, 'Koha::ArticleRequests->search_limited should not return all article requests for restricted patron' );
};

subtest 'may_article_request' => sub {
    plan tests => 4;

    # mocking
    t::lib::Mocks::mock_preference('ArticleRequests', 1);
    t::lib::Mocks::mock_preference('ArticleRequestsLinkControl', 'calc');
    $cache->set_in_cache( Koha::CirculationRules::GUESSED_ITEMTYPES_KEY, {
        '*'  => { 'CR' => 1 },
        'S'  => { '*'  => 1 },
        'PT' => { 'BK' => 1 },
    });

    my $itemtype = Koha::ItemTypes->find('CR') // Koha::ItemType->new({ itemtype => 'CR' })->store;
    is( $itemtype->may_article_request, 1, 'SER/* should be true' );
    is( $itemtype->may_article_request({ categorycode => 'S' }), 1, 'SER/S should be true' );
    is( $itemtype->may_article_request({ categorycode => 'PT' }), '', 'SER/PT should be false' );
    t::lib::Mocks::mock_preference('ArticleRequestsLinkControl', 'always');
    is( $itemtype->may_article_request({ categorycode => 'PT' }), '1', 'Result should be true when LinkControl is set to always' );

    # Cleanup
    $cache->clear_from_cache( Koha::CirculationRules::GUESSED_ITEMTYPES_KEY );
};

$schema->storage->txn_rollback();
