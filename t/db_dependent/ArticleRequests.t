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

use Test::More tests => 55;

use t::lib::TestBuilder;

use Koha::Database;
use Koha::Biblio;
use Koha::Notice::Messages;
use Koha::Patron;

use t::lib::TestBuilder;

BEGIN {
    use_ok('Koha::ArticleRequest');
    use_ok('Koha::ArticleRequests');
    use_ok('Koha::ArticleRequest::Status');
}

my $schema = Koha::Database->new()->schema();
$schema->storage->txn_begin();
my $builder = t::lib::TestBuilder->new;

my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;

$dbh->do("DELETE FROM issuingrules");

my $biblio = Koha::Biblio->new()->store();
ok( $biblio->id, 'Koha::Biblio created' );

my $biblioitem = $schema->resultset('Biblioitem')->new(
    {
        biblionumber => $biblio->id
    }
)->insert();
ok( $biblioitem->id, 'biblioitem created' );

my $itype = $builder->build({ source => 'Itemtype' });
my $item = Koha::Item->new(
    {
        biblionumber     => $biblio->id,
        biblioitemnumber => $biblioitem->id,
        itype => $itype->{itemtype},
    }
)->store();
ok( $item->id, 'Koha::Item created' );

my $branch   = $builder->build({ source => 'Branch' });
my $category = $builder->build({ source => 'Category' });
my $patron   = Koha::Patron->new(
    {
        categorycode => $category->{categorycode},
        branchcode   => $branch->{branchcode},
        flags        => 1,# superlibrarian
    }
)->store();
ok( $patron->id, 'Koha::Patron created' );
my $patron_2 = $builder->build({ source => 'Borrower', value => { flags => 0 } });
$patron_2 = Koha::Patrons->find( $patron_2->{borrowernumber} );

my $nb_article_requests = Koha::ArticleRequests->count;

# store
Koha::Notice::Messages->delete;
my $article_request_title = 'an article request title';
my $article_request = Koha::ArticleRequest->new(
    {
        borrowernumber => $patron->id,
        biblionumber   => $biblio->id,
        itemnumber     => $item->id,
        title          => $article_request_title,
    }
)->store();

my $notify_message = Koha::Notice::Messages->search->next;
is( $notify_message->letter_code, "AR_".Koha::ArticleRequest::Status::Pending);
# Default AR_PROCESSING template content "Title: <<article_requests.title>>"
like( $notify_message->content, qr{Title: $article_request_title}, 'Values from article_requests table must be fetched for the notification' );

$article_request = Koha::ArticleRequests->find( $article_request->id );
ok( $article_request->id, 'Koha::ArticleRequest created' );
is( $article_request->status, Koha::ArticleRequest::Status::Pending, 'New article request has status of Open' );
is( $article_request->updated_on, undef, 'New article request has not an updated_on date set yet' );

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
$article_request->status(Koha::ArticleRequest::Status::Pending);
$article_request->store();

is( $article_request->biblio->id,   $biblio->id, '$ar->biblio() gets corresponding Koha::Biblio object' );
is( $article_request->item->id,     $item->id,   '$ar->item() gets corresponding Koha::Item object' );
is( $article_request->borrower->id, $patron->id, '$ar->borrower() gets corresponding Koha::Patron object' );

my $ar = $patron->article_requests();
is( ref($ar),      'Koha::ArticleRequests', '$patron->article_requests returns Koha::ArticleRequests object' );
is( $ar->next->id, $article_request->id,    'Returned article request matches' );

is( $patron->article_requests_current()->count(), 1, 'Open request returned for article_requests_current' );
$article_request->process();
is( $patron->article_requests_current()->count(), 1, 'Processing request returned for article_requests_current' );
$article_request->complete();
is( $patron->article_requests_current()->count(), 0, 'Completed request not returned for article_requests_current' );
$article_request->cancel();
is( $patron->article_requests_current()->count(), 0, 'Canceled request not returned for article_requests_current' );

$article_request->status(Koha::ArticleRequest::Status::Pending);
$article_request->store();

is( $patron->article_requests_finished()->count(), 0, 'Open request returned for article_requests_finished' );
$article_request->process();
is( $patron->article_requests_finished()->count(), 0, 'Processing request returned for article_requests_finished' );
$article_request->complete();
$article_request->cancel();
is( $patron->article_requests_finished()->count(), 1, 'Canceled request not returned for article_requests_finished' );

$article_request->status(Koha::ArticleRequest::Status::Pending);
$article_request->store();

$ar = $biblio->article_requests();
is( ref($ar),      'Koha::ArticleRequests', '$biblio->article_requests returns Koha::ArticleRequests object' );
is( $ar->next->id, $article_request->id,    'Returned article request matches' );

is( $biblio->article_requests_current()->count(), 1, 'Open request returned for article_requests_current' );
$article_request->process();
is( $biblio->article_requests_current()->count(), 1, 'Processing request returned for article_requests_current' );
$article_request->complete();
is( $biblio->article_requests_current()->count(), 0, 'Completed request not returned for article_requests_current' );
$article_request->cancel();
is( $biblio->article_requests_current()->count(), 0, 'Canceled request not returned for article_requests_current' );

$article_request->status(Koha::ArticleRequest::Status::Pending);
$article_request->store();

is( $biblio->article_requests_finished()->count(), 0, 'Open request returned for article_requests_finished' );
$article_request->process();
is( $biblio->article_requests_finished()->count(), 0, 'Processing request returned for article_requests_finished' );
$article_request->complete();
$article_request->cancel();
is( $biblio->article_requests_finished()->count(), 1, 'Canceled request not returned for article_requests_finished' );

my $rule;
$rule = $schema->resultset('Issuingrule')
  ->new( { categorycode => '*', itemtype => '*', branchcode => '*', article_requests => 'yes' } )->insert();
ok( $biblio->can_article_request($patron), 'Record is requestable with rule type yes' );
is( $biblio->article_request_type($patron), 'yes', 'Biblio article request type is yes' );
ok( $item->can_article_request($patron),   'Item is requestable with rule type yes' );
is( $item->article_request_type($patron), 'yes', 'Item article request type is yes' );
$rule->delete();

$rule = $schema->resultset('Issuingrule')
  ->new( { categorycode => '*', itemtype => '*', branchcode => '*', article_requests => 'bib_only' } )->insert();
ok( $biblio->can_article_request($patron), 'Record is requestable with rule type bib_only' );
is( $biblio->article_request_type($patron), 'bib_only', 'Biblio article request type is bib_only' );
ok( !$item->can_article_request($patron),  'Item is not requestable with rule type bib_only' );
is( $item->article_request_type($patron), 'bib_only', 'Item article request type is bib_only' );
$rule->delete();

$rule = $schema->resultset('Issuingrule')
  ->new( { categorycode => '*', itemtype => '*', branchcode => '*', article_requests => 'item_only' } )->insert();
ok( $biblio->can_article_request($patron), 'Record is requestable with rule type item_only' );
is( $biblio->article_request_type($patron), 'item_only', 'Biblio article request type is item_only' );
ok( $item->can_article_request($patron),   'Item is not requestable with rule type item_only' );
is( $item->article_request_type($patron), 'item_only', 'Item article request type is item_only' );
$rule->delete();

$rule = $schema->resultset('Issuingrule')
  ->new( { categorycode => '*', itemtype => '*', branchcode => '*', article_requests => 'no' } )->insert();
ok( !$biblio->can_article_request($patron), 'Record is requestable with rule type no' );
is( $biblio->article_request_type($patron), 'no', 'Biblio article request type is no' );
ok( !$item->can_article_request($patron),   'Item is not requestable with rule type no' );
is( $item->article_request_type($patron), 'no', 'Item article request type is no' );
$rule->delete();

subtest 'search_limited' => sub {
    plan tests => 4;
    C4::Context->_new_userenv('xxx');
    my $group_1 = Koha::Library::Group->new( { title => 'TEST Group 1' } )->store;
    my $group_2 = Koha::Library::Group->new( { title => 'TEST Group 2' } )->store;
    Koha::Library::Group->new({ parent_id => $group_1->id,  branchcode => $patron->branchcode })->store();
    Koha::Library::Group->new({ parent_id => $group_2->id,  branchcode => $patron_2->branchcode })->store();
    set_logged_in_user( $patron ); # Is superlibrarian
    is( Koha::ArticleRequests->count, $nb_article_requests + 1, 'Koha::ArticleRequests should return all article requests' );
    is( Koha::ArticleRequests->search_limited->count, $nb_article_requests + 1, 'Koha::ArticleRequests->search_limited should return all article requests for superlibrarian' );
    set_logged_in_user( $patron_2 ); # Is restricted
    is( Koha::ArticleRequests->count, $nb_article_requests + 1, 'Koha::ArticleRequests should return all article requests' );
    is( Koha::ArticleRequests->search_limited->count, $nb_article_requests, 'Koha::ArticleRequests->search_limited should not return all article requests for restricted patron' );
};

$schema->storage->txn_rollback();

sub set_logged_in_user {
    my ($patron) = @_;
    C4::Context->set_userenv(
        $patron->borrowernumber, $patron->userid,
        $patron->cardnumber,     'firstname',
        'surname',               $patron->library->branchcode,
        'Midway Public Library', $patron->flags,
        '',                      ''
    );
}
