#!/usr/bin/perl
#
# Copyright (C) 2012 Tamil s.a.r.l.
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
BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    my $lib = "$FindBin::Bin/../kohalib.pl";
    eval { require $lib };
}

use Getopt::Long;
use Pod::Usage;
use YAML;
use Try::Tiny;
use C4::Context;


my ($doit, $alterengine, $help);
my $result = GetOptions(
    'doit'        => \$doit,
    'alterengine' => \$alterengine,
    'help|h'      => \$help,
);


sub usage {
    pod2usage( -verbose => 2 );
    exit;
}


sub fix_mysql_constraints {
    my ($doit) = @_;

    # Get all current DB constraints
    my $dbh = C4::Context->dbh;
    $dbh->{RaiseError} = 1;
    $dbh->{ShowErrorStatement} = 1;
    my $database = C4::Context->config('database');
    my %db_constraint = map { $_->[0] => undef } @{$dbh->selectall_arrayref(
        "SELECT CONSTRAINT_NAME
           FROM information_schema.table_constraints
          WHERE constraint_schema = '$database'
            AND CONSTRAINT_TYPE != 'PRIMARY KEY' ")};

    my $base_dir = C4::Context->config('intranetdir');
    open my $fh, "<", "$base_dir/installer/data/mysql/kohastructure.sql"
        or die "Unable to open kohastructure.sql file";

    my $table_name;
    my $engine_altered;
    # FIXME: This hide problem. But if you run this script, it means that you
    # have already identified issues with your Koha DB integrity, and will fix
    # any necessary tables requiring records deleting.
    $dbh->do("SET FOREIGN_KEY_CHECKS=0");
    my $line = <$fh>;
    while ( $line ) {
        if ( $line =~ /CREATE TABLE (.*?) / ) {
            $table_name = $1;
            $table_name =~ s/\`//g;
            $engine_altered = 0;
            $line = <$fh>;
            next;
        }
        unless ( $line =~ /CONSTRAINT /i ) {
            $line = <$fh>;
            next;
        }
        my $constraint = $line;
        CONTRAINT_LOOP:
        while ( $constraint !~ /,/ ) {
            $line = <$fh>;
            last CONTRAINT_LOOP if $line =~ /ENGINE/i;
            $line =~ s/^ */ /;
            $constraint .= $line;
        }
        $constraint =~ s/^ *//;
        $constraint =~ s/\n//g;
        $constraint =~ s/ *$//;
        $constraint =~ s/,$//;
        my ($name) = $constraint =~ /CONSTRAINT (.*?) /;
        $name =~ s/\`//g;
        unless ( exists($db_constraint{$name}) ) {
            if ( $alterengine && !$engine_altered ) {
                my $sql = "ALTER TABLE $table_name ENGINE = 'InnoDB'";
                say $sql;
                if ( $doit ) {
                    try {
                        $dbh->do($sql) if $doit;
                        $engine_altered = 1;
                    } catch {
                        say "Error: $_;";
                    };
                }
            }
            my $sql = "ALTER TABLE $table_name ADD $constraint";
            say $sql;
            if ( $doit ) {
                try {
                    $dbh->do($sql) if $doit;
                } catch {
                    say "Error: $_";
                }
            }
        }
        $line = <$fh> if $line =~ /CONSTRAINT/i;
    }
}


usage() if $help;

fix_mysql_constraints($doit);

=head1 NAME

fix_mysql_constraints.pl

=head1 SYNOPSIS

  fix_mysql_constraints.pl --help
  fix_mysql_constraints.pl
  fix_mysql_constraints.pl --doit

=head1 DESCRIPTION

See bug #8915

Alter tables to add missing constraints. Prior to altering tables, it may be
necessary to alter tables storage engine from MyISAM to InnoDB.

=over 8

=item B<--help>

Prints this help

=item B<--doit>

Alter tables effectively, otherwise just display the ALTER TABLE directives.

=item B<--alterengine>

Prior to add missing constraints, alter table engine to InnoDB.

=back

=cut
