#!/usr/bin/env perl

# Copyright 2017 Koha-Suomi Oy
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

use Test::More;
use Try::Tiny; #Even Selenium::Remote::Driver uses Try::Tiny :)

use Koha::Auth::PermissionManager;
use Koha::Patron::Modifications;

use t::lib::Page::Mainpage;
use t::lib::Page::Opac::OpacMain;
use t::lib::Page::Opac::OpacMemberentry;
use t::lib::Page::Members::Memberentry;
use t::lib::Page::Members::Moremember;

use t::lib::TestObjects::PatronFactory;
use t::lib::TestObjects::SystemPreferenceFactory;

##Setting up the test context
my $testContext = {};

my $password = '1234';
my $patronFactory = t::lib::TestObjects::PatronFactory->new();
my $borrowers = $patronFactory->createTestGroup([
            {firstname  => 'Testone',
             surname    => 'Testtwo',
             cardnumber => '1A01',
             branchcode => 'CPL',
             userid     => 'normal_user',
             address    => 'testi',
             city       => 'joensuu',
             zipcode    => '80100',
             password   => $password,
            },
            {firstname  => 'Testthree',
             surname    => 'Testfour',
             cardnumber => 'superuberadmin',
             branchcode => 'CPL',
             userid     => 'god',
             address    => 'testi',
             city       => 'joensuu',
             zipcode    => '80100',
             password   => $password,
            },
        ], undef, $testContext);

my $systempreferences = t::lib::TestObjects::SystemPreferenceFactory->createTestGroup([
            {preference => 'ValidatePhoneNumber',
             value      => '^((90[0-9]{3})?0|\+358\s?)(?!(100|20(0|2(0|[2-3])|9[8-9])|300|600|700|708|75(00[0-3]|(1|2)\d{2}|30[0-2]|32[0-2]|75[0-2]|98[0-2])))(4|50|10[1-9]|20(1|2(1|[4-9])|[3-9])|29|30[1-9]|71|73|75(00[3-9]|30[3-9]|32[3-9]|53[3-9]|83[3-9])|2|3|5|6|8|9|1[3-9])\s?(\d\s?){4,19}\d$',
            },
            {preference => 'TalkingTechItivaPhoneNotification',
             value      => 1
            },
            {preference => 'SMSSendDriver',
             value      => 'test'
            },
            {preference => 'EnhancedMessagingPreferences',
             value      => 1
            },
        ], undef, $testContext);

my $permissionManager = Koha::Auth::PermissionManager->new();
$permissionManager->grantPermissions(
    $borrowers->{'superuberadmin'},
    {superlibrarian => 'superlibrarian'}
);

eval {
    OpacValidations();
    StaffValidations();
};

if ($@) { #Catch all leaking errors and gracefully terminate.
    warn $@;
    tearDown();
    exit 1;
}

##All tests done, tear down test context
tearDown();
done_testing;

sub tearDown {
    Koha::Patron::Modifications->search({
        borrowernumber => $borrowers->{'1A01'}->borrowernumber
    })->delete;
    Koha::Patron::Modifications->search({
        borrowernumber => $borrowers->{'superuberadmin'}->borrowernumber
    })->delete;
    t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext);
}








######################################################
    ###  STARTING TEST IMPLEMENTATIONS         ###
######################################################
sub setValidationsOff {
    C4::Context->set_preference('ValidatePhoneNumber', '');
}
sub setValidationsOn {
    C4::Context->set_preference('ValidatePhoneNumber', '^((90[0-9]{3})?0|\+358\s?)(?!(100|20(0|2(0|[2-3])|9[8-9])|300|600|700|708|75(00[0-3]|(1|2)\d{2}|30[0-2]|32[0-2]|75[0-2]|98[0-2])))(4|50|10[1-9]|20(1|2(1|[4-9])|[3-9])|29|30[1-9]|71|73|75(00[3-9]|30[3-9]|32[3-9]|53[3-9]|83[3-9])|2|3|5|6|8|9|1[3-9])\s?(\d\s?){4,19}\d$');
}

sub OpacValidations {
    my $main = t::lib::Page::Opac::OpacMain->new({
        borrowernumber => $borrowers->{'superuberadmin'}->borrowernumber
    });

    setValidationsOn();

    ok(C4::Context->preference('ValidatePhoneNumber'), "Phone validation on");
    $main
    ->doPasswordLogin($borrowers->{'superuberadmin'}->userid(), $password)
    ->navigateYourPersonalDetails()
    ->setEmail('valid@email.com') # test valid email
    ->submitForm(1) # expecting success
    ->navigateYourPersonalDetails()
    ->setEmail("invalidemail") # test invalid email
    ->submitForm(0) # expecting error
    ->navigateYourPersonalDetails()
    ->setPhone("+3585012345667") # test valid phone number
    ->submitForm(1) # expecting success
    ->navigateYourPersonalDetails()
    ->setPhone("1234phone56789") # test invalid phone number
    ->submitForm(0); # expecting error

    print "--Setting validations off--\n";
    setValidationsOff(); # set validations off from system prefs
    #then test validations again
    is(C4::Context->preference('ValidatePhoneNumber'), '',
       "Phone validation off");

    $main
    ->navigateYourPersonalDetails()
    ->setEmail("invalidemail_validations_off") # test invalid email
    ->submitForm(0) # expecting error, email validation is always on
    ->navigateYourPersonalDetails()
    ->setEmail('valid@email.com')
    ->submitForm(1)
    ->navigateYourPersonalDetails()
    ->setPhone("1234phone56789_validations_off") # test invalid phone number
    ->submitForm(1); # expecting success
}

sub StaffValidations {
    setValidationsOn();

    my $memberentry = t::lib::Page::Members::Memberentry->new({
        borrowernumber => $borrowers->{'superuberadmin'}->borrowernumber,
        op => 'modify',
        destination => 'circ',
        categorycode => 'PT'
    });

    ok(C4::Context->preference('ValidatePhoneNumber'), "Phone validation on");

    $memberentry
    ->doPasswordLogin($borrowers->{'superuberadmin'}->userid(), $password)
    ->setEmail('valid@email.com') # test valid email
    ->submitForm(1) # expecting success
    ->navigateEditPatron()
    ->setEmail("invalidemail") # test invalid email
    ->submitForm(0) # expecting error
    ->setEmail("")
    ->setPhone("+3585012345667") # test valid phone number
    ->submitForm(1) # expecting success
    ->navigateEditPatron()
    ->setPhone("1234phone56789") # test invalid phone number
    ->submitForm(0); # expecting error

    print "--Setting validations off--\n";
    setValidationsOff(); # set validations off from system prefs
    #then test validations again

    is(C4::Context->preference('ValidatePhoneNumber'), '',
       "Phone validation off");

    $memberentry
    ->setPhone("") # refreshing
    ->setEmail("") # the
    ->submitForm(1)    # page
    ->navigateEditPatron()
    ->setEmail("invalidemail_validations_off") # test invalid email
    ->submitForm(0) # expecting error, email validation is always on
    ->setEmail('valid@email.com')
    ->submitForm(1)
    ->navigateEditPatron()
    ->setPhone("1234phone56789_validations_off") # test invalid phone number
    ->submitForm(1); # expecting success

    setValidationsOn();
}
