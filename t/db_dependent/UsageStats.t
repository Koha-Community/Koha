# Copyright 2015 BibLibre
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use Test::More tests => 57;
use t::lib::Mocks qw(mock_preference);
use t::lib::TestBuilder;
use POSIX qw(strftime);
use Data::Dumper;
use Koha::Biblios;

use Koha::Libraries;

BEGIN {
    use_ok('C4::UsageStats');
    use_ok('C4::Context');
    use_ok('C4::Biblio');
    use_ok( 'C4::AuthoritiesMarc', qw(AddAuthority) );
    use_ok('C4::Reserves');
    use_ok('MARC::Record');
    use_ok('Koha::Acquisition::Orders');
}

can_ok(
    'C4::UsageStats', qw(
      NeedUpdate
      BuildReport
      ReportToCommunity
      _count )
);

my $schema  = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;
my $dbh = C4::Context->dbh;

$dbh->do('DELETE FROM issues');
$dbh->do('DELETE FROM biblio');
$dbh->do('DELETE FROM items');
$dbh->do('DELETE FROM auth_header');
$dbh->do('DELETE FROM old_issues');
$dbh->do('DELETE FROM old_reserves');
$dbh->do('DELETE FROM borrowers');
$dbh->do('DELETE FROM aqorders');
$dbh->do('DELETE FROM subscription');

#################################################
#             Testing Subs
#################################################

# ---------- Testing NeedUpdate -----------------

#Mocking C4::Context->preference("UsageStatsLastUpdateTime") to 0
my $now = strftime( "%s", localtime );
t::lib::Mocks::mock_preference( "UsageStatsLastUpdateTime", 0 );

my $update = C4::UsageStats->NeedUpdate;
is( $update, 1, "There is no last update, update needed" );

#Mocking C4::Context->preference("UsageStatsLastUpdateTime") to now
$now = strftime( "%s", localtime );
t::lib::Mocks::mock_preference( "UsageStatsLastUpdateTime", $now );

$update = C4::UsageStats->NeedUpdate;
is( $update, 0, "Last update just be done, no update needed " );

my $nb_of_libraries = Koha::Libraries->count;

# ---------- Testing BuildReport ----------------

#Test report->library -----------------
#mock to 0
t::lib::Mocks::mock_preference( "UsageStatsID",          0 );
t::lib::Mocks::mock_preference( "UsageStatsLibraryName", 0 );
t::lib::Mocks::mock_preference( "UsageStatsLibrariesInfo",  0 );
t::lib::Mocks::mock_preference( "UsageStatsLibraryType", 0 );
t::lib::Mocks::mock_preference( "UsageStatsCountry",     0 );
t::lib::Mocks::mock_preference( "UsageStatsLibraryUrl",  0 );

my $report = C4::UsageStats->BuildReport();

isa_ok( $report,              'HASH',  '$report is a HASH' );
isa_ok( $report->{libraries}, 'ARRAY', '$report->{libraries} is an ARRAY' );
is( scalar( @{ $report->{libraries} } ), 0, "There are 0 fields in libraries, libraries info are not shared" );
is( $report->{installation}->{koha_id}, 0,  "UsageStatsID          is good" );
is( $report->{installation}->{name},    '', "UsageStatsLibraryName is good" );
is( $report->{installation}->{url},     '', "UsageStatsLibraryUrl  is good" );
is( $report->{installation}->{type},    '', "UsageStatsLibraryType is good" );
is( $report->{installation}->{country}, '', "UsageStatsCountry     is good" );


#mock with values
t::lib::Mocks::mock_preference( "UsageStatsID",          1 );
t::lib::Mocks::mock_preference( "UsageStatsLibraryName", 'NAME' );
t::lib::Mocks::mock_preference( "UsageStatsLibraryUrl",  'URL' );
t::lib::Mocks::mock_preference( "UsageStatsLibraryType", 'TYPE' );
t::lib::Mocks::mock_preference( "UsageStatsCountry",     'COUNTRY' );
t::lib::Mocks::mock_preference( "UsageStatsLibrariesInfo", 1 );
t::lib::Mocks::mock_preference( "UsageStatsGeolocation", 1 );


$report = C4::UsageStats->BuildReport();

isa_ok( $report,              'HASH',  '$report is a HASH' );
isa_ok( $report->{libraries}, 'ARRAY', '$report->{libraries} is an ARRAY' );
is( scalar( @{ $report->{libraries} } ), $nb_of_libraries, "There are 6 fields in $report->{libraries}" );
is( $report->{installation}->{koha_id}, 1,     "UsageStatsID          is good" );
is( $report->{installation}->{name},   'NAME', "UsageStatsLibraryName is good" );
is( $report->{installation}->{url},     'URL', "UsageStatsLibraryUrl  is good" );
is( $report->{installation}->{type},   'TYPE', "UsageStatsLibraryType is good" );
is( $report->{installation}->{country}, 'COUNTRY', "UsageStatsCountry is good" );

#Test report->volumetry ---------------
#with original values
$report = C4::UsageStats->BuildReport();

isa_ok( $report,              'HASH', '$report is a HASH' );
isa_ok( $report->{volumetry}, 'HASH', '$report->{volumetry} is a HASH' );
is( scalar( keys %{$report->{volumetry}} ), 8, "There are 8 fields in $report->{volumetry}" );
is( $report->{volumetry}->{biblio},         0, "There is no biblio" );
is( $report->{volumetry}->{items},          0, "There is no items" );
is( $report->{volumetry}->{auth_header},    0, "There is no auth_header" );
is( $report->{volumetry}->{old_issues},     0, "There is no old_issues" );
is( $report->{volumetry}->{old_reserves},   0, "There is no old_reserves" );
is( $report->{volumetry}->{borrowers},      0, "There is no borrowers" );
is( $report->{volumetry}->{aqorders},       0, "There is no aqorders" );
is( $report->{volumetry}->{subscription},   0, "There is no subscription" );

#after adding objects
construct_objects_needed();

$report = C4::UsageStats->BuildReport();

isa_ok( $report,              'HASH', '$report is a HASH' );
isa_ok( $report->{volumetry}, 'HASH', '$report->{volumetry} is a HASH' );
is( scalar( keys %{$report->{volumetry}} ), 8, "There are 8 fields in $report->{volumetry}" );
is( $report->{volumetry}->{biblio},         3, "There are 3 biblio" );
is( $report->{volumetry}->{items},          3, "There are 3 items" );
is( $report->{volumetry}->{auth_header},    2, "There are 2 auth_header" );
is( $report->{volumetry}->{old_issues},     1, "There is  1 old_issues" );
is( $report->{volumetry}->{old_reserves},   1, "There is  1 old_reserves" );
is( $report->{volumetry}->{borrowers},      3, "There are 3 borrowers" );
is( $report->{volumetry}->{aqorders},       1, "There is  1 aqorders" );
is( $report->{volumetry}->{subscription},   1, "There is  1 subscription" );

#Test report->systempreferences -------
#mock to 0
mocking_systempreferences_to_a_set_value(0);

$report = C4::UsageStats->BuildReport();
isa_ok( $report,                      'HASH', '$report is a HASH' );
isa_ok( $report->{systempreferences}, 'HASH', '$report->{systempreferences} is a HASH' );
verif_systempreferences_values( $report, 0 );

#mock with values
mocking_systempreferences_to_a_set_value(1);

$report = C4::UsageStats->BuildReport();
isa_ok( $report,                      'HASH', '$report is a HASH' );
isa_ok( $report->{systempreferences}, 'HASH', '$report->{systempreferences} is a HASH' );
verif_systempreferences_values( $report, 1 );

#Test if unwanted syspref are not sent
is( $report->{systempreferences}->{useDischarge}, undef, 'useDischarge should not be shared');
is( $report->{systempreferences}->{OpacUserJS},   undef, 'OpacUserJS   should not be shared');

# ---------- Testing ReportToCommunity ----------

# ---------- Testing _count ---------------------
my $query = '
  SELECT count(*)
  FROM   borrowers
  ';
my $count = $dbh->selectrow_array($query);

my $nb_fields = C4::UsageStats::_count('borrowers');
is( $nb_fields, $count, "_count return the good number of fields" );

#################################################
#             Subs
#################################################

# Adding :
# 3 borrowers
# 4 biblio
# 3 biblio items
# 3 items
# 2 auth_header
# 1 old_issues
# 1 old_reserves
# 1 subscription
# 1 aqorders
sub construct_objects_needed {

    # ---------- 3 borrowers  ---------------------
    my $surname1     = 'Borrower 1';
    my $surname2     = 'Borrower 2';
    my $surname3     = 'Borrower 3';
    my $firstname1   = 'firstname 1';
    my $firstname2   = 'firstname 2';
    my $firstname3   = 'firstname 3';
    my $cardnumber1  = 'test_card1';
    my $cardnumber2  = 'test_card2';
    my $cardnumber3  = 'test_card3';
    my $categorycode = $builder->build({ source => 'Category' })->{categorycode};
    my $branchcode = $builder->build({ source => 'Branch' })->{branchcode};

    my $query = '
    INSERT INTO borrowers
      (surname, firstname, cardnumber, branchcode, categorycode)
    VALUES (?,?,?,?,?)';
    my $insert_sth = $dbh->prepare($query);
    $insert_sth->execute( $surname1, $firstname1, $cardnumber1, $branchcode, $categorycode );
    my $borrowernumber1 = $dbh->last_insert_id( undef, undef, 'borrowers', undef );
    $insert_sth->execute( $surname2, $firstname2, $cardnumber2, $branchcode, $categorycode );
    my $borrowernumber2 = $dbh->last_insert_id( undef, undef, 'borrowers', undef );
    $insert_sth->execute( $surname3, $firstname3, $cardnumber3, $branchcode, $categorycode );
    my $borrowernumber3 = $dbh->last_insert_id( undef, undef, 'borrowers', undef );

    # ---------- 3 biblios -----------------------
    my $title1  = 'Title 1';
    my $title2  = 'Title 2';
    my $title3  = 'Title 3';
    my $author1 = 'Author 1';
    my $author2 = 'Author 2';
    my $author3 = 'Author 3';

    $query = '
    INSERT INTO biblio
      (title, author, datecreated)
    VALUES (?,?, NOW())';
    $insert_sth = $dbh->prepare($query);
    $insert_sth->execute( $title1, $author1 );
    my $biblionumber1 = $dbh->last_insert_id( undef, undef, 'biblio', undef );
    $insert_sth->execute( $title2, undef );
    my $biblionumber2 = $dbh->last_insert_id( undef, undef, 'biblio', undef );
    $insert_sth->execute( $title3, $author3 );
    my $biblionumber3 = $dbh->last_insert_id( undef, undef, 'biblio', undef );

    # ---------- 3 biblio items  -------------------------
    $query = '
    INSERT INTO biblioitems
      (biblionumber, itemtype)
    VALUES (?,?)';
    $insert_sth = $dbh->prepare($query);
    $insert_sth->execute( $biblionumber1, 'Book' );
    my $biblioitemnumber1 = $dbh->last_insert_id( undef, undef, 'biblioitems', undef );
    $insert_sth->execute( $biblionumber2, 'Music' );
    my $biblioitemnumber2 = $dbh->last_insert_id( undef, undef, 'biblioitems', undef );
    $insert_sth->execute( $biblionumber3, 'Book' );
    my $biblioitemnumber3 = $dbh->last_insert_id( undef, undef, 'biblioitems', undef );

    # ---------- 3 items  -------------------------
    my $barcode1 = '111111';
    my $barcode2 = '222222';
    my $barcode3 = '333333';

    $query = '
    INSERT INTO items
      (biblionumber, biblioitemnumber, barcode, itype)
    VALUES (?,?,?,?)';
    $insert_sth = $dbh->prepare($query);
    $insert_sth->execute( $biblionumber1, $biblioitemnumber1, $barcode1, 'Book' );
    my $item_number1 = $dbh->last_insert_id( undef, undef, 'items', undef );
    $insert_sth->execute( $biblionumber2, $biblioitemnumber2, $barcode2, 'Music' );
    my $item_number2 = $dbh->last_insert_id( undef, undef, 'items', undef );
    $insert_sth->execute( $biblionumber3, $biblioitemnumber3, $barcode3, 'Book' );
    my $item_number3 = $dbh->last_insert_id( undef, undef, 'items', undef );

    # ---------- Add 2 auth_header
    $query = '
    INSERT INTO auth_header
      (authtypecode, marcxml)
    VALUES (?, "")';
    $insert_sth = $dbh->prepare($query);
    $insert_sth->execute('atc1');
    my $authid1 = $dbh->last_insert_id( undef, undef, 'auth_header', undef );
    $insert_sth->execute('atc2');
    my $authid2 = $dbh->last_insert_id( undef, undef, 'auth_header', undef );

    # ---------- Add 1 old_issues
    $query = '
    INSERT INTO old_issues
      (borrowernumber, branchcode, itemnumber)
    VALUES (?,?,?)';
    $insert_sth = $dbh->prepare($query);
    $insert_sth->execute( $borrowernumber1, $branchcode, $item_number1 );
    my $issue_id1 = $dbh->last_insert_id( undef, undef, 'old_issues', undef );

    # ---------- Add 1 old_reserves
    AddReserve( $branchcode, $borrowernumber1, $biblionumber1, '', 1, undef, undef, '', 'Title', undef, undef );
    my $biblio = Koha::Biblios->find( $biblionumber1 );
    my $holds = $biblio->holds;
    $holds->next->cancel if $holds->count;

    # ---------- Add 1 aqbudgets
    $query = '
    INSERT INTO aqbudgets
      (budget_amount)
    VALUES (?)';
    $insert_sth = $dbh->prepare($query);
    $insert_sth->execute("20.0");
    my $aqbudgets1 = $dbh->last_insert_id( undef, undef, 'aqbudgets', undef );

    # ---------- Add 1 aqorders
    $query = '
    INSERT INTO aqorders
      (budget_id, basketno, biblionumber, invoiceid, subscriptionid)
    VALUES (?,?,?,?,?)';
    $insert_sth = $dbh->prepare($query);
    $insert_sth->execute( $aqbudgets1, undef, undef, undef, undef );
    my $aqorders1 = $dbh->last_insert_id( undef, undef, 'aqorders', undef );

    # --------- Add 1 subscription
    $query = '
    INSERT INTO subscription
      (biblionumber)
    VALUES (?)';
    $insert_sth = $dbh->prepare($query);
    $insert_sth->execute($biblionumber1);
    my $subscription1 = $dbh->last_insert_id( undef, undef, 'subscription', undef );

}

#Change systempreferences values to $set_value
sub mocking_systempreferences_to_a_set_value {
    my $set_value = shift;

    foreach (
        qw/
        AcqCreateItem
        AcqWarnOnDuplicateInvoice
        AcqViewBaskets
        BasketConfirmations
        OrderPdfFormat
        casAuthentication
        casLogout
        AllowPKIAuth
        DebugLevel
        delimiter
        noItemTypeImages
        virtualshelves
        AutoLocation
        IndependentBranches
        SessionStorage
        Persona
        AuthDisplayHierarchy
        AutoCreateAuthorities
        BiblioAddsAuthorities
        AuthorityMergeLimit
        AuthorityMergeMode
        UseAuthoritiesForTracings
        CatalogModuleRelink
        hide_marc
        IntranetBiblioDefaultView
        LabelMARCView
        OpacSuppression
        SeparateHoldings
        UseControlNumber
        advancedMARCeditor
        DefaultClassificationSource
        EasyAnalyticalRecords
        autoBarcode
        item-level_itypes
        marcflavour
        PrefillItem
        z3950NormalizeAuthor
        SpineLabelAutoPrint
        SpineLabelShowPrintOnBibDetails
        BlockReturnOfLostItems
        BlockReturnOfWithdrawnItems
        CalculateFinesOnReturn
        AgeRestrictionOverride
        AllFinesNeedOverride
        AllowFineOverride
        AllowItemsOnHoldCheckout
        AllowItemsOnHoldCheckoutSCO
        AllowNotForLoanOverride
        AllowRenewalLimitOverride
        AllowReturnToBranch
        AllowTooManyOverride
        AutomaticItemReturn
        AutoRemoveOverduesRestrictions
        CircControl
        HomeOrHoldingBranch
        HomeOrHoldingBranchReturn
        InProcessingToShelvingCart
        IssueLostItem
        IssuingInProcess
        ManInvInNoissuesCharge
        OverduesBlockCirc
        RenewalPeriodBase
        RenewalSendNotice
        RentalsInNoissuesCharge
        ReturnBeforeExpiry
        ReturnToShelvingCart
        TransfersMaxDaysWarning
        UseBranchTransferLimits
        useDaysMode
        UseTransportCostMatrix
        UseCourseReserves
        finesCalendar
        FinesIncludeGracePeriod
        finesMode
        RefundLostOnReturnControl
        WhenLostChargeReplacementFee
        WhenLostForgiveFine
        AllowHoldDateInFuture
        AllowHoldPolicyOverride
        AllowHoldsOnDamagedItems
        AllowHoldsOnPatronsPossessions
        AutoResumeSuspendedHolds
        canreservefromotherbranches
        decreaseLoanHighHolds
        DisplayMultiPlaceHold
        emailLibrarianWhenHoldIsPlaced
        ExpireReservesMaxPickUpDelay
        OPACAllowHoldDateInFuture
        OPACAllowUserToChooseBranch
        ReservesControlBranch
        ReservesNeedReturns
        SuspendHoldsIntranet
        SuspendHoldsOpac
        TransferWhenCancelAllWaitingHolds
        AllowAllMessageDeletion
        AllowOfflineCirculation
        CircAutocompl
        CircAutoPrintQuickSlip
        DisplayClearScreenButton
        FilterBeforeOverdueReport
        FineNotifyAtCheckin
        itemBarcodeFallbackSearch
        itemBarcodeInputFilter
        previousIssuesDefaultSortOrder
        RecordLocalUseOnReturn
        soundon
        SpecifyDueDate
        todaysIssuesDefaultSortOrder
        UpdateTotalIssuesOnCirc
        UseTablesortForCirc
        WaitingNotifyAtCheckin
        AllowSelfCheckReturns
        AutoSelfCheckAllowed
        FRBRizeEditions
        OPACFRBRizeEditions
        AmazonCoverImages
        OPACAmazonCoverImages
        Babeltheque
        BakerTaylorEnabled
        GoogleJackets
        HTML5MediaEnabled
        IDreamBooksReadometer
        IDreamBooksResults
        IDreamBooksReviews
        LibraryThingForLibrariesEnabled
        LocalCoverImages
        OPACLocalCoverImages
        NovelistSelectEnabled
        XISBN
        OpenLibraryCovers
        OpenLibrarySearch
        UseKohaPlugins
        SyndeticsEnabled
        TagsEnabled
        CalendarFirstDayOfWeek
        opaclanguagesdisplay
        AuthoritiesLog
        BorrowersLog
        CataloguingLog
        FinesLog
        IssueLog
        LetterLog
        ReturnLog
        SubscriptionLog
        BiblioDefaultView
        COinSinOPACResults
        DisplayOPACiconsXSLT
        hidelostitems
        HighlightOwnItemsOnOPAC
        OpacAddMastheadLibraryPulldown
        OPACDisplay856uAsImage
        OpacHighlightedWords
        OpacKohaUrl
        OpacMaintenance
        OpacPublic
        OpacSeparateHoldings
        OPACShowCheckoutName
        OpacShowFiltersPulldownMobile
        OPACShowHoldQueueDetails
        OpacShowRecentComments
        OPACShowUnusedAuthorities
        OpacStarRatings
        opacthemes
        OPACURLOpenInNewWindow
        OpacAuthorities
        opacbookbag
        OpacBrowser
        OpacBrowseResults
        OpacCloud
        OPACFinesTab
        OpacHoldNotes
        OpacItemLocation
        OpacPasswordChange
        OPACPatronDetails
        OPACpatronimages
        OPACPopupAuthorsSearch
        OpacTopissue
        opacuserlogin
        QuoteOfTheDay
        RequestOnOpac
        reviewson
        ShowReviewer
        ShowReviewerPhoto
        SocialNetworks
        suggestion
        AllowPurchaseSuggestionBranchChoice
        OpacAllowPublicListCreation
        OpacAllowSharingPrivateLists
        OpacRenewalAllowed
        OpacRenewalBranch
        OPACViewOthersSuggestions
        SearchMyLibraryFirst
        singleBranchMode
        AnonSuggestions
        EnableOpacSearchHistory
        OPACPrivacy
        opacreadinghistory
        TrackClicks
        PatronSelfRegistration
        OPACShelfBrowser
        AutoEmailOpacUser
        AutoEmailPrimaryAddress
        autoMemberNum
        BorrowerRenewalPeriodBase
        checkdigit
        EnableBorrowerFiles
        EnhancedMessagingPreferences
        ExtendedPatronAttributes
        intranetreadinghistory
        patronimages
        TalkingTechItivaPhoneNotification
        uppercasesurnames
        IncludeSeeFromInSearches
        OpacGroupResults
        QueryAutoTruncate
        QueryFuzzy
        QueryStemming
        QueryWeightFields
        TraceCompleteSubfields
        TraceSubjectSubdivisions
        UseICU
        UseQueryParser
        defaultSortField
        displayFacetCount
        OPACdefaultSortField
        OPACItemsResultsDisplay
        expandedSearchOption
        IntranetNumbersPreferPhrase
        OPACNumbersPreferPhrase
        opacSerialDefaultTab
        RenewSerialAddsSuggestion
        RoutingListAddReserves
        RoutingSerials
        SubscriptionHistory
        Display856uAsImage
        DisplayIconsXSLT
        template
        yuipath
        HidePatronName
        intranetbookbag
        StaffDetailItemSelection
        viewISBD
        viewLabeledMARC
        viewMARC
        ILS-DI
        OAI-PMH
        version
        AudioAlerts
        /
      ) {
        t::lib::Mocks::mock_preference( $_, $set_value );
    }
}

#Test if all systempreferences are at $value_to_test
sub verif_systempreferences_values {
    my ( $report, $value_to_test ) = @_;

    my @missings;
    foreach my $key ( keys %{$report->{systempreferences}} ) {
        if ( $report->{systempreferences}->{$key} ne $value_to_test ) {
            warn $key;
            push @missings, $key;
        }
    }
    unless ( @missings ) {
        ok(1, 'All prefs are present');
    } else {
        ok(0, 'Some prefs are missing: ' . Dumper(\@missings));
    }
}

$schema->storage->txn_rollback;
