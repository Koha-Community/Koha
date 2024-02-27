# RELEASE NOTES FOR KOHA 22.11.15
27 févr. 2024

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 22.11.15 can be downloaded from:

- [Download](http://download.koha-community.org/koha-22.11.15.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 22.11.15 is a bugfix/maintenance release.

It includes 9 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [29510](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29510) objects.find should call search_limited if present
- [34623](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34623) Update jQuery-validate plugin to 1.20.0
- [35890](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35890) AutoLocation system preference + setting the library IP field - can still login and unexpected results
- [35918](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35918) Incorrect library used when AutoLocation configured using the same IP
- [35941](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35941) OPAC user can guess clubs of other users
- [36072](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36072) Can request articles even if ArticleRequests is off

## Bugfixes

### Authentication

#### Critical bugs fixed

- [36034](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36034) cas_ticket is set to serialized patron object in session

### Circulation

#### Critical bugs fixed

- [35518](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35518) Call to C4::Context->userenv happens before it's gets populated breaks code logic in circulation

### Web services

#### Critical bugs fixed

- [34893](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34893) ILS-DI can return the wrong patron for AuthenticatePatron

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Chinese (Traditional)](https://koha-community.org/manual/22.11//html/) (61%)
- [English](https://koha-community.org/manual/22.11//html/) (100%)
- [English (USA)](https://koha-community.org/manual/22.11/en/html/)
- [French](https://koha-community.org/manual/22.11/fr/html/) (38%)
- [German](https://koha-community.org/manual/22.11/de/html/) (40%)
- [Hindi](https://koha-community.org/manual/22.11/hi/html/) (74%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (75%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Traditional) (81%)
- Czech (70%)
- Dutch (88%)
- English (100%)
- English (New Zealand) (69%)
- English (USA)
- English (United Kingdom) (99%)
- Finnish (96%)
- French (100%)
- French (Canada) (96%)
- German (100%)
- German (Switzerland) (56%)
- Greek (57%)
- Hindi (100%)
- Italian (92%)
- Norwegian Bokmål (69%)
- Persian (fa_ARAB) (75%)
- Polish (99%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (88%)
- Russian (93%)
- Slovak (67%)
- Spanish (100%)
- Swedish (88%)
- Telugu (77%)
- Turkish (88%)
- Ukrainian (79%)
- hyw_ARMN (generated) (hyw_ARMN) (70%)
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

The release team for Koha 22.11.15 is


- Release Manager: Tomás Cohen Arazi

- Release Manager assistants:
  - Jonathan Druart
  - Martin Renvoize

- QA Manager: Katrin Fischer

- QA Team:
  - Aleisha Amohia
  - Nick Clemens
  - Jonathan Druart
  - Lucas Gass
  - Victor Grousset
  - Kyle M Hall
  - Joonas Kylmälä
  - Andrew Nugged
  - Martin Renvoize
  - Marcel de Rooy
  - Fridolin Somers
  - Petro Vashchuk
  - David Cook

- Topic Experts:
  - UI Design -- Owen Leonard
  - Zebra -- Fridolin Somers

- Bug Wranglers:
  - Aleisha Amohia
  - Jake Deery
  - Lucas Gass
  - Séverine Queune

- Packaging Manager: Mason James

- Documentation Manager: David Nind

- Documentation Team:
  - Donna Bachowski
  - Aude Charillon
  - Martin Renvoize
  - Lucy Vaux-Harvey

- Translation Manager: Bernardo González Kriegel


- Wiki curators: 
  - Thomas Dukleth
  - Katrin Fischer

- Release Maintainers:
  - 22.05 -- Lucas Gass
  - 21.11 -- Arthur Suzuki
  - 21.05 -- Victor Grousset

## Credits



We thank the following individuals who contributed patches to Koha 22.11.15
<div style="column-count: 2;">

- Aleisha Amohia (1)
- Tomás Cohen Arazi (2)
- Nick Clemens (1)
- Frédéric Demians (4)
- Jonathan Druart (7)
- Andreas Jonsson (1)
- Owen Leonard (1)
- Martin Renvoize (4)
- Marcel de Rooy (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 22.11.15
<div style="column-count: 2;">

- Athens County Public Libraries (1)
- ByWater-Solutions (1)
- Catalyst Open Source Academy (1)
- Koha Community Developers (7)
- Kreablo AB (1)
- PTFS-Europe (4)
- Rijksmuseum (1)
- Tamil (4)
- Theke Solutions (2)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Matt Blenkinsop (3)
- Frédéric Demians (13)
- Jonathan Druart (1)
- Magnus Enger (2)
- Lucas Gass (2)
- Victor Grousset (1)
- Kyle M Hall (7)
- David Nind (1)
- Martin Renvoize (7)
- Marcel de Rooy (2)
- Fridolin Somers (12)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 22.11.x-security.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 27 févr. 2024 06:56:02.
