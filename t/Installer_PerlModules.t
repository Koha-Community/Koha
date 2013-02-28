#!/usr/bin/perl
#
# This Koha test module is a stub!  
# Add more tests here!!!

use strict;
use warnings;

use Test::More tests => 16;

BEGIN {
        use_ok('C4::Installer::PerlModules');
}

my $modules;
ok ($modules = C4::Installer::PerlModules->new(), 'Tests modules object');
my $prereq_pm = $modules->prereq_pm();
ok (exists($prereq_pm->{"DBI"}), 'DBI required for installer to run');
ok (exists($prereq_pm->{"CGI"}), 'CGI required for installer to run' );
ok (exists($prereq_pm->{"YAML"}), 'YAML required for installer to run');
is ($modules->required('module'=>"DBI"),1, 'DBI should return 1 since required');
is ($modules->required('module'=>"thisdoesn'texist"),-1, 'string should return -1 since not in hash');
my $required = $modules->required('required'=>1);
my %params = map { $_ => 1 } @$required;
ok (exists($params{"DBI"}), 'DBI required for installer to run');
my $optional = $modules->required('optional'=>1);
%params = map { $_ => 1 } @$optional;
ok (exists($params{"Test::Strict"}), 'test::strict optional for installer to run');
is ($optional = $modules->required('spaghetti'=>1),-1, '-1 returned when parsing in unknown parameter');
my $version_info = $modules->version_info('module'=>"DBI");
ok (exists($version_info->{'DBI'}->{"required"}), 'required exists');
ok (exists($version_info->{'DBI'}->{"upgrade"}), 'upgrade exists');
is ($modules->version_info('module'=>"thisdoesn'texist"),-1, 'thisdoesntexist should return -1');
ok ($modules->module_count() >10 , 'count should be greater than 10');
my @module_list = $modules->module_list;
%params = map { $_ => 1 } @module_list;
ok (exists($params{"DBI"}), 'DBI exists in array');
is ($modules->required('module'=>"String::Random"),1, 'String::Random should return 1 since required');
