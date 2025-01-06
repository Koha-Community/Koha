# RELEASE NOTES FOR KOHA 24.05.06
06 Jan 2025

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 24.05.06 can be downloaded from:

- [Download](https://download.koha-community.org/koha-24.05.06.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 24.05.06 is a bugfix/maintenance and security release.

It includes 5 enhancements, 251 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [37727](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37727) CVE-2024-24337 - Fix CSV formula injection - client side (DataTables)
- [38468](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38468) Staff interface detail page vulnerable to reflected XSS
- [38470](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38470) Subscription detail page vulnerable to reflected XSS

## Bugfixes

### About

#### Other bugs fixed

- [38517](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38517) Release team 25.05

### Acquisitions

#### Critical bugs fixed

- [38437](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38437) Modal does not appear on single order receive

#### Other bugs fixed

- [34159](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34159) Remove plan by AR_CANCELLATION choice in aqplan

  **Sponsored by** *Chetco Community Public Library*
- [35087](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35087) Discount rate should only allow valid input formats
  >This fixes the vendor discount field so that it now only accepts values that will save correctly:
  >- a decimal number in the format 0.0 (if a comma is entered, you are now prompted to enter a decimal point)
  >- numbers with up to two digits before the decimal and up to three digits after the decimal, for example: 9, 99, -99, 99.9, 0.99, 99.99, 99.999
- [35823](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35823) When uploading a MARC file to a basket it is showing inactive funds without them being selected
- [36049](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36049) Rounding prices sometimes leads to incorrect results
  >This fixes the values and totals shown for orders when rounding prices using the OrderPriceRounding system preference. Example: vendor price for an item is 18.90 and the discount is 5%, the total would show as 17.95 instead of 17.96.

  **Sponsored by** *Karlsruhe Institute of Technology (KIT)*
- [37070](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37070) Incorrect barcode generation when adding orders to basket
- [37184](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37184) Special character encoding problem when importing MARC file from the acquisitions module
- [37246](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37246) Suggestions filter by fund displays inactive budgets
- [37265](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37265) Consideration of UniqueItemFields setting when receiving items in an order
  >This fixes receiving orders so that values added to fields selected in the UniqueItemFields system preference are treated as unique when receiving items. 
  >
  >Example of incorrect behavour that is fixed:
  >- For the UniqueItemFields system preference, the Public note (itemnotes) is set as unique.
  >- Multiple quantities of the same item are ordered.
  >- When receiving the order, a note is added to the public note for the first copy of item received.
  >- For the second copy of the item received, the public note from the first item was incorrectly added.

  **Sponsored by** *kohawbibliotece.pl*
- [37304](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37304) Created by filter in acquisitions advanced orders search always shows zero results
- [37854](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37854) Barcode fails when adding item during order receive (again)
- [37913](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37913) Remove more unreachable code in aqcontract.tt

  **Sponsored by** *Chetco Community Public Library*
- [37914](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37914) Forms for budget planning filters and export should GET rather than POST

  **Sponsored by** *Chetco Community Public Library*
- [38271](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38271) Missing 008 field in bibliographic records created via EDIFACT
- [38297](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38297) The "New vendor" button needs a permissions guard
- [38303](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38303) Item's replacement price not set to defaultreplacecost if 0.00
- [38325](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38325) Cannot delete invoice while viewing it

  **Sponsored by** *Chetco Community Public Library*
- [38329](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38329) Remove orphan confirm_deletion() in supplier.tt

  **Sponsored by** *Chetco Community Public Library*
- [38680](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38680) [24.05.x] copyno not copied over when set in MarcItemFieldsToOrder system preference

### Architecture, internals, and plumbing

#### Critical bugs fixed

- [37056](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37056) CSRF error on login when user js contains a fetch of svc/report
- [37741](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37741) Koha errors on page (e.g. 404) cause incorrect CSRF errors
  >This change prevents an error in a background call (e.g. a missing favicon.ico) from affecting the user's session, which can lead to incorrect CSRF 403 errors during form POSTs. (The issue is prevented by stopping error pages from returning the CGISESSID cookie, which overwrites the CGISESSID cookie returned by the foreground page.)
- [37824](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37824) Replace webpack with rspack for fun and profit
- [38035](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38035) "sound" listed as an installed language
- [38495](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38495) Cannot cancel background job (CSRF)

#### Other bugs fixed

- [31581](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31581) Remove Zebra files for NORMARC
- [33188](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33188) Warning in Koha::Items->hidden_in_opac
- [35959](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35959) Inconsistent hierarchy during C3 merge of class 'Koha::AuthorisedValue' (and a few other modules)
- [36317](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36317) Koha::Biblio->host_items fails with search_ordered()
- [36873](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36873) Koha::Objects->delete should accept parameters and pass them through
- [36901](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36901) Add logging for uncaught exceptions in background job classes
  >This fixes the logging of uncaught exceptions in background jobs. Some rare situations like DB connection drops can make jobs get marked as failure, but no information about the reasons was logged anywhere.
- [37155](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37155) Remove unnecessary unblessing of patron in CanItemBeReserved
- [37292](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37292) Add an index on expires column for oauth_access_tokens
  >This adds a database index to the `expires` column for the 'oauth_access_tokens' table, making it easier for database administrators to purge older records.
- [37628](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37628) Remove get_opac_news_by_id
- [37672](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37672) V1/RecordSources.pm should use more helpers
- [37757](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37757) notice_email_address explodes if EmailFieldPrimary is not valid
- [37823](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37823) Remove unreachable code in aqcontract.tt
- [37865](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37865) Use of uninitialized value $op in string at circulation.pl
- [37981](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37981) Switch installer/step3.tt form from POST to GET
- [37982](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37982) Serial collection edit form can be GET
- [38000](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38000) Redundant code import in search.pl
- [38027](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38027) Clearing a flatpickr datetime causes errors
- [38200](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38200) Remove dead code to delete authorities in authorities/authorities.pl

  **Sponsored by** *Chetco Community Public Library*
- [38234](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38234) Remove unused vulnerable jszip library file
- [38257](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38257) Several functionalities broken in cart pop up

  **Sponsored by** *Koha-Suomi Oy*
- [38274](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38274) Typo in Arabic language description
  >This fixes the language description for Arabic (displayed in OPAC and the staff interface advanced search) - from "Arabic (لعربية)" to "Arabic (العربية)".
- [38286](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38286) Koha::Biblio:hidden_in_opac does not need to fetch the items if OpacHiddenItemsHidesRecord is set

### Authentication

#### Critical bugs fixed

- [36822](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36822) When creating a new patron via LDAP or Shibboleth 0000-00-00 is inserted for invalid updated_on

#### Other bugs fixed

- [37104](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37104) Block AnonymousPatron from logging into anything
  >This prevents the anonymous patron from logging into the OPAC and staff interface. (The anonymous patron used for anonymous suggestions and checkout history is set using the AnonymousPatron system preference.)

### Cataloging

#### Critical bugs fixed

- [37964](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37964) Only show host items when system preference EasyAnalyticalRecords is enabled
- [38413](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38413) Batch operations from item search results fail when "select visible rows" and many items are selected
  >This fixes an Apache web server error ("Request-URI Too Long - The requested URL's length exceeds the capacity limit for this server.") when using item search and batch modification to edit many items (500+).

  **Sponsored by** *Chetco Community Public Library*

#### Other bugs fixed

- [26929](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26929) Koha will only display the first 20 macros Advanced Editor

  **Sponsored by** *Chetco Community Public Library*
- [27769](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27769) Advanced editor shouldn't break copying selected text with Ctrl+C
  >This fixes a shortcut key clash introduced by bug 17179 - Advanced editor: Add keyboard shortcuts to repeat (duplicate) a field, and cut text. It updates the default Ctrl+C shortcut for 'Copy line' to 'Ctrl+Alt+C' so that it doesn't clash with the system copy shortcut.
  >
  >This is only fixed for new installs, so if you are experiencing this issue with an existing Koha installation, you may wish to manually apply the new mapping.
- [36375](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36375) Inconsistencies in ContentWarningField display
- [36821](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36821) Authority type text for librarians and OPAC limited to 100 characters
- [36976](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36976) Warning 'Argument "" isn't numeric in numeric' in log when merging bibliographic records

  **Sponsored by** *Ignatianum University in Cracow*
- [37293](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37293) MARC bibliographic framework text for librarians and OPAC limited to 100 characters
  >This fixes the staff and OPAC description fields for the MARC bibliographic framework forms - it increases the number of characters that can be entered to 255. Previously, the tag description fields were limited to 100 characters and the subfield description fields to 80 characters, even though the database allows up to 255 characters.

  **Sponsored by** *Chetco Community Public Library*
- [37403](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37403) Wrong progress quantity in job details when staging records with match check
- [37840](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37840) Wrong status in the Intranet detail page when the item type is not for loan
  >This fixes the status shown for items on record details pages in the staff interface. When an item type was set as not for loan, the status for individual items was incorrectly shown as "Available", instead of "Not for loan" (it was correctly shown as "Not for loan" in the OPAC). 
  >
  >(This is related to the changes made in Koha 24.05 to use the API to display holdings information in the staff interface, and improve the performance for records with many items.)
- [37871](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37871) Remove extraneous 246 subfields from the title mappings (Elasticsearch, MARC21)
  >This patch limits indexing of field 246 to $a, $b, $n, and $p in various title indexes.
  >Previously, all 246 subfields were indexed, including non-title subfields such as $i (Display text), $g (Miscellaneous information), and linking subfields, making the title index very large and giving false results, especially when looking for duplicates in cataloging.
- [38030](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38030) stocknumberAV.pl fails with CSRF protection

  **Sponsored by** *Ignatianum University in Cracow*
- [38065](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38065) Auto control number (001) widget in advanced editor does not work under CSRF protection
- [38082](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38082) Advanced editor does not save the selected framework with new record
- [38158](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38158) Typo in inventory 'Items has no "not for loan" status'
- [38162](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38162) Can't delete a stock rotation

### Circulation

#### Critical bugs fixed

- [37540](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37540) Pseudonymization is preventing renewals from the patrons account page

#### Other bugs fixed

- [13945](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13945) Multiple dialogs for item that needs transferred and hold captured at checkin
  >This fixes multiple dialog boxes from popping up when checking in an item that has a hold, but needs transferred. 
  >
  >Example: If an item is checked in at library A, and the item needs transferred to library B, *and* there is a hold for pickup at library B, the librarian will see a dialog box for both the transfer and the hold.
- [37076](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37076) Incorrect needsconfirmation code RESERVED_WAITING
  >This fixes an incorrect value used in the OPAC self-checkout code (this new feature was added to Koha 23.11 by Bug 30979 - Add ability for OPAC users to checkout to themselves). 
  >
  >Because of the incorrect value in the code (RESERVED_WAITING instead of RESERVE_WAITING - the 'D' is incorrect), patrons could self check out an item on hold for another patron, instead of getting an error message "This item appears to be on hold for another patron, please return it to the desk".
- [37271](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37271) Recall status should be 'requested' in overdue_recalls.pl

  **Sponsored by** *Ignatianum University in Cracow*
- [37396](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37396) Batch checkout does not checkout items if OverduesBlockCirc set to ask for confirmation
- [37424](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37424) Batch checkout silently fails if item contains materials specified (952$3)
  >This fixes the batch checkout when an item has a 952$3 value (Materials specified (bound volume or other part)). The text for the 952$3 was not displayed on the batch check out screen, it would silently fail, and then not check out the item to the patron (with no warning given). (This requires setting these system preferences CircConfirmItemParts, BatchCheckouts, BatchCheckoutsValidCategories (all).)
- [37444](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37444) Can't filter holds to pull by pickup location
- [37505](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37505) Statistical patrons don't display information about item status if item wasn't checked out
- [37524](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37524) Pressing "Renew all" redirects user to "Export data" tool if one of the items is not renewable

  **Sponsored by** *Koha-Suomi Oy*
- [37794](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37794) Fix form that POSTs without an op in Holds to pull

  **Sponsored by** *Chetco Community Public Library*
- [37836](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37836) Prevent submitting empty barcodes in self check-in
- [37983](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37983) "Search a patron" box no longer has auto focus
- [38012](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38012) Remove ispermanent from returns.tt and branchtransfers.tt
- [38097](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38097) Add class to "Item was not checked out" message in checkin table
- [38117](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38117) "Item was not checked in" should not always show

### Command-line Utilities

#### Critical bugs fixed

- [36435](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36435) Prevent warnings from interrupting koha-run-backups when deleting old backup files

  **Sponsored by** *Catalyst*
- [37075](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37075) Message queue processor will fail to send any message unless letter_code is passed

#### Other bugs fixed

- [14565](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14565) koha-run-backups does not backup an instance called demo
  >This removes a hard-coded exclusion for backups of instances named "demo".
- [18273](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18273) bulkmarcimport.pl inserts authority duplicates
  >This fixes the misc/migration_tools/bulkmarcimport.pl script when importing authority records so that the "--match" option works as expected, and no duplicates are created. Previously, this option was not working for authority records and duplicate records were being created even when there was a match.
- [35466](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35466) bulkmarcimport needs a parameter to skip indexing
  >This patch adds a new option to skip indexing to bulkmarcimport: `--skip_indexing`
  >It also fixes a bug where authorities were being indexed multiple times during import.
- [37038](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37038) koha-elasticsearch creates a file named 0
- [37550](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37550) bulkmarcimport.pl dies when adding items throws an exception
- [37709](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37709) bulkmarcimport.pl should die when the file cannot be opened
- [37787](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37787) Undocument koha-worker --queue elastic_index
  >This fixes the documentation for the koha-worker script. It removes the elastic_index queue from the script, as this is now handled by koha-es-indexer (added by bug 33108 to Koha 23.05.00 and backported to 22.11.06).
- [37790](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37790) Prevent indexing and holds queue updates when running update_localuse_from_statistics.pl
- [38173](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38173) Fix description of koha-dump --exclude-indexes
- [38237](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38237) Add logging to erm_run_harvester cronjob
- [38249](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38249) `koha-list` help typo about elastic

### Course reserves

#### Other bugs fixed

- [37838](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37838) Remove button broken on second page of course reserves item results

  **Sponsored by** *Toi Ohomai Institute of Technology, New Zealand*

### Database

#### Other bugs fixed

- [38522](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38522) Increase length of erm_argreements.license_info
  >This fixes the ERM agreements license information field (ERM > Agreements) so that more than 80 characters can be entered. It is now a medium text field, which allows entering up to 16,777,215 characters.

### ERM

#### Critical bugs fixed

- [37526](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37526) Handle redirects in SUSHI requests

#### Other bugs fixed

- [34920](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34920) ERM breaks if an ERM authorized value is missing a description
- [37008](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37008) "Help" link on ERM pages is not translatable
- [37275](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37275) Remove parenthesis from Select user button in ERM
- [37277](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37277) Identifiers need a space between the ISBN (Print) and ISBN (Online) in ERM
  >This fixes the display of identifiers for local titles so that are on separate lines, instead of joined together on the same line.
- [37395](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37395) Cannot hide columns in ERM tables
- [37491](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37491) Remove duplicate asset import from KBART template
- [38128](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38128) Agreement/license user selection not limited to users with ERM module permissions
- [38177](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38177) ERM - HoldingsIQ pagination does not work

### Fines and fees

#### Critical bugs fixed

- [37263](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37263) Creating default article request fees is not working
  >This fixes adding and deleting values for 'Default article request fees', so this works as expected (Administration > Circulation and fine rules > Default article request fees (when ArticleRequests enabled)). (This is related to the CSRF changes added in Koha 24.05 to improve form security.)

### Hold requests

#### Other bugs fixed

- [35771](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35771) Unselecting titles when making multi-hold does not have any effect
  >This fixes placing multiple holds for a patron from search results in the staff interface:
  >- The place holds page has checkboxes for unselecting some of the listed items - unselecting an item did not work and holds were placed on all items where a hold could be placed.
  >- Unselected items without a pickup location generated a 500 error.
- [36970](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36970) (Bug 34160 follow-up) Barcode should be html filtered, not uri filtered in holds queue view
  >This fixes the display of barcodes with spaces in the holds queue. Barcodes are now displayed correctly with a space, rather than with '%20'.
- [38186](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38186) Cancelling a hold from the holds over tab shouldn't trigger "return to home" transfer on a lost item
- [38239](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38239) Incorrect number of items to pull in holds to pull report with partially filled holds

  **Sponsored by** *Ignatianum University in Cracow*

### Holidays

#### Critical bugs fixed

- [38357](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38357) When adding new holidays Koha sometimes copies same holidays to other librarys

### I18N/L10N

#### Critical bugs fixed

- [36171](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36171) Extraction of Template Toolkit directive as translatable string causes patron view error in several languages
  >This fixes the extraction of strings that were causing translation errors. Template Tookit tags that contained HTML tags were split and treated as text that could be translated, instead of a Template Toolkit tag.

#### Other bugs fixed

- [35769](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35769) Untranslatable strings when placing holds in staff
  >This fixes some strings that were not made available for translating for holds in the staff interface.
- [37257](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37257) Copy in OPAC datatable untranslatable

  **Sponsored by** *Athens County Public Libraries*
- [37814](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37814) Wrong use of '__()' in .tt files

  **Sponsored by** *Athens County Public Libraries*
- [38085](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38085) Untranslatable options in OPACAuthorIdentifiersAndInformation
- [38138](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38138) Main contact method in hold pop-up untranslatable

### ILL

#### Other bugs fixed

- [37178](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37178) Column "comments" in ILL requests table gives error on sorting, paging cannot be changed
- [37194](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37194) Improve link from unconfigured ILL module

### Installation and upgrade (command-line installer)

#### Other bugs fixed

- [38385](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38385) DB updates not displayed properly on the UI

### Label/patron card printing

#### Other bugs fixed

- [37206](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37206) Removing an item from a label batch should be a CSRF-protected POST operation

  **Sponsored by** *Athens County Public Libraries*
- [37863](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37863) Patron card batches don't detect when the patron is already in the list

### Lists

#### Other bugs fixed

- [38020](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38020) Fix 'delete list' button to have same formatting as 'edit list'
  >This fixes the items in the 'Edit' menu for lists in the staff interface so that the options (Edit list, Delete list) are correctly left aligned. Previously, 'Delete list' was indented.
- [38251](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38251) "Remove selected items" button not removing single item in OPAC lists

  **Sponsored by** *Chetco Community Public Library*

### MARC Authority data support

#### Critical bugs fixed

- [37235](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37235) Download single authority results in 500 error

  **Sponsored by** *Athens County Public Libraries*

#### Other bugs fixed

- [37252](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37252) Saving an authority record as MADS (XML) fails
  >This fixes the saving of authority records in MADS format in the staff interface (Authorities > search results > authority details > Save > MADS (XML)). Before this fix, the downloaded records had a zero file size and were empty.

### MARC Bibliographic data support

#### Other bugs fixed

- [28075](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28075) Add missing UNIMARC value for coded data 135a
  >This updates the UNIMARC 135$a subfield to add missing values.
- [34346](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34346) Adding duplicate tag to a framework should give user readable message
- [37357](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37357) Authorised values in control fields cause Javascript errors

### Notices

#### Critical bugs fixed

- [38089](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38089) Fix incorrect regular expression from bug 33478 and move styles to head

#### Other bugs fixed

- [32575](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32575) gather_print_notices.pl sends attachment as body of email or poorly named txt file
  >This fixes emails generated by the misc/cronjobs/gather_print_notices.pl script. It adds empty text to the body of the email, so that the HTML file with the print notices is correctly attached to the email, and can be correctly printed. Because of the way the notices were being sent, and the way that different email clients handle different types of attachments, the notices were sometimes inserted into the body of the email or attached as poorly named text files.
- [37642](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37642) Generated letter should use https in header
  >This updates http links to W3C standards used in notice headers to https links.

### OPAC

#### Other bugs fixed

- [22223](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22223) Item url double-encode when parameter is an encoded URL
- [24690](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24690) Make OPACPopupAuthorsSearch work with search terms containing parenthesis
  >This fixes the OPAC so that when OPACPopupAuthorsSearch is enabled, author names not linked to an authority record that have parenthesis (for example, Criterion Collection (Firm)) correctly return results. Previously, author names with parenthesis did not return search results.

  **Sponsored by** *Athens County Public Libraries*
- [35126](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35126) Remove the use of event attributes from when adding records to lists in the OPAC
- [36557](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36557) Improve logic and display of OPAC cart, tag, and lists controls
  >This fixes errors in the way features are displayed in OPAC result lists so that controls for holds, tags, lists, and so on, are shown or hidden according to system preferences.
  >
  >It converts the Cart/Lists dropdown to separate buttons, making the display logic simpler and making the interface more consistent with updates to the staff interface search results.
- [36950](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36950) Improve placement of catalog concern banner in the OPAC
- [37057](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37057) OPACShowUnusedAuthorities displays unused authorities regardless
  >This fixes authority searching in the OPAC. Using the OPACShowUnusedAuthorities system preference now works as expected when using Zebra and Elasticsearch search engines:
  >- if set to "Show", unused authorities are shown in the search results
  >- if set to "Don't show", unused authorities are not shown in the search results.
  >A regression was causing unused authorities to show in the search results when the system preference was set to "Don't show".
- [37158](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37158) OPAC recalls history table not responsive

  **Sponsored by** *Athens County Public Libraries*
- [37629](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37629) Link to news are broken
- [37679](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37679) Dublin Core export option broken
- [37684](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37684) Direct links to expired news are broken
- [37827](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37827) Switch OPAC download list form from POST to GET

  **Sponsored by** *Chetco Community Public Library*
- [37853](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37853) Returning to your account at the end of changing your password in the OPAC doesn't need to POST a form

  **Sponsored by** *Chetco Community Public Library*
- [37887](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37887) OPAC password recovery needs to use a cud- op while POSTing new password

  **Sponsored by** *Chetco Community Public Library*
- [37931](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37931) Wrong OPAC facet item types label
- [38100](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38100) Items with damaged status are shown in OPAC results as "Not available" even with AllowHoldsOnDamagedItems
- [38132](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38132) Add data-isbn to shelfbrowser images
- [38231](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38231) Adjust CSS for search result controls in the OPAC

  **Sponsored by** *Athens County Public Libraries*
- [38362](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38362) Printing lists only prints the ten first results in the OPAC
  >This fixes printing lists in the OPAC so that all the items are printed, instead of only the first 10.
- [38463](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38463) Unnecessary CSRF token in OPAC authority search
  >This fixes the OPAC authority search result URL so that it no longer includes the CSRF token, and makes the URL more readable. (This is related to the CSRF changes added in Koha 24.05 to improve form security.)

  **Sponsored by** *Chetco Community Public Library*

### Patrons

#### Critical bugs fixed

- [37892](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37892) Patron category 'can be a guarantee' means that same category cannot be a guarantor

#### Other bugs fixed

- [30397](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30397) Duplicate '20' option in dropdown 'Show entries' menu
  >This fixes the options for the number of entries to show for patron search results in the staff interface - 20 was listed twice.
- [30648](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30648) Title is lost in holds history when bibliographic record is deleted
- [34610](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34610) ProtectSuperlibrarianPrivileges, not ProtectSuperlibrarian
  >This fixes the hover message when attempting to grant the `superlibrarian` permission (Access to all librarian functions) to a patron. It changes the message to use the correct system preference name "The system preference ProtectSuperlibrarianPrivileges is enabled", instead of "..ProtectSuperlibrarian...". 
  >
  >(The message appears over the tick box next to the permission name if the patron attempting to set the permissions is not a super librarian, and the ProtectSuperlibrarianPrivileges is set to "Allow only superlibrarians" - only super librarians can give other staff patrons superlibrarian access.)
- [35508](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35508) Update borrowers.updated_on when modifying a patron's attribute
  >This patch causes the patron field "Updated on" to behave as expected and be updated when a patron attribute is changed.
  >Before this patch, if while editing a patron only the value of a patron attribute was changed, the patron's updated_on date would not be updated.
- [35987](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35987) See highlighted items below link broken
- [37365](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37365) Bad redirect when adding a patron message from members/files.pl
  >This fixes a redirect when adding a patron message straight after uploading a patron file (when EnableBorrowerFiles is enabled). Before this fix, an error message "Patron not found. Return to search" was displayed if you added a message straight after you finished uploading a file (the "Add message" option on other pages worked as expected).
- [37368](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37368) Patron searches break when surname and firstname are set to NULL
  >This fixes an error when searching for patrons in the staff interface (for both the search in the header and the sidebar). If you have a patron without a last name or first name, and search using a space, the search did not complete and generated a browser console error.
- [37528](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37528) Using borrowerRelationship while guarantor relationship is unchecked from BorrowerMandatoryField results in error

  **Sponsored by** *Koha-Suomi Oy*
- [37562](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37562) Duplicate patron check when user cannot see patron leads to a blank popup
- [38005](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38005) 500 error on self registration when patron attribute is set as mandatory
- [38109](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38109) Patron category types are not sorted when entering/editing patrons
- [38112](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38112) Description of patrons search no longer displayed
- [38188](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38188) Fix populating borrowernumberslist from patron_search_selections

  **Sponsored by** *Koha-Suomi Oy*

### Plugin architecture

#### Critical bugs fixed

- [37872](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37872) ILL module has issues when plugins are disabled (enable_plugins = 0)
  >This fixes an issue when plugins are not enabled and the ILL module is enabled. This caused an error on the About Koha > System information section.
  >This also fixes a page error shown when accessing the ILL module with enable_plugins = 0 in koha-conf.xml.

### REST API

#### Other bugs fixed

- [37032](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37032) REST API: Unable to call item info via holds endpoint

  **Sponsored by** *Koha-Suomi Oy*
- [37535](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37535) Adding a debit via API will show the patron as the librarian that caused the debit
- [37687](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37687) API query operators list doesn't match documentation
  >This restores "-not_in" so that it is now listed as a valid operator for filtering API responses.
- [38390](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38390) Add 'subscriptions+count' embed to vendors endpoint

  **Sponsored by** *PTFS Europe* and *ByWater Solutions*

### Reports

#### Other bugs fixed

- [37108](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37108) Cash register statistics wizard is wrongly sorting payment by home library of the manager
- [37987](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37987) Downloading SQL report in .tab format is slow

  **Sponsored by** *Koha-Suomi Oy*

### SIP2

#### Other bugs fixed

- [23426](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23426) Empty AV field returned in 'patron info' in addition to those requested
  >This fixes SIP2 responses to remove the empty AV field in patron information responses, when fine information is requested. It also:
  >- adds the active currency as part of the response (BH)
  >- fixes the number of items in the response which are specified in BP and BQ, when other items as fine items are requested.
- [37582](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37582) SIP2 responses can contain newlines when a patron has multiple debarments
- [38284](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38284) handle_patron_status dies if patron not found
  >This fixes patron status SIP2 request responses if the request has an invalid or empty card number or PIN, and options are set for the TrackLastPatronActivityTriggers system preference. The SIP request was silently dying.

  **Sponsored by** *PTFS Europe*
- [38344](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38344) Don't send "Thank you !" as screen message
  >This fixes a typo in a SIP output message - "Thank you !" should be "Thank you!" (note the space before the exclamation mark).

### Searching

#### Other bugs fixed

- [37167](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37167) Fix mapping call number searches to Z39.50
  >This fixes how the Z39.50 search form is populated when using the Z39.50/SRU search option, from advanced search results in the staff interface where a "Call number" search is made. It now autofills the searched for value in the "Dewey" field instead of the "Title" field. 
  >
  >(Even though the field is labelled "Dewey", it also searches for Library of Congress call numbers in the 050 tag. Note that there are other issues with the search form, the labels used, and what is actually searched for - there are separate bugs for these).
- [37244](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37244) Selecting home library or holding library facet changes library dropdown
- [37249](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37249) Item search column filtering broken
- [37333](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37333) Search filters using OR are not correctly grouped
- [37369](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37369) Item search column filtering can't use descriptions

  **Sponsored by** *Koha-Suomi Oy*
- [37998](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37998) Tabs and backslashes in the data break item search display

  **Sponsored by** *Ignatianum University in Cracow*

### Searching - Elasticsearch

#### Other bugs fixed

- [33348](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33348) Show authority heading use with Elasticsearch
  >This fixes the ShowHeadingUse system preference so that it now works with Elasticsearch. When enabled, this option adds a new column to authority search results in the staff interface - it lists what the heading can be used for (based on the values in the MARC entry for 008/14-16), for example:
  >  ✔ Main/Added Entry
  >  ✔ Subject
  >  x Series Title
  >
  >(This feature was originally added to Koha 22.05.00 by bug 29990, but only worked with the Zebra search engine.)

  **Sponsored by** *Education Services Australia SCIS*
- [37319](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37319) Move mappings for 752ad (MARC21) and 210a/214a (UNIMARC) to pl index
- [37446](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37446) Home/holding library facets missing user friendly label
  >This fixes the facet labels for holdingbranch and homebranch to ensure they say "Holding libraries" or "Home libraries" when Elasticsearch is enabled.

  **Sponsored by** *Toi Ohomai Institute of Technology, New Zealand*
- [37857](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37857) Unable to select type "Geo point" or "Call number" when adding a search field
  >This fixes the "Type" dropdown list when configuring search fields. It adds two missing options - Call number, and Geo point (Administration > Catalog > Search engine configuration (Elasticsearch) > Search fields > Type column options).
- [38416](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38416) Failover to MARCXML if cannot roundtrip USMARC when indexing

### Self checkout

#### Other bugs fixed

- [37027](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37027) Some dataTable controls in SCO seem unnecessary
- [37525](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37525) Self checkout: "Return this item" doesn't show up in scan confirmation screen despite SCOAllowCheckin being allowed
- [38041](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38041) Not all self checkout errors behave the same

### Serials

#### Critical bugs fixed

- [38378](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38378) Serial frequency deletion is broken

  **Sponsored by** *Chetco Community Public Library*

#### Other bugs fixed

- [29818](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29818) Cannot save subscription frequency without display order

  **Sponsored by** *Chetco Community Public Library*

### Staff interface

#### Critical bugs fixed

- [37916](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37916) Plugin search and install regression
- [38118](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38118) Removed empty columns on holdings table on details page are not restored when new items loaded

#### Other bugs fixed

- [37065](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37065) Bookings tab should filter out expired bookings by default
  >This fixes the list of bookings for items so that only current bookings are listed, and excludes expired bookings. There is now a link, "Show expired", to display all bookings.
- [37213](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37213) Improve breadcrumbs in rotating collections
  >This fixes the breadcrumbs for rotating collections and makes them more consistent with other breadcrumbs (Tools > Rotating collections > New collection).
- [37233](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37233) Library URL broken in the libraries table
  >This fixes the URL link for a library in the staff interface (Administration > Basic parameters > Libraries) so that it works as expected. The link was not correctly formatted and it generated a 404 page not found error.
- [37393](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37393) Bundle items don't show their host in the staff interface
  >This fixes the item status for an item in a bundle, shown in the staff interface's holdings table. If an item is part of a bundle, the item status should show as "Not for loan (Added to bundle). In bundle: [Title and link to record it is bundled with]". It was not showing the "In bundle: [...]" text and link to the bundled item.
  >
  >(Note: This fixes the staff interface, the OPAC correctly shows the text and link. To use the bundle feature: 
  >1) For a record's leader, set position "7- Bibliographic level" to "c- Collection".
  >2) Use the "Manage bundle" action for the record's item, and add items to the bundle.)
- [37928](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37928) "Upload image" item not correctly styled
- [37954](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37954) Unable to hide barcode column in holdings table
  >This fixes hiding the barcode column on the staff interface for a record's holdings table. You can now turn on or off hiding the barcode by default, and select the display of the barcode column using the 'Columns' setting.
- [38071](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38071) "Clear filter" on catalogue details page always disabled
  >The fixes the global "Clear filter" for tables in the staff interface so that you can now clear the filter. It was previously greyed out, and you needed to refresh the page to clear the filter.
- [38130](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38130) Cannot filter items on library name
- [38146](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38146) Last seen date is missing the time in the item holdings table
- [38240](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38240) Filtering resulting in no result will hide filters

### System Administration

#### Critical bugs fixed

- [38328](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38328) Cannot delete ILL batch statuses

  **Sponsored by** *Chetco Community Public Library*

#### Other bugs fixed

- [35257](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35257) Only admin start page uses "circulation desks"
  >This changes the Koha administration page title for "Circulation desks" to "Desks" for consistency - all other areas such as the sidebar, page titles, and breadcrumbs all use just "Desks". It also updates the UseCirculationDesks system preference description.
- [37209](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37209) Improve record overlay rules validation and styling
  >This fixes the validation for the record overlay rules page (in line with the coding guidelines):
  >- the 'Tag' field is marked as required if you add or edit a rule and leave it empty
  >- pressing enter now saves a new or edited rule
- [37229](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37229) Table configuration listings for course reserves incorrect

  **Sponsored by** *Athens County Public Libraries*
- [37329](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37329) Typo: authorised value in patron attribute types
- [37404](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37404) Typo in intranetreadinghistory description
- [37606](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37606) Framework export module should escape double quotes
- [37766](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37766) Fix forms that POST without an op in MARC bibliographic frameworks

  **Sponsored by** *Chetco Community Public Library*
- [37905](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37905) Correctly fix the "last hour" filter on the job list
- [38309](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38309) Cannot delete additional fields
  >This fixes deleting additional fields (Administration - Additional parameters > Additional fields) - deleting fields now works as expected. Previously, attempting to delete a field would generate a blank page and the field was not deleted. (This is related to the CSRF changes added in Koha 24.05 to improve form security.)

  **Sponsored by** *Chetco Community Public Library*

### Templates

#### Other bugs fixed

- [35232](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35232) Misspelled ID breaks label on patron lists form
- [35238](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35238) Incorrect label markup in patron card creator printer profile edit form
  >This fixes an accessibility issue in the HTML markup for the patron card creator printer profile edit form.
- [35239](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35239) Missing form field ids in batch patron modification template
  >This fixes the batch patron modification edit form labels so that they all have IDs, and the input box now receive the focus when clicking on the label (this includes patron attribute fields, but excludes date fields). This is an accessibility improvement. Before this, you had to click in the input box to add a value.

  **Sponsored by** *Athens County Public Libraries*
- [36905](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36905) Terminology: home locations / home collections
  >This removes the unnecessary word "home" from several aria-labels in OPAC search facets. For example, "Show more home locations" was changed to "Show more locations". (Note that there is no visible change to the OPAC.)
- [37231](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37231) (Bug 34940 follow-up) Highlight logged-in library in facets does not work with ES

  **Sponsored by** *Ignatianum University in Cracow*
- [37242](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37242) Don't use the term branch in cash register administration
- [37264](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37264) Fix delete button on staff interface's suggestion detail page

  **Sponsored by** *Athens County Public Libraries*
- [37595](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37595) Double HTML escaped ampersand in pagination bar
- [37848](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37848) "Run with template" options need formatting

  **Sponsored by** *Athens County Public Libraries*
- [37977](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37977) Fix some issues with labels in inventory form

  **Sponsored by** *Chetco Community Public Library*
- [38476](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38476) Use anchor tag for DataTables configure button
  >This fixes the "Configure" button for tables, so that you can now right-click and open the table settings in a new tab.

### Test Suite

#### Other bugs fixed

- [36919](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36919) t/db_dependent/Koha/Object.t produces warnings
- [36935](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36935) BackgroundJob/ImportKBARTFile.t generates warnings
  >This removes unnecessary warning messages generated in the log files if the import of KBART files in the ERM module are successful (EOF - End of data in parsing input stream). It also adds error handling tests to the test suite.
- [36936](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36936) api/v1/bookings.t generates warnings
- [36944](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36944) Auth.t should not fail when AutoLocation is enabled
- [37283](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37283) t/db_dependent/selenium/authentication.t is failing
- [37289](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37289) t/db_dependent/api/v1/authorised_values.t is failing under specific circumstances
- [37490](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37490) Add test to detect when yarn.lock is not updated
- [37620](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37620) Fix randomly failing tests for cypress/integration/InfiniteScrollSelect_spec.ts
- [37963](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37963) Improve error handling and testing of ERM eUsage SUSHI
- [38322](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38322) Wrong comment in t/db_dependent/api/v1/erm_users.t
  >This fixes ERM user tests in t/db_dependent/api/v1/erm_users.t. It was not correctly testing the permissions for listing users. It was supposed to check that two users were returned, but only one was returned.
- [38513](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38513) Fix Biblio.t for Koha_Main_My8 test configuration
- [38526](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38526) Auth_with_* tests fail randomly

### Tools

#### Other bugs fixed

- [36132](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36132) Allow users to delete multiple patron lists at once on any page
  >This fixes patron lists so that when there are more than 20 lists, the lists on the next pages can be deleted. Previously, you were only able to delete the lists on the first page.
- [37243](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37243) Tag moderation actions should be in the last column

  **Sponsored by** *Athens County Public Libraries*
- [37326](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37326) Batch modification should decode barcodes when using a barcode file
- [37580](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37580) Unique holiday descriptions are not editable

  **Sponsored by** *Westlake Porter Public Library*
- [37730](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37730) Batch patron modification table horizontal scroll causes headers to mismatch
  >This fixes the table for the batch patron modification tool (Tools > Patrons and circulation > Batch patron modification). When you scrolled down the page so that table header rows are "sticky", and then scrolled to the right, the table header columns were fixed instead of changing to match the column contents.
- [37965](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37965) Fix regression of convert_urls setting in TinyMCE which causes unexpected URL rewriting
- [38266](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38266) Incorrect attribute disabled in patron batch modification
- [38275](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38275) Unable to delete patron card creator images
  >This fixes deleting images when using the patron card creator's image manager. You could not delete images, and received an error message "WARNING: An unsupported operation was attempted. Please have your system administrator check the error log for details." (This is related to the CSRF changes added in Koha 24.05 to improve form security.)

### Web services

#### Critical bugs fixed

- [36560](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36560) ILS-DI API POSTS cause CSRF errors
  >This change creates an anti-CSRF exception so that the ILS-DI API will work without a CSRF token. Libraries are reminded that they should be careful when configuring the ILS-DI:AuthorizedIPs system preference for access to the ILS-DI API.

#### Other bugs fixed

- [35442](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35442) Script migration_tools/build_oai_sets.pl is missing ORDER BY
- [38131](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38131) ILS-DI documentation still shows renewals instead of renewals_count
- [38233](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38233) ILS-DI GetRecords should filter out items hidden in OPAC and use OPAC MARCXML
  >This updates the ILS-DI GetRecords service to use the OPAC version of the MARCXML and filter items based on their OPAC visibility. For example, if OpacHiddenItems includes "withdrawn: [1]" (hide items with a withdrawn status of 1) and hidelostitems is set to "Don't show", then an ILS_DI request for a record will not show items with a withdrawn status = 1 (Withdrawn). Previously, there was no way to hide hidden items from the ILS-DI request.

## Enhancements 

### Database

#### Enhancements

- [31143](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31143) We should attempt to fix/identify all cases where '0000-00-00' may still remain in the database
  >This enhancement:
  >
  >1. Updates the misc/maintenance/search_for_data_inconsistencies.pl script so that it identifies any date fields that have 0000-00-00 values.
  >
  >2. Adds a new script misc/maintenance/fix_invalid_dates.pl that fixes any date fields that have '0000-00-00' values (for example: dateofbirth) by updating them to 'NULL'. 
  >
  >Patron, item, and other date fields with a value of '000-00-00' can cause errors. This includes:
  >- API errors
  >- stopping the patron autocomplete search working
  >- generating a 500 internal server error:
  >  . for normal patron searching
  >  . when displaying item data in the holdings table

### ERM

#### Enhancements

- [37856](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37856) Some SUSHI providers require the platform parameter
  >This enhancement adds a new "platform" field to ERM's usage data providers, allowing the harvest of SUSHI usage data from providers that require this parameter.

### MARC Bibliographic data support

#### Enhancements

- [37114](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37114) Update MARC21 default framework to Update 38 (June 2024)
  >This enhancement updates the default MARC21 bibliographic framework for new installations to reflect the changes from Update 38 (June 2024).
  >
  >NOTES:
  >- For existing installations, manually updating the default and other frameworks with the changes is required.
  >- For new installations, only the default framework is updated. Manually updating other frameworks with the changes is required.

### SIP2

#### Enhancements

- [37087](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37087) Add support for TCP keepalive to SIP server
  >This change adds 3 new configuration options to the SIPconfig.xml. These are custom_tcp_keepalive, custom_tcp_keepalive_time, and custom_tcp_keepalive_intvl. Usage is documented in C4/SIP/SIPServer.pm. They are used to control TCP keepalives for the SIP server. Configuration of these parameters is essential for running a SIP server in Microsoft Azure.

### Templates

#### Enhancements

- [33925](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33925) Improve translation of title tags: Serials
  >This enhancement updates the templates for the serials pages to allow title tags to be more easily translated. It also updates some templates to add consistency for the page title, breadcrumb navigation, and page headers, and to add the "page-section" <div> where it was lacking.

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Armenian (hy_ARMN)](https://koha-community.org/manual/24.05//html/) (58%)
- [Bulgarian (bg_CYRL)](https://koha-community.org/manual/24.05//html/) (98%)
- [Chinese (Traditional)](https://koha-community.org/manual/24.05/zh_Hant/html/) (92%)
- [English](https://koha-community.org/manual/24.05//html/) (100%)
- [English (USA)](https://koha-community.org/manual/24.05/en/html/)
- [French](https://koha-community.org/manual/24.05/fr/html/) (55%)
- [German](https://koha-community.org/manual/24.05/de/html/) (69%)
- [Greek](https://koha-community.org/manual/24.05//html/) (78%)
- [Hindi](https://koha-community.org/manual/24.05/hi/html/) (72%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (97%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified) (88%)
- Chinese (Traditional) (89%)
- Czech (68%)
- Dutch (87%)
- English (100%)
- English (New Zealand) (63%)
- English (USA)
- Finnish (99%)
- French (99%)
- French (Canada) (99%)
- German (100%)
- Greek (58%)
- Hindi (98%)
- Italian (82%)
- Norwegian Bokmål (75%)
- Persian (fa_ARAB) (97%)
- Polish (100%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (88%)
- Russian (94%)
- Slovak (61%)
- Spanish (100%)
- Swedish (87%)
- Telugu (69%)
- Turkish (82%)
- Ukrainian (72%)
- hyw_ARMN (generated) (hyw_ARMN) (63%)
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

The release team for Koha 24.05.06 is


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
new features in Koha 24.05.06
<div style="column-count: 2;">

- Athens County Public Libraries
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)
- Chetco Community Public Library
- Education Services Australia SCIS
- Ignatianum University in Cracow
- Karlsruhe Institute of Technology (KIT)
- [Koha-Suomi Oy](https://koha-suomi.fi)
- [PTFS Europe](https://ptfs-europe.com)
- Toi Ohomai Institute of Technology, New Zealand
- Westlake Porter Public Library
- kohawbibliotece.pl
</div>

We thank the following individuals who contributed patches to Koha 24.05.06
<div style="column-count: 2;">

- Aleisha Amohia (6)
- Pedro Amorim (38)
- Tomás Cohen Arazi (16)
- Noémie Ariste (1)
- Oliver Behnke (1)
- Matt Blenkinsop (11)
- Alex Buckley (3)
- Kevin Carnes (1)
- Nick Clemens (42)
- David Cook (21)
- Paul Derscheid (7)
- Jonathan Druart (43)
- Michał Dudzik (1)
- Magnus Enger (3)
- Laura Escamilla (1)
- Eugene Jose Espinoza (1)
- Katrin Fischer (5)
- Andrew Fuerste-Henry (2)
- Eric Garcia (4)
- Lucas Gass (27)
- Didier Gautheron (1)
- Thibaud Guillot (1)
- Bo Gustavsson (1)
- Kyle M Hall (10)
- Andrew Fuerste Henry (3)
- Mason James (2)
- Andreas Jonsson (2)
- Janusz Kaczmarek (14)
- Jan Kissig (8)
- Thomas Klausner (1)
- Michał Kula (1)
- Emily Lamancusa (7)
- Sam Lau (5)
- Brendan Lawlor (1)
- Owen Leonard (26)
- Yanjun Li (2)
- CJ Lynce (1)
- Julian Maurice (7)
- Matthias Meusburger (1)
- David Nind (2)
- Alexandre Noel (2)
- Andrew Nugged (1)
- Katariina Pohto (1)
- Martin Renvoize (14)
- Phil Ringnalda (23)
- Adolfo Rodríguez (2)
- Marcel de Rooy (7)
- Caroline Cyr La Rose (5)
- Johanna Räisä (2)
- Fridolin Somers (7)
- Catalyst Bug Squasher (1)
- Lari Strand (1)
- Raphael Straub (2)
- Emmi Takkinen (6)
- Lari Taskula (3)
- Petro Vashchuk (1)
- George Veranis (1)
- Hinemoea Viault (1)
- wainuiwitikapark (5)
- Hammat Wele (4)
- Wainui Witika-Park (8)
- Baptiste Wojtkowski (6)
- Chloe Zermatten (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 24.05.06
<div style="column-count: 2;">

- Athens County Public Libraries (26)
- [BibLibre](https://www.biblibre.com) (21)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (5)
- [ByWater Solutions](https://bywatersolutions.com) (85)
- [Cape Libraries Automated Materials Sharing](https://info.clamsnet.org) (1)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha) (19)
- Catalyst Open Source Academy (5)
- Chetco Community Public Library (23)
- [Dataly Tech](https://dataly.gr) (1)
- David Nind (2)
- Dubuque County Library District (2)
- gustavsson.one (1)
- [Hypernova Oy](https://www.hypernova.fi) (3)
- Independant Individuals (30)
- Karlsruhe Institute of Technology (KIT) (2)
- Koha Community Developers (43)
- [Koha-Suomi Oy](https://koha-suomi.fi) (8)
- KohaAloha (2)
- kohawbibliotece.pl (1)
- Kreablo AB (2)
- laposte.net (2)
- [Libriotech](https://libriotech.no) (3)
- [LMSCloud](lmscloud.de) (7)
- Lund University Library, Sweden (1)
- Max Planck Institute for Gravitational Physics (1)
- [Montgomery County Public Libraries](montgomerycountymd.gov) (7)
- [Prosentient Systems](https://www.prosentient.com.au) (21)
- [PTFS Europe](https://ptfs-europe.com) (64)
- Rijksmuseum, Netherlands (7)
- [Solutions inLibro inc](https://inlibro.com) (12)
- [Theke Solutions](https://theke.io) (16)
- westlakelibrary.org (1)
- Wildau University of Technology (8)
- [Xercode](https://xebook.es) (2)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Alyssa (1)
- Aleisha Amohia (11)
- Pedro Amorim (23)
- Tomás Cohen Arazi (13)
- Sukhmandeep Benipal (6)
- Catrina Berka (1)
- Matt Blenkinsop (8)
- Philippe Blouin (1)
- Sonia Bouis (2)
- Alex Buckley (1)
- Nick Clemens (19)
- David Cook (6)
- Chris Cormack (15)
- Jake Deery (2)
- Paul Derscheid (28)
- Roman Dolny (24)
- Jonathan Druart (24)
- Magnus Enger (5)
- Laura Escamilla (4)
- Katrin Fischer (367)
- Eric Garcia (1)
- Lucas Gass (403)
- Victor Grousset (7)
- Kyle M Hall (12)
- Olivier Hubert (1)
- Thomas Klausner (6)
- Kristi Krueger (2)
- Michał Kula (1)
- Emily Lamancusa (16)
- Sam Lau (6)
- Laura_Escamilla (2)
- Brendan Lawlor (16)
- Owen Leonard (14)
- Yanjun Li (3)
- Lucas (1)
- CJ Lynce (3)
- Martha (1)
- Jesse Maseto (1)
- Julian Maurice (6)
- Kelly McElligott (1)
- Esther Melander (1)
- David Nind (112)
- Laura ONeil (1)
- Eric Phetteplace (1)
- Hannah Prince (1)
- Martin Renvoize (129)
- Riomar Resurreccion (1)
- Phil Ringnalda (29)
- Marcel de Rooy (34)
- Caroline Cyr La Rose (8)
- Michaela Sieber (1)
- Fridolin Somers (1)
- Sam Sowanick (7)
- Tadeusz „tadzik” Sośnierz (1)
- Michelle Spinney (2)
- Emmi Takkinen (4)
- Olivier V (15)
- Loïc Vassaux-Artur (1)
- Olivier Vezina (1)
- wainuiwitikapark (15)
- Shi Yao Wang (4)
- Baptiste Wojtkowski (6)
- Chloe Zermatten (2)
- Anneli Österman (5)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 24.05.x

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 06 Jan 2025 05:02:40.
