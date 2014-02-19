#!/usr/bin/perl

# Tests for C4::AuthoritiesMarc::merge

use Modern::Perl;

use Test::More tests => 2;

use MARC::Record;
use Test::MockModule;
use Test::MockObject;

use C4::Biblio;
use Koha::Database;

BEGIN {
        use_ok('C4::AuthoritiesMarc');
}

my $schema  = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;

# Some advanced mocking :)
my ( @zebrarecords, $index );
my $auth_mod = Test::MockModule->new( 'C4::AuthoritiesMarc' );
my $context_mod = Test::MockModule->new( 'C4::Context' );
my $search_mod = Test::MockModule->new( 'C4::Search' );
my $zoom_mod = Test::MockModule->new( 'ZOOM::Query::CCL2RPN', no_auto => 1 );
my $conn_obj = Test::MockObject->new;
my $zoom_obj = Test::MockObject->new;
my $zoom_record_obj = Test::MockObject->new;
set_mocks();

subtest 'Test merge A1 to A2 (withing same authtype)' => sub {
# Tests originate from bug 11700
    plan tests => 5;

    # Create authority type TEST_PERSO
    $dbh->do("INSERT INTO auth_types(authtypecode, authtypetext, auth_tag_to_report, summary) VALUES('TEST_PERSO', 'Personal Name', '109', 'Personal Names');");
    $dbh->do("INSERT INTO auth_tag_structure (authtypecode, tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value) VALUES('TEST_PERSO', '109', 'HEADING--PERSONAL NAME', 'HEADING--PERSONAL NAME', 0, 0, NULL)");
    $dbh->do("INSERT INTO auth_subfield_structure (authtypecode, tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, tab, authorised_value, value_builder, seealso, isurl, hidden, linkid, kohafield, frameworkcode) VALUES ('TEST_PERSO', '109', 'a', 'Personal name', 'Personal name', 0, 0, 1, NULL, NULL, '', 0, 0, '', '', '')");

    my $auth1 = new MARC::Record;
    $auth1->append_fields(new MARC::Field('109', '0', '0', 'a' => 'George Orwell'));
    my $authid1 = AddAuthority($auth1, undef, 'TEST_PERSO');
    my $auth2 = new MARC::Record;
    $auth2->append_fields(new MARC::Field('109', '0', '0', 'a' => 'G. Orwell'));
    my $authid2 = AddAuthority($auth2, undef, 'TEST_PERSO');

    $dbh->do("INSERT IGNORE INTO marc_subfield_structure(tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES('609', 'a', 'Personal name', 'Personal name', 0, 0, '', 6, '', 'TEST_PERSO', '', NULL, 0, '', '', '', NULL)");
    $dbh->do("UPDATE marc_subfield_structure SET authtypecode = 'TEST_PERSO' WHERE tagfield='609' AND tagsubfield='a' AND frameworkcode='';");
    my $tagfields = $dbh->selectcol_arrayref("select distinct tagfield from marc_subfield_structure where authtypecode='TEST_PERSO'");
    my $biblio1 = new MARC::Record;
    $biblio1->append_fields(
        new MARC::Field('609', '0', '0', '9' => $authid1, 'a' => 'George Orwell')
    );
    my ( $biblionumber1 ) = AddBiblio($biblio1, '');
    my $biblio2 = new MARC::Record;
    $biblio2->append_fields(
        new MARC::Field('609', '0', '0', '9' => $authid2, 'a' => 'G. Orwell')
    );
    my ( $biblionumber2 ) = AddBiblio($biblio2, '');

    @zebrarecords = ( $biblio1, $biblio2 );
    $index = 0;
    my $rv = C4::AuthoritiesMarc::merge( $authid2, $auth2, $authid1, $auth1 );
    is( $rv, 1, 'We expect one biblio record (out of two) to be updated' );

    $biblio1 = GetMarcBiblio($biblionumber1);
    is($biblio1->subfield('609', '9'), $authid1, 'Check biblio1 609$9' );
    is($biblio1->subfield('609', 'a'), 'George Orwell',
        'Check biblio1 609$a' );
    $biblio2 = GetMarcBiblio($biblionumber2);
    is($biblio2->subfield('609', '9'), $authid1, 'Check biblio2 609$9' );
    is($biblio2->subfield('609', 'a'), 'George Orwell',
        'Check biblio2 609$a' );
};

sub set_mocks {
    # Mock ZOOM objects: They do nothing actually
    # Get new_record_from_zebra to return the records

    $context_mod->mock( 'Zconn', sub { $conn_obj; } );
    $search_mod->mock( 'new_record_from_zebra', sub {
         return if $index >= @zebrarecords;
         return $zebrarecords[ $index++ ];
    });
    $zoom_mod->mock( 'new', sub {} );

    $conn_obj->mock( 'search', sub { $zoom_obj; } );
    $zoom_obj->mock( 'destroy', sub {} );
    $zoom_obj->mock( 'record', sub { $zoom_record_obj; } );
    $zoom_obj->mock( 'search', sub {} );
    $zoom_obj->mock( 'size', sub { @zebrarecords } );
    $zoom_record_obj->mock( 'raw', sub {} );
}

$schema->storage->txn_rollback;
