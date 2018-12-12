#!/usr/bin/perl
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

use Test::More tests => 3;

use_ok('Koha::BiblioUtils');
use_ok('Koha::BiblioUtils::Iterator');

use C4::Items;
use C4::Biblio;
use DBI;
use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema = Koha::Database->new()->schema();
$schema->storage->txn_begin();

# Delete issues to prevent foreign constraint failures.
# blank all biblios, biblioitems, and items.
$schema->resultset('Issue')->delete();
$schema->resultset('Biblio')->delete();

my $location = 'My Location';
my $builder = t::lib::TestBuilder->new;
my $library = $builder->build({
    source => 'Branch',
});
my $itemtype = $builder->build({
   source => 'Itemtype',
});

# Create a biblio instance for testing
t::lib::Mocks::mock_preference('marcflavour', 'MARC21');
my $biblio = $builder->build_sample_biblio();

# Add an item.
my ($item_bibnum, $item_bibitemnum, $itemnumber) = AddItem({ homebranch => $library->{branchcode}, holdingbranch => $library->{branchcode}, location => $location, itype => $itemtype->{itemtype} } , $biblio->biblionumber);

my $rs = $schema->resultset('Biblioitem')->search({});
my $iterator = Koha::BiblioUtils::Iterator->new($rs, items => 1 );
my $record = $iterator->next();
my $expected_tags = [ 100, 245, 942, 952, 999 ];
my @result_tags = map { $_->tag() } $record->field('...');
my @sorted_tags = sort @result_tags;
is_deeply(\@sorted_tags,$expected_tags, "Got the same tags as expected");

$schema->storage->txn_rollback();
