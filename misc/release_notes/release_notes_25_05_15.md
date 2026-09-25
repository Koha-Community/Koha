# RELEASE NOTES FOR KOHA 25.05.15
25 Sep 2026

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 25.05.15 can be downloaded from:

- [Download](https://download.koha-community.org/koha-25.05.15.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 25.05.15 is a security release.

It includes 6 security bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [37441](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37441) ShowAlerts msg not escaped in tools uploads
- [42674](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42674) OS command injection via `jobid` in Task Scheduler (`tools/scheduler.pl`)
- [43326](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43326) Stored XSS in patron account note (accountlines.note)
- [43424](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43424) REST Basic Auth bypasses account lockout (8.1 HIGH)
- [43426](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43426) admin/item_circulation_alerts.pl cud-toggle performs no authentication check at all (7.5 HIGH)
- [43470](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43470) REST Basic Auth allows silent 2FA secret takeover

## Bugfixes

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [English (USA)](https://koha-community.org/manual/25.05/en/html/)
- [French](https://koha-community.org/manual/25.05/fr/html/) (83%)
- [German](https://koha-community.org/manual/25.05/de/html/) (84%)
- [Greek](https://koha-community.org/manual/25.05/el/html/) (90%)
- [Hindi](https://koha-community.org/manual/25.05/hi/html/) (62%)
- [Portuguese](https://koha-community.org/manual/25.05/pt/html/) (53%)
- [Portuguese (Brazil)](https://koha-community.org/manual/25.05/pt_BR/html/) (28%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (92%)
- Armenian (hy_ARMN) (100%)
- Azerbaijani (64%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified Han script) (83%)
- Chinese (Traditional Han script) (97%)
- Czech (67%)
- Dutch (89%)
- English (100%)
- English (New Zealand) (61%)
- English (USA)
- Finnish (99%)
- French (100%)
- French (Canada) (99%)
- German (100%)
- Greek (66%)
- Hindi (94%)
- Italian (82%)
- Khmer (Central) (57%)
- Norwegian Bokmål (71%)
- Persian (fa_ARAB) (93%)
- Polish (100%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (88%)
- Russian (93%)
- Slovak (59%)
- Spanish (98%)
- Swedish (89%)
- Telugu (65%)
- Turkish (80%)
- Ukrainian (74%)
- Uzbek (62%)
- Western Armenian (hyw_ARMN) (60%)
</div>

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](https://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](https://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](https://translate.koha-community.org/)

## Release Team

The release team for Koha 25.05.15 is


- Release Manager: Pedro Amorim

- Release Manager assistants:
  - Tomás Cohen Arazi
  - Martin Renvoize

- QA Manager: Lisette Scheer

- QA Team:
  - Lucas Gass
  - Laura Escamilla
  - Kyle M Hall
  - Baptiste Wojtkowski
  - Victor Grousset
  - David Cook
  - Andrew Fuerste-Henry
  - Brendan Lawlor
  - Thomas Klausner
  - Paul Derscheid
  - Jan Kissig
  - Jacob O'Mara
  - Nick Clemens
  - Tomás Cohen Arazi
  - Marcel de Rooy
  - Emily Lamancusa
  - Aleisha Amohia
  - Martin Renvoize
  - David Nind

- Topic Experts:
  - Elasticsearch/OpenSearch -- Fridolin Somers
  - SIP2 -- Kyle M Hall
  - EDI -- Kyle M Hall
  - POS -- Martin Renvoize

- Bug Wranglers:
  - Michaela Sieber
  - Laura Escamilla

- Documentation Manager: Aude Charillon

- Documentation Team:
  - Caroline Cyr La Rose
  - David Nind
  - Philip Orr

- Wiki curators: 
  - Thomas Dukleth
  - George Williams

- Release Maintainers:
  - 26.05 -- Lucas Gass
  - 25.11 -- Baptiste Wojtkowski
  - 25.05 -- Wainui Witika-Park (Catalyst IT)
  - 24.11 -- Fridolin Somers

- Release Maintainer assistants:
  - 26.05 -- Jacob O'Mara
  - 25.05 -- Alex Buckley & Aleisha Amohia (Catalyst IT)

## Credits



We thank the following individuals who contributed patches to Koha 25.05.15
<div style="column-count: 2;">

- Paul Derscheid (1)
- Jonathan Druart (5)
- Martin Renvoize (1)
- Hammat Wele (1)
- Wainui Witika-Park (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 25.05.15
<div style="column-count: 2;">

- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha) (1)
- Koha Community Developers (5)
- [LMSCloud](https://www.lmscloud.de) (1)
- [OpenFifth](https://openfifth.co.uk) (1)
- [Solutions inLibro inc](https://inlibro.com) (1)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Nick Clemens (1)
- David Cook (4)
- Andrew Fuerste-Henry (1)
- Sanjar Tulkinov Anvar o'g'li (1)
- Martin Renvoize (3)
- Phil Ringnalda (4)
- Wainui Witika-Park (8)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 25.05.x

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 25 Sep 2026 02:02:16.
