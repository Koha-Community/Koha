# RELEASE NOTES FOR KOHA 24.11.01
06 Jan 2025

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 24.11.01 can be downloaded from:

- [Download](https://download.koha-community.org/koha-24.11.01.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 24.11.01 is a bugfix/maintenance release.

It includes 1 enhancements, 19 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [37727](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37727) CVE-2024-24337 - Fix CSV formula injection - client side (DataTables)
- [38468](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38468) Staff interface detail page vulnerable to reflected XSS
- [38470](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38470) Subscription detail page vulnerable to reflected XSS

## Bugfixes

### Architecture, internals, and plumbing

#### Other bugs fixed

- [37292](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37292) Add an index on expires column for oauth_access_tokens
  >This adds a database index to the `expires` column for the 'oauth_access_tokens' table, making it easier for database administrators to purge older records.
- [38543](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38543) dataTables assets included but no longer exist
  >This fixes the cause of a file not found message in log files when displaying the checkouts table for a patron (for any patron with current checkouts > Check out > Checkouts tab > Show checkouts). It removes the reference to the rowGroup data tables plugin assets - these no longer exist, as the plugin is now part of DataTables. (This is related to the upgrade to DataTables 2.x in Koha 24.11.)

### Cataloging

#### Other bugs fixed

- [37293](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37293) MARC bibliographic framework text for librarians and OPAC limited to 100 characters
  >This fixes the staff and OPAC description fields for the MARC bibliographic framework forms - it increases the number of characters that can be entered to 255. Previously, the tag description fields were limited to 100 characters and the subfield description fields to 80 characters, even though the database allows up to 255 characters.

  **Sponsored by** *Chetco Community Public Library*

### Database

#### Critical bugs fixed

- [38602](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38602) Columns bookings.creation_date and bookings.modification_date not added if multiple databases are in use
  >This fixes the database update for Bug 37592 - Add a record of creation and modification to bookings, added in Koha 24.11.00. It covers the case where multiple Koha instances are being updated on the same server - the database update was only updating the first database.

  **Sponsored by** *Koha-Suomi Oy*

#### Other bugs fixed

- [38522](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38522) Increase length of erm_argreements.license_info
  >This fixes the ERM agreements license information field (ERM > Agreements) so that more than 80 characters can be entered. It is now a medium text field, which allows entering up to 16,777,215 characters.

### ERM

#### Other bugs fixed

- [38466](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38466) KBART import fails silently if file extension is wrong
  >This fixes importing of KBART files by adding an error message if the file extension is not .TSV or .CSV, instead of silently failing.

### Installation and upgrade (web-based installer)

#### Other bugs fixed

- [38622](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38622) Fix Koha sample data to include preferred_name
  >This updates the sample patron data used by koha-testing-docker (KTD) with the new preferred name field added by bug 28633 in Koha 24.11. Without this update, patron search results and detail pages in KTD did not have the patron's first name.
  >NOTE: This only affected the KTD environment, used for Koha development and testing.

### OPAC

#### Other bugs fixed

- [38362](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38362) Printing lists only prints the ten first results in the OPAC
  >This fixes printing lists in the OPAC so that all the items are printed, instead of only the first 10.
- [38594](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38594) Table settings for courses reserves not working in the OPAC
  >This fixes the OPAC course reserves table. The table settings were not taken into account when displaying the table, for example, hidden columns were still shown.
- [38595](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38595) Table settings behavior broken on some tables in the OPAC
  >This fixes three OPAC tables (holds history, checkout history, and search history) that were not working correctly. This was caused by a JavaScript error (Uncaught TypeError: table_settings.columns is undefined). (This is related to the DataTables upgrade in Koha 24.11.)
- [38620](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38620) Non-existent hc-sticky asset included in opac-tags
  >This removes an obsolete reference to the hc-sicky JavaScript library for the OPAC tags page - hc-sticky is no longer included in Koha.

### Staff interface

#### Other bugs fixed

- [37393](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37393) Bundle items don't show their host in the staff interface
  >This fixes the item status for an item in a bundle, shown in the staff interface's holdings table. If an item is part of a bundle, the item status should show as "Not for loan (Added to bundle). In bundle: [Title and link to record it is bundled with]". It was not showing the "In bundle: [...]" text and link to the bundled item.
  >
  >(Note: This fixes the staff interface, the OPAC correctly shows the text and link. To use the bundle feature: 
  >1) For a record's leader, set position "7- Bibliographic level" to "c- Collection".
  >2) Use the "Manage bundle" action for the record's item, and add items to the bundle.)

### Templates

#### Other bugs fixed

- [31470](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31470) Incorrect selector for relationship dropdown used in members.js

  **Sponsored by** *Koha-Suomi Oy*
- [38476](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38476) Use anchor tag for DataTables configure button
  >This fixes the "Configure" button for tables, so that you can now right-click and open the table settings in a new tab.
- [38536](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38536) Patrons requesting modifications: Expand correct panel
  >This fixes the panels in the staff interface on the patrons requesting modifications page. The automatic panel expansion was not working as expected:
  >- The first panel should expand by default (when there is no patron selected)
  >- The panel should expand when a patron is selected (when opening from the patron's record)
  >(This is related to the OPAC and staff interface Bootstrap 5 upgrade in Koha 24.11.)

  **Sponsored by** *Athens County Public Libraries*

### Web services

#### Other bugs fixed

- [38605](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38605) t/db_dependent/Koha/OAIHarvester.t fails with wrong date format
  >This fixes the tests for t/db_dependent/Koha/OAIHarvester.t - dates were incorrectly handled during the first days of the month because of the use of non-zero-padded days values.

## Enhancements 

### Notices

#### Enhancements

- [38758](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38758) Make formatting date and datetime fields in notices a bit shorter/easier
  >This enhancement adds an easier way to format dates in notices, and minimise potential errors - strftime. It can be used for both date and date time fields, and is locale friendly.
  >
  >Examples:
  >- Date field: [% borrower.dateexpiry.strftime('%d-%m-%y') %]
  >- Date and time field: [% borrower.lastseen.strftime("%d-%m-%y %H:%M") %]
  >- Locale: [% borrower.dateexpiry.strftime("%d %B %Y", "nl_NL") %]

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Armenian (hy_ARMN)](https://koha-community.org/manual/24.11//html/) (58%)
- [Bulgarian (bg_CYRL)](https://koha-community.org/manual/24.11//html/) (98%)
- [Chinese (Traditional)](https://koha-community.org/manual/24.11/zh_Hant/html/) (92%)
- [English](https://koha-community.org/manual/24.11//html/) (100%)
- [English (USA)](https://koha-community.org/manual/24.11/en/html/)
- [French](https://koha-community.org/manual/24.11/fr/html/) (55%)
- [German](https://koha-community.org/manual/24.11/de/html/) (69%)
- [Greek](https://koha-community.org/manual/24.11//html/) (78%)
- [Hindi](https://koha-community.org/manual/24.11/hi/html/) (72%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (96%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified) (86%)
- Chinese (Traditional) (88%)
- Czech (67%)
- Dutch (86%)
- English (100%)
- English (New Zealand) (61%)
- English (USA)
- Finnish (99%)
- French (99%)
- French (Canada) (97%)
- German (100%)
- Greek (57%)
- Hindi (97%)
- Italian (81%)
- Norwegian Bokmål (74%)
- Persian (fa_ARAB) (97%)
- Polish (100%)
- Portuguese (Brazil) (98%)
- Portuguese (Portugal) (88%)
- Russian (92%)
- Slovak (60%)
- Spanish (100%)
- Swedish (86%)
- Telugu (68%)
- Turkish (81%)
- Ukrainian (71%)
- hyw_ARMN (generated) (hyw_ARMN) (62%)
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

The release team for Koha 24.11.01 is


- Release Manager: Katrin Fischer

- Release Manager assistants:
  - Tomás Cohen Arazi
  - Martin Renvoize
  - Jonathan Druart

- QA Manager: Martin Renvoize

- QA Team:
  - Victor Grousset
  - Lisette Scheer
  - Emily Lamancusa
  - David Cook
  - Jonathan Druart
  - Julian Maurice
  - Baptiste Wojtowski
  - Paul Derscheid
  - Aleisha Amohia
  - Laura Escamilla
  - Tomás Cohen Arazi
  - Kyle M Hall
  - Nick Clemens
  - Lucas Gass
  - Marcel de Rooy
  - Matt Blenkinsop
  - Pedro Amorim
  - Brendan Lawlor
  - Thomas Klausner

- Security Manager: Tomás Cohen Arazi

- Topic Experts:
  - UI Design -- Owen Leonard
  - REST API -- Tomás Cohen Arazi
  - Zebra -- Fridolin Somers

- Bug Wranglers:
  - Michaela Sieber
  - Jacob O'Mara
  - Jake Deery

- Packaging Manager: Mason James

- Documentation Manager: Philip Orr

- Documentation Team:
  - Aude Charillon
  - David Nind
  - Caroline Cyr La Rose

- Wiki curators: 
  - George Williams
  - Thomas Dukleth
  - Jonathan Druart
  - Martin Renvoize

- Release Maintainers:
  - 24.11 -- Paul Derscheid
  - 24.05 -- Wainui Witika-Park
  - 23.11 -- Fridolin Somers
  - 22.11 -- Laura Escamilla

## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 24.11.01
<div style="column-count: 2;">

- Athens County Public Libraries
- Chetco Community Public Library
- [Koha-Suomi Oy](https://koha-suomi.fi)
</div>

We thank the following individuals who contributed patches to Koha 24.11.01
<div style="column-count: 2;">

- Tomás Cohen Arazi (1)
- Matt Blenkinsop (1)
- David Cook (3)
- Paul Derscheid (7)
- Jonathan Druart (5)
- Katrin Fischer (3)
- Lucas Gass (1)
- Andrew Fuerste Henry (3)
- Michał Kula (1)
- Owen Leonard (2)
- Matthias Meusburger (1)
- Martin Renvoize (2)
- Phil Ringnalda (1)
- Marcel de Rooy (2)
- Emmi Takkinen (5)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 24.11.01
<div style="column-count: 2;">

- Athens County Public Libraries (2)
- [BibLibre](https://www.biblibre.com) (1)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (3)
- [ByWater Solutions](https://bywatersolutions.com) (4)
- Chetco Community Public Library (1)
- Independant Individuals (1)
- Koha Community Developers (5)
- [Koha-Suomi Oy](https://koha-suomi.fi) (5)
- [LMSCloud](https://lmscloud.de) (7)
- [Prosentient Systems](https://www.prosentient.com.au) (3)
- [PTFS Europe](https://ptfs-europe.com) (3)
- Rijksmuseum, Netherlands (2)
- [Theke Solutions](https://theke.io) (1)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Matt Blenkinsop (2)
- Chris Cormack (1)
- Paul Derscheid (32)
- Roman Dolny (1)
- Jonathan Druart (3)
- Magnus Enger (1)
- Katrin Fischer (23)
- Lucas Gass (11)
- Victor Grousset (2)
- Owen Leonard (8)
- Julian Maurice (1)
- msaby (1)
- David Nind (5)
- Martin Renvoize (1)
- Marcel de Rooy (4)
- Sam Sowanick (1)
- Shi Yao Wang (1)
- Baptiste Wojtkowski (1)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 24.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 06 Jan 2025 12:48:56.
