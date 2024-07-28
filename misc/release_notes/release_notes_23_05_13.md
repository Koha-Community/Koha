# RELEASE NOTES FOR KOHA 23.05.13
28 Jul 2024

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 23.05.13 can be downloaded from:

- [Download](http://download.koha-community.org/koha-23.05.13.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 23.05.13 is a bugfix/maintenance release.

It includes 6 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [37018](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37018) SQL injection using q under api/
  >24.05.02
- [37146](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37146) plugin_launcher.pl allows running of any Perl file on file system
  >24.05.02
- [37210](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37210) SQL injection in overdue.pl
  >24.05.02
- [37247](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37247) On subscriptions operation allowed without authentication
  >24.05.02

## Bugfixes

### ERM

#### Critical bugs fixed

- [35115](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35115) ERM - Potential MARC data loss when importing titles from list

### Patrons

#### Other bugs fixed

- [36816](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36816) OPAC - Patron 'submit update request' does not work for clearing patron attribute types

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Chinese (Traditional)](https://koha-community.org/manual/23.05/zh_Hant/html/) (76%)
- [English](https://koha-community.org/manual/23.05//html/) (100%)
- [English (USA)](https://koha-community.org/manual/23.05/en/html/)
- [French](https://koha-community.org/manual/23.05/fr/html/) (46%)
- [German](https://koha-community.org/manual/23.05/de/html/) (38%)
- [Greek](https://koha-community.org/manual/23.05//html/) (45%)
- [Hindi](https://koha-community.org/manual/23.05/hi/html/) (77%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (86%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Traditional) (99%)
- Czech (70%)
- Dutch (83%)
- English (100%)
- English (New Zealand) (68%)
- English (USA)
- Finnish (99%)
- French (100%)
- French (Canada) (99%)
- German (100%)
- German (Switzerland) (55%)
- Greek (61%)
- Hindi (99%)
- Italian (91%)
- Norwegian Bokmål (78%)
- Persian (fa_ARAB) (99%)
- Polish (100%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (88%)
- Russian (98%)
- Slovak (66%)
- Spanish (99%)
- Swedish (88%)
- Telugu (76%)
- Turkish (88%)
- Ukrainian (80%)
- hyw_ARMN (generated) (hyw_ARMN) (69%)
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

The release team for Koha 23.05.13 is


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



We thank the following individuals who contributed patches to Koha 23.05.13
<div style="column-count: 2;">

- Pedro Amorim (1)
- Tomás Cohen Arazi (5)
- Nick Clemens (1)
- David Cook (1)
- Jonathan Druart (4)
- Julian Maurice (1)
- Martin Renvoize (4)
- Fridolin Somers (2)
- wainuiwitikapark (2)
- Hammat Wele (2)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 23.05.13
<div style="column-count: 2;">

- [BibLibre](https://www.biblibre.com) (3)
- [ByWater Solutions](https://bywatersolutions.com) (1)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha) (2)
- Koha Community Developers (4)
- [Prosentient Systems](https://www.prosentient.com.au) (1)
- [PTFS Europe](https://ptfs-europe.com) (5)
- [Solutions inLibro inc](https://inlibro.com) (2)
- [Theke Solutions](https://theke.io) (5)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Pedro Amorim (3)
- Tomás Cohen Arazi (6)
- Nick Clemens (1)
- Chris Cormack (4)
- Jonathan Druart (10)
- Katrin Fischer (2)
- Victor Grousset (2)
- Martin Renvoize (8)
- Marcel de Rooy (4)
- Fridolin Somers (2)
- wainuiwitikapark (21)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 23.05.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 28 Jul 2024 23:44:35.
