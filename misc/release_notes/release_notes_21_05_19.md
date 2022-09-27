# RELEASE NOTES FOR KOHA 21.05.19
27 Sep 2022

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 21.05.19 can be downloaded from:

- [Download](https://download.koha-community.org/koha-21.05.19.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 21.05.19 is a bugfix/maintenance release.

It includes 8 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations






## Critical bugs fixed

### Acquisitions

- [[14680]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14680) When creating orders from a staged file discounts supplied in the form are added

### Circulation

- [[29051]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29051) Seen renewal methods incorrectly blocked

### Command-line Utilities

- [[30308]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30308) bulkmarcimport.pl broken by OAI-PMH:AutoUpdateSets(EmbedItemData)

### Packaging

- [[30209]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30209) Upgrade 'libdbd-sqlite2-perl' package to 'libdbd-sqlite3-perl'

### Searching - Elasticsearch

- [[28610]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28610) Elasticsearch 7 - hits.total is now an object

  **Sponsored by** *Lund University Library*

  >This is one of the changes to have Koha compatible with ElasticSearch 7. This one also causes the full end of compatibility with ElasticSearch 5. Users are advised to upgrade as soon as possible to ElasticSearch 7 since version 5 and 6 are not supported anymore by their developers.

### Staff Client

- [[31138]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31138) DataTables is not raising error to the end user


## Other bugs fixed

### Architecture, internals, and plumbing

- [[31473]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31473) Test about bad OpacHiddenItems conf fragile

### Reports

- [[27045]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27045) Exports using CSV profiles with tab as separator don't work correctly



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/21.05/ar/html/) (34.3%)
- [Chinese (Taiwan)](https://koha-community.org/manual/21.05/zh_TW/html/) (59.9%)
- [Czech](https://koha-community.org/manual/21.05/cs/html/) (27.6%)
- [English (USA)](https://koha-community.org/manual/21.05/en/html/)
- [French](https://koha-community.org/manual/21.05/fr/html/) (68.3%)
- [French (Canada)](https://koha-community.org/manual/21.05/fr_CA/html/) (26%)
- [German](https://koha-community.org/manual/21.05/de/html/) (75%)
- [Hindi](https://koha-community.org/manual/21.05/hi/html/) (100%)
- [Italian](https://koha-community.org/manual/21.05/it/html/) (48.9%)
- [Spanish](https://koha-community.org/manual/21.05/es/html/) (37%)
- [Turkish](https://koha-community.org/manual/21.05/tr/html/) (40.3%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (89.3%)
- Armenian (100%)
- Armenian (Classical) (89%)
- Chinese (Taiwan) (91.1%)
- Czech (70.9%)
- English (New Zealand) (61.1%)
- English (USA)
- Finnish (82.1%)
- French (93.5%)
- French (Canada) (98.8%)
- German (100%)
- German (Switzerland) (60.5%)
- Greek (55.3%)
- Hindi (100%)
- Italian (100%)
- Nederlands-Nederland (Dutch-The Netherlands) (61.3%)
- Norwegian Bokmål (65.4%)
- Polish (100%)
- Portuguese (91.1%)
- Portuguese (Brazil) (86.6%)
- Russian (86%)
- Slovak (72.7%)
- Spanish (100%)
- Swedish (76.5%)
- Telugu (99%)
- Turkish (100%)
- Ukrainian (78.1%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](https://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](https://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](https://translate.koha-community.org/)

## Release Team

The release team for Koha 21.05.19 is


- Release Manager: Tomás Cohen Arazi

- Release Manager assistants:
  - Jonathan Druart
  - Martin Renvoize

- QA Manager: Katrin Fischer

- QA Team:
  - Aleisha Amohia
  - Nick Clemens
  - Jonathan Druart
  - Lucas Gass
  - Victor Grousset
  - Kyle M Hall
  - Joonas Kylmälä
  - Andrew Nugged
  - Martin Renvoize
  - Marcel de Rooy
  - Fridolin Somers
  - Petro Vashchuk
  - David Cook

- Topic Experts:
  - UI Design -- Owen Leonard
  - Zebra -- Fridolin Somers

- Bug Wranglers:
  - Aleisha Amohia
  - Jake Deery
  - Lucas Gass
  - Séverine Queune

- Packaging Manager: Mason James


- Documentation Manager: David Nind


- Documentation Team:
  - Donna Bachowski
  - Aude Charillon
  - Martin Renvoize
  - Lucy Vaux-Harvey

- Translation Managers: 
  - Bernardo González Kriegel

- Wiki curators: 
  - Thomas Dukleth
  - Katrin Fischer

- Release Maintainers:
  - 22.05 -- Lucas Gass
  - 21.11 -- Arthur Suzuki
  - 21.05 -- Victor Grousset

## Credits
We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 21.05.19

- Lund University Library

We thank the following individuals who contributed patches to Koha 21.05.19

- Tomás Cohen Arazi (1)
- Kevin Carnes (1)
- Nick Clemens (1)
- Frédéric Demians (1)
- Jonathan Druart (3)
- Katrin Fischer (1)
- Victor Grousset (2)
- Mason James (1)
- Martin Renvoize (2)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 21.05.19

- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (1)
- ByWater-Solutions (1)
- Koha Community Developers (5)
- KohaAloha (1)
- PTFS-Europe (2)
- Tamil (1)
- Theke Solutions (1)
- ub.lu.se (1)

We also especially thank the following individuals who tested patches
for Koha

- Tomás Cohen Arazi (8)
- Caroline (2)
- Nick Clemens (4)
- Katrin Fischer (3)
- Lucas Gass (8)
- Victor Grousset (11)
- Kyle M Hall (5)
- Julian Maurice (1)
- Kelly McElligott (1)
- David Nind (1)
- Martin Renvoize (1)
- Fridolin Somers (2)
- Arthur Suzuki (8)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 21.05.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 27 Sep 2022 12:10:18.
