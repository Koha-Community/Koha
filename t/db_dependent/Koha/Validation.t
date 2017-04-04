#!/usr/bin/perl
#
# Copyright 2017 Koha-Suomi Oy
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

use Test::More tests => 3;

use t::lib::Mocks;

BEGIN {
    use_ok('Koha::Validation');
}

subtest 'email() tests' => sub {
    plan tests => 2;

    is(Koha::Validation::email('test'), 0, "'test' is invalid e-mail address'");
    is(Koha::Validation::email('test@example.com'), 1, '\'test@example.com\' is '
                               .'valid e-mail address');
};

subtest 'phone() tests' => sub {
    plan tests => 3;

    t::lib::Mocks::mock_preference('ValidatePhoneNumber', '');

    is(Koha::Validation::phone('test'), 1, 'Phone number validation is switched '
       .'off, so \'test\' is a valid phone number');

    # An example: Finnish Phone number validation regex
    subtest 'Finnish phone number validation regex' => sub {
        t::lib::Mocks::mock_preference('ValidatePhoneNumber',
            '^((90[0-9]{3})?0|\+358\s?)(?!(100|20(0|2(0|[2-3])|9[8-9])|300|600|70'
           .'0|708|75(00[0-3]|(1|2)\d{2}|30[0-2]|32[0-2]|75[0-2]|98[0-2])))(4|50|'
           .'10[1-9]|20(1|2(1|[4-9])|[3-9])|29|30[1-9]|71|73|75(00[3-9]|30[3-9]|3'
           .'2[3-9]|53[3-9]|83[3-9])|2|3|5|6|8|9|1[3-9])\s?(\d\s?){4,19}\d$'
        );

        is(Koha::Validation::phone('1234'), 0, '1234 is invalid phone number.');
        is(Koha::Validation::phone('+358501234567'), 1, '+358501234567 is valid '
           .'phone number.');
        is(Koha::Validation::phone('+1-202-555-0198'), 0, '+1-202-555-0198 is '
          .'invalid phone number.');
    };

    subtest 'International phone number validation regex' => sub {
        t::lib::Mocks::mock_preference('ValidatePhoneNumber',
            '^((\+)?[1-9]{1,2})?([-\s\.])?((\(\d{1,4}\))|\d{1,4})(([-\s\.])?[0-9]'
           .'{1,12}){1,2}$'
        );

        is(Koha::Validation::phone('nope'), 0, 'nope is invalid phone number.');
        is(Koha::Validation::phone('1234'), 1, '1234 is valid phone number.');
        is(Koha::Validation::phone('+358501234567'), 1, '+358501234567 is valid '
           .'phone number.');
        is(Koha::Validation::phone('+1-202-555-0198'), 1, '+1-202-555-0198 is '
          .'valid phone number.');
    };

};
