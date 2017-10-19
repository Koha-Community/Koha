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

my $library = $builder->build({ source => 'Branch' });
my $categorycode = $builder->build({ source => 'Category' })->{ categorycode };

C4::Context->_new_userenv('xxx');
C4::Context->set_userenv(0,0,0,'firstname','surname', $library->{branchcode}, $library->{branchname}, '', '', '');

my %item_branch_infos = (
    homebranch => $library->{branchcode},
    holdingbranch => $library->{branchcode},
);

my $borrowernumber = AddMember( categorycode => $categorycode, branchcode => $library->{branchcode} );
my $patron_category = $builder->build({ source => 'Category', value => { categorycode => 'NOT_X', category_type => 'P', enrolmentfee => 0 } });
    my $patron = $builder->build({ source => 'Borrower', value => { branchcode => $library->{branchcode}, categorycode => $patron_category->{categorycode} } } );

my $biblioitem = $builder->build( { source => 'Biblioitem' } );
my $item = $builder->build(
    {
        source => 'Item',
        value  => {
            homebranch    => $library->{branchcode},
            holdingbranch => $library->{branchcode},
            notforloan    => 0,
            itemlost      => 0,
            withdrawn     => 0,
            biblionumber  => $biblioitem->{biblionumber},
        }
    }
);
C4::Circulation::AddIssue( $patron, $item->{barcode} );

eval { C4::Circulation::MarkIssueReturned( $borrowernumber, $item->{itemnumber}, 'dropbox_branch', 'returndate', 2 ) };
like ( $@, qr<Fatal error: the patron \(\d+\) .* AnonymousPatron>, );

my $anonymous_borrowernumber = AddMember( categorycode => $categorycode, branchcode => $library->{branchcode} );
t::lib::Mocks::mock_preference('AnonymousPatron', $anonymous_borrowernumber);
# The next call will raise an error, because data are not correctly set
$dbh->{PrintError} = 0;
eval { C4::Circulation::MarkIssueReturned( $borrowernumber, 'itemnumber', 'dropbox_branch', 'returndate', 2 ) };
unlike ( $@, qr<Fatal error: the patron \(\d+\) .* AnonymousPatron>, );

$schema->storage->txn_rollback;

