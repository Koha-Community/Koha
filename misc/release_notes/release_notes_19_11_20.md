# RELEASE NOTES FOR KOHA 19.11.20
22 Jul 2021

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 19.11.20 can be downloaded from:

- [Download](http://download.koha-community.org/koha-19.11.20.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 19.11.20 is a bugfix/maintenance release.

It includes 1 enhancements, 9 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations




## Enhancements

### Architecture, internals, and plumbing

- [[28386]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28386) Replace dev_map.yaml from release_tools with .mailmap


## Critical bugs fixed

### Fines and fees

- [[28482]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28482) Floating point math prevents items from being returned

### Notices

- [[28487]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28487) Overdue_notices does not fall back to default language

  >Previously overdue notices exclusively used the default language, but bug 26420 changed this to the opposite - to exclusively use the language chosen by the patron.
  >
  >However, if there is no translation for the overdue notice for the language chosen by the patron then no message is sent.
  >
  >This fixes this so that if there is no translation of the overdue notice for the language chosen by the patron, then the default language notice is used.

### REST API

- [[23653]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23653) Plack fails when http://swagger.io/v2/schema.json is unavailable and schema cache missing
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

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/19.11/ar/html/) (42.4%)
- [Chinese (Taiwan)](https://koha-community.org/manual/19.11/zh_TW/html/) (90.1%)
- [Czech](https://koha-community.org/manual/19.11/cs/html/) (33.4%)
- [English (USA)](https://koha-community.org/manual/19.11/en/html/)
- [French](https://koha-community.org/manual/19.11/fr/html/) (69%)
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
- Basque (55.6%)
- Catalan; Valencian (50.5%)
- Chinese (China) (56.9%)
- Chinese (Taiwan) (98.6%)
- Czech (90.8%)
- English (New Zealand) (78.3%)
- English (USA)
- Finnish (74.2%)
- French (99.4%)
- French (Canada) (93.8%)
- German (100%)
- German (Switzerland) (80.8%)
- Greek (71.2%)
- Hindi (100%)
- Italian (87%)
- Nederlands-Nederland (Dutch-The Netherlands) (85.4%)
- Norwegian Bokmål (83.3%)
- Occitan (post 1500) (53%)
- Polish (85.6%)
- Portuguese (99.3%)
- Portuguese (Brazil) (99.9%)
- Slovak (83%)
- Spanish (99.9%)
- Swedish (85%)
- Telugu (99.9%)
- Turkish (99.9%)
- Ukrainian (75%)
- Vietnamese (51.5%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 19.11.20 is


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

We thank the following individuals who contributed patches to Koha 19.11.20

- Tomás Cohen Arazi (3)
- Eden Bacani (1)
- Nick Clemens (2)
- David Cook (1)
- Jonathan Druart (23)
- Mason James (1)
- Martin Renvoize (4)
- Koha translators (1)
- Wainui Witika-Park (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 19.11.20

- ByWater-Solutions (2)
- Catalyst (1)
- Independant Individuals (5)
- Koha Community Developers (19)
- KohaAloha (1)
- Prosentient Systems (1)
- PTFS-Europe (4)
- Theke Solutions (3)

We also especially thank the following individuals who tested patches
for Koha

- Tomás Cohen Arazi (2)
- Nick Clemens (3)
- Jonathan Druart (10)
- Magnus Enger (1)
- Katrin Fischer (2)
- Andrew Fuerste-Henry (2)
- Victor Grousset (33)
- Kyle M Hall (8)
- Owen Leonard (2)
- David Nind (2)
- Martin Renvoize (14)
- Marcel de Rooy (2)
- Fridolin Somers (28)
- Wainui Witika-Park (36)



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

Autogenerated release notes updated last on 22 Jul 2021 11:25:33.
