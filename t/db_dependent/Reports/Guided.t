# Copyright 2012 Catalyst IT Ltd.
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

use strict;
use warnings;

use Test::More tests => 19;                      # last test to print

use_ok('C4::Reports::Guided');

# This is the query I found that triggered bug 8594.
my $sql = "SELECT aqorders.ordernumber, biblio.title, biblio.biblionumber, items.homebranch,
    aqorders.entrydate, aqorders.datereceived,
    (SELECT DATE(datetime) FROM statistics
        WHERE itemnumber=items.itemnumber AND
            (type='return' OR type='issue') LIMIT 1)
    AS shelvedate,
    DATEDIFF(COALESCE(
        (SELECT DATE(datetime) FROM statistics
            WHERE itemnumber=items.itemnumber AND
            (type='return' OR type='issue') LIMIT 1),
    aqorders.datereceived), aqorders.entrydate) AS totaldays
FROM aqorders
LEFT JOIN biblio USING (biblionumber)
LEFT JOIN items ON (items.biblionumber = biblio.biblionumber
    AND dateaccessioned=aqorders.datereceived)
WHERE (entrydate >= '2011-01-01' AND (datereceived < '2011-02-01' OR datereceived IS NULL))
    AND items.homebranch LIKE 'INFO'
ORDER BY title";

my ($res_sql, $res_lim1, $res_lim2) = C4::Reports::Guided::strip_limit($sql);
is($res_sql, $sql, "Not breaking subqueries");
is($res_lim1, 0, "Returns correct default offset");
is($res_lim2, undef, "Returns correct default LIMIT");

# Now the same thing, but we want it to remove the LIMIT from the end

my $test_sql = $res_sql . " LIMIT 242";
($res_sql, $res_lim1, $res_lim2) = C4::Reports::Guided::strip_limit($test_sql);
# The replacement drops a ' ' where the limit was
is(trim($res_sql), $sql, "Correctly removes only final LIMIT");
is($res_lim1, 0, "Returns correct default offset");
is($res_lim2, 242, "Returns correct extracted LIMIT");

$test_sql = $res_sql . " LIMIT 13,242";
($res_sql, $res_lim1, $res_lim2) = C4::Reports::Guided::strip_limit($test_sql);
# The replacement drops a ' ' where the limit was
is(trim($res_sql), $sql, "Correctly removes only final LIMIT (with offset)");
is($res_lim1, 13, "Returns correct extracted offset");
is($res_lim2, 242, "Returns correct extracted LIMIT");

# After here is the simpler case, where there isn't a WHERE clause to worry
# about.

# First case with nothing to change
$sql = "SELECT * FROM items";
($res_sql, $res_lim1, $res_lim2) = C4::Reports::Guided::strip_limit($sql);
is($res_sql, $sql, "Not breaking simple queries");
is($res_lim1, 0, "Returns correct default offset");
is($res_lim2, undef, "Returns correct default LIMIT");

$test_sql = $sql . " LIMIT 242";
($res_sql, $res_lim1, $res_lim2) = C4::Reports::Guided::strip_limit($test_sql);
is(trim($res_sql), $sql, "Correctly removes LIMIT in simple case");
is($res_lim1, 0, "Returns correct default offset");
is($res_lim2, 242, "Returns correct extracted LIMIT");

$test_sql = $sql . " LIMIT 13,242";
($res_sql, $res_lim1, $res_lim2) = C4::Reports::Guided::strip_limit($test_sql);
is(trim($res_sql), $sql, "Correctly removes LIMIT in simple case (with offset)");
is($res_lim1, 13, "Returns correct extracted offset");
is($res_lim2, 242, "Returns correct extracted LIMIT");

sub trim {
    my ($s) = @_;
    $s =~ s/^\s*(.*?)\s*$/$1/s;
    return $s;
}
