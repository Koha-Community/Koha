#!/usr/bin/perl

# Tests for C4::AuthoritiesMarc::merge

use Modern::Perl;

use Test::More tests => 4;

use MARC::Record;
use Test::MockModule;
use Test::MockObject;

use t::lib::TestBuilder;

use C4::Biblio;
use Koha::Database;

BEGIN {
        use_ok('C4::AuthoritiesMarc');
}

my $schema  = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;
my $builder = t::lib::TestBuilder->new;

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

subtest 'Test merge A1 to modified A1' => sub {
# Tests originate from bug 11700
    plan tests => 4;

    $dbh->do("INSERT IGNORE INTO marc_subfield_structure(tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES('109', 'a', 'Personal name', 'Personal name', 0, 0, '', 6, '', 'TEST_PERSO', '', NULL, 0, '', '', '', NULL)");
    $dbh->do("UPDATE marc_subfield_structure SET authtypecode = 'TEST_PERSO' WHERE tagfield='109' AND tagsubfield='a' AND frameworkcode='';");

    my $auth1old = MARC::Record->new;
    $auth1old->append_fields( MARC::Field->new( '109', '0', '0', 'a' => 'Bruce Wayne' ));
    my $auth1new = $auth1old->clone;
    $auth1new->field('109')->update( a => 'Batman' );
    my $authid1 = AddAuthority( $auth1new, undef, 'TEST_PERSO' );

    my $MARC1 = MARC::Record->new();
    $MARC1->append_fields( MARC::Field->new( '245', '', '', 'a' => 'From the depths' ));
    $MARC1->append_fields( MARC::Field->new( '109', '', '', 'a' => 'Bruce Wayne', 'b' => '2014', '9' => $authid1 ));
    my $MARC2 = MARC::Record->new();
    $MARC2->append_fields( MARC::Field->new( '245', '', '', 'a' => 'All the way to heaven' ));
    $MARC2->append_fields( MARC::Field->new( '109', '', '', 'a' => 'Batman', '9' => $authid1 ));
    my ( $biblionumber1 ) = AddBiblio( $MARC1, '');
    my ( $biblionumber2 ) = AddBiblio( $MARC2, '');

    @zebrarecords = ( $MARC1, $MARC2 );
    $index = 0;

    my $rv = C4::AuthoritiesMarc::merge( $authid1, $auth1old, $authid1, $auth1new );
    is( $rv, 2, 'Both records are updated now' );

    my $biblio1 = GetMarcBiblio($biblionumber1);
    my $biblio2 = GetMarcBiblio($biblionumber1);

    my $auth_field = $auth1new->field(109)->subfield('a');
    is( $auth_field, $biblio1->field(109)->subfield('a'), 'Record1 values updated correctly' );
    is( $auth_field, $biblio2->field(109)->subfield('a'), 'Record2 values updated correctly' );

    # TODO Following test will change when we improve merge
    # Will depend on a preference
    is( $biblio1->field(109)->subfield('b'), $MARC1->field(109)->subfield('b'), 'Record not overwritten while merging');
};

subtest 'Test merge A1 to B1 (changing authtype)' => sub {
# Tests were aimed for bug 9988, moved to 17909 in adjusted form
# Would not encourage this type of merge, but we should test what we offer
# The merge routine still needs the fixes on bug 17913
    plan tests => 8;

    # create another authtype
    my $authtype2 = $builder->build({
        source => 'AuthType',
        value  => {
            auth_tag_to_report => '112',
        },
    });
    # create two fields linked to this auth type
    $schema->resultset('MarcSubfieldStructure')->search({ tagfield => [ '112', '712' ] })->delete;
    $builder->build({
        source => 'MarcSubfieldStructure',
        value  => {
            tagfield => '112',
            tagsubfield => 'a',
            authtypecode => $authtype2->{authtypecode},
            frameworkcode => '',
        },
    });
    $builder->build({
        source => 'MarcSubfieldStructure',
        value  => {
            tagfield => '712',
            tagsubfield => 'a',
            authtypecode => $authtype2->{authtypecode},
            frameworkcode => '',
        },
    });

    # create auth1 (from the earlier type)
    my $auth1 = MARC::Record->new;
    $auth1->append_fields( MARC::Field->new( '109', '0', '0', 'a' => 'George Orwell', b => 'bb' ));
    my $authid1 = AddAuthority($auth1, undef, 'TEST_PERSO');
    # create auth2 (new type)
    my $auth2 = MARC::Record->new;
    $auth2->append_fields( MARC::Field->new( '112', '0', '0', 'a' => 'Batman', c => 'cc' ));
    my $authid2 = AddAuthority($auth1, undef, $authtype2->{authtypecode} );

    # create a biblio with one 109 and two 609s to be touched
    # seems exceptional see bug 13760 comment10
    my $marc = MARC::Record->new;
    $marc->append_fields(
        MARC::Field->new( '003', 'some_003' ),
        MARC::Field->new( '109', '', '', a => 'G. Orwell', b => 'bb', d => 'd', 9 => $authid1 ),
        MARC::Field->new( '245', '', '', a => 'My title' ),
        MARC::Field->new( '609', '', '', a => 'Orwell', 9 => "$authid1" ),
        MARC::Field->new( '609', '', '', a => 'Orwell', x => 'xx', 9 => "$authid1" ),
        MARC::Field->new( '611', '', '', a => 'Added for testing order' ),
        MARC::Field->new( '612', '', '', a => 'unrelated', 9 => 'other' ),
    );
    my ( $biblionumber ) = C4::Biblio::AddBiblio( $marc, '' );
    my $oldbiblio = C4::Biblio::GetMarcBiblio( $biblionumber );

    @zebrarecords = ( $marc );
    $index = 0;
    my $retval = C4::AuthoritiesMarc::merge( $authid1, $auth1, $authid2, $auth2 );
    is( $retval, 1, 'We touched only one biblio' );

    # Get new marc record for compares
    my $newbiblio = C4::Biblio::GetMarcBiblio( $biblionumber );
    compare_field_count( $oldbiblio, $newbiblio, 1 );
    # TODO The following test will still fail; refined after 17913
    compare_field_order( $oldbiblio, $newbiblio, 0 );

    # Check some fields
    is( $newbiblio->field('003')->data,
        $oldbiblio->field('003')->data,
        'Check contents of a control field not expected to be touched' );
    is( $newbiblio->subfield( '245', 'a' ),
        $oldbiblio->subfield( '245', 'a' ),
        'Check contents of a data field not expected to be touched' );
    is( $newbiblio->subfield( '112', 'a' ),
        $auth2->subfield( '112', 'a' ), 'Check modified 112a' );
    is( $newbiblio->subfield( '112', 'c' ),
        $auth2->subfield( '112', 'c' ), 'Check new 112c' );

    #TODO Check the new 612s (after fix on 17913, they are 112s now)
    is( $newbiblio->subfield( '612', 'a' ),
        $oldbiblio->subfield( '612', 'a' ), 'Check untouched 612a' );
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

sub compare_field_count {
    my ( $oldmarc, $newmarc, $pass ) = @_;
    my $t;
    if( $pass ) {
        is( scalar $newmarc->fields, $t = $oldmarc->fields, "Number of fields still equal to $t" );
    } else {
        isnt( scalar $newmarc->fields, $t = $oldmarc->fields, "Number of fields not equal to $t" );
    }
}

sub compare_field_order {
    my ( $oldmarc, $newmarc, $pass ) = @_;
    if( $pass ) {
        is( ( join q/,/, map { $_->tag; } $newmarc->fields ),
            ( join q/,/, map { $_->tag; } $oldmarc->fields ),
            'Order of fields unchanged' );
    } else {
        isnt( ( join q/,/, map { $_->tag; } $newmarc->fields ),
            ( join q/,/, map { $_->tag; } $oldmarc->fields ),
            'Order of fields changed' );
    }
}

$schema->storage->txn_rollback;
