# RELEASE NOTES FOR KOHA 25.05.14
24 Aug 2026

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 25.05.14 can be downloaded from:

- [Download](https://download.koha-community.org/koha-25.05.14.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 25.05.14 is a security release.

It includes 6 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [42736](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42736) SQL Injection in reports/cat_issues_top.pl via Criteria / Filter request parameters (unvalidated string context, no placeholders)
- [42800](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42800) Potential XSS in shelf list in the erm module
- [42904](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42904) Prevent XSS in patron restriction comments

## Bugfixes

### Architecture, internals, and plumbing

#### Critical bugs fixed

- [30233](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30233) [ZDI-CAN-29165] Remote code execution in user-supplied regex
  >This change refactors the regular expression handling for Batch Item Modification, MARC Modification templates, and Callnumber splitting. It moves from Perl's traditional compile-time regular expression handling to a more dynamic (but restrictive) run-time regular expression handling more similar to Python's "sub" regex method. This functions to reduce vulnerabilities to code injection into Koha's Perl backend.

### MARC Bibliographic data support

#### Other bugs fixed

- [43085](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43085) Fix typo in data/marc21_field_006.xml
  >This fixes the text label shown in the plugin/value builder for MARC21 006 tag when "CF - Computer Files" is selected. The label "12-18 - Undefined" was changed to "12-17 - Undefined".
  >
  >(Change only for Koha 25.05 - made to later releases by Bug 40284 - MARC21: Adjust maxlength for 005, 006 and 007.)

  **Sponsored by** *Toi Ohomai Institute of Technology, New Zealand*

### Reports

#### Other bugs fixed

- [8127](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8127) Most-circulated items report doesn't work when limited by library
  >This fixes some of the filters for the "Most-circulated items" report so that using limits (the Limits section with "Limit to" and "By") now works.
  >
  >Previously some options for "By" (such as Library and Week) generated an error message or there were no results (when results were expected).

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [English (USA)](https://koha-community.org/manual/25.05/en/html/)
- [French](https://koha-community.org/manual/25.05/fr/html/) (83%)
- [German](https://koha-community.org/manual/25.05/de/html/) (84%)
- [Greek](https://koha-community.org/manual/25.05/el/html/) (91%)
- [Hindi](https://koha-community.org/manual/25.05/hi/html/) (62%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (92%)
- Armenian (hy_ARMN) (100%)
- Azerbaijani (64%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified Han script) (83%)
- Chinese (Traditional Han script) (97%)
- Czech (67%)
- Dutch (89%)
- English (100%)
- English (New Zealand) (61%)
- English (USA)
- Finnish (99%)
- French (100%)
- French (Canada) (99%)
- German (100%)
- Greek (66%)
- Hindi (94%)
- Italian (82%)
- Khmer (Central) (57%)
- Norwegian Bokmål (71%)
- Persian (fa_ARAB) (93%)
- Polish (100%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (88%)
- Russian (93%)
- Slovak (59%)
- Spanish (98%)
- Swedish (89%)
- Telugu (65%)
- Turkish (80%)
- Ukrainian (74%)
- Uzbek (53%)
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

The release team for Koha 25.05.14 is


- Release Manager: Pedro Amorim

- Release Manager assistants:
  - Tomás Cohen Arazi
  - Martin Renvoize

- QA Manager: Lisette Scheer

- QA Team:
  - Lucas Gass
  - Laura Escamilla
  - Kyle M Hall
  - Baptiste Wojtkowski
  - Victor Grousset
  - David Cook
  - Andrew Fuerste-Henry
  - Brendan Lawlor
  - Thomas Klausner
  - Paul Derscheid
  - Jan Kissig
  - Jacob O'Mara
  - Nick Clemens
  - Tomás Cohen Arazi
  - Marcel de Rooy
  - Emily Lamancusa
  - Aleisha Amohia
  - Martin Renvoize
  - David Nind

- Topic Experts:
  - Elasticsearch/OpenSearch -- Fridolin Somers
  - SIP2 -- Kyle M Hall
  - EDI -- Kyle M Hall
  - POS -- Martin Renvoize

- Bug Wranglers:
  - Michaela Sieber
  - Laura Escamilla

- Documentation Manager: Aude Charillon

- Documentation Team:
  - Caroline Cyr La Rose
  - David Nind
  - Philip Orr

- Wiki curators: 
  - Thomas Dukleth
  - George Williams

- Release Maintainers:
  - 26.05 -- Lucas Gass
  - 25.11 -- Baptiste Wojtkowski
  - 25.05 -- Wainui Witika-Park (Catalyst IT)
  - 24.11 -- Fridolin Somers

- Release Maintainer assistants:
  - 26.05 -- Jacob O'Mara
  - 25.05 -- Alex Buckley & Aleisha Amohia (Catalyst IT)

## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 25.05.14
<div style="column-count: 2;">

- Toi Ohomai Institute of Technology, New Zealand
</div>

We thank the following individuals who contributed patches to Koha 25.05.14
<div style="column-count: 2;">

- Jonathan Druart (1)
- Amit Gupta (1)
- Sanjar Tulkinov Anvar o'g'li (1)
- Martin Renvoize (3)
- Marcel de Rooy (1)
- Wainui Witika-Park (3)
- Baptiste Wojtkowski (2)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 25.05.14
<div style="column-count: 2;">

- [BibLibre](https://www.biblibre.com) (2)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha) (3)
- Independant Individuals (1)
- informaticsglobal.ai (1)
- Koha Community Developers (1)
- [OpenFifth](https://openfifth.co.uk) (3)
- Rijksmuseum, Netherlands (1)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Aleisha Amohia (1)
- David Cook (3)
- Lucas Gass (2)
- David Nind (3)
- Lawrence O'Regan-Lloyd (1)
- Martin Renvoize (2)
- Wainui Witika-Park (9)
- Baptiste Wojtkowski (2)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 25.05.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 24 Aug 2026 03:07:51.
