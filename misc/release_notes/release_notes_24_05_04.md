# RELEASE NOTES FOR KOHA 24.05.04
02 Oct 2024

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 24.05.04 can be downloaded from:

- [Download](http://download.koha-community.org/koha-24.05.04.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 24.05.04 is a bugfix/maintenance release.

It includes 92 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


## Bugfixes

### About

#### Other bugs fixed

- [37575](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37575) Typo 'AutoCreateAuthorites' in about.pl

### Accessibility

#### Other bugs fixed

- [37586](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37586) Improve accessibility of top navigation in the OPAC with aria-labels

### Acquisitions

#### Other bugs fixed

- [37337](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37337) Submitting a similar suggestion results in a blank page
- [37340](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37340) EDIFACT messages should be sortable by 'details'
  >This fixes the EDIFACT messages table in acquisitions so that the details column is now sortable (Acquisitions > EDIFACT messages (when the EDIFACT system preference is enabled).
- [37343](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37343) Cannot search for vendors when transferring an item in acquisitions
- [37411](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37411) Exporting budget planning gives 500 error
- [37450](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37450) Clicking 'Close basket' from the list of baskets does nothing
- [37551](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37551) MarcFieldsToOrder price is overriding MarcItemFieldsToOrderPrice

### Architecture, internals, and plumbing

#### Critical bugs fixed

- [37260](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37260) Problem with connection to broker not displayed on the about page
- [37371](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37371) Direct input of dates not working when editing only part of a date
- [37509](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37509) Elasticsearch status info missing from 'Server information'
  >This fixes the About Koha > Server information page so that it now shows information about Elasticsearch. Before this, it was empty.

#### Other bugs fixed

- [36362](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36362) Only call Koha::Libraries->search() if necessary in Item::pickup_locations

  **Sponsored by** *Gothenburg University Library*
- [36474](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36474) updatetotalissues.pl  should not modify the record when the total issues has not changed
  >This updates the misc/cronjobs/update_totalissues.pl script so that records are only modified if the number of issues changes. Previously, every record was modified - even if the number of issues did not change.
  >
  >In addition, with CataloguingLog enabled, this previously added one entry to the log viewer for every record - as all the records were modified even if the number of issues did not change. Now, only records where the number of issues have changed are included in the log viewer, significantly reducing the number of entries.
- [37216](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37216) Fix dbrev for EmailFieldSelection
- [37400](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37400) On checkin don't search for a patron unless needed
- [37510](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37510) Koha::Object->delete should throw a Koha::Exception if there's a parent row constraint

### Cataloging

#### Critical bugs fixed

- [37429](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37429) Can't edit bibliographic records anymore (empty form)

#### Other bugs fixed

- [37342](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37342) CSRF error - Cannot add new authorities from basic editor with 'Link authorities automatically'
- [37383](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37383) No edit item button on catalog detail page for items where holding library is not logged in library
- [37399](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37399) Item type not displayed on holdings table if noItemTypeImages is disabled
  >This fixes the staff interface holdings table for a record so that the 'Item type' column is displayed when the "noItemTypeImages" system preference is set to 'Don't show'.

  **Sponsored by** *Koha-Suomi Oy*
- [37591](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37591) Moredetail.tt page is opening very slowly
  >This improves the loading time of a record's items page in the staff item when there are many items and check-outs.

  **Sponsored by** *Koha-Suomi Oy*

### Circulation

#### Critical bugs fixed

- [37407](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37407) Fast add / fast cataloging from patron checkout does not checkout item

#### Other bugs fixed

- [32696](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32696) Recalls can inadvertently extend the due date

  **Sponsored by** *Ignatianum University in Cracow*
- [36196](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36196) Handling NULL data in ajax calls for cities
- [37413](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37413) Updating an item level hold on an item with no barcode to a next available hold also modifies the other holds on the record
  >This fixes updating existing item level holds for an item without a barcode. When updating an existing item level hold from "Only item No barcode" (Holds for a record > Existing holds > Details column) to "Next available", it would incorrectly change any other item level holds to "Next available".
- [37552](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37552) Automatic renewals cronjob can die when an item scheduled for renewal is checked in

### Command-line Utilities

#### Critical bugs fixed

- [37543](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37543) connexion_import_daemon.pl stopped working in 24.05 due to API changes related to CSRF-Token

  **Sponsored by** *Reformational Study Centre*
- [37775](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37775) update_totalissues.pl uses $dbh->commit but does not use transactions

#### Other bugs fixed

- [37553](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37553) Fix CSRF handling in koha-svc.pl script

### Course reserves

#### Other bugs fixed

- [37409](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37409) Edit button for items in course reserves list doesn't work
  >This fixes editing existing reserves for a course (when using course reserves). Editing a reserve was opening the add reserve form, instead of letting you edit the existing reserve. (This is related to the CSRF changes added in Koha 24.05 to improve form security.)

### Database

#### Other bugs fixed

- [37476](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37476) RANK is a reserved word in MySQL 8.0.2+
  >This fixes adding a patron to a routing list after receiving a serial - the patron was not being added to the routing list. This issue was only happing where MySQL 8.0.2 or later was used as the database for Koha. This was because the SQL syntax in the SQL used RANK, which become a reserved word in MySQL 8.0.2.
- [37593](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37593) Fix typo in schema description for items.bookable

### ERM

#### Critical bugs fixed

- [37288](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37288) Edit data provider form does not show the name
  >This fixes the editing form for eUsage data providers (ERM > eUsage > Data providers):
  >- It delays the page display until the information from the counter registry is received. Previously, the data provider name was empty until the data from the registry was received.
  >- It removes the 'Create manually' button when editing a data provider that was created from the registry.
- [37308](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37308) Add user-agent to SUSHI outgoing requests

#### Other bugs fixed

- [37647](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37647) Unnecessary use of Text::CSV_XS in Koha/REST/V1/ERM/EHoldings/Titles/Local.pm

### Fines and fees

#### Critical bugs fixed

- [37263](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37263) Creating default article request fees is not working

#### Other bugs fixed

- [37254](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37254) Dropdown values not cleared after pressing clear in circulation rules

  **Sponsored by** *Koha-Suomi Oy*

### Hold requests

#### Critical bugs fixed

- [29087](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29087) Holds to pull list can crash with a SQL::Abstract puke
  >This fixes the cause of an error (SQL::Abstract::puke():...) that can occur on the holds to pull list (Circulation > Holds > Holds to pull).
- [37351](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37351) Checkboxes on waiting holds report are not kept when switching to another page
- [37374](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37374) Place hold button non-responsive for club holds

#### Other bugs fixed

- [37373](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37373) Cursor should go to patron search box on loading holds page

### I18N/L10N

#### Critical bugs fixed

- [37303](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37303) Fuzzy translations displayed on the UI

### ILL

#### Critical bugs fixed

- [37389](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37389) REST API queries joining on extended_attributes may cause severe performance issues
  >This fixes a severe performance issue with a REST API SQL query for patron and interlibrary loan request custom attributes. It fixes the problematic join queries using a "mixin" and adds tests. The previous queries could in some circumstance severally affect the database performance.

### Label/patron card printing

#### Critical bugs fixed

- [37192](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37192) Can't print label from the item editor
  >This fixes a 500 error that occurs when attempting to print a label for an item in the staff interface (from the record details page > Edit > Edit items > Actions > Print label (for a specific item). The label batch editor now opens (as expected).

### Lists

#### Other bugs fixed

- [37285](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37285) Printing lists only prints the ten first results

### MARC Authority data support

#### Other bugs fixed

- [37226](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37226) Authority hierarchy tree broken when a child (narrower) term appears under more than one parent (greater) term

### OPAC

#### Critical bugs fixed

- [37111](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37111) OPAC renewal - CSRF "op must be set"
  >This fixes an error that occurs when patron's attempt to renew items from their OPAC account (Your account > Summary). The error was related to the CSRF changes to improve the security for forms added Koha 24.05.

#### Other bugs fixed

- [36566](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36566) Correct ESLlint errors in OPAC enhanced content JS
  >This fixes various ESLint errors in enhanced content JavaScript files:
  >- Consistent indentation
  >- Remove variables which are declared but not used
  >- Add missing semicolons
  >- Add missing "var" declarations
- [37324](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37324) Self registration complete login form won't login user
  >This fixes the login form after completing self registration in the OPAC - the prefilled login details now let you log in.

### Patrons

#### Critical bugs fixed

- [34147](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34147) Patron search displays "processing" when category has library limitations that exclude the logged in library name
- [37378](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37378) Patron searches can fail when library groups are set to 'Limit patron data access by group'
- [37523](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37523) CSRF error when modifying an existing patron record

  **Sponsored by** *Athens County Public Libraries*
- [37542](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37542) Patron search is incorrectly parsing entries as dates and fetching the wrong patron if dateofbirth in search fields

#### Other bugs fixed

- [36882](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36882) Flatpickr doesn't work for repeatable date patron attributes in overdues
- [37435](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37435) Cannot renew patron from details page in patron account without circulate permissions
- [37489](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37489) Cannot delete patron image without uploading a file

### Point of Sale

#### Other bugs fixed

- [36998](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36998) 'Issue refund' modal on cash register transactions page can mistakenly display amount from previously clicked on transaction
- [37563](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37563) Refund, payout, and discount modals in patron transactions and point of sale have broken/bad formatting of values

### REST API

#### Other bugs fixed

- [29509](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29509) GET /patrons* routes permissions excessive

### Reports

#### Critical bugs fixed

- [37093](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37093) 403 Forbidden Error when attempting to search for Mana Reports
  >This fixes searching for a report in Mana when creating a new report. Searching Mana was generating an error message "Your search could not be completed. Please try again later. 403 Forbidden". (This is related to the CSRF changes added in Koha 24.05 to improve form security.)

#### Other bugs fixed

- [37077](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37077) SQL Reports - Picking only one option for each multiple selection results in wrong query
- [37382](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37382) Report download is empty except for headers if .tab format is selected
- [37763](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37763) 'Update and run SQL' appends the editor screen after the report results

  **Sponsored by** *Westlake Porter Public Library*

### Searching - Elasticsearch

#### Other bugs fixed

- [35792](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35792) Quiet warning: Use of uninitialized value $sub6
  >This removes a warning message[1] that appears in the reindexing output when using Elasticsearch. The warning was generated if there was no value in 880$6 (880 = Alternate Graphic Representation, $6 = Linkage), but there were other 880 subfields with a value, for example 880$a.
  >
  >[1] Use of uninitialized value $sub6 in pattern match (m//) at /kohadevbox/koha/Koha/SearchEngine/Elasticsearch.pm line 619.
- [36879](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36879) Spurious warnings in QueryBuilder
  >This fixes the cause of a warning message in the log files. Changing the sort order for search results in the staff interface (for example, from Relevance to Author (A-Z)) would generate an unnecessary warning message in plack-intranet-error.log: [WARN] Use of uninitialized value $f in hash element at /kohadevbox/koha/Koha/SearchEngine/Elasticsearch/QueryBuilder.pm line 72    5.

### Serials

#### Critical bugs fixed

- [37873](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37873) Unable to delete user from routing list or preview/print routing list slip
  >Fixes a regression that prevented recipients from being deleted from a routing list, as well as resolving issues with previewing routing lists.

  **Sponsored by** *Westlake Porter Public Library*

#### Other bugs fixed

- [37294](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37294) Generate next button in serials not working
  >This fixes the 'Generate next' button when receiving serials so that it now works as expected. Before this fix, nothing happened when clicking the button. (This is related to the CSRF changes added in Koha 24.05 to improve form security.)

### Staff interface

#### Critical bugs fixed

- [26866](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26866) Items table on additem should sort by cn_sort

#### Other bugs fixed

- [28762](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28762) Item status shows incorrectly on course-details.pl
- [31921](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31921) No confirmation alert when deleting a vendor
  >This fixes deleting vendors in acquisitions. There is now a new confirmation pop-up dialogue box.
- [33453](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33453) Confirmation button for 'Record cashup' should be yellow
  >This fixes the style of the "Confirm" button in the pop-up window when recording a cashup (Tools > Transaction history for > Record cashup). The button was changed from the default button style (with a white background) to the yellow primary action button.
- [33455](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33455) Heading on 'update password' page is too big
  >This fixes the heading for the patron change password page in the staff interface (Patrons > search for a patron > Change password). It was previously part of the form area with the white background, when it should have been above it like other page headings.
- [36129](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36129) Check in "Hide all columns" doesn't persist on item batch modification/deletion
  >This fixes the item batch modification/deletion tool, so that if the "Hide all columns" checkbox is selected and then the page is reloaded, the checkbox is still shown as selected. Before this, the columns remained hidden as expected, but the checkbox wasn't selected.

  **Sponsored by** *Koha-Suomi Oy*
- [37029](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37029) 'About Koha' button on staff side homepage seems out of place among application buttons
- [37425](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37425) Deletion of bibliographic record can cause search errors

### System Administration

#### Critical bugs fixed

- [37419](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37419) Deleting the record source deletes the associated biblio_metadata rows

#### Other bugs fixed

- [36276](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36276) Cannot edit identity provider after creation
  >This fixes the identity provider and domain forms so that the information is now editable (Administration > Additional parameters > Identity providers).

  **Sponsored by** *Athens County Public Libraries*
- [36907](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36907) OAI set mapping form field maxlength should match table column sizes
  >This fixes the OIA set mappings form so that you can't enter more characters than the maximum length for the input fields (Field (3), Subfield (1), and Value (80)). Previously, you could enter more characters - however, when you saved the form it generated an error.
- [37461](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37461) Typo in SMSSendAdditionalOptions description

### Templates

#### Other bugs fixed

- [35235](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35235) Mismatched label on notice edit form
- [35236](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35236) Mismatched label on patron card batch edit form
  >This fixes the "Batch description" label when editing a patron card batch (Tools > Patrons and circulation > Patron card creator > Manage > Card batches > Edit). When you click on the batch description label, the input field is now selected and you can enter the batch description. Before this, you had to click in the field to add the description.
- [36885](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36885) Missing tooltip on budget planning page
  >This fixes the "Budget locked" tooltip for budget fund planning pages (Administration > Budgets > select a budget that is locked > Funds > Planning > any planning option). The tooltip was not styled correctly for fund names - it now has white text on a black background.
- [37030](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37030) Use template wrapper for breadcrumbs: Cash register stats
- [37496](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37496) Link to item details from holdings table links to all items
- [37643](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37643) Check for NaN instead of truthiness if calendar.inc accepts_time

### Test Suite

#### Other bugs fixed

- [37302](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37302) xt/api.t should fail if swagger-cli is missing
  >This fixes the tests in xt/api.t. It was skipping tests if swagger-cli was missing, which meant that some tests weren't being run when they should be. The tests now fail if swagger-cli isn't found.
  >
  >It also adds swagger-cli 4.0.4+ to the devDependancies section of package.json.
- [37607](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37607) t/cypress/integration/ERM/DataProviders_spec.ts fails
- [37620](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37620) Fix randomly failing tests for cypress/integration/InfiniteScrollSelect_spec.ts
- [37623](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37623) t/db_dependent/Letters.t tests fails to consider EmailFieldPrimary system preference

  **Sponsored by** *Pymble Ladies' College*

### Tools

#### Critical bugs fixed

- [37612](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37612) Batch modifying patrons from patron lists broken by CSRF protection
  >This fixes batch editing patrons from a patron list (Tools > Patrons and circulation > Patron lists > Actions > Batch edit patrons). When attempting to batch edit patrons, it didn't load the page to batch edit the patrons, and displayed the message "No patron card numbers or borrowernumbers given." (This is related to the CSRF changes added in Koha 24.05 to improve form security.)

  **Sponsored by** *Chetco Community Public Library*
- [37614](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37614) Printing patron cards from patron lists broken by CSRF protection
  >This fixes printing patron cards from a patron list (Tools > Patrons and circulation > Patron lists > Actions > Print patron cards > Export). When clicking on Export, the progress icon keeps spinning and doesn't finish - resulting in no PDF file to download. (This is related to the CSRF changes added in Koha 24.05 to improve form security.)

#### Other bugs fixed

- [37186](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37186) Cannot delete a rotating collection

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Chinese (Traditional)](https://koha-community.org/manual/24.05/zh_Hant/html/) (78%)
- [English](https://koha-community.org/manual/24.05//html/) (100%)
- [English (USA)](https://koha-community.org/manual/24.05/en/html/)
- [French](https://koha-community.org/manual/24.05/fr/html/) (49%)
- [German](https://koha-community.org/manual/24.05/de/html/) (39%)
- [Greek](https://koha-community.org/manual/24.05//html/) (73%)
- [Hindi](https://koha-community.org/manual/24.05/hi/html/) (75%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (98%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified) (88%)
- Chinese (Traditional) (90%)
- Czech (69%)
- Dutch (83%)
- English (100%)
- English (New Zealand) (63%)
- English (USA)
- Finnish (99%)
- French (99%)
- French (Canada) (99%)
- German (99%)
- German (Switzerland) (51%)
- Greek (57%)
- Hindi (99%)
- Italian (83%)
- Norwegian Bokmål (76%)
- Persian (fa_ARAB) (94%)
- Polish (99%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (88%)
- Russian (93%)
- Slovak (61%)
- Spanish (100%)
- Swedish (87%)
- Telugu (69%)
- Turkish (82%)
- Ukrainian (73%)
- hyw_ARMN (generated) (hyw_ARMN) (64%)
</div>

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 24.05.04 is


- Release Manager: Katrin Fischer

- Release Manager assistants:
  - Tomás Cohen Arazi
  - Martin Renvoize
  - Jonathan Druart

- QA Manager: Martin Renvoize

- QA Team:
  - Marcel de Rooy
  - Kyle M Hall
  - Emily Lamancusa
  - Nick Clemens
  - Lucas Gass
  - Tomás Cohen Arazi
  - Julian Maurice
  - Victor Grousset
  - Aleisha Amohia
  - David Cook
  - Laura Escamilla
  - Jonathan Druart
  - Pedro Amorim
  - Matt Blenkinsop
  - Thomas Klausner

- Topic Experts:
  - UI Design -- Owen Leonard
  - Zebra -- Fridolin Somers
  - ERM -- Matt Blenkinsop
  - ILL -- Pedro Amorim
  - SIP2 -- Matthias Meusburger
  - CAS -- Matthias Meusburger

- Bug Wranglers:
  - Aleisha Amohia
  - Jacob O'Mara

- Packaging Managers:
  - Mason James
  - Tomás Cohen Arazi

- Documentation Manager: Philip Orr

- Documentation Team:
  - Aude Charillon
  - Caroline Cyr La Rose
  - Lucy Vaux-Harvey
  - Emmanuel Bétemps
  - Marie-Luce Laflamme
  - Kelly McElligott
  - Rasa Šatinskienė
  - Heather Hernandez

- Wiki curators: 
  - Thomas Dukleth
  - George Williams

- Release Maintainers:
  - 24.05 -- Lucas Gass
  - 23.11 -- Fridolin Somers
  - 23.05 -- Wainui Witika-Park
  - 22.11 -- Fridolin Somers

## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 24.05.04
<div style="column-count: 2;">

- Athens County Public Libraries
- Chetco Community Public Library
- Gothenburg University Library
- Ignatianum University in Cracow
- [Koha-Suomi Oy](https://koha-suomi.fi)
- Pymble Ladies' College
- Reformational Study Centre
- Westlake Porter Public Library
</div>

We thank the following individuals who contributed patches to Koha 24.05.04
<div style="column-count: 2;">

- Aleisha Amohia (1)
- Pedro Amorim (9)
- Tomás Cohen Arazi (7)
- Matt Blenkinsop (7)
- Rudolf Byker (1)
- Nick Clemens (13)
- David Cook (4)
- Paul Derscheid (1)
- Jonathan Druart (6)
- Eric Garcia (5)
- Lucas Gass (24)
- Victor Grousset (2)
- Thibaud Guillot (1)
- David Gustafsson (1)
- Kyle M Hall (4)
- Mason James (1)
- Andreas Jonsson (1)
- Janusz Kaczmarek (2)
- Jan Kissig (1)
- Emily Lamancusa (3)
- Sam Lau (6)
- Laura_Escamilla (3)
- Brendan Lawlor (4)
- Owen Leonard (7)
- CJ Lynce (4)
- Julian Maurice (7)
- Vicki McKay (1)
- PerplexedTheta (2)
- Martin Renvoize (19)
- Phil Ringnalda (6)
- Caroline Cyr La Rose (1)
- Andreas Roussos (1)
- Johanna Räisä (1)
- Fridolin Somers (1)
- Catalyst Bug Squasher (3)
- Jennifer Sutton (1)
- Emmi Takkinen (3)
- Hammat Wele (1)
- Baptiste Wojtkowski (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 24.05.04
<div style="column-count: 2;">

- Athens County Public Libraries (7)
- [BibLibre](https://www.biblibre.com) (9)
- [ByWater Solutions](https://bywatersolutions.com) (44)
- [Cape Libraries Automated Materials Sharing](https://info.clamsnet.org) (4)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha) (5)
- Catalyst Open Source Academy (1)
- Chetco Community Public Library (6)
- [Dataly Tech](https://dataly.gr) (1)
- Göteborgs Universitet (1)
- Independant Individuals (15)
- Koha Community Developers (8)
- [Koha-Suomi Oy](https://koha-suomi.fi) (3)
- KohaAloha (1)
- Kreablo AB (1)
- laposte.net (1)
- llownd.net (2)
- [LMSCloud](lmscloud.de) (1)
- [Montgomery County Public Libraries](montgomerycountymd.gov) (3)
- [Prosentient Systems](https://www.prosentient.com.au) (4)
- [PTFS Europe](https://ptfs-europe.com) (35)
- [Solutions inLibro inc](https://inlibro.com) (2)
- [Theke Solutions](https://theke.io) (7)
- westlakelibrary.org (4)
- Wildau University of Technology (1)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Belal Ahmadi (1)
- Pedro Amorim (3)
- Tomás Cohen Arazi (6)
- Matt Blenkinsop (4)
- Mary Blomley (1)
- Nick Clemens (21)
- David Cook (9)
- Chris Cormack (2)
- Jake Deery (3)
- Paul Derscheid (5)
- Roman Dolny (16)
- Jonathan Druart (1)
- Katrin Fischer (73)
- Andrew Fuerste-Henry (1)
- Eric Garcia (1)
- Lucas Gass (146)
- Victor Grousset (9)
- Kyle M Hall (16)
- Barbara Johnson (2)
- Janusz Kaczmarek (1)
- Kelly (1)
- Jan Kissig (1)
- Emily Lamancusa (8)
- Sam Lau (2)
- Laura_Escamilla (3)
- Brendan Lawlor (5)
- Owen Leonard (10)
- Julian Maurice (5)
- David Nind (36)
- Laura ONeil (1)
- Hayley Pelham (3)
- Martin Renvoize (76)
- Phil Ringnalda (5)
- Jason Robb (1)
- Marcel de Rooy (37)
- Johanna Räisä (1)
- Michaela Sieber (1)
- Sam Sowanick (1)
- Emmi Takkinen (2)
- Alexander Wagner (2)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 24.05.x-security.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 02 Oct 2024 14:43:13.
