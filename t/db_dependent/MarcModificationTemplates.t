use Modern::Perl;

use Test::More tests => 95;

use Koha::SimpleMARC;

use_ok("MARC::Field");
use_ok("MARC::Record");
use_ok("C4::MarcModificationTemplates");

my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

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

# Getter
my @actions = GetModificationTemplateActions( $template_id );
is( @actions, 3, "3 actions are insered");

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
is( $third_action->{action}, 'copy_field', "test  factionor third action" );
is( $third_action->{from_field}, '606', "test from_field for third action" );
is( $third_action->{from_subfield}, 'a', "test from_subfield for third action" );
is( $third_action->{to_field}, '607', "test to_field for third action" );
is( $third_action->{to_subfield}, 'a', "test to_subfield for third action" );
is( $third_action->{conditional}, 'unless', "test conditional for third action" );
is( $third_action->{conditional_field}, '606', "test conditional_field for third action" );
is( $third_action->{conditional_subfield}, 'a', "test conditional_subfield for third action" );
is( $third_action->{conditional_comparison}, 'not_equals', "test conditional_comparison for third action" );
is( $third_action->{conditional_value}, '^AJAX', "test conditional_value for third action" );


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

is( GetModificationTemplateAction( $actions[0]->{mmta_id} )->{ordering}, '3', 'First becomes third' );
is( GetModificationTemplateAction( $actions[1]->{mmta_id} )->{ordering}, '2', 'Second stays second' );
is( GetModificationTemplateAction( $actions[2]->{mmta_id} )->{ordering}, '1', 'Third becomes first' );

is( MoveModificationTemplateAction( $actions[0]->{mmta_id}, 'up' ), '1', 'Move up the first action (was third)' );
is( MoveModificationTemplateAction( $actions[0]->{mmta_id}, 'up' ), '1', 'Move up the first action (was second)' );
is( MoveModificationTemplateAction( $actions[2]->{mmta_id}, 'down' ), '1', 'Move down the third action (was second)' );

is( GetModificationTemplateAction( $actions[0]->{mmta_id} )->{ordering}, '1', 'First becomes again first' );
is( GetModificationTemplateAction( $actions[1]->{mmta_id} )->{ordering}, '2', 'Second stays again second' );
is( GetModificationTemplateAction( $actions[2]->{mmta_id} )->{ordering}, '3', 'Third becomes again third' );

# Cleaning
is( DelModificationTemplateAction( $actions[0]->{mmta_id} ), 2, "Delete the first action, 2 others are reordered" );
is( GetModificationTemplateAction( $actions[0]->{mmta_id} ), undef, "first action does not exist anymore" );

is( DelModificationTemplate( $template_id ), 1, "The template has been deleted" );

is( GetModificationTemplateAction( $actions[1]->{mmta_id} ), undef, "second action does not exist anymore" );
is( GetModificationTemplateAction( $actions[2]->{mmta_id} ), undef, "third action does not exist anymore" );

is( GetModificationTemplateActions( $template_id ), 0, "There is no action for deleted template" );

# ModifyRecordWithTemplate
my @USERENV = (
    1,
    'test',
    'MASTERTEST',
    'Test',
    'Test',
    't',
    'Test',
    0,
);
C4::Context->_new_userenv ('DUMMY_SESSION_ID');
C4::Context->set_userenv ( @USERENV );

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
        'The art of computer programming',
        'Bad title',
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
        'The art of computer programming',
        'Bad title updated',
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
        'The art of computer programming',
        'Bad title updated',
        'Bad title',
        'Bad title updated',
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
        'The art of computer programming',
        'Bad title',
        'Bad title updated',
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
            650, ' ', '0',
            9 => '462',
        ),
        MARC::Field->new(
            952, ' ', ' ',
            p => '3010023917_updated',
            y => 'BK',
            c => 'GEN',
            e => '2001-06-25',
        ),
        MARC::Field->new(
            246, '', ' ',
            a => 'The art of computer programming',
        ),
        MARC::Field->new(
            651, ' ', '0',
            a => 'Computer algorithms.',
            9 => '499',
        ),
        MARC::Field->new(
            999, ' ', ' ',
            a => 'non existent.',
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
            650, ' ', '0',
            9 => '462',
        ),
        MARC::Field->new(
            952, ' ', ' ',
            p => '3010023917_updated',
            y => 'BK',
            c => 'GEN',
            e => '2001-06-25',
        ),
        MARC::Field->new(
            246, '', ' ',
            a => 'The art of computer programming',
        ),
        MARC::Field->new(
            651, ' ', '0',
            a => 'Computer algorithms.',
            9 => '499',
        ),
        MARC::Field->new(
            999, ' ', ' ',
            a => 'non existent.',
        ),
    );
    $record->append_fields(@fields);
    return $record;
}

# C4::Context->userenv
sub Mock_userenv {
    return { branchcode => 'CPL' };
}
