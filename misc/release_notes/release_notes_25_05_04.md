# RELEASE NOTES FOR KOHA 25.05.04
25 Sep 2025

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 25.05.04 can be downloaded from:

- [Download](https://download.koha-community.org/koha-25.05.04.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 25.05.04 is a bugfix/maintenance release.

It includes 37 enhancements, 88 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [40748](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40748) Remote-Code-Execution (RCE) in update_social_data.pl
- [40766](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40766) Reflected XSS in set-library.pl

## Bugfixes

### About

#### Other bugs fixed

- [40468](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40468) Terminology on the About > Licenses page - use US American spelling for license
  >This fixes the Koha about > Licenses page to use the US American spelling for license (instead of licence, which is the British English spelling).
- [40692](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40692) Wrong color background in Perl modules page

### Accessibility

#### Other bugs fixed

- [40609](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40609) Invisible Button Styling in "hint" Container Until Hovered

### Acquisitions

#### Critical bugs fixed

- [40684](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40684) Permission error for vendors if user has not full acquisition module permission
- [40870](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40870) Fund code is lost when modifying an order in acquisitions

#### Other bugs fixed

- [36155](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36155) Improve performance of suggestion.pl when there are many budgets
- [39980](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39980) Vendors pages are broken when using Koha as a Mojolicious application
  >This fixes vendor pages when running Koha as a Mojolicious application. You couldn't search for or create vendors (you get a page not found error). (This is related to bug 38010 - Migrate vendors to Vue, added to Koha 25.05.)
- [40146](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40146) Untranslatable actions on vendor

  **Sponsored by** *Athens County Public Libraries*
- [40483](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40483) Searching vendors by Alias no longer works
- [40861](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40861) "Odd number of elements in anonymous hash" warning in serials/acqui-search-result.pl

### Architecture, internals, and plumbing

#### Critical bugs fixed

- [40608](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40608) Password not changed if PASSWORD_CHANGE letter absent
- [40671](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40671) Expand Koha::Hold->revert_waiting to handle all found statuses

#### Other bugs fixed

- [35467](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35467) NewsLog should be renamed
- [40150](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40150) Prevent uncaught error on multiple attempts to 'define' on 'CustomElementsRegistry' in islands.ts
- [40405](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40405) systempreferences.value cannot be set to NULL
- [40585](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40585) Prevent crash on biblionumber in addbybiblionumber.pl
- [40636](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40636) C4::Reserves::CancelExpiredReserves behavior depends on date it is run
- [40641](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40641) Patron.pm can create warnings
- [40725](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40725) DBRev 23.12.00.053 should be made more resilient
- [40773](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40773) Improve build of "vue/dist" files
- [40838](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40838) Bookings related built CSS not ignored by Git

### Cataloging

#### Other bugs fixed

- [31460](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31460) Merging biblio records with attached item groups losing groups
- [38967](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38967) Export to CSV or Barcode file from item search results fail when "select visible rows" and many items are selected
- [40497](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40497) Item add form does not respect framework maxlength setting

  **Sponsored by** *Athens County Public Libraries*

### Circulation

#### Critical bugs fixed

- [40739](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40739) Setting TransfersBlockCirc to 'Don't block' does not allow for scanning to continue
  >This patch fixes a bug where setting TransfersBlockCirc to 'Don't block' did not allow scanning to continue after the modal pop-up was displayed.

#### Other bugs fixed

- [40643](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40643) circulation.tt attaches event listeners to keypress in a problematic way
- [40644](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40644) Bookings biblio checks erroneously if multiple check-outs and bookings exist
- [40678](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40678) Choices are not remembered if a wrong transfer modal is generated
  >This patchset fixes a bug where the "Drop box mode" and "Forgive overdue charges" checkbox values were not retained when a wrong transfer modal is displayed.
- [40679](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40679) Existing holds toolbar goes wonky if you select 'del' from priority dropdown
  >Fixes a problem in the UI that would make the toolbar look wrong when 'del' is selected in the priority dropdown on reserve/request.tt
- [40689](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40689) "Lost status" and "Damaged status" don't appear on moredetail.pl if user can't update them
- [40690](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40690) Checkout status doesn't appear on moredetail.pl if item is not checked out
- [40708](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40708) Increase accuracy and accessibility of checkin errors
- [40709](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40709) Status filter will display in wrong column if item-level_itypes is set to bibliographic record

### Database

#### Other bugs fixed

- [38906](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38906) REGEXP_REPLACE not in MySQL < 5.7b DB update 24.06.00.064 fails

### ERM

#### Critical bugs fixed

- [40774](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40774) EBSCO Packages search box is missing

### Hold requests

#### Critical bugs fixed

- [40755](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40755) Hold cancellation requests cause error 500 on holds waiting page

#### Other bugs fixed

- [40331](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40331) Extra transfer generated when transfer for hold cancelled due to checkin at incorrect library
- [40515](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40515) Mark as lost and notify patron is broken in pendingreserves.pl
- [40586](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40586) opac-user, holds-table.inc: Include on order status when item.notforloan < 0
- [40672](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40672) `desk_id` not cleared when `revert_found()` called
- [40747](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40747) Placeholder text in the filter row for Publication Details on the holds queue is incorrect

### Holidays

#### Other bugs fixed

- [38633](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38633) Calendar - Weekly closures are ignored when setting a yearly repeating holiday

### I18N/L10N

#### Other bugs fixed

- [33856](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33856) Inventory tool CSV export contains untranslatable strings
- [37926](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37926) Bookings - "to" untranslatable

  **Sponsored by** *Athens County Public Libraries*
- [40510](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40510) Add context to the word "More" in several templates

  **Sponsored by** *Athens County Public Libraries*

### Installation and upgrade (web-based installer)

#### Other bugs fixed

- [40557](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40557) Onboarding enrollment period fields styled badly
  >This fixes the 'Create a patron category' page in the web installer. It tidies up the layout for the enrolment period - the 'In months' and 'Until date' fields were further down the page, instead of aligned to the right of enrolment period label.

  **Sponsored by** *Athens County Public Libraries*

### MARC Bibliographic data support

#### Other bugs fixed

- [40618](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40618) The display of the field 255 (Cartographic Mathematical Data) is missing (both in intranet and OPAC)

  **Sponsored by** *Ignatianum University in Cracow*

### Notices

#### Other bugs fixed

- [40305](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40305) Collected and change variables are inconsistent in controllers and notice templates
  >This standardizes the terminology used throughout the payment system to consistently use 'tendered' instead of the mixed usage of 'collected' and 'tendered' that has caused confusion over the years. 
  >
  >It changes the variable names used in the code, HTML forms, and notices for the point of sale module and patron accounting - there is no change to the terms staff see on the pages in the staff interfaces.
  >
  >Note: It changes the variable names used in the RECEIPT and ACCOUNT_CREDIT notices. If you have not made any change to the default notices, they will automatically be updated. If you have customized these notices, you will need to manually update them.

### OPAC

#### Other bugs fixed

- [38455](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38455) UNIMARC XSLT Music incipit (036) try to display field 031 (as in MARC21)
- [40523](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40523) Remove unused export_buttons variable from koha-tmpl/opac-tmpl/bootstrap/js/datatables.js
- [40602](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40602) Broken HTML showing in Alert 'subscriptions' tab

  **Sponsored by** *Athens County Public Libraries*
- [40612](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40612) Eliminate duplicate element id in OPAC language menus

  **Sponsored by** *Athens County Public Libraries*
- [40614](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40614) Invalid markup in cookie consent modal

  **Sponsored by** *Athens County Public Libraries*
- [40759](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40759) Wrong date format in subscription brief history in OPAC
- [40780](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40780) Removing rows on advanced search should not lose focus
- [40782](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40782) Selections toolbar buttons should not be focusable when they are inactive
- [40803](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40803) Users cannot renew overdue items from 'Overdue' tab in account

### Patrons

#### Other bugs fixed

- [36278](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36278) Relabel "Gone no address"
- [40566](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40566) "Home library" empty on "Recalls history"
  >This fixes the recalls history page for a patron - the patron's home library is now shown in the patron information section in the staff interface (previously, "Home library:" was shown without the patron's actual home library showing).
- [40807](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40807) Quick add form does not include 'username' when it is included in BorrowerMandatoryFields

### Plugin architecture

#### Other bugs fixed

- [40812](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40812) Move Theke sample plugin repo to Github

### REST API

#### Other bugs fixed

- [36536](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36536) Make REST API's validateUserAndPassword update borrowers.lastseen
  >This patch add the option in the 'TrackLastPatronActivityTriggers' system preference to update a patron's 'Lastseen' entry when that patron's username and password are successfully validated via the REST API's /auth/password/validation endpoint.

  **Sponsored by** *Westlake Porter Public Library*
- [40543](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40543) pickup_library.branchname embed wrong

### Reports

#### Critical bugs fixed

- [40819](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40819) Guided reports select column should not be initialized as select2

### SIP2

#### Other bugs fixed

- [39820](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39820) Items with hold cancellation requests should have the hold cancelled when checked in via SIP
  >This fixes checking in items using SIP, and there is a hold cancellation request - the hold is now cancelled.
  >
  >Before this, it did not cancel the hold and it was still listed under "Holds with cancellation requests" (Circulation > Holds > Holds awaiting pickup).
- [40675](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40675) Carriage return in patron note message breaks SIP

### Searching

#### Other bugs fixed

- [39072](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39072) Item search shareable link adding selections for similar LOC auth values

### Self checkout

#### Other bugs fixed

- [40763](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40763) SCO alert box for for wrong password used alert-info when it should use alert-warning

### Staff interface

#### Critical bugs fixed

- [39930](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39930) Saved configuration states on tables are lost overnight
- [40753](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40753) DT's SaveState not working on the orders table
  >This fixes the basket order table so that when you close (or reopen) a basket, the columns shown remain the same as the table configuration. Before this fix, if you closed a basket and then reopened it, the table settings columns hidden by default were ignored and all the possible columns were shown.

#### Other bugs fixed

- [40040](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40040) RTL CSS files not loaded in templates; legacy right-to-left.css causing UI issues
- [40565](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40565) Column filters on the item search do not work
  >This patch fixes a problem that made the column search filters not to work when doing an item search.
- [40645](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40645) When adding to a list the 'list name' field is cut off
- [40651](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40651) Item search custom field selection is not populated in shareable link
- [40734](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40734) Libraries additional fields don't appear when creating a new library
- [40876](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40876) DT - Exact search not applied on second attribute for column filters

### Templates

#### Other bugs fixed

- [40591](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40591) Typo in fastadd button class
- [40592](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40592) Fix incorrect row highlighting on patron checkout history page

  **Sponsored by** *Athens County Public Libraries*
- [40600](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40600) Typo in ILL requests template: "Complete request request"

  **Sponsored by** *Athens County Public Libraries*

### Test Suite

#### Critical bugs fixed

- [40765](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40765) Acquisition tests will fail if order.quantity is set to 0

#### Other bugs fixed

- [40315](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40315) xt/tt_tidy.t generates warnings
- [40858](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40858) t/00-merge-conflict-markers.t should only test files part of git repo

### Tools

#### Other bugs fixed

- [39423](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39423) Column checkboxes on item batch modification hide incorrect columns
- [40691](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40691) CCODE label not includes in case of 'wrong place' problem (and maybe others cases) into inventory.pl

  **Sponsored by** *BibLibre*
- [40702](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40702) Inventory CSV export missing "title" header

### Web services

#### Other bugs fixed

- [36561](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36561) Inappropriate permission for "/api/v1/auth/password/validation"
  >This change adds a new borrower subpermission "api_validate_password" with the description "Validate patron passwords using the API". This permission allows API borrower accounts, especially for third-parties, the ability to authenticate users without needing full create-read-update-delete (CRUD) permissions.

## Enhancements 

### Accessibility

#### Enhancements

- [38642](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38642) DataTables expand button has no label

  **Sponsored by** *Athens County Public Libraries*

### Acquisitions

#### Enhancements

- [38619](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38619) UNIMARC prices should also be extracted from 071d
  >This enhancement imports the value in 071$d to the price field when adding an item to a basket using the "From a new file" option. Before this, it only imported the value from 010$d and 345$d.

### Architecture, internals, and plumbing

#### Enhancements

- [40058](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40058) Move RevertWaitingStatus to Koha::Hold->revert_waiting()
- [40275](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40275) Add Koha::Patrons->find_by_identifier()

### Cataloging

#### Enhancements

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
- [40839](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40839) Advanced cataloging editor z39.50 search should include Keyword in Advanced Search options
  >This patch makes keyword searching available when performing a z39.50 search via the advanced search modal in the advanced cataloging editor.

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
- [23010](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23010) If an item is checked out or in transit it should not be able to be marked withdrawn
  >This enhancement adds a new system preference, PreventWithDrawingItemsStatus. When the system preference is enabled it will prevent items that are in-transit or checked out from being withdrawn.
  >
  >** Sponsored by Cuyahoga County Public Library **
- [36455](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36455) Default the hold queue link to your logged in library
  >This enhancement defaults the holds queue link on the Circulation home page (and corresponding navigation links) to the currently logged in branch. This reduces the number of clicks to run the holds queue for the typical library without adding any additional clicks should the queue need generated for an alternate branch or all branches.
- [36789](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36789) Transform a booking into checkout

  **Sponsored by** *Association de Gestion des Œuvres Sociales d'Inria (AGOS)* and *LMS Cloud*
- [40656](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40656) bookings/list.tt needs to be refactored

### Developer documentation

#### Enhancements

- [38997](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38997) Remove reference to "members" in SendAlerts

### ERM

#### Enhancements

- [39345](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39345) Koha must support COUNTER 5.1
  >This enhancement adds support to the ERM module for Release 5.1 of the Code of Practice for COUNTER Metrics that came into force in January 2025, with a requirement for reports to be delivered by the 28th of February 2025.

### Hold requests

#### Enhancements

- [37651](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37651) biblio->current_holds and item->current_holds do not respect ConfirmFutureHolds
- [40395](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40395) Allow selecting multiple holds in patron detail page to perform actions on
  >This enhancement adds a 'checkbox' column to the patron holds table located on the 'Holds' tab on the patron 'Details' page and the patron 'Check out' page.
  >It also reimplements suspending and cancelling multiple holds on these pages from a UI/UX point of view.
  >Before, the user was required to check the box under the 'Delete?' column for the respective hold and then click a 'Cancel marked holds' button alongside a cancellation reason.
  >Now, the user selects the holds they want to cancel and click a new 'Cancel selected holds' button. This reworked button now shows the hold cancellation modal, becoming more consistent to what happens when cancelling holds in other pages where this action is also possible.
  >Suspending multiple holds has received the same treatment, with the additional benefit that is now possible to suspend a set of selected holds, rather than only being able to suspend either a single or all holds.
  >This work also serves as preparation for future holds 'bulk actions' on these patron pages, now that selecting multiple holds on these pages has been standardized.

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
- [40482](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40482) bookcover/bookcoverimg class in search results show include more data-attributes for customization
  >This enhancement adds data-attributes to the bookcover class in the OPAC and staff interface search results. This will make it easier to customization based on those attributes.

### Notices

#### Enhancements

- [36114](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36114) Port default TRANSFERSLIP notice to Template Toolkit syntax
- [39883](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39883) NEW_SUGGESTION email notices end up in the patrons notice tab (members/notices.pl) when they should not
  >The patch makes it so NEW_SUGGESTION email notices do not show up in a patron's notice history.

### Patrons

#### Enhancements

- [22632](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22632) Add logging of merged patrons
  >This enhancement adds details of patron merges to the log viewer (when BorrowersLog is enabled).
- [40251](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40251) Icon for self-check user permission

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
- [40653](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40653) plugins/run.pl controller drops authentication if logging in to that route

### REST API

#### Enhancements

- [39900](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39900) Add public REST endpoint for additional_contents

### Reports

#### Enhancements

- [40425](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40425) Guided report - "Next" button on last step is misleading
  >This enhancement to quided reports renames the label for the last step from "Next" to "Save" - this reflects the actual behavour.

### Searching

#### Enhancements

- [33646](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33646) "Cataloging search" missing important data for not for loan items

### Serials

#### Enhancements

- [37116](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37116) Add the option to edit linked serials when editing items

### Staff interface

#### Enhancements

- [27934](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27934) Table sorting using title-string option is obsolete
- [37883](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37883) Add a filter for staff search results to filter by library
  >This enhancement adds the system preference  FilterSearchResultsByLoggedInBranch. When turned on this feature will allow librarians to filter search results to only show those belonging to the logged in branch. This selection will be set in the browser's localStorage.

### System Administration

#### Enhancements

- [39824](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39824) Add a direct link to default framework in MARC bibliographic frameworks page
  >This patch adds a direct link to default framework from the MARC bibliographic frameworks page.

### Templates

#### Enhancements

- [36095](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36095) Improve translation of title tags: OPAC part 2

  **Sponsored by** *Athens County Public Libraries*
- [38877](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38877) Improve translation of title tags: OPAC part 3

  **Sponsored by** *Athens County Public Libraries*
- [40606](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40606) Remove italics from shelving location in the staff interface
  >This enhancement removes the italics formatting from the shelving location in a record's holdings table, now that it is in its own column. (The formatting was there to differentiate the shelving location from the library name when they were in the same column. This is not necessary anymore.) 
  >
  >(This is a follow-up to Bug 15461 - Add shelving location to holdings table as a separate column, added in Koha 25.04.)

### Test Suite

#### Enhancements

- [40444](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40444) Add a test to ensure all Perl test files use Test::NoWarnings

### Tools

#### Enhancements

- [34561](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34561) Move IntranetReportsHomeHTML to HTML customizations
  >This enhancement moves the IntranetReportsHomeHTML system preference into HTML customizations. This makes it possible to have language-specific and library-specific content. The option has been renamed StaffReportsHome for better consistency with other HTML customization regions.

  **Sponsored by** *Athens County Public Libraries*

## New system preferences

- AdditionalContentLog
- FilterSearchResultsByLoggedInBranch
- PreventWithdrawingItemsStatus

## Deleted system preferences

- IntranetReportsHomeHTML
- NewsLog

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [English (USA)](https://koha-community.org/manual/25.05/en/html/)
- [French](https://koha-community.org/manual/25.05/fr/html/) (75%)
- [German](https://koha-community.org/manual/25.05/de/html/) (95%)
- [Greek](https://koha-community.org/manual/25.05/el/html/) (95%)
- [Hindi](https://koha-community.org/manual/25.05/hi/html/) (67%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<!-- <div style="column-count: 2;"> -->

- Arabic (ar_ARAB) (92%)
- Armenian (hy_ARMN) (99%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified Han script) (83%)
- Chinese (Traditional Han script) (97%)
- Czech (66%)
- Dutch (85%)
- English (100%)
- English (New Zealand) (61%)
- English (USA)
- Finnish (99%)
- French (99%)
- French (Canada) (97%)
- German (99%)
- Greek (65%)
- Hindi (95%)
- Italian (80%)
- Norwegian Bokmål (71%)
- Persian (fa_ARAB) (93%)
- Polish (99%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (86%)
- Russian (92%)
- Slovak (58%)
- Spanish (98%)
- Swedish (86%)
- Telugu (65%)
- Tetum (51%)
- Turkish (81%)
- Ukrainian (71%)
- Western Armenian (hyw_ARMN) (60%)
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

The release team for Koha 25.05.04 is


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
new features in Koha 25.05.04
<!-- <div style="column-count: 2;"> -->

- Association de Gestion des Œuvres Sociales d'Inria (AGOS)
- Athens County Public Libraries
- [BibLibre](https://www.biblibre.com)
- [Cape Libraries Automated Materials Sharing](https://info.clamsnet.org)
- Ignatianum University in Cracow
- [Koha-Suomi Oy](https://koha-suomi.fi)
- [LMS Cloud](https://www.lmscloud.de)
- [OpenFifth](https://openfifth.co.uk)
- [Solutions inLibro inc.](https://inlibro.com)
- [Westlake Porter Public Library](https://westlakelibrary.org)
<!-- </div> -->

We thank the following individuals who contributed patches to Koha 25.05.04
<!-- <div style="column-count: 2;"> -->

- Axel Amghar (3)
- Pedro Amorim (31)
- Tomás Cohen Arazi (26)
- Alexander Blanchard (1)
- Matt Blenkinsop (2)
- Courtney Brown (1)
- Nick Clemens (11)
- David Cook (11)
- Jake Deery (3)
- Paul Derscheid (28)
- Jonathan Druart (35)
- Marion Durand (1)
- Laura Escamilla (2)
- David Flater (1)
- Emily-Rose Francoeur (2)
- Andrew Fuerste-Henry (7)
- Matthias Le Gac (2)
- Lucas Gass (49)
- Thibaud Guillot (3)
- Janusz Kaczmarek (1)
- Emily Lamancusa (3)
- Brendan Lawlor (3)
- Owen Leonard (18)
- CJ Lynce (1)
- Julian Maurice (3)
- David Nind (1)
- Karam Qubsi (1)
- Martin Renvoize (17)
- Jason Robb (3)
- Adolfo Rodríguez (1)
- Marcel de Rooy (14)
- Caroline Cyr La Rose (5)
- Bernard Scaife (1)
- Lisette Scheer (1)
- Fridolin Somers (3)
- Hammat Wele (3)
- Baptiste Wojtkowski (2)
- Chloe Zermatten (1)
<!-- </div> -->

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 25.05.04
<!-- <div style="column-count: 2;"> -->

- Athens County Public Libraries (18)
- [BibLibre](https://www.biblibre.com) (12)
- [ByWater Solutions](https://bywatersolutions.com) (70)
- [Cape Libraries Automated Materials Sharing](https://info.clamsnet.org) (3)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha) (1)
- David Nind (1)
- Independant Individuals (6)
- Koha Community Developers (35)
- [LMSCloud](https://www.lmscloud.de) (28)
- [Montgomery County Public Libraries](https://montgomerycountymd.gov) (3)
- [Open Fifth](https://openfifth.co.uk/) (56)
- [Prosentient Systems](https://www.prosentient.com.au) (11)
- Rijksmuseum, Netherlands (14)
- sekls.org (3)
- [Solutions inLibro inc](https://inlibro.com) (12)
- [Theke Solutions](https://theke.io) (26)
- westlakelibrary.org (1)
- [Xercode](https://xebook.es) (1)
<!-- </div> -->

We also especially thank the following individuals who tested patches
for Koha
<!-- <div style="column-count: 2;"> -->

- Pedro Amorim (16)
- Tomás Cohen Arazi (7)
- Wendy Bartlett (1)
- Matt Blenkinsop (2)
- Emmanuel Bétemps (2)
- Nick Clemens (25)
- David Cook (14)
- Jake Deery (2)
- Ray Delahunty (1)
- Paul Derscheid (289)
- Trevor Diamond (1)
- Roman Dolny (9)
- Jonathan Druart (26)
- Marion Durand (3)
- Laura Escamilla (13)
- Katrin Fischer (2)
- David Flater (4)
- Andrew Fuerste-Henry (12)
- Eric Garcia (4)
- Lucas Gass (232)
- Amaury GAU (5)
- Kyle M Hall (5)
- Tomas Jiglind (1)
- Ludovic Julien (2)
- krimsonkharne (1)
- Marie-Luce Laflamme (1)
- Emily Lamancusa (17)
- Brendan Lawlor (10)
- Christine Lee (1)
- Owen Leonard (17)
- Lin Wei Li (2)
- CJ Lynce (2)
- Nathalie (2)
- Christian Nelson (3)
- Miranda Nero (1)
- David Nind (38)
- Lawrence ORegan-Lloyd (1)
- Eric Phetteplace (7)
- Martin Renvoize (31)
- Jason Robb (7)
- Marcel de Rooy (60)
- Caroline Cyr La Rose (1)
- Bernard Scaife (1)
- Lisette Scheer (3)
- Emmi Takkinen (2)
- Noah Tremblay (5)
- Olivier Vezina (2)
- Hammat Wele (4)
- Anneli Österman (1)
<!-- </div> -->





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 25.05.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 25 Sep 2025 18:51:29.
