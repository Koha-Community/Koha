package C4::UsageStats;

# This file is part of Koha.
#
# Copyright 2014 BibLibre
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use C4::Context;
use POSIX qw(strftime);
use LWP::UserAgent;
use JSON;

use Koha::Libraries;

=head1 NAME

C4::UsageStats

=head1 DESCRIPTION

This package contains what is needed to report Koha statistics to hea
hea.koha-community.org is the server that centralize Koha setups informations
Koha libraries are encouraged to provide informations about their collections,
their structure,...

=head2 NeedUpdate

  $needUpdateYN = C4::UsageStats::NeedUpdate;

Returns Y (1) if the last update is more than 1 month old
This way, even if the cronjob is run every minute, the webservice will be called
only once a month !

=cut

sub NeedUpdate {
    my $lastupdated = C4::Context->preference('UsageStatsLastUpdateTime') || 0;
    my $now = strftime( "%s", localtime );

    # Need to launch cron.
    return 1 if $now - $lastupdated >= 2592000;

    # Data don't need to be updated
    return 0;
}

sub BuildReport {
    my $report;
    my @libraries;
    if( C4::Context->preference('UsageStatsLibrariesInfo') ) {
        my $libraries = Koha::Libraries->search;
        while ( my $library = $libraries->next ) {
            push @libraries, { name => $library->branchname, url => $library->branchurl, country => $library->branchcountry, geolocation => $library->geolocation, };
        }
    }
    $report = {
        installation => {
            koha_id => C4::Context->preference('UsageStatsID')          || 0,
            name    => C4::Context->preference('UsageStatsLibraryName') || q||,
            url     => C4::Context->preference('UsageStatsLibraryUrl')  || q||,
            type    => C4::Context->preference('UsageStatsLibraryType') || q||,
            country => C4::Context->preference('UsageStatsCountry')     || q||,
            geolocation => C4::Context->preference('UsageStatsGeolocation') || q||,
        },
        libraries => \@libraries,
    };

    # Get database volumetry.
    foreach (
        qw/biblio items auth_header old_issues old_reserves borrowers aqorders subscription/
      )
    {
        $report->{volumetry}{$_} = _count($_);
    }

    # Get systempreferences.
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
        AudioAlerts
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
        /
      )
    {
        $report->{systempreferences}{$_} = C4::Context->preference($_);
    }
    return $report;
}

=head2 ReportToCommunity

  ReportToCommunity;

Send to hea.koha-community.org database informations

=cut

sub ReportToCommunity {
    my $data = shift;
    my $json = encode_json($data);

    my $url = "https://hea.koha-community.org/upload.pl";
    my $ua = LWP::UserAgent->new;
    my $res = $ua->post(
        $url,
        'Content-type' => 'application/json;charset=utf-8',
        Content => $json,
    );
    my $content = decode_json( $res->decoded_content );
    if ( $content->{koha_id} ) {
        C4::Context->set_preference( 'UsageStatsID', $content->{koha_id} );
    }
    if ( $content->{id} ) {
        C4::Context->set_preference( 'UsageStatsPublicID', $content->{id} );
    }
}

=head2 _count

  $data = _count($table);

Count the number of records in $table tables

=cut

sub _count {
    my $table = shift;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT count(*) from $table");
    $sth->execute;
    return $sth->fetchrow_array;
}

1;
