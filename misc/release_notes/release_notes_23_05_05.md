# RELEASE NOTES FOR KOHA 23.05.05
08 Nov 2023

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 23.05.05 can be downloaded from:

- [Download](http://download.koha-community.org/koha-23.05.05.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 23.05.05 is a bugfix/maintenance release.

It includes 16 enhancements, 85 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


## Bugfixes

### About

#### Other bugs fixed

- [34800](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34800) Update contributor openhub links

### Acquisitions

#### Critical bugs fixed

- [34645](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34645) Add missing fields to MarcItemFieldsToOrder system preference

#### Other bugs fixed

- [32676](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32676) EDI message status uses varying case, breaking EDI status block
- [34917](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34917) Fix suggestions.tt table default sort column

### Architecture, internals, and plumbing

#### Critical bugs fixed

- [32305](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32305) Background worker doesn't check job status when received from rabbitmq
- [34204](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34204) Koha user needs to be able to login
- [34959](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34959) Translator tool generates too many changes
- [35014](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35014) Times should only be set for enable-time flatpickrs
- [35111](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35111) Background jobs worker crashes on SIGPIPE when database connection lost in Ubuntu 22.04
- [35199](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35199) Fix error handling in http-client.js

#### Other bugs fixed

- [34271](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34271) Remove a few Logger statements from REST API
- [34885](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34885) Improve confusing pref description for OPACHoldsIfAvailableAtPickup
- [34912](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34912) Account(s).t tests fail in UTC+1 and higher
- [34916](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34916) ArticleRequests.t may fail on wrong borrowernumber
- [34918](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34918) Koha/Items.t crashes on missing borrower 42 or 51
- [34930](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34930) Fix timezone problem in Koha/Object.t
- [34932](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34932) A missing manager (51) failed my patron test
- [34982](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34982) Administration currencies table not showing pagination
- [34990](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34990) Backgroundjob->enqueue does not send persistent header
- [35000](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35000) OPACMandatoryHoldDates does not work well with flatpickr
- [35024](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35024) Do not wrap PO files
- [35064](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35064) Syntax error in db_revs/220600072.pl

### Cataloging

#### Critical bugs fixed

- [34014](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34014) There is no way to fix records with broken MARCXML

#### Other bugs fixed

- [34171](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34171) item_barcode_transform does not work when moving items
- [34549](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34549) The cataloguing editor allows you to input invalid data
  >This fixes entering data when cataloguing so that non-XML characters are removed. Non-XML characters (such as ESC) were causing adding and editing data to fail, with errors similar to:
  >  Error: invalid data, cannot decode metadata object
  >  parser error : PCDATA invalid Char value 27
- [34689](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34689) Add and duplicate item - Error 500
- [34794](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34794) Typo in recalls_to_pull.tt
- [35101](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35101) Clicking the barcode.pl plugin causes screen to jump back to top

### Circulation

#### Critical bugs fixed

- [27249](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27249) Using the calendar to 'close' a library can create an infinite loop during renewals

#### Other bugs fixed

- [34722](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34722) All items display as recalled when an item-level recall is made

  **Sponsored by** *Toi Ohomai Institute of Technology*

### ERM

#### Critical bugs fixed

- [33606](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33606) Access to ERM requires parameters => 'manage_sysprefs'

#### Other bugs fixed

- [34804](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34804) Translation fixes - ERM

### Fines and fees

#### Critical bugs fixed

- [35015](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35015) Regression: Charges table no longer filters out paid transactions

### Hold requests

#### Other bugs fixed

- [33074](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33074) ReservesControlBranch not taken into account in opac-reserve.pl
- [34901](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34901) Item-level holds can show inaccurate transit status on the patron details page
- [35069](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35069) Items needed column on circ/reserveratios.pl does not sort properly

### I18N/L10N

#### Other bugs fixed

- [34801](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34801) Fix incorrect use of __() in .tt and .inc files (bug 34038 follow-up)
- [34833](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34833) "order number" untranslatable when editing estimated delivery date
- [34870](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34870) Unrecognized special characters when writing off an invoice with a note
  >This fixes the display of UTF-8 characters for write off notes under a patron's accounting section. Previously, if you added a note when writing off multiple charges ([Patron] > Accounting > Make a payment > Payment note column > + Add note), a note with special characters (for example, éçö) did not display correctly.
- [35081](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35081) "Your concern was sucessfully submitted." untranslatable

### Installation and upgrade (command-line installer)

#### Critical bugs fixed

- [34881](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34881) Database update for bug 28854 isn't fully idempotent

### Installation and upgrade (web-based installer)

#### Critical bugs fixed

- [34520](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34520) Database update 22.06.00.078 breaks update process

#### Other bugs fixed

- [34558](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34558) Update custom.sql for it-IT webinstaller

### OPAC

#### Critical bugs fixed

- [34836](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34836) OPAC ISBD or MARC view blows up with error 500
  >This fixes an error that occurs when viewing the MARC and ISBD views of a record in the OPAC (when not logged in) - the detail pages cannot be viewed and there is an error trace displayed.

#### Other bugs fixed

- [34923](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34923) OPAC hold page flatpickr does not allow direct input of dates
- [34934](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34934) Remove the use of event attributes from OPAC lists page
- [34936](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34936) Remove the use of event attributes from OPAC detail page
- [34944](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34944) Remove the use of event attributes from OPAC full serial issue page
- [34945](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34945) Remove the use of event attributes from OPAC clubs tab
- [34946](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34946) Remove the use of event attributes from self checkout and check-in
- [34961](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34961) RSS feed link in OPAC is missing sort parameter
  >This fixes two RSS links in the OPAC search results template so that they include the correct parameters, including the descending sort by acquisition date.
- [34980](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34980) Remove the use of event attributes from title-actions-menu.inc in OPAC
- [35006](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35006) OPAC holdings table - sort for current library column doesn't work
  >This fixes the holdings table on the OPAC's bibliographic detail
  >page so that home and current library columns are sorted correctly by
  >library name.

### Patrons

#### Other bugs fixed

- [33395](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33395) Patron search results shows only overdues if patron has overdues
- [34462](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34462) Bug 25299 seems to have been reintroduced in more recent versions.
  >This fixes the display of the card expiration message on a patron's page so that it now includes the date that their card will expire.
- [34531](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34531) Hiding Lost card flag and Gone no address flag via BorrowerUnwantedFields hides Patron restrictions
- [34883](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34883) Regression in Patron Import dateexpiry function
- [34891](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34891) View restrictions button (patrons page) doesn't link to tab
- [35127](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35127) Patron search ignores searchtype from the context menu

### Plugin architecture

#### Other bugs fixed

- [35148](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35148) before_send_messages plugin hook does not pass the --where option

### REST API

#### Critical bugs fixed

- [35167](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35167) GET /items* broken if notforloan == 0 and itemtype.notforloan == NULL

#### Other bugs fixed

- [35053](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35053) Item-level rules not checked if both item_id and biblio_id are passed

### Reports

#### Other bugs fixed

- [34859](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34859) reports-home.pl has unnecessary syspref template parameters

### SIP2

#### Other bugs fixed

- [22873](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22873) C4::SIP::ILS::Transation::FeePayment->pay $disallow_overpayment does nothing

### Staff interface

#### Other bugs fixed

- [34921](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34921) Tabs on Additional Content page need space above
- [35019](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35019) Can't delete news from the staff interface main page

### Templates

#### Critical bugs fixed

- [35110](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35110) Authorities editor with JS error when only one tab

#### Other bugs fixed

- [34119](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34119) Improve staff interface print stylesheet following redesign
- [34443](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34443) Spelling: Patron search pop-up Sort1: should be Sort 1:
- [34781](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34781) Add a span tag around GDPR text in opac-memberentry
- [34942](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34942) Typo: brower
  >This fixes a typo in a message used in the advanced cataloguing editor when macros are converted from being stored in the browser to being stored in the database - 'brower' to 'browser'.
- [35010](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35010) In record checkout history should not show anonymous patron link
- [35055](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35055) Don't export actions column from patron search results
- [35072](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35072) Invalid usage of "&amp;" in JavaScript intranet-tmpl script redirects
- [35124](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35124) Incorrect item groups table markup

### Test Suite

#### Critical bugs fixed

- [34911](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34911) Test suite no longer run test critic

#### Other bugs fixed

- [34489](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34489) Koha/Patrons.t: Subtests get_age and is_valid_age do not pass in another timezone
- [34967](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34967) Move Prices.t to t/db_dependent
- [34968](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34968) t/Search.t does not do anything with Test::DBIx::Class
- [34969](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34969) t/Search/buildQuery.t does not do anything with Test::DBIx::Class
- [34970](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34970) t/SuggestionEngine_AuthorityFile.t does not do anything with Test::DBIx::Class
- [35042](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35042) Members.t: should not set datelastseen to NULL everywhere

### Tools

#### Other bugs fixed

- [34822](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34822) BatchUpdateBiblioHoldsQueue should be called once per import batch when using RealTimeHoldsQueue
- [34939](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34939) When manually entering dates in flatPickr the hour and minute get set to 00:00 not 23:59

### Web services

#### Other bugs fixed

- [34467](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34467) OAI GetRecord bad encoding for UNIMARC

## Enhancements 

### Acquisitions

#### Enhancements

- [26994](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26994) Display list of names in alphabetical order when using the Suggestion information filter in Suggestions management
- [34908](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34908) Sort item types alphabetically by description rather than code when adding a new empty record as an order to a basket

  **Sponsored by** *South Taranaki District Council*

### Architecture, internals, and plumbing

#### Enhancements

- [34825](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34825) Move Letters.t to t/db_dependent
- [34887](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34887) Merge Patron.t into t/db/Koha/Patron.t
- [34983](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34983) Retranslating causes changes in locale_data.json

### Authentication

#### Enhancements

- [30843](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30843) TOTP expiration delay should be configurable

### Circulation

#### Enhancements

- [34457](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34457) Add card number to hold details page

### ILL

#### Enhancements

- [35105](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35105) ILL - Saving 'Edit request' form with invalid Patron ID causes ILL table to not render

### OPAC

#### Enhancements

- [33819](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33819) Accessibility: More description required in OPAC search breadcrumbs

### Patrons

#### Enhancements

- [26558](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26558) Guarantor information is lost when an error occurs during new account creation

  **Sponsored by** *Koha-Suomi Oy*
- [34511](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34511) Typo in manage_staged_records permission description
  >This patch corrects a typo in the description of the manage_staged_records permission.

### Staff interface

#### Enhancements

- [33169](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33169) Improve vue breadcrumbs and left-hand menu

### Templates

#### Enhancements

- [34446](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34446) Typo: Can be guarantee
- [34679](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34679) Description for RELTERMS authorized value category is wrong
  >This patch changes the description of the RELTERMS authorized value category to "List of relator codes and terms".

### Tools

#### Enhancements

- [26978](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26978) Add item type criteria to batch extend due date tool
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

- Arabic (70.8%)
- Armenian (100%)
- Armenian (Classical) (63.7%)
- Bulgarian (93.3%)
- Chinese (Taiwan) (100%)
- Czech (57.8%)
- English (New Zealand) (67.6%)
- English (USA)
- Finnish (100%)
- French (99.7%)
- French (Canada) (100%)
- German (100%)
- Hindi (100%)
- Italian (90.7%)
- Nederlands-Nederland (Dutch-The Netherlands) (82.6%)
- Norwegian Bokmål (77.1%)
- Persian (99.4%)
- Polish (100%)
- Portuguese (89.5%)
- Portuguese (Brazil) (100%)
- Russian (97.2%)
- Slovak (61%)
- Spanish (100%)
- Swedish (83.7%)
- Telugu (75.9%)
- Turkish (85.8%)
- Ukrainian (78.7%)
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

The release team for Koha 23.05.05 is


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
new features in Koha 23.05.05
<div style="column-count: 2;">

- [Koha-Suomi Oy](https://koha-suomi.fi)
- South Taranaki District Council
- Toi Ohomai Institute of Technology
</div>

We thank the following individuals who contributed patches to Koha 23.05.05
<div style="column-count: 2;">

- Aleisha Amohia (3)
- Pedro Amorim (3)
- Tomás Cohen Arazi (9)
- Matt Blenkinsop (9)
- Philippe Blouin (1)
- Nick Clemens (9)
- David Cook (5)
- Frédéric Demians (1)
- Jonathan Druart (10)
- emilyrose (2)
- Laura Escamilla (2)
- Katrin Fischer (6)
- Emily-Rose Francoeur (1)
- Lucas Gass (5)
- Victor Grousset (1)
- Kyle M Hall (3)
- Michał Kula (1)
- Emily Lamancusa (2)
- Owen Leonard (16)
- Julian Maurice (6)
- Agustín Moyano (1)
- David Nind (3)
- Jacob O'Mara (1)
- Martin Renvoize (1)
- Marcel de Rooy (28)
- Caroline Cyr La Rose (2)
- Fridolin Somers (7)
- Zeno Tajoli (1)
- Emmi Takkinen (1)
- Koha translators (1)
- Hinemoea Viault (1)
- Shi Yao Wang (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 23.05.05
<div style="column-count: 2;">

- Athens County Public Libraries (16)
- BibLibre (13)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (6)
- ByWater-Solutions (19)
- Catalyst Open Source Academy (3)
- Cineca (1)
- David Nind (3)
- Independant Individuals (1)
- Koha Community Developers (11)
- Koha-Suomi (1)
- montgomerycountymd.gov (2)
- Prosentient Systems (5)
- PTFS-Europe (13)
- Rijksmuseum (28)
- Solutions inLibro inc (8)
- Tamil (1)
- Theke Solutions (10)
- users.noreply.github.com (1)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Aleisha Amohia (1)
- Pedro Amorim (3)
- Tomás Cohen Arazi (124)
- Matt Blenkinsop (2)
- Nick Clemens (10)
- Rebecca Coert (1)
- David Cook (1)
- Chris Cormack (2)
- Jonathan Druart (7)
- Laura Escamilla (1)
- Katrin Fischer (51)
- Andrew Fuerste-Henry (2)
- Lucas Gass (13)
- Victor Grousset (12)
- Kyle M Hall (3)
- Katariina Hanhisalo (1)
- hebah (1)
- Barbara Johnson (4)
- Kristi Krueger (1)
- Tuomas Kunttu (1)
- Emily Lamancusa (3)
- Sam Lau (4)
- Owen Leonard (9)
- Kelly McElligott (6)
- David Nind (35)
- Martin Renvoize (19)
- Marcel de Rooy (23)
- Caroline Cyr La Rose (1)
- Michaela Sieber (1)
- Fridolin Somers (133)
- Jessie Zairo (1)
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

Autogenerated release notes updated last on 08 Nov 2023 06:37:18.
