# RELEASE NOTES FOR KOHA 22.11.14
29 janv. 2024

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 22.11.14 can be downloaded from:

- [Download](http://download.koha-community.org/koha-22.11.14.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 22.11.14 is a bugfix/maintenance release.

It includes 2 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [34893](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34893) ILS-DI can return the wrong patron for AuthenticatePatron

## Bugfixes

### REST API

#### Critical bugs fixed

- [35204](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35204) REST API: POST endpoint /auth/password/validation dies on patron with expired password

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Chinese (Traditional)](https://koha-community.org/manual/22.11//html/) (50%)
- [English](https://koha-community.org/manual/22.11//html/) (100%)
- [English (USA)](https://koha-community.org/manual/22.11/en/html/)
- [French](https://koha-community.org/manual/22.11/fr/html/) (39%)
- [German](https://koha-community.org/manual/22.11/de/html/) (41%)
- [Hindi](https://koha-community.org/manual/22.11/hi/html/) (68%)

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
- Czech (66%)
- Dutch (88%)
- English (100%)
- English (New Zealand) (69%)
- English (USA)
- English (United Kingdom) (99%)
- Finnish (96%)
- French (99%)
- French (Canada) (96%)
- German (100%)
- German (Switzerland) (56%)
- Greek (57%)
- Hindi (100%)
- Italian (91%)
- Norwegian Bokmål (68%)
- Persian (fa_ARAB) (75%)
- Polish (100%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (88%)
- Russian (92%)
- Slovak (67%)
- Spanish (100%)
- Swedish (87%)
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

The release team for Koha 22.11.14 is


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



We thank the following individuals who contributed patches to Koha 22.11.14
<div style="column-count: 2;">

- Tomás Cohen Arazi (1)
- Matt Blenkinsop (2)
- David Cook (1)
- Frédéric Demians (2)
- Kyle M Hall (3)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 22.11.14
<div style="column-count: 2;">

- ByWater-Solutions (3)
- Prosentient Systems (1)
- PTFS-Europe (2)
- Tamil (2)
- Theke Solutions (1)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Tomás Cohen Arazi (6)
- Frédéric Demians (6)
- Katrin Fischer (2)
- Lucas Gass (2)
- Victor Grousset (4)
- Fridolin Somers (7)
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

Autogenerated release notes updated last on 29 janv. 2024 08:07:30.
