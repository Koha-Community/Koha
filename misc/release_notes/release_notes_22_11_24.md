# RELEASE NOTES FOR KOHA 22.11.24
26 Feb 2025

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 22.11.24 can be downloaded from:

- [Download](http://download.koha-community.org/koha-22.11.24.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 22.11.24 is a bugfix/maintenance release.

It includes 4 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).

## Security Bugs

- [28907](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28907) Potential unauthorized access in public REST routes
- [36081](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36081) ArticleRequestsSupportedFormats not enforced server-side
- [37816](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37816) Stop SIP2 from logging passwords
- [38454](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38454) Memory (L1) cache is not flushed before API requests
- [38467](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38467) Template::Toolkit filters can create risky Javascript when not using RFC3986
- [38469](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38469) Circulation returns vulnerable to reflected XSS
- [38488](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38488) Add TT filter using HTML scrubber
- [38829](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38829) [CVE-2025-22954] SQL Injection in lateissues-export.pl
- [38961](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38961) XSS in vendor search

## Bugfixes

### Fines and fees

#### Other bugs fixed

- [28097](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28097) t/db_dependent/Koha/Account/Line.t test fails with FinesMode set to calculate

### Serials

#### Other bugs fixed

- [38470](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38470) Subscription detail page vulnerable to reflected XSS

### Staff interface

#### Other bugs fixed

- [37727](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37727) CVE-2024-24337 - Fix CSV formula injection - client side (DataTables)
- [38468](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38468) Staff interface detail page vulnerable to reflected XSS

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Armenian (hy_ARMN)](https://koha-community.org/manual/22.11//html/) (58%)
- [Bulgarian (bg_CYRL)](https://koha-community.org/manual/22.11//html/) (98%)
- [Chinese (Traditional)](https://koha-community.org/manual/22.11/zh_Hant/html/) (99%)
- [English](https://koha-community.org/manual/22.11//html/) (100%)
- [English (USA)](https://koha-community.org/manual/22.11/en/html/)
- [French](https://koha-community.org/manual/22.11/fr/html/) (59%)
- [German](https://koha-community.org/manual/22.11/de/html/) (100%)
- [Greek](https://koha-community.org/manual/22.11//html/) (93%)
- [Hindi](https://koha-community.org/manual/22.11/hi/html/) (71%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (90%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified) (96%)
- Chinese (Traditional) (82%)
- Czech (72%)
- Dutch (89%)
- English (100%)
- English (New Zealand) (69%)
- English (USA)
- English (United Kingdom) (99%)
- Finnish (96%)
- French (100%)
- French (Canada) (96%)
- German (100%)
- German (Switzerland) (56%)
- Greek (69%)
- Hindi (99%)
- Italian (92%)
- Norwegian Bokmål (69%)
- Persian (fa_ARAB) (77%)
- Polish (100%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (88%)
- Russian (94%)
- Slovak (68%)
- Spanish (100%)
- Swedish (88%)
- Telugu (77%)
- Tetum (54%)
- Turkish (91%)
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

The release team for Koha 22.11.24 is


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

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 22.11.24
<div style="column-count: 2;">

- Chetco Community Public Library
</div>

We thank the following individuals who contributed patches to Koha 22.11.24
<div style="column-count: 2;">

- Tomás Cohen Arazi (2)
- David Cook (7)
- Jonathan Druart (7)
- Magnus Enger (1)
- JesseM (3)
- Julian Maurice (1)
- Phil Ringnalda (3)
- Marcel de Rooy (3)
- Lari Taskula (7)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 22.11.24
<div style="column-count: 2;">

- [BibLibre](https://www.biblibre.com) (1)
- [ByWater Solutions](https://bywatersolutions.com) (3)
- Chetco Community Public Library (3)
- [Hypernova Oy](https://www.hypernova.fi) (7)
- Koha Community Developers (7)
- [Libriotech](https://libriotech.no) (1)
- [Prosentient Systems](https://www.prosentient.com.au) (7)
- Rijksmuseum, Netherlands (3)
- [Theke Solutions](https://theke.io) (2)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Tomás Cohen Arazi (6)
- Alex Buckley (8)
- David Cook (1)
- Chris Cormack (1)
- Paul Derscheid (3)
- Jonathan Druart (2)
- Magnus Enger (9)
- Victor Grousset (15)
- JesseM (15)
- Brendan Lawlor (1)
- Owen Leonard (1)
- Jesse Maseto (10)
- Julian Maurice (5)
- Phil Ringnalda (2)
- Marcel de Rooy (17)
- Fridolin Somers (12)
- wainuiwitikapark (5)
- Baptiste Wojtkowski (2)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 22.11.x-security.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 26 Feb 2025 17:14:07.
