#!/usr/bin/perl

use Modern::Perl;

use Test::More tests => 130;

use Koha::Database;
use Koha::SimpleMARC;

use t::lib::Mocks;

use_ok("MARC::Field");
use_ok("MARC::Record");
use_ok('C4::MarcModificationTemplates', qw( AddModificationTemplate AddModificationTemplateAction GetModificationTemplateAction GetModificationTemplateActions ModModificationTemplateAction MoveModificationTemplateAction DelModificationTemplate DelModificationTemplateAction ModifyRecordWithTemplate GetModificationTemplates ));

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;

$dbh->do(q|DELETE FROM marc_modification_templates|);

# Creation
my $template_id = AddModificationTemplate("template_name");
like( $template_id, qr|^\d+$|, "new template returns an id" );

is( AddModificationTemplateAction(
    $template_id, 'move_field', 1,
    '464', 'u', '', '464', '3',
    '', '', '',
    '', '', '', '', '', '',
    'move first 464$u to 464$3'
), 1, "Add first action");

is( AddModificationTemplateAction(
    $template_id, 'update_field', 0,
    '099', 't', 'LIV', '', '',
    '', '', '',
    'if', '200', 'b', 'equals', 'Text', '',
    'Update field 099$t with value LIV if 200$b matches "Text"'
), 1, "Add second action");

is( AddModificationTemplateAction(
    $template_id, 'copy_field', 0,
    '606', 'a', '', '607', 'a',
    '', '', '',
    'unless', '606', 'a', 'not_equals', '^AJAX', '1',
    'Copy field 606$a to 607$a unless 606$a matches RegEx m^AJAX'
), 1, "Add third action");

is( AddModificationTemplateAction(
    $template_id, 'add_field', 0,
    '650', 'a', 'Additional', '', '',
    '', '', '',
    'unless', '650', 'a', 'exists', '', '',
    'Add field 650$aAdditional unless 650$a exists'
), 1, "Add fourth action");
# Getter

my @actions = GetModificationTemplateActions( $template_id );
is( @actions, 4, "4 actions are inserted");

for my $action ( @actions ) {
    isnt( GetModificationTemplateAction( $action->{mmta_id} ), undef, "action with id $action->{mmta_id} exists" );
}

my $first_action = $actions[0];
is( $first_action->{ordering}, 1, "test ordering for first action" );
is( $first_action->{action}, 'move_field', "test action for first action" );
is( $first_action->{from_field}, '464', "test from_field for first action" );
is( $first_action->{from_subfield}, 'u', "test from_subfield for first action" );
is( $first_action->{to_field}, '464', "test to_field for first action" );
is( $first_action->{to_subfield}, '3', "test to_subfield for first action" );

my $second_action = $actions[1];
is( $second_action->{ordering}, 2, "test ordering for second action" );
is( $second_action->{action}, 'update_field', "test action for second action" );
is( $second_action->{from_field}, '099',"test from_field for second action" );
is( $second_action->{from_subfield}, 't', "test from_subfield for second action" );
is( $second_action->{field_value}, 'LIV', "test firld_value for second action" );
is( $second_action->{to_field}, '', "test to_field for second action" );
is( $second_action->{to_subfield}, '', "test to_subfield for second action" );
is( $second_action->{conditional}, 'if', "test conditional for second action" );
is( $second_action->{conditional_field}, '200', "test conditional_field for second action" );
is( $second_action->{conditional_subfield}, 'b', "test conditional_subfield for second action" );
is( $second_action->{conditional_comparison}, 'equals', "test conditional_comparison for second action" );

my $third_action = $actions[2];
is( $third_action->{ordering}, 3, "test ordering for third action" );
is( $third_action->{action}, 'copy_field', "test action for third action" );
is( $third_action->{from_field}, '606', "test from_field for third action" );
is( $third_action->{from_subfield}, 'a', "test from_subfield for third action" );
is( $third_action->{to_field}, '607', "test to_field for third action" );
is( $third_action->{to_subfield}, 'a', "test to_subfield for third action" );
is( $third_action->{conditional}, 'unless', "test conditional for third action" );
is( $third_action->{conditional_field}, '606', "test conditional_field for third action" );
is( $third_action->{conditional_subfield}, 'a', "test conditional_subfield for third action" );
is( $third_action->{conditional_comparison}, 'not_equals', "test conditional_comparison for third action" );
is( $third_action->{conditional_value}, '^AJAX', "test conditional_value for third action" );

my $fourth_action = $actions[3];
is( $fourth_action->{ordering}, 4, "test ordering for fourth action" );
is( $fourth_action->{action}, 'add_field', "test action for fourth action" );
is( $fourth_action->{from_field}, '650', "test from_field for fourth action" );
is( $fourth_action->{from_subfield}, 'a', "test from_subfield for fourth action" );
is( $fourth_action->{to_field}, '', "test to_field for fourth action" );
is( $fourth_action->{to_subfield}, '', "test to_subfield for fourth action" );
is( $fourth_action->{conditional}, 'unless', "test conditional for fourth action" );
is( $fourth_action->{conditional_field}, '650', "test conditional_field for fourth action" );
is( $fourth_action->{conditional_subfield}, 'a', "test conditional_subfield for fourth action" );
is( $fourth_action->{conditional_comparison}, 'exists', "test conditional_comparison for fourth action" );
is( $fourth_action->{conditional_value}, '', "test conditional_value for fourth action" );

# Modifications
is( ModModificationTemplateAction(
    $actions[1]->{mmta_id}, 'update_field', 0,
    '100', 'u', 'LIV', '', '',
    '', '', '',
    'if', '200', 'c', 'equals', 'Text', '',
    'Update field 099$t with value LIV if 200$b matches "Text"'
), 1, "Modify second action");

$second_action = GetModificationTemplateAction( $actions[1]->{mmta_id} );
is( $second_action->{ordering}, 2, "test ordering for second action modified" );
is( $second_action->{action}, 'update_field', "test action for second action modified" );
is( $second_action->{from_field}, '100',"test from_field for second action modified" );
is( $second_action->{from_subfield}, 'u', "test from_subfield for second action modified" );
is( $second_action->{field_value}, 'LIV', "test firld_value for second action modified" );
is( $second_action->{to_field}, '', "test to_field for second action modified" );
is( $second_action->{to_subfield}, '', "test to_subfield for second action modified" );
is( $second_action->{conditional}, 'if', "test conditional for second action modified" );
is( $second_action->{conditional_field}, '200', "test conditional_field for second action modified" );
is( $second_action->{conditional_subfield}, 'c', "test conditional_subfield for second action modified" );
is( $second_action->{conditional_comparison}, 'equals', "test conditional_comparison for second action modified" );

# Up and down
is( MoveModificationTemplateAction( $actions[2]->{mmta_id}, 'top' ), '1', 'Move the third action on top' );
is( MoveModificationTemplateAction( $actions[0]->{mmta_id}, 'bottom' ), '1', 'Move the first action on bottom' );

is( GetModificationTemplateAction( $actions[0]->{mmta_id} )->{ordering}, '4', 'First becomes fourth' );
is( GetModificationTemplateAction( $actions[1]->{mmta_id} )->{ordering}, '2', 'Second stays second' );
is( GetModificationTemplateAction( $actions[2]->{mmta_id} )->{ordering}, '1', 'Third becomes first' );
is( GetModificationTemplateAction( $actions[3]->{mmta_id} )->{ordering}, '3', 'Fourth becomes third' );

is( MoveModificationTemplateAction( $actions[0]->{mmta_id}, 'up' ), '1', 'Move up the first action (was fourth)' );
is( MoveModificationTemplateAction( $actions[0]->{mmta_id}, 'up' ), '1', 'Move up the first action (was third)' );
is( MoveModificationTemplateAction( $actions[2]->{mmta_id}, 'down' ), '1', 'Move down the third action (was first)' );

is( GetModificationTemplateAction( $actions[0]->{mmta_id} )->{ordering}, '1', 'First becomes again first' );
is( GetModificationTemplateAction( $actions[1]->{mmta_id} )->{ordering}, '3', 'Second becomes third' );
is( GetModificationTemplateAction( $actions[2]->{mmta_id} )->{ordering}, '2', 'Third becomes second' );
is( GetModificationTemplateAction( $actions[3]->{mmta_id} )->{ordering}, '4', 'Fourth becomes again fourth' );

# Cleaning
is( DelModificationTemplateAction( $actions[0]->{mmta_id} ), 3, "Delete the first action, 2 others are reordered" );
is( GetModificationTemplateAction( $actions[0]->{mmta_id} ), undef, "first action does not exist anymore" );

is( DelModificationTemplate( $template_id ), 1, "The template has been deleted" );

is( GetModificationTemplateAction( $actions[1]->{mmta_id} ), undef, "second action does not exist anymore" );
is( GetModificationTemplateAction( $actions[2]->{mmta_id} ), undef, "third action does not exist anymore" );
is( GetModificationTemplateAction( $actions[3]->{mmta_id} ), undef, "fourth action does not exist anymore" );

is( GetModificationTemplateActions( $template_id ), 0, "There is no action for deleted template" );

# ModifyRecordWithTemplate
t::lib::Mocks::mock_userenv();

$template_id = AddModificationTemplate("new_template_test");
like( $template_id, qr|^\d+$|, "new template returns an id" );

is( AddModificationTemplateAction(
    $template_id, 'delete_field', 0,
    '245', '', '', '', '',
    '', '', '',
    'if', '245', 'a', 'equals', 'Bad title', '',
    'Delete field 245 if 245$a eq "Bad title"'
), 1, 'Add first action: delete field 245 if 245$a eq "Bad title"');

is( AddModificationTemplateAction(
    $template_id, 'copy_field', 0,
    '245', 'a', '', '246', 'a',
    '', '', '',
    '', '', '', '', '', '',
    'copy field 245$a to 246$a'
), 1, 'Add second action: copy 245$a to 246$a');

is( AddModificationTemplateAction(
    $template_id, 'delete_field', 0,
    '650', 'a', '', '', '',
    '', '', '',
    'if', '650', '9', 'equals', '462', '',
    'Delete field 650$a if 650$9=462'
), 1, 'Add third action: delete field 650$a if 650$9=462');

is( AddModificationTemplateAction(
    $template_id, 'update_field', 0,
    '952', 'p', '3010023917_updated', '', '',
    '', '', '',
    'unless', '650', '9', 'equals', '42', '',
    'Update field 952$p with "3010023917_updated" if 650$9 != 42'
), 1, 'Add fourth action: update field 952$p with "3010023917_updated" if 650$9 != 42');

is( AddModificationTemplateAction(
    $template_id, 'move_field', 0,
    '952', 'd', '', '952', 'e',
    '', '', '',
    'if', '952', 'c', 'equals', '^GEN', '1',
    'Move field 952$d to 952$e if 952$c =~ /^GEN/'
), 1, 'Add fifth action: move field 952$d to 952$e if 952$c =~ /^GEN/');

is( AddModificationTemplateAction(
    $template_id, 'update_field', 0,
    '650', 'a', 'Computer algorithms.', '', '',
    '', '', '',
    'if', '650', '9', 'equals', '499', '',
    'Update field 650$a with "Computer algorithms." to 651 if 650$9 == 499'
), 1, 'Add sixth action: update field 650$a with "Computer algorithms." if 650$9 == 499');

is( AddModificationTemplateAction(
    $template_id, 'move_field', 0,
    '650', '', '', '651', '',
    '', '', '',
    'if', '650', '9', 'equals', '499', '',
    'Move field 650 to 651 if 650$9 == 499'
), 1, 'Add seventh action: move field 650 to 651 if 650$9 == 499');

is( AddModificationTemplateAction(
    $template_id, 'update_field', 0,
    '999', 'a', 'non existent.', '', '',
    '', '', '',
    '', '', '', '', '', '',
    'Update non existent field 999$a with "non existent"'
), 1, 'Add eighth action: update field non existent 999$a with "non existent."');

is( AddModificationTemplateAction(
    $template_id, 'update_field', 0,
    '999', 'a', 'existent - updated.', '', '',
    '', '', '',
    '', '', '', '', '', '',
    'Update existent field 999$a with "existent - updated."'
), 1, 'Add ninth action: update field non existent 999$a with "existent - updated."');

is( AddModificationTemplateAction(
    $template_id, 'add_field', 0,
    '999', 'a', 'additional existent.', '', '',
    '', '', '',
    '', '', '', '', '', '',
    'Add new existent field 999$a with "additional existent"'
), 1, 'Add tenth action: add additional field existent 999$a with "additional existent."');

is( AddModificationTemplateAction(
    $template_id, 'add_field', 0,
    '007', '', 'vxcdq', '', '',
    '', '', '',
    '', '', '', '', '', '',
    'Add new existent field 999$a with "additional existent"'
), 1, 'Add eleventh action: add additional field existent 007');

my $record = new_record();
is( ModifyRecordWithTemplate( $template_id, $record ), undef, "The ModifyRecordWithTemplate returns undef" );

my $expected_record = expected_record_1();
is_deeply( $record, $expected_record, "Record modification as expected");

$template_id = AddModificationTemplate("another_template_test");

# Duplicate 245 => 3x245
is( AddModificationTemplateAction(
    $template_id, 'copy_field', 0,
    '245', '', '', '245', '',
    '', '', '',
    'if', '245', 'a', 'equals', 'Bad title', '',
    'Copy field 245 if 245$a eq "Bad title"'
), 1, 'Add action: copy field 245 if 245$a eq "Bad title"');

$record = new_record();
is( ModifyRecordWithTemplate( $template_id, $record ), undef, "The ModifyRecordWithTemplate returns undef" );

my @fields_245a = Koha::SimpleMARC::read_field({
    record => $record,
    field => '245',
    subfield => 'a',
});
is_deeply( \@fields_245a, [
        'Bad title',
        'The art of computer programming',
        'Bad title',
    ], 'Copy field has copied the "Bad title"' );

# Update first "Bad title"
is( AddModificationTemplateAction(
    $template_id, 'update_field', 1,
    '245', 'a', 'Bad title updated', '', '',
    '', '', '',
    'if', '245', 'a', 'equals', 'Bad title', '',
    'Update first 245$a matching "Bad title" with "Bad title updated"'
), 1, 'Add action: update field 245$a matching "Bad title" with "Bad title updated');

$record = new_record();
is( ModifyRecordWithTemplate( $template_id, $record ), undef, "The ModifyRecordWithTemplate returns undef" );

@fields_245a = Koha::SimpleMARC::read_field({
    record => $record,
    field => '245',
    subfield => 'a',
});
is_deeply( \@fields_245a, [
        'Bad title updated',
        'The art of computer programming',
        'Bad title',
    ], 'update_field has update first the "Bad title"' );

# Duplicate first 245 => 3x245
is( AddModificationTemplateAction(
    $template_id, 'copy_field', 1,
    '245', '', '', '245', '',
    '', '', '',
    'if', '245', 'a', 'equals', '^Bad title', '1',
    'Copy field 245 if 245$a =~ "^Bad title"'
), 1, 'Add action: copy field 245 if 245$a =~ "^Bad title"');

$record = new_record();
is( ModifyRecordWithTemplate( $template_id, $record ), undef, "The ModifyRecordWithTemplate returns undef" );

@fields_245a = Koha::SimpleMARC::read_field({
    record => $record,
    field => '245',
    subfield => 'a',
});
is_deeply( \@fields_245a, [
        'Bad title updated',
        'Bad title updated',
        'The art of computer programming',
        'Bad title',
    ], 'Copy field has copied first "^Bad title"' );

# Delete first ^Bad title
is( AddModificationTemplateAction(
    $template_id, 'delete_field', 1,
    '245', '', '', '', '',
    '', '', '',
    'if', '245', 'a', 'equals', '^Bad title', '1',
    'Delete first 245$a mathing ^Bad title'
), 1, 'Delete first 245$a mathing ^Bad title');

$record = new_record();
is( ModifyRecordWithTemplate( $template_id, $record ), undef, "The ModifyRecordWithTemplate returns undef" );
@fields_245a = Koha::SimpleMARC::read_field({
    record => $record,
    field => '245',
    subfield => 'a',
});
is_deeply( \@fields_245a, [
        'Bad title updated',
        'The art of computer programming',
        'Bad title',
    ], 'delete field has been deleted the right field"' );

is( AddModificationTemplateAction(
    $template_id, 'delete_field', 0,
    '245', '', '', '', '',
    '', '', '',
    'if', '245', 'a', 'equals', 'updated$', '1',
    'Delete first 245$a mathing updated$'
), 1, 'Delete first 245$a mathing updated$');

$record = new_record();
is( ModifyRecordWithTemplate( $template_id, $record ), undef, "The ModifyRecordWithTemplate returns undef" );
@fields_245a = Koha::SimpleMARC::read_field({
    record => $record,
    field => '245',
    subfield => 'a',
});
is_deeply( \@fields_245a, [
        'The art of computer programming',
        'Bad title'
    ], 'delete field has been deleted the right field"' );

subtest 'GetModificationTemplates' => sub {
    plan tests => 1;
    $dbh->do(q|DELETE FROM marc_modification_templates|);
    AddModificationTemplate("zzz");
    AddModificationTemplate("aaa");
    AddModificationTemplate("mmm");
    my @templates = GetModificationTemplates();
    is_deeply( [map{$_->{name}} @templates], ['aaa', 'mmm', 'zzz'] );
};

subtest "not_equals" => sub {
    plan tests => 2;
    $dbh->do(q|DELETE FROM marc_modification_templates|);
    my $template_id = AddModificationTemplate("template_name");
    AddModificationTemplateAction(
        $template_id, 'move_field', 0,
        '650', '', '', '651', '',
        '', '', '',
        'if', '650', '9', 'not_equals', '499', '',
        'Move field 650 to 651 if 650$9 != 499'
    );
    my $record = new_record();
    ModifyRecordWithTemplate( $template_id, $record );
    my $expected_record = expected_record_2();
    is_deeply( $record, $expected_record, '650 has been moved to 651 when 650$9 != 499' );

    $dbh->do(q|DELETE FROM marc_modification_templates|);
    $template_id = AddModificationTemplate("template_name");
    AddModificationTemplateAction(
        $template_id, 'move_field', 0,
        '650', '', '', '651', '',
        '', '', '',
        'if', '650', 'b', 'not_equals', '499', '',
        'Move field 650 to 651 if 650$b != 499'
    );
    $record = new_record();
    ModifyRecordWithTemplate( $template_id, $record );
    $expected_record = new_record();
    is_deeply( $record, $expected_record, 'None 650 have been moved, no $650$b exists' );
};

subtest "when conditional field doesn't match the from field" => sub {
    plan tests => 3;
    $dbh->do(q|DELETE FROM marc_modification_templates|);
    my $template_id = AddModificationTemplate("template_name");
    AddModificationTemplateAction(
        $template_id, 'delete_field', 0,
        '650', '9', '', '', '',
        '', '', '',
        'if', '245', 'a', 'equals', 'Bad title', '',
        'Delete fields 650$9 if 245$a == "Bad title"'
    );
    my $record = new_record();
    ModifyRecordWithTemplate( $template_id, $record );
    my $expected_record = expected_record_3();
    is_deeply( $record, $expected_record, '650$9 fields have been deleted when 245$a == "Bad title"' );

    $dbh->do(q|DELETE FROM marc_modification_templates|);
    $template_id = AddModificationTemplate("template_name");
    AddModificationTemplateAction(
        $template_id, 'delete_field', 0,
        '650', '9', '', '', '',
        '', '', '',
        'if', '245', 'a', 'exists', '', '',
        'Delete fields 650$9 if 245$a exists'
    );
    $record = new_record();
    ModifyRecordWithTemplate( $template_id, $record );
    $expected_record = expected_record_3();
    is_deeply( $record, $expected_record, '650$9 fields have been deleted because 245$a exists' );

    $dbh->do(q|DELETE FROM marc_modification_templates|);
    $template_id = AddModificationTemplate("template_name");
    AddModificationTemplateAction(
        $template_id, 'delete_field', 1,
        '650', '', '', '', '',
        '', '', '',
        'if', '245', 'a', 'exists', '', '',
        'Delete 1st field 650 if 245$a exists'
    );
    $record = new_record();
    ModifyRecordWithTemplate( $template_id, $record );
    $expected_record = expected_record_4();
    is_deeply( $record, $expected_record, '1st 650 field has been deleted because 245$a exists' );
};

sub new_record {
    my $record = MARC::Record->new;
    $record->leader('03174nam a2200445 a 4500');
    my @fields = (
        MARC::Field->new(
            100, '1', ' ',
            a => 'Knuth, Donald Ervin',
            d => '1938',
        ),
        MARC::Field->new(
            245, '1', '4',
            a => 'The art of computer programming',
            c => 'Donald E. Knuth.',
        ),
        MARC::Field->new(
            245, '1', '4',
            a => 'Bad title',
            c => 'Donald E. Knuth.',
        ),
        MARC::Field->new(
            650, ' ', '0',
            a => 'Computer programming.',
            9 => '462',
        ),
        MARC::Field->new(
            650, ' ', '0',
            a => 'Computer programming.',
            9 => '499',
        ),
        MARC::Field->new(
            952, ' ', ' ',
            p => '3010023917',
            y => 'BK',
            c => 'GEN',
            d => '2001-06-25',
        ),
    );
    $record->append_fields(@fields);
    return $record;
}

sub expected_record_1 {
    my $record = MARC::Record->new;
    $record->leader('03174nam a2200445 a 4500');
    my @fields = (
        MARC::Field->new(
           '007', 'vxcdq',
        ),
        MARC::Field->new(
            100, '1', ' ',
            a => 'Knuth, Donald Ervin',
            d => '1938',
        ),
        MARC::Field->new(
            245, '1', '4',
            a => 'The art of computer programming',
            c => 'Donald E. Knuth.',
        ),
        MARC::Field->new(
            246, '', ' ',
            a => 'The art of computer programming',
        ),
        MARC::Field->new(
            650, ' ', '0',
            9 => '462',
        ),
        MARC::Field->new(
            651, ' ', '0',
            a => 'Computer algorithms.',
            9 => '499',
        ),
        MARC::Field->new(
            952, ' ', ' ',
            p => '3010023917_updated',
            y => 'BK',
            c => 'GEN',
            e => '2001-06-25',
        ),
        MARC::Field->new(
            999, ' ', ' ',
            a => 'additional existent.',
        ),
        MARC::Field->new(
            999, ' ', ' ',
            a => 'existent - updated.',
        ),
    );
    $record->append_fields(@fields);
    return $record;
}

sub expected_record_2 {
    my $record = MARC::Record->new;
    $record->leader('03174nam a2200445 a 4500');
    my @fields = (
        MARC::Field->new(
            100, '1', ' ',
            a => 'Knuth, Donald Ervin',
            d => '1938',
        ),
        MARC::Field->new(
            245, '1', '4',
            a => 'The art of computer programming',
            c => 'Donald E. Knuth.',
        ),
        MARC::Field->new(
            245, '1', '4',
            a => 'Bad title',
            c => 'Donald E. Knuth.',
        ),
        MARC::Field->new(
            650, ' ', '0',
            a => 'Computer programming.',
            9 => '499',
        ),
        MARC::Field->new(
            651, ' ', '0',
            a => 'Computer programming.',
            9 => '462',
        ),
        MARC::Field->new(
            952, ' ', ' ',
            p => '3010023917',
            y => 'BK',
            c => 'GEN',
            d => '2001-06-25',
        )
    );
    $record->append_fields(@fields);
    return $record;
}

sub expected_record_3 {
    my $record = MARC::Record->new;
    $record->leader('03174nam a2200445 a 4500');
    my @fields = (
        MARC::Field->new(
            100, '1', ' ',
            a => 'Knuth, Donald Ervin',
            d => '1938',
        ),
        MARC::Field->new(
            245, '1', '4',
            a => 'The art of computer programming',
            c => 'Donald E. Knuth.',
        ),
        MARC::Field->new(
            245, '1', '4',
            a => 'Bad title',
            c => 'Donald E. Knuth.',
        ),
        MARC::Field->new(
            650, ' ', '0',
            a => 'Computer programming.',
        ),
        MARC::Field->new(
            650, ' ', '0',
            a => 'Computer programming.',
        ),
        MARC::Field->new(
            952, ' ', ' ',
            p => '3010023917',
            y => 'BK',
            c => 'GEN',
            d => '2001-06-25',
        ),
    );
    $record->append_fields(@fields);
    return $record;
}

sub expected_record_4 {
    my $record = MARC::Record->new;
    $record->leader('03174nam a2200445 a 4500');
    my @fields = (
        MARC::Field->new(
            100, '1', ' ',
            a => 'Knuth, Donald Ervin',
            d => '1938',
        ),
        MARC::Field->new(
            245, '1', '4',
            a => 'The art of computer programming',
            c => 'Donald E. Knuth.',
        ),
        MARC::Field->new(
            245, '1', '4',
            a => 'Bad title',
            c => 'Donald E. Knuth.',
        ),
        MARC::Field->new(
            650, ' ', '0',
            a => 'Computer programming.',
            9 => '499',
        ),
        MARC::Field->new(
            952, ' ', ' ',
            p => '3010023917',
            y => 'BK',
            c => 'GEN',
            d => '2001-06-25',
        ),
    );
    $record->append_fields(@fields);
    return $record;
}

# Tests related to use of subfield 0 ($0)

sub new_record_0 {
    my $record = MARC::Record->new;
    $record->leader('03174nam a2200445 a 4500');
    my @fields = (
        MARC::Field->new(
            100, '1', ' ',
            0 => '12345',
            a => 'Knuth, Donald Ervin',
            d => '1938',
        ),
        MARC::Field->new(
            245, '1', '4',
            0 => '12345',
            a => 'The art of computer programming',
            c => 'Donald E. Knuth.',
        ),
        MARC::Field->new(
            650, ' ', '0',
            0 => '42',
            a => 'Computer programming.',
            9 => '462',
        ),
        MARC::Field->new(
            590, ' ', '0',
            0 => 'Zeroth',
            a => 'Appolo',
        ),
    );
    $record->append_fields(@fields);
    return $record;
}

sub expected_record_0 {
    my $record = MARC::Record->new;
    $record->leader('03174nam a2200445 a 4500');
    my @fields = (
        MARC::Field->new(
            100, '1', ' ',
            a => 'Knuth, Donald Ervin',
            d => '1938',
            0 => 'TestUpdated',
            0 => 'TestUpdated',
        ),
        MARC::Field->new(
            245, '1', '4',
            0 => '12345',
            a => 'The art of computer programming',
            c => 'Donald E. Knuth.',
        ),
        MARC::Field->new(
            600, ' ', ' ',
            0 => 'TestUpdated',
        ),
        MARC::Field->new(
            600, ' ', ' ',
            0 => 'TestUpdated',
        ),
        MARC::Field->new(
            650, ' ', '0',
            0 => '42',
            a => 'Computer programming.',
            9 => '462',
        ),
        MARC::Field->new(
            590, ' ', '0',
            0 => 'Zeroth',
            a => 'Appolo',
        ),
        MARC::Field->new(
            690, ' ', '0',
            0 => 'Zeroth',
            a => 'Appolo',
        ),
        MARC::Field->new(
            690, ' ', ' ',
            0 => 'Zeroth',
            a => 'Appolo',
        ),
        MARC::Field->new(
            700, ' ', ' ',
            0 => '12345',
        ),
    );
    $record->append_fields(@fields);
    return $record;
}

$record = new_record_0();
is( ModifyRecordWithTemplate( $template_id, $record ), undef, "The ModifyRecordWithTemplate returns undef" );

$template_id = AddModificationTemplate("template_test_subfield_0");
like( $template_id, qr|^\d+$|, "new template returns an id" );

# Delete subfield 100$0
is( AddModificationTemplateAction(
    $template_id, 'delete_field', 0,
    '100', '0', '', '', '',
    '', '', '',
    '', '', '', '', '', '',
    'Action 1: Delete subfield 100$0'
), 1, 'Action 1: Delete subfield 100$0');

# Add new subfield 100$0 with value "Test"
# This adds a new 100 field to the record
is( AddModificationTemplateAction(
    $template_id, 'add_field', 0,
    '100', '0', 'Test', '', '',
    '', '', '',
    '', '', '', '', '', '',
    'Action 2: Add new subfield 100$0 with value "Test"'
), 1, 'Action 2: Add new subfield 100$0');

# Update existing or add new subfield 100$0 with value "TestUpdated"
# This updates the new 100 create above, and adds a new 100$0 to the original 100 field
is( AddModificationTemplateAction(
    $template_id, 'update_field', 0,
    '100', '0', 'TestUpdated', '', '',
    '', '', '',
    '', '', '', '', '', '',
    'Action 3: Update existing or add new subfield 100$0 with value "TestUpdated"'
), 1, 'Action 3: Update existing or add new subfield 100$0 with value "TestUpdated"');

# Move subfield 100$0 to 600$0
# This removes the newly created 100, and removes the 100$0 from the original 100 field
# Two 600 fields with a single 0 subfield are created
is( AddModificationTemplateAction(
    $template_id, 'move_field', 0,
    '100', '0', '', '600', '0',
    '', '', '',
    '', '', '', '', '', '',
    'Action 4: Move subfield 100$0 to 600$0'
), 1, 'Action 4: Move subfield 100$0 to 600$0');

# Copy subfield 600$0 to 100$0
# Copy subfield adds to existing fields if found, so we get two 100$0 on the original field
is( AddModificationTemplateAction(
    $template_id, 'copy_field', 0,
    '600', '0', '', '100', '0',
    '', '', '',
    '', '', '', '', '', '',
    'Action 5: Copy subfield 600$0 to 100$0'
), 1, 'Action 5: Copy subfield 600$0 to 100$0');

# Copy and replace subfield 245$0 to 700$0
# Copy and replace in this case makes a new 700$0 as it wasn't there
is( AddModificationTemplateAction(
    $template_id, 'copy_and_replace_field', 0,
    '245', '0', '', '700', '0',
    '', '', '',
    '', '', '', '', '', '',
    'Action 6: Copy and replace subfield 245$0 to 700$0'
), 1, 'Action 6: Copy and replace subfield 245$0 to 700$0');

# Copy subfield 590$0 to 690$0
# Copies the single subfield from 590 to a new 690
is( AddModificationTemplateAction(
    $template_id, 'copy_field', 0,
    '590', '0', '', '690', '0',
    '', '', '',
    '', '', '', '', '', '',
    'Action 7: Copy subfield 590$0 to 690$0'
), 1, 'Action 7: Copy subfield 590$0 to 690$0');

# Copy subfield 590$a to 690$a
# Copy subfield adds to existing 690 a new subfield a
is( AddModificationTemplateAction(
    $template_id, 'copy_field', 0,
    '590', 'a', '', '690', 'a',
    '', '', '',
    '', '', '', '', '', '',
    'Action 8: Copy subfield 690$a to 690$a'
), 1, 'Action 8: Copy subfield 690$a to 690$a');


# Copy field 590 to 690
# Copy field copies existing to a new 690, does not add to existing
is( AddModificationTemplateAction(
    $template_id, 'copy_field', 0,
    '590', '', '', '690', '',
    '', '', '',
    '', '', '', '', '', '',
    'Action 9: Copy subfield 590 to 690'
), 1, 'Action 9: Copy subfield 590 to 690');

my @actions_0 = GetModificationTemplateActions( $template_id );
is( @actions_0, 9, "9 actions are inserted");

ModifyRecordWithTemplate( $template_id, $record );
my $expected_record_0 = expected_record_0();
is_deeply(
    $record, $expected_record_0,
    '100$0 has been deleted, added back, updated, moved to 600$0, and copied back to 100$0; finally, 245$0 has been copied and replaced to 700$0'
);

# Test for Bug 32950: Moving subfield can lose values for repeatable fields
subtest "Bug 32950: Moving subfield preserves values in repeatable fields" => sub {
    plan tests => 14;
    $dbh->do(q|DELETE FROM marc_modification_templates|);
    my $template_id = AddModificationTemplate("test_bug_32950");

    # Create template action to move 020$z to 020$a
    AddModificationTemplateAction(
        $template_id, 'move_field', 0,
        '020',        'z',          '', '020', 'a',
        '',           '',           '',
        '',           '',           '', '', '', '',
        'Move field 020$z to 020$a'
    );

    # Create test record with multiple 020 fields, some with $a, some with $z
    my $record = MARC::Record->new;
    $record->leader('03174nam a2200445 a 4500');
    my @fields = (
        MARC::Field->new( '020', ' ', ' ', 'a' => '9781003182870', 'q' => '(ebk)' ),
        MARC::Field->new( '020', ' ', ' ', 'a' => '1003182879' ),
        MARC::Field->new( '020', ' ', ' ', 'a' => '9781000407204', 'q' => '(electronic bk. : EPUB)' ),
        MARC::Field->new( '020', ' ', ' ', 'z' => '9781032023175', 'q' => '(hbk.)' ),
        MARC::Field->new( '020', ' ', ' ', 'z' => '9780367760380', 'q' => '(pbk.)' ),
    );
    $record->append_fields(@fields);

    # Apply the template
    ModifyRecordWithTemplate( $template_id, $record );

    # Get all 020 fields after modification
    my @fields_020 = $record->field('020');
    is( scalar @fields_020, 5, "Should still have 5 020 fields" );

    # Check that existing $a values are preserved
    is( $fields_020[0]->subfield('a'), '9781003182870', 'First field $a value preserved' );
    is( $fields_020[0]->subfield('q'), '(ebk)',         'First field $q value preserved' );

    is( $fields_020[1]->subfield('a'), '1003182879', 'Second field $a value preserved' );

    is( $fields_020[2]->subfield('a'), '9781000407204',           'Third field $a value preserved' );
    is( $fields_020[2]->subfield('q'), '(electronic bk. : EPUB)', 'Third field $q value preserved' );

    # Check that $z values were moved to $a in fields that had $z
    is( $fields_020[3]->subfield('a'), '9781032023175', 'Fourth field $z moved to $a' );
    is( $fields_020[3]->subfield('q'), '(hbk.)',        'Fourth field $q value preserved' );

    is( $fields_020[4]->subfield('a'), '9780367760380', 'Fifth field $z moved to $a' );

    # Verify $z subfields were removed (move operation)
    for my $field (@fields_020) {
        my @z_subfields = $field->subfield('z');
        is( scalar @z_subfields, 0, 'No $z subfields should remain' );
    }

    DelModificationTemplate($template_id);
};
