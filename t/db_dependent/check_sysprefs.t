#!/usr/bin/perl

# Copyright (C) 2010 BibLibre
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Carp;
use Getopt::Long;
use C4::Context;
use Array::Utils qw(array_minus);

# When this option is set, no tests are performed.
# The missing sysprefs are displayed as sql inserts instead.
our $showsql = 0;
GetOptions( 'showsql' => \$showsql );

use Test::NoWarnings;
use Test::More tests => 3;

our $dbh = C4::Context->dbh;
my $intranetdir       = C4::Context->config('intranetdir');
my $root_dir          = $intranetdir . '/installer/data/mysql/mandatory';
my $base_syspref_file = "sysprefs.sql";

open my $ref_fh, '<', "$root_dir/$base_syspref_file" or croak "Can't open '$root_dir/$base_syspref_file': $!";
my $ref_syspref  = get_syspref_from_file($ref_fh);
my @ref_sysprefs = sort { lc $a cmp lc $b } keys %$ref_syspref;
my $num_sysprefs = scalar @ref_sysprefs;

subtest 'Compare database with sysprefs.sql file' => sub {
    if ( !$showsql ) {
        cmp_ok(
            $num_sysprefs, '>', 0,
            "Found $num_sysprefs sysprefs"
        );
    }

    check_db($ref_syspref);
};

subtest 'Compare sysprefs.sql with YAML files' => sub {
    plan tests => 2;

    my $yaml_prefs = get_syspref_from_yaml();
    my @yaml_mod   = @$yaml_prefs;
    @yaml_mod = grep !/marcflavour/, @yaml_mod;    # Added by web installer

    my @sysprefs_mod = @ref_sysprefs;
    @sysprefs_mod = grep !/ElasticsearchIndexStatus_authorities/, @sysprefs_mod;    # Not to be changed manually
    @sysprefs_mod = grep !/ElasticsearchIndexStatus_biblios/,     @sysprefs_mod;    # Not to be changed manually
    @sysprefs_mod = grep !/OPACdidyoumean/,                       @sysprefs_mod;    # Separate configuration page
    @sysprefs_mod = grep !/UsageStatsID/,                         @sysprefs_mod;    # Separate configuration page
    @sysprefs_mod = grep !/UsageStatsLastUpdateTime/,             @sysprefs_mod;    # Separate configuration page
    @sysprefs_mod = grep !/UsageStatsPublicID/,                   @sysprefs_mod;    # Separate configuration page

    my @missing_yaml = array_minus( @sysprefs_mod, @yaml_mod );
    is( scalar @missing_yaml, 0, "No system preference entries missing from sysprefs.sql" );
    if ( scalar @missing_yaml > 0 ) {
        diag "System preferences missing from YAML:\n  * " . join( "\n  * ", @missing_yaml ) . "\n";
    }

    my @missing_sysprefs = array_minus( @yaml_mod, @sysprefs_mod );
    is( scalar @missing_sysprefs, 0, "No system preference entries missing from YAML files" );
    if ( scalar @missing_sysprefs > 0 ) {
        diag "System preferences missing from sysprefs.sql:\n  * " . join( "\n  * ", @missing_sysprefs ) . "\n";
    }
};

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

#  Get system preferences from YAML files
sub get_syspref_from_yaml {
    my @prefs;
    foreach my $file ( glob( $intranetdir . "/koha-tmpl/intranet-tmpl/prog/en/modules/admin/preferences/*.pref" ) ) {
        if ( open( my $fh, '<:encoding(UTF-8)', $file ) ) {
            while ( my $row = <$fh> ) {
                chomp $row;
                my $pref;
                if ( $row =~ /pref: (.*)/ ) {
                    $pref = $1;
                    $pref =~ s/["']//ig;
                    push @prefs, $pref;
                }
            }
        } else {
            warn "Could not open file '$file' $!";
        }
    }
    return \@prefs;
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
        cmp_ok(
            $dbcount, ">=", scalar( keys %$sysprefs ),
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
        } else {
            if ( $count != 1 ) {
                print $sysprefs->{$_};
            }
        }
    }
}

=head1 NAME

syspref.t

=head1 DESCRIPTION

This test checks for missing system preferences in the database
and the sysprefs.sql file.

System prefereces are gathered from the installation and YAML files.
The database is then queried to check if all the system preferneces are
in it.

=head1 USAGE

prove -v xt/check_sysprefs.t

If you want to display the missing sysprefs as sql inserts :
perl check_sysprefs.t --showsql

=cut
