# RELEASE NOTES FOR KOHA 22.11.18
18 juin 2024

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 22.11.18 can be downloaded from:

- [Download](http://download.koha-community.org/koha-22.11.18.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 22.11.18 is a bugfix/maintenance release.

It includes 3 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


## Bugfixes

### Architecture, internals, and plumbing

#### Critical bugs fixed

- [36520](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36520) SQL Injection in opac-sendbasket.pl (CVE-2024-36058)
- [36818](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36818) Remote-Code-Execution (RCE) in upload-cover-image.pl (CVE-2024-36057)

### REST API

#### Other bugs fixed

- [36575](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36575) Wrong patron can be returned for API validation route

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Chinese (Traditional)](https://koha-community.org/manual/22.11/zh_Hant/html/) (72%)
- [English](https://koha-community.org/manual/22.11//html/) (100%)
- [English (USA)](https://koha-community.org/manual/22.11/en/html/)
- [French](https://koha-community.org/manual/22.11/fr/html/) (44%)
- [German](https://koha-community.org/manual/22.11/de/html/) (40%)
- [Hindi](https://koha-community.org/manual/22.11/hi/html/) (80%)

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

The release team for Koha 22.11.18 is


- Release Manager: Katrin Fischer

- Release Manager assistants:
  - Tomás Cohen Arazi
  - Martin Renvoize
  - Jonathan Druart

- QA Manager: Martin Renvoize

- QA Team:
  - Marcel de Rooy
  - Kyle M Hall
  - Emily Lamancusa
  - Nick Clemens
  - Lucas Gass
  - Tomás Cohen Arazi
  - Julian Maurice
  - Victor Grousset
  - Aleisha Amohia
  - David Cook
  - Laura Escamilla
  - Jonathan Druart
  - Pedro Amorim
  - Matt Blenkinsop
  - Thomas Klausner

- Topic Experts:
  - UI Design -- Owen Leonard
  - Zebra -- Fridolin Somers
  - ERM -- Matt Blenkinsop
  - ILL -- Pedro Amorim
  - SIP2 -- Matthias Meusburger
  - CAS -- Matthias Meusburger

- Bug Wranglers:
  - Aleisha Amohia
  - Jacob O'Mara

- Packaging Managers:
  - Mason James
  - Tomás Cohen Arazi

- Documentation Manager: Philip Orr

- Documentation Team:
  - Aude Charillon
  - Caroline Cyr La Rose
  - Lucy Vaux-Harvey
  - Emmanuel Bétemps
  - Marie-Luce Laflamme
  - Kelly McElligott
  - Rasa Šatinskienė
  - Heather Hernandez

- Wiki curators: 
  - Thomas Dukleth
  - George Williams

- Release Maintainers:
  - 24.05 -- Lucas Gass
  - 23.11 -- Fridolin Somers
  - 23.05 -- Wainui Witika-Park
  - 22.11 -- Fridolin Somers

## Credits



We thank the following individuals who contributed patches to Koha 22.11.18
<div style="column-count: 2;">

- Nick Clemens (4)
- Chris Cormack (2)
- Frédéric Demians (2)
- Jonathan Druart (2)
- Martin Renvoize (1)
- Marcel de Rooy (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 22.11.18
<div style="column-count: 2;">

- BigBallOfWax (2)
- [ByWater Solutions](https://bywatersolutions.com) (4)
- Koha Community Developers (2)
- [PTFS Europe](https://ptfs-europe.com) (1)
- Rijksmuseum, Netherlands (1)
- Tamil (2)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Chris Cormack (1)
- Frédéric Demians (9)
- Victor Grousset (3)
- Amit Gupta (2)
- Kyle M Hall (2)
- Martin Renvoize (3)
- Marcel de Rooy (8)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 22.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 18 juin 2024 15:15:31.
