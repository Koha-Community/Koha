#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright 2013 Equinox Software, Inc.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 6;

use C4::Context;
use_ok('C4::Search', qw/AddSearchHistory PurgeSearchHistory/); # GetSearchHistory is not exported

# Start transaction
my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

# start with a clean slate
$dbh->do('DELETE FROM search_history');
is(_get_history_count(), 0, 'starting off with nothing in search_history');

# Add some history rows.  Note that we're ignoring the return value;
# since the search_history table doesn't have an auto_increment
# column, it appears that the value of $dbh->last_insert_id() is
# useless for determining if the insert failed.
AddSearchHistory(12345, 'session_1', 'query_desc_1', 'query_cgi_1', 5);
AddSearchHistory(12345, 'session_1', 'query_desc_2', 'query_cgi_2', 6);
AddSearchHistory(12345, 'session_1', 'query_desc_3', 'query_cgi_3', 7);
AddSearchHistory(56789, 'session_2', 'query_desc_4', 'query_cgi_4', 8);
is(_get_history_count(), 4, 'successfully added four search_history rows');

# We're not testing GetSearchHistory at present because it is broken...
# see bug 10677

# munge some dates
my $sth = $dbh->prepare('
    UPDATE search_history
    SET time = DATE_SUB(time, INTERVAL ? DAY)
    WHERE query_desc = ?
');
$sth->execute(46, 'query_desc_1');
$sth->execute(31, 'query_desc_2');

PurgeSearchHistory(45);
is(_get_history_count(), 3, 'purged history older than 45 days');
PurgeSearchHistory(30);
is(_get_history_count(), 2, 'purged history older than 30 days');
PurgeSearchHistory(-1);
is(_get_history_count(), 0, 'purged all history');

sub _get_history_count {
    my $count_sth = $dbh->prepare('SELECT COUNT(*) FROM search_history');
    $count_sth->execute();
    my $count = $count_sth->fetchall_arrayref();
    return $count->[0]->[0];
}

$dbh->rollback;
