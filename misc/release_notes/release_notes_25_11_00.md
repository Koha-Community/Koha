# RELEASE NOTES FOR KOHA 25.11.00
05 Dec 2025

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 25.11.00 can be downloaded from:

- [Download](https://download.koha-community.org/koha-25.11-latest.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 25.11.00 is a major release, that comes with many new features.

It includes 3 new features, 224 enhancements, 433 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).

## New features & Enhancements

### About

#### Enhancements

- [34783](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34783) Update list of 'Contributing companies and institutions' on about page

### Accessibility

#### Enhancements

- [38642](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38642) DataTables expand button has no label

  **Sponsored by** *Athens County Public Libraries*
- [39434](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39434) The pages are missing semantic tags that identify the regions of the pages.
  >This patch adds missing semantic HTML5 elements, such as `<header>` and `<main>`, to the OPAC page structure. These changes improve the accessibility and structural clarity of the OPAC by explicitly identifying key regions of each page.
- [39677](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39677) Add the role presentation to the vertical divider in the navigation
  >Accessibility improvement: Vertical dividers in the OPAC navigation now include role="presentation" to ensure they are correctly identified as decorative elements. This provides clearer semantics for assistive technologies without affecting display or design.
- [39706](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39706) Accessibility: Missing text alternative for the star rating.
- [39982](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39982) Accessibility: The 'Browse results' menu does not have sufficient color contrast.
- [40097](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40097) Text elements on the OPAC user pages don’t have sufficient color contrast.
- [40330](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40330) Accessibility of the OPAC Labels

### Acquisitions

#### Enhancements

- [7132](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7132) Check for duplicates when creating a new record in acquisitions
  >Acquisitions: duplicate check when ordering from an empty record
  >
  >When creating a new order via Acquisitions → New order (empty record), Koha now checks for existing bibliographic duplicates (using C4::Search::FindDuplicate). If a potential match is found, staff see the standard Duplicate warning screen with options to Use existing record, Create new anyway, or Cancel and return to the basket.
  >This aligns the empty-record workflow with the existing duplicate checks used for external source imports and cataloging, reducing accidental duplicate bibs in the catalog.
- [20253](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20253) Optionally use buyer's purchase order number from EDIFACT quote in basket name
  >Libraries can now configure EDI vendor accounts to use the buyer's purchase order number from EDIFACT quote messages (RFF+ON segments) as the basket name instead of the EDIFACT filename, dramatically improving searchability and cross-referencing between Koha and vendor systems.
  >
  >**For acquisitions staff:**
  >
  >1. Go to Administration → Acquisitions → EDI accounts
  >2. Edit a vendor EDI account
  >3. Enable "Use purchase order numbers"
  >4. Save the configuration
  >
  >After this:
  >- Baskets created from EDIFACT quotes will use the purchase order number as the basket name
  >- You can easily search for and identify baskets using the same reference numbers you use with vendors
  >- The basket name field will be read-only (to preserve the purchase order number reference)
  >- If duplicate purchase order numbers are detected, you'll receive clear error messages preventing conflicts
  >
  >**Technical workflow:**
  >
  >Quote RFF+ON segment → Basket Name → Order BGM segment
  >
  >This follows EDIFACT specifications where the purchase order number from incoming quote messages should be used as the document message number in the BGM segment of outgoing ORDER messages.

  **Sponsored by** *OpenFifth*, *Royal Borough of Kensington and Chelsea* and *Westminster City Council*
- [31632](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31632) Add ability to manually link orders to suggestions
  >This enhancement allows library staff to link an order (in an unclosed basket, or a standing order) to an accepted suggestion.

  **Sponsored by** *Pymble Ladies' College*
- [34127](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34127) Allow to customize CSV export of basketgroup and add a ODS export
  >It is now possible to export any basket to CSV, even the closed ones or those linked to a group.
- [38208](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38208) Provide a link to ERM agreements and licenses from a vendor record
- [38298](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38298) EDIFACT breadcrumbs need to be permissions based
  >This fixes the breadcrumbs to EDI accounts, so that the 'Administration' breadcrumb link is not shown if the staff patron doesn't have permission to access administration pages, but does have permission to manage EDIT accounts (Acquisitions > Administration > EDI accounts).
  >
  >What happens after this change:
  >- Administration permissions: sees Administration > EDI accounts (no change)
  >- Only Manage EDIFACT transmissions (edi_manage) permissions: sees Acquisitions > EDI accounts (previously Administration > EDI accounts was shown, but they couldn't access the administration pages)
- [38619](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38619) UNIMARC prices should also be extracted from 071d
  >This enhancement imports the value in 071$d to the price field when adding an item to a basket using the "From a new file" option. Before this, it only imported the value from 010$d and 345$d.
- [39468](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39468) EDI message status should be case insensitive
  >Fix EDI message status display in acquisitions so matching is case-insensitive by converting edi_order.status to lowercase before comparison.
- [40333](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40333) When EDIFACT is enabled, one should be able view the corresponding EDIFACT INVOICE message on the Koha Invoice page
  >The invoice display page now includes a section showing information about the EDIFACT interchange file that was used to create the invoice, with the ability to view the raw EDIFACT message data.
  >
  >Previously, when troubleshooting EDIFACT invoices or verifying invoice data against the original EDIFACT message, staff had to navigate separately to the EDIFACT messages administration page and search for the corresponding message file. This enhancement provides direct access from the invoice page, improving workflow efficiency and traceability.
  >
  >**Key features:**
  >
  >- **EDIFACT interchange information**: Display of message type, transfer date, status, and filename directly on the invoice page
  >- **Raw message viewer**: "View EDIFACT interchange" button opens a modal displaying the complete raw EDIFACT data
  >- **Error visibility**: Any EDIFACT processing errors are displayed prominently on the invoice page in a warning box
  >- **Smart display**: The EDIFACT section only appears when the EDIFACT system is enabled and the invoice has an associated message
  >
  >**For acquisitions staff:**
  >
  >When viewing an invoice that was created from an EDIFACT message, you'll now see an "EDIFACT interchange" section after the vendor information. This section shows:
  >- The interchange filename
  >- Message type (e.g., INVOIC)
  >- Transfer date and status
  >- Any errors that occurred during processing
  >- A button to view the complete raw EDIFACT data
  >
  >This enhancement is particularly useful for:
  >- Troubleshooting invoice discrepancies
  >- Verifying that EDIFACT data was parsed correctly
  >- Supporting queries about invoice details
  >- Training staff on EDIFACT processing

  **Sponsored by** *Open Fifth*
- [40334](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40334) When EDIFACT is enabled, one should be able view the corresponding EDIFACT QUOTE and ORDER messages on the Koha Basket page

  **Sponsored by** *Open Fifth*
- [40942](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40942) Vendor's contacts  not displayed nicely on the vendor detail view
- [41119](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41119) Autocompletion of basket creator does not work in acquisition-home.pl

### Architecture, internals, and plumbing

#### Enhancements

- [30915](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30915) "Scalar" TT plugin no longer needed
  >This patch set removes the Context TT plugin which only contained the Scalar method. This was only used a few times in the codebase. (We do not expect them to be used in notices on larger scale.)
  >
  >The db revision will warn users for (adjusted) notices that contain this construct if any. Occurrences like [% Context.Scalar(x,y) %] can be replaced by [% x.y %]. If x.y returns a list, change to x.y.size.
- [31149](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31149) Use dayjs to parse dates
  >REVERTED
- [32176](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32176) Correctly display patrons when selected after autocomplete (was js/patron-autocomplete.js need another option)
- [35451](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35451) Add tablename field to additional_field_values
- [35761](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35761) Add an administration editor for FTP and SFTP servers
  >Koha now includes a unified administration interface for managing FTP and SFTP server connections, eliminating the need to duplicate connection details across different parts of the system.
  >
  >This new centralised configuration system allows you to define FTP and SFTP server credentials once and then reference them from multiple features (such as EDI). If a password changes or a vendor upgrades from FTP to SFTP, only a single configuration record needs updating.
  >
  >**Key features:**
  >
  >- **Unified server management**: Configure FTP and SFTP servers under Administration → File transports
  >- **Secure credential storage**: Passwords and SSH keys are encrypted in the database
  >- **Connection testing**: Test connections directly from the Koha interface to verify credentials and connectivity
  >- **Granular permissions**: New `manage_file_transports` permission controls access to the configuration interface
  >- **Reusable configurations**: Server configurations can be referenced by multiple features, reducing duplication
  >
  >**Configuration options:**
  >
  >- Transport type (FTP or SFTP)
  >- Server hostname and port
  >- Username and password
  >- Upload and download directories
  >- Connection settings (passive mode, debug mode)
  >- SSH private key (for SFTP)
  >
  >**For administrators:**
  >
  >Access the new file transport management under Administration → File transports. The interface includes a connection testing feature that validates your credentials and checks read/write permissions on the configured directories.
  >
  >**Future extensibility:**
  >
  >This architecture provides a foundation for adding file transport capabilities to other Koha features such as `runreport.pl`, `export_records.pl`, and `export_borrowers.pl`, allowing them to upload outputs directly to remote servers.
- [36674](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36674) Lazy load api-client JS files
- [38201](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38201) VueJS architecture rethink
  >The idea behind this bug was to introduce a framework for building Vue applications and components that would allow a developer to make use of pre-existing components and logic, rather than having to write everything from scratch. Currently in Koha, we have a lot of bespoke logic for each different form/display page as well as a lot of repeated code. This can make regressions more likely and reduce code consistency. To address this, we have introduced standardised components for rendering form elements (e.g. inputs, selects) and displaying data, as well as a standardised ‘list’ component. This means that each new Vue module can be built very quickly without the need to write out all the HTML structure and logic for creating a form/display page - the developer can simply access the pre-written logic in the framework to do the heavy lifting for them.
  >
  >The FormElement and ShowElement components are at the core of this work, as they render the different input and display options in a standardised manner. These are made use of by ResourceFormSave, ResourceShow and ResourceList which act as generic components that can be used by the developer to handle any Koha data type. To prove this, all the existing Vue modules (ERM, Preservation, Record Resources and Vendors) have been migrated to use it. A new suite of cypress tests has been written to verify the functionality as well as catch regressions and part of this is introducing component testing into Koha for any future Vue work that may need it.
  >
  >Moving forwards, the aim would be that new modules are built using this framework. It is important to note that the framework is not restrictive - it is possible to inject bespoke components directly into FormElement and ShowElement where there are particularly niche requirements. However, the goal is that if the developer feels that there could be a need for that requirement in future for someone else, then the goal should be to expand the framework to support it so that all can benefit. We have documented this through the use of JSDoc in base-resource.js, as well as with an example SkeletonResource.vue to show how it should be used. There are also the live examples in the modules mentioned above.
- [38311](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38311) DataTables - Simplify the building of the dropdown list filters
- [38363](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38363) get_template_and_user and checkauth don't use C4::Output for rendering auth pages
- [38489](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38489) EDI should be updated to use the new FTP/SFTP Servers management page
  >EDI (EDIFACT) transport configuration has been completely refactored to use the unified file transport system introduced in Bug 35761 and Bug 39190, eliminating the duplication of FTP/SFTP server configuration that previously existed between EDI accounts and the file transport administration.
  >
  >Previously, EDI accounts stored their own FTP/SFTP connection details (host, port, username, password) separately from the FTP/SFTP servers configuration, leading to duplicate maintenance. Now, EDI accounts simply reference a configured file transport, with the transport handling all connection management.
  >
  >**Key changes:**
  >
  >- **Unified configuration**: EDI accounts now select an existing file transport for upload and download operations rather than storing duplicate connection details
  >- **Automatic migration**: Existing EDI transport configurations are automatically migrated to file transport records during upgrade
  >- **Enhanced transport capabilities**: EDI now benefits from the file transport system's connection testing, status monitoring, and encrypted credential storage
  >- **New 'local' transport type**: Added support for local directory operations, useful for development and testing
  >- **Simplified EDI interface**: The EDI account form now uses dropdown selectors for file transports instead of requiring manual entry of connection details
  >
  >**Technical improvements:**
  >
  >- Removed 184 lines of legacy FTP/SFTP connection code from `Koha::Edifact::Transport`
  >- Added `rename_file()` method to transport classes for EDI file processing workflow
  >- Added `disconnect()` method for proper connection cleanup
  >- Standardised `list_files()` API across all transport types
  >- All transport classes now return consistent data structures
  >
  >**For administrators:**
  >
  >When upgrading, your existing EDI transport configurations will be automatically converted to file transport records. After upgrade, you'll manage FTP/SFTP credentials in one place (Administration → File transports) rather than duplicating them for each EDI account.

  **Sponsored by** *ByWater Solutions*
- [38936](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38936) Move suppressed record redirection into a sub
- [39190](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39190) Rework new (S)FTP classes to be polymorphic classes
  >The SFTP server configuration (introduced in Bug 35761) has been significantly enhanced and renamed to 'File transports' to support multiple transport protocols through a polymorphic architecture.
  >
  >This enhancement adds full transport protocol handling for both FTP and SFTP connections, including connection testing and SSH key management for SFTP. The system now uses polymorphic classes that automatically instantiate the correct transport handler (FTP or SFTP) based on the configured protocol type.
  >
  >**Key features:**
  >
  >- **Automatic connection testing**: When saving a transport configuration, Koha now tests the connection in the background and stores detailed status information
  >- **SFTP key handling**: SSH private keys for SFTP connections are securely stored and automatically written to the filesystem when needed
  >- **Protocol-specific methods**: Each transport type (FTP/SFTP) has its own specialised connection handling whilst sharing common configuration storage
  >- **Enhanced status reporting**: Connection status is now stored as detailed JSON data rather than simple text
  >- **Renamed administration**: The admin interface and API have been renamed from 'sftp_servers' to 'file_transports' to reflect the multi-protocol nature
  >
  >**Technical changes:**
  >
  >- New base class `Koha::File::Transport` handles configuration storage
  >- Protocol-specific subclasses `Koha::File::Transport::FTP` and `Koha::File::Transport::SFTP` implement transport methods
  >- Background job `Koha::BackgroundJob::TestTransport` handles connection testing
  >- API endpoint renamed from `/config/sftp_servers` to `/config/file_transports`
  >- Admin page renamed from `admin/sftp_servers.pl` to `admin/file_transports.pl`
  >
  >This architecture makes it straightforward to add additional transport protocols in the future (such as cloud storage services) whilst keeping protocol-specific logic cleanly separated.
- [39488](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39488) Update Koha::Object(s) to allow for polymorphic classing
  >Koha's object framework now supports polymorphic classing, allowing different object subclasses to be instantiated based on field values in shared database tables.
  >
  >This enhancement updates `Koha::Object` and `Koha::Objects` classes to pass the original `DBIx::Class` result object to the `object_class` method, enabling dynamic class selection based on record content. This works across all standard retrieval methods including `find`, `find_or_create`, `single`, `next`, `last`, and `as_list`.
  >
  >**Use cases:**
  >
  >- Transport protocols (FTP/SFTP) sharing a common table but requiring protocol-specific methods
  >- Account lines where debits and credits share a table but need type-specific behaviour
  >- Any scenario where related object types share storage but require distinct method implementations
  >
  >**For developers:**
  >
  >To implement polymorphic classes, define a `_polymorphic_class_map` method in your `Koha::Objects` class that returns a hashref mapping field values to class names. The framework will automatically instantiate the appropriate subclass based on the stored data.
  >
  >A template for implementing polymorphic classes is included in the codebase. Test::Builder has also been updated to introspect polymorphic class maps for comprehensive testing.
- [39906](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39906) Add bot challenge (in Apache layer)
  >When enabled, external HTTP requests to key Koha OPAC pages are challenged using a Javascript script.
- [40037](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40037) Redundant check in `notices_content` hook handling
- [40055](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40055) C4::Reserves::MoveReserve should be passed objects
- [40058](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40058) Move RevertWaitingStatus to Koha::Hold->revert_waiting()
  >This development refactors and existing function into a class method. The idea is that the code gets simplified, and also improve performance as the method acts on the already instantiated object instead of fetching it from the DB, internally.
- [40101](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40101) Add `Koha::Patron->can_place_holds`
- [40275](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40275) Add Koha::Patrons->find_by_identifier()
- [40286](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40286) Make C4::Auth::checkpw_internal use Koha::Patrons->find_by_identifier
- [40337](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40337) checkprevcheckout must be defined as ENUM at DB level
- [40527](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40527) Add SECURITY.md to Koha
  >This enhancement adds a markdown file to the Koha project repository to make it clear how to report security issues.
- [40579](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40579) CSV formula injection protection
- [40919](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40919) Unnecessary DB access in Koha::Item::Transfer->receive
- [40958](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40958) Move patron_to_html (from js-patron-format.inc) to a standalone JS file
- [41031](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41031) Extractor::MARC->new does not check if metadata is a MARC::Record
- [41153](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41153) (Follow-up of 40559) Cleanup catalogue/MARCdetail.pl

### Authentication

#### Enhancements

- [30724](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30724) Add ability for administrator to reset a users 2FA
  >This enhancement enables superlibrarians to turn off two-factor authentication (2FA) for a staff patron when they lose access to their authenticator application or device. This is accessed from the patron's account > More > Manage two-factor authentication.

  **Sponsored by** *ByWater Solutions*
- [34164](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34164) OAuth2/OIDC should redirect to page that initiated login
- [37711](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37711) IdP auto-register should work on the staff interface
  >The 'auto-register' feature can now be enabled in the staff interface.
  >
  >Previously, this functionality was only available in the OPAC and could not be used from the staff side.

  **Sponsored by** *ByWater Solutions*
- [40943](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40943) Store session_id in userenv

### Cataloging

#### Enhancements

- [29980](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29980) Validate ISBN when cataloguing bibliographic records
  >This enhancement adds a new cataloging plugin (value builder) for validating ISBNs. If you enter an invalid ISBN, a browser pop-up window warns that the ISBN is invalid, but you can ignore this (the field is highlighted in yellow) and still save the record.
  >
  >For new installations, the validate_isbn.pl plugin is added to the bibliographic frameworks by default for 020$a (MARC21) or 010$a (UNIMARC).
  >
  >For existing installations, update your frameworks manually.
- [35654](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35654) Add option to delete_items.pl to delete record if existing item getting deleted is the only one attached to the bib
  >This patch updates the delete_items script to use Koha::Items->search instead of a direct database query.
  >
  >Using a --where option that refers to the items table by name such as:
  >./misc/cronjobs/delete_items.pl --where "items.withdrawn = 0" 
  >
  >will no longer work and result in an error:
  >execute failed: Unknown column 'items.withdrawn' in 'where clause'
  >
  >Use the --where option without naming the items table instead:
  >./misc/cronjobs/delete_items.pl --where "withdrawn = 0"

  **Sponsored by** *Cape Libraries Automated Materials Sharing*
- [37604](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37604) Give skip_open_orders checkbox an ID in batch record deletion template
  >This enhancement adds an ID to the "Skip bibliographic records with open acquisition orders" checkbox on the batch record deletion page (Cataloging > Batch editing > Batch record deletion").
  >
  >This is required so that when selecting or unselecting the checkbox, the focus remains on the checkbox. The ID semantically links the checkbox to its label so machines (screenreaders and computers) can tell they are related elements.
- [38330](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38330) Make bib-level suppression a biblio table field instead of part of a MARC tag
- [39507](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39507) Make the MARC21 008 plugin more precise for MU
- [39545](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39545) Construct more complete 773 content when creating a child record

  **Sponsored by** *Open Fifth*
- [39880](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39880) Add shelving location to cn_browser.tt
  >This enhancement adds the shelving location column to the table for the call number browser cataloging plugin (cn_browser.pl, often added to bibliographic frameworks for 952$o - Full call number).
- [40017](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40017) Z39.50 search: Allow leader and specific control field positions in Additional fields
  >This enhancement to the AdditionalFieldsInZ3950ResultSearch and AdditionalFieldsInZ3950ResultAuthSearch system preferences improves what you can show for the additional fields in the Z39.50 search results:
  >
  >[1] the complete leader with 000
  >[2] the complete control field, for example 008
  >[3] specific positions in the leader or control fields, for example 000p1, 008p2, etc.
  >[4] a range from the leader or control field, for example 000p6-7, 008p35-37, etc.
- [40839](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40839) Advanced cataloging editor z39.50 search should include Keyword in Advanced Search options
  >This patch makes keyword searching available when performing a z39.50 search via the advanced search modal in the advanced cataloging editor.
- [41015](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41015) Z39.50 searching in Advanced Cataloging Editor is not clearly labeled
  >This enhancement updates the labels for the advanced cataloging editor search form to make it clear that it is a Z39.50/SRU search. (It changes "Search" to "Z39.50/SRU search", and the advanced search form is changed from "Advanced search" to "Advanced Z39.50/SRU search").

### Circulation

#### Enhancements

- [9762](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9762) Log circulation overrides
  >**Summary:**
  >Koha circulation actions (checkout, renewal, return) previously lacked detailed logging when staff overrode system restrictions, making it difficult to audit and track these important decisions.
  >
  >**Fix:**
  >Added comprehensive override logging that captures when staff bypass circulation restrictions:
  >  - **JSON Action Logs:** All circulation overrides now log structured data including confirmation codes (`DEBT`, `AGE_RESTRICTION`, `ON_RESERVE`, etc.) and forced override reasons
  >  - **Consistent Format:** Standardized JSON logging across all circulation operations (AddIssue, AddRenewal)
  >  - **Enhanced Display:** Action log viewer shows human-readable descriptions of overrides (e.g., "Patron is restricted", "Renewal limit override")
  >  - **Comprehensive Coverage:** Tracks overrides for patron restrictions, age limits, checkout limits, holds conflicts, fine overrides, and more
  >
  >**Impact:**
  >Provides complete audit trail for circulation policy overrides, improving accountability and compliance reporting. Librarians can now easily track when and why staff bypassed system restrictions during checkout, renewal, and return operations.
  >
  >  **Technical Details:**
  >  Override information is stored as JSON in action logs with format:
  >  ```json
  >  {
  >    "issue": 123,
  >    "itemnumber": 456,
  >    "confirmations": ["DEBT", "AGE_RESTRICTION"],
  >    "forced": ["TOO_MANY"]
  >  }
  >  ```

  **Sponsored by** *OpenFifth* and *Solutions inLibro inc.*
- [20644](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20644) Per itemtype setting for CheckPrevCheckout
  >This enhancement extends the CheckPrevCheckout functionality to item types. With this change, if the CheckPrevCheckouts system preference is set to either "Unless overridden by patron category or by item type, do" or "Unless overridden by patron category or by item type, do not", an additional option will appear in the item type definition. This allows libraries to customize whether Koha should warn staff when a patron has already checked out the same title, on a per–item type basis.
- [23010](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23010) If an item is checked out or in transit it should not be able to be marked withdrawn
  >This enhancement adds a new system preference, PreventWithDrawingItemsStatus. When the system preference is enabled it will prevent items that are in-transit or checked out from being withdrawn.
  >
  >** Sponsored by Cuyahoga County Public Library **
- [35669](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35669) Update check in message for a specific authorised value in the LOST authorised values
  >This enhancement displays the LOST authorized value description when checking an item in, instead of the generic "Item was lost, now found." message. For example, if the LOST value description is "Missing" it will now display as "Item was Missing, now found.".
- [36455](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36455) Default the hold queue link to your logged in library
  >This enhancement defaults the holds queue link on the Circulation home page (and corresponding navigation links) to the currently logged in branch. This reduces the number of clicks to run the holds queue for the typical library without adding any additional clicks should the queue need generated for an alternate branch or all branches.
- [36789](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36789) Transform a booking into checkout

  **Sponsored by** *Association de Gestion des Œuvres Sociales d'Inria (AGOS)* and *LMS Cloud*
- [37661](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37661) Disable/Enable Bookings
  >The booking module can now be turned off via system preference "EnableBooking"
- [39642](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39642) Add SMS number to hold found modals on return.tt
  >Enhancement: The “Hold for:” section in the waiting-hold and transfer-hold modals now displays the patron’s SMS alert number (if present). This makes it easier for staff to quickly see contact details when processing holds.
- [39881](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39881) Add patron card number to the 'On hold for' column on the transfers to receive page
  >This enhancement adds the patron's card number to the transfers to receive page for patrons shown in the 'on hold for' column, for item-level holds (Circulation > Transfers > Transfers to receive).
- [39923](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39923) Add classes to email and phone in overdue report to allow for customization
  >This patches adds a overdue_email and overdue_phone to the overdue report making it easier to target the phone/email with CSS or JavaScript.

  **Sponsored by** *Athens County Public Libraries*
- [40656](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40656) bookings/list.tt needs to be refactored
- [40665](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40665) Add booking_id field to issues to link checkouts to bookings that were fulfilled by them

### Command-line Utilities

#### Enhancements

- [38115](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38115) Add FTP support to export_records.pl
- [38306](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38306) Make automatic_renewals.pl cronjob quiet if EnhancedMessagingPreferences syspref is off

  **Sponsored by** *Catalyst*
- [38404](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38404) Make clear in RestrictPatronsWithFailedNotices syspref description that restrict_patrons_with_failed_notices.pl cronjob has default days setting
- [40545](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40545) Add a CLI script to manually reset 2FA settings
  >This enhancement adds a new command-line script (misc/admin/reset_2fa.pl) that allows administrators to reset a patron's two-factor authentication settings when they lose access to their authenticator device.

  **Sponsored by** *ByWater Solutions*
- [40722](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40722) Add logging to reset of elastic mappings files when rebuilding elastic
- [40964](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40964) koha-elasticsearch is missing --where option

  **Sponsored by** *HKS3* and *Koha DACH Hackfest*

### Course reserves

#### Enhancements

- [40699](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40699) Preferred name not displayed for instructors in course reserves in staff interface

### Developer documentation

#### Enhancements

- [38997](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38997) Remove reference to "members" in SendAlerts
- [40458](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40458) Discharge.pm is missing pod coverage

### ERM

#### Enhancements

- [36831](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36831) Add support for .txt files to the KBART import tool
  >This enhancement allows the KBART import tool to accept different file types and then work out whether they are CSV or TSV files. (This is useful for detecting what the separation character is for KBART files in .txt format.)
- [36942](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36942) Throw an exception if a KBART file can't be read
  >25.11.00
- [39345](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39345) Koha must support COUNTER 5.1
  >This enhancement adds support to the ERM module for Release 5.1 of the Code of Practice for COUNTER Metrics that came into force in January 2025, with a requirement for reports to be delivered by the 28th of February 2025.
- [40141](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40141) Add "Run" and "Test" buttons to data provider toolbar

### Hold requests

#### New features

- [15516](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15516) Allow to place a hold on first available item from a group of titles
  >This features allows a patron to place a hold on the first available item from a group of titles on the staff interface or OPAC.

  **Sponsored by** *Catalyst*
- [36135](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36135) Add tool to batch modify holds
  >This patchset adds a new feature that allows for the batch modification of holds via a new tool. It also adds a new permission to allow use of the batch modify holds tool.

  **Sponsored by** *Koha-Suomi Oy*

#### Enhancements

- [31698](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31698) Add ability to move a hold to a new bibliographic record/item
  >This enhancement allows for staff to move item level holds to new items and record level holds to new records. From the holds list page ( reserve/request.pl ) staff will now see the option to "Move selected holds" if they have the alter_hold_target permission. When the button is clicked a modal will be presented allowing staff to choose a new record target for record level holds or a new item target for item level holds. 
  >
  >This patch also adds the new permission that is required to move holds, alter_hold_target.
  >
  >Sponsored by: Cuyahoga County Public Library
- [37651](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37651) biblio->current_holds and item->current_holds do not respect ConfirmFutureHolds
- [38939](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38939) Add reservenote to members/holdshistory.pl
  >This enhancement add a 'Hold note' column to the patron's hold history table. It is configurable via administration's Table settings.
- [40335](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40335) Holds queue does not allow multiselect
  >Allows the selection of multiple values for collection code or shelving location when running the Holds queue.
- [40395](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40395) Allow selecting multiple holds in patron detail page to perform actions on
  >This enhancement adds a 'checkbox' column to the patron holds table located on the 'Holds' tab on the patron 'Details' page and the patron 'Check out' page.
  >It also reimplements suspending and cancelling multiple holds on these pages from a UI/UX point of view.
  >Before, the user was required to check the box under the 'Delete?' column for the respective hold and then click a 'Cancel marked holds' button alongside a cancellation reason.
  >Now, the user selects the holds they want to cancel and click a new 'Cancel selected holds' button. This reworked button now shows the hold cancellation modal, becoming more consistent to what happens when cancelling holds in other pages where this action is also possible.
  >Suspending multiple holds has received the same treatment, with the additional benefit that is now possible to suspend a set of selected holds, rather than only being able to suspend either a single or all holds.
  >This work also serves as preparation for future holds 'bulk actions' on these patron pages, now that selecting multiple holds on these pages has been standardized.
- [40517](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40517) Allow grouping existing holds
  >Staff can now group existing patron holds together directly from the patron holds table, in addition to creating hold groups when placing new holds.
  >
  >Previously, hold groups could only be created when placing new holds (if the DisplayAddHoldGroups system preference was enabled). With this enhancement, staff can now select multiple existing holds from a patron's holds list and group them together using a new "Group selected" button.
  >
  >**Key features:**
  >
  >- **Group selected button**: Select two or more holds from the patron holds table and click "Group selected" to create a new hold group
  >- **Visual group IDs**: Hold groups are displayed with easy-to-understand sequential numbers (1, 2, 3, etc.) rather than internal database IDs
  >- **Automatic cleanup**: If a hold group is left with only one hold (or none) after cancellations or fulfilment, the group is automatically deleted
  >- **Smart restrictions**: You cannot group holds that have already been found (waiting for pickup)
  >- **Multiple groups**: Create as many different hold groups as needed for a patron
  >
  >**Using hold groups:**
  >
  >1. Navigate to a patron's record and click the "Holds" tab
  >2. Select two or more holds using the checkboxes
  >3. Click the "Group selected" button and confirm
  >4. The holds are now grouped together with a visual group ID displayed in the holds table
  >5. Click on the group number to view or manage the hold group
  >
  >**For administrators:**
  >
  >This feature requires the DisplayAddHoldGroups system preference to be enabled. The new "Group selected" button appears alongside other hold management buttons on patron holds pages.
  >
  >**REST API:**
  >
  >A new API endpoint `/api/v1/patrons/{patron_id}/hold_groups` has been added to support listing and creating hold groups programmatically.
- [40529](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40529) Update how hold groups work
  >This patchset changes how hold groups work: Previously, only Waiting holds triggered group-based actions by cancelling other holds in the group. Now, when a hold in a group becomes In transit or Waiting, it is designated as the group's target hold. Subsequent check-ins skip other holds in the same group unless the target is cancelled, allowing a new target to be set. This improves hold fulfillment logic and supports dynamic reassignment of target holds. The behavior applies to check-ins, holds to pull and the holds queue.
- [40551](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40551) Make patron page holds table use API endpoint for cancellation
  >The patron holds tables on the patron details page, circulation page, and holds management page (reserve/request.pl) now use a REST API endpoint for cancelling holds, with bulk cancellations processed as background jobs.
  >
  >Previously, hold cancellations from these pages were processed synchronously through traditional page requests. When cancelling multiple holds at once, this could cause delays or timeouts on pages with many holds.
  >
  >**Key improvements:**
  >
  >- **Background processing**: Bulk hold cancellations are now queued as background jobs, preventing page timeouts when cancelling multiple holds
  >- **Consistent interface**: Selecting and cancelling holds works the same way across all patron-related holds tables (patron details, circulation, and holds management pages)
  >- **Better performance**: The page doesn't need to wait for all cancellations to complete before refreshing
  >
  >**For staff:** When you cancel selected holds, the page may not refresh immediately. The cancellations are being processed in the background. You can check the status of the background job in Administration → Jobs.
  >
  >**Technical details:**
  >
  >This enhancement adds a new `/holds/cancellation_bulk` API endpoint (Bug 40550) that accepts multiple hold IDs and queues their cancellations as a background job, improving the reliability and user experience when managing large numbers of holds.
- [40552](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40552) Allow selecting all holds from a group
- [40613](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40613) Allow ungrouping holds

### ILL

#### Enhancements

- [37901](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37901) Add ILL pseudonymization
  >This enhancement adds 2 new types of statistics related to Interlibrary loans: ILL request created, and ILL request completed.
  >Additionally, if Pseudonymization is enabled, pseudonymized transactions will be created from these statistics.
  >
  >Technical changes:
  >- Database table 'pseudonymized_borrower_attributes' renamed to 'pseudonymized_metadata_values'. Existing reports that reference this table should be updated accordingly on upgrade.
  >- Adds 'illrequest_id' column to statistics table

  **Sponsored by** *UK Health Security Agency*
- [38928](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38928) Openurl 'id' or 'rft_id' may contain key information
- [39773](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39773) OPAC ILL form does not use client-side form validation for required fields
  >The OPAC interlibrary loan request form now uses browser-based client-side validation for required fields. When creating a new ILL request, required fields (such as request type) are validated before the form is submitted, providing immediate feedback to users if required information is missing.
  >
  >This enhancement improves the user experience by:
  >- Highlighting required fields that are empty when the user attempts to submit
  >- Preventing incomplete forms from being submitted to the server
  >- Reducing unnecessary page reloads for validation errors
  >
  >This validation applies to both authenticated ILL requests and unauthenticated requests (when the ILLOpacUnauthenticatedRequest system preference is enabled).
- [39917](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39917) Display a prompt for status alias when completing a request if ILL_STATUS_ALIAS in use
  >This enhancement to ILL requests lets you select a 'status alias' when marking requests as complete. This is only shown when values are defined for the ILL_STATUS_ALIAS authorized values category. The alias is then shown in the status field on the request details page, and in the status column for the list of ILL requests. If there are no values defined, then you are not prompted to select a status alias.

  **Sponsored by** *NHS England (National Health Service England)*
- [39918](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39918) Unauthenticated request data should show when editing a request
  >This fixes the edit form for an unauthenticated ILL request in the staff interface - it now shows the details for the person who made the request (name and email address).
  >
  >(This is a follow-up to Bug 36197 - Allow unauthenticated ILL requests in the OPAC, a new feature added in Koha 25.05.)
- [40005](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40005) Manage request page should show accessurl
  >This enhancement adds the 'Access URL' field to the manage ILL request page, if a value exists (depending on the backend). Before this, it was only shown in the table listing all requests.
- [40012](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40012) Standard form missing publisher for journal articles
- [40024](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40024) Backends that don't support get_requested_partners capability show a '(0)' in status
  >This enhancement removes the '(0)' for the ILL request status field, where the ILL backend does not support the 'get_requested_partners' capability. (The method returns '0' if the backend does not implement the capability. The template checks for 'length', and length of '0' is '1'.)
- [40026](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40026) Edit item metadata should present Standard form if AutoILLBackendPriority is in use
- [40075](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40075) ILL Standard form should only show libraries that are pickup_locations
- [40262](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40262) ILL - Save the fact that copyright clearance has been confirmed by the patron
  >This enhancement to copyright clearance for interlibrary loan requests:
  >- records the copyright clearance in the database (it previously wasn't)
  >- shows the message "Patron has confirmed copyright clearance for this request" on the request page
  >
  >(This requires text in the ILLModuleCopyrightClearance HTML customization.)
- [40850](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40850) Add `Koha::ILL::Request->add_or_update_attributes`
- [40856](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40856) Improve Standard backend metadata retrieval

### Label/patron card printing

#### Enhancements

- [40366](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40366) Update the label export process to avoid Greybox modal

  **Sponsored by** *Athens County Public Libraries*
- [40412](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40412) Update the patron card export process to avoid Greybox modal

  **Sponsored by** *Athens County Public Libraries*
- [40414](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40414) Update patron card layout with expiry date

### Lists

#### Enhancements

- [39145](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39145) Differentiate between deleting or transferring public and shared lists
  >This enhancement to the lists feature adds a new option to the ListOwnershipUponPatronDeletion system preference - "change owner of public lists, delete shared lists".
  >
  >When the patron that created a list is deleted (and this option is set):
  >- the owner of any public lists are changed (to the patron deleting the patron, or the patron set in ListOwnerDesignated), and 
  >- any shared lists are deleted.

### MARC Authority data support

#### Enhancements

- [33296](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33296) Linker should search for authority records with an appropriate 008/14,15,16 value
- [38514](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38514) Filter out autocomplete list of authorities with ConsiderHeadingUse
  >This patch updates the authority search in cataloging to exclude results from the autocomplete that would be excluded from the search based on ConsiderHeadingUse and MARC21 field 008/14-16 indication of what the heading can be used for (main/added entry, subject entry, series entry).

### MARC Bibliographic data support

#### Enhancements

- [29733](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29733) MARC21: Link 7xx linking fields to marc21_linking_section.pl value builder in sample frameworks
- [39860](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39860) Add a way to allow for additional/custom MARC fields in the record display
  >Adds a way to enhance bibliographic displays including the staff interface result and detail pages, and the OPAC's result and detail pages. This is done through "Tools" > "Additional content" >  "Record display customizations".
- [40071](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40071) MARC21 Addition to relator terms in technical notice 2025-06-04
  >This enhancement adds a new relator term "waw - Writer of afterword" to the RELTERMS authorized values list (from the MARC21 4 June 2025 technical notice).
  >
  >Note: This change only affects new installations. For existing installations, manually update the RELTERMS authorized values list.
- [40072](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40072) MARC21 Addition to relator terms in technical notice 2025-04-03
  >This enhancement to the RELTERMS authorized values list (from the MARC21 3 April 2025 technical notice):
  >- adds a new relator term "wfw - Writer of foreword"
  >- removes the deprecated relator term "aui - Author of introduction, etc."
  >
  >Notes:
  >1. This change only affects new installations. 
  >2. For existing installations, manually update the RELTERMS authorized values list to reflect the changes from the technical notice.
  >2. As there is a deprecated term (aui):
  >   - Importing records with a nonexistent value will not delete data from the records. It will simply say "aui (Not an authorized value)". 
  >   - For existing installations and records, use batch record modification before deleting the deprecated term (aui), where required.
- [40073](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40073) MARC21 Addition to relator terms in technical notice 2025-02-06
  >This enhancement adds two new relator terms to the RELTERMS authorized values list (from the MARC21 6 February 2025 technical notice):
  >- ink - Inker
  >- pnc - Penciller
  >
  >Note: This change only affects new installations. For existing installations, manually update the RELTERMS authorized values list.
- [40272](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40272) Add an alert for incorrect (MARC21) fixed-length control fields
  >This proposal adds an alert when opening the MARC basic editor while a control field (005-008) has an incorrect length.
- [40284](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40284) MARC21: Adjust maxlength for 005, 006 and 007
- [40482](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40482) bookcover/bookcoverimg class in search results show include more data-attributes for customization
  >This enhancement adds data-attributes to the bookcover class in the OPAC and staff interface search results. This will make it easier to customization based on those attributes.

### MARC Bibliographic record staging/import

#### Enhancements

- [38661](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38661) Add warning when deleting import batch

### Notices

#### Enhancements

- [36020](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36020) Port default recall notices to Template Toolkit
  >This enhancement adds recalls to the objects that can be called using Template Toolkit and updates the default notices for RETURN_RECALLED_ITEM, PICKUP_RECALLED_ITEM, and RECALL_REQUESTER_DET notices. 
  >
  >It uses [% INCLUDE 'biblio-title.inc' biblio=biblio link=0 %]  and [% INCLUDE 'patron-title.inc' patron => borrower, no_title => 1, no_html = 1 %] to pull in the title and patron information. 
  >
  >Existing installations will not see changes to their notices but they can be viewed using the "See default" button when editing the notice.
- [36114](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36114) Port default TRANSFERSLIP notice to Template Toolkit syntax
- [36127](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36127) Port default HOLDPLACED and HOLD_CHANGED notices to Template Toolkit syntax
- [39280](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39280) Generalize ODUE notice text - remove "If an item becomes more than 30 days overdue, you will be unable to use your library card until the item is returned."
  >This enhancement removes unnecessary or misleading text from the ODUE notice, as it depends on the library's settings: "If an item becomes more than 30 days overdue, you will be unable to use your library card until the item is returned.".
  >
  >Note: The notice is not automatically updated for existing installations. Update the notice manually to change the wording if required, or replace the default notice using "View default" and "Copy to template" if you have not customized the notice.
- [39883](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39883) NEW_SUGGESTION email notices end up in the patrons notice tab (members/notices.pl) when they should not
  >The patch makes it so NEW_SUGGESTION email notices do not show up in a patron's notice history.

### OPAC

#### Enhancements

- [18148](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18148) Make list of lists in OPAC sortable
  >When reviewing a list of public or private lists in the OPAC, users can now sort the list of lists by "List name" or "Modification date" in ascending or descending order.
- [38792](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38792) Move "My virtual card" tab and maybe re-label it

  **Sponsored by** *Athens County Public Libraries*
- [39411](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39411) Add card number and patron expiration info to OPAC Virtual Card
- [39925](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39925) Table columns missing headings for bibliographic search history in OPAC

  **Sponsored by** *Athens County Public Libraries*
- [40129](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40129) Always show the "Not finding what you're looking for" links in opac-results.tt
- [40143](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40143) Add links to private lists in OPAC bibliographic record detail pages
  >This enhancement lets patron see links to their own private lists on OPAC bibliographic record detail pages. Previously, only public lists were shown.
- [40221](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40221) Replace layout tables for component part display

  **Sponsored by** *Athens County Public Libraries*

### Packaging

#### Enhancements

- [40164](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40164) Add Template::Plugin::JSON to handle JSON in Template Toolkit
  >This patch adds a new Template::Toolkit library to Koha's dependencies. This library, while not directly used in Koha, can be used in Template::Toolkit-driven templates to access JSON structures (e.g. notices, report templates, etc).
  >
  >A good example is making report templates that include JSON columns, like `background_jobs.data`.

### Patrons

#### Enhancements

- [22632](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22632) Add logging of merged patrons
  >This enhancement adds details of patron merges to the log viewer (when BorrowersLog is enabled).
- [26258](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26258) Circulation tabs inconsistent with counters
  >This enhancement changes the markup, style, and behaviour of counters which are displayed on a patron's check out and details tabs:
  >1. A new style: the counter background has a light blue square with rounded corners
  >2. The claims tab:
  >   . The order of the counters is now Unresolved claims / Resolved claims
  >   . The background colour for the counter changes to orange when the value set in ClaimReturnedWarningThreshold is reached
  >3. The restrictions tab: the counter background color is red
  >4. The clubs tab: now only shows the number of clubs a patron is enrolled in (the count of available clubs is removed)

  **Sponsored by** *Athens County Public Libraries*
- [30568](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30568) Make patron name fields more flexible
- [32581](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32581) Update dateexpiry on categorycode change
- [33647](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33647) Display borrowers.lastseen in patron record
  >If the system preference TrackLastPatronActivityTriggers has no triggers enabled, a patron's 'last seen' date will be displayed in their patron record.
- [40082](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40082) PatronDuplicateMatchingAddFields isn't respected in the OPAC or the API
- [40245](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40245) Support option to display firstname in patron search results when different than preferred_name
  >A new system preference 'ShowFirstIfDifferentThanPreferred' toggles the ability for a patron's documented first name to be displayed alongside their Preferred name, when different, during patron search. This allows for library staff to easier identify and distinguish between patron record with similar names or when an ID does not match the patron's preferred name.

  **Sponsored by** *Westlake Porter Public Library*
- [40251](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40251) Icon for self-check user permission
- [40367](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40367) Improve display of messages on patron account
  >This adjusts the way patron messages are displayed on a patron account, grouping messages together and labeling them based on whether they are internal staff notes or OPAC messages.

### Plugin architecture

#### Enhancements

- [34978](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34978) Add --include and --exclude options to install_plugins.pl to choose the plugins to install
  >This enhancement adds new parameters to the install_plugins.pl script to specify which plugins to install.
  >
  >New parameters :
  >--include <PluginClass> (repeatable) install ONLY the plugins specified
  >
  >--exclude <PluginClass> (repeatable) install all the plugins EXCEPT the ones specified
  >
  >The parameters require the full plugin class (e.g. Koha::Plugin::PluginName). 
  >
  >The parameters *cannot* be used simultaneously.
- [39632](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39632) Failed plugin install gives too little info
- [40653](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40653) plugins/run.pl controller drops authentication if logging in to that route
- [40827](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40827) Update plugin wrapper to include context for method="report"
  >This enhancement updates the plugin wrapper to include the reports menu and have the breadcrumbs list reports instead of admin or tools when method="report"

### REST API

#### Enhancements

- [38931](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38931) Add endpoints for individual credits and debits
- [39091](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39091) Cash registers should have a list API endpoint
- [39816](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39816) Allow embedding `days_late` in baskets
  >This development adds the ability to embed information on late days on the basket objects retrieved from the API.
- [39830](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39830) Add order claim object definition
- [39900](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39900) Add public REST endpoint for additional_contents
  >A new public REST API endpoint has been added for retrieving additional contents (news items and HTML customisations) without authentication. This enables external applications and websites to access and display Koha news and custom content.
  >
  >**Endpoint details:**
  >- **Path:** `/api/v1/public/additional_contents`
  >- **Method:** GET
  >- **Authentication:** None required (public endpoint)
  >- **Query parameters:**
  >  - Standard search and filter parameters for finding specific content
  >  - `lang`: Filter by language code to retrieve content in a specific language
  >  - `embed`: Use `translated_contents` to include all available translations
  >
  >**Key features:**
  >
  >- **Public access**: No authentication required, making it suitable for displaying library news on external websites
  >- **Multi-language support**: Retrieve content in specific languages or fetch all translations at once using the `translated_contents` embed
  >- **Flexible filtering**: Search and filter additional contents using standard API query parameters
  >- **Content types**: Access both news items and HTML customisations through the same endpoint
  >
  >**For developers:**
  >
  >This endpoint follows the same patterns as other Koha public API endpoints. Use the `lang` parameter to retrieve content for a specific language, or use `embed=translated_contents` to get all available translations in a single request. This is particularly useful for multi-lingual library websites that need to display Koha news items.
  >
  >**Example use cases:**
  >- Displaying library news on an external website
  >- Integrating OPAC announcements into a library portal
  >- Building mobile applications that show library notices
  >- Creating custom displays of library information
- [40176](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40176) Add maxLength to the item definition
- [40177](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40177) Add maxLength to the library definition
- [40178](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40178) Add maxLength to the patron definition
- [40179](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40179) Add maxLength to the patron's category definition
- [40417](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40417) Search_rs is re-instating deleted query parameters
- [40423](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40423) Handling x-koha-request-id relies on wrong data structure
- [40424](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40424) Handling query-in-body relies on wrong data structure
- [40434](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40434) Add maxLength to the vendor definition
- [40511](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40511) Add maxLength to the eHoldings title definition
- [40512](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40512) Add maxLength to the erm agreements definition
- [40542](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40542) Add `cancellation_reason` to holds strings embed
- [40550](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40550) Add /holds/cancellation_bulk endpoint
  >A new REST API endpoint `/api/v1/holds/cancellation_bulk` has been added to support cancelling multiple holds in a single request, with the cancellations processed as a background job.
  >
  >This endpoint accepts an array of hold IDs and optionally a cancellation reason, then queues a background job to process the cancellations asynchronously. This prevents timeouts and improves performance when cancelling large numbers of holds.
  >
  >**Endpoint details:**
  >- **Method:** POST
  >- **Path:** `/api/v1/holds/cancellation_bulk`
  >- **Parameters:** 
  >  - `hold_ids` (required): Array of hold IDs to cancel
  >  - `cancellation_reason` (optional): Reason for cancellation
  >- **Response:** Returns a background job ID for tracking the cancellation progress
  >
  >**For developers:**
  >
  >This endpoint is used by the staff interface patron holds tables (Bug 40551) to handle bulk hold cancellations. The background job approach ensures reliable processing even when dealing with hundreds of holds, and allows the user interface to remain responsive.
  >
  >**Required permissions:**
  >- `reserveforothers` - Place and modify holds for patrons

### Reports

#### Enhancements

- [23978](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23978) Notes field in saved reports should allow for (scrubbed) HTML
  >This enhancement to the notes field for saved SQL reports now allows the use of selected HTML in the field.
- [40425](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40425) Guided report - "Next" button on last step is misleading
  >This enhancement to quided reports renames the label for the last step from "Next" to "Save" - this reflects the actual behavour.

### Searching

#### Enhancements

- [28702](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28702) Improve performance of C4/XSLT/buildKohaItemsNamespace
- [33646](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33646) "Cataloging search" missing important data for not for loan items
- [33729](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33729) Add  a column for dateaccessioned to item search results
- [36947](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36947) Sort Elasticsearch/Zebra facets according to configurable locale instead of using Perl's stringwise/bytewise sort

### Searching - Elasticsearch

#### Enhancements

- [39526](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39526) Unify system preference variable names for Elasticsearch

  **Sponsored by** *HKS3*
- [39636](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39636) Add options to compare_es_to_db script
  >The `compare_es_to_db.pl` script now supports the `-b/--biblios` and `-a/--authorities` options, allowing checks to be limited to a single index.
  >
  >Additionally, the generated Elasticsearch curl link has been updated to align with the latest version structure.
- [40890](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40890) Make batch_size configurable for koha-es-indexer
  >A new configuration entry has been introduced in `koha-conf.xml` to control how many Elasticsearch update tasks the indexer processes per iteration.
  >
  >Previously, the indexer defaulted to a batch size of 10. While the `koha-es-indexer` command supported overriding this with the `--batch_size` parameter, there was no way to set a different default value.
  >
  >This change is particularly beneficial for large sites, where the indexer may otherwise struggle to keep pace with the update queue during peak activity.

### Serials

#### Enhancements

- [37115](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37115) Add the option to delete linked serials when deleting items
- [37116](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37116) Add the option to edit linked serials when editing items
- [40070](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40070) Make appending published date to serial enumeration optional on detail pages
  >Enhancement: A new system preference, DisplayPublishedDate, has been added to control whether the published date is shown after the volume/numbering information in holdings tables. When enabled, the date will appear in parentheses in both the OPAC and staff interface (Serial/Enumeration and Vol info columns). When disabled, the date is hidden.

### Staff interface

#### Enhancements

- [27934](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27934) Table sorting using title-string option is obsolete
- [30148](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30148) Pipe separated contents are hard to customize (staff interface)
- [36518](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36518) Add unique IDs to the fieldsets of the item search form to facilitate customization
  >This enhancement adds IDs to the fieldsets on the staff interface search form (Search > Item search), to make CSS customization easier. The fieldset IDs are:
  >- Library and location section: librarylocation
  >- Item information section: access_and_condition
  >- Barcode search section: barcodesearch
  >- Call number section: callnumber_checkouts
- [37883](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37883) Add a filter for staff search results to filter by library
  >This enhancement adds the system preference  FilterSearchResultsByLoggedInBranch. When turned on this feature will allow librarians to filter search results to only show those belonging to the logged in branch. This selection will be set in the browser's localStorage.
- [38438](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38438) Make Add persistent selections and batch operations to item search optional
- [38942](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38942) Item template toolbar is not like other toolbars
  >This enhancement improves the item-template-toolbar in Koha, adding some classes to be consistent with other toolbars in Koha.
- [40086](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40086) Table settings for Article Requests tables
  >This enhancement adds table configuration options to the article request tables (Circulation > Patron request > Article requests). You can now choose the columns to show, copy the shareable link, and configure the default columns (columns to hide by default, columns that can't be changed, and set the default sort order).

  **Sponsored by** *Athens County Public Libraries*
- [40288](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40288) patron details in patron sidebar overflow the sidebar
- [40615](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40615) Update mention of 'My virtual card' in OPACVirtualCard description
- [40757](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40757) Highlight circulation rules on click

### System Administration

#### New features

- [37893](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37893) Migrate some SIP configuration into the staff interface
  >This update introduces a new SIP2 module that allows staff members with the new sip2 permission to manage SIP2 institutions, accounts, and system preference overrides directly in the UI. When upgrading to 25.11, the relevant SIPConfig.xml settings are automatically migrated into the database. These settings can then be edited in the UI, and the SIP server will pick up any changes immediately without needing a restart. This makes configuring SIP2 easier, removing the need for server access to edit XML files or restart the SIP server for these settings.
  >Server params and listeners are intentionally not included in this work and must still be configured in the SIPConfig.xml file.

  **Sponsored by** *ByWater Solutions*

#### Enhancements

- [38863](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38863) Show bookings options on itemtypes.pl

  **Sponsored by** *Athens County Public Libraries*
- [39824](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39824) Add a direct link to default framework in MARC bibliographic frameworks page
  >This patch adds a direct link to default framework from the MARC bibliographic frameworks page.
- [39825](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39825) Add a direct link to items tag in MARC bibliographic framework page
  >Enhancement: Added direct link to items tag in MARC bibliographic framework
  >
  >This enhancement adds a “View items tag (952)” button to the MARC bibliographic framework page (995 in UNIMARC). This provides a faster way to access the items tag subfields without needing to search manually.
- [39897](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39897) Make EDI accounts a configurable DataTable
  >This enhancement converts the EDI accounts table from a standard table to a DataTable - so you can now sort, filter, configure the columns, export the data, and so on (Koha administration > Acquisition parameters > EDI accounts).

  **Sponsored by** *Athens County Public Libraries*
- [40343](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40343) Koha to MARC mapping should suggest to run batchRebuildItemsTables.pl
  >This enhancement updates the information message on the Koha to MARC mapping page to mention that batchRebuildItemsTables.pl should also be run if changes are made to mappings that affect the items table. It currently only mentions running misc/batchRebuildBiblioTables.pl
- [40418](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40418) Update the item type translation process to avoid Greybox modal

  **Sponsored by** *Athens County Public Libraries*

### Templates

#### Enhancements

- [16721](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16721) Add table configuration to serial claims table

  **Sponsored by** *Athens County Public Libraries*
- [28146](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28146) E-mail address used on error pages should respect ReplytoDefault
- [36095](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36095) Improve translation of title tags: OPAC part 2

  **Sponsored by** *Athens County Public Libraries*
- [38877](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38877) Improve translation of title tags: OPAC part 3

  **Sponsored by** *Athens County Public Libraries*
- [39448](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39448) Layout improvement for search filter administration

  **Sponsored by** *Athens County Public Libraries*
- [39809](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39809) .required class was made too non-specific in Bootstrap upgrade
  >This patch corrects the styling of required fields so that the text entered in the input is no longer shown in red. Previously, the .required class was incorrectly applied to the input itself rather than just the label and required indicator.
- [39948](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39948) Simplify unauthenticated ILL request detail in the OPAC
  >This enhancement simplifies the unauthenticated ILL submission detail page for the OPAC. It removes 'Unauthenticated ...' in front of the labels for the first name, last name, and email fields.
- [39960](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39960) Improve messages in the OPAC ask for a discharge page (opac-discharge.tt)
  >This enhancement improves the messages in the OPAC on the ask for a discharge page (Your account > Ask for discharge, when the useDischarge system preference is enabled).
  >
  >Improvements:
  >- Improved wording for the number of items checked out: instead of "..2 item(s).." and "..1 item(s)..." the text changes based on the actual number of checkouts - "...2 items..." and "...an item...".
  >- More succinct text: for example, instead of "Please pay your charges before reapplying.", "Please pay them before reapplying."
- [40172](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40172) Remove jQuery from js/fetch/http-client.js
- [40422](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40422) Remove Greybox assets from the staff interface

  **Sponsored by** *Athens County Public Libraries*
- [40606](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40606) Remove italics from shelving location in the staff interface
  >This enhancement removes the italics formatting from the shelving location in a record's holdings table, now that it is in its own column. (The formatting was there to differentiate the shelving location from the library name when they were in the same column. This is not necessary anymore.) 
  >
  >(This is a follow-up to Bug 15461 - Add shelving location to holdings table as a separate column, added in Koha 25.04.)

### Test Suite

#### Enhancements

- [39876](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39876) Centralize listing of files from our codebase
- [39877](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39877) CI - Incremental runs
  >25.11.00
- [40170](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40170) Replace cypress-mysql with mysql2
- [40173](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40173) Reuse http-client from Cypress tests - preparation steps
- [40174](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40174) Add a way to cleanly insert data in DB from Cypress tests
- [40180](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40180) Missing Cypress tests for 'Holds to pull' library filters
- [40181](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40181) Cypress tests - Ensure that insertData does not leave data in the DB
- [40301](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40301) Missing Cypress tests for 'Type' column visibility
- [40346](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40346) Allow Cypress to test OPAC
- [40401](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40401) Implement Koha::Patron->is_anonymous (was t/db_dependent/Auth.t generates warnings)
- [40407](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40407) Remove legacy "pre-wrap" versions (was Patron/Borrower_Discharge.t generates warnings)
- [40444](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40444) Add a test to ensure all Perl test files use Test::NoWarnings
- [40447](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40447) Add documentation for cypress plugins
- [40809](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40809) JS warning should make Cypress tests fail
- [40872](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40872) opac/unapi type not detected by tidy.pl
- [41003](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41003) Missing Cypress tests for patron display

### Tools

#### Enhancements

- [34561](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34561) Move IntranetReportsHomeHTML to HTML customizations
  >This enhancement moves the IntranetReportsHomeHTML system preference into HTML customizations. This makes it possible to have language-specific and library-specific content. The option has been renamed StaffReportsHome for better consistency with other HTML customization regions.

  **Sponsored by** *Athens County Public Libraries*
- [40400](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40400) Rename club start and end date to make clearer these are for the enrollment period
  >This enhancement to patron clubs renames "Start date" and "End date" to "Enrollment start date" and "Enrollment end date", to better reflect what the dates represent.
## Bugfixes
This list includes all bugfixes since the previous major version. Most of them
have already been fixed in maintenance releases


#### Critical bugs fixed

- [40370](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40370) about.pl should NOT say "Run the following SQL to fix the database" (25.11.00,25.05.02,24.11.08)
- [40066](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40066) Cannot add order to basket from the baskets view (25.11.00,25.11.01)
  >This fixes adding items to a basket - instead of getting the pop-up window to add to the basket, the message "You can't create any orders unless you first define a budget and a fund." was shown (Acquisitions > [vendor] > Baskets > Add to basket). 
  >
  >(This is related to Bug 38010 - Migrate vendors to Vue, added to Koha 25.05.)
- [40587](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40587) Prevent selection of different EAN's on EDI ORDER when the Basket is generated from a QUOTE message (25.11.00,25.05.05)

  **Sponsored by** *OpenFifth*
- [40684](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40684) Permission error for vendors if user has not full acquisition module permission (25.11.00,25.05.04)
- [40743](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40743) Unable to select the correct fund when paying invoices (25.11.00,25.05.05)
- [40870](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40870) Fund code is lost when modifying an order in acquisitions (25.11.00,25.05.04)
- [40918](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40918) Invoice Adjustment Reason always "No reason" even if report shows a saved reason (25.11.00,25.05.05)
- [38426](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38426) Node.js v18 EOL around 25.05 release time (25.11.00)
- [40033](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40033) The background jobs page calls GetPlugins incorrectly, resulting in a 500 error (25.11.00,25.05.01,24.11.06)
  >This fixes the background jobs page (Koha administration > Jobs > Manage jobs) so that it doesn't generate a 500 error when a plugin does not have a background task (it currently calls GetPlugins incorrectly).
- [40608](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40608) Password not changed if PASSWORD_CHANGE letter absent (25.11.00,25.05.04,24.11.10)
- [40671](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40671) Expand Koha::Hold->revert_waiting to handle all found statuses (25.11.00,25.05.04)
- [40680](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40680) Many warnings on Perl 5.40 due to importing methods from not yet defined packages (25.11.00)
- [40748](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40748) Remote-Code-Execution (RCE) in update_social_data.pl (25.11.00,25.05.04,24.11.09,24.05.12,22.11.31)
- [41328](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41328) All KohaTable tables broken in Vue components (25.11.00)
- [41336](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41336) Vue Router warn on Vue datatable pages (25.11.00)
- [41354](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41354) Error when loading "Record sources" Vue app (25.11.00)
- [41355](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41355) No 'show' view for record sources (25.11.00)
  >This fixes the list of record sources (Administration > Catalog > Record sources) - it removes the links from entries in the name column (all the link did was reload the page).
- [41357](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41357) New SIP2 module is broken
  >25.11.00
- [40544](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40544) Manage bundle button broken (25.11.00,25.05.03,24.11.09)
  >Fixes the "Manage bundle" feature broken by Bug 40127
- [40997](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40997) Javascript error prevents saving when an instance of an 'important' or 'required' field is deleted (25.11.00,25.05.05,24.11.11)
- [38477](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38477) Regression: new overdue fine applied incorrectly when using "Refund lost item charge and charge new overdue fine" option in circ rules (25.11.00,25.05.01,24.11.06)
  >Under certain circumstances, the existence of a lost charge for a patron that previously borrowed an item (which was later found) could lead to creating a new fine for a patron that borrowed and returned the item with no issues - if the item was lost and found again after they had returned it.
  >
  >This adds tests to cover this edge case, and fixes this edge case to ensure that a new fine is only charged if the patron charged the lost fine matches the patron who most recently returned the item.
- [40205](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40205) "Default checkout, hold and return policy" cannot be unset (25.11.00,25.05.06,24.11.11)
- [40296](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40296) Bookings that are checked out do not have status updated to completed (25.11.00,25.05.03,24.11.09)
- [40739](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40739) Setting TransfersBlockCirc to 'Don't block' does not allow for scanning to continue (25.11.00,25.05.04)
  >This patch fixes a bug where setting TransfersBlockCirc to 'Don't block' did not allow scanning to continue after the modal pop-up was displayed.
- [41314](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41314) Column visibility broken on the checkouts table (25.11.00,25.05.06)
  >This fixes the display of the 'Export' column on a patron's check out and details sections when ExportCircHistory is enabled and disabled. Because of a regression (caused by DataTable's saveState, bug 33484), the column was not correctly shown unless you cleared the cache/local storage:
  >- If ExportCircHistory was set to 'Show', it is shown the first time.
  >- If ExportCircHistory is then set to 'Don't show', the export column continues to show until you clear the browser cache/local storage.
- [31124](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31124) koha-remove fails to remove long_tasks queue daemon, so koha-create for same <instance> user fails (25.11.00,25.05.01,24.11.08)
  >This development makes `koha-remove` stop all worker processes before attempting to remove the instance's UNIX user.
- [40953](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40953) marc_ordering_process.pl broken due to accidental newline (25.11.00,25.05.05,24.11.11)
- [41099](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41099) koha-mysql doesn't work out of the box on Debian 13
- [37622](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37622) "location" header is set for non-POST routes (25.11.00,25.05.05,24.11.11)
- [38446](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38446) Permission error for additional fields (25.11.00,25.05.06)

  **Sponsored by** *Karlsruhe Institute of Technology (KIT)*
- [39823](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39823) SUSHI harvest fails to display error if the provider's response does not contain Severity (25.11.00,25.05.01,24.11.06)
  >This fixes SUSHI harvests for ERM. It now displays an error message when running a report/harvest, where there is no severity marker returned for the error. Previously (even if the test connect passed), only a red bar with no error message was shown.
- [40198](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40198) Datatables search for data providers is broken (25.11.00,25.05.03,24.11.09)
- [40774](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40774) EBSCO Packages search box is missing (25.11.00,25.05.04)
- [41063](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41063) Additional fields are broken in Vue (values entered are not saved) (25.11.00)
  >This fixes the saving of data for additional fields for modules in Koha that use Vue (ERM, Preservation, Acquisitions). The data entered for additional fields is now saved, instead of being ignored and lost. For example, data for additional fields added to ERM agreements was not being saved, but now are.
- [40620](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40620) Holds Queue will assign to the lowest item number if multiple branches have the same transport cost (25.11.00,25.05.03,24.11.10)
- [40654](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40654) Sorting holds table can cause priority issues (25.11.00,25.05.03,24.11.09)
  >This patchset fixes a problem where hold priority could be incorrectly updated depending on how the table is sorted on reserve/request.tt.
- [40755](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40755) Hold cancellation requests cause error 500 on holds waiting page (25.11.00,25.05.04)
- [40057](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40057) Database update 24.12.00.017 fails if old ILL data points to non-existent borrowernumber (25.11.00,25.05.01,24.11.07)
  >This fixes a database update related to ILL requests, for bug 32630 - Don't delete ILL requests when patron is deleted, added in Koha 25.05.
  >
  >Background: Some databases have very old ILL requests where 'borrowernumber' has a value of a borrowernumber that doesn't exist. We're not exactly how the data ended up this way, but it's happened at least twice now for one provider.
- [40292](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40292) SQL syntax error when upgrading to 25.05 on MariaDB 10.3, RENAME COLUMN unsupported (25.11.00,25.05.05)
- [41167](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41167) Rewrite Rules missing in etc/koha-httpd.conf (25.11.00,25.05.06,24.11.11)
- [40092](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40092) Clicking save doesn't fill auto-populated fields in authority and biblio editor (25.11.00,25.05.02,24.11.08)
  >This fixes a regression between Koha 24.11, and 25.05 and main. When adding a new authority or bibliographic record, clicking save (without filling in any fields) now restores filling in the auto-populated fields such as 000, 003, and 008.
- [38102](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38102) Checkout history in OPAC displaying more than 50 items (25.11.00,25.05.02,24.11.08)
- [38974](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38974) Error when submitting patron update from the OPAC Can't call method "dateofbirthrequired" on an undefined value (25.11.00,25.05.03,24.11.08)
  >This fixes updating personal details in the OPAC. A 500 error was shown if the "Patron category (categorycode)" was selected in the PatronSelfModificationBorrowerUnwantedField system preference and the date of birth field was changed or previously empty.
- [35830](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35830) Add separate permission for Merging Patrons (25.11.00,25.05.06,24.11.11,24.05.16,22.11.33)

  **Sponsored by** *Cape Libraries Automated Materials Sharing*
- [41094](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41094) search_anonymize_candidates returns too many candidates when FailedLoginAttempts is empty (25.11.00,25.05.06,24.11.11)
- [41364](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41364) Error in preservation module breadcrumb (25.11.00)
- [39336](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39336) Public Biblio endpoint should honour OpacSuppression syspref (25.11.00)
- [40819](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40819) Guided reports select column should not be initialized as select2 (25.11.00,25.05.04)
- [39911](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39911) Fatal errors from SIP server are not logged (25.11.00,25.05.01,24.11.08)
  >This restores the logging of fatal SIP errors to both the SIP logs and standard output from the command line.
- [38072](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38072) Regression with modalPrint (25.11.00,25.05.06,24.11.11)
  >This fixes a regression when printing dialogue boxes in certain Chromium-based browsers, for example, when printing the cashup summary for the point of sale system. Sometimes the print dialog failed to open, and instead you were faced with a flash of white before the new tab automatically closed and didn't print.
- [39930](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39930) Saved configuration states on tables are lost overnight (25.11.00,25.05.04,24.11.10)
- [40127](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40127) JS error on biblio detail page when there are no items (25.11.00,25.05.02,24.11.08)
  >This fixes a JavaScript error on bibliographic record pages in the staff interface, where the record has no items.
- [40753](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40753) DT's SaveState not working on the orders table (25.11.00,25.05.04)
  >This fixes the basket order table so that when you close (or reopen) a basket, the columns shown remain the same as the table configuration. Before this fix, if you closed a basket and then reopened it, the table settings columns hidden by default were ignored and all the possible columns were shown.
- [40866](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40866) Corrections to override logging (25.11.00,25.05.05)
- [41042](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41042) Table setting 'default sort order' not available for existing installations (25.11.00,25.05.05)
- [41229](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41229) Cash registers are not fully reset on library change (25.11.00,25.05.06,24.11.11)
- [39482](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39482) Link to edit OpacLibraryInfo from library edit page broken
  >This fixes editing and showing OpacLibraryInfo HTML customizations information in the staff interface and OPAC:
  >
  >1. Staff interface:
  >   - When editing a library (Koha administration > Libraries > Actions > Edit)
  >     . the links to edit OpacLibraryInfo entries for the OPAC information field are now correct (previously, they may have linked to an incorrect HTML customization)
  >     . if there is more than one OpacLibraryInfo entry, all entries are now shown (only one entry was shown previously)
  >   - When viewing library information (Koha administration > Libraries > Name > [click library name]), all the OpacLibraryInfo entries are now shown
  >
  >2. OPAC:
  >   - All the entries for a library (including any 'All libraries' entries for OpacLibraryInfo) are now shown on the library information page (from the 'Libraries' link under the quick search bar)
  >   - In a record's holdings table, the pop-up window when you click on the current library for an item now correctly shows all entries

  **Sponsored by** *Athens County Public Libraries*
- [40655](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40655) Transport cost matrix doesn't save changes (25.11.00,25.05.05)
  >This fixes a problem with the transport cost matrix where fields that were disabled could not be made enabled via the interface,
- [40161](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40161) New translation not displayed when translating an item type (25.11.00,25.05.02)
- [40430](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40430) Toolbar_spec.ts is failing (25.11.00,25.05.03)
- [40765](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40765) Acquisition tests will fail if order.quantity is set to 0 (25.11.00,25.05.04,24.11.10)
- [41274](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41274) Incremental test runs not properly skipping Schema files (25.11.00)
- [39289](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39289) Batch extend due date tool only displays the first 20 checkouts (25.11.00,25.05.02)
- [41079](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41079) Checkboxes visible on the batch patron modification results view (25.11.00,25.05.05)

#### Other bugs fixed

- [32244](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32244) Add Vue and Cypress to the About Koha > Licenses page (25.11.00,25.05.03)
  >This adds Cypress and Vue to the About Koha > Licenses page.
- [40022](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40022) Release team 25.11 (25.11.00,25.05.02,24.11.08,22.11.30)
- [40466](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40466) Zebra status misleading in "Server information" tab. (25.11.00,25.05.03,24.11.09)
- [40468](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40468) Terminology on the About > Licenses page - use US American spelling for license (25.11.00,25.05.04)
  >This fixes the Koha about > Licenses page to use the US American spelling for license (instead of licence, which is the British English spelling).
- [40692](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40692) Wrong color background in Perl modules page (25.11.00,25.05.04)
- [29069](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29069) Accessibility: "Refine your search" link doesn't have sufficient contrast (25.11.00,25.05.03)
- [39475](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39475) WCAG 2.1: 1.4.10 - Content reflow - OPAC header menus (25.11.00,25.05.01)
  >This fixes some accessibility reflow issues in dropdown menus for the OPAC when larger text sizes are used (for example, 400%). It specifies the text-wrap behaviour, and by reducing line-height values in some places it makes dropdown items more distinguishable from each other. This includes:
  >- Lists: a list with a very long name now wraps, instead of staying on one line that goes off the screen.
  >- User menu (when logged in): the 'Clear' button next to 'Search history' now moves down to its own line.
- [39489](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39489) 'Refine your search' should have an aria-expanded attribute (25.11.00,25.05.03)
  >This fixes the "Refine your search" section in the OPAC. For screen reader users on smaller screens, it now correctly announces that it is an expandable section, instead of a link (by adding an aria-expanded attribute).
  >
  >Explanation: The 'Refine your search' expandable section in the Koha OPAC was not clearly announced by screen readers for smaller screen sizes. This is because the expandable section was identified and announced as a link. This resulted in screen reader users incorrectly expecting a link to another page, and not being informed that it was an expandable section.

  **Sponsored by** *British Museum*
- [39502](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39502) Web Usability Accessibility Audit - Decorative Images Don't Need alt Text (25.11.00,25.05.03)
- [39998](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39998) Missing presentation role on layout tables. (25.11.00,25.05.03,24.11.09)
- [40165](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40165) Incomplete logic for controlling display of OPAC language footer (25.11.00,25.05.02,24.11.08)

  **Sponsored by** *Athens County Public Libraries*
- [40609](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40609) Invisible Button Styling in "hint" Container Until Hovered (25.11.00,25.05.04,24.11.10)
- [41198](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41198) Add visible “Sort results by” label above the sort dropdown for accessibility and clarity (25.11.00,25.05.06)
  >Adds a visible “Sort results by” label above the sort dropdown in OPAC search results to improve accessibility and clarity.
- [41201](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41201) Definite article in some labels confuses screen readers (25.11.00,25.05.06)
- [36155](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36155) Improve performance of suggestion.pl when there are many budgets (25.11.00,25.05.04,24.11.09)
- [38516](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38516) Closed group basket not able to open pdf file with adobe  The root object is missing or invalid (25.11.00,25.05.06,24.11.11)
- [39572](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39572) Create EDIFACT order button no longer forces librarians to review EAN to select (25.11.00,25.05.02,24.11.08)
  >This fixes the EDIFACT order confirmation message for a basket so that the EAN information is now included on the confirmation page ([a basket for a vendor] > Create EDIFACT order > [select EAN from dropdown list], with the BasketConfirmations system preference set to 'always ask for conformation').
  >
  >Previously, the `Create EDIFACT order` action would take librarians to a page to select the EDI Library EAN. Now, the EANs are included in a dropdown list for the action. This removed the chance to review the selected EAN to confirm it was correct. In addition, some libraries have dozens of Library EANs, making the button dropdown list cumbersome to use.
- [39980](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39980) Vendors pages are broken when using Koha as a Mojolicious application (25.11.00,25.05.04)
  >This fixes vendor pages when running Koha as a Mojolicious application. You couldn't search for or create vendors (you get a page not found error). (This is related to bug 38010 - Migrate vendors to Vue, added to Koha 25.05.)
- [40036](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40036) Purchase suggestion status column no longer displays reason (25.11.00,25.05.01)
  >This restores the display of suggestion accept or reject reasons (from the SUGGEST authorized values category) in the status column for the list of purchase suggestions. (This is related to Bug 33430 - Use REST API for suggestions tables, added in Koha 25.05.)
  >
  >It also adds classes for the SUGGEST authorized values, so that these can be styled.
- [40067](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40067) "Receive shipments" should not open in a new tab/window (25.11.00,25.05.01)
  >This fixes the "Receive shipments" action from a vendor page in acquisition - it now opens the receive shipment form in the same window, instead of opening in a new tab or window.
- [40106](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40106) Language selector not displayed on some acquisition views (vue) (25.11.00,25.05.03)
- [40146](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40146) Untranslatable actions on vendor (25.11.00,25.05.04)

  **Sponsored by** *Athens County Public Libraries*
- [40318](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40318) "Receive shipments" should not open in a new tab/window - vendor list view (25.11.00,25.05.03)
  >This fixes the "Receive shipments" action from the table listing vendors in acquisitions - it now opens the receive shipment form in the same window, instead of opening in a new tab or window.
- [40483](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40483) Searching vendors by Alias no longer works (25.11.00,25.05.04)
- [40593](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40593) Can't search all columns in Acquisitions Suggestions table (25.11.00,25.05.05)
- [40861](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40861) "Odd number of elements in anonymous hash" warning in serials/acqui-search-result.pl (25.11.00,25.05.04,24.11.10)
- [40868](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40868) Vendor module permissions are ignored (25.11.00,25.05.05)
- [40982](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40982) Basket: Orders table — "Modify" and "Cancel order" columns missing or displayed incorrectly (25.11.00,25.05.05)
- [40988](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40988) Subfunds in acqui-home.pl and aqbudgets.pl are not collapsible beyond 20th line (25.11.00,25.05.06,24.11.11)
- [41088](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41088) Fix translatability for "Add new" and "Remove this" in vue (25.11.00)
- [18584](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18584) Our legacy code contains trailing-spaces (25.05.00)
- [35467](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35467) NewsLog should be renamed (25.11.00,25.05.04)
  >This renames the NewsLog system preference to AdditionalContentLog, and updates the system preference description and the log viewer tool.
- [37305](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37305) Remove C4::Biblio::prepare_marc_host and use Koha::Biblio->generate_marc_host_field in preference (25.11.00,25.05.02,24.11.08)

  **Sponsored by** *Open Fifth*
- [38966](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38966) Wrong POD in Koha/CoverImages.pm and Koha/Acquisition/Order/Claims.pm (25.11.00,25.05.02,24.11.08)
- [39834](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39834) Tabs need to be replaced with spaces (25.11.00,25.05.01)
  >This fixes several files by replacing tabs with spaces and makes the QA script happy!
- [39920](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39920) do_check_for_previous_checkout should us 'IN' over 'OR' (25.11.00,25.05.01,24.11.06)
- [40003](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40003) Warning generated when creating a new bib record (25.11.00,25.05.01,24.11.08)
  >This removes an unnecessary warning from the logs when creating a new bibliographic record, and updates the tests.
- [40030](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40030) HTML should be escaped when viewing system preferences diff in Log viewer (25.11.00,25.05.02,24.11.08)
  >This bug fixes an issue where when viewing the action logs for a system preference change, there is an option to view a comparison between different log lines for the same system preference. 
  >
  >This bug escapes the string values before displaying the comparison so that any HTML (e.g. in IntranetUserJS) is not rendered.
- [40034](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40034) CheckReserves dies if itype doesn't exist (25.11.00,25.05.01,24.11.07)
- [40041](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40041) Update mailmap for 25.11.x (25.11.00,25.05.05,24.11.11)
- [40079](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40079) C4::Scrubber "note" profile should allow for list (ul, ol, li, dl, dt, and dd) HTML tags (25.11.00,25.05.02,24.11.08)
  >This adds unordered, ordered, and description list tags (<ul>, <ol>, <li>, <dl>, <dt>, and <dd>) to the HTML that is allowed in notes fields (for example, course reserves staff and public notes).
- [40087](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40087) Remove unused C4::Scrubber profiles "tag" and "staff" (25.11.00,25.05.01,24.11.08)
  >This removes unused "tag" and "staff" scrubber profiles from the code for the scrubber module.
- [40132](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40132) Remove some POD from Koha/Template/Plugin/AdditionalContents.pm (25.11.00,25.05.03,24.11.09)
- [40150](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40150) Prevent uncaught error on multiple attempts to 'define' on 'CustomElementsRegistry' in islands.ts (25.11.00,25.05.04)
- [40163](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40163) Several http links should be moved to https (25.11.00)
- [40242](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40242) Typo in Quotes module (25.11.00,25.05.02,24.11.08)
  >This fixes a typo in the code for the quote of the day tool (there were two =>).
- [40261](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40261) Tidy `build-git-snapshot` (25.11.00,25.05.02,24.11.08)
- [40265](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40265) t/db_dependent/OAI/Server.t is failing randomly (25.11.00,25.05.05,24.11.11)
- [40277](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40277) Warn in C4::Koha::GetAuthorisedValues() (25.11.00,25.05.02,24.11.08)
  >This fixes the cause of an unnecessary warning message[1] in the logs when searching the OPAC when not logged in. (This warning was occurring when the OpacAdvancedSearchTypes system preference was set to something other than "itemtypes", for example "loc".)
  >
  >[1] Warning message:
  >[WARN] Use of uninitialized value $branch_limit in concatenation (.) or string at ...
- [40405](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40405) systempreferences.value cannot be set to NULL (25.11.00,25.05.04)
- [40516](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40516) Boolean filters are broken on datatables (25.11.00,25.05.03,24.11.09)
- [40524](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40524) Stored XSS run by DataTables Print button in staff interface (25.11.00,25.05.06,24.11.11,24.05.16,22.11.33)
  >Adds a custom function to ensure cleaner outputs when using DateTable's print button.
- [40525](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40525) CSV formula injection - client side (DataTables) in OPAC (25.11.00,25.05.05,24.11.10,24.05.15,22.11.32)
- [40535](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40535) Branches.tt view page has out of place "Category:" field (25.11.00,25.05.03)
  >This removes a category field that was mistakenly added to the library's detail page (Koha administration > Basic parameters > Libraries > view any library).
- [40559](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40559) Fix a noisy warn in catalogue/MARCdetail (25.11.00,25.05.06,24.11.11)
- [40585](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40585) Prevent crash on biblionumber in addbybiblionumber.pl (25.11.00,25.05.04,24.11.10)
- [40636](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40636) C4::Reserves::CancelExpiredReserves behavior depends on date it is run (25.11.00,25.05.04)
- [40641](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40641) Patron.pm can create warnings (25.11.00,25.05.04)
- [40663](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40663) Package GD::Barcode::QRcode@2.01 (25.11.00)
- [40725](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40725) DBRev 23.12.00.053 should be made more resilient (25.11.00,25.05.04,24.11.10)
- [40766](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40766) Reflected XSS in set-library.pl (25.11.00,25.05.04,24.11.09,24.05.12,22.11.31)
- [40773](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40773) Improve build of "vue/dist" files (25.11.00,25.05.04)
- [40818](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40818) marc_lib is mostly used raw in templates (25.11.00,25.05.05,24.11.10,24.05.15,22.11.32)
- [40820](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40820) STOMP errors even when JobsNotificationMethod='polling' (25.11.00,25.05.05,24.11.11)
- [40838](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40838) Bookings related built CSS not ignored by Git (25.11.00,25.05.04)
- [40978](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40978) t/db_dependent/Budgets.t fails on Debian 13 due to warnings (25.11.00,25.05.05,24.11.11)
- [40995](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40995) Patron search autocomplete adds extraneous spacing and punctuation when patron lacks surname (25.11.00)
- [41024](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41024) Inconsistent spelling of Borrower(s)Log (25.11.00,25.05.06,24.11.11)
- [41032](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41032) Open Fifth missing in plugin repos config (25.11.00,25.05.06,24.11.11)
  >This updates the template used when creating Koha instances  - it changes the plugin repository details for Open Fifth (previously PTFS-Europe), so that you can search and install plugins using the staff interface.
  >
  >To update existing Koha instances (where uploading and installing plugins from Git repositories is enabled) change the PTFS-Europe details to Open Fifth in the /etc/koha/sites/<instancename>/koha-conf.xml:
  >
  >  <repo>
  >     <name>Open Fifth</name>
  >     <org_name>openfifth</org_name>
  >     <service>github</service>
  >  </repo>
- [41044](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41044) Fix argument isn't numeric in addition in Koha::Item::find_booking (25.11.00,25.05.06,24.11.11)
- [41104](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41104) Samesite HTTP response header being set in C4::Auth::checkauth() (25.11.00,25.05.06,24.11.11)
- [41123](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41123) Remove useless dbh statement from Patron (25.11.00,25.05.06,24.11.11)
- [41262](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41262) Duplicate import in Koha::Patron (25.11.00,25.05.06)
- [41271](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41271) pod_coverage.t unintentionally attempts to launch a SIP server when checking SIPServer.pm (25.11.00)
- [39206](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39206) Koha improperly tries to remove foreign cookies on logout (and in general the cookies aren't actually removed, but set to empty values) (25.11.00,25.05.02)
  >This patch adds more control to Koha::CookieManager by allowing to refine its list of managed cookies with keep or remove entries in koha-conf.xml.
  >
  >IMPORTANT NOTE: The former (probably widely unused) feature of putting a regex in the do_not_remove_cookie lines is replaced by interpreting its value as a prefix. (So you should e.g. replace catalogue_editor_\d+ by just catalogue_editor_
- [41038](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41038) Add more test coverage for bug 30724 (25.11.00)
- [31460](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31460) Merging biblio records with attached item groups losing groups (25.11.00,25.05.04,24.11.10)
- [37364](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37364) Improve creation of 773 fields for item bundles regarding MARC21 245 and 264 (25.11.00,25.05.01,24.11.06)
  >Enhancement: Improved handling of publication and title information in 773$d/t for analytic records
  >
  >The logic for extracting publication information now considers both MARC fields 264 and 260, ensuring better compatibility with RDA records using 264. The system prefers the 264 field with first indicator “3” (current/latest publication) when available, falling back to the first 264 or 260 otherwise.
  >
  >The extraction of title information from field 245 has been expanded to include subfields $n and $p in addition to $a and $b. This ensures multi-part works are properly distinguished by including part/section numbers and titles in the analytic entry.
  >
  >These improvements help ensure more accurate and complete linking of analytic records to their host records, especially for multipart works and RDA cataloguing practices.
  >

  **Sponsored by** *PTFS Europe*
- [38967](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38967) Export to CSV or Barcode file from item search results fail when "select visible rows" and many items are selected (25.11.00,25.05.04,24.11.10)
- [39871](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39871) Clearing item statuses with batch item modification tool does not work correctly (25.11.00,25.05.02,24.11.08)
  >This fixes a bug with the Batch item modification tool. Previously, if library staff tried to clear the items' not-for-loan, withdrawn, lost, or damaged status using the Batch item modification tool, the fields would not be cleared correctly. Depending on the database settings, the job might fail completely and the items wouldn't be modified at all, or else the status would be cleared, but the status date (such as withdrawn_on or itemlost_on) would not be cleared. Now the tool can be used to clear those fields, just like any other non-mandatory field.
- [39991](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39991) Record comparison in vendor file - results no longer side by side (25.11.00,25.05.01,24.11.06)
  >This fixes the 'Diff' view for staged records where they match existing records - the comparison is shown side by side instead of imported record being shown below the original record (Cataloging > Manage staged records > [select a file] > View [from the Diff column for a record]).
- [40128](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40128) StripWhitespaceChars can create empty subfields (25.11.00,25.05.02,24.11.08)
- [40156](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40156) Advanced editor should not create empty fields and subfields (25.11.00,25.05.03,24.11.09)

  **Sponsored by** *Ignatianum University in Cracow*
- [40497](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40497) Item add form does not respect framework maxlength setting (25.11.00,25.05.04)

  **Sponsored by** *Athens County Public Libraries*
- [40897](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40897) Uneven field lengths in additem.tt (25.11.00,25.05.05)
- [40908](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40908) Issues with deleting items from additem page (25.11.00,25.05.05)
- [41205](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41205) Error in Advanced Cataloging editor when z39 source returns undef / empty records (25.11.00,25.05.06,24.11.11)
- [24533](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24533) Improved sorting in checkouts table (25.11.00,25.05.06)
  >This update fixes and improves how sorting works in the Checkouts table of the staff interface.
  >
  >## What was wrong before
  >
  >When checkouts were grouped into “Today’s checkouts” and “Previous checkouts,” sorting by a column (like title or branch) would break the grouping and show everything in one long list.
  >
  >Some columns also sorted incorrectly because they were linked to the wrong data.
  >
  >## What’s changed
  >
  >Sorting now keeps the Today/Previous grouping, making the list easier to understand.
  >
  >The Due date column is the exception — sorting by due date now gives you a clean list ordered by due date only, which is what most staff expect.
  >
  >All columns now sort the correct data.
- [34596](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34596) Items in transit should not show up in the holds queue (25.11.00,25.05.05)
  >This patch alters the way that the real time holds queue is rebuilt when an item is returned and a hold is found.
  >
  >Previously the queue would be rebuilt on the initial checkin, and a second time when the hold was confirmed. This led to a race condition where the item would be queued in one run, while being marked in transit during the second.
  >
  >We now delay the build of the holds queue until after the hold is either confirmed or ignored and only build it once.
- [39180](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39180) Handle and report exception at checkout/checkin due to missing guarantor (25.11.00,25.05.03,24.11.09)
  >This fixes checking out, checking in, and renewing items for a patron where a guarantor is required, and they don't have one (where the ChildNeedsGuarantor system preference is enabled).
  >
  >These actions are now completed correctly, and a warning message is now shown on the patron's page where a guarantor is required and they don't have one: "System preference 'ChildNeedsGuarantor' is enabled and this patron does not have a guarantor.".
  >
  >Previously:
  >- checking items in or out generated a 500 error message, even though the actions were successfully completed
  >- attempting to renew items generated this message "Error: Internal Server Error" and the items were not renewed
  >- no message was shown on the patron page warning that they needed a guarantor
- [39919](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39919) Overdues with fines report has incorrect title, breadcrumbs, etc. (25.11.00,25.05.01,24.11.08)

  **Sponsored by** *Athens County Public Libraries*
- [40107](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40107) Article requests: some DataTables functionality is broken (25.11.00,25.05.02)
  >This fixes JavaScript errors in the staff interface article requests table. The tables weren't refreshing, and the tab numbers weren't updating, when selecting an action for individual or multiple requests (such as 'Set request as pending').

  **Sponsored by** *Athens County Public Libraries*
- [40538](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40538) XSS in hold suspend modal in staff interface (25.11.00,25.05.03,24.11.08,24.05.13,22.11.30)
  >Fixes XSS vulnerability in suspend hold modal and suspend hold button by refactoring the Javascript that creates the HTML.
- [40643](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40643) circulation.tt attaches event listeners to keypress in a problematic way (25.11.00,25.05.04,24.11.10)
- [40644](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40644) Bookings biblio checks erroneously if multiple check-outs and bookings exist (25.11.00,25.05.04,24.11.10)
- [40678](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40678) Choices are not remembered if a wrong transfer modal is generated (25.11.00,25.05.04,24.11.10)
  >This patchset fixes a bug where the "Drop box mode" and "Forgive overdue charges" checkbox values were not retained when a wrong transfer modal is displayed.
- [40679](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40679) Existing holds toolbar goes wonky if you select 'del' from priority dropdown (25.11.00,25.05.04,24.11.10)
  >Fixes a problem in the UI that would make the toolbar look wrong when 'del' is selected in the priority dropdown on reserve/request.tt
- [40689](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40689) "Lost status" and "Damaged status" don't appear on moredetail.pl if user can't update them (25.11.00,25.05.04,24.11.10)
- [40690](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40690) Checkout status doesn't appear on moredetail.pl if item is not checked out (25.11.00,25.05.04,24.11.10)
- [40708](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40708) Increase accuracy and accessibility of checkin errors (25.11.00,25.05.04)
- [40709](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40709) Status filter will display in wrong column if item-level_itypes is set to bibliographic record (25.11.00,25.05.04,24.11.10)
- [40899](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40899) When placing multiple holds at once the individual "Pickup location:" dropdowns do not update when changing the top level "Pickup at:" dropdown" (25.11.00,25.05.05,24.11.11)
  >This fixes a problem where the item specific branch choice was not being set correctly when placing a hold on multiple items at the same time in the staff interface.
- [41149](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41149) Spinner/loader does not disappear when a renewal fails with AllowRenewalOnHoldOverride set to dont allow (25.11.00,25.05.06,24.11.11)
- [41211](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41211) Cannot cancel patron holds in some cases (25.11.00)
- [41298](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41298) Filtering holdings table with status In transit considers every item ever transferred to be "In transit" (25.11.00,25.05.06,24.11.11)
- [23883](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23883) sip_cli_emulator.pl - typo in parameter name (25.11.00,25.05.02,24.11.08)
- [35700](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35700) Holds reminder cronjob --triggered switch does not work as intended if the day to send notice hits concurrent holidays (25.11.00,25.05.05,24.11.11)
  >This bugfix adds a check to the hold reminders cronjob so the job will skip if today is a holiday when the --holiday flag is used. 
  >
  >This will prevent the notice from repeating reminders that would send on a usually closed day again on the next open day.
- [39532](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39532) Script debar_patrons_with_fines.pl should not use MANUAL restriction type (25.11.00,25.05.06)
- [39740](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39740) [Follow-up of 36932] Split dev_install into git_install and debug_mode (25.11.00)
- [39887](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39887) Improve documentation of overdue_notices.pl (25.11.00,25.05.01,24.11.06,24.05.12)
  >This improves the help for the misc/cronjobs/overdue_notices.pl script.
  >
  >It tidies the text and clarifies some options, including:
  >- improving the descriptions for the help --test, --date, --email, and --frombranch options
  >- adding some more usage examples (shown when run with the --man option)
- [39961](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39961) koha-create doesn't start all queues (25.11.00,25.05.01,24.11.08)
  >This fixes the koha-create and koha-disable package commands so that they start and stop all the background job worker queues (including long_tasks).
- [40144](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40144) `sip_cli_emulator.pl` warnings (25.11.00,25.05.02,24.11.08)
- [40785](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40785) Cronjob cleanup_database.pl usage is outdated (25.11.00,25.05.05,24.11.11)
- [41008](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41008) bulkmarcimport.pl -d broken for authorities (25.11.00,25.05.06,24.11.11)
- [36033](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36033) Table pseudonymized_transactions needs more indexes (24.05.00,23.11.06,23.05.12)
- [38906](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38906) REGEXP_REPLACE not in MySQL < 5.7b DB update 24.06.00.064 fails (25.11.00,25.05.04,24.11.10)
- [40109](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40109) Path to fix_invalid_dates.pl is incorrect in fix_invalid_dates.pl and search_for_data_inconsistencies.pl (25.11.00,25.05.02,24.11.08)
  >This fixes a path in a hint in the search for data inconsistencies script (search_for_data_inconsistencies.pl) - misc/cronjobs/fix_invalid_dates.pl should be misc/maintenance/fix_invalid_dates.pl.
- [40027](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40027) Use GitHub workflow to automatically close PRs opened on the Koha repo there (25.11.00,25.05.05,24.11.11)
- [38899](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38899) Allow the Vue toolbar to be sticky (25.11.00,25.05.01)
  >This restores the sticky toolbar when adding a vendor in the acquisitions module (Acquisitions > + New vendor). This is related to bug 38010, which migrates vendors in the acquisitions module to using Vue - the sticky menu was not included in this.
- [39951](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39951) Column filters are offset in ERM (25.11.00,25.05.02)
- [41001](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41001) Dismissing the "Run now" modal breaks functionality (25.11.00)
- [41103](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41103) Click on data providers platform breaks functionality (25.11.00)
- [38412](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38412) Koha should warn when hold on bibliographic record requires hold policy override (25.11.00,25.05.03,24.11.09)

  **Sponsored by** *BibLibre* and *Westlake Porter Public Library*
- [39912](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39912) RealTimeHoldsQueue should be rebuilt when a holds pickup location is changed (25.11.00,25.05.02,24.11.08)
- [40118](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40118) Regression - 'Holds to pull' library filters don't work (25.11.00,25.05.02,24.11.08)
- [40122](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40122) 'Holds to pull' library filters don't work if library name contains parenthesis (25.11.00,25.05.02,24.11.08)
  >This fixes the holds to pull page so that the dropdown library filter works if the library name contains parenthesis (Circulation > Holds and bookings > Holds to pull).
- [40331](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40331) Extra transfer generated when transfer for hold cancelled due to checkin at incorrect library (25.11.00,25.05.04,24.11.10)
- [40515](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40515) Mark as lost and notify patron is broken in pendingreserves.pl (25.11.00,25.05.04,24.11.10)
- [40530](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40530) Show hold cancellation reason in patron holds history (25.11.00,25.05.03,24.11.09)
  >This fixes the status message when a hold is cancelled on the patron's holds history page in the staff interface. It displayed "Cancelled(FIXME)", instead of the actual reason. (This is related to bug 35560 - Use the REST API for holds history, added in Koha 25.05.00 and 24.11.05.)
- [40586](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40586) opac-user, holds-table.inc: Include on order status when item.notforloan < 0 (25.11.00,25.05.04)
- [40672](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40672) `desk_id` not cleared when `revert_found()` called (25.11.00,25.05.04)
- [40747](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40747) Placeholder text in the filter row for Publication Details on the holds queue is incorrect (25.11.00,25.05.04,24.11.10)
- [40929](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40929) Can't call method "borrowernumber" on an undefined value at opac-modrequest.pl (25.11.00,25.05.05,24.11.11)
- [40985](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40985) Clarify POD of Holds->filter_by_found (25.11.00,25.05.05,24.11.11)
- [38633](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38633) Calendar - Weekly closures are ignored when setting a yearly repeating holiday (25.11.00,25.05.04,24.11.10)
- [20601](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20601) Untranslatable strings in circulation statistics (25.11.00,25.05.02)
  >This fixes and enhances the circulation statistics report wizard:
  >- Fixes some strings so that they are now translatable
  >- Fixes the patron library dropdown list so that it now works
  >- Improves the "Filtered on" information shown before the report results:
  >  . the filtered on options selected in the report are now shown in bold
  >  . descriptions are now shown instead of codes (for example, the library name instead of the library code)

  **Sponsored by** *Athens County Public Libraries*
- [33856](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33856) Inventory tool CSV export contains untranslatable strings (25.11.00,25.05.04,24.11.09)
- [37926](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37926) Bookings - "to" untranslatable (25.11.00,25.05.04,24.11.10)

  **Sponsored by** *Athens County Public Libraries*
- [40510](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40510) Add context to the word "More" in several templates (25.11.00,25.05.04)

  **Sponsored by** *Athens County Public Libraries*
- [39875](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39875) ILL - History check fails if unauthenticated request (25.11.00,25.05.01)
  >This fixes the ILL request history check (added in Koha 25.05 by bug 38441 - Allow for an ILL history check workflow stage). If there is no patron, or it is an unauthenticated request, then the check to see if the same request has been made is no longer performed (requires enbaling the ILLHistoryCheck system preference).
- [40025](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40025) Standard ILL requests don't update form when changing type in edit item metadata (25.11.00,25.05.01)
  >This fixes editing the item metadata for a standard ILL request. If the type (such as book or journal) is changed, the metadata is now updated for the selected type. Before this, matching metadata was not updated.
- [40171](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40171) ILL Patron Has No Email Address on File message upon "Send Notice To Patron" (25.11.00,25.05.02,24.11.11)
  >Staff members now receive clear feedback when attempting to send ILL notices to patrons who have no email address on file or haven't configured their messaging preferences for interlibrary loan notifications.
  >
  >Previously, when clicking "Send notice to patron" for an ILL request, staff received no indication whether the notice was successfully queued for delivery. If the patron had no email address or hadn't opted in to ILL messaging preferences, the notice would silently fail to send, leaving staff unaware that the patron wasn't notified.
  >
  >With this enhancement:
  >- A warning message now displays if the notice cannot be queued: "The requested notice was NOT queued for delivery by email, SMS"
  >- A success message displays when the notice is successfully queued
  >- Staff can immediately see when they need to contact the patron through alternative means (such as telephone)
  >
  >**For staff:** If you see the warning message, check the patron's record to ensure:
  >1. They have a valid email address on file
  >2. They have enabled ILL messaging preferences (Interlibrary loan ready / Interlibrary loan unavailable) in their patron messaging preferences
- [40855](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40855) Standard backend uses plain SQL (25.11.00)
- [41057](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41057) OPAC ILL visiting a URL directly does not respect ILLOpacbackends (25.11.00,25.05.05,24.11.11)
- [41257](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41257) ILL "List requests"/"Refresh" wording doesn't work (25.11.00,25.05.06,24.11.11)
- [40557](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40557) Onboarding enrollment period fields styled badly (25.11.00,25.05.04)
  >This fixes the 'Create a patron category' page in the web installer. It tidies up the layout for the enrolment period - the 'In months' and 'Until date' fields were further down the page, instead of aligned to the right of enrolment period label.

  **Sponsored by** *Athens County Public Libraries*
- [34157](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34157) Exporting labels as a barcode range can cause a 500 error (25.11.00,25.05.02,24.11.08)
  >This fixes the "Error 500..." message generated when printing barcode ranges using the label creator, where the layout type selected is "Bibliographic data precedes barcode" (Cataloging > Tools > Label creator).
- [40061](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40061) Cannot delete image from patron card creator (25.11.00,25.05.01)
  >This fixes deleting patron images in the patron card creator (Tools > Patrons and circulation > Patron card creator > +New Image). 
  >
  >Deleting images now works:
  >- using the delete button beside each image
  >- using the checkbox to select and delete the last image, if there is only one image
  >
  >(This is partly related to the CSRF changes added in Koha 24.05 to improve form security.)

  **Sponsored by** *Athens County Public Libraries*
- [40473](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40473) X scale for Code39 barcodes is calculated incorrectly when generating barcode labels (25.11.00,25.05.05,24.11.11)
- [33440](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33440) A public list can be transferred to a staff member without list permissions (25.11.00,25.05.01,24.11.08)
  >This fixes the transfer of public lists to staff patrons that do not have list permissions - when attempting to transfer the list, and the staff member doesn't have list permissions, an error message is now shown. Previously, the list could be transferred and then be edited by the staff patron without list permissions.
- [39427](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39427) Searching lists table by owner can only enter firstname or surname (25.11.00,25.05.03,24.11.09)
- [40488](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40488) "Public lists" breadcrumb link doesn't work when editing public list in staff interface (25.11.00,25.05.03,24.11.09)
  >Fixes breadcrumb link when editing public lists in staff interface.

  **Sponsored by** *Athens County Public Libraries*
- [40916](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40916) Cannot edit a list to have a sortfield value of anything other than publicationyear (25.11.00,25.05.05)
  >This fixes a problem where lists were un-sortable in the staff interface. It also fixes a problem where the sort value for a list was always being set to 'Publication year' when editing that list.
- [40119](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40119) Merge should not leave empty 6XX subfield $2 (MARC 21) (25.11.00,25.05.01,24.11.08)

  **Sponsored by** *Ignatianum University in Cracow*
- [39558](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39558) Timestamps on biblio biblioitems and biblio_metadata are not in sync (25.11.00,25.05.01)
  >This fixes the timestamp recorded in timestamp fields when in a bibliographic record is updated. The timestamp fields in the biblio, biblioitems, and biblio_metadata tables are now all updated and kept in sync when a record is updated. The timestamps being out of sync could affect reporting and updating records in other systems, such as discovery layers.
- [40618](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40618) The display of the field 255 (Cartographic Mathematical Data) is missing (both in intranet and OPAC) (25.11.00,25.05.04,24.11.10)

  **Sponsored by** *Ignatianum University in Cracow*
- [40959](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40959) LOC classification display broken (25.11.00,25.05.05,24.11.11)
  >This fixes the display logic for the Library of Congress classification field (050) in the staff interface for MARC21. The separator was being shown between subfields $a and $b, instead of between additional 050 entries.
  >
  >Example: 
  >
  >For an 050 with two entries: 
  >
  > 050  4 $aE337.5 $b.O54 2025
  > 050  4 $aE415.7 $b.A44 2025
  >
  >This was incorrectly shown in the staff interface as:
  >
  > LOC classification: E337.5 | .O54 2025 E415.7 | .A44 2025
  >
  >It should have been shown as:
  >
  >  LOC classification: E337.5 O54 2025 | E415.7 A44 2025
- [39279](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39279) Terminology:  Please return or renew them at the branch below as soon as possible. (25.11.00,25.05.03,24.11.09)
  >This fixes the terminology used in the overdue notice (ODUE) to change 'branch' to 'library': "Please return or renew your overdue items at the library as soon as possible.".
  >
  >Note: The notice is not automatically updated for existing installations. Update the notice manually to change the wording if required, or replace the default notice using "View default" and "Copy to template" if you have not customized the notice.
- [39985](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39985) items.onloan field is not updated when an item is recalled (25.11.00,25.05.06,24.11.11)

  **Sponsored by** *Auckland University of Technology*
- [40305](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40305) Collected and change variables are inconsistent in controllers and notice templates (25.11.00,25.05.04)
  >This standardizes the terminology used throughout the payment system to consistently use 'tendered' instead of the mixed usage of 'collected' and 'tendered' that has caused confusion over the years. 
  >
  >It changes the variable names used in the code, HTML forms, and notices for the point of sale module and patron accounting - there is no change to the terms staff see on the pages in the staff interfaces.
  >
  >Note: It changes the variable names used in the RECEIPT and ACCOUNT_CREDIT notices. If you have not made any change to the default notices, they will automatically be updated. If you have customized these notices, you will need to manually update them.
- [30633](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30633) Move OPACHoldingsDefaultSortField to table settings configuration (25.11.00,25.05.06)
  >Restore the ability to define a default sort order for the holdings table at the OPAC.
  >It replaces the system preference "OPACHoldingsDefaultSortField" that had been broken for a while. Note that its value is not migrated.
- [38080](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38080) Sorting options for holdings table are incorrect (25.11.00,25.05.06,24.11.11)
  >This fixes the default sort order for the OPAC holdings table, so that the default table sorting setting is used. Previously, it was not correctly using this setting (for example, setting the shelving location as the default sort order did not work).
- [38455](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38455) UNIMARC XSLT Music incipit (036) try to display field 031 (as in MARC21) (25.11.00,25.05.04,24.11.10)
- [39223](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39223) The OPAC browse search (opac-browse.pl) is broken since 24.11 (25.11.00,25.05.02,24.11.08)
  >This fixes the OPAC browse search feature (OpacBrowseSearch system preference, Elasticsearch only). Expanding and collapsing the search results to show the details now works, instead of nothing happening.
- [40080](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40080) Course reserves details search appears offscreen (25.11.00,25.05.01,24.11.08)
  >This fixes the alignment of the OPAC course reserves search box - it is now on the left above the table, instead of offscreen on the right-hand side.
- [40523](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40523) Remove unused export_buttons variable from koha-tmpl/opac-tmpl/bootstrap/js/datatables.js (25.11.00,25.05.04)
- [40540](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40540) OPAC generates warnings in logs when no results are found (25.11.00,25.05.03,24.11.09)

  **Sponsored by** *Ignatianum University in Cracow*
- [40590](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40590) OPACAuthorIdentifiersAndInformation shows empty list elements for unknown 024$2 (25.11.00,25.05.03,24.11.09)

  **Sponsored by** *Athens County Public Libraries*
- [40602](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40602) Broken HTML showing in Alert 'subscriptions' tab (25.11.00,25.05.04)

  **Sponsored by** *Athens County Public Libraries*
- [40612](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40612) Eliminate duplicate element id in OPAC language menus (25.11.00,25.05.04)

  **Sponsored by** *Athens County Public Libraries*
- [40614](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40614) Invalid markup in cookie consent modal (25.11.00,25.05.04,24.11.10)

  **Sponsored by** *Athens County Public Libraries*
- [40759](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40759) Wrong date format in subscription brief history in OPAC (25.11.00,25.05.04,24.11.10)
- [40780](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40780) Removing rows on advanced search should not lose focus (25.11.00,25.05.04)
- [40782](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40782) Selections toolbar buttons should not be focusable when they are inactive (25.11.00,25.05.04,24.11.10)
  >The selections toolbar on OPAC search results now properly manages keyboard focus for disabled buttons. Previously, visually disabled toolbar buttons (such as "Add to cart" or "Add to list" when no items were selected) could still receive keyboard focus, which was confusing for screen reader users.
  >
  >Disabled toolbar buttons now have `tabindex="-1"` applied, making them non-focusable until they become active. When items are selected and the buttons become enabled, they are automatically made focusable again.
  >
  >This enhancement improves the keyboard navigation experience and ensures that assistive technology users are not misled by inactive controls that appear to be interactive.
- [40803](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40803) Users cannot renew overdue items from 'Overdue' tab in account (25.11.00,25.05.04)
- [40836](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40836) Credit and debit types are not shown in patron account on OPAC (25.11.00,25.05.06,24.11.11)
- [40873](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40873) AV dropdowns in OPAC don't use lib_opac values (25.11.00,25.05.06,24.11.11)
  >This fixes the value displayed in dropdown lists for authorized values in the OPAC. The value entered in the 'Description (OPAC)' field is now shown for authorized value dropdown lists. Previously, the value shown was what was in the 'Description' field.
  >
  >Example: for the SUGGEST_FORMAT authorized value category, the value in 'Description (OPAC)' is now shown in the dropdown list for the item type field on the purchase suggestion form in the OPAC.
- [40903](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40903) OPAC advanced search applies a location limit of the logged-in library by default (25.11.00,25.05.06,24.11.11)
- [41010](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41010) Incorrect show_priority condition in opac-detail (25.11.00,25.05.05)
- [41078](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41078) Improve handling of multiple covers on shelves/lists results in the OPAC (25.11.00,25.05.06)
- [41128](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41128) ratings.js creating "undefined" text for screen readers and print output (25.11.00)
- [41168](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41168) "Search the catalog by keyword" confuses some users (25.11.00,25.05.06)
  >This updates the main OPAC search field hint text from "Search the catalog by keyword" to "Search the catalog". This avoids any confusion about only being able to search by keyword.
- [41177](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41177) Breadcrumbs should have aria-disabled attribute if its the current page (25.11.00,25.05.06)
- [40039](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40039) Add production enhancements to build-git-snapshot tool (25.11.00,25.05.02,24.11.08)
- [29908](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29908) Warning when empty ClaimReturnedWarningThreshold in patron_messages.inc (25.11.00,25.05.06,24.11.11)
- [34776](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34776) Patron messaging preferences are lost when an error occurs during new account creation (25.11.00,25.05.02,24.11.08)
  >This fixes creating a new patron - the messaging preferences are now remembered if there is an error when creating a new patron. Before this, if there was an error when creating a patron (for example, the wrong age for the patron category), the messaging preferences (either the default or changes made) were emptied and needed to be re-added.

  **Sponsored by** *Koha-Suomi Oy*
- [36278](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36278) Relabel "Gone no address" (25.11.00,25.05.04)
- [39408](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39408) Cannot add patron via API if AutoEmailNewUser and WELCOME content blank (25.11.00,25.05.05,24.11.11)
- [39498](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39498) Correct display of patron restriction comments (25.11.00,25.05.02)
  >This updates the way patron restrictions are displayed in the OPAC and staff interface, with the intention of making the details of each restriction clearer.
- [40116](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40116) Extra popup notice when saving a patron with patron guarantor ends in error (25.11.00,25.05.02,24.11.08)
  >This patch changes existing guarantors elements in the patron add form to use classes "guarantor_id" and "guarantor_relationship" to prevent an unnecessary pop-up if the form throws an error.

  **Sponsored by** *Koha-Suomi Oy*
- [40281](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40281) Patron circulation history page - type column is not hidden (25.11.00,25.05.02)
  >This fixes the patron circulation history page. The 'Type' column should not be shown, and is now hidden.
- [40321](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40321) DataTables search ( dt-search ) does not work on holds history page (25.11.00,25.05.03,24.11.09)
- [40459](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40459) Preferred name is lost when editing partial record (25.11.00,25.05.03,24.11.09)
- [40469](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40469) Reword anonymous_refund permission description (25.11.00,25.05.03,24.11.09)
- [40566](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40566) "Home library" empty on "Recalls history" (25.11.00,25.05.04,24.11.10)
  >This fixes the recalls history page for a patron - the patron's home library is now shown in the patron information section in the staff interface (previously, "Home library:" was shown without the patron's actual home library showing).
- [40605](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40605) Synchronize two sentences about processing personal data (25.11.00,25.05.05,24.11.11)
- [40807](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40807) Quick add form does not include 'username' when it is included in BorrowerMandatoryFields (25.11.00,25.05.04,24.11.10)
- [40886](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40886) Patron circ messages not sorted in chronological order (25.11.00,25.05.05)
  >This fixes a problem where circulation messages were not order chronologically in the staff interface.
- [40917](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40917) Required patron attributes show with extra whitespace in the textarea (25.11.00,25.05.05)
  >This fixes a problem where extraeounos whitespace was being added to the textarea ( HTML element ) of a required patron attribute in the staff interface.
- [40936](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40936) Add index for default patron sort order (25.11.00,25.05.05,24.11.11)
  >This change introduces a new database index to improve the performance of patron searches, especially in large databases. This will prevent slow searches and potential database server issues related to sorting patrons by name and address.
  >
  >**System Administrator Note:**
  >Applying this update will add a new index to the `borrowers` table. On systems with a large number of patrons, this operation can take a significant amount of time and consume considerable server resources (CPU and I/O).
  >
  >While modern database systems can often perform this operation without locking the table for the entire duration, a general slowdown of the system is expected. It is **strongly recommended** to run the upgrade (`updatedatabase.pl`) during a planned maintenance window to avoid impacting users.
- [41039](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41039) Patron search button can be spammed and trigger many API patron searches (25.11.00,25.05.06,24.11.11)
  >Every click of the "Search" button in patrons searching form
  >was triggering another patron search API request.
  >This button is now disabled after click until the first searches results are displayed.
- [41053](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41053) Make notice contents searchable on notices tab of patron details (25.11.00,25.05.06)
- [41067](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41067) 'OPAC mandatory' attribute setting requires 'Editable in OPAC' to work (25.11.00,25.05.06)
- [41212](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41212) members/maninvoice.pl debit_types should sort by description not code (25.11.00,25.05.06,24.11.11)
- [25952](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25952) Github search errors make it impossible to install plugins from other repos (25.11.00,25.05.06)
  >This fixes the error 500 "malformed JSON string" message when something goes wrong searching for plugins using the plugin search in the staff interface (for example, when there is an invalid repository in the Koha configuration).
- [40812](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40812) Move Theke sample plugin repo to Github (25.11.00,25.05.04,24.11.10)
- [40983](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40983) Remove deprecated syntax for 'after_biblio_action' hooks (25.11.00,25.05.06)
  >IMPORTANT: The former biblio and biblio_id params of after_biblio_action hooks/plugins have been removed now. They were deprecated on bug 36343 and replaced by the payload hash. Please adjust your plugins using them, if you did not do so already.
- [40625](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40625) Prevent cashup re-submissions on page reload (25.11.00,25.05.06,24.11.11)
- [36536](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36536) Make REST API's validateUserAndPassword update borrowers.lastseen (25.11.00,25.05.04)
  >This patch add the option in the 'TrackLastPatronActivityTriggers' system preference to update a patron's 'Lastseen' entry when that patron's username and password are successfully validated via the REST API's /auth/password/validation endpoint.

  **Sponsored by** *Westlake Porter Public Library*
- [39657](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39657) Block holds placed via the API when patron would be blocked from placing OPAC hold (25.05.02)
  >This development adds more holdability checks to the `POST /holds` endpoint. Overrides are added for all of them:
  >
  >* bad_address
  >* card_lost
  >* debt_limit
  >* expired
  >* hold_limit
  >* restricted
  >
  >Before this development, only `any` could be passed as an override. It will now have more granularity.
- [39970](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39970) REST API - Creating a patron without mandatory attribute types does not error (it should) (25.11.00,25.05.01)
  >This fixes a regression when creating a patron using the API. No error was returned if mandatory patron attributes were not provided, when it should be.
- [40254](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40254) POST /holds override logic problem (25.11.00,25.05.02)
- [40433](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40433) Missing maxLength in item, patron and library (25.11.00,25.05.03)
- [40543](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40543) pickup_library.branchname embed wrong (25.11.00,25.05.04,24.11.10)
- [39066](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39066) Fix "To screen into the browser" (25.11.00,25.05.03)
  >This fixes the terminology used for showing the output for standard reports in the browser. It changes "To screen into the browser" to "To screen in the browser" ("into" changed to "to").
- [39534](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39534) Saved report subgroup filter not hidden correctly (25.11.00,25.05.02,24.11.08)

  **Sponsored by** *Athens County Public Libraries*
- [39866](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39866) Acquisitions statistics fails when filling only the To date (25.11.00,25.05.01)
  >This fixes an internal server error when using the acquisitions statistics wizard report. The error was generated when only the "To" date was filled in for either the "Placed on" and "Received on" options.
- [39955](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39955) Report subgroup filter not cleared when changing tabs (25.11.00,25.05.01,24.11.06)
  >This fixes the display of saved reports in reports tabs when subgroups and filtering are used. Previously, if you used filters for subgroups and then changed tabs, the subgroup filter was not cleared - resulting in reports not showing.

  **Sponsored by** *Athens County Public Libraries*
- [40470](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40470) REPORT_GROUP authorized value cannot be numeric (25.11.00,25.05.05,24.11.11)
- [40937](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40937) No option to show/hide data menu in report results when including borrowernumber (25.11.00,25.05.05,24.11.11)
- [40939](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40939) Cardnumber not found when performing batch actions from report results (25.11.00,25.05.05)
- [40961](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40961) LocalUse Circulation Statistics offering empty results (25.11.00,25.05.06,24.11.11)
- [41082](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41082) Renaming columns in reports doesn't work with batch tools (25.11.00,25.05.06,24.11.11)
- [41112](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41112) Space is missing in report preview (25.11.00,25.05.06,24.11.11)
  >This fixes the 'Delete' button when previewing the SQL for a saved report - there is now a space between the trash can icon and Delete.
- [32934](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32934) SIP checkouts using "no block" flag have a calculated due rather than the specified due date (25.11.00,25.05.02,24.11.08)
- [39820](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39820) Items with hold cancellation requests should have the hold cancelled when checked in via SIP (25.11.00,25.05.04,24.11.10)
  >This fixes checking in items using SIP, and there is a hold cancellation request - the hold is now cancelled.
  >
  >Before this, it did not cancel the hold and it was still listed under "Holds with cancellation requests" (Circulation > Holds > Holds awaiting pickup).
- [40270](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40270) Remove useless warnings on failed SIP2 login (25.11.00,25.05.03,24.11.09)
- [40675](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40675) Carriage return in patron note message breaks SIP (25.11.00,25.05.04,24.11.10)
- [40915](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40915) SIP message parsing with empty fields edge cases (25.11.00,25.05.05,24.11.11)
- [39072](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39072) Item search shareable link adding selections for similar LOC auth values (25.11.00,25.05.04,24.11.10)
- [39896](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39896) System preference AuthorLinkSortBy is not working for UNIMARC or custom XSLT (25.11.00,25.05.03,24.11.09)
  >This fixes the default UNIMARC XSLT files so that the AuthorLinkSortBy and AuthorLinkSortOrder system preferences now work with UNIMARC, not just MARC21. 
  >
  >A note was also added to the system preference for those that use custom XSLT (for OPACXSLTDetailsDisplay, OPACXSLTResultsDisplay, XSLTDetailsDisplay, and XSLTResultsDisplay) - they need to update their templates to support these features for both MARC21 and UNIMARC.
  >
  >(These preferences were added in Koha 23.11 by Bug 33217 - Allow different default sorting when click author links, but only the default XSLT files for MARC21 were updated.)
- [40854](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40854) Staff interface search results browsing is broken (25.11.00,25.05.05)
  >This fixes the sidebar menu on the record details page in the staff interface, so that the search results browsing tool appears.
  >
  >A change from Bug 37222 - Standardize markup for sidebar menus (added to Koha 25.05) was causing the search results browser tool not to show on a record's details page after selecting a title from the search results.
- [40888](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40888) and/or/not drop-downs are missing in the Advanced Search form (25.11.00,25.05.05)
  >This fixes an issue with the Advanced Search form. When using "More options" to enter multiple search criteria, each criteria after the first should have a drop-down allowing you to choose between "and", "or", and "not" for that line. That drop-down was missing for most lines, and this fixes that issue so that the drop-down will display correctly again.
- [40304](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40304) Zebrasrv config doesn't consider non-AMD64 CPUs (25.11.00,25.05.02,24.11.08)
- [40004](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40004) Standardize spelling of "Self Checkout" to "Self-checkout" with hyphen in UI (25.11.00,25.05.03)
- [40108](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40108) Self-checkout print receipt option not working (25.11.00,25.05.01,24.11.08)

  **Sponsored by** *Athens County Public Libraries*
- [40763](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40763) SCO alert box for for wrong password used alert-info when it should use alert-warning (25.11.00,25.05.04)
- [39997](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39997) List of closed serials: reopening requires the syspref "RoutingSerials" (25.11.00,25.05.02,24.11.08)
- [39712](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39712) Query parameters break the manual mappings in vue modules (25.11.00,25.05.03,24.11.09)
- [39903](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39903) Catalog details page emits error if librarian cannot moderate comments on the record (25.11.00,25.05.01,24.11.08)
- [39939](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39939) Cancel selected holds button on the holds awaiting pickup page is the same color as the background (25.11.00,25.05.02)
  >This fixes the cancel selected holds buttons on the holds awaiting pickup page (under the tabs) (Circulation > Holds > Holds awaiting pickup). The light grey background was removed, and you can now see the cancel selected holds buttons.
  >
  >It also links the TransferWhenCancelAllWaitingHolds system preference under the "Holds waiting past their expiration date", if the staff patron has permission to change system preferences.

  **Sponsored by** *Athens County Public Libraries*
- [39987](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39987) Batch item deletion breadcrumb uses wrong link (25.11.00,25.05.01,24.11.06)
  >This fixes the 'Batch item deletion' breadcrumb link when batch deleting items in cataloguing. If you clicked on the link, it would incorrectly take you to the 'Batch item modification' page.
- [40040](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40040) RTL CSS files not loaded in templates; legacy right-to-left.css causing UI issues (25.11.00,25.05.04)
- [40081](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40081) textareas appear to now be fixed width (25.11.00,25.05.03,24.11.09)
  >This fixes OPAC and staff interface forms with text area fields. You can now adjust the size both vertically and horizontally - after the Bootstrap 5 upgrade you could only adjust the size vertically. (This is related to the OPAC and staff interface Bootstrap 5 upgrade in Koha 24.11.)

  **Sponsored by** *Athens County Public Libraries*
- [40121](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40121) library and category not selected on the patron search (25.11.00,25.05.03,24.11.09)
- [40166](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40166) Syspref description for ILS-DI:AuthorizedIPs is incorrect (25.11.00,25.05.01,24.11.08)
  >This fixes a typo in the ILS-DI:AuthorizedIPs system preference, correcting the example for allowing all IPs
- [40250](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40250) Wrong link to NoIssuesChargeGuarantorWithGuarantees in patron category page (25.11.00,25.05.02)
  >This fixes the link to the system preference NoIssuesChargeGuarantorsWithGuarantees when creating or editing a patron category. Previously, the link erroneously pointed to the NoIssuesChargeGuarantees system preference.
- [40298](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40298) A select2 in a bootstrap modal, like in the patron card batch patron search modal, needs it's parent defined (25.11.00,25.05.03,24.11.09)
- [40421](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40421) Logged in info should be data-attributes instead and text (25.11.00,25.05.02)
  >This patch adds HTML data-attributes to some hidden content in the staff interface. This makes it easier to retrieve context about the logged in user with CSS or JavaScript.
- [40560](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40560) Incorrect breadcrumb on recall history (25.11.00,25.05.03)

  **Sponsored by** *Athens County Public Libraries*
- [40565](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40565) Column filters on the item search do not work (25.11.00,25.05.04,24.11.11)
  >This patch fixes a problem that made the column search filters not to work when doing an item search.
- [40645](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40645) When adding to a list the 'list name' field is cut off (25.11.00,25.05.04)
- [40647](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40647) "dictionary" misspelled in rep_dictonary class (25.11.00,25.05.03,24.11.09)
  >This fixes a spelling error in the class name on the reports home page in the staff interface: "rep_dictonary" to "rep_dictionary".
- [40651](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40651) Item search custom field selection is not populated in shareable link (25.11.00,25.05.04,24.11.10)
- [40734](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40734) Libraries additional fields don't appear when creating a new library (25.11.00,25.05.04)
  >This fixes adding a new library when additional fields are configured in Administration > Additional fields > Libraries (branches). The additional fields were not shown when creating a new library (they were shown when editing an existing library).
- [40865](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40865) Single patron result does not redirect (25.11.00,25.05.05)
- [40876](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40876) DT - Exact search not applied on second attribute for column filters (25.11.00,25.05.04,24.11.11)
- [40880](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40880) Exporting Item search results to csv, columns after Damaged Status are misaligned (25.11.00,25.05.05)
- [40904](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40904) Unable to search items by location (25.11.00,25.05.05)
  >This fixes the holdings table in the staff interface so that it can be searched and filtered by the shelving location description.
- [40907](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40907) parenthesis and bracket are breaking filter on item table (25.11.00,25.05.05,24.11.11)
- [41071](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41071) Registers not correctly populated / selected when changing branches (25.11.00,25.05.05)
- [41074](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41074) Last patron links are shuffled and wrong patrons removed (25.11.00,25.05.05,24.11.11)
- [41217](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41217) Missing class on body tag for reserve/hold-group.tt (25.11.00)
- [37439](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37439) ChildNeedsGuarantor description misleading (25.11.00,25.05.01,24.11.08)
  >This updates the description for the ChildNeedsGuarantor system preference as it was misleading, as it not longer just applies to children (historically it did - but now it can be any patron type that can have a guarantor).
  >
  >The updated description:
  >
  >Any patron of a patron type than can have a guarantor [does not require|requires] a guarantor be set when adding the patron.
  >WARNING: Setting this preference to 'requires' will cause errors for any pre-existing patrons that would now require a guarantor and do not have one.
- [40088](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40088) Do not show edit button for default framework (25.11.00,25.05.02,24.11.08)
  >This fixes MARC structure page for the default bibliographic framework. It removes the 'Edit framework' button at the top of the page, as you can't actually edit the default framework description (Koha administration > Catalog > MARC bibliographic framework, for the default framework select Actions > MARC structure.)
- [40114](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40114) Can't select new library when editing a desk (25.11.00,25.05.03,24.11.09)
  >This patch fixes a problem that made it impossible to select a new library/branch when editing a desk from Administration -> Desks.

  **Sponsored by** *Athens County Public Libraries*
- [40453](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40453) Allow newly-added item type translations to be edited (25.11.00)

  **Sponsored by** *Athens County Public Libraries*
- [40547](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40547) Unable to view background job if enable_plugins is 0 (25.11.00,25.05.03,24.11.09)
- [41092](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41092) Some system preferences have target='blank' instead of target='_blank' (25.11.00,25.05.06,24.11.11)
  >This fixes the HTML target attribute for some system preference links that open a pop-up window or external link. The link attribute now uses "_blank" instead of "blank", and opens in a new tab for external links, and the same browser window for pop-up windows (modals).
- [32284](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32284) Capitalization: Audio Carriers, Computer Carriers ... in UNIMARC value builders (25.11.00,25.05.02)
  >This fixes the capitalization for the labels displayed in the MARC tag editor for UNIMARC subfields 181$a, 181$c, $182$a, 182$c, and 183$c, when the value builders are used. The labels are changed from capital case to sentence case, for consistency with other labels:
  >- Content Form -> Content form (181$a)
  >- Content Type -> Content type (181$c)
  >- Media Type Code -> Media type code (182$a)
  >- Media Type -> Media type (182$c)
  >- In the dropdown list (183$a):
  >  . Audio Carriers -> Audio carriers
  >  . Computer Carriers -> Computer carriers
  >  . Microform Carriers -> Microform carriers
  >  . Microscopic Carriers -> Microscopic carriers
  >  . Stereographic Carriers -> Stereographic carriers
- [32287](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32287) Capitalization: Printing and/or Publishing Information Transcribed as Found in the Colophon:␠ (25.11.00,25.05.02)
  >This fixes the capitalisation for the labels displayed in the OPAC and staff interface for UNIMARC subfields 214$r and $s - these are changed from capital case to sentence case, to be consistent with other labels:
  >- 214$r: Printing and/or publishing information transcribed
  >         as found in the main source of information
  >- 214$s: Printing and/or publishing information transcribed
  >         as found in the colophon
- [32296](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32296) Capitalization: Specification of Dimensionality,... (25.11.00,25.05.02)
  >This fixes the capitalization for the labels displayed in the MARC tag editor for UNIMARC 181$b, when the value builder unimarc_field_181b.pl is used. The labels are changed from capital case to sentence case, for consistency with other labels:
  >- Specification of type (position 0)
  >- Specification of motion (position 1)
  >- Specification of dimensionality (position 2)
  >- Sensory specification 1, 2 and 3 (positions 3 to 5)
- [38127](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38127) Missing column headings in 'Add user' pop-up modal (25.11.00,25.05.01,24.11.06)
  >This fixes the "Add user" pop-up window when adding a user to a new order in acquisitions. The table now shows the column headings, such as card, name, category, and library.

  **Sponsored by** *Athens County Public Libraries*
- [39441](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39441) Some templates have div.container instead of div.container-fluid (25.11.00,25.05.02,24.11.08)
  >This updates a few templates so that div.container is replaced with div.container-fluid. div.container has a fixed maximum width that isn't consistent with the rest of Koha. An example where this caused display issues - the staff interface cart: the action icons were bunched up to the left, instead of being spread evenly across the pop-up window width.

  **Sponsored by** *Athens County Public Libraries*
- [39499](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39499) Add some padding to the Save button in the sticky bar in cataloging (25.11.00,25.05.01,24.11.08)
  >This fixes a regression in the style of the floating toolbar on
  >the basic MARC editor page - it adds more padding before the 'Save' button in the sticky toolbar and is now aligned correctly with other page elements. Before this, it was aligned to the left without any padding before it.

  **Sponsored by** *Athens County Public Libraries*
- [39947](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39947) Use bg-*-subtle in preference to bg-* Bootstrap classes (25.11.00,25.05.01,24.11.10)
  >This fixes some Bootstrap color classes.
  >
  >It removes a few instances of the "bg-*" class from templates (used in a few places such as bg-info, bg-danger, etc.) as the styles don't really fit with the staff interface's color palette. Examples include the circulation and fine rules page and the patron import tool page.
  >
  >In the places where we don't want to use the corresponding alert classes, it adds some CSS so that we can safely use the ".bg-*-subtle" class to a div with ".page-section.".
  >
  >(This is related to Bug 39274 - HTML bg-* elements are low contrast, added to Koha 25.05, and Bug 35402 - Update the OPAC and staff interface to Bootstrap 5, added to Koha 24.11.)

  **Sponsored by** *Athens County Public Libraries*
- [39954](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39954) Cataloging search results incorrect menu markup (25.11.00,25.05.02,24.11.08)

  **Sponsored by** *Athens County Public Libraries*
- [40042](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40042) search_indexes.inc may have undefined index var (25.11.00,25.05.01,24.11.07)
- [40111](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40111) Fix title sorting on two reports (25.11.00,25.05.02,24.11.08)

  **Sponsored by** *Athens County Public Libraries*
- [40160](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40160) Use HTTPS for links to community websites (25.11.00,25.05.02)
- [40222](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40222) Bootstrap popover components not updated for BS5 (25.11.00,25.05.03,24.11.09)

  **Sponsored by** *Athens County Public Libraries*
- [40244](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40244) Typo in branchoverdues.tt (25.11.00,25.05.02,24.11.08)
  >Fixes text in overdues with fines "Overdues at with fines {library}" into "Overdues with fines at {library}"
- [40249](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40249) "Copy settings" should be "Copy permissions" (25.11.00,25.05.02,24.11.08)
  >This bug changes the phrase "Copy settings" to read as "Copy permissions".

  **Sponsored by** *Athens County Public Libraries*
- [40319](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40319) Fix spacing in address display include (25.11.00,25.05.02)

  **Sponsored by** *Athens County Public Libraries*
- [40413](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40413) Patron list input missing "Required" label (25.11.00,25.05.03,24.11.09)

  **Sponsored by** *Athens County Public Libraries*
- [40451](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40451) Link patron restriction types to correct section in manual (25.11.00,25.05.03,24.11.09)

  **Sponsored by** *Athens County Public Libraries*
- [40591](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40591) Typo in fastadd button class (25.11.00,25.05.04)
- [40592](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40592) Fix incorrect row highlighting on patron checkout history page (25.11.00,25.05.04)

  **Sponsored by** *Athens County Public Libraries*
- [40600](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40600) Typo in ILL requests template: "Complete request request" (25.11.00,25.05.04)

  **Sponsored by** *Athens County Public Libraries*
- [40664](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40664) Serial subscription input missing "Required" labels (25.11.00,25.05.06,24.11.11)
  >This fixes the second page of the new serial subscription form - it adds missing "Required" labels next to two mandatory fields
  >('Frequency' and 'Subscription start date').
- [40720](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40720) Misleading title attribute "Remove all items" in Select2 fields (25.11.00,25.05.06,24.11.11)
  >Improvement: Updated Select2 title text for clarity
  >
  >This patch updates the Select2 initialization script to improve accessibility and clarity. The title attribute on the “X” control (used to clear selections in Select2 dropdowns) now reads “Clear selections” instead of “Clear items,” eliminating ambiguity.

  **Sponsored by** *Athens County Public Libraries*
- [40760](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40760) 'Edit' link in item receive table is not formatted as link (25.11.00,25.05.06,24.11.11)
- [40857](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40857) Dropdown menu for Booking cancellation is hidden in modal (25.11.00,25.05.05,24.11.11)
- [40931](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40931) Hold pickup location drop-down boxes not wide enough when placing multiple holds at the same time. (25.11.00,25.05.05)
- [41207](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41207) Permission description string does match permission name (25.11.00,25.05.06,24.11.11)

  **Sponsored by** *Cape Libraries Automated Materials Sharing*
- [18772](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18772) t/ImportBatch.t generates warnings (25.11.00,25.05.02,24.11.08)
- [36625](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36625) t/db_dependent/Koha/Biblio.t leaves test data in the database (25.11.00,25.05.01,24.11.06)
- [38475](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38475) InfiniteScrollSelect_spec.ts is failing randomly again (25.11.00,25.05.06,24.11.11)
- [40018](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40018) Remove warning from Koha/Template/Plugin/Koha.t (25.11.00,25.05.01,24.11.08)
- [40019](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40019) Koha/Auth/Client.t produces warnings (25.11.00,25.05.01,24.11.08)
- [40020](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40020) Koha/AdditionalContents.t produces warnings (25.11.00,25.05.01,24.11.08)
- [40021](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40021) Koha/Plugins/Recall_hooks.t produces warnings (25.11.00,25.05.01,24.11.08)
- [40043](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40043) Agreements_spec.ts is failing randomly (2) (25.11.00,25.05.02,24.11.08)
- [40046](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40046) Remove wait and screenshot from Tools/ManageMarcImport_spec.ts (25.11.00,25.05.02,24.11.10)
- [40051](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40051) cy.wait(delay) should not be used in Cypress tests (25.11.00,25.05.03)
- [40168](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40168) afterEach not called in KohaTable cypress tests (25.11.00,25.05.02,24.11.08)
- [40169](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40169) Cypress tests - mockData should not replace "_id" fields if passed (25.11.00,25.05.02,24.11.08)
- [40315](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40315) xt/tt_tidy.t generates warnings (25.11.00,25.05.04)
- [40316](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40316) selenium/regressions.t generates warnings (25.11.00,25.05.02,24.11.08)
- [40317](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40317) Auth_with_shibboleth.t generates warnings (25.11.00,25.05.02,24.11.08)
- [40320](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40320) Missing Cypress tests for patron address display (25.11.00,25.05.05)
- [40344](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40344) KohaTable_spec.ts is failing (25.11.00,25.05.02,24.11.08)
- [40345](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40345) Missing Cypress tests for checkout history - OPAC (25.11.00,25.05.03)
- [40347](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40347) Koha/Hold.t generates diag (25.11.00,25.05.02,24.11.08)
- [40348](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40348) api/v1/two_factor_auth.t generates warnings (25.11.00,25.05.02,24.11.08)
- [40350](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40350) t/db_dependent/Holds.t generates warnings (25.11.00,25.05.02,24.11.08)
- [40351](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40351) Koha/SearchEngine/Elasticsearch/Search.t  generates a warning (25.11.00,25.05.02,24.11.08)
- [40353](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40353) Koha/Patron.t generates warnings (25.11.00,25.05.02,24.11.08)
- [40371](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40371) t/db_dependent/Budgets.t generates warnings (25.11.00,25.05.03)
- [40372](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40372) api/v1/holds.t generates a warning (25.11.00,25.05.02,24.11.08)
- [40373](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40373) Reserves.t generates a warning (25.11.00,25.05.02,24.11.08)
- [40374](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40374) Koha/Booking.t generates warnings (25.11.00,25.05.02,24.11.08)
- [40376](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40376) AuthorisedValues.t generates a warning (25.11.00,25.05.02,24.11.08)
- [40377](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40377) HoldsQueue/TransportCostOptimizations.t generates warnings (25.11.00,25.05.02,24.11.08)
- [40378](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40378) api/v1/biblios.t generates warnings (25.11.00,25.05.02,24.11.08)
- [40379](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40379) t/db_dependent/www tests generate warnings (25.11.00,25.05.02)
- [40380](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40380) Koha/Patrons/Import.t generates warnings (25.11.00,25.05.02,24.11.08)
- [40381](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40381) Koha/SearchEngine/Elasticsearch/ExportConfig.t generates warnings (25.11.00,25.05.02,24.11.08)
- [40384](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40384) Koha/Plugins/Patron.t generates warnings (25.11.00,25.05.02,24.11.08)
- [40385](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40385) Reserves/CancelExpiredReserves.t generates a warning (25.11.00,25.05.02,24.11.08)
- [40386](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40386) t/Edifact.t generates warnings (25.11.00,25.05.03)
- [40387](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40387) t/db_dependent/Koha/EDI.t generates warnings (25.11.00,25.05.03)
- [40388](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40388) t/Labels.t generates a warning (25.11.00,25.05.02,24.11.08)
- [40389](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40389) t/dummy.t is useless (25.11.00,25.05.02,24.11.08)
- [40390](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40390) t/db_dependent/Biblio.t generates warnings (25.11.00,25.05.02,24.11.08)
- [40402](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40402) xt/find-license-problems.t is failing (25.11.00,25.05.02,24.11.08)
- [40403](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40403) Circulation_holdsqueue.t generates warnings (25.11.00,25.05.02,24.11.08)
- [40404](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40404) t/Test/Mock/Logger.t generates warnings (25.11.00,25.05.02,24.11.08)
- [40406](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40406) selenium/basic_workflow.t generates warnings (25.11.00,25.05.02,24.11.08)
- [40409](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40409) t/db_dependent/Overdues.t generates warnings (25.11.00,25.05.02,24.11.08)
- [40410](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40410) Letters.t generates a warning (25.11.00,25.05.02,24.11.08)
- [40411](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40411) Koha/SearchEngine/Elasticsearch.t generates warnings (25.11.00,25.05.02,24.11.08)
- [40419](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40419) xt/find-license-problems.t isn't catching all instances of 51 Franklin St/Street (25.11.00,25.05.02,24.11.08)
- [40429](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40429) Koha/Patron/Modifications.t generates warnings (25.11.00,25.05.02,24.11.08)
- [40437](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40437) Koha/Installer.t generates a warning (25.11.00,25.05.02,24.11.08)
- [40438](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40438) Koha/Old/Hold.t generates warnings (25.11.00,25.05.02,24.11.08)
- [40467](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40467) t/00-deprecated.t no longer needed (25.11.00,25.05.05,24.11.11)
- [40490](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40490) Warnings from GD::Barcode::QRcode on U24 (25.11.00,25.05.03,24.11.09)
- [40493](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40493) t/cypress/plugins/dist/ must be git ignored (25.11.00,25.05.03)
- [40539](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40539) Cypress videos and screenshots should be gitignored (25.11.00,25.05.03)
- [40541](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40541) Add new line at the end of the files when missing (25.11.00,25.05.03)
- [40548](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40548) diff in DB schema (25.11.00,25.05.02)
- [40845](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40845) t/Koha/Manual.t only passes for 25.05 and 25.06 (25.11.00,25.05.06,24.11.11)
- [40858](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40858) t/00-merge-conflict-markers.t should only test files part of git repo (25.11.00,25.05.04)
- [40950](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40950) Don't forbid 'falsy' in codespell (25.11.00)
- [40969](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40969) Circulation.t fails if  RenewalPeriodBase is set to now ( the current date ) (25.11.00,25.05.05,24.11.11)
- [40981](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40981) KohaTable/Holdings_spec.ts is failing randomly (25.11.00,25.05.05)
- [41012](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41012) ILSDI_Services.t is failing randomly (25.11.00,25.05.05,24.11.11)
- [31930](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31930) Ignore whitespace before and after barcodes when adding items to rotating collections (25.11.00,25.05.03,24.11.09)
  >This fixes adding or removing items to a rotating collection (Tools > Patrons and circulation > Rotating collections). If a barcode has a space before it, it is now ignored instead of generating an error message.
- [32950](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32950) MARC modification template moving subfield can lose values for repeatable fields (25.11.00,25.05.05,24.11.11)
  >MARC modification templates now correctly preserve existing values when moving subfields within repeatable fields. Previously, moving subfields could cause data loss or duplication when the source subfield didn't exist in all instances of the repeatable field.
  >
  >**The problem:**
  >
  >When using a MARC modification template to move a subfield within a repeatable field (for example, moving 020$z to 020$a), if some 020 fields had existing $a values but no $z values, those existing $a values would be overwritten or lost.
  >
  >**Example scenario:**
  >
  >Given multiple 020 fields:
  >- 020$a with existing ISBN
  >- 020$a with another existing ISBN  
  >- 020$z with cancelled ISBN (to be moved to $a)
  >- 020$z with another cancelled ISBN (to be moved to $a)
  >
  >Previously, when moving 020$z to 020$a, the first two existing 020$a values would be replaced with values from the 020$z fields, causing data loss.
  >
  >**What's fixed:**
  >
  >- Existing subfield values in fields that don't contain the source subfield are now preserved
  >- Source subfield values are only moved to the corresponding target positions in fields that actually contain the source subfield
  >- The move operation correctly removes the source subfields after copying their values
  >- Field order and other subfields are maintained correctly
  >
  >**For cataloguers:**
  >
  >MARC modification template "move" operations now work reliably with repeatable fields. When moving subfields, only the fields that contain the source subfield will be affected, and all other existing values in the repeatable fields will be preserved.
- [39423](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39423) Column checkboxes on item batch modification hide incorrect columns (25.11.00,25.05.04,24.11.10)
- [40332](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40332) Tools menu sidebar category not shown for users with batch_extend_due_dates only (25.11.00,25.05.02,24.11.08)
- [40549](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40549) Warnings generated when using Import Patrons tool (25.11.00,25.05.03,24.11.09)
- [40691](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40691) CCODE label not includes in case of 'wrong place' problem (and maybe others cases) into inventory.pl (25.11.00,25.05.04,24.11.10)

  **Sponsored by** *BibLibre*
- [40702](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40702) Inventory CSV export missing "title" header (25.11.00,25.05.04,24.11.10)
- [40843](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40843) On modborrowers.pl patron attributes should sort by the description, not the code (25.11.00,25.05.06,24.11.11)
  >This patch fixes a problem in the batch patron modification tool where extended patron attributes were sorting based on the code, instead of the description.
- [41065](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41065) Batch patron modification results are no longer displayed (25.11.00,25.05.05)
- [36561](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36561) Inappropriate permission for "/api/v1/auth/password/validation" (25.11.00,25.05.04)
  >This change adds a new borrower subpermission "api_validate_password" with the description "Validate patron passwords using the API". This permission allows API borrower accounts, especially for third-parties, the ability to authenticate users without needing full create-read-update-delete (CRUD) permissions.
- [40622](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40622) Bug 38233 not properly applied to 24.11.x, 25.05.x, and main (25.11.00,25.05.05,24.11.11)
  >ILS-DI GetRecords will now show the OPAC version of "marcxml".

## New system preferences

- AdditionalContentLog
- DisplayAddHoldGroups
- DisplayPublishedDate
- ElasticsearchPreventAutoTruncate
- EnableBooking
- FacetSortingLocale
- FilterSearchResultsByLoggedInBranch
- PreventWithdrawingItemsStatus
- ShowPatronFirstnameIfDifferentThanPreferredname

## Deleted system preferences

- IntranetReportsHomeHTML
- OPACHoldingsDefaultSortField

## Renamed system preferences
- ElasticsearchPreventAutoTruncate renamed as ElasticsearchPreventAutoTruncate
- NewsLog renamed as AdditionalContentLog

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [English (USA)](https://koha-community.org/manual/25.11/en/html/)
- [French](https://koha-community.org/manual/25.11/fr/html/) (75%)
- [German](https://koha-community.org/manual/25.11/de/html/) (94%)
- [Greek](https://koha-community.org/manual/25.11/el/html/) (98%)
- [Hindi](https://koha-community.org/manual/25.11/hi/html/) (67%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (90%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified Han script) (82%)
- Chinese (Traditional Han script) (95%)
- Czech (65%)
- Dutch (84%)
- English (100%)
- English (New Zealand) (60%)
- English (USA)
- Finnish (98%)
- French (98%)
- French (Canada) (97%)
- German (98%)
- Greek (64%)
- Hindi (93%)
- Italian (79%)
- Norwegian Bokmål (70%)
- Persian (fa_ARAB) (91%)
- Polish (98%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (85%)
- Russian (91%)
- Slovak (57%)
- Spanish (96%)
- Swedish (88%)
- Telugu (64%)
- Turkish (79%)
- Ukrainian (69%)
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

The release team for Koha 25.11.00 is


- Release Manager: Lucas Gass

- QA Manager: Martin Renvoize

- QA Team:
  - Andrew Fuerste-Henry
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
new features in Koha 25.11.00
<div style="column-count: 2;">

- Association de Gestion des Œuvres Sociales d'Inria (AGOS)
- Athens County Public Libraries
- Auckland University of Technology
- [BibLibre](https://www.biblibre.com)
- British Museum
- [ByWater Solutions](https://bywatersolutions.com)
- [Cape Libraries Automated Materials Sharing](https://info.clamsnet.org)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)
- [HKS3](https://koha-support.eu)
- Ignatianum University in Cracow
- Karlsruhe Institute of Technology (KIT)
- Koha DACH Hackfest
- [Koha-Suomi Oy](https://koha-suomi.fi)
- [LMS Cloud](https://www.lmscloud.de)
- NHS England (National Health Service England)
- [Open Fifth](https://openfifth.co.uk)
- [OpenFifth](https://openfifth.co.uk)
- Pymble Ladies' College
- [Royal Borough of Kensington and Chelsea](https://www.rbkc.gov.uk)
- [Solutions inLibro inc.](https://inlibro.com)
- UK Health Security Agency
- [Westlake Porter Public Library](https://westlakelibrary.org)
- [Westminster City Council](https://www.westminster.gov.uk)
</div>

We thank the following individuals who contributed patches to Koha 25.11.00
<div style="column-count: 2;">

- Rachel A-M (2)
- Axel Amghar (3)
- Aleisha Amohia (7)
- Pedro Amorim (252)
- Tomás Cohen Arazi (145)
- Alexander Blanchard (3)
- Matt Blenkinsop (225)
- Courtney Brown (2)
- Alex Carver (1)
- Nick Clemens (44)
- David Cook (44)
- Jake Deery (11)
- Paul Derscheid (20)
- Jonathan Druart (354)
- Marion Durand (2)
- Laura Escamilla (18)
- Katrin Fischer (2)
- David Flater (2)
- Emily-Rose Francoeur (2)
- Andrew Fuerste-Henry (18)
- Matthias Le Gac (3)
- Eric Garcia (2)
- Toni Gardiner (1)
- Lucas Gass (194)
- Thibaud Guillot (3)
- David Gustafsson (1)
- Michael Hafen (3)
- Kyle M Hall (11)
- Mason James (1)
- Andreas Jonsson (1)
- Janusz Kaczmarek (14)
- Jan Kissig (2)
- Thomas Klausner (2)
- Michał Kula (1)
- Vivek Kumar (1)
- Emily Lamancusa (15)
- Sam Lau (2)
- Brendan Lawlor (6)
- lawrenceol-clams (1)
- Owen Leonard (74)
- Cath Leone (1)
- CJ Lynce (7)
- Nina Martinez (8)
- Julian Maurice (3)
- David Nind (7)
- Brian Norris (1)
- Andrew Nugged (1)
- Eric Phetteplace (1)
- PhilipOrr (1)
- Aman Pilgrim (2)
- Karam Qubsi (1)
- katy rayn (1)
- Martin Renvoize (144)
- Jason Robb (3)
- Adolfo Rodríguez (2)
- Marcel de Rooy (63)
- Caroline Cyr La Rose (11)
- sashaanastasi (2)
- Bernard Scaife (2)
- Lisette Scheer (6)
- Slava Shishkin (1)
- Fridolin Somers (11)
- Tadeusz „tadzik” Sośnierz (1)
- Lari Strand (3)
- Arthur Suzuki (3)
- Emmi Takkinen (4)
- Doris Tam (1)
- Lari Taskula (4)
- Theodoros Theodoropoulos (1)
- Imani Thomas (1)
- Shi Yao Wang (2)
- Yvonne Waterman (1)
- Hammat Wele (6)
- Baptiste Wojtkowski (10)
- Chloe Zermatten (2)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 25.11.00
<div style="column-count: 2;">

- Aristotle University Of Thessaloniki (Αριστοτέλειο Πανεπιστήμιο Θεσσαλονίκης) (1)
- Athens County Public Libraries (74)
- bestbookbuddies.com (1)
- [BibLibre](https://www.biblibre.com) (40)
- [Bibliotheksservice-Zentrum Baden-Württemberg (BSZ)](https://bsz-bw.de) (2)
- [ByWater Solutions](https://bywatersolutions.com) (294)
- [Cape Libraries Automated Materials Sharing](https://info.clamsnet.org) (7)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha) (11)
- Catalyst Open Source Academy (5)
- ctalyst.net.nz (1)
- David Nind (7)
- Gothenburg University Library (1)
- [HKS3](https://koha-support.eu) (1)
- [Hypernova Oy](https://www.hypernova.fi) (4)
- Independant Individuals (38)
- Koha Community Developers (354)
- [Koha-Suomi Oy](https://koha-suomi.fi) (7)
- KohaAloha (1)
- Kreablo AB (1)
- [LMSCloud](https://www.lmscloud.de) (21)
- [Montgomery County Public Libraries](https://montgomerycountymd.gov) (15)
- [Open Fifth](https://openfifth.co.uk) (639)
- [Prosentient Systems](https://www.prosentient.com.au) (44)
- Rijksmuseum, Netherlands (63)
- sekls.org (3)
- [Solutions inLibro inc](https://inlibro.com) (24)
- [Theke Solutions](https://theke.io) (143)
- westlakelibrary.org (7)
- Wildau University of Technology (2)
- [Xercode](https://xebook.es) (2)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Aleisha Amohia (14)
- Pedro Amorim (51)
- Anneli (7)
- Tomás Cohen Arazi (92)
- Andrew Auld (2)
- Wojciech Baran (1)
- Wendy Bartlett (1)
- Phillip Berg (3)
- Sarah Berry (1)
- Pamela Bird (4)
- Matt Blenkinsop (37)
- Katie Bliss (1)
- Anke Bruns (2)
- Emmanuel Bétemps (6)
- Aude Charillon (5)
- Christopher (1)
- Nick Clemens (88)
- David Cook (73)
- Jake Deery (3)
- Ray Delahunty (1)
- Michal Denar (6)
- Paul Derscheid (77)
- Trevor Diamond (3)
- Roman Dolny (43)
- Jonathan Druart (331)
- Hannah Dunne-Howrie (23)
- Marion Durand (4)
- Magnus Enger (11)
- Laura Escamilla (64)
- Jeremy Evans (11)
- Katrin Fischer (5)
- David Flater (19)
- Andrew Fuerste-Henry (130)
- Brendan Gallagher (6)
- Eric Garcia (6)
- Lucas Gass (1627)
- Amaury GAU (5)
- George (2)
- Kim Gnerre (1)
- Victor Grousset (25)
- Nial Halford-Busby (1)
- Kyle M Hall (60)
- Chip Halvorsen (1)
- Claire Hernandez (3)
- Heather Hernandez (5)
- Cornelius Hertfelder (1)
- Mason James (1)
- Jason (1)
- Tomas Jiglind (1)
- Barbara Johnson (1)
- Ludovic Julien (4)
- Kevin Kellenberger (1)
- Jan Kissig (7)
- Thomas Klausner (2)
- Lukas Koszyk (1)
- krimsonkharne (1)
- kristi (1)
- Kristi Krueger (6)
- Marie-Luce Laflamme (1)
- Emily Lamancusa (42)
- Sam Lau (1)
- Brendan Lawlor (37)
- Christine Lee (1)
- Owen Leonard (102)
- Lin Wei Li (7)
- Ludovic (1)
- CJ Lynce (8)
- Jesse Maseto (1)
- Julian Maurice (3)
- Michaela (5)
- Nathalie (5)
- Christian Nelson (3)
- Miranda Nero (1)
- David Nind (262)
- noah (1)
- Lawrence ORegan-Lloyd (1)
- Boubacar OUATTARA (3)
- Eric Phetteplace (8)
- Laurence Rault (1)
- Martin Renvoize (306)
- Johannes Reuter (1)
- Phil Ringnalda (3)
- Jason Robb (8)
- Marcel de Rooy (196)
- Caroline Cyr La Rose (15)
- Mathieu Saby (3)
- Bernard Scaife (7)
- Lisette Scheer (99)
- Slava Shishkin (4)
- Michaela Sieber (265)
- Sam Sowanick (4)
- Tadeusz „tadzik” Sośnierz (1)
- Michelle Spinney (3)
- Dominique et Stephanie (1)
- Arthur Suzuki (1)
- Emmi Takkinen (8)
- Felicie Thiery (1)
- Imani Thomas (1)
- Jen Tormey (1)
- Noah Tremblay (6)
- Clemens Tubach (1)
- Olivier Vezina (2)
- Hammat Wele (4)
- Baptiste Wojtkowski (19)
- Katherine Wolf (1)
-  Anneli Österman (1)
- Anneli Österman (20)
</div>



And people who contributed to the Koha manual during the release cycle of Koha 25.11.00
<div style="column-count: 2;">
- Pymble Ladies College (2)
- Jason Robb (2)
- Andrew Auld (1)
- Manu B (1)
- Ian Beardslee (1)
- Aude Charillon (29)
- Caroline Cyr La Rose (49)
- Jonathan Druart (21)
- Marion Durand (8)
- Tim Hannah (2)
- Mark Hofstetter (1)
- Kristi Krueger (2)
- Brendan Lawlor (1)
- David Nind (11)
- Paul Poulain (3)
- Laurence Rault (1)
- Jessica Zairo (3)
</div>

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Notes from the Release Manager

Wow! What an adventure this has been and a great expereince for me! Similar to getting an Academy Award, there are just too many people to thank: 

- ByWater Solutions, for allowing me to take on this role. Brendan Gallagher for being so encouraging and making me belive I can actuall do this!  
- I really could not have done this without Jonathan Druart (joubu), Tomás Cohen Arazi (tcohen), and Martin Renvoize (ashimema) helping me every step of the way. Thanks for dealing with my somewhat annoying questions everyday. You all are the real RM's this cycle. Thanks for the release tools you have created and maintained over the years, making this job a lot easier.
- The ByWater Solutions development team, for taking on my extra work so I could have time to do RM things.
- Each of the release maintainers for doing an amazing job maintaining the versions of the software that librarians use on a day to day basis.
- All of you Koha users out there. We couldn't do any of this without you!
- Anyone who provided a patch, tested a bug, did QA, worked on translations, or documented Koha in the manual. Y'all are the true heroes! 

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

Autogenerated release notes updated last on 05 Dec 2025 17:53:11.
