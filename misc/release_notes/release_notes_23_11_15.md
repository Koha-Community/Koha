# RELEASE NOTES FOR KOHA 23.11.15
26 May 2025

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 23.11.15 can be downloaded from:

- [Download](https://download.koha-community.org/koha-23.11.15.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 23.11.15 is a bugfix/maintenance release.

It includes 1 bugfixe and 1 security fixe.

This should be the last 23.11 version, we strongly advice to upgrade to newest stable or LTS version.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [39184](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39184) Server-side template injection leading to remote code execution

## Bugfixes

### Staff interface

#### Other bugs fixed

- [36867](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36867) ILS-DI AuthorizedIPs should deny explicitly except those listed
  >This patch updates the ILS-DI authorized IPs preference to deny all IPs not listed in the preference.
  >
  >Previously if no text was entered the ILS-DI service was accessible by all IPs, now it requires explicitly defining the IPs that can access the service.
  >
  >Upgrading libraries using ILS-DI should check that they have the necessary IPs defined in the system preference.

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Armenian (hy_ARMN)](https://koha-community.org/manual/23.11//html/) (100%)
- [Chinese (Traditional)](https://koha-community.org/manual/23.11/zh_Hant/html/) (98%)
- [English](https://koha-community.org/manual/23.11//html/) (100%)
- [English (USA)](https://koha-community.org/manual/23.11/en/html/)
- [Finnish](https://koha-community.org/manual/23.11//html/) (100%)
- [French](https://koha-community.org/manual/23.11/fr/html/) (72%)
- [German](https://koha-community.org/manual/23.11/de/html/) (98%)
- [Greek](https://koha-community.org/manual/23.11//html/) (96%)
- [Hindi](https://koha-community.org/manual/23.11/hi/html/) (70%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (99%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified) (89%)
- Chinese (Traditional) (99%)
- Czech (70%)
- Dutch (88%)
- English (100%)
- English (New Zealand) (66%)
- English (USA)
- Finnish (100%)
- French (99%)
- French (Canada) (99%)
- German (100%)
- German (Switzerland) (52%)
- Greek (70%)
- Hindi (99%)
- Italian (84%)
- Norwegian Bokmål (76%)
- Persian (fa_ARAB) (98%)
- Polish (100%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (88%)
- Russian (96%)
- Slovak (63%)
- Spanish (100%)
- Swedish (87%)
- Telugu (70%)
- Tetum (53%)
- Turkish (86%)
- Ukrainian (75%)
- hyw_ARMN (generated) (hyw_ARMN) (65%)
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

The release team for Koha 23.11.15 is


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



We thank the following individuals who contributed patches to Koha 23.11.15
<div style="column-count: 2;">

- Nick Clemens (1)
- David Cook (1)
- Fridolin Somers (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 23.11.15
<div style="column-count: 2;">

- [BibLibre](https://www.biblibre.com) (1)
- [ByWater Solutions](https://bywatersolutions.com) (1)
- [Prosentient Systems](https://www.prosentient.com.au) (1)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Magnus Enger (1)
- Marcel de Rooy (1)
- Fridolin Somers (2)
- wainuiwitikapark (2)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 23.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 26 May 2025 13:56:56.
