# RELEASE NOTES FOR KOHA 26.05.02
04 Aug 2026

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 26.05.02 can be downloaded from:

- [Download](https://download.koha-community.org/koha-26.05.02.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 26.05.02 is a bugfix/maintenance release.

It includes 3 enhancements, 54 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [30233](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30233) Remote code execution in user-supplied regex
  >This change refactors the regular expression handling for Batch Item Modification, MARC Modification templates, and Callnumber splitting. It moves from Perl's traditional compile-time regular expression handling to a more dynamic (but restrictive) run-time regular expression handling more similar to Python's "sub" regex method. This functions to reduce vulnerabilities to code injection into Koha's Perl backend.
- [42471](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42471) /cgi-bin/koha/suggestion/suggestion.pl Multiple Parameters Stored Cross-Site Scripting
- [42746](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42746) Stored SQL injection via unvalidated 'agefield' in automatic_item_modification_by_age (C4::Items::ToggleNewStatus)
- [42747](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42747) Stored SQL injection via patroncard layout image_name (patroncards/edit-layout.pl -> create-pdf.pl)
- [42749](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42749) SQL injection in acqui/parcels.pl via the orderby parameter (ORDER BY direction) reaching C4::Acquisition::GetInvoices
- [42847](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42847) SIP authentication ignored after initial successful connection
- [42866](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42866) SQL Injection in Koha/AdditionalContents.pm search_for_display via the patron lang value (stored / second-order, executed on issue-slip print, unvalidated string context, no placeholder)
- [43019](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43019) OPAC pages limited to library are readable by unauthenticated users

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

#### Critical bugs fixed

- [42702](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42702) Acquisitions: Cancel order link on parcel.pl absorbs following HTML into href

#### Other bugs fixed

- [41070](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41070) No warning when filling no fund while importing in a basket from a file
  >This fixes an issue when adding an order to a basket using the "From a new file" option.
  >
  >When adding an order from the staged file there was no warning if you didn't select the fund in either the "Select to import" or "Default accounting details" tabs.
  >
  >Now there is a warning if you don't select a fund: "Some funds are not defined in item records".
- [41709](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41709) GIR segment data should be encoded in EDI ORDERs

  **Sponsored by** *OpenFifth*
- [41803](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41803) Improvements to consistency in basket groups template
  >This change makes updates to the basket groups template:
  >- Action buttons in the basket group table's "actions" column now 
  >  have the class "btn btn-default btn-xs" (previously they were larger,
  >  yellow buttons, now they are smaller buttons with a light grey
  >  background)
  >- Action buttons now have icons
  >- Export action: there is now a dropdown list of export 
  >  options (CSV and PDF)
  >- Edit and delete actions: now use a class instead of an ID as a hook -
  >  this prevents duplicate element IDs on the page.
  >- Generate EDIFACT order action: when there is no EDIFACT configuration,
  >  the action button is disabled and the error message is in a tooltip.
  >- Warning messages styled as standard Bootstrap alerts

  **Sponsored by** *Athens County Public Libraries*
- [42645](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42645) ModSuggestion: FallbackToSMSIfNoEmail ignores EmailFieldPrimary/EmailFieldPrecedence

  **Sponsored by** *OpenFifth*

### Architecture, internals, and plumbing

#### Other bugs fixed

- [42802](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42802) kohastructure.sql needs adjustments for mariadb 12.3

### Cataloging

#### Other bugs fixed

- [40225](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40225) The --send-all option in the stockrotation job fails if there are no items to rotate at all
- [42531](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42531) Repeatable field values with long text do not wrap on staff record detail page
- [42846](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42846) Koha::Database::DataInconsistency typo for biblioitemnumber in MARC

### Circulation

#### Other bugs fixed

- [41889](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41889) /checkouts?checked_in=1 errors when patron_id is null
- [42659](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42659) Multiple numbers and parts shown incorrectly on checkin screen

### Command-line Utilities

#### Other bugs fixed

- [42640](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42640) Script search_for_data_inconsistencies.pl should use binmode UTF-8

### ERM

#### Other bugs fixed

- [42825](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42825) ERM Local Title - Start date (started_on) not saved for package resources
  >This fixes adding a title to a package when creating a new title for ERM - the start date for the title was not saved (ERM > eHoldings > Titles > New title > Packages > Add new package).

### Hold requests

#### Other bugs fixed

- [42357](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42357) Holds table is missing patron name
  >This fixes the holds table for a bibliographic record in the staff interface. It now shows the patron's name in addition to the patron's card number.
  >
  >(Use existing system HidePatronName system preference to hide patron names, for example for privacy reasons at circulation desks.)
- [42909](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42909) Suspend class missing from suspended holds on request.pl
  >This fixes the holds table for a record in the staff interface to restore the "suspend" class to the table row for suspended holds, allowing styling by libraries.

### ILL

#### Other bugs fixed

- [42397](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42397) ILL batches logged under 'ILL' action_logs modulename cause conflict with ILL requests
  >This fixes an issue where ILL batch activity was incorrectly mixed with ILL request logs, causing a 500 error when viewing affected ILL requests.
- [42582](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42582) Uncaught TypeError on Place request with partner libraries when no z39.50 service is set

### Installation and upgrade (command-line installer)

#### Critical bugs fixed

- [42795](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42795) Bug 40658 breaks CLI for 25.11

### OPAC

#### Critical bugs fixed

- [42654](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42654) Regression: Section missing from OPAC course reserve detail page
  >This fixes the course reserves page and navigation in the OPAC so that if a course has a value in the section field, then this value is now shown on the OPAC course detail page after the course name in the page title, breadcrumb, and main heading. 
  >
  >Example: Course reserves for 'Course name' - Section

#### Other bugs fixed

- [42159](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42159) With OPACAuthorIdentifiersAndInformation information lacking from field 110/111
  >This fixes the "Author information" tab in the OPAC details page so that it now shows information from authority records where:
  >- the authority record 024 has identifier data, and
  >- the identifiers option is selected for the OPACAuthorIdentifiersAndInformation system preference.
  >
  >The "Author information" tab now shows the authority record information where it is used in a bibliographic record's 110 (Corporate name) and 111 (Meeting name).
- [42202](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42202) IndependentBranches shouldn't filter public libaries in OPAC search, news, and most popular
  >This fixes the OPAC library location filtering for logged in patrons when IndependentBranches is used.
  >
  >Logged in patrons now see the same options for library locations as unauthenticated patrons, for example:
  >- Library pulldown for "All libraries" for the main search (OpacAddMastheadLibraryPulldown system preference)
  >- Advanced search "Location and availability" option 
  >- Most popular from filter (OpacTopissue system preference)
  >- News selector (OpacNewsLibrarySelect system preference)
  >
  >Previously, the library location options were not shown when a patron was logged in. This made no sense, as unauthenticated user can see all the libraries. (A logged in patron could also do a search and then filter by any library location.)
- [42721](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42721) Update OPACAuthorIdentifiersAndInformation description and identifier labels shown in the OPAC
  >The fixes the OPACAuthorIdentifiersAndInformation system preference description so that identifiers are listed in alphabetical order.
  >
  >It also updates the identifier labels in the system preference description and what is shown in the OPAC:
  >- ScopusID --> Scopus ID
  >- WIKIDATA ID --> Wikidata ID

### Patrons

#### Critical bugs fixed

- [42734](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42734) autoMemberNumValue syspref has no formal UI
  >Superlibrarians can now view and manage the autoMemberNumValue system preference directly from the Patrons preferences page, allowing them to correct a runaway patron cardnumber counter without requiring vendor support. A caution note clarifies that the setting is automatically managed and should only be modified by experienced administrators, with warnings about the risk of duplicate cardnumbers and third-party account access if set incorrectly.

#### Other bugs fixed

- [42611](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42611) Javascript error on readingrec.pl when no reading history

### REST API

#### Other bugs fixed

- [36988](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36988) PUT for patrons requires full borrowers permission, but should only require 'edit_borrowers'
- [42739](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42739) OPAC ratings.js: Add CSRF-TOKEN header to fetch call

### Reports

#### Critical bugs fixed

- [42360](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42360) SQL Injection in reports/acquisitions_stats.pl via Filter parameter
- [42363](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42363) SQL Injection in reports/catalogue_stats.pl via the Line request parameter
- [42368](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42368) SQL Injection in reports/issues_avg_stats.pl via the Filter request parameter (unvalidated string context, no placeholders)
- [42369](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42369) SQL Injection in reports/bor_issues_top.pl via the Filter request parameter (unvalidated string context, no placeholders)
- [42735](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42735) SQL Injection in reports/issues_stats.pl via PeriodTypeSel / PeriodDaySel / PeriodMonthSel / Filter parameters (unvalidated string context, no placeholders)

#### Other bugs fixed

- [12757](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12757) Integers in saved SQL report ODT export prepended with single quote

  **Sponsored by** *OpenFifth*
- [42550](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42550) JS error on saved SQL reports page when there are no reports
- [42803](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42803) Regression in Reports > Items with no checkouts (reports/catalogue_out.pl)

### SIP2

#### Critical bugs fixed

- [42664](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42664) Changes to SIP2 accounts may not applied immediately

### Staff interface

#### Other bugs fixed

- [42116](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42116) e.preventDefault is a function, needs parentheses
- [42535](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42535) Remove useless "news_delete" javascript in staff interface
- [42666](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42666) Next button in Item types and Patron categories does not work

### System Administration

#### Other bugs fixed

- [42128](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42128) Move JS code from admin-icon-selection.inc to a separate .js file

  **Sponsored by** *Athens County Public Libraries*
- [42141](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42141) Design pattern introduced in 40191 does not work in staff SIP configuration
- [42641](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42641) JavaScript errors on patron attribute types admin page
  >This fixes the "Patron attribute types" page (Administration > Patrons and circulation > Patron attribute types). The standard table was not showing correctly because of JavaScript errors. The table was not showing the standard navigation and other table elements:
  >  . "Showing X to X of X entries" (above and below the table)
  >  . Search filter
  >  . Export options
  >  . Sorting controls for the columns

### Templates

#### Other bugs fixed

- [42707](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42707) Malformed Bootstrap dropdown in reports output
  >This fixes the formatting of the patron card number (cardnumber) column in reports. It now uses the "dropdown-item" class and is formatted the same as other dropdown lists, such as borrowernumber.

  **Sponsored by** *Athens County Public Libraries*

### Test Suite

#### Other bugs fixed

- [42862](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42862) bookingsModalDatePicker_spec.ts is failing

### Z39.50 / SRU / OpenSearch Servers

#### Other bugs fixed

- [42321](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42321) Z3950/SRU Search should handle empty results from search targets better

## Enhancements 

### I18N/L10N

#### Enhancements

- [40610](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40610) Update OPAC templates to improve ease of translation

  **Sponsored by** *Athens County Public Libraries*

### SIP2

#### Enhancements

- [42002](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42002) SIP screen msg regexp can't be empty

### Serials

#### Enhancements

- [42078](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42078) Allow vendor ID searches on serial subscription vendor search page

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [English (USA)](https://koha-community.org/manual/26.05/en/html/)
- [French](https://koha-community.org/manual/26.05/fr/html/) (80%)
- [German](https://koha-community.org/manual/26.05/de/html/) (85%)
- [Greek](https://koha-community.org/manual/26.05/el/html/) (91%)
- [Hindi](https://koha-community.org/manual/26.05/hi/html/) (61%)

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
- French (100%)
- French (Canada) (96%)
- German (100%)
- Greek (63%)
- Hindi (90%)
- Italian (79%)
- Khmer (Central) (57%)
- Norwegian Bokmål (67%)
- Persian (fa_ARAB) (88%)
- Polish (99%)
- Portuguese (Brazil) (98%)
- Portuguese (Portugal) (88%)
- Russian (89%)
- Slovak (56%)
- Spanish (93%)
- Swedish (88%)
- Telugu (62%)
- Turkish (76%)
- Ukrainian (71%)
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

The release team for Koha 26.05.02 is

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

## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 26.05.02
<div style="column-count: 2;">

- Athens County Public Libraries
- [OpenFifth](https://openfifth.co.uk)
</div>

We thank the following individuals who contributed patches to Koha 26.05.02
<div style="column-count: 2;">

- Pedro Amorim (5)
- Tomás Cohen Arazi (1)
- Nick Clemens (1)
- David Cook (11)
- Paul Derscheid (1)
- Jonathan Druart (21)
- Laura Escamilla (4)
- Lucas Gass (7)
- Kyle M Hall (8)
- Janusz Kaczmarek (2)
- Jan Kissig (3)
- Owen Leonard (5)
- Chris Mathevet (1)
- David Nind (1)
- Andrew Nugged (1)
- Sanjar Tulkinov Anvar o'g'li (3)
- Eric Phetteplace (1)
- Martin Renvoize (13)
- Olivia Reynolds (1)
- Adolfo Rodríguez (1)
- Marcel de Rooy (1)
- Lisette Scheer (2)
- Fridolin Somers (2)
- Baptiste Wojtkowski (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 26.05.02
<div style="column-count: 2;">

- Athens County Public Libraries (5)
- [BibLibre](https://www.biblibre.com) (3)
- [ByWater Solutions](https://bywatersolutions.com) (22)
- David Nind (1)
- Independant Individuals (7)
- Koha Community Developers (21)
- [LMSCloud](https://www.lmscloud.de) (1)
- [OpenFifth](https://openfifth.co.uk) (19)
- [Prosentient Systems](https://www.prosentient.com.au) (11)
- Rijksmuseum, Netherlands (1)
- [Solutions inLibro inc](https://inlibro.com) (1)
- [Theke Solutions](https://theke.io) (1)
- Wildau University of Technology (3)
- [Xercode](https://xebook.es) (1)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Pedro Amorim (4)
- Angela (1)
- Tomás Cohen Arazi (1)
- Angela Berrett (1)
- Nick Clemens (2)
- David Cook (5)
- Paul Derscheid (5)
- Jonathan Druart (19)
- Marion Durand (1)
- Laura Escamilla (5)
- Andrew Fuerste-Henry (1)
- Eric Garcia (1)
- Lucas Gass (90)
- Kyle M Hall (1)
- Emily Lamancusa (1)
- Brendan Lawlor (3)
- Owen Leonard (3)
- Chris Mathevet (1)
- David Nind (37)
- Sanjar Tulkinov Anvar o'g'li (11)
- Lawrence O'Regan-Lloyd (2)
- Martin Renvoize (16)
- Olivia Reynolds (1)
- Phil Ringnalda (1)
- Marcel de Rooy (1)
- Lisette Scheer (9)
- Baptiste Wojtkowski (7)
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

Autogenerated release notes updated last on 04 Aug 2026 13:51:55.
