#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 11;

use C4::Context;

use_ok('Koha::Item::Search::Field');
import Koha::Item::Search::Field qw(AddItemSearchField ModItemSearchField
    DelItemSearchField GetItemSearchField GetItemSearchFields);

my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;

# Start with empty table.
foreach my $field (GetItemSearchFields()) {
    DelItemSearchField($field->{name});
}
is(scalar GetItemSearchFields(), 0, "No existing search field");

# Missing keys in hashref parameter, so returns undef
ok(not (defined AddItemSearchField()), "missing keys => fail");
ok(not (defined AddItemSearchField({})), "missing keys => fail");
ok(not (defined AddItemSearchField({name => 'foo'})), "missing keys => fail");
ok(not (defined AddItemSearchField({name => 'foo', label => 'Foo'})), "missing keys => fail");

# Success, the field hashref is returned
ok('HASH' eq ref AddItemSearchField({name => 'foo', label => 'Foo', tagfield => '001'}), "successful add");

# Check the table now contains one row.
is(scalar GetItemSearchFields(), 1, "Table now contains one row");
my $field = GetItemSearchField('foo');
is_deeply($field, {name => 'foo', label => 'Foo', tagfield => '001', tagsubfield => undef, authorised_values_category => undef});

ok((defined ModItemSearchField({name => 'foo', label => 'Foobar', tagfield => '100', 'tagsubfield' => 'a'})), "successful mod");
$field = GetItemSearchField('foo');
is_deeply($field, {name => 'foo', label => 'Foobar', tagfield => '100', tagsubfield => 'a', authorised_values_category => undef});

$dbh->rollback;
