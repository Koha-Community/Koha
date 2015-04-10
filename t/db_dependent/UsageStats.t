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
use Test::More tests => 552;
use t::lib::Mocks qw(mock_preference);
use POSIX qw(strftime);
use Data::Dumper;

BEGIN {
    use_ok('C4::UsageStats');
    use_ok('C4::Context');
    use_ok('C4::Biblio');
    use_ok( 'C4::AuthoritiesMarc', qw(AddAuthority) );
    use_ok('C4::Reserves');
    use_ok('MARC::Record');
    use_ok('Koha::Acquisition::Order');
    use_ok('t::lib::TestBuilder');
}

can_ok(
    'C4::UsageStats', qw(
      NeedUpdate
      BuildReport
      ReportToCommunity
      _count )
);

my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;
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

# ---------- Testing BuildReport ----------------

#Test report->library -----------------
#mock to 0
t::lib::Mocks::mock_preference( "UsageStatsID",          0 );
t::lib::Mocks::mock_preference( "UsageStatsLibraryName", 0 );
t::lib::Mocks::mock_preference( "UsageStatsLibraryUrl",  0 );
t::lib::Mocks::mock_preference( "UsageStatsLibraryType", 0 );
t::lib::Mocks::mock_preference( "UsageStatsCountry",     0 );

my $report = C4::UsageStats->BuildReport();

isa_ok( $report,            'HASH', '$report is a HASH' );
isa_ok( $report->{library}, 'HASH', '$report->{library} is a HASH' );
is( scalar( keys( $report->{library} ) ), 5,  "There are 5 fields in $report->{library}" );
is( $report->{library}->{id},             0,  "UsageStatsID           is good" );
is( $report->{library}->{name},           '', "UsageStatsLibraryName  is good" );
is( $report->{library}->{url},            '', "UsageStatsLibraryUrl   is good" );
is( $report->{library}->{type},           '', "UsageStatsLibraryType  is good" );
is( $report->{library}->{country},        '', "UsageStatsCountry      is good" );

#mock with values
t::lib::Mocks::mock_preference( "UsageStatsID",          1 );
t::lib::Mocks::mock_preference( "UsageStatsLibraryName", 'NAME' );
t::lib::Mocks::mock_preference( "UsageStatsLibraryUrl",  'URL' );
t::lib::Mocks::mock_preference( "UsageStatsLibraryType", 'TYPE' );
t::lib::Mocks::mock_preference( "UsageStatsCountry",     'COUNTRY' );

$report = C4::UsageStats->BuildReport();

isa_ok( $report,            'HASH', '$report is a HASH' );
isa_ok( $report->{library}, 'HASH', '$report->{library} is a HASH' );
is( scalar( keys( $report->{library} ) ), 5,         "There are 5 fields in $report->{library}" );
is( $report->{library}->{id},             1,         "UsageStatsID            is good" );
is( $report->{library}->{name},           'NAME',    "UsageStatsLibraryName   is good" );
is( $report->{library}->{url},            'URL',     "UsageStatsLibraryUrl    is good" );
is( $report->{library}->{type},           'TYPE',    "UsageStatsLibraryType   is good" );
is( $report->{library}->{country},        'COUNTRY', "UsageStatsCountry       is good" );

#Test report->volumetry ---------------
#without objects
$report = C4::UsageStats->BuildReport();

isa_ok( $report,              'HASH', '$report is a HASH' );
isa_ok( $report->{volumetry}, 'HASH', '$report->{volumetry} is a HASH' );
is( scalar( keys( $report->{volumetry} ) ), 8, "There are 8 fields in $report->{volumetry}" );
is( $report->{volumetry}->{biblio},         0, "There is no biblio" );
is( $report->{volumetry}->{items},          0, "There is no items" );
is( $report->{volumetry}->{auth_header},    0, "There is no auth_header" );
is( $report->{volumetry}->{old_issues},     0, "There is no old_issues" );
is( $report->{volumetry}->{old_reserves},   0, "There is no old_reserves" );
is( $report->{volumetry}->{borrowers},      0, "There is no borrowers" );
is( $report->{volumetry}->{aqorders},       0, "There is no aqorders" );
is( $report->{volumetry}->{subscription},   0, "There is no subscription" );

construct_objects_needed();

#with objects
$report = C4::UsageStats->BuildReport();

isa_ok( $report,              'HASH', '$report is a HASH' );
isa_ok( $report->{volumetry}, 'HASH', '$report->{volumetry} is a HASH' );
is( scalar( keys( $report->{volumetry} ) ), 8, "There are 8 fields in $report->{volumetry}" );
is( $report->{volumetry}->{biblio},         4, "There are 4 biblio" );
is( $report->{volumetry}->{items},          3, "There are 3 items" );
is( $report->{volumetry}->{auth_header},    2, "There are 2 auth_header" );
is( $report->{volumetry}->{old_issues},     1, "There is 1 old_issues" );
is( $report->{volumetry}->{old_reserves},   1, "There is 1 old_reserves" );
is( $report->{volumetry}->{borrowers},      3, "There are 3 borrowers" );
is( $report->{volumetry}->{aqorders},       1, "There is 1 aqorders" );
is( $report->{volumetry}->{subscription},   1, "There is 1 subscription" );

#Test report->systempreferences -------
#mock to 0
mocking_systempreferences_to_a_set_value(0);

$report = C4::UsageStats->BuildReport();
isa_ok( $report,                      'HASH', '$report is a HASH' );
isa_ok( $report->{systempreferences}, 'HASH', '$report->{systempreferences} is a HASH' );
is( scalar( keys( $report->{systempreferences} ) ), 248, "There are 248 fields in $report->{systempreferences}" );
verif_systempreferences_values(0);

#mock with values
mocking_systempreferences_to_a_set_value(1);

$report = C4::UsageStats->BuildReport();
isa_ok( $report,                      'HASH', '$report is a HASH' );
isa_ok( $report->{systempreferences}, 'HASH', '$report->{systempreferences} is a HASH' );
is( scalar( keys( $report->{systempreferences} ) ), 248, "There are 248 fields in $report->{systempreferences}" );
verif_systempreferences_values(1);

# ---------- Testing ReportToCommunity ----------

# ---------- Testing _count ---------------------

$dbh->do('DROP TABLE IF EXISTS _exmpl_tbl');
$dbh->do('CREATE TABLE _exmpl_tbl (id INT, val VARCHAR(10))');
$dbh->do( 'INSERT INTO _exmpl_tbl VALUES(1, ?)', undef, 'Hello' );
$dbh->do( 'INSERT INTO _exmpl_tbl VALUES(2, ?)', undef, 'World' );

my $query = '
  SELECT count(*)
  FROM   _exmpl_tbl
  ';
my $count = $dbh->selectrow_array($query);

my $nb_fields = C4::UsageStats::_count('_exmpl_tbl');
is( $nb_fields, $count, "_exmpl_tbl has 2 fields" );

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
    my $cardnumber1  = '00001';
    my $cardnumber2  = '00002';
    my $cardnumber3  = '00003';
    my $categorycode = Koha::Database->new()->schema()->resultset('Category')->first()->categorycode();
    my $branchcode   = Koha::Database->new()->schema()->resultset('Branch')->first()->branchcode();

    my $query = '
   INSERT INTO borrowers
      (surname, firstname, cardnumber, branchcode, categorycode)
    VALUES (?,?,?,?,?)';
    my $insert_sth = $dbh->prepare($query);
    $insert_sth->execute( $surname1, $firstname1, $cardnumber1, $branchcode, $categorycode );
    $insert_sth->execute( $surname2, $firstname2, $cardnumber2, $branchcode, $categorycode );
    $insert_sth->execute( $surname3, $firstname3, $cardnumber3, $branchcode, $categorycode );

    $query = '
    SELECT borrowernumber
    FROM   borrowers
    WHERE  surname = ?';
    my $borrowernumber1 = $dbh->selectrow_array( $query, {}, $surname1 );
    my $borrowernumber2 = $dbh->selectrow_array( $query, {}, $surname2 );
    my $borrowernumber3 = $dbh->selectrow_array( $query, {}, $surname3 );

    # ---------- 3 biblios -----------------------
    my $title1  = 'Title 1';
    my $title2  = 'Title 2';
    my $title3  = 'Title 3';
    my $author1 = 'Author 1';
    my $author2 = 'Author 2';
    my $author3 = 'Author 3';

    $query = '
    INSERT INTO biblio
      (title, author)
    VALUES (?,?)';
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
      (biblionumber, itemtype, marcxml)
    VALUES (?,?,?)';
    $insert_sth = $dbh->prepare($query);
    $insert_sth->execute( $biblionumber1, 'Book',  '' );
    $insert_sth->execute( $biblionumber2, 'Music', '' );
    $insert_sth->execute( $biblionumber3, 'Book',  '' );

    $query = '
    SELECT biblioitemnumber
    FROM   biblioitems
    WHERE  biblionumber = ?';
    my $biblioitemnumber1 = $dbh->selectrow_array( $query, {}, $biblionumber1 );
    my $biblioitemnumber2 = $dbh->selectrow_array( $query, {}, $biblionumber2 );
    my $biblioitemnumber3 = $dbh->selectrow_array( $query, {}, $biblionumber3 );

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
    $insert_sth->execute( $biblionumber2, $biblioitemnumber2, $barcode2, 'Music' );
    $insert_sth->execute( $biblionumber3, $biblioitemnumber3, $barcode3, 'Book' );

    $query = '
    SELECT itemnumber
    FROM   items
    WHERE  barcode = ?';
    my $item_number1 = $dbh->selectrow_array( $query, {}, $barcode1 );
    my $item_number2 = $dbh->selectrow_array( $query, {}, $barcode2 );
    my $item_number3 = $dbh->selectrow_array( $query, {}, $barcode3 );

    # ---------- Add 2 auth_header
    $query = '
    INSERT INTO auth_header
      (authtypecode)
    VALUES (?)';
    $insert_sth = $dbh->prepare($query);
    $insert_sth->execute('authtypecode1');
    $insert_sth->execute('authtypecode2');

    $query = '
    SELECT authid
    FROM   auth_header
    WHERE  authtypecode = ?';
    my $authid1 = $dbh->selectrow_array( $query, {}, 'authtypecode1' );
    my $authid2 = $dbh->selectrow_array( $query, {}, 'authtypecode2' );

    # ---------- Add 1 old_issues
    $query = '
    INSERT INTO old_issues
      (borrowernumber, branchcode, itemnumber)
    VALUES (?,?,?)';
    $insert_sth = $dbh->prepare($query);
    $insert_sth->execute( $borrowernumber1, $branchcode, $item_number1 );

    $query = '
    SELECT issue_id
    FROM   old_issues
    WHERE  borrowernumber = ?';
    my $issue_id1 = $dbh->selectrow_array( $query, {}, $borrowernumber1 );

    # ---------- Add 1 old_reserves
    AddReserve( $branchcode, $borrowernumber1, $biblionumber1, 'a', '', 1, undef, undef, '', 'Title', undef, undef );
    my $reserves1   = GetReservesFromBiblionumber( { biblionumber => $biblionumber1 } );
    my $reserve_id1 = $reserves1->[0]->{reserve_id};
    my $reserve1    = CancelReserve( { reserve_id => $reserve_id1 } );

    # ---------- Add 1 biblio, 1 subscription and 1 aqorder
    my $builder = t::lib::TestBuilder->new();
    $builder->clear( { source => 'Aqorder' } );
    my $order1 = $builder->build(
        {   source  => 'Aqorder',
            value   => { datecancellationprinted => undef, },
            only_fk => 1,
        }
    );
    my $newordernumber = Koha::Acquisition::Order->new($order1)->insert->{ordernumber};
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
        AllowPkiAuth
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
        dontmerge
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
        BlockReturnOfWithdrawnItems
        CalculateFinesOnReturn
        AgeRestrictionOverride
        AllFinesNeedOverride
        AllowFineOverride
        AllowItemsOnHoldCheckout
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
        RefundLostItemFeeOnReturn
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
        AuthorisedValueImages
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
        OPACShowBarcode
        OPACShowCheckoutName
        OpacShowFiltersPulldownMobile
        OPACShowHoldQueueDetails
        OpacShowLibrariesPulldownMobile
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
        memberofinstitution
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
        StaffAuthorisedValueImages
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
        /
      ) {
        t::lib::Mocks::mock_preference( $_, $set_value );
    }
}

#Test if all systempreferences are at $value_to_test
sub verif_systempreferences_values {
    my $value_to_test = shift;

    is( $report->{systempreferences}->{AcqCreateItem},                       $value_to_test, "AcqCreateItem                      = $value_to_test" );
    is( $report->{systempreferences}->{AcqWarnOnDuplicateInvoice},           $value_to_test, "AcqWarnOnDuplicateInvoice          = $value_to_test" );
    is( $report->{systempreferences}->{AcqViewBaskets},                      $value_to_test, "AcqViewBaskets                     = $value_to_test" );
    is( $report->{systempreferences}->{BasketConfirmations},                 $value_to_test, "BasketConfirmations                = $value_to_test" );
    is( $report->{systempreferences}->{OrderPdfFormat},                      $value_to_test, "OrderPdfFormat                     = $value_to_test" );
    is( $report->{systempreferences}->{casAuthentication},                   $value_to_test, "casAuthentication                  = $value_to_test" );
    is( $report->{systempreferences}->{casLogout},                           $value_to_test, "casLogout                          = $value_to_test" );
    is( $report->{systempreferences}->{AllowPkiAuth},                        $value_to_test, "AllowPkiAuth                       = $value_to_test" );
    is( $report->{systempreferences}->{DebugLevel},                          $value_to_test, "DebugLevel                         = $value_to_test" );
    is( $report->{systempreferences}->{delimiter},                           $value_to_test, "delimiter                          = $value_to_test" );
    is( $report->{systempreferences}->{noItemTypeImages},                    $value_to_test, "noItemTypeImages                   = $value_to_test" );
    is( $report->{systempreferences}->{virtualshelves},                      $value_to_test, "virtualshelves                     = $value_to_test" );
    is( $report->{systempreferences}->{AutoLocation},                        $value_to_test, "AutoLocation                       = $value_to_test" );
    is( $report->{systempreferences}->{IndependentBranches},                 $value_to_test, "IndependentBranches                = $value_to_test" );
    is( $report->{systempreferences}->{SessionStorage},                      $value_to_test, "SessionStorage                     = $value_to_test" );
    is( $report->{systempreferences}->{Persona},                             $value_to_test, "Persona                            = $value_to_test" );
    is( $report->{systempreferences}->{AuthDisplayHierarchy},                $value_to_test, "AuthDisplayHierarchy               = $value_to_test" );
    is( $report->{systempreferences}->{AutoCreateAuthorities},               $value_to_test, "AutoCreateAuthorities              = $value_to_test" );
    is( $report->{systempreferences}->{BiblioAddsAuthorities},               $value_to_test, "BiblioAddsAuthorities              = $value_to_test" );
    is( $report->{systempreferences}->{dontmerge},                           $value_to_test, "dontmerge                          = $value_to_test" );
    is( $report->{systempreferences}->{UseAuthoritiesForTracings},           $value_to_test, "UseAuthoritiesForTracings          = $value_to_test" );
    is( $report->{systempreferences}->{CatalogModuleRelink},                 $value_to_test, "CatalogModuleRelink                = $value_to_test" );
    is( $report->{systempreferences}->{hide_marc},                           $value_to_test, "hide_marc                          = $value_to_test" );
    is( $report->{systempreferences}->{IntranetBiblioDefaultView},           $value_to_test, "IntranetBiblioDefaultView          = $value_to_test" );
    is( $report->{systempreferences}->{LabelMARCView},                       $value_to_test, "LabelMARCView                      = $value_to_test" );
    is( $report->{systempreferences}->{OpacSuppression},                     $value_to_test, "OpacSuppression                    = $value_to_test" );
    is( $report->{systempreferences}->{SeparateHoldings},                    $value_to_test, "SeparateHoldings                   = $value_to_test" );
    is( $report->{systempreferences}->{UseControlNumber},                    $value_to_test, "UseControlNumber                   = $value_to_test" );
    is( $report->{systempreferences}->{advancedMARCeditor},                  $value_to_test, "advancedMARCeditor                 = $value_to_test" );
    is( $report->{systempreferences}->{DefaultClassificationSource},         $value_to_test, "DefaultClassificationSource        = $value_to_test" );
    is( $report->{systempreferences}->{EasyAnalyticalRecords},               $value_to_test, "EasyAnalyticalRecords              = $value_to_test" );
    is( $report->{systempreferences}->{autoBarcode},                         $value_to_test, "autoBarcode                        = $value_to_test" );
    is( $report->{systempreferences}->{'item-level_itypes'},                 $value_to_test, "item-level_itypes                  = $value_to_test" );
    is( $report->{systempreferences}->{marcflavour},                         $value_to_test, "marcflavour                        = $value_to_test" );
    is( $report->{systempreferences}->{PrefillItem},                         $value_to_test, "PrefillItem                        = $value_to_test" );
    is( $report->{systempreferences}->{z3950NormalizeAuthor},                $value_to_test, "z3950NormalizeAuthor               = $value_to_test" );
    is( $report->{systempreferences}->{SpineLabelAutoPrint},                 $value_to_test, "SpineLabelAutoPrint                = $value_to_test" );
    is( $report->{systempreferences}->{SpineLabelShowPrintOnBibDetails},     $value_to_test, "SpineLabelShowPrintOnBibDetails    = $value_to_test" );
    is( $report->{systempreferences}->{BlockReturnOfWithdrawnItems},         $value_to_test, "BlockReturnOfWithdrawnItems        = $value_to_test" );
    is( $report->{systempreferences}->{CalculateFinesOnReturn},              $value_to_test, "CalculateFinesOnReturn             = $value_to_test" );
    is( $report->{systempreferences}->{AgeRestrictionOverride},              $value_to_test, "AgeRestrictionOverride             = $value_to_test" );
    is( $report->{systempreferences}->{AllFinesNeedOverride},                $value_to_test, "AllFinesNeedOverride               = $value_to_test" );
    is( $report->{systempreferences}->{AllowFineOverride},                   $value_to_test, "AllowFineOverride                  = $value_to_test" );
    is( $report->{systempreferences}->{AllowItemsOnHoldCheckout},            $value_to_test, "AllowItemsOnHoldCheckout           = $value_to_test" );
    is( $report->{systempreferences}->{AllowNotForLoanOverride},             $value_to_test, "AllowNotForLoanOverride            = $value_to_test" );
    is( $report->{systempreferences}->{AllowRenewalLimitOverride},           $value_to_test, "AllowRenewalLimitOverride          = $value_to_test" );
    is( $report->{systempreferences}->{AllowReturnToBranch},                 $value_to_test, "AllowReturnToBranch                = $value_to_test" );
    is( $report->{systempreferences}->{AllowTooManyOverride},                $value_to_test, "AllowTooManyOverride               = $value_to_test" );
    is( $report->{systempreferences}->{AutomaticItemReturn},                 $value_to_test, "AutomaticItemReturn                = $value_to_test" );
    is( $report->{systempreferences}->{AutoRemoveOverduesRestrictions},      $value_to_test, "AutoRemoveOverduesRestrictions     = $value_to_test" );
    is( $report->{systempreferences}->{CircControl},                         $value_to_test, "CircControl                        = $value_to_test" );
    is( $report->{systempreferences}->{HomeOrHoldingBranch},                 $value_to_test, "HomeOrHoldingBranch                = $value_to_test" );
    is( $report->{systempreferences}->{HomeOrHoldingBranchReturn},           $value_to_test, "HomeOrHoldingBranchReturn          = $value_to_test" );
    is( $report->{systempreferences}->{InProcessingToShelvingCart},          $value_to_test, "InProcessingToShelvingCart         = $value_to_test" );
    is( $report->{systempreferences}->{IssueLostItem},                       $value_to_test, "IssueLostItem                      = $value_to_test" );
    is( $report->{systempreferences}->{IssuingInProcess},                    $value_to_test, "IssuingInProcess                   = $value_to_test" );
    is( $report->{systempreferences}->{ManInvInNoissuesCharge},              $value_to_test, "ManInvInNoissuesCharge             = $value_to_test" );
    is( $report->{systempreferences}->{OverduesBlockCirc},                   $value_to_test, "OverduesBlockCirc                  = $value_to_test" );
    is( $report->{systempreferences}->{RenewalPeriodBase},                   $value_to_test, "RenewalPeriodBase                  = $value_to_test" );
    is( $report->{systempreferences}->{RenewalSendNotice},                   $value_to_test, "RenewalSendNotice                  = $value_to_test" );
    is( $report->{systempreferences}->{RentalsInNoissuesCharge},             $value_to_test, "RentalsInNoissuesCharge            = $value_to_test" );
    is( $report->{systempreferences}->{ReturnBeforeExpiry},                  $value_to_test, "ReturnBeforeExpiry                 = $value_to_test" );
    is( $report->{systempreferences}->{ReturnToShelvingCart},                $value_to_test, "ReturnToShelvingCart               = $value_to_test" );
    is( $report->{systempreferences}->{TransfersMaxDaysWarning},             $value_to_test, "TransfersMaxDaysWarning            = $value_to_test" );
    is( $report->{systempreferences}->{UseBranchTransferLimits},             $value_to_test, "UseBranchTransferLimits            = $value_to_test" );
    is( $report->{systempreferences}->{useDaysMode},                         $value_to_test, "useDaysMode                        = $value_to_test" );
    is( $report->{systempreferences}->{UseTransportCostMatrix},              $value_to_test, "UseTransportCostMatrix             = $value_to_test" );
    is( $report->{systempreferences}->{UseCourseReserves},                   $value_to_test, "UseCourseReserves                  = $value_to_test" );
    is( $report->{systempreferences}->{finesCalendar},                       $value_to_test, "finesCalendar                      = $value_to_test" );
    is( $report->{systempreferences}->{FinesIncludeGracePeriod},             $value_to_test, "FinesIncludeGracePeriod            = $value_to_test" );
    is( $report->{systempreferences}->{finesMode},                           $value_to_test, "finesMode                          = $value_to_test" );
    is( $report->{systempreferences}->{RefundLostItemFeeOnReturn},           $value_to_test, "RefundLostItemFeeOnReturn          = $value_to_test" );
    is( $report->{systempreferences}->{WhenLostChargeReplacementFee},        $value_to_test, "WhenLostChargeReplacementFee       = $value_to_test" );
    is( $report->{systempreferences}->{WhenLostForgiveFine},                 $value_to_test, "WhenLostForgiveFine                = $value_to_test" );
    is( $report->{systempreferences}->{AllowHoldDateInFuture},               $value_to_test, "AllowHoldDateInFuture              = $value_to_test" );
    is( $report->{systempreferences}->{AllowHoldPolicyOverride},             $value_to_test, "AllowHoldPolicyOverride            = $value_to_test" );
    is( $report->{systempreferences}->{AllowHoldsOnDamagedItems},            $value_to_test, "AllowHoldsOnDamagedItems           = $value_to_test" );
    is( $report->{systempreferences}->{AllowHoldsOnPatronsPossessions},      $value_to_test, "AllowHoldsOnPatronsPossessions     = $value_to_test" );
    is( $report->{systempreferences}->{AutoResumeSuspendedHolds},            $value_to_test, "AutoResumeSuspendedHolds           = $value_to_test" );
    is( $report->{systempreferences}->{canreservefromotherbranches},         $value_to_test, "canreservefromotherbranches        = $value_to_test" );
    is( $report->{systempreferences}->{decreaseLoanHighHolds},               $value_to_test, "decreaseLoanHighHolds              = $value_to_test" );
    is( $report->{systempreferences}->{DisplayMultiPlaceHold},               $value_to_test, "DisplayMultiPlaceHold              = $value_to_test" );
    is( $report->{systempreferences}->{emailLibrarianWhenHoldIsPlaced},      $value_to_test, "emailLibrarianWhenHoldIsPlaced     = $value_to_test" );
    is( $report->{systempreferences}->{ExpireReservesMaxPickUpDelay},        $value_to_test, "ExpireReservesMaxPickUpDelay       = $value_to_test" );
    is( $report->{systempreferences}->{OPACAllowHoldDateInFuture},           $value_to_test, "OPACAllowHoldDateInFuture          = $value_to_test" );
    is( $report->{systempreferences}->{OPACAllowUserToChooseBranch},         $value_to_test, "OPACAllowUserToChooseBranch        = $value_to_test" );
    is( $report->{systempreferences}->{ReservesControlBranch},               $value_to_test, "ReservesControlBranch              = $value_to_test" );
    is( $report->{systempreferences}->{ReservesNeedReturns},                 $value_to_test, "ReservesNeedReturns                = $value_to_test" );
    is( $report->{systempreferences}->{SuspendHoldsIntranet},                $value_to_test, "SuspendHoldsIntranet               = $value_to_test" );
    is( $report->{systempreferences}->{SuspendHoldsOpac},                    $value_to_test, "SuspendHoldsOpac                   = $value_to_test" );
    is( $report->{systempreferences}->{TransferWhenCancelAllWaitingHolds},   $value_to_test, "TransferWhenCancelAllWaitingHolds  = $value_to_test" );
    is( $report->{systempreferences}->{AllowAllMessageDeletion},             $value_to_test, "AllowAllMessageDeletion            = $value_to_test" );
    is( $report->{systempreferences}->{AllowOfflineCirculation},             $value_to_test, "AllowOfflineCirculation            = $value_to_test" );
    is( $report->{systempreferences}->{CircAutocompl},                       $value_to_test, "CircAutocompl                      = $value_to_test" );
    is( $report->{systempreferences}->{CircAutoPrintQuickSlip},              $value_to_test, "CircAutoPrintQuickSlip             = $value_to_test" );
    is( $report->{systempreferences}->{DisplayClearScreenButton},            $value_to_test, "DisplayClearScreenButton           = $value_to_test" );
    is( $report->{systempreferences}->{FilterBeforeOverdueReport},           $value_to_test, "FilterBeforeOverdueReport          = $value_to_test" );
    is( $report->{systempreferences}->{FineNotifyAtCheckin},                 $value_to_test, "FineNotifyAtCheckin                = $value_to_test" );
    is( $report->{systempreferences}->{itemBarcodeFallbackSearch},           $value_to_test, "itemBarcodeFallbackSearch          = $value_to_test" );
    is( $report->{systempreferences}->{itemBarcodeInputFilter},              $value_to_test, "itemBarcodeInputFilter             = $value_to_test" );
    is( $report->{systempreferences}->{previousIssuesDefaultSortOrder},      $value_to_test, "previousIssuesDefaultSortOrder     = $value_to_test" );
    is( $report->{systempreferences}->{RecordLocalUseOnReturn},              $value_to_test, "RecordLocalUseOnReturn             = $value_to_test" );
    is( $report->{systempreferences}->{soundon},                             $value_to_test, "soundon                            = $value_to_test" );
    is( $report->{systempreferences}->{SpecifyDueDate},                      $value_to_test, "SpecifyDueDate                     = $value_to_test" );
    is( $report->{systempreferences}->{todaysIssuesDefaultSortOrder},        $value_to_test, "todaysIssuesDefaultSortOrder       = $value_to_test" );
    is( $report->{systempreferences}->{UpdateTotalIssuesOnCirc},             $value_to_test, "UpdateTotalIssuesOnCirc            = $value_to_test" );
    is( $report->{systempreferences}->{UseTablesortForCirc},                 $value_to_test, "UseTablesortForCirc                = $value_to_test" );
    is( $report->{systempreferences}->{WaitingNotifyAtCheckin},              $value_to_test, "WaitingNotifyAtCheckin             = $value_to_test" );
    is( $report->{systempreferences}->{AllowSelfCheckReturns},               $value_to_test, "AllowSelfCheckReturns              = $value_to_test" );
    is( $report->{systempreferences}->{AutoSelfCheckAllowed},                $value_to_test, "AutoSelfCheckAllowed               = $value_to_test" );
    is( $report->{systempreferences}->{FRBRizeEditions},                     $value_to_test, "FRBRizeEditions                    = $value_to_test" );
    is( $report->{systempreferences}->{OPACFRBRizeEditions},                 $value_to_test, "OPACFRBRizeEditions                = $value_to_test" );
    is( $report->{systempreferences}->{AmazonCoverImages},                   $value_to_test, "AmazonCoverImages                  = $value_to_test" );
    is( $report->{systempreferences}->{OPACAmazonCoverImages},               $value_to_test, "OPACAmazonCoverImages              = $value_to_test" );
    is( $report->{systempreferences}->{Babeltheque},                         $value_to_test, "Babeltheque                        = $value_to_test" );
    is( $report->{systempreferences}->{BakerTaylorEnabled},                  $value_to_test, "BakerTaylorEnabled                 = $value_to_test" );
    is( $report->{systempreferences}->{GoogleJackets},                       $value_to_test, "GoogleJackets                      = $value_to_test" );
    is( $report->{systempreferences}->{HTML5MediaEnabled},                   $value_to_test, "HTML5MediaEnabled                  = $value_to_test" );
    is( $report->{systempreferences}->{IDreamBooksReadometer},               $value_to_test, "IDreamBooksReadometer              = $value_to_test" );
    is( $report->{systempreferences}->{IDreamBooksResults},                  $value_to_test, "IDreamBooksResults                 = $value_to_test" );
    is( $report->{systempreferences}->{IDreamBooksReviews},                  $value_to_test, "IDreamBooksReviews                 = $value_to_test" );
    is( $report->{systempreferences}->{LibraryThingForLibrariesEnabled},     $value_to_test, "LibraryThingForLibrariesEnabled    = $value_to_test" );
    is( $report->{systempreferences}->{LocalCoverImages},                    $value_to_test, "LocalCoverImages                   = $value_to_test" );
    is( $report->{systempreferences}->{OPACLocalCoverImages},                $value_to_test, "OPACLocalCoverImages               = $value_to_test" );
    is( $report->{systempreferences}->{NovelistSelectEnabled},               $value_to_test, "NovelistSelectEnabled              = $value_to_test" );
    is( $report->{systempreferences}->{XISBN},                               $value_to_test, "XISBN                              = $value_to_test" );
    is( $report->{systempreferences}->{OpenLibraryCovers},                   $value_to_test, "OpenLibraryCovers                  = $value_to_test" );
    is( $report->{systempreferences}->{UseKohaPlugins},                      $value_to_test, "UseKohaPlugins                     = $value_to_test" );
    is( $report->{systempreferences}->{SyndeticsEnabled},                    $value_to_test, "SyndeticsEnabled                   = $value_to_test" );
    is( $report->{systempreferences}->{TagsEnabled},                         $value_to_test, "TagsEnabled                        = $value_to_test" );
    is( $report->{systempreferences}->{CalendarFirstDayOfWeek},              $value_to_test, "CalendarFirstDayOfWeek             = $value_to_test" );
    is( $report->{systempreferences}->{opaclanguagesdisplay},                $value_to_test, "opaclanguagesdisplay               = $value_to_test" );
    is( $report->{systempreferences}->{AuthoritiesLog},                      $value_to_test, "AuthoritiesLog                     = $value_to_test" );
    is( $report->{systempreferences}->{BorrowersLog},                        $value_to_test, "BorrowersLog                       = $value_to_test" );
    is( $report->{systempreferences}->{CataloguingLog},                      $value_to_test, "CataloguingLog                     = $value_to_test" );
    is( $report->{systempreferences}->{FinesLog},                            $value_to_test, "FinesLog                           = $value_to_test" );
    is( $report->{systempreferences}->{IssueLog},                            $value_to_test, "IssueLog                           = $value_to_test" );
    is( $report->{systempreferences}->{LetterLog},                           $value_to_test, "LetterLog                          = $value_to_test" );
    is( $report->{systempreferences}->{ReturnLog},                           $value_to_test, "ReturnLog                          = $value_to_test" );
    is( $report->{systempreferences}->{SubscriptionLog},                     $value_to_test, "SubscriptionLog                    = $value_to_test" );
    is( $report->{systempreferences}->{AuthorisedValueImages},               $value_to_test, "AuthorisedValueImages              = $value_to_test" );
    is( $report->{systempreferences}->{BiblioDefaultView},                   $value_to_test, "BiblioDefaultView                  = $value_to_test" );
    is( $report->{systempreferences}->{COinSinOPACResults},                  $value_to_test, "COinSinOPACResults                 = $value_to_test" );
    is( $report->{systempreferences}->{DisplayOPACiconsXSLT},                $value_to_test, "DisplayOPACiconsXSLT               = $value_to_test" );
    is( $report->{systempreferences}->{hidelostitems},                       $value_to_test, "hidelostitems                      = $value_to_test" );
    is( $report->{systempreferences}->{HighlightOwnItemsOnOPAC},             $value_to_test, "HighlightOwnItemsOnOPAC            = $value_to_test" );
    is( $report->{systempreferences}->{OpacAddMastheadLibraryPulldown},      $value_to_test, "OpacAddMastheadLibraryPulldown     = $value_to_test" );
    is( $report->{systempreferences}->{OPACDisplay856uAsImage},              $value_to_test, "OPACDisplay856uAsImage             = $value_to_test" );
    is( $report->{systempreferences}->{OpacHighlightedWords},                $value_to_test, "OpacHighlightedWords               = $value_to_test" );
    is( $report->{systempreferences}->{OpacKohaUrl},                         $value_to_test, "OpacKohaUrl                        = $value_to_test" );
    is( $report->{systempreferences}->{OpacMaintenance},                     $value_to_test, "OpacMaintenance                    = $value_to_test" );
    is( $report->{systempreferences}->{OpacPublic},                          $value_to_test, "OpacPublic                         = $value_to_test" );
    is( $report->{systempreferences}->{OpacSeparateHoldings},                $value_to_test, "OpacSeparateHoldings               = $value_to_test" );
    is( $report->{systempreferences}->{OPACShowBarcode},                     $value_to_test, "OPACShowBarcode                    = $value_to_test" );
    is( $report->{systempreferences}->{OPACShowCheckoutName},                $value_to_test, "OPACShowCheckoutName               = $value_to_test" );
    is( $report->{systempreferences}->{OpacShowFiltersPulldownMobile},       $value_to_test, "OpacShowFiltersPulldownMobile      = $value_to_test" );
    is( $report->{systempreferences}->{OPACShowHoldQueueDetails},            $value_to_test, "OPACShowHoldQueueDetails           = $value_to_test" );
    is( $report->{systempreferences}->{OpacShowLibrariesPulldownMobile},     $value_to_test, "OpacShowLibrariesPulldownMobile    = $value_to_test" );
    is( $report->{systempreferences}->{OpacShowRecentComments},              $value_to_test, "OpacShowRecentComments             = $value_to_test" );
    is( $report->{systempreferences}->{OPACShowUnusedAuthorities},           $value_to_test, "OPACShowUnusedAuthorities          = $value_to_test" );
    is( $report->{systempreferences}->{OpacStarRatings},                     $value_to_test, "OpacStarRatings                    = $value_to_test" );
    is( $report->{systempreferences}->{opacthemes},                          $value_to_test, "opacthemes                         = $value_to_test" );
    is( $report->{systempreferences}->{OPACURLOpenInNewWindow},              $value_to_test, "OPACURLOpenInNewWindow             = $value_to_test" );
    is( $report->{systempreferences}->{OpacAuthorities},                     $value_to_test, "OpacAuthorities                    = $value_to_test" );
    is( $report->{systempreferences}->{opacbookbag},                         $value_to_test, "opacbookbag                        = $value_to_test" );
    is( $report->{systempreferences}->{OpacBrowser},                         $value_to_test, "OpacBrowser                        = $value_to_test" );
    is( $report->{systempreferences}->{OpacBrowseResults},                   $value_to_test, "OpacBrowseResults                  = $value_to_test" );
    is( $report->{systempreferences}->{OpacCloud},                           $value_to_test, "OpacCloud                          = $value_to_test" );
    is( $report->{systempreferences}->{OPACFinesTab},                        $value_to_test, "OPACFinesTab                       = $value_to_test" );
    is( $report->{systempreferences}->{OpacHoldNotes},                       $value_to_test, "OpacHoldNotes                      = $value_to_test" );
    is( $report->{systempreferences}->{OpacItemLocation},                    $value_to_test, "OpacItemLocation                   = $value_to_test" );
    is( $report->{systempreferences}->{OpacPasswordChange},                  $value_to_test, "OpacPasswordChange                 = $value_to_test" );
    is( $report->{systempreferences}->{OPACPatronDetails},                   $value_to_test, "OPACPatronDetails                  = $value_to_test" );
    is( $report->{systempreferences}->{OPACpatronimages},                    $value_to_test, "OPACpatronimages                   = $value_to_test" );
    is( $report->{systempreferences}->{OPACPopupAuthorsSearch},              $value_to_test, "OPACPopupAuthorsSearch             = $value_to_test" );
    is( $report->{systempreferences}->{OpacTopissue},                        $value_to_test, "OpacTopissue                       = $value_to_test" );
    is( $report->{systempreferences}->{opacuserlogin},                       $value_to_test, "opacuserlogin                      = $value_to_test" );
    is( $report->{systempreferences}->{QuoteOfTheDay},                       $value_to_test, "QuoteOfTheDay                      = $value_to_test" );
    is( $report->{systempreferences}->{RequestOnOpac},                       $value_to_test, "RequestOnOpac                      = $value_to_test" );
    is( $report->{systempreferences}->{reviewson},                           $value_to_test, "reviewson                          = $value_to_test" );
    is( $report->{systempreferences}->{ShowReviewer},                        $value_to_test, "ShowReviewer                       = $value_to_test" );
    is( $report->{systempreferences}->{ShowReviewerPhoto},                   $value_to_test, "ShowReviewerPhoto                  = $value_to_test" );
    is( $report->{systempreferences}->{SocialNetworks},                      $value_to_test, "SocialNetworks                     = $value_to_test" );
    is( $report->{systempreferences}->{suggestion},                          $value_to_test, "suggestion                         = $value_to_test" );
    is( $report->{systempreferences}->{AllowPurchaseSuggestionBranchChoice}, $value_to_test, "AllowPurchaseSuggestionBranchChoice= $value_to_test" );
    is( $report->{systempreferences}->{OpacAllowPublicListCreation},         $value_to_test, "OpacAllowPublicListCreation        = $value_to_test" );
    is( $report->{systempreferences}->{OpacAllowSharingPrivateLists},        $value_to_test, "OpacAllowSharingPrivateLists       = $value_to_test" );
    is( $report->{systempreferences}->{OpacRenewalAllowed},                  $value_to_test, "OpacRenewalAllowed                 = $value_to_test" );
    is( $report->{systempreferences}->{OpacRenewalBranch},                   $value_to_test, "OpacRenewalBranch                  = $value_to_test" );
    is( $report->{systempreferences}->{OPACViewOthersSuggestions},           $value_to_test, "OPACViewOthersSuggestions          = $value_to_test" );
    is( $report->{systempreferences}->{SearchMyLibraryFirst},                $value_to_test, "SearchMyLibraryFirst               = $value_to_test" );
    is( $report->{systempreferences}->{singleBranchMode},                    $value_to_test, "singleBranchMode                   = $value_to_test" );
    is( $report->{systempreferences}->{AnonSuggestions},                     $value_to_test, "AnonSuggestions                    = $value_to_test" );
    is( $report->{systempreferences}->{EnableOpacSearchHistory},             $value_to_test, "EnableOpacSearchHistory            = $value_to_test" );
    is( $report->{systempreferences}->{OPACPrivacy},                         $value_to_test, "OPACPrivacy                        = $value_to_test" );
    is( $report->{systempreferences}->{opacreadinghistory},                  $value_to_test, "opacreadinghistory                 = $value_to_test" );
    is( $report->{systempreferences}->{TrackClicks},                         $value_to_test, "TrackClicks                        = $value_to_test" );
    is( $report->{systempreferences}->{PatronSelfRegistration},              $value_to_test, "PatronSelfRegistration             = $value_to_test" );
    is( $report->{systempreferences}->{OPACShelfBrowser},                    $value_to_test, "OPACShelfBrowser                   = $value_to_test" );
    is( $report->{systempreferences}->{AutoEmailOpacUser},                   $value_to_test, "AutoEmailOpacUser                  = $value_to_test" );
    is( $report->{systempreferences}->{AutoEmailPrimaryAddress},             $value_to_test, "AutoEmailPrimaryAddress            = $value_to_test" );
    is( $report->{systempreferences}->{autoMemberNum},                       $value_to_test, "autoMemberNum                      = $value_to_test" );
    is( $report->{systempreferences}->{BorrowerRenewalPeriodBase},           $value_to_test, "BorrowerRenewalPeriodBase          = $value_to_test" );
    is( $report->{systempreferences}->{checkdigit},                          $value_to_test, "checkdigit                         = $value_to_test" );
    is( $report->{systempreferences}->{EnableBorrowerFiles},                 $value_to_test, "EnableBorrowerFiles                = $value_to_test" );
    is( $report->{systempreferences}->{EnhancedMessagingPreferences},        $value_to_test, "EnhancedMessagingPreferences       = $value_to_test" );
    is( $report->{systempreferences}->{ExtendedPatronAttributes},            $value_to_test, "ExtendedPatronAttributes           = $value_to_test" );
    is( $report->{systempreferences}->{intranetreadinghistory},              $value_to_test, "intranetreadinghistory             = $value_to_test" );
    is( $report->{systempreferences}->{memberofinstitution},                 $value_to_test, "memberofinstitution                = $value_to_test" );
    is( $report->{systempreferences}->{patronimages},                        $value_to_test, "patronimages                       = $value_to_test" );
    is( $report->{systempreferences}->{TalkingTechItivaPhoneNotification},   $value_to_test, "TalkingTechItivaPhoneNotification  = $value_to_test" );
    is( $report->{systempreferences}->{uppercasesurnames},                   $value_to_test, "uppercasesurnames                  = $value_to_test" );
    is( $report->{systempreferences}->{IncludeSeeFromInSearches},            $value_to_test, "IncludeSeeFromInSearches           = $value_to_test" );
    is( $report->{systempreferences}->{OpacGroupResults},                    $value_to_test, "OpacGroupResults                   = $value_to_test" );
    is( $report->{systempreferences}->{QueryAutoTruncate},                   $value_to_test, "QueryAutoTruncate                  = $value_to_test" );
    is( $report->{systempreferences}->{QueryFuzzy},                          $value_to_test, "QueryFuzzy                         = $value_to_test" );
    is( $report->{systempreferences}->{QueryStemming},                       $value_to_test, "QueryStemming                      = $value_to_test" );
    is( $report->{systempreferences}->{QueryWeightFields},                   $value_to_test, "QueryWeightFields                  = $value_to_test" );
    is( $report->{systempreferences}->{TraceCompleteSubfields},              $value_to_test, "TraceCompleteSubfields             = $value_to_test" );
    is( $report->{systempreferences}->{TraceSubjectSubdivisions},            $value_to_test, "TraceSubjectSubdivisions           = $value_to_test" );
    is( $report->{systempreferences}->{UseICU},                              $value_to_test, "UseICU                             = $value_to_test" );
    is( $report->{systempreferences}->{UseQueryParser},                      $value_to_test, "UseQueryParser                     = $value_to_test" );
    is( $report->{systempreferences}->{defaultSortField},                    $value_to_test, "defaultSortField                   = $value_to_test" );
    is( $report->{systempreferences}->{displayFacetCount},                   $value_to_test, "displayFacetCount                  = $value_to_test" );
    is( $report->{systempreferences}->{OPACdefaultSortField},                $value_to_test, "OPACdefaultSortField               = $value_to_test" );
    is( $report->{systempreferences}->{OPACItemsResultsDisplay},             $value_to_test, "OPACItemsResultsDisplay            = $value_to_test" );
    is( $report->{systempreferences}->{expandedSearchOption},                $value_to_test, "expandedSearchOption               = $value_to_test" );
    is( $report->{systempreferences}->{IntranetNumbersPreferPhrase},         $value_to_test, "IntranetNumbersPreferPhrase        = $value_to_test" );
    is( $report->{systempreferences}->{OPACNumbersPreferPhrase},             $value_to_test, "OPACNumbersPreferPhrase            = $value_to_test" );
    is( $report->{systempreferences}->{opacSerialDefaultTab},                $value_to_test, "opacSerialDefaultTab               = $value_to_test" );
    is( $report->{systempreferences}->{RenewSerialAddsSuggestion},           $value_to_test, "RenewSerialAddsSuggestion          = $value_to_test" );
    is( $report->{systempreferences}->{RoutingListAddReserves},              $value_to_test, "RoutingListAddReserves             = $value_to_test" );
    is( $report->{systempreferences}->{RoutingSerials},                      $value_to_test, "RoutingSerials                     = $value_to_test" );
    is( $report->{systempreferences}->{SubscriptionHistory},                 $value_to_test, "SubscriptionHistory                = $value_to_test" );
    is( $report->{systempreferences}->{Display856uAsImage},                  $value_to_test, "Display856uAsImage                 = $value_to_test" );
    is( $report->{systempreferences}->{DisplayIconsXSLT},                    $value_to_test, "DisplayIconsXSLT                   = $value_to_test" );
    is( $report->{systempreferences}->{StaffAuthorisedValueImages},          $value_to_test, "StaffAuthorisedValueImages         = $value_to_test" );
    is( $report->{systempreferences}->{template},                            $value_to_test, "template                           = $value_to_test" );
    is( $report->{systempreferences}->{yuipath},                             $value_to_test, "yuipath                            = $value_to_test" );
    is( $report->{systempreferences}->{HidePatronName},                      $value_to_test, "HidePatronName                     = $value_to_test" );
    is( $report->{systempreferences}->{intranetbookbag},                     $value_to_test, "intranetbookbag                    = $value_to_test" );
    is( $report->{systempreferences}->{StaffDetailItemSelection},            $value_to_test, "StaffDetailItemSelection           = $value_to_test" );
    is( $report->{systempreferences}->{viewISBD},                            $value_to_test, "viewISBD                           = $value_to_test" );
    is( $report->{systempreferences}->{viewLabeledMARC},                     $value_to_test, "viewLabeledMARC                    = $value_to_test" );
    is( $report->{systempreferences}->{viewMARC},                            $value_to_test, "viewMARC                           = $value_to_test" );
    is( $report->{systempreferences}->{'ILS-DI'},                            $value_to_test, "ILS-DI                             = $value_to_test" );
    is( $report->{systempreferences}->{'OAI-PMH'},                           $value_to_test, "OAI-PMH                            = $value_to_test" );
    is( $report->{systempreferences}->{version},                             $value_to_test, "version                            = $value_to_test" );
}

$dbh->rollback;
