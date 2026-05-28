# RELEASE NOTES FOR KOHA 25.11.05
28 May 2026

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 25.11.05 can be downloaded from:

- [Download](https://download.koha-community.org/koha-25.11.05.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 25.11.05 is a bugfix/maintenance release.

It includes 37 enhancements, 143 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [38414](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38414) Reports permissions not properly enforced
- [42361](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42361) SQL Injection in reports/catalogue_out.pl via Filter parameter (error-based, triggered when Criteria matches /branchcode/)

## Bugfixes

### Accessibility

#### Other bugs fixed

- [41933](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41933) Course reserves OPAC DataTables search field missing accessible label
- [41934](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41934) Empty table header in course reserves table causes accessibility error
  >This fixes an accessibility issue with the course reserves table in the OPAC (OPAC > Course reserves): "Table header text should not be empty".
  >
  >Previously when responsive table controls were shown for the list of course reserves (a green "+" button is shown when the browser window is narrower and all the columns can't be displayed), there was no title for the column header with the controls.
  >
  >Now, the column header has the text "Expand" when the responsive controls are shown.
- [42142](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42142) The gear icon to toggle panel for login settings needs accessibility updates
- [42143](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42143) The breadcrumbs on Patron pages render an empty link
  >This patch improves accessibility for screen readers by removing a duplicate empty link that was rendered in the breadcrumbs on patron pages.
- [42149](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42149) The main navigation needs an aria-label
- [42236](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42236) OPAC lists table header contains no text
- [42300](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42300) OPAC detail page: authority links have no text
  >This fixes an accessibility issue on OPAC details pages for magnifying glass icon links to authority records: "Links must have discernible text".
  >
  >The magnifying glass icon links now have a title and aria label "View authority record".
- [42448](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42448) Staff Interface News (newsfooter) text does not have sufficient color contrast

  **Sponsored by** *Athens County Public Libraries*

### Acquisitions

#### Critical bugs fixed

- [42010](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42010) Include escaping when using PO numbers in EDI acquisitions

#### Other bugs fixed

- [41783](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41783) Query parameters for suggestions filtering is not encoded
  >This fixes searching for suggestions using the "Bibliographic information" filter on the acquisitions page in the staff interface (Acquisitions > Suggestions).
  >
  >Searching was not working as expected in some situations. For example, searching for a title of an existing suggestion did not return any results.
- [41997](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41997) Default suggester is not passed by the suggestion creation form
- [41999](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41999) Suggestions table in staff interface no longer searches all data following title in Suggestion column
  >This fixes the search filter for the suggestions tables in the staff interface. The search filter now searches all suggestion column data, not just the title.
- [42312](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42312) Must enter all four lines of physical address when editing a vendor

### Architecture, internals, and plumbing

#### Critical bugs fixed

- [42394](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42394) Session_id lost when a job is enqueued

#### Other bugs fixed

- [30261](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30261) opac/tracklinks.pl renders 404 incorrectly
- [41454](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41454) Remove unused dbh calls
- [41521](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41521) WebService::ILS::OverDrive not passing pl_valid
  >Embedding WebService::ILS::OverDrive into Koha to fix several perl validation errors.
  >The author of the module is not reachable on CPAN.
  >This can be reverted once upstream has been fixed.
- [41587](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41587) node audit identified several vulnerable node dependencies
  >Fix node dependency security vulnerabilities by upgrading packages and adding yarn resolutions. The following packages were updated:
  >
  >Direct dependency upgrades:
  >- gulp-exec from ^4.0.0 to ^5.0.0 (fixes lodash.template HIGH vulnerability)
  >- lodash from ^4.17.12 to ^4.17.23 (MODERATE)
  >- minimatch from ^3.0.2 to ^3.1.4 (HIGH)
  >
  >Yarn resolutions added to pin secure versions of transitive dependencies:
  >- form-data ^2.5.4 (CRITICAL)
  >- fast-xml-parser ^4.5.4 (CRITICAL)
  >- braces ^3.0.3 (HIGH)
  >- qs ^6.14.1 (HIGH)
  >- serialize-javascript ^7.0.3 (HIGH)
  >- micromatch ^4.0.8 (MODERATE)
  >- @cypress/request ^3.0.0 (MODERATE)
  >- js-yaml ^4.1.1 (MODERATE)
  >- undici ^6.23.0 (MODERATE)
  >
  >This brings in upstream security fixes for critical, high, and moderate severity vulnerabilities reported by yarn audit. No functional changes are expected in Koha beyond those provided by the updated dependencies.
- [42163](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42163) wrapper-staff-tool-plugin.inc no longer loads the admin menu
  >This fixes the sidebar menus when using plugins. The appropriate sidebar menu is now shown, depending on the type of plugin (such as administration, tools, or reports). Previously, no sidebar menu was appearing in some circumstances.
- [42175](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42175) Running under Mojo is broken in k.t.d
- [42317](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42317) [CVE-2014-1626] Require MARC::File::XML > 1.0.2
  >This updates the CPAN file to reflect the minimum version
  >needed for the MARC::File::XML Perl module. This is important
  >because of the vulnerabilities in version 1.0.1.
  >
  >(Note: This should not cause any issues, as v1.0.5 is available and already used from Debian repositories for installation.)
- [42356](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42356) New yarn build warning: if() syntax is deprecated

  **Sponsored by** *Athens County Public Libraries*
- [42463](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42463) Deleting a SMS provider should use text() rather than html()

### Authentication

#### Other bugs fixed

- [42222](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42222) Use of uninitialized string in string eq in Auth.pm

### Cataloging

#### Other bugs fixed

- [31717](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31717) Value builder unimarc_field_010.pl should also use 214$c
  >This updates the unimarc_field_010.pl value builder for UNIMARC systems. If the value builder finds a publisher from the ISBN entered in 010$a, it now automatically adds the publisher name to the 214$c (only the 214$c is updated if there is also a 210$c, as the 214$c is now the more important field with the bibliographic transition.).
- [41367](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41367) Staff user interface - no sidebar menu when on record sources pages
  >This adds the missing sidebar menu when using Administration > Catalog > Record sources.

  **Sponsored by** *OpenFifth*
- [42072](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42072) Batch item deletion "Delete records" message is confusing
  >This change clarifies the option to delete bibliographic records if no items remain in the Batch Item Deletion cataloguing tool.
- [42176](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42176) Form to create an authorized value is submitted when cancelled

  **Sponsored by** *Lund University Library*
- [42221](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42221) autoBarcode set to incremental EAN-13 barcodes do not increment
- [42262](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42262) MARC 006 tag editor plugin drops blank value in position 17 when editing existing tag
- [42424](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42424) Javascript error prevents saving when an instance of an 'important' or 'required' subfield is deleted

### Circulation

#### Critical bugs fixed

- [39748](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39748) Daylight savings breaks circulation (when DST change eliminates 00:00 to 00:59)
  >This change fixes a timezone-related issue that occurs when checking patron expiry dates in certain timezones (e.g. Africa/Cairo) where the daylight savings time change erases midnight from that day. 
  >
  >While it is a rare problem, it can cause errors accessing patron details and check out pages in the staff interface for those Koha instances affected.

#### Other bugs fixed

- [15792](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15792) Double-clicking the 'renew' button on circulation.pl will double-charge account management fee
  >This fixes patron renewal from the patron check out or details page, so that you can't double-click the "Renew" link, and get double-charged the enrollment fee (where an enrollment fee is this is set for the patron category).
  >
  >It also changes the "Renew" link from a text link to a standard light-grey action button.
- [21941](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21941) Incorrect GROUP BY in circ/reserveratios.pl

  **Sponsored by** *Lund University Library*
- [41343](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41343) Overdue report is too intensive on systems with many overdues
- [41510](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41510) Fallback on bookable itemtype can break if item has no itemtype
  >Catches the unlikely case of there not being an itemtype associated with item or bib for bookings.
- [41788](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41788) Make running the holds queue on click optional
  >This patch adds a system preference 'UseHoldsQueueFilterOptions'. When it is enabled it prevents the direct running of the holds queue by clicking on the 'Holds queue' links. With it enabled it will present the user with filter options before running the holds queue. This is to prevent excessive running of the holds queue which can cause slowdowns on larger systems.
- [41938](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41938) Argument "" isn't numeric in numeric gt (>) ... warnings in circulation.tt

  **Sponsored by** *Ignatianum University in Cracow*
- [41940](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41940) Use of uninitialized value... warnings in circulation.pl

  **Sponsored by** *Ignatianum University in Cracow*

### Command-line Utilities

#### Critical bugs fixed

- [41353](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41353) koha-dump failing on mysqldump PROCESS privileges
  >For those using the MySQL database. Starting from MySQL 5.7.31 and MySQL 8.0.20, mysqldump requires the PROCESS privilege to access tablespace metadata by default. Without this privilege, backup operations fail with permission errors.
  >
  >This fixes this issue by adding the --no-tablespaces flag to the dbflag variable. This prevents mysqldump from attempting to access tablespace metadata, allowing backups to complete successfully without requiring the PROCESS privilege.

#### Other bugs fixed

- [40744](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40744) Don't give noisy warning when PatronSelfRegistration is turned off
  >When PatronSelfRegistration is set to ignore (i.e. do nothing) if --del-exp-selfreg is passed to cleanup_database.pl we were issuing warnings.  This patch removes those.
- [41967](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41967) cleanup_database.pl ignores integer values for --labels and --cards and defaults to 1 day
  >This fixes a bug in the cleanup_database.pl script to delete label batches and patron card batches older than X days. Before this fix, if the --labels  or --cards argument was passed in the cronjob, all batches older than 1 day were deleted, regardless of the value passed in the argument.

### Database

#### Critical bugs fixed

- [39107](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39107) kohastructure.sql doesn't load on new MySQL versions
  >This fixes a database error that occurred when starting up a new Koha instance with MySQL version 8.4 or higher.
- [41460](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41460) On Mysql on upgrade from 25.05 to 25.11 I got the error TEXT column 'value' can't have a default value

#### Other bugs fixed

- [42273](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42273) 'idenfity' typo in `categories` table
  >Fixes the spelling in the database comment for the categorycode field (in the categories table): 'idenfity' to 'identify'.

### Fines and fees

#### Other bugs fixed

- [41386](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41386) Adding 0.00 as value for "Expired hold charge" in circulation rules can lead to exception Koha::Exceptions::Account::AmountNotPositive
  >Using value 0.00 in "Expired hold charge" rule on circulation rules caused Koha to die with exception Koha::Exceptions::Account::AmountNotPositive when expired hold charge was added for patron. This was caused by error in if statement in method Koha::Hold->cancel which allowed value 0.00 to be passed to method add_debit. This method then raised exception since value 0.00 is not positive. This patch fixes the erroneous if statement in method Koha::Hold->cancel.

  **Sponsored by** *Koha-Suomi Oy*

### Hold requests

#### Critical bugs fixed

- [41959](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41959) Holds queue builder doesn't always check all holds when using transport cost matrix

#### Other bugs fixed

- [41267](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41267) It should be possible to prevent some itemtypes from filling other biblio level holds
- [41335](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41335) Toggling the hold options does not always work in opac-reserve
  >When DisplayMultiItemHolds is enabled, item selection for specific     items is done via checkboxes; no item is preselected unless there is only one. Otherwise an item is selected via radio buttons. The first one is preselected.
- [41801](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41801) FixPriority recursive calls for lowestPriority holds can be removed
  >This performance update optimizes the C4::Reserves->FixPriority function. Previously, when adjusting holds on a record with many "lowest priority" requests, Koha would use recursive calls that repeatedly touched every hold on the record. This caused significant slowdowns (lag) when managing large hold queues.
- [41849](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41849) Cancelling filled hold from group does not cancel remaining pending holds from group or indicate that it's a hyperhold
  >This patch adds a new option to the modal displayed when checking in an item that is already waiting for a hold. If the hold is part of a group, the modal will offer the option to cancel all holds in the group rather than just the hold for the item that has been checked in.
  >A new REST API endpoint (POST /patrons/{patron_id}/hold_groups/{hold_group_id}/cancel) has been added to achieve this functionality. The new endpoint will:
  >-Cancel all holds within a specified hold group.
  >-Accept a cancellation reason 
  >-Return a 204 on success
  >-Return a 404 when the hold group cannot found or does not exist.
  >
  >The endpoint requires the 'reserveforothers' permission.
- [41878](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41878) No logs for grouping existing holds or ungrouping a hyperhold
  >With this patch, Koha will record a holds modification in the action logs each time a hold is grouped or ungrouped.
- [41880](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41880) Logs for moved holds don't indicate original bib number/item number
  >If a record-level hold is moved from one record to another (or an item-level hold is moved from one item to another), and no change was made to the hold before it was moved, there was no way to identify the record or item for the original hold (when HoldsLog is enabled).
  >
  >With this change, both the old record (or item) number and new record number (or item) are now shown in the log viewer Info and Diff columns.
  >
  >This is shown in the diff column as O for the old biblionumber (or itemnumber) and N for the new biblionumber (or itemnumber).
  >
  >Example for the Diff column for a record-level hold that was moved:
  >
  >- Before (note "O":"11" and "N":11):
  >  {"D":{"biblionumber":{"O":"11","N":11},"timestamp":{"O":"2026-02-28 02:39:44","N":"2026-02-28 02:42:02"}}}
  >
  >- After (note "N":11 and "O":262):
  >  {"D":{"biblionumber":{"N":11,"O":262},"timestamp":{"O":"2026-02-28 02:54:57","N":"2026-02-28 02:55:18"}}}
  >
  >Example for the Diff column for a record-level hold that was moved:
  >
  >- Before (note that no biblionumbers or itemnumbers are shown):
  >  {"D":{"timestamp":{"N":"2026-02-28 02:51:07","O":"2026-02-28 02:50:00"}}}
  >
  >- After (note that the new and old biblionumbers and itemnumbers are now shown):
  >  {"D":{"biblionumber":{"O":139,"N":255},"itemnumber":{"N":563,"O":296},"timestamp":{"N":"2026-02-28 02:59:33","O":"2026-02-28 02:58:34"}}}
- [42147](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42147) Action logs for hold creation contain less data
  >Prior to version 25.05.05, the action logs for creating a hold used to show the full hold data in the "info" column, but starting in 25.05.05 the "info" column only shows the hold id, and other hold information is not logged when the hold is created. This restores other hold values to the hold creation action logs, so that libraries can easily look up the starting priority and options that were selected when the hold was first placed.
- [42255](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42255) Grouped holds counted inconsistently for circ rules
  >This fixes placing holds when group holds are enabled (DisplayAddHoldGroups system preference), so that a group hold only counts as one hold.
  >
  >Previously, each hold in the hold group was counted as a hold. So if the "Holds allowed (total)" or "Maximum total holds allowed (count)" circulation and fine rules values were exceeded you would not be able to place additional holds and get a message "Too many holds: [patron name] can place of the requested holds for a maximum of XX total holds.".
  >
  >Example: if the total holds allowed is set to 2 and a group hold was placed on two records, this was counted as 2 holds - placing an additional hold would result in the the "Too many holds" message.
- [42343](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42343) JS error holdsQueueTable is undefined when no holds exist

  **Sponsored by** *Koha-Suomi Oy*

### I18N/L10N

#### Other bugs fixed

- [41769](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41769) ", by" in suggestions table in the staff interface is not translated
  >This fixes a translation issue in the purchase suggestions
  >table in the staff interface. When there is a suggestion title and author, a ", by" is added between the title and the author in the suggestion column. The "by" was not being translated when a language other than English was used for the staff interface.
- [42302](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42302) xgettext.pl does not output to STDOUT correctly
- [42341](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42341) "Print label" on staff detail page is not translatable

### ILL

#### Other bugs fixed

- [41247](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41247) ILL batches modal does not reset correctly
  >The "New ILL requests batch" modal was not resetting its state correctly after being closed, causing unexpected behaviour when it was reopened.
  >
  >The modal now resets its internal state fully when closed, so that each new batch creation session starts from a clean initial state regardless of how far through the workflow the previous session progressed.
- [41861](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41861) ILL request cost and price paid don't show if 0
  >This updates how an ILL request cost and price paid are shown - if the amount is $0, then it is now shown. Previously, the fields were not shown if the amount was $0.
  >
  >(Note: 'Cost' is not editable in the user interface, but the backend used may set the value. 'Price paid' is editable through the 'Edit request' action)
- [41944](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41944) Error 500 on non-existent ILL request (op=illview)
  >This fixes error 500 and stack trace messages being shown when attempting to access a non-existent ILL request in the staff interface. Now, if no request is found, the standard 404 page not found error page is shown.
- [42244](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42244) Fix JS TypeError on patrons ILL table

### Installation and upgrade (command-line installer)

#### Critical bugs fixed

- [42301](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42301) updatedatabase fails on mysql when adding a unique key to a text column (introduced by 35380)
- [42318](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42318) Table record_sources is not populated with data on install
  >This adds predefined record source values for new Koha installations (Administration > Catalog > Record sources).
  >
  >The predefined values for record sources are:
  >- batchmod (Batch record modification)
  >- intranet (Staff interface MARC editor)
  >- batchimport (Stage MARC import)
  >- z3950 (Z39.50 import)
  >- bulkmarcimport (Bulk import command line script)
  >- import_lexile (Lexile.com scores from CSV using the command line script)
  >
  >These values were formerly hardcoded for MARC overlay rules (Administration > Catalog > Record overlay rules). Bug 35380 (added in Koha 26.05) removed the hardcoded values, but didn't update the installation scripts.
- [42374](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42374) DB Upgrade from the UI is broken
- [42412](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42412) Upgrade to 25.11.02.004 using MySQL fails with Exception: Incorrect DATE value:  value: '0000-00-00'

### MARC Authority data support

#### Other bugs fixed

- [21453](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21453) blinddetail-biblio-search.pl/.tt use hardcoded subfield values for MARC21
- [41843](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41843) Koha::Authorities->move_to_deleted can die on encoding errors
  >This fixes deleting authority records - you can now successfully delete authority records with encoding errors and invalid MARCXML.
  >
  >Previously, attempting to delete an authority record with encoding errors would result in a 500 error.
- [41859](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41859) Authority search autocomplete results not consistent with search results

  **Sponsored by** *Ignatianum University in Cracow*
- [41962](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41962) Add comment to SearchAuthorities about unused params, update POD accordingly

### MARC Bibliographic data support

#### Other bugs fixed

- [41759](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41759) The display of MARC 21 field 026 data (Fingerprint Identifier) is missing (both in intranet and OPAC)

  **Sponsored by** *Ignatianum University in Cracow*

### Mana-kb

#### Other bugs fixed

- [41373](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41373) Report share with mana not working when language_loop is not true

### OPAC

#### Critical bugs fixed

- [42545](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42545) Koha::Calendar::days_between skips holiday subtraction for end date if time is early

#### Other bugs fixed

- [40481](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40481) The items table on koha/opac-MARCdetail.pl does not honor OPACHiddenItems
  >This fixes the MARC view in the OPAC where an item should be hidden when OPACHiddenItems rules should apply. The item was hidden in the normal view, but not in the MARC view.
- [41665](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41665) Only include Greybox in OPAC if IdRef is enabled
  >This patch wraps the Greybox include in the OPAC with a syspref check on IdRef, so that it's only loaded when it's needed.
- [41690](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41690) Add MARC21 245$b (subtitle) to Cite option
  >This fixes citations generated using the "Cite" option in the OPAC - subtitles are now included in the title where they exist for MARC21 (245$b).
- [41866](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41866) "Use of uninitialized value..." warning in opac-search.pl

  **Sponsored by** *Ignatianum University in Cracow*
- [41870](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41870) Warning "Use of uninitialized value $borrowernumber" in opac-detail.pl

  **Sponsored by** *Ignatianum University in Cracow*
- [41942](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41942) Hiding primary contact method hides lang with PatronSelfModificationBorrowerUnwantedField
- [41953](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41953) OPAC holds don't show which group/hyperhold individual holds belong to
  >This patch adjust the display of current holds in a patron's account in the OPAC to clarify which holds are grouped together. It adds a column showing the hold group number and makes it more clear that the message "part of a hold group" can be clicked to reveal a list of grouped holds.
- [42017](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42017) Fix content type of OPAC news RSS

  **Sponsored by** *Athens County Public Libraries*
- [42020](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42020) (Bug 39482 follow-up) Library info link shown in OPAC without OpacLibraryInfo and library URL
  >This fixes the link to library information (the (i) icon) in the OPAC holdings table, before the current and home library name. The (i) icon now only appears if the OpacLibraryInfo HTML customization is defined.
  >
  >Before this, a link to library information was appearing even if OpacLibraryInfo was not defined.
  >
  >(If there is:
  >- only a URL defined for the library, the current and home library is an active link to the website
  >- an OpacLibraryInfo HTML customization AND a URL defined for the library, an (i) icon is shown and in the pop-up window there is the library information and a button with "Visit website".)
  >
  >(This is related to bug 39482 - Link to edit OpacLibraryInfo from library edit page broken, included in Koha 26.05.00 and 25.11.01.)

  **Sponsored by** *Pontificia Università di San Tommaso d'Aquino (Angelicum)*
- [42570](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42570) OPAC patron summary shows literal holds count instead of group-aware count
  >This fixes the patron summary on the front page of the OPAC to show the correct number of holds when hold groups are enabled (DisplayAddHoldGroups system preference).
  >
  >Grouped holds are now correctly shown as 1 hold, instead of the number of individual holds in hold groups.

### Patrons

#### Critical bugs fixed

- [41045](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41045) Suggestions manage permissions added to patrons who previously had no permissions in that category

#### Other bugs fixed

- [37143](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37143) Patron registration allows for saving required fields with a single space instead of information
  >This changes the OPAC self-registration form validation so that required fields need actual information, and not just spaces.
  >
  >Before this, spaces could be entered into most required fields and the form would successfully submit. Now, when submitting, a warning is generated to fill in all missing fields for required fields with just spaces.
- [41073](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41073) Import users expiry date default does not apply
- [42169](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42169) Unify patron category change popups
- [42474](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42474) Patron categories form label: "Upperage limit" should be "Upper age limit"
  >This fixes the spelling for a patron category form label - it changes "Upperage limit" to "Upper age limit".

### Point of Sale

#### Other bugs fixed

- [41585](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41585) Refunds don't always appear on the register page
  >This patch fixes two issues with cash refunds on the register page:
  >
  >1. Payouts were not appearing in the transactions table after being
  >   created because accountlines were fetched before the refund
  >   operation completed.
  >
  >2. Account credit (AC) refunds were incorrectly creating payout
  >   transactions when no cash should leave the register.

### REST API

#### Critical bugs fixed

- [35380](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35380) PUT /biblios/:biblio_id doesn't apply record overlay rules
  >This fixes API requests that update a bibliographic record (PUT /biblios/:biblio_id) so that they apply the record overlay rules if defined in Administration > Catalog > Record overlay rules > Module = source.
  >
  >The predefined values for record sources are:
  >- batchmod (Batch record modification)
  >- intranet (Staff interface MARC editor)
  >- batchimport (Stage MARC import)
  >- z3950 (Z39.50 import)
  >- bulkmarcimport (Bulk import command line script)
  >- import_lexile (Lexile.com scores from CSV using the command line script) 
  >and can be expanded in Administration > Catalog > Record sources.
- [41614](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41614) additional_contents REST endpoint broke the display location filter
  >This fixes a regression that resulted in an empty list in the "Display location" filter in the sidebar for Tools > Additional tools > HTML customizations. Only All, OPAC, and Staff Interface options were shown in the dropdown list, instead of the full list of display locations.
  >
  >(Regression caused by Bug 39900 - Add public REST endpoint for additional_contents, in Koha 25.11 and 25.05.)

### Reports

#### Other bugs fixed

- [41699](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41699) onsite_checkout not available in Statistics wizards
  >In Reports > Statistics wizards > Circulation there was no  option to extract information about entries with statistics.type = 'onsite_checkout'.

### SIP2

#### Critical bugs fixed

- [42053](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42053) Bug 37893 DBUpdate does not always add the new userflags/permissions
  >This patch adds the 'sip2' user flag to systems on which it does not exist. This flag was introduced in Bug 37893 but due to an error in the upgrade script it was not added to systems without existing SIP configuration.
- [42547](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42547) SIP performance is terrible if sip2_resource_last_modified is missing from memcached

#### Other bugs fixed

- [41985](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41985) Fix wording on SIP2 account form - 'Syspref' to 'System preference'
  >This fixes the section heading on the SIP2 account form to spell system preference in full ('Syspref overrides' to 'System preference overrides').
- [42447](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42447) SIP template fields in the database are too small

### Searching - Elasticsearch

#### Other bugs fixed

- [28884](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28884) ElasticSearch: Question mark in title search returns no results

  **Sponsored by** *Pontificia Università di San Tommaso d'Aquino (Angelicum)*
- [40658](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40658) When sorting by local-number we should use the sort field
- [41758](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41758) Add Fingerprint Identifier data to Elasticsearch index mappings

  **Sponsored by** *Ignatianum University in Cracow*
- [41863](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41863) Facets generated from Authorized values sometimes show empty labels

  **Sponsored by** *Ignatianum University in Cracow*

### Searching - Zebra

#### Other bugs fixed

- [41795](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41795) UNIMARC: a Zebra search for Corporate Body Name authorities will also return Collective Titles
  >Previously, in UNIMARC instances, a search for "Corporate Body
  >Name" authorities (authtypecode 'CO') in the OPAC or in the
  >Staff interface would return "Collective Title" (authtypecode 'CO_UNI_TI') authorities as well. This has now been fixed. NOTE: this was a Zebra-only issue, Elasticsearch is not affected.

### Self checkout

#### Other bugs fixed

- [27826](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27826) Self checkout dies on '?' as a barcode
  >This fixes the self-checkout feature so that barcodes with characters (such as ? or +) work. Previously, attempting to check out an item with such a barcode resulted in an error page.

### Serials

#### Other bugs fixed

- [41846](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41846) Notes field of routing list displays HTML characters
  >This change fixes the routing list note so that new lines converted to <br> don't get escaped by the HTML filter.
- [42277](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42277) JS error when viewing a subscription

### Staff interface

#### Critical bugs fixed

- [42521](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42521) Cannot login from suggestion.pl

#### Other bugs fixed

- [41476](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41476) Plugins table explode if one of the plugin is in error
- [41516](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41516) Terminology: Change cardnumber to card number for system preference descriptions
  >This fixes the system preference descriptions for AutoSwitchPatron, CardnumberLog, and SelfCheckoutByLogin so that they use "card number" instead of "cardnumber" (as per the terminology guidelines).
- [42182](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42182) StaffReportsHome HTML customization does not work when library limited
- [42238](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42238) Navigating directly to a patron's holds tab does not work
- [42309](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42309) JS error when there are no cash registers
  >This fixes a JavaScript error in the browser console when there are no cash registers (Administration > Accounting > Cash registers):
  >
  >Uncaught TypeError: can't access property "DataTable", crtable is undefined
- [42398](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42398) Form validation does not work on additional content news
  >This fixes adding or editing news (Tools > Additional tools > News) so that a default title and content is required for a news item.

### System Administration

#### Other bugs fixed

- [28297](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28297) Can't save system preference and field not marked as modified when changing value
  >System preferences with a text input field can now be saved when they are changed back to the original value.
- [42638](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42638) Cannot delete an identity provider domain

  **Sponsored by** *Athens County Public Libraries*

### Templates

#### Other bugs fixed

- [35237](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35237) Duplicate ids in markup of patron card layout edit form
  >Remove duplicate ID's in the markup to return valid html.

  **Sponsored by** *Catalyst*
- [41760](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41760) Fix <tbody> and <tfoot> in several templates

  **Sponsored by** *Athens County Public Libraries*
- [41778](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41778) Broken display of not for loan status on item detail page
  >This patch makes some corrections to the way the item detail page template defines and display an item's not for loan status.

  **Sponsored by** *Athens County Public Libraries*
- [41835](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41835) Add item forms Tag editor buttons on serial edition page are misaligned

  **Sponsored by** *Koha-Suomi Oy*
- [42012](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42012) e.preventDefault not called in clubs.tt club_hold_search handler
- [42103](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42103) Spelling: marc record
  >This fixes the spelling of "marc" (marc to MARC) in two places:
  >- an error message in the database audit (More > About Koha > Database audit)
  >- the description for the marc_modification_templates permission
- [42104](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42104) Spelling: capitalize id (instead of id and Id)
  >This fixes the spelling in several places where "id" or "Id" is used instead of "ID".
- [42106](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42106) Spelling: Failed to load plugin url: {0}
  >Fixes the terminology for URL (url changed to URL) in the file used by Koha for translating TinyMCE editor interface UI text.
- [42131](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42131) Terminology: Return in action logs should be Check-in
  >This changes the text for the "Return" action in the log viewer (when checking in an item) to "Check-in", to help improve translation.
- [42134](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42134) String displays incorrectly: words “notices” and “for” appear concatenated

  **Sponsored by** *Athens County Public Libraries*
- [42140](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42140) Patron information - no space between guarantor name and relationship on patron details page
  >This fixes the display of the guarantor information on a patron's details page for the staff interface - there is now a space between the guarantor's surname and relationship. For example: "Henry Acevedo (father)" instead of "Henry Acevedo(father)".
- [42438](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42438) Remove event attributes from icon selection include file

  **Sponsored by** *Athens County Public Libraries*
- [42439](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42439) Remove event attributes from label-edit-batch.tt

  **Sponsored by** *Athens County Public Libraries*
- [42442](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42442) Remove event attributes from bibliographic record merge template

  **Sponsored by** *Athens County Public Libraries*
- [42445](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42445) Remove event attributes from list creation template

  **Sponsored by** *Athens County Public Libraries*
- [42467](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42467) Remove event attributes from MARC modification templates template

  **Sponsored by** *Athens County Public Libraries*

### Test Suite

#### Critical bugs fixed

- [41216](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41216) Resurrect tt_valid.t

#### Other bugs fixed

- [40962](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40962) t/db_dependent/OAI/Server.t is failing
- [42126](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42126) t/db_dependent/00-strict.t not testing all perl files
- [42359](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42359) t/db_dependent/Reports/Guided.t fails when ReportsLog is enabled
- [42578](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42578) Koha/Hold.t failing on date comparison
- [42581](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42581) xt/api.t shouldn't test routes injected by plugins

### Tools

#### Critical bugs fixed

- [41882](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41882) Batch hold modification tool updates pickup locations to disallowed libraries
  >This fixes a problem with the batch hold modification tool that was allowing for holds to be batch updated to pickup location that are not valid.

#### Other bugs fixed

- [29016](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29016) Log viewer has problems with many entries
- [41883](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41883) Modifications using batch hold modification tool aren't logged
  >This patchsets adds the ability to log information about holds modified via the batch hold modification tool. Modifications are only logged if the HoldsLog system preference is enabled.
- [41884](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41884) Job report for batch item modifications that fail due to PreventWithdrawingItemsStatus has no details on failed items
- [42156](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42156) Staging and matching authorities with bad characters can fail
  >This fixes an error where matching on authorities would fail when encountering a record with invalid characters.
  >
  >Koha will now attempt to clean the record for parsing. If it can't be recovered, the record will be dropped from found matches.

## Enhancements 

### Accessibility

#### Enhancements

- [42165](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42165) OPAC main search should include role="search"

### Architecture, internals, and plumbing

#### Enhancements

- [41440](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41440) Add caching to language_get_description and get_rfc4646_from_iso639

### Cataloging

#### Enhancements

- [33857](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33857) Reduce and resize local cover images
  >Previously, uploading a JPEG cover image to Koha's local cover image store caused the file to be re-encoded as PNG, increasing file sizes by up to 10×. A 170 KB JPEG would be stored as ~930 KB.
  >
  >After this fix, images are stored in their original format. The same image is now stored at ~92 KB — roughly half the original size, with no quality loss.
  >
  >This affects all installations using the LocalCoverImages system preference.
- [40633](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40633) Add keyboard shortcut to advanced cataloging editor for fixed length field plugins
  >This enhancement adds a keyboard shortcut to the advanced cataloging editor to open the value builder plugins for the MARC leader, 006, 007, and 008 fields. This shortcut defaults to Control-Shift-H but can be customized as desired.

  **Sponsored by** *Main Library Alliance*

### Circulation

#### Enhancements

- [37966](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37966) When overriding a hold to renew a book the due date becomes "now" if not specified

### Command-line Utilities

#### Enhancements

- [41062](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41062) Expand cronjob erm_run_harvester.pl with parameter for providers
  >This enhancement adds a new option to define specific providers in the cronjob erm_run_harvester.pl that are used to run the harvesting for COUNTER Reports in the ERM module.
  >Use parameter --provider-id or -p
  >The parameter provider-id is repeatable.
  >If the parameter for provider-id is not used all active providers will be harvested (as before).
  >The script will check if these providers are active (as before).

  **Sponsored by** *Karlsruhe Institute of Technology (KIT)*
- [41851](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41851) Add logging to EDI cron job

### Hold requests

#### Enhancements

- [41957](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41957) Hyperhold/hold group information should show on 'Hold found' modal
  >This enhancement adds a notification to the hold found modal when the hold to be filled is part of a group. The modal will include the message "part of a hold group" and a link to the holds table in the patron's account.

### Lists

#### Enhancements

- [42267](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42267) Update lists pages to use grid layout for forms

  **Sponsored by** *Athens County Public Libraries*

### OPAC

#### Enhancements

- [34025](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34025) Uniform titles (130 / 240 /730) in bibliographic record to link to authority file
- [39027](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39027) News are ordered with oldest on top
- [41955](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41955) OPAC: Patron hold history table should show hyperhold/hold group information

### Patrons

#### Enhancements

- [41954](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41954) Staff interface: Patron hold history table should show hyperhold/hold group information

### Plugin architecture

#### Enhancements

- [40972](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40972) New hook: extend MARC filter

### Point of Sale

#### Enhancements

- [37671](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37671) Can't print receipt for refund from cash register transaction history
  >This enhancements adds a new PAYOUT notice template to be use for receipt printing of refund transactions.
  >
  >We then use that template from both the cash management registers page and the patron account pages.

  **Sponsored by** *OpenFifth*
- [41751](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41751) Cash register transaction history returns 403 for users with only anonymous_refund permission

  **Sponsored by** *OpenFifth*

### REST API

#### Enhancements

- [41733](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41733) Honor EmailPatronRegistrations preference in the API
- [41901](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41901) Allow duplicate check when adding authority via API
- [42206](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42206) Add REST endpoint GET /libraries/{library_id}/closed_dates

  **Sponsored by** *Büchereizentrale Schleswig-Holstein*

### Reports

#### Enhancements

- [39164](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39164) Add max_statement_time to SQL report queries
  >This patchset adds the abilty to set a maximum execution time in seconds for SQL report queries. Reports exceeding this limit will be automatically terminated. This is configured in the koha-conf.xml file by setting the report_sql_max_statement_time_seconds parameter. By default this is turned off.

### SIP2

#### Enhancements

- [41383](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41383) SIP2 server does not search patrons by unique patron attributes (alternate IDs unusable in SIP2)

### Searching - Elasticsearch

#### Enhancements

- [36550](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36550) koha-elasticsearch commit default should be configurable
  >You can now set custom defaults for koha-elasticsearch in /etc/default/koha-common. You can still override the defaults using the command line.
- [40577](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40577) Bulk update Elasticsearch index for bibliographic records after authority change
  >When merging (or updating) authorities, the Elasticsearch indexing of the linked biblios now will happen in one background job per authority instead of one background job per biblio. So an authority that is used in 100 biblios will now trigger one indexing background job with 100 biblio items instead of 100 background jobs with 1 biblio item each.
- [42016](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42016) Add identifier-other search field for authorities (MARC 21)

  **Sponsored by** *Pontificia Università di San Tommaso d'Aquino (Angelicum)*
- [42107](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42107) Add score to staff search results

### Serials

#### Enhancements

- [38009](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38009) Add a generate next button in serials receive page
  >This enhancement adds a "Generate next" button to the receive page for a serial, similar to the one on the serial collection page (Serials > [subscription page] > Receive).

  **Sponsored by** *Pymble Ladies' College*
- [42076](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42076) Add vendor ID column to serial vendor search results

### System Administration

#### Enhancements

- [41980](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41980) SIP codes in the new SIP Config UI could have better descriptions
  >This enhancement improves the descriptions and tooltips for several SIP2 account form fields:
  >- Allow and hide fields: instead of just codes (such as CQ), 
  >  most codes now include a description 
  >  (such as CQ - Valid Patron Password)
  >- Improved tooltips for these fields:
  >  . CR item field
  >  . CT always send
  >  . CV always send 00 on success
  >  . CV triggers alert
  >- Adds tooltips in the template section for the 
  >  AE, AV, and DA field templates

### Templates

#### Enhancements

- [23269](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23269) Long hold queues are slowing the service
  >The patron holds table now uses the REST API to fetch, display and modify hold information, replacing the previous implementation.
  >
  >### What Changed
  >
  >Migrated the patron holds table to use REST API endpoints for data retrieval
  >All existing holds table functionality remains intact with improved performance and maintainability
  >
  >### Impact
  >
  >This change modernizes the holds table architecture by leveraging the REST API, providing:
  >
  >Better separation of concerns between frontend and backend
  >Improved consistency with other API-driven features
  >Foundation for future enhancements to holds management

  **Sponsored by** *Koha-Suomi Oy*
- [39780](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39780) Update library groups form to use grid layout

  **Sponsored by** *Athens County Public Libraries*
- [40113](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40113) Update accounting admin pages to use grid layout for forms

  **Sponsored by** *Athens County Public Libraries*
- [40727](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40727) Minor styling bug in print/email receipt pop-up menu
- [41823](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41823) Update acquisitions admin pages to use grid layout for forms

  **Sponsored by** *Athens County Public Libraries*
- [41827](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41827) Update authority types pages to use grid layout for forms

  **Sponsored by** *Athens County Public Libraries*

### Tools

#### Enhancements

- [8088](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8088) Png-images of covers lost transparency

### Transaction logs

#### Enhancements

- [42030](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42030) Add diff support to SUGGESTION action logs
  >This enhancement adds a 'diff' to the action logs for purchase suggestions (creating, modifying, and deleting).
  >
  >Previously, no diff was recorded (although some information was recorded in the Info column).

### Web services

#### Enhancements

- [37713](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37713) OAI-PMH - Honour OpacSuppression syspref

## New system preferences

- ElasticsearchEscapeCharacters
- OpacElasticsearchEscapeCharacters
- UseHoldsQueueFilterOptions

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [English (USA)](https://koha-community.org/manual/25.11/en/html/)
- [French](https://koha-community.org/manual/25.11/fr/html/) (80%)
- [German](https://koha-community.org/manual/25.11/de/html/) (88%)
- [Greek](https://koha-community.org/manual/25.11/el/html/) (92%)
- [Hindi](https://koha-community.org/manual/25.11/hi/html/) (62%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (89%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified Han script) (81%)
- Chinese (Traditional Han script) (94%)
- Czech (65%)
- Dutch (85%)
- English (100%)
- English (New Zealand) (60%)
- English (USA)
- Finnish (98%)
- French (99%)
- French (Canada) (96%)
- German (100%)
- Greek (64%)
- Hindi (92%)
- Italian (79%)
- Norwegian Bokmål (69%)
- Persian (fa_ARAB) (90%)
- Polish (100%)
- Portuguese (Brazil) (98%)
- Portuguese (Portugal) (88%)
- Russian (90%)
- Slovak (57%)
- Spanish (95%)
- Swedish (88%)
- Telugu (63%)
- Turkish (78%)
- Ukrainian (72%)
- Western Armenian (hyw_ARMN) (59%)
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

The release team for Koha 25.11.05 is


- Release Manager: Lucas Gass

- QA Manager: Martin Renvoize

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

- Documentation Manager: David Nind

- Documentation Team:
  - Philip Orr
  - Aude Charillon
  - Caroline Cyr La Rose

- Translation Manager: Jonathan Druart


- Wiki curators: 
  - George Williams
  - Thomas Dukleth

- Release Maintainers:
  - 25.11 -- Jacob O'Mara
  - 25.05 -- Laura Escamilla
  - 24.11 -- Fridolin Somers
  - 22.11 -- Wainui Witika-Park (Catalyst IT)

- Release Maintainer assistants:
  - 25.11 -- Chloé Zermatten
  - 24.11 -- Baptiste Wojtkowski
  - 22.11 -- Alex Buckley & Aleisha Amohia

## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 25.11.05
<div style="column-count: 2;">

- Athens County Public Libraries
- [Büchereizentrale Schleswig-Holstein](https://www.bz-sh.de)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)
- Ignatianum University in Cracow
- Karlsruhe Institute of Technology (KIT)
- [Koha-Suomi Oy](https://koha-suomi.fi)
- Lund University Library
- [Main Library Alliance](https://www.mainlib.org)
- [OpenFifth](https://openfifth.co.uk)
- Pontificia Università di San Tommaso d'Aquino (Angelicum)
- Pymble Ladies' College
</div>

We thank the following individuals who contributed patches to Koha 25.11.05
<div style="column-count: 2;">

- Saiful Amin (3)
- Pedro Amorim (25)
- apirak (1)
- Tomás Cohen Arazi (5)
- Courtney Brown (1)
- Kevin Carnes (2)
- Lewis Clay (1)
- Nick Clemens (28)
- Casey Conlin (1)
- David Cook (16)
- Jake Deery (1)
- Paul Derscheid (6)
- Roman Dolny (3)
- Jonathan Druart (33)
- elias (1)
- Laura Escamilla (6)
- Andrew Fuerste-Henry (6)
- Lucas Gass (25)
- Ayoub Glizi-Vicioso (3)
- Victor Grousset (1)
- Michael Hafen (3)
- Kyle M Hall (11)
- Harrison Hawkins (1)
- Mark Hofstetter (2)
- Andreas Jonsson (1)
- Kabooshki (1)
- Janusz Kaczmarek (12)
- Jan Kissig (11)
- Thomas Klausner (1)
- Emily Lamancusa (7)
- Brendan Lawlor (3)
- Owen Leonard (25)
- David Nind (5)
- Jacob O'Mara (20)
- Eric Phetteplace (2)
- Martin Renvoize (54)
- Marcel de Rooy (4)
- Caroline Cyr La Rose (1)
- Andreas Roussos (4)
- Johanna Räisä (9)
- Bernard Scaife (2)
- Lisette Scheer (1)
- Robin Sheat (1)
- Maryse Simard (1)
- Simon (1)
- Fridolin Somers (2)
- Tadeusz „tadzik” Sośnierz (2)
- Raphael Straub (1)
- Emmi Takkinen (2)
- Petro Vashchuk (1)
- Hammat Wele (4)
- Wainui Witika-Park (1)
- Baptiste Wojtkowski (2)
- Tom Yates (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 25.11.05
<div style="column-count: 2;">

- Athens County Public Libraries (25)
- [BibLibre](https://www.biblibre.com) (5)
- [ByWater Solutions](https://bywatersolutions.com) (77)
- [Cape Libraries Automated Materials Sharing](https://info.clamsnet.org) (3)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha) (3)
- [Dataly Tech](https://dataly.gr) (4)
- David Nind (5)
- hire-tom.co.uk (1)
- [HKS3](https://koha-support.eu) (2)
- hofstetter.at (2)
- Independant Individuals (31)
- [Jezuici](https://jezuici.pl/) (3)
- kallisti.net.nz (1)
- Karlsruhe Institute of Technology (KIT) (1)
- Koha Community Developers (34)
- [Koha-Suomi Oy](https://koha-suomi.fi) (2)
- Kreablo AB (1)
- live.co.uk (1)
- [LMSCloud](https://www.lmscloud.de) (6)
- Lund University Library (2)
- [Montgomery County Public Libraries](https://montgomerycountymd.gov) (7)
- [OpenFifth](https://openfifth.co.uk) (102)
- [Prosentient Systems](https://www.prosentient.com.au) (16)
- punsarn.asia (1)
- Rijksmuseum, Netherlands (4)
- semanticconsulting.com (3)
- [Solutions inLibro inc](https://inlibro.com) (9)
- [Theke Solutions](https://theke.io) (5)
- Wildau University of Technology (11)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Pedro Amorim (7)
- Tomás Cohen Arazi (5)
- Charlie Arthur (2)
- Andrew Auld (5)
- Brian J. Barr (3)
- Scott Barter (1)
- Bob Bennhoff (15)
- Angela Berrett (1)
- Emmanuel Bétemps (4)
- Nick Clemens (17)
- David Cook (17)
- Paul Derscheid (11)
- Roman Dolny (20)
- Jonathan Druart (39)
- Marion Durand (1)
- Laura Escamilla (10)
- Syed Faheemuddin (1)
- Katrin Fischer (4)
- Andrew Fuerste-Henry (46)
- Brendan Gallagher (1)
- Lucas Gass (228)
- Victor Grousset (15)
- Kyle M Hall (6)
- Juliet Heltibridle (1)
- Mason James (1)
- Graham Jones (1)
- Janusz Kaczmarek (1)
- Jan Kissig (3)
- Thomas Klausner (6)
- Emily Lamancusa (19)
- Brendan Lawlor (11)
- Owen Leonard (16)
- Chris Mathevet (1)
- Julian Maurice (4)
- Jeanne Mauriello (2)
- Gretchen Maxeiner (2)
- Esther Melander (1)
- Mercury (1)
- David Nind (99)
- Noah (1)
- noah (1)
- Sanjar Tulkinov Anvar o'g'li (1)
- Jacob O'Mara (347)
- Lawrence O'Regan-Lloyd (1)
- Eric Phetteplace (2)
- Martin Renvoize (90)
- Phil Ringnalda (4)
- Marcel de Rooy (33)
- Caroline Cyr La Rose (2)
- Johanna Räisä (1)
- Bernard Scaife (3)
- Lisette Scheer (3)
- Fridolin Somers (1)
- Edith Speller (1)
- Justin Swink (1)
- Emmi Takkinen (4)
- Felicie Thiery (1)
- Jackie Usher (2)
- John Vinke (5)
- Alexander Wagner (1)
- Baptiste Wojtkowski (10)
- Laura Woodward (1)
- Jessie Z (1)
- Anneli Österman (2)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 25.11.x-security.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 28 May 2026 19:24:27.
