#!/usr/bin/perl
#
# This file is part of Koha.
#
# Copyright (C) 2014  Aleisha Amohia (Bug 11541)
# Copyright (C) 2016  Mark Tompsett (Bug 17234)
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

# This Koha test module is still a stub!
# Add more tests here!!!

use Modern::Perl;
use Test::More tests => 16;
use Koha::Database;

BEGIN {
    use_ok('C4::Installer');
}

ok( my $installer = C4::Installer->new(), 'Testing NewInstaller' );
is( ref $installer, 'C4::Installer', 'Testing class of object' );
is( $installer->{'dbname'}, C4::Context->config('database'), 'Testing DbName' );
is(
    $installer->{'dbms'},
    C4::Context->config('db_scheme')
    ? C4::Context->config('db_scheme')
    : 'mysql',
    'Testing DbScheme'
);
is(
    $installer->{'hostname'},
    C4::Context->config('hostname'),
    'Testing Hostname'
);
is( $installer->{'port'},     C4::Context->config('port'), 'Testing Port' );
is( $installer->{'user'},     C4::Context->config('user'), 'Testing User' );
is( $installer->{'password'}, C4::Context->config('pass'), 'Testing Password' );

# The borrower table is known to have columns and constraints.
my $schema = Koha::Database->new->schema;
my $source = $schema->source('Borrower');

my @column_names = $source->columns();
my $column_name  = $column_names[0];
ok( column_exists( 'borrowers', $column_name ), 'Known column does exist' );
ok( ! column_exists( 'borrowers', 'xxx'), 'Column xxx does not exist' );
{
    my $dbh = C4::Context->dbh;
    $dbh->{RaiseError} = 1;
    ok( ! column_exists( 'this_table_will_never_exist', 'xxx'), 'Column xxx does not exist, the table does not exist' );
}
my @constraint_names = $source->unique_constraint_names();
my $constraint_name  = $constraint_names[0];
ok( index_exists( 'borrowers', $constraint_name), 'Known contraint does exist' );
ok( ! index_exists( 'borrowers', 'xxx'), 'Constraint xxx does not exist' );

ok( foreign_key_exists( 'borrowers', 'borrowers_ibfk_1' ), 'FK borrowers_ibfk_1 exists' );
ok( ! foreign_key_exists( 'borrowers', 'xxx' ), 'FK xxxx does not exist' );
