#!/usr/bin/perl
#
# This is to test C4/Koha
# It requires a working Koha database with the sample data

use strict;
use warnings;
use C4::Context;

use Test::More tests => 3;

BEGIN {
    use_ok('C4::Koha');
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
$sth->execute($data->{category}, $data->{authorised_value}, $data->{lib}, $data->{lib_opac}, $data->{imageurl});

# Tests
is ( GetAuthorisedValueByCode($data->{category}, $data->{authorised_value}), $data->{lib}, "GetAuthorisedValueByCode" );
is ( GetKohaImageurlFromAuthorisedValues($data->{category}, $data->{lib}), $data->{imageurl}, "GetKohaImageurlFromAuthorisedValues" );

# Clean up
$query = "DELETE FROM authorised_values WHERE category=? AND authorised_value=? AND lib=? AND lib_opac=? AND imageurl=?;";
$sth = $dbh->prepare($query);
$sth->execute($data->{category}, $data->{authorised_value}, $data->{lib}, $data->{lib_opac}, $data->{imageurl});

