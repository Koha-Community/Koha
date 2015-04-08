#!/usr/bin/perl

# Copyright 2012 C & P Bibliography Services
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

use strict;
use warnings;

use C4::Context;
use Test::More;

BEGIN {
        use_ok('Koha::Authority');
}

my $record = MARC::Record->new;

$record->add_fields(
        [ '001', '1234' ],
        [ '150', ' ', ' ', a => 'Cooking' ],
        [ '450', ' ', ' ', a => 'Cookery' ],
        );
my $authority = Koha::Authority->new($record);

is(ref($authority), 'Koha::Authority', 'Created valid Koha::Authority object');

is($authority->authorized_heading(), 'Cooking', 'Authorized heading was correct');

is_deeply($authority->record, $record, 'Saved record');

SKIP:
{
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT authid FROM auth_header LIMIT 1;");
    $sth->execute();

    my $authid;
    for my $row ($sth->fetchrow_hashref) {
        $authid = $row->{'authid'};
    }
    skip 'No authorities', 3 unless $authid;
    $authority = Koha::Authority->get_from_authid($authid);

    is(ref($authority), 'Koha::Authority', 'Retrieved valid Koha::Authority object');

    is($authority->authid, $authid, 'Object authid is correct');

    is($authority->record->field('001')->data(), $authid, 'Retrieved correct record');

    $authority = Koha::Authority->get_from_authid('alphabetsoup');
    is($authority, undef, 'No invalid record is retrieved');
}

SKIP:
{
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT import_record_id FROM import_records WHERE record_type = 'auth' LIMIT 1;");
    $sth->execute();

    my $import_record_id;
    for my $row ($sth->fetchrow_hashref) {
        $import_record_id = $row->{'import_record_id'};
    }

    skip 'No authorities in reservoir', 3 unless $import_record_id;
    $authority = Koha::Authority->get_from_breeding($import_record_id);

    is(ref($authority), 'Koha::Authority', 'Retrieved valid Koha::Authority object');

    is($authority->authid, undef, 'Records in reservoir do not have an authid');

    is(ref($authority->record), 'MARC::Record', 'MARC record attached to authority');

    $authority = Koha::Authority->get_from_breeding('alphabetsoup');
    is($authority, undef, 'No invalid record is retrieved from reservoir');
}

done_testing();
