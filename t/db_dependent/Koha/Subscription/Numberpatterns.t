#!/usr/bin/perl

# Copyright 2017 BibLibre
#
# This file is part of Koha
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

use t::lib::TestBuilder;
use Test::NoWarnings;
use Test::More tests => 7;
use Koha::Database;

use_ok('Koha::Subscription::Numberpatterns');

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;

my $dbh = C4::Context->dbh;
$dbh->do('DELETE FROM subscription_numberpatterns');

my $numberpattern = $builder->build(
    {
        source => 'SubscriptionNumberpattern',
        value  => {
            label           => 'Volume, Number, Issue',
            description     => 'Volume Number Issue 1',
            numberingmethod => 'Vol.{X}, Number {Y}, Issue {Z}',
            label1          => 'Volume',
            add1            => '1',
            every1          => '48',
            whenmorethan1   => '99999',
            setto1          => '1',
            numbering1      => undef,
            label2          => 'Number',
            add2            => '1',
            every2          => '4',
            whenmorethan2   => '12',
            setto2          => '1',
            numbering2      => undef,
            label3          => 'Issue',
            add3            => '1',
            every3          => '1',
            whenmorethan3   => '4',
            setto3          => '1',
            numbering3      => undef
        }
    }
);

my $search_ok = {
    umberingmethod    => 'Vol.{X}, Number {Y}, Issue {Z}',
    label1            => 'Volume', add1   => '1', every1 => '48',
    whenmorethan1     => '99999',  setto1 => '1',
    label2            => 'Number', add2   => '1', every2 => '4',
    whenmorethan2     => '12',     setto2 => '1',
    label3            => 'Issue',  add3   => '1', every3 => '1',
    whenmorethan3     => '4',      setto3 => '1',
    numbering_pattern => 'mana'
};

my $number_pattern_id = Koha::Subscription::Numberpatterns->new_or_existing($search_ok);
is( $number_pattern_id, $numberpattern->{id}, 'new_or_existing method should find the existing number pattern' );

$number_pattern_id = Koha::Subscription::Numberpatterns->new_or_existing( { numbering_pattern => 1 } );
is( $number_pattern_id, 1, 'new_or_existing method should return passed numbering_pattern' );

my $search_not_ok = {
    patternname       => 'Number',
    sndescription     => 'Simple Numbering method',
    numberingmethod   => 'No.{X}',
    label1            => 'Number',
    add1              => 1,
    every1            => 1,
    whenmorethan1     => 99999,
    setto1            => 1,
    numbering_pattern => 'mana'
};

$number_pattern_id = Koha::Subscription::Numberpatterns->new_or_existing($search_not_ok);
my $new_number_pattern = Koha::Subscription::Numberpatterns->find($number_pattern_id);
is( $new_number_pattern->label,           'Number' );
is( $new_number_pattern->description,     'Simple Numbering method' );
is( $new_number_pattern->numberingmethod, 'No.{X}' );

$schema->storage->txn_rollback;
