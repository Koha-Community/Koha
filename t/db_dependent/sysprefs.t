#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright (C) 2012 BibLibre SARL
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
use Test::More tests => 3;
use C4::Context;

# Start transaction
my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;
$dbh->{AutoCommit} = 0;

my $opacheader = C4::Context->preference('opacheader');
my $newopacheader = "newopacheader";

C4::Context->set_preference('OPACHEADER', $newopacheader);
ok(C4::Context->preference('opacheader') eq $newopacheader);

C4::Context->set_preference('opacheader', $opacheader);
ok(C4::Context->preference('OPACHEADER') eq $opacheader);

$ENV{OVERRIDE_SYSPREF_opacheader} = 'this is an override';
C4::Context->clear_syspref_cache();
is(C4::Context->preference('opacheader'),
   'this is an override',
   'system preference value overridden from environment'
);

$dbh->rollback;
