use Modern::Perl;
use Test::More tests => 5;
use Test::MockModule;

use MARC::Record;
use MARC::Field;

use C4::Context;
use C4::Acquisition qw( FillWithDefaultValues );

my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

my $biblio_module  = Test::MockModule->new('C4::Biblio');
my $default_author = 'default author';
my $default_x      = 'my default value';
$biblio_module->mock(
    'GetMarcStructure',
    sub {
        {
            # default value for an existing field
            '245' => {
                c          => { defaultvalue => $default_author },
                mandatory  => 0,
                repeatable => 0,
                tab        => 0,
                lib        => 'a lib',
              },

            # default for a nonexisting field
            '099' => {
                x => { defaultvalue => $default_x },
            },
        };
    }
);

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
