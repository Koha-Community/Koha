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

use Test::More tests => 18;
use Test::Warn;
use t::lib::Mocks;

BEGIN {
    t::lib::Mocks::mock_dbh;
    use_ok('Koha::Object');
    use_ok('Koha::Borrower');
}

my $object = Koha::Borrower->new( { surname => 'Test Borrower' } );
is( $object->surname(), 'Test Borrower', "Accessor returns correct value" );
$object->surname('Test Borrower Surname');
is( $object->surname(), 'Test Borrower Surname', "Accessor returns correct value after set" );

my $object2 = Koha::Borrower->new( { surname => 'Test Borrower 2' } );
is( $object2->surname(), 'Test Borrower 2', "Accessor returns correct value" );
$object2->surname('Test Borrower Surname 2');
is( $object2->surname(), 'Test Borrower Surname 2', "Accessor returns correct value after set" );

my $ret;
$ret = $object2->set( { surname => "Test Borrower Surname 3", firstname => "Test Firstname" } );
ok( ref($ret) eq 'Koha::Borrower', "Set returns object on success" );
is( $object2->surname(),   "Test Borrower Surname 3", "Set sets first field correctly" );
is( $object2->firstname(), "Test Firstname",          "Set sets second field correctly" );

warning_is { $ret = $object->set({ surname => "Test Borrower Surname 4", bork => "bork" }) }
            "No property bork!",
            "Expected 'No property bork!' caught";
is( $object2->surname(), "Test Borrower Surname 3", "Bad Set does not set field" );
is( $ret, 0, "Set returns 0 when passed a bad property" );

warning_is { $ret = $object->bork() }
            "No method bork!",
            "Expected 'No method bork!' caught for getter.";
ok( ! defined $ret, 'Bad getter returns undef' );

warning_is { $ret = $object->bork('bork') }
            "No method bork!",
            "Expected 'No method bork!' caught for setter.";
ok( ! defined $ret, 'Bad setter returns undef' );

my $borrower = Koha::Borrower->new(
    {
        borrowernumber      => '12345',
        cardnumber          => '1234567890',
        surname             => 'mySurname',
        firstname           => 'myFirstname',
        title               => 'Mr.',
        othernames          => 'myOthernames',
        initials            => 'MM',
        streetnumber        => '100',
        streettype          => 'Blvd',
        address             => 'my personnal address',
        address2            => 'my adress2',
        city                => 'Marseille',
        state               => 'mystate',
        zipcode             => '13006',
        country             => 'France',
        email               => 'mySurname.myFirstname@email.com',
        phone               => '0402872934',
        mobile              => '0627884632',
        fax                 => '0402872935',
        emailpro            => 'myEmailPro@email.com',
        phonepro            => '0402873334',
        B_streetnumber      => '101',
        B_streettype        => 'myB_streettype',
        B_address           => 'myB_address',
        B_address2          => 'myB_address2',
        B_city              => 'myB_city',
        B_state             => 'myB_state',
        B_zipcode           => '23456',
        B_country           => 'myB_country',
        B_email             => 'myB_email',
        B_phone             => '0678353935',
        dateofbirth         => '1990-07-16',
        branchcode          => 'myBranCode',
        categorycode        => 'myCatCode',
        dateenrolled        => '2015-03-19',
        dateexpiry          => '2016-03-19',
        gonenoaddress       => '0',
        lost                => '0',
        debarred            => '2015-04-19',
        debarredcomment     => 'You are debarred',
        contactname         => 'myContactname',
        contactfirstname    => 'myContactfirstname',
        contacttitle        => 'myContacttitle',
        guarantorid         => '123454321',
        borrowernotes       => 'borrowernotes',
        relationship        => 'myRelationship',
        sex                 => 'M',
        password            => 'hfkurhfe976634èj!',
        flags               => '55555',
        userid              => '87987',
        opacnote            => 'myOpacnote',
        contactnote         => 'myContactnote',
        sort1               => 'mySort1',
        sort2               => 'mySort2',
        altcontactfirstname => 'myAltcontactfirstname',
        altcontactsurname   => 'myAltcontactsurname',
        altcontactaddress1  => 'myAltcontactaddress1',
        altcontactaddress2  => 'myAltcontactaddress2',
        altcontactaddress3  => 'myAltcontactaddress3',
        altcontactstate     => 'myAltcontactstate',
        altcontactzipcode   => '465843',
        altcontactcountry   => 'myOtherCountry',
        altcontactphone     => 'myOtherphone',
        smsalertnumber      => '0683027346',
        privacy             => '667788',
    }
);

#borrower Accessor tests
subtest 'Accessor tests' => sub {
    plan tests => 65;
    is( $borrower->borrowernumber, '12345',                           'borrowernumber accessor returns correct value' );
    is( $borrower->cardnumber,     '1234567890',                      'cardnumber accessor returns correct value' );
    is( $borrower->surname,        'mySurname',                       'surname accessor returns correct value' );
    is( $borrower->firstname,      'myFirstname',                     'firstname accessor returns correct value' );
    is( $borrower->title,          'Mr.',                             'title accessor returns correct value' );
    is( $borrower->othernames,     'myOthernames',                    'othernames accessor returns correct value' );
    is( $borrower->initials,       'MM',                              'initials accessor returns correct value' );
    is( $borrower->streetnumber,   '100',                             'streetnumber accessor returns correct value' );
    is( $borrower->streettype,     'Blvd',                            'streettype accessor returns correct value' );
    is( $borrower->address,        'my personnal address',            'address accessor returns correct value' );
    is( $borrower->address2,       'my adress2',                      'address2 accessor returns correct value' );
    is( $borrower->city,           'Marseille',                       'city accessor returns correct value' );
    is( $borrower->state,          'mystate',                         'state accessor returns correct value' );
    is( $borrower->zipcode,        '13006',                           'zipcode accessor returns correct value' );
    is( $borrower->country,        'France',                          'country accessor returns correct value' );
    is( $borrower->email,          'mySurname.myFirstname@email.com', 'email accessor returns correct value' );
    is( $borrower->phone,          '0402872934',                      'phone accessor returns correct value' );
    is( $borrower->mobile,         '0627884632',                      'mobile accessor returns correct value' );
    is( $borrower->fax,            '0402872935',                      'fax accessor returns correct value' );
    is( $borrower->emailpro,       'myEmailPro@email.com',            'emailpro accessor returns correct value' );
    is( $borrower->phonepro,       '0402873334',                      'phonepro accessor returns correct value' );
    is( $borrower->B_streetnumber, '101',                             'B_streetnumber accessor returns correct value' );
    is( $borrower->B_streettype,   'myB_streettype',                  'B_streettype accessor returns correct value' );
    is( $borrower->B_address,      'myB_address',                     'B_address accessor returns correct value' );
    is( $borrower->B_address2,     'myB_address2',                    'B_address2 accessor returns correct value' );
    is( $borrower->B_city,         'myB_city',                        'B_city accessor returns correct value' );
    is( $borrower->B_state,        'myB_state',                       'B_state accessor returns correct value' );
    is( $borrower->B_zipcode,      '23456',                           'B_zipcode accessor returns correct value' );
    is( $borrower->B_country,      'myB_country',                     'B_country accessor returns correct value' );
    is( $borrower->B_email,        'myB_email',                       'B_email accessor returns correct value' );
    is( $borrower->B_phone,        '0678353935',                      'B_phone accessor returns correct value' );
    is( $borrower->dateofbirth,    '1990-07-16',                      'dateofbirth accessor returns correct value' );
    is( $borrower->branchcode,     'myBranCode',                      'branchcode accessor returns correct value' );
    is( $borrower->categorycode,   'myCatCode',                       'categorycode accessor returns correct value' );
    is( $borrower->dateenrolled,   '2015-03-19',                      'dateenrolled accessor returns correct value' );
    is( $borrower->dateexpiry,     '2016-03-19',                      'dateexpiry accessor returns correct value' );
    is( $borrower->gonenoaddress,  '0',                               'gonenoaddress accessor returns correct value' );
    is( $borrower->lost,           '0',                               'lost accessor returns correct value' );
    is( $borrower->debarred,       '2015-04-19',                      'debarred accessor returns correct value' );
    is( $borrower->debarredcomment,     'You are debarred',      'debarredcomment accessor returns correct value' );
    is( $borrower->contactname,         'myContactname',         'contactname accessor returns correct value' );
    is( $borrower->contactfirstname,    'myContactfirstname',    'contactfirstname accessor returns correct value' );
    is( $borrower->contacttitle,        'myContacttitle',        'contacttitle accessor returns correct value' );
    is( $borrower->guarantorid,         '123454321',             'guarantorid accessor returns correct value' );
    is( $borrower->borrowernotes,       'borrowernotes',         'borrowernotes accessor returns correct value' );
    is( $borrower->relationship,        'myRelationship',        'relationship accessor returns correct value' );
    is( $borrower->sex,                 'M',                     'sex accessor returns correct value' );
    is( $borrower->password,            'hfkurhfe976634èj!',    'password accessor returns correct value' );
    is( $borrower->flags,               '55555',                 'flags accessor returns correct value' );
    is( $borrower->userid,              '87987',                 'userid accessor returns correct value' );
    is( $borrower->opacnote,            'myOpacnote',            'opacnote accessor returns correct value' );
    is( $borrower->contactnote,         'myContactnote',         'contactnote accessor returns correct value' );
    is( $borrower->sort1,               'mySort1',               'sort1 accessor returns correct value' );
    is( $borrower->sort2,               'mySort2',               'sort2 accessor returns correct value' );
    is( $borrower->altcontactfirstname, 'myAltcontactfirstname', 'altcontactfirstname accessor returns correct value' );
    is( $borrower->altcontactsurname,   'myAltcontactsurname',   'altcontactsurname accessor returns correct value' );
    is( $borrower->altcontactaddress1,  'myAltcontactaddress1',  'altcontactaddress1 accessor returns correct value' );
    is( $borrower->altcontactaddress2,  'myAltcontactaddress2',  'altcontactaddress2 accessor returns correct value' );
    is( $borrower->altcontactaddress3,  'myAltcontactaddress3',  'altcontactaddress3 accessor returns correct value' );
    is( $borrower->altcontactstate,     'myAltcontactstate',     'altcontactstate accessor returns correct value' );
    is( $borrower->altcontactzipcode,   '465843',                'altcontactzipcode accessor returns correct value' );
    is( $borrower->altcontactcountry,   'myOtherCountry',        'altcontactcountry accessor returns correct value' );
    is( $borrower->altcontactphone,     'myOtherphone',          'altcontactphone accessor returns correct value' );
    is( $borrower->smsalertnumber,      '0683027346',            'smsalertnumber accessor returns correct value' );
    is( $borrower->privacy,             '667788',                'privacy accessor returns correct value' );
};

#borrower Set tests
subtest 'Set tests' => sub {
    plan tests => 65;

    $borrower->set(
        {
            borrowernumber      => '12346',
            cardnumber          => '1234567891',
            surname             => 'SmySurname',
            firstname           => 'SmyFirstname',
            title               => 'Mme.',
            othernames          => 'SmyOthernames',
            initials            => 'SS',
            streetnumber        => '200',
            streettype          => 'Rue',
            address             => 'Smy personnal address',
            address2            => 'Smy adress2',
            city                => 'Lyon',
            state               => 'Smystate',
            zipcode             => '69000',
            country             => 'France',
            email               => 'SmySurname.myFirstname@email.com',
            phone               => '0402872935',
            mobile              => '0627884633',
            fax                 => '0402872936',
            emailpro            => 'SmyEmailPro@email.com',
            phonepro            => '0402873335',
            B_streetnumber      => '102',
            B_streettype        => 'SmyB_streettype',
            B_address           => 'SmyB_address',
            B_address2          => 'SmyB_address2',
            B_city              => 'SmyB_city',
            B_state             => 'SmyB_state',
            B_zipcode           => '12333',
            B_country           => 'SmyB_country',
            B_email             => 'SmyB_email',
            B_phone             => '0678353936',
            dateofbirth         => '1991-07-16',
            branchcode          => 'SmyBranCode',
            categorycode        => 'SmyCatCode',
            dateenrolled        => '2014-03-19',
            dateexpiry          => '2017-03-19',
            gonenoaddress       => '1',
            lost                => '1',
            debarred            => '2016-04-19',
            debarredcomment     => 'You are still debarred',
            contactname         => 'SmyContactname',
            contactfirstname    => 'SmyContactfirstname',
            contacttitle        => 'SmyContacttitle',
            guarantorid         => '223454321',
            borrowernotes       => 'Sborrowernotes',
            relationship        => 'SmyRelationship',
            sex                 => 'F',
            password            => 'zerzerzer#',
            flags               => '666666',
            userid              => '98233',
            opacnote            => 'SmyOpacnote',
            contactnote         => 'SmyContactnote',
            sort1               => 'SmySort1',
            sort2               => 'SmySort2',
            altcontactfirstname => 'SmyAltcontactfirstname',
            altcontactsurname   => 'SmyAltcontactsurname',
            altcontactaddress1  => 'SmyAltcontactaddress1',
            altcontactaddress2  => 'SmyAltcontactaddress2',
            altcontactaddress3  => 'SmyAltcontactaddress3',
            altcontactstate     => 'SmyAltcontactstate',
            altcontactzipcode   => '565843',
            altcontactcountry   => 'SmyOtherCountry',
            altcontactphone     => 'SmyOtherphone',
            smsalertnumber      => '0683027347',
            privacy             => '667789'
        }
    );

    is( $borrower->borrowernumber,      '12346',                            'borrowernumber field set ok' );
    is( $borrower->cardnumber,          '1234567891',                       'cardnumber field set ok' );
    is( $borrower->surname,             'SmySurname',                       'surname field set ok' );
    is( $borrower->firstname,           'SmyFirstname',                     'firstname field set ok' );
    is( $borrower->title,               'Mme.',                             'title field set ok' );
    is( $borrower->othernames,          'SmyOthernames',                    'othernames field set ok' );
    is( $borrower->initials,            'SS',                               'initials field set ok' );
    is( $borrower->streetnumber,        '200',                              'streetnumber field set ok' );
    is( $borrower->streettype,          'Rue',                              'streettype field set ok' );
    is( $borrower->address,             'Smy personnal address',            'address field set ok' );
    is( $borrower->address2,            'Smy adress2',                      'address2 field set ok' );
    is( $borrower->city,                'Lyon',                             'city field set ok' );
    is( $borrower->state,               'Smystate',                         'state field set ok' );
    is( $borrower->zipcode,             '69000',                            'zipcode field set ok' );
    is( $borrower->country,             'France',                           'country field set ok' );
    is( $borrower->email,               'SmySurname.myFirstname@email.com', 'email field set ok' );
    is( $borrower->phone,               '0402872935',                       'phone field set ok' );
    is( $borrower->mobile,              '0627884633',                       'mobile field set ok' );
    is( $borrower->fax,                 '0402872936',                       'fax field set ok' );
    is( $borrower->emailpro,            'SmyEmailPro@email.com',            'emailpro field set ok' );
    is( $borrower->phonepro,            '0402873335',                       'phonepro field set ok' );
    is( $borrower->B_streetnumber,      '102',                              'B_streetnumber field set ok' );
    is( $borrower->B_streettype,        'SmyB_streettype',                  'B_streettype field set ok' );
    is( $borrower->B_address,           'SmyB_address',                     'B_address field set ok' );
    is( $borrower->B_address2,          'SmyB_address2',                    'B_address2 field set ok' );
    is( $borrower->B_city,              'SmyB_city',                        'B_city field set ok' );
    is( $borrower->B_state,             'SmyB_state',                       'B_state field set ok' );
    is( $borrower->B_zipcode,           '12333',                            'B_zipcode field set ok' );
    is( $borrower->B_country,           'SmyB_country',                     'B_country field set ok' );
    is( $borrower->B_email,             'SmyB_email',                       'B_email field set ok' );
    is( $borrower->B_phone,             '0678353936',                       'B_phone field set ok' );
    is( $borrower->dateofbirth,         '1991-07-16',                       'dateofbirth field set ok' );
    is( $borrower->branchcode,          'SmyBranCode',                      'branchcode field set ok' );
    is( $borrower->categorycode,        'SmyCatCode',                       'categorycode field set ok' );
    is( $borrower->dateenrolled,        '2014-03-19',                       'dateenrolled field set ok' );
    is( $borrower->dateexpiry,          '2017-03-19',                       'dateexpiry field set ok' );
    is( $borrower->gonenoaddress,       '1',                                'gonenoaddress field set ok' );
    is( $borrower->lost,                '1',                                'lost field set ok' );
    is( $borrower->debarred,            '2016-04-19',                       'debarred field set ok' );
    is( $borrower->debarredcomment,     'You are still debarred',           'debarredcomment field set ok' );
    is( $borrower->contactname,         'SmyContactname',                   'contactname field set ok' );
    is( $borrower->contactfirstname,    'SmyContactfirstname',              'contactfirstname field set ok' );
    is( $borrower->contacttitle,        'SmyContacttitle',                  'contacttitle field set ok' );
    is( $borrower->guarantorid,         '223454321',                        'guarantorid field set ok' );
    is( $borrower->borrowernotes,       'Sborrowernotes',                   'borrowernotes field set ok' );
    is( $borrower->relationship,        'SmyRelationship',                  'relationship field set ok' );
    is( $borrower->sex,                 'F',                                'sex field set ok' );
    is( $borrower->password,            'zerzerzer#',                       'password field set ok' );
    is( $borrower->flags,               '666666',                           'flags field set ok' );
    is( $borrower->userid,              '98233',                            'userid field set ok' );
    is( $borrower->opacnote,            'SmyOpacnote',                      'opacnote field set ok' );
    is( $borrower->contactnote,         'SmyContactnote',                   'contactnote field set ok' );
    is( $borrower->sort1,               'SmySort1',                         'sort1 field set ok' );
    is( $borrower->sort2,               'SmySort2',                         'sort2 field set ok' );
    is( $borrower->altcontactfirstname, 'SmyAltcontactfirstname',           'altcontactfirstname field set ok' );
    is( $borrower->altcontactsurname,   'SmyAltcontactsurname',             'altcontactsurname field set ok' );
    is( $borrower->altcontactaddress1,  'SmyAltcontactaddress1',            'altcontactaddress1 field set ok' );
    is( $borrower->altcontactaddress2,  'SmyAltcontactaddress2',            'altcontactaddress2 field set ok' );
    is( $borrower->altcontactaddress3,  'SmyAltcontactaddress3',            'altcontactaddress3 field set ok' );
    is( $borrower->altcontactstate,     'SmyAltcontactstate',               'altcontactstate field set ok' );
    is( $borrower->altcontactzipcode,   '565843',                           'altcontactzipcode field set ok' );
    is( $borrower->altcontactcountry,   'SmyOtherCountry',                  'altcontactcountry field set ok' );
    is( $borrower->altcontactphone,     'SmyOtherphone',                    'altcontactphone field set ok' );
    is( $borrower->smsalertnumber,      '0683027347',                       'smsalertnumber field set ok' );
    is( $borrower->privacy,             '667789',                           'privacy field set ok' );
};

1;
