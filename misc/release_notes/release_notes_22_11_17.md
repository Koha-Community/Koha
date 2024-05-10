# RELEASE NOTES FOR KOHA 22.11.17
10 May 2024

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 22.11.17 can be downloaded from:

- [Download](http://download.koha-community.org/koha-22.11.17.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 22.11.17 is a bugfix/maintenance release.

It includes 1 enhancements, 5 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


## Bugfixes

### Architecture, internals, and plumbing

#### Critical bugs fixed

- [24879](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24879) Add missing authentication checks

#### Other bugs fixed

- [36176](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36176) [23.11 and below] We need tests to check for 'cud-' operations in stable branches (pre-24.05)

### Authentication

#### Critical bugs fixed

- [34755](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34755) Error authenticating to external OpenID Connect (OIDC) identity provider : wrong_csrf_token

#### Other bugs fixed

- [36098](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36098) Create Koha::Session module

### Cataloging

#### Critical bugs fixed

- [36511](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36511) Some scripts missing a dependency following Bug 24879

## Enhancements 

### Plugin architecture

#### Enhancements

- [34943](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34943) Add a pre-save plugin hook for biblios

  **Sponsored by** *Theke Solutions*

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Chinese (Traditional)](https://koha-community.org/manual/22.11//html/) (70%)
- [English](https://koha-community.org/manual/22.11//html/) (100%)
- [English (USA)](https://koha-community.org/manual/22.11/en/html/)
- [French](https://koha-community.org/manual/22.11/fr/html/) (41%)
- [German](https://koha-community.org/manual/22.11/de/html/) (40%)
- [Hindi](https://koha-community.org/manual/22.11/hi/html/) (81%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (90%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Traditional) (81%)
- Czech (72%)
- Dutch (88%)
- English (100%)
- English (New Zealand) (69%)
- English (USA)
- English (United Kingdom) (99%)
- Finnish (96%)
- French (100%)
- French (Canada) (96%)
- German (100%)
- German (Switzerland) (56%)
- Greek (57%)
- Hindi (100%)
- Italian (92%)
- Norwegian Bokmål (69%)
- Persian (fa_ARAB) (75%)
- Polish (100%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (88%)
- Russian (94%)
- Slovak (67%)
- Spanish (100%)
- Swedish (88%)
- Telugu (77%)
- Turkish (88%)
- Ukrainian (79%)
- hyw_ARMN (generated) (hyw_ARMN) (70%)
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

The release team for Koha 22.11.17 is


- Release Manager: Katrin Fischer

- Release Manager assistants:
  - Tomás Cohen Arazi
  - Martin Renvoize
  - Jonathan Druart

- QA Manager: Marcel de Rooy

- QA Team:
  - Marcel de Rooy
  - Julian Maurice
  - Lucas Gass
  - Victor Grousset
  - Kyle M Hall
  - Nick Clemens
  - Martin Renvoize
  - Tomás Cohen Arazi
  - Aleisha Amohia
  - Emily Lamancusa
  - David Cook
  - Jonathan Druart
  - Pedor Amorim

- Topic Experts:
  - UI Design -- Owen Leonard
  - Zebra -- Fridolin Somers
  - REST API -- Tomás Cohen Arazi
  - ERM -- Matt Blenkinsop
  - ILL -- Pedro Amorim
  - SIP2 -- Matthias Meusburger
  - CAS -- Matthias Meusburger

- Bug Wranglers:
  - Aleisha Amohia
  - Indranil Das Gupta

- Packaging Managers:
  - Mason James
  - Indranil Das Gupta
  - Tomás Cohen Arazi

- Documentation Manager: Aude Charillon

- Documentation Team:
  - Caroline Cyr La Rose
  - Kelly McElligott
  - Philip Orr
  - Marie-Luce Laflamme
  - Lucy Vaux-Harvey

- Translation Manager: Jonathan Druart


- Wiki curators: 
  - Thomas Dukleth
  - Katrin Fischer

- Release Maintainers:
  - 23.11 -- Fridolin Somers
  - 23.05 -- Lucas Gass
  - 22.11 -- Frédéric Demians
  - 22.05 -- Danyon Sewell

- Release Maintainer assistants:
  - 22.05 -- Wainui Witika-Park

## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 22.11.17
<div style="column-count: 2;">

- [Theke Solutions](https://theke.io)
</div>

We thank the following individuals who contributed patches to Koha 22.11.17
<div style="column-count: 2;">

- Tomás Cohen Arazi (3)
- Nick Clemens (1)
- David Cook (4)
- Frédéric Demians (3)
- Jonathan Druart (6)
- Lucas Gass (2)
- Owen Leonard (1)
- Julian Maurice (1)
- Martin Renvoize (1)
- Fridolin Somers (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 22.11.17
<div style="column-count: 2;">

- Athens County Public Libraries (1)
- BibLibre (2)
- ByWater-Solutions (3)
- Koha Community Developers (6)
- Prosentient Systems (4)
- PTFS-Europe (1)
- Tamil (3)
- Theke Solutions (3)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Tomás Cohen Arazi (1)
- Nick Clemens (3)
- David Cook (3)
- danyonsewell (1)
- Frédéric Demians (20)
- Jonathan Druart (5)
- Katrin Fischer (4)
- Lucas Gass (8)
- Kyle M Hall (3)
- Olivier Hubert (1)
- Owen Leonard (1)
- David Nind (2)
- Martin Renvoize (4)
- Fridolin Somers (12)
- Wainui Witika-Park (1)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 22.11.x-security.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 10 May 2024 08:05:47.
