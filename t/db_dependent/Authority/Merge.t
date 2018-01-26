#!/usr/bin/perl

# Tests for C4::AuthoritiesMarc::merge

use Modern::Perl;

use Test::More tests => 10;

use Getopt::Long;
use MARC::Record;
use Test::MockModule;

use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Biblio;
use Koha::Authorities;
use Koha::Authority::ControlledIndicators;
use Koha::Authority::MergeRequests;
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

# Global variables, mocking and framework modifications
our @linkedrecords;
my $mocks = set_mocks();
our ( $authtype1, $authtype2 ) = modify_framework();

subtest 'Test postponed merge feature' => sub {
    plan tests => 6;

    # Set limit to zero, and call merge a few times
    t::lib::Mocks::mock_preference('AuthorityMergeLimit', 0);
    my $auth1 = t::lib::TestBuilder->new->build({ source => 'AuthHeader' });
    my $cnt = Koha::Authority::MergeRequests->count;
    merge({ mergefrom => '0' });
    is( Koha::Authority::MergeRequests->count, $cnt, 'No merge request added as expected' );
    merge({ mergefrom => $auth1->{authid} });
    is( Koha::Authority::MergeRequests->count, $cnt, 'No merge request added since we have zero hits' );
    @linkedrecords = ( 1, 2 ); # these biblionumbers do not matter
    merge({ mergefrom => $auth1->{authid} });
    is( Koha::Authority::MergeRequests->count, $cnt + 1, 'Merge request added as expected' );

    # Set limit to two (starting with two records)
    t::lib::Mocks::mock_preference('AuthorityMergeLimit', 2);
    merge({ mergefrom => $auth1->{authid} });
    is( Koha::Authority::MergeRequests->count, $cnt + 1, 'No merge request added as we do not exceed the limit' );
    @linkedrecords = ( 1, 2, 3 ); # these biblionumbers do not matter
    merge({ mergefrom => $auth1->{authid} });
    is( Koha::Authority::MergeRequests->count, $cnt + 2, 'Merge request added as we do exceed the limit again' );
    # Now override
    merge({ mergefrom => $auth1->{authid}, override_limit => 1 });
    is( Koha::Authority::MergeRequests->count, $cnt + 2, 'No merge request added as we did override' );

    # Set merge limit high enough for the other subtests
    t::lib::Mocks::mock_preference('AuthorityMergeLimit', 1000);
};

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
    @linkedrecords = ( $biblionumber1, $biblionumber2 );
    my $rv = C4::AuthoritiesMarc::merge({ mergefrom => $authid2, MARCfrom => $auth2, mergeto => $authid1, MARCto => $auth1 });
    is( $rv, 1, 'We expect one biblio record (out of two) to be updated' );

    # Check the results
    my $newbiblio1 = GetMarcBiblio({ biblionumber => $biblionumber1 });
    compare_fields( $biblio1, $newbiblio1, {}, 'count' );
    compare_fields( $biblio1, $newbiblio1, {}, 'order' );
    is( $newbiblio1->subfield('609', '9'), $authid1, 'Check biblio1 609$9' );
    is( $newbiblio1->subfield('609', 'a'), 'George Orwell',
        'Check biblio1 609$a' );
    my $newbiblio2 = GetMarcBiblio({ biblionumber => $biblionumber2 });
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
    @linkedrecords = ( $biblionumber1, $biblionumber2 );
    t::lib::Mocks::mock_preference('AuthorityMergeMode', 'loose');
    my $rv = C4::AuthoritiesMarc::merge({ mergefrom => $authid1, MARCfrom => $auth1old, mergeto => $authid1, MARCto => $auth1new });
    is( $rv, 2, 'Both records are updated now' );

    #Check the results
    my $biblio1 = GetMarcBiblio({ biblionumber => $biblionumber1 });
    compare_fields( $MARC1, $biblio1, {}, 'count' );
    compare_fields( $MARC1, $biblio1, {}, 'order' );
    is( $auth1new->field(109)->subfield('a'), $biblio1->field(109)->subfield('a'), 'Record1 values updated correctly' );
    my $biblio2 = GetMarcBiblio({ biblionumber => $biblionumber2 });
    compare_fields( $MARC2, $biblio2, {}, 'count' );
    compare_fields( $MARC2, $biblio2, {}, 'order' );
    is( $auth1new->field(109)->subfield('a'), $biblio2->field(109)->subfield('a'), 'Record2 values updated correctly' );
    # This is only true in loose mode:
    is( $biblio1->field(109)->subfield('b'), $MARC1->field(109)->subfield('b'), 'Subfield not overwritten in loose mode');

    # Merge again in strict mode
    t::lib::Mocks::mock_preference('AuthorityMergeMode', 'strict');
    ModBiblio( $MARC1, $biblionumber1, '' );
    @linkedrecords = ( $biblionumber1 );
    $rv = C4::AuthoritiesMarc::merge({ mergefrom => $authid1, MARCfrom => $auth1old, mergeto => $authid1, MARCto => $auth1new });
    $biblio1 = GetMarcBiblio({ biblionumber => $biblionumber1 });
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
    my $oldbiblio = C4::Biblio::GetMarcBiblio({ biblionumber => $biblionumber });

    # Time to merge
    @linkedrecords = ( $biblionumber );
    my $retval = C4::AuthoritiesMarc::merge({ mergefrom => $authid1, MARCfrom => $auth1, mergeto => $authid2, MARCto => $auth2 });
    is( $retval, 1, 'We touched only one biblio' );

    # Get new marc record for compares
    my $newbiblio = C4::Biblio::GetMarcBiblio({ biblionumber => $biblionumber });
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

subtest 'Merging authorities should handle deletes (BZ 18070)' => sub {
    plan tests => 2;

    # Add authority and linked biblio, delete authority
    my $auth1 = MARC::Record->new;
    $auth1->append_fields( MARC::Field->new( '109', '', '', 'a' => 'DEL'));
    my $authid1 = AddAuthority( $auth1, undef, $authtype1 );
    my $bib1 = MARC::Record->new;
    $bib1->append_fields(
        MARC::Field->new( '245', '', '', a => 'test DEL' ),
        MARC::Field->new( '609', '', '', a => 'DEL', 9 => "$authid1" ),
    );
    my ( $biblionumber ) = C4::Biblio::AddBiblio( $bib1, '' );
    @linkedrecords = ( $biblionumber );
    DelAuthority({ authid => $authid1 }); # this triggers a merge call

    # See what happened in the biblio record
    my $marc1 = C4::Biblio::GetMarcBiblio({ biblionumber => $biblionumber });
    is( $marc1->field('609'), undef, 'Field 609 should be gone too' );

    # Now we simulate the delete as done in the cron job
    # First, restore auth1 and add 609 back in bib1
    $auth1 = MARC::Record->new;
    $auth1->append_fields( MARC::Field->new( '109', '', '', 'a' => 'DEL'));
    $authid1 = AddAuthority( $auth1, undef, $authtype1 );
    $marc1->append_fields(
        MARC::Field->new( '609', '', '', a => 'DEL', 9 => "$authid1" ),
    );
    ModBiblio( $marc1, $biblionumber, '' );
    # Instead of going through DelAuthority, we manually delete the auth
    # record and call merge afterwards.
    # This mimics deleting an authority and calling merge later in the
    # merge cron job.
    # We use the biblionumbers parameter here and unmock linked_biblionumbers.
    C4::Context->dbh->do( "DELETE FROM auth_header WHERE authid=?", undef, $authid1 );
    @linkedrecords = ();
    $mocks->{auth_mod}->unmock_all;
    merge({ mergefrom => $authid1, biblionumbers => [ $biblionumber ] });
    # Final check
    $marc1 = C4::Biblio::GetMarcBiblio({ biblionumber => $biblionumber });
    is( $marc1->field('609'), undef, 'Merge removed the 609 again even after deleting the authority record' );
};

subtest "Test some specific postponed merge issues" => sub {
    plan tests => 4;

    my $authmarc = MARC::Record->new;
    $authmarc->append_fields( MARC::Field->new( '109', '', '', 'a' => 'aa', b => 'bb' ));
    my $oldauthmarc = MARC::Record->new;
    $oldauthmarc->append_fields( MARC::Field->new( '112', '', '', c => 'cc' ));
    my $id = AddAuthority( $authmarc, undef, $authtype1 );
    my $biblio = MARC::Record->new;
    $biblio->append_fields(
        MARC::Field->new( '109', '', '', a => 'a1', 9 => $id ),
        MARC::Field->new( '612', '', '', a => 'a2', c => 'cc', 9 => $id+1 ),
        MARC::Field->new( '612', '', '', a => 'a3', 9 => $id+2 ),
    );
    my ( $biblionumber ) = C4::Biblio::AddBiblio( $biblio, '' );

    # Merge A to B postponed, A is deleted (simulated by id+1)
    # This proves the !authtypefrom condition in sub merge
    # Additionally, we test clearing subfield
    merge({ mergefrom => $id + 1, MARCfrom => $oldauthmarc, mergeto => $id, MARCto => $authmarc, biblionumbers => [ $biblionumber ] });
    $biblio = C4::Biblio::GetMarcBiblio({ biblionumber => $biblionumber });
    is( $biblio->subfield('609', '9'), $id, '612 moved to 609' );
    is( $biblio->subfield('609', 'c'), undef, '609c cleared correctly' );

    # Merge A to B postponed, delete B immediately (hits B < hits A)
    # This proves the !@record_to test in sub merge
    merge({ mergefrom => $id + 2, mergeto => $id + 1, MARCto => undef, biblionumbers => [ $biblionumber ] });
    $biblio = C4::Biblio::GetMarcBiblio({ biblionumber => $biblionumber });
    is( $biblio->field('612'), undef, 'Last 612 must be gone' );

    # Show that we 'need' skip_merge; this example is far-fetched.
    # We *prove* by contradiction.
    # Suppose: Merge A to B postponed, and delete A would merge rightaway.
    # (You would need some special race condition with merge.pl to do so.)
    # The modify merge would be useless after that.
    @linkedrecords = ( $biblionumber );
    my $restored_mocks = set_mocks();
    DelAuthority({ authid => $id, skip_merge => 1 }); # delete A
    $restored_mocks->{auth_mod}->unmock_all;
    $biblio = C4::Biblio::GetMarcBiblio({ biblionumber => $biblionumber });
    is( $biblio->subfield('109', '9'), $id, 'If the 109 is no longer present, another modify merge would not bring it back' );
};

subtest "Graceful resolution of missing reporting tag" => sub {
    plan tests => 2;

    # Simulate merge with authority in Default fw without reporting tag
    # We expect data loss in biblio, but we keep $a and the reference in $9
    # in order to allow a future merge to restore data.

    # Accomplish the above by clearing reporting tag in $authtype2
    my $fw2 = Koha::Authority::Types->find( $authtype2 );
    $fw2->auth_tag_to_report('')->store;

    my $authmarc = MARC::Record->new;
    $authmarc->append_fields( MARC::Field->new( '109', '', '', 'a' => 'aa', b => 'bb' ));
    my $id1 = AddAuthority( $authmarc, undef, $authtype1 );
    my $id2 = AddAuthority( $authmarc, undef, $authtype2 );

    my $biblio = MARC::Record->new;
    $biblio->append_fields(
        MARC::Field->new( '609', '', '', a => 'aa', 9 => $id1 ),
    );
    my ( $biblionumber ) = C4::Biblio::AddBiblio( $biblio, '' );

    # Merge
    merge({ mergefrom => $id1, MARCfrom => $authmarc, mergeto => $id2, MARCto => $authmarc, biblionumbers => [ $biblionumber ] });
    $biblio = C4::Biblio::GetMarcBiblio({ biblionumber => $biblionumber });
    is( $biblio->subfield('612', '9'), $id2, 'id2 saved in $9' );
    is( $biblio->subfield('612', 'a'), ' ', 'Kept an empty $a too' );

    $fw2->auth_tag_to_report('112')->store;
};

subtest 'merge should not reorder too much' => sub {
    plan tests => 2;

    # Back to loose mode
    t::lib::Mocks::mock_preference('AuthorityMergeMode', 'loose');

    my $authmarc = MARC::Record->new;
    $authmarc->append_fields( MARC::Field->new( '109', '', '', 'a' => 'aa', b => 'bb' ));
    my $id = AddAuthority( $authmarc, undef, $authtype1 );
    my $biblio = MARC::Record->new;
    $biblio->append_fields(
        MARC::Field->new( '109', '', '', 9 => $id, i => 'in front', a => 'aa', c => 'after controlled block' ), # this field shows the old situation when $9 is the first subfield
        MARC::Field->new( '609', '', '', i => 'in front', a => 'aa', c => 'after controlled block', 9 => $id ), # here $9 is already the last one
    );
    my ( $biblionumber ) = C4::Biblio::AddBiblio( $biblio, '' );

    # Merge 109 and 609 and check order of subfields
    merge({ mergefrom => $id, MARCfrom => $authmarc, mergeto => $id, MARCto => $authmarc, biblionumbers => [ $biblionumber ] });
    my $biblio2 = C4::Biblio::GetMarcBiblio({ biblionumber => $biblionumber });
    my $subfields = [ map { $_->[0] } $biblio2->field('109')->subfields ];
    is_deeply( $subfields, [ 'i', 'a', 'b', 'c', '9' ], 'Merge only moved $9' );
    $subfields = [ map { $_->[0] } $biblio2->field('609')->subfields ];
    is_deeply( $subfields, [ 'i', 'a', 'b', 'c', '9' ], 'Order kept' );
};

subtest 'Test how merge handles controlled indicators' => sub {
    plan tests => 4;

    # Note: See more detailed tests in t/Koha/Authority/ControlledIndicators.t

    # Testing MARC21 because thesaurus code makes it more interesting
    t::lib::Mocks::mock_preference( 'marcflavour', 'MARC21' );
    t::lib::Mocks::mock_preference('AuthorityControlledIndicators', q|marc21,*,ind1:auth1,ind2:thesaurus|);

    my $authmarc = MARC::Record->new;
    $authmarc->append_fields(
        MARC::Field->new( '008', (' 'x11).'r' ), # thesaurus code
        MARC::Field->new( '109', '7', '', 'a' => 'a' ),
    );
    my $id = AddAuthority( $authmarc, undef, $authtype1 );
    my $biblio = MARC::Record->new;
    $biblio->append_fields(
        MARC::Field->new( '609', '8', '4', a => 'a', 2 => '2', 9 => $id ),
    );
    my ( $biblionumber ) = C4::Biblio::AddBiblio( $biblio, '' );

    # Merge and check indicators and $2
    merge({ mergefrom => $id, MARCfrom => $authmarc, mergeto => $id, MARCto => $authmarc, biblionumbers => [ $biblionumber ] });
    my $biblio2 = C4::Biblio::GetMarcBiblio({ biblionumber => $biblionumber });
    is( $biblio2->field('609')->indicator(1), '7', 'Indicator1 OK' );
    is( $biblio2->field('609')->indicator(2), '7', 'Indicator2 OK' );
    is( $biblio2->subfield('609', '2'), 'aat', 'Subfield $2 OK' );

    # Test $2 removal now
    $authmarc->field('008')->update( (' 'x11).'a' ); # LOC, no $2 needed
    AddAuthority( $authmarc, $id, $authtype1 ); # modify
    merge({ mergefrom => $id, MARCfrom => $authmarc, mergeto => $id, MARCto => $authmarc, biblionumbers => [ $biblionumber ] });
    $biblio2 = C4::Biblio::GetMarcBiblio({ biblionumber => $biblionumber });
    is( $biblio2->subfield('609', '2'), undef, 'No subfield $2 left' );
};

sub set_mocks {
    # After we removed the Zebra code from merge, we only need to mock
    # get_usage_count and linked_biblionumbers here.

    my $mocks;
    $mocks->{auth_mod} = Test::MockModule->new( 'Koha::Authorities' );
    $mocks->{auth_mod}->mock( 'get_usage_count', sub {
         return scalar @linkedrecords;
    });
    $mocks->{auth_mod}->mock( 'linked_biblionumbers', sub {
         return @linkedrecords;
    });
    return $mocks;
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
