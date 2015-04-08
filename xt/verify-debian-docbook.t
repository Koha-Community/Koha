#!/usr/bin/perl

# Copyright (C) 2013 Catalyst IT Ltd.
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

# This runs 'xmllint' (part of libxml2-utils) over each xml file that
# generates the koha-common man pages and ensures they're correct.

use strict;
use warnings;

use Test::More qw(no_plan);

my $doc_dir = 'debian/docs';
my @doc_files = glob($doc_dir . '/*.xml');
my @command = qw(xmllint --noout);

foreach my $file (@doc_files) {
    ok(system(@command, $file) == 0, "XML validation for $file");
}
