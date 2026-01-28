# RELEASE NOTES FOR KOHA 25.11.01
28 Jan 2026

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 25.11.01 can be downloaded from:

- [Download](https://download.koha-community.org/koha-25.11.01.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 25.11.01 is a bugfix/maintenance release.

It includes 34 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [41593](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41593) Authenticated SQL Injection in staff side suggestions
- [41662](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41662) CSRF-vulnerability in opac-patron-consent.pl.

## Bugfixes

### Acquisitions

#### Other bugs fixed

- [39514](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39514) If one basket has uncertain prices, all baskets are displayed in red
  >This fixes the display of baskets in acquisitions so that only baskets with uncertain prices are shown in red. Previously, if one basket had an uncertain price, all the baskets in the page were shown in red, even those without uncertain prices, making it hard to know where to go to fix the price.

### Architecture, internals, and plumbing

#### Critical bugs fixed

- [38426](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38426) Node.js v18 EOL around 25.05 release time
- [40989](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40989) t/db_dependent/OAI/Server.t fails on Debian 13
  >This fixes OAI-PMH (tests and request) so that OAI-PMH responses work when Debian 13 (Trixie) is used as the operating system. Trailing slashes are stripped from requestURL for CGI.pm 4.68+ compatibility
  >
  >Technical details:
  >
  >CGI.pm 4.68 (shipped with Debian 13/Trixie) changed the behaviour of
  >self_url() to include a trailing slash when there's no path component.
  >
  >This strips the trailing slash from both the requestURL field in OAI responses and the baseURL field in Identify responses to maintain compatibility across CGI.pm versions.

#### Other bugs fixed

- [41238](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41238) Pseudonymize statistic jobs don't update progress
  >This fixes the progress shown for pseudonymize statistics background jobs. The progress was shown in the list of jobs (Administration > Jobs > Manage jobs) as "0/1" instead of "1/1", even though the background job was finished.
- [41404](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41404) No need to check related guarantor/guarantee charges when the limits are not set

### Circulation

#### Other bugs fixed

- [40949](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40949) Bookings to collect shouldn't tell staff to check in items
  >This removes the sentence "Please retrieve them and check them in." from the bookings to collect page (Circulation > Holds and bookings > Bookings to collect). This is not required, as checking in items is not relevant for bookings.
- [41345](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41345) Regression: Clicking the 'Ignore' button on hold found modal for already-waiting hold does not dismiss the modal (again)
  >This fixes a regression when checking in an item. Clicking the "Ignore" option in the dialog box, when an item already has a waiting status, just reloaded the dialog box. Clicking the "Ignore" option now closes the dialog box and works as expected.
- [41352](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41352) Bookings to Collect Help does not take you to the correct place in the manual
  >This fixes the link to the help for the Circulation > Holds and bookings > Bookings to collect page - it now links to the correct place in the documentation, instead of the documentation home page.
- [41451](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41451) Hold history search fails when itemtype column present
  >This fixes filtering on a patron's holds history when AllowHoldItemTypeSelection is enabled. This previously produced a 500 error when searching, but now works as expected.
- [41456](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41456) Item type filter on the hold history view does not work correctly
  >This fixes the patron's holds history table in the staff interface. The search filter now works as expected - using the library name or library code and requested item type name or item type code (when AllowHoldItemTypeSelection is enabled) now work as expected, and the column filters for both of these now use dropdown lists.

### Hold requests

#### Other bugs fixed

- [41432](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41432) Add prefetch to improve performance of holds page
  >This improves the performance of the holds request page for a record in the staff interface.

### I18N/L10N

#### Other bugs fixed

- [40287](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40287) Fix untranslatable strings in more statistics wizards
  >This fixes and improves the acquisitions, patrons, catalog, and circulation statistics report wizard:
  >- Fixes some strings so that they are now translatable
  >- Improves the "Filtered on" information shown before the report results:
  >  . the filtered on options selected in the report are now shown in a bulleted list and in bold
  >  . descriptions are now shown instead of codes (for example, the library name instead of the library code)

  **Sponsored by** *Athens County Public Libraries*

### Installation and upgrade (web-based installer)

#### Other bugs fixed

- [40006](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40006) Upgrading install.pl shows code vs HTML
  >This fixes a database update (for bug 38436 in 24.11.00) that caused code to show in the browser instead of HTML output when running an upgrade.

### OPAC

#### Other bugs fixed

- [40619](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40619) Remove OverDrive star ratings from the OPAC
  >This removes the code for OverDrive star ratings from OPAC pages, as OverDrive no longer supplies star ratings through their API.

  **Sponsored by** *Athens County Public Libraries*

### Patrons

#### Critical bugs fixed

- [41145](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41145) Logging patron attributes logs even if there's no changes
  >This prevents misleading patron attribute modification logs, when a library batch imports patrons with the BorrowersLog system preference set to 'Log'. It now correctly only shows a log entry when a patron attribute value is changed.
  >
  >Example: 
  >- Before the change: for an existing patron with a patron attribute of INSTID:1234, with a re-import the log shows { "attribute.INSTID" : { "after" : "1234", "before" : "" } }, even though there is no change to the patron attribute.
  >- After the change: 
  >  . No log entry is shown if there is no change to the patron attribute.
  >  . If there is a change to the patron attribute (for example, changed to 5678 on a re-import), it is now correctly shown - { "attribute.INSTID" : { "after" : "5678", "before" : "1234" } }

  **Sponsored by** *Auckland University of Technology*

#### Other bugs fixed

- [39014](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39014) Storing a guarantee fails due to TrackLastPatronActivityTriggers "creating a patron"
  >This fixes an error when creating a patron that requires a guarantor, when this combination of settings is used:
  >- `TrackLastPatronActivityTriggers`: 'Creating a patron' is selected
  >- `ChildNeedsGuarantor`: is set to 'requires'
  >- The patron category is a 'Child' and 'Can be guarantee' is set to 'Yes'
  >
  >With these settings, this error message "The following fields are wrong. Please fix them." (without a list of fields) was incorrectly shown when creating a child patron, even though you had correctly added the guarantor information.

  **Sponsored by** *Koha-Suomi Oy*
- [41363](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41363) Don't hide patron category limitation warning behind icon
  >This moves the hint text for the warning on the Library management > Category field (when editing a patron record) from a tool tip on the warning icon to standard hint text under the input field, to make it more accessible
  >
  >Note: This warning only appears under certain circumstances (when a patron category is limited to a specific library, and you edit a patron when the library is set to another location).

  **Sponsored by** *Athens County Public Libraries*

### Point of Sale

#### Other bugs fixed

- [41408](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41408) POS Inline Editing Triggers Form Submission on Enter Key
  >Inline editing the cost or quantity fields on a point of sale transaction, then pressing enter, incorrectly submitted the form--instead of just updating the field.
  >
  >Now, the values in the fields are updated without submitting the form, and you can continue entering sale details and completing the transaction.

### REST API

#### Other bugs fixed

- [40219](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40219) Welcome Email Sent on Failed Patron Registration via API
  >This fixes patron registrations using the API - a welcome email notice was sent even if there were validation failures.

### Reports

#### Other bugs fixed

- [41292](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41292) Add "force_password_reset_when_set_by_staff" to the allowed column name list
  >This adds the force_password_reset_when_set_by_staff field in the categories table to the list of allowed password-related fields that can be used in SQL reports.
  >
  >Currently, this field is treated as containing sensitive password-related data and generates an error when creating a report that uses it.

### SIP2

#### Other bugs fixed

- [40455](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40455) A patron information  request fails when no currency is set
  >This fixes an error in SIP2 patron information responses (64) when no currency is set, which can be the case for new Koha instances.
  >
  >Example, if no currency is set:
  >- Before the fix, there is an 'undef' error:
  >    ...
  >    Trying 'patron_information'
  >    SEND: 6300120251202    115652          AOCPL|AA42|ACterm1|
  >    READ: undef 
  >- After the fix, patron informatin is returned and there is no error:
  >    ...
  >    Trying 'patron_information'
  >     SEND: 6300120251202    122545          AOCPL|AA42|ACterm1|
  >     READ: 64              00120251202     
  >     122546000000000000000000000000AOCPL|AA42|AE koha|BLY|BV0|CC5|PCS|
  >     PIY|AFGreetings from Koha. |

### Searching - Elasticsearch

#### Other bugs fixed

- [38345](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38345) Restore support for OpenSearch
  >This fixes Koha so that OpenSearch now works, and is now covered again by continuous integration tests (these have been failing for some time in Jenkins).
  >
  >Note: See the test plan for guidance on how to start KTD successfully with OS1 and OS2 if you have issues.
- [40980](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40980) Clicking a search facet without logging in may trigger a cud-login error
  >This fixes using facets in the OPAC for searching when not logged in, where Elasticsearch or OpenSearch is used as the search engine. In some circumstances, a 403 Forbidden Error was incorrectly generated (this is related to changes made in previous versions of Koha to improve form security).

### Serials

#### Other bugs fixed

- [37796](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37796) Generated issue has incorrect number in pattern when receiving
  >This fixes an issue with incorrect numbering patterns and the next expected issue shown, after a serial is received.
  >
  >Example of an incorrect numbering pattern before this fix: 
  >- Monthly serial received for August 2025 (its status shows as 'Arrived' for August 2025).
  >- The next expected serial was then shown as August 2025 instead of September 2025 (its status was shown as 'Expected' with a incorrect numbering pattern of August 2025)

### Staff interface

#### Other bugs fixed

- [41427](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41427) Terminology: branch should be library in FilterSearchResultsByLoggedInBranch
  >This fixes the terminology and improves the description for the FilterSearchResultsByLoggedInBranch system preference - branch should be library.

### System Administration

#### Critical bugs fixed

- [39482](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39482) Link to edit OpacLibraryInfo from library edit page broken
  >This fixes editing and showing OpacLibraryInfo HTML customizations information in the staff interface and OPAC:
  >
  >1. Staff interface:
  >   - When editing a library (Koha administration > Libraries > Actions > Edit)
  >     . the links to edit OpacLibraryInfo entries for the OPAC information field are now correct (previously, they may have linked to an incorrect HTML customization)
  >     . if there is more than one OpacLibraryInfo entry, all entries are now shown (only one entry was shown previously)
  >   - When viewing library information (Koha administration > Libraries > Name > [click library name]), all the OpacLibraryInfo entries are now shown
  >
  >2. OPAC:
  >   - All the entries for a library (including any 'All libraries' entries for OpacLibraryInfo) are now shown on the library information page (from the 'Libraries' link under the quick search bar)
  >   - In a record's holdings table, the pop-up window when you click on the current library for an item now correctly shows all entries

  **Sponsored by** *Athens County Public Libraries*

### Templates

#### Other bugs fixed

- [40567](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40567) Correct eslint errors in recalls.js
  >This fixes a few minor coding guideline errors in the JavaScript used on recalls pages (JS8: Follow guidelines set by ESLint). There are no changes to how the recalls pages work.

  **Sponsored by** *Athens County Public Libraries*
- [41339](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41339) Typo 'Too many checkout'
  >Changes "Too many checkout" to "Too many checkouts" message that shows in the log viewer when circulation overrides are logged.
- [41348](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41348) Capitalization: "List Files" and others
  >This fixes the capitalization for messages used with FTP/SFTP file transfers (Administration > Additional parameters > File transports).
  >
  >Changes:
  >- "List Files" to "List files"
  >- "Change Directory" to "Change directory"
- [41361](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41361) Incorrect markup in category code confirmation modal
  >This fixes the "Confirm expiration date" dialog box that is shown when changing an individual patron's category:
  >- The "No" option now works.
  >- It is now formatted using our standard Bootstrap 5 styles.

  **Sponsored by** *Athens County Public Libraries*
- [41395](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41395) Terminology: Target item cannot be reserved from other branches
  >Updates the terminology for two circulation-related messages (reserves to holds, branches to libraries):
  >
  >- "Target item cannot be reserved from other branches" to "Target item cannot be placed on hold from other libraries"
  >- "No reserves allowed" to "No holds allowed"
- [41396](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41396) Capitalization: 'Transport Settings' and other
  >This fixes the capitalization for the section headings on the EDI account create and edit form - they are now in sentence case (Administration > Acquisition parameters > EDI accounts):
  >
  >- Basic Information => Basic information
  >- Transport Settings => Transport settings
  >- Message Types => Message types
  >- Functional Switches => Functional switches

  **Sponsored by** *Athens County Public Libraries*

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [English (USA)](https://koha-community.org/manual/25.11/en/html/)
- [French](https://koha-community.org/manual/25.11/fr/html/) (74%)
- [German](https://koha-community.org/manual/25.11/de/html/) (90%)
- [Greek](https://koha-community.org/manual/25.11/el/html/) (94%)
- [Hindi](https://koha-community.org/manual/25.11/hi/html/) (64%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (90%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified Han script) (82%)
- Chinese (Traditional Han script) (95%)
- Czech (65%)
- Dutch (85%)
- English (100%)
- English (New Zealand) (60%)
- English (USA)
- Finnish (99%)
- French (99%)
- French (Canada) (97%)
- German (99%)
- Greek (64%)
- Hindi (93%)
- Italian (79%)
- Norwegian Bokmål (69%)
- Persian (fa_ARAB) (91%)
- Polish (99%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (86%)
- Russian (91%)
- Slovak (57%)
- Spanish (96%)
- Swedish (88%)
- Telugu (64%)
- Turkish (79%)
- Ukrainian (73%)
- Western Armenian (hyw_ARMN) (59%)
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

The release team for Koha 25.11.01 is


- Release Manager: Lucas Gass

- QA Manager: Martin Renvoize

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

- Documentation Manager: David Nind

- Documentation Team:
  - Philip Orr
  - Aude Charillon
  - Caroline Cyr La Rose

- Translation Manager: Jonathan Druart


- Wiki curators: 
  - George Williams
  - Thomas Dukleth

- Release Maintainers:
  - 25.11 -- Jacob O'Mara
  - 25.05 -- Laura Escamilla
  - 24.11 -- Fridolin Somers
  - 22.11 -- Wainui Witika-Park (Catalyst IT)

- Release Maintainer assistants:
  - 25.11 -- Chloé Zermatten
  - 24.11 -- Baptiste Wojtkowski
  - 22.11 -- Alex Buckley & Aleisha Amohia

## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 25.11.01
<div style="column-count: 2;">

- Athens County Public Libraries
- Auckland University of Technology
- [Koha-Suomi Oy](https://koha-suomi.fi)
</div>

We thank the following individuals who contributed patches to Koha 25.11.01
<div style="column-count: 2;">

- Pedro Amorim (1)
- Tomás Cohen Arazi (2)
- Alex Buckley (2)
- Nick Clemens (6)
- David Cook (2)
- Paul Derscheid (2)
- Jonathan Druart (7)
- Andrew Fuerste-Henry (2)
- Lucas Gass (3)
- Jan Kissig (1)
- Owen Leonard (10)
- David Nind (2)
- Jacob O'Mara (4)
- Martin Renvoize (3)
- Marcel de Rooy (1)
- Caroline Cyr La Rose (1)
- Lisette Scheer (1)
- Leo Stoyanov (1)
- Emmi Takkinen (1)
- Lari Taskula (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 25.11.01
<div style="column-count: 2;">

- Athens County Public Libraries (10)
- [ByWater Solutions](https://bywatersolutions.com) (13)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha) (2)
- David Nind (2)
- [Hypernova Oy](https://www.hypernova.fi) (1)
- Koha Community Developers (7)
- [Koha-Suomi Oy](https://koha-suomi.fi) (1)
- [LMSCloud](https://www.lmscloud.de) (2)
- [Open Fifth](https://openfifth.co.uk/) (8)
- [Prosentient Systems](https://www.prosentient.com.au) (2)
- Rijksmuseum, Netherlands (1)
- [Solutions inLibro inc](https://inlibro.com) (1)
- [Theke Solutions](https://theke.io) (2)
- Wildau University of Technology (1)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Christopher Brannon (1)
- Aude Charillon (1)
- Jonathan Druart (3)
- Magnus Enger (1)
- Laura Escamilla (8)
- Lucas Gass (42)
- Victor Grousset (1)
- Owen Leonard (1)
- David Nind (29)
- Jacob O'Mara (49)
- Wesley Owen (2)
- Martin Renvoize (12)
- Marcel de Rooy (11)
- Samuel (1)
- Lisette Scheer (3)
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

Autogenerated release notes updated last on 28 Jan 2026 11:17:10.
