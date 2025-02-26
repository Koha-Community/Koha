# RELEASE NOTES FOR KOHA 24.11.02
26 Feb 2025

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 24.11.02 can be downloaded from:

- [Download](https://download.koha-community.org/koha-24.11.02.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 24.11.02 is a bugfix/maintenance and security release.

It includes 5 enhancements, 61 bugfixes and 12 security fixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [28478](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28478) MARC detail and ISBD pages still show suppressed records
- [28907](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28907) Potential unauthorized access in public REST routes
- [36081](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36081) ArticleRequestsSupportedFormats not enforced server-side
- [37266](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37266) patron_lists/delete.pl should have CSRF protection

  **Sponsored by** *Athens County Public Libraries*
- [37816](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37816) Stop SIP2 from logging passwords
- [38454](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38454) Memory (L1) cache is not flushed before API requests
- [38467](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38467) Template::Toolkit filters can create risky Javascript when not using RFC3986
- [38469](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38469) Circulation returns vulnerable to reflected XSS
- [38488](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38488) Add TT filter using HTML scrubber
- [38829](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38829) [CVE-2025-22954] SQL Injection in lateissues-export.pl
- [38961](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38961) XSS in vendor search

  **Sponsored by** *Chetco Community Public Library*
- [39170](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39170) Remote Code Execution within Task Scheduler

## Bugfixes

### Accessibility

#### Other bugs fixed

- [38644](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38644) Breadcrumbs disappear when zoomed in
  >This fixes the display of breadcrumbs in the OPAC for smaller screen sizes - when the page was zoomed in or viewed on a mobile device, the breadcrumbs disappeared.

  **Sponsored by** *Athens County Public Libraries*

### Acquisitions

#### Critical bugs fixed

- [37993](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37993) Having a single EDI EAN account produces a bad redirect
  >This fixes creating an EDIFACT order for a basket in acquisitions - if there was only one library EAN defined, then a 403 page error was generated. It also simplifies creating an EDIFACT order:
  >- If there are no library EANs defined, the "Create EDIFACT order" button is greyed out and has a tooltip "You must define an EAN in Administration > Library EANs".
  >- If there is only one library EAN defined, you are prompted to generate the order without needing to select an EAN.
  >- If there is more than one library EAN, the "Create EDIFACT order" button incorporates a dropdown list with the available library EANs.
  >(The error is related to the CSRF changes added in Koha 24.05 to improve form security.)

#### Other bugs fixed

- [38155](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38155) Can't close invoices using checkboxes from invoices.pl
  >This fixes closing and reopening of invoices (Acquisitions > [Vendor] > Invoices). Previously, the invoices you selected weren't closed or reopened when clicking on the "Close/Reopen selected invoices" button - all that happened was that one of the selected invoices was displayed instead. (This is related to the CSRF changes added in Koha 24.05 to improve form security.)
- [38659](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38659) Cannot set a new suggestion manager when editing a suggestion
  >This fixes editing suggestions so that you can change the suggestion manager in the staff interface. Previously, you could select a new suggestion manager, but the managed by field wasn't updated or saved.

### Architecture, internals, and plumbing

#### Other bugs fixed

- [38624](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38624) browserid_include.js no longer used
  >This removes a JavaScript file previously used in OPAC templates that is no longer used (js/browserid_include.js).
- [38653](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38653) Obsolete call on system preference 'OPACLocalCoverImagesPriority'
  >This fixes the OPAC search results page by removing a call to system preference OPACLocalCoverImagesPriority - this system preference no longer exists. (There is no visible difference to the OPAC search results page.)

### Circulation

#### Critical bugs fixed

- [38588](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38588) Checkin that triggers a transfer => print slip => Internal server error
  >This fixes a regression caused by bug 35721 in Koha 24.11. When checking in an item that needs transferring to its home library, printing the slip was generating an error ("..Active item transfer already exists' with transfer..").

#### Other bugs fixed

- [38512](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38512) Item table status column display is wrong when record has recalls
  >This fixes the display of recalls in the holdings table - the "Recalled by [patron] on [date]" message now only shows for item-level recalls. Previously, the message was displayed for all items when a record-level recall was made.
- [38649](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38649) Searching for a patron from additem.pl triggers an issue slip to print
  >This fixes an issue when searching for a patron using the check out menu item in the header, when you are on the add or edit item form for a record. It was triggering a blank issue slip for printing. This was caused by a change in Bug 37407 (Fast add/fast cataloging from patron checkout does not checkout item) that affected checking referrer URLs and query strings.
- [38985](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38985) Syndetics covers don't show on OPAC result pages

### Command-line Utilities

#### Other bugs fixed

- [38382](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38382) Need a fresh connection when CSRF has expired for connexion daemon
  >This fixes the OCLC Connexion import daemon (misc/bin/connexion_import_daemon.pl) - the connection was failing after the CSRF token expired (after 8 hours). It now generates a new user agent when reauthenticating when the CSRF token for the session has expired. (This is related to the CSRF changes added in Koha 24.05 to improve form security.)
- [38386](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38386) compare_es_to_db.pl shouldn't retrieve the records from ES
  >This small enhancement makes the `compare_es_to_db.pl` maintenance script require less resources when run.

### Fines and fees

#### Other bugs fixed

- [28097](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28097) t/db_dependent/Koha/Account/Line.t test fails with FinesMode set to calculate

### Hold requests

#### Critical bugs fixed

- [38919](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38919) Checkin does not notify of waiting holds

### I18N/L10N

#### Other bugs fixed

- [38450](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38450) Missing translation string in catalogue_detail.inc
  >This fixes some missing strings in the po files used for translation. Strings in this format were being included for translation: _("This %s is picked").format(foo) However, strings using this format were not: _("This %s is NOT picked".format(bar))
- [38707](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38707) Patron restriction types from installer files not translatable
  >This fixes installer files so that the default patron restriction types are now translatable.
- [38726](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38726) marc vs. MARC in admin-home.tt
  >This fixes the spelling in the description for Administration > Acquisition parameters > MARC order accounts (requires enabling the MarcOrderingAutomation system preference). It changes 'marc' to 'MARC'.

### ILL

#### Other bugs fixed

- [38530](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38530) ILL request table won't load if libraries are in groups and staff doesn't have view_borrower_infos_from_any_libraries
  >This fixes the interlibrary loan (ILL) requests table so that it loads (instead of saying "Processing") when library groups are used, and:
  >- the library group has the feature "Limit patron visibility to libraries within this group for members" (Limit patron data access by group) set
  >- library staff don't have permission to view patron information from any libraries (view_borrower_infos_from_any_libraries).
  >
  >The ILL table now loads, and shows "A patron from another library" for the patron details.
- [38675](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38675) 'Switch provider' dropdown options not styled properly
  >This fixes the styling for the 'Switch provider' dropdown list for interlibrary loan requests - the options are now styled correctly, instead of appearing as plain text links.

### Installation and upgrade (command-line installer)

#### Critical bugs fixed

- [38750](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38750) Installer process not terminating when nothing to do
  >This fixes the installation process - instead of getting "Try again" when there is nothing left to do (after updating the database structure) and not being able to finish, you now get "Everything went okay. Update done."
- [38779](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38779) Record sources not working on packages install
  >This fixes the record sources page (Administration > Cataloging > Record sources) for package installs - you can now add and edit record sources, instead of getting a blank page. The Koha packages were missing the required JavaScript files (/intranet-tmpl/prog/js/vue/dist/admin/record_sources_24.1100000.js"></script>) to make the page work correctly.

### MARC Bibliographic data support

#### Critical bugs fixed

- [32722](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32722) UNIMARC: Remove mandatory flag from some subfields and field in default bibliographic framework
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

### OPAC

#### Critical bugs fixed

- [38683](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38683) OPAC cover images are only shown on first result page
  >This fixes OPAC search results when cover images are enabled - covers are now shown on all the result pages, instead of just the first page of results.

#### Other bugs fixed

- [38422](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38422) Add data-isbn and data-title to lists for plugin cover images
  >This enhancement adds cover images to OPAC lists, for OPAC enabled cover image sources.
  >
  >(Note: This currently only displays nicely with one source of cover images. With multiple sources enabled, the images are listed vertically.)
- [38544](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38544) OPAC modal login should not exist when OPAC login is disabled
  >This removes the OPAC login dialog box from the HTML when logging into the OPAC is turned off (opacuserlogin system preference), rather than just making it not visible.
- [38596](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38596) DataTable - previous order sequence behaviour not restored at the OPAC
  >This fixes the display of the ordering arrows in OPAC table heading rows so that the sort options are ascending (the down arrow), and descending (the up arrow). It removes an incorrect intermediate stage where no arrows were highlighted. (This is related to the upgrade to DataTables 2.x in Koha 24.11.)
- [38657](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38657) Image obscured by the search results toolbar when previewing cover images from OPAC search results
  >This fixes the display of cover images in the OPAC - the image viewer was appearing behind the search results toolbar, partially obscuring the cover image.

  **Sponsored by** *Athens County Public Libraries*
- [39003](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39003) Cannot see suspend column in user's hold table on OPAC
  >This fixes the OPAC > Summary > Holds table for a logged in patron - the 'Suspend' column is now shown.

### Packaging

#### Other bugs fixed

- [33018](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33018) Debian package tidy-up
  >This removes unneeded Debian package dependencies. Previously we provided them in the Koha Debian repository, but we no longer need to as they are now available in the standard repositories.

### Patrons

#### Other bugs fixed

- [37992](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37992) Patron search results: table header with column filters isn't sticky anymore
  >This fixes the sticky header for patron search results - it now includes the column headings and filters. (This restores the behavour to what it was in Koha 23.11.)
- [38429](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38429) Ambiguous patron category when adding a new guarantee
  >This improves adding a guarantee for a patron (+ Add guarantee). Where there is more than one patron category that can be a guarantee, the add guarantee button now includes a dropdown list of the categories. This removes the need to manually select the patron category on the patron add form - previously, if not changed, the first patron category in the list was selected by default.

### REST API

#### Other bugs fixed

- [38678](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38678) GET /deleted/biblios cannot be filtered on `deleted_on`

### SIP2

#### Other bugs fixed

- [38486](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38486) No block checkouts are still blocked by fines, checkouts, and blocked item types
  >This fixes SIP so that it allows noblock checkouts, regardless of normal patron checkout blocks.
  >
  >Explanation: The purpose of no block checkouts in SIP is to indicate that the SIP machine has made an offline ("store and forward") transaction. The patron already has the item. As such, the item must be checked out to the patron or the library risks losing the item due to lack of tracking. As such, no block checkouts should not be blocked under any circumstances.

### Searching

#### Other bugs fixed

- [38935](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38935) "Actions" column not translatable for the item search results table (itemsearch.tt)
  >This fixes the item search results table in the staff interface - the "Actions" column label is now translatable.

### Searching - Elasticsearch

#### Critical bugs fixed

- [38913](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38913) Elasticsearch indexing explodes with some oversized records with UTF-8 characters

#### Other bugs fixed

- [38101](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38101) ES skips records with huge fields
  >This fixes indexing of subfields with a large amount of text (such as 500$a) - the text is now indexed, and the record can now be found. Previously, subfields with a large amount of text were not correctly indexed.

### Staff interface

#### Critical bugs fixed

- [38070](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38070) Regression in print notices
  >This fixes a regression from the Boostrap 5 upgrade for print notices. Each notice is now on its own page, instead of running one after the other without a page break (when running gather_print_notices.pl with HTML file output). (This is related to the OPAC and staff interface Bootstrap 5 upgrade in Koha 24.11.)

#### Other bugs fixed

- [38367](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38367) offset is wrong on plugins-disabled.tt page
  >This fixes the display of the plugins page, when plugins are disabled in koha-conf.xml and the page is accessed directly. The message that plugins are disabled is now indented, instead of aligned to the far left.
- [38465](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38465) Cannot schedule a curbside pickup
  >This removes duplicated JavaScript library includes from the curbside pickup page, as they are now included in the main include. (This is a follow-up to bug 36454 - Provide indication if a patron is expired or restricted on patron search autocomplete, a new feature added in Koha 24.11.00.)

### Templates

#### Critical bugs fixed

- [38268](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38268) Callers of confirmModal need to remove the modal as the first step in their callback function
  >This fixes confirm dialog boxes in the OPAC to prevent unintended actions being taken, such as accidentally deleting a list. This specifically fixes lists, and makes a technical change to prevent this happening in the future for other areas of the OPAC (such as suggestions, tags, and self-checkout).
  >
  >Example of issue fixed for lists: 
  >1. Create a list with several items.
  >2. From the new list, select a couple of the items.
  >3. Click "Delete list" and then select "No, do not delete".
  >4. Then select "Remove from list", and confirm by clicking "Yes, remove from list".
  >5. Result: Instead of removing the items selected, the whole list was incorrectly deleted!

  **Sponsored by** *Chetco Community Public Library*

#### Other bugs fixed

- [37634](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37634) Missing "USE Koha" causes JS errors and missing "Last patron" menu
  >This fixes the cause of the "Last patron" menu not displaying on many staff interface pages, or generating JavaScript errors (where showLastPatron is enabled). (It adds "[% USE Koha %]" to templates where it was missing. It also removes some duplicate USE entries.)

  **Sponsored by** *Athens County Public Libraries*
- [38347](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38347) Fix style of sidebar form submit button on bookings to collect page
  >This fixes the style for the submit button on the bookings to collect page (Circulation > Bookings to collect). It now has the same yellow "primary" style as other submit buttons, and it fills the width of the sidebar.

  **Sponsored by** *Athens County Public Libraries*
- [38350](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38350) Fix style of sidebar form clear buttons
  >This fixes the markup and CSS for sidebar forms that contain a submit button and a clear button (for example, the patrons and ILL requests sidebars). The submit button is now wider than the clear button for visual emphasis.

  **Sponsored by** *Athens County Public Libraries*
- [38519](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38519) Improve contrast of Bootstrap alerts and text background classes
  >This updates the staff interface CSS to improve the visibility and contrast in Bootstrap alerts and text with background classes. (This is related to the OPAC and staff interface Bootstrap 5 upgrade in Koha 24.11.)

  **Sponsored by** *Athens County Public Libraries*
- [38611](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38611) Change 'Staff' to 'Staff interface' in HTML customization locations
  >This fixes the HTML customization display location dropdown list so that the "Staff" grouping is now "Staff interface". This makes it clearer for translation.
- [38701](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38701) Fix HTML validity errors in invoice template
  >This fixes some HTML markup errors on the Acquisitions > Invoices page - it now passes W3C HTML validation checks.

  **Sponsored by** *Athens County Public Libraries*
- [38813](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38813) Curbside pickups tab not selected in OPAC

### Tools

#### Critical bugs fixed

- [31450](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31450) HTML customizations and news will not display on OPAC without a publication date
  >This fixes the display of news, HTML customizations, and pages on the OPAC - a publication date is now required for all types of additional content. Previously, news items and HTML customizations were not shown if they didn't have a publication date (this behavour was not obvious from the forms).

  **Sponsored by** *Athens County Public Libraries*

#### Other bugs fixed

- [38452](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38452) Inventory tool barcodes should not be case sensitive
  >This fixes the inventory tool so that it ignores case sensitivity for barcodes, similar to other areas of Koha such as checking in and checking out items (for example, ABC123 and abc123 are treated the same).
- [38531](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38531) Include action_logs.diff when reverting hold
  >This fixes the holds log so that the diff now includes the changes when reverting a hold. (This was missed when the diff in JSON format feature was added to Koha 24.05 by bug 25159.).

## Enhancements 

### Hold requests

#### Enhancements

- [37427](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37427) Searching for an empty string for clubs in an item's hold tab is not allowed
  >This improves searching for patron clubs on a record's holds page - it now works similar to the patron search tab. You can now click search with no text in the search box, and a list of clubs are displayed. Previously, you had to enter the club ID or partial name to get a result.

### Staff interface

#### Enhancements

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

### Tools

#### Enhancements

- [37360](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37360) Add 'protected status' as one of the things that can be updated via batch patron modification
  >This enhancement to the batch patron modification tool allows superlibrarians to batch update the protected status setting for patrons, instead of having to change each patron individually. The edit patrons form now includes the "Protected" field. (The protected status option for patrons was added in Koha 23.11.

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Armenian (hy_ARMN)](https://koha-community.org/manual/24.11//html/) (58%)
- [Bulgarian (bg_CYRL)](https://koha-community.org/manual/24.11//html/) (98%)
- [Chinese (Traditional)](https://koha-community.org/manual/24.11/zh_Hant/html/) (99%)
- [English](https://koha-community.org/manual/24.11//html/) (100%)
- [English (USA)](https://koha-community.org/manual/24.11/en/html/)
- [French](https://koha-community.org/manual/24.11/fr/html/) (59%)
- [German](https://koha-community.org/manual/24.11/de/html/) (100%)
- [Greek](https://koha-community.org/manual/24.11//html/) (93%)
- [Hindi](https://koha-community.org/manual/24.11/hi/html/) (71%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<!-- <div style="column-count: 2;"> -->

- Arabic (ar_ARAB) (96%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified) (86%)
- Chinese (Traditional) (99%)
- Czech (67%)
- Dutch (87%)
- English (100%)
- English (New Zealand) (61%)
- English (USA)
- Finnish (99%)
- French (100%)
- French (Canada) (98%)
- German (100%)
- Greek (64%)
- Hindi (97%)
- Italian (81%)
- Norwegian Bokmål (74%)
- Persian (fa_ARAB) (97%)
- Polish (99%)
- Portuguese (Brazil) (98%)
- Portuguese (Portugal) (87%)
- Russian (92%)
- Slovak (60%)
- Spanish (99%)
- Swedish (86%)
- Telugu (68%)
- Tetum (51%)
- Turkish (83%)
- Ukrainian (71%)
- hyw_ARMN (generated) (hyw_ARMN) (62%)
<!-- </div> -->

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](https://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](https://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](https://translate.koha-community.org/)

## Release Team

The release team for Koha 24.11.02 is


- Release Manager: Katrin Fischer

- Release Manager assistants:
  - Tomás Cohen Arazi
  - Martin Renvoize
  - Jonathan Druart

- QA Manager: Martin Renvoize

- QA Team:
  - Victor Grousset
  - Lisette Scheer
  - Emily Lamancusa
  - David Cook
  - Jonathan Druart
  - Julian Maurice
  - Baptiste Wojtowski
  - Paul Derscheid
  - Aleisha Amohia
  - Laura Escamilla
  - Tomás Cohen Arazi
  - Kyle M Hall
  - Nick Clemens
  - Lucas Gass
  - Marcel de Rooy
  - Matt Blenkinsop
  - Pedro Amorim
  - Brendan Lawlor
  - Thomas Klausner

- Security Manager: Tomás Cohen Arazi

- Topic Experts:
  - UI Design -- Owen Leonard
  - REST API -- Tomás Cohen Arazi
  - Zebra -- Fridolin Somers

- Bug Wranglers:
  - Michaela Sieber
  - Jacob O'Mara
  - Jake Deery

- Packaging Manager: Mason James

- Documentation Manager: Philip Orr

- Documentation Team:
  - Aude Charillon
  - David Nind
  - Caroline Cyr La Rose

- Wiki curators: 
  - George Williams
  - Thomas Dukleth
  - Jonathan Druart
  - Martin Renvoize

- Release Maintainers:
  - 24.11 -- Paul Derscheid
  - 24.05 -- Wainui Witika-Park
  - 23.11 -- Fridolin Somers
  - 22.11 -- Laura Escamilla


## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 24.11.02
<!-- <div style="column-count: 2;"> -->

- Athens County Public Libraries
- Chetco Community Public Library
<!-- </div> -->

We thank the following individuals who contributed patches to Koha 24.11.02
<!-- <div style="column-count: 2;"> -->

- Pedro Amorim (1)
- Tomás Cohen Arazi (12)
- Matt Blenkinsop (3)
- Nick Clemens (3)
- David Cook (6)
- Jake Deery (2)
- Paul Derscheid (2)
- Jonathan Druart (12)
- Magnus Enger (1)
- Lucas Gass (8)
- Kyle M Hall (2)
- Andrew Fuerste Henry (2)
- Mason James (2)
- Janusz Kaczmarek (1)
- Emily Lamancusa (4)
- Sam Lau (1)
- Brendan Lawlor (3)
- Owen Leonard (12)
- Julian Maurice (1)
- Martin Renvoize (6)
- Phil Ringnalda (4)
- Marcel de Rooy (3)
- Caroline Cyr La Rose (2)
- Mathieu Saby (1)
- Lisette Scheer (1)
- Fridolin Somers (2)
- Emmi Takkinen (1)
- Lari Taskula (9)
<!-- </div> -->

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 24.11.02
<!-- <div style="column-count: 2;"> -->

- Athens County Public Libraries (12)
- [BibLibre](https://www.biblibre.com) (3)
- [ByWater Solutions](https://bywatersolutions.com) (16)
- [Cape Libraries Automated Materials Sharing](https://info.clamsnet.org) (3)
- Chetco Community Public Library (4)
- [Hypernova Oy](https://www.hypernova.fi) (9)
- Independant Individuals (3)
- Koha Community Developers (12)
- [Koha-Suomi Oy](https://koha-suomi.fi) (1)
- KohaAloha (2)
- [Libriotech](https://libriotech.no) (1)
- [LMSCloud](lmscloud.de) (2)
- [Montgomery County Public Libraries](montgomerycountymd.gov) (4)
- [Prosentient Systems](https://www.prosentient.com.au) (6)
- [PTFS Europe](https://ptfs-europe.com) (12)
- Rijksmuseum, Netherlands (3)
- [Solutions inLibro inc](https://inlibro.com) (2)
- [Theke Solutions](https://theke.io) (12)
<!-- </div> -->

We also especially thank the following individuals who tested patches
for Koha
<!-- <div style="column-count: 2;"> -->

- Pedro Amorim (1)
- Matt Blenkinsop (6)
- Catrina (1)
- Nick Clemens (2)
- David Cook (7)
- Paul Derscheid (105)
- Roman Dolny (2)
- Jonathan Druart (6)
- Magnus Enger (13)
- Katrin Fischer (73)
- Lucas Gass (6)
- Victor Grousset (19)
- Andrew Fuerste Henry (3)
- Barbara Johnson (3)
- Jan Kissig (1)
- Emily Lamancusa (4)
- Brendan Lawlor (6)
- Owen Leonard (6)
- Julian Maurice (5)
- David Nind (25)
- Laura ONeil (1)
- Martin Renvoize (25)
- Phil Ringnalda (4)
- Marcel de Rooy (32)
- Lisette Scheer (3)
- Sam Sowanick (3)
- Emmi Takkinen (1)
- Olivier Vezina (2)
- Baptiste Wojtkowski (4)
<!-- </div> -->





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

Autogenerated release notes updated last on 26 Feb 2025 18:36:49.
