# RELEASE NOTES FOR KOHA 24.11.21
28 Oct 2026

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 24.11.21 can be downloaded from:

- [Download](https://download.koha-community.org/koha-24.11.21.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 24.11.21 is a bugfix/maintenance release with security fixes.

It includes 6 bugfixes, 4 security.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [42946](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42946) [CVE-2026-16031] Time-based Blind SQL Injection in itemsearch.pl functionality
- [43429](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43429) Stored XSS via OPAC Report a Problem executes in staff/intranet security context (8.7 HIGH)
- [43634](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43634) cancelBulk in waitingreserves.pl is not protected against CSRF attacks
- [43707](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43707) Fix stored XSS in DT's column filters in staff interface

## Bugfixes

### System Administration

#### Other bugs fixed

- [43336](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43336) Remove support for LibrisSpellcheck
  >This removes support for LibrisSpellcheck, as the API that this feature was based on was removed by the Swedish National Library.
  >
  >It removes two system preferences: LibrisKey and LibrisURL. It also removes the LibrisSpellcheck option from "Did you mean?" (Administration > Additional parameters > Did you mean?).

### Templates

#### Other bugs fixed

- [37441](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37441) ShowAlerts msg not escaped in tools uploads

## Deleted system preferences

- LibrisKey
- LibrisURL

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [English (USA)](https://koha-community.org/manual/24.11/en/html/)
- [French](https://koha-community.org/manual/24.11/fr/html/) (82%)
- [German](https://koha-community.org/manual/24.11/de/html/) (84%)
- [Greek](https://koha-community.org/manual/24.11/el/html/) (90%)
- [Hindi](https://koha-community.org/manual/24.11/hi/html/) (61%)
- [Portuguese](https://koha-community.org/manual/24.11/pt/html/) (61%)
- [Portuguese (Brazil)](https://koha-community.org/manual/24.11/pt_BR/html/) (61%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Afrikaans (96%)
- Arabic (ar_ARAB) (95%)
- Armenian (hy_ARMN) (100%)
- Azerbaijani (62%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified Han script) (86%)
- Chinese (Traditional Han script) (99%)
- Czech (68%)
- Dutch (89%)
- English (100%)
- English (New Zealand) (98%)
- English (USA)
- Finnish (99%)
- French (100%)
- French (Canada) (99%)
- German (100%)
- Greek (69%)
- Hindi (97%)
- Italian (85%)
- Khmer (Central) (55%)
- Norwegian Bokmål (73%)
- Persian (fa_ARAB) (96%)
- Polish (99%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (88%)
- Russian (95%)
- Slovak (61%)
- Spanish (99%)
- Swedish (89%)
- Telugu (67%)
- Tetum (52%)
- Turkish (83%)
- Ukrainian (77%)
- Uzbek (67%)
- Western Armenian (hyw_ARMN) (62%)
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

The release team for Koha 24.11.21 is


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



We thank the following individuals who contributed patches to Koha 24.11.21
<div style="column-count: 2;">

- David Cook (2)
- Jonathan Druart (8)
- Magnus Enger (1)
- Fridolin Somers (3)
- Wainui Witika-Park (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 24.11.21
<div style="column-count: 2;">

- [BibLibre](https://www.biblibre.com) (3)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha) (1)
- Koha Community Developers (8)
- [Libriotech](https://libriotech.no) (1)
- [Prosentient Systems](https://www.prosentient.com.au) (2)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Nick Clemens (1)
- David Cook (3)
- Jonathan Druart (1)
- Andrew Fuerste-Henry (1)
- Lucas Gass (1)
- Amit Gupta (2)
- Kyle M Hall (2)
- David Nind (5)
- Marcel de Rooy (7)
- Fridolin Somers (4)
- Wainui Witika-Park (1)
- Baptiste Wojtkowski (1)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 24.11.x-security.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 28 Oct 2026 07:01:44.
