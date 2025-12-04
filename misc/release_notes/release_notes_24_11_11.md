# RELEASE NOTES FOR KOHA 24.11.11
04 Dec 2025

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 24.11.11 can be downloaded from:

- [Download](https://download.koha-community.org/koha-24.11.11.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 24.11.11 is a bugfix/maintenance release.

It includes 76 bugfixes (1 security).

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [40524](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40524) Stored XSS run by DataTables Print button in staff interface

## Bugfixes

### Acquisitions

#### Other bugs fixed

- [38516](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38516) Closed group basket not able to open pdf file with adobe  The root object is missing or invalid
- [40988](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40988) Subfunds in acqui-home.pl and aqbudgets.pl are not collapsible beyond 20th line
- [41100](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41100) EDI vendor account port numbers no longer editable
  >This fixes editing EDI account port numbers in Koha 25.05.x. When editing the port numbers for an account (Administration > Acquisition parameters > EDI accounts), the changes were not saved.

### Architecture, internals, and plumbing

#### Other bugs fixed

- [40041](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40041) Update mailmap for 25.11.x
- [40265](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40265) t/db_dependent/OAI/Server.t is failing randomly
- [40559](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40559) Fix a noisy warn in catalogue/MARCdetail
- [40820](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40820) STOMP errors even when JobsNotificationMethod='polling'
- [40978](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40978) t/db_dependent/Budgets.t fails on Debian 13 due to warnings
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

### Cataloging

#### Critical bugs fixed

- [40997](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40997) Javascript error prevents saving when an instance of an 'important' or 'required' field is deleted

#### Other bugs fixed

- [40897](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40897) Uneven field lengths in additem.tt
- [41205](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41205) Error in Advanced Cataloging editor when z39 source returns undef / empty records

### Circulation

#### Critical bugs fixed

- [40205](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40205) "Default checkout, hold and return policy" cannot be unset

#### Other bugs fixed

- [40899](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40899) When placing multiple holds at once the individual "Pickup location:" dropdowns do not update when changing the top level "Pickup at:" dropdown"
  >This fixes a problem where the item specific branch choice was not being set correctly when placing a hold on multiple items at the same time in the staff interface.
- [41149](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41149) Spinner/loader does not disappear when a renewal fails with AllowRenewalOnHoldOverride set to dont allow
- [41298](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41298) Filtering holdings table with status In transit considers every item ever transferred to be "In transit"

### Command-line Utilities

#### Critical bugs fixed

- [40953](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40953) marc_ordering_process.pl broken due to accidental newline

#### Other bugs fixed

- [35700](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35700) Holds reminder cronjob --triggered switch does not work as intended if the day to send notice hits concurrent holidays
  >This bugfix adds a check to the hold reminders cronjob so the job will skip if today is a holiday when the --holiday flag is used. 
  >
  >This will prevent the notice from repeating reminders that would send on a usually closed day again on the next open day.
- [40785](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40785) Cronjob cleanup_database.pl usage is outdated
- [41008](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41008) bulkmarcimport.pl -d broken for authorities

### Developer documentation

#### Other bugs fixed

- [40027](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40027) Use GitHub workflow to automatically close PRs opened on the Koha repo there

### ERM

#### Critical bugs fixed

- [37622](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37622) "location" header is set for non-POST routes

### Hold requests

#### Other bugs fixed

- [40929](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40929) Can't call method "borrowernumber" on an undefined value at opac-modrequest.pl
- [40985](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40985) Clarify POD of Holds->filter_by_found

### ILL

#### Other bugs fixed

- [40171](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40171) ILL Patron Has No Email Address on File message upon "Send Notice To Patron"
  >Staff members now receive clear feedback when attempting to send ILL notices to patrons who have no email address on file or haven't configured their messaging preferences for interlibrary loan notifications.
  >
  >Previously, when clicking "Send notice to patron" for an ILL request, staff received no indication whether the notice was successfully queued for delivery. If the patron had no email address or hadn't opted in to ILL messaging preferences, the notice would silently fail to send, leaving staff unaware that the patron wasn't notified.
  >
  >With this enhancement:
  >- A warning message now displays if the notice cannot be queued: "The requested notice was NOT queued for delivery by email, SMS"
  >- A success message displays when the notice is successfully queued
  >- Staff can immediately see when they need to contact the patron through alternative means (such as telephone)
  >
  >**For staff:** If you see the warning message, check the patron's record to ensure:
  >1. They have a valid email address on file
  >2. They have enabled ILL messaging preferences (Interlibrary loan ready / Interlibrary loan unavailable) in their patron messaging preferences
- [41057](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41057) OPAC ILL visiting a URL directly does not respect ILLOpacbackends
- [41257](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41257) ILL "List requests"/"Refresh" wording doesn't work

### Installation and upgrade (command-line installer)

#### Critical bugs fixed

- [41167](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41167) Rewrite Rules missing in etc/koha-httpd.conf

### Label/patron card printing

#### Other bugs fixed

- [40473](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40473) X scale for Code39 barcodes is calculated incorrectly when generating barcode labels

### MARC Bibliographic data support

#### Other bugs fixed

- [40959](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40959) LOC classification display broken
  >This fixes the display logic for the Library of Congress classification field (050) in the staff interface for MARC21. The separator was being shown between subfields $a and $b, instead of between additional 050 entries.
  >
  >Example: 
  >
  >For an 050 with two entries: 
  >
  > 050  4 $aE337.5 $b.O54 2025
  > 050  4 $aE415.7 $b.A44 2025
  >
  >This was incorrectly shown in the staff interface as:
  >
  > LOC classification: E337.5 | .O54 2025 E415.7 | .A44 2025
  >
  >It should have been shown as:
  >
  >  LOC classification: E337.5 O54 2025 | E415.7 A44 2025

### Notices

#### Other bugs fixed

- [39985](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39985) items.onloan field is not updated when an item is recalled

  **Sponsored by** *Auckland University of Technology*

### OPAC

#### Other bugs fixed

- [38080](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38080) Sorting options for holdings table are incorrect
  >This fixes the default sort order for the OPAC holdings table, so that the default table sorting setting is used. Previously, it was not correctly using this setting (for example, setting the shelving location as the default sort order did not work).
- [40836](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40836) Credit and debit types are not shown in patron account on OPAC
- [40873](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40873) AV dropdowns in OPAC don't use lib_opac values
  >This fixes the value displayed in dropdown lists for authorized values in the OPAC. The value entered in the 'Description (OPAC)' field is now shown for authorized value dropdown lists. Previously, the value shown was what was in the 'Description' field.
  >
  >Example: for the SUGGEST_FORMAT authorized value category, the value in 'Description (OPAC)' is now shown in the dropdown list for the item type field on the purchase suggestion form in the OPAC.
- [40903](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40903) OPAC advanced search applies a location limit of the logged-in library by default

### Patrons

#### Critical bugs fixed

- [35830](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35830) Add separate permission for Merging Patrons

  **Sponsored by** *Cape Libraries Automated Materials Sharing*
- [41094](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41094) search_anonymize_candidates returns too many candidates when FailedLoginAttempts is empty

#### Other bugs fixed

- [29908](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29908) Warning when empty ClaimReturnedWarningThreshold in patron_messages.inc
- [39408](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39408) Cannot add patron via API if AutoEmailNewUser and WELCOME content blank
- [40605](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40605) Synchronize two sentences about processing personal data
- [40936](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40936) Add index for default patron sort order
  >This change introduces a new database index to improve the performance of patron searches, especially in large databases. This will prevent slow searches and potential database server issues related to sorting patrons by name and address.
  >
  >**System Administrator Note:**
  >Applying this update will add a new index to the `borrowers` table. On systems with a large number of patrons, this operation can take a significant amount of time and consume considerable server resources (CPU and I/O).
  >
  >While modern database systems can often perform this operation without locking the table for the entire duration, a general slowdown of the system is expected. It is **strongly recommended** to run the upgrade (`updatedatabase.pl`) during a planned maintenance window to avoid impacting users.
- [41039](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41039) Patron search button can be spammed and trigger many API patron searches
  >Every click of the "Search" button in patrons searching form
  >was triggering another patron search API request.
  >This button is now disabled after click until the first searches results are displayed.
- [41212](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41212) members/maninvoice.pl debit_types should sort by description not code

### Point of Sale

#### Other bugs fixed

- [40625](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40625) Prevent cashup re-submissions on page reload

### Reports

#### Other bugs fixed

- [40470](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40470) REPORT_GROUP authorized value cannot be numeric
- [40937](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40937) No option to show/hide data menu in report results when including borrowernumber
- [40961](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40961) LocalUse Circulation Statistics offering empty results
- [41082](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41082) Renaming columns in reports doesn't work with batch tools
- [41112](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41112) Space is missing in report preview
  >This fixes the 'Delete' button when previewing the SQL for a saved report - there is now a space between the trash can icon and Delete.

### SIP2

#### Other bugs fixed

- [40915](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40915) SIP message parsing with empty fields edge cases

### Staff interface

#### Critical bugs fixed

- [38072](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38072) Regression with modalPrint
  >This fixes a regression when printing dialogue boxes in certain Chromium-based browsers, for example, when printing the cashup summary for the point of sale system. Sometimes the print dialog failed to open, and instead you were faced with a flash of white before the new tab automatically closed and didn't print.
- [41229](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41229) Cash registers are not fully reset on library change

#### Other bugs fixed

- [39712](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39712) Query parameters break the manual mappings in vue modules
- [40565](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40565) Column filters on the item search do not work
  >This patch fixes a problem that made the column search filters not to work when doing an item search.
- [40876](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40876) DT - Exact search not applied on second attribute for column filters
- [40907](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40907) parenthesis and bracket are breaking filter on item table
- [41074](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41074) Last patron links are shuffled and wrong patrons removed

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
- [40857](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40857) Dropdown menu for Booking cancellation is hidden in modal
- [41207](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41207) Permission description string does match permission name

  **Sponsored by** *Cape Libraries Automated Materials Sharing*

### Test Suite

#### Other bugs fixed

- [38475](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38475) InfiniteScrollSelect_spec.ts is failing randomly again
- [40467](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40467) t/00-deprecated.t no longer needed
- [40845](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40845) t/Koha/Manual.t only passes for 25.05 and 25.06
- [40969](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40969) Circulation.t fails if  RenewalPeriodBase is set to now ( the current date )
- [41012](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41012) ILSDI_Services.t is failing randomly

### Tools

#### Other bugs fixed

- [32950](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32950) MARC modification template moving subfield can lose values for repeatable fields
  >MARC modification templates now correctly preserve existing values when moving subfields within repeatable fields. Previously, moving subfields could cause data loss or duplication when the source subfield didn't exist in all instances of the repeatable field.
  >
  >**The problem:**
  >
  >When using a MARC modification template to move a subfield within a repeatable field (for example, moving 020$z to 020$a), if some 020 fields had existing $a values but no $z values, those existing $a values would be overwritten or lost.
  >
  >**Example scenario:**
  >
  >Given multiple 020 fields:
  >- 020$a with existing ISBN
  >- 020$a with another existing ISBN  
  >- 020$z with cancelled ISBN (to be moved to $a)
  >- 020$z with another cancelled ISBN (to be moved to $a)
  >
  >Previously, when moving 020$z to 020$a, the first two existing 020$a values would be replaced with values from the 020$z fields, causing data loss.
  >
  >**What's fixed:**
  >
  >- Existing subfield values in fields that don't contain the source subfield are now preserved
  >- Source subfield values are only moved to the corresponding target positions in fields that actually contain the source subfield
  >- The move operation correctly removes the source subfields after copying their values
  >- Field order and other subfields are maintained correctly
  >
  >**For cataloguers:**
  >
  >MARC modification template "move" operations now work reliably with repeatable fields. When moving subfields, only the fields that contain the source subfield will be affected, and all other existing values in the repeatable fields will be preserved.
- [40843](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40843) On modborrowers.pl patron attributes should sort by the description, not the code
  >This patch fixes a problem in the batch patron modification tool where extended patron attributes were sorting based on the code, instead of the description.

### Web services

#### Other bugs fixed

- [40622](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40622) Bug 38233 not properly applied to 24.11.x, 25.05.x, and main
  >ILS-DI GetRecords will now show the OPAC version of "marcxml".

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [English (USA)](https://koha-community.org/manual/24.11/en/html/)
- [French](https://koha-community.org/manual/24.11/fr/html/) (75%)
- [German](https://koha-community.org/manual/24.11/de/html/) (94%)
- [Greek](https://koha-community.org/manual/24.11/el/html/) (98%)
- [Hindi](https://koha-community.org/manual/24.11/hi/html/) (67%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (95%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified Han script) (86%)
- Chinese (Traditional Han script) (99%)
- Czech (68%)
- Dutch (88%)
- English (100%)
- English (New Zealand) (63%)
- English (USA)
- Finnish (99%)
- French (99%)
- French (Canada) (99%)
- German (99%)
- Greek (68%)
- Hindi (97%)
- Italian (82%)
- Norwegian Bokmål (73%)
- Persian (fa_ARAB) (96%)
- Polish (99%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (87%)
- Russian (94%)
- Slovak (60%)
- Spanish (99%)
- Swedish (88%)
- Telugu (67%)
- Tetum (52%)
- Turkish (83%)
- Ukrainian (73%)
- Western Armenian (hyw_ARMN) (62%)
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

The release team for Koha 24.11.11 is


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
new features in Koha 24.11.11
<div style="column-count: 2;">

- Athens County Public Libraries
- Auckland University of Technology
- [Cape Libraries Automated Materials Sharing](https://info.clamsnet.org)
</div>

We thank the following individuals who contributed patches to Koha 24.11.11
<div style="column-count: 2;">

- Aleisha Amohia (1)
- Pedro Amorim (7)
- Tomás Cohen Arazi (9)
- Nick Clemens (6)
- David Cook (5)
- Paul Derscheid (5)
- Jonathan Druart (24)
- Laura Escamilla (2)
- Katrin Fischer (1)
- Andrew Fuerste-Henry (2)
- Lucas Gass (6)
- Kyle M Hall (5)
- Jan Kissig (1)
- Michał Kula (1)
- Vivek Kumar (1)
- Brendan Lawlor (1)
- lawrenceol-clams (1)
- Eric Phetteplace (1)
- Martin Renvoize (7)
- Marcel de Rooy (9)
- Caroline Cyr La Rose (2)
- Lisette Scheer (1)
- Slava Shishkin (1)
- Fridolin Somers (4)
- Lari Taskula (3)
- Hammat Wele (1)
- Baptiste Wojtkowski (2)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 24.11.11
<div style="column-count: 2;">

- bestbookbuddies.com (1)
- [BibLibre](https://www.biblibre.com) (6)
- [Bibliotheksservice-Zentrum Baden-Württemberg (BSZ)](https://bsz-bw.de) (1)
- [ByWater Solutions](https://bywatersolutions.com) (22)
- [Cape Libraries Automated Materials Sharing](https://info.clamsnet.org) (2)
- Catalyst Open Source Academy (1)
- [Hypernova Oy](https://www.hypernova.fi) (3)
- Independant Individuals (3)
- Koha Community Developers (24)
- [LMSCloud](https://www.lmscloud.de) (5)
- [Open Fifth](https://openfifth.co.uk/) (14)
- [Prosentient Systems](https://www.prosentient.com.au) (5)
- Rijksmuseum, Netherlands (9)
- [Solutions inLibro inc](https://inlibro.com) (3)
- [Theke Solutions](https://theke.io) (9)
- Wildau University of Technology (1)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Aleisha Amohia (5)
- Tomás Cohen Arazi (2)
- Sarah Berry (1)
- Katie Bliss (1)
- Anke Bruns (1)
- Aude Charillon (1)
- Nick Clemens (11)
- David Cook (8)
- Paul Derscheid (104)
- Trevor Diamond (2)
- Jonathan Druart (7)
- Magnus Enger (1)
- Laura Escamilla (4)
- Andrew Fuerste-Henry (1)
- Brendan Gallagher (1)
- Lucas Gass (96)
- George (1)
- Victor Grousset (1)
- Nial Halford-Busby (1)
- Kyle M Hall (5)
- Chip Halvorsen (1)
- Claire Hernandez (2)
- Jan Kissig (1)
- Thomas Klausner (1)
- Brendan Lawlor (9)
- Owen Leonard (9)
- CJ Lynce (2)
- David Nind (25)
- Martin Renvoize (17)
- Phil Ringnalda (1)
- Jason Robb (1)
- Marcel de Rooy (24)
- Caroline Cyr La Rose (2)
- Mathieu Saby (2)
- Bernard Scaife (2)
- Lisette Scheer (6)
- Fridolin Somers (77)
- Arthur Suzuki (1)
- Imani Thomas (1)
- Baptiste Wojtkowski (26)
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
line is 24.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 04 Dec 2025 15:14:36.
