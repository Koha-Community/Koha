# RELEASE NOTES FOR KOHA 20.11.18
26 Apr 2022

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 20.11.18 can be downloaded from:

- [Download](https://download.koha-community.org/koha-20.11.18.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 20.11.18 is a bugfix/maintenance release.

It includes 6 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations






## Critical bugs fixed

### Architecture, internals, and plumbing

- [[30172]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30172) Background jobs failing due to race condition

### Patrons

- [[28943]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28943) Lower the risk of accidental patron deletion by cleanup_database.pl

  >If you use self registration but you do not use a temporary self registration patron category,
  >you should actually clear the preference
  >PatronSelfRegistrationExpireTemporaryAccountsDelay.

### Test Suite

- [[19169]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19169) Add a test to detect unneeded 'atomicupdate' files


## Other bugs fixed

### Architecture, internals, and plumbing

- [[30296]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30296) Correct path for cookie bibs_selected

### Cataloging

- [[26328]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26328) incremental barcode generation fails when incorrectly converting strings to numbers

### Patrons

- [[22993]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22993) Messaging preferences not set for patrons imported through API



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/20.11/ar/html/) (27%)
- [Chinese (Taiwan)](https://koha-community.org/manual/20.11/zh_TW/html/) (61.6%)
- [English (USA)](https://koha-community.org/manual/20.11/en/html/)
- [French](https://koha-community.org/manual/20.11/fr/html/) (58.7%)
- [French (Canada)](https://koha-community.org/manual/20.11/fr_CA/html/) (26%)
- [German](https://koha-community.org/manual/20.11/de/html/) (71.2%)
- [Hindi](https://koha-community.org/manual/20.11/hi/html/) (99.9%)
- [Italian](https://koha-community.org/manual/20.11/it/html/) (50.1%)
- [Spanish](https://koha-community.org/manual/20.11/es/html/) (36.5%)
- [Turkish](https://koha-community.org/manual/20.11/tr/html/) (41.9%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (98.6%)
- Armenian (100%)
- Armenian (Classical) (89%)
- Bulgarian (91.3%)
- Catalan; Valencian (57.6%)
- Chinese (Taiwan) (92.8%)
- Czech (72.9%)
- English (New Zealand) (59.2%)
- English (USA)
- Finnish (78.9%)
- French (92.2%)
- French (Canada) (91.7%)
- German (100%)
- German (Switzerland) (66.5%)
- Greek (60.9%)
- Hindi (99.9%)
- Italian (100%)
- Nederlands-Nederland (Dutch-The Netherlands) (94.1%)
- Norwegian Bokmål (63.4%)
- Polish (99.9%)
- Portuguese (91.1%)
- Portuguese (Brazil) (96.2%)
- Russian (93.1%)
- Slovak (80.1%)
- Spanish (99.8%)
- Swedish (74.7%)
- Telugu (99.5%)
- Turkish (100%)
- Ukrainian (70.4%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](https://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](https://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](https://translate.koha-community.org/)

## Release Team

The release team for Koha 20.11.18 is


- Release Manager: Fridolin Somers

- Release Manager assistants:
  - Jonathan Druart
  - Martin Renvoize
  - Tomás Cohen Arazi

- QA Manager: Katrin Fischer

- QA Team:
  - Andrew Nugged
  - Jonathan Druart
  - Joonas Kylmälä
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
  - Zebra -- Fridolin Somers
  - Accounts -- Martin Renvoize

- Bug Wranglers:
  - Indranil Das Gupta
  - Erica Rohlfs

- Packaging Manager: Mason James


- Documentation Manager: David Nind


- Documentation Team:
  - Aude Charillon
  - Caroline Cyr La Rose
  - Kelly McElligott
  - Lucy Vaux-Harvey
  - Martin Renvoize
  - Rocio Lopez

- Translation Managers: 
  - Bernardo González Kriegel

- Wiki curators: 
  - Thomas Dukleth

- Release Maintainers:
  - 21.11 -- Kyle M Hall
  - 21.05 -- Andrew Fuerste-Henry
  - 20.11 -- Victor Grousset
  - 19.11 -- Wainui Witika-Park

## Credits

We thank the following individuals who contributed patches to Koha 20.11.18

- Nick Clemens (2)
- David Cook (1)
- Jonathan Druart (4)
- Victor Grousset (2)
- Mason James (1)
- Marcel de Rooy (1)
- Fridolin Somers (1)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 20.11.18

- BibLibre (1)
- ByWater-Solutions (2)
- Koha Community Developers (6)
- KohaAloha (1)
- Prosentient Systems (1)
- Rijksmuseum (1)

We also especially thank the following individuals who tested patches
for Koha

- Tomás Cohen Arazi (4)
- Nick Clemens (2)
- Jonathan Druart (2)
- Katrin Fischer (1)
- Andrew Fuerste-Henry (11)
- Victor Grousset (10)
- Kyle M Hall (7)
- Marjorie (1)
- David Nind (1)
- Martin Renvoize (4)
- Marcel de Rooy (1)
- Fridolin Somers (6)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 20.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 26 Apr 2022 02:11:19.
