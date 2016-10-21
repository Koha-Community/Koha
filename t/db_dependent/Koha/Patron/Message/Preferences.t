#!/usr/bin/perl

# Copyright 2017 Koha-Suomi Oy
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

use Test::More tests => 2;

use t::lib::Mocks;
use t::lib::TestBuilder;

use Koha::Notice::Templates;
use Koha::Patron::Categories;
use Koha::Patron::Message::Attributes;
use Koha::Patron::Message::Transport::Types;
use Koha::Patron::Message::Transports;
use Koha::Patrons;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'Test class imports' => sub {
    plan tests => 2;

    use_ok('Koha::Patron::Message::Preference');
    use_ok('Koha::Patron::Message::Preferences');
};

subtest 'Test Koha::Patron::Message::Preferences' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $attribute = build_a_test_attribute();

    subtest 'Test for a patron' => sub {
        plan tests => 2;

        my $patron = build_a_test_patron();
        Koha::Patron::Message::Preference->new({
            borrowernumber       => $patron->borrowernumber,
            message_attribute_id => $attribute->message_attribute_id,
            wants_digest         => 0,
            days_in_advance      => undef,
        })->store;

        my $preference = Koha::Patron::Message::Preferences->find({
            borrowernumber       => $patron->borrowernumber,
            message_attribute_id => $attribute->message_attribute_id
        });
        ok($preference->borrower_message_preference_id > 0,
           'Added a new messaging preference for patron.');

        $preference->delete;
        is(Koha::Patron::Message::Preferences->search({
            borrowernumber       => $patron->borrowernumber,
            message_attribute_id => $attribute->message_attribute_id
        })->count, 0, 'Deleted the messaging preference.');
    };

    subtest 'Test for a category' => sub {
        my $category = build_a_test_category();
        Koha::Patron::Message::Preference->new({
            categorycode         => $category->categorycode,
            message_attribute_id => $attribute->message_attribute_id,
            wants_digest         => 0,
            days_in_advance      => undef,
        })->store;

        my $preference = Koha::Patron::Message::Preferences->find({
            categorycode         => $category->categorycode,
            message_attribute_id => $attribute->message_attribute_id
        });
        ok($preference->borrower_message_preference_id > 0,
           'Added a new messaging preference for category.');

        $preference->delete;
        is(Koha::Patron::Message::Preferences->search({
            categorycode         => $category->categorycode,
            message_attribute_id => $attribute->message_attribute_id
        })->count, 0, 'Deleted the messaging preference.');
    };

    $schema->storage->txn_rollback;
};

sub build_a_test_attribute {
    my ($params) = @_;

    $params->{takes_days} = $params->{takes_days} && $params->{takes_days} > 0
                            ? 1 : 0;

    my $attribute = $builder->build({
        source => 'MessageAttribute',
        value => $params,
    });

    return Koha::Patron::Message::Attributes->find(
        $attribute->{message_attribute_id}
    );
}

sub build_a_test_category {
    my $categorycode   = $builder->build({
        source => 'Category' })->{categorycode};

    return Koha::Patron::Categories->find($categorycode);
}

sub build_a_test_patron {
    my $categorycode   = $builder->build({
        source => 'Category' })->{categorycode};
    my $branchcode     = $builder->build({
        source => 'Branch' })->{branchcode};
    my $borrowernumber = $builder->build({
        source => 'Borrower' })->{borrowernumber};

    return Koha::Patrons->find($borrowernumber);
}

1;
