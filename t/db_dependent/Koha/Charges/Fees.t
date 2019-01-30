#!/usr/bin/perl
#
# Copyright 2018 ByWater Solutions
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

use Test::More tests => 2;

use t::lib::Mocks;
use t::lib::TestBuilder;

use Data::Dumper;

use C4::Calendar;
use Koha::DateUtils qw(dt_from_string);

BEGIN {
    use_ok('Koha::Charges::Fees');
}

my $builder = t::lib::TestBuilder->new();

my $patron_category = $builder->build_object(
    {
        class => 'Koha::Patron::Categories',
        value => {
            category_type => 'P',
            enrolmentfee  => 0,
        }
    }
);
my $library = $builder->build_object(
    {
        class => 'Koha::Libraries',
    }
);
my $biblio = $builder->build_object(
    {
        class => 'Koha::Biblios',
    }
);
my $itemtype = $builder->build_object(
    {
        class => 'Koha::ItemTypes',
        value => {
            rentalcharge_daily => '0.00',
            rentalcharge        => '0.00',
            processfee          => '0.00',
            defaultreplacecost  => '0.00',
        },
    }
);
my $item = $builder->build_object(
    {
        class => 'Koha::Items',
        value => {
            biblionumber  => $biblio->id,
            homebranch    => $library->id,
            holdingbranch => $library->id,
            itype         => $itemtype->id,
        }
    }
);
my $patron = $builder->build_object(
    {
        class => 'Koha::Patrons',
        value => {
            dateexpiry   => '9999-12-31',
            categorycode => $patron_category->id,
        }
    }
);

my $dt_from = dt_from_string();
my $dt_to = dt_from_string()->add( days => 6 );

my $fees = Koha::Charges::Fees->new(
    {
        patron    => $patron,
        library   => $library,
        item      => $item,
        to_date   => $dt_to,
        from_date => $dt_from,
    }
);

subtest 'accumulate_rentalcharge tests' => sub {
    plan tests => 4;

    $itemtype->rentalcharge_daily(1.00);
    $itemtype->store();
    is( $itemtype->rentalcharge_daily,
        1.00, 'Daily return charge stored correctly' );

    t::lib::Mocks::mock_preference( 'finesCalendar', 'ignoreCalendar' );
    my $charge = $fees->accumulate_rentalcharge();
    is( $charge, 6.00, 'Daily rental charge calculated correctly with finesCalendar = ignoreCalendar' );

    t::lib::Mocks::mock_preference( 'finesCalendar', 'noFinesWhenClosed' );
    $charge = $fees->accumulate_rentalcharge();
    is( $charge, 6.00, 'Daily rental charge calculated correctly with finesCalendar = noFinesWhenClosed' );

    my $calendar = C4::Calendar->new( branchcode => $library->id );
    $calendar->insert_week_day_holiday(
        weekday     => 3,
        title       => 'Test holiday',
        description => 'Test holiday'
    );
    $charge = $fees->accumulate_rentalcharge();
    is( $charge, 5.00, 'Daily rental charge calculated correctly with finesCalendar = noFinesWhenClosed and closed Wednesdays' );
};
