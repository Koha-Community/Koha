# RELEASE NOTES FOR KOHA 24.11.18
06 Aug 2026

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 24.11.18 can be downloaded from:

- [Download](https://download.koha-community.org/koha-24.11.18.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 24.11.18 is a bugfix/maintenance release with security patches.

It includes 1 bugfix (7 security).

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


## Bugfixes

### Security bugs

- [30233](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30233) Remote code execution in user-supplied regex
  >This change refactors the regular expression handling for Batch Item Modification, MARC Modification templates, and Callnumber splitting. It moves from Perl's traditional compile-time regular expression handling to a more dynamic (but restrictive) run-time regular expression handling more similar to Python's "sub" regex method. This functions to reduce vulnerabilities to code injection into Koha's Perl backend.
- [42746](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42746) Stored SQL injection via unvalidated 'agefield' in automatic_item_modification_by_age (C4::Items::ToggleNewStatus)
- [42747](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42747) Stored SQL injection via patroncard layout image_name (patroncards/edit-layout.pl -> create-pdf.pl)
- [42749](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42749) SQL injection in acqui/parcels.pl via the orderby parameter (ORDER BY direction) reaching C4::Acquisition::GetInvoices
- [42847](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42847) SIP authentication ignored after initial successful connection
- [42866](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42866) SQL Injection in Koha/AdditionalContents.pm search_for_display via the patron lang value (stored / second-order, executed on issue-slip print, unvalidated string context, no placeholder)
- [43019](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43019) OPAC pages limited to library are readable by unauthenticated users

### About

#### Other bugs fixed

- [42726](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42726) Release team 26.11
  >Updates changes to the 25.11 release team, and adds the details of people in the 26.05 release team. (More > About Koha > Koha team.)

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [English (USA)](https://koha-community.org/manual/24.11/en/html/)
- [French](https://koha-community.org/manual/24.11/fr/html/) (80%)
- [German](https://koha-community.org/manual/24.11/de/html/) (85%)
- [Greek](https://koha-community.org/manual/24.11/el/html/) (91%)
- [Hindi](https://koha-community.org/manual/24.11/hi/html/) (61%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (95%)
- Armenian (hy_ARMN) (100%)
- Azerbaijani (62%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified Han script) (86%)
- Chinese (Traditional Han script) (99%)
- Czech (68%)
- Dutch (89%)
- English (100%)
- English (New Zealand) (63%)
- English (USA)
- Finnish (99%)
- French (100%)
- French (Canada) (99%)
- German (100%)
- Greek (68%)
- Hindi (97%)
- Italian (84%)
- Khmer (Central) (55%)
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
- Ukrainian (77%)
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

The release team for Koha 24.11.18 is


- Release Manager: Pedro Amorim

- QA Manager: Lisette Scheer

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
  - Lucas Gass

- Documentation Manager: Aude Charillon

- Documentation Team:
  - Philip Orr
  - Caroline Cyr La Rose
  - David Nind
  - Marion Durand

- Translation Manager: Jonathan Druart


- Wiki curators:
  - George Williams
  - Thomas Dukleth

- Release Maintainers:
  - 26.05 -- Lucas Gass
  - 25.11 -- Baptiste Wojtkowski
  - 25.05 -- Wainui Witika-Park
  - 24.11 -- Fridolin Somers

- Release Maintainer assistants:
  - 26.05 --Jacob O'Mara
  - 25.05 -- Alex Buckley & Aleisha Amohia



## Credits



We thank the following individuals who contributed patches to Koha 24.11.18
<div style="column-count: 2;">

- Martin Renvoize (1)
- Baptiste Wojtkowski (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 24.11.18
<div style="column-count: 2;">

- [BibLibre](https://www.biblibre.com) (1)
- [OpenFifth](https://openfifth.co.uk) (1)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Jonathan Druart (1)
- Owen Leonard (1)
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

Autogenerated release notes updated last on 06 Aug 2026 09:02:10.
