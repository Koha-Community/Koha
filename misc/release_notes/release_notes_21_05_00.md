# RELEASE NOTES FOR KOHA 21.05.00
28 May 2021

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 21.05.00 can be downloaded from:

- [Download](http://download.koha-community.org/koha-21.05-latest.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 21.05.00 is a major release, that comes with many new features.

It includes 6 new features, 248 enhancements, 449 bugfixes.

A <b>Technical highlights</b> section is included at the bottom of these notes for those seeking a short summary of the more technical changes included in this release.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations

## Significant changes

### Accounting

Work has continued on refactoring the accounting code this cycle.  The 'Point of sale' and 'Cash management' features have been further enhanced to better expose cash-up functionality to the user interface and aid in auditing processes and effort has been made to ensure all accountline actions are properly recording using double entry accounting methods with offsets to link income to debts.

### Transfers

A significant amount of work has gone into refactoring the transfers system to enable future enhancements and improve maintainability.  Transfers can now be queued and a priority system exists for the various mechanisms that can trigger a transfer. Additionally, an audit trail is now left in place to allow future debugging to take place. This has helped us to resolve a number of long standing bugs and edge cases in the transfers process.

### Accessibility

Work has continued to make Koha more accessible:

- Title elements on the OPAC and staff client now start with the most unique information first
- The structure of headings on the OPAC has improved and headings are now more descriptive
- Breadcrumbs on the staff interface now show the most unique information first
- The OPAC has improved labelling to make it more accessible to people using screen readers

### PayPal support

Paypal support has been dropped from Koha core and moved to a plugin [[23215]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23215)


## New features

### Acquisitions

- [[20212]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20212) Improve performance of acquisitions receive page

  >This development changes how the orders table on receiving in acquisitions is rendered.
  >Before these patches all active orders data was fetched from the database, along with all the related data (patrons, biblio). This leads to significant delays because all orders matching the filtering criteria were loaded, even when only 20 rows were displayed on the UI.
  >With this patch, the table is rendering using server-side pagination, provided by the REST API. This means
  >(1) only the information to be rendered is fetched (faster drawing
  >(2) the page doesn't reload anymore when a new filter is added: it just refreshes the table, very fastly.
  >
  >Sponsored by: Camden County Library System
  >
  >Sponsored by: ByWater Solutions
- [[22773]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22773) Bulk close invoices and filter invoice view (open/closed)

  >This new feature splits the view of the invoice search results into opened and closed tables and adds the ability to bulk close or reopen invoices.

### Cataloging

- [[11299]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11299) Add a button to automatically link authority records in cataloguing (AJAX)

  >This patch adds a new button to the basic MARC editor. When clicked this button will run through all controlled fields in the MARC record and search the existing authority file to link them to authorities. Depending on system preferences unmatched headings will create new authorities or remain unlinked. Results will be highlighted so that the cataloguer can see what was done.

### MARC Bibliographic data support

- [[8976]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8976) Default sequence of subfields in cataloguing and item editor

  **Sponsored by** *Orex Digital*

  >This new enhancement adds the ability to change the default order of the subfields.
  >
  >Both bibliographic and authority MARC subfield structure are taken into account. And so the item edition as well.
  >
  >This will answer, for instance, the following needs:
  > - $i in 7xx fields should be the first subfield in the sequence
  > - 300 fields are sorted number first when cataloguers enter the letter fields first
  > - 100 field, it's commonly $a, $q, $d.

### Staff Client

- [[22569]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22569) Add a 'Transfers to send' report

  >This enhancement adds a 'Transfers to send' report to the circulation module.
  >
  >This is a parallel for the 'Transfers to receive' report and lists all items that are set to transfer but not yet in transit (along with their transfer reason and whether they're available to be picked from the shelves or currently checked out).

### System Administration

- [[26633]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26633) Add advanced editor for transfer limits

  >This enhancement adds an "advanced" editor for transfer limits that displays all to/from library combinations in a grid and allows them to be edited in a manner somewhat similar to the transport cost matrix editor.

## Enhancements

### Acquisitions

- [[23971]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23971) Add logging for basket related actions

  >This enhancement adds back the `AcquisitionsLog` preference and when enabled it adds logging for the following actions:
  >
  >* Adding new baskets
  >* Re-opening closed baskets
  >* Modifying baskets
  >* Modifying basket headers
  >* Modifying basket users
  >* Closing baskets
  >* Approving baskets
- [[26630]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26630) Allow custom text for each library on the purchase suggestion page

  >Enhancement to allow for custom text at the top of the purchase suggestion screen which can be administered via the Koha news tool.
- [[27023]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27023) Add class names in the suggestions column in suggestions management

  >This enhancement adds classes to the various information spans displayed in the suggestions table. This allows for simple targeting of CSS rules to highlight or hide information that is important/irrelevant for your library's use.
- [[27240]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27240) Export basket: remove spaces and don't export links

  >A simple template cleanup to improve code legibility and remove superfluous whitespace when exporting data using the table features. Also removes links from the exported data.
- [[27606]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27606) Breadcrumbs on parcel.pl should include a link to the vendor

  >Updates the breadcrumb on the orders to receive page from:
  >
  >Home > Acquisitions > Receive orders from My Vendor
  >
  >to
  >
  >Home > Acquisitions > My vendor > Receive orders
  >
  >This improves consistency and aids navigation.
- [[27646]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27646) Allow export of acquisitions home and funds table
- [[27793]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27793) Store Contents of FTX segment of EDI quotes for inclusion in orders

  >This enhancement adds support for the EDI FTX (FreeText) segment in Edifact ordering. We simply store the segment and pass it around in the EDI process required.
- [[27794]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27794) Add link to biblio in lateorders page

  >This patch modifies the display of bibliographic records in the acquisitions report of late orders so that the title of the record is a link to the corresponding bibliographic details page.

### Architecture, internals, and plumbing

- [[22824]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22824) Replace YAML::Syck with YAML::XS

  >To bring consistency to the codebase, improve performance and reduce dependencies it was decided we should converge on a single YAML parsing library... we opted for YAML::XS.
- [[23271]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23271) Koha::Patron::Category should use Koha::Object::Limit::Library

  >This enhancement makes Koha::Patron::Categories inherit the
  >'search_with_library_limits' method from Koha::Objects::Limit::Library and thus makes it consistent with other locations where filtering by branch is required.
- [[23583]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23583) Handle OpacHiddenItems with yaml_preference
- [[23830]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23830) Koha::AuthorisedValues should use Koha::Objects::Limit::Library

  >This enhancement makes Koha::AuthorisedValues inherit the
  >'search_with_library_limits' method from Koha::Objects::Limit::Library and thus makes it consistent with other locations where filtering by branch is required.
- [[24254]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24254) Add Koha::Items->filter_by_visible_in_opac

  >This patch introduces an efficient way of filtering Koha::Items result sets, to hide items that shouldn't be exposed on public interfaces.
  >
  >Filtering is governed by the following system preferences. A helper method is added to handle lost items:
  >- hidelostitems: Koha::Items->filter_out_lost is added to handle this.
  >
  >Some patrons have exceptions so OpacHiddenItems is not enforced on them. That's why the new method [1] has an optional parameter that expects the logged in patron to be passed in the call.
  >
  >[1] Koha::Items->filter_by_visible_in_opac
- [[25026]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25026) RaiseError must be set for the UI

  >Turning on RaiseError for the UI will propagate the SQL errors to the UI. That will prevent errors to silently fail and let developers catch issues that could exist in our codebase.
- [[25670]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25670) Add useful methods to Koha::Acquisition::Orders

  >This architectural enhancement adds helpful filter methods to the Koha::Acquisitions:: modules to ease the development of Acquisitions API's and future acquisitions related enhancements.
- [[25755]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25755) Add a Koha::Item->request_transfer method

  >This work adds a `request_transfer` method to `Koha::Item` that allows a transfer to be requested.
  >
  >The method will throw exceptions for missing parameters and it obeys the transfer limits.
  >
  >Optionally, one can pass 'ignore_limits' and 'enqueue'/'replace' parameters to override the transfer limits and handle cases where a transfer request may already exist.
- [[25757]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25757) Add a Koha::Item::Transfer->transit method

  >This patch adds the `Koha::Item->transit` method which can be used to progress a transfer from 'requested' to 'in_transit'.
  >
  >The method will throw an exception if the item is not checked in and will handle `CartToShelf` and update `DateLastSeen` as well as updating the 'frombranch' if required.
  >
  >We also add some sugar methods to allow easy navigation between the 'Transfer' and it's respective 'Item'.
- [[25767]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25767) Add Koha::Item::Transfer->receive method

  >This enhancement adds the `Koha::Item::Transfer->receive` method to allow recording the receipt of a transfer at its destination.
  >
  >The method will throw an exception if the item is not checked in and it also handles setting DateLastSeen.
- [[25802]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25802) Koha::Calendar->addDate should be renamed addDuration to better reflect it's purpose
- [[26057]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26057) Add Koha::Item::Transfer->cancel method

  >This enhancement adds the `Koha::Item::Transfer->cancel` method to allow audited cancellation of item transfers.
  >
  >This patch introduces the `datecancelled` and `cancellation_reason` fields to branchtransfers for tracking when and why a transfer was cancelled.
- [[26481]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26481) Add Koha::Item::Transfer->in_transit method

  >This enhancement adds the `Koha::Item::Transfer->in_transit` helper method to quickly identify transfers that are in progress.
- [[26618]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26618) C4/RotatingCollections.pm should not use C4::Circulation::transferbook

  >This enhancement updates the Rotating Collections system to use the recently introduced Koha:: methods for Item Transfers.
  >
  >We expose some extra feedback to the end user to highlight where transfers would have previously failed silently when used in combination with other systems that trigger transfers.
- [[26950]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26950) Checkin failure messages are unclear or too specific
- [[27069]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27069) Change holdallowed values from numbers to strings
- [[27131]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27131) Move code from circ/pendingreserves.pl to modules
- [[27246]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27246) Remove apache only code from C4::Context BEGIN
- [[27268]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27268) Move C4::Biblio::GetMarcNotes to Koha namespace

  **Sponsored by** *Bibliotheksservice-Zentrum Baden-Württemberg (BSZ)*
- [[27281]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27281) Replace call to `C4::Circulation::DeleteTransfer` with `Koha::Item::Transfer->cancel({ comment => $comment })` in `C4::Circulation::LostItem`
- [[27485]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27485) Rename system preference gist to TaxRates
- [[27486]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27486) Rename system preference delimiter to CSVDelimiter
- [[27487]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27487) Rename system preference reviewson to OPACComments

  >This renames the existing system preference 'reviewson' to 'OPACComments' which better reflects its use.
- [[27491]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27491) Rename system preference opaclanguages  to OPACLanguages
- [[27636]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27636) Replace Koha::Account::pay with a simpler method

  >This enhancement adds the new 'payin_amount' method to Koha::Account.
  >
  >This method utilises the well tested 'Koha::Account->add_credit' and 'Koha::Account::Line->apply' methods to achieve consistent results when paying in credit against debts.
  >
  >The original 'pay' method now uses payin_amount internally and will be left intact for a deprecation period.
- [[27673]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27673) Replace YAML with YAML::XS

  >Replaces uses of YAML module with more widely supported YAML::XS module.
- [[27756]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27756) background_jobs_worker.pl is memory inefficient
- [[27833]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27833) Koha::Exceptions::Patron::Attribute::* should have parameters

  >This development adds parameters to the extended attributes-related exceptions. This allows better handling.
- [[27851]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27851) Add Koha::Old::Checkouts->filter_by_todays_checkins method
- [[27896]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27896) Remove C4::Circulation::DeleteTransfer

  >This patch replaces calls to DeleteTransfer with Koha::Item::Transfer->cancel and then removes C4::Circulation::DeleteTransfer entirely.
  >
  >This brings two advantages:
  >1. Better auditing of transfers by recording reasons for cancellation and throwing suitable errors for various conditions
  >2. Cleaning code from the overburdened C4::Circulation module.
- [[27930]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27930) Move _escape_* functions from acq/parcel.tt to be re-usable

  >This enhancement moves the useful `_escape_price` and `_escape_str` functions found in acq/parcel.tt into the re-usable staff-global.js include file.
- [[27995]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27995) Koha::Account::Line->apply should return the update Koha::Account::Line object
- [[28056]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28056) Add Koha::Exceptions::Patron::MissingMandatoryExtendedAttribute

  >This patch adds a new exception for more fine-grained control on the errors when dealing with patrons and their extended attributes.
- [[28210]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28210) C4::Circulation::LostItem should pass through skip_record_index to MarkIssueReturned
- [[28278]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28278) Improve $KOHA_CONF parsing speed by using XML::LibXML
- [[28386]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28386) Replace dev_map.yaml from release_tools with .mailmap

### Authentication

- [[18506]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18506) SSO - Shibboleth Only Mode

  >This enhancement adds a system preference to allow libraries to enable shibboleth to work as the only authentication method available for their library and as such practice fully devolved authentication.
  >
  >When combined with the OpacPublic preference, this can be used to enable seamless Single Sign On, where the user simply browses to the OPAC in their web browser and if already logged in on their domain they will automatically be logged in in koha too.

### Cataloging

- [[23302]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23302) Less clicks on Z3950 search results

  >On the three forms where we use Z3950 search results, in acquisitions and cataloguing for authorities as well as biblios, the form remembers your last choice for Card or MARC view.
  >
  >Note that this adds a new key in localStorage of your browser: z3950search_last_action.
- [[24108]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24108) Configure if biblionumber or control number is used for saved files from detail page or advanced cataloguing editor

  >This enhancement lets you choose how a record is named when saving it as a MARC or MARCXML file using the advanced cataloguing editor or the download option from the staff interface detail page.
  >
  >Using the new system system preference "DefaultSaveRecordFileID" choose:
  >- the bibliographic record number (the default): the file is saved as bib-{biblionumber}.{format}, or
  >- the control number (001 field): the file is saved as as record-{controlnumber}.{format}.
- [[26943]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26943) Show not for loan descriptions in cataloging search (addbooks.pl)

  >Adds the ability to see not for loan descriptions in the cataloging search results.
- [[27422]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27422) HTML5Media is http by default but Youtube is https only

  **Sponsored by** *Banco Central de la República Argentina*
- [[27545]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27545) NewItemsDefaultLocation is only used from additem.pl

  >The NewItemsDefaultLocation syste prefernce setting is now also used when adding items in the serials or acquisition module or when importing items through the staged MARC import tools.
- [[27980]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27980) Replace obsolete title-string sorting: Catalog templates
- [[28035]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28035) Improve breadcrumbs of cataloging search page
- [[28179]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28179) Use a lightbox gallery to display the images - detail page, staff interface

  **Sponsored by** *Gerhard Sondermann Dialog e.K. (presseplus.de, presseshop.at, presseshop.ch)*

  >This enhancement adds the ability to display the cover images of a bibliographic record in a gallery. Cover images attached to items are also displayed in separated galleries.

### Circulation

- [[12224]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12224) Allow easy printing of patron check-in slip

  **Sponsored by** *Bibliotheksservice-Zentrum Baden-Württemberg (BSZ)*

  >This allows to print a checkin slip with information about all of the items a patron has checked in that day from the checkin page in the staff client. It uses a new notice template with the letter code CHECKINSLIP.
- [[18532]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18532) Messaging preferences for auto renewals

  >This patchset adds messaging preferences for controlling auto renewal notifications. This allows more fine-grained control on auto renewal notifications.
  >
  >A new letter is added to the existing AUTO_RENEWALS one, for digest notifications  (AUTO_RENEWALS_DIGEST).
- [[18912]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18912) Show more item information when using itemBarcodeFallbackSearch

  >When using itemBarcodeFallbacksearch to checkout items with an unknown or non-existing barcode, the table with items matching the search criteria didn't contain a lot of information about the items. This patch adds several columns to make it easier to pick the correct item for checkout: callnumber, copy number, serial enumeration, inventory number, collection, and item type.
- [[21883]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21883) Show authorized value description for withdrawn in check-in

  >This adds the description of the withdrawn status to the message that is displayed when a withdrawn item is returned.
- [[23207]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23207) Allow automatic checkin/return at end of circulation period

  >This adds a new configuration option to the itemtype administration page: Automatic checkin. With automatic checkin enabled the item will be automatically checked in at its due date.
  >In order for this feature to work correctly, the automatic_checkin.pl cronjob needs to be set up on your installation.
- [[26937]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26937) Add an optional delay to the CheckPrevCheckout system preference

  >This adds a new system preference CheckPrevCheckoutDelay that allows to specify a number of days that is used with the CheckPrevCheckout feature to determine, if a warning should be shown or not. If the checkin date of the item that is about to be checked out is longer ago than CheckPrefCheckoutDelay days, no warning will be displayed.
- [[27306]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27306) Add subtitle to return claims table
- [[27924]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27924) Display number of holds awaiting pickup on check out screens

  >This patch changes the way waiting holds are displayed on the checkout screen. Holds waiting at the current library will now be displayed separately from holds waiting at other libraries, with a count shown for each group.
- [[28034]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28034) Add DataTables to lists of clubs in "Clubs" tabs on patron account

### Command-line Utilities

- [[15986]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15986) Add a script for sending hold waiting reminder notices

  >This patch adds a new script (holds_reminder.pl) for sending holds reminder notices to patrons. The script is intended to be run as a cronjob and takes several parameters:
  >days - after how many days waiting to send the notice
  >lettercode - to specify which notice is used
  >library - (repeatable) to specify which branches to send notices from
  >holidays - to specify that holidays should not be counted as waiting days
  >mtt - (message transport type) to specify which notice format to use, i.e. print, email, etc.
  >date - to run the script as it would have been on a specific date
  >n    - no emails - test mode, report only, do not send notices
- [[24272]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24272) Add a command line script to compare the syspref cache to the database

  >This script checks the value of the system preferences in the database against those in the cache. Generally differences will only exist if changes have been made directly to the DB or the cache has become corrupted.
- [[24541]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24541) Database clean-up: purge messages

  >Adds a new option to the cleanup_database.pl cron job to schedule deletion of messages added to patron accounts.
- [[26459]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26459) Allow sip_cli_emulator to handle cancelling holds
- [[27048]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27048) Add timestamps to verbose output of rebuild_zebra.pl
- [[27049]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27049) Add a script to bulk writeoff debts

  >This new script can be scheduled to writeoff user debts prior to the `delete_patrons.pl` script attempting to remove them.
  >
  >Example: ./writeoff_debts.pl --added_before $(date -d '-18 month' --iso-8601) --confirm
- [[27050]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27050) Allow multiple category_codes in delete_patrons.pl

  **Sponsored by** *Lund University Library*

  >This enhancement allows the use of multiple patron category codes in the delete_patrons.pl script. For example, delete_patrons.pl --category_code PT --category_code ST
- [[27839]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27839) koha-worker missing tab-completion in bash

### Fines and fees

- [[16486]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16486) Display the TIME a fine was collected/written off

  **Sponsored by** *Catalyst*

  >This patch updates the information displayed in Koha for account lines. In accounts tables, the current 'Date' field is renamed 'Created', and a new column 'Updated' is added to display the last updated timestamp of the line.
  >
  >For new installations, accounts notices are also updated to include this information by default.
- [[23215]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23215) Remove PayPal logic from Koha

  >A while ago, a new payment plugin for PayPal was introduced, with more features like per-branch configurations. [1]
  >
  >This patch removes the PayPal payment feature from the codebase in favor of that plugin.
  >
  >[1] https://gitlab.com/thekesolutions/plugins/koha-plugin-pay-via-paypal
- [[24300]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24300) Add a 'payout amount' option to accounts

  >This enhancement adds a 'Payout amount' button to the borrowers account details page when there is outstanding credit.  This allows a library to payout multiple outstanding credits in one action.
- [[26272]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26272) Allow cashup summaries to be displayed from the library summary page

  >This enhancement utilises the recently introduced API routes for cashup summaries to allow the display of the cashup summary for the most recent cashup performed on each cash register visible on the cash management library summary page.
- [[26273]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26273) Expose cashup summary history for a cash register

  >This enhancement adds a cashup history table at the bottom of the register details page. You can then use this table to display the full summary for any cashup that has taken place at this cash register.
- [[27967]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27967) Modals on the borrower account page don't validate minimum values
- [[27971]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27971) The VOID method should be updated to respect double-entry accounting

  >Prior to this patch, the VOID action would reverse payments and set the original credit to '0'.
  >
  >With this patch, we bring the void action in line with other actions that can take place on the accounts system. The original credit amount is kept for audit purposes, we add a VOID line to the accountlines and offset it against the original credit (so that the amount outstanding is zero) and we reverse all the original offsets the credit may have been made against and record these reversals.
  >
  >This all helps in future audits and gives additional detail for Koha's other internal processes (Like automated refunds having to discount void payments - See bug 28421)
- [[28127]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28127) POS register details tables should have a transaction date

  >This patch adds the accountline timestamp to transactions on the register detail page.

### Hold requests

- [[24359]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24359) Remove items from Holds Queue when checked in

  >This development makes Koha trigger an update on the holds queue when items are checked in. This way, the holds queue will be updated faster than the default 1 hour frequency (cronjob).
  >
  >Note: this doesn't trigger the more expensive task of recalculating the whole queue, which remains a cronjob-based task.
- [[26498]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26498) Add option to set a default expire date for holds at reservation time

  **Sponsored by** *Koha-Suomi Oy*

  >This enhancement adds the option to set a default elapsed expiry date for holds at placement and when reservedate is updated.
- [[27016]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27016) Make the pickup locations dropdowns use Select2

  >This enhancement improves the display of the pickup library dropdown list in the holds section for a record, particularly for long lists. Enhancements include being able to start typing the name of the library and search for the library.
- [[27790]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27790) Possibility to filter Holds to pull list using pickup place

  >Add option to filter by pickup location in Holds to pull report.
- [[27864]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27864) Visual feedback on overridden pickup locations when placing biblio-level hold

  >This patch changes the pickup location dropdown, when placing biblio-level holds, so it renders a sign, alerting that circulation rules would be overridden if the pickup location is chosen.
  >
  >It relies on new API routes.
- [[27894]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27894) Add visual feedback on overridden pickup locations
- [[28092]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28092) Holds to pull needs to include reserve notes

  >Adds reserve notes column to Holds to pull report.

### Installation and upgrade (command-line installer)

- [[25674]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25674) Add RabbitMQ options to koha-create

### Label/patron card printing

- [[15563]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15563) Add option to regularly delete patroncard and label batches to cleanup_database.pl cronjob

  >This enhancement adds new options to the cleanup_database cronjob to delete label and card creator batches that haven't been updated for a given number of days. Previously, all batches were kept indefinitely.
- [[26875]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26875) Allow printing of just one barcode

  >This patch allows one to use the barcode range feature in the label creator tool to print a single barcode at a time.
- [[26962]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26962) Koha notice/slips/receipts should print in true black (#000000)

  >Almost black color in CSS rules (like #000066) are now replaced by true black color #000000
- [[28041]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28041) Improve breadcrumbs and headings on label creator pages
- [[28119]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28119) Use full description in layout type selection

  >This enhancement changes the display of the drop down list when adding and editing label layouts (Tools > Label creator > Layouts) so that a full description of label types is shown instead of brief names. For example: "Only the barcode is printed" instead of "BAR".

### MARC Bibliographic data support

- [[12966]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12966) Edition statement missing from card view in Z39.50 result list (acq+cataloguing)

  >This adds the edition statement (MARC21 250) to the card/ISBD views in the Z39.50 search results in the acquisition and cataloging modules.
- [[27022]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27022) Add publisher number (MARC21 028) to OPAC and staff detail pages
- [[27852]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27852) Link YES_NO authorized value category to 942$n in Default framework

  >This patch adds a Yes/No drop-down menu in the default bibliographic framework for field 942$n (MARC21). This field controls whether or not the record is hidden in the OPAC.

### MARC Bibliographic record staging/import

- [[26199]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26199) Record matching rule match check should include Leader/LDR

  >This patch extends the functionality of the existing record matching rules by allowing comparisons based on the fixed-length MARC leader. To reference the leader in a matching rule, enter "LDR" for the MARC tag in your matching rule setup. The offset and length values can be used to further refine your match.

### Notices

- [[11257]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11257) Document "items.content" for DUEDGST and PREDUEDGST and update sample notices
- [[14233]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14233) Add logging support to notices and slips management

  >This enhancement adds support for logging changes to notices and slips. Features include:
  >- a system preference (NoticesLog) which allows you to enable logging changes for notices and slips
  >- logging new notices, changes to notices, and deletion of notices
  >- filtering in the log viewer so you can show all changes for a specific notice
  >- a comparison feature, so you can see what changes were made to a notice.
- [[14723]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14723) Additional delivery notes to messages

  **Sponsored by** *Hypernova Oy* and *Koha-Suomi Oy*
- [[21886]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21886) Add option to send notices from owning library instead of issuing library

  **Sponsored by** *Gothenburg University Library*

  >Option added to advance_notice.pl and overdue_notice.pl for sending notices from owning or issuing library.
- [[26734]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26734) Convert accounts (monetary) notices to use GetPreparedLetter

  >This enhancement updates the existing slip printing code to utilise the internal GetPreparedLetter function as our other notices do.
  >
  >This leads to code clarity improvements and consistency and is part of the path to migrating all notices to use template toolkit consistently as well as exposing more variables to the template system for notices.
  >
  >*WARNING*: We replace any existing notices for the monetary slips with a modern equivalent using template toolkit. Any customised templates will be recorded in the action logs and should be used as inspiration for updating the new slips to include your libraries customizations. Letter codes: ACCOUNT_CREDIT, ACCOUNT_DEBIT

### OPAC

- [[12260]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12260) Printing a page from bootstrap shows unnecessary links
- [[18989]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18989) Allow displaying biblios with all items hidden by OpacHiddenItems

  >Currently the bibliographic record will be hidden in the OPAC, if all linked items are hidden by criteria defined in OpacHiddenItems. This patch adds a new system preference OpacHiddenItemsHidesRecord that allows to control this behavior making it possible to show the record, even if all items are hidden.
- [[20410]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20410) Remove OpacGroupResults system preference and feature

  >Remove the OpacGroupResults system preference and PazPar2 that have been deprecated in the previous major version.
- [[22752]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22752) Show item-level hold details for patrons when logged into their account

  >This enhancement to the OPAC shows a logged in patron what item a hold was placed on, for item-level holds ("Item on hold: <barcode>" is added after the title).
- [[25775]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25775) Add DataTables controls to user's checkouts table in OPAC

  >This patch adds some tools to the display of checkouts, overdues, holds, etc. in the logged-in user's view of their account in the OPAC. Users logged in using a JavaScript-capable browser will now see a filter form for instantly searching the contents of these tables. Controls will be shown to copy the data in the table, export the contents as a CSV file, or print a print-friendly version of the data in the table.
- [[26123]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26123) Show info about existing OPAC note/Patron message on patron's dashboard

  >Shows the number of messages and OPAC note from a patron record on the dashboard on the OPAC start page.
- [[26847]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26847) Make borrower category code accessible in all pages of the OPAC
- [[27005]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27005) Adding a filter in the datatable of opac-readingrecord page

  >This patch adds a search field and export options to the OPAC for a patron's checkout history table.
- [[27029]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27029) Detail page missing Javascript accessible biblionumber value
- [[27098]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27098) Rename 'Relatives fines' to 'Relatives charges' in OPAC
- [[27440]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27440) Improve structure and style of result toolbars in the OPAC
- [[27493]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27493) Improve structure and style of checkbox columns in tables
- [[27610]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27610) Accessibility: OPAC - h1 on each page is Logo but should be page description/title

  **Sponsored by** *Catalyst*
- [[27618]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27618) Don't show dropdown if PatronSelfRegistrationLibraryList only has one library

  >This patch modifies the patron self-registration screen to improve usability when there is only one library defined in the PatronSelfRegistrationLibraryList system preference. In this situation the library will now display as text instead of a dropdown with only one option.
- [[27681]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27681) Style OPAC self-registration CAPTCHA as uppercase

  >This changes the CAPTCHA field in the OPAC self-registration form to automatically change any character entered to be upper case.
- [[27728]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27728) Add a search box on OPAC search history

  >This new enhancement adds a search box to the OPAC search history. It also adds options to copy, export as CSV, and print search history data.
- [[27740]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27740) Accessibility: OPAC - Headings should have correct tags and hierarchy

  **Sponsored by** *Catalyst*
- [[27742]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27742) Accessibility: OPAC - Page titles should have unique information first
- [[27814]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27814) Improve responsive behavior of the user page in the OPAC
- [[27876]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27876) Accessibility: OPAC - Reduce heading redundancy

  **Sponsored by** *Catalyst*
- [[27991]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27991) Message field for checkout notes should have a maxlength set
- [[28018]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28018) Replace obsolete title-string sorting: OPAC templates

### Patrons

- [[8326]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8326) Allow patron attributes to be made repeatable after initial creation

  >This enhancement lets you modify the attributes "repeatable" and "unique identifier" for patron attribute types. Before this change it was not possible to modify these after they were initially set.
  >
  >Now you can modify patron attribute types, depending on the existing values recorded:
  >- repeatable: can make repeatable if it wasn't before; can make not repeatable once any repeatable values are removed
  >- unique identifier: if unique is set you can't add the same value to other patrons; you can't make an existing attribute unique until you edit all the existing values recorded for patrons and make them unique
- [[21549]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21549) Lock expired patron accounts after x days

  >This report adds pref LockExpiredDelay. When you enter a value there, the cleanup_database.pl cron job will lock the accounts of patrons that expired at least the specified number of days.
  >This follows the same pattern as existing code that already allows you to anonymize or delete locked patrons.
- [[22150]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22150) Make it easier to unselect one member permission after selecting all
- [[27607]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27607) Add the ability to compare patron records during merge process

  >When merging two patron records, the user now has the option to compare the two records to see the differences between them.
- [[27990]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27990) Replace obsolete title-string sorting: Patrons

### Plugin architecture

- [[25245]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25245) Add a plugin hook to allow running code on a nightly basis

  >This patchset adds a new cronjob script to Koha, plugins_nightly.pl
  >
  >This script will check for plugins that have registered a cronjob_nightly method and execute that method.
  >
  >This enhancement allows users to install and setup plugins that require cronjobs without backend system changes and prevents the addition of new cronjob files for each plugin.

### REST API

- [[23666]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23666) Add routes for extended patron attributes

  >This development adds routes for managing a patron's extended attributes.
  >
  >The following routes are added:
  >GET    /patrons/:patron_id/extended_attributes
  >POST   /patrons/:patron_id/extended_attributes
  >PUT    /patrons/:patron_id/extended_attributes
  >DELETE /patrons/:patron_id/extended_attributes/:extended_attribute_id
  >PATCH  /patrons/:patron_id/extended_attributes/:extended_attribute_id
- [[26274]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26274) Expose cash register cashup summaries via an API route.

  >This enhancement adds the `/cash_registers/{cash_register_id}/cashups` and `/cashups/{cashup_id}` API endpoints. This opens up the possibility to display the cashup summaries more easily on a wider range of Koha pages.
- [[26636]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26636) Add objects.find Mojolicious helper

  **Sponsored by** *Virginia Polytechnic Institute and State University*
- [[27015]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27015) Add filtering options to the pickup_locations routes
- [[27352]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27352) Add GET /biblios/:biblio_id/items
- [[27353]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27353) Return the number of total records
- [[27366]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27366) Add GET /patrons/:patron_id/holds

  >This enhancements adds the `GET /patrons/{patron_id}/holds` endpoint to the REST API.
- [[27544]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27544) Simplify /checkouts implementation
- [[27587]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27587) Use Basic auth on API tests
- [[27760]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27760) Add handling for x-koha-override

  >This patches add a new Mojolicious helper method that takes care of reading 'x-koha-override' headers that contain comma-separated overrides (e.g. 'pickup_location,too_many_holds') and stashes them for later use in controller methods.
- [[27797]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27797) Make POST /holds use the stashed koha.overrides
- [[27854]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27854) Clean GET /patrons controller
- [[27855]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27855) Allow embedding extended_attributes on /patrons routes

  >This enhancement allows patron extended attributes to be embedded into the patron object responses on the restful api.
- [[27898]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27898) Make PUT /holds/:hold_id handle x-koha-override for pickup locations
- [[27932]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27932) Add GET /biblios/:biblio_id/pickup_locations

  >See the related wiki page https://wiki.koha-community.org/wiki/Biblios_pickup_locations_endpoint_RFC
- [[28002]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28002) Add optional extended_attributes param to POST /patrons

  >This development adds an optional parameter to the POST /patrons route, so extended attributes can be passed for patron creation.
  >It relies on the underlying code to handle extended attributes constraints/requirements (repeatable, mandatory, unique, etc).
  >
  >The added attribute (to be passed in the body of the POST request) is 'extended_attributes' and consists of an array of extended attribute objects (properly described on the spec).
- [[28157]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28157) Add the ability to set a library from which an API request pretends to come from
- [[28189]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28189) Move the base swagger file to YAML
- [[28463]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28463) Change spec for better looking in the docs

### Reports

- [[22152]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22152) Hide printing the tools navigation when printing reports
- [[24695]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24695) Improve SQL report validation
- [[26708]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26708) Add option to preview SQL from list of saved reports

  >This patch adds the option to preview a saved report's SQL directly from the list of saved reports. From this preview the user can edit the report, duplicate it, schedule it, run it, or delete it.
- [[26713]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26713) Add pagination to bottom of saved SQL reports table

  >This enhancement adds a second pagination menu to the bottom of saved SQL reports tables.
- [[27380]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27380) Add option for taking a list parameter in reports

  >This enhancement adds a new option for taking input in reports.
  >
  >You can now specify the input as a 'list' which will allow inputting a newline separated list of values
  >
  >When requesting in put in the report you can use 'list' after the pipe symbol, similar to the way you can specify a 'date' input
  >
  >"Data to enter|list"
- [[27643]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27643) Add CodeMirror custom syntax highlighting for SQL runtime parameters

  >This patch modifies the configuration of the reports module's SQL editor so that runtime parameters have their own syntax highlighting, setting them apart by color from other parts of the SQL code.
- [[27644]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27644) Add button to SQL report editor for inserting runtime parameters

  >This patch adds a button menu to the SQL report CodeMirror editor for inserting runtime parameters. Each menu item triggers a modal dialog where the user can specify a parameter label and any other relevant option.
- [[27994]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27994) Replace obsolete title-string sorting: Reports templates

### SIP2

- [[14300]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14300) siplogs do not record process IDs

  >This addition to the default configuration for the SIP section of the Log4Perl configuration will add the process ID to the log lines for SIP logs.  This allows for tracing a transaction from start to finish when using forked SIP services.
- [[26591]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26591) Add a choice to prevent the checkout or warn the user if CheckPrevCheckout is used via SIP2

  >Some libraries would like patrons to be able to check out items with prior checkouts via SIP even if the CheckPrevIssue preference is enabled.
  >
  >This feature is enabled by adding the flag prevcheckout_block_checkout to an account in the SIP configuration file, and setting the value of it to "0".

### Searching

- [[21249]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21249) Syspref to choose whether to search homebranch, holding branch or both for library groups in advanced search

  **Sponsored by** *Catalyst*

  >This patch adds a system preference, SearchLimitLibrary, to be used in the advanced search on the staff client and OPAC, and the OPAC masthead search. When limiting search results with a library or library group, the SearchLimitLibrary system preference can be set to limit using the item's holding branch, home branch, or both.
- [[23763]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23763) Move pagination calculations to a subroutine

  >This enhancement moves duplicated code for the pagination of search results in the OPAC and staff interface into its own routine.

### Searching - Elasticsearch

- [[24863]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24863) QueryFuzzy syspref says it requires Zebra but Elasticsearch has some support
- [[25054]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25054) Display search field aliases in search engine configuration

  >This adds a new column aliases to the search fields tabs of the search engine configuration table. The aliases table shows the abbreviated and alternative index names available for each defined index.
- [[26991]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26991) Add action logs to search engine administration

  >This enhancement adds logging of changes made to Elasticsearch. These can be viewed in the log viewer tool, where you can view all search engine changes, or limit to edit mapping and reset mapping actions.
- [[27682]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27682) Add a floating table header for Search engine configuration

  >This enhancement adds a search filter and a floating table header (that "sticks" to the top of the browser window as you scroll down) to the search engine configuration pages (Administration > Catalog > Search engine configuration (Elasticsearch)). 
  >
  >The "Search fields" table is sortable, but the "Bibliographic records" and "Authorities" tables are not as they have drag-and-drop row reordering.

### Serials

- [[23243]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23243) Allow filtering out of historic subscription expirations in the check expiration of serials page

  **Sponsored by** *Centre collégial des services regroupés*

  >Bug 15171 reversed the behaviour of the serials page to always display expired serial subscriptions.
  >
  >This bug makes that filtering optional using a new checkbox.
- [[27998]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27998) Replace obsolete title-string sorting: Serials templates
- [[28036]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28036) Improve breadcrumbs of serial claims page

### Staff Client

- [[14004]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14004) Add ability to temporarily disable added CSS and Javascript in OPAC and interface

  >This allows to temporarily disable any of OPACUserCSS, OPACUserJS, OpacAdditionalStylesheet, opaclayoutstylesheet, IntranetUserCSS, IntranetUserJS, intranetcolorstylesheet, and intranetstylesheet system preference via an URL parameter.
  >
  >Alter the URL in OPAC or staff interface by adding an additional parameter DISABLE_SYSPREF_<system preference name>=1. 
  >
  >Example:
  >/cgi-bin/koha/mainpage.pl?DISABLE_SYSPREF_IntranetUserCSS=1
- [[25462]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25462) Shelving location should be on a new line in holdings table

  >In the holdings table, the shelving location is now displayed on a new line after the 'Home library'.
- [[26703]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26703) Modify the "title" elements to contain unique information first

  **Sponsored by** *Catalyst*

  >Title elements should contain unique information first. This aids accessibility for all as browser titles become much more relevant and useful for navigation.
- [[26707]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26707) Split cart and lists button on bibliographic detail pages

  >This patch modifies the toolbar on bibliographic detail pages so that the "Add to cart" and "Add to lists" buttons are separate. The "Add to cart" now shows whether the title is in the cart. The "Add to lists" button is now a menu of list choices like it is on the search results page.
- [[27404]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27404) Update intranet-tmpl/prog/en/modules/labels/label-edit-range.tt for ACC2
- [[27405]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27405) Update intranet-tmpl/prog/en/modules/pos/register.tt for ACC2

  >This patch updates occurrences of input type="number" in  intranet-tmpl/prog/en/modules/pos/register.tt to use 'input type="text" inputmode="numeric" pattern="^\d+(\.\d{2})?$"' as per the accessibility coding guideline ACC2.
- [[27406]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27406) Update admin/searchengine/elasticsearch/mappings.tt to adhere to ACC2
- [[27407]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27407) Update intranet-tmpl/prog/en/modules/reserve/request.tt for ACC2
- [[27409]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27409) Update members/boraccount.tt for ACC2
- [[27411]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27411) Update tools/automatic_item_modification_by_age.tt to reflect ACC2
- [[27412]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27412) Update intranet-tmpl/prog/en/modules/tools/overduerules.tt to adhere to ACC2
- [[27582]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27582) Breadcrumb incorrect for POS: Library details page
- [[27846]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27846) Accessibility: Staff Client - Breadcrumbs should be more accessible

  **Sponsored by** *Catalyst*
- [[27982]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27982) Replace obsolete title-string sorting: Acquisitions templates part 1
- [[27983]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27983) Replace obsolete title-string sorting: Acquisitions templates part 2
- [[28091]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28091) Add meta tag with Koha version number to staff interface pages

### System Administration

- [[27251]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27251) Rewrite the QOTD editor using the Koha REST API

  >This patch replaces the QOTD editor with the standard way used for creating, editing, and deleting QOTD entries (now uses edit and delete buttons, and a standard form to add and edit entries).
- [[27263]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27263) Link to preferences mentioned in system preference descriptions

  >Wherever a system preference description mentions another system preference the name of that preference will now be a link that searches for the system preference saving steps and making it easier to review related preferences.
- [[27395]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27395) Add warning to PatronSelfRegistrationDefaultCategory to avoid accidental patron deletion

  >This patch adds a warning to the PatronSelfRegistrationDefaultCategory system
  >preference to not use a regular patron category for self registration.
  >
  >If a regular patron category code is used and the cleanup_database cronjob is setup
  >to delete unverified and unfinished OPAC self registrations, it permanently and
  >and unrecoverably deletes all patrons that have registered more than
  >PatronSelfRegistrationExpireTemporaryAccountsDelay days ago.
  >
  >It also removes unnecessary apostrophes at the end of two self registration
  >and modification system preference descriptions.
- [[27415]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27415) Add note to ILLHiddenRequestStatuses preference to the ILLSTATUS authorized value category
- [[27598]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27598) Add UPLOAD as a built-in system authorized value category

  >The file upload feature requires that users create an UPLOAD category for authorized values before adding values to that category. This patch adds the UPLOAD category by default so that users don't have to create it.
- [[27652]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27652) Offer selections for preferences which ask for patron categories

  >This enhancement to system preferences lets you select patron categories from a dropdown list, instead of manually entering patron category codes. This prevents possible errors from manually entering incorrect codes.
  >
  >This is enabled for these system preferences:
  >- PatronSelfRegistrationDefaultCategory (single option)
  >- GoogleOpenIDConnectDefaultCategory (single option)
  >- OPACHoldsIfAvailableAtPickup (multiple options)
  >- BatchCheckouts (multiple options)
- [[27805]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27805) Use input type "email" for email preferences

  >This patch modifies the global system preferences interface so that fields which ask for an email address have the correct HTML attribute type: email. This allows some basic email address validation by the browser and can enable different keyboard options on devices with onscreen keyboards.
- [[27975]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27975) Replace obsolete title-string sorting: Administration templates

### Templates

- [[21851]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21851) Improve style of sidebar forms

  >This patch makes minor changes to staff interface CSS to improve the style of forms in sidebars. It adjusts the style of nested field sets and gives more room to list items (and the form fields they contain).
- [[24623]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24623) Phase out jquery.cookie.js: Advanced MARC editor
- [[24624]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24624) Phase out jquery.cookie.js: Receipt summary

  >This patch removes the jquery.cookie.js plugin from the "Receive orders" page in acquisitions as it is no longer used.
- [[25846]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25846) Improve handling of multiple covers on catalog search results in the staff client

  >This enhancement updates the staff interface catalog search results to improve the display of multiple covers associated with each search result:
  >- Adlibris
  >- Amazon
  >- Google
  >- OpenLibrary
  >- Local cover images (including multiple local cover images)
  >- Coce (serving up Amazon, Google, and OpenLibrary images)
  >- Images from the CustomCoverImages preference
  >A single cover is now displayed for each result, with controls for scrolling through any other available cover.
- [[26755]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26755) Make the guarantor search popup taller
- [[26958]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26958) Move Elasticsearch mapping template JS to the footer
- [[26959]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26959) Reindent batch item modification template
- [[26960]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26960) Move batch item modification template JavaScript to the footer
- [[26970]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26970) Add row highlight on drag in Elasticsearch mapping template
- [[26982]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26982) Typo in system preference UsageStats: statisics
- [[26985]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26985) Remove code for "Upcoming events" from codebase as not implemented
- [[27192]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27192) Set focus for cursor to item type input box when creating new item types
- [[27210]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27210) Typo in patron-attr-types.tt
- [[27289]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27289) Template tweaks for point of sale page
- [[27402]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27402) Add column filtering to the Datatables REST API wrapper

  >This development adds native DataTables column filtering to the REST API wrapper. This allows easily adding column filters to DataTables using the REST API.
  >A sample implementation is added to the cities admin page, for reference.
- [[27403]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27403) Enable fixedHeader for Datatables
- [[27437]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27437) Improve hint labels on library creation form
- [[27439]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27439) Improve hint labels on patron attribute type entry form
- [[27455]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27455) Add focus to branch code when a new library is added
- [[27465]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27465) Add column visibility to the admin/cities.pl
- [[27469]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27469) Improve link text when returning to vendor page
- [[27471]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27471) Improve link text when successfully merging authorities and remove JS redirect
- [[27472]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27472) Improve link text when successfully merging bibliographic records
- [[27473]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27473) Improve link text in the installer
- [[27474]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27474) Improve link text to define a label printer profile if none defined and fix conditional
- [[27475]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27475) Improve link text to define a patron card printer profile if none are defined
- [[27476]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27476) Improve link text for logging in on OPAC

  **Sponsored by** *Catalyst*
- [[27477]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27477) Improve link text when a record has too many items on the OPAC
- [[27478]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27478) Improve link text when viewing an ILL requested item
- [[27479]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27479) Improve link text after successfully resetting password in OPAC
- [[27592]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27592) Link audio alerts to corresponding preference and back

  >This patch adds a link to the Audio Alerts page so that if audio alerts are disabled the user can follow a link directly to the corresponding system preference.
- [[27605]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27605) Add floating toolbar to patron search page

  >This patch modifies the patron module's search interface so that the toolbar of results-related controls sticks to the top of the screen as the user scrolls down. This
  >gives access to the controls for adding patrons to a list and for merging patrons.
- [[27699]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27699) Add cash register information to responsive staff interface header menu

  >This enhancement adds the currently selected cash register (if it is enabled and set) to the logged-in user's header menu on the top righthand side of the staff interface when using smaller browser screen sizes.
- [[27749]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27749) Phase out jquery.cookie.js: Search to hold

  >This patch modifies the "search to hold" process for patrons and clubs so that the newer jquery-cookie plugin is used instead of jquery.cookie.
- [[27751]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27751) Phase out jquery.cookie.js: Batch item modifications
- [[27792]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27792) Improve jEditable configuration for point of sale fields

  >This patch improves interactions with inline-editable fields in the Point of Sale interface to prevent jumpy table re-draws and to enforce the required currenty/number input types.
- [[27974]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27974) Replace obsolete title-string sorting: Circulation templates
- [[28006]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28006) Restore "Additional fields" link on serials navigation menu
- [[28016]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28016) Replace obsolete title-string sorting: Assorted templates
- [[28046]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28046) Add "Additional fields" link on acquisition navigation menu
- [[28047]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28047) Standardize: Call number, callnumber, Call no. etc.

  >This patch modifies instances in the templates where variations of "Call number" are used. "Call number" is now used instead of "Call no.", "Call no", or "callnumber".
- [[28055]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28055) Convert DataTables option names to current version
- [[28066]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28066) Remove select tag's size attribute where it is 1
- [[28081]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28081) Make card number a label in patron search results

  >In the Patrons module, in patron search results, the user can now click the patron card number to select the checkbox for that row.
- [[28132]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28132) Remove "this" from button descriptions on basket and basket group pages
- [[28134]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28134) Replace use of input type number in onboarding templates

### Test Suite

- [[18146]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18146) C4::Circulation CanBookBeRenewed  lacks full test coverage

  >This enhancement improves the test coverage for OverduesBlockRenewing and removes some of the warning messages.

### Tools

- [[4037]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=4037) Inventory tool missing item type filter

  **Sponsored by** *Bibliotheksservice-Zentrum Baden-Württemberg (BSZ)*

  >This patch adds the ability to filter inventory by item type. Multiple item types can be selected at once.
- [[24446]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24446) Stockrotation: Update to use daterequested in branchtransfers

  >This patchset updates the Stock Rotation system to use the recently introduced Koha::Item[::Transfer] methods.
  >
  >It fixes a bug whereby such transfers could be accidentally cancelled by other processes and sets these transfer to be the lowest priority.
  >
  >We also introduce handling for the new 'requested' transfer state into the circulation system.
- [[25476]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25476) Uploaded files can't be easily browsed via upload.pl
- [[27594]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27594) Add access to public download link for publicly-accessible uploads

  >This patch adds a link to the display of publicly-accessible downloads so that the public link can be copied.
- [[27766]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27766) Hide expired news items by default

  >This patch modifies the news page in the staff interface so that expired news items are hidden by default. A checkbox in the sidebar can be checked to show the hidden rows.
- [[27773]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27773) Hide unique holidays and exceptions which have passed
- [[28007]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28007) Replace obsolete title-string sorting: Tools templates
- [[28014]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28014) Add table settings to batch patron modification

  >This patch adds DataTable table configuration and export options to the table of patrons submitted for batch modification, both before and after modifications are made. The table will now be configurable via Table Settings in Administration.
- [[28037]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28037) Improve breadcrumbs of CSV profiles page

  >This patch expands the logic around the page title and breadcrumbs of the CSV profiles page. The name of the page has also been changed from "CSV export profiles" to "CSV profiles" to match links elsewhere in Koha.
  >
  >Breadcrumbs now display as:
  >- Initial window: Tools > CSV profiles
  >- New CSV profile: Tools > CSV profiles > New CSV profile
  >- Edit an existing CSV profile: Tools > CSV profiles > Modify a CSV profile
- [[28108]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28108) Move action logs 'SERIAL CLAIM' and 'ACQUISITION CLAIM' to a new 'CLAIMS' module

  >This enhancement changes the logging system preferences and the log viewer tool so that:
  >
  >- ClaimsLog: logs when an acquisitions claim or a serials claim notice is sent (Claims module in the log viewer)
  >- AcquisitionLog: logs all other changes for acquisition actions (Acquisitions module in the log viewer).
  >
  >Previously ClaimsLog was called LettersLog, but the name was considered confusing after support for logging changes to notices and slips was added in Koha 21.05 (bug 14233).

### Web services

- [[27584]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27584) Improve OAI-PMH provider performance


## Critical bugs fixed

(This list includes all bugfixes since the previous major version. Most of them
have already been fixed in maintainance releases)

### Acquisitions

- [[26997]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26997) Database Mysql Version 8.0.22 failed to Update During Upgrade
- [[27203]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27203) Order unitprice is not set anymore and  totals are 0
- [[27671]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27671) Missing include in orderreceive.tt
- [[27719]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27719) Receiving orders hangs on processing when missing a replacement price

  **Sponsored by** *Virginia Polytechnic Institute and State University*
- [[27828]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27828) New order from staged file is broken

### Architecture, internals, and plumbing

- [[20982]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20982) opac-shelves.pl vulnerable to Cross-site scripting attacks
- [[26363]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26363) Provide a systemd unit file for background_jobs_worker
- [[26705]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26705) System preference NoticeBcc not working

  >The Email::Stuffer library we use, doesn't handle Bcc as Mail::Sendmail does. So Bcc handling wasn't working as expected. This patchset adds support for explicitly handling Bcc (including the NoticeBcc feature) to our Koha::Email library.
- [[27252]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27252) ES5 no longer supported (since 20.11.00)

  >This prepares Koha to officially no longer support Elasticsearch 5.X.
  >
  >It adds a new system preference 'ElasticsearchCrossFields' to allow users to choose whether or not to enable this feature.
- [[27534]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27534) koha upgrade throws SQL error while applying Bug 25333 - Change message transport type for Talking Tech from "phone" to "itiva"
- [[27580]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27580) NULL values not correctly handled in Koha::Items->filter_by_visible_in_opac
- [[27586]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27586) Import patrons script has a confirm switch that doesn't do anything

  >This fixes the misc/import_patrons.pl script so that patrons are not imported unless the --confirm option is used. Currently, if the script is run without "--confirm" option it reports that it is "Running in dry-run mode, provide --confirm to apply the changes", however it imports the patrons anyway.
- [[27676]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27676) finesMode=off not correctly handled
- [[27821]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27821) sanitize_zero_date does not handle datetime
- [[28031]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28031) Koha::Patron::Attribute->_check_repeatable doesn't exclude the object's ID
- [[28200]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28200) Net::Netmask 1.9104-2 requires constructor change for backwards compatibility

  >The code library Koha uses for working with IP addresses has dropped support for abbreviated values in recent releases.  This is to tighten up the default security of input value's and we have opted in Koha to follow this change through into our system preferences for the same reason.
  >
  >WARNING: `koha_trusted_proxies` and `ILS-DI:AuthorizedIPs` are both affected. Please check that you are not using abbreviated IP forms for either of these cases. Example: "10.10" is much less explicit than "10.10.0.0/16" and should be avoided.
- [[28302]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28302) Koha does not work with CGI::Compile 0.24
- [[28317]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28317) Remove CGI::Session::Serialize::yaml dependency by using the default serializer

### Authentication

- [[28385]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28385) LDAP server configuration broken since migration from XML::Simple

### Cataloging

- [[18017]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18017) Use index_heading and index_match_heading in UNIMARC authorities zebra configuration
- [[24564]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24564) The adding of new subfields according to IFLA updates doesn't respect existing tab
- [[27509]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27509) cn_sort value is lost when editing an item without changing cn_source or itemcallnumber
- [[27886]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27886) Authority linking broken in advanced editor

### Circulation

- [[24154]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24154) No indication that Default checkout, hold and return policy are set if values are blank
- [[26208]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26208) Overdues restrictions not consistently removed when renewing multiple items at once
- [[26457]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26457) DB DeadLock when renewing checkout items
- [[27707]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27707) Renewing doesn't work when renewal notices are enabled
- [[27808]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27808) Item's onloan column remains unset if a checked out item is issued to another patron without being returned first
- [[28064]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28064) Transits are not created at check in despite user responding 'Yes, print slip' to the prompt
- [[28136]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28136) Transferred holds are not triggering
- [[28230]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28230) Renewing/Checking out record with AE or OE letter in title can make Koha totally unfunctional

### Command-line Utilities

- [[27245]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27245) bulkmarcimport.pl error 'Already in a transaction'
- [[27276]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27276) borrowers-force-messaging-defaults throws Incorrect DATE value: '0000-00-00' even though sql strict mode is dissabled
- [[28001]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28001) Fix delete_patrons.pl if no category is passed
- [[28291]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28291) koha-translate install script producing incorrectly encoded YAML translation files

### Database

- [[24658]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24658) Deleting items with fines does not update itemnumber in accountlines to NULL causing ISE
- [[27003]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27003) action_logs table error when adding an item
- [[28298]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28298) DBRev 19.12.00.076 broken

### Fines and fees

- [[25508]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25508) Confusing renewal message when paying accruing fine with RenewAccruingItemWhenPaid turned off
- [[27796]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27796) SIP payment types should not be available as refund types
- [[27927]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27927) longoverdue cronjob renews items before marking lost when both RenewAccruingItemWhenPaid and  WhenLostForgiveFine  are enabled

### Hold requests

- [[26634]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26634) Hold rules applied incorrectly when All Libraries rules are more specific than branch rules
- [[27068]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27068) HoldsQueue doesn't know how to use holds groups

  >Koha 20.05 introduced local hold groups, but neglected to add support of them in the holds queue. Because of this, the holds queue will not show items the could have filled holds from other libraries in a hold group. This patch set adds support for hold groups to the holds queue builder thus improving Koha's ability to find items to fill hold requests.
- [[27071]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27071) Hold pickup library match not enforced correctly on intranet when using hold groups

  >When using library groups, the rules for placing holds did not always work as expected. This fixes these rules so that when patrons are part of a library in a group, they can only place a hold for items held in that library group. It also improves the error messages.
  >
  >Example:
  >- There are two library groups with distinct libraries in each (Group A and B).
  >- Default rules for all libraries are: Hold Policy = "From local hold group" and Hold pickup library match to "Patron's hold group", AllowHoldPolicyOverride is Don't allow.
  >- You can place a hold for a patron that belongs to one of the Group A libraries, for an item only held in a Group A library.
  >- You can't place a hold for that item for a patron from a Group B library.
- [[27205]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27205) Hold routes are not dealing with invalid pickup locations
- [[27529]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27529) Cannot place hold on OPAC if hold_fullfillment_policy is set to group and  OPACAllowUserToChooseBranch  not allowed
- [[27865]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27865) Hold pickup location dropdown on patron pages should respect hold fulfillment policies
- [[28273]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28273) Multi-holds allow invalid pickup locations

### Holidays

- [[27835]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27835) Closed days offsets with one day

### I18N/L10N

- [[28154]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28154) Translate script faces encoding issues
- [[28419]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28419) Page addorderiso2709.pl is untranslatable

### Installation and upgrade (command-line installer)

- [[27466]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27466) Update process failing for 20.06.00.023

  >The update 20.06.00.023 for adding options and reconfiguring the QuoteOfTheDay feature would fail. This patch makes sure that the update can be processed correctly.

### Installation and upgrade (web-based installer)

- [[28281]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28281) Installer doesn't work on some languages (pl-PL) because it double decodes installer data

### Lists

- [[27715]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27715) Possibly SQL injection in virtualshelves

### MARC Authority data support

- [[27737]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27737) Tag editor for authority lookup broken in authority editor

  >This patch changes the markup structure for the authorities editor so that it better matches that of the basic bibliographic record editor. This allows the authority-linking JavaScript to correctly target fields on both pages.

### Notices

- [[28023]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28023) Typo in Reply-To header

### OPAC

- [[15448]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15448) Placing hold on specific items doesn't enforce OpacHiddenItems
- [[24398]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24398) Error when viewing single news item and NewsAuthorDisplay pref set to OPAC
- [[27148]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27148) Internal Server Error during self registration 20.11

  >This fixes a bug when using self registration and there is no patron category available for selection in the registration form.
- [[27200]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27200) "Browse search" is broken
- [[27626]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27626) Patron self-registration breaks if categorycode and password are hidden
- [[27731]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27731) Place hold link for individual OPAC search result broken
- [[27860]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27860) Bad KohaAdminEmailAddress breaks patron self registration and password reset feature
- [[28193]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28193) OpacLoginInstructions news block broken by Bug 20168

### Packaging

- [[28364]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28364) koha-z3950-responder breaks because of log4perl.conf permissions

### Patrons

- [[25946]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25946) borrowerRelationship can no longer be empty
- [[26517]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26517) Avoid deleting patrons with permission
- [[27004]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27004) Deleting a staff account who have created claims returned causes problem in the return_claims table because of a NULL value in return_claims.created_by.
- [[27144]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27144) Cannot delete any patrons
- [[27420]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27420) A mistake in bug 5161 leads to some patron attributes appearing without a fieldset
- [[27933]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27933) Order patron search broken (dateofbirth, cardnumber, expirationdate)
- [[28217]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28217) Several non-repeatable attributes when merging patrons

### Plugin architecture

- [[27820]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27820) plugins_nightly.pl script missing use

### REST API

- [[28369]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28369) additionalProperties missing in holds routes
- [[28370]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28370) Routes still missing additionalProperties in spec

### Reports

- [[27142]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27142) Patron batch update from report module - no patrons loaded into view

  >This fixes an error when batch modifying patrons using the reports module. After running a report (such as SELECT * FROM borrowers LIMIT 50) and selecting batch modification an error was displayed: "Warning, the following cardnumbers were not found:", and you were not able to modify any patrons.

### SIP2

- [[27166]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27166) SIP2 Connection is killed when an item that was not issued is checked in and generates a transfer
- [[27196]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27196) Waiting title level hold checked in at wrong location via SIP leaves hold in a broken state and drops connection
- [[27589]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27589) Error when specifying CR field in SIP Config

### Searching

- [[28475]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28475) Searching all headings returns no results

  **Sponsored by** *Asociación Latinoamericana de Integración*

### Searching - Elasticsearch

- [[26312]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26312) Add some error handling during Elasticsearch indexing
- [[27597]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27597) Searching "kw:term" does not work with Elasticsearch
- [[27784]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27784) Unknown authority types break elasticsearch authorities indexing

  >This patch fixes Elasticsearch indexing failures caused by 'SUBDIV' type authority records in Koha. It skips the step of parsing the authorities into the linking form if the type contains '_SUBD'. 
  >
  >Notes: 
  >- Koha currently doesn't have support for 'SUBDIV' type authority records.
  >- They can be added to the authority types in the staff interface, however, values are hard coded in various modules and Koha has no concept of how to link a subfield heading to a record, as we only deal in whole fields.

### Searching - Zebra

- [[12430]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12430) Relevance ranking should also be used without QueryWeightFields system preference

### Serials

- [[27842]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27842) Incorrect biblionumber handling in serials subscriptions

### Staff Client

- [[27256]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27256) "Add" button on point of sale page fails on table paging
- [[28368]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28368) Error when printing receipt of point of sale

### System Administration

- [[27569]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27569) marc-framework import function doesn't accept LibreOffice csv/ods file formats

### Templates

- [[27124]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27124) JS error "select2Width is not defined"
- [[28351]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28351) Cannot set restrictions when 'dateformat' is other than 'us'

### Test Suite

- [[27055]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27055) Update Firefox version used in Selenium GUI tests

### Tools

- [[27669]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27669) reverting and importing status never set when importing/reverting a batch
- [[28015]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28015) Inventory tool fails when timeformat=12h
- [[28158]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28158) Lost items not charging when marked lost from batch item modification
- [[28220]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28220) Exception not caught when importing patrons

### Web services

- [[26665]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26665) OAI 'Set' and 'Metadata' dropdowns broken

  >With OAI-PMH enabled, if you clicked on Sets or Metadata in the search results no additional information was displayed (example query: <OPACBaseURL>/cgi-bin/koha/oai.pl?verb=ListRecords&metadataPrefix=marc21). This patch fixes this so that the additional information for Sets and Metadata is now correctly displayed.


## Other bugs fixed

(This list includes all bugfixes since the previous major version. Most of them
have already been fixed in maintainance releases)

### About

- [[7143]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7143) Bug for tracking changes to the about page
- [[27495]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27495) The "Accessibility advocate" role is not yet listed in the about page.
- [[27661]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27661) Clarify error for message broker
- [[28442]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28442) Release team 21.11

### Acquisitions

- [[23195]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23195) Shipping costs are inconsistent in where displayed

  >With this patch the shipping costs added to an invoice are always counted as "spent". With this change the totals on the start page of the acquisition module will match the totals on the ordered and spent pages for a fund.
- [[23675]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23675) UseACQFrameworkForBiblioRecords default framework is missing LDR breaking encoding
- [[23767]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23767) Spent and Ordered total values don't include child funds on acqui-home
- [[23929]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23929) Invoice adjustments should filter inactive funds
- [[24469]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24469) Record biblionumber in import_biblio when adding to basket via file
- [[24470]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24470) Set import_status when file used to populate basket in acquisitions
- [[26905]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26905) Purchase suggestion button hidden for users with suggestion permission but not acq permission
- [[26989]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26989) Ensure no CR occurs in an EDIFACT order message
- [[27446]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27446) Markup errors in suggestion/suggestion.tt

  >This patch fixes several markup errors in the suggestions template in the staff interface, including:
  >- Indentation
  >- Unclosed tags
  >- Non-unique IDs
  >- Adding comments to highlight markup structure
- [[27547]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27547) Typo in parcel.tt
- [[27608]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27608) Correct 'accepted by' inconsistency in suggestion.tt

  **Sponsored by** *Collecto*
- [[27813]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27813) Purchase suggestions should sort by suggesteddate rather than title

  >This changes the list of purchase suggestions so that the oldest suggestions are shown first, rather than by title. (This was the behaviour before Koha 20.05).
- [[27900]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27900) regression: add from existing record with null results deadends
- [[28003]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28003) Invoice adjustments using inactive budgets do not indicate that status
- [[28077]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28077) Missing colon on suggestion modification page
- [[28103]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28103) Barcode fails when adding item during order receive
- [[28223]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28223) Total for budgets is incorrect when child funds have negative values
- [[28283]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28283) 'Quantity received' should have inputmode="numeric"

### Architecture, internals, and plumbing

- [[15720]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15720) OCLC Connexion daemon does not verify username or password
- [[16067]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16067) Koha::Cache, fastmmap caching system is broken
- [[24000]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24000) Some modules do not return 1
- [[25292]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25292) L1 cache too long in Z3950 server (z3950-responder)
- [[25306]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25306) Unnecessary update of framework in ModBiblioMarc
- [[25381]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25381) XSLTs should not define entities
- [[25552]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25552) Add missing Claims Returned option to MarkLostItemsAsReturned

  >Marking an item as a return claim checks the system preference MarkLostItemsAsReturned to see if the claim should be removed from the patron record. However, the option for "when marking an item as a return claim" was never added to the system preference, so there was no way to remove a checkout from the patron record when marking the checkout as a return claim. This patch set adds that missing option.
- [[26048]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26048) PSGI Koha does not use custom ErrorDocument pages

  >This change allows PSGI (Plack) Koha to use the custom ErrorDocument pages that CGI Koha already uses. Without this change, a 500 error will show a white page with only "Internal server error" and a 404 will show a white page with only "not found". This change aligns the error reporting for the two different Koha web modes.
- [[26742]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26742) Add configuration for message broker
- [[26848]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26848) Fix Readonly dependency in cpanfile
- [[26849]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26849) Fix Array::Utils dependency in cpanfile
- [[26947]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26947) kohastructure.sql should be updated for each release

  >The kohastructure file which contains the table create statements for Koha was originally a MySQL dump which has been managed by hand as developers added new tables, changed columns, etc.
  >
  >In order to standardize this table and allow easy comparison of an existing sites database to the correct Koha structure this file should be automatically generated as part of the release process
- [[27030]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27030) The new "Processing" hold status is missing in C4::Reserves module documentation
- [[27154]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27154) Koha/Util/SystemPreferences.pm must be removed
- [[27179]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27179) Misspelling of Method in REST API files

  >This fixes the misspelling of Method (Mehtod to Method) in REST API files.
- [[27209]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27209) Add Koha::Hold->set_pickup_location
- [[27327]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27327) Indirect object notation in Koha::Club::Hold
- [[27331]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27331) fr-FR/1-Obligatoire/authorised_values.sql is invalid
- [[27333]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27333) Wrong exception thrown in Koha::Club::Hold::add
- [[27345]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27345) C4::Auth::get_template_and_user is missing some permissions for superlibrarian
- [[27530]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27530) Sample patron data should be updated and/or use relative dates
- [[27562]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27562) itiva notices break if record title contains quotes
- [[27581]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27581) Rename UseICU system preference to UseICUStyleQuotes
- [[27680]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27680) API DataTables Wrapper fails for ordering on multi-data-field columns
- [[27714]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27714) Koha::NewsItem->author explodes if the author has been removed

  >This fixes the cause of errors occurring for the display of news items where the author of no longer exists in Koha.
- [[27807]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27807) API DataTables Wrapper fails for ordered on multiple columns
- [[27844]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27844) koha-worker systemd service should run as %i-koha in package install
- [[27857]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27857) Koha::Patron->extended_attributes skips checks
- [[27858]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27858) Make Koha::Patron::Attribute->store raise an exception on invalid type/code
- [[27939]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27939) Update yarn.lock file
- [[27942]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27942) QOTD: quote CSV uploads may contain JavaScript payloads (XSS)
- [[28053]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28053) Warning in C4::Members::patronflags
- [[28096]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28096) API datatables wrapper does not deal correctly with hidden columns
- [[28110]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28110) YAML::XS minimum version should be 0.67, not 0.41
- [[28156]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28156) Koha::Account::Line->renewable must be named is_renewable
- [[28221]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28221) process_message_queue.pl missing `use Try::Tiny`
- [[28244]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28244) Ukrainian is misspelled in language tables for English
- [[28276]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28276) Do not fetch config ($KOHA_CONF) from memcached
- [[28293]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28293) Wrong key used in Patrons::Import->generate_patron_attributes
- [[28367]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28367) Wrong plack condition in C4/Auth_with_shibboleth.pm

### Authentication

- [[20854]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20854) Redirect after logout with CAS 3.0 broken

  >This patch adds a new system preference casServerVersion, that will allow Koha to work correctly with different CAS protocol versions. In this case it fixes a problem that arose by changing the name of a parameter in the logout request between CAS 2 and 3 that broke the redirect after successful logout.
- [[21325]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21325) Prevent authentication when sending userid and password via querystring parameters

  >This change may break custom or creative (yet insecure) authentication integration using GET requests. These auth requests do not exist in Koha, but they may be used by extensions, customizations, or clever end users.

### Browser compatibility

- [[27282]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27282) Printing broken in some versions of Chrome

  >Printing in some versions of Google Chrome does not work correctly making it impossible to print. This patch alters the JavaScript which controls the print dialogues in order to make for a better a printing experience across all browsers.

### Cataloging

- [[20971]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20971) Corrupted storable string breaks SubfieldsToUseWhenPrefill functionality
- [[22243]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22243) Advanced Cataloguer editor fails if the target contains an apostrophe in the name
- [[23406]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23406) When using an authorised value for suppression, record doesn't show as suppressed in staff interface
- [[25777]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25777) Datatables on z3950_search.pl show incorrect number of entries
- [[26921]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26921) Create cover image even when there is no record identificator

  **Sponsored by** *Orex Digital*
- [[26964]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26964) Advanced editor no longer selects newly created macros

  >This patch fixes the behaviour for saving of new macros using the advanced editor. Before this fix the newly created macro wasn't selected and the automatic save (there isn't a save option) had nothing to save.
- [[27125]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27125) Show authority type for UNIMARC in authority search result display
- [[27128]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27128) Follow-up to bug 25728 - Don't prefill av's code
- [[27130]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27130) Adding local cover image at item level shows 'File type' section
- [[27135]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27135) Viewing local cover images at item level shows a link to upload image at record level
- [[27164]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27164) Fix item search CSV export
- [[27308]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27308) Advanced editor should skip blank lines when inserting new fields
- [[27508]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27508) Can't duplicate the MARC field tag with JavaScript if option "advancedMARCeditor" is set to "Don't display"
- [[27577]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27577) Autolink bibs after generating the biblionumber
- [[27578]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27578) Searchid not initialized when adding a new record
- [[27738]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27738) Set fallback for unset DefaultCountryField008 to |||, "no attempt to code"
- [[27739]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27739) Advanced editor should use DefaultCountryField008 system preference rather than hardcoding xxu
- [[27837]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27837) Permanent location is reverted to location when location updated and permanent_location mapped to MARC field
- [[28123]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28123) Commas in file names of uploaded files cause inconsistently broken 856$u links
- [[28270]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28270) Wrong tooltip displayed on moredetail for the claim lost status

### Circulation

- [[8287]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8287) Improve filter on checked out from overdues
- [[16785]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16785) Autocomplete broken on overdues report
- [[24488]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24488) Holds to Pull sometimes shows the wrong 'first patron' details
- [[25583]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25583) When ClaimReturnedLostValue is not set, the claim returned tab doesn't appear
- [[25690]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25690) SIP should not allow to check out an item in transfer because of a hold to another patron

  >- Proper warning messages are added in staff interface when trying to initiate transfer to an attached hold.
  >
  >- Checking out someone else's hold that is in transit is prevented
- [[26953]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26953) Phone & SMS transports always displayed in overdue status triggers
- [[27011]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27011) Warnings in returns.pl

  >This patch removes a variable ($name) that is no longer used in Circulation > Check in (/cgi-bin/koha/circ/returns.pl), and the resulting warnings (..[WARN] Use of uninitialized value in concatenation (.) or string at..) that were recorded in the error log.
- [[27058]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27058) Cannot place hold to ordered item when on shelf holds are not allowed
- [[27133]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27133) Header missing for "Copy no" on the relative's checkouts table
- [[27538]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27538) Cells in the bottom filtering row of the "Holds to pull" table shifted
- [[27548]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27548) Warnings "use of uninitialized value" on branchoverdues.pl

  >This fixes the cause of unnecessary "use of uninitialized value" warnings in the log files generated by Circulation > Overdues with fines (/cgi-bin/koha/circ/branchoverdues.pl).
  >
  >This was caused by not taking into account that the "location" parameter for this form is initially empty.
- [[27549]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27549) Warning "use of uninitialized value" on renew.pl

  >This fixes the cause of unnecessary "use of uninitialized value" warnings in the log files generated by Circulation > Renew (/cgi-bin/koha/circ/renew.pl).
  >
  >This was caused by not taking into account that the "barcode" parameter for this form is initially empty.
- [[27645]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27645) Duplicate message in batch checkout
- [[27655]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27655) Barcode column is missing from "Holds to pull" table preferences yaml file
- [[27836]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27836) Document that CircControl syspref changes which library's calendar to use
- [[27969]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27969) On checkin, relabel "Remember due date" as "Remember return date"
- [[27993]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27993) Koha::Item::Transfer->in_transit should not count cancelled transfers
- [[28013]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28013) Improvements to CanBookBeRenewed
- [[28139]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28139) Processing holds are not filled automatically
- [[28148]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28148) JavaScript error when printing transfer slip for existing transfer
- [[28202]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28202) Pickup libraries not sorted by name when placing hold

  >This corrects the sort order for library names for the pickup list when placing a hold. The list of libraries now sorts by library name, instead of the library code.

### Command-line Utilities

- [[11344]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11344) Perldoc issues in misc/cronjobs/advance_notices.pl
- [[14564]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14564) Incorrect permissions prevent web download of configuration backups
- [[17429]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17429) Document the --plack option for koha-list
- [[26851]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26851) Overdue notices should not send a report to the library if there is no content
- [[27085]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27085) Corrections in overdue_notices.pl help text

  **Sponsored by** *Lund University Library*
- [[27563]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27563) Remove check-url.pl in favor of check-url-quick.pl

  >The check-url.pl script has been deprecated since Koha 3.8 - this patch removes it. If any users are still referencing that script in their cronjobs they will need to update to the new script upon upgrade.
- [[27656]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27656) misc/cronjobs/longoverdue.pl better error message
- [[27819]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27819) Spurious errors when running delete_records_via_leader.pl
- [[28028]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28028) Remove broken fix_onloan.pl maintenance script

  >This script is removed from the codebase, as it was non-functional for a long time which also suggests that it wasn't used.
- [[28255]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28255) Follow up to bug 23463 - use item_object in misc/cronjobs/delete_items.pl

### Database

- [[7806]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7806) Don't use 0000-00-00 to signal a non-existing date
- [[17809]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17809) Correct some authorised values in fr-FR

### Developer documentation

- [[28305]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28305) Remove doc reference to XML::Simple in C4::Context

### Fines and fees

- [[20527]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20527) "label" tag linked to the wrong "input" tag (wrong "for" attribute) in paycollect.tt

  >This fixes the HTML 'label for=""' element for the Writeoff amount field on the Accounting > Make a payment form for a patron - changes "paid" to "amountwrittenoff".
- [[24519]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24519) Change calculation and validation in Point of Sale should match Paycollect
- [[26593]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26593) Rental discounts are applied in wrong precedence order
- [[27180]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27180) Fines cronjob does not update fines on holidays when finesCalendar is set to ignore

  >Prior to this patchset the fines cronjob would not run on holidays. This was to ensure that dropbox mode correctly decremented fines. 
  >
  >Dropbox mode has been rewritten and we can now correctly calculate and charge fines on holidays (or not) following the calendar and system preferences.
- [[27290]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27290) Cash register allows for 'amount tendered' less than amount being paid
- [[27811]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27811) Manage patrons fines and fees (updatecharges)  subpermissions shows links/buttons that cannot be accessed
- [[28097]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28097) t/db_dependent/Koha/Account/Line.t test fails with FinesMode set to calculate
- [[28144]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28144) Historical OVERDUE fines may not have an issue_id
- [[28147]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28147) Pass itemnumber when writing off a single debit
- [[28168]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28168) Manual invoice form pre-fills Amount field with invalid number
- [[28181]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28181) Archived debit type still shows as available in Point of Sale
- [[28266]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28266) Misspelled word: recieved in cashup confirmation pop-up

### Hold requests

- [[12362]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12362) Branch transfer records orphaned on cancelled holds

  >This change improves the queue handling for transfer cancellations.
  >
  >With this patch, if a transfer is force-cancelled whilst it is in transit then a reverse transfer will be created to ensure the item gets back to the originating library unless there are already other transfers in the queue, in which case the next transfer in the queue will take precedence.
- [[16787]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16787) 'Too many holds' message appears inappropriately and is missing data
- [[18729]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18729) Librarian unable to update hold pickup library from patron pages without "modify_holds_priority" permission
- [[25760]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25760) Holds ratio report is not reporting on records with 1 hold
- [[26367]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26367) Warn in HoldsQueue if request itemtype set but request is not item specific
- [[26976]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26976) When renewalsallowed is empty the UI is not correct
- [[26999]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26999) "Any library" not translatable on the hold list
- [[27117]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27117) Staff without modify_holds_priority permission can't update hold pick-up from biblio
- [[27706]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27706) Holds to Pull libraries column filter doesn't work
- [[27718]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27718) Holds to Pull list doesn't respect holdallowed circulation rule anymore
- [[27729]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27729) Code around SkipHoldTrapOnNotForLoanValue contains two perl bugs
- [[27732]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27732) JavaScript error on place hold page in the staff interface

  >This patch fixes the cause of a JavaScript console error ("Uncaught ReferenceError: $ is not defined") when placing a hold using the staff interface. It:
  >- Moves the "$.fn.select2.defaults" definition from the top of the page to the bottom so that jQuery is loaded first.
  >- Improves the display of the dropdown list for the pickup library so that the width is wider.
- [[27733]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27733) Sort pickup locations by library name instead of branchcode
- [[27803]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27803) publicationyear / copyrightdate not included in Holds to Pull

  **Sponsored by** *Catalyst*
- [[27921]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27921) Timestamp in holds log is out of date when a hold is marked as waiting
- [[28078]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28078) Add option to ignore hold counts when checking CanItemBeReserved
- [[28118]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28118) Fix missing "selected" attribute in "Pickup at" dropdown
- [[28125]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28125) All OPAC holds blocked when OPACHiddenItems contains incorrect values
- [[28169]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28169) Reverting waiting hold causes holds page Javascript stop functioning
- [[28286]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28286) Place hold button not displayed when biblio has only Ordered items

### I18N/L10N

- [[27398]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27398) Serials: Values in subscription length pull down are not translatable when defining numbering patterns
- [[27416]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27416) String 'Modify tag' in breadcrumb is untranslatable
- [[27815]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27815) "Remove" in point of sale untranslatable
- [[27816]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27816) "Click to edit" in Point of sale is untranslatable

### ILL

- [[25614]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25614) "Clear filter" button permanently disabled on ILL request list

### Installation and upgrade (web-based installer)

- [[11996]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11996) Default active currencies for ru-RU and uk-UA are wrong

  >This fixes the currencies in the sample installer files for Russia (ru-RU; changes GRN -> UAH, default remains as RUB) and the Ukraine (uk-UA; changes GRN -> UAH).
- [[24810]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24810) French SQL files for "news" contain "Welcome into Koha 3!"

  >This removes the Koha version number from the sample news items for the French language installer files (fr-FR and fr-CA).
- [[24811]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24811) French SQL files for "news" contain broken link to the wiki

  >This fixes a broken link in the sample news items for the French language installer files (fr-FR and fr-CA).
- [[27621]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27621) Remove it-IT installer data

  >This removes the SQL installer directory from the Koha source code. Installing Italian sample data will still be possible, but translations have been moved into Koha's translation system using .po files maintained on https://translate.koha-community.org.
- [[27623]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27623) Remove pl-PL installer data

  >This removes the SQL installer directory from the Koha source code. Installing Polish sample data will still be possible, but translations have been moved into Koha's translation system using .po files maintained on https://translate.koha-community.org.
- [[27624]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27624) Remove ru-RU installer data
- [[27625]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27625) Remove uk-UA installer data

### Lists

- [[28069]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28069) Can't sort lists on staff client

### MARC Authority data support

- [[21958]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21958) _check_valid_auth_link checks too many subfields
- [[28159]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28159) URI-encode existing values put into query string for z39.50 authority search
- [[28160]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28160) Values from 150$a aren't prefilled in z39.50 search form from an existing authority record

### MARC Bibliographic data support

- [[25632]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25632) Update MARC21 frameworks to update Nr. 30 (May 2020)

### MARC Bibliographic record staging/import

- [[26171]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26171) Show biblionumber in Koha::Exceptions::Metadata::Invalid
- [[27099]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27099) Stage for import button not showing up

### Mana-kb

- [[27061]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27061) Double permission check in svc/mana/search

### Notices

- [[13613]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13613) Don't allow digest to be selected without a digest-able transport selected
- [[24447]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24447) POD of C4::Members::Messaging::GetMessagingPreferences() is misleading
- [[28017]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28017) Allow non-FQDN and IP addresses in emails
- [[28258]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28258) Bad date formatting in AUTO_RENEWALS notice

### OPAC

- [[18112]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18112) Add street type to main address in OPAC
- [[21260]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21260) Improve the Availability line of OPAC XSLT search results

  >This report adds preference Reference_NFL_Statuses that allows you to define the not for loan statuses that you want to be reported as Available for reference on the OPAC results display (XSLT based).
  >Basis for further adjustments on bug 26302.
- [[26406]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26406) Suggestions filter does not work
- [[26578]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26578) OverDrive results can return false positives when searches contain CCL syntax
- [[26941]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26941) Missing OPAC password recovery error messages
- [[27047]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27047) Purchase suggestions search filter is broken
- [[27090]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27090) In the location column of an OPAC cart the 'In transit from' and 'to' fields are empty
- [[27168]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27168) Most popular doesn't always sort correctly
- [[27178]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27178) OPAC results and lists pages contain invalid attributes (xmlns:str="http://exslt.org/strings")
- [[27230]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27230) purchase suggestion authorized value opac_sug doesn't show opac description
- [[27261]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27261) PatronSelfRegistrationBorrowerUnwantedField should exclude branchcode

  >This patch excludes the ability to add branchcode to the PatronSelfRegistrationBorrowerUnwantedField system preference.
- [[27297]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27297) When itemtype is marked as required in OpacSuggestion MandatoryFields the field is not required
- [[27325]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27325) Fix singular/plural forms on the OPAC dashboard
- [[27450]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27450) Making password required for patron registration breaks patron modification
- [[27543]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27543) Tooltip on opac-messaging.pl obscured by table headers

  >This patch fixes the display of tooltips in a patrons OPAC account for the 'your messaging' section. It corrects which Bootstrap assets are compiled with the OPAC CSS - the file for Bootstrap tooltips should be included.
- [[27566]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27566) CSS rule not applying to HTML select / option -  displays with serif font ignoring rules
- [[27571]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27571) "Add to lists" on MARC and ISBD view of OPAC detail page doesn't open in new window
- [[27628]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27628) Fix minor HTML markup errors in OPAC search results templates
- [[27633]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27633) Display of 440$v doubled up in the OPAC

  >This fixes the display of 440$v (Series Statement/Added Entry-Title - Volume/sequential designation ($v)) in the OPAC. Before this fix $v is included in the title link and then displayed after the ;. With the fix $v is only displayed after the ; and is not duplicated in the title link.
- [[27650]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27650) Wrong variable passed to the template in opac-main
- [[27726]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27726) OPACProblemReports cuts off message text
- [[27748]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27748) Encoding problem in link to OverDrive results
- [[27830]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27830) OPAC library list does not use AddressFormat
- [[27881]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27881) Markup error in masthead-langmenu.inc
- [[27889]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27889) Form fields in OPAC are "out of shape"

  >This patch tweaks the CSS for the advanced search form in the OPAC so that it adjusts well at various browser widths, including preventing the form from taking up the whole width of the page at higher browser widths.
- [[27940]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27940) Fix missing email in OpacMaintenance page

  >This fixes no email address being shown on the OPAC maintenance page for "site administrator" link (when OpacMaintenance is set). Before this the link was showing as an empty "mailto:" instead of the value of KohaAdminEmailAddress
- [[27961]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27961) External track clicks links should get uri filtered

  **Sponsored by** *Parliamentary Library New Zealand*
- [[27979]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27979) Multiple item URIs break redirect if TrackClicks enabled

  **Sponsored by** *Catalyst*
- [[28086]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28086) Email address shown on OpacMaintenancePage should use ReplytoDefault if set

  >This enhancement changes the OPAC maintenance page* so that it uses the email address from the ReplyToDefault system preference, if it is set, for the "please contact the site administrator" email link.
  >
  >If ReplyToDefault is not set, it will use KohaAdminEmailAddress.
  >
  >If both ReplytoDefault and KohaAdminEmailAddress are not set, no link is shown.
  >
  >* Displays when the OpacMaintenance system preference is set to "Show".
- [[28094]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28094) Fix bad encoding of OVERRIDE_SYSPREF_LibraryName
- [[28114]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28114) OPAC Results availability line does not show homebranch/holding branch correctly
- [[28140]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28140) Accessibility: OPAC - "sort_by"  select isn't labelled on search results page
- [[28162]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28162) Self registration fails if patron extended attributes are editable
- [[28241]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28241) OPACNoResultsFound {QUERY_KW} placeholder doesn't always match the search terms when commas are included in the search

### Patrons

- [[17364]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17364) branchcode in BorrowerUnwantedField causes software error when saving patron record

  >A more user friendly interface for selecting database columns for some system preferences (such as BorrowerUnwantedField) was added in Koha 20.11 (Bug 22844). 
  >
  >Some database columns should be excluded from selection as they can cause server errors. For example, branchcode in BorrowerUnwantedField is required for adding patrons - if selected it causes a server error and you can't add a patron, so it should not be selectable.
  >
  >This bug fixes the issue by:
  >
  >- allowing developers to define the database columns to exclude from selection in the .pref system preference definition file using "exclusions: "
  >
  >- disabling the selection of the excluded database columns in the staff interface when configuring system preferences that allow selecting database columns
  >
  >- updating the BorrowerUnwantedField system preference to exclude branchcode
- [[26059]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26059) Create guarantor/guarantee links on patron import
- [[26417]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26417) Remove warn in Koha::Patron is_valid_age
- [[26797]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26797) Error when trying to access Relative Checkouts between Professional and Organizational patron categories
- [[26940]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26940) debarred comment in borrowers table is lost on patron modifications in memberentry.pl page
- [[26956]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26956) Allow "Show checkouts/fines to guarantor" to be set without a guarantor saved
- [[26995]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26995) Drop column relationship from borrower tables
- [[27454]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27454) Additional patron attributes change sequence on every reload of edit page

  >This fixes the order that additional patron attributes are displayed on the patron edit form. They are now sorted by the attribute code, before this they displayed in a random order.
- [[27604]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27604) PatronSelfRegistrationLibraryList can be bypassed
- [[27717]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27717) Date of birth fails to display for babies under 1 year
- [[27822]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27822) Wrong systempreference for AddressFormat (es-ES)
- [[27937]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27937) Date of birth entered  without correct format causes internal server error
- [[28043]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28043) Some patron clubs operations don't work from later pages of results

### Plugin architecture

- [[27114]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27114) Use Template Toolkit plugin for Koha plugins hook 'intranet_catalog_biblio_tab'

  >Koha plugins hook 'intranet_catalog_biblio_tab' now uses Template Toolkit plugin (like hook 'intranet_js', ...).
  >It makes it easy to use it in other places (like MARC details page for example).
- [[27120]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27120) Send biblio to Koha plugins hook 'intranet_catalog_biblio_tab'

### REST API

- [[26181]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26181) Holds placed via the REST API should not be forced by default even if AllowHoldPolicyOverride is enabled

  >This patch disables AllowHoldPolicyOverride by default in the /holds REST API. It also adds tests for this behaviour, and adds a header that can be used to request the override explicitly.
- [[27034]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27034) $c->objects->search shouldn't use path parameters
- [[27330]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27330) Wrong return status when no enrollments in club holds
- [[27593]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27593) Inconsistent return status on club holds routes
- [[27863]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27863) Cannot select different pickup locations even with AllowHoldsPolicyOverride on request.pl
- [[28254]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28254) Make it possible to override rules in PUT /holds/:hold_id/pickup_location
- [[28272]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28272) Definition files are missing additionalProperties: false

  >When the REST API spec was first written we assumed additionalProperties: false was the default behavior. It probably was by then.
  >
  >We recently found the need to explicitly add it to all the relevant places (i.e. those that require strictness).
  >
  >This bug adds it, and fixes the tests that fail or the error conditions that were hidden due to this being absent in the spec.
- [[28414]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28414) Fix labels for return claims routes
- [[28424]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28424) POST /patrons/:patron_id/account/credits return value wrong
- [[28461]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28461) Specify only one tag per route

### SIP2

- [[25808]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25808) Renewal via the SIP 'checkout' message gives incorrect message
- [[26701]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26701) Remove scripts from C4/SIP directory
- [[27014]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27014) SIP2 cannot find patrons at checkin
- [[27204]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27204) SIP patron information request with fee line items returns incorrect data
- [[27936]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27936) AllowItemsOnHoldCheckoutSIP does not allow checkout of items currently waiting for a hold
- [[28052]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28052) keys omitted in check for system preference override
- [[28054]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28054) SIPServer.pm is a program and requires a shebang
- [[28320]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28320) SIP SC Status message should check the DB connection

### Searching

- [[26533]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26533) Searching authorities using 'is exactly' doesn't work as expected

  **Sponsored by** *Education Services Australia SCIS*

  >Searching authorities using 'is exactly' was matching on any word in the heading. Now it is matching the heading exactly (the entire heading).
- [[26679]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26679) Genre tags linking to subject search, causing null results
- [[26957]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26957) Find duplicate removes operators from the middle of search terms
- [[27745]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27745) Use of uninitialized value in hash element error at C4/Search.pm
- [[27746]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27746) Use of uninitialized value $oclc in pattern match (m//) error at C4/Koha.pm
- [[27928]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27928) FindDuplicate is hardcoded to use Zebra
- [[28074]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28074) Browse controls on staff detail pages are sometimes weird
- [[28213]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28213) Deleting a patron or patron club causes server error on searching

### Searching - Elasticsearch

- [[26051]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26051) Elasticsearch uses the wrong field for callnumber sorting

  >This fixes the sorting of search results by call number when using Elasticsearch. Currently it does not sort correctly (uses local-classification instead of cn-sort) and may also cause error messages "No results found" and "Error: Unable to perform your search. Please try again.". This also matches the behaviour used by Zebra.
- [[26996]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26996) Elasticsearch: Multiprocess reindexing sometimes doesn't reindex all records

  **Sponsored by** *Lund University Library*
- [[27043]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27043) Add to number_of_replicas and number_of_shards  to index config

  >Elasticsearch 6 server has default value 5 for "number_of_shards" but warn about Elasticsearch 7 having default value 1.
  >So its is better to set this value in configuration file.
  >Patch also sets number_of_replicas to 1.
  >If you have only one Elasticsearch node, you have to set this value to 0.
- [[27307]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27307) "Keyword as phrase" option in search dropdown doesn't work with Elastic
- [[27316]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27316) In mappings use yes/no for sortable
- [[27724]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27724) Use lenient also in Elasticsearch authorities search
- [[28268]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28268) Improve memory usage when indexing authorities in Elasticsearch

### Searching - Zebra

- [[8426]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8426) Map  ︡a to a and t︠ to t for searching (Non-ICU)
- [[27299]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27299) Zebra phrase register is incorrectly tokenized when using ICU

  >Previously, Zebra indexing in ICU mode was incorrectly tokenizing text for the "p" register. This meant that particular phrase searches were not working as expected. With this change, phrase searching works the same in ICU and CHR modes.

### Serials

- [[27332]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27332) When renewing a serial subscription, show note and library only if RenewSerialAddsSuggestion is used
- [[27397]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27397) Serials: The description input field when defining numbering patterns is too short

### Staff Client

- [[23475]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23475) Search context is lost when simple search leads to a single record
- [[26946]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26946) Limit size of cash register's name on the UI
- [[27321]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27321) Make excluded database columns in system preferences more clearly disabled

  >This enhancement styles non-selectable database columns in system preferences in a light grey (#cccccc), making them easier to identify. Currently the checkbox and label are the same color as selectable columns.
- [[27336]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27336) JS error in Administration - System preferences page
- [[27408]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27408) Update intranet-tmpl/prog/en/modules/members/mancredit.tt for ACC2

  >This patch updates occurrences of input type="number" in intranet-tmpl/prog/en/modules/members/mancredit.tt to use 'input type="text" inputmode="numeric" pattern="^\d+(\.\d{2})?$"' as per the accessibility coding guideline ACC2.
- [[27410]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27410) Update intranet-tmpl/prog/en/modules/members/maninvoice.tt to reflect ACC2
- [[27653]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27653) Do not include 'caption' row in print/copy export of datatables
- [[27776]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27776) Point of Sale 'This sale' table should not be sorted by default
- [[27777]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27777) Improve tables on Point of Sale page for low screen resolutions
- [[27926]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27926) Date of birth sorting with British English format is broken
- [[28187]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28187) rowGroup headings are getting their styles overriden

### System Administration

- [[27250]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27250) DELETE calls are stacked on the SMTP servers admin page
- [[27264]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27264) Reword sentence of OPACHoldsHistory
- [[27280]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27280) Explanation for "Days mode" is not consistent
- [[27310]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27310) Wrong CSS float on 'Visibility' in framework edition

  >This fixes the display of the 'Visibility' label when editing subfields for a framework. The label is now aligned correctly with the other labels.
- [[27349]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27349) Mana system preference wrong type YesNo
- [[27351]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27351) UsageStatsCountry system preference wrong type YesNo
- [[27703]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27703) Can't navigate in Authorized values

  >This fixes an issue when navigating authorized value categories - if you selected an authorized value category from the drop down list it wouldn't change to the selected category.
- [[27713]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27713) Duplicate search field IDs in MARC framework administration template
- [[27716]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27716) Insufficient access control for printer profiles

  >This change moves the label creator pages, including the printer profiles management, under the 'lable_creator' permission under tools. This gives a more refined access permission for this area of functionality.
- [[27798]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27798) Independent branches should have a warning
- [[27968]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27968) MARC framework CSV and ODS import incomplete or corrupted
- [[27999]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27999) Display the description of authorized values category
- [[28121]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28121) Wrong punctuation on desk deletion
- [[28207]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28207) Crash when seeing MARC structure of a new framework
- [[28345]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28345) Patron attributes no longer have option to select empty class

### Task Scheduler

- [[27109]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27109) Better labels for background job details
- [[27127]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27127) Wrong display of messages if there was only 1 record modified

### Templates

- [[20238]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20238) Show description of ITEMTYPECAT instead of code in itemtypes summary table

  >This enhancement changes the item types page (Koha administration > Basic parameters > Item types) so that the search category column displays the ITEMTYPECAT authorized value's description, instead of the authorized value code. (This makes it consistent with the edit form where it displays the descriptions for authorized values.)
- [[24055]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24055) Description of PayPalReturnURL system preference is unclear

  >This enhancement improves the description of the PayPalReturnURL. Changed from 'configured return' to 'configured return URL' as this is what it is called on the PayPal website.
- [[25954]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25954) Header search forms should be labeled
- [[26471]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26471) Datatables js error on missing pdfmake.min.js.map
- [[26602]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26602) Datatables - Actions columns should not be exported
- [[27027]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27027) Typo: has successfully been modified.. %s

  >This fixes a grammatical error in koha-tmpl/intranet-tmpl/prog/en/modules/admin/background_jobs.tt (has successfully been modified..) - it replaces two full stops at the end of the sentence with one.
- [[27031]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27031) Koha.Preference() should be used more often in header.inc and js_includes.inc
- [[27232]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27232) Missing spaces in member-alt-contact-style.inc make some strings appearing twice in po
- [[27277]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27277) Queued vs Enqueued
- [[27292]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27292) TablesSettings.GetColumns() returning nothing creates unexpected Javascript on request.tt
- [[27324]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27324) Use Koha.Preference() for intranetbookbag everywhere
- [[27356]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27356) Don't hide the SMTP servers table when last displayed is deleted
- [[27430]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27430) Use minimum length for patron category on password hint

  >This corrects the hint on the patron add/edit form to take into account that the minimum password length can now also be set on patron category level.
- [[27457]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27457) Set focus for cursor to Debit type code field when creating new debit type
- [[27458]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27458) Set focus for cursor to Credit type code field when creating new credit type
- [[27525]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27525) 'wich' instead of a 'with' in a sentence

  >This patch fixes two spelling errors in the batchMod-del.tt template that is used by the batch item deletion tool in the staff interface: "wich" -> "with."
- [[27531]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27531) Remove type attribute from script tags: Cataloging plugins
- [[27561]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27561) Remove type attribute from script tags: Various templates
- [[27654]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27654) "Table settings for Pages" need to be sorted on "Administration -> Table settings"
- [[27668]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27668) Improve validation of patron entry form in the OPAC
- [[27695]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27695) Fix style of messages on Elasticsearch configuration page
- [[27752]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27752) Correct ESLint errors in batchMod.js

  >This patch makes minor changes to batchMod.js used in Tools > Batch item modification. This addresses errors raised by ESLint, including white space changes, to make sure it meets coding guideline JS8: Follow guidelines set by ESLint.
- [[27754]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27754) Correct eslint errors in basket.js

  >This patch makes minor changes to basket.js in the staff interface templates to remove ESLint warnings. Besides whitespace changes, most changes are to correct undeclared or unnecessarily declared variables.
- [[27795]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27795) Misalignment of TOTAL value in lateorders page
- [[27827]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27827) Authority type input field for new authority types should be wider
- [[27861]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27861) Warning in C4/XSLT.pm - use of uninitialized value in numeric eq (==)
- [[27899]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27899) Missing description for libraryNotPickupLocation on request.pl
- [[28004]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28004) Incomplete breadcrumbs in authorized valued

  >This patch fixes some incorrect displays within the breadcrumbs on authorised_values.tt
- [[28032]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28032) Button corrections in point of sale pages
- [[28033]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28033) Minor capitalization corrections
- [[28042]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28042) Button corrections in OAI set mappings template
- [[28135]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28135) Replace use of input type number in additem.js
- [[28190]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28190) Library limitation column not toggable on itemtypes table

### Test Suite

- [[26364]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26364) XISBN.t makes a bad assumption about return values
- [[26405]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26405) Circulation.t fails on 'AddRenewal left both fines'
- [[27317]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27317) (Bug 27127 follow-up) fix t/db_dependent/Koha/BackgroundJobs.t
- [[27554]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27554) Clarify and add tests for Koha::Patrons->update_category_to child to adult
- [[28234]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28234) TestBuilder->build_sample_biblio does not deal correctly with encoding
- [[28249]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28249) Selenium->wait_for_element_visible can fall in an infinite loop
- [[28250]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28250) Debug from Selenium error handler is no longer working
- [[28288]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28288) XISBN.t is failing is 500 is returned by the webservice

### Tools

- [[17202]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17202) Deleting a rotating collection with items should either be prohibited or items should be removed
- [[21818]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21818) Don't use AutoCommit flag in stage-marc-import.pl
- [[26298]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26298) If MaxItemsToProcessForBatchMod is set to 1000, the max is actually 999
- [[26336]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26336) Cannot import items if items ignored when staging
- [[26894]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26894) Marc Modification Templates treat subfield 0 as no subfield set when moving fields
- [[26942]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26942) TinyMCE in the News Tool is still doing some types of automatic code cleanup
- [[26983]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26983) Selecting ALL Items in Inventory- only selects 20
- [[27247]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27247) Missing highlighting in Quote of the day
- [[27413]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27413) Cannot add debarment with batch patron modification tool
- [[27576]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27576) Don't show import records table when cleaning a batch
- [[27694]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27694) News tool editor (codemirror) automatically converts HTML entities
- [[27869]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27869) QotD CSV upload JavaScript errors

  >This patch handles malformed CSV errors by producing a warning on the page letting users know that the CSV filed uploaded has errors.
- [[27963]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27963) touch_all_items.pl script is not working at all
- [[28044]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28044) Calendar: Tables with closed days are no longer color coded
- [[28170]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28170) Downloading some files via Tools - Upload is broken
- [[28178]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28178) Image viewer does not select the correct image

  **Sponsored by** *Gerhard Sondermann Dialog e.K. (presseplus.de, presseshop.at, presseshop.ch)*
- [[28198]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28198) Sample notices SQL fails on HOLD_REMINDER: Column count doesn't match value count
- [[28229]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28229) Hide clubs from place a hold screen if no clubs exist

### Web services

- [[17229]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17229) ILS-DI HoldTitle and HoldItem should check if patron is expired
- [[21301]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21301) Restriction of the informations given by GetRecords ILS-DI service

  >For privacy protection, ILS-DI webservice GetRecords will not give patron information anymore. Also old issues are not given anymore.
  >This removes method C4::Circulation::GetBiblioIssues().

### Z39.50 / SRU / OpenSearch Servers

- [[26528]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26528) Koha return no result if  there's  invalid records in Z39.50/SRU server reply
- [[27149]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27149) Z3950Responder removes itemnumber when adding item statuses
- [[28112]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28112) Z39.50 does not populate form with all passed criteria

## New system preferences

- AcquisitionLog
- AutoRenewalNotices
- ChargeFinesOnClosedDays
- CheckPrevCheckoutDelay
- ClaimsLog
- DefaultHoldExpirationdate
- DefaultHoldExpirationdatePeriod
- DefaultHoldExpirationdateUnitOfTime
- DefaultSaveRecordFileID
- ElasticsearchCrossFields
- LockExpiredDelay
- NoticesLog
- OpacHiddenItemsHidesRecord
- Reference_NFL_Statuses
- SearchLimitLibrary
- casServerVersion

## Renamed system preferences

- delimiter     => CSVDelimiter
- LetterLog     => ClaimsLog
- UseICU        => UseICUStyleQuotes
- gist          => TaxRates
- opaclanguages => OPACLanguages
- reviewson     => OPACComments

## Deleted system preferences

- EnablePayPalOpacPayments
- PayPalChargeDescription
- PayPalPwd
- PayPalReturnURL
- PayPalSandboxMode
- PayPalSignature
- PayPalUser

## New Authorized value categories

- UPLOAD

## New letter codes

- HOLD_REMINDER
- AUTO_RENEWALS_DGST
- CHECKINSLIP

## Technical highlights

Some significant technical changes were made behind the scenes in this release and it was felt that they should be additionally highlighted in the notes as they could be easily missed above.

### Dev tools

- The kohastructure.sql schema will be regenerated before each release [[26947]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26947). A new option has been created to generate it from the database: `koha-dump --schema-only`
It will let you compare easily the structure of your DB with the one in the codebase.

### REST API Enhancements

- We are proud to introduce a new resource for third party integration developers: [https://api.koha-community.org](https://api.koha-community.org). This new documentation resource describes all api endpoints for the supported versions of Koha and makes the Swagger specification available for download and work will continue in the next cycle to improve this excellent new resource for application integrators everywhere.

- Numerous new API endpoints have been introduced this cycle, including patron attributes, transfers, holds, pickup libraries, cash management, to name but a few.

- We added the "additionalProperties" flag to our API schema to be more strict and found issues and inconsistencies. Unspecified properties passed in the object will make the route rejected [[28272]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28272)

- New Mojolicious helper "x-koha-override" [[27760]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27760) to pass "overrides" methods. For instance for "too many holds" when a confirmation is needed on the GUI.

### Translatability/installer

The specific .sql files from the installer directory will be removed in the upcoming release.
A workgroup will be formed during the 21.11 development cycle to remove the remaining ones.
So far we got rid of de-DE, es-ES, it-IT, pl-PL, ru-RU and uk-UA.
The remaining ones are fr-FR, fr-CA, nb-NO. You can see the work on the omnibus bug report [[27829]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27829).
If you are using one of these languages and their .sql files, please contact the core team to tell us what you want to keep from them.

### Test suite

- We implemented a LIGHT_RUN (default 1) switch to run heavy tests only on a single job (Koha_Master). The other jobs are not running the selenium and www tests. That allows us to run the test suite faster than before.

### Errors handling

The RaiseError flag is now set on the DB handler. That means we will never fail a SQL query silently.
That might lead to unexpected explosion (server error 500) but will help the development team to catch remaining bug.
To avoid displaying an ugly "Software error" page, we created an error page that is nicely integrated into Koha.

Another effect of this change is that the update database process will not stop if something wrong happened during the upgrade procedure.

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/21.05/ar/html/) (34.3%)
- [Chinese (Taiwan)](https://koha-community.org/manual/21.05/zh_TW/html/) (58.5%)
- [Czech](https://koha-community.org/manual/21.05/cs/html/) (27.6%)
- [English (USA)](https://koha-community.org/manual/21.05/en/html/)
- [French](https://koha-community.org/manual/21.05/fr/html/) (45.8%)
- [French (Canada)](https://koha-community.org/manual/21.05/fr_CA/html/) (25.2%)
- [German](https://koha-community.org/manual/21.05/de/html/) (65%)
- [Hindi](https://koha-community.org/manual/21.05/hi/html/) (94.7%)
- [Italian](https://koha-community.org/manual/21.05/it/html/) (47.8%)
- [Spanish](https://koha-community.org/manual/21.05/es/html/) (34.8%)
- [Turkish](https://koha-community.org/manual/21.05/tr/html/) (40.3%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (91.3%)
- Armenian (99.1%)
- Armenian (Classical) (89%)
- Chinese (Taiwan) (81.6%)
- Czech (67.2%)
- English (New Zealand) (62.2%)
- English (USA)
- Finnish (80.8%)
- French (82.7%)
- French (Canada) (83.6%)
- German (99.9%)
- German (Switzerland) (61.5%)
- Greek (55%)
- Hindi (99.9%)
- Italian (92.6%)
- Nederlands-Nederland (Dutch-The Netherlands) (62.6%)
- Norwegian Bokmål (58.2%)
- Polish (85.5%)
- Portuguese (80%)
- Portuguese (Brazil) (87.9%)
- Russian (87%)
- Slovak (73.6%)
- Spanish (91.7%)
- Swedish (77.5%)
- Telugu (99.7%)
- Turkish (90%)
- Ukrainian (60.9%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 21.05.00 is


- Release Manager: Jonathan Druart

- Release Manager assistants:
  - Martin Renvoize
  - Tomás Cohen Arazi

- QA Manager: Katrin Fischer

- QA Team:
  - David Cook
  - Agustín Moyano
  - Martin Renvoize
  - Marcel de Rooy
  - Joonas Kylmälä
  - Julian Maurice
  - Tomás Cohen Arazi
  - Josef Moravec
  - Nick Clemens
  - Kyle M Hall
  - Victor Grousset

- Topic Experts:
  - UI Design -- Owen Leonard
  - REST API -- Tomás Cohen Arazi
  - Zebra -- Fridolin Somers
  - Accounts -- Martin Renvoize

- Bug Wranglers:
  - Amit Gupta
  - Mengü Yazıcıoğlu
  - Indranil Das Gupta

- Packaging Managers:
  - David Cook
  - Mason James
  - Agustín Moyano

- Documentation Manager: Caroline Cyr La Rose


- Documentation Team:
  - Marie-Luce Laflamme
  - Lucy Vaux-Harvey
  - Henry Bolshaw
  - David Nind

- Translation Managers: 
  - Indranil Das Gupta
  - Bernardo González Kriegel

- Release Maintainers:
  - 20.11 -- Fridolin Somers
  - 20.05 -- Andrew Fuerste-Henry
  - 19.11 -- Victor Grousset

## Credits
We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 21.05.00

- Asociación Latinoamericana de Integración
- Banco Central de la República Argentina
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)
- [Centre collégial des services regroupés](http://www.ccsr.qc.ca)
- [Collecto](https://collecto.ca)
- Education Services Australia SCIS
- Gerhard Sondermann Dialog e.K. (presseplus.de, presseshop.at, presseshop.ch)
- Gothenburg University Library
- Hypernova Oy
- Koha-Suomi Oy
- Lund University Library
- Orex Digital
- Parliamentary Library New Zealand
- Virginia Polytechnic Institute and State University

We thank the following individuals who contributed patches to Koha 21.05.00

- Aleisha Amohia (15)
- Ethan Amohia (1)
- Jasmine Amohia (1)
- Tomás Cohen Arazi (211)
- Alex Arnaud (1)
- Cori Lynn Arnold (1)
- Eden Bacani (8)
- Stefan Berndtsson (1)
- Philippe Blouin (2)
- Henry Bolshaw (3)
- Alex Buckley (2)
- Colin Campbell (4)
- Nick Clemens (162)
- David Cook (22)
- Christophe Croullebois (1)
- Jonathan Druart (487)
- Magnus Enger (2)
- Victoria Faafia (1)
- Bouzid Fergani (1)
- Katrin Fischer (36)
- Andrew Fuerste-Henry (4)
- Lucas Gass (29)
- Didier Gautheron (5)
- Victor Grousset (9)
- Kyle M Hall (46)
- Andrew Isherwood (10)
- Mason James (4)
- Pasi Kallinen (2)
- Mazen Khallaf (10)
- Amy King (10)
- Bernardo González Kriegel (1)
- Joonas Kylmälä (22)
- Owen Leonard (165)
- Ava Li (6)
- Catherine Ma (6)
- Ere Maijala (3)
- Julian Maurice (14)
- Matthias Meusburger (3)
- Josef Moravec (7)
- Agustín Moyano (16)
- David Nind (1)
- Andrew Nugged (2)
- Björn Nylén (1)
- James O'Keeffe (11)
- Dobrica Pavlinušić (1)
- Maxime Pelletier (1)
- Séverine Queune (2)
- Martin Renvoize (193)
- Phil Ringnalda (6)
- David Roberts (1)
- Marcel de Rooy (22)
- Caroline Cyr La Rose (3)
- Andreas Roussos (4)
- Lisette Scheer (1)
- Samir Shah (1)
- Fridolin Somers (43)
- Arthur Suzuki (1)
- Emmi Takkinen (8)
- Lari Taskula (2)
- Mirko Tietgen (1)
- Mark Tompsett (1)
- Koha translators (1)
- Petro Vashchuk (14)
- Timothy Alexis Vass (2)
- Ella Wipatene (5)
- Wainui Witika-Park (45)
- Mengü Yazıcıoğlu (3)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 21.05.00

- Athens County Public Libraries (165)
- BibLibre (68)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (36)
- Bibliothèque Universitaire des Langues et Civilisations (BULAC) (2)
- ByWater-Solutions (241)
- Catalyst (47)
- Catalyst Open Source Academy (15)
- Chetco Community Public Library (6)
- Dataly Tech (4)
- Devinim (3)
- Göteborgs Universitet (1)
- Hypernova Oy (2)
- Independant Individuals (82)
- Koha Community Developers (490)
- Koha-Suomi (6)
- KohaAloha (4)
- Latah County Library District (1)
- Libriotech (2)
- Prosentient Systems (22)
- PTFS-Europe (208)
- Rijks Museum (22)
- Solutions inLibro inc (6)
- The City of Joensuu (1)
- The Donohue Group (1)
- Theke Solutions (227)
- Lund University Library (3)
- UK Parliament (3)
- Universidad Nacional de Córdoba (1)
- University of Helsinki (25)
- Wellington East Girls' College (1)

We also especially thank the following individuals who tested patches
for Koha

- Hasina Akhter (4)
- Aleisha Amohia (1)
- Tomás Cohen Arazi (101)
- Eden Bacani (2)
- Donna Bachowski (1)
- Allison Blanning (1)
- Henry Bolshaw (33)
- Sonia Bouis (3)
- Galen Charlton (1)
- Nick Clemens (145)
- David Cook (19)
- Holly Cooper (1)
- Chris Cormack (1)
- Alvaro Cornejo (1)
- Sarah Daviau (1)
- Michal Denar (38)
- Jonathan Druart (1292)
- Victoria Faafia (1)
- Katrin Fischer (396)
- Marti Fuerst (5)
- Andrew Fuerste-Henry (77)
- Marti Fyerst (3)
- Brendan Gallagher (4)
- Lucas Gass (47)
- Didier Gautheron (1)
- Kim Gnerre (3)
- Todd Goatley (2)
- Victor Grousset (105)
- Amit Gupta (23)
- Kyle M Hall (227)
- Stina Hallin (2)
- Katariina Hanhisalo (3)
- Frank Hansen (2)
- Mark Hofstetter (1)
- Abbey Holt (1)
- Luke Honiss (1)
- Ron Houk (8)
- Andrew Isherwood (1)
- Mason James (3)
- Barbara Johnson (19)
- Daniel Jones (1)
- Christopher Kellermeyer (2)
- Mazen Khallaf (3)
- Bernardo González Kriegel (1)
- Rhonda Kuiper (2)
- Joonas Kylmälä (87)
- Rasmus Leißner (5)
- Owen Leonard (125)
- Ava Li (7)
- Ere Maijala (1)
- Marjorie (2)
- Julian Maurice (37)
- Kelly McElligott (20)
- Matthias Meusburger (1)
- Telishia Mickens (1)
- Kathleen Milne (33)
- Josef Moravec (21)
- Pascale Nalon (1)
- David Nind (206)
- Andrew Nugged (6)
- Björn Nylén (1)
- James O'Keeffe (1)
- Hayley Pelham (3)
- Séverine Queune (27)
- Liz Rea (1)
- Martin Renvoize (525)
- Phil Ringnalda (8)
- Marcel de Rooy (82)
- Caroline Cyr La Rose (1)
- Andreas Roussos (1)
- Sally (28)
- Lisette Scheer (11)
- Fridolin Somers (29)
- Alexandra Speer (3)
- Christian Stelzenmüller (6)
- Deb Stephenson (1)
- Lyon 3 Team (1)
- Mark Tompsett (1)
- Petro Vashchuk (19)
- Timothy Alexis Vass (1)
- Wainui Witika-Park (4)
- Amandine Zocca (2)

We thank the following individuals who mentored new contributors to the Koha project

- Andrew Nugged

And people who contributed to the Koha manual during the release cycle of Koha 21.05.00

- Victoria (1)
- vfaafia29 (4)
- Eden Bacani (9)
- Chris Cormack (11)
- Caroline Cyr La Rose (89)
- Katrin Fischer (4)
- Amy King (6)
- Ava Li (5)
- Martin Renvoize (3)
- Lucy Vaux-Harvey (46)
- Ella Wipatene (19)


We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-devel@lists.koha-community.org.

## Notes from the Release Manager

Thanks to those who are working everyday to make Koha better day after day.

I would like to thank especially the whole development team and all those who contributed to the different topics from the roadmap we defined at the beginning of the release cycle.

I am excited to continue as release manager for one more development cycle. We, as a community, are comforting our capacity to work together and are continuously becoming more efficient. A lot of stimulating and interesting challenges are waiting for us.

[Join us](https://wiki.koha-community.org/wiki/Getting_involved) if it's done yet!

Enjoy this new version of Koha!

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is master.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 28 May 2021 09:08:25.
