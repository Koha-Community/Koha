# RELEASE NOTES FOR KOHA 20.11.17
24 Mar 2022

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 20.11.17 can be downloaded from:

- [Download](https://download.koha-community.org/koha-20.11.17.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 20.11.17 is a bugfix/maintenance release.

It includes 8 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations






## Critical bugs fixed

### Fines and fees

- [[29385]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29385) Add missing cash register support to SIP2

### I18N/L10N

- [[29596]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29596) Add Yiddish language

  **Sponsored by** *Universidad Nacional de San Martín*

  >This enhancement adds the Yiddish (יידיש) language to Koha. Yiddish now appears as an option for refining search results in the staff interface advanced search (Search > Advanced search > More options > Language and Language of original) and the OPAC (Advanced search > More options > Language).

### Packaging

- [[29881]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29881) Remove SQLite2 dependency
- [[30084]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30084) Remove dependency of liblocale-codes-perl

### REST API

- [[29877]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29877) MaxReserves should be enforced consistently between staff interface and API

### SIP2

- [[29754]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29754) Patron fines counted twice for SIP when NoIssuesChargeGuarantorsWithGuarantees is enabled


## Other bugs fixed

### Test Suite

- [[29862]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29862) TestBuilder.t fails with ES enabled

### Tools

- [[29722]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29722) Add some diversity to sample quotes

  **Sponsored by** *Catalyst*

  >This patch adds sample quotes from women, women of colour, trans women, Black and Indigenous women, and people who weren't US Presidents!



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/20.11/ar/html/) (27%)
- [Chinese (Taiwan)](https://koha-community.org/manual/20.11/zh_TW/html/) (61.5%)
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
- Bulgarian (91.4%)
- Catalan; Valencian (57.6%)
- Chinese (Taiwan) (92.7%)
- Czech (72.9%)
- English (New Zealand) (59.2%)
- English (USA)
- Finnish (79%)
- French (92.2%)
- French (Canada) (91.7%)
- German (100%)
- German (Switzerland) (66.5%)
- Greek (61%)
- Hindi (100%)
- Italian (99.7%)
- Nederlands-Nederland (Dutch-The Netherlands) (94.2%)
- Norwegian Bokmål (63.4%)
- Polish (100%)
- Portuguese (91.2%)
- Portuguese (Brazil) (96.3%)
- Russian (93.2%)
- Slovak (80.1%)
- Spanish (99.7%)
- Swedish (74.7%)
- Telugu (99.6%)
- Turkish (100%)
- Ukrainian (70.5%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](https://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](https://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](https://translate.koha-community.org/)

## Release Team

The release team for Koha 20.11.17 is


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
We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 20.11.17

- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)
- Universidad Nacional de San Martín

We thank the following individuals who contributed patches to Koha 20.11.17

- Aleisha Amohia (1)
- Tomás Cohen Arazi (4)
- Nick Clemens (2)
- Jonathan Druart (2)
- Andrew Fuerste-Henry (1)
- Victor Grousset (3)
- Mason James (3)
- Fridolin Somers (1)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 20.11.17

- BibLibre (1)
- ByWater-Solutions (3)
- Catalyst Open Source Academy (1)
- Koha Community Developers (5)
- KohaAloha (3)
- Theke Solutions (4)

We also especially thank the following individuals who tested patches
for Koha

- Tomás Cohen Arazi (3)
- Jonathan Druart (2)
- Katrin Fischer (3)
- Andrew Fuerste-Henry (15)
- Lucas Gass (1)
- Victor Grousset (14)
- Kyle M Hall (14)
- David Nind (1)
- Martin Renvoize (6)
- Fridolin Somers (10)



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

Autogenerated release notes updated last on 24 Mar 2022 02:05:13.
