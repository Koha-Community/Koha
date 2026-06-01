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

use Array::Utils qw(array_minus);

use Test::NoWarnings;
use Test::More tests => 3;

use C4::Context;

use Koha::Devel::Sysprefs;
use Koha::Config::SysPrefs;

our $dbh = C4::Context->dbh;
my $intranetdir = C4::Context->config('intranetdir');

my @exceptions = qw(
    marcflavour
    ElasticsearchIndexStatus_authorities
    ElasticsearchIndexStatus_biblios
    OPACdidyoumean
    UsageStatsID
    UsageStatsLastUpdateTime
    UsageStatsPublicID
);

my @sysprefs_in_sql_file = Koha::Devel::Sysprefs->new->get_sysprefs_from_file();

subtest 'Compare database with sysprefs.sql file' => sub {
    ok( scalar(@sysprefs_in_sql_file), "Found sysprefs" );

    check_db(@sysprefs_in_sql_file);
};

subtest 'Compare sysprefs.sql with YAML files' => sub {
    plan tests => 2;

    my $yaml_prefs                  = Koha::Config::SysPrefs->get_all_from_yml;
    my @syspref_names_in_yaml_files = keys %$yaml_prefs;
    @syspref_names_in_yaml_files = array_minus @syspref_names_in_yaml_files, @exceptions;

    my @syspref_names_in_sql_file = map { $_->{variable} } @sysprefs_in_sql_file;
    @syspref_names_in_sql_file = array_minus @syspref_names_in_sql_file, @exceptions;

    my @missing_yaml = array_minus( @syspref_names_in_sql_file, @syspref_names_in_yaml_files );
    is( scalar @missing_yaml, 0, "No system preference entries missing from sysprefs.sql" );
    if ( scalar @missing_yaml > 0 ) {
        diag "System preferences missing from YAML:\n  * " . join( "\n  * ", @missing_yaml ) . "\n";
    }

    my @missing_sysprefs = array_minus( @syspref_names_in_yaml_files, @syspref_names_in_sql_file );
    is( scalar @missing_sysprefs, 0, "No system preference entries missing from YAML files" );
    if ( scalar @missing_sysprefs > 0 ) {
        diag "System preferences missing from sysprefs.sql:\n  * " . join( "\n  * ", @missing_sysprefs ) . "\n";
    }
};

sub check_db {
    my @sysprefs_from_file = @_;

    # FIXME FrameworksLoaded is a temporary syspref created during the installation process
    # We should either rewrite the code to avoid its need, or delete it once the installation is finished.
    my $sysprefs_in_db = $dbh->selectall_arrayref(
        q{
        SELECT * from systempreferences
        WHERE variable NOT IN ('marcflavour', 'Version', 'FrameworksLoaded')
        ORDER BY variable
    }, { Slice => {} }
    );

    my $yaml_prefs = Koha::Config::SysPrefs->get_all_from_yml;

    # Checking the number of sysprefs in the database
    my @syspref_names_in_db       = map { $_->{variable} } @$sysprefs_in_db;
    my @syspref_names_in_sql_file = map { $_->{variable} } @sysprefs_in_sql_file;
    my @diff                      = array_minus @syspref_names_in_db, @syspref_names_in_sql_file;
    is( scalar(@diff), 0 )
        or diag sprintf( "Too many sysprefs in DB: %s", join ", ", @diff );

    is_deeply( \@syspref_names_in_sql_file, \@syspref_names_in_db, 'Syspref in sysprefs.sql must be sorted by name' );
    for my $pref (@sysprefs_in_sql_file) {
        my ($in_db)   = grep { $_->{variable} eq $pref->{variable} } @$sysprefs_in_db;
        my %db_copy   = %$in_db;
        my %file_copy = %$pref;
        delete $db_copy{value};
        delete $file_copy{value};

        delete $db_copy{options};
        delete $db_copy{explanation};
        delete $db_copy{type};

        # Do not compare values, they can differ (new vs existing installs)
        is_deeply( \%db_copy, \%file_copy, sprintf "Comparing %s", $pref->{variable} );
        if ( defined $in_db->{options} ) {
            fail( sprintf "%s has 'options' set in DB, must be NULL!", $in_db->{variable} );
        }
        if ( defined $in_db->{explanation} ) {
            fail( sprintf "%s has 'explanation' set in DB, must be NULL!", $in_db->{variable} );
        }
        if ( defined $in_db->{type} ) {
            fail( sprintf "%s has 'type' set in DB, must be NULL!", $in_db->{variable} );
        }

        next if grep { $_ eq $pref->{variable} } @exceptions;

        my $yaml_pref = $yaml_prefs->{ $pref->{variable} };
        if ( $yaml_pref->{type} eq 'select' && ref( $yaml_pref->{choices} ) ) {
            my @choices = sort keys %{ $yaml_pref->{choices} };
            if ( scalar(@choices) == 2 && $choices[0] eq "0" && $choices[1] eq "1" ) {
                like(
                    $pref->{value}, qr{^(0|1)$},
                    sprintf( "Pref %s must be 0 or 1, found=%s in file", $pref->{variable}, $pref->{value} ),
                );
                like(
                    $in_db->{value}, qr{^(0|1)$},
                    sprintf( "Pref %s must be 0 or 1, found=%s in DB", $in_db->{variable}, $in_db->{value} ),
                );

            }
        }
    }
}

=head1 NAME

check_sysprefs.t

=head1 DESCRIPTION

This test checks for missing system preferences in the database
and the sysprefs.sql file.

System prefereces are gathered from the installation and YAML files.
The database is then queried to check if all the system preferneces are
in it.

=cut
