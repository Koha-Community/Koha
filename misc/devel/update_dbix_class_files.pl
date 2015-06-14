#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright (C) 2012 ByWater Solutions
# Copyright (C) 2013 Equinox Software, Inc.
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

use DBIx::Class::Schema::Loader qw/ make_schema_at /;

use Getopt::Long;
use Pod::Usage;

my $path = "./";
my $db_driver = 'mysql';
my $db_host = 'localhost';
my $db_port = '3306';
my $db_name;
my $db_user;
my $db_passwd;
my $help;

GetOptions(
    "path=s"      => \$path,
    "db_driver=s" => \$db_driver,
    "db_host=s"   => \$db_host,
    "db_port=s"   => \$db_port,
    "db_name=s"   => \$db_name,
    "db_user=s"   => \$db_user,
    "db_passwd=s" => \$db_passwd,
    "h|help"      => \$help
);

# If we were asked for usage instructions, do it
pod2usage(1) if defined $help;

if (! defined $db_name ) {
    print "Error: \'db_name\' parameter is mandatory.\n";
    pod2usage(1);
} else {

    make_schema_at(
        "Koha::Schema",
        { debug => 1, dump_directory => $path, preserve_case => 1 },
        ["DBI:$db_driver:dbname=$db_name;host=$db_host;port=$db_port",$db_user, $db_passwd ]
    );
}

1;

=head1 NAME

misc/devel/update_dbix_class_files.pl

=head1 SYNOPSIS

 update_dbix_class_files.pl --db_name=db-name --db_user=db-user \
                            --db_passwd=db-pass ...

The command in usually called from the root directory for the Koha source tree.
If you are running from another directory, use the --path switch to specify
a different path.

=head1 OPTIONS

=over 8

=item B<--db_name>

DB name. (mandatory)

=item B<--db_user>

DB user name.

=item B<--db_passwd>

DB password.

=item B<--db_driver>

DB driver to be used. (defaults to 'mysql')

=item B<--db_host>

hostname for the DB server. (defaults to 'localhost')

=item B<--db_port>

port number for the DB server. (defaults to '3306')

=item B<--path>

path into which create the schema files. (defaults to './')

=item B<-h|--help>

prints this help text

=back