# RELEASE NOTES FOR KOHA 24.11.04
24 Apr 2025

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 24.11.04 can be downloaded from:

- [Download](https://download.koha-community.org/koha-24.11.04.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 24.11.04 is a bugfix/maintenance and security release.

It includes 20 enhancements, 97 bugfixes and 2 security fixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [36867](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36867) ILS-DI AuthorizedIPs should deny explicitly except those listed
  >This patch updates the ILS-DI authorized IPs preference to deny all IPs not listed in the preference.
  >
  >Previously if no text was entered the ILS-DI service was accessible by all IPs, now it requires explicitly defining the IPs that can access the service.
  >
  >Upgrading libraries using ILS-DI should check that they have the necessary IPs defined in the system preference.
- [38969](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38969) Reflected XSS vulnerability in tags

## Bugfixes

### About

#### Other bugs fixed

- [38617](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38617) Fix warning about auto increment and biblioitems
  >This fixes the table name in the warning about auto increment and biblioitems on the About Koha > System information page.
  >
  >If the system identifies auto increment issues, the message is now "The following IDs exist in both tables biblioitems and deletedbiblioitems", instead of "...tables biblio and deletedbiblioitems".

### Acquisitions

#### Critical bugs fixed

- [38423](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38423) EDIFACT invoice files should skip orders that cannot be receipted rather than failing to complete
  >This fixes loading EDIFACT invoice files so that it skips a problematic order (usually a cancelled order or a deleted bibliographic or item record), reports any problem orders, and completes the processing of other orders. Previously, the EDIFACT page would get "stuck" and display as "Processing" for problematic orders, then the remainder of the orders in the file had to be manually receipted by library staff (as vendors are reluctant to re-process part invoices).

  **Sponsored by** *PTFS Europe*
- [39282](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39282) When adding an order from file, data entered in the "Item information" tab is not saved and invalid items are created
  >This fixes an issue that occurs in Acquisitions when adding an order from a new or staged file. If the system preference AcqCreateItem is set to create items when the order is placed, and item information is not imported from the uploaded MARC file, then the librarian would enter the item information in the "Item information" tab when confirming the order. The information from this tab was not getting processed correctly, which led to "empty" items being created.

#### Other bugs fixed

- [8425](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8425) Autobarcode generates duplicate barcodes with AcqCreateItems = on order
- [38698](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38698) Created by filter in acquisitions duplicate orders search always shows zero results
  >This fixes the "Basket created by" search when duplicating existing orders in acquisitions - it now returns results, previously no results were returned.
- [38765](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38765) Internal server error when merging invoices
  >This fixes merging of invoices (Acquisitions > Invoices > [select invoices from search results] > Merge selected invoices > Merge). Previously, clicking "Merge" caused an internal server error with the message "The given date <date> does not match the date format (iso)...".
- [38766](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38766) Opening, closing, or deleting and invoice from the Action drop-down can cause internal server error
  >This fixes closing and reopening of invoices using the action button options (Acquisitions > [Vendor] > Invoices > Actions) - when used from the search results when using invoice filters (for example, shipment to and from dates). This caused an internal server error with the message "The given date <date> does not match the date format (iso)...". It also adds a confirmation message when deleting an invoice.
- [38957](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38957) EDIFACT messages table should sort by 'Transferred date' descending by default
- [38986](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38986) Restore "Any" option to purchase suggestion filter by fund
- [39044](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39044) Fund dropdown not populated for order search on acqui-home

### Architecture, internals, and plumbing

#### Critical bugs fixed

- [38872](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38872) Only first 'a' node tested for wrong filters

#### Other bugs fixed

- [36229](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36229) koha-run-backups should be first daily job
  >This fixes the order of the daily cron jobs (/etc/cron.daily/koha-common) so that koha-run-backups is run first. 
  >
  >Reasons for this include:
  >
  >1. The koha-run-backups cron job takes a backup before running scripts that change database contents. If there is a problem with those scripts, you'll have a very recent backup on which to fallback.
  >
  >2. It's a resource intensive job. If you have a lot of Koha instances, this means you're running your most intensive job at the end of the job run, which might be a lot later in the day than you anticipate. (Of course, you can update /etc/crontab to change when /etc/cron.daily is run, but this will help reduce impact in the meantime.)
  >
  >Deployment of this change:
  >- New installations: This change will seamlessly apply for new installations.
  >- Existing installations:
  >  . You HAVEN'T manually modified the crontab: it will seamlessly apply.
  >  . You HAVE manually modified the crontab: you will be prompted, and will need to decide about applying the change.
  >  . Where deployment tools are used (such as Ansible): this will depend on what tools you use and how they are configured.
- [38855](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38855) test/README not removed by bug 22056
  >This removes an unused README file and directory (koha-tmpl/intranet-tmpl/prog/en/modules/test/README).
- [39172](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39172) Merging records no longer compares side by side
  >This patch fixes a regression when merging records in the cataloging module. Columns will show side by side again when comparing records for a merge.

### Authentication

#### Critical bugs fixed

- [38826](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38826) C4::Auth::check_api_auth sometimes returns $session and sometimes returns $sessionID
  >This fixes authentication checking so that the $sessionID is consistently returned (sometimes it was returning the session object). (Note: $sessionID is returned on a successful login, while $session is returned when there is a cookie for an authenticated session.)

### Cataloging

#### Other bugs fixed

- [39294](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39294) Not all settings stick when staging MARC records for import

### Circulation

#### Critical bugs fixed

- [38789](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38789) Wrong Transfer modal does not show
  >This fixes a regression. When an item in transit was checked in at a library other than the destination, it was not generating the "Wrong transfer" dialog box.
- [38793](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38793) When setting up automatic confirmation of transfers when dismissing the modal. It prevents manual cancellation
  >Fixes a transfer being silently not canceled (despite clicking the button) when system preferences TransfersBlockCirc = "don't block" and AutomaticConfirmTransfer = "do automatically confirm". Which should only be about confirming when dismissing the transfer modal.

#### Other bugs fixed

- [34068](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34068) Dropdown selector when changing pickup library should not depend on RESTdefaultPageSize
  >This fixes the dropdown list for holds pickup locations in the staff interface - it now shows the complete list of libraries. Previously, in some circumstances, it was not showing the complete list of pickup locations (for example, with RESTdefaultPageSize = 5 and AllowHoldPolicyOverride = Allow, it would only show the final page of libraries instead of the full list of libraries).
- [38232](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38232) Materials specified note un-checks 'forgive overdue charges' box
  >This fixes the remembering of the options when checking in items from Circulation > Check in > options icon in the barcode field.
  >
  >If the "Forgive overdue charges" option was selected (shown when the finesMode system preference is set to "Calculate and charge"), this selection was not remembered after checking in an item with a materials specified note (952$3).
- [38748](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38748) Library name is missing in return to home transfer slip
  >This fixes the generation of the transfer slip - the library to transfer an item to is now shown, instead of being blank.
- [38783](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38783) Row highlighting in the circulation history table for a patron doesn't look great
  >This fixes the circulation history table for a patron, and makes it easier to identify checked out items:
  >- the alternating row background colors are now white and grey, rather than:
  >  . Returned items: white/grey
  >  . Checked out items: yellow/grey
  >- checked out items are now shown as "Checked out" using an orange/gold badge in the "Return date" column
- [38853](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38853) 'Cancel selected' on holds table does not work
  >This fixes the "Cancel selected" button for a records' holds table in the staff interface - it now cancels the selected holds. Previously, after you confirmed the hold cancellation nothing happened (the background jobs didn't run and the holds were not cancelled). (This is related to the CSRF changes added in Koha 24.05 to improve form security.)

  **Sponsored by** *Chetco Community Public Library*
- [39108](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39108) Clicking the 'Ignore' button on hold found modal for already-waiting hold does not dismiss the modal
- [39183](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39183) If using automatic return claim resolution on checkout, each checkout will overwrite the previous resolution (again)
- [39270](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39270) Some bookable items cannot be booked

### Command-line Utilities

#### Critical bugs fixed

- [38894](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38894) Longoverdue cron should follow HomeOrHoldingBranch as well as CircControl when using --library flag
  >When the longoverdue cron is limited by library, it follows the CircControl system preference. When CircControl is set to "the item's library," this patch allows the HomeOrHoldingBranch system preference to further specify either the item's homebranch or the item's holdingbranch. This makes the longoverdue cron consistent with the application or circulation and fine rules.

#### Other bugs fixed

- [29238](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29238) Cataloging cron jobs are not logged
  >This fixes the scripts so that these cataloging cronjobs are now logged when run:
  >- misc/link_bibs_to_authorities.pl
  >- misc/cronjobs/merge_authorities.pl
  >- misc/migration_tools/remove_unused_authorities.pl
- [37920](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37920) writeoff_debts.pl should be logged
- [38104](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38104) share_usage_with_koha_community.pl: Check between two runs is not needed
- [38857](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38857) Cronjobs should log their start and command line parameters before processing options
  >This fixes all cronjobs so that if they fail because of bad parameters, information is now available in the log viewer to help with troubleshooting (when the CronjobLog system preference is enabled).
  >
  >Notes:
  >- This changed all the cronjobs in misc/cronjobs that had the 'cronlogaction'.
  >- It also changed misc/maintenance/fix_invalid_dates.pl (not a cronjob, but now only logs if confirmed - similar to misc/import_patrons.pl).
  >- For misc/cronjobs/purge_suggestions.pl, a verbose option was added for consistency.
- [39236](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39236) writeoff_debts.pl does not run

### ERM

#### Other bugs fixed

- [36627](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36627) Display importer for manually harvested SUSHI data
  >This fixes the ERM usage statistics import logs table to show who manually imported the SUSHI data. For eUSage > Data providers > [Name] >  Import logs, the "Imported by" column now shows the staff patron, instead of just "Cronjob".
- [38782](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38782) ERM eUsage related tests are failing
  >This fixes failing ERM usage tests.
- [38854](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38854) Unused 'class' prop in ToolbarButton

### Fines and fees

#### Critical bugs fixed

- [39025](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39025) Update patron account templates to use old_issue_id to display circ info

### I18N/L10N

#### Other bugs fixed

- [36836](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36836) Review ERM module for translation issues
  >This fixes multiple translation issues for the ERM module, including missing strings and following the coding guidelines.
- [38147](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38147) Edit button in bookings untranslatable
  >This fixes the 'Edit' and 'Cancel' actions for the bookings table for a record in the staff interface - these are now translatable.
- [38377](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38377) Improve translatability of remaining renewals counters
  >This fixes the translation strings for renewals - they now use named placeholders so that the correct order can be translated.
  >
  >Example: 
  >- In English: "4 of 5 renewals remaining"
  >- In Turkish: 
  >  . was incorrectly translated as "4 uzatma hakkınızdan 5 tane kaldı"
  >  . is now correctly translated as (5 uzatma hakkınızdan 4 tane kaldı"
- [39077](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39077) Translation script raises warnings for obsolete translations

### ILL

#### Other bugs fixed

- [38505](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38505) CirculateILL checkout broken if item does not have a barcode
- [38751](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38751) Creating ILL request through OPAC openURL explodes if same attribute defined twice
- [39175](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39175) Send request to partners explodes

### Installation and upgrade (command-line installer)

#### Critical bugs fixed

- [39460](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39460) Debian package install broken in 24.11 if no database change included in package (e.g. 24.11.03-2)

#### Other bugs fixed

- [38448](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38448) Fix inconsistencies in database update messages
  >This fixes some database update messages to improve their consistency with the database update guidelines.

### Lists

#### Other bugs fixed

- [39268](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39268) When switching tabs between 'My lists' and 'Public lists' incorrect lists can be displayed

  **Sponsored by** *Athens County Public Libraries*

### MARC Bibliographic data support

#### Other bugs fixed

- [38471](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38471) Typo: "Field suppresion, FSP (RLIN)"
  >Thus fixes a typo in the subfield description for authority framework 090$t - "Field suppresion" to "Field suppression". (This change only affects new installations - existing installations will need to manually update their authority frameworks.)

### MARC Bibliographic record staging/import

#### Other bugs fixed

- [33268](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33268) Overlay rules don't work correctly when source is set to *
  >This enhancement changes how marc overlay rules are evaluated. 
  >
  >Before the change rules with filter set to '*' (wildcard) where only applied when no other rules had been defined for a specific filter value, regardless of if any of the rules with that filter value matched or not.
  >
  >With this change we fallback to the wildcard filter rules even though rules with a matching filter value do exists, if no rule for that filter value matches. This resolves the issue of having to repeat the same default rules for each filter value rule set. If for some filter value the wildcard filter rules should be overridden, a wildcard tag rule for that filter value can be defined which will have higher precedence and override all the filter wildcard rules.
  >
  >In summary, the rules will applied as follows:
  >
  >- A matching rule is looked for based on context (module and filter value), if multiple contexts matches rules for the module with highest priority are used. The module priority is (from highest to lowest) "User name", "Patron category" and "Source".
  >
  >- If no matching rule is found, we fallback to the wildcard filter rules of the current context module.
  >
  >For Koha installations where marc overlay rules is in use a database migration will run that creates new rules if necessary to preserve the current behavior, so no user action needs to be taken in order to correct for this change.

  **Sponsored by** *Gothenburg University Library*

### Notices

#### Other bugs fixed

- [38777](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38777) HOLD letter should use the reply to of the library that hold is waiting at
  >This updates the HOLD letter to use the reply to email address of the library the hold is waiting at instead of the patron library to ensure replies go to the correct branch for the hold.

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
- [39056](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39056) Do not copy preferred_name to new patron when using Duplicate
- [39244](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39244) Duplicate and change password buttons missing if no borrowerRelationship defined and patron is not adult
- [39283](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39283) Middle name doesn't display in patron search results

### Point of Sale

#### Other bugs fixed

- [38667](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38667) Point of sale transaction history should not appear to be sortable
  >This removes the column sorting icons from the point of sale "Transactions to date" and "Older transactions" tables. The sort order for these tables is fixed, and clicking the icons had no effect.

  **Sponsored by** *Athens County Public Libraries*

### REST API

#### Other bugs fixed

- [37286](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37286) Fix REST API authentication when using Mojo apps
- [38679](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38679) GET /deleted/biblios missing some mappings
- [38926](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38926) POST /biblios returns 200 even if AddBiblio fails
- [38927](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38927) Unecessary call to FindDuplicate if x-confirm-not-duplicate is passed to POST /biblios
- [38929](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38929) POST endpoints not returning the Location header
- [38932](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38932) Adding debits and credits should return the correct Location header
- [39397](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39397) Searching a biblio by timestamp returns a different timestamp

### Reports

#### Other bugs fixed

- [37927](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37927) Show report name on page title when viewing SQL
  >This fixes the browser window/tab page title when viewing the SQL for a report (Reports > Saved reports > Actions > View) - it now includes the report name and number.

### SIP2

#### Critical bugs fixed

- [38375](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38375) SIP2 syspref SIP2SortBinMapping is not working

#### Other bugs fixed

- [38810](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38810) SIP account level system preference overrides not properly cleared between requests

### Searching

#### Other bugs fixed

- [14907](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14907) Item search: call numbers in item search results are ordered alphabetically
  >This fixes item search results when ordering the results by the call number. They are now correctly ordered using cn_sort, instead of a basic "alphabetical" order (cn_sort uses the appropriate sorting rules for the classification scheme).
- [38646](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38646) C4::Languages::getLanguages is very unreasonably slow (100+ ms)
- [38846](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38846) Function getLanguages is called unnecessarily for search result pages
  >This fixes OPAC and staff interface searching so that language option functions (C4::Languages::getLanguages) are only used on the advanced search pages and not the search result pages, where the output is not used.
  >
  >This should also help improve performance - this might be minor on a quiet system, but it could have an impact on a busier system (and reduces unnecessary database calls).

### Self checkout

#### Other bugs fixed

- [38174](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38174) Self checkout renders alert for each checkout in session instead of just most recent checkout

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
- [38724](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38724) Holdings table - filters shown after column visibility is updated
  >This fixes the holdings table. If you clicked "Columns" and you added or removed a column, it was automatically showing the column filters - but it didn't toggle "Hide filters" and you had to click twice to hide them.
- [38827](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38827) New search performed when column filters lose focus
  >This fixes DataTable tables to stop duplicate update queries being made when values are entered for filters and then the focus is lost (for example, clicking somewhere else on the screen).
- [38954](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38954) checkout type column should be hidden by colvis

### System Administration

#### Other bugs fixed

- [36163](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36163) Can't select a country for usage statistics

  **Sponsored by** *Ignatianum University in Cracow*
- [38738](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38738) additional-fields-entry.inc always closing select element even when it doesn't exist
- [38856](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38856) Typo: EmailAddressForPatronRegistrations - "chooose"
  >This fixes a spelling mistake in the EmailAddressForPatronRegistrations system preference description - "chooose" -> "choose".

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
- [38502](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38502) Use Bootstrap alert info class for messages on table settings page
  >This fixes the styles for informational messages on the table settings page (Administration > Additional parameters > Table settings). It updates the existing class (class="alert"), which doesn't add any style, to the Bootstrap 5 class (class="alert alert-info") - which now has a light blue background.

  **Sponsored by** *Athens County Public Libraries*
- [38665](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38665) Markup error in additional fields template title
  >This fixes a markup error in the browser page title for the additional fields page - there was an additional caret (>) at the start (> Additional fields > Administration > Koha, instead of Additional fields > Administration > Koha).

  **Sponsored by** *Athens County Public Libraries*
- [38845](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38845) OpacNoItemTypeImages required to show item type images in staff interface advanced search
  >This fixes the display of item type images in the staff interface's advanced search. The noItemTypeImages system preference now correctly controls the display of the item type images. Previously, it was incorrectly controlled by the OpacNoItemTypeImages system preference.
- [38921](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38921) Remove unused href from Cancel hold link

  **Sponsored by** *Chetco Community Public Library*
- [38958](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38958) Search history deletion broken in the staff interface
  >This fixes deleting catalog search history in the staff interface (when the EnableSearchHistory system preference is set to 'Keep') - the delete button now works. Previously, selected search terms could not be deleted. (This is related to the DataTables upgrade in Koha 24.11.)

### Tools

#### Other bugs fixed

- [38771](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38771) Typo 'AuthScuccessLog' system preference
  >This fixes the log viewer authentication module "Log not enabled" warning message for the log viewer. If either AuthFailureLog or AuthSuccessLog system preferences are set to "Don't log", the "Log not enabled" warning icon is now shown. Previously, if one of the system preferences was set to "Log", no warning icon was shown.
- [38870](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38870) Remove overflow scroll from batch patron modification

  **Sponsored by** *Athens County Public Libraries*

## Enhancements 

### About

#### Enhancements

- [36039](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36039) The output of audit_database.pl should be accessible through the UI
  >This enhancement makes the misc/maintenance/audit_database.pl script (added in Koha 23.11) available in the staff interface - About Koha > Database audit tab. The script compares the instance's database against kohastructure.sql and identifies any differences that need fixing. This is useful for identifying database issues that should be addressed before running a maintenance or release update.

### Architecture, internals, and plumbing

#### Enhancements

- [22415](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22415) Koha::EDI should not use Log::Log4perl directly
  >This enhancement changes the way EDI logging is done - it now uses the improved Koha::Logger, instead of Log::Log4perl.
- [36662](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36662) ILL - t/db_dependent/Illrequest should not exist
  >This enhancement moves the ILL test files to the correct folder structure - t/db_dependent/Koha/ILL/.
- [38483](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38483) C4::Heading::preferred_authorities is not used
  >This removes an unused method 'preferred_authorities' (Return a list of authority records for headings that are a preferred form of the heading).

  **Sponsored by** *Ignatianum University in Cracow*

### Cataloging

#### Enhancements

- [37398](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37398) Initialize a datepicker on all date/datetime fields when adding/editing items
  >This enhancement adds the date picker by default to all item date and datetime fields.

### Command-line Utilities

#### Enhancements

- [36365](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36365) compare_es_to_db.pl should offer a way to reconcile differences

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

- [26211](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26211) Patron age verification while doing the self-registration
  >This enhancement adds age verification checking to the self-registration and personal details forms. A message is now shown if the date of birth entered doesn't match with the patron category age range, "Patron's age is incorrect for their category. Please try again.".
- [35808](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35808) Remove obsolete responsive table markup from several pages in the OPAC
  >This enhancement removes obsolete responsive table markup (span.tdlabel) from several OPAC pages, as the tables now use the DataTables responsive features.

  **Sponsored by** *Athens County Public Libraries*

### Patrons

#### Enhancements

- [33454](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33454) Improve breadcrumbs for patron lists
  >This fixes the breadcrumbs for patron lists (Tools > Patrons and circulation > Patron lists) so that they are now more consistent with other breadcrumbs, and improves their translatability (Tools > Patron lists > Add patrons to 'List name', instead of Tools > Patron lists > List name).

### Searching - Elasticsearch

#### Enhancements

- [36729](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36729) Add publisher/distributor number (MARC21 028$a) to standard identifier search index
  >This enhancement adds 028$a (MARC21 - Publisher or distributor number) to the standard number (standard-identifier) search index, searchable using the Advanced search > Standard number (in the staff interface and OPAC).
  >
  >Note: This change only affects new installations, or when resetting mappings. To update existing installations, either manually make the change and reindex, or reset the mappings and reindex. It may also require updating your bibliographic frameworks.

### Staff interface

#### Enhancements

- [38662](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38662) Additional fields admin page hard to read
  >This enhancement to the Administration > Additional parameters > Additional fields page makes it easier to read. The tables are now grouped and listed alphabetically by module and table name, instead of alphabetically by database table name.
- [38790](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38790) Add HTML classes to item information fields for a record - item page (moredetail.pl)
  >This enhancement adds CSS classes to each field on the record's item page. This makes it easier to customize the page, for example, hiding the "Paid for?" field.
  >
  >Field name: class name
  >----------------------
  >Record information:
  >- Biblionumber: biblionumber
  >- Item type: itemtype
  >- Rental charge: rentalcharge
  >- Daily rental charge: rentlcharge_daily
  >- Hourly rental charge: rentalcharge_hourly
  >- ISBN: isbn
  >- Publication details: publication_details
  >- Volume: volume
  >- Physical details: physical_details
  >- Notes: biblio_note
  >- No. of items: item_count
  >Item information:
  >- Home library: homebranch
  >- Item type: itype
  >- Collection: ccode
  >- Item call number: itemcallnumber
  >- Copy number: copynumber
  >- Shelving location: location
  >- Replacement price: replacementprice
  >- Materials specified: materials
  >Statuses:
  >- Current library: holdingbranch
  >- Current renewals: renewals_count
  >- Lost status: lost
  >- Damaged status: damaged
  >- Withdrawn status: withdrawn
  >Priority:
  >- Exclude from local holds priority: local_holds_priority
  >- Bookable: bookable
  >History:
  >- Order date: order_info
  >- Accession date: dateaccessioned
  >- Invoice number: invoice
  >- Total checkouts: issues
  >- Last seen: datelastseen
  >- Last borrowed: datelastborrowed
  >- Last borrower: previous_borrowers
  >- Paid for?: paidfor
  >- Serial enumeration: enumchron
  >- Public note: itemnotes
  >- Non-public note: itemnotes_nonpublic

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

- [37448](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37448) Add build_sample_ill_request to TestBuilder.pm
  >This enhancement adds the ability to generate sample ILL requests for the test suite.
- [38461](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38461) Table features needs to be covered by e2e tests using Cypress
- [38503](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38503) Add a Cypress task to generate objects based on its swagger def spec
  >This provides utilities for Cypress tests to generate JavaScript objects directly from the API definitions. They contain example data and can then be using to easily mock API responses in tests.
- [39007](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39007) Add last_audit to the sushi_service API spec

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Armenian (hy_ARMN)](https://koha-community.org/manual/24.11//html/) (100%)
- [Chinese (Traditional)](https://koha-community.org/manual/24.11/zh_Hant/html/) (99%)
- [English](https://koha-community.org/manual/24.11//html/) (100%)
- [English (USA)](https://koha-community.org/manual/24.11/en/html/)
- [French](https://koha-community.org/manual/24.11/fr/html/) (71%)
- [German](https://koha-community.org/manual/24.11/de/html/) (99%)
- [Greek](https://koha-community.org/manual/24.11//html/) (96%)
- [Hindi](https://koha-community.org/manual/24.11/hi/html/) (71%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<!-- <div style="column-count: 2;"> -->

- Arabic (ar_ARAB) (95%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified) (86%)
- Chinese (Traditional) (99%)
- Czech (67%)
- Dutch (88%)
- English (100%)
- English (New Zealand) (61%)
- English (USA)
- Finnish (98%)
- French (99%)
- French (Canada) (98%)
- German (99%)
- Greek (67%)
- Hindi (97%)
- Italian (81%)
- Norwegian Bokmål (74%)
- Persian (fa_ARAB) (97%)
- Polish (99%)
- Portuguese (Brazil) (98%)
- Portuguese (Portugal) (87%)
- Russian (94%)
- Slovak (61%)
- Spanish (99%)
- Swedish (86%)
- Telugu (67%)
- Tetum (52%)
- Turkish (83%)
- Ukrainian (73%)
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

The release team for Koha 24.11.04 is


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
new features in Koha 24.11.04
<!-- <div style="column-count: 2;"> -->

- Athens County Public Libraries
- Chetco Community Public Library
- Deutsches Elektronen-Synchrotron DESY, Library
- Gothenburg University Library
- Ignatianum University in Cracow
- [PTFS Europe](https://ptfs-europe.com)
<!-- </div> -->

We thank the following individuals who contributed patches to Koha 24.11.04
<!-- <div style="column-count: 2;"> -->

- Pedro Amorim (28)
- Tomás Cohen Arazi (15)
- Sukhmandeep Benipal (1)
- Matt Blenkinsop (7)
- Nick Clemens (17)
- David Cook (4)
- Jake Deery (1)
- Paul Derscheid (8)
- Roman Dolny (2)
- Jonathan Druart (52)
- Magnus Enger (1)
- Katrin Fischer (9)
- Eric Garcia (1)
- Lucas Gass (16)
- Victor Grousset (2)
- Amit Gupta (1)
- David Gustafsson (4)
- Kyle M Hall (3)
- Andrew Fuerste Henry (4)
- Nicolas Hunstein (1)
- Andreas Jonsson (1)
- Janusz Kaczmarek (2)
- Michał Kula (1)
- Emily Lamancusa (8)
- Brendan Lawlor (2)
- Owen Leonard (15)
- Yanjun Li (1)
- Julian Maurice (2)
- David Nind (3)
- Eric Phetteplace (1)
- Martin Renvoize (13)
- Phil Ringnalda (3)
- Caroline Cyr La Rose (2)
- Lisette Scheer (1)
- Danyon Sewell (1)
- Leo Stoyanov (2)
- Lari Strand (1)
- Lari Taskula (1)
- Imani Thomas (1)
- Alexander Wagner (1)
- Baptiste Wojtkowski (1)
<!-- </div> -->

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 24.11.04
<!-- <div style="column-count: 2;"> -->

- Athens County Public Libraries (15)
- [BibLibre](https://www.biblibre.com) (2)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (10)
- [ByWater Solutions](https://bywatersolutions.com) (45)
- [Cape Libraries Automated Materials Sharing](https://info.clamsnet.org) (2)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha) (1)
- Chetco Community Public Library (3)
- David Nind (3)
- desy.de (1)
- Göteborgs Universitet (4)
- [Hypernova Oy](https://www.hypernova.fi) (1)
- Independant Individuals (5)
- Informatics Publishing Ltd (1)
- jezuici.pl (2)
- Koha Community Developers (54)
- [Koha-Suomi Oy](https://koha-suomi.fi) (1)
- Kreablo AB (1)
- laposte.net (1)
- [Libriotech](https://libriotech.no) (1)
- [LMSCloud](lmscloud.de) (8)
- [Montgomery County Public Libraries](montgomerycountymd.gov) (8)
- openfifth.co.uk (1)
- [Prosentient Systems](https://www.prosentient.com.au) (4)
- [PTFS Europe](https://ptfs-europe.com) (48)
- [Solutions inLibro inc](https://inlibro.com) (3)
- [Theke Solutions](https://theke.io) (15)
<!-- </div> -->

We also especially thank the following individuals who tested patches
for Koha
<!-- <div style="column-count: 2;"> -->

- Pedro Amorim (11)
- Tomás Cohen Arazi (7)
- Matt Blenkinsop (14)
- Fiona Borthwick (1)
- Amanda Campbell (1)
- Nick Clemens (2)
- Rebecca Coert (2)
- David Cook (2)
- Jake Deery (2)
- Ray Delahunty (5)
- Paul Derscheid (235)
- Roman Dolny (4)
- Jonathan Druart (21)
- Magnus Enger (9)
- Laura Escamilla (1)
- Katrin Fischer (217)
- Lucas Gass (3)
- Victor Grousset (30)
- Kyle M Hall (8)
- Andrew Fuerste Henry (2)
- Heather Hernandez (1)
- Bibliothèque Ifao (1)
- JesseM (3)
- Jan Kissig (6)
- Thomas Klausner (2)
- Emily Lamancusa (7)
- William Lavoie (5)
- Brendan Lawlor (8)
- Owen Leonard (13)
- Jesse Maseto (2)
- Gretchen Maxeiner (2)
- David Nind (59)
- Martin Renvoize (71)
- Phil Ringnalda (14)
- Marcel de Rooy (28)
- Lisette Scheer (3)
- Sam Sowanick (4)
- Leo Stoyanov (2)
- Imani Thomas (1)
- Jason Vasche (1)
- John Vinke (4)
- Baptiste Wojtkowski (3)
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

Autogenerated release notes updated last on 24 Apr 2025 16:51:29.
