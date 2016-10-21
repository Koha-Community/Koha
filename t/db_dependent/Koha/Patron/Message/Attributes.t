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

use Koha::Database;

my $schema  = Koha::Database->new->schema;

subtest 'Test class imports' => sub {
    plan tests => 2;

    use_ok('Koha::Patron::Message::Attribute');
    use_ok('Koha::Patron::Message::Attributes');
};

subtest 'Test Koha::Patron::Message::Attributes' => sub {
    plan tests => 6;

    $schema->storage->txn_begin;

    Koha::Patron::Message::Attribute->new({
        message_name => 'Test_Attribute'
    })->store;
    Koha::Patron::Message::Attribute->new({
        message_name => 'Test_Attribute2',
        takes_days   => 1
    })->store;

    my $attribute  = Koha::Patron::Message::Attributes->find({
        message_name => 'Test_Attribute' });
    my $attribute2 = Koha::Patron::Message::Attributes->find({
        message_name => 'Test_Attribute2' });

    is($attribute->message_name, 'Test_Attribute',
       'Added a new messaging attribute.');
    is($attribute->takes_days, 0,
       'For that messaging attribute, takes_days is disabled by default.');
    is($attribute2->message_name, 'Test_Attribute2',
       'Added another messaging attribute.');
    is($attribute2->takes_days, 1,
       'takes_days is enabled for that message attribute (as expected).');

    $attribute->delete;
    $attribute2->delete;
    is(Koha::Patron::Message::Attributes->find({
        message_name => 'Test_Attribute' }), undef,
       'Deleted the first message attribute.');
    is(Koha::Patron::Message::Attributes->find({
        message_name => 'Test_Attribute2' }), undef,
       'Deleted the second message attribute.');

    $schema->storage->txn_rollback;
};

1;
