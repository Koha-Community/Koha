# RELEASE NOTES FOR KOHA 25.05.03
26 Aug 2025

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 25.05.03 can be downloaded from:

- [Download](https://download.koha-community.org/koha-25.05.03.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 25.05.03 is a bugfix/maintenance and security release.

It includes 40 enhancements, 57 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [39906](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39906) Add bot challenge (in Apache layer)
- [40538](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40538) XSS in hold suspend modal in staff interface
  >Fixes XSS vulnerability in suspend hold modal and suspend hold button by refactoring the Javascript that creates the HTML.
- [40579](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40579) CSV formula injection protection

## Bugfixes

### About

#### Other bugs fixed

- [32244](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32244) Add Vue and Cypress to the About Koha > Licenses page
  >This adds Cypress and Vue to the About Koha > Licenses page.
- [40466](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40466) Zebra status misleading in "Server information" tab.

### Accessibility

#### Other bugs fixed

- [29069](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29069) Accessibility: "Refine your search" link doesn't have sufficient contrast
- [39489](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39489) 'Refine your search' should have an aria-expanded attribute
  >This fixes the "Refine your search" section in the OPAC. For screen reader users on smaller screens, it now correctly announces that it is an expandable section, instead of a link (by adding an aria-expanded attribute).
  >
  >Explanation: The 'Refine your search' expandable section in the Koha OPAC was not clearly announced by screen readers for smaller screen sizes. This is because the expandable section was identified and announced as a link. This resulted in screen reader users incorrectly expecting a link to another page, and not being informed that it was an expandable section.

  **Sponsored by** *British Museum*
- [39502](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39502) Web Usability Accessibility Audit - Decorative Images Don't Need alt Text
- [39998](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39998) Missing presentation role on layout tables.

### Acquisitions

#### Other bugs fixed

- [40106](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40106) Language selector not displayed on some acquisition views (vue)
- [40318](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40318) "Receive shipments" should not open in a new tab/window - vendor list view
  >This fixes the "Receive shipments" action from the table listing vendors in acquisitions - it now opens the receive shipment form in the same window, instead of opening in a new tab or window.

### Architecture, internals, and plumbing

#### Other bugs fixed

- [40132](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40132) Remove some POD from Koha/Template/Plugin/AdditionalContents.pm
- [40516](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40516) Boolean filters are broken on datatables
- [40535](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40535) Branches.tt view page has out of place "Category:" field
  >This removes a category field that was mistakenly added to the library's detail page (Koha administration > Basic parameters > Libraries > view any library).

### Cataloging

#### Critical bugs fixed

- [40544](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40544) Manage bundle button broken

#### Other bugs fixed

- [40156](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40156) Advanced editor should not create empty fields and subfields

  **Sponsored by** *Ignatianum University in Cracow*

### Circulation

#### Critical bugs fixed

- [40296](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40296) Bookings that are checked out do not have status updated to completed

#### Other bugs fixed

- [39180](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39180) Handle and report exception at checkout/checkin due to missing guarantor
  >This fixes checking out, checking in, and renewing items for a patron where a guarantor is required, and they don't have one (where the ChildNeedsGuarantor system preference is enabled).
  >
  >These actions are now completed correctly, and a warning message is now shown on the patron's page where a guarantor is required and they don't have one: "System preference 'ChildNeedsGuarantor' is enabled and this patron does not have a guarantor.".
  >
  >Previously:
  >- checking items in or out generated a 500 error message, even though the actions were successfully completed
  >- attempting to renew items generated this message "Error: Internal Server Error" and the items were not renewed
  >- no message was shown on the patron page warning that they needed a guarantor

### ERM

#### Critical bugs fixed

- [40198](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40198) Datatables search for data providers is broken

### Hold requests

#### Critical bugs fixed

- [40620](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40620) Holds Queue will assign to the lowest item number if multiple branches have the same transport cost
- [40654](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40654) Sorting holds table can cause priority issues
  >This patchset fixes a problem where hold priority could be incorrectly updated depending on how the table is sorted on reserve/request.tt.

#### Other bugs fixed

- [38412](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38412) Koha should warn when hold on bibliographic record requires hold policy override

  **Sponsored by** *BibLibre* and *Westlake Porter Public Library*
- [40530](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40530) Show hold cancellation reason in patron holds history
  >This fixes the status message when a hold is cancelled on the patron's holds history page in the staff interface. It displayed "Cancelled(FIXME)", instead of the actual reason. (This is related to bug 35560 - Use the REST API for holds history, added in Koha 25.05.00 and 24.11.05.)

### Lists

#### Other bugs fixed

- [39427](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39427) Searching lists table by owner can only enter firstname or surname
- [40488](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40488) "Public lists" breadcrumb link doesn't work when editing public list in staff interface
  >Fixes breadcrumb link when editing public lists in staff interface.

  **Sponsored by** *Athens County Public Libraries*

### Notices

#### Other bugs fixed

- [39279](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39279) Terminology:  Please return or renew them at the branch below as soon as possible.
  >This fixes the terminology used in the overdue notice (ODUE) to change 'branch' to 'library': "Please return or renew your overdue items at the library as soon as possible.".
  >
  >Note: The notice is not automatically updated for existing installations. Update the notice manually to change the wording if required, or replace the default notice using "View default" and "Copy to template" if you have not customized the notice.

### OPAC

#### Other bugs fixed

- [40540](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40540) OPAC generates warnings in logs when no results are found

  **Sponsored by** *Ignatianum University in Cracow*
- [40590](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40590) OPACAuthorIdentifiersAndInformation shows empty list elements for unknown 024$2

  **Sponsored by** *Athens County Public Libraries*

### Patrons

#### Other bugs fixed

- [40321](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40321) DataTables search ( dt-search ) does not work on holds history page
- [40459](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40459) Preferred name is lost when editing partial record
- [40469](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40469) Reword anonymous_refund permission description

### REST API

#### Other bugs fixed

- [40433](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40433) Missing maxLength in item, patron and library

### Reports

#### Other bugs fixed

- [39066](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39066) Fix "To screen into the browser"
  >This fixes the terminology used for showing the output for standard reports in the browser. It changes "To screen into the browser" to "To screen in the browser" ("into" changed to "to").

### SIP2

#### Other bugs fixed

- [40270](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40270) Remove useless warnings on failed SIP2 login

### Searching

#### Other bugs fixed

- [39896](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39896) System preference AuthorLinkSortBy is not working for UNIMARC or custom XSLT
  >This fixes the default UNIMARC XSLT files so that the AuthorLinkSortBy and AuthorLinkSortOrder system preferences now work with UNIMARC, not just MARC21. 
  >
  >A note was also added to the system preference for those that use custom XSLT (for OPACXSLTDetailsDisplay, OPACXSLTResultsDisplay, XSLTDetailsDisplay, and XSLTResultsDisplay) - they need to update their templates to support these features for both MARC21 and UNIMARC.
  >
  >(These preferences were added in Koha 23.11 by Bug 33217 - Allow different default sorting when click author links, but only the default XSLT files for MARC21 were updated.)

### Self checkout

#### Other bugs fixed

- [40004](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40004) Standardize spelling of "Self Checkout" to "Self-checkout" with hyphen in UI

### Staff interface

#### Other bugs fixed

- [39712](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39712) Query parameters break the manual mappings in vue modules
- [40081](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40081) textareas appear to now be fixed width
  >This fixes OPAC and staff interface forms with text area fields. You can now adjust the size both vertically and horizontally - after the Bootstrap 5 upgrade you could only adjust the size vertically. (This is related to the OPAC and staff interface Bootstrap 5 upgrade in Koha 24.11.)

  **Sponsored by** *Athens County Public Libraries*
- [40121](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40121) library and category not selected on the patron search
- [40298](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40298) A select2 in a bootstrap modal, like in the patron card batch patron search modal, needs it's parent defined
- [40560](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40560) Incorrect breadcrumb on recall history

  **Sponsored by** *Athens County Public Libraries*
- [40647](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40647) "dictionary" misspelled in rep_dictonary class
  >This fixes a spelling error in the class name on the reports home page in the staff interface: "rep_dictonary" to "rep_dictionary".

### System Administration

#### Other bugs fixed

- [40114](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40114) Can't select new library when editing a desk
  >This patch fixes a problem that made it impossible to select a new library/branch when editing a desk from Administration -> Desks.

  **Sponsored by** *Athens County Public Libraries*
- [40547](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40547) Unable to view background job if enable_plugins is 0

### Templates

#### Other bugs fixed

- [40222](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40222) Bootstrap popover components not updated for BS5

  **Sponsored by** *Athens County Public Libraries*
- [40413](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40413) Patron list input missing "Required" label

  **Sponsored by** *Athens County Public Libraries*
- [40451](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40451) Link patron restriction types to correct section in manual

  **Sponsored by** *Athens County Public Libraries*

### Test Suite

#### Critical bugs fixed

- [40430](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40430) Toolbar_spec.ts is failing

#### Other bugs fixed

- [40051](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40051) cy.wait(delay) should not be used in Cypress tests
- [40345](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40345) Missing Cypress tests for checkout history - OPAC
- [40371](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40371) t/db_dependent/Budgets.t generates warnings
- [40386](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40386) t/Edifact.t generates warnings
- [40387](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40387) t/db_dependent/Koha/EDI.t generates warnings
- [40490](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40490) Warnings from GD::Barcode::QRcode on U24
- [40493](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40493) t/cypress/plugins/dist/ must be git ignored
- [40539](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40539) Cypress videos and screenshots should be gitignored
- [40541](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40541) Add new line at the end of the files when missing

### Tools

#### Other bugs fixed

- [31930](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31930) Ignore whitespace before and after barcodes when adding items to rotating collections
  >This fixes adding or removing items to a rotating collection (Tools > Patrons and circulation > Rotating collections). If a barcode has a space before it, it is now ignored instead of generating an error message.
- [40549](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40549) Warnings generated when using Import Patrons tool

## Enhancements 

### About

#### Enhancements

- [34783](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34783) Update list of 'Contributing companies and institutions' on about page

### Accessibility

#### Enhancements

- [39982](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39982) Accessibility: The 'Browse results' menu does not have sufficient color contrast.
- [40097](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40097) Text elements on the OPAC user pages don’t have sufficient color contrast.

### Acquisitions

#### Enhancements

- [34127](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34127) Allow to customize CSV export of basketgroup and add a ODS export
  >It is now possible to export any basket to CSV, even the closed ones or those linked to a group.

### Architecture, internals, and plumbing

#### Enhancements

- [40037](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40037) Redundant check in `notices_content` hook handling

### Cataloging

#### Enhancements

- [37604](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37604) Give skip_open_orders checkbox an ID in batch record deletion template
  >This enhancement adds an ID to the "Skip bibliographic records with open acquisition orders" checkbox on the batch record deletion page (Cataloging > Batch editing > Batch record deletion").
  >
  >This is required so that when selecting or unselecting the checkbox, the focus remains on the checkbox. The ID semantically links the checkbox to its label so machines (screenreaders and computers) can tell they are related elements.

### Circulation

#### Enhancements

- [35669](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35669) Update check in message for a specific authorised value in the LOST authorised values
  >This enhancement displays the LOST authorized value description when checking an item in, instead of the generic "Item was lost, now found." message. For example, if the LOST value description is "Missing" it will now display as "Item was Missing, now found.".
- [39923](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39923) Add classes to email and phone in overdue report to allow for customization
  >This patches adds a overdue_email and overdue_phone to the overdue report making it easier to target the phone/email with CSS or JavaScript.

  **Sponsored by** *Athens County Public Libraries*

### Command-line Utilities

#### Enhancements

- [38404](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38404) Make clear in RestrictPatronsWithFailedNotices syspref description that restrict_patrons_with_failed_notices.pl cronjob has default days setting

### ILL

#### Enhancements

- [39773](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39773) OPAC ILL form does not use client-side form validation for required fields
- [39917](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39917) Display a prompt for status alias when completing a request if ILL_STATUS_ALIAS in use
  >This enhancement to ILL requests lets you select a 'status alias' when marking requests as complete. This is only shown when values are defined for the ILL_STATUS_ALIAS authorized values category. The alias is then shown in the status field on the request details page, and in the status column for the list of ILL requests. If there are no values defined, then you are not prompted to select a status alias.

  **Sponsored by** *NHS England (National Health Service England)*
- [40026](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40026) Edit item metadata should present Standard form if AutoILLBackendPriority is in use
- [40075](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40075) ILL Standard form should only show libraries that are pickup_locations

### Label/patron card printing

#### Enhancements

- [40414](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40414) Update patron card layout with expiry date

### MARC Authority data support

#### Enhancements

- [38514](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38514) Filter out autocomplete list of authorities with ConsiderHeadingUse
  >This patch updates the authority search in cataloging to exclude results from the autocomplete that would be excluded from the search based on ConsiderHeadingUse and MARC21 field 008/14-16 indication of what the heading can be used for (main/added entry, subject entry, series entry).

### MARC Bibliographic record staging/import

#### Enhancements

- [38661](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38661) Add warning when deleting import batch

### Notices

#### Enhancements

- [36127](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36127) Port default HOLDPLACED and HOLD_CHANGED notices to Template Toolkit syntax

### OPAC

#### Enhancements

- [40143](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40143) Add links to private lists in OPAC bibliographic record detail pages
  >This enhancement lets patron see links to their own private lists on OPAC bibliographic record detail pages. Previously, only public lists were shown.

### Patrons

#### Enhancements

- [40367](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40367) Improve display of messages on patron account
  >This adjusts the way patron messages are displayed on a patron account, grouping messages together and labeling them based on whether they are internal staff notes or OPAC messages.

### Plugin architecture

#### Enhancements

- [39632](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39632) Failed plugin install gives too little info

### REST API

#### Enhancements

- [39091](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39091) Cash registers should have a list API endpoint
- [40417](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40417) Search_rs is re-instating deleted query parameters
- [40423](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40423) Handling x-koha-request-id relies on wrong data structure
- [40424](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40424) Handling query-in-body relies on wrong data structure
- [40542](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40542) Add `cancellation_reason` to holds strings embed

### Serials

#### Enhancements

- [37115](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37115) Add the option to delete linked serials when deleting items

### System Administration

#### Enhancements

- [39897](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39897) Make EDI accounts a configurable DataTable
  >This enhancement converts the EDI accounts table from a standard table to a DataTable - so you can now sort, filter, configure the columns, export the data, and so on (Koha administration > Acquisition parameters > EDI accounts).

  **Sponsored by** *Athens County Public Libraries*
- [40343](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40343) Koha to MARC mapping should suggest to run batchRebuildItemsTables.pl
  >This enhancement updates the information message on the Koha to MARC mapping page to mention that batchRebuildItemsTables.pl should also be run if changes are made to mappings that affect the items table. It currently only mentions running misc/batchRebuildBiblioTables.pl

### Templates

#### Enhancements

- [39809](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39809) .required class was made too non-specific in Bootstrap upgrade
  >This patch corrects the styling of required fields so that the text entered in the input is no longer shown in red. Previously, the .required class was incorrectly applied to the input itself rather than just the label and required indicator.
- [39960](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39960) Improve messages in the OPAC ask for a discharge page (opac-discharge.tt)
  >This enhancement improves the messages in the OPAC on the ask for a discharge page (Your account > Ask for discharge, when the useDischarge system preference is enabled).
  >
  >Improvements:
  >- Improved wording for the number of items checked out: instead of "..2 item(s).." and "..1 item(s)..." the text changes based on the actual number of checkouts - "...2 items..." and "...an item...".
  >- More succinct text: for example, instead of "Please pay your charges before reapplying.", "Please pay them before reapplying."

### Test Suite

#### Enhancements

- [40173](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40173) Reuse http-client from Cypress tests - preparation steps
- [40174](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40174) Add a way to cleanly insert data in DB from Cypress tests
- [40180](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40180) Missing Cypress tests for 'Holds to pull' library filters
- [40181](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40181) Cypress tests - Ensure that insertData does not leave data in the DB
- [40301](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40301) Missing Cypress tests for 'Type' column visibility
- [40346](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40346) Allow Cypress to test OPAC
- [40447](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40447) Add documentation for cypress plugins

### Tools

#### Enhancements

- [40400](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40400) Rename club start and end date to make clearer these are for the enrollment period
  >This enhancement to patron clubs renames "Start date" and "End date" to "Enrollment start date" and "Enrollment end date", to better reflect what the dates represent.

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [English (USA)](https://koha-community.org/manual/25.05/en/html/)
- [French](https://koha-community.org/manual/25.05/fr/html/) (74%)
- [German](https://koha-community.org/manual/25.05/de/html/) (98%)
- [Greek](https://koha-community.org/manual/25.05/el/html/) (86%)
- [Hindi](https://koha-community.org/manual/25.05/hi/html/) (70%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (92%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified Han script) (84%)
- Chinese (Traditional Han script) (98%)
- Czech (65%)
- Dutch (86%)
- English (100%)
- English (New Zealand) (62%)
- English (USA)
- Finnish (99%)
- French (99%)
- French (Canada) (97%)
- German (99%)
- Greek (65%)
- Hindi (95%)
- Italian (80%)
- Norwegian Bokmål (71%)
- Persian (fa_ARAB) (94%)
- Polish (99%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (86%)
- Russian (92%)
- Slovak (59%)
- Spanish (98%)
- Swedish (87%)
- Telugu (66%)
- Tetum (51%)
- Turkish (81%)
- Ukrainian (71%)
- Western Armenian (hyw_ARMN) (60%)
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

The release team for Koha 25.05.03 is


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
new features in Koha 25.05.03
<div style="column-count: 2;">

- Athens County Public Libraries
- [BibLibre](https://www.biblibre.com)
- British Museum
- Ignatianum University in Cracow
- NHS England (National Health Service England)
- [Westlake Porter Public Library](https://westlakelibrary.org)
</div>

We thank the following individuals who contributed patches to Koha 25.05.03
<div style="column-count: 2;">

- Rachel A-M (1)
- Pedro Amorim (13)
- Tomás Cohen Arazi (17)
- Alexander Blanchard (1)
- Matt Blenkinsop (8)
- Courtney Brown (1)
- Nick Clemens (6)
- David Cook (3)
- Paul Derscheid (2)
- Jonathan Druart (51)
- Marion Durand (1)
- Laura Escamilla (2)
- Katrin Fischer (1)
- David Flater (1)
- Andrew Fuerste-Henry (3)
- Eric Garcia (1)
- Lucas Gass (5)
- Michael Hafen (1)
- Kyle M Hall (1)
- Janusz Kaczmarek (4)
- Emily Lamancusa (4)
- Brendan Lawlor (1)
- Owen Leonard (14)
- CJ Lynce (1)
- Nina Martinez (4)
- David Nind (3)
- Aman Pilgrim (2)
- katy rayn (1)
- Martin Renvoize (9)
- Marcel de Rooy (2)
- Caroline Cyr La Rose (1)
- sashaanastasi (1)
- Bernard Scaife (1)
- Lisette Scheer (1)
- Arthur Suzuki (1)
- Imani Thomas (1)
- Yvonne Waterman (1)
- Baptiste Wojtkowski (1)
- Chloe Zermatten (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 25.05.03
<div style="column-count: 2;">

- Athens County Public Libraries (14)
- [BibLibre](https://www.biblibre.com) (7)
- [Bibliotheksservice-Zentrum Baden-Württemberg (BSZ)](https://bsz-bw.de) (1)
- [ByWater Solutions](https://bywatersolutions.com) (21)
- [Cape Libraries Automated Materials Sharing](https://info.clamsnet.org) (1)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha) (3)
- ctalyst.net.nz (1)
- David Nind (3)
- Independant Individuals (10)
- Koha Community Developers (51)
- [LMSCloud](https://www.lmscloud.de) (2)
- [Montgomery County Public Libraries](https://montgomerycountymd.gov) (4)
- [Open Fifth](https://openfifth.co.uk/) (33)
- [Prosentient Systems](https://www.prosentient.com.au) (3)
- Rijksmuseum, Netherlands (2)
- [Solutions inLibro inc](https://inlibro.com) (1)
- [Theke Solutions](https://theke.io) (15)
- westlakelibrary.org (1)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Aleisha Amohia (1)
- Pedro Amorim (6)
- Tomás Cohen Arazi (5)
- Wojciech Baran (1)
- Matt Blenkinsop (15)
- Aude Charillon (5)
- Nick Clemens (21)
- David Cook (5)
- Paul Derscheid (174)
- Roman Dolny (7)
- Jonathan Druart (11)
- Marion Durand (1)
- Magnus Enger (1)
- Laura Escamilla (20)
- Katrin Fischer (2)
- David Flater (7)
- Brendan Gallagher (4)
- Eric Garcia (1)
- Lucas Gass (160)
- Kyle M Hall (2)
- Cornelius Hertfelder (1)
- Emily Lamancusa (10)
- Sam Lau (1)
- Brendan Lawlor (5)
- Owen Leonard (29)
- CJ Lynce (1)
- Michaela (2)
- Nathalie (3)
- David Nind (44)
- Boubacar OUATTARA (3)
- Martin Renvoize (39)
- Marcel de Rooy (14)
- Caroline Cyr La Rose (4)
- Lisette Scheer (7)
- Dominique et Stephanie (1)
- Baptiste Wojtkowski (4)
-  Anneli Österman (1)
</div>





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

Autogenerated release notes updated last on 26 Aug 2025 19:49:36.
