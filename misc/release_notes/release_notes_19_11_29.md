# RELEASE NOTES FOR KOHA 19.11.29
26 Apr 2022

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 19.11.29 can be downloaded from:

- [Download](http://download.koha-community.org/koha-19.11.29.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 19.11.29 is a bugfix/maintenance release.

It includes 3 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations






## Critical bugs fixed

### Patrons

- [[28943]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28943) Lower the risk of accidental patron deletion by cleanup_database.pl

  >If you use self registration but you do not use a temporary self registration patron category,
  >you should actually clear the preference
  >PatronSelfRegistrationExpireTemporaryAccountsDelay.

### Test Suite

- [[19169]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19169) Add a test to detect unneeded 'atomicupdate' files


## Other bugs fixed

### Cataloging

- [[26328]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26328) incremental barcode generation fails when incorrectly converting strings to numbers



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/19.11/ar/html/) (42.4%)
- [Chinese (Taiwan)](https://koha-community.org/manual/19.11/zh_TW/html/) (90.1%)
- [Czech](https://koha-community.org/manual/19.11/cs/html/) (33.4%)
- [English (USA)](https://koha-community.org/manual/19.11/en/html/)
- [French](https://koha-community.org/manual/19.11/fr/html/) (72.1%)
- [French (Canada)](https://koha-community.org/manual/19.11/fr_CA/html/) (29.2%)
- [German](https://koha-community.org/manual/19.11/de/html/) (49.5%)
- [Hindi](https://koha-community.org/manual/19.11/hi/html/) (100%)
- [Italian](https://koha-community.org/manual/19.11/it/html/) (67.7%)
- [Spanish](https://koha-community.org/manual/19.11/es/html/) (46.4%)
- [Turkish](https://koha-community.org/manual/19.11/tr/html/) (71.3%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (97.9%)
- Armenian (100%)
- Armenian (Classical) (100%)
- Basque (55.7%)
- Catalan; Valencian (50.6%)
- Chinese (China) (57%)
- Chinese (Taiwan) (98.9%)
- Czech (90.8%)
- English (New Zealand) (78.4%)
- English (USA)
- Finnish (74.4%)
- French (100%)
- French (Canada) (94%)
- German (100%)
- German (Switzerland) (80.9%)
- Greek (73.1%)
- Hindi (100%)
- Italian (87.2%)
- Nederlands-Nederland (Dutch-The Netherlands) (85.3%)
- Norwegian Bokmål (83.4%)
- Occitan (post 1500) (53.1%)
- Persian (74.7%)
- Polish (85.9%)
- Portuguese (100%)
- Portuguese (Brazil) (100%)
- Slovak (83.2%)
- Spanish (100%)
- Swedish (85.4%)
- Telugu (100%)
- Tetun (52.9%)
- Turkish (100%)
- Ukrainian (75%)
- Vietnamese (51.6%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 19.11.29 is


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

We thank the following individuals who contributed patches to Koha 19.11.29

- David Cook (1)
- Chris Cormack (2)
- Jonathan Druart (1)
- Mason James (1)
- Marcel de Rooy (1)
- Fridolin Somers (1)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 19.11.29

- BibLibre (1)
- Catalyst (2)
- Koha Community Developers (1)
- KohaAloha (1)
- Prosentient Systems (1)
- Rijksmuseum (1)

We also especially thank the following individuals who tested patches
for Koha

- Chris Cormack (5)
- Jonathan Druart (2)
- Katrin Fischer (1)
- Marjorie (1)
- David Nind (1)
- Martin Renvoize (1)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 19.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 26 Apr 2022 21:36:27.
