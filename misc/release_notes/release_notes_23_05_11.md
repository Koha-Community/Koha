# RELEASE NOTES FOR KOHA 23.05.11
07 May 2024

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 23.05.11 can be downloaded from:

- [Download](http://download.koha-community.org/koha-23.05.11.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 23.05.11 is a bugfix/maintenance release.

It includes 1 enhancements, 1 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).

#### Security bugs

- [19613](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19613) Scrub borrowers fields: borrowernotes opacnote
- [36149](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36149) userenv stored in plack worker's memory and survive from one request to another
- [36382](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36382) XSS in showLastPatron dropdown
- [36532](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36532) Any authenticated OPAC user can run opac-dismiss-message.pl for any user/any message

## Bugfixes

### Cataloging

#### Critical bugs fixed

- [36511](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36511) Some scripts missing a dependency following Bug 24879

## Enhancements 

### Architecture, internals, and plumbing

#### Enhancements

- [36328](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36328) C4::Scrubber should allow more HTML tags

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Chinese (Traditional)](https://koha-community.org/manual/23.05//html/) (70%)
- [English](https://koha-community.org/manual/23.05//html/) (100%)
- [English (USA)](https://koha-community.org/manual/23.05/en/html/)
- [French](https://koha-community.org/manual/23.05/fr/html/) (41%)
- [German](https://koha-community.org/manual/23.05/de/html/) (40%)
- [Hindi](https://koha-community.org/manual/23.05/hi/html/) (81%)

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
- German (99%)
- German (Switzerland) (55%)
- Greek (55%)
- Hindi (100%)
- Italian (91%)
- Norwegian Bokmål (78%)
- Persian (fa_ARAB) (99%)
- Polish (100%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (88%)
- Russian (98%)
- Slovak (66%)
- Spanish (100%)
- Swedish (88%)
- Telugu (76%)
- Turkish (87%)
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

The release team for Koha 23.05.11 is


- Release Manager: Katrin Fischer

- Release Manager assistants:
  - Tomás Cohen Arazi
  - Martin Renvoize
  - Jonathan Druart

- QA Manager: Marcel de Rooy

- QA Team:
  - Marcel de Rooy
  - Julian Maurice
  - Lucas Gass
  - Victor Grousset
  - Kyle M Hall
  - Nick Clemens
  - Martin Renvoize
  - Tomás Cohen Arazi
  - Aleisha Amohia
  - Emily Lamancusa
  - David Cook
  - Jonathan Druart
  - Pedor Amorim

- Topic Experts:
  - UI Design -- Owen Leonard
  - Zebra -- Fridolin Somers
  - REST API -- Tomás Cohen Arazi
  - ERM -- Matt Blenkinsop
  - ILL -- Pedro Amorim
  - SIP2 -- Matthias Meusburger
  - CAS -- Matthias Meusburger

- Bug Wranglers:
  - Aleisha Amohia
  - Indranil Das Gupta

- Packaging Managers:
  - Mason James
  - Indranil Das Gupta
  - Tomás Cohen Arazi

- Documentation Manager: Aude Charillon

- Documentation Team:
  - Caroline Cyr La Rose
  - Kelly McElligott
  - Philip Orr
  - Marie-Luce Laflamme
  - Lucy Vaux-Harvey

- Translation Manager: Jonathan Druart


- Wiki curators: 
  - Thomas Dukleth
  - Katrin Fischer

- Release Maintainers:
  - 23.11 -- Fridolin Somers
  - 23.05 -- Lucas Gass
  - 22.11 -- Frédéric Demians
  - 22.05 -- Danyon Sewell

- Release Maintainer assistants:
  - 22.05 -- Wainui Witika-Park

## Credits



We thank the following individuals who contributed patches to Koha 23.05.11
<div style="column-count: 2;">

- Nick Clemens (2)
- Jonathan Druart (7)
- Lucas Gass (1)
- Owen Leonard (1)
- Julian Maurice (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 23.05.11
<div style="column-count: 2;">

- Athens County Public Libraries (1)
- BibLibre (1)
- ByWater-Solutions (3)
- Koha Community Developers (7)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Nick Clemens (6)
- David Cook (6)
- danyonsewell (1)
- Jonathan Druart (1)
- Katrin Fischer (1)
- Lucas Gass (11)
- Kyle M Hall (3)
- Owen Leonard (1)
- Fridolin Somers (11)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 23.05.x-security.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 07 May 2024 16:44:24.
