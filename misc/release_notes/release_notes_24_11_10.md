# RELEASE NOTES FOR KOHA 24.11.10
28 Oct 2025

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 24.11.10 can be downloaded from:

- [Download](https://download.koha-community.org/koha-24.11.10.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 24.11.10 is a bugfix/maintenance release with security bugs.

It includes 6 enhancements, 115 bugfixes (2 security).

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [40525](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40525) CSV formula injection - client side (DataTables) in OPAC
- [40818](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40818) marc_lib is mostly used raw in templates

## Bugfixes

### Accessibility

#### Other bugs fixed

- [39274](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39274) HTML bg-* elements are low contrast

  **Sponsored by** *Athens County Public Libraries*
- [39597](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39597) When cancelling multiple holds on a bib record cancel_hold_alert has very low contrast
- [40609](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40609) Invisible Button Styling in "hint" Container Until Hovered

### Acquisitions

#### Other bugs fixed

- [39029](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39029) When a basket contains an order transferred from another basket some information is incorrect
- [39169](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39169) Acquisitions homepage no longer automatically hides "active" and "budget period" columns
- [39530](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39530) Make MARC ordering cronjob respect the AcqCreateItems system preference
- [39752](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39752) Koha MarcOrder does not verify bibliographic record exists when adding order and items
- [39787](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39787) Sending EDI order from basket fails if only one Library EAN exists
- [39904](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39904) EDIFACT error messages are malformed
- [40861](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40861) "Odd number of elements in anonymous hash" warning in serials/acqui-search-result.pl

### Architecture, internals, and plumbing

#### Critical bugs fixed

- [40608](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40608) Password not changed if PASSWORD_CHANGE letter absent

#### Other bugs fixed

- [39485](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39485) "Wide character in print" when exporting from staff interface and OPAC
- [39606](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39606) Cover change from bug 39294 with a Cypress test
  >This adds Cyress tests for staging MARC records for import.
- [39618](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39618) Add a non-unique index/key to borrowers table for preferred_name
- [39623](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39623) "make install" re-runs "make" process unnecessarily
- [39734](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39734) Obsolete call of system preference IntranetmainUserblock
- [39826](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39826) Vendor interface's password not utf8 decoded on display
- [39833](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39833) mysqldump SET character_set_client = utf8 vs utf8mb4
- [40585](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40585) Prevent crash on biblionumber in addbybiblionumber.pl
- [40725](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40725) DBRev 23.12.00.053 should be made more resilient

### Cataloging

#### Other bugs fixed

- [31460](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31460) Merging biblio records with attached item groups losing groups
- [37546](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37546) We should output error messages alongside error codes for z39.50 errors
  >This fixes the output displayed for errors returned from Z39.50 searches within Koha. Error messages and additional information are now shown for any error codes (when they are returned), making it easier to troubleshoot issues.
  >
  >The message output now has the 'message' first, followed by the error reference inside brackets, the "for [SERVERNAME]", and finally "result No."
- [38925](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38925) Update record 'date entered on file' when duplicating a record -- in advanced editor
- [38967](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38967) Export to CSV or Barcode file from item search results fail when "select visible rows" and many items are selected
- [39321](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39321) Hide subfield tag for fixed length control fields
- [39561](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39561) Users with only editcatalogue: fast_cataloging cannot easily add an item if a duplicate is found

### Circulation

#### Other bugs fixed

- [38861](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38861) Error loading the table in the bookings to collect report
  >This patch fixes a bug where the bookings to collect table was not loading correctly.
- [39212](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39212) Error when attempting to edit a booking
- [39389](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39389) Cannot use dataTables export function on checkout table in members/moremember.pl
- [39421](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39421) Renewal date input field (and date picker) not showing on Circulation > Renew
  >This restores the renewal due date input field and date picker on the Circulation > Renew page - this was missing. It changes the behavor slightly so that it matches the Circulation > Check in page (and other areas of Koha) - the barcode input field now has a settings icon, clicking this now shows the renewal date input field (with the date picker).
- [39569](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39569) When cancelling a hold waiting past expiration date triggers a transfer the libraries name is not in alert
- [39604](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39604) Remember for the session for this patron doesn't remember to cancel a hold
- [39692](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39692) With OnSiteCheckoutsForce the due date should be set
- [39696](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39696) Low contrast for claim return date in circulation overdue report
  >This fixes the color of the date in the return claims column on the overdues page (Circulation > Overdues > Overdues) - the date is now shown in black, instead of white.
  >
  >Previously, the date shown after a claim returned action is completed was white. The date not visible in rows with a white background, and was almost invisible in rows with a grey background.
- [40643](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40643) circulation.tt attaches event listeners to keypress in a problematic way
- [40644](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40644) Bookings biblio checks erroneously if multiple check-outs and bookings exist
- [40678](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40678) Choices are not remembered if a wrong transfer modal is generated
  >This patchset fixes a bug where the "Drop box mode" and "Forgive overdue charges" checkbox values were not retained when a wrong transfer modal is displayed.
- [40679](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40679) Existing holds toolbar goes wonky if you select 'del' from priority dropdown
  >Fixes a problem in the UI that would make the toolbar look wrong when 'del' is selected in the priority dropdown on reserve/request.tt
- [40689](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40689) "Lost status" and "Damaged status" don't appear on moredetail.pl if user can't update them
- [40690](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40690) Checkout status doesn't appear on moredetail.pl if item is not checked out
- [40709](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40709) Status filter will display in wrong column if item-level_itypes is set to bibliographic record

### Command-line Utilities

#### Other bugs fixed

- [39733](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39733) Update code comment with a TODO in misc/cronjobs/staticfines.pl

### Database

#### Other bugs fixed

- [38906](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38906) REGEXP_REPLACE not in MySQL < 5.7b DB update 24.06.00.064 fails

### ERM

#### Other bugs fixed

- [35885](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35885) ERM vendor sort order
- [39075](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39075) Fix DB inconsistencies in the usage statistics module
- [39543](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39543) Error modal when trying to add two controlling licences to an agreement duplicates error message

### Hold requests

#### Critical bugs fixed

- [40620](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40620) Holds Queue will assign to the lowest item number if multiple branches have the same transport cost

#### Other bugs fixed

- [33224](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33224) OPACHoldsIfAvailableAtPickup and no on-shelf holds don't mix well
- [40331](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40331) Extra transfer generated when transfer for hold cancelled due to checkin at incorrect library
- [40515](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40515) Mark as lost and notify patron is broken in pendingreserves.pl
- [40747](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40747) Placeholder text in the filter row for Publication Details on the holds queue is incorrect

### Holidays

#### Other bugs fixed

- [38633](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38633) Calendar - Weekly closures are ignored when setting a yearly repeating holiday

### I18N/L10N

#### Other bugs fixed

- [37926](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37926) Bookings - "to" untranslatable

  **Sponsored by** *Athens County Public Libraries*
- [38630](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38630) Make the REST API respect KohaOpacLanguage cookie
- [38903](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38903) getTranslatedLanguages is still called with wrong theme
- [38904](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38904) admin/localization should allow translation into languages only available in the OPAC

### ILL

#### Other bugs fixed

- [39783](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39783) HTML error for option DVD in ILL form
- [39784](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39784) xxx as translatable string in ILL

### Label/patron card printing

#### Other bugs fixed

- [39800](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39800) Error 500 when trying to delete patron card template

### MARC Bibliographic data support

#### Other bugs fixed

- [40618](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40618) The display of the field 255 (Cartographic Mathematical Data) is missing (both in intranet and OPAC)

  **Sponsored by** *Ignatianum University in Cracow*

### Notices

#### Other bugs fixed

- [39317](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39317) Saving a letter template can lead to a CSRF error on some installs

### OPAC

#### Other bugs fixed

- [33012](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33012) Accessibility: Some navigation items in OPAC cannot be accessed by keyboard (search history, log out)
  >This fixes the OPAC navigation menus when logged in so that keyboard users can use the tab key to navigation menus. Some menu items (such as some list options, search history, and log out) were not selectable when just using the tab key.
- [38455](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38455) UNIMARC XSLT Music incipit (036) try to display field 031 (as in MARC21)
- [39449](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39449) OPAC table sort arrows show opposite sort direction
- [39500](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39500) Subfield 111 $n is badly displayed in OPAC
- [39528](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39528) Get rid of schema.org type "Product"

  **Sponsored by** *Karlsruhe Institute of Technology (KIT)*
- [39582](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39582) Syndetics covers don't show on OPAC result pages when identifier is not ISBN
- [39603](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39603) OPAC advanced search display or ITEMTYPECAT is wrong if other  authorised values have the same code
- [39735](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39735) Typo in system preference call 'OPACFineNoRenewalsIncludeCredit'
- [39736](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39736) Obsolete call on system preference 'OPACResultsSidebar'
- [39737](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39737) Obsolete call on system preference 'PatronSelfRegistrationAdditionalInstructions'
- [39738](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39738) Obsolete call on system preference 'SelfCheckHelpMessage'
  >This patch obsoletes some old code related to the SelfCheckHelpMessage system preference. The system preference was made obsolete by Bug 35065 which moved the system preference into HTML customization.
- [40614](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40614) Invalid markup in cookie consent modal

  **Sponsored by** *Athens County Public Libraries*
- [40759](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40759) Wrong date format in subscription brief history in OPAC
- [40782](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40782) Selections toolbar buttons should not be focusable when they are inactive
  >The selections toolbar on OPAC search results now properly manages keyboard focus for disabled buttons. Previously, visually disabled toolbar buttons (such as "Add to cart" or "Add to list" when no items were selected) could still receive keyboard focus, which was confusing for screen reader users.
  >
  >Disabled toolbar buttons now have `tabindex="-1"` applied, making them non-focusable until they become active. When items are selected and the buttons become enabled, they are automatically made focusable again.
  >
  >This enhancement improves the keyboard navigation experience and ensures that assistive technology users are not misled by inactive controls that appear to be interactive.

### Patrons

#### Other bugs fixed

- [38841](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38841) Guarantor does not check non members guarantor while deleting with ChildNeedsGuarantor
  >This patch allows a librarian to replace a member guarantor with a non-member guarantor. Before this patch, saving a child's profile with the "delete [this guarantor]" box checked and the data entered in the non-member guarantor field resulted in an error because koha refused to delete the last guarantor.
- [39379](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39379) The "Edit" button appears in patron search results even when you cannot edit the patron
- [39576](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39576) 'Last patron' results should display preferred name
- [39652](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39652) Pseudonymized_borrower_attributes causes subsequent pseudonymized_transactions to not be added
- [40566](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40566) "Home library" empty on "Recalls history"
  >This fixes the recalls history page for a patron - the patron's home library is now shown in the patron information section in the staff interface (previously, "Home library:" was shown without the patron's actual home library showing).
- [40807](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40807) Quick add form does not include 'username' when it is included in BorrowerMandatoryFields

### Plugin architecture

#### Other bugs fixed

- [40812](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40812) Move Theke sample plugin repo to Github

### REST API

#### Other bugs fixed

- [39771](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39771) The `data` attribute in job.yaml should be nullable
- [40543](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40543) pickup_library.branchname embed wrong

### SIP2

#### Other bugs fixed

- [39820](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39820) Items with hold cancellation requests should have the hold cancelled when checked in via SIP
  >This fixes checking in items using SIP, and there is a hold cancellation request - the hold is now cancelled.
  >
  >Before this, it did not cancel the hold and it was still listed under "Holds with cancellation requests" (Circulation > Holds > Holds awaiting pickup).
- [39842](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39842) SIP current_location field is never sent
- [40675](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40675) Carriage return in patron note message breaks SIP

### Searching

#### Other bugs fixed

- [39020](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39020) Search filters can't parse query in some instances
- [39072](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39072) Item search shareable link adding selections for similar LOC auth values

### Searching - Elasticsearch

#### Other bugs fixed

- [39079](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39079) Matchpoints with multiple fields require all fields to match under Elasticsearch

### Self checkout

#### Other bugs fixed

- [39484](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39484) Can't play audio alerts on self checkout from an external source

### Serials

#### Other bugs fixed

- [39775](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39775) Serials claims table filters aren't working
  >This restores the table filters for serial claims search results - they are now located at the top of the table, and actually work. This was a regression.
- [39814](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39814) Filters on subscription search are broken
  >This restores the column filters to the top of the table for serials search - they are now located at the top of the table, and actually work. This was a regression.

### Staff interface

#### Critical bugs fixed

- [39930](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39930) Saved configuration states on tables are lost overnight

#### Other bugs fixed

- [39080](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39080) Table headers of holds to pull table are incorrect size on scroll
- [39663](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39663) Patrons entry in additional fields has wrong  header
  >This fixes the heading level for Koha administration > Additional parameters > Additional fields > Patrons - from an H3 to an H2 (follow-up to Bug 38662 - Additional fields admin page hard to read).
- [40651](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40651) Item search custom field selection is not populated in shareable link

### System Administration

#### Other bugs fixed

- [39525](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39525) Relabel "Hold pickup library match" as "Hold and booking pickup library match"

### Templates

#### Other bugs fixed

- [39354](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39354) Remove unintended Bootstrap 5 change to scroll-behavior
  >This fixes two unexpected and unintentional Bootstrap 5 changes:
  >
  >- It updates the "smooth scroll" behavior introduced in Bootstrap 5 for in-page links. Example: when clicking on a section link for a system administration, the page should jump immediately to that section instead of scrolling.
  >
  >- It updates some multiple-select dropdown lists used by some system preference controls, where a default option is not selected. When you hovered over the dropdown list, the cursor changed to a "waiting" cursor (rotating circle), this behavour is now removed. Example: the ArticleRequestsMandatoryFields system preference.
- [39400](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39400) "Jump to add item form" doesn't work while editing an existing item

  **Sponsored by** *Chetco Community Public Library*
- [39947](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39947) Use bg-*-subtle in preference to bg-* Bootstrap classes
  >This fixes some Bootstrap color classes.
  >
  >It removes a few instances of the "bg-*" class from templates (used in a few places such as bg-info, bg-danger, etc.) as the styles don't really fit with the staff interface's color palette. Examples include the circulation and fine rules page and the patron import tool page.
  >
  >In the places where we don't want to use the corresponding alert classes, it adds some CSS so that we can safely use the ".bg-*-subtle" class to a div with ".page-section.".
  >
  >(This is related to Bug 39274 - HTML bg-* elements are low contrast, added to Koha 25.05, and Bug 35402 - Update the OPAC and staff interface to Bootstrap 5, added to Koha 24.11.)

  **Sponsored by** *Athens County Public Libraries*

### Test Suite

#### Critical bugs fixed

- [40765](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40765) Acquisition tests will fail if order.quantity is set to 0

#### Other bugs fixed

- [39746](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39746) Wrong system preference 'AutoLocation' in test suite
- [39747](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39747) Wrong system preference 'DefaultHoldExpirationUnitOfTime' in test suite
- [39995](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39995) Koha/Biblio.t can fail on slow servers
- [40046](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40046) Remove wait and screenshot from Tools/ManageMarcImport_spec.ts

### Tools

#### Other bugs fixed

- [39070](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39070) Elasticsearch facets are not used/needed when finding record matches
- [39076](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39076) Elasticsearch timeouts when committing import batches
- [39423](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39423) Column checkboxes on item batch modification hide incorrect columns
- [39717](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39717) Stock rotation stages cannot be moved
- [40691](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40691) CCODE label not includes in case of 'wrong place' problem (and maybe others cases) into inventory.pl

  **Sponsored by** *BibLibre*
- [40702](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40702) Inventory CSV export missing "title" header

### Z39.50 / SRU / OpenSearch Servers

#### Other bugs fixed

- [39861](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39861) Z39.50/SRU servers on second page of results cannot be deleted
  >This fixes the Z39.50/SRU servers page so that servers on the second (and later) page of results can now be deleted.

## Enhancements 

### Acquisitions

#### Enhancements

- [38619](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38619) UNIMARC prices should also be extracted from 071d
  >This enhancement imports the value in 071$d to the price field when adding an item to a basket using the "From a new file" option. Before this, it only imported the value from 010$d and 345$d.

### Cataloging

#### Enhancements

- [40839](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40839) Advanced cataloging editor z39.50 search should include Keyword in Advanced Search options
  >This patch makes keyword searching available when performing a z39.50 search via the advanced search modal in the advanced cataloging editor.

### ERM

#### Enhancements

- [39345](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39345) Koha must support COUNTER 5.1
  >This enhancement adds support to the ERM module for Release 5.1 of the Code of Practice for COUNTER Metrics that came into force in January 2025, with a requirement for reports to be delivered by the 28th of February 2025.

### MARC Bibliographic data support

#### Enhancements

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

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [English (USA)](https://koha-community.org/manual/24.11/en/html/)
- [French](https://koha-community.org/manual/24.11/fr/html/) (75%)
- [German](https://koha-community.org/manual/24.11/de/html/) (95%)
- [Greek](https://koha-community.org/manual/24.11/el/html/) (99%)
- [Hindi](https://koha-community.org/manual/24.11/hi/html/) (67%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (95%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified Han script) (86%)
- Chinese (Traditional Han script) (99%)
- Czech (68%)
- Dutch (88%)
- English (100%)
- English (New Zealand) (63%)
- English (USA)
- Finnish (99%)
- French (99%)
- French (Canada) (99%)
- German (100%)
- Greek (68%)
- Hindi (97%)
- Italian (82%)
- Norwegian Bokmål (74%)
- Persian (fa_ARAB) (96%)
- Polish (99%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (87%)
- Russian (94%)
- Slovak (60%)
- Spanish (99%)
- Swedish (87%)
- Telugu (67%)
- Tetum (52%)
- Turkish (83%)
- Ukrainian (73%)
- Western Armenian (hyw_ARMN) (62%)
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

The release team for Koha 24.11.10 is


- Release Manager: Lucas Gass

- QA Manager: Martin Renvoize

- QA Team:
  - Andrew Fuerste-Henry
  - Andrii Nugged
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
  - Petro V
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
new features in Koha 24.11.10
<div style="column-count: 2;">

- Athens County Public Libraries
- [BibLibre](https://www.biblibre.com)
- Chetco Community Public Library
- Ignatianum University in Cracow
- Karlsruhe Institute of Technology (KIT)
</div>

We thank the following individuals who contributed patches to Koha 24.11.10
<div style="column-count: 2;">

- Pedro Amorim (8)
- Tomás Cohen Arazi (12)
- Andrew Auld (1)
- Baptiste (2)
- Alexander Blanchard (2)
- Matt Blenkinsop (3)
- Nick Clemens (17)
- David Cook (7)
- Jake Deery (1)
- Paul Derscheid (1)
- Jonathan Druart (20)
- Marion Durand (1)
- Laura Escamilla (2)
- Katrin Fischer (2)
- Lucas Gass (17)
- Thibaud Guillot (1)
- Kyle M Hall (1)
- Andrew Fuerste Henry (4)
- Janusz Kaczmarek (4)
- Emily Lamancusa (2)
- Brendan Lawlor (2)
- Owen Leonard (8)
- Julian Maurice (1)
- Martin Renvoize (6)
- Phil Ringnalda (1)
- Marcel de Rooy (9)
- Caroline Cyr La Rose (3)
- Bernard Scaife (1)
- Lisette Scheer (2)
- Slava Shishkin (1)
- Michael Skarupianski (1)
- Fridolin Somers (10)
- Imani Thomas (1)
- Hammat Wele (2)
- Baptiste Wojtkowski (4)
- Chloe Zermatten (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 24.11.10
<div style="column-count: 2;">

- Athens County Public Libraries (8)
- [BibLibre](https://www.biblibre.com) (19)
- [Bibliotheksservice-Zentrum Baden-Württemberg (BSZ)](https://bsz-bw.de) (2)
- [ByWater Solutions](https://bywatersolutions.com) (44)
- [Cape Libraries Automated Materials Sharing](https://info.clamsnet.org) (2)
- Chetco Community Public Library (1)
- Independant Individuals (6)
- Koha Community Developers (20)
- [LMSCloud](https://www.lmscloud.de) (1)
- [Montgomery County Public Libraries](https://montgomerycountymd.gov) (2)
- [Open Fifth](https://openfifth.co.uk/) (23)
- [Prosentient Systems](https://www.prosentient.com.au) (7)
- Rijksmuseum, Netherlands (9)
- [Solutions inLibro inc](https://inlibro.com) (5)
- [Theke Solutions](https://theke.io) (12)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Pedro Amorim (1)
- Andrew (1)
- Tomás Cohen Arazi (7)
- Andrew Auld (1)
- Emmanuel Bétemps (2)
- Nick Clemens (9)
- David Cook (9)
- Paul Derscheid (67)
- Trevor Diamond (1)
- Roman Dolny (16)
- Jonathan Druart (9)
- Marion Durand (1)
- Magnus Enger (6)
- Laura Escamilla (1)
- Katrin Fischer (83)
- David Flater (4)
- Eric Garcia (2)
- Lucas Gass (61)
- Andrew Fuerste Henry (3)
- Janne (1)
- Barbara Johnson (1)
- Ludovic Julien (1)
- Thibault Keromnes (1)
- Thomas Klausner (1)
- krimsonkharne (1)
- Kristi Krueger (2)
- Emily Lamancusa (4)
- Brendan Lawlor (8)
- Christine Lee (1)
- Owen Leonard (16)
- CJ Lynce (2)
- Miranda Nero (1)
- David Nind (26)
- Lawrence ORegan-Lloyd (1)
- Eric Phetteplace (2)
- Martin Renvoize (28)
- Phil Ringnalda (3)
- Marcel de Rooy (43)
- Lisette Scheer (3)
- Fridolin Somers (141)
- Tadeusz „tadzik” Sośnierz (2)
- Emmi Takkinen (1)
- Noah Tremblay (3)
- Baptiste Wojtkowski (6)
- Anneli Österman (1)
</div>





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

Autogenerated release notes updated last on 28 Oct 2025 15:09:18.
