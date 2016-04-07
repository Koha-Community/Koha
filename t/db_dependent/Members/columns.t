#!/usr/bin/perl
#
# This is to test C4/Members
# It requires a working Koha database with the sample data

use Modern::Perl;

use Test::More tests => 2;

BEGIN {
    use_ok('C4::Members');
}

my @borrowers_columns = C4::Members::columns;
ok(
    $#borrowers_columns > 1,
    'C4::Member->column returned a reasonable number of columns ('
      . ( $#borrowers_columns + 1 ) . ')'
  )
  or diag(
'WARNING: Check that the borrowers table exists and has the correct fields defined.'
  );

exit;
