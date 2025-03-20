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
use Test::NoWarnings;
use Test::More tests => 23;
use File::Temp qw(tempfile);
use utf8;

use Koha::Database;

BEGIN {
    use_ok(
        'C4::Installer',
        qw( column_exists index_exists unique_key_exists foreign_key_exists primary_key_exists marc_framework_sql_list )
    );
}

ok( my $installer = C4::Installer->new(), 'Testing NewInstaller' );
is( ref $installer,         'C4::Installer',                 'Testing class of object' );
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
ok( column_exists( 'borrowers',  $column_name ), 'Known column does exist' );
ok( !column_exists( 'borrowers', 'xxx' ),        'Column xxx does not exist' );
{
    ok( !column_exists( 'this_table_will_never_exist', 'xxx' ), 'Column xxx does not exist, the table does not exist' );
}
my @constraint_names = $source->unique_constraint_names();
my $constraint_name  = $constraint_names[0];
ok( index_exists( 'borrowers',  $constraint_name ), 'Known constraint does exist' );
ok( !index_exists( 'borrowers', 'xxx' ),            'Constraint xxx does not exist' );

ok( foreign_key_exists( 'borrowers',  'borrowers_ibfk_1' ), 'FK borrowers_ibfk_1 exists' );
ok( !foreign_key_exists( 'borrowers', 'xxx' ),              'FK xxxx does not exist' );

ok( unique_key_exists( 'items',      'itembarcodeidx' ), 'UNIQUE KEY itembarcodeidx exists' );
ok( !unique_key_exists( 'borrowers', 'xxx' ),            'UNIQUE KEY xxxx does not exist' );

ok( primary_key_exists('borrowers'), 'Borrowers does have a primary key on some column' );
ok( primary_key_exists( 'borrowers',  'borrowernumber' ), 'Borrowers has primary key on borrowernumber' );
ok( !primary_key_exists( 'borrowers', 'email' ),          'Borrowers does not have a primary key on email' );

subtest 'marc_framework_sql_list' => sub {
    plan tests => 1;

    my ( $fh, $filepath ) = tempfile(
        DIR    => C4::Context->config("intranetdir") . "/installer/data/mysql/en/marcflavour/marc21/mandatory",
        SUFFIX => '.yml', UNLINK => 1
    );
    print $fh Encode::encode_utf8("---\ndescription:\n    - \"Standardowe typy haseł przedmiotowych MARC21\"\n");
    close $fh;

    my $yaml_files = $installer->marc_framework_sql_list( 'en', 'MARC21' );

    my $description;
FILE: for my $file (@$yaml_files) {
        for my $framework ( @{ $file->{frameworks} } ) {
            if ( $framework->{fwkfile} eq $filepath ) {
                $description = $framework->{fwkdescription}->[0];
                last FILE;
            }
        }
    }
    is( $description, 'Standardowe typy haseł przedmiotowych MARC21' );
};
