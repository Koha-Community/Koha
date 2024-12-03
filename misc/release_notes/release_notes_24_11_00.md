# RELEASE NOTES FOR KOHA 24.11.00
25 Nov 2024

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 24.11.00 can be downloaded from:

- [Download](https://download.koha-community.org/koha-24.11-latest.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 24.11.00 is a major release, that comes with many new features.

It includes 10 new features, 184 enhancements, 647 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).

## New features & Enhancements

### Acquisitions

#### New features

- [34355](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34355) Automated MARC record ordering process
  >Adds a parallel process to EDI ordering for MARC-file based ordering systems.
  >

  **Sponsored by** *ByWater Solutions*

#### Enhancements

- [8855](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8855) Link from receipt to invoice
  >This enhancement links the invoice number on the receiving orders page to the invoice page.
- [33363](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33363) More specific permissions for purchase suggestions
  >This enhancement adds new staff permissions for suggestions. The new permissions are suggestions_create and suggestions_delete. Staff that currently have suggestions_manage will have the new statuses after the update.

  **Sponsored by** *Cuyahoga County Public Library*
- [34805](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34805) Add order search form to acquisitions module start page
  >This adds the advanced search form for searching orders to the start page of the acquisitions module.

  **Sponsored by** *Athens County Public Libraries*
- [36767](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36767) Add a hint to the EDI account form that the SFTP/FTP port will fallback to port 22 if not defined
  >This fixes an error when creating an EDI account if you don't enter the upload and download ports. The port numbers should have defaulted to port 22, but didn't - this generated an error when saving. It also adds a hint for the input fields to say that the port will default to 22 if not set.
- [37081](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37081) Add order confusing when ordering from a staged file
  >Fixes confusing terminology when staging or adding a new file to a basket in the acquisitions module.
- [37109](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37109) Don't provide old claims fields when duplicating acquisitions orders
  >This patch stops the unused fields claims_count, claimed_date, received_on and placed_on from being initialised while duplicating an order. The fields no longer exist in the aqorders table and no longer need to be set or passed on.

  **Sponsored by** *Catalyst*
- [37511](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37511) Add option to place the currency symbol before or after the amount
  >Adds the option in currencies to define whether the currency symbol should appear before or after the amount in displays.

  **Sponsored by** *Ignatianum University in Cracow*
- [38204](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38204) Add `GET /acquisitions/baskets`
  >This enhancement adds a new API endpoint to list baskets for acquisitions.
  >

  **Sponsored by** *PTFS Europe* and *ByWater Solutions*

### Architecture, internals, and plumbing

#### Enhancements

- [17729](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17729) Replace IsItemOnHoldAndFound with $item->holds->filter_by_found->count
- [24471](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24471) Rename ILL method handle_commit_maybe
- [30856](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30856) Remove CanReserveBeCanceledFromOpac
- [33641](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33641) We should record return library in old checkouts (oldissues)
- [35026](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35026) Refactor addorderiso2709.pl to use object methods
- [36694](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36694) Remove HC Sticky library in favor of CSS
  >This enhancement removes the hc-sticky.js assets from Koha which were used to make certain HTML elements "sticky". The functionality is now accomplished using only CSS.
- [37380](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37380) Move GetMarcControlnumber to Koha namespace
- [37480](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37480) Make C4::Serials::addroutingmember use Koha::Objects
- [37844](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37844) Remove C4::Members::DeleteUnverifiedOpacRegistrations
- [37845](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37845) Remove C4::Members::DeleteExpiredOpacRegistrations
- [37868](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37868) Remove C4::Reserves::ToggleSuspend
- [38279](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38279) C4::ImportBatch::EmbedItemsInImportBiblio is not used

### Authentication

#### Enhancements

- [36026](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36026) Add TLS MySQL connection without mutual authentication
  >Database connections with TLS require client private keys
  >and certificates for authentication but MariaDB also supports
  >authentication by user and password.
  >This enhancement allows omitting the TLS options for certificate based client authentication.

  **Sponsored by** *Karlsruhe Institute of Technology (KIT)*
- [37691](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37691) Password expiration reset not clear enough
  >This enhancement alters the style of the error message shown to a staff member who tries to log in to the staff client with an expired password. This change makes the message more visible and rewords the link text to read "Reset your password."

  **Sponsored by** *Athens County Public Libraries*

### Cataloging

#### New features

- [35659](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35659) OAI harvester
  >This change adds the ability for library staff to define OAI repositories in Koha, which are harvested for metadata using a cronjob configured by the system administrator. An email report of the harvest can be shared via using an email address defined in the system preference OAI-PMH:HarvestEmailReport

  **Sponsored by** *Association KohaLa* and *KohaLa*

#### Enhancements

- [29560](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29560) Add option to create MARC links when adding items to bundles
  >This enhancement to the bundle functionality adds the option to create 773 MARC field links between the bundle host and its constituent parts.
  >

  **Sponsored by** *PTFS Europe*
- [36054](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36054) Don't mark MARC21 005 as mandatory in frameworks now that AddBiblio and ModBibilio will set it no matter what
  >This change makes the 005 tag in MARC bibliographic frameworks no longer mandatory, because every time a bibliographic record is added or modified, Koha will set the content of 005 to the current time. Existing installations are not affected by this change, but should feel free to make the same change to their installed frameworks.
- [36496](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36496) Inventory results table needs an export option
  >This enhancement adds the CSV export options to the inventory results screen. Previously the CSV export had to be selected before running inventory.
- [36498](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36498) Allow ability to set display order when adding an item group from item editor
  >This enhancement to item groups allows you to set the order for item groups created when adding a new item. To do this: 
  >1. Scroll down to the 'Add to item group section' at the bottom of the add item form.
  >2. For the options field, select 'Create new item group'.
  >3. Add a new group name.
  >4. Add a number to the new 'Display order' field to set the order.
  >Previously, the order of the groups could only be changed from the item groups tab on the record details page.
  >(To use the item groups feature, enable the EnableItemGroups system preference.)
- [36515](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36515) Amend MARC modification templates so control fields can be copied to subfields
  >With this enhancement it's now possible to copy the content of MARC control fields to MARC subfields. Example: copy 001 to 035$a.

  **Sponsored by** *Education Services Australia SCIS*

### Circulation

#### New features

- [33736](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33736) Add bookings to collect circulation report
  >The enhancement adds a new 'Bookings to collect' report into the Circulation module. It parallels the 'Holds to pull' report allowing staff to easily report against upcoming bookings and collect them from the shelves ready for collection by the patron who has the item booked.

  **Sponsored by** *PTFS Europe*

#### Enhancements

- [14180](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14180) Make "Always show checkouts immediately" a global setting
  >This enhancement adds the ability for libraries to have checkouts always show immediately. To turn on this new feature, set the new system preference 'AlwaysLoadCheckoutsTable' to 'do. If you find that checkouts are slow do load, you can add a delay to the table so the rest of the page can load and checkouts can proceed using the new system preference 'LoadCheckoutsTableDelay'.
  >

  **Sponsored by** *ByWater Solutions*
- [14787](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14787) Allow confirm/continue option to circulation warnings at checkout
  >This patch adds functionality that will remember whether an action has been confirmed for a particular patron for the session. While carrying out an action on that patron, if the same checkout confirmation message keeps appearing the user can now select to remember their confirmation while they are still working on that patron. When the user moves onto a new patron the confirmations then reset and accumulate again for the new patron.
  >

  **Sponsored by** *ByWater Solutions*, *Colorado Library Consortium (CLIC)*, *Panhandle Public Library Cooperative* and *Arcadia Public Library*
- [23781](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23781) Recalls notices and messaging preferences
  >This enhancement for recalls adds two new patron messaging preferences and associated circulation notices when UseRecalls is enabled:
  >- Recall awaiting pickup (new notice - PICKUP_RECALLED_ITEM)
  >- Return recalled item (new notice - RETURN_RECALLED_ITEM)

  **Sponsored by** *Toi Ohomai Institute of Technology, New Zealand*
- [27919](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27919) Split claims return from LOST
  >This changes the behavior of the 'claims returned' feature to no longer depend on a specific lost status of the item. If the item was set to a lost status before being marked as 'claims returned' the existing status will be kept. It's also possible to update items to a different lost status after claiming it returned.
  >

  **Sponsored by** *ByWater Solutions* and *PTFS Europe* and *Cuyahoga County Public Library*
- [28924](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28924) Allow checkout fine limit to be determined by patron category
  >This allows to set charge limits for checkouts by patron category. If the patron category level option is not used, the global system preferences will be used instead. 
  >
  >The new options available are:
  >
  >- Checkout charge limit (`noissuescharge`) 
  >- Guarantee checkout charge limit (`NoIssuesChargeGuarantees preference`)
  >- Guarantors with guarantees checkout charge limit (`NoIssuesChargeGuarantorsWithGuarantees`)

  **Sponsored by** *Cuyahoga County Public Library*
- [33292](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33292) Claim return doesn't refund lost item charge when MarkLostItemsAsReturned includes "When marking an item as a return claim" and "Refund lost item fee" is on
  >This allows to refund the lost charge when a return claim is resolved. For this a new checkbox labelled 'Refund previous lost fee' is added to the return claim modal.
  >

  **Sponsored by** *ByWater Solutions* and *Cuyahoga County Public Library*
- [34440](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34440) Add warm-up and cool-down periods to bookings
  >This enhancement to the recently added bookings functionality allows libraries to define a lead-in and trail-out period to be prepended and appended to bookings.
  >
  >These periods prevent checkouts or bookings from taking place too close to each other and allow for things like transfers and maintenance to be carried out.

  **Sponsored by** *Cuyahoga County Public Library*
- [35906](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35906) Add bookable option on itemtypes
  >This allows to configure on item type level if an item is bookable or not. The item type level setting can be overwritten on item level.
- [35931](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35931) Pre-select items with due date today in the renew column on details page and on checkout page
  >This enhancement selects items that are due today on the patron checkout and details screens, allowing librarians to renew items due today without additional clicks. This mirrors the behavior for overdue items on the same pages.
- [36476](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36476) Add holds priority column to patron summary print
  >Adds a holds priority column to the "Pending holds" table when printing the patron's account summary.
- [36547](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36547) Add 'Checked out on' column to overdues table
  >This enhancement adds a "Checked out on" column to the report found at Circulation -> Overdues.
- [36915](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36915) Send email notification when a booking is cancelled
  >This enhancement sends a notice to a patron when a booking is cancelled using the new BOOKING_CANCELLATION notice.
  >

  **Sponsored by** *BibLibre*
- [37023](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37023) Filling a hold should update the timestamp
  >With this change the timestamp of the hold is updated when it is filled and moved to the `old_reserves` database table.

  **Sponsored by** *Koha-Suomi Oy*
- [37126](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37126) Provide link to patron account when checking out to statistical patron ends checkout
  >This enhancement links the patron details in the message displayed when checking out an item to a statistical patron, where that item is already checked out to another patron. Previously, the patron details in the message did not link to the patron. This now makes it easier for staff to check the patron's details, for example, to check for any incorrect charges.
- [37204](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37204) Add a booking has changed notice to update a patron should a booking be updated
  >This enhancement introduces a notice to inform patrons of changes to their bookings, such as updates to the pickup library, start date, or end date, ensuring clear communication regarding any modifications.

  **Sponsored by** *Büchereizentrale Schleswig-Holstein*
- [37354](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37354) Bookings should respect circulation rules for max loan periods
  >This enhancement builds on the bookings functionality added in the last cycle. We now prevent a booking from exceeding the maximum period laid out by the circulation rules for that item.
  >
  >We highlight the loan period and renewal periods in the bookings calendar upon selection of the booking start date and disallow bookings that exceed the loan period + renewal period * max renewals rules.
  >

  **Sponsored by** *PTFS Europe*
- [37592](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37592) Add a record of creation and modification to bookings
  >This enhancement adds `created_at` and `updated_at` fields to the bookings table, providing institutions with the ability to track the creation and modification timestamps of bookings.
  >

  **Sponsored by** *Büchereizentrale Schleswig-Holstein*
- [37601](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37601) Add status field to bookings table
  >This enhancement adds a status column to the bookings table to track the state of a booking, including 'new', 'cancelled', and 'completed' statuses. Future statuses will be handled dynamically for improved API response handling and search functionality.
  >

  **Sponsored by** *Büchereizentrale Schleswig-Holstein*
- [37803](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37803) Add patron notification when a new booking has been created successfully
  >This enhancement adds a patron notification for successful booking creation, aligning it with existing notices for booking modifications and deletions.

  **Sponsored by** *Büchereizentrale Schleswig-Holstein*
- [38175](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38175) Improve bookings behavior with new status field
  >We opted to move away from deleting bookings on collection/cancellation and instead use a status field to signify booking state.
  >
  >This allows for future reporting against fulfilled bookings.
- [38193](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38193) Add cancellation_reason field to bookings table
  >This enhancement adds a `cancellation_reason` field to the bookings table, allowing users to specify a reason for cancellations using either free text or an authorized value, and integrates this information into the cancellation process and notices.

  **Sponsored by** *Büchereizentrale Schleswig-Holstein*
- [38222](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38222) Let staff pick a cancellation reason when canceling a booking
  >This enhancement introduces a combobox component for booking cancellations, allowing users to select from authorized values or enter free text, ensuring consistent input handling and improved user experience across booking management modules.

  **Sponsored by** *Büchereizentrale Schleswig-Holstein*

### Command-line Utilities

#### Enhancements

- [9596](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9596) Allow longoverdue.pl to be configured per library on the command line
  >This patch adds --library and --skip-library options to the misc/cronjob/longoverdue.pl script. This enables setting the rules differently for each library when running the script on the command line and as a cron job.
- [29507](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29507) Speed up auto renew cronjob via parallel processing
  >This enhancement enables using parallel processing to speed up the running of the automatic renewals cron job (misc/cronjobs/automatic_renewals.pl). This cron job can take hours to run for libraries with thousands of items to renew. 
  >
  >To use this enhancement, add this setting to the instance's koha-conf.xml - adjusting the value depending on the system resources available:
  >
  >  <auto_renew_cronjob>
  >    <parallel_loops_count>1</parallel_loops_count>
  >  </auto_renew_cronjob>
- [36766](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36766) Add command-line utility to SFTP a file to a remote server
  >This enhancement adds a new command line utility misc/cronjobs/sftp_file.pl that allows libraries to securely transfer MARC data to an SFTP server. 
  >
  >Example usage: misc/cronjobs/sftp_file.pl --host sftp --user koha --pass koha --upload_dir upload --file /tmp/test.mrc
  >
  >Additional information:
  >1. Use misc/cronjobs/sftp_file.pl --help to list all the options available.
  >2. Two new notices are available: SFTP_FAILURE and SFTP_SUCCESSFUL.
  >3. The from address for any emails defaults to KohaAdminEmailAddress if ReplytoDefault is not set.
  >
  >##### Example of usage and workflow
  >
  >In New Zealand, libraries need to send MARC files to a remote server (using SFTP) to keep the national Te Puna union catalogue up to date.
  >
  >This enhancement allows NZ libraries to automate sending their MARC files by:
  >1. Using the runreport.pl cronjob to generate a list of bibliographic numbers.
  >2. Using the export_records.pl cronjob to generate the MARC file for those bibliographic numbers.
  >3. Use a new sftp_file cronjob to transfer the MARC file to the remote SFTP server.

  **Sponsored by** *Catalyst* and *Horowhenua Libraries, Toi Ohomai Institute of Technology, Plant and Food Research Limited, Waitaki District Council, South Taranaki District Council New Zealand*
- [36770](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36770) Add a reportID parameter to export_records.pl
  >This enhancement enables the export_records.pl script use a report output to export biblio or authority records, using the new 
  >--report_id=1 flag.

  **Sponsored by** *Horowhenua Libraries, Toi Ohomai Institute of Technology, Plant and Food Research Limited, Waitaki District Council, South Taranaki District Council New Zealand*
- [37181](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37181) Add --confirm option switch to pseudonymize_statistics.pl
  >This adds a `--confirm` option to the `pseudoymize_statistics.pl` command line script. Without this option there will be no changes made when the script is run, avoiding any accidental changes.
- [37613](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37613) Follow-up to bug 9596 to change the option and documentation to match Terminology Guidelines
- [37657](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37657) Improve speed of koha-preferences CLI tool (by using minimal dbh)
  >This change refactors the koha-preferences CLI tool to use different internal database libraries in order to gain a speed performance improvement.
- [37682](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37682) Improve speed of koha-preferences CLI tool (by lazy-loading modules)
  >By lazy-loading modules needed for some functions of the koha-preferences CLI tool, other functions which do not need those modules now run much faster.

### Course reserves

#### Enhancements

- [35978](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35978) Extend breadcrumbs course reserves with sections
  >This enhancement adds the course section field into the breadcrumb for course reserves. This makes it easier to distinguish where you are.

### Database

#### Enhancements

- [31143](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31143) We should attempt to fix/identify all cases where '0000-00-00' may still remain in the database
  >This enhancement:
  >
  >1. Updates the misc/maintenance/search_for_data_inconsistencies.pl script so that it identifies any date fields that have 0000-00-00 values.
  >
  >2. Adds a new script misc/maintenance/fix_invalid_dates.pl that fixes any date fields that have '0000-00-00' values (for example: dateofbirth) by updating them to 'NULL'. 
  >
  >Patron, item, and other date fields with a value of '000-00-00' can cause errors. This includes:
  >- API errors
  >- stopping the patron autocomplete search working
  >- generating a 500 internal server error:
  >  . for normal patron searching
  >  . when displaying item data in the holdings table

### ERM

#### New features

- [35287](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35287) Add additional fields support to ERM licenses
  >This enhancement adds "Additional fields" support to ERM licenses.

  **Sponsored by** *PTFS Europe* and *UKHSA - UK Health Security Agency*

#### Enhancements

- [37274](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37274) Standardize the toolbar in Vue components
- [37576](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37576) Add additional fields support to ERM agreements
  >This adds the option to add additional fields to ERM agreements. The fields can be either free text or linked to an authorized value for a pull down list. They be set to repeatable and made searchable.
- [37577](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37577) Add additional fields support to ERM packages
  >This adds the option to add additional fields to ERM packages. The fields can be either free text or linked to an authorized value for a pull down list. They be set to repeatable and made searchable.
- [37856](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37856) Some SUSHI providers require the platform parameter
  >This enhancement adds a new "platform" field to ERM's usage data providers, allowing the harvest of SUSHI usage data from providers that require this parameter.

### Fines and fees

#### Enhancements

- [34325](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34325) On the manual invoice and credit forms rename "Barcode" to "Item barcode" for clarity
  >This enhancement changes the form labels and error message for the manual invoice and credit forms for patrons (in the accounting section). This is to clarify that this field is for an item barcode, and not a patron card number barcode.

### Hold requests

#### Enhancements

- [28833](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28833) Speed up holds queue builder via parallel processing
  >This enhancement adds the ability to increase the amount of parallel calculations used to create the Holds Queue. The amount of calculations or "loops" done in parallel is set in the new system preference 'HoldsQueueParallelLoopsCount'. This enhancement will allow faster holds queue building for libraries with a very large amount of holds. Note that increasing the value in the system preference also causes Koha to use more resources when building the holds queue.
- [29079](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29079) Make bibliographic information in holds queue customizable
  >This enhancement adds two new columns to the holds queue table - Author and Publication details. It removes this information from the title column. Libraries can use table settings to hide this information, for example, if you only want to show the title in the holds queue.
- [30411](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30411) Add separate shelving location column to holds queue
  >Adds shelving location as its own column in the holds queue. This makes it easier to sort the holds queue by shelving location.
- [36064](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36064) Add information about holds with cancellation requests to staff start page
  >This enhancement adds a "Holds with cancellation requests: X" link to the staff interface home page. This makes it more visible to librarians that patrons have made cancellation requests, and action them (where patrons have the ability to cancel holds).
- [36595](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36595) Add patron email to the holds queue table
  >This enhancement adds a patron's email address (when it exists) to the patron column for the holds queue table (Circulation > Holds and bookings > Holds queue). (This requires setting the HidePatronName system preference to 'Show'.)

### I18N/L10N

#### Enhancements

- [37781](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37781) Add translation context for "On" (when used alone)
  >This enhancement adds translation context to the word "On" when it is used alone. In the item search page, it means "on a specific date", and on the SMTP server administration page, it means "on" as in "not off". The translation context separates the two strings so that they can be translated individually.

### ILL

#### New features

- [35570](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35570) Add a generic master form in ILL
  >This incorporates the ILL backend previously known as "FreeForm" (https://github.com/PTFS-Europe/koha-ill-freeform) into core Koha, now labeled as "Standard".
  >This allows the ILL module to be used as soon as the ILLModule system preference is enabled, without the need to install additional third-party backends, although the option to do so still exists.
  >Upon upgrading, all prior "FreeForm" ILL requests, attributes, and comments will be transferred to the new "Standard" backend.

#### Enhancements

- [36118](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36118) ILL request log does not display patron information
  >With the IllLog system preference enabled, the actions logged for each ILL request lacked details about which patron user performed the action. This enhancement addresses this.

  **Sponsored by** *PTFS Europe* and *UKHSA - UK Health Security Agency*
- [36221](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36221) Improve styling of Standard backend create OPAC form
  >This makes various improvements to the ILL request form in the OPAC to make it more consistent with the other forms in Koha. This includes fixes to the styling of required fields, terminology and translations.

### Installation and upgrade (command-line installer)

#### Enhancements

- [34088](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34088) Schema upgrade should short circuit faster if no upgrade needs to be done
  >This change makes koha-schema-upgrade use an optimized check if a database upgrade is needed before attempting the usual slower upgrade process. This makes Koha upgrades, which don't need database updates, much faster.

### Lists

#### Enhancements

- [30955](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30955) Send a notice to new owner when transferring shared list
  >This enhancement adds a new notice, TRANSFER_OWNERSHIP, under a new module, Lists. When a list is transferred to a new owner, this notice is triggered, containing a short paragraph detailing the list name.
- [37177](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37177) "item" should be "record" in list page
  >This patch corrects some areas in the lists and carts so that the term 'record' is used instead of 'item' when referring to a bibliographic record.

  **Sponsored by** *Athens County Public Libraries*

### MARC Authority data support

#### Enhancements

- [35305](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35305) Add XSLT for authority details page in staff interface
  >This enhancement enables using custom XSLT stylesheets to display authority detail pages in the staff interface. 
  >
  >Enter a path to the custom XSLT file in the new system preference AuthorityXSLTDetailsDisplay (or use an external URL). Use placeholders for multiple custom style sheets for different languages ({langcode}) and authority types ({authtypecode}).
  >
  >(Note: This ability is already available for the OPAC. It was added by bug 21330 to Koha 23.05 and 22.11.07).
- [36603](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36603) UNIMARC: automatically copy the ISNI number over when linking authorities with authorities
  >This enables the automatic copying over of authority subfield 010$a [aka INTERNATIONAL STANDARD NAME IDENTIFIER (ISNI)] into the corresponding 5xx$o subfield when linking authorities with other authorities in UNIMARC instances. It only applies to the Personal Name, Corporate Body Name, and Family Name authority types.
- [37122](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37122) Update MARC21 authority frameworks to Update 30
  >This enhancement updates the MARC21 authority frameworks for new installations to reflect the changes from Update 30 (May 2020).
  >
  >NOTES:
  >- For existing installations, manually updating the default and other frameworks with the changes is required.
- [37123](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37123) Update MARC21 authority frameworks to Update 31
  >This enhancement updates the MARC21 authority frameworks for new installations to reflect the changes from Update 31 (December 2020).
  >
  >NOTES:
  >- For existing installations, manually updating the default and other frameworks with the changes is required.
- [37124](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37124) Update MARC21 authority frameworks to Update 32
  >This enhancement updates the MARC21 authority frameworks for new installations to reflect the changes from Update 32 (June 2021).
  >
  >NOTES:
  >- For existing installations, manually updating the default and other frameworks with the changes is required.
- [37125](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37125) Update MARC21 authority frameworks to Update 33
  >This enhancement updates the MARC21 authority frameworks for new installations to reflect the changes from Update 33 (November 2021).
  >
  >NOTES:
  >- For existing installations, manually updating the default and other frameworks with the changes is required.
- [37128](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37128) Update MARC21 authority frameworks to Update 34
  >This enhancement updates the MARC21 authority frameworks for new installations to reflect the changes from Update 34 (July 2022).
  >
  >NOTES:
  >- For existing installations, manually updating the default and other frameworks with the changes is required.
- [37132](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37132) Update MARC21 authority frameworks to Update 35
  >This enhancement updates the MARC21 authority frameworks for new installations to reflect the changes from Update 35 (December 2022).
  >
  >NOTES:
  >- For existing installations, manually updating the default and other frameworks with the changes is required.
- [37133](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37133) Update MARC21 authority frameworks to Update 36
  >This enhancement updates the MARC21 authority frameworks for new installations to reflect the changes from Update 36 (June 2023).
  >
  >NOTES:
  >- For existing installations, manually updating the default and other frameworks with the changes is required.
- [37134](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37134) Update MARC21 authority frameworks to Update 37
  >This enhancement updates the MARC21 authority frameworks for new installations to reflect the changes from Update 37 (December 2023).
  >
  >NOTES:
  >- For existing installations, manually updating the default and other frameworks with the changes is required.
- [37135](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37135) Update MARC21 authority frameworks to Update 38
  >This enhancement updates the MARC21 authority frameworks for new installations to reflect the changes from Update 38 (June 2024).
  >
  >NOTES:
  >- For existing installations, manually updating the default and other frameworks with the changes is required.
- [37349](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37349) Use cache for authority types when linking bibliographic records to authorities

### MARC Bibliographic data support

#### Enhancements

- [36055](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36055) Simplify MARC21 fast add framework
  >This enhancement updates the fast add framework (FA) to remove unnecessary fields (which defeated the purpose of having a way to quickly add a minimal record). **Important note**: This update only affects new installations. See the bug details (comment #2) for a list of changes if you would like to update your existing FA framework.
- [37114](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37114) Update MARC21 default framework to Update 38 (June 2024)
  >This enhancement updates the default MARC21 bibliographic framework for new installations to reflect the changes from Update 38 (June 2024).
  >
  >NOTES:
  >- For existing installations, manually updating the default and other frameworks with the changes is required.
  >- For new installations, only the default framework is updated. Manually updating other frameworks with the changes is required.
- [37120](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37120) Add heading subfields for 647 (MARC21)
  >This enhancement updates the default MARC21 bibliographic framework to add subfields a, c, d, and g to field 647.
  >NOTE: This does not affect existing installations. If you are upgrading and wish to have the subfields in your bibliographic framework, add them via Administration > MARC bibliographic framework.
- [37121](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37121) MARC21 Addition to relator terms in technical notice 2024-05-14
  >This patch adds new relator codea in the list of MARC21 relator terms in Koha:
  >
  >- wfs - Writer of film story
  >- wft - Writer of intertitles
  >- wts - Writer of television story
  >
  >Note: this is added in the installer files. It will not affect existing installations. For existing installations, add the new relator code in Administration > Authorized values > RELTERMS.

### Notices

#### Enhancements

- [17976](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17976) TT syntax for notices - Add an equivalence for items.fine
  >This patch adds an easy accessor method for fetching a checkouts overdue fines.  This is of particular interest to notice template authors as you can now use the following snippet in your notices:
  >
  >`[% overdue.overdue_fines.total_outstanding | $Price %]`
- [23295](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23295) Automatically debar patrons if SMS or email notice fail
  >This enhancement adds the new system preference 'RestrictPatronsWithFailedNotices' to allow Koha to automatically restrict patrons when SMS or email notices fail to reach them. The system preference is turned off by default. To turn it on, set the system preference to 'Apply'. This system preference requires the misc/cronjobs/restrict_patrons_with_failed_notices.pl cronjob.

  **Sponsored by** *Catalyst*
- [29194](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29194) Patron messaging preferences should be logically ordered
  >This changes the sequence of the notices in the messaging preferences table to be more logical and roughly chronological.
- [36758](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36758) We should notify an assignee when they are assigned a ticket
  >This enhancement to catalog concerns notifies staff when a new concern is assigned to them for action (when CatalogConcerns and OpacCatalogConcerns are enabled). It uses a new TICKET_ASSIGNED notice. No notice is sent when it is self-assigned.
  >

  **Sponsored by** *PTFS Europe*
- [36815](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36815) Add the option to 'Reset to default' in the notices editor
  >This enhancement adds a new 'View default' button to the notices editor for notices that ship in the sample data for Koha.
  >
  >This button allows you to display the default sample notice in a popup modal and even reset the notice your currently editing to that default.
  >

  **Sponsored by** *PTFS Europe*

### OPAC

#### New features

- [14670](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14670) Add 'cite' option to detail page in OPAC
  >This adds a new 'Cite' option to the toolbar on the right of the bibliographic details on the details page in the OPAC. When clicked, you are presented with citations for the viewed record using different citation styles.

  **Sponsored by** *Orex Digital* and *Regionbibliotek Halland / County library of Halland*
- [26777](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26777) Give the user the option to display their patron card barcode from the OPAC
  >This adds the option to display the patron's library card as a barcode within their library account, so it can be scanned at the circulation desk or a self check machine.
  >The feature can be activated using the new system preference `OPACVirtualCard`.

#### Enhancements

- [26933](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26933) Improve handling of multiple covers on catalog search results in the OPAC
  >This enhancement adds the slider widget for multiple cover images on the OPAC search results page (when multiple sources enabled), matching the way covers display on the detail page.

  **Sponsored by** *Athens County Public Libraries*
- [30873](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30873) "Libraries" link on OPAC should be hideable by system preference
  >This enhancement adds a system preference which allows the Koha administrator to hide the "Libraries" link which appears under the main search bar in the OPAC. The preference is enabled by default because that reflects the previous default behavior.

  **Sponsored by** *Athens County Public Libraries*
- [33317](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33317) Add system preference to set meta robots for the OPAC
  >This enhancement adds a new system preference,  OpacMetaRobots which allows libraries to tell search engine robots how to crawl and index OPAC pages.
- [34486](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34486) Hide more OPAC holdings table columns when they are empty
  >This patch updates the OPAC bibliographic detail page so that in the holdings table, the following columns are hidden if they contain no data: Call number, date due, materials, checkouts, barcode, and item-level holds.

  **Sponsored by** *Athens County Public Libraries*
- [36141](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36141) Add classes to CAS text on OPAC login page
  >This enhancement adds classes to the CAS-related messages on the OPAC login page. This will make it easier for libraries to customize using CSS and JavaScript. The new classes are cas_invalid, cas_title, and cas_url. It also moves the invalid CAS login message to above the CAS login heading (the same as for the Shibboleth login).
- [36453](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36453) BlockExpiredPatronOpacActions should allow multiple actions options
  >This enhancement improves the BlockExpiredPatronOpacActions system preference to allow the specification of which OPAC actions are blocked for expired patrons.
  >Prior to this enhancement, this system preference functioned as a simple "on" or "off" switch, where having it 'on' blocked both 'placing holds' and 'renewing an item' for expired patrons on the OPAC.
- [36651](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36651) Add placeholder text to the search bar in the OPAC
  >This enhancement updates the style of the OPAC search bar's placeholder text, the text which is shown in the text field when the user has not entered any text. Previously the style of the placeholder made it look very much like text the user had typed. Now the placeholder is right-aligned and italic in order to distinguish it from regular text, while keeping a color which has accessible contrast.
- [37046](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37046) Use template wrapper for OPAC curbside pickup tabs
  >This enhancement makes structural changes to the way the OPAC curbside pickups page is generated for more consistency and ease of upgrade to new Bootstrap versions.
- [37048](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37048) Use template wrapper for self checkout page
  >This enhancement makes structural changes to the way the self checkout page is generated for more consistency and ease of upgrade to new Bootstrap versions.
- [37221](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37221) No way to turn off OverDrive integrations without removing all system preference values
  >This patch adds the new system preference `OPACOverDrive`. It allows a library to disable OverDrive features without having to remove one or more of their OverDrive credentials.

  **Sponsored by** *Athens County Public Libraries*
- [37391](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37391) QR code for bibliographic record in OPAC should use canonical link
  >This patch updates QR code creation from a bibliographic record in the OPAC to use the canonical version of the URL to the bibliographic record, making the shared URL much shorter and the created QR code less complicated. Note that the system preference OPACDetailQRCode must be set to 'Enable' in order to show the QR code in the bibliographic record's detail page in the OPAC.
- [37412](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37412) Style placeholder text in the OPAC
  >This enhancement adds a custom style to the placeholder text shown in the OPAC's main search bar when it is empty. Previously the placeholder text color was very close to the color of user-entered text, making it difficult to distinguish the state of the form. Rather than adjusting the color of the placeholder text in a way that makes the contrast unacceptable, this changes the text to right-aligned italic text.

  **Sponsored by** *Athens County Public Libraries*
- [37972](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37972) Allow selection of tab in patron's summary table by query param
  >This enhancement adds the ability to direct links to specific tabs of the OPAC patron summary with the following syntax:
  > /cgi-bin/koha/opac-user.pl?tab=opac-user-holds

### Patrons

#### New features

- [28633](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28633) Add a preferred name field to patrons
  >This patch adds a new column to the borrowers table, 'preferred_name'. This will be visible in staff and OPAC patron forms by default. This column takes precedence in display and will show where patrons are displayed throughout Koha. If not populated or field is hidden, the first name will be copied into the preferred name field for display. Use of 'firstname' in notices and other templates will continue to display the first name, switching to 'preferred_name' will display the new field.
  >When hiding this field, it should be hidden in all interfaces to avoid any discrepancies or confusion.

#### Enhancements

- [23486](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23486) TrackLastPatronActivityTriggers should have an option for patron creation
  >This enhancement adds 'Creating a patron' as an option to the TrackLastPatronActivityTriggers system preference (for updating the last seen date). Previously, creating a patron was not an option for updating the last seen date - this could understate reports about active patrons.
- [27123](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27123) Add messages to batch patron modification
  >This adds patron messages to the batch patron modification tool form. It allows to add new messages to multiple patron accounts at a time and also to delete all messages on these accounts at once.
- [33462](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33462) Force password change for new patrons entered by staff
  >This adds a new option to the patron category administration pages, that allows to enforce a password reset on first login for any patron accounts created manually in the staff interface.
- [34608](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34608) Add sort1 and sort2 to patron search results
  >This enhancement adds the option of displaying patron "sort1" and "sort2" statistical fields in the patron module's main search results, using column visibility controls. The fields are hidden by default in the updated table configuration.
- [36085](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36085) Setting and unsetting the protected flag should be limited to superlibrarian accounts
  >Only patrons with superlibrarian permissions will be able to set or remove the "Protected" flag on patron accounts
- [36169](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36169) Add guarantee to patron categories with category type 'Staff'
  >This allows patrons with a patron category of the type "Staff" to have guarantees linked to them.
- [36454](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36454) Provide indication if a patron is expired or restricted on patron search autocomplete
  >This enhancement adds "Expired" or "Restricted" information badges to patron autocomplete search suggestions, where these criteria apply.
- [36912](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36912) Add more spans/classes to member-display-address-style.inc for additional styling
  >This enhancement adds spans and classes for customizing the styling of a patron's main address when using IntranetUserCSS.
  >
  >Example:
  >
  >.patronaddress1 {
  >  .streetnumber {
  >    color: blue;
  >  }
  >  .address1 {
  >    color: green;
  >  }
  >  .roadtype {
  >    color: pink;
  >  }
  >}
  >
  >.patronaddress2 {
  >  color: lightgreen;
  >}
  >
  >.patroncity {
  >  .city {
  >    color: orange;
  >  }
  >  .state {
  >    color: brown;
  >  }
  >  .zipcode {
  >    color: limegreen;
  >  }
  >  .comma {
  >    color: teal;
  >  }
  >  .country {
  >    color: red;
  >  }
  >}
- [37323](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37323) Remote-Code-Execution (RCE) in picture-upload.pl
  >This change sanitizes filenames used in picture upload and validates the datalink.txt/idlink.txt contents to prevent remote code execution (RCE).

### Plugin architecture

#### Enhancements

- [35568](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35568) Add a plugin hook to allow modification of notices created via GetPreparedLetter
- [37033](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37033) Allow plugins to load JavaScript on the cart pop-up in the staff interface
- [37495](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37495) Add ability to use metadata to filter plugins to run for plugins_nightly.pl
  >This enhancement allows the plugins_nightly.pl cronjob to execute the nightly cronjob plugin hook for one or more specific plugins. This allows greater flexibility in scheduling the nightly cronjobs for various plugins and allows a single plugins cronjob hook to be run without trigger other plugins cronjob hooks.

### REST API

#### New features

- [28965](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28965) Add public routes for lists
  >This enhancement adds new public API endpoint for retrieving lists.

#### Enhancements

- [30660](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30660) Add cancellation reason to holds delete endpoint
  >This enhancement adds the ability to send a hold cancellation reason to the delete hold API endpoint.

  **Sponsored by** *Koha-Suomi Oy*
- [30661](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30661) Able to update more hold parameters via REST API
  >This enhancement adds API endpoints to update the hold_date and expiration_date via the API.

  **Sponsored by** *Koha-Suomi Oy*
- [35197](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35197) Expose additional_field definitions through REST API
  >This enhancement adds a new REST API endpoint for exposing configured additional fields:
  >/api/v1/extended_attribute_types
  >
  >Configured additional fields for a specific resource are queried as follows e.g. invoice:
  >/api/v1/extended_attribute_types?resource_type=invoice

  **Sponsored by** *PTFS Europe* and *UKHSA - UK Health Security Agency*
- [35430](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35430) Add endpoints for managing stock rotation rota's
  >This enhancement adds API endpoints for managing stock rotation rotas.
- [36480](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36480) Add GET /libraries/:library_id/desks
  >This enhancement adds an API endpoint for requesting a list of desks for a library. For example: http://127.0.0.1:8080/api/v1/libraries/cpl/desks
- [36481](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36481) Add GET /libraries/:library_id/cash_registers
  >This enhancement adds an API endpoint for requesting a list of cash registers for a library. For example: http://127.0.0.1:8080/api/v1/libraries/cpl/cash_registers
- [36641](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36641) Add an endpoint to list circulation rules
  >This enhancement adds a new `/circulation_rules` endpoint to the API's to allow fetching of circulation rules.
  >
  >It requires item_type, patron_category and library as parameters and accepts an options 'rules' parameter to allow listing only rules that are of interest.
- [37253](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37253) Enhance POST /checkouts endpoint to accept barcode or item_id
  >The enhancement adds the ability to accept the barcode for a checkout via the API. If the origin only had access to the barcode and not the itemnumber a second API call was previously required to perform a checkout with only the barcode.
- [37686](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37686) render_resource_not_found() and render_resource_deleted() misses
  >This development finished the code cleanup we implemented on bug 36495, by performing the same code changes in new code that was added in between and some misses too.
- [37809](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37809) Add missing embeds to checkouts endpoints
- [37850](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37850) branchillemail missing from public libraries REST endpoint
  >This enhancement adds the library's e-mail address for interlibrary loans to the following public REST API endpoint's response:
  ><opac_url>/api/v1/public/libraries
- [37902](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37902) Timezone ignored when passing rfc3339 formatted date (search 'q')
  >RFC3339 formatted dates are not correctly taken into account when passed to an attribute via the 'q' parameter

### Reports

#### Enhancements

- [32413](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32413) JSON reports shows inaccurate results with repeated parameters
  >When creating a reports with runtime parameters that use the same description, the form in Koha would present only one input field for them, but the JSON API required to send the value multiple times for each occurrence of the runtime parameter. This makes the behavior in Koha and the JSON API match in that the parameter needs to be only sent once.
  >
  >**Important:** Scripts using the JSON feature with repeatable parameters before this change will need to be adapted.

  **Sponsored by** *Koha-Suomi Oy*
- [37188](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37188) Batch patron modification from report results should be an option when borrowernumber is selected
  >Some libraries do not use card numbers for their patrons, but would still like to be able to batch modify patrons from reports. This will makes it so that adding the borrowernumber to a report will also allow to trigger batch patron modifications.
- [37508](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37508) SQL reports should not show patron password hash if queried
  >This enhancement on reports module prevents SQL queries from being run if they would return a password field from the database table.

  **Sponsored by** *Reserve Bank of New Zealand*

### SIP2

#### Enhancements

- [18317](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18317) Allow check out of already checked out items through SIP
  >This enhancement allows checkouts of items already checked out to someone else when using SIP2. This is enabled using the new system preference AllowItemsOnLoanCheckoutSIP. 
  >
  >Example use case: Patron A has checked out a book and tried to return it, but for some reason it hasn't been properly checked in - but it was re-shelved anyway. Patron B wants to borrow this book from an unstaffed library, but the self-checkout blocks them because the book is still checked out to Patron A.
- [37087](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37087) Add support for TCP keepalive to SIP server
  >This change adds 3 new configuration options to the SIPconfig.xml. These are custom_tcp_keepalive, custom_tcp_keepalive_time, and custom_tcp_keepalive_intvl. Usage is documented in C4/SIP/SIPServer.pm. They are used to control TCP keepalives for the SIP server. Configuration of these parameters is essential for running a SIP server in Microsoft Azure.

### Searching

#### Enhancements

- [14322](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14322) Add option to create a shareable link for item searches
  >This enhancement adds a 'Copy shareable link' button to item search results in the staff interface. Previously, the only way to share a search with colleagues was by detailing all the search parameters - and they would then need to manually add these to the item search form.

  **Sponsored by** *Cape Libraries Automated Materials Sharing*
- [34481](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34481) Add IncludeSeeAlsoFromInSearches like IncludeSeeFromInSearches
  >This enhancement adds 'see also from' authority record headings (5XX) to bibliographic searches. This is enabled by using the new IncludeSeeAlsoFromInSearches system preference, and requires a reindex.
- [36991](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36991) Add ability to scan call numbers index/search field
  >This adds 'call number' to the available search options when using the 'scan indexes' feature from the advanced search page in the staff interface.
- [37238](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37238) Add table settings to itemsearch results
  >The item search results table is now configurable via the table settings.
- [37969](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37969) Add missing language code nor (Norwegian/inclusive)
  >This enhancement adds the language code nor for the Norwegian inclusive language ISO 639-2 to Koha.

### Searching - Elasticsearch

#### Enhancements

- [36725](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36725) Add "current publication frequency" to Elasticsearch index mappings (MARC21 310$a)
  >This updates the default Elasticsearch mappings to include MARC 310$a - current publication frequency. Please note that this will only affect new installations. If mappings are reset to default on existing installations a full reindex is required.

  **Sponsored by** *Education Services Australia SCIS*
- [36727](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36727) Add incorrect ISSN to Elasticsearch index mappings
  >This enhancement makes changes to International Standard Serial Number (ISSN) related index mapping when using Elasticsearch or Open Search.
  >
  >A new issn-all search field enables finding all records with any ISSN related to that content. For example, you are able to find the online and paper version of a serial with one search.
  >
  >The issn search field remains a precise search - you get the exact record with the ISSN in 022$a (MARC21) or 011$a (UNIMARC).
  >
  >MARC21:
  >- Adds these subfields to the new issn-all search field:
  >  . 022$a (International Standard Serial Number)
  >  . 022$y (Incorrect ISSN)
  >  . 022$z (Canceled ISSN)
  >  . 023$a (Cluster ISSN)
  >  . 023$y (Incorrect Cluster ISSN)
  >  . 023$z (Canceled Cluster ISSN)
  >- Adds 022$y, 022$z, 023$a, 023$y, and 023$z to the identifier-standard search field
  >
  >
  >UNIMARC:
  >- Adds these subfields to the new issn-all search field:
  >  . 011$a (Number (ISSN)
  >  . 011$y (Cancelled ISSN)
  >  . 011$z (Erroneous ISSN or ISSN-L)
  >- Removes 011$y and 011$z from the issn search field
  >
  >These changes will only take effect for existing installations if the index mappings are reset (caution: existing customizations are lost) and records are re-indexed.

  **Sponsored by** *Education Services Australia SCIS*
- [36798](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36798) Add ability to search across all ISBNs using the ISBN-search
  >The new system preference `SearchCancelledAndInvalidISBNandISSN` allows to include invalid and cancelled ISBNs (MARC21 020/022 $z) in searches for ISBN and ISSN.

  **Sponsored by** *Ignatianum University in Cracow*
- [36952](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36952) Add 370 to authority index (MARC21)
  >This enhancement adds field 370 (associated place) to the default MARC21 authority index mappings when using Elasticsearch or Open Search (it is already indexed if using Zebra).
- [36953](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36953) Add 678 to authority index (MARC21)
  >This enhancement adds field 678 (biographical or historical data) to the default MARC21 authority index mappings when using Elasticsearch or Open Search (it is already indexed if using Zebra).

### Staff interface

#### New features

- [33484](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33484) Ability to remember user's selected table configuration and search filters for tables
  >This new feature adds two new options to the table settings.
  >When enabled the state of the table, meaning the column selection and search filters, will be restored to what as formerly set by the user.
  >
  >* "Save configuration state on page change": save the column visibility, length of the table and order in session.
  >* "Save search state on page change": save the search and filtering in session.
  >
  >Please note: When you hide columns permanently using the settings on the table configuration page in the administration module, it will require users to log out/log in again for the change to take effect.
  >
  >Additionally a new button "Copy shareable link" is added to the tables. It will copy a link with the current state of the table into the clipboard, so you can save it as a bookmark or share it with someone else.

#### Enhancements

- [2486](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=2486) Show user comments in staff interface
  >This enhancement shows OPAC comments on the staff interface record, making it easier for staff to view comments on items when the "OPACComments" system preference is turned on.
- [20411](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20411) Remove StaffDetailItemSelection system preference and make the feature always on
  >Removes the system preference StaffDetailItemSelection which is no longer needed. The item selection column in the holdings table is now configurable via Table settings configuration.
- [30623](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30623) Copy permissions from one user to another
  >This enhancement makes it a lot easier to create staff users with similar or identical permission profiles by allowing it to copy the permission settings from one user to another.
- [35153](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35153) Convert IntranetmainUserblock system preference to additional contents
  >This enhancement converts the IntranetmainUserblock system preference to an entry in Tools -> Additional contents. This allows the user to create content to be shown on the staff client home page in multiple languages or with custom content for each library.
- [35191](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35191) Make entries per page configurable for items table on staff detail page
  >Add an option, in the Tables page of the Administration module, to adjust how many items per page will display by default in the item holdings table on a bibliographic record.
- [35402](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35402) Update the OPAC and staff interface to Bootstrap 5
  >This enhancement updates the version of the Bootstrap library that Koha uses from Bootstrap 4 to Bootstrap 5 (Bootstrap 4 is end of life and is no longer updated).
  >
  >We use [bootstrap](https://getbootstrap.com/) for both the OPAC and staff interface to help keep our styling consistent and responsive.
- [36777](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36777) Create a new section for system preferences related to lost item handling
  >This enhancement moves lost item circulation system preferences from 'Checkout policy' to a new 'Lost item policy' section.
- [36941](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36941) Highlight that some libraries should not be available at login when StaffLoginRestrictBranchByIP is enabled
  >This enhancement changes the staff interface login form so that only valid libraries are shown in the dropdown list when the `StaffLoginRestrictBranchByIP` preference is enabled.
- [37004](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37004) Staff search results: Add a HTML class ( branchcode ) to each item entry in the results list
  >This enhancement to staff interface search results adds the library code as an HTML class to each item entry in the location column. This makes it easier to add custom CSS/JavaScript for libraries to the search results.
- [37141](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37141) Add option to display completed bookings from patron page
  >This enhancement to bookings now shows completed bookings for patrons on their check out and details page. There is now a filter to show expired and hide expired bookings (similar to what is shown on a record's bookings page.)
- [37309](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37309) Improve delete and modify items links on the bibliographic detail page
  >This enhancement improves the way batch operation controls are dynamically generated when the user checks one or more checkboxes under the holdings tab on the bibliographic detail page. The markup has also been updated in order to improve consistency in the way the controls are styled.
- [37574](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37574) Add visual indicator that bookings are expired
  >This enhancement adds a visual indicator for expired bookings in the bookings table by displaying a status column with 'Expired' and 'Active' labels, making it easier to identify expired bookings when viewing or filtering them.
  >

  **Sponsored by** *Büchereizentrale Schleswig-Holstein*

### System Administration

#### Enhancements

- [27490](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27490) Rename system preference language to StaffInterfaceLanguages
  >This enhancement renames the 'language' system preference to 'StaffInterfaceLanguages', to make the name clearer and more meaningful.
- [28575](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28575) Add ability to choose if lost fee is refunded based on when lost fee was paid off
  >This adds a new system preference `NoRefundOnLostFinesPaidAge` that allows the user to control how long after a lost fee has been paid a refund will be issued if the item is found and returned.

  **Sponsored by** *Rapid City Public Library*
- [33731](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33731) Allow audio alerts to be used on SCO pages
  >Makes audio alerts accessible in the self checkout module by default. Staff can now pick sounds from the list in the Audio alerts configuration and no longer need a full path URL to make sounds available in the self checkout module.
- [35044](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35044) Additional fields: Allow for repeatable fields
  >This enhancement adds the "repeatable" option for additional fields. 
  >
  >For repeatable text fields there is now:
  >- an "Add new" button for adding a new text field
  >- a "Remove" button for the removal of a repeatable text field. 
  >
  >For repeatable fields using authorized values, the options are now shown as checkboxes instead of a dropdown list, and allows multiple selections.
- [37436](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37436) Move EmailPatronWhenHoldIsPlaced to holds policy system preferences
  >This patch moves the EmailPatronWhenHoldIsPlaced system preference from Circulation > Patron restrictions to Circulation > Holds policy.
- [37513](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37513) Disable 'Delete' button if the record source cannot be deleted
  >This enhancement to the record sources feature (added in Koha 24.05) removes the 'Delete' action from the record sources table if there are bibliographic records that use the record source.
  >
  >Previously, if you tried to delete a record source that was in use, you would get an unhelpful error message "Something went wrong: Error: Something went wrong, check Koha logs for details.".
- [37888](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37888) Default filtering of background jobs could be improved
  >This updates the display and filter option for background jobs. By default the background jobs page now shows the most recently queued jobs, whatever their status is, and allows to filter on the current pending and running jobs.
- [38053](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38053) Change section and description of DefaultLongOverduePatronCategories and DefaultLongOverdueSkipPatronCategories system preferences
  >This enhancement moves the DefaultLongOverduePatronCategories and DefaultLongOverdueSkipPatronCategories system preferences to the Lost item policy section of the circulation preferences, to be with the other DefaultLongOverdue system preferences.
  >It also changes the description of the system preferences to make it clearer it has to do with the **long overdues** process and not just the overdues process.

### Templates

#### Enhancements

- [32218](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32218) Rephrase: Allow OPAC access to users from this domain to login with this identity provider.
- [33195](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33195) Reindent the bibliographic details page
  >This updates the template file used to display the bibliographic detail page in the staff interface. It re-indents the file so that it has consistent indentation, and adds comments to highlight the markup structure. This is a developer-oriented change with no visible effect to the user.
- [33526](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33526) Use template wrapper for tabs: bibliographic detail page
- [33907](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33907) Improve translation of title tags: OPAC part 1
  >This enhancement makes structural changes to the way OPAC pages are built to make it easier for translators to translate the text in the page's <title> tag.
  >
  >Some pages were also updated for consistency: harmonizing page title, breadcrumb navigation, and page headers.
- [33925](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33925) Improve translation of title tags: Serials
  >This enhancement updates the templates for the serials pages to allow title tags to be more easily translated. It also updates some templates to add consistency for the page title, breadcrumb navigation, and page headers, and to add the "page-section" <div> where it was lacking.
- [35838](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35838) Use template wrapper for tabs: Curbside pickups administration
  >This enhancement makes structural changes to the way the curbside pickups administration page is generated for more consistency and ease of upgrade to new Bootstrap versions.
- [36911](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36911) Reindent circ-menu.inc
  >This updates the circ-menu.inc include file used for the left-hand sidebar menu on circulation pages (when the CircSidebar system preference). It reindents the file so that it has consistent indentation, and adds comments to highlight the markup structure. These changes have no visible effect on the pages.
- [36945](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36945) Fix several missed instance of breadcrumb WRAPPER use
  >This enhancement makes structural changes to the way the breadcrumb menu is generated on several pages for more consistency and ease of upgrade to new Bootstrap versions.
- [37515](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37515) Add common class to all places where an item type image is shown
  >This enhancement changes the markup which is used to show item type images in both the OPAC and staff interface. The change adds a common class attribute, "itemtype-image", so that the display of these images can be changed with custom CSS.

  **Sponsored by** *Athens County Public Libraries*
- [37578](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37578) Remove the Charges tab from checkout and patron details
  >This patch removes the unused 'Charges' tab from the include file for patron accounts in the circulation and patron details templates. Information about charges and credits is already shown as a warning message at the top of these pages as well as in the left side menu in the 'Accounting' tab.

  **Sponsored by** *Athens County Public Libraries*

### Tools

#### Enhancements

- [37103](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37103) Link log viewer options to corresponding system preference
  >This patch updates the log viewer interface to show a warning icon next to each module for which logging is disabled. If the user has the correct permissions, the warning icon links directly to the corresponding system preference for enabling the log.
- [37943](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37943) Object creation should be logged with a JSON diff of changes, implement for items
  >This enhancement will store modification diffs, if the action is set to ADD or CREATE and an "original" object is passed in.
- [37944](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37944) Object deletion should be logged with a JSON diff of changes, implement for items
  >This enhancement will store modification diffs, if the action is set to DELETE, and an "original" object is passed in.

### Web services

#### Enhancements

- [31161](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31161) OAI-PMH - Honour OpacHiddenItems system preferences
  >This patch alters the OAI-PMH code to respect the OpacHiddenItems and OpacHiddenItemsHidesRecord system preferences when all items on a record are hidden. In this case, the server will now return the record as 'deleted' - this way if an item is changed in a way that marks it hidden, and it is the last item on the record, the next harvest will pickup this change and remove the record
- [36315](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36315) ILSDI GetRecord speed improvement
  >This change makes the items.location lookup in the ILSDI GetRecords service use a cached lookup rather than a per-item lookup for location values, which makes the ILSDI service return much more quickly for records with many items.

### Z39.50 / SRU / OpenSearch Servers

#### Enhancements

- [36996](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36996) Add a system preference to mark items unavailable in Z39.50 responder
  >This adds a new system preference `z3950Status` which takes a YAML block and marks any items matching the conditions as unavailable in Z39.50 results
  >It obeys the existing `AdditionalFieldsInZ3950ResultSearch` system preference settings, adding item status to field 952 $k.
## Bugfixes
This list includes all bugfixes since the previous major version. Most of them
have already been fixed in maintenance releases


#### Critical bugs fixed

- [34444](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34444) Statistic 1/2 not saving when updating fund after receipt (24.11.00,24.05.02,23.11.07,23.05.15)
- [36995](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36995) Can't delete library EAN (24.11.00,24.05.02)
  >This fixes the Library EANs page so that EANs can be deleted. After the CSRF update in 24.05 (bug 34478), the 'Delete' action for an EAN no longer worked as it should.
- [37089](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37089) Cannot delete a fund or a currency (24.11.00,24.05.02)
  >This fixes the acquisitions funds and currencies pages so that they can be deleted. After the CSRF changes in 24.05 to improve form security, the 'Delete' actions no longer worked. The deletion confirmation message was displayed with '' for the name and no values for the fund or currency, then didn't delete them.
- [37090](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37090) Cannot delete an EDI account (24.11.00,24.05.02)
  >This fixes the EDI accounts page (Acquisitions > Administration (when EDIFACT is enabled)) so that accounts can be deleted. After the CSRF changes in 24.05 to improve form security, the 'Delete' action for an EDI account no longer worked.
- [37316](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37316) Cannot add items to basket via file if barcodes not supplied (24.11.00,24.05.02)
  >This fixes an error when using order files from a vendor to stage and add records with items to a basket. If barcodes are not specified for the items (either from the file or manually), this caused an error when saving. Order files without barcodes can now be used.
- [37377](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37377) Orders search is not returning any results (24.11.00,24.05.02)
  >This fixes the orders search in Acquisitions - clicking the search button was doing nothing and not returning any results. (This is related to the CSRF changes added in Koha 24.05 to improve form security.)
- [37533](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37533) Invalid query when receiving an order (24.11.00,24.05.03,23.11.08,23.05.14)
- [38183](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38183) Can't set suggestion manager when there are multiple tabs (24.11.00,24.05.05)
- [38343](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38343) False display of closed invoices in receive process (24.11.00)
- [38437](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38437) Modal does not appear on single order receive (24.11.00)
- [36520](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36520) SQL Injection in opac-sendbasket.pl (CVE-2024-36058) (24.11.00,24.05.01,23.11.06,23.05.12,22.11.18,22.05.22)
- [36598](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36598) Add CSRF protection to Mojolicious apps (24.11.00,24.05.04)
- [36736](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36736) Add ability to load DBIx::Class Schema files found in plugins (24.11.00)
- [36863](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36863) CSRF Plack middleware doesn't handle the CONNECT HTTP method
  >24.11.00,24.05.02
- [36875](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36875) SQL injection in additional content pages (24.11.00,24.05.01,23.11.06)
- [37040](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37040) ErrorDocument accidentally setting off CSRF (24.11.00,24.05.02)
  >This improves the mechanism for preventing the activation of CSRF middleware by ErrorDocument subrequests. For example, a properly formatted 403 error page is now displayed instead of a plain text error. (This is related to the CSRF changes added in Koha 24.05 to improve form security.)
- [37056](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37056) CSRF error on login when user js contains a fetch of svc/report (24.11.00,24.05.06)
- [37152](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37152) Delete-confirm should not start with 'cud-' (24.11.00,24.05.02)
  >This fixes the delete actions in these areas so that they now work as they should:
  >
  >- Acquisitions: 
  >   . Contracts - couldn't delete a contract (no confirmation message, didn't delete) (Acquisitions > search for a vendor > Contracts > Delete > Yes, delete contract)
  >   . Baskets - could still delete a basket (so no change in behavour), however it wasn't using the correct code to do this (Acquisitions > search for a vendor > select a basket > Delete basket)
  >
  >- MARC bibliographic frameworks and authority types: couldn't delete tags - the confirmation message didn't have the tag description, and didn't delete (there was no error message, it just didn't delete the tag) (Administration > Catalog > MARC bibliographic framework OR Authority types > Actions > MARC structure > [choose a tag] > Actions > Delete)
  >
  >- Patron categories: when attempting to delete a patron category that was still in use - it generated an error message, instead of a warning that it was still in use (and didn't delete the category) (Administration > Patron categories > Delete > [Warning that can't delete if in use OR Confirm deletion])
  >
  >- Purchase suggestions in a patron's OPAC account: could still delete a purchase suggestion (so no change in behavour), however it wasn't using the correct code to do this (OPAC > Your account > Purchase suggestions > select suggestoon > Delete selected)
  >
  >(These fixes are related to the CSRF changes added in Koha 24.05 to improve form security.)
- [37260](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37260) Problem with connection to broker not displayed on the about page (24.11.00,24.05.04)
- [37371](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37371) Direct input of dates not working when editing only part of a date (24.11.00,24.05.04)
- [37464](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37464) Remote Code Execution in barcode function leads to reverse shell (24.11.00,24.05.03,23.11.08,23.05.14,22.11.20)
- [37509](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37509) Elasticsearch status info missing from 'Server information' (24.11.00,24.05.04)
  >This fixes the About Koha > Server information page so that it now shows information about Elasticsearch. Before this, it was empty.
- [37741](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37741) Koha errors on page (e.g. 404) cause incorrect CSRF errors (24.11.00,24.05.06)
  >This change prevents an error in a background call (e.g. a missing favicon.ico) from affecting the user's session, which can lead to incorrect CSRF 403 errors during form POSTs. (The issue is prevented by stopping error pages from returning the CGISESSID cookie, which overwrites the CGISESSID cookie returned by the foreground page.)
- [37824](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37824) Replace webpack with rspack for fun and profit (24.11.00)
- [38035](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38035) "sound" listed as an installed language (24.11.00,24.05.06)
- [38495](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38495) Cannot cancel background job (CSRF) (24.11.00)
- [36822](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36822) When creating a new patron via LDAP or Shibboleth 0000-00-00 is inserted for invalid updated_on (24.11.00,24.05.06)
- [35125](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35125) AutoCreateAuthorities creates separate authorities when thesaurus differs, even with LinkerConsiderThesaurus set to Don't (24.11.00,24.05.05,23.11.11)
- [37080](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37080) Cannot delete a MARC bibliographic framework or authority type (24.11.00,24.05.02)
  >This fixes the forms so that you can now delete MARC bibliographic frameworks and authority types. (This is related to the CSRF changes added in Koha 24.05 to improve form security.)
- [37127](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37127) Authorized values select not working on authority forms (24.11.00,24.05.02)
  >This fixes the add and edit forms for authority records that use authorized values for subfields - values for these subfields can now be selected using a dropdown list. After the CSRF changes in 24.05 to improve form security, no dropdown list for selecting the subfield value was displayed.
- [37392](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37392) Edit item permission by library group is broken (24.11.00)
- [37429](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37429) Can't edit bibliographic records anymore (empty form) (24.11.00,24.05.04)
- [37536](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37536) Cataloging add item js needs to update conditional that checks op (24.11.00,24.05.05)
- [37655](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37655) XSS vulnerability in basic editor handling of title (24.11.00,24.05.04,23.11.09,23.05.15)
- [37656](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37656) XSS in Advanced editor for Z39.50 search results (24.11.00,24.05.04,23.11.09,23.05.15)

  **Sponsored by** *Chetco Community Public Library*
- [37947](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37947) Import from Z39.50 doesn't open the record in editor (24.11.00,24.05.05)
- [37964](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37964) Only show host items when system preference EasyAnalyticalRecords is enabled (24.11.00,24.05.06)
- [38076](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38076) Librarians with only fast add permission can no longer edit or create fast add records (24.11.00,24.05.05)
- [38094](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38094) Librarians with only fast add permission can no longer edit existing fast add records (24.11.00,24.05.05)
- [38211](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38211) New bibliographic record in non-default framework opens in default on first edit (24.11.00,24.05.05)
- [38413](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38413) Batch operations from item search results fail when "select visible rows" and many items are selected (24.11.00,24.05.06)
  >This fixes an Apache web server error ("Request-URI Too Long - The requested URL's length exceeds the capacity limit for this server.") when using item search and batch modification to edit many items (500+).

  **Sponsored by** *Chetco Community Public Library*
- [37031](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37031) Club enrollment doesn't complete in staff interface (24.11.00,24.05.02,23.11.07)
  >This fixes a typo in the code that causes the enrollment of a patron in a club to fail.
- [37047](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37047) Patron bookings are not visible from patrons checkout page (24.11.00,24.05.02)
  >This fixes the patron check out page so that current bookings are listed under the bookings tab. A bookings tab showing the number of bookings was visible on a patron's check out tab, but wasn't listing the bookings.
- [37290](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37290) Deleting circulation rule for a specific library deletes for All libraries instead (24.11.00,24.05.05)
- [37332](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37332) Renewal due date and renew as unseen fields not respected when renewing an item from the patron account (24.11.00,24.05.02)
  >This fixes two issues when renewing items for patrons in the staff interface (Patrons > selected patron > Check out > Checkouts table). The "Renew as unseen" checkbox and the custom renewal due date field were both ignored. With these changes, the functionality to change the renewal due date and process a renewal as an unseen renewal once again work as intended.
- [37385](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37385) Transfer/next hold modals not triggered automatically when cancelling a hold by checking item in (24.11.00,24.05.02)
  >This fixes an issue when checking in an item to cancel a waiting hold - if a transfer to the originating library is required, the pop-up window notifying that a transfer is required was not automatically generated. (This is related to the CSRF changes added in Koha 24.05 to improve form security.)
- [37407](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37407) Fast add / fast cataloging from patron checkout does not checkout item (24.11.00,24.05.04)
- [37540](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37540) Pseudonymization is preventing renewals from the patrons account page (24.11.00,24.05.06)
- [38287](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38287) Saving default checkout, hold and return policy with empty bookings values causes error (24.11.00)
- [36435](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36435) Prevent warnings from interrupting koha-run-backups when deleting old backup files (24.11.00,24.05.06)

  **Sponsored by** *Catalyst*
- [37075](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37075) Message queue processor will fail to send any message unless letter_code is passed (24.11.00,24.05.06)
- [37543](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37543) connexion_import_daemon.pl stopped working in 24.05 due to API changes related to CSRF-Token (24.11.00,24.05.04)

  **Sponsored by** *Reformational Study Centre*
- [37775](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37775) update_totalissues.pl uses $dbh->commit but does not use transactions (24.11.00,24.05.04,23.11.10)
- [38156](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38156) Auto renew cron job mangles digest notices when parallel processing is enabled (24.11.00)
- [37288](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37288) Edit data provider form does not show the name (24.11.00,24.05.04,23.11.09)
  >This fixes the editing form for eUsage data providers (ERM > eUsage > Data providers):
  >- It delays the page display until the information from the counter registry is received. Previously, the data provider name was empty until the data from the registry was received.
  >- It removes the 'Create manually' button when editing a data provider that was created from the registry.
- [37308](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37308) Add user-agent to SUSHI outgoing requests (24.11.00,24.05.04,23.11.10)
- [37526](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37526) Handle redirects in SUSHI requests (24.11.00)
- [28664](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28664) One should not be able to issue a refund against a VOID accountline (24.11.00,24.05.02,23.11.07)
  >This fixes VOID transactions for patron accounting entries so that the 'Issue refund' button is not available.
- [37255](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37255) Creating default waiting hold cancellation policy for all patron categories and itemtypes breaks Koha (24.11.00,24.05.03)

  **Sponsored by** *Koha-Suomi Oy*
- [37263](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37263) Creating default article request fees is not working (24.11.00,24.05.06)
- [29087](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29087) Holds to pull list can crash with a SQL::Abstract puke (24.11.00,24.05.04,23.11.09)
  >This fixes the cause of an error (SQL::Abstract::puke():...) that can occur on the holds to pull list (Circulation > Holds > Holds to pull).
- [37351](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37351) Checkboxes on waiting holds report are not kept when switching to another page (24.11.00,24.05.04,23.11.09)
- [37374](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37374) Place hold button non-responsive for club holds (24.11.00,24.05.04)
- [38126](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38126) Holds queue is allocating holds twice when using TransportCostMatrix and LocalHoldsPriority (24.11.00,24.05.05)
- [38148](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38148) Check value of holdallowed circ rule properly (Bug 29087 follow-up) (24.11.00,24.05.05,23.11.10)

  **Sponsored by** *Whanganui District Council*
- [38357](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38357) When adding new holidays Koha sometimes copies same holidays to other librarys (24.11.00)
- [36171](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36171) Extraction of Template Toolkit directive as translatable string causes patron view error in several languages (24.11.00,24.05.06)
- [37303](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37303) Fuzzy translations displayed on the UI (24.11.00,24.05.04)
- [38164](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38164) Translation process is broken (24.11.00,24.05.05)
- [34597](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34597) Expired patrons can still place ILL requests through OPAC (24.11.00)
- [37389](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37389) REST API queries joining on extended_attributes may cause severe performance issues (24.11.00,24.05.04)
  >This fixes a severe performance issue with a REST API SQL query for patron and interlibrary loan request custom attributes. It fixes the problematic join queries using a "mixin" and adds tests. The previous queries could in some circumstance severally affect the database performance.
- [36424](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36424) Database update 23.06.00.061 breaks due to syntax error (24.11,24.05.02,23.11.07)
  >This fixes a syntax error in database update 230600061.pl (from bug 29002 which added the item booking feature to Koha 23.11.) - there was a comma that shouldn't have been there, which would cause the upgrade to fail if an old version of the following plugin was installed: https://github.com/bywatersolutions/koha-plugin-room-reservations
- [36978](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36978) Upgrade fails at 23.06.00.007 [Bug 34029] (24.11.00)
- [36986](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36986) (Bug 26176 follow-up) Fix rename StaffLoginBranchBasedOnIP in DBRev (24.11.00,24.05.01,23.11.06)
- [36993](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36993) Upgrade fails at 23.12.00.023 [Bug 32132] (24.11.00,24.05.01)
- [37000](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37000) Upgrade fails at 23.12.00.044 [Bug 36120] (24.11.00,24.05.02)
  >This fixes a database update error that may occur when upgrading to Koha 24.05.00 or later. This was related to Bug 31620 - Add pickup locations to bookings, an enhancement added in Koha 24.05.
  >
  >Database upgrade error message: 
  >ERROR - {UNKNOWN}: DBI Exception: DBD::mysql::db do failed: Cannot change column 'pickup_library_id': used in a foreign key constraint 'bookings_ibfk_4' at /usr/share/koha/lib/C4/Installer.pm line 741
- [37187](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37187) Label batches and label templates cannot be deleted (24.11.00,24.05.02)
  >This fixes the manage label batches and label templates pages so that they can now be deleted. (This is related to the CSRF changes added in Koha 24.05 to improve form security.)

  **Sponsored by** *Athens County Public Libraries*
- [37192](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37192) Can't print label from the item editor (24.11.00,24.05.04)
  >This fixes a 500 error that occurs when attempting to print a label for an item in the staff interface (from the record details page > Edit > Edit items > Actions > Print label (for a specific item). The label batch editor now opens (as expected).
- [37720](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37720) XSS (and bustage) in label creator (24.11.00,24.05.04,23.11.09,23.05.19)
- [37235](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37235) Download single authority results in 500 error (24.11.00,24.05.06)

  **Sponsored by** *Athens County Public Libraries*
- [37059](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37059) 'Insert' button is not working in notices and slips tool (24.11.00,24.05.02)
  >This fixes the button used to insert fields into the body of a notice - it was not working (Tools > Notices and slips > Edit any notice > expand a notice type > select a field on the left-hand side > Insert).
- [38089](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38089) Fix incorrect regular expression from bug 33478 and move styles to head (24.11.00,24.05.06)
- [37039](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37039) Cannot request a discharge in the OPAC (24.11.00,24.05.02)
  >This fixes the OPAC discharge request so that it now works as expected - after pressing the "Ask for a discharge" button, the page was refreshed but no request was made. (Requires useDischarge system preference enabled; OPAC > Your account > Ask for a discharge.) (This is related to the CSRF changes added in Koha 24.05 to improve form security.)
- [37111](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37111) OPAC renewal - CSRF "op must be set" (24.11.00,24.05.04)
  >This fixes an error that occurs when patron's attempt to renew items from their OPAC account (Your account > Summary). The error was related to the CSRF changes to improve the security for forms added Koha 24.05.
- [37150](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37150) Can't delete single title from a list using the "Remove from list" link (24.11.00,24.05.05)

  **Sponsored by** *Athens County Public Libraries*
- [34147](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34147) Patron search displays "processing" when category has library limitations that exclude the logged in library name (24.11.00,24.05.04)
- [37378](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37378) Patron searches can fail when library groups are set to 'Limit patron data access by group' (24.11.00,24.05.04,23.11.09)
- [37523](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37523) CSRF error when modifying an existing patron record (24.11.00,24.05.04)

  **Sponsored by** *Athens County Public Libraries*
- [37542](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37542) Patron search is incorrectly parsing entries as dates and fetching the wrong patron if dateofbirth in search fields (24.11.00,24.05.04)
- [37786](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37786) members/cancel-charge.pl needs CSRF protection (24.11.00,24.05.05)

  **Sponsored by** *Chetco Community Public Library*
- [37881](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37881) Guarantor code broken (24.11.00)
- [37892](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37892) Patron category 'can be a guarantee' means that same category cannot be a guarantor (24.11.00,24.05.06)
- [37872](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37872) ILL module has issues when plugins are disabled (enable_plugins = 0) (24.11.00)
  >This fixes an issue when plugins are not enabled and the ILL module is enabled. This caused an error on the About Koha > System information section.
  >This also fixes a page error shown when accessing the ILL module with enable_plugins = 0 in koha-conf.xml.
- [37018](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37018) SQL injection using q under api/
  >24.11.00,24.05.02,23.11.07,23.05.13,22.11.19
- [23685](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23685) Exporting report may consume unlimited memory (24.11.00)
  >This development allows you to control the number of records that is downloaded in the reports module (to prevent timeouts) and also includes the option to hide the ODS download option that is the most expensive one.
  >
  >Adding prefs GuidedReportsExportLimit and ReportingAllowsODS_Export for that reason.

  **Sponsored by** *Waikato Institute of Technology, New Zealand*
- [37093](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37093) 403 Forbidden Error when attempting to search for Mana Reports (24.11.00,24.05.04)
  >This fixes searching for a report in Mana when creating a new report. Searching Mana was generating an error message "Your search could not be completed. Please try again later. 403 Forbidden". (This is related to the CSRF changes added in Koha 24.05 to improve form security.)
- [37197](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37197) Batch patron modification from reports fails by using GET instead of POST (24.11.00,24.05.05)
- [37270](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37270) Deleting a report from the actions menu on a list of saved reports does not work (24.11.00,24.05.05)

  **Sponsored by** *Athens County Public Libraries*
- [37734](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37734) Insert runtime parameter button is not working in Reports (24.11.00)
  >This fixes the 'Insert runtime parameter' when creating reports from SQL - nothing was happening when selecting any of the parameters to insert. (This is related to the OPAC and staff interface Bootstrap 5 upgrade in Koha 24.11.)
- [35989](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35989) Searching Geographic authorities generates error (24.11.00,24.05.02,23.11.07)
  >This fixes an error generated when searching geographic name authorities ("Error: Unmatched [ in regex; marked by ...".). The error was generated if an authority record had a heading in the subfields for 751 (Established Heading Linking Entry-Geographic Name) and 781 (Subdivision Linking Entry-Geographic Subdivision).
- [37165](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37165) Can't edit frequencies due to stray cud- in modify op (24.11.00,24.05.02)
  >This fixes the serials frequency edit form so that they can be edited (Serials > Manage frequencies > select edit action for a frequency). Before this, you couldn't edit the frequency - the form was empty. (This is related to the CSRF changes added in Koha 24.05 to improve form security.)
- [37183](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37183) Serials batch edit changes the expiration date to TODAY (24.11.00,24.05.02,23.11.07)
  >This fixes batch editing of serials and the expiration date. Before this patch, if no date was entered in the expiration date field, it was changed to the current date when the batch edit form was saved. This caused the expiration date to change to the current date for all serials in the batch edit.
- [37247](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37247) On subscriptions operation allowed without authentication
  >24.11.00,24.05.02,23.11.07,23.05.13,22.11.19
- [37873](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37873) Unable to delete user from routing list or preview/print routing list slip (24.11.00,24.05.04)
  >Fixes a regression that prevented recipients from being deleted from a routing list, as well as resolving issues with previewing routing lists.

  **Sponsored by** *Westlake Porter Public Library*
- [38378](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38378) Serial frequency deletion is broken (24.11.00)

  **Sponsored by** *Chetco Community Public Library*
- [26866](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26866) Items table on additem should sort by cn_sort (24.11.00,24.05.04)
- [37005](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37005) Holdings table will not load when noItemTypeImages is set to 'Don't show' (24.11.00,24.05.02)
  >This fixes a problem with the holdings table not loading when the noItemTypeImages system preference is set to 'Don't show'.
- [37078](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37078) Damaged status not showing in record detail page (24.11.00,24.05.02)
  >This fixes the record details page to correctly show the damaged status for an item in the holdings table status column, instead of showing it as available.
- [37375](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37375) Holdings table not loading if MARC framework is missing certain 952 subfields (24.11.00,24.05.05)
  >This fixes the loading of the holdings table for a record in the staff interface, where the framework for a MARC21 instance is missing certain 952 subfields (8, a, b, c, or y). The holdings table will still now load, before it would display as "Processing" and not display any holding details.
- [37466](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37466) Reflected Cross Site Scripting (24.11.00,24.05.03,23.11.08,23.05.14,22.11.20)
- [37812](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37812) Adjust Vue modals for Bootstrap 5 (24.11.00)
  >This fixes the display of the dialog boxes (Vue modals) for the ERM and preservation modules. (This is related to the OPAC and staff interface Bootstrap 5 upgrade in Koha 24.11.)
- [37916](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37916) Plugin search and install regression (24.11.00,24.05.06)
- [37959](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37959) Item circulation alerts table appears to be broken (24.11.00,24.05.05)
- [38118](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38118) Removed empty columns on holdings table on details page are not restored when new items loaded (24.11.00,24.05.06)
- [38190](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38190) JS error on suggestion page (24.11.00)
- [38248](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38248) Staff interface detail page item table lookup fails when item has lost status but no claims returned (24.11.00)
- [38391](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38391) DT's add filters called too many times (24.11.00)
- [38436](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38436) Adjust code for column visibility (after DataTables upgrade) (24.11.00)
- [38485](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38485) Update column visibility on holdings table correctly (24.11.00)
- [37091](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37091) Cannot delete a local system preference (24.11.00,24.05.02)
  >This fixes the forms for local system preferences - these can now be deleted.
- [37419](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37419) Deleting the record source deletes the associated biblio_metadata rows (24.11.00,24.05.04)
- [38069](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38069) Table settings not saving (24.11.00)
- [38328](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38328) Cannot delete ILL batch statuses (24.11.00)

  **Sponsored by** *Chetco Community Public Library*
- [37748](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37748) In Bootstrap 5 "disabled" class must be on anchor tag, not list item (24.11.00)

  **Sponsored by** *Athens County Public Libraries*
- [38305](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38305) Can't delete or archive suggestions (24.11.00)
- [38049](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38049) Admin/RecordSources_spec.ts is still failing randomly (24.11.00)
- [33339](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33339) Formula injection (CSV Injection) in export functionality (24.11.00,24.05.05,23.11.10,23.05.16,22.11.22)
- [37129](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37129) Patron attributes linked to an authorized value don't show a select menu in batch modification (24.11.00,24.05.02)
  >This fixes the patron batch modification tool so that patron attributes linked to an authorized value now show the dropdown list of values. (This is related to the CSRF changes added in Koha 24.05 to improve form security.)
- [37483](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37483) Batch extend due dates tool not working (24.11.00,24.05.05)
- [37612](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37612) Batch modifying patrons from patron lists broken by CSRF protection (24.11.00,24.05.04)
  >This fixes batch editing patrons from a patron list (Tools > Patrons and circulation > Patron lists > Actions > Batch edit patrons). When attempting to batch edit patrons, it didn't load the page to batch edit the patrons, and displayed the message "No patron card numbers or borrowernumbers given." (This is related to the CSRF changes added in Koha 24.05 to improve form security.)

  **Sponsored by** *Chetco Community Public Library*
- [37614](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37614) Printing patron cards from patron lists broken by CSRF protection (24.11.00,24.05.04)
  >This fixes printing patron cards from a patron list (Tools > Patrons and circulation > Patron lists > Actions > Print patron cards > Export). When clicking on Export, the progress icon keeps spinning and doesn't finish - resulting in no PDF file to download. (This is related to the CSRF changes added in Koha 24.05 to improve form security.)
- [37654](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37654) XSS in batch record import for the citation column (24.11.00,24.05.04,23.11.09,23.05.15)

  **Sponsored by** *Chetco Community Public Library*
- [37961](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37961) Inventory followup fails by POSTing without an op or csrf_token (24.11.00,24.05.05)

  **Sponsored by** *Chetco Community Public Library*
- [36560](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36560) ILS-DI API POSTS cause CSRF errors (24.11.00,24.05.06)
  >This change creates an anti-CSRF exception so that the ILS-DI API will work without a CSRF token. Libraries are reminded that they should be careful when configuring the ILS-DI:AuthorizedIPs system preference for access to the ILS-DI API.

#### Other bugs fixed

- [37003](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37003) Release team 24.11 (24.11.00,24.05.02,23.11.07,23.05.15)
  >This updates the About Koha > Koha team with the release team members for Koha 22.11.
- [37575](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37575) Typo 'AutoCreateAuthorites' in about.pl (24.11.00,24.05.04,23.11.11)
- [38517](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38517) Release team 25.05
- [33766](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33766) Fix ambiguous form field in OPAC login form (24.11.00)
  >This adds the new system preference `OPACLoginLabelTextContent` that allows to control the text displayed on the login form. Available options are:
  >
  >- card number
  >- card number or username
  >- username
- [37586](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37586) Improve accessibility of top navigation in the OPAC with aria-labels (24.11.00,24.05.04,23.11.10)
- [37758](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37758) Accessibility: "translControl1" field is missing a descriptive label (24.11.00)
- [37988](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37988) Accessibility: The 'Home' icon in the staff interface cannot be accessed with a keyboard (24.11.00)
- [30493](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30493) Pending archived suggestions appear on staff interface home page (24.11.00,24.05.02,23.11.07,23.05.1)
  >This fixes the list of pending suggestions to remove archived suggestions with a "Pending" status. If suggestions were archived and their status was left as "Pending", they were still appearing as suggestions to manage on the staff interface and acquisitions home pages.
- [34159](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34159) Remove plan by AR_CANCELLATION choice in aqplan (24.11.00,24.05.06)

  **Sponsored by** *Chetco Community Public Library*
- [34718](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34718) Input field in fund list (Select2) on receive is inactive (24.11.00,24.05.02,23.11.07)
  >This fixes the fund selector dropdown list when receiving an item. This was not selectable, and the fund could not be changed.
- [35087](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35087) Discount rate should only allow valid input formats (24.11.00,24.05.06)
- [35597](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35597) Purchase suggestion changes aren't logged (24.11.00)
  >This adds the logging of purchase suggestion additions, changes, and deletions. This is enabled using the new SuggestionsLog system preference.
- [35823](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35823) When uploading a MARC file to a basket it is showing inactive funds without them being selected (24.11.00,24.05.06)
- [36049](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36049) Rounding prices sometimes leads to incorrect results (24.11.00,24.05.06)

  **Sponsored by** *Karlsruhe Institute of Technology (KIT)*
- [37070](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37070) Incorrect barcode generation when adding orders to basket (24.11.00,24.05.06)
- [37071](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37071) Purchase suggestions from the patron account are not redirecting to the suggestion form (24.11.00,24.05.02)
  >This fixes the "New purchase suggestion" link from a patron's purchase suggestion area. The link now takes you to the new purchase suggestion form, instead of the suggestions management page. (This is related to the CSRF changes added in Koha 24.05 to improve form security.)
- [37184](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37184) Special character encoding problem when importing MARC file from the acquisitions module (24.11.00)
- [37246](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37246) Suggestions filter by fund displays inactive budgets (24.11.00,24.05.06)
- [37265](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37265) Consideration of UniqueItemFields setting when receiving items in an order. (24.11.00,24.05.06)

  **Sponsored by** *kohawbibliotece.pl*
- [37304](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37304) Created by filter in acquisitions advanced orders search always shows zero results (24.11.00,24.05.06)
- [37337](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37337) Submitting a similar suggestion results in a blank page (24.11.00,24.05.04,23.11.09)
- [37340](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37340) EDIFACT messages should be sortable by 'details' (24.11.00,24.05.04)
  >This fixes the EDIFACT messages table in acquisitions so that the details column is now sortable (Acquisitions > EDIFACT messages (when the EDIFACT system preference is enabled).
- [37343](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37343) Cannot search for vendors when transferring an item in acquisitions (24.11.00,24.05.02)
- [37411](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37411) Exporting budget planning gives 500 error (24.11.00,24.05.04,23.11.09)
- [37450](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37450) Clicking 'Close basket' from the list of baskets does nothing (24.11.00,24.05.04)
- [37854](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37854) Barcode fails when adding item during order receive (again) (24.11.00)
- [37913](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37913) Remove more unreachable code in aqcontract.tt (24.11.00,24.05.06)

  **Sponsored by** *Chetco Community Public Library*
- [37914](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37914) Forms for budget planning filters and export should GET rather than POST (24.11.00,24.05.06)

  **Sponsored by** *Chetco Community Public Library*
- [38235](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38235) Suggestion confirmation letter sent when it should not (24.11.00)
  >This enhancement prevents a patron who made a suggestion from being notified again if their suggested record is reordered.

  **Sponsored by** *Ignatianum University in Cracow*
- [38271](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38271) Missing 008 field in bibliographic records created via EDIFACT (24.11.00,24.05.06)
- [38297](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38297) The "New vendor" button needs a permissions guard (24.11.00)
- [38303](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38303) Item's replacement price not set to defaultreplacecost if 0.00 (24.11.00)
- [38325](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38325) Cannot delete invoice while viewing it (24.11.00)

  **Sponsored by** *Chetco Community Public Library*
- [38326](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38326) copyno not copied over when set in MarcItemFieldsToOrder system preference (24.11.00)
- [38329](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38329) Remove orphan confirm_deletion() in supplier.tt (24.11.00)

  **Sponsored by** *Chetco Community Public Library*
- [23387](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23387) Cache ClassSource (24.11.00)
- [28294](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28294) C4::Circulation::updateWrongTransfer should be moved into Koha:: (24.11.00)
- [31224](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31224) Koha::Biblio::Metadata->record should use the EmbedItems filter (24.11.00)
- [31581](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31581) Remove Zebra files for NORMARC (24.11.00,24.05.06)
- [33188](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33188) Warning in Koha::Items->hidden_in_opac (24.11.00)
- [35294](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35294) Typo in comment in C4 circulation: barocode (24.11.00,24.05.02,23.11.07,23.05.15)
  >This fixes spelling errors in catalog code comments (barocode => barcode, and preproccess => preprocess).
- [35539](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35539) Remove unused columns from categories table (24.11.00)
- [35655](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35655) Make it possible to switch off RabbitMQ without any warns in logs/about page (24.11.00)
- [35721](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35721) Replace ModItemTransfer calls in circ/returns.pl (24.11.00)
- [35959](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35959) Inconsistent hierarchy during C3 merge of class 'Koha::AuthorisedValue' (and a few other modules) (24.11.00,24.05.06)
- [36317](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36317) Koha::Biblio->host_items fails with search_ordered() (24.11.00,24.05.06)
- [36330](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36330) Fix typo: reseve (24.11.00)
  >This fixes the spelling of "reserve" in Koha source code comments (was spelled incorrectly as "reseve").

  **Sponsored by** *Catalyst*
- [36362](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36362) Only call Koha::Libraries->search() if necessary in Item::pickup_locations (24.11.00,24.05.04,23.11.09)

  **Sponsored by** *Gothenburg University Library*
- [36367](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36367) Remove context stack (24.11.00)
- [36474](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36474) updatetotalissues.pl  should not modify the record when the total issues has not changed (24.11.00,24.05.04,23.11.10)
  >This updates the misc/cronjobs/update_totalissues.pl script so that records are only modified if the number of issues changes. Previously, every record was modified - even if the number of issues did not change.
  >
  >In addition, with CataloguingLog enabled, this previously added one entry to the log viewer for every record - as all the records were modified even if the number of issues did not change. Now, only records where the number of issues have changed are included in the log viewer, significantly reducing the number of entries.
- [36594](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36594) Library hours display issues (24.11.00)
  >This fixes the display of library hours in the staff interface (Administration > Basic parameters > Libraries):
  >This patch corrects the following issues related to the display of library
  >-Newly created or edited libraries no longer display 'null' for undefined open and close times.
  >-Libraries without any defined hours will state such instead of displaying the hours table.
  >-The CalendarFirstDayOfWeek system preferences is now respected when viewing a library with defined hours.
  >-Time displays and inputs now follow the TimeFormat system preference.
  >-Times are no longer displayed with seconds.
  >-A TT filter, KohaTimes, has been added to handle proper formatting of time strings based on systems preferences.

  **Sponsored by** *Westlake Porter Public Library*
- [36640](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36640) Upgrade DataTables from 1.13.6 to 2.x (24.11.00)
- [36873](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36873) Koha::Objects->delete should accept parameters and pass them through (24.11.00,24.05.06)
- [36901](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36901) Add logging for uncaught exceptions in background job classes (24.11.00,24.05.06)
  >This enhancement adds logging for uncaught exceptions in background job classes. Some rare situations like DB connection drops can make jobs get marked as failure, but no information about the reasons is logged anywhere.
- [36940](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36940) Resolve two Auth warnings when AutoLocation is enabled having a branch without branchip (24.11.00,24.05.02,23.11.07,23.05.15)
  >This fixes two warnings in the log files when the AutoLocation system preference is enabled and there is a library without an IP address.
  >
  >Warning messages:
  >[WARN] Use of uninitialized value $domain in substitution (s///) at /usr/share/koha/C4/Auth.pm line 1223.
  >[WARN] Use of uninitialized value $domain in regexp compilation at /usr/share/koha/C4/Auth.pm line 1224.
- [37037](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37037) touch_all_biblios.pl triggers rebuilding holds for all affected records when RealTimeHoldsQueue is enabled (24.11.00,24.05.02,23.11.07)
  >This fixes running misc/maintenance/touch_all_biblios.pl when RealTimeHoldsQueue is enabled - it was creating background jobs to rebuild the holds queue for every record, which was unnecessary.
- [37155](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37155) Remove unnecessary unblessing of patron in CanItemBeReserved (24.11.00,24.05.06)
- [37216](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37216) Fix dbrev for EmailFieldSelection (24.11.00,24.05.04)
- [37400](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37400) On checkin don't search for a patron unless needed (24.11.00,24.05.04,23.11.09)
- [37493](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37493) Cypress videos and screenshots should be .gitignored (24.11.00)
  >This updates .gitignore so that the directories for any screenshots and videos created by cypress tests are ignored by git. The directories created are:
  >- t/cypress/screenshots/
  >- t/cypress/videos/
- [37510](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37510) Koha::Object->delete should throw a Koha::Exception if there's a parent row constraint (24.11.00,24.05.04)
- [37628](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37628) Remove get_opac_news_by_id (24.11.00,24.05.06)
- [37672](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37672) V1/RecordSources.pm should use more helpers (24.11.00,24.05.06)
- [37728](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37728) More "op" are missing in POSTed forms (24.11.00)
- [37757](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37757) notice_email_address explodes if EmailFieldPrimary is not valid (24.11.00,24.05.06)
- [37797](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37797) Choosing not to delete a budget does not need to be a form submission (24.11.00)
- [37823](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37823) Remove unreachable code in aqcontract.tt (24.11.00,24.05.06)
- [37861](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37861) Fix XSS vulnerability in barcode append function (24.11.00,24.05.05,23.11.10,23.05.16,22.11.22)

  **Sponsored by** *KillerRabbitAos*
- [37865](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37865) Use of uninitialized value $op in string at circulation.pl (24.11.00)
- [37869](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37869) Plugin hook before_send_messages not triggered for any messages sent without use of process_message_queue.pl (24.11.00)
  >This moves the plugin hook before_send_messages out of process_message_queue and into SendQueuedMessages so notices that are sent automatically, such as WELCOME can also trigger the plugin hook.
- [37981](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37981) Switch installer/step3.tt form from POST to GET (24.11.00,24.05.06)
- [37982](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37982) Serial collection edit form can be GET (24.11.00,24.05.06)
- [38000](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38000) Redundant code import in search.pl (24.11.00,24.05.06)
- [38011](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38011) Add a foreign key link between vendors and subscriptions (24.11.00)

  **Sponsored by** *PTFS Europe* and *ByWater Solutions*
- [38027](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38027) Clearing a flatpickr datetime causes errors (24.11.00,24.05.06)
- [38081](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38081) maskitoTimeOptionsGenerator does not properly support 12-hour times in calendar.inc (24.11.00)
- [38120](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38120) Commented lines in auth.tt should be removed (24.11.00)
- [38200](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38200) Remove dead code to delete authorities in authorities/authorities.pl (24.11.00,24.05.06)

  **Sponsored by** *Chetco Community Public Library*
- [38234](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38234) Remove unused vulnerable jszip library file (24.11.00)
- [38243](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38243) Datatable's header_filter is unused (24.11.00)
- [38257](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38257) Several functionalities broken in cart pop up (24.11.00)

  **Sponsored by** *Koha-Suomi Oy*
- [38273](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38273) Koha::Object->discard_changes should return the Koha::Object for chaining (24.11.00)
- [38274](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38274) Typo in Arabic language description (24.11.00,24.05.06)
  >This fixes the language description for Arabic (displayed in OPAC and the staff interface advanced search) - from "Arabic (لعربية)" to "Arabic (العربية)".
- [38286](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38286) Koha::Biblio:hidden_in_opac does not need to fetch the items if OpacHiddenItemsHidesRecord is set (24.11.00)
- [38342](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38342) Koha::Object->store warning on invalid ENUM value (24.11.00)
- [38424](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38424) Upgrade redocly/cli to the latest release (24.11.00)
- [37104](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37104) Block AnonymousPatron from logging into anything (24.11.00,24.05.06)
  >This prevents the anonymous patron from logging into the OPAC and staff interface. (The anonymous patron used for anonymous suggestions and checkout history is set using the AnonymousPatron system preference.)
- [25387](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25387) Merging different authority types creates no warning (24.11.00,24.05.02,23.11.07,23.05.15)
  >This improves merging authorities of different types so that:
  >
  >1. When selecting the reference record, the authority record number and type are displayed next to each record.
  >2. When merging authority records of different types:
  >   . the authority type is now displayed in the tab heading, and
  >   . a warning is also displayed "Multiple authority types are used. There may be a data loss while merging.".
  >
  >Previously, no warning was given when merging authority records with different types - this could result in undesirable outcomes, data loss, and extra work required to clean up.
- [26929](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26929) Koha will only display the first 20 macros Advanced Editor (24.11.00,24.05.06)

  **Sponsored by** *Chetco Community Public Library*
- [27769](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27769) Advanced editor shouldn't break copying selected text with Ctrl+C (24.11.00,24.05.06)
  >This bugfix corrects a shortcut key clash introduced by bug 17179. We update the default Ctrl+C shortcut for 'Copy line' to 'Ctrl+Alt+C' so that we don't clash with the system copy shortcut.
  >
  >We only do this for new installs, so if you are experiencing this issue with an existing Koha install, you may wish to apply the new mapping in your installation too.
- [36320](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36320) Clicking 'Edit items' from detail page in staff interface leads to 'Add item' screen (24.11.00)

  **Sponsored by** *Athens County Public Libraries*
- [36375](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36375) Inconsistencies in ContentWarningField display (24.11.00,24.05.06)
- [36821](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36821) Authority type text for librarians and OPAC limited to 100 characters (24.11.00,24.05.06)
- [36891](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36891) Restore returning 404 from svc/bib when the bib number doesn't exist (24.11.00,24.05.02,23.11.07,23.05.15)
  >This fixes requests made for records that don't exist using the /svc/bib/<biblionumber> HTTP API. A 404 error (Not Found) is now returned if a record doesn't exist, instead of a 505 error (HTTP Version Not Supported).
- [36976](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36976) Warning 'Argument "" isn't numeric in numeric' in log when merging bibliographic records (24.11.00,24.05.06)

  **Sponsored by** *Ignatianum University in Cracow*
- [36984](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36984) Transit pending status breaks holdings info (24.11.00,24.05.02)
  >This fixes the status shown in the staff interface holdings table for a record when transferring rotation collections. It now correctly shows as "Transit pending...", instead of showing as "Processing" and not displaying the items available.
- [37342](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37342) CSRF error - Cannot add new authorities from basic editor with 'Link authorities automatically' (24.11.00,24.05.04)
- [37383](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37383) No edit item button on catalog detail page for items where holding library is not logged in library (24.11.00,24.05.04)
- [37399](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37399) Item type not displayed on holdings table if noItemTypeImages is disabled (24.11.00,24.05.04)
  >This fixes the staff interface holdings table for a record so that the 'Item type' column is displayed when the "noItemTypeImages" system preference is set to 'Don't show'.

  **Sponsored by** *Koha-Suomi Oy*
- [37403](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37403) Wrong progress quantity in job details when staging records with match check (24.11.00,24.05.06)
- [37591](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37591) Moredetail.tt page is opening very slowly (24.11.00,24.05.04,23.11.10)
  >This improves the loading time of a record's items page in the staff item when there are many items and check-outs.

  **Sponsored by** *Koha-Suomi Oy*
- [37840](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37840) Wrong status in the Intranet detail page when the item type is not for loan (24.11.00,24.05.06)
- [37871](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37871) Remove extraneous 246 subfields from the title mappings (Elasticsearch, MARC21) (24.11.00,24.05.06)
  >This patch limits indexing of field 246 to $a, $b, $n, and $p in various title indexes.
  >Previously, all 246 subfields were indexed, including non-title subfields such as $i (Display text), $g (Miscellaneous information), and linking subfields, making the title index very large and giving false results, especially when looking for duplicates in cataloging.
- [38030](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38030) stocknumberAV.pl fails with CSRF protection (24.11.00,24.05.06)

  **Sponsored by** *Ignatianum University in Cracow*
- [38057](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38057) Fix checkmarks in change framework menu in advanced editor after Bootstrap5 update (24.11.00)

  **Sponsored by** *Chetco Community Public Library*
- [38065](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38065) Auto control number (001) widget in advanced editor does not work under CSRF protection (24.11.00,24.05.06)
- [38082](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38082) Advanced editor does not save the selected framework with new record (24.11.00,24.05.06)
- [38158](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38158) Typo in inventory 'Items has no "not for loan" status' (24.11.00)
- [38162](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38162) Can't delete a stock rotation (24.11.00,24.05.06)
- [13945](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13945) Multiple dialogs for item that needs transferred and hold captured at checkin (24.11.00,24.05.06)
- [32696](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32696) Recalls can inadvertently extend the due date (24.11.00,24.05.04,23.11.10)

  **Sponsored by** *Ignatianum University in Cracow*
- [36196](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36196) Handling NULL data in ajax calls for cities (24.11.00,24.05.04,23.11.09)
- [36428](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36428) Current bookings are not counted in record side bar (24.11.00,24.05.02)
  >This fixes the number of bookings shown for a record (in the sidebar menu for a record) and on a patron's details page (the Bookings tab). It now shows future and active bookings in the count, instead of just future bookings.
- [36459](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36459) Backdating checkouts on circ/circulation.pl not working properly (24.11.00,24.05.02,23.11.07)
  >This fixes setting a due date in the past when checking out an item to a patron. The date entered was not remembered and not displayed on the "Please confirm checkout" message - you had to select and add the date again.
- [36475](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36475) "Print summary" tables cannot be column configured (24.11.00,24.05.04)
- [36716](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36716) Need a better way of looping through smart-rules ( circ table ) columns (24.11.00)
- [37014](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37014) "Item was not checked in" printed on next POST because of missing supplementary form (24.11.00,24.05.02,23.11.07)
  >This fixes a check in issue where the message "Item was not checked in" was appearing in the due date column of the checked-in items table. This was occurring when an action was required for an item after it was checked in, for example when the item needed transferring to another library.
- [37055](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37055) WaitingNotifyAtCheckout should only trigger on patrons with waiting holds (24.11.00,24.05.05)
- [37076](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37076) Incorrect needsconfirmation code RESERVED_WAITING (24.11.00.24.05.06)
- [37210](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37210) SQL injection in overdue.pl
  >24.11.00,24.05.02,23.11.07,23.05.13,22.11.19
- [37271](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37271) Recall status should be 'requested' in overdue_recalls.pl (24.11.00,24.05.06)

  **Sponsored by** *Ignatianum University in Cracow*
- [37345](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37345) Remember for session checkbox on checkout page not sticking (24.11.00,24.05.02,23.11.07)
  >This fixes the date in the "Specify due date" field if "Remember for session" is ticked (when checking out items to a patron). The date was not being remembered, and you had to select it again.
- [37396](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37396) Batch checkout does not checkout items if OverduesBlockCirc set to ask for confirmation (24.11.00,24.05.06)
- [37413](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37413) Updating an item level hold on an item with no barcode to a next available hold also modifies the other holds on the record (24.11.00,24.05.04,23.11.10)
  >This fixes updating existing item level holds for an item without a barcode. When updating an existing item level hold from "Only item No barcode" (Holds for a record > Existing holds > Details column) to "Next available", it would incorrectly change any other item level holds to "Next available".
- [37424](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37424) Batch checkout silently fails if item contains materials specified (952$3) (24.11.00)
- [37444](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37444) Can't filter holds to pull by pickup location (24.11.00,24.05.06)
- [37505](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37505) Statistical patrons don't display information about item status if item wasn't checked out (24.11.00,24.05.06)
- [37524](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37524) Pressing "Renew all" redirects user to "Export data" tool if one of the items is not renewable (24.11.00,24.05.06)

  **Sponsored by** *Koha-Suomi Oy*
- [37552](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37552) Automatic renewals cronjob can die when an item scheduled for renewal is checked in (24.11.00,24.05.04,23.11.09)
- [37636](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37636) Checkout slip prints out of order (24.11.00)
- [37783](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37783) Fix form that looks like it would POST without an op in reserve/request.tt (24.11.00)

  **Sponsored by** *Chetco Community Public Library*
- [37794](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37794) Fix form that POSTs without an op in Holds to pull (24.11.00,24.05.06)

  **Sponsored by** *Chetco Community Public Library*
- [37836](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37836) Prevent submitting empty barcodes in self check-in (24.11.00,24.05.06)
- [37866](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37866) Unable to resolve claim from patron details page (24.11.00)

  **Sponsored by** *Koha-Suomi Oy*
- [37983](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37983) "Search a patron" box no longer has auto focus (24.11.00,24.05.06)
- [38012](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38012) Remove ispermanent from returns.tt and branchtransfers.tt (24.11.00,24.05.06)
- [38013](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38013) Some checkin messages on checkins page lack specific CSS classes (24.11.00)
- [38016](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38016) Relabel booking precaution column heading in circulation rules tables (24.11.00)

  **Sponsored by** *Catalyst*
- [38060](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38060) Bookings table does not render if tab opened from the URL (24.11.00)
- [38097](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38097) Add class to "Item was not checked out" message in checkin table (24.11.00,24.05.06)
- [38117](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38117) "Item was not checked in" should not always show (24.11.00,24.05.06)
- [38246](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38246) If using automatic return claim resolution on checkout, each checkout will overwrite the previous resolution (24.11.00)
- [14565](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14565) koha-run-backups does not backup an instance called demo (24.11.00,24.05.06)
  >This removes a hard-coded exclusion for backups of instances named "demo".
- [18273](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18273) bulkmarcimport.pl inserts authority duplicates (24.11.00,24.05.06)
  >This fixes the misc/migration_tools/bulkmarcimport.pl script when importing authority records so that the "--match" option works as expected, and no duplicates are created. Previously, this option was not working for authority records and duplicate records were being created even when there was a match.
- [34077](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34077) writeoff_debts without --confirm doesn't show which accountline records it would have been written off (24.11.00,24.05.02,23.11.07)
  >This fixes the misc/cronjobs/writeoff_debts.pl and updates the help. If the --confirm option was not used it was showing the help, instead of showing the accountline records that would be written off. Fixes to the script, and updates to improve the help and error messages include:
  >- improving the help for the usage and options (it should now be easier to understand how to use the script)
  >- only showing the usage summary when the wrong options are used (unknown option, no filter options, or no --confirm or --verbose)
  >- clarifying the help for the --verbose and --confirm options (--verbose is required if --confirm is not used)
  >- showing an error message when no filter options are used, and when no --confirm or --verbose option is used
  >- the --category-code option requires another filter option
- [35466](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35466) bulkmarcimport needs a parameter to skip indexing (24.11.00,24.05.06)
  >This patch adds a new option to skip indexing to bulkmarcimport: `--skip_indexing`
  >It also fixes a bug where authorities were being indexed multiple times during import.
- [36977](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36977) Google does not read sitemaps with the name sitemapNNNN.xml (24.11.00)
  >This changes the file name for sitemap files[1] generated by misc/cronjobs/sitemap.pl from sitemapNNNN.xml to sitemap_NNNN.xml (it adds an underscore). For whatever reason, Google only seems to fetch sitemap files with an underscore, despite this not being a requirement in the sitemap protocol. This then resulted in pages not being crawled (reducing their discoverability).
  >
  >[1] Site map files are used by search engines to identify pages on websites that are available for crawling. See https://sitemaps.org/ for more information.
- [37038](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37038) koha-elasticsearch creates a file named 0 (24.11.00,24.05.06)
- [37478](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37478) bulkmarcimport.pl can die on bad records (24.11.00)
  >This adds a -sk (--skip_bad_records) option to misc/migration_tools/bulkmarcimport.pl. Use this option to catch any parsing errors - if errors are found, the record is checked to identify any problems, outputs warnings, and then skips the record. If this option is not used, and there are bad records, the import job may fail.
- [37550](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37550) bulkmarcimport.pl dies when adding items throws an exception (24.11.00)
- [37553](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37553) Fix CSRF handling in koha-svc.pl script (24.11.00, 24.05.04)
- [37709](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37709) bulkmarcimport.pl should die when the file cannot be opened (24.11.00,24.05.06)
- [37787](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37787) Undocument koha-worker --queue elastic_index (24.11.00,24.05.06)
- [37790](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37790) Prevent indexing and holds queue updates when running update_localuse_from_statistics.pl (24.11.00)
- [38173](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38173) Fix description of koha-dump --exclude-indexes (24.11.00,24.05.06)
- [38237](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38237) Add logging to erm_run_harvester cronjob (24.11.00,24.05.06)
- [38249](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38249) `koha-list` help typo about elastic (24.11.00,24.05.06)
- [37409](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37409) Edit button for items in course reserves list doesn't work (24.11.00,24.05.04)
  >This fixes editing existing reserves for a course (when using course reserves). Editing a reserve was opening the add reserve form, instead of letting you edit the existing reserve. (This is related to the CSRF changes added in Koha 24.05 to improve form security.)
- [37838](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37838) Remove button broken on second page of course reserves item results (24.11.00,24.05.06)

  **Sponsored by** *Toi Ohomai Institute of Technology, New Zealand*
- [22421](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22421) accountlines.issue_id is missing a foreign key constraint (24.11.00)
- [37476](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37476) RANK is a reserved word in MySQL 8.0.2+ (24.11.00,24.05.04)
  >This fixes adding a patron to a routing list after receiving a serial - the patron was not being added to the routing list. This issue was only happing where MySQL 8.0.2 or later was used as the database for Koha. This was because the SQL syntax in the SQL used RANK, which become a reserved word in MySQL 8.0.2.
- [37593](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37593) Fix typo in schema description for items.bookable (24.11.00,24.05.04,23.11.10)
- [38434](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38434) (Bug 35906 follow-up) dbrev different from kohastructure.sql (24.11.00)
- [37198](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37198) POD for GetPreparedLetter doesn't include 'objects' (24.11.00,24.05.02,23.11.07,23.05.15)
  >This updates the GetPreparedLetter documentation for developers (it was not updated when changes were made in Bug 19966 - Add ability to pass objects directly to slips and notices).
- [34920](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34920) ERM breaks if an ERM authorized value is missing a description (24.11.00,24.05.06)
- [36895](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36895) Background job links for KBART import are not working (24.11.00,24.05.02)
  >This fixes the background job page link after importing a KBART file in the ERM module (E-resource management > eHoldings > Local > Title > Import from KBART file). Previously, it linked to the background jobs page - it now links to the background job page for the import.
- [36956](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36956) ERM eUsage reports: only the first 20 data providers are listed when creating a new report (24.11.00,24.05.02,23.11.07)
  >This fixes the "Choose data provider" dropdown list when creating a usage report in ERM so that all providers are listed (ERM > eUsage > Reports > Create report). Before this, it was only listing the first 20 data providers.
- [37008](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37008) "Help" link on ERM pages is not translatable (24.11.00,24.05.06)
- [37043](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37043) Counter registry has a new API base URL (24.11.00,24.05.02,23.11.07)
  >This updates the URL used for searching for data providers when adding a new usage data provider for the ERM usage statistics module (E-resource management > eUsage > Data providers). The base URL changed from https://registry.projectcounter.org/ to https://registry.countermetrics.org/.
- [37275](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37275) Remove parenthesis from Select user button in ERM (24.11.00,24.05.06)
- [37277](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37277) Identifiers need a space between the ISBN (Print) and ISBN (Online) in ERM (24.11.00,24.05.06)
  >This fixes the display of identifiers for local titles so that are on separate lines, instead of joined together on the same line.
- [37395](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37395) Cannot hide columns in ERM tables (24.11.00,24.05.06)
- [37491](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37491) Remove duplicate asset import from KBART template (24.11.00)
- [37647](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37647) Unnecessary use of Text::CSV_XS in Koha/REST/V1/ERM/EHoldings/Titles/Local.pm (24.11.00,24.05.04)
- [37810](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37810) Some SUSHI providers return ServiceActive instead of Service_Active (24.11.00)
- [38128](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38128) Agreement/license user selection not limited to users with ERM module permissions (24.11.00,24.05.06)
- [38177](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38177) ERM - HoldingsIQ pagination does not work (24.11.00,24.05.06)
- [38272](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38272) Add permission check for erm permission to additional-fields.tt (24.11.00,24.05.06)
- [34585](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34585) "When to charge" columns value not copied when editing circulation rule (24.11.00,24.05.05,23.11.11)

  **Sponsored by** *Koha-Suomi Oy*
- [37254](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37254) Dropdown values not cleared after pressing clear in circulation rules (24.11.00,24.05.04,23.11.09)

  **Sponsored by** *Koha-Suomi Oy*
- [35771](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35771) Unselecting titles when making multi-hold does not have any effect (24.11.00,24.05.06)
- [36970](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36970) (Bug 34160 follow-up) Barcode should be html filtered, not uri filtered in holds queue view (24.11.00,24.05.06)
  >This fixes the display of barcodes with spaces in the holds queue. Barcodes are now displayed correctly with a space, rather than with '%20'.
- [37373](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37373) Cursor should go to patron search box on loading holds page (24.11.00,24.05.04)
- [37587](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37587) Wrong priority when placing multiple item-level holds (24.11.00,24.05.05)
  >This fixes an issue that was causing new holds to be added as first priority, rather than last priority, when placing multiple item-level holds at once. Now the holds will be added to the end of the list as expected.
- [38186](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38186) Cancelling a hold from the holds over tab shouldn't trigger "return to home" transfer on a lost item (24.11.00)
- [38239](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38239) Incorrect number of items to pull in holds to pull report with partially filled holds (24.11.00)

  **Sponsored by** *Ignatianum University in Cracow*
- [18493](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18493) Many languages are missing from the advanced search languages dropdown (24.11.00)
- [32313](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32313) Complete database column descriptions for cataloguing module in guided reports (24.11.00,24.05.02,23.11.07)
  >This fixes some column descriptions used in guided reports. It:
  >- Adds missing descriptions for the items and biblioitems tables (used by the Circulation, Catalog, Acquisitions, and Serials modules)
  >- Updates some column descriptions to make them more consistent or clearer.
- [35769](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35769) Untranslatable strings when placing holds in staff (24.11.00,24.05.06)
- [36836](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36836) Review ERM module for translation issues
- [37257](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37257) Copy in OPAC datatable untranslatable (24.11.00,24.05.06)

  **Sponsored by** *Athens County Public Libraries*
- [37814](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37814) Wrong use of '__()' in .tt files (24.11.00,24.05.06)

  **Sponsored by** *Athens County Public Libraries*
- [38085](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38085) Untranslatable options in OPACAuthorIdentifiersAndInformation (24.11.00,24.05.06)
- [38138](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38138) Main contact method in hold pop-up untranslatable (24.11.00,24.05.06)
- [38492](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38492) Some javascript translatable strings do not get picked up for translation (24.11.00)
- [35725](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35725) Generic master form does not keep patron and cardnumber when changing type (24.11.00)
- [36894](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36894) Journal article request authors do not show in the ILL requests table (24.11.00,24.05.02,23.11.07)
  >This fixes the table for interlibrary loan (ILL) requests so that it now displays authors for journal article requests.
- [37178](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37178) Column "comments" in ILL requests table gives error on sorting, paging cannot be changed (24.11.00)
- [37194](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37194) Improve link from unconfigured ILL module (24.11.00,24.05.06)
- [38166](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38166) Core status graph strings should be translatable (24.11.00)
- [38276](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38276) ILL Standard form does not consider DOI in openURL (24.11.00)
- [38288](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38288) Provide openURL backwards compatibility with FreeForm (24.11.00)
- [38359](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38359) ILL UI pages offset no longer works after Bootstrap 5 upgrade (24.11.00)
- [38376](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38376) ILL Standard form does not consider id in openURL (24.11.00)
  >This update will recognize the 'id' parameter in an openURL as a 'DOI', ensuring compatibility with version 0.1 of the OpenURL format standard. For more information, visit: https://www.doi.org/the-identifier/resources/factsheets/doi-system-and-openurl.
- [37818](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37818) XXX trick in installer code is not longer needed (24.11.00)
- [37820](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37820) Upgrade fails at 23.12.00.023 [Bug 36993] (24.11.00)
- [38299](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38299) Errors with updates caught in C4::Installer should be colored/highlighted (24.11.00)
- [38385](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38385) DB updates not displayed properly on the UI (24.11.00)
- [38394](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38394) Remove try/catch and say_failures for 24.11 (24.11.00)
- [38383](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38383) say_info messages in web installer have bad contrast/font color (24.11.00)
- [37206](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37206) Removing an item from a label batch should be a CSRF-protected POST operation (24.11.00,24.05.06)

  **Sponsored by** *Athens County Public Libraries*
- [37863](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37863) Patron card batches don't detect when the patron is already in the list (24.11.00)
- [13888](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13888) 'Lists' permission should allow/disallow using the lists module in staff (24.11.00)
- [37285](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37285) Printing lists only prints the ten first results (24.11.00,24.05.04,23.11.09,23.05.15)
- [38020](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38020) Fix 'delete list' button to have same formatting as 'edit list' (24.11.00)
  >This fixes the items in the 'Edit' menu for lists in the staff interface so that the options (Edit list, Delete list) are correctly left aligned. Previously, 'Delete list' was indented.
- [38251](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38251) "Remove selected items" button not removing single item in OPAC lists (24.11.00,24.05.06)

  **Sponsored by** *Chetco Community Public Library*
- [37226](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37226) Authority hierarchy tree broken when a child (narrower) term appears under more than one parent (greater) term (24.11.00,24.05.04,23.11.09)
- [37252](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37252) Saving an authority record as MADS (XML) fails (24.11.00,24.05.06)
  >This fixes the saving of authority records in MADS format in the staff interface (Authorities > search results > authority details > Save > MADS (XML)). Before this fix, the downloaded records had a zero file size and were empty.
- [38056](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38056) Search term after deleting an authority shouldn't be URI encoded (24.11.00,24.05.05)

  **Sponsored by** *Chetco Community Public Library*
- [28075](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28075) Add missing UNIMARC value for coded data 135a (24.11.00)
  >This updates the UNIMARC 135$a subfield to add missing values.
- [34346](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34346) Adding duplicate tag to a framework should give user readable message (24.11.00,24.05.06)
- [36111](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36111) Online resource link should be based on the presence of 856$u (MARC21) (24.11.00)
  >This fixes the display of 856 in the search results and detailed record, in the staff interface and OPAC. Currently, Koha displays "Click here to access online" if any 856 subfield is present, using the $u subfield as the link target, even if $u is empty. This patch makes the display of the online resource link depend on the presence of 856$u to prevent empty links.
- [37357](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37357) Authorised values in control fields cause Javascript errors (24.11.00,24.05.06)
- [32575](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32575) gather_print_notices.pl sends attachment as body of email or poorly named txt file (24.11.00,24.05.06)
- [35639](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35639) Long SMS messages are not sent if they exceed the character limitation of the messaging driver (24.11.00)
- [36741](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36741) AUTO_RENEWALS_DGST should skip auto_too_soon (24.11.00,24.05.02,23.11.07)
  >This fixes the default AUTO_RENEWALS_DGST notice so that items where it is too soon to renew aren't included in the notice output to patrons when the automatic renewals cron job is run (based on the circulation rules settings). These items were previously included in the notice.
  >
  >NOTE: This notice is only updated for new installations. Existing installations should update this notice if they only want to show the actual items automatically renewed.
- [37036](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37036) Cannot access template toolkit branch variable in auto renewal notices (24.11.00,24.05.02,23.11.07)
  >This fixes the automatic renewal notices (AUTO_RENEWALS and AUTO_RENEWALS_DGST) generated using the misc/cronjobs/automatic_renewals.pl cron job so that library information from the branches table is now available. Examples of use: [% branch.branchcode %], [% branch.branchname %], [% branch.branchaddress1 %], [% IF branch.branchaddress2 %][% branch.branchaddress2 %][% END %], [% branch.branchcity %], [% branch.branchstate %], [% branch.branchzip %].
- [37642](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37642) Generated letter should use https in header (24.11.00,24.05.06)
  >This updates http links to W3C standards used in notice headers to https links.
- [37891](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37891) Editing a notice's name having SMSSendDriver disabled causes notice to be listed twice (24.11.00,24.05.05,23.11.11)
- [37967](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37967) Allow auto renewals notices to be sent via phone (24.11.00)
- [13342](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13342) Not logged in user can place a review/comment as a deleted patron (24.11.00,24.05.04,23.11.09,23.05.15)
- [14007](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14007) Values listed in OpacHiddenItems should not appear in OPAC facets (24.11.00)
  >This fixes item type facets in OPAC search results when using OpacHiddenItems. Facet values in OpacHiddenItems are now filtered out and no longer displayed.
  >
  >For example, to hide Map item types (item type code = MP) in the OPAC:
  >- add "itype: ['MP']" to OpacHiddenItems
  >- previously, map items would not be displayed in the search results, but the 'Item type' facet under 'Refine your search' would still display the 'Maps' value
  >- now, the item type facet no longer displays the 'Maps' value
- [22223](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22223) Item url double-encode when parameter is an encoded URL (24.11.00)
- [24690](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24690) Make OPACPopupAuthorsSearch work with search terms containing parenthesis (24.11.00)
  >This fixes the OPAC so that when OPACPopupAuthorsSearch is enabled, author names not linked to an authority record that have parenthesis (for example, Criterion Collection (Firm)) correctly return results. Previously, author names with parenthesis did not return search results.

  **Sponsored by** *Athens County Public Libraries*
- [29539](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29539) UNIMARC: authority number in $9 displays for thesaurus controlled fields instead of content of $a (24.11.00,24.05.02,23.11.07)
  >This fixes the display of authority terms in the OPAC for UNIMARC systems. The authority record number was displaying instead of the term, depending on the order of the $9 and $a subfields (example for a 606 entry: if $a then $9, the authority number was displayed; if $9 then $a, the authority term was displayed).

  **Sponsored by** *National Library of Greece*
- [30372](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30372) Patron self registration: Extended patron attributes are emptied on submit when mandatory field isn't filled in (24.11.00,24.05.02,23.11.07)
  >This fixes the patron self registration form when extended patron attributes are used. If a mandatory field wasn't filled in when submitting, the values entered into any extended patron attributes were lost and needed re-entering.
- [35126](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35126) Remove the use of event attributes from when adding records to lists in the OPAC (24.11.00)
- [35942](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35942) OPAC user can enroll several times to the same club (24.11.00,24.05.00,23.11.03,23.05.09,22.11.15,22.05.19)
  >This fixes patron club enrollment to prevent patrons from enrolling multiple times in the same club. There was no visible option in a patron's OPAC account to do this (Summary > Clubs), but it could be achieved by directly accessing the URL (/cgi-bin/koha/svc/club/enroll?id={clubid}).
- [36166](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36166) Disable select to add to list if opacuserlogin is disabled (24.11.00,24.05.02)
  >This fixes the OPAC search results header to remove the "Add to list" option when system preference opacuserlogin is set to "Don't allow". Previously, if you clicked on Add to list > New list, you would get a message saying you needed to be logged in - but you can't.
- [36207](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36207) Update browser alerts to modals: OPAC tags (24.11.00,24.05.02)
  >This changes the process for removing a tag from a title on a patron's tag list (OPAC > Your account > Tags). It now uses a confirmation dialog box instead of a JavaScript alert. It also makes some minor tweaks to the CSS to correct the style for "Remove tag" links.
- [36337](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36337) Hiding lists with OpacPublic breaks styling for language list (24.11.00)

  **Sponsored by** *Athens County Public Libraries*
- [36557](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36557) Improve logic and display of OPAC cart, tag, and lists controls (24.11.00,24.05.06)
- [36566](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36566) Correct ESLlint errors in OPAC enhanced content JS (24.11.00,24.05.04,23.11.09)
  >This fixes various ESLint errors in enhanced content JavaScript files:
  >- Consistent indentation
  >- Remove variables which are declared but not used
  >- Add missing semicolons
  >- Add missing "var" declarations
- [36742](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36742) Improve OPAC behavior for instances with only one library, including libraries page (24.11.00)
  >This makes some changes in how installations with only one library marked as public are handled. This affects and improves the display in several pages in the OPAC:
  >
  >- OPAC home page with `OpacAddMastheadLibraryPulldown` enabled
  >- OPAC news section with existing news items and `OpacNewsLibrarySelect` enabled
  >- Advanced search - location and availability section
  >- The "Most popular" page with `OpacTopissue` enabled
  >- The suggestion entry form with `suggestion` enabled
  >- The article request entry form with `ArticleRequests` enabled and circulation rules configured to allow requests

  **Sponsored by** *Athens County Public Libraries*
- [36950](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36950) Improve placement of catalog concern banner in the OPAC (24.11.00,24.05.06)
- [36983](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36983) B_address_2 field is required even when not set to be required (24.11.00,24.05.02,23.11.07)
  >This fixes the patron self registration form. If the address field (B_address) in the alternative address section was set to required using the PatronSelfRegistrationBorrowerMandatoryField system preference, it was incorrectly making the address 2 field (B_address2) required on the form as well (even though it was not selected in the system preference).
- [37057](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37057) OPACShowUnusedAuthorities displays unused authorities regardless (24.11.00,24.05.06)
- [37069](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37069) Authorities pagination on OPAC broken by CSRF (24.11.00,24.05.02)
  >This fixes the pagination for authority search results in the OPAC. (This is related to the CSRF changes added in Koha 24.05 to improve form security.)
- [37074](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37074) Comment approval and un-approval should be CSRF-protected (24.11.00,24.05.02)
- [37158](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37158) OPAC recalls history table not responsive (24.11.00,24.05.06)

  **Sponsored by** *Athens County Public Libraries*
- [37324](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37324) Self registration complete login form won't login user (24.11.00,24.05.04)
  >This fixes the login form after completing self registration in the OPAC - the prefilled login details now let you log in.
- [37339](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37339) Default messaging preferences are not applied when self registering in OPAC (24.11.00,24.05.05,23.11.10)
  >This fixes a regression in Koha 24.05, 23.11, and 23.05 (caused by Bug 30318). Default messaging preferences for the self registraton patron category were not set for patron's self-registering using the OPAC.
- [37362](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37362) Do not show the lists button if there are no public lists and opacuserlogin is off (24.11.00)

  **Sponsored by** *Athens County Public Libraries*
- [37370](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37370) opac-export.pl can be used even if exporting disabled (24.11.00,24.05.03,23.11.08,23.05.14,22.11.20)
- [37629](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37629) Link to news are broken (24.11.00,24.05.06)
- [37679](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37679) Dublin Core export option broken (24.11.00,24.05.06)
- [37684](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37684) Direct links to expired news are broken (24.11.00)
- [37724](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37724) Remove Koha version number from public generator metadata (24.11.00,24.05.05,23.11.10,23.05.16,22.11.22)
- [37742](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37742) My virtual card error message not showing (24.11.00)
  >This fixes an error message shown for a patron's virtual card in the OPAC, where the patron's card number can't be converted to a Code39 barcode* (OPACVirtualCard system preference enabled, Your account > My virtual card). Previously the error message was "Error: ${errorMessage}", now it is "Error: Unable to generate barcode".
  >
  >* Code 39 barcodes can only contain digits, capital letters, spaces, and the symbols -.$/+%
- [37827](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37827) Switch OPAC download list form from POST to GET (24.11.00,24.05.06)

  **Sponsored by** *Chetco Community Public Library*
- [37833](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37833) Incorrect logic controlling display of OPAC language selection menus (24.11.00)
  >This fixes the display of the OPAC footer and menu options. Some combinations of OPACReportProblem, CookieConsent, OpacLangSelectorMode, and opaclanguagesdisplay system preferences were causing the OPAC footer and menu items not to display as expected (including the footer not displaying, or menu options not displaying).
- [37841](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37841) Switch OPAC language menu alignment in header and footer (24.11.00)
  >This fixes the display of the language selector in the footer for the OPAC. For longer language names (such as English United Kingdom), the name is misaligned and goes off the page to the left.
- [37853](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37853) Returning to your account at the end of changing your password in the OPAC doesn't need to POST a form (24.11.00,24.05.06)

  **Sponsored by** *Chetco Community Public Library*
- [37887](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37887) OPAC password recovery needs to use a cud- op while POSTing new password (24.11.00,24.05.06)

  **Sponsored by** *Chetco Community Public Library*
- [37931](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37931) Wrong OPAC facet item types label (24.11.00,24.05.06)
- [38055](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38055) Space between label and value for MARC field 530 (24.11.00)
- [38100](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38100) Items with damaged status are shown in OPAC results as "Not available" even with AllowHoldsOnDamagedItems (24.11.00)
- [38125](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38125) Setting patron reading privacy to "never" will immediately delete all reading history without warning (24.11.00)
- [38132](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38132) Add data-isbn to shelfbrowser images (24.11.00)
- [38197](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38197) Remove old version of Bootstrap JS left behind during upgrade (24.11.00)
- [38231](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38231) Adjust CSS for search result controls in the OPAC (24.11.00)

  **Sponsored by** *Athens County Public Libraries*
- [38304](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38304) Remove SaveState options for OPAC tables (24.11.00)
  >This removes the "SaveState" options (Save configuration state on page change, Save search state on page change) from the OPAC table settings configuration. The new SaveState feature (added to 24.11 by bug 33484) is not implemented for the OPAC tables, and this removes any ambiguity.
- [38463](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38463) Unnecessary CSRF token in OPAC authority search (24.11.00)
  >This fixes the OPAC authority search result URL so that it no longer includes the CSRF token, and makes the URL more readable. (This is related to the CSRF changes added in Koha 24.05 to improve form security.)

  **Sponsored by** *Chetco Community Public Library*
- [35755](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35755) Upgrade Business::ISBN to at least 3.008 minimum version (24.11.00)
- [25520](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25520) Change wording on SMS phone number set up (24.11.00,24.05.02,23.11.07)
  >This fixes the hint when entering an SMS number on the OPAC messaging settings page - it is now the same as the staff interface patron hint.
- [30397](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30397) Duplicate '20' option in dropdown 'Show entries' menu (24.11.00)
  >This fixes the options for the number of entries to show for patron search results in the staff interface - 20 was listed twice.
- [30648](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30648) Title is lost in holds history when bibliographic record is deleted (24.11.00)
- [32530](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32530) When duplicating child card, guarantor is not saved (24.11.00)
- [34610](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34610) ProtectSuperlibrarianPrivileges, not ProtectSuperlibrarian (24.11.00,24.05.06)
- [35508](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35508) Update borrowers.updated_on when modifying a patron's attribute (24.11.00,24.05.06)
  >This patch causes the patron field "Updated on" to behave as expected and be updated when a patron attribute is changed.
  >Before this patch, if while editing a patron only the value of a patron attribute was changed, the patron's updated_on date would not be updated.
- [35987](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35987) See highlighted items below link broken (24.11.00)
- [36882](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36882) Flatpickr doesn't work for repeatable date patron attributes in overdues (24.11.00,24.05.04)
- [37365](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37365) Bad redirect when adding a patron message from members/files.pl (24.11.00)
  >This fixes a redirect when adding a patron message straight after uploading a patron file (when EnableBorrowerFiles is enabled). Before this fix, an error message "Patron not found. Return to search" was displayed if you added a message straight after you finished uploading a file (the "Add message" option on other pages worked as expected).
- [37366](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37366) Patron category "Password change in OPAC" setting only follows system preference (24.11.00)
- [37368](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37368) Patron searches break when surname and firstname are set to NULL (24.11.00,24.05.06)
  >This fixes an error when searching for patrons in the staff interface (for both the search in the header and the sidebar). If you have a patron without a last name or first name, and search using a space, the search did not complete and generated a browser console error.
- [37435](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37435) Cannot renew patron from details page in patron account without circulate permissions (24.11.00,24.05.04,23.11.09)
- [37488](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37488) Filepaths not validated in ZIP upload to picture-upload.pl (24.11.00,24.05.03,23.11.08,23.05.14,22.11.20)
- [37489](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37489) Cannot delete patron image without uploading a file (24.11.00,24.05.04)
- [37528](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37528) Using borrowerRelationship while guarantor relationship is unchecked from BorrowerMandatoryField results in error (24.11.00,24.05.06)

  **Sponsored by** *Koha-Suomi Oy*
- [37562](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37562) Duplicate patron check when user cannot see patron leads to a blank popup (24.11.00,24.05.06)
- [37807](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37807) "Export today's checked in barcodes" not disabled when needed (24.11.00)
- [38005](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38005) 500 error on self registration when patron attribute is set as mandatory (24.11.00,24.05.06)
- [38109](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38109) Patron category types are not sorted when entering/editing patrons (24.11.00,24.05.06)
- [38112](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38112) Description of patrons search no longer displayed (24.11.00,24.05.06)
- [38188](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38188) Fix populating borrowernumberslist from patron_search_selections (24.11.00,24.05.06)

  **Sponsored by** *Koha-Suomi Oy*
- [38283](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38283) Patron search modal has a button opened by a <button> and closed by a </a> (24.11.00)
- [38315](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38315) Add a class to expired patrons in patron search (24.11.00)
  >This updates patron search results in the staff interface to use the "dateexpiry" class to highlight expired patron accounts for the "Expires on" column (the date is now red and in italics).
- [37146](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37146) plugin_launcher.pl allows running of any Perl file on file system
  >24.11.00,24.05.02,23.11.07,23.05.13,22.11.19
- [36998](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36998) 'Issue refund' modal on cash register transactions page can mistakenly display amount from previously clicked on transaction (24.11.00,24.05.04,23.11.09)
- [37563](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37563) Refund, payout, and discount modals in patron transactions and point of sale have broken/bad formatting of values (24.11.00)
- [29509](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29509) GET /patrons* routes permissions excessive (24.11.00,24.05.04,23.11.09)
- [36575](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36575) Wrong patron can be returned for API validation route (24.11.00,24.05.01,23.11.06,23.05.12,22.11.18,22.05.22)
- [37021](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37021) REST API: Holds endpoint handles item_id as string in GET call (24.11.00,24.05.02,23.11.07)
  >This fixes the REST API holds endpoint so that the item_id is handled as an integer, not a string.
- [37032](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37032) REST API: Unable to call item info via holds endpoint (24.11.00,24.05.06)

  **Sponsored by** *Koha-Suomi Oy*
- [37261](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37261) api/v1/extended_attribute_types does not return additional fields for unmapped tablenames (24.11.00)
- [37262](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37262) api/v1/extended_attribute_types does not filter additional fields for unmapped tablenames (24.11.00)
- [37535](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37535) Adding a debit via API will show the patron as the librarian that caused the debit (24.11.00,24.05.06)
- [37639](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37639) items.stack ( shelving control number ) not included in items API endpoint (24.11.00)
- [37687](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37687) API query operators list doesn't match documentation (24.11.00,24.05.06)
- [37791](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37791) Fix terminology 'Biblio not found' (24.11.00)
- [38390](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38390) Add 'subscriptions+count' embed to vendors endpoint (24.11.00)

  **Sponsored by** *PTFS Europe* and *ByWater Solutions*
- [36707](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36707) Links on itemnumbers in report should say "item" instead of "record" (24.11.00)

  **Sponsored by** *Athens County Public Libraries*
- [37077](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37077) SQL Reports - Picking only one option for each multiple selection results in wrong query (24.11.00,24.05.04)
- [37108](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37108) Cash register statistics wizard is wrongly sorting payment by home library of the manager (24.11.00,24.05.06)
- [37328](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37328) Cannot delete report after using 'Update and run SQ' button (24.11.00)
  >This fixes deleting saved reports, and adds a confirmation message. Before this, attempting to delete a saved report (Edit > Delete) did not do anything.

  **Sponsored by** *Westlake Porter Public Library*
- [37382](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37382) Report download is empty except for headers if .tab format is selected (24.11.00,24.05.04)
- [37615](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37615) Clean up the form for sending cardnumbers from a report to batch patron modification (24.11.00)
  >This tidies up the form used when initiating patron batch modifications from a report that uses card numbers (option for 'Batch operations with X visible records'). There is no visible difference (the form that sends the card numbers to the patron batch modification form now puts them in a single text area, instead of multiple inputs).
- [37740](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37740) Saved reports GROUP tabs don't show the proper panel (24.11.00)
- [37745](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37745) Duplicate class attributes break dropdown items (24.11.00)
- [37763](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37763) 'Update and run SQL' appends the editor screen after the report results (24.11.00,24.05.04)

  **Sponsored by** *Westlake Porter Public Library*
- [37987](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37987) Downloading SQL report in .tab format is slow (24.11.00,24.05.06)

  **Sponsored by** *Koha-Suomi Oy*
- [23426](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23426) Empty AV field returned in 'patron info' in addition to those requested (24.11.00)
  >This patch adds fine items (AV) to patron information response in SIP2.
  >Additionally the active currency is be part of the response (BH) and the number of items requested with BP and BQ is fixed.
- [36948](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36948) Adjust SIPconfig for log_file and IP version (24.11.00,24.05.02,23.11.07)
  >This fixes issues with logging and default ports in the SIP configuration for Debian 12, when using the koha-testing-docker (KTD) development environment - these issues were causing the SIP service to stop working. Changes include updating the SIPconfig.xml template to:
  >- fix the logging issue (Debian 12 uses journal instead of syslog, use chomp for SIP log4perl configuration, log all SIP issues to sip.log by default)
  >- fix the port issue (allows using IPv4 and IPv6 for the port settings, configures the default template to use IPv4)
- [37016](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37016) SIP2 renew shows old/wrong date due (24.11.00,24.05.02,23.11.07)
  >Set correct due date in SIP2 renewal response message.
- [37582](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37582) SIP2 responses can contain newlines when a patron has multiple debarments (24.11.00,24.05.06)
- [38073](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38073) Missing use after Bug 25812 (24.11.00)
- [38284](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38284) handle_patron_status dies if patron not found (24.11.00)

  **Sponsored by** *PTFS Europe*
- [38344](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38344) Don't send "Thank you !" as screen message (24.11.00)
  >This fixes a typo in a SIP output message - "Thank you !" should be "Thank you!" (note the space before the exclamation mark).
- [32252](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32252) Number of results in a facet do not show after facet selection (24.11.00)
- [33563](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33563) Document Elasticsearch secure mode (24.11.00,24.05.02,23.11.07)
  >When using authentication with Elasticsearch/Opensearch, you must use HTTPS. This change adds some comments in koha-conf.xml to show how to do configure Koha to use authentication and HTTPS for ES/OS.
- [37167](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37167) Fix mapping call number searches to Z39.50 (24.11.00,24.05.06)
- [37244](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37244) Selecting home library or holding library facet changes library dropdown (24.11.00,24.05.06)
- [37249](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37249) Item search column filtering broken (24.11.00,24.05.06)
- [37333](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37333) Search filters using OR are not correctly grouped (24.11.00,24.05.06)
- [37369](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37369) Item search column filtering can't use descriptions (24.11.00,24.05.06)

  **Sponsored by** *Koha-Suomi Oy*
- [37801](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37801) Search results with limits create URLs that cause XML errors in RSS2 output (24.11.00,24.05.05,23.11.11)

  **Sponsored by** *Chetco Community Public Library*
- [37979](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37979) typo in PQF index : index.koha.classification-soruce

  **Sponsored by** *Chetco Community Public Library*
- [37998](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37998) Tabs and backslashes in the data break item search display (24.11.00)

  **Sponsored by** *Ignatianum University in Cracow*
- [30745](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30745) Elasticsearch: Search never returns with after-date and/or before-date in label batch item search (24.11.00)
- [33348](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33348) Show authority heading use with Elasticsearch (24.11.00)

  **Sponsored by** *Education Services Australia SCIS*
- [33407](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33407) With ES and QueryAutoTruncate on, a search containing ISBD punctuation returns no results (24.11.00)

  **Sponsored by** *Ignatianum University in Cracow*
- [35792](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35792) Quiet warning: Use of uninitialized value $sub6 (24.11.00,24.05.04)
  >This removes a warning message[1] that appears in the reindexing output when using Elasticsearch. The warning was generated if there was no value in 880$6 (880 = Alternate Graphic Representation, $6 = Linkage), but there were other 880 subfields with a value, for example 880$a.
  >
  >[1] Use of uninitialized value $sub6 in pattern match (m//) at /kohadevbox/koha/Koha/SearchEngine/Elasticsearch.pm line 619.
- [36879](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36879) Spurious warnings in QueryBuilder (24.11.00,24.05.04,23.11.09,23.05.15)
  >This fixes the cause of a warning message in the log files. Changing the sort order for search results in the staff interface (for example, from Relevance to Author (A-Z)) would generate an unnecessary warning message in plack-intranet-error.log: [WARN] Use of uninitialized value $f in hash element at /kohadevbox/koha/Koha/SearchEngine/Elasticsearch/QueryBuilder.pm line 72    5.
- [36982](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36982) Collections facet does not get alphabetized based on collection descriptions (24.11.00,24.05.02,23.11.07)
  >This fixes the display of the 'Collections' facet for search results in the staff interface and OPAC when using Elasticsearch and Open Search. Values for the facet are now sorted alphabetically using the CCODE authorized values' descriptions, instead of the authorized values' codes.
- [37319](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37319) Move mappings for 752ad (MARC21) and 210a/214a (UNIMARC) to pl index (24.11.00,24.05.06)
- [37430](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37430) (Bug 33407 follow-up) ISBD punctuation removal in ES searches (24.11.00)

  **Sponsored by** *Ignatianum University in Cracow*
- [37446](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37446) Home/holding library facets missing user friendly label (24.11.00,24.05.06)
  >This patch fixes the facet labels for holdingbranch and homebranch to ensure they say "Holding libraries" or "Home libraries" when Elasticsearch is enabled.

  **Sponsored by** *Toi Ohomai Institute of Technology, New Zealand*
- [37857](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37857) Unable to select type "Geo point" or "Call number" when adding a search field (24.11.00,24.05.06)
- [37953](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37953) Incorrect handling of DisplayLibraryFacets in previous database update 23.12.000.36 (24.11.00,24.05.05)
- [38416](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38416) Failover to MARCXML if cannot roundtrip USMARC when indexing (24.11.00)
- [35869](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35869) Dismissing an OPAC message from SCO logs the user out (24.11.00,24.05.02,23.11.07)
  >This removes the "Dismiss" button for patron messages that appear in the OPAC self-checkout system. Dismissing messages was logging patrons out. This option was removed, as fixing this would require significant changes to the self-checkout system. Patron's can still dismiss messages from their OPAC account (Your account > Summary > Messages for you > Dismiss).
- [36679](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36679) Anonymous patron is not blocked from checkout via self check (24.11.00,24.05.02,23.11.07)
  >This fixes the web-based self-checkout system to prevent the AnonymousPatron from checking out items.
- [37026](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37026) Switching tabs in the sco_main page ( Checkouts, Holds, Charges ) creates a JS error (24.11.00,24.05.02,23.11.07)
  >This fixes a JavaScript error (dataTables is not defined) when switching between the checkouts, holds, and charges tabs in the OPAC self-checkout system.
- [37027](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37027) Some dataTable controls in SCO seem unnecessary (24.11.00,24.05.06)
- [37044](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37044) OPAC message from SCO missing library branch (24.11.00,24.05.02,23.11.07,23.05.15)
  >This fixes the self checkout "Messages for you" section for a patron so that any OPAC messages added by library staff now include the library name. Previously, "Written on DD/MM/YYYY by " was displayed after the message without including the library name.
- [37525](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37525) Self checkout: "Return this item" doesn't show up in scan confirmation screen despite SCOAllowCheckin being allowed (24.11.00,24.05.06)
- [38041](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38041) Not all self checkout errors behave the same (24.11.00,24.05.06)
- [29818](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29818) Cannot save subscription frequency without display order (24.11.00)

  **Sponsored by** *Chetco Community Public Library*
- [37294](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37294) Generate next button in serials not working (24.11.00,24.05.04)
  >This fixes the 'Generate next' button when receiving serials so that it now works as expected. Before this fix, nothing happened when clicking the button. (This is related to the CSRF changes added in Koha 24.05 to improve form security.)
- [28762](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28762) Item status shows incorrectly on course-details.pl (24.11.00,24.05.04)
- [31921](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31921) No confirmation alert when deleting a vendor (24.11.00,24.05.04)
  >This fixes deleting vendors in acquisitions. There is now a new confirmation pop-up dialogue box.
- [33453](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33453) Confirmation button for 'Record cashup' should be yellow (24.11.00,24.05.04,23.11.09)
  >This fixes the style of the "Confirm" button in the pop-up window when recording a cashup (Tools > Transaction history for > Record cashup). The button was changed from the default button style (with a white background) to the yellow primary action button.
- [33455](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33455) Heading on 'update password' page is too big (24.11.00,24.05.04,23.11.09)
  >This fixes the heading for the patron change password page in the staff interface (Patrons > search for a patron > Change password). It was previously part of the form area with the white background, when it should have been above it like other page headings.
- [33635](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33635) CSV export display broken diacritics in Excel (24.11.00)
- [36129](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36129) Check in "Hide all columns" doesn't persist on item batch modification/deletion (24.11.00.24.05.04,23.11.09)
  >This fixes the item batch modification/deletion tool, so that if the "Hide all columns" checkbox is selected and then the page is reloaded, the checkbox is still shown as selected. Before this, the columns remained hidden as expected, but the checkbox wasn't selected.

  **Sponsored by** *Koha-Suomi Oy*
- [36182](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36182) Add vendor column to holdings table (24.11.00)
  >This adds a new columns 'Source of acquisition' (MARC21 952$e) to the holdings table in the staff detail page. If the field contains a valid vendor ID, it will display the name of the vendor. If the field contains text, the text will be displayed.
- [36930](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36930) Item search gives irrelevant results when using 2+ added filter criteria (24.11.00,24.05.02,23.11.07,23.05.15)
  >This fixes the item search so that it returns the correct results when two or more additional filters are used (such as publisher and publication date). It was working correctly with one filter, but was not using any filters if two or more were used in a query.
- [36966](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36966) Fix links for local cover images for items on staff detail page (24.11.00,24.05.02)
  >This fixes the local cover image links for items (staff interface record details holdings table > dropdown link for Edit > Upload image) by removing unnecessary parameters, fixing an invalid link, an uninitialised Template::Toolkit variable. This has no noticeable effect, but is important for avoiding future issues.
- [37029](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37029) 'About Koha' button on staff side homepage seems out of place among application buttons (24.11.00,24.05.04)
- [37065](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37065) Bookings tab should filter out expired bookings by default (24.11.00,24.05.06)
  >This fixes the list of bookings for items so that only current bookings are listed. There is now a link, "Show expired", to display all bookings.
- [37213](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37213) Improve breadcrumbs in rotating collections (24.11.00,24.05.06)
- [37233](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37233) Library URL broken in the libraries table (24.11.00,24.05.06)
  >This fixes the URL link for a library in the staff interface (Administration > Basic parameters > Libraries) so that it works as expected. Currently, you get a 404 page not found error.
- [37330](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37330) LocalCoverImages for items don't show after 33526 (24.11.00)
- [37425](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37425) Deletion of bibliographic record can cause search errors (24.11.00,24.05.04,23.11.09)
- [37452](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37452) The 'Compare matched records' diff view page is missing page-sections (24.11.00)
- [37484](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37484) Sorting dates in the housebound deliveries table should work for different date formats (24.11.00)
- [37681](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37681) XSS vulnerability in item.uri in staff interface (24.11.00,24.05.04)
- [37697](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37697) CSS from HTML customizations previews bleeds through to rest of page (24.11.00)
- [37732](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37732) Update templates to use Bootstrap styles when alert class comes from the perl script (24.11.00)

  **Sponsored by** *Athens County Public Libraries*
- [37733](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37733) Preservation link in the header menu is not styled correctly (24.11.00)
- [37739](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37739) Can't delete vendors after Bootstrap 5 update (24.11.00)
  >This fixes acquisitions so that you can now delete vendors. (This is related to the OPAC and staff interface Bootstrap 5 upgrade in Koha 24.11 (bug 35402) and bug 31921, which added a confirmation pop-up window when deleting a vendor.)
- [37752](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37752) Tabs for MARC subfield structure are missing a class (24.11.00)
  >This fixes the navigation display when editing bibliographic framework subfields. It was displaying a plain text link for each subfield in the header, instead of the standard tabbed style. (This is related to the OPAC and staff interface Bootstrap 5 upgrade in Koha 24.11.)
- [37753](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37753) Navigation links when editing authority type subfields are in plain text instead of the tabbed style (24.11.00)
  >This fixes the navigation display when editing authority type subfields. It was displaying a plain text link for each subfield in the header, instead of the standard tabbed style. (This is related to the OPAC and staff interface Bootstrap 5 upgrade in Koha 24.11.)
- [37755](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37755) Change in Bootstrap5 has broken batch patron modification (24.11.00)
- [37928](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37928) "Upload image" item not correctly styled (24.11.00,24.05.06)
- [37954](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37954) Unable to hide barcode column in holdings table (24.11.00,24.05.06)
  >This fixes hiding the barcode column on the staff interface for a record's holdings table. You can now turn on or off hiding the barcode by default, and select the display of the barcode column using the 'Columns' setting.
- [37955](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37955) Clicking table's 'configure' button no longer opens column settings page properly (24.11.00)
- [37980](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37980) Style corrections for installer and onboarding following Bootstrap 5 update (24.11.00)
- [38071](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38071) "Clear filter" on catalogue details page always disabled (24.11.00, 24.05.06)
- [38130](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38130) Cannot filter items on library name (24.11.00,24.05.06)
- [38146](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38146) Last seen date is missing the time in the item holdings table (24.11.00,24.05.06)
- [38191](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38191) Suggestions filters do not expand (24.11.00)
- [38192](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38192) State not restored correctly on suggestion tables (24.11.00)
- [38240](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38240) Filtering resulting in no result will hide filters (24.11.00,24.05.06)
- [38312](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38312) Patron form behind fixed header (24.11.00)
- [38379](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38379) Remove obsolete Bootstrap classes from installer templates (24.11.00)
- [38444](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38444) Bug 34147 follow-up: add tests (24.11.00)
- [38482](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38482) Disable save state for items tables (24.11.00)
- [38484](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38484) Filters on the "Holds to pull" page is broken (24.11.00)
- [34185](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34185) Code mixes OpacItemLocation and OPACItemLocation (24.11.00)
- [35257](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35257) Only admin start page uses "circulation desks" (24.11.00,24.05.06)
  >This changes the Koha administration page title for "Circulation desks" to "Desks" for consistency - all other areas such as the sidebar, page titles, and breadcrumbs all use just "Desks". It also updates the UseCirculationDesks system preference description.
- [36217](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36217) Jobs page include last hour filter does not work (24.11.00)

  **Sponsored by** *Koha-Suomi Oy*
- [36276](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36276) Cannot edit identity provider after creation (24.11.00,24.05.04)
  >This fixes the identity provider and domain forms so that the information is now editable (Administration > Additional parameters > Identity providers).

  **Sponsored by** *Athens County Public Libraries*
- [36527](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36527) Patron category or item type not changing when editing another circulation rule (24.11.00,24.05.02,23.11.07)
  >This fixes editing circulation rules, where the patron category and item type didn't change when you were editing one rule and then changed to editing another rule. This could happen if you were: 1. Editing a rule. 2. Clicked on Edit to change another rule. 3. Confirmed that you wanted to edit another rule. Depending on your rules, the values for the patron category or item type in the editing row may not have changed.
- [36672](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36672) Circulation rules are performing too many lookups (24.11.00,24.05.02)
  >This improves the performance of the circulation and rules page by reducing the number of lookups. This should improve the page loading times (including when editing and saving) when a library has many categories and item types.
- [36880](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36880) Record overlay rules are not validated on add or edit (24.11.00,24.05.02)
  >This fixes the record overlay rules page so that a tag is now required when adding and editing a rule.
- [36907](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36907) OAI set mapping form field maxlength should match table column sizes (24.11.00,24.05.04,23.11.10)
  >This fixes the OIA set mappings form so that you can't enter more characters than the maximum length for the input fields (Field (3), Subfield (1), and Value (80)). Previously, you could enter more characters - however, when you saved the form it generated an error.
- [36922](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36922) Correct hint on date patron attributes not being repeatable (24.11.00,24.05.02)
  >This updates the hint text for "Is a date" when adding a patron attribute - date fields are now repeatable (an enhancement added to Koha 24.05 by bug 32610).
- [36926](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36926) Move syspref PlaceHoldsOnOrdersFromSuggestions (24.11.00)
  >This moves the PlaceHoldsOnOrdersFromSuggestions system preference from the Acquisitions > Printing section to the Circulation > Holds policy section.
- [37157](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37157) Error 500 when loading identity provider list (24.11.00,24.05.02,23.11.07)
  >This fixes the listing of identity providers (Administration > Additional parameters > Identity providers) when special characters are used in the configuration and mapping fields (such as "scope": "élève"). Previously, using special characters in these fields caused a 500 error when viewing the Administration > Identity providers page.
- [37163](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37163) Fix the redirect after deleting a tag from an authority framework to load the right page (24.11.00,24.05.02,23.11.07)
  >This fixes the redirect after deleting a tag from an authority framework. After confirming the deletion of a tag, you are now returned to where you were in the list of tags for the authority type, instead of tag 000 (this now matches the behavour when deleting tags for a MARC framework - see bug 37161).
- [37209](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37209) Improve record overlay rules validation and styling (24.11.00)
- [37229](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37229) Table configuration listings for course reserves incorrect (24.11.00,24.05.06)

  **Sponsored by** *Athens County Public Libraries*
- [37329](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37329) Typo: authorised value in patron attribute types (24.11.00,24.05.06)
- [37404](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37404) Typo in intranetreadinghistory description (24.11.00,24.05.06)
- [37461](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37461) Typo in SMSSendAdditionalOptions description (24.11.00,24.05.04)
- [37606](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37606) Framework export module should escape double quotes (24.11.00,24.05.06)
- [37662](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37662) Library information - text inconsistencies between the table, edit form, and display page (24.11.00)
  >This fixes some text inconsistencies for the library information listing page, and the add, view and modify library pages. This includes:
  >1. Using the message "Library hours not set" for the text if no hours are set.
  >2. Using "Library hours" for the column and field name for library hours.
  >3. Adding a missing colon (:) for the "MARC organization code" field.
  >4. Spelling "information" in full for the previously labelled "OPAC info" field.
  >5. Updating the hint text for the IP, MARC organization code, and Public fields.
- [37765](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37765) Fix forms that POST without an op in systempreferences (24.11.00)

  **Sponsored by** *Chetco Community Public Library*
- [37766](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37766) Fix forms that POST without an op in MARC bibliographic frameworks (24.11.00,24.05.06)

  **Sponsored by** *Chetco Community Public Library*
- [37767](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37767) Fix forms that POST without an op in Authority types (24.11.00)

  **Sponsored by** *Chetco Community Public Library*
- [37768](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37768) Fix form that POSTs without an op in itemtype administration (24.11.00)

  **Sponsored by** *Chetco Community Public Library*
- [37769](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37769) Fix forms that POST without an op in currency administration (24.11.00)

  **Sponsored by** *Chetco Community Public Library*
- [37905](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37905) Correctly fix the "last hour" filter on the job list (24.11.00,24.05.06)
- [38293](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38293) Cannot add Specific OPAC JS or CSS (24.11.00)
  >This fixes adding Specific OPAC JS and Specific OPAC CSS for libraries - you can now add or edit these settings. (This is related to the OPAC and staff interface Bootstrap 5 upgrade in Koha 24.11.)
- [38309](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38309) Cannot delete additional fields (24.11.00)
  >This fixes deleting additional fields (Administration - Additional parameters > Additional fields) - deleting fields now works as expected. Previously, attempting to delete a field would generate a blank page and the field was not deleted. (This is related to the CSRF changes added in Koha 24.05 to improve form security.)

  **Sponsored by** *Chetco Community Public Library*
- [30699](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30699) Fix various HTML validity errors in staff interface templates (24.11.00)

  **Sponsored by** *Athens County Public Libraries*
- [33178](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33178) Use template wrapper for authority and bibliographic subfield entry form tabs (24.11.00)
- [34183](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34183) Remove MARC format hint from OPACResultsLibrary description (24.11.00)
  >This correction removes an obsolete hint from the OPACResultsLibrary system preference description. It is no longer necessary to specify which MARC formats are supported.
- [34573](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34573) Inconsistencies in acquisitions modify vendor title tag (24.11.00,24.05.02,23.11.07)
  >This fixes page title, breadcrumb, and browser page title inconsistencies when adding and modifying vendor details in acquisitions.
- [34706](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34706) Capitalization: Cas login (24.11.00,24.05.02,23.11.07)
  >This fixes a capitalization error. CAS is an abbreviation, and should be CAS on the login form (used when casAuthentication is enabled and configured).
- [35232](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35232) Misspelled ID breaks label on patron lists form (24.11.00,24.05.06)
- [35235](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35235) Mismatched label on notice edit form (24.11.00,25.05.04,23.11.09)
- [35236](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35236) Mismatched label on patron card batch edit form (24.11.00,24.05.04,23.11.09)
  >This fixes the "Batch description" label when editing a patron card batch (Tools > Patrons and circulation > Patron card creator > Manage > Card batches > Edit). When you click on the batch description label, the input field is now selected and you can enter the batch description. Before this, you had to click in the field to add the description.
- [35238](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35238) Incorrect label markup in patron card creator printer profile edit form (24.11.00,24.05.06)
- [35239](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35239) Missing form field ids in batch patron modification template (24.11.00,24.05.06)
  >This fixes the batch patron modification edit form labels so that they all have IDs, and the input box now receive the focus when clicking on the label (this includes patron attribute fields, but excludes date fields). This is an accessibility improvement. Before this, you had to click in the input box to add a value.

  **Sponsored by** *Athens County Public Libraries*
- [35240](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35240) Missing form field ids in rotating collection edit form (24.11.00,24.05.02,23.11.07)
  >This adds missing IDs to the rotating collections edit form (Tools > Rotating collections > edit a rotating collection (Actions > Edit)).
- [36338](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36338) Capitalization: Card number or Userid may already exist. (24.11.00,24.05.02,23.11.07)
  >This fixes the text for the warning message in the web installer onboarding section when creating the Koha administrator patron - where the card number or username already exists. It now uses "username" instead of "Userid", and updates the surrounding text:
  >. Previous text: The patron has not been created! Card number or Userid may already exist.
  >. Updated text: The patron was not created! The card number or username already exists.
- [36885](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36885) Missing tooltip on budget planning page (24.11.00,24.05.04,23.11.09)
  >This fixes the "Budget locked" tooltip for budget fund planning pages (Administration > Budgets > select a budget that is locked > Funds > Planning > any planning option). The tooltip was not styled correctly for fund names - it now has white text on a black background.
- [36905](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36905) Terminology: home locations / home collections (24.11.00,24.05.06)
  >This removes the unnecessary word "home" from several aria-labels in OPAC search facets. For example, "Show more home locations" was changed to "Show more locations". (Note that there is no visible change to the OPAC.)
- [36909](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36909) Eliminate duplicate ID in cookie consent markup (24.11.00,24.05.02)
  >This fixes HTML validation warnings about duplicate IDs in the cookie consent markup for the OPAC and staff interface.
- [36961](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36961) Typo: itms (24.11.00,24.05.02)
  >This fixes a spelling mistake in the opacreadinghistory system preference description - it changes 'itms' to 'items'.
- [37002](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37002) Correct several HTML markup errors (24.11.00,24.05.02)
  >This fixes several minor HTML markup validation errors for the bibliographic detail page in the staff interface.
- [37030](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37030) Use template wrapper for breadcrumbs: Cash register stats (24.11.00,24.05.04,23.11.09)
- [37161](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37161) After deleting a tag in a MARC framework, confirmation page is blank (24.11.00,24.05.02)
  >This removes the "Tag deleted" page after deleting a MARC framework tag. After confirming the deletion of a tag, you are now returned to you where you were in the list of tags for the framework (this now matches the behavour when deleting tags for an authority type - see bug 37163). 
  >
  >It also fixes the blank page that was displayed after confirming the tag deletion - this was related to the CSRF changes added in Koha 24.05 to improve form security.
- [37162](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37162) Remove dead confirmation code when deleting tags from authority frameworks (24.11.00,24.05.02,23.11.07)
  >This removes redundant code that is no longer used when deleting authority tags. A previous change removed the extra page displayed after confirming the deletion an authority tag - this required you to click OK, and then you were returned to the list of tags.
- [37231](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37231) (Bug 34940 follow-up) Highlight logged-in library in facets does not work with ES (24.11.00,24.05.06)

  **Sponsored by** *Ignatianum University in Cracow*
- [37242](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37242) Don't use the term branch in cash register administration (24.11.00,24.05.06)
- [37264](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37264) Fix delete button on staff interface's suggestion detail page (24.11.00,24.05.06)

  **Sponsored by** *Athens County Public Libraries*
- [37496](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37496) Link to item details from holdings table links to all items (24.11.00,24.05.04)
  >When clicking on an item barcode to view the details of that item, Koha usually displays a page showing just that item. The barcode link from the item holdings table on a bibliographic record was linking to a page showing the details for all items on the record, which can load very slowly when there are many items. This fixes the link so that it links only to that specific item.
- [37595](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37595) Double HTML escaped ampersand in pagination bar (24.11.00,24.05.06)
- [37643](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37643) Check for NaN instead of truthiness if calendar.inc accepts_time (24.11.00,24.05.04)
- [37759](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37759) Duplicated "Set library" menu item caused by bad merge (24.11.00)
- [37795](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37795) job-progress.inc progress bar broken by Bootstrap5 upgrade (24.11.00)

  **Sponsored by** *Chetco Community Public Library*
- [37846](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37846) Serial prediction pattern test appears at the bottom of the page (24.11.00)
  >This fixes the test prediction pattern when adding a new subscription for a serial - the prediction pattern was appearing at the bottom of the page, instead of in a column to the right. (This is related to the OPAC and staff interface Bootstrap 5 upgrade in Koha 24.11.)
- [37848](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37848) "Run with template" options need formatting (24.11.00,24.05.06)

  **Sponsored by** *Athens County Public Libraries*
- [37910](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37910) Minor spacing issues in the catalog concerns page (24.11.00)
- [37912](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37912) Catalog concerns - Broken link under concern title (24.11.00)
- [37945](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37945) Links for system preferences subsections don't work (24.11.00)
- [37946](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37946) Double menu when clicking the caret in Z39.50 search (24.11.00)
- [37977](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37977) Fix some issues with labels in inventory form (24.11.00,24.05.06)

  **Sponsored by** *Chetco Community Public Library*
- [38066](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38066) Pop-up window footers can block page content (24.11.00,24.05.06)
  >This fixes the display of some dialog boxes, such as the authority record search plugin when editing 100$a, so that the content at the bottom (such as search results) is not obscured by the footer navigation.

  **Sponsored by** *Athens County Public Libraries*
- [38129](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38129) Add note regarding permissions in suggestion manager search pop-up modal (24.11.00)
- [38346](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38346) Make sidebar checkboxes consistent (24.11.00)

  **Sponsored by** *Athens County Public Libraries*
- [38380](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38380) Fix other instances of obsolete col-*-offset classes from templates (24.11.00)
- [34838](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34838) The ILL module and tests generate warnings (24.11.00,24.05.02,23.11.07)
  >This fixes the cause of several warnings generated by the tests for the inter-library loan (ILL) module.
- [36919](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36919) t/db_dependent/Koha/Object.t produces warnings (24.11.00,24.05.06)
- [36935](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36935) BackgroundJob/ImportKBARTFile.t generates warnings (24.11.00,24.05.06)
- [36936](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36936) api/v1/bookings.t generates warnings (24.11.00,24.05.06)
- [36937](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36937) api/v1/password_validation.t generates warnings (24.11.00,24.05.02,23.11.07,23.05.15)
  >This fixes the cause of a warning for the t/db_dependent/api/v1/password_validation.t tests (warning fixed: Use of uninitialized value $status in numeric eq (==)).
- [36938](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36938) Biblio.t generates warnings (24.11.00,24.05.02,23.11.07)
  >This fixes the cause of warnings generated by the bibliographic tests.
- [36944](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36944) Auth.t should not fail when AutoLocation is enabled (24.11.00,24.05.06)
- [36999](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36999) 00-strict.t fails to find koha_perl_deps.pl (24.11.00,24.05.02,23.11.07)
  >This fixes the tests in t/db_dependent/00-strict.t. The tests were failing as a file (koha_perl_deps.pl) was moved and is no longer required for these tests.
- [37283](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37283) t/db_dependent/selenium/authentication.t is failing (24.11.00,24.05.06)
- [37289](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37289) t/db_dependent/api/v1/authorised_values.t is failing under specific circumstances (24.11.00,24.05.06)
- [37302](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37302) xt/api.t should fail if swagger-cli is missing (24.11.00,24.05.04)
  >This fixes the tests in xt/api.t. It was skipping tests if swagger-cli was missing, which meant that some tests weren't being run when they should be. The tests now fail if swagger-cli isn't found.
  >
  >It also adds swagger-cli 4.0.4+ to the devDependancies section of package.json.
- [37490](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37490) Add test to detect when yarn.lock is not updated (24.11.00,24.05.06)
- [37607](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37607) t/cypress/integration/ERM/DataProviders_spec.ts fails (24.11.00,24.05.04,23.11.09)
- [37620](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37620) Fix randomly failing tests for cypress/integration/InfiniteScrollSelect_spec.ts (24.11.00,24.05.04)
- [37623](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37623) t/db_dependent/Letters.t tests fails to consider EmailFieldPrimary system preference (24.11.00,24.05.04,23.11.10)

  **Sponsored by** *Pymble Ladies' College*
- [37870](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37870) UI/Form/Builder/Item.t and Biblio.t are still failing randomly (cn_source sort) (24.11.00)
- [37898](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37898) All db dependent tests should run within a transaction (24.11.00)
- [37917](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37917) RecordSources_spec.ts is failing randomly (24.11.00)
- [37929](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37929) Cypress tests for agreements aren't all running (24.11.00)
- [37963](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37963) Improve error handling and testing of ERM eUsage SUSHI (24.11.00)
- [38043](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38043) KohaTimes filter is missing tests (24.11.00)
- [38322](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38322) Wrong comment in t/db_dependent/api/v1/erm_users.t (24.11.00)
- [38418](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38418) SIP/Transaction.t fails if wrong `dateformat` set (24.11.00)
- [38501](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38501) Prevent failures of Koha/Booking.t when running tests on an updated database (24.11.00)
- [38513](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38513) Fix Biblio.t for Koha_Main_My8 test configuration (24.11.00)
- [38526](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38526) Auth_with_* tests fail randomly (24.11.00)
- [35100](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35100) Items assigned to StockRotation do not advance if a hold is triggered before the initial transfer (24.11.00)
- [36083](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36083) Not able to create customizable areas to intranet home pages that are library specific (24.11.00)
- [36128](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36128) Use of uninitialized value in string eq at /usr/share/koha/lib/C4/Overdues.pm (24.11.00,24.05.02,23.11.07)
  >This fixes the following error message when running the overdues check cronjob on a Koha system without defined overdue rules:
  >
  >/etc/cron.daily/koha-common: Use of uninitialized value in string eq at /usr/share/koha/lib/C4/Overdues.pm line 686.
- [36132](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36132) Allow users to delete multiple patron lists at once on any page (24.11.00)
  >This fixes patron lists so that when there are more than 20 lists, the lists on the next pages can be deleted. Previously, you were only able to delete the lists on the first page.
- [37186](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37186) Cannot delete a rotating collection (24.11.00,24.05.04)
- [37243](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37243) Tag moderation actions should be in the last column (24.11.00,24.05.06)

  **Sponsored by** *Athens County Public Libraries*
- [37326](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37326) Batch modification should decode barcodes when using a barcode file (24.11.00)
- [37522](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37522) Logging item modification should record the original version of the item (24.11.00)
  >Actions logs for changes to items now include the pre and post change item data in the database.

  **Sponsored by** *Ignatianum University in Cracow*
- [37580](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37580) Unique holiday descriptions are not editable (24.11.00,24.05.06)

  **Sponsored by** *Westlake Porter Public Library*
- [37730](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37730) Batch patron modification table horizontal scroll causes headers to mismatch (24.11.00,24.05.06)
  >This fixes the table for the batch patron modification" tool (Tools > Patrons and circulation > Batch patron modification). When you scrolled down the page so that table header rows are "sticky", and then scrolled to the right, the table header columns were fixed instead of changing to match the column contents.
- [37779](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37779) Fix forms that POST without an op in tag moderation (24.11.00)

  **Sponsored by** *Chetco Community Public Library*
- [37785](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37785) Remove dead code in tools/letter.tt that looks like a form that would POST without an op (24.11.00)

  **Sponsored by** *Chetco Community Public Library*
- [37859](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37859) Tabs for record comments are in plain text (related to Bootstrap 5 update) (24.11.00)
  >This fixes the tab headings for patron comments (Tools > Patrons and circulation > Comments), so that they are now standard tabs instead of plain text links. (This is related to the OPAC and staff interface Bootstrap 5 upgrade in Koha 24.11.)
- [37965](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37965) Fix regression of convert_urls setting in TinyMCE which causes unexpected URL rewriting (24.11.00)
- [38266](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38266) Incorrect attribute disabled in patron batch modification (24.11.00)
- [38275](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38275) Unable to delete patron card creator images (24.11.00,24.05.06)
  >This fixes deleting images when using the patron card creator's image manager. You could not delete images, and received an error message "WARNING: An unsupported operation was attempted. Please have your system administrator check the error log for details." (This is related to the CSRF changes added in Koha 24.05 to improve form security.)
- [38428](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38428) Simplify listing of items on stock rotation page (24.11.00)
- [30715](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30715) Terminology: Logs should use staff interface and not intranet for the interface (24.11.00,24.05.02,23.11.07,23.05.15)
  >This fixes the log viewer so that 'Staff interface' is used instead of 'Intranet' for the filtering option and the value displayed in the log entries interface column.
  >
  >Note: This does not fix the underlying value recorded in the action_log table (these are added as 'intranet' to the interface column), or the values shown in CSV exports.
- [37182](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37182) 'datetime' field lost on pseudonymization (24.11.00,24.05.02)
  >This fixes a regression where the datetime field was lost when using the pseudonymization command line script added in Koha 24.05 (misc/maintenance/pseudonymize_statistics.pl, see bug 34611). It also adds new tests.
- [35442](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35442) Script migration_tools/build_oai_sets.pl is missing ORDER BY (24.11.00,24.05.06)
- [38131](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38131) ILS-DI documentation still shows renewals instead of renewals_count (24.11.00)
- [38233](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38233) ILS-DI GetRecords should filter out items hidden in OPAC and use OPAC MARCXML (24.11.00)
  >This updates the ILS-DI GetRecords service to use the OPAC version of the MARCXML and filter items based on their OPAC visibility. For example, if OpacHiddenItems includes "withdrawn: [1]" (hide items with a withdrawn status of 1) and hidelostitems is set to "Don't show", then an ILS_DI request for a record will not show items with a withdrawn status = 1 (Withdrawn). Previously, there was no way to hide hidden items from the ILS-DI request.

## New system preferences

- AllowItemsOnLoanCheckoutSIP
- AlwaysLoadCheckoutsTable
- AuthorityXSLTDetailsDisplay
- ForcePasswordResetWhenSetByStaff
- HoldsQueueParallelLoopsCount
- IncludeSeeAlsoFromInSearches
- JobsNotificationMethod
- MarcOrderingAutomation
- NoRefundOnLostFinesPaidAge
- OAI-PMH:HarvestEmailReport
- OPACItemLocation
- OPACLoginLabelTextContent
- OPACOverDrive
- OPACShowLibraries
- OPACVirtualCard
- OPACVirtualCardBarcode
- OpacMetaRobots
- ReportsExportFormatODS
- ReportsExportLimit
- RestrictPatronsWithFailedNotices
- SMSSendMaxChar
- SearchCancelledAndInvalidISBNandISSN
- StaffInterfaceLanguages
- SuggestionsLog
- z3950Status

## Deleted system preferences

- IntranetmainUserblock
- OpacItemLocation
- StaffDetailItemSelection

## Renamed system preferences

- language > StaffInterfaceLanguages

## New authorized value categories

-  BOOKING_CANCELLATION

## New notices and slips

- BOOKING_CANCELLATION
- BOOKING_CONFIRMATION
- BOOKING_MODIFICATION
- OAI_HARVEST_REPORT
- SFTP_FAILURE
- SFTP_SUCCESS
- TICKET_ASSIGNED
- TRANSFER_OWNERSHIP



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Armenian (hy_ARMN)](https://koha-community.org/manual/24.11//html/) (58%)
- [Bulgarian (bg_CYRL)](https://koha-community.org/manual/24.11//html/) (98%)
- [Chinese (Traditional)](https://koha-community.org/manual/24.11/zh_Hant/html/) (81%)
- [English](https://koha-community.org/manual/24.11//html/) (100%)
- [English (USA)](https://koha-community.org/manual/24.11/en/html/)
- [French](https://koha-community.org/manual/24.11/fr/html/) (52%)
- [German](https://koha-community.org/manual/24.11/de/html/) (45%)
- [Greek](https://koha-community.org/manual/24.11//html/) (75%)
- [Hindi](https://koha-community.org/manual/24.11/hi/html/) (72%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (ar_ARAB) (96%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified) (87%)
- Chinese (Traditional) (88%)
- Czech (67%)
- Dutch (86%)
- English (100%)
- English (New Zealand) (61%)
- English (USA)
- Finnish (98%)
- French (98%)
- French (Canada) (97%)
- German (100%)
- Greek (56%)
- Hindi (97%)
- Italian (81%)
- Norwegian Bokmål (74%)
- Persian (fa_ARAB) (95%)
- Polish (100%)
- Portuguese (Brazil) (98%)
- Portuguese (Portugal) (87%)
- Russian (92%)
- Slovak (60%)
- Spanish (98%)
- Swedish (86%)
- Telugu (68%)
- Turkish (81%)
- Ukrainian (71%)
- hyw_ARMN (generated) (hyw_ARMN) (62%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](https://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](https://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](https://translate.koha-community.org/)

## Release Team

The release team for Koha 24.11.00 is


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
new features in Koha 24.11.00

- [Association KohaLa](https://koha-fr.org)
- Athens County Public Libraries
- [Büchereizentrale Schleswig-Holstein](https://www.bz-sh.de)
- [Cape Libraries Automated Materials Sharing](https://info.clamsnet.org)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)
- Chetco Community Public Library
- [Cuyahoga County Public Library](https://cuyahogalibrary.org)
- Education Services Australia SCIS
- Gothenburg University Library
- Horowhenua Libraries, New Zealand
- Ignatianum University in Cracow
- Karlsruhe Institute of Technology (KIT)
- KillerRabbitAos
- [Koha-Suomi Oy](https://koha-suomi.fi)
- KohaLa
- National Library of Greece
- [Orex Digital](https://orex.es)
- Plant and Food Research Limited
- [PTFS Europe](https://ptfs-europe.com)
- Pymble Ladies' College
- Rapid City Public Library
- [Reformational Study Centre](www.refstudycentre.com)
- Regionbibliotek Halland / County library of Halland
- Reserve Bank of New Zealand
- South Taranaki District Council, New Zealand
- Toi Ohomai Institute of Technology, New Zealand
- UKHSA - UK Health Security Agency
- Waikato Institute of Technology, New Zealand
- Waitaki District Council, New Zealand
- Westlake Porter Public Library
- Whanganui District Council
- kohawbibliotece.pl

We thank the following individuals who contributed patches to Koha 24.11.00

- Aleisha Amohia (19)
- Pedro Amorim (174)
- Tomás Cohen Arazi (100)
- Noémie Ariste (1)
- Alex Arnaud (2)
- Katrina Bassett (1)
- Oliver Behnke (1)
- Matt Blenkinsop (93)
- Jérémy Breuillard (1)
- Alex Buckley (13)
- Phan Tung Bui (2)
- Rudolf Byker (1)
- Kevin Carnes (1)
- Nick Clemens (123)
- David Cook (54)
- Chris Cormack (4)
- Jake Deery (15)
- Paul Derscheid (71)
- Jonathan Druart (246)
- Michał Dudzik (1)
- Marion Durand (1)
- Magnus Enger (5)
- Laura Escamilla (10)
- Eugene Jose Espinoza (1)
- Katrin Fischer (124)
- Emily-Rose Francoeur (2)
- Andrew Fuerste-Henry (3)
- Matthias Le Gac (1)
- Eric Garcia (16)
- Lucas Gass (74)
- Didier Gautheron (2)
- Ewa Gozd (1)
- Victor Grousset (6)
- Thibaud Guillot (9)
- Amit Gupta (1)
- David Gustafsson (1)
- Bo Gustavsson (1)
- Michael Hafen (2)
- Kyle M Hall (62)
- Nicolas Hunstein (1)
- Mason James (3)
- Andreas Jonsson (5)
- Janusz Kaczmarek (34)
- Jan Kissig (11)
- Thomas Klausner (1)
- Denys Konovalov (1)
- Lukas Koszyk (1)
- Michał Kula (1)
- Emily Lamancusa (34)
- Sam Lau (28)
- Brendan Lawlor (18)
- Owen Leonard (113)
- Yanjun Li (2)
- CJ Lynce (9)
- Julian Maurice (22)
- Vicki McKay (1)
- Matthias Meusburger (11)
- David Nind (16)
- Alexandre Noel (2)
- Artur Norrby (1)
- Andrew Nugged (2)
- Eric Phetteplace (1)
- Katariina Pohto (2)
- Martin Renvoize (220)
- Phil Ringnalda (60)
- Adolfo Rodríguez (3)
- Marcel de Rooy (23)
- Caroline Cyr La Rose (24)
- Andreas Roussos (5)
- Johanna Räisä (8)
- Fridolin Somers (17)
- Catalyst Bug Squasher (4)
- Martin Stenberg (4)
- Lari Strand (4)
- Raphael Straub (2)
- Jennifer Sutton (3)
- Emmi Takkinen (15)
- Doris Tam (1)
- Lari Taskula (6)
- Petro Vashchuk (1)
- George Veranis (2)
- Olivier Vezina (1)
- Hinemoea Viault (1)
- Hammat Wele (14)
- Wainui Witika-Park (3)
- Baptiste Wojtkowski (11)
- Chloe Zermatten (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 24.11.00

- Athens County Public Libraries (113)
- [BibLibre](https://www.biblibre.com) (72)
- [Bibliotheksservice-Zentrum Baden-Württemberg (BSZ)](https://www.bsz-bw.de) (125)
- BigBallOfWax (4)
- [ByWater Solutions](https://bywatersolutions.com) (271)
- [Cape Libraries Automated Materials Sharing](https://info.clamsnet.org) (18)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha) (31)
- Catalyst Open Source Academy (15)
- Chetco Community Public Library (60)
- [Dataly Tech](https://dataly.gr) (7)
- David Nind (16)
- Dubuque County Library District (3)
- Gothenburg University Library (1)
- [Hypernova Oy](https://www.hypernova.fi) (5)
- Independant Individuals (112)
- Informatics Publishing Ltd (1)
- Karlsruhe Institute of Technology (KIT) (3)
- Koha Community Developers (253)
- [Koha-Suomi Oy](https://koha-suomi.fi) (21)
- KohaAloha (3)
- kohawbibliotece.pl (1)
- Kreablo AB (5)
- [Libriotech](https://libriotech.no) (5)
- [LMSCloud](lmscloud.de) (71)
- Lund University Library, Sweden (1)
- Max Planck Institute for Gravitational Physics (1)
- [Montgomery County Public Libraries](montgomerycountymd.gov) (34)
- [Prosentient Systems](https://www.prosentient.com.au) (54)
- [PTFS Europe](https://ptfs-europe.com) (503)
- Rijksmuseum, Netherlands (23)
- [Solutions inLibro inc](https://inlibro.com) (47)
- [Theke Solutions](https://theke.io) (100)
- Westlake Porter Public Library (9)
- Wildau University of Technology (11)
- [Xercode](https://xebook.es) (3)

We also especially thank the following individuals who tested patches
for Koha

- Hugo Agud (8)
- Belal Ahmadi (1)
- Alyssa Drake (1)
- Hebah Amin-Headley (1)
- Aleisha Amohia (29)
- Pedro Amorim (97)
- Cornelius Amzar (1)
- Andrew Auld (2)
- Tomás Cohen Arazi (103)
- Sukhmandeep Benipal (15)
- Catrina Berka (1)
- Matt Blenkinsop (47)
- Mary Blomley (1)
- Philippe Blouin (1)
- Sonia Bouis (3)
- Valerie Burnett (1)
- Nick Clemens (159)
- David Cook (40)
- Chris Cormack (35)
- Dave Daghita (1)
- Jake Deery (32)
- Ray Delahunty (4)
- Frédéric Demians (1)
- Michal Denar (2)
- Paul Derscheid (99)
- Roman Dolny (73)
- Jonathan Druart (117)
- Nicole C. Engard (1)
- Magnus Enger (7)
- Laura Escamilla (34)
- Jeremy Evans (4)
- Katrin Fischer (1567)
- Emily-Rose Francoeur (1)
- Andrew Fuerste-Henry (20)
- Eric Garcia (8)
- Lucas Gass (115)
- Victor Grousset (86)
- Thibaud Guillot (2)
- Amit Gupta (2)
- Bo Gustavsson (1)
- Kyle M Hall (136)
- Andrew Fuerste Henry (5)
- Heather Hernandez (1)
- Olivier Hubert (1)
- Nicolas Hunstein (3)
- Markus John (1)
- Barbara Johnson (10)
- Janusz Kaczmarek (3)
- Jan Kissig (4)
- Thomas Klausner (10)
- Kristi Krueger (13)
- Michał Kula (2)
- Tuomas Kunttu (2)
- Emily Lamancusa (63)
- Sam Lau (25)
- Brendan Lawlor (37)
- Kelly McElligott (1)
- LEBSimonsen (14)
- Owen Leonard (100)
- Yanjun Li (2)
- CJ Lynce (6)
- Jesse Maseto (1)
- Julian Maurice (49)
- Kelly McElligott (3)
- Esther Melander (16)
- David Nind (372)
- Alexandre Noel (2)
- Laura ONeil (3)
- Philip Orr (1)
- Hayley Pelham (3)
- Eric Phetteplace (2)
- Hannah Prince (1)
- Martin Renvoize (603)
- Riomar Resurreccion (1)
- Phil Ringnalda (67)
- Jason Robb (2)
- Marcel de Rooy (121)
- Caroline Cyr La Rose (11)
- Johanna Räisä (1)
- Lisette Scheer (27)
- Michaela Sieber (24)
- Maryse Simard (1)
- Michael Skarupianski (1)
- Fridolin Somers (1)
- Sam Sowanick (10)
- Tadeusz „tadzik” Sośnierz (6)
- Edith Speller (9)
- Michelle Spinney (2)
- Jan Steinberg (1)
- Martha Sullivan (1)
- Arthur Suzuki (7)
- Emmi Takkinen (9)
- Loïc Vassaux--Artur (1)
- Loïc Vassaux-Artur (1)
- Olivier Vezina (30)
- Marc Véron (1)
- Alexander Wagner (2)
- Shi Yao Wang (3)
- George Williams (2)
- Baptiste Wojtkowski (5)
- Chloe Zermatten (5)
- Anneli Österman (5)

And people who contributed to the Koha manual during the release cycle of Koha 24.11.00

- Rudolf Byker (5)
- Manu B (8)
- Catrina Berka (3)
- Aude Charillon (24)
- Caroline Cyr La Rose (194)
- Jonathan Field (5)
- Heather Hernandez (4)
- Thibault Keromnès (2)
- Jan Kissig (1)
- Cécile Lambour (1)
- Brendan Lawlor (1)
- David Nind (1)
- Philip Orr (16)
- Eric Phetteplace (1)
- Heather Rommens (3)
- Mathieu Saby (1)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Notes from the Release Manager

Getting a release out is a big adventure, including some monsters and also big rewards. I'd like to give some special thanks to:

- My employer BSZ and my coworkers for enabling me to do this in the first place and for a second time.
- The RM assistants Jonathan, Martin and Tomás for their help and support.
- Our Release Maintainers for their never-ending work of backporting.
- The people of the Koha Community for all their contributions. This wouldn't be possible without you.
- The libraries using Koha, without you everything we do would be pointless.
- Jenkins: we've been better this time around, but I'd really like if you were failing less randomly at times.

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

Autogenerated release notes updated last on 25 Nov 2024 15:45:07.
