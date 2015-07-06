#!/usr/bin/env perl

# Copyright 2015 Open Source Freedom Fighters
#
# This file is part of Koha.
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

use Test::More; #Please don't set the test count here. It is nothing but trouble when rebasing against master
                #and is of dubious help, especially since we are running dynamic tests here which are triggered
                #based on the reported test infrastucture capabilities.
use Try::Tiny; #Even Selenium::Remote::Driver uses Try::Tiny :)
use Scalar::Util qw(blessed);

use t::lib::WebDriverFactory;


my $testingModules = {  firefox => {version => '39.0', platform => 'LINUX'},
                        phantomjs => {},
                        mojolicious => {version => 'V1'},
                    };

foreach my $name (keys %$testingModules) {
    try {
        my $conf = $testingModules->{$name};
        my ($webDriver) = t::lib::WebDriverFactory::getUserAgentDrivers({$name => $conf});
        ok(blessed($webDriver), "'$name' WebDriver/UserAgent capability.");
    } catch {
        if ($_ =~ /is not an executable file/) {
            print "$name-driver is not installed. See Selenium::$name for installation instructions.\n";
        }
        else {
            print "$name-driver not operational.\n";
        }
    };
}

done_testing;