#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 1;

use t::lib::Mocks;
use t::lib::TestBuilder;
use Koha::Database;
use Koha::IssuingRules;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;
our $builder = t::lib::TestBuilder->new;

subtest 'guess_article_requestable_itemtypes' => sub {
    plan tests => 12;

    t::lib::Mocks::mock_preference('ArticleRequests', 1);
    Koha::IssuingRules->delete;
    my $itype1 = $builder->build_object({ class => 'Koha::ItemTypes' });
    my $itype2 = $builder->build_object({ class => 'Koha::ItemTypes' });
    my $catg1 = $builder->build_object({ class => 'Koha::Patron::Categories' });
    my $catg2 = $builder->build_object({ class => 'Koha::Patron::Categories' });
    my $rule1 = $builder->build_object({
        class => 'Koha::IssuingRules',
        value => {
            branchcode => 'MPL', # no worries: no FK
            categorycode => '*',
            itemtype => $itype1->itemtype,
            article_requests => 'bib_only',
        },
    });
    my $rule2 = $builder->build_object({
        class => 'Koha::IssuingRules',
        value => {
            branchcode => '*',
            categorycode => $catg1->categorycode,
            itemtype => $itype2->itemtype,
            article_requests => 'yes',
        },
    });

    my $res = Koha::IssuingRules->guess_article_requestable_itemtypes;
    is( $res->{'*'}, undef, 'Item type * seems not permitted' );
    is( $res->{$itype1->itemtype}, 1, 'Item type 1 seems permitted' );
    is( $res->{$itype2->itemtype}, 1, 'Item type 2 seems permitted' );
    $res = Koha::IssuingRules->guess_article_requestable_itemtypes({ categorycode => $catg2->categorycode });
    is( $res->{'*'}, undef, 'Item type * seems not permitted' );
    is( $res->{$itype1->itemtype}, 1, 'Item type 1 seems permitted' );
    is( $res->{$itype2->itemtype}, undef, 'Item type 2 seems not permitted' );

    # Change the rules
    $rule2->itemtype('*')->store;
    $Koha::IssuingRules::last_article_requestable_guesses = {};
    $res = Koha::IssuingRules->guess_article_requestable_itemtypes;
    is( $res->{'*'}, 1, 'Item type * seems permitted' );
    is( $res->{$itype1->itemtype}, 1, 'Item type 1 seems permitted' );
    is( $res->{$itype2->itemtype}, undef, 'Item type 2 seems not permitted' );
    $res = Koha::IssuingRules->guess_article_requestable_itemtypes({ categorycode => $catg2->categorycode });
    is( $res->{'*'}, undef, 'Item type * seems not permitted' );
    is( $res->{$itype1->itemtype}, 1, 'Item type 1 seems permitted' );
    is( $res->{$itype2->itemtype}, undef, 'Item type 2 seems not permitted' );

    $Koha::IssuingRules::last_article_requestable_guesses = {};
};

$schema->storage->txn_rollback;
