#!/usr/bin/perl

use strict;
use warnings;
use C4::Context;
use DBIx::Class::Schema::Loader qw/ make_schema_at /;
use Getopt::Long;

my $path = "./";
GetOptions(
    "path=s" => \$path,
    );
my $context = new C4::Context;
my $db_driver;
if ($context->config("db_scheme")){
    $db_driver=C4::Context->db_scheme2dbi($context->config("db_scheme"));
}else{
    $db_driver="mysql";
}


my $db_name   = $context->config("database");
my $db_host   = $context->config("hostname");
my $db_port   = $context->config("port") || '';
my $db_user   = $context->config("user");
my $db_passwd = $context->config("pass");

make_schema_at("Koha::Schema", {debug => 1, dump_directory => $path}, ["DBI:$db_driver:dbname=$db_name;host=$db_host;port=$db_port",$db_user, $db_passwd ]);
