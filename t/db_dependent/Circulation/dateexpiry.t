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

use DateTime;
use Time::HiRes qw/gettimeofday time/;
use Test::More tests => 2;
use C4::Members;
use Koha::DateUtils;
use Koha::Database;

use t::lib::TestBuilder;
use t::lib::Mocks qw( mock_preference );

my $schema  = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new();

$ENV{ DEBUG } = 0;

my $patron_category = $builder->build({ source => 'Category', value => { category_type => 'P', enrolmentfee => 0 } });

subtest 'Tests for CanBookBeIssued related to dateexpiry' => sub {
    plan tests => 4;
    can_book_be_issued();
};
subtest 'Tests for CalcDateDue related to dateexpiry' => sub {
    plan tests => 4;
    calc_date_due();
};

sub can_book_be_issued {
    my $item    = $builder->build( { source => 'Item' } );
    my $patron  = $builder->build_object(
        {   class  => 'Koha::Patrons',
            value  => {
                dateexpiry => '9999-12-31',
                categorycode => $patron_category->{categorycode},
            }
        }
    );
    my $duration = gettimeofday();
    my ( $issuingimpossible, $needsconfirmation ) = C4::Circulation::CanBookBeIssued( $patron, $item->{barcode} );
    $duration = gettimeofday() - $duration;
    cmp_ok $duration, '<', 1, "CanBookBeIssued should not be take more than 1s if the patron is expired";
    is( not( exists $issuingimpossible->{EXPIRED} ), 1, 'The patron should not be considered as expired if dateexpiry is 9999-*' );

    $item = $builder->build( { source => 'Item' } );
    $patron = $builder->build_object(
        {   class  => 'Koha::Patrons',
            value  => {
                dateexpiry => undef,
                categorycode => $patron_category->{categorycode},
            }
        }
    );
    ( $issuingimpossible, $needsconfirmation ) = C4::Circulation::CanBookBeIssued( $patron, $item->{barcode} );
    is( not( exists $issuingimpossible->{EXPIRED} ), 1, 'The patron should not be considered as expired if dateexpiry is not set' );

    my $tomorrow = dt_from_string->add_duration( DateTime::Duration->new( days => 1 ) );
    $item = $builder->build( { source => 'Item' } );
    $patron = $builder->build_object(
        {   class  => 'Koha::Patrons',
            value  => {
                dateexpiry => output_pref( { dt => $tomorrow, dateonly => 1, dateformat => 'sql' } ),
                categorycode => $patron_category->{categorycode},
            },
        }
    );
    ( $issuingimpossible, $needsconfirmation ) = C4::Circulation::CanBookBeIssued( $patron, $item->{barcode} );
    is( not( exists $issuingimpossible->{EXPIRED} ), 1, 'The patron should not be considered as expired if dateexpiry is tomorrow' );

}

sub calc_date_due {
    t::lib::Mocks::mock_preference( 'ReturnBeforeExpiry', 1 );

    # this triggers the compare between expiry and due date

    my $patron = $builder->build({
        source => 'Borrower',
        value  => {
            categorycode => $patron_category->{categorycode},
        }
    });
    my $item   = $builder->build( { source => 'Item' } );
    my $branch = $builder->build( { source => 'Branch' } );
    my $today  = dt_from_string();

    # first test with empty expiry date
    # note that this expiry date will never lead to an issue btw !!
    $patron->{dateexpiry} = '0000-00-00';
    my $d = C4::Circulation::CalcDateDue( $today, $item->{itype}, $branch->{branchcode}, $patron );
    is( ref $d eq "DateTime" && $d->mdy() =~ /^\d+/, 1, "CalcDateDue with expiry 0000-00-00" );

    # second test expiry date==today
    my $d2 = output_pref( { dt => $today, dateonly => 1, dateformat => 'sql' } );
    $patron->{dateexpiry} = $d2;
    $d = C4::Circulation::CalcDateDue( $today, $item->{itype}, $branch->{branchcode}, $patron );
    is( ref $d eq "DateTime" && DateTime->compare( $d->truncate( to => 'day' ), $today->truncate( to => 'day' ) ) == 0, 1, "CalcDateDue with expiry today" );

    # third test expiry date tomorrow
    my $dur = DateTime::Duration->new( days => 1 );
    my $tomorrow = $today->clone->add_duration($dur);
    $d2 = output_pref( { dt => $tomorrow, dateonly => 1, dateformat => 'sql' } );
    $patron->{dateexpiry} = $d2;
    $d = C4::Circulation::CalcDateDue( $today, $item->{itype}, $branch->{branchcode}, $patron );
    is( ref $d eq "DateTime" && $d->mdy() =~ /^\d+/, 1, "CalcDateDue with expiry tomorrow" );

    # fourth test far future
    $patron->{dateexpiry} = '9876-12-31';
    my $t1 = time;
    $d = C4::Circulation::CalcDateDue( $today, $item->{itype}, $branch->{branchcode}, $patron );
    my $t2 = time;
    is( ref $d eq "DateTime" && $t2 - $t1 < 1, 1, "CalcDateDue with expiry in year 9876 in " . sprintf( "%6.4f", $t2 - $t1 ) . " seconds." );
}

$schema->storage->txn_rollback;

