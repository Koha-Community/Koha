#!/usr/bin/perl

# Copyright Biblibre 2012
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use C4::Context;
use C4::Update::Database;
use Getopt::Long;

my $help;
my $version;
my $list;
my $all;
my $min;

GetOptions(
    'h|help|?' => \$help,
    'm:s'      => \$version,
    'l|list'   => \$list,
    'a|all'    => \$all,
    'min:s'    => \$min,
);

if ( $help or not( $version or $list or $all ) ) {
    usage();
    exit;
}

my @reports;
if ($version) {
    my $report = C4::Update::Database::execute_version($version);
    push @reports, $report;
}

if ($list) {
    my $available       = C4::Update::Database::list_versions_available();
    my $already_applied = C4::Update::Database::list_versions_already_applied();
    say "Versions available:";
    for my $v (@$available) {
        if ( not grep { $v eq $_->{version} } @$already_applied ) {
            say "\t- $_" for $v;
        }
    }
    say "Versions already applied:";
    say "\t- $_->{version}" for @$already_applied;

}

if ($all) {
    my $versions_available = C4::Update::Database::list_versions_available();
    my $versions = C4::Update::Database::list_versions_already_applied;
    my $min_version =
        $min
      ? $min =~ m/\d\.\d{2}\.\d{2}\.\d{3}/
          ? C4::Update::Database::TransformToNum($min)
          : $min
      : 0;

    for my $v (@$versions_available) {
        # We execute ALL versions where version number >= min_version
        # OR version is not a number
        if ( not grep { $v eq $_->{version} } @$versions
            and ( not $v =~ /\d\.\d{2}\.\d{2}\.\d{3}/ or
                C4::Update::Database::TransformToNum($v) >= $min_version ) )
        {
            my $report = C4::Update::Database::execute_version $v;
            push @reports, $report;
        }
    }
}

if ( $version or $all ) {
    say @reports ? "Report:" : "Nothing to report";
    for my $report (@reports) {
        my ( $v, $r ) = each %$report;
        if ( ref($r) eq 'HASH' ) {
            say "\t$v => $r->{error}";
        }
        elsif ( ref($r) eq 'ARRAY' ) {
            say "\t$_" for @$r;
        }
        else {
            say "\t$v => $r";
        }
    }
}

sub usage {
    say "update.pl";
    say "This script updates your database for you";
    say "Usage:";
    say "\t-h\tShow this help message";
    say "\t-m\tExecute a given version";
    say "\t-l\tList all the versions";
    say "\t-all\tExecute all available versions";
    say
      "\t-min\tWith -all, Execute all available versions since a given version";
    say "\t\tCan be X.XX.XX.XXX or X.XXXXXXX";
}
