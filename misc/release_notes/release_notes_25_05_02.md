# RELEASE NOTES FOR KOHA 25.05.02
24 Jul 2025

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 25.05.02 can be downloaded from:

- [Download](https://download.koha-community.org/koha-25.05.02.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 25.05.02 is a bugfix/maintenance release.

It includes 25 enhancements, 96 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [40030](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40030) HTML should be escaped when viewing system preferences diff in Log viewer

## Bugfixes

### About

#### Critical bugs fixed

- [40370](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40370) about.pl should NOT say "Run the following SQL to fix the database"

#### Other bugs fixed

- [40022](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40022) Release team 25.11

### Accessibility

#### Other bugs fixed

- [40165](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40165) Incomplete logic for controlling display of OPAC language footer

  **Sponsored by** *Athens County Public Libraries*

### Acquisitions

#### Other bugs fixed

- [39572](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39572) Create EDIFACT order button no longer forces librarians to review EAN to select
  >This fixes the EDIFACT order confirmation message for a basket so that the EAN information is now included on the confirmation page ([a basket for a vendor] > Create EDIFACT order > [select EAN from dropdown list], with the BasketConfirmations system preference set to 'always ask for conformation').
  >
  >Previously, the `Create EDIFACT order` action would take librarians to a page to select the EDI Library EAN. Now, the EANs are included in a dropdown list for the action. This removed the chance to review the selected EAN to confirm it was correct. In addition, some libraries have dozens of Library EANs, making the button dropdown list cumbersome to use.

### Architecture, internals, and plumbing

#### Other bugs fixed

- [37305](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37305) Remove C4::Biblio::prepare_marc_host and use Koha::Biblio->generate_marc_host_field in preference
  >25.11.00

  **Sponsored by** *Open Fifth*
- [38966](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38966) Wrong POD in Koha/CoverImages.pm and Koha/Acquisition/Order/Claims.pm
- [40079](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40079) C4::Scrubber "note" profile should allow for list (ul, ol, li, dl, dt, and dd) HTML tags
  >This adds unordered, ordered, and description list tags (<ul>, <ol>, <li>, <dl>, <dt>, and <dd>) to the HTML that is allowed in notes fields (for example, course reserves staff and public notes).
- [40242](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40242) Typo in Quotes module
  >This fixes a typo in the code for the quote of the day tool (there were two =>).
- [40261](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40261) Tidy `build-git-snapshot`
- [40277](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40277) Warn in C4::Koha::GetAuthorisedValues()
  >This fixes the cause of an unnecessary warning message[1] in the logs when searching the OPAC when not logged in. (This warning was occurring when the OpacAdvancedSearchTypes system preference was set to something other than "itemtypes", for example "loc".)
  >
  >[1] Warning message:
  >[WARN] Use of uninitialized value $branch_limit in concatenation (.) or string at ...

### Authentication

#### Other bugs fixed

- [39206](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39206) Koha improperly tries to remove foreign cookies on logout (and in general the cookies aren't actually removed, but set to empty values)
  >This patch adds more control to Koha::CookieManager by allowing to refine its list of managed cookies with keep or remove entries in koha-conf.xml.
  >
  >IMPORTANT NOTE: The former (probably widely unused) feature of putting a regex in the do_not_remove_cookie lines is replaced by interpreting its value as a prefix. (So you should e.g. replace catalogue_editor_\d+ by just catalogue_editor_

### Cataloging

#### Other bugs fixed

- [39871](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39871) Cannot clear item statuses with batch item modification tool
- [40128](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40128) StripWhitespaceChars can create empty subfields

### Circulation

#### Other bugs fixed

- [40107](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40107) Article requests: some DataTables functionality is broken
  >This fixes JavaScript errors in the staff interface article requests table. The tables weren't refreshing, and the tab numbers weren't updating, when selecting an action for individual or multiple requests (such as 'Set request as pending').

  **Sponsored by** *Athens County Public Libraries*

### Command-line Utilities

#### Other bugs fixed

- [23883](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23883) sip_cli_emulator.pl - typo in parameter name
- [40144](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40144) `sip_cli_emulator.pl` warnings

### Database

#### Other bugs fixed

- [40109](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40109) Path to fix_invalid_dates.pl is incorrect in fix_invalid_dates.pl and search_for_data_inconsistencies.pl
  >This fixes a path in a hint in the search for data inconsistencies script (search_for_data_inconsistencies.pl) - misc/cronjobs/fix_invalid_dates.pl should be misc/maintenance/fix_invalid_dates.pl.

### ERM

#### Other bugs fixed

- [38899](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38899) Allow the Vue toolbar to be sticky
  >This restores the sticky toolbar when adding a vendor in the acquisitions module (Acquisitions > + New vendor). This is related to bug 38010, which migrates vendors in the acquisitions module to using Vue - the sticky menu was not included in this.
- [39951](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39951) Column filters are offset in ERM

### Hold requests

#### Other bugs fixed

- [39912](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39912) RealTimeHoldsQueue should be rebuilt when a holds pickup location is changed
- [40118](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40118) Regression - 'Holds to pull' library filters don't work
- [40122](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40122) 'Holds to pull' library filters don't work if library name contains parenthesis
  >This fixes the holds to pull page so that the dropdown library filter works if the library name contains parenthesis (Circulation > Holds and bookings > Holds to pull).

### I18N/L10N

#### Other bugs fixed

- [20601](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20601) Untranslatable strings in circulation statistics
  >This fixes and enhances the circulation statistics report wizard:
  >- Fixes some strings so that they are now translatable
  >- Fixes the patron library dropdown list so that it now works
  >- Improves the "Filtered on" information shown before the report results:
  >  . the filtered on options selected in the report are now shown in bold
  >  . descriptions are now shown instead of codes (for example, the library name instead of the library code)

  **Sponsored by** *Athens County Public Libraries*

### ILL

#### Other bugs fixed

- [40171](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40171) ILL Patron Has No Email Address on File message upon "Send Notice To Patron"

### Label/patron card printing

#### Other bugs fixed

- [34157](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34157) Exporting labels as a barcode range can cause a 500 error
  >This fixes the "Error 500..." message generated when printing barcode ranges using the label creator, where the layout type selected is "Bibliographic data precedes barcode" (Cataloging > Tools > Label creator).

### MARC Authority data support

#### Critical bugs fixed

- [40092](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40092) Clicking save doesn't fill auto-populated fields in authority and biblio editor
  >This fixes a regression between Koha 24.11, and 25.05 and main. When adding a new authority or bibliographic record, clicking save (without filling in any fields) now restores filling in the auto-populated fields such as 000, 003, and 008.

### OPAC

#### Critical bugs fixed

- [38102](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38102) Checkout history in OPAC displaying more than 50 items

#### Other bugs fixed

- [39223](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39223) The OPAC browse search (opac-browse.pl) is broken since 24.11
  >This fixes the OPAC browse search feature (OpacBrowseSearch system preference, Elasticsearch only). Expanding and collapsing the search results to show the details now works, instead of nothing happening.

### Packaging

#### Other bugs fixed

- [40039](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40039) Add production enhancements to build-git-snapshot tool

### Patrons

#### Other bugs fixed

- [34776](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34776) Patron messaging preferences are lost when an error occurs during new account creation
  >This fixes creating a new patron - the messaging preferences are now remembered if there is an error when creating a new patron. Before this, if there was an error when creating a patron (for example, the wrong age for the patron category), the messaging preferences (either the default or changes made) were emptied and needed to be re-added.

  **Sponsored by** *Koha-Suomi Oy*
- [39498](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39498) Correct display of patron restriction comments
- [40116](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40116) Extra popup notice when saving a patron with patron guarantor ends in error
  >This patch changes existing guarantors elements in the patron add form to use classes "guarantor_id" and "guarantor_relationship" to prevent an unnecessary pop-up if the form throws an error.

  **Sponsored by** *Koha-Suomi Oy*
- [40281](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40281) Patron circulation history page - type column is not hidden
  >This fixes the patron circulation history page. The 'Type' column should not be shown, and is now hidden.

### REST API

#### Other bugs fixed

- [39657](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39657) Block holds placed via the API when patron would be blocked from placing OPAC hold
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
- [40254](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40254) POST /holds override logic problem

### Reports

#### Other bugs fixed

- [39534](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39534) Saved report subgroup filter not hidden correctly

  **Sponsored by** *Athens County Public Libraries*

### SIP2

#### Other bugs fixed

- [32934](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32934) SIP checkouts using "no block" flag have a calculated due rather than the specified due date

### Searching - Zebra

#### Other bugs fixed

- [40304](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40304) Zebrasrv config doesn't consider non-AMD64 CPUs

### Serials

#### Other bugs fixed

- [39997](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39997) List of closed serials: reopening requires the syspref "RoutingSerials"

### Staff interface

#### Critical bugs fixed

- [40127](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40127) JS error on biblio detail page when there are no items
  >This fixes a JavaScript error on bibliographic record pages in the staff interface, where the record has no items.

#### Other bugs fixed

- [39939](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39939) Cancel selected holds button on the holds awaiting pickup page is the same color as the background
  >This fixes the cancel selected holds buttons on the holds awaiting pickup page (under the tabs) (Circulation > Holds > Holds awaiting pickup). The light grey background was removed, and you can now see the cancel selected holds buttons.
  >
  >It also links the TransferWhenCancelAllWaitingHolds system preference under the "Holds waiting past their expiration date", if the staff patron has permission to change system preferences.

  **Sponsored by** *Athens County Public Libraries*
- [40250](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40250) Wrong link to NoIssuesChargeGuarantorWithGuarantees in patron category page
- [40421](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40421) Logged in info should be data-attributes instead and text
  >This patch adds HTML data-attributes to some hidden content in the staff interface. This makes it easier to retrieve context about the logged in user with CSS or JavaScript.

### System Administration

#### Other bugs fixed

- [40088](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40088) Do not show edit button for default framework

### Templates

#### Critical bugs fixed

- [40161](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40161) New translation not displayed when translating an item type

#### Other bugs fixed

- [32284](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32284) Capitalization: Audio Carriers, Computer Carriers ... in UNIMARC value builders
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
- [32287](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32287) Capitalization: Printing and/or Publishing Information Transcribed as Found in the Colophon:␠
  >This fixes the capitalisation for the labels displayed in the OPAC and staff interface for UNIMARC subfields 214$r and $s - these are changed from capital case to sentence case, to be consistent with other labels:
  >- 214$r: Printing and/or publishing information transcribed
  >         as found in the main source of information
  >- 214$s: Printing and/or publishing information transcribed
  >         as found in the colophon
- [32296](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32296) Capitalization: Specification of Dimensionality,...
  >This fixes the capitalization for the labels displayed in the MARC tag editor for UNIMARC 181$b, when the value builder unimarc_field_181b.pl is used. The labels are changed from capital case to sentence case, for consistency with other labels:
  >- Specification of type (position 0)
  >- Specification of motion (position 1)
  >- Specification of dimensionality (position 2)
  >- Sensory specification 1, 2 and 3 (positions 3 to 5)
- [39441](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39441) Some templates have div.container instead of div.container-fluid
  >This updates a few templates so that div.container is replaced with div.container-fluid. div.container has a fixed maximum width that isn't consistent with the rest of Koha. An example where this caused display issues - the staff interface cart: the action icons were bunched up to the left, instead of being spread evenly across the pop-up window width.

  **Sponsored by** *Athens County Public Libraries*
- [39954](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39954) Cataloging search results incorrect menu markup

  **Sponsored by** *Athens County Public Libraries*
- [40111](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40111) Fix title sorting on two reports

  **Sponsored by** *Athens County Public Libraries*
- [40160](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40160) Use HTTPS for links to community websites
- [40244](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40244) Typo in branchoverdues.tt
- [40249](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40249) "Copy settings" should be "Copy permissions"
  >This bug changes the phrase "Copy settings" to read as "Copy permissions".

  **Sponsored by** *Athens County Public Libraries*
- [40319](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40319) Fix spacing in address display include

  **Sponsored by** *Athens County Public Libraries*

### Test Suite

#### Other bugs fixed

- [18772](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18772) t/ImportBatch.t generates warnings
- [40043](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40043) Agreements_spec.ts is failing randomly (2)
- [40046](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40046) Remove wait and screenshot from Tools/ManageMarcImport_spec.ts
- [40168](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40168) afterEach not called in KohaTable cypress tests
- [40169](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40169) Cypress tests - mockData should not replace "_id" fields if passed
- [40316](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40316) selenium/regressions.t generates warnings
- [40317](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40317) Auth_with_shibboleth.t generates warnings
- [40344](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40344) KohaTable_spec.ts is failing
- [40347](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40347) Koha/Hold.t generates diag
- [40348](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40348) api/v1/two_factor_auth.t generates warnings
- [40350](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40350) t/db_dependent/Holds.t generates warnings
- [40351](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40351) Koha/SearchEngine/Elasticsearch/Search.t  generates a warning
- [40353](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40353) Koha/Patron.t generates warnings
- [40372](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40372) api/v1/holds.t generates a warning
- [40373](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40373) Reserves.t generates a warning
- [40374](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40374) Koha/Booking.t generates warnings
- [40376](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40376) AuthorisedValues.t generates a warning
- [40377](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40377) HoldsQueue/TransportCostOptimizations.t generates warnings
- [40378](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40378) api/v1/biblios.t generates warnings
- [40379](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40379) t/db_dependent/www tests generate warnings
- [40380](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40380) Koha/Patrons/Import.t generates warnings
- [40381](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40381) Koha/SearchEngine/Elasticsearch/ExportConfig.t generates warnings
- [40384](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40384) Koha/Plugins/Patron.t generates warnings
- [40385](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40385) Reserves/CancelExpiredReserves.t generates a warning
- [40388](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40388) t/Labels.t generates a warning
- [40389](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40389) t/dummy.t is useless
- [40390](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40390) t/db_dependent/Biblio.t generates warnings
- [40402](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40402) xt/find-license-problems.t is failing
- [40403](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40403) Circulation_holdsqueue.t generates warnings
- [40404](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40404) t/Test/Mock/Logger.t generates warnings
- [40406](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40406) selenium/basic_workflow.t generates warnings
- [40409](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40409) t/db_dependent/Overdues.t generates warnings
- [40410](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40410) Letters.t generates a warning
- [40411](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40411) Koha/SearchEngine/Elasticsearch.t generates warnings
- [40419](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40419) xt/find-license-problems.t isn't catching all instances of 51 Franklin St/Street
- [40429](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40429) Koha/Patron/Modifications.t generates warnings
- [40437](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40437) Koha/Installer.t generates a warning
- [40438](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40438) Koha/Old/Hold.t generates warnings

### Tools

#### Critical bugs fixed

- [39289](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39289) Batch extend due date tool only displays the first 20 checkouts

#### Other bugs fixed

- [40332](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40332) Tools menu sidebar category not shown for users with batch_extend_due_dates only

## Enhancements 

### Accessibility

#### Enhancements

- [40330](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40330) Accessibility of the OPAC Labels

### Acquisitions

#### Enhancements

- [31632](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31632) Add ability to manually link orders to suggestions
  >This enhancement allows library staff to link an order (in an unclosed basket, or a standing order) to an accepted suggestion.

  **Sponsored by** *Pymble Ladies' College*

### Architecture, internals, and plumbing

#### Enhancements

- [40101](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40101) Add `Koha::Patron->can_place_holds`
- [40337](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40337) checkprevcheckout must be defined as ENUM at DB level

### Cataloging

#### Enhancements

- [39545](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39545) Construct more complete 773 content when creating a child record

  **Sponsored by** *Open Fifth*

### Circulation

#### Enhancements

- [39881](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39881) Add patron card number to the 'On hold for' column on the transfers to receive page
  >This enhancement adds the patron's card number to the transfers to receive page for patrons shown in the 'on hold for' column, for item-level holds (Circulation > Transfers > Transfers to receive).

### Developer documentation

#### Enhancements

- [40458](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40458) Discharge.pm is missing pod coverage

### Hold requests

#### Enhancements

- [38939](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38939) Add reservenote to members/holdshistory.pl
  >This enhancement add a 'Hold note' column to the patron's hold history table. It is configurable via administration's Table settings.

### ILL

#### Enhancements

- [38928](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38928) Openurl 'id' or 'rft_id' may contain key information

### OPAC

#### Enhancements

- [38792](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38792) Move "My virtual card" tab and maybe re-label it

  **Sponsored by** *Athens County Public Libraries*
- [39411](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39411) Add card number and patron expiration info to OPAC Virtual Card
- [40129](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40129) Always show the "Not finding what you're looking for" links in opac-results.tt

### Packaging

#### Enhancements

- [40164](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40164) Add Template::Plugin::JSON to handle JSON in Template Toolkit
  >This patch adds a new Template::Toolkit library to Koha's dependencies. This library, while not directly used in Koha, can be used in Template::Toolkit-driven templates to access JSON structures (e.g. notices, report templates, etc).
  >
  >A good example is making report templates that include JSON columns, like `background_jobs.data`.

### REST API

#### Enhancements

- [40176](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40176) Add maxLength to the item definition
- [40177](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40177) Add maxLength to the library definition
- [40178](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40178) Add maxLength to the patron definition
- [40179](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40179) Add maxLength to the patron's category definition

### Searching

#### Enhancements

- [33729](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33729) Add  a column for dateaccessioned to item search results
- [36947](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36947) Sort Elasticsearch/Zebra facets according to configurable locale instead of using Perl's stringwise/bytewise sort

### Templates

#### Enhancements

- [39448](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39448) Layout improvement for search filter administration

  **Sponsored by** *Athens County Public Libraries*
- [40172](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40172) Remove jQuery from js/fetch/http-client.js

### Test Suite

#### Enhancements

- [39876](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39876) Centralize listing of files from our codebase
- [40170](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40170) Replace cypress-mysql with mysql2
- [40401](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40401) Implement Koha::Patron->is_anonymous (was t/db_dependent/Auth.t generates warnings)
- [40407](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40407) Remove legacy "pre-wrap" versions (was Patron/Borrower_Discharge.t generates warnings)

## New system preferences

- FacetSortingLocale

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [English (USA)](https://koha-community.org/manual/25.05/en/html/)
- [French](https://koha-community.org/manual/25.05/fr/html/) (73%)
- [German](https://koha-community.org/manual/25.05/de/html/) (97%)
- [Greek](https://koha-community.org/manual/25.05/el/html/) (99%)
- [Hindi](https://koha-community.org/manual/25.05/hi/html/) (70%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (93%)
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
- Greek (66%)
- Hindi (95%)
- Italian (79%)
- Norwegian Bokmål (71%)
- Persian (fa_ARAB) (94%)
- Polish (99%)
- Portuguese (Brazil) (95%)
- Portuguese (Portugal) (87%)
- Russian (92%)
- Slovak (59%)
- Spanish (98%)
- Swedish (87%)
- Telugu (66%)
- Tetum (51%)
- Turkish (81%)
- Ukrainian (71%)
- Western Armenian (hyw_ARMN) (61%)
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

The release team for Koha 25.05.02 is


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
new features in Koha 25.05.02
<div style="column-count: 2;">

- Athens County Public Libraries
- [Koha-Suomi Oy](https://koha-suomi.fi)
- [Open Fifth](https://openfifth.co.uk/)
- Pymble Ladies' College
</div>

We thank the following individuals who contributed patches to Koha 25.05.02
<div style="column-count: 2;">

- Aleisha Amohia (2)
- Pedro Amorim (8)
- Tomás Cohen Arazi (19)
- Alexander Blanchard (1)
- Matt Blenkinsop (1)
- Nick Clemens (1)
- David Cook (5)
- Jake Deery (1)
- Paul Derscheid (5)
- Jonathan Druart (74)
- Laura Escamilla (3)
- Andrew Fuerste-Henry (1)
- Matthias Le Gac (1)
- Eric Garcia (1)
- Toni Gardiner (1)
- Lucas Gass (5)
- Mason James (1)
- Janusz Kaczmarek (3)
- Emily Lamancusa (6)
- Owen Leonard (12)
- Cath Leone (1)
- Nina Martinez (1)
- David Nind (2)
- Brian Norris (1)
- Andrew Nugged (1)
- PhilipOrr (1)
- Martin Renvoize (19)
- Marcel de Rooy (5)
- Caroline Cyr La Rose (2)
- Fridolin Somers (3)
- Lari Strand (1)
- Emmi Takkinen (4)
- Doris Tam (1)
- Baptiste Wojtkowski (4)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 25.05.02
<div style="column-count: 2;">

- Athens County Public Libraries (12)
- [BibLibre](https://www.biblibre.com) (8)
- [ByWater Solutions](https://bywatersolutions.com) (10)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha) (6)
- David Nind (2)
- Independant Individuals (5)
- Koha Community Developers (74)
- [Koha-Suomi Oy](https://koha-suomi.fi) (5)
- KohaAloha (1)
- [LMSCloud](https://www.lmscloud.de) (6)
- [Montgomery County Public Libraries](https://montgomerycountymd.gov) (6)
- [Open Fifth](https://openfifth.co.uk/) (30)
- [Prosentient Systems](https://www.prosentient.com.au) (5)
- Rijksmuseum, Netherlands (5)
- [Solutions inLibro inc](https://inlibro.com) (3)
- [Theke Solutions](https://theke.io) (19)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Aleisha Amohia (6)
- Pedro Amorim (4)
- Tomás Cohen Arazi (8)
- Andrew Auld (2)
- Matt Blenkinsop (9)
- Emmanuel Bétemps (4)
- David Cook (4)
- Paul Derscheid (207)
- Roman Dolny (7)
- Jonathan Druart (4)
- Magnus Enger (1)
- Laura Escamilla (1)
- David Flater (4)
- Andrew Fuerste-Henry (3)
- Eric Garcia (1)
- Lucas Gass (191)
- Kyle M Hall (2)
- Heather Hernandez (5)
- Kristi Krueger (6)
- Emily Lamancusa (12)
- Brendan Lawlor (1)
- Owen Leonard (16)
- Jesse Maseto (1)
- David Nind (76)
- Martin Renvoize (54)
- Phil Ringnalda (1)
- Marcel de Rooy (45)
- Caroline Cyr La Rose (1)
- Lisette Scheer (10)
- Tadeusz „tadzik” Sośnierz (1)
- Michelle Spinney (1)
- Felicie Thiery (1)
- Baptiste Wojtkowski (2)
- Anneli Österman (2)
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

Autogenerated release notes updated last on 24 Jul 2025 20:50:14.
