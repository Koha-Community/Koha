#!/usr/bin/perl
#
# Copyright 2007 Foundations Bible College.
# Copyright 2013 BibLibre
#
# This file is part of Koha.
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

use Test::More tests => 24;
use MARC::Record;
use MARC::Field;

use t::lib::TestBuilder;

use C4::Context;
use C4::Biblio;
use C4::Items;
use Koha::Libraries;

BEGIN {
    use_ok('C4::Labels::Batch');
}

# Start transaction
my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

my $builder = t::lib::TestBuilder->new;
$builder->build({ source => 'Branch', value => { branchcode => 'CPL' } })
    unless Koha::Libraries->find('CPL');

my $sth = $dbh->prepare('SELECT branchcode FROM branches b LIMIT 0,1');
$sth->execute();
my $branch_code = $sth->fetchrow_hashref()->{'branchcode'};
diag sprintf('Database returned the following error: %s', $sth->errstr) if $sth->errstr;

my $expected_batch = {
        creator         => 'Labels',
        items           => [],
        branch_code     => $branch_code,
        batch_stat      => 0,   # False if any data has changed and the db has not been updated
    };

my $batch = 0;
my $item_number = 0;

# Testing Batch->new() method.
ok($batch = C4::Labels::Batch->new(branch_code => $branch_code), "C4::Labels::Batch-->new() succeeds");
my $batch_id = $batch->get_attr('batch_id');
$expected_batch->{'batch_id'} = $batch_id;
is_deeply($batch, $expected_batch, "New batch object is correct.");

# Testing Batch->get_attr() method.
foreach my $key (keys %{$expected_batch}) {
    if (ref($expected_batch->{$key}) eq 'ARRAY') {
        ok(ref($expected_batch->{$key}) eq ref($batch->get_attr($key)), "Batch->get_attr() SUCCESS on attribute $key.");
    }
    else {
        ok($expected_batch->{$key} eq $batch->get_attr($key), "Batch->get_attr() SUCCESS on attribute $key.");
    }
}

# Testing Batch->add_item() method.
# Create the item
my ( $f_holdingbranch, $sf_holdingbranch ) = GetMarcFromKohaField( 'items.holdingbranch' );
my ( $f_homebranch, $sf_homebranch ) = GetMarcFromKohaField( 'items.homebranch' );
is( $f_holdingbranch, $f_homebranch, "items information should be in the same field" );
my $field = $f_holdingbranch;

my $record = MARC::Record->new();
$record->append_fields(
    MARC::Field->new( $field, '', '', $sf_homebranch => 'CPL', $sf_holdingbranch => 'CPL' ),
    MARC::Field->new( $field, '', '', $sf_homebranch => 'CPL', $sf_holdingbranch => 'CPL' ),
    MARC::Field->new( $field, '', '', $sf_homebranch => 'CPL', $sf_holdingbranch => 'CPL' ),
    MARC::Field->new( $field, '', '', $sf_homebranch => 'CPL', $sf_holdingbranch => 'CPL' ),
    MARC::Field->new( $field, '', '', $sf_homebranch => 'CPL', $sf_holdingbranch => 'CPL' ),
    MARC::Field->new( $field, '', '', $sf_homebranch => 'CPL', $sf_holdingbranch => 'CPL' ),
    MARC::Field->new( $field, '', '', $sf_homebranch => 'CPL', $sf_holdingbranch => 'CPL' ),
    MARC::Field->new( $field, '', '', $sf_homebranch => 'CPL', $sf_holdingbranch => 'CPL' ),
    MARC::Field->new( $field, '', '', $sf_homebranch => 'CPL', $sf_holdingbranch => 'CPL' ),
    MARC::Field->new( $field, '', '', $sf_homebranch => 'CPL', $sf_holdingbranch => 'CPL' ),
);
my ( $biblionumber, $biblioitemnumber ) = C4::Biblio::AddBiblio($record, '');
my @iteminfo = C4::Items::AddItemBatchFromMarc( $record, $biblionumber, $biblioitemnumber, '' );

my $itemnumbers = $iteminfo[0];

for my $itemnumber ( @$itemnumbers ) {
    ok($batch->add_item($itemnumber) eq 0 , "Batch->add_item() success.");
}
$batch_id = $batch->get_attr('batch_id');

# Testing Batch->retrieve() method.
ok(my $saved_batch = C4::Labels::Batch->retrieve(batch_id => $batch_id), "Batch->retrieve() success.");
is_deeply($saved_batch, $batch, "Batch object retrieved correctly" );

# Testing Batch->remove_item() method.
my $itemnumber = @$itemnumbers[0];
ok($batch->remove_item($itemnumber) eq 0, "Batch->remove_item() success.");

my $updated_batch = C4::Labels::Batch->retrieve(batch_id => $batch_id);
is_deeply($updated_batch, $batch, "Updated batch object is correct.");

# Testing Batch->delete() method.
my $del_results = $batch->delete();
ok($del_results eq 0, "Batch->delete() success.");

$dbh->rollback;
