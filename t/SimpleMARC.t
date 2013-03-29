use Modern::Perl;

use Test::More tests => 37;

use_ok("MARC::Field");
use_ok("MARC::Record");
use_ok("Koha::SimpleMARC");

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
            650, ' ', '0',
            a => 'Computer programming.',
            9 => '462',
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

my $record = new_record;

# field_exists
is( field_exists( $record, '650', 'a'), 'Computer programming.', '650$a exists' );
is( field_exists( $record, '650', 'b'), undef, '650$b does not exist' );

$record->append_fields(
    MARC::Field->new(
        650, ' ', '0',
        a => 'Computer algorithms.',
        9 => '463',
    )
);

is( field_exists( $record, '650', 'a'), 'Computer programming.', '650$a exists, field_exists returns the first one' );

# read_field
my @fields_650a = read_field( $record, '650', 'a');
is( $fields_650a[0], 'Computer programming.', 'first 650$a' );
is( $fields_650a[1], 'Computer algorithms.', 'second 650$a' );
is( read_field( $record, '650', 'a', 1 ), 'Computer programming.', 'first 650$a bis' );
is( read_field( $record, '650', 'a', 2 ), 'Computer algorithms.', 'second 650$a bis' );
is( read_field( $record, '650', 'a', 3 ), undef, 'There is no 3 650$a' );

# copy_field
copy_field( $record, '245', 'a', '246', 'a' );
is_deeply( read_field( $record, '245', 'a' ), 'The art of computer programming', 'After copy 245$a still exists' );
is_deeply( read_field( $record, '246', 'a' ), 'The art of computer programming', '246$a is a new field' );
delete_field( $record, '246' );
is( field_exists( $record, '246', 'a', '246$a does not exist anymore' ), undef );

copy_field( $record, '650', 'a', '651', 'a' );
my @fields_651a = read_field( $record, '651', 'a' );
is_deeply( \@fields_651a, ['Computer programming.', 'Computer algorithms.'], 'Copy multivalued field' );
delete_field( $record, '651' );

copy_field( $record, '650', 'a', '651', 'a', undef, 1 );
@fields_651a = read_field( $record, '651', 'a' );
is_deeply( read_field( $record, '651', 'a' ), 'Computer programming.', 'Copy first field 650$a' );
delete_field( $record, '651' );

copy_field( $record, '650', 'a', '651', 'a', undef, 2 );
@fields_651a = read_field( $record, '651', 'a' );
is_deeply( read_field( $record, '651', 'a' ), 'Computer algorithms.', 'Copy second field 650$a' );
delete_field( $record, '651' );

copy_field( $record, '650', 'a', '651', 'a', { search => 'Computer', replace => 'The art of' } );
@fields_651a = read_field( $record, '651', 'a' );
is_deeply( \@fields_651a, ['The art of programming.', 'The art of algorithms.'], 'Copy field using regex' );

copy_field( $record, '650', 'a', '651', 'a', { search => 'Computer', replace => 'The mistake of' } );
@fields_651a = read_field( $record, '651', 'a' );
is_deeply( \@fields_651a, ['The mistake of programming.', 'The mistake of algorithms.'], 'Copy fields using regex on existing fields' );
delete_field( $record, '651' );

copy_field( $record, '650', 'a', '651', 'a', { search => 'Computer', replace => 'The art of' } );
copy_field( $record, '650', 'a', '651', 'a', { search => 'Computer', replace => 'The mistake of' }, 1, "dont_erase" );
@fields_651a = read_field( $record, '651', 'a' );
is_deeply( \@fields_651a, [
    'The art of programming.',
    'The mistake of programming.',
    'The art of algorithms.',
    'The mistake of programming.'
], 'Copy first field using regex on existing fields without erase existing values' );
delete_field( $record, '651' );

copy_field( $record, '650', 'a', '651', 'a', { search => 'Computer', replace => 'The art of' } );
copy_field( $record, '650', 'a', '651', 'a', { search => 'Computer', replace => 'The mistake of' }, undef , "dont_erase" );
@fields_651a = read_field( $record, '651', 'a' );
is_deeply( \@fields_651a, [
    'The art of programming.',
    'The mistake of programming.',
    'The mistake of algorithms.',
    'The art of algorithms.',
    'The mistake of programming.',
    'The mistake of algorithms.'
], 'Copy fields using regex on existing fields without erase existing values' );
delete_field( $record, '651' );

# Copy with regex modifiers
copy_field( $record, '650', 'a', '652', 'a', { search => 'o', replace => 'foo' } );
my @fields_652a = read_field( $record, '652', 'a' );
is_deeply( \@fields_652a, ['Cfoomputer programming.', 'Cfoomputer algorithms.'], 'Copy field using regex' );

copy_field( $record, '650', 'a', '653', 'a', { search => 'o', replace => 'foo', modifiers => 'g' } );
my @fields_653a = read_field( $record, '653', 'a' );
is_deeply( \@fields_653a, ['Cfoomputer prfoogramming.', 'Cfoomputer algfoorithms.'], 'Copy field using regex' );

copy_field( $record, '650', 'a', '654', 'a', { search => 'O', replace => 'foo', modifiers => 'i' } );
my @fields_654a = read_field( $record, '654', 'a' );
is_deeply( \@fields_654a, ['Cfoomputer programming.', 'Cfoomputer algorithms.'], 'Copy field using regex' );

copy_field( $record, '650', 'a', '655', 'a', { search => 'O', replace => 'foo', modifiers => 'gi' } );
my @fields_655a = read_field( $record, '655', 'a' );
is_deeply( \@fields_655a, ['Cfoomputer prfoogramming.', 'Cfoomputer algfoorithms.'], 'Copy field using regex' );

# update_field
update_field( $record, '952', 'p', undef, '3010023918' );
is_deeply( read_field( $record, '952', 'p' ), '3010023918', 'update existing subfield 952$p' );
delete_field( $record, '952' );
update_field( $record, '952', 'p', undef, '3010023918' );
update_field( $record, '952', 'y', undef, 'BK' );
is_deeply( read_field( $record, '952', 'p' ), '3010023918', 'create subfield 952$p' );
is_deeply( read_field( $record, '952', 'y' ), 'BK', 'create subfield 952$k on existing 952 field' );
$record->append_fields(
    MARC::Field->new(
        952, ' ', ' ',
        p => '3010023917',
        y => 'BK',
    ),
);
update_field( $record, '952', 'p', undef, '3010023919' );
my @fields_952p = read_field( $record, '952', 'p' );
is_deeply( \@fields_952p, ['3010023919', '3010023919'], 'update all subfields 952$p with the same value' );

update_field( $record, '952', 'p', undef, ('3010023917', '3010023918') );
@fields_952p = read_field( $record, '952', 'p' );
is_deeply( \@fields_952p, ['3010023917', '3010023918'], 'update all subfields 952$p with the different values' );

# move_field
$record = new_record;
my ( @fields_952d, @fields_952c, @fields_954c, @fields_954p);
$record->append_fields(
    MARC::Field->new(
        952, ' ', ' ',
        p => '3010023917',
        y => 'BK',
    ),
);
copy_field( $record, '952', 'd', '952', 'd' );
@fields_952d = read_field( $record, '952', 'd' );
is_deeply( \@fields_952d, ['2001-06-25', '2001-06-25'], 'copy 952$d into others 952 field' );

move_field( $record, '952', 'c', '954', 'c' );
@fields_952c = read_field( $record, '952', 'c' );
@fields_954c = read_field( $record, '954', 'c' );
is_deeply( \@fields_952c, [], 'The 952$c has moved' );
is_deeply( \@fields_954c, ['GEN'], 'Now 954$c exists' );

move_field( $record, '952', 'p', '954', 'p', undef, 1 ); # Move the first field
@fields_952p = read_field( $record, '952', 'p' );
@fields_954p = read_field( $record, '954', 'p' );
is_deeply( \@fields_952p, ['3010023917'], 'One of 952$p has moved' );
is_deeply( \@fields_954p, ['3010023917'], 'Now 954$p exists' );

$record = new_record;
$record->append_fields(
    MARC::Field->new(
        952, ' ', ' ',
        p => '3010023917',
        y => 'BK',
    ),
);

move_field( $record, '952', 'p', '954', 'p' ); # Move all field
@fields_952p = read_field( $record, '952', 'p' );
@fields_954p = read_field( $record, '954', 'p' );
is_deeply( \@fields_952p, [], 'All 952$p have moved' );
is_deeply( \@fields_954p, ['3010023917', '3010023917'], 'Now 2 954$p exist' );

