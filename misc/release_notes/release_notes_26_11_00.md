# RELEASE NOTES FOR KOHA 26.11.00
26 Nov 2026

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 26.11.00 can be downloaded from:

- [Download](https://download.koha-community.org/koha-26.11-latest.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 26.11.00 is a major release, that comes with many new features.

It includes 10 new features, 223 enhancements, 417 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).

## New features & Enhancements

### About

#### Enhancements

- [41522](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41522) Make system preferences clickable for warnings in About Koha > System information
  >This enhancement makes the system preferences shown in warnings and errors on the About Koha > System information page clickable.
  >
  >Note: Links are only shown for patrons with permission to manage system preferences.

  **Sponsored by** *Catalyst*

### Accessibility

#### Enhancements

- [39890](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39890) Accessibility: Add more Bypass blocks to the OPAC.
  >The OPAC has more skip links for keyboard and screen reader users: "Skip to menu", "Skip to the search" and "Skip to footer". Each one appears on the pages where the matching menu, search box or footer is shown.

### Acquisitions

#### Enhancements

- [12278](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12278) Total amount of each invoice should be displayed in invoices page (parcels.pl)
  >The Receive shipments page (acqui/parcels.pl) has a **Total** column showing the total of each shipment. The total includes tax if the vendor is set to invoice with tax included, otherwise it excludes tax. Adjustments and shipping costs are added to the total.

  **Sponsored by** *Anne Arundel County Public Library*
- [30144](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30144) Add support for EDI GIR:LVT and/or GIR:LVC, Servicing instructions, segment
  >EDIFACT servicing instructions (GIR LVC and LVT segments) are now supported on order lines. Servicing instructions received in an EDIFACT quote are stored on the order line, and they are sent in the GIR segments of EDIFACT orders. Coded instructions (LVC) are chosen from the `EDIFACT_SI` authorised values, which contain the EDItEUR List 3B servicing codes. Free-text instructions (LVT) can also be entered. Each servicing instruction group can hold one coded instruction, one free-text instruction, or one of each.
  >
  >The Add order form has a "Servicing instructions" field, and the basket shows the instructions in a column that can be shown from the Columns menu.
  >
  >**To enable**
  >1. Enable `EDIFACT` in Administration > System preferences.
  >2. Add an EDI account for the vendor. The servicing instructions field is shown only when both are in place.
  >
  >**Upgrade notes**
  >- The database update adds the `servicing_instruction` column to orders and creates the `EDIFACT_SI` authorised value category.

  **Sponsored by** *Martin Renvoize*
- [34166](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34166) Show total price in table of suggestions
  >The purchase suggestions table (Acquisitions > Suggestions) has a **Total** column showing each suggestion's total price, after currency conversion. As with other totals, the value is shown without a currency symbol. The column can be shown or hidden from the Columns menu, and its visibility can be set in the table settings.

  **Sponsored by** *OpenFifth*
- [39959](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39959) Add total amount column to invoice search results
  >The invoice search results (Acquisitions > Invoices) now have a Total column showing the total amount of each invoice.
- [40186](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40186) Show additional fields in search form on acquisition start page
  >The search form on the acquisitions home page now includes the additional fields for order baskets (Administration > Additional fields > Order baskets), so orders can be searched by those values from the home page as well as from the advanced search.

  **Sponsored by** *Athens County Public Libraries*
- [41029](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41029) Add option for MARC overlay rules to apply when adding to a basket
  >Record overlay rules can now be set for records added to a basket from a file. Administration > Record overlay rules has a new source, "Add to basket", which applies when orders are added from a file in Acquisitions.
  >
  >**Upgrade notes**
  >- Existing "Staged MARC import" overlay rules are copied to the new "Add to basket" source, so basket behaviour is unchanged. The two sets of rules can then be edited separately.
- [41297](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41297) Add duplicate invoice number detection on EDI invoice import
  >When EDIFACT invoices are imported, Koha can now detect an invoice number that has already been received from the same vendor. Detection can block the duplicate so that it is not processed, and can email library staff and vendor EDI contacts about it.
  >
  >**New system preferences**
  >- `EdifactInvoiceImportBlockDuplicates` (default: 0, "Don't block") - when set to Block, an invoice whose number already exists for the same vendor is not processed, and the duplicate is recorded as an EDI error for the message.
  >- `EdifactInvoiceImportBlockDuplicatesEmailNotice` (default: 0, "Do not send") - when blocking is enabled, emails the EDI_DUP_INV_LIBRARY notice to AcquisitionsDefaultEmailAddress, KohaAdminEmailAddress or the addresses in the next preference. Vendor EDI contacts flagged "Contact about EDI errors" receive the EDI_DUP_INV_VENDOR notice whenever this is not set to "Do not send".
  >- `EdifactInvoiceImportBlockDuplicatesEmailAddresses` (default: empty) - comma-separated staff email addresses, used when the notice preference is set to specific email addresses.
  >
  >**To enable**
  >1. Set `EdifactInvoiceImportBlockDuplicates` to Block in Administration > System preferences.
  >2. Optionally set `EdifactInvoiceImportBlockDuplicatesEmailNotice`, and tick "Contact about EDI errors" on the vendor contacts who should be emailed.
  >
  >**Upgrade notes**
  >- Blocking is off after upgrade, so nothing changes until the preference is set.
  >- The upgrade adds the "Contact about EDI errors" flag to vendor contacts, an index on `aqinvoices` (invoicenumber, booksellerid), and the two notice templates EDI_DUP_INV_LIBRARY and EDI_DUP_INV_VENDOR (Tools > Notices and slips).

  **Sponsored by** *Royal Borough of Kensington and Chelsea* and *Westminster City Council*
- [41996](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41996) Further improvements to EDIFACT error recording
  >EDIFACT invoice import errors are now recorded against the invoice they relate to, so the Invoice page shows only the errors for that invoice. Errors that apply to the whole file, such as an unknown vendor EAN, are still shown on every invoice from that file.
  >
  >Branch mismatch errors now include the order number from the invoice and the branches where that order has items, and a warning is recorded when an invoice refers to an order that is already complete.
  >
  >**Upgrade notes**
  >- Adds an `invoicenumber` column and index to `edifact_errors`. Errors recorded before the upgrade have no invoice number, so they continue to show on every invoice from their file.
- [42001](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42001) Update duplicate purchase order number detection on EDI quote import to optionally send notifications to staff and vendors
  >When an EDI order is blocked because its basket name (used as the purchase order number for the vendor) duplicates a basket already held for the same vendor, Koha can now email library staff and vendor EDI contacts. The duplicate check that blocks the order is unchanged.
  >
  >**New system preferences**
  >- `EdifactOrderSendBlockDuplicatesEmailNotice` (default: 0, "Do not send") - chooses who is emailed: AcquisitionsDefaultEmailAddress, KohaAdminEmailAddress or the addresses in the next preference. Vendor EDI contacts flagged "Contact about EDI errors" receive the EDI_DUP_ORD_VENDOR notice whenever this is not set to "Do not send".
  >- `EdifactOrderSendBlockDuplicatesEmailAddresses` (default: empty) - comma-separated staff email addresses, used when the notice preference is set to specific email addresses.
  >
  >**To enable**
  >1. Set `EdifactOrderSendBlockDuplicatesEmailNotice` in Administration > System preferences.
  >2. Tick "Contact about EDI errors" on the vendor contacts who should be emailed.
  >
  >**Upgrade notes**
  >- Notifications are off after upgrade. The upgrade adds the notice templates EDI_DUP_ORD_LIBRARY and EDI_DUP_ORD_VENDOR.

  **Sponsored by** *Royal Borough of Kensington and Chelsea* and *Westminster City Council*
- [42080](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42080) Invoice PDFs are forced downloads
  >Invoice files attached in Acquisitions are no longer always downloaded. When you click a file name, PDF, PNG, JPEG, GIF and WebP files open in the browser. The file type is checked from the file contents, not the file name. All other files, including SVG, are downloaded as before, and the Download button always downloads the file. Inline views are served with a Content-Security-Policy that blocks scripts.
  >
  >**To enable**
  >1. Enable `AcqEnableFiles` in Administration > System preferences.
  >
  >**Upgrade notes**
  >- Viewing invoice files requires the File::LibMagic Perl module (Debian package `libfile-libmagic-perl`). See the note on the File::LibMagic dependency.
- [43644](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43644) Show the vendor name instead of ID in booksellers.pl breadcrumb
  >Updated the acquisitions breadcrumb to display the vendor's name instead of its ID, with improved formatting for readability.

### Architecture, internals, and plumbing

#### Enhancements

- [35142](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35142) Koha::Util::oclc_number should be removed in favor of Koha::Biblio::Metadata::Extractor
  >OCLC numbers are now read from field 035$a without regard to case (for example, "ocolc"), and any parenthesised organisation code before the number is removed, not only "(OCoLC)".
  >
  >Developers: C4::Koha::GetNormalizedOCLCNumber, Koha::Util::MARC::oclc_number and Koha::Util::MARC::strip_orgcode have been removed. Use $biblio->normalized_oclc, or Koha::Biblio::Metadata::Extractor for a record you already have.
- [38259](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38259) Adjust DT's lengthMenu option
  >Updates the "Show X entries" page length menu on several tables, including patron search results, the acquisitions parcel page, patron card batch editing and the ERM EBSCO package and title lists. The menu now uses the DataTables 2 `lengthMenu` format.
- [39726](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39726) Remove ConnectSuggestionAndBiblio from C4/Suggestions.pm
  >Developers: removes the unused `ConnectSuggestionAndBiblio` function from `C4::Suggestions` and the unused `connectDuplicate` operation from the acquisitions suggestion page. There is no change for staff.
- [39727](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39727) Remove DelSuggestionsOlderThan from C4/Suggestions.pm
  >The `purge_suggestions.pl` cronjob no longer uses the `DelSuggestionsOlderThan` function, which has been removed from `C4::Suggestions`. It deletes the same suggestions as before: those not marked ASKED, whose managed date is older than the number of days given.
- [39729](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39729) Add option -exact_days to filter_by_last_update
  >Developers: `Koha::Objects->filter_by_last_update` accepts a new `exact_days` option, which matches objects whose last update was exactly the given number of days ago.
- [40788](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40788) Add a custom event to Vue/Vue Islands when the Vue is loaded
  >Developers: Vue pages and Vue islands now fire browser events that IntranetUserJS and other scripts can listen for:
  >- `koha:vue-loaded` (`detail.module` gives the page name) fires once a Vue page is ready. It covers the ERM, Acquisitions, Preservation, SIP2, ILL, record sources and circulation triggers pages.
  >- `koha:island-loaded` (`detail.name` gives the island name) fires for each Vue island on a page.
  >- `koha:islands-ready` fires once all the islands on a page have finished loading, whether or not each one loaded successfully.
- [40901](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40901) koha-common.service bundles all sub-daemons under one systemd service instead of per-instance services
- [41061](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41061) No longer need to validate dates manually
  >Developers: removes the `is_valid_date`, `validate_date` and `get_dateformat_str` JavaScript functions from the staff and OPAC calendar code. Date fields are now validated by Maskito, so any local JavaScript that calls these functions must be updated.
- [41674](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41674) Add template plugin for linking to system preferences based on user permission
  >This patch adds a new template plugin, LinkPref, to be used by template authors. The plugin outputs system preference names as links depending on the logged-in user's permission. It also implements use of this new plugin in the Administration -> Libraries template.

  **Sponsored by** *Athens County Public Libraries*
- [41717](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41717) Update PDF::Reuse and PDF::Reuse::Barcode to the latest version
- [41728](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41728) Add `Koha::Item::Availability::Checkin` to centralize logic
  >This development refactors and modernizes the code responsible for checking if an item can be checked in. All the changes are covered by tests.
  >
  >The ultimate goal is to implement an API endpoint for a confirmation flow for checking items in.
  >
  >It proposes a pattern to follow on the needed rewrite of the circulation core functionality that will provide a coherent return value and behavior. Areas like checking out or the ability to place holds are the next targets for implementing this pattern.
- [41896](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41896) Remove C4::Context from Koha::Cache
  >Developer note: `Koha::Cache` no longer depends on `C4::Context`. The memcached namespace is now read from `Koha::Config`. No change for users.
- [42077](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42077) Move RabbitMQ from mandatory to optional and make SQL polling the default
  >New installations now use polling, rather than STOMP, to send background job notifications. RabbitMQ is no longer a hard dependency of the Debian packages: `rabbitmq-server` is only suggested. Background job workers are still required.
  >
  >**Changed system preferences**
  >- `JobsNotificationMethod` (default: polling, previously STOMP) - applies to new installations. STOMP is still available.
  >
  >**Upgrade notes**
  >- Existing sites keep their current `JobsNotificationMethod` setting.
  >- Sites that use STOMP with a local RabbitMQ broker should run `apt-mark manual rabbitmq-server`, so the broker is not removed as an unneeded automatic dependency. See the Debian NEWS for `koha-common` for details.
- [42094](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42094) Tidy all script tags (except value_builder)
  >Developers: the template test that checks script tags is now `xt/tt_script_tidy.t` (it replaces `xt/tt_kohaTable_tidy.t`) and covers all `.tt` and `.inc` files except `cataloguing/value_builder`. A script tag that uses Template Toolkit variables must have `data-tt-allowed="true"`, and a script tag without Template Toolkit variables must not have it. Module and importmap scripts that need an exception use `data-tt-allowed-exception="true"`.
- [42278](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42278) Tidy all script tags - circ
  >Internal change to the circulation staff pages: their JavaScript that uses Template Toolkit variables is moved into separate script blocks, as required by the script tag test in `xt/tt_script_tidy.t`. No change in behaviour is intended.
- [42279](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42279) Tidy all script tags - acqui
  >Internal change to the acquisitions staff pages: their JavaScript that uses Template Toolkit variables is moved into separate script blocks, as required by the script tag test in `xt/tt_script_tidy.t`. No change in behaviour is intended.
- [42280](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42280) Tidy all script tags - admin
  >Internal change to the administration staff pages: their JavaScript that uses Template Toolkit variables is moved into separate script blocks, as required by the script tag test in `xt/tt_script_tidy.t`. No change in behaviour is intended.
- [42281](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42281) Tidy all script tags - authorities
  >Internal change to the authorities staff pages: their JavaScript that uses Template Toolkit variables is moved into separate script blocks, as required by the script tag test in `xt/tt_script_tidy.t`. No change in behaviour is intended.
- [42282](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42282) Tidy all script tags - catalogue
  >Internal change to the catalogue staff pages: their JavaScript that uses Template Toolkit variables is moved into separate script blocks, as required by the script tag test in `xt/tt_script_tidy.t`. No change in behaviour is intended.
- [42283](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42283) Tidy all script tags - cataloguing
  >Internal change to the cataloguing staff pages, including the catalogue concerns page: their JavaScript that uses Template Toolkit variables is moved into separate script blocks, as required by the script tag test in `xt/tt_script_tidy.t`. No change in behaviour is intended.
- [42284](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42284) Tidy all script tags - addbiblio/authorities
  >Internal change to the cataloguing record editor and the authority editing pages: their JavaScript that uses Template Toolkit variables is moved into separate script blocks, as required by the script tag test in `xt/tt_script_tidy.t`. The list of mandatory and important fields is now built in a different way. No change in behaviour is intended.
- [42286](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42286) Tidy all script tags - ill
  >Internal change to the interlibrary loans staff pages: their JavaScript that uses Template Toolkit variables is moved into separate script blocks, as required by the script tag test in `xt/tt_script_tidy.t`. No change in behaviour is intended.
- [42290](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42290) Tidy all script tags - suggestion
  >Internal change to the purchase suggestion staff pages: their JavaScript that uses Template Toolkit variables is moved into separate script blocks, as required by the script tag test in `xt/tt_script_tidy.t`. No change in behaviour is intended.
- [42291](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42291) Tidy all script tags - shelves
  >Internal change to the virtual shelves (lists) staff pages: their JavaScript that uses Template Toolkit variables is moved into separate script blocks, as required by the script tag test in `xt/tt_script_tidy.t`. No change in behaviour is intended.
- [42292](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42292) Tidy all script tags - opac
  >Internal change to the OPAC pages: their JavaScript that uses Template Toolkit variables is moved into separate script blocks, as required by the script tag test in `xt/tt_script_tidy.t`. No change in behaviour is intended.
- [42293](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42293) Tidy all script tags - serials
  >Internal change to the serials staff pages: their JavaScript that uses Template Toolkit variables is moved into separate script blocks, as required by the script tag test in `xt/tt_script_tidy.t`. No change in behaviour is intended.
- [42294](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42294) Tidy all script tags - patron searches
  >Internal change to the patron search tables used across the staff interface: their JavaScript that uses Template Toolkit variables is moved into separate script blocks, as required by the script tag test in `xt/tt_script_tidy.t`. The "Show entries" menu now falls back to the standard values (10, 20, 50, 100, All) when `PatronsPerPage` is not a number, and no longer lists a value twice.
- [42295](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42295) Tidy all script tags - includes staff
  >Internal change to the shared staff interface includes: their JavaScript that uses Template Toolkit variables is moved into separate script blocks, as required by the script tag test in `xt/tt_script_tidy.t`. No change in behaviour is intended.
- [42296](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42296) Tidy all script tags - trivial ones
  >Developer change only. Template script blocks have been tidied, and only blocks that interpolate Template Toolkit variables carry `data-tt-allowed="true"`. There is no change for users.
- [42310](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42310) Move calendar CRUD to Koha::Calendar::* with normalized schema
  >Library closures and holidays are now stored in four purpose-specific tables: weekly closures, repeating closures (for example 25 December), single closures, and closure exceptions (days a library is open despite a closure rule). The `repeatable_holidays` and `special_holidays` tables are removed.
  >
  >Developers: the calendar code now lives in `Koha::Library::Calendar` and its `Koha::Library::Calendar::*` classes. `Koha::Calendar` no longer exists. `Koha::Library::Calendar->closed_dates_in_range` returns every closed date in a range.
  >
  >**Upgrade notes**
  >- The database update migrates existing closures into the new tables and then drops the old tables.
  >- The new tables allow one weekly closure per weekday, one repeating closure per day and month, and one single closure or exception per date. Legacy rows that break these rules are skipped, and the update prints a warning with the number skipped. Titles and descriptions of skipped rows can be recovered from your pre-upgrade backup.
- [42314](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42314) Add `Koha::Library->calendar`
  >Developers: `Koha::Library` has a new `calendar` method, which returns a `Koha::Library::Calendar` object for the library. The closed dates API and the rental charge calculation now use it.
- [42385](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42385) Extract _GetCircControlBranch into Koha::Policy::Circulation
  >Developers: the logic that decides which library's circulation rules apply (based on `CircControl` and `HomeOrHoldingBranch`) moves to `Koha::Policy::Circulation->circ_control_library($item, $patron)`. It takes an optional `pickup_library_id`, for API and background contexts. `_GetCircControlBranch` is removed from `C4::Circulation`.
- [42391](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42391) Use DBIx::Class `exception_action` to translate exceptions at the source
  >Developers: database errors are now translated into Koha exceptions where they are raised, by a DBIx::Class `exception_action` hook on `Koha::Schema`, instead of try/catch blocks in each caller. The mapping lives in `Koha::Schema::ExceptionMapper`, which replaces `Koha::Schema::Util::ExceptionTranslator`. Unmatched database errors are thrown as `Koha::Exceptions::Object::UnhandledDBError`. `Koha::Schema->translate_exception` is removed.
- [42396](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42396) Replace C4::Stats::UpdateStats calls with Koha::Statistic->store

  **Sponsored by** *OpenFifth*
- [42425](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42425) Add checkin_id FK to accountlines to link fee adjustments to checkin events
  >Fines, fees and credits created during a check-in are now linked to that check-in, so they can be traced back to it. The account line API now includes this link, as `checkin_id`.
  >
  >**Upgrade notes**
  >- Existing account lines are not linked to check-ins. Only lines created after the upgrade are linked.
- [42529](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42529) Move GetAgeRestriction to Koha namespace
  >Developers: the age restriction check moves out of `C4::Circulation` into `Koha::Policy::Biblio::AgeRestriction->check($biblio, $patron)`. `Koha::Biblio->age_restriction` returns the numeric age from the `AgeRestrictionMarker` value, or undef. `GetAgeRestriction` is removed from `C4::Circulation`.
- [42553](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42553) preferences.pl: Allow 'multiple_sortable' to use 'authval' source for dynamic choices
  >Developers: `.pref` definitions can now use `multiple_sortable: authval` with a `source` authorised value category. The choices of the ordered multi-select are then populated from that category at render time, as `choices: authval` already did for single-value choices. No existing preference changes.

  **Sponsored by** *OpenFifth*
- [42566](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42566) Remove C4::Koha::GetNormalizedUPC in favor of MetadataExtractor
  >Developers: `C4::Koha::GetNormalizedUPC` is removed. Use `$biblio->normalized_upc`, which is provided by the MARC metadata extractor.
- [42567](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42567) Remove C4::Koha::GetNormalizedEAN in favor of MetadataExtractor
  >Developers: `C4::Koha::GetNormalizedEAN` is removed. Use `$biblio->normalized_ean`, which reads field 024$a with first indicator 3 for MARC21 and field 073$a for UNIMARC.
- [42882](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42882) Add option to disable setting time and permissions for File Transports
- [42949](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42949) Add configurable complexity score header for WAF rate limiting
  >Adds an optional complexity score response header that enables per-endpoint rate limiting in things like Cloudflare WAF Rate Limiting Rules. Heavy endpoints (search results, AJAX) get higher scores so they consume more of a client's rate limit budget.
  >
  >The feature is disabled by default. To enable it, add this to the <config> section of koha-conf.xml and restart Plack:
  >```xml
  >  <complexity_score_header>1</complexity_score_header>
  >```
  >Then each OPAC path can be configured by adding something like:
  >```xml
  >  <complexity_score_weights>
  >    <opac-search.pl>30</opac-search.pl>
  >  </complexity_score_weights>
  >```
- [43077](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43077) Add encode_claims/decode_claims to Koha::Token
  >Developers: `Koha::Token` gains `encode_claims` and `decode_claims`, which sign and verify a JWT carrying any hashref of claims, including nested hashes and arrays. `generate_jwt`, `check_jwt` and `decode_jwt` now wrap these methods.
  >
  >**Upgrade notes**
  >- `decode_jwt` now returns undef and logs a warning for an invalid or expired token, instead of dying. Callers that relied on the exception must check the return value.
  >- JWTs are always signed with the Koha secret. A secret passed by the caller is ignored.
- [43202](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43202) Improve discoverability of ERM system preferences
  >This enhancement updates the system preference descriptions for ERMModule and ERMProviders - now searching for "electronic" gives you results when searching system preferences.
- [43307](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43307) Migrate cataloguing/moveitem.tt to use api-client.js
  >Deleting a biblio record from Cataloguing > Move items now uses the REST API client rather than a direct jQuery AJAX call. The biblio API client gains a `delete` method. Staff see no change.
- [43463](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43463) Add SIP2 port  to system information page
  >This enhancement adds SIP2 listener port information to the System Information tab of the About Koha page. This information was previously only visible in the SIPconfig.xml file on the Koha server but is needed by third-parties when setting up new SIP2 services. Adding it to the System Information tab makes it easily accessible to users.
- [43516](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43516) Harden the frontend HttpClient and add a shared API error formatter
  >The shared frontend HTTP client is more robust for developers writing staff interface JavaScript. A malformed response, such as a proxy error page or a session-expired redirect, is now reported as an error rather than as a JSON parse failure. Errors keep the HTTP status and Koha error code. Requests accept an `AbortSignal` to cancel them, and callers that show their own error message can suppress the default error dialog. A new `formatApiError()` helper, in `js/fetch/api-error.js`, gives translated messages for an expired session, a forbidden request and a network failure.

  **Sponsored by** *Büchereizentrale Schleswig-Holstein*
- [43525](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43525) Batch patron deletion and anonymization should be a background job
  >Enhancement moves the batch deletion of patrons into a background job.
- [43777](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43777) Koha::Biblio::Metadata->record should repair recoverable MARCXML faults on read

  **Sponsored by** *OpenFifth*

### Authentication

#### Enhancements

- [43785](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43785) 2FA code fields should use autocomplete="one-time-code" so password managers can fill the TOTP code
  >The staff two-factor authentication code field and the two-factor setup PIN field are marked so that password managers, such as Apple Passwords, 1Password and Bitwarden, offer the current code from a stored TOTP secret. On mobile devices a numeric keypad is shown. Browsers still do not keep these codes in form history.

### Cataloging

#### Enhancements

- [22439](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22439) Duplicated code in PrepHostMarcField and prepare_host_field
  >Linking an analytical (child) record to its host record now uses one code path. The "Create analytics" and "New child record" options, and linkitem.pl, all generate the host link field (773 for MARC21, 461 for UNIMARC) with Koha::Biblio->generate_marc_host_field.
  >
  >When `EasyAnalyticalRecords` is enabled, the link also includes the host item's barcode ($o), item number ($9) and biblionumber ($0). If the host record cannot be found from the control number ($w, when `UseControlNumber` is enabled), the link now falls back to these subfields.
  >
  >Developers: C4::Biblio::PrepHostMarcField has been removed. Use Koha::Biblio->generate_marc_host_field( { item => $item } ) instead.

  **Sponsored by** *Martin Renvoize*
- [24535](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24535) Add the ability to have longer barcodes than 20 digits
- [35104](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35104) We should warn when attempting to save MARC records that contain characters invalid in XML

  **Sponsored by** *OpenFifth*
- [35729](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35729) Koha needs to handle ISBNs starting with 979 for cover images

  **Sponsored by** *Horowhenua Libraries Trust*
- [41253](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41253) Item Modification by Age should have its own permission
  >This patch adds a new permission to control the Item Modification by Age tool. Previously access to both the Batch Item Modification Tool and the Item Modification by Age tool were controlled by the items_batchmod permission. The new permission is items_modification_by_age and it can be found in the tools permission group. At upgrade the new items_modification_by_age permission will be given to all users who previously had the items_batchmod permission.
- [42625](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42625) Allow records to be locked for editing based on library & group
  >This enhancement allows locked records to be edited by users from a given library group.
  >When creating or editing library groups, one can now set the option "Use for record source editing".
  >When creating record sources, one can define one or more library groups to be allowed to edit records with this source. Only groups with the "Use for record source editing" option set will be accessible for this purpose.
  >When a record has a source set and that source is editable by one or more library groups, the record will only be editable by superlibrarians, users with edit_locked_records permission, and users with edit_catalogue permission whose home library is in one of those groups.

  **Sponsored by** *Cape Libraries Automated Materials Sharing*
- [43025](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43025) Show metadata repair warnings in the cataloguing edit form
  >The cataloguing editor now shows the metadata problems found in a record, with details of each one.
  >
  >- **Saving:** if a record can be repaired, it is saved and a warning lists each automatic repair, with a link to the affected field. If it cannot be repaired, it is not saved, and the form is shown again with the error.
  >- **Opening:** problems already recorded for a record are listed under "Data quality warnings" when the record is opened for editing. Each one links to the affected field, where the field still exists, and has a "Mark resolved" button.
  >
  >Marking an error resolved uses `DELETE /api/v1/biblios/{biblio_id}/metadata/errors/{error_id}`, which requires the `editcatalogue > edit_catalogue` permission.

  **Sponsored by** *OpenFifth*
- [43026](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43026) Show metadata repair warnings on the biblio detail and MARC detail pages
  >The biblio detail and MARC detail pages now show a "Data quality warnings" banner listing any metadata problems recorded for the record, including faults repaired when it was last saved. Records whose metadata cannot be repaired still show the decoding error.

  **Sponsored by** *OpenFifth*
- [43027](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43027) Handle undecodable metadata gracefully when merging bibliographic records
  >Merging records with corrupt metadata is handled more clearly. If a record cannot be read, the merge stops before any change is made and an error names the record, instead of showing a raw exception. Faults repaired during the merge are shown as a warning.

  **Sponsored by** *OpenFifth*
- [43797](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43797) Adding item number to holdings table
  >The holdings table on the catalogue record details page has an Item number column. It is hidden by default; to show it, use the gear icon and select Columns > Item number.
- [44010](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=44010) Improve enforcement of record locking
  >This enhancement extends and refines the locking of bibliographic records. Locked biblio records can no longer be edited via batch modification or record import and overlay. New items can be created on locked biblios via either batch record modification or record import and overlay.
  >
  >When a user with records_batchmod permission but without edit_locked_records permission performs a batch modification on a group of records containing one or more locked records, the locked records that were not modified are noted in the background job details.

  **Sponsored by** *Cape Libraries Automated Materials Sharing*
- [44011](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=44011) Add ability to change record source via MARC mod template
  >This enhancement allows record source to be edited via batch record modification and during record import as part of a MARC modification template. Users with marc_modification_templates and set_record_sources permissions are able to create MARC modification templates that change the record source of a record. Changes to record source may be combined with changes to MARC data or may be saved in a template that does not change MARC data. Users with records_batchmod and set_record_sources permissions may use MARC modification templates containing record source changes when performing record batch modifications.
  >With this enhancement, modification, creation, and deletion of MARC modification templates will now be logged if the new MarcModificationTemplatesLog system preference is enabled. This logging does not include the changes to the actions related to a MARC modification template.

  **Sponsored by** *Cape Libraries Automated Materials Sharing*
- [44012](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=44012) Add ability to apply MARC mod template via Connexion import
  >This enhancement allows the Connexion daemon to be configured to apply a MARC modification template when importing records.

  **Sponsored by** *Cape Libraries Automated Materials Sharing*

### Circulation

#### New features

- [31391](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31391) Staff-side recalls
  >This enhancement adds the ability to place recalls via the staff interface by changing the UseRecalls system preference from a Yes/No setting to one that configures where recalls can be placed: through the OPAC only, the staff interface only, or both. Existing sites that had recalls enabled keep the OPAC-only behaviour.
  >
  >This enhancement also adds the ability to convert existing holds to recalls easily via the staff interface. The hold will be cancelled and a recall placed using the hold's information.

  **Sponsored by** *Auckland University of Technology*

#### Enhancements

- [40492](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40492) Improvements to the pending offline circulation actions table
  >Two enhancements to the pending offline circulation actions page (Circulation > Offline circulation > Pending offline circulation actions):
  >- The barcode now links directly to the item on the item details page, instead of the bibliographic record, and opens in a new tab.
  >- There is a new last seen date column, with a warning if the item's last seen date is more recent than the offline circulation action date (for example, the item was checked in).
- [41129](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41129) Migrate place_booking.js to a Vue island.
  >The staff interface booking modal, opened from the catalogue record, circulation and patron pages, is now a Vue component. Staff choose the patron, pickup location, item type and item, then the booking period on a calendar. The calendar shows existing bookings, checkouts, holidays, lead and trail periods and booking limits, and dates that the rules do not allow cannot be selected. Existing bookings can be edited from the bookings table and the timeline using the same form.
  >
  >**Upgrade notes**
  >- The old booking modal template (`place_booking.inc`) and its JavaScript (`place_booking.js`) have been removed. Local customisations that include them must be updated.

  **Sponsored by** *Büchereizentrale Schleswig-Holstein*
- [41514](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41514) The API should fully respect lead and trail periods for bookings
  >This enhancement adds full validation of lead and trail period configuration to the bookings APIs to ensure third party consumers follow Koha settings when placing bookings.
- [42383](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42383) Migrate check-in page to Vue
  >The staff check-in page is rebuilt in Vue and replaces the legacy `circ/returns.pl`. It reproduces the behaviour of the old page: check-in messages, hold, transfer and recall confirmations, return claims, bundle verification and slip printing. It opens from the circulation home page, the circulation sidebar and Alt+r, and the header check-in search box now checks items in on this page.
  >
  >Developers: the check-in API gains follow-up action endpoints for hold, transfer and recall confirmations. They are marked EXPERIMENTAL and may still change.
  >
  >**Changed system preferences**
  >- `AutomaticConfirmTransfer` - the description now says which transfers it applies to and what confirming does. The setting and its default are unchanged.
  >
  >**Upgrade notes**
  >- `circ/returns.pl` has been removed. There is no redirect, so bookmarks and links to it need to use `circ/checkin.pl` instead. A `?barcode=` parameter on `circ/checkin.pl` prefills the barcode field without checking the item in.
- [42418](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42418) Add Koha::Checkin(s) - checkin as a first-class resource
  >Adds a checkins table recording each checkin with who, where, and any related
  >events (holds, recalls, etc.). Plugins get it in the after_circ_action payload
  >as checkin.
  >
  >The upgrade backfills past returns from 24.11 onwards (bug 33641) whose library
  >and item still exist, with no staff member, and reports how many were skipped.
- [42443](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42443) Update transferstoreceive.pl to use the API to fetch transfer information
  >Circulation > Transfers to receive now loads its list through the REST API, as a table that can be filtered by sending library and home library. The table shows who the item is on hold for (a hold or a recall), and a days-late badge according to `TransfersMaxDaysWarning`. Staff can cancel a transfer from the table. If the transfer has already been received or cancelled, its row is removed.
  >
  >Developers: new endpoints `GET /transfers` and `POST /transfers/{transfer_id}/cancellation`, which need the `circulate > circulate_remaining_permissions` permission. Cancelling reverts an in-transit recall for the item, as returns does. `cancellation_reason` is optional and defaults to `Manual`. The cancellation endpoint returns 409 when the transfer has already arrived or been cancelled.
- [42790](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42790) Clarify and unify bookings actions to 'Edit, Cancel, Checkout, Extend' shown appropriate per status and permission
  >The bookings tables on the patron's Bookings tab and on the biblio bookings page now show the same actions for each booking, based on the booking's status and the logged-in user's permissions:
  >
  >- **New bookings:** Edit and Cancel (`circulate > manage_bookings`), and Checkout (the `circulate` permission). Checkout opens the checkout screen for the patron, with the item and the booking end date as the due date. It is now also offered from the patron's Bookings tab.
  >- **Issued bookings:** the Item column shows the checkout due date and a link to the checkout. Extend is shown to users with the `circulate` permission.
  >- **Completed and cancelled bookings:** no actions.
  >
  >New bookings whose collection window has opened are highlighted, and those whose window has passed without collection are highlighted as a warning.
  >
  >**Extend** changes the due date of an issued booking's checkout. The modal shows the current booking end date and checkout due date, and offers only dates after the checkout due date. Dates that clash with another booking for the same item cannot be selected. The extension is recorded as a renewal of the checkout, and the booking end date is updated to match the new due date. The booking modals on the circulation page are loaded only when `EnableBooking` is enabled.
  >
  >The biblio bookings endpoint now accepts the `item.checkout` embed.

  **Sponsored by** *OpenFifth* and *Westminster City Council*
- [42997](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42997) Keep booking end dates in sync with checkout due dates at issue and renewal
  >The end date of a booking now follows the loan of the booked item.
  >
  >- **Checkout:** if staff set a due date when checking out a booked item, the booking end date is changed to match. An on-site checkout of a booked item is no longer extended to the booking end date; the booking end date is shortened to the actual due date instead. An explicit due date is honoured only when `SpecifyDueDate` is enabled.
  >- **Renewal:** when a checkout linked to a booking is renewed, the booking end date is changed to match the new due date.
  >- **Clashes:** if a new due date would run into the next booking for the same item, the booking keeps its original end date. At checkout, staff are shown a confirmation saying so before the checkout can proceed.
  >- **Renewals refused:** a renewal of a booked item is refused with the reason `booked` if the new due date would run into the next booking for the item. The patron's own booking no longer hides the next booking from this check.
  >
  >**Upgrade notes**
  >- The booking end date is updated when an item is checked out or renewed after the upgrade. The upgrade has no database update, so existing bookings are not changed until their item is next checked out or renewed.
  >- Renewals that run into the next booking for the item were allowed before and are now refused.

  **Sponsored by** *OpenFifth* and *Westminster City Council*
- [43108](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43108) Add a REST API endpoint for a biblio's booking availability over a date range
  >Adds `GET /api/v1/biblios/{biblio_id}/booking_availability` for developers and integrators. For a date range of up to 366 days, it returns for each date and each bookable item of the record whether a new booking can be placed. Each result lists blockers (existing booking, checkout, lead period and trail period) and advisory warnings (closed days and lead-period notes). It takes `from_date`, `to_date` and `pickup_library_id`, and optionally `item_id` and `excluded_booking_id`. It requires the `circulate > manage_bookings` permission.

  **Sponsored by** *Büchereizentrale Schleswig-Holstein*
- [43500](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43500) Extract mark_returned and lift_overdue_restrictions from MarkIssueReturned
  >Developers: archiving a checkout on return is now `Koha::Checkout->mark_returned`, and lifting overdue restrictions is `Koha::Patron->lift_overdue_restrictions`. `MarkIssueReturned` uses both. The checkin library is passed in explicitly, so callers such as cronjobs can record the correct library or none. Behaviour for existing users is unchanged.

  **Sponsored by** *Black Hills Library Consortium- http://www.rcgov.org/Library/*
- [43504](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43504) Extract Koha::Account->forgive_debit from _FixOverduesOnReturn
  >Developers: forgiving overdue charges on return is now `Koha::Account->forgive_debit`, which no longer depends on the logged-in user's environment. Behaviour for staff is unchanged.

  **Sponsored by** *Black Hills Library Consortium- http://www.rcgov.org/Library/*
- [43508](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43508) Extract Koha::Account->add_lost_replacement_fee from chargelostitem
  >Developers: charging the replacement and processing fees for a lost item is now `Koha::Account->add_lost_replacement_fee`, taken out of the `chargelostitem` routine in `C4::Accounts`. It keeps the deduplication, default replacement cost and processing fee rule handling. Lost item charging behaves as before.

  **Sponsored by** *Black Hills Library Consortium- http://www.rcgov.org/Library/*

### Command-line Utilities

#### Enhancements

- [28740](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28740) Delete old ILL requests with cleanup_database
  >This enhancement adds options to the database clean up script (misc/cronjobs/cleanup_database.pl) for deleting ILL requests:
  >
  >The two new parameters for deleting ILL requests are:
  >--illrequests-status*
  >--illrequests-days (optional, defaults to 30 days)
  >
  >* The ILL status codes are defined in the backends, with additional aliases configured using the ILL_STATUS_ALIAS authorized value category. The Standard backend status codes are listed in the manual https://koha-community.org/manual/latest/en/html/ILL_requests.html#request-statuses

  **Sponsored by** *Koha-Suomi Oy*
- [40934](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40934) process_message_queue.pl add ability to exclude some letter code
  >The `process_message_queue.pl` cronjob has a new `--exclude-code` (`-x`) option, which processes all queued messages except those with the given letter code. The option can be repeated. It cannot be combined with `--code`.
  >
  >This makes it easier to send digests once a day and everything else every hour. For example, the hourly job can use `process_message_queue.pl --exclude-code DUEDGST --exclude-code PREDUEDGST --exclude-code HOLDDGST --exclude-code AUTO_RENEWALS_DGST`, and a daily job can run `process_message_queue.pl` with no options to send the digests.

  **Sponsored by** *OpenFifth*
- [42714](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42714) Koha::Script should automatically log start and end of scripts when they are run
  >Cron jobs that use `use Koha::Script -cron` now log their own start, with the command-line options, and their completion to the Cron jobs action log. The scripts no longer need to do this by hand, so every converted cron script is logged in the same way. Nothing is logged unless the `CronjobLog` system preference is enabled.
  >
  >Administrators filtering the action log for Cron jobs will see a start and an end entry for each run of these scripts.
- [42766](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42766) Add ScriptLog syspref and auto-logging for non-cron Koha scripts
  >This enhancement allows libraries to log when scripts are run (such as misc/devel/create_superlibrarian.pl) using the new ScriptLog system preference.
  >
  >In the log viewer, 'Scripts' is added as an option to the log viewer modules for filtering results, and any log entries show as the 'Scripts' module.
- [43546](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43546) Standardize command-line scripts on Getopt::Long::Descriptive for safer, more consistent option handling
  >Command-line scripts can declare their options, including required ones, through `Koha::Script->describe_options`. This gives every converted script a consistent `--help`, a `--man` manual page and a fail-fast error for a missing required option. `misc/cronjobs/cart_to_shelf.pl` is the first script converted.
  >
  >**Upgrade notes**
  >- Getopt::Long::Descriptive 0.109 or later is now required. On Debian and Ubuntu it is installed with the `libgetopt-long-descriptive-perl` package; otherwise install it from the cpanfile.
  >- `cart_to_shelf.pl` now rejects `--hours` values that are not positive integers, so a negative value no longer runs.
  >- Converted scripts exit with status 1 on command-line errors.
- [43548](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43548) Convert misc/cronjobs/runreport.pl to the Getopt::Long::Descriptive convention (see bug 43546)
  >The `misc/cronjobs/runreport.pl` script now uses the standard Koha command-line option handling. Its options work as before, and `--help` and `--man` show the usage and the full documentation. The script stops with an error, before any database access, if no report ID is given.
  >
  >`--to` and `--from` now imply `--email`, so the report is emailed.
- [43549](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43549) Convert misc/cronjobs/cleanup_database.pl to the Getopt::Long::Descriptive convention (see bug 43546)
  >`misc/cronjobs/cleanup_database.pl` uses the same option handling as the other converted cron scripts. `--help` lists every option with usage examples, `--man` prints the script's manual page, and invalid options exit with status 1.
- [43550](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43550) Convert misc/cronjobs/update_patrons_category.pl to Getopt::Long::Descriptive, with --from/--to as genuinely required options (see bug 43546)
  >The `misc/cronjobs/update_patrons_category.pl` script now requires both `--from` (`-f`) and `--to` (`-t`). Previously, a command line missing `--from` ran the date checks before failing. Now the script stops at once with a "Mandatory parameter" error and the usage text. Command lines that give both options work as before.
- [43551](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43551) Convert misc/cronjobs/process_message_queue.pl to the Getopt::Long::Descriptive convention (see bug 43546)
  >`misc/cronjobs/process_message_queue.pl` uses the same option handling as the other converted cron scripts. `--help` describes every option, and invalid options exit with status 1. Options and defaults are unchanged, and `--code` and `--exclude-code` remain mutually exclusive.
- [43552](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43552) Convert misc/cronjobs/gather_print_notices.pl to the Getopt::Long::Descriptive convention (see bug 43546)
  >The `gather_print_notices.pl` cronjob now parses its options with the shared `Koha::Script` option handling, and its help text is generated from the option definitions.
  >
  >**Configuration**
  >- `-h` no longer means help; use `--help`.
  >- Single-dash long options such as `-nosend` still work but print a deprecation warning. Use `--nosend` or `--no-send` instead.
  >
  >**Upgrade notes**
  >- Cron lines that use `-h` need to be changed to `--help`.
- [43553](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43553) Convert misc/cronjobs/holds/holds_reminder.pl to the Getopt::Long::Descriptive convention (see bug 43546)
  >The `holds_reminder.pl` cronjob now parses its options with the shared `Koha::Script` option handling, and its help text is generated from the option definitions.
  >
  >**Configuration**
  >- `--date` must now be a valid date in `YYYY-MM-DD` format; anything else is rejected with the usage text.
  >- The `--help` and `--man` options use double dashes. Multi-letter options are documented with double dashes (`--library`, `--days`, `--lettercode`, ...).
  >- Single-dash spellings of the long options, such as `-library` or `-lettercode`, are still accepted with a deprecation warning. Use the double-dash form.
- [43557](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43557) Add declarative mutually-exclusive option support to Koha::Script->describe_options
  >Scripts that use `Koha::Script->describe_options` can declare a group of mutually exclusive options with the `exclusive` key. If more than one option in the group is given, the script stops with an error and the usage text. Group members must be written with their first-declared option name, such as `exclude-code`; `describe_options` throws an error for any other form.
  >
  >Single-dash long options, such as `-days`, that were accepted by these scripts before still work, but a deprecation warning is printed to STDERR and the option is read as `--days`. This is a compatibility measure and will be removed in a future release, so cron lines should be changed to use `--days`.
- [43558](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43558) Convert misc/cronjobs/longoverdue.pl to the Getopt::Long::Descriptive convention (see bug 43546)
  >The `longoverdue.pl` cronjob now parses its options with the shared `Koha::Script` option handling. The `--category`/`--skip-category`, `--library`/`--skip-library` and `--itemtype`/`--skip-itemtype` pairs are each rejected when used together.
  >
  >**Configuration**
  >- `-h` and `--manual` are no longer accepted. Use `--help` and `--man`.
  >
  >**Upgrade notes**
  >- Cron lines that use `-h` or `--manual` need to be updated.
- [43559](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43559) Convert misc/cronjobs/membership_expiry.pl to the Getopt::Long::Descriptive convention (see bug 43546)
  >The `membership_expiry.pl` cronjob now parses its options with the shared `Koha::Script` option handling. `--active` and `--inactive` cannot be used together, and each must be given a positive number of months.
  >
  >**Configuration**
  >- `-c` (confirm) is still required. Without it the script prints its usage and does nothing.
  >- Single-dash option names such as `-branch` or `-letter_renew` are accepted with a deprecation warning. Use the double-dash form, for example `--letter_renew`.

### ERM

#### Enhancements

- [41294](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41294) Allow monthly harvesting only so Data not available for certain months do not result in a complete failure of the harvest
  >COUNTER usage harvesting has been improved to process each month separately. This prevents missing or not-yet-available usage data for one month from causing the entire harvesting process to fail. Available data for other months can now be harvested successfully. This change is a prerequisite for the improvements introduced in Bug 38822.

  **Sponsored by** *Karlsruhe Institute of Technology (KIT)*

### Fines and fees

#### Enhancements

- [43402](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43402) Offer button to print receipt when collecting account payments
  >When `FinePaymentAutoPopup` is set to "Do not show", taking a payment or writing off fees on a patron's account now shows an alert on the resulting page, offering to print or email the receipt for that transaction. The alert reads "Payment received" for a payment and "Fee written off" for a write off. Point of sale payments otherwise behave as before. The print and email receipt buttons on the Point of sale, pay and account pages now have ids, so they can be styled with IntranetUserCSS.

  **Sponsored by** *Martin Renvoize*

### Hold requests

#### New features

- [41410](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41410) Allow definition of a period after hold creation during which the hold is only filled locally
  >Libraries can now restrict which items may fill a hold for a set number of days after the hold is placed. During that period, a hold whose queue target is an item in the local library hold group can only be filled by an item from that group, so a returned item from elsewhere does not take it. After the period the hold can be filled by any item. This works independently of LocalHoldsPriority. Matches are recorded when the holds queue is built.
  >
  >**New system preferences**
  >- `LocalHoldsExclusivityPeriod` (default: 0, disabled) - the number of days after a hold is placed during which only local hold group items can fill it.
  >- `LocalHoldsExclusivityItemControl` (default: holding library) - whether the item's home library or holding library is compared with the library hold group. Options: home library, holding library.
  >- `LocalHoldsExclusivityPatronControl` (default: pickup library) - whether the hold's pickup library or the patron's home library is compared with the library hold group. Options: pickup library, home library.
  >
  >**To enable**
  >1. Set `LocalHoldsExclusivityPeriod` to a number of days in Administration > System preferences.
  >2. Make sure the libraries that should share local holds are in the same library hold group.

  **Sponsored by** *Main Library Alliance*

#### Enhancements

- [36868](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36868) Add ability to automatically empty cart after placing holds ( staff interface and OPAC )
  >This patchset adds the ability to automatically delete items from the cart/bookbag when a hold is place on that on item. The feature is controlled by a new system preference, AutoDeleteFromCartWhenHoldPlaced. The system preference allows one to enable this feature for the staff interface, OPAC, or both.
- [38638](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38638) Offer non-priority option when placing multiple holds
  >This adds the "Non priority hold" option when placing multiple holds in the staff interface (search the catalog, select several records, click "Place hold" from the toolbar). 
  >
  >Note: This option already exists when placing individual holds for a record.

  **Sponsored by** *Athens County Public Libraries*
- [42489](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42489) Allow RealTimeHoldsQueue to use --unallocated option
  >This development allows the RealTimeHoldsQueue to use the 'unallocated' option available in build_holds_queue.pl. This option prevents deletion of current queue and only deals with holds not currently in the queue.

  **Sponsored by** *The Main Library Alliance*
- [42490](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42490) Allow configuration of LocalHoldsPriority to apply only when capturing items for holds, not when building holds queue
  >This enhancement allows for a more narrow application of LocalHoldsPriority via the system preference LocalHoldsPriorityScope. Setting LocalHoldsPriorityScope to capture_and_queue maintains the current behavior. When LocalHoldsPriorityScope is set to capture_only, holds queue targets will be assigned without the influence of LocalHoldsPriority but LocalHoldsPriority will still be used when an item that is not already targeted by the queue is captured for a hold (this generally occurs when an item has been on loan or otherwise unavailable to the queue and is then checked in or otherwise updated to become available).

  **Sponsored by** *The Main Library Alliance*
- [42503](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42503) Render the holds queue using the REST API
  >Circulation > Holds queue now loads its results from the new `GET /api/v1/holds/queue` endpoint, as a paginated table instead of loading the whole queue at once. Sidebar filters redraw the table without reloading the page, and columns can be sorted. The item type column shows the translated item type description. The patron column follows the `HidePatronName` preference and the usual patron display rules.
  >
  >Item type, collection code and shelving location descriptions are stored with each queue item when the queue is built. The page and API need the existing `circulate > circulate_remaining_permissions` permission.
  >
  >**Upgrade notes**
  >- The page has moved from `circ/view_holdsqueue.pl` to `circ/holds_queue.pl`. Update any bookmarks or links to the old page. Saved column settings for the holds queue are migrated automatically.
- [43125](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43125) Rewrite FixPriority to use a single bulk UPDATE instead of per-hold updates

  **Sponsored by** *ByWater Solutions*

### I18N/L10N

#### Enhancements

- [40610](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40610) Update OPAC templates to improve ease of translation
  >Some OPAC strings are now translatable: the page title of a record without a title, the waiting and in-transit hold statuses, and the "Log in with [identity provider]" links. Translators will see these strings in their translation files.

  **Sponsored by** *Athens County Public Libraries*
- [41842](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41842) Improve translation of course reserves headings
  >Course reserves page titles, breadcrumbs and headings are reworded for clarity, and the course name and section are now separated by " - " (space, dash, space), as in the OPAC. The strings now carry context and placeholders for translators. Existing translations of the reworded strings will need updating.

  **Sponsored by** *Athens County Public Libraries*

### ILL

#### Enhancements

- [39944](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39944) Metadata should be trimmed before creating an ILL request
  >Leading and trailing spaces are removed from ILL request metadata when a request is created in the staff interface. For example, a DOI entered with a leading space is saved without it.

  **Sponsored by** *NHS England (National Health Service England)*
- [41111](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41111) AutoILLBackendPriority should consider a 'yellow' stage
  >When the AutoILLBackendPriority system preference is enabled, the availability check page uses a colour code to highlight backends: green for "can place the ILL request / available", red for "can't place the ILL request / unavailable". There is now another colour: yellow for "can place the ILL request but will go through manual verification".
  >
  >- Koha will always recommend a green backend over a yellow one, even if the yellow backend has a higher priority in AutoILLBackendPriority.
  >- The yellow backend is never automatically selected as the recommended one, but staff can choose to select it.
- [43084](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43084) OPAC ILL request form (Standard backend) should default library to patron's home library
  >When the ILL module is enabled and a logged-in patron places an ILL request through the OPAC with the Standard backend, the "Destination library" dropdown is preselected with the patron's home library.
- [43086](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43086) Prefill unauthenticated patron information for new ILL requests if available
  >This enhancement adds a "Remember me" checkbox to the unauthenticated ILL
  >request form for the OPAC. If it is checked upon submit, the details are remembered. 
  >
  >Rationale: If an unauthenticated patron makes multiple ILL requests back-to-back, they have to fill in their patron details every time. Remembering and prefilling these details will save time and improve the patron experience.

  **Sponsored by** *NHS England (National Health Service England)*
- [43139](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43139) ILL requests Widget should sort desc to display newest records
  >The ILL requests Widget now sorts descending to display newest records first.
- [43234](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43234) Move ILL request purging logic to Koha::ILL::Requests
  >The ILL request purge in the `misc/cronjobs/cleanup_database.pl` script (`--illrequests-days`, `--illrequests-status`) now uses the new `Koha::ILL::Requests->filter_by_purgeable` method, which can be reused by other code. The command-line behaviour is unchanged.

### Label/patron card printing

#### Enhancements

- [40478](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40478) Add option to justify barcode on labels
  >This enhancement adds a "Barcode justification" option to label layouts. This allows you to justify CODE39, COOP2of5, Industrial2of5 and EAN13 barcodes independently of any other content in the label layout.

### Lists

#### New features

- [30557](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30557) Add ability to create Item lists
  >This enhancement adds the ability to save list of items. These lists are only accessible in the staff interface. Items may be added to a list from the biblio detail page, item search results, or report results. Lists may be private, accessible to specific libraries, or accessible to specific library groups. Lists may also be shared with specific users. Interaction with item lists is enabled via new permissions: create_item_lists, edit_item_lists, delete_item_lists, and manage_item_list_contents. Logging of list creation, modification, and deletion may be enabled via a new system preference, ItemListsLog.

  **Sponsored by** *Cape Libraries Automated Materials Sharing*

#### Enhancements

- [40498](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40498) Improve style of list transfer form
  >The transfer form for public lists has a restyled patron search, matching the one on the circulation page. The "New owner" line now appears only after a patron has been selected.

  **Sponsored by** *Athens County Public Libraries*

### MARC Authority data support

#### Enhancements

- [41685](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41685) MARC21: Sort 4xx/5xx in BuildSummary alphabetic within hierarchy ($w: g or h)
  >This enhancement changes the order of "see also" terms (450 and 550) in the staff interface and OPAC authority search results:
  >- broader terms first ($w = g)
  >- other terms in the middle (w = no value)
  >- narrower terms last ($w = h)
  >- each grouping sorted alphabetically (on $a).
  >
  >They are currently shown in the order they are entered in the authority record.
- [41702](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41702) Update MARC21 authority frameworks to Update 41 (December 2025)
  >This enhancement updates the MARC21 default authority frameworks to include changes brought by Update 41 to the MARC21 format.
  >
  >**Note that this only affects new installations. If you wish to apply the changes from Update 41 to your own frameworks, you can do so in Administration > Authority types.**
  >
  >The changes included here are the following :
  > 
  >- Added subfield $4 - Relationship (R) to field 368
  >- Added subfield $i - Relationship information (R) to field 368 
  >- Added subfield $4 - Relationship (R) to field 376
  >- Added subfield $i - Relationship information (R) to field 376 
  >- Added subfield $4 - Relationship (R) to field 381
  >- Added subfield $i - Relationship information (R) to field 381
  >- Subfield $g renamed to Conversion date/time in field 884
- [41714](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41714) MARC21 authorities thesaurus link hardcoded
  >The authority linker can now follow the authority types set in the MARC bibliographic framework for MARC21, as UNIMARC already does. Previously MARC21 headings were always linked to hardcoded authority types (for example, field 650 always to TOPIC_TERM), so changes to thesaurus links in the framework were ignored.
  >
  >**New system preferences**
  >- `LinkerUseFrameworkAuthTypes` (default: Don't) - when set to Do, headings are linked using the authority types set in the framework's thesaurus links. Only tags Koha already treats as heading fields can be retargeted.
  >
  >**To enable**
  >1. Set `LinkerUseFrameworkAuthTypes` to Do in Administration > System preferences.
  >2. Check the thesaurus links for the fields you want in Administration > MARC bibliographic framework > Default.
  >
  >**Upgrade notes**
  >- Existing linking behaviour is unchanged until the preference is set to Do.

### MARC Bibliographic data support

#### Enhancements

- [36001](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36001) Show MARC field 362 for serials in OPAC and staff
  >The OPAC and staff detail views of a record now show the content of MARC 21 field 362 ($a, dates of publication and/or sequential designation) when the record has one. This is most useful for serials.
- [41697](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41697) Update MARC21 default framework to Update 41 (December 2025)
  >This enhancement updates the MARC21 default bibliographic framework to include changes brought by Update 41 to the MARC21 format.
  >
  >**Note that this only affects new installations. If you wish to apply the changes from Update 41 to your own frameworks, you can do so in Administration > MARC bibliographic framework.**
  >
  >The changes included here are the following :
  >
  >- New value r - Remote sensing image in 006/08 for Maps
  >- New value t - 4K Ultra HD Blu-ray in 007/04 for Videorecordings
  >- New value r - Remote sensing image in 008/25 for Maps
  >- Added subfield $6 - Linkage (NR) to field 060
  >- Added subfield $6 - Linkage (NR) to field 070
  >- Added subfield $z - Title statement context note (NR) to field 245
  >- Added subfield $i - Relationship information (R) to field 381
  >- Added subfield $4 - Relationship (R) to field 381
  >- Subfield $g renamed to Conversion date/time in field 884
- [43073](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43073) Update MARC21 default framework to Update 42 (May 2026)
  >This enhancement updates the MARC21 default bibliographic frameworks to include changes brought by Update 42 to the MARC21 format.
  >
  >The changes included here are the following :
  >
  >- Renamed subfield $a to "Language code of text or sound track" in field 041
  >- Added subfield $7 "Data provenance" to field 341
  >- Added subfield $h "Sensory hazards" to field 341
  >
  >**Note that this only affects new installations. If you wish to apply the changes from Update 42 to your own frameworks, you can do so in Administration > MARC bibliographic framework.**
  >
  >Changes to value builders are also included in this enhancement. These will be in all installations, not only new installations.
  >
  >Changes to field 006
  >- New value a - Activity report in 006/04 for Continuing resources
  >- New value i - Serial zine in 006/04 for Continuing resources
  >- New value q - Serial podcast in 006/04 for Continuing resources
  >- Added missing value g - Magazine in 006/04 for Continuing resources
  >- Added missing value h - Blog in 006/04 for Continuing resources
  >- Added missing value j - Journal in 006/04 for Continuing resources
  >- Added missing value r - Repository in 006/04 for Continuing resources
  >- Added missing value s - Newsletter in 006/04 for Continuing resources
  >- Added missing value t - Directory in 006/04 for Continuing resources
  >
  >Changes to field 008
  >- New value a - Activity report in 008/21 for Continuing resources
  >- New value i - Serial zine in 008/21 for Continuing resources
  >- New value q - Serial podcast in 008/21 for Continuing resources

### Notices

#### New features

- [10190](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10190) Overdue notice triggers based on item type
  >Overdue notice and status triggers have moved from Tools to a new **Circulation triggers** page at Administration > Circulation triggers. The page lists the triggers for each library, patron category and item type, and shows the rules in effect (including the fallback rules). Staff can add, edit and delete triggers, and reset the rules for a context. The triggers are now stored as circulation rules, so they are managed alongside the other circulation rules. The old Tools > Overdue notice/status triggers page has been removed.
  >
  >**Changed system preferences**
  >- `DefaultToLoggedInLibraryOverdueTriggers` (default: 0) - when enabled, the Circulation triggers page opens on the logged-in library's rules instead of all libraries.
  >
  >**New permissions**
  >- `parameters > manage_circ_triggers` - manage overdue notice triggers on the Circulation triggers page.
  >
  >**Upgrade notes**
  >- Existing overdue triggers are migrated to circulation rules during the database update, and the old overdue rule tables are then removed.
  >- The old `tools > edit_notice_status_triggers` permission has been removed. Staff who had it are given `parameters > manage_circ_triggers`.
  >- The `misc/cronjobs/thirdparty/TalkingTech_itiva_outbound.pl` script reads its triggers from circulation rules.

  **Sponsored by** *Glasgow Colleges Library Group*
- [33260](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33260) Show message queue on staff interface and make notices printable
  >Tools > Notices management lists the notices Koha has generated (the message queue), newest first, and lets staff filter them by type, status, patron category, library and queue date. Notices can be previewed, resent and printed, one at a time or several together. The patron's Notices tab offers the same actions for that patron. Notices that were sent, failed or deleted can be converted to a print notice, for example for a patron without a working email address. Pending email and SMS notices cannot be printed, so they are still sent.
  >
  >Staff only see notices of patrons they are allowed to see. The content of notices that carry a secret (password reset, registration verification and 2FA one-time token notices) is not shown or printed. These notices are still listed, with their status.
  >
  >**New system preferences**
  >- `NoticesManagement` (default: 0, disabled) - shows Tools > Notices management and enables the notice printing and conversion pages.
  >
  >**New permissions**
  >- `tools > view_generated_notices` - view, print, convert and resend generated notices. The patron's Notices tab needs this permission only, not the preference.
  >
  >**To enable**
  >1. Enable `NoticesManagement` in Administration > System preferences.
  >2. Grant the `view_generated_notices` permission to the relevant staff.
  >
  >**Upgrade notes**
  >- `message_queue.status` has two new values: `printed`, for notices that have been printed rather than sent, and `converted`, for notices converted to print.
  >- The `gather_print_notices.pl` cronjob now sets the print notices it gathers to `printed` instead of `sent`. Reports or scripts that rely on `sent` for print notices need updating.
  >- The database update adds the `CONVERTED_TO_PRINT` notice (Tools > Notices and slips, Patrons module), used to create the print notice. Libraries can edit it.
  >- `members/printnotice.pl` is replaced by `members/print_notice.pl`, which takes notice ids. Update any links to the old page.

  **Sponsored by** *Colorado Library Consortium*

#### Enhancements

- [15283](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15283) Switch default ISSUEQSLIP notice to Template Toolkit
  >The default Issue quick slip notice (`ISSUEQSLIP`) now uses Template Toolkit. It shows the library, the patron's name and card number, today's date and time, and the title, barcode and due date of the items the patron checked out today.
  >
  >**Upgrade notes**
  >- Only new installations get the Template Toolkit version. Existing sites keep their current `ISSUEQSLIP` notice. To use the new default, open the default template in Tools > Notices and slips, use "Copy to template" and save.
- [30657](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30657) Make patron attributes available via Template Toolkit in notices
  >Patron attributes can be used in notices. The values of a patron's extended attributes are available as `borrower.extended_attribute_values`, keyed by attribute type code, for example `[% borrower.extended_attribute_values.UNCLE %]`. Repeatable types give a list of values, which can be looped over with `FOREACH`.
- [43941](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43941) Add a method for fetching processing fee from circulation rules
  >Checkouts have a new `processing_fee` method that returns the processing fee from the Default lost item fee policy in Circulation and fine rules. Notice templates can print it, for example in the issue slip with `[% c.processing_fee %]` inside `borrower.checkouts`.
- [43948](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43948) Add method to get effective replacement cost for an item
  >Items have a new `effective_replacement_price` method for notice templates, for example `[% c.item.effective_replacement_price %]` inside `borrower.checkouts`. It returns the item's replacement price. If that is empty or 0 and `useDefaultReplacementCost` is enabled, it returns the default replacement cost of the item type. Otherwise it returns 0.

### OPAC

#### Enhancements

- [2172](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=2172) Cart attaches an iso2709 file, which can be confusing
  >This enhancement removes the basket.iso2709 attachment to emails when the cart is sent by email from the OPAC or the staff interface.
  >
  >This attachment caused confusion for patrons, as it is MARC format and not easily readable.
  >
  >If patrons require records in MARC format, they can download the cart in MARC format, from individual records, or download from lists.
  >
  >Note about the Send cart (CART) notice:
  >1. For existing Koha instances, the notice must be manually updated to remove the sentence about the attachment.
  >2. No changes are required to the notice for new instances.
- [30759](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30759) Add hint about the data that is sent via the Google Books API to OPACSuggestionAutoFill
  >This enhancement adds a note about the data that is sent to Google if the OPACSuggestionAutoFill system preference is enabled.

  **Sponsored by** *Catalyst*
- [34973](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34973) Update Font Awesome for the OPAC to fix JavaScript warning in the console for Firefox: "Glyph bbox was incorrect"
  >This fixes browser console JavaScript errors about Font Awesome fonts for the OPAC when using Firefox. The version of Font Awesome used was upgraded from 6.3 to 7.2 as part of fixing this.

  **Sponsored by** *Athens County Public Libraries*
- [40603](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40603) Add support for "uri" to OPACAuthorIdentifiersAndInformation
  >This enhancement adds the option to use 'uri' in 024$2 and a a URI in 024$a for personal name authority records.
  >
  >This information can then be shown in the OPAC author information sections for a bibliographic record and authority record (when the Identifiers (024$2$a) option is selected for the OPACAuthorIdentifiersAndInformation system preference).
  >
  >It also updates the OPACAuthorIdentifiersAndInformation system preference description to include uri in the list of codes.

  **Sponsored by** *Athens County Public Libraries*
- [41318](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41318) AmazonLocale system preference - add Brazil as an option
  >This enhancement lets you manually set the top-level domain using the AmazonLocaleTld system preference (previously AmazonLocale), instead of using a hard-coded predefined list.
  >
  >Notes:
  >- AmazonLocale system preference is now renamed to AmazonLocaleTld.
  >- There is no dropdown list, but you can click on the domains listed under options in the description to add it.
  >- The system preference is not actually used to retrieve the image, it is used for the link "Amazon cover image (see the original image)" at the bottom of the light box after clicking on the image.
  >- If AmazonLocale is set and you click the link in the light box, it often leads to a page not found (404) or broken pages on the Amazon country domain.
- [42586](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42586) Allow extra elements on OPAC top navigation bar
  >Tools > HTML customizations has a new location, `OPACNavbarExtraContent`, listed under OPAC items. Its content is shown in the OPAC top navigation bar.

### Packaging

#### Enhancements

- [42087](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42087) Add dependency File::LibMagic for validating file using magic numbers
  >This patch adds File::LibMagic to Koha's dependencies via cpanfile. This Perl library allows access to the C library libmagic which determines file type based off of "magic numbers" which are data in the first line of many file types which are unique to that filetype.

### Patrons

#### New features

- [39658](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39658) Allow definition of non-hierarchical linked patron accounts
  >This enhancement allows multiple Koha accounts to be linked together without the implied hierarchy of a guarantor/guarantee relationship. Account linking is enabled with the new EnablePatronAccountLinking system preference. Account linkages can only be managed in the staff interface. Linked accounts can be collectively blocked from checkout based on their shared debit total based on the new NoIssuesChargeLinkedAccounts system preference. If the new AllowLinkedAccountHoldPickup system preference is enabled, an item that is on hold for one patron may be retrieved by another patron with a linked account. When the item is entered as a checkout on the second patron's account, it will be automatically checked out to the first patron instead, thereby fulfilling their hold.

#### Enhancements

- [14806](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14806) Action Log for Modifying borrower messaging preferences
  >This patch records changes to a patron’s messaging preferences in the action log when the BorrowersLog system preference is enabled. Updates to notification methods, digest settings, and reminder timing are now logged with before/after values, including when a preference is removed.

  **Sponsored by** *Koha-Suomi Oy*
- [32652](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32652) Match the curbside pickup time slots selection for the staff interface with the OPAC
  >This enhancement updates the style of the time selection controls for curbside pickups so that it more closely matches the OPAC.
  >
  >Changes include:
  >- The times are now styled as buttons
  >- A check-mark icon is shown when a time is selected
  >- There is now a tooltip: "Pickups scheduled: X"
  >- The form now uses CSS grids

  **Sponsored by** *Athens County Public Libraries*
- [34632](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34632) Patron Importing should be a background job
  >Patron importing now runs as a background job. This update prevents server timeouts when uploading large files and provides real-time progress tracking. A detailed summary is generated upon completion, making bulk patron imports much more reliable and easier to manage.
- [42112](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42112) Add option when changing a patron's category: allow choosing what to do for the expiry date and messaging preferences
  >This adds two new system preferences that let you control what happens when changing a patron's category:
  >- Updating the enrollment period expiry date: 
  >   UpdateExpiryDateOnCategoryChange
  >- Updating the messaging preferences:
  >   UpdateMessagingPrefsOnCategoryChange
  >
  >When changing a patron's category, a pop-up window with pre-populated checkboxes is shown and lets you select what to do (depending on the new system preference settings).
  >
  >The options for both the new system preferences are:
  >- Never update
  >- Ask before updating, default to no
  >- Ask before updating, default to yes (note: this is the default)
  >- Always update without asking
- [42350](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42350) Add preferred name, middle name and other name to batch  patron modification
  >This enhancement makes preferred name, middle name, and other name accessible in the patron batch modification tool.
- [42734](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42734) autoMemberNumValue syspref has no formal UI
  >Superlibrarians can now view and manage the autoMemberNumValue system preference directly from the Patrons preferences page, allowing them to correct a runaway patron cardnumber counter without requiring vendor support. A caution note clarifies that the setting is automatically managed and should only be modified by experienced administrators, with warnings about the risk of duplicate cardnumbers and third-party account access if set incorrectly.
- [43518](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43518) Add a, pure Vue, reusable PatronSelect Vue component with patron search
  >Adds a reusable `PatronSelect` Vue component for developers: a searchable, debounced patron picker that shows each patron's age and library, with Expired and Restricted badges. Any screen that needs to choose a patron can mount it. It uses the new `patrons.search()` method of the patron API client, and helper functions in `js/vue/utils/patron-options.js` that format patron names as the legacy patron autocomplete does.

  **Sponsored by** *Büchereizentrale Schleswig-Holstein*

### Plugin architecture

#### Enhancements

- [33758](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33758) Add a parameter to use the intranet_catalog_biblio_enhancements_toolbar_button Plugin hook
  >The plugin hook intranet_catalog_biblio_enhancements_toolbar_button is now passed the record's `biblionumber`, so plugins can add buttons to the catalogue detail page toolbar for the record being viewed.
- [40984](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40984) Synchronise before_ and after_authority_action hook signatures with biblio action hooks
  >IMPORTANT: The authority and authority_id parameters of after_authority_action_hooks plugins have been deprecated! Please switch to using the payload hash. The old parameters will be removed in a future version of Koha.
  >
  >Note that this report also adds before_authority_action_hooks allowing you to modify authority records before saving.

### Point of Sale

#### New features

- [40445](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40445) Point of Sale reconciliation input during daily summaries
  >Point of Sale cashups can now record the cash actually counted in the register. If the counted amount differs from the expected amount, the difference is recorded automatically as a surplus (credit) or a deficit (debit) on the account. The cashup summary shows both the expected and the counted cash when there is a discrepancy.
  >
  >A cashup can also be started and completed later. While a cashup is in progress, its summary can be previewed before it is completed. Completing a cashup from the Cash summary page opens the cashup summary straight away.
  >
  >**New system preferences**
  >- `CashupReconciliationNoteRequired` (default: 0, Don't require) - require a reconciliation note when a cashup has a surplus or a deficit.
  >- `CashupReconciliationNoteAuthorisedValue` (default: empty, free text) - name an authorised value category whose values are offered as reconciliation notes. Leave empty for a free text note.
  >
  >**Upgrade notes**
  >- The database update adds the system account types `CASHUP_SURPLUS` (credit) and `CASHUP_DEFICIT` (debit). They are created by cashups and cannot be added manually.
  >- In the cashup summary, positive amounts mean cash collected, and negative amounts mean cash had to be added to the register.

  **Sponsored by** *OpenFifth*

#### Enhancements

- [33501](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33501) Add optional support for different payment types during cashup reconciliation
  >Cashup can now reconcile each payment type separately. The new `CashupPaymentTypes` preference lists, in order, the PAYMENT_TYPE authorised values that are held in the register and reconciled at cashup. The Complete cashup modal shows one row per type, with its expected total, the counted amount and a reconciliation note. Each type with a difference gets its own surplus or deficit line. Payments that are not in the list, such as cards, still appear in the cashup summary under "Taken elsewhere".
  >
  >**New system preferences**
  >- `CashupPaymentTypes` (default: `CASH,SIP00`) - ordered list of PAYMENT_TYPE authorised values reconciled at cashup. Set it in Administration > System preferences > Accounting. Add a type such as `CHEQUE` to reconcile it too.
  >
  >**Upgrade notes**
  >- The single cashup-wide reconciliation note is removed. When `CashupReconciliationNoteRequired` is set, each discrepant payment type needs its own note.
  >- Existing CASHUP_SURPLUS and CASHUP_DEFICIT lines without a payment type are set to `CASH` by the database update.
  >- With the default `CASH,SIP00`, the Complete cashup modal shows one row for `CASH` and one for `SIP00`.

  **Sponsored by** *West Sussex County Council*
- [43325](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43325) Remove event attribute from point of sale receipt window

  **Sponsored by** *Athens County Public Libraries*

### REST API

#### Enhancements

- [23998](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23998) Messages REST API
  >Messages recorded against patrons can now be managed through the REST API at `/api/v1/messages`. The endpoint supports listing, adding, getting, updating (PUT and PATCH) and deleting messages.
  >
  >Reading messages requires `borrowers > list_borrowers`. Adding, changing and deleting messages requires `borrowers > edit_borrowers`. Staff only see and change messages for patrons they are allowed to see. Patron and library IDs in a request are checked, and invalid values are rejected with a 400 error.
- [24401](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24401) Add POST /checkins endpoint with availability check and confirmation flow
  >New REST API endpoints for check-in operations: GET /checkins/availability for pre-flight checks and POST /checkins to return items. Supports the same JWT confirmation flow as POST /checkouts, embedded related
  >   objects (item, checkout, hold, transfer, restriction, debits, credits, etc.), and returns the full checkin record.
- [35797](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35797) Add GET route for patron images
  >This enhancement adds a new API route to request a patron image, if it exists. Errors are returned if a patron number doesn't exist or there is no patron image.
  >
  >Example API request: http://127.0.0.1:8081/api/v1/patrons/49/default_image
  >
  >Error messages:
  >- If there is no patron image: Patron image not found.
  >- If the patron doesn't exist: Patron not found.
- [38291](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38291) Add GET /library_groups
  >New REST API endpoint `GET /api/v1/library_groups` lists library groups, and an entry for each library added to a group, with paging, sorting and `q` searching. Each entry gives the group's title, description, parent group, the libraries it contains and its access flags (hide patron info, limit item editing, limit report access, OPAC and staff search groups, local hold and float groups). Requires the `manage_libraries` permission, as the Library groups page does.
- [41950](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41950) Make +count embeds sortable by using SQL-level COUNT subqueries
  >Developer and API note: `+count` embeds (for example `claims+count`) are now calculated in SQL as correlated subqueries, rather than with one query per row. They can be used in `_order_by`, so API results can be sorted by a count. Embeds that previously had no database relationship now have one, including checkouts on patrons, baskets and invoices on vendors, and holds on biblios.
- [42207](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42207) Allow library embed on GET /patrons/{patron_id}
  >Integrators: `GET /patrons/{patron_id}` now accepts `library` as an embed (`x-koha-embed: library`), so the response includes the patron's library details.

  **Sponsored by** *Büchereizentrale Schleswig-Holstein*
- [42592](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42592) Flag +count embeds that cannot be sorted
  >Developers: the OpenAPI spec now flags `+count` embeds that cannot be sorted, using the `x-koha-unsortable-embeds` extension, on GET /acquisitions/orders, GET /biblios/{biblio_id}/items and GET /patrons. The published API documentation shows this extension.
- [42679](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42679) Add GET /patrons/{patron_id}/overdues_count endpoint
  >Developers: new endpoint `GET /api/v1/patrons/{patron_id}/overdues_count`, which returns the number of overdue checkouts for a patron as an integer. It is computed live from the database. It requires the `borrowers > list_borrowers` permission and is intended for loading overdue counts on demand, for example in patron search results.
- [42730](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42730) Migrate place_booking.js $.post to api-client.js
- [42731](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42731) Migrate modal-claims.inc $.post to api-client.js
- [42732](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42732) Migrate catalogue/detail.tt addToBundle $.post to api-client.js
- [42998](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42998) Allow a requested due date when renewing a checkout via the REST API
  >The checkout renewal endpoints (`POST /api/v1/checkouts/{checkout_id}/renewal` and `/renewals`) now accept an optional `due_date` (RFC 3339) in the request body, to renew a checkout to a specific date. The date is checked against bookings for the item, and any linked booking's end date is kept in step with the new due date. A malformed `due_date` is rejected with a 400 response.
  >
  >The `x-koha-override` header accepts `renewal_limit`, which skips the renewal count limit when `AllowRenewalLimitOverride` is enabled. Overrides made through the API are recorded in the renewal log, as they are in the staff interface.
  >
  >Refused renewals return an `error_code` in the response (for example `booked` or `too_many`) in addition to the message.

  **Sponsored by** *OpenFifth* and *Westminster City Council*
- [43486](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43486) Add permission-gated patron notification info to the checkin hold.patron embed
  >Integrators: the patron API accepts a `notification_summary` embed (`x-koha-embed=notification_summary`) showing how the patron will be notified when a hold is filled or a recall is waiting, including the notice transports and the primary contact method. The embed is returned only when the requesting user is allowed to see the patron.
- [43606](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43606) Add x-koha-embed: items support to GET /biblios (list), respecting OPAC/public item visibility
  >This development adds the option to embed holdings (items) information on bibliographic records related endpoints.

### Reports

#### New features

- [16631](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16631) Limit listing of reports using patron library
  >This enhancement adds the ability to limit saved reports to users based on the user’s home library. When enabled via the new LimitReportsBy system preference, staff members with the manage_report_limits permission and superlibrarians can restrict which libraries have access to individual reports. Staff members will only see reports assigned to their home library, ensuring that catalogers and staff at different libraries or branches only have access to the reports relevant to their library or branch.
  >
  >To use this feature, enable the LimitReportsBy system preference in Administration > System Preferences > Reports. Then grant the manage_report_limits permission to staff members who should be able to manage which libraries can access reports. When editing a saved report, users with this permission will see a "Library limitation" select box at the bottom of the edit form, where they can choose one or more libraries that should have access to the report.Reports created non-permissioned users are limited to that user's home library. Limits are not changed when non-permissioned users edit a report to avoid overwriting limits intentionally set by permissioned users.
  >
  >The saved reports list includes a new "Library limits" column (visible only to users with the manage_report_limits permission or superlibrarians) that displays how many libraries each report is limited to. Hovering over the count shows a tooltip with the full library names and codes. Users with the manage_report_limits permission also have access to a "Show reports" filter with options to view all reports ("Show all reports") or only reports available to their home library ("Show my branch reports").
  >
  >When upgrading, a new table (reports_branches) is created to track the relationships between reports and libraries. A new system preference (LimitReportsBy) is added to enable the feature, and a new permission (manage_report_limits) is added to control who can manage report limitations. Library limitations are preserved when duplicating reports and persist when the LimitReportsBy preference is toggled on or off.

  **Sponsored by** *Ramapo Catskill Library System*
- [41921](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41921) Add ability to run reports as background jobs
  >This enhancement adds the ability to run reports as background jobs. This allows long-running reports to process their query in the background, with results available to users once they've completed. A new report jobs page shows all currently running reports and provides access to all reports previously run as background jobs. 
  >This behavior is controlled by a new system preference, ReportsRunInBackground. The system preference options allow for either all reports to run in the foreground, all reports to run in the background, or for the user to choose when the report is run. Further, the execute_reports permission is split into a permission to execute reports in the foreground and a permission to execute reports in the background.

  **Sponsored by** *Cape Libraries Automated Materials Sharing*

#### Enhancements

- [41920](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41920) Limit number of concurrent reports that can be run simultaneously for an instance of Koha
  >This enhancement allows for the configuration of the 'total_running_reports_per_instance_limit' variable in koha-conf.xml. When configured this will restrict the number of concurrent total reports that can be run on an instance simultaneously.
- [42108](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42108) Add ability to specify that a report can only be run as a foreground or background report
  >This enhancement allows individual reports to be set to always run in either the foreground or the background. This option is set when either creating or editing a report. The option is only available when the ReportsRunInBackground system preference is set to "let the user choose." If the system preference is set to force all reports into either the foreground or the background, the per-report option is hidden and overridden.
- [42621](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42621) Extend report limitations by library to use library groups
  >This enhancement allows reports access to be limited by library groups. The system preference LimitReportsBy gains the new option "library groups". In library groups setup in administration, a new group feature of "Limit report access by group" is added. When the system preference is set to limit by groups, a report with a library limitation that includes any given library will also be accessible to users from other libraries sharing a report-limiting group with the first library.
- [42623](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42623) Add ability to restrict which libraries can be selected in a report runtime parameter
  >This enhancement limits which libraries are available to be selected when a report asks for a library as a runtime parameter. If the LimitReportsBy system preference is set to limit report access by library or library group, any runtime parameter asking the user to select a library will only offer the user the options of libraries from which the report can be run. If the system preference is set to "No restriction" or a given report has no library limits defined, all libraries are offered as options in a runtime parameter.
- [42667](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42667) Split the ability to edit other librarian's reports into a separate permission
  >Editing other librarians' SQL reports now needs a separate permission, `reports > edit_all_reports` ("Edit SQL reports created by other librarians"). Users with `create_reports` can still create and edit their own reports. The edit controls are hidden for reports a user cannot edit.
  >
  >**New permissions**
  >- `reports > edit_all_reports` - edit SQL reports created by other librarians.
  >
  >**Upgrade notes**
  >- The database update grants `edit_all_reports` to every user who already has `create_reports`, so nothing changes for them. Remove the permission from users who should only edit their own reports.
- [43739](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43739) Notice templates should include format with notice name in dropdown

  **Sponsored by** *OpenFifth*
- [43744](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43744) Make report object available when running report with template
  >Notice templates in the Reports module can now use the saved report that is running them, as `report`. For example, `[% report.report_name %]` in a notice body shows the report's name. This applies when the notice is sent from a guided report, or by `misc/cronjobs/patron_emailer.pl -module report -report <id>`.

  **Sponsored by** *OpenFifth*

### SIP2

#### New features

- [42769](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42769) Add a SIP testing tool to the staff web interface
  >Adds a "Test SIP2 messages" button to the SIP2 account editor (Administration > SIP2 > Accounts). It lets staff check what a SIP2 account returns for a message, without a SIP connection or the account's SIP password. Staff choose a message type (patron status, patron information, item information, checkout or check-in), enter a patron barcode, item barcode or patron password as needed, and run the test. The raw request and the response are shown, with the response broken into named fields. The request can also be edited by hand.
  >
  >The test runs the real SIP message handlers as the patron the account logs in as, so the circulation rules apply as they would for a real login. It runs in a transaction that is always rolled back, so a checkout or check-in is reported but not carried out. Each test is written to the API log with the user, the account and the message code. No patron or item identifiers are logged. Staff may not test messages for patrons or items they cannot see, and an item from another library is refused when `IndependentBranches` is enabled, unless the user is a superlibrarian.
  >
  >The patron password is not checked against the patron's record. Staff choose "Valid password" or "Invalid password" to get the matching response, or "Not sent".
  >
  >**New permissions**
  >- `sip2 > manage_sip2` - the SIP2 pages and their API endpoints. Required in place of the whole `sip2` permission.
  >- `sip2 > test_sip2_messages` - use the message tester. It also needs `borrowers > list_borrowers`.
  >
  >**Upgrade notes**
  >- Staff who already have the whole `sip2` permission get both new permissions. Other staff need `sip2 > manage_sip2` to use the SIP2 pages, and `sip2 > test_sip2_messages` to use the tester.

#### Enhancements

- [41649](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41649) Add support for setting the magnetic media flag for SIP in Koha
  >Item types can now be flagged as magnetic media for SIP2. The flag is used to set the magnetic media field in SIP2 checkout, checkin and renewal responses, and magnetic items are not desensitized. This lets SIP-connected equipment, such as Biblioteca automated sorters, handle returned items correctly.
  >
  >**Item types**
  >Administration > Item types has a new "SIP magnetic" checkbox next to "SIP media type". It is unticked by default.
  >
  >**To enable**
  >1. In Administration > Item types, tick "SIP magnetic" for each item type that represents magnetic media, such as tapes or cassettes.
  >
  >**Upgrade notes**
  >- No item types are flagged after upgrade, so SIP2 responses do not change until the flag is set.

  **Sponsored by** *OpenFifth*
- [42180](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42180) Add patron lookup tool to SIP2 account creation
  >The SIP2 account form now uses a patron search to set the staff userid for SIP2 authentication, instead of a free text field. The list and detail views show the patron's userid. Setting the login ID requires the `list_borrowers` permission as well as `sip2`, because the search uses the patrons API.
  >
  >**Upgrade notes**
  >- A stored login ID that does not match a patron shows as "Invalid patron data", with a Remove link. Select a patron to fix the account.

### Searching - Elasticsearch

#### Enhancements

- [22639](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22639) Ability to export Elasticsearch mappings and facets settings
  >This enhancement adds an 'Export mappings' button to the Elasticsearch mappings configuration page to download the current search field mappings as YAML.
- [36724](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36724) Add cartographic mathematical data to Elasticsearch index mappings
  >Values in 255$a and 255$b in MARC21 bibliographic records are now indexed and searchable in Elasticsearch.

  **Sponsored by** *Education Services Australia SCIS*

### Self checkout

#### Enhancements

- [43671](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43671) Holds impair SCO module load time
  >This fixes the self-checkout module to improve the loading time for the holds tab, particularly where there are a large number of holds.
  >
  >It adds a new system preference, SCOLoadHoldsByDefault (enabled by default). If not enabled, there is a button "Load your holds" when you click the "Holds" tab.

### Serials

#### Enhancements

- [37140](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37140) Add vendor automatically to 952 $e when creating items for serials
  >This enhancement to serials populates the '952$e - Source of acquisition' with the vendor id when an item is received (where the serial has 'create an item record' set).

  **Sponsored by** *Bibliotheksservice-Zentrum Baden-Württemberg (BSZ)*
- [40201](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40201) Subscription search form on the start page is missing additional fields
  >The subscription search form on the Serials home page now includes the additional fields for serial subscriptions that are marked as searchable (Administration > Additional fields > Serials subscriptions).
- [41387](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41387) Add option for 2 digit month to serial patterns
  >This adds some new placeholders to be used within the numbering pattern of a subscription: {Day2} and {Month2}. They will be automatically replaced with the corresponding 2 digit value derived from the publication date of the issue when it's received.
- [42078](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42078) Allow vendor ID searches on serial subscription vendor search page
  >The vendor search on the serial subscription form (Serials > New subscription, then search for a vendor) now also finds a vendor by its exact vendor ID. Searching by part of the vendor name still works. The field label is now "Vendor name or ID".

### Staff interface

#### Enhancements

- [32419](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32419) Show availability in list view in staff interface
  >This patch adds a new XSLT to apply to the lists view on the staff interface, used by the XSLTListsDisplay system preference.
  >
  >It is almost a copy of MARC21slim2intranetResults.xsl, used by the XSLTResultsDisplay system preference, except it includes code to also display item availability. Item availability is already shown on the lists view on the OPAC, so this adds that functionality to the staff interface.

  **Sponsored by** *Pymble Ladies' College*
- [36897](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36897) Make it possible to use select[multiple] and select[size] in a sidebar
  >Multiple-select and sized select boxes placed in a staff interface sidebar now show their full height, instead of collapsing to a single line. For example, the clipboard in the advanced cataloguing editor sidebar keeps its 10-line height.

  **Sponsored by** *Chetco Community Public Library*
- [38185](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38185) DT - replace dom with layout
  >Tables in the staff interface that use the shared table component have a new layout. The paging, search and button controls have moved, and the "First" and "Last" links are hidden at narrow widths. The "full" pagination style (First, Previous, Next, Last, without page numbers) is removed, so page numbers are shown everywhere. On the credit types, debit types and patron account pages, the table filters now sit above the table.
  >
  >**Configuration**
  >- Developers: `kohaTable` no longer accepts the deprecated `dom` and `pagingType` options, or the legacy DataTables options. Use `layout` and `tableFeatures` instead. `tableFeatures` takes a list of `info`, `search`, `paging` and `buttons`. If it is omitted, all of them are shown. Passing a deprecated option throws an error.
  >
  >**Upgrade notes**
  >- Local JavaScript or plugins that pass `dom` or `pagingType` to `kohaTable` must be updated, or those tables will throw an error.
- [41116](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41116) Selectors are inconsistently structured in hold found modals
  >The patron phone number and email address on the branch transfer page are now marked with the classes `patron-phone` and `patron-email`, matching the other staff templates that show them. What is displayed does not change. Local CSS or JavaScript that targets the previous selectors needs updating.
- [41254](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41254) The filter for item status in item tables should be improved
  >This enhancement groups the values for the records detail page status column filter on the holdings table in the staff interface. 
  >
  >This makes it easier to select the appropriate status value, as it can correspond to multiple authorised values, for example, Not for loan, Withdrawn, Lost and Damaged. Until now, only a single entry could be selected, and filtering applied to all values at once.
- [41995](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41995) Autocomplete for syspref search
  >The system preference search on the Administration page now suggests preference names as you type, once three characters have been entered. Choosing a suggestion opens the search result for that preference.
- [42322](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42322) Collapse sidebar
  >This enhancement adds the ability to collapse the left-hand sidebar (menu) on almost all pages in Koha.
- [42330](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42330) Use main-container.inc from all the templates
  >Many staff pages that used their own layout, such as Acquisitions, Administration, Cataloguing, Circulation, Members and Tools pages, now use the shared main container. These pages therefore get the same structure and the sidebar collapse feature.
  >
  >Developers: staff templates should use `main-container.inc`. The test `xt/find-missing-main-container.t` prevents new `<main>` elements in staff templates.
- [42332](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42332) Remove conditional TT tags from tables thead
- [42344](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42344) Remove CircSidebar
  >The `CircSidebar` system preference is removed. Circulation pages now always show the navigation sidebar, which can be collapsed with its toggle button.
  >
  >**Upgrade notes**
  >- The database update deletes `CircSidebar`. Sites that had it turned off will see the sidebar on circulation pages after the upgrade.
- [42564](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42564) Upgrade Font Awesome in the staff interface to 7.2
  >This upgrades the version of Font Awesome used for the staff interface from 6.2 to 7.2.
  >
  >This also fixes numerous browser console JavaScript errors in the browser console ("downloadable font: Glyph bbox was incorrect" warnings) about Font Awesome for the staff interface when using Firefox.

  **Sponsored by** *Athens County Public Libraries*
- [42584](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42584) Allow extra elements on staff top navigation bar
  >Tools > HTML customizations has a new location, `StaffNavbarExtraContent`, listed under Staff items. Its content is shown in the staff interface top navigation bar, separate from the main menu. It can be restricted to one library, so it only shows when that library is selected.
- [42925](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42925) Replace the 'clear' button with an icon inside the search box (global search for tables)
  >This updates the global search for tables (where DataTables are used), so that:
  >- The 'X' to clear a search works across Chrome and Firefox based browsers.
  >- Removes the 'X Clear filter' option.
  >- The 'X' to clear the search can be navigated to using the tab key (that is, it can be accessed when using keyboard navigation).
  >
  >Previously, the 'X' to clear an active table search only appeared in Chrome-based browsers, and wasn't visible in Firefox-based browsers.
- [43389](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43389) Remove conditional TT tags from tables thead (Holdings tables)
- [43576](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43576) Add icon-only collapsed mode to staff interface sidebar menus
  >The collapsible staff sidebar can now be collapsed to an icon-only rail. Each link in the main sidebar menus has an icon, and hovering over an icon shows its label. The collapsed or expanded state is remembered from page to page. The toggle is at the top of the sidebar.
  >
  >Menus converted so far are: circulation (patron and module menus), cataloguing, tools, system preferences, reports, guided reports, the bibliographic record view, serials, labels, point of sale, acquisitions, vendors and administration (the Vue menus), and the Notices management page. The icons match those on the module home pages and in the header search tabs, and no two neighbouring icons in a menu are the same.
  >
  >No system preference needs to be changed.
- [43830](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43830) Improve links to and from item details page
  >This makes two small quality-of-life improvements to links:
  >- After doing an item search, clicking the item barcode loads the item details of only that specific item. Previously it loaded the details for all items.
  >- On the item details page, clicking "Edit item" goes directly to the item edit form. Previously it linked to the top of the page, requiring the user to scroll down to the form.
- [44112](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=44112) Add a clear control to the Vue date picker and move its icon inside right
  >The date fields in the Vue pages (for example ERM agreements, Preservation, ILL and item lists) now have a clear button that empties the date in one click. The calendar icon has moved to the right of the field, next to the clear button. Developers can opt out with the `clearable` prop of `FlatPickrWrapper`. Legacy pages are not affected.

### System Administration

#### Enhancements

- [29587](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29587) Test mail option in SMTP servers
  >This enhancement adds a "Send test email" action on the SMTP servers administration page.
  >
  >It sends a test message to the address in the KohaAdminEmailAddress system preference and reports success or failure.
- [36153](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36153) Increase allowed length of authorized value descriptions
  >The description of an authorised value, for the staff interface and the OPAC, can now be up to 400 characters long, instead of 200. The database update changes the `lib` and `lib_opac` columns.

  **Sponsored by** *Education Services Australia SCIS*
- [42128](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42128) Move JS code from admin-icon-selection.inc to a separate .js file

  **Sponsored by** *Athens County Public Libraries*
- [43319](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43319) Remove event attribute from library_groups.tt

  **Sponsored by** *Athens County Public Libraries*
- [43321](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43321) Remove event attribute from search filter administration

  **Sponsored by** *Athens County Public Libraries*
- [43336](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43336) Remove support for LibrisSpellcheck
  >This removes support for LibrisSpellcheck, as the API that this feature was based on was removed by the Swedish National Library.
  >
  >It removes two system preferences: LibrisKey and LibrisURL. It also removes the LibrisSpellcheck option from "Did you mean?" (Administration > Additional parameters > Did you mean?).

### Templates

#### Enhancements

- [31406](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31406) Set focus for cursor to Name input when adding a new item search field
  >When adding an item search field in Administration > Item search fields, the cursor is now placed in the Name field, so you can start typing straight away.
- [41826](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41826) Update item type and authorized values pages to use grid layout for forms
  >The New and Edit forms for Administration > Authorized values and Administration > Item types now use a grid layout, for a cleaner and more consistent form layout.

  **Sponsored by** *Athens County Public Libraries*
- [42440](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42440) Remove event attributes from labeled MARC detail template

  **Sponsored by** *Athens County Public Libraries*
- [42441](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42441) Remove event attributes from authority merge template

  **Sponsored by** *Athens County Public Libraries*
- [43257](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43257) Remove event attributes from circulation.tt

  **Sponsored by** *Athens County Public Libraries*
- [43293](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43293) Add IDs to the Pay/Write off confirm buttons on paycollect.tt
  >The Confirm buttons on the patron Pay fines and Write off forms now have ids: `paysubmit` for payments and `writeoffsubmit` for write offs. Local customisations, hardware integrations such as receipt printer triggers, and tests can now target each action reliably. The individual Pay and Write off forms have their own button ids: `pay_individual-submit` and `writeoff_individual_submit`.
- [43829](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43829) Add toolbar to patron list detail page
  >This patch adds a toolbar to the patron list detail page so that a user with the correct permission can easily edit or delete the list from this page. The patch also makes some markup corrections for validity, and removes some unused
  >JavaScript from the main patron lists page.

  **Sponsored by** *Athens County Public Libraries*

### Test Suite

#### Enhancements

- [42772](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42772) Upgrade Cypress to 15.16.0
  >The Cypress test suite is upgraded to Cypress 15.16.0. Test writers should use `cy.env()` for sensitive values, or `Cypress.expose()` for public configuration, in place of `Cypress.env()`. The `experimentalStudio` option has been removed from the Cypress configuration, as Cypress Studio is now available to all users.
- [43517](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43517) Enable vue-tsc type checking and shared Cypress component-test shims
  >Adds `vue-tsc` type checking for `.vue` files, run with the `types:check` script, and shared Cypress component-test support. Cypress tests now fail on unexpected `console.warn` output, such as Vue or deprecation warnings. The global `String.prototype.format` and the flatpickr, dayjs and `$timezone` globals used by components are provided to component tests. `String.prototype.format` now lives in `js/str-format.js`, loaded before `staff-global.js`.

  **Sponsored by** *Büchereizentrale Schleswig-Holstein*

### Tools

#### Enhancements

- [15248](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15248) Make it possible to configure duplicate check on bibliographic records
  >This enhancement allows one to select a custom matching rule for use when creating new records, rather than relying on Koha's default check on title and author. This selection is made per framework in Administration module. Any framework for which no matching rule has been selected will continue to use Koha's default title and author matching.

  **Sponsored by** *SCD Lyon2*
- [21860](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21860) MARC modification templates cannot check or change indicators
  >MARC modification templates can now match and set MARC indicators. For actions on fields with tags 010 and above, the **Use indicators** checkbox lets you:
  >- match only the fields whose indicators match the source indicators (enter `_` to match a blank indicator, or leave an indicator empty to ignore it);
  >- set the indicators of the destination field;
  >- use the indicators of the conditional field in an "if" condition.
  >
  >Control fields (tags below 010) have no indicators. Existing template actions are not affected, and do not use indicator criteria unless **Use indicators** is ticked.

  **Sponsored by** *koha-US*
- [27248](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27248) Allow to use list of barcodes with batch extend due dates tool
  >This adds a new input to the Batch extend due dates tool for a list of item barcodes to further specify checkout criteria. It also adds a new batch operation available in reports that return item numbers that sends the items to the Batch extend due dates tool.

  **Sponsored by** *Cape Libraries Automated Materials Sharing*
- [28915](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28915) MARC modification templates should allow specification of a position or range within a control field
  >MARC modification templates can now change control fields (tags below 010), such as 008. For an **Update existing or add new** action on a control field, the "starting from character position" box sets the position to write to, and the value replaces the characters from that position onwards. Positions of two digits, such as 35 in field 008, can be entered.
- [41105](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41105) Add Gender option in Batch patron modification
  >Batch patron modification now includes a Gender column and a Gender option. Staff can set the gender of all the selected patrons to Female, Male or Other, or clear it.

  **Sponsored by** *OpenFifth*
- [42097](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42097) Add link to create new club from list of club templates
  >This enhancement changes the actions for patron club templates (Tools > Patrons > Patron clubs > Club templates) so that:
  >- there is a new action to create club directly from the club templates actions (New club)
  >- the actions are now in a dropdown list (the same as the clubs section)
  >
  >This makes it easy to create a new club directly from the list of templates.

  **Sponsored by** *Athens County Public Libraries*
- [42111](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42111) Update various admin pages to use grid layout for forms - Part 1
  >The New and Edit forms of several administration pages now use a grid layout, so fields line up more consistently. The pages are Additional fields, Audio alerts, Cities and towns, and the Classification sources, filing rules and splitting rules pages. The regular expression section of the classification splitting rules form is also laid out more clearly.

  **Sponsored by** *Athens County Public Libraries*
- [42118](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42118) Update various admin pages to use grid layout for forms - Part 2
  >The New and Edit forms of several administration pages now use a grid layout, so fields line up more consistently. The pages are Item search fields, OAI sets, OAI set mappings, OAI repositories, SMS cellular providers and SMTP servers. The OAI set mapping fields now have a maximum length.

  **Sponsored by** *Athens County Public Libraries*
- [42627](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42627) Printing a range of barcodes should be from and quantity instead of from and to
  >This enhancement changes the inputs when printing a range of barcodes. Previously the tool asked for a "From" and a "To" to define the range of barcodes. This patch changes that to have a "Starting barcode" and a "Number of barcodes to print" to define the range. The enhancement also limits the total number of barcodes that can be printed at once to 1000.
- [43029](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43029) Guard maintenance scripts against biblios with corrupt metadata
  >The maintenance scripts `misc/maintenance/sanitize_records.pl` and `misc/maintenance/touch_all_biblios.pl` now skip and report any biblio whose metadata cannot be read, instead of stopping the whole run.

  **Sponsored by** *OpenFifth*

### Transaction logs

#### Enhancements

- [42033](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42033) Add diff support to patron restriction and circ message action logs
  >This enhancement adds diffs to the log viewer for patron restriction and message actions.

  **Sponsored by** *OpenFifth*
- [42035](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42035) Add diff support to APIKEYS CREATE and DELETE action logs
  >When `ApiKeyLog` is enabled, creating and deleting an API key is logged with the key's details, so the Diff column in Tools > Log viewer (module "API keys") shows what was created or deleted.
  >
  >**Changed system preferences**
  >- `ApiKeyLog` (default: 0, "Don't log") - now also records the details of API keys that are created or deleted, not only the action.

  **Sponsored by** *OpenFifth*

### Web services

#### Enhancements

- [41084](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41084) Zotero connector broken by bug 37370
  >Restores Zotero support for the OPAC export. A new system preference lets the `utf8` export format (used by the Zotero browser extension) be served even when it is not selected in `OpacExportOptions`.
  >
  >**New system preferences**
  >- `EnableZotero` (default: enabled) - allows `utf8` export from the OPAC regardless of `OpacExportOptions`.
  >
  >**Upgrade notes**
  >- The preference is enabled for existing sites on upgrade, so Zotero keeps working.
## Bugfixes
This list includes all bugfixes since the previous major version. Most of them
have already been fixed in maintenance releases


#### Security bugs

- [34451](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34451) Add CSRF protection to REST API

#### Critical bugs fixed

- [42605](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42605) Acquisition Items not listed during receipt (26.11.00,26.05.04)
  >Fixes the Receive orders page not listing any items to receive when `AcqCreateItem` is set to "placing an order". The page now reads that preference as its actual value instead of a yes/no flag.
- [42702](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42702) Acquisitions: Cancel order link on parcel.pl absorbs following HTML into href (26.11.00,26.05.02)
- [42723](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42723) Purchase suggestion 500 page error when EmailPurchaseSuggestions is set to "email address of library" (26.11.00,26.05.01,25.11.06,25.05.12,24.11.18)
  >This fixes a 500 page error[1] when creating a suggestion in the staff interface if:
  >- the EmailPurchaseSuggestions system preference is set to "email address of library", and
  >- the library for acquisition information is set to "Any".
  >
  >[1] Can't call method "inbound_email_address" on an undefined value at /kohadevbox/koha/Koha/Suggestion.pm line 107
- [42995](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42995) Error in table of pending orders prevents receiving orders (26.11.00)
  >Fixes an error ("500: Internal Server Error") on Receive shipments, where the table of orders never loaded because of an invalid database query when the orders API embedded counts of related records.
- [43211](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43211) Koha hangs when receiving order with AcqCreateItem set to 'receiving an order' (26.11.00,26.05.05)
  >This fixes an error when receiving an order, when the basket has "Create items when" set to "receiving an order". Orders can now be received when this is the case.
  >
  >Previously, receiving an order would result in the page staying on "Processing", and nothing further happening (as well as a browser console JavaScript error "Uncaught TypeError: unique_item_fields.split is not a function").
- [43787](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43787) Adding orders from a staged file (addorderiso2709.pl) can use gigabytes of memory if there are many funds (26.11.00,26.05.05)
  >Greatly reduces the size of the "Add orders from a staged file" page by removing the whitespace repeated in every fund drop-down. On systems with very many funds the page was previously hundreds of megabytes and could exhaust the server's memory.
- [30233](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30233) [CVE-2026-19780][ZDI-CAN-29165] Remote code execution in user-supplied regex (26.11.00,26.05.02,25.11.07,25.05.13,24.11.18)
  >This change refactors the regular expression handling for Batch Item Modification, MARC Modification templates, and Callnumber splitting. It moves from Perl's traditional compile-time regular expression handling to a more dynamic (but restrictive) run-time regular expression handling more similar to Python's "sub" regex method. This functions to reduce vulnerabilities to code injection into Koha's Perl backend.
- [42674](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42674) OS command injection via `jobid` in Task Scheduler (`tools/scheduler.pl`) (26.11.00,26.05.04,25.11.09,25.05.15,24.11.20)
- [42736](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42736) SQL Injection in reports/cat_issues_top.pl via Criteria / Filter request parameters (unvalidated string context, no placeholders) (26.11.00,26.05.03,25.11.08,25.05.14,24.11.19)
- [42746](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42746) Stored SQL injection via unvalidated 'agefield' in automatic_item_modification_by_age (C4::Items::ToggleNewStatus) (26.11.00,26.05.02,25.11.07,25.05.13,24.11.18)
- [42747](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42747) Stored SQL injection via patroncard layout image_name (patroncards/edit-layout.pl -> create-pdf.pl) (26.11.00,26.05.02,25.11.07,25.05.13,24.11.18)
- [42749](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42749) SQL injection in acqui/parcels.pl via the orderby parameter (ORDER BY direction) reaching C4::Acquisition::GetInvoices (26.11.00,26.05.02,25.11.07,25.05.13,24.11.18)
- [42847](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42847) SIP authentication ignored after initial successful connection (26.11.00,26.05.02,25.11.07,25.05.13,24.11.18)
  >Fixes the SIP server leaving a connection logged in as the previous terminal after a failed login attempt. A failed login now clears the earlier login.
- [42992](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42992) FTP file transport list_files() corrupts filenames (26.11.00,26.05.03,25.11.10)
- [43019](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43019) OPAC pages limited to library are readable by unauthenticated users (26.11.00,26.05.02,25.11.07,25.05.13,24.11.18)
- [43121](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43121) Vue: Don't pattern match on translatable strings (26.11.00,26.05.03,25.11.11)
- [43330](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43330) C4::Tags fails to compile when TagsExternalDictionary is configured (26.11.00,26.05.05)
- [43401](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43401) Makefile.PL doesn't compile vue OPAC js to the right directory (26.11.00,26.05.04)
- [43424](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43424) REST Basic Auth bypasses account lockout (8.1 HIGH) (26.11.00,26.05.04,25.11.09,25.05.15,24.11.20)
- [42719](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42719) OAuth/OIDC login crashes with 500 when no CGISESSID cookie exists (IdP-initiated flow) (26.11.00,26.05.04)
- [43375](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43375) OAuth userinfo_url silently fails to parse JSON when Content-Type has extra parameters (e.g. Microsoft Graph) (26.11.00,26.05.05)
  >This patch makes the content-type detection for the OAuth2 client more robust. The result is more robust integration with external identity providers.
- [32748](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32748) Library limitations will cause data loss when editing items (26.11.00,26.05.05)
  >When an authorised value used on the item edition form (e.g. damaged status, withdrawn status, etc.) was restricted to a specific library, staff at other libraries could not see the item's current value in the dropdown list and risked silently overwriting it when saving.
  >
  >This is now fixed: the current value is always displayed, even if it comes from an authorised value restricted to another library, with a warning indicating it is not normally available for the logged-in library.

  **Sponsored by** *BibLibre*
- [43872](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43872) Spelling fix in Bug 23415 causes auto renewals to send that should not (26.11.00,26.05.06)
  >Fixes a misspelled `auto_renew_error` value (`auto_too_much_oweing` instead of `auto_too_much_owing`) left in existing checkouts and old checkouts, which could cause patrons to receive an auto-renewal notice in error.
  >
  >**Upgrade notes**
  >- The database update corrects the existing rows automatically.
- [42218](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42218) ERM yearly usage totals can be wrong after re-harvesting (26.11.00)
  >The yearly numbers were wrong and could not be repaired.
  >ERM yearly usage totals are now always calculated from the monthly usage, fixing wrong totals when a year was split over several COUNTER files or re-harvested with corrected figures. Existing totals are recalculated during the upgrade. Only regular usage is now imported from COUNTER master reports; text and data mining (TDM) usage is no longer counted. This restriction is temporary. Once Access_Method is added to the database (see Bug 44050), the restriction to Regular can be lifted.
- [43944](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43944) Manual Counter file imports fail on spec compliant files (26.11.00)
  >Fixes manual COUNTER usage file imports failing for files that use the date format required by the COUNTER specification (`Mmm-yyyy`, for example `Jan-2026`).
- [44067](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=44067) Unable to Save Agreements with related records with notes field (26.11.00,26.05.06,25.11.11)
  >Fixes an intermittent error ("Properties not allowed: _strings") when saving an ERM agreement that has related records, such as agreement relationships. The API no longer adds an unexpected `_strings` property to related records.
- [42608](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42608) Hold-shelf expiration over-extends when ExcludeHolidaysFromMaxPickUpDelay is on and useDaysMode=Dayweek (26.11.00)

  **Sponsored by** *OpenFifth*
- [42915](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42915) Filtering Holds table by patron name or pickup library is broken (26.11.00,26.05.03,25.11.10)

  **Sponsored by** *Cape Libraries Automated Materials Sharing*
- [42999](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42999) $valid_items flag contamination in reserve/request.pl causes non-holdable items to appear as available after the first holdable item in the loop (26.11.00,26.05.03,25.11.09)
  >This fixes placing holds using the staff interface for a specific item, where there is an item that has a "Not for loan" status.
  >
  >Previously, you could select the item that is not for loan.
  >
  >Now the item that is not for loan has an "X Not for loan" in red in the hold column, and you can't select it.
- [43033](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43033) Holds queue allocate with transport cost matrix can choose impossible holds (26.11.00,26.05.03,25.11.09)
- [43072](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43072) fill_other_biblio_holds_policy values display incorrectly in circ rules page (26.11.00,26.05.05,25.11.10)
- [43174](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43174) Regressions: Staff interface patron search on a record details page - lists patrons by default (26.11.00,26.05.03,25.11.10)
- [43378](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43378) Wrong hold can be selected when LocalHoldsPriority set to GiveLibraryAndGroup (26.11.00,26.05.05)
- [43674](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43674) ISO 18626 messages are missing the mandatory ISO18626Message envelope (26.11.00,26.05.06)
- [42795](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42795) Bug 40658 breaks CLI for 25.11 (26.11.00,26.05.02,25.11.08)
- [42886](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42886) CSS files not installed (26.11.00,26.05.03,25.11.08,25.05.16)
- [43231](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43231) Bug 40658 still breaks CLI for 25.11 after Bug 42795 (26.11.00,26.05.06,25.11.11)
- [31925](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31925) AutoCreateAuthorities needs to preserve subject heading thesaurus to not create duplicate authority records (26.11.00,26.05.06)

  **Sponsored by** *Heythrop Library*
- [40294](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40294) Mandatory patron expiration notice is not sent if patron does not have a primary contact method defined (26.11.00,26.05.05)
  >This fixes a bug with the option to make expiration notices mandatory by patron category.
  >
  >Before this update, if a Primary Contact Method has not been selected on the patron's account, the expiration notice will not be sent.
  >
  >With the update, the standard patron messaging preferences can be set for the expiration notice.
  >
  >If the expiration notice is mandatory, but the patron does not have any messaging preferences enabled for that notice, the notice will fall back to the first possible messaging method (depending on available contact information and system settings), in this order:
  >- email
  >- phone
  >- sms
  >- print
- [30319](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30319) Patron self-modification values not retained if field blocked in PatronSelfRegistrationBorrowerUnwantedField (26.11.00,26.05.05)
  >Fixes a problem in patron self-modification where the fields in PatronSelfRegistrationBorrowerUnwantedField were being discarded even when they were visible, and editable, on the patron self-modification page.

  **Sponsored by** *OpenFifth*
- [39589](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39589) Search returns 'No results found' despite existing matching records (26.11.00,26.05.05)
- [41197](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41197) opac/opac-account-pay-return.pl should not require CSRF (26.11.00,26.05.05,25.11.11)
- [42555](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42555) (Bug 25314 follow-up) ID incorrectly used for facet label for customized facets in the OPAC (26.11.00,26.05.01,25.11.06)
  >This fixes the labels for facets in the OPAC. Customized facets generated from mappings.yaml were displayed with the technical type_id instead of the proper label.
  >
  >For example, for a facet defined as "su-gen" with a label of "Genre/Form", "su-gen" was used as the label instead of "Genre/Form".
  >
  >(This is related to Bug 25314 - Make OPAC facets collapse, added to Koha 26.05.00,25.11.04.)
- [42654](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42654) Regression: Section missing from OPAC course reserve detail page (26.11.00,26.05.02,25.11.09)
  >This fixes the course reserves page and navigation in the OPAC so that if a course has a value in the section field, then this value is now shown on the OPAC course detail page after the course name in the page title, breadcrumb, and main heading. 
  >
  >Example: Course reserves for 'Course name' - Section
- [43843](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43843) OPAC JavaScript translations break when the Content-Security-Policy is enabled (26.11.00)
- [43991](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43991) Pickup location change modal is unusable on narrow OPAC screens (26.11.00)
  >Fixed an issue where patrons could not see the change pickup location dialog for holds on mobile devices. The dialog now displays correctly on smaller screens, allowing patrons to change their hold pickup location.
- [43831](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43831) Patron duplicate check matches every new patron when an existing patron is blank in all compared fields (26.11.00,26.05.06)
- [41648](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41648) Incorrect 'update_date' breaks the plugins home page (26.11.00,26.05.05,25.11.11)

  **Sponsored by** *OpenFifth*
- [41819](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41819) Refunds via the Cash registers page should not result in PAYOUTS if the transaction type is 'Account Credit' (26.11.00,26.05.03,25.11.09)
- [43196](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43196) PUT requests with a bad request body to biblios endpoint blanks a record (26.11.00,26.05.05)
  >`PUT /api/v1/biblios/{biblio_id}` now rejects a malformed MARC body (for example invalid JSON) with an error. Previously the request reported success and replaced the record with an empty one.
- [43241](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43241) `q=` parameter bypasses datetime conversion for values nested in DBIC operators (26.11.00)
- [43694](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43694) Koha::REST::V1::to_xml emits child elements in random order, producing schema-invalid XML (26.11.00)
- [42360](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42360) [CVE-2026-70369] SQL Injection in reports/acquisitions_stats.pl via Filter parameter (26.11.00,26.05.01,25.11.06,25.05.12,24.11.17)
- [42361](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42361) [CVE-2026-6428] SQL Injection in reports/catalogue_out.pl via Filter parameter (error-based, triggered when Criteria matches /branchcode/) (26.11.00,26.05.01,25.11.05,25.05.11,24.11.16,22.11.38)
- [42363](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42363) [CVE-2026-70370] SQL Injection in reports/catalogue_stats.pl via the Line request parameter (26.11.00,26.05.01,25.11.06,25.05.12,24.11.17)
- [42368](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42368) [CVE-2026-70371] SQL Injection in reports/issues_avg_stats.pl via the Filter request parameter (unvalidated string context, no placeholders) (26.11.00,26.05.01,25.11.06,25.05.12,24.11.17)
- [42369](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42369) [CVE-2026-70372] SQL Injection in reports/bor_issues_top.pl via the Filter request parameter (unvalidated string context, no placeholders) (26.11.00,26.05.01,25.11.06,25.05.12,24.11.17)
- [42735](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42735) [CVE-2026-70373] SQL Injection in reports/issues_stats.pl via PeriodTypeSel / PeriodDaySel / PeriodMonthSel / Filter parameters (unvalidated string context, no placeholders) (26.11.00,26.05.01,25.11.06,25.05.12,24.11.17)
- [43267](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43267) Batch operations from datatables report view should only send visible results (same as standard view) (26.11.00,26.05.04)
- [42664](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42664) Changes to SIP2 accounts may not applied immediately (26.11.00,26.05.02,25.11.09)
- [42988](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42988) Saving a SIP account imported from SIPconfig.xml can change the holds (Holds get captured -  holds_get_captured) behavior (26.11.00,26.05.03,25.11.10)
- [42485](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42485) Elasticsearch dynamic mapping date detection causes indexing failures with ARRAY MARC format (26.11.00,26.05.01,25.11.07)
- [42669](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42669) es_indexer_daemon.pl silently marks jobs finished on indexing failure and doesn't recover from NoNodes (26.11.00,26.05.03,25.11.09)
  >The Elasticsearch indexer daemon (es_indexer_daemon.pl) was silently marking background indexing jobs as "finished" even when Elasticsearch was unreachable, causing records to disappear from search results with no indication of failure. Additionally, after a brief ES outage (e.g. a Docker restart), the daemon's connection pool would mark the node as dead with exponential backoff, leaving it permanently stuck until manually restarted. The daemon now resets jobs to "new" on NoNodes errors so they are automatically retried once connectivity is restored, recreates the ES client to reset the connection pool, and correctly marks jobs as "failed" for other indexing errors.
- [33276](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33276) Library limitations will cause data loss when editing locations in the subscription form (26.11.00)

  **Sponsored by** *BibLibre*
- [41604](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41604) Impossible to hide Checkin column in issues-table in circ/circulation.pl (26.11.00,26.05.03,25.11.09)
- [42349](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42349) Incorrect filter by recalls (26.11.00,26.05.03,25.11.09)
  >This fixes the holdings table on the record details page. The status column filter now works correctly when selecting the "Recalled" option, and lists recalls placed for a specific item.
  >
  >Previously, the "Recalled" filter did not work and all items for the record were listed instead.
- [42868](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42868) Bookings are storing incorrect timezone values (26.11.00,26.05.03,25.11.09)
  >Fixes bookings being saved with the wrong dates (for example starting a day early) when the library timezone is not UTC. Start and end dates are now calculated in the library's timezone.
- [43429](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43429) Stored XSS via OPAC Report a Problem executes in staff/intranet security context (8.7 HIGH) (26.11.00,26.05.05,25.11.10,25.05.16,24.11.21)
- [43570](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43570) Memory leak in SafeURL and HtmlScrubber Template::Toolkit filters (26.11.00,26.05.05)
- [43782](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43782) GenerateCSRF caches token with global key causing cross-session CSRF 403 errors on Plack workers (26.11.00,26.05.06)
- [43946](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43946) Classes picked for translation in XSLT (26.11.00)
- [43604](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43604) commit_file.pl --revert dies: safe_to_delete calls can_edit_items_from on undef (26.11.00,26.05.06)

#### Other bugs fixed

- [42453](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42453) "About Koha" breaks if Elasticsearch is used but unavailable (26.11.00.26.05.02,25.11.09)
- [42726](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42726) Release team 26.11 (26.11.00,26.05.01,25.11.06,25.05.12,24.11.18)
  >Updates changes to the 25.11 release team, and adds the details of people in the 26.05 release team. (More > About Koha > Koha team.)
- [43177](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43177) Use archived link for Bridge Material Type Icon Set (26.11.00,26.05.04,25.11.10)
  >This updates the link for About Koha > Licenses > Bridge Material Type Icon Set. It now goes to an Internet Archive page with information (including the license), as the original page is no longer available.

  **Sponsored by** *Athens County Public Libraries*
- [44324](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=44324) Release team 27.05
- [42229](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42229) Form label used on non-form elements on opac-memberentry.tt pages (26.11.00,26.05.01,25.11.07)
- [42230](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42230) DataTables search (dt-search) on a patron's OPAC account summary page (opac-user.tt) contains empty label elements (26.11.00)
  >Fixed an accessibility issue on the OPAC account summary page where DataTables search fields contained empty labels. Search fields now display properly labeled, translatable text for screen reader accessibility.
- [42231](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42231) Fix accessibility issues in OPAC summary table (26.11.00,26.05.02,25.11.09)
  >This fixes some accessibility issues on the patron's OPAC summary section: Form elements must have labels.
  >
  >- Checked out "Renew" checkbox: adds a hidden label for screen readers
  >- Add note pop-up window for "Report a problem" (when the AllowCheckoutNotes 
  >  system preference is enabled): adds a hidden label for screen readers
  >
  >It also hides the item title on the report a problem and suspend hold pop-up windows.
- [42232](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42232) Fieldset with missing legend on OPAC account messaging settings page (opac-messaging.tt) (26.11.00,26.05.01,25.11.07)
  >This fixes an accessibility issue on the patron's OPAC account messaging preferences form: Missing legend for the fieldset with submit changes and cancel buttons.
  >
  >It adds a legend tag "visible" for screen reader patrons so that it is clear for the group of buttons what they are being asked to do.
- [42233](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42233) OPAC suggestions table header contains no text (26.11.00,26.05.01,25.11.07)
- [42234](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42234) OPAC checkout history page table header contains no text (26.11.00,26.05.01,25.11.07)
  >This fixes the patron checkout history table in the OPAC. It adds a title to the cover image column ("Cover image").
- [42235](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42235) On OPAC messaging preferences page table header contains no text (26.11.00,26.05.05,25.11.11)
  >This fixes two accessibility issues with the patron's OPAC messaging table (OPAC > [log in] > Your account > Messaging): "Table header text should not be empty".
  >
  >Previously:
  >1. The first column header has no text.
  >2. When responsive table controls were shown for the table, there was no title in the last column header with the controls (a green "+" button is shown when the browser window is narrower and all the columns can't be displayed).
  >
  >Now:
  >1. The first column header now has the text "Message type".
  >2. The responsive table control column header has the text "Expand" when the responsive controls are shown.
- [42299](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42299) OPAC detail page: star ratings has no associated label (26.11.00,26.05.01,25.11.07)
  >This fixes an accessibility issue for star ratings on the OPAC record details page - it adds a label for screen reader patrons.
- [42498](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42498) Accessibility - Page tabs/pagination on results in opac produces accessibility error  "Aria state or property has invalid value" (26.11.00,26.05.01,25.11.06)

  **Sponsored by** *Athens County Public Libraries*
- [32938](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32938) Acquisitions EDI - ORDRSP messages are loaded as invoices (26.11.00,26.05.01)

  **Sponsored by** *OpenFifth*
- [39215](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39215) EDIFACT quote files should skip orders that cannot be processed rather than failing to complete (26.11.00,26.05.06)
  >When an EDIFACT quote file contains a line that cannot be processed, for example an LLO GIR branchcode that does not exist, that line is reported in the EDIFACT messages and skipped, and the other lines are still imported. Previously the whole file failed and the message stayed on "Processing". The message now ends as "received" or "error".
  >
  >**Upgrade notes**
  >- A basket with an unprocessable line is left open rather than automatically ordered, so staff can correct the line and order it manually.

  **Sponsored by** *OpenFifth*
- [41070](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41070) No warning when filling no fund while importing in a basket from a file (26.11.00,26.05.02,25.11.08)
  >This fixes an issue when adding an order to a basket using the "From a new file" option.
  >
  >When adding an order from the staged file there was no warning if you didn't select the fund in either the "Select to import" or "Default accounting details" tabs.
  >
  >Now there is a warning if you don't select a fund: "Some funds are not defined in item records".
- [41709](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41709) GIR segment data should be encoded in EDI ORDERs (26.11.00,26.05.02)

  **Sponsored by** *OpenFifth*
- [41742](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41742) Use of uninitialized value in repeat (x)... warning in acqui-home.pl (26.11.00,26.05.06)
  >Fixes a "Use of uninitialized value in repeat" warning in the Acquisitions error log. Subfunds are again shown with a ">" prefix, and sub-subfunds with ">>", in the fund dropdowns on Acquisitions pages.
- [41803](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41803) Improvements to consistency in basket groups template (26.11.00,26.05.02)
  >This change makes updates to the basket groups template:
  >- Action buttons in the basket group table's "actions" column now 
  >  have the class "btn btn-default btn-xs" (previously they were larger,
  >  yellow buttons, now they are smaller buttons with a light grey
  >  background)
  >- Action buttons now have icons
  >- Export action: there is now a dropdown list of export 
  >  options (CSV and PDF)
  >- Edit and delete actions: now use a class instead of an ID as a hook -
  >  this prevents duplicate element IDs on the page.
  >- Generate EDIFACT order action: when there is no EDIFACT configuration,
  >  the action button is disabled and the error message is in a tooltip.
  >- Warning messages styled as standard Bootstrap alerts

  **Sponsored by** *Athens County Public Libraries*
- [41998](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41998) Some templates in suggestion.pl are computed even through a redirection (26.11.00,26.05.01,25.11.06)
- [42225](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42225) On sites with many vendors spent.pl cannot load (26.11.00,26.05.03,25.11.09)
  >This improves the SQL for the spent by fund report (Acquisitions > [All available funds section of the page]  > [select amount in the spent column for a fund that has a link]).
  >
  >This fixes an issue where there was a VERY large number of vendors in a system (260k + !!!), which resulted in a database error:
  >  ERROR 1038 (HY001): Out of sort memory, consider 
  >  increasing server sort buffer size
- [42571](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42571) Sending EDI order results in variable not available warnings (26.11.00,26.05.03,25.11.09)
- [42645](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42645) ModSuggestion: FallbackToSMSIfNoEmail ignores EmailFieldPrimary/EmailFieldPrecedence (26.11.00,26.05.02)

  **Sponsored by** *OpenFifth*
- [42646](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42646) ModSuggestion: SMS status-change notices always contain email template content (26.11.00)

  **Sponsored by** *OpenFifth*
- [42710](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42710) Purchase suggestion creation form (staff interface) no longer defaults to logged-in library (26.11.00,26.05.01,25.11.06)
  >This fixes entering suggestions using the staff interface. When making a suggestion the default library selected was "Any". The default library is now the current library you are logged in as.
- [42740](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42740) Suggestion status is not kept when editing a suggestion (26.11.00,26.05.01,25.11.06)
- [42750](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42750) Purchase suggestions made from members/purchase-suggestions.pl no longer redirect back (26.11.00,26.05.01,25.11.06)
  >This fixes the redirect when making a suggestion for a patron (Patrons > [Selected patron] > Purchase suggestions).
  >
  >After creating a suggestion, the staff patron is now redirected back to the patron's purchase suggestion page. Previously, they stayed on the list of suggestions on the suggestion management page in acquisitions.
  >
  >(This fixes an error introduced by Bug 39721 - Remove GetSuggestion from C4/Suggestions.pm, added to Koha 26.05 and 25.11.)
- [42757](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42757) Suggester is not passed by purchase-suggestions.pl (26.11.00,26.05.01,25.11.09)
  >This fixes "Suggested by" when making a suggestion for a patron from Patrons > [Selected patron] > Purchase suggestions.
  >
  >"Suggested by" was being recorded as the logged in librarian, instead of the patron that made the suggestion.
- [42789](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42789) EDI ORDRSP: Item and suggestion status not updated when order line cancelled by supplier (26.11.00,26.05.05)
  >When a supplier's EDI order response (ORDRSP) cancels an order line, the order is now cancelled in the same way as a manual cancellation from the acquisitions pages. Items on the order are deleted, where Koha allows it, and a purchase suggestion linked to the order is reverted from ORDERED to ACCEPTED. The cancellation reason and date are recorded on the order.
  >
  >Previously only the order status and cancellation fields were updated, so the items and the suggestion were left unchanged. Biblio records are not deleted.

  **Sponsored by** *OpenFifth*
- [42827](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42827) Items expected column in parcels.pl always displays 0 (26.11.00,26.05.04,25.11.10)
- [42919](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42919) Suggestion duplicate warning erases suggestion info (26.11.00,26.05.03,25.11.07)
- [43034](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43034) t/db_dependent/Koha/EDI.t fails when SearchEngine is Elasticsearch (26.11.00,26.05.03)
- [43053](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43053) Vendor payment methods are not displaying correctly (26.11.00,26.05.04)
  >This fixes issues when adding "Payment methods" to a vendor's record (Acquisitions > Vendors > Ordering information > Payment method). Now values are correctly shown in the dropdown list, and you can add multiple values.
  >
  >Notes:
  >1. The authorized values for VENDOR_PAYMENT_METHOD need a description for it to show in the dropdown list.
  >2. You may need to hard refresh the page for changes and new values to show in the dropdown list on the vendor edit form.
- [43259](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43259) Add to group does not add to group (26.11.00,26.05.06)
  >This fixes adding baskets to basket groups for acquisitions (Acquisitions > [select a vendor] > Basket groups).
  >
  >Before this patch, attempting to "Add to group" or "Remove" a basket to a basket group did not work - nothing happened (and generated a JavaScript error in the browser console).
  >
  >Now, baskets can be successfully added or removed from basket groups.
- [43361](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43361) Invoice item counts increase for every subscription order (26.11.00)
- [43757](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43757) EDIFACT parser drops syntax 4 interchanges silently and dies on a missing UNA (26.11.00)
- [43789](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43789) EDI quote processing dies with undefined to_json when AcquisitionLog is enabled (26.11.00)
- [43790](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43790) EDIFACT messages Import button always runs the invoice importer, even for quotes (26.11.00)
- [43876](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43876) CancelReceipt deletes items with raw SQL: no reindex, no logging (26.11.00)
  >When cancelling the receipt of an order whose basket creates items on receiving, the items are now deleted the same way as other item deletions: the bibliographic record is reindexed (so the items are no longer shown in the search results), the deletion is recorded in the cataloguing log, plugin hooks are called, the holds queue is updated and empty item groups are deleted. As before, the items are not copied to the deleted items table, as they never were part of the collection.
- [36549](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36549) es_indexer_daemon.pl leaks memory (26.11.00,26.05.06)
- [39160](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39160) Mojolicious::Plugin::OAuth2 is loaded suboptimally (26.11.00,26.05.06)
- [39337](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39337) Use SQL field to apply OpacSuppression in OAI-PMH (26.11.00)
  >Records marked for OPAC suppression (942$n) are now correctly hidden from OAI-PMH responses when the `OpacSuppression` system preference is enabled. 
  >
  >Suppression is now applied consistently across the OPAC, REST API, and OAI-PMH, and the `OpacSuppressionByIPRange` system preference is also honoured by OAI-PMH.
  >
  >Previously, suppressed records could still appear in OAI-PMH `ListRecords` and `GetRecord` outputs, leaking catalogue data to harvesters.

  **Sponsored by** *OpenFifth*
- [41605](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41605) Fix incorrect default value keys in Vue (26.11.00,26.05.01)
  >Internal Vue fix: the default value for boolean fields in the record sources resource is now declared as `defaultValue`, the key the framework checks. Boolean fields already default to false, so there is no change in behaviour.
- [41681](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41681) bulkmarcimport.pl reports an incorrect number of MARC records processed (26.11.00,26.05.04,25.11.10)
- [42471](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42471) [CVE-2026-41921] /cgi-bin/koha/suggestion/suggestion.pl Multiple Parameters Stored Cross-Site Scripting (26.11.00,26.05.02,25.11.07,25.05.13)
- [42551](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42551) C3 merge error when syntax checking some installed plugins (26.11.00,26.05.03,25.11.09)
- [42800](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42800) Potential XSS in shelf list in the erm module (26.11.00,26.05.03,25.11.08,25.05.14,24.11.19)
- [42802](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42802) kohastructure.sql needs adjustments for mariadb 12.3 (26.11.00,26.05.02)
- [42866](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42866) SQL Injection in Koha/AdditionalContents.pm search_for_display via the patron lang value (stored / second-order, executed on issue-slip print, unvalidated string context, no placeholder) (26.11.00,26.05.02,25.11.07,25.05.13,24.11.18)
- [42904](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42904) Prevent XSS in patron restriction comments (26.11.00,26.05.03,25.11.08,25.05.14,24.11.19)
- [42924](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42924) Restore default MaxAge for CSRF token (26.11.00,26.05.05)
- [42993](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42993) Koha::Edifact::Transport should log transport failures via Koha::Logger (26.11.00,26.05.06)
- [43078](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43078) File transport SFTP backend returns inconsistent list() structure compared to FTP/Local backends (26.11.00,26.05.04,25.11.10)
- [43088](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43088) Koha::File::Transport lacks a consistent current_directory() accessor across FTP/SFTP/Local (26.11.00,26.05.04)
- [43091](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43091) Staff-only Vue island chunks are emitted into the OPAC dist directory (26.11.00,26.05.04)
- [43092](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43092) Koha::File::Transport::change_directory(undef) means three different things across FTP, SFTP and Local (26.11.00,26.05.05)
- [43101](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43101) search_for_data_inconsistencies.pl creates a query that ORs every biblionumber in the catalog (26.11.00,26.05.03,25.11.10)
  >This fixes the search for data inconsistencies script (misc/maintenance/search_for_data_inconsistencies.pl) so that it now runs significantly faster - it replaces OR with IN for subqueries.
  >
  >Technical details:
  >
  >1. Queries that use OR instead of IN are less efficient and can lead to situations where the query takes a very long time to complete due to row level scanning. Example: We found one instance where they query had been running for over 10 days!
  >
  >2. This fix makes ids() return a subquery instead of a list of results, and switches the callers to using IN. The database now resolves the set itself and the queries stay a constant size no matter how large the catalog is. This is super efficient because the subquery doesn't even execute as a separate query since biblionumber is the primary key!
- [43102](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43102) Koha::Items filters inline every itemnumber of the set as an OR chain (26.11.00)
- [43103](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43103) Batch item modification and patron deletion query IDs as OR query chains (26.11.00,26.05.04)
- [43159](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43159) Regression to @INC handling by bug 39740 undoing bug 25778 (26.11.00,26.05.04,25.11.10)
- [43168](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43168) Incorrect error output when staging a file (26.11.00,26.05.04,25.11.10)
- [43326](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43326) Stored XSS in patron account note (accountlines.note) (26.11.00,26.05.04,25.11.09,25.05.15,24.11.20)
- [43426](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43426) admin/item_circulation_alerts.pl cud-toggle performs no authentication check at all (7.5 HIGH) (26.11.00,26.05.04,25.11.09,25.05.15,24.11.20)
- [43438](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43438) All Vue datatables export the actions column (26.11.00)
  >This fixes the data that is exported from Vue-based modules (such as ERM, Preservation, Acquisitions - Vendors, and record sources) so that the action column options are not exported (such as Edit and Delete).
- [43470](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43470) REST Basic Auth allows silent 2FA secret takeover (26.11.00,26.05.04,25.11.09,25.05.15,24.11.20)
- [43513](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43513) Add .mailmap entries for Lawrence O'Regan-Lloyd (26.11.00,26.05.06)
- [43523](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43523) Initial patron lookup in cleanborrowers.pl is slow (26.11.00,26.05.06)
- [43805](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43805) Logging back in after a session timeout 404s on Vue pages served through a RewriteRule (record_sources, circulation_triggers) (26.11.00)
- [43832](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43832) Default CSP external cover images on the OPAC (26.11.00)
- [44150](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=44150) CGI::param called in list context from acqui/addorderiso2709.pl line 232 (26.11.00)
- [44182](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=44182) CGI::param called in list context from suggestion/suggestion.pl line 105/106 (26.11.00)
- [32542](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32542) Coce images not appearing in staff interface (26.11.00,26.05.06)
- [38196](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38196) Filter out concerns by specific status does not include concern without status (26.11.00)
  >This fixes the filters on the staff interface catalog concerns page so that it now "works as expected" (Cataloging > Reports > Catalog concerns, or "Cataloging concerns pending: X" on the staff interface home page).
  >
  >Before this fix, the filters weren't including concerns with no status assigned.
  >
  >How the filters now work:
  >
  >1. There is a "Hide resolved" (default) filter (with "Include resolved" as its inverse). When first accessing the catalog concerns page, all catalog concerns are shown:
  >   - clicking "Hide resolved":
  >     - Hides resolved concerns
  >     - Shows all other concerns, including those with no status assigned
  >   - clicking the inverse "Include resolved" shows all concerns regardless of status
  >   - the label was changed from "Filter resolved" to "Hide resolved"
  >
  >2. There are also filters for all the status codes defined using the TICKET_STATUS authorized value category: 
  >   - the filters are now labelled "Hide [status description]" (the inverse is "Include [status description]"), instead of "Filter [status description]"
  >   - clicking the filter for a status hides the concerns with that status
  >   - to show all the concerns, click "Include [status description]"
  >
  >The renaming should make it clearer what the filters do.
  >
  >A separate bug also was created to look at options to make the filters work similar to other filters in other areas, as the behavour on the catalog concerns page is quite different from filters used elsewhere in Koha.
- [39909](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39909) Batch modification with regex does not work with control fields (26.11.00,26.05.06)
- [40225](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40225) The --send-all option in the stockrotation job fails if there are no items to rotate at all (26.11.00,26.05.02,25.11.08)
- [41829](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41829) Tag editor button has wrong id on copied MARC field when value builder plugin is used (26.11.00,26.05.01)

  **Sponsored by** *Koha-Suomi Oy*
- [41987](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41987) addbooks.tt has duplicate IDs searchresult-breeding (26.11.00,26.05.01,25.11.07)
- [42166](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42166) Cannot Edit as new (duplicate) a record without a 008 in the advanced editor (26.11.00,26.05.03,25.11.10)
- [42178](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42178) The Close button submits the remove from bundle form (26.11.00,26.05.01,25.11.07)

  **Sponsored by** *Lund University Library*
- [42512](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42512) MARC control field length detection prevents editing of records with invalid MARCXML (26.11.00,26.05.03,25.11.09)
- [42531](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42531) Repeatable field values with long text do not wrap on staff record detail page (26.11.00,26.05.02,25.11.08)
- [42612](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42612) "Import this batch into the catalog" button has useless class (26.11.00,26.05.01)
- [42701](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42701) Ability to click anywhere in item row for edit and delete options is missing (26.11.00,26.05.01,25.11.06)
- [42846](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42846) Koha::Database::DataInconsistency typo for biblioitemnumber in MARC (26.11.00,26.05.02,25.11.08)
- [42874](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42874) z3950_auth_search is losing index parameter (26.11.00,26.05.03,25.11.09)
- [42968](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42968) Show Contents label for 505 fields with blank indicator
  >The staff interface and OPAC display a label for MARC21 505 formatted contents notes based on the first indicator:
  >
  >- 0 = Contents:
  >- 1 = Incomplete contents:
  >- 2 = Partial contents:
  >
  >However, when the 505 first indicator is blank, no label was displayed before the contents note. This makes the contents note less clear, especially for records where libraries have entered 505 data without indicators.
  >
  >Now, when the 505 first indicator is blank, Koha shows a fallback "Contents:" label.
- [42975](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42975) Patron category filters broken in Record overlay rules (26.11.00)
- [43024](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43024) A couple of lower-traffic paths don't guard against undecodable MARC either (26.11.00)

  **Sponsored by** *OpenFifth*
- [43206](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43206) cn_browser plugin red background on exact match is hard to read (26.11.00,26.05.03,25.11.10)

  **Sponsored by** *Athens County Public Libraries*
- [43239](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43239) Serial items item type can be set incorrectly when receiving multiple items (26.11.00,26.05.05,25.11.11)
  >This fixes the item type created for serials, when item records are created for subscriptions.
  >
  >Explanation:
  >
  >It is possible to create subscription item records with the wrong
  >item type if:
  >- the makePreviousSerialAvailablesystem preference is enabled, and 
  >- there is no value selected for the "Item type for older issues" field.
  >
  >In installations where item types differ between items and records, this causes data inconsistencies and leads to errors in a record's holdings table.
  >
  >This fix changes the behaviour of the serials subscription form so that if
  >makePreviousSerialAvailable is enabled and a subscription's "Item type for older issues" field is empty/not selected, the previous item type value is kept for item records. It also adds a hint text to the subscription form about this change.

  **Sponsored by** *Koha-Suomi Oy*
- [43430](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43430) Advanced editor omits a missing mandatory 008 when editing a record (26.11.00)
- [43650](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43650) incremental EAN-13 barcodes produce unexpected sequence (26.11.00,26.05.06)
- [44069](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=44069) svc/bib still calls removed record_strip_nonxml and no longer reports repaired records (26.11.00)

  **Sponsored by** *OpenFifth*
- [36762](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36762) Item not transferred correctly when there is a pending hold (26.11.00,26.05.03,25.11.10)
  >This fixes two issues when transferring an item that could fill a pending hold to a library that is not the holds pickup library:
  >1. Koha only gives you an option to transfer the item to the pickup library. When this option is chosen, Koha says that item is being transferred to the selected library, not to the pickup library. Then it fails to create the transfer.
  >2. Adds a new option ("Ignore hold and transfer to [Library name]") to ignore the hold and transfer the item to the library selected in the transfer tool.

  **Sponsored by** *Koha-Suomi Oy*
- [38122](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38122) Cannot sort holdings table by status (26.11.00)
  >This restores the "Group by status" option to the holdings table for a record in the staff interface (after the Show filters, Select all, and Clear all options).
  >
  >Clicking "Group by status" sorts the items by the status column.^
  >
  >Clicking "Ungroup by status" resets the holdings table.
  >
  >In combination with the filters option this provides several ways for staff to quickly scan and organize the items by status.
  >
  >+ Order for grouping items is:
  >
  >* Available (available)
  >* Checked out (checked_out)
  >* Local use (local_use)
  >* In transit (in_transit)
  >* Lost (lost)
  >* Withdrawn (withdrawn)
  >* Damaged (damaged)
  >* Not for loan (not_for_loan)
  >* On hold (on_hold)
  >* Recalled (recalled)
  >* In bundle (in_bundle)
  >* Restricted (restricted)
- [40206](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40206) Curbside pickups - Layout wrong when 'CircSidebar' enabled (26.11.00)
- [41358](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41358) action logs info column should always store JSON (26.11.00,26.05.03,25.11.09)

  **Sponsored by** *OpenFifth*
- [41445](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41445) Wrong info about holds selection after hold suspending (26.11.00,26.05.06)
  >This fixes the holds table for a patron after a single hold is suspended (in the "Check out" and "Details" section for a patron record in the staff interface).
  >
  >After suspending a hold, no holds are selected in the holds table.
  >
  >Previously, after suspending a hold:
  >- The tick box in table header (the first column) was selected
  >- There was no tick in any of the tick boxes for individual
  >  holds
  >- The count at the bottom for "holds selected" was the total
  >  number of holds
  >- The action buttons were active ("Cancel selected" and "Suspend selected")

  **Sponsored by** *Cape Libraries Automated Materials Sharing*
- [41705](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41705) Popup blockers may be triggered by options to automatically display payment receipt for printing after making a payments (26.11.00,26.05.01,25.11.06)

  **Sponsored by** *OpenFifth*
- [41889](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41889) /checkouts?checked_in=1 errors when patron_id is null (26.11.00,26.05.02,25.11.09,25.11.09)
- [41898](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41898) Expired bookings do not display when expired filter is used in patron record (26.11.00)

  **Sponsored by** *OpenFifth* and *Westminster City Council*
- [41992](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41992) Checkout History remembering Last Page (26.11.00,26.05.01,25.11.07)
- [42454](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42454) Terminology: Use "and" instead of "&" for curbside pickups "Staged & ready (0)" tab (26.11.00,26.05.01,25.11.06)
  >This fixes the "Staged & ready (0)" tab for curbside pickups (Circulation > Holds and bookings > Curbside pickup) so that it uses "and" instead of "&" in the table title, as per the terminology guidelines (when CurbsidePickup is enabled).
- [42505](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42505) Hold transfer slip popup blocked by browser after 'Print slip and confirm' is clicked on hold-found modal (26.11.00,26.05.06)

  **Sponsored by** *OpenFifth*
- [42565](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42565) GetIssuingCharges returns undef when rentalcharge is NULL (26.11.00,26.05.04,25.11.10)
- [42659](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42659) Multiple numbers and parts shown incorrectly on checkin screen (26.11.00,26.05.02,25.11.08)
- [42697](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42697) Home library and current library filters can filter incorrectly (26.11.00,26.05.05)
- [42875](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42875) Wrong failure message when adding an item to a bundle (26.11.00)
  >This fixes the error message when adding an item to a bundle, where the item is currently checked out:
  >- Incorrect error message: "Failure: Item '[barcode]' belongs to another bundle"
  >- Correct error message: "Failure: Bundle is currently checked out"
- [42930](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42930) Overdues (circ/overdue.pl) incorrectly shows bibliographic record title in patron column instead of the patron's title (salutation) (26.11.00,26.05.03,25.11.08)
  >This fixes the information shown in the overdues report patron column (Circulation > Overdues > Overdues). The bibliographic record title was shown before the patron's name, instead of the patron's title (salutation).
  >
  >(Related to bug 41343 - Overdue report is too intensive on systems with many overdues, added to Koha 26.05 and 25.11.)
- [43001](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43001) Non priority hold label doesn't always appear on the staff interface holds page for a record (reserve/request.pl) (26.11.00,26.05.03)
  >This fixes the holds page in the staff interface for a record. When placing a non priority hold ("Non priority hold" option selected), "Non priority hold" text (in italics) was not showing in the details column for the hold.
- [43119](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43119) Checkout and hold action logs are not displayed correctly (26.11.00,26.05.04,25.11.10)
- [43225](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43225) Renewal confirmation message formatting is missing punctuation and space (26.11.00)
  >This fixes the punctuation for a renewal confirmation message (when the AllowFineOverrideRenewing system preference is set to "Allow").
  >
  >The previous message was: "The patron has a debt of [amount]Are you sure you want to renew checkout(s)?"
  >
  >The message is now: "The patron has a debt of [amount]. Are you sure you want to renew checkout(s)?"
- [43247](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43247) Transfer reason doesn't show in Checked-in items table for float limit transfers (26.11.00)
- [43346](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43346) MarkLostItemsAsReturned does not work without userenv set (26.11.00,26.05.06)
- [43769](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43769) existing_holds table search/filter by pickup library is broken on request.tt (26.11.00,26.05.06)
  >Fixes a problem with DataTables searching where partial matches could not be searched for.
- [43771](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43771) Override ability for "no renewal before" part of AllowRenewalLimitOverride is not working from patron accounts unless another block exists (26.11.00,26.05.06)

  **Sponsored by** *Koha-Suomi Oy*
- [43803](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43803) Confirming a hold at checkin can set the hold to waiting on an item that has been checked out again (item ends up both on loan and waiting) (26.11.00,26.05.06)
- [43866](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43866) Patron name and card number should not be clickable in remaining 'Checking out to' headings (26.11.00)
  >This fixes the "Checking out to [patron name (patron number)]" messages to remove the link for the patron name and card number for the:
  >- checkout page when a patron can't check out (for example, when they have restrictions)
  >- batch check out page.
  >
  >(The standard check out page was fixed in Bug 43220 - Patron name and card number should not be clickable in headings.)
- [43879](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43879) AddReturn does not reindex the record when a withdrawn item blocks the return after clearing onloan (26.11.00)
  >When checking in an item that is not checked out but still has a due date set (inconsistent data), and the return is blocked because the item is withdrawn (BlockReturnOfWithdrawnItems), the record is now reindexed. Previously, the due date was cleared in the database but not in the search index, so the search results kept showing the item as checked out.
- [43887](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43887) Checkout warning block has empty id instead of circmessages (26.11.00)
  >This fixes the patron checkout page when a patron can't checkout items (for example, when they have a restriction). The "Cannot check out!" block is now correctly styled and has:
  >- an id="circmessages" (the id was missing for the div)
  >- padding
  >- bottom margin
  >- a white background (blended into the background before the fix)
- [43894](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43894) AddIssue stores UpdateNotForLoanStatusOnCheckout after enqueuing the record reindex (26.11.00)
  >When an item is checked out and UpdateNotForLoanStatusOnCheckout changes its not for loan status, the new status is now saved together with the checkout, before the record is reindexed. Previously, the status was saved in a second step after the reindex was queued, so the search results could keep showing the old status (for example "Ordered") after the checkout.
- [44030](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=44030) FineNoRenewalsBlockAutoRenew set to "allow" no longer allows automatic renewals (26.11.00)

  **Sponsored by** *Koha Solutions*
- [44211](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=44211) Holds to pull library filter fails when library name contains an ampersand (26.11.00)
- [35061](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35061) Fix documentation for --preserve-field in import_patrons.pl (26.11.00,26.05.05,25.11.11)
- [35948](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35948) cleanup_database.pl should remove not only finished background jobs (26.11.00,26.05.03)
- [39208](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39208) printoverdues.sh requires unavailable cli tool xhtml2pdf (26.11.00,26.05.03)
- [42298](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42298) "No automatic renewal before" falls back to "No renewal before" if former is greater than the latter (26.11.00,26.05.04,25.11.10)
- [42640](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42640) Script search_for_data_inconsistencies.pl should use binmode UTF-8 (26.11.00,26.05.02,25.11.09)
- [42861](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42861) System warning about missing encryption_key on a fresh instance (26.11.00,26.05.03,25.11.10)
  >This fixes the koha-create command so that it generates the random encryption key required for passwords and sensitive data.
  >
  >It uses pwgen with the number of characters set to 32, and adds the <encryption_key> entry to the instance's koha-conf.xml file.
- [43799](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43799) cart_to_shelf cron waits an extra hour to update items (26.11.00,26.05.06)
- [43813](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43813) Remove To Do from runreport.pl (26.11.00,26.05.06)
- [42013](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42013) Confirmation dialog for "Remove all reserves" never shown on course details page (26.11.00,26.05.06)
- [42130](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42130) Holdings created in ERM with a linked bibliographic record does not index the record (26.11.00,26.05.01,25.11.06,25.05.12,24.11.18)
  >This fixes indexing of records, so that when a new title is added in the ERM module (ERM > eHoldings > Local > Titles) and 'Create bibliographic record' is selected, the new record can be found when searching.
- [42522](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42522) Holdings created in ERM with a linked bibliographic record do not show the link to the record (26.11.00,26.05.03,25.11.10)
- [42825](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42825) ERM Local Title - Start date (started_on) not saved for package resources (26.11.00,26.05.02,25.11.09)
  >This fixes adding a title to a package when creating a new title for ERM - the start date for the title was not saved (ERM > eHoldings > Titles > New title > Packages > Add new package).
- [42933](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42933) ERM - Error adding a license to an agreement when leaving non-mandatory fields empty (26.11.00,26.05.03,25.11.09)
  >This fixes an issue for the ERM module when adding a license to an agreement. The status field for the license was not shown as required. This generated an error message if you attempted to add a license without selecting a value for the status field: "Something went wrong: Error: Expected string - got null.". The status field is now marked as required.
  >
  >(Related to Bug 38201 - VueJS architecture rethink, added to Koha 25.11.)
- [42981](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42981) ERM package result list hangs when filtering by vendor and search status is saved (26.11.00,26.05.03,25.11.10)
- [26540](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26540) Server error when attempting to issue cash credit with UseCashRegisters (26.11.00)
  >Cash payouts and refunds are now only offered when the library has a cash register. This fixes the server error when issuing a cash credit with `UseCashRegisters` enabled. Without a register, the payout and refund forms show a message asking for a cash register to be added, instead of the Cash payment type and register selection.
  >
  >**Upgrade notes**
  >- With `UseCashRegisters` enabled, Cash is no longer offered for payouts and refunds at libraries that have no cash register. Add a cash register for the library to offer it again.
- [43910](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43910) Cash payout throws a 500 error when no cash register is selected (26.11.00)
- [33364](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33364) Stop holds to pull report showing items that have been allocated to a recall (26.11.00,26.05.03,25.11.10)
  >This fixes the "Holds to pull" circulation report to exclude items that have pending recalls (recalled items waiting for pickup or in transit for a patron).

  **Sponsored by** *Catalyst*
- [39419](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39419) Holds API treats 'expiration_date' as 'patron_expiration_date' (26.11.00,26.05.06)

  **Sponsored by** *Cape Libraries Automated Materials Sharing*
- [41227](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41227) SuspendHoldsIntranet have no effect (26.11.00,26.05.03,25.11.10)
- [41879](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41879) Holds that move to a new bib can be unfillable (26.11.00,26.05.03,25.11.10)
- [42357](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42357) Holds table is missing patron name (26.11.00,26.05.02,25.11.09)
  >This fixes the holds table for a bibliographic record in the staff interface. It now shows the patron's name in addition to the patron's card number.
  >
  >(Use existing system HidePatronName system preference to hide patron names, for example for privacy reasons at circulation desks.)
- [42395](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42395) Missing translations for the existing holds table (load_patron_holds_table) for a record in the staff interface (26.11.00,26.05.01,25.11.07)
  >This fixes the translatability of strings for the existing holds table in the staff interface for a record (Staff interface > [details page for a record] > Holds > Existing holds).
  >
  >These strings were not previously translated:
  >- Priority column: In transit, Waiting, and In processing
  >- Change priority column: tooltip text for arrows:
  >  . Move hold up
  >  . Move hold to top
  >  . Move hold to bottom
  >  . Move hold down

  **Sponsored by** *Koha-Suomi Oy*
- [42722](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42722) Improve invalidPickupBranch error message (26.11.00,26.05.06)
- [42909](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42909) Suspend class missing from suspended holds on request.pl (26.11.00,26.05.02,25.11.09)
  >This fixes the holds table for a record in the staff interface to restore the "suspend" class to the table row for suspended holds, allowing styling by libraries.
- [43448](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43448) Unreachable code in reserve/request.pl (26.11.00,26.05.06)
- [43634](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43634) cancelBulk in waitingreserves.pl is not protected against CSRF attacks (26.11.00,26.05.05,25.11.10,25.05.16,24.11.21)
- [43996](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43996) Holds tab count is not updated after cancelling holds in the patron holds table (26.11.00)
- [38358](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38358) To date-calendarbox don't follow when you are editing holidays (26.11.00)

  **Sponsored by** *Koha-Suomi Oy*
- [42741](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42741) Plural strings don't apply in list content column (26.11.00,26.05.01)
- [43260](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43260) Debug options in navigation bar untranslatable (26.11.00,26.05.05)
  >This fixes the "Debug controls" options in the staff interface so that they are translatable. It also changes the options to sentence case, as per the coding guidelines.
  >
  >The debug controls menu that is shown in the top right-hand side of the top menu in the staff interface (only shows if the staff patron has "Display the debug interface (debug)" permissions) - options are now in sentence case:
  >- Disable custom CSS
  >- Disable custom JS
  >- Disable custom stylesheets

  **Sponsored by** *Athens County Public Libraries*
- [43849](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43849) Add context for translation of "Editor" (26.11.00)
- [43933](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43933) When a list exists, lists page does not load in Hindi (26.11.00)
- [43935](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43935) data-confirmation-msg not translatable (26.11.00)
- [43942](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43942) Untranslatable actions on vendor (again) (26.11.00)
- [44097](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=44097) Patron search "starting with" and "containing" untranslatable (26.11.00)
- [42397](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42397) ILL batches logged under 'ILL' action_logs modulename cause conflict with ILL requests (26.11.00,26.05.02)
  >This fixes an issue where ILL batch activity was incorrectly mixed with ILL request logs, causing a 500 error when viewing affected ILL requests.
  >
  >It also adds "Interlibrary loan batches" as a module to the log viewer.
- [42582](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42582) Uncaught TypeError on Place request with partner libraries when no z39.50 service is set (26.11.00,26.05.02,25.11.08)
- [42617](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42617) ILL availability pagination not working (26.11.00,26.05.03,25.11.09)
- [42653](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42653) ILL request with log entries from multiple backends causes 500 error (26.11.00,26.05.06)
- [42845](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42845) Access to ILL requires parameters => 'manage_sysprefs' (26.11.00,26.05.04)
- [43204](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43204) ILL availability search: Source column links to plain OPAC URL instead of the deep link (26.11.00,26.05.05,25.11.11)
- [43354](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43354) ILL request table search returns a 500 error (26.11.00,26.05.05)
  >This fixes the ILL requests history table for a patron, so that a search doesn't result in a 500 error (Patrons > [selected patron] > ILL requests history > Search [filter above the table]).
- [43696](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43696) ISO 18626 date-times are not UTC (26.11.00)
- [43809](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43809) illreq_created statistic is not recorded for ILL requests created by plugin backends (26.11.00)
- [42850](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42850) ILL requests stylesheet is not installed (26.11.00,26.05.03,25.11.08,25.05.16)
- [43192](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43192) Lists cannot be deleted from OPAC (26.11.00,26.05.04,25.11.10)

  **Sponsored by** *Athens County Public Libraries*
- [42920](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42920) Looking up authority records in Advanced editor appends 20 extra spaces (26.11.00,26.05.03,25.11.09)

  **Sponsored by** *Chetco Community Public Library*
- [43665](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43665) Fix HTML entities in fields filled by marc21_linking_section.pl (26.11.00,26.05.06)

  **Sponsored by** *BibLibre*
- [42194](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42194) Sharing a report to Mana does not give feedback (26.11.00,26.05.01,25.11.06)
- [38621](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38621) [% today %] variable unavailable in report templates (26.11.00)

  **Sponsored by** *OpenFifth*
- [41602](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41602) Cannot combine filters with holds status filters (26.11.00)
  >Fixes a '500 error' when using multiple filters for the holdings table for a record in the staff interface.
- [43288](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43288) Change amount missing from printed fee receipts (change_given/change param mismatch) (26.11.00,26.05.06)
  >This fixes pop-up printable payment receipts for payments made by patrons (when the FinePaymentAutoPopup system preference is set to "Do").
  >
  >If change is given for a payment, the line "Change given" on the printable receipt was missing.
- [43342](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43342) Default OVERDUES_SLIP contains empty lines (26.11.00,26.05.05,25.11.11)
- [43380](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43380) Koha will generate spurious print notices if itiva is enabled and a patron has only selected phone notices (26.11.00,26.05.06)
- [43738](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43738) Notice module "Reports" label is unclear (26.11.00,26.05.06)
- [43740](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43740) Notice module "Patrons (custom slip)" is sometimes "Patron (custom slip)" (26.11.00,26.05.06)
- [20846](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20846) Suppressed records still appear in public lists (26.11.00,26.05.05,25.11.11)
- [38361](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38361) Gender field does not include a Required if the field is set to required in  PatronSelfRegistrationBorrowerMandatoryField (26.11.00,26.05.04,25.11.10,25.11.10)
  >This fixes the gender field for the patron self-registration form so that if it is marked as mandatory using the PatronSelfRegistrationBorrowerMandatoryField system preference, the form shows the field as "Required".
  >
  >It also replaces the radio buttons with a dropdown menu.
- [40799](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40799) Loading spinner not removed because .cover-slider is now used instead of .cover-slides (26.11.00,26.05.05,25.11.11)
  >This fixes the display of cover images on detail pages in the OPAC. For cover images with a shorter height, the loading spinner indicating that the image is currently loading was still shown after the image is loaded.
- [41706](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41706) "Use of uninitialized value..." warning in C4/Record.pm (26.11.00,26.05.05,25.11.11)
  >Removes the cause of "[WARN] Use of uninitialized value $2 in split at /kohadevbox/koha/C4/Record.pm line 924." warnings from the plack-opac-error.log when viewing record detail pages in the OPAC. This was related to the Cite feature.

  **Sponsored by** *Ignatianum University in Cracow*
- [41796](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41796) "Forgot your password" link is not visible if OpacResetPassword is enabled but OpacPasswordChange is disabled (26.11.00,26.05.03,25.11.09)
- [41982](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41982) Linked items resulting from EasyAnalyticalRecords are not shown on OPAC results page (26.11.00,26.05.06)

  **Sponsored by** *Pontificia Università di San Tommaso d'Aquino (Angelicum)*
- [41988](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41988) OPAC: News RSS links with HTML not working (26.11.00,26.05.03,25.11.10)
- [42066](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42066) CSRF-token sometimes missing from pages (26.11.00,26.05.03,25.11.09)
- [42159](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42159) With OPACAuthorIdentifiersAndInformation information lacking from field 110/111 (26.11.00,26.05.02,25.11.09)
  >This fixes the "Author information" tab in the OPAC details page so that it now shows information from authority records where:
  >- the authority record 024 has identifier data, and
  >- the identifiers option is selected for the OPACAuthorIdentifiersAndInformation system preference.
  >
  >The "Author information" tab now shows the authority record information where it is used in a bibliographic record's 110 (Corporate name) and 111 (Meeting name).
- [42172](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42172) With OPACAuthorIdentifiersAndInformation show whole heading, not only $a (26.11.00)
- [42193](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42193) The "Suspend hold" modal in the OPAC sometimes tries to resume hold (26.11.00,26.05.01,25.11.06)
- [42202](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42202) IndependentBranches shouldn't filter public libaries in OPAC search, news, and most popular (26.11.00,26.05.02,25.11.08)
  >This fixes the OPAC library location filtering for logged in patrons when IndependentBranches is used.
  >
  >Logged in patrons now see the same options for library locations as unauthenticated patrons, for example:
  >- Library pulldown for "All libraries" for the main search (OpacAddMastheadLibraryPulldown system preference)
  >- Advanced search "Location and availability" option 
  >- Most popular from filter (OpacTopissue system preference)
  >- News selector (OpacNewsLibrarySelect system preference)
  >
  >Previously, the library location options were not shown when a patron was logged in. This made no sense, as unauthenticated user can see all the libraries. (A logged in patron could also do a search and then filter by any library location.)
- [42274](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42274) opac-tags.pl should return JSON instead of JS script (26.11.00,26.05.06)
- [42579](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42579) Checkout history export "title" column too long (26.11.00,26.05.03)
- [42634](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42634) Self-checkout Finish/logout does not reliably clear the JWT cookie (26.11.00,26.05.05,25.11.11)

  **Sponsored by** *OpenFifth*
- [42721](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42721) Update OPACAuthorIdentifiersAndInformation description and identifier labels shown in the OPAC (26.11.00)
  >This fixes the OPACAuthorIdentifiersAndInformation system preference description so that identifiers are listed in alphabetical order.
  >
  >It also updates the identifier labels in the system preference description and what is shown in the OPAC:
  >- ScopusID --> Scopus ID
  >- WIKIDATA ID --> Wikidata ID
- [42912](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42912) Javascript error on opac-readingrecord when no Circulation history (26.11.00,26.05.03,25.11.09)
- [43134](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43134) Standardize use of colon in OPAC advanced search page (26.11.00,26.05.04)
  >This fixes OPAC advanced search option headings to add missing colons (for consistency).
- [43229](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43229) Purchase suggestions incorrectly promises an email confirmation for anonymous suggestions (26.11.00,26.05.06)
  >On the OPAC purchase suggestion form, a patron who is not logged in is now told to log in if they want an email when the library processes their suggestion. A logged-in patron is told that they will receive that email. The log-in prompt is shown only when `opacuserlogin` is enabled.
- [43237](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43237) 'Expand' column header doesn't appear consistently for collapsed responsive tables in the OPAC (26.11.00,26.05.06)

  **Sponsored by** *Athens County Public Libraries*
- [43311](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43311) Make opac-memberentry.tt set CSRF header (26.11.00,26.05.06)
  >On the OPAC, changing "Allow guarantor to see checkouts" under Your account > Personal details now saves without a 403 error.
- [43312](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43312) Make opac-user.tt set the CSRF header for article request cancellation (26.11.00,26.05.06)
  >On the OPAC, cancelling an article request from Your account no longer fails with a 403 error.
- [43344](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43344) OPAC does not show the On order item status when acquisition details are enabled (26.11.00,26.05.06)
- [43347](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43347) Simple OPAC search with no results generates warnings: Odd number of elements in anonymous hash (26.11.00)
- [43519](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43519) Direct links to article request form still work when the feature is disabled (26.11.00,26.05.06)

  **Sponsored by** *Athens County Public Libraries*
- [43540](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43540) Switching OPAC language loses /bib/<id> short URLs, redirects to homepage (26.11.00,26.05.06)
- [43710](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43710) OPAC self-registration crashes with a 500 error when ExtendedPatronAttributes is disabled and a patron attribute type is mandatory (26.11.00)
  >OPAC self-registration no longer fails with an error 500 when ExtendedPatronAttributes is disabled and a patron attribute type is mandatory and editable in the OPAC. The patron attributes are now only saved when ExtendedPatronAttributes is enabled, as in the staff interface.
- [43732](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43732) koha-create doesn't output a message about enabling email (26.11.00,26.05.06)
- [43734](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43734) koha-create requires --create-db despite the documentation saying it's the default (26.11.00,26.05.06)
- [20573](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20573) Patron receives membership expiry notice but 'will expire soon' alert doesn't show for staff at checkout (26.11.00,26.05.04,25.11.10)
  >This fixes a bug that caused the system preferences MembershipExpiryDaysNotice and NotifyBorrowerDeparture to behave differently when set to the same value.
  >
  >For example, if MembershipExpiryDaysNotice and NotifyBorrowerDeparture are both set to trigger 30 days before the patron account expiration date:
  >- MembershipExpiryDaysNotice would cause an account expiry notice to be sent exactly 30 days before the account expiration date; 
  >- however, NotifyBorrowerDeparture would not begin showing an alert on the patron account until the next day.
  >
  >This fixes the timing on NotifyBorrowerDeparture so that it begins displaying the alert exactly the chosen number of days before the account expires. That way, if MembershipExpiryDaysNotice and NotifyBorrowerDeparture are set to the same value, they will both trigger on the same day.
- [41946](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41946) Superlibrarian should be able to set protected status on patron creation (26.11.00,26.05.03,25.11.09)
- [42018](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42018) Inconsistent behavior for null values for fields selected in PatronDuplicateMatchingAddFields (26.11.00,26.05.05,25.11.10)
- [42161](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42161) Non-mandatory patron attribute type does not appear in members-update.pl (26.11.00)

  **Sponsored by** *OpenFifth*
- [42245](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42245) Patron search for guarantors is preselecting borrower sort values from the borrower record (26.11.00,26.05.01,25.11.07)
  >This fixes the "Add guarantor" pop-up window when adding a guarantor for a patron.
  >
  >The form was populating the "Sort 2" field with the value from the patron you are adding the guarantor to (if they had values stored for the Sort 1 and Sort 2 fields in the library management section).
- [42611](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42611) Javascript error on readingrec.pl when no reading history (26.11.00,26.05.02)
- [42650](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42650) Icon for self-check user permission should not appear for a superlibrarian (26.11.00)
- [42781](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42781) Declare 'name' before using it in patron-format.js (26.11.00,26.05.01,25.11.07)
- [43005](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43005) Regression: Changing category from details page section doesn't trigger expiration update (26.11.00,26.05.04,25.11.10)
  >This fixes a regression where editing a patron's record from the "Library use" section didn't show the pop-up window if the patron category is changed (prompting to reset expiration date and messaging preferences to the patron category defaults). 
  >
  >(Note: changing the patron category when editing a complete patron record was not affected, it was only not appearing when editing a patron record from the "Library use" section.)
  >
  >(Related to Bug 42169 - Unify patron category change popups, added to Koha 26.05 and 25.11.)
- [43069](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43069) Empty PatronDuplicateMatchingAddFields considers every new patron as duplicate (26.11.00,26.05.03,25.11.10)
- [43110](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43110) When a patron has a value for advance notices the checkboxes are enabled on the details view (26.11.00,26.05.04)
- [43245](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43245) There should be a message in the staff interface if a patron has no email address and you reset their password (More > Send password reset) (26.11.00,26.05.05)
  >This fixes resetting a password for a patron in the staff interface ("More > Send password reset" option when OpacResetPassword is set to "allowed").
  >
  >If a patron has no email message, no message was sent. There was no indication about this and the reason why, so you would assume that a password reset notice was sent (apart from redirecting to the patron notices section, where you may have noticed that there isn't a password reset notice queued).
  >
  >Now, if the patron does not have an email address, a message is shown:
  >
  >       Unable to send password reset
  >
  >       The patron has no email address
- [43672](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43672) When a patron has no advance notices value and their category is changed to one with a value the checkboxes are not enabled (26.11.00,26.05.05)
- [43825](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43825) Patron edit page doesn't return to moremember.pl when it should (26.11.00,26.05.06)
- [44033](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=44033) Patron name link on merge patrons page should open in new window (26.11.00)
  >This fixes the merge patron page. Links for the individual patrons to be merged now open in a new window/tab, instead of opening in the existing page (the icon indicates it will open in a new window, and it now does).

  **Sponsored by** *Athens County Public Libraries*
- [44065](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=44065) Alternate address with AddressFormat "de" shows no space between postcode and city (26.11.00)
- [42430](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42430) Fix issue with stale plugin methods after plugin upgrade (26.11.00,26.05.03,25.11.09)
- [43779](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43779) Transaction column contents blank when exporting register transaction history (26.11.00)
  >This fixes the export of data from the point of sale system transaction summary for a cash register - the transaction date and the transaction ID was not exported.
- [43955](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43955) POS receipt links open an intermediate page instead of printing directly (26.11.00)
- [44009](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=44009) POS change-to-give modal stays open after Yes with FinePaymentAutoPopup (26.11.00)
- [36988](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36988) PUT for patrons requires full borrowers permission, but should only require 'edit_borrowers' (26.11.00,26.05.02)
- [40736](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40736) OAuth/OIDC authentication logs error message when CGISESSID is missing (26.11.00)
  >When an OAuth or OIDC login is started directly without an existing session (the `CGISESSID` cookie is missing), the user is now redirected with a "No user session found" message.
- [42739](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42739) OPAC ratings.js: Add CSRF-TOKEN header to fetch call (26.11.00,26.05.02,25.11.08)
- [43460](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43460) REST API XML payload conversion breaks plugin API routes that consume XML (26.11.00,26.05.06)
- [8127](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8127) Most-circulated items report doesn't work when limited by library (26.11.00,26.05.03,25.11.08,25.05.14,24.11.19)
  >This fixes some of the filters for the "Most-circulated items" report so that using limits (the Limits section with "Limit to" and "By") now works.
  >
  >Previously some options for "By" (such as Library and Week) generated an error message or there were no results (when results were expected).
- [12757](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12757) Integers in saved SQL report ODT export prepended with single quote (26.11.00,26.05.02,25.11.08)

  **Sponsored by** *OpenFifth*
- [42451](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42451) "convert" op in guided_reports.pl is broken due to JS error (26.11.00,26.05.05,25.11.11)
- [42550](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42550) JS error on saved SQL reports page when there are no reports (26.11.00,26.05.02)
- [42803](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42803) Regression in Reports > Items with no checkouts (reports/catalogue_out.pl) (26.11.00,26.05.02,25.11.08)
- [43098](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43098) Typo in URL for "Edit SQL" button in guided reports (guided_reports_start.tt) (26.11.00,26.05.03,25.11.10)
  >This fixes a typo in the URL when editing the SQL in reports. If there is an error in the SQL, the "Edit SQL" button would take you to the guided reports wizard, instead of letting you edit the SQL for the report.  
  >
  >(Changes ".../guided_reports.pl?op=edit_formid=..." to ".../guided_reports.pl?op=edit_form&id=..." - note the missing &)
- [43249](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43249) A duplicate report limit of 1 prevents users from running reports at all (26.11.00,26.05.05)
- [43296](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43296) Circulation statistics do not work with non-numeric patron attribute codes (26.11.00,26.05.06)
- [43432](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43432) Update the description for the ReportsExportLimit system preference (26.11.00)
  >This updates the ReportsExportLimit system preference description to clarify that it controls the number of rows (or results) exported, which may or may not be records.
  >
  >It also moves the ReportsExportLimit system preference from the
  >staff interface category to the reports category, as
  >it relates only to the reports module.
  >
  >Updated description:
  >Download a maximum of _____ rows when exporting report results.
  >NOTE:
  >- Using LIMIT in a report overrides this setting.
  >- It does not limit results when using 'Open in DataTables'
  >  export options.
  >
  >Previous description:
  >Download a maximum of _____ records when downloading from the
  >reports module.
  >NOTE: Only a positive value will enforce a limit. A specific
  >limit in the report overrides this setting.
- [43547](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43547) Update and Run SQL button runs report before updating (26.11.00)
  >Fixes a problem where the 'Update and run' button for reports was fetching a stored version of the report from before the update.
- [43591](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43591) Regression Bug 16631 My/All Reports Filter Option Missing (26.11.00)
- [43623](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43623) LIMIT OFFSET syntax not correctly handled in reports (26.11.00,26.05.06)

  **Sponsored by** *Cape Libraries Automated Materials Sharing*
- [43736](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43736) Reports should allow use of any format when rendering with a template (26.11.00)

  **Sponsored by** *OpenFifth*
- [43981](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43981) Numeric barcodes can lose trailing zeroes in ODS export of reports (26.11.00)

  **Sponsored by** *OpenFifth*
- [39829](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39829) SIP2 title field does not include subtitle, part or number (26.11.00)
- [40800](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40800) TransferArrived needlessly triggers alerts in SIP (26.11.00,26.05.05,25.11.11)

  **Sponsored by** *OpenFifth*
- [41707](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41707) The DIE handler in C4::SIP::Trapper is logging non-SIP errors, causing log flooding (26.11.00)
  >The SIP Trapper module's error handling has been enhanced to distinguish between SIP-related and non-SIP errors. SIP-related errors are now logged at the ERROR level, while non-SIP errors are logged as warnings.
  >
  >This improvement reduces log noise and makes it easier for system administrators to quickly identify and respond to genuine SIP connectivity and protocol issues, improving the overall maintainability of SIP services.

  **Sponsored by** *Koha-Suomi Oy*
- [42002](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42002) SIP screen msg regexp can't be empty (26.11.00,26.05.02,25.11.08)
  >On the SIP2 account screen, the "replace" value of a screen message regular expression is now optional. If it is left blank, matched text is replaced with an empty string.
- [42700](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42700) In C4/SIP/ILS/Patron.pm, hold_items only counts waiting holds (26.11.00,26.05.05,25.11.10)
- [42860](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42860) UNIVERSAL::require is deprecated and should be replaced (26.11.00,26.05.06)
- [43397](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43397) SIP accounts with a blank AE field template send an empty patron name (26.11.00,26.05.06)
- [43727](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43727) SIP no block checkouts and offline checkouts leave another patron's waiting hold in place (26.11.00,26.05.06)
- [38181](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38181) Extreme slow search results on OPAC (only) search when result records contain multiple items. (26.11.00)
- [42946](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42946) [CVE-2026-16031] Time-based Blind SQL Injection in itemsearch.pl functionality (26.11.00,26.05.05,25.11.10,25.05.16,24.11.21)
- [43320](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43320) Don't repeat a quoted search with more quotes when no results (26.11.00,26.05.04,25.11.10)
- [44063](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=44063) Component parts are not sorted by ComponentSortField and ComponentSortOrder (26.11.00)
- [39769](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39769) es_indexer_daemon.pl uses stale L1 cache (26.11.00,26.05.05,25.11.11)
  >The Elasticsearch indexer daemon is a long-lived process that never cleared its L1 (in-process) cache, meaning changes to system preferences like IncludeSeeFromInSearches were not picked up until the daemon was manually restarted. The L1 cache is now flushed before each indexing batch, so preference changes take effect on the next indexing run without requiring a daemon restart.
- [43498](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43498) UNIMARC: authority search returns no results when the authority type is only in 942$a (26.11.00,26.05.06)

  **Sponsored by** *Altsol*
- [42699](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42699) Editing an already received serial with a duplicate barcode leads to Error 500 (26.11.00,26.05.03,25.11.10)

  **Sponsored by** *Koha-Suomi Oy*
- [42844](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42844) Subscription search breaks when using additional field and no search result is returned (26.11.00,26.05.01,25.11.07)
- [44125](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=44125) Serial claims CSV export breaks non-ASCII characters (26.11.00)
- [40668](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40668) Library groups and seperateholdings with itemgroups prevents adding items to itemgroup (26.11.00,26.05.04,25.11.10)
  >This fixes an issue that prevents staff patrons from adding items to an item group. Actions to add or remove items from an item group did not show, even though they had the correct permissions.
  >
  >Example:
  >- Staff patron has catalogue and manage_item_groups permissions
  >- Item groups are enabled (EnableItemGroups system preference)
  >- There is a library group for the library that the staff patron is from
  >- The "Limit item editing by group" is set for this library group (effectively, the staff patron can only edit items from their own library)
  >- Before the fix: When viewing the items for a record there were no actions available to add items to an item group (the check box was selectable, but there were no actions available)
  >- After the fix: Actions to add or remove items from an item group are now visible and work as expected

  **Sponsored by** *OpenFifth*
- [42084](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42084) Incorrect interface shown in log viewer for system preference changes (26.11.00,26.05.01,25.11.06)
  >This fixes the interface shown in the log viewer when changes to system preferences are made. The log viewer now correctly shows the change to system preferences was made from the staff interface. Previously, the OPAC interface was for system preference changes-this was not correct, as system preferences cannot be modified from the OPAC.
- [42116](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42116) e.preventDefault is a function, needs parentheses (26.11.00,26.05.02,25.11.08)
- [42133](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42133) Cataloguing plugins are broken on the batch item mod tool (again) (26.11.00,26.05.01,25.11.06)
- [42339](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42339) Canceling a Record display customization directs to the HTML customizations (26.11.00,26.05.03,25.11.09)
  >This fixes the record display customizations page (Tools > Additional tools > Record display customizations). When you cancel adding a new entry you are now returned to the list of record display customizations, instead of the list of HTML customizations.
- [42535](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42535) Remove useless "news_delete" javascript in staff interface (26.11.00,26.05.02,25.11.08)
- [42632](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42632) Cannot manage bundles after filters are displayed (26.11.00,26.05.04,25.11.10)
- [42656](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42656) File transport test responses can be unclear (26.11.00,26.05.05)
- [42661](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42661) Redudant repetition in "Patron: %s Patron's home library: (%s /%s )" when HidePatronName is activated (26.11.00,26.05.05,25.11.11)
- [42666](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42666) Next button in Item types and Patron categories does not work (26.11.00,26.05.02,25.11.08)
- [42708](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42708) Itemtype images no longer displayed on the holdings table (26.11.00,26.05.01)
  >This fixes showing item type images in the staff interface holdings table.
  >
  >Item type images weren't showing where noItemTypeImages was set to "Show", and were showing when it was set to "Don't show" (the opposite of what it should be).
  >
  >The correct behavour for the noItemTypeImages system preference is now restored:
  >- If set to "Show", the item type image is shown.
  >- If set to "Don't show", the item type image is not shown.
  >
  >(This was a regression from bug 41566 - Tidy kohaTable block - catalogue, added to Koha 26.05.)
- [42727](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42727) Languages displayed in random order in language menu (26.11.00,26.05.05)
  >This fixes how language selectors/tabs are shown in the staff interface for notices and slips and additional contents (such as news and customizations) - now shown in a consistent order, and removes the "randomness" when pages are refreshed:
  >
  >1. For the staff interface footer: shows enabled languages in the order shown in the StaffInterfaceLanguages system preference.
  >
  >2. For notices and slips (with TranslateNotices system preference enabled) the language tabs are now shown in this order: Default, English, then all languages installed in language code order (de-DE, fr-CA, fr-FR, pt-BR, pt-PT, ...) (notes: not in the order shown in the StaffInterfaceLanguages system preference, shows all installed languages - not just enabled languages).
  >
  >3. For additional contents (news, HTML customizations, ...) the language tabs are now shown in this order: Default, all enabled languages in the order shown in the StaffInterfaceLanguages system preference, then languages not enabled at the end (note: if there is more than one language code for a language installed (such as fr-CA and fr-FR) but one is not enabled, the languages are grouped together - the language not enabled doesn't go to the end).
- [42799](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42799) Toolbar stickiness implementation is flaky (26.11.00,26.05.03,25.11.10)
- [42986](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42986) JS error when writing off selected charges (26.11.00,26.05.03)
- [43032](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43032) Table row highlighting is broken in holds (26.11.00)
- [43313](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43313) Item's permanent location not shown when item's location is set to CART (26.11.00,26.05.05)

  **Sponsored by** *OpenFifth*
- [43331](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43331) No class on collection code in holdings table on bib detail (26.11.00,26.05.05,25.11.11)
- [43370](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43370) Holdings table displays a user-selected column on the pages where it is empty (26.11.00,26.05.06)
- [43373](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43373) Holdings table always displays the shelving location column (26.11.00,26.05.05)
- [43383](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43383) Problem adding to a list or cart when using browser's back button (26.11.00,26.05.06)
- [43394](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43394) DT - pagination is broken if pageLength is not an integer (26.11.00,26.05.06)
  >This fixes navigating patron card batch entries in the patron card editor (Tools > Patrons and circulation > Patron card creator). The "Next" pagination link now works as expected.
  >
  >Previously, the next page link did not work (nothing happened) and there was a JavaScript error in the browser console.
- [43444](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43444) After logout and immediate login, language selection link takes back to login page (26.11.00)
- [43561](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43561) Local use system preferences are shown in autocomplete but not found in searches (26.11.00)
- [43654](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43654) Item search: DataTables column filters ignored when 2+ conditions are combined (follow-up to Bug 36930) (26.11.00,26.05.06)
  >This fixes item search in the staff interface (Search > Item search) so that the filters in the search results now work as expected.
  >
  >Before the patch: when using multiple search criteria in the section where you can enter specific values for fields (such as Barcode, Title, and so on), using the filters in the search results table did not do anything. For example (using sample data in koha-testing-docker):
  >- Barcode is 3999%
  >- AND Title is %perl%
  >  ==> Results: 18
  >- In the filter for the Title column, enter template
  >  ==> Results: no change to results
  >
  >After the patch: filters in the table now work as expected.
- [43714](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43714) stockrotation.pl runs out for memory when rotas have too many items in a stage (26.11.00,26.05.06)
  >Optimizes the prefetch in stockrotations.pl to make the retrieval of stock rotation items faster.
- [42141](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42141) Design pattern introduced in 40191 does not work in staff SIP configuration (26.11.00,26.05.02,25.11.08)
- [42568](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42568) Match maxlength attributes to marc_order_accounts column sizes (26.11.00,26.05.03,25.11.09,25.11.09)

  **Sponsored by** *Athens County Public Libraries*
- [42618](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42618) Incorrect sidebar menu link to MARC order accounts (26.11.00,26.05.03,25.11.09)

  **Sponsored by** *Athens County Public Libraries*
- [42641](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42641) JavaScript errors on patron attribute types admin page (26.11.00,26.05.02,25.11.08)
  >This fixes the "Patron attribute types" page (Administration > Patrons and circulation > Patron attribute types). The standard table was not showing correctly because of JavaScript errors. The table was not showing the standard navigation and other table elements:
  >  . "Showing X to X of X entries" (above and below the table)
  >  . Search filter
  >  . Export options
  >  . Sorting controls for the columns
- [42810](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42810) New patron category form does not show self-renewal information message field (26.11.00,26.05.06)
  >This fixes the patron category form - when creating a new patron category the "Self-renewal information message" field is now shown (under the "Account expiry and self-renewal" section). 
  >
  >Before this:
  >1. Only the field hint text was shown when creating a new patron category.
  >2. The field was only shown when editing an existing patron category.
- [42885](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42885) FineNoRenewals description mentions fines rather than charges (26.11.00,26.05.03)
- [43215](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43215) Checkbox/sortable system preferences show one 'Saved preference' message per option instead of per preference (26.11.00)
  >This fixes the messages shown when saving changes to system preferences that use the widget with multiple sortable and selectable options that have checkboxes, such as OPACAuthorIdentifiersAndInformation. 
  >
  >Saving changes to system preferences that used this widget resulted in several pops up with "Saved preference ..." with one confirmation line per checkbox/option (even if only one option was changed), instead of a single line for the preference itself.
- [43314](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43314) Add cron reminder to AnonymizeLastBorrower/AnonymizeLastBorrowerDays description (26.11.00,26.05.06)
  >This adds a note to the AnonymizeLastBorrower system preference with a hint about needing to run the cron job.
- [43681](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43681) Can't update additional field authorized value category to "none" (26.11.00)

  **Sponsored by** *Athens County Public Libraries*
- [44001](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=44001) System preference tables - column widths noticeably more inconsistent in main (26.11.00)
  >This improves the consistency of the column widths for system preference table columns (preference and value columns). Sometimes the column widths were very wide and at other times they were very narrow. (While not perfectly aligned, they are more similar to Koha 26.05.)
  >
  >(This is a follow-up to Bug 38185 - DT - replace dom with layout, added to Koha 26.11).
- [37441](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37441) ShowAlerts msg not escaped in tools uploads (26.11.00,26.05.04,25.11.09,25.05.15,24.11.20)
- [38948](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38948) Modal error on some pages: Can't access property "backdrop" (26.11.00,26.05.06)

  **Sponsored by** *Athens County Public Libraries*
- [39420](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39420) Item edit breadcrumbs wrong (26.11.00,26.05.06)
- [42052](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42052) Do not export the checkbox and spine label columns in the staff interface holdings table (26.11.00)
  >This fixes the export of the holdings table for a record in the staff interface so that the checkbox and spine label columns are not included (Export > CSV).
- [42154](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42154) Bug 38714 hid the "New match check" link in record matching rules (26.11.00,26.05.01,25.11.06,25.05.13)

  **Sponsored by** *Athens County Public Libraries*
- [42475](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42475) Terminology: OPAC is an abbreviation (26.11.00,26.05.01,25.11.06,25.05.13)
  >Changes opac to OPAC for these system preference descriptions:
  >- NovelistSelectProfile
  >- item-level_itypes
  >- OpacSuppressionByIPRange
- [42518](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42518) Capitalization: Refund Payout Receipt (26.11.00,26.05.01,25.11.07)
  >This fixes the capitalization (title case to sentence case) for a heading in the "Point of sale payout receipt (PAYOUT)" print notice template: Refund Payout Receipt --> Refund payout receipt.
  >
  >Note: This only affects new Koha installations. Existing installations need to either manually update the notice or replace the existing notice with the default notice text.
- [42519](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42519) Terminology: branch should be library (26.11.00,26.05.03)
  >This fixes the terminology used for the default message in the "Self-renewal failure message" field (Administration > Patrons and circulation > Patron categories > Account expiry and self-renewal). "...your local branch..." changed to "...your library...".
- [42684](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42684) Capitalization: No Barcode and several other occurrences where title case is used instead of sentence case (26.11.00,26.05.01)
  >This fixes the capitalization (title case used instead of sentence case) in several modules:
  >- Acquisitions:
  >  . Processing Errors --> Processing errors
  >- Reports:
  >  . Reports Dictionary --> Reports dictionary
  >  . Saved Reports --> Saved reports 
  >- Interlibrary loans (ILL):
  >  . Home Library --> Home library
  >  . Holding Library --> Holding library
  >  . No Barcode --> No barcode
  >  . Supplying Agency Request ID --> Supplying agency request ID
  >  . Requesting Agency --> Requesting agency
  >  . Visit ILL requests (previously ILL Module) --> Visit ILL requests (previously ILL module)
  >  . ILL Requests --> ILL requests
  >  . visit the ILL requests (previously ILL Module) --> visit the ILL requests (previously ILL module)
  >- ERM and ILL dashboards:
  >   . Open Widget Picker --> Open widget picker
  >- View-based modules:
  >  . Invalid Date --> Invalid date
  >- OPAC authentication:
  >  . Koha Administrator --> Koha administrator
  >- About Koha:
  >  . Not Installed --> Not installed
- [42685](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42685) Capitalization corrections in some ILL files (26.11.00,26.05.06)
  >This fixes two user interface capitalization issues for the ILL module:
  >1. "ISO18626 Messages" to "ISO18626 messages"
  >2. "Requesting Agencies" to "Requesting agencies"
- [42691](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42691) Typo: automaticaly (26.11.00,26.05.01)
  >Fixes a spelling error in the AutomaticRenewalPeriodBase system preference - automaticaly -> automatically.
- [42692](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42692) Typo: regarless (26.11.00,26.05.01)
  >Fixes a spelling error in the AllNoticeStylesheet system preference - regarless -> regardless.
- [42695](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42695) Minor language and markup corrections to reports error messages (26.11.00,26.05.01,25.11.07)
  >This fixes the HTML markup for some report error messages, along with some minor text changes:
  >- Uses an H1 for the heading
  >- Uses p for paragraphs

  **Sponsored by** *Athens County Public Libraries*
- [42707](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42707) Malformed Bootstrap dropdown in reports output (26.11.00,26.05.02,25.11.08)
  >This fixes the formatting of the patron card number (cardnumber) column in reports. It now uses the "dropdown-item" class and is formatted the same as other dropdown lists, such as borrowernumber.

  **Sponsored by** *Athens County Public Libraries*
- [42928](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42928) Terminology: Log viewer results - show "Check-in" instead of "Return" in the action column (26.11.00,26.05.03)
  >This fixes the terminology used in the log viewer tool results. "Check-in" (noun) is now used instead of "Return".
- [43046](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43046) Checkbox labels in Currencies and EDI accounts have unnecessary colons (26.11.00,26.05.03)
- [43220](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43220) Patron name and card number should not be clickable in headings (26.11.00,26.05.06)
  >This fixes the "Checking out to [patron name (patron number)]" message on the patron check out page to remove the link for the patron name and card number.
  >
  >(A follow-up bug, Bug 43866 - Patron name and card number should not be clickable in remaining 'Checking out to' headings, removes the link from the check out page when a patron can't check out (for example, when they have restrictions) and the batch check out page.)

  **Sponsored by** *Athens County Public Libraries*
- [43443](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43443) Terminology: Issued should be "Checked out" in bookings (26.11.00)
  >This fixes the terminology for the status of a booking, shown in the bookings table for a record and a patron's check out and details sections. When checked out, the status for a booking is now shown as "Checked out" instead of "Issued".
- [43595](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43595) Missing space between title and author in items search (26.11.00,26.05.06)
- [43651](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43651) Clarify "Expand all" and "Collapse all" link labels in Acquisitions and Funds sections (26.11.00)

  **Sponsored by** *Koha-Suomi Oy*
- [43707](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43707) Fix stored XSS in DT's column filters in staff interface (26.11.00,26.05.05,25.11.10,25.05.16,24.11.21)
- [43786](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43786) Incorrect string concat in templates (26.11.00,26.05.06)
- [43992](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43992) Fix capitalization errors introduced with item lists (26.11.00)

  **Sponsored by** *Athens County Public Libraries*
- [42705](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42705) OPAC/SCO_spec.ts  is failing (26.11.00,26.05.01,25.11.07)
- [42733](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42733) Tools/ManageMarcImport_spec.ts is failing (again) (26.11.00,26.05.01,25.11.06,25.05.12)
- [42764](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42764) codespell.t fails after container OS upgrade due to newer codespell dictionary (26.11.00,26.05.01,25.11.12)
- [42783](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42783) Tools/ManageMarcImport_spec.ts is still flaky (26.11.00,26.05.01,25.05.12,25.11.07,25.11.07)
- [42801](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42801) Race condition in ERM/UsageReports_spec.ts (26.11.00.26.05.06)
- [42862](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42862) bookingsModalDatePicker_spec.ts is failing (26.11.00,26.05.01,25.11.10)
- [42937](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42937) `$Test::Strict::TEST_STRICT = 0;` no longer needed in t/db_dependent/00-strict.t (26.11.00,26.05.03,25.11.09)
- [42979](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42979) api/v1/biblios.t on MySQL 8 (26.11.00)
- [43071](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43071) Test failures when Holds Allowed (daily) has a value (26.11.00,26.05.03,25.11.10)
- [43082](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43082) Flaky action_logs.t object filter test due to default LIKE matching (26.11.00,26.05.04,25.11.10)
- [43117](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43117) t/Form_MessagingPreferences.t does not use Test::NoWarnings (26.11.00,26.05.06)
- [43203](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43203) Item.t doesn't clean up after itself correctly (26.11.00,26.05.05,25.11.11)
- [43339](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43339) automatic_item_modification_by_age_configuration is not a real system preference (26.11.00,26.05.05)
- [43669](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43669) Selenium tests can fail if server is still restarting (26.11.00,26.05.04,25.11.10)
- [43881](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43881) Vendors_spec.ts receive test depends on the first table row (26.11.00)
- [43965](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43965) xt/check-thead-tt-tags.t requires a new entry when a new table is added to a Vue app (26.11.00)
- [44070](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=44070) Detail page dies on unparseable metadata; selenium regressions.t expects the old biberror for a now-repairable record (26.11.00)

  **Sponsored by** *OpenFifth*
- [42973](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42973) Additional contents ordering ignores "Appear in position" when sorting news (26.11.00,26.05.04)
- [43043](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43043) Library limit for OpacMySummaryNote HTML customization doesn't work (26.11.00,26.05.03,25.11.10)
- [43173](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43173) Terminology: Log viewer - "Modify cardnumber" should be " Modify card number" (26.11.00,26.05.04)
  >This fixes the log viewer terminology. It changes "Modify cardnumber" to "Modify card number", as per the terminology guidelines in two places:
  >- Actions section: is now "Modify card number"
  >- Log view results action column when a patron's
  >  card number is changed: is now "Modify card number"
- [43868](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43868) Log viewer search does not find circulation entries by item barcode (26.11.00,26.05.06)
- [43895](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43895) Bug 42627 improvements and follow-ups (26.11.00)
- [44068](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=44068) Log Viewer gives 500 error, if output "to screen in the browser" (26.11.00)
- [42321](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42321) Z3950/SRU Search should handle empty results from search targets better (26.11.00,26.05.02,25.11.09)

## New system preferences

- AllowLinkedAccountHoldPickup
- AmazonLocaleTld
- AutoDeleteFromCartWhenHoldPlaced
- CashupPaymentTypes
- CashupReconciliationNoteAuthorisedValue
- CashupReconciliationNoteRequired
- EdifactInvoiceImportBlockDuplicates
- EdifactInvoiceImportBlockDuplicatesEmailAddresses
- EdifactInvoiceImportBlockDuplicatesEmailNotice
- EdifactOrderSendBlockDuplicatesEmailAddresses
- EdifactOrderSendBlockDuplicatesEmailNotice
- EnablePatronAccountLinking
- EnableZotero
- ItemListsLog
- LimitReportsBy
- LinkerUseFrameworkAuthTypes
- LocalHoldsExclusivityItemControl
- LocalHoldsExclusivityPatronControl
- LocalHoldsExclusivityPeriod
- LocalHoldsPriorityScope
- MarcModificationTemplatesLog
- NoIssuesChargeLinkedAccounts
- NoticesManagement
- RealTimeHoldsQueueUnallocated
- ReportsRunInBackground
- SCOLoadHoldsByDefault
- ScriptLog
- UpdateExpiryDateOnCategoryChange
- UpdateMessagingPrefsOnCategoryChange

## Deleted system preferences

- AmazonLocale
- CircSidebar
- LibrisKey
- LibrisURL

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [English (USA)](https://koha-community.org/manual/26.11/en/html/)
- [French](https://koha-community.org/manual/26.11/fr/html/) (81%)
- [German](https://koha-community.org/manual/26.11/de/html/) (82%)
- [Greek](https://koha-community.org/manual/26.11/el/html/) (88%)
- [Hindi](https://koha-community.org/manual/26.11/hi/html/) (60%)
- [Portuguese](https://koha-community.org/manual/26.11/pt/html/) (60%)
- [Portuguese (Brazil)](https://koha-community.org/manual/26.11/pt_BR/html/) (60%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Afrikaans (97%)
- Arabic (ar_ARAB) (84%)
- Armenian (hy_ARMN) (100%)
- Azerbaijani (62%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified Han script) (76%)
- Chinese (Traditional Han script) (88%)
- Czech (61%)
- Dutch (83%)
- English (100%)
- English (New Zealand) (97%)
- English (USA)
- Finnish (96%)
- French (97%)
- French (Canada) (96%)
- German (100%)
- Greek (60%)
- Hindi (86%)
- Italian (76%)
- Khmer (Central) (55%)
- Norwegian Bokmål (64%)
- Persian (fa_ARAB) (85%)
- Polish (100%)
- Portuguese (Brazil) (97%)
- Portuguese (Portugal) (86%)
- Russian (87%)
- Slovak (54%)
- Spanish (90%)
- Swedish (88%)
- Telugu (59%)
- Turkish (73%)
- Ukrainian (68%)
- Uzbek (67%)
- Western Armenian (hyw_ARMN) (55%)
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

The release team for Koha 26.11.00 is


- Release Manager: Pedro Amorim

- Release Manager assistants:
  - Tomás Cohen Arazi
  - Martin Renvoize

- QA Manager: Lisette Scheer

- QA Team:
  - Lucas Gass
  - Laura Escamilla
  - Kyle M Hall
  - Baptiste Wojtkowski
  - David Cook
  - Andrew Fuerste-Henry
  - Brendan Lawlor
  - Paul Derscheid
  - Jan Kissig
  - Jacob O'Mara
  - Nick Clemens
  - Tomás Cohen Arazi
  - Marcel de Rooy
  - Emily Lamancusa
  - Aleisha Amohia
  - Martin Renvoize
  - David Nind
  - Jonathan Druart
  - Katrin Fischer
  - Matt Blenkinsop
  - Michaela Sieber
  - Owen Leonard

- Topic Experts:
  - Elasticsearch/OpenSearch -- Fridolin Somers
  - SIP2 -- Kyle M Hall
  - EDI -- Kyle M Hall
  - POS -- Martin Renvoize

- Bug Wranglers:
  - Michaela Sieber
  - Laura Escamilla

- Documentation Manager: Aude Charillon

- Documentation Team:
  - Caroline Cyr La Rose
  - David Nind
  - Philip Orr

- Wiki curators: 
  - Thomas Dukleth
  - George Williams

- Release Maintainers:
  - 26.05 -- Lucas Gass
  - 25.11 -- Baptiste Wojtkowski
  - 25.05 -- Wainui Witika-Park (Catalyst IT)
  - 24.11 -- Fridolin Somers

- Release Maintainer assistants:
  - 26.05 -- Jacob O'Mara
  - 25.05 -- Alex Buckley & Aleisha Amohia (Catalyst IT)

## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 26.11.00
<div style="column-count: 2;">

- Altsol
- [Anne Arundel County Public Library](https://www.aacpl.net)
- Athens County Public Libraries
- Auckland University of Technology
- [BibLibre](https://www.biblibre.com)
- [Bibliotheksservice-Zentrum Baden-Württemberg (BSZ)](https://bsz-bw.de)
- Black Hills Library Consortium- http://www.rcgov.org/Library/
- [ByWater Solutions](https://bywatersolutions.com)
- [Büchereizentrale Schleswig-Holstein](https://www.bz-sh.de)
- [Cape Libraries Automated Materials Sharing](https://info.clamsnet.org)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)
- Chetco Community Public Library
- Colorado Library Consortium
- Education Services Australia SCIS
- [Glasgow Colleges Library Group](https://library.cityofglasgowcollege.ac.uk)
- [Heythrop Library](https://heythroplibrary.co.uk)
- Horowhenua Libraries Trust
- Ignatianum University in Cracow
- Karlsruhe Institute of Technology (KIT)
- Koha Solutions
- [Koha-Suomi Oy](https://koha-suomi.fi)
- Lund University Library
- [Main Library Alliance](https://www.mainlib.org)
- Martin Renvoize
- NHS England (National Health Service England)
- [OpenFifth](https://openfifth.co.uk)
- Pontificia Università di San Tommaso d'Aquino (Angelicum)
- Pymble Ladies' College
- Ramapo Catskill Library System
- [Royal Borough of Kensington and Chelsea](https://www.rbkc.gov.uk)
- SCD Lyon2
- [The Main Library Alliance](https://www.mainlib.org)
- [West Sussex County Council](https://www.westsussex.gov.uk)
- [Westminster City Council](https://www.westminster.gov.uk)
- [koha-US](https://koha-us.org)
</div>

We thank the following individuals who contributed patches to Koha 26.11.00
<div style="column-count: 2;">

- Alex Carver [Acerock7] (3)
- Saiful Amin (2)
- Aleisha Amohia (22)
- Pedro Amorim (164)
- Tomás Cohen Arazi (145)
- Jake Bateman (1)
- Matt Blenkinsop (53)
- Colin Campbell (1)
- Kevin Carnes (1)
- Nick Clemens (46)
- Casey Conlin (3)
- David Cook (28)
- Ilker Dagli (1)
- Konstantinos Daskalopoulos (1)
- Jake Deery (5)
- Frédéric Demians (7)
- Paul Derscheid (100)
- Roman Dolny (1)
- Jonathan Druart (262)
- Ján Dugovič (1)
- Magnus Enger (2)
- Laura Escamilla (34)
- Katrin Fischer (13)
- Andrew Fuerste-Henry (27)
- Lucas Gass (96)
- Ayoub Glizi-Vicioso (1)
- Victor Grousset (1)
- Thibaud Guillot (12)
- Amit Gupta (3)
- Bo Gustavsson (2)
- Kyle M Hall (143)
- Mark Hofstetter (2)
- Andreas Jonsson (3)
- Babar Junaid (1)
- Janusz Kaczmarek (11)
- Jan Kissig (58)
- Emily Lamancusa (19)
- Johan Larsson (1)
- Brendan Lawlor (28)
- Owen Leonard (81)
- Nina Martinez (1)
- Chris Mathevet (3)
- Julian Maurice (5)
- Artur Mickiewicz (1)
- nela (1)
- Chris Nighswonger (2)
- David Nind (10)
- Andrew Nugged (11)
- Sanjar Tulkinov Anvar o'g'li (4)
- Jacob O'Mara (76)
- Lawrence O'Regan-Lloyd (2)
- Eric Phetteplace (5)
- Martin Renvoize (525)
- Olivia Reynolds (74)
- Phil Ringnalda (2)
- Jason Robb (1)
- Adolfo Rodríguez (9)
- Marcel de Rooy (15)
- Caroline Cyr La Rose (9)
- Johanna Räisä (2)
- Lisette Scheer (6)
- Robin Sheat (2)
- Slava Shishkin (5)
- Maryse Simard (1)
- Fridolin Somers (6)
- Samuel Sowanick (3)
- Tadeusz „tadzik” Sośnierz (1)
- Lari Strand (2)
- Jennifer Sutton (1)
- Arthur Suzuki (3)
- Emmi Takkinen (8)
- Lari Taskula (12)
- Cameron E. Tidd (1)
- Shi Yao Wang (6)
- Hammat Wele (10)
- Baptiste Wojtkowski (15)
- Sam Young (2)
- Chloe Zermatten (42)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 26.11.00
<div style="column-count: 2;">

- altsol.gr (1)
- Athens County Public Libraries (81)
- [BibLibre](https://www.biblibre.com) (42)
- [Bibliotheksservice-Zentrum Baden-Württemberg (BSZ)](https://bsz-bw.de) (13)
- [ByWater Solutions](https://bywatersolutions.com) (354)
- [Cape Libraries Automated Materials Sharing](https://info.clamsnet.org) (30)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha) (15)
- Catalyst Open Source Academy (8)
- cca.edu (2)
- Chetco Community Public Library (2)
- citlink.net (1)
- corvallisoregon.gov (3)
- David Nind (10)
- gustavsson.one (2)
- [HKS3](https://koha-support.eu) (1)
- hofstetter.at (2)
- [Hypernova Oy](https://www.hypernova.fi) (12)
- imcode.com (1)
- Independant Individuals (43)
- informaticsglobal.ai (3)
- [Jezuici](https://jezuici.pl/) (1)
- kallisti.net.nz (2)
- Koha Community Developers (263)
- [Koha-Suomi Oy](https://koha-suomi.fi) (9)
- Kreablo AB (3)
- [Libriotech](https://libriotech.no) (2)
- [LMSCloud](https://www.lmscloud.de) (100)
- Lund University Library (1)
- mail.com (1)
- [Montgomery County Public Libraries](https://montgomerycountymd.gov) (19)
- nyabla.net (1)
- [OpenFifth](https://openfifth.co.uk) (941)
- [Prosentient Systems](https://www.prosentient.com.au) (28)
- rcls.org (3)
- Rijksmuseum, Netherlands (15)
- semanticconsulting.com (2)
- [Solutions inLibro inc](https://inlibro.com) (30)
- [South East Kansas Library System](http://www.sekls.org) (1)
- Tamil (7)
- [Theke Solutions](https://theke.io) (145)
- veritassuperaitsolutions.com (2)
- Wildau University of Technology (58)
- [Xercode](https://xebook.es) (9)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Alex Carver [Acerock7] (20)
- Aleisha Amohia (10)
- Pedro Amorim (1912)
- Angela (1)
- Anni (1)
- Tomás Cohen Arazi (69)
- Katie Baines (1)
- Stephanie Baker (1)
- Christie Balestrieri (2)
- Baptiste Bayche (13)
- Kris Becker (1)
- Bob Bennhoff (7)
- Angela Berrett (6)
- Matt Blenkinsop (69)
- Richard Bridgen (2)
- Emmanuel Bétemps (1)
- Aude Charillon (1)
- Bastien CHAUVET (3)
- Hayley Cheng (1)
- Nick Clemens (172)
- David Cook (43)
- Benjamin Daeuber (1)
- Ray Delahunty (5)
- Frédéric Demians (13)
- Paul Derscheid (114)
- Trevor Diamond (27)
- Roman Dolny (13)
- Jonathan Druart (120)
- Sharon Dugdale (3)
- Hannah Dunne-Howrie (45)
- Marion Durand (30)
- Magnus Enger (3)
- Laura Escamilla (94)
- Katrin Fischer (71)
- Sarah Fletcher (3)
- Andrew Fuerste-Henry (302)
- Brendan Gallagher (2)
- Eric Garcia (1)
- Lucas Gass (110)
- Stephen Graham (2)
- Claire Gravely (1)
- Clemens Gresser (3)
- Gretchen (5)
- Mike Grgurev (11)
- Victor Grousset (15)
- Amit Gupta (3)
- Bo Gustavsson (2)
- Kyle M Hall (78)
- George Harkins (12)
- Sally Healey (2)
- Juliet Heltibridle (12)
- Mason James (1)
- Barbara Johnson (10)
- Janusz Kaczmarek (1)
- E-P Keskitalo (1)
- Jan Kissig (61)
- Kristi Krueger (1)
- Emily Lamancusa (25)
- Sam Lau (3)
- Brendan Lawlor (181)
- Owen Leonard (86)
- David Liddle (3)
- Coleen Lilly (3)
- Chris Mathevet (2)
- Julian Maurice (1)
- Jeanne Maurielle (1)
- Gretchen Maxeiner (7)
- Debbie McCarthy (6)
- Kelly McElligott (27)
- Michaela (52)
- Marcus Michel (7)
- Phan Quang Minh (6)
- Michael Mundet (2)
- David Nind (477)
- Sanjar Tulkinov Anvar o'g'li (13)
- Jacob O'Mara (37)
- Lawrence O'Regan-Lloyd (5)
- Eric Phetteplace (5)
- Hannah Prince (4)
- Martin Renvoize (434)
- Olivia Reynolds (4)
- Phil Ringnalda (17)
- Jason Robb (21)
- Adolfo Rodríguez (3)
- Marcel de Rooy (35)
- Caroline Cyr La Rose (4)
- sabrina (1)
- Mathieu Saby (3)
- Lisette Scheer (103)
- Rae Schumann (18)
- Michaela Sieber (38)
- Fridolin Somers (1)
- Tadeusz „tadzik” Sośnierz (1)
- Edith Speller (2)
- Michelle Spinney (19)
- Anna Stalter (8)
- Christian Stelzenmüller (2)
- Kellie Stephens (17)
- Marisha Sullivan (1)
- Arthur Suzuki (4)
- Emmi Takkinen (5)
- Lari Taskula (1)
- Mary Teal (7)
- Felicie Thiery (2)
- Clemens Tubach (11)
- Jackie Usher (22)
- John Vinke (16)
- Baptiste Wojtkowski (30)
- Anneli Österman (14)
</div>



And people who contributed to the Koha manual during the release cycle of Koha 26.11.00
<div style="column-count: 2;">

</div>

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

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

Autogenerated release notes updated last on 26 Nov 2026 11:34:06.
