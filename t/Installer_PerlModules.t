#!/usr/bin/perl
#
# This Koha test module is a stub!
# Add more tests here!!!

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 4;
use Test::Warn;

BEGIN {
    use_ok('C4::Installer::PerlModules');
}

subtest 'prereq_pm' => sub {
    my $modules;
    ok( $modules = C4::Installer::PerlModules->new(), 'Tests modules object' );
    my $prereq_pm = $modules->prereq_pm();
    ok( exists( $prereq_pm->{"DBI"} ),      'DBI required for installer to run' );
    ok( exists( $prereq_pm->{"CGI"} ),      'CGI required for installer to run' );
    ok( exists( $prereq_pm->{"YAML::XS"} ), 'YAML::XS required for installer to run' );
};

subtest 'versions_info' => sub {
    plan tests => 5;
    my $modules = C4::Installer::PerlModules->new;
    warning_is { $modules->versions_info } undef, 'No warnings from versions_info';
    ok( exists $modules->{missing_pm}, 'versions_info fills the missing_pm key' );
    ok( exists $modules->{upgrade_pm}, 'versions_info fills the upgrade_pm key' );
    ok( exists $modules->{current_pm}, 'versions_info fills the current_pm key' );
    my $missing_modules = $modules->get_attr('missing_pm');
    my $upgrade_modules = $modules->get_attr('upgrade_pm');
    my $current_modules = $modules->get_attr('current_pm');
    my $dbi_is_missing  = grep { exists $_->{DBI} ? 1 : () } @$missing_modules;
    my $dbi_is_upgrade  = grep { exists $_->{DBI} ? 1 : () } @$upgrade_modules;
    my $dbi_is_current  = grep { exists $_->{DBI} ? 1 : () } @$current_modules;
    ok( $dbi_is_missing || $dbi_is_upgrade || $dbi_is_current, 'DBI should either be missing, upgrade or current' );
};
