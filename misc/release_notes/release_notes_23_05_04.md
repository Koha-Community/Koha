# RELEASE NOTES FOR KOHA 23.05.04
28 Sep 2023

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 23.05.04 can be downloaded from:

- [Download](http://download.koha-community.org/koha-23.05.04.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 23.05.04 is a bugfix/maintenance release.

It includes 10 enhancements, 114 bugfixes including 4 security fixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [34349](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34349) Validate inputs for task scheduler
- [34369](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34369) Add CSRF protection to system preferences
- [34513](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34513) Authenticated users can bypass permissions and view some privileged pages
- [34761](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34761) Stored/reflected XSS with searches and saved search filters

## Bugfixes

### Acquisitions

#### Critical bugs fixed

- [34109](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34109) When adding items on receive, mandatory fields are not checked
- [34509](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34509) Cannot create baskets if too many vendors
- [34736](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34736) Item checkboxes move to wrong order line in multi-receive, breaking partial receive
- [34880](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34880) Receive impossible if items created 'in cataloguing'

#### Other bugs fixed

- [34036](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34036) Single receive doesn't reload data and order lines don't appear in received section

  **Sponsored by** *Toi Ohomai Institute of Technology*
- [34095](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34095) Shipping cost should default to a blank box instead of 0.00
- [34445](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34445) Default budget is not selected in addorderiso2709.pl

### Architecture, internals, and plumbing

#### Critical bugs fixed

- [34720](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34720) UpdateNotForLoanStatusOnCheckin should be named UpdateNotForLoanStatusOnCheckout
- [34731](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34731) C4::Letters::SendQueuedMessages can be triggered with an undef message_id
  >This fixes an issue where generating a notice that is undefined (for example, where it is empty) will trigger the sending of any pending messages, even though the message queue cronjob isn't run. This can cause an issue for libraries that expect emails and SMS messages to be processed at specific times.

#### Other bugs fixed

- [21828](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21828) Improve efficiency of C4::Biblio::LinkBibHeadingsToAuthorities
- [30362](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30362) GetSoonestRenewDate is technically wrong when NoRenewalBeforePrecision set to date soonest renewal is today
- [34570](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34570) Remove use of onclick for PopupMARCFieldDoc()
- [34571](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34571) Remove use of onclick for ExpandField
- [34589](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34589) Update on bug 20256 is not idempotent
- [34656](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34656) CartToShelf should not trigger RealTimeHoldsQueue
- [34786](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34786) after_biblio_action hooks: find after delete makes no sense
- [34844](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34844) manage_item_editor_templates is missing from userpermissions.sql

### Authentication

#### Critical bugs fixed

- [34163](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34163) CSRF error if try OAuth2/OIDC after logout

### Cataloging

#### Other bugs fixed

- [33744](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33744) Plugins not working on duplicated MARC fields
- [34266](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34266) Item type should not default to biblio itemtype if it's not a valid itemtype

### Circulation

#### Critical bugs fixed

- [34601](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34601) Cannot manage suggestions without CSRF error

#### Other bugs fixed

- [25023](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25023) Claims returned dates not formatted according to dateformat preference
- [32765](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32765) Transfer is not retried after cancelling hold
- [34257](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34257) Library limitations for item types not respected when batch modding items
- [34302](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34302) Checkin and renewal error messages disappear immediately in checkouts table
- [34341](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34341) Revert Bug 34072: Holds queue search interface hidden on small screens
- [34572](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34572) Simplify template logic around check-in input form
- [34634](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34634) Expiration date does not display on reserve/request.pl if date is today or in the past

### Command-line Utilities

#### Critical bugs fixed

- [34764](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34764) sip_cli_emulator -fa/--fee_acknowledge does not act as expected

#### Other bugs fixed

- [31964](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31964) Missing manpage for koha-z3950-responder
  >This adds a man page for the `koha-z3950-responder` command-line utility, documenting all available options and parameters that can be used when running this command.
- [34505](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34505) Patron invalid age in search_for_data_inconsistencies.pl should skip expired patrons
- [34569](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34569) misc/cronjobs/holds/holds_reminder.pl problem with trigger arg
- [34653](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34653) Make koha-foreach return the correct status code

### ERM

#### Other bugs fixed

- [34219](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34219) getAll not allowing additional parameters
- [34465](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34465) "Actions" columns are sortable
- [34466](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34466) "Clear filter" always disabled
- [34789](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34789) Fix typo in erm_eholdings_titles

### Fines and fees

#### Critical bugs fixed

- [34620](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34620) Writeoff causes 500 error if  RequirePaymentType is on
  >This fixes writing off a charge when the RequirePaymentType system preference is set to required. The write-off now completes successfully without generating an error page (Patrons > [patron account] > Accounting > Make a payment > Write off an individual charge).

#### Other bugs fixed

- [34331](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34331) Point of sale transaction history is showing the wrong register information
- [34340](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34340) Point of sale email template is showing 0.00 in the tendered field

### Hold requests

#### Critical bugs fixed

- [34609](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34609) Holds history errors 500 if old_reserves.biblionumber is NULL
- [34666](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34666) _Findgroupreserve is not returning title level matches from the queue for holds with no item group

### I18N/L10N

#### Other bugs fixed

- [34079](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34079) The phrase "Displaying [all|approved|pending|rejected] terms" was separated
- [34081](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34081) Contextualization of "Approved" (one term) vs "Approved" (more than one term), and other tag statuses
- [34310](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34310) Input prompt in datatables column search boxes untranslatable

### ILL

#### Other bugs fixed

- [34223](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34223) ILL status filter does not load immediately after selecting a backend filter

### Installation and upgrade (command-line installer)

#### Critical bugs fixed

- [34276](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34276) upgrading 23.05 to 23.05.002

#### Other bugs fixed

- [34684](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34684) 220600007.pl is failing if run twice
- [34685](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34685) updatedatabase.pl does not propagate the error code

### Label/patron card printing

#### Other bugs fixed

- [34532](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34532) Silence warns in Patroncard.pm when layout values are empty
- [34592](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34592) The patron search window, given just a sort field value, doesn't work

### Lists

#### Other bugs fixed

- [34650](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34650) Editing/deleting lists from toolbar on virtualshelves/shelves.pl causes CSRF error

### Notices

#### Other bugs fixed

- [33759](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33759) Typo: Thankyou
- [34583](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34583) Overdue notices: wrong encoding in e-mail in 'print' mode

### OPAC

#### Critical bugs fixed

- [34518](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34518) "Renew all" button doesn't work in OPAC
- [34694](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34694) OPAC bib record blows up with error 500
- [34768](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34768) Can't pay fines on OPAC if patron has a guarantee and they can see their fines

#### Other bugs fixed

- [27496](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27496) Accessibility: Navigation buttons are poorly described by screen readers
- [29578](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29578) Search term highlighting breaks with titles containing characters with Greek diacritics
  >This fixes an issue with the term highlighter which is used during catalog searches in both the OPAC and the Staff interface. Under certain conditions (searching for titles containing characters with Greek diacritics), the jQuery term highlighter would break and in the process make the "Highlight" / "Unhighlight" button disappear altogether. UNIMARC instances were affected the most by this.
- [34522](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34522) Suggestion for purchase displays wrong library in OPAC display if patron suggests for non-home library
- [34613](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34613) Remove onclick event attributes from Verovio midiplayer.js
- [34627](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34627) Fix CMS page HTML structure so that footer content is displayed correctly
- [34641](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34641) Novelist content does not display on OPAC detail page if NovelistSelectView is set to below
- [34711](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34711) Remove use of onclick for opac-privacy.pl
- [34723](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34723) opac-imageviewer.pl not showing thumbnails
- [34724](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34724) Remove use of onclick for opac-imageviewer.pl
- [34725](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34725) Remove use of onclick for OPAC cart
- [34730](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34730) Add responsive behavior to more tables in the OPAC
- [34760](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34760) Prevent error when logging into OPAC after conducting a search

  **Sponsored by** *Toi Ohomai Institute of Technology*

### Patrons

#### Other bugs fixed

- [34356](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34356) Enabling RecordStaffUserOnCheckout causes bad default sorting in checkout history
- [34402](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34402) Sorting holds on patron account includes articles
- [34728](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34728) HTML notices should not be pre-formatted
- [34743](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34743) Incorrect POD in import_patrons.pl

### REST API

#### Other bugs fixed

- [32942](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32942) Suggestion API doesn't support custom statuses
- [34339](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34339) $c->validation should be avoided (part 2)

### Reports

#### Other bugs fixed

- [34552](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34552) No Results when filtering "All payments to the library" or "payment" in Statistics wizards : Cash register

### SIP2

#### Critical bugs fixed

- [34767](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34767) SIP2 fee acknowledgement flag on renewals is passed, but not used

#### Other bugs fixed

- [23548](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23548) AQ field required in checkin response
  >This fixes SIP return messages so that there is an "AQ|" field, even if it is empty (this is a required field according to the specification, and some machines (such as PV-SUPA) crash if it is not present).

### Searching - Elasticsearch

#### Other bugs fixed

- [33406](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33406) Searching for authority with hyphen surrounded by spaces causes error 500 (with ES)
- [34740](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34740) Sort option are wrong in search engine configuration (Elasticsearch)

### Serials

#### Critical bugs fixed

- [30451](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30451) Delete a subscription deletes the linked order
  >When an order had been created using the 'from a subscription' option and the subscription was deleted, the order line would be deleted with it, independent of its status or age. This caused problems with funds and budgets. With this patch, we will unlink order line and subscription on delete, but the order line will remain.

### Staff interface

#### Critical bugs fixed

- [34639](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34639) Item shown in transit on detail.pl even if marked as arrived or cancelled

#### Other bugs fixed

- [34616](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34616) "Edit SMTP server" page - Default SMTP configuration dialog has some issues

### System Administration

#### Critical bugs fixed

- [34622](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34622) SMTP server edit page unsets is_default if editing default server

#### Other bugs fixed

- [34748](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34748) Wrong column name basket_number in table settings for basket

### Templates

#### Other bugs fixed

- [33734](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33734) Using custom search filters breaks diacritics characters in search term
- [34038](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34038) Fix incorrect use of __() in .tt and .inc files
- [34066](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34066) Datatable options don't fully translate on list of saved reports
- [34115](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34115) Use a global tab select function for activating Bootstrap tabs based on location hash
- [34307](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34307) Update plugin wrapper to use template wrapper for breadcrumbs
- [34379](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34379) Inconsistencies in Library groups page
- [34385](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34385) Inconsistencies in Transport cost matrix page header
- [34386](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34386) Inconsistencies in Cities and towns page titles, breadcrumbs, and header
- [34434](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34434) Terminology: Biblio should be bibliographic
- [34436](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34436) Some breadcrumbs lack <span> for translatability
- [34502](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34502) Useless SEARCH_RESULT.localimage usage
- [34533](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34533) jsdiff library missing from guided reports page
- [34565](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34565) Label mismatch in MARC21 006 and 008 cataloging plugins
- [34567](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34567) Correct colors for advanced cataloging editor status bar
- [34625](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34625) Search engine configuration tables header problem
- [34646](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34646) Two attributes class in OPAC masthead-langmenu.inc
- [34835](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34835) Highlight logged-in library in patron searches does not work anymore in new staff interface

### Test Suite

#### Other bugs fixed

- [34843](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34843) Koha/Database/Commenter.t is failing if the DB has been upgraded
- [34846](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34846) SIP/ILS.t is failing if the DB has been upgraded
- [34847](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34847) Search.t is failing if the DB has been upgraded
- [34848](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34848) SIP/Message.t is failing if the DB has been upgraded

### Tools

#### Critical bugs fixed

- [34617](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34617) Patron expiration dates not updated during import when there is no dateexpiry column in the file

#### Other bugs fixed

- [22135](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22135) Inventory tool doesn't export "out of order" problem to CSV
  >This fixes the export of inventory results when "Check barcodes list for items shelved out of order" is selected. Currently, the problem column is blank for items shelved out of order when it should be "Shelved out of order".
- [32048](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32048) Calendar adding holidays repeated
- [34732](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34732) Barcode image generator doesn't generate correct Code39 barcode

## Enhancements 

### Architecture, internals, and plumbing

#### Enhancements

- [34787](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34787) Typo gorup

### Circulation

#### Enhancements

- [33876](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33876) item-note-nonpublic and item-note-public are difficult to customize in the checkout table

### Command-line Utilities

#### Enhancements

- [28995](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28995) Add --added_after to writeoff_debts.pl

### ERM

#### Enhancements

- [34448](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34448) ERM should be able to display error messages coming from the API

### OPAC

#### Enhancements

- [12421](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12421) No way to get back to search results from overdrive results

### Patrons

#### Enhancements

- [34719](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34719) Middle name doesn't show on autocomplete

### REST API

#### Enhancements

- [34054](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34054) Allow to embed biblio on GET /items

  **Sponsored by** *Bibliothèque Universitaire des Langues et Civilisations (BULAC)*
- [34313](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34313) Make password validation endpoint return patron IDs
- [34333](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34333) Add cancellation request information embed option to the holds endpoint

### Templates

#### Enhancements

- [34345](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34345) 'Circulation and fine rules' vs 'Circulation and fines rules'

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
- Armenian (Classical) (63.7%)
- Bulgarian (91.7%)
- Chinese (Taiwan) (99.5%)
- Czech (57.9%)
- English (New Zealand) (67.6%)
- English (USA)
- Finnish (100%)
- French (99.8%)
- French (Canada) (99.7%)
- German (100%)
- Hindi (100%)
- Italian (90.8%)
- Nederlands-Nederland (Dutch-The Netherlands) (80.5%)
- Norwegian Bokmål (74.7%)
- Persian (93.5%)
- Polish (94.5%)
- Portuguese (89.5%)
- Portuguese (Brazil) (100%)
- Russian (96.5%)
- Slovak (60.9%)
- Spanish (99.9%)
- Swedish (83.8%)
- Telugu (76%)
- Turkish (85.9%)
- Ukrainian (78.2%)
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

The release team for Koha 23.05.04 is


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
new features in Koha 23.05.04
<div style="column-count: 2;">

- [Bibliothèque Universitaire des Langues et Civilisations (BULAC)](http://www.bulac.fr)
- Toi Ohomai Institute of Technology
</div>

We thank the following individuals who contributed patches to Koha 23.05.04
<div style="column-count: 2;">

- Aleisha Amohia (2)
- Pedro Amorim (17)
- Tomás Cohen Arazi (16)
- Matt Blenkinsop (9)
- Kevin Carnes (1)
- Nick Clemens (22)
- David Cook (22)
- Frédéric Demians (1)
- Jonathan Druart (17)
- Laura Escamilla (3)
- Katrin Fischer (8)
- Lucas Gass (10)
- Evan Giles (1)
- Victor Grousset (4)
- Michael Hafen (1)
- Kyle M Hall (6)
- Janusz Kaczmarek (1)
- Emily Lamancusa (1)
- Per Larsson (1)
- Owen Leonard (21)
- Julian Maurice (3)
- Matthias Meusburger (1)
- Martin Renvoize (12)
- Marcel de Rooy (6)
- Caroline Cyr La Rose (2)
- Andreas Roussos (3)
- Fridolin Somers (7)
- Arthur Suzuki (2)
- Petr Svoboda (1)
- Emmi Takkinen (1)
- Lari Taskula (2)
- Koha translators (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 23.05.04
<div style="column-count: 2;">

- Athens County Public Libraries (21)
- BibLibre (13)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (8)
- ByWater-Solutions (41)
- Catalyst (1)
- Catalyst Open Source Academy (2)
- Dataly Tech (3)
- Göteborgs Universitet (1)
- Hypernova Oy (2)
- Independant Individuals (2)
- Koha Community Developers (21)
- Koha-Suomi (1)
- montgomerycountymd.gov (1)
- Prosentient Systems (22)
- PTFS-Europe (38)
- R-Bit Technology (1)
- Rijksmuseum (6)
- Solutions inLibro inc (2)
- Tamil (1)
- Theke Solutions (16)
- ub.lu.se (1)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Aleisha Amohia (4)
- Pedro Amorim (11)
- Andrew (2)
- Tomás Cohen Arazi (186)
- Matt Blenkinsop (6)
- Christopher Brannon (1)
- Barry Cannon (1)
- Christine (1)
- Nick Clemens (8)
- David Cook (5)
- Chris Cormack (3)
- Ray Delahunty (1)
- Michal Denar (1)
- Jonathan Druart (22)
- Laura Escamilla (4)
- Katrin Fischer (52)
- Émily-Rose Francoeur (2)
- Andrew Fuerste-Henry (1)
- Lucas Gass (11)
- Salah Ghedda (3)
- Nicolas Giraud (1)
- Victor Grousset (16)
- Kyle M Hall (8)
- Inkeri (1)
- Jason (1)
- joubu (2)
- Emily Lamancusa (2)
- Sam Lau (10)
- Owen Leonard (17)
- Christian Nelson (1)
- David Nind (31)
- Martin Renvoize (21)
- Marcel de Rooy (53)
- Caroline Cyr La Rose (7)
- Andreas Roussos (2)
- Michaela Sieber (4)
- Fridolin Somers (196)
- Lari Taskula (1)
- Alexander Wagner (1)
- Anneli Österman (1)
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

Autogenerated release notes updated last on 28 Sep 2023 18:27:32.
