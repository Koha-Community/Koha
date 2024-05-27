# RELEASE NOTES FOR KOHA 24.05.00
28 May 2024

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 24.05.00 can be downloaded from:

- [Download](http://download.koha-community.org/koha-24.05-latest.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 24.05.00 is a major release, that comes with many new features.

It includes 9 new features, 239 enhancements, 529 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).

## New features & Enhancements

### About

#### Enhancements

- [32693](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32693) The 'About Koha' page loads slowly
  >This enhancement improves the 'About Koha' page loading time. Instead of loading all the tabs at once, the content is loaded when the tab is selected.

### Acquisitions

#### Enhancements

- [10758](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10758) Show bibliographic information of deleted records in acquisition baskets
  >This makes the title of a deleted bibliographic record visible in the basket summary page. Please note that this will only work on records, where the biblionumber of the deleted record has been stored. - A feature that was introduced with Koha 23.05.
- [18360](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18360) Allow deletion of cancelled order lines
  >This patch set allows you to delete cancelled order lines from an open acquisition basket.
- [30070](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30070) Performance issues with edifactmsgs when you have a large number of messages
  >This enhancement converts the EDIFACT messages display table to an API driven asynchronous datatable greatly improving the performance of that page when large numbers of messages exist.
- [33171](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33171) Add coded_location_qualifier, barcode, and enumchron to MarcItemFieldsToOrder
  >This enhancement allows the use of `coded_location_qualifier`, `barcode` and `enumchron` fields in the `MarcItemFieldsToOrder` preference.
- [33393](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33393) Modify sentence above the order table in English 1-page order PDF
  >This enhancement adds the new `1PageOrderPDFText` system preference allowing librarians to customise the output of PDF orders.

  **Sponsored by** *Pymble Ladies' College*
- [35724](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35724) Define non-standard port numbers for SFTP upload/download in EDI accounts
  >This adds configuration options for the upload port and download port to the EDI account configuration page. If no port is added, it will keep using the default port 22.

  **Sponsored by** *Waikato Institute of Technology, New Zealand*

### Architecture, internals, and plumbing

#### Enhancements

- [19097](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19097) Koha to MARC mappings (Part 3): Correct remaining GetMarcFromKohaField calls
- [31335](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31335) Unnecessary holds fetch in serials/routing-preview.pl
- [31345](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31345) Add ability to exit process_message_queue.pl early if any plugin before_send_messages hook fails
- [32474](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32474) Implement infinite scroll in vue-select
- [33431](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33431) Make code use C4::Context->yaml_preference
- [34426](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34426) Add tests for CSRF checks missing
- [35133](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35133) Accessors defined in AUTOLOAD does not work if called with SUPER
- [35388](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35388) Add comment to circ/transfers_to_send.pl about limited use in stock rotation context
- [35490](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35490) Remove GetMarcItem from C4::Biblio
- [35536](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35536) Improve removal of Koha plugins in unit tests
- [35581](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35581) ILL Koha classes are not consistent
  >This is behind-the-scenes work that restructures the Koha ILL classes in the source code. No functionality is added or updated here.
  >
  >For backend authors:
  >If your ILL backend(s) invokes core class methods e.g.:
  >my $request = Koha::Illrequests->find( $illrequest_id )
  >
  >It'll have to be updated to:
  >my $request = Koha::ILL::Requests->find( $illrequest_id )
- [35616](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35616) Add a 'source' field to Koha::Tickets to denote the path taken to report the ticket
- [35633](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35633) Upgrade Chocolat JS library from v1.1.0 to v1.1.2
- [35638](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35638) Upgrade Enquire JS library from v2.0.1 to v2.1.6
- [35640](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35640) Upgrade FileSaver JS library to v2.0.4
- [35642](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35642) Upgrade Font Face Observer library from v2.0.3 to v2.3.0
- [35643](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35643) Upgrade HC Sticky library from v2.2.3 to v2.2.7
- [35782](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35782) Remove Koha::Template::Plugin::Biblio::HoldsCount
- [35783](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35783) Remove Koha::Template::Plugin::Biblio::RecallsCount
- [35787](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35787) Remove Koha::Template::Plugin::Biblio::CanBook
- [35788](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35788) Remove Koha::Template::Plugin::Biblio::BookingsCount
- [35789](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35789) Remove Koha::Template::Plugin::Biblio::ArticleRequestsActiveCount
- [35790](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35790) Remove Koha::Template::Plugin::Biblio::CanArticleRequest
- [35793](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35793) Remove Koha::Template::Plugin::Cache
- [35907](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35907) Add ability to log all custom report runs with or without query
- [35955](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35955) New CSRF token generated everytime we need one
- [35994](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35994) New acquisition status method to see if biblio record is still in acquisition
- [36017](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36017) Dead code in admin/clone-rules
- [36018](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36018) Improve consistency in Acquisition/Order(s) regarding active/current orders
- [36019](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36019) Dead code in tags/review
- [36051](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36051) Add option to specify SMS::Send driver parameters in a system preference instead of a file
- [36084](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36084) Pass CSRF token to SVC scripts (1/2)
  >The /svc API now requires a CSRF token for stateful requests (i.e. POST/PUT/PATCH/DELETE). Third-party developers should consult the wiki documentation for updated workflows. CSRF tokens are available through the /svc/authentication endpoint.
- [36102](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36102) Protect login forms from CSRF attacks
- [36148](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36148) Move CSRF check code outside of CGI->new
- [36151](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36151) Update leaflet.js to current version

  **Sponsored by** *Geosphere, Austria*
- [36246](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36246) Have a centralized method for submitting a form via a link
- [36328](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36328) C4::Scrubber should allow more HTML tags
- [36374](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36374) Some of our JS files should stay tidy
- [36400](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36400) Centralize {js,ts,vue} formatting config in .prettierrc.js
- [36546](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36546) Bundle API spec to speed up worker startup
  >This change adds a bundled version of the API specification during build time, which requires less processing, which in turn allows Koha to start up faster.
- [36788](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36788) Debian control* updates for new dependencies
- [36792](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36792) Limit POSIX imports

### Authentication

#### Enhancements

- [36503](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36503) Add a plugin hook to modify patrons after authentication
  >This plugin hook allows to change patron data or define the patron based on the authenticated user.

  **Sponsored by** *Karlsruhe Institute of Technology (KIT)*

### Cataloging

#### New features

- [31791](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31791) Add the ability to lock records to prevent modification through the Koha staff interface
  >This feature adds a way to lock records from being manually edited, if their defined source is marked as such.
  >
  >The record source can only be set (so far) when adding records using the API (or a dedicated plugin using the new code). A future enhancement (bug 36372) will allow privileged users to set the record source manually, as well.

  **Sponsored by** *ByWater Solutions*

#### Enhancements

- [30554](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30554) Use XSLT in authority search cataloguing plugin
  >This fixes the authority search cataloguing plugin so that the search results when adding an authority term to a record are customisable when using the AuthorityXSLTResultsDisplay system preference (for both MARC21 and UNIMARC).

  **Sponsored by** *Écoles nationales supérieure d'architecture (ENSA)*
- [32435](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32435) Add resolution types to catalog concerns
  >This enhancement adds a new `TICKET_RESOLUTION` authorized value type. You may use it to optionally add new resolution values to the catalog concerns workflow.
  >

  **Sponsored by** *PTFS Europe*
- [33494](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33494) Catalog concerns - Toggle 'Hide resolved' and 'Show all'

  **Sponsored by** *PTFS Europe*
- [35034](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35034) Add link to the bibliographic records when they are selected for merging
- [35062](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35062) Allow a framework plugin to add class to prevent submit during ajax call
- [35628](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35628) Add optional statuses to catalog concerns
  >This enhancement adds a new `TICKET_STATUS` authorized value type. You may use it to optionally add new statuses to the catalog concerns workflow.
  >

  **Sponsored by** *PTFS Europe*
- [35657](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35657) Add ability to assign tickets to librarians for catalog concerns
  >This enhancement adds to the ability to assign tickets to librarians in the catalog concerns feature.
  >

  **Sponsored by** *PTFS Europe*
- [35768](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35768) Show 'Used in' records link for results in cataloguing authority plugin

  **Sponsored by** *Education Services Australia SCIS*
- [36156](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36156) Don't duplicate selected value when a field or subfield linked to an authorized value is repeated
  >When a field or subfield is linked to a list of authorized values and repeated in the cataloging editor, the selected value was repeated in the copied field. This makes it so the copied field will be empty.
- [36370](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36370) Add ContentWarningField to UNIMARC XSLT
  >This enhancement enables UNIMARC installations to pick a note field to use to store 'Content warnings' about bibliographic records, using the ContentWarningField system preference (added in Koha 23.05 by bug 31123, but only for MARC21 installations).
  >
  >To use this feature, add a tag and subfields to your bibliographic framework(s), and update the ContentWarningField system preference with the tag to use. A 'Content warning:' label will then be displayed in the OPAC and staff interface, on both the detail and results pages.  If a $u subfield for a URL is added, the $a subfield will use this as to create a clickable link. Other subfields will be displayed after the $a subfield.

### Circulation

#### New features

- [6796](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=6796) Overnight checkouts taking into account opening and closing hours
  >This feature adds the ability to set opening and closing hours for your library and for these hours to be considered when calculating due dates for hourly loans. If the due date for an hourly loan falls after the library closes, the library can choose for the due date to be shortened to meet the close time, or extended to meet the open time the next day. This feature adds a new table 'branch_hours' for storing the open and close times per day for each library, and a new system preference 'ConsiderLibraryHoursWhenIssuing' to choose which behaviour should be followed when calculating due dates.

  **Sponsored by** *Auckland University of Technology*, *Catalyst* and *PTFS Europe*
- [29002](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29002) Add ability to book items ahead of time
  >This lays the foundations for item bookings in Koha.
  >
  >An item can be made 'bookable' via the item modification screens; Once at least one item is `bookable`, a new "Place booking" button will appear as an option on the bibliographic record detail page and a "Bookings" tab will be available from the side menu to allow management of bookings.
  >
  >Bookings cannot overlap, and circulation will detect when an item has a booking on it and notify the librarian appropriately.
  >
  >*Note*: There are many further enhancements in the pipeline still to come.

#### Enhancements

- [16122](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16122) Item record needs to keep local use count
  >This patch adds a new separate field for recording local use to the items table. It will be hidden from the holdings table by default but can be made visible using the table configuration settings.
  >
  >This includes a new CLI script to update the `update_localuse_from_statistics.pl` that can be used to set the new items.localuse field with information from the statistics table.
- [27595](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27595) Place holds for patrons on accepted purchase suggestions
  >This patch adds a new system preference “PlaceHoldsOnOrdersFromSuggestions” that allows accepted  suggestions to automatically be put on hold for the suggesting patron as soon as the suggested item is ordered.
  >
  >The default value is “Don't” automatically place a hold when ordering from a suggestion.
  >

  **Sponsored by** *Bedford Public Library*

  **Sponsored by** *Altadena Library District*

  **Sponsored by** *St. Paul's School*
- [27753](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27753) Automate resolution of return claim when checking in an item
  >This patch adds two new system preferences, ‘AutoClaimReturnStatusOnCheckin’ and ‘AutoClaimReturnStatusOnCheckout’, to allow automatic resolution of return claims on checkin and/or on checkout of the item claimed as returned. Both system preferences allow choosing between "Found in library" or "Returned by patron" as reasons for the resolution. The default value for both preferences is empty, meaning automatic resolution on checkin/checkout is turned off by default.
  >

  **Sponsored by** *Altadena Library District*

  **Sponsored by** *Altadena Library District*
- [31671](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31671) Add button to print transfer slips to the 'Transfer items' page
- [33174](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33174) Have better indication when one is cancelling multiple holds on a record
  >This improves the confirmation message when multiple holds are cancelled to include the number of holds to be cancelled.
- [33737](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33737) Add bookings to patron details
  >This enhancement exposes a patron's bookings in their details page in the staff interface.
  >

  **Sponsored by** *PTFS Europe* and *ByWater Solutions*
- [34668](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34668) Notify staff with a pop-up about waiting holds for a patron when checking out
  >This enhancement adds a new system preference, WaitingNotifyAtCheckout, that generates a pop-up in the circulation module alerting staff that the patron they are checking out items to also has holds waiting for them.
- [35813](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35813) When placing a booking, we should feedback successful placements
- [36074](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36074) Make materials specified note easier to customize, part 2
- [36096](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36096) Add ability to select default sort and display length for tables on 'Holds awaiting pickup' page
- [36120](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36120) Add pickup locations to bookings
  >This enhancement adds the requirement to pick a pickup location when placing a booking.

  **Sponsored by** *Cuyahoga County Public Library*
- [36373](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36373) Show existing bookings in datepicker
  >With this change it's possible to see the dates an item is already booked for within the calendar widget when creating a new booking. The booked dates will show with a little blue dot.

### Command-line Utilities

#### Enhancements

- [26831](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26831) Enable librarians to control when unaccepted private list share invites are removed by the cleanup_database.pl cronjob
  >The new `PurgeListShareInvitesOlderThan` system preference enables librarians to control when unaccepted private list share invites are removed from the database.
  >
  >Unaccepted private list share invites will now be removed based on the following prioritised options:
  >
  >- Priority 1. Use DAYS value when the cleanup_database.pl cronjob is run with a --list-invites DAYS parameter specified.
  >
  >- Priority 2. Use the PurgeListShareInvitesOlderThan system preference value.
  >
  >- Priority 3. Use a default of 14 days, if the cleanup_database.pl cronjob is run with a --list-invites parameter missing the DAYS value, AND the PurgeListShareInvitesOlderThan system preference is empty.
  >
  >- Priority 4. Don't remove any unaccepted private list share invites if the cleanup_database.pl cronjob is run without the --list-invites parameter and the PurgeListShareInvitesOlderThan syspref is empty.

  **Sponsored by** *Catalyst*
- [29440](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29440) Refactor/clean up bulkmarcimport.pl
- [31286](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31286) Embed see-from headings into bibliographic records export
  >This adds a new option `--embed_see_from_headings` to the CLI script `export_records.pl`. It allows to include the see-also headings from the linked authority records in the exported bibliographic records.
- [34611](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34611) Add a script for pseudonymizing existing data
  >This adds a new CLI script `pseudonymize_statistics.pl` that will allow to pseudonymize rows in the statistics table before a given date.
- [35169](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35169) Make long overdue patron category options configurable in interface
  >This adds two new system preferences `DefaultLongOverduePatronCategories` and `DefaultLongOverdueSkipPatronCategories` that allow for additional configuration of the `longoverdue.pl` CLI script directly from the staff interface. The settings of the system preferences will be used when the script is called without the corresponding options.
- [35479](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35479) Nightly cronjob for plugins should log the plugins that are being run
- [35653](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35653) Allow the patron import script to log it's output to the action_logs cron logging
- [35836](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35836) search_for_data_inconsistencies.pl - Search for loops in dependencies
- [35954](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35954) Add --status to koha-plack
- [35996](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35996) Add clarification to POD in writeoff_debts.pl
- [36068](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36068) Add maintenance script acq_cancel_obsolete_orders.pl
  >This adds a new CLI script `acq_cancel_obsolete_orders.pl` that allows to clean up older acquisition data with conflicting information on the order status. This will also cancel order lines that are no longer linked to a bibliographic record, but are still considered pending.
- [36309](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36309) create_superlibrarian.pl output could be more helpful
- [36325](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36325) Add option to koha-run-backups/koha-dump, to exclude logs

### Database

#### Enhancements

- [36755](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36755) Increase length of 'code' column in borrower_attribute_types
  >This extends the borrower_attribute_types.code field from varchar(10) to varchar(64). This makes it easier to use also for plugins who might want to use unique prefixes.

### ERM

#### New features

- [34788](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34788) Add the ability to import KBART files to ERM
  >This enhancement to the ERM module allows for importing KBART format files into the system. It also allows to optionally create linked bibliographic records from the provided data.

  **Sponsored by** *UK Health Security Agency*

#### Enhancements

- [36618](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36618) Make creation of bibliographic records optional for ERM local titles
  >Without this patch creating a local title would always create a bibliographic record in the catalog as well. Now this is optional depending on a checkbox. The checkbox is also available when importing local records form a KBART file.

### Fines and fees

#### Enhancements

- [22740](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22740) Automatically change lost status when item is paid for
  >This patch implements two new system preferences, `UpdateItemLostStatusWhenWriteOff` and `UpdateItemLostStatusWhenPaid` that allow you to specify the status to change an item to when the outstanding balance of a lost item is paid or written off. These preferences are tied to the LOST authorised values set.
  >

  **Sponsored by** *Cuyahoga County Public Library*

### Hold requests

#### Enhancements

- [15565](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15565) Place multiple item-level holds at once for the same record
  >Allow borrowers to place multiple item-level holds on a record in the staff interface and OPAC.
  >
  >Item radio buttons are replaced with checkboxes.
  >
  >This feature is enabled/disabled via the system preference "DisplayMultiItemHolds".
- [23208](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23208) Ability to set default ratio in holds ratio report
  >This patch adds the new system preference 'HoldRatioDefault' to allow setting a different default value for the holds ratio report found in Circulation -> Holds -> Hold ratios.
  >The default value for the new system preference is 3.
- [30579](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30579) When placing item level hold, some options that are not used are not disabled
  >This is part of improvements to placing holds from the record page in the staff interface. 
  >
  >It improves the structure of the page to make it clear that the different type of holds ("Hold next available item", "Hold next available item from an item group" (when enabled), and "Hold a specific item") are mutually-exclusive options, including:
  >
  >- Simplifying the hold details section at the start of the page
  >- Putting the information and options for each type of hold in their own selectable section of the page
  >
  >Note: additional improvements to the design were made in bugs 36864 and 36899.
- [31981](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31981) Add classes to each NEEDSCONFIRM message for easier styling in circ/circulation.tt
  >This patch adds a unique class to each "needs confirmation" message shown in circulation. Previously the only selector for any circulation message needing confirmation was #circ_needsconfirmation, so CSS or jQuery targeting only a single specific message was not easy to do.
  >With this patch you can directly target the new unique class selector for the specific message found behind the class element .needsconfirm.
- [34032](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34032) Holds expirationdate left blank if waiting status is reverted

  **Sponsored by** *Koha-Suomi Oy*
- [35432](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35432) Clarify and simplify the workings of MapItemsToHoldRequests
- [35564](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35564) Add home library (homebranch) column to holds queue report
- [35576](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35576) Make the callnumber column easier to customize when viewing the holds queue report
  >This adds the class 'hq-callnumber' to the call number column on the holds queue report. This will allow for easier customization using CSS or jQuery.
- [35727](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35727) Unused code in HoldsQueue::MapItemsToHoldRequests
- [35826](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35826) Optimize building of holds queue based on transport cost matrix
- [36559](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36559) Transport cost matrix update helpers
  >With a lot of columns and rows the transport cost matrix got hard to edit. This patch makes it so that the header column and row are fixed and will always remain visible while editing.

### ILL

#### Enhancements

- [19605](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19605) ILL backends should be pluggable through regular Koha plugins
- [34431](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34431) Distinguish between status and status alias in ILL UI
- [35106](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35106) ILL - Add patron autocomplete to 'Edit request' Patron ID input
- [35107](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35107) ILL - Type disclaimer value and date should be visible under "Request details" in the manage request page
- [35108](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35108) ILL - "Manage request" page is too loaded
  >This enhancement hides option fields that are empty when displaying ILL requests.
- [35151](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35151) Convert ILLModuleCopyrightClearance system preference to additional contents
- [36105](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36105) Add option to filter for "No status alias"

### Installation and upgrade (web-based installer)

#### Enhancements

- [35681](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35681) Add support for colored messages in the output of updatedatabase
  >This enhancement adds support for colored messages for Koha database updates, in both the terminal and browser.
  >
  >These new CSS classes are used:
  >.updatedatabase-report-red  for warnings
  >.updatedatabase-report-green  for ?
  >.updatedatabase-report-yellow  where action is required
  >.updatedatabase-report-blue  for information
  >

  **Sponsored by** *PTFS Europe*

### MARC Authority data support

#### New features

- [13706](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13706) Deduping authorities script (dedup_authorities.pl)
  >This new command line script (misc/maintenance/dedup_authorities.pl) is a tool for helping to automatically remove duplicate authority records.
  >
  >Features:
  >- Choose a method(s) to select which authority record to keep when duplicates are found. Methods include:
  >  . date: keep the most recent authority (based on 005 field)
  >  . used: keep the most used authority
  >  . ppn: PPN (UNIMARC only), keep the authority with a ppn (when some authorities don't have one, based on 009 field)
  >- Use a SQL WHERE statement to limit the authority records checked for deduplication
  >- Check only specified authority types
  >- Increase the level of detail shown using the --verbose option
  >- Changes are only made when the --confirm option is used
  >
  >Examples:
  >- Methods - for the authorities that have a PPN, keep the most recent, and if two (or more) have the same date in 005, keep the most used: --method ppn --method date --method used  
  >- SQL WHERE statement - only look at records with an auth_id less than 5,000: --where="authid < 5000" 
  >- Limit deduplication to specific authority types: --authtypecode PERSO_NAME
  >
  >See the script help for the options available and usage examples (misc/maintenance/dedup_authorities.pl --help).

#### Enhancements

- [29825](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29825) Preview of authority record on edit mode as MARC formatted view
- [30047](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30047) Add a field to auth_header to record main heading as text string
- [35328](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35328) Add a notes pop-up for authority records to authority search results
  >This enhancement makes authority record notes (6xx) more accessible in a special Notes pop-up, available in all authority search result lists.

  **Sponsored by** *Education Services Australia SCIS*
- [35903](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35903) In cataloguing authority plugin using autocomplete should set operator exact after selecting an entry

### MARC Bibliographic data support

#### Enhancements

- [35993](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35993) AddBiblio should add 005 just like ModBiblio updates it
- [36108](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36108) Update MARC21 default framework to Update 37 (December 2023)
  >This enhancement updates the default MARC21 framework for new installations to reflect the changes from Update 37 (December 2023).
  >
  >NOTES:
  >- For existing installations, manually updating the default and other frameworks with the changes is required.
  >- For new installations, only the default framework is updated. Manually updating other frameworks with the changes is required.

### MARC Bibliographic record staging/import

#### Enhancements

- [30349](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30349) Cleanup bulkmarcimport.pl
  >Updates the help info and adds multi-character options where they are missing. (e.g. --help for -h)
- [33418](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33418) Allow setting overlay_framework for connexion imports
- [36247](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36247) MARC21 Addition to relator terms in technical notice 2024-02-27
  >This patch adds the relator code gdv (Game developer) in the list of MARC21 relator terms in Koha.
  >
  >Note: this is added in the installer files. It will not affect existing installations. For existing installations, add the new relator code in Administration > Authorized values > RELTERMS.

### Notices

#### New features

- [29393](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29393) Ability to send emails from patron details page
  >This new feature allows staff with appropriate permissions, `send_messages_to_borrowers`, to email patrons from the patron details pages.
  >
  >Notice templates can be defined, and used for defaults, using the new `Patrons (custom message)` module.
  >

  **Sponsored-by** *Aix-Marseille University*

#### Enhancements

- [12802](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12802) Send notices using several email addresses
  >This enhancement allows libraries to select a list of email address fields to use when sending notices to patrons.
  >
  >The address fields used in the notices are selected using a new system preference, `EmailFieldSelection` - these address fields are then used for the notices when `EmailFieldPrimary` is set to `selected addresses`.

  **Sponsored by** *St Luke's Grammar School & Pymble Ladies' College*
- [18397](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18397) Add recipient/sender information to notices tab in staff interface
  >This enhancement adds `from`, `to` and `cc` addresses to the 'Delivery note' column in the patron's notices table, once the notice is sent.
  >

  **Sponsored by** *PTFS Europe*
- [31627](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31627) Add ability to embed the letter ID in outgoing email notices
  >This enhancement adds two new email headers to notices sent by Koha.
  >
  >`X-Koha-Template-ID` to contain the ID of the template used to generate the notice, and `X-Koha-Message-ID` to contain the ID of the specific message as defined by Koha.
  >
  >This allows staff to easily trace issues with message content back to their source. Headers are not displayed to end users by default, but are easily accessible to support staff.
  >

  **Sponsored by** *ByWater Solutions*
- [33478](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33478) Customise the format of notices when they are printed
  >This implements a style field for each template to allow for advanced CSS customisations of printed notices and slips. There are links to insert selectors as helpers. Styles can be applied for an individual notice or all notices at once.

  **Sponsored by** *Colorado Library Consortium*
- [34854](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34854) Add ability to skip Talking Tech Itiva notifications for a patron if a given field matches a given value
- [35279](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35279) Add fallback for WELCOME notice to allow 'print' when patrons are missing email address
- [35925](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35925) Port default NEW_SUGGESTION, REJECTED, ACCEPTED, and ORDERED notices to Template Toolkit
- [36106](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36106) Port default PREDUE and DUE notices to Template Toolkit
- [36113](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36113) Port default RENEWAL notice to Template Toolkit syntax
- [36125](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36125) Port default HOLD_SLIP notice to Template Toolkit syntax
- [36126](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36126) Port default HOLD notice to Template Toolkit syntax
- [36608](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36608) Port default TO_PROCESS and AVAILABLE notices to Template Toolkit syntax

### OPAC

#### Enhancements

- [19768](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19768) Possibility to choose "Note" tab in OpacSerialDefaultTab
  >This adds an additional option to the `opacSerialDefaultTab` system preference that allows to select the 'Title information' tab as default on serial records in the OPAC.

  **Sponsored by** *Athens County Public Libraries*
- [29948](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29948) Display author information for researchers
  >This enhancement enables the display of authority record information about authors and contributors on OPAC record and authority detail pages.[1]
  >
  >Use the new system preference OPACAuthorIdentifiersAndInformation to configure what information to display, and in what order. (This replaces OPACAuthorIdentifiers, which enabled the display of identifiers from 024$a and 024$2.)
  >
  >Information available for display:
  >- Field of activity (372$a$s$t)
  >- Address (371$a$b$d$e)
  >- Associated group (373$a$s$t$u$v$0)
  >- Electronic mail address (371$m)
  >- Identifiers (024$2$a)[2]
  >- Occupation (374$a$s$t$u$v$0)
  >- Place of birth (370$a)
  >- Place of death (370$b)
  >- URI (371$u)
  >
  >[1] Displayed on the bibliographic record detail page in the holdings section under a new 'Author information' tab; and on the authority record detail page under the 'Author information' heading.
  >
  >[2] Valid codes for author and contributor identifiers to use in the source subfield (024$2) are currently: orcid (ORCID), scopus (ScopusID), loop (Loop ID), rid (Publons ID), and viaf (VIAF ID).

  **Sponsored by** *Orex Digital*
- [34793](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34793) We should ship default 'CookieConsentPopup' data that describes our required cookies
  >This only applies to new installations that select "sample news items" in the web installer.
- [35346](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35346) 'Accept essential cookies' should always appear if CookieConsent is enabled
- [35347](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35347) 'More information' should always display in cookie consent bar
- [35586](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35586) Add the collection to the location column in the OPAC cart
- [35663](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35663) Wording on OPAC privacy page is misleading
- [35689](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35689) Add id and classes to each MARC note in OPAC bibliographic details
  >This enhancement adds id and class attributes to each MARC note in the description tab for the OPAC bibliographic detail page.
  >
  >It adds a unique id for each note (for unique styling of each repeated tag), and a general and unique class for each tag (for consistent styling across the same tag number). An example of the HTML output: 
  >```
  ><p id="marcnote-500-2" class="marcnote marcnote-500">...</p>
  >```
  >Styles can be defined for notes and individual tags in the `OPACUserCSS` system preference - see the test plan for an example.
- [35812](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35812) Should specify canonical URLs to help search indexers
  >This adds a nice canonical URL for search engines to use. It will prevent duplicates with different URL query parameters from getting indexed separately and will also prevent search engine confusion when the search automatically redirects to the detail page for searches with only one result.
- [36138](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36138) Add cancellation reason to the status column on the OPAC hold history page

### Patrons

#### Enhancements

- [25996](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25996) Changes to restrictions should be logged
  >This adds logging of adding, updating and lifting of patron restrictions. It's controlled by the `BorrowersLog` system preference.

  **Sponsored by** *Karlsruhe Institute of Technology (KIT)*
- [26597](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26597) Transfer information from guarantor when adding a guarantor to an existing patron
- [31097](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31097) Patron restriction types should display in staff interface and OPAC
  >This patch allows the display of patron restriction types and expiry dates directly in the checkout area and in the patron details as well as in the OPAC when patron restriction types are in use and also uses a newline for each restriction. Previously only the comment was displayed.
- [32610](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32610) Add ability to specify patron attribute as a date
  >This makes it possible to add patron attribute fields as dates. The field will then display as any other date field including the calendar widget.
- [33703](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33703) Entering dates should be more flexible accepting different entry formats
  >This makes entering dates directly into the date field a bit more flexible by allowing to omit the delimiters ('/' or '-', or '.') for the set date format.
- [34574](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34574) Datatables column dropdown select filter does not have a CSS class
- [34575](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34575) Patron search results: Add a CSS class to patron email to ease customization
- [35316](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35316) Add call number to holds history page
- [35356](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35356) SMS number field shows on moremember.pl even when null
- [35474](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35474) Add icon for protected patrons
- [36204](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36204) Add othernames to the PatronAutoComplete  display

### Plugin architecture

#### Enhancements

- [30897](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30897) Gracefully reload Koha after plugin install/upgrade
  >This fix, (enabled by default for new installations), allows plugins to be installed via the staff interface without the additional need to ask a system administrator to restart your Koha instance.
- [34943](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34943) Add a pre-save plugin hook for biblios
  >This plugin hook allows tweaking bibliographic records right before they are stored on the database.
  >
  >This allows having plugins that add custom/calculated fields, for example.

  **Sponsored by** *Theke Solutions*
- [35331](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35331) Add an ILL table actions plugin hook
- [35568](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35568) Add a plugin hook to allow modification of notices created via GetPreparedLetter
- [36206](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36206) Administrative plugins
  >This adds a new type of administrative plugin that supplements the existing tool and report plugins. When installed, an entry for this plugin will be shown on the administration module start page.

### REST API

#### Enhancements

- [22613](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22613) Add /patrons/patron_id/checkouts endpoints
- [26297](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26297) Add a route to list patron categories
- [33036](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33036) Add route to merge bibliographic records
  >A new endpoint of REST API /biblios to merge two bibliographic records. You need to pass parameters with a JSON file.
  >Complete endpoint: <base_url>/api/v1/biblios/<biblo_id>/merge
  >Parametes of json file:
  >- biblio_id_to_merge (mandatory)
  >- rules (optional)
  >- framework_to_use (optional)
  >- datarecord (optional)
  >More info in the  Swagger/OpenAPI specification of the API.

  **Sponsored by** *Technische Hochschule Wildau*
- [33960](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33960) Add ability to retrieve deleted bibliographic records
- [35353](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35353) Add API endpoint to fetch patron's previous holds
- [35386](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35386) Add ability to configure renewal library when not specified in API request
- [35744](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35744) Implement +strings for GET /patrons/:patron_id
- [35967](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35967) Add /api/v1/patrons/{patron_id}/recalls endpoint to list a patron's recalls

  **Sponsored by** *Auckland University of Technology*
- [36480](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36480) Add GET /libraries/:library_id/desks
  >This enhancement adds an API endpoint for requesting a list of desks for a library. For example: http://127.0.0.1:8080/api/v1/libraries/cpl/desks
- [36481](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36481) Add GET /libraries/:library_id/cash_registers
  >This enhancement adds an API endpoint for requesting a list of cash registers for a library. For example: http://127.0.0.1:8080/api/v1/libraries/cpl/cash_registers
- [36482](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36482) Make it possible to embed desks and cash_registers on /libraries
- [36495](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36495) Add render_resource_not_found() and render_resource_deleted() helpers
- [36565](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36565) Fix API docs inconsistencies

### Reports

#### Enhancements

- [5920](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=5920) Remove HTML from downloaded reports in CSV format
  >When choosing the CSV option of downloading a report from the reports module, any HTML used for creating links etc. will automatically be removed from the exported file.
- [35746](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35746) Multiple selections for parameters used in the IN function
  >This enhancement adds the ability for report runtime parameters to allow selecting multiple options from the list of authorized values.
  >
  >**Usage**: `WHERE branchcode IN <<Select branches|branches:in>>`

  **Sponsored by** *Cape Libraries Automated Materials Sharing*
- [35856](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35856) Runtime parameter modal should provide option of ":all"
  >This patch adds radio checkboxes to the runtime parameter modal menu used in creating SQL reports to allow the runtime parameter to use multiple values ("... in the following list of values") or to allow choosing all values ("... in all the values").
  >Now when you use the modal menu for inserting a runtime parameter while creating an SQL report you can simply click on the radio button for "single parameter only", "include option for all" or "allow multiple selections" after choosing the runtime parameter you want to add.
- [36380](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36380) Filter matches not included in borrowers statistics reports
- [36555](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36555) Add report_id to file name when exporting report results

### SIP2

#### Enhancements

- [25813](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25813) Enhance patron expiration in SIP display
- [36605](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36605) TrackLastPatronActivity for SIP should track both patron status and patron information requests

### Searching

#### Enhancements

- [26654](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26654) Add item number column to item search results and CSV export
- [33134](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33134) Add some missing languages
- [35728](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35728) Add option to NOT redirect to result when search returns only one record
  >This enhancement to catalog searching enables choosing what happens for a single search result (for both the OPAC and staff interface): redirect to the record details page (the current behavour), or show only one result.
  >
  >New system preference RedirectToSoleResult is used to manage this (enabled by default to match Koha's current behaviour).

  **Sponsored by** *Education Services Australia SCIS*
- [36499](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36499) Add last checkout date column to the item search results
- [36545](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36545) Use select2 to improve multi-select in item search
  >This patch modifies all multi-select fields in the item search to use the jQuery select2 framework. Previously selecting multiple values in the item search fields was unintuitive as you had to hold down Ctrl while clicking the next value. In libraries with a high amount of values (e.g. a library with hundreds of different branches or itemtypes), selecting multiple values from the long list was extra difficult and time consuming. Using select2 allows for fast selection of multiple values, better display of the selected values and even allows you to start typing the specific value you are looking for in order to find it much faster than previously possible.

  **Sponsored by** *Karlsruhe Institute of Technology (KIT)*

### Searching - Elasticsearch

#### New features

- [31652](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31652) Add geo-search
  >This lays the groundwork for geographical searching using Elasticsearch 7+. This includes:
  >- New search types for Elasticsearch search mappings to store latitude and longitude values and index them (using values from 034$s and 034$t).
  >- Extending the QueryBuilder to allow for building advanced Elasticsearch queries (for example, geo_distance) that cannot be represented in a simple string query.
  >
  >To use this new feature now in the OPAC, install and enable the HKS3GeoSearch plugin (https://github.com/HKS3/HKS3GeoSearch).

  **Sponsored by** *Geosphere, Austria* and *ZAMG - Zentralanstalt für Meterologie und Geodynamik, Austria*
- [35138](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35138) Enable configuration of facets with Elasticsearch
  >This new feature enables facets for Elasticsearch (and Open Search) to be managed from the search engine configuration page. Prior to this, the facet fields were hard-coded in the codebase.
  >
  >You can add new facets when the search field options for  'Facetable' and 'Searchable' are set to "Yes".

  **Sponsored by** *The Research University in the Helmholtz Association (KIT)*

#### Enhancements

- [20388](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20388) Ability to add search fields from UI
  >This enhancement for Elasticsearch (and Open Search) lets you add search fields using the staff interface (Administration > Catalog > Search engine configuration  (Elasticsearch)). Previously, you needed to edit a YAML file on the server to change the search fields.

  **Sponsored by** *The Research University in the Helmholtz Association (KIT)*
- [34693](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34693) Add 035$a as Other-control-number index in authorities search indexes (MARC21, Elasticsearch)
  >This patch adds 035$a in the default MARC21 Elasticsearch authority indexes. 
  >
  >For existing installations, make sure you reindex with the option -r (reset mappings) to have this information in the index for existing records.
- [35345](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35345) Pass custom SQL to rebuild_elasticsearch.pl to determine which records to index
  >This adds a `--where` parameter to the `rebuild_elasticsearch.pl` script that allows to flexibly select the records for reindexing with SQL. Examples would be the authority type or ranges and lists of biblionumbers and authids.

  **Sponsored by** *HKS3* and *Steiermärkische Landesbibliothek*
- [36396](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36396) Link facet with authorised value category
  >This new feature adds the ability to link an Elasticsearch facet to an authorized value category in order to display a description instead of the code.
  >An example could be a code for the resource type (book, e-journal, database, etc.) if this code is in a local MARC 9xx field. 
  >This feature depends on Bug 35138 - configuration of facets with Elasticsearch.

  **Sponsored by** *The Research University in the Helmholtz Association (KIT)*
- [36574](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36574) Canceled/invalid ISBN not indexed for MARC21
  >This adds a new search index `isbn-all` to the default Elasticsearch search mappings that includes the valid, canceled and invalid ISBNs.
- [36578](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36578) Elasticsearch: publisher-location (pl) index should include field 752 (for old prints) and also support UNIMARC
  >This extends the Elasticsearch default search field mappings to include 752 (MARC21) and 210a, 214a (UNIMARC) in the index for place of publication.
- [36584](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36584) Add fields 520, 561, and 563 (MARC 21) to ES note search field
- [36723](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36723) Add musical presentation to Elasticsearch index mappings

  **Sponsored by** *Education Services Australia SCIS*

### Searching - Zebra

#### Enhancements

- [35621](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35621) Map ÿ to y for searching (Non-ICU)

### Self checkout

#### New features

- [32256](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32256) Self checkout batch mode
  >This new feature allows more than one item to be scanned and processed at once in Koha's self-checkout module. This feature uses the existing BatchCheckouts and BatchCheckoutsValidCategories system preferences to determine if batch checkouts should be allowed.
  >
  >NOTE: The items in the batch are handled one-by-one, so if any item in the batch requires confirmation (for example, to be renewed or returned) or is impossible to check out, the process will stop at that item. Any items earlier in the list will be processed, but any items coming after in the list will be ignored.

  **Sponsored by** *Koha-US*

### Serials

#### Enhancements

- [26567](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26567) Allow to limit subscription search to subscriptions with routing lists
  >This adds a new search option 'Has routing list' to the advanced search in the serials module. It allows to limit the search to subscriptions with linked routing list.
  >

  **Sponsored by** *Bibliotheksservice-Zentrum Baden-Württemberg*
- [32392](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32392) Ability to skip forward serial issues when receiving double (or more) issue
  >This adds a new button to the serial collection page that allows to create a new issue while skipping several issues in between. The skipped issues will not be created. This can help when multiple issues need to be combined into one.

  **Sponsored by** *Bibliotek Mellansjö, Sweden*
- [35646](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35646) Allow using the publication date parts for serial numbering
  >This adds some new placeholders to be used within the numbering pattern of a subscription: {Year}, {Day}, {DayName}, {Month}, {MonthName}. They will be automatically replaced with the corresponding value derived from the publication date of the issue when its received.

### Staff interface

#### Enhancements

- [22567](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22567) Stock rotation manage rotas should show items current and desired locations
- [30623](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30623) Copy permissions from one user to another
  >This enhancement makes it a lot easier to create staff users with similar or identical permission profiles by allowing it to copy the permission settings from one user to another.
- [33568](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33568) Use the REST API to display items on the biblio detail view
  >This enhancement completely rewrites the display of the items table on the bibliographic record detail view.
  >The filtering, ordering and pagination of this table are now done using the REST API endpoint which will fix performance issues for records with many items.
- [35329](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35329) Move patron searches to a modal
  >The patron searches that formerly used a pop-up windows have been moved into a modal. Examples: patron search for routing lists, manager search for suggestions, guarantor search.
- [35389](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35389) Hide 'Transfers to send' on circulation home page when stock rotation is disabled
  >Currently, Transfers to send (on circulation) is only relevant when you enable StockRotation. To lower confusion, we hide the option if you did not enable that pref.
- [35444](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35444) Add easy way to retrieve a logged in user's categorycode
  >This adds a hidden span to the HTML source code of the staff interface that includes the patron category code of the currently logged in staff user.
- [35540](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35540) Separate StaffListsHome block from the table block
- [35582](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35582) Advanced search languages should be listed with selected UI language descriptions shown first if available
- [35707](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35707) Item statuses in the holdings table on biblio details should appear one per line
  >This fixes the display of item status column in the staff interface holdings table for a record. If there is more than one status to display, they are now displayed on separate lines, instead of running together as one continuous line.
- [35810](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35810) Add back to top button to the staff interface
  >This adds a 'back to the top' button to the staff interface, similar to the one in the OPAC, that appears in the bottom right corner when scrolling down on pages.
- [35862](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35862) Display patron search result on the right of the form (modal)
- [36265](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36265) Bigger font-size for headers in staff interface
- [36440](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36440) Add edit buttons for patron flags in attention box

  **Sponsored by** *Gothenburg University Library*
- [36582](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36582) Add option to set library, desk, and register from user menu
- [36663](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36663) Table configuration options on items table don't show in staff interface
- [36760](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36760) Make 'Current assignee' stand out more in ticket details view

### System Administration

#### Enhancements

- [35097](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35097) Use country-list.inc to display choices for UsageStatsCountry preference
- [35919](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35919) Add record sources CRUD
  >This development creates a new entity in Koha, the `record sources`.
  >
  >They will be used to define policies for records based on their source.
- [36510](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36510) Add CircControl information to circulation and fine rules page

### Templates

#### Enhancements

- [25682](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25682) Style transfers interface to match checkin page
- [34082](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34082) Cut some redundancy in OPAC JavaScript string translations
- [34862](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34862) blocking_errors.inc not included everywhere
- [35249](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35249) Use DataTables RowReorder extension instead of tableDND jQuery plugin
- [35260](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35260) Review batch checkout page
- [35362](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35362) Update patron module pop-up windows with consistent footer markup
- [35363](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35363) Update transfer order pop-up window with consistent footer markup
- [35364](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35364) Update serials pop-up windows with consistent footer markup
  >This enhancement updates the style of several serials module templates so that the submission and close buttons are in a fixed footer at the bottom of the pop-up windows, consistent with other pop-up windows.
- [35379](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35379) 'searchfield' parameter name misleading when translating
- [35419](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35419) Update page title for bookings
- [35426](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35426) Improve layout of bookings modal form
- [35511](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35511) Add visual indicators of patron edit form collapsible sections
- [35558](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35558) Do not fetch local image if none exists
- [35850](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35850) Use template wrapper for tabs: Header search forms
- [35877](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35877) Use template wrapper to build Bootstrap accordion components
- [35880](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35880) Use template wrapper for accordions: Patrons requesting modifications
- [35882](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35882) Use template wrapper for accordions: Notices
- [35883](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35883) Use template wrapper for accordions: Table settings administration
- [35895](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35895) Reindent tags review template
- [36472](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36472) Add search box at the top of the authorities editor page
  >This adds the search header to the authorities editor page. With the recent staff interface redesign, this takes up very little space.
- [36671](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36671) Reindent item transfer template (branchtransfers.tt)

### Test Suite

#### Enhancements

- [35548](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35548) Move KitchenSink test on its own and control table creation
- [36486](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36486) Add tests for Koha::DateTime::Format::SQL
- [36593](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36593) Add support for the `time` column type on TestBuilder

### Tools

#### Enhancements

- [25159](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25159) Action logs should be stored in JSON (and as a diff of the change)
  >This is the first step to improve and standardize the way we log information in the action log tables. In order to achieve this a new column `diff` is added to the `action_logs` table. This is used to store a diff of the changes to an object in JSON syntax.
- [35648](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35648) Allow sorting of patron categories in overdue notice/status triggers
- [36443](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36443) Add 'fax' to batch patron modification tool

### Transaction logs

#### Enhancements

- [27291](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27291) Change datetime format in Zebra logs
  >This enhancement changes the Zebra output log time format from the default "hh:mm:ss-DD/MM" to the more standard ISO 8601 "%FT%T".
  >
  >This makes the logs easier to read for both humans and machines. One benefit includes easy searching and sorting.
## Bugfixes
This list includes all bugfixes since the previous major version. Most of them
have already been fixed in maintenance releases


#### Critical bugs fixed

- [35504](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35504) Release team 24.05 (24.05.00,23.11.02,23.05.09)
- [35634](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35634) Permissions mismatch for vendor issues (24.05.00,23.11.02)
- [35892](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35892) Fallback to GetMarcPrice in addorderiso2907 no longer works (24.05.00,23.11.04,23.05.10)
- [35912](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35912) Item prices not populating order form when adding to a basket from a staged file (24.05.00,23.11.03)
- [35913](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35913) Item order prices do not fall back to MarcFieldsToOrder if not set by MarcItemFieldsToOrder (24.05.00,23.11.04)
- [36035](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36035) Form is broken in addorderiso2709.pl (24.05.00,23.11.05,23.05.12)
- [36047](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36047) Apostrophe in suggestion status reason blocks order receipt (24.05.00,23.11.04,23.05.10)
- [36053](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36053) Replacement prices not populating when supplied from MarcItemFieldsToOrder (24.05.00,23.11.05,23.05.12)
- [36233](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36233) Cannot search invoices if too many vendors (24.05.00,23.11.04,23.05.10)
- [24879](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24879) Add missing authentication checks (24.05.00,23.11.04,23.05.10,22.11.16,22.05.20)
- [34478](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34478) Full CSRF protection (24.05.00)
- [35687](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35687) Upgrade to 23.06.00.013 may fail (24.05.00,23.11.02)
- [35819](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35819) "No job found" error for BatchUpdateBiblioHoldsQueue (race condition) (24.05.00,23.11.04,23.05.10)
- [35843](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35843) No such thing as Koha::Exceptions::Exception (24.05.00,23.11.03,23.05.09)
- [35890](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35890) AutoLocation system preference + setting the library IP field - can still login and unexpected results (24.05.00,23.11.03,23.05.09,22.11.15,22.05.19)
- [36149](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36149) userenv stored in plack worker's memory and survive from one request to another (24.05.00,23.11.05,23.05.11,22.11.17,22.05.21)
- [36177](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36177) We need integration tests to cover CSRF checks (24.05.00)
- [36190](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36190) op param for stateful requests must start with 'cud-' (24.05.00)
- [36193](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36193) CSRF - Code review missed (24.05.00)
- [36195](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36195) CSRF - testing reports
- [36244](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36244) Template toolkit syntax not escaped in letter templates (24.05.00,23.11.04,23.05.10,22.11.16,22.05.20)
- [36379](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36379) Authorities search is broken (24.05.00)
- [36665](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36665) Auto location and IP recognition (24.05.00)
  >This patch adds a new system preference "StaffLoginLibraryBasedOnIP" which, when enabled, will set the logged in library to the library with an IP setting matching the current users IP. This preference will be overridden if "AutoLocation" is enabled, as that preference will enforce the user selecting a library that matches their current IP or signing into their home library from the correct IP.
- [36790](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36790) 230600052.pl is failing (24.05.00,23.11.06)
- [36943](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36943) Update .mailmap for 24.05.x release (24.05.00)
- [36034](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36034) cas_ticket is set to serialized patron object in session (24.05.00,23.11.03,23.05.09,22.11.15,22.05.19)
- [36219](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36219) State parameter broken for OIDC/Oauth (24.05.00)
- [36326](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36326) Batch deletion of selected items from detail page is broken (24.05.00)
- [36327](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36327) Items view -  Deletion of items is broken (24.05.00)
- [36336](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36336) Exporting records from detail page is broken (24.05.00)
- [36351](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36351) CSRF Adjustments for Cataloguing editor (24.05.00)
- [36511](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36511) Some scripts missing a dependency following Bug 24879 (24.05.00,23.11.04,23.05.10,22.11.16,22.05.20)
- [36630](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36630) Item search batch operations buttons broken by CRSF (24.05.00)
- [33847](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33847) Database update replaces undefined rules with defaults rather than the value that would be used (24.05.00,23.11.02,23.05.08)
- [35341](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35341) Circulation rule dates are being overwritten (24.05.00,23.11.02,23.05.09)
- [35468](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35468) Bookings permission mismatch (24.05.00,23.11.02)
- [35518](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35518) Call to C4::Context->userenv happens before it's gets populated breaks code logic in circulation (24.05.00,23.11.03,23.05.09)
- [35944](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35944) Bookings is not taken into account in CanBookBeRenewed (24.05.00,23.11.05)
- [36100](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36100) Regression in bookings edit (24.05.00,23.11.04)
- [36175](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36175) Checking out items that are booked doesn't quite work (24.05.00,23.11.04)
- [36313](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36313) Check out/check in leads to error 500 in staff interface (24.05.00,23.11.06,23.05.12)

  **Sponsored by** *Koha-Suomi Oy*
- [36331](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36331) Items that cannot be held are prevented renewal when there are holds on the record (24.05.00,23.11.05,23.05.12)
- [36418](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36418) Set response's content-type to application/json when needed - svc scripts (24.05.00)
- [36426](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36426) Cannot set article request as pending (24.05.00)
- [36708](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36708) Problems editing circ rules when 'Holds allowed (total)' value is greater than or equal to 0 (24.05.00,23.11.06,23.05.12)
- [36859](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36859) Batch checkout not working due to mismatch in CSRF parameter names (24.05.00)
- [36946](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36946) Can't process pending offline circulations (24.05.00)
- [36508](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36508) Patron userid field can be overwritten by update_patron_categories when limiting by fines (24.05.00,23.11.06,23.05.12)
- [34972](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34972) Canceling a waiting hold from the holds over tab can make the next hold unfillable (24.05.00,23.11.06,23.05.12)
- [35322](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35322) AllowItemsOnHoldCheckoutSCO and AllowItemsOnHoldCheckoutSIP do not work (24.05.00,23.11.02,23.05.09)
- [35489](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35489) Holds on items with no barcode are missing an input for itemnumber (24.05.00,23.11.02,23.05.08)
- [36735](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36735) Cannot revert the waiting status of a hold (24.05.00)
- [33237](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33237) If TranslateNotices is off, us the default language includes in slips (24.05.00)
  >This patch set cleans up the way languages are chosen and used in includes when printing slips. Previously, if the system preference 'TranslateNotices' was turned off (meaning the patron had their language set to 'Default'), the includes texts would be in English, even if the library had written their notices in a different language e.g. French.
  >
  >With this patch set, the language used for includes will always match the language used for creating the notice itself, regardless of whether 'TranslateNotices' is turned on or off.
  >
  >This patch set also makes important changes to the logic used to set the language. With this patch, the notice will:
  >1. use patron's preferred language
  >2. if patron's preferred language is 'default', use the first language in 'language' system preference.
  >
  >This patch set also adds the display of 'Default language' to the language that will be marked as 'Default' in the notices editor tool so that the librarian writing a notice will know exactly which language will be used when printing slips.
  >
  >Please note that due to these changes it is no longer possible to print the slip in any installed language simply by switching the staff interface language before printing! Bug 36733 has been added as a follow-up for restoring this functionality.
- [36876](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36876) In table settings words are split in two and some of them cannot be translated properly (24.05.00)
- [36241](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36241) ILL Batches are broken (24.05.00)
- [36243](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36243) ILL "Edit request" action is broken (24.05.00)
- [36245](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36245) ILL - Custom backend form action is broken (24.05.00)
- [36249](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36249) ILL - "Request from partners" action is broken (24.05.00)
- [36904](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36904) ILL error when searching from table search input (24.05.00)
- [34516](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34516) Upgrade database fails for 22.11.07.003, points to web installer (24.05.00,23.11.01,23.05.07)
- [35473](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35473) Core bookings and room reservations plugin tables clash (24.05.00,23.11.04)
- [36232](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36232) Error fixing OAI-PMH:AutoUpdateSetsEmbedItemData syspref name on the DB (24.05.00,23.11.04)
- [36832](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36832) Adding authority records is broken (24.05.00,23.11.06,23.05.12)
- [31427](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31427) Automatic renewal errors should come before many other renewal errors (24.05.00,23.11.04)
- [34886](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34886) Regression in when hold button appears (24.05.00,23.11.05,23.05.12)
- [35348](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35348) Cookie information should be available regardless of whether you are logged in or not (24.05.00)
- [36274](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36274) OPAC suggestions form doesn't display (24.05.00)
- [36883](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36883) Can't finish club enrollment in the OPAC (24.05.00)
- [35614](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35614) Update cpanfile for Mojolicious::Plugin::OpenAPI v5.09 (24.05.00)
- [30645](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30645) Generated DBIC query incorrect for API searches across joined extended attributes when several terms are passed (24.05.00)
  >This fixes patron searching where there are multiple patron attributes - all patron attributes are now searched. Before this, if your search included values from multiple patron attributes, no results would be found. Example: if you have two patron attributes with the value 'abc' in one and '123' in another, searching for either one worked as expected, but no results would be found searching for 'abc 123'.
- [33832](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33832) Can't change a patron's username without entering passwords (24.05.00,23.11.06,23.05.12)
- [34479](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34479) Clear saved patron search selections after certain actions (24.05.00,23.11.03,23.05.09)
  >This fixes issues with patron search, and remembering the patrons selected after performing an action (such as Add to patron list, Merge selected patrons, Batch patron modification). Remembering selected patrons was introduced in Koha 22.11, bug 29971.
  >
  >Previously, the patrons selected after running an action were kept, and this either caused confusion, or could result in data loss if other actions were taken with new searches.
  >
  >Now, after performing a search and taking one of the actions available, you are now prompted with "Keep patrons selected for a new operation". When you return to the patron search:
  >- If the patrons are kept: those patrons should still be selected
  >- If the patrons aren't kept: the patron selection history is empty and no patrons are selected
- [35796](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35796) Patron password expiration date lost when patron edited by superlibrarian (24.05.00,23.11.04,23.05.10)
- [35980](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35980) Add message to patron needs permission check (24.05.00,23.11.05)
- [36368](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36368) Cannot save new patron after error (24.05.00)

  **Sponsored by** *Koha-Suomi Oy*
- [35930](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35930) ILL module broken if plugins disabled (24.05.00,23.11.03)
- [35759](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35759) Preservation module home yields a blank page (24.05.00,23.11.02)
- [35204](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35204) REST API: POST endpoint /auth/password/validation dies on patron with expired password (24.05.00,23.11.02,23.05.08)
- [35658](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35658) Typo in /patrons/:patron_id/holds (24.05.00,23.11.02,23.05.08)
- [36612](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36612) The public tickets endpoint needs public fields list (24.05.00,23.11.06,23.05.12)
- [31988](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31988) manager.pl is only user for "Catalog by item type" report (24.05.00,23.11.04,23.05.10,22.11.16,22.05.20)
- [36568](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36568) Changing rows per page on a custom report is broken (24.05.00)
- [36308](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36308) SIP2 login broken by CSRF changes (24.05.00)
- [36563](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36563) Item search does not search for multiple values (24.05.00,23.11.06,23.05.12)
- [36349](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36349) Login for SCO/SCI broken  by CSRF (24.05.00)
- [35935](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35935) Wrong branch picked after an incorrect login (24.05.00,23.11.04,23.05.10)
- [36234](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36234) Language prefs cannot be modified (24.05.00)
- [36302](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36302) Patron search from search bar broken (24.05.00)
- [36447](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36447) Circ rules slow to load when many itemtypes and categories (24.05.00,23.11.05)
- [36577](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36577) (bug 34478 follow-up) marc21_linking_section.pl not working (24.05.00)
- [36700](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36700) CSRF: Cannot save a systempreference (when nginx drops the CSRF header with an underscore) (24.05.00)
- [35460](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35460) Unable to add or edit hold rules in circulation rules table (24.05.00,23.11.01)

  **Sponsored by** *Koha-Suomi Oy*
- [36235](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36235) System preferences chopping everything after a semicolon. (24.05.00)
- [36597](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36597) Cannot delete circulation desk (24.05.00)
- [36332](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36332) JS error on moremember (24.05.00,23.11.04,23.05.10)
- [36844](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36844) Set library, desk, and cash register menu follow-ups (24.05.00)
- [35922](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35922) t/db_dependent/www/batch.t is failing (24.05.00,23.11.03,23.05.10)
- [36356](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36356) FrameworkPlugin.t does not rollback properly (24.05.00,23.11.04,23.05.12)
- [36535](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36535) 33568 introduced too many changes in modules without tests (24.05.00)
- [35696](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35696) Transit status not properly updated for items advanced in Stock Rotation tool (24.05.00,23.11.02,23.05.08)
- [36159](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36159) Patron imports record a change for non-text columns that are not in the import file (24.05.00,23.11.05)
- [36838](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36838) Can't approve or reject tags in the staff interface (24.05.00)
- [36877](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36877) Patron card creator does not work when editing layout, profile or template (24.05.00)
- [34893](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34893) ILS-DI can return the wrong patron for AuthenticatePatron (24.05.00,23.11.02,23.05.08,22.11.14,22.05.18)
- [35428](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35428) gulp po tasks do not clean temporary files (24.05.00,23.11.02,23.05.08)

#### Other bugs fixed

- [35584](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35584) Missing licenses in about page (24.05.00,23.11.02)
- [36134](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36134) Elasticsearch authentication using userinfo parameter crashes about.pl (24.05.00,23.11.04,23.05.10)
- [34647](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34647) name attribute is obsolete in anchor tag (24.05.00,23.11.03,23.05.09)
- [35157](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35157) The searchfieldstype select element produces invalid HTML (24.05.00,23.11.01)
- [35894](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35894) Duplicate link in booksellers.tt (24.05.00,23.11.03,23.05.09)
- [36140](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36140) Wrong for attribute on Invoice number: label in invoice.tt (24.05.00,23.11.04,23.05.10)
- [30598](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30598) Replacement cost is not copied from retail price when ordering from file (24.05.00,23.11.06)
- [32132](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32132) Missing budget_period_id in aqbudgets kills lateorders.pl (24.05.00)

  **Sponsored by** *Koha-Suomi Oy*
- [33457](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33457) Improve display of fund users when the patron has no firstname (24.05.00,23.11.03,23.05.09)
- [34853](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34853) Move EDI link to new line in invoice column of acquisition details display (24.05.00,23.11.03)
- [34963](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34963) Unable to delete fields in suggestions (24.05.00,23.11.06)
- [35398](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35398) EDI: Fix support for LRP (Library Rotation Plan) for Koha with Stock Rotation enabled (24.05.00,23.11.04,23.05.10)
- [35514](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35514) New order line form: Total prices not updated when adding multiple items (24.05.00,23.11.03)
- [35911](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35911) Archived suggestions show in patron's account (24.05.00,23.11.04,23.05.10)
  >This fixes an unintended change introduced in Koha 22.11. Archived suggestions are now no longer shown on the patron's account page in the staff interface.
- [35916](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35916) Purchase suggestions bibliographic filter should be a "contains" search (24.05.00,23.11.04)
- [35927](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35927) Selecting MARC framework again doesn't work when adding to basket from an external source (24.05.00)
- [36002](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36002) Get rid of aqorders.purchaseordernumber (24.05.00)
- [36030](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36030) Do not show "Place hold" for deleted biblio record on basket page (24.05.00,23.11.06)
- [36036](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36036) Fix location field when ordering from staged files (24.05.00,23.11.05,23.05.12)
- [36122](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36122) NEW_SUGGESTION is sent for every modification to the suggestion (24.05.00,23.11.06)
- [36173](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36173) Cancelling order confirmation view does not show basket's info (24.05.00,23.11.06)
  >This fixes the breadcrumb links on the confirmation page when cancelling an order (from the receiving screen).
- [36187](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36187) Cannot set suggestedby when adding/editing a suggestion from the staff interface (24.05.00)
- [36442](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36442) Fix typo in EDIFACT list (24.05.00)

  **Sponsored by** *Gothenburg University Library*
- [36620](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36620) Broken order management for suggestions with quantity (24.05.00)

  **Sponsored by** *Ignatianum University in Cracow*
- [36635](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36635) Cannot display vendor's issue (24.05.00)
- [36739](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36739) Unable to delete a budget (24.05.00)
- [36856](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36856) New order from existing bibliographic record does not show MARC subfield name (24.05.00)
- [25539](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25539) Remove AddBiblio "defer_marc_save" option (24.05.00)
- [26176](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26176) AutoLocation is badly named (24.05.00)
- [30068](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30068) Wrong reference to table_borrowers in circulation.tt (24.05.00,23.11.06)
- [33898](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33898) background_jobs_worker.pl may leave defunct children processes for extended periods of time (24.05.00,23.11.04,23.05.10)
- [34360](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34360) [WARN] DBIx::Class::ResultSetColumn::new(): Attempting to retrieve non-unique column 'biblionumber' on a resultset containing one-to-many joins will return duplicate results (24.05.00,23.11.06)
- [34913](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34913) Upgrade DataTables from 1.10.18 to 1.13.6 (24.05.00,23.11.02,23.05.10)
- [34999](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34999) REST API: Public routes should respect OPACMaintenance (24.05.00,23.11.02,23.05.09)
  >This report ensures that if OPACMaintenance is set, public API calls are blocked with an UnderMaintenance exception.
- [35248](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35248) Bookings needs unit tests (24.05.00,23.11.04)
- [35277](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35277) Pseudonymization should be done in a background job (24.05.00,23.11.03)
- [35309](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35309) Remove DT's fnSetFilteringDelay (24.05.00,23.11.02,23.05.08)
- [35405](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35405) MarcAuthorities: Use of uninitialized value $tag in hash element at MARC/Record.pm line 202. (24.05.00,23.11.02,23.05.08)
- [35491](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35491) Reverting waiting status for holds is not logged (24.05.00,23.11.02,23.05.08)
- [35610](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35610) Missing FK on old_reserves.branchcode (24.05.00,23.11.06)
  >Add a foreign key on the old_reserves.branchcode database column. This link was missing and the column may contain incorrect data/branchcode.
  >Note that the values will now be set to NULL when the branchcode is incorrect.
- [35629](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35629) Redundant code in includes/patron-search.inc (24.05.00,23.11.02,23.05.08)
- [35701](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35701) Cannot use i18n.inc from memberentrygen (24.05.00,23.11.03,23.05.09)
- [35702](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35702) Reduce DB calls when performing authorities merge (24.05.00,23.11.02,23.05.09)
- [35718](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35718) Remove ES6 warnings from JavaScript system preferences (24.05.00,23.11.04)
  >This removes some warnings when entering JavaScript in UserJS system preferences and library specific OPAC JS, when using ECMAScript 6 features/syntax.
- [35833](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35833) Fix few noisy warnings from C4/Koha and search (24.05.00,23.11.03)
- [35835](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35835) Fix shebang for cataloguing/ysearch.pl (24.05.00,23.11.03,23.05.09)
- [35918](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35918) Incorrect library used when AutoLocation configured using the same IP (24.05.00,23.11.03,23.05.09,22.11.15,22.05.19)
- [35921](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35921) Improve performance of acquisitions start page when there are many budgets (24.05.00,23.11.04,23.05.12)
- [35950](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35950) Move the handling of statistics patron logic out of CanBookBeIssued (24.05.00,23.11.04)
- [35960](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35960) XSS in staff login form (24.05.00,23.11.04,23.05.10,22.11.16,22.05.20)
- [35979](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35979) Possible RealTimeHoldsQueue check missing in modrequest.pl for BatchUpdateBiblioHoldsQueue background job (24.05.00,23.11.06)
- [36000](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36000) Fix CGI::param called in list context from catalogue/search.pl (24.05.00,23.11.04,23.05.10)
- [36031](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36031) Get rid of (outdated) misc/bin/set-selinux-labels.sh (24.05.00)
- [36056](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36056) Clarify subpermissions check behavior in C4::Auth (24.05.00,23.11.04,23.05.10)
- [36088](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36088) Remove useless code form opac-account-pay.pl (24.05.00,23.11.04,23.05.10)
- [36092](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36092) sessionID not passed to the template on auth.tt (24.05.00,23.11.03,23.05.09)
- [36170](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36170) Wrong warning in memberentry (24.05.00,23.11.04)
- [36212](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36212) transferbook should not look for items without barcode (24.05.00,23.11.04,23.05.10)
- [36307](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36307) SMS::Send driver errors are not captured and stored (24.05.00,23.11.06)
- [36322](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36322) Can run docs/**/*.pl from the UI (24.05.00,23.11.04,23.05.10,22.11.16,22.05.20)
- [36323](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36323) koha_perl_deps.pl can be run from the UI (24.05.00,23.11.04,23.05.10,22.11.16,22.05.20)
- [36378](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36378) Cannot stay logged in if AutoLocation is enabled but library's IP address is not set correctly (24.05.00)
- [36386](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36386) Prevent Net::Server warn about User Not Defined from SIPServer (24.05.00,23.11.06)
- [36395](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36395) Useless fetch of AV categories in admin/marc_subfields_structure.pl (24.05.00,23.11.06)

  **Sponsored by** *The Research University in the Helmholtz Association (KIT)*
- [36432](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36432) Remove circular dependency from Koha::Object (24.05.00,23.11.06)
- [36438](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36438) MARCdetail: Can't call method "metadata" on an undefined value (24.05.00,23.11.06)
- [36463](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36463) We should compress our JSON responses (gzip deflate mod_deflate application/json) (24.05.00,23.11.06)
- [36473](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36473) updatetotalissues.pl should not die on a bad record (24.05.00,23.11.06)
  >This fixes the misc/cronjobs/update_totalissues.pl script so that it skips records with invalid data, instead of just stopping. (This also means that the 'Most-circulated items' report now shows the correct data - if the script stopped because of invalid records, the report may have not picked up circulated items.)
- [36521](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36521) Checkbox preferences should be allowed to be submitted empty (24.05.00)
- [36526](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36526) Remove circular dependency from Koha::Objects (24.05.00,23.11.06)
- [36531](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36531) Koha should serve text/javascript compressed, like application/javascript is (24.05.00,22.11.06)
- [36634](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36634) tools/automatic_item_modification_by_age.pl use cud-show instead of show (24.05.00)
- [36639](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36639) CSRF: Fix deleting authority from authority detail page (24.05.00)
- [36774](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36774) Flatpickr clear() adds unintentional clear button (24.05.00,23.11.06)
- [36793](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36793) Local preferences should not stay in the cache when they are deleted (24.05.00)
- [36858](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36858) Crash on wrong page number in opac-shelves (24.05.00)
- [36914](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36914) DBIx::Class warning from shelves.pl (24.05.00)
- [29930](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29930) 'cardnumber' overwritten with userid when not mapped (LDAP auth) (24.05.00,23.11.03,23.05.09)
- [36098](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36098) Create Koha::Session module (24.05.00,23.11.04,23.05.10,22.11.16)
- [36908](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36908) Clarify and standardize the behavior of AutoLocation/ StaffLoginBranchBasedOnIP system preferences (24.05.00)
- [24424](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24424) Advanced editor - interface hangs as "Loading" when given an invalid bib number (24.05.00)

  **Sponsored by** *Ignatianum University in Cracow*
- [27363](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27363) Restore temporary selection of Z39.50 targets throughout multiple searches (24.05.00,23.11.06)
- [27893](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27893) Deleting a bibliographic record should warn about attached acquisition orders and cancel them (24.05.00)
- [29522](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29522) Bib record not correctly updated when merging identical authorities with LinkerModule set to First Match (24.05.00,23.11.04,23.05.10)
- [32029](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32029) Automatic item modifications by age missing biblio table (24.05.00,23.11.04,23.05.10)
- [33639](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33639) Adding item to item group from 'Add item' screen doesn't work (24.05.00,23.11.02,23.05.09)
  >This fixes adding a new item to an item group (when using the item groups feature - EnableItemGroups system preference). before this fix, even if you selected an item group, it was not added to it.
- [34234](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34234) Item groups dropdown in detail page modal does not respect display order (24.05.00,23.11.04,23.05.10)
- [35383](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35383) Dragging and dropping subfield of repeated tags doesn't work (24.05.00,23.11.01)
- [35414](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35414) Silence warn related to number_of_copies (24.05.00,23.11.01,23.05.07)
- [35425](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35425) Sortable prevents mouse selection of text inside child input/textarea elements (24.05.00,23.11.01)
- [35441](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35441) Typo 'UniqueItemsFields' system preference (24.05.00,23.11.01,23.05.07)
- [35554](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35554) Authority search popup is only 700px (24.05.00,23.11.04,23.05.10)
- [35651](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35651) Toggle for advanced editor should not show to staff without advanced_editor permissions (24.05.00,23.11.02)
  >This fixes the display of the button to access the advanced editor. It now only displays when the staff patron has the correct permissions ("Use the advanced cataloging editor (requires edit_catalogue)").
- [35695](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35695) Remove useless item group code from cataloging_additem.js (24.05.00,23.11.03,23.05.09)
- [35774](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35774) add_item_to_item_group additem.pl should be $item->itemnumber instead of biblioitemnumber (24.05.00,23.11.03,23.05.09)
- [35963](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35963) Problem using some filters in the bundled items table (24.05.00,23.11.04,23.05.10)
- [36461](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36461) Advanced editor should disable RequireJS timeout with waitSeconds: 0 (24.05.00,23.11.06)
- [36552](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36552) Update record 'date entered on file' when duplicating a record (24.05.00,23.11.06)
- [36589](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36589) Advanced cataloging - restore the correct height of the clipboard (24.05.00)
- [36756](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36756) Fix default action on split update button when editing tickets/catalog concerns (24.05.00)
- [36757](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36757) Add assignee to catalog concern/ticket detail view when opened from catalog detail page (24.05.00)
- [36786](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36786) (Bug 31791 follow-up) Koha explodes when trying to edit a bibliographic record with an invalid biblionumber (24.05.00)

  **Sponsored by** *Ignatianum University in Cracow*
- [36794](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36794) Illegitimate modification of biblionumber subfield content (999 $c) (24.05.00)

  **Sponsored by** *Ignatianum University in Cracow*
- [8461](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8461) Block returns of withdrawn items show as 'not checked out' (24.05.00,23.11.06)
- [18139](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18139) 'Too many checked out' can confuse librarians (24.05.00,23.11.02)
- [18885](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18885) When 'on-site checkout' was used, the 'Specify due date' should be emptied for next checkout unless OnSiteCheckoutAutoCheck (24.05.00,23.11.06)
- [30230](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30230) Search for patrons in checkout should not require edit_borrowers permission (24.05.00,23.11.03)
- [30324](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30324) Parent and child itemtype checkout limits not enforced as expected (24.05.00,23.11.06)
- [34263](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34263) Suspending holds consecutively populates previously used date falsely (24.05.00)
- [35149](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35149) Add "do nothing" option to CircAutoPrintQuickSlip system preference (24.05.00)
- [35216](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35216) Use return variable names from CanBookBeIssued in circulation.pl for consistency (24.05.00,23.11.02)
- [35310](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35310) Current renewals 'view' link doesnt work if renewals correspond to an item no longer checked out (24.05.00,23.11.02,23.05.08)
  >This fixes the current renewals information (shown under the statuses section) on the item page for records in the staff interface so that:
  >1. The current renewals row is only now shown if there are current renewals for the item (previously it was shown for all items, even if they had no renewals).
  >2. It only shows the number of current renewals for the current check out (previously the number shown would include all renewals, including for previous check-outs).
- [35357](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35357) Item not removed from holds queue when checked out to a different patron (24.05.00,23.11.04)
- [35360](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35360) Inconsistent use/look of 'Cancel hold(s)' button on circ/waitingreserves.pl (24.05.00,23.11.03,23.05.09)
- [35469](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35469) Cannot create bookings without circulation permissions (24.05.00,23.11.04)
- [35483](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35483) Restore item level to record level hold switch in hold table (24.05.00,23.11.03)
- [35532](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35532) Use of calendar for date range in bookings is not clear (24.05.00,23.11.04)
  >This updates the bookings feature to make selecting the booking period clearer:
  >- Changes field label from 'Period' to 'Booking dates'
  >- Adds a hint added to indicate that you need to select a start and end date ('Select the booking start and end date')
  >- Removes the date shortcut options from the date picker, as they do not make sense for bookings
- [35535](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35535) Cancel hold -button does not work in pop-up (Hold found, item is already waiting) (24.05.00,23.11.03)
- [35587](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35587) Items lose their lost status when check-in triggers a transfer even though BlockReturnOfLostItems is enabled (24.05.00,23.11.02,23.05.08)

  **Sponsored by** *Pymble Ladies' College*
- [35600](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35600) Prevent checkouts table to flicker (24.05.00,23.11.02,23.05.08)
- [35773](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35773) Cannot create bookings without edit_borrowers, label_creator, routing or order_manage permissions (24.05.00,23.11.04)
- [35840](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35840) Local use is double-counted when using both RecordLocalUseOnReturn and statistical patrons (24.05.00,23.11.04)
- [35924](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35924) The 'checkin slip' button should not be available for patrons whose privacy is set to never (24.05.00,23.11.04)
- [35983](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35983) Library specific refund lost item replacement fee cannot be 'refund_unpaid' (24.05.00,23.11.04,23.05.10)
- [36060](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36060) If issues table includes overdues 'Renew selected items' button is disabled (24.05.00)
- [36091](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36091) Spelling: Use "card number" instead of cardnumber in text (24.05.00,23.11.04)
- [36139](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36139) Bug 35518 follow-up: fix AutoSwitchPatron (24.05.00,23.11.05)
  >This fixes an issue when the AutoSwitchPatron system preference is enabled (the issue was caused by bug 35518 - added to Koha 24.05.00, 23.11.03, and 23.05.09).
  >
  >If you went to check out an item to a patron, and then entered another patron's card number in the item bar code, it was correctly:
  >- switching to that patron 
  >- showing a message to say that the patron was switched.
  >
  >However, it was also incorrectly showing a "Barcode not found" message - this is now fixed, and is no longer displayed.
- [36347](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36347) Return claims table is loaded twice (24.05.00,23.11.06)
- [36393](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36393) Renewal with a specific date does not take the new date due that we pick (24.05.00,23.11.06)
- [36494](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36494) Flatpickr error on checkout page if the patron is blocked from checking out (24.05.00,23.11.06)
- [36581](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36581) Checkouts table on patron account won't load if any of the items have item notes (24.05.00)
- [36614](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36614) Reinstate phone column in patron search (24.05.00,23.11.06)
- [36619](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36619) Cannot show/hide columns on the patron search table when placing a hold (24.05.00)
- [30627](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30627) koha-run-backups delete the backup files after finished its job without caring days option (24.05.00,23.11.03,23.05.09)
- [34091](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34091) Typo in help for cleanupdatabase.pl: --log-modules  needs to be --log-module (24.05.00,23.11.01,23.05.07)
- [35373](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35373) Remove comment about bug 8000 in gather_print_notices.pl (24.05.00,23.11.03,23.05.09)
- [35596](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35596) Error in writeoff_debts documentation (24.05.00,23.11.03,23.05.09)
- [36009](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36009) Document koha-worker --queue elastic_index (24.05.00,23.11.04,23.05.10)
- [36517](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36517) Fix output from install_plugins.pl (24.05.00,23.11.06)
- [36709](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36709) Add --confirm flag to update_localuse_from_statistics.pl script (24.05.00)
- [36787](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36787) staticfines.pl missing use Koha::DateUtils::output_pref (24.05.00,23.11.06)
- [36033](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36033) Table pseudonymized_transactions needs more indexes (24.05.00,23.11.06,23.05.12)
- [36687](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36687) itemtypes.notforloan should be tinyint and NOT NULL (24.05.00,23.11.06)
- [35354](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35354) Update emailLibrarianWhenHoldisPlaced system preference description (24.05.00,23.11.03,23.05.09)
- [35392](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35392) HTML in translatable string (24.05.00,23.11.06)
- [35408](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35408) ERM > Titles > Import from a list gives an invalid link to the import job (24.05.00,23.11.01,23.05.07)
- [35757](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35757) Sushi service and counter registry tests are failing (24.05.00,23.11.02)
- [36093](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36093) Fix missing array reference in provider rollup reports (24.05.00,23.11.06)
- [36392](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36392) Only 20 vendors in ERM dropdown (24.05.00,23.11.06)
  >This fixes the listing of vendors when adding a new agreement in the electronic resources (ERM) module. Previously only the first 20 vendors were displayed, now all vendors are displayed.
- [36623](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36623) Remove localhost reference from counter logs page (24.05.00,23.11.06)
- [36827](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36827) Tabs in the ERM module have a gap above the tab content (24.05.00)
- [36828](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36828) Remove unnecessary code from UsageStatisticsReportsHome.vue (24.05.00)
- [32565](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32565) Holds placed when all libraries are closed do not get added to holds queue if HoldsQueueSkipClosed and RealTimeHoldsQueue are enabled (24.05.00,23.11.06)
  >This patch set adds a new option "--unallocated" to the build_holds_queue.pl cronjob.
  >
  >This option prevents deletion of the existing queue, and looks for new unassigned holds that may be mapped to available items.
  >
  >There are two intended uses for the option, depending on whether the 'RealTimeHoldsQueue' (RTHQ) system preference is enabled or not.
  >
  >Without RTHQ libraries who want a more static holds queue during the day can run an hourly 'unallocated' cronjob. This will add new holds to the queue as they come in, but allow libraries longer to fill the holds in their existing queue before they move on. The recommendation would then be a nightly full run to rebuild the queue entirely.
  >
  >With RTHQ, libraries could run a nightly 'unallocated' cron to select holds for libraries that were not open on the previous day, and to select holds that have been unsuspended by another cronjob.
  >
  >Current setups will continue to function as before with no change, but libraries may wish to review their options after this upgrade.
- [34823](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34823) Do not show item group drop-down if there are no item groups (24.05.00)
- [35394](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35394) Correct the message displayed when attempting to checkout an item during it's booking period (24.05.00,23.11.06)
  >This fixes the logic and message displayed if you try to check out an item where there is a booking. Now you cannot check out an item where there is a booking, and the message displayed is: "The item is booked for another patron".
- [35559](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35559) Can't change the pickup date of holds on the last day of expiration (24.05.00,23.11.06)
- [35573](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35573) Koha is not correctly warning of overridden items when placing a hold if AllowHoldPolicyOverride (24.05.00,23.11.06)
- [35977](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35977) Display current date in hold starts on when placing a hold in the OPAC (24.05.00,23.11.06)
- [35997](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35997) Cancelling a hold should remove the hold from the queue (24.05.00,23.11.04)
- [36103](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36103) Remove the "Cancel hold" link for item level holds (24.05.00,23.11.04,23.05.10)
- [36137](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36137) update_totalissues.pl should always skip_holds_queue (24.05.00,23.11.06)
- [36227](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36227) No warning if placing hold on item group with no items (24.05.00,23.11.06)
- [36439](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36439) Column settings are missing on holds-to-pull table (24.05.00,23.11.06)
- [36775](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36775) Option to place multiple holds on single bib should not be hidden when holds per record is unlimited (24.05.00)
- [36797](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36797) Record with 1000+ holds and unique priorities causes a 500 error (24.05.00)
- [36864](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36864) Further improvements to holds request page (24.05.00)
  >This is part of improvements to placing holds from the record page in the staff interface.
  >
  >It adds a tick icon with a green background to the section selected (either 'Hold next available item' or 'Hold a specific item').
  >
  >It prevents selecting drop down lists in the section not selected.
- [36899](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36899) Further improvements to holds request page, part 2 (24.05.00)
  >This is part of improvements to placing holds from the record page in the staff interface. When selecting 'Hold next available item', 'Hold next available item from an item group' (when item groups enabled), or 'Hold a specific item' you can now select anywhere on that section of the page, instead of having to select the radio button beside each heading.
- [34900](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34900) The translation of the string "The " should depend on context (24.05.00,23.11.02,23.05.08)
- [35376](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35376) Rephrase: Be careful removing attribute to this processing, the items using it will be impacted as well! (24.05.00,23.11.01)
- [35475](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35475) Untranslatable strings in booking modal and JS (24.05.00,23.11.02)
- [35476](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35476) Submit button for adding new processings is not translatable (24.05.00,23.11.02)
  >This fixes some submit buttons in the ERM and Preservation modules so that are now translatable.
- [35531](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35531) Add context for translation of gender option "Other" (24.05.00,23.11.06)
- [35567](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35567) Host-item in "Show analytics" link can be translated (24.05.00,23.11.02,23.05.08)
- [36516](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36516) translation script could output useless warning (24.05.00,23.11.06)
- [36837](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36837) XSLT CSS classes offered for translations (24.05.00)
- [36845](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36845) Exclude meta tag from the translations (24.05.00)
- [36872](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36872) Untranslatable "Please make sure all selected titles have a pickup location set" (24.05.00)
- [34282](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34282) ILL batches - availability checking has issues (24.05.00,23.11.03)

  **Sponsored by** *UK Health Security Agency*
- [35685](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35685) ILL - OPAC request creation error if submitted empty while ILLModuleDisclaimerByType is in use (24.05.00,23.11.06)
- [36130](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36130) ILL batches table not showing all batches (24.05.00,23.11.04)
- [36414](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36414) Consequent workflow stages form submit fail due to CSRF token conflict (24.05.00)
- [36416](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36416) Check out using CirculateILL is broken (24.05.00)
- [34979](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34979) System preferences missing from sysprefs.sql (24.05.00,23.11.03)
- [35698](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35698) Wrong bug number in db_revs/220600084.pl (24.05.00,23.11.02,23.05.08)
- [35686](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35686) Case missing from installer step 3 template title (24.05.00,23.11.02)
  >This fixes a web browser page title for the web installer - from " > Web installer > Koha" to "Updating database structure  > Web installer > Koha".
- [36819](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36819) Default layout data prints squished barcodes (24.05.00)
- [36931](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36931) label-item-search.pl paging doesn't work (due to CSRF changes) (24.05.00)
- [35547](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35547) When using "Add to a list" button with more than 10 lists, "staff only" does not show up (24.05.00,23.11.02,23.05.08)
- [36003](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36003) Printing list from OPAC shows "Cookies" when CookieConsent enabled (24.05.00)
- [36388](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36388) Mouse operation does not work in draggable fields in authority editor (with Firefox) (24.05.00,23.11.06)
- [36791](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36791) Koha explodes when trying to edit an authority record with an invalid authid (24.05.00,23.11.06,23.05.12)

  **Sponsored by** *Ignatianum University in Cracow*
- [36799](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36799) Illegitimate modification of MARC authid field content (001) (24.05.00)

  **Sponsored by** *Ignatianum University in Cracow*
- [34663](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34663) Errors in UNIMARC default framework (24.05.00,23.11.06)
- [36111](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36111) Online resource link should be based on the presence of 856$u (MARC21)
  >This fixes the display of 856 in the search results and detailed record, in the staff interface and OPAC. Currently, Koha displays "Click here to access online" if any 856 subfield is present, using the $u subfield as the link target, even if $u is empty. This patch makes the display of the online resource link depend on the presence of 856$u to prevent empty links.
- [23296](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23296) Auto Renewal Notice does not use Library specific notices (24.05.00,23.11.06)
- [30287](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30287) Notices using HTML render differently in notices.pl (24.05.00,23.11.02,23.05.08)
  >This fixes notice previews for patrons in the staff interface (Patrons > [Patron account] > Notices), where HTML is used in the email notices. For example, previously if <br>s were used then the preview would match the email sent, however, using <p>s would add extra lines in the preview.
- [35285](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35285) Centralise notice content wrapping for HTML output (24.05.00)
- [36652](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36652) Cannot copy notice from one library to another (24.05.00,23.11.06)
- [16567](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16567) RSS feeds show issues in W3C validator and can't be read by some aggregators (Chimpfeedr, feedbucket) (24.05.00,23.11.06)
- [33244](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33244) Do not show lists in OPAC if OpacPublic is disabled (24.05.00,23.11.01)
- [34792](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34792) CookieConsentBar content feels mis-aligned (24.05.00)
- [35436](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35436) Copy is not translatable in OPAC search history (24.05.00,23.11.01,23.05.07)
- [35488](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35488) Placing a hold on the OPAC takes the user to their account page, but does not activate the holds tab (24.05.00,23.11.02,23.05.08)
- [35492](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35492) Suspending/unsuspending a hold on the OPAC takes the user to their account page, but does not activate the holds tab (24.05.00,23.11.02,23.05.08)
- [35495](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35495) Cancelling a hold on the OPAC takes the user to their account page, but does not activate the holds tab (24.05.00,23.11.02,23.05.08)
- [35496](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35496) Placing an article request on the OPAC takes the user to their account page, but does not activate the article request tab (24.05.00,23.11.02,23.05.08)
- [35538](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35538) List of libraries on OPAC self registration form should sort by branchname rather than branchcode (24.05.00,23.11.04,23.05.10)
- [35578](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35578) Validate "Where" in OPAC Authority search (24.05.00,23.11.03)
- [35676](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35676) OPAC search results - link for "Check for suggestions" generates a blank page (24.05.00,23.11.02)
- [35795](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35795) Missing closing tag in OPAC course details template (24.05.00,23.11.03)
- [35841](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35841) Update text of 'Cancel' hold button on OPAC (24.05.00,23.11.03)
- [35929](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35929) Don't submit 'empty' changes to personal details in OPAC (24.05.00)
- [35952](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35952) Removed unnecessary  line in opac-blocked.pl (24.05.00,23.11.04,23.05.10)
- [35969](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35969) Improve error message, remove some logging when sending a cart from the OPAC (24.05.00,23.11.06)
- [36004](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36004) Typo in "Your concern was successfully submitted" OPAC text (24.05.00,23.11.04,23.05.10)
- [36032](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36032) The "Next" pagination button has a double instead of a single angle (24.05.00,23.05.10)

  **Sponsored by** *Karlsruhe Institute of Technology (KIT)*
- [36070](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36070) "Place recall" hover styling on OPAC not consistent (24.05.00,23.11.04)
- [36142](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36142) Usermenu "Recalls history" not active when confirming recall (24.05.00,23.11.06)
- [36341](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36341) "Hold starts on date" should be limited to future dates (24.05.00,23.11.06)
- [36390](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36390) Two minor OPAC CSS fixes (24.05.00,23.11.06)
- [36532](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36532) Any authenticated OPAC user can run opac-dismiss-message.pl for any user/any message (24.05.00,23.11.05,23.05.11)
- [36615](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36615) Terminology: use 'on hold' instead of 'reserved' in OPAC self checkout (24.05.00)
- [36772](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36772) OPAC self checkout accepts wrong or partial barcodes (24.05.00)
- [36785](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36785) Tagging: Resolve warning about unrecognized biblionumber (24.05.00)
- [25691](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25691) Debian packages point to /usr/share/doc/koha/README.Debian which does not exist (24.05.00,23.11.02,23.05.09)
- [35713](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35713) Remove debian/docs/LEEME.Debian (24.05.00,23.11.02,23.05.08)
- [19613](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19613) Scrub borrowers fields: borrowernotes opacnote (24.05.00,23.11.05,23.05.11,22.11.17,22.05.21)
- [25835](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25835) Include overdue report (under circulation module) as a staff permission (24.05.00,23.11.02,23.05.08)
- [30318](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30318) Cannot override default patron messaging preferences when creating a patron in staff interface (24.05.00,23.11.06)
- [30987](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30987) Adding relationship to PatronQuickAddFields causes it to be added 2x (24.05.00,23.11.06)
- [33849](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33849) Duplicate patron warning resets patron's library if different than logged in user's library (24.05.00)

  **Sponsored by** *Koha-Suomi Oy*
- [35344](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35344) Patron image upload does not warn about missing cardnumber (24.05.00,23.11.01,23.05.07)
- [35352](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35352) Cannot hide SMSalertnumber via BorrowerUnwantedField (24.05.00,23.11.01,23.05.07)
- [35445](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35445) OPAC registration verification triggered by email URL scanners (24.05.00,23.11.03)
- [35493](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35493) Housebound roles show as a collapsed field option when checked in CollapseFieldsPatronAddForm, even if housebound is off (24.05.00,23.11.02,23.05.08)
- [35599](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35599) Pronouns and HidePersonalPatronDetailOnCirculation (24.05.00,23.11.06)
  >Bug 10950 adds a pronouns text field to the patron record.
  >It was hidden by the system preference 'HidePersonalPatronDetailOnCirculation', not anymore.
- [35743](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35743) The "category" filter is not selected in the column filter dropdown (24.05.00,23.11.03)
- [35756](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35756) Wrong use of encodeURIComponent in patron-search.inc (24.05.00,23.11.02,23.05.09)
- [36076](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36076) paycollect.tt is missing permission checks for manual credit and invoice (24.05.00,23.11.04,23.05.10)
- [36251](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36251) Patron search by letter broken in holds (24.05.00)
- [36292](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36292) 'See all charges' hyperlink to view guarantee fees is not linked correctly (24.05.00,23.11.04,23.05.10)
- [36298](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36298) In patrons search road type authorized value code displayed in patron address (24.05.00,23.11.04,23.05.10)
- [36321](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36321) Problem when dateexpiry in BorrowerUnwantedField (24.05.00,23.11.06,23.05.12)
- [36353](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36353) Ensure consistent empty selection style for guarantor relationship drop-downs (24.05.00,23.11.06)
- [36371](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36371) Patron attributes will not show in brief info if value is 0 (24.05.00,23.11.06)
- [36376](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36376) Display library limitations alert in patron's messages (24.05.00,23.11.06)
- [36452](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36452) Patron message does not respect multiple line display (24.05.00,23.11.06)
- [36529](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36529) manage_additional_fields permission for more than acquisitions and serials (24.05.00)
- [36738](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36738) Date attributes follow-ups (24.05.00)
- [36816](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36816) OPAC - Patron 'submit update request' does not work for clearing patron attribute types (24.05.00)
- [36825](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36825) Cannot hide "Protected" field via BorrowerUnwantedField system preference (24.05.00)

  **Sponsored by** *Koha-Suomi Oy*
- [35070](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35070) Koha plugins implementing "background_jobs" hook can't provide view template (24.05.00,23.11.02,23.05.08)
- [36343](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36343) The 'after_biblio_action' hooks have an inconsistent signature compared to before_biblio_action, and actions in reserves and items (24.05.00)
- [35387](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35387) Capitalization: Labels in preservation module are not capitalized (24.05.00,23.11.01)
  >This fixes the capitalization of some label names in the Preservation module (name -> Name, and barcode -> Barcode).
- [35463](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35463) Link preservation module help to the manual (24.05.00,23.11.02)
  >This patch links the various pages of the preservation module to each specific section of the preservation module chapter in the manual.
- [35477](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35477) Adding non-existent items to the waiting list should display a warning (24.05.00,23.11.02)
- [35714](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35714) Clicking Print slips when no letter template selected causes error (24.05.00,23.11.06)
- [36649](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36649) Adding recently added items to processing from waiting list does not work if processing includes information from database columns (24.05.00,23.11.06)
- [32551](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32551) API requests don't carry language related information (24.05.00,23.11.02,23.05.08)
- [35129](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35129) REST API: _per_page=0 crashes on Illegal division by zero (24.05.00,23.11.06)
- [35368](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35368) "Add a checkout" shows up twice in online documentation (24.05.00,23.11.03)
- [36066](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36066) REST API: We should only allow deleting cancelled order lines (24.05.00,23.11.04,23.05.10)
- [36329](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36329) Transfer limits should respect `BranchTransferLimitsType` (24.05.00,23.11.04,23.05.12)
- [36420](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36420) REST API Basic Auth does not support cardnumbers, only userid (24.05.00,23.11.06)
- [36421](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36421) Better logging of 500 errors in V1/Auth.pm (24.05.00,23.11.06)
- [36483](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36483) Calling $object->to_api directly should be avoided (24.05.00,23.11.06)
- [36493](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36493) Test for GET /api/v1/cash_registers/:cash_register_id/cashups is fragile (24.05.00,23.11.06)
- [36505](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36505) Allow updating patron attributes via PUT (24.05.00)
- [35498](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35498) SQL auto-complete should not prevent use of tab for spacing (24.05.00,23.11.02,23.05.08)
- [35936](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35936) Cannot save existing report with incorrect AV category (24.05.00,23.11.03)
- [35943](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35943) SQL reports groups/subgroups whose name contains regexp special characters break table filtering (24.05.00,23.11.06)
- [35949](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35949) Useless code pointing to branchreserves.pl in request.tt (24.05.00,23.11.04,23.05.10)
- [36534](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36534) Batch operations when using limit in report (24.05.00,23.11.06)
- [36796](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36796) Fix mistake in database column descriptions for statistics table (24.05.00,23.11.06)
- [36823](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36823) Reports links to database schema 404 looking for master rather than main (24.05.00)
- [35461](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35461) Renew All 66 SIP server response messages produce HASH content in replies (24.05.00,23.11.03,23.05.09)
- [36676](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36676) SIP2 drops connection when using unknown patron id in fee paid message (24.05.00)
- [32695](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32695) Search string for various 7xx linking fields is incorrectly formed (24.05.00,23.11.06)
  >This fixes the search links for the MARC21 linking fields 775, 780, 785, 787 to search for $a and $t in separate indexes instead of searching for both in the title index.
- [35410](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35410) 856 label is inconsistent between detail page and search results in XSLTs (24.05.00,23.11.01,23.05.07)
  >This updates the default staff interface and OPAC XSLT files so that "Online resources" is used as the label in search results for field 856 - Electronic Location and Access, instead of "Online access". This matches the label used in the detail page for a record.
  >
  >It also adjusts the CSS class so OPAC and staff interface both use online_resources.
- [36659](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36659) Authorities search tab keeps defaulting to main heading ($a only) (24.05.00)

  **Sponsored by** *Education Services Australia SCIS*
- [32707](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32707) Elasticsearch should not auto truncate (even if  QueryAutoTruncate = 1) for identifiers (and some other fields) (24.05.00,23.11.06)
- [33099](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33099) Add missing MARC21 match authority mappings so "Search all headings" search works (24.05.00)
- [33205](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33205) (Bug 28268 follow-up) Method call $row->authid inside quotes - produces meaningless warning (24.05.00,23.11.06)
- [35086](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35086) Koha::SearchEngine::Elasticsearch::Indexer->update_index needs to commit in batches (24.05.00,23.11.02,23.05.09)
  >This enables breaking large Elasticsearch or Open Search indexing requests into smaller chunks (for example, when updating many records using batch modifications).
  >
  >This means that instead of sending a single background request for indexing, which could exceed the limits of the search server or take up too many resources, it limits index update requests to a more manageable size.
  >
  >The default chunk size is 5,000. To configure a different chunk size, add a <chunk_size> directive to the elasticsearch section of the instance's koha-conf.xml (for example: <chunk_size>2000</chunk_size>).
  >
  >NOTE: This doesn't change the command line indexing script, as this already allows passing a commit size defining how many records to send.
- [35265](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35265) Remove drag and drop in Elasticsearch mappings (24.05.00,23.11.02)
  >This removes the ability to drag and drop the order of the bibliographic and authorities search fields (Administration > Catalog > Search engine configuration (Elasticsearch)). This was removed as the feature has no effect on the search results when using Elasticsearch or OpenSearch as the search engine.
- [35618](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35618) catalogue/showelastic.pl uses deprecated/removed parameter "type" (24.05.00,23.11.02)
  >This fixes the display when clicking on "Show" for the "Elasticsearch record" entry for a record in the staff interface. Before this fix, a page not found (404) was displayed when viewing a record using Elasticsearch 7 or 8, or Open Search 1 ord 2. (Note that Elasticsearch 6 is no longer supported.)
- [36269](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36269) Elasticsearch: publisher-location (pl) index should include 260a/264a (MARC21) (24.05.00,23.11.06)
  >This enhancement adds 260$a and 264$a to the publisher-location (pl) Elasticsearch index for MARC21 records. Values in those two fields will be findable using the Publisher location option in the advanced search.
  >
  >Note: for existing installations, the index needs to be rebuilt using -r (reset mappings) in order for this information to be taken into account.

  **Sponsored by** *Steiermärkische Landesbibliothek*
- [36394](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36394) Inconsistent behaviour in footers (mappings admin page) (24.05.00,23.11.06)

  **Sponsored by** *The Research University in the Helmholtz Association (KIT)*
- [36554](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36554) Document languages from field 041 should be present in 'ln' search field and Languages facet (MARC 21) (24.05.00,23.11.06)
- [36678](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36678) Include fields with non-filing characters removed when indexing (24.05.00,23.11.06)
- [36750](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36750) OPAC - some facet heading labels are not displayed in search results when using Elasticsearch (24.05.00)
- [27198](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27198) Sync marc21-retrieval-info-auth-dom.xml with retrieval-info-auth-dom.xml (24.05.00,23.11.06)
  >This fixes the syntax in marc21-retrieval-info-auth-dom.xml, so that one can use the Zebra special retrieval elements documented at https://software.indexdata.com/zebra/doc/special-retrieval.html
  >
  >These are very useful when troubleshooting issues with authority records in Zebra.
- [35455](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35455) ICU does not strip = when indexing/searching (24.05.00,23.11.02,23.05.08)
  >This change fixes an issue with Zebra ICU searching where titles with colons aren't properly searchable, especially when used with Analytics.
  >
  >A full re-index of Zebra is needed for this change to take effect.
- [23102](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23102) 404 errors on page causes SCI user to be logged out (24.05.00,23.11.06)
- [28012](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28012) Error on saving new numbering pattern (24.05.00,23.11.02,23.05.08)
  >This fixes the serials new numbering pattern input form so that the name and numbering formula fields are marked as required. Before this, there was no indication that these fields were required and error trace messages were displayed if these were not completed - saving a new pattern or editing an existing pattern would also silently fail.
  >
  >NOTE: Making the description field optional will be fixed in bug 31297. Until this is done, a value needs to be entered into this field - even though it doesn't indicate that it is required.
- [31297](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31297) Cannot add new subscription patterns from edit subscription page (24.05.00,23.11.02,23.05.08)
- [36804](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36804) Serials claims 'Clear filter' doesn't work (24.05.00,23.11.06)
- [28869](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28869) Optionally restrict authorised values to tinyint (24.05.00)
- [30123](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30123) On set library page, desk always defaults to last in list instead of desk user is signed in at (24.05.00)
- [32477](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32477) Hiding batch item modification columns isn't remembered correctly (24.05.00,23.11.02,23.05.09)
  >This fixes showing and hiding columns when batch item editing (Cataloging > Batch editing > Batch item modification). When using the show/hide column options, the correct columns and updating the show/hide selections were not correctly displayed, including when the page was refreshed (for example: selecting the Collection column hid the holds column instead, and the shown/hide option for Collection was not selected).

  **Sponsored by** *Koha-Suomi Oy*
- [33464](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33464) Report "Orders by fund" is missing page-section class on results (24.05.00,23.11.03)
- [34298](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34298) Duplicate existing orders is missing page section on order list (24.05.00,23.11.03)
- [34872](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34872) Cart pop-up is missing page section (24.05.00,23.11.03)
- [35300](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35300) Add page-section to table of invoice files (24.05.00,23.11.03)
- [35396](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35396) Replace Datatables' column filters throttling with input timeout (24.05.00,23.11.03)
- [35574](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35574) Bookings page should require only manage_bookings permissions (24.05.00,23.11.02)
- [35592](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35592) Missing closing div tag in bookings alert in circulation.tt (24.05.00,23.11.02)
- [35619](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35619) Change password form in patron account has misaligned validation errors (24.05.00,23.11.02,23.05.08)
- [35742](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35742) Cannot remove new user added to fund (24.05.00,23.11.03)
- [35745](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35745) Setting suggester on the suggestion edit form does not show library and category (24.05.00,23.11.03)
- [35752](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35752) Can't delete additional contents with 'Delete selected' button (24.05.00,23.11.03)
- [35753](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35753) Checkbox() function in additional-contents not necessary (24.05.00,23.11.03)
- [35772](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35772) Double escaping of patron fields in bookings modal (24.05.00,23.11.02)
- [35800](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35800) edit_any_item permission required to see patron name in detail page (24.05.00,23.11.03,23.05.10)
- [35865](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35865) Missing hint about permissions when adding managers to a basket (24.05.00,23.11.03,23.05.09)
- [35868](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35868) Warning sign for using a patron category that is limited to another library has moved to other side of page (24.05.00,23.11.06)
- [35961](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35961) Modal include missing for catalog concerns (24.05.00)
- [36005](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36005) Typo in "Your concern was successfully submitted" in staff interface (24.05.00,23.11.04,23.05.10)
- [36099](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36099) JS error in console on non-existent biblio record (24.05.00,23.11.04,23.05.10)
- [36150](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36150) Circulation home page styling does not match Cataloging home page styling (24.05.00,23.11.04)
  >This fixes the styling of the circulation home page for the staff interface. It is now consistent with the cataloging home page, and includes wider side margins.
- [36215](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36215) Bookings calendar only shows bookings within RESTdefaultPageSize (24.05.00,23.11.04)
- [36462](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36462) Home button breadcrumb appears twice when viewing/editing the authority MARC subfield structure (24.05.00,23.11.06)
  >Previously, the 'Home' breadcrumb button would appear twice in succession when viewing or editing the authority MARC subfield structure for a particular field. Following a trivial template fix, the 'Home' breadcrumb button will now appear only once.
- [36469](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36469) Conflict between _header.scss and addbiblio.css tab style (24.05.00)
  >This fixes the display of the staff interface search bar. In some places, such as when adding a new record, extra padding was added.
- [36507](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36507) Cannot set desk or register as non superlibrarian (24.05.00)
- [36572](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36572) Cleanup the set library page and avoid extra confirmation step (24.05.00)
- [36673](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36673) Limit search for used categories and item types to current library (24.05.00,23.11.06)
- [36830](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36830) Unable to delete a holiday (24.05.00)
- [36834](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36834) (Bug 29697 follow-up) Koha explodes when trying to open in Labeled MARC view a bibliographic record with an invalid biblionumber (24.05.00)
- [31694](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31694) MARC overlay rules presets don't change anything if presets are translated (24.05.00,23.11.02,23.05.08)
- [34644](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34644) Add clarifying text to sysprefs to indicate that MarcFieldsToOrder is a fallback to MarcItemFieldsToOrder (24.05.00,23.11.02,23.05.08)
  >This updates the descriptions for system preferences MarcFieldsToOrder and MarcItemFieldsToOrder.
- [35293](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35293) Regression: Bug 33390 (QA follow-up) patch overwrote the template changes to bug 25560 (24.05.00,23.11.02)

  **Sponsored by** *Catalyst*
- [35395](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35395) Update description of DefaultPatronSearchMethod (24.05.00,23.11.02)
- [35457](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35457) Move SerialsDefaultEMailAddress and SerialsDefaultReplyTo to serials preferences (24.05.00,23.11.06)
- [35510](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35510) Non-patron guarantor missing from CollapseFieldsPatronAddForm  options (24.05.00,23.11.02,23.05.09)
  >This adds Non-patron guarantor as an option to the CollapseFieldsPatronAddForm system preference - this section can now be collapsed on the patron form.
- [35530](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35530) Can't tell if UserCSS and UserJS in libraries are for staff interface or OPAC (24.05.00,23.11.03)
- [35708](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35708) System parameter AutoRenewalNotices defaults to deprecated option (24.05.00,23.11.06)
  >NEW INSTALLATIONS ONLY. This sets the default value for the AutoRenewalNotices system preference to "according to patron messaging preferences". (The previous default value was deprecated - "(Deprecated) according to --send-notices cron switch".)
- [35831](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35831) Move UpdateItemLocationOnCheckout to Checkout policy section (24.05.00,23.11.03)
- [35973](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35973) System preference RedirectGuaranteeEmail has incorrect values (24.05.00,23.11.06)
- [36294](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36294) Replace inaccurate use of "book" in system preferences (24.05.00)
- [36409](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36409) System preference name consistency - change EMail to Email for SerialsDefaultEMailAddress and AcquisitionsDefaultEMailAddress (24.05.00,23.11.06)
- [36592](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36592) Cannot save default display length or default sort order in table settings (24.05.00)
- [36824](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36824) Fix conversion of __VERSION__ in system preferences to use main rather than master (24.05.00)
- [34398](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34398) Inconsistencies in Record matching rules page titles, breadcrumbs, and header (24.05.00,23.11.01)
- [35323](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35323) Terminology: Add additional elements to the "More Searches" bar... (24.05.00,23.11.03)
- [35327](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35327) Fix capitalization of language name (24.05.00,23.11.01,23.05.07)
  >This fixes the capitalization of English (english -> English) in the ILS_DI GetAvailability information page (<domainname>:<port>/cgi-bin/koha/ilsdi.pl?service=Describe&verb=GetAvailability).
- [35349](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35349) Reindent label item search template (24.05.00,23.11.03)
- [35350](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35350) Update label creator pop-up windows with consistent footer markup (24.05.00,23.11.03)
- [35351](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35351) Adjust basket details template to avoid showing empty page-section (24.05.00,23.11.04,23.05.10)
  >This removes the empty white section in acquisitions for a basket with no orders.
- [35378](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35378) 'This authority type is used {count} times' missing dot (24.05.00,23.11.01)
- [35397](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35397) SIP2AddOpacMessagesToScreenMessage syspref description issue (24.05.00,23.11.04)
- [35404](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35404) Wrong copy and paste in string (ILL batches) (24.05.00,23.11.01)
- [35406](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35406) Typo in holds queue viewer template (24.05.00,23.11.03)
- [35407](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35407) Terminology: Show fewer collection codes (24.05.00,23.11.03)
- [35412](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35412) Capitalization: Toggle Dropdown (24.05.00,23.11.01)
- [35413](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35413) Terminology: differentiate issues for vendor issues and serials (24.05.00,23.11.02)
- [35415](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35415) Rephrase: Some patrons have requested a privacy ... (24.05.00,23.11.01)
- [35417](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35417) Update breadcrumbs and page titles for vendor issues (24.05.00,23.11.02)
- [35422](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35422) Unexpected translation string for Suggestions template (24.05.00,23.11.04)
- [35449](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35449) Accessibility: No links on "here" (24.05.00,23.11.01)
- [35450](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35450) Preservation system preferences should be authorised value pull downs (24.05.00,23.11.01)
- [35453](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35453) Wrong 'Laserdisc)' string on 007 builder (MARC21) (24.05.00,23.11.01,23.05.07)
- [35517](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35517) Choose correct default header search tab according to permissions (24.05.00,23.11.02)
  >This fixes the display of the header search form on the staff interface home page so that staff patrons with different permissions will see the correct tab in the header search form. Previously, the default was to display the check out search - if they didn't have circulation permissions, the search tabs were initially hidden.
- [35523](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35523) Fix doubled up quotes in cash register deletion confirmation message (24.05.00,23.11.02)
- [35524](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35524) Terminology: Bookseller in basket group CSV export (24.05.00,23.11.02)
- [35525](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35525) Spelling: SMS is an abbreviation (24.05.00,23.11.02)
- [35526](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35526) Terminology: Id, sushi and counter are abbreviations (24.05.00,23.11.02)
- [35528](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35528) Avoid 'click' for links in system preferences (24.05.00,23.11.02)
- [35529](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35529) Avoid 'click' for links in library administration (24.05.00,23.11.02)
- [35557](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35557) LoadResultsCovers is not used (staff) (24.05.00,23.11.02,23.05.08)
- [35602](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35602) Typo: AutoMemberNum (24.05.00,23.11.02)
- [35650](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35650) 'Check the logs' string dot-inconsistent (24.05.00,23.11.02)
  >This makes 'Check the logs..' messages more consistent across Koha, including the use of full stops. It also fixes up other related inconsistencies. These changes should make translations easier as well.
- [35820](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35820) Table on Hold ratios page at circ/reserveratios.pl has wrong id (24.05.00,23.11.03)
- [35857](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35857) Update display of Clear and Cancel links in the authority search pop-up window (24.05.00,23.11.06)
- [35893](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35893) Missing closing </li> in opac.pref (24.05.00,23.11.03)
- [35934](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35934) Items in transit show as both in-transit and Available on holdings list (24.05.00,23.11.04,23.05.10)
- [35951](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35951) We don't need category-out-of-age-limit.inc (24.05.00,23.11.03)
- [36157](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36157) Links in the "Run with template" dropdown at guided_reports.pl have odd formatting (24.05.00,23.11.04)
- [36158](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36158) Text on the "Show SQL code" button at guided_reports.pl breaks if report notice templates exist (24.05.00,23.11.04)
- [36224](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36224) It looks like spsuggest functionality was removed years ago, but the templates still refer to it (24.05.00,23.11.04,23.05.10)
- [36282](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36282) OPAC - Remove trailing and leading blank space from translated strings (24.05.00,23.11.06)
- [36295](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36295) Space out content blocks in batch record deletion (24.05.00,23.11.06)
- [36334](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36334) Unnecessary JS code in member.tt (24.05.00)
- [36358](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36358) Typo in errorpage.tt: requets (24.05.00)
- [36382](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36382) XSS in showLastPatron dropdown (24.05.00,23.11.05)
- [36384](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36384) 'Used saved' typo in guided reports (24.05.00)
- [36490](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36490) Correct tab-switching keyboard shortcut for header search forms (24.05.00)
- [36528](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36528) Incorrect path to enquire.js on self checkout slip print page (24.05.00)
- [36610](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36610) Some improvements to OPAC print CSS (24.05.00)
- [36701](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36701) Adjust hold confirmation to avoid showing empty div (24.05.00)
- [36892](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36892) Wrong label on filter-orders include (24.05.00)
- [32671](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32671) basic_workflow.t is failing on slow servers (24.05.00,23.11.04,23.05.10)
- [34655](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34655) system_preferences_search.t is failing randomly (24.05.00)
- [35506](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35506) selenium/regressions.t is failing randomly (24.05.00)
- [35507](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35507) Fix handling plugins in unit tests causing random failures on Jenkins (24.05.00,23.11.02,23.05.09)
- [35556](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35556) selenium/administration_tasks.t failing if too many patron categories (24.05.00,23.11.02)
- [35598](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35598) selenium/authentication_2fa.t is still failing randomly (24.05.00,23.11.02,23.05.08)
- [35904](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35904) C4::Auth::checkauth cannot be tested easily (24.05.00,23.11.03,23.05.09)
- [35940](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35940) Cypress tests for the Preservation module are failing (24.05.00,23.11.03)
- [35962](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35962) t/db_dependent/Koha/BackgroundJob.t failing on D10 (24.05.00,23.11.03,23.05.09)
- [36010](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36010) Items/AutomaticItemModificationByAge.t is failing (24.05.00,23.11.04,23.05.10)
- [36012](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36012) ERM/Agreements_spec.ts might be failing if run too slow (24.05.00)
- [36160](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36160) Use $builder->build_object when creating patrons in Circulation.t (24.05.00,23.11.06)
- [36268](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36268) Letters.t assumes an empty ReplyToDefault (24.05.00,23.11.06)
- [36277](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36277) t/db_dependent/api/v1/transfer_limits.t  is failing (24.05.00,23.11.04,23.05.10)
- [36355](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36355) Auth/csrf.ts is failing if library with long info in the DB (24.05.00)
- [36397](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36397) t/db_dependent/Koha/Plugins/authority_hooks.t fails with Elasticsearch (24.05.00)
- [36567](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36567) Datetime warning in t/db_dependent/Circulation.t and t/db_dependent/Circulation/dateexpiry.t (24.05.00,23.11.06)

  **Sponsored by** *Koha-Suomi Oy*
- [36916](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36916) TestBuilder generates incorrect JS and CSS for libraries (24.05.00)
- [36917](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36917) Many warnings from t/db_dependent/Authority/Merge.t (24.05.00)
- [36923](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36923) Holds/LocalHoldsPriority.t generates warnings (24.05.00)
- [36924](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36924) t/db_dependent/Search.t generates warnings (24.05.00)
- [36939](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36939) Serials.t generates a warning (24.05.00)
- [34621](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34621) Patron import option to 'Renew existing patrons' 'from the current membership expiry date' not implemented (24.05.00,23.11.06)
  >This fixes the option when importing patrons so that the expiry date is updated for existing patrons (Tools > Patrons > Import patrons > Preserve existing values > Overwrite the existing one with this > Renew existing patrons - from the current membership expiry date).
- [35438](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35438) Importing records can create too large transactions (24.05.00,23.11.02,23.05.09)
- [35579](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35579) marcrecord2csv searches authorised values inefficiently (24.05.00,23.11.02,23.05.08)
  >This significantly improves the speed of downloading large lists in CSV format. (It adds a get_descriptions_by_marc_field" method which caches AuthorisedValue descriptions when searched by MARC field, which is used when exporting MARC to CSV.)
- [35588](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35588) marcrecord2csv retrieves authorised values incorrectly for fields (24.05.00,23.11.02,23.05.08)
  >This fixes the CSV export of records so that authorized values are exported correctly. It ensures that the authorized value descriptions looked up are for the correct field/subfield designated in the CSV profile. Example: If the 942$s (Serial record flag) for a record has a value of "1", it was previously exported as "Yes" even though it wasn't an authorized value.
- [35641](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35641) Reduce DB calls when performing inventory on a list of barcodes (24.05.00,23.11.02,23.05.09)
- [35817](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35817) Wrong hint on patron's category when batch update patron (24.05.00,23.11.03,23.05.09)
- [36082](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36082) OPACResultsSideBar not working with library specific message (24.05.00,23.11.06)
- [36305](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36305) Inventory tools need adjustments for CSRF (24.05.00)
- [34950](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34950) ILS DI Availability is not accurate for items on holds shelf or in transit (24.05.00,23.11.02,23.05.09)
- [36335](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36335) ILS-DI GetRecords bad encoding for UNIMARC (24.05.00)
- [34041](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34041) z3950 responder additional options not coming through properly (24.05.00)
- [36730](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36730) (Bug 35428 follow-up) po files (sometimes) fail to update (24.05.00,23.11.06)

## New system preferences

- 1PageOrderPDFText
- AcquisitionsDefaultEmailAddress
- AutoClaimReturnStatusOnCheckin
- AutoClaimReturnStatusOnCheckout
- ConsiderLibraryHoursInCirculation
- DefaultLongOverduePatronCategories
- DefaultLongOverdueSkipPatronCategories
- DisplayMultiItemHolds
- ESPreventAutoTruncate
- EmailFieldSelection
- HoldRatioDefault
- OPACAuthorIdentifiersAndInformation
- PlaceHoldsOnOrdersFromSuggestions
- PurgeListShareInvitesOlderThan
- RESTAPIRenewalBranch
- RedirectToSoleResult
- SCOBatchCheckoutsValidCategories
- SMSSendAdditionalOptions
- SerialsDefaultEmailAddress
- StaffLoginLibraryBasedOnIP
- StaffLoginRestrictLibraryByIP
- UpdateItemLostStatusWhenPaid
- UpdateItemLostStatusWhenWriteoff
- WaitingNotifyAtCheckout

## Deleted system preferences
- ILLModuleCopyrightClearance moved into HTML customizations
- AutoLocation replaced by StaffLoginLibraryBasedOnIP
- OPACAuthorIdentifiers replaced by OPACAuthorIdentifiersAndInformation

## New authorized value codes

- TICKET_RESOLUTION
- TICKET_STATUS

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Chinese (Traditional)](https://koha-community.org/manual/24.05/zh_Hant/html/) (72%)
- [English](https://koha-community.org/manual/24.05/en/html/) (100%)
- [French](https://koha-community.org/manual/24.05/fr/html/) (44%)
- [German](https://koha-community.org/manual/24.05/de/html/) (40%)
- [Hindi](https://koha-community.org/manual/24.05/hi/html/) (80%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (ar_ARAB) (98%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Traditional) (90%)
- Czech (68%)
- Dutch (76%)
- English (100%)
- English (New Zealand) (63%)
- English (USA)
- Finnish (99%)
- French (98%)
- French (Canada) (95%)
- German (100%)
- German (Switzerland) (51%)
- Greek (51%)
- Hindi (99%)
- Italian (83%)
- Norwegian Bokmål (76%)
- Persian (fa_ARAB) (91%)
- Polish (98%)
- Portuguese (Brazil) (91%)
- Portuguese (Portugal) (87%)
- Russian (90%)
- Slovak (60%)
- Spanish (100%)
- Swedish (87%)
- Telugu (69%)
- Turkish (79%)
- Ukrainian (73%)
- Western Armenian (hyw_ARMN) (64%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 24.05.00 is


- Release Manager: Katrin Fischer

- Release Manager assistants:
  - Tomás Cohen Arazi
  - Martin Renvoize
  - Jonathan Druart

- QA Manager: Marcel de Rooy

- QA Team:
  - Marcel de Rooy
  - Julian Maurice
  - Lucas Gass
  - Victor Grousset
  - Kyle M Hall
  - Nick Clemens
  - Martin Renvoize
  - Tomás Cohen Arazi
  - Aleisha Amohia
  - Emily Lamancusa
  - David Cook
  - Jonathan Druart
  - Pedor Amorim

- Topic Experts:
  - UI Design -- Owen Leonard
  - Zebra -- Fridolin Somers
  - REST API -- Tomás Cohen Arazi
  - ERM -- Matt Blenkinsop
  - ILL -- Pedro Amorim
  - SIP2 -- Matthias Meusburger
  - CAS -- Matthias Meusburger

- Bug Wranglers:
  - Aleisha Amohia
  - Indranil Das Gupta

- Packaging Managers:
  - Mason James
  - Indranil Das Gupta
  - Tomás Cohen Arazi

- Documentation Manager: Aude Charillon

- Documentation Team:
  - Caroline Cyr La Rose
  - Kelly McElligott
  - Philip Orr
  - Marie-Luce Laflamme
  - Lucy Vaux-Harvey

- Translation Manager: Jonathan Druart


- Wiki curators: 
  - Thomas Dukleth
  - Katrin Fischer

- Release Maintainers:
  - 23.11 -- Fridolin Somers
  - 23.05 -- Lucas Gass
  - 22.11 -- Frédéric Demians
  - 22.05 -- Danyon Sewell

- Release Maintainer assistants:
  - 22.05 -- Wainui Witika-Park

## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 24.05.00

- Altadena Library District
- Athens County Public Libraries
- Auckland University of Technology
- Bibliotek Mellansjö, Sweden
- [ByWater Solutions](https://bywatersolutions.com)
- [Cape Libraries Automated Materials Sharing](https://info.clamsnet.org)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)
- Colorado Library Consortium
- Cuyahoga County Public Library
- Education Services Australia SCIS
- [Geosphere, Austria](https://www.geosphere.at)
- Gothenburg University Library
- [HKS3](koha-support.eu)
- Ignatianum University in Cracow
- Karlsruhe Institute of Technology (KIT)
- [Koha-Suomi Oy](https://koha-suomi.fi)
- [Koha-US](https://koha-us.org)
- [Orex Digital](https://orex.es)
- [PTFS Europe](https://ptfs-europe.com)
- Pymble Ladies' College
- St Luke's Grammar School & Pymble Ladies' College
- Steiermärkische Landesbibliothek
- Technische Hochschule Wildau
- [Theke Solutions](https://theke.io)
- UK Health Security Agency
- Waikato Institute of Technology, New Zealand
- [ZAMG - Zentralanstalt für Meterologie und Geodynamik, Austria](https://www.zamg.ac.at/)
- Écoles nationales supérieure d'architecture (ENSA)

We thank the following individuals who contributed patches to Koha 24.05.00

- Aleisha Amohia (34)
- Pedro Amorim (121)
- Tomás Cohen Arazi (137)
- Alex Arnaud (8)
- Stefan Berndtsson (2)
- Matt Blenkinsop (44)
- Jérémy Breuillard (1)
- Alex Buckley (12)
- Phan Tung Bui (2)
- Kevin Carnes (4)
- Aude Charillon (2)
- Nick Clemens (178)
- David Cook (41)
- Paul Derscheid (2)
- Jonathan Druart (469)
- Magnus Enger (4)
- Laura Escamilla (17)
- Katrin Fischer (167)
- Emily-Rose Francoeur (1)
- Andrew Fuerste-Henry (4)
- Matthias Le Gac (12)
- Lucas Gass (98)
- Victor Grousset (12)
- Thibaud Guillot (10)
- David Gustafsson (16)
- Michael Hafen (1)
- Kyle M Hall (89)
- Janik Hilser (1)
- Mark Hofstetter (1)
- Andreas Jonsson (12)
- Janusz Kaczmarek (22)
- Jan Kissig (4)
- Thomas Klausner (3)
- Michał Kula (5)
- Joonas Kylmälä (2)
- Emily Lamancusa (27)
- Per Larsson (1)
- Brendan Lawlor (13)
- Owen Leonard (139)
- Julian Maurice (24)
- Matthias Meusburger (1)
- David Nind (7)
- Andrew Nugged (1)
- Björn Nylén (2)
- Jacob O'Mara (2)
- Philip Orr (3)
- Hayley Pelham (1)
- Katariina Pohto (3)
- Liz Rea (1)
- Martin Renvoize (280)
- Phil Ringnalda (7)
- Adolfo Rodríguez (1)
- Marcel de Rooy (145)
- Caroline Cyr La Rose (16)
- Andreas Roussos (1)
- David Schmidt (3)
- Danyon Sewell (3)
- Slava Shishkin (1)
- Michael Skarupianski (1)
- Fridolin Somers (25)
- Lari Strand (2)
- Raphael Straub (4)
- Zeno Tajoli (1)
- Emmi Takkinen (13)
- Lari Taskula (3)
- George Veranis (1)
- Shi Yao Wang (10)
- Hammat Wele (9)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 24.05.00

- Athens County Public Libraries (139)
- [BibLibre](https://www.biblibre.com) (69)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (167)
- [ByWater Solutions](https://bywatersolutions.com) (383)
- [Cape Libraries Automated Materials Sharing](https://info.clamsnet.org) (13)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha) (28)
- Catalyst Open Source Academy (22)
- Chetco Community Public Library (7)
- Cineca (1)
- [Dataly Tech](https://dataly.gr) (2)
- Dubuque County Library District (4)
- Göteborgs Universitet (14)
- [HKS3](koha-support.eu) (1)
- [Hypernova Oy](https://www.hypernova.fi) (3)
- Independant Individuals (54)
- Karlsruhe Institute of Technology (KIT) (4)
- Koha Community Developers (481)
- [Koha-Suomi Oy](https://koha-suomi.fi) (16)
- Kreablo AB (12)
- [Libriotech](https://libriotech.no) (4)
- [LMSCloud](lmscloud.de) (5)
- Lund University Library, Sweden (6)
- [Montgomery County Public Libraries](montgomerycountymd.gov) (27)
- [Prosentient Systems](https://www.prosentient.com.au) (41)
- [PTFS Europe](https://ptfs-europe.com) (449)
- Rijksmuseum, Netherlands (145)
- [Solutions inLibro inc](https://inlibro.com) (50)
- [Theke Solutions](https://theke.io) (137)
- Wildau University of Technology (4)
- [Xercode](https://xebook.es) (1)

We also especially thank the following individuals who tested patches
for Koha

- Michael Adamyk (2)
- Hugo Agud (4)
- Hebah Amin-Headley (2)
- Aleisha Amohia (5)
- Pedro Amorim (73)
- Tomás Cohen Arazi (186)
- Martin Aubeut (1)
- BabaJaga (1)
- Donna Bachowski (1)
- Baptiste Bayche (1)
- Matt Blenkinsop (37)
- Christopher Brannon (3)
- Richard Bridgen (1)
- Phan Tung Bui (3)
- Kevin Carnes (1)
- Aude Charillon (1)
- Axelle Clarisse (4)
- Nick Clemens (204)
- David Cook (19)
- Chris Cormack (4)
- Ray Delahunty (12)
- Frédéric Demians (4)
- Michal Denar (2)
- Paul Derscheid (12)
- Roman Dolny (16)
- Jonathan Druart (343)
- Michał Dudzik (1)
- Sharon Dugdale (2)
- Magnus Enger (5)
- Laura Escamilla (12)
- Jonathan Field (1)
- Katrin Fischer (1704)
- Andrew Fuerste-Henry (69)
- Matthias Le Gac (11)
- Brendan Gallagher (4)
- Lucas Gass (110)
- Eric Gosselin (2)
- Stephen Graham (6)
- Victor Grousset (106)
- Sophie Halden (1)
- Kyle M Hall (128)
- Stina Hallin (1)
- Frank Hansen (1)
- Sally Healey (6)
- Marie Hedbom (2)
- Mason James (2)
- Barbara Johnson (11)
- Janusz Kaczmarek (5)
- Sabrina Kiehl (2)
- Jan Kissig (5)
- Thomas Klausner (2)
- Lukas Koszyk (7)
- Kristi Krueger (7)
- Mia Kujala (2)
- Michał Kula (13)
- Emily Lamancusa (127)
- Sam Lau (12)
- Brendan Lawlor (31)
- Nicolas Legrand (1)
- Owen Leonard (143)
- Mikko Liimatainen (1)
- Julian Maurice (31)
- Kelly McElligott (9)
- Esther Melander (19)
- David Nind (362)
- Björn Nylén (1)
- Philip Orr (13)
- Nell O’Hora (1)
- Barbara Petritsch (2)
- Hans Pålsson (1)
- Séverine Queune (1)
- Laurence Rault (66)
- Martin Renvoize (458)
- Phil Ringnalda (16)
- Marcel de Rooy (187)
- Caroline Cyr La Rose (17)
- Mathieu Saby (4)
- Lisette Scheer (11)
- David Schmidt (5)
- Danyon Sewell (1)
- Michaela Sieber (13)
- Tadeusz Sośnierz (2)
- Edith Speller (2)
- Michelle Spinney (7)
- Christian Stelzenmüller (2)
- Myka Kennedy Stephens (1)
- Lari Strand (1)
- Arthur Suzuki (10)
- Emmi Takkinen (11)
- Clemens Tubach (13)
- Loïc Vassaux--Artur (1)
- Hinemoea Viault (1)
- Marc Véron (2)
- Alexander Wagner (3)
- Mohd Hafiz Yusoff (2)
- Anneli Österman (8)

We thank the following individuals who mentored new contributors to the Koha project

- Martin Renvoize

And people who contributed to the Koha manual during the release cycle of Koha 24.05.00

- Manu B (1)
- Aude Charillon (48)
- Caroline Cyr La Rose (173)
- Ben Daeuber (10)
- Jonathan Druart (1)
- Jonathan Field (144)
- Katrin Fischer (1)
- Brendan Lawlor (1)
- Kelly McElligott (4)
- Sophie Meynieux (1)
- David Nind (1)
- Philip Orr (80)
- Rasa Šatinskienė (21)
- Helen Symington (6)
- Lucy Vaux-Harvey (11)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Notes from the Release Manager

This has been a great experience and I'd like to give some special thanks to:

- My employer BSZ and my coworkers for enabling me to do this in the first place.
- The RM assistants Jonathan, Martin and Tomas for their patience and support.
- Our Release Maintainers for their never-ending work of backporting.
- The people of the Koha Community for all their contributions. This wouldn't be possible without you.
- Jenkins, my forever frenemy, for always pointing out the stuff we missed. May you have more green days than not.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is main.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 27 May 2024 13:04:25.
