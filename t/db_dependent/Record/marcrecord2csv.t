#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 13;
use Test::MockModule;
use MARC::Record;
use MARC::Field;
use Text::CSV::Encoded;

use C4::Biblio qw( AddBiblio );
use C4::Context;
use C4::Record qw( marcrecord2csv );
use Koha::Database;
use Koha::Biblios;

use C4::Items qw( AddItemFromMarc );

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;

my $builder = t::lib::TestBuilder->new;
my $module_biblio = Test::MockModule->new('C4::Biblio');

my $record = new_record();
my $frameworkcode = q||;
my ( $biblionumber, $biblioitemnumber ) = AddBiblio( $record, $frameworkcode );

my $csv_content = q(Title=245$a|Author=245$c|Subject=650$a);
my $csv_profile_id_1 = insert_csv_profile({ csv_content => $csv_content });
my $csv = Text::CSV::Encoded->new();

# Test bad biblionumber case
my $csv_output = C4::Record::marcrecord2csv( -1, $csv_profile_id_1, 1, $csv );
ok(! defined $csv_output, 'Bad biblionumber gives undef as expected.');

$csv_output = C4::Record::marcrecord2csv( $biblionumber, $csv_profile_id_1, 1, $csv );

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

$csv_content = q(Title and author=[% FOREACH field IN fields.245 %][% field.a.0 %] [% field.c.0 %][% END %]|Subject=650$a);
my $csv_profile_id_3 = insert_csv_profile({ csv_content => $csv_content });

$csv_output = C4::Record::marcrecord2csv( $biblionumber, $csv_profile_id_3, 1, $csv );
is( $csv_output, q["Title and author"|Subject
"The art of computer programming Donald E. Knuth.The art of another title Donald E. Knuth. II"|"Computer programming.,Computer algorithms."
], q|TT way: display all 245$a and 245$c| );

$csv_content = q(Subject=[% FOREACH field IN fields.650 %][% IF field.indicator.2 %][% field.a.0 %][% END %][% END %]);
my $csv_profile_id_4 = insert_csv_profile({ csv_content => $csv_content });

$csv_output = C4::Record::marcrecord2csv( $biblionumber, $csv_profile_id_4, 1, $csv );
is( $csv_output, q[Subject
"Computer programming."
], q|TT way: display 650$a if indicator 2 for 650 is set| );

$csv_content = q|Language=[% fields.008.0.substr( 28, 3 ) %]|;
my $csv_profile_id_5 = insert_csv_profile({ csv_content => $csv_content });

$csv_output = C4::Record::marcrecord2csv( $biblionumber, $csv_profile_id_5, 1, $csv );
is( $csv_output, q[Language
eng
], q|TT way: export language from the control field 008| );

$csv_content = q|Title=[% IF fields.100.0.indicator.1 %][% fields.245.0.a.0 %][% END %]|;
my $csv_profile_id_6 = insert_csv_profile({ csv_content => $csv_content });

$csv_output = C4::Record::marcrecord2csv( $biblionumber, $csv_profile_id_6, 1, $csv );
is( $csv_output, q[Title
"The art of computer programming"
], q|TT way: display first subfield a for first field 245 if indicator 1 for field 100 is set| );

$csv_content = q|Title=[% IF fields.100.0.indicator.1 == 1 %][% fields.245.0.a.0 %][% END %]|;
my $csv_profile_id_7 = insert_csv_profile({ csv_content => $csv_content });

$csv_output = C4::Record::marcrecord2csv( $biblionumber, $csv_profile_id_7, 1, $csv );
is( $csv_output, q[Title
"The art of computer programming"
], q|TT way: display first subfield a for first field 245 if indicator 1 == 1 for field 100 is set| );


my $authorised_value_1 =
  $builder->build( { source => 'AuthorisedValue', value => { category => 'MY_AV_1', authorised_value => 1, lib => 'This is an AV', lib_opac => 'This is an AV (opac)' } } );
my $authorised_value_2 = $builder->build(
    { source => 'AuthorisedValue', value => { category => 'MY_AV_2', authorised_value => 2, lib => 'This is another AV', lib_opac => 'This is another AV (opac)' } } );
$dbh->do(q|DELETE FROM marc_subfield_structure WHERE tagfield='998' and ( tagsubfield='8' or tagsubfield='9')|);
$builder->build(
    { source => 'MarcSubfieldStructure', value => { authorised_value => $authorised_value_1->{category}, tagfield => 998, tagsubfield => '8', frameworkcode => $frameworkcode } }
);
$builder->build(
    { source => 'MarcSubfieldStructure', value => { authorised_value => $authorised_value_2->{category}, tagfield => 998, tagsubfield => '9', frameworkcode => $frameworkcode } }
);
$csv_content = q(Title=245$a|AV1=998$8|AV2=998$9);
my $csv_profile_id_8 = insert_csv_profile( { csv_content => $csv_content } );
$csv_output = C4::Record::marcrecord2csv( $biblionumber, $csv_profile_id_8, 1, $csv );
is( $csv_output, q[Title|AV1|AV2
"The art of computer programming,The art of another title"|"This is an AV"|"This is another AV"
], q|TT way: display first subfield a for first field 245 if indicator 1 == 1 for field 100 is set|
);

$csv_content = q(Title=245$a|AVs=998);
my $csv_profile_id_9 = insert_csv_profile( { csv_content => $csv_content } );
$csv_output = C4::Record::marcrecord2csv( $biblionumber, $csv_profile_id_9, 1, $csv );
is( $csv_output, q[Title|AVs
"The art of computer programming,The art of another title"|"This is an AV,This is another AV"
], q|TT way: display first subfield a for first field 245 if indicator 1 == 1 for field 100 is set|
);

subtest 'Test for subfields 0' => sub {
    plan tests => 1;

    my $record2        = new_record();
    my $frameworkcode2 = q||;

    # We change the barcode of the second item record to prevent an error "duplicate entry"
    my $field     = $record->field('952');
    my $new_field = MARC::Field->new(
        '952', ' ', ' ',
        0 => '1',
        p => '3010023918',
    );
    $field->replace_with($new_field);

    # We create another record
    my ( $biblionumber2, $biblioitemnumber2 ) = AddBiblio( $record2, $frameworkcode2 );

    # We add two item to two record to test fieldtag 952 and subfieldtag 9520
    my ( undef, undef, $itemnumber2 ) = AddItemFromMarc( $record2, $biblionumber );
    my ( undef, undef, $itemnumber ) = AddItemFromMarc( $record, $biblionumber );
    $csv_content = q(Titre=245a|Nom de personne=100a|Statut « Élagué »=9520);
    my $csv_profile_id_10 = insert_csv_profile( { csv_content => $csv_content } );
    $csv_output = C4::Record::marcrecord2csv( $biblionumber, $csv_profile_id_10, 1, $csv );
    is_deeply(
        [ split "\n", $csv_output ],
        [
            q[Titre|"Nom de personne"|"Statut « Élagué »"],
            q["The art of computer programming,The art of another title"|"Knuth, Donald Ervin"|Withdrawn;Withdrawn],
        ],
        q[subfieldtag 952\$0 is not working, should return 'Withdrawn']
    );
};

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
            0 => '1',
            p => '3010023917',
            y => 'BK',
            c => 'GEN',
            d => '2001-06-25',
        ),
        MARC::Field->new(
            998, ' ', ' ',
            8 => 1,
            9 => 2,
        ),
    );
    $record->append_fields(@fields);
    return $record;
}
