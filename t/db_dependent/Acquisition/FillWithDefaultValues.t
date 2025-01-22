use Modern::Perl;
use Test::NoWarnings;
use Test::More tests => 13;
use Test::MockModule;

use MARC::Record;
use MARC::Field;

use C4::Context;
use C4::Acquisition qw( FillWithDefaultValues );
use Koha::Database;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $biblio_module  = Test::MockModule->new('C4::Biblio');
my $default_author = 'default author';
my $default_x      = 'my default value';
$biblio_module->mock(
    'GetMarcStructure',
    sub {
        {
            # default for a control field
            '008' => {
                x => { defaultvalue => $default_x },
            },

            # default value for an existing field
            '245' => {
                c          => { defaultvalue => $default_author, mandatory => 1 },
                mandatory  => 0,
                repeatable => 0,
                tab        => 0,
                lib        => 'a lib',
            },

            # default for a nonexisting field
            '099' => {
                x => { defaultvalue => $default_x },
            },
            '942' => {
                c => { defaultvalue => 'BK', mandatory => 1 },
                d => { defaultvalue => '942d_val' },
                f => { defaultvalue => '942f_val' },
            },
        };
    }
);

my $record = MARC::Record->new;
$record->leader('03174nam a2200445 a 4500');
my @fields = (
    MARC::Field->new(
        '008', '1', ' ',
        '@' => '120829t20132012nyu bk 001 0ceng',
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
        245, '1', '4', a => 'my second title',
    ),
);

$record->append_fields(@fields);

C4::Acquisition::FillWithDefaultValues($record);

my @fields_245 = $record->field(245);
is( scalar(@fields_245), 2, 'No new 245 field has been created' );
my @subfields_245_0 = $fields_245[0]->subfields;
my @subfields_245_1 = $fields_245[1]->subfields;
is_deeply(
    \@subfields_245_0,
    [ [ 'a', 'The art of computer programming' ], [ 'c', 'Donald E. Knuth.' ] ],
    'first 245 field has not been updated'
);
is_deeply(
    \@subfields_245_1,
    [ [ 'a', 'my second title' ], [ 'c', $default_author ] ],
    'second 245 field has a new subfield c with a default value'
);

my @fields_099 = $record->field('099');
is( scalar(@fields_099), 1, '1 new 099 field has been created' );
my @subfields_099 = $fields_099[0]->subfields;
is_deeply(
    \@subfields_099,
    [ [ 'x', $default_x ] ],
    '099$x contains the default value'
);

# Test controlfield default
$record->field('008')->update(undef);
C4::Acquisition::FillWithDefaultValues($record);
is( $record->field('008')->data, $default_x, 'Controlfield got default' );

is( $record->subfield( '942', 'd' ), '942d_val', 'Check 942d' );

# Now test only_mandatory parameter
$record->delete_fields( $record->field('245') );
$record->delete_fields( $record->field('942') );
$record->append_fields( MARC::Field->new( '942', '', '', 'f' => 'f val' ) );

# We deleted 245 and replaced 942. If we only apply mandatories, we should get
# back 245c again and 942c but not 942d. 942f should be left alone.
C4::Acquisition::FillWithDefaultValues( $record, { only_mandatory => 1 } );
@fields_245 = $record->field(245);
is( scalar @fields_245, 1, 'Only one 245 expected' );
is( $record->subfield( '245', 'c' ), $default_author, '245c restored' );
is( $record->subfield( '942', 'c' ), 'BK',            '942c also restored' );
is( $record->subfield( '942', 'd' ), undef,           '942d should not be there' );
is( $record->subfield( '942', 'f' ), 'f val',         '942f untouched' );

$schema->storage->txn_rollback;
