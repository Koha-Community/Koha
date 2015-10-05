#!/usr/bin/env perl

use Modern::Perl;
use Test::More tests => 14;
use Test::MockModule;

use C4::Context;
use C4::Circulation;
use C4::Biblio;
use C4::Items;
use C4::Members;

use Koha::Database;

my $dbh = C4::Context->dbh;
my $schema = Koha::Database->new()->schema();

# Start transaction
$dbh->{RaiseError} = 1;
$schema->storage->txn_begin();

$dbh->do(q{INSERT INTO itemtypes (itemtype) VALUES ('GTI_I_TEST')});
$schema->resultset('Category')->create({ categorycode => 'GTI_C_TEST' });
$schema->resultset('Branch')->create({ branchcode => 'GTI_B_1', branchname => 'GTI_B_1' });
$schema->resultset('Branch')->create({ branchcode => 'GTI_B_2', branchname => 'GTI_B_2' });

my $c4_context = Test::MockModule->new('C4::Context');
$c4_context->mock('userenv', sub {
    { branch => 'GTI_B_1' }
});
C4::Context->set_preference('item-level_itypes', '0');

my $biblionumber = create_biblio('Test 1', 'GTI_I_TEST');
AddItem({
    barcode => 'GTI_BARCODE_001',
    homebranch => 'GTI_B_1',
    ccode => 'GTI_CCODE',
}, $biblionumber);

$biblionumber = create_biblio('Test 2', 'GTI_I_TEST');
AddItem({
    barcode => 'GTI_BARCODE_002',
    homebranch => 'GTI_B_2',
}, $biblionumber);

my $borrowernumber = AddMember(
    userid => 'gti.test',
    categorycode => 'GTI_C_TEST',
    branchcode => 'GTI_B_1'
);
my $borrower = GetMember(borrowernumber => $borrowernumber);

AddIssue($borrower, 'GTI_BARCODE_001');
AddIssue($borrower, 'GTI_BARCODE_002');

#
# Start of tests
#

my @issues = GetTopIssues({count => 10, itemtype => 'GTI_I_TEST'});
is(scalar @issues, 2);
is($issues[0]->{title}, 'Test 1');
is($issues[1]->{title}, 'Test 2');

@issues = GetTopIssues({count => 1, itemtype => 'GTI_I_TEST'});
is(scalar @issues, 1);
is($issues[0]->{title}, 'Test 1');

@issues = GetTopIssues({count => 10, branch => 'GTI_B_2'});
is(scalar @issues, 1);
is($issues[0]->{title}, 'Test 2');

@issues = GetTopIssues({count => 10, ccode => 'GTI_CCODE'});
is(scalar @issues, 1);
is($issues[0]->{title}, 'Test 1');

@issues = GetTopIssues({count => 10, itemtype => 'GTI_I_TEST', newness => 1});
is(scalar @issues, 2);
is($issues[0]->{title}, 'Test 1');
is($issues[1]->{title}, 'Test 2');

$dbh->do(q{
    UPDATE biblio
    SET datecreated = DATE_SUB(datecreated, INTERVAL 2 DAY)
    WHERE biblionumber = ?
}, undef, $biblionumber);

@issues = GetTopIssues({count => 10, itemtype => 'GTI_I_TEST', newness => 1});
is(scalar @issues, 1);
is($issues[0]->{title}, 'Test 1');

#
# End of tests
#

$schema->storage->txn_rollback();

sub create_biblio {
    my ($title, $itemtype) = @_;

    my ($title_tag, $title_subfield) = GetMarcFromKohaField('biblio.title', '');
    my ($it_tag, $it_subfield) = GetMarcFromKohaField('biblioitems.itemtype', '');

    my $record = MARC::Record->new();
    $record->append_fields(
        MARC::Field->new($title_tag, ' ', ' ', $title_subfield => $title),
        MARC::Field->new($it_tag, ' ', ' ', $it_subfield => $itemtype),
    );

    return AddBiblio($record, '');
}
