#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright 2015 Mark Tompsett
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
use MARC::Record;
use MARC::Field;
use Test::More;
use C4::Context;
use Koha::Database;
use Data::Dumper;

BEGIN {
    use_ok('Koha::RecordProcessor');
}

our $VERSION = '3.23';    # Master version that I hope it gets in.

my $dbh = C4::Context->dbh;

my $database = Koha::Database->new();
my $schema   = $database->schema();
$schema->storage->txn_begin();

$dbh->{RaiseError} = 1;

$dbh->do(q{UPDATE marc_subfield_structure SET hidden=2 WHERE tagfield='020';});

my $isbn        = '0590353403';
my $title       = 'Foundation';
my $marc_record = MARC::Record->new;
my $field       = MARC::Field->new( '020', q{}, q{}, 'a' => $isbn );
$marc_record->append_fields($field);
$field = MARC::Field->new( '245', q{}, q{}, 'a' => $title );
$marc_record->append_fields($field);

my $processor = Koha::RecordProcessor->new(
    { filters => ('ViewPolicy'), options => { 'test' => 'value1' } } );
is(
    ref( $processor->filters->[0] ),
    'Koha::Filter::MARC::ViewPolicy',
    'Created record processor with implicitly scoped ViewPolicy filter'
);
my $after_record    = $processor->process($marc_record);
my $modified_record = $marc_record->clone;
my @isbn            = $modified_record->field('020');
$modified_record->delete_fields(@isbn);
is_deeply( $modified_record, $after_record,
    'Filtered and modified MARC record match' );

$schema->storage->txn_rollback();

done_testing();
