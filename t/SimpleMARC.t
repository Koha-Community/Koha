use Modern::Perl;

use Test::More tests => 10;

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

# field_exists
subtest 'field_exists' => sub {
    plan tests => 3;
    my $record = new_record;
    is_deeply(
        field_exists( { record => $record, field => '650', subfield => 'a' } ),
        [1],
        '650$a exists'
    );
    is_deeply(
        field_exists( { record => $record, field => '650', subfield => 'b' } ),
        [],
        '650$b does not exist'
    );

    $record->append_fields(
        MARC::Field->new(
            650, ' ', '0',
            a => 'Computer algorithms.',
            9 => '463',
        )
    );

    is_deeply(
        field_exists( { record => $record, field => '650', subfield => 'a' } ),
        [ 1, 2 ],
        '650$a exists, field_exists returns the 2 field numbers'
    );
};

# read_field
subtest 'read_field' => sub {
    plan tests              => 2;
    subtest 'read subfield' => sub {
        plan tests => 5;
        my $record = new_record;
        $record->append_fields(
            MARC::Field->new(
                650, ' ', '0',
                a => 'Computer algorithms.',
                9 => '463',
            )
        );

        my @fields_650a =
          read_field( { record => $record, field => '650', subfield => 'a' } );
        is_deeply( $fields_650a[0], 'Computer programming.', 'first 650$a' );
        is_deeply( $fields_650a[1], 'Computer algorithms.',  'second 650$a' );
        is_deeply(
            [
                read_field(
                    {
                        record        => $record,
                        field         => '650',
                        subfield      => 'a',
                        field_numbers => [1]
                    }
                )
            ],
            ['Computer programming.'],
            'first 650$a bis'
        );
        is_deeply(
            [
                read_field(
                    {
                        record        => $record,
                        field         => '650',
                        subfield      => 'a',
                        field_numbers => [2]
                    }
                )
            ],
            ['Computer algorithms.'],
            'second 650$a bis'
        );
        is_deeply(
            [
                read_field(
                    {
                        record        => $record,
                        field         => '650',
                        subfield      => 'a',
                        field_numbers => [3]
                    }
                )
            ],
            [],
            'There is no 3 650$a'
        );
    };
    subtest 'read field' => sub {
        plan tests => 4;
        my $record = new_record;
        $record->append_fields(
            MARC::Field->new(
                650, ' ', '0',
                a => 'Computer algorithms.',
                9 => '463',
            )
        );
        is_deeply(
            [
                read_field(
                    {
                        record => $record,
                        field  => '650'
                    }
                )
            ],
            [ 'Computer programming.', '462', 'Computer algorithms.', '463' ],
            'Get the all subfield values for field 650'
        );
        is_deeply(
            [
                read_field(
                    {
                        record        => $record,
                        field         => '650',
                        field_numbers => [1]
                    }
                )
            ],
            [ 'Computer programming.', '462' ],
            'Get the all subfield values for the first field 650'
        );
        is_deeply(
            [
                read_field(
                    { record => $record, field => '650', field_numbers => [2] }
                )
            ],
            [ 'Computer algorithms.', '463' ],
            'Get the all subfield values for the second field 650'
        );
        is_deeply(
            [
                read_field(
                    { record => $record, field => '650', field_numbers => [3] }
                )
            ],
            [],
'Get the all subfield values for the third field 650 which does not exist'
        );
    };
};

# update_field
subtest 'update_field' => sub {
    plan tests                => 1;
    subtest 'update subfield' => sub {
        plan tests => 5;
        my $record = new_record;

        update_field(
            {
                record   => $record,
                field    => '952',
                subfield => 'p',
                values   => ['3010023918']
            }
        );
        is_deeply(
            [
                read_field(
                    { record => $record, field => '952', subfield => 'p' }
                )
            ],
            ['3010023918'],
            'update existing subfield 952$p'
        );
        delete_field( { record => $record, field => '952' } );
        update_field(
            {
                record   => $record,
                field    => '952',
                subfield => 'p',
                values   => ['3010023918']
            }
        );
        update_field(
            {
                record   => $record,
                field    => '952',
                subfield => 'y',
                values   => ['BK']
            }
        );
        is_deeply(
            [
                read_field(
                    { record => $record, field => '952', subfield => 'p' }
                )
            ],
            ['3010023918'],
            'create subfield 952$p'
        );
        is_deeply(
            read_field(
                { record => $record, field => '952', subfield => 'y' }
            ),
            'BK',
            'create subfield 952$k on existing 952 field'
        );

        $record->append_fields(
            MARC::Field->new(
                952, ' ', ' ',
                p => '3010023917',
                y => 'BK',
            ),
        );
        update_field(
            {
                record   => $record,
                field    => '952',
                subfield => 'p',
                values   => ['3010023919']
            }
        );
        my @fields_952p =
          read_field( { record => $record, field => '952', subfield => 'p' } );
        is_deeply(
            \@fields_952p,
            [ '3010023919', '3010023919' ],
            'update all subfields 952$p with the same value'
        );

        update_field(
            {
                record   => $record,
                field    => '952',
                subfield => 'p',
                values   => [ '3010023917', '3010023918' ]
            }
        );
        @fields_952p =
          read_field( { record => $record, field => '952', subfield => 'p' } );
        is_deeply(
            \@fields_952p,
            [ '3010023917', '3010023918' ],
            'update all subfields 952$p with the different values'
        );
    };
};

# copy_field - subfield
subtest 'copy_field' => sub {
    plan tests              => 2;
    subtest 'copy subfield' => sub {
        plan tests => 20;
        my $record = new_record;
        $record->append_fields(
            MARC::Field->new(
                650, ' ', '0',
                a => 'Computer algorithms.',
                9 => '463',
            )
        );
        copy_field(
            {
                record        => $record,
                from_field    => '245',
                from_subfield => 'a',
                to_field      => '246',
                to_subfield   => 'a'
            }
        );
        is_deeply(
            [
                read_field(
                    { record => $record, field => '245', subfield => 'a' }
                )
            ],
            ['The art of computer programming'],
            'After copy 245$a still exists'
        );
        is_deeply(
            [
                read_field(
                    { record => $record, field => '246', subfield => 'a' }
                )
            ],
            ['The art of computer programming'],
            '246$a is a new field'
        );
        delete_field( { record => $record, field => '246' } );
        is_deeply(
            field_exists(
                { record => $record, field => '246', subfield => 'a' }
            ),
            [],
            '246$a does not exist anymore'
        );

        copy_field(
            {
                record        => $record,
                from_field    => '650',
                from_subfield => 'a',
                to_field      => '651',
                to_subfield   => 'a'
            }
        );
        my @fields_651a =
          read_field( { record => $record, field => '651', subfield => 'a' } );
        is_deeply(
            \@fields_651a,
            [ 'Computer programming.', 'Computer algorithms.' ],
            'Copy multivalued field'
        );
        delete_field( { record => $record, field => '651' } );

        copy_field(
            {
                record        => $record,
                from_field    => '650',
                from_subfield => 'a',
                to_field      => '651',
                to_subfield   => 'a',
                field_numbers => [1]
            }
        );
        is_deeply(
            [
                read_field(
                    { record => $record, field => '651', subfield => 'a' }
                )
            ],
            ['Computer programming.'],
            'Copy first field 650$a'
        );
        delete_field( { record => $record, field => '652' } );

        copy_field(
            {
                record        => $record,
                from_field    => '650',
                from_subfield => 'a',
                to_field      => '651',
                to_subfield   => 'a',
                field_numbers => [2]
            }
        );
        is_deeply(
            [
                read_field(
                    { record => $record, field => '651', subfield => 'a' }
                )
            ],
            ['Computer programming.', 'Computer algorithms.'],
            'Copy second field 650$a'
        );
        delete_field( { record => $record, field => '651' } );

        copy_field(
            {
                record        => $record,
                from_field    => '650',
                from_subfield => 'a',
                to_field      => '651',
                to_subfield   => 'a',
                regex => { search => 'Computer', replace => 'The art of' }
            }
        );
        @fields_651a =
          read_field( { record => $record, field => '651', subfield => 'a' } );
        is_deeply(
            \@fields_651a,
            [ 'The art of programming.', 'The art of algorithms.' ],
            'Copy field using regex'
        );
        delete_field( { record => $record, field => '651' } );

        copy_field(
            {
                record        => $record,
                from_field    => '650',
                from_subfield => 'a',
                to_field      => '651',
                to_subfield   => 'a',
                regex => { search => 'Computer', replace => 'The mistake of' }
            }
        );
        @fields_651a =
          read_field( { record => $record, field => '651', subfield => 'a' } );
        is_deeply(
            \@fields_651a,
            [ 'The mistake of programming.', 'The mistake of algorithms.' ],
            'Copy fields using regex on existing fields'
        );
        delete_field( { record => $record, field => '651' } );

        copy_field(
            {
                record        => $record,
                from_field    => '650',
                from_subfield => 'a',
                to_field      => '651',
                to_subfield   => 'a',
                regex => { search => 'Computer', replace => 'The art of' }
            }
        );
        @fields_651a =
          read_field( { record => $record, field => '651', subfield => 'a' } );
        is_deeply(
            \@fields_651a,
            [ 'The art of programming.', 'The art of algorithms.', ],
            'Copy all fields using regex'
        );
        delete_field( { record => $record, field => '651' } );

        copy_field(
            {
                record        => $record,
                from_field    => '650',
                from_subfield => 'a',
                to_field      => '651',
                to_subfield   => 'a',
                regex => { search => 'Computer', replace => 'The art of' },
                field_numbers => [1]
            }
        );
        @fields_651a =
          read_field( { record => $record, field => '651', subfield => 'a' } );
        is_deeply(
            \@fields_651a,
            [ 'The art of programming.', ],
            'Copy first field using regex'
        );
        delete_field( { record => $record, field => '651' } );

        # Copy with regex modifiers
        $record = new_record;
        $record->append_fields(
            MARC::Field->new(
                650, ' ', '0',
                a => 'Computer algorithms.',
                9 => '463',
            )
        );
        copy_field(
            {
                record        => $record,
                from_field    => '650',
                from_subfield => 'a',
                to_field      => '652',
                to_subfield   => 'a',
                regex         => { search => 'o', replace => 'foo' }
            }
        );
        my @fields_652a =
          read_field( { record => $record, field => '652', subfield => 'a' } );
        is_deeply(
            \@fields_652a,
            [ 'Cfoomputer programming.', 'Cfoomputer algorithms.' ],
            'Copy field using regex'
        );

        copy_field(
            {
                record        => $record,
                from_field    => '650',
                from_subfield => 'a',
                to_field      => '653',
                to_subfield   => 'a',
                regex => { search => 'o', replace => 'foo', modifiers => 'g' }
            }
        );
        my @fields_653a =
          read_field( { record => $record, field => '653', subfield => 'a' } );
        is_deeply(
            \@fields_653a,
            [ 'Cfoomputer prfoogramming.', 'Cfoomputer algfoorithms.' ],
            'Copy field using regex'
        );

        copy_field(
            {
                record        => $record,
                from_field    => '650',
                from_subfield => 'a',
                to_field      => '654',
                to_subfield   => 'a',
                regex => { search => 'O', replace => 'foo', modifiers => 'i' }
            }
        );
        my @fields_654a =
          read_field( { record => $record, field => '654', subfield => 'a' } );
        is_deeply(
            \@fields_654a,
            [ 'Cfoomputer programming.', 'Cfoomputer algorithms.' ],
            'Copy field using regex'
        );

        copy_field(
            {
                record        => $record,
                from_field    => '650',
                from_subfield => 'a',
                to_field      => '655',
                to_subfield   => 'a',
                regex => { search => 'O', replace => 'foo', modifiers => 'gi' }
            }
        );
        my @fields_655a =
          read_field( { record => $record, field => '655', subfield => 'a' } );
        is_deeply(
            \@fields_655a,
            [ 'Cfoomputer prfoogramming.', 'Cfoomputer algfoorithms.' ],
            'Copy field using regex'
        );

        $record = new_record;
        $record->append_fields(
            MARC::Field->new(
                952, ' ', ' ',
                p => '3010023917',
                y => 'BK',
            ),
        );

        copy_field(
            {
                record        => $record,
                from_field    => '952',
                from_subfield => 'd',
                to_field      => '952',
                to_subfield   => 'd'
            }
        );
        my @fields_952d =
          read_field( { record => $record, field => '952', subfield => 'd' } );
        # FIXME We need a new action "duplicate" if we don't want to modify the original field
        is_deeply(
            \@fields_952d,
            [ '2001-06-25', '2001-06-25', '2001-06-25' ],
            'copy 952$d into others 952 field'
        );

        copy_field(
            {
                record        => $record,
                from_field    => '111',
                from_subfield => '1',
                to_field      => '999',
                to_subfield   => '9'
            }
        );
        my @fields_9999 =
          read_field( { record => $record, field => '999', subfield => '9' } );
        is_deeply( \@fields_9999, [],
            'copy a nonexistent subfield does not create a new one' );

        $record = new_record;
        copy_field(
            {
                record        => $record,
                from_field    => 245,
                from_subfield => 'a',
                to_field      => 245,
                to_subfield   => 'a',
                regex         => { search => '^', replace => 'BEGIN ' }
            }
        );
        is_deeply(
            [
                read_field(
                    { record => $record, field => '245', subfield => 'a' }
                )
            ],
            ['The art of computer programming', 'BEGIN The art of computer programming'],
            'Update a subfield: add a string at the beginning'
        );

        $record = new_record;
        copy_field(
            {
                record        => $record,
                from_field    => 245,
                from_subfield => 'a',
                to_field      => 245,
                to_subfield   => 'a',
                regex         => { search => '$', replace => ' END' }
            }
        );
        is_deeply(
            [
                read_field(
                    { record => $record, field => '245', subfield => 'a' }
                )
            ],
            ['The art of computer programming', 'The art of computer programming END'],
            'Update a subfield: add a string at the end'
        );

        $record = new_record;
        copy_field(
            {
                record        => $record,
                from_field    => 245,
                from_subfield => 'c',
                to_field      => 650,
                to_subfield   => 'c',
            }
        );

        is_deeply(
            [
                read_field(
                    { record => $record, field => '650' }
                )
            ],
            [ 'Computer programming.', '462', 'Donald E. Knuth.' ],
            'Copy a subfield to an existent field but inexistent subfield'
        );

        $record = new_record;
        copy_field(
            {
                record        => $record,
                from_field    => 245,
                from_subfield => 'c',
                to_field      => 650,
                to_subfield   => '9',
            }
        );

        is_deeply(
            [
                read_field(
                    { record => $record, field => '650' }
                )
            ],
            [ 'Computer programming.', '462', 'Donald E. Knuth.' ],
            'Copy a subfield to an existent field / subfield'
        );
    };

    subtest 'copy field' => sub {
        plan tests => 14;
        my $record = new_record;
        $record->append_fields(
            MARC::Field->new(
                952, ' ', ' ',
                p => '3010023918',
                y => 'CD',
            ),
        );

        #- copy all fields
        copy_field(
            { record => $record, from_field => '952', to_field => '953' } );
        my @fields_952 = read_field( { record => $record, field => '952' } );
        is_deeply(
            [
                read_field(
                    { record => $record, field => '952', field_numbers => [1] }
                )
            ],
            [ '3010023917', 'BK', 'GEN', '2001-06-25' ],
            "copy all: original first field still exists"
        );
        is_deeply(
            [
                read_field(
                    { record => $record, field => '952', field_numbers => [2] }
                )
            ],
            [ '3010023918', 'CD' ],
            "copy all: original second field still exists"
        );
        is_deeply(
            [
                read_field(
                    { record => $record, field => '953', field_numbers => [1] }
                )
            ],
            [ '3010023917', 'BK', 'GEN', '2001-06-25' ],
            "copy all: first original fields has been copied"
        );
        is_deeply(
            [
                read_field(
                    { record => $record, field => '953', field_numbers => [2] }
                )
            ],
            [ '3010023918', 'CD' ],
            "copy all: second original fields has been copied"
        );

        #- copy only the first field
        copy_field(
            {
                record        => $record,
                from_field    => '953',
                to_field      => '954',
                field_numbers => [1]
            }
        );
        is_deeply(
            [
                read_field(
                    { record => $record, field => '953', field_numbers => [1] }
                )
            ],
            [ '3010023917', 'BK', 'GEN', '2001-06-25' ],
            "copy first: first original fields has been copied"
        );
        is_deeply(
            [
                read_field(
                    { record => $record, field => '953', field_numbers => [2] }
                )
            ],
            [ '3010023918', 'CD' ],
            "copy first: second original fields has been copied"
        );
        is_deeply(
            [ read_field( { record => $record, field => '954' } ) ],
            [ '3010023917', 'BK', 'GEN', '2001-06-25' ],
            "copy first: only first, first 953 has been copied"
        );

        $record = new_record;
        $record->append_fields(
            MARC::Field->new(
                952, ' ', ' ',
                p => '3010023918',
                y => 'CD',
            ),
        );

        #- copy all fields and modify values using a regex
        copy_field(
            {
                record     => $record,
                from_field => '952',
                to_field   => '953',
                regex      => { search => '30100', replace => '42424' }
            }
        );
        is_deeply(
            [
                read_field(
                    { record => $record, field => '952', field_numbers => [1] }
                )
            ],
            [ '3010023917', 'BK', 'GEN', '2001-06-25' ],
            "copy all with regex: original first field still exists"
        );
        is_deeply(
            [
                read_field(
                    { record => $record, field => '952', field_numbers => [2] }
                )
            ],
            [ '3010023918', 'CD' ],
            "copy all with regex: original second field still exists"
        );
        is_deeply(
            [
                read_field(
                    { record => $record, field => '953', field_numbers => [1] }
                )
            ],
            [ '4242423917', 'BK', 'GEN', '2001-06-25' ],
            "copy all with regex: first original fields has been copied"
        );
        is_deeply(
            [
                read_field(
                    { record => $record, field => '953', field_numbers => [2] }
                )
            ],
            [ '4242423918', 'CD' ],
            "copy all with regex: second original fields has been copied"
        );
        copy_field(
            {
                record     => $record,
                from_field => '111',
                to_field   => '999',
            }
        );
        my @fields_9999 =
          read_field( { record => $record, field => '999', subfield => '9' } );
        is_deeply( \@fields_9999, [],
            'copy a nonexistent field does not create a new one' );

        $record = new_record;
        copy_field(
            {
                record        => $record,
                from_field    => 245,
                to_field      => 650,
            }
        );

        is_deeply(
            [
                read_field(
                    { record => $record, field => '650', field_numbers => [2] }
                )
            ],
            [ 'The art of computer programming', 'Donald E. Knuth.' ],
            'Copy a field to existent fields should create a new field'
        );
        is_deeply(
            [
                read_field(
                    { record => $record, field => '650', field_numbers => [1] }
                )
            ],
            [ 'Computer programming.', '462' ],
            'Copy a field to existent fields should create a new field, the original one should not have been updated'
        );
    };
};

# copy_and_replace_field - subfield
subtest 'copy_and_replace_field' => sub {
    plan tests              => 2;
    subtest 'copy and replace subfield' => sub {
        plan tests => 19;
        my $record = new_record;
        $record->append_fields(
            MARC::Field->new(
                650, ' ', '0',
                a => 'Computer algorithms.',
                9 => '463',
            )
        );
        copy_and_replace_field(
            {
                record        => $record,
                from_field    => '245',
                from_subfield => 'a',
                to_field      => '246',
                to_subfield   => 'a'
            }
        );
        is_deeply(
            [
                read_field(
                    { record => $record, field => '245', subfield => 'a' }
                )
            ],
            ['The art of computer programming'],
            'Copy and replace should not have modify original subfield 245$a (same as copy)'
        );
        is_deeply(
            [
                read_field(
                    { record => $record, field => '246', subfield => 'a' }
                )
            ],
            ['The art of computer programming'],
            'Copy and replace should create a new 246$a (same as copy)'
        );

        $record = new_record;
        $record->append_fields(
            MARC::Field->new(
                650, ' ', '0',
                a => 'Computer algorithms.',
                9 => '463',
            )
        );
        copy_and_replace_field(
            {
                record        => $record,
                from_field    => '650',
                from_subfield => 'a',
                to_field      => '651',
                to_subfield   => 'a'
            }
        );
        my @fields_651a =
          read_field( { record => $record, field => '651', subfield => 'a' } );
        is_deeply(
            \@fields_651a,
            [ 'Computer programming.', 'Computer algorithms.' ],
            'Copy and replace multivalued field (same as copy)'
        );
        delete_field( { record => $record, field => '651' } );

        copy_and_replace_field(
            {
                record        => $record,
                from_field    => '650',
                from_subfield => 'a',
                to_field      => '651',
                to_subfield   => 'a',
                field_numbers => [1]
            }
        );
        is_deeply(
            [
                read_field(
                    { record => $record, field => '651', subfield => 'a' }
                )
            ],
            ['Computer programming.'],
            'Copy and replace first field 650$a should only copy the 1st (same as copy)'
        );

        copy_and_replace_field(
            {
                record        => $record,
                from_field    => '650',
                from_subfield => 'a',
                to_field      => '651',
                to_subfield   => 'a',
                field_numbers => [2]
            }
        );
        is_deeply(
            [
                read_field(
                    { record => $record, field => '651', subfield => 'a' }
                )
            ],
            ['Computer algorithms.'],
            'Copy and replace second field 650$a should erase 651$a'
        );
        delete_field( { record => $record, field => '651' } );

        copy_and_replace_field(
            {
                record        => $record,
                from_field    => '650',
                from_subfield => 'a',
                to_field      => '651',
                to_subfield   => 'a',
                regex => { search => 'Computer', replace => 'The art of' }
            }
        );
        @fields_651a =
          read_field( { record => $record, field => '651', subfield => 'a' } );
        is_deeply(
            \@fields_651a,
            [ 'The art of programming.', 'The art of algorithms.' ],
            'Copy and replace field using regex (same as copy)'
        );
        delete_field( { record => $record, field => '651' } );

        copy_and_replace_field(
            {
                record        => $record,
                from_field    => '650',
                from_subfield => 'a',
                to_field      => '651',
                to_subfield   => 'a',
                regex => { search => 'Computer', replace => 'The mistake of' }
            }
        );
        @fields_651a =
          read_field( { record => $record, field => '651', subfield => 'a' } );
        is_deeply(
            \@fields_651a,
            [ 'The mistake of programming.', 'The mistake of algorithms.' ],
            'Copy and replace fields using regex on existing fields (same as copy)'
        );
        delete_field( { record => $record, field => '651' } );

        copy_and_replace_field(
            {
                record        => $record,
                from_field    => '650',
                from_subfield => 'a',
                to_field      => '651',
                to_subfield   => 'a',
                regex => { search => 'Computer', replace => 'The art of' }
            }
        );
        @fields_651a =
          read_field( { record => $record, field => '651', subfield => 'a' } );
        is_deeply(
            \@fields_651a,
            [ 'The art of programming.', 'The art of algorithms.', ],
            'Copy and replace all fields using regex (same as copy)'
        );
        delete_field( { record => $record, field => '651' } );

        copy_and_replace_field(
            {
                record        => $record,
                from_field    => '650',
                from_subfield => 'a',
                to_field      => '651',
                to_subfield   => 'a',
                regex => { search => 'Computer', replace => 'The art of' },
                field_numbers => [1]
            }
        );
        @fields_651a =
          read_field( { record => $record, field => '651', subfield => 'a' } );
        is_deeply(
            \@fields_651a,
            [ 'The art of programming.', ],
            'Copy and replace first field using regex (same as copy)'
        );
        delete_field( { record => $record, field => '651' } );

        # Copy and replace with regex modifiers
        $record = new_record;
        $record->append_fields(
            MARC::Field->new(
                650, ' ', '0',
                a => 'Computer algorithms.',
                9 => '463',
            )
        );
        copy_and_replace_field(
            {
                record        => $record,
                from_field    => '650',
                from_subfield => 'a',
                to_field      => '652',
                to_subfield   => 'a',
                regex         => { search => 'o', replace => 'foo' }
            }
        );
        my @fields_652a =
          read_field( { record => $record, field => '652', subfield => 'a' } );
        is_deeply(
            \@fields_652a,
            [ 'Cfoomputer programming.', 'Cfoomputer algorithms.' ],
            'Copy and replace field using regex (same as copy)'
        );

        copy_and_replace_field(
            {
                record        => $record,
                from_field    => '650',
                from_subfield => 'a',
                to_field      => '653',
                to_subfield   => 'a',
                regex => { search => 'o', replace => 'foo', modifiers => 'g' }
            }
        );
        my @fields_653a =
          read_field( { record => $record, field => '653', subfield => 'a' } );
        is_deeply(
            \@fields_653a,
            [ 'Cfoomputer prfoogramming.', 'Cfoomputer algfoorithms.' ],
            'Copy and replace field using regex (same as copy)'
        );

        copy_and_replace_field(
            {
                record        => $record,
                from_field    => '650',
                from_subfield => 'a',
                to_field      => '654',
                to_subfield   => 'a',
                regex => { search => 'O', replace => 'foo', modifiers => 'i' }
            }
        );
        my @fields_654a =
          read_field( { record => $record, field => '654', subfield => 'a' } );
        is_deeply(
            \@fields_654a,
            [ 'Cfoomputer programming.', 'Cfoomputer algorithms.' ],
            'Copy and replace field using regex (same as copy)'
        );

        copy_and_replace_field(
            {
                record        => $record,
                from_field    => '650',
                from_subfield => 'a',
                to_field      => '655',
                to_subfield   => 'a',
                regex => { search => 'O', replace => 'foo', modifiers => 'gi' }
            }
        );
        my @fields_655a =
          read_field( { record => $record, field => '655', subfield => 'a' } );
        is_deeply(
            \@fields_655a,
            [ 'Cfoomputer prfoogramming.', 'Cfoomputer algfoorithms.' ],
            'Copy and replace field using regex (same as copy)'
        );

        $record = new_record;
        $record->append_fields(
            MARC::Field->new(
                952, ' ', ' ',
                p => '3010023917',
                y => 'BK',
            ),
        );

        copy_and_replace_field(
            {
                record        => $record,
                from_field    => '952',
                from_subfield => 'd',
                to_field      => '952',
                to_subfield   => 'd'
            }
        );
        my @fields_952d =
          read_field( { record => $record, field => '952', subfield => 'd' } );
        is_deeply(
            \@fields_952d,
            [ '2001-06-25', '2001-06-25' ],
            'copy and replace 952$d into others 952 field'
        );

        copy_and_replace_field(
            {
                record        => $record,
                from_field    => '111',
                from_subfield => '1',
                to_field      => '999',
                to_subfield   => '9'
            }
        );
        my @fields_9999 =
          read_field( { record => $record, field => '999', subfield => '9' } );
        is_deeply( \@fields_9999, [],
            'copy and replace a nonexistent subfield does not create a new one (same as copy)' );

        $record = new_record;
        copy_and_replace_field(
            {
                record        => $record,
                from_field    => 245,
                from_subfield => 'a',
                to_field      => 245,
                to_subfield   => 'a',
                regex         => { search => '^', replace => 'BEGIN ' }
            }
        );
        # This is the same as update the subfield
        is_deeply(
            [
                read_field(
                    { record => $record, field => '245', subfield => 'a' }
                )
            ],
            ['BEGIN The art of computer programming'],
            'Copy and replace - Update a subfield: add a string at the beginning'
        );

        $record = new_record;
        copy_and_replace_field(
            {
                record        => $record,
                from_field    => 245,
                from_subfield => 'a',
                to_field      => 245,
                to_subfield   => 'a',
                regex         => { search => '$', replace => ' END' }
            }
        );
        # This is the same as update the subfield
        is_deeply(
            [
                read_field(
                    { record => $record, field => '245', subfield => 'a' }
                )
            ],
            ['The art of computer programming END'],
            'Copy and replace - Update a subfield: add a string at the end'
        );

        $record = new_record;
        copy_and_replace_field(
            {
                record        => $record,
                from_field    => 245,
                from_subfield => 'c',
                to_field      => 650,
                to_subfield   => 'c',
            }
        );

        is_deeply(
            [
                read_field(
                    { record => $record, field => '650' }
                )
            ],
            [ 'Computer programming.', '462', 'Donald E. Knuth.' ],
            'Copy and replace a subfield to an existent field but inexistent subfield (same as copy)'
        );

        $record = new_record;
        copy_and_replace_field(
            {
                record        => $record,
                from_field    => 245,
                from_subfield => 'c',
                to_field      => 650,
                to_subfield   => '9',
            }
        );

        is_deeply(
            [
                read_field(
                    { record => $record, field => '650' }
                )
            ],
            [ 'Computer programming.', 'Donald E. Knuth.' ],
            'Copy and replace a subfield to an existent field / subfield, the origin subfield is replaced'
        );
    };

    subtest 'copy and replace field' => sub {
        plan tests => 14;
        my $record = new_record;
        $record->append_fields(
            MARC::Field->new(
                952, ' ', ' ',
                p => '3010023918',
                y => 'CD',
            ),
        );

        #- copy all fields
        copy_and_replace_field(
            { record => $record, from_field => '952', to_field => '953' } );
        my @fields_952 = read_field( { record => $record, field => '952' } );
        is_deeply(
            [
                read_field(
                    { record => $record, field => '952', field_numbers => [1] }
                )
            ],
            [ '3010023917', 'BK', 'GEN', '2001-06-25' ],
            "copy all: original first field still exists (same as copy)"
        );
        is_deeply(
            [
                read_field(
                    { record => $record, field => '952', field_numbers => [2] }
                )
            ],
            [ '3010023918', 'CD' ],
            "copy all: original second field still exists (same as copy)"
        );
        is_deeply(
            [
                read_field(
                    { record => $record, field => '953', field_numbers => [1] }
                )
            ],
            [ '3010023917', 'BK', 'GEN', '2001-06-25' ],
            "copy all: first original fields has been copied (same as copy)"
        );
        is_deeply(
            [
                read_field(
                    { record => $record, field => '953', field_numbers => [2] }
                )
            ],
            [ '3010023918', 'CD' ],
            "copy all: second original fields has been copied (same as copy)"
        );

        #- copy only the first field
        copy_and_replace_field(
            {
                record        => $record,
                from_field    => '953',
                to_field      => '954',
                field_numbers => [1]
            }
        );
        is_deeply(
            [
                read_field(
                    { record => $record, field => '953', field_numbers => [1] }
                )
            ],
            [ '3010023917', 'BK', 'GEN', '2001-06-25' ],
            "copy and replace first: first original fields has been copied (same as copy)"
        );
        is_deeply(
            [
                read_field(
                    { record => $record, field => '953', field_numbers => [2] }
                )
            ],
            [ '3010023918', 'CD' ],
            "copy and replace first: second original fields has been copied (same as copy)"
        );
        is_deeply(
            [ read_field( { record => $record, field => '954' } ) ],
            [ '3010023917', 'BK', 'GEN', '2001-06-25' ],
            "copy and replace first: only first, first 953 has been copied (same as copy)"
        );

        $record = new_record;
        $record->append_fields(
            MARC::Field->new(
                952, ' ', ' ',
                p => '3010023918',
                y => 'CD',
            ),
        );

        #- copy and replace all fields and modify values using a regex
        copy_and_replace_field(
            {
                record     => $record,
                from_field => '952',
                to_field   => '953',
                regex      => { search => '30100', replace => '42424' }
            }
        );
        is_deeply(
            [
                read_field(
                    { record => $record, field => '952', field_numbers => [1] }
                )
            ],
            [ '3010023917', 'BK', 'GEN', '2001-06-25' ],
            "copy and replace all with regex: original first field still exists (same as copy)"
        );
        is_deeply(
            [
                read_field(
                    { record => $record, field => '952', field_numbers => [2] }
                )
            ],
            [ '3010023918', 'CD' ],
            "copy and replace all with regex: original second field still exists (same as copy)"
        );
        is_deeply(
            [
                read_field(
                    { record => $record, field => '953', field_numbers => [1] }
                )
            ],
            [ '4242423917', 'BK', 'GEN', '2001-06-25' ],
            "copy and replace all with regex: first original fields has been copied (same as copy)"
        );
        is_deeply(
            [
                read_field(
                    { record => $record, field => '953', field_numbers => [2] }
                )
            ],
            [ '4242423918', 'CD' ],
            "copy and replace all with regex: second original fields has been copied (same as copy)"
        );
        copy_and_replace_field(
            {
                record     => $record,
                from_field => '111',
                to_field   => '999',
            }
        );
        my @fields_9999 =
          read_field( { record => $record, field => '999', subfield => '9' } );
        is_deeply( \@fields_9999, [],
            'copy and replace a nonexistent field does not create a new one (same as copy)' );

        $record = new_record;
        copy_and_replace_field(
            {
                record        => $record,
                from_field    => 245,
                to_field      => 650,
            }
        );

        is_deeply(
            [
                read_field(
                    { record => $record, field => '650', field_numbers => [1] }
                )
            ],
            [ 'The art of computer programming', 'Donald E. Knuth.' ],
            'Copy and replace to an existent field should erase the original field'
        );
        is_deeply(
            [
                read_field(
                    { record => $record, field => '650', field_numbers => [2] }
                )
            ],
            [],
            'Copy and replace to an existent field should not create a new field'
        );
    };
};

# move_field - subfields
subtest 'move_field' => sub {
    plan tests              => 2;
    subtest 'move subfield' => sub {
        plan tests => 7;
        my $record = new_record;
        my ( @fields_952d, @fields_952c, @fields_954c, @fields_954p );
        $record->append_fields(
            MARC::Field->new(
                952, ' ', ' ',
                p => '3010023917',
                y => 'BK',
            ),
        );
        move_field(
            {
                record        => $record,
                from_field    => '952',
                from_subfield => 'c',
                to_field      => '954',
                to_subfield   => 'c'
            }
        );
        @fields_952c =
          read_field( { record => $record, field => '952', subfield => 'c' } );
        @fields_954c =
          read_field( { record => $record, field => '954', subfield => 'c' } );
        is_deeply( \@fields_952c, [],      'The 952$c has moved' );
        is_deeply( \@fields_954c, ['GEN'], 'Now 954$c exists' );

        move_field(
            {
                record        => $record,
                from_field    => '952',
                from_subfield => 'p',
                to_field      => '954',
                to_subfield   => 'p',
                field_numbers => [1]
            }
        );    # Move the first field
        my @fields_952p =
          read_field( { record => $record, field => '952', subfield => 'p' } );
        @fields_954p =
          read_field( { record => $record, field => '954', subfield => 'p' } );
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

        move_field(
            {
                record        => $record,
                from_field    => '952',
                from_subfield => 'p',
                to_field      => '954',
                to_subfield   => 'p'
            }
        );    # Move all field
        @fields_952p =
          read_field( { record => $record, field => '952', subfield => 'p' } );
        @fields_954p =
          read_field( { record => $record, field => '954', subfield => 'p' } );
        is_deeply( \@fields_952p, [], 'All 952$p have moved' );
        is_deeply(
            \@fields_954p,
            [ '3010023917', '3010023917' ],
            'Now 2 954$p exist'
        );

        move_field(
            {
                record        => $record,
                from_field    => '111',
                from_subfield => '1',
                to_field      => '999',
                to_subfield   => '9'
            }
        );
        my @fields_9999 =
          read_field( { record => $record, field => '999', subfield => '9' } );
        is_deeply( \@fields_9999, [],
            'move a nonexistent subfield does not create a new one' );
    };

    subtest 'move field' => sub {
        plan tests => 9;

        # move_field - fields
        my $record = new_record;
        $record->append_fields(
            MARC::Field->new(
                952, ' ', ' ',
                p => '3010023917',
                y => 'BK',
            ),
        );

        #- Move all fields
        move_field(
            { record => $record, from_field => '952', to_field => '953' } );
        is_deeply( [ read_field( { record => $record, field => '952' } ) ],
            [], "original fields don't exist" );
        is_deeply(
            [
                read_field(
                    { record => $record, field => '953', field_numbers => [1] }
                )
            ],
            [ '3010023917', 'BK', 'GEN', '2001-06-25' ],
            "first original fields has been copied"
        );
        is_deeply(
            [
                read_field(
                    { record => $record, field => '953', field_numbers => [2] }
                )
            ],
            [ '3010023917', 'BK' ],
            "second original fields has been copied"
        );

        #- Move only the first field
        move_field(
            {
                record        => $record,
                from_field    => '953',
                to_field      => '954',
                field_numbers => [1]
            }
        );
        is_deeply(
            [ read_field( { record => $record, field => '953' } ) ],
            [ '3010023917', 'BK' ],
            "only first, the second 953 still exists"
        );
        is_deeply(
            [ read_field( { record => $record, field => '954' } ) ],
            [ '3010023917', 'BK', 'GEN', '2001-06-25' ],
            "only first, first 953 has been copied"
        );

        $record = new_record;
        $record->append_fields(
            MARC::Field->new(
                952, ' ', ' ',
                p => '3010023917',
                y => 'BK',
            ),
        );

        #- Move all fields and modify values using a regex
        move_field(
            {
                record     => $record,
                from_field => '952',
                to_field   => '953',
                regex      => { search => 'BK', replace => 'DVD' }
            }
        );
        is_deeply( [ read_field( { record => $record, field => '952' } ) ],
            [], "use a regex, original fields don't exist" );
        is_deeply(
            [
                read_field(
                    { record => $record, field => '953', field_numbers => [1] }
                )
            ],
            [ '3010023917', 'DVD', 'GEN', '2001-06-25' ],
            "use a regex, first original fields has been copied"
        );
        is_deeply(
            [
                read_field(
                    { record => $record, field => '953', field_numbers => [2] }
                )
            ],
            [ '3010023917', 'DVD' ],
            "use a regex, second original fields has been copied"
        );

        move_field(
            {
                record     => $record,
                from_field => '111',
                to_field   => '999',
            }
        );
        my @fields_9999 =
          read_field( { record => $record, field => '999', subfield => '9' } );
        is_deeply( \@fields_9999, [],
            'move a nonexistent field does not create a new one' );

    };
};

# delete_field
subtest 'delete_field' => sub {
    plan tests                => 2;
    subtest 'delete subfield' => sub {
        plan tests => 2;
        my $record = new_record;
        $record->append_fields(
            MARC::Field->new(
                952, ' ', ' ',
                p => '3010023917',
                y => 'BK',
            ),
        );

        delete_field(
            {
                record        => $record,
                field         => '952',
                subfield      => 'p',
                field_numbers => [1]
            }
        );
        my @fields_952p =
          read_field( { record => $record, field => '952', subfield => 'p' } );
        is_deeply( \@fields_952p, ['3010023917'], 'Delete first 952$p' );

        $record = new_record;
        $record->append_fields(
            MARC::Field->new(
                952, ' ', ' ',
                p => '3010023917',
                y => 'BK',
            ),
        );
        delete_field( { record => $record, field => '952', subfield => 'p' } );
        @fields_952p =
          read_field( { record => $record, field => '952', subfield => 'p' } );
        is_deeply( \@fields_952p, [], 'Delete all 952$p' );
    };

    subtest 'delete field' => sub {
        plan tests => 2;
        my $record = new_record;
        delete_field( { record => $record, field => '952' } );
        my @fields_952 = read_field( { record => $record, field => '952' } );
        is_deeply( \@fields_952, [], 'Delete all 952, 1 deleted' );

        $record = new_record;
        $record->append_fields(
            MARC::Field->new(
                952, ' ', ' ',
                p => '3010023917',
                y => 'BK',
            ),
        );
        delete_field( { record => $record, field => '952' } );
        @fields_952 = read_field( { record => $record, field => '952' } );
        is_deeply( \@fields_952, [], 'Delete all 952, 2 deleted' );
    };
};
