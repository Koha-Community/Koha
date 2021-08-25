# RELEASE NOTES FOR KOHA 19.11.21
25 Aug 2021

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 19.11.21 can be downloaded from:

- [Download](http://download.koha-community.org/koha-19.11.21.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 19.11.21 is a bugfix/maintenance release with security fixes.

It includes 1 security fixes, 2 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations


## Security bugs

### Koha

- [[28784]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28784) DoS in opac-search.pl causes OOM situation and 100% CPU (doesn't require login!)




## Critical bugs fixed

### Tools

- [[28675]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28675) QOTD broken in 20.11 and below


## Other bugs fixed

### OPAC

- [[28518]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28518) "Return to the last advanced search" exclude keywords if more than 3



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/19.11/ar/html/) (42.4%)
- [Chinese (Taiwan)](https://koha-community.org/manual/19.11/zh_TW/html/) (90.1%)
- [Czech](https://koha-community.org/manual/19.11/cs/html/) (33.4%)
- [English (USA)](https://koha-community.org/manual/19.11/en/html/)
- [French](https://koha-community.org/manual/19.11/fr/html/) (69.1%)
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
- Portuguese (100%)
- Portuguese (Brazil) (99.9%)
- Slovak (83%)
- Spanish (99.9%)
- Swedish (85%)
- Telugu (100%)
- Turkish (100%)
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

The release team for Koha 19.11.21 is

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

We thank the following individuals who contributed patches to Koha 19.11.21

- Nick Clemens (1)
- Jonathan Druart (3)
- Marcel de Rooy (1)
- Koha translators (1)
- Wainui Witika-Park (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 19.11.21

- ByWater-Solutions (1)
- Catalyst (1)
- Koha Community Developers (3)
- Rijks Museum (1)

We also especially thank the following individuals who tested patches
for Koha

- Tomás Cohen Arazi (2)
- Nick Clemens (2)
- Katrin Fischer (1)
- Victor Grousset (5)
- Kyle M Hall (1)
- Owen Leonard (2)
- David Nind (1)
- Marcel de Rooy (2)
- Fridolin Somers (1)
- Wainui Witika-Park (5)



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

Autogenerated release notes updated last on 25 Aug 2021 00:48:48.
