#!/usr/bin/perl

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

use Test::More tests => 4;

use Koha::MarcOrder;
use Koha::Acquisition::Baskets;
use Koha::Acquisition::Bookseller;
use MARC::Record;
use Koha::Import::Records;
use Koha::Database;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest '_get_MarcItemFieldsToOrder_syspref_data()' => sub {
    plan tests => 14;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference(
        'MarcItemFieldsToOrder', 'homebranch: 975$a
holdingbranch: 975$b
itype: 975$y
nonpublic_note: 975$x
public_note: 975$z
loc: 975$c
ccode: 975$8
notforloan: 975$7
uri: 975$u
copyno: 975$n
quantity: 975$q
budget_code: 975$h
price: 975$p
replacementprice: 975$v'
    );

    my $record = MARC::Record->new();

    $record->add_fields(
        [ '001', '1234' ],
        [
            '975', ' ', ' ', p => 10, q => 1, h => 1, a => 'CPL', b => 'CPL', y => 'Book',
            x => 'Private note', z => 'Public note', c => 'Shelf', 8 => 'ccode', 7 => 0,
            u => '12345abcde',   n => '12345',       v => 10
        ],
    );

    my $marc_item_fields_to_order = @{
        Koha::MarcOrder::_get_MarcItemFieldsToOrder_syspref_data(
            $record,
        )
    }[0];

    is(
        $marc_item_fields_to_order->{price}, 10,
        "price has been read correctly"
    );
    is(
        $marc_item_fields_to_order->{quantity}, 1,
        "quantity has been read correctly"
    );
    is(
        $marc_item_fields_to_order->{budget_code}, 1,
        "budget_code has been read correctly"
    );
    is(
        $marc_item_fields_to_order->{homebranch}, 'CPL',
        "homebranch has been read correctly"
    );
    is(
        $marc_item_fields_to_order->{holdingbranch}, 'CPL',
        "holdingbranch has been read correctly"
    );
    is(
        $marc_item_fields_to_order->{itype}, 'Book',
        "itype has been read correctly"
    );
    is(
        $marc_item_fields_to_order->{nonpublic_note}, 'Private note',
        "nonpublic_note has been read correctly"
    );
    is(
        $marc_item_fields_to_order->{public_note}, 'Public note',
        "public_note has been read correctly"
    );
    is(
        $marc_item_fields_to_order->{loc}, 'Shelf',
        "loc has been read correctly"
    );
    is(
        $marc_item_fields_to_order->{ccode}, 'ccode',
        "ccode has been read correctly"
    );
    is(
        $marc_item_fields_to_order->{notforloan}, 0,
        "notforloan has been read correctly"
    );
    is(
        $marc_item_fields_to_order->{uri}, '12345abcde',
        "uri has been read correctly"
    );
    is(
        $marc_item_fields_to_order->{copyno}, '12345',
        "copyno has been read correctly"
    );
    is(
        $marc_item_fields_to_order->{replacementprice}, 10,
        "replacementprice has been read correctly"
    );

    $schema->storage->txn_rollback;
};

subtest '_get_MarcFieldsToOrder_syspref_data()' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference(
        'MarcFieldsToOrder', 'price: 975$p
quantity: 975$q
budget_code: 975$h'
    );

    my $record = MARC::Record->new();

    $record->add_fields(
        [ '001', '1234' ],
        [ '975', ' ', ' ', p => 10, q => 1, h => 1 ],
    );

    my $marc_fields_to_order = Koha::MarcOrder::_get_MarcFieldsToOrder_syspref_data(
        'MarcFieldsToOrder', $record,
        [ 'price', 'quantity', 'budget_code', 'discount', 'sort1', 'sort2' ]
    );

    is(
        $marc_fields_to_order->{price}, 10,
        "Price has been read correctly"
    );
    is(
        $marc_fields_to_order->{quantity}, 1,
        "Quantity has been read correctly"
    );
    is(
        $marc_fields_to_order->{budget_code}, 1,
        "Budget code has been read correctly"
    );

    $schema->storage->txn_rollback;
};

subtest 'add_biblio_from_import_record()' => sub {
    plan tests => 4;

    $schema->storage->txn_begin;

    my $sample_import_batch = {
        matcher_id     => 1,
        template_id    => 1,
        branchcode     => 'CPL',
        overlay_action => 'create_new',
        nomatch_action => 'create_new',
        item_action    => 'always_add',
        import_status  => 'staged',
        batch_type     => 'z3950',
        file_name      => 'test.mrc',
        comments       => 'test',
        record_type    => 'auth',
    };

    my $import_batch_id = C4::ImportBatch::AddImportBatch($sample_import_batch);

    my $record = MARC::Record->new();

    $record->add_fields(
        [ '001', '1234' ],
        [ '020', ' ', ' ', a => '9780596004931' ],
        [ '975', ' ', ' ', p => 10, q => 1, h => 1 ],
    );

    my $import_record_id = C4::ImportBatch::AddBiblioToBatch( $import_batch_id, 0, $record, 'utf8', 0 );
    my $import_record    = Koha::Import::Records->find($import_record_id);

    my $result = Koha::MarcOrder::add_biblio_from_import_record(
        {
            import_record   => $import_record,
            matcher_id      => $sample_import_batch->{matcher_id},
            overlay_action  => $sample_import_batch->{overlay_action},
            agent           => 'cron',
            import_batch_id => $import_batch_id
        }
    );

    isnt(
        $result->{record_result}->{biblionumber}, undef,
        'A new biblionumber is added or an existing biblionumber is returned'
    );

    # Check that records are skipped if not selected when called from addorderiso2709.pl
    # Pass in an empty array and the record should be skipped
    my @import_record_id_selected = ();
    my $result2                   = Koha::MarcOrder::add_biblio_from_import_record(
        {
            import_record             => $import_record,
            matcher_id                => $sample_import_batch->{matcher_id},
            overlay_action            => $sample_import_batch->{overlay_action},
            import_record_id_selected => \@import_record_id_selected,
            agent                     => 'client',
            import_batch_id           => $import_batch_id
        }
    );

    is( $result2->{skip},                1, 'Record was skipped' );
    is( $result2->{duplicates_in_batch}, 0, 'Record was skipped - no duplicate checking needed' );
    is( $result2->{record_result},       0, 'Record was skipped' );

    $schema->storage->txn_rollback;
};

subtest 'add_items_from_import_record() - addorderiso2709.pl' => sub {
    plan tests => 6;

    $schema->storage->txn_begin;

    my $bpid = C4::Budgets::AddBudgetPeriod(
        {
            budget_period_startdate => '2008-01-01', budget_period_enddate => '2008-12-31'
            , budget_period_active      => 1
            , budget_period_description => "MAPERI"
        }
    );
    my $budgetid = C4::Budgets::AddBudget(
        {
            budget_code      => "BC_1",
            budget_name      => "budget_name_test_1",
            budget_period_id => $bpid,
        }
    );
    my $budgetid2 = C4::Budgets::AddBudget(
        {
            budget_code      => "BC_2",
            budget_name      => "budget_name_test_2",
            budget_period_id => $bpid,
        }
    );
    my $fund1         = C4::Budgets::GetBudget($budgetid);
    my $fund2         = C4::Budgets::GetBudget($budgetid2);
    my $budget_code_1 = $fund1->{budget_code};
    my $budget_code_2 = $fund2->{budget_code};

    my $sample_import_batch = {
        matcher_id     => 1,
        template_id    => 1,
        branchcode     => 'CPL',
        overlay_action => 'create_new',
        nomatch_action => 'create_new',
        item_action    => 'always_add',
        import_status  => 'staged',
        batch_type     => 'z3950',
        file_name      => 'test.mrc',
        comments       => 'test',
        record_type    => 'auth',
    };

    my $import_batch_id = C4::ImportBatch::AddImportBatch($sample_import_batch);

    my $record = MARC::Record->new();

    $record->add_fields(
        [ '001', '1234' ],
        [ '020', ' ', ' ', a => '9780596004931' ],
        [ '975', ' ', ' ', p => 10, q => 1, h => $budget_code_2 ],
    );

    my $import_record_id          = C4::ImportBatch::AddBiblioToBatch( $import_batch_id, 0, $record, 'utf8', 0 );
    my $import_record             = Koha::Import::Records->find($import_record_id);
    my @import_record_id_selected = ($import_record_id);

    my $result = Koha::MarcOrder::add_biblio_from_import_record(
        {
            import_record             => $import_record,
            matcher_id                => $sample_import_batch->{matcher_id},
            overlay_action            => $sample_import_batch->{overlay_action},
            agent                     => 'client',
            import_batch_id           => $import_batch_id,
            import_record_id_selected => \@import_record_id_selected
        }
    );

    my $bookseller = Koha::Acquisition::Bookseller->new(
        {
            name         => "my vendor",
            address1     => "bookseller's address",
            phone        => "0123456",
            active       => 1,
            deliverytime => 5,
        }
    )->store;

    my $client_item_fields = {
        'notforloans' => [
            '',
            ''
        ],
        'c_budget_id'       => 2,
        'replacementprices' => [
            '0.00',
            '0.00'
        ],
        'uris' => [
            '',
            ''
        ],
        'c_replacement_price' => '0.00',
        'public_notes'        => [
            '',
            ''
        ],
        'itemcallnumbers' => [
            '',
            ''
        ],
        'budget_codes' => [
            '',
            ''
        ],
        'nonpublic_notes' => [
            '',
            ''
        ],
        'homebranches' => [
            'CPL',
            'CPL'
        ],
        'copynos' => [
            '',
            ''
        ],
        'holdingbranches' => [
            'CPL',
            'CPL'
        ],
        'ccodes' => [
            '',
            ''
        ],
        'locs' => [
            '',
            ''
        ],
        'itemprices' => [
            '10.00',
            '10.00'
        ],
        'c_discount' => '',
        'c_price'    => '0.00',
        'c_sort2'    => '',
        'c_sort1'    => '',
        'c_quantity' => '1',
        'itypes'     => [
            'BK',
            'BK'
        ]
    };

    my $order_line_details = Koha::MarcOrder::add_items_from_import_record(
        {
            record_result      => $result->{record_result},
            basket_id          => 1,
            vendor             => $bookseller,
            budget_id          => $budgetid,
            agent              => 'client',
            client_item_fields => $client_item_fields,
        }
    );

    is(
        @{$order_line_details}[0]->{rrp}, '10.00',
        "Price has been read correctly"
    );
    is(
        @{$order_line_details}[0]->{listprice}, '10',
        "Listprice has been created successfully"
    );
    is(
        @{$order_line_details}[0]->{quantity}, 1,
        "Quantity has been read correctly"
    );
    is(
        @{$order_line_details}[0]->{budget_id}, $budgetid,
        "Budget code has been read correctly"
    );

    my @created_items = @{$order_line_details}[0]->{itemnumbers};
    my $new_item      = Koha::Items->find( $created_items[0] );

    isnt(
        $new_item, undef,
        'Item was successfully created'
    );
    is(
        $new_item->price, '10.00',
        'Item values mapped correctly'
    );

    $schema->storage->txn_rollback;
};

