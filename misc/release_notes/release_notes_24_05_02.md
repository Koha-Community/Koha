# RELEASE NOTES FOR KOHA 24.05.02
25 Jul 2024

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 24.05.02 can be downloaded from:

- [Download](http://download.koha-community.org/koha-24.05.02.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 24.05.02 is a bugfix/maintenance release.

It includes 6 security fixes, 6 enhancements, and  91 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [37018](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37018) SQL injection using q under api/
- [37146](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37146) plugin_launcher.pl allows running of any Perl file on file system
- [37210](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37210) SQL injection in overdue.pl
- [37247](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37247) On subscriptions operation allowed without authentication
- [36863](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36863) CSRF Plack middleware doesn't handle the CONNECT HTTP method
- [37074](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37074) Comment approval and un-approval should be CSRF-protected

## Bugfixes

### About

#### Other bugs fixed

- [37003](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37003) Release team 24.11
  >This updates the About Koha > Koha team with the release team members for Koha 22.11.

### Acquisitions

#### Critical bugs fixed

- [34444](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34444) Statistic 1/2 not saving when updating fund after receipt
- [36995](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36995) Can't delete library EAN
  >This fixes the Library EANs page so that EANs can be deleted. After the CSRF update in 24.05 (bug 34478), the 'Delete' action for an EAN no longer worked as it should.
- [37089](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37089) Cannot delete a fund or a currency
- [37090](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37090) Cannot delete an EDI account
- [37316](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37316) Cannot add items to basket via file if barcodes not supplied
- [37377](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37377) Orders search is not returning any results
  >This fixes the orders search in Acquisitions - clicking the search button was doing nothing and not returning any results. (This is related to the CSRF changes added in Koha 24.05 to improve form security.)

#### Other bugs fixed

- [30493](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30493) Pending archived suggestions appear on staff interface home page
- [34718](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34718) Input field in fund list (Select2) on receive is inactive
- [37071](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37071) Purchase suggestions from the patron account are not redirecting to the suggestion form
  >This fixes the "New purchase suggestion" link from a patron's purchase suggestion area. The link now takes you to the new purchase suggestion form, instead of the suggestions management page. (This is related to the CSRF changes added in Koha 24.05 to improve form security.)

### Architecture, internals, and plumbing

#### Critical bugs fixed

- [37040](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37040) ErrorDocument accidentally setting off CSRF
  >This improves the mechanism for preventing the activation of CSRF middleware by ErrorDocument subrequests. For example, a properly formatted 403 error page is now displayed instead of a plain text error. (This is related to the CSRF changes added in Koha 24.05 to improve form security.)
- [37152](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37152) Delete-confirm should not start with 'cud-'

#### Other bugs fixed

- [35294](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35294) Typo in comment in C4 circulation: barocode
  >This fixes spelling errors in catalog code comments (barocode => barcode, and preproccess => preprocess).
- [36940](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36940) Resolve two Auth warnings when AutoLocation is enabled having a branch without branchip
- [37037](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37037) touch_all_biblios.pl triggers rebuilding holds for all affected records when RealTimeHoldsQueue is enabled

### Cataloging

#### Critical bugs fixed

- [37080](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37080) Cannot delete a MARC bibliographic framework or authority type
  >This fixes the forms so that you can now delete MARC bibliographic frameworks and authority types. (This is related to the CSRF changes added in Koha 24.05 to improve form security.)
- [37127](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37127) Authorized values select not working on authority forms

#### Other bugs fixed

- [25387](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25387) Merging different authority types creates no warning
  >This improves merging authorities of different types so that:
  >
  >1. When selecting the reference record, the authority record number and type are displayed next to each record.
  >2. When merging authority records of different types:
  >   . the authority type is now displayed in the tab heading, and
  >   . a warning is also displayed "Multiple authority types are used. There may be a data loss while merging.".
  >
  >Previously, no warning was given when merging authority records with different types - this could result in undesirable outcomes, data loss, and extra work required to clean up.
- [36891](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36891) Restore returning 404 from svc/bib when the bib number doesn't exist
- [36984](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36984) Transit pending status breaks holdings info
  >This fixes the status shown in the staff interface holdings table for a record when transferring rotation collections. It now correctly shows as "Transit pending...", instead of showing as "Processing" and not displaying the items available.

### Circulation

#### Critical bugs fixed

- [37031](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37031) Club enrollment doesn't complete in staff interface
  >This fixes a typo in the code that causes the enrollment of a patron in a club to fail.
- [37047](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37047) Patron bookings are not visible from patrons checkout page
- [37332](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37332) Renewal due date and renew as unseen fields not respected when renewing an item from the patron account
  >This fixes two issues when renewing items for patrons in the staff interface (Patrons > selected patron > Check out > Checkouts table). The "Renew as unseen" checkbox and the custom renewal due date field were both being ignored. With this patch, the functionality to change the renewal due date and/or process a renewal as an Unseen renewal once again work as intended.
- [37385](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37385) Transfer/next hold modals not triggered automatically when cancelling a hold by checking item in
  >This fixes an issue when checking in an item to cancel a waiting hold - if a transfer to the originating library is required, the pop-up window notifying that a transfer is required was not automatically generated. (This is related to the CSRF changes added in Koha 24.05 to improve form security.)

#### Other bugs fixed

- [36428](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36428) Current bookings are not counted in record side bar
  >This fixes the number of bookings shown for a record (in the sidebar menu for a record) and on a patron's details page (the Bookings tab). It now shows future and active bookings in the count, instead of just future bookings.
- [36459](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36459) Backdating checkouts on circ/circulation.pl not working properly
- [37014](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37014) "Item was not checked in" printed on next POST because of missing supplementary form
- [37345](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37345) Remember for session checkbox on checkout page not sticking
  >This fixes the date in the "Specify due date" field if "Remember for session" is ticked (when checking out items to a patron). The date was not being remembered, and you had to select it again.

### Command-line Utilities

#### Other bugs fixed

- [34077](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34077) writeoff_debts without --confirm doesn't show which accountline records it would have been written off

### Developer documentation

#### Other bugs fixed

- [37198](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37198) POD for GetPreparedLetter doesn't include 'objects'
  >This updates the GetPreparedLetter documentation for developers (it was not updated when changes were made in Bug 19966 - Add ability to pass objects directly to slips and notices).

### ERM

#### Other bugs fixed

- [36895](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36895) Background job links for KBART import are not working
  >This fixes the background job page link after importing a KBART file in the ERM module (E-resource management > eHoldings > Local > Title > Import from KBART file). Previously, it linked to the background jobs page - it now links to the background job page for the import.
- [36956](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36956) ERM eUsage reports: only the first 20 data providers are listed when creating a new report
- [37043](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37043) Counter registry has a new API base URL

### Fines and fees

#### Critical bugs fixed

- [28664](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28664) One should not be able to issue a refund against a VOID accountline
  >This fixes VOID transactions for patron accounting entries so that the 'Issue refund' button is not available.

### I18N/L10N

#### Other bugs fixed

- [32313](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32313) Complete database column descriptions for cataloguing module in guided reports
  >This fixes some column descriptions used in guided reports. It:
  >- Adds missing descriptions for the items and biblioitems tables (used by the Circulation, Catalog, Acquisitions, and Serials modules)
  >- Updates some column descriptions to make them more consistent or clearer.

### ILL

#### Other bugs fixed

- [36894](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36894) Journal article request authors do not show in the ILL requests table
  >This fixes the table for interlibrary loan (ILL) requests so that it now displays authors for journal article requests.

### Installation and upgrade (command-line installer)

#### Critical bugs fixed

- [36424](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36424) Database update 23.06.00.061 breaks due to syntax error
- [37000](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37000) Upgrade fails at 23.12.00.044 [Bug 36120]
  >This fixes a database update error that may occur when upgrading to Koha 24.05.00 or later. This was related to Bug 31620 - Add pickup locations to bookings, an enhancement added in Koha 24.05.
  >
  >Database upgrade error message: 
  >ERROR - {UNKNOWN}: DBI Exception: DBD::mysql::db do failed: Cannot change column 'pickup_library_id': used in a foreign key constraint 'bookings_ibfk_4' at /usr/share/koha/lib/C4/Installer.pm line 741

### Label/patron card printing

#### Critical bugs fixed

- [37187](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37187) Label batches and label templates cannot be deleted
  >This fixes the manage label batches and label templates pages so that they can now be deleted. (This is related to the CSRF changes added in Koha 24.05 to improve form security.)

  **Sponsored by** *Athens County Public Libraries*

### Notices

#### Critical bugs fixed

- [37059](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37059) 'Insert' button is not working in notices and slips tool

#### Other bugs fixed

- [36741](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36741) AUTO_RENEWALS_DGST should skip auto_too_soon
  >This fixes the default AUTO_RENEWALS_DGST notice so that items where it is too soon to renew aren't included in the notice output to patrons when the automatic renewals cron job is run (based on the circulation rules settings). These items were previously included in the notice.
  >
  >NOTE: This notice is only updated for new installations. Existing installations should update this notice if they only want to show the actual items automatically renewed.
- [37036](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37036) Cannot access template toolkit branch variable in auto renewal notices

### OPAC

#### Critical bugs fixed

- [37039](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37039) Cannot request a discharge in the OPAC
  >This fixes the OPAC discharge request so that it now works as expected - after pressing the "Ask for a discharge" button, the page was refreshed but no request was made. (Requires useDischarge system preference enabled; OPAC > Your account > Ask for a discharge.) (This is related to the CSRF changes added in Koha 24.05 to improve form security.)

#### Other bugs fixed

- [29539](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29539) UNIMARC: authority number in $9 displays for thesaurus controlled fields instead of content of $a
  >This fixes the display of authority terms in the OPAC for UNIMARC systems. The authority record number was displaying instead of the term, depending on the order of the $9 and $a subfields (example for a 606 entry: if $a then $9, the authority number was displayed; if $9 then $a, the authority term was displayed).

  **Sponsored by** *National Library of Greece*
- [30372](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30372) Patron self registration: Extended patron attributes are emptied on submit when mandatory field isn't filled in
  >This fixes the patron self registration form when extended patron attributes are used. If a mandatory field wasn't filled in when submitting, the values entered into any extended patron attributes were lost and needed re-entering.
- [35942](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35942) OPAC user can enroll several times to the same club
- [36166](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36166) Disable select to add to list if opacuserlogin is disabled
  >This fixes the OPAC search results header to remove the "Add to list" option when system preference opacuserlogin is set to "Don't allow". Previously, if you clicked on Add to list > New list, you would get a message saying you needed to be logged in - but you can't.
- [36207](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36207) Update browser alerts to modals: OPAC tags
  >This changes the process for removing a tag from a title on a patron's tag list (OPAC > Your account > Tags). It now uses a confirmation dialog box instead of a JavaScript alert. It also makes some minor tweaks to the CSS to correct the style for "Remove tag" links.
- [36983](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36983) B_address_2 field is required even when not set to be required
- [37069](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37069) Authorities pagination on OPAC broken by CSRF
  >This fixes the pagination for authority search results in the OPAC.

### Patrons

#### Other bugs fixed

- [25520](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25520) Change wording on SMS phone number set up
  >This fixes the hint when entering an SMS number on the OPAC messaging settings page - it is now the same as the staff interface patron hint.

### REST API

#### Other bugs fixed

- [37021](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37021) REST API: Holds endpoint handles item_id as string in GET call

### SIP2

#### Other bugs fixed

- [36948](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36948) Adjust SIPconfig for log_file and IP version
- [37016](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37016) SIP2 renew shows old/wrong date due
  >Set correct due date in SIP2 renewal response message.

### Searching

#### Critical bugs fixed

- [35989](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35989) Searching Geographic authorities generates error

#### Other bugs fixed

- [33563](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33563) Document Elasticsearch secure mode
  >When using authentication with Elasticsearch/Opensearch, you must use HTTPS. This change adds some comments in koha-conf.xml to show how to do configure Koha to use authentication and HTTPS for ES/OS.

### Searching - Elasticsearch

#### Other bugs fixed

- [36982](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36982) Collections facet does not get alphabetized based on collection descriptions
  >This fixes the display of the 'Collections' facet for search results in the staff interface and OPAC when using Elasticsearch and Open Search. Values for the facet are now sorted alphabetically using the CCODE authorized values' descriptions, instead of the authorized values' codes.

### Self checkout

#### Other bugs fixed

- [35869](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35869) Dismissing an OPAC message from SCO logs the user out
- [36679](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36679) Anonymous patron is not blocked from checkout via self check
  >This fixes the web-based self-checkout system to prevent the AnonymousPatron from checking out items.
- [37026](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37026) Switching tabs in the sco_main page ( Checkouts, Holds, Charges ) creates a JS error
- [37044](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37044) OPAC message from SCO missing library branch
  >This fixes the self checkout "Messages for you" section for a patron so that any OPAC messages added by library staff now include the library name. Previously, "Written on DD/MM/YYYY by " was displayed after the message without including the library name.

### Serials

#### Critical bugs fixed

- [37165](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37165) Can't edit frequencies due to stray cud- in modify op
- [37183](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37183) Serials batch edit changes the expiration date to TODAY
  >This fixes batch editing of serials and the expiration date. Before this patch, if no date was entered in the expiration date field, it was changed to the current date when the batch edit form was saved. This caused the expiration date to change to the current date for all serials in the batch edit.

### Staff interface

#### Critical bugs fixed

- [37005](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37005) Holdings table will not load when noItemTypeImages is set to 'Don't show'
  >This fixes a problem with the holdings table not loading when the noItemTypeImages system preference is set to 'Don't show'.
- [37078](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37078) Damaged status not showing in record detail page
  >This fixes the record details page to correctly show the damaged status for an item in the holdings table status column, instead of showing it as available.

#### Other bugs fixed

- [36930](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36930) Item search gives irrelevant results when using 2+ added filter criteria
- [36966](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36966) Fix links for local cover images for items on staff detail page
  >This fixes the local cover image links for items (staff interface record details holdings table > dropdown link for Edit > Upload image) by removing unnecessary parameters, fixing an invalid link, an uninitialised Template::Toolkit variable. This has no noticeable effect, but is important for avoiding future issues.

### System Administration

#### Critical bugs fixed

- [37091](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37091) Cannot delete a local system preference
  >This fixes the forms for local system preferences - these can now be deleted.

#### Other bugs fixed

- [36527](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36527) Patron category or item type not changing when editing another circulation rule
- [36672](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36672) Circulation rules are performing too many lookups
  >This improves the performance of the circulation and rules page by reducing the number of lookups. This should improve the page loading times (including when editing and saving) when a library has many categories and item types.
- [36880](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36880) Record overlay rules are not validated on add or edit
  >This fixes the record overlay rules page so that a tag is now required when adding and editing a rule.
- [36922](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36922) Correct hint on date patron attributes not being repeatable
  >This updates the hint text for "Is a date" when adding a patron attribute - date fields are now repeatable (an enhancement added to Koha 24.05 by bug 32610).
- [37157](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37157) Error 500 when loading identity provider list
  >This fixes the listing of identity providers (Administration > Additional parameters > Identity providers) when special characters are used in the configuration and mapping fields (such as "scope": "élève"). Previously, using special characters in these fields caused a 500 error when viewing the Administration > Identity providers page.
- [37163](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37163) Fix the redirect after deleting a tag from an authority framework to load the right page

### Templates

#### Other bugs fixed

- [34573](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34573) Inconsistencies in acquisitions modify vendor title tag
  >This fixes page title, breadcrumb, and browser page title inconsistencies when adding and modifying vendor details in acquisitions.
- [34706](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34706) Capitalization: Cas login
  >This fixes a capitalization error. CAS is an abbreviation, and should be CAS on the login form (used when casAuthentication is enabled and configured).
- [35240](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35240) Missing form field ids in rotating collection edit form
  >This adds missing IDs to the rotating collections edit form (Tools > Rotating collections > edit a rotating collection (Actions > Edit)).
- [36338](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36338) Capitalization: Card number or Userid may already exist.
  >This fixes the text for the warning message in the web installer onboarding section when creating the Koha administrator patron - where the card number or username already exists. It now uses "username" instead of "Userid", and updates the surrounding text:
  >. Previous text: The patron has not been created! Card number or Userid may already exist.
  >. Updated text: The patron was not created! The card number or username already exists.
- [36909](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36909) Eliminate duplicate ID in cookie consent markup
  >This fixes HTML validation warnings about duplicate IDs in the cookie consent markup for the OPAC and staff interface.
- [36961](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36961) Typo: itms
  >This fixes a spelling mistake in the opacreadinghistory system preference description - it changes 'itms' to 'items'.
- [37002](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37002) Correct several HTML markup errors
  >This fixes several minor HTML markup validation errors for the bibliographic detail page in the staff interface.
- [37161](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37161) After deleting a tag in a MARC framework, confirmation page is blank
- [37162](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37162) Remove dead confirmation code when deleting tags from authority frameworks

### Test Suite

#### Other bugs fixed

- [34838](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34838) The ILL module and tests generate warnings
- [36937](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36937) api/v1/password_validation.t generates warnings
  >This fixes the cause of a warning for the t/db_dependent/api/v1/password_validation.t tests (warning fixed: Use of uninitialized value $status in numeric eq (==)).
- [36938](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36938) Biblio.t generates warnings
- [36999](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36999) 00-strict.t fails to find koha_perl_deps.pl
  >This fixes the t/db_dependent/00-strict.t. The tests were failing as a file (koha_perl_deps.pl) was moved and is no longer required for these tests.

### Tools

#### Critical bugs fixed

- [37129](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37129) Patron attributes linked to an authorized value don't show a select menu in batch modification
  >This fixes the patron batch modification tool so that patron attributes linked to an authorized value now show the dropdown list of values. (This is related to the CSRF changes added in Koha 24.05 to improve form security.)

#### Other bugs fixed

- [36128](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36128) Use of uninitialized value in string eq at /usr/share/koha/lib/C4/Overdues.pm
  >This fixes the following error message when running the overdues check cronjob on a Koha system without defined overdue rules:
  >
  >/etc/cron.daily/koha-common: Use of uninitialized value in string eq at /usr/share/koha/lib/C4/Overdues.pm line 686.

### Transaction logs

#### Other bugs fixed

- [30715](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30715) Terminology: Logs should use staff interface and not intranet for the interface
  >This fixes the log viewer so that 'Staff interface' is used instead of 'Intranet' for the filtering option and the value displayed in the log entries interface column.
  >
  >Note: This does not fix the underlying value recorded in the action_log table (these are added as 'intranet' to the interface column), or the values shown in CSV exports.
- [37182](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37182) 'datetime' field lost on pseudonymization

## Enhancements 

### Cataloging

#### Enhancements

- [36498](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36498) Allow ability to set display order when adding an item group from item editor

### OPAC

#### Enhancements

- [36141](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36141) Add classes to CAS text on OPAC login page
  >This enhancement adds classes to the CAS-related messages on the OPAC login page. This will make it easier for libraries to customize using CSS and JavaScript. The new classes are cas_invalid, cas_title, and cas_url. It also moves the invalid CAS login message to above the CAS login heading (the same as for the Shibboleth login).

### REST API

#### Enhancements

- [36480](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36480) Add GET /libraries/:library_id/desks
  >This enhancement adds an API endpoint for requesting a list of desks for a library. For example: http://127.0.0.1:8080/api/v1/libraries/cpl/desks
- [36481](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36481) Add GET /libraries/:library_id/cash_registers
  >This enhancement adds an API endpoint for requesting a list of cash registers for a library. For example: http://127.0.0.1:8080/api/v1/libraries/cpl/cash_registers

### Staff interface

#### Enhancements

- [30623](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30623) Copy permissions from one user to another
  >This enhancement makes it a lot easier to create staff users with similar or identical permission profiles by allowing it to copy the permission settings from one user to another.

### Templates

#### Enhancements

- [36911](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36911) Reindent circ-menu.inc
  >This updates the circ-menu.inc include file used for the left-hand sidebar menu on circulation pages (when the CircSidebar system preference). It reindents the file so that it has consistent indentation, and adds comments to highlight the markup structure. These changes have no visible effect on the pages.

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Chinese (Traditional)](https://koha-community.org/manual/24.05/zh_Hant/html/) (76%)
- [English](https://koha-community.org/manual/24.05//html/) (100%)
- [English (USA)](https://koha-community.org/manual/24.05/en/html/)
- [French](https://koha-community.org/manual/24.05/fr/html/) (46%)
- [German](https://koha-community.org/manual/24.05/de/html/) (38%)
- [Greek](https://koha-community.org/manual/24.05//html/) (44%)
- [Hindi](https://koha-community.org/manual/24.05/hi/html/) (77%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (98%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Traditional) (89%)
- Czech (69%)
- Dutch (76%)
- English (100%)
- English (New Zealand) (63%)
- English (USA)
- Finnish (99%)
- French (99%)
- French (Canada) (96%)
- German (100%)
- German (Switzerland) (51%)
- Greek (57%)
- Hindi (99%)
- Italian (83%)
- Norwegian Bokmål (76%)
- Persian (fa_ARAB) (94%)
- Polish (98%)
- Portuguese (Brazil) (91%)
- Portuguese (Portugal) (88%)
- Russian (91%)
- Slovak (60%)
- Spanish (99%)
- Swedish (87%)
- Telugu (69%)
- Turkish (80%)
- Ukrainian (72%)
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

The release team for Koha 24.05.02 is


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
new features in Koha 24.05.02
<div style="column-count: 2;">

- Athens County Public Libraries
- National Library of Greece
</div>

We thank the following individuals who contributed patches to Koha 24.05.02
<div style="column-count: 2;">

- Pedro Amorim (9)
- Tomás Cohen Arazi (8)
- Matt Blenkinsop (9)
- Phan Tung Bui (1)
- Nick Clemens (8)
- David Cook (7)
- Chris Cormack (1)
- Jonathan Druart (4)
- Marion Durand (1)
- Katrin Fischer (1)
- Matthias Le Gac (1)
- Eric Garcia (1)
- Lucas Gass (11)
- Victor Grousset (1)
- Kyle M Hall (5)
- Andreas Jonsson (1)
- Janusz Kaczmarek (1)
- Jan Kissig (1)
- Denys Konovalov (1)
- Emily Lamancusa (6)
- Sam Lau (3)
- Laurae (1)
- Brendan Lawlor (3)
- Owen Leonard (11)
- Julian Maurice (3)
- David Nind (8)
- Andrew Nugged (1)
- Martin Renvoize (22)
- Phil Ringnalda (14)
- Adolfo Rodríguez (1)
- Marcel de Rooy (4)
- Fridolin Somers (3)
- Lari Strand (2)
- Emmi Takkinen (1)
- George Veranis (1)
- Hammat Wele (3)
- Baptiste Wojtkowski (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 24.05.02
<div style="column-count: 2;">

- Athens County Public Libraries (11)
- [BibLibre](https://www.biblibre.com) (8)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (1)
- BigBallOfWax (1)
- [ByWater Solutions](https://bywatersolutions.com) (25)
- [Cape Libraries Automated Materials Sharing](https://info.clamsnet.org) (3)
- Chetco Community Public Library (14)
- [Dataly Tech](https://dataly.gr) (1)
- David Nind (8)
- denyskon.de (1)
- Independant Individuals (6)
- Koha Community Developers (5)
- [Koha-Suomi Oy](https://koha-suomi.fi) (3)
- Kreablo AB (1)
- [Montgomery County Public Libraries](montgomerycountymd.gov) (6)
- [Prosentient Systems](https://www.prosentient.com.au) (7)
- [PTFS Europe](https://ptfs-europe.com) (40)
- Rijksmuseum, Netherlands (4)
- [Solutions inLibro inc](https://inlibro.com) (5)
- [Theke Solutions](https://theke.io) (8)
- Wildau University of Technology (1)
- [Xercode](https://xebook.es) (1)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Aleisha Amohia (3)
- Pedro Amorim (5)
- Tomás Cohen Arazi (8)
- Matt Blenkinsop (14)
- Nick Clemens (28)
- Chris Cormack (10)
- Roman Dolny (1)
- Jonathan Druart (17)
- Magnus Enger (1)
- Laura Escamilla (1)
- Katrin Fischer (78)
- Eric Garcia (4)
- Lucas Gass (168)
- Victor Grousset (1)
- Kyle M Hall (3)
- Jan Kissig (1)
- Emily Lamancusa (16)
- Sam Lau (8)
- Brendan Lawlor (2)
- Owen Leonard (7)
- CJ Lynce (1)
- Julian Maurice (3)
- David Nind (41)
- Martin Renvoize (70)
- Phil Ringnalda (1)
- Marcel de Rooy (9)
- Michaela Sieber (1)
- Tadeusz „tadzik” Sośnierz (2)
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

Autogenerated release notes updated last on 25 Jul 2024 17:23:39.
