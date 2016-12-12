#!/usr/bin/perl

use Modern::Perl;
use Test::More;

use C4::KohaSuomi::DebianPackages;

#Start testing if we extracted the files we need correctly.
my $packageNames = C4::KohaSuomi::DebianPackages::getDebianPackageNames();

subtest "Are the starting and ending results what we expect", sub {
    is($packageNames->[0], 'libalgorithm-checkdigits-perl');
    is($packageNames->[1], 'libanyevent-http-perl');
    is($packageNames->[-2], 'xmlstarlet');
    is($packageNames->[-1], 'yaz');
};

subtest "Unwanted packages excluded", sub {
    foreach my $unwantedPackageName (@{C4::KohaSuomi::DebianPackages::getPackageRegexps('exclude', 'Standalone')}) {
        my $found = 0;
        foreach my $packName (@$packageNames) {
            $found = 1 if $packName =~ /^$unwantedPackageName$/i;
        }
        ok(not($found), "$unwantedPackageName");
    }
};

subtest "Drop package references to other virtual packages", sub {
    my $found = 0;
    foreach my $packName (@$packageNames) {
        $found = 1 if $packName =~ /(?:misc:Depends)|(?:\$)/i;
    }
    ok(not($found), "Virtual packages dropped");
};

subtest "Drop package source references (or whatever these 'libtest-simple-perl|perl-modules' are?)", sub {
    my $found = 0;
    foreach my $packName (@$packageNames) {
        $found = 1 if $packName =~ /\|/i;
        $found = 1 if $packName =~ /libtest-simple-perl\|perl-modules/i;
    }
    ok(not($found), "Source references dropped");
};

subtest "Drop package version specifiers", sub {
    my $found = 0;
    foreach my $packName (@$packageNames) {
        $found = $packName if $packName =~ /\(/i;
        $found = $packName if $packName =~ /libswagger2-perl\(>=\d.\d+\)/i;
    }
    ok(not($found), "Package version specifiers dropped") if not($found);
    ok(not($found), "Package version specifier not dropped for package '$found'") if $found;
};

my $ubuntu1604Packages = C4::KohaSuomi::DebianPackages::getUbuntu1604PackageNames();
subtest "Drop packages not available in Ubuntu16.04", sub {
    foreach my $unwantedPackageName (@{C4::KohaSuomi::DebianPackages::getPackageRegexps('exclude', 'Ubuntu1604')}) {
        my $found = 0;
        foreach my $packName (@$ubuntu1604Packages) {
            $found = 1 if $packName =~ /^$unwantedPackageName$/i;
        }
        ok(not($found), "$unwantedPackageName");
    }
};

subtest "Include packages required in Ubuntu16.04", sub {
    foreach my $wantedPackName (@{C4::KohaSuomi::DebianPackages::getPackageRegexps('include', 'Ubuntu1604')}) {
        my $found = 0;
        foreach my $packName (@$ubuntu1604Packages) {
            $found = 1 if $packName =~ /^$wantedPackName$/i;
        }
        ok($found, "$wantedPackName");
    }
};


my $ksPackageNames = C4::KohaSuomi::DebianPackages::getKohaSuomiDebianPackageNames();
subtest "KohaSuomi specific debian packages discovered", sub {
    #These are discovered
    foreach my $ksPackName (qw(nano curl)) {
        my $found = 0;
        foreach my $packName (@$ksPackageNames) {
            $found = 1 if $packName =~ /^$ksPackName$/i;
        }
        ok($found, "$ksPackName discovered");
    }
    #These must no be discovered
    foreach my $ksPackName (qw(.README)) {
        my $found = 0;
        foreach my $packName (@$ksPackageNames) {
            $found = 1 if $packName =~ /^$ksPackName$/i;
        }
        ok(not($found), "$ksPackName not discovered");
    }
};
