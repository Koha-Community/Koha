#!/usr/bin/perl

use Modern::Perl;

use C4::Context;
use C4::Overdues;
use Koha::Database;
use Koha::DateUtils;

use Test::More tests => 5;

#Start transaction
my $dbh = C4::Context->dbh;
my $schema = Koha::Database->new()->schema();

$dbh->{RaiseError} = 1;
$dbh->{AutoCommit} = 0;

$dbh->do(q|DELETE FROM issuingrules|);

my $issuingrule = $schema->resultset('Issuingrule')->create(
    {
        categorycode           => '*',
        itemtype               => '*',
        branchcode             => '*',
        fine                   => 1,
        finedays               => 0,
        chargeperiod           => 7,
        chargeperiod_charge_at => 0,
        lengthunit             => 'days',
        issuelength            => 1,
    }
);

ok( $issuingrule, 'Issuing rule created' );

my $period_start = dt_from_string('2000-01-01');
my $period_end = dt_from_string('2000-01-05');

my ( $fine ) = CalcFine( {}, q{}, q{}, $period_start, $period_end  );
is( $fine, 0, '4 days overdue, charge period 7 days, charge at end of interval gives fine of $0' );

$period_end = dt_from_string('2000-01-10');
( $fine ) = CalcFine( {}, q{}, q{}, $period_start, $period_end  );
is( $fine, 1, '9 days overdue, charge period 7 days, charge at end of interval gives fine of $1' );

# Test charging fine at the *beginning* of each charge period
$issuingrule->update( { chargeperiod_charge_at => 1 } );

$period_end = dt_from_string('2000-01-05');
( $fine ) = CalcFine( {}, q{}, q{}, $period_start, $period_end  );
is( $fine, 1, '4 days overdue, charge period 7 days, charge at start of interval gives fine of $1' );

$period_end = dt_from_string('2000-01-10');
( $fine ) = CalcFine( {}, q{}, q{}, $period_start, $period_end  );
is( $fine, 2, '9 days overdue, charge period 7 days, charge at start of interval gives fine of $2' );
