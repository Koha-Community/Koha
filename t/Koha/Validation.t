# Copyright 2016 KohaSuomi
#
# This file is part of Koha.
#

use Modern::Perl;
use Test::More;

use Scalar::Util qw(blessed);
use Try::Tiny;

use DateTime;

use C4::Biblio;
use Koha::Validation;

use t::lib::TestObjects::SystemPreferenceFactory;
use t::lib::TestObjects::ObjectFactory;


my $globalContext = {};
my $spref = t::lib::TestObjects::SystemPreferenceFactory->createTestGroup([
                    {
                        preference => 'ValidatePhoneNumber',
                        value => '^((90[0-9]{3})?0|\+358\s?)(?!(100|20(0|2(0|[2-3])|9[8-9])|300|600|700|708|75(00[0-3]|(1|2)\d{2}|30[0-2]|32[0-2]|75[0-2]|98[0-2])))(4|50|10[1-9]|20(1|2(1|[4-9])|[3-9])|29|30[1-9]|71|73|75(00[3-9]|30[3-9]|32[3-9]|53[3-9]|83[3-9])|2|3|5|6|8|9|1[3-9])\s?(\d\s?){4,19}\d$',
                    },
                    ], undef, $globalContext);

subtest "Proper Koha::Validation invocation", \&kohaValidationInvocation;
sub kohaValidationInvocation {
    try {
        Koha::Validation::tries('key', 'A', 'string');
        ok(0,
           "SHOULD THROW AN ERROR");
    }
    catch {
        is(ref($_), 'Koha::Exception::SubroutineCall',
           "Koha::Validation->tries() called using the wrong notation.");
    }
}

subtest "Validate email", \&simpleEmail;
sub simpleEmail {
    is(Koha::Validation->email('koha@example.com'),
       1,
       "Valid email");
    is(Koha::Validation->email('koha@examplecom'),
       0,
       "InValid email");
}

subtest "Validate phone", \&simplePhone;
sub simplePhone {
    is(Koha::Validation->phone('+358504497763'),
       1,
       "Valid phone");
    is(Koha::Validation->phone('+35504497763'),
       0,
       "InValid phone");
}

subtest "Validate array of something", \&arrayOf;
sub arrayOf {
    my @array = ('+358504497763', '0451123123');
    is(Koha::Validation->tries('phnbr', \@array, 'phone', 'a' ),
       1,
       "Valid phonenumber array");

    push(@array, 'soita heti');
    try {
        is(Koha::Validation->tries('phnbr', \@array, 'phone', 'a' ),
           'SHOULD THROW AN EXCEPTION!',
           "InValid phonenumber array");
    } catch {
        is(ref($_), 'Koha::Exception::BadParameter',
           "InValid phonenumber array");

        ok($_->message =~ /'soita heti' is not a valid 'phonenumber'/,
           "Got a well formatted error message");
    };
}

subtest "Validate string", \&simpleString;
sub simpleString {

    is(Koha::Validation->tries('key', '+358504497763', 'string'),
       1,
       "Valid string");

    try {
        is(Koha::Validation->tries('key', 'A', 'string'),
           'SHOULD THROW AN EXCEPTION!',
           "Not a string, but a char");
    } catch {
        is(ref($_), 'Koha::Exception::BadParameter',
           "Not a string, but a char");

        ok($_->message =~ /is not a valid 'string', but a char/,
           "Got a well formatted error message");
    };

    try {
        is(Koha::Validation->tries('key', '', 'string'),
           'SHOULD THROW AN EXCEPTION!',
           "Not a string, but a nothing");
    } catch {
        is(ref($_), 'Koha::Exception::BadParameter',
           "Not a string, but a nothing");
    };

    is(Koha::Validation->tries('key', 'AB', 'string'),
       1,
       "Valid short String");
}

subtest "Array of Array of doubles", \&nestedArrayDoubles;
sub nestedArrayDoubles {

    my @array = ([0.4, 1.2],
                 [4.5, 7.9]);
    is(Koha::Validation->tries('nay', \@array, 'double', 'aa'),
       1,
       "Valid nested array of doubles");

    push(@array, [2, 'lol']);
    try {
        is(Koha::Validation->tries('nay', \@array, 'double', 'aa'),
           'SHOULD THROW AN EXCEPTION!',
           "InValid nested array of doubles");
    } catch {
        is(ref($_), 'Koha::Exception::BadParameter',
           "InValid nested array of doubles");

        ok($_->message =~ /is not a valid 'double'/,
           "Got a well formatted error message");
    };
}

subtest "Digit", \&simpleDigit;
sub simpleDigit {
    is(Koha::Validation->tries('diggit', 1, 'digit'),
       1,
       "Valid digit");

    try {
        is(Koha::Validation->tries('diggit', '21 34', 'digit'),
           'SHOULD THROW AN EXCEPTION!',
           "Not a digit");
    } catch {
        is(ref($_), 'Koha::Exception::BadParameter',
           "Not a digit");

        ok($_->message =~ /is not a valid 'digit'/,
           "Got a well formatted error message");
    };

    try {
        is(Koha::Validation->tries('diggit', '', 'digit'),
           'SHOULD THROW AN EXCEPTION!',
           "Not a digit");
    } catch {
        is(ref($_), 'Koha::Exception::BadParameter',
           "Not a digit");

        ok($_->message =~ /is not a valid 'digit'/,
           "Got a well formatted error message");
    };

    try {
        is(Koha::Validation->tries('diggit', -1, 'digit'),
           'SHOULD THROW AN EXCEPTION!',
           "Negative number is not a digit");
    } catch {
        is(ref($_), 'Koha::Exception::BadParameter',
           "Negative number is not a digit");

        ok($_->message =~ /negative numbers are not a 'digit'/,
           "Got a well formatted error message");
    };
}

subtest "MARC Selectors", \&marcSelectors;
sub marcSelectors {

    is(Koha::Validation->tries('mrc', '856', 'marcFieldSelector'),
       1,
       "Valid MARC Field selector");
    is(Koha::Validation::getMARCFieldSelectorCache, '856', "Validated MARC Field remembered");
    is(Koha::Validation::getMARCSubfieldSelectorCache, undef, "Not touched MARC Subfield not defined");

    try {
        is(Koha::Validation->tries('mrc', '85u', 'marcFieldSelector',),
           'SHOULD THROW AN EXCEPTION!',
           "InValid MARC Field selector");
    } catch {
        is(ref($_), 'Koha::Exception::BadParameter',
           "InValid MARC Field selector");

        ok($_->message =~ /is not a MARC field selector/,
           "Got a well formatted error message");
    };
    is(Koha::Validation::getMARCFieldSelectorCache,  undef, "InValidated MARC Field forgot");
    is(Koha::Validation::getMARCSubfieldSelectorCache, undef, "Not touched MARC Subfield not defined");

    is(Koha::Validation->tries('mrc', '110a', 'marcSubfieldSelector',),
       1,
       "Valid MARC Subfield selector");
    is(Koha::Validation::getMARCFieldSelectorCache,  '110', "Validated MARC Field remembered");
    is(Koha::Validation::getMARCSubfieldSelectorCache, 'a',   "Validated MARC Subfield remembered");

    try {
        is(Koha::Validation->tries('mrc', '110', 'marcSubfieldSelector',),
           'SHOULD THROW AN EXCEPTION!',
           "InValid MARC Subfield selector");
    } catch {
        is(ref($_), 'Koha::Exception::BadParameter',
           "InValid MARC Subfield selector");

        ok($_->message =~ /is not a MARC subfield selector/,
           "Got a well formatted error message");
    };
    is(Koha::Validation::getMARCFieldSelectorCache,  undef, "InValidated MARC Field forgot");
    is(Koha::Validation::getMARCSubfieldSelectorCache, undef, "InValidated MARC Subfield forgot");

    is(Koha::Validation->tries('mrc', '110a', 'marcSelector',),
       1,
       "Valid MARC selector");
    is(Koha::Validation::getMARCFieldSelectorCache,  '110', "Validated MARC Field remembered");
    is(Koha::Validation::getMARCSubfieldSelectorCache, 'a',   "Validated MARC Subfield remembered");

    is(Koha::Validation->tries('mrc', '245', 'marcSelector',),
       1,
       "Valid MARC selector");
    is(Koha::Validation::getMARCFieldSelectorCache, '245',  "Validated MARC Field remembered");
    is(Koha::Validation::getMARCSubfieldSelectorCache, '', "Not given MARC Subfield forgot");

    my ($f, $sf) = C4::Biblio::GetMarcFromKohaField('biblio.title', '');
    is(Koha::Validation->tries('mrc', 'biblio.title', 'marcSelector'),
       1,
       "biblio.title is a valid MARC Selector");
    is(Koha::Validation::getMARCFieldSelectorCache,    $f,  "Field from KohaToMarcMapping");
    is(Koha::Validation::getMARCSubfieldSelectorCache, $sf, "Subfield from KohaToMarcMapping");
}

subtest "DateTime", \&dateTime;
sub dateTime {
    my ($dt);

    $dt = DateTime->now();
    ok(Koha::Validation->tries('datetime', $dt, 'DateTime'),
       "Valid DateTime");

    try {
        $dt = '2014-05-22 15:44:45';
        ok(Koha::Validation->tries('datetime', $dt, 'DateTime'),
           "InValid DateTime");
    } catch {
        is(ref($_), 'Koha::Exception::BadParameter',
           "InValid DateTime");

        ok($_->message =~ /is not blessed/,
           "Got a well formatted error message");
    };

    try {
        $dt = {};
        bless($dt);
        ok(Koha::Validation->tries('datetime', $dt, 'DateTime'),
           "InValid DateTime");
    } catch {
        is(ref($_), 'Koha::Exception::BadParameter',
           "InValid DateTime");

        ok($_->message =~ /is not a valid 'DateTime'/,
           "Got a well formatted error message");
    };
}

subtest "Exception is of proper text format - without a package", \&exceptionTextFormatNoPackage;
sub exceptionTextFormatNoPackage {
    try {
        is(Koha::Validation->tries('key', 'A', 'string'),
           'SHOULD THROW AN EXCEPTION!',
           "Not a string, but a char");
    } catch {
        my @msgs = split("\n", $_->message());
        ok($msgs[1] =~ /^    at (?:(?:::)?\w+)+:\d+$/,
           "Package and line of code in the error");
    };
}

##Keep this package declaration in the bottom of the file, or it will mix the subroutine autodiscovery of our IDE!
#Time for some perl magic
package TestPackage::TestSubpackage {
use Test::More; use Try::Tiny;
subtest "Exception is of proper text format - withing packages", \&exceptionTextFormat;
sub exceptionTextFormat {
    try {
        is(Koha::Validation->tries('key', 'A', 'string'),
           'SHOULD THROW AN EXCEPTION!',
           "Not a string, but a char");
    } catch {
        my @msgs = split("\n", $_->message());
        is($msgs[0],
           "Koha::Validation::tries() 'key' => 'A' is not a valid 'string', but a char",
           "Got a well formatted error message");
        ok($msgs[1] =~ /^    at (?:(?:::)?\w+)+:\d+$/,
           "Package and line of code in the error");
    };
}
#done_testing(); #You might have to enable this depending on will there be new tests under this package/subtest
};

t::lib::TestObjects::ObjectFactory->tearDownTestContext($globalContext);
done_testing();
