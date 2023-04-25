#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 2;
use Test::MockModule;

use t::lib::TestBuilder;
use t::lib::Mocks;

BEGIN {
    use_ok('Koha::Template::Plugin::Frameworks');
}

my $schema  = Koha::Database->schema;
my $builder = t::lib::TestBuilder->new;

$schema->storage->txn_begin;

subtest 'GetName tests' => sub {
    plan tests => 3;

    my $framework = $builder->build_object({ class => 'Koha::BiblioFrameworks' })->store;

    my $plugin = Koha::Template::Plugin::Frameworks->new();

    my $name = $plugin->GetName( $framework->frameworkcode );
    is( $name, $framework->frameworktext, "Name correctly fetched" );

    $name = $plugin->GetName();
    is( $name, q{}, "Nothing returned if nothing passed" );

    $framework->delete;
    $name = $plugin->GetName( $framework->frameworkcode );
    is( $name, $framework->frameworkcode, "When framework not found, we get the code back" );
};

$schema->storage->txn_rollback;
