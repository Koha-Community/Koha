# RELEASE NOTES FOR KOHA 24.11.03
24 Mar 2025

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 24.11.03 can be downloaded from:

- [Download](https://download.koha-community.org/koha-24.11.03.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 24.11.03 is a bugfix/maintenance and security release.

It includes 13 enhancements, 44 bugfixes of which 2 are security fixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [31165](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31165) "Public note" field in course reserve should restrict HTML usage
- [37784](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37784) Patron password hash can be fetched using report dictionary

  **Sponsored by** *Reserve Bank of New Zealand*

## Bugfixes

### About

#### Other bugs fixed

- [38617](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38617) Fix warning about auto increment and biblioitems
  >This fixes the table name in the warning about auto increment and biblioitems on the About Koha > System information page.
  >
  >If the system identifies auto increment issues, the message is now "The following IDs exist in both tables biblioitems and deletedbiblioitems", instead of "...tables biblio and deletedbiblioitems".

### Acquisitions

#### Critical bugs fixed

- [39282](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39282) When adding an order from file, data entered in the "Item information" tab is not saved and invalid items are created
  >This fixes an issue that occurs in Acquisitions when adding an order from a new or staged file. If the system preference AcqCreateItem is set to create items when the order is placed, and item information is not imported from the uploaded MARC file, then the librarian would enter the item information in the "Item information" tab when confirming the order. The information from this tab was not getting processed correctly, which led to "empty" items being created.

#### Other bugs fixed

- [38766](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38766) Opening, closing, or deleting and invoice from the Action drop-down can cause internal server error
  >This fixes closing and reopening of invoices using the action button options (Acquisitions > [Vendor] > Invoices > Actions) - when used from the search results when using invoice filters (for example, shipment to and from dates). This caused an internal server error with the message "The given date <date> does not match the date format (iso)...". It also adds a confirmation message when deleting an invoice.
- [38957](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38957) EDIFACT messages table should sort by 'Transferred date' descending by default
- [38986](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38986) Restore "Any" option to purchase suggestion filter by fund
- [39044](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39044) Fund dropdown not populated for order search on acqui-home

### Architecture, internals, and plumbing

#### Other bugs fixed

- [39172](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39172) Merging records no longer compares side by side
  >This patch fixes a regression when merging records in the cataloging module. Columns will show side by side again when comparing records for a merge.

### Authentication

#### Critical bugs fixed

- [38826](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38826) C4::Auth::check_api_auth sometimes returns $session and sometimes returns $sessionID
  >This fixes authentication checking so that the $sessionID is consistently returned (sometimes it was returning the session object). (Note: $sessionID is returned on a successful login, while $session is returned when there is a cookie for an authenticated session.)

### Circulation

#### Critical bugs fixed

- [38789](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38789) Wrong Transfer modal does not show
  >This fixes a regression. When an item in transit was checked in at a library other than the destination, it was not generating the "Wrong transfer" dialog box.
- [38793](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38793) When setting up automatic confirmation of transfers when dismissing the modal. It prevents manual cancellation
  >Fixes a transfer being silently not canceled (despite clicking the button) when system preferences TransfersBlockCirc = "don't block" and AutomaticConfirmTransfer = "do automatically confirm". Which should only be about confirming when dismissing the transfer modal.

#### Other bugs fixed

- [38748](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38748) Library name is missing in return to home transfer slip
  >This fixes the generation of the transfer slip - the library to transfer an item to is now shown, instead of being blank.
- [38853](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38853) 'Cancel selected' on holds table does not work
  >This fixes the "Cancel selected" button for a records' holds table in the staff interface - it now cancels the selected holds. Previously, after you confirmed the hold cancellation nothing happened (the background jobs didn't run and the holds were not cancelled). (This is related to the CSRF changes added in Koha 24.05 to improve form security.)

  **Sponsored by** *Chetco Community Public Library*
- [39108](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39108) Clicking the 'Ignore' button on hold found modal for already-waiting hold does not dismiss the modal
- [39183](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39183) If using automatic return claim resolution on checkout, each checkout will overwrite the previous resolution (again)
- [39270](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39270) Some bookable items cannot be booked

### Command-line Utilities

#### Other bugs fixed

- [37920](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37920) writeoff_debts.pl should be logged
- [39236](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39236) writeoff_debts.pl does not run

### ERM

#### Other bugs fixed

- [36627](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36627) Display importer for manually harvested SUSHI data
  >This fixes the ERM usage statistics import logs table to show who manually imported the SUSHI data. For eUSage > Data providers > [Name] >  Import logs, the "Imported by" column now shows the staff patron, instead of just "Cronjob".
- [38782](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38782) ERM eUsage related tests are failing
  >This fixes failing ERM usage tests.

### Fines and fees

#### Critical bugs fixed

- [39025](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39025) Update patron account templates to use old_issue_id to display circ info

### ILL

#### Other bugs fixed

- [39175](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39175) Send request to partners explodes

### Lists

#### Other bugs fixed

- [39268](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39268) When switching tabs between 'My lists' and 'Public lists' incorrect lists can be displayed

  **Sponsored by** *Athens County Public Libraries*

### OPAC

#### Other bugs fixed

- [35975](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35975) Downloaded cart with BibTeX contains hash value instead of the record number
  >This fixes the contents of the BibTeX file downloaded from an OPAC cart - it now correctly shows the record number, instead of Koha::Hash(xxx).
  >
  >Example of incorrect BibTeX file format:
  >@book{Koha::Biblio=HASH(0x560e89ade4b8), <--- should have been 262
  >	author = {Christiansen, Tom. and Foy, Brian D.},
  >	title = {Programming Perl /},
  >	publisher = {O'Reilly,},
  >	year = {c2012.},
  >	address = {Beijing ;},
  >	edition = {4th ed.},
  >	note = {Rev. ed. of: Programming Perl / Larry Wall, Tom Christiansen & Jon Orwant. 2000. 3rd ed.}
  >}
- [38077](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38077) Minor spacing issue in self checkout login page
  >This fixes a minor spacing issue on the self checkout login page. The login form is now arranged vertically and includes more padding.

  **Sponsored by** *Athens County Public Libraries*
- [38462](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38462) Remove unused code for pagination in OPAC authority search
  >This removes unused code for OPAC authority search results pagination. (There are no visible changes for patrons.)

  **Sponsored by** *Chetco Community Public Library*
- [38753](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38753) Missing table cells breaks OPAC charges table
  >This fixes the charges table for a patron in the OPAC (Your account > Charges). It didn't display correctly in some circumstances (there were missing empty table cells, resulting in empty and misaligned cells at the end of the table).

  **Sponsored by** *Athens County Public Libraries*

### Patrons

#### Other bugs fixed

- [36025](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36025) Extended attributes clause added to patron search query even when there are no searchable attributes
  >REVERTED, REMOVE FROM RELASE NOTES
- [38459](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38459) Cities dropdown should work for quick add form as well
  >This fixes the quick add patron form so that the city field uses a dropdown list and populates other fields (state, ZIP/Postal code, and country), where cities are defined in Administration > Patrons and circulation > Cities and towns.
- [38735](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38735) New installations should include preferred_name in DefaultPatronSearchFields by default
  >This enhancement updates the DefaultPatronSearchFields system preference - the preferred name field is now included in the default patron search using the "standard" option. Note: This change only affects new installations.
  >
  >(This is related to bug 28633 - Add a preferred name field to patrons, a new featured added in Koha 24.11.00.)
- [38772](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38772) Typo 'minPasswordPreference' system preference
  >This fixes a typo in the code for OPAC password recovery - 'minPasswordPreference' to 'minPasswordLength' (the correct system preference name). It has no noticeable effect on resetting an account password from the OPAC.
- [39244](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39244) Duplicate and change password buttons missing if no borrowerRelationship defined and patron is not adult

### Point of Sale

#### Other bugs fixed

- [38667](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38667) Point of sale transaction history should not appear to be sortable
  >This removes the column sorting icons from the point of sale "Transactions to date" and "Older transactions" tables. The sort order for these tables is fixed, and clicking the icons had no effect.

  **Sponsored by** *Athens County Public Libraries*

### SIP2

#### Critical bugs fixed

- [38375](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38375) SIP2 syspref SIP2SortBinMapping is not working

### Staff interface

#### Critical bugs fixed

- [38632](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38632) All columns shown in holdings table when displaying the filters
  >This fixes the holdings table - clicking "Show filters" was incorrectly displaying all columns.

#### Other bugs fixed

- [37761](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37761) Tabs on curbside_pickups.tt page not styled right after Bootstrap 5 update
  >This fixes the curbside pickups page (Circulation > Holds and bookings > Curbside pickups) so that the tabs are correctly styled (instead of plain links), and the automatic refresh works as expected (you stay on the currently selected tab). (This is related to the OPAC and staff interface Bootstrap 5 upgrade in Koha 24.11.)

  **Sponsored by** *Athens County Public Libraries*
- [38108](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38108) Make display of table filters in staff interface holdings table configurable
  >This patch adds a new system preference called 'AlwaysShowHoldingsTableFilters'. This system preference allows staff to control the behavior of the filters on the items detail page. It can be set to either always show the filters by default or to never show the filters by default.
- [38711](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38711) Wrong font-weight in tables during printing from staff interface
  >This fixes the print style sheet for tables in the staff interface - the last column is no longer printed in bold. This was affecting various pages when printed, such as notices and slips, and pages.

  **Sponsored by** *Deutsches Elektronen-Synchrotron DESY, Library*

### Templates

#### Other bugs fixed

- [36609](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36609) Update index type labels in Elasticsearch config page: Std. Number, Call Number, <empty>
  >This fixes the labels used for the type options when configuring Elasticsearch search fields - they now use sentence case and the full name (instead of abbreviations):
  >- Default (instead of being blank)
  >- Identifier (instead of Std. Number)
  >- Call number (instead of Call Number)
- [38285](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38285) Replace instances of obsolete Bootstrap class "pull-right"
  >This fixes some CSS from the Bootstrap 5 upgrade:
  >- Removes instances of the pre-Bootstrap-5 class "pull-right" (Bootstrap 5 menus have better responsive behavour).
  >- Adds "dropdown-item" classes to some menu items that lacked it.
  >- Adds some custom style for the "Filter" form in the patron permissions toolbar (it is now correctly aligned).
  >(This is related to the OPAC and staff interface Bootstrap 5 upgrade in Koha 24.11.)

  **Sponsored by** *Athens County Public Libraries*
- [38349](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38349) Fix style of sidebar form submit button on tags review page
  >This fixes the "Apply filter(s)" button on the tags review page in the staff interface (Tools > Patrons and circulation > Tags). It now has the same yellow "primary" style as other submit buttons - the text is slightly larger, and the button now fills the entire width of the sidebar.

  **Sponsored by** *Athens County Public Libraries*
- [38665](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38665) Markup error in additional fields template title
  >This fixes a markup error in the browser page title for the additional fields page - there was an additional caret (>) at the start (> Additional fields > Administration > Koha, instead of Additional fields > Administration > Koha).

  **Sponsored by** *Athens County Public Libraries*

### Tools

#### Other bugs fixed

- [38771](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38771) Typo 'AuthScuccessLog' system preference
  >This fixes the log viewer authentication module "Log not enabled" warning message for the log viewer. If either AuthFailureLog or AuthSuccessLog system preferences are set to "Don't log", the "Log not enabled" warning icon is now shown. Previously, if one of the system preferences was set to "Log", no warning icon was shown.

## Enhancements 

### About

#### Enhancements

- [36039](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36039) The output of audit_database.pl should be accessible through the UI
  >This enhancement makes the misc/maintenance/audit_database.pl script (added in Koha 23.11) available in the staff interface - About Koha > Database audit tab. The script compares the instance's database against kohastructure.sql and identifies any differences that need fixing. This is useful for identifying database issues that should be addressed before running a maintenance or release update.

### Architecture, internals, and plumbing

#### Enhancements

- [36662](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36662) ILL - t/db_dependent/Illrequest should not exist
  >This enhancement moves the ILL test files to the correct folder structure - t/db_dependent/Koha/ILL/.
- [38483](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38483) C4::Heading::preferred_authorities is not used
  >This removes an unused method 'preferred_authorities' (Return a list of authority records for headings that are a preferred form of the heading).

  **Sponsored by** *Ignatianum University in Cracow*
- [38838](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38838) optgroup construct needs cleaning in the reports module
  >This enhancement updates what is shown when selecting the columns when creating a new dictionary definition in reports. It now shows "Field description / tablename.fieldname", instead of just the "Field description" - the same as for creating reports. Example, 'Publication date / biblioitems.publicationyear' (previously it just showed 'Publication date').

### Cataloging

#### Enhancements

- [37398](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37398) Initialize a datepicker on all date/datetime fields when adding/editing items
  >This enhancement adds the date picker by default to all item date and datetime fields.

### I18N/L10N

#### Enhancements

- [38684](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38684) Improve translatability in cat-toolbar.inc
  >This enhancement improves the translatability of the tool tips for 'Edit > Delete record' on the record details page in the staff interface. It makes it easier to translate the singular and plural forms of items and subscriptions.

### Lists

#### Enhancements

- [38302](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38302) Inconsistent delete confirmation dialog for "Delete list" buttons
  >This enhancement adds a confirmation step when deleting a list from the "Your lists" and "Public lists" tabs in the staff interface. Previously, you were not asked to confirm the list deletion. This also makes it consistent with deleting a list from its contents page, where you are asked to confirm the list deletion.

### OPAC

#### Enhancements

- [35808](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35808) Remove obsolete responsive table markup from several pages in the OPAC
  >This enhancement removes obsolete responsive table markup (span.tdlabel) from several OPAC pages, as the tables now use the DataTables responsive features.

  **Sponsored by** *Athens County Public Libraries*

### Patrons

#### Enhancements

- [33454](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33454) Improve breadcrumbs for patron lists
  >This fixes the breadcrumbs for patron lists (Tools > Patrons and circulation > Patron lists) so that they are now more consistent with other breadcrumbs, and improves their translatability (Tools > Patron lists > Add patrons to 'List name', instead of Tools > Patron lists > List name).

### Staff interface

#### Enhancements

- [38662](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38662) Additional fields admin page hard to read
  >This enhancement to the Administration > Additional parameters > Additional fields page makes it easier to read. The tables are now grouped and listed alphabetically by module and table name, instead of alphabetically by database table name.

### Templates

#### Enhancements

- [37826](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37826) Remove the use of the script_name variable where it is unnecessary
  >This enhancement removes the $script_name variable from several pages where it is unnecessary, and updates the corresponding template with the URL itself. (Most of the places where a $script_name variable was used was not strictly necessary. It was also used inconsistently.)

  **Sponsored by** *Athens County Public Libraries*
- [38221](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38221) Add Bootstrap styling to pagination in authority plugin search results
  >This enhancement updates the style of the pagination links in the cataloging authority search popup (for example, 100$a). The style is now consistent with other pages (such as catalog search results), instead of plain links for result page numbers and angle brackets for next, last, first, and previous page links.

  **Sponsored by** *Athens County Public Libraries*

### Test Suite

#### Enhancements

- [39007](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39007) Add last_audit to the sushi_service API spec

## New system preferences

- AlwaysShowHoldingsTableFilters

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Armenian (hy_ARMN)](https://koha-community.org/manual/24.11//html/) (100%)
- [Chinese (Traditional)](https://koha-community.org/manual/24.11/zh_Hant/html/) (99%)
- [English](https://koha-community.org/manual/24.11//html/) (100%)
- [English (USA)](https://koha-community.org/manual/24.11/en/html/)
- [French](https://koha-community.org/manual/24.11/fr/html/) (63%)
- [German](https://koha-community.org/manual/24.11/de/html/) (99%)
- [Greek](https://koha-community.org/manual/24.11//html/) (97%)
- [Hindi](https://koha-community.org/manual/24.11/hi/html/) (71%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<!-- <div style="column-count: 2;"> -->

- Arabic (ar_ARAB) (96%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified) (86%)
- Chinese (Traditional) (100%)
- Czech (67%)
- Dutch (88%)
- English (100%)
- English (New Zealand) (61%)
- English (USA)
- Finnish (99%)
- French (100%)
- French (Canada) (98%)
- German (100%)
- Greek (67%)
- Hindi (97%)
- Italian (81%)
- Norwegian Bokmål (74%)
- Persian (fa_ARAB) (97%)
- Polish (99%)
- Portuguese (Brazil) (98%)
- Portuguese (Portugal) (88%)
- Russian (93%)
- Slovak (61%)
- Spanish (99%)
- Swedish (86%)
- Telugu (68%)
- Tetum (52%)
- Turkish (83%)
- Ukrainian (72%)
- hyw_ARMN (generated) (hyw_ARMN) (62%)
<!-- </div> -->

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](https://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](https://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](https://translate.koha-community.org/)

## Release Team

The release team for Koha 24.11.03 is


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
new features in Koha 24.11.03
<!-- <div style="column-count: 2;"> -->

- Athens County Public Libraries
- Chetco Community Public Library
- Deutsches Elektronen-Synchrotron DESY, Library
- Ignatianum University in Cracow
- Reserve Bank of New Zealand
<!-- </div> -->

We thank the following individuals who contributed patches to Koha 24.11.03
<!-- <div style="column-count: 2;"> -->

- Aleisha Amohia (1)
- Pedro Amorim (17)
- Tomás Cohen Arazi (1)
- Sukhmandeep Benipal (1)
- Matt Blenkinsop (4)
- Nick Clemens (10)
- David Cook (2)
- Jake Deery (1)
- Paul Derscheid (4)
- Roman Dolny (2)
- Jonathan Druart (8)
- Magnus Enger (1)
- Katrin Fischer (4)
- Eric Garcia (1)
- Lucas Gass (12)
- Andrew Fuerste Henry (2)
- Andreas Jonsson (1)
- Janusz Kaczmarek (1)
- Emily Lamancusa (7)
- Owen Leonard (11)
- Yanjun Li (1)
- David Nind (2)
- Martin Renvoize (3)
- Phil Ringnalda (2)
- Marcel de Rooy (2)
- Lisette Scheer (1)
- Lari Strand (1)
- Lari Taskula (1)
- Alexander Wagner (1)
<!-- </div> -->

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 24.11.03
<!-- <div style="column-count: 2;"> -->

- Athens County Public Libraries (11)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (4)
- [ByWater Solutions](https://bywatersolutions.com) (26)
- Catalyst Open Source Academy (1)
- Chetco Community Public Library (2)
- David Nind (2)
- desy.de (1)
- [Hypernova Oy](https://www.hypernova.fi) (1)
- Independant Individuals (2)
- jezuici.pl (2)
- Koha Community Developers (8)
- [Koha-Suomi Oy](https://koha-suomi.fi) (1)
- Kreablo AB (1)
- [Libriotech](https://libriotech.no) (1)
- [LMSCloud](lmscloud.de) (4)
- [Montgomery County Public Libraries](montgomerycountymd.gov) (7)
- [Prosentient Systems](https://www.prosentient.com.au) (2)
- [PTFS Europe](https://ptfs-europe.com) (25)
- Rijksmuseum, Netherlands (2)
- [Solutions inLibro inc](https://inlibro.com) (1)
- [Theke Solutions](https://theke.io) (1)
<!-- </div> -->

We also especially thank the following individuals who tested patches
for Koha
<!-- <div style="column-count: 2;"> -->

- Pedro Amorim (4)
- Tomás Cohen Arazi (3)
- Matt Blenkinsop (3)
- Fiona Borthwick (1)
- Amanda Campbell (1)
- Nick Clemens (2)
- Rebecca Coert (2)
- David Cook (1)
- Paul Derscheid (102)
- Roman Dolny (3)
- Jonathan Druart (7)
- Magnus Enger (5)
- Katrin Fischer (93)
- Lucas Gass (2)
- Victor Grousset (2)
- Kyle M Hall (3)
- JesseM (3)
- Jan Kissig (1)
- Emily Lamancusa (4)
- Brendan Lawlor (5)
- Owen Leonard (9)
- David Nind (21)
- Martin Renvoize (19)
- Phil Ringnalda (14)
- Marcel de Rooy (18)
- Lisette Scheer (2)
- Sam Sowanick (1)
- Jason Vasche (1)
- John Vinke (4)
<!-- </div> -->





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

Autogenerated release notes updated last on 24 Mar 2025 18:00:36.
