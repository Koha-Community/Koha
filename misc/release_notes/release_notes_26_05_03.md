# RELEASE NOTES FOR KOHA 26.05.03
24 Aug 2026

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 26.05.03 can be downloaded from:

- [Download](https://download.koha-community.org/koha-26.05.03.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 26.05.03 is a bugfix/maintenance release.

It includes 3 enhancements, 66 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [42736](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42736) SQL Injection in reports/cat_issues_top.pl via Criteria / Filter request parameters (unvalidated string context, no placeholders)
- [42800](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42800) Potential XSS in shelf list in the erm module
- [42904](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42904) Prevent XSS in patron restriction comments

## Bugfixes

### Acquisitions

#### Other bugs fixed

- [42225](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42225) On sites with many vendors spent.pl cannot load
  >This improves the SQL for the spent by fund report (Acquisitions > [All available funds section of the page]  > [select amount in the spent column for a fund that has a link]).
  >
  >This fixes an issue where there was a VERY large number of vendors in a system (260k + !!!), which resulted in a database error:
  >  ERROR 1038 (HY001): Out of sort memory, consider
  >  increasing server sort buffer size
- [42571](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42571) Sending EDI order results in variable not available warnings
- [42919](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42919) Suggestion duplicate warning erases suggestion info
- [43034](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43034) t/db_dependent/Koha/EDI.t fails when SearchEngine is Elasticsearch

### Architecture, internals, and plumbing

#### Critical bugs fixed

- [42992](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42992) FTP file transport list_files() corrupts filenames
- [43121](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43121) Vue: Don't pattern match on translatable strings

#### Other bugs fixed

- [42551](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42551) C3 merge error when syntax checking some installed plugins
- [43101](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43101) search_for_data_inconsistencies.pl creates a query that ORs every biblionumber in the catalog
  >This fixes the search for data inconsistencies script (misc/maintenance/search_for_data_inconsistencies.pl) so that it now runs significantly faster - it replaces OR with IN for subqueries.
  >
  >Technical details:
  >
  >1. Queries that use OR instead of IN are less efficient and can lead to situations where the query takes a very long time to complete due to row level scanning. Example: We found one instance where they query had been running for over 10 days!
  >
  >2. This fix makes ids() return a subquery instead of a list of results, and switches the callers to using IN. The database now resolves the set itself and the queries stay a constant size no matter how large the catalog is. This is super efficient because the subquery doesn't even execute as a separate query since biblionumber is the primary key!

### Cataloging

#### Other bugs fixed

- [42166](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42166) Cannot Edit as new (duplicate) a record without a 008 in the advanced editor
- [42512](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42512) MARC control field length detection prevents editing of records with invalid MARCXML
- [42874](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42874) z3950_auth_search is losing index parameter
- [43206](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43206) cn_browser plugin red background on exact match is hard to read

  **Sponsored by** *Athens County Public Libraries*

### Circulation

#### Other bugs fixed

- [36762](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36762) Item not transferred correctly when there is a pending hold
  >This fixes two issues when transferring an item that could fill a pending hold to a library that is not the holds pickup library:
  >1. Koha only gives you an option to transfer the item to the pickup library. When this option is chosen, Koha says that item is being transferred to the selected library, not to the pickup library. Then it fails to create the transfer.
  >2. Adds a new option ("Ignore hold and transfer to [Library name]") to ignore the hold and transfer the item to the library selected in the transfer tool.

  **Sponsored by** *Koha-Suomi Oy*
- [41358](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41358) action logs info column should always store JSON

  **Sponsored by** *OpenFifth*
- [42930](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42930) Overdues (circ/overdue.pl) incorrectly shows bibliographic record title in patron column instead of the patron's title (salutation)
  >This fixes the information shown in the overdues report patron column (Circulation > Overdues > Overdues). The bibliographic record title was shown before the patron's name, instead of the patron's title (salutation).
  >
  >(Related to bug 41343 - Overdue report is too intensive on systems with many overdues, added to Koha 26.05 and 25.11.)
- [43001](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43001) Non priority hold label doesn't always appear on the staff interface holds page for a record (reserve/request.pl)
  >This fixes the holds page in the staff interface for a record. When placing a non priority hold ("Non priority hold" option selected), "Non priority hold" text (in italics) was not showing in the details column for the hold.

### Command-line Utilities

#### Other bugs fixed

- [35948](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35948) cleanup_database.pl should remove not only finished background jobs
- [39208](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39208) printoverdues.sh requires unavailable cli tool xhtml2pdf
- [42861](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42861) System warning about missing encryption_key on a fresh instance
  >This fixes the koha-create command so that it generates the random encryption key required for passwords and sensitive data.
  >
  >It uses pwgen with the number of characters set to 32, and adds the <encryption_key> entry to the instance's koha-conf.xml file.

### ERM

#### Other bugs fixed

- [42522](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42522) Holdings created in ERM with a linked bibliographic record do not show the link to the record
- [42933](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42933) ERM - Error adding a license to an agreement when leaving non-mandatory fields empty
  >This fixes an issue for the ERM module when adding a license to an agreement. The status field for the license was not shown as required. This generated an error message if you attempted to add a license without selecting a value for the status field: "Something went wrong: Error: Expected string - got null.". The status field is now marked as required.
  >
  >(Related to Bug 38201 - VueJS architecture rethink, added to Koha 25.11.)
- [42981](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42981) ERM package result list hangs when filtering by vendor and search status is saved

### Hold requests

#### Critical bugs fixed

- [42915](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42915) Filtering Holds table by patron name or pickup library is broken

  **Sponsored by** *Cape Libraries Automated Materials Sharing*
- [42999](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42999) $valid_items flag contamination in reserve/request.pl causes non-holdable items to appear as available after the first holdable item in the loop
  >This fixes placing holds using the staff interface for a specific item, where there is an item that has a "Not for loan" status.
  >
  >Previously, you could select the item that is not for loan.
  >
  >Now the item that is not for loan has an "X Not for loan" in red in the hold column, and you can't select it.
- [43033](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43033) Holds queue allocate with transport cost matrix can choose impossible holds
- [43174](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43174) Regressions: Staff interface patron search on a record details page - lists patrons by default

#### Other bugs fixed

- [33364](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33364) Stop holds to pull report showing items that have been allocated to a recall
  >This fixes the "Holds to pull" circulation report to exclude items that have pending recalls (recalled items waiting for pickup or in transit for a patron).

  **Sponsored by** *Catalyst*
- [41227](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41227) SuspendHoldsIntranet have no effect
- [41879](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41879) Holds that move to a new bib can be unfillable

### ILL

#### Other bugs fixed

- [42617](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42617) ILL availability pagination not working

### Installation and upgrade (command-line installer)

#### Critical bugs fixed

- [42886](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42886) CSS files not installed

#### Other bugs fixed

- [42850](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42850) ILL requests stylesheet is not installed

### MARC Authority data support

#### Other bugs fixed

- [42920](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42920) Looking up authority records in Advanced editor appends 20 extra spaces

  **Sponsored by** *Chetco Community Public Library*

### OPAC

#### Other bugs fixed

- [41796](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41796) "Forgot your password" link is not visible if OpacResetPassword is enabled but OpacPasswordChange is disabled
- [41988](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41988) OPAC: News RSS links with HTML not working
- [42066](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42066) CSRF-token sometimes missing from pages
- [42579](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42579) Checkout history export "title" column too long
- [42912](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42912) Javascript error on opac-readingrecord when no Circulation history

### Patrons

#### Other bugs fixed

- [41946](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41946) Superlibrarian should be able to set protected status on patron creation
- [43069](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43069) Empty PatronDuplicateMatchingAddFields considers every new patron as duplicate

### Plugin architecture

#### Other bugs fixed

- [42430](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42430) Fix issue with stale plugin methods after plugin upgrade

### Point of Sale

#### Critical bugs fixed

- [41819](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41819) Refunds via the Cash registers page should not result in PAYOUTS if the transaction type is 'Account Credit'

### Reports

#### Other bugs fixed

- [8127](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8127) Most-circulated items report doesn't work when limited by library
  >This fixes some of the filters for the "Most-circulated items" report so that using limits (the Limits section with "Limit to" and "By") now works.
  >
  >Previously some options for "By" (such as Library and Week) generated an error message or there were no results (when results were expected).
- [43098](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43098) Typo in URL for "Edit SQL" button in guided reports (guided_reports_start.tt)
  >This fixes a typo in the URL when editing the SQL in reports. If there is an error in the SQL, the "Edit SQL" button would take you to the guided reports wizard, instead of letting you edit the SQL for the report.
  >
  >(Changes ".../guided_reports.pl?op=edit_formid=..." to ".../guided_reports.pl?op=edit_form&id=..." - note the missing &)

### SIP2

#### Critical bugs fixed

- [42988](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42988) Saving a SIP account imported from SIPconfig.xml can change the holds (Holds get captured -  holds_get_captured) behavior

### Searching - Elasticsearch

#### Critical bugs fixed

- [42669](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42669) es_indexer_daemon.pl silently marks jobs finished on indexing failure and doesn't recover from NoNodes
  >The Elasticsearch indexer daemon (es_indexer_daemon.pl) was silently marking background indexing jobs as "finished" even when Elasticsearch was unreachable, causing records to disappear from search results with no indication of failure. Additionally, after a brief ES outage (e.g. a Docker restart), the daemon's connection pool would mark the node as dead with exponential backoff, leaving it permanently stuck until manually restarted. The daemon now resets jobs to "new" on NoNodes errors so they are automatically retried once connectivity is restored, recreates the ES client to reset the connection pool, and correctly marks jobs as "failed" for other indexing errors.

### Serials

#### Other bugs fixed

- [42699](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42699) Editing an already received serial with a duplicate barcode leads to Error 500

  **Sponsored by** *Koha-Suomi Oy*

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
- [42799](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42799) Toolbar stickiness implementation is flaky
- [42986](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42986) JS error when writing off selected charges

### System Administration

#### Other bugs fixed

- [42568](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42568) Match maxlength attributes to marc_order_accounts column sizes

  **Sponsored by** *Athens County Public Libraries*
- [42618](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42618) Incorrect sidebar menu link to MARC order accounts

  **Sponsored by** *Athens County Public Libraries*
- [42885](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42885) FineNoRenewals description mentions fines rather than charges

### Templates

#### Other bugs fixed

- [42519](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42519) Terminology: branch should be library
  >This fixes the terminology used for the default message in the "Self-renewal failure message" field (Administration > Patrons and circulation > Patron categories > Account expiry and self-renewal). "...your local branch..." changed to "...your library...".
- [42928](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42928) Terminology: Log viewer results - show "Check-in" instead of "Return" in the action column
  >This fixes the terminology used in the log viewer tool results. "Check-in" (noun) is now used instead of "Return".
- [43046](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43046) Checkbox labels in Currencies and EDI accounts have unnecessary colons

### Test Suite

#### Other bugs fixed

- [42937](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42937) `$Test::Strict::TEST_STRICT = 0;` no longer needed in t/db_dependent/00-strict.t
- [43071](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43071) Test failures when Holds Allowed (daily) has a value

### Tools

#### Other bugs fixed

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

### Tools

#### Enhancements

- [42118](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42118) Update various admin pages to use grid layout for forms - Part 2

  **Sponsored by** *Athens County Public Libraries*

## New system preferences

- EnableZotero

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [English (USA)](https://koha-community.org/manual/26.05/en/html/)
- [French](https://koha-community.org/manual/26.05/fr/html/) (83%)
- [German](https://koha-community.org/manual/26.05/de/html/) (84%)
- [Greek](https://koha-community.org/manual/26.05/el/html/) (91%)
- [Hindi](https://koha-community.org/manual/26.05/hi/html/) (62%)
- [Portuguese (Brazil)](https://koha-community.org/manual/26.05/pt_BR/html/) (28%)

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
- Spanish (94%)
- Swedish (88%)
- Telugu (62%)
- Turkish (76%)
- Ukrainian (71%)
- Uzbek (53%)
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

The release team for Koha 26.05.03 is

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
new features in Koha 26.05.03
<div style="column-count: 2;">

- Athens County Public Libraries
- [Cape Libraries Automated Materials Sharing](https://info.clamsnet.org)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)
- Chetco Community Public Library
- [Koha-Suomi Oy](https://koha-suomi.fi)
- [OpenFifth](https://openfifth.co.uk)
</div>

We thank the following individuals who contributed patches to Koha 26.05.03
<div style="column-count: 2;">

- Saiful Amin (1)
- Aleisha Amohia (1)
- Pedro Amorim (4)
- Tomás Cohen Arazi (3)
- Matt Blenkinsop (2)
- Nick Clemens (6)
- David Cook (1)
- Paul Derscheid (3)
- Jonathan Druart (30)
- Laura Escamilla (2)
- Katrin Fischer (1)
- Andrew Fuerste-Henry (1)
- Lucas Gass (17)
- Amit Gupta (1)
- Kyle M Hall (10)
- Andreas Jonsson (1)
- Jan Kissig (3)
- Emily Lamancusa (1)
- Brendan Lawlor (4)
- Owen Leonard (4)
- Chris Mathevet (1)
- Andrew Nugged (1)
- Sanjar Tulkinov Anvar o'g'li (1)
- Martin Renvoize (20)
- Phil Ringnalda (1)
- Jason Robb (1)
- Adolfo Rodríguez (1)
- Caroline Cyr La Rose (1)
- Slava Shishkin (1)
- Fridolin Somers (1)
- Samuel Sowanick (2)
- Emmi Takkinen (3)
- Lari Taskula (1)
- Hammat Wele (3)
- Baptiste Wojtkowski (3)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 26.05.03
<div style="column-count: 2;">

- Athens County Public Libraries (4)
- [BibLibre](https://www.biblibre.com) (4)
- [Bibliotheksservice-Zentrum Baden-Württemberg (BSZ)](https://bsz-bw.de) (1)
- [ByWater Solutions](https://bywatersolutions.com) (36)
- [Cape Libraries Automated Materials Sharing](https://info.clamsnet.org) (4)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha) (1)
- Chetco Community Public Library (1)
- corvallisoregon.gov (2)
- [Hypernova Oy](https://www.hypernova.fi) (1)
- Independant Individuals (3)
- informaticsglobal.ai (1)
- Koha Community Developers (30)
- [Koha-Suomi Oy](https://koha-suomi.fi) (3)
- Kreablo AB (1)
- [LMSCloud](https://www.lmscloud.de) (3)
- [Montgomery County Public Libraries](https://montgomerycountymd.gov) (1)
- [OpenFifth](https://openfifth.co.uk) (26)
- [Prosentient Systems](https://www.prosentient.com.au) (1)
- semanticconsulting.com (1)
- [Solutions inLibro inc](https://inlibro.com) (5)
- [South East Kansas Library System](http://www.sekls.org) (1)
- [Theke Solutions](https://theke.io) (3)
- Wildau University of Technology (3)
- [Xercode](https://xebook.es) (1)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Aleisha Amohia (3)
- Tomás Cohen Arazi (1)
- Kris Becker (1)
- Matt Blenkinsop (1)
- Nick Clemens (4)
- David Cook (4)
- Paul Derscheid (7)
- Trevor Diamond (1)
- Roman Dolny (3)
- Jonathan Druart (13)
- Laura Escamilla (10)
- Katrin Fischer (2)
- Andrew Fuerste-Henry (8)
- Lucas Gass (123)
- Gretchen (1)
- Victor Grousset (15)
- Bo Gustavsson (1)
- Jan Kissig (1)
- Emily Lamancusa (2)
- Owen Leonard (3)
- Michaela (2)
- David Nind (52)
- Eric Phetteplace (3)
- Martin Renvoize (26)
- Phil Ringnalda (2)
- Jason Robb (16)
- Caroline Cyr La Rose (2)
- Lisette Scheer (12)
- Michaela Sieber (1)
- Edith Speller (1)
- Emmi Takkinen (1)
- Felicie Thiery (1)
- Baptiste Wojtkowski (1)
- Anneli Österman (1)
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

Autogenerated release notes updated last on 24 Aug 2026 22:34:58.
