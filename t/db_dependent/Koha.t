#!/usr/bin/perl
#
# This is to test C4/Koha
# It requires a working Koha database with the sample data

use strict;
use warnings;
use C4::Context;

use Test::More tests => 6;
use DateTime::Format::MySQL;

eval {use Test::Deep;};

BEGIN {
    use_ok('C4::Koha', qw( :DEFAULT GetDailyQuote ));
    use_ok('C4::Members');
}

my $dbh = C4::Context->dbh;

subtest 'Authorized Values Tests' => sub {
    plan tests => 6;

    my $data = {
        category            => 'CATEGORY',
        authorised_value    => 'AUTHORISED_VALUE',
        lib                 => 'LIB',
        lib_opac            => 'LIBOPAC',
        imageurl            => 'IMAGEURL'
    };


# Insert an entry into authorised_value table
    my $query = "INSERT INTO authorised_values (category, authorised_value, lib, lib_opac, imageurl) VALUES (?,?,?,?,?);";
    my $sth = $dbh->prepare($query);
    my $insert_success = $sth->execute($data->{category}, $data->{authorised_value}, $data->{lib}, $data->{lib_opac}, $data->{imageurl});
    ok($insert_success, "Insert data in database");


# Tests
    SKIP: {
        skip "INSERT failed", 5 unless $insert_success;

        is ( GetAuthorisedValueByCode($data->{category}, $data->{authorised_value}), $data->{lib}, "GetAuthorisedValueByCode" );
        is ( GetKohaImageurlFromAuthorisedValues($data->{category}, $data->{lib}), $data->{imageurl}, "GetKohaImageurlFromAuthorisedValues" );

        my $sortdet=C4::Members::GetSortDetails("lost", "3");
        is ($sortdet, "Lost and Paid For", "lost and paid works");

        my $sortdet2=C4::Members::GetSortDetails("loc", "child");
        is ($sortdet2, "Children's Area", "Child area works");

        my $sortdet3=C4::Members::GetSortDetails("withdrawn", "1");
        is ($sortdet3, "Withdrawn", "Withdrawn works");
    }

# Clean up
    if($insert_success){
        $query = "DELETE FROM authorised_values WHERE category=? AND authorised_value=? AND lib=? AND lib_opac=? AND imageurl=?;";
        $sth = $dbh->prepare($query);
        $sth->execute($data->{category}, $data->{authorised_value}, $data->{lib}, $data->{lib_opac}, $data->{imageurl});
    }
};

subtest 'Itemtype info Tests' => sub {
    like ( getitemtypeinfo('BK')->{'imageurl'}, qr/intranet-tmpl/, 'getitemtypeinfo on unspecified interface returns intranet imageurl (legacy behavior)' );
    like ( getitemtypeinfo('BK', 'intranet')->{'imageurl'}, qr/intranet-tmpl/, 'getitemtypeinfo on "intranet" interface returns intranet imageurl' );
    like ( getitemtypeinfo('BK', 'opac')->{'imageurl'}, qr/opac-tmpl/, 'getitemtypeinfo on "opac" interface returns opac imageurl' );
};















### test for C4::Koha->GetDailyQuote()
SKIP:
    {
        skip "Test::Deep required to run the GetDailyQuote tests.", 1 if $@;

        subtest 'Daily Quotes Test' => sub {
            plan tests => 4;

            SKIP: {

                skip "C4::Koha can't \'GetDailyQuote\'!", 3 unless can_ok('C4::Koha','GetDailyQuote');

                my $expected_quote = {
                    id          => 3,
                    source      => 'Abraham Lincoln',
                    text        => 'Four score and seven years ago our fathers brought forth on this continent, a new nation, conceived in Liberty, and dedicated to the proposition that all men are created equal.',
                    timestamp   => re('\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}'),   #'0000-00-00 00:00:00',
                };

# test quote retrieval based on id

                my $quote = GetDailyQuote('id'=>3);
                cmp_deeply ($quote, $expected_quote, "Got a quote based on id.") or
                    diag('Be sure to run this test on a clean install of sample data.');

# test random quote retrieval

                $quote = GetDailyQuote('random'=>1);
                ok ($quote, "Got a random quote.");

# test quote retrieval based on today's date

                my $query = 'UPDATE quotes SET timestamp = ? WHERE id = ?';
                my $sth = C4::Context->dbh->prepare($query);
                $sth->execute(DateTime::Format::MySQL->format_datetime(DateTime->now), $expected_quote->{'id'});

                DateTime::Format::MySQL->format_datetime(DateTime->now) =~ m/(\d{4}-\d{2}-\d{2})/;
                $expected_quote->{'timestamp'} = re("^$1");

#        $expected_quote->{'timestamp'} = DateTime::Format::MySQL->format_datetime(DateTime->now);   # update the timestamp of expected quote data

                $quote = GetDailyQuote(); # this is the "default" mode of selection
                cmp_deeply ($quote, $expected_quote, "Got a quote based on today's date.") or
                    diag('Be sure to run this test on a clean install of sample data.');
            }
        };
}


#
# test that &slashifyDate returns correct (non-US) date
#
subtest 'Date and ISBN tests' => sub {
    plan tests => 7;

    my $date    = "01/01/2002";
    my $newdate = &slashifyDate("2002-01-01");
    my $isbn13  = "9780330356473";
    my $isbn13D = "978-0-330-35647-3";
    my $isbn10  = "033035647X";
    my $isbn10D = "0-330-35647-X";
    ok( $date eq $newdate, 'slashifyDate' );
    my $undef = undef;
    is( xml_escape($undef), '',
        'xml_escape() returns empty string on undef input' );
    my $str = q{'"&<>'};
    is(
        xml_escape($str),
        '&apos;&quot;&amp;&lt;&gt;&apos;',
        'xml_escape() works as expected'
    );
    is( $str, q{'"&<>'}, '... and does not change input in place' );
    is( C4::Koha::_isbn_cleanup('0-590-35340-3'),
        '0590353403', '_isbn_cleanup removes hyphens' );
    is( C4::Koha::_isbn_cleanup('0590353403 (pbk.)'),
        '0590353403', '_isbn_cleanup removes parenthetical' );
    is( C4::Koha::_isbn_cleanup('978-0-321-49694-2'),
        '0321496949', '_isbn_cleanup converts ISBN-13 to ISBN-10' );

};
