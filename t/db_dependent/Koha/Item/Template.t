#!/usr/bin/perl

# Copyright 2022 Koha Development team
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

use Encode;
use JSON;

use Koha::Database;

use t::lib::TestBuilder;

use Test::More tests => 2;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

use_ok("Koha::Item::Template");

subtest 'Serializing and deserializing contents' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $data = {
        location => 'test',
        cost    => "2\x{20ac}",
    };

    my $template = Koha::Item::Template->new(
        {   name     => 'My template',
            contents => $data,
        }
    )->store();

    my $encoded_data;
    foreach my $key ( keys %{$data} ) {
        $encoded_data->{$key} = Encode::encode('UTF-8', $data->{$key});
    }

    is( $template->contents, JSON->new->utf8->encode($data), 'Contents serialized correctly' );

    is_deeply(
        $template->decoded_contents,
        $encoded_data,
        'Contents deserialized and UTF-8 encoded correctly'
    );

    $schema->storage->txn_rollback;
};
