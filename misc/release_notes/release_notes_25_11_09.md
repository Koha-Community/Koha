# RELEASE NOTES FOR KOHA 25.11.09
30 Sep 2026

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 25.11.09 can be downloaded from:

- [Download](https://download.koha-community.org/koha-25.11.09.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 25.11.09 is a bugfix/maintenance release with security patches.

It includes 42 bugfixes (5 security).

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [37441](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37441) ShowAlerts msg not escaped in tools uploads
- [42674](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42674) OS command injection via `jobid` in Task Scheduler (`tools/scheduler.pl`)
- [43424](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43424) REST Basic Auth bypasses account lockout (8.1 HIGH)
- [43426](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43426) admin/item_circulation_alerts.pl cud-toggle performs no authentication check at all (7.5 HIGH)
- [43470](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43470) REST Basic Auth allows silent 2FA secret takeover

## Bugfixes

### About

#### Other bugs fixed

- [42453](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42453) "About Koha" breaks if Elasticsearch is used but unavailable

### Accessibility

#### Other bugs fixed

- [42231](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42231) Fix accessibility issues in OPAC summary table
  >This fixes some accessibility issues on the patron's OPAC summary section: Form elements must have labels.
  >
  >- Checked out "Renew" checkbox: adds a hidden label for screen readers
  >- Add note pop-up window for "Report a problem" (when the AllowCheckoutNotes 
  >  system preference is enabled): adds a hidden label for screen readers
  >
  >It also hides the item title on the report a problem and suspend hold pop-up windows.

### Acquisitions

#### Other bugs fixed

- [42225](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42225) On sites with many vendors spent.pl cannot load
  >This improves the SQL for the spent by fund report (Acquisitions > [All available funds section of the page]  > [select amount in the spent column for a fund that has a link]).
  >
  >This fixes an issue where there was a VERY large number of vendors in a system (260k + !!!), which resulted in a database error:
  >  ERROR 1038 (HY001): Out of sort memory, consider 
  >  increasing server sort buffer size
- [42571](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42571) Sending EDI order results in variable not available warnings
- [42757](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42757) Suggester is not passed by purchase-suggestions.pl
  >This fixes "Suggested by" when making a suggestion for a patron from Patrons > [Selected patron] > Purchase suggestions.
  >
  >"Suggested by" was being recorded as the logged in librarian, instead of the patron that made the suggestion.

### Architecture, internals, and plumbing

#### Other bugs fixed

- [42551](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42551) C3 merge error when syntax checking some installed plugins

### Cataloging

#### Other bugs fixed

- [42512](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42512) MARC control field length detection prevents editing of records with invalid MARCXML
- [42874](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42874) z3950_auth_search is losing index parameter

### Circulation

#### Other bugs fixed

- [41358](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41358) action logs info column should always store JSON

  **Sponsored by** *OpenFifth*
- [41889](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41889) /checkouts?checked_in=1 errors when patron_id is null

### Command-line Utilities

#### Other bugs fixed

- [42640](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42640) Script search_for_data_inconsistencies.pl should use binmode UTF-8

### ERM

#### Other bugs fixed

- [42825](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42825) ERM Local Title - Start date (started_on) not saved for package resources
  >This fixes adding a title to a package when creating a new title for ERM - the start date for the title was not saved (ERM > eHoldings > Titles > New title > Packages > Add new package).
- [42933](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42933) ERM - Error adding a license to an agreement when leaving non-mandatory fields empty
  >This fixes an issue for the ERM module when adding a license to an agreement. The status field for the license was not shown as required. This generated an error message if you attempted to add a license without selecting a value for the status field: "Something went wrong: Error: Expected string - got null.". The status field is now marked as required.
  >
  >(Related to Bug 38201 - VueJS architecture rethink, added to Koha 25.11.)

### Hold requests

#### Critical bugs fixed

- [42999](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42999) $valid_items flag contamination in reserve/request.pl causes non-holdable items to appear as available after the first holdable item in the loop
  >This fixes placing holds using the staff interface for a specific item, where there is an item that has a "Not for loan" status.
  >
  >Previously, you could select the item that is not for loan.
  >
  >Now the item that is not for loan has an "X Not for loan" in red in the hold column, and you can't select it.
- [43033](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43033) Holds queue allocate with transport cost matrix can choose impossible holds

#### Other bugs fixed

- [42357](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42357) Holds table is missing patron name
  >This fixes the holds table for a bibliographic record in the staff interface. It now shows the patron's name in addition to the patron's card number.
  >
  >(Use existing system HidePatronName system preference to hide patron names, for example for privacy reasons at circulation desks.)
- [42909](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42909) Suspend class missing from suspended holds on request.pl
  >This fixes the holds table for a record in the staff interface to restore the "suspend" class to the table row for suspended holds, allowing styling by libraries.

### ILL

#### Other bugs fixed

- [42617](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42617) ILL availability pagination not working

### MARC Authority data support

#### Other bugs fixed

- [42920](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42920) Looking up authority records in Advanced editor appends 20 extra spaces

  **Sponsored by** *Chetco Community Public Library*

### OPAC

#### Critical bugs fixed

- [42654](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42654) Regression: Section missing from OPAC course reserve detail page
  >This fixes the course reserves page and navigation in the OPAC so that if a course has a value in the section field, then this value is now shown on the OPAC course detail page after the course name in the page title, breadcrumb, and main heading. 
  >
  >Example: Course reserves for 'Course name' - Section

#### Other bugs fixed

- [41796](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41796) "Forgot your password" link is not visible if OpacResetPassword is enabled but OpacPasswordChange is disabled
- [42066](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42066) CSRF-token sometimes missing from pages
- [42159](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42159) With OPACAuthorIdentifiersAndInformation information lacking from field 110/111
  >This fixes the "Author information" tab in the OPAC details page so that it now shows information from authority records where:
  >- the authority record 024 has identifier data, and
  >- the identifiers option is selected for the OPACAuthorIdentifiersAndInformation system preference.
  >
  >The "Author information" tab now shows the authority record information where it is used in a bibliographic record's 110 (Corporate name) and 111 (Meeting name).
- [42912](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42912) Javascript error on opac-readingrecord when no Circulation history

### Patrons

#### Other bugs fixed

- [41946](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41946) Superlibrarian should be able to set protected status on patron creation

### Plugin architecture

#### Other bugs fixed

- [42430](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42430) Fix issue with stale plugin methods after plugin upgrade

### Point of Sale

#### Critical bugs fixed

- [41819](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41819) Refunds via the Cash registers page should not result in PAYOUTS if the transaction type is 'Account Credit'

### SIP2

#### Critical bugs fixed

- [42664](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42664) Changes to SIP2 accounts may not applied immediately

### Searching - Elasticsearch

#### Critical bugs fixed

- [42669](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42669) es_indexer_daemon.pl silently marks jobs finished on indexing failure and doesn't recover from NoNodes
  >The Elasticsearch indexer daemon (es_indexer_daemon.pl) was silently marking background indexing jobs as "finished" even when Elasticsearch was unreachable, causing records to disappear from search results with no indication of failure. Additionally, after a brief ES outage (e.g. a Docker restart), the daemon's connection pool would mark the node as dead with exponential backoff, leaving it permanently stuck until manually restarted. The daemon now resets jobs to "new" on NoNodes errors so they are automatically retried once connectivity is restored, recreates the ES client to reset the connection pool, and correctly marks jobs as "failed" for other indexing errors.

### Staff interface

#### Critical bugs fixed

- [41604](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41604) Impossible to hide Checkin column in issues-table in circ/circulation.pl
- [42349](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42349) Incorrect filter by recalls
  >This fixes the holdings table on the record details page. The status column filter now works correctly when selecting the "Recalled" option, and lists recalls placed for a specific item.
  >
  >Previously, the "Recalled" filter did not work and all items for the record were listed instead.
- [42868](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42868) Bookings are storing incorrect timezone values

#### Other bugs fixed

- [42339](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42339) Canceling a Record display customization directs to the HTML customizations
  >This fixes the record display customizations page (Tools > Additional tools > Record display customizations). When you cancel adding a new entry you are now returned to the list of record display customizations, instead of the list of HTML customizations.

### System Administration

#### Other bugs fixed

- [42568](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42568) Match maxlength attributes to marc_order_accounts column sizes

  **Sponsored by** *Athens County Public Libraries*
- [42618](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42618) Incorrect sidebar menu link to MARC order accounts

  **Sponsored by** *Athens County Public Libraries*

### Test Suite

#### Other bugs fixed

- [42937](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42937) `$Test::Strict::TEST_STRICT = 0;` no longer needed in t/db_dependent/00-strict.t

### Z39.50 / SRU / OpenSearch Servers

#### Other bugs fixed

- [42321](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42321) Z3950/SRU Search should handle empty results from search targets better

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [English (USA)](https://koha-community.org/manual/25.11/en/html/)
- [French](https://koha-community.org/manual/25.11/fr/html/) (83%)
- [German](https://koha-community.org/manual/25.11/de/html/) (84%)
- [Greek](https://koha-community.org/manual/25.11/el/html/) (90%)
- [Hindi](https://koha-community.org/manual/25.11/hi/html/) (62%)
- [Portuguese](https://koha-community.org/manual/25.11/pt/html/) (53%)
- [Portuguese (Brazil)](https://koha-community.org/manual/25.11/pt_BR/html/) (42%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (89%)
- Armenian (hy_ARMN) (100%)
- Azerbaijani (64%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified Han script) (81%)
- Chinese (Traditional Han script) (94%)
- Czech (65%)
- Dutch (89%)
- English (100%)
- English (New Zealand) (60%)
- English (USA)
- Finnish (99%)
- French (100%)
- French (Canada) (97%)
- German (99%)
- Greek (64%)
- Hindi (92%)
- Italian (80%)
- Khmer (Central) (58%)
- Norwegian Bokmål (69%)
- Persian (fa_ARAB) (90%)
- Polish (100%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (88%)
- Russian (92%)
- Slovak (58%)
- Spanish (96%)
- Swedish (88%)
- Telugu (63%)
- Turkish (78%)
- Ukrainian (73%)
- Uzbek (64%)
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

The release team for Koha 25.11.09 is
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
new features in Koha 25.11.09
<div style="column-count: 2;">

- Athens County Public Libraries
- Chetco Community Public Library
- [OpenFifth](https://openfifth.co.uk)
</div>

We thank the following individuals who contributed patches to Koha 25.11.09
<div style="column-count: 2;">

- Pedro Amorim (1)
- Tomás Cohen Arazi (1)
- Nick Clemens (4)
- Paul Derscheid (3)
- Jonathan Druart (16)
- Laura Escamilla (2)
- Lucas Gass (3)
- Kyle M Hall (8)
- Andreas Jonsson (1)
- Janusz Kaczmarek (2)
- Jan Kissig (3)
- Owen Leonard (2)
- Martin Renvoize (13)
- Phil Ringnalda (1)
- Adolfo Rodríguez (2)
- Marcel de Rooy (1)
- Lisette Scheer (1)
- Fridolin Somers (1)
- Lari Taskula (1)
- Hammat Wele (2)
- Baptiste Wojtkowski (5)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 25.11.09
<div style="column-count: 2;">

- Athens County Public Libraries (2)
- [BibLibre](https://www.biblibre.com) (6)
- [ByWater Solutions](https://bywatersolutions.com) (18)
- Chetco Community Public Library (1)
- [Hypernova Oy](https://www.hypernova.fi) (1)
- Independant Individuals (2)
- Koha Community Developers (16)
- Kreablo AB (1)
- [LMSCloud](https://www.lmscloud.de) (3)
- [OpenFifth](https://openfifth.co.uk) (14)
- Rijksmuseum, Netherlands (1)
- [Solutions inLibro inc](https://inlibro.com) (2)
- [Theke Solutions](https://theke.io) (1)
- Wildau University of Technology (3)
- [Xercode](https://xebook.es) (2)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Aleisha Amohia (2)
- Pedro Amorim (3)
- Tomás Cohen Arazi (1)
- Nick Clemens (4)
- David Cook (3)
- Paul Derscheid (5)
- Roman Dolny (2)
- Jonathan Druart (8)
- Laura Escamilla (3)
- Andrew Fuerste-Henry (1)
- Lucas Gass (59)
- Victor Grousset (1)
- Bo Gustavsson (1)
- Emily Lamancusa (1)
- Brendan Lawlor (3)
- Chris Mathevet (1)
- David Nind (33)
- Sanjar Tulkinov Anvar o'g'li (1)
- Lawrence O'Regan-Lloyd (1)
- Martin Renvoize (16)
- Phil Ringnalda (5)
- Jason Robb (2)
- Caroline Cyr La Rose (1)
- Lisette Scheer (13)
- Edith Speller (1)
- Baptiste Wojtkowski (60)
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

Autogenerated release notes updated last on 30 Sep 2026 16:03:15.
