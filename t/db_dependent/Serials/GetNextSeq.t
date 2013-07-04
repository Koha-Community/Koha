#!/usr/bin/perl

use C4::Context;
use Test::More tests => 32;
use Modern::Perl;

my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;
$dbh->{AutoCommit} = 0;

use C4::Serials::Frequency;
use C4::Serials;

my $frequency = {
    description => "One issue per day",
    unit => 'day',
    issuesperunit => 1,
    unitsperissue => 1,
};
my $id = AddSubscriptionFrequency($frequency);

# TEST CASE 1 - 1 variable, from 1 to 4
my $pattern = {
             add1 =>  1,          add2 =>  0,          add3 =>  0,
           every1 =>  1,        every2 =>  0,        every3 =>  0,
    whenmorethan1 =>  4, whenmorethan2 =>  0, whenmorethan3 =>  0,
           setto1 =>  1,        setto2 =>  0,        setto3 =>  0,
    numberingmethod => 'X: {X}',
    numbering1 => '',
    numbering2 => '',
    numbering3 => '',
};

my $subscription = {
    periodicity => $id,
    firstacquidate => '1970-01-01',
    lastvalue1 => 1, lastvalue2 => 1, lastvalue3 => 1,
    innerloop1 => 0, innerloop2 => 0, innerloop3 => 0,
    skip_serialseq => 1,
    irregularity => '3;5',
    countissuesperunit => 1,
    locale => 'en',
};
my $publisheddate = $subscription->{firstacquidate};

my $seq = _next_seq($subscription, $pattern, $publisheddate);
is($seq, 'X: 2');
$publisheddate = GetNextDate($subscription, $publisheddate);
$seq = _next_seq($subscription, $pattern, $publisheddate);
is($seq, 'X: 4');
$publisheddate = GetNextDate($subscription, $publisheddate);
$seq = _next_seq($subscription, $pattern, $publisheddate);
is($seq, 'X: 2');
$publisheddate = GetNextDate($subscription, $publisheddate);
$seq = _next_seq($subscription, $pattern, $publisheddate);
is($seq, 'X: 3');

# TEST CASE 2 - 1 variable, use 'dayname' numbering, from 1 to 7
$subscription = {
    periodicity => $id,
    firstacquidate => '1970-01-01',
    lastvalue1 => 1, lastvalue2 => 1, lastvalue3 => 1,
    innerloop1 => 0, innerloop2 => 0, innerloop3 => 0,
    skip_serialseq => 1,
    irregularity => '3;4;6',
    countissuesperunit => 1,
    locale => 'C',
};
$pattern = {
             add1 =>  1,          add2 =>  0,          add3 =>  0,
           every1 =>  1,        every2 =>  0,        every3 =>  0,
    whenmorethan1 =>  7, whenmorethan2 =>  0, whenmorethan3 =>  0,
           setto1 =>  1,        setto2 =>  0,        setto3 =>  0,
    numberingmethod => 'X: {X}',
    numbering1 => 'dayname',
    numbering2 => '',
    numbering3 => '',
};

$publisheddate = $subscription->{firstacquidate};

$seq = _next_seq($subscription, $pattern, $publisheddate);
is($seq, 'X: Tuesday');
$publisheddate = GetNextDate($subscription, $publisheddate);
$seq = _next_seq($subscription, $pattern, $publisheddate);
is($seq, 'X: Friday');
$publisheddate = GetNextDate($subscription, $publisheddate);
$seq = _next_seq($subscription, $pattern, $publisheddate);
is($seq, 'X: Sunday');
$publisheddate = GetNextDate($subscription, $publisheddate);
$seq = _next_seq($subscription, $pattern, $publisheddate);
is($seq, 'X: Monday');
$publisheddate = GetNextDate($subscription, $publisheddate);
$seq = _next_seq($subscription, $pattern, $publisheddate);
is($seq, 'X: Tuesday');

# TEST CASE 3 - 1 variable, use 'monthname' numbering, from 0 to 11 by step of 2
$subscription = {
    periodicity => $id,
    firstacquidate => '1970-01-01',
    lastvalue1 => 0, lastvalue2 => 1, lastvalue3 => 1,
    innerloop1 => 0, innerloop2 => 0, innerloop3 => 0,
    skip_serialseq => 1,
    irregularity => '3;4;6',
    countissuesperunit => 1,
    locale => 'C',
};
$pattern = {
             add1 =>  2,          add2 =>  0,          add3 =>  0,
           every1 =>  1,        every2 =>  0,        every3 =>  0,
    whenmorethan1 => 11, whenmorethan2 =>  0, whenmorethan3 =>  0,
           setto1 =>  0,        setto2 =>  0,        setto3 =>  0,
    numberingmethod => 'X: {X}',
    numbering1 => 'monthname',
    numbering2 => '',
    numbering3 => '',
};

$publisheddate = $subscription->{firstacquidate};

$seq = _next_seq($subscription, $pattern, $publisheddate);
is($seq, 'X: March');
$publisheddate = GetNextDate($subscription, $publisheddate);
$seq = _next_seq($subscription, $pattern, $publisheddate);
is($seq, 'X: September');
$publisheddate = GetNextDate($subscription, $publisheddate);
$seq = _next_seq($subscription, $pattern, $publisheddate);
is($seq, 'X: January');
$publisheddate = GetNextDate($subscription, $publisheddate);
$seq = _next_seq($subscription, $pattern, $publisheddate);
is($seq, 'X: March');
$publisheddate = GetNextDate($subscription, $publisheddate);
$seq = _next_seq($subscription, $pattern, $publisheddate);
is($seq, 'X: May');

# TEST CASE 4 - 1 variable, use 'season' numbering, from 0 to 3
$subscription = {
    periodicity => $id,
    firstacquidate => '1970-01-01',
    lastvalue1 => 0, lastvalue2 => 1, lastvalue3 => 1,
    innerloop1 => 0, innerloop2 => 0, innerloop3 => 0,
    skip_serialseq => 1,
    irregularity => '3;4;6',
    countissuesperunit => 1,
    locale => 'C',
};
$pattern = {
             add1 =>  1,          add2 =>  0,          add3 =>  0,
           every1 =>  1,        every2 =>  0,        every3 =>  0,
    whenmorethan1 =>  3, whenmorethan2 =>  0, whenmorethan3 =>  0,
           setto1 =>  0,        setto2 =>  0,        setto3 =>  0,
    numberingmethod => 'X: {X}',
    numbering1 => 'season',
    numbering2 => '',
    numbering3 => '',
};

$publisheddate = $subscription->{firstacquidate};

$seq = _next_seq($subscription, $pattern, $publisheddate);
is($seq, 'X: Summer');
$publisheddate = GetNextDate($subscription, $publisheddate);
$seq = _next_seq($subscription, $pattern, $publisheddate);
is($seq, 'X: Spring');
$publisheddate = GetNextDate($subscription, $publisheddate);
$seq = _next_seq($subscription, $pattern, $publisheddate);
is($seq, 'X: Fall');
$publisheddate = GetNextDate($subscription, $publisheddate);
$seq = _next_seq($subscription, $pattern, $publisheddate);
is($seq, 'X: Winter');
$publisheddate = GetNextDate($subscription, $publisheddate);
$seq = _next_seq($subscription, $pattern, $publisheddate);
is($seq, 'X: Spring');

# TEST CASE 5 - 2 variables, from 1 to 12, and from 1 to 4
$subscription = {
    periodicity => $id,
    firstacquidate => '1970-01-01',
    lastvalue1 => 1, lastvalue2 => 1, lastvalue3 => 1,
    innerloop1 => 0, innerloop2 => 0, innerloop3 => 0,
    skip_serialseq => 1,
    irregularity => '3;4;6',
    countissuesperunit => 1,
    locale => 'C',
};
$pattern = {
             add1 =>  1,          add2 =>  1,          add3 =>  0,
           every1 =>  1,        every2 =>  4,        every3 =>  0,
    whenmorethan1 =>  4, whenmorethan2 => 12, whenmorethan3 =>  0,
           setto1 =>  1,        setto2 =>  1,        setto3 =>  0,
    numberingmethod => 'Y: {Y}, X: {X}',
    numbering1 => '',
    numbering2 => '',
    numbering3 => '',
};

$publisheddate = $subscription->{firstacquidate};

$seq = _next_seq($subscription, $pattern, $publisheddate);
is($seq, 'Y: 1, X: 2');
$publisheddate = GetNextDate($subscription, $publisheddate);
$seq = _next_seq($subscription, $pattern, $publisheddate);
is($seq, 'Y: 2, X: 1');
$publisheddate = GetNextDate($subscription, $publisheddate);
$seq = _next_seq($subscription, $pattern, $publisheddate);
is($seq, 'Y: 2, X: 3');
$publisheddate = GetNextDate($subscription, $publisheddate);
$seq = _next_seq($subscription, $pattern, $publisheddate);
is($seq, 'Y: 2, X: 4');
$publisheddate = GetNextDate($subscription, $publisheddate);
$seq = _next_seq($subscription, $pattern, $publisheddate);
is($seq, 'Y: 3, X: 1');

# TEST CASE 6 - 3 variables, from 1 to 12, from 1 to 8, and from 1 to 4
$subscription = {
    periodicity => $id,
    firstacquidate => '1970-01-01',
    lastvalue1 => 1, lastvalue2 => 1, lastvalue3 => 1,
    innerloop1 => 0, innerloop2 => 0, innerloop3 => 0,
    skip_serialseq => 1,
    irregularity => '3;4;6;110',
    countissuesperunit => 1,
    locale => 'C',
};
$pattern = {
             add1 =>  1,          add2 =>  1,          add3 =>  1,
           every1 =>  1,        every2 =>  4,        every3 => 32,
    whenmorethan1 =>  4, whenmorethan2 =>  8, whenmorethan3 => 12,
           setto1 =>  1,        setto2 =>  1,        setto3 =>  1,
    numberingmethod => 'Z: {Z}, Y: {Y}, X: {X}',
    numbering1 => '',
    numbering2 => '',
    numbering3 => '',
};

$publisheddate = $subscription->{firstacquidate};

$seq = _next_seq($subscription, $pattern, $publisheddate);
is($seq, 'Z: 1, Y: 1, X: 2');
$publisheddate = GetNextDate($subscription, $publisheddate);
$seq = _next_seq($subscription, $pattern, $publisheddate);
is($seq, 'Z: 1, Y: 2, X: 1');
$publisheddate = GetNextDate($subscription, $publisheddate);
$seq = _next_seq($subscription, $pattern, $publisheddate);
is($seq, 'Z: 1, Y: 2, X: 3');
$publisheddate = GetNextDate($subscription, $publisheddate);
$seq = _next_seq($subscription, $pattern, $publisheddate);
is($seq, 'Z: 1, Y: 2, X: 4');
for (1..100) {
    $publisheddate = GetNextDate($subscription, $publisheddate);
    $seq = _next_seq($subscription, $pattern, $publisheddate);
}
$publisheddate = GetNextDate($subscription, $publisheddate);
$seq = _next_seq($subscription, $pattern, $publisheddate);
is($seq, 'Z: 4, Y: 4, X: 1');
# 110th is here
$publisheddate = GetNextDate($subscription, $publisheddate);
$seq = _next_seq($subscription, $pattern, $publisheddate);
is($seq, 'Z: 4, Y: 4, X: 3');
$publisheddate = GetNextDate($subscription, $publisheddate);
$seq = _next_seq($subscription, $pattern, $publisheddate);
is($seq, 'Z: 4, Y: 4, X: 4');
$publisheddate = GetNextDate($subscription, $publisheddate);
$seq = _next_seq($subscription, $pattern, $publisheddate);
is($seq, 'Z: 4, Y: 5, X: 1');


$dbh->rollback;

sub _next_seq {
    my ($subscription, $pattern, $publisheddate) = @_;
    my $seq;
    ($seq, $subscription->{lastvalue1}, $subscription->{lastvalue2},
        $subscription->{lastvalue3}, $subscription->{innerloop1},
        $subscription->{innerloop2}, $subscription->{innerloop3}) =
            GetNextSeq($subscription, $pattern, $publisheddate);
    return $seq;
}
