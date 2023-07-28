# RELEASE NOTES FOR KOHA 23.05.02
28 Jul 2023

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 23.05.02 can be downloaded from:

- [Download](http://download.koha-community.org/koha-23.05.02.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 23.05.02 is a bugfix/maintenance with security fixes release.

It includes 12 enhancements, 135 bugfixes including 5 security fixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [22990](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22990) Add CSRF protection to boraccount, pay, suggestions and virtualshelves on staff
- [30524](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30524) Add base framework for dealing with CSRF in Koha
- [33881](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33881) SCO/SCI user leaving the module doesn't clear session (ie JWT)
- [34023](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34023) HTML injection in "back to results" link from search page
- [34368](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34368) Add CSRF protection to Content Management pages

## Bugfixes

### About

#### Other bugs fixed

- [33899](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33899) Release team 23.11

### Acquisitions

#### Critical bugs fixed

- [33993](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33993) The GET orders endpoint needs to allow users with order_receive permission
- [34080](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34080) Updating suggestion status can result in 500 error

#### Other bugs fixed

- [33798](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33798) Vendor details - improve consistency of edit forms and display
  >This fixes display errors and improves the consistency of the vendor page and edit forms in acquisitions. Includes adding colons to field labels when adding an interface, making field labels all bold, and addressing some accessibility issues.
- [33863](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33863) On receive "change currency" is always checked
- [33939](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33939) JavaScript needs to distinguish between order budgets and default budgets when adding to staged file form a basket
- [34002](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34002) Check for stage_marc_import permission when adding to basket from a new file
- [34261](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34261) Deleting an EDIFACT ordering account throws an error

### Architecture, internals, and plumbing

#### Critical bugs fixed

- [32894](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32894) Objects cache methods' result without invalidation
- [33270](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33270) OAI-PMH should not die on record errors

#### Other bugs fixed

- [18855](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18855) Fines cronjob can cause duplicate fines if run during active circulation
- [24517](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24517) Zebra: date-entered-on-file misses 6th position
  >This patch fixes the date-entered-on-file index so that it correctly uses all 6 characters instead of the 5 character it has used the last 11 years.
  >
  >Note: For this patch to have effect, Zebra must be re-indexed.
- [26700](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26700) Remove unused C4/SIP/t directory
- [30002](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30002) Add project-level perltidyrc
- [30649](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30649) Vendor EDI account passwords should be encrypted in the database
- [33047](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33047) Local cover image fetchers return 500 internal error when image not available
- [33493](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33493) Add a filter relationship for branchtransfers
- [33496](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33496) Add 'host_items' param to Koha::Biblio->items
- [33500](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33500) Failing test for t/db_dependent/Circulation.t when RecordLocalUseOnReturn is set to record
- [33778](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33778) Move t/Auth_with_shibboleth.t to db_dependent
- [33937](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33937) Incorrect export in C4::Members
- [33950](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33950) Unnecessary processing in opac-readingrec if BakerTaylor and Syndetics off
- [33951](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33951) normalized_oclc not defined in opac-readingrecord.tt
- [33967](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33967) REMOTE_ADDR incorrect in plack.log when run behind a proxy
- [34033](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34033) DB update problems from bug 30649
- [34051](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34051) Koha::AuthorisedValues->get_description_by_koha_field not caching results for non-existent values
- [34243](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34243) Too many cities are created (at least in comments)
- [34303](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34303) t/00-testcritic.t should only test files part of git repo

### Authentication

#### Critical bugs fixed

- [33880](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33880) "Enable two-factor authentication" fails if patron's library branchname is too long

#### Other bugs fixed

- [31651](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31651) Log message incorrect in Auth_with_shibboleth.pm
- [33879](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33879) check_cookie_auth overwrites interface set by get_template_and_user
  >This fixes an issue with recording the interface for the log viewer where installations run the OPAC and staff interface on the same domain name. Before this patch, if a user logged into the OPAC and then went to the staff interface and performed a logable action (such as a checkout), the interface in the log was incorrectly recorded as the OPAC.

### Cataloging

#### Critical bugs fixed

- [34146](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34146) How to limit number of copies (on additem and serials-edit)?
- [34218](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34218) XSLT parse on record directly breaks OPAC display

#### Other bugs fixed

- [31185](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31185) Link authorities automatically doesn't detect duplicate authorities
- [34029](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34029) Import breaks when data exceeds size of mapped database columns
- [34097](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34097) Using the three ellipses to set the date accessioned for an item repositions the screen to the top
- [34182](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34182) AddBiblio shouldn't set biblio.serial based on biblio.seriestitle
- [34251](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34251) MARC editor with JS error when using fast add framework

### Circulation

#### Other bugs fixed

- [31082](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31082) Add tooltip to buttons when item bundles cannot be changed while checked out
- [31147](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31147) Recalls due date to the minute rather than 23:59

  **Sponsored by** *Catalyst*
  >The current recalls behaviour adjusts the due date of the most appropriate checkout based on the 'recall due date interval' circulation rule. It also adjusts the due time, which is buggy behaviour. The due date should be adjusted based on the circulation rule, but the due time should remain the same.
- [33806](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33806) Overridden checkin date not retained when CircConfirmItemParts enabled
- [33817](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33817) Composition of an item bundle can be changed if checked out
- [33858](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33858) Date for pending offline circulation is unformatted
- [33944](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33944) When listing checkouts, don't fetch item object if not using recalls
- [33961](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33961) In-built Offline circulation tool no longer working and should be removed
  >This removed the in-built Koha offline circulation tool that could be activated using the AllowOfflineCirculation system preference. This won't have any effect on the KOCT Firefox plugin or on the Windows desktop offline circulation tool.
- [33976](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33976) Claims returned option is not disabled in moredetail.pl if the item has a different lost status
- [34071](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34071) Change the phrasing of 'automatic checkin' to fit consistent terminology
- [34072](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34072) Holds queue search interface hidden on small screens
- [34086](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34086) On detail.tt if item.permanent_location is NULL no shelving location will show
- [34232](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34232) Item groups dropdown on add item form does not respect display order

### Documentation

#### Other bugs fixed

- [33790](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33790) Fix and add various links to the manual

### ERM

#### Other bugs fixed

- [33941](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33941) EBSCO Packages filter failing
- [33973](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33973) Sorting broken on ERM tables
- [34107](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34107) Sorting agreements by Name actually sorts by ID
- [34201](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34201) Missing sorting indicator on the ERM tables
- [34214](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34214) Toolbar component should make the icon configurable

  **Sponsored by** *Bibliothèque Universitaire des Langues et Civilisations (BULAC)*

### Hold requests

#### Critical bugs fixed

- [34178](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34178) Add caching of ItemsAnyAvailableAndNotRestricted to IsAvailableForItemLevelRequest
- [34233](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34233) Pickup location pulldowns when placing holds in staff are blank

#### Other bugs fixed

- [30860](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30860) Performance: Add option for CanBookBeReserved to return all item values
- [33573](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33573) Add public endpoint for cancelling holds
- [34137](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34137) Requested cancellation date column missing from holds awaiting pickup table config

### ILL

#### Critical bugs fixed

- [34130](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34130) ILL requests table won't load if request_placed date is null

### Installation and upgrade (web-based installer)

#### Critical bugs fixed

- [33671](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33671) Database update 22.06.00.048  breaks update process
- [34337](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34337) Web installer doesn't install patrons when select all is used

#### Other bugs fixed

- [33581](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33581) Error in web installer concerning sample holidays and patrons requiring sample libraries

### Label/patron card printing

#### Other bugs fixed

- [34209](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34209) Follow up on Bug 28726 - move whole search header div into checkbox column condition

### Lists

#### Other bugs fixed

- [32402](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32402) "Modification date" missing from OPAC lists table
  >This enhancement adds the modification date column to the lists tables for the OPAC. This lets patrons know when the list was last updated.

### MARC Authority data support

#### Critical bugs fixed

- [33404](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33404) Authorities imported from Z39.50 in encodings other than UTF-8 are corrupted

#### Other bugs fixed

- [34180](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34180) Template variable in JavaScript triggers error when showing authority MARC preview

### MARC Bibliographic data support

#### Other bugs fixed

- [26862](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26862) MARC21 530 is missing from staff interface and has no label
  >This fixes the display of the MARC21 530 tag and subfields so that it:
  >- now displays in the staff interface (was missing)
  >- improves the display of the values by adding
  >  . a description/label
  >  . separators between repeated 530 tags
  >  . missing spaces before $u and between repeated $u subfields
- [31618](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31618) Typo in POD for C4::ImportBatch::RecordsFromMARCXMLFile

### Notices

#### Other bugs fixed

- [33900](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33900) advance_notices.pl cronjob hangs

### OPAC

#### Critical bugs fixed

- [34174](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34174) Saving RIS results to Error 505

#### Other bugs fixed

- [32341](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32341) Some OPAC tables are not displayed well in mobile mode
- [33933](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33933) Use restrictions appear twice for items on OPAC
- [33957](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33957) normalized_oclc not defined in opac-user.tt
- [34005](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34005) Toggling the search term highlighting is not always working in the bibliographic record details page
- [34015](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34015) Terminology: Relative issues should be Relative's checkouts

### Packaging

#### Other bugs fixed

- [33720](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33720) updatedatabase.pl should purge memcached

### Patrons

#### Critical bugs fixed

- [34106](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34106) Patron search in member-search-box.inc always defaults to 'Starts with' search

#### Other bugs fixed

- [33117](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33117) Patron checkout search not working if searching with second surname
- [33176](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33176) Improve enforcing of RequirePaymentType
- [33820](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33820) Add hints to warn the librarian that they will be logged out if they change their username
- [33968](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33968) Two colons missing on guarantor labels in memberentry.pl form
- [34083](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34083) Patron auto-complete fails if organization patron full name is in a single field separated by a space
- [34092](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34092) patron-autocomplete.js and patron-search.inc search logic should match
- [34256](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34256) Patron search: search for borrowernumber starts with fails

### REST API

#### Critical bugs fixed

- [32801](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32801) /checkouts?checked_in=1 errors when itemnumber is null

#### Other bugs fixed

- [33996](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33996) Authority objects missing mapping

### Reports

#### Other bugs fixed

- [27824](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27824) Report batch operations break with space in placeholder
- [29664](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29664) Do not show voided payments in cash register statistics wizard

### Searching

#### Other bugs fixed

- [28196](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28196) In page anchors on additem.pl don't always go to the right place
- [31253](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31253) Item search in staff interface should call barcodedecode if the search index is a barcode
- [33896](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33896) Catalog search from the masthead searchbar produces a warning in the logs

### Serials

#### Other bugs fixed

- [23775](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23775) Claiming a serial issue doesn't create the next one
- [33901](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33901) Only one issue shown when testing prediction pattern
- [34052](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34052) Fix link to subscription from serial collection page

### Staff interface

#### Other bugs fixed

- [32245](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32245) Deleting news entries from Koha's staff start page is broken
- [33497](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33497) Reduce DB calls on staff detail page
- [33946](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33946) biblio-title.inc should not add a link if biblio does not exist
- [34094](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34094) Apply DefaultPatronSearchMethod to all patron search forms
- [34116](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34116) Add page-sectioning to item search in label creator
- [34131](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34131) Plugins page breadcrumbs and side menu not consistent

### System Administration

#### Other bugs fixed

- [33578](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33578) Cannot edit patron restriction types
- [33868](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33868) Upgrade the Multiple Select plugin in the staff interface
  >This enhancement updates the jQuery Multiple Select plugin version from 1.1 to 1.6. This plugin is used in the staff interface system preferences area.

### Templates

#### Other bugs fixed

- [33528](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33528) Use template wrapper for tabs: Patron details and circulation
- [33781](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33781) Terminology: Item already issued to other borrower.
- [33855](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33855) Clean up forms and page sections on 'manage MARC imports' page
  >This enhancement makes minor changes to the structure of the "Manage staged MARC records" page for a batch so that sections are more clearly delineated and forms have the correct structure. It also shortens the new framework field labels and adds hints for clarification.
- [33893](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33893) Use template wrapper for tabs: OPAC checkout history
- [33894](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33894) Use template wrapper for tabs: OPAC search history
- [33897](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33897) Use template wrapper for tabs: OPAC bibliographic detail page
- [33999](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33999) Subscription details link on bibliographic detail page should have permission check
- [34010](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34010) Template corrections to recall pages
- [34012](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34012) Use template wrapper for tabs: Recalls awaiting pickup
- [34013](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34013) Recalls awaiting pickup doesn't show count on each tab
- [34074](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34074) Improve translations of strings on the about page
- [34103](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34103) Capitalization: Currencies & Exchange rates
- [34184](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34184) "Document type" in suggestions form should have an empty entry
- [34244](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34244) Improve contrast in staff interface main page layered icons

### Test Suite

#### Other bugs fixed

- [33727](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33727) Merge Calendar tests
- [33852](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33852) jobs.t is not testing only_current

### Tools

#### Critical bugs fixed

- [34181](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34181) Batch patron modification tool missing checkboxes to clear field values
- [34288](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34288) Cannot use cataloguing tools without cataloguing permissions

#### Other bugs fixed

- [29762](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29762) Patron batch modification tool - mobile phone number column naming
- [33667](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33667) 'Copy to all libraries' doesn't work on editing holidays

  **Sponsored by** *Koha-Suomi Oy*
- [33972](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33972) Remove unnecessary batch status change in C4::ImportBatch
- [33987](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33987) Combine multiple db updates in C4::ImportBatch::BatchCommitRecords for efficiency/avoiding possible deadlocks
- [33989](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33989) Inventory tool performs unnecessary authorized value lookups
- [34220](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34220) Running log viewer for only Catalog module loads wrong side navbar
- [34225](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34225) KohaTable broken on batch item deletion and modification results

## Enhancements 

### Architecture, internals, and plumbing

#### Enhancements

- [33776](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33776) Add inLibro in default plugin repositories
  >This enhancement adds inLibro to the list of git repositories searched for plugins. 
  >
  >Notes: 
  >- The ability to search git repositories for plugins from the manage plugins page, and then install, requires a system-level configuration change for your Koha instance(s).
  >- To enable, copy the <plugin_repos> block from debian/templates/koha-conf-site.xml.in to your instance's koha-conf.xml file, remove comments, and restart.

### Cataloging

#### Enhancements

- [29732](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29732) Check alert in cataloguing authorities should be a static message
  >This patch changes the way error form validation error messages are displayed when editing authority records. Instead of a JavaScript alert, errors are now shown on the page itself, with links in the message to take you to the corresponding field. A new "Errors" button in the toolbar allows the user to jump back to the list of errors for easy reference.

### ERM

#### Enhancements

- [33417](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33417) Create one standard Toolbar component

### Label/patron card printing

#### Enhancements

- [28726](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28726) Add sort1 and sort2 to patron card creator patron search

### MARC Bibliographic data support

#### Enhancements

- [29471](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29471) MARC21: 520 - Summary etc. doesn't display in staff interface

### OPAC

#### Enhancements

- [33808](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33808) Accessibility: Non-descriptive links

### Plugin architecture

#### Enhancements

- [31339](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31339) Add Template::Toolkit WRAPPER for Koha Tool Plugins

### REST API

#### Enhancements

- [33974](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33974) Add ability to search biblios endpoint any biblioitem attribute
- [34211](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34211) Add +strings for GET /api/v1/biblios/:biblio_id/items

### SIP2

#### Enhancements

- [34101](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34101) Limit items types that can be checked out via SIP2

### System Administration

#### Enhancements

- [27424](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27424) One should be able to assign an SMTP server as the default
  >We have been able to define SMTP servers in the staff interface for a while now. But to utilize them you had to set the SMTP server for each library individually. With this you can now chose to apply an SMTP server as default to all your libraries.

### Templates

#### Enhancements

- [34124](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34124) Improve in-page navigation on table settings page

## New system preferences

- DefaultPatronSearchMethod

## Deleted system preferences

- AllowOfflineCirculation

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (70.9%)
- Armenian (100%)
- Armenian (Classical) (63.8%)
- Bulgarian (91.8%)
- Chinese (Taiwan) (96.1%)
- Czech (58%)
- English (New Zealand) (67.7%)
- English (USA)
- Finnish (95.9%)
- French (99.9%)
- French (Canada) (98.5%)
- German (100%)
- Hindi (100%)
- Italian (90.9%)
- Nederlands-Nederland (Dutch-The Netherlands) (80.5%)
- Norwegian Bokmål (71.2%)
- Persian (83.8%)
- Polish (91.5%)
- Portuguese (89.2%)
- Portuguese (Brazil) (99.7%)
- Russian (95.1%)
- Slovak (61%)
- Spanish (99.7%)
- Swedish (81.5%)
- Telugu (76.1%)
- Turkish (85.9%)
- Ukrainian (77%)
</div>

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 23.05.02 is


- Release Manager: Tomás Cohen Arazi

- Release Manager assistants:
  - Jonathan Druart
  - Martin Renvoize

- QA Manager: Katrin Fischer

- QA Team:
  - Aleisha Amohia
  - Nick Clemens
  - David Cook
  - Jonathan Druart
  - Lucas Gass
  - Victor Grousset
  - Kyle M Hall
  - Andrii Nugged
  - Martin Renvoize
  - Marcel de Rooy
  - Petro Vashchuk

- Topic Experts:
  - UI Design -- Owen Leonard
  - Zebra -- Fridolin Somers
  - REST API -- Martin Renvoize
  - ERM -- Pedro Amorim
  - ILL -- Pedro Amorim

- Bug Wranglers:
  - Aleisha Amohia

- Packaging Manager: Mason James

- Documentation Manager: Aude Charillon

- Documentation Team:
  - Caroline Cyr La Rose
  - Lucy Vaux-Harvey

- Translation Manager: Bernardo González Kriegel


- Wiki curators: 
  - Thomas Dukleth
  - Katrin Fischer

- Release Maintainers:
  - 23.05 -- Fridolin Somers
  - 22.11 -- PTFS Europe (Matt Blenkinsop, Pedro Amorim)
  - 22.05 -- Lucas Gass
  - 21.11 -- Danyon Sewell

- Release Maintainer assistants:
  - 21.11 -- Wainui Witika-Park

## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 23.05.02
<div style="column-count: 2;">

- [Bibliothèque Universitaire des Langues et Civilisations (BULAC)](http://www.bulac.fr)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)
- [Koha-Suomi Oy](https://koha-suomi.fi)
</div>

We thank the following individuals who contributed patches to Koha 23.05.02
<div style="column-count: 2;">

- Aleisha Amohia (1)
- Pedro Amorim (14)
- Tomás Cohen Arazi (26)
- Matt Blenkinsop (11)
- Philippe Blouin (1)
- Jérémy Breuillard (1)
- Nick Clemens (22)
- David Cook (13)
- Jake Deery (2)
- Jonathan Druart (44)
- Laura Escamilla (1)
- Katrin Fischer (11)
- Lucas Gass (12)
- Victor Grousset (1)
- Thibaud Guillot (1)
- Amit Gupta (1)
- Michał Górny (1)
- Michael Hafen (3)
- Kyle M Hall (5)
- Jan Kissig (1)
- Emily Lamancusa (1)
- Sam Lau (4)
- Owen Leonard (25)
- Julian Maurice (2)
- Jacob O'Mara (1)
- Philip Orr (1)
- Martin Renvoize (20)
- Phil Ringnalda (3)
- Adolfo Rodríguez (1)
- Marcel de Rooy (26)
- Caroline Cyr La Rose (2)
- Andreas Roussos (1)
- Fridolin Somers (4)
- Emmi Takkinen (1)
- Koha translators (1)
- Hammat Wele (5)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 23.05.02
<div style="column-count: 2;">

- Athens County Public Libraries (25)
- BibLibre (8)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (11)
- ByWater-Solutions (40)
- Catalyst Open Source Academy (1)
- Chetco Community Public Library (3)
- Dataly Tech (1)
- gentoo.org (1)
- Independant Individuals (8)
- Informatics Publishing Ltd (1)
- Koha Community Developers (45)
- Koha-Suomi (1)
- lmscloud.de (1)
- montgomerycountymd.gov (1)
- Prosentient Systems (13)
- PTFS-Europe (47)
- Rijksmuseum (26)
- Solutions inLibro inc (8)
- th-wildau.de (1)
- Theke Solutions (26)
- Xercode (1)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- AlexanderBlanchardAC (1)
- Pedro Amorim (4)
- Tomás Cohen Arazi (230)
- Alexander Blanchard (2)
- Univ Brest (1)
- Nick Clemens (27)
- David Cook (12)
- Paul Derscheid (4)
- Jonathan Druart (28)
- Sharon Dugdale (1)
- ebal (1)
- Katrin Fischer (73)
- Andrew Fuerste-Henry (5)
- Lucas Gass (9)
- Victor Grousset (2)
- Kyle M Hall (12)
- Sally Healey (1)
- Heather Hernandez (1)
- Emily Lamancusa (3)
- Rachael Laritz (1)
- Sam Lau (49)
- Owen Leonard (16)
- Solene Ngamga (1)
- David Nind (27)
- Björn Nylén (2)
- Quinn (1)
- Martin Renvoize (290)
- Phil Ringnalda (3)
- Marcel de Rooy (38)
- Caroline Cyr La Rose (1)
- Lisette Scheer (1)
- Michaela Sieber (6)
- Fridolin Somers (18)
- Ed Veal (1)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 23.05.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 28 Jul 2023 21:21:11.
