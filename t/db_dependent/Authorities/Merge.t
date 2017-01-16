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

# Framework operations
my ( $authtype1, $authtype2 ) = modify_framework();

subtest 'Test merge A1 to A2 (withing same authtype)' => sub {
# Tests originate from bug 11700
    plan tests => 9;

    # Add two authority records
    my $auth1 = MARC::Record->new;
    $auth1->append_fields( MARC::Field->new( '109', '0', '0', 'a' => 'George Orwell' ));
    my $authid1 = AddAuthority( $auth1, undef, $authtype1 );
    my $auth2 = MARC::Record->new;
    $auth2->append_fields( MARC::Field->new( '109', '0', '0', 'a' => 'G. Orwell' ));
    my $authid2 = AddAuthority( $auth2, undef, $authtype1 );

    # Add two biblio records
    my $biblio1 = MARC::Record->new;
    $biblio1->append_fields( MARC::Field->new( '609', '0', '0', '9' => $authid1, 'a' => 'George Orwell' ));
    my ( $biblionumber1 ) = AddBiblio($biblio1, '');
    my $biblio2 = MARC::Record->new;
    $biblio2->append_fields( MARC::Field->new( '609', '0', '0', '9' => $authid2, 'a' => 'G. Orwell' ));
    my ( $biblionumber2 ) = AddBiblio($biblio2, '');

    # Time to merge
    @zebrarecords = ( $biblio1, $biblio2 );
    $index = 0;
    my $rv = C4::AuthoritiesMarc::merge( $authid2, $auth2, $authid1, $auth1 );
    is( $rv, 1, 'We expect one biblio record (out of two) to be updated' );

    # Check the results
    my $newbiblio1 = GetMarcBiblio($biblionumber1);
    compare_field_count( $biblio1, $newbiblio1, 1 );
    compare_field_order( $biblio1, $newbiblio1, 1 );
    is( $newbiblio1->subfield('609', '9'), $authid1, 'Check biblio1 609$9' );
    is( $newbiblio1->subfield('609', 'a'), 'George Orwell',
        'Check biblio1 609$a' );
    my $newbiblio2 = GetMarcBiblio($biblionumber2);
    compare_field_count( $biblio2, $newbiblio2, 1 );
    compare_field_order( $biblio2, $newbiblio2, 1 );
    is( $newbiblio2->subfield('609', '9'), $authid1, 'Check biblio2 609$9' );
    is( $newbiblio2->subfield('609', 'a'), 'George Orwell',
        'Check biblio2 609$a' );
};

subtest 'Test merge A1 to modified A1' => sub {
# Tests originate from bug 11700
    plan tests => 8;

    # Simulate modifying an authority from auth1old to auth1new
    my $auth1old = MARC::Record->new;
    $auth1old->append_fields( MARC::Field->new( '109', '0', '0', 'a' => 'Bruce Wayne' ));
    my $auth1new = $auth1old->clone;
    $auth1new->field('109')->update( a => 'Batman' );
    my $authid1 = AddAuthority( $auth1new, undef, $authtype1 );

    # Add two biblio records
    my $MARC1 = MARC::Record->new;
    $MARC1->append_fields( MARC::Field->new( '109', '', '', 'a' => 'Bruce Wayne', 'b' => '2014', '9' => $authid1 ));
    $MARC1->append_fields( MARC::Field->new( '245', '', '', 'a' => 'From the depths' ));
    my $MARC2 = MARC::Record->new;
    $MARC2->append_fields( MARC::Field->new( '109', '', '', 'a' => 'Batman', '9' => $authid1 ));
    $MARC2->append_fields( MARC::Field->new( '245', '', '', 'a' => 'All the way to heaven' ));
    my ( $biblionumber1 ) = AddBiblio( $MARC1, '');
    my ( $biblionumber2 ) = AddBiblio( $MARC2, '');

    # Time to merge
    @zebrarecords = ( $MARC1, $MARC2 );
    $index = 0;
    my $rv = C4::AuthoritiesMarc::merge( $authid1, $auth1old, $authid1, $auth1new );
    is( $rv, 2, 'Both records are updated now' );

    #Check the results
    my $biblio1 = GetMarcBiblio($biblionumber1);
    compare_field_count( $MARC1, $biblio1, 1 );
    compare_field_order( $MARC1, $biblio1, 1 );
    is( $auth1new->field(109)->subfield('a'), $biblio1->field(109)->subfield('a'), 'Record1 values updated correctly' );
    my $biblio2 = GetMarcBiblio($biblionumber1);
    compare_field_count( $MARC2, $biblio2, 1 );
    compare_field_order( $MARC2, $biblio2, 1 );
    is( $auth1new->field(109)->subfield('a'), $biblio2->field(109)->subfield('a'), 'Record2 values updated correctly' );

    # TODO Following test will change when we improve merge
    # Will depend on a preference
    is( $biblio1->field(109)->subfield('b'), $MARC1->field(109)->subfield('b'), 'Record not overwritten while merging');
};

subtest 'Test merge A1 to B1 (changing authtype)' => sub {
# Tests were aimed for bug 9988, moved to 17909 in adjusted form
# Would not encourage this type of merge, but we should test what we offer
# The merge routine still needs the fixes on bug 17913
    plan tests => 8;

    # create two auth recs of different type
    my $auth1 = MARC::Record->new;
    $auth1->append_fields( MARC::Field->new( '109', '0', '0', 'a' => 'George Orwell', b => 'bb' ));
    my $authid1 = AddAuthority( $auth1, undef, $authtype1 );
    my $auth2 = MARC::Record->new;
    $auth2->append_fields( MARC::Field->new( '112', '0', '0', 'a' => 'Batman', c => 'cc' ));
    my $authid2 = AddAuthority($auth1, undef, $authtype2 );

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

    # Time to merge
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

sub modify_framework {
    # create two auth types
    my $authtype1 = $builder->build({
        source => 'AuthType',
        value  => {
            auth_tag_to_report => '109',
        },
    });
    my $authtype2 = $builder->build({
        source => 'AuthType',
        value  => {
            auth_tag_to_report => '112',
        },
    });

    # Link 109/609 to the first authtype
    $builder->build({
        source => 'MarcSubfieldStructure',
        value  => {
            tagfield => '109',
            tagsubfield => 'a',
            authtypecode => $authtype1->{authtypecode},
            frameworkcode => '',
        },
    });
    $builder->build({
        source => 'MarcSubfieldStructure',
        value  => {
            tagfield => '609',
            tagsubfield => 'a',
            authtypecode => $authtype1->{authtypecode},
            frameworkcode => '',
        },
    });

    # Link 112/712 to the second authtype
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

    return ( $authtype1->{authtypecode}, $authtype2->{authtypecode} );
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
