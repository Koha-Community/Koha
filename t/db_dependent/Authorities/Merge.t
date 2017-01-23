#!/usr/bin/perl

# Tests for C4::AuthoritiesMarc::merge

use Modern::Perl;

use Test::More tests => 4;

use Getopt::Long;
use MARC::Record;
use Test::MockModule;
use Test::MockObject;

use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Biblio;
use Koha::Database;

BEGIN {
        use_ok('C4::AuthoritiesMarc');
}

# Optionally change marc flavour
my $marcflavour;
GetOptions( 'flavour:s' => \$marcflavour );
t::lib::Mocks::mock_preference( 'marcflavour', $marcflavour ) if $marcflavour;

my $schema  = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;

# Some advanced mocking :)
my ( @zebrarecords, $index );
my $context_mod = Test::MockModule->new( 'C4::Context' );
my $search_mod = Test::MockModule->new( 'C4::Search' );
my $zoom_mod = Test::MockModule->new( 'ZOOM::Query::CCL2RPN', no_auto => 1 );
my $conn_obj = Test::MockObject->new;
my $zoom_obj = Test::MockObject->new;
my $zoom_record_obj = Test::MockObject->new;
set_mocks();

# Framework operations
my ( $authtype1, $authtype2 ) = modify_framework();

subtest 'Test merge A1 to A2 (within same authtype)' => sub {
# Tests originate from bug 11700
    plan tests => 9;

    # Start in loose mode, although it actually does not matter here
    t::lib::Mocks::mock_preference('AuthorityMergeMode', 'loose');

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
    compare_fields( $biblio1, $newbiblio1, {}, 'count' );
    compare_fields( $biblio1, $newbiblio1, {}, 'order' );
    is( $newbiblio1->subfield('609', '9'), $authid1, 'Check biblio1 609$9' );
    is( $newbiblio1->subfield('609', 'a'), 'George Orwell',
        'Check biblio1 609$a' );
    my $newbiblio2 = GetMarcBiblio($biblionumber2);
    compare_fields( $biblio2, $newbiblio2, {}, 'count' );
    compare_fields( $biblio2, $newbiblio2, {}, 'order' );
    is( $newbiblio2->subfield('609', '9'), $authid1, 'Check biblio2 609$9' );
    is( $newbiblio2->subfield('609', 'a'), 'George Orwell',
        'Check biblio2 609$a' );
};

subtest 'Test merge A1 to modified A1, test strict mode' => sub {
# Tests originate from bug 11700
    plan tests => 12;

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
    $MARC1->append_fields( MARC::Field->new( '609', '', '', 'a' => 'Bruce Lee', 'b' => 'Should be cleared too', '9' => $authid1 ));
    $MARC1->append_fields( MARC::Field->new( '609', '', '', 'a' => 'Bruce Lee', 'c' => 'This is a duplicate to be removed in strict mode', '9' => $authid1 ));
    my $MARC2 = MARC::Record->new;
    $MARC2->append_fields( MARC::Field->new( '109', '', '', 'a' => 'Batman', '9' => $authid1 ));
    $MARC2->append_fields( MARC::Field->new( '245', '', '', 'a' => 'All the way to heaven' ));
    my ( $biblionumber1 ) = AddBiblio( $MARC1, '');
    my ( $biblionumber2 ) = AddBiblio( $MARC2, '');

    # Time to merge in loose mode first
    @zebrarecords = ( $MARC1, $MARC2 );
    $index = 0;
    t::lib::Mocks::mock_preference('AuthorityMergeMode', 'loose');
    my $rv = C4::AuthoritiesMarc::merge( $authid1, $auth1old, $authid1, $auth1new );
    is( $rv, 2, 'Both records are updated now' );

    #Check the results
    my $biblio1 = GetMarcBiblio($biblionumber1);
    compare_fields( $MARC1, $biblio1, {}, 'count' );
    compare_fields( $MARC1, $biblio1, {}, 'order' );
    is( $auth1new->field(109)->subfield('a'), $biblio1->field(109)->subfield('a'), 'Record1 values updated correctly' );
    my $biblio2 = GetMarcBiblio( $biblionumber2 );
    compare_fields( $MARC2, $biblio2, {}, 'count' );
    compare_fields( $MARC2, $biblio2, {}, 'order' );
    is( $auth1new->field(109)->subfield('a'), $biblio2->field(109)->subfield('a'), 'Record2 values updated correctly' );
    # This is only true in loose mode:
    is( $biblio1->field(109)->subfield('b'), $MARC1->field(109)->subfield('b'), 'Subfield not overwritten in loose mode');

    # Merge again in strict mode
    t::lib::Mocks::mock_preference('AuthorityMergeMode', 'strict');
    ModBiblio( $MARC1, $biblionumber1, '' );
    @zebrarecords = ( $MARC1 );
    $index = 0;
    $rv = C4::AuthoritiesMarc::merge( $authid1, $auth1old, $authid1, $auth1new );
    $biblio1 = GetMarcBiblio($biblionumber1);
    is( $biblio1->field(109)->subfield('b'), undef, 'Subfield overwritten in strict mode' );
    compare_fields( $MARC1, $biblio1, { 609 => 1 }, 'count' );
    my @old609 = $MARC1->field('609');
    my @new609 = $biblio1->field('609');
    is( scalar @new609, @old609 - 1, 'strict mode should remove a duplicate 609' );
    is( $biblio1->field(609)->subfields,
        scalar($auth1new->field('109')->subfields) + 1,
        'Check number of subfields in strict mode for the remaining 609' );
        # Note: the +1 comes from the added subfield $9 in the biblio
};

subtest 'Test merge A1 to B1 (changing authtype)' => sub {
# Tests were aimed for bug 9988, moved to 17909 in adjusted form
# Would not encourage this type of merge, but we should test what we offer
    plan tests => 13;

    # Get back to loose mode now
    t::lib::Mocks::mock_preference('AuthorityMergeMode', 'loose');

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
    compare_fields( $oldbiblio, $newbiblio, {}, 'count' );
    # Exclude 109/609 and 112/612 in comparing order
    my $excl = { '109' => 1, '112' => 1, '609' => 1, '612' => 1 };
    compare_fields( $oldbiblio, $newbiblio, $excl, 'order' );
    # Check position of 612s in the new record
    my $full_order = join q/,/, map { $_->tag } $newbiblio->fields;
    is( $full_order =~ /611(,612){3}/, 1, 'Check position of all 612s' );

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

    # Check 112b; this subfield was cleared when moving from 109 to 112
    # Note that this fix only applies to the current loose mode only
    is( $newbiblio->subfield( '112', 'b' ), undef,
        'Merge respects a cleared subfield in loose mode' );

    # Check the original 612
    is( ( $newbiblio->field('612') )[0]->subfield( 'a' ),
        $oldbiblio->subfield( '612', 'a' ), 'Check untouched 612a' );
    # Check second 612
    is( ( $newbiblio->field('612') )[1]->subfield( 'a' ),
        $auth2->subfield( '112', 'a' ), 'Check second touched 612a' );
    # Check second new 612ax (in LOOSE mode)
    is( ( $newbiblio->field('612') )[2]->subfield( 'a' ),
        $auth2->subfield( '112', 'a' ), 'Check touched 612a' );
    is( ( $newbiblio->field('612') )[2]->subfield( 'x' ),
        ( $oldbiblio->field('609') )[1]->subfield('x'),
        'Check 612x' );
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
    my $builder = t::lib::TestBuilder->new;

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

    # Link 112/612 to the second authtype
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
            tagfield => '612',
            tagsubfield => 'a',
            authtypecode => $authtype2->{authtypecode},
            frameworkcode => '',
        },
    });

    return ( $authtype1->{authtypecode}, $authtype2->{authtypecode} );
}

sub compare_fields { # mode parameter: order or count
    my ( $oldmarc, $newmarc, $exclude, $mode ) = @_;
    $exclude //= {};
    if( C4::Context->preference('marcflavour') eq 'UNIMARC' ) {
        # By default exclude field 100 from comparison in UNIMARC.
        # Will have been added by ModBiblio in merge.
        $exclude->{100} = 1;
    }
    my @oldfields = map { $exclude->{$_->tag} ? () : $_->tag } $oldmarc->fields;
    my @newfields = map { $exclude->{$_->tag} ? () : $_->tag } $newmarc->fields;

    if( $mode eq 'count' ) {
        my $t;
        is( scalar @newfields, $t = @oldfields, "Number of fields still equal to $t" );
    } elsif( $mode eq 'order' ) {
        is( ( join q/,/, @newfields ), ( join q/,/, @oldfields ), 'Order of fields unchanged' );
    }
}

$schema->storage->txn_rollback;
