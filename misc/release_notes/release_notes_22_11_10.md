# RELEASE NOTES FOR KOHA 22.11.10
28 Sep 2023

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 22.11.10 can be downloaded from:

- [Download](http://download.koha-community.org/koha-22.11.10.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 22.11.10 is a bugfix/maintenance release.

It includes 4 enhancements, 67 bugfixes.

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

- [34509](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34509) Cannot create baskets if too many vendors

#### Other bugs fixed

- [34095](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34095) Shipping cost should default to a blank box instead of 0.00
- [34445](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34445) Default budget is not selected in addorderiso2709.pl

### Architecture, internals, and plumbing

#### Other bugs fixed

- [30362](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30362) GetSoonestRenewDate is technically wrong when NoRenewalBeforePrecision set to date soonest renewal is today
- [34570](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34570) Remove use of onclick for PopupMARCFieldDoc()
- [34571](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34571) Remove use of onclick for ExpandField

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
- [34341](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34341) Revert Bug 34072: Holds queue search interface hidden on small screens
- [34572](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34572) Simplify template logic around check-in input form
- [34634](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34634) Expiration date does not display on reserve/request.pl if date is today or in the past

### Command-line Utilities

#### Other bugs fixed

- [31964](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31964) Missing manpage for koha-z3950-responder
  >This adds a man page for the `koha-z3950-responder` command-line utility, documenting all available options and parameters that can be used when running this command.
- [34505](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34505) Patron invalid age in search_for_data_inconsistencies.pl should skip expired patrons
- [34569](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34569) misc/cronjobs/holds/holds_reminder.pl problem with trigger arg

### ERM

#### Other bugs fixed

- [34219](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34219) getAll not allowing additional parameters
- [34465](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34465) "Actions" columns are sortable
- [34466](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34466) "Clear filter" always disabled

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

- [34592](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34592) The patron search window, given just a sort field value, doesn't work

### Lists

#### Other bugs fixed

- [34650](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34650) Editing/deleting lists from toolbar on virtualshelves/shelves.pl causes CSRF error

### Notices

#### Other bugs fixed

- [34583](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34583) Overdue notices: wrong encoding in e-mail in 'print' mode

### OPAC

#### Other bugs fixed

- [27496](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27496) Accessibility: Navigation buttons are poorly described by screen readers
- [29578](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29578) Search term highlighting breaks with titles containing characters with Greek diacritics
  >This fixes an issue with the term highlighter which is used during catalog searches in both the OPAC and the Staff interface. Under certain conditions (searching for titles containing characters with Greek diacritics), the jQuery term highlighter would break and in the process make the "Highlight" / "Unhighlight" button disappear altogether. UNIMARC instances were affected the most by this.
- [34522](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34522) Suggestion for purchase displays wrong library in OPAC display if patron suggests for non-home library
- [34627](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34627) Fix CMS page HTML structure so that footer content is displayed correctly
- [34641](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34641) Novelist content does not display on OPAC detail page if NovelistSelectView is set to below
- [34723](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34723) opac-imageviewer.pl not showing thumbnails

### Patrons

#### Other bugs fixed

- [34356](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34356) Enabling RecordStaffUserOnCheckout causes bad default sorting in checkout history

### Reports

#### Other bugs fixed

- [34552](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34552) No Results when filtering "All payments to the library" or "payment" in Statistics wizards : Cash register

### SIP2

#### Other bugs fixed

- [23548](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23548) AQ field required in checkin response
  >This fixes SIP return messages so that there is an "AQ|" field, even if it is empty (this is a required field according to the specification, and some machines (such as PV-SUPA) crash if it is not present).

### Serials

#### Critical bugs fixed

- [30451](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30451) Delete a subscription deletes the linked order
  >When an order had been created using the 'from a subscription' option and the subscription was deleted, the order line would be deleted with it, independent of its status or age. This caused problems with funds and budgets. With this patch, we will unlink order line and subscription on delete, but the order line will remain.

### Templates

#### Other bugs fixed

- [34038](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34038) Fix incorrect use of __() in .tt and .inc files
- [34066](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34066) Datatable options don't fully translate on list of saved reports
- [34115](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34115) Use a global tab select function for activating Bootstrap tabs based on location hash
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

### Tools

#### Critical bugs fixed

- [34617](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34617) Patron expiration dates not updated during import when there is no dateexpiry column in the file

#### Other bugs fixed

- [22135](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22135) Inventory tool doesn't export "out of order" problem to CSV
  >This fixes the export of inventory results when "Check barcodes list for items shelved out of order" is selected. Currently, the problem column is blank for items shelved out of order when it should be "Shelved out of order".

## Enhancements 

### ERM

#### Enhancements

- [34448](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34448) ERM should be able to display error messages coming from the API

### REST API

#### Enhancements

- [34313](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34313) Make password validation endpoint return patron IDs

### Staff interface

#### Enhancements

- [33316](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33316) Improve display of ES indexer jobs

### Templates

#### Enhancements

- [34345](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34345) 'Circulation and fine rules' vs 'Circulation and fines rules'

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Chinese (Taiwan)](https://koha-community.org/manual/22.11/zh_TW/html/) (71.5%)
- [English (USA)](https://koha-community.org/manual/22.11/en/html/)
- [French](https://koha-community.org/manual/22.11/fr/html/) (58.6%)
- [German](https://koha-community.org/manual/22.11/de/html/) (59.4%)
- [Hindi](https://koha-community.org/manual/22.11/hi/html/) (82.2%)
- [Italian](https://koha-community.org/manual/22.11/it/html/) (32.2%)
- [Turkish](https://koha-community.org/manual/22.11/tr/html/) (26.2%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (71.8%)
- Armenian (100%)
- Armenian (Classical) (64.6%)
- Bulgarian (90.8%)
- Chinese (Taiwan) (81.3%)
- Czech (62%)
- English (New Zealand) (68.1%)
- English (USA)
- English (United Kingdom) (100%)
- Finnish (97%)
- French (99.9%)
- French (Canada) (95.3%)
- German (100%)
- German (Switzerland) (50.1%)
- Greek (51.6%)
- Hindi (100%)
- Italian (91.7%)
- Nederlands-Nederland (Dutch-The Netherlands) (90.3%)
- Norwegian Bokmål (65.1%)
- Persian (70.2%)
- Polish (100%)
- Portuguese (89.6%)
- Portuguese (Brazil) (100%)
- Russian (93.3%)
- Slovak (61.7%)
- Spanish (99.8%)
- Swedish (81.5%)
- Telugu (77%)
- Turkish (87%)
- Ukrainian (77.8%)
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

The release team for Koha 22.11.10 is


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



We thank the following individuals who contributed patches to Koha 22.11.10
<div style="column-count: 2;">

- Pedro Amorim (9)
- Tomás Cohen Arazi (5)
- Matt Blenkinsop (10)
- Kevin Carnes (1)
- Nick Clemens (14)
- David Cook (17)
- Jonathan Druart (7)
- Laura Escamilla (2)
- Katrin Fischer (4)
- Lucas Gass (7)
- Victor Grousset (2)
- Michael Hafen (1)
- Per Larsson (1)
- Owen Leonard (18)
- Julian Maurice (3)
- Matthias Meusburger (1)
- Martin Renvoize (3)
- Caroline Cyr La Rose (2)
- Andreas Roussos (2)
- Fridolin Somers (3)
- Petr Svoboda (1)
- Koha translators (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 22.11.10
<div style="column-count: 2;">

- Athens County Public Libraries (18)
- BibLibre (7)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (4)
- ByWater-Solutions (23)
- Dataly Tech (2)
- Göteborgs Universitet (1)
- Independant Individuals (1)
- Koha Community Developers (9)
- Prosentient Systems (17)
- PTFS-Europe (22)
- R-Bit Technology (1)
- Solutions inLibro inc (2)
- Theke Solutions (5)
- ub.lu.se (1)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Aleisha Amohia (1)
- Pedro Amorim (7)
- Andrew (2)
- Tomás Cohen Arazi (96)
- Matt Blenkinsop (106)
- Christopher Brannon (1)
- Christine (1)
- Nick Clemens (5)
- David Cook (3)
- Chris Cormack (3)
- Ray Delahunty (1)
- Michal Denar (1)
- Jonathan Druart (12)
- Laura Escamilla (3)
- Katrin Fischer (35)
- Lucas Gass (8)
- Nicolas Giraud (1)
- Victor Grousset (9)
- Kyle M Hall (6)
- Inkeri (1)
- Jason (1)
- joubu (2)
- Sam Lau (10)
- Owen Leonard (9)
- Christian Nelson (1)
- David Nind (14)
- Martin Renvoize (7)
- Marcel de Rooy (30)
- Caroline Cyr La Rose (5)
- Fridolin Somers (89)
- Anneli Österman (1)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 22.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 28 Sep 2023 11:29:06.
