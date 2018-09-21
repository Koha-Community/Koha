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
use Test::More tests => 4;

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

subtest 'get_yaml_pref_hash' => sub {

    plan tests => 1;

    my $the_pref = Koha::Config::SysPrefs->find({variable=>'ItemsDeniedRenewal'});
    $the_pref->value(q{
        nulled: [NULL,'']
        this: [just_that]
        multi_this: [that,another]
    });

    my $expected_hash = {
        nulled => [undef,""],
        this     => ['just_that'],
        multi_this => ['that','another'],
    };
    my $got_hash = $the_pref->get_yaml_pref_hash();
    is_deeply($got_hash,$expected_hash,"Pref fetched and converted correctly");

};

$schema->storage->txn_rollback;
