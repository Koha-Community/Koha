#!/usr/bin/perl

# Copyright (C) 2010 BibLibre
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
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
use warnings;

use Getopt::Long;
use C4::Context;

# When this option is set, no tests are performed.
# The missing sysprefs are displayed as sql inserts instead.
our $showsql = 0;
GetOptions( 'showsql' => \$showsql );

use Test::More qw(no_plan);
our $dbh = C4::Context->dbh;
my $root_dir = C4::Context->config('intranetdir') . '/installer/data/mysql';
my $base_syspref_file = "sysprefs.sql";

open( my $ref_fh, "<$root_dir/$base_syspref_file" );
my $ref_syspref = get_syspref_from_file($ref_fh);
my @ref_sysprefs = sort { lc $a cmp lc $b } keys %$ref_syspref;
if ( !$showsql ) {
    cmp_ok( $#ref_sysprefs, '>=', 0,
        "Found " . ( $#ref_sysprefs + 1 ) . " sysprefs" );
}

check_db($ref_syspref);

#
# Get sysprefs from SQL file populating sysprefs table with INSERT statement.
#
# Example:
# INSERT INTO `systempreferences` (variable,value,explanation,options,type)
# VALUES('AmazonLocale','US','Use to set the Locale of your Amazon.com Web Services',
# 'US|CA|DE|FR|JP|UK','Choice')
#
sub get_syspref_from_file {
    my $fh = shift;
    my %syspref;
    while (<$fh>) {
        next if /^--/;    # Comment line
        my $query = $_;
        if ( $_ =~ /\([\s]*\'([\w\-:]+)\'/ ) {
            my $variable = $1;
            if ($variable) {
                $syspref{$variable} = $query;
            }
        }
    }
    return \%syspref;
}

sub check_db {
    my $sysprefs = shift;

    # Checking the number of sysprefs in the database
    my $query = "SELECT COUNT(*) FROM systempreferences";
    my $sth   = $dbh->prepare($query);
    $sth->execute;
    my $res     = $sth->fetchrow_arrayref;
    my $dbcount = $res->[0];
    if ( !$showsql ) {
        cmp_ok( $dbcount, ">=", scalar( keys %$sysprefs ),
"There are at least as many sysprefs in the database as in the sysprefs.sql"
        );
    }

    # Checking for missing sysprefs in the database
    $query = "SELECT COUNT(*) FROM systempreferences WHERE variable=?";
    $sth   = $dbh->prepare($query);
    foreach ( keys %$sysprefs ) {
        $sth->execute($_);
        my $res   = $sth->fetchrow_arrayref;
        my $count = $res->[0];
        if ( !$showsql ) {
            is( $count, 1, "Syspref $_ exists in the database" );
        }
        else {
            if ( $count != 1 ) {
                print $sysprefs->{$_};
            }
        }
    }
}

=head1 NAME

syspref.t

=head1 DESCRIPTION

This test checks for missing sysprefs in the database.

Sysprefs are gathered from the installation file. The database is
then queried to check if all the sysprefs are in it.

=head1 USAGE

prove -v xt/check_sysprefs.t

If you want to display the missing sysprefs as sql inserts :
perl check_sysprefs.t --showsql

=cut
