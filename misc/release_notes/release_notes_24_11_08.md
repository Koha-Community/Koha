# RELEASE NOTES FOR KOHA 24.11.08
26 Aug 2025

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 24.11.08 can be downloaded from:

- [Download](https://download.koha-community.org/koha-24.11.08.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 24.11.08 is a bugfix/maintenance release.

It includes 20 enhancements, 180 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [39906](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39906) Add bot challenge (in Apache layer)
- [40538](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40538) XSS in hold suspend modal in staff interface
  >Fixes XSS vulnerability in suspend hold modal and suspend hold button by refactoring the Javascript that creates the HTML.
- [40579](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40579) CSV formula injection protection

## Bugfixes

### About

#### Critical bugs fixed

- [40370](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40370) about.pl should NOT say "Run the following SQL to fix the database"

#### Other bugs fixed

- [38988](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38988) If JobsNotificationMethod is not STOMP the about page shows as if there was a problem
  >This fixes the messages displayed in About Koha "Server information" and "System information" tabs, depending on whether the RabbitMQ service is running and the options for the JobsNotificationMethod system preference. Previously, an error message was shown in the system information tab when the "Polling" option was selected and RabbitMQ was not running, when it shouldn't have.
  >
  >Expected behavour:
  >- RabbitMQ running: 
  >  . STOMP option: message broker shows as "Using RabbitMQ", no warnings in the system information tab
  >  . Polling option: message broker shows as "Using SQL polling", no warnings in the system information tab
  >- RabbitMQ not running:
  >  . STOMP option: message broker shows as "Using SQL polling (Fallback, Error connecting to RabbitMQ)", error message shown in the system information tab
  >  . Polling option: message broker shows as "Using SQL polling", no warnings in the system information tab
- [40022](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40022) Release team 25.11

### Accessibility

#### Other bugs fixed

- [39209](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39209) Cookie consent banner should be 'focused' on load
- [40165](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40165) Incomplete logic for controlling display of OPAC language footer

  **Sponsored by** *Athens County Public Libraries*

### Acquisitions

#### Critical bugs fixed

- [39754](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39754) Cannot scroll EANs when clicking 'Create EDIFACT order' in a basket
- [39878](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39878) EDIFACT vendor account records sets default port incorrectly for FTP
  >This fixes the default upload and download ports when creating an EDI account (Koha administration > Acquisition parameters > EDI accounts > New account). 
  >
  >If:
  >- FTP is selected, it now defaults to port 21 (instead of port 22).
  >- SFTP is selected, it defaults to port 22.

#### Other bugs fixed

- [39572](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39572) Create EDIFACT order button no longer forces librarians to review EAN to select
  >This fixes the EDIFACT order confirmation message for a basket so that the EAN information is now included on the confirmation page ([a basket for a vendor] > Create EDIFACT order > [select EAN from dropdown list], with the BasketConfirmations system preference set to 'always ask for conformation').
  >
  >Previously, the `Create EDIFACT order` action would take librarians to a page to select the EDI Library EAN. Now, the EANs are included in a dropdown list for the action. This removed the chance to review the selected EAN to confirm it was correct. In addition, some libraries have dozens of Library EANs, making the button dropdown list cumbersome to use.

### Architecture, internals, and plumbing

#### Critical bugs fixed

- [34070](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34070) background_jobs_worker.pl floods logs when it gets error frames

#### Other bugs fixed

- [37305](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37305) Remove C4::Biblio::prepare_marc_host and use Koha::Biblio->generate_marc_host_field in preference

  **Sponsored by** *Open Fifth*
- [38149](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38149) Make ESLint config compatible with version 9 and have ESLint and Prettier installed by default
  >This fixes the Koha ESLint configuration (used for finding JavaScript errors) so that it is compatible with ESLint v9, changes the packages used so that ESLint and prettier are installed by default, and tidies some files that require updating after the prettier upgrade.
- [38167](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38167) ESLint: migrate config to flat format + cleanup some node dependencies
- [38546](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38546) prettierrc should set tabWidth and useTabs
  >This fixes Koha's Prettier code formatter configuration file (.prettierrc.js) to set the default indentation to four spaces.
- [38770](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38770) Remove @vue/cli-service and babel
  >This removes unused dependencies following the move from webpack to Rspack (Bug 37824 - added to Koha 24.11). They were blocking upgrading ESLint and Node.js
- [38966](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38966) Wrong POD in Koha/CoverImages.pm and Koha/Acquisition/Order/Claims.pm
- [38998](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38998) Cannot edit default SMTP server config when not using DB
- [39213](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39213) CGI::param called in list context from cataloguing/moveitem.pl
- [39214](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39214) Mock preferences in t/db_dependent/Koha/Session.t for subtest 'test session driver'
- [39392](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39392) Atomic update README references wrong file extension
- [39567](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39567) Move form-submit js into js includes files
  >This moves form-submit JavaScript from individual template files and adds it to the global JavaScript include files for the staff interface and OPAC.
- [40003](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40003) Warning generated when creating a new bib record
  >This removes an unnecessary warning from the logs when creating a new bibliographic record, and updates the tests.
- [40030](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40030) HTML should be escaped when viewing system preferences diff in Log viewer
- [40079](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40079) C4::Scrubber "note" profile should allow for list (ul, ol, li, dl, dt, and dd) HTML tags
  >This adds unordered, ordered, and description list tags (<ul>, <ol>, <li>, <dl>, <dt>, and <dd>) to the HTML that is allowed in notes fields (for example, course reserves staff and public notes).
- [40087](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40087) Remove unused C4::Scrubber profiles "tag" and "staff"
  >This removes unused "tag" and "staff" scrubber profiles from the code for the scrubber module.
- [40242](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40242) Typo in Quotes module
  >This fixes a typo in the code for the quote of the day tool (there were two =>).
- [40261](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40261) Tidy `build-git-snapshot`
- [40277](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40277) Warn in C4::Koha::GetAuthorisedValues()
  >This fixes the cause of an unnecessary warning message[1] in the logs when searching the OPAC when not logged in. (This warning was occurring when the OpacAdvancedSearchTypes system preference was set to something other than "itemtypes", for example "loc".)
  >
  >[1] Warning message:
  >[WARN] Use of uninitialized value $branch_limit in concatenation (.) or string at ...

### Cataloging

#### Critical bugs fixed

- [39848](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39848) Users without edit_catalogue permission can delete the record if no items remain from the batch item deletion tool

#### Other bugs fixed

- [19113](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19113) Barcode value builder not working with numeric branchcode
  >This fixes the generation of item barcodes, where the autoBarcode system preference is set to "generated in the form <branchcode>yymm0001" and the library code is either a number or alphanumeric value. This automatically generated barcode format didn't work in this case, and the number generated would not automatically increment.
- [25015](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25015) Staff with 'Edit Iitems' permission currently can not edit Items attached to a fast add framework
- [31019](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31019) UNIMARC field help link when cataloging - update default URL
  >This fixes the default UNIMARC field documentation link for the basic MARC editor - the help link now goes to https://www.ifla.org/g/unimarc-rg/unimarc-updates/. IFLA no longer provides field-level documentation pages for the UNIMARC format (as at December 2024), and the previous default links no longer work.
  >
  >It also:
  >- makes minor formatting changes to improve consistency with the
  >  advanced editor:
  >  . the help link text is now [?], instead of ?
  >  . adds hover text for [?] - "Show help for this tag"
  >  . adds some additional spacing before the indicator fields
  >  . removes the '-' before the tag title
  >- updates the MarcFieldDocURL system preference description
- [38895](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38895) In advanced editor, the fixed data helpers put '#' instead of space in record content

  **Sponsored by** *Ignatianum University in Cracow*
- [39293](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39293) Remove box around subfield tag in basic editor

  **Sponsored by** *Chetco Community Public Library*
- [39544](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39544) New / New record generates warnings in log
- [39570](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39570) Add item form includes itemnumber while adding a new item

  **Sponsored by** *Chetco Community Public Library*
- [39871](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39871) Clearing item statuses with batch item modification tool does not work correctly
  >This fixes a bug with the Batch item modification tool. Previously, if library staff tried to clear the items' not-for-loan, withdrawn, lost, or damaged status using the Batch item modification tool, the fields would not be cleared correctly. Depending on the database settings, the job might fail completely and the items wouldn't be modified at all, or else the status would be cleared, but the status date (such as withdrawn_on or itemlost_on) would not be cleared. Now the tool can be used to clear those fields, just like any other non-mandatory field.
- [40128](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40128) StripWhitespaceChars can create empty subfields

### Circulation

#### Critical bugs fixed

- [33284](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33284) checkout_renewals table retains checkout history in violation of patron privacy
  >With the introduction of more fine-grained renewals tracking in "Checkout renewals should be stored in their own table", we inadvertently missed applying patron anonymization preferences.
  >
  >This bug corrects that by adding logic to ensure we follow a patrons preference for removing this data.

#### Other bugs fixed

- [31167](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31167) Only mark due dates in the past red on overdues report
  >This fixes the overdues report (Circulation > Overdues > Overdues) so that when the "Show any items currently checked out" filter is selected, the due date is only shown in red for overdue items. Currently, the due date is in red for all items.

  **Sponsored by** *Athens County Public Libraries*
- [37334](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37334) Cannot filter holdings table by status
  >This restores the ability to filter the holdings table by status. This was lost when the holdings table was upgraded to use the REST API (added to Koha 24.05 by bug 33568).
- [39919](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39919) Overdues with fines report has incorrect title, breadcrumbs, etc.

  **Sponsored by** *Athens County Public Libraries*

### Command-line Utilities

#### Critical bugs fixed

- [31124](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31124) koha-remove fails to remove long_tasks queue daemon, so koha-create for same <instance> user fails
  >This development makes `koha-remove` stop all worker processes before attempting to remove the instance's UNIX user.
- [39694](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39694) `es_indexer_daemon.pl` doesn't use batch_size in DB poll mode

#### Other bugs fixed

- [23883](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23883) sip_cli_emulator.pl - typo in parameter name
- [38760](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38760) koha-mysql doesn't work with encrypted database connection

  **Sponsored by** *Karlsruhe Institute of Technology (KIT)*
- [39250](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39250) Add archive_purchase_suggestions.pl to cron.daily commented
- [39301](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39301) pseudonymize_statistics.pl script generates too many background jobs
- [39961](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39961) koha-create doesn't start all queues
  >This fixes the koha-create and koha-disable package commands so that they start and stop all the background job worker queues (including long_tasks).
- [40144](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40144) `sip_cli_emulator.pl` warnings

### Course reserves

#### Other bugs fixed

- [39078](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39078) Incorrect variable checks in course reserve details template

  **Sponsored by** *Athens County Public Libraries*

### Database

#### Other bugs fixed

- [40109](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40109) Path to fix_invalid_dates.pl is incorrect in fix_invalid_dates.pl and search_for_data_inconsistencies.pl
  >This fixes a path in a hint in the search for data inconsistencies script (search_for_data_inconsistencies.pl) - misc/cronjobs/fix_invalid_dates.pl should be misc/maintenance/fix_invalid_dates.pl.

### ERM

#### Other bugs fixed

- [38794](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38794) AggregatedFullText description should be Aggregated full text
  >This fixes the authorized value description for AggregatedFullText in the ERM_PACKAGE_CONTENT_TYPE category. It updates the description from "Aggregated full" to "Aggregated full text".
- [39346](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39346) Only 20 additional fields can be added to an agreement
  >This fixes adding a new agreement in the ERM module, where there are more than 20 additional fields. All additional fields are now listed, not just the first 20.

### Hold requests

#### Other bugs fixed

- [37650](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37650) Fix warn and remove FIXME in circ/returns.pl
- [39912](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39912) RealTimeHoldsQueue should be rebuilt when a holds pickup location is changed
- [40118](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40118) Regression - 'Holds to pull' library filters don't work
- [40122](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40122) 'Holds to pull' library filters don't work if library name contains parenthesis
  >This fixes the holds to pull page so that the dropdown library filter works if the library name contains parenthesis (Circulation > Holds and bookings > Holds to pull).

### I18N/L10N

#### Other bugs fixed

- [38823](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38823) The word 'Reports' in ERM menu is not translatable
- [38900](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38900) Translation script explodes without a meaningful error when an "incorrect" structure is found
  >This fixes the translation script so that it now provides a more meaningful error when updating a language that has incorrect strings. It now identifies exactly where the problem comes from, making it easier to fix the problem.
  >
  >An example of the updated error message:
  >
  > gulp po:update --lang LANG
  > ..
  > Incorrect structure found at ./koha-tmpl/intranet-tmpl/prog/en/modules/admin/branches.tt:230: '<option value="*" ' at misc/translator/xgettext.pl line 124, <$INPUT> line 65.
  > ..
- [39032](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39032) "Items selected" in item search untranslatable
  >This fixes a syntax error that prevented the string "Items selected" for the item search from being picked up by the translation tool (the text is shown when items in the item search results are selected).

### ILL

#### Other bugs fixed

- [39050](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39050) Duplicate "type" attributes in ill-batch-modal.inc
- [39446](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39446) OPAC ILL request status_alias is not displayed

### Label/patron card printing

#### Other bugs fixed

- [34157](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34157) Exporting labels as a barcode range can cause a 500 error
  >This fixes the "Error 500..." message generated when printing barcode ranges using the label creator, where the layout type selected is "Bibliographic data precedes barcode" (Cataloging > Tools > Label creator).

### Lists

#### Other bugs fixed

- [33440](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33440) A public list can be transferred to a staff member without list permissions
  >This fixes the transfer of public lists to staff patrons that do not have list permissions - when attempting to transfer the list, and the staff member doesn't have list permissions, an error message is now shown. Previously, the list could be transferred and then be edited by the staff patron without list permissions.

### MARC Authority data support

#### Critical bugs fixed

- [40092](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40092) Clicking save doesn't fill auto-populated fields in authority and biblio editor
  >This fixes a regression between Koha 24.11, and 25.05 and main. When adding a new authority or bibliographic record, clicking save (without filling in any fields) now restores filling in the auto-populated fields such as 000, 003, and 008.

#### Other bugs fixed

- [38987](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38987) Cannot link authorities with other authorities
  >This fixes adding (or editing) authority terms to authority records (for example, 500$a)- choosing a term using the authority finder was not adding the selected term to the authority record (it was staying on authority finder pop up window, and generated a JavaScript error).
- [40119](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40119) Merge should not leave empty 6XX subfield $2 (MARC 21)

  **Sponsored by** *Ignatianum University in Cracow*

### MARC Bibliographic data support

#### Other bugs fixed

- [39012](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39012) Koha fails to import default MARC bibliographic framework

### Notices

#### Other bugs fixed

- [36008](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36008) SendAlerts should use notice_email_address instead of email
- [39089](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39089) Delivery note in patron notice table is confusing when the delivery method is print
  >This patch fixes a problem where a patron's email address is shown in the 'Delivery note' column when the message transport type is print.
- [39596](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39596) Missing labels in OPAC and staff interface when a record  has a void second indicator for MARC 780/785

### OPAC

#### Critical bugs fixed

- [38102](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38102) Checkout history in OPAC displaying more than 50 items
- [38974](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38974) Error when submitting patron update from the OPAC Can't call method "dateofbirthrequired" on an undefined value
  >This fixes updating personal details in the OPAC. A 500 error was shown if the "Patron category (categorycode)" was selected in the PatronSelfModificationBorrowerUnwantedField system preference and the date of birth field was changed or previously empty.
- [39680](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39680) The navigation item "Clear” in search history doesn't delete searches

  **Sponsored by** *Athens County Public Libraries*

#### Other bugs fixed

- [22458](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22458) PatronSelfRegistrationEmailMustBeUnique disallows self modification requests if multiple accounts share an email address
- [38963](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38963) Deletion of bibliographic record can cause search errors in OPAC
  >This fixes searching in the OPAC when the OPACLocalCoverImages system preference is enabled. In some circumstances an error is generated (Can't call method "cover_images" on an undefined value...) when a record is deleted, a search is made, but the search index is not yet updated.
- [39088](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39088) If OPACURLOpenInNewWindow is enabled, URLs without http are broken in OPAC results
- [39124](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39124) In lists dropdown, the option "view all" is always displayed
- [39144](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39144) OPAC virtual card page is missing custom CSS from OPACUserCSS
- [39148](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39148) Lists are incorrectly sorted in UNIMARC (OPAC follow-up)
- [39223](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39223) The OPAC browse search (opac-browse.pl) is broken since 24.11
  >This fixes the OPAC browse search feature (OpacBrowseSearch system preference, Elasticsearch only). Expanding and collapsing the search results to show the details now works, instead of nothing happening.
- [40080](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40080) Course reserves details search appears offscreen
  >This fixes the alignment of the OPAC course reserves search box - it is now on the left above the table, instead of offscreen on the right-hand side.

### Packaging

#### Other bugs fixed

- [40039](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40039) Add production enhancements to build-git-snapshot tool

### Patrons

#### Other bugs fixed

- [34776](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34776) Patron messaging preferences are lost when an error occurs during new account creation
  >This fixes creating a new patron - the messaging preferences are now remembered if there is an error when creating a new patron. Before this, if there was an error when creating a patron (for example, the wrong age for the patron category), the messaging preferences (either the default or changes made) were emptied and needed to be re-added.

  **Sponsored by** *Koha-Suomi Oy*
- [39021](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39021) Badly formatted dropdown on patron account transactions page
  >This fixes the misaligned "Email" item on the "Receipt" action dropdown menu for a patron's accounting transactions page in the staff interface (when UseEmailReceipts is set to "Send"). (This is related to the OPAC and staff interface Bootstrap 5 upgrade in Koha 24.11.)

  **Sponsored by** *Athens County Public Libraries*
- [39038](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39038) CollapseFieldsPatronAddForm - Collapsing "Non-patron guarantor" section also collapses the "Patron guarantor" section
  >This fixes the add patron form when using the CollapseFieldsPatronAddForm system preference to collapse sections of the form. If the "Non-patron guarantor" option was selected it was also collapsing the "Patron guarantor" section.
- [39226](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39226) [WARN] DBIx::Class::Storage::DBI::insert(): Missing value for primary key column 'borrowernumber' on BorrowerModification
- [39467](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39467) Fix patron "View restrictions"  link in messages
  >This patch fixes a problem where the 'View restrictions' buttons was not properly opening the 'Restrictions' tab when clicked.

  **Sponsored by** *Gothenburg University Library*
- [40116](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40116) Extra popup notice when saving a patron with patron guarantor ends in error
  >This patch changes existing guarantors elements in the patron add form to use classes "guarantor_id" and "guarantor_relationship" to prevent an unnecessary pop-up if the form throws an error.

  **Sponsored by** *Koha-Suomi Oy*

### Point of Sale

#### Other bugs fixed

- [39040](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39040) Incorrect row striping in POS transaction sales table

### REST API

#### Critical bugs fixed

- [39932](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39932) Koha::Item->_status should return an array

#### Other bugs fixed

- [35246](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35246) Bad data erorrs should provide better logs for api/v1/biblios
- [39260](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39260) Typo in acquisitions baskets API documentation

### Reports

#### Other bugs fixed

- [39298](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39298) Runtime parameters don't work with report templates on first run
- [39534](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39534) Saved report subgroup filter not hidden correctly

  **Sponsored by** *Athens County Public Libraries*

### SIP2

#### Critical bugs fixed

- [39911](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39911) Fatal errors from SIP server are not logged
  >This restores the logging of fatal SIP errors to both the SIP logs and standard output from the command line.

#### Other bugs fixed

- [29410](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29410) Dates compared arithmetically in MsgType.pm (warns: Argument isn't numeric in numeric ne)
- [32934](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32934) SIP checkouts using "no block" flag have a calculated due rather than the specified due date
- [38658](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38658) SIP not marking patrons expired unless NotifyBorrowerDeparture has a positive value

### Searching - Zebra

#### Other bugs fixed

- [40304](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40304) Zebrasrv config doesn't consider non-AMD64 CPUs

### Self checkout

#### Other bugs fixed

- [40108](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40108) Self-checkout print receipt option not working

  **Sponsored by** *Athens County Public Libraries*

### Serials

#### Other bugs fixed

- [34971](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34971) Closing a subscription should require edit_subscription permission
  >This fixes the serials receiving (receive_serials) permission - staff that only have this permission can now only receive serials, and can no longer (incorrectly) close a subscription. Previously, the "Close" action was incorrectly shown on the subscription details page and this allowed staff to close (but not reopen) a subscription (Serials > Search > [select a serial from the results] > Subscriptions detail page for a serial).
- [38515](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38515) Generate next serial deletes the notes from the expected serial and ignores preference PreserveSerialNotes in the new serial
  >This fixes the generation of the next serial and keeping the issue notes, when PreserveSerialNotes is set to "Do". If a serial with the status "Expected" had notes and the next issue was generated (the "Generate next" button), the serial status changed to "Late" and the notes were not copied over - as expected. However, if PreserveSerialNotes was set to "Do", it wasn't keeping the note for the next issue.
- [38528](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38528) Additional fields are not properly fetched in serial subscription details
- [39997](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39997) List of closed serials: reopening requires the syspref "RoutingSerials"

### Staff interface

#### Critical bugs fixed

- [40002](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40002) Cannot filter patrons by "Browse by last name"
- [40127](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40127) JS error on biblio detail page when there are no items
  >This fixes a JavaScript error on bibliographic record pages in the staff interface, where the record has no items.

#### Other bugs fixed

- [34681](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34681) Last returned by and last/previous borrower doesn't display if patron's cardnumber is empty
  >This fixes a bug where the 'Last borrower' and 'Previous borrower' links did not appear when the borrower lacked a cardnumber. This patch makes it fall back to borrowernumber in those cases.
- [38773](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38773) SMTP server is not showing on the library detail page
  >This fixes the library detail page (Administration > Libraries > [view a library]) so that the SMTP server information is now shown (where it exists). Previously, the SMTP server was showing in the list of libraries, but not on the library's individual detail page.
- [39000](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39000) "Encoding errors" block on detail page hurt the eyes
- [39011](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39011) Unable to search the holdings table (except home/holding libraries and barcode)
  >This fixes and improves searching the holdings table for columns that use an authorized or coded value. You can now use either the codes or the description when searching for item type, current library, home library, and collection columns. For example, searching for BK or Books now works as expected.
- [39022](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39022) Last patron is replaced by current patron on page load
- [39035](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39035) CookieConsentBar message prints on slip when cookies aren’t accepted
  >This patch fixes a bug where CookieConsent information would show up on printed material in the staff interface.
- [39186](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39186) 'Cancel marked holds' button on patron holds tab styling is inconsistent
- [39258](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39258) Remove extra delete button in report preview modal
  >This removes an extra "Delete" button when previewing the SQL for the report from the list of saved reports page. (The duplicate button didn't do anything.)
- [39903](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39903) Catalog details page emits error if librarian cannot moderate comments on the record
- [40166](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40166) Syspref description for ILS-DI:AuthorizedIPs is incorrect
  >This fixes a typo in the ILS-DI:AuthorizedIPs system preference, correcting the example for allowing all IPs

### System Administration

#### Other bugs fixed

- [32949](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32949) Smart-rules prefills junk date on page load
- [37439](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37439) ChildNeedsGuarantor description misleading
  >This updates the description for the ChildNeedsGuarantor system preference as it was misleading, as it not longer just applies to children (historically it did - but now it can be any patron type that can have a guarantor).
  >
  >The updated description:
  >
  >Any patron of a patron type than can have a guarantor [does not require|requires] a guarantor be set when adding the patron.
  >WARNING: Setting this preference to 'requires' will cause errors for any pre-existing patrons that would now require a guarantor and do not have one.
- [38874](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38874) Typo in UpdateItemLocationOnCheckout and UpdateItemLocationOnCheckin example
- [39300](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39300) Quick edit a subfield not selecting the correct tab
- [39827](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39827) Wrong framework in edit framework button
  >This fixes editing bibliographic framework descriptions. In Koha administration > Catalog > MARC bibliographic framework, the Actions > Edit framework option for any framework was always showing the edit form for the default framework description, instead of the actual framework selected.
- [40088](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40088) Do not show edit button for default framework
  >This fixes MARC structure page for the default bibliographic framework. It removes the 'Edit framework' button at the top of the page, as you can't actually edit the default framework description (Koha administration > Catalog > MARC bibliographic framework, for the default framework select Actions > MARC structure.)

### Templates

#### Other bugs fixed

- [38294](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38294) Checkbox/label for search filters incorrectly aligned

  **Sponsored by** *Athens County Public Libraries*
- [38968](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38968) Identity providers "More" controls broken after Bootstrap 5 upgrade
  >This fixes the identity providers add and modify form so that the "More" buttons now correctly expand and show hidden help text. (This is related to the OPAC and staff interface Bootstrap 5 upgrade in Koha 24.11.)

  **Sponsored by** *Athens County Public Libraries*
- [39051](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39051) Cash register statistics form submit button styled incorrectly

  **Sponsored by** *Athens County Public Libraries*
- [39053](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39053) Add page-section div to reports results pages
  >This fixes several report result pages so that they have a "page-section" div - they now have a white background, instead of the light grey background.

  **Sponsored by** *Athens County Public Libraries*
- [39185](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39185) Holds priority drop-down contains extraneous 0's if there are found holds
- [39409](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39409) Duplicate modifybiblio ids in cataloguing toolbar

  **Sponsored by** *Chetco Community Public Library*
- [39441](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39441) Some templates have div.container instead of div.container-fluid
  >This updates a few templates so that div.container is replaced with div.container-fluid. div.container has a fixed maximum width that isn't consistent with the rest of Koha. An example where this caused display issues - the staff interface cart: the action icons were bunched up to the left, instead of being spread evenly across the pop-up window width.

  **Sponsored by** *Athens County Public Libraries*
- [39473](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39473) Drop-down filters on item holdings table should match codes exactly
  >This fixes the dropdown filters for the holdings table in the staff interface. The filters now use an exact match.
  >
  >Example: Items with an item type of BK (Books) and BKA (Other type of book) would both be shown if either was selected in the dropdown list, instead of just the items for the specific item type.
- [39499](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39499) Add some padding to the Save button in the sticky bar in cataloging
  >This fixes a regression in the style of the floating toolbar on
  >the basic MARC editor page - it adds more padding before the 'Save' button in the sticky toolbar and is now aligned correctly with other page elements. Before this, it was aligned to the left without any padding before it.

  **Sponsored by** *Athens County Public Libraries*
- [39954](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39954) Cataloging search results incorrect menu markup

  **Sponsored by** *Athens County Public Libraries*
- [40111](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40111) Fix title sorting on two reports

  **Sponsored by** *Athens County Public Libraries*
- [40244](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40244) Typo in branchoverdues.tt
  >Fixes text in overdues with fines "Overdues at with fines {library}" into "Overdues with fines at {library}"
- [40249](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40249) "Copy settings" should be "Copy permissions"
  >This bug changes the phrase "Copy settings" to read as "Copy permissions".

  **Sponsored by** *Athens County Public Libraries*

### Test Suite

#### Other bugs fixed

- [18772](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18772) t/ImportBatch.t generates warnings
- [39286](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39286) BackgroundJob.t should mock_config
- [39315](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39315) Missing tests for KohaTable search on coded value's description
- [40018](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40018) Remove warning from Koha/Template/Plugin/Koha.t
- [40019](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40019) Koha/Auth/Client.t produces warnings
- [40020](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40020) Koha/AdditionalContents.t produces warnings
- [40021](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40021) Koha/Plugins/Recall_hooks.t produces warnings
- [40043](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40043) Agreements_spec.ts is failing randomly (2)
- [40168](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40168) afterEach not called in KohaTable cypress tests
- [40169](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40169) Cypress tests - mockData should not replace "_id" fields if passed
- [40316](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40316) selenium/regressions.t generates warnings
- [40317](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40317) Auth_with_shibboleth.t generates warnings
- [40344](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40344) KohaTable_spec.ts is failing
- [40347](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40347) Koha/Hold.t generates diag
- [40348](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40348) api/v1/two_factor_auth.t generates warnings
- [40350](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40350) t/db_dependent/Holds.t generates warnings
- [40351](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40351) Koha/SearchEngine/Elasticsearch/Search.t  generates a warning
- [40353](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40353) Koha/Patron.t generates warnings
- [40372](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40372) api/v1/holds.t generates a warning
- [40373](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40373) Reserves.t generates a warning
- [40374](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40374) Koha/Booking.t generates warnings
- [40376](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40376) AuthorisedValues.t generates a warning
- [40377](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40377) HoldsQueue/TransportCostOptimizations.t generates warnings
- [40378](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40378) api/v1/biblios.t generates warnings
- [40380](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40380) Koha/Patrons/Import.t generates warnings
- [40381](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40381) Koha/SearchEngine/Elasticsearch/ExportConfig.t generates warnings
- [40384](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40384) Koha/Plugins/Patron.t generates warnings
- [40385](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40385) Reserves/CancelExpiredReserves.t generates a warning
- [40388](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40388) t/Labels.t generates a warning
- [40389](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40389) t/dummy.t is useless
- [40390](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40390) t/db_dependent/Biblio.t generates warnings
- [40402](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40402) xt/find-license-problems.t is failing
- [40403](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40403) Circulation_holdsqueue.t generates warnings
- [40404](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40404) t/Test/Mock/Logger.t generates warnings
- [40406](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40406) selenium/basic_workflow.t generates warnings
- [40409](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40409) t/db_dependent/Overdues.t generates warnings
- [40410](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40410) Letters.t generates a warning
- [40411](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40411) Koha/SearchEngine/Elasticsearch.t generates warnings
- [40419](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40419) xt/find-license-problems.t isn't catching all instances of 51 Franklin St/Street
- [40429](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40429) Koha/Patron/Modifications.t generates warnings
- [40437](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40437) Koha/Installer.t generates a warning
- [40438](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40438) Koha/Old/Hold.t generates warnings

### Tools

#### Other bugs fixed

- [40332](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40332) Tools menu sidebar category not shown for users with batch_extend_due_dates only

## Enhancements 

### Circulation

#### Enhancements

- [37832](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37832) Rental discount is should be decimal like other similar fields in circulation rules
  >This adds validation to the rental discount field in the circulation rules table.
- [39881](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39881) Add patron card number to the 'On hold for' column on the transfers to receive page
  >This enhancement adds the patron's card number to the transfers to receive page for patrons shown in the 'on hold for' column, for item-level holds (Circulation > Transfers > Transfers to receive).

### Command-line Utilities

#### Enhancements

- [38762](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38762) compare_es_to_db.pl should provide links to the staff interface

### Developer documentation

#### Enhancements

- [39447](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39447) Update mailmap for company name change
  >PTFS Europe is no more, Long live Open Fifth
- [40458](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40458) Discharge.pm is missing pod coverage

### Hold requests

#### Enhancements

- [38939](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38939) Add reservenote to members/holdshistory.pl
  >This enhancement add a 'Hold note' column to the patron's hold history table. It is configurable via administration's Table settings.

### Lists

#### Enhancements

- [39374](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39374) No way to restrict OPAC users from sending lists
  >New system preference "OPACDisableSendList" provides libraries the option to disable the ability to send lists from the OPAC, and hides the "Send list" link on the opac-shelves.pl page.

### MARC Bibliographic data support

#### Enhancements

- [38873](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38873) Update MARC21 default framework to Update 39 (December 2024)

### Notices

#### Enhancements

- [38095](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38095) Custom patron messages should have access to information about the logged-in library they were sent from
  >This enhancement allows branch information to be included in predefined notices templates for the `Patrons (custom message)` module, which defines notices that can be sent to patrons by clicking the "Add Message" button on the patron account. These notices can now use the `branch` tag to access information about the branch the staff member is logged into at the time they send the message. For example: `[% branch.branchname %]` - the logged-in branch's name, `[% branch.branchaddress1 %]` - the logged-in branch's address, etc.

### OPAC

#### Enhancements

- [39411](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39411) Add card number and patron expiration info to OPAC Virtual Card
- [39508](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39508) Add support for ISNI and Wikidatata identifiers to OPACAuthorIdentifiersAndInformation
  >This adds support for ISNI and WIKIDATA ID to 'Author information' tab in the OPAC. The feature is configured using the OPACAuthorIdentifiersAndInformation system preference.

### Patrons

#### Enhancements

- [25947](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25947) Improve locked account message in brief patron info in staff interface

### Plugin architecture

#### Enhancements

- [36433](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36433) Plugin hook elasticsearch_to_document

### Staff interface

#### Enhancements

- [38313](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38313) RESTOAuth2ClientCredentials system preference description is confusing

### System Administration

#### Enhancements

- [39565](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39565) OPACVirtualCard system preferences should not be in Suggestions section
  >This enhancement moves the OPACVirtualCard system preferences (OPACVirtualCard and OPACVirtualCardBarcode) from the OPAC suggestion section to the OPAC features section.

### Test Suite

#### Enhancements

- [38818](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38818) Add diag option to t::lib::Mocks::Logger

  **Sponsored by** *Open Fifth*
- [40407](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40407) Remove legacy "pre-wrap" versions (was Patron/Borrower_Discharge.t generates warnings)

### Z39.50 / SRU / OpenSearch Servers

#### Enhancements

- [39303](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39303) Add audience index to SRU

## New system preferences

- OPACDisableSendList

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [English (USA)](https://koha-community.org/manual/24.11/en/html/)
- [French](https://koha-community.org/manual/24.11/fr/html/) (74%)
- [German](https://koha-community.org/manual/24.11/de/html/) (98%)
- [Greek](https://koha-community.org/manual/24.11/el/html/) (86%)
- [Hindi](https://koha-community.org/manual/24.11/hi/html/) (70%)

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
- Czech (67%)
- Dutch (89%)
- English (100%)
- English (New Zealand) (63%)
- English (USA)
- Finnish (100%)
- French (100%)
- French (Canada) (99%)
- German (100%)
- Greek (67%)
- Hindi (97%)
- Italian (82%)
- Norwegian Bokmål (74%)
- Persian (fa_ARAB) (96%)
- Polish (99%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (87%)
- Russian (94%)
- Slovak (61%)
- Spanish (99%)
- Swedish (87%)
- Telugu (68%)
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

The release team for Koha 24.11.08 is


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
new features in Koha 24.11.08
<div style="column-count: 2;">

- Athens County Public Libraries
- Chetco Community Public Library
- Gothenburg University Library
- Ignatianum University in Cracow
- Karlsruhe Institute of Technology (KIT)
- [Koha-Suomi Oy](https://koha-suomi.fi)
- [Open Fifth](https://openfifth.co.uk)
</div>

We thank the following individuals who contributed patches to Koha 24.11.08
<div style="column-count: 2;">

- Pedro Amorim (5)
- Tomás Cohen Arazi (21)
- Stefan Berndtsson (1)
- Alexander Blanchard (1)
- Nick Clemens (9)
- David Cook (15)
- Jake Deery (2)
- Frédéric Demians (3)
- Paul Derscheid (1)
- Jonathan Druart (75)
- Magnus Enger (1)
- Laura Escamilla (4)
- Katrin Fischer (4)
- Matthias Le Gac (1)
- Lucas Gass (7)
- Victor Grousset (4)
- Kyle M Hall (6)
- Andrew Fuerste Henry (2)
- Nicolas Hunstein (3)
- Mason James (1)
- Andreas Jonsson (1)
- Janusz Kaczmarek (8)
- Lukas Koszyk (1)
- Emily Lamancusa (10)
- William Lavoie (4)
- Owen Leonard (20)
- Julian Maurice (1)
- Matthias Meusburger (1)
- David Nind (2)
- Andrew Nugged (1)
- Eric Phetteplace (1)
- Martin Renvoize (20)
- Phil Ringnalda (3)
- Adolfo Rodríguez (1)
- Marcel de Rooy (13)
- Caroline Cyr La Rose (3)
- Andreas Roussos (1)
- Fridolin Somers (12)
- Lari Strand (1)
- Emmi Takkinen (4)
- Doris Tam (1)
- Petro Vashchuk (2)
- Baptiste Wojtkowski (13)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 24.11.08
<div style="column-count: 2;">

- Athens County Public Libraries (20)
- [BibLibre](https://www.biblibre.com) (27)
- [Bibliotheksservice-Zentrum Baden-Württemberg (BSZ)](https://bsz-bw.de) (7)
- [ByWater Solutions](https://bywatersolutions.com) (28)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha) (1)
- Chetco Community Public Library (3)
- [Dataly Tech](https://dataly.gr) (1)
- David Nind (2)
- Gothenburg University Library (1)
- Independant Individuals (12)
- Karlsruhe Institute of Technology (KIT) (1)
- Koha Community Developers (79)
- [Koha-Suomi Oy](https://koha-suomi.fi) (5)
- KohaAloha (1)
- Kreablo AB (1)
- [Libriotech](https://libriotech.no) (1)
- [LMSCloud](https://www.lmscloud.de) (1)
- [Montgomery County Public Libraries](https://montgomerycountymd.gov) (10)
- [Open Fifth](https://openfifth.co.uk) (28)
- [Prosentient Systems](https://www.prosentient.com.au) (15)
- Rijksmuseum, Netherlands (13)
- [Solutions inLibro inc](https://inlibro.com) (8)
- Tamil (3)
- [Theke Solutions](https://theke.io) (21)
- [Xercode](https://xebook.es) (1)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Aleisha Amohia (3)
- Pedro Amorim (4)
- Tomás Cohen Arazi (8)
- Andrew Auld (1)
- Baptiste (1)
- Matt Blenkinsop (7)
- Emmanuel Bétemps (1)
- Aude Charillon (2)
- Christopher (1)
- Nick Clemens (15)
- David Cook (4)
- Paul Derscheid (141)
- Roman Dolny (18)
- Jonathan Druart (16)
- Magnus Enger (16)
- Katrin Fischer (139)
- David Flater (5)
- Andrew Fuerste-Henry (3)
- Brendan Gallagher (3)
- Lucas Gass (134)
- Victor Grousset (1)
- Allax Guillen (1)
- Bo Gustavsson (1)
- Kyle M Hall (6)
- Andrew Fuerste Henry (1)
- Heather Hernandez (2)
- Cornelius Hertfelder (1)
- Barbara Johnson (1)
- Janusz Kaczmarek (1)
- Jan Kissig (1)
- Thomas Klausner (2)
- Emily Lamancusa (15)
- William Lavoie (1)
- Brendan Lawlor (2)
- Owen Leonard (18)
- Lin Wei Li (1)
- Jesse Maseto (2)
- Julian Maurice (5)
- Esther Melander (1)
- David Nind (98)
- Martin Renvoize (59)
- Phil Ringnalda (7)
- Marcel de Rooy (88)
- Caroline Cyr La Rose (2)
- Mathieu Saby (1)
- Lisette Scheer (5)
- Fridolin Somers (212)
- Tadeusz „tadzik” Sośnierz (1)
- Michelle Spinney (2)
- Emmi Takkinen (1)
- Imani Thomas (1)
- Olivier Vezina (1)
- Shi Yao Wang (2)
- Wainui Witika-Park (2)
- Baptiste Wojtkowski (62)
- Anneli Österman (2)
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

Autogenerated release notes updated last on 26 Aug 2025 15:11:12.
