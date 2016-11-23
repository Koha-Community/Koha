#!/usr/bin/perl

# Copyright Koha-Suomi Oy 2016
#
# This file is part of Koha
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
use t::lib::TestBuilder;

use Koha::Exceptions;

use_ok('Koha::Availability');

my $exception;

subtest 'Instantiate new Koha::Availability -object' => sub {
    plan tests => 6;

    my $availability = Koha::Availability->new;
    is(ref($availability), 'Koha::Availability', 'Object instantiated successfully.');

    subtest 'Check Koha::Availability -object default values' => \&check_default_values;
    subtest 'Add additional notes' => sub {
        plan tests => 4;

        $availability = Koha::Availability->new;
        $exception = 'Koha::Exceptions::Exception';
        $availability->note($exception->new( error => 'Test note' ));
        is($availability->note, 1, 'Added a test note with additional data.');
        is(ref($availability->notes->{$exception}), $exception, 'The object contains this test note.');
        is($availability->notes->{$exception}->error, 'Test note', 'The note contains our additional data.');

        subtest 'Availability should stay false if it has unavailability and a note is added' => sub {
            plan tests => 3;

            $availability = Koha::Availability->new;
            $exception = 'Koha::Exceptions::Exception';
            $availability->unavailable($exception->new( error => 'Test unavailability' ));
            is($availability->available, 0, 'Availability is false');
            $availability->note($exception->new( error => 'Test note' ));
            is($availability->notes->{$exception}->error, 'Test note', 'Added a test note.');
            is($availability->available, 0, 'Availability is still false');
        };
    };

    subtest 'Set availability to be confirmed by a librarian' => sub {
        plan tests => 5;

        $availability = Koha::Availability->new;
        $exception = 'Koha::Exceptions::Exception';
        $availability->confirm($exception->new( error => 'Needs to be confirmed' ));
        is($availability->confirm, 1, 'Added a new exception to be confirmed by librarian, with some additional data.');
        my $confirmations = $availability->confirmations;
        is(ref($confirmations->{$exception}), $exception, 'The object contains this exception.');
        is($confirmations->{$exception}->error, 'Needs to be confirmed', 'Additional data is also stored.');
        is($availability->available, 1, 'Although we have something to be confirmed, availability is still true.');
        $availability->confirm(Koha::Exceptions::MissingParameter->new( error => 'Just a test.' ));
        is($availability->confirm, 2, 'Added another exception. $availability->confirm returns the correct count.');
    };

    subtest 'Set availability to unavailable' => sub {
        plan tests => 6;

        $availability = Koha::Availability->new;
        $exception = 'Koha::Exceptions::Exception';
        $availability->unavailable($exception->new( error => 'Not available' ));
        is($availability->unavailable, 1, 'Added a new exception with some additional data and made the availability false.');
        my $unavailabilities = $availability->unavailabilities;
        is(ref($unavailabilities->{$exception}), $exception, 'The object contains this exception.');
        is($unavailabilities->{$exception}->error, 'Not available', 'Additional data is also stored.');
        is($availability->unavailable, 1, 'Availability is unavailable.');
        is($availability->available, 0, 'Not available.');
        $availability->unavailable(Koha::Exceptions::MissingParameter->new( error => 'Just a test.' ));
        is($availability->unavailable, 2, 'Added another exception. $availability->confirm returns the correct count.');
    };

    subtest 'Reset Koha::Availability -object' => sub {
        plan tests => 3;

        $availability = Koha::Availability->new;
        $exception = 'Koha::Exceptions::Exception';
        $availability->unavailable($exception->new( error => 'Not available' ));
        ok(!$availability->available, 'Set Availability-object as unavailable.');
        ok($availability->reset, 'Object reset');
        ok($availability->available, 'Availability is now true.');
    };
};

sub check_default_values {
    plan tests => 5;

    my $availability = Koha::Availability->new;
    is($availability->available, 1, 'Koha::Availability -object is available.');
    is(keys %{$availability->unavailabilities}, 0, 'There are no unavailabilities.');
    is(keys %{$availability->confirmations}, 0, 'Nothing needs to be confirmed.');
    is(keys %{$availability->notes}, 0, 'There are no additional notes.');
    is($availability->expected_available, undef, 'There is no expectation of future availability');
}

1;
