#!/usr/bin/perl

# Copyright (C) 2014 Tamil s.a.r.l.
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

use Modern::Perl;
use Test::More qw(no_plan);


my $root_dir = 'installer/data/mysql';
my $base_notices_file = "en/mandatory/sample_notices.sql";
my @trans_notices_files = qw(
    fr-FR/1-Obligatoire/sample_notices.sql
    de-DE/mandatory/sample_notices.sql
    es-ES/mandatory/sample_notices.sql
    it-IT/necessari/notices.sql
    nb-NO/1-Obligatorisk/sample_notices.sql
    pl-PL/mandatory/sample_notices.sql
    ru-RU/mandatory/sample_notices.sql
    uk-UA/mandatory/sample_notices.sql
);

ok(
    open( my $ref_fh, "<", "$root_dir/$base_notices_file" ),
    "Open reference sample notices file $root_dir/$base_notices_file" );
my $ref_notice = get_notices_from_file( $ref_fh );
my @ref_notices = sort { lc $a cmp lc $b } keys %$ref_notice;
cmp_ok(
    $#ref_notices, '>=', 0,
    "Found " . ($#ref_notices + 1) . " sample notices" );

foreach my $file_name ( @trans_notices_files ) {
    compare_notices( $file_name );
}


#
# Get sample notices from SQL file populating letters table with INSERT
# statement.
#
sub get_notices_from_file {
    my $fh = shift;
    my %notice;
    while ( <$fh> ) {
        next unless /, *'([\_A-Z_]*)'/;
        $notice{$1} = 1;
    }
    return \%notice;
}


sub compare_notices {
    my $trans_file = shift;
    ok(
       open( my $trans_fh,"<", "$root_dir/$trans_file" ),
       "Open translated sample notices file $root_dir/$trans_file" );
    my $trans_notice = get_notices_from_file( $trans_fh );
    use YAML;
    my @trans_notices = sort { lc $a cmp lc $b } keys %$trans_notice;
    cmp_ok(
        $#trans_notices, '>=', 0,
        "Found " . ($#trans_notices + 1) . " notices" );
    my @to_add_notices;
    foreach ( @ref_notices ) {
       push @to_add_notices, $_ if ! $trans_notice->{$_};
    }
    if ( $#to_add_notices >= 0 ) {
        fail( 'No sample notice to add') or diag( "Sample notices to add in $trans_file: " . join(', ', @to_add_notices ) );
    }
    else {
        pass( 'No sample notice to add' );
    }

    my @to_delete_notices;
    foreach ( @trans_notices ) {
       push @to_delete_notices, $_ if ! $ref_notice->{$_};
    }
    if ( $#to_delete_notices >= 0 ) {
        fail( 'No sample notice to delete' );
        diag( "Sample notices to delete in $trans_file: " . join(', ', @to_delete_notices ) );
        diag( 'Warning: Some of those sample notices may rather have to be added to English notice' );
    }
    else {
        pass( 'No sample notices to delete' );
    }
}


=head1 NAME

sample_notices.t

=head1 DESCRIPTION

This test identifies incoherences between translated sample notices and the
'en' reference file.

Koha sample notices are loaded to 'letter' table from a text SQL file
during Koha installation by web installer. The reference file is the one
provided for English (en) installation :

  <koha_root>/installer/data/mysql/en/mandatory/sample_notices.sql

Alternatives files are provided for other languages. Those files are difficult
to keep synchronized with reference file. This could be an functional issue
since some Koha operation depend on notice existence, for example Print Slip in
Circulation.

=head1 USAGE

 prove -v sample_notices.t
 prove sample_notices.t

=cut
