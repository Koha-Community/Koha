# RELEASE NOTES FOR KOHA 20.11.13
24 Dec 2021

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 20.11.13 can be downloaded from:

- [Download](https://download.koha-community.org/koha-20.11.13.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 20.11.13 is a bugfix/maintenance release.

It includes 2 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations






## Critical bugs fixed

### Architecture, internals, and plumbing

- [[29330]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29330) Koha cannot send emails with attachments using Koha::Email and message_queue table

### Fines and fees

- [[27801]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27801) Entering multiple lines of an item in Point of Sale can make the Collect Payment field off

  >This fixes the POS transactions page so that the total for the sale and the amount to collect are the same.
  >
  >Before this a POS transaction with multiple items in the Sale box, say for example 9 x .10 items, the total in the Sale box appears correct, but the amount to Collect from Patron is off by a cent.



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/20.11/ar/html/) (27%)
- [Chinese (Taiwan)](https://koha-community.org/manual/20.11/zh_TW/html/) (61.4%)
- [English (USA)](https://koha-community.org/manual/20.11/en/html/)
- [French](https://koha-community.org/manual/20.11/fr/html/) (52.7%)
- [French (Canada)](https://koha-community.org/manual/20.11/fr_CA/html/) (26%)
- [German](https://koha-community.org/manual/20.11/de/html/) (71.2%)
- [Hindi](https://koha-community.org/manual/20.11/hi/html/) (99.9%)
- [Italian](https://koha-community.org/manual/20.11/it/html/) (50%)
- [Spanish](https://koha-community.org/manual/20.11/es/html/) (36.5%)
- [Turkish](https://koha-community.org/manual/20.11/tr/html/) (41.9%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (99%)
- Armenian (100%)
- Armenian (Classical) (89%)
- Bulgarian (91.7%)
- Catalan; Valencian (57.6%)
- Chinese (Taiwan) (92.9%)
- Czech (73.2%)
- English (New Zealand) (59.4%)
- English (USA)
- Finnish (79.2%)
- French (91.7%)
- French (Canada) (91.9%)
- German (100%)
- German (Switzerland) (66.7%)
- Greek (60.5%)
- Hindi (100%)
- Italian (100%)
- Nederlands-Nederland (Dutch-The Netherlands) (94.1%)
- Norwegian Bokmål (63.6%)
- Polish (100%)
- Portuguese (88.4%)
- Portuguese (Brazil) (96.5%)
- Russian (93.5%)
- Slovak (80.3%)
- Spanish (100%)
- Swedish (75%)
- Telugu (99.9%)
- Turkish (99.9%)
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

The release team for Koha 20.11.13 is


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

- Packaging Manager: 


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

We thank the following individuals who contributed patches to Koha 20.11.13

- Tomás Cohen Arazi (3)
- Nick Clemens (5)
- Victor Grousset (5)
- Martin Renvoize (2)
- Marcel de Rooy (1)
- Koha translators (1)
- Petro Vashchuk (6)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 20.11.13

- ByWater-Solutions (5)
- Independant Individuals (6)
- Koha Community Developers (5)
- PTFS-Europe (2)
- Rijksmuseum (1)
- Theke Solutions (3)

We also especially thank the following individuals who tested patches
for Koha

- Tomás Cohen Arazi (1)
- Alex Buckley (6)
- Jonathan Druart (16)
- Andrew Fuerste-Henry (2)
- Victor Grousset (23)
- Kyle M Hall (17)
- David Nind (2)
- Martin Renvoize (17)
- Marcel de Rooy (3)
- Sally (1)
- Fridolin Somers (1)



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

Autogenerated release notes updated last on 24 Dec 2021 13:21:27.
