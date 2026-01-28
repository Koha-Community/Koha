# RELEASE NOTES FOR KOHA 25.05.07
28 Jan 2026

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 25.05.07 can be downloaded from:

- [Download](https://download.koha-community.org/koha-25.05.07.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 25.05.07 is a bugfix/maintenance release.

It includes 10 enhancements, 8 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [41593](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41593) Authenticated SQL Injection in staff side suggestions
- [41662](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41662) CSRF-vulnerability in opac-patron-consent.pl.

## Bugfixes

### Acquisitions

#### Other bugs fixed

- [39468](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39468) EDI message status should be case insensitive
  >Fix EDI message status display in acquisitions so matching is case-insensitive by converting edi_order.status to lowercase before comparison.

### Architecture, internals, and plumbing

#### Other bugs fixed

- [40163](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40163) Several http links should be moved to https
- [40524](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40524) Stored XSS run by DataTables Print button in staff interface
  >Adds a custom function to ensure cleaner outputs when using DateTable's print button.

### Database

#### Critical bugs fixed

- [41421](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41421) Bug 35830 DB update must be idempotent
  >25.11.00,25.05.06,24.11.11,24.05.16,22.11.33

### Preservation

#### Critical bugs fixed

- [41364](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41364) Error in preservation module breadcrumb

### Staff interface

#### Other bugs fixed

- [41217](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41217) Missing class on body tag for reserve/hold-group.tt

## Enhancements 

### Accessibility

#### Enhancements

- [39677](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39677) Add the role presentation to the vertical divider in the navigation
  >Accessibility improvement: Vertical dividers in the OPAC navigation now include role="presentation" to ensure they are correctly identified as decorative elements. This provides clearer semantics for assistive technologies without affecting display or design.

### Architecture, internals, and plumbing

#### Enhancements

- [40527](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40527) Add SECURITY.md to Koha
  >This enhancement adds a markdown file to the Koha project repository to make it clear how to report security issues.
- [40919](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40919) Unnecessary DB access in Koha::Item::Transfer->receive

### Authentication

#### Enhancements

- [34164](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34164) OAuth2/OIDC should redirect to page that initiated login

### REST API

#### Enhancements

- [39830](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39830) Add order claim object definition

### Staff interface

#### Enhancements

- [36518](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36518) Add unique IDs to the fieldsets of the item search form to enable customization
  >This enhancement adds IDs to the fieldsets on the staff interface search form (Search > Item search), to make CSS customization easier. The fieldset IDs are:
  >- Library and location section: librarylocation
  >- Item information section: access_and_condition
  >- Barcode search section: barcodesearch
  >- Call number section: callnumber_checkouts
- [38942](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38942) Item template toolbar is not like other toolbars
  >This enhancement improves the item-template-toolbar in Koha, adding some classes to be consistent with other toolbars in Koha.
- [40757](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40757) Highlight circulation rules on click

### Templates

#### Enhancements

- [16721](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16721) Add table configuration to serial claims table

  **Sponsored by** *Athens County Public Libraries*
- [28146](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28146) E-mail address used on error pages should respect ReplytoDefault

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [English (USA)](https://koha-community.org/manual/25.05/en/html/)
- [French](https://koha-community.org/manual/25.05/fr/html/) (74%)
- [German](https://koha-community.org/manual/25.05/de/html/) (90%)
- [Greek](https://koha-community.org/manual/25.05/el/html/) (94%)
- [Hindi](https://koha-community.org/manual/25.05/hi/html/) (64%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (92%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified Han script) (83%)
- Chinese (Traditional Han script) (97%)
- Czech (67%)
- Dutch (86%)
- English (100%)
- English (New Zealand) (61%)
- English (USA)
- Finnish (99%)
- French (99%)
- French (Canada) (99%)
- German (100%)
- Greek (65%)
- Hindi (94%)
- Italian (80%)
- Norwegian Bokmål (71%)
- Persian (fa_ARAB) (93%)
- Polish (99%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (87%)
- Russian (93%)
- Slovak (58%)
- Spanish (98%)
- Swedish (88%)
- Telugu (65%)
- Turkish (80%)
- Ukrainian (74%)
- Western Armenian (hyw_ARMN) (60%)
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

The release team for Koha 25.05.07 is


- Release Manager: Lucas Gass

- QA Manager: Martin Renvoize

- QA Team:
  - Marcel de Rooy
  - Martin Renvoize
  - Jonathan Druart
  - Laura Escamilla
  - Lucas Gass
  - Tomás Cohen Arazi
  - Lisette Scheer
  - Nick Clemens
  - Paul Derscheid
  - Emily Lamancusa
  - David Cook
  - Matt Blenkinsop
  - Andrew Fuerste-Henry
  - Brendan Lawlor
  - Pedro Amorim
  - Kyle M Hall
  - Aleisha Amohia
  - David Nind
  - Baptiste Wojtkowski
  - Jan Kissig
  - Katrin Fischer
  - Thomas Klausner
  - Julian Maurice
  - Owen Leonard

- Documentation Manager: David Nind

- Documentation Team:
  - Philip Orr
  - Aude Charillon
  - Caroline Cyr La Rose

- Translation Manager: Jonathan Druart


- Wiki curators: 
  - George Williams
  - Thomas Dukleth

- Release Maintainers:
  - 25.11 -- Jacob O'Mara
  - 25.05 -- Laura Escamilla
  - 24.11 -- Fridolin Somers
  - 22.11 -- Wainui Witika-Park (Catalyst IT)

- Release Maintainer assistants:
  - 25.11 -- Chloé Zermatten
  - 24.11 -- Baptiste Wojtkowski
  - 22.11 -- Alex Buckley & Aleisha Amohia

## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 25.05.07
<div style="column-count: 2;">

- Athens County Public Libraries
</div>

We thank the following individuals who contributed patches to Koha 25.05.07
<div style="column-count: 2;">

- Rachel A-M (1)
- Tomás Cohen Arazi (6)
- Nick Clemens (1)
- David Cook (5)
- Paul Derscheid (2)
- Jonathan Druart (2)
- Laura Escamilla (3)
- Lucas Gass (4)
- David Gustafsson (1)
- Brendan Lawlor (1)
- Owen Leonard (1)
- Nina Martinez (1)
- Marcel de Rooy (1)
- Lisette Scheer (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 25.05.07
<div style="column-count: 2;">

- Athens County Public Libraries (1)
- [BibLibre](https://www.biblibre.com) (1)
- [ByWater Solutions](https://bywatersolutions.com) (9)
- [Cape Libraries Automated Materials Sharing](https://info.clamsnet.org) (1)
- Göteborgs Universitet (1)
- Independant Individuals (1)
- Koha Community Developers (2)
- [LMSCloud](https://www.lmscloud.de) (2)
- [Prosentient Systems](https://www.prosentient.com.au) (5)
- Rijksmuseum, Netherlands (1)
- [Theke Solutions](https://theke.io) (6)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Tomás Cohen Arazi (1)
- David Cook (1)
- Paul Derscheid (1)
- Jonathan Druart (2)
- Laura Escamilla (19)
- Lucas Gass (1)
- Barbara Johnson (1)
- Ludovic Julien (1)
- Lukas Koszyk (1)
- Brendan Lawlor (4)
- Owen Leonard (1)
- David Nind (3)
- Martin Renvoize (8)
- Marcel de Rooy (2)
- Lisette Scheer (3)
- Michaela Sieber (1)
- Emmi Takkinen (1)
- Baptiste Wojtkowski (1)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 25.05.x-security.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 28 Jan 2026 16:08:09.
