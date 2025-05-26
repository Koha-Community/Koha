# RELEASE NOTES FOR KOHA 25.05.00
27 May 2025

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 25.05.00 can be downloaded from:

- [Download](https://download.koha-community.org/koha-25.05-latest.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 25.05.00 is a major release, that comes with many new features.

It includes 5 new features, 186 enhancements, 481 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).

## New features & Enhancements

### About

#### Enhancements

- [36039](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36039) The output of audit_database.pl should be accessible through the UI
  >This enhancement makes the misc/maintenance/audit_database.pl script (added in Koha 23.11) available in the staff interface - About Koha > Database audit tab. The script compares the instance's database against kohastructure.sql and identifies any differences that need fixing. This is useful for identifying database issues that should be addressed before running a maintenance or release update.
- [39154](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39154) About: add a warning for obsoleted sip.log

### Accessibility

#### Enhancements

- [39237](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39237) HTML title in head tag doesn't correspond to page title of the "Your summary" page in OPAC
- [39356](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39356) Accessibility 1.3.1:  There are pages where heading levels are skipped
  >This fixes some accessibility issues on OPAC pages where heading levels are missing or skipped. It adds headings where they are missing, or changes the heading levels in the cases where they were incorrect.

### Acquisitions

#### New features

- [38010](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38010) Migrate vendors to Vue
  >This update improves the vendor management interface by migrating it to Vue.js, enhancing user experience and maintainability. It introduces embedded counts for associated baskets and subscriptions, adds protection logic to the DELETE endpoint to prevent unintended deletions, and relocates system preference values to a configuration endpoint for better accessibility.

#### Enhancements

- [37588](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37588) Add ability to mark a suggestion as 'available' from the suggestions management page
  >This enhancement adds the ability to mark a suggestion as available when it's not linked to an order. The AVAILABLE notice is then sent  to the patron.

  **Sponsored by** *Pymble Ladies' College*
- [38689](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38689) EDIFACT errors should log to a staff accessible location
  >**Summary:**  
  >Previously, EDIFACT import errors were only visible in server logs, making troubleshooting difficult for staff.
  >
  >**Fix:**  
  >Errors are now logged in a location accessible via the staff interface, allowing easier review and follow-up.
  >
  >**Impact:**  
  >Helps acquisitions staff and sysadmins quickly identify and resolve issues with vendor data.
  >

  **Sponsored by** *Open Fifth*
- [39518](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39518) Add the option to define the basket name in a MARC file when adding to a basket
  >**Summary:**  
  >Some vendors include the intended basket name in the MARC file, but Koha previously ignored this information.
  >
  >**Enhancement:**  
  >You can now configure a MARC order account to read a specified field in the MARC file and use its value as the basket name.
  >
  >**Impact:**  
  >Improves automation and vendor integration by reducing the need for manual basket naming during order import.

### Architecture, internals, and plumbing

#### Enhancements

- [18798](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18798) Use Koha.Preference in OPAC reading record

  **Sponsored by** *Catalyst*
- [22415](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22415) Koha::EDI should not use Log::Log4perl directly
  >This enhancement changes the way EDI logging is done - it now uses the improved Koha::Logger, instead of Log::Log4perl.
- [26553](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26553) Remove KohaTable (columns_settings.inc) and use kohaTable (datatables.js)
  >**Summary:**  
  >Koha had two similar implementations for DataTables buttons: `KohaTable` and `kohaTable`, leading to duplication and confusion.
  >
  >**Fix:**  
  >The older `KohaTable` (from `columns_settings.inc`) has been removed. All tables now use the unified `kohaTable` implementation in `datatables.js`.
  >
  >**Impact:**  
  >Simplifies code maintenance and ensures consistent table behavior across the staff interface.
- [36662](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36662) ILL - t/db_dependent/Illrequest should not exist
  >This enhancement moves the ILL test files to the correct folder structure - t/db_dependent/Koha/ILL/.
- [37911](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37911) Prototype vue islands within static pages
- [37930](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37930) Change how we handle authorised values in Vue
- [38255](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38255) Do not use dataTable constructor directly
- [38483](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38483) C4::Heading::preferred_authorities is not used
  >This removes an unused method 'preferred_authorities' (Return a list of authority records for headings that are a preferred form of the heading).

  **Sponsored by** *Ignatianum University in Cracow*
- [38664](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38664) Tidy the whole codebase
  >This is an improvement to the internals of Koha, which will not cause any changes to library workflows. Release notes for developers:
  >
  >Most of the codebase is now tidy.
  >.pm, .pl, .t, .tt, .inc, .vue, and .js files are, and will continue to be, kept tidy!
  >
  >Update your ktd to get:
  >
  >The new images with a pre-commit Git hook, which will be installed at ktd startup.
  >The updated QA script.
  >A Prettier plugin for tidying Template Toolkit files: https://gitlab.com/koha-community/prettier-plugin-template-toolkit
  >For new patches you don’t need to do anything special:
  >
  >The pre-commit hook will automatically tidy files when you commit your changes.
  >The QA script will check that your commits contain tidy versions of the files.
  >
  >There are two new scripts available for developers:
  >misc/devel/tidy.pl - Used to tidy files.
  >misc/devel/auto_rebase.pl - Automatically attempts to rebase your patches.
- [38832](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38832) Dead code in catalogue/search.pl
  >This removes unused code for catalog searching in the staff interface.
- [38838](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38838) optgroup construct needs cleaning in the reports module
  >This enhancement updates what is shown when selecting the columns when creating a new dictionary definition in reports. It now shows "Field description / tablename.fieldname", instead of just the "Field description" - the same as for creating reports. Example, 'Publication date / biblioitems.publicationyear' (previously it just showed 'Publication date').
- [38871](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38871) sub string_list in misc/translator/xgettext.pl never used
- [38930](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38930) Add a permissions store for Vue apps
- [38941](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38941) Convert the acquisitions menu to a Vue island
- [38952](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38952) JS function messenger not used in acq.js
- [38993](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38993) Merge fetch files
  >Technical notes: This change merge the 2 "fetch" directories. No more duplication of code which will make it more robust and maintainable.
- [39096](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39096) Add "tidy all" commits to a git blame ignore file
- [39106](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39106) Improve the auto-rebase script to retrieve patches from bugzilla
- [39191](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39191) Add a `format` param to Koha::Exceptions::ArticleRequest::WrongFormat
- [39772](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39772) Background jobs page lists unknown job types for jobs implemented by plugins
- [39832](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39832) Add $basket->vendor() method

### Cataloging

#### Enhancements

- [26869](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26869) Enable batch record modification to create items on existing bibs
  >This allows to use the MARC modification templates in combination with the batch record modifications to add items to records already in the Koha catalog. In order to add items you have to add a 952 (MARC21) or 995 (UNIMARC) field using the templates.
- [30975](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30975) Use event delegation for framework plugins to avoid using private jQuery method _data
  >**This introduces a breaking change for users that have custom framework plugins:** the first parameter of JavaScript functions is now always an Event object. Before that it was possible to receive a string containing an HTML ID. This ID is available in `event.data.id` (assuming the first parameter is named `event`)
- [35134](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35134) Call number browser's pop-up size should be adjustable
  >With this feature it's possible to re-size the pop-up generated by the call number browser (cn_browser.pl) manually with the chosen size being remembered for the next time the pop-up is opened.
- [37398](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37398) Initialize a datepicker on all date/datetime fields when adding/editing items
  >This enhancement adds the date picker by default to all item date and datetime fields.
- [38142](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38142) UNIMARC: Choose heading to use from the authority record in the bibliographic record by language
  >This allows to choose which heading to copy from an authority record into the bibliographic record using a language code recorded in $7 of the authority heading field. This feature only applies to UNIMARC.

  **Sponsored by** *Écoles nationales supérieure d'architecture (ENSA)*
- [38670](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38670) Display MARC21 773$d in record detail page
  >This adds 773$d - Place, publisher, and date of publication to the bibliographic record detail page in staff interface and OPAC.
- [38943](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38943) Advanced catalog editor's macro modal isn't wide enough
  >This increases the size of the advanced MARC editor's macro modal.

### Circulation

#### Enhancements

- [25711](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25711) Move ExpireReservesMaxPickUpDelayCharge to the circulation rules
  >This adds the option to define the charge for late hold pick-ups in the circulation rules. If no value is defined in the circulation rules, the value set in the ExpireReservesMaxPickUpDelayCharge system preference will be used.
- [37832](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37832) Rental discount is should be decimal like other similar fields in circulation rules
  >This adds validation to the rental discount field in the circulation rules table.
- [38356](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38356) CheckPrevCheckout should also check current loans
  >If `AllowMultipleIssuesOnABiblio` is enabled patrons can checkout multiple items from same record but these check outs were not checked by Koha. This patch changes `CheckPrevCheckout` system preference functionality so that it also checks patrons current check outs and displays new confirmation message "Patron has this title currently checked out:..." so that librarians now have to confirm if item will be check out to patron.

  **Sponsored by** *Koha-Suomi Oy*
- [38732](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38732) Add copy number column to the bundles table on the staff detail page
  >This enhancement adds a column to the bundles table which includes the copynumber information.
- [39141](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39141) Add search box to checkout page
  >When visiting the checkouts page without having selected a patron, the page was empty. Now it shows a patron search box to help in selecting the patron.
- [39624](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39624) Add an "All" patron category option for the "Default open article requests limit" circulation rules
  >This fixes the "Default open article requests limit" for the circulation and fine rules, so that the patron category drop-down list has an "All" option. 
  >
  >Previously, there was no "All" patron category option, and you needed to set rules individually for each patron category. 
  >
  >This requires the `ArticleRequests` system preference enabled.

### Command-line Utilities

#### Enhancements

- [32440](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32440) Allow selective deletion of statistics entries based on type by cleanup_database
  >Cleanup_database can delete all statistics entries more than X days old. If one is using pseudonymization to create pseudonymized_transactions data, then one may wish to use that cleanup_database function to delete statistics entries that have been duplicated in pseudonymized_transactions.
  >However, not all types of transactions in statistics are duplicated in pseudonymized transactions.
  >
  >Pseudonymized_transactions currently only includes checkouts, returns,
  >and renewals.
  >
  >This patch adds two additional parameters to cleanup_database.pl:
  >
  >1. `--statistics-type`
  >
  >Defines the types of statistics to purge. Will purge all types if parameter is omitted. Repeatable.
  >
  >2. `--statistics-type-pseudo`
  >
  >Grabs values from @Koha::Statistic::pseudonymization_types. At the time of implementation these are: renew, issue, return and onsite_checkout
- [36365](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36365) compare_es_to_db.pl should offer a way to reconcile differences
  >This patch adds a new option switch `--fix` (or `-f`) to make the script try to fix the problems it found.
  >
  >It also added a `--help` option.
- [37418](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37418) Expand delete_patron.pl with option to not delete patrons with restrictions
  >This feature adds a new parameter to the cronjob delete_patrons.pl which gives an option to not delete patrons with given restriction types.
  >The parameter `--without_restriction_type` is repeatable.

  **Sponsored by** *Karlsruhe Institute of Technology (KIT)*
- [38307](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38307) Make overdue_notices.pl quiet if there are no libraries with active overdue rules

  **Sponsored by** *Catalyst*
- [38408](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38408) Add parallel exporting of MARC records to Zebra rebuild/reindex
  >Add the parameter --processes to the rebuild_zebra.pl script for parallel processing of the export step when dumping authority or biblio records to file. This will signficantly reduce the time needed for this part of reindexing.
- [38762](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38762) compare_es_to_db.pl should provide links to the staff interface

### Database

#### New features

- [30888](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30888) Add a table for deletedauthorities
  >This adds a new database table deletedauthorities that will keep the data of deleted authority records, similar to deletedbiblio_metadata and other related tables.

#### Enhancements

- [39062](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39062) Increase length of inventory number field in database
  >The length of the inventory (items.stocknumber) field was increased from 32 characters to 80 characters.

### Developer documentation

#### Enhancements

- [39447](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39447) Update mailmap for company name change
  >PTFS Europe is no more, Long live Open Fifth

### ERM

#### Enhancements

- [37273](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37273) Add ID column to Agreements table in the ERM
  >The enhancement adds an ID column to the ERM's agreement table which is configurable through Table settings.

### Fines and fees

#### Enhancements

- [23674](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23674) Allowing notes on all entries in patron Transactions table
  >This enhancement adds the ability to set notes on all actions in the transaction table on the staff interface. Staff can now add notes when applying discounts, paying individual fines, writing off individual fines, issuing a payouts, voiding payments, issuing refunds, and cancelling charges.
- [33473](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33473) Allow to send email receipts for payments/writeoff manually instead of automatically
  >**Summary:**  
  >Email receipts were previously either sent automatically for all transactions or not at all, with no manual option.
  >
  >**Enhancement:**  
  >Staff can now manually email a receipt from the payment line using the new **'Receipt' → 'Email'** option.  
  >The system preference `UseEmailReceipts` has been renamed to `AutomaticEmailReceipts` for clarity.
  >
  >**Impact:**  
  >Provides more flexibility and control over patron communication, and improves clarity in system configuration.
  >

  **Sponsored by** *Open Fifth*
- [37211](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37211) All notes in the patron account transactions table should be editable
  >This enhancement adds the ability to edit notes in the patron transactions table. Staff can now edit notes on lines for discounts, paying individual fines, writing off individual fines, issuing a payouts, voiding payments, issuing refunds, and cancelling charges. There is a new subpermission in updatecharge to 'edit_notes'.
- [38457](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38457) Add additional fields support to debit types
  >**Summary:**  
  >Debit types were previously limited in customization, restricting the ability to store extra metadata.
  >
  >**Enhancement:**  
  >Additional fields can now be configured for debit types, allowing storage of custom financial codes or reporting data.
  >
  >**Impact:**  
  >Improves flexibility for libraries with advanced accounting or reporting requirements.

  **Sponsored by** *Open Fifth*
- [39177](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39177) Add additional fields support to credit types
  >**Summary:**  
  >Credit types lacked support for custom data, limiting financial tracking options.
  >
  >**Enhancement:**  
  >Additional fields can now be added to credit type configurations to store extra metadata such as reporting codes.
  >
  >**Impact:**  
  >Enables better integration with external financial systems or internal reporting needs.

  **Sponsored by** *Open Fifth*

### Hold requests

#### Enhancements

- [17338](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17338) 'Holds awaiting pickup' should keep you on the same tab when cancelling a hold
  >When cancelling hold requests that haven't been picked up, it would jump back to the first tab after saving. Now Koha will display the correct tab after saving.
- [20747](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20747) Allow LocalHoldsPriority to fill by hierarchical groups system rather than individual library
  >This enhancement adds the ability to set the "LocalHoldsPriority" system preference to more options: 
  >-`Give Library` (current behavior when on)
  >-`Give Library and Group` 
  >-`Give Library Group` 
  >-`Don't give` (current behavior when off).
  >The system preference will be updated in existing installations to match with the new options based on current settings.
  >Note: The holds queue needs to be rebuilt after changing the preference to update items that have already been targeted by the queue.
- [35560](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35560) Use the REST API for holds history
  >This enhancement to a patron's hold history section in the staff interface:
  >- Uses the REST API to generate the holds history page.
  >- Separates the holds history into two tables: "Current holds" and "Past holds".
  >- Adds filters for each table, such as Show all, Pending, Waiting, Fulfilled.
- [37427](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37427) Searching for an empty string for clubs in an item's hold tab is not allowed
  >This improves searching for patron clubs on a record's holds page - it now works similar to the patron search tab. You can now click search with no text in the search box, and a list of clubs are displayed. Previously, you had to enter the club ID or partial name to get a result.
- [37860](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37860) Holds awaiting pickup table should include the patron main contact method
  >This adds the main contact method recorded in the user's account to the table of holds awaiting pick-up.

### I18N/L10N

#### Enhancements

- [36833](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36833) Update German translations for new languages added
- [38684](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38684) Improve translatability in cat-toolbar.inc
  >This enhancement improves the translatability of the tool tips for 'Edit > Delete record' on the record details page in the staff interface. It makes it easier to translate the singular and plural forms of items and subscriptions.
- [38727](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38727) Improve the translatability of the patron categories administration page
  >This improves the translatability of the hint text for these fields on the patron categories form (Administration > Patrons and administration > Patron categories):
  >- Block expired patron OPAC actions
  >- Exclude from local holds priority
  >- Checkout charge limit
  >- Guarantees checkout charge limit
  >- Guarantors with guarantees checkout charge limit
- [39061](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39061) Allow translation context in vue files
- [39815](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39815) ODUE notice translatability can be improved

### ILL

#### New features

- [35604](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35604) ILL - Allow for automatic backend selection
  >With this new feature enabled, users no longer need to select a backend when submitting an ILL request. Instead, the Standard form is always displayed, and Koha automatically determines the best backend to use based on availability and priority settings. For staff, a "Confirm request" screen is displayed to verify the suggested backend.
  >Compatible backends must implement the provides_backend_availability_check capability and implement the availability_check_info method.

  **Sponsored by** *NHS England (National Health Service England)* and *Open Fifth*
- [36197](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36197) Allow unauthenticated ILL requests in the OPAC
  >This new feature adds the option for unauthenticated users to place ILL requests through the OPAC without needing to log in.
  >This may be especially helpful if users are redirected to the Koha OPAC ILL request form from an external service, allowing them to access the request form directly without being prompted to log in.

  **Sponsored by** *NHS England (National Health Service England)*
- [38441](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38441) Allow for an ILL history check workflow stage
  >Adds a workflow stage that performs a check on whether an ILL request that is about to be placed has already been placed in the past.
  >
  >This feature is enabled using the new ILLHistoryCheck system preference.

#### Enhancements

- [30200](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30200) Add customizable tabs to interlibrary loan requests list
  >This enhancement adds system preference `ILLRequestsTabs`. The preference can be configured to show tabs that can optionally group multiple statuses together in the ILL requests table. Additionally, multiple statuses can be filtered on when filtering the ill request table.
  >Tab format exampe: 
  >- name: New
  >  status:
  >    - NEW
  >- name: Requested or reverted
  >  status:
  >    - REQ
  >    - REQREV
  >- name: Queued
  >  status:
  >    - QUEUED
  >- name: Empty
  >  status:
  >    - NONEXISTENT
- [38669](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38669) Staff interface: Automatic backend screen should provide option to go back to form
  >This enhancement adds a "Return to form" link on the confirm backend page, so that the request details can be updated (for example, to fix a failure reason in the backend availability check).

  **Sponsored by** *Open Fifth* and *UK Health Security Agency*
- [38685](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38685) ILL pages have incomplete breadcrumbs
- [38819](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38819) ILL - 'Switch provider' should use AutoILLBackendPriority
  >This enhancement changes the 'Switch provider' button on ILL requests to use the `AutoILLBackendPriority` feature when configured. The button will now present the automatic backend screen, query all installed backends for availability and suggest the most appropriate one.
- [39179](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39179) ILL batches should allow editing without having to add new requests

  **Sponsored by** *UK Health Security Agency*
- [39444](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39444) Standard form does not consider PubMed ID
- [39600](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39600) Use the API to render the OPAC ILL requests table
  >This patch modernizes the ILL requests page in the OPAC by making it render using the API.
  >
  >New API endpoints are added for this purpose.
  >
  >This includes adding pagination and search features to the table previously not available.

  **Sponsored by** *Wiko*
- [39697](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39697) ILL OPAC unauthenticated form is not centered

### Lists

#### Enhancements

- [38302](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38302) Inconsistent delete confirmation dialog for "Delete list" buttons
  >This enhancement adds a confirmation step when deleting a list from the "Your lists" and "Public lists" tabs in the staff interface. Previously, you were not asked to confirm the list deletion. This also makes it consistent with deleting a list from its contents page, where you are asked to confirm the list deletion.
- [39238](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39238) Add links toward private lists in bibliographic record detail page in staff interface
  >With this change the users can see links to their own private lists on the bibliographic record detail page in the staff interface.
- [39374](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39374) No way to restrict OPAC users from sending lists
  >New system preference "OPACDisableSendList" provides libraries the option to disable the ability to send lists from the OPAC, and hides the "Send list" link on the opac-shelves.pl page.

### MARC Authority data support

#### Enhancements

- [26684](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26684) Remove 'marc' column from auth_header table
  >Before this patch we stored both the MARC and the MARCXML record of an authority in the database table auth_header. With this patch the data is no longer duplicated and we are only storing the MARCXML record.
- [38494](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38494) Koha should consider authority heading use in cataloging
  >In MARC21 authority records, three bytes (008/14-16) can indicate what the heading can be used for (main/added entry, subject entry, series entry). With the new system preference ConsiderHeadingUse Koha will respect the authority record's intended use and limit the search in authority linker accordingly.

  **Sponsored by** *Ignatianum University in Cracow*

### MARC Bibliographic data support

#### Enhancements

- [38180](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38180) Don't show label if 520 ind1=8 (MARC21)
  >This patch fixes the logic in the MARC21 XSLT files to not show a label on the 520 field if the first indicator is set to 8.
- [38873](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38873) Update MARC21 default framework to Update 39 (December 2024)
- [38891](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38891) MARC21 Addition to relator terms in technical notice 2024-10-17

### Notices

#### Enhancements

- [30300](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30300) Add patron expiration email to patron messaging preferences
  >This adds the option to set the patron account expiration notice in the patron account's messaging preference.
  >
  >If the MembershipExpiryDaysNotice system preference is in use, the patron account expiration notice will be activated automatically on update for all existing patron accounts.
- [30301](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30301) Add an option to specify the patron expiration notices as mandatory by patron category
  >This allows to configure by patron category if a user is allowed to opt-out of the patron account expiration notice. If the noticed is enforced, the patron can only pick between the available message transport options, but not deactivate the notice entirely.
- [32211](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32211) Update sample (PRE)DUE notices to use Template Toolkit syntax
- [32216](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32216) Send MEMBERSHIP_EXPIRY notice as print
  >This enhancement adds print notice functionality to the membership_expiry.pl script, by adding both conditional and and forced modes. 
  >When passing only --confirm, the script will check the patron's record for an email address. 
  >If one is found, an email notice is generated. If one is not, a print notice is used instead. 
  >By adding a -p flag, print notices will be generated, even if an email address is present.
- [36109](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36109) Port default ODUE notice to Template Toolkit syntax
- [36110](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36110) Port default OVERDUES_SLIP to Template Toolkit syntax
  >This enhancement replaces the default OVERDUES_SLIP syntax, converting it from Koha's bespoke syntax to the more standard Template Toolkit syntax.
- [36112](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36112) Port default CHECKOUT_NOTE notice to Template Toolkit syntax
- [36256](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36256) Port default MEMBERSHIP_EXPIRY notice to Template Toolkit syntax
- [37989](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37989) Allow Template Toolkit for PROBLEM_REPORT notice
  >This makes it possible to use Template Toolkit syntax for the PROBLEM_REPORT notice linked to cataloguing concerns feature.
- [38087](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38087) Ship a default print template for the welcome notice
- [38095](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38095) Custom patron messages should have access to information about the logged-in library they were sent from
  >This enhancement allows branch information to be included in predefined notices templates for the `Patrons (custom message)` module, which defines notices that can be sent to patrons by clicking the "Add Message" button on the patron account. These notices can now use the `branch` tag to access information about the branch the staff member is logged into at the time they send the message. For example: `[% branch.branchname %]` - the logged-in branch's name, `[% branch.branchaddress1 %]` - the logged-in branch's address, etc.
- [38758](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38758) Make formatting date and datetime fields in notices a bit shorter/easier
  >This enhancement adds an easier way to format dates in notices, and minimise potential errors - strftime. It can be used for both date and date time fields, and is locale friendly.
  >
  >Examples:
  >- Date field: [% borrower.dateexpiry.strftime('%d-%m-%y') %]
  >- Date and time field: [% borrower.lastseen.strftime("%d-%m-%y %H:%M") %]
  >- Locale: [% borrower.dateexpiry.strftime("%d %B %Y", "nl_NL") %]

### OPAC

#### Enhancements

- [26211](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26211) Patron age verification while doing the self-registration
  >This enhancement adds age verification checking to the self-registration and personal details forms. A message is now shown if the date of birth entered doesn't match with the patron category age range, "Patron's age is incorrect for their category. Please try again.".
- [32051](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32051) Rename 'Library' page link to 'Contact' for single library
  >If there is only one library marked as 'public' in the library configuration page, the navigation item on the OPAC will change from 'Libraries' to 'Contact'.
- [34778](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34778) Add a 'Show password' link to toggle visibility of password when logging into OPAC
  >This enhancement adds a link to the OPAC login form so a user can reveal their password before submitting the form.
- [35808](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35808) Remove obsolete responsive table markup from several pages in the OPAC
  >This enhancement removes obsolete responsive table markup (span.tdlabel) from several OPAC pages, as the tables now use the DataTables responsive features.

  **Sponsored by** *Athens County Public Libraries*
- [37907](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37907) Add column to user summary to show date an item was checked out on

  **Sponsored by** *Athens County Public Libraries*
- [38705](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38705) Add "Publication date (text)" column to table of subscriptions in the OPAC
  >This enhancement adds a new column to the subscription table in the OPAC which displays the information in the serial.publisheddatetext column.
- [39265](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39265) Self registration: Hide library from the form if there is only one library
  >In a single-branch Koha installation it makes no sense to have library selection drop-down in the self-registration form. This patch makes it so it no longer displays in that case.
- [39508](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39508) Add support for ISNI and Wikidatata identifiers to OPACAuthorIdentifiersAndInformation
  >This adds support for ISNI and WIKIDATA ID to 'Author information' tab in the OPAC. The feature is configured using the OPACAuthorIdentifiersAndInformation system preference.

### Patrons

#### Enhancements

- [25947](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25947) Improve locked account message in brief patron info in staff interface
- [26744](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26744) Log changes to extended patron attributes
  >The enhancements allows for the logging of patron attribute types when adding, removing, or updating them in a patron record.

  **Sponsored by** *Gothenburg University Library*
- [32742](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32742) Add sorting options to patron list export
- [33454](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33454) Improve breadcrumbs for patron lists
  >This fixes the breadcrumbs for patron lists (Tools > Patrons and circulation > Patron lists) so that they are now more consistent with other breadcrumbs, and improves their translatability (Tools > Patron lists > Add patrons to 'List name', instead of Tools > Patron lists > List name).
- [35028](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35028) Add OPAC self-registration alert on staff interface main page

  **Sponsored by** *Écoles nationales supérieure d'architecture (ENSA)*
- [35635](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35635) Expand patron attribute type mandatory field to allow different settings for OPAC and staff interface
  >This enhancement expands the patron attribute type "Mandatory" field, allowing for different configurations for the OPAC and the staff interface.
- [38532](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38532) Show both credits and debits on checkouts and details tabs in staff
  >This fixes the patron check out and details pages. They now show both charges and credits, for example:
  >- Charges: Patron has outstanding charges of 10.00.  
  >- Credits: Patron has outstanding credits of 35.00
  >
  >Previously, the pages only listed the charges - which could be misleading.
- [39452](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39452) Log cardnumber changes as distinct action within borrower logs
- [39579](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39579) Add ability to restrict patron date of birth on self registration
  >This new feature adds a new system preference `PatronSelfRegistrationAgeRestriction` to restrict the maximum age of patrons self registering.

  **Sponsored by** *Cheshire Libraries Shared Services*

### Plugin architecture

#### Enhancements

- [36433](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36433) Plugin hook elasticsearch_to_document
- [39405](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39405) Add plugin hook `overwrite_calc_fine` to override fine calculation
  >This new hook allows to overwrite the internal Koha standard calculation of fines. This can be useful if your library needs to implement its own algorithm. For example, if it has a fine policy with graduated fines per overdue letter.

  **Sponsored by** *Karlsruhe Institute of Technology (KIT)*
- [39540](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39540) Add a warning in the circulation rules page if a plugin overrides rules
  >This adds a warning to the circulation rules page when a plugin using the `overwrite_calc_fine` hook is installed and enabled.

  **Sponsored by** *Karlsruhe Institute of Technology (KIT)*
- [39870](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39870) Add plugin hook for making arbitrary data available to notices
  >This development allows plugins to make arbitrary data available to notices.
  >
  >Each plugin has a defined namespace (e.g. 'innreach'). If a plugin implements the `notices_content` method, it will be called. The generated data structure it returns will be available to the notice author as `[% plugin_content.innreach %]`.
  >
  >The hook will be passed the notice generation context, so authors can return different information based on what they need for each letter, for example.

### REST API

#### Enhancements

- [37256](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37256) Add an endpoint to allow setting circulation rule sets

  **Sponsored by** *Glasgow Colleges Library Group*
- [38253](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38253) REST API: Toggle holds lowest priority via REST API

  **Sponsored by** *Koha-Suomi Oy*

### Reports

#### Enhancements

- [32034](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32034) Library branch transfers should be in the action logs
- [36585](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36585) Report 'Patrons with the most checkouts' doesn't have the total when outputting to CSV
  >This improves the 'Patrons with the most checkouts' report to:
  >1. Add the total to the CSV output.
  >2. Change the screen output to only show the patrons name once, instead of for each group by column.
  >3. Add total check out when output to screen.
  >4. Change item type group by from biblioitems.itemtype to items.itype.
  >
  >Note: This does not fix the SQL query so that it can run if the database is in strict mode.
- [37050](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37050) Add select2 to SQL report multi select
  >When writing SQL reports with SQL runtime parameters for selecting multiple items from a list, this is now easier with a Select2-style pull-down that allows for searching and displays choices as a list with 'x' for easy removal of previous selections.

  **Sponsored by** *Cape Libraries Automated Materials Sharing*

### SIP2

#### Enhancements

- [36431](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36431) Checkin does not show difference between WasTransfered and NeedsTransfer

### Searching

#### Enhancements

- [36660](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36660) Make authorities 'see from' searches more specific

  **Sponsored by** *Education Services Australia SCIS*
- [38681](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38681) "Last checkout date" in item search form should provide a date picker
  >This enhancement adds a datepicker to the "Last checkout date" field in Item search making it easier to select before, after, and on dates in the appropriate date format.
- [39147](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39147) Add more missing languages

  **Sponsored by** *Ignatianum University in Cracow*

### Searching - Elasticsearch

#### Enhancements

- [36729](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36729) Add publisher/distributor number (MARC21 028$a) to standard identifier search index
  >This enhancement adds 028$a (MARC21 - Publisher or distributor number) to the standard number (standard-identifier) search index, searchable using the Advanced search > Standard number (in the staff interface and OPAC).
  >
  >Note: This change only affects new installations, or when resetting mappings. To update existing installations, either manually make the change and reindex, or reset the mappings and reindex. It may also require updating your bibliographic frameworks.
- [38694](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38694) Boost exact title matches in Elasticsearch
- [39171](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39171) Rename IS02709 ElasticsearchMARCFormat to base64ISO2709

### Serials

#### Enhancements

- [35152](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35152) Convert RoutingListNote system preference to additional contents
  >This enhancement converts the `RoutingListNote` system preference to an HTML customization, making it possible to have language- and library-specific content.
  >
  >NOTE: This removes the default content that was previously used in the `RoutingListNote` system preference. The `RoutingSerials` system preference was updated to mention the `RoutingListNote` HTML customization option.

  **Sponsored by** *Athens County Public Libraries*
- [37094](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37094) Improve layout of serial claims page

  **Sponsored by** *Athens County Public Libraries*
- [37171](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37171) Add display of subscription issue notes on serials claims page

  **Sponsored by** *Loughborough University*

### Staff interface

#### Enhancements

- [15461](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15461) Add shelving location to holdings table as a separate column
- [28453](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28453) Update pagination subroutine to generate Bootstrap markup
  >This enhancement updates how pagination bars are generated and displayed in the staff interface for these areas, so that they are consistent with the pagination for catalog search results:
  >- Authorities > Authority search results
  >- Cataloging > Cataloging search results
  >- Cataloging > MARC Editor > Tags that uses the unimarc_field_210c value builder
  >- Reports > Saved SQL reports > Report results
  >- Tools > Comments
  >- Lists > List contents
  >
  >The pagination bar markup was removed from the templates for these pages because it wasn't being used:
  >- Administration > Patron attribute types
  >- Administration > Record matching rules
  >- Tools > Tags

  **Sponsored by** *Athens County Public Libraries*
- [35154](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35154) Convert StaffLoginInstructions system preference to additional contents
  >This enhancement moves the StaffLoginInstructions system preference into HTML customizations, making it possible to have language-specific content.
- [36275](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36275) The displayed values for 'client ID' and 'secret' need copy to clipboard buttons when managing API keys in patron accounts
  >This enhancement adds copy buttons to the API keys in patron accounts to make it clear and easy to copy the values correctly. There is now a tooltip to indicate a successful copy.
- [38116](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38116) Patrons search description should be built from DT's search settings
  >This enhancement improves the search description (or criteria) shown above the patrons page search results table. 
  >
  >It now displays the additional search criteria entered in the global search filter and column filters, for example:
  >
  >  Patrons found for: Anywhere: e
  >  Standard starting with 'a'
  >  Library=Franklin
- [38313](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38313) RESTOAuth2ClientCredentials system preference description is confusing
- [38521](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38521) Add classes to reports homepage
  >This enhancement adds CSS classes to each of the main sections on the reports home page:
  >- Reports dictionary: rep_dictionary *
  >- Statistics wizards: rep_wizards
  >- Report plugins: rep_plugins
  >- Top lists: rep_top
  >- Inactive: rep_inactive
  >- Other: rep_other
  >
  >* This change also corrects the heading level for reports dictionary to an H2 (from an H5), to correctly reflect the page structure.
- [38662](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38662) Additional fields admin page hard to read
  >This enhancement to the Administration > Additional parameters > Additional fields page makes it easier to read. The tables are now grouped and listed alphabetically by module and table name, instead of alphabetically by database table name.
- [38663](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38663) Add additional fields to libraries
  >This enhancement lets you add additional fields to libraries (Koha administration > Additional parameters > Additional fields ).
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
- [38994](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38994) Add class attributes to the circulation homepage to ease customization
- [39099](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39099) Use select2 to select library limitations in item types, patron categories, and authorized values
  >This improves the selection of the values for the 'Libraries limitation' field when adding and editing:
  >
  >* item types
  >* patron categories
  >* authorized value categories
  >
  >Instead of selecting multiple values from a drop-down list using the Ctrl key, you can either select or start typing the value, select or press enter, then repeat to select additional values.

  **Sponsored by** *Athens County Public Libraries*

### System Administration

#### Enhancements

- [37311](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37311) Tone down the SMTP servers administration page
  >This enhancement improves the SMTP servers administration page.
  >
  >It reformats the information section at the top of the page with the current default SMTP server detailsand adds an edit link.
  >
  >For the table listing all the SMTP servers:
  >- "Is default" column: if the server is the default, it is highlighted with a green badge and "Default" in bold (the row is no longer in red and italicised, implying action is required to fix something).
  >- "Debug mode" column: if the server is in debug mode, it is highlighted with a yellow badge and "On" in bold.

  **Sponsored by** *Athens County Public Libraries*
- [38851](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38851) Rephrase OpacRenewalBranch and RESTAPIRenewalBranch to specify that they are about renewals
- [38989](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38989) Note hard-coded price checks in MarcFieldsToOrder system preference text
- [39550](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39550) RestrictPatronsWithFailedNotices system preference should not be in patron relationships section
  >This moves the system preference `RestrictPatronsWithFailedNotices' into the right section of the system preferences editor.
- [39565](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39565) OPACVirtualCard system preferences should not be in Suggestions section
  >This enhancement moves the OPACVirtualCard system preferences (OPACVirtualCard and OPACVirtualCardBarcode) from the OPAC suggestion section to the OPAC features section.

### Templates

#### Enhancements

- [7508](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7508) Collapsable items on items tab
  >This enhancement to the staff interface bibliographic record items detail tab:
  >1. Adds a sidebar sub-menu showing barcodes (or item numbers) so that staff can jump directly to an item. (The sub-menu uses a scrollbar if the record has around 15 or more items.)
  >2. Makes each item on the page collapsible, so item details are hidden when clicking the item header.
  >
  >Note: The heading for each item is "Barcode ...". For an item without a barcode, the heading is "Item number ...".
  >
  >Technical changes: 
  >- JavaScript code moved from the authority and MARC editors into the global JavaScript file. This is the code that helps you jump to a specific part of a page.
  >- staff-global.scss modified to improve the readability of the sidebar sub-menu and removes CSS which was specific to the system preferences page. This makes the sub-menus on the item details and system preferences pages consistent with each other.

  **Sponsored by** *Athens County Public Libraries*
- [25318](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25318) Convert authorities_js.inc to JavaScript file with translatable strings

  **Sponsored by** *Athens County Public Libraries*
- [32890](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32890) Add DataTables to curbside pickups
  >This enhancement changes the curbside pickups page in the staff interface so that each table is a DataTable with configurable columns.
  >
  >It also replaces the patron name output for consistency and to display names 'surname, firstname' for correct column sorting.
- [37222](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37222) Standardize markup for sidebar menus
  >This patch standardizes the way side navigation menus are built in the staff client.

  **Sponsored by** *Athens County Public Libraries*
- [37250](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37250) Redesign labels home page to match other module home pages
  >This enhancement changes the label creator home page (Cataloging > Tools > Label creator) so that it shows the links which previously were buried in a dropdown menu.

  **Sponsored by** *Athens County Public Libraries*
- [37826](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37826) Remove the use of the script_name variable where it is unnecessary
  >This enhancement removes the $script_name variable from several pages where it is unnecessary, and updates the corresponding template with the URL itself. (Most of the places where a $script_name variable was used was not strictly necessary. It was also used inconsistently.)

  **Sponsored by** *Athens County Public Libraries*
- [38221](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38221) Add Bootstrap styling to pagination in authority plugin search results
  >This enhancement updates the style of the pagination links in the cataloging authority search popup (for example, 100$a). The style is now consistent with other pages (such as catalog search results), instead of plain links for result page numbers and angle brackets for next, last, first, and previous page links.

  **Sponsored by** *Athens County Public Libraries*
- [38227](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38227) Collapse authority popup search form when showing results

  **Sponsored by** *Athens County Public Libraries*
- [38351](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38351) Improve layout of course reserve details
  >This enhancement improves the layout of course reserves pages.
  >
  >For the list of courses, it changes the "Reserves" heading to "Courses".
  >
  >For the course details page it:
  >- Replaces the "Reserves" heading with the course name, 
  >  matching the breadcrumbs and page title.
  >- Adds separator lines between fields.
  >- Adds colons after labels.
  >- Fixes some alignment issues.
  >- Only displays fields with values.
  >- Now shows "0" for the "Number of students" if no value is added.

  **Sponsored by** *Athens County Public Libraries*
- [38488](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38488) Add TT filter using HTML scrubber
- [38714](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38714) Adjust templates for prettier
- [38718](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38718) main container wrapper
- [38720](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38720) HTML1 no longer valid? TT tags can be present in HTML without breaking the translator tool
- [38842](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38842) Add reusable modal wrapper
- [38984](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38984) DataTables's columnDefs cleanup
- [39046](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39046) Use Bootstrap badge to indicate late transfers

  **Sponsored by** *Athens County Public Libraries*
- [39083](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39083) Fix title sorting on list of tagged titles

  **Sponsored by** *Athens County Public Libraries*
- [39483](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39483) Update staff interface forms to use grid layout

  **Sponsored by** *Athens County Public Libraries*
- [39533](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39533) Use select2 to select item types and libraries in export of bibliographic records
  >This enhancement updates the bibliographic records export tool to use select2 for multiselect of item types and libraries for a more friendly user experience. Additionally the page will correctly load CSV profiles if the page is reloaded or navigated to using the back button and CSV is selected for the export.

  **Sponsored by** *Athens County Public Libraries*
- [39762](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39762) Add datatables server-side rendering to OPAC
- [39810](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39810) Use select2 to select library limitations in credit and debit type administration
  >This improves the selection of the values for the 'Libraries limitation' field when adding and editing:
  >- Debit types
  >- Credit types
  >
  >Instead of selecting multiple values from a dropdown list using the Ctrl key, you can either select or start typing the value, select or press enter, then repeat to select additional values.

  **Sponsored by** *Athens County Public Libraries*
- [39843](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39843) Use select2 for multiple selects on patron attributes and extend due dates pages
  >This improves the selection of values on these pages:
  >- Patron attribute types: for the Library limitation field
  >- Batch extend due dates: for the Patron categories, Item types, and Libraries fields
  >
  >Instead of selecting multiple values from a dropdown list using the Ctrl key, you can either select or start typing the value, select or press enter, then repeat to select additional values.

  **Sponsored by** *Athens County Public Libraries*

### Test Suite

#### Enhancements

- [37448](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37448) Add build_sample_ill_request to TestBuilder.pm
  >This enhancement adds the ability to generate sample ILL requests for the test suite.
- [38461](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38461) Table features needs to be covered by e2e tests using Cypress
- [38503](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38503) Add a Cypress task to generate objects based on its swagger def spec
  >This provides utilities for Cypress tests to generate JavaScript objects directly from the API definitions. They contain example data and can then be using to easily mock API responses in tests.
- [38818](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38818) Add diag option to t::lib::Mocks::Logger

  **Sponsored by** *Open Fifth*
- [38944](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38944) Add Test::NoWarnings to tests without warnings
  >This enhancement adds the Test::NoWarnings module to all the tests that currently do not produce warnings. This will then be a good starting point to move toward no warnings in our tests, with the next step to clean the other tests that currently do provide warnings.
- [39007](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39007) Add last_audit to the sushi_service API spec
- [39119](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39119) xt/js_tidy.t and xt/vue_tidy.t does not use tidy.pl
- [39130](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39130) Add unit tests for xgettext.pl
- [39319](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39319) xt/author/podcorrectness.t only test POD for perl files within C4 and Koha
- [39325](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39325) Run codespell successfully on the whole codebase
- [39365](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39365) `perl -cw` should pass on all Perl files
- [39367](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39367) Add POD to all subroutines/methods
- [39700](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39700) Fix test case t/db_dependent/Authority/Merge.t broken in 34739
- [39741](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39741) xt/author/valid-templates.t should setting dirs to skip

### Tools

#### Enhancements

- [18657](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18657) Inventory tool should display more statuses/problems
  >This enhancement adds two new checkboxes to the inventory tool. One will show lost items and the other will show items without a problem when barcodes aren't compared.
- [37360](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37360) Add 'protected status' as one of the things that can be updated via batch patron modification
  >This enhancement to the batch patron modification tool allows superlibrarians to batch update the protected status setting for patrons, instead of having to change each patron individually. The edit patrons form now includes the "Protected" field. (The protected status option for patrons was added in Koha 23.11.
- [39628](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39628) Display 'diff' in action logs
  >Adds a "diff" column to the action logs viewer. This column will display the old (O) and new (N) values of the fields that were changed, for modules that store that information.

### Z39.50 / SRU / OpenSearch Servers

#### Enhancements

- [39303](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39303) Add audience index to SRU
## Bugfixes
This list includes all bugfixes since the previous major version. Most of them
have already been fixed in maintenance releases


#### Security bugs

- [39184](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39184) Server-side template injection leading to remote code execution (25.05.00)

#### Critical bugs fixed

- [33430](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33430) Use REST API for suggestions tables (25.05.00)
  >This development reworks the purchase suggestion tables to use the API, which results in much faster load times when there are many suggestions.
- [37993](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37993) Having a single EDI EAN account produces a bad redirect (25.05.00,24.11.02)
  >This fixes creating an EDIFACT order for a basket in acquisitions - if there was only one library EAN defined, then a 403 page error was generated. It also simplifies creating an EDIFACT order:
  >- If there are no library EANs defined, the "Create EDIFACT order" button is greyed out and has a tooltip "You must define an EAN in Administration > Library EANs".
  >- If there is only one library EAN defined, you are prompted to generate the order without needing to select an EAN.
  >- If there is more than one library EAN, the "Create EDIFACT order" button incorporates a dropdown list with the available library EANs.
  >(The error is related to the CSRF changes added in Koha 24.05 to improve form security.)
- [38411](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38411) When adding multiple items on receive, mandatory fields are not checked (25.05.00)
- [38423](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38423) EDIFACT invoice files should skip orders that cannot be receipted rather than failing to complete (25.05.00,24.11.04)
  >This fixes loading EDIFACT invoice files so that it skips a problematic order (usually a cancelled order or a deleted bibliographic or item record), reports any problem orders, and completes the processing of other orders. Previously, the EDIFACT page would get "stuck" and display as "Processing" for problematic orders, then the remainder of the orders in the file had to be manually receipted by library staff (as vendors are reluctant to re-process part invoices).

  **Sponsored by** *Open Fifth*
- [38961](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38961) XSS in vendor search (25.05.00,24.11.02,24.05.07,23.11.12,22.11.24)

  **Sponsored by** *Chetco Community Public Library*
- [39282](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39282) When adding an order from file, data entered in the "Item information" tab is not saved and invalid items are created (25.05.00, 24.11.03)
  >This fixes an issue that occurs in Acquisitions when adding an order from a new or staged file. If the system preference AcqCreateItem is set to create items when the order is placed, and item information is not imported from the uploaded MARC file, then the librarian would enter the item information in the "Item information" tab when confirming the order. The information from this tab was not getting processed correctly, which led to "empty" items being created.
- [39754](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39754) Cannot scroll EANs when clicking 'Create EDIFACT order' in a basket (25.05.00)
- [39858](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39858) Cannot save vendor if it has invoices (25.05.00)
- [39878](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39878) EDIFACT vendor account records sets default port incorrectly for FTP (25.05.00)
  >This fixes the default upload and download ports when creating an EDI account (Koha administration > Acquisition parameters > EDI accounts > New account). 
  >
  >If:
  >- FTP is selected, it now defaults to port 21 (instead of port 22).
  >- SFTP is selected, it defaults to port 22.
- [34070](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34070) background_jobs_worker.pl floods logs when it gets error frames (25.05.00)
- [37020](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37020) bulkmarcimport gets killed when inserting large files (25.05.00)
- [38872](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38872) Only first 'a' node tested for wrong filters (25.05.00,24.11.04)
- [39115](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39115) Tidy script should list the files we do not want to tidy (25.05.00)
- [39353](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39353) Tidy - Do not empty template files (25.05.00)
- [39849](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39849) Target dependency issue in Makefile (25.05.00)
- [38826](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38826) C4::Auth::check_api_auth sometimes returns $session and sometimes returns $sessionID (25.05.00,24.11.03,24.05.08,23.11.13)
  >This fixes authentication checking so that the $sessionID is consistently returned (sometimes it was returning the session object). (Note: $sessionID is returned on a successful login, while $session is returned when there is a cookie for an authenticated session.)
- [39874](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39874) Template error prevents authority merging (25.05.00)
  >This fixes merging authority records. It was not possible to merge authority records after bug 39325 (this only affects  Koha 25.05/main).

  **Sponsored by** *Athens County Public Libraries*
- [39299](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39299) cn_browser on 952$o fails to open from item editor (25.05.00)
- [39396](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39396) Select2 drop-downs in batch item modification are empty (25.05.00)
- [39462](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39462) (bug 37870 follow-up) Default values from framework are inserted into existing record while editing (25.05.00)

  **Sponsored by** *Pontificia Università di San Tommaso d'Aquino (Angelicum)*
- [39848](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39848) Users without edit_catalogue permission can delete the record if no items remain from the batch item deletion tool (25.05.00)
- [39864](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39864) Cannot save automatic item modifications by age rules (25.05.00)
- [33284](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33284) checkout_renewals table retains checkout history in violation of patron privacy (25.05.00)
  >With the introduction of more fine-grained renewals tracking in "Checkout renewals should be stored in their own table", we inadvertently missed applying patron anonymization preferences.
  >
  >This bug corrects that by adding logic to ensure we follow a patrons preference for removing this data.
- [38588](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38588) Checkin that triggers a transfer => print slip => Internal server error (25.05.00,24.11.02)
  >This fixes a regression caused by bug 35721 in Koha 24.11. When checking in an item that needs transferring to its home library, printing the slip was generating an error ("..Active item transfer already exists' with transfer..").
- [38789](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38789) Wrong Transfer modal does not show (25.05.00,24.11.03)
  >This fixes a regression. When an item in transit was checked in at a library other than the destination, it was not generating the "Wrong transfer" dialog box.
- [38793](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38793) When setting up automatic confirmation of transfers when dismissing the modal. It prevents manual cancellation (25.05.00,24.11.03)
  >Fixes a transfer being silently not canceled (despite clicking the button) when system preferences TransfersBlockCirc = "don't block" and AutomaticConfirmTransfer = "do automatically confirm". Which should only be about confirming when dismissing the transfer modal.
- [39302](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39302) Checkins can disappear from checkin list if transfer modal is triggered (25.05.00)
- [39750](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39750) Wrong transfer breaking check in when using library transfer limits (25.05.00)
- [38894](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38894) Longoverdue cron should follow HomeOrHoldingBranch as well as CircControl when using --library flag (25.05.00,24.11.04)
  >When the longoverdue cron is limited by library, it follows the CircControl system preference. When CircControl is set to "the item's library," this patch allows the HomeOrHoldingBranch system preference to further specify either the item's homebranch or the item's holdingbranch. This makes the longoverdue cron consistent with the application or circulation and fine rules.
- [39694](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39694) `es_indexer_daemon.pl` doesn't use batch_size in DB poll mode (25.05.00)
- [38602](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38602) Columns bookings.creation_date and bookings.modification_date not added if multiple databases are in use (25.05.00,24.11.01)
  >This fixes the database update for Bug 37592 - Add a record of creation and modification to bookings, added in Koha 24.11.00. It covers the case where multiple Koha instances are being updated on the same server - the database update was only updating the first database.

  **Sponsored by** *Koha-Suomi Oy*
- [39025](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39025) Update patron account templates to use old_issue_id to display circ info (25.05.00,24.11.03)
- [38919](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38919) Checkin does not notify of waiting holds (25.05.00,24.11.02)
- [38340](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38340) Translatability - Standard form include files are not translatable (25.05.00)
- [39765](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39765) Old-fashioned ILL backends (not plugins) are not working (25.05.00)
- [38750](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38750) Installer process not terminating when nothing to do (25.05.00,24.11.02,24.05.08)
  >This fixes the installation process - instead of getting "Try again" when there is nothing left to do (after updating the database structure) and not being able to finish, you now get "Everything went okay. Update done."
- [38779](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38779) Record sources not working on packages install (25.05.00,24.11.02,24.05.07)
  >This fixes the record sources page (Administration > Cataloging > Record sources) for package installs - you can now add and edit record sources, instead of getting a blank page. The Koha packages were missing the required JavaScript files (/intranet-tmpl/prog/js/vue/dist/admin/record_sources_24.1100000.js"></script>) to make the page work correctly.
- [39460](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39460) Debian package install broken in 24.11 if no database change included in package (e.g. 24.11.03-2) (25.05.00,24.11.03)
- [39560](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39560) For authorities, hidden fields in the record will be lost when editing and saving (25.05.00)
  >This bug fixes an issue where data would be deleted from authorities if the field was filled out but hidden in the authority type. This patch updates the authority editor to show the data if present, even if the field is edited, matching the bibliographic editor behavior.
- [32722](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32722) UNIMARC: Remove mandatory flag from some subfields and field in default bibliographic framework (25.05.00,24.11.02,24.05.08)
  >This updates the default UNIMARC bibliographic record framework to remove the mandatory flag from some subfields and fields. 
  >
  >For UNIMARC, several subfields are only mandatory if the field is actually used (MARC21 does not have this requirement). 
  >
  >A change made to the default framework by bug 30373 in Koha 22.05 meant that if the mandatory subfield was empty, and the field itself was optional (not mandatory), you couldn't save the record.
  >
  >For example, if field 410 (Series) is used (this is an optional field), then subfield $t (Title) is required. However, the way the default framework was set up (subfield $t was marked as mandatory) you couldn't save the record - as subfield $t was mandatory, even though the 410 is optional.
  >
  >As Koha is not currently able to manage both the UNIMARC and MARC21 requirements without significant changes, a practical decision was made to configure the otherwise mandatory subfields as not mandatory. 
  >
  >Important note: This only affects NEW UNIMARC installations. Existing installations should edit their default UNIMARC framework to make these changes (although, it is likely that they have already done so).
- [28478](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28478) MARC detail and ISBD pages still show suppressed records (25.05.00,24.11.02,24.05.07)
- [38683](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38683) OPAC cover images are only shown on first result page (25.05.00,24.11.02)
  >This fixes OPAC search results when cover images are enabled - covers are now shown on all the result pages, instead of just the first page of results.
- [38981](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38981) Local cover images failing to load in OPAC search results (25.05.00)
  >This patchset fixes a problem where local cover images were not properly loading on the OPAC results page. With this fix local covers now load correctly.
- [39095](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39095) Clicking 'Cancel' for article requests in the OPAC patron account does not respond (25.05.00)

  **Sponsored by** *Athens County Public Libraries*
- [39313](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39313) OpacTrustedCheckout self-checkout modal not checking out valid barcode (25.05.00)

  **Sponsored by** *Reserve Bank of New Zealand*
- [39395](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39395) Self checkout login form not correctly place (25.05.00)
  >This fixes the self checkout system login page - there was a large vertical gap between the header of the page, and the actual login form.
- [39680](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39680) The navigation item "Clear” in search history doesn't delete searches (25.05.00)

  **Sponsored by** *Athens County Public Libraries*
- [39707](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39707) Fix JS error when placing a request (25.05.00)
- [39761](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39761) OPAC DataTables responsive table controls style broken by Bug 39600 (25.05.00)

  **Sponsored by** *Athens County Public Libraries*
- [39857](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39857) OAI expanded_avs option broken (25.05.00,24.11.05)
- [38892](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38892) Patron category 'can be a guarantee' means that same category cannot be a guarantor (again) (25.05.00)
- [39331](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39331) Guarantor relationships not removed when changing patron category from memberentry.pl (25.05.00)
  >This fixes changing a patron with guarantors from a patron category that allows guarantees to one that doesn't (for example, from Kid to a Patron). Currently, the guarantor relationships are kept (when they shouldn't be).
- [39779](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39779) Table.row.add error in point of sale table (25.05.00)
- [28907](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28907) Potential unauthorized access in public REST routes (25.05.00,24.11.02,24.05.07,23.11.12,22.11.24)
- [39932](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39932) Koha::Item->_status should return an array (25.05.00)
- [38375](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38375) SIP2 syspref SIP2SortBinMapping is not working (25.05.00,24.11.03)
- [38913](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38913) Elasticsearch indexing explodes with some oversized records with UTF-8 characters (25.05.00,24.11.02,24.05.07)
- [38829](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38829) [CVE-2025-22954] SQL Injection in lateissues-export.pl (25.05.00,24.11.02,24.05.07,23.11.12,22.11.24)
- [38070](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38070) Regression in print notices (25.05.00,24.11.02)
  >This fixes a regression from the Boostrap 5 upgrade for print notices. Each notice is now on its own page, instead of running one after the other without a page break (when running gather_print_notices.pl with HTML file output). (This is related to the OPAC and staff interface Bootstrap 5 upgrade in Koha 24.11.)
- [38632](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38632) All columns shown in holdings table when displaying the filters (25.05.00,24.11.03)
  >This fixes the holdings table - clicking "Show filters" was incorrectly displaying all columns.
- [39112](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39112) Item search returns error (25.05.00)

  **Sponsored by** *Athens County Public Libraries*
- [39305](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39305) About page must warn if Plack is not running (25.05.00)
- [39664](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39664) Repeatable AV additional fields no longer work (25.05.00)
- [38268](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38268) Callers of confirmModal need to remove the modal as the first step in their callback function (25.05.00,24.11.02,23.11.14)
  >This fixes confirm dialog boxes in the OPAC to prevent unintended actions being taken, such as accidentally deleting a list. This specifically fixes lists, and makes a technical change to prevent this happening in the future for other areas of the OPAC (such as suggestions, tags, and self-checkout).
  >
  >Example of issue fixed for lists: 
  >1. Create a list with several items.
  >2. From the new list, select a couple of the items.
  >3. Click "Delete list" and then select "No, do not delete".
  >4. Then select "Remove from list", and confirm by clicking "Yes, remove from list".
  >5. Result: Instead of removing the items selected, the whole list was incorrectly deleted!

  **Sponsored by** *Chetco Community Public Library*
- [39304](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39304) Jenkins not failing when git command fails (25.05.00)
- [31450](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31450) HTML customizations and news will not display on OPAC without a publication date (25.05.00,24.11.02,24.05.08,23.11.13)
  >This fixes the display of news, HTML customizations, and pages on the OPAC - a publication date is now required for all types of additional content. Previously, news items and HTML customizations were not shown if they didn't have a publication date (this behavour was not obvious from the forms).

  **Sponsored by** *Athens County Public Libraries*
- [39170](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39170) Remote code execution within task scheduler (25.05.00,24.11.02,24.05.07,23.11.12,22.11.24)
- [39295](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39295) Patron card creator infinite loop during line wrapping in template/layout incompatibility (25.05.00)

#### Other bugs fixed

- [38617](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38617) Fix warning about auto increment and biblioitems (25.05.00,24.11.03)
  >This fixes the table name in the warning about auto increment and biblioitems on the About Koha > System information page.
  >
  >If the system identifies auto increment issues, the message is now "The following IDs exist in both tables biblioitems and deletedbiblioitems", instead of "...tables biblio and deletedbiblioitems".
- [38988](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38988) If JobsNotificationMethod is not STOMP the about page shows as if there was a problem (25.05.00)
  >This fixes the messages displayed in About Koha "Server information" and "System information" tabs, depending on whether the RabbitMQ service is running and the options for the JobsNotificationMethod system preference. Previously, an error message was shown in the system information tab when the "Polling" option was selected and RabbitMQ was not running, when it shouldn't have.
  >
  >Expected behavour:
  >- RabbitMQ running: 
  >  . STOMP option: message broker shows as "Using RabbitMQ", no warnings in the system information tab
  >  . Polling option: message broker shows as "Using SQL polling", no warnings in the system information tab
  >- RabbitMQ not running:
  >  . STOMP option: message broker shows as "Using SQL polling (Fallback, Error connecting to RabbitMQ)", error message shown in the system information tab
  >  . Polling option: message broker shows as "Using SQL polling", no warnings in the system information tab
- [39153](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39153) About does not handle log4perl warnings correctly. (25.05.00)
- [38644](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38644) Breadcrumbs disappear when zoomed in (25.05.00)
  >This fixes the display of breadcrumbs in the OPAC for smaller screen sizes - when the page was zoomed in or viewed on a mobile device, the breadcrumbs disappeared.

  **Sponsored by** *Athens County Public Libraries*
- [39209](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39209) Cookie consent banner should be 'focused' on load (25.05.00)
- [39274](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39274) HTML bg-* elements are low contrast (25.05.00)

  **Sponsored by** *Athens County Public Libraries*
- [39490](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39490) Table columns missing headings (25.05.00)
- [39492](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39492) Add missing aria label on the OPAC holdings table browse shelf link (25.05.00)
  >This enhancement adds an aria label to the browse shelf link in the OPAC holdings table. This provides more information about what the link does for those using assistive technology, such as screen readers.
- [39494](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39494) Announce status messaging on login page (25.05.00)
- [39497](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39497) 'Lists' page tabs should be marked as such (25.05.00)
- [39547](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39547) Required fields not conveyed programmatically in patron details in the OPAC (25.05.00)
- [39597](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39597) When cancelling multiple holds on a bib record cancel_hold_alert has very low contrast (25.05.00)
- [39661](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39661) Self-registration form - field label missing for gender selection (25.05.00)
- [39688](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39688) Space missing between "suspended" and "until" in the holds summary table (25.05.00)
- [39689](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39689) Typo in header of course reserves page (25.05.00)
- [39782](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39782) Staff interface patron registration form - field label missing for gender selection (25.05.00)
  >This fixes the patron registration form in the staff interface. It adds a label ("Gender") before the gender selection options in the patron identity section.
- [8425](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8425) Autobarcode generates duplicate barcodes with AcqCreateItems = on order (25.05.00,24.11.04)
- [38155](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38155) Can't close invoices using checkboxes from invoices.pl (25.05.00,24.11.02,24.05.09)
  >This fixes closing and reopening of invoices (Acquisitions > [Vendor] > Invoices). Previously, the invoices you selected weren't closed or reopened when clicking on the "Close/Reopen selected invoices" button - all that happened was that one of the selected invoices was displayed instead. (This is related to the CSRF changes added in Koha 24.05 to improve form security.)
- [38659](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38659) Cannot set a new suggestion manager when editing a suggestion (25.05.00,24.11.02)
  >This fixes editing suggestions so that you can change the suggestion manager in the staff interface. Previously, you could select a new suggestion manager, but the managed by field wasn't updated or saved.
- [38698](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38698) Created by filter in acquisitions duplicate orders search always shows zero results (25.05.00,24.11.04)
  >This fixes the "Basket created by" search when duplicating existing orders in acquisitions - it now returns results, previously no results were returned.
- [38765](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38765) Internal server error when merging invoices (25.05.00,24.11.04)
  >This fixes merging of invoices (Acquisitions > Invoices > [select invoices from search results] > Merge selected invoices > Merge). Previously, clicking "Merge" caused an internal server error with the message "The given date <date> does not match the date format (iso)...".
- [38766](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38766) Opening, closing, or deleting and invoice from the Action drop-down can cause internal server error (25.05.00,24.11.03)
  >This fixes closing and reopening of invoices using the action button options (Acquisitions > [Vendor] > Invoices > Actions) - when used from the search results when using invoice filters (for example, shipment to and from dates). This caused an internal server error with the message "The given date <date> does not match the date format (iso)...". It also adds a confirmation message when deleting an invoice.
- [38957](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38957) EDIFACT messages table should sort by 'Transferred date' descending by default (25.05.00,24.11.03)
- [38986](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38986) Restore "Any" option to purchase suggestion filter by fund (25.05.00,24.11.03)
- [39029](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39029) When a basket contains an order transferred from another basket some information is incorrect (25.05.00)
- [39044](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39044) Fund dropdown not populated for order search on acqui-home (25.05.00, 24.11.03)
- [39169](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39169) Acquisitions homepage no longer automatically hides "active" and "budget period" columns (25.05.00)
- [39530](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39530) Make MARC ordering cronjob respect the AcqCreateItems system preference (25.05.00)
- [39620](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39620) Price not populating from 020$c when creating a basket (25.05.00,24.11.05)
  >This patch fixes an error in Koha/MarcOrder.pm where price was not correctly defaulting to the 020$c if it exists.
- [39752](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39752) Koha MarcOrder does not verify bibliographic record exists when adding order and items (25.05.00)
- [39787](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39787) Sending EDI order from basket fails if only one Library EAN exists (25.05.00)
- [39888](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39888) Error on acquisitions home when no budgets are defined (25.05.00)
- [39904](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39904) EDIFACT error messages are malformed (25.05.00)
- [39914](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39914) Can't use table export function on late orders (25.05.00)
  >This fixes the export option for the acquisition's late orders table (Acquisitions > Late orders). Export now works as expected - previously, a progress spinner was shown and the table data was not exported.
- [18584](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18584) Our legacy code contains trailing-spaces (25.05.00)
- [36229](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36229) koha-run-backups should be first daily job (25.05.00,24.11.04)
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
- [37292](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37292) Add an index on expires column for oauth_access_tokens (25.05.00,24.11.01,24.05.06)
  >This adds a database index to the `expires` column for the 'oauth_access_tokens' table, making it easier for database administrators to purge older records.
- [38149](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38149) Make ESLint config compatible with version 9 and have ESLint and Prettier installed by default (25.05.00)
  >This fixes the Koha ESLint configuration (used for finding JavaScript errors) so that it is compatible with ESLint v9, changes the packages used so that ESLint and prettier are installed by default, and tidies some files that require updating after the prettier upgrade.
- [38167](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38167) ESLint: migrate config to flat format + cleanup some node dependencies (25.05.00)
- [38440](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38440) dt_button_clear_filter handling outside of datatables.js not needed (25.05.00)
- [38472](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38472) exportColumns hard-coded in patron categories, patron restriction types, and basket tables (25.05.00)
- [38524](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38524) Add support for Vue.js and TypeScript to ESLint config to be able to actually enforce coding guideline JS8 (25.05.00)
  >This updates the configuration for ESLint (used for finding JavaScript coding errors) so that ESLint can be used to check Vue (.vue) and TypesScript (.ts) files. This will help with enforcing coding guideline JS8: Follow guidelines set by ESLint (https://wiki.koha-community.org/wiki/Coding_Guidelines#JS8:_Follow_guidelines_set_by_ESLint).
- [38543](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38543) dataTables assets included but no longer exist (25.05.00,24.11.01)
  >This fixes the cause of a file not found message in log files when displaying the checkouts table for a patron (for any patron with current checkouts > Check out > Checkouts tab > Show checkouts). It removes the reference to the rowGroup data tables plugin assets - these no longer exist, as the plugin is now part of DataTables. (This is related to the upgrade to DataTables 2.x in Koha 24.11.)
- [38546](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38546) prettierrc should set tabWidth and useTabs (25.05.00)
  >This fixes Koha's Prettier code formatter configuration file (.prettierrc.js) to set the default indentation to four spaces.
- [38624](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38624) browserid_include.js no longer used (25.05.00,24.11.02)
  >This removes a JavaScript file previously used in OPAC templates that is no longer used (js/browserid_include.js).
- [38653](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38653) Obsolete call on system preference 'OPACLocalCoverImagesPriority' (25.05.00,24.11.02,24.05.09,23.11.14)
  >This fixes the OPAC search results page by removing a call to system preference OPACLocalCoverImagesPriority - this system preference no longer exists. (There is no visible difference to the OPAC search results page.)
- [38770](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38770) Remove @vue/cli-service and babel (25.05.00)
  >This removes unused dependencies following the move from webpack to Rspack (Bug 37824 - added to Koha 24.11). They were blocking upgrading ESLint and Node.js
- [38855](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38855) test/README not removed by bug 22056 (25.05.00,24.11.04)
  >This removes an unused README file and directory (koha-tmpl/intranet-tmpl/prog/en/modules/test/README).
- [38998](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38998) Cannot edit default SMTP server config when not using DB (25.05.00)
- [39092](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39092) When loading an ILL backend plugin it should be cached (25.05.00)
- [39114](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39114) Auto-rebase script does not deal correctly with deleted files (25.05.00)
- [39126](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39126) The tidy script might hide useful error message (25.05.00)
- [39132](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39132) Fix dbic: Revert changes to Schema.pm (25.05.00)
- [39149](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39149) .PL files not tidy (25.05.00)
- [39159](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39159) Remove useless autouse in C4/Koha.pm (25.05.00)
- [39172](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39172) Merging records no longer compares side by side (25.05.00,24.11.03)
  >This patch fixes a regression when merging records in the cataloging module. Columns will show side by side again when comparing records for a merge.
- [39188](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39188) ESLint doesn't work due bug in old "globals" node package (25.05.00)
- [39200](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39200) Fix QA tool complaint that hidelostitems is badly placed in sysprefs.sql (25.05.00)
- [39213](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39213) CGI::param called in list context from cataloguing/moveitem.pl (25.05.00)
- [39214](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39214) Mock preferences in t/db_dependent/Koha/Session.t for subtest 'test session driver' (25.05.00)
- [39262](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39262) showCartUpdate indirectly uses eval() (25.05.00)

  **Sponsored by** *Athens County Public Libraries*
- [39392](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39392) Atomic update README references wrong file extension (25.05.00)
- [39485](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39485) "Wide character in print" when exporting from staff interface and OPAC (25.05.00)
- [39567](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39567) Move form-submit js into js includes files (25.05.00)
  >This moves form-submit JavaScript from individual template files and adds it to the global JavaScript include files for the staff interface and OPAC.
- [39606](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39606) Cover change from bug 39294 with a Cypress test (25.05.00)
  >This adds Cyress tests for staging MARC records for import.
- [39618](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39618) Add a non-unique index/key to borrowers table for preferred_name (25.05.00)
- [39623](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39623) "make install" re-runs "make" process unnecessarily (25.05.00)
- [39734](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39734) Obsolete call of system preference IntranetmainUserblock (25.05.00)
- [39826](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39826) Vendor interface's password not utf8 decoded on display (25.05.00)
- [39833](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39833) mysqldump SET character_set_client = utf8 vs utf8mb4 (25.05.00)
- [39835](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39835) Tidy is_boolean / tinyint (25.05.00)
- [19113](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19113) Barcode value builder not working with numeric branchcode (25.05.00)
  >This fixes the generation of item barcodes, where the autoBarcode system preference is set to "generated in the form <branchcode>yymm0001" and the library code is either a number or alphanumeric value. This automatically generated barcode format didn't work in this case, and the number generated would not automatically increment.
- [25015](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25015) Staff with 'Edit Iitems' permission currently can not edit Items attached to a fast add framework (25.05.00)
- [31019](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31019) UNIMARC field help link when cataloging - update default URL (25.05.00)
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
- [31323](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31323) Edit item highlighting problem (25.05.00)

  **Sponsored by** *Chetco Community Public Library*
- [32877](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32877) Clean up cataloguing/value_builder/upload.pl (25.05.00)
- [37293](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37293) MARC bibliographic framework text for librarians and OPAC limited to 100 characters (25.05.00,24.11.01,24.05.06,23.11.11)
  >This fixes the staff and OPAC description fields for the MARC bibliographic framework forms - it increases the number of characters that can be entered to 255. Previously, the tag description fields were limited to 100 characters and the subfield description fields to 80 characters, even though the database allows up to 255 characters.

  **Sponsored by** *Chetco Community Public Library*
- [37546](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37546) We should output error messages alongside error codes for z39.50 errors (25.05.00)
  >This fixes the output displayed for errors returned from Z39.50 searches within Koha. Error messages and additional information are now shown for any error codes (when they are returned), making it easier to troubleshoot issues.
  >
  >The message output now has the 'message' first, followed by the error reference inside brackets, the "for [SERVERNAME]", and finally "result No."
- [38895](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38895) In advanced editor, the fixed data helpers put '#' instead of space in record content (25.05.00)

  **Sponsored by** *Ignatianum University in Cracow*
- [38925](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38925) Update record 'date entered on file' when duplicating a record -- in advanced editor (25.05.00)
- [39293](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39293) Remove box around subfield tag in basic editor (25.05.00)

  **Sponsored by** *Chetco Community Public Library*
- [39294](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39294) Not all settings stick when staging MARC records for import (25.05.00,24.11.04)
- [39321](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39321) Hide subfield tag for fixed length control fields (25.05.00)
- [39544](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39544) New / New record generates warnings in log (25.05.00)
- [39559](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39559) YY is not interpreted as a default value for authorities (25.05.00)
- [39561](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39561) Users with only editcatalogue: fast_cataloging cannot easily add an item if a duplicate is found (25.05.00)
- [39570](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39570) Add item form includes itemnumber while adding a new item (25.05.00)

  **Sponsored by** *Chetco Community Public Library*
- [39633](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39633) Inventory tool DataTable doesn't properly load (25.05.00,24.11.05)
- [31167](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31167) Only mark due dates in the past red on overdues report (25.05.00)
  >This fixes the overdues report (Circulation > Overdues > Overdues) so that when the "Show any items currently checked out" filter is selected, the due date is only shown in red for overdue items. Currently, the due date is in red for all items.

  **Sponsored by** *Athens County Public Libraries*
- [34068](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34068) Dropdown selector when changing pickup library should not depend on RESTdefaultPageSize (25.05.00,24.11.04)
  >This fixes the dropdown list for holds pickup locations in the staff interface - it now shows the complete list of libraries. Previously, in some circumstances, it was not showing the complete list of pickup locations (for example, with RESTdefaultPageSize = 5 and AllowHoldPolicyOverride = Allow, it would only show the final page of libraries instead of the full list of libraries).
- [36081](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36081) ArticleRequestsSupportedFormats not enforced server-side (25.05.00,24.11.02,24.05.07,23.11.12,22.11.24)
- [37334](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37334) Cannot filter holdings table by status (25.05.00)
  >This restores the ability to filter the holdings table by status. This was lost when the holdings table was upgraded to use the REST API (added to Koha 24.05 by bug 33568).
- [38232](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38232) Materials specified note un-checks 'forgive overdue charges' box (25.05.00,24.11.04)
  >This fixes the remembering of the options when checking in items from Circulation > Check in > options icon in the barcode field.
  >
  >If the "Forgive overdue charges" option was selected (shown when the finesMode system preference is set to "Calculate and charge"), this selection was not remembered after checking in an item with a materials specified note (952$3).
- [38469](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38469) Circulation returns vulnerable to reflected XSS (25.05.00,24.11.02,24.05.07,23.11.12,22.11.24)
- [38512](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38512) Item table status column display is wrong when record has recalls (25.05.00,24.11.02,24.05.09)
  >This fixes the display of recalls in the holdings table - the "Recalled by [patron] on [date]" message now only shows for item-level recalls. Previously, the message was displayed for all items when a record-level recall was made.
- [38649](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38649) Searching for a patron from additem.pl triggers an issue slip to print (25.05.00)
  >This fixes an issue when searching for a patron using the check out menu item in the header, when you are on the add or edit item form for a record. It was triggering a blank issue slip for printing. This was caused by a change in Bug 37407 (Fast add/fast cataloging from patron checkout does not checkout item) that affected checking referrer URLs and query strings.
- [38748](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38748) Library name is missing in return to home transfer slip (25.05.00,24.11.03)
  >This fixes the generation of the transfer slip - the library to transfer an item to is now shown, instead of being blank.
- [38767](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38767) Statuses in the holdings table should have block display, not inline (25.05.00)
  >This fixes the status column in the holdings table for a record with multiple statuses - each status is now shown on its own line, instead of running together. (The CSS was updated so that there is a holding_status class (which is styled as a block) and then the individual status class, for example: <span class="holding_status waitingat">Waiting at X since Y.</span>.)
- [38783](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38783) Row highlighting in the circulation history table for a patron doesn't look great (25.05.00,24.11.04)
  >This fixes the circulation history table for a patron, and makes it easier to identify checked out items:
  >- the alternating row background colors are now white and grey, rather than:
  >  . Returned items: white/grey
  >  . Checked out items: yellow/grey
  >- checked out items are now shown as "Checked out" using an orange/gold badge in the "Return date" column
- [38853](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38853) 'Cancel selected' on holds table does not work (25.05.00,24.11.03)
  >This fixes the "Cancel selected" button for a records' holds table in the staff interface - it now cancels the selected holds. Previously, after you confirmed the hold cancellation nothing happened (the background jobs didn't run and the holds were not cancelled). (This is related to the CSRF changes added in Koha 24.05 to improve form security.)

  **Sponsored by** *Chetco Community Public Library*
- [38861](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38861) Error loading the table in the bookings to collect report (25.05.00)
  >This patch fixes a bug where the bookings to collect table was not loading correctly.
- [38985](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38985) Syndetics covers don't show on OPAC result pages (25.05.00,24.11.02)
- [39108](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39108) Clicking the 'Ignore' button on hold found modal for already-waiting hold does not dismiss the modal (25.05.00,24.11.03)
- [39183](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39183) If using automatic return claim resolution on checkout, each checkout will overwrite the previous resolution (again) (25.05.00, 24.11.03)
- [39212](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39212) Error when attempting to edit a booking (25.05.00)
- [39270](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39270) Some bookable items cannot be booked (25.05.00,24.11.03)
- [39307](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39307) console.error on circ/circulation.pl page (25.05.00)
- [39323](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39323) Print dropdown in members toolbar should auto close (25.05.00)

  **Sponsored by** *Athens County Public Libraries*
- [39357](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39357) Wrong sidebar menu on batch checkout page (25.05.00)

  **Sponsored by** *Athens County Public Libraries*
- [39361](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39361) Hold found modal does not display from circulation / transfer (25.05.00,24.11.05)
- [39389](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39389) Cannot use dataTables export function on checkout table in members/moremember.pl (25.05.00)
- [39414](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39414) Item type not retained when editing a booking (25.05.00,24.11.05)
- [39421](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39421) Renewal date input field (and date picker) not showing on Circulation > Renew (25.05.00)
  >This restores the renewal due date input field and date picker on the Circulation > Renew page - this was missing. It changes the behavor slightly so that it matches the Circulation > Check in page (and other areas of Koha) - the barcode input field now has a settings icon, clicking this now shows the renewal date input field (with the date picker).
- [39491](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39491) All accountline notes should be HTML textarea (25.05.00)
- [39555](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39555) Clarify "On loan" column on "transfers to send" page (25.05.00)
  >This fixes the transfer to send table (Circulation > Transfers > Transfers to send) to clarify the values shown - if an item is not checked out, it is now shown as "Not checkout out" instead of "On shelf" - which was confusing, as it could be in transit. 
  >
  >Changes made:
  >1. The column "On loan" is now labelled "Date due".
  >2. If an item is not checked out, the value now shown is "Not checked out", instead of "On shelf". (Previously, if an item was in transit to another location (for example), it was shown as "On shelf", which was confusing.)
  >3. If an item is checked out, the value shown is "Due [DATE]" (no change in behavour).
- [39569](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39569) When cancelling a hold waiting past expiration date triggers a transfer the libraries name is not in alert (25.05.00)
- [39588](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39588) Bookings to collect report won't load when the search returns currently checked out bookings (25.05.00,24.11.05)
- [39604](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39604) Remember for the session for this patron doesn't remember to cancel a hold (25.05.00)
- [39692](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39692) With OnSiteCheckoutsForce the due date should be set (25.05.00)
- [39696](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39696) Low contrast for claim return date in circulation overdue report (25.05.00)
  >This fixes the color of the date in the return claims column on the overdues page (Circulation > Overdues > Overdues) - the date is now shown in black, instead of white.
  >
  >Previously, the date shown after a claim returned action is completed was white. The date not visible in rows with a white background, and was almost invisible in rows with a grey background.
- [29238](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29238) Cataloging cron jobs are not logged (25.05.00,24.11.04)
  >This fixes the scripts so that these cataloging cronjobs are now logged when run:
  >- misc/link_bibs_to_authorities.pl
  >- misc/cronjobs/merge_authorities.pl
  >- misc/migration_tools/remove_unused_authorities.pl
- [36932](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36932) koha-plack: Add parameter for specifically enabling Starman development environment (25.05.00)
  >This adds a --development|-dev option to koha-plack. With this new option, an error trace is displayed instead of an "Error 500" page. This makes it easier to identify issues during development.
  >
  >Note: If the -dev option is not added, restarting koha-plack defaults to using a deployment environment.
- [37920](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37920) writeoff_debts.pl should be logged (25.05.00,24.11.03)
- [38104](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38104) share_usage_with_koha_community.pl: Check between two runs is not needed (25.05.00,24.11.04)
- [38382](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38382) Need a fresh connection when CSRF has expired for connexion daemon (25.05.00,24.11.02,24.05.08)
  >This fixes the OCLC Connexion import daemon (misc/bin/connexion_import_daemon.pl) - the connection was failing after the CSRF token expired (after 8 hours). It now generates a new user agent when reauthenticating when the CSRF token for the session has expired. (This is related to the CSRF changes added in Koha 24.05 to improve form security.)
- [38386](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38386) compare_es_to_db.pl shouldn't retrieve the records from ES (25.05.00,24.11.02)
  >This small enhancement makes the `compare_es_to_db.pl` maintenance script require less resources when run.
- [38760](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38760) koha-mysql doesn't work with encrypted database connection (25.05.00)

  **Sponsored by** *Karlsruhe Institute of Technology (KIT)*
- [38857](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38857) Cronjobs should log their start and command line parameters before processing options (25.05.00,24.11.04)
  >This fixes all cronjobs so that if they fail because of bad parameters, information is now available in the log viewer to help with troubleshooting (when the CronjobLog system preference is enabled).
  >
  >Notes:
  >- This changed all the cronjobs in misc/cronjobs that had the 'cronlogaction'.
  >- It also changed misc/maintenance/fix_invalid_dates.pl (not a cronjob, but now only logs if confirmed - similar to misc/import_patrons.pl).
  >- For misc/cronjobs/purge_suggestions.pl, a verbose option was added for consistency.
- [39236](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39236) writeoff_debts.pl does not run (25.05.00,24.11.03)
- [39250](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39250) Add archive_purchase_suggestions.pl to cron.daily commented (25.05.00)
- [39301](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39301) pseudonymize_statistics.pl script generates too many background jobs (25.05.00)
- [39322](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39322) When pseudonymizing don't fetch patron attributes if none are kept (25.05.00)
- [39413](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39413) Add a check for item fields in bibliographic MARC records (25.05.00)
- [39532](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39532) Script debar_patrons_with_fines.pl should not use MANUAL restriction type
- [39733](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39733) Update code comment with a TODO in misc/cronjobs/staticfines.pl (25.05.00)
- [31165](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31165) "Public note" field in course reserve should restrict HTML usage (25.05.01,25.05.00,24.11.03,24.05.08,23.11.13,22.11.25)
- [39078](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39078) Incorrect variable checks in course reserve details template (25.05.00)

  **Sponsored by** *Athens County Public Libraries*
- [38522](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38522) Increase length of erm_argreements.license_info (25.05.00,24.11.01,24.05.06,23.11.11)
  >This fixes the ERM agreements license information field (ERM > Agreements) so that more than 80 characters can be entered. It is now a medium text field, which allows entering up to 16,777,215 characters.
- [35885](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35885) ERM vendor sort order (25.05.00)
- [36627](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36627) Display importer for manually harvested SUSHI data (25.05.00,24.11.03)
  >This fixes the ERM usage statistics import logs table to show who manually imported the SUSHI data. For eUSage > Data providers > [Name] >  Import logs, the "Imported by" column now shows the staff patron, instead of just "Cronjob".
- [37934](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37934) Extend length of API key, requestor ID and customer ID for data providers (25.05.00)
- [38466](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38466) KBART import fails silently if file extension is wrong (25.05.00,24.11.01)
  >This fixes importing of KBART files by adding an error message if the file extension is not .TSV or .CSV, instead of silently failing.
- [38782](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38782) ERM eUsage related tests are failing (25.05.00,24.11.03,24.05.09)
  >This fixes failing ERM usage tests.
- [38794](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38794) AggregatedFullText description should be Aggregated full text (25.05.00)
  >This fixes the authorized value description for AggregatedFullText in the ERM_PACKAGE_CONTENT_TYPE category. It updates the description from "Aggregated full" to "Aggregated full text".
- [38854](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38854) Unused 'class' prop in ToolbarButton (25.05.00,24.11.04)
- [39075](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39075) Fix DB inconsistencies in the usage statistics module (25.05.00)
- [39346](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39346) Only 20 additional fields can be added to an agreement (25.05.00)
  >This fixes adding a new agreement in the ERM module, where there are more than 20 additional fields. All additional fields are now listed, not just the first 20.
- [39350](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39350) The language switch is not displayed at the bottom of ERM module pages (25.05.00)
  >This restores the language selector at the bottom of the pages for the ERM and preservation modules.
- [39543](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39543) Error modal when trying to add two controlling licences to an agreement duplicates error message (25.05.00)
- [25787](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25787) Club holds can't be placed without modify_holds_priority permission (25.05.00)
  >This fixes placing holds for clubs. Placing holds for a club now only requires the place_holds permission.
- [29074](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29074) DefaultHoldExpirationdatePeriod blank value interpreted as zero (25.05.00)

  **Sponsored by** *Koha-Suomi Oy*
- [33224](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33224) OPACHoldsIfAvailableAtPickup and no on-shelf holds don't mix well (25.05.00)
- [35434](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35434) Non-superlibrarians should not place holds in other libraries when IndependentBranches is enabled (25.05.00)
  >This fixes placing holds in the staff interface so that non-superlibrarians can't place holds for other libraries when:
  >- IndependentBranches is enabled
  >- canreservefromotherbranches is set to don't allow.
  >
  >Previously, all libraries were listed when placing a hold - it should only show the item's home library.
- [37650](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37650) Fix warn and remove FIXME in circ/returns.pl (25.05.00)
- [38650](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38650) We should only fill title level or specific item holds when a patron checks out an item (25.05.00)
- [39679](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39679) Missing space before barcode in holds table with item-specific hold (25.05.00)
  >This fixes the holds table for a record:
  >1. There is now a space between "Only item" and the barcode for specific item holds, for example: "Only item 3999...".
  >2. Where there is no barcode for the item, it now shows as "Item only [No barcode]" to improve consistency with other areas of Koha (instead of "Only item No barcode").
- [36836](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36836) Review ERM module for translation issues (25.05.00,24.11.04)
  >This fixes multiple translation issues for the ERM module, including missing strings and following the coding guidelines.
- [38147](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38147) Edit button in bookings untranslatable (25.05.00,24.11.04)
  >This fixes the 'Edit' and 'Cancel' actions for the bookings table for a record in the staff interface - these are now translatable.
- [38377](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38377) Improve translatability of remaining renewals counters (25.05.00,24.11.04)
  >This fixes the translation strings for renewals - they now use named placeholders so that the correct order can be translated.
  >
  >Example: 
  >- In English: "4 of 5 renewals remaining"
  >- In Turkish: 
  >  . was incorrectly translated as "4 uzatma hakkınızdan 5 tane kaldı"
  >  . is now correctly translated as (5 uzatma hakkınızdan 4 tane kaldı"
- [38450](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38450) Missing translation string in catalogue_detail.inc (25.05.00,24.11.02)
  >This fixes some missing strings in the po files used for translation. Strings in this format were being included for translation: _("This %s is picked").format(foo) However, strings using this format were not: _("This %s is NOT picked".format(bar))
- [38630](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38630) Make the REST API respect KohaOpacLanguage cookie (25.05.00)
- [38707](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38707) Patron restriction types from installer files not translatable (25.05.00,24.11.02,24.05.08)
  >This fixes installer files so that the default patron restriction types are now translatable.
- [38726](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38726) marc vs. MARC in admin-home.tt (25.05.00)
  >This fixes the spelling in the description for Administration > Acquisition parameters > MARC order accounts (requires enabling the MarcOrderingAutomation system preference). It changes 'marc' to 'MARC'.
- [38823](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38823) The word 'Reports' in ERM menu is not translatable (25.05.00)
- [38900](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38900) Translation script explodes without a meaningful error when an "incorrect" structure is found (25.05.00)
  >This fixes the translation script so that it now provides a more meaningful error when updating a language that has incorrect strings. It now identifies exactly where the problem comes from, making it easier to fix the problem.
  >
  >An example of the updated error message:
  >
  > gulp po:update --lang LANG
  > ..
  > Incorrect structure found at ./koha-tmpl/intranet-tmpl/prog/en/modules/admin/branches.tt:230: '<option value="*" ' at misc/translator/xgettext.pl line 124, <$INPUT> line 65.
  > ..
- [38903](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38903) getTranslatedLanguages is still called with wrong theme (25.05.00)
- [38904](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38904) admin/localization should allow translation into languages only available in the OPAC (25.05.00)
- [39032](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39032) "Items selected" in item search untranslatable (25.05.00)
  >This fixes a syntax error that prevented the string "Items selected" for the item search from being picked up by the translation tool (the text is shown when items in the item search results are selected).
- [39077](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39077) Translation script raises warnings for obsolete translations (25.05.00,24.11.04)
- [32630](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32630) Don't delete ILL requests when patron is deleted (25.05.00)

  **Sponsored by** *UK Health Security Agency*
- [38339](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38339) Standard backend _get_core_fields are not translatable (25.05.00)
- [38505](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38505) CirculateILL checkout broken if item does not have a barcode (25.05.00,24.11.04)
- [38530](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38530) ILL request table won't load if libraries are in groups and staff doesn't have view_borrower_infos_from_any_libraries (25.05.00,24.11.02)
  >This fixes the interlibrary loan (ILL) requests table so that it loads (instead of saying "Processing") when library groups are used, and:
  >- the library group has the feature "Limit patron visibility to libraries within this group for members" (Limit patron data access by group) set
  >- library staff don't have permission to view patron information from any libraries (view_borrower_infos_from_any_libraries).
  >
  >The ILL table now loads, and shows "A patron from another library" for the patron details.
- [38675](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38675) 'Switch provider' dropdown options not styled properly (25.05.00)
  >This fixes the styling for the 'Switch provider' dropdown list for interlibrary loan requests - the options are now styled correctly, instead of appearing as plain text links.
- [38751](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38751) Creating ILL request through OPAC openURL explodes if same attribute defined twice (25.05.00,24.11.04)
- [38761](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38761) Backend plugins that are disabled remain visible (25.05.00)
- [39050](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39050) Duplicate "type" attributes in ill-batch-modal.inc (25.05.00)
- [39175](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39175) Send request to partners explodes (25.05.00, 24.11.03)
- [39178](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39178) ILL table does not render when viewing requests of a batch (25.05.00)
- [39446](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39446) OPAC ILL request status_alias is not displayed (25.05.00)
- [39774](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39774) OPAC ILL Unauthenticated request details table not styled correctly (25.05.00)
- [39777](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39777) ILL history check does not show in OPAC (25.05.00)
  >This fixes the ILL history check tests. It also restores the ILL history check when creating an ILL request in the OPAC. If a potential duplicate request is made (for example the patron has already made a request using the same DOI, Pubmed ID, or ISBN), it now displays the request history check page (when the ILLHistoryCheck system preference is enabled).
- [39783](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39783) HTML error for option DVD in ILL form (25.05.00)
- [39784](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39784) xxx as translatable string in ILL (25.05.00)
- [38448](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38448) Fix inconsistencies in database update messages (25.05.00,24.11.04)
  >This fixes some database update messages to improve their consistency with the database update guidelines.
- [39635](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39635) Update List::MoreUtils version in cpanfile (25.05.00)
- [38622](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38622) Fix Koha sample data to include preferred_name (25.05.00,24.11.01)
  >This updates the sample patron data used by koha-testing-docker (KTD) with the new preferred name field added by bug 28633 in Koha 24.11. Without this update, patron search results and detail pages in KTD did not have the patron's first name.
  >NOTE: This only affected the KTD environment, used for Koha development and testing.
- [39800](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39800) Error 500 when trying to delete patron card template (25.05.00)
- [37434](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37434) Lists are incorrectly sorted in UNIMARC (25.05.00)
- [39268](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39268) When switching tabs between 'My lists' and 'Public lists' incorrect lists can be displayed (25.05.00, 24.11.03)

  **Sponsored by** *Athens County Public Libraries*
- [34739](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34739) Linked biblios should not be merged (updated) when changes to an authority don't change the authorized heading (25.05.00)

  **Sponsored by** *Ignatianum University in Cracow*
- [38729](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38729) Linker should consider diacritics (25.05.00)

  **Sponsored by** *Ignatianum University in Cracow*
- [38987](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38987) Cannot link authorities with other authorities (25.05.00)
  >This fixes adding (or editing) authority terms to authority records (for example, 500$a)- choosing a term using the authority finder was not adding the selected term to the authority record (it was staying on authority finder pop up window, and generated a JavaScript error).
- [39415](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39415) Add subfield g to Geographic name authority fields (25.05.00)
- [39501](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39501) Incorrect relationship code chosen when linking authorities with other authorities (25.05.00)
- [39503](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39503) Linker should always respect thesaurus with LinkerConsiderThesaurus on (25.05.00)
- [38471](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38471) Typo: "Field suppresion, FSP (RLIN)" (25.05.00,24.11.04)
  >Thus fixes a typo in the subfield description for authority framework 090$t - "Field suppresion" to "Field suppression". (This change only affects new installations - existing installations will need to manually update their authority frameworks.)
- [39012](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39012) Koha fails to import default MARC bibliographic framework (25.05.00)
- [33268](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33268) Overlay rules don't work correctly when source is set to * (25.05.00,24.11.04)
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
- [36008](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36008) SendAlerts should use notice_email_address instead of email (25.05.00)
- [38777](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38777) HOLD letter should use the reply to of the library that hold is waiting at (25.05.00,24.11.04)
  >This updates the HOLD letter to use the reply to email address of the library the hold is waiting at instead of the patron library to ensure replies go to the correct branch for the hold.
- [39089](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39089) Delivery note in patron notice table is confusing when the delivery method is print (25.05.00)
  >This patch fixes a problem where a patron's email address is shown in the 'Delivery note' column when the message transport type is print.
- [39317](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39317) Saving a letter template can lead to a CSRF error on some installs (25.05.00)
- [39410](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39410) Notice display modal should use shadow dom (25.05.00)
- [39596](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39596) Missing labels in OPAC and staff interface when a record  has a void second indicator for MARC 780/785 (25.05.00)
- [22458](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22458) PatronSelfRegistrationEmailMustBeUnique disallows self modification requests if multiple accounts share an email address (25.05.00)
- [33012](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33012) Accessibility: Some navigation items in OPAC cannot be accessed by keyboard (search history, log out) (25.05.00)
  >This fixes the OPAC navigation menus when logged in so that keyboard users can use the tab key to navigation menus. Some menu items (such as some list options, search history, and log out) were not selectable when just using the tab key.
- [35975](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35975) Downloaded cart with BibTeX contains hash value instead of the record number (25.05.00,24.11.03)
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
- [38077](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38077) Minor spacing issue in self checkout login page (25.05.00,24.11.03)
  >This fixes a minor spacing issue on the self checkout login page. The login form is now arranged vertically and includes more padding.

  **Sponsored by** *Athens County Public Libraries*
- [38184](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38184) OpacTrustedCheckout module does not show due date (25.05.00)
  >This fixes the self checkout pop-up window when using the OpacTrustedCheckout system preference - the due date is now shown in the due date column, previously it was not showing the due date.

  **Sponsored by** *Reserve Bank of New Zealand*
- [38362](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38362) Printing lists only prints the ten first results in the OPAC (25.05.00,24.11.01,24.05.06,23.11.11)
  >This fixes printing lists in the OPAC so that all the items are printed, instead of only the first 10.
- [38422](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38422) Add data-isbn and data-title to lists for plugin cover images (25.05.00)
  >This enhancement adds cover images to OPAC lists, for OPAC enabled cover image sources.
  >
  >(Note: This currently only displays nicely with one source of cover images. With multiple sources enabled, the images are listed vertically.)
- [38462](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38462) Remove unused code for pagination in OPAC authority search (25.05.00,24.11.03)
  >This removes unused code for OPAC authority search results pagination. (There are no visible changes for patrons.)

  **Sponsored by** *Chetco Community Public Library*
- [38544](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38544) OPAC modal login should not exist when OPAC login is disabled (25.05.00,24.11.02)
  >This removes the OPAC login dialog box from the HTML when logging into the OPAC is turned off (opacuserlogin system preference), rather than just making it not visible.
- [38594](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38594) Table settings for courses reserves not working in the OPAC (25.05.00,24.11.01)
  >This fixes the OPAC course reserves table. The table settings were not taken into account when displaying the table, for example, hidden columns were still shown.
- [38595](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38595) Table settings behavior broken on some tables in the OPAC (25.05.00,24.11.01)
  >This fixes three OPAC tables (holds history, checkout history, and search history) that were not working correctly. This was caused by a JavaScript error (Uncaught TypeError: table_settings.columns is undefined). (This is related to the DataTables upgrade in Koha 24.11.)
- [38596](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38596) DataTable - previous order sequence behaviour not restored at the OPAC (25.05.00,24.11.02)
  >This fixes the display of the ordering arrows in OPAC table heading rows so that the sort options are ascending (the down arrow), and descending (the up arrow). It removes an incorrect intermediate stage where no arrows were highlighted. (This is related to the upgrade to DataTables 2.x in Koha 24.11.)
- [38620](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38620) Non-existent hc-sticky asset included in opac-tags (25.05.00,24.11.01)
  >This removes an obsolete reference to the hc-sicky JavaScript library for the OPAC tags page - hc-sticky is no longer included in Koha.
- [38657](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38657) Image obscured by the search results toolbar when previewing cover images from OPAC search results (25.05.00)
  >This fixes the display of cover images in the OPAC - the image viewer was appearing behind the search results toolbar, partially obscuring the cover image.

  **Sponsored by** *Athens County Public Libraries*
- [38753](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38753) Missing table cells breaks OPAC charges table (25.05.00,24.11.03)
  >This fixes the charges table for a patron in the OPAC (Your account > Charges). It didn't display correctly in some circumstances (there were missing empty table cells, resulting in empty and misaligned cells at the end of the table).

  **Sponsored by** *Athens County Public Libraries*
- [38963](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38963) Deletion of bibliographic record can cause search errors in OPAC (25.05.00)
  >This fixes searching in the OPAC when the OPACLocalCoverImages system preference is enabled. In some circumstances an error is generated (Can't call method "cover_images" on an undefined value...) when a record is deleted, a search is made, but the search index is not yet updated.
- [39003](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39003) Cannot see suspend column in user's hold table on OPAC (25.05.00,24.11.02)
  >This fixes the OPAC > Summary > Holds table for a logged in patron - the 'Suspend' column is now shown.
- [39088](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39088) If OPACURLOpenInNewWindow is enabled, URLs without http are broken in OPAC results (25.05.00)
- [39124](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39124) In lists dropdown, the option "view all" is always displayed (25.05.00)
- [39144](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39144) OPAC virtual card page is missing custom CSS from OPACUserCSS (25.05.00)
- [39148](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39148) Lists are incorrectly sorted in UNIMARC (OPAC follow-up) (25.05.00)
- [39276](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39276) OPACShowHoldQueueDetails datatable warning (25.05.00,24.11.05)
- [39449](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39449) OPAC table sort arrows show opposite sort direction (25.05.00)
- [39500](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39500) Subfield 111 $n is badly displayed in OPAC (25.05.00)
- [39513](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39513) Correct OPAC subscription tables DataTable initialization (25.05.00)

  **Sponsored by** *Athens County Public Libraries*
- [39528](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39528) Get rid of schema.org type "Product" (25.05.00)

  **Sponsored by** *Karlsruhe Institute of Technology (KIT)*
- [39582](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39582) Syndetics covers don't show on OPAC result pages when identifier is not ISBN (25.05.00)
- [39603](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39603) OPAC advanced search display or ITEMTYPECAT is wrong if other  authorised values have the same code (25.05.00)
- [39735](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39735) Typo in system preference call 'OPACFineNoRenewalsIncludeCredit' (25.05.00)
- [39736](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39736) Obsolete call on system preference 'OPACResultsSidebar' (25.05.00)
- [39737](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39737) Obsolete call on system preference 'PatronSelfRegistrationAdditionalInstructions' (25.05.00)
- [39738](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39738) Obsolete call on system preference 'SelfCheckHelpMessage' (25.05.00)
  >This patch obsoletes some old code related to the SelfCheckHelpMessage system preference. The system preference was made obsolete by Bug 35065 which moved the system preference into HTML customization.
- [33018](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33018) Debian package tidy-up (25.05.00,24.11.02,24.05.08)
  >This removes unneeded Debian package dependencies. Previously we provided them in the Koha Debian repository, but we no longer need to as they are now available in the standard repositories.
- [14250](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14250) Don't allow generating discharges for patrons with fines (25.05.00)
- [32604](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32604) Patron categories upper age limit not respected when creating a patron (25.05.00)
- [36025](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36025) Extended attributes clause added to patron search query even when there are no searchable attributes (25.05.00,24.11.03)
- [37992](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37992) Patron search results: table header with column filters isn't sticky anymore (25.05.00,24.11.02)
  >This fixes the sticky header for patron search results - it now includes the column headings and filters. (This restores the behavour to what it was in Koha 23.11.)
- [38395](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38395) Title is not displayed in hold history when bibliographic record is deleted (25.05.00,24.11.05)
- [38429](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38429) Ambiguous patron category when adding a new guarantee (25.05.00,24.11.02)
  >This improves adding a guarantee for a patron (+ Add guarantee). Where there is more than one patron category that can be a guarantee, the add guarantee button now includes a dropdown list of the categories. This removes the need to manually select the patron category on the patron add form - previously, if not changed, the first patron category in the list was selected by default.
- [38459](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38459) Cities dropdown should work for quick add form as well (25.05.00,24.11.03)
  >This fixes the quick add patron form so that the city field uses a dropdown list and populates other fields (state, ZIP/Postal code, and country), where cities are defined in Administration > Patrons and circulation > Cities and towns.
- [38735](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38735) New installations should include preferred_name in DefaultPatronSearchFields by default (25.05.00,24.11.03)
  >This enhancement updates the DefaultPatronSearchFields system preference - the preferred name field is now included in the default patron search using the "standard" option. Note: This change only affects new installations.
  >
  >(This is related to bug 28633 - Add a preferred name field to patrons, a new featured added in Koha 24.11.00.)
- [38772](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38772) Typo 'minPasswordPreference' system preference (25.05.00,24.11.03,24.05.09,23.11.14)
  >This fixes a typo in the code for OPAC password recovery - 'minPasswordPreference' to 'minPasswordLength' (the correct system preference name). It has no noticeable effect on resetting an account password from the OPAC.
- [38841](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38841) Guarantor does not check non members guarantor while deleting with ChildNeedsGuarantor (25.05.00)
  >This patch allows a librarian to replace a member guarantor with a non-member guarantor. Before this patch, saving a child's profile with the "delete [this guarantor]" box checked and the data entered in the non-member guarantor field resulted in an error because koha refused to delete the last guarantor.
- [38847](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38847) Renewing an expired child patron without a guarantor and with ChildNeedsGuarantor set results in an internal server error (25.05.00)
  >This fixes an internal server error when renewing an expired child patron without a guarantor, when the ChildNeedsGuarantor system preference is set to "must have". It now displays a standard error message with "This patron could not be renewed: they need a guarantor."
- [39021](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39021) Badly formatted dropdown on patron account transactions page (25.05.00)
  >This fixes the misaligned "Email" item on the "Receipt" action dropdown menu for a patron's accounting transactions page in the staff interface (when UseEmailReceipts is set to "Send"). (This is related to the OPAC and staff interface Bootstrap 5 upgrade in Koha 24.11.)

  **Sponsored by** *Athens County Public Libraries*
- [39038](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39038) CollapseFieldsPatronAddForm - Collapsing "Non-patron guarantor" section also collapses the "Patron guarantor" section (25.05.00)
  >This fixes the add patron form when using the CollapseFieldsPatronAddForm system preference to collapse sections of the form. If the "Non-patron guarantor" option was selected it was also collapsing the "Patron guarantor" section.
- [39056](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39056) Do not copy preferred_name to new patron when using Duplicate (25.05.00,24.11.04)
- [39226](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39226) [WARN] DBIx::Class::Storage::DBI::insert(): Missing value for primary key column 'borrowernumber' on BorrowerModification (25.05.00)
- [39244](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39244) Duplicate and change password buttons missing if no borrowerRelationship defined and patron is not adult (25.05.00, 24.11.03)
- [39246](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39246) Patron category charge limit inputs should be larger (25.05.00)
- [39283](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39283) Middle name doesn't display in patron search results (25.05.00,24.11.04)
- [39308](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39308) No space between preferred name and middle name in some places (25.05.00)
- [39334](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39334) Preserve order when saving patron attributes (25.05.00)
- [39379](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39379) The "Edit" button appears in patron search results even when you cannot edit the patron (25.05.00)
- [39467](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39467) Fix patron "View restrictions"  link in messages (This patch fixes a problem where the 'View restrictions' buttons was not properly opening the 'Restrictions' tab when clicked.,25.05.00)

  **Sponsored by** *Gothenburg University Library*
- [39576](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39576) 'Last patron' results should display preferred name (25.05.00)
- [39587](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39587) Patron surname missing from contact information list on patron details tab (25.05.00)
- [39644](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39644) Too many borrower_relationships causes patron page to not load (25.05.00,24.11.05)
- [39652](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39652) Pseudonymized_borrower_attributes causes subsequent pseudonymized_transactions to not be added (25.05.00)
- [39710](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39710) Cannot load holds history if there are deleted biblios (25.05.00,24.11.05)
- [38667](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38667) Point of sale transaction history should not appear to be sortable (25.05.00,24.11.03)
  >This removes the column sorting icons from the point of sale "Transactions to date" and "Older transactions" tables. The sort order for these tables is fixed, and clicking the icons had no effect.

  **Sponsored by** *Athens County Public Libraries*
- [39040](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39040) Incorrect row striping in POS transaction sales table (25.05.00)
- [35246](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35246) Bad data erorrs should provide better logs for api/v1/biblios (25.05.00)
- [37286](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37286) Fix REST API authentication when using Mojo apps (25.05.00,24.11.04)
- [38454](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38454) Memory (L1) cache is not flushed before API requests (25.05.00,24.11.02,24.05.07,23.11.12,22.11.24)
- [38678](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38678) GET /deleted/biblios cannot be filtered on `deleted_on` (25.05.00,24.11.02,24.05.08)
- [38679](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38679) GET /deleted/biblios missing some mappings (25.05.00,24.11.04)
- [38905](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38905) Updating an item of a bibliographic record should use edit_items instead edit_catalogue permission (25.05.00,24.11.04)

  **Sponsored by** *Koha-Suomi Oy*
- [38926](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38926) POST /biblios returns 200 even if AddBiblio fails (25.05.00,24.11.04)
- [38927](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38927) Unecessary call to FindDuplicate if x-confirm-not-duplicate is passed to POST /biblios (25.05.00,24.11.04)
- [38929](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38929) POST endpoints not returning the Location header (25.05.00,24.11.04)
- [38932](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38932) Adding debits and credits should return the correct Location header (25.05.00,24.11.04)
- [39260](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39260) Typo in acquisitions baskets API documentation (25.05.00)
- [39397](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39397) Searching a biblio by timestamp returns a different timestamp (25.05.00,24.11.04)
- [39771](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39771) The `data` attribute in job.yaml should be nullable (25.05.00)
- [39837](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39837) Vendor interface object under specified (25.05.00)
- [39838](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39838) Vendor alias object under specified (25.05.00)
- [37784](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37784) Patron password hash can be fetched using report dictionary (25.05.01,25.05.00,24.11.03,24.05.08,23.11.13,22.11.25)

  **Sponsored by** *Reserve Bank of New Zealand*
- [37927](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37927) Show report name on page title when viewing SQL (25.05.00,24.11.04)
  >This fixes the browser window/tab page title when viewing the SQL for a report (Reports > Saved reports > Actions > View) - it now includes the report name and number.
- [39015](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39015) Date sorting not working in cash register statistics wizard (25.05.00)
  >This fixes date sorting for the cash register statistics wizard so that columns with dates sort correctly (it adds a "data-sort" attribute to the columns in the results table which contain dates - this allows DataTables to sort using the unformatted date). It also adds the "anti-the"  class to the title column, so that it sorts excluding articles such as a, the, and an.

  **Sponsored by** *Athens County Public Libraries*
- [39298](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39298) Runtime parameters don't work with report templates on first run (25.05.00)
- [29410](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29410) Dates compared arithmetically in MsgType.pm (warns: Argument isn't numeric in numeric ne) (25.05.00)
- [36954](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36954) SIP server logging: the use of three log files is confusing (25.05.00)
  >This harmonizes the use of logfile names for SIP with other koha debian scripts. We are still using sip-output.log and sip-error.log but we do no longer use sip.log.
  >
  >**IMPORTANT:** At upgrade time, adjust your log4perl.conf under /etc/koha/sites accordingly.
- [37816](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37816) Stop SIP2 from logging passwords (25.05.00,24.11.02,24.05.07,23.11.12,22.11.24)
- [38486](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38486) No block checkouts are still blocked by fines, checkouts, and blocked item types (25.05.00,24.11.02,24.05.08,23.11.13)
  >This fixes SIP so that it allows noblock checkouts, regardless of normal patron checkout blocks.
  >
  >Explanation: The purpose of no block checkouts in SIP is to indicate that the SIP machine has made an offline ("store and forward") transaction. The patron already has the item. As such, the item must be checked out to the patron or the library risks losing the item due to lack of tracking. As such, no block checkouts should not be blocked under any circumstances.
- [38615](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38615) Cancelling a waiting hold via SIP should include an option to move it to holds with cancellation requests (25.05.00)
- [38658](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38658) SIP not marking patrons expired unless NotifyBorrowerDeparture has a positive value (25.05.00)
- [38810](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38810) SIP account level system preference overrides not properly cleared between requests (25.05.00,24.11.04)
- [39842](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39842) SIP current_location field is never sent (25.05.00)
- [14907](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14907) Item search: call numbers in item search results are ordered alphabetically (25.05.00,24.11.04)
  >This fixes item search results when ordering the results by the call number. They are now correctly ordered using cn_sort, instead of a basic "alphabetical" order (cn_sort uses the appropriate sorting rules for the classification scheme).
- [38646](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38646) C4::Languages::getLanguages is very unreasonably slow (100+ ms) (25.05.00,24.11.04)
- [38846](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38846) Function getLanguages is called unnecessarily for search result pages (25.05.00,24.11.04)
  >This fixes OPAC and staff interface searching so that language option functions (C4::Languages::getLanguages) are only used on the advanced search pages and not the search result pages, where the output is not used.
  >
  >This should also help improve performance - this might be minor on a quiet system, but it could have an impact on a busier system (and reduces unnecessary database calls).
- [38935](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38935) "Actions" column not translatable for the item search results table (itemsearch.tt) (25.05.00,24.11.02)
  >This fixes the item search results table in the staff interface - the "Actions" column label is now translatable.
- [39020](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39020) Search filters can't parse query in some instances (25.05.00)
- [23875](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23875) Elasticsearch - When sorting by score we should provide a tiebreaker (25.05.00)
  >This fixes search results when using Elasticsearch so that:
  >- When searching by relevance (the default) and a generic search (such as "*"), search results are returned with the highest record number first (previously, search results were returned with the lowest record number first)
  >- Editing a record and repeating a generic search doesn't change the sort order (previously editing a record would change the search results order).
  >
  >Changing the sort order of results (such as by author (A-Z) or title) continue to work as expected.
- [38101](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38101) ES skips records with huge fields (25.05.00,24.11.02)
  >This fixes indexing of subfields with a large amount of text (such as 500$a) - the text is now indexed, and the record can now be found. Previously, subfields with a large amount of text were not correctly indexed.
- [39079](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39079) Matchpoints with multiple fields require all fields to match under Elasticsearch (25.05.00)
- [26479](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26479) Always show "Check in"-button if SCOAllowCheckin (25.05.00)
- [36586](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36586) Self-checkouts will get CSRF errors if left inactive for 8 hours (25.05.00)
- [38174](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38174) Self checkout renders alert for each checkout in session instead of just most recent checkout (25.05.00,24.11.04)
- [39217](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39217) Self checkout: Fix ugly error on wrong password when logging in (25.05.00)
  >This fixes the error message on the self checkout login form (when the AutoSelfCheckAllowed system preference is used) so that it uses the same message as the regular OPAC when incorrect credentials are used.
  >
  >- Previous message: "The userid Koha::Patron=HASH(0x606447f6d868) was not found in the database. Please try again."
  >- Updated error message: "You entered an incorrect username or password. Please try again! But note that passwords are case sensitive. Please contact a library staff member if you continue to have problems."

  **Sponsored by** *Athens County Public Libraries*
- [39484](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39484) Can't play audio alerts on self checkout from an external source (25.05.00)
- [34971](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34971) Closing a subscription should require edit_subscription permission (25.05.00)
  >This fixes the serials receiving (receive_serials) permission - staff that only have this permission can now only receive serials, and can no longer (incorrectly) close a subscription. Previously, the "Close" action was incorrectly shown on the subscription details page and this allowed staff to close (but not reopen) a subscription (Serials > Search > [select a serial from the results] > Subscriptions detail page for a serial).
- [35202](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35202) Table settings should apply to multiple subscriptions in the OPAC (25.05.00,24.11.05)
  >This fixes the display of columns shown for the subscription detail tables in the OPAC, where there are multiple subscriptions for a record. Any changes to the columns were only applied to the first subscription, for all the other subscriptions all the columns were shown (including columns that should have been hidden). (Columns for the subscription tables for the OPAC record details are configured under Administration > Additional parameters > Table settings > OPAC > subscriptionst.)

  **Sponsored by** *Athens County Public Libraries*
- [38470](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38470) Subscription detail page vulnerable to reflected XSS (25.05.00,24.11.01,24.05.06,23.11.11,22.11.23)
- [38515](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38515) Generate next serial deletes the notes from the expected serial and ignores preference PreserveSerialNotes in the new serial (25.05.00)
  >This fixes the generation of the next serial and keeping the issue notes, when PreserveSerialNotes is set to "Do". If a serial with the status "Expected" had notes and the next issue was generated (the "Generate next" button), the serial status changed to "Late" and the notes were not copied over - as expected. However, if PreserveSerialNotes was set to "Do", it wasn't keeping the note for the next issue.
- [38528](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38528) Additional fields are not properly fetched in serial subscription details (25.05.00)
- [39406](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39406) Issues on serial collection page sort from old to new now (25.05.00,24.11.05)
  >This fixes the serial collection table so that issues now sort in descending order based on the date published column (the latest issue at the top).

  **Sponsored by** *Pymble Ladies' College*
- [39775](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39775) Serials claims table filters aren't working (25.05.00)
  >This restores the table filters for serial claims search results - they are now located at the top of the table, and actually work. This was a regression.
- [39814](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39814) Filters on subscription search are broken (25.05.00)
  >This restores the column filters to the top of the table for serials search - they are now located at the top of the table, and actually work. This was a regression.
- [39915](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39915) Late issues export exports empty rows in CSV (25.05.00,24.11.05)
- [34681](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34681) Last returned by and last/previous borrower doesn't display if patron's cardnumber is empty (25.05.00)
  >This fixes a bug where the 'Last borrower' and 'Previous borrower' links did not appear when the borrower lacked a cardnumber. This patch makes it fall back to borrowernumber in those cases.
- [36867](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36867) ILS-DI AuthorizedIPs should deny explicitly except those listed (25.05.00,24.11.04,24.05.09,23.11.14,22.11.26)
  >This patch updates the ILS-DI authorized IPs preference to deny all IPs not listed in the preference.
  >
  >Previously if no text was entered the ILS-DI service was accessible by all IPs, now it requires explicitly defining the IPs that can access the service.
  >
  >Upgrading libraries using ILS-DI should check that they have the necessary IPs defined in the system preference.
- [37393](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37393) Bundle items don't show their host in the staff interface (25.05.00,24.11.01,24.05.06)
  >This fixes the item status for an item in a bundle, shown in the staff interface's holdings table. If an item is part of a bundle, the item status should show as "Not for loan (Added to bundle). In bundle: [Title and link to record it is bundled with]". It was not showing the "In bundle: [...]" text and link to the bundled item.
  >
  >(Note: This fixes the staff interface, the OPAC correctly shows the text and link. To use the bundle feature: 
  >1) For a record's leader, set position "7- Bibliographic level" to "c- Collection".
  >2) Use the "Manage bundle" action for the record's item, and add items to the bundle.)
- [37727](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37727) CVE-2024-24337 - Fix CSV formula injection - client side (DataTables) (25.05.00,24.11.01,24.05.06,23.11.11,22.11.23)
- [37761](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37761) Tabs on curbside_pickups.tt page not styled right after Bootstrap 5 update (25.05.00,24.11.03)
  >This fixes the curbside pickups page (Circulation > Holds and bookings > Curbside pickups) so that the tabs are correctly styled (instead of plain links), and the automatic refresh works as expected (you stay on the currently selected tab). (This is related to the OPAC and staff interface Bootstrap 5 upgrade in Koha 24.11.)

  **Sponsored by** *Athens County Public Libraries*
- [38108](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38108) Make display of table filters in staff interface holdings table configurable (25.05.00,24.11.03)
  >This patch adds a new system preference called 'AlwaysShowHoldingsTableFilters'. This system preference allows staff to control the behavior of the filters on the items detail page. It can be set to either always show the filters by default or to never show the filters by default.
- [38367](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38367) offset is wrong on plugins-disabled.tt page (25.05.00)
  >This fixes the display of the plugins page, when plugins are disabled in koha-conf.xml and the page is accessed directly. The message that plugins are disabled is now indented, instead of aligned to the far left.
- [38465](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38465) Cannot schedule a curbside pickup (25.05.00)
  >This removes duplicated JavaScript library includes from the curbside pickup page, as they are now included in the main include. (This is a follow-up to bug 36454 - Provide indication if a patron is expired or restricted on patron search autocomplete, a new feature added in Koha 24.11.00.)
- [38468](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38468) Staff interface detail page vulnerable to reflected XSS (25.05.00,24.11.01,24.05.06,23.11.11,22.11.23)
- [38711](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38711) Wrong font-weight in tables during printing from staff interface (25.05.00,24.11.03)
  >This fixes the print style sheet for tables in the staff interface - the last column is no longer printed in bold. This was affecting various pages when printed, such as notices and slips, and pages.

  **Sponsored by** *Deutsches Elektronen-Synchrotron DESY, Library*
- [38724](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38724) Holdings table - filters shown after column visibility is updated (25.05.00,24.11.04)
  >This fixes the holdings table. If you clicked "Columns" and you added or removed a column, it was automatically showing the column filters - but it didn't toggle "Hide filters" and you had to click twice to hide them.
- [38773](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38773) SMTP server is not showing on the library detail page (25.05.00)
  >This fixes the library detail page (Administration > Libraries > [view a library]) so that the SMTP server information is now shown (where it exists). Previously, the SMTP server was showing in the list of libraries, but not on the library's individual detail page.
- [38827](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38827) New search performed when column filters lose focus (25.05.00,24.11.04)
  >This fixes DataTable tables to stop duplicate update queries being made when values are entered for filters and then the focus is lost (for example, clicking somewhere else on the screen).
- [38954](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38954) checkout type column should be hidden by colvis (25.05.00,24.11.04)
- [38969](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38969) Reflected XSS vulnerability in tags (25.05.00,24.11.04,24.05.09,23.11.14,22.11.26)
- [39000](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39000) "Encoding errors" block on detail page hurt the eyes (25.05.00)
- [39011](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39011) Unable to search the holdings table (except home/holding libraries and barcode) (25.05.00)
  >This fixes and improves searching the holdings table for columns that use an authorized or coded value. You can now use either the codes or the description when searching for item type, current library, home library, and collection columns. For example, searching for BK or Books now works as expected.
- [39022](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39022) Last patron is replaced by current patron on page load (25.05.00)
- [39035](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39035) CookieConsentBar message prints on slip when cookies aren’t accepted (25.05.00)
  >This patch fixes a bug where CookieConsent information would show up on printed material in the staff interface.
- [39080](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39080) Table headers of holds to pull table are incorrect size on scroll (25.05.00)
- [39186](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39186) 'Cancel marked holds' button on patron holds tab styling is inconsistent (25.05.00)
- [39258](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39258) Remove extra delete button in report preview modal (25.05.00)
  >This removes an extra "Delete" button when previewing the SQL for the report from the list of saved reports page. (The duplicate button didn't do anything.)
- [39663](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39663) Patrons entry in additional fields has wrong  header (25.05.00)
  >This fixes the heading level for Koha administration > Additional parameters > Additional fields > Patrons - from an H3 to an H2 (follow-up to Bug 38662 - Additional fields admin page hard to read).
- [32949](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32949) Smart-rules prefills junk date on page load (25.05.00)
- [36163](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36163) Can't select a country for usage statistics (25.05.00,24.11.04)

  **Sponsored by** *Ignatianum University in Cracow*
- [38738](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38738) additional-fields-entry.inc always closing select element even when it doesn't exist (25.05.00,24.11.04)
- [38856](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38856) Typo: EmailAddressForPatronRegistrations - "chooose" (25.05.00,24.11.04)
  >This fixes a spelling mistake in the EmailAddressForPatronRegistrations system preference description - "chooose" -> "choose".
- [38874](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38874) Typo in UpdateItemLocationOnCheckout and UpdateItemLocationOnCheckin example (25.05.00)
- [39005](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39005) Typo in patron category 'Force new password reset' hintq (25.05.00)
- [39300](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39300) Quick edit a subfield not selecting the correct tab (25.05.00)
- [39525](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39525) Relabel "Hold pickup library match" as "Hold and booking pickup library match" (25.05.00)
- [39685](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39685) Typo: authorised value in item search fields (25.05.00)
- [39827](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39827) Wrong framework in edit framework button (25.05.00)
- [30707](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30707) Move container's closing div tag into template from intranet-bottom.inc (25.05.00)
  >For templates which use the intranet-bottom include file, the markup in that template lacks the main container's closing div, expecting it to be closed in intranet-bottom.inc. This moves that closing div into each template.
  >
  >This is intended to make it clearer to anyone trying to maintain the correct structure of the page, and hopefully to make it possible to automatically tidy template files.
- [31270](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31270) Terminology: Standardize on self-registration or self registration (25.05.00)
  >This fixes any occurrences of "self registration" (and variations) and changes these to "self-registration" for consistency in the OPAC and staff interface.
  >
  >It also updates the system preference description for PatronSelfRegistrationLibraryList.
- [31470](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31470) Incorrect selector for relationship dropdown used in members.js (25.05.00,24.11.01)
  >This fixes the patron entry and edit form (memberentrygen.tt) to add a missing id "relationship" to the patron guarantor relationship dropdown list field (so this can be used as a selector in IntranetUserJS). 
  >
  >It also fixes an issue when adding a patron guarantor to a patron that already has a non-patron guarantor - this would incorrectly set the non-patron guarantor relationship field to empty.

  **Sponsored by** *Koha-Suomi Oy*
- [36609](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36609) Update index type labels in Elasticsearch config page: Std. Number, Call Number, <empty> (25.05.00,24.11.03)
  >This fixes the labels used for the type options when configuring Elasticsearch search fields - they now use sentence case and the full name (instead of abbreviations):
  >- Default (instead of being blank)
  >- Identifier (instead of Std. Number)
  >- Call number (instead of Call Number)
- [37634](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37634) Missing "USE Koha" causes JS errors and missing "Last patron" menu (25.05.00,24.11.02)
  >This fixes the cause of the "Last patron" menu not displaying on many staff interface pages, or generating JavaScript errors (where showLastPatron is enabled). (It adds "[% USE Koha %]" to templates where it was missing. It also removes some duplicate USE entries.)

  **Sponsored by** *Athens County Public Libraries*
- [38285](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38285) Replace instances of obsolete Bootstrap class "pull-right" (25.05.00,24.11.03)
  >This fixes some CSS from the Bootstrap 5 upgrade:
  >- Removes instances of the pre-Bootstrap-5 class "pull-right" (Bootstrap 5 menus have better responsive behavour).
  >- Adds "dropdown-item" classes to some menu items that lacked it.
  >- Adds some custom style for the "Filter" form in the patron permissions toolbar (it is now correctly aligned).
  >(This is related to the OPAC and staff interface Bootstrap 5 upgrade in Koha 24.11.)

  **Sponsored by** *Athens County Public Libraries*
- [38294](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38294) Checkbox/label for search filters incorrectly aligned (25.05.00)

  **Sponsored by** *Athens County Public Libraries*
- [38347](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38347) Fix style of sidebar form submit button on bookings to collect page (25.05.00)
  >This fixes the style for the submit button on the bookings to collect page (Circulation > Bookings to collect). It now has the same yellow "primary" style as other submit buttons, and it fills the width of the sidebar.

  **Sponsored by** *Athens County Public Libraries*
- [38349](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38349) Fix style of sidebar form submit button on tags review page (25.05.00,24.11.03)
  >This fixes the "Apply filter(s)" button on the tags review page in the staff interface (Tools > Patrons and circulation > Tags). It now has the same yellow "primary" style as other submit buttons - the text is slightly larger, and the button now fills the entire width of the sidebar.

  **Sponsored by** *Athens County Public Libraries*
- [38350](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38350) Fix style of sidebar form clear buttons (25.05.00)
  >This fixes the markup and CSS for sidebar forms that contain a submit button and a clear button (for example, the patrons and ILL requests sidebars). The submit button is now wider than the clear button for visual emphasis.

  **Sponsored by** *Athens County Public Libraries*
- [38467](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38467) Template::Toolkit filters can create risky Javascript when not using RFC3986 (25.05.00,24.11.02,24.05.07,23.11.12,22.11.24)
- [38476](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38476) Use anchor tag for DataTables configure button (25.05.00,24.11.01,24.05.06)
  >This fixes the "Configure" button for tables, so that you can now right-click and open the table settings in a new tab.
- [38502](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38502) Use Bootstrap alert info class for messages on table settings page (25.05.00,24.11.04)
  >This fixes the styles for informational messages on the table settings page (Administration > Additional parameters > Table settings). It updates the existing class (class="alert"), which doesn't add any style, to the Bootstrap 5 class (class="alert alert-info") - which now has a light blue background.

  **Sponsored by** *Athens County Public Libraries*
- [38519](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38519) Improve contrast of Bootstrap alerts and text background classes (25.05.00,24.11.03)
  >This updates the staff interface CSS to improve the visibility and contrast in Bootstrap alerts and text with background classes. (This is related to the OPAC and staff interface Bootstrap 5 upgrade in Koha 24.11.)

  **Sponsored by** *Athens County Public Libraries*
- [38536](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38536) Patrons requesting modifications: Expand correct panel (25.05.00,24.11.01)
  >This fixes the panels in the staff interface on the patrons requesting modifications page. The automatic panel expansion was not working as expected:
  >- The first panel should expand by default (when there is no patron selected)
  >- The panel should expand when a patron is selected (when opening from the patron's record)
  >(This is related to the OPAC and staff interface Bootstrap 5 upgrade in Koha 24.11.)

  **Sponsored by** *Athens County Public Libraries*
- [38611](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38611) Change 'Staff' to 'Staff interface' in HTML customization locations (25.05.00)
  >This fixes the HTML customization display location dropdown list so that the "Staff" grouping is now "Staff interface". This makes it clearer for translation.
- [38665](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38665) Markup error in additional fields template title (25.05.00,24.11.03)
  >This fixes a markup error in the browser page title for the additional fields page - there was an additional caret (>) at the start (> Additional fields > Administration > Koha, instead of Additional fields > Administration > Koha).

  **Sponsored by** *Athens County Public Libraries*
- [38701](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38701) Fix HTML validity errors in invoice template (25.05.00)
  >This fixes some HTML markup errors on the Acquisitions > Invoices page - it now passes W3C HTML validation checks.

  **Sponsored by** *Athens County Public Libraries*
- [38713](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38713) Incorrect HTML structures (25.05.00)
- [38785](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38785) Punctuation inconsistencies in system preference descriptions (25.05.00)
  >This fixes some punctuation inconsistencies for system preference descriptions, identified during translation. This includes:
  >- missing full stops at the end of complete sentences
  >- incorrect placement of full stops (for example, after each option value, instead of after the option selection box)
  >- minor wording changes (for example, Opac to OPAC)
- [38813](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38813) Curbside pickups tab not selected in OPAC (25.05.00,24.11.02)
- [38845](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38845) OpacNoItemTypeImages required to show item type images in staff interface advanced search (25.05.00,24.11.04)
  >This fixes the display of item type images in the staff interface's advanced search. The noItemTypeImages system preference now correctly controls the display of the item type images. Previously, it was incorrectly controlled by the OpacNoItemTypeImages system preference.
- [38921](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38921) Remove unused href from Cancel hold link (25.05.00,24.11.04)

  **Sponsored by** *Chetco Community Public Library*
- [38958](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38958) Search history deletion broken in the staff interface (25.05.00,24.11.04)
  >This fixes deleting catalog search history in the staff interface (when the EnableSearchHistory system preference is set to 'Keep') - the delete button now works. Previously, selected search terms could not be deleted. (This is related to the DataTables upgrade in Koha 24.11.)
- [38964](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38964) Fix column span in footer of staff interface account payment page (25.05.00)
  >This fixes an alignment problem on the 'Make a payment' screen where the table footer had an inconsistent number of columns.

  **Sponsored by** *Athens County Public Libraries*
- [38968](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38968) Identity providers "More" controls broken after Bootstrap 5 upgrade (25.05.00)
  >This fixes the identity providers add and modify form so that the "More" buttons now correctly expand and show hidden help text. (This is related to the OPAC and staff interface Bootstrap 5 upgrade in Koha 24.11.)

  **Sponsored by** *Athens County Public Libraries*
- [38979](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38979) Standardize word spacing for Cardnumber (25.05.00)
  >This changes "cardnumber" to "card number" on the Tools > Patron lists pages.

  **Sponsored by** *Athens County Public Libraries*
- [39051](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39051) Cash register statistics form submit button styled incorrectly (25.05.00)

  **Sponsored by** *Athens County Public Libraries*
- [39053](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39053) Add page-section div to reports results pages (25.05.00)
  >This fixes several report result pages so that they have a "page-section" div - they now have a white background, instead of the light grey background.

  **Sponsored by** *Athens County Public Libraries*
- [39081](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39081) Fix date and title sorting on batch extend due dates page (25.05.00)

  **Sponsored by** *Athens County Public Libraries*
- [39185](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39185) Holds priority drop-down contains extraneous 0's if there are found holds (25.05.00)
- [39189](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39189) Collapsing sections on moredetail.pl not working (25.05.00)
- [39248](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39248) Wrong 007/5 label for # in Nonprojected graphic (25.05.00)
- [39354](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39354) Remove unintended Bootstrap 5 change to scroll-behavior (25.05.00)
  >This fixes two unexpected and unintentional Bootstrap 5 changes:
  >
  >- It updates the "smooth scroll" behavior introduced in Bootstrap 5 for in-page links. Example: when clicking on a section link for a system administration, the page should jump immediately to that section instead of scrolling.
  >
  >- It updates some multiple-select dropdown lists used by some system preference controls, where a default option is not selected. When you hovered over the dropdown list, the cursor changed to a "waiting" cursor (rotating circle), this behavour is now removed. Example: the ArticleRequestsMandatoryFields system preference.
- [39400](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39400) "Jump to add item form" doesn't work while editing an existing item (25.05.00)

  **Sponsored by** *Chetco Community Public Library*
- [39404](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39404) Inconsistency due to "Add to list" vs "Add to a list" (25.05.00)
- [39409](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39409) Duplicate modifybiblio ids in cataloguing toolbar (25.05.00)

  **Sponsored by** *Chetco Community Public Library*
- [39464](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39464) Z39.50 Search results not highlighting grey rows in yellow when previewing (25.05.00,24.11.05)
- [39473](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39473) Drop-down filters on item holdings table should match codes exactly (25.05.00)
  >This fixes the dropdown filters for the holdings table in the staff interface. The filters now use an exact match.
  >
  >Example: Items with an item type of BK (Books) and BKA (Other type of book) would both be shown if either was selected in the dropdown list, instead of just the items for the specific item type.
- [39619](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39619) Typo: Identifierr (25.05.00)
- [39626](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39626) Display patron name in 'Holds to pull' report using standard template (25.05.00)
- [39831](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39831) Correct typo in manage-marc-import.tt (25.05.00)

  **Sponsored by** *Athens County Public Libraries*
- [39957](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39957) Fix JS error on credit and debit types administration pages (25.05.00)

  **Sponsored by** *Athens County Public Libraries*
- [38474](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38474) t/db_dependent/Letters.t can fail randomly (25.05.00)
- [38744](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38744) Tests in Koha/Biblio.t are not rolling back (25.05.00)
- [39286](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39286) BackgroundJob.t should mock_config (25.05.00)
- [39315](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39315) Missing tests for KohaTable search on coded value's description (25.05.00)
- [39368](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39368) Warnings from t::lib::Mocks::Zebra because of statement after exec (25.05.00)
- [39746](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39746) Wrong system preference 'AutoLocation' in test suite (25.05.00)
- [39747](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39747) Wrong system preference 'DefaultHoldExpirationUnitOfTime' in test suite (25.05.00)
- [39869](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39869) Club holds API missing tests (25.05.00)
- [39995](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39995) Koha/Biblio.t can fail on slow servers (25.05.00)
- [37266](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37266) patron_lists/delete.pl should have CSRF protection (25.05.00,24.11.02,24.05.07)

  **Sponsored by** *Athens County Public Libraries*
- [38452](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38452) Inventory tool barcodes should not be case sensitive (25.05.00,24.11.02,24.05.08)
  >This fixes the inventory tool so that it ignores case sensitivity for barcodes, similar to other areas of Koha such as checking in and checking out items (for example, ABC123 and abc123 are treated the same).
- [38531](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38531) Include action_logs.diff when reverting hold (25.05.00,24.11.02,24.05.08)
  >This fixes the holds log so that the diff now includes the changes when reverting a hold. (This was missed when the diff in JSON format feature was added to Koha 24.05 by bug 25159.).
- [38771](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38771) Typo 'AuthScuccessLog' system preference (25.05.00,24.11.03)
  >This fixes the log viewer authentication module "Log not enabled" warning message for the log viewer. If either AuthFailureLog or AuthSuccessLog system preferences are set to "Don't log", the "Log not enabled" warning icon is now shown. Previously, if one of the system preferences was set to "Log", no warning icon was shown.
- [38870](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38870) Remove overflow scroll from batch patron modification (25.05.00,24.11.04)

  **Sponsored by** *Athens County Public Libraries*
- [39070](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39070) Elasticsearch facets are not used/needed when finding record matches (25.05.00)
- [39076](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39076) Elasticsearch timeouts when committing import batches (25.05.00)
- [39717](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39717) Stock rotation stages cannot be moved (25.05.00)
- [39908](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39908) Hide diff column by default in log viewer (25.05.00)
- [38605](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38605) t/db_dependent/Koha/OAIHarvester.t fails with wrong date format (25.05.00,24.11.01)
  >This fixes the tests for t/db_dependent/Koha/OAIHarvester.t - dates were incorrectly handled during the first days of the month because of the use of non-zero-padded days values.
- [39861](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39861) Z39.50/SRU servers on second page of results cannot be deleted (25.05.00)
  >This fixes the Z39.50/SRU servers page so that servers on the second (and later) page of results can now be deleted.

## New system preferences

- AlwaysShowHoldingsTableFilters
- AutoILLBackendPriority
- AutomaticEmailReceipts
- CardnumberLog
- ConsiderHeadingUse
- ElasticsearchBoostFieldMatch
- HoldCancellationRequestSIP
- ILLHistoryCheck
- ILLOpacUnauthenticatedRequest
- ILLRequestsTabs
- LanguageToUseOnMerge
- LinkerConsiderDiacritics
- OPACDisableSendList
- PatronSelfRegistrationAgeRestriction
- PatronSelfRegistrationAlert
- TransfersLog

## Deleted system preferences

- RoutingListNote > Moved to HTML customizations
- StaffLoginInstructions > Moved to HTML customizations

## Renamed system preferences 

- UseEmailReceipts > AutomaticEmailReceipts

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Chinese (Traditional)](https://koha-community.org/manual/25.05/zh_Hant/html/) (98%)
- [English (USA)](https://koha-community.org/manual/25.05/en/html/)
- [French](https://koha-community.org/manual/25.05/fr/html/) (72%)
- [German](https://koha-community.org/manual/25.05/de/html/) (98%)
- [Greek](https://koha-community.org/manual/25.05/el/html/) (96%)
- [Hindi](https://koha-community.org/manual/25.05/hi/html/) (70%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:


- Arabic (ar_ARAB) (93%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified) (84%)
- Chinese (Traditional) (98%)
- Czech (65%)
- Dutch (86%)
- English (100%)
- English (New Zealand) (62%)
- English (USA)
- Finnish (100%)
- French (98%)
- French (Canada) (95%)
- German (100%)
- Greek (65%)
- Hindi (95%)
- Italian (79%)
- Norwegian Bokmål (72%)
- Persian (fa_ARAB) (94%)
- Polish (100%)
- Portuguese (Brazil) (95%)
- Portuguese (Portugal) (86%)
- Russian (92%)
- Slovak (59%)
- Spanish (98%)
- Swedish (87%)
- Telugu (65%)
- Tetum (51%)
- Turkish (81%)
- Ukrainian (71%)
- Western Armenian (hyw_ARMN) (61%)


Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](https://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](https://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](https://translate.koha-community.org/)

## Release Team

The release team for Koha 25.05.00 is


- Release Manager: Katrin Fischer

- Release Manager assistants:
  - Tomás Cohen Arazi
  - Martin Renvoize
  - Jonathan Druart

- QA Manager: Martin Renvoize

- QA Team:
  - Martin Renvoize
  - Marcel de Rooy
  - Jonathan Druart
  - Lucas Gass
  - Nick Clemens
  - Baptiste Wojtkowski
  - Emily Lamancusa
  - Matt Blenkinsop
  - Tomás Cohen Arazi
  - Lisette Scheer
  - David Cook
  - Paul Derscheid
  - Pedro Amorim
  - Thomas Klausner
  - Brendan Lawlor
  - Julian Maurice
  - Kyle M Hall
  - Victor Grousset
  - Owen Leonard
  - Wainui Witika-Park
  - Laura Escamilla
  - Magnus Enger
  - David Nind

- Topic Experts:
  - UI Design -- Owen Leonard
  - Zebra -- Fridolin Somers
  - REST API -- Tomás Cohen Arazi

- Bug Wranglers:
  - Michaela Sieber
  - Jacob O'Mara
  - Jake Deery

- Packaging Manager: 

- Documentation Manager: Philip Orr

- Documentation Team:
  - Aude Charillon
  - Caroline Cyr la Rose
  - David Nind

- Wiki curators: 
  - Thomas Dukleth
  - George Williams
  - Jonathan Druart

- Release Maintainers:
  - 24.11 -- Paul Derscheid
  - 24.05 -- Catalyst (Wainui Witika-Park, Alex Buckley, Aleisha Amoha)
  - 23.11 -- Fridolin Somers
  - 22.11 -- Jesse Maseto

## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 25.05.00


- Athens County Public Libraries
- [Cape Libraries Automated Materials Sharing](https://info.clamsnet.org)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)
- Cheshire Libraries Shared Services
- Chetco Community Public Library
- Deutsches Elektronen-Synchrotron DESY, Library
- Education Services Australia SCIS
- [Glasgow Colleges Library Group](https://library.cityofglasgowcollege.ac.uk)
- Gothenburg University Library
- Ignatianum University in Cracow
- Karlsruhe Institute of Technology (KIT)
- [Koha-Suomi Oy](https://koha-suomi.fi)
- [Loughborough University](https://lboro.ac.uk)
- NHS England (National Health Service England)
- [Open Fifth](https://openfifth.co.uk/)
- Pontificia Università di San Tommaso d'Aquino (Angelicum)
- Pymble Ladies' College
- Reserve Bank of New Zealand
- UK Health Security Agency
- [Wiko](https://www.wiko-berlin.de)
- Écoles nationales supérieure d'architecture (ENSA)


We thank the following individuals who contributed patches to Koha 25.05.00


- Aleisha Amohia (10)
- Pedro Amorim (127)
- Tomás Cohen Arazi (91)
- Andrew Auld (1)
- Sukhmandeep Benipal (1)
- Stefan Berndtsson (2)
- Alexander Blanchard (6)
- Matt Blenkinsop (143)
- Jérémy Breuillard (1)
- Nick Clemens (63)
- David Cook (39)
- Jake Deery (6)
- Frédéric Demians (3)
- Paul Derscheid (19)
- Roman Dolny (2)
- Jonathan Druart (623)
- Marion Durand (1)
- Magnus Enger (5)
- Laura Escamilla (4)
- Katrin Fischer (109)
- Emily-Rose Francoeur (1)
- Andrew Fuerste-Henry (21)
- Eric Garcia (3)
- Lucas Gass (104)
- Victor Grousset (14)
- Amit Gupta (1)
- David Gustafsson (9)
- Michael Hafen (1)
- Kyle M Hall (11)
- Nicolas Hunstein (8)
- Mason James (2)
- Andreas Jonsson (4)
- Janusz Kaczmarek (27)
- Thomas Klausner (4)
- Lukas Koszyk (1)
- Michał Kula (2)
- Emily Lamancusa (31)
- Sam Lau (6)
- William Lavoie (4)
- Brendan Lawlor (11)
- Owen Leonard (160)
- Yanjun Li (1)
- Nina Martinez (2)
- Julian Maurice (12)
- Matthias Meusburger (4)
- Mathieu Saby (1)
- David Nind (10)
- Eric Phetteplace (3)
- Martin Renvoize (83)
- Phil Ringnalda (15)
- Adolfo Rodríguez (2)
- Annisha Romney (1)
- Marcel de Rooy (42)
- Caroline Cyr La Rose (16)
- Andreas Roussos (2)
- Johanna Räisä (3)
- Bernard Scaife (1)
- Lisette Scheer (9)
- Danyon Sewell (1)
- Slava Shishkin (1)
- Michael Skarupianski (1)
- Fridolin Somers (14)
- Tadeusz „tadzik” Sośnierz (6)
- Leo Stoyanov (2)
- Lari Strand (1)
- Raphael Straub (5)
- Emmi Takkinen (8)
- Lari Taskula (15)
- Koha Development Team (1)
- Imani Thomas (2)
- Petro Vashchuk (5)
- Alexander Wagner (1)
- Hammat Wele (7)
- Baptiste Wojtkowski (16)
- Chloe Zermatten (2)


We thank the following libraries, companies, and other institutions who contributed
patches to Koha 25.05.00


- Athens County Public Libraries (160)
- [BibLibre](https://www.biblibre.com) (46)
- [Bibliotheksservice-Zentrum Baden-Württemberg (BSZ)](https://bsz-bw.de) (117)
- [ByWater Solutions](https://bywatersolutions.com) (217)
- [Cape Libraries Automated Materials Sharing](https://info.clamsnet.org) (12)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha) (2)
- Catalyst Open Source Academy (9)
- Chetco Community Public Library (15)
- [Dataly Tech](https://dataly.gr) (2)
- David Nind (10)
- Deutsches Elektronen-Synchrotron DESY, Library (1)
- Gothenburg University Library (10)
- [HKS3](koha-support.eu) (6)
- [Hypernova Oy](https://www.hypernova.fi) (15)
- Independant Individuals (63)
- Informatics Publishing Ltd (1)
- [Jezuici, Poland](https://jezuici.pl/) (2)
- Karlsruhe Institute of Technology (KIT) (6)
- Koha Community Developers (637)
- [Koha-Suomi Oy](https://koha-suomi.fi) (9)
- KohaAloha (2)
- Kreablo AB (4)
- [Libriotech](https://libriotech.no) (5)
- [LMSCloud](lmscloud.de) (19)
- [Montgomery County Public Libraries](montgomerycountymd.gov) (31)
- [Open Fifth](https://openfifth.co.uk/) (368)
- [Prosentient Systems](https://www.prosentient.com.au) (39)
- Rijksmuseum, Netherlands (42)
- [Solutions inLibro inc](https://inlibro.com) (29)
- Tamil (3)
- [Theke Solutions](https://theke.io) (91)
- [Xercode](https://xebook.es) (2)


We also especially thank the following individuals who tested patches
for Koha


- Hebah Amin-Headley (1)
- Pedro Amorim (32)
- Tomás Cohen Arazi (110)
- Andrew Auld (4)
- Baptiste Bayche (1)
- Catrina Berka (1)
- Matt Blenkinsop (48)
- Philippe Blouin (1)
- Fiona Borthwick (1)
- Emmanuel Bétemps (18)
- Amanda Campbell (1)
- Aude Charillon (2)
- Nick Clemens (88)
- Rebecca Coert (2)
- David Cook (35)
- Chris Cormack (1)
- Jake Deery (2)
- Ray Delahunty (6)
- Frédéric Demians (1)
- Paul Derscheid (33)
- Roman Dolny (75)
- Jonathan Druart (207)
- Hannah Dunne-Howrie (6)
- Magnus Enger (58)
- Laura Escamilla (9)
- Jeremy Evans (12)
- Katrin Fischer (1838)
- Emily-Rose Francoeur (1)
- Andrew Fuerste-Henry (19)
- Brendan Gallagher (20)
- Lucas Gass (413)
- Victor Grousset (62)
- Allax Guillen (1)
- Bo Gustavsson (1)
- Kyle M Hall (30)
- George Harkins (4)
- Heather Hernandez (1)
- Bibliothèque Ifao (1)
- Barbara Johnson (8)
- Janusz Kaczmarek (2)
- Kelly (2)
- Thibault Keromnes (2)
- Jan Kissig (11)
- Thomas Klausner (21)
- Kristi Krueger (3)
- Emily Lamancusa (35)
- William Lavoie (10)
- Brendan Lawlor (33)
- Hanna Leiker (4)
- Owen Leonard (112)
- Jesse Maseto (7)
- Julian Maurice (12)
- Gretchen Maxeiner (2)
- Esther Melander (4)
- Matthias Meusburger (2)
- Mathieu Saby (4)
- David Nind (303)
- Laura ONeil (1)
- Philip Orr (1)
- Stephanie Petruso (2)
- Eric Phetteplace (1)
- Anni Rajala (1)
- Laurence Rault (4)
- Martin Renvoize (580)
- Phil Ringnalda (125)
- Jason Robb (4)
- Marcel de Rooy (160)
- Caroline Cyr La Rose (7)
- Sam (1)
- Lisette Scheer (53)
- Janne Seppänen (3)
- Michaela Sieber (83)
- Fridolin Somers (7)
- Sam Sowanick (9)
- Tadeusz „tadzik” Sośnierz (5)
- Michelle Spinney (1)
- Leo Stoyanov (2)
- Karolina Sumara (1)
- Emmi Takkinen (19)
- Felicie Thiery (1)
- Imani Thomas (3)
- Clemens Tubach (1)
- Jason Vasche (1)
- Petro Vashchuk (1)
- Olivier Vezina (6)
- John Vinke (4)
- Shi Yao Wang (4)
- Baptiste Wojtkowski (58)
- Anneli Österman (1)


We thank the following individuals who mentored new contributors to the Koha project


- Andrew Nugged


And people who contributed to the Koha manual during the release cycle of Koha 25.05.00


- Rudolf Byker (1)
- Emmanuel Bétemps (15)
- Aude Charillon (57)
- Caroline Cyr La Rose (60)
- Heather Hernandez (12)
- Kristi Krueger (2)
- Esther Melander (5)
- Philip Orr (9)
- Martin Renvoize (1)
- Jessica Zairo (2)


We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Notes from the Release Manager

I've been honored to serve as the Release Manager for the Koha Community for three major versions. 
It's with joy, but also a little bit of sadness, that I am now writing these notes as one of the last tasks of this cycle.
I hope we once again managed to create the best version of Koha there has yet been.

Some special and well deserves thanks go to:

- My employer BSZ and my coworkers for enabling me to do this three times in a row.
- The RM assistants Jonathan, Martin and Tomás for their continuing help and support.
- Our Release Maintainers for their never-ending work of backporting.
- The people of the Koha Community for all their contributions, giving their koha to Koha. This wouldn't be possible without you.
- The libraries using Koha, without you everything we do would be pointless.


## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is main.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 26 May 2025 15:38:47.
