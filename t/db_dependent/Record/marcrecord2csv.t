#!/usr/bin/perl;

use Modern::Perl;
use Test::More tests => 4;
use Test::MockModule;
use MARC::Record;
use MARC::Field;
use Text::CSV::Encoded;

use C4::Biblio qw( AddBiblio );
use C4::Context;
use C4::Record;

my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

my $module_biblio = Test::MockModule->new('C4::Biblio');

my $record = new_record();
my ( $biblionumber, $biblioitemnumber ) = AddBiblio( $record, q|| );
$module_biblio->mock( 'GetMarcBiblio', sub{ $record } );

my $csv_content = q(Title=245$a|Author=245$c|Subject=650$a);
my $csv_profile_id_1 = insert_csv_profile({ csv_content => $csv_content });
my $csv = Text::CSV::Encoded->new();

my $csv_output = C4::Record::marcrecord2csv( $biblionumber, $csv_profile_id_1, 1, $csv );

is( $csv_output, q[Title|Author|Subject
"The art of computer programming,The art of another title"|"Donald E. Knuth.,Donald E. Knuth. II"|"Computer programming.,Computer algorithms."
], q|normal way: display headers and content| );

$csv_output = C4::Record::marcrecord2csv( $biblionumber, $csv_profile_id_1, 0, $csv );
is( $csv_output, q["The art of computer programming,The art of another title"|"Donald E. Knuth.,Donald E. Knuth. II"|"Computer programming.,Computer algorithms."
], q|normal way: don't display headers| );

$csv_content = q(245|650);
my $csv_profile_id_2 = insert_csv_profile({ csv_content => $csv_content });

$csv_output = C4::Record::marcrecord2csv( $biblionumber, $csv_profile_id_2, 1, $csv );
is( $csv_output, q["TITLE STATEMENT"|"SUBJECT ADDED ENTRY--TOPICAL TERM"
"The art of computer programming,Donald E. Knuth.,0;The art of another title,Donald E. Knuth. II,1"|"Computer programming.,462;Computer algorithms.,499"
], q|normal way: headers retrieved from the DB| );

$csv_output = C4::Record::marcrecord2csv( $biblionumber, $csv_profile_id_2, 0, $csv );
is( $csv_output, q["The art of computer programming,Donald E. Knuth.,0;The art of another title,Donald E. Knuth. II,1"|"Computer programming.,462;Computer algorithms.,499"
], q|normal way: headers are not display if not needed| );

sub insert_csv_profile {
    my ( $params ) = @_;
    my $csv_content = $params->{csv_content};
    $dbh->do(q|
        INSERT INTO export_format(profile, description, content, csv_separator, field_separator, subfield_separator, encoding, type) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        |, {}, ("TEST_PROFILE4", "my desc", $csv_content, '|', ';', ',', 'utf8', 'marc')
    );
    return $dbh->last_insert_id( undef, undef, 'export_format', undef );
}

sub new_record {
    my $record = MARC::Record->new;
    $record->leader('03174nam a2200445 a 4500');
    my @fields = (
        MARC::Field->new(
            '008', "140211b xxu||||| |||| 00| 0 eng d"
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
            9 => '0',
        ),
        MARC::Field->new(
            245, '1', '4',
            a => 'The art of another title',
            c => 'Donald E. Knuth. II',
            9 => '1',
        ),
        MARC::Field->new(
            650, ' ', '1',
            a => 'Computer programming.',
            9 => '462',
        ),
        MARC::Field->new(
            650, ' ', '0',
            a => 'Computer algorithms.',
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
