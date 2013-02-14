#!/usr/bin/perl
#
# This is to test C4/Koha
# It requires a working Koha database with the sample data

use strict;
use warnings;
use C4::Context;

use Test::More tests => 9;

BEGIN {
    use_ok('C4::Koha');
    use_ok('C4::Members');
}

my $data = {
    category            => 'CATEGORY',
    authorised_value    => 'AUTHORISED_VALUE',
    lib                 => 'LIB',
    lib_opac            => 'LIBOPAC',
    imageurl            => 'IMAGEURL'
};

my $dbh = C4::Context->dbh;

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

subtest 'Itemtype info Tests' => sub {
    like ( getitemtypeinfo('BK')->{'imageurl'}, qr/intranet-tmpl/, 'getitemtypeinfo on unspecified interface returns intranet imageurl (legacy behavior)' );
    like ( getitemtypeinfo('BK', 'intranet')->{'imageurl'}, qr/intranet-tmpl/, 'getitemtypeinfo on "intranet" interface returns intranet imageurl' );
    like ( getitemtypeinfo('BK', 'opac')->{'imageurl'}, qr/opac-tmpl/, 'getitemtypeinfo on "opac" interface returns opac imageurl' );
};

