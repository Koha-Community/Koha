# RELEASE NOTES FOR KOHA 21.11.20
11 May 2023

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 21.11.20 can be downloaded from:

- [Download](http://download.koha-community.org/koha-21.11.20.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 21.11.20 is a bugfix/maintenance release.

It includes 20 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations






## Critical bugs fixed

### Architecture, internals, and plumbing

- [[33183]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33183) Error inserting matchpoint_components when creating record matching rules with MariaDB 10.6
- [[33309]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33309) Race condition while checkout renewal with ES

### Cataloging

- [[30966]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30966) Record overlay rules - can't use Z39.50 filter

  **Sponsored by** *Koha-Suomi Oy*
- [[33100]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33100) Authority linking doesn't work for bib headings ending in two or more punctuation characters

### Label/patron card printing

- [[31259]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31259) Downloading patron card PDF hangs the server


## Other bugs fixed

### Architecture, internals, and plumbing

- [[33211]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33211) Fix failing test for basic_workflow.t when adding item
- [[33341]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33341) Perl 5.36 doesn't consider some of our code cool

### Cataloging

- [[33144]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33144) Authority lookup in advanced editor overencodes HTML

### Command-line Utilities

- [[33285]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33285) It should be possible to specify the separator used in runreport.pl

### Hold requests

- [[33198]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33198) request.pl is calculating pickup locations that are not used

### I18N/L10N

- [[33151]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33151) Improve translation of strings in cities and circulation desk administration pages

### ILL

- [[28641]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28641) ILLHiddenRequestStatuses does not consider custom statuses

  **Sponsored by** *PTFS Europe*

### MARC Authority data support

- [[32279]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32279) GetAuthorizedHeading missing from exports of C4::AuthoritiesMarc
- [[32280]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32280) Export method ImportBreedingAuth from C4::Breeding

### Packaging

- [[33168]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33168) Timeline on "About Koha" is not working for package installs

### Reports

- [[33063]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33063) Duplicated reports should maintain subgroup of original

### Searching

- [[13976]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13976) Sorting search results by popularity is alphabetical

  >This patch fixes the sorting of searches by popularity, ensuring that results are sorted numerically.
  >
  >Note: The popularity search requires the use of either the syspref UpdateTotalIssuesOnCirc or the update_totalissue.pl cronjob

### Searching - Elasticsearch

- [[32519]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32519) In Elasticsearch mappings table use search field name

### Self checkout

- [[33150]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33150) Add specific message for renewal too_soon situation

### Templates

- [[33137]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33137) Make sure columns on transactions and 'pay fines' tab are matching up



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/21.11/ar/html/) (33.8%)
- [Chinese (Taiwan)](https://koha-community.org/manual/21.11/zh_TW/html/) (58.8%)
- [Czech](https://koha-community.org/manual/21.11/cs/html/) (27.2%)
- [English (USA)](https://koha-community.org/manual/21.11/en/html/)
- [French](https://koha-community.org/manual/21.11/fr/html/) (70.9%)
- [French (Canada)](https://koha-community.org/manual/21.11/fr_CA/html/) (25.6%)
- [German](https://koha-community.org/manual/21.11/de/html/) (73.3%)
- [Hindi](https://koha-community.org/manual/21.11/hi/html/) (100%)
- [Italian](https://koha-community.org/manual/21.11/it/html/) (48.2%)
- [Spanish](https://koha-community.org/manual/21.11/es/html/) (36.1%)
- [Turkish](https://koha-community.org/manual/21.11/tr/html/) (39.6%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (86.4%)
- Armenian (100%)
- Armenian (Classical) (89%)
- Bulgarian (100%)
- Chinese (Taiwan) (78.5%)
- Czech (76.9%)
- English (New Zealand) (60.1%)
- English (USA)
- Finnish (98.9%)
- French (100%)
- French (Canada) (91.7%)
- German (100%)
- German (Switzerland) (58.1%)
- Greek (61%)
- Hindi (100%)
- Italian (99.9%)
- Nederlands-Nederland (Dutch-The Netherlands) (86.2%)
- Norwegian Bokmål (62.4%)
- Polish (100%)
- Portuguese (91.1%)
- Portuguese (Brazil) (83.4%)
- Russian (83.9%)
- Slovak (74.8%)
- Spanish (100%)
- Swedish (81.3%)
- Telugu (94%)
- Turkish (99.8%)
- Ukrainian (75.1%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 21.11.20 is


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
We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 21.11.20

- Koha-Suomi Oy
- [PTFS Europe](https://ptfs-europe.com)

We thank the following individuals who contributed patches to Koha 21.11.20

- Pedro Amorim (1)
- Tomás Cohen Arazi (2)
- Nick Clemens (8)
- David Cook (1)
- Katrin Fischer (1)
- Lucas Gass (1)
- Kyle M Hall (1)
- Mason James (1)
- Andreas Jonsson (1)
- Owen Leonard (1)
- Johanna Raisa (1)
- Phil Ringnalda (1)
- Fridolin Somers (4)
- Arthur Suzuki (2)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 21.11.20

- Athens County Public Libraries (1)
- BibLibre (6)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (1)
- ByWater-Solutions (10)
- Chetco Community Public Library (1)
- Independant Individuals (1)
- KohaAloha (1)
- Kreablo AB (1)
- Prosentient Systems (1)
- PTFS-Europe (1)
- Theke Solutions (2)

We also especially thank the following individuals who tested patches
for Koha

- Anke (1)
- Tomás Cohen Arazi (22)
- Matt Blenkinsop (15)
- Nick Clemens (2)
- Jonathan Druart (5)
- Magnus Enger (1)
- Laura Escamilla (1)
- Katrin Fischer (5)
- Andrew Fuerste-Henry (1)
- Lucas Gass (24)
- Sally Healey (2)
- Mason James (1)
- Janusz Kaczmarek (1)
- Solene Ngamga (1)
- David Nind (2)
- Jacob O'Mara (9)
- Martin Renvoize (8)
- Phil Ringnalda (1)
- Marcel de Rooy (2)
- Michaela Sieber (1)
- Fridolin Somers (1)
- Arthur Suzuki (24)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 21.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 11 May 2023 13:05:00.
