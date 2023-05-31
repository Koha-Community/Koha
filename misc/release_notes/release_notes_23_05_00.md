# RELEASE NOTES FOR KOHA 23.05.00
31 May 2023

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 23.05.00 can be downloaded from:

- [Download](http://download.koha-community.org/koha-23.05-latest.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 23.05.00 is a major release, that comes with many new features.

It includes 26 new features, 145 enhancements, 701 bugfixes.

## System requirements

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).

## New features & Enhancements

### Acquisitions

#### New features

- [8179](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8179) Receiving multiple order lines at once

  **Sponsored by** *Virginia Polytechnic Institute and State University*
  >This development changes the order receive page so multiple orders can be selected and processed at once.
  >
  >Selected orders can be browsed using the added 'Next order' and 'Previous order' buttons.
  >
  >After editing each order, without reloading the page or having to search for them again, a convenient 'Confirm' button allows us to receive all orders at once.
  >
  >This opens the door for new enhancements like adding default actions on all selected orders, etc.
- [11844](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11844) Additional fields for order lines
  >This adds the option to add additional user defined fields to the order lines in the acquisition module. The fields can be set up as free text fields or pull down lists driven by authorised values. They can also pull information from the MARC record or allow you to create and edit a field in the MARC record.
- [33103](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33103) Add vendor aliases
  >This allows to create aliases for a vendor. The aliases can be former names or different spellings of the name. Once added they will display on the vendor detail page. And they will be included in search when searching by a vendor's name.
- [33104](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33104) Add vendor interfaces
  >This adds the ability to create interfaces for vendors.
  >An interface is a website, software, or portal that you use to manage orders or gather statistics from the vendor or organisation. Interfaces can also include usernames and passwords, that will be encrypted for storage, but can be decrypted and made visible in the staff interface.
  >The type of an interface can be set using the `VENDOR_INTERFACE_TYPE` authorised values category.

#### Enhancements

- [25655](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25655) Additionally store actual cost in foreign currency and currency from the invoice

  **Sponsored by** *The Research University in the Helmholtz Association (KIT)*
  >When receiving an item with a price in a foreign currency, you already had the option to calculate the price in the active currency, but the original price and currency were not stored. They will now be stored in `invoice_unitprice` and `invoice_currency` in the `aqorders` table.
- [29935](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29935) Add option to search in archived suggestions to all search tabs
  >This adds a checkbox 'Include archived' to all of the search filter tabs for suggestions in the staff interface.
- [32452](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32452) Link basket group name from basket summary page
  >Adds a link to the basket group page from the basket summary page.
- [32705](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32705) Display actual cost in foreign currency and currency from the invoice

  **Sponsored by** *The Research University in the Helmholtz Association (KIT)*
  >The original price of an order in a foreign currency and the currency will now display on the invoice summary page.
- [33098](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33098) Revert suggestion status to 'Accepted' when orders made from a suggestion are cancelled

  **Sponsored by** *Waikato Institute of Technology*
  >This enhancement will revert the status of a suggestion from `ORDERED` to `ACCEPTED` when an order made from a suggestion is cancelled.
- [33340](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33340) Correct formatting of English 1-page order PDF when the basket group covers multiple pages

  **Sponsored by** *Pymble Ladies' College*
  >If a basket group contains many order lines, this will ensure:
  > * The page number at the bottom of the first page is not obscured.
  > * The table of ordered items does not start half way down the second page.
- [33541](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33541) Show 'Document type' in list of suggestions when creating an order from a suggestion
  >The 'Document type' of a suggestion will now be visible in the list of accepted suggestions when creating a new order line. This is to help with ordering the right material type and also for picking the correct item type.
- [33785](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33785) A couple more UI changes related to Bug 8179

### Architecture, internals, and plumbing

#### Enhancements

- [30310](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30310) Replace Moment.js with Day.js
- [30943](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30943) Make background job classes use helpers
- [31095](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31095) Remove Koha::Patron::Debarment::GetDebarments and use $patron->restrictions in preference

  **Sponsored by** *PTFS Europe*
- [31735](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31735) Avoid re-fetching objects from database by passing them down instead of object ids

  **Sponsored by** *Gothenburg University Library*
- [32013](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32013) Autorenewals is effectively a bulk action and should be treated as such

  **Sponsored by** *PTFS Europe*
- [32609](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32609) Remove compiled files from src
  >This important architectural change removes the built CSS and JavaScript files from source control and introduces a build process and trigger into our packaging routines.  
  >This will both save space in the repository and lead to less mistakes from developers by dropping the need to build, add and commit these files at release time.
- [32806](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32806) Some Vue files need to be moved for better reusability
  >This is an important architectural improvement to aid in future maintenance and expansion of the Vue based modules (erm) not available in Koha.
- [32939](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32939) Have generic fetch functions in vue modules
- [32991](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32991) Improve our Dialog component and remove routes for deletion
- [33066](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33066) We need a KohaTable Vue component
- [33070](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33070) Get rid of Koha::Patron->can_edit_item and use can_edit_item_from instead
- [33080](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33080) Add helpers that return result_set for further processing
- [33083](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33083) Handle generic collection of records methods
- [33289](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33289) Vue - Add API client class to interact with svc/config/systempreferences

  **Sponsored by** *Bibliothèque Universitaire des Langues et Civilisations (BULAC)*
- [33567](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33567) Remove fallback for Reference_NFL_statuses in C4/XSLT module
- [33625](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33625) Enforce formatting on vue .js and .ts files

### Cataloging

#### New features

- [20256](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20256) Add ability to limit editing of items to home library or library group

  **Sponsored by** *CLiC (Colorado Library Consortium)*
  >  
  >This adds the ability to limit item editing to staff users from libraries within a specific library group. This is done via a new option when creating item groups. There is also a new system preference `edit_any_item` that permits users to edit all items on a record independent of the library groups and their own home library.
- [31123](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31123) Add a simple way to add 'Harmful content warnings' to catalogue records

  **Sponsored by** *Tavistock & Portman Library*
  >
  >This new feature allows librarians to pick a note field to use to store 'Content warnings' about biblio records.
  >
  >The new `ContentWarningField` system preference can be set to any MARC field, though for MARC21 an 59X is recommended.  One can add said field to the frameworks and it will be displayed appropriately with the label 'Content warning:' in OPAC and staff interface on both detail and results pages.  We hide subfield x from the OPAC as it is often used as a 'private note' in other note fields and we also handle turning the content of a 'u' subfield into a clickable link if you wish to use that. Other subfields as just displayed in line when present.

#### Enhancements

- [23656](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23656) Add search box at the top of the cataloging editor page
  >This adds the search header to the cataloging editor page. With the recent staff interface redesign, this takes up very little space.
- [30358](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30358) Strip leading/trailing whitespace characters from input fields when cataloguing

  **Sponsored by** *Catalyst* and *Educational Services Australia SCIS*
  >This adds a new system preference `StripWhitespaceChars` which, when enabled, will strip leading and trailing whitespace characters from all fields when cataloguing both bibliographic records and authority records. Whitespace characters that will be stripped are:
  > * spaces
  > * newlines
  > * carriage returns
  > * tabs
- [30930](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30930) Ability to change authority type while editing record

  **Sponsored by** *Education Services Australia SCIS*
  >This adds the ability to change the MARC authority type/framework used while editing an authority record.
- [31212](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31212) Datelastseen should be a datetime
  >This moves the last seen date in `items.datelastseen` from a date to a datetime, meaning that now not only the date, but also the time will be recorded.
- [32680](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32680) Add hooks to allow cover images to be provided by plugins

  **Sponsored by** *PTFS Europe*
- [33365](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33365) Add item type column to call number browser's results table
  >This adds a new column for the item type to the results list of the cn_browser.pl value builder that can be linked to the subfield for the callnumber.

### Circulation

#### Enhancements

- [25503](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25503) Add option to export items bundle contents in checkouts table
- [25856](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25856) Suspended holds should be styled differently on request.pl
- [30403](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30403) Update notforloan status also on check out

  **Sponsored by** *Koha-Suomi Oy*
- [30642](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30642) We should record the renewal type (automatic/manual)

  **Sponsored by** *PTFS Europe*
  >
  >This ensures that the type of a renewal, automatic or manual, is stored in the new column `renewal_type` of the `checkout_renewals` table.
- [30963](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30963) Automatically refresh the curbside pickups list

  **Sponsored by** *Association KohaLa*
- [31557](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31557) Add ability for holds queue builder to prioritize either matching a patron's home library to the item's home or holding library
- [31615](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31615) Allow checkin of items bundles without verifying their contents
  >This enhancement adds the possibility to skip the content verification step when checking in a bundle.
- [32134](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32134) Show the bundle size when checked out
- [32373](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32373) Show date of restriction on patron screen

  **Sponsored by** *PTFS Europe*
  >
  >This enhancement adds the date a restriction was added to patron restriction messages, for example: "Restricted since 31/12/2022: Patron's account is restricted until 31/12/2022 with the explanation:...".
- [33246](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33246) itemBarcodeFallbackSearch search results should show whether or not items are available
  >This adds a label 'Checked out' to the result list of items when using `itemBarcodeFallbackSearch`.

### Command-line Utilities

#### Enhancements

- [23924](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23924) Add a parameter to the script add_date_fields_to_marc_records.pl to specify a date field
- [30069](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30069) Add edifact_messages to cleanup_database.pl

  **Sponsored by** *PTFS Europe*
- [31453](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31453) Add ability to filter messages to process using process_message_queue.pl via a command line parameter
- [32518](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32518) Add reason option to cancel_unfilled_holds
- [32686](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32686) Specify action of action_logs entries to purge
- [33360](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33360) SendQueuedMessages: Improve limit behavior and add domain limits
  >In order to control/throttle the volume of mail messages sent by Koha, this report makes the limit parameter of process_message_queue (and associated routine in Letters) look at the number of messages actually sent, not processed. It also adds the possibility of delaying messages to specified domains according to limits defined in koha-conf.xml (see example section added in this patch set). For instance, you may define that each minute only 30 messages are sent to outlook.com or 50 messages per hour to gmail.com, etc. This will help in reducing deferred or rejected mails due to exceeding limits of various email providers.

### Database

#### Enhancements

- [32334](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32334) Sync comments in database with schema

### ERM

#### Enhancements

- [32924](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32924) Filter agreements by logged in librarian
- [32925](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32925) Display loading info when a form is submitted
  >This gives the end user more visual feedback when a form is submitted in eRM.
- [33064](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33064) Add a search option for licenses to top search bar

  **Sponsored by** *PTFS Europe*
- [33466](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33466) Link vendor name in list of licenses

### Fines and fees

#### Enhancements

- [31448](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31448) Add option to re-send email receipt when UseEmailReceipts is enabled

  **Sponsored by** *PTFS Europe*
- [32450](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32450) Make it possible to exclude debit types from charges counted for circulation restriction (noissuecharge)

  **Sponsored by** *PTFS Europe*
  >
  >This enhancement allows a user to select which debit types should be included in deciding whether a patron should be restricted from checkouts (`noissuescharge` system preference). Three existing system preferences have been deleted (`ManInvInNoissuesCharge`, `RentalsInNoissuesCharge`, `HoldsInNoissuesCharge`) and the management of the debit types now sits in the Debit Types area of system preferences. The user can edit each debit type and select whether it should be included in the `noissuescharge` calculation, giving users much more flexibility over restrictions.
- [32977](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32977) Add call number column to list of charges on transactions tab in patron account
  >This enhancement adds the item call number to the 'transactions' and 'make a payment' tabs in the patron's account, if the charge is linked to a particular item.
  >
  >If needed, it is possible to hide this column by going to Administration > Table settings > Patrons > Page: fines >
  >Table id: account-fines or Administration > Table settings > Patrons > Page: pay > Table id: pay-fines-table.

### Hold requests

#### Enhancements

- [32421](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32421) Add collection ( ccode ) column to holds to pull
  >This enhancement removes an inconsistency in the holds to pull display by adding collection code to the displayed columns.

### ILL

#### Enhancements

- [21548](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21548) Make ILL patron category in koha-conf.xml match with ILL patron category in sample data

  **Sponsored by** *PTFS Europe*
  >
  >This makes sure, that in the future the Inter-Library Loan (IL) patron category of the sample data matches the default configuration of the ILL patron category in the `koha-conf.xml` file.
- [32546](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32546) Move ILL system preferences to their own tab in administration
- [32548](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32548) Make illrequestattributes easily available to ILL notices

### Installation and upgrade (web-based installer)

#### Enhancements

- [33128](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33128) Add Polish translations for language descriptions

### Lists

#### Enhancements

- [30418](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30418) Add permission and setting for public lists to allow staff with permission to edit contents

  **Sponsored by** *Catalyst*
  >Add a new 'Permitted staff only' option to public lists, allowing only permitted staff users to manage the list contents from the staff client and OPAC.
  >
  >The 'Permitted staff only' option differs from the 'Staff only' option because permitted staff are Koha patrons with the 'catalogue' permission enabled and the new 'edit_public_list_contents' sub-permission enabled.
- [32173](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32173) Add count of total titles in list to staff interface
  >With this the number of entries on a list will show in the detail page of a list in the staff interface.
- [32434](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32434) Records in lists not showing what other lists they belong to

### MARC Bibliographic data support

#### Enhancements

- [29185](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29185) Show MARC21 tag 765 - Original Language Entry

### Notices

#### Enhancements

- [3150](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=3150) Move emails for sending cart and list contents into notices tool

  **Sponsored by** *Bibliotheksservice-Zentrum Baden-Württemberg (BSZ)*
  >This patch creates notices using Template Toolkit syntax for sending emails containing cart (named CART) and list (named LIST) contents. This provides libraries more flexibility around what the emails contain and means they can be more translatable.
- [23773](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23773) Send MEMBERSHIP_EXPIRY notice by SMS

  **Sponsored by** *Médiathèque de Montauban*
- [29100](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29100) Add checkouts data loop to predue/due notices script (advance_notices.pl)
- [30555](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30555) Add more sample notice for SMS messages
- [31858](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31858) TT syntax for ACQORDER notices
- [33203](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33203) Overdue notice/status triggers letter selection is ambiguous

### OPAC

#### New features

- [31028](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31028) Add 'Report a concern' feature for patrons to report concerns about catalog records

  **Sponsored by** *Tavistock & Portman Library*
  >
  >This brings a new catalog concerns feature to the OPAC and staff interface, allowing non-cataloguers to report issues with catalog records from the record details pages.
  >
  >Reported concerns will be visible in the dashboard on the staff interface start page and available from the cataloguing home page.
  >
  >The feature can be independently enabled for OPAC and staff interface using the `OpacCatalogConcerns` and `CatalogConcerns` system preferences.
- [31051](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31051) Show patron's 'savings' on the OPAC

  **Sponsored by** *Horowhenua Libraries Trust*
  >This new feature shows a patron how much they have saved by using the library rather than purchasing items. Savings are calculated based on item replacement prices. The system preference allows you to choose where to display the savings - the user page, the summary box on the OPAC homepage, or the checkout history page.

#### Enhancements

- [12029](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12029) Patrons should be able to delete their patron messages

  **Sponsored by** *Koha-US*
  >This enhancement adds the ability for patrons to dismiss an OPAC message, marking it as read to remove it from their summary page.
- [16522](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16522) Add 773 (Host item entry) to the cart and list displays and e-mails

  **Sponsored by** *Bibliotheksservice-Zentrum Baden-Württemberg (BSZ)*
  >This adds information from host item entry (MARC21 773) and if applicable a link to the host record in the following places:
  >* Staff interface: list, list email, cart, cart email, and search results
  >* OPAC: list, list email, cart, cart email, and search results
- [21330](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21330) Add XSLT for authority detail page in OPAC
  >This enhancement enables using custom XSLT stylesheets to display authority detail pages in the OPAC. 
  >
  >Enter a path to the custom XSLT file in the new system preference AuthorityXSLTOpacDetailsDisplay (or enter an external URL). Use placeholders for multiple custom style sheets for different languages ({langcode}) and authority types ({authtypecode}).
- [26765](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26765) Make author span a clickable link on OPAC results list
- [29449](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29449) Show userid on "your personal details" tab
  >Patrons can now see their username in the 'Personal details' tab in the OPAC.
  >
  >This can be hidden from them using the PatronSelfModificationBorrowerUnwantedField system preference, if needed.
- [30621](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30621) Author should be its own column on opac-readingrecord.tt
- [31699](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31699) Add a generic way to redirect back to the page you were on at login for modal logins

  **Sponsored by** *The European Southern Observatory*
  >
  >This enhancement adds the ability to redirect users back to where they were when using the modal type logins in place of an action that requires login on the OPAC.
  >
  >Example: On the OPAC detail page you can add comments if logged in. Prior to this patch, clicking the link to add a comment prior to being logged in would expose the login modal and then re-direct you to your OPAC user page, and thus lose the context of your action.  With this enhancement, you are redirected back to the record you were looking at and can then post your comment.
- [32125](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32125) Implement contextual return on OPAC comments

  **Sponsored by** *PTFS Europe*
  >
  >This enhancement ensures patrons are returned to the correct bibliographic record detail page after a login that is prompted when attempting to comment on a bibliographic record.
- [32998](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32998) Consolidate opac-tmpl/lib and opac-tmpl/bootstrap/lib
- [33767](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33767) Accessibility: The 'OPAC results' page contains semantically incorrect headings

### Patrons

#### New features

- [32426](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32426) Make userid generation pluggable
  >This adds a new plugin hook `patron_generate_userid` that allows to have a custom method for generating the userid on a patron record.

#### Enhancements

- [14251](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14251) Allow use of CSS in discharge letter
  >With this patch, it is now possible to add CSS formatting to the discharge letter. CSS styling can be added directly in the DISCHARGE letter in the Notices and slips tool. The CSS stylesheet added in the NoticeCSS system preference will also be applied to the discharge PDF.
  >
  >Note that the discharge functionality now requires the weasyprint module.
- [21699](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21699) Allow circulation messages to be editable
- [26598](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26598) Display guarantee's fines on guarantor's details page
  >This enhancement adds a new tab in the patron details page to show guarantees' unpaid charges.
- [28366](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28366) Add batch patron modification to patron search results
- [29046](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29046) Allow libraries to specify email order for "AutoEmailPrimaryAddress"

  **Sponsored by** *PTFS Europe*
  >
  >This enhancement adds a new system preference EmailFieldPrecedence, which allows libraries to set the order in which patron email addresses are used when selecting "first valid" in EmailFieldPrimary (formerly AutoEmailPrimaryAddress).
- [33038](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33038) Add classes to category code and category type in patron brief information for easier customization

### REST API

#### New features

- [21043](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21043) Add POST endpoint for patron debits

  **Sponsored by** *The Research University in the Helmholtz Association (KIT)*
- [29453](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29453) Add GET endpoints to fetch patron credits and debits

  **Sponsored by** *PTFS Europe*
- [30962](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30962) Add POST endpoint for validating a user password
- [31793](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31793) Add DELETE endpoint for Authorities
- [31794](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31794) Add GET endpoint for Authorities
- [31795](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31795) Add POST endpoint for Authorities
- [31796](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31796) Add PUT endpoint for Authorities
- [31797](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31797) Add DELETE endpoint for Items
- [31798](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31798) Add POST endpoint for Items
- [31799](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31799) Add PUT endpoint for Items
- [31800](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31800) Add POST endpoint for Biblios
- [31801](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31801) Add PUT endpoint for Biblios
- [32734](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32734) Add GET endpoint for listing Biblios
- [32735](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32735) Add GET endpoint for listing Authorities
- [32981](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32981) Add GET endpoint for listing authorised values by a given category
- [32997](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32997) Add GET endpoint for listing authorised value categories
- [33146](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33146) Add public GET endpoint for listing items

#### Enhancements

- [33161](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33161) Implement +strings for GET /items and GET /items/:item_id

  **Sponsored by** *Virginia Polytechnic Institute and State University*
  >Exposes the `+strings` option on the `/items` endpoints.
  >
  >The allows api consumers to request that string expansions of various coded values from these endpoints are embedded into the response.

### Reports

#### Enhancements

- [17350](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17350) Add option to delete data stored in saved_reports with cleanup_database
- [23824](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23824) Add a 'Save and run' button to reports
- [30928](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30928) Add interface to statistics table
- [32057](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32057) Add optional stack trace to action logs
  >It can be useful to know where in Koha a logged action was generated from, and how. This enhancement adds stack traces to action logs. To use, add a number for the trace depth (such as 3) to the new system preference `ActionLogsTraceDepth`. The details for the stack trace are available by querying the database, for example:  
  >`SELECT * FROM action_logs WHERE trace IS NOT NULL;`
- [32613](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32613) Add auto-completion to our SQL reports editor
  >This adds an auto-complete feature to the SQL reports editor. This works for tables and columns. For columns you'll need to start with the table name, like `borrowers.`. The editor will then suggest the columns of the `borrowers` table. The auto-complete feature will also work when tables have been renamed.

### SIP2

#### Enhancements

- [25812](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25812) Fines can be displayed on SIP checkin/checkout
- [32431](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32431) Show date for expired patrons in SIP
- [32684](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32684) Implement SIP patron status field "too many items lost"

### Searching

#### Enhancements

- [14911](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14911) Item search: Display additional title information
  >Improves display of title information in item search by adding subtitle, part name, part number and medium to the display.
- [31338](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31338) Show in advanced search when IncludeSeeFromInSearches is used
  >When `IncludeSeeFromInSearches` is activated, there will be a note below the first search form on the advanced search in staff interface and OPAC.
- [32960](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32960) Add option in item search for excluding checked out items
- [33190](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33190) Add search history button to advance search form if EnableSearchHistory keep

### Searching - Elasticsearch

#### Enhancements

- [18829](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18829) Elasticsearch - Add ability to view the ES indexed record
- [33594](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33594) Sorting results by Title A-Z might use wrong title field
  >This changes the behavour of title search and sorting (Title (A-Z)) in the OPAC and staff interface when using Elasticsearch or Open Search. The title search now only uses 245 (for MARC 21) and 200 (for UNIMARC). Previously other title fields may have affected the search order, for example 240$a in MARC21.
  >
  >To make this change for existing installations, reset the search engine mappings (Administration > Catalog > Search engine configuration (Elasticsearch) > Reset mappings (scroll down to the bottom of the page)) and rebuild the search index (koha-elasticsearch --rebuild -d -b -a <instancename>). If you have customized the search engine configuration, remember to record or back these up BEFORE resetting the mappings.

### Self checkout

#### Enhancements

- [32115](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32115) Add ID to check-out default help message dialog to allow customization

### Serials

#### Enhancements

- [32752](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32752) Add new serial issue status: "Out for binding", "Bound", and "Circulating"

  **Sponsored by** *The Research University in the Helmholtz Association (KIT)*

### Staff interface

#### Enhancements

- [30624](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30624) Add a permission to control the ability to change the logged in library
  >This enhancement adds a new `loggedinlibrary` permission to allow or prevent staff members to set the library where they log in.
- [32886](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32886) Set focus for cursor to Code when adding a new restriction
- [33090](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33090) page-sections are missing in the account line details page
- [33281](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33281) Improve authority links and add them to MARC preview
- [33316](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33316) Improve display of ES indexer jobs
- [33607](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33607) Show framework on record details page
  >With this patch the MARC framework shows at the end of the bibliographic description on the catalog detail page in the staff interface.

### System Administration

#### Enhancements

- [27424](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27424) One should be able to assign an SMTP server as the default
  >We have been able to define SMTP servers in the staff interface for a while now. But to utilize them you had to set the SMTP server for each library individually. With this you can now chose to apply an SMTP server as default to all your libraries.
- [33192](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33192) We should rename 'AutoEmailPrimaryAddress' to 'EmailFieldPrimary' for clarification
  >The enhancement renames AutoEmailPrimaryAddress the system preference to EmailFieldPrimary to reflect the fact that it is not only used in the context of AutoEmailNewUser, but in general for email notices.
- [33550](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33550) Rename Patron restrictions administration page 'Patron restriction types'

### Templates

#### Enhancements

- [27775](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27775) Add hint about drag and drop feature on framework subfield edit
  >The sequence subfields appear when cataloguing bibliographic records, auhority records or items can be changed for each framework. To make this feature more visible a note was added to the framework administration page.
- [31407](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31407) Set focus for cursor to Currency when adding a new currency
- [32095](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32095) Remove bullets from statuses in inventory tool
- [32319](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32319) Give header search submit button more padding
- [32507](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32507) Use template wrapper to build breadcrumb navigation
  >Architectural enhancement in preparation for bootstrap 5 upgrade.  This patch adds the foundations for abstracting the breadcrumb component of the staff client.
- [32571](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32571) Use template wrapper to build tabbed components
- [32649](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32649) Use template wrapper for library transfer limits tabs
- [32658](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32658) Use template wrapper in order from staged file template
- [32660](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32660) Use template wrapper for basket groups tabs
- [32661](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32661) Use template wrapper for invoices page tabs
- [32662](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32662) Use template wrapper for item circulation alerts page
- [32683](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32683) Convert header search tabs to Bootstrap
- [32688](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32688) Convert recalls awaiting pickup tabs to Bootstrap
- [32698](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32698) Use template wrapper for serials pages tabs
- [32746](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32746) Standardize structure around action fieldsets in acquisitions
- [32769](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32769) Standardize structure around action fieldsets in administration
- [32914](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32914) Use template wrapper for batch record deletion and modification templates
- [32952](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32952) Standardize action fieldsets in authorities, cataloging, and circulation
- [33000](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33000) Use template wrapper for breadcrumbs: Acquisitions part 1
- [33031](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33031) Update OPAC lists page to use Bootstrap markup for tabs
- [33068](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33068) Use template wrapper for breadcrumbs: Administration part 3
- [33071](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33071) Show tooltip when hovering on home icon in staff interface breadcrumbs
- [33077](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33077) Improve ease of translating template title tags
- [33127](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33127) Use template wrapper for breadcrumbs: Administration part 5
- [33310](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33310) Use template wrapper for tabs: Suggestions
- [33349](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33349) Patron attributes don't have identifying info in the staff interface

### Test Suite

#### Enhancements

- [31479](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31479) Provide an option to skip the test for atomic updates

  **Sponsored by** *Catalyst*
  >This enhancement adds an option to skip the check for leftover atomic updates when building custom packages. This is particularly useful for Koha providers or anyone else building Koha packages manually.
  >
  >In practice, this could be run like: sudo CUSTOM_PACKAGE=1 ./debian/build-git-snapshot -r ~/debian -v 21.11.01git -d
- [33282](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33282) Cypress tests are failing
- [33733](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33733) Move t/XSLT.t to db_dependent

### Tools

#### Enhancements

- [31611](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31611) More visibly highlight records that cannot be batch deleted/modified

  **Sponsored by** *Toi Ohomai Institute of Technology, New Zealand*
  >This enhancement more clearly emphasises records that cannot be modified or deleted in the 'Batch record deletion', 'Batch item modification', and 'Batch item deletion' tools. Rows are now highlighted in yellow, with a red 'X' in the first column (hovering over the red 'X' shows the reason it cannot be modified or deleted).
- [32019](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32019) Add option to mark items returned in batch modification
- [32021](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32021) Pages 'appear in position' field is not useful

  **Sponsored by** *Catalyst*
- [32164](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32164) Add link to MARC modification templates from batch record modification page
- [32970](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32970) Allow export of batch item modification results in background jobs
## Bugfixes
This list includes all bugfixes since the previous major version. Most of them
have already been fixed in maintenance releases


#### Security bugs

- [31908](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31908) New login fails while having cookie from previous session (23.05.00,22.11.01, 21.11.15)
  >This patch introduces more thorough cleanup of user sessions when logging after a privilege escalation request.
- [32208](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32208) Re-login without enough permissions needs attention (22.11.01,22.05.08)
- [33595](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33595) Bug 26628 broke authorization for tools start page (23.05.00)

#### Critical bugs fixed

- [32401](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32401) x-koha-query cannot contain non-ISO-8859-1 values (23.05.00,22.11.03)
- [32437](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32437) When adding to a basket form a staged file and matching the imported records are ignored when set to overwrite (23.05.00,22.11.05)
- [33262](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33262) When an ordered record is deleted, we lose all information on what was ordered (23.05.00,22.11.06,22.05.13)
- [33653](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33653) Search for late orders can show received order lines (23.05.00,22.11.06)
- [33784](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33784) Save clicks on single order receive (23.05.00)
- [33864](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33864) Problems in order receive modal (23.05.00)
- [32393](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32393) background job worker explodes if JSON is incorrect (23.05.00,22.11.03,22.05.10)
- [32394](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32394) Long tasks queue is never used (23.05.00,22.11.01,22.05.10)
- [32422](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32422) Hardcoded paths in _common.scss prevent using external node_modules (23.05.00,22.11.01)
- [32472](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32472) [21.11 CRASH] The method Koha::Item->count is not covered by tests (21.11.18,22.11.04)
- [32481](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32481) Rabbit times out when too many jobs are queued and the response takes too long (23.05.00,22.11.02,22.05.09, 21.11.16)
- [32558](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32558) Allow background_jobs_worker.pl to process multiple jobs simultaneously up to a limit (23.05.00,22.11.04,22.05.11)
- [32561](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32561) background job worker is still running with all the modules in RAM (23.05.00,22.11.03,22.05.10)
- [32612](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32612) Koha background worker should log to worker-error/output.log (23.05.00,22.11.03,22.05.10)
- [32656](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32656) Script delete_records_via_leader.pl no longer deletes items (23.05.00,22.11.03,22.05.10,21.11.16)
- [33044](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33044) BackgroundJob enqueue does not return the job id if rabbit is unreachable (23.05.00,22.11.04,22.05.11,21.11.19)
- [33183](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33183) Error inserting matchpoint_components when creating record matching rules with MariaDB 10.6 (23.05.00,22.11.04,22.05.12,21.11.20)
- [33309](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33309) Race condition while checkout renewal with ES (23.05.00,22.11.05,22.05.12,21.11.20)
- [33368](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33368) borrowers.flags is about to reach the limit (23.05.00,22.11.05)
- [32354](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32354) Handle session_state param given by OAuth identity provider (23.05.00,22.11.01)

  **Sponsored by** *The New Zealand Institute for Plant and Food Research Limited*
  >This patch ensures Koha doesn't throw an error if the IdP hands back a session_state parameter.
- [33708](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33708) OAuth/OIDC authentication for the staff interface requires OPAC enabled (23.05.00)
- [33815](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33815) Crash when librarian changes their own username in the staff interface (23.05.00)
- [19361](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19361) Linking an authorised value category to a field in a framework can lose data (23.05.00,22.11.04)
- [28328](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28328) Editing a record can cause an ISE if data too long for column (23.05.00,22.11.06)
- [30966](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30966) Record overlay rules - can't use Z39.50 filter (23.05.00,22.11.05,22.05.12,21.11.20)

  **Sponsored by** *Koha-Suomi Oy*
- [32550](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32550) 'Clear on loan' link on Batch item modification doesn't untick on loan items (23.05.00,22.11.02)
- [33100](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33100) Authority linking doesn't work for bib headings ending in two or more punctuation characters (23.05.00,22.11.04,22.05.12, 21.11.20)
- [33375](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33375) Advanced editor crashes when using MySQL 8 due to reserved rank keyword (23.05.00,22.11.05,22.05.13,21.11.21)
- [33445](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33445) Regression - Replacing authority via Z39.50 will not search for anything but the value from the existing authority (23.05.00,22.11.06)
- [33591](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33591) Cannot merge bibliographic records (23.05.00,22.11.06)
- [29234](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29234) Transfers generated by stock rotation alert but do not initiate at checkin (23.05.00,22.11.05)
- [32653](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32653) Curbside pickups - wrong dates available at the OPAC (23.05.00,22.11.04)
- [32891](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32891) Curbside pickups - Cannot select slot in the last hour (23.05.00,22.11.04)
- [33300](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33300) Wrong system preference name AutomaticWrongTransfer (23.05.00,22.11.06)
- [33362](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33362) Return claims can be un-resolvable if issue_id is set but no issue is found in issues or old_issues (23.05.00)
- [33574](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33574) Restriction type is not stored, all restrictions fall back to MANUAL (23.05.00,22.11.05)
- [32798](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32798) build_oai_sets.pl passes wrong parameter to Koha::Biblio::Metadata->record (23.05.00,22.11.04)
- [33108](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33108) We need a way to launch the ES indexer automatically (23.05.00,22.11.06)
- [33603](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33603) misc/maintenance/search_for_data_inconsistencies.pl fails if biblio.biblionumber on control field (23.05.00,22.11.06,22.05.13)
- [32468](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32468) Vendors select only allows selecting from first 20 vendors by default (23.05.00,22.11.01)
- [32779](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32779) Import from list is broken (23.05.00,22.11.03)
- [32782](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32782) Add UNIMARC support to the ERM module (23.05.00,22.11.06)
- [33481](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33481) EBSCO ws return 415: Content type 'application/octet-stream' not supported (23.05.00,22.11.05)
- [33482](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33482) Errors from EBSCO's ws are not reported to the UI (23.05.00,22.11.06)
- [33483](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33483) Cannot link EBSCO's package with local agreement (23.05.00,22.11.06)
- [33485](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33485) Add/remove title from holdings is not using the correct endpoint (23.05.00,22.11.05)
- [33623](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33623) getAll not encoding URL params (23.05.00,22.11.06)
- [30254](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30254) New overdue fine applied to incorrectly when using "Refund lost item charge and charge new overdue fine" option in circ rules (23.05.00,22.11.03, 22.05.10)
- [30687](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30687) Unable to override hold policy if no pickup locations are available (23.05.00,22.11.06)
- [32470](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32470) (Bug 14783 follow-up) Fix mysql error in db_rev for 22.06.000.064 (23.05.00,22.11.01)
- [33611](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33611) Holds being placed in the future if DefaultHoldExpirationdate is set (23.05.00,22.11.06)
- [33761](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33761) Holds queue is not selecting items with completed transfers (23.05.00)
- [30352](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30352) "Not for loan" in result list doesn't translate in OPAC (23.05.00,22.11.06,22.05.13)
- [32356](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32356) xx-XX installer dir /kohadevbox/koha/installer/data/mysql/xx-XX already exists. (23.05.00,22.11.03,22.05.10,21.11.18)
- [33702](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33702) Patrons should only see their own ILLs in the OPAC (22.11.06)
- [28267](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28267) Older databases fail to upgrade due to having a row format other than "DYNAMIC" (23.05.00,22.11.06)
- [32399](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32399) Database update for bug 30483 is failing (23.05.00,22.11.01,22.05.12)
- [31259](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31259) Downloading patron card PDF hangs the server (23.05.00,22.11.05,22.05.12,21.11.20)
- [32250](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32250) link_bibs_to_authorities generates too many background jobs (23.05.00,22.11.06)
- [33159](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33159) Thesaurus is not defined by second indicator for controlled fields outside of 6XX (23.05.00,22.11.05)
- [33277](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33277) Correctly handle linking subfields with no defined thesaurus (23.05.00,22.11.06)
- [33557](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33557) Add a system preference to disable/enable thesaurus checking during authority linking (23.05.00,22.11.06)
- [32442](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32442) Invalid Template Toolkit in notices can cause errors (23.05.00,22.11.03)
- [32445](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32445) Status display of 'not for loan' items is broken in OPAC/staff (23.05.00,22.11.02)
- [32674](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32674) When placing a hold in OPAC page explodes into error 500 (23.05.00,22.11.04)
- [32712](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32712) OPACShowCheckoutName makes OPAC explode (23.05.00,22.11.03)
- [33069](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33069) File download from list in OPAC gives error (23.05.00,22.11.06)
- [33101](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33101) Basket More details view doesn't work (23.05.00,22.11.04)
- [32994](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32994) Remove compiled files from src (2) (23.05.00,22.11.04)
- [33629](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33629) allow pbuilder to use network via build-git-snapshot (23.05.00,22.11.06,22.05.13)
- [19249](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19249) Date picker broken in "Quick add new patron" form (23.05.00,22.11.06)
- [33829](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33829) Cannot add patron to patron list if PatronAutoComplete is off (23.05.00)
- [32539](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32539) UI hooks can break the UI (23.05.00,22.11.03,22.05.10,21.11.18)
- [31381](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31381) Searching patrons by letter broken when using non-mandatory extended attributes (23.05.00, 22.11.01)
- [32336](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32336) MARCXML output of REST API may be badly encoded (UNIMARC) (23.05.00,22.11.05)
- [32713](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32713) x-koha-embed appears to no longer properly validate (23.05.00,22.11.04)
- [33020](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33020) Unsupported method history (23.05.00,22.11.04)
- [33145](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33145) Invalid specification for ERM routes (23.05.00,22.11.04)
- [32515](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32515) SIP2 no block flag on checkin calls routine that does not exist (23.05.00,22.11.03,22.05.10)
- [33055](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33055) SIP2 adding incorrect fines blocked message (23.05.00,22.11.04,22.05.11,21.11.19)
- [33216](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33216) SIP fee paid messages explode if payment registers are enabled and the SIP account has no register (23.05.00,22.11.06,22.05.13,21.11.21)
- [32126](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32126) Adding item search fields is broken - can't add more than one field (23.05.00, 22.11.01)
- [33297](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33297) Typo system preference RetainPatronSearchTerms in DB revs 220600044.pl (23.05.00)
- [32594](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32594) Add a dedicated ES indexing background worker (23.05.00,22.11.06)
- [33019](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33019) Records not indexed in Elasticsearch ES when first catalogued (23.05.00,22.11.05)
- [32555](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32555) Error when viewing serial in OPAC (23.05.00,22.11.03)
- [33014](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33014) Add link to serial advanced search (23.05.00,22.11.04)
- [31935](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31935) Serials subscription form is misaligned (23.05.00,22.11.02)
  >This fixes the alignment of the serials subscription form.
- [32517](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32517) Patron search dies on case mismatch of patron category (23.05.00,22.11.02)
  >This fixes patron search so that searching by category will work regardless of the patron category code case (upper, lower, and sentence case). Before this, category codes in upper case were expected - where they weren't this caused the search to fail, resulting in no search results.
- [32772](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32772) Patron autocomplete should not use contains on all fields (23.05.00,22.11.03)
- [33774](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33774) Loading club table in every tab in patron details (23.05.00)
- [32898](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32898) Cypress tests are failing (23.05.00,22.11.04)
- [33416](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33416) Agreements.ts is failing (23.05.00)
- [26611](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26611) Required match checks don't work for authority records (23.05.00)

  **Sponsored by** *Waikato Institute of Technology*
  >This fixes match checking for authorities when importing records, so that the required match checks are correctly applied. Previously, match checks for authority records did not work.
- [32054](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32054) GetImportRecordMatches returns the wrong match when passed 'best only' (23.05.00,22.11.02)
- [32631](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32631) Error when previewing record during batch record modification (23.05.00,22.11.03)
  >This patch corrects an error in the script which outputs MARC data for preview during batch record modification.
- [32804](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32804) Importing and replacing items causes inconsistency when itemnumber match and biblio match disagree (23.05.00,22.11.04)
- [33156](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33156) Batch patron modification tool is missing search bar and other attributes (23.05.00,22.11.06,22.05.13)
- [33412](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33412) (bug 15869 follow-up) Overlay record framework is always setting records to original framework (23.05.00,22.11.06)
- [33576](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33576) Records are not indexed when imported if using Elasticsearch (23.05.00,22.11.06)
- [33504](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33504) ILS-DI does not record renewer_id for renewals creating issue with renewal history view (23.05.00,22.11.06,22.05.13)

#### Other bugs fixed

- [32665](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32665) warnPrefRequireChoosingExistingAuthority condition incorrect in about.pl (23.05.00,22.11.04)
- [32687](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32687) About may list version of SQL client in container, not actual server (23.05.00,22.11.04)
- [20473](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20473) "Item information" tab should not appear if item is not created upon placing an order (23.05.00,22.11.03)
- [31056](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31056) Unable to 'Close and export as PDF' a basket group (23.05.00,22.11.04)
- [31722](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31722) Don't show EDIFACT note on basket group page if EDIFACT is turned off (23.05.00,22.11.05)
- [31984](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31984) TaxRate system preference - add note about updating vendor tax rates where required (23.05.00,22.11.01)
  >This enhancement adds a note to the TaxRates system preference about updating vendors tax rates when the TaxRates system preference values are changed or removed. (Vendors retain the original value entered, and this is used to calculate the tax rate for orders.)
- [32377](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32377) GetBudgetHierarchy slows down acqui/histsearch.pl (23.05.00,22.11.03,22.05.10, 21.11.16)

  **Sponsored by** *Koha-Suomi Oy*
- [32382](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32382) Fund input misaligned on invoice summary page (23.05.00,22.11.03)
- [32406](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32406) Cannot search pending orders using non-latin-1 scripts (23.05.00,22.11.03,22.05.10,21.11.16)
- [32417](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32417) Cannot insert order: Mandatory parameter biblionumber is missing (23.05.00,22.11.01)
- [32484](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32484) Enable framework plugins when UseACQFrameworkForBiblioRecords is set (23.05.00,22.11.06)
  >This bugfix enables the use of framework plugins when: 
  >- `UseACQFrameworkForBiblioRecords` is enabled, and
  >- entering catalog details when adding items to a basket from a new (empty) record. 
  >This requires plugins to be enabled for fields in the `ACQ` framework.
- [32531](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32531) Filter 'Include archived' no longer shows non-archived suggestions (23.05.00,22.11.02)
- [32603](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32603) Suggester category in Suggestions management (23.05.00,22.11.03)
- [32694](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32694) Keep current option for budgets in receiving broken (23.05.00,22.11.03,22.05.10,21.11.16)
- [33002](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33002) 'Archive selected' button missing? (23.05.00,22.11.04)
- [33003](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33003) Show the vendor type description on vendor detail page when AV is used (23.05.00)
- [33082](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33082) Add yellow buttons and page sections to 'copy order' pages (23.05.00,22.11.04)
- [33238](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33238) Error adding suggestion to basket as non-superlibrarian (Bug 29886 follow-up) (23.05.00,22.11.05,22.05.13,21.11.21)
- [33414](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33414) Dates displayed in ISO format in orders by fund (23.05.00,22.11.05)
- [33421](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33421) Filtering purchase suggestions by status does not work if All Libraries is selected (23.05.00)
- [33663](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33663) Don't hide Suggestions link in side navigation when suggestion preference is disabled (23.05.00)
- [33771](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33771) Markup errors on orderreceive.tt after 8179 (23.05.00)
- [33783](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33783) Populate actual cost with estimated cost if actual cost not set when receiving (bug 8179 follow-up) (23.05.00)
- [18247](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18247) Remove SQL queries from branch_transfer_limit.pl administrative script (23.05.00,22.11.03,22.05.10, 21.11.16)

  **Sponsored by** *Catalyst*
- [23247](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23247) Use EmbedItems in opac-MARCdetail.pl (23.05.00,22.11.04)
- [28672](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28672) Improve EDI debug logging (23.05.00,22.11.03,22.05.10,21.11.18)
- [30649](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30649) Vendor EDI account passwords should be encrypted in the database (23.05.00)
- [30920](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30920) Add caching to C4::Biblio::GetAuthorisedValueDesc (23.05.00,22.11.04)
- [31675](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31675) Remove packages from debian/control that are no longer used (23.05.00, 22.11.01, 22.05.09, 21.11.16)
- [31893](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31893) Some pages load about.tt template to check authentication rather than using checkauth (23.05.00,22.11.03,22.05.10, 21.11.16)
- [32330](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32330) Table background_jobs is missing indexes (23.05.00,22.11.01,22.05.09, 21.11.16)
- [32418](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32418) CRASH: Can't call method "unblessed" on an undefined value at cataloguing/additem.pl (23.05.00,22.11.05)
- [32457](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32457) CGI::param called in list context from acqui/addorder.pl line 182 (23.05.00,22.11.01,22.05.09, 21.11.16)
- [32460](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32460) Columns missing from table configuration for patron categories (23.05.00,22.11.04,22.05.11)
- [32465](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32465) koha-worker debian script missing 'queue' in help (23.05.00,22.11.02,22.05.09)
  >This adds information about the --queue option to the help text for the koha-worker script.
- [32528](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32528) Koha::Item->safe_to_delete should short-circuit earlier (23.05.00,22.11.02)
- [32529](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32529) Holds in processing should block item deletion (23.05.00,22.11.02)
- [32573](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32573) background_jobs_worker.pl should ACK a message before it forks and runs the job (23.05.00,22.11.03,22.05.10, 21.11.16)
- [32580](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32580) Background job cancel button broken, leads to background_jobs.pl with a kc (23.05.00,22.11.03)
- [32582](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32582) Mailmap maps to wrong email address (23.05.00,22.11.02)
- [32583](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32583) Restore display of only one item in catalogue/moredetails (23.05.00,22.11.03)
- [32585](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32585) Followup on Bug 32583 - fix some variable references (23.05.00,22.11.04)
- [32678](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32678) Add new line in authorized values tests in search_for_data_inconsistencies.pl (23.05.00,22.11.04,22.05.11,21.11.19)
- [32716](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32716) update NGINX config examples to increase proxy_buffer_size (23.05.00,22.11.05,22.05.13,21.11.21)
  >Set proxy_buffer_size in the example NGINX configuration to reduce chances that REST API responses that use pagination get dropped by NGINX
- [32781](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32781) CreateEHoldingsFromBiblios not dealing with non-existent package correcly (23.05.00,22.11.04)
- [32794](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32794) mailto links in 856 can be incorrectly formed by XSLT (23.05.00,22.11.05)
- [32811](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32811) Remove unused indexer.log (23.05.00,22.11.04,22.05.11,21.11.19)
- [32922](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32922) Remove space in shebang (23.05.00,22.11.04)
- [32935](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32935) basketgroup.js is not longer used and should be removed (23.05.00,22.11.04)
- [32975](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32975) Error in package.json's definition of css:build vs css:build:prod (23.05.00, 22.11.04)
- [32978](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32978) 'npm install' fails in ktd on aarch64, giving unsupported architecture error for node-sass (23.05.00,22.11.04)
- [32990](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32990) Possible deadlock in C4::ImportBatch::_update_batch_record_counts (23.05.00,22.11.06)
- [32992](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32992) Move background worker script to misc/workers (23.05.00,22.11.06)
- [33053](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33053) Tables item_groups and recalls have a biblio_id column with a default of 0 (23.05.00,22.11.06)
- [33088](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33088) background-job-progressbar.js no longer needed in batch_record_modification.tt (23.05.00,22.11.05,22.05.13,21.11.21)
- [33167](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33167) Cleanup staff interface catalog details page (23.05.00,22.11.06)
- [33211](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33211) Fix failing test for basic_workflow.t when adding item (23.05.00,22.11.04,22.05.12,21.11.20)
- [33229](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33229) Patron reading history should be cleared when privacy set to never (23.05.00,22.11.05)
- [33341](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33341) Perl 5.36 doesn't consider some of our code cool (23.05.00,22.11.05,22.05.12,21.11.20)
- [33367](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33367) tmp/modified_authorities/README.txt seems useless (23.05.00,22.11.05,22.05.13,21.11.21)
- [33447](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33447) Add caching to Biblio->pickup_locations (23.05.00,22.11.06)
- [33488](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33488) Library transfer limits should have an index on fromBranch (23.05.00,22.11.06)
- [33489](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33489) The borrowers table should have indexes on default patron search fields (23.05.00,22.11.06)
- [33710](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33710) Ignore howto files (23.05.00,22.11.06)
- [33718](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33718) _new_Zconn crashes on a bug in t::lib::Mocks::mock_config (23.05.00)
- [33739](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33739) ModItemTransfer triggers indexing twice (23.05.00)
- [33854](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33854) Typo in ImportBatchProfiles controller (23.05.00)
- [33675](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33675) Add CSRF protection to OAuth/OIDC authentication (23.05.00)
  >This development adds support for the `state` parameter generation and delivery when contacting IdPs. This is an optional but recommended opaque value in the OAuth2/OIDC specs that helps prevent CSRF attacks, but is also a requirement on some Identity Provider solutions.
- [3831](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=3831) Add a warning/hint when FA framework is missing (23.05.00,22.11.04)
- [15869](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15869) Change framework on overlay (23.05.00,22.11.03)
  >This change fixes a long-standing bug where the framework specified during import only applied to new records and not overlaid matches.
- [29173](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29173) Button "replace authority record via Z39/50/SRU" doesn't pre-fill (23.05.00,22.11.03,22.05.10,21.11.18)
  >This fixes the behaviour of the replace an authority record via Z39.50/SRU buttons when editing an authority record. Both ways of doing this (Edit > Edit record > Replace record via Z39.50/SRU search and Edit > Replace record via Z39.50/SRU search) now pre-fill the search form with available data.
- [31665](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31665) 952$d ( Date acquired ) no longer prefills with todays date when focused (23.05.00,22.11.04)
- [32204](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32204) in-page anchor to edititem on additem.pl not working (23.05.00,22.11.03)
- [32253](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32253) Advanced cataloging editor doesn't load every line initially (23.05.00,22.11.06,22.05.13)
- [32321](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32321) 006 field not correctly prepopulated in Advanced cataloging editor (23.05.00,22.11.03,22.05.10, 21.11.16)
- [32567](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32567) Update plugin unimarc_field_110.pl 'Script of title' and 'Transliteration code' (23.05.00,22.11.03)
- [32692](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32692) Terminology: MARC framework tag subfield editor uses intranet instead of staff interface (23.05.00,22.11.03,22.05.10)
- [32812](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32812) Fix cataloguing/value_builder/barcode_manual.pl (23.05.00,22.11.04, 21.11.19)
- [32813](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32813) Fix cataloguing/value_builder/barcode.pl (23.05.00,22.11.04.22.05.11, 21.11.19)
- [32814](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32814) Fix cataloguing/value_builder/callnumber-KU.pl (23.05.00,22.11.04,22.05.11, 21.11.19)
- [32815](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32815) Fix cataloguing/value_builder/callnumber.pl (23.05.00,22.11.04,22.05.11,21.11.19)
- [32816](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32816) Fix cataloguing/value_builder/cn_browser.pl (23.05.00,22.11.04,22.05.11, 21.11.19)
- [32817](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32817) Clean up cataloguing/value_builder/dateaccessioned.pl (23.05.00,22.11.06)
- [32818](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32818) Clean up cataloguing/value_builder/marc21_field_005.pl (23.05.00,22.11.06)
- [32819](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32819) Fix cataloguing/value_builder/stocknumberam123.pl (23.05.00,22.11.04,22.05.11,21.11.19)
- [32820](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32820) Fix cataloguing/value_builder/stocknumberAV.pl (23.05.00,22.11.04,22.05.11, 21.11.19)
- [32821](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32821) Fix cataloguing/value_builder/stocknumber.pl (23.05.00,22.11.04,22.05.11, 21.11.19)
- [32822](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32822) Fix cataloguing/value_builder/unimarc_field_010.pl (23.05.00,22.11.04,22.05.11,21.11.19)
- [32823](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32823) Fix cataloguing/value_builder/unimarc_field_100_authorities.pl (23.05.00,22.11.04,22.05.11,21.11.19)
- [32824](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32824) Fix cataloguing/value_builder/unimarc_field_100.pl (23.05.00,22.11.04,22.05.11,21.11.19)
- [32825](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32825) Fix cataloguing/value_builder/unimarc_field_105.pl (23.05.00,22.11.04,22.05.11,21.11.19)
- [32826](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32826) Fix cataloguing/value_builder/unimarc_field_106.pl (23.05.00,22.11.04,22.05.11,21.11.19)
- [32827](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32827) Fix cataloguing/value_builder/unimarc_field_110.pl (23.05.00,22.11.04,22.05.11,21.11.19)
- [32828](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32828) Fix cataloguing/value_builder/unimarc_field_115a.pl (23.05.00,22.11.04,22.05.11,21.11.19)
- [32829](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32829) Fix cataloguing/value_builder/unimarc_field_115b.pl (23.05.00,22.11.04,22.05.11,21.11.19)
- [32830](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32830) Fix cataloguing/value_builder/unimarc_field_116.pl (23.05.00,22.11.05)
- [32831](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32831) Fix cataloguing/value_builder/unimarc_field_117.pl (23.05.00,22.11.05)
- [32832](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32832) Fix cataloguing/value_builder/unimarc_field_120.pl (23.05.00,22.11.05)
- [32833](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32833) Fix cataloguing/value_builder/unimarc_field_121a.pl (23.05.00,22.11.05)
- [32834](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32834) Fix cataloguing/value_builder/unimarc_field_121b.pl (23.05.00,22.11.05)
- [32835](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32835) Fix cataloguing/value_builder/unimarc_field_122.pl (23.05.00,22.11.04,22.05.11,21.11.19)
- [32836](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32836) Fix cataloguing/value_builder/unimarc_field_123a.pl (23.05.00,22.11.05)
- [32837](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32837) Fix cataloguing/value_builder/unimarc_field_123d.pl (23.05.00,22.11.05)
- [32838](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32838) Fix cataloguing/value_builder/unimarc_field_123e.pl (23.05.00,22.11.05)
- [32839](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32839) Fix cataloguing/value_builder/unimarc_field_123f.pl (23.05.00,22.11.05)
- [32840](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32840) Fix cataloguing/value_builder/unimarc_field_123g.pl (23.05.00,22.11.05)
- [32841](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32841) Fix cataloguing/value_builder/unimarc_field_123i.pl (23.05.00,22.11.05)
- [32842](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32842) Fix cataloguing/value_builder/unimarc_field_123j.pl (23.05.00,22.11.05)
- [32843](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32843) Fix cataloguing/value_builder/unimarc_field_124a.pl (23.05.00,22.11.05)
- [32844](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32844) Fix cataloguing/value_builder/unimarc_field_124b.pl (23.05.00,22.11.05)
- [32845](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32845) Fix cataloguing/value_builder/unimarc_field_124c.pl (23.05.00,22.11.05)
- [32846](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32846) Fix cataloguing/value_builder/unimarc_field_124d.pl (23.05.00,22.11.05)
- [32847](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32847) Fix cataloguing/value_builder/unimarc_field_124e.pl (23.05.00,22.11.05)
- [32848](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32848) Fix cataloguing/value_builder/unimarc_field_124f.pl (23.05.00,22.11.05)
- [32849](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32849) Fix cataloguing/value_builder/unimarc_field_124g.pl (23.05.00,22.11.05)
- [32850](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32850) Fix cataloguing/value_builder/unimarc_field_124.pl (23.05.00,22.11.05)
- [32851](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32851) Fix cataloguing/value_builder/unimarc_field_125a.pl (23.05.00,22.11.05)
- [32852](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32852) Fix cataloguing/value_builder/unimarc_field_125b.pl (23.05.00,22.11.05)
- [32854](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32854) Fix cataloguing/value_builder/unimarc_field_126a.pl (23.05.00,22.11.05)
- [32855](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32855) Fix cataloguing/value_builder/unimarc_field_126b.pl (23.05.00,22.11.05)
- [32857](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32857) Fix cataloguing/value_builder/unimarc_field_127.pl (23.05.00,22.11.05)
- [32858](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32858) Fix cataloguing/value_builder/unimarc_field_128a.pl (23.05.00,22.11.05)
- [32859](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32859) Fix cataloguing/value_builder/unimarc_field_128b.pl (23.05.00,22.11.05)
- [32860](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32860) Fix cataloguing/value_builder/unimarc_field_128c.pl (23.05.00,22.11.05)
- [32861](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32861) Fix cataloguing/value_builder/unimarc_field_130.pl (23.05.00,22.11.05)
- [32862](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32862) Fix cataloguing/value_builder/unimarc_field_135a.pl (23.05.00,22.11.05)
- [32863](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32863) Fix cataloguing/value_builder/unimarc_field_140.pl (23.05.00,22.11.05)
- [32864](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32864) Fix cataloguing/value_builder/unimarc_field_141.pl (23.05.00,22.11.05)
- [32865](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32865) Clean up cataloguing/value_builder/unimarc_field_146a.pl (23.05.00,22.11.06)
- [32866](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32866) Clean up cataloguing/value_builder/unimarc_field_146h.pl (23.05.00,22.11.06)
- [32867](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32867) Clean up cataloguing/value_builder/unimarc_field_146i.pl (23.05.00,22.11.06)
- [32868](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32868) Fix cataloguing/value_builder/unimarc_field_210c_bis.pl (23.05.00,22.11.06)
- [32869](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32869) Fix cataloguing/value_builder/unimarc_field_210c.pl (23.05.00,22.11.06)
- [32870](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32870) Fix cataloguing/value_builder/unimarc_field_225a_bis.pl (23.05.00,22.11.06)
- [32871](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32871) Fix cataloguing/value_builder/unimarc_field_225a.pl (23.05.00,22.11.06)
- [32872](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32872) Fix cataloguing/value_builder/unimarc_field_4XX.pl (23.05.00,22.11.06)
- [32873](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32873) Fix cataloguing/value_builder/unimarc_field_686a.pl (23.05.00,22.11.06)
- [32874](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32874) Fix cataloguing/value_builder/unimarc_field_700-4.pl (23.05.00,22.11.06)
- [32875](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32875) Fix cataloguing/value_builder/unimarc_leader_authorities.pl (23.05.00,22.11.06)
- [32876](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32876) Fix cataloguing/value_builder/unimarc_leader.pl (23.05.00,22.11.06)
- [32959](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32959) Item templates will apply the same barcode each time template is applied if autobarcode is enabled (23.05.00)
- [33144](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33144) Authority lookup in advanced editor overencodes HTML (23.05.00,22.11.04,22.05.12,21.11.20)
- [33173](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33173) Save and continue button in standard cataloging module broken (23.05.00,22.11.04,22.05.11,21.11.19)
- [33624](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33624) Using Browser "Back" button in Batch Record Modification causes biblio options to be displayed (23.05.00)
- [33655](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33655) z39.50 search no longer shows search in progress (23.05.00,22.11.06)
- [33686](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33686) Update plugin unimarc_field_100.pl 'Script of title' with 2022 values (23.05.00)
- [14784](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14784) Missing checkin message for debarred patrons when issuing rules 'fine days = 0' (23.05.00,22.11.02)
- [18398](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18398) CHECKIN/CHECKOUT/RENEWAL don't use AutoEmailPrimaryAddress but first valid e-mail (23.05.00,22.11.06,22.05.13)
  >This enhancement applies the EmailFieldPrimary (formerly AutoEmailPrimaryAddress) system preference choice to the CHECKIN, CHECKOUT, RENEWAL and various RECALL notices.
- [26967](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26967) Patron autocomplete does not correctly format addresses (23.05.00,22.11.06)
- [28975](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28975) Holds queue lists can show holds from all libraries even with IndependentBranches (23.05.00, 22.11.01, 22.05.09, 21.11.16)
- [29021](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29021) Automatic renewal due to RenewAccruingItemWhenPaid should not be considered Seen (23.05.00,22.11.03)
- [31209](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31209) Add a span with class around serial enumeration/chronology data in list of checkouts for better styling (23.05.00,22.11.04,22.05.11, 21.11.19)
- [31233](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31233) Fine grace period in circulation conditions is misnamed (23.05.00,22.11.02)
- [31563](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31563) Numbers on claims tab not showing in translated templates (23.05.00,22.11.04)
- [32121](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32121) Show an alert when adding a checked out item to an item bundle (23.05.00,22.11.06)
- [32129](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32129) Use patron categorycode of most relevant recall when checking if item can be a waiting recall (23.05.00,22.11.06)

  **Sponsored by** *Auckland University of Technology*
  >This patch uses the patron category of the patron who requested the most relevant recall to check for more specific circulation rules relating to recalls. This ensures that patrons who are allowed to place recalls are able to fill their recalls, especially when recalls are not  generally available for all patron categories.
- [32503](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32503) Holds awaiting pickup doesn't sort dates correctly (23.05.00,22.11.04)
- [32878](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32878) Make it impossible to renew the item if it has active item level hold (23.05.00,22.11.07)
- [32883](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32883) Curbside pickups - Order "To be staged" by date and time of scheduled pickup (23.05.00,22.11.05)
- [33021](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33021) Show an alert when adding an item on hold to an item bundle (23.05.00)
  >When adding an item that is currently on hold to an item bundle, a warning will display, but you can still choose to add the item to the bundle.
- [33220](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33220) Recalls to pull should not show in transit or allocated items (23.05.00)

  **Sponsored by** *Auckland University of Technology*
- [33577](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33577) Buttons on reserve/request.pl are misaligned (23.05.00,22.11.06)
- [33613](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33613) Claim return doesn't charge when "Ask if a lost fee should be charged" is selected and marked to charge (23.05.00,22.11.06)
- [33838](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33838) Offline circulation interface error on return (23.05.00)
- [32793](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32793) import_patrons.pl typo in usage (23.05.00,22.11.03)
- [32800](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32800) build_oai_sets.pl fails on deleted records (23.05.00,22.11.05)
- [33285](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33285) It should be possible to specify the separator used in runreport.pl (23.05.00,22.11.05,22.05.12,21.11.20)
- [33626](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33626) compare_es_to_db.pl does not work with Search::Elasticsearch 7.0 (23.05.00,22.11.06)
- [33645](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33645) koha-foreach always returns 1 if --chdir not specified (23.05.00,22.11.06)
- [33677](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33677) Remove --verbose from koha-worker manpage (23.05.00,22.11.06)
- [33717](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33717) Typo in search_for_data_inconsistencies.pl (23.05.00)
- [28674](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28674) old_reserves.item_level_hold and reserves.item_level_hold comments have typo "hpld" not "hold" (23.05.00,22.11.03)
- [32357](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32357) Set borrower_message_preferences.days_in_advance default to NULL (23.05.00,22.11.06)
  >This fixes the default value in the database for the 'Days in advance' field for patron messaging preferences so that it defaults to NULL instead of 0 (borrower_message_preferences table and the days_in_advance field).
- [32180](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32180) ERM - Mandatory fields don't have the 'required' class on the label (23.05.00,22.11.04)
- [32495](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32495) Required fields in API and UI form don't match (23.05.00,22.11.04)
  >This enhancement changes the new agreement form so that the description field is no longer required (to match with the API).
- [32728](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32728) ERM - Search header should change to match the section you are in (23.05.00,22.11.04)
- [32807](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32807) No need to fetch all if we need to know if one exist (23.05.00,22.11.05)
- [32983](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32983) Use REST API route to retrieve authorised values (23.05.00,22.11.04)
- [33290](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33290) Incorrect variable used in http-client.js (23.05.00,22.11.05)

  **Sponsored by** *Bibliothèque Universitaire des Langues et Civilisations (BULAC)*
- [33346](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33346) Add Help link to Koha manual in ERM module (23.05.00,22.11.05)
- [33354](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33354) Error 400 Bad Request when submitting form in ERM (23.05.00,22.11.06)
- [33355](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33355) ERM UI and markup has some issues (23.05.00,22.11.06)
- [33381](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33381) Active link in the menu is not always correctly styled (23.05.00,22.11.05)
- [33408](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33408) Fetch sysprefs from svc/config/systempreferences (23.05.00)

  **Sponsored by** *Bibliothèque Universitaire des Langues et Civilisations (BULAC)*
- [33422](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33422) ERM - Search header should change to match the section you are in (23.05.00,22.11.05)
- [33490](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33490) Agreements - Filter by expired results in error (23.05.00,22.11.06)
- [33491](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33491) EBSCO Packages - Add new agreement UI has some issues (23.05.00,22.11.06)
- [33823](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33823) KohaTable vue component action buttons spacing differ from kohaTable (23.05.00)
- [22042](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22042) BlockReturnofWithdrawn Items does not block refund generation when item is withdrawn and lost (23.05.00,22.11.02,22.05.09, 21.11.16)
- [32247](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32247) Real time HoldsQueue does not need to check items if there are no holds (23.05.00,22.11.01,22.05.09)
- [32455](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32455) Don't send hold notices from the library's inbound email address (23.05.00,22.11.03)
- [32627](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32627) Reprinting holds slips should not reset the expiration date (23.05.00,22.11.06)
- [32993](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32993) Holds priority changed incorrectly with dropdown selector (23.05.00,22.11.06)
- [33198](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33198) request.pl is calculating pickup locations that are not used (23.05.00,22.11.05,22.05.12)
- [33210](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33210) (Bug 31963 follow-up) No hold fee message on OPAC should be displayed when there is no fee (23.05.00,22.11.06)
- [33302](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33302) Placing item level holds in OPAC allows to pick forbidden pick-up locations, but then places no hold (23.05.00,22.11.06)
- [33672](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33672) Item group features shows when placing holds if EnableItemGroupHolds is disabled (23.05.00,22.11.06)
- [33791](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33791) $hold->fill does not set itemnumber when checking out without confirming hold (23.05.00)
- [31057](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31057) Add clarifying text to 'To date' in the calendar tool (23.05.00,22.11.05)
- [22490](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22490) Some strings in JavaScript files are untranslatable (23.05.00,22.11.04)
- [26403](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26403) Move debit and credit types to YAML files and fix other related translation issues (23.05.00,22.11.06)
  >With this patch the descriptions of system internal credit and debit types will be translated into the selected language at installation time. This will only affect new installations and SQL reporting. If you are building your own SQL reports, you'll be able to pull the descriptions from the tables.
  >
  >It also makes sure, that all system internal debit and credit types appear translated in the GUI. This now also includes the administration pages for managing credit and debit types. Some descriptions for discount, payout, purchase, and void were missing. These have now also been added.
- [30993](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30993) Translation: Unbreak sentence in upload.tt (23.05.00,22.11.03,22.05.11, 21.11.19)
- [31640](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31640) Fuzzy translations of preferences can cause missing sections and inaccurate translations (23.05.00,22.11.05)
- [31957](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31957) Translation: Ability to change the sentence structure on library administration page (23.05.00,22.11.03,22.05.11, 21.11.19)
- [32292](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32292) Update and add database column descriptions used in guided reports (23.05.00,22.11.03)
  >This completes and adds column descriptions that show up when creating a new guided report for following tables:
  >* items
  >* borrowers
  >* biblio
  >* aqorders
  >* suggestions
- [32588](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32588) Filters on top of 'Items with no checkouts' report are untranslatable (23.05.00,22.11.03)
- [32931](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32931) ERM - (is perpetual) Yes / No options untranslatable (23.05.00,22.11.06)
- [33076](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33076) Add context to "Quotes" (23.05.00,22.11.04,22.05.12)
- [33151](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33151) Improve translation of strings in cities and circulation desk administration pages (23.05.00,22.11.04,22.05.12, 21.11.20)
- [33323](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33323) Select button in patron search modal is not translatable (23.05.00,22.11.05,22.05.13)
- [33332](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33332) Fix formatting of TT comments to improve translations (23.05.00,22.11.05)
- [33533](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33533) Translatability: Do not separate "Patron" or "Organization" and "identity" in memberentrygen.tt (23.05.00,22.11.06)
- [22440](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22440) Improve ILL page performance by moving to server side filtering (23.05.00,22.11.06)
- [22693](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22693) ILL "Price paid" column does not appear in column configuration (23.05.00,22.11.03,22.05.11, 21.11.19)
  >This adds the "Price paid" column to the inter-library loan requests table.  This column is also configurable using the Columns button and in the table settings (Administration > Additional parameters > Table settings > Interlibrary loans > ill-requests).
- [28641](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28641) ILLHiddenRequestStatuses does not consider custom statuses (23.05.00,22.11.05,22.05.12,21.11.20)

  **Sponsored by** *PTFS Europe*
- [32525](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32525) Standardize labels between ILL request list and detail page (23.05.00,22.11.04,22.05.11,21.11.19)
- [32566](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32566) Don't show 'ILL request logs' button, when IllLog is turned off (23.05.00,22.11.04,22.05.11, 21.11.19)
- [32799](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32799) ILLSTATUS authorized value category name is confusing (23.05.00,22.11.04)
- [33762](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33762) Restore page-section in ILL (23.05.00)
- [33051](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33051) 22600075.pl is not idempotent (23.05.00,22.11.04)
- [32918](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32918) ERM authorized values should be in installer/data/mysql/en/mandatory/auth_values.yml (23.05.00,22.11.04)
- [33059](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33059) Capitalization: Fix sample authorised value descriptions (23.05.00,22.11.04)
- [33671](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33671) Database update  22.06.00.048  breaks update process (23.05.00,22.11.06)
- [32302](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32302) "ISBN" label shows when no ISBN data present when sending list (23.05.00,22.11.01,22.05.09, 21.11.16)
  >This fixes email messages sent when sending lists so that if there are no ISBNs for a record, an empty label is not shown.
- [32279](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32279) GetAuthorizedHeading missing from exports of C4::AuthoritiesMarc (23.05.00,22.11.05,22.05.12,21.11.20)
- [32280](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32280) Export method ImportBreedingAuth from C4::Breeding (23.05.00,22.11.05,22.05.12, 21.11.20)
- [33138](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33138) Don't copy tag 147 to all MARC frameworks, since it should only be used in a separate NAME_EVENT framework (23.05.00)
- [23032](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23032) Add 264 to Alternate Graphic Representation (MARC21 880) (23.05.00,22.11.02)
- [31432](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31432) MARC21: Make 245 n and p subfields visible in frameworks by default (23.05.00,22.11.06,22.05.13, 21.11.21)
- [31860](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31860) Standardize capitalization for item subfield descriptions (UNIMARC 995/MARC21 952) (23.05.00,22.11.03)
- [32689](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32689) Host item entry (773) missing a space between label and content when $i is used (23.05.00,22.11.03)
- [32766](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32766) Update plugin unimarc_field_116.pl fields (23.05.00,22.11.06)
  >This updates the labels for some values so that they match with the definitions in UNIMARC Bibliographic (3rd ed.) Updates, and to help with translation:
  >
  >- Specific material designation: 
  >  i- print (no change in display)
  >  m- master -> m- mould
  >
  >- Techniques (drawings, paintings) 1, 2, and 3:
  >  crayon -> charcoal
  >
  >- Technique (prints) 1,2, and 3:
  >  Label for dropdown list changed to Techniques (print) 1, 2, and 3
  >  camaiu -> cameo
  >  computer graphics -> infography
  >
  >- Functional designation
  >  ab- item cover -> ab- resource cover
  >  ag- chart -> ag- diagram
- [33419](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33419) Make home library and holding library in items mandatory by default (23.05.00,22.11.06)
  >This will make the home library and holding library on the item form manatory for new installations. It's recommended to also manually make these changes for existing installations as Koha won't function properly if any of these fields are missing.
- [33356](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33356) Add link to mana-kb settings from 'Useful resources' in reports (23.05.00)
- [24616](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24616) Cannot copy notice to another library if it already exists (23.05.00,22.11.03)

  **Sponsored by** *Koha-Suomi Oy*
- [29354](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29354) Make overdue_notices.pl send HTML attachment as .html (23.05.00,22.11.04)
- [32221](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32221) Password entry should be removed from placeholder list in notices editor (23.05.00,22.11.03,22.05.10, 21.11.16)
- [32917](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32917) Change patron.firstname and patron.surname in password change sample notice (23.05.00,22.11.06)
- [33223](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33223) Koha::Patron->notice_email_address isn't consistently used (23.05.00)
- [33313](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33313) TICKET_NOTIFY looking for IntranetBaseURL rather than staffClientBaseURL in default notice (23.05.00)
- [33314](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33314) Link to bibliographic record incomplete in default TICKET_NOTIFY notice (23.05.00)
- [33622](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33622) Notice content does not show on default tab if TranslateNotices enabled (23.05.00,22.11.06)
- [33649](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33649) Fix use of cronlogaction (23.05.00,22.11.06)
- [33658](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33658) Capitalization: **To Reproduce** (23.05.00)
- [25590](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25590) Street number is missing from alternate address in the OPAC (23.05.00,22.11.05)
- [29311](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29311) Do not allow editing of bibliographic information when entering suggestion from existing bibs (23.05.00,22.11.05,22.05.13,21.11.21)
- [29993](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29993) Syndetics cover images do not display in browse shelf when scrolling from the first page (23.05.00)
- [30162](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30162) XSLT has broken link for traced series because of OPAC/staff interface confusion (23.05.00,22.11.05)
- [31221](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31221) Buttons overflow in OPAC search results in mobile view (23.05.00,22.11.04)
- [31248](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31248) Fix responsive table style in the OPAC after switch to Bootstrap tabs (23.05.00,22.11.04,22.05.11)
- [32251](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32251) opac-page.pl: Add a fallback for when language cookie was removed (23.05.00,22.11.03)
- [32338](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32338) OPAC - Mobile - Selection toolbar in search result is shifted and not adjusted (23.05.00,22.11.04)
- [32412](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32412) OPACShelfBrowser controls add extra Coce images to biblio-cover-slider (23.05.00,22.11.06)
- [32492](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32492) Improve mark-up of OPAC messaging table to ease customization (23.05.00,22.11.04,22.05.11,21.11.19)
- [32597](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32597) Article requests not stacking in patron view (23.05.00,22.11.02,22.05.09)
- [32611](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32611) Not for loan items don't show the specific not for loan value in OPAC detail page (23.05.00,22.11.04)
- [32663](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32663) Street number should not allow for entering more than 10 characters in OPAC (23.05.00,22.11.04,22.05.11,21.11.19)
- [32679](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32679) CSS class article-request-title is doubled up in article requests list in staff patron account (23.05.00,22.11.04,22.05.11,21.11.19)
- [32701](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32701) Self checkout help page lacks required I18N JavaScript (23.05.00,22.11.06)
- [32946](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32946) 'Send list/cart' forms in OPAC is misaligned (23.05.00,22.11.04)
- [32995](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32995) Koha agent string not sent for OverDrive fulfillment requests (23.05.00,22.11.06)
- [32999](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32999) Click handler to show QR code in OPAC lacks preventDefault (23.05.00,22.11.04,22.05.11, 21.11.19)
- [33102](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33102) Cart in OPAC and staff interface does no longer display infos from biblioitems table (23.05.00,22.11.06)
- [33160](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33160) Make sure 773 (host item entry) displays in the cart when not linked by $w (23.05.00,22.11.05)
- [33233](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33233) OPAC advanced search inputs stay disabled when using browser's back button (23.05.00,22.11.06)
- [33299](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33299) Item type column is empty when placing item level holds in OPAC (23.05.00,22.11.05)
- [33821](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33821) OPAC flatpickr no longer allows for direct input of date (23.05.00)
- [33168](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33168) Timeline on "About Koha" is not working for package installs (23.05.00,22.11.05,22.05.12,21.11.20)
- [33371](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33371) Add 'koha-common.service' systemd service (23.05.00)
- [25379](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25379) HTML in circulation notes doesn't show correctly on checkin (23.05.00,22.11.06)
- [31166](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31166) Digest option is not selectable for phone when PhoneNotification is enabled (23.05.00,22.11.01, 21.11.16)
- [31492](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31492) Patron image upload fails on first attempt with CSRF failure (23.05.00,22.11.02,22.05.09, 21.11.16)
- [31890](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31890) PrefillGuaranteeField should include option to prefill surname (23.05.00,22.11.04)
  >This bugfix adds the surname field to the list of fields (in the PrefillGuaranteeField system preference) that can be automatically prefilled when adding a guarantee to a patron's account.
- [32232](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32232) Koha crashes if dateofbirth is 1947-04-27, 1948-04-25, or 1949-04-24 (23.05.00,22.11.06)
- [32491](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32491) Can no longer search patrons in format 'surname, firstname' (23.05.00,22.11.02,22.05.09)
- [32505](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32505) Cannot search by dateofbirth in specified dateformat (23.05.00,22.11.02,22.05.09)
- [32510](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32510) "New list" option is not available when too many patron's lists (23.05.00,22.11.05)
- [32570](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32570) City is duplicated in patron search if the patron has both city and state (23.05.00,22.11.03,22.05.10)
- [32655](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32655) Variables showing in patron messaging preferences (23.05.00,22.11.03,22.05.10,21.11.16)
- [32675](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32675) Cannot add a guarantor when there is a single quote in the guarantor attributes (23.05.00,22.11.04,22.05.11)
- [32770](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32770) Patron search field groups no longer exist (23.05.00,22.11.04,22.05.11)
- [32904](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32904) Patrons table processing eternally and not loading (23.05.00,22.11.04)

  **Sponsored by** *Education Services Australia SCIS*
- [32976](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32976) Patron image Add/Edit button should not appear if permission is turned off (23.05.00,22.11.05)
- [33155](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33155) Category and library filters from header patron search not taken into account (23.05.00,22.11.04,22.05.11)
- [33266](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33266) Patron name missing space before surname (23.05.00)
- [33684](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33684) Able to save patron with empty mandatory date fields (23.05.00,22.11.06)
- [30367](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30367) Plugins: Search explodes in error when searching for specific keywords (23.05.00,22.11.06)
- [33189](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33189) Plugin upload should prompt for .kpz files (23.05.00,22.11.04,22.05.11,21.11.19)
- [31160](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31160) Required fields in the Patrons API are a bit random (23.05.00,22.11.01)
- [32118](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32118) Clarify expansion/embed modifiers (23.05.00,22.11.04)
- [32409](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32409) Cannot search cashups using non-latin-1 scripts (23.05.00,22.11.03,22.05.10,21.11.16)
  >This fixes the cashup history table so that filters can use non latin-1 characters (Point of sale > Cash summary for <library> > select register). Before this fix, the table was not filtered or refreshed if you entered non latin-1 characters.
- [32923](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32923) x-koha-embed must a header of collectionFormat csv (23.05.00,22.11.04)
- [33227](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33227) OpenAPI validation is failing for paths/biblios.yaml (23.05.00,22.11.04)
- [33328](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33328) x-marc-schema should be renamed x-record-schema (23.05.00,22.11.06)
- [33329](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33329) GET /biblios encoding wrong when UNIMARC (23.05.00,22.11.06)
- [33470](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33470) Don't calculate overridden values when placing a hold via the REST API (23.05.00,22.11.06)
- [27513](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27513) Add description to reports page (23.05.00,22.11.05,22.05.13,21.11.21)
- [32589](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32589) Improve headings on result tables for 'checkouts with no items' report (23.05.00,22.11.03)
- [32805](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32805) When recording localuse in the statistics table location is always NULL (23.05.00,22.11.04)
- [33063](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33063) Duplicated reports should maintain subgroup of original (23.05.00,22.11.04,22.05.12,21.11.20)
- [33152](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33152) Set focus for cursor to search input box when creating new report from "New SQL from Mana" option (23.05.00)
- [33513](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33513) Batch update from report module - no patrons loaded into view (23.05.00,22.11.06)
- [33713](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33713) Report batch operations should open in new tab (23.05.00)
  >When using the batch operations from report results, the links to the batch tools will now open in a new tab instead of the same one, leaving the report results visible.
- [33792](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33792) reserves_stats.pl ignores filled holds without itemnumber (23.05.00)
- [32408](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32408) If a fine can be overridden on checkout in Koha, what should the SIP client do? (23.05.00,22.11.03,22.05.10)
- [32537](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32537) Add 'no_block' option to sip_cli_emulator (23.05.00,22.11.03,22.05.10)
  >This enhanced adds the no-block option to the SIP emulator for optional use in checkout/checkin/renew messages.
- [32624](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32624) Patrons fines are not accurate in SIP2 when NoIssuesChargeGuarantorsWithGuarantees or NoIssuesChargeGuarantees are enabled (23.05.00,22.11.03, 22.05.10,21.11.18)
- [33580](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33580) Bring back ability to mark item as seen via SIP2 item information request (23.05.00,22.11.06)
- [13976](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13976) Sorting search results by popularity is alphabetical (23.05.00,22.11.05,22.05.12,21.11.20)
  >This patch fixes the sorting of searches by popularity, ensuring that results are sorted numerically.
  >
  >Note: The popularity search requires the use of either the syspref UpdateTotalIssuesOnCirc or the update_totalissue.pl cronjob
- [20596](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20596) Authority record matching rule causes staging failure when MARC record contains multiple tag values for a match point (23.05.00,22.11.01,22.05.09, 21.11.16)
- [31326](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31326) Koha::Biblio->get_components_query fetches too many component parts (23.05.00,22.11.03)

  **Sponsored by** *Koha-Suomi Oy*
- [32639](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32639) OpenSearch description format document generates search errors (23.05.00,22.11.04,22.05.11,21.11.19)
- [33093](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33093) (Bug 27546 follow-up) With ES searching within results does not work for 'Keyword' and 'Keyword as phrase' (23.05.00,22.11.06)
- [33506](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33506) Series has wrong index name on scan index page and search option selection is not retained (23.05.00,22.11.06,22.05.13)
- [33569](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33569) Order by relevance may not be visible (23.05.00,22.11.06)
- [31471](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31471) Duplicate check in cataloguing fails with Elasticsearch for records with multiple ISBN (23.05.00,22.11.04,22.05.11,21.11.19)
- [31695](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31695) Type standard number is missing field ci_raw in field_config.yaml (23.05.00,22.11.05,22.05.13, 21.11.21)
- [32519](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32519) In Elasticsearch mappings table use search field name (23.05.00,22.11.04,22.05.12,21.11.20)
- [33206](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33206) Bad title__sort made of multisubfield 245 (23.05.00,22.11.06)
- [33486](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33486) Remove Koha::BackgroundJob::UpdateElasticIndex->process routine (23.05.00,22.11.06)
- [31841](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31841) Shelving location search in staff interface sometimes creates invalid Zebra query (23.05.00,22.11.05)
- [32416](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32416) arp - Accelerated reader point searches fail due to conflicting attribute (23.05.00,22.11.03,22.05.10,21.11.16)
  >This fixes
- [32741](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32741) Attribute codes should not be repeated in bib1.att (23.05.00,22.11.03,22.05.10,21.11.16)
- [32937](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32937) Zebra: Ignore copyright symbol when searching (23.05.00,22.11.06)
- [19188](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19188) Self checkout: Fine blocking checkout is missing currency symbol (23.05.00,22.11.03,22.05.10, 21.11.16)
- [32921](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32921) SelfCheckTimeout doesn't logout if SelfCheckReceiptPrompt modal is open (23.05.00,22.11.06,22.05.13)
- [33150](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33150) Add specific message for renewal too_soon situation (23.05.00,22.11.04,22.05.12,21.11.20)
- [33037](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33037) [Bugs 32555  and 31313 follow-up] Koha does not display difference between enumchron and serialseq in record detail view (OPAC and intranet) (23.05.00,22.11.06)
- [33040](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33040) Add "Date published (text)" to serials tab on record view (detail.pl) (23.05.00,22.11.05,22.05.13,21.11.21)
- [33261](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33261) Dates for issues on subscription detail page display unformatted (23.05.00,22.11.05)
- [33512](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33512) Labels/buttons are confusing on serials-edit page (23.05.00,22.11.06)
- [33560](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33560) Batch edit link broken if subscriptions are selected using "select all" link (23.05.00,22.11.06)
- [28314](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28314) Spinning icon is not always going away for local covers in staff (23.05.00,22.11.03,22.05.10, 21.11.16)
- [28315](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28315) PopupMARCFieldDoc is defined twice in addbiblio.tt (23.05.00,22.11.06)
- [31768](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31768) Tags is a 'Tool' but doesn't include the tools nav sidebar (23.05.00,22.11.03,22.05.10,21.11.18)
- [31950](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31950) Page section on library view is too wide / not aligned with toolbar (23.05.00,22.11.02)
- [31962](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31962) Add tooltip to 'configure' on datatable controls (23.05.00,22.11.03)
- [32027](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32027) Terminology: change "librarian interface" to "staff interface" in additional contents tool (23.05.00,22.11.03)
- [32194](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32194) "Can be guarantee" value should show uppercase "No" (23.05.00,22.11.01)
  >This fixes the display of the patron categories "Can be guarantee" column so that "No" values have a capital "N". Previously, "no" values were shown with a lowercase "n".
- [32236](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32236) Batch item modification - alignment of tick box for 'Use default values' (23.05.00,22.11.01)
- [32239](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32239) Report options for adding groups/sub groups are misaligned (23.05.00,22.11.03)
- [32257](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32257) Label for patron attributes misaligned on patron batch mod (23.05.00,22.11.01)
- [32261](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32261) Insufficient user feedback when selecting patron in autocomplete (23.05.00,22.11.01)
- [32272](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32272) Last borrower and previous borrower display on moredetail.pl is broken (23.05.00,22.11.02)
- [32301](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32301) Show correct defaultSortField in staff interface advanced search (23.05.00,22.11.05,22.05.13,21.11.21)
- [32355](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32355) Add class url to all URL syspref (23.05.00,22.11.01, 22.05.09, 21.11.16)
- [32368](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32368) Add page-section to saved report results (23.05.00,22.11.01)
- [32475](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32475) The phrase "System prefs" should be replaced with the correct terminology "System preferences" (23.05.00,22.11.02)
- [32504](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32504) Empty column name, misaligning visibility, and export for basket/orders in table settings (23.05.00,22.11.03)
- [32520](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32520) Patron autocomplete should respect DefaultPatronSearchFields (23.05.00,22.11.03)
- [32523](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32523) Shortcuts / Links to missing fields in MARC-Editor don't work as expected (23.05.00,22.11.03,22.05.10,21.11.18)
  >This fixes the standard MARC editor so that the links for any errors go to the correct tab. Currently, the links only work if you are the correct tab.
- [32568](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32568) Add page section to list of checkins (23.05.00,22.11.04)
  >This patch adds the page-section class to the checkedin table on the returns page.
- [32576](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32576) ILL needs the page-section treatment (23.05.00,22.11.04)
- [32596](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32596) Background jobs viewer not showing finished jobs (23.05.00,22.11.02,22.05.09)
- [32644](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32644) Terminology: staff/intranet and biblio in plugins home page (23.05.00,22.11.03,22.05.10, 21.11.16)
  >This patch replaces some incorrect terminology in the plugins home page regarding enhanced content plugins.
- [32718](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32718) Capitalization: Display Order (23.05.00,22.11.03)
- [32733](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32733) Add more page-sections to basket summary page (23.05.00,22.11.03)
- [32768](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32768) Autocomplete suggestions container should always be on top of other UI elements (23.05.00,22.11.04)
- [32797](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32797) Cannot save OAI set mapping rule for subfield 0 (23.05.00,22.11.03,22.05.10,21.11.16)
- [32881](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32881) System preferences sub menu text is hard to read (23.05.00,22.11.03)
- [32908](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32908) Item type icons broken in the bibliographic record details page (23.05.00,22.11.03)
- [32909](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32909) Item type icons broken when placing an item-level hold (23.05.00,22.11.03,22.05.11, 21.11.19)
- [32941](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32941) Sys prefs side menu styling applying where not intended (23.05.00,22.11.04)
- [32982](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32982) 'Add/Edit group' modals in library groups is missing it's primary button (23.05.00,22.11.04,22.05.11,21.11.19)
- [33032](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33032) Alternate holdings broken in staff interface search results (23.05.00,22.11.04,22.05.11,21.11.19)
- [33133](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33133) Fast cataloging should be visible in cataloging (23.05.00,22.11.05)
- [33191](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33191) AutoEmailPrimaryAddress options don't match labels in memberentry (23.05.00)
  >This enhancement changes the wording of the choices in the EmailFieldPrimary system preference (formely AutoEmailPrimaryAddress) to match the patron form field names.
  >The choices were changed like so:
  >- 'home' is now called 'primary email' and refers to the email database column
  >- 'work' is now called 'secondary email' and refers to the emailpro database column
  >- 'alternate' is still called 'alternate email' and refers to the B_email database column
  >- first valid and cardnumber did not change.
- [33253](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33253) 2FA - Form not excluded from autofill (23.05.00,22.11.06)
- [33391](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33391) Currently active menu item on navmenulist should not change style on hover (23.05.00,22.11.05)
- [33463](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33463) 'Actions' column on plugins table should not be sortable (23.05.00)
- [33505](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33505) Improve styling of scan index page (23.05.00,22.11.06,22.05.13)
- [33532](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33532) Catalog concerns - Title of the page says Tools instead of Cataloging (23.05.00)
  >This fixes the HTML page title for the cataloging concerns management page so that it says Catalog concerns > Cataloging > Koha (as it is under cataloging, not tools).
- [33588](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33588) Inventory item list is missing page-section class (23.05.00,22.11.06)
- [33590](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33590) WRAPPER tab_panel breaks JS on some pages (Select all/Clear all, post-Ajax updates) (23.05.00,22.11.06)
- [33596](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33596) Merge result page is missing page-section (23.05.00,22.11.06)
- [33615](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33615) Date picker icon not visible (23.05.00,22.11.06)
- [33621](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33621) Javascript error when claiming return via circulation.pl (23.05.00,22.11.06)
- [33631](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33631) results_summary label and content are slightly misaligned in staff interface (23.05.00,22.11.06)
- [33642](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33642) Typo: No log found . (23.05.00,22.11.06)
- [33643](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33643) Add page-section to 'scan index' page (23.05.00,22.11.06)
- [33788](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33788) Items tab shows all previous borrowers instead of 3 (23.05.00)
- [30694](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30694) Impossible to delete line in circulation and fine rules (23.05.00,22.11.02,22.05.09, 21.11.16)

  **Sponsored by** *Koha-Suomi Oy*
- [32291](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32291) "library category" messages should be removed (not used) (23.05.00, 22.11.01, 22.05.09, 21.11.16)
- [32535](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32535) BorrowerUnwantedField syspref should not include borrowers.flags (23.05.00,22.11.02)
- [32544](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32544) borrowers.flags should not be an option in any BorrowerMandatory or BorrowerUnwanted system preferences (23.05.00,22.11.03)
- [32745](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32745) Jobs view breaks when there are jobs with context IS NULL (23.05.00,22.11.06)
- [32761](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32761) Typos in description of CircControlReturnsBranch system preference (23.05.00,22.11.03)
- [32775](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32775) Ordering when there are multiple languages within a language group is wrong (23.05.00)

  **Sponsored by** *Kinder library, New Zealand*
- [32786](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32786) Curbside pickup admin page has cities search bar (23.05.00,22.11.03)
- [32787](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32787) Patron restrictions admin page has patron categories search bar (23.05.00,22.11.03)
- [32788](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32788) Curbside pickups - Order curbside pickup slots chronologically (23.05.00,22.11.03)
- [32803](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32803) EnableItemGroups and EnableItemGroupHolds options are wrong (23.05.00,22.11.04)
- [32964](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32964) OPACResultsMaxItemsUnavailable description is misleading (23.05.00,22.11.05)
- [33004](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33004) Add VENDOR_TYPE to default authorised value categories (23.05.00,22.11.04)
- [33060](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33060) Fix yes/no setting to 1/0 in system preference YAML files (23.05.00,22.11.04)
- [33196](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33196) Terminology: rephrase Pseudonymization system preference to be more general (23.05.00,22.11.06)
- [33197](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33197) Terminology: rename GDPR_Policy system preference (23.05.00,22.11.06)
- [33335](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33335) MARC overlay rules broken because of "categorycode.categorycode " which contains "-" (23.05.00,22.11.06)
- [33509](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33509) Staff search result list shows "other holdings" with AlternateHoldingsField when there are no alternate holdings (23.05.00,22.11.05,22.05.13,21.11.21)
- [33549](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33549) Patron restriction types - Style missing for dialog messages (23.05.00,22.11.06)
- [33586](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33586) Library and category are switched in table configuration for patron search results table settings (23.05.00,22.11.06)
- [33634](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33634) Sidebar navigation links in system preferences not taking user to the clicked section (23.05.00,22.11.06,22.05.13)
- [33673](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33673) Global system preferences - change to just system preferences (23.05.00)
- [33787](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33787) Remove option to archive system debit types (23.05.00)
- [22375](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22375) Due dates should be formatted consistently (23.05.00,22.11.06)
- [28235](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28235) Custom cover images are very large in staff search results and OPAC details (23.05.00,22.11.01)
- [31405](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31405) Set focus for cursor to setSpec input when adding a new OAI set (23.05.00,22.11.06)
- [31409](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31409) Set focus for cursor to Fund code when adding a new fund (23.05.00,22.11.05)
- [31410](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31410) Set focus for cursor to Server name when adding a new Z39.50 or SRU server (23.05.00,22.11.06)
- [31413](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31413) Set focus for cursor to Selector when adding a new audio alert (23.05.00,22.11.04,22.05.11,21.11.19)
- [31932](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31932) The basket summary page template needs a cleanup (23.05.00,22.11.03)
- [31994](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31994) Clicking the next button of a DataTable loading its data from the HTML does nothing (23.05.00,22.11.05)
- [32003](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32003) Accessibility: Order search results has two h1 headings (23.05.00,22.11.05)
- [32023](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32023) Remove horizontal line from OPAC navigation for CMS pages (23.05.00,22.11.03)
- [32061](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32061) <span> in the title of z39.50 servers page (23.05.00,22.11.01)
- [32074](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32074) Edit vendor has a floating toolbar, but still an additional save button at the bottom (23.05.00,22.11.01)
- [32127](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32127) Sort patron categories by description in templates (23.05.00,22.11.05,22.05.13)
- [32159](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32159) Uncertain prices has 2 level 1 headings (23.05.00,22.11.04)
- [32200](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32200) Add page-section checkout notes page (circ) (23.05.00,22.11.01)
- [32205](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32205) Unnecessary sysprefs used in template params for masthead during failed OPAC auth (23.05.00,22.11.04,22.05.11,21.11.19)
- [32213](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32213) Reindent item search fields template (23.05.00, 22.11.01)
- [32215](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32215) 'You Searched for' for patron restrictions is not used (23.05.00,22.11.04)
- [32217](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32217) Typo: Error authenticating in external provider (23.05.00,22.11.05)
- [32222](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32222) Capitalization: id (23.05.00,22.11.03)
- [32226](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32226) Capitalization: Edit html content (23.05.00,22.11.03)
- [32229](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32229) Typo: Items missing from bundle at checkin for %s (23.05.00,22.11.03)
- [32230](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32230) Capitalization: Manage Domains (23.05.00,22.11.03)
- [32263](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32263) Capitalization: ...and on the Libraries page in the OPAC. (23.05.00,22.11.05)
- [32264](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32264) Capitalization/Terminology: Show in Staff client? (23.05.00,22.11.03)
- [32282](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32282) Capitalization: User id (23.05.00,22.11.01)
- [32283](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32283) Capitalization: opac users of this domain to login with this identity provider (23.05.00,22.11.01)
- [32289](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32289) Punctuation: Delete desk "...?" (23.05.00,22.11.03,22.05.10)
- [32290](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32290) ILL requests uses some wrong terminology (23.05.00,22.11.03,22.05.10,21.11.18)
- [32293](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32293) Terminology: Some budgets are not defined in item records (23.05.00,22.11.04)
- [32294](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32294) Capitalization: Enter your User ID... (23.05.00,22.11.03,22.05.10,21.11.18)
- [32295](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32295) Punctuation: Filters : (23.05.00,22.11.03,22.05.10,21.11.18)
- [32300](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32300) Add page-section to cataloguing plugins (cat) (23.05.00,22.11.01)
- [32307](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32307) Chocolat image viewer broken in the staff interface when Coce is enabled (23.05.00,22.11.04,22.05.11, 21.11.19)
- [32320](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32320) Remove text-shadow from header menu links (23.05.00,22.11.01)
- [32323](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32323) Correct focus state of some DataTables controls (23.05.00,22.11.01)
- [32348](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32348) Library public is missing from columns settings (23.05.00,22.11.02,22.05.09, 21.11.16)
- [32378](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32378) Incorrect label for in identity provider domains (23.05.00,22.11.01)
- [32400](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32400) Add page-section to tables for end of year rollover (acq) (23.05.00,22.11.02)
- [32447](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32447) In items table barcode column can not be filtered (23.05.00,22.11.05)
- [32482](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32482) Reindent holds awaiting pickup template (23.05.00,22.11.03)
  >This tidies up the template used to display the holds awaiting pickup page (Circulation > Holds > Holds awaiting pickup). It also fixes the page so that the circulation sidebar is now shown.
- [32562](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32562) Reindent the about page template (23.05.00,22.11.03)
- [32586](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32586) Reindent items with no checkouts reports template (23.05.00,22.11.03)
- [32587](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32587) Add page-section to items with no checkouts report (23.05.00,22.11.03)
- [32605](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32605) Restore some form styling from before the redesign (23.05.00,22.11.03)
- [32606](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32606) Revert Flatpickr style changes made in Bug 31943 (23.05.00,22.11.03)
- [32616](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32616) Add 'page-section' to various acquisitions pages (23.05.00,22.11.02)
- [32618](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32618) Add 'page-section' to various administration pages (23.05.00,22.11.03)
- [32628](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32628) Add 'page-section' to various serials pages (23.05.00,22.11.02)
- [32632](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32632) Add 'page-section' to some tools pages (23.05.00,22.11.02)
- [32633](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32633) Add 'page-section' to cataloging and authority pages (23.05.00,22.11.03)
- [32634](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32634) Add 'page-section' to various pages (23.05.00,22.11.05)
- [32642](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32642) Loading spinner always visible when cover image is short (OPAC) (23.05.00,22.11.06,22.05.13,21.11.21)
- [32672](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32672) Incorrect CSS path to jquery-ui (23.05.00,22.11.03,22.05.10)
- [32690](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32690) Reindent the serial collection template (23.05.00,22.11.03)
- [32738](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32738) Correct upload local cover image title tag (23.05.00,22.11.03)
- [32743](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32743) Reindent the invoice details page (23.05.00,22.11.03)
- [32757](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32757) "Save changes" button on housebound tab should be yellow (23.05.00,22.11.04)
- [32771](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32771) Standardize structure around action fieldsets in serials (23.05.00,22.11.05)
- [32785](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32785) Typo: Maximum number of simultaneus pickups per interval (curbside pickups) (23.05.00,22.11.03)
- [32912](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32912) Use template wrapper for notices tabs (23.05.00,22.11.04)
- [32926](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32926) Cannot expand or collapse some System preference sections after a search (23.05.00,22.11.04,22.05.11,21.11.19)
- [32933](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32933) Use val() instead of attr("value") when getting field values with jQuery (23.05.00,22.11.04,22.05.11,21.11.19)
- [32945](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32945) Capitalization: id (part 2) (23.05.00,22.11.05)
- [32954](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32954) Standardize action fieldsets in rotating collections, suggestions, tools (23.05.00,22.11.05)
- [32955](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32955) Standardize structure around action fieldsets in various templates (23.05.00,22.11.05)
- [32956](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32956) Use template wrapper for HTML customizations tabs (23.05.00,22.11.05)
- [32969](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32969) Remove references to jQueryUI assets and style in the OPAC (23.05.00,22.11.05)
- [32973](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32973) Use template wrapper for breadcrumbs: about, main, and error page (23.05.00,22.11.04)
- [33001](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33001) Use template wrapper for breadcrumbs: Acquisitions part 2 (23.05.00,22.11.05)
- [33005](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33005) Use template wrapper for breadcrumbs: Acquisitions part 3 (23.05.00,22.11.05)
- [33006](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33006) Use template wrapper for breadcrumbs: Administration part 1 (23.05.00,22.11.05)
- [33007](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33007) Use template wrapper for breadcrumbs: Administration part 2 (23.05.00,22.11.05)
- [33011](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33011) Capitalization: Show in Staff interface? (23.05.00,22.11.04)
- [33015](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33015) 'Cancel' link still points to tools home when it should be cataloguing home on some pages (23.05.00,22.11.04)
- [33016](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33016) MARC diff view still shows tools instead of cataloging in title and breadcrumbs (23.05.00,22.11.04)
- [33048](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33048) Empty email link on error page when OPAC login not allowed (23.05.00,22.11.04,22.05.11,21.11.19)
- [33056](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33056) Terminology: change 'fine' to 'charge' when making a payment/writeoff (23.05.00,22.11.04)
- [33058](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33058) Terminology: change 'fine' to 'charge' for viewing a guarantee's charges in OPAC (23.05.00,22.11.04)
- [33095](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33095) Text is white on white when hovering over pay/writeoff buttons in paycollect (23.05.00,22.11.04)
- [33111](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33111) Use template wrapper for breadcrumbs: Administration part 4 (23.05.00,22.11.05)
- [33126](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33126) Markup error in staff interface tab wrapper (23.05.00,22.11.04)
- [33129](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33129) Use template wrapper for breadcrumbs: Administration part 6 (23.05.00,22.11.05)
- [33130](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33130) Use template wrapper for breadcrumbs: Authorities (23.05.00,22.11.05)
- [33131](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33131) Use template wrapper for breadcrumbs: Catalog part 1 (23.05.00,22.11.05)
- [33136](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33136) Catalog search pop-up is missing page-section (23.05.00,22.11.05)
- [33137](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33137) Make sure columns on transactions and 'pay fines' tab are matching up (23.05.00,22.11.05,22.05.12, 21.11.20)
- [33147](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33147) Use template wrapper for breadcrumbs: Catalog part 2 (23.05.00,22.11.05)
- [33148](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33148) Use template wrapper for breadcrumbs: Cataloging (23.05.00,22.11.05)
- [33149](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33149) Use template wrapper for breadcrumbs: Circulation part 1 (23.05.00,22.11.05)
- [33154](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33154) Tab WRAPPER follow-up: label text must be translatable (23.05.00,22.11.05)
- [33158](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33158) Use template wrapper for authorized values and item types administration tabs (23.05.00)
- [33180](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33180) Use template wrapper for tabs: Budgets and Search engine configuration (23.05.00,22.11.05)
- [33181](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33181) Use template wrapper for tabs on record merge pages (23.05.00,22.11.05)
- [33185](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33185) Use template wrapper for tabs on authority and biblio MARC details (23.05.00,22.11.05)
- [33186](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33186) Use template wrapper for tabs on search history and advanced search (23.05.00,22.11.05)
- [33187](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33187) Use template wrapper for tabs article requests and holds awaiting pickup pages (23.05.00,22.11.05)
- [33265](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33265) Additional unformatted navigation items when on serial receive page (23.05.00,22.11.05)
- [33272](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33272) Color of the "(remove)" link when an item is in the cart (OPAC) (23.05.00,22.11.05)
- [33278](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33278) Correct JS for activating default tab on various pages (23.05.00,22.11.05)
- [33293](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33293) Use template wrapper for tabs: Holds (23.05.00,22.11.05)
- [33294](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33294) Use template wrapper for tabs: Checkout history (23.05.00,22.11.05)
- [33307](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33307) Use template wrapper for tabs: Lists (23.05.00,22.11.05)
- [33320](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33320) Patron modification requests: options are squashed (23.05.00,22.11.06)
- [33322](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33322) "Please select at least one suggestion" when doing a catalog search from suggestions page (23.05.00,22.11.05)
- [33324](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33324) Use template wrapper for tabs: Tools (23.05.00,22.11.05)
- [33333](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33333) Use template wrapper for tabs: SQL reports (23.05.00,22.11.05)
- [33336](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33336) Use a dedicated column for plugin status in plugins table (23.05.00, 22.11.06)
- [33345](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33345) On-site checkout checkbox does not work since issue date using flatpickr (23.05.00,22.11.05)
- [33372](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33372) Use template wrapper for breadcrumbs: Circulation part 2 (23.05.00,22.11.05)
- [33373](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33373) Use template wrapper for breadcrumbs: Circulation part 3 (23.05.00,22.11.05)
- [33382](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33382) Use template wrapper for breadcrumbs: Patron clubs (23.05.00,22.11.05)
- [33383](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33383) Use template wrapper for breadcrumbs: Course reserves (23.05.00,22.11.05)
- [33384](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33384) Use template wrapper for breadcrumbs: Labels (23.05.00,22.11.05)
- [33385](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33385) Use template wrapper for breadcrumbs: Patrons part 1 (23.05.00,22.11.05)
- [33386](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33386) Use template wrapper for breadcrumbs: Patrons part 2 (23.05.00,22.11.05)
- [33387](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33387) Use template wrapper for breadcrumbs: Patrons part 3 (23.05.00,22.11.05)
- [33388](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33388) Use template wrapper for breadcrumbs: Patrons part 4 (23.05.00,22.11.06)
- [33389](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33389) Use template wrapper for breadcrumbs: Patrons part 5 (23.05.00,22.11.05)
- [33409](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33409) Use template wrapper for breadcrumbs: Patrons lists (23.05.00,22.11.05)
- [33410](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33410) Use template wrapper for breadcrumbs: Patron card creator (23.05.00,22.11.05)
- [33429](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33429) Use template wrapper for breadcrumbs: Plugins (23.05.00,22.11.05)
- [33434](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33434) Use template wrapper for breadcrumbs: Point of sale (23.05.00,22.11.05)
- [33436](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33436) Use template wrapper for breadcrumbs: Reports part 1 (23.05.00,22.11.05)
- [33437](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33437) Use template wrapper for breadcrumbs: Reports part 2 (23.05.00,22.11.06)
- [33438](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33438) Use template wrapper for breadcrumbs: Reports part 3 (23.05.00,22.11.06)
- [33439](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33439) Use template wrapper for breadcrumbs: Reports part 4 (23.05.00,22.11.06)
- [33551](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33551) Rogue span in patron restriction types admin page title (23.05.00,22.11.06)
- [33553](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33553) Unecessary GetCategories calls in template (23.05.00)
- [33555](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33555) Use template wrapper for breadcrumbs: Rotating collections (23.05.00,22.11.06)
- [33558](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33558) Use template wrapper for breadcrumbs: Serials part 1 (23.05.00,22.11.06)
- [33559](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33559) Use template wrapper for breadcrumbs: Serials part 2 (23.05.00,22.11.06)
- [33564](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33564) Use template wrapper for breadcrumbs: Serials part 3 (23.05.00,22.11.06)
- [33565](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33565) Use template wrapper for breadcrumbs: Tags (23.05.00,22.11.06)
- [33566](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33566) Use template wrapper for breadcrumbs: Tools, part 1 (23.05.00,22.11.06)
- [33571](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33571) Use template wrapper for breadcrumbs: Tools, part 2 (23.05.00,22.11.06)
- [33572](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33572) Use template wrapper for breadcrumbs: Tools, part 3 (23.05.00,22.11.06)
- [33579](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33579) Typo: record record (23.05.00,22.11.06,22.05.13)
- [33582](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33582) Use template wrapper for breadcrumbs: Tools, part 4 (23.05.00,22.11.06)
- [33597](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33597) Get rid of few SameSite warnings (23.05.00,22.11.06,22.05.13)
- [33598](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33598) Use template wrapper for breadcrumbs: Tools, part 5 (23.05.00,22.11.06)
- [33599](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33599) Use template wrapper for breadcrumbs: Various (23.05.00)
- [33600](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33600) Use template wrapper for breadcrumbs: Tools, part 7 (23.05.00,22.11.06)
- [33601](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33601) Use template wrapper for breadcrumbs: Tools, part 8 (23.05.00,22.11.06)
- [33696](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33696) Doubled up home icon in budgets page (23.05.00,22.11.06)
- [33699](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33699) Typo in identity_provider_domains.tt (presedence) (23.05.00,22.11.06)
- [33705](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33705) Tables have configure button even if they are not configurable (23.05.00)
- [33707](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33707) News vs Quote of the day styling on staff interface main page (23.05.00)
- [33721](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33721) Show inactive funds in invoice.tt out of order (23.05.00)
- [33735](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33735) Misspelling in SMS provier (23.05.00)
- [33769](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33769) Terminology:  'Warning: Item {barcode} is reserved' (23.05.00)
- [33797](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33797) Extra space in supplier.tt (23.05.00)
  >This removes the space between the field label and the colon for the notes field in the interfaces section for a vendor's details.
- [28670](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28670) api/v1/patrons_holds.t is failing randomly (23.05.00,22.11.02)
- [29274](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29274) z_reset.t is wrong (23.05.00,22.11.01)
- [32349](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32349) Remove TEST_QA (23.05.00,22.11.02,22.05.09, 21.11.16)
- [32350](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32350) We should die if TestBuilder is passed a column we're not expecting (23.05.00, 22.11.01)
- [32351](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32351) Fix all TestBuilder calls failing due to wrong column names (23.05.00, 22.11.01)
- [32352](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32352) xt/check_makefile.t failing on node_modules (23.05.00, 22.11.01)
- [32353](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32353) reserves.item_group_id should be undefined in tests by default (23.05.00,22.11.04)
- [32366](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32366) BatchDeleteBiblio task should have tests to prove indexing all takes place in one step (23.05.00,22.11.01)
- [32376](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32376) selenium/authentication_2fa.t produces artefact (23.05.00,22.11.03)
- [32622](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32622) Auth.t failing on D10 (23.05.00, 22.11.02, 22.05.09, 21.11.16)
- [32648](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32648) Search.t is failing if run after Filter_MARC_ViewPolicy.t (23.05.00,22.11.05)
- [32650](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32650) Koha/Holds.t is failing randomly (23.05.00,22.11.02)
- [32673](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32673) Remove misc/load_testing/ scripts (23.05.00,22.11.03)
- [32710](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32710) UI/Form/Builder/Item.t is failing randomly (23.05.00,22.11.05)
- [32979](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32979) Add Test::Exception to Logger.t (23.05.00,22.11.04,22.05.11, 21.11.19)
- [33054](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33054) Koha/Acquisition/Order.t is failing randomly (23.05.00,22.11.04)
- [33214](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33214) Make sure cache is cleared properly (23.05.00,22.11.04)
- [33235](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33235) Cypress tests are failing (23.05.00,22.11.04)
- [33263](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33263) selenium/patrons_search.t is failing randomly (23.05.00,22.11.04)
- [33402](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33402) ERM Cypress tests needs to be moved to their own directory (22.11.06)
- [33403](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33403) Letters.t: Foreign key exception if you do not have a numberpattern with id=1 (23.05.00,22.11.06)
- [33584](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33584) Fix failures for Database/Commenter.t on MySQL 8 (23.05.00)
- [33719](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33719) Search.t: too much noise about ContentWarningField (23.05.00)
- [33743](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33743) xt/find-missing-filters.t parsing files outside of git repo (23.05.00)
- [33777](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33777) Get Jenkins green again for Auth_with_shibboleth.t (23.05.00)
- [33834](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33834) api/v1/ill_requests.t fails randomly (23.05.00)
- [22428](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22428) MARC modification template cuts text to 100 characters (23.05.00,22.11.04)
- [26628](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26628) Clubs permissions should grant access to Tools page (23.05.00,22.11.03,22.05.10,21.11.16)
- [30869](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30869) Stock rotation rotas cannot be deleted (23.05.00,22.11.04)

  **Sponsored by** *PTFS Europe*
- [31585](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31585) "ACQUISITION ORDER" action missing from log viewer search form (23.05.00)
- [32041](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32041) OPAC and staff interface results page do not honor SyndeticsCoverImageSize (23.05.00,22.11.06,22.05.13)
- [32255](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32255) Cannot use file upload in batch record modification (23.05.00,22.11.02,22.05.09, 21.11.16)
- [32389](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32389) Syndetics links are built wrong on the staff results page (23.05.00,22.11.01,22.05.09)
- [32456](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32456) Date accessioned is now cleared when items are replaced (23.05.00,22.11.02,22.05.09)
- [32600](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32600) Housebound module needs page-section treatment (23.05.00,22.11.03)
- [32685](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32685) Display incorrect when matching authority records during import (23.05.00,22.11.04,22.05.11)
- [32967](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32967) Recalls notices are using the wrong database columns (23.05.00,22.11.04)

  **Sponsored by** *Catalyst*
- [33010](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33010) CheckinSlip doesn't return checkins if checkout library and checkin library differ (23.05.00)

  **Sponsored by** *Koha-Suomi Oy*
- [33637](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33637) Batch patron modification broken (23.05.00,22.11.06)
- [26433](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26433) Control number search option missing from SRU mapping options (23.05.00,22.11.05)
- [33231](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33231) (Bug 30813 follow-up) No publication date nor edition statements in Z39.50 biblio search results (23.05.00,22.11.05)

## New system preferences

- ActionLogsTraceDepth
- AuthorityXSLTOpacDetailsDisplay
- AutomaticConfirmTransfer
- CatalogConcerns
- CatalogerEmails
- ContentWarningField
- EmailFieldPrecedence
- EmailFieldPrimary
- HoldsQueuePrioritizeBranch
- LinkerConsiderThesaurus
- OpacCatalogConcerns
- OPACShowSavings
- PrivacyPolicyConsent
- StripWhitespaceChars
- UpdateNotForLoanStatusOnCheckout

## Deleted system preferences

- AutoEmailPrimaryAddress (replaced by EmailFieldPrimary)
- AutomaticWrongTransfer (replaced by AutomaticConfirmTransfer)
- GDPR_Policy (replaced by PrivacyPolicyConsent)
- ManInvInNoissuesCharge
- RentalsInNoissuesCharge

## New Authorized value categories

- ERM_AGREEMENT_CLOSURE_REASON
- ERM_AGREEMENT_LICENSE_LOCATION
- ERM_AGREEMENT_LICENSE_STATUS
- ERM_AGREEMENT_RENEWAL_PRIORITY
- ERM_AGREEMENT_STATUS
- ERM_AGREEMENT_USER_ROLES
- ERM_LICENSE_STATUS
- ERM_LICENSE_TYPE
- ERM_PACKAGE_CONTENT_TYPE
- ERM_PACKAGE_TYPE
- ERM_TITLE_PUBLICATION_TYPE
- ERM_USER_ROLES (replacing ERM_AGREEMENT_USER_ROLES)
- ILL_STATUS_ALIAS (replacing ILLSTATUS)
- VENDOR_INTERFACE_TYPE
- VENDOR_TYPE

## New letter codes

- CART
- LIST
- TICKET_ACKNOWLEDGE
- TICKET_NOTIFY
- TICKET_RESOLVE
- TICKET_UPDATE

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (71.2%)
- Armenian (100%)
- Armenian (Classical) (64%)
- Bulgarian (92.2%)
- Chinese (Taiwan) (81.2%)
- Czech (58.2%)
- English (New Zealand) (67.5%)
- English (USA)
- Finnish (95.8%)
- French (98.1%)
- French (Canada) (97.1%)
- German (100%)
- Hindi (100%)
- Italian (91%)
- Nederlands-Nederland (Dutch-The Netherlands) (80.9%)
- Norwegian Bokmål (67.5%)
- Persian (75.7%)
- Polish (91.8%)
- Portuguese (89.5%)
- Portuguese (Brazil) (100%)
- Russian (93.8%)
- Slovak (61.1%)
- Spanish (100%)
- Swedish (81.8%)
- Telugu (76.4%)
- Turkish (86.3%)
- Ukrainian (77.2%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 23.05.00 is


- Release Manager: Tomás Cohen Arazi

- Release Manager assistants:
  - Jonathan Druart
  - Martin Renvoize

- QA Manager: Katrin Fischer

- QA Team:
  - Aleisha Amohia
  - Nick Clemens
  - David Cook
  - Jonathan Druart
  - Lucas Gass
  - Victor Grousset
  - Kyle M Hall
  - Martin Renvoize
  - Marcel de Rooy
  - Fridolin Somers

- Topic Experts:
  - UI Design -- Owen Leonard
  - Zebra -- Fridolin Somers
  - REST API -- Martin Renvoize

- Bug Wranglers:
  - Aleisha Amohia
  - Indranil Das Gupta

- Packaging Manager: Mason James

- Documentation Manager: Caroline Cyr La Rose

- Documentation Team:
  - Aude Charillon
  - David Nind
  - Lucy Vaux-Harvey

- Translation Manager: Bernardo González Kriegel


- Wiki curators: 
  - Thomas Dukleth
  - Katrin Fischer

- Release Maintainers:
  - 22.11 -- PTFS Europe (Martin Renvoize, Matt Blenkinsop, Jacob O'Mara, Pedro Amorim)
  - 22.05 -- Lucas Gass
  - 21.11 -- Arthur Suzuki
  - 21.05 -- Wainui Witika-Park

## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 23.05.00

- [Association KohaLa](https://koha-fr.org)
- Auckland University of Technology
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ)
- [Bibliothèque Universitaire des Langues et Civilisations (BULAC)](http://www.bulac.fr)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)
- Education Services Australia SCIS
- Gothenburg University Library
- Horowhenua Libraries Trust
- Kinder library, New Zealand
- [Koha-Suomi Oy](https://koha-suomi.fi)
- Koha-US
- Médiathèque de Montauban
- [PTFS Europe](https://ptfs-europe.com)
- Pymble Ladies' College
- [The New Zealand Institute for Plant and Food Research Limited](https://www.plantandfood.com/en-nz/)
- The Research University in the Helmholtz Association (KIT)
- Toi Ohomai Institute of Technology, New Zealand
- Virginia Polytechnic Institute and State University
- Waikato Institute of Technology

We thank the following individuals who contributed patches to Koha 23.05.00

- Axel Amghar (1)
- Aleisha Amohia (26)
- Pedro Amorim (54)
- Tomás Cohen Arazi (210)
- Alex Arnaud (2)
- Andrew Auld (3)
- Matt Blenkinsop (31)
- Jérémy Breuillard (3)
- Alex Buckley (15)
- Kevin Carnes (1)
- Galen Charlton (1)
- Nick Clemens (152)
- David Cook (26)
- Frédéric Demians (5)
- Paul Derscheid (2)
- Jonathan Druart (282)
- Magnus Enger (7)
- Laura Escamilla (1)
- Katrin Fischer (163)
- Géraud Frappier (1)
- Andrew Fuerste-Henry (2)
- Lucas Gass (63)
- Didier Gautheron (2)
- Victor Grousset (1)
- Thibaud Guillot (6)
- David Gustafsson (2)
- Michael Hafen (3)
- Kyle M Hall (66)
- Mark Hofstetter (1)
- Olivier Hubert (1)
- Mason James (8)
- Andreas Jonsson (1)
- Janusz Kaczmarek (8)
- Pasi Kallinen (1)
- Jan Kissig (1)
- Emily Lamancusa (1)
- Owen Leonard (158)
- The Minh Luong (1)
- Marius Mandrescu (1)
- Julian Maurice (80)
- Matthias Meusburger (3)
- Josef Moravec (1)
- Agustín Moyano (20)
- David Nind (8)
- Jacob O'Mara (4)
- Philip Orr (5)
- Mona Panchaud (1)
- Johanna Raisa (2)
- Martin Renvoize (111)
- Phil Ringnalda (2)
- Marcel de Rooy (99)
- Caroline Cyr La Rose (17)
- Andreas Roussos (4)
- Slava Shishkin (6)
- Maryse Simard (1)
- Fridolin Somers (28)
- Adam Styles (1)
- Emmi Takkinen (6)
- Lari Taskula (1)
- Clemens Tubach (1)
- Petro Vashchuk (1)
- George Veranis (1)
- Shi Yao Wang (3)
- Jenny Way (1)
- Hammat Wele (5)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 23.05.00

- Athens County Public Libraries (158)
- BibLibre (125)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (163)
- ByWater Solutions (282)
- Catalyst (15)
- Catalyst Open Source Academy (26)
- Chetco Community Public Library (2)
- Dataly Tech (5)
- David Nind (8)
- Denver university Colorado Library (2)
- Equinox Open Library Initiative (1)
- Education Services Australia (1)
- Göteborgs Universitet (2)
- hofstetter.at (1)
- Hypernova Oy (1)
- Independant Individuals (22)
- Karlsruher Institut für Technologie (1)
- Koha Community Developers (283)
- Koha-Suomi (7)
- KohaAloha (8)
- Kreablo AB (1)
- Libriotech (7)
- LMSCloud (7)
- Lunds Universitet (1)
- Montgomery County Public Libraries (1)
- mpan.ch (1)
- Prosentient Systems (26)
- PTFS-Europe (203)
- Rijksmuseum (99)
- Solutions inLibro inc (30)
- Tamil (5)
- Technische Hochschule Wildau (1)
- Theke Solutions (230)

We also especially thank the following individuals who tested patches
for Koha

- Michael Adamyk (1)
- Hugo Agud (1)
- Aleisha Amohia (12)
- Pedro Amorim (80)
- Anke Bruns (1)
- Tomás Cohen Arazi (1491)
- Andrew Auld (30)
- Bob Bennhoff (1)
- Catrina Berka (1)
- Matt Blenkinsop (51)
- Philippe Blouin (1)
- Christopher Brannon (5)
- Felicity Brown (2)
- Alex Buckley (1)
- Kevin Carnes (1)
- Axelle Clarisse (2)
- Nick Clemens (233)
- Bob Bennhoff - CLiC (7)
- David Cook (16)
- Chris Cormack (2)
- Frédéric Demians (6)
- Paul Derscheid (10)
- Harold Dramer (1)
- Jonathan Druart (234)
- Magnus Enger (15)
- Laura Escamilla (21)
- Jonathan Field (16)
- Katrin Fischer (347)
- Ann Flournoy (2)
- Andrew Fuerste-Henry (42)
- Brendan Gallagher (1)
- Lucas Gass (107)
- Amaury Gau (3)
- Nicolas Giraud (1)
- Victor Grousset (19)
- Amit Gupta (1)
- Kyle M Hall (203)
- Frank Hansen (9)
- Evelyn Hartline (1)
- Sally Healey (17)
- Juliet Heltibridle (1)
- Heather Hernandez (8)
- Mason James (3)
- Barbara Johnson (21)
- Janusz Kaczmarek (2)
- Jan Kissig (4)
- Emily Lamancusa (6)
- Sam Lau (1)
- Owen Leonard (64)
- LMSCloudPaulD (1)
- Marius Mandrescu (4)
- Marie-Luce (7)
- Julian Maurice (3)
- Johanna Miettunen (1)
- ml-inlibro (1)
- Agustín Moyano (41)
- Solene Ngamga (3)
- David Nind (385)
- Andrew Nugged (4)
- Jacob O'Mara (2)
- Helen Oliver (22)
- Jacob Omara (1)
- Philip Orr (6)
- Pascal (1)
- Séverine Queune (1)
- Laurence Rault (2)
- Martin Renvoize (276)
- Phil Ringnalda (13)
- Marcel de Rooy (144)
- Caroline Cyr La Rose (40)
- Lisette Scheer (2)
- Danyon Sewell (1)
- Michaela Sieber (32)
- Fridolin Somers (18)
- Alexandra Speer (1)
- Emmi Takkinen (4)
- Thibault (3)
- Clemens Tubach (1)
- George Veranis (1)
- Hinemoea Viault (5)
- Hammat Wele (7)

We thank the following individuals who mentored new contributors to the Koha project

- Martin Renvoize

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Notes from the Release Manager

This was supposed to be a quiet release, fixing things the challenging previous release had left unpolished...

... but it wasn't. We cannot help but want to move faster and provide the users with more and more features.

We have several new contributors and developers, with new questions and points of view, pushing us to give the best and do better each day.

Thanks to everyone for the chance to be part of this, and for being around when the community needs you.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is clean_master.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 31 May 2023 18:33:36.
