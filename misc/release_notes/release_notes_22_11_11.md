# RELEASE NOTES FOR KOHA 22.11.11
07 Nov 2023

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 22.11.11 can be downloaded from:

- [Download](http://download.koha-community.org/koha-22.11.11.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 22.11.11 is a bugfix/maintenance release.

It includes 13 enhancements, 77 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [34513](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34513) Authenticated users can bypass permissions and view some privileged pages

## Bugfixes

### Acquisitions

#### Critical bugs fixed

- [34645](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34645) Add missing fields to MarcItemFieldsToOrder system preference

#### Other bugs fixed

- [32676](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32676) EDI message status uses varying case, breaking EDI status block
- [34917](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34917) Fix suggestions.tt table default sort column

### Architecture, internals, and plumbing

#### Critical bugs fixed

- [35014](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35014) Times should only be set for enable-time flatpickrs

#### Other bugs fixed

- [34656](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34656) CartToShelf should not trigger RealTimeHoldsQueue
- [34786](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34786) after_biblio_action hooks: find after delete makes no sense
- [34844](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34844) manage_item_editor_templates is missing from userpermissions.sql
- [34885](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34885) Improve confusing pref description for OPACHoldsIfAvailableAtPickup
- [34912](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34912) Account(s).t tests fail in UTC+1 and higher
- [34916](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34916) ArticleRequests.t may fail on wrong borrowernumber
- [34918](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34918) Koha/Items.t crashes on missing borrower 42 or 51
- [34930](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34930) Fix timezone problem in Koha/Object.t
- [34932](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34932) A missing manager (51) failed my patron test
- [34982](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34982) Administration currencies table not showing pagination

### Cataloging

#### Other bugs fixed

- [34549](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34549) The cataloguing editor allows you to input invalid data
  >This fixes entering data when cataloguing so that non-XML characters are removed. Non-XML characters (such as ESC) were causing adding and editing data to fail, with errors similar to:
  >  Error: invalid data, cannot decode metadata object
  >  parser error : PCDATA invalid Char value 27
- [34689](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34689) Add and duplicate item - Error 500
- [34794](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34794) Typo in recalls_to_pull.tt

### Circulation

#### Other bugs fixed

- [34302](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34302) Checkin and renewal error messages disappear immediately in checkouts table
- [34722](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34722) All items display as recalled when an item-level recall is made

  **Sponsored by** *Toi Ohomai Institute of Technology*

### Command-line Utilities

#### Critical bugs fixed

- [34764](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34764) sip_cli_emulator -fa/--fee_acknowledge does not act as expected

#### Other bugs fixed

- [34653](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34653) Make koha-foreach return the correct status code

### ERM

#### Other bugs fixed

- [34789](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34789) Fix typo in erm_eholdings_titles
- [34804](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34804) Translation fixes - ERM

### Fines and fees

#### Critical bugs fixed

- [35015](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35015) Regression: Charges table no longer filters out paid transactions

### I18N/L10N

#### Other bugs fixed

- [34833](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34833) "order number" untranslatable when editing estimated delivery date
- [34870](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34870) Unrecognized special characters when writing off an invoice with a note
  >This fixes the display of UTF-8 characters for write off notes under a patron's accounting section. Previously, if you added a note when writing off multiple charges ([Patron] > Accounting > Make a payment > Payment note column > + Add note), a note with special characters (for example, éçö) did not display correctly.

### Installation and upgrade (web-based installer)

#### Other bugs fixed

- [34558](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34558) Update custom.sql for it-IT webinstaller

### Label/patron card printing

#### Other bugs fixed

- [34532](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34532) Silence warns in Patroncard.pm when layout values are empty

### OPAC

#### Critical bugs fixed

- [34694](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34694) OPAC bib record blows up with error 500
- [34768](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34768) Can't pay fines on OPAC if patron has a guarantee and they can see their fines
- [34836](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34836) OPAC ISBD or MARC view blows up with error 500
  >This fixes an error that occurs when viewing the MARC and ISBD views of a record in the OPAC (when not logged in) - the detail pages cannot be viewed and there is an error trace displayed.

#### Other bugs fixed

- [34613](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34613) Remove onclick event attributes from Verovio midiplayer.js
- [34711](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34711) Remove use of onclick for opac-privacy.pl
- [34724](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34724) Remove use of onclick for opac-imageviewer.pl
- [34725](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34725) Remove use of onclick for OPAC cart
- [34730](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34730) Add responsive behavior to more tables in the OPAC
- [34760](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34760) Prevent error when logging into OPAC after conducting a search

  **Sponsored by** *Toi Ohomai Institute of Technology*
- [34923](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34923) OPAC hold page flatpickr does not allow direct input of dates
- [34934](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34934) Remove the use of event attributes from OPAC lists page
- [34936](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34936) Remove the use of event attributes from OPAC detail page
- [34944](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34944) Remove the use of event attributes from OPAC full serial issue page
- [34945](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34945) Remove the use of event attributes from OPAC clubs tab
- [34961](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34961) RSS feed link in OPAC is missing sort parameter
  >This fixes two RSS links in the OPAC search results template so that they include the correct parameters, including the descending sort by acquisition date.

### Patrons

#### Other bugs fixed

- [33395](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33395) Patron search results shows only overdues if patron has overdues
- [34728](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34728) HTML notices should not be pre-formatted
- [34743](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34743) Incorrect POD in import_patrons.pl
- [34883](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34883) Regression in Patron Import dateexpiry function

### REST API

#### Other bugs fixed

- [32942](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32942) Suggestion API doesn't support custom statuses

### Reports

#### Other bugs fixed

- [34859](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34859) reports-home.pl has unnecessary syspref template parameters

### SIP2

#### Critical bugs fixed

- [34767](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34767) SIP2 fee acknowledgement flag on renewals is passed, but not used

#### Other bugs fixed

- [22873](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22873) C4::SIP::ILS::Transation::FeePayment->pay $disallow_overpayment does nothing

### Searching - Elasticsearch

#### Other bugs fixed

- [33406](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33406) Searching for authority with hyphen surrounded by spaces causes error 500 (with ES)
- [34740](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34740) Sort option are wrong in search engine configuration (Elasticsearch)

### Staff interface

#### Other bugs fixed

- [34921](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34921) Tabs on Additional Content page need space above

### System Administration

#### Other bugs fixed

- [34748](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34748) Wrong column name basket_number in table settings for basket

### Templates

#### Other bugs fixed

- [33734](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33734) Using custom search filters breaks diacritics characters in search term
- [34443](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34443) Spelling: Patron search pop-up Sort1: should be Sort 1:
- [34781](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34781) Add a span tag around GDPR text in opac-memberentry
- [34835](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34835) Highlight logged-in library in patron searches does not work anymore in new staff interface
- [34942](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34942) Typo: brower
  >This fixes a typo in a message used in the advanced cataloguing editor when macros are converted from being stored in the browser to being stored in the database - 'brower' to 'browser'.
- [35010](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35010) In record checkout history should not show anonymous patron link

### Test Suite

#### Critical bugs fixed

- [34911](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34911) Test suite no longer run test critic

#### Other bugs fixed

- [34489](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34489) Koha/Patrons.t: Subtests get_age and is_valid_age do not pass in another timezone
- [34843](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34843) Koha/Database/Commenter.t is failing if the DB has been upgraded
- [34846](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34846) SIP/ILS.t is failing if the DB has been upgraded
- [34847](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34847) Search.t is failing if the DB has been upgraded
- [34848](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34848) SIP/Message.t is failing if the DB has been upgraded
- [34967](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34967) Move Prices.t to t/db_dependent
- [34968](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34968) t/Search.t does not do anything with Test::DBIx::Class
- [34969](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34969) t/Search/buildQuery.t does not do anything with Test::DBIx::Class
- [34970](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34970) t/SuggestionEngine_AuthorityFile.t does not do anything with Test::DBIx::Class

### Tools

#### Other bugs fixed

- [32048](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32048) Calendar adding holidays repeated
- [34732](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34732) Barcode image generator doesn't generate correct Code39 barcode
- [34822](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34822) BatchUpdateBiblioHoldsQueue should be called once per import batch when using RealTimeHoldsQueue
- [34939](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34939) When manually entering dates in flatPickr the hour and minute get set to 00:00 not 23:59

### Web services

#### Other bugs fixed

- [34467](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34467) OAI GetRecord bad encoding for UNIMARC

## Enhancements 

### Architecture, internals, and plumbing

#### Enhancements

- [34787](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34787) Typo gorup
- [34825](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34825) Move Letters.t to t/db_dependent
- [34887](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34887) Merge Patron.t into t/db/Koha/Patron.t

### Authentication

#### Enhancements

- [30843](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30843) TOTP expiration delay should be configurable

### Circulation

#### Enhancements

- [33876](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33876) item-note-nonpublic and item-note-public are difficult to customize in the checkout table

### OPAC

#### Enhancements

- [33819](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33819) Accessibility: More description required in OPAC search breadcrumbs

### Patrons

#### Enhancements

- [34511](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34511) Typo in manage_staged_records permission description
  >This patch corrects a typo in the description of the manage_staged_records permission.
- [34719](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34719) Middle name doesn't show on autocomplete

### REST API

#### Enhancements

- [34054](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34054) Allow to embed biblio on GET /items

  **Sponsored by** *Bibliothèque Universitaire des Langues et Civilisations (BULAC)*
- [34333](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34333) Add cancellation request information embed option to the holds endpoint

### Templates

#### Enhancements

- [34446](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34446) Typo: Can be guarantee
- [34679](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34679) Description for RELTERMS authorized value category is wrong
  >This patch changes the description of the RELTERMS authorized value category to "List of relator codes and terms".

### Tools

#### Enhancements

- [34716](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34716) Typo in tools/stockrotation.tt

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

- Arabic (71.7%)
- Armenian (100%)
- Armenian (Classical) (64.5%)
- Bulgarian (93.3%)
- Chinese (Taiwan) (81.2%)
- Czech (62%)
- English (New Zealand) (68.1%)
- English (USA)
- English (United Kingdom) (99.9%)
- Finnish (96.9%)
- French (99.8%)
- French (Canada) (95.2%)
- German (100%)
- German (Switzerland) (50.1%)
- Greek (51.5%)
- Hindi (100%)
- Italian (91.7%)
- Nederlands-Nederland (Dutch-The Netherlands) (90.3%)
- Norwegian Bokmål (65.1%)
- Persian (70.1%)
- Polish (100%)
- Portuguese (89.6%)
- Portuguese (Brazil) (100%)
- Russian (93.2%)
- Slovak (61.7%)
- Spanish (100%)
- Swedish (84.9%)
- Telugu (76.9%)
- Turkish (86.9%)
- Ukrainian (77.7%)
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

The release team for Koha 22.11.11 is


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
new features in Koha 22.11.11
<div style="column-count: 2;">

- [Bibliothèque Universitaire des Langues et Civilisations (BULAC)](http://www.bulac.fr)
- Toi Ohomai Institute of Technology
</div>

We thank the following individuals who contributed patches to Koha 22.11.11
<div style="column-count: 2;">

- Aleisha Amohia (2)
- Pedro Amorim (4)
- Tomás Cohen Arazi (8)
- Matt Blenkinsop (20)
- Nick Clemens (10)
- David Cook (13)
- Frédéric Demians (2)
- Jonathan Druart (9)
- emilyrose (1)
- Laura Escamilla (2)
- Katrin Fischer (5)
- Lucas Gass (5)
- Evan Giles (1)
- Victor Grousset (2)
- Kyle M Hall (4)
- Janusz Kaczmarek (1)
- Emily Lamancusa (1)
- Owen Leonard (8)
- David Nind (2)
- Jacob O'Mara (2)
- Martin Renvoize (7)
- Marcel de Rooy (25)
- Caroline Cyr La Rose (2)
- Fridolin Somers (2)
- Arthur Suzuki (2)
- Zeno Tajoli (1)
- Koha translators (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 22.11.11
<div style="column-count: 2;">

- Athens County Public Libraries (8)
- BibLibre (4)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (5)
- ByWater-Solutions (21)
- Catalyst (1)
- Catalyst Open Source Academy (2)
- Cineca (1)
- David Nind (2)
- Independant Individuals (2)
- Koha Community Developers (11)
- montgomerycountymd.gov (1)
- Prosentient Systems (13)
- PTFS-Europe (32)
- Rijksmuseum (25)
- Solutions inLibro inc (3)
- Tamil (2)
- Theke Solutions (8)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Pedro Amorim (5)
- Tomás Cohen Arazi (127)
- Matt Blenkinsop (91)
- Nick Clemens (7)
- David Cook (2)
- Jonathan Druart (11)
- Laura Escamilla (2)
- Katrin Fischer (46)
- Andrew Fuerste-Henry (2)
- Lucas Gass (7)
- Salah Ghedda (3)
- Victor Grousset (9)
- Kyle M Hall (1)
- hebah (1)
- Kristi Krueger (1)
- Emily Lamancusa (3)
- Sam Lau (2)
- Owen Leonard (10)
- David Nind (27)
- Jacob O'Mara (31)
- Martin Renvoize (12)
- Marcel de Rooy (31)
- Caroline Cyr La Rose (1)
- Andreas Roussos (2)
- Michaela Sieber (1)
- Fridolin Somers (132)
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

Autogenerated release notes updated last on 07 Nov 2023 11:42:54.
