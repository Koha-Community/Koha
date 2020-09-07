#!/usr/bin/perl

# Copyright 2015 Koha Development team
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
use Test::More tests => 3;
use Koha::BiblioFramework;
use Koha::BiblioFrameworks;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $nb_of_frameworks = Koha::BiblioFrameworks->search->count;
my $new_framework_1 = Koha::BiblioFramework->new({
    frameworkcode => 'mfw1',
    frameworktext => 'my_frameworktext_for_fw_1',
})->store;
my $new_framework_2 = Koha::BiblioFramework->new({
    frameworkcode => 'mfw2',
    frameworktext => 'my_frameworktext_for_fw_2',
})->store;

is( Koha::BiblioFrameworks->search->count, $nb_of_frameworks + 2, 'The 2 biblio frameworks should have been added' );

my $retrieved_framework_1 = Koha::BiblioFrameworks->find( $new_framework_1->frameworkcode );
is( $retrieved_framework_1->frameworktext, $new_framework_1->frameworktext, 'Find a biblio framework by frameworkcode should return the correct framework' );

$retrieved_framework_1->delete;
is( Koha::BiblioFrameworks->search->count, $nb_of_frameworks + 1, 'Delete should have deleted the biblio framework' );
$schema->storage->txn_rollback;
