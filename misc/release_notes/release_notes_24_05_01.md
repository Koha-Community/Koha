# RELEASE NOTES FOR KOHA 24.05.01
10 Jun 2024

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 24.05.01 can be downloaded from:

- [Download](http://download.koha-community.org/koha-24.05.01.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 24.05.01 is a bugfix/maintenance release.

It includes 6 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [36520](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36520) SQL Injection in opac-sendbasket.pl (CVE-2024-36058)
- [36575](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36575) Wrong patron can be returned for API validation route
- [36818](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36818) Remote-Code-Execution (RCE) in upload-cover-image.pl (CVE-2024-36057)
- [36875](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36875) SQL injection in additional content pages

## Bugfixes

### Installation and upgrade (command-line installer)

#### Critical bugs fixed

- [36986](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36986) (Bug 26176 follow-up) Fix rename StaffLoginBranchBasedOnIP in DBRev
- [36993](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36993) Upgrade fails at 23.12.00.023 [Bug 32132]

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Chinese (Traditional)](https://koha-community.org/manual/24.05//html/) (73%)
- [English](https://koha-community.org/manual/24.05//html/) (100%)
- [English (USA)](https://koha-community.org/manual/24.05/en/html/)
- [French](https://koha-community.org/manual/24.05/fr/html/) (44%)
- [German](https://koha-community.org/manual/24.05/de/html/) (40%)
- [Hindi](https://koha-community.org/manual/24.05/hi/html/) (80%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (98%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Traditional) (90%)
- Czech (68%)
- Dutch (76%)
- English (100%)
- English (New Zealand) (63%)
- English (USA)
- Finnish (99%)
- French (98%)
- French (Canada) (95%)
- German (100%)
- German (Switzerland) (51%)
- Greek (51%)
- Hindi (99%)
- Italian (83%)
- Norwegian Bokmål (76%)
- Persian (fa_ARAB) (91%)
- Polish (98%)
- Portuguese (Brazil) (91%)
- Portuguese (Portugal) (87%)
- Russian (90%)
- Slovak (60%)
- Spanish (100%)
- Swedish (87%)
- Telugu (69%)
- Turkish (79%)
- Ukrainian (73%)
- hyw_ARMN (generated) (hyw_ARMN) (64%)
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

The release team for Koha 24.05.01 is


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
  - 24.05 -- Fridolin Somers
  - 23.11 -- Fridolin Somers
  - 23.05 -- Lucas Gass
  - 22.11 -- Frédéric Demians
  - 22.05 -- Danyon Sewell

- Release Maintainer assistants:
  - 22.05 -- Wainui Witika-Park

## Credits



We thank the following individuals who contributed patches to Koha 24.05.01
<div style="column-count: 2;">

- Nick Clemens (4)
- Chris Cormack (2)
- Jonathan Druart (2)
- Martin Renvoize (5)
- Marcel de Rooy (5)
- Fridolin Somers (2)
- Emmi Takkinen (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 24.05.01
<div style="column-count: 2;">

- BibLibre (2)
- BigBallOfWax (2)
- ByWater-Solutions (4)
- Koha Community Developers (2)
- Koha-Suomi (1)
- PTFS-Europe (5)
- Rijksmuseum (5)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Chris Cormack (1)
- Victor Grousset (8)
- Amit Gupta (2)
- Kyle M Hall (2)
- David Nind (1)
- Martin Renvoize (9)
- Marcel de Rooy (8)
- Fridolin Somers (18)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 24.05.x-security.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 10 Jun 2024 14:30:42.
