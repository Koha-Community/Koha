#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright 2016 Koha Development Team
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

use Getopt::Long;
use Pod::Usage;

use C4::Installer;
use C4::Context;
use t::lib::Mocks;

=head1 NAME

populate_db.pl - Load included sample data into the DB

=head1 SYNOPSIS

populate_db.pl [--marcflavour MARCFLAVOUR]

 Options:
   --help            Brief help message
   --marcflavour m   Specify the MARC flavour to use (MARC21|UNIMARC). Defaults
                                to MARC21.
   -v                Be verbose.

=head1 OPTIONS

=over 8

=item B<--help>

Prints a brief help message and exits.

=item B<--marcflavour>

Lets you choose the desired MARC flavour for the sample data. Valid options are MARC21 and UNIMARC.
It defaults to MARC21.

=item B<--verbose>

Make the output more verbose.

=back

=cut

my $help;
my $verbose;
my $marcflavour = 'MARC21';

GetOptions(
    'help|?'        => \$help,
    'verbose'       => \$verbose,
    'marcflavour=s' => \$marcflavour
) or pod2usage;

if ( $help ) {
    pod2usage;
}

$marcflavour = uc($marcflavour);

if (     $marcflavour ne 'MARC21'
     and $marcflavour ne 'UNIMARC' ) {
    say "Invalid MARC flavour '$marcflavour' passed.";
    pod2usage;
}

$ENV{KOHA_DB_DO_NOT_RAISE_OR_PRINT_ERROR} = 1;
my $dbh = C4::Context->dbh; # At the beginning to die if DB does not exist.

my ( $prefs_count ) = $dbh->selectrow_array(q|SELECT COUNT(*) FROM systempreferences|);
my ( $patrons_count ) = $dbh->selectrow_array(q|SELECT COUNT(*) FROM borrowers|);
if ( $prefs_count or $patrons_count ) {
    die "Database is not empty!";
}
$dbh->disconnect;
$ENV{KOHA_DB_DO_NOT_RAISE_OR_PRINT_ERROR} = 0;

our $root      = C4::Context->config('intranetdir');
our $data_dir  = "$root/installer/data/mysql";
our $installer = C4::Installer->new;
my $lang                = 'en';
my $koha_structure_file = "$data_dir/kohastructure.sql";
my @sample_files_mandatory = (
    glob("$data_dir/mandatory/*.sql"),
    "$data_dir/audio_alerts.sql",
    "$data_dir/sysprefs.sql",
    "$data_dir/userflags.sql",
    "$data_dir/userpermissions.sql",
);
my @sample_lang_files_mandatory    = ( glob $root . "/installer/data/mysql/$lang/mandatory/*.sql" );
my @sample_lang_files_optional     = ( glob $root . "/installer/data/mysql/$lang/optional/*.sql" );
my @marc21_sample_files_mandatory  = ( glob $root . "/installer/data/mysql/$lang/marcflavour/marc21/*/*.sql" );
my @unimarc_sample_files_mandatory = ( glob $root . "/installer/data/mysql/$lang/marcflavour/unimarc/*/*.sql" );

my $version = get_version();

initialize_data();
update_database();

sub initialize_data {
    say "Inserting koha db structure..."
        if $verbose;
    my $error = $installer->load_db_schema;
    die $error if $error;

    for my $f (@sample_files_mandatory) {
        execute_sqlfile($f);
    }

    for my $f (@sample_lang_files_mandatory) {
        execute_sqlfile($f);
    }

    for my $f (@sample_lang_files_optional) {
        execute_sqlfile($f);
    }

    if ( $marcflavour eq 'UNIMARC' ) {
        for my $f (@unimarc_sample_files_mandatory) {
            execute_sqlfile($f);
        }
    } else {
        for my $f (@marc21_sample_files_mandatory) {
            execute_sqlfile($f);
        }
    }

    # set marcflavour (MARC21)
    my $dbh = C4::Context->dbh;

    say "Setting the MARC flavour on the sysprefs..."
        if $verbose;
    $dbh->do(qq{
        INSERT INTO `systempreferences` (variable,value,explanation,options,type)
        VALUES ('marcflavour',?,'Define global MARC flavor (MARC21 or UNIMARC) used for character encoding','MARC21|UNIMARC','Choice')
    },undef,$marcflavour);

    # set version
    say "Setting Koha version to $version..."
        if $verbose;
    $dbh->do(qq{
        INSERT INTO systempreferences(variable, value, options, explanation, type)
        VALUES ('Version', '$version', NULL, 'The Koha database version. WARNING: Do not change this value manually, it is maintained by the webinstaller', NULL)
    });
}

sub execute_sqlfile {
    my ($filepath) = @_;
    say "Inserting $filepath..."
        if $verbose;
    my $error = $installer->load_sql($filepath);
    die $error if $error;
}

sub get_version {
    do $root . '/kohaversion.pl';
    my $version = kohaversion();
    $version =~ s/(\d)\.(\d{2})\.(\d{2})\.(\d{3})/$1.$2$3$4/;
    return $version;
}

sub update_database {
    my $update_db_path = $root . '/installer/data/mysql/updatedatabase.pl';
    say "Updating database..."
        if $verbose;
    my $file = `cat $update_db_path`;
    $file =~ s/exit;//;
    eval $file;
    if ($@) {
        die "updatedatabase.pl process failed: $@";
    } else {
        say "updatedatabase.pl process succeeded.";
    }
}
