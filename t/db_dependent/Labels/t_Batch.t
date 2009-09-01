#!/usr/bin/perl
#
# Copyright 2007 Foundations Bible College.
#
# This file is part of Koha.
#       
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;
use warnings;

use Test::More tests => 22;
use C4::Context;
use Data::Dumper;

BEGIN {
    use_ok('C4::Labels::Batch');
}

my $sth = C4::Context->dbh->prepare('SELECT branchcode FROM branches b LIMIT 0,1');
$sth->execute();
my $branch_code = $sth->fetchrow_hashref()->{'branchcode'};
syslog("LOG_ERR", "t/db_dependent/Labels/t_Batch.t : Database returned the following error: %s", $sth->errstr) if $sth->errstr;
my $expected_batch = {
        items           => [],
        branch_code     => $branch_code,
        batch_stat      => 0,   # False if any data has changed and the db has not been updated
    };

my $batch = 0;
my $item_number = 0;

diag "Testing Batch->new() method.";
ok($batch = C4::Labels::Batch->new(branch_code => $branch_code)) || diag "Batch->new() FAILED. Check syslog for details.";
my $batch_id = $batch->get_attr('batch_id');
$expected_batch->{'batch_id'} = $batch_id;
is_deeply($batch, $expected_batch) || diag "New batch object FAILED to verify.";

diag "Testing Batch->get_attr() method.";
foreach my $key (keys %{$expected_batch}) {
    if (ref($expected_batch->{$key}) eq 'ARRAY') {
        ok(ref($expected_batch->{$key}) eq ref($batch->get_attr($key))) || diag "Batch->get_attr() FAILED on attribute $key.";
    }
    else {
        ok($expected_batch->{$key} eq $batch->get_attr($key)) || diag "Batch->get_attr() FAILED on attribute $key.";
    }
}

diag "Testing Batch->add_item() method.";
my $sth1 = C4::Context->dbh->prepare('SELECT itemnumber FROM items LIMIT 0,10');
$sth1->execute();
while (my $row = $sth1->fetchrow_hashref()) {
    syslog("LOG_ERR", "t/db_dependent/Labels/t_Batch.t : Database returned the following error: %s", $sth1->errstr) if $sth1->errstr;
    ok($batch->add_item($row->{'itemnumber'}) eq 0 ) || diag "Batch->add_item() FAILED. Check syslog for details.";
    $item_number = $row->{'itemnumber'};
}

diag "Testing Batch->retrieve() method.";
ok(my $saved_batch = C4::Labels::Batch->retrieve(batch_id => $batch_id)) || diag "Batch->retrieve() FAILED. Check syslog for details.";
is_deeply($saved_batch, $batch) || diag "Retrieved batch object FAILED to verify.";

diag "Testing Batch->remove_item() method.";

ok($batch->remove_item($item_number) eq 0) || diag "Batch->remove_item() FAILED. See syslog for details.";
my $updated_batch = C4::Labels::Batch->retrieve(batch_id => $batch_id);
is_deeply($updated_batch, $batch) || diag "Updated batch object FAILED to verify.";

diag "Testing Batch->delete() method.";

my $del_results = $batch->delete();
ok($del_results eq 0) || diag "Batch->delete() FAILED. See syslog for details.";
