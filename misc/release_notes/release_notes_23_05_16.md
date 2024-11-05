# RELEASE NOTES FOR KOHA 23.05.16
05 Nov 2024

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 23.05.16 can be downloaded from:

- [Download](http://download.koha-community.org/koha-23.05.16.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 23.05.16 is a bugfix/maintenance release.

It includes 5 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [33339](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33339) Formula injection (CSV Injection) in export functionality
- [37724](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37724) Remove Koha version number from public generator metadata
- [37737](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37737) Users with 'execute_reports' permission can create reports 23.11 and lower
- [37861](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37861) Fix XSS vulnerability in barcode append function

  **Sponsored by** *KillerRabbitAos*

## Bugfixes

### Architecture, internals, and plumbing

#### Other bugs fixed

- [38234](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38234) Remove unused vulnerable jszip library file

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Chinese (Traditional)](https://koha-community.org/manual/23.05/zh_Hant/html/) (77%)
- [English](https://koha-community.org/manual/23.05//html/) (100%)
- [English (USA)](https://koha-community.org/manual/23.05/en/html/)
- [French](https://koha-community.org/manual/23.05/fr/html/) (49%)
- [German](https://koha-community.org/manual/23.05/de/html/) (38%)
- [Greek](https://koha-community.org/manual/23.05//html/) (73%)
- [Hindi](https://koha-community.org/manual/23.05/hi/html/) (73%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (86%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified) (95%)
- Chinese (Traditional) (99%)
- Czech (70%)
- Dutch (88%)
- English (100%)
- English (New Zealand) (68%)
- English (USA)
- Finnish (99%)
- French (99%)
- French (Canada) (99%)
- German (100%)
- German (Switzerland) (55%)
- Greek (62%)
- Hindi (99%)
- Italian (91%)
- Norwegian Bokmål (78%)
- Persian (fa_ARAB) (99%)
- Polish (99%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (88%)
- Russian (98%)
- Slovak (67%)
- Spanish (100%)
- Swedish (88%)
- Telugu (76%)
- Turkish (89%)
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

The release team for Koha 23.05.16 is


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
new features in Koha 23.05.16
<div style="column-count: 2;">

- KillerRabbitAos
</div>

We thank the following individuals who contributed patches to Koha 23.05.16
<div style="column-count: 2;">

- Artur (1)
- David Cook (1)
- Jonathan Druart (1)
- Kyle M Hall (1)
- Lisette Scheer (1)
- wainuiwitikapark (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 23.05.16
<div style="column-count: 2;">

- [ByWater Solutions](https://bywatersolutions.com) (2)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha) (1)
- Independant Individuals (1)
- Koha Community Developers (1)
- [Prosentient Systems](https://www.prosentient.com.au) (1)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Nick Clemens (1)
- David Cook (1)
- Chris Cormack (2)
- Magnus Enger (1)
- Victor Grousset (1)
- Bo Gustavsson (1)
- Kyle M Hall (1)
- Brendan Lawlor (1)
- Martin Renvoize (1)
- Marcel de Rooy (1)
- wainuiwitikapark (5)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is (HEAD detached from security-23.05.x-security).

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 05 Nov 2024 22:48:49.
