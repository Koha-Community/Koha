#!/usr/bin/perl

# Copyright 2020 Koha Development team
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

use Koha::Import::Record::Auths;
use Koha::Database;

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;
my $nb_of_record_auths = Koha::Import::Record::Auths->search->count;

my $record_auth_1 = $builder->build({ source => 'ImportAuth' });
my $record_auth_2 = $builder->build({ source => 'ImportAuth' });

is( Koha::Import::Record::Auths->search->count, $nb_of_record_auths + 2, 'The 2 record auths should have been added' );

my $retrieved_record_auth_1 = Koha::Import::Record::Auths->search({ import_record_id => $record_auth_1->{import_record_id}})->next;
is_deeply( $retrieved_record_auth_1->unblessed, $record_auth_1, 'Find a record auth by import record id should return the correct record auth' );

$retrieved_record_auth_1->delete;
is( Koha::Import::Record::Auths->search->count, $nb_of_record_auths + 1, 'Delete should have deleted the record auth' );

$schema->storage->txn_rollback;
