# RELEASE NOTES FOR KOHA 22.05.18
28 Jan 2024

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 22.05.18 can be downloaded from:

- [Download](http://download.koha-community.org/koha-22.05.18.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 22.05.18 is a bugfix/maintenance release.

It includes 1 enhancements, 2 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


## Security bugs

- [34893](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34893) ILS-DI can return the wrong patron for AuthenticatePatron

## Critical bugs fixed

- [35343](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35343) record method, required for bug 26611, missing from Koha::Authority

## Enhancements 

- [27342](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27342) Improve readability and improvement of C4::Auth::get_template_and_user

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Chinese (Traditional)](https://koha-community.org/manual/22.05//html/) (50%)
- [English](https://koha-community.org/manual/22.05//html/) (100%)
- [English (USA)](https://koha-community.org/manual/22.05/en/html/)
- [French](https://koha-community.org/manual/22.05/fr/html/) (39%)
- [German](https://koha-community.org/manual/22.05/de/html/) (41%)
- [Hindi](https://koha-community.org/manual/22.05/hi/html/) (68%)

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
- Czech (68%)
- Dutch (83%)
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
- Norwegian Bokmål (60%)
- Persian (fa_ARAB) (68%)
- Polish (100%)
- Portuguese (Brazil) (83%)
- Portuguese (Portugal) (85%)
- Russian (77%)
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

The release team for Koha 22.05.18 is


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



We thank the following individuals who contributed patches to Koha 22.05.18
<div style="column-count: 2;">

- Aleisha Amohia (1)
- Tomás Cohen Arazi (3)
- David Cook (1)
- Jonathan Druart (2)
- Kyle M Hall (3)
- Martin Renvoize (2)
- root (1)
- Wainui Witika-Park (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 22.05.18
<div style="column-count: 2;">

- ByWater-Solutions (3)
- Catalyst (1)
- Catalyst Open Source Academy (1)
- Koha Community Developers (2)
- Prosentient Systems (1)
- PTFS-Europe (2)
- Theke Solutions (3)
- wainuiwitikapark-lp.dynamic.wgtn.cat-it.co.nz (1)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Tomás Cohen Arazi (4)
- Matt Blenkinsop (1)
- Victor Grousset (4)
- Martin Renvoize (2)
- Wainui Witika-Park (6)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is (HEAD detached from 63ec3760d2).

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 28 Jan 2024 23:58:58.
