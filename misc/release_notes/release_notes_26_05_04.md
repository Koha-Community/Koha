# RELEASE NOTES FOR KOHA 26.05.04
01 Oct 2026

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 26.05.04 can be downloaded from:

- [Download](https://download.koha-community.org/koha-26.05.04.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 26.05.04 is a bugfix/maintenance release.

It includes 3 enhancements, 38 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).

#### Security bugs

- [37441](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37441) ShowAlerts msg not escaped in tools uploads
- [42674](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42674) OS command injection via `jobid` in Task Scheduler (`tools/scheduler.pl`)
- [43326](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43326) Stored XSS in patron account note (accountlines.note)
- [43424](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43424) REST Basic Auth bypasses account lockout (8.1 HIGH)
- [43426](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43426) admin/item_circulation_alerts.pl cud-toggle performs no authentication check at all (7.5 HIGH)
- [43470](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43470) REST Basic Auth allows silent 2FA secret takeover

## Bugfixes

### About

#### Other bugs fixed

- [43177](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43177) Use archived link for Bridge Material Type Icon Set
  >This updates the link for About Koha > Licenses > Bridge Material Type Icon Set. It now goes to an Internet Archive page with information (including the license), as the original page is no longer available.

  **Sponsored by** *Athens County Public Libraries*

### Acquisitions

#### Critical bugs fixed

- [42605](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42605) Acquisition Items not listed during receipt

#### Other bugs fixed

- [42827](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42827) Items expected column in parcels.pl always displays 0
- [43053](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43053) Vendor payment methods are not displaying correctly
  >This fixes issues when adding "Payment methods" to a vendor's record (Acquisitions > Vendors > Ordering information > Payment method). Now values are correctly shown in the dropdown list, and you can add multiple values.
  >
  >Notes:
  >1. The authorized values for VENDOR_PAYMENT_METHOD need a description for it to show in the dropdown list.
  >2. You may need to hard refresh the page for changes and new values to show in the dropdown list on the vendor edit form.

### Architecture, internals, and plumbing

#### Critical bugs fixed

- [42736](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42736) SQL Injection in reports/cat_issues_top.pl via Criteria / Filter request parameters (unvalidated string context, no placeholders)
- [43401](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43401) Makefile.PL doesn't compile vue OPAC js to the right directory

#### Other bugs fixed

- [41681](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41681) bulkmarcimport.pl reports an incorrect number of MARC records processed
- [41717](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41717) Update PDF::Reuse and PDF::Reuse::Barcode to the latest version
- [42396](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42396) Replace C4::Stats::UpdateStats calls with Koha::Statistic->store

  **Sponsored by** *OpenFifth*
- [42800](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42800) Potential XSS in shelf list in the erm module
- [42904](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42904) Prevent XSS in patron restriction comments
- [43078](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43078) File transport SFTP backend returns inconsistent list() structure compared to FTP/Local backends
- [43088](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43088) Koha::File::Transport lacks a consistent current_directory() accessor across FTP/SFTP/Local
- [43091](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43091) Staff-only Vue island chunks are emitted into the OPAC dist directory
- [43103](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43103) Batch item modification and patron deletion query IDs as OR query chains
- [43159](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43159) Regression to @INC handling by bug 39740 undoing bug 25778
- [43168](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43168) Incorrect error output when staging a file

### Authentication

#### Critical bugs fixed

- [42719](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42719) OAuth/OIDC login crashes with 500 when no CGISESSID cookie exists (IdP-initiated flow)

### Cataloging

#### Other bugs fixed

- [35729](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35729) Koha needs to handle ISBNs starting with 979 for cover images

  **Sponsored by** *Horowhenua Libraries Trust*

### Circulation

#### Other bugs fixed

- [42565](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42565) GetIssuingCharges returns undef when rentalcharge is NULL
- [43119](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43119) Checkout and hold action logs are not displayed correctly

### Command-line Utilities

#### Other bugs fixed

- [42298](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42298) "No automatic renewal before" falls back to "No renewal before" if former is greater than the latter

### ILL

#### Other bugs fixed

- [42845](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42845) Access to ILL requires parameters => 'manage_sysprefs'
- [43139](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43139) ILL requests Widget should sort desc to display newest records
  >The ILL requests Widget now sorts descending to display newest records first

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
- [43134](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43134) Standardize use of colon in OPAC advanced search page
  >This fixes OPAC advanced search option headings to add missing colons (for consistency).

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
- [43005](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43005) Regression: Changing category from details page section doesn't trigger expiration update
  >This fixes a regression where editing a patron's record from the "Library use" section didn't show the pop-up window if the patron category is changed (prompting to reset expiration date and messaging preferences to the patron category defaults). 
  >
  >(Note: changing the patron category when editing a complete patron record was not affected, it was only not appearing when editing a patron record from the "Library use" section.)
  >
  >(Related to Bug 42169 - Unify patron category change popups, added to Koha 26.05 and 25.11.)
- [43110](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43110) When a patron has a value for advance notices the checkboxes are enabled on the details view

### Reports

#### Critical bugs fixed

- [43267](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43267) Batch operations from datatables report view should only send visible results (same as standard view)

### Searching

#### Other bugs fixed

- [43320](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43320) Don't repeat a quoted search with more quotes when no results

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

### Test Suite

#### Other bugs fixed

- [43082](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43082) Flaky action_logs.t object filter test due to default LIKE matching
- [43669](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43669) Selenium tests can fail if server is still restarting

### Tools

#### Other bugs fixed

- [42973](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42973) Additional contents ordering ignores "Appear in position" when sorting news
- [43173](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43173) Terminology: Log viewer - "Modify cardnumber" should be " Modify card number"
  >This fixes the log viewer terminology. It changes "Modify cardnumber" to "Modify card number", as per the terminology guidelines in two places:
  >- Actions section: is now "Modify card number"
  >- Log view results action column when a patron's
  >  card number is changed: is now "Modify card number"

## Enhancements 

### OPAC

#### Enhancements

- [30759](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30759) Add hint about the data that is sent via the Google Books API to OPACSuggestionAutoFill
  >This enhancement adds a note about the data that is sent to Google if the OPACSuggestionAutoFill system preference is enabled.

  **Sponsored by** *Catalyst*

### Serials

#### Enhancements

- [40201](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40201) Subscription search form on the start page is missing additional fields

### Staff interface

#### Enhancements

- [41116](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41116) Selectors are inconsistently structured in hold found modals

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [English (USA)](https://koha-community.org/manual/26.05/en/html/)
- [French](https://koha-community.org/manual/26.05/fr/html/) (83%)
- [German](https://koha-community.org/manual/26.05/de/html/) (84%)
- [Greek](https://koha-community.org/manual/26.05/el/html/) (90%)
- [Hindi](https://koha-community.org/manual/26.05/hi/html/) (61%)
- [Portuguese](https://koha-community.org/manual/26.05/pt/html/) (54%)
- [Portuguese (Brazil)](https://koha-community.org/manual/26.05/pt_BR/html/) (42%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (87%)
- Armenian (hy_ARMN) (100%)
- Azerbaijani (62%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified Han script) (79%)
- Chinese (Traditional Han script) (92%)
- Czech (64%)
- Dutch (87%)
- English (100%)
- English (New Zealand) (58%)
- English (USA)
- Finnish (99%)
- French (99%)
- French (Canada) (97%)
- German (99%)
- Greek (63%)
- Hindi (90%)
- Italian (79%)
- Khmer (Central) (57%)
- Norwegian Bokmål (67%)
- Persian (fa_ARAB) (88%)
- Polish (99%)
- Portuguese (Brazil) (98%)
- Portuguese (Portugal) (88%)
- Russian (90%)
- Slovak (56%)
- Spanish (93%)
- Swedish (88%)
- Telugu (62%)
- Turkish (76%)
- Ukrainian (71%)
- Uzbek (63%)
- Western Armenian (hyw_ARMN) (57%)
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

The release team for Koha 26.05.04 is

- Release Manager: Pedro Amorim

- Release Manager assistants:
  - Tomás Cohen Arazi
  - Martin Renvoize

- QA Manager: Lisette Scheer

- QA Team:
  - Lucas Gass
  - Laura Escamilla
  - Kyle M Hall
  - Baptiste Wojtkowski
  - Victor Grousset
  - David Cook
  - Andrew Fuerste-Henry
  - Brendan Lawlor
  - Thomas Klausner
  - Paul Derscheid
  - Jan Kissig
  - Jacob O'Mara
  - Nick Clemens
  - Tomás Cohen Arazi
  - Marcel de Rooy
  - Emily Lamancusa
  - Aleisha Amohia
  - Martin Renvoize
  - David Nind

- Topic Experts:
  - Elasticsearch/OpenSearch -- Fridolin Somers
  - SIP2 -- Kyle M Hall
  - EDI -- Kyle M Hall
  - POS -- Martin Renvoize

- Bug Wranglers:
  - Michaela Sieber
  - Laura Escamilla

- Documentation Manager: Aude Charillon

- Documentation Team:
  - Caroline Cyr La Rose
  - David Nind
  - Philip Orr

- Wiki curators: 
  - Thomas Dukleth
  - George Williams

- Release Maintainers:
  - 26.05 -- Lucas Gass
  - 25.11 -- Baptiste Wojtkowski
  - 25.05 -- Wainui Witika-Park (Catalyst IT)
  - 24.11 -- Fridolin Somers

- Release Maintainer assistants:
  - 26.05 -- Jacob O'Mara
  - 25.05 -- Alex Buckley & Aleisha Amohia (Catalyst IT)

## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 26.05.04
<div style="column-count: 2;">

- Athens County Public Libraries
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)
- Horowhenua Libraries Trust
- [OpenFifth](https://openfifth.co.uk)
</div>

We thank the following individuals who contributed patches to Koha 26.05.04
<div style="column-count: 2;">

- Aleisha Amohia (1)
- Pedro Amorim (3)
- Tomás Cohen Arazi (3)
- Matt Blenkinsop (4)
- Nick Clemens (3)
- David Cook (2)
- Paul Derscheid (3)
- Jonathan Druart (8)
- Laura Escamilla (3)
- Andrew Fuerste-Henry (1)
- Lucas Gass (5)
- Amit Gupta (1)
- Bo Gustavsson (1)
- Kyle M Hall (1)
- Jan Kissig (2)
- Emily Lamancusa (2)
- Owen Leonard (4)
- Chris Nighswonger (1)
- David Nind (1)
- Andrew Nugged (3)
- Sanjar Tulkinov Anvar o'g'li (1)
- Martin Renvoize (8)
- Olivia Reynolds (2)
- Jennifer Sutton (1)
- Lari Taskula (2)
- Hammat Wele (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 26.05.04
<div style="column-count: 2;">

- Athens County Public Libraries (4)
- [ByWater Solutions](https://bywatersolutions.com) (13)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha) (2)
- David Nind (1)
- gustavsson.one (1)
- [Hypernova Oy](https://www.hypernova.fi) (2)
- Independant Individuals (4)
- informaticsglobal.ai (1)
- Koha Community Developers (8)
- [LMSCloud](https://www.lmscloud.de) (3)
- [Montgomery County Public Libraries](https://montgomerycountymd.gov) (2)
- [OpenFifth](https://openfifth.co.uk) (17)
- [Prosentient Systems](https://www.prosentient.com.au) (2)
- [Solutions inLibro inc](https://inlibro.com) (1)
- [Theke Solutions](https://theke.io) (3)
- veritassuperaitsolutions.com (1)
- Wildau University of Technology (2)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Aleisha Amohia (1)
- Anni (1)
- Matt Blenkinsop (4)
- Nick Clemens (4)
- David Cook (8)
- Paul Derscheid (1)
- Roman Dolny (1)
- Jonathan Druart (10)
- Laura Escamilla (10)
- Katrin Fischer (3)
- Andrew Fuerste-Henry (10)
- Lucas Gass (59)
- Gretchen (1)
- Janusz Kaczmarek (1)
- Emily Lamancusa (4)
- Owen Leonard (1)
- Chris Mathevet (1)
- Gretchen Maxeiner (2)
- Michaela (1)
- David Nind (25)
- Eric Phetteplace (1)
- Martin Renvoize (3)
- Phil Ringnalda (2)
- Lisette Scheer (3)
- Michaela Sieber (1)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 26.05.x-security.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 01 Oct 2026 15:47:53.
