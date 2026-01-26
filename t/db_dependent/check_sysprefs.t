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

use File::Slurp qw(read_file);
use C4::Context;
use Array::Utils qw(array_minus);

use Test::NoWarnings;
use Test::More tests => 3;

our $dbh = C4::Context->dbh;
my $intranetdir      = C4::Context->config('intranetdir');
my $root_dir         = $intranetdir . '/installer/data/mysql/mandatory';
my $syspref_filepath = "$root_dir/sysprefs.sql";

my @lines            = read_file($syspref_filepath) or die "Can't open $syspref_filepath: $!";
my @sysprefs_in_file = get_sysprefs_from_file(@lines);

subtest 'Compare database with sysprefs.sql file' => sub {
    ok( scalar(@sysprefs_in_file), "Found sysprefs" );

    check_db(@sysprefs_in_file);
};

subtest 'Compare sysprefs.sql with YAML files' => sub {
    plan tests => 2;

    my $yaml_prefs = get_syspref_from_yaml();
    my @yaml_mod   = @$yaml_prefs;
    @yaml_mod = grep !/marcflavour/, @yaml_mod;    # Added by web installer

    my @syspref_names_in_file = map { $_->{variable} } @sysprefs_in_file;
    @syspref_names_in_file = grep !/ElasticsearchIndexStatus_authorities/,
        @syspref_names_in_file;                    # Not to be changed manually
    @syspref_names_in_file = grep !/ElasticsearchIndexStatus_biblios/,
        @syspref_names_in_file;                    # Not to be changed manually
    @syspref_names_in_file = grep !/OPACdidyoumean/,           @syspref_names_in_file;    # Separate configuration page
    @syspref_names_in_file = grep !/UsageStatsID/,             @syspref_names_in_file;    # Separate configuration page
    @syspref_names_in_file = grep !/UsageStatsLastUpdateTime/, @syspref_names_in_file;    # Separate configuration page
    @syspref_names_in_file = grep !/UsageStatsPublicID/,       @syspref_names_in_file;    # Separate configuration page

    my @missing_yaml = array_minus( @syspref_names_in_file, @yaml_mod );
    is( scalar @missing_yaml, 0, "No system preference entries missing from sysprefs.sql" );
    if ( scalar @missing_yaml > 0 ) {
        diag "System preferences missing from YAML:\n  * " . join( "\n  * ", @missing_yaml ) . "\n";
    }

    my @missing_sysprefs = array_minus( @yaml_mod, @syspref_names_in_file );
    is( scalar @missing_sysprefs, 0, "No system preference entries missing from YAML files" );
    if ( scalar @missing_sysprefs > 0 ) {
        diag "System preferences missing from sysprefs.sql:\n  * " . join( "\n  * ", @missing_sysprefs ) . "\n";
    }
};

# Get sysprefs from SQL file populating sysprefs table with INSERT statement.
#
# Example:
# INSERT INTO `systempreferences` (variable,value,explanation,options,type)
# VALUES('AmazonLocale','US','Use to set the Locale of your Amazon.com Web Services',
# 'US|CA|DE|FR|JP|UK','Choice')
#
sub get_sysprefs_from_file {
    my @lines = @_;
    my @sysprefs;
    for my $line (@lines) {
        chomp $line;
        next if $line =~ /^INSERT INTO /;    # first line
        next if $line =~ /^;$/;              # last line
        next if $line =~ /^--/;              # Comment line
        if (
            $line =~ m/
            '(?<variable>[^'\\]*(?:\\.[^'\\]*)*)',\s*
            '(?<value>[^'\\]*(?:\\.[^'\\]*)*)',\s*
            (?<options>NULL|'(?<options_content>[^'\\]*(?:\\.[^'\\]*)*)'),\s*
            (?<explanation>NULL|'(?<explanation_content>[^'\\]*(?:\\.[^'\\]*)*)'),\s*
            (?<type>NULL|'(?<type_content>[^'\\]*(?:\\.[^'\\]*)*)')
        /xms
            )
        {
            my $variable    = $+{variable};
            my $value       = $+{value};
            my $options     = $+{options_content};
            my $explanation = $+{explanation_content};
            my $type        = $+{type_content};

            if ($options) {
                $options =~ s/\\'/'/g;
                $options =~ s/\\\\/\\/g;
            }
            if ($explanation) {
                $explanation =~ s/\\'/'/g;
                $explanation =~ s/\\n/\n/g;
            }

            # FIXME Explode if already exists?
            push @sysprefs, {
                variable    => $variable,
                value       => $value,
                options     => $options,
                explanation => $explanation,
                type        => $type,
            };
        } else {
            die "$line does not match";
        }
    }
    return @sysprefs;
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
    my @sysprefs_from_file = @_;

    # FIXME FrameworksLoaded is a temporary syspref created during the installation process
    # We should either rewrite the code to avoid its need, or delete it once the installation is finished.
    my $sysprefs_in_db = $dbh->selectall_hashref(
        q{
        SELECT * from systempreferences
        WHERE variable <> 'FrameworksLoaded'
    }, 'variable'
    );

    # Checking the number of sysprefs in the database
    my @syspref_names_in_db   = keys %$sysprefs_in_db;
    my @syspref_names_in_file = map { $_->{variable} } @sysprefs_in_file;
    my @diff                  = array_minus @syspref_names_in_db, @syspref_names_in_file;
    is_deeply( [ sort @diff ], [ 'Version', 'marcflavour' ] )
        or diag sprintf( "Too many sysprefs in DB: %s", join ", ", @diff );

    my @sorted_names_in_file = sort {
        $b =~ s/_/ZZZ/g;    # mysql sorts underscore last, if you modify this qa-test-tools will need adjustements
        lc($a) cmp lc($b)
    } @syspref_names_in_file;
    is_deeply( \@syspref_names_in_file, \@sorted_names_in_file, 'Syspref in sysprefs.sql must be sorted by name' );
    for my $pref (@sysprefs_in_file) {
        my $in_db     = $sysprefs_in_db->{ $pref->{variable} };
        my %db_copy   = %$in_db;
        my %file_copy = %$pref;
        delete $db_copy{value};
        delete $file_copy{value};

        if ( $pref->{variable} =~ m{^ElasticsearchIndexStatus_} ) {

            # Exception for the 2 sysprefs ElasticsearchIndexStatus_authorities and ElasticsearchIndexStatus_biblios
            # They do not have a type defined
            # Will deal with them on a follow-up bugs
            next;
        }

        # Do not compare values, they can differ (new vs existing installs)
        is_deeply( \%db_copy, \%file_copy, sprintf "Comparing %s", $pref->{variable} );
        if ( !defined $pref->{type} ) {
            fail( sprintf "%s does not have a type in file!", $pref->{variable} );
        }
        if ( !defined $in_db->{type} ) {
            fail( sprintf "%s does not have a type in DB!", $in_db->{variable} );
        }
        if ( $pref->{type} && $pref->{type} eq 'YesNo' ) {
            like(
                $pref->{value}, qr{^(0|1)$},
                sprintf( "Pref %s must be 0 or 1, found=%s in file", $pref->{variable}, $pref->{value} ),
            );
            like(
                $in_db->{value}, qr{^(0|1)$},
                sprintf( "Pref %s must be 0 or 1, found=%s in DB", $in_db->{variable}, $in_db->{value} ),
            );
        }

        # TODO Check on valid 'type'
        #like($pref->{type}, qr{^()$});
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
