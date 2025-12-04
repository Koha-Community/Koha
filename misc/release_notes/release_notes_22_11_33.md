# RELEASE NOTES FOR KOHA 22.11.33
04 Dec 2025

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 22.11.33 can be downloaded from:

- [Download](https://download.koha-community.org/koha-22.11.33.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 22.11.33 is a security bugfix/maintenance release.

It includes 2 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [40524](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40524) Stored XSS run by DataTables Print button in staff interface

## Bugfixes

### Patrons

#### Critical bugs fixed

- [35830](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35830) Add separate permission for Merging Patrons

  **Sponsored by** *Cape Libraries Automated Materials Sharing*

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [English (USA)](https://koha-community.org/manual/22.11/en/html/)
- [French](https://koha-community.org/manual/22.11/fr/html/) (75%)
- [German](https://koha-community.org/manual/22.11/de/html/) (94%)
- [Greek](https://koha-community.org/manual/22.11/el/html/) (98%)
- [Hindi](https://koha-community.org/manual/22.11/hi/html/) (67%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (90%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified Han script) (96%)
- Chinese (Traditional Han script) (83%)
- Czech (72%)
- Dutch (89%)
- English (100%)
- English (New Zealand) (70%)
- English (USA)
- English (United Kingdom) (99%)
- Finnish (96%)
- French (100%)
- French (Canada) (96%)
- German (100%)
- German (Switzerland) (56%)
- Greek (72%)
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
- Swedish (89%)
- Telugu (78%)
- Tetum (54%)
- Turkish (91%)
- Ukrainian (79%)
- Western Armenian (hyw_ARMN) (70%)
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

The release team for Koha 22.11.33 is


- Release Manager: Lucas Gass

- QA Manager: Martin Renvoize

- QA Team:
  - Andrew Fuerste-Henry
  - Andrii Nugged
  - Baptiste Wojtkowski
  - Brendan Lawlor
  - David Cook
  - Emily Lamancusa
  - Jonathan Druart
  - Julian Maurice
  - Kyle Hall
  - Laura Escamilla
  - Lisette Scheer
  - Marcel de Rooy
  - Nick Clemens
  - Paul Derscheid
  - Petro V
  - Tomás Cohen Arazi
  - Victor Grousset

- Documentation Manager: David Nind

- Documentation Team:
  - Aude Charillon
  - Caroline Cyr La Rose
  - Donna Bachowski
  - Heather Hernandez
  - Kristi Krueger
  - Philip Orr

- Translation Manager: Jonathan Druart


- Wiki curators: 
  - George Williams
  - Thomas Dukleth

- Release Maintainers:
  - 25.05 -- Paul Derscheid
  - 24.11 -- Fridolin Somers
  - 24.05 -- Jesse Maseto
  - 22.11 -- Catalyst IT (Wainui, Alex, Aleisha)

- Release Maintainer assistants:
  - 25.05 -- Martin Renvoize
  - 24.11 -- Baptiste Wojtkowski
  - 24.05 -- Laura Escamilla

## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 22.11.33
<div style="column-count: 2;">

- [Cape Libraries Automated Materials Sharing](https://info.clamsnet.org)
</div>

We thank the following individuals who contributed patches to Koha 22.11.33
<div style="column-count: 2;">

- Aleisha Amohia (2)
- David Cook (1)
- Brendan Lawlor (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 22.11.33
<div style="column-count: 2;">

- [Cape Libraries Automated Materials Sharing](https://info.clamsnet.org) (1)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha) (2)
- [Prosentient Systems](https://www.prosentient.com.au) (1)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- David Cook (1)
- Brendan Lawlor (1)
- Owen Leonard (1)
- Marcel de Rooy (1)
- wainuiwitikapark (2)
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

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 04 Dec 2025 21:01:36.
