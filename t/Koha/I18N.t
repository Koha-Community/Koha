#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 35;
use Test::MockModule;
use FindBin qw($Bin);
use Encode;

BEGIN {
    use_ok('Koha::I18N');
}

my $koha_i18n = Test::MockModule->new('Koha::I18N');
$koha_i18n->mock('_base_directory', sub { "$Bin/I18N/po" });

my $c4_languages = Test::MockModule->new('C4::Languages');
$c4_languages->mock('getlanguage', sub { 'xx-XX' });

# If you need to modify the MO file to add new tests
# 1) msgunfmt -o Koha.po t/Koha/I18N/po/xx_XX/LC_MESSAGES/Koha.mo
# 2) Edit Koha.po
# 3) msgfmt -o t/Koha/I18N/po/xx_XX/LC_MESSAGES/Koha.mo Koha.po
my @tests = (
    [ __('test') => 'test ツ' ],
    [ __x('Hello {name}', name => 'World') => 'Hello World ツ' ],
    [ __n('Singular', 'Plural', 0) => 'Zero ツ' ],
    [ __n('Singular', 'Plural', 1) => 'Singular ツ' ],
    [ __n('Singular', 'Plural', 2) => 'Plural ツ' ],
    [ __n('Singular', 'Plural', 3) => 'Plural ツ' ],
    [ __nx('one item', '{count} items', 0, count => 0) => 'no item ツ' ],
    [ __nx('one item', '{count} items', 1, count => 1) => 'one item ツ' ],
    [ __nx('one item', '{count} items', 2, count => 2) => '2 items ツ' ],
    [ __nx('one item', '{count} items', 3, count => 3) => '3 items ツ' ],
    [ __xn('one item', '{count} items', 0, count => 0) => 'no item ツ' ],
    [ __xn('one item', '{count} items', 1, count => 1) => 'one item ツ' ],
    [ __xn('one item', '{count} items', 2, count => 2) => '2 items ツ' ],
    [ __xn('one item', '{count} items', 3, count => 3) => '3 items ツ' ],
    [ __p('biblio', 'title') => 'title (biblio) ツ' ],
    [ __p('patron', 'title') => 'title (patron) ツ' ],
    [ __px('biblio', 'Remove item {id}', id => 42) => 'Remove item 42 (biblio) ツ' ],
    [ __px('list', 'Remove item {id}', id => 42) => 'Remove item 42 (list) ツ' ],
    [ __np('ctxt1', 'singular', 'plural', 0) => 'zero (ctxt1) ツ' ],
    [ __np('ctxt1', 'singular', 'plural', 1) => 'singular (ctxt1) ツ' ],
    [ __np('ctxt1', 'singular', 'plural', 2) => 'plural (ctxt1) ツ' ],
    [ __np('ctxt1', 'singular', 'plural', 3) => 'plural (ctxt1) ツ' ],
    [ __np('ctxt2', 'singular', 'plural', 0) => 'zero (ctxt2) ツ' ],
    [ __np('ctxt2', 'singular', 'plural', 1) => 'singular (ctxt2) ツ' ],
    [ __np('ctxt2', 'singular', 'plural', 2) => 'plural (ctxt2) ツ' ],
    [ __np('ctxt2', 'singular', 'plural', 3) => 'plural (ctxt2) ツ' ],
    [ __npx('biblio', 'one item', '{count} items', 0, count => 0) => 'no item (biblio) ツ' ],
    [ __npx('biblio', 'one item', '{count} items', 1, count => 1) => 'one item (biblio) ツ' ],
    [ __npx('biblio', 'one item', '{count} items', 2, count => 2) => '2 items (biblio) ツ' ],
    [ __npx('biblio', 'one item', '{count} items', 3, count => 3) => '3 items (biblio) ツ' ],
    [ __npx('list', 'one item', '{count} items', 0, count => 0) => 'no item (list) ツ' ],
    [ __npx('list', 'one item', '{count} items', 1, count => 1) => 'one item (list) ツ' ],
    [ __npx('list', 'one item', '{count} items', 2, count => 2) => '2 items (list) ツ' ],
    [ __npx('list', 'one item', '{count} items', 3, count => 3) => '3 items (list) ツ' ],
);

foreach my $test (@tests) {
    is($test->[0], decode_utf8($test->[1]), $test->[1]);
}
