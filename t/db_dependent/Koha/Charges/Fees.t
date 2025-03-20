#!/usr/bin/perl
#
# Copyright 2018 ByWater Solutions
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

use Test::NoWarnings;
use Test::More tests => 9;
use Test::Exception;
use Test::Warn;

use t::lib::Mocks;
use t::lib::TestBuilder;
use t::lib::Dates;

use Time::Fake;
use C4::Calendar    qw( new insert_week_day_holiday delete_holiday );
use Koha::DateUtils qw(dt_from_string);

BEGIN {
    use_ok('Koha::Charges::Fees');
}

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new();
$schema->storage->txn_begin;

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
            rentalcharge_daily           => '0.00',
            rentalcharge_daily_calendar  => 1,
            rentalcharge_hourly          => '0.00',
            rentalcharge_hourly_calendar => 1,
            rentalcharge                 => '0.00',
            processfee                   => '0.00',
            defaultreplacecost           => '0.00',
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

my $now = dt_from_string()->set_time_zone('floating');
Time::Fake->offset( $now->epoch );

my $dt_from = $now->clone->subtract( days => 2 );
my $dt_to   = $now->clone->add( days => 4 );

subtest 'new' => sub {
    plan tests => 9;

    # Mandatory parameters missing
    throws_ok {
        Koha::Charges::Fees->new(
            {
                library => $library,
                item    => $item,
                to_date => $dt_to,
            }
        )
    }
    'Koha::Exceptions::MissingParameter', 'MissingParameter thrown for patron';
    throws_ok {
        Koha::Charges::Fees->new(
            {
                patron  => $patron,
                item    => $item,
                to_date => $dt_to,
            }
        )
    }
    'Koha::Exceptions::MissingParameter', 'MissingParameter thrown for library';
    throws_ok {
        Koha::Charges::Fees->new(
            {
                patron  => $patron,
                library => $library,
                to_date => $dt_to,
            }
        )
    }
    'Koha::Exceptions::MissingParameter', 'MissingParameter thrown for item';
    throws_ok {
        Koha::Charges::Fees->new(
            {
                patron  => $patron,
                library => $library,
                item    => $item,
            }
        )
    }
    'Koha::Exceptions::MissingParameter', 'MissingParameter thrown for to_date';

    # Mandatory parameter bad
    dies_ok {
        Koha::Charges::Fees->new(
            {
                patron  => '12345',
                library => $library,
                item    => $item,
                to_date => $dt_to,
            }
        )
    }
    'dies for bad patron';
    dies_ok {
        Koha::Charges::Fees->new(
            {
                patron  => $patron,
                library => '12345',
                item    => $item,
                to_date => $dt_to,
            }
        )
    }
    'dies for bad library';
    dies_ok {
        Koha::Charges::Fees->new(
            {
                patron  => $patron,
                library => $library,
                item    => '12345',
                to_date => $dt_to,
            }
        )
    }
    'dies for bad item';
    dies_ok {
        Koha::Charges::Fees->new(
            {
                patron  => $patron,
                library => $library,
                item    => $item,
                to_date => 12345
            }
        )
    }
    'dies for bad to_date';

    # Defaults
    my $fees = Koha::Charges::Fees->new(
        {
            patron  => $patron,
            library => $library,
            item    => $item,
            to_date => $dt_to,
        }
    );
    is(
        t::lib::Dates::compare( $fees->from_date, dt_from_string() ), 0,
        'from_date default set correctly to today'
    );
};

subtest 'patron accessor' => sub {
    plan tests => 2;

    my $fees = Koha::Charges::Fees->new(
        {
            patron  => $patron,
            library => $library,
            item    => $item,
            to_date => $dt_to,
        }
    );

    ok(
        $fees->patron->isa('Koha::Patron'),
        'patron accessor returns a Koha::Patron'
    );
    warning_is { $fees->patron('12345') }
    { carped => "Setting 'patron' to something other than a Koha::Patron is not supported!" },
        "Warning thrown when attempting to set patron to string";

};

subtest 'library accessor' => sub {
    plan tests => 2;

    my $fees = Koha::Charges::Fees->new(
        {
            patron  => $patron,
            library => $library,
            item    => $item,
            to_date => $dt_to,
        }
    );

    ok(
        $fees->library->isa('Koha::Library'),
        'library accessor returns a Koha::Library'
    );
    warning_is { $fees->library('12345') }
    { carped => "Setting 'library' to something other than a Koha::Library is not supported!" },
        "Warning thrown when attempting to set library to string";
};

subtest 'item accessor' => sub {
    plan tests => 2;

    my $fees = Koha::Charges::Fees->new(
        {
            patron  => $patron,
            library => $library,
            item    => $item,
            to_date => $dt_to,
        }
    );

    ok( $fees->item->isa('Koha::Item'), 'item accessor returns a Koha::Item' );
    warning_is { $fees->item('12345') }
    { carped => "Setting 'item' to something other than a Koha::Item is not supported!" },
        "Warning thrown when attempting to set item to string";
};

subtest 'to_date accessor' => sub {
    plan tests => 2;

    my $fees = Koha::Charges::Fees->new(
        {
            patron  => $patron,
            library => $library,
            item    => $item,
            to_date => $dt_to,
        }
    );

    ok(
        $fees->to_date->isa('DateTime'),
        'to_date accessor returns a DateTime'
    );
    warning_is { $fees->to_date(12345) }
    { carped => "Setting 'to_date' to something other than a DateTime is not supported!" },
        "Warning thrown when attempting to set to_date to integer";
};

subtest 'from_date accessor' => sub {
    plan tests => 2;

    my $fees = Koha::Charges::Fees->new(
        {
            patron  => $patron,
            library => $library,
            item    => $item,
            to_date => $dt_to,
        }
    );

    ok(
        $fees->from_date->isa('DateTime'),
        'from_date accessor returns a DateTime'
    );
    warning_is { $fees->from_date(12345) }
    { carped => "Setting 'from_date' to something other than a DateTime is not supported!" },
        "Warning thrown when attempting to set from_date to integer";
};

subtest 'accumulate_rentalcharge tests' => sub {
    plan tests => 9;

    my $fees = Koha::Charges::Fees->new(
        {
            patron    => $patron,
            library   => $library,
            item      => $item,
            to_date   => $dt_to,
            from_date => $dt_from,
        }
    );

    # Daily tests
    Koha::CirculationRules->set_rules(
        {
            categorycode => $patron->categorycode,
            itemtype     => $itemtype->id,
            branchcode   => $library->id,
            rules        => {
                lengthunit => 'days',
            }
        }
    );

    $itemtype->rentalcharge_daily(1.00);
    $itemtype->store();
    is(
        $itemtype->rentalcharge_daily,
        1.00, 'Daily return charge stored correctly'
    );

    t::lib::Mocks::mock_preference( 'finesCalendar', 'ignoreCalendar' );
    my $charge = $fees->accumulate_rentalcharge();
    is(
        $charge, 6.00,
        'Daily rental charge calculated correctly with finesCalendar = ignoreCalendar'
    );

    t::lib::Mocks::mock_preference( 'finesCalendar', 'noFinesWhenClosed' );
    $charge = $fees->accumulate_rentalcharge();
    is(
        $charge, 6.00,
        'Daily rental charge calculated correctly with finesCalendar = noFinesWhenClosed'
    );

    $itemtype->rentalcharge_daily_calendar(0)->store();
    $charge = $fees->accumulate_rentalcharge();
    is(
        $charge, 6.00,
        'Daily rental charge calculated correctly with finesCalendar = noFinesWhenClosed and rentalcharge_daily_calendar = 0'
    );
    $itemtype->rentalcharge_daily_calendar(1)->store();

    my $calendar = C4::Calendar->new( branchcode => $library->id );

    # DateTime 1..7 (Mon..Sun), C4::Calendar 0..6 (Sun..Sat)
    my $closed_day =
          ( $dt_from->day_of_week == 6 ) ? 0
        : ( $dt_from->day_of_week == 7 ) ? 1
        :                                  $dt_from->day_of_week + 1;
    $calendar->insert_week_day_holiday(
        weekday     => $closed_day,
        title       => 'Test holiday',
        description => 'Test holiday'
    );
    $charge = $fees->accumulate_rentalcharge();
    my $day_names = {
        0 => 'Sunday',
        1 => 'Monday',
        2 => 'Tuesday',
        3 => 'Wednesday',
        4 => 'Thursday',
        5 => 'Friday',
        6 => 'Saturday'
    };
    my $dayname = $day_names->{$closed_day};
    is(
        $charge, 5.00,
        "Daily rental charge calculated correctly with finesCalendar = noFinesWhenClosed and closed $dayname"
    );

    # Hourly tests
    Koha::CirculationRules->set_rules(
        {
            categorycode => $patron->categorycode,
            itemtype     => $itemtype->id,
            branchcode   => $library->id,
            rules        => {
                lengthunit => 'hours',
            }
        }

    );

    $itemtype->rentalcharge_hourly("0.25");
    $itemtype->store();

    $dt_to = $dt_from->clone->add( hours => 96 );
    $fees  = Koha::Charges::Fees->new(
        {
            patron    => $patron,
            library   => $library,
            item      => $item,
            to_date   => $dt_to,
            from_date => $dt_from,
        }
    );

    $itemtype->rentalcharge_hourly_calendar(0)->store();
    $charge = $fees->accumulate_rentalcharge();
    is( $charge, 24.00, 'Hourly rental charge calculated correctly (96h * 0.25u)' );

    $itemtype->rentalcharge_hourly_calendar(1)->store();
    $charge = $fees->accumulate_rentalcharge();
    is(
        $charge, 18.00,
        "Hourly rental charge calculated correctly with finesCalendar = noFinesWhenClosed and closed $dayname (96h - 24h * 0.25u)"
    );

    $itemtype->rentalcharge_hourly_calendar(0)->store();
    $charge = $fees->accumulate_rentalcharge();
    is(
        $charge, 24.00,
        "Hourly rental charge calculated correctly with finesCalendar = noFinesWhenClosed and closed $dayname (96h - 24h * 0.25u) and rentalcharge_hourly_calendar = 0"
    );

    $itemtype->rentalcharge_hourly_calendar(1)->store();
    $calendar->delete_holiday( weekday => $closed_day );
    $charge = $fees->accumulate_rentalcharge();
    is(
        $charge, 24.00,
        'Hourly rental charge calculated correctly with finesCalendar = noFinesWhenClosed (96h - 0h * 0.25u)'
    );
};

$schema->storage->txn_rollback;
Time::Fake->reset;
