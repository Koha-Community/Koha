# RELEASE NOTES FOR KOHA 25.05.10
22 Apr 2026

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 25.05.10 can be downloaded from:

- [Download](https://download.koha-community.org/koha-25.05.10.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 25.05.10 is a bugfix/maintenance release.

It includes 1 enhancements, 5 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [34000](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34000) Don't allow auto-generated cardnumbers to be re-used, it may give access of services to the next patron created
- [42136](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42136) User-entered Template::Toolkit allows information disclosure
- [42252](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42252) Stored XSS when deleting a list or removing a list share
- [42253](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42253) Stored XSS in advanced editor in Macro name
- [42254](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42254) DOM XSS via tag search

## Bugfixes

### Patrons

#### Critical bugs fixed

- [42423](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42423) Submit button in patron search from header never submits
  >This fixes the patron search in the staff interface header. 
  >
  >If the search you enter didn't show any autocomplete results, clicking the arrow to search didn't do anything.
  >
  >Now, it will use the search you entered and show any results.

## New system preferences

- autoMemberNumValue

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [English (USA)](https://koha-community.org/manual/25.05/en/html/)
- [French](https://koha-community.org/manual/25.05/fr/html/) (80%)
- [German](https://koha-community.org/manual/25.05/de/html/) (89%)
- [Greek](https://koha-community.org/manual/25.05/el/html/) (93%)
- [Hindi](https://koha-community.org/manual/25.05/hi/html/) (63%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (92%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified Han script) (83%)
- Chinese (Traditional Han script) (97%)
- Czech (67%)
- Dutch (86%)
- English (100%)
- English (New Zealand) (61%)
- English (USA)
- Finnish (99%)
- French (100%)
- French (Canada) (99%)
- German (99%)
- Greek (65%)
- Hindi (94%)
- Italian (81%)
- Norwegian Bokmål (71%)
- Persian (fa_ARAB) (93%)
- Polish (99%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (88%)
- Russian (93%)
- Slovak (59%)
- Spanish (98%)
- Swedish (89%)
- Telugu (65%)
- Turkish (80%)
- Ukrainian (74%)
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

The release team for Koha 25.05.10 is


- Release Manager: Lucas Gass

- QA Manager: Martin Renvoize

- QA Team:
  - Marcel de Rooy
  - Martin Renvoize
  - Jonathan Druart
  - Laura Escamilla
  - Lucas Gass
  - Tomás Cohen Arazi
  - Lisette Scheer
  - Nick Clemens
  - Paul Derscheid
  - Emily Lamancusa
  - David Cook
  - Matt Blenkinsop
  - Andrew Fuerste-Henry
  - Brendan Lawlor
  - Pedro Amorim
  - Kyle M Hall
  - Aleisha Amohia
  - David Nind
  - Baptiste Wojtkowski
  - Jan Kissig
  - Katrin Fischer
  - Thomas Klausner
  - Julian Maurice
  - Owen Leonard

- Documentation Manager: David Nind

- Documentation Team:
  - Philip Orr
  - Aude Charillon
  - Caroline Cyr La Rose

- Translation Manager: Jonathan Druart


- Wiki curators: 
  - George Williams
  - Thomas Dukleth

- Release Maintainers:
  - 25.11 -- Jacob O'Mara
  - 25.05 -- Laura Escamilla
  - 24.11 -- Fridolin Somers
  - 22.11 -- Wainui Witika-Park (Catalyst IT)

- Release Maintainer assistants:
  - 25.11 -- Chloé Zermatten
  - 24.11 -- Baptiste Wojtkowski
  - 22.11 -- Alex Buckley & Aleisha Amohia

## Credits



We thank the following individuals who contributed patches to Koha 25.05.10
<div style="column-count: 2;">

- David Cook (4)
- Jonathan Druart (5)
- Lucas Gass (3)
- Martin Renvoize (3)
- Marcel de Rooy (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 25.05.10
<div style="column-count: 2;">

- [ByWater Solutions](https://bywatersolutions.com) (3)
- Koha Community Developers (5)
- [OpenFifth](https://openfifth.co.uk) (3)
- [Prosentient Systems](https://www.prosentient.com.au) (4)
- Rijksmuseum, Netherlands (1)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- David Cook (3)
- Jonathan Druart (2)
- Andrew Fuerste-Henry (3)
- Lucas Gass (13)
- Brendan Lawlor (1)
- Jacob O'Mara (3)
- Phil Ringnalda (2)
- Marcel de Rooy (2)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 25.05.x-security.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 22 Apr 2026 22:09:53.
