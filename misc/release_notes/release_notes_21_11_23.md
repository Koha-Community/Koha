# RELEASE NOTES FOR KOHA 21.11.23
04 Aug 2023

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 21.11.23 can be downloaded from:

- [Download](http://download.koha-community.org/koha-21.11.23.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 21.11.23 is a bugfix/maintenance release.

It includes 1 enhancements, 9 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


## Bugfixes

### Command-line Utilities

#### Other bugs fixed

- [33645](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33645) koha-foreach always returns 1 if --chdir not specified
- [33677](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33677) Remove --verbose from koha-worker manpage

### Hold requests

#### Other bugs fixed

- [32993](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32993) Holds priority changed incorrectly with dropdown selector

### OPAC

#### Other bugs fixed

- [33233](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33233) OPAC advanced search inputs stay disabled when using browser's back button

### Staff interface

#### Other bugs fixed

- [28315](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28315) PopupMARCFieldDoc is defined twice in addbiblio.tt
- [33642](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33642) Typo: No log found .

### System Administration

#### Other bugs fixed

- [33196](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33196) Terminology: rephrase Pseudonymization system preference to be more general

### Templates

#### Other bugs fixed

- [31405](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31405) Set focus for cursor to setSpec input when adding a new OAI set
- [31410](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31410) Set focus for cursor to Server name when adding a new Z39.50 or SRU server

## Enhancements 

### Architecture, internals, and plumbing

#### Enhancements

- [29486](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29486) _koha_marc_update_bib_ids no longer needed for GetMarcBiblio

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Arabic](https://koha-community.org/manual/21.11/ar/html/) (33.8%)
- [Chinese (Taiwan)](https://koha-community.org/manual/21.11/zh_TW/html/) (58.8%)
- [Czech](https://koha-community.org/manual/21.11/cs/html/) (27.2%)
- [English (USA)](https://koha-community.org/manual/21.11/en/html/)
- [French](https://koha-community.org/manual/21.11/fr/html/) (71.6%)
- [French (Canada)](https://koha-community.org/manual/21.11/fr_CA/html/) (25.6%)
- [German](https://koha-community.org/manual/21.11/de/html/) (73.3%)
- [Hindi](https://koha-community.org/manual/21.11/hi/html/) (100%)
- [Italian](https://koha-community.org/manual/21.11/it/html/) (48.2%)
- [Spanish](https://koha-community.org/manual/21.11/es/html/) (36.2%)
- [Turkish](https://koha-community.org/manual/21.11/tr/html/) (39.6%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (86.3%)
- Armenian (100%)
- Armenian (Classical) (76%)
- Bulgarian (100%)
- Chinese (Taiwan) (78.5%)
- Czech (77%)
- English (New Zealand) (60.1%)
- English (USA)
- Finnish (98.9%)
- French (100%)
- French (Canada) (91.7%)
- German (100%)
- German (Switzerland) (58.1%)
- Greek (61.8%)
- Hindi (100%)
- Italian (100%)
- Nederlands-Nederland (Dutch-The Netherlands) (86.5%)
- Norwegian Bokmål (62.4%)
- Polish (100%)
- Portuguese (91.1%)
- Portuguese (Brazil) (83.4%)
- Russian (83.9%)
- Slovak (74.8%)
- Spanish (100%)
- Swedish (85.1%)
- Telugu (94%)
- Turkish (99.8%)
- Ukrainian (75.1%)
</div>

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 21.11.23 is


- Release Manager: Tomás Cohen Arazi

- Release Manager assistants:
  - Jonathan Druart
  - Martin Renvoize

- QA Manager: Katrin Fischer

- QA Team:
  - Aleisha Amohia
  - Nick Clemens
  - David Cook
  - Jonathan Druart
  - Lucas Gass
  - Victor Grousset
  - Kyle M Hall
  - Andrii Nugged
  - Martin Renvoize
  - Marcel de Rooy
  - Petro Vashchuk

- Topic Experts:
  - UI Design -- Owen Leonard
  - Zebra -- Fridolin Somers
  - REST API -- Martin Renvoize
  - ERM -- Pedro Amorim
  - ILL -- Pedro Amorim

- Bug Wranglers:
  - Aleisha Amohia

- Packaging Manager: Mason James

- Documentation Manager: Aude Charillon

- Documentation Team:
  - Caroline Cyr La Rose
  - Lucy Vaux-Harvey

- Translation Manager: Bernardo González Kriegel


- Wiki curators: 
  - Thomas Dukleth
  - Katrin Fischer

- Release Maintainers:
  - 23.05 -- Fridolin Somers
  - 22.11 -- PTFS Europe (Matt Blenkinsop, Pedro Amorim)
  - 22.05 -- Lucas Gass
  - 21.11 -- Danyon Sewell

- Release Maintainer assistants:
  - 21.11 -- Wainui Witika-Park

## Credits



We thank the following individuals who contributed patches to Koha 21.11.23
<div style="column-count: 2;">

- Tomás Cohen Arazi (1)
- David Cook (1)
- danyonsewell (4)
- Jonathan Druart (5)
- Katrin Fischer (3)
- Lucas Gass (2)
- Amit Gupta (1)
- Michał Górny (1)
- Kyle M Hall (1)
- Philip Orr (1)
- Martin Renvoize (3)
- Koha translators (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 21.11.23
<div style="column-count: 2;">

- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (3)
- ByWater-Solutions (3)
- Catalyst (4)
- gentoo.org (1)
- Informatics Publishing Ltd (1)
- Koha Community Developers (5)
- lmscloud.de (1)
- Prosentient Systems (1)
- PTFS-Europe (3)
- Theke Solutions (1)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Tomás Cohen Arazi (16)
- Matt Blenkinsop (4)
- Nick Clemens (3)
- David Cook (6)
- danyonsewell (13)
- Jonathan Druart (2)
- Magnus Enger (1)
- Katrin Fischer (1)
- Lucas Gass (10)
- Kyle M Hall (4)
- Barbara Johnson (1)
- Owen Leonard (3)
- David Nind (4)
- Martin Renvoize (8)
- Marcel de Rooy (19)
- Fridolin Somers (3)
- Emmi Takkinen (1)
- Hinemoea Viault (1)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 21.11.x

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 04 Aug 2023 03:08:10.
