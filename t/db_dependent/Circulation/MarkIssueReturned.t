#!/usr/bin/perl

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

use Test::More tests => 2;
use Test::Warn;

use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Circulation;
use C4::Members;
use Koha::Library;

my $schema = Koha::Database->schema;
my $dbh = C4::Context->dbh;

$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference('AnonymousPatron', '');

my $branchcode = $builder->build({ source => 'Branch' })->{ branchcode };
my $categorycode = $builder->build({ source => 'Category' })->{ categorycode };

my %item_branch_infos = (
    homebranch => $branchcode,
    holdingbranch => $branchcode,
);

my $borrowernumber = AddMember( categorycode => $categorycode, branchcode => $branchcode );

eval { C4::Circulation::MarkIssueReturned( $borrowernumber, 'itemnumber', 'dropbox_branch', 'returndate', 2 ) };
like ( $@, qr<Fatal error: the patron \(\d+\) .* AnonymousPatron>, );

my $anonymous_borrowernumber = AddMember( categorycode => $categorycode, branchcode => $branchcode );
t::lib::Mocks::mock_preference('AnonymousPatron', $anonymous_borrowernumber);
# The next call will raise an error, because data are not correctly set
$dbh->{PrintError} = 0;
eval { C4::Circulation::MarkIssueReturned( $borrowernumber, 'itemnumber', 'dropbox_branch', 'returndate', 2 ) };
unlike ( $@, qr<Fatal error: the patron \(\d+\) .* AnonymousPatron>, );

$schema->storage->txn_rollback;

1;
