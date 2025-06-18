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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use DBIx::Class::Schema::Loader qw/ make_schema_at /;

use Getopt::Long qw( GetOptions );
use Pod::Usage   qw( pod2usage );

my %db_defaults = (
    driver => 'mysql',
    host   => 'localhost',
    port   => '3306',
);

my $path = "./";
my $db_driver;
my $db_host;
my $db_port;
my $db_name;
my $db_user;
my $db_passwd;
my $koha_conf;
my $force;
my $help;

GetOptions(
    "path=s"      => \$path,
    "db_driver=s" => \$db_driver,
    "db_host=s"   => \$db_host,
    "db_port=s"   => \$db_port,
    "db_name=s"   => \$db_name,
    "db_user=s"   => \$db_user,
    "db_passwd=s" => \$db_passwd,
    "koha-conf:s" => \$koha_conf,
    "force"       => \$force,
    "h|help"      => \$help
);

# If we were asked for usage instructions, do it
pod2usage(1) if defined $help;

if ( defined $koha_conf ) {
    if ( $koha_conf eq '' and not defined $ENV{KOHA_CONF} ) {
        print STDERR "Error: KOHA_CONF is not defined\n";
        exit(1);
    }

    $koha_conf ||= $ENV{KOHA_CONF};
    unless ( -r $koha_conf ) {
        print STDERR "Error: File $koha_conf does not exist or is not readable\n";
        exit(1);
    }

    require C4::Context;
    my $context = C4::Context->new($koha_conf);
    unless ($context) {
        print STDERR "Error: Koha context creation failed. Please check that $koha_conf is correct\n";
        exit(1);
    }

    $context->set_context;
    $db_defaults{driver} = $context->config('db_scheme');
    $db_defaults{host}   = $context->config('hostname');
    $db_defaults{port}   = $context->config('port');
    $db_defaults{name}   = $context->config('database');
    $db_defaults{user}   = $context->config('user');
    $db_defaults{passwd} = $context->config('pass');
}

$db_driver //= $db_defaults{driver};
$db_host   //= $db_defaults{host};
$db_port   //= $db_defaults{port};
$db_name   //= $db_defaults{name};
$db_user   //= $db_defaults{user};
$db_passwd //= $db_defaults{passwd};

if ( !defined $db_name ) {
    print "Error: \'db_name\' parameter is mandatory.\n";
    pod2usage(1);
} else {

    $force //= 0;

    make_schema_at(
        "Koha::Schema",
        { debug => 1, dump_directory => $path, preserve_case => 1, overwrite_modifications => $force },
        [
            "DBI:$db_driver:dbname=$db_name;host=$db_host;port=$db_port",
            $db_user,
            $db_passwd,
            { loader_class => 'Koha::Schema::Loader::mysql' }
        ]
    );
}

1;

=head1 NAME

misc/devel/update_dbix_class_files.pl

=head1 SYNOPSIS

 update_dbix_class_files.pl [--koha-conf <path>] --db_name=db-name \
                            --db_user=db-user --db_passwd=db-pass ...

The command in usually called from the root directory for the Koha source tree.
If you are running from another directory, use the --path switch to specify
a different path.

=head1 OPTIONS

=over 8

=item B<--koha-conf> <path>

Path to koha-conf.xml from which DB connection params will be retrieved.

<path> is optional and defaults to the value of environment variable KOHA_CONF,
if set. It is an error to omit the <path> if KOHA_CONF is not set.

Any B<--db_*> options will override values retrieved from <path>.

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

=item B<--force>

Force a schema overwrite.

WARNING: Use this at your own risk! it's helpful if you are maintaining a fork or in other such cases. You should always attempt to run the script without force first and only resort to using force if that fails. It is also very much worthwhile checking the diff after running with force to ensure you have not resulted in any unexpected changes.

=item B<-h|--help>

prints this help text

=back
