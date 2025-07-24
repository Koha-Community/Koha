# RELEASE NOTES FOR KOHA 24.11.07
24 Jul 2025

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 24.11.07 can be downloaded from:

- [Download](https://download.koha-community.org/koha-24.11.07.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 24.11.07 is a bugfix/maintenance release.

It includes 7 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


## Bugfixes

### Architecture, internals, and plumbing

#### Other bugs fixed

- [40034](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40034) CheckReserves dies if itype doesn't exist

### Circulation

#### Other bugs fixed

- [39307](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39307) console.error on circ/circulation.pl page

### ILL

#### Critical bugs fixed

- [40057](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40057) Database update 24.12.00.017 fails if old ILL data points to non-existent borrowernumber
  >This fixes a database update related to ILL requests, for bug 32630 - Don't delete ILL requests when patron is deleted, added in Koha 25.05.
  >
  >Background: Some databases have very old ILL requests where 'borrowernumber' has a value of a borrowernumber that doesn't exist. We're not exactly how the data ended up this way, but it's happened at least twice now for one provider.

#### Other bugs fixed

- [32630](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32630) Don't delete ILL requests when patron is deleted

  **Sponsored by** *UK Health Security Agency*

### Label/patron card printing

#### Other bugs fixed

- [40061](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40061) Cannot delete image from patron card creator
  >This fixes deleting patron images in the patron card creator (Tools > Patrons and circulation > Patron card creator > +New Image). 
  >
  >Deleting images now works:
  >- using the delete button beside each image
  >- using the checkbox to select and delete the last image, if there is only one image
  >
  >(This is partly related to the CSRF changes added in Koha 24.05 to improve form security.)

  **Sponsored by** *Athens County Public Libraries*

### Templates

#### Other bugs fixed

- [39626](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39626) Display patron name in 'Holds to pull' report using standard template
- [40042](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40042) search_indexes.inc may have undefined index var

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [English (USA)](https://koha-community.org/manual/24.11/en/html/)
- [French](https://koha-community.org/manual/24.11/fr/html/) (73%)
- [German](https://koha-community.org/manual/24.11/de/html/) (97%)
- [Greek](https://koha-community.org/manual/24.11/el/html/) (99%)
- [Hindi](https://koha-community.org/manual/24.11/hi/html/) (70%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (95%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified Han script) (86%)
- Chinese (Traditional Han script) (99%)
- Czech (67%)
- Dutch (89%)
- English (100%)
- English (New Zealand) (63%)
- English (USA)
- Finnish (99%)
- French (99%)
- French (Canada) (99%)
- German (100%)
- Greek (67%)
- Hindi (97%)
- Italian (81%)
- Norwegian Bokmål (74%)
- Persian (fa_ARAB) (97%)
- Polish (100%)
- Portuguese (Brazil) (98%)
- Portuguese (Portugal) (87%)
- Russian (94%)
- Slovak (61%)
- Spanish (99%)
- Swedish (87%)
- Telugu (68%)
- Tetum (52%)
- Turkish (83%)
- Ukrainian (73%)
- Western Armenian (hyw_ARMN) (62%)
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

The release team for Koha 24.11.07 is


- Release Manager: Lucas Gass

- QA Manager: Martin Renvoize

- QA Team:
  - Andrew Fuerste-Henry
  - Andrii Nugged
  - Baptiste Wojtkowski
  - Brendan Lawlor
  - David Cook
  - Emily Lamancusa
  - Jonathan Druart
  - Julian Maurice
  - Kyle Hall
  - Laura Escamilla
  - Lisette Scheer
  - Marcel de Rooy
  - Nick Clemens
  - Paul Derscheid
  - Petro V
  - Tomás Cohen Arazi
  - Victor Grousset

- Documentation Manager: David Nind

- Documentation Team:
  - Aude Charillon
  - Caroline Cyr La Rose
  - Donna Bachowski
  - Heather Hernandez
  - Kristi Krueger
  - Philip Orr

- Translation Manager: Jonathan Druart


- Wiki curators: 
  - George Williams
  - Thomas Dukleth

- Release Maintainers:
  - 25.05 -- Paul Derscheid
  - 24.11 -- Fridolin Somers
  - 24.05 -- Jesse Maseto
  - 22.11 -- Catalyst IT (Wainui, Alex, Aleisha)

- Release Maintainer assistants:
  - 25.05 -- Martin Renvoize
  - 24.11 -- Baptiste Wojtkowski
  - 24.05 -- Laura Escamilla

## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 24.11.07
<div style="column-count: 2;">

- Athens County Public Libraries
- UK Health Security Agency
</div>

We thank the following individuals who contributed patches to Koha 24.11.07
<div style="column-count: 2;">

- Pedro Amorim (7)
- Tomás Cohen Arazi (2)
- Paul Derscheid (1)
- Katrin Fischer (2)
- Lucas Gass (1)
- Owen Leonard (2)
- Fridolin Somers (2)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 24.11.07
<div style="column-count: 2;">

- Athens County Public Libraries (2)
- [BibLibre](https://www.biblibre.com) (2)
- [Bibliotheksservice-Zentrum Baden-Württemberg (BSZ)](https://bsz-bw.de) (2)
- [ByWater Solutions](https://bywatersolutions.com) (1)
- [LMSCloud](https://www.lmscloud.de) (1)
- [Open Fifth](https://openfifth.co.uk/) (7)
- [Theke Solutions](https://theke.io) (2)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Emmanuel Bétemps (1)
- Paul Derscheid (6)
- Magnus Enger (1)
- Jeremy Evans (6)
- Katrin Fischer (8)
- Lucas Gass (7)
- Brendan Lawlor (1)
- David Nind (3)
- Marcel de Rooy (6)
- Caroline Cyr La Rose (2)
- Lisette Scheer (6)
- Fridolin Somers (1)
- Baptiste Wojtkowski (14)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 24.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 24 Jul 2025 20:15:36.
