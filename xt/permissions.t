#!/usr/bin/perl 

# Copyright (C) 2010 Tamil s.a.r.l.
#
# This file is part of Koha.
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

use strict;
use warnings;

use Test::More qw(no_plan);

use C4::Context;

my $root_dir = 'installer/data/mysql';
my $base_perms_file = "en/mandatory/userpermissions.sql";
my @trans_perms_files = qw(
    de-DE/mandatory/userpermissions.sql
    it-IT/necessari/userpermissions.sql
    fr-FR/1-Obligatoire/userpermissions.sql
    uk-UA/mandatory/permissions_and_user_flags.sql
    ru-RU/mandatory/permissions_and_user_flags.sql
    pl-PL/mandatory/userpermissions.sql
    nb-NO/1-Obligatorisk/userpermissions.sql
    es-ES/mandatory/userpermissions.sql
);

ok(
    open( my $ref_fh, "<$root_dir/$base_perms_file" ),
    "Open reference user permissions file $root_dir/$base_perms_file" );
my $ref_perm = get_perms_from_file( $ref_fh );
my @ref_perms = sort { lc $a cmp lc $b } keys %$ref_perm;
cmp_ok(
    $#ref_perms, '>=', 0,
    "Found " . ($#ref_perms + 1) . " user permissions" );

foreach my $file_name ( @trans_perms_files ) {
    compare_perms( $file_name );
}


#
# Get user permissions from SQL file populating permissions table with INSERT
# statement.
#
# Exemple:
#  INSERT INTO permissions (module_bit, code, description) VALUES
#  ( 1, 'override_renewals', 'Override blocked renewals'),
#
sub get_perms_from_file {
    my $fh = shift;
    my %perm;
    my $found_insert = 0;
    while ( <$fh> ) {
        next if /^--/; # Comment line
        $found_insert = 1 if /insert\s+into/i and /permissions/i;
        next unless $found_insert;
        #/VALUES.*\(\'([\w\-:]+)\'/;
        /,\s*\'(.*?)\'/;
        my $variable = $1;
        next unless $variable;
        $perm{$variable} = 1;
    }
    return \%perm;
}


sub compare_perms {
    my $trans_file = shift;
    ok(
       open( my $trans_fh, "<$root_dir/$trans_file" ),
       "Open translated user permissions file $root_dir/$trans_file" );
    my $trans_perm = get_perms_from_file( $trans_fh );
    my @trans_perms = sort { lc $a cmp lc $b } keys %$trans_perm;
    cmp_ok(
        $#trans_perms, '>=', 0,
        "Found " . ($#trans_perms + 1) . " perms" );

    my @to_add_perms;
    foreach ( @ref_perms ) {
       push @to_add_perms, $_ if ! $trans_perm->{$_};
    }
    if ( $#to_add_perms >= 0 ) {
        fail( 'No user permissions to add') or diag( "User permissions to add in $trans_file: " . join(', ', @to_add_perms ) );
    }
    else {
        pass( 'No user permissions to add' );
    }

    my @to_delete_perms;
    foreach ( @trans_perms ) {
       push @to_delete_perms, $_ if ! $ref_perm->{$_};
    }
    if ( $#to_delete_perms >= 0 ) {
        fail( 'No user permissions to delete' );
        diag( "User permissions to delete in $trans_file: " . join(', ', @to_delete_perms ) );
        diag( 'Warning: Some of those user permissions may rather have to be added to English permissions' );
    }
    else {
        pass( 'No user permissions to delete' );
    }
}


=head1 NAME

permissions.t

=head1 DESCRIPTION

This test identifies incoherences between translated user permissions files and
the 'en' reference file.

Koha user permissions are loaded to 'permissions' table from a text SQL file
during Koha installation by web installer. The reference file is the one
provided for English (en) installation :

  <koha_root>/installer/data/mysql/en/mandatory/userpermissions.sql

Alternatives files are provided for other languages. Those files
are difficult to keep syncrhonized with reference file.

=head1 USAGE

 prove -v permissions.t
 prove permissions.t

=cut

