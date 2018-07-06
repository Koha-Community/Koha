#!/usr/bin/env perl

# Copyright 2017 Koha-Suomi Oy
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use Test::More tests => 1;
use Test::Mojo;
use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Auth;
use C4::Circulation;
use C4::Context;
use C4::Items;

use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

# FIXME: sessionStorage defaults to mysql, but it seems to break transaction handling
# this affects the other REST api tests
t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );

my $remote_address = '127.0.0.1';
my $t              = Test::Mojo->new('Koha::REST::V1');

subtest 'get() tests' => sub {
    plan tests => 42;

    $schema->storage->txn_begin;

    # Create test context
    my ($borrowernumber, $sessionid)            = create_user_and_session();
    my ($librariannnumber, $librariansessionid) = create_user_and_session(2);

    # Mock userenv branchcode
    my $branchcode = $builder->build({ source => 'Branch' })->{ branchcode };
    my $module = new Test::MockModule('C4::Context');
    $module->mock('userenv', sub { { branch => $branchcode } });

    # 1. Patrons
    my $patron       = Koha::Patrons->find($borrowernumber);
    my $librarian    = Koha::Patrons->find($librariannnumber);

    # 2. Biblios and items
    my $biblionumber = create_biblio('RESTful Web APIs', 'The Best');
    my $itemnumber1  = create_item($biblionumber, 'TEST1001');
    my $itemnumber2  = create_item($biblionumber, 'TEST1002');
    my $itemnumber3  = create_item($biblionumber, 'TEST1003');
    my $item1        = Koha::Items->find($itemnumber1);
    my $item2        = Koha::Items->find($itemnumber2);
    my $item3        = Koha::Items->find($itemnumber3);

    # 3. Checkouts
    my $due    = DateTime->now->add(weeks => 2);
    my $issue1 = C4::Circulation::AddIssue($patron->unblessed, 'TEST1001', $due);
    my $due2   = Koha::DateUtils::dt_from_string( $issue1->date_due );
    my $issue2 = C4::Circulation::AddIssue($patron->unblessed, 'TEST1002', $due2);
    C4::Circulation::AddRenewal($borrowernumber, $itemnumber2, $branchcode, $due2);

    # 4. Issuing rules
    t::lib::Mocks::mock_preference('OpacRenewalAllowed', 1);
    t::lib::Mocks::mock_preference('CircControl', 'ItemHomeLibrary');
    t::lib::Mocks::mock_preference('HomeOrHoldingBranch', 'homebranch');
    Koha::IssuingRule->new({
        categorycode => $patron->categorycode,
        itemtype     => $item1->effective_itemtype,
        branchcode   => $item1->homebranch,
        ccode        => $item1->ccode,
        permanent_location => $item1->permanent_location,
        renewalsallowed => 5,
    })->store;
    Koha::IssuingRule->new({
        categorycode => $patron->categorycode,
        itemtype     => $item2->effective_itemtype,
        branchcode   => $item2->homebranch,
        ccode        => $item2->ccode,
        permanent_location => $item2->permanent_location,
        renewalsallowed => 1,
    })->store;

    # BEGIN TEST

    # Request my own expanded checkout infromation
    my $tx = $t->ua->build_tx(GET => "/api/v1/checkouts/expanded?borrowernumber="
                              .$borrowernumber);
    $tx->req->cookies({name =>'CGISESSID', value => $sessionid});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
        ->status_is(200)
        ->json_is('/0/borrowernumber' => $borrowernumber)
        ->json_is('/0/itemnumber' => $itemnumber1)
        ->json_like('/0/date_due' => qr/$due\+\d\d:\d\d/)
        ->json_is('/0/renewals'   => 0)
        ->json_is('/0/renewable'  => Mojo::JSON->true)
        ->json_is('/0/renewability_error' => undef)
        ->json_is('/0/max_renewals' => 5)
        ->json_is('/1/borrowernumber' => $borrowernumber)
        ->json_is('/1/itemnumber' => $itemnumber2)
        ->json_like('/1/date_due' => qr/$due2\+\d\d:\d\d/)
        ->json_is('/1/renewals'   => 1)
        ->json_is('/1/renewable'  => Mojo::JSON->false)
        ->json_is('/1/renewability_error' => 'too_many')
        ->json_is('/1/max_renewals' => 1)
        ->json_is('/0/biblionumber' => $biblionumber)
        ->json_is('/0/title' => 'RESTful Web APIs')
        ->json_is('/0/title_remainder' => 'The Best')
        ->json_is('/0/enumchron' => 'ecTEST1001')
        ->json_hasnt('/2');
        

    t::lib::Mocks::mock_preference('OpacRenewalAllowed', 0);
    $tx = $t->ua->build_tx(GET => "/api/v1/checkouts/expanded?borrowernumber="
                              .$borrowernumber);
    $tx->req->cookies({name =>'CGISESSID', value => $librariansessionid});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
        ->status_is(200)
        ->json_is('/0/borrowernumber' => $borrowernumber)
        ->json_is('/0/itemnumber' => $itemnumber1)
        ->json_like('/0/date_due' => qr/$due\+\d\d:\d\d/)
        ->json_is('/0/renewals'   => 0)
        ->json_is('/0/renewable'  => Mojo::JSON->true)
        ->json_is('/0/renewability_error' => undef)
        ->json_is('/0/max_renewals' => 5)
        ->json_is('/1/borrowernumber' => $borrowernumber)
        ->json_is('/1/itemnumber' => $itemnumber2)
        ->json_like('/1/date_due' => qr/$due2\+\d\d:\d\d/)
        ->json_is('/1/renewals'   => 1)
        ->json_is('/1/renewable'  => Mojo::JSON->false)
        ->json_is('/1/renewability_error' => 'too_many')
        ->json_is('/1/max_renewals' => 1)
        ->json_is('/0/biblionumber' => $biblionumber)
        ->json_is('/0/title' => 'RESTful Web APIs')
        ->json_is('/0/title_remainder' => 'The Best')
        ->json_is('/0/enumchron' => 'ecTEST1001')
        ->json_hasnt('/2');
    $schema->storage->txn_rollback;
};

sub create_user_and_session {
    my ($flags) = @_;

    my $categorycode = $builder->build({ source => 'Category' })->{ categorycode };
    my $branchcode = $builder->build({ source => 'Branch' })->{ branchcode };

    my $borrower = $builder->build({
        source => 'Borrower',
        value => {
            branchcode   => $branchcode,
            categorycode => $categorycode,
            flags        => $flags,
            lost         => 0,
            gonenoaddress => 0,
        }
    });

    my $borrowersession = t::lib::Mocks::mock_session({borrower => $borrower});

    return ($borrower->{borrowernumber}, $borrowersession->id);
}

sub create_biblio {
    my ($title, $subtitle) = @_;

    my $record = new MARC::Record;
    $record->append_fields(
        new MARC::Field('245', ' ', ' ', a => $title, b => $subtitle),
    );

    my ($biblionumber) = C4::Biblio::AddBiblio($record, '');

    return $biblionumber;
}

sub create_item {
    my ($biblionumber, $barcode) = @_;

    my $branchcode = $builder->build({ source => 'Branch' })->{ branchcode };

    my $itemtype = $builder->build({
        source => 'Itemtype', value => { notforloan => 0, rentalcharge => 0 }
    });
    my $item = {
        barcode       => $barcode,
        homebranch    => $branchcode,
        holdingbranch => $branchcode,
        itype         => $itemtype->{itemtype},
        enumchron     => 'ec' . $barcode
    };

    my $itemnumber = C4::Items::AddItem($item, $biblionumber);

    return $itemnumber;
}
