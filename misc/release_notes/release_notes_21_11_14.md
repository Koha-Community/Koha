# RELEASE NOTES FOR KOHA 21.11.14
22 Nov 2022

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 21.11.14 can be downloaded from:

- [Download](http://download.koha-community.org/koha-21.11.14.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 21.11.14 is a bugfix/maintenance release with security fixes.

It includes 1 security fixes, 4 enhancements, 46 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations


## Security bugs

### Koha

- [[31219]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31219) Patron attribute types not cleaned/checked


## Enhancements

### Architecture, internals, and plumbing

- [[29955]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29955) Move C4::Acquisition::populate_order_with_prices to Koha::Acquisition::Order

### Cataloging

- [[31250]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31250) Don't remove advanced/basic cataloging editor cookie on logout

### Command-line Utilities

- [[31342]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31342) process_message_queue can run over the top of itself causing double-up emails

  **Sponsored by** *ByWater Solutions*

### OPAC

- [[31605]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31605) Improve style of OPAC suggestions search form


## Critical bugs fixed

### Cataloging

- [[31234]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31234) SubfieldsToAllowForRestrictedEditing : data from drop-down menu not stored
- [[31818]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31818) Advanced editor doesn't show keyboard shortcuts

### Circulation

- [[28553]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28553) Patrons can be set to receive auto_renew notices as SMS, but Koha does not generate them

### Installation and upgrade (command-line installer)

- [[32110]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32110) Duplicated additional content entries on DBRev 210600016

### Patrons

- [[31421]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31421) Library limitation on patron category breaks patron search
- [[31497]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31497) Quick add: mandatory fields save as empty when not filled in before first save attempt

### System Administration

- [[31364]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31364) Saving multi-select system preference don't save when all checks are removed

### Templates

- [[31558]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31558) Upgrade of TinyMCE broke image drag and drop

### Tools

- [[31154]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31154) Batch item modification fails when "Use default values" is checked

  **Sponsored by** *Koha-Suomi Oy*


## Other bugs fixed

### Acquisitions

- [[27550]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27550) "Duplicate budget" does not keep users associated with the funds

  >Users linked to funds in acquisitions will now be kept when a budget and fund structure is duplicated.
- [[29658]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29658) Crash on cancelling cancelled order
- [[30359]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30359) GetBudgetHierarchy is slow on order receive page
- [[31367]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31367) Display of sub-funds does not include totals of sub-sub-funds on acquisitions home page

### Architecture, internals, and plumbing

- [[28167]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28167) A warning when setting which library to use in intranet and UseCashRegisters is disabled
- [[30262]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30262) opac/tracklinks.pl inconsistent with GetMarcUrls for whitespace

### Cataloging

- [[31646]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31646) Focus input by default when clicking on a dropdown field in the cataloguing editor
- [[31863]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31863) Advanced cataloging editor no longer auto-resizes

### Circulation

- [[26626]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26626) When checking in a hold that is not found the X option is 'ignore' and when hold is found it is 'cancel'

### Command-line Utilities

- [[31239]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31239) search_for_data_inconsistencies.pl fails for Koha to MARC mapping using biblio table
- [[31299]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31299) Duplicate output in search_for_data_inconsistencies.pl
- [[31356]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31356) Itiva outbound script doesn't respect calendar when calculating expiration date for holds

### Database

- [[30483]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30483) Do not allow NULL in issues.borrowernumber and issues.itemnumber

### Documentation

- [[31465]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31465) Link system preference tabs to correct manual pages

### Fines and fees

- [[31513]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31513) NaN errors when using refund and payout with CurrencyFormat = FR

### Hold requests

- [[31518]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31518) Hidden items count not displayed on hold request page

### ILL

- [[30890]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30890) ILL breadcrumbs are wrong

### Notices

- [[29409]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29409) Update for bug 25333 can fail due to bad data or constraints

### OPAC

- [[29603]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29603) Fix responsive behavior of facets menu in OPAC search results
- [[30231]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30231) Don't display (rejected) forms of series entry in search results
- [[31527]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31527) Breadcrumbs for anonymous suggestions are not correct
- [[31531]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31531) Some modules loaded twice in opac-memberentry.pl

### Patrons

- [[31486]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31486) Deleting a message from checkouts tab redirects to detail tab in patron account

  >This patch corrects a problem where message deletion was improperly redirecting to the patron delete page when a message is deleted on the circulation page.
- [[31516]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31516) Missing error handling for accessing deleted/non-existent club enrollment

  >This adds an error message when viewing enrollments for a non-existent club. Previously, a page with an empty title and table were displayed.
- [[31562]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31562) Patron 'flags' don't respect unwanted fields

### Searching - Elasticsearch

- [[25375]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25375) Elasticsearch: Limit on available items does not work
- [[31023]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31023) Cannot create new GENRE/FORM authorities when  QueryRegexEscapeOptions  set to 'Unescape escaped'

### Self checkout

- [[31488]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31488) Rephrase "You have checked out too many items" to be friendlier

### Serials

- [[29608]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29608) Editing numbering patterns does require full serials permission

### Staff interface

- [[31565]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31565) Patron search filter by category code with special character returns no results

### System Administration

- [[31401]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31401) Update administration sidebar to match entries on administration start page

### Templates

- [[31379]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31379) Change results per page text for default
- [[31542]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31542) Home page links wrong font-family

### Test Suite

- [[31598]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31598) Fix random failure on Jenkins for t/db_dependent/Upload.t

### Tools

- [[28290]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28290) Record matching rules with no subfields cause ISE
- [[31482]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31482) Label creator does not call barcodedecode
- [[31564]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31564) Pass start label when exporting single label as PDF



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/21.11/ar/html/) (33.8%)
- [Chinese (Taiwan)](https://koha-community.org/manual/21.11/zh_TW/html/) (58.8%)
- [Czech](https://koha-community.org/manual/21.11/cs/html/) (27.2%)
- [English (USA)](https://koha-community.org/manual/21.11/en/html/)
- [French](https://koha-community.org/manual/21.11/fr/html/) (68.8%)
- [French (Canada)](https://koha-community.org/manual/21.11/fr_CA/html/) (25.6%)
- [German](https://koha-community.org/manual/21.11/de/html/) (73.3%)
- [Hindi](https://koha-community.org/manual/21.11/hi/html/) (100%)
- [Italian](https://koha-community.org/manual/21.11/it/html/) (48.2%)
- [Spanish](https://koha-community.org/manual/21.11/es/html/) (36.1%)
- [Turkish](https://koha-community.org/manual/21.11/tr/html/) (39.6%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (86.7%)
- Armenian (100%)
- Armenian (Classical) (89%)
- Bulgarian (100%)
- Chinese (Taiwan) (78.8%)
- Czech (76.9%)
- English (New Zealand) (60.2%)
- English (USA)
- Finnish (98.8%)
- French (95.5%)
- French (Canada) (92.1%)
- German (100%)
- German (Switzerland) (58.3%)
- Greek (60.4%)
- Hindi (100%)
- Italian (100%)
- Nederlands-Nederland (Dutch-The Netherlands) (86.6%)
- Norwegian Bokmål (62.7%)
- Polish (100%)
- Portuguese (91%)
- Portuguese (Brazil) (83.1%)
- Russian (84.2%)
- Slovak (74.6%)
- Spanish (100%)
- Swedish (81.5%)
- Telugu (94.4%)
- Turkish (98.9%)
- Ukrainian (75.3%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 21.11.14 is


- Release Manager: Jonathan Druart

- Release Manager assistants:
  - Martin Renvoize
  - Tomás Cohen Arazi

- QA Manager: Katrin Fischer

- QA Team:
  - Agustín Moyano
  - Andrew Nugged
  - David Cook
  - Joonas Kylmälä
  - Julian Maurice
  - Kyle M Hall
  - Marcel de Rooy
  - Martin Renvoize
  - Nick Clemens
  - Petro Vashchuk
  - Tomás Cohen Arazi
  - Victor Grousset

- Topic Experts:
  - UI Design -- Owen Leonard
  - REST API -- Tomás Cohen Arazi
  - Elasticsearch -- Fridolin Somers
  - Zebra -- Fridolin Somers
  - Accounts -- Martin Renvoize

- Bug Wranglers:
  - Sally Healey

- Packaging Manager: 


- Documentation Manager: David Nind


- Documentation Team:
  - David Nind
  - Lucy Vaux-Harvey

- Translation Managers: 
  - Bernardo González Kriegel

- Wiki curators: 
  - Thomas Dukleth

- Release Maintainers:
  - 21.05 -- Kyle M Hall
  - 20.11 -- Fridolin Somers
  - 20.05 -- Victor Grousset
  - 19.11 -- Wainui Witika-Park

- Release Maintainer assistants:
  - 21.05 -- Nick Clemens

- Release Maintainer mentors:
  - 19.11 -- Aleisha Amohia

## Credits
We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 21.11.14

- [ByWater Solutions](https://bywatersolutions.com)
- Koha-Suomi Oy

We thank the following individuals who contributed patches to Koha 21.11.14

- Tomás Cohen Arazi (4)
- Philippe Blouin (1)
- Jeremy Breuillard (1)
- Nick Clemens (21)
- David Cook (3)
- Jonathan Druart (5)
- Katrin Fischer (2)
- Lucas Gass (3)
- Isobel Graham (3)
- Kyle M Hall (3)
- Janusz Kaczmarek (1)
- Joonas Kylmälä (5)
- Owen Leonard (4)
- Julian Maurice (5)
- Martin Renvoize (2)
- Marcel de Rooy (10)
- Fridolin Somers (5)
- Arthur Suzuki (8)
- Emmi Takkinen (1)
- Lari Taskula (1)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 21.11.14

- Athens County Public Libraries (4)
- BibLibre (19)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (2)
- ByWater-Solutions (27)
- Hypernova Oy (1)
- Independant Individuals (9)
- Koha Community Developers (5)
- Koha-Suomi (1)
- Prosentient Systems (3)
- PTFS-Europe (2)
- Rijksmuseum (10)
- Solutions inLibro inc (1)
- Theke Solutions (4)

We also especially thank the following individuals who tested patches
for Koha

- Aleisha Amohia (1)
- Tomás Cohen Arazi (74)
- Philippe Blouin (1)
- Nick Clemens (9)
- David Cook (1)
- Chris Cormack (2)
- Jonathan Druart (2)
- Magnus Enger (1)
- Katrin Fischer (20)
- Andrew Fuerste-Henry (5)
- Lucas Gass (79)
- Kyle M Hall (8)
- Samu Heiskanen (1)
- Mark Hofstetter (1)
- Barbara Johnson (2)
- Joonas Kylmälä (17)
- Owen Leonard (5)
- David Nind (23)
- Liz Rea (1)
- Martin Renvoize (13)
- Marcel de Rooy (5)
- Michaela Sieber (2)
- Fridolin Somers (2)
- Arthur Suzuki (80)
- George Williams (1)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 21.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 22 Nov 2022 09:35:42.
