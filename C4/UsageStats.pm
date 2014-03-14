package UsageStats;

# Copyright 2000-2003 Katipo Communications
# Copyright 2010 BibLibre
# Parts Copyright 2010 Catalyst IT
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
use C4::Context;
use POSIX qw(strftime);
use LWP::UserAgent;
use JSON;

=head1 NAME C4::UsageStats

=head1 DESCRIPTION

This package contains what is needed to report Koha statistics to hea
hea.koha-community.org is the server that centralize Koha setups informations
Koha libraries are encouraged to provide informations about their collections,
their structure,...

This package is normally only called by a cronjob, like
0 3 1 * * export KOHA_CONF=/home/koha/etc/koha-conf.xml; export PERL5LIB=/home/koha/src; perl /home/koha/src/C4/UsageStats.pm

IMPORTANT : please do NOT run the cron on the 1st, but on another day. The idea is to avoid all
Koha libraries sending their data at the same time ! So choose any day between 1 and 28 !


=head2 NeedUpdate

  $needUpdateYN = C4::UsageStats::NeedUpdate;

Returns Y (1) if the last update is more than 1 month old
This way, even if the cronjob is run every minute, the webservice will be called
only once a month !

=cut

sub NeedUpdate {
    my $lastupdated = C4::Context->preference('UsageStatsLastUpdateTime') || 0;
    my $now = strftime("%s", localtime);

    # Need to launch cron.
    return 1 if $now - $lastupdated >= 2592000;

    # Cron no need to be launched.
    return 0;
}

=head2 LaunchCron

  LaunchCron();

Compute results and send them to the centralized server

=cut

sub LaunchCron {
    if (!C4::Context->preference('UsageStatsShare')) {
      die ("UsageStats is not configured");
    }
    if (NeedUpdate) {
        C4::Context->set_preference('UsageStatsLastUpdateTime', strftime("%s", localtime));
        my $data = BuildReport();
        ReportToCommunity($data);
    }
}

=head2 Builreport

  BuildReport();

retrieve some database volumety and systempreferences that will be sent to hea server

=cut

sub BuildReport {
    my $report = {
        'library' => {
            'name' => C4::Context->preference('UsageStatsLibraryName'),
            'id' => C4::Context->preference('UsageStatsID') || 0,
        },
    };

    # Get database volumetry.
    foreach (qw/biblio auth_header old_issues old_reserves borrowers aqorders subscription/) {
        $report->{volumetry}{$_} = _count($_);
    }

    # Get systempreferences.
    foreach (qw/ AcqCreateItem
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
 AllowOnShelfHolds
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
 OPACItemHolds
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
 AddPatronLists
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
 version/) {
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
    my $json = to_json($data);

    my $ua = LWP::UserAgent->new;
    my $req = HTTP::Request->new(POST => "http://hea.koha-community.org/upload.pl");
    $req->content_type('application/x-www-form-urlencoded');
    $req->content("data=$json");
    my $res = $ua->request($req);
    my $content = from_json($res->decoded_content);
    C4::Context->set_preference('UsageStatsID', $content->{library}{library_id});
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

&LaunchCron;
1;
