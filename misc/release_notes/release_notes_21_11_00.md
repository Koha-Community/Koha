# RELEASE NOTES FOR KOHA 21.11.00
25 nov. 2021

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 21.11.00 can be downloaded from:

- [Download](http://download.koha-community.org/koha-21.11-latest.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 21.11.00 is a major release, that comes with many new features.

It includes 4 new features, 196 enhancements, 388 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations



## New features

### Cataloging

- [[11175]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11175) Show the parent record's component parts in the detailed views

  >This enhancement adds the 'ShowComponentParts' system preference.
  >
  >When enabled, a record with analytical records has a new tab below the record detail containing links to the component parts records.
  >
  >The feature requires `MaxComponentRecords` is set to limit the maximum number of attached records to display; if more records are found then a link to the 'Show analytics' search will appear at the bottom of the listed analytics.
- [[14957]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14957) Write protecting MARC fields based on source of import

  **Sponsored by** *Catalyst*, *Gothenburg University Library* and *Halland County Library*

  >This enhancement enables the use of rules for merging MARC records. For example, it can be used to prevent field data from being overwritten.
  >
  >It is enabled using the new system preference "MARCOverlayRules". Rules are added, edited and deleted in the staff interface from Home > Koha administration > Catalog > MARC overlay rules.
  >
  >NOTE: A follow-up bug is being worked upon to add compatibility with bulkmarcimport.

### Course reserves

- [[14237]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14237) Allow bibs to be added to course without items

  **Sponsored by** *Bibliotheksservice-Zentrum Baden-Württemberg (BSZ)*

  >This patch adds a biblionumber column to course_items, adds a relationship between course_items.biblionumber and biblio.biblionumber, and changes course_items.itemnumber to allow null values. This feature allows a patron to add bibliographic records to course reserves. They can be added individually or in a batch. The courses that have reserved this record will also show on the record's detail page.

### OPAC

- [[28180]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28180) Use a lightbox gallery to display the images on the detail pages in OPAC

  **Sponsored by** *Gerhard Sondermann Dialog e.K. (presseplus.de, presseshop.at, presseshop.ch)*

  >This enhancement to the OPAC enables the display of multiple cover images on the detail page for a record or items in a gallery.

## Enhancements

### About

- [[29209]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29209) Credits for Saxion in Dutch (NL) translation

### Acquisitions

- [[24190]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24190) Add additional Acquisition logging

  >This enhancement adds additional logging of acquisition-related changes including:
  >- Order line creation and cancellation
  >- Invoice adjustment additions, amendments and deletions
  >- Order line receipts against an invoice
  >- Budget adjustments
  >- Fund adjustments
  >- Order release date (EDIFACT)
  >
  >The name of the system preference that enables logging of acquisition-related changes was changed from AcqLog to AcquisitionLog.
  >
  >Note: Acquisition logging was added in Koha 21.05.
- [[27287]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27287) Make note fields from orders searchable

  **Sponsored by** *Bibliotheksservice-Zentrum Baden-Württemberg (BSZ)*

  >Adds search options for the internal and vendor note fields from the basket to the advanced search form in acquisitions.
- [[28508]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28508) Use "Invoice number" instead of "Invoice no" on the invoice search filter
- [[28640]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28640) Add EDI order status to basket details display

  >Clarify the exact status of EDI orders on the basket details display, highlighting that a basket can be closed but pending or closed and sent for example.

### Architecture, internals, and plumbing

- [[17600]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17600) Standardize the EXPORT

  >We favored the use of EXPORT_OK over EXPORT, to prevent name clashes and make the import explicit.
- [[26326]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26326) Add Koha Objects for Import Records and Import Record Matches
- [[27032]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27032) CanBookBeRenewed is not understandable and needs refactoring

  >Improvements to readability of CanBookBeRenewed function
- [[27526]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27526) Remove Mod/AddItemFromMarc from additem.pl
- [[28306]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28306) Allow to query database with minimal memory footprint

  >This provides a new method Koha::Database::dbh which returns a database handler without loading unnecessary stuff.
  >This will be useful to reduce memory usage of daemons that need to check the database periodically.
- [[28374]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28374) Convert pos/printreceipt.pl to use GetPreparedLetter

  >This patch converts the point of sale receipt printer controller to using GetPreparedLetter instead of calling getletter directly.
- [[28413]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28413) background job worker is running with all the modules in RAM
- [[28417]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28417) Authen::CAS::Client always loaded even if CAS is not used
- [[28445]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28445) Use the task queue for the batch delete and update items tool

  >This enhancement changes the batch item modification and deletion tools so that they now use the task queue feature (added in Koha 21.05) instead of using background jobs. For the library staff member this provides more information on the progress of the task.
- [[28514]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28514) Replace C4::Letters::getletter with Koha::Notice::Templates->find_effective_template

  >This patch simplifies and clarifies the process of getting a notice template for a notice.
- [[28519]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28519) Add a 2nd directory for Perl modules
- [[28565]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28565) Adding a new syspref for sharing through HEA should be simpler

  >This enhancement simplifies the way new system preferences are added to Hea for statistical reporting. Before this enhancement the tests (t/db_dependent/UsageStats.t) required adjusting every time a new system preference was added. Now when a new system preference is added to Hea they are automatically picked up for the tests.
- [[28572]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28572) Replace C4::Debug with Koha::Logger->debug

  >This patch simplifies and clarifies how developers should add debug statements to the Koha codebase.
- [[28588]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28588) Add Koha::Checkouts::ReturnClaim->resolve
- [[28590]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28590) get_shelves_userenv and set_shelves_userenv not used
- [[28591]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28591) debug passed to get_template_and_user but not used
- [[28606]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28606) Replace $ENV{DEBUG} and $DEBUG with Koha::Logger->debug
- [[28624]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28624) Smart::Comments not used and not installed
- [[28765]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28765) sub find_value not used in tools/batchMod.pl
- [[28769]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28769) tabloop not used in cataloguing plugins

  >This technical change removes the "tabloop" variable that is passed from the add item form logic to the cataloguing plugins, as it is never used.
- [[28785]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28785) Code in C4::Auth::checkauth is copy pasted

  **Sponsored by** Orex Digital
- [[28893]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28893) Unused opac/rss directory can be removed
- [[28959]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28959) virtualshelves.category is really a boolean
- [[29082]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29082) Add filtering methods to Koha::ArticleRequests

  >Add re-usable pre-filtered searches to the Article Requests system.
- [[29083]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29083) Update article requests-related Koha::Patron methods to use relationships

  >Provides a small performance enhancement and allows prefetching and embedding to work in the API
- [[29084]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29084) Update article requests-related Koha::Biblio methods to use relationships

  >Provides a small performance enhancement and allows prefetching and embedding to work in the API
- [[29086]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29086) Reuse article request filtering methods in Biblio template plugin
- [[29288]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29288) Add current_checkouts and old_checkouts methods to Koha::Biblio

### Cataloging

- [[24674]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24674) Uncertain years for publicationyear/copyrightdate -- corrected
- [[27520]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27520) Adding new itemtype images boardgame, zoom-in, and zoom-out to carredart

  >This enhancement adds boardgame, zoom-in and zoom-out images to the carredart icon set for item types.
- [[27522]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27522) Add a new itemtype info image to carredart

  >This enhancement adds a info image to the carredart icon set for item types.
- [[27523]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27523) Adding new itemtype lock image to carredart

  >This enhancement adds a lock image to the carredart icon set for item types.
- [[27985]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27985) Add option for using a MARC modification template on a single record from the details page

  >This development allows for sending a single record to 'batch' modification in order to process a MARC modification template against the record.
- [[28543]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28543) Clicking on 'New record' will use default framework

  >This enhancement changes the 'New record' button when cataloguing. Before this change you needed to choose the framework - now it will use the default framework unless you select a different framework from the drop-down list. This makes it consistent with creating a new record using the 'New from Z39.50/SRU' button.
  >
  >NOTE: This is a change in default behavour that cataloguers may be used to.
- [[28694]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28694) Check alert in cataloguing should be a static message

  >This patch changes the way error form validation error messages are displayed when using the basic MARC editor in cataloging. Instead of a JavaScript alert, errors are now shown on the page itself, with links in the message to take you to the corresponding field. A new "Errors" button in the toolbar allows the user to jump back to the list of errors for easy reference.

### Circulation

- [[10902]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10902) Highlight patrons from logged-in library in patron searches

  >This enhancement highlights the branch when searching for patrons from the currently-logged-in library. 
  >
  >This includes:
  >- The "Check out" tab in the staff interface header: 
  >  . autocomplete results now show the library name. It's highlighted in green for patrons from the currently logged-in library
  >  . after submitting a partial name, the library name for patrons from the currently logged-in library is also highlighted in green
  >- Browsing for patrons: the library name for patrons from the currently logged-in library is highlighted in green.
- [[20472]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20472) Add digital scan as optional format to Article Requests

  >This patch set adds an additional (optional) format to Article Requests. Allowing a user to request a digital copy.
  >In staff the request can be processed by entering a download URL. This serves as a base for further automation.
- [[20688]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20688) Add accesskeys for hold confirmation boxes
- [[25883]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25883) Highlight transfers on checkin screen table

  >This patch replaces the `Holding library` field in the check-in table with a new `Transfer to` field.
  >
  >The `Holding library` would always match the current branch, as holding branch is updated by the check-in process.  We now highlight transfers by populating the new `Transfer to` field with the destination library.
- [[27296]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27296) Return claims should be filtered by default to show unresolved claims
- [[27944]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27944) Add new stages to the article request process

  **Sponsored by** Rijksmuseum

  >When article requests come in they may require additional processing, for example: determining the type of request or other workflows.
  >
  >This enhancement adds a requested stage before the pending and processing stages for the article request process.
- [[27945]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27945) Limit the number of active article requests per patron category

  **Sponsored by** Rijksmuseum

  >This enhancement lets you limit the number of active article requests a patron can make each day. Edit the patron category and enter the 'Maximum active article requests'.
- [[27947]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27947) Add default cancellation reasons to article requests

  **Sponsored by** Rijksmuseum

  >This feature adds a way to define a list of possible cancellation reasons for article requests. That way, they can be chosen upon cancellation.
- [[27948]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27948) Add disclaimer text to article requests feature

  **Sponsored by** Rijksmuseum

  >This enhancement lets you include text that patrons need to accept before they can place an article request (similar to the ILLModuleCopyrightClearance system preference). 
  >
  >Add the text required to the new ArticleRequestsDisclaimerText entry in the additional contents tool.
- [[27949]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27949) Batch printing of article request slips

  **Sponsored by** Rijksmuseum

  >This developments adds a way to select several article requests and print slips for them in batch.
- [[28695]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28695) Add shelving location column to overdue report (overdue.tt)
- [[28810]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28810) Housebound details should be textarea not text inputs

  >This patch changes the housebound detail form inputs from text inputs to textarea's in order to accommodate more information in each field.
- [[29093]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29093) Article requests: Checkbox for table of contents

  >This patch set adds a new article request column for a request to copy or scan table of contents.

### Command-line Utilities

- [[18631]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18631) `cleanup_database.pl` should take an option for modules in action_logs

  >This patch adds two new optional parameters to the `cleanup_database.pl` script.
  >
  >`--log-modules` - A repeatable option to specify which action log module lines to truncate.
  >
  >`--preserve-log` - A repeatable option to specify which action log module lines to keep.
- [[25429]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25429) `cleanup_database.pl` should remove resolved claims returned after X days

  >This enhancement adds the new `CleanUpDatabaseReturnClaims` system preference allowing administrators to specify how many days after resolution a claimed return record should be deleted from the database.
  >
  >For this functionality to be enabled, the `cleanup_database.pl` must be scheduled to run regularly with the new `--return-claims` parameter passed.
- [[28456]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28456) Add option to use a WHERE statement in membership_expiry.pl cronjob

  >Add an optional `--where` parameter to the `membership_expiry.pl` task. This allows for arbitrarily complex SQL where statements to be passed to the script to filter affected patrons.

### Developer documentation

- [[27375]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27375) Set YAML file settings in .editorconfig

  **Sponsored by** *Koha-Suomi Oy*

### Fines and fees

- [[22435]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22435) Clarify account_offset types by converting them to clear codes

  >This enhancement serves to clarify how the account offsets table functions.  We record all account actions in this table, including accountline creations, modifications and offsets.
  >
  >Prior to this patch we had a large number of different offset types, one for each accountline type. But we didn't clearly define what the offset was actually "doing".  This patch replaces the existing offset types with a refined list; `CREATE`, `APPLY`, `OVERDUE_INCREASE`, `OVERDUE_DECREASE` and `VOID`.
  >
  >The accountline details page, accessible from the borrower account transactions table is updated to display the whole history of the selected accountline, including creation (CREATE), increments (OVERDUE_INCREASE/DECREASE) and offsets (Application of payments, cancellations, voids, writeoffs and refunds).
- [[27583]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27583) Clarify how cash management fits together

  >This enhancement serves to clarify the parts of the cash management module by updating the names or pages and embellishing the breadcrumb navigation for these pages.
- [[28346]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28346) Action buttons should have a class per action type
- [[28389]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28389) One should be able to see details for refunds on the register summary page
- [[28421]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28421) Add tests for Voided Payment and Voided Writeoff.

### Hold requests

- [[23678]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23678) Cancel holds in bulk

  >This developments adds a way to choose multiple holds using checkboxes, to cancel them in bulk.
  >
  >It uses the new background jobs infrastructure recently introduced.
- [[28261]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28261) Add visual feedback on overridden pickup locations on patron's page
- [[28816]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28816) Improve the display of multiple holds during hold process
- [[29015]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29015) Add option to limit Holds Queue report by shelving location / collection
- [[29116]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29116) request.pl re-invents Koha::Patron::is_expired accessor
- [[29404]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29404) Add infinite scrolling to pickup location dropdowns
- [[29407]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29407) Make the pickup locations dropdown JS reusable

### ILL

- [[27170]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27170) ILL availability should be able to display arbitrary links to related resources
- [[28340]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28340) Provide improved display of ILL request metadata in notices
- [[28879]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28879) Display of metadata with long label names looks terrible

### Installation and upgrade (web-based installer)

- [[25078]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25078) Update DB process - wrap each DBRev inside a transaction and better error handling

  >This enhancement improves the reliability and error reporting of our database update procedures.
  >
  >We now stop the upgrade if we come across an error and roll back anything inside that upgrade step.  We also now report the errors to the end-user, both on the command line or in the browser.
  >
  >Finally, our monolithic updatedateabase script had been growing unmanageably large for some time. This patchset allows us to split each upgrade step into a single atomic file and thus simplifies writing updates and applying retrospective fixes.
- [[27101]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27101) Remove fr-CA installer data

  >This enhancement removes fr-CA installer data. Installer data is now in YAML format and there is no need for localized installer files (these are now translated using Koha's translation system using .po files maintained on https://translate.koha-community.org).
- [[27622]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27622) Remove nb-NO installer data

  >This enhancement removes Norwegian installer data. Installer data is now in YAML format and there is no need for localized installer files (these are now translated using Koha's translation system using .po files maintained on https://translate.koha-community.org).
- [[27823]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27823) List upcoming steps during installation process
- [[28978]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28978) Convert installer CSS to SCSS

### Label/patron card printing

- [[26340]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26340) When printing labels from a barcode range, keep zero padding

### MARC Bibliographic data support

- [[18984]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18984) Remove support for NORMARC

  >The National library of Norway has replaced NORMARC with MARC21. Koha instances that use NORMARC have either been converted to MARC21, or will need to convert as part of any upgrade (from Koha 21.11 onwards).
- [[27850]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27850) Search link for 260 a and c in MARC21 XSLT display

  >This enhancement adds search links to the MARC21 XSLT display for 260$a and $c fields for the OPAC and staff interface.

### MARC Bibliographic record staging/import

- [[26402]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26402) Add --framework parameter to commit_file.pl

### Notices

- [[28153]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28153) Add 'Hold reminder' messaging preference

  >This enhancement allows staff/patrons to control individual preferences for holds reminder noticess in the patron's messaging preferences area.

### OPAC

- [[15067]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15067) Add additional languages to advanced search language search

  >This enhancement adds Estonian, Inuktitut, Inupiaq, Latvian, and Lithuanian (along with their translations) to the list of languages in the advanced search for the OPAC and staff interface (Advanced search > More options > Language drop down list).
  >
  >The list of languages is also now sorted in alphabetical order.
- [[20310]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20310) Article requests: Use details from the host record when submitting an article request on an analytic record without attached items

  >This new feature add the `ArticleRequestsHostRedirection` system preference.
  >
  >When enabled, if a user attempts to place an article request from an analytic record the system will automatically populate some details in the request from using data from the host record.
- [[24223]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24223) Convert OpacNav system preference to news block
- [[24224]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24224) Convert OpacNavBottom system preference to news block
- [[26302]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26302) OPAC XSLT Results: List variable number of itemcallnumbers

  >This enhancement allows customizing the number of call numbers displayed for OPAC search results for items available and not available by changing two new system preferences:
  >- OPACResultsMaxItems: maximum number of available items displayed in search results (default = 1)
  >- OPACResultsMaxItemsUnavailable - maximum number of unavailable items displayed in search results (such as when checked out and damaged) (default = 0)
  >
  >This is useful when records have a large number of items, for example larger libraries with many branches, union catalogues, and university libraries with course text books.
- [[26761]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26761) Use aria-disabled attribute in OPAC cart for disabled links
- [[27360]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27360) Libraries should be able to pick which branches display on the public 'Libraries' page

  >This patch adds a new field, `Public` to the definable library information. When enabled, the library details will be displayed in the libraries page on the OPAC.
- [[27445]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27445) OPAC header tweaks for non-JavaScript users
- [[27882]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27882) Move external search results links out of page heading
- [[28101]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28101) Accessibility: OPAC - Breadcrumbs should be more accessible

  **Sponsored by** *Catalyst*
- [[28142]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28142) Accessibility: OPAC Cart/basket checkboxes are not labelled
- [[28536]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28536) Move translatable strings into overdrive.js
- [[28537]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28537) Improve HTML generated by OverDrive integration
- [[28720]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28720) Update the process of adding a checkout note in the OPAC

  >This enhancement moves the entry of checkout notes for the OPAC into a modal window, with the goal of making note entry easier.
  >
  >The "add note" button in the report a problem on the OPAC summary page will trigger a modal where a patron can submit or edit their message:
  >- The modal window contains text explaining that the note will be shown to staff when the item is checked in.
  >- The message about a successfully submitted message has text formatting added to improve clarity, and includes an edit link for changing a message.
- [[28821]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28821) OPAC Advanced search: Improve operation of button plus/less
- [[28831]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28831) OPAC XSLT Results: Allow unavailable item grouping on status only for large consortia
- [[28838]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28838) SCO impossible errors are hard to target with CSS/JS

  >This patch adds unique IDs to the SCO main page so the impossible errors can easily be targeted via JS and CSS.
- [[28933]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28933) Hard to parse OPAC-detail subscription information
- [[29006]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29006) Make GoogleOpenIDConnect options consistent in the OPAC

  >This enhancement improves the consistency of the OPAC login forms when using Google OpenID Connect. A "Log in with Google" button now appears above the Koha login form when logging in from the home page, "Log in to your account" in the navigation menu, and when accessed directly (/cgi-bin/koha/opac-user.pl).
- [[29162]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29162) Change template structure on OPAC library page so that a single library can easily be hidden

  >This patch adds markup to the OPAC library page so that CSS or JS can more easily target elements of the page: 
  >- Each library section is wrapped in a div with a unique id
  >- Classes are added to the paragraphs containing phone, fax, URL, and library description.
  >- An ID has been added to the menu of libraries in the sidebar so that they can be targetted individually.

### Patrons

- [[11879]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11879) Add a new field to patron record: main contact method

  **Sponsored by** *Centre collégial des services regroupés*

  >This enhancement adds a "Main contact method" dropdown list field to the patron modification form in the staff interface and OPAC.
  >
  >This field is useful for reporting purposes, or to know which contact method to use first when trying to contact a patron.
- [[15788]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15788) Split borrowers permission into create/edit and delete

  >This enhancement allows administrators to control, at a more fine-grained level, which users may delete patron records.
  >
  >This patch introduces a new `delete_borrowers` user permission.
- [[24406]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24406) Add a span to patron category category type codes in patron search result lists

  >The patron category type code (A, C, O, ...) is currently displayed in the patron module search, patron card creator, and acquisition patron searches.
  >
  >This information is not useful for most users, as these are internal codes that cannot be easily "decoded". And while you might be able to guess A as Adult in English, it doesn't translate to other languages.
  >
  >This patch wraps a span around the patron category type code shown in () after the patron category.
- [[26544]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26544) Make housebound module show delivery preferences when scheduling
- [[27725]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27725) Use JavaScript to set history state during patron search

  >This patch modifies the process of searching patrons by the first letter of their surname so that the search is added to the browser's history. This allows the user to use the back button to return to the search after clicking one of the results.
- [[27873]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27873) Make display of patron restrictions, charges, notes, etc. consistent for check out and patron details screens

  >This enhancement updates the checkout and patron detail pages in the staff interface - circulation and patron-related messages are now displayed in the same way. Before this, messages on the two pages displayed in a different order and were inconsistent with each other.
- [[28073]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28073) Make patron modifications auto-open panel for referring patron record
- [[28450]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28450) Make Account summary print tables configurable

  >This patch adds table settings for the three tables (checkouts, fines and holds) which appear on the
  >patron's "Print summary" view. This will allow the administrator to
  >set a default configuration for columns on the print summary page.
- [[28867]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28867) Use Bootstrap button menu and modal for adding patrons to lists

### Plugin architecture

- [[26351]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26351) Add plugin hooks to transform item barcodes

  >This enhancement adds a plugin hook to transform item barcodes scanned in to Koha. For example, if you need to alter your scanned item barcodes, but your scanners cannot be programmed to do so, a plugin could be written to handle that change in Koha instead. One example would be to drop the first and last characters of the scanned barcode, which may be check digits rather than part of the barcode itself.
- [[26352]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26352) Add plugin hooks to transform patron barcodes

  >This enhancement adds a plugin hook to transform patron cardnumbers scanned in to Koha. For example, if you need to alter your scanned cardnumbers, but your scanners cannot be programmed to do so, a plugin could be written to handle that change in Koha instead. One example would be to drop the first and last characters of the scanned barcode, which may be check digits rather than part of the barcode itself.
- [[27173]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27173) Add plugin hooks for authority record changes

  >This enhancement allows plugin authors to implement an `after_authority_action` method in order to act upon authority create, modify and delete.
- [[28026]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28026) Add a 'call_recursive' method to Koha::Plugins
- [[28211]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28211) Replace use of call_recursive() with call()

  >This enhancement changes the way plugin hooks are called to transform data. We now pass object to be modified as a reference, thus allowing several plugins to operate cumulatively on the same object.
- [[28474]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28474) Pass process_message_queue.pl params to before_send_messages plugin hooks

  >This enhancement passes the parameters received by process_message_queue.pl through to the before_send_messages plugin calls. This allows plugins to respect calls that should only affect certain letter codes etc.

### REST API

- [[17314]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17314) Routes to create, list and delete a purchase suggestion
- [[27358]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27358) Add GET /public/biblios/:biblio_id/items
- [[27931]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27931) Add GET /items/:item_id/pickup_locations

  >This development adds routes for fetching an item's valid pickup location list.
- [[28412]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28412) Add supported authentication methods documentation
- [[28948]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28948) Add a /public counterpart for the libraries REST endpoints
- [[29107]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29107) item_type should be item_type_id on item response object
- [[29108]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29108) Add q parameters to items routes
- [[29183]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29183) Add query options documentation

  >This patch adds documentation of the different filtering methods the REST API provides.
- [[29290]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29290) Add routes to fetch checkouts for a given biblio

### Reports

- [[27747]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27747) Add CodeMirror custom syntax highlighting for column placeholders

  >This patch modifies the configuration of the reports module's SQL editor so that column placeholders have their own syntax highlighting, setting them apart by color from other parts of the SQL code.
- [[28454]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28454) Add Koha version number to database schema link in reports
- [[29186]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29186) Move reports result limit menu into toolbar
- [[29201]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29201) biblio_framework missing form list of runtime parameters when editing SQL reports

### SIP2

- [[12169]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12169) Improve reliability of sip_shutdown script
- [[25464]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25464) Add ability to specify client IP and SIP account used in SIP2 logging

  >This enhancement adds the ability to specify the incoming IP address used for a given log statement via SIP, as well as the SIP2 account that was in use at the time. This data is very helpful for debugging purposes.
- [[28730]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28730) Add option to format AH field (due date)  in SIP checkout response

### Searching

- [[27848]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27848) Elasticsearch - include 245b subtitle and 245p part subfields in the default title index mappings

  >This enhancement adds the 245$b (subtitle) and 245$p (part name) subfields to the default title index mappings for Elasticsearch.
- [[28384]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28384) Add 'no_items' option to TransformMarcToKoha
- [[28830]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28830) Add CNI (Control Number Identifier) search index (MARC21)

### Searching - Elasticsearch

- [[28339]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28339) Elasticsearch - Add 8XX to default title-series index mappings (MARC21)

  >This enhancement adds the 8XX (800$t, 810$t, 811$t, and 830$a) subfields to the default title-series index mappings for Elasticsearch. Currently for MARC21 only 440$a and 490$a are included.
- [[28378]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28378) Elasticsearch - Add 264c to default copydate mappings (MARC21)

  >This enhancement adds 264$c to the default mapping for the copydate index when using Elasticsearch.
- [[28379]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28379) Elasticsearch - Add 710 to author-name-corporate index (MARC21)

  >This enhancement adds the 710 to the author-name-corporate index mappings for MARC21 in Elasticsearch.
- [[28381]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28381) Elasticsearch - Add 710 and 711 to default mappings for author index (MARC21)

  >This enhancement adds fields 710$a and 711$a to the default author index mapping when using Elasticsearch.
- [[28391]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28391) Elasticsearch - Add 264b to publisher index mapping (MARC21)
- [[28393]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28393) Elasticsearch - Add 050a to lc-call-number index mapping (MARC21)

  >This enhancement adds 050$a (Library of Congress classification number) to the lc-call-number index mapping when using Elasticsearch.
  >
  >These means that when searching using lc-call-number both 050$a and 050$b (Library of Congress item number) are now searchable.
- [[28736]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28736) Better error message when ES fails to understand the syntax of the search query

### Searching - Zebra

- [[20463]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20463) Create an index for LDR, pos 19 - Multipart resource record level

  **Sponsored by** *Bibliotheksservice-Zentrum Baden-Württemberg (BSZ)*

  >This adds a new Zebra index Multipart-resource-level or mrl for LDR, pos. 19 - multipart resource record level. It allows to search for sets and parts with independent and dependent title.
- [[28337]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28337) Add System-control-number index for authorities to MARC21 indexes

### Staff Client

- [[28356]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28356) Consolidate header catalogue search box code
- [[28390]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28390) Transaction timestamps should be part of the transaction grouping row instead of repeated for each breakdown row
- [[28677]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28677) Add the word "calendar" to the description for ExpireReservesOnHolidays
- [[28819]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28819) Add link to item search from mainpage.pl
- [[29369]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29369) Use Flatpickr in dateaccessioned cataloging plugin

### System Administration

- [[27505]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27505) Add new itemtype controller image for carredart

  >This enhancement adds a video game controller image to the carredart icon set for item types.
- [[27521]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27521) Adding new itemtype headset image for carredart

  >This enhancement adds a headset image to the carredart icon set for item types.
- [[28347]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28347) Add DataTables, additional information to patron attribute types management
- [[28563]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28563) Add AllowHoldItemTypeSelection to Hea

  >This enhancement adds the AllowHoldItemTypeSelection system preference to the list of system preferences usage data that will be shared with Hea.
- [[29149]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29149) Background job detail view needs more flexibility

### Templates

- [[12561]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12561) Remove non-XSLT views

  >This removes the non-XSLT views feature that was deprecated from July 2014.
  >
  >As part of this change:
  >- system preferences HighlightOwnItemsOnOPAC and HighlightOwnItemsOnOPACWhich are removed
  >- a warning is added to the about page if a default XSLT file was removed, or if a file referenced in one of the system preferences does not exist.
- [[26838]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26838) Improve styling of checkin message
- [[26949]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26949) Upgrade TinyMCE in the staff interface from 5.0.16 to 5.9.2
- [[28084]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28084) Standardize: Cardnumber, Card number, Card
- [[28321]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28321) Use template block for display of items in search results
- [[28376]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28376) Flatpickr introduction for datetime picker

  >This patch begins the process of replacing an obsolete jQuery plugin with a new library for selecting dates and times. Koha uses the jQueryUI "datepicker" widget for selecting dates, and uses an additional plugin, "jQuery Timepicker Addon," when adding time selection to the widget. This additional plugin has not been updated for many years. The new library, Flatpickr, will eventually replace both the jQuery Timepicker Addon and the jQueryUI datepicker widget. This replacement process begins here with the new Flatpickr calendar widget being added to Circulation -> Renew, Reports -> Patron statistics wizard, and Administration -> Patron categories.
- [[28394]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28394) Improve style of patron category entry form
- [[28843]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28843) Add view and edit buttons to result of MARC record import
- [[28937]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28937) Use Flatpickr on circulation and patron pages
- [[28942]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28942) Use Flatpickr on acquisitions pages
- [[28945]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28945) Use Flatpickr on administration pages
- [[28949]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28949) Use Flatpickr on reports pages
- [[28958]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28958) Use Flatpickr on serials pages
- [[28961]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28961) Use Flatpickr on tools pages
- [[28963]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28963) Use Flatpickr on calendar page
- [[28982]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28982) Use Flatpickr on onboarding pages
- [[28983]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28983) Use Flatpickr on various pages
- [[28988]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28988) Reindent calendar template
- [[29041]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29041) Improve specificity of breadcrumbs in Additional Contents
- [[29042]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29042) Improve formatting of entry form in Additional Contents
- [[29052]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29052) Make consistent use of spans and div with hint class
- [[29229]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29229) Use Flatpickr in suggestion search sidebar filter
- [[29231]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29231) Add missing Flatpickr to inventory page
- [[29270]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29270) Use flatpickr and futuredate on reserve/request.tt
- [[29299]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29299) Reindent serials search template

### Test Suite

- [[19185]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19185) Web installer and onboarding tool selenium test
- [[19821]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19821) Run tests on a separate database
- [[28615]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28615) Add a simple way to mock Koha::Logger

### Tools

- [[16446]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16446) Allow librarians to add borrowers to patron lists by borrowernumber
- [[22544]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22544) Move C4:NewsChannels to Koha namespace
- [[24019]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24019) Patron batch modification based on borrowernumber

  >With this change the batch patron modification tool can now accept a file or list of borrowernumbers in addition to accepting cardnumbers or a patron list.
- [[24387]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24387) Rename News tool

  >This enhancement is renaming the "News" tool to the more generic
  >"Additional contents".
  >It creates two different "categories" of content:
  >"news" and "HTML customizations".
- [[26080]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26080) Use the task queue for the batch delete records tool
- [[27883]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27883) Add ability to preserve patron field from being overwritten by import

  >This enhancement to the patron import tool lets you keep current values for selected fields for existing patrons - when the data is imported the selected fields are not overwritten.
  >
  >When importing:
  >- match to existing patrons using either their card number or user name
  >- select the fields that will not be overwritten under 'Preserve existing values'.
- [[28175]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28175) Usability improvements to uploads page

  >Some general improvements have been made to the "Upload" page in the Tools section: An "Upload" toolbar button is now present on upload results and search results pages; Search forms now appear in the sidebar if you're not on the main page; Upload categories are shown in search results as full descriptions linked to a search for that category.
- [[28177]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28177) Add date column and column configuration to uploads
- [[28839]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28839) Better texts in stage MARC for import
- [[29265]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29265) Can't pick editor to use when adding new news or HTML customization entries

### Web services

- [[26195]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26195) Add a way to specify authorised values should be expanded [OAI]

  >This enhancement adds a new option to the OAI configuration file, to tell it to expand authorised values.
- [[28630]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28630) ILSDI::AuthenticatePatron should set borrowers.lastseen

### Z39.50 / SRU / OpenSearch Servers

- [[8280]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8280) SRU should be filterable by Koha Item Type


## Critical bugs fixed

(This list includes all bugfixes since the previous major version. Most of them
have already been fixed in maintainance releases)

### Acquisitions

- [[14999]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14999) Adding to basket orders from staged files mixes up the prices between different orders
- [[24370]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24370) Editing purchase suggestion changes the acquisition library to logged-in user's
- [[28773]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28773) Aquisitions from external source not working for non english language
- [[28946]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28946) 500 error when choosing patron for purchase suggestion
- [[28960]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28960) EDI transfer_items uses a relationship where it's looking for a field
- [[29283]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29283) Cannot delete basket with cancelled order for deleted biblio
- [[29496]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29496) Can't save an order with mandatory items subfields

### Architecture, internals, and plumbing

- [[24434]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24434) C4::Circulation::updateWrongTransfer is never called but should be
- [[24850]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24850) Koha::DateUtils ignores offsets in RFC3339 datetimes

  >Prior to this patch our date handling library ignored offset data passed with rfc3339 dates. This could lead to problems if an API client converted to UTC or was in a different timezone to the Koha instance time setting.
  >
  >This patch adds proper handling to dt_from_string such that if an REF3339 date is input, we parse out the offset and then adjust the time to match the instance timezone for storage.
- [[26374]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26374) Update for 19974 is not idempotent
- [[28759]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28759) Users with pretty basic staff interface permissions can see/add/remove API keys of any other user
- [[28772]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28772) Any user that can work with reports can see API keys of any other user
- [[28881]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28881) Suggestion not displayed on the order receive page
- [[28929]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28929) No filtering on borrowers.flags on member entry pages (OPAC, self registration, staff interface)
- [[28935]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28935) No filtering on patron's data on member entry pages (OPAC, self registration, staff interface)
- [[28941]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28941) No filtering on suggestion at the OPAC
- [[28947]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28947) OPAC user can create new users
- [[29134]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29134) Patron search has poor performance when ExtendedAttributes enabled and many attributes match
- [[29135]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29135) OAI should not include biblionumbers from deleteditems when determining deletedbiblios

  **Sponsored by** *National Library of Finland*
- [[29139]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29139) Paying gives ISE if UseEmailReceipts is enabled
- [[29197]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29197) commit_file.pl missing import
- [[29243]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29243) PrepareItemrecordDisplay should not be called with empty string in defaultvalues
- [[29330]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29330) Koha cannot send emails with attachments using Koha::Email and message_queue table
- [[29386]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29386) background jobs table data field is a TEXT which is too small

### Authentication

- [[28489]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28489) CGI::Session is incorrectly serialized to DB in production env / when strict_sql_modes = 0

### Cataloging

- [[28676]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28676) AutoCreateAuthorities can repeatedly generate authority records when using Default linker and heading is cached
- [[28750]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28750) Undefined subroutines in svc/cataloguing/framework (caused by bug 17600)

  >This fixes an issue in master caused by bug 17600. This resulted in the advanced cataloguing editor failing to load.
- [[28812]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28812) Authority tag editor only copies $a from record to search form
- [[29137]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29137) Unwanted authorised values are too easily created via the cataloging module

### Circulation

- [[28538]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28538) Regression - Date of birth entered without correct format causes internal server error
- [[29221]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29221) On returns.tt modal displays wrong message when lost items are returned
- [[29255]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29255) Built-in offline circulation broken with SQL error
- [[29380]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29380) Auto renewing, batch due date extension tool and checkout note previews are broken
- [[29463]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29463) Umlauts in search field get changed into replacement character

### Command-line Utilities

- [[28994]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28994) Make writeoff_debts.pl use amountoutstanding, not amount
- [[29076]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29076) cleanup_database.pl dies of passed zebraqueue and not confirm

### Database

- [[28534]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28534) pending_offline_circulations table uses MyISAM engine

  >This updates the database structure for the pending_offline_operations table so that it uses the InnoDB engine instead of the MyISAM engine.
- [[28692]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28692) Reduce DB action_log table size

### Fines and fees

- [[28482]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28482) Floating point math prevents items from being returned

### Hold requests

- [[28057]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28057) Confusion of biblionumber and biblioitemnumber in request.pl
- [[28338]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28338) Validate item holdability and pickup location separately
- [[28496]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28496) Club holds form broken

  >This fixes the libraries shown in the 'Pickup at' dropdown list when placing a club hold so that it shows all libraries, instead of just the currently logged in library.
- [[28503]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28503) When ReservesControlBranch = "patron's home library" and Hold policy = "From home library" all holds are allowed
- [[28520]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28520) Cancelling a hold that is in transit hides item's transit status
- [[28748]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28748) When hold is overridden cannot select a pickup location
- [[29073]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29073) Hold expiration added to new holds when DefaultHoldExpirationdate turned off
- [[29148]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29148) Holds to Pull doesn't reflect item-level holds

### Notices

- [[28487]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28487) Overdue_notices does not fall back to default language

  >Previously overdue notices exclusively used the default language, but bug 26420 changed this to the opposite - to exclusively use the language chosen by the patron.
  >
  >However, if there is no translation for the overdue notice for the language chosen by the patron then no message is sent.
  >
  >This fixes this so that if there is no translation of the overdue notice for the language chosen by the patron, then the default language notice is used.
- [[28803]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28803) process_message_queue.pl dies if any messsages in the message queue contain an invalid to_address
- [[29223]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29223) Auto-renewals can fail when not digested per branch and patron requests digest
- [[29381]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29381) Auto-renewal digest messages are sent on every cron run

  >This fixes an issue with automatic renewal digest messages - these were being sent on every cron run, even if there was nothing to renew or no renewal errors.
  >
  >(This error was caused by a regression in 21.05 from Bug 18532: Add individual issues to digest notice and hide auto_renewals messaging preference when not needed.)

### OPAC

- [[28299]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28299) OpacHiddenItems not working in OPAC lists

  >This fixes an issue where items that should be hidden from display in the OPAC (using the rules in OpacHiddenItems, for example: damaged) were displayed under availability in OPAC lists.
- [[28462]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28462) TT tag on several lines break the translator tool
- [[28600]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28600) Variable "$patron" is not available
- [[28631]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28631) Holds History title link returns "not found" error
- [[28660]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28660) Self checkout is not automatically logging in
- [[28679]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28679) Unable to click "Log in to your account" when  GoogleOpenIDConnect  is enabled

  >This fixes the login link in the OPAC when GoogleOpenIDConnect is enabled. It removes modal-related markup which was causing the link to fail.
- [[28845]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28845) OpacAddMastheadLibraryPulldown does not respect multibranchlimit in OPAC_SEARCH_LIMIT
- [[28870]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28870) Cart shipping fails because of Non-ASCII characters in display-name of reply-to address
- [[28885]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28885) OpacBrowseResults can cause errors with bad search indexes
- [[29318]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29318) OverDrive search page should not require edit_borrowers permission
- [[29332]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29332) AdditionalContents displays blocks for every library prior to login
- [[29416]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29416) Regression: information from existing bib no longer populating on suggest for purchase

  >This restores the behaviour for purchase suggestions for an existing title, so that the suggestion form is pre-filled with the details from the existing record.

### Packaging

- [[28616]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28616) Remove Data::Printer dependency

### Patrons

- [[28490]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28490) Cannot modify patrons in some categories (e.g. Child category)
- [[29341]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29341) If OpacRenewalBranch = opacrenew, pseudonymization process leads to "internal server error" when patrons renew the loans at OPAC
- [[29524]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29524) Cannot set a new value for privacy_guarantor_checkouts in memberentry.pl

### Plugin architecture

- [[29121]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29121) Plugins with broken ->install prevent access to the plugins list

### REST API

- [[28585]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28585) Cannot search on date fields

  >This patch fixes the date handling for query parsing from the API.  We use dt_from_string to convert out RFC3339 formatted date strings to DateTime objects with an associated timezone and then user the native datetime formatted provided by the SQL connection library to convert to an appropriately formated date time string.
- [[28586]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28586) Cannot resolve a claim

  >This fixes an issue with the 'Returned claims' feature (enabled by setting a value for ClaimReturnedLostValue)- resolving returned claims now works as expected.
  >
  >Before this fix, an attempt to resolve a claim resulted in the page hanging and the claim not being able to be resolved.
- [[29032]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29032) ILL route unusable (slow)
- [[29272]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29272) API not respecting $category->effective_change_password

### Reports

- [[28523]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28523) Patrons with the most checkouts (bor_issues_top.pl) is failing with MySQL 8
- [[28524]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28524) Most-circulated items (cat_issues_top.pl) is failing with MySQL 8
- [[28804]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28804) 500 Error when running report with bad syntax
- [[29204]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29204) Error 500 when execute Circulation report with date period

### SIP2

- [[26871]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26871) L1 cache still too long in SIP Server

  >This fixes SIP connections so that when system preference and configuration changes are made (for example: enabling or disabling logging of issues and returns) they are picked up automatically with the next message, rather than requiring the SIP connection to be closed and reopened.
  >
  >SIP connections typically tend to be long lived - weeks if not months. Basically the connection per SIP machine is initiated once when the SIP machine boots and then never closed until maintenance is required. Therefore we need to reset Koha's caches on every SIP request to get the latest system preference and configuration changes from the memcached cache that is shared between all the Koha programs (staff interface, OPAC, SIP, cronjobs, etc).
- [[29264]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29264) SIP config allows use of non-branchcode institution ids causes workers to die without responding

  >This adds a warning to the logs where a SIP login uses an institution id that is *not* a valid library code.
  >
  >If a SIP login uses an institution with an id that doesn't match a valid branchcode, everything will appear to work, but the SIP worker will die anywhere that Koha gets the branch from the userenv and assumes it is valid.
  >
  >The repercussions of this are that actions such as the checkout message simply die and do not return a response message to the requestor.
- [[29564]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29564) Use List::MoreUtils so SIP U16/Xenial does not break

### Searching

- [[29152]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29152) Change to default search behavior when limiting by branch
- [[29374]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29374) searchResults explodes if biblio record has been deleted

### Searching - Elasticsearch

- [[29284]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29284) Koha dies when an analytics search fails in Elasticsearch

### Staff Client

- [[28236]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28236) Selecting database columns for system preferences in standard and dev installs is broken

  **Sponsored by** *Koha-Suomi Oy*

  >This fixes Apache access to json files in koha-tmpl for non-package installs. This causes issues for system preferences where there is a pick list for database columns.
  >
  >Bug 22844 introduced a pick list of database columns for system preferences where such a list was required. This list is in a plain json file under the templates directory. This works fine for packages, but because of bug 9812 (which limited browser access to selected files) those directories are not accessible to the outside world for both standard and dev type installs using the make process.
- [[28573]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28573) Replace authority record with Z39.50/SRU creates new authority record
- [[28872]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28872) AcquisitionLog, NewsLog, NoticesLog should use 1/0 for their values
- [[28986]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28986) Parent itemtype not selected when editing circ rules
- [[29193]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29193) DataTables only showing 20 results on checkout search and patrons search on request.pl
- [[29240]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29240) Flatpickr - error in the console when a date is selected
- [[29241]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29241) Flatpickr not displaying date in the past for futuredate
- [[29500]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29500) Flatpickr accepting original date in the past for futuredate but also other dates in the past

### System Administration

- [[28729]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28729) Return-path header not set in emails

### Templates

- [[29477]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29477) flatpickr default time should be 23:59 (11:59 pm as well, probably), not 12:00

  >This fixes the flatpickr default time defaulting to 12:00 instead of 23:59, which was an unexpected change in behaviour caused by the flatpickr switch.
- [[29478]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29478) flatpickr misses quick shortcut to "Today" date

  >This adds shortcuts to yesterday, today and tomorrow for the flatpickr date selector.

### Test Suite

- [[29368]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29368) Zebra index not correctly mocked from tests

### Tools

- [[28717]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28717) NewsLog doesn't work

  >This patch fixes a regression in the NewsLog caused by Bug 28718.
- [[28745]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28745) Batch item modifications no longer displayed modified items
- [[28758]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28758) Undefined subroutines in C4/ImportBatch.pm (bug 17600)
- [[29019]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29019) Unable to delete HTML customization
- [[29113]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29113) New "code" field for additional contents is not useful for the end users
- [[29387]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29387) BatchUpdateBiblio does not handle exception correctly
- [[29469]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29469) Error when approving and rejecting tags
- [[29567]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29567) Cataloguing plugins are broken on the batch item mod tool

### translate.koha-community.org

- [[29261]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29261) Translation script breaks members/tables/members_results.tt


## Other bugs fixed

(This list includes all bugfixes since the previous major version. Most of them
have already been fixed in maintainance releases)

### About

- [[28476]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28476) Update info in docs/teams.yaml file
- [[28904]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28904) Update information on Newsletter editor on about page
- [[29123]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29123) Add Dataly Tech to About page
- [[29300]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29300) Release team 22.05

### Acquisitions

- [[27708]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27708) Cannot create EDI order if AcqCreateItem value is not "placing an order"
- [[28079]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28079) Set focus to search box field when adding an order to basket
- [[28408]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28408) Last modification date for suggestions is wrong
- [[28627]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28627) Revert the order receive page to display 'Actual cost' as ecost_tax_included/ecost_tax_excluded if unitprice not set
- [[28956]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28956) Acquisitions: select correct default tax rate when receiving orders

  **Sponsored by** *Catalyst*
- [[29429]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29429) Cannot close budgets

### Architecture, internals, and plumbing

- [[28373]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28373) Items fields not used in default XSLT

  >When processing records for display we loop through each field in the record and translate authorized values into descriptions. Item fields in the record contain many authorised values, and the lookups can cause a delay in displaying the record. If using the default XSLT these fields are not displayed as they exist in the record, so parsing them is not necessary and can save time. This bug adds a system preference that disables sending these fields for processing and thus saving time. Enabling the system preference will allow users to pass the items to custom style sheets if needed.
- [[28409]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28409) Category should be validated in opac-shelves.pl
- [[28561]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28561) Order_by triggers a DBIx warning Unable to properly collapse has_many results
- [[28570]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28570) bor_issues_top.pl using a /tmp file to log debug
- [[28571]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28571) C4::Auth::_session_log is not used and must be removed
- [[28620]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28620) Remove trailing space when logging with log4perl
- [[28622]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28622) Selected branchcode incorrectly passed to adv search
- [[28734]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28734) Koha::Biblio->get_marc_notes should parse authorised values

  **Sponsored by** *Catalyst*
- [[28744]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28744) Class with empty/no to_api_mapping should generate an empty from_api_mapping
- [[28763]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28763) Undefined subroutine XSLTParse4Display (bug 17600)
- [[28776]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28776) Warns from GetItemsInfo when biblio marked as serial
- [[28931]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28931) use EXPORT_OK in Koha::DateUtils
- [[28992]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28992) Resolve warning from undefined BIG_LOOP
- [[29111]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29111) Remove dead code from intranet
- [[29175]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29175) finishreceive: Replace , by ;
- [[29177]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29177) Remove TODO in acqui/finishreceive.pl
- [[29179]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29179) Useless include in moveitem.pl
- [[29182]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29182) ArticleRequest status changing methods calling SUPER::store
- [[29207]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29207) Restore Getopt::Long config to not ignore cases
- [[29218]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29218) "hidden" class is not working for DT if column visibility button is used
- [[29321]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29321) Remove a last without loop context
- [[29350]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29350) TT method 'delete' don't need to be escaped
- [[29395]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29395) Use EXPORT_OK in Koha::Patron::Debarments
- [[29408]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29408) The datatables api wrapper is ambiguously named

  >This patch 1) renames the Koha REST JS dataTables wrapper from the
  >ambiguous 'api' to the clearer 'kohaTable' 2) goes through the codebase and updates existing relevant calls to .api referencing the Koha REST dataTables wrapper to use the name 'kohaTable', and 3) adds JSDoc formatted parameter documentation for the kohaTable function.
- [[29427]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29427) Debug mode not honoured in SMTP transport

  >The debug flag on the SMTP servers configuration was not being used correctly. This patch implements the expected behavior.
  >
  >Note: Enabling this will lead to lots of logging for each SMTP connection Koha does.

### Authentication

- [[28914]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28914) Wrong wording in authentication forms

### Cataloging

- [[27461]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27461) Fix field 008 length below 40 positions in cataloguing plugin
- [[28022]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28022) MARC subfield 9 not honoring visibility
- [[28171]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28171) Serial enumeration / chronology sorting is broken in biblio page
- [[28204]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28204) Table highlighting is broken at the cataloguing/additem.pl
- [[28383]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28383) Log in via the itemsearch URL leads to Internal Server Error

  >When trying to access the item search form in the staff interface (/cgi-bin/koha/catalogue/itemsearch.pl) when not logged in, an internal server error (error code 500) is received after entering your login details. This fixes the problem so that the item search form is displayed as expected.
- [[28513]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28513) Analytic search links formed incorrectly
- [[28533]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28533) Requesting whole field in 'itemcallnumber' system preference causes internal server error
- [[28542]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28542) Move new authority from Z39.50/SRU to a button

  >This makes the layout for creating new authorities consistent with creating new records - there is now a separate button 'New from Z39.50/SRU' (rather than being part of the drop-down list).
- [[28611]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28611) Incorrect Select2 width
- [[28727]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28727) "Edit item" button on moredetail should be enabled with edit_items permission
- [[28828]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28828) Bug 22399 breaks unimarc_field_4XX.tt and marc21_linking_section.tt value builders
- [[28829]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28829) Useless single quote escaping in value_builder/unimarc_field_4XX.pl
- [[29030]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29030) Problems introduced by bug 25728
- [[29146]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29146) Default values from the framework should only be applied at biblio/item creation

  >This patch makes Koha no longer apply default values to empty fields in an existing biblio record in the regular cataloguing editor. Same for item editor.
- [[29319]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29319) Errors when doing a cataloging search which starts with a number + letter

  >This fixes an error that occurs in cataloging search when entering a search term with ten characters (like "7th Heaven" or "2nd editio") - Koha thinks you are entering an ISBN10 number, gets confused and delivers an error page. Searching now works as expected for ISBN13/ISBN10 (without the '-'s), title and author searches.
- [[29437]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29437) 500 error when performing a catalog search for an ISBN13 with no valid ISBN10

### Circulation

- [[15812]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15812) Checkout search with too many results (single character search)  causes poor performance or timeout

  >This patch replaces the special case patron results page from circulation searches and instead redirects to the standard patron search results page.
  >
  >To enable quick onward navigation to checkout, we add a link to the cardnumber field and a button to the actions column.
- [[21093]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21093) Specified due date incorrectly retained when using fast add
- [[25619]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25619) Updating an expiration date for a waiting hold won't save
- [[27064]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27064) Transferring an item with a hold allows the user to set a hold waiting without transferring to the correct branch
- [[27279]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27279) "Checked out by" not populated on issuehistory.pl
- [[27847]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27847) Don't obscure page when checkin modal is non-blocking
- [[28271]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28271) Add the ability to set a new lost status when a claim is resolved
- [[28382]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28382) 'Reserve' should be passed through as transfer reason appropriately in branchtransfers
- [[28455]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28455) If TrackLastPatronActivity is enabled we should update 'lastseen' field on checkouts

  >This updates the 'lastseen' date for a patron when items are checked out (when TrackLastPatronActivity is enabled). (The last seen date is displayed on the patron details page.)
- [[28653]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28653) Sorting loans by due date doesn't work after renewing

  **Sponsored by** *Koha-Suomi Oy*
- [[28774]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28774) Warnings from GetIssuingCharge when rental discount is not set

  >This fixes the cause of warning messages in the log files when the rental discount in the circulation rules has a blank value. 
  >
  >Before this fix, multiple warning messages "[2021/07/28 12:11:25] [WARN] Argument "" isn't numeric in subtraction (-) at /kohadevbox/koha/C4/Circulation.pm line 3385." appeared in the log files. These warnings occurred for items checked out where they had rental charges and the rental discount value in the circulation rules was blank.
- [[28850]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28850) Clarify wording on AllFinesNeedOverride system preference

  >This clarifies the wording for the AllFinesNeedOverride system preference. If set to 'require', checkouts are blocked when using the web-based selfcheck and SIP.
- [[28891]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28891) RecordStaffUserOnCheckout display a new column but default sort column isn't changed
- [[28985]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28985) Negative rental amounts can be saved but not enforced
- [[29026]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29026) Behavior change when an empty barcode field is submitted in circulation
- [[29411]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29411) Single result for checkout search by name should redirect to check out tab

### Command-line Utilities

- [[28352]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28352) Errors in search_for_data_inconsistencies.pl relating to authorised values and frameworks
- [[28399]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28399) batchRebuildItemsTables.pl error 'Already in a transaction'
- [[28749]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28749) All backups behave as if --without-db-name is passed
- [[29078]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29078) Division by zero in touch_all scripts
- [[29216]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29216) Correct --where documentation in update_patrons_category.pl

### Documentation

- [[28636]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28636) t:lib::Mocks is missing POD

### Fines and fees

- [[26760]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26760) Redirect to paycollect.pl when clicking on "Save and pay"
- [[28344]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28344) One should be able to issue refunds against payments that have already been cashed up.
- [[29309]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29309) 'Pay all fines' should be 'Pay all charges'

### Hold requests

- [[3142]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=3142) Standardize how OPAC and staff determine requestability
- [[7703]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7703) Don't block bulk hold action on search results if some items can't be placed on hold
- [[27885]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27885) Populate biblionumbers parameter when placing hold on single title
- [[28510]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28510) Skip processing holds queue items from closed libraries when HoldsQueueSkipClosed is enabled
- [[28644]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28644) Can't call method "borrowernumber" on an undefined value at C4/Reserves.pm line 607
- [[28754]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28754) C4::Reserves::FixPriority creates many warns when holds have lowestPriority set
- [[28779]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28779) Calling request.pl with non-existent biblionumber gives internal server error
- [[28972]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28972) Add missing foreign key constraints to holds queue table
- [[29049]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29049) Holds page shows too many priority options in pulldown
- [[29355]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29355) Pickup location list limited by RESTdefaultPageSize syspref
- [[29356]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29356) Search for pickup library when placing a hold should be truncated in both directions

### I18N/L10N

- [[28898]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28898) Context for translation: term (word) vs. term (semester)

  >This disambiguates and provides a hint for translating the term "term" used in course reserves, where the meaning is "semester" rather than something like search term. This allows it to be translated, rather than having to use JQuery to change the text displayed for languages other then English.

### ILL

- [[22614]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22614) Request migration from one backend to another should not create new request

### Installation and upgrade (web-based installer)

- [[29158]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29158) Web installer fails to load account_offset_types.sql

### Label/patron card printing

- [[25459]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25459) In patron cards layout, barcode position doesn't respect units
- [[28940]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28940) IntranetUserJS is called twice on spinelable-print.tt

### Lists

- [[28673]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28673) An encoded ampersand missing the ampersand

### MARC Authority data support

- [[24698]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24698) UNIMARC authorities leader plugin
- [[29334]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29334) Do not apply framework defaultvalue to existing authority records

  >This fixes an issue where the default value for a field in a framework was being applied when records were edited, rather than only when first created.
- [[29435]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29435) OPAC authority details page broken when AuthDisplayHierarchy is enabled

### MARC Bibliographic data support

- [[10265]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10265) 8xx serial added entries need spaces and punctuation in XSLT display
- [[26852]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26852) Add missing X11$e and remove relator term subfields from MARC21 headings

  >This patch adds $e to 111 and 611, but removes it from 100 and 110 as it's used for the relator term there and should not be copied. Same for 111$j.

### Notices

- [[28263]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28263) AUTO_RENEWALS message for 'too_many' is wrong

  >This corrects the text in the AUTO_RENEWALS and AUTO_RENEWALS_DGST notices. These are sent when an item is setup for automatic renewal and can no longer be automatically renewed as the maximum number of renewals reached:
  >- Current wording: "You have reached the maximum number of checkouts possible."
  >- Updated wording: "You have reached the maximum number of renewals possible."
  >
  >For new installations the sample notices are updated. For existing installations the notices will be updated if they exist and haven't been changed.
- [[28581]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28581) Patron's queue_notice uses inbound_email_address incorrectly
- [[28582]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28582) Can't enqueue letter HASH(0x55edf1806850) at /usr/share/koha/Koha/ArticleRequest.pm line 123.
- [[28813]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28813) Fix recording and display of delivery errors for patron notices
- [[29460]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29460) Typo 'pendin    g approval'

### OPAC

- [[5229]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=5229) OPACItemsResultsDisplay preference must be removed
- [[20277]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20277) Link to host item doesn't work in analytical records if 773$a is present
- [[26223]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26223) The OPAC ISBD view does not display item information
- [[28242]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28242) Accessibility: OPAC - add captions and legends to tables and forms

  **Sponsored by** *Catalyst*

  >As part of improving OPAC accessibility this change ensures that all tables have relevant captions and all forms have relevant legends - this makes navigation easier for people using a screen reader.
  >
  >Note: Many of the captions and legends have class="sr-only" so they are not visible, but are available for people who use a screen reader.
- [[28313]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28313) Add street type to alternate address in OPAC
- [[28388]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28388) Search result set is lost when viewing the MARC plain view (opac-showmarc.pl)
- [[28422]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28422) OPAC MARC detail view doesn't correctly evaluate holdability

  >In the normal and ISBD detail views for a record in the OPAC the 'Place hold' link only appears if a hold can actually be placed. This change fixes the MARC detail view so that it is consistent with the normal and ISBD detail views. (Before this, a 'Place hold' link would appear for the MARC detail, even if a hold couldn't be placed, for example if an item was recorded as not for loan.)
- [[28469]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28469) Move "Skip to main content" link to top of page
- [[28511]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28511) Road types in OPAC should prefer OPAC description if one exists
- [[28518]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28518) "Return to the last advanced search" exclude keywords if more than 3
- [[28545]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28545) Noisy uninitialized warn at opac-MARCdetail.pl line 313

  >This removes "..Use of uninitialized value in concatenation (.) or string at.." warning messages from the plack-opac-error.log when accessing the MARC view page for a record in the OPAC.
- [[28569]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28569) In opac-suggestions.pl user library is not preselected
- [[28597]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28597) OPAC suggestions do not display news for logged in branch
- [[28662]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28662) Not possible to log out of patron account in OPAC with JavaScript disabled
- [[28741]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28741) OAI ListSets does not correctly build resumption token
- [[28764]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28764) Sorting not correct in pagination on OPAC lists
- [[28768]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28768) OPAC reading history page (opac-readingrecord.pl) wont display news items
- [[28784]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28784) DoS in opac-search.pl causes OOM situation and 100% CPU (doesn't require login!)
- [[28861]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28861) Item type column always hidden in holds history
- [[28868]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28868) Masthead.inc is missing class name

  >This patch adds back the class 'mastheadsearch' which was lost during the upgrade to Bootstrap 4 in Bug 20168.
- [[28901]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28901) showCart incorrectly calculates position if content above navbar
- [[28910]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28910) Correct eslint errors in OPAC basket.js
- [[28921]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28921) Many [WARN] Argument "" isn't numeric in numeric gt (>) at /home/koha/src/koha-tmpl/opac-tmpl/bootstrap/en/includes/html_helpers.inc line 23.
- [[28930]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28930) Cardnumber is lost if an invalid self registration form is submitted to the server, and the server side form validation fails
- [[28934]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28934) OPAC registration form design is not consistent
- [[29034]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29034) Accessibility: OPAC nav-links don't have sufficient contrast ratio
- [[29035]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29035) Accessibility: OPAC masthead_search label doesn't have sufficient contrast ratio
- [[29037]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29037) Accessibility: OPAC links don't have sufficient contrast
- [[29038]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29038) Accessibility: OPACUserSummary heading doesn't have sufficient contrast
- [[29064]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29064) OPAC duplicate "Most popular titles" in 'title' tag
- [[29065]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29065) Accessibility: OPAC clear search history link has insufficient contrast
- [[29067]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29067) Remove duplicate conditional statement from OPAC messaging settings title
- [[29068]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29068) Accessibility: OPAC search results summary text has insufficient contrast
- [[29070]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29070) Accessibility: OPAC Purchase Suggestions on search results page has insufficient contrast
- [[29091]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29091) Correct display of lists and tags on search results
- [[29126]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29126) Accessibility: More corrections to contrast in the OPAC
- [[29128]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29128) Trailing whitespace in Browse shelf link on opac-detail.tt
- [[29169]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29169) Wrong "daily limit" warning when article request is not available
- [[29172]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29172) Can't use controlfields with CustomCoverImagesURL
- [[29199]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29199) Classes in item availability on OPAC results no longer set correctly
- [[29329]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29329) stray "s" in opac-detail

### Packaging

- [[28926]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28926) Update cpanfile for Mojolicious::Plugin::OpenAPI v2.16

### Patrons

- [[18747]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18747) Select All in Add Patron Option in Patron Lists only selects the first 20 entries
- [[21794]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21794) Incomplete address displayed on patron details page when City field is empty
- [[27145]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27145) Patron deletion via intranet doesn't handle exceptions well
- [[28350]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28350) Sort by "circ note" is broken on the patron search result view

  >This fixes the patron search result page so that the results can be sorted using the 'Circ note' column. Before this fix you could not sort the results by this column.
- [[28392]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28392) streettype and B_streettype cannot be hidden via BorrowerUnwantedField
- [[28882]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28882) Incorrect permissions check client-side
- [[28973]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28973) Improve Koha::Patron::can_see_patron_infos efficiency
- [[29025]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29025) Saved auth login and password are pre-filled in patron creation form
- [[29213]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29213) Typo ol in member-alt-contact-style.inc
- [[29215]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29215) In patron form collapsing "Patron guarantor" display errors
- [[29227]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29227) Patron messaging preferences digest show as editable but are not
- [[29430]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29430) Table cell click doesn't activate buttons in patron search

### Plugin architecture

- [[28228]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28228) Warns from plugins when metadata value not defined for key
- [[28303]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28303) Having multiple pluginsdir causes plugin_upload to try to write to the opac-tmpl folder

### REST API

- [[28480]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28480) GET /patrons missing q parameters on the spec
- [[28604]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28604) Bad encoding when using marc-in-json
- [[28613]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28613) Several objects.search-based routes missing parameters
- [[28632]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28632) patrons.t fragile on slow boxes
- [[28842]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28842) Missing summary for /items/:item_id/pickup_locations
- [[28848]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28848) OpenAPI version should be a string
- [[29072]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29072) Move reference route /cities spec to YAML
- [[29157]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29157) Cannot set date/date-time attributes to NULL
- [[29405]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29405) The patron spec for date_renewed is missing it's format definition

  >This fix adds the date format string to the date_renewed field. This is to ensure that the date_renewed field can be correctly validated.

### Reports

- [[27884]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27884) Add HTML mail support for patron emailer script
- [[28264]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28264) Transaction type is empty in cash register statistics wizard report
- [[28349]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28349) Date sorting incorrect in some tables
- [[28731]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28731) Subroutines not explicitly imported in reports svc (opac and staff)
- [[29225]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29225) Report subgroup does not appear consistently
- [[29271]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29271) Cash register report not displaying or exporting correctly
- [[29279]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29279) Holds ratio report not sorting correctly
- [[29328]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29328) Add missing list parameter to reports parameter menu
- [[29351]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29351) Add missing cn_source parameter to reports parameter menu

  >This patch adds a link for the previously-hidden option of using a runtime parameter for selecting "Source of classification or shelving scheme." Now when composing an SQL report you can click the "Insert runtime parameter" button to see a menu that includes this option.
- [[29352]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29352) Runtime parameter labels should not be said to be optional

### SIP2

- [[27600]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27600) SIP2: renew_all shouldn't perform a password check
- [[27906]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27906) Add support for circulation status 9 ( waiting to be re-shelved )
- [[27907]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27907) Add support for circulation status 2 ( on order )
- [[27908]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27908) Add support for circulation status 1 ( other ) for damaged items
- [[28464]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28464) Cancelling a waiting hold via SIP returns a failed response even when cancellation succeeds
- [[29452]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29452) Unnecessary warns in sip logs

### Searching

- [[28365]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28365) (Bug 19873 follow-up) Make it possible to search on value 0
- [[28526]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28526) Impossible to search only zero
- [[28554]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28554) In itemsearch sort filters by description

  >For item search in the staff interface the shelving location and item type values are now sorted by the description, rather than the authorized value code.
- [[28826]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28826) Facet sort order differs between search engines
- [[28847]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28847) Branch limits while searching should be expanded in query building and not in CGI
- [[29138]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29138) LoadSearchHistoryToTheFirstLoggedUser should save 0 instead of "no"

### Searching - Elasticsearch

- [[22690]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22690) Merging records with many items too slow (Elasticsearch)

  >This enhancement significantly improves the performance when merging records with many items (for an installation using Elasticsearch). 
  >
  >Before this enhancement the web server would time out as the search engine was reindexing the origin record and the destination record for each item moving.
- [[22801]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22801) Advance search yr uses copydate instead of date-of-publication

  >This fixes the advanced search form in the OPAC and staff interface so that the publication date (and range) uses the value(s) in 008 instead of 260$c when using Elasticsearch.
- [[25030]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25030) IncludeSeeFromInSearches not honoured in Elasticsearch

  >Feature enabled by system preference IncludeSeeFromInSearches was implemented in Zebra search engine but not in Elasticsearch.
  >This feature allows in bibliographic searches to match also on authorities see from (non-preferred form) headings.
- [[28316]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28316) Fix ES crashes related to various punctuation characters
- [[28380]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28380) Elasticsearch - Correct 024aa in mappings (MARC21)

  >This corrects the MARC21 mapping for 024$a when using Elasticsearch: identifier-other now maps to 024a rather than 024aa (which is a typo).
- [[28484]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28484) Elasticsearch fails to parse query if exclamation point is in 245$a
- [[29010]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29010) Weight input pattern wrong

  **Sponsored by** *Steiermärkische Landesbibliothek*

### Searching - Zebra

- [[21286]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21286) Advanced search for Corporate-name creates Zebra errors

  >This fixes the advanced search in the staff interface so that searching using the 'Corporate name' index now works correctly when the QueryAutoTruncate system preference is not enabled. Before this a search (using Zebra) for a name such as 'House plants' would not return any results and generate error messages in the log files.
- [[27348]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27348) Error defining INDEXER_PARAMS in /etc/default/koha-common

### Self checkout

- [[28488]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28488) Javascript error in self-checkout (__ is not defined)

### Serials

- [[28719]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28719) Cannot edit serials when deleted the selected issues

### Staff Client

- [[20529]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20529) Return to results link is truncated when the search contains a double quote
- [[28467]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28467) Add wording to TrackLastPatronActivity description to tell users that it records SIP authentication

  >This improves the wording for the TrackLastPatronActivity system preference to reflect that the 'last seen' date updates when a patron logs into the OPAC or connects using SIP.
- [[28472]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28472) UpdateItemLocationOnCheckin not updating items where location is null
- [[28598]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28598) Changing date or time format on a production server will NOT create duplicate fines and we should remove the syspref warnings
- [[28601]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28601) Wrong breadcrumb for 'Home' on circulation-home

  >This fixes the breadcrumb link to the the staff interface home page from the circulation area - it now links correctly to the staff interface home page, rather than the circulation page.
- [[28722]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28722) tools/batchMod.pl needs to import C4::Auth::haspermission
- [[28728]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28728) Holds ratio page links to itself pointlessly
- [[28747]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28747) Clarify wording on RestrictionBlockRenewing syspref

  >This clarifies the wording for the RestrictionBlockRenewing system preference to make it clear that when set to Allow, it only allows renewal using the staff interface.
- [[28802]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28802) Untranslatable strings in browser.js
- [[28834]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28834) Improve wording biblios/authorities on tools home page
- [[28912]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28912) Pseudonymization should display a nice error message when brcypt_settings are not defined
- [[28913]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28913) Automatic checkin setting in item type setup should note required cronjob
- [[29062]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29062) Patron check-in slip repeats data
- [[29131]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29131) Row striping breaks color coding on item circulation alerts
- [[29195]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29195) Highlighting broken on odd rows in circ-patron-search-results
- [[29242]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29242) Flatpickr - Turn autocomplete off
- [[29244]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29244) alert/error and message dialogues should have the same width
- [[29459]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29459) Replace some missed datetimepickers in circulation templates with Flatpickr

### System Administration

- [[28567]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28567) Pick-up location is not saved correctly when creating a new library

  >This fixes an issue when adding a new library - the pick-up location was always saving as "Yes", even when no was selected.
- [[28704]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28704) Library MARCOrgCode field needs maxlength attribute

  >This fixes an error that occurs when you enter a "MARC organization code" in the form for adding and editing libraries. With this change the input field is limited to 16 characters.
- [[28859]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28859) Table Settings should control Checked out by field in Checkout history
- [[28936]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28936) Sort1 and Sort2 should be included in BorrowerUnwantedField and related sysprefs
- [[29004]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29004) Update GoogleOpenIDConnect preference to make it clear that it is OPAC-only

  >This improves the description of the GoogleOpenIDConnect and related preferences to make it clear that GoogleOpenIDConnect affects OPAC logins and that the preferences are related.
- [[29020]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29020) Missing Background jobs link in admin-home
- [[29056]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29056) Remove demo functionality remnants
- [[29075]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29075) OPAC info should not be displayed in libraries table
- [[29180]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29180) System preference RequestOnOpac should be renamed

  >System preference RequestOnOpac renamed to OPACHoldRequests. It could be confused with the 'Article Request' feature and does not follow Koha terminology - OPAC related system preferences normally start with OPAC.
- [[29200]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29200) Remove Adlibris cover service
- [[29298]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29298) "Managing library" missing from histsearch table settings
- [[29456]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29456) "Auto renewal" and "Hold reminder" notice shown as "unknown" on the patron category list view

### Templates

- [[27498]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27498) Add a link for the hold ratios to acquisitions home page

  >This enhancement adds a link to the hold ratios report in the Acquisitions sidebar menu under the reports heading.
- [[28149]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28149) Improve internationalization and formatting on background jobs page
- [[28280]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28280) Item types configuration page doesn't use Price filter for default replacement cost and processing fee

  >This fixes the display of 'Default replacement cost' and a
  >'Processing fee (when lost)' when adding item types so that amounts use two decimals instead of six.
- [[28423]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28423) JavaScript error on MARC modifications page

  >This patch makes a minor change to the MARC modifications template (Staff interface > Administration > MARC modification templates) so that the "mmtas" variable isn't defined if there is no JSON to be assigned as its value.
- [[28427]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28427) Terminology: Shelf should be list
- [[28428]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28428) Capitalization: Password Updated
- [[28438]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28438) Capitalization: Various corrections
- [[28441]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28441) Terminology: Reserve notes should be Hold notes
- [[28443]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28443) Terminology: Issuing should be Checking out
- [[28470]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28470) Typo: Are you sure you with to chart this report?
- [[28522]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28522) Correct eslint errors in staff-global.js
- [[28579]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28579) Typo: No record have been imported because they all match an existing record in your catalog.
- [[28689]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28689) Extra %s in alert message when saving an item

  >This removes an unnecessary %s in the alert message when there are errors in the cataloging add item form (for example when mandatory fields are not entered).
- [[28733]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28733) Desks link is in "Patrons and circ" section on admin homepage but in "Basic parameters" on the sidebar
- [[28825]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28825) Can't edit local cover image for item from details page
- [[28902]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28902) Grey color should be on label for record metadata

  >In record search or details, label is now with grey color (for example "Author:") and metadata with black color (for example "J.R.R Tolkien").
  >For both OPAC and staff interface.
- [[28927]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28927) Id opacmainuserblock used twice in OPAC

  >This patch removes redundant div with id 'opacmainuserblock' and 'opacheader' since there is already this id generated by HTML customization.
- [[28928]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28928) Minor follow-ups to Bug 28376 - Flatpickr introduction
- [[28938]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28938) Correct Flatpickr's default 12hr time formatting
- [[29112]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29112) Module navigation sidebars in staff now show bullet points
- [[29133]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29133) Wrong string format in select2.inc
- [[29232]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29232) Clean up obsolete jQueryUI datepicker code from cash register stats template
- [[29233]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29233) Correct missed jQueryUI datepicker in serials search sidebar
- [[29278]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29278) write_age function broken by Flatpickr conversion

  >This fixes the display of a patron's age in the staff interface after the date of birth field (for example: Age: 63 years 4 months). This was not displaying after the switch to Flatpickr for date entry on this page in the 21.11 release development cycle.
- [[29286]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29286) Typo: Librarien will need the manage_auth_values subpermission.
- [[29301]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29301) Display error with serials search flatpickr when searching Mana
- [[29394]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29394) Remove flatpickr instantiations from .tt files

### Test Suite

- [[27155]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27155) Include identifier test in Biblio_and_Items_plugin_hooks.t
- [[28479]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28479) TestBuilder.pm uses incorrect method for checking if objects to be created exists
- [[28483]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28483) Warnings from Search.t must be removed
- [[28509]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28509) Koha/Acquisition/Orders.t is failing randomly
- [[28516]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28516) Koha/Patrons/Import.t is failing randomly
- [[28873]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28873) Incorrect age displayed in db_dependent/Koha/Patrons.t

  >This fixes age tests in t/db_dependent/Koha/Patrons.t so that  the correct ages are calculated and displayed. It also adds the category code 'AGE_5_10' in messages to display age limits.
- [[29273]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29273) Warning not caught in tests for plugins
- [[29306]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29306) Holds.t: Fix Use of uninitialized value $_ in concatenation (.) or string
- [[29315]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29315) Remove warnings from Search.t
- [[29363]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29363) TestBuilder.t failing if biblionumber=123 does not exist
- [[29364]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29364) Search.t not reverting changes made to the framework
- [[29485]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29485) selenium/administration_tasks.t is failing randomly
- [[29565]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29565) selenium/regressions.t can fail on slow boxes

### Tools

- [[26205]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26205) News changes aren't logged
- [[27929]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27929) Regex option in item batch modification is hidden for itemcallnumber if 952$o linked to cn_browser plugin
- [[28191]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28191) Update wording on batch patron deletion to reflect changes from bug 26517
- [[28336]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28336) Cannot change matching rules for authorities
- [[28353]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28353) Regression: Batch item deletion no longer shows which items were not removed

  >This restores and improves the messages displayed when batch deleting items (Tools > Catalog > Batch item deletion).
  >
  >The messages displayed are:
  >- "Warning, the following barcodes were not found:", followed by a list of barcodes
  >- "Warning, the following items cannot be deleted:", followed by a list of barcodes
- [[28418]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28418) Show template_id of MARC modification templates
- [[28525]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28525) TinyMCE for system prefs does some automatic code clean up
- [[28718]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28718) Can't delete multiple news items at once
- [[28835]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28835) Ability to pass list contents to batch record modification broken
- [[29153]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29153) CodeMirror broken for news and HTML customizations
- [[29254]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29254) Setting wrong dates on additional-contents.pl
- [[29263]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29263) Return to Additional Contents listview after editing such an item

### Web services

- [[21105]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21105) oai.pl returns invalid earliestDatestamp

  **Sponsored by** *Reformational Study Centre*

  >This fixes the date format in OAI-PMH for Identify.earliestDatestamp so that it uses "YYYY-MM-DDThh:mm:ssZ" and is in UTC, instead of the SQL formsat "YYYY-MM-DD hh:mm:ss" currently used. For OAI-PMH all date and time values must be in the format "YYYY-MM-DDThh:mm:ssZ" and in UTC.

## New system preferences

- ArticleRequestsOpacHostRedirection
- ArticleRequestsSupportedFormats
- CleanUpDatabaseReturnClaims
- CreateAVFromCataloguing
- FacetOrder
- MARCOverlayRules
- MaxComponentRecords
- NewsLog
- OPACResultsMaxItems
- OPACResultsMaxItemsUnavailable
- OPACResultsUnavailableGroupingBy
- PassItemMarcToXSLT
- ShowComponentRecords

## Renamed system preferences

- RequestOnOpac => OPACHoldRequests
- NewsToolEditor => AdditionalContentsEditor

## Deleted system preferences

- AdlibrisCoversEnabled
- AdlibrisCoversURL
- HighlightOwnItemsOnOPAC
- HighlightOwnItemsOnOPACWhich
- OPACItemsResultsDisplay
- OpacNav (moved to HTML customizations)
- OpacNavBottoma (moved to HTML customizations)

## New Authorized value categories

- AR_CANCELLATION

## New letter codes

- AR_REQUESTED

## Technical highlights

Some significant technical changes were made behind the scenes in this release and it was felt that they should be additionally highlighted in the notes as they could be easily missed above.

### Perl modules

A new lib directory has been added for Perl modules.

This might requires some changes in your webserver configuration if you don't install Koha via the Debian packages. More details about these changes can be found on [bug 28519](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28519).

### Task queue

A fresh new task was added: batch cancel holds [[23678]](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23678)

The ongoing process of migrating forking scripts into proper jobs in the task queue has continued during this cycle.

Three tools have been moved to use the task queue this time:

- batch delete items
- batch update items
- batch delete records (biblios and authorities).

There has been an important change to the way we build the item form in the cataloguing module. The idea is to make the form and item list reusable from different other modules (acquisition, serials, etc.) [[27526]](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27526) [[28445]](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28445)

To prevent the background job worker to have the whole Koha modules in RAM we replaced the 'use' statements with 'require' [[28413]](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28413).

### Upgrade

The update database process has been refactored so each DBRev is run inside a database transaction. This makes the process more robust.

Also, a different format for atomic update has been adopted. It brings more flexibility for the output and make the code more centralized, robust and reusable [[25078]](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25078).

### Translation

Two new languages have been removed from the installer files: fr-CA [[27101]](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27101) and nb-NO [[27622]](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27622). Only fr-FR is remaining, the hardest given that it has the UNIMARC frameworks defined.

### Test suite

We added two selenium scripts to test the installer and onboarding steps [[19185](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19185) and [19821](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19821)].
The way Jenkins runs the whole test suite can be found at [here](https://gitlab.com/koha-community/koha-testing-docker/-/blob/master/files/run.sh).

The job 'Koha_Master' is the only one running the whole test suite (ie. with the 'selenium' and 'www' tests). First it recreates the database, runs 00-onboarding.t, recreates the database, runs 01-installer.pl, the other selenium scripts and finally the other test files in random order. You will see your tests failing on this job if you are relying on data injected by the misc4dev scripts used to build koha-testing-docker database.

### New plugin hooks

3 new plugin hooks have been added:

- Transform item barcodes [[26351]](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26351)
- Transform patron barcodes [[26352]](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26352)
- Act upon authority create, modify and delete actions [[27173]](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27173)

### REST API

New routes:

- GET /biblios/:biblio_id/checkouts [[29290]](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29290)
- GET /public/libraries [[28948]](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28948)
- GET /public/biblios/:biblio_id/items [[27358]](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27358)
- GET /suggestions [[17314]](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17314)
- POST /suggestions [[17314]](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17314)
- GET /suggestions/:suggestion_id [[17314]](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17314)
- PUT /suggestions/:suggestion_id [[17314]](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17314)
- DELETE /suggestions/:suggestion_id [[17314]](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17314)

#### Being able to specify which attributes to display at object level

A powerful addition to our API framework has been added this cycle. `Koha::Object->to_api` now handles a new parameter `is_public` that is used to determine the right output depending on the requested object profile. It relies internally on an allow-list to choose what attributes to return. It allows us to reuse existing controllers for public usage, and also provides a simple way to declare what attributes should be returned. Base classes need to implement a method called `public_read_list` that returns a list of allowed attributes.

The first two routes to use this new mechanism are:

- GET /public/biblios/:biblio_id/items
- GET /public/libraries

#### YAML spec

On the previous cycle the base file for the spec was migrated to YAML to ease the inclusion of Markdown documentation/examples so our API docs render nicely on our [API site](https://api.koha.community.org). New routes have been added as YAML during this cycle. Time constraints prevented us from moving the entire spec into YAML but it is scheduled to be done early next cycle.

#### Date-time and timezones handling

Prior to now our date handling library ignored offset data passed with rfc3339 dates. This could lead to problems if an API client converted to UTC or was in a different timezone to the Koha instance time setting. With this release we add proper handling to `dt_from_string` such that if an rfc3339 date is input, we parse out the offset and then adjust the time to match the instance timezone for storage.

Some better handling of exception cases is still in the works. Specially for cases our validation library version is not catching correctly [[29322]](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29322).

### UI

jQueryUI's timepicker has been replaced with Flatpickr [[29239]](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29239) in the staff interface.

### Debug

There were some historical ways of playing with a debug mode in Koha. They have been replaced in favor of `Koha::Logger->debug`

- Replace C4::Debug with Koha::Logger->debug [[28572]](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28572)
- debug passed to get_template_and_user but not used [[28591]](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28591)
- Replace $ENV{DEBUG} and $DEBUG with Koha::Logger->debug [[28606]](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28606)

### Others

We favored the use of EXPORT_OK over EXPORT, to prevent name clashes and make the import explicit [[17600]](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17600).
It basically means that the following is now incorrect:

```
use C4::Circulation;
AddIssue(@params);
```

You will now need to import explicitely the subroutine:

```
use C4::Circulation qw( AddIssue );
AddIssue(@params);
```

Note that you can still use the full namespace:

```
use C4::Circulation;
C4::Circulation::AddIssue(@params);
```

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/21.11/ar/html/) (43.3%)
- [Chinese (Taiwan)](https://koha-community.org/manual/21.11/zh_TW/html/) (100%)
- [Czech](https://koha-community.org/manual/21.11/cs/html/) (33.1%)
- [English (USA)](https://koha-community.org/manual/21.11/en/html/)
- [French](https://koha-community.org/manual/21.11/fr/html/) (70.6%)
- [French (Canada)](https://koha-community.org/manual/21.11/fr_CA/html/) (31.2%)
- [German](https://koha-community.org/manual/21.11/de/html/) (72.4%)
- [Hindi](https://koha-community.org/manual/21.11/hi/html/) (100%)
- [Italian](https://koha-community.org/manual/21.11/it/html/) (78.9%)
- [Spanish](https://koha-community.org/manual/21.11/es/html/) (58.5%)
- [Turkish](https://koha-community.org/manual/21.11/tr/html/) (70.2%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (87.4%)
- Armenian (99.3%)
- Armenian (Classical) (89%)
- Bulgarian (61.5%)
- Chinese (Taiwan) (79.8%)
- Czech (69.4%)
- English (New Zealand) (59.8%)
- English (USA)
- Finnish (83.1%)
- French (88.6%)
- French (Canada) (84.9%)
- German (100%)
- German (Switzerland) (59.3%)
- Greek (53.2%)
- Hindi (97.6%)
- Italian (90.7%)
- Nederlands-Nederland (Dutch-The Netherlands) (60.2%)
- Norwegian Bokmål (63.9%)
- Polish (98.3%)
- Portuguese (88.4%)
- Portuguese (Brazil) (84.7%)
- Russian (84.5%)
- Slovak (70.7%)
- Spanish (95.2%)
- Swedish (83.1%)
- Telugu (96.5%)
- Turkish (96.6%)
- Ukrainian (63.8%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 21.11.00 is


- Release Manager: Jonathan Druart

- Release Manager assistants:
  - Martin Renvoize
  - Tomás Cohen Arazi

- QA Manager: Katrin Fischer

- QA Team:
  - Agustín Moyano
  - Andrew Nugged
  - David Cook
  - Joonas Kylmälä
  - Julian Maurice
  - Kyle M Hall
  - Marcel de Rooy
  - Martin Renvoize
  - Nick Clemens
  - Petro Vashchuk
  - Tomás Cohen Arazi
  - Victor Grousset

- Topic Experts:
  - UI Design -- Owen Leonard
  - REST API -- Tomás Cohen Arazi
  - Elasticsearch -- Fridolin Somers
  - Zebra -- Fridolin Somers
  - Accounts -- Martin Renvoize

- Bug Wranglers:
  - Sally Healey

- Packaging Manager: 


- Documentation Manager: David Nind


- Documentation Team:
  - David Nind
  - Lucy Vaux-Harvey

- Translation Managers: 
  - Bernardo González Kriegel

- Wiki curators: 
  - Thomas Dukleth

- Release Maintainers:
  - 21.05 -- Kyle M Hall
  - 20.11 -- Fridolin Somers
  - 20.05 -- Victor Grousset
  - 19.11 -- Wainui Witika-Park

- Release Maintainer assistants:
  - 21.05 -- Nick Clemens

- Release Maintainer mentors:
  - 19.11 -- Aleisha Amohia

## Credits
We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 21.11.00

- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)
- [Centre collégial des services regroupés](http://www.ccsr.qc.ca)
- Gerhard Sondermann Dialog e.K. (presseplus.de, presseshop.at, presseshop.ch)
- Gothenburg University Library
- Halland County Library
- Koha-Suomi Oy
- Rijksmuseum
- National Library of Finland
- Orex Digital
- Reformational Study Centre
- Steiermärkische Landesbibliothek

We thank the following individuals who contributed patches to Koha 21.11.00

- Aleisha Amohia (6)
- Tomás Cohen Arazi (156)
- Alex Arnaud (1)
- Henry Bolshaw (8)
- Florian Bontemps (1)
- Jason Boyer (1)
- Jérémy Breuillard (2)
- Rudolf Byker (1)
- Colin Campbell (1)
- Nick Clemens (143)
- David Cook (4)
- Christophe Croullebois (1)
- Jonathan Druart (462)
- Marion Durand (1)
- Ivan Dziuba (2)
- Gus Ellerm (1)
- Magnus Enger (1)
- Victoria Faafia (3)
- Katrin Fischer (29)
- Andrew Fuerste-Henry (12)
- Lucas Gass (22)
- Didier Gautheron (5)
- Victor Grousset (1)
- David Gustafsson (7)
- Michael Hafen (1)
- Kyle M Hall (45)
- Andrew Isherwood (13)
- Mason James (3)
- Andreas Jonsson (2)
- Janusz Kaczmarek (2)
- Pasi Kallinen (1)
- Thomas Klausner (2)
- Joonas Kylmälä (52)
- Owen Leonard (137)
- Ava Li (2)
- Ere Maijala (3)
- Julian Maurice (14)
- Josef Moravec (16)
- Agustín Moyano (11)
- David Nind (1)
- Andrew Nugged (5)
- Hayley Pelham (3)
- Johanna Raisa (2)
- Martin Renvoize (142)
- Alexis Ripetti (3)
- Marcel de Rooy (92)
- Caroline Cyr La Rose (11)
- Andreas Roussos (5)
- Maryse Simard (2)
- Fridolin Somers (28)
- Arthur Suzuki (2)
- Emmi Takkinen (1)
- Lari Taskula (2)
- Petro Vashchuk (14)
- George Veranis (2)
- Bin Wen (1)
- Wainui Witika-Park (3)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 21.11.00

- Athens County Public Libraries (137)
- BibLibre (56)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (29)
- ByWater-Solutions (222)
- Catalyst (6)
- Catalyst Open Source Academy (6)
- Dataly Tech (7)
- David Nind (1)
- Equinox Open Library Initiative (1)
- Göteborgs Universitet (1)
- Hypernova Oy (2)
- Independant Individuals (73)
- Koha Community Developers (462)
- Koha-Suomi (1)
- KohaAloha (3)
- Kreablo AB (2)
- Libriotech (1)
- Prosentient Systems (4)
- PTFS-Europe (156)
- Rijksmuseum (92)
- Solutions inLibro inc (19)
- The City of Joensuu (1)
- Theke Solutions (167)
- UK Parliament (8)
- University of Helsinki (37)

We also especially thank the following individuals who tested patches
for Koha

- Azucena Aguayo (2)
- Hugo Agud (1)
- Salman Ali (4)
- Aleisha Amohia (1)
- Tomás Cohen Arazi (149)
- Donna Bachowski (1)
- Henry Bolshaw (1)
- Christopher Brannon (3)
- Jérémy Breuillard (1)
- Sara Brown (1)
- Alex Buckley (7)
- Assumpta Byrne (1)
- Barry Cannon (4)
- Nick Clemens (241)
- Rebecca Coert (3)
- David Cook (13)
- Holly Cooper (3)
- Ben Daeuber (1)
- Michal Denar (2)
- Christopher Kellermeyer - Altadena Library District (6)
- Jonathan Druart (1032)
- Marion Durand (1)
- Magnus Enger (1)
- Esther (1)
- Bouzid Fergani (7)
- Katrin Fischer (259)
- Andrew Fuerste-Henry (66)
- Lucas Gass (28)
- Victor Grousset (52)
- Amit Gupta (2)
- hakam (2)
- Kyle M Hall (106)
- Sally Healey (17)
- Mark Hofstetter (1)
- Abbey Holt (2)
- Andrew Isherwood (1)
- Barbara Johnson (10)
- Pasi Kallinen (10)
- Jon Knight (2)
- Joonas Kylmälä (88)
- Rasmus Leißner (7)
- Owen Leonard (84)
- Julian Maurice (4)
- Kelly McElligott (9)
- Christian Nelson (2)
- David Nind (284)
- Andrew Nugged (27)
- Hayley Pelham (5)
- Eric Phetteplace (3)
- Séverine Queune (5)
- Martin Renvoize (363)
- Phil Ringnalda (5)
- Marcel de Rooy (200)
- Caroline Cyr La Rose (3)
- Lisette Scheer (1)
- Julien Sicot (1)
- Fridolin Somers (13)
- Christian Stelzenmüller (5)
- Maura Stephens (2)
- Emmi Takkinen (15)
- Winfred Thompkins (1)
- Jill Tivey (1)
- Petro Vashchuk (16)
- Lucy Vaux-Harvey (3)
- Benjamin Veasey (2)
- George Veranis (13)
- Ronald Wijlens (1)
- George Williams (3)
- Wainui Witika-Park (1)

We thank the following individuals who mentored new contributors to the Koha project

- Andreas Roussos


And people who contributed to the Koha manual during the release cycle of Koha 21.11.00

- Caroline Cyr La Rose (4)
- Heather Hernandez (8)
- Martin Renvoize (5)
- Erica Rohlfs (2)
- Lucy Vaux-Harvey (3)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Notes from the Release Manager

It was a pleasure to serve one more time as release manager, this version of Koha is the best one so far, enjoy it!

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 21.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 25 nov. 2021 15:10:01.
