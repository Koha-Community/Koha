# RELEASE NOTES FOR KOHA 25.05.06
04 Dec 2025

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 25.05.06 can be downloaded from:

- [Download](https://download.koha-community.org/koha-25.05.06.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 25.05.06 is a bugfix/maintenance release.

It includes 58 bugfixes, 2 of them are security fixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [35830](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35830) Add separate permission for Merging Patrons

  **Sponsored by** *Cape Libraries Automated Materials Sharing*
- [40524](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40524) Stored XSS run by DataTables Print button in staff interface

## Bugfixes

### Accessibility

#### Other bugs fixed

- [41198](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41198) Add visible “Sort results by” label above the sort dropdown for accessibility and clarity
  >Adds a visible “Sort results by” label above the sort dropdown in OPAC search results to improve accessibility and clarity.
- [41201](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41201) Definite article in some labels confuses screen readers

### Acquisitions

#### Other bugs fixed

- [38516](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38516) Closed group basket not able to open pdf file with adobe  The root object is missing or invalid
- [40988](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40988) Subfunds in acqui-home.pl and aqbudgets.pl are not collapsible beyond 20th line
- [41100](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41100) EDI vendor account port numbers no longer editable
  >This fixes editing EDI account port numbers in Koha 25.05.x. When editing the port numbers for an account (Administration > Acquisition parameters > EDI accounts), the changes were not saved.

### Architecture, internals, and plumbing

#### Other bugs fixed

- [40559](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40559) Fix a noisy warn in catalogue/MARCdetail
- [41024](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41024) Inconsistent spelling of Borrower(s)Log
- [41032](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41032) Open Fifth missing in plugin repos config
  >This updates the template used when creating Koha instances  - it changes the plugin repository details for Open Fifth (previously PTFS-Europe), so that you can search and install plugins using the staff interface.
  >
  >To update existing Koha instances (where uploading and installing plugins from Git repositories is enabled) change the PTFS-Europe details to Open Fifth in the /etc/koha/sites/<instancename>/koha-conf.xml:
  >
  >  <repo>
  >     <name>Open Fifth</name>
  >     <org_name>openfifth</org_name>
  >     <service>github</service>
  >  </repo>
- [41044](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41044) Fix argument isn't numeric in addition in Koha::Item::find_booking
- [41104](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41104) Samesite HTTP response header being set in C4::Auth::checkauth()
- [41123](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41123) Remove useless dbh statement from Patron
- [41262](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41262) Duplicate import in Koha::Patron

### Authentication

#### Other bugs fixed

- [41038](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41038) Add more test coverage for bug 30724

### Cataloging

#### Other bugs fixed

- [41205](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41205) Error in Advanced Cataloging editor when z39 source returns undef / empty records

### Circulation

#### Critical bugs fixed

- [40205](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40205) "Default checkout, hold and return policy" cannot be unset
- [41314](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41314) Column visibility broken on the checkouts table
  >This fixes the display of the 'Export' column on a patron's check out and details sections when ExportCircHistory is enabled and disabled. Because of a regression (caused by DataTable's saveState, bug 33484), the column was not correctly shown unless you cleared the cache/local storage:
  >- If ExportCircHistory was set to 'Show', it is shown the first time.
  >- If ExportCircHistory is then set to 'Don't show', the export column continues to show until you clear the browser cache/local storage.

#### Other bugs fixed

- [24533](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24533) Improved sorting in checkouts table
- [41149](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41149) Spinner/loader does not disappear when a renewal fails with AllowRenewalOnHoldOverride set to dont allow
- [41298](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41298) Filtering holdings table with status In transit considers every item ever transferred to be "In transit"

### Command-line Utilities

#### Other bugs fixed

- [39532](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39532) Script debar_patrons_with_fines.pl should not use MANUAL restriction type
- [41008](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41008) bulkmarcimport.pl -d broken for authorities

### ERM

#### Critical bugs fixed

- [38446](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38446) Permission error for additional fields

  **Sponsored by** *Karlsruhe Institute of Technology (KIT)*

### ILL

#### Other bugs fixed

- [41257](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41257) ILL "List requests"/"Refresh" wording doesn't work

### Installation and upgrade (command-line installer)

#### Critical bugs fixed

- [41167](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41167) Rewrite Rules missing in etc/koha-httpd.conf

### Notices

#### Other bugs fixed

- [39985](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39985) items.onloan field is not updated when an item is recalled

  **Sponsored by** *Auckland University of Technology*

### OPAC

#### Other bugs fixed

- [30633](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30633) Move OPACHoldingsDefaultSortField to table settings configuration
  >Restore the ability to define a default sort order for the holdings table at the OPAC.
  >It replaces the system preference "OPACHoldingsDefaultSortField" that had been broken for a while. Note that its value is not migrated.
- [38080](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38080) Sorting options for holdings table are incorrect
  >This fixes the default sort order for the OPAC holdings table, so that the default table sorting setting is used. Previously, it was not correctly using this setting (for example, setting the shelving location as the default sort order did not work).
- [40836](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40836) Credit and debit types are not shown in patron account on OPAC
- [40873](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40873) AV dropdowns in OPAC don't use lib_opac values
  >This fixes the value displayed in dropdown lists for authorized values in the OPAC. The value entered in the 'Description (OPAC)' field is now shown for authorized value dropdown lists. Previously, the value shown was what was in the 'Description' field.
  >
  >Example: for the SUGGEST_FORMAT authorized value category, the value in 'Description (OPAC)' is now shown in the dropdown list for the item type field on the purchase suggestion form in the OPAC.
- [40903](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40903) OPAC advanced search applies a location limit of the logged-in library by default
- [41078](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41078) Improve handling of multiple covers on shelves/lists results in the OPAC
- [41168](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41168) "Search the catalog by keyword" confuses some users
  >This updates the main OPAC search field hint text from "Search the catalog by keyword" to "Search the catalog". This avoids any confusion about only being able to search by keyword.
- [41177](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41177) Breadcrumbs should have aria-disabled attribute if its the current page

### Patrons

#### Critical bugs fixed

- [41094](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41094) search_anonymize_candidates returns too many candidates when FailedLoginAttempts is empty

#### Other bugs fixed

- [29908](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29908) Warning when empty ClaimReturnedWarningThreshold in patron_messages.inc
- [41039](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41039) Patron search button can be spammed and trigger many API patron searches
- [41053](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41053) Make notice contents searchable on notices tab of patron details
- [41067](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41067) 'OPAC mandatory' attribute setting requires 'Editable in OPAC' to work
- [41212](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41212) members/maninvoice.pl debit_types should sort by description not code

### Plugin architecture

#### Other bugs fixed

- [25952](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25952) Github search errors make it impossible to install plugins from other repos
  >This fixes the error 500 "malformed JSON string" message when something goes wrong searching for plugins using the plugin search in the staff interface (for example, when there is an invalid repository in the Koha configuration).
- [40983](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40983) Remove deprecated syntax for 'after_biblio_action' hooks
  >IMPORTANT: The former biblio and biblio_id params of after_biblio_action hooks/plugins have been removed now. They were deprecated on bug 36343 and replaced by the payload hash. Please adjust your plugins using them, if you did not do so already.

### Point of Sale

#### Other bugs fixed

- [40625](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40625) Prevent cashup re-submissions on page reload

### REST API

#### Critical bugs fixed

- [39336](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39336) Public Biblio endpoint should honour OpacSuppression syspref

### Reports

#### Other bugs fixed

- [40961](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40961) LocalUse Circulation Statistics offering empty results
- [41082](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41082) Renaming columns in reports doesn't work with batch tools
- [41112](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41112) Space is missing in report preview
  >This fixes the 'Delete' button when previewing the SQL for a saved report - there is now a space between the trash can icon and Delete.

### Staff interface

#### Critical bugs fixed

- [38072](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38072) Regression with modalPrint
  >This fixes a regression when printing dialogue boxes in certain Chromium-based browsers, for example, when printing the cashup summary for the point of sale system. Sometimes the print dialog failed to open, and instead you were faced with a flash of white before the new tab automatically closed and didn't print.
- [41229](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41229) Cash registers are not fully reset on library change

### System Administration

#### Other bugs fixed

- [41092](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41092) Some system preferences have target='blank' instead of target='_blank'
  >This fixes the HTML target attribute for some system preference links that open a pop-up window or external link. The link attribute now uses "_blank" instead of "blank", and opens in a new tab for external links, and the same browser window for pop-up windows (modals).

### Templates

#### Other bugs fixed

- [40664](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40664) Serial subscription input missing "Required" labels
  >This fixes the second page of the new serial subscription form - it adds missing "Required" labels next to two mandatory fields
  >('Frequency' and 'Subscription start date').
- [40720](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40720) Misleading title attribute "Remove all items" in Select2 fields
  >Improvement: Updated Select2 title text for clarity
  >
  >This patch updates the Select2 initialization script to improve accessibility and clarity. The title attribute on the “X” control (used to clear selections in Select2 dropdowns) now reads “Clear selections” instead of “Clear items,” eliminating ambiguity.

  **Sponsored by** *Athens County Public Libraries*
- [40760](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40760) 'Edit' link in item receive table is not formatted as link
- [41207](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41207) Permission description string does match permission name

  **Sponsored by** *Cape Libraries Automated Materials Sharing*

### Test Suite

#### Other bugs fixed

- [38475](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38475) InfiniteScrollSelect_spec.ts is failing randomly again
- [40845](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40845) t/Koha/Manual.t only passes for 25.05 and 25.06

### Tools

#### Other bugs fixed

- [40843](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40843) On modborrowers.pl patron attributes should sort by the description, not the code
  >This patch fixes a problem in the batch patron modification tool where extended patron attributes were sorting based on the code, instead of the description.

## Deleted system preferences

- OPACHoldingsDefaultSortField

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [English (USA)](https://koha-community.org/manual/25.05/en/html/)
- [French](https://koha-community.org/manual/25.05/fr/html/) (75%)
- [German](https://koha-community.org/manual/25.05/de/html/) (94%)
- [Greek](https://koha-community.org/manual/25.05/el/html/) (98%)
- [Hindi](https://koha-community.org/manual/25.05/hi/html/) (67%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (92%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (99%)
- Chinese (Simplified Han script) (83%)
- Chinese (Traditional Han script) (97%)
- Czech (66%)
- Dutch (85%)
- English (100%)
- English (New Zealand) (61%)
- English (USA)
- Finnish (99%)
- French (99%)
- French (Canada) (99%)
- German (99%)
- Greek (65%)
- Hindi (94%)
- Italian (80%)
- Norwegian Bokmål (71%)
- Persian (fa_ARAB) (93%)
- Polish (99%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (86%)
- Russian (92%)
- Slovak (58%)
- Spanish (98%)
- Swedish (88%)
- Telugu (65%)
- Turkish (80%)
- Ukrainian (70%)
- Western Armenian (hyw_ARMN) (60%)
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

The release team for Koha 25.05.06 is


- Release Manager: Lucas Gass

- QA Manager: Martin Renvoize

- QA Team:
  - Andrew Fuerste-Henry
  - Andrii Nugged
  - Baptiste Wojtkowski
  - Brendan Lawlor
  - David Cook
  - Emily Lamancusa
  - Jonathan Druart
  - Julian Maurice
  - Kyle Hall
  - Laura Escamilla
  - Lisette Scheer
  - Marcel de Rooy
  - Nick Clemens
  - Paul Derscheid
  - Petro V
  - Tomás Cohen Arazi
  - Victor Grousset

- Documentation Manager: David Nind

- Documentation Team:
  - Aude Charillon
  - Caroline Cyr La Rose
  - Donna Bachowski
  - Heather Hernandez
  - Kristi Krueger
  - Philip Orr

- Translation Manager: Jonathan Druart


- Wiki curators: 
  - George Williams
  - Thomas Dukleth

- Release Maintainers:
  - 25.05 -- Paul Derscheid
  - 24.11 -- Fridolin Somers
  - 24.05 -- Jesse Maseto
  - 22.11 -- Catalyst IT (Wainui, Alex, Aleisha)

- Release Maintainer assistants:
  - 25.05 -- Martin Renvoize
  - 24.11 -- Baptiste Wojtkowski
  - 24.05 -- Laura Escamilla

## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 25.05.06
<div style="column-count: 2;">

- Athens County Public Libraries
- Auckland University of Technology
- [Cape Libraries Automated Materials Sharing](https://info.clamsnet.org)
- Karlsruhe Institute of Technology (KIT)
</div>

We thank the following individuals who contributed patches to Koha 25.05.06
<div style="column-count: 2;">

- Aleisha Amohia (1)
- Pedro Amorim (2)
- Tomás Cohen Arazi (3)
- Matt Blenkinsop (1)
- Nick Clemens (1)
- David Cook (3)
- Jake Deery (2)
- Paul Derscheid (8)
- Jonathan Druart (19)
- Laura Escamilla (2)
- Katrin Fischer (1)
- Andrew Fuerste-Henry (1)
- Lucas Gass (5)
- Kyle M Hall (4)
- Jan Kissig (1)
- Vivek Kumar (1)
- Brendan Lawlor (1)
- lawrenceol-clams (1)
- Owen Leonard (3)
- Eric Phetteplace (1)
- Martin Renvoize (8)
- Marcel de Rooy (9)
- Caroline Cyr La Rose (2)
- Slava Shishkin (1)
- Fridolin Somers (2)
- Lari Taskula (3)
- Baptiste Wojtkowski (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 25.05.06
<div style="column-count: 2;">

- Athens County Public Libraries (3)
- bestbookbuddies.com (1)
- [BibLibre](https://www.biblibre.com) (3)
- [Bibliotheksservice-Zentrum Baden-Württemberg (BSZ)](https://bsz-bw.de) (1)
- [ByWater Solutions](https://bywatersolutions.com) (13)
- [Cape Libraries Automated Materials Sharing](https://info.clamsnet.org) (2)
- Catalyst Open Source Academy (1)
- [Hypernova Oy](https://www.hypernova.fi) (3)
- Independant Individuals (2)
- Koha Community Developers (19)
- [LMSCloud](https://www.lmscloud.de) (8)
- [Open Fifth](https://openfifth.co.uk/) (13)
- [Prosentient Systems](https://www.prosentient.com.au) (3)
- Rijksmuseum, Netherlands (9)
- [Solutions inLibro inc](https://inlibro.com) (2)
- [Theke Solutions](https://theke.io) (3)
- Wildau University of Technology (1)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Aleisha Amohia (5)
- Tomás Cohen Arazi (1)
- Sarah Berry (1)
- Matt Blenkinsop (1)
- Nick Clemens (3)
- David Cook (8)
- Jake Deery (1)
- Paul Derscheid (83)
- Trevor Diamond (1)
- Jonathan Druart (2)
- Magnus Enger (2)
- Laura Escamilla (6)
- Andrew Fuerste-Henry (1)
- Brendan Gallagher (1)
- Lucas Gass (72)
- Kyle M Hall (2)
- Jan Kissig (3)
- Brendan Lawlor (5)
- Owen Leonard (13)
- CJ Lynce (1)
- David Nind (18)
- Martin Renvoize (16)
- Phil Ringnalda (1)
- Jason Robb (1)
- Marcel de Rooy (17)
- Caroline Cyr La Rose (1)
- Lisette Scheer (6)
- Michaela Sieber (7)
- Arthur Suzuki (1)
- Emmi Takkinen (1)
- Baptiste Wojtkowski (3)
- Katherine Wolf (1)
- Anneli Österman (1)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 25.05.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 04 Dec 2025 09:22:01.
