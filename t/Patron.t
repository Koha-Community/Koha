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

use Test::More tests => 3;
use Test::Warn;
use t::lib::Mocks;
use t::lib::TestBuilder;

use_ok('Koha::Object');
use_ok('Koha::Patron');

use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'Accessor tests' => sub {
    plan tests => 9;
    $schema->storage->txn_begin;

    my $object = Koha::Patron->new( { surname => 'Test Patron' } );
    is( $object->surname(), 'Test Patron', "Accessor returns correct value" );
    $object->surname('Test Patron Surname');
    is( $object->surname(), 'Test Patron Surname', "Accessor returns correct value after set" );

    my $object2 = Koha::Patron->new( { surname => 'Test Patron 2' } );
    is( $object2->surname(), 'Test Patron 2', "Accessor returns correct value" );
    $object2->surname('Test Patron Surname 2');
    is( $object2->surname(), 'Test Patron Surname 2', "Accessor returns correct value after set" );

    my $ret;
    $ret = $object2->set( { surname => "Test Patron Surname 3", firstname => "Test Firstname" } );
    ok( ref($ret) eq 'Koha::Patron', "Set returns object on success" );
    is( $object2->surname(),   "Test Patron Surname 3", "Set sets first field correctly" );
    is( $object2->firstname(), "Test Firstname",          "Set sets second field correctly" );

    our $patron = Koha::Patron->new(
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
            borrowernotes       => 'borrowernotes',
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

    subtest 'Accessor tests after new' => sub {
        plan tests => 60;
        is( $patron->borrowernumber, '12345',                           'borrowernumber accessor returns correct value' );
        is( $patron->cardnumber,     '1234567890',                      'cardnumber accessor returns correct value' );
        is( $patron->surname,        'mySurname',                       'surname accessor returns correct value' );
        is( $patron->firstname,      'myFirstname',                     'firstname accessor returns correct value' );
        is( $patron->title,          'Mr.',                             'title accessor returns correct value' );
        is( $patron->othernames,     'myOthernames',                    'othernames accessor returns correct value' );
        is( $patron->initials,       'MM',                              'initials accessor returns correct value' );
        is( $patron->streetnumber,   '100',                             'streetnumber accessor returns correct value' );
        is( $patron->streettype,     'Blvd',                            'streettype accessor returns correct value' );
        is( $patron->address,        'my personnal address',            'address accessor returns correct value' );
        is( $patron->address2,       'my adress2',                      'address2 accessor returns correct value' );
        is( $patron->city,           'Marseille',                       'city accessor returns correct value' );
        is( $patron->state,          'mystate',                         'state accessor returns correct value' );
        is( $patron->zipcode,        '13006',                           'zipcode accessor returns correct value' );
        is( $patron->country,        'France',                          'country accessor returns correct value' );
        is( $patron->email,          'mySurname.myFirstname@email.com', 'email accessor returns correct value' );
        is( $patron->phone,          '0402872934',                      'phone accessor returns correct value' );
        is( $patron->mobile,         '0627884632',                      'mobile accessor returns correct value' );
        is( $patron->fax,            '0402872935',                      'fax accessor returns correct value' );
        is( $patron->emailpro,       'myEmailPro@email.com',            'emailpro accessor returns correct value' );
        is( $patron->phonepro,       '0402873334',                      'phonepro accessor returns correct value' );
        is( $patron->B_streetnumber, '101',                             'B_streetnumber accessor returns correct value' );
        is( $patron->B_streettype,   'myB_streettype',                  'B_streettype accessor returns correct value' );
        is( $patron->B_address,      'myB_address',                     'B_address accessor returns correct value' );
        is( $patron->B_address2,     'myB_address2',                    'B_address2 accessor returns correct value' );
        is( $patron->B_city,         'myB_city',                        'B_city accessor returns correct value' );
        is( $patron->B_state,        'myB_state',                       'B_state accessor returns correct value' );
        is( $patron->B_zipcode,      '23456',                           'B_zipcode accessor returns correct value' );
        is( $patron->B_country,      'myB_country',                     'B_country accessor returns correct value' );
        is( $patron->B_email,        'myB_email',                       'B_email accessor returns correct value' );
        is( $patron->B_phone,        '0678353935',                      'B_phone accessor returns correct value' );
        is( $patron->dateofbirth,    '1990-07-16',                      'dateofbirth accessor returns correct value' );
        is( $patron->branchcode,     'myBranCode',                      'branchcode accessor returns correct value' );
        is( $patron->categorycode,   'myCatCode',                       'categorycode accessor returns correct value' );
        is( $patron->dateenrolled,   '2015-03-19',                      'dateenrolled accessor returns correct value' );
        is( $patron->dateexpiry,     '2016-03-19',                      'dateexpiry accessor returns correct value' );
        is( $patron->gonenoaddress,  '0',                               'gonenoaddress accessor returns correct value' );
        is( $patron->lost,           '0',                               'lost accessor returns correct value' );
        is( $patron->debarred,       '2015-04-19',                      'debarred accessor returns correct value' );
        is( $patron->debarredcomment,     'You are debarred',      'debarredcomment accessor returns correct value' );
        is( $patron->borrowernotes,       'borrowernotes',         'borrowernotes accessor returns correct value' );
        is( $patron->sex,                 'M',                     'sex accessor returns correct value' );
        is( $patron->password,            'hfkurhfe976634èj!',    'password accessor returns correct value' );
        is( $patron->flags,               '55555',                 'flags accessor returns correct value' );
        is( $patron->userid,              '87987',                 'userid accessor returns correct value' );
        is( $patron->opacnote,            'myOpacnote',            'opacnote accessor returns correct value' );
        is( $patron->contactnote,         'myContactnote',         'contactnote accessor returns correct value' );
        is( $patron->sort1,               'mySort1',               'sort1 accessor returns correct value' );
        is( $patron->sort2,               'mySort2',               'sort2 accessor returns correct value' );
        is( $patron->altcontactfirstname, 'myAltcontactfirstname', 'altcontactfirstname accessor returns correct value' );
        is( $patron->altcontactsurname,   'myAltcontactsurname',   'altcontactsurname accessor returns correct value' );
        is( $patron->altcontactaddress1,  'myAltcontactaddress1',  'altcontactaddress1 accessor returns correct value' );
        is( $patron->altcontactaddress2,  'myAltcontactaddress2',  'altcontactaddress2 accessor returns correct value' );
        is( $patron->altcontactaddress3,  'myAltcontactaddress3',  'altcontactaddress3 accessor returns correct value' );
        is( $patron->altcontactstate,     'myAltcontactstate',     'altcontactstate accessor returns correct value' );
        is( $patron->altcontactzipcode,   '465843',                'altcontactzipcode accessor returns correct value' );
        is( $patron->altcontactcountry,   'myOtherCountry',        'altcontactcountry accessor returns correct value' );
        is( $patron->altcontactphone,     'myOtherphone',          'altcontactphone accessor returns correct value' );
        is( $patron->smsalertnumber,      '0683027346',            'smsalertnumber accessor returns correct value' );
        is( $patron->privacy,             '667788',                'privacy accessor returns correct value' );
    };

    subtest 'Accessor tests after set' => sub {
        plan tests => 60;

        $patron->set(
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
                borrowernotes       => 'Sborrowernotes',
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

        is( $patron->borrowernumber,      '12346',                            'borrowernumber field set ok' );
        is( $patron->cardnumber,          '1234567891',                       'cardnumber field set ok' );
        is( $patron->surname,             'SmySurname',                       'surname field set ok' );
        is( $patron->firstname,           'SmyFirstname',                     'firstname field set ok' );
        is( $patron->title,               'Mme.',                             'title field set ok' );
        is( $patron->othernames,          'SmyOthernames',                    'othernames field set ok' );
        is( $patron->initials,            'SS',                               'initials field set ok' );
        is( $patron->streetnumber,        '200',                              'streetnumber field set ok' );
        is( $patron->streettype,          'Rue',                              'streettype field set ok' );
        is( $patron->address,             'Smy personnal address',            'address field set ok' );
        is( $patron->address2,            'Smy adress2',                      'address2 field set ok' );
        is( $patron->city,                'Lyon',                             'city field set ok' );
        is( $patron->state,               'Smystate',                         'state field set ok' );
        is( $patron->zipcode,             '69000',                            'zipcode field set ok' );
        is( $patron->country,             'France',                           'country field set ok' );
        is( $patron->email,               'SmySurname.myFirstname@email.com', 'email field set ok' );
        is( $patron->phone,               '0402872935',                       'phone field set ok' );
        is( $patron->mobile,              '0627884633',                       'mobile field set ok' );
        is( $patron->fax,                 '0402872936',                       'fax field set ok' );
        is( $patron->emailpro,            'SmyEmailPro@email.com',            'emailpro field set ok' );
        is( $patron->phonepro,            '0402873335',                       'phonepro field set ok' );
        is( $patron->B_streetnumber,      '102',                              'B_streetnumber field set ok' );
        is( $patron->B_streettype,        'SmyB_streettype',                  'B_streettype field set ok' );
        is( $patron->B_address,           'SmyB_address',                     'B_address field set ok' );
        is( $patron->B_address2,          'SmyB_address2',                    'B_address2 field set ok' );
        is( $patron->B_city,              'SmyB_city',                        'B_city field set ok' );
        is( $patron->B_state,             'SmyB_state',                       'B_state field set ok' );
        is( $patron->B_zipcode,           '12333',                            'B_zipcode field set ok' );
        is( $patron->B_country,           'SmyB_country',                     'B_country field set ok' );
        is( $patron->B_email,             'SmyB_email',                       'B_email field set ok' );
        is( $patron->B_phone,             '0678353936',                       'B_phone field set ok' );
        is( $patron->dateofbirth,         '1991-07-16',                       'dateofbirth field set ok' );
        is( $patron->branchcode,          'SmyBranCode',                      'branchcode field set ok' );
        is( $patron->categorycode,        'SmyCatCode',                       'categorycode field set ok' );
        is( $patron->dateenrolled,        '2014-03-19',                       'dateenrolled field set ok' );
        is( $patron->dateexpiry,          '2017-03-19',                       'dateexpiry field set ok' );
        is( $patron->gonenoaddress,       '1',                                'gonenoaddress field set ok' );
        is( $patron->lost,                '1',                                'lost field set ok' );
        is( $patron->debarred,            '2016-04-19',                       'debarred field set ok' );
        is( $patron->debarredcomment,     'You are still debarred',           'debarredcomment field set ok' );
        is( $patron->borrowernotes,       'Sborrowernotes',                   'borrowernotes field set ok' );
        is( $patron->sex,                 'F',                                'sex field set ok' );
        is( $patron->password,            'zerzerzer#',                       'password field set ok' );
        is( $patron->flags,               '666666',                           'flags field set ok' );
        is( $patron->userid,              '98233',                            'userid field set ok' );
        is( $patron->opacnote,            'SmyOpacnote',                      'opacnote field set ok' );
        is( $patron->contactnote,         'SmyContactnote',                   'contactnote field set ok' );
        is( $patron->sort1,               'SmySort1',                         'sort1 field set ok' );
        is( $patron->sort2,               'SmySort2',                         'sort2 field set ok' );
        is( $patron->altcontactfirstname, 'SmyAltcontactfirstname',           'altcontactfirstname field set ok' );
        is( $patron->altcontactsurname,   'SmyAltcontactsurname',             'altcontactsurname field set ok' );
        is( $patron->altcontactaddress1,  'SmyAltcontactaddress1',            'altcontactaddress1 field set ok' );
        is( $patron->altcontactaddress2,  'SmyAltcontactaddress2',            'altcontactaddress2 field set ok' );
        is( $patron->altcontactaddress3,  'SmyAltcontactaddress3',            'altcontactaddress3 field set ok' );
        is( $patron->altcontactstate,     'SmyAltcontactstate',               'altcontactstate field set ok' );
        is( $patron->altcontactzipcode,   '565843',                           'altcontactzipcode field set ok' );
        is( $patron->altcontactcountry,   'SmyOtherCountry',                  'altcontactcountry field set ok' );
        is( $patron->altcontactphone,     'SmyOtherphone',                    'altcontactphone field set ok' );
        is( $patron->smsalertnumber,      '0683027347',                       'smsalertnumber field set ok' );
        is( $patron->privacy,             '667789',                           'privacy field set ok' );
    };

    $schema->storage->txn_rollback;
};
