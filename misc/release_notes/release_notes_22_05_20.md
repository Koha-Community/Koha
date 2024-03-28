# RELEASE NOTES FOR KOHA 22.05.20
28 Mar 2024

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 22.05.20 can be downloaded from:

- [Download](http://download.koha-community.org/koha-22.05.20.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 22.05.20 is a security bugfix/maintenance release.

It includes 2 enhancements, 20 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [24879](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24879) Add missing authentication checks
- [30524](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30524) Add base framework for dealing with CSRF in Koha
- [35960](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35960) XSS in staff login form
- [36244](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36244) Template toolkit syntax not escaped in letter templates
- [36322](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36322) Can run docs/**/*.pl from the UI
- [36323](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36323) koha_perl_deps.pl can be run from the UI

## Bugfixes

### Architecture, internals, and plumbing

#### Critical bugs fixed

- [29510](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29510) objects.find should call search_limited if present
- [35890](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35890) AutoLocation system preference + setting the library IP field - can still login and unexpected results

#### Other bugs fixed

- [35918](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35918) Incorrect library used when AutoLocation configured using the same IP
- [36072](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36072) Can request articles even if ArticleRequests is off
- [36092](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36092) sessionID not passed to the template on auth.tt
- [36176](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36176) [23.11 and below] We need tests to check for 'cud-' operations in stable branches (pre-24.05)

### Authentication

#### Critical bugs fixed

- [36034](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36034) cas_ticket is set to serialized patron object in session

### Cataloging

#### Critical bugs fixed

- [35343](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35343) record method, required for bug 26611, missing from Koha::Authority

### Circulation

#### Critical bugs fixed

- [35518](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35518) Call to C4::Context->userenv happens before it's gets populated breaks code logic in circulation

### OPAC

#### Critical bugs fixed

- [35941](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35941) OPAC user can guess clubs of other users

#### Other bugs fixed

- [35942](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35942) OPAC user can enroll several times to the same club

### Reports

#### Critical bugs fixed

- [31988](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31988) manager.pl is only user for "Catalog by item type" report

### Test Suite

#### Other bugs fixed

- [35904](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35904) C4::Auth::checkauth cannot be tested easily

### Web services

#### Critical bugs fixed

- [34893](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34893) ILS-DI can return the wrong patron for AuthenticatePatron

## Enhancements 

### Architecture, internals, and plumbing

#### Enhancements

- [27342](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27342) Improve readability and improvement of C4::Auth::get_template_and_user

### Serials

#### Enhancements

- [23352](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23352) Define serial's collection in the subscription

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Chinese (Traditional)](https://koha-community.org/manual/22.05//html/) (63%)
- [English](https://koha-community.org/manual/22.05//html/) (100%)
- [English (USA)](https://koha-community.org/manual/22.05/en/html/)
- [French](https://koha-community.org/manual/22.05/fr/html/) (41%)
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
- Dutch (84%)
- English (100%)
- English (New Zealand) (69%)
- English (USA)
- Finnish (95%)
- French (99%)
- French (Canada) (99%)
- German (100%)
- German (Switzerland) (61%)
- Greek (61%)
- Hindi (100%)
- Italian (100%)
- Norwegian Bokmål (61%)
- Persian (fa_ARAB) (69%)
- Polish (99%)
- Portuguese (Brazil) (83%)
- Portuguese (Portugal) (85%)
- Russian (79%)
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

The release team for Koha 22.05.20 is


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



We thank the following individuals who contributed patches to Koha 22.05.20
<div style="column-count: 2;">

- Aleisha Amohia (1)
- Tomás Cohen Arazi (7)
- Nick Clemens (1)
- Jonathan Druart (22)
- Lucas Gass (1)
- Victor Grousset (1)
- Kyle M Hall (4)
- Andreas Jonsson (3)
- Julian Maurice (1)
- Martin Renvoize (3)
- root (1)
- Marcel de Rooy (1)
- Fridolin Somers (2)
- Wainui Witika-Park (6)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 22.05.20
<div style="column-count: 2;">

- BibLibre (3)
- ByWater-Solutions (6)
- Catalyst (6)
- Catalyst Open Source Academy (1)
- Koha Community Developers (23)
- Kreablo AB (3)
- PTFS-Europe (3)
- Rijksmuseum (1)
- Theke Solutions (7)
- wainuiwitikapark-lp.dynamic.wgtn.cat-it.co.nz (1)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Aleisha Amohia (6)
- Tomás Cohen Arazi (2)
- Matt Blenkinsop (7)
- Nick Clemens (1)
- Frédéric Demians (3)
- Jonathan Druart (4)
- Magnus Enger (2)
- Lucas Gass (2)
- Victor Grousset (2)
- Kyle M Hall (13)
- Andrew Fuerste Henry (1)
- Owen Leonard (1)
- David Nind (2)
- Martin Renvoize (24)
- Marcel de Rooy (6)
- Fridolin Somers (4)
- Wainui Witika-Park (29)
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

Autogenerated release notes updated last on 28 Mar 2024 00:07:46.
