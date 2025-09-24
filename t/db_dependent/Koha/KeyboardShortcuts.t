#!/usr/bin/perl

# Copyright 2019 Koha Development team
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use Test::NoWarnings;
use Test::More tests => 5;

use Koha::Database;

use t::lib::TestBuilder;

BEGIN {
    use_ok('Koha::KeyboardShortcuts');
}

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder         = t::lib::TestBuilder->new;
my $nb_of_shortcuts = Koha::KeyboardShortcuts->search->count;

my $shortcut_hash = {
    shortcut_name => 'this_cut',
    shortcut_keys => 'Ctrl-D',
};

my $new_shortcut = Koha::KeyboardShortcut->new($shortcut_hash)->store;
is( Koha::KeyboardShortcuts->count, $nb_of_shortcuts + 1, 'Adding a new shortcut increases count' );

my $found_shortcut = Koha::KeyboardShortcuts->find("this_cut");
is_deeply( $found_shortcut->unblessed, $shortcut_hash, 'We find the right object' );

$found_shortcut->delete;
is( Koha::KeyboardShortcuts->count, $nb_of_shortcuts, 'Deleting a new shortcut works' );

$schema->storage->txn_rollback;
