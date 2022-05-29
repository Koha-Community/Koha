# RELEASE NOTES FOR KOHA 21.05.15
29 May 2022

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 21.05.15 can be downloaded from:

- [Download](http://download.koha-community.org/koha-21.05.15.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 21.05.15 is a bugfix/maintenance release.

It includes 1 enhancements, 6 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations




## Enhancements

### Templates

- [[30212]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30212) Make Select2 available for ILL backend developers


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[30540]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30540) Double processing invalid dates can lead to ISE

### Fines and fees

- [[30346]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30346) Editing circ rule with Overdue fines cap (amount) results in data loss and extra fines

### Searching

- [[29374]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29374) searchResults explodes if biblio record has been deleted

### Self checkout

- [[30199]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30199) self checkout login by cardnumber is broken if you input a non-existent cardnumber

### Tools

- [[30518]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30518) StockRotationItems crossing DST boundary throw invalid local time exception


## Other bugs fixed

### Test Suite

- [[30595]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30595) update_child_to_adult.t is failing randomly



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/21.05/ar/html/) (34.3%)
- [Chinese (Taiwan)](https://koha-community.org/manual/21.05/zh_TW/html/) (59%)
- [Czech](https://koha-community.org/manual/21.05/cs/html/) (27.6%)
- [English (USA)](https://koha-community.org/manual/21.05/en/html/)
- [French](https://koha-community.org/manual/21.05/fr/html/) (63.3%)
- [French (Canada)](https://koha-community.org/manual/21.05/fr_CA/html/) (25.5%)
- [German](https://koha-community.org/manual/21.05/de/html/) (73.5%)
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
- Chinese (Taiwan) (86.5%)
- Czech (70.9%)
- English (New Zealand) (61.1%)
- English (USA)
- Finnish (82%)
- French (93.2%)
- French (Canada) (98.8%)
- German (100%)
- German (Switzerland) (60.5%)
- Greek (55.3%)
- Hindi (100%)
- Italian (100%)
- Nederlands-Nederland (Dutch-The Netherlands) (61.4%)
- Norwegian Bokmål (65.4%)
- Polish (99.9%)
- Portuguese (91.1%)
- Portuguese (Brazil) (86.6%)
- Russian (86%)
- Slovak (72.4%)
- Spanish (100%)
- Swedish (76.5%)
- Telugu (99%)
- Turkish (100%)
- Ukrainian (77.4%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 21.05.15 is


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

We thank the following individuals who contributed patches to Koha 21.05.15

- Tomás Cohen Arazi (1)
- Nick Clemens (1)
- Jonathan Druart (3)
- Andrew Fuerste-Henry (3)
- Lucas Gass (1)
- Martin Renvoize (4)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 21.05.15

- ByWater-Solutions (5)
- Koha Community Developers (3)
- PTFS-Europe (4)
- Theke Solutions (1)

We also especially thank the following individuals who tested patches
for Koha

- Nick Clemens (4)
- Andrew Fuerste-Henry (11)
- Lucas Gass (1)
- Kyle M Hall (9)
- Martin Renvoize (3)
- Marcel de Rooy (3)
- Fridolin Somers (9)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is rmain2105.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 29 May 2022 16:25:28.
