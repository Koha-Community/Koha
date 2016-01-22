#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright (C) 2016 ByWater Solutions
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
use Test::More tests => 13;

use MARC::Record;

use t::lib::TestBuilder;

use C4::Letters;
use C4::Members;
use C4::Biblio;
use Koha::Database;
use Koha::DateUtils;
use Koha::Biblio;
use Koha::Biblioitem;
use Koha::Item;
use Koha::Hold;
use Koha::NewsItem;
use Koha::Serial;
use Koha::Subscription;
use Koha::Suggestion;
use Koha::Checkout;
use Koha::Patron::Modification;

my $schema = Koha::Database->schema;
$schema->storage->txn_begin();

my $builder = t::lib::TestBuilder->new();

my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;

$dbh->do(q|DELETE FROM letter|);

my $date = dt_from_string;

my $library = $builder->build( { source => 'Branch' } );
my $patron  = $builder->build( { source => 'Borrower' } );
my $patron2 = $builder->build( { source => 'Borrower' } );

my $biblio = Koha::Biblio->new(
    {
        title => 'Test Biblio'
    }
)->store();

my $biblioitem = Koha::Biblioitem->new(
    {
        biblionumber => $biblio->id()
    }
)->store();

my $item = Koha::Item->new(
    {
        biblionumber     => $biblio->id(),
        biblioitemnumber => $biblioitem->id()
    }
)->store();

my $hold = Koha::Hold->new(
    {
        borrowernumber => $patron->{borrowernumber},
        biblionumber   => $biblio->id()
    }
)->store();

my $news         = Koha::NewsItem->new()->store();
my $serial       = Koha::Serial->new()->store();
my $subscription = Koha::Subscription->new()->store();
my $suggestion   = Koha::Suggestion->new()->store();
my $checkout     = Koha::Checkout->new( { itemnumber => $item->id() } )->store();
my $modification = Koha::Patron::Modification->new( { verification_token => "TEST" } )->store();

my $prepared_letter;

my $sth =
  $dbh->prepare(q{INSERT INTO letter (module, code, name, title, content) VALUES ('test',?,'Test','Test',?)});

$sth->execute( "TEST_PATRON", "[% borrower.id %]" );
$prepared_letter = GetPreparedLetter(
    (
        module      => 'test',
        letter_code => 'TEST_PATRON',
        tables      => {
            borrowers => $patron->{borrowernumber},
        },
    )
);
is( $prepared_letter->{content}, $patron->{borrowernumber}, 'Patron object used correctly with scalar' );

$prepared_letter = GetPreparedLetter(
    (
        module      => 'test',
        letter_code => 'TEST_PATRON',
        tables      => {
            borrowers => $patron,
        },
    )
);
is( $prepared_letter->{content}, $patron->{borrowernumber}, 'Patron object used correctly with hashref' );

$prepared_letter = GetPreparedLetter(
    (
        module      => 'test',
        letter_code => 'TEST_PATRON',
        tables      => {
            borrowers => [ $patron->{borrowernumber} ],
        },
    )
);
is( $prepared_letter->{content}, $patron->{borrowernumber}, 'Patron object used correctly with arrayref' );

$sth->execute( "TEST_BIBLIO", "[% biblio.id %]" );
$prepared_letter = GetPreparedLetter(
    (
        module      => 'test',
        letter_code => 'TEST_BIBLIO',
        tables      => {
            biblio => $biblio->id(),
        },
    )
);
is( $prepared_letter->{content}, $biblio->id, 'Biblio object used correctly' );

$sth->execute( "TEST_LIBRARY", "[% branch.id %]" );
$prepared_letter = GetPreparedLetter(
    (
        module      => 'test',
        letter_code => 'TEST_LIBRARY',
        tables      => {
            branches => $library->{branchcode}
        },
    )
);
is( $prepared_letter->{content}, $library->{branchcode}, 'Library object used correctly' );

$sth->execute( "TEST_ITEM", "[% item.id %]" );
$prepared_letter = GetPreparedLetter(
    (
        module      => 'test',
        letter_code => 'TEST_ITEM',
        tables      => {
            items => $item->id()
        },
    )
);
is( $prepared_letter->{content}, $item->id(), 'Item object used correctly' );

$sth->execute( "TEST_NEWS", "[% news.id %]" );
$prepared_letter = GetPreparedLetter(
    (
        module      => 'test',
        letter_code => 'TEST_NEWS',
        tables      => {
            opac_news => $news->id()
        },
    )
);
is( $prepared_letter->{content}, $news->id(), 'News object used correctly' );

$sth->execute( "TEST_HOLD", "[% hold.id %]" );
$prepared_letter = GetPreparedLetter(
    (
        module      => 'test',
        letter_code => 'TEST_HOLD',
        tables      => {
            reserves => [ $patron->{borrowernumber}, $biblio->id() ]
        },
    )
);
is( $prepared_letter->{content}, $hold->id(), 'Hold object used correctly' );

$sth->execute( "TEST_SERIAL", "[% serial.id %]" );
$prepared_letter = GetPreparedLetter(
    (
        module      => 'test',
        letter_code => 'TEST_SERIAL',
        tables      => {
            serial => $serial->id()
        },
    )
);
is( $prepared_letter->{content}, $serial->id(), 'Serial object used correctly' );

$sth->execute( "TEST_SUBSCRIPTION", "[% subscription.id %]" );
$prepared_letter = GetPreparedLetter(
    (
        module      => 'test',
        letter_code => 'TEST_SUBSCRIPTION',
        tables      => {
            subscription => $subscription->id()
        },
    )
);
is( $prepared_letter->{content}, $subscription->id(), 'Subscription object used correctly' );

$sth->execute( "TEST_SUGGESTION", "[% suggestion.id %]" );
$prepared_letter = GetPreparedLetter(
    (
        module      => 'test',
        letter_code => 'TEST_SUGGESTION',
        tables      => {
            suggestions => $suggestion->id()
        },
    )
);
is( $prepared_letter->{content}, $suggestion->id(), 'Suggestion object used correctly' );

$sth->execute( "TEST_ISSUE", "[% checkout.id %]" );
$prepared_letter = GetPreparedLetter(
    (
        module      => 'test',
        letter_code => 'TEST_ISSUE',
        tables      => {
            issues => $item->id()
        },
    )
);
is( $prepared_letter->{content}, $checkout->id(), 'Checkout object used correctly' );

$sth->execute( "TEST_MODIFICATION", "[% patron_modification.id %]" );
$prepared_letter = GetPreparedLetter(
    (
        module      => 'test',
        letter_code => 'TEST_MODIFICATION',
        tables      => {
            borrower_modifications => $modification->verification_token,
        },
    )
);
is( $prepared_letter->{content}, $modification->id(), 'Patron modification object used correctly' );
