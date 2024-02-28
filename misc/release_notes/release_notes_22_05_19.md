# RELEASE NOTES FOR KOHA 22.05.19
28 Feb 2024

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 22.05.19 can be downloaded from:

- [Download](http://download.koha-community.org/koha-22.05.19.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 22.05.19 is a bugfix/maintenance release.

It includes 11 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [29510](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29510) objects.find should call search_limited if present
- [30524](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30524) Add base framework for dealing with CSRF in Koha
- [35890](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35890) AutoLocation system preference + setting the library IP field - can still login and unexpected results
- [35918](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35918) Incorrect library used when AutoLocation configured using the same IP
- [35941](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35941) OPAC user can guess clubs of other users
- [35942](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35942) OPAC user can enroll several times to the same club
- [36072](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36072) Can request articles even if ArticleRequests is off

## Bugfixes

### Architecture, internals, and plumbing

#### Other bugs fixed

- [36092](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36092) sessionID not passed to the template on auth.tt

### Authentication

#### Critical bugs fixed

- [36034](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36034) cas_ticket is set to serialized patron object in session

### Circulation

#### Critical bugs fixed

- [35518](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35518) Call to C4::Context->userenv happens before it's gets populated breaks code logic in circulation

### Test Suite

#### Other bugs fixed

- [35904](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35904) C4::Auth::checkauth cannot be tested easily

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Chinese (Traditional)](https://koha-community.org/manual/22.05//html/) (61%)
- [English](https://koha-community.org/manual/22.05//html/) (100%)
- [English (USA)](https://koha-community.org/manual/22.05/en/html/)
- [French](https://koha-community.org/manual/22.05/fr/html/) (39%)
- [German](https://koha-community.org/manual/22.05/de/html/) (40%)
- [Hindi](https://koha-community.org/manual/22.05/hi/html/) (75%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (81%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Traditional) (95%)
- Czech (71%)
- Dutch (83%)
- English (100%)
- English (New Zealand) (69%)
- English (USA)
- Finnish (95%)
- French (100%)
- French (Canada) (99%)
- German (100%)
- German (Switzerland) (61%)
- Greek (61%)
- Hindi (100%)
- Italian (100%)
- Norwegian Bokmål (61%)
- Persian (fa_ARAB) (68%)
- Polish (99%)
- Portuguese (Brazil) (83%)
- Portuguese (Portugal) (85%)
- Russian (78%)
- Slovak (71%)
- Spanish (100%)
- Swedish (87%)
- Telugu (85%)
- Turkish (99%)
- Ukrainian (73%)
- hyw_ARMN (generated) (hyw_ARMN) (76%)
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

The release team for Koha 22.05.19 is


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



We thank the following individuals who contributed patches to Koha 22.05.19
<div style="column-count: 2;">

- Aleisha Amohia (1)
- Tomás Cohen Arazi (5)
- Nick Clemens (1)
- Jonathan Druart (11)
- Victor Grousset (1)
- Kyle M Hall (3)
- Andreas Jonsson (1)
- Martin Renvoize (1)
- Marcel de Rooy (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 22.05.19
<div style="column-count: 2;">

- ByWater-Solutions (4)
- Catalyst Open Source Academy (1)
- Koha Community Developers (12)
- Kreablo AB (1)
- PTFS-Europe (1)
- Rijksmuseum (1)
- Theke Solutions (5)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Aleisha Amohia (6)
- Tomás Cohen Arazi (1)
- Matt Blenkinsop (6)
- Frédéric Demians (2)
- Jonathan Druart (2)
- Magnus Enger (2)
- Lucas Gass (1)
- Victor Grousset (1)
- Kyle M Hall (11)
- David Nind (1)
- Martin Renvoize (13)
- Marcel de Rooy (3)
- Fridolin Somers (4)
- Wainui Witika-Park (13)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 22.05.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 28 Feb 2024 21:48:13.
