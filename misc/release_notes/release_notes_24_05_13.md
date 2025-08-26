# RELEASE NOTES FOR KOHA 24.05.13
26 Aug 2025

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 24.05.13 can be downloaded from:

- [Download](https://download.koha-community.org/koha-24.05.13.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 24.05.13 is a bugfix/maintenance release.

It includes 2 enhancements, 2 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [39906](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39906) Add bot challenge (in Apache layer)
- [40538](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40538) XSS in hold suspend modal in staff interface
  >Fixes XSS vulnerability in suspend hold modal and suspend hold button by refactoring the Javascript that creates the HTML.
- [40579](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40579) CSV formula injection protection

## Bugfixes

### About

#### Other bugs fixed

- [40022](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40022) Release team 25.11

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Armenian (hy_ARMN)](https://koha-community.org/manual/24.05//html/) (100%)
- [Chinese (Traditional Han script)](https://koha-community.org/manual/24.05//html/) (98%)
- [English](https://koha-community.org/manual/24.05//html/) (100%)
- [English (USA)](https://koha-community.org/manual/24.05/en/html/)
- [Finnish](https://koha-community.org/manual/24.05//html/) (100%)
- [French](https://koha-community.org/manual/24.05/fr/html/) (74%)
- [German](https://koha-community.org/manual/24.05/de/html/) (98%)
- [Greek](https://koha-community.org/manual/24.05//html/) (86%)
- [Hindi](https://koha-community.org/manual/24.05/hi/html/) (70%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (97%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified Han script) (88%)
- Chinese (Traditional Han script) (99%)
- Czech (69%)
- Dutch (88%)
- English (100%)
- English (New Zealand) (64%)
- English (USA)
- Finnish (100%)
- French (100%)
- French (Canada) (99%)
- German (99%)
- Greek (69%)
- Hindi (99%)
- Italian (84%)
- Norwegian Bokmål (75%)
- Persian (fa_ARAB) (97%)
- Polish (100%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (87%)
- Russian (95%)
- Slovak (62%)
- Spanish (99%)
- Swedish (87%)
- Telugu (69%)
- Tetum (53%)
- Turkish (85%)
- Ukrainian (74%)
- hyw_ARMN (generated) (hyw_ARMN) (63%)
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

The release team for Koha 24.05.13 is


- Release Manager: 

## Credits



We thank the following individuals who contributed patches to Koha 24.05.13
<div style="column-count: 2;">

- Tomás Cohen Arazi (2)
- David Cook (2)
- Jesse Maseto (1)
- Martin Renvoize (1)
- Marcel de Rooy (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 24.05.13
<div style="column-count: 2;">

- [ByWater Solutions](https://bywatersolutions.com) (1)
- openfifth.co.uk (1)
- [Prosentient Systems](https://www.prosentient.com.au) (2)
- Rijksmuseum, Netherlands (1)
- [Theke Solutions](https://theke.io) (2)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Pedro Amorim (1)
- David Cook (2)
- Paul Derscheid (3)
- Magnus Enger (1)
- Katrin Fischer (1)
- Cornelius Hertfelder (1)
- Jesse Maseto (1)
- Marcel de Rooy (3)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 24.05.x-security.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 26 Aug 2025 17:21:46.
