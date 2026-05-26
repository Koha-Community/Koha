# RELEASE NOTES FOR KOHA 26.05.00
26 May 2026

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 26.05.00 can be downloaded from:

- [Download](https://download.koha-community.org/koha-26.05-latest.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 26.05.00 is a major release, that comes with many new features.

It includes 2 new features, 214 enhancements, 365 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).

## New features & Enhancements

### About

#### Enhancements

- [41135](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41135) Convert about page Perl module table to DataTable
  >This enhancement updates the Perl modules about page to use the standard data table format - this allows for sorting, filtering by required or missing, and searching (More > About Koha > Perl modules).

  **Sponsored by** *Athens County Public Libraries*
- [41319](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41319) Link content of 'Contributing companies and institutions' to bug sponsors
  >This enhancement automates the generation of contributing companies and institutions on the about page (About Koha > Koha team), and (where known):
  >- Links to their website 
  >- Includes the country

### Accessibility

#### Enhancements

- [38643](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38643) Advanced Search input fields need placeholders
  >OPAC accessibility improvement: Added dynamic placeholder text to advanced search fields to provide clearer visual guidance and improve usability for users with cognitive accessibility needs.
- [42165](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42165) OPAC main search should include role="search"

### Acquisitions

#### Enhancements

- [38207](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38207) Add vendor payment methods
  >This enhancement adds a 'Payment method" field to the ordering information section for a vendor. Options to use are added in the new VENDOR_PAYMENT_METHOD authorized values category.
- [38262](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38262) Add additional fields to vendors
  >This enhancement lets you add and use additional fields for vendors (Administration > Additional parameters > Additional fields > Acquisitions > Vendors).
- [40383](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40383) Modernise the EDIFACT Message display modal
  >The EDIFACT message viewer has been significantly improved with a new interactive modal interface replacing the previous basic display.
  >
  >New features:
  >
  >  - Tree view — Collapsible, hierarchical display of EDIFACT interchange structure with segment tagging
  >  - Raw view — Plain-text fallback for direct inspection of message content
  >  - Search — Real-time search with regex support, result count, and previous/next navigation
  >  - Focus mode — Highlights segments relevant to the current context (basket or invoice) when opened from those pages
  >  - JSON download — New ?format=json endpoint on edimsg.pl and download button for programmatic access and debugging; backed by a new to_json() method on Koha::Edifact

  **Sponsored by** *Martin Renvoize*
- [40391](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40391) EDI: Add support for GIR:LSL field
  >Add support for the Library Sub-location field in EDIfact messages, to allow both Collection Code and Location Code mappings from EDI messages.

  **Sponsored by** *OpenFifth*, *Royal Borough of Kensington and Chelsea* and *Westminster City Council*
- [41695](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41695) Suggestion->refuser returns the manager

### Architecture, internals, and plumbing

#### Enhancements

- [19871](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19871) Use new exceptions Koha::Exceptions::Object::DuplicateID and FKConstraint

  **Sponsored by** *OpenFifth*
- [20638](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20638) Add audit logging for API key actions
- [32370](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32370) Provide a generic set of tools for JSON fields
- [38365](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38365) Add Content-Security-Policy HTTP header to HTML responses
  >This change adds a configurable Content-Security-Policy HTTP header to Koha. This header instructs the browser to put restrictions on a number of actions like loading resources or ensuring use of HTTPS. It is an especially useful tool in preventing cross-site scripting (XSS).
- [39721](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39721) Remove GetSuggestion from C4/Suggestions.pm
- [39722](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39722) Remove GetSuggestionFromBiblionumber from C4/Suggestions.pm
- [39723](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39723) Remove GetSuggestionInfoFromBiblionumber from C4/Suggestions.pm
- [39724](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39724) Remove GetSuggestionInfo from C4/Suggestions.pm
- [39725](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39725) Remove GetSuggestionByStatus from C4/Suggestions.pm
- [39789](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39789) Add ability to specify an alternative header to X-Forwarded-For for finding the real IP address
- [39971](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39971) Patron attribute types form logic should be reusable
  >Internal refactoring of code for reusability. No end-user functionality changes.
- [40286](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40286) Make C4::Auth::checkpw_internal use Koha::Patrons->find_by_identifier
  >Consistently use find_by_identifier for authentication.
- [40811](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40811) Enhance Koha::File::Transport API
  >This enhancement introduces a modernized dual API design for Koha's file transport system, making it easier for developers to work with FTP, SFTP, and local file operations.
  >
  >  Key Improvements
  >
  >  Simplified API (Recommended)
  >  - Automatic connection management - no need for manual connect() / disconnect() calls
  >  - Per-operation directory control via options hashref
  >  - Stateless operations safe for concurrent usage
  >
  >  # Simple one-line operations
  >  $transport->upload_file($local, $remote, { path => '/custom/' });
  >  $transport->download_file($remote, $local);
  >  $transport->list_files({ path => '/incoming/' });
  >
  >  Traditional API (Still Supported)
  >  - Manual connection and directory management when needed
  >  - Ideal for multiple operations in the same directory
  >  - Full backward compatibility maintained
  >
  >  # Explicit control when needed
  >  $transport->change_directory('/work/');
  >  $transport->upload_file($local, 'file1.txt');
  >  $transport->upload_file($local, 'file2.txt');
  >
  >  Standardized Architecture
  >  - Consistent template method pattern across all transport types (SFTP, FTP, Local)
  >  - Clear separation between public API and protocol-specific implementation
  >  - Improved authentication handling with fixes for password-less connections
  >
  >  This is an internal API enhancement that improves code maintainability and developer experience without affecting end-user functionality.
- [40993](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40993) Do not allow direct calls of value_builder scripts
  >This report adds an Apache RewriteRule to prevent hitting cataloguing value_builder scripts (aka framework plugins) directly. They are supposed to be called only via plugin_launcher.pl.
- [41324](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41324) Tidy kohaTable block
  >https://wiki.koha-community.org/wiki/Coding_Guidelines#JS19:_Avoid_Template::Toolkit_tags_in_script_tags
- [41440](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41440) Add caching to language_get_description and get_rfc4646_from_iso639
- [41462](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41462) Koha objects namespace for OAI sets and biblios
  >This enhancement adds OAI sets and bibliographic records to the Koha::Objects namespace. This is an architectural change that makes these objects easier to access programmatically, for API endpoints and database relationships.

  **Sponsored by** *Auckland University of Technology*
- [41619](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41619) Add `Koha::CSV`
- [41797](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41797) Tidy kohaTable block - reports/guided_reports_start
- [41834](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41834) Remove systempreferences's options, explanation and type DB values
- [42003](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42003) Upgrade DataTables from 2.3.4 to 2.3.7 (and FixedHeader to 4.0.6)
  >This enhancement upgrades the DataTables JavaScript library from version 2.3.4 to 2.3.7.
  >
  >This brings in upstream fixes and improvements released since 2.3.4, especially version 4.0.6 of the FixedHeader plugin, which fixes a scrolling glitch with sticky headers.
- [42185](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42185) Too many dbh subroutines in C4::Context
- [42287](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42287) Tidy all script tags - members
- [42288](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42288) Tidy all script tags - reserve
- [42289](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42289) Tidy all script tags - tools

### Cataloging

#### Enhancements

- [17387](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17387) Add an undelete feature for items/biblios
  >When a bibliographic record or item is deleted in Koha, the data is moved to the
  >`deletedbiblio`, `deletedbiblioitems`, and `deleteditems` tables rather than being
  >permanently removed. This new feature exposes those tables through a dedicated staff
  >interface and REST API, enabling authorised users to restore that data back into the
  >active catalogue.
  >### New Features
  >- A **Restore Deleted Records** page is accessible from the Cataloguing module home page,
  >  presenting two tables: one for deleted bibliographic records and one for deleted items.
  >- Each table displays key identifying information such as biblio ID, title, barcode, and
  >  the date the record was deleted.
  >- A **date range filter** in the sidebar allows staff to narrow results by deletion date.
  >- Restoring a **deleted item** whose parent bibliographic record is also deleted will
  >  present a warning modal, prompting the user to restore the bibliographic record first.
  >- Restoring a **deleted bibliographic record** opens a modal listing any associated deleted
  >  items, with checkboxes allowing the user to select which items (if any) to restore
  >  alongside the bibliographic record.
  >- Restored records are automatically **re-indexed** in the search engine (Zebra /
  >  Elasticsearch) upon restoration.
  >- Restore actions are written to the **action log** (`RESTORE` action for both biblios
  >  and items), providing an audit trail.
  >- Library group membership is taken into account during permission checks, so staff are
  >  only able to restore records within their permitted scope.
  >### New REST API Endpoints
  >New endpoints have been added to the Koha REST API to support programmatic restoration
  >of deleted records:
  >- `POST /api/v1/deleteditems/{item_id}/restore` — restore a single deleted item
  >- `POST /api/v1/deletedbiblios/{biblio_id}/restore` — restore a single deleted
  >  bibliographic record
  >- `GET /api/v1/deleteditems` — list deleted items (supports embedding associated biblio
  >  data and pagination headers)
  >- `GET /api/v1/deletedbiblios` — list deleted bibliographic records (supports embedding
  >  associated deleted items)
  >### New Permission
  >A new **`restore_deleted_records`** permission has been added as a child of the
  >**Cataloguing** permissions group. Users must be granted this permission to access the
  >Restore Deleted Records page and to use the restore API endpoints.
  >### Important Notes
  >- Restoration is only possible for records still present in the deleted records tables.
  >  Data in related tables (e.g. link tracker, holds history) that was cascade-deleted when
  >  the record was removed **cannot** be recovered by this tool.
  >- A restored record will be re-inserted with its original biblio/item ID where possible.
  >- This feature does not constitute a full "soft delete" or undo system — it is a targeted
  >  recovery tool for data held in Koha's existing deleted-record tables.

  **Sponsored by** *ByWater Solutions*
- [32773](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32773) Have the ability to have more than 1 Fast Add framework
  >This enhancement adds the ability for libraries to use multiple bibliographic frameworks for Fast add.
  >
  >Administrators with the manage_marc_frameworks permission can now enable MARC bibliographic frameworks to be used as Fast add frameworks.
  >
  >Library staff with the fast_cataloging permission will be able to create and edit Fast add enabled bibliographic records. They will be able to create items for Fast add enabled records and edit the attached items if allowed by library or library group.
  >
  >A Fast add badge will be displayed in the details of Fast add enabled bibliographic records.

  **Sponsored by** *Cape Libraries Automated Materials Sharing*
- [33857](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33857) Reduce and resize local cover images
  >Previously, uploading a JPEG cover image to Koha's local cover image store caused the file to be re-encoded as PNG, increasing file sizes by up to 10×. A 170 KB JPEG would be stored as ~930 KB.
  >
  >After this fix, images are stored in their original format. The same image is now stored at ~92 KB — roughly half the original size, with no quality loss.
  >
  >This affects all installations using the LocalCoverImages system preference.
- [39418](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39418) Add authorized value lists for MARC21 RDA Carrier, Content, and Media Vocabularies
  >This enhancement adds authorized value lists for use in MARC21 tags 336 - Content Type, 337 - Media Type, and 338 - Carrier Type, subfields $a and $b. Note: Manual updates are required to your frameworks to link the subfields to the authorized value lists.
  >
  >The six new authorized value lists:
  >- RDACARRIER
  >- RDACARRIER_CODE
  >- RDACONTENT
  >- RDACONTENT_CODE
  >- RDAMEDIA
  >- RDAMEDIA_CODE

  **Sponsored by** *California College of the Arts*
- [40031](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40031) Creation of a new MARC modification template should redirect to have the template ID in the URL
  >This updates the URL when adding a new MARC modification template (Cataloging > Batch editing > MARC modification templates). It adds the template ID to the URL so that you can directly link to the template.
  >
  >Previously, you had to click `Edit actions` from the list of templates, and couldn't directly link to the template to see the actions:
  >- Previous URL after adding a template:
  >   STAFF-INTERFACE-URL/cgi-bin/koha/tools/marc_modification_templates.pl
  >- New URL after adding a template: 
  >   STAFF-INTERFACE-URL/cgi-bin/koha/tools/marc_modification_templates.pl?template_id=(template_id)&op=select_template
- [40154](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40154) Deleting an item does not warn about an item level hold

  **Sponsored by** *Koha-Suomi Oy*
- [40584](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40584) When AutoControlNumber is activated, do not show 001 in Advanced Editor
- [40633](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40633) Add keyboard shortcut to advanced cataloging editor for fixed length field plugins
  >This enhancement adds a keyboard shortcut to the advanced cataloging editor to open the value builder plugins for the MARC leader, 006, 007, and 008 fields. This shortcut defaults to Control-Shift-H but can be customized as desired.

  **Sponsored by** *Main Library Alliance*
- [40841](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40841) Limit z39.50 targets to specific libraries
  >This enhancement adds the option to limit the Z3950/SRU targets to specific libraries.
  >
  >Within larger systems, catalogers at individual library may have different z39.50 targets that they prefer to use or are allowed access to.
- [41060](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41060) Add a value_builder to check if ISSN is valid
  >This enhancement adds a new cataloging plugin (value builder) for validating ISSNs. If you enter an invalid ISSN, a browser pop-up window warns that the ISSN is invalid, but you can ignore this (the field is highlighted in yellow) and still save the record.
  >
  >For new installations, the validate_issn.pl plugin is added to the bibliographic frameworks by default for 022$a (MARC21) or 011$a (UNIMARC).
  >
  >For existing installations, update your frameworks manually.
- [41170](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41170) Highlight previously edited item on add items page
  >This patch adds highlighting of the most recently edited/added item on the 'add items page'
  >The feature allows catalogers to identify recent item and confirm their edits or compare to other items in the catalog.
- [41902](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41902) Allow configuration of bibliographic information to be shown on new record duplicate check
  >This enhancement adds a way to display more bibliographic information when Koha suspects a newly-created bibliographic record may be a duplicate of an existing record. This is done through "Tools" > "Additional content" >  "Record display customizations", using the new display location of StaffDuplicateCheckPage. Information to be displayed is defined in TemplateToolkit and styled with HTML. Available data includes the contents of the biblio table and the full MARC record.

### Circulation

#### Enhancements

- [7376](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7376) Transfer limits should be checked at check-in
  >This patch introduces new controls to prevent a check-in at a library where transfer rules would forbid the item transfer back to this item's home/issuing library.
  >
  >For items set to 'float' transfer rules are not set as the check-in would not trigger a transfer.

  **Sponsored by** *National Library of Finland*
- [16131](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16131) Error messages for library transfers show with bullet points
  >When transferring items (Circulation > Transfers > Transfer), any error messages are shown as a bulleted list in one alert box.
  >
  >If there is only one error, it looks a bit odd having a bulleted list with only one item. 
  >
  >With this enhancement, each error message is now shown in its own alert box.

  **Sponsored by** *Catalyst*
- [23415](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23415) Notify patron fines when renewing
  >It was possible to renew items for patrons who had fines over the accepted limit on the renew item page or from their list of checkouts.
  >
  >This enhancement adds a new system preference, `AllowFineOverrideRenewing`, to allow staff to renew items for patrons with fines greater than value in `FineNoRenewal` (previously OPACFineNoRenewals).
  > 
  >### New features
  >
  >- New system preference `AllowFineOverrideRenewing`. It allows staff to renew items for patrons whose fines are over the amount set in the `FineNoRenewals` system preference. Otherwise, renewing is prevented. If renewing items is allowed, staff are still required to confirm if they really want to renew items for the patron.
  >
  >### Changes made to system preferences and API endpoints
  >
  >- These system preferences were renamed as they are now also used in the staff interface (not just the OPAC):
  >  - OPACFineNoRenewals was renamed FineNoRenewal.
  >  - OPACFineNoRenewalsIncludeCredits was renamed FineNoRenewalsIncludeCredits.
  >  - OPACFineNoRenewalsBlockAutoRenew was renamed FineNoRenewalsBlockAutoRenew. 
  >- Adds support to the REST API renewal endpoints for the AllowFineOverrideRenewing functionality.
  >
  >### Important notes
  >
  >- There were several places in the code where the auto-renewal error code was written as "auto_too_much_oweing" instead of "auto_too_much_owing".
  >- The same typo was also present in example notices templates, and possibly in notice templates saved in the database.
  >- The typo is automatically fixed with a database update.

  **Sponsored by** *Koha-Suomi Oy* and *OpenFifth*
- [26993](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26993) Allow StoreLastBorrower to retain a locally-defined number of previous borrowers
  >This enhancement expands the StoreLastBorrower system preference to allow for the retention of a locally defined number of previous borrowers for a given item. This enhancement also introduces a mechanism that will delete any extra borrowers stored in the items_last_borrower table that exceed the number set in the StoreLastBorrower system preference.
- [28530](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28530) Allow configuration of floating limits by item type
  >This enhancement adds the ability to define and enforce a maximum number of items per item type to be held at each library when items are allowed to float. This feature is enabled with the UseLibraryFloatLimits system preference. Float limits are defined within Administration. Items checked in at a library that has met its float limit for that item type will be transferred to the branch with the lowest ratio of held items to allowed items.
- [30331](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30331) Allow RenewalPeriodBase behavior to differ between manual and automatic renewals
  >This patchset splits the RenewalPeriodBase system preference into two separate system preferences so the renewal base period can be controlled separately for for manual and automatic renewals. The new system preferences are ManualRenewalPeriodBase and AutomaticRenewalPeriodBase.
- [32682](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32682) Add permission for viewing patron reading history
  >This enhancement adds a new permission for viewing parton's reading history. ( view_checkout_history ) 
  >Now when intranetreadinghistory is enabled staff must also have the specific 'view_checkout_history' permission in order to view a patron's reading history. With intranetreadinghistory turned off the no users are able to view patron's reading history.
- [37707](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37707) Lead/Trail times should work in combination
- [37966](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37966) When overriding a hold to renew a book the due date becomes "now" if not specified
- [39802](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39802) Add CircControl equivalent system preference for lost item fees and actions
  >This enhancement adds a new system preference: LostChargesControl which is used to determine the branch that is used to look up the circulation rule for charging lost fees when an item is marked lost.
  >
  >Choices are:
  >library the item is from (follows HomeOrHolding)
  >library the patron is from
  >library you are logged in at
  >
  >Currently this is only used by the longoverdue cronjob. Selecting "library you are logged in at" will cause the cronjob to cancel as there is no branch - this mimics current behavior, but is more verbose.

  **Sponsored by** *MAIN Library Alliance*
- [40364](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40364) Add permission for viewing patron holds history
  >This enhancement adds a new permission for viewing parton's hold history. ( view_holds_history ) 
  >Now when IntranetReadingHistoryHolds is enabled staff must also have the specific 'view_holds_history' permission in order to view a patron's hold history. With IntranetReadingHistoryHolds turned off the no users are able to view patron's hold history.
- [41134](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41134) Add table settings to transfers
  >This enhancement adds standard table settings to the transfers table (Circulation > Transfers > Transfer). This includes options to change the columns shown, export data, and to configure the default table settings.

  **Sponsored by** *Athens County Public Libraries*
- [41338](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41338) Hold found dialog does not show item home and check-in libraries
- [41539](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41539) Include item barcode in waiting hold message on patron record
  >This enhancement adds the item barcode to the holds waiting information on a patron's check out and details page.
  >
  >This makes it easier for circulation staff to copy the barcode to check the item out when a patron picks it up (where this is the library workflow and a self-service option is not available.
  >
  >Before: Title (Item type), Author. Hold place on DD-MM-YY
  >After:  Title (Item type), Author. (Barcode) Hold place on DD-MM-YY

### Command-line Utilities

#### Enhancements

- [23260](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23260) Anonymize (remove) patron data from items_last_borrower
  >This enhancement allows the automatic deletion of data from the items_last_borrower table. This data is generated based on the StoreLastBorrower system preference. Deletion of this data performed by the new cronjob anonymize_last_borrowers.pl, with its behavior governed by the new system preferences AnonymizeLastBorrower and AnonymizeLastBorrowerDays. When the cronjob is run, entries in items_last_borrower are anonymized if older than the number of days defined in AnonymizeLastBorrowerDays.
- [33308](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33308) Add ability to to use SFTP with runreport.pl
- [37538](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37538) Improve documentation printed by connexion_import_daemon.pl --help
  >Use `misc/bin/connexion_import_daemon.pl --help` to view more detailed information about the options available for this script.

  **Sponsored by** *Reformational Study Centre*
- [38549](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38549) Make create_superlibrarian.pl script accept a name parameter
  >This enhancement enables the user to supply a surname parameter when creating a superlibrarian user via the commandline script create_superlibrarian.pl. Koha patrons MUST have a name, so if no surname is provided, the userid will be used for the surname instead.

  **Sponsored by** *Catalyst*
- [41062](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41062) Expand cronjob erm_run_harvester.pl with parameter for providers
  >This enhancement adds a new option to define specific providers in the cronjob erm_run_harvester.pl that are used to run the harvesting for COUNTER Reports in the ERM module.
  >Use parameter --provider-id or -p
  >The parameter provider-id is repeatable.
  >If the parameter for provider-id is not used all active providers will be harvested (as before).
  >The script will check if these providers are active (as before).

  **Sponsored by** *Karlsruhe Institute of Technology (KIT)*
- [41851](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41851) Add logging to EDI cron job

### Continuous Integration

#### Enhancements

- [41368](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41368) Tools/ManageMarcImport_spec.ts is failing

### Database

#### Enhancements

- [41409](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41409) Streetnumber has a different data type in borrower_modifications
  >The database data types for these fields are tinytext in the borrowers table and varchar(10) in the borrower_modifications table:
  >
  >- streetnumber (a patron's main address street number field)
  >- B_streetnumber (a patron's alternate address street number field)
  >
  >This enhancement updates the borrower_modifications table so that the fields are now tinytext, consistent with the borrowers table.

  **Sponsored by** *Cheshire Libraries Shared Services*

### ERM

#### New features

- [39320](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39320) Create a 'landing page' for ERM
  >This adds a customizable landing page to the ERM module. Staff members can remove, add, and reorganise landing page "widgets" to customize the landing page layout to suit their needs (all widgets are shown by default):
  >
  >- Counts: shows the number of ERM related resources such as agreements, licenses, local packages, local titles, etc.
  >- Licenses needing action: shows licenses that need action - it filters licenses by status and end date (this is configurable from the settings menu item for the widget). 
  >- Run eUsage report: lets you select a saved eUsage report to run.
  >- Latest SUSHI Counter jobs: shows the latest SUSHI Counter background jobs.

  **Sponsored by** *UK Health Security Agency*

#### Enhancements

- [39438](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39438) Add additional fields to agreements periods

  **Sponsored by** *Karlsruhe Institute of Technology (KIT)*
- [40191](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40191) Design pattern: Redirect user to a view of the record after saving instead of list

  **Sponsored by** *Karlsruhe Institute of Technology (KIT)*
- [40192](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40192) Add additional fields to ERM titles
  >This adds the option to add additional fields to ERM titles. The fields can be either free text or linked to an authorized value for a pull down list. They can be set to repeatable and made searchable.

  **Sponsored by** *Karlsruhe Institute of Technology (KIT)*

### Fines and fees

#### Enhancements

- [35612](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35612) Record branch context in accountlines.branchcode for OVERDUE, LOST, and PROCESSING fees
  >This enhancement allows the optional recording of the branch used when generating an accountline.
  >
  >For OVERDUE fees, the branch chosen by CircControl will be reflected here. For LOST and PROCESSING fees, the branch chosen by LostChargesControl will be reflected here.
  >
  >This development will allow librarians to reference charges against the circ rules to determine which branches rule was applied when creating a fine.
- [36506](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36506) Processing fee should be configurable by library
  >This enhancement adds a new section to the Circulation and fines rules page, and allows the configuration of processing fees per branch and itemtype.
  >
  >Following the LostChargesControl syspref, the rule will be chosen based on the branch selected and items will be charged the corresponding processing fee when marked lost if there is one defined.

  **Sponsored by** *The Main Library Alliance*
- [40255](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40255) Allow custom debit descriptions
  >This patchset allows for the ability to set custom debit descriptions via Notices and Slips by adding a new module called "Debit description (custom)" to notices/slips.. By using a Debit description (custom) notice/slip with the same name as a debit type, a custom debit description will be used instead of the default.

### Hold requests

#### Enhancements

- [3492](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=3492) Move hold fee setting into circulation rules
  >Hold fees can now be configured through the circulation rules matrix, providing much more granular control over hold charges based on patron category, item type, and library combinations.
  >
  >Previously, hold fees (reservefee) could only be set at the patron category level in the patron category administration. This enhancement integrates hold fees into the main circulation rules system, where they follow the standard rule hierarchy with automatic fallback handling.
  >
  >**Key changes:**
  >
  >- Hold fees can now be set for specific combinations of patron category, item type, and library
  >- The deprecated `reservefee` field has been removed from patron categories
  >- Hold fee configuration appears as a new column in the circulation rules matrix
  >- Hold fees follow the same rule precedence as other circulation rules (most specific rule wins, with fallback to broader rules)
  >
  >**For administrators:**
  >
  >After upgrading, you may want to review your circulation rules and update hold fees where appropriate. Any existing hold fees previously set at the patron category level will have been migrated to the circulation rules.

  **Sponsored by** *OpenFifth*
- [40435](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40435) Allow CanBookBeRenewed to consider future holds
  >Historically, renewals are not blocked for future holds (which are only possible when enabled). This report adds a new preference FutureHoldsBlockRenewals to override that behavior. If you enable it, renewals are blocked by future holds when they are not further away than the threshhold used for Holds to Pull in preference ConfirmFutureHolds.
- [40769](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40769) Highlight hold fees when placing a hold from the staff interface
  >This enhancement adds hold fee information display in the staff interface's hold
  >request interface, bringing it to feature parity with the OPAC.
  > 
  >The OPAC already shows patrons the fee that will be charged for placing
  >a hold, but the staff interface did not display this information when staff
  >place holds on behalf of patrons. This creates a transparency gap where
  >staff cannot inform patrons about potential charges.
- [41957](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41957) Hyperhold/hold group information should show on 'Hold found' modal
  >This enhancement adds a notification to the hold found modal when the hold to be filled is part of a group. The modal will include the message "part of a hold group" and a link to the holds table in the patron's account.
- [41983](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41983) Holds queue should show when holds are part of a group
  >This adds "(part of a hold group)" to the holds queue (under the title in the title column), when hold groups are enabled (DisplayAddHoldGroups system preference).

### I18N/L10N

#### Enhancements

- [38136](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38136) Refactor database translations (alternative)
- [39580](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39580) Make Elasticsearch process_error error string translatable

### ILL

#### New features

- [37762](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37762) Expand ILL to allow for supplying agency/lending library workflows

#### Enhancements

- [33544](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33544) Squash some ILL fields to alleviate request table overflow
- [40105](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40105) Patrons cannot add notes when creating an ILL
- [40504](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40504) ILL requests should have ability to assign staff to manage
  >This enhancement adds a "Managed by" feature for Interlibrary Loan (ILL) requests, mirroring existing functionality in purchase suggestions. This is particularly beneficial for large consortia managing high volumes of requests.
- [41009](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41009) When editing an ILL request, the user is returned to the list
  >This enhancement will return a user to the ill request page instead of the list of requests after saving an edit.
- [41054](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41054) Standard ILL form should consider eISSN field
  >This adds the 'eISSN' field to the ILL Standard forms where ISSN is also present.
- [41281](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41281) ILL request metadata doesn't show if falsy
- [41536](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41536) ILL "Confirm Request" button fails to stand out as a primary action

### Lists

#### Enhancements

- [42267](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42267) Update lists pages to use grid layout for forms

  **Sponsored by** *Athens County Public Libraries*

### MARC Authority data support

#### Enhancements

- [41093](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41093) Authority search for 'See ...' references inserts "None specified" when no relationship is chosen

### MARC Bibliographic data support

#### Enhancements

- [38096](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38096) Field 857 is not considered for display on XSLT files
- [41000](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41000) Update label on record detail pages for 041$d - "Spoken language" to "Sung or spoken language"
  >This enhancement updates the label on detail pages in the staff interface
  >and OPAC for records with a 041$d (MARC21) - Language code of sung or spoken text.
  >
  >It is now labelled as "Sung or spoken language", instead of "Spoken language" --better matching the MARC21 definition.
  >
  >For music libraries, this also more accurately reflects the information for the record.

### MARC Bibliographic record staging/import

#### Enhancements

- [39516](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39516) Record and display record matching rule composite scores
  >This enhancement adds a column to the table of records on the "Manage staged MARC records" screen. The new "Score breakdown" column displays the full scoring details from the matching rule used during staging, allowing the user to see specifically how a record was matched. When a record matches on multiple match points all are displayed. The column is hidden by default but can be set to show via Table Settings in the Administration module.

  **Sponsored by** *Main Library Alliance*

### Notices

#### Enhancements

- [35267](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35267) Clarify CSS options for Notices
  >Clarify existing and add new CSS options for Notice Templates.

  **Sponsored by** *OpenFifth*
- [40719](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40719) Explicit turn off RELATIVE file paths for plugins for user-entered templates

### OPAC

#### Enhancements

- [25314](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25314) Make OPAC facets collapse
  >This enhancement modifies the OPAC catalog search results page's facets menu, adding the ability to click on a facet heading to collapse it.

  **Sponsored by** *Athens County Public Libraries*
- [32483](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32483) Show requested changes to personal details in OPAC
- [34025](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34025) Uniform titles (130 / 240 /730) in bibliographic record to link to authority file
- [35192](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35192) Highlight search terms in OPAC Title notes tab
  >This enhancement highlights matching search terms in the OPAC record details page notes tab (when the OpacHighlightedWords system preference is set to 'Highlight').

  **Sponsored by** *Catalyst*
- [39027](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39027) News are ordered with oldest on top
- [39698](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39698) Add option to expand responsive datatable rows by default
  >This enhancement lets you control the default responsiveness of OPAC tables, such as OPAC search history. New system preference 'OPACTableColExpandedByDefault' controls the default behavor. Tables are collapsed by default with a '+' to expand, and when expanded a '-' is visible to collapse. (This enhancement is a result of recommendations from a recent accessibility audit.)
  >
  >** Sponsored by: Open Fifth **

  **Sponsored by** *British Museum*
- [40060](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40060) Update structure of popup windows in the OPAC

  **Sponsored by** *Athens County Public Libraries*
- [40659](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40659) Allow "My virtual card" format and content to be customizable
- [41655](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41655) Local OPAC covers are not displayed in OPAC lists
  >This fixes a regression where the local cover images were no longer displayed in lists in the OPAC and staff interface. With this fix, the local cover images are back in the lists in both interfaces.
- [41768](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41768) OPAC pickup location selector doesn't reflect available pickup location if you select a specific item
- [41955](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41955) OPAC: Patron hold history table should show hyperhold/hold group information

### Patrons

#### Enhancements

- [21555](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21555) Merging Patrons allows for all patrons to be selected

  **Sponsored by** *Cape Libraries Automated Materials Sharing*
- [26355](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26355) Allow patron account renewals through the OPAC

  **Sponsored by** *Westminster City Council*
- [30303](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30303) Add ability to select which values to retain when merging patrons
  >This enhancement provides greater control over data preservation and streamlines the process of managing duplicate patron records.
  >
  >When merging two patron records, users can now selectively copy fields to retain from the record being deleted (source) into the record being kept (destination).

  **Sponsored by** *Cape Libraries Automated Materials Sharing*
- [39927](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39927) Add permissions check to PatronSelfRegistrationAlert on home page
  >This enhancement fixes the staff interface home page so that the "Self-registrations from" alert is only shown if the staff patron has the correct permissions. Before this, the alert was shown when the staff patron didn't have any borrower permissions.

  **Sponsored by** *Athens County Public Libraries*
- [40794](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40794) Add an id to the div containing payments tabs
  >An id="account-tabs" attribute has been added to the account/payment tab navigation (Transactions, Make a payment, Create manual invoice, Create manual credit). This allows for easier customization and targeting with CSS/JS without conflicting with the global toptabs navigation.
- [41411](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41411) Streetnumber field is limited to 10 characters despite being tinytext
  >The input form for a patron's main and alternative address street number fields are limited to 10 characters, even though the underlying database field can have up to 255 characters.
  >
  >This enhancement removes this 10-character limit, which makes it more useful where house names are used instead of house numbers.
- [41749](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41749) Add patron consent status display to staff patron detail page
  >Adds a "Consents" section to the staff patron detail page. It shows the patron's privacy consent status (when PrivacyPolicyConsent
  >is enabled) and any plugin-defined consent types.
  >
  >Each consent displays with visual status indicators:
  >- Green checkmark with timestamp when consent was given
  >- Red X with timestamp when consent was refused
  >- Gray "Not specified" when no consent recorded
- [41814](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41814) Limit the maximum age for patron categories without a specified range
  >This patch adds a new system preference `PatronAgeRestriction`, which acts in the same way `PatronSelfRegistrationAgeRestriction` (a restriction on the maximum age of a borrower), except for the intranet. It will also act as the maximum age restrictor on the OPAC, in the event that the `PatronSelfRegistrationAgeRestriction` is not set.

  **Sponsored by** *Cheshire Libraries Shared Services*
- [41954](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41954) Staff interface: Patron hold history table should show hyperhold/hold group information

### Plugin architecture

#### Enhancements

- [36542](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36542) In C4/AddBiblio, plugin hook after_biblio_action is triggered before the record is actually saved
  >This bug fix moves when the after_biblio_action plugin hook is triggered so the record can be saved before the plugin hook is called. This will let the plugin save biblionumbers on newly created records that would otherwise not be generated yet.
- [39522](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39522) Add hooks to allow 'Valuebuilder' plugins to be installable

  **Sponsored by** *OpenFifth*
- [40095](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40095) It would be beneficial to send the page when calling intranet_js plugin hooks
  >The get_plugins_intranet_js method now passes the current script name
  >(controller) to plugins via a 'page' parameter, allowing plugins to
  >determine which page/controller is being displayed.
  > 
  >This will allow plugin authors to only return JS that's relevant to the
  >current page when they wish to do so.
- [40972](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40972) New hook: extend MARC filter
- [42150](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42150) Allow plugins to register Vue islands via registerIsland()
  >The islands module provides Koha's Vue component architecture but does not expose a public API for external registration. This enhancement enables plugins to contribute Vue islands to the staff interface.
  >It also lays the groundwork for bug 42189 which allows plugins to create new dashboard widgets.

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

- [28701](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28701) primary_contact_method not part of the REST API spec
- [29668](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29668) Add API route to create a basket
- [41107](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41107) Create an API endpoint to get Koha version
  >This enhancement adds a new REST API endpoint to retrieve Koha version information. The returned version object includes the full version string (e.g., '25.06.00.029') as well as its constituent parts: major version number, minor version number, release number, maintenance version number, and development version number (if applicable). This prepares the foundation for a future /status endpoint that will include all information displayed in the About page.
- [41733](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41733) Honor EmailPatronRegistrations preference in the API
- [41901](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41901) Allow duplicate check when adding authority via API
- [41994](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41994) REST API route to list system preferences
- [42206](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42206) Add REST endpoint GET /libraries/{library_id}/closed_dates

  **Sponsored by** *Büchereizentrale Schleswig-Holstein*

### Reports

#### Enhancements

- [39043](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39043) Style improvement to guided reports controls

  **Sponsored by** *Athens County Public Libraries*
- [39164](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39164) Add max_statement_time to SQL report queries
  >This patchset adds the abilty to set a maximum execution time in seconds for SQL report queries. Reports exceeding this limit will be automatically terminated. This is configured in the koha-conf.xml file by setting the report_sql_max_statement_time_seconds parameter. By default this is turned off.
- [40896](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40896) Run report button should be disabled after click
  >The "Run report" buttons in the guided reports interface are now disabled upon click and display a spinner icon, preventing accidental duplicate submissions that could overload the system. This improvement uses a new reusable throttled button component that automatically re-enables after a configurable timeout and correctly handles browser back-forward cache navigation. The component wraps icons in semantic containers for accessibility (aria-busy) and is designed to be reused across other parts of the staff interface.
- [41918](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41918) Prevent users from running the same report multiple times concurrently
- [41919](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41919) Limit number of current reports a single user can run simultaneously
- [42190](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42190) Add datatables to reports
  >This enhancement allows report results to be viewed with the  DataTables feature used elsewhere in Koha. DataTables allows sorting by any column in the results as well as dynamic filtering. Export options within the DataTables view include a new Copy option and export data respecting the user's current sorting and filtering.
- [42406](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42406) Create permission to allow user to delete only their own reports

### SIP2

#### Enhancements

- [41214](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41214) Cash register should only show if UseCashRegisters sys pref is enabled
  >This change turns the display of the 'cash register' field in SIP2 accounts to become conditional depending on whether the UseCashRegisters sys pref is enabled or not.
  >For developers: This changes the hideIn option for VueJS framework resources, now allowing it to be a callback function which is checked in real-time, dictating whether a field is displayed or not.
- [41311](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41311) Add ability for SIP to send patron home library ( branchcode ) in AO field
- [41383](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41383) SIP2 server does not search patrons by unique patron attributes (alternate IDs unusable in SIP2)

### Searching

#### Enhancements

- [36920](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36920) Greater/less than search option on item search page to Barcode-drop-down menu
  >This enhancement adds greater than and less than search options on item search page field drop-down menu. With them staff can search e.g. items which have release year starting from specific year.

### Searching - Elasticsearch

#### Enhancements

- [21820](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21820) Zebraqueue should not be added to when only Elasticsearch is used
  >We added a new syspref "ElasticsearchEnableZebraQueue". If disabled, no data will be written to the zebraqueue table, because usually when using Elasicsearch you don't need to also run Zebra.
  >
  >But if your workflows require changed biblio/auths to show up in the zebraqueue table, set the syspref to "enable". When upgrading, the old behavior will be kept, i.e. the syspref is set to "enable". New installations will default to "disable".
- [22639](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22639) Ability to export Elasticsearch mappings and facets settings
  >This enhancement adds an 'Export mappings' button to the Elasticsearch mappings configuration page to download the current search field mappings as YAML.
- [36550](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36550) koha-elasticsearch commit default should be configurable
  >You can now set custom defaults for koha-elasticsearch in /etc/default/koha-common. You can still override the defaults using the command line.
- [36849](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36849) Add more tags to Elasticsearch mapping for title, title as phrase
  >This enhancement adds these fields to the 'title' index for new installations using Elasticsearch: 440$a, 600$t, 800$t, 810$t, 830$n$p. This makes records with information in these fields findable in the staff interface and OPAC, and in the advanced search, when using the 'Title' and 'Title as phrase' options.
  >
  >Note: Existing installations will need to either manually add these, or reset the mappings.

  **Sponsored by** *Education Services Australia SCIS*
- [36853](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36853) Enhance Elasticsearch Notes/Comments MARC21 index mappings
  >This enhancement adds these note subfields to the Notes/Comments index for new installations using Elasticsearch: 501$a, 503$a, 504$a, 508$a, 511$a, 521$a, 538$a, and 547$a. This makes them notes findable in the staff interface and OPAC, and in the advanced search for when the Notes/Comments option is selected.
  >
  >Note: Existing installations will need to either manually add these, or reset the mappings.

  **Sponsored by** *Education Services Australia SCIS*
- [37099](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37099) Add uniform title fields to the title and subject Elasticsearch index mappings
  >This enhancement adds the 630$a field to the 'subject (Topics)' search field index for new installations using Elasticsearch.
  >
  >Note: Existing installations will need to either manually add the mapping, or reset their mappings.

  **Sponsored by** *Education Services Australia SCIS*
- [39158](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39158) Reduce code duplication in marc_records_to_documents
- [40577](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40577) Bulk update Elasticsearch index for bibliographic records after authority change
  >When merging (or updating) authorities, the Elasticsearch indexing of the linked biblios now will happen in one background job per authority instead of one background job per biblio. So an authority that is used in 100 biblios will now trigger one indexing background job with 100 biblio items instead of 100 background jobs with 1 biblio item each.
- [42016](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42016) Add identifier-other search field for authorities (MARC 21)

  **Sponsored by** *Pontificia Università di San Tommaso d'Aquino (Angelicum)*
- [42107](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42107) Add score to staff search results

### Self checkout

#### Enhancements

- [23909](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23909) SCO allows to check out items with Waiting state if AllowItemsOnHoldCheckoutSCO
  >This enhancement extends the options in the system preferences AllowItemsOnHoldCheckoutSCO and AllowItemsOnHoldCheckoutSIP. When a patron attempts via the web-based self-checkout or SIP to check out an item on which another patron has a hold, libraries now have the option to block all checkouts, allow the checkout if the hold is pending, or allow the checkout if the hold is pending or waiting. The new system preference AllowHoldCheckoutOverride governs whether or not staff with sufficient permissions should be able to check out on-hold items to other patrons via the staff client.

### Serials

#### Enhancements

- [38009](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38009) Add a generate next button in serials receive page
  >This enhancement adds a "Generate next" button to the receive page for a serial, similar to the one on the serial collection page (Serials > [subscription page] > Receive).

  **Sponsored by** *Pymble Ladies' College*
- [38061](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38061) Serials collection table improvements
  >This introduces for each new and existing subscription a field named "Pre-select issues in the collections table"
- [41330](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41330) Brace are not escaped in serials number management
  >Brace in numbering patterns in serials are not breaking anymore the reception of serials
- [42076](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42076) Add vendor ID column to serial vendor search results

### Staff interface

#### Enhancements

- [24949](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24949) Provide password visibility toggle / icon to unmask password on staff login screen

  **Sponsored by** *Athens County Public Libraries*
- [35211](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35211) Make it possible to split holdings tab using library groups in intranet
  >This enhancement adds a new system preference `SeparateHoldingsByGroup.` When this preference is enabled and the logged-in library is part of a library group marked `Use for staff search groups,` the holdings table will include a tab listing all items with a homebranch within that group. When `SeparateHoldings` is also enabled, the `Other holdings` tab will only include items not owned by either the logged-in library or a library sharing a group with the logged-in library.
- [36698](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36698) Display 'diff' nicely in action logs
  >This enhancement adds styling to the `diff` column in the action logs to make it more human readable.
- [38728](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38728) Add option to automatically trigger cashup summary modal after cashup
  >This enhancement automatically displays the cash register summary in a pop-up window after recording a cashup (from both the individual cash register details page and the cash registers summary page).
- [38946](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38946) Add serial enumeration to inventory table
  >This change adds a "Serial enumeration / chronology" column into the inventory results. This is particularly useful when doing inventory/stocktake with serials which share the same call number but have different volume numbers. This new column can be hidden by clicking "Columns" and hiding it or going into table settings.
- [39142](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39142) Add debug permission to allow user to toggle JS and CSS customizations on/off
  >This fix adds GUI controls to disable custom CSS and JS on the page. It also includes a system preference, user flag, to control managing this along with updates to permissions for being able to do this. This works alongside the pre-existing url parameters to disable custom css and JS in the page.
- [40816](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40816) Upgrade DataTables from 2.1.8 to 2.3.4
  >This enhancement upgrades the DataTables JavaScript library from version 2.1.8 to 2.3.4.
  >
  >This brings in upstream fixes and improvements released since 2.1.8, including bug fixes and general stability updates.
  >
  >No functional changes are expected in Koha beyond those provided by the updated DataTables library.
- [40933](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40933) Add SMS support under Add message feature
  >This new feature allows staff with appropriate permissions, `send_messages_to_borrowers`, to send SMS messages patrons from the patron details pages.
  >
  >Notice templates can be defined, and used for defaults, using the `Patrons (custom message)` module.
- [41206](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41206) Add collection to transfers to receive
- [41692](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41692) "See all charges" link in the guarantor details does not activate Guarantees charges tab
- [41885](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41885) Rename iso2709 to MARC for the staff interface download options for the cart and lists (to match the OPAC)
  >This enhancement renames iso2709 to MARC for staff interface cart and lists download options. This now matches the OPAC.

### System Administration

#### Enhancements

- [28495](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28495) Add hint about whitespace usage upon library creation
- [41332](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41332) Add new option for Greek (el) to the 'KohaManualLanguage' System Preference
  >This enhancement adds 'Greek' to the list of languages
  >for the KohaManualLanguage system preference.
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
- [37773](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37773) Show search term in cataloging search results
  >This enhancement updates the cataloging search results page so that the search term is shown in the page title, breadcrumb, and headings (Staff interface > Cataloging > Cataloging search).

  **Sponsored by** *Athens County Public Libraries*
- [39255](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39255) Improve translation of title tags: OPAC part 4
  >This fixes several OPAC templates so that the title tags can be more easily translated. There is no (or minimal) differences in the English browser tab titles.

  **Sponsored by** *Athens County Public Libraries*
- [39715](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39715) Do not quote DataTables options
  >This patch updates templates so that the options passed to DataTables, via KohaTable, are not quoted. The quotes are not necessary, and are not consistent with official DataTables documentation. This establishes a standard for us to follow in the future.

  **Sponsored by** *Athens County Public Libraries*
- [39780](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39780) Update library groups form to use grid layout

  **Sponsored by** *Athens County Public Libraries*
- [40113](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40113) Update accounting admin pages to use grid layout for forms

  **Sponsored by** *Athens County Public Libraries*
- [40727](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40727) Minor styling bug in print/email receipt pop-up menu
- [41350](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41350) Terminology: Biblio was already issued
  >This changes the log viewer message "Biblio was already issued" to "An item from this bibliographic record is already checked out."
  >
  >This action is recorded in the logs when `AllowMultipleIssuesOnABiblio` is set to "Don't allow" and staff confirm a check-out where a patron has already checked out another item for the record.

  **Sponsored by** *Athens County Public Libraries*
- [41562](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41562) Introduce the concept of "stores" for regular javascript
- [41563](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41563) Tidy kohaTable block - acqui
- [41564](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41564) Tidy kohaTable block - admin
- [41565](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41565) Tidy kohaTable block - bookings
- [41566](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41566) Tidy kohaTable block - catalogue
- [41567](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41567) Tidy kohaTable block - cataloguing
- [41568](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41568) Tidy kohaTable block - circ
- [41569](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41569) Tidy kohaTable block - clubs
- [41570](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41570) Tidy kohaTable block - course_reserves
- [41571](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41571) Tidy kohaTable block - labels
- [41572](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41572) Tidy kohaTable block - members
- [41573](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41573) Tidy kohaTable block - patron_lists
- [41574](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41574) Tidy kohaTable block - patroncards
- [41575](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41575) Tidy kohaTable block - pos
- [41576](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41576) Tidy kohaTable block - reports
- [41577](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41577) Tidy kohaTable block - reserves
- [41578](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41578) Tidy kohaTable block - serials
- [41579](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41579) Tidy kohaTable block - suggestions
- [41580](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41580) Tidy kohaTable block - tools
- [41581](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41581) Tidy kohaTable block - virtualshelves
- [41582](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41582) Tidy kohaTable block - opac
- [41638](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41638) Patron record field labels lack distinct id in HTML
  >This enhancement adds ids to all the labels on memberentry.pl with the convention of <label for="surname" id="surname_label"> for easier jquery selection.
- [41677](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41677) Use template wrapper for tabs: OAI repositories

  **Sponsored by** *Athens County Public Libraries*
- [41823](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41823) Update acquisitions admin pages to use grid layout for forms

  **Sponsored by** *Athens County Public Libraries*
- [41827](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41827) Update authority types pages to use grid layout for forms

  **Sponsored by** *Athens County Public Libraries*

### Test Suite

#### Enhancements

- [41362](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41362) Allow Cypress tests to use KOHA_USER and KOHA_PASS as override

### Tools

#### Enhancements

- [8088](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8088) Png-images of covers lost transparency
- [16994](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16994) Import and export MARC modification templates
  >This enhancement brings in the possibility for a librarian to export a Marc modification template in a json file. This can serve either as a backup or for sharing purposes.
- [40135](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40135) Record diff in action logs when modifying a bibliographic record
  >This enhancement adds a 'diff' to the action logs when modifying a bibliographic record (creating, modifying, and deleting).
  >
  >Previously, no diff was recorded (although some information was recorded in the Info column).
  >
  >Note: Details for changes to items were already recorded a diff.
- [40136](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40136) Record diff in action logs when modifying a patron
  >This enhancement adds a 'diff' to the action logs when modifying a patron (creating, modifying, changing a card number, and deleting).
  >
  >Previously, no diff was recorded (although some information was recorded in the info column).
- [40905](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40905) Past unique holidays not shown when enabling Show past checkbox
- [41126](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41126) Move shelving location into a separate column in inventory

  **Sponsored by** *Athens County Public Libraries*
- [42188](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42188) Fix display regressions in action logs for biblio changes
  >Restore and improve the action logs displays for biblio modifications.
  >
  >We use MARC-in-JSON format to give a structure, properly encoded, output in the details field.

### Transaction logs

#### Enhancements

- [42030](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42030) Add diff support to SUGGESTION action logs
  >This enhancement adds a 'diff' to the action logs for purchase suggestions (creating, modifying, and deleting).
  >
  >Previously, no diff was recorded (although some information was recorded in the Info column).
- [42032](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42032) Add diff support to AUTHORITIES action logs
  >This enhancement adds a 'diff' to the action logs for authority record changes (creating, modifying, and deleting).
  >
  >Previously, no diff was recorded (although some information was recorded in the Info column).

### Web services

#### Enhancements

- [37713](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37713) OAI-PMH - Honour OpacSuppression syspref
## Bugfixes
This list includes all bugfixes since the previous major version. Most of them
have already been fixed in maintenance releases


#### Security bugs

- [34000](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34000) Don't allow auto-generated cardnumbers to be re-used, it may give access of services to the next patron created (26.05.00, 25.11.04, 25.05.10, 24.11.15, 22.11.37)
- [38414](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38414) Reports permissions not properly enforced
- [42136](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42136) User-entered Template::Toolkit allows information disclosure (26.05.00, 24.11.15)
- [42252](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42252) Stored XSS when deleting a list or removing a list share (26.05.00, 24.11.15)
- [42253](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42253) Stored XSS in advanced editor in Macro name (26.05.00, 24.11.15)
- [42254](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42254) DOM XSS via tag search (26.05.00, 24.11.15)
- [42366](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42366) debug_mode 0 and debug_mode 1 enable debug mode (26.05.00)

#### Critical bugs fixed

- [41546](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41546) Cannot unarchive suggestions (26.05.00,25.11.02)
  >This restores the 'Unarchive' action for archived suggestions.
  >
  >To restore an archived suggestion:
  >1. Go to Acquisitions > Suggestions
  >2. To show archived suggestions:
  >   2.1 From the sidebar 'Filter by section', select 
  >       'Include archived'
  >   2.2 Click the 'Go' button in the 'Organize by section'
  >3. For an archived suggestion ('Archived' shown under the 
  >   suggestion title):
  >   3.1 Select the dropdown list by the 'Edit' button
  >       on the far right
  >   3.2 Select the 'Unarchive' action.
- [41591](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41591) XSS vulnerability via file upload function for invoices (26.05.00,25.11.02,25.05.08,24.11.13,22.11.35)
- [41848](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41848) Typo in parcel.tt prevents receiving (26.05.00)
- [42010](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42010) Include escaping when using PO numbers in EDI acquisitions (26.05.00,25.11.05)
- [38384](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38384) General fix for plugins breaking database transactions (26.05.00,25.11.04)
- [40989](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40989) t/db_dependent/OAI/Server.t fails on Debian 13 (26.05.00,25.11.01)
  >This fixes OAI-PMH (tests and request) so that OAI-PMH responses work when Debian 13 (Trixie) is used as the operating system. Trailing slashes are stripped from requestURL for CGI.pm 4.68+ compatibility
  >
  >Technical details:
  >
  >CGI.pm 4.68 (shipped with Debian 13/Trixie) changed the behaviour of
  >self_url() to include a trailing slash when there's no path component.
  >
  >This strips the trailing slash from both the requestURL field in OAI responses and the baseURL field in Identify responses to maintain compatibility across CGI.pm versions.
- [41327](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41327) `yarn css:build` generates several warnings (26.05.00,25.11.02)

  **Sponsored by** *Athens County Public Libraries*
- [41329](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41329) yarn install generates 2 warnings regarding datatables-.net-vue3 (26.05.00,25.11.02)
- [41617](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41617) CSV export from item search results - incorrect spaces after comma separator causes issues (26.05.00,25.11.03,25.05.09)
  >This fixes the CSV export from item search results in the staff interface (Search > Item search> Export select results (X) to CSV).
  >
  >It removes extra spaces after the comma separator, which causes issues when using the CSV file with some applications (such as Microsoft Excel).
- [41857](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41857) Suggestions table actions broken (Update manager and Delete selected) (26.05.00,25.11.04)
  >This fixes errors that are generated when selecting a suggestion in the staff interface and:
  >- Updating the manager for the suggestion (Update manager > [select manager] > Submit)
  >- Deleting the suggestion (Delete selected > Submit)
  >
  >(Related to changes made by Bug 39721 - Remove GetSuggestion from C4/Suggestions.pm, added in Koha 26.05.)
- [42068](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42068) Update on bug 26993 breaks items deletions with a corrupted foreign key (26.05.00)
- [42071](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42071) Suggestion does not load when viewing the suggestion (26.05.00,25.11.04,25.05.11)
  >This fixes suggestion details not showing when you click the title in the staff interface suggestions management table.
  >
  >(Related to changes made by Bug 41857 - Suggestions table actions broken (Update manager and Delete selected), added in Koha 26.05.)
- [42098](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42098) EDIFACT edi_cron.pl runs disabled plugins due to bug in Koha::Plugins::Handler::run (26.05.00,25.11.04,25.05.11)
  >Closes a loophole in our plugin handler that meant that some plugin methods may have run even when the plugin was marked as disabled.
- [42353](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42353) Tell which version of node to use (26.05.00)
- [42394](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42394) Session_id lost when a job is enqueued (26.05.00,25.11.05)
- [41481](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41481) XML validation error when launching the tag editor for MARC21 fields 006/008 (26.05.00,25.11.02,25.05.09)
  >This fixes an XML validation error ("Can't validate the xml data from (...)/marc21_field_00{6,8}.xml") when using the tag editor for MARC21 fields 006/008. The tag editor now works as expected for these fields.
- [42606](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42606) Error when importing a record using Z39.50 from the cataloging home page
  >26.05.00
- [39584](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39584) Booking post-processing time cuts into circulation period (26.05.00,25.11.02)
- [39748](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39748) Daylight savings breaks circulation (when DST change eliminates 00:00 to 00:59) (26.05.00,25.11.05)
  >This change fixes a timezone-related issue that occurs when checking patron expiry dates in certain timezones (e.g. Africa/Cairo) where the daylight savings time change erases midnight from that day. 
  >
  >While it is a rare problem, it can cause errors accessing patron details and check out pages in the staff interface for those Koha instances affected.
- [28528](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28528) bulkmarcimport delete option doesn't delete biblio_metadata (26.05.00,25.11.04)

  **Sponsored by** *Ignatianum University in Cracow*
- [41315](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41315) Using patron-homelibrary option for overdue notices may not send notices to all branches (26.05.00,25.11.03)
- [41353](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41353) koha-dump failing on mysqldump PROCESS privileges (26.05.00,25.11.05)
  >For those using the MySQL database. Starting from MySQL 5.7.31 and MySQL 8.0.20, mysqldump requires the PROCESS privilege to access tablespace metadata by default. Without this privilege, backup operations fail with permission errors.
  >
  >This fixes this issue by adding the --no-tablespaces flag to the dbflag variable. This prevents mysqldump from attempting to access tablespace metadata, allowing backups to complete successfully without requiring the PROCESS privilege.
- [39107](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39107) kohastructure.sql doesn't load on new MySQL versions (26.05.00,25.11.05)
  >This fixes a database error that occurred when starting up a new Koha instance with MySQL version 8.4 or higher.
- [41421](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41421) Bug 35830 DB update must be idempotent
  >25.11.00,25.05.06,24.11.11,24.05.16,22.11.33
- [41460](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41460) On Mysql on upgrade from 25.05 to 25.11 I got the error TEXT column 'value' can't have a default value (26.05.00,25.11.05)
- [41520](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41520) Using additional fields on ERM agreements results in an error when loading the agreements table (26.05.00,25.11.02)
  >This fixes the ERM agreements table, when additional fields are added for agreements.
  >
  >When loading the ERM agreements table, a 500 error was generated:
  >
  >   Something went wrong when loading the table.
  >   500: Internal Server Error
  >   Properties not allowed: record_table.
  >   Properties not allowed: record_table.
  >   Properties not allowed: record_table.
- [29923](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29923) Do not generate overpayment refund from writeoff of fine (26.05.00,25.11.04,25.05.11)
- [41761](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41761) Updating accountlines note sets accountlines.date to current date (26.05.00,25.11.04)
- [41781](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41781) Holds queue builder ( build_holds_queue.pl ) fails if HoldsQueueParallelLoopsCount is greater than 1 (26.05.00,25.11.03)
- [41959](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41959) Holds queue builder doesn't always check all holds when using transport cost matrix (26.05.00,25.11.05)
- [41337](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41337) koha-create --request-db and --populate-db creates log files owned by root (intranet-error.log, opac-error.log) (26.05.00,25.11.04)
  >This fixes the UNIX user/group ownership of the log files `intranet-error.log` and `opac-error.log` inside `/var/log/koha/<instance>/`.
  >Previously, running `koha-create --request-db` followed by `koha-create --populate-db` would result in the two log files being owned by root/root.
  >The correct ownership is now applied, meaning the log files will be owned by the <instance>-koha/<instance>-koha UNIX user/group.
- [42301](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42301) updatedatabase fails on mysql when adding a unique key to a text column (introduced by 35380) (26.05.00,25.11.05)
- [42318](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42318) Table record_sources is not populated with data on install (26.05.00,25.11.05)
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
- [42374](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42374) DB Upgrade from the UI is broken (26.05.00,25.11.05)
- [42412](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42412) Upgrade to 25.11.02.004 using MySQL fails with Exception: Incorrect DATE value:  value: '0000-00-00' (26.05.00,25.11.05)
- [41662](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41662) CSRF-vulnerability in opac-patron-consent.pl. (26.05.00,25.05.07,25.11.01,24.11.12)
- [42545](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42545) Koha::Calendar::days_between skips holiday subtraction for end date if time is early (26.05.00,25.11.05)
- [41045](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41045) Suggestions manage permissions added to patrons who previously had no permissions in that category (26.05.00,25.11.05)
- [41145](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41145) Logging patron attributes logs even if there's no changes (26.05.00,25.11.01)
  >This prevents misleading patron attribute modification logs, when a library batch imports patrons with the BorrowersLog system preference set to 'Log'. It now correctly only shows a log entry when a patron attribute value is changed.
  >
  >Example: 
  >- Before the change: for an existing patron with a patron attribute of INSTID:1234, with a re-import the log shows { "attribute.INSTID" : { "after" : "1234", "before" : "" } }, even though there is no change to the patron attribute.
  >- After the change: 
  >  . No log entry is shown if there is no change to the patron attribute.
  >  . If there is a change to the patron attribute (for example, changed to 5678 on a re-import), it is now correctly shown - { "attribute.INSTID" : { "after" : "5678", "before" : "1234" } }

  **Sponsored by** *Auckland University of Technology*
- [42423](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42423) Submit button in patron search from header never submits (26.05.00,25.11.04,25.05.10)
  >This fixes the patron search in the staff interface header. 
  >
  >If the search you enter didn't show any autocomplete results, clicking the arrow to search didn't do anything.
  >
  >Now, it will use the search you entered and show any results.
- [41603](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41603) Plugin hook causing DB locks when cancelling holds (26.05.00,25.11.02)
- [41684](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41684) notices_content hook is not checking if individual plugins are enabled and is reloading plugins (26.05.00,25.11.03)
- [35380](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35380) PUT /biblios/:biblio_id doesn't apply record overlay rules (26.05.00,25.11.05)
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
- [41614](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41614) additional_contents REST endpoint broke the display location filter (26.05.00,25.11.05)
  >This fixes a regression that resulted in an empty list in the "Display location" filter in the sidebar for Tools > Additional tools > HTML customizations. Only All, OPAC, and Staff Interface options were shown in the dropdown list, instead of the full list of display locations.
  >
  >(Regression caused by Bug 39900 - Add public REST endpoint for additional_contents, in Koha 25.11 and 25.05.)
- [42053](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42053) Bug 37893 DBUpdate does not always add the new userflags/permissions (26.05.00,25.11.05)
  >This patch adds the 'sip2' user flag to systems on which it does not exist. This flag was introduced in Bug 37893 but due to an error in the upgrade script it was not added to systems without existing SIP configuration.
- [42547](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42547) SIP performance is terrible if sip2_resource_last_modified is missing from memcached (26.05.00,25.11.05)
- [40966](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40966) 'whole_record' and 'weighted_fields' not passed around (26.05.00,25.11.03)
- [41646](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41646) Self-checkin displaying too much whitespace due to incorrect HTML (26.05.00,25.11.02)
  >This removes a large section of white space between the page header and the actual form on the OPAC self check-in page, which was positioned near the bottom of the page.
- [41593](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41593) [CVE-2026-31844] Authenticated SQL Injection in staff side suggestions (26.05.00,25.11.01,25.05.07,24.11.12)
- [41798](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41798) Cannot enable 'passive' mode in File Transports for FTP (26.05.00,25.11.03)
- [42048](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42048) Reflected XSS in patron search saved link
  >26.05.00, 25.11.03, 25.05.09
- [42521](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42521) Cannot login from suggestion.pl (26.05.00,25.11.05)
- [39482](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39482) Link to edit OpacLibraryInfo from library edit page broken (26.05.00,25.11.01)
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
- [41261](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41261) XSS vulnerability in opac/unAPI (26.05.00, 25.11.03,25.05.09, 24.11.14, 22.11.36)
  >This change validates the inputs to "unapi" so that any invalid inputs will result in a 400 error or a response containing valid options for follow-up requests.
- [41431](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41431) Circulation rule notes dropping when editing rule (26.05.00,25.11.03,25.05.09,24.11.16)
  >This fixes editing circulation and fine rules with notes - notes are now correctly shown when editing, and are not lost when saving the rule.
  >
  >Previously, if you edited a rule with a note, it was not displayed in the edit field and was removed when the rule was saved.

  **Sponsored by** *Koha-Suomi Oy*
- [41216](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41216) Resurrect tt_valid.t (26.05.00,25.11.05)
- [41682](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41682) Syspref discrepancies between new and upgraded installs (26.05.00,25.11.03)
  >This fixes several system preferences discrepancies and adds tests, including:
  >
  >* Setting options to NULL when options=""
  >* Fixing the explanation when different
  >* Fixing the wrong order (some rows had options=explanation)
  >* Fixing the wrong type "Yes/No" => "YesNo"
  >* Removed StaffLoginBranchBasedOnIP: both StaffLoginLibraryBasedOnIP and StaffLoginBranchBasedOnIP are in the database for upgraded installs
  >* Adding a description for ApiKeyLog
  >* Fixing 'integer' vs. 'Integer' inconsistency
  >* Fixing 'cancelation' typo
  >* Improving the tests:
  >  * Compare sysprefs.sql and the database content for options, explanation and type
  >  * Catch type not defined
  >  * Catch incorrect YesNo values (must be 0 or 1)
  >
  >An example where discrepancies have crept in during upgrades includes warnings in the About Koha > System information - the system preferences had no value (either 1 or 0) in the 'value' field:
  >* Warning System preference 'ILLHistoryCheck' must be '0' or '1', but is ''.
  >* Warning System preference 'ILLOpacUnauthenticatedRequest' must be '0' or '1', but is ''.
  >* Warning System preference 'SeparateHoldingsByGroup' must be '0' or '1', but is ''.
- [41438](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41438) Batch hold tool: Suspended holds are unsuspended when making other changes to holds (26.05.00,25.11.02)

  **Sponsored by** *Koha-Suomi Oy*
- [41882](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41882) Batch hold modification tool updates pickup locations to disallowed libraries (26.05.00,25.11.05)
  >This fixes a problem with the batch hold modification tool that was allowing for holds to be batch updated to pickup location that are not valid.

#### Other bugs fixed

- [41102](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41102) Error 500 on the "About" page when biblioserver Zebra configuration is missing (26.05.00,25.11.02)
  >This fixes the About Koha page when Zebra is not running or not correctly configured in the Koha instance's koha-conf.xml file. Instead of a 500 error when you access the page, there is now a message in the server information tab for Zebra's status, such as "Zebra server seems not to be available. Is it started?".
- [41317](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41317) Release team 26.05 (26.05.00,22.11.34)
  >Updates changes to the 25.11 release team, and adds the details of people in the 26.05 release team. (More > About Koha > Koha team.)
- [40726](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40726) Clicking off of a dropdown in the user menu branch switching closes the dropdown (26.05.00,25.11.02)
- [41933](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41933) Course reserves OPAC DataTables search field missing accessible label (26.05.00,25.11.05)
- [41934](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41934) Empty table header in course reserves table causes accessibility error (26.05.00,25.11.05)
  >This fixes an accessibility issue with the course reserves table in the OPAC (OPAC > Course reserves): "Table header text should not be empty".
  >
  >Previously when responsive table controls were shown for the list of course reserves (a green "+" button is shown when the browser window is narrower and all the columns can't be displayed), there was no title for the column header with the controls.
  >
  >Now, the column header has the text "Expand" when the responsive controls are shown.
- [42142](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42142) The gear icon to toggle panel for login settings needs accessibility updates (26.05.00,25.11.05)
- [42143](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42143) The breadcrumbs on Patron pages render an empty link (26.05.00,25.11.05)
  >This patch improves accessibility for screen readers by removing a duplicate empty link that was rendered in the breadcrumbs on patron pages.
- [42149](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42149) The main navigation needs an aria-label (26.05.00,25.11.05)
- [42236](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42236) OPAC lists table header contains no text (26.05.00,25.11.05)
- [42300](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42300) OPAC detail page: authority links have no text (26.05.00,25.11.05)
  >This fixes an accessibility issue on OPAC details pages for magnifying glass icon links to authority records: "Links must have discernible text".
  >
  >The magnifying glass icon links now have a title and aria label "View authority record".
- [42448](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42448) Staff Interface News (newsfooter) text does not have sufficient color contrast (26.05.00,25.11.05)

  **Sponsored by** *Athens County Public Libraries*
- [39514](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39514) If one basket has uncertain prices, all baskets are displayed in red (26.05.00,25.11.01)
  >This fixes the display of baskets in acquisitions so that only baskets with uncertain prices are shown in red. Previously, if one basket had an uncertain price, all the baskets in the page were shown in red, even those without uncertain prices, making it hard to know where to go to fix the price.
- [41420](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41420) Syntax error in referrer in parcel.tt (26.05.00,25.11.03,25.05.09,24.11.16)
  >This fixes the URL for the "Cancel order and catalog record" link when receiving an order for an invoice - the referrer section of the URL was missing.
- [41783](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41783) Query parameters for suggestions filtering is not encoded (26.05.00,25.11.05)
  >This fixes searching for suggestions using the "Bibliographic information" filter on the acquisitions page in the staff interface (Acquisitions > Suggestions).
  >
  >Searching was not working as expected in some situations. For example, searching for a title of an existing suggestion did not return any results.
- [41997](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41997) Default suggester is not passed by the suggestion creation form (26.05.00,25.11.05)
- [41999](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41999) Suggestions table in staff interface no longer searches all data following title in Suggestion column (26.05.00,25.11.05)
  >This fixes the search filter for the suggestions tables in the staff interface. The search filter now searches all suggestion column data, not just the title.
- [42312](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42312) Must enter all four lines of physical address when editing a vendor (26.05.00,25.11.05)
- [42603](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42603) Cannot 'receive selected' because of typo in variable name (26.05.00)
  >This fixes receiving orders using the "Receive selected (X)" button. It now works as expected - before this, the button did nothing, and you couldn't complete receiving the order.
- [27115](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27115) Restarting koha-common fails to restart SIP2 server (26.05.00,25.11.02)
  >This fixes an issue when stopping and restarting SIP servers using `koha-sip` - it would sometimes not restart the SIP servers.
  >
  >This was because a restart could attempt the --start command while a previous SIP server was still running. This could result in the SIP server not restarting at all.
  >
  >The fix replaces `daemon --stop` with `start-stop-daemon --stop` in the code, to ensure that all the running SIP servers are actually stopped before restarting.
- [30261](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30261) opac/tracklinks.pl renders 404 incorrectly (26.05.00,25.11.05)
- [30803](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30803) output_error should not assume a 404 status (26.05.00,25.11.04)
  >This change fixes the output_error function so that it requires a numeric input.
- [35423](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35423) AuthoritiesMarc: Warnings substr outside of string and Use of uninitialized value $type in string eq (26.05.00,25.11.03)
- [41036](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41036) Koha::ImportBatch is not logging errors (26.05.00,25.11.04)
- [41043](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41043) Use op 'add_form' and 'edit_form' instead of 'add' and 'edit' (26.05.00,25.11.03)
- [41076](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41076) Perltidy config needs to be refined to not cause changes with perltidy 20250105 (26.05.00,25.11.03)
- [41142](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41142) Update jQuery-validate plugin to 1.21.0 (26.05.00,25.11.02,25.05.09,24.11.14)

  **Sponsored by** *Athens County Public Libraries*
- [41238](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41238) Pseudonymize statistic jobs don't update progress (26.05.00,25.11.01)
  >This fixes the progress shown for pseudonymize statistics background jobs. The progress was shown in the list of jobs (Administration > Jobs > Manage jobs) as "0/1" instead of "1/1", even though the background job was finished.
- [41268](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41268) Circulation rules script has many  conditionals (26.05.00,25.11.03)
- [41287](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41287) Using locale sorting may have a negative impact on search speeds (26.05.00,25.11.03)
  >This improves the performance for showing facets when using Elasticsearch, by adding another option "simple alphabetical" to sort facets to the FacetOrder system preference.
  >
  >This improves performance for English language libraries and will display the facets correctly in most cases, unless there are Unicode characters.
  >
  >(Technical note: 'stringwise' is basic alphanumeric sorting character by character - diacritics are largely ignored.)
- [41404](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41404) No need to check related guarantor/guarantee charges when the limits are not set (26.05.00,25.11.01)
- [41454](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41454) Remove unused dbh calls (26.05.00,25.11.05)
- [41521](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41521) WebService::ILS::OverDrive not passing pl_valid (26.05.00,25.11.05)
  >Embedding WebService::ILS::OverDrive into Koha to fix several perl validation errors.
  >The author of the module is not reachable on CPAN.
  >This can be reverted once upstream has been fixed.
- [41523](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41523) Bug 41409 update statement is not accurate (26.05.00,25.11.02)
- [41545](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41545) JS warning "redeclaration of let filters_options" (26.05.00,25.11.02)
- [41557](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41557) LoginFirstname, LoginSurname and emailaddress sent to template but never used (26.05.00,25.11.03)
- [41560](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41560) Useless (and confusing) id attribute on a couple of script tag (26.05.00,25.11.03)
  >Removes the id attribute from the script tag  for two pages in the staff interface, as they are not needed.
  >
  >The two pages changed:
  >- 'Checkout history' section for a record
  >- 'Circulation history' for a patron
- [41561](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41561) "tab" variable in admin/aqbudgetperiods.pl,tt is not used and should be removed (26.05.00,25.11.03)
- [41587](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41587) node audit identified several vulnerable node dependencies (26.05.00,25.11.04)
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
- [41599](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41599) reports/acquisitions_stats.pl calls output_error incorrectly (26.05.00,25.11.04)
  >Fixes acquisitions_stats.pl so it returns a 403 code if a user tries to send a malicious payload.
- [41653](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41653) Stores for permissions and sysprefs should be under the Koha namespace (26.05.00)
- [41701](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41701) Fix definition of OAI-PMH:DeletedRecord preference in sysprefs.sql (26.05.00,25.11.03)

  **Sponsored by** *Athens County Public Libraries*
- [41747](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41747) xt/js_tidy is failing on ill js files
- [41837](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41837) Are we ready for rc1? (26.05.00)
  >This removes unused code (a hard-coded path in templates) that is no longer used in Koha (it was added pre-2007 for a release candidate).
- [41864](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41864) (Bug 40966 follow-up) Simple OPAC search generates warnings: Odd number of elements in anonymous hash (26.05.00,25.11.04)

  **Sponsored by** *Ignatianum University in Cracow*
- [41916](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41916) SIP2 module cypress tests failing
  >26.05.00
- [42085](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42085) Permissions should be logged when a patron is deleted (26.05.00)
  >The log viewer now (with dependent changes) shows the details for a deleted borrower in the info and diff columns - including the permissions they had before the patron account was deleted. Previously, no details were recorded - just that a patron with their borrower number was deleted.
  >
  >This may be helpful for auditing purposes (for example, a previous employee's account was decommissioned, and they had XYZ permissions at the time).
- [42163](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42163) wrapper-staff-tool-plugin.inc no longer loads the admin menu (26.05.00,25.11.05)
  >This fixes the sidebar menus when using plugins. The appropriate sidebar menu is now shown, depending on the type of plugin (such as administration, tools, or reports). Previously, no sidebar menu was appearing in some circumstances.
- [42175](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42175) Running under Mojo is broken in k.t.d (26.05.00,25.11.05)
- [42317](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42317) [CVE-2014-1626] Require MARC::File::XML > 1.0.2 (26.05.00,25.11.05)
  >This updates the CPAN file to reflect the minimum version
  >needed for the MARC::File::XML Perl module. This is important
  >because of the vulnerabilities in version 1.0.1.
  >
  >(Note: This should not cause any issues, as v1.0.5 is available and already used from Debian repositories for installation.)
- [42356](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42356) New yarn build warning: if() syntax is deprecated (26.05.00,25.11.05)

  **Sponsored by** *Athens County Public Libraries*
- [42463](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42463) Deleting a SMS provider should use text() rather than html() (26.05.00,25.11.05)
- [42637](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42637) Check if biblio exists before checking if it is a fast add framework (26.05.00)
  >This fixes a regression from Bug 32773 - Have the ability to have more than 1 Fast Add framework, added to Koha 26.05.
  >
  >If you tried to access a record that doesn't exist, you got a 500 error "Can't call method "frameworkcode" on an undefined value at /kohadevbox/koha/catalogue/detail.pl line 94".
  >
  >With this fix, you now get a message saying "The record you requested does not exist (XXXXXX)." (where XXXX is the biblionumber you were trying to access).
- [33782](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33782) OAuth2/OIDC identity providers code is not covered by unit tests (26.05.00,25.11.03)
- [42222](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42222) Use of uninitialized string in string eq in Auth.pm (26.05.00,25.11.05)
- [31717](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31717) Value builder unimarc_field_010.pl should also use 214$c (26.05.00,25.11.05)
  >This updates the unimarc_field_010.pl value builder for UNIMARC systems. If the value builder finds a publisher from the ISBN entered in 010$a, it now automatically adds the publisher name to the 214$c (only the 214$c is updated if there is also a 210$c, as the 214$c is now the more important field with the bibliographic transition.).
- [34879](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34879) ./catalogue/getitem-ajax.pl appears to be unused (26.05.00,25.11.03,25.05.09)
- [40306](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40306) Use GET in form of value_builder/unimarc_field_4XX.pl (26.05.00,25.11.04)
  >This fixes searching for terms when using the unimarc_field_4XX.pl value builder. The 'Start search' button now works, instead of doing nothing. (UNIMARC instances.) (This is related to the CSRF changes added in Koha 24.05 to improve form security.)
- [40711](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40711) Fix value builder for 181 in UNIMARC (26.05.00,25.11.04)
  >Fixes the value builder for UNIMARC 181$c and 181$2:
  >- 181$c: now inserts the correct codes from the dropdown list (previously, it would populate the field with incorrect values - choosing cri would not add a value, crm would insert an a as the value)
  >- 181$2: now uses the correct HTML body ID (previously it was cat_unimarc_field_182-2, now it is cat_unimarc_field_181-2)
- [40777](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40777) 500 Error: Something went wrong when loading the table Should Exit Cleanly (26.05.00,25.11.02)
  >This adds an "Audit" option on the toolbar for records in the staff interface. This implements the check for missing home and current library data (952$a and 952$b fields).
  >
  >If a record has data inconsistencies, then using the audit option is shown on the error message that is shown when accessing the record details page:
  >
  >        Something went wrong when loading the table.
  >        500: Internal server error
  >        Have a look at the "Audit" button in the toolbar
- [41047](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41047) Current library and home library sort by code instead of description (26.05.00,25.11.02)
  >This patch fixes a problem where holdings were not sorting correctly by the branchname. With this patch the 'Current library' and 'Home library' columns now sort correctly on the description/library name instead of on the branchcode.
- [41081](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41081) Link from 856$u points to http://%20%20%20%20 (26.05.00,25.11.02)
  >If a 856$u for a record has just spaces instead of a URL, an invalid link was shown on the record page for the OPAC and staff interface (under 'Online resources').
  >
  >Example: a record with four spaces added "Online resources" information to a record's page, with an invalid link to http://%20%20%20%20
- [41367](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41367) Staff user interface - no sidebar menu when on record sources pages (26.05.00,25.11.05)
  >This adds the missing sidebar menu when using Administration > Catalog > Record sources.

  **Sponsored by** *OpenFifth*
- [41417](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41417) 500 error when creating new authorized values from additem.pl (26.05.00,25.11.04,25.05.11)
- [41475](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41475) 500 error when placing a hold on records with multiple 773 entries (26.05.00,25.11.03,25.05.09,24.11.16)
- [41588](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41588) Link from 856$u breaks with leading or trailing spaces (26.05.00,25.11.03,25.05.09)
  >If a 856$u for a record had spaces before or after the URL, the link shown on the record page on the OPAC and staff interface (under 'Online resources') did not work.
  >
  >Depending on the browser, either nothing happened, or an error was shown that the site wasn't reachable.
  >
  >Examples that previously caused links not to work (without the quotes):
  >- " koha-community.org"
  >- "koha-community.org "
  >- " koha-community.org "
- [42072](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42072) Batch item deletion "Delete records" message is confusing (26.05.00,25.11.05)
  >This change clarifies the option to delete bibliographic records if no items remain in the Batch Item Deletion cataloguing tool.
- [42176](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42176) Form to create an authorized value is submitted when cancelled (26.05.00,25.11.05)

  **Sponsored by** *Lund University Library*
- [42177](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42177) Cannot manage bundles (26.05.00)

  **Sponsored by** *Lund University Library*
- [42221](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42221) autoBarcode set to incremental EAN-13 barcodes do not increment (26.05.00,25.11.05)
- [42262](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42262) MARC 006 tag editor plugin drops blank value in position 17 when editing existing tag (26.05.00,25.11.05)
- [42424](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42424) Javascript error prevents saving when an instance of an 'important' or 'required' subfield is deleted (26.05.00,25.11.05)
- [15792](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15792) Double-clicking the 'renew' button on circulation.pl will double-charge account management fee (26.05.00,25.11.05)
  >This fixes patron renewal from the patron check out or details page, so that you can't double-click the "Renew" link, and get double-charged the enrollment fee (where an enrollment fee is this is set for the patron category).
  >
  >It also changes the "Renew" link from a text link to a standard light-grey action button.
- [21941](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21941) Incorrect GROUP BY in circ/reserveratios.pl (26.05.00,25.11.05)

  **Sponsored by** *Lund University Library*
- [39916](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39916) The 'Place booking' modal should have cypress tests (26.05.00,25.11.02)
- [40134](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40134) Fix and optimise 'Any item' functionality of bookings (26.05.00,25.11.03)
- [40949](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40949) Bookings to collect shouldn't tell staff to check in items (26.05.00,25.11.01)
  >This removes the sentence "Please retrieve them and check them in." from the bookings to collect page (Circulation > Holds and bookings > Bookings to collect). This is not required, as checking in items is not relevant for bookings.
- [41035](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41035) bundle_remove click handler in returns.tt has invalid path component "item" (26.05.00,25.11.03)
- [41055](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41055) Missing accesskey attribute for print button (shortcut P) (26.05.00,25.11.03,25.05.09,24.11.16)

  **Sponsored by** *Koha-Suomi Oy*
- [41058](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41058) Using Show Checkouts button when LoadCheckoutsTableDelay is set causes collision/error. loadIssuesTableDelayTimeoutId  not assigned (26.05.00,25.11.04)
  >This fixes an error message when viewing the checkouts table for patrons, under the patron's check out section in the staff interface, where:
  >- the LoadCheckoutsTableDelay system preference is set (greater than zero)
  >- "Always show checkouts automatically" is selected
  >
  >Clicking "Show checkouts" when "Checkouts table will show automatically in X seconds..." is shown resulted in a pop-error message, after the table with the list of checkouts was shown:
  >  Something went wrong when loading the table
  >  200: OK.
- [41131](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41131) Libaray transfer limits basic editor allows one to prevent transfers from a library to itself and block related holds (26.05.00,25.11.04)
- [41343](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41343) Overdue report is too intensive on systems with many overdues (26.05.00,25.11.05)
- [41345](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41345) Regression: Clicking the 'Ignore' button on hold found modal for already-waiting hold does not dismiss the modal (again) (26.05.00,25.11.01,25.05.09)
  >This fixes a regression when checking in an item. Clicking the "Ignore" option in the dialog box, when an item already has a waiting status, just reloaded the dialog box. Clicking the "Ignore" option now closes the dialog box and works as expected.
- [41352](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41352) Bookings to Collect Help does not take you to the correct place in the manual (26.05.00,25.11.01)
  >This fixes the link to the help for the Circulation > Holds and bookings > Bookings to collect page - it now links to the correct place in the documentation, instead of the documentation home page.
- [41451](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41451) Hold history search fails when itemtype column present (26.05.00,25.11.01)
  >This fixes filtering on a patron's holds history when AllowHoldItemTypeSelection is enabled. This previously produced a 500 error when searching, but now works as expected.
- [41456](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41456) Item type filter on the hold history view does not work correctly (26.05.00,25.11.01)
  >This fixes the patron's holds history table in the staff interface. The search filter now works as expected - using the library name or library code and requested item type name or item type code (when AllowHoldItemTypeSelection is enabled) now work as expected, and the column filters for both of these now use dropdown lists.
- [41457](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41457) Hold history table does not deal with column visibility correctly (26.05.00,25.11.03)
- [41510](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41510) Fallback on bookable itemtype can break if item has no itemtype (26.05.00,25.11.05)
  >Catches the unlikely case of there not being an itemtype associated with item or bib for bookings.
- [41518](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41518) "Scheduled for automatic renewal" displays even if patron does not allow automatic renewals (26.05.00,25.11.04,25.05.11)
  >This change makes the "Scheduled for automatic renewal" text only appear in the renew column of checkouts table in the staff interface and OPAC when the item will actually be considered for automatic renewal.
  >
  >The text was showing, even if the item would not automatically be renewed due to automatic renewals being disallowed at the patron level.
  >
  >This now matches the criteria that misc/cronjobs/automatic_renewals.pl uses for processing automatic renewals.
- [41788](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41788) Make running the holds queue on click optional (26.05.00,25.11.05)
  >This patch adds a system preference 'UseHoldsQueueFilterOptions'. When it is enabled it prevents the direct running of the holds queue by clicking on the 'Holds queue' links. With it enabled it will present the user with filter options before running the holds queue. This is to prevent excessive running of the holds queue which can cause slowdowns on larger systems.
- [41886](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41886) Biblio::check_booking counts checkouts on non-bookable items causing false clashes (26.05.00,25.11.04,25.05.11)

  **Sponsored by** *Büchereizentrale Schleswig-Holstein*
- [41887](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41887) Booking::store runs clash detection on terminal status transition causing 500 on checkout (26.05.00,25.11.04)

  **Sponsored by** *Büchereizentrale Schleswig-Holstein*
- [41938](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41938) Argument "" isn't numeric in numeric gt (>) ... warnings in circulation.tt (26.05.00,25.11.05)

  **Sponsored by** *Ignatianum University in Cracow*
- [41940](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41940) Use of uninitialized value... warnings in circulation.pl (26.05.00,25.11.05)

  **Sponsored by** *Ignatianum University in Cracow*
- [41977](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41977) Hold fee not charged for title-level holds when all items have negative notforloan status (26.05.00)

  **Sponsored by** *OpenFifth*
- [42062](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42062) Patron column missing from checkout history on biblio record (26.05.00)
- [32736](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32736) koha-worker should be able to restart all queues with a single call (26.05.00)
  >Adds an --all-queues option to the koha-worker package command. This lets you perform actions (such as start, stop, restart, and status) on all defined queues (currently only 'default' and 'long_tasks') with one command.
- [40744](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40744) Don't give noisy warning when PatronSelfRegistration is turned off (26.05.00,25.11.05)
  >When PatronSelfRegistration is set to ignore (i.e. do nothing) if --del-exp-selfreg is passed to cleanup_database.pl we were issuing warnings.  This patch removes those.
- [41097](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41097) Deduping authorities script (dedup_authorities.pl) can die on duplicated ids (26.05.00,25.11.04)
  >This fixes the deduping authorities maintenance script (misc/maintenance/dedup_authorities.pl) so that it now works and displays the output from the merging of authority records as expected. 
  >
  >Previously, it seemed to generate duplicate IDs, for example:
  >
  >Before
  >------
  >
  >Processing authority 1660 (531/650 81.69%)
  >    Merging 1660,1662 into 1660.
  >    Updated 0 biblios
  >    Deleting 1662
  >    Merge done.
  >
  >After
  >-----
  >
  >Processing authority 1660 (532/650 81.85%)
  >    Merging 1662 into 1660.
  >    Updated 0 biblios
  >    Deleting 1662
  >    Merge done.
- [41316](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41316) Using patron-homelibrary option for overdue notices does not change which rules are used (26.05.00,25.11.04)
- [41967](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41967) cleanup_database.pl ignores integer values for --labels and --cards and defaults to 1 day (26.05.00,25.11.05)
  >This fixes a bug in the cleanup_database.pl script to delete label batches and patron card batches older than X days. Before this fix, if the --labels  or --cards argument was passed in the cronjob, all batches older than 1 day were deleted, regardless of the value passed in the argument.
- [42273](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42273) 'idenfity' typo in `categories` table (26.05.00,25.11.05)
  >Fixes the spelling in the database comment for the categorycode field (in the categories table): 'idenfity' to 'identify'.
- [41120](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41120) Click on New data provider breaks functionality (26.05.00,25.11.03)
  >This fixes adding a new data provider after creating a new data provider (ERM > eUsage > Data providers > New data provider).
  >
  >If you created a new data provider, clicked close after the information about the provider was shown, then went to add another new data provider - nothing happened: you got an empty page, and there was an error in the browser developer tools console.
- [41173](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41173) ERM breadcrumb link causes page reload (26.05.00)
  >This fixes an issue with the breadcrumb links in the ERM module. The ERM landing page with the dashboard now loads correctly. (This is related to bug 39320 - Create a 'landing page' for ERM.)
- [41615](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41615) ERM Dashboard breaks Licenses cypress tests (26.05.00)
- [41386](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41386) Adding 0.00 as value for "Expired hold charge" in circulation rules can lead to exception Koha::Exceptions::Account::AmountNotPositive (26.05.00,25.11.05)
  >Using value 0.00 in "Expired hold charge" rule on circulation rules caused Koha to die with exception Koha::Exceptions::Account::AmountNotPositive when expired hold charge was added for patron. This was caused by error in if statement in method Koha::Hold->cancel which allowed value 0.00 to be passed to method add_debit. This method then raised exception since value 0.00 is not positive. This patch fixes the erroneous if statement in method Koha::Hold->cancel.

  **Sponsored by** *Koha-Suomi Oy*
- [42466](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42466) UseCashRegisters gets ignored on paycollect when change > 0 (26.05.00)
- [41267](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41267) It should be possible to prevent some itemtypes from filling other biblio level holds (26.05.00,25.11.05)
- [41335](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41335) Toggling the hold options does not always work in opac-reserve (26.05.00,25.11.05)
  >When DisplayMultiItemHolds is enabled, item selection for specific     items is done via checkboxes; no item is preselected unless there is only one. Otherwise an item is selected via radio buttons. The first one is preselected.
- [41416](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41416) Poor performance when clicking 'Update hold(s)' on request.pl for records with many holds (26.05.00,25.11.02)
- [41432](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41432) Add prefetch to improve performance of holds page (26.05.00,25.11.01)
  >This improves the performance of the holds request page for a record in the staff interface.
- [41801](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41801) FixPriority recursive calls for lowestPriority holds can be removed (26.05.00,25.11.05)
  >This performance update optimizes the C4::Reserves->FixPriority function. Previously, when adjusting holds on a record with many "lowest priority" requests, Koha would use recursive calls that repeatedly touched every hold on the record. This caused significant slowdowns (lag) when managing large hold queues.
- [41849](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41849) Cancelling filled hold from group does not cancel remaining pending holds from group or indicate that it's a hyperhold (26.05.00,25.11.05)
  >This patch adds a new option to the modal displayed when checking in an item that is already waiting for a hold. If the hold is part of a group, the modal will offer the option to cancel all holds in the group rather than just the hold for the item that has been checked in.
  >A new REST API endpoint (POST /patrons/{patron_id}/hold_groups/{hold_group_id}/cancel) has been added to achieve this functionality. The new endpoint will:
  >-Cancel all holds within a specified hold group.
  >-Accept a cancellation reason 
  >-Return a 204 on success
  >-Return a 404 when the hold group cannot found or does not exist.
  >
  >The endpoint requires the 'reserveforothers' permission.
- [41878](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41878) No logs for grouping existing holds or ungrouping a hyperhold (26.05.00,25.11.05)
  >With this patch, Koha will record a holds modification in the action logs each time a hold is grouped or ungrouped.
- [41880](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41880) Logs for moved holds don't indicate original bib number/item number (26.05.00,25.11.05)
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
- [41956](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41956) Show hold_group_id in patron holds table rather than visual_hold_group_id (26.05.00)
- [42147](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42147) Action logs for hold creation contain less data (26.05.00,25.11.05)
  >Prior to version 25.05.05, the action logs for creating a hold used to show the full hold data in the "info" column, but starting in 25.05.05 the "info" column only shows the hold id, and other hold information is not logged when the hold is created. This restores other hold values to the hold creation action logs, so that libraries can easily look up the starting priority and options that were selected when the hold was first placed.
- [42255](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42255) Grouped holds counted inconsistently for circ rules (26.05.00,25.11.05)
  >This fixes placing holds when group holds are enabled (DisplayAddHoldGroups system preference), so that a group hold only counts as one hold.
  >
  >Previously, each hold in the hold group was counted as a hold. So if the "Holds allowed (total)" or "Maximum total holds allowed (count)" circulation and fine rules values were exceeded you would not be able to place additional holds and get a message "Too many holds: [patron name] can place of the requested holds for a maximum of XX total holds.".
  >
  >Example: if the total holds allowed is set to 2 and a group hold was placed on two records, this was counted as 2 holds - placing an additional hold would result in the the "Too many holds" message.
- [42343](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42343) JS error holdsQueueTable is undefined when no holds exist (26.05.00,25.11.05)

  **Sponsored by** *Koha-Suomi Oy*
- [40287](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40287) Fix untranslatable strings in more statistics wizards (26.05.00,25.11.01)
  >This fixes and improves the acquisitions, patrons, catalog, and circulation statistics report wizard:
  >- Fixes some strings so that they are now translatable
  >- Improves the "Filtered on" information shown before the report results:
  >  . the filtered on options selected in the report are now shown in a bulleted list and in bold
  >  . descriptions are now shown instead of codes (for example, the library name instead of the library code)

  **Sponsored by** *Athens County Public Libraries*
- [41623](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41623) Missing translation string in catalogue_detail.inc (again) (25.11.02,25.05.09,24.11.14)
- [41689](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41689) "Staff note" and "OPAC" message types in patron files untranslatable (26.05.00,25.11.03,25.05.09)
- [41769](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41769) ", by" in suggestions table in the staff interface is not translated (26.05.00,25.11.05)
  >This fixes a translation issue in the purchase suggestions
  >table in the staff interface. When there is a suggestion title and author, a ", by" is added between the title and the author in the suggestion column. The "by" was not being translated when a language other than English was used for the staff interface.
- [42302](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42302) xgettext.pl does not output to STDOUT correctly (26.05.00,25.11.05)
- [42341](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42341) "Print label" on staff detail page is not translatable (26.05.00,25.11.05)
- [41204](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41204) OpenURL ILL no longer defaults to Standard if FreeForm (26.05.00,25.11.03)
- [41237](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41237) OPAC created requests ignore library selection, always default to patron's library (26.05.00,25.11.02,25.05.09,24.11.14)
  >This fixes a bug on the OPAC create ILL request form which was always setting the library to the patron's library, ignoring the library selection made on the form.
- [41247](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41247) ILL batches modal does not reset correctly (26.05.00,25.11.05)
  >The "New ILL requests batch" modal was not resetting its state correctly after being closed, causing unexpected behaviour when it was reopened.
  >
  >The modal now resets its internal state fully when closed, so that each new batch creation session starts from a clean initial state regardless of how far through the workflow the previous session progressed.
- [41465](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41465) Unauthenticated request does not display 'type' correctly (26.05.00,25.11.03,25.05.09)
- [41478](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41478) AutoILLBackendPriority - Unauthenticated request shows backend form if wrong captcha (26.05.00,25.11.03,25.05.09)
- [41512](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41512) ILLCheckAvailability stage table doesn't render (26.05.00,25.11.03,25.05.09)
  >This fixes creating ILL requests when the ILLCheckAvailability system preference is used - the checking for availability was not completed and the table was not shown.
- [41861](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41861) ILL request cost and price paid don't show if 0 (26.05.00,25.11.05)
  >This updates how an ILL request cost and price paid are shown - if the amount is $0, then it is now shown. Previously, the fields were not shown if the amount was $0.
  >
  >(Note: 'Cost' is not editable in the user interface, but the backend used may set the value. 'Price paid' is editable through the 'Edit request' action)
- [41944](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41944) Error 500 on non-existent ILL request (op=illview) (26.05.00,25.11.05)
  >This fixes error 500 and stack trace messages being shown when attempting to access a non-existent ILL request in the staff interface. Now, if no request is found, the standard 404 page not found error page is shown.
- [42244](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42244) Fix JS TypeError on patrons ILL table (26.05.00,25.11.05)
- [40006](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40006) Upgrading install.pl shows code vs HTML (26.05.00,25.11.01)
  >This fixes a database update (for bug 38436 in 24.11.00) that caused code to show in the browser instead of HTML output when running an upgrade.
- [21453](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21453) blinddetail-biblio-search.pl/.tt use hardcoded subfield values for MARC21 (26.05.00,25.11.05)
- [41843](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41843) Koha::Authorities->move_to_deleted can die on encoding errors (26.05.00,25.11.05)
  >This fixes deleting authority records - you can now successfully delete authority records with encoding errors and invalid MARCXML.
  >
  >Previously, attempting to delete an authority record with encoding errors would result in a 500 error.
- [41859](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41859) Authority search autocomplete results not consistent with search results (26.05.00,25.11.05)

  **Sponsored by** *Ignatianum University in Cracow*
- [41962](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41962) Add comment to SearchAuthorities about unused params, update POD accordingly (26.05.00,25.11.05)
- [41759](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41759) The display of MARC 21 field 026 data (Fingerprint Identifier) is missing (both in intranet and OPAC) (26.05.00,25.11.05)

  **Sponsored by** *Ignatianum University in Cracow*
- [41373](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41373) Report share with mana not working when language_loop is not true (26.05.00,25.11.05)
- [28308](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28308) Select 'Days in advance' = 0 for Advance notice effectively disables PREDUE notices (26.05.00,25.11.03)
- [39749](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39749) RestrictPatronsWithFailedNotices should not trigger for DUPLICATE_MESSAGE failures (26.05.00,25.11.04)
- [39781](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39781) Cannot limit by library when creating custom patron email sent via patron details page (26.05.00,25.11.03)
  >This patch updates the Add Message interface in the patron record such that the dropdown for selecting a notice template when sending email or SMS messages will only list notices for all libraries or for the user's logged-in library. Messages using a template for a specific library will now enqueue successfully.
- [40960](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40960) Only generate a notice for patrons about holds filled if they have set messaging preferences (26.05.00,25.11.03,25.05.09,24.11.16)
  >Currently, if a patron has not set any messaging preferences for notifying them about holds filled, a print notice is still generated.
  >
  >With this change, a notice is now only generated for a patron if their messaging preferences for 'Hold filled' are set. This matches the behavor for overdue and hold reminder notices.
- [41393](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41393) Advance notices should set the reply to address (26.05.00,25.11.04,25.05.11)
- [42083](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42083) Email and SMS messages from patron record should have distinct permissions (26.05.00,25.11.03)
  >This patch removes the 'send_messages_to_borrowers' permission and replaces it with 'send_messages_to_borrowers_email' and 'send_messages_to_borrowers_sms,' allowing users to be limited to sending either email or SMS messages from a patron record. At update, users who previously had 'send_messages_to_borrowers' permission will be given only 'send_messages_to_borrowers_email,' as SMS messages are a new functionality on 26.05 and not something to which users previously had access.
- [40481](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40481) The items table on koha/opac-MARCdetail.pl does not honor OPACHiddenItems (26.05.00,25.11.05)
  >This fixes the MARC view in the OPAC where an item should be hidden when OPACHiddenItems rules should apply. The item was hidden in the normal view, but not in the MARC view.
- [40619](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40619) Remove OverDrive star ratings from the OPAC (26.05.00,25.11.01)
  >This removes the code for OverDrive star ratings from OPAC pages, as OverDrive no longer supplies star ratings through their API.

  **Sponsored by** *Athens County Public Libraries*
- [40822](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40822) Custom cover images not displayed in search results (26.05.00,25.11.03)
- [41479](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41479) Remove Baker & Taylor integration (26.05.00)
  >This removes the enhanced content integration for Baker & Taylor,  as they have ceased operating and the service is no longer available.

  **Sponsored by** *Athens County Public Libraries*
- [41558](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41558) Broken links to tab on opac-user (26.05.00,25.11.04,25.05.11)
  >This fixes and standardizes links to tabs for the patron summary section in the OPAC (such as Checked out, Overdue, Charges, Holds, and so on).
  >
  >In the past, we have used several different ways (some that work, some that don't) to construct the links to the tabs.
  >
  >Now, to directly link to a tab in the summary section, add ?tab=opac-user-* to the URL when you are in the summary section (where * = tab name from the anchor when you hover over the tab, for example checkouts (for Checked out), overdues (for Overdue), fines (for Overdue), recalls (for Recalls)).
- [41665](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41665) Only include Greybox in OPAC if IdRef is enabled (26.05.00,25.11.05)
  >This patch wraps the Greybox include in the OPAC with a syspref check on IdRef, so that it's only loaded when it's needed.
- [41690](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41690) Add MARC21 245$b (subtitle) to Cite option (26.05.00,25.11.05)
  >This fixes citations generated using the "Cite" option in the OPAC - subtitles are now included in the title where they exist for MARC21 (245$b).
- [41866](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41866) "Use of uninitialized value..." warning in opac-search.pl (26.05.00,25.11.05)

  **Sponsored by** *Ignatianum University in Cracow*
- [41870](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41870) Warning "Use of uninitialized value $borrowernumber" in opac-detail.pl (26.05.00,25.11.05)

  **Sponsored by** *Ignatianum University in Cracow*
- [41942](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41942) Hiding primary contact method hides lang with PatronSelfModificationBorrowerUnwantedField (26.05.00,25.11.05)
- [41953](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41953) OPAC holds don't show which group/hyperhold individual holds belong to (26.05.00,25.11.05)
  >This patch adjust the display of current holds in a patron's account in the OPAC to clarify which holds are grouped together. It adds a column showing the hold group number and makes it more clear that the message "part of a hold group" can be clicked to reveal a list of grouped holds.
- [41970](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41970) PA_CLASS does not show in fieldset ID on opac-memberentry.pl (26.05.00,25.11.04,25.05.11)
- [42017](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42017) Fix content type of OPAC news RSS (26.05.00,25.11.05)

  **Sponsored by** *Athens County Public Libraries*
- [42020](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42020) (Bug 39482 follow-up) Library info link shown in OPAC without OpacLibraryInfo and library URL (26.05.00,25.11.05)
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
- [42570](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42570) OPAC patron summary shows literal holds count instead of group-aware count (26.05.00,25.11.05)
  >This fixes the patron summary on the front page of the OPAC to show the correct number of holds when hold groups are enabled (DisplayAddHoldGroups system preference).
  >
  >Grouped holds are now correctly shown as 1 hold, instead of the number of individual holds in hold groups.
- [29768](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29768) hidepatronname hides guarantor name on borrower edit screen (26.05.00,25.11.03)
  >If the `hidepatronname` system preference was set to "Don't show" it hid the guarantor's name when:
  >- editing the guarantee's patron record (it shows the guarantor patron's card number)
  >- viewing the guarantee patron's details page
  >
  >With this change, you can now see the guarantor's name in these areas.
  >
  >As this information is viewable by clicking the card number, it doesn't make much sense to hide the patron name for guarantors and guarantees.

  **Sponsored by** *Koha-Suomi Oy*
- [36360](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36360) Link ILL requests to surviving patron record when patrons are merged (26.05.00,25.11.03)
- [37143](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37143) Patron registration allows for saving required fields with a single space instead of information (26.05.00,25.11.05)
  >This changes the OPAC self-registration form validation so that required fields need actual information, and not just spaces.
  >
  >Before this, spaces could be entered into most required fields and the form would successfully submit. Now, when submitting, a warning is generated to fill in all missing fields for required fields with just spaces.
- [39014](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39014) Storing a guarantee fails due to TrackLastPatronActivityTriggers "creating a patron" (26.05.00,25.11.01)
  >This fixes an error when creating a patron that requires a guarantor, when this combination of settings is used:
  >- `TrackLastPatronActivityTriggers`: 'Creating a patron' is selected
  >- `ChildNeedsGuarantor`: is set to 'requires'
  >- The patron category is a 'Child' and 'Can be guarantee' is set to 'Yes'
  >
  >With these settings, this error message "The following fields are wrong. Please fix them." (without a list of fields) was incorrectly shown when creating a child patron, even though you had correctly added the guarantor information.

  **Sponsored by** *Koha-Suomi Oy*
- [41040](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41040) Empty patron search from the header should not trigger a patron search (26.05.00,25.11.03,25.05.09)
  >This fixes the "Search patrons" option in the staff interface menu bar. Currently, clicking "Search patrons" and then the arrow (without entering a value) automatically performs a search.
  >
  >With this change, a patron search is now no longer automatic. If you don't enter anything, or don't select any options, you are now prompted (using a tooltip) to enter a patron name or card number.
  >
  >NOTE: This is a change in behavour from what you may be used to.
- [41073](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41073) Import users expiry date default does not apply (26.05.00,25.11.05)
- [41363](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41363) Don't hide patron category limitation warning behind icon (26.05.00,25.11.01)
  >This moves the hint text for the warning on the Library management > Category field (when editing a patron record) from a tool tip on the warning icon to standard hint text under the input field, to make it more accessible
  >
  >Note: This warning only appears under certain circumstances (when a patron category is limited to a specific library, and you edit a patron when the library is set to another location).

  **Sponsored by** *Athens County Public Libraries*
- [41497](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41497) ul.patronbriefinfo inconsistent in coding structure (26.05.00,25.11.02)
  >This patch fixes inconsistent HTML structures in the patronbriefinfo <ul>.

  **Sponsored by** *Athens County Public Libraries*
- [41675](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41675) Username value is ignored in Patron quick-add form (26.05.00,25.11.04,25.05.11)
- [41752](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41752) Guarantor first name and guarantor surname mislabeled in system preferences (26.05.00,25.11.03,25.05.09)
- [41904](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41904) "Use of uninitialized value..." warning in del_message.pl (26.05.00,25.11.04,25.05.11)

  **Sponsored by** *Ignatianum University in Cracow*
- [41986](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41986) Names in "Contact information" need more clarity (26.05.00,25.11.04,25.05.11)
  >This changes the "Contact information" section on the patron details page (moremember.pl) to:
  >- show the "Middle name" field (where it exists)
  >- show the "Preferred name" field at the top (where it differs from the "First name").
- [42169](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42169) Unify patron category change popups (26.05.00,25.11.05)
- [42474](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42474) Patron categories form label: "Upperage limit" should be "Upper age limit" (26.05.00,25.11.05)
  >This fixes the spelling for a patron category form label - it changes "Upperage limit" to "Upper age limit".
- [41408](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41408) POS Inline Editing Triggers Form Submission on Enter Key (26.05.00,25.11.01)
  >Inline editing the cost or quantity fields on a point of sale transaction, then pressing enter, incorrectly submitted the form--instead of just updating the field.
  >
  >Now, the values in the fields are updated without submitting the form, and you can continue entering sale details and completing the transaction.
- [41585](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41585) Refunds don't always appear on the register page (26.05.00,25.11.05)
  >This patch fixes two issues with cash refunds on the register page:
  >
  >1. Payouts were not appearing in the transactions table after being
  >   created because accountlines were fetched before the refund
  >   operation completed.
  >
  >2. Account credit (AC) refunds were incorrectly creating payout
  >   transactions when no cash should leave the register.
- [40219](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40219) Welcome Email Sent on Failed Patron Registration via API (26.05.00,25.11.01,25.05.08,24.11.13)
  >This fixes patron registrations using the API - a welcome email notice was sent even if there were validation failures.
- [41700](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41700) Checkouts note_date has incorrect format in swagger definitions (26.05.00,25.11.03)
- [41292](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41292) Add "force_password_reset_when_set_by_staff" to the allowed column name list (26.05.00,25.11.01)
  >This adds the force_password_reset_when_set_by_staff field in the categories table to the list of allowed password-related fields that can be used in SQL reports.
  >
  >Currently, this field is treated as containing sensitive password-related data and generates an error when creating a report that uses it.
- [41699](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41699) onsite_checkout not available in Statistics wizards (26.05.00,25.11.05)
  >In Reports > Statistics wizards > Circulation there was no  option to extract information about entries with statistics.type = 'onsite_checkout'.
- [41715](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41715) Argument "YYYY-MM-DD" isn't numeric in numeric lt (<)... warnings in issues_stats.pl (26.05.00,25.11.04,25.05.11)
  >Removes the cause of "[WARN] Argument "YYYY-MM-DD" isn't numeric in numeric lt (<) at /kohadevbox/koha/reports/issues_stats.pl line 224." warnings from the plack-intranet-error.log when using the from and to date filter in the circulation statistics report in the staff interface.
  >
  >This was happening because a numerical comparison was used to compare the dates, instead of a string comparison.

  **Sponsored by** *Ignatianum University in Cracow*
- [36752](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36752) Remove TODO about missing summary info in the SIP2 code (26.05.00,25.11.04,25.05.11)
- [40455](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40455) A patron information  request fails when no currency is set (26.05.00,25.11.01)
  >This fixes an error in SIP2 patron information responses (64) when no currency is set, which can be the case for new Koha instances.
  >
  >Example, if no currency is set:
  >- Before the fix, there is an 'undef' error:
  >    ...
  >    Trying 'patron_information'
  >    SEND: 6300120251202    115652          AOCPL|AA42|ACterm1|
  >    READ: undef 
  >- After the fix, patron informatin is returned and there is no error:
  >    ...
  >    Trying 'patron_information'
  >     SEND: 6300120251202    122545          AOCPL|AA42|ACterm1|
  >     READ: 64              00120251202     
  >     122546000000000000000000000000AOCPL|AA42|AE koha|BLY|BV0|CC5|PCS|
  >     PIY|AFGreetings from Koha. |
- [41369](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41369) SIP payments have no branchcode (26.05.00)
  >This fixes SIP2 based payments, so that a branchcode (institution id) is now recorded for the payment.
- [41458](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41458) SIP passes UID instead of GID to Net::Server causing error (26.05.00,25.11.03,25.05.09)
  >This fixes an error that may occur when starting the SIP server: "...Couldn't become gid "<uid>": Operation not permitted...". Koha was passing an incorrect value to the Net::Server "group" parameter.
- [41811](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41811) SIP server will inadvertently remove non-alphanumeric characters from the end of a message (26.05.00,25.11.04,25.05.11)
- [41818](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41818) SIP2 message in AF field should be stripped of newlines and carriage returns (26.05.00,25.11.04,25.05.11)
- [41985](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41985) Fix wording on SIP2 account form - 'Syspref' to 'System preference' (26.05.00,25.11.05)
  >This fixes the section heading on the SIP2 account form to spell system preference in full ('Syspref overrides' to 'System preference overrides').
- [42447](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42447) SIP template fields in the database are too small (26.05.00,25.11.05)
- [41444](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41444) Fetch transfers directly for search results (26.05.00,25.11.04,25.05.11)
- [41496](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41496) Item search copy sharable link not working (26.05.00,25.11.04,25.05.11)

  **Sponsored by** *Lund University Library*
- [28884](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28884) ElasticSearch: Question mark in title search returns no results (26.05.00,25.11.05)

  **Sponsored by** *Pontificia Università di San Tommaso d'Aquino (Angelicum)*
- [38345](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38345) Restore support for OpenSearch (26.05.00,25.11.01)
  >This fixes Koha so that OpenSearch now works, and is now covered again by continuous integration tests (these have been failing for some time in Jenkins).
  >
  >Note: See the test plan for guidance on how to start KTD successfully with OS1 and OS2 if you have issues.
- [40658](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40658) When sorting by local-number we should use the sort field (26.05.00,25.11.05)
- [40853](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40853) ElasticsearchBoostFieldMatch - needs to boost results more (26.05.00)
- [40980](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40980) Clicking a search facet without logging in may trigger a cud-login error (26.05.00,25.11.01)
  >This fixes using facets in the OPAC for searching when not logged in, where Elasticsearch or OpenSearch is used as the search engine. In some circumstances, a 403 Forbidden Error was incorrectly generated (this is related to changes made in previous versions of Koha to improve form security).
- [41758](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41758) Add Fingerprint Identifier data to Elasticsearch index mappings (26.05.00,25.11.05)

  **Sponsored by** *Ignatianum University in Cracow*
- [41863](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41863) Facets generated from Authorized values sometimes show empty labels (26.05.00,25.11.05)

  **Sponsored by** *Ignatianum University in Cracow*
- [41795](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41795) UNIMARC: a Zebra search for Corporate Body Name authorities will also return Collective Titles (26.05.00,25.11.05)
  >Previously, in UNIMARC instances, a search for "Corporate Body
  >Name" authorities (authtypecode 'CO') in the OPAC or in the
  >Staff interface would return "Collective Title" (authtypecode 'CO_UNI_TI') authorities as well. This has now been fixed. NOTE: this was a Zebra-only issue, Elasticsearch is not affected.
- [27826](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27826) Self checkout dies on '?' as a barcode (26.05.00,25.11.05)
  >This fixes the self-checkout feature so that barcodes with characters (such as ? or +) work. Previously, attempting to check out an item with such a barcode resulted in an error page.
- [41645](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41645) Make self-checkout use responsive CSS (26.05.00,25.11.04)
  >This change fixes the self check-out (SCO) so that it works with responsive CSS, which makes it more mobile friendly. This is especially useful when providing SCO on a tablet.
- [41647](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41647) Make self-checkin use responsive CSS (26.05.00,25.11.04)
  >This change fixes the self check-in (SCI) so that it works with responsive CSS, which makes it more mobile friendly. This is especially useful when providing SCI on a tablet.
- [42200](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42200) SelfCheckTimeout being interpreted in milliseconds instead of seconds (26.05.00)
  >This fixes the timeout for the self-checkout system. The value in SelfCheckTimeout is in seconds, but milliseconds were used in the code. (For example, instead of the timeout happening after 120 seconds (2 minutes) you were logged out after 120 milliseconds!)
  >
  >(This was caused by a change in Bug 38365 - Add Content-Security-Policy HTTP header to HTML responses, added in Koha 26.05.)
- [36136](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36136) Flatpickr allows selecting date from the past on copied serial subscriptions (26.05.00,25.11.03)
- [36466](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36466) Incorrect date value stored when "Published on" or "Expected on" are empty (26.05.00,25.11.03,25.05.09)
  >Editing a serial and removing the dates in the "Published on" and "Expected on" fields generated a 500 error (Serials > [selected serial] > Serial collection).
  >
  >This fixes the error and:
  >- Sets the data in the database to NULL
  >- Shows the dates as "Unknown" in the serial collection table for the "Date published" and "Date received" columns
  >- Changes any existing 0000-00-00 dates in the database to NULL (for existing installations)
- [37796](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37796) Generated issue has incorrect number in pattern when receiving (26.05.00,25.11.01)
  >This fixes an issue with incorrect numbering patterns and the next expected issue shown, after a serial is received.
  >
  >Example of an incorrect numbering pattern before this fix: 
  >- Monthly serial received for August 2025 (its status shows as 'Arrived' for August 2025).
  >- The next expected serial was then shown as August 2025 instead of September 2025 (its status was shown as 'Expected' with a incorrect numbering pattern of August 2025)
- [41846](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41846) Notes field of routing list displays HTML characters (26.05.00,25.11.05)
  >This change fixes the routing list note so that new lines converted to <br> don't get escaped by the HTML filter.
- [42277](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42277) JS error when viewing a subscription (26.05.00,25.11.05)
- [20956](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20956) BorrowersLog is not logging permission changes (26.05.00)
  >This enhancement adds logging of patron permission changes when BorrowersLog is enabled. Detailed information about the changes is now included in the log viewer tool info and diff columns. Before this change, permission changes were not logged.
- [34353](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34353) We don't need 'SpineLabelShowPrintOnBibDetails' anymore (26.05.00)
  >This removes the SpineLabelShowPrintOnBibDetails system preference, as columns shown on the bibliographic details page holding table are customizable using table settings.
  >
  >(Upgrading takes into account the current settings. For, example if SpineLabelShowPrintOnBibDetails was set to show, then it will be visible unless the table setting for spinelabel was set to "Is hidden by default".)
- [39055](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39055) Unauthenticated are not redirected properly in reports module after login (26.05.00,25.11.04)
  >This change fixes the login so that pages that use "op" still work following a login prompt.
- [41422](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41422) New FilterSearchResultsByLoggedInBranch doesn't fully translate (26.05.00,25.11.03,25.05.09)
  >This fixes the translatability of the text shown when the FilterSearchResultsByLoggedInBranch system preference is enabled, and also the check and what is shown only works when not translated.
- [41427](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41427) Terminology: branch should be library in FilterSearchResultsByLoggedInBranch (26.05.00,25.11.01)
  >This fixes the terminology and improves the description for the FilterSearchResultsByLoggedInBranch system preference - branch should be library.
- [41476](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41476) Plugins table explode if one of the plugin is in error (26.05.00,25.11.05)
- [41484](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41484) Wording of 'On hold', 'Booked', and 'Recalled' in issues table can be confusing (26.05.00,25.11.02)
  >This updates the wording of messages on a patron's checkouts tab (under the check out and details sections) to avoid confusion when another patron has placed a hold, booking, or recall. 
  >
  >Messages changed:
  >- Recalled => Item recalled by another patron
  >- Booked => Item booked for another patron
  >- On hold => Item on hold for another patron
- [41494](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41494) Rename "Koha administration" to "Administration" for consistency (26.05.00,25.11.02)
  >Renames "Koha administration" to "Administration" on the staff interface and administration module home pages. This improves consistency, as everywhere else in the staff interface it is called administration, such as for breadcrumbs and browser page titles.
- [41516](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41516) Terminology: Change cardnumber to card number for system preference descriptions (26.05.00,25.11.05)
  >This fixes the system preference descriptions for AutoSwitchPatron, CardnumberLog, and SelfCheckoutByLogin so that they use "card number" instead of "cardnumber" (as per the terminology guidelines).
- [41594](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41594) Can access invoice-files.pl even when AcqEnableFiles is disabled
  >26.05.00, 25.11.03, 25.05.09, 24.11.14, 22.11.36
- [41624](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41624) Revert Bug 35211 (26.05.00)
- [41679](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41679) Stock rotation repatriation modal can conflict with holds modal (26.05.00,25.11.03,25.05.09,24.11.16)
- [41958](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41958) Rename BibTex to BibTeX (with a capital X) for the staff interface cart and list download options (to match the OPAC) (26.05.00,25.11.04,25.05.11)
  >This renames BibTex to BibTeX (with a capital X) for the staff interface cart and list download options (to match the OPAC).
- [41976](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41976) [Vue] LinkWrapper.vue isn't scoped properly (26.05.00,25.11.04,25.05.11)
- [41989](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41989) addbook shows the translated interface (26.05.00,25.11.04,25.05.11)
  >Fixes an issue with templates that meant incorrect translations could be shown on the addbook page.
- [42182](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42182) StaffReportsHome HTML customization does not work when library limited (26.05.00,25.11.05)
- [42238](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42238) Navigating directly to a patron's holds tab does not work (26.05.00,25.11.05)
- [42309](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42309) JS error when there are no cash registers (26.05.00,25.11.05)
  >This fixes a JavaScript error in the browser console when there are no cash registers (Administration > Accounting > Cash registers):
  >
  >Uncaught TypeError: can't access property "DataTable", crtable is undefined
- [42398](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42398) Form validation does not work on additional content news (26.05.00,25.11.05)
  >This fixes adding or editing news (Tools > Additional tools > News) so that a default title and content is required for a news item.
- [19690](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19690) Smart rules: Term "If any unavailable" is confusing (26.05.00,25.11.03,25.05.09,24.11.16)
- [28297](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28297) Can't save system preference and field not marked as modified when changing value (26.05.00,25.11.05)
  >System preferences with a text input field can now be saved when they are changed back to the original value.
- [38876](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38876) Typo in UpdateNotForLoanStatusOnCheckout description (26.05.00,25.11.02)
- [41190](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41190) "Default checkout, hold and return policy" needs a space in title (26.05.00,25.11.02)
  >Adds a space to the circulation rules section heading for "Default checkout, hold and return policy" when a library is selected.
  >
  >Example:
  >- With a library selected, such as Centerville, the rule heading is missing a space "Default checkout, hold and return policyfor Centerville"
- [41360](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41360) Transport cost matrix assumes all transfers are disabled upon first use (26.05.00,25.11.04,25.05.11)
  >This adds three new toolbar buttons to make batch modifications to the transport cost matrix table easier (when UseTransportCostMatrix is enabeld):
  >
  >* Enable all cells
  >* Disable empty cells
  >* Populate empty cells, with selectable values from 0 to 100
- [41540](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41540) staffShibOnly - update description for system preference (26.05.00,25.11.02,25.05.09)
  >This updates the description for the `staffShibOnly` system preference and fixes grammar and spelling:
  >- "login" to "log in"
  >- "shibboleth" to "Shibboleth" (capitalized)
- [42638](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42638) Cannot delete an identity provider domain (26.05.00,25.11.05)

  **Sponsored by** *Athens County Public Libraries*
- [37402](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37402) Task scheduling fails if you don't use the correct time format (26.05.00,25.11.03)
- [32285](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32285) Punctuation: Completeness of the reproduction code␠:, ... (26.05.00,25.11.03)
  >This removes spaces before the colons for the unimarc_field_325h.pl and unimarc_field_325j.pl value builder form field labels.
- [32288](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32288) Capitalization: RDA Carrier, etc. (26.05.00,25.11.03)

  **Sponsored by** *Athens County Public Libraries*
- [35237](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35237) Duplicate ids in markup of patron card layout edit form (26.05.00,25.11.05)
  >Remove duplicate ID's in the markup to return valid html.

  **Sponsored by** *Catalyst*
- [38739](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38739) Templates not ending with include intranet-bottom.inc in staff interface (26.05.00,25.11.02)
  >This update fixes inconsistencies in template markup which could cause duplicated page elements, JavaScript errors, and errors in HTML validation.
- [40567](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40567) Correct eslint errors in recalls.js (26.05.00,25.11.01)
  >This fixes a few minor coding guideline errors in the JavaScript used on recalls pages (JS8: Follow guidelines set by ESLint). There are no changes to how the recalls pages work.

  **Sponsored by** *Athens County Public Libraries*
- [40568](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40568) Various corrections to recalls templates (26.05.00,25.11.04)
  >This makes some minor changes to recalls templates:
  >- Fixes the date sorting on the recalls queue page
  >- Hides "Show old recalls" if there are no recalls in a patron's recalls history, and adds the "page-section" div (white background)

  **Sponsored by** *Athens County Public Libraries*
- [40703](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40703) Replace data-toggle by data-bs-toggle (26.05.00,25.11.03)
- [40787](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40787) Plugins buttons misaligned when search box is enabled (26.05.00,25.11.04,25.05.11)
- [41339](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41339) Typo 'Too many checkout' (26.05.00,25.11.01)
  >Changes "Too many checkout" to "Too many checkouts" message that shows in the log viewer when circulation overrides are logged.
- [41340](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41340) Better translatability on 'batch_item_record_modification.inc' (26.05.00,25.11.03)
- [41347](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41347) Terminology: Item had a reserve waiting (26.05.00,25.11.03)
  >This fixes the terminology for two log viewer messages:
  >- "Item had a reserve waiting" to "Hold waiting on item"
  >- "Item was reserved" to "Hold placed on item"
- [41348](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41348) Capitalization: "List Files" and others (26.05.00,25.11.01)
  >This fixes the capitalization for messages used with FTP/SFTP file transfers (Administration > Additional parameters > File transports).
  >
  >Changes:
  >- "List Files" to "List files"
  >- "Change Directory" to "Change directory"
- [41351](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41351) Capitalization: Override Renew hold for another (26.05.00,25.11.02,25.05.09)
  >This fixes the capitalization for a log viewer message: "Override Renew hold for another" to "Override renew hold for another".
- [41361](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41361) Incorrect markup in category code confirmation modal (26.05.00,25.11.01,25.05.08)
  >This fixes the "Confirm expiration date" dialog box that is shown when changing an individual patron's category:
  >- The "No" option now works.
  >- It is now formatted using our standard Bootstrap 5 styles.

  **Sponsored by** *Athens County Public Libraries*
- [41395](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41395) Terminology: Target item cannot be reserved from other branches (26.05.00,25.11.01)
  >Updates the terminology for two circulation-related messages (reserves to holds, branches to libraries):
  >
  >- "Target item cannot be reserved from other branches" to "Target item cannot be placed on hold from other libraries"
  >- "No reserves allowed" to "No holds allowed"
- [41396](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41396) Capitalization: 'Transport Settings' and other (26.05.00,25.11.01)
  >This fixes the capitalization for the section headings on the EDI account create and edit form - they are now in sentence case (Administration > Acquisition parameters > EDI accounts):
  >
  >- Basic Information => Basic information
  >- Transport Settings => Transport settings
  >- Message Types => Message types
  >- Functional Switches => Functional switches

  **Sponsored by** *Athens County Public Libraries*
- [41397](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41397) Terminology: Target item is not reservable (26.05.00,25.11.02)
  >This fixes the terminology for a staff interface holds message: "Target item is not reservable" to "Target item cannot be placed on hold"
- [41398](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41398) Typo: Tagret item is not in the local hold group (26.05.00,25.11.02)
  >This fixes a spelling error for a holds-related message in the staff interface: "Tagret item is not in the local hold group" to "Target item is not in the local hold group".
- [41586](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41586) Spacing problem in display of patron names (26.05.00,25.11.03)

  **Sponsored by** *Athens County Public Libraries*
- [41658](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41658) Capitalization: Data Provider (26.05.00)
  >Fixes the capitalization for ERM module's "Latest SUSHI Counter jobs" dashboard widget so that the table column heading is "Data provider" instead of "Data Provider".
- [41760](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41760) Fix <tbody> and <tfoot> in several templates (26.05.00,25.11.05)

  **Sponsored by** *Athens County Public Libraries*
- [41764](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41764) ISSN hidden input missing from Z39.50 search form navigation (26.05.00,25.11.03,25.05.09,24.11.16)
  >This fixes the Acquisitions and Cataloging Z39.50 search forms so that the pagination works when searching using the ISSN input field.
  >
  >When you click the next page of results, or got to a specific result page, the search now works as expected - it remembers the ISSN you were searching for, with "You searched for: ISSN: XXXX" shown above the search results, and search results shown.
  >
  >Previously, the ISSN was not remembered, and "Nothing found. Try another search." was shown, and no further search results were shown.

  **Sponsored by** *Athens County Public Libraries*
- [41778](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41778) Broken display of not for loan status on item detail page (26.05.00,25.11.05)
  >This patch makes some corrections to the way the item detail page template defines and display an item's not for loan status.

  **Sponsored by** *Athens County Public Libraries*
- [41807](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41807) Fix automatic tab selection on basket groups page (26.05.00,25.11.04)
  >This patch fixes a bug which prevented the expected tab from being activated when the user takes certain actions like closing or deleting a basket group.

  **Sponsored by** *Athens County Public Libraries*
- [41835](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41835) Add item forms Tag editor buttons on serial edition page are misaligned (26.05.00,25.11.05)

  **Sponsored by** *Koha-Suomi Oy*
- [41838](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41838) Fix automatic tab selection on MARC subfield edit pages (26.05.00,25.11.04,25.05.11)

  **Sponsored by** *Athens County Public Libraries*
- [41964](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41964) Upgrade the Multiple Select plugin in the staff interface to 2.3.1 (26.05.00)

  **Sponsored by** *Athens County Public Libraries*
- [42012](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42012) e.preventDefault not called in clubs.tt club_hold_search handler (26.05.00,25.11.05)
- [42014](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42014) Patron lists tab shows blank content when no patron lists exist (26.05.00,25.11.04,25.05.11)
- [42103](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42103) Spelling: marc record (26.05.00,25.11.05)
  >This fixes the spelling of "marc" (marc to MARC) in two places:
  >- an error message in the database audit (More > About Koha > Database audit)
  >- the description for the marc_modification_templates permission
- [42104](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42104) Spelling: capitalize id (instead of id and Id) (26.05.00,25.11.05)
  >This fixes the spelling in several places where "id" or "Id" is used instead of "ID".
- [42106](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42106) Spelling: Failed to load plugin url: {0} (26.05.00,25.11.05)
  >Fixes the terminology for URL (url changed to URL) in the file used by Koha for translating TinyMCE editor interface UI text.
- [42131](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42131) Terminology: Return in action logs should be Check-in (26.05.00,25.11.05)
  >This changes the text for the "Return" action in the log viewer (when checking in an item) to "Check-in", to help improve translation.
- [42134](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42134) String displays incorrectly: words “notices” and “for” appear concatenated (26.05.00,25.11.05)

  **Sponsored by** *Athens County Public Libraries*
- [42140](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42140) Patron information - no space between guarantor name and relationship on patron details page (26.05.00,25.11.05)
  >This fixes the display of the guarantor information on a patron's details page for the staff interface - there is now a space between the guarantor's surname and relationship. For example: "Henry Acevedo (father)" instead of "Henry Acevedo(father)".
- [42434](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42434) Capitalization: Print Slip CSS,  Print Notice CSS... (26.05.00)
  >This fixes notice and slip configuration page headings and text so that they use sentence
  >case. It also adds full stops to some alert sentences for consistency.
  >
  >(Related to Bug 35267 - Clarify CSS options for notices, which added several new sections
  >to notice and slip configuration pages in Koha 26.05.)
- [42438](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42438) Remove event attributes from icon selection include file (26.05.00,25.11.05)

  **Sponsored by** *Athens County Public Libraries*
- [42439](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42439) Remove event attributes from label-edit-batch.tt (26.05.00,25.11.05)

  **Sponsored by** *Athens County Public Libraries*
- [42442](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42442) Remove event attributes from bibliographic record merge template (26.05.00,25.11.05)

  **Sponsored by** *Athens County Public Libraries*
- [42445](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42445) Remove event attributes from list creation template (26.05.00,25.11.05)

  **Sponsored by** *Athens County Public Libraries*
- [42467](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42467) Remove event attributes from MARC modification templates template (26.05.00,25.11.05)

  **Sponsored by** *Athens County Public Libraries*
- [39745](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39745) Wrong system preference 'language' in test suite (26.05.00,25.11.03)
  >This fixes several tests so that the correct system preference names are used:
  >- language => StaffInterfaceLanguages (name changed in bug 27490) 
  >- opaclanguages => OPACLanguages (name now uses the correct case)
- [40446](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40446) DB config used by Cypress (mysql2) is not configurable (26.05.00,25.11.02)
- [40946](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40946) "Aborted connection 42 to db" from Koha/Z3950Responder/ZebraSession.t (26.05.00,25.11.03)
- [40947](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40947) "Aborted connection 42 to db" from t/db_dependent/www/search_utf8.t (26.05.00,25.11.03)
- [40962](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40962) t/db_dependent/OAI/Server.t is failing (26.05.00,25.11.05)
- [41384](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41384) SIP2/Accounts.ts  is failing randomly (26.05.00,25.11.04)
- [41449](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41449) Reserves.t may fail when on shelf holds are restricted (26.05.00,25.11.03,25.05.09,24.11.16)
- [41616](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41616) Warnings on authority_hooks.t (26.05.00,25.11.04)
- [41710](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41710) SearchEngine/Elasticsearch/Search.t does not rollback properly (26.05.00,25.11.03)
- [41812](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41812) xt/find-missing-csrf.t failing when JS contains csrf_token hidden input (26.05.00)
- [41830](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41830) Acquisitions/Vendors_spec.ts is failing randomly (26.05.00,25.11.04,25.05.11)
- [41831](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41831) ERM/Dialog_spec.ts leaves test data in DB (26.05.00)
- [42126](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42126) t/db_dependent/00-strict.t not testing all perl files (26.05.00,25.11.05)
- [42359](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42359) t/db_dependent/Reports/Guided.t fails when ReportsLog is enabled (26.05.00,25.11.05)
- [42578](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42578) Koha/Hold.t failing on date comparison (26.05.00,25.11.05)
- [42581](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42581) xt/api.t shouldn't test routes injected by plugins (26.05.00,25.11.05)
- [29016](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29016) Log viewer has problems with many entries (26.05.00,25.11.05)
- [40846](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40846) Job Status should not be Failed if a record import result in a item update (26.05.00,25.11.02)
- [41163](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41163) Circulation logs record issuing branch in database but show logged-in branch in log viewer (26.05.00,25.11.03)
- [41334](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41334) Move modified_holds tables column settings under Tools section (26.05.00,25.11.02)
  >This moves the location of the modified_holds table on the table settings  page from Circulation > holds to Tools > batch_hold_modification, as this table relates to the batch modification of holds (added to Koha 25.11 by bug 36135).

  **Sponsored by** *Koha-Suomi Oy*
- [41883](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41883) Modifications using batch hold modification tool aren't logged (26.05.00,25.11.05)
  >This patchsets adds the ability to log information about holds modified via the batch hold modification tool. Modifications are only logged if the HoldsLog system preference is enabled.
- [41884](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41884) Job report for batch item modifications that fail due to PreventWithdrawingItemsStatus has no details on failed items (26.05.00,25.11.05)
- [42156](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42156) Staging and matching authorities with bad characters can fail (26.05.00,25.11.05)
  >This fixes an error where matching on authorities would fail when encountering a record with invalid characters.
  >
  >Koha will now attempt to clean the record for parsing. If it can't be recovered, the record will be dropped from found matches.

## New system preferences

- AllNoticeCSS
- AllNoticeStylesheet
- AllowFineOverrideRenewing
- AllowHoldCheckoutOverride
- AnonymizeLastBorrower
- AnonymizeLastBorrowerDays
- ApiKeyLog
- AutomaticRenewalPeriodBase
- EdifactLSL
- ElasticsearchBoostFieldMatchAmount
- ElasticsearchEnableZebraQueue
- ElasticsearchEscapeCharacters
- EmailNoticeCSS
- EmailNoticeStylesheet
- FineNoRenewals
- FineNoRenewalsBlockAutoRenew
- FineNoRenewalsBlockSelfCheckRenew
- FineNoRenewalsIncludeCredits
- FutureHoldsBlockRenewals
- LostChargesControl
- ManualRenewalPeriodBase
- OPACTableColExpandedByDefault
- OpacElasticsearchEscapeCharacters
- PatronAgeRestriction
- PrintNoticeCSS
- PrintNoticeStylesheet
- PrintSlipCSS
- PrintSlipStylesheet
- TitleHoldFeeStrategy
- UseHoldsQueueFilterOptions
- UseLibraryFloatLimits
- autoMemberNumValue

## Deleted system preferences

- BakerTaylorBookstoreURL
- BakerTaylorEnabled
- BakerTaylorPassword
- BakerTaylorUsername
- NoticeCSS
- OPACFineNoRenewals
- OPACFineNoRenewalsBlockAutoRenew
- OPACFineNoRenewalsIncludeCredits
- RenewalPeriodBase
- SlipCSS
- SpineLabelShowPrintOnBibDetails

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [English (USA)](https://koha-community.org/manual/26.05/en/html/)
- [French](https://koha-community.org/manual/26.05/fr/html/) (80%)
- [German](https://koha-community.org/manual/26.05/de/html/) (88%)
- [Greek](https://koha-community.org/manual/26.05/el/html/) (92%)
- [Hindi](https://koha-community.org/manual/26.05/hi/html/) (62%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (87%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified Han script) (79%)
- Chinese (Traditional Han script) (92%)
- Czech (64%)
- Dutch (83%)
- English (100%)
- English (New Zealand) (58%)
- English (USA)
- Finnish (98%)
- French (98%)
- French (Canada) (94%)
- German (100%)
- Greek (63%)
- Hindi (90%)
- Italian (78%)
- Norwegian Bokmål (67%)
- Persian (fa_ARAB) (88%)
- Polish (100%)
- Portuguese (Brazil) (97%)
- Portuguese (Portugal) (88%)
- Russian (88%)
- Slovak (56%)
- Spanish (93%)
- Swedish (88%)
- Telugu (62%)
- Turkish (77%)
- Ukrainian (71%)
- Western Armenian (hyw_ARMN) (57%)
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

The release team for Koha 26.05.00 is


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
new features in Koha 26.05.00
<div style="column-count: 2;">

- Athens County Public Libraries
- Auckland University of Technology
- British Museum
- [ByWater Solutions](https://bywatersolutions.com)
- [Büchereizentrale Schleswig-Holstein](https://www.bz-sh.de)
- California College of the Arts
- [Cape Libraries Automated Materials Sharing](https://info.clamsnet.org)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)
- Cheshire Libraries Shared Services
- Education Services Australia SCIS
- Ignatianum University in Cracow
- Karlsruhe Institute of Technology (KIT)
- [Koha-Suomi Oy](https://koha-suomi.fi)
- Lund University Library
- MAIN Library Alliance
- [Main Library Alliance](https://www.mainlib.org)
- [Martin Renvoize](martin.renvoize@openfifth.co.uk)
- National Library of Finland
- [OpenFifth](https://openfifth.co.uk)
- Pontificia Università di San Tommaso d'Aquino (Angelicum)
- Pymble Ladies' College
- [Reformational Study Centre](www.refstudycentre.com)
- [Royal Borough of Kensington and Chelsea](https://www.rbkc.gov.uk)
- [The Main Library Alliance](https://www.mainlib.org)
- UK Health Security Agency
- [Westminster City Council](https://www.westminster.gov.uk)
</div>

We thank the following individuals who contributed patches to Koha 26.05.00
<div style="column-count: 2;">

- Saiful Amin (3)
- Aleisha Amohia (3)
- Pedro Amorim (178)
- apirak (1)
- Tomás Cohen Arazi (56)
- Matt Blenkinsop (44)
- Courtney Brown (1)
- Alex Buckley (3)
- Rudolf Byker (1)
- Connor Cameron-Jones (1)
- Kevin Carnes (4)
- Lewis Clay (1)
- Nick Clemens (85)
- Casey Conlin (1)
- David Cook (69)
- Jake Deery (9)
- Paul Derscheid (42)
- Roman Dolny (6)
- Jonathan Druart (301)
- elias (1)
- Laura Escamilla (17)
- Katrin Fischer (3)
- David Flater (2)
- Andrew Fuerste-Henry (29)
- Eric Garcia (7)
- Lucas Gass (197)
- Ayoub Glizi-Vicioso (5)
- Raguram Gopinath (1)
- grgurmg (1)
- Victor Grousset (4)
- David Gustafsson (1)
- Michael Hafen (3)
- Kyle M Hall (45)
- Harrison Hawkins (1)
- Mark Hofstetter (2)
- Andreas Jonsson (1)
- Kabooshki (1)
- Janusz Kaczmarek (13)
- Olli Kautonen (1)
- Aya Khallaf (1)
- Jan Kissig (19)
- Thomas Klausner (4)
- Emily Lamancusa (7)
- Brendan Lawlor (16)
- Owen Leonard (95)
- Julian Maurice (2)
- Mia (1)
- David Nind (13)
- Jacob O'Mara (24)
- pders01 (6)
- Eric Phetteplace (5)
- Photonyx (3)
- Katariina Pohto (1)
- Martin Renvoize (290)
- Olivia Reynolds (1)
- Alexis Ripetti (1)
- Marcel de Rooy (23)
- Caroline Cyr La Rose (4)
- Andreas Roussos (7)
- Johanna Räisä (9)
- Bernard Scaife (2)
- Lisette Scheer (10)
- Robin Sheat (1)
- Slava Shishkin (4)
- Maryse Simard (1)
- Simon (1)
- Fridolin Somers (6)
- Tadeusz „tadzik” Sośnierz (2)
- Leo Stoyanov (1)
- Raphael Straub (1)
- Adam Styles (1)
- Arthur Suzuki (7)
- Emmi Takkinen (13)
- Lari Taskula (26)
- Imani Thomas (3)
- Petro Vashchuk (3)
- Mercury WallacE (1)
- Shi Yao Wang (1)
- Hammat Wele (14)
- Wainui Witika-Park (4)
- Baptiste Wojtkowski (23)
- Tom Yates (1)
- Samuel Young (1)
- Jessica Zairo (3)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 26.05.00
<div style="column-count: 2;">

- Athens County Public Libraries (95)
- [BibLibre](https://www.biblibre.com) (39)
- [Bibliotheksservice-Zentrum Baden-Württemberg (BSZ)](https://bsz-bw.de) (3)
- [ByWater Solutions](https://bywatersolutions.com) (390)
- [Cape Libraries Automated Materials Sharing](https://info.clamsnet.org) (16)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha) (13)
- coffee.geek.nz (1)
- [Dataly Tech](https://dataly.gr) (7)
- David Nind (13)
- esa.edu.au (1)
- Göteborgs Universitet (1)
- hire-tom.co.uk (1)
- [HKS3](https://koha-support.eu) (2)
- hofstetter.at (2)
- [Hypernova Oy](https://www.hypernova.fi) (26)
- Independant Individuals (68)
- [Jezuici](https://jezuici.pl/) (6)
- kallisti.net.nz (1)
- Karlsruhe Institute of Technology (KIT) (1)
- Koha Community Developers (305)
- [Koha-Suomi Oy](https://koha-suomi.fi) (14)
- Kreablo AB (1)
- live.co.uk (1)
- [LMSCloud](https://www.lmscloud.de) (42)
- Lund University Library (4)
- memlen.com (1)
- [Montgomery County Public Libraries](https://montgomerycountymd.gov) (7)
- myy.haaga-helia.fi (1)
- [OpenFifth](https://openfifth.co.uk) (547)
- [Prosentient Systems](https://www.prosentient.com.au) (69)
- punsarn.asia (1)
- Rijksmuseum, Netherlands (23)
- semanticconsulting.com (3)
- [Solutions inLibro inc](https://inlibro.com) (26)
- [Theke Solutions](https://theke.io) (56)
- Wildau University of Technology (19)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Alex Carver [Acerock7] (4)
- Pedro Amorim (18)
- Tomás Cohen Arazi (66)
- Charlie Arthur (3)
- Andrew Auld (6)
- Scott Aylett (4)
- Brian J. Barr (3)
- Scott Barter (1)
- Kris Becker (17)
- Bob Bennhoff (17)
- Angela Berrett (1)
- Matt Blenkinsop (16)
- Christopher Brannon (12)
- Richard Bridgen (8)
- Emmanuel Bétemps (4)
- Connor Cameron-Jones (1)
- Aude Charillon (1)
- Nick Clemens (56)
- David Cook (78)
- Ben Daeuber (5)
- Benjamin Daeuber (1)
- Jake Deery (1)
- Paul Derscheid (205)
- Trevor Diamond (34)
- Roman Dolny (36)
- Jonathan Druart (225)
- Hannah Dunne-Howrie (6)
- Marion Durand (13)
- Magnus Enger (1)
- Laura Escamilla (46)
- Jeremy Evans (21)
- Syed Faheemuddin (1)
- Katrin Fischer (32)
- Roger fredricks (1)
- Andrew Fuerste-Henry (174)
- Brendan Gallagher (3)
- Lucas Gass (1313)
- Ayoub Glizi-Vicioso (1)
- Stephen Graham (2)
- Mike Grgurev (1)
- Victor Grousset (43)
- Kyle M Hall (75)
- Harrison Hawkins (1)
- Sally Healey (2)
- Juliet Heltibridle (7)
- Mason James (1)
- Graham Jones (1)
- Ludovic Julien (2)
- Janusz Kaczmarek (2)
- Olli Kautonen (1)
- Jan Kissig (20)
- Thomas Klausner (32)
- Kristi Krueger (17)
- Emily Lamancusa (23)
- Brendan Lawlor (23)
- Owen Leonard (187)
- Lin Wei Li (2)
- Ludovic (1)
- Manvi (2)
- Marie Martino (1)
- Chris Mathevet (1)
- Julian Maurice (11)
- Jeanne Mauriello (9)
- Gretchen Maxeiner (3)
- Esther Melander (1)
- Mercury (1)
- Michaela (29)
- Mikko (1)
- Peter Moore (8)
- Nathalie (2)
- Miranda Nero (9)
- David Nind (333)
- noah (3)
- Noah (1)
- Lawrence O'Regan-Lloyd (2)
- Nic Olsson (1)
- Wesley Owen (2)
- Leo O’Neill (1)
- Eric Phetteplace (3)
- Photonyx (1)
- Judy Poyer (1)
- Laurence Rault (2)
- Martin Renvoize (338)
- Phil Ringnalda (7)
- Jason Robb (45)
- Marcel de Rooy (100)
- Caroline Cyr La Rose (8)
- Johanna Räisä (1)
- Mathieu Saby (7)
- Samuel (1)
- Bernard Scaife (3)
- Lisette Scheer (118)
- Michaela Sieber (5)
- Catherine Small (5)
- Fridolin Somers (2)
- Edith Speller (1)
- Lari Strand (2)
- Arthur Suzuki (8)
- Justin Swink (1)
- Emmi Takkinen (10)
- Lari Taskula (26)
- Felicie Thiery (1)
- Jackie Usher (15)
- John Vinke (5)
- Alexander Wagner (1)
- Shi Yao Wang (2)
- Baptiste Wojtkowski (25)
- Laura Woodward (1)
- Jessie Z (1)
- Anneli Österman (5)
</div>

And people who contributed to the Koha manual during the release cycle of Koha 26.05.00
<div style="column-count: 2;">
- Jrobb (2)
- Pymble Ladies College (3)
- Andrew Auld (1)
- Manu B (5)
- Ian Beardslee (1)
- Aude Charillon (43)
- Caroline Cyr La Rose (68)
- Jonathan Druart (67)
- Hannah Dunne-Howrie (1)
- Marion Durand (8)
- Tim Hannah (2)
- Heather Hernandez (1)
- Mark Hofstetter (1)
- Kristi Krueger (4)
- Brendan Lawlor (1)
- David Nind (29)
- Lawrence O'Regan-Lloyd (1)
- Philip Orr (12)
- Paul Poulain (3)
- Laurence Rault (1)
- Martin Renvoize (2)
- Bouis S (4)
- Jessica Zairo (5)
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

Autogenerated release notes updated last on 26 May 2026 16:45:33.
