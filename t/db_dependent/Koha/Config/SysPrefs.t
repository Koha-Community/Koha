# This file is part of Koha.
#
# Copyright 2018 Koha Development Team
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
use Test::More tests => 3;

use t::lib::Mocks;
use t::lib::TestBuilder;
use Koha::Config::SysPrefs;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;

my $nb_of_prefs = Koha::Config::SysPrefs->search->count;
my $new_pref = Koha::Config::SysPref->new({
    variable => 'ShouldNotBeDone',
    value    => 'but a good test?',
    options  => undef,
    explanation => 'just for CRUD sake',
    type     => 'Free'
})->store;

is( Koha::Config::SysPrefs->search->count, $nb_of_prefs + 1, 'The 1 pref should have been added' );
my $retrieved_pref = Koha::Config::SysPrefs->find('ShouldNotBeDone');
is( $retrieved_pref->value, $new_pref->value, 'Find a pref by variable should return the correct pref' );

$retrieved_pref->delete;
is( Koha::Config::SysPrefs->search->count, $nb_of_prefs, 'Delete should have deleted the pref' );

$schema->storage->txn_rollback;
