#!/usr/bin/perl

# Tests for C4::Members::GetUpcomingMembershipExpires

# This file is part of Koha.
#
# Copyright 2015 Biblibre
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

use Test::MockModule;
use Test::More tests => 6;

use C4::Members qw|GetUpcomingMembershipExpires|;
use Koha::Database;
use t::lib::TestBuilder;
use t::lib::Mocks qw( mock_preference );

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $date_time = new Test::MockModule('DateTime');
$date_time->mock(
    'now', sub {
        return DateTime->new(
            year      => 2015,
            month     => 6,
            day       => 15,
        );
});

t::lib::Mocks::mock_preference( 'MembershipExpiryDaysNotice', 15 );

my $builder = t::lib::TestBuilder->new();
$builder->build({
    source => 'Category',
    value  => {
        categorycode            => 'AD',
        description             => 'Adult',
        enrolmentperiod         => 18,
        upperagelimit           => 99,
        category_type           => 'A',
    },
});

my $branch = $builder->build({
    source => 'Branch',
    value  => {
        branchname              => 'My branch',
    },
});
my $branchcode = $branch->{branchcode};
# before we add borrowers to this branch, add the expires we have now
# note that this pertains to the current mocked setting of the pref
# for this reason we add the new branchcode to most of the tests
my $expires = scalar @{ GetUpcomingMembershipExpires() };

$builder->build({
    source => 'Borrower',
    value  => {
        firstname               => 'Vincent',
        surname                 => 'Martin',
        cardnumber              => '80808081',
        categorycode            => 'AD',
        branchcode              => $branchcode,
        dateexpiry              => '2015-06-30'
    },
});

$builder->build({
    source => 'Borrower',
    value  => {
        firstname               => 'Claude',
        surname                 => 'Dupont',
        cardnumber              => '80808082',
        categorycode            => 'AD',
        branchcode              => $branchcode,
        dateexpiry              => '2015-06-29'
    },
});

$builder->build({
    source => 'Borrower',
    value  => {
        firstname               => 'Gilles',
        surname                 => 'Dupond',
        cardnumber              => '80808083',
        categorycode            => 'AD',
        branchcode              => $branchcode,
        dateexpiry              => '2015-07-02'
    },
});

# Test without extra parameters
my $upcoming_mem_expires = GetUpcomingMembershipExpires();
is( scalar(@$upcoming_mem_expires), $expires + 1, 'Get upcoming membership expires should return one new borrower.' );

# Test with branch
$upcoming_mem_expires = GetUpcomingMembershipExpires({ branch => $branchcode });
is( @$upcoming_mem_expires==1 && $upcoming_mem_expires->[0]{surname} eq 'Martin',1 , 'Get upcoming membership expires should return borrower "Martin".' );

# Test MembershipExpiryDaysNotice == 0
t::lib::Mocks::mock_preference( 'MembershipExpiryDaysNotice', 0 );
$upcoming_mem_expires = GetUpcomingMembershipExpires({ branch => $branchcode });
is( scalar(@$upcoming_mem_expires), 0, 'Get upcoming membership expires with MembershipExpiryDaysNotice==0 should not return new records.' );

# Test MembershipExpiryDaysNotice == undef
t::lib::Mocks::mock_preference( 'MembershipExpiryDaysNotice', undef );
$upcoming_mem_expires = GetUpcomingMembershipExpires({ branch => $branchcode });
is( scalar(@$upcoming_mem_expires), 0, 'Get upcoming membership expires without MembershipExpiryDaysNotice should not return new records.' );

# Test the before parameter
t::lib::Mocks::mock_preference( 'MembershipExpiryDaysNotice', 15 );
$upcoming_mem_expires = GetUpcomingMembershipExpires({ branch => $branchcode, before => 1 });
# Expect 29/6 and 30/6
is( scalar(@$upcoming_mem_expires), 2, 'Expect two results for before==1');
# Test after parameter also
$upcoming_mem_expires = GetUpcomingMembershipExpires({ branch => $branchcode, before => 1, after => 2 });
# Expect 29/6, 30/6 and 2/7
is( scalar(@$upcoming_mem_expires), 3, 'Expect three results when adding after' );

# End
$schema->storage->txn_rollback;
