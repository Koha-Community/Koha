# Copyright 2016 KohaSuomi
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
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
use C4::Search;
use Test::More;

use t::db_dependent::Matcher::testRecords;
use t::db_dependent::Matcher::matchers;

my $testContext = {};

my $matcher = t::db_dependent::Matcher::matchers::create($testContext)->{'001'};


subtest "Merge matched records", \&mergeMatchedRecords;
sub mergeMatchedRecords {
    my ($localRecords, $error, $marcresults, $total_hits, $output, $r);
    my $subtestContext = {};
    eval {
    $localRecords = t::db_dependent::Matcher::testRecords::create($subtestContext);
    $output = `$ENV{KOHA_PATH}/misc/migration_tools/rebuild_zebra.pl -b -a -r -x`;

    ( $error, $marcresults, $total_hits ) = C4::Search::SimpleSearch("Control-number=duplicate");
    is(scalar(@$marcresults), 4,
       'Search Control-number=duplicate returned 4 results');
    ok($marcresults->[0] =~ /Old school song/,
       'Got the correct records');

    ##Start deduplicating from the first created biblio. Excpecting to find 3 duplicates and merge them all.
    system($ENV{KOHA_PATH}."/misc/maintenance/deduplicator.pl", "--matcher", $matcher->_id(), "-M", "newest", "--biblionumber", $localRecords->{isbn1}->{biblionumber}, '--max-matches', 10);

    $r = C4::Biblio::GetBiblio(  $localRecords->{isbn1}->{biblionumber}  );
    is($r, undef, "First duplicate 'isbn1' deleted");
    $r = C4::Biblio::GetBiblio(  $localRecords->{isbn2}->{biblionumber}  );
    is($r, undef, "Second duplicate 'isbn2' deleted");
    $r = C4::Biblio::GetBiblio(  $localRecords->{isbn3}->{biblionumber}  );
    ok($r, "Third duplicate 'isbn3' exists");
    is($r->{author}, "Author. Mies", "Third record is the newest record.");
    $r = C4::Biblio::GetBiblio(  $localRecords->{isbn4}->{biblionumber}  );
    ok($r, "Fourth record 'isbn4' exists and is not a duplicate");
    is($r->{title}, "Old skoolz", "Fourth record is 'Old skoolz'");
    };
    if ($@) {
        ok(0, $@);
    }

    t::lib::TestObjects::ObjectFactory->tearDownTestContext($subtestContext);
}


t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext);
done_testing();
