#!/usr/bin/perl 

# Copyright (C) 2009 Tamil s.a.r.l.
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;
use warnings;

use Test::More qw(no_plan);

use C4::Context;

my $root_dir = C4::Context->config( 'intranetdir' ) . '/installer/data/mysql';
my $base_syspref_file = "en/mandatory/sysprefs.sql";
my @trans_syspref_files = qw(
    fr-FR/1-Obligatoire/unimarc_standard_systemprefs.sql
    uk-UA/mandatory/system_preferences_optimal.sql
    ru-RU/mandatory/system_preferences_optimal.sql
);

ok(
    open( my $ref_fh, "<$root_dir/$base_syspref_file" ),
    "Open reference syspref file $root_dir/$base_syspref_file" );
my $ref_syspref = get_syspref_from_file( $ref_fh );
my @ref_sysprefs = sort { lc $a cmp lc $b } keys %$ref_syspref;
cmp_ok(
    $#ref_sysprefs, '>=', 0,
    "Found " . ($#ref_sysprefs + 1) . " sysprefs" );

foreach my $file_name ( @trans_syspref_files ) {
    compare_syspref( $file_name );
}


#
# Get sysprefs from SQL file populating sysprefs table with INSERT statement.
#
# Exemple:
# INSERT INTO `systempreferences` (variable,value,explanation,options,type) 
# VALUES('AmazonLocale','US','Use to set the Locale of your Amazon.com Web Services',
# 'US|CA|DE|FR|JP|UK','Choice')
#
sub get_syspref_from_file {
    my $fh = shift;
    my %syspref;
    while ( <$fh> ) {
        next if /^--/; # Comment line
        #/VALUES.*\(\'([\w\-:]+)\'/;
        /\(\'([\w\-:]+)\'/;
        my $variable = $1;
        next unless $variable;
        $syspref{$variable} = 1;
    }
    return \%syspref;
}


sub compare_syspref {
    my $trans_file = shift;
    ok(
       open( my $trans_fh, "<$root_dir/$trans_file" ),
       "Open translated sysprefs file $root_dir/$trans_file" );
    my $trans_syspref = get_syspref_from_file( $trans_fh );
    my @trans_sysprefs = sort { lc $a cmp lc $b } keys %$trans_syspref;
    cmp_ok(
        $#trans_sysprefs, '>=', 0,
        "Found " . ($#trans_sysprefs + 1) . " sysprefs" );

    my @to_add_sysprefs;
    foreach ( @ref_sysprefs ) {
       push @to_add_sysprefs, $_ if ! $trans_syspref->{$_};
    }
    if ( $#to_add_sysprefs >= 0 ) {
        fail( 'No syspref to add') or diag( "Sysprefs to add in $trans_file: " . join(', ', @to_add_sysprefs ) );
    }
    else {
        pass( 'No syspref to add' );
    }

    my @to_delete_sysprefs;
    foreach ( @trans_sysprefs ) {
       push @to_delete_sysprefs, $_ if ! $ref_syspref->{$_};
    }
    if ( $#to_delete_sysprefs >= 0 ) {
        fail( 'No syspref to delete' );
        diag( "Sysprefs to delete in $trans_file: " . join(', ', @to_delete_sysprefs ) );
        diag( 'Warning: Some of those sysprefs may rather have to be added to English sysprefs' );
    }
    else {
        pass( 'No syspref to delete' );
    }
}


=head1 NAME

syspref.t

=head1 DESCRIPTION

This test identifies incoherences between translated sysprefs files
and the reference file.

Koha sysprefs are loaded to sypref table from a text SQL file during
Koha installation by web installer. The reference file is the one
provided for English (en) installation :

  <koha_root>/installer/data/mysql/en/mandatory/sysprefs.sql

Alternatives files are provided for other languages. Those files
are difficult to keep syncrhonized with reference file.

=head1 USAGE

prove -v syspref.t

=cut

