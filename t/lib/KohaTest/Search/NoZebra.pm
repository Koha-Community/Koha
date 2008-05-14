package KohaTest::Search::NoZebra;
use base qw( KohaTest::Search );

use strict;
use warnings;

use Test::More;

use MARC::Record;

use C4::Search;
use C4::Biblio;
use C4::Context;

=head2 STARTUP METHODS

These get run once, before the main test methods in this module

=cut

=head3 startup_50_init_nozebra

Turn on NoZebra mode, for now, assumes and requires
that the test database has started out using Zebra.

=cut

sub startup_50_init_nozebra : Test( startup => 3 ) {
    my $using_nozebra = C4::Context->preference('NoZebra');
    ok(!$using_nozebra, "starting out using Zebra");
    my $dbh = C4::Context->dbh;
    $dbh->do("UPDATE systempreferences SET value=1 WHERE variable='NoZebra'");
    $dbh->do("UPDATE systempreferences SET value=0 WHERE variable in ('QueryFuzzy','QueryWeightFields','QueryStemming')");
    $using_nozebra = C4::Context->preference('NoZebra');
    ok($using_nozebra, "switched to NoZebra");

    my $sth = $dbh->prepare("SELECT COUNT(*) FROM nozebra");
    $sth->execute;
    my ($count) = $sth->fetchrow_array;
    $sth->finish;
    cmp_ok($count, '==', 0, "NoZebra index starts off empty");
}

sub startup_51_add_bibs : Test( startup => 2 ) {
    my $self = shift;

    my $bib1 = MARC::Record->new();
    $bib1->leader('     nam a22     7a 4500');
    $bib1->append_fields(
        MARC::Field->new('010', ' ', ' ', a => 'lccn001'), 
        MARC::Field->new('020', ' ', ' ', a => 'isbn001'), 
        MARC::Field->new('022', ' ', ' ', a => 'issn001'), 
        MARC::Field->new('100', ' ', ' ', a => 'Cat, Felix T.'),
        MARC::Field->new('245', ' ', ' ', a => 'Of mice and men :', b=> 'a history'),
    );
    my $bib2 = MARC::Record->new();
    $bib2->leader('     nam a22     7a 4500');
    $bib2->append_fields(
        MARC::Field->new('010', ' ', ' ', a => 'lccn002'), 
        MARC::Field->new('020', ' ', ' ', a => 'isbn002'), 
        MARC::Field->new('022', ' ', ' ', a => 'issn002'), 
        MARC::Field->new('100', ' ', ' ', a => 'Dog, Rover T.'),
        MARC::Field->new('245', ' ', ' ', a => 'Of mice and men :', b=> 'a digression'),
    );

    my $dbh = C4::Context->dbh;
    my $count_sth = $dbh->prepare("SELECT COUNT(*) FROM nozebra");
    my $count;
    my ($bib1_bibnum, $bib1_bibitemnum) = AddBiblio($bib1, '');
    $count_sth->execute;
    ($count) = $count_sth->fetchrow_array;
    cmp_ok($count, '==', 14, "correct number of new words indexed"); # tokens + biblionumber + __RAW__

    my ($bib2_bibnum, $bib2_bibitemnum) = AddBiblio($bib2, '');
    $count_sth->execute;
    ($count) = $count_sth->fetchrow_array;
    cmp_ok($count, '==', 22, "correct number of new words indexed"); # tokens + biblionumber + __RAW__

    push @{ $self->{nozebra_test_bibs} }, $bib1_bibnum, $bib2_bibnum;
}

=head2 TEST METHODS

Standard test methods

=cut

sub basic_searches_via_nzanalyze : Test( 28 ) {
    my $self = shift;
    my ($bib1_bibnum, $bib2_bibnum) = @{ $self->{nozebra_test_bibs} };
    
    my $results = C4::Search::NZanalyse('foobar');
    ok(!defined($results), "no hits on 'foobar'");

    $results = C4::Search::NZanalyse('dog');
    my ($hits, @bibnumbers) = parse_nzanalyse($results);
    cmp_ok($hits, '==', 1, "one hit on 'dog'");
    is($bib2_bibnum, $bibnumbers[0], "correct hit on 'dog'");

    $results = C4::Search::NZanalyse('au=dog');
    ($hits, @bibnumbers) = parse_nzanalyse($results);
    cmp_ok($hits, '==', 1, "one hit on 'au=dog'");
    is($bib2_bibnum, $bibnumbers[0], "correct hit on 'au=dog'");

    $results = C4::Search::NZanalyse('isbn=dog');
    ($hits, @bibnumbers) = parse_nzanalyse($results);
    cmp_ok($hits, '==', 0, "zero hits on 'isbn=dog'");

    $results = C4::Search::NZanalyse('cat');
    ($hits, @bibnumbers) = parse_nzanalyse($results);
    cmp_ok($hits, '==', 1, "one hit on 'cat'");
    is($bib1_bibnum, $bibnumbers[0], "correct hit on 'cat'");

    $results = C4::Search::NZanalyse('cat and dog');
    ($hits, @bibnumbers) = parse_nzanalyse($results);
    cmp_ok($hits, '==', 0, "zero hits on 'cat and dog'");

    $results = C4::Search::NZanalyse('cat or dog');
    ($hits, @bibnumbers) = parse_nzanalyse($results);
    cmp_ok($hits, '==', 2, "two hits on 'cat or dog'");
    is_deeply([ sort @bibnumbers ], [ sort($bib1_bibnum, $bib2_bibnum) ], "correct hits on 'cat or dog'");

    $results = C4::Search::NZanalyse('mice and men');
    ($hits, @bibnumbers) = parse_nzanalyse($results);
    cmp_ok($hits, '==', 2, "two hits on 'mice and men'");
    is_deeply([ sort @bibnumbers ], [ sort($bib1_bibnum, $bib2_bibnum) ], "correct hits on 'mice and men'");

    $results = C4::Search::NZanalyse('title=digression or issn=issn001');
    ($hits, @bibnumbers) = parse_nzanalyse($results);
    cmp_ok($hits, '==', 2, "two hits on 'title=digression or issn=issn001'");
    is_deeply([ sort @bibnumbers ], [ sort($bib1_bibnum, $bib2_bibnum) ], "correct hits on 'title=digression or issn=issn001'");

    $results = C4::Search::NZanalyse('title=digression and issn=issn002');
    ($hits, @bibnumbers) = parse_nzanalyse($results);
    cmp_ok($hits, '==', 1, "two hits on 'title=digression and issn=issn002'");
    is($bib2_bibnum, $bibnumbers[0], "correct hit on 'title=digression and issn=issn002'");

    $results = C4::Search::NZanalyse('mice not men');
    ($hits, @bibnumbers) = parse_nzanalyse($results);
    cmp_ok($hits, '==', 0, "zero hits on 'mice not men'");

    $results = C4::Search::NZanalyse('mice not dog');
    ($hits, @bibnumbers) = parse_nzanalyse($results);
    cmp_ok($hits, '==', 1, "one hit on 'mice not dog'");
    is($bib1_bibnum, $bibnumbers[0], "correct hit on 'mice not dog'");

    $results = C4::Search::NZanalyse('isbn > a');
    ($hits, @bibnumbers) = parse_nzanalyse($results);
    cmp_ok($hits, '==', 2, "two hits on 'isbn > a'");
    is_deeply([ sort @bibnumbers ], [ sort($bib1_bibnum, $bib2_bibnum) ], "correct hits on 'isbn > a'");

    $results = C4::Search::NZanalyse('isbn < z');
    ($hits, @bibnumbers) = parse_nzanalyse($results);
    cmp_ok($hits, '==', 2, "two hits on 'isbn < z'");
    is_deeply([ sort @bibnumbers ], [ sort($bib1_bibnum, $bib2_bibnum) ], "correct hits on 'isbn < z'");

    $results = C4::Search::NZanalyse('isbn > isbn001');
    ($hits, @bibnumbers) = parse_nzanalyse($results);
    cmp_ok($hits, '==', 1, "one hit on 'isbn > isbn001'");
    is($bib2_bibnum, $bibnumbers[0], "correct hit on 'isbn > isbn001'");

    $results = C4::Search::NZanalyse('isbn>=isbn001');
    ($hits, @bibnumbers) = parse_nzanalyse($results);
    cmp_ok($hits, '==', 2, "two hits on 'isbn>=isbn001'");
    is_deeply([ sort @bibnumbers ], [ sort($bib1_bibnum, $bib2_bibnum) ], "correct hits on 'isbn>=isbn001'");
}

sub parse_nzanalyse {
    my $results = shift;
    my @bibnumbers = ();
    if (defined $results) {
        # NZanalyze currently has a funky way of returning results -
        # it does not guarantee that a biblionumber occurs only
        # once in the results string.  Hence we must remove
        # duplicates, like NZorder (inefficently) does
        my %hash;
        @bibnumbers = grep { ++$hash{$_} == 1 }  map { my @f = split /,/, $_; $f[0]; } split /;/, $results;
    }
    return scalar(@bibnumbers), @bibnumbers;
}

=head2 SHUTDOWN METHODS

These get run once, after all of the main tests methods in this module

=cut

sub shutdown_49_remove_bibs : Test( shutdown => 4 ) {
    my $self = shift;
    my ($bib1_bibnum, $bib2_bibnum) = @{ $self->{nozebra_test_bibs} };

    my $dbh = C4::Context->dbh;
    my $count_sth = $dbh->prepare("SELECT COUNT(*) FROM nozebra");
    my $count;

    my $error = DelBiblio($bib2_bibnum);
    ok(!defined($error), "deleted bib $bib2_bibnum");
    $count_sth->execute;
    ($count) = $count_sth->fetchrow_array;
    TODO: { local $TODO = 'nothing actually gets deleted from nozebra currently';
    cmp_ok($count, '==', 14, "correct number of words indexed after bib $bib2_bibnum deleted"); 
    }

    $error = DelBiblio($bib1_bibnum);
    ok(!defined($error), "deleted bib $bib1_bibnum");
    $count_sth->execute;
    ($count) = $count_sth->fetchrow_array;
    TODO: { local $TODO = 'nothing actually gets deleted from nozebra currently';
    cmp_ok($count, '==', 0, "no entries left in nozebra after bib $bib1_bibnum deleted"); 
    }

    delete $self->{nozebra_test_bibs};
}

sub shutdown_50_init_nozebra : Test( shutdown => 3 ) {
    my $using_nozebra = C4::Context->preference('NoZebra');
    ok($using_nozebra, "still in NoZebra mode");
    my $dbh = C4::Context->dbh;
    $dbh->do("UPDATE systempreferences SET value=0 WHERE variable='NoZebra'");
    $dbh->do("UPDATE systempreferences SET value=1 WHERE variable in ('QueryFuzzy','QueryWeightFields','QueryStemming')");
    $using_nozebra = C4::Context->preference('NoZebra');
    ok(!$using_nozebra, "switched to Zebra");

    # FIXME
    $dbh->do("DELETE FROM nozebra");
    my $sth = $dbh->prepare("SELECT COUNT(*) FROM nozebra");
    $sth->execute;
    my ($count) = $sth->fetchrow_array;
    $sth->finish;
    cmp_ok($count, '==', 0, "NoZebra index finishes up empty");
}

1;
