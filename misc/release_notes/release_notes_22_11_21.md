# RELEASE NOTES FOR KOHA 22.11.21
07 oct. 2024

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 22.11.21 can be downloaded from:

- [Download](http://download.koha-community.org/koha-22.11.21.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 22.11.21 is a bugfix/maintenance release.

It includes 12 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


## Bugfixes

### About

#### Other bugs fixed

- [37003](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37003) Release team 24.11
  >This updates the About Koha > Koha team with the release team members for Koha 22.11.

### Acquisitions

#### Critical bugs fixed

- [34444](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34444) Statistic 1/2 not saving when updating fund after receipt

#### Other bugs fixed

- [30493](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30493) Pending archived suggestions appear on staff interface home page
  >This fixes the list of pending suggestions to remove archived suggestions with a "Pending" status. If suggestions were archived and their status was left as "Pending", they were still appearing as suggestions to manage on the staff interface and acquisitions home pages.

### Architecture, internals, and plumbing

#### Other bugs fixed

- [35294](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35294) Typo in comment in C4 circulation: barocode
  >This fixes spelling errors in catalog code comments (barocode => barcode, and preproccess => preprocess).

### Cataloging

#### Other bugs fixed

- [25387](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25387) Merging different authority types creates no warning
  >This improves merging authorities of different types so that:
  >
  >1. When selecting the reference record, the authority record number and type are displayed next to each record.
  >2. When merging authority records of different types:
  >   . the authority type is now displayed in the tab heading, and
  >   . a warning is also displayed "Multiple authority types are used. There may be a data loss while merging.".
  >
  >Previously, no warning was given when merging authority records with different types - this could result in undesirable outcomes, data loss, and extra work required to clean up.

### Developer documentation

#### Other bugs fixed

- [37198](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37198) POD for GetPreparedLetter doesn't include 'objects'
  >This updates the GetPreparedLetter documentation for developers (it was not updated when changes were made in Bug 19966 - Add ability to pass objects directly to slips and notices).

### Searching - Elasticsearch

#### Other bugs fixed

- [36879](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36879) Spurious warnings in QueryBuilder
  >This fixes the cause of a warning message in the log files. Changing the sort order for search results in the staff interface (for example, from Relevance to Author (A-Z)) would generate an unnecessary warning message in plack-intranet-error.log: [WARN] Use of uninitialized value $f in hash element at /kohadevbox/koha/Koha/SearchEngine/Elasticsearch/QueryBuilder.pm line 72    5.

### Self checkout

#### Other bugs fixed

- [37044](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37044) OPAC message from SCO missing library branch
  >This fixes the self checkout "Messages for you" section for a patron so that any OPAC messages added by library staff now include the library name. Previously, "Written on DD/MM/YYYY by " was displayed after the message without including the library name.

### Staff interface

#### Other bugs fixed

- [36930](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36930) Item search gives irrelevant results when using 2+ added filter criteria
  >This fixes the item search so that it returns the correct results when two or more additional filters are used (such as publisher and publication date). It was working correctly with one filter, but was not using any filters if two or more were used in a query.

### Templates

#### Other bugs fixed

- [35240](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35240) Missing form field ids in rotating collection edit form
  >This adds missing IDs to the rotating collections edit form (Tools > Rotating collections > edit a rotating collection (Actions > Edit)).

### Test Suite

#### Other bugs fixed

- [36937](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36937) api/v1/password_validation.t generates warnings
  >This fixes the cause of a warning for the t/db_dependent/api/v1/password_validation.t tests (warning fixed: Use of uninitialized value $status in numeric eq (==)).

### Transaction logs

#### Other bugs fixed

- [30715](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30715) Terminology: Logs should use staff interface and not intranet for the interface
  >This fixes the log viewer so that 'Staff interface' is used instead of 'Intranet' for the filtering option and the value displayed in the log entries interface column.
  >
  >Note: This does not fix the underlying value recorded in the action_log table (these are added as 'intranet' to the interface column), or the values shown in CSV exports.

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Chinese (Traditional)](https://koha-community.org/manual/22.11/zh_Hant/html/) (78%)
- [English](https://koha-community.org/manual/22.11//html/) (100%)
- [English (USA)](https://koha-community.org/manual/22.11/en/html/)
- [French](https://koha-community.org/manual/22.11/fr/html/) (50%)
- [German](https://koha-community.org/manual/22.11/de/html/) (39%)
- [Greek](https://koha-community.org/manual/22.11//html/) (73%)
- [Hindi](https://koha-community.org/manual/22.11/hi/html/) (75%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (90%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified) (96%)
- Chinese (Traditional) (81%)
- Czech (72%)
- Dutch (89%)
- English (100%)
- English (New Zealand) (69%)
- English (USA)
- English (United Kingdom) (99%)
- Finnish (96%)
- French (100%)
- French (Canada) (96%)
- German (100%)
- German (Switzerland) (56%)
- Greek (63%)
- Hindi (99%)
- Italian (92%)
- Norwegian Bokmål (69%)
- Persian (fa_ARAB) (76%)
- Polish (100%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (88%)
- Russian (94%)
- Slovak (67%)
- Spanish (100%)
- Swedish (88%)
- Telugu (77%)
- Turkish (90%)
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

The release team for Koha 22.11.21 is


- Release Manager: Katrin Fischer

- Release Manager assistants:
  - Tomás Cohen Arazi
  - Martin Renvoize
  - Jonathan Druart

- QA Manager: Martin Renvoize

- QA Team:
  - Marcel de Rooy
  - Kyle M Hall
  - Emily Lamancusa
  - Nick Clemens
  - Lucas Gass
  - Tomás Cohen Arazi
  - Julian Maurice
  - Victor Grousset
  - Aleisha Amohia
  - David Cook
  - Laura Escamilla
  - Jonathan Druart
  - Pedro Amorim
  - Matt Blenkinsop
  - Thomas Klausner

- Topic Experts:
  - UI Design -- Owen Leonard
  - Zebra -- Fridolin Somers
  - ERM -- Matt Blenkinsop
  - ILL -- Pedro Amorim
  - SIP2 -- Matthias Meusburger
  - CAS -- Matthias Meusburger

- Bug Wranglers:
  - Aleisha Amohia
  - Jacob O'Mara

- Packaging Managers:
  - Mason James
  - Tomás Cohen Arazi

- Documentation Manager: Philip Orr

- Documentation Team:
  - Aude Charillon
  - Caroline Cyr La Rose
  - Lucy Vaux-Harvey
  - Emmanuel Bétemps
  - Marie-Luce Laflamme
  - Kelly McElligott
  - Rasa Šatinskienė
  - Heather Hernandez

- Wiki curators: 
  - Thomas Dukleth
  - George Williams

- Release Maintainers:
  - 24.05 -- Lucas Gass
  - 23.11 -- Fridolin Somers
  - 23.05 -- Wainui Witika-Park
  - 22.11 -- Frédéric Demians

## Credits



We thank the following individuals who contributed patches to Koha 22.11.21
<div style="column-count: 2;">

- Matt Blenkinsop (1)
- Nick Clemens (2)
- Frédéric Demians (1)
- Marion Durand (1)
- Katrin Fischer (4)
- Eric Garcia (1)
- Andreas Jonsson (1)
- Janusz Kaczmarek (1)
- Emily Lamancusa (1)
- Sam Lau (1)
- Brendan Lawlor (1)
- David Nind (1)
- Martin Renvoize (3)
- Baptiste Wojtkowski (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 22.11.21
<div style="column-count: 2;">

- [BibLibre](https://www.biblibre.com) (2)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (4)
- [ByWater Solutions](https://bywatersolutions.com) (2)
- [Cape Libraries Automated Materials Sharing](https://info.clamsnet.org) (1)
- David Nind (1)
- Independant Individuals (3)
- Kreablo AB (1)
- [Montgomery County Public Libraries](montgomerycountymd.gov) (1)
- [PTFS Europe](https://ptfs-europe.com) (4)
- Tamil (1)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Pedro Amorim (1)
- Matt Blenkinsop (1)
- Nick Clemens (2)
- Chris Cormack (1)
- Frédéric Demians (16)
- Jonathan Druart (1)
- Katrin Fischer (9)
- Lucas Gass (14)
- Kyle M Hall (1)
- Emily Lamancusa (2)
- Owen Leonard (2)
- David Nind (4)
- Martin Renvoize (2)
- Marcel de Rooy (1)
- Fridolin Somers (12)
- wainuiwitikapark (16)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 22.11.x-security.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 07 oct. 2024 17:56:06.
