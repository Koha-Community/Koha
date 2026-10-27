# RELEASE NOTES FOR KOHA 25.11.10
27 Oct 2026

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 25.11.10 can be downloaded from:

- [Download](https://download.koha-community.org/koha-25.11.10.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 25.11.10 is a bugfix/maintenance release with security patches.

It includes 4 enhancements, 51 bugfixes (4  security).

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [42946](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42946) [CVE-2026-16031] Time-based Blind SQL Injection in itemsearch.pl functionality
- [43429](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43429) Stored XSS via OPAC Report a Problem executes in staff/intranet security context (8.7 HIGH)
- [43634](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43634) cancelBulk in waitingreserves.pl is not protected against CSRF attacks
- [43707](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43707) Fix stored XSS in DT's column filters in staff interface

## Bugfixes

### About

#### Other bugs fixed

- [43177](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43177) Use archived link for Bridge Material Type Icon Set
  >This updates the link for About Koha > Licenses > Bridge Material Type Icon Set. It now goes to an Internet Archive page with information (including the license), as the original page is no longer available.

  **Sponsored by** *Athens County Public Libraries*

### Acquisitions

#### Other bugs fixed

- [42827](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42827) Items expected column in parcels.pl always displays 0

### Architecture, internals, and plumbing

#### Critical bugs fixed

- [42992](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42992) FTP file transport list_files() corrupts filenames

#### Other bugs fixed

- [41681](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41681) bulkmarcimport.pl reports an incorrect number of MARC records processed
- [43078](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43078) File transport SFTP backend returns inconsistent list() structure compared to FTP/Local backends
- [43101](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43101) search_for_data_inconsistencies.pl creates a query that ORs every biblionumber in the catalog
  >This fixes the search for data inconsistencies script (misc/maintenance/search_for_data_inconsistencies.pl) so that it now runs significantly faster - it replaces OR with IN for subqueries.
  >
  >Technical details:
  >
  >1. Queries that use OR instead of IN are less efficient and can lead to situations where the query takes a very long time to complete due to row level scanning. Example: We found one instance where they query had been running for over 10 days!
  >
  >2. This fix makes ids() return a subquery instead of a list of results, and switches the callers to using IN. The database now resolves the set itself and the queries stay a constant size no matter how large the catalog is. This is super efficient because the subquery doesn't even execute as a separate query since biblionumber is the primary key!
- [43159](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43159) Regression to @INC handling by bug 39740 undoing bug 25778
- [43168](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43168) Incorrect error output when staging a file

### Cataloging

#### Other bugs fixed

- [35729](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35729) Koha needs to handle ISBNs starting with 979 for cover images

  **Sponsored by** *Horowhenua Libraries Trust*
- [42166](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42166) Cannot Edit as new (duplicate) a record without a 008 in the advanced editor
- [43206](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43206) cn_browser plugin red background on exact match is hard to read

  **Sponsored by** *Athens County Public Libraries*

### Circulation

#### Other bugs fixed

- [36762](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36762) Item not transferred correctly when there is a pending hold
  >This fixes two issues when transferring an item that could fill a pending hold to a library that is not the holds pickup library:
  >1. Koha only gives you an option to transfer the item to the pickup library. When this option is chosen, Koha says that item is being transferred to the selected library, not to the pickup library. Then it fails to create the transfer.
  >2. Adds a new option ("Ignore hold and transfer to [Library name]") to ignore the hold and transfer the item to the library selected in the transfer tool.

  **Sponsored by** *Koha-Suomi Oy*
- [42565](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42565) GetIssuingCharges returns undef when rentalcharge is NULL
- [43119](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43119) Checkout and hold action logs are not displayed correctly

### Command-line Utilities

#### Other bugs fixed

- [42298](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42298) "No automatic renewal before" falls back to "No renewal before" if former is greater than the latter
- [42861](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42861) System warning about missing encryption_key on a fresh instance
  >This fixes the koha-create command so that it generates the random encryption key required for passwords and sensitive data.
  >
  >It uses pwgen with the number of characters set to 32, and adds the <encryption_key> entry to the instance's koha-conf.xml file.

### ERM

#### Other bugs fixed

- [42522](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42522) Holdings created in ERM with a linked bibliographic record do not show the link to the record
- [42981](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42981) ERM package result list hangs when filtering by vendor and search status is saved

### Hold requests

#### Critical bugs fixed

- [42915](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42915) Filtering Holds table by patron name or pickup library is broken

  **Sponsored by** *Cape Libraries Automated Materials Sharing*
- [43072](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43072) fill_other_biblio_holds_policy values display incorrectly in circ rules page
- [43174](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43174) Regressions: Staff interface patron search on a record details page - lists patrons by default

#### Other bugs fixed

- [33364](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33364) Stop holds to pull report showing items that have been allocated to a recall
  >This fixes the "Holds to pull" circulation report to exclude items that have pending recalls (recalled items waiting for pickup or in transit for a patron).

  **Sponsored by** *Catalyst*
- [41227](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41227) SuspendHoldsIntranet have no effect
- [41879](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41879) Holds that move to a new bib can be unfillable

### Lists

#### Other bugs fixed

- [43192](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43192) Lists cannot be deleted from OPAC

  **Sponsored by** *Athens County Public Libraries*

### OPAC

#### Other bugs fixed

- [38361](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38361) Gender field does not include a Required if the field is set to required in  PatronSelfRegistrationBorrowerMandatoryField
  >This fixes the gender field for the patron self-registration form so that if it is marked as mandatory using the PatronSelfRegistrationBorrowerMandatoryField system preference, the form shows the field as "Required".
  >
  >It also replaces the radio buttons with a dropdown menu.
- [41988](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41988) OPAC: News RSS links with HTML not working

### Patrons

#### Other bugs fixed

- [20573](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20573) Patron receives membership expiry notice but 'will expire soon' alert doesn't show for staff at checkout
  >This fixes a bug that caused the system preferences MembershipExpiryDaysNotice and NotifyBorrowerDeparture to behave differently when set to the same value.
  >
  >For example, if MembershipExpiryDaysNotice and NotifyBorrowerDeparture are both set to trigger 30 days before the patron account expiration date:
  >- MembershipExpiryDaysNotice would cause an account expiry notice to be sent exactly 30 days before the account expiration date; 
  >- however, NotifyBorrowerDeparture would not begin showing an alert on the patron account until the next day.
  >
  >This fixes the timing on NotifyBorrowerDeparture so that it begins displaying the alert exactly the chosen number of days before the account expires. That way, if MembershipExpiryDaysNotice and NotifyBorrowerDeparture are set to the same value, they will both trigger on the same day.
- [42018](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42018) Inconsistent behavior for null values for fields selected in PatronDuplicateMatchingAddFields
- [43005](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43005) Regression: Changing category from details page section doesn't trigger expiration update
  >This fixes a regression where editing a patron's record from the "Library use" section didn't show the pop-up window if the patron category is changed (prompting to reset expiration date and messaging preferences to the patron category defaults). 
  >
  >(Note: changing the patron category when editing a complete patron record was not affected, it was only not appearing when editing a patron record from the "Library use" section.)
  >
  >(Related to Bug 42169 - Unify patron category change popups, added to Koha 26.05 and 25.11.)
- [43069](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43069) Empty PatronDuplicateMatchingAddFields considers every new patron as duplicate

### Reports

#### Other bugs fixed

- [43098](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43098) Typo in URL for "Edit SQL" button in guided reports (guided_reports_start.tt)
  >This fixes a typo in the URL when editing the SQL in reports. If there is an error in the SQL, the "Edit SQL" button would take you to the guided reports wizard, instead of letting you edit the SQL for the report.  
  >
  >(Changes ".../guided_reports.pl?op=edit_formid=..." to ".../guided_reports.pl?op=edit_form&id=..." - note the missing &)

### SIP2

#### Critical bugs fixed

- [42988](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42988) Saving a SIP account imported from SIPconfig.xml can change the holds (Holds get captured -  holds_get_captured) behavior

#### Other bugs fixed

- [42700](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42700) In C4/SIP/ILS/Patron.pm, hold_items only counts waiting holds

### Searching

#### Other bugs fixed

- [43320](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43320) Don't repeat a quoted search with more quotes when no results

### Serials

#### Other bugs fixed

- [42699](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42699) Editing an already received serial with a duplicate barcode leads to Error 500

  **Sponsored by** *Koha-Suomi Oy*

### Staff interface

#### Other bugs fixed

- [40668](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40668) Library groups and seperateholdings with itemgroups prevents adding items to itemgroup
  >This fixes an issue that prevents staff patrons from adding items to an item group. Actions to add or remove items from an item group did not show, even though they had the correct permissions.
  >
  >Example:
  >- Staff patron has catalogue and manage_item_groups permissions
  >- Item groups are enabled (EnableItemGroups system preference)
  >- There is a library group for the library that the staff patron is from
  >- The "Limit item editing by group" is set for this library group (effectively, the staff patron can only edit items from their own library)
  >- Before the fix: When viewing the items for a record there were no actions available to add items to an item group (the check box was selectable, but there were no actions available)
  >- After the fix: Actions to add or remove items from an item group are now visible and work as expected

  **Sponsored by** *OpenFifth*
- [42632](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42632) Cannot manage bundles after filters are displayed
- [42799](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42799) Toolbar stickiness implementation is flaky

### System Administration

#### Other bugs fixed

- [43336](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43336) Remove support for LibrisSpellcheck
  >This removes support for LibrisSpellcheck, as the API that this feature was based on was removed by the Swedish National Library.
  >
  >It removes two system preferences: LibrisKey and LibrisURL. It also removes the LibrisSpellcheck option from "Did you mean?" (Administration > Additional parameters > Did you mean?).

### Test Suite

#### Other bugs fixed

- [42862](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42862) bookingsModalDatePicker_spec.ts is failing
- [43071](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43071) Test failures when Holds Allowed (daily) has a value
- [43082](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43082) Flaky action_logs.t object filter test due to default LIKE matching
- [43669](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43669) Selenium tests can fail if server is still restarting

### Tools

#### Other bugs fixed

- [42973](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42973) Additional contents ordering ignores "Appear in position" when sorting news
- [43043](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43043) Library limit for OpacMySummaryNote HTML customization doesn't work

### Web services

#### Critical bugs fixed

- [41084](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41084) Zotero connector broken by bug 37370

## Enhancements 

### Architecture, internals, and plumbing

#### Enhancements

- [41061](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41061) No longer need to validate dates manually

### Circulation

#### Enhancements

- [40492](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40492) Improvements to the pending offline circulation actions table
  >Two enhancements to the pending offline circulation actions page (Circulation > Offline circulation > Pending offline circulation actions):
  >- The barcode now links directly to the item on the item details page, instead of the bibliographic record, and opens in a new tab.
  >- There is a new last seen date column, with a warning if the item's last seen date is more recent than the offline circulation action date (for example, the item was checked in).

### OPAC

#### Enhancements

- [30759](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30759) Add hint about the data that is sent via the Google Books API to OPACSuggestionAutoFill
  >This enhancement adds a note about the data that is sent to Google if the OPACSuggestionAutoFill system preference is enabled.

  **Sponsored by** *Catalyst*

### Tools

#### Enhancements

- [42118](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42118) Update various admin pages to use grid layout for forms - Part 2

  **Sponsored by** *Athens County Public Libraries*

## New system preferences

- EnableZotero

## Deleted system preferences

- LibrisKey
- LibrisURL

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [English (USA)](https://koha-community.org/manual/25.11/en/html/)
- [French](https://koha-community.org/manual/25.11/fr/html/) (82%)
- [German](https://koha-community.org/manual/25.11/de/html/) (84%)
- [Greek](https://koha-community.org/manual/25.11/el/html/) (90%)
- [Hindi](https://koha-community.org/manual/25.11/hi/html/) (61%)
- [Portuguese](https://koha-community.org/manual/25.11/pt/html/) (61%)
- [Portuguese (Brazil)](https://koha-community.org/manual/25.11/pt_BR/html/) (61%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Afrikaans (99%)
- Arabic (ar_ARAB) (89%)
- Armenian (hy_ARMN) (100%)
- Azerbaijani (64%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified Han script) (81%)
- Chinese (Traditional Han script) (94%)
- Czech (65%)
- Dutch (89%)
- English (100%)
- English (New Zealand) (99%)
- English (USA)
- Finnish (99%)
- French (99%)
- French (Canada) (99%)
- German (100%)
- Greek (64%)
- Hindi (92%)
- Italian (80%)
- Khmer (Central) (58%)
- Norwegian Bokmål (69%)
- Persian (fa_ARAB) (90%)
- Polish (99%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (88%)
- Russian (92%)
- Slovak (58%)
- Spanish (96%)
- Swedish (88%)
- Telugu (63%)
- Turkish (78%)
- Ukrainian (73%)
- Uzbek (69%)
- Western Armenian (hyw_ARMN) (58%)
</div>

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](https://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](https://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](https://translate.koha-community.org/)

## Release Team

The release team for Koha 25.11.10 is
- Release Manager: Pedro Amorim

- QA Manager: Lisette Scheer

- QA Team:
  - Marcel de Rooy
  - Martin Renvoize
  - Jonathan Druart
  - Laura Escamilla
  - Lucas Gass
  - Tomás Cohen Arazi
  - Lisette Scheer
  - Nick Clemens
  - Paul Derscheid
  - Emily Lamancusa
  - David Cook
  - Matt Blenkinsop
  - Andrew Fuerste-Henry
  - Brendan Lawlor
  - Pedro Amorim
  - Kyle M Hall
  - Aleisha Amohia
  - David Nind
  - Baptiste Wojtkowski
  - Jan Kissig
  - Katrin Fischer
  - Thomas Klausner
  - Julian Maurice
  - Owen Leonard
  - Lucas Gass

- Documentation Manager: Aude Charillon

- Documentation Team:
  - Philip Orr
  - Caroline Cyr La Rose
  - David Nind
  - Marion Durand

- Translation Manager: Jonathan Druart


- Wiki curators:
  - George Williams
  - Thomas Dukleth

- Release Maintainers:
  - 26.05 -- Lucas Gass
  - 25.11 -- Baptiste Wojtkowski
  - 25.05 -- Wainui Witika-Park
  - 24.11 -- Fridolin Somers

- Release Maintainer assistants:
  - 26.05 --Jacob O'Mara
  - 25.05 -- Alex Buckley & Aleisha Amohia



## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 25.11.10
<div style="column-count: 2;">

- Athens County Public Libraries
- [Cape Libraries Automated Materials Sharing](https://info.clamsnet.org)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)
- Horowhenua Libraries Trust
- [Koha-Suomi Oy](https://koha-suomi.fi)
- [OpenFifth](https://openfifth.co.uk)
</div>

We thank the following individuals who contributed patches to Koha 25.11.10
<div style="column-count: 2;">

- Saiful Amin (1)
- Aleisha Amohia (2)
- Pedro Amorim (3)
- Tomás Cohen Arazi (3)
- Matt Blenkinsop (5)
- Nick Clemens (5)
- David Cook (2)
- Paul Derscheid (1)
- Jonathan Druart (18)
- Magnus Enger (1)
- Laura Escamilla (2)
- Katrin Fischer (1)
- Andrew Fuerste-Henry (3)
- Lucas Gass (13)
- Bo Gustavsson (1)
- Kyle M Hall (9)
- Jan Kissig (1)
- Emily Lamancusa (4)
- Brendan Lawlor (4)
- Owen Leonard (4)
- Martin Renvoize (13)
- Olivia Reynolds (1)
- Slava Shishkin (1)
- Fridolin Somers (1)
- Jennifer Sutton (1)
- Emmi Takkinen (3)
- Lari Taskula (2)
- Hammat Wele (3)
- Baptiste Wojtkowski (6)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 25.11.10
<div style="column-count: 2;">

- Athens County Public Libraries (4)
- [BibLibre](https://www.biblibre.com) (7)
- [Bibliotheksservice-Zentrum Baden-Württemberg (BSZ)](https://bsz-bw.de) (1)
- [ByWater Solutions](https://bywatersolutions.com) (32)
- [Cape Libraries Automated Materials Sharing](https://info.clamsnet.org) (4)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha) (3)
- gustavsson.one (1)
- [Hypernova Oy](https://www.hypernova.fi) (2)
- Independant Individuals (1)
- Koha Community Developers (18)
- [Koha-Suomi Oy](https://koha-suomi.fi) (3)
- [Libriotech](https://libriotech.no) (1)
- [LMSCloud](https://www.lmscloud.de) (1)
- [Montgomery County Public Libraries](https://montgomerycountymd.gov) (4)
- [OpenFifth](https://openfifth.co.uk) (22)
- [Prosentient Systems](https://www.prosentient.com.au) (2)
- semanticconsulting.com (1)
- [Solutions inLibro inc](https://inlibro.com) (3)
- [Theke Solutions](https://theke.io) (3)
- Wildau University of Technology (1)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Aleisha Amohia (4)
- Anni (1)
- Tomás Cohen Arazi (1)
- Matt Blenkinsop (3)
- Nick Clemens (5)
- David Cook (8)
- Paul Derscheid (4)
- Roman Dolny (2)
- Jonathan Druart (6)
- Laura Escamilla (9)
- Katrin Fischer (5)
- Andrew Fuerste-Henry (17)
- Lucas Gass (85)
- Gretchen (1)
- Amit Gupta (2)
- Kyle M Hall (3)
- Janusz Kaczmarek (1)
- Emily Lamancusa (6)
- Owen Leonard (2)
- Chris Mathevet (1)
- Gretchen Maxeiner (2)
- David Nind (43)
- Lawrence O'Regan-Lloyd (3)
- Eric Phetteplace (3)
- Martin Renvoize (10)
- Phil Ringnalda (2)
- Marcel de Rooy (8)
- Lisette Scheer (3)
- Michaela Sieber (1)
- Fridolin Somers (1)
- Emmi Takkinen (1)
- Felicie Thiery (1)
- Baptiste Wojtkowski (95)
- Anneli Österman (1)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 25.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 27 Oct 2026 13:22:31.
