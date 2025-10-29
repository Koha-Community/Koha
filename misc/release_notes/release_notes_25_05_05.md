# RELEASE NOTES FOR KOHA 25.05.05
29 Oct 2025

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 25.05.05 can be downloaded from:

- [Download](https://download.koha-community.org/koha-25.05.05.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 25.05.05 is a bugfix/maintenance release.

It includes 61 bugfixes. 2 of them are security fixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [40525](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40525) CSV formula injection - client side (DataTables) in OPAC
- [40818](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40818) marc_lib is mostly used raw in templates

## Bugfixes

### Acquisitions

#### Critical bugs fixed

- [40587](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40587) Prevent selection of different EAN's on EDI ORDER when the Basket is generated from a QUOTE message

  **Sponsored by** *OpenFifth*
- [40743](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40743) Unable to select the correct fund when paying invoices
- [40918](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40918) Invoice Adjustment Reason always "No reason" even if report shows a saved reason

#### Other bugs fixed

- [40593](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40593) Can't search all columns in Acquisitions Suggestions table
- [40868](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40868) Vendor module permissions are ignored
- [40982](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40982) Basket: Orders table — "Modify" and "Cancel order" columns missing or displayed incorrectly

### Architecture, internals, and plumbing

#### Other bugs fixed

- [40041](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40041) Update mailmap for 25.11.x
- [40265](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40265) t/db_dependent/OAI/Server.t is failing randomly
- [40820](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40820) STOMP errors even when JobsNotificationMethod='polling'
- [40978](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40978) t/db_dependent/Budgets.t fails on Debian 13 due to warnings

### Cataloging

#### Critical bugs fixed

- [40997](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40997) Javascript error prevents saving when an instance of an 'important' or 'required' field is deleted

#### Other bugs fixed

- [40897](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40897) Uneven field lengths in additem.tt
- [40908](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40908) Issues with deleting items from additem page

### Circulation

#### Other bugs fixed

- [34596](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34596) Items in transit should not show up in the holds queue
  >This patch alters the way that the real time holds queue is rebuilt when an item is returned and a hold is found.
  >
  >Previously the queue would be rebuilt on the initial checkin, and a second time when the hold was confirmed. This led to a race condition where the item would be queued in one run, while being marked in transit during the second.
  >
  >We now delay the build of the holds queue until after the hold is either confirmed or ignored and only build it once.
- [40899](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40899) When placing multiple holds at once the individual "Pickup location:" dropdowns do not update when changing the top level "Pickup at:" dropdown"
  >This fixes a problem where the item specific branch choice was not being set correctly when placing a hold on multiple items at the same time in the staff interface.

### Command-line Utilities

#### Critical bugs fixed

- [40953](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40953) marc_ordering_process.pl broken due to accidental newline

#### Other bugs fixed

- [35700](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35700) Holds reminder cronjob --triggered switch does not work as intended if the day to send notice hits concurrent holidays
  >This bugfix adds a check to the hold reminders cronjob so the job will skip if today is a holiday when the --holiday flag is used. 
  >
  >This will prevent the notice from repeating reminders that would send on a usually closed day again on the next open day.
- [40785](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40785) Cronjob cleanup_database.pl usage is outdated

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

### Label/patron card printing

#### Other bugs fixed

- [40473](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40473) X scale for Code39 barcodes is calculated incorrectly when generating barcode labels

### Lists

#### Other bugs fixed

- [40916](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40916) Cannot edit a list to have a sortfield value of anything other than publicationyear
  >This fixes a problem where lists were un-sortable in the staff interface. It also fixes a problem where the sort value for a list was always being set to 'Publication year' when editing that list.

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

### OPAC

#### Other bugs fixed

- [41010](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41010) Incorrect show_priority condition in opac-detail

### Patrons

#### Other bugs fixed

- [39408](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39408) Cannot add patron via API if AutoEmailNewUser and WELCOME content blank
- [40605](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40605) Synchronize two sentences about processing personal data
- [40886](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40886) Patron circ messages not sorted in chronological order
  >This fixes a problem where circulation messages were not order chronologically in the staff interface.
- [40917](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40917) Required patron attributes show with extra whitespace in the textarea
  >This fixes a problem where extraeounos whitespace was being added to the textarea ( HTML element ) of a required patron attribute in the staff interface.
- [40936](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40936) Add index for default patron sort order
  >This change introduces a new database index to improve the performance of patron searches, especially in large databases. This will prevent slow searches and potential database server issues related to sorting patrons by name and address.
  >
  >**System Administrator Note:**
  >Applying this update will add a new index to the `borrowers` table. On systems with a large number of patrons, this operation can take a significant amount of time and consume considerable server resources (CPU and I/O).
  >
  >While modern database systems can often perform this operation without locking the table for the entire duration, a general slowdown of the system is expected. It is **strongly recommended** to run the upgrade (`updatedatabase.pl`) during a planned maintenance window to avoid impacting users.

### Reports

#### Other bugs fixed

- [40470](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40470) REPORT_GROUP authorized value cannot be numeric
- [40937](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40937) No option to show/hide data menu in report results when including borrowernumber
- [40939](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40939) Cardnumber not found when performing batch actions from report results

### SIP2

#### Other bugs fixed

- [40915](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40915) SIP message parsing with empty fields edge cases

### Searching

#### Other bugs fixed

- [40854](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40854) Staff interface search results browsing is broken
- [40888](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40888) and/or/not drop-downs are missing in the Advanced Search form
  >This fixes an issue with the Advanced Search form. When using "More options" to enter multiple search criteria, each criteria after the first should have a drop-down allowing you to choose between "and", "or", and "not" for that line. That drop-down was missing for most lines, and this fixes that issue so that the drop-down will display correctly again.

### Staff interface

#### Critical bugs fixed

- [40866](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40866) Corrections to override logging
- [41042](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41042) Table setting 'default sort order' not available for existing installations

#### Other bugs fixed

- [40865](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40865) Single patron result does not redirect
- [40880](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40880) Exporting Item search results to csv, columns after Damaged Status are misaligned
- [40904](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40904) Unable to search items by location
  >This fixes the holdings table in the staff interface so that it can be searched and filtered by the shelving location description.
- [40907](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40907) parenthesis and bracket are breaking filter on item table
- [41071](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41071) Registers not correctly populated / selected when changing branches
- [41074](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41074) Last patron links are shuffled and wrong patrons removed

### System Administration

#### Critical bugs fixed

- [40655](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40655) Transport cost matrix doesn't save changes
  >This fixes a problem with the transport cost matrix where fields that were disabled could not be made enabled via the interface,

### Templates

#### Other bugs fixed

- [40857](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40857) Dropdown menu for Booking cancellation is hidden in modal
- [40931](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40931) Hold pickup location drop-down boxes not wide enough when placing multiple holds at the same time.

### Test Suite

#### Other bugs fixed

- [40320](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40320) Missing Cypress tests for patron address display
- [40467](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40467) t/00-deprecated.t no longer needed
- [40969](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40969) Circulation.t fails if  RenewalPeriodBase is set to now ( the current date )
  >25.11.00
- [40981](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40981) KohaTable/Holdings_spec.ts is failing randomly
  >25.11.00
- [41012](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41012) ILSDI_Services.t is failing randomly

### Tools

#### Critical bugs fixed

- [41079](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41079) Checkboxes visible on the batch patron modification results view

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
- [41065](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41065) Batch patron modification results are no longer displayed

### Web services

#### Other bugs fixed

- [40622](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40622) Bug 38233 not properly applied to 24.11.x, 25.05.x, and main
  >ILS-DI GetRecords will now show the OPAC version of "marcxml".

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [English (USA)](https://koha-community.org/manual/25.05/en/html/)
- [French](https://koha-community.org/manual/25.05/fr/html/) (75%)
- [German](https://koha-community.org/manual/25.05/de/html/) (95%)
- [Greek](https://koha-community.org/manual/25.05/el/html/) (99%)
- [Hindi](https://koha-community.org/manual/25.05/hi/html/) (67%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (92%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
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
- Hindi (95%)
- Italian (80%)
- Norwegian Bokmål (71%)
- Persian (fa_ARAB) (93%)
- Polish (99%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (86%)
- Russian (92%)
- Slovak (58%)
- Spanish (98%)
- Swedish (86%)
- Telugu (65%)
- Tetum (51%)
- Turkish (81%)
- Ukrainian (71%)
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

The release team for Koha 25.05.05 is


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
new features in Koha 25.05.05
<div style="column-count: 2;">

- [OpenFifth](https://openfifth.co.uk)
</div>

We thank the following individuals who contributed patches to Koha 25.05.05
<div style="column-count: 2;">

- Pedro Amorim (2)
- Tomás Cohen Arazi (8)
- Matt Blenkinsop (2)
- Nick Clemens (10)
- David Cook (5)
- Paul Derscheid (4)
- Jonathan Druart (37)
- Laura Escamilla (3)
- Andrew Fuerste-Henry (2)
- Lucas Gass (7)
- Kyle M Hall (2)
- Michał Kula (1)
- Emily Lamancusa (1)
- Martin Renvoize (15)
- Marcel de Rooy (3)
- Lisette Scheer (1)
- Fridolin Somers (1)
- Arthur Suzuki (1)
- Hammat Wele (2)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 25.05.05
<div style="column-count: 2;">

- [BibLibre](https://www.biblibre.com) (2)
- [ByWater Solutions](https://bywatersolutions.com) (25)
- Independant Individuals (1)
- Koha Community Developers (37)
- [LMSCloud](https://www.lmscloud.de) (4)
- [Montgomery County Public Libraries](https://montgomerycountymd.gov) (1)
- [Open Fifth](https://openfifth.co.uk/) (19)
- [Prosentient Systems](https://www.prosentient.com.au) (5)
- Rijksmuseum, Netherlands (3)
- [Solutions inLibro inc](https://inlibro.com) (2)
- [Theke Solutions](https://theke.io) (8)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Aleisha Amohia (2)
- Tomás Cohen Arazi (2)
- Katie Bliss (1)
- Anke Bruns (1)
- Nick Clemens (13)
- David Cook (3)
- Paul Derscheid (112)
- Trevor Diamond (1)
- Jonathan Druart (10)
- Hannah Dunne-Howrie (2)
- Magnus Enger (1)
- Laura Escamilla (2)
- Andrew Fuerste-Henry (9)
- Lucas Gass (94)
- George (1)
- Victor Grousset (1)
- Nial Halford-Busby (1)
- Kyle M Hall (7)
- Chip Halvorsen (1)
- Claire Hernandez (2)
- Jason (1)
- Kevin Kellenberger (1)
- Thomas Klausner (1)
- Brendan Lawlor (11)
- Owen Leonard (2)
- Ludovic (1)
- CJ Lynce (3)
- David Nind (7)
- Eric Phetteplace (1)
- Martin Renvoize (24)
- Marcel de Rooy (21)
- Caroline Cyr La Rose (1)
- Mathieu Saby (3)
- Bernard Scaife (2)
- Slava Shishkin (4)
- Michaela Sieber (3)
- Michelle Spinney (1)
- Emmi Takkinen (1)
- Imani Thomas (1)
- Jen Tormey (1)
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

Autogenerated release notes updated last on 29 Oct 2025 16:50:14.
