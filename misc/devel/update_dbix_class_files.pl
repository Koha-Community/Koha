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

my $path = "./";
my $db_driver = 'mysql';
my $db_host = 'localhost';
my $db_port = '3306';
my $db_name = '';
my $db_user = '';
my $db_passwd = '';
GetOptions(
    "path=s"      => \$path,
    "db_driver=s" => \$db_driver,
    "db_host=s"   => \$db_host,
    "db_port=s"   => \$db_port,
    "db_name=s"   => \$db_name,
    "db_user=s"   => \$db_user,
    "db_passwd=s" => \$db_passwd,
);

make_schema_at(
    "Koha::Schema",
    {debug => 1, dump_directory => $path},
    ["DBI:$db_driver:dbname=$db_name;host=$db_host;port=$db_port",$db_user, $db_passwd ]
);
