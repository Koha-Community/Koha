# RELEASE NOTES FOR KOHA 22.11.30
26 Aug 2025

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 22.11.30 can be downloaded from:

- [Download](https://download.koha-community.org/koha-22.11.30.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 22.11.30 is a bugfix/maintenance release.

It includes 1 enhancements, 4 bugfixes.

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

### Serials

#### Other bugs fixed

- [39996](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39996) [22.11] Subscription cannot be reopened

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [English (USA)](https://koha-community.org/manual/22.11/en/html/)
- [French](https://koha-community.org/manual/22.11/fr/html/) (74%)
- [German](https://koha-community.org/manual/22.11/de/html/) (98%)
- [Greek](https://koha-community.org/manual/22.11/el/html/) (86%)
- [Hindi](https://koha-community.org/manual/22.11/hi/html/) (70%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (90%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified Han script) (96%)
- Chinese (Traditional Han script) (83%)
- Czech (72%)
- Dutch (89%)
- English (100%)
- English (New Zealand) (70%)
- English (USA)
- English (United Kingdom) (99%)
- Finnish (96%)
- French (99%)
- French (Canada) (96%)
- German (99%)
- German (Switzerland) (56%)
- Greek (72%)
- Hindi (99%)
- Italian (92%)
- Norwegian Bokmål (69%)
- Persian (fa_ARAB) (77%)
- Polish (99%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (88%)
- Russian (94%)
- Slovak (68%)
- Spanish (99%)
- Swedish (88%)
- Telugu (78%)
- Tetum (54%)
- Turkish (91%)
- Ukrainian (79%)
- Western Armenian (hyw_ARMN) (70%)
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

The release team for Koha 22.11.30 is



## Credits



We thank the following individuals who contributed patches to Koha 22.11.30
<div style="column-count: 2;">

- Tomás Cohen Arazi (2)
- Baptiste (1)
- David Cook (2)
- Martin Renvoize (1)
- Marcel de Rooy (1)
- wainuiwitikapark (1)
- Wainui Witika-Park (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 22.11.30
<div style="column-count: 2;">

- [BibLibre](https://www.biblibre.com) (1)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha) (2)
- [Open Fifth](https://openfifth.co.uk/) (1)
- [Prosentient Systems](https://www.prosentient.com.au) (2)
- Rijksmuseum, Netherlands (1)
- [Theke Solutions](https://theke.io) (2)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Pedro Amorim (1)
- Paul Derscheid (1)
- Magnus Enger (1)
- Katrin Fischer (1)
- David Flater (1)
- Cornelius Hertfelder (1)
- Jesse Maseto (1)
- Marcel de Rooy (3)
- wainuiwitikapark (5)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 22.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 26 Aug 2025 07:39:11.
