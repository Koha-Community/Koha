# RELEASE NOTES FOR KOHA 24.05.07
26 Feb 2025

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 24.05.07 can be downloaded from:

- [Download](https://download.koha-community.org/koha-24.05.07.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 24.05.07 is a bugfix/maintenance release.

It includes 2 enhancements, 15 bugfixes and 12 security fixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [28478](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28478) MARC detail and ISBD pages still show suppressed records
- [28907](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28907) Potential unauthorized access in public REST routes
- [36081](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36081) ArticleRequestsSupportedFormats not enforced server-side
- [37266](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37266) patron_lists/delete.pl should have CSRF protection

  **Sponsored by** *Athens County Public Libraries*
- [37816](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37816) Stop SIP2 from logging passwords
- [38454](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38454) Memory (L1) cache is not flushed before API requests
- [38467](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38467) Template::Toolkit filters can create risky Javascript when not using RFC3986
- [38469](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38469) Circulation returns vulnerable to reflected XSS
- [38488](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38488) Add TT filter using HTML scrubber
- [38829](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38829) [CVE-2025-22954] SQL Injection in lateissues-export.pl
- [38961](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38961) XSS in vendor search

  **Sponsored by** *Chetco Community Public Library*
- [39170](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39170) Remote Code Execution within Task Scheduler

## Bugfixes

### ERM

#### Other bugs fixed

- [37810](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37810) Some SUSHI providers return ServiceActive instead of Service_Active

### Fines and fees

#### Other bugs fixed

- [28097](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28097) t/db_dependent/Koha/Account/Line.t test fails with FinesMode set to calculate

### Installation and upgrade (command-line installer)

#### Critical bugs fixed

- [38779](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38779) Record sources not working on packages install
  >This fixes the record sources page (Administration > Cataloging > Record sources) for package installs - you can now add and edit record sources, instead of getting a blank page. The Koha packages were missing the required JavaScript files (/intranet-tmpl/prog/js/vue/dist/admin/record_sources_24.1100000.js"></script>) to make the page work correctly.

### Searching - Elasticsearch

#### Critical bugs fixed

- [38913](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38913) Elasticsearch indexing explodes with some oversized records with UTF-8 characters

## Enhancements 

### Test Suite

#### Enhancements

- [39007](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39007) Add last_audit to the sushi_service API spec

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Armenian (hy_ARMN)](https://koha-community.org/manual/24.05//html/) (58%)
- [Bulgarian (bg_CYRL)](https://koha-community.org/manual/24.05//html/) (98%)
- [Chinese (Traditional)](https://koha-community.org/manual/24.05/zh_Hant/html/) (99%)
- [English](https://koha-community.org/manual/24.05//html/) (100%)
- [English (USA)](https://koha-community.org/manual/24.05/en/html/)
- [French](https://koha-community.org/manual/24.05/fr/html/) (59%)
- [German](https://koha-community.org/manual/24.05/de/html/) (100%)
- [Greek](https://koha-community.org/manual/24.05//html/) (92%)
- [Hindi](https://koha-community.org/manual/24.05/hi/html/) (71%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<!--<div style="column-count: 2;">-->

- Arabic (ar_ARAB) (97%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified) (88%)
- Chinese (Traditional) (99%)
- Czech (68%)
- Dutch (87%)
- English (100%)
- English (New Zealand) (63%)
- English (USA)
- Finnish (99%)
- French (100%)
- French (Canada) (99%)
- German (100%)
- Greek (65%)
- Hindi (98%)
- Italian (82%)
- Norwegian Bokmål (75%)
- Persian (fa_ARAB) (97%)
- Polish (100%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (88%)
- Russian (94%)
- Slovak (61%)
- Spanish (100%)
- Swedish (87%)
- Telugu (69%)
- Tetum (52%)
- Turkish (84%)
- Ukrainian (72%)
- hyw_ARMN (generated) (hyw_ARMN) (63%)
<!--</div>-->

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](https://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](https://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](https://translate.koha-community.org/)

## Release Team

The release team for Koha 24.05.07 is


- Release Manager: Katrin Fischer

- Release Manager assistants:
  - Tomás Cohen Arazi
  - Martin Renvoize
  - Jonathan Druart

- QA Manager: Martin Renvoize

- QA Team:
  - Victor Grousset
  - Lisette Scheer
  - Emily Lamancusa
  - David Cook
  - Jonathan Druart
  - Julian Maurice
  - Baptiste Wojtowski
  - Paul Derscheid
  - Aleisha Amohia
  - Laura Escamilla
  - Tomás Cohen Arazi
  - Kyle M Hall
  - Nick Clemens
  - Lucas Gass
  - Marcel de Rooy
  - Matt Blenkinsop
  - Pedro Amorim
  - Brendan Lawlor
  - Thomas Klausner

- Security Manager: Tomás Cohen Arazi

- Topic Experts:
  - UI Design -- Owen Leonard
  - REST API -- Tomás Cohen Arazi
  - Zebra -- Fridolin Somers

- Bug Wranglers:
  - Michaela Sieber
  - Jacob O'Mara
  - Jake Deery

- Packaging Manager: Mason James

- Documentation Manager: Philip Orr

- Documentation Team:
  - Aude Charillon
  - David Nind
  - Caroline Cyr La Rose

- Wiki curators: 
  - George Williams
  - Thomas Dukleth
  - Jonathan Druart
  - Martin Renvoize

- Release Maintainers:
  - 24.11 -- Paul Derscheid
  - 24.05 -- Wainui Witika-Park
  - 23.11 -- Fridolin Somers
  - 22.11 -- Laura Escamilla


## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 24.05.07
<!--<div style="column-count: 2;">-->

- Athens County Public Libraries
- Chetco Community Public Library
<!--</div>-->

We thank the following individuals who contributed patches to Koha 24.05.07
<!--<div style="column-count: 2;">-->

- Pedro Amorim (2)
- Tomás Cohen Arazi (4)
- Matt Blenkinsop (2)
- Alex Buckley (2)
- Nick Clemens (1)
- David Cook (5)
- Jonathan Druart (8)
- Magnus Enger (1)
- Janusz Kaczmarek (1)
- Owen Leonard (1)
- Julian Maurice (1)
- Phil Ringnalda (3)
- Marcel de Rooy (3)
- Lari Taskula (9)
<!--</div>-->

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 24.05.07
<!--<div style="column-count: 2;">-->

- Athens County Public Libraries (1)
- [BibLibre](https://www.biblibre.com) (1)
- [ByWater Solutions](https://bywatersolutions.com) (1)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha) (2)
- Chetco Community Public Library (3)
- [Hypernova Oy](https://www.hypernova.fi) (9)
- Independant Individuals (1)
- Koha Community Developers (8)
- [Libriotech](https://libriotech.no) (1)
- [Prosentient Systems](https://www.prosentient.com.au) (5)
- [PTFS Europe](https://ptfs-europe.com) (4)
- Rijksmuseum, Netherlands (3)
- [Theke Solutions](https://theke.io) (4)
<!--</div>-->

We also especially thank the following individuals who tested patches
for Koha
<!--<div style="column-count: 2;">-->

- Tomás Cohen Arazi (6)
- Alex Buckley (34)
- Nick Clemens (2)
- David Cook (2)
- Paul Derscheid (4)
- Jonathan Druart (5)
- Magnus Enger (12)
- Katrin Fischer (3)
- Victor Grousset (15)
- Brendan Lawlor (1)
- Owen Leonard (1)
- Julian Maurice (5)
- David Nind (3)
- Martin Renvoize (6)
- Phil Ringnalda (3)
- Marcel de Rooy (19)
- wainuiwitikapark (7)
- Baptiste Wojtkowski (1)
<!--</div>-->





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 24.05.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 26 Feb 2025 11:06:57.
