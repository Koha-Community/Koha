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

use Koha::Authority;
use Koha::Authorities;
use Koha::Authority::Type;
use Koha::Authority::Types;
use Koha::Database;

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder               = t::lib::TestBuilder->new;
my $nb_of_authorities     = Koha::Authorities->search->count;
my $nb_of_authority_types = Koha::Authority::Types->search->count;
my $new_authority_type_1  = Koha::Authority::Type->new(
    {   authtypecode       => 'my_ac_1',
        authtypetext       => 'my authority type text 1',
        auth_tag_to_report => '100',
        summary            => 'my summary for authority 1',
    }
)->store;
my $new_authority_1 = Koha::Authority->new( { authtypecode => $new_authority_type_1->authtypecode, } )->store;
my $new_authority_2 = Koha::Authority->new( { authtypecode => $new_authority_type_1->authtypecode, } )->store;

is( Koha::Authority::Types->search->count, $nb_of_authority_types + 1, 'The authority type should have been added' );
is( Koha::Authorities->search->count,      $nb_of_authorities + 2,     'The 2 authorities should have been added' );

$new_authority_1->delete;
is( Koha::Authorities->search->count, $nb_of_authorities + 1, 'Delete should have deleted the library' );

$schema->storage->txn_rollback;
1;
