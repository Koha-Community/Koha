#!/usr/bin/perl
#
# This Koha test module is a stub!  
# Add more tests here!!!

use Modern::Perl;

use Test::More tests => 22;

BEGIN {
        use_ok('C4::Installer::PerlModules');
}

$C4::Installer::PerlModules::PERL_DEPS->{'Local::Module::Upgraded'} = {
    'required' => '1',
    'min_ver' => '0.9.3',
    'usage' => "Testing: make sure numbers are compared numerically and not lexicographically",
};
$Local::Module::Upgraded::VERSION = '0.9.13';
$INC{"Local/Module/Upgraded.pm"} = 1;
use_ok("Local::Module::Upgraded");

$C4::Installer::PerlModules::PERL_DEPS->{'Local::Module::NotUpgraded'} = {
    'required' => '1',
    'min_ver' => '0.9.3',
    'usage' => "Testing: make sure numbers are compared numerically and not lexicographically",
};
$Local::Module::NotUpgraded::VERSION = '0.9.1';
$INC{"Local/Module/NotUpgraded.pm"} = 1;
use_ok("Local::Module::NotUpgraded");

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
my $version_info = $modules->version_info('DBI');
ok (exists($version_info->{"required"}), 'required exists');
ok (exists($version_info->{"upgrade"}), 'upgrade exists');
is ($modules->version_info("thisdoesn'texist"),-1, 'thisdoesntexist should return -1');
ok ($modules->module_count() >10 , 'count should be greater than 10');
my @module_list = $modules->module_list;
%params = map { $_ => 1 } @module_list;
ok (exists($params{"DBI"}), 'DBI exists in array');
is ($modules->required('module'=>"String::Random"),1, 'String::Random should return 1 since required');
is ($modules->version_info(), -1, "Testing empty modules");

is($modules->version_info("Local::Module::Upgraded")->{"upgrade"},0,"Version 0.9.13 is greater than 0.9.3, so no upgrade needed");
is($modules->version_info("Local::Module::NotUpgraded")->{"upgrade"},1,"Version 0.9.1 is smaller than 0.9.1, so no upgrade needed");

subtest 'versions_info' => sub {
    plan tests => 4;
    my $modules = C4::Installer::PerlModules->new;
    $modules->versions_info;
    ok( exists $modules->{missing_pm}, 'versions_info fills the missing_pm key' );
    ok( exists $modules->{upgrade_pm}, 'versions_info fills the upgrade_pm key' );
    ok( exists $modules->{current_pm}, 'versions_info fills the current_pm key' );
    my $missing_modules = $modules->get_attr( 'missing_pm' );
    my $upgrade_modules = $modules->get_attr( 'upgrade_pm' );
    my $current_modules = $modules->get_attr( 'current_pm' );
    my $dbi_is_missing = grep { exists $_->{DBI} ? 1 : () } @$missing_modules;
    my $dbi_is_upgrade = grep { exists $_->{DBI} ? 1 : () } @$upgrade_modules;
    my $dbi_is_current = grep { exists $_->{DBI} ? 1 : () } @$current_modules;
    ok( $dbi_is_missing || $dbi_is_upgrade || $dbi_is_current, 'DBI should either be missing, upgrade or current' );
};
