#!/usr/bin/perl

use Modern::Perl;
use Test::NoWarnings;
use Test::More tests => 2;

use t::lib::Mocks;
use t::lib::TestBuilder;
use Koha::Database;
use Koha::CirculationRules;
use Koha::Caches;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;
our $builder = t::lib::TestBuilder->new;
our $cache   = Koha::Caches->get_instance;

subtest 'guess_article_requestable_itemtypes' => sub {
    plan tests => 13;

    t::lib::Mocks::mock_preference( 'ArticleRequests',            1 );
    t::lib::Mocks::mock_preference( 'ArticleRequestsLinkControl', 'calc' );
    $cache->clear_from_cache(Koha::CirculationRules::GUESSED_ITEMTYPES_KEY);
    Koha::CirculationRules->delete;
    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $itype1  = $builder->build_object( { class => 'Koha::ItemTypes' } );
    my $itype2  = $builder->build_object( { class => 'Koha::ItemTypes' } );
    my $catg1   = $builder->build_object( { class => 'Koha::Patron::Categories' } );
    my $catg2   = $builder->build_object( { class => 'Koha::Patron::Categories' } );
    my $rule1   = Koha::CirculationRules->set_rule(
        {
            branchcode   => $library->branchcode,
            categorycode => undef,
            itemtype     => $itype1->itemtype,
            rule_name    => 'article_requests',
            rule_value   => 'bib_only',
        },
    );
    my $rule2 = Koha::CirculationRules->set_rule(
        {
            branchcode   => undef,
            categorycode => $catg1->categorycode,
            itemtype     => $itype2->itemtype,
            rule_name    => 'article_requests',
            rule_value   => 'yes',
        },
    );

    my $res = Koha::CirculationRules->guess_article_requestable_itemtypes;
    is( $res->{'*'},                 undef, 'Item type * seems not permitted' );
    is( $res->{ $itype1->itemtype }, 1,     'Item type 1 seems permitted' );
    is( $res->{ $itype2->itemtype }, 1,     'Item type 2 seems permitted' );
    $res = Koha::CirculationRules->guess_article_requestable_itemtypes( { categorycode => $catg2->categorycode } );
    is( $res->{'*'},                 undef, 'Item type * seems not permitted' );
    is( $res->{ $itype1->itemtype }, 1,     'Item type 1 seems permitted' );
    is( $res->{ $itype2->itemtype }, undef, 'Item type 2 seems not permitted' );

    # Change the rules
    $rule2->itemtype(undef)->store;
    $cache->clear_from_cache(Koha::CirculationRules::GUESSED_ITEMTYPES_KEY);
    $res = Koha::CirculationRules->guess_article_requestable_itemtypes;
    is( $res->{'*'},                 1,     'Item type * seems permitted' );
    is( $res->{ $itype1->itemtype }, 1,     'Item type 1 seems permitted' );
    is( $res->{ $itype2->itemtype }, undef, 'Item type 2 seems not permitted' );
    $res = Koha::CirculationRules->guess_article_requestable_itemtypes( { categorycode => $catg2->categorycode } );
    is( $res->{'*'},                 undef, 'Item type * seems not permitted' );
    is( $res->{ $itype1->itemtype }, 1,     'Item type 1 seems permitted' );
    is( $res->{ $itype2->itemtype }, undef, 'Item type 2 seems not permitted' );

    # Finally test the overriding pref
    t::lib::Mocks::mock_preference( 'ArticleRequestsLinkControl', 'always' );
    $res = Koha::CirculationRules->guess_article_requestable_itemtypes( {} );
    is( $res->{'*'}, 1, 'Override algorithm with pref setting' );

    $cache->clear_from_cache(Koha::CirculationRules::GUESSED_ITEMTYPES_KEY);
};

$schema->storage->txn_rollback;
