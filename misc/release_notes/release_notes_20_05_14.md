# RELEASE NOTES FOR KOHA 20.05.14
23 Jul 2021

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 20.05.14 can be downloaded from:

- [Download](https://download.koha-community.org/koha-20.05.14.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 20.05.14 is a bugfix/maintenance release.

It includes 6 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations






## Critical bugs fixed

### REST API

- [[28586]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28586) Cannot resolve a claim

  >This fixes an issue with the 'Returned claims' feature (enabled by setting a value for ClaimReturnedLostValue)- resolving returned claims now works as expected.
  >
  >Before this fix, an attempt to resolve a claim resulted in the page hanging and the claim not being able to be resolved.

### Reports

- [[28523]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28523) Patrons with the most checkouts (bor_issues_top.pl) is failing with MySQL 8
- [[28524]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28524) Most-circulated items (cat_issues_top.pl) is failing with MySQL 8


## Other bugs fixed

### About

- [[27495]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27495) The "Accessibility advocate" role is not yet listed in the about page.
- [[28442]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28442) Release team 21.11
- [[28476]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28476) Update info in docs/teams.yaml file



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/20.05/ar/html/) (43.3%)
- [Chinese (Taiwan)](https://koha-community.org/manual/20.05/zh_TW/html/) (100%)
- [Czech](https://koha-community.org/manual/20.05/cs/html/) (33.1%)
- [English (USA)](https://koha-community.org/manual/20.05/en/html/)
- [French](https://koha-community.org/manual/20.05/fr/html/) (69.9%)
- [French (Canada)](https://koha-community.org/manual/20.05/fr_CA/html/) (31.2%)
- [German](https://koha-community.org/manual/20.05/de/html/) (72.3%)
- [Hindi](https://koha-community.org/manual/20.05/hi/html/) (100%)
- [Italian](https://koha-community.org/manual/20.05/it/html/) (78.9%)
- [Spanish](https://koha-community.org/manual/20.05/es/html/) (58.5%)
- [Turkish](https://koha-community.org/manual/20.05/tr/html/) (70.2%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (98.2%)
- Armenian (100%)
- Armenian (Classical) (99.7%)
- Chinese (Taiwan) (93.9%)
- Czech (80.6%)
- English (New Zealand) (66.5%)
- English (USA)
- Finnish (70.2%)
- French (86.3%)
- French (Canada) (96.9%)
- German (100%)
- German (Switzerland) (74.2%)
- Greek (62.2%)
- Hindi (100%)
- Italian (100%)
- Norwegian Bokmål (70.8%)
- Polish (79.3%)
- Portuguese (86.3%)
- Portuguese (Brazil) (97.6%)
- Russian (86.1%)
- Slovak (89.4%)
- Spanish (99.6%)
- Swedish (79.2%)
- Telugu (99.8%)
- Turkish (99.9%)
- Ukrainian (66.1%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](https://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](https://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](https://translate.koha-community.org/)

## Release Team

The release team for Koha 20.05.14 is


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

- Packaging Manager: Mason James


- Documentation Manager: David Nind


- Documentation Team:
  - Lucy Vaux-Harvey
  - David Nind

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

We thank the following individuals who contributed patches to Koha 20.05.14

- Tomás Cohen Arazi (2)
- Eden Bacani (1)
- Jonathan Druart (2)
- Victor Grousset (2)
- Mason James (1)
- Martin Renvoize (4)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 20.05.14

- Independant Individuals (1)
- Koha Community Developers (4)
- KohaAloha (1)
- PTFS-Europe (4)
- Theke Solutions (2)

We also especially thank the following individuals who tested patches
for Koha

- Nick Clemens (2)
- Jonathan Druart (6)
- Magnus Enger (1)
- Andrew Fuerste-Henry (2)
- Victor Grousset (12)
- Kyle M Hall (7)
- Owen Leonard (2)
- David Nind (2)
- Martin Renvoize (1)
- Marcel de Rooy (2)
- Fridolin Somers (8)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 20.05.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 23 Jul 2021 22:28:34.
