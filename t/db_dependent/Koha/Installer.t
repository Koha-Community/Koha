#!/usr/bin/perl

# This file is part of Koha
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

use Test::More tests => 1;

use C4::Context;
use Koha::Database;
use Koha::Installer;

use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;

subtest 'check_db_row_format() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $dbh = C4::Context->dbh;
    $dbh->do("ALTER TABLE tags row_format=COMPACT;");

    my $pos_result = Koha::Installer->check_db_row_format;
    is($pos_result->{count},1,"Detected problem table");

    $dbh->do("ALTER TABLE tags row_format=DYNAMIC;");

    my $neg_result = Koha::Installer->check_db_row_format;
    is($neg_result->{count},undef,"Detected no problem tables");

    $schema->storage->txn_rollback;
};
