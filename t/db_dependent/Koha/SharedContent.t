#!/usr/bin/perl

# Copyright 2016 BibLibre Morgane Alonso
#
# This file is part of Koha
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

use t::lib::TestBuilder;
use t::lib::Mocks;
use Test::MockModule;
use Test::MockObject;
use Test::NoWarnings;
use Test::More tests => 46;
use Koha::Database;
use Koha::Patrons;
use Koha::Subscriptions;

use HTTP::Status qw(:constants :is status_message);

use_ok('Koha::SharedContent');

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new();

my $want_error   = 0;
my $post_request = 0;
my $query        = {};

t::lib::Mocks::mock_config( 'mana_config', 'https://foo.bar' );

is( Koha::SharedContent::get_sharing_url(), 'https://foo.bar', 'Mana URL' );

my $result = Koha::SharedContent::search_entities( 'report', $query );
ok( $result->{msg} =~ /Can\'t connect to foo.bar:443/, 'Unable to connect' );
is( $result->{code}, 500, 'Code is 500' );

my $ua = Test::MockModule->new('LWP::UserAgent');
$ua->mock(
    'simple_request',
    sub {
        return mock_response();
    }
);

$want_error = 1;
$query      = { query => 'foo', usecomments => 1 };
$result     = Koha::SharedContent::search_entities( 'report', $query );
ok( $result->{msg} =~ /^Error thrown by decoded_content/, 'Error in decoded_content' );
is( $result->{code}, 500, 'Code is 500' );

$want_error = 0;
$query      = { title => 'foo', usecomments => 1 };
$result     = Koha::SharedContent::search_entities( 'subscription', $query );
is( $result->{code}, 200, 'search_entities success' );

$result = Koha::SharedContent::get_entity_by_id( 'subscription', 23 );
is( $result->{code}, 200, 'get_entity_by_id success' );

my $params = {
    title         => 'The English historical review',
    issn          => '0013-8266',
    ean           => '',
    publishercode => 'Longman'
};

# Search a subscription.
my $request = Koha::SharedContent::build_request( 'get', 'subscription', $params );
is( $request->method, 'GET', 'Get subscription - Method is get' );

my %query = $request->uri->query_form;
is( $query{title},         'The English historical review', 'Check title' );
is( $query{issn},          '0013-8266',                     'Check issn' );
is( $query{ean},           undef,                           'Check ean' );
is( $query{publishercode}, 'Longman',                       'Check publisher' );

is( $request->uri->path, '/subscription.json', 'Path is subscription' );

# Get a report by id.
$request = Koha::SharedContent::build_request( 'getwithid', 'report', 26 );
is( $request->method, 'GET', 'Get with id - Method is get' );

is( $request->uri->path, '/report/26.json', 'Path is report/26.json' );

# Share a report.
my $content = {
    'kohaversion'  => '17.06.00.008',
    'language'     => 'fr-FR',
    'notes'        => 'some notes',
    'report_group' => '',
    'exportemail'  => 'xx@xx.com',
    'report_name'  => 'A useless report',
    'savedsql'     => 'SELECT * FROM ITEMS',
    'type'         => undef
};

$request = Koha::SharedContent::build_request( 'post', 'report', $content );
is( $request->method, 'POST', 'Share report - Method is post' );

is( $request->uri->path, '/report.json', 'Path is report.json' );

# prepare shared data
my $library = $builder->build_object(
    {
        class => 'Koha::Libraries',
    }
);

my $loggedinuser = $builder->build_object(
    {
        class => 'Koha::Patrons',
        value => {
            email      => '',
            emailpro   => '',
            B_email    => '',
            branchcode => $library->branchcode,
        }
    }
);

my $biblio = $builder->build_sample_biblio;

my $subscriptionFrequency = $builder->build( { source => 'SubscriptionFrequency' } );

my $subscriptionNumberpattern = $builder->build( { source => 'SubscriptionNumberpattern' } );

my $subscription = $builder->build(
    {
        source => 'Subscription',
        value  => {
            biblionumber  => $biblio->biblionumber,
            periodicity   => $subscriptionFrequency->{id},
            numberpattern => $subscriptionNumberpattern->{id},
            mana_id       => undef
        }
    }
);

t::lib::Mocks::mock_userenv( { patron => $loggedinuser } );

t::lib::Mocks::mock_preference( 'language', 'en' );

$post_request = 1;
$result       = Koha::SharedContent::send_entity(
    'en', $loggedinuser->borrowernumber, $subscription->{subscriptionid},
    'subscription'
);
is( $result->{code}, 200, 'send_entity success' );

my $s = Koha::Subscriptions->find( $subscription->{subscriptionid} );
is( $s->mana_id, 5, 'Mana id is set' );

$content = { resource_id => $subscription->{mana_id}, resource_type => 'subscription', message => 'My comment' };
$result  = Koha::SharedContent::comment_entity( 'resource_comment', $content );
is( $result->{code}, 200, 'Comment success' );

my $data = Koha::SharedContent::prepare_entity_data(
    '',
    $loggedinuser->borrowernumber,
    $subscription->{subscriptionid},
    'subscription'
);

is( $data->{language},      'en',                                    'Language is set to default' );
is( $data->{exportemail},   $library->branchemail,                   'Email is set with the userenv branch one' );
is( $data->{title},         $biblio->title,                          'Shared title' );
is( $data->{sfdescription}, $subscriptionFrequency->{description},   'Shared sfdescription' );
is( $data->{unit},          $subscriptionFrequency->{unit},          'Shared unit' );
is( $data->{unitsperissue}, $subscriptionFrequency->{unitsperissue}, 'Shared unitsperissue' );
is( $data->{issuesperunit}, $subscriptionFrequency->{issuesperunit}, 'Shared issuesperunit' );

is( $data->{label},           $subscriptionNumberpattern->{label},           'Shared np label' );
is( $data->{sndescription},   $subscriptionNumberpattern->{description},     'Shared np description' );
is( $data->{numberingmethod}, $subscriptionNumberpattern->{numberingmethod}, 'Shared numberingmethod' );
is( $data->{label1},          $subscriptionNumberpattern->{label1},          'Shared label1' );
is( $data->{add1},            $subscriptionNumberpattern->{add1},            'Shared add1' );
is( $data->{every1},          $subscriptionNumberpattern->{every1},          'Shared every1' );
is( $data->{whenmorethan1},   $subscriptionNumberpattern->{whenmorethan1},   'Shared whenmorethan1' );
is( $data->{setto1},          $subscriptionNumberpattern->{setto1},          'Shared setto1' );
is( $data->{numbering1},      $subscriptionNumberpattern->{numbering1},      'Shared numbering1' );
my $biblioitem = $biblio->biblioitem;
is( $data->{issn},          $biblioitem->issn,          'Shared ISSN' );
is( $data->{ean},           $biblioitem->ean,           'Shared EAN' );
is( $data->{publishercode}, $biblioitem->publishercode, 'Shared publishercode' );

sub mock_response {
    my $response = Test::MockObject->new();

    if ($want_error) {
        $response->mock(
            'code',
            sub {
                return 500;
            }
        );
        $response->mock(
            'is_error',
            sub {
                return 0;
            }
        );
        $response->mock(
            'decoded_content',
            sub {
                die 'Error thrown by decoded_content';
            }
        );
    } elsif ($post_request) {
        $response->mock(
            'code',
            sub {
                return 200;
            }
        );
        $response->mock(
            'is_error',
            sub {
                return 0;
            }
        );
        $response->mock(
            'decoded_content',
            sub {
                return '{"code": "200", "msg": "foo", "id": "5"}';
            }
        );
    } else {
        $response->mock(
            'code',
            sub {
                return 200;
            }
        );
        $response->mock(
            'is_error',
            sub {
                return 0;
            }
        );
        $response->mock(
            'decoded_content',
            sub {
                return '';
            }
        );
    }
}

# Increment request.
$request = Koha::SharedContent::build_request(
    'increment',
    'subscription',
    12,
    'foo'
);

is( $request->method, 'POST', 'Increment subscription - Method is post' );

%query = $request->uri->query_form;
is( $query{id},       12,             'Check id' );
is( $query{step},     1,              'Step is default' );
is( $query{resource}, 'subscription', 'Check ressource' );

is( $request->uri->path, '/subscription/12.json/increment/foo', 'Path is subscription' );

$schema->storage->txn_rollback;
