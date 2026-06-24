# RELEASE NOTES FOR KOHA 24.11.17
24 Jun 2026

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 24.11.17 can be downloaded from:

- [Download](https://download.koha-community.org/koha-24.11.17.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 24.11.17 is a bugfix/maintenance release with security patches.

It includes 7 bugfixes (5 security).

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [42360](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42360) SQL Injection in reports/acquisitions_stats.pl via Filter parameter
- [42363](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42363) SQL Injection in reports/catalogue_stats.pl via the Line request parameter
- [42368](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42368) SQL Injection in reports/issues_avg_stats.pl via the Filter request parameter (unvalidated string context, no placeholders)
- [42369](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42369) SQL Injection in reports/bor_issues_top.pl via the Filter request parameter (unvalidated string context, no placeholders)
- [42735](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42735) SQL Injection in reports/issues_stats.pl via PeriodTypeSel / PeriodDaySel / PeriodMonthSel / Filter parameters (unvalidated string context, no placeholders)

## Bugfixes

### Command-line Utilities

#### Other bugs fixed

- [39301](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39301) pseudonymize_statistics.pl script generates too many background jobs

### Patrons

#### Critical bugs fixed

- [41045](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41045) Suggestions manage permissions added to patrons who previously had no permissions in that category

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [English (USA)](https://koha-community.org/manual/24.11/en/html/)
- [French](https://koha-community.org/manual/24.11/fr/html/) (80%)
- [German](https://koha-community.org/manual/24.11/de/html/) (87%)
- [Greek](https://koha-community.org/manual/24.11/el/html/) (92%)
- [Hindi](https://koha-community.org/manual/24.11/hi/html/) (62%)

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
- Czech (68%)
- Dutch (88%)
- English (100%)
- English (New Zealand) (63%)
- English (USA)
- Finnish (99%)
- French (100%)
- French (Canada) (99%)
- German (100%)
- Greek (68%)
- Hindi (97%)
- Italian (83%)
- Norwegian Bokmål (73%)
- Persian (fa_ARAB) (96%)
- Polish (100%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (88%)
- Russian (94%)
- Slovak (61%)
- Spanish (99%)
- Swedish (88%)
- Telugu (67%)
- Tetum (52%)
- Turkish (83%)
- Ukrainian (76%)
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

The release team for Koha 24.11.17 is


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



We thank the following individuals who contributed patches to Koha 24.11.17
<div style="column-count: 2;">

- David Cook (6)
- Jonathan Druart (5)
- Fridolin Somers (2)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 24.11.17
<div style="column-count: 2;">

- [BibLibre](https://www.biblibre.com) (2)
- Koha Community Developers (5)
- [Prosentient Systems](https://www.prosentient.com.au) (6)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Jonathan Druart (3)
- Emily Lamancusa (1)
- Sanjar Tulkinov Anvar o'g'li (6)
- Jacob O'Mara (1)
- Martin Renvoize (4)
- Fridolin Somers (8)
- Emmi Takkinen (1)
- Wainui Witika-Park (1)
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

Autogenerated release notes updated last on 24 Jun 2026 08:30:39.
