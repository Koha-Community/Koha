# RELEASE NOTES FOR KOHA 21.05.01
24 Jun 2021

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 21.05.01 can be downloaded from:

- [Download](http://download.koha-community.org/koha-21.05.01.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 21.05.01 is a bugfix/maintenance release.

It includes 2 enhancements, 23 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations




## Enhancements

### Architecture, internals, and plumbing

- [[28519]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28519) Add a 2nd directory for Perl modules

### REST API

- [[27931]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27931) Add GET /items/:item_id/pickup_locations

  >This development adds routes for fetching an item's valid pickup location list.


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[24434]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24434) C4::Circulation::updateWrongTransfer is never called but should be

### Authentication

- [[28489]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28489) CGI::Session is incorrectly serialized to DB in production env / when strict_sql_modes = 0

### Circulation

- [[28538]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28538) Regression - Date of birth entered without correct format causes internal server error

### Fines and fees

- [[28482]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28482) Floating point math prevents items from being returned

### Hold requests

- [[28338]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28338) Validate item holdability and pickup location separately
- [[28496]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28496) Club holds form broken

  >This fixes the libraries shown in the 'Pickup at' dropdown list when placing a club hold so that it shows all libraries, instead of just the currently logged in library.
- [[28503]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28503) When ReservesControlBranch = "patron's home library" and Hold policy = "From home library" all holds are allowed
- [[28520]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28520) Cancelling a hold that is in transit hides item's transit status

### Notices

- [[28487]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28487) Overdue_notices does not fall back to default language

  >Previously overdue notices exclusively used the default language, but bug 26420 changed this to the opposite - to exclusively use the language chosen by the patron.
  >
  >However, if there is no translation for the overdue notice for the language chosen by the patron then no message is sent.
  >
  >This fixes this so that if there is no translation of the overdue notice for the language chosen by the patron, then the default language notice is used.

### OPAC

- [[28600]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28600) Variable "$patron" is not available

### Packaging

- [[28616]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28616) Remove Data::Printer dependency

### Patrons

- [[28490]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28490) Cannot modify patrons in some categories (e.g. Child category)

### REST API

- [[28586]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28586) Cannot resolve a claim

  >This fixes an issue with the 'Returned claims' feature (enabled by setting a value for ClaimReturnedLostValue)- resolving returned claims now works as expected.
  >
  >Before this fix, an attempt to resolve a claim resulted in the page hanging and the claim not being able to be resolved.


## Other bugs fixed

### Cataloging

- [[28171]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28171) Serial enumeration / chronology sorting is broken in biblio page
- [[28204]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28204) Table highlighting is broken at the cataloguing/additem.pl
- [[28383]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28383) Log in via the itemsearch URL leads to Internal Server Error

  >When trying to access the item search form in the staff interface (/cgi-bin/koha/catalogue/itemsearch.pl) when not logged in, an internal server error (error code 500) is received after entering your login details. This fixes the problem so that the item search form is displayed as expected.

### Circulation

- [[27064]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27064) Transferring an item with a hold allows the user to set a hold waiting without transferring to the correct branch
- [[28382]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28382) 'Reserve' should be passed through as transfer reason appropriately in branchtransfers

### OPAC

- [[28518]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28518) "Return to the last advanced search" exclude keywords if more than 3

### Patrons

- [[28350]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28350) Sort by "circ note" is broken on the patron search result view

  >This fixes the patron search result page so that the results can be sorted using the 'Circ note' column. Before this fix you could not sort the results by this column.

### Self checkout

- [[28488]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28488) Javascript error in self-checkout (__ is not defined)

### Staff Client

- [[28467]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28467) Add wording to TrackLastPatronActivity description to tell users that it records SIP authentication

  >This improves the wording for the TrackLastPatronActivity system preference to reflect that the 'last seen' date updates when a patron logs into the OPAC or connects using SIP.

### Tools

- [[28353]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28353) Regression: Batch item deletion no longer shows which items were not removed

  >This restores and improves the messages displayed when batch deleting items (Tools > Catalog > Batch item deletion).
  >
  >The messages displayed are:
  >- "Warning, the following barcodes were not found:", followed by a list of barcodes
  >- "Warning, the following items cannot be deleted:", followed by a list of barcodes



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/21.05/ar/html/) (34.3%)
- [Chinese (Taiwan)](https://koha-community.org/manual/21.05/zh_TW/html/) (58.5%)
- [Czech](https://koha-community.org/manual/21.05/cs/html/) (27.6%)
- [English (USA)](https://koha-community.org/manual/21.05/en/html/)
- [French](https://koha-community.org/manual/21.05/fr/html/) (47.2%)
- [French (Canada)](https://koha-community.org/manual/21.05/fr_CA/html/) (25.2%)
- [German](https://koha-community.org/manual/21.05/de/html/) (67.2%)
- [Hindi](https://koha-community.org/manual/21.05/hi/html/) (98.2%)
- [Italian](https://koha-community.org/manual/21.05/it/html/) (47.8%)
- [Spanish](https://koha-community.org/manual/21.05/es/html/) (34.8%)
- [Turkish](https://koha-community.org/manual/21.05/tr/html/) (40.3%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (91.2%)
- Armenian (100%)
- Armenian (Classical) (89%)
- Chinese (Taiwan) (81.6%)
- Czech (70.1%)
- English (New Zealand) (62.2%)
- English (USA)
- Finnish (80.9%)
- French (84.6%)
- French (Canada) (83.5%)
- German (100%)
- German (Switzerland) (61.4%)
- Greek (54.9%)
- Hindi (100%)
- Italian (92.8%)
- Nederlands-Nederland (Dutch-The Netherlands) (62.5%)
- Norwegian Bokmål (58.2%)
- Polish (86%)
- Portuguese (79.9%)
- Portuguese (Brazil) (87.8%)
- Russian (87%)
- Slovak (73.6%)
- Spanish (91.7%)
- Swedish (77.4%)
- Telugu (99.9%)
- Turkish (93.8%)
- Ukrainian (61.9%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 21.05.01 is


- Release Manager: Jonathan Druart

- Release Manager assistants:
  - Martin Renvoize
  - Tomás Cohen Arazi

- QA Manager: Katrin Fischer

- QA Team:
  - David Cook
  - Agustín Moyano
  - Martin Renvoize
  - Marcel de Rooy
  - Joonas Kylmälä
  - Julian Maurice
  - Tomás Cohen Arazi
  - Josef Moravec
  - Nick Clemens
  - Kyle M Hall
  - Victor Grousset
  - Andrew Nugged
  - Petro Vashchuk

- Topic Experts:
  - UI Design -- Owen Leonard
  - REST API -- Tomás Cohen Arazi
  - Elasticsearch -- Fridolin Somers
  - Zebra -- Fridolin Somers
  - Accounts -- Martin Renvoize

- Bug Wranglers:
  - Sally Healey

- Packaging Manager:
  - Mason James

- Documentation Manager: David Nind


- Documentation Team:
  - Lucy Vaux-Harvey
  - David Nind

- Translation Managers: 
  - Bernardo González Kriegel

- Release Maintainers:
  - 21.05 -- Kyle Hall
  - 20.11 -- Fridolin Somers
  - 20.05 -- Victor Grousset
  - 19.11 -- Wainui Witika-Park

## Credits

We thank the following individuals who contributed patches to Koha 21.05.01

- Tomás Cohen Arazi (9)
- Nick Clemens (9)
- David Cook (2)
- Jonathan Druart (16)
- Katrin Fischer (1)
- Andrew Fuerste-Henry (1)
- Kyle M Hall (1)
- Joonas Kylmälä (17)
- Owen Leonard (1)
- Julian Maurice (2)
- Andrew Nugged (1)
- Martin Renvoize (9)
- Alexis Ripetti (1)
- Koha translators (1)
- Petro Vashchuk (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 21.05.01

- Athens County Public Libraries (1)
- BibLibre (2)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (1)
- ByWater-Solutions (11)
- Independant Individuals (2)
- Koha Community Developers (16)
- Prosentient Systems (2)
- PTFS-Europe (9)
- Solutions inLibro inc (1)
- Theke Solutions (9)
- University of Helsinki (17)

We also especially thank the following individuals who tested patches
for Koha

- Tomás Cohen Arazi (5)
- Nick Clemens (28)
- David Cook (5)
- Jonathan Druart (46)
- Katrin Fischer (7)
- Andrew Fuerste-Henry (5)
- Victor Grousset (7)
- Kyle M Hall (71)
- Joonas Kylmälä (5)
- Owen Leonard (3)
- Christian Nelson (2)
- David Nind (13)
- Andrew Nugged (2)
- Martin Renvoize (14)
- Marcel de Rooy (1)
- Emmi Takkinen (8)
- Petro Vashchuk (10)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 21.05.X.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 24 Jun 2021 16:41:01.
