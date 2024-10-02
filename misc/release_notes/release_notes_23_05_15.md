# RELEASE NOTES FOR KOHA 23.05.15
02 Oct 2024

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 23.05.15 can be downloaded from:

- [Download](http://download.koha-community.org/koha-23.05.15.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 23.05.15 is a security and bugfix/maintenance release.

It includes 20 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [13342](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13342) Not logged in user can place a review/comment as a deleted patron
- [37654](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37654) XSS in Batch record import for the Citation column

  **Sponsored by** *Chetco Community Public Library*
- [37655](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37655) XSS vulnerability in basic editor handling of title
- [37656](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37656) XSS in Advanced editor for Z39.50 search results

  **Sponsored by** *Chetco Community Public Library*
- [37720](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37720) XSS (and bustage) in label creator

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
- [36940](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36940) Resolve two Auth warnings when AutoLocation is enabled having a branch without branchip
  >This fixes two warnings in the log files when the AutoLocation system preference is enabled and there is a library without an IP address.
  >
  >Warning messages:
  >[WARN] Use of uninitialized value $domain in substitution (s///) at /usr/share/koha/C4/Auth.pm line 1223.
  >[WARN] Use of uninitialized value $domain in regexp compilation at /usr/share/koha/C4/Auth.pm line 1224.

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
- [36891](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36891) Restore returning 404 from svc/bib when the bib number doesn't exist
  >This fixes requests made for records that don't exist using the /svc/bib/<biblionumber> HTTP API. A 404 error (Not Found) is now returned if a record doesn't exist, instead of a 505 error (HTTP Version Not Supported).

### Developer documentation

#### Other bugs fixed

- [37198](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37198) POD for GetPreparedLetter doesn't include 'objects'
  >This updates the GetPreparedLetter documentation for developers (it was not updated when changes were made in Bug 19966 - Add ability to pass objects directly to slips and notices).

### Lists

#### Other bugs fixed

- [37285](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37285) Printing lists only prints the ten first results

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

- [Chinese (Traditional)](https://koha-community.org/manual/23.05/zh_Hant/html/) (78%)
- [English](https://koha-community.org/manual/23.05//html/) (100%)
- [English (USA)](https://koha-community.org/manual/23.05/en/html/)
- [French](https://koha-community.org/manual/23.05/fr/html/) (49%)
- [German](https://koha-community.org/manual/23.05/de/html/) (39%)
- [Greek](https://koha-community.org/manual/23.05//html/) (73%)
- [Hindi](https://koha-community.org/manual/23.05/hi/html/) (75%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (86%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified) (95%)
- Chinese (Traditional) (99%)
- Czech (70%)
- Dutch (85%)
- English (100%)
- English (New Zealand) (68%)
- English (USA)
- Finnish (99%)
- French (99%)
- French (Canada) (99%)
- German (99%)
- German (Switzerland) (55%)
- Greek (61%)
- Hindi (99%)
- Italian (91%)
- Norwegian Bokmål (78%)
- Persian (fa_ARAB) (99%)
- Polish (100%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (88%)
- Russian (98%)
- Slovak (67%)
- Spanish (100%)
- Swedish (88%)
- Telugu (76%)
- Turkish (89%)
- Ukrainian (79%)
- hyw_ARMN (generated) (hyw_ARMN) (69%)
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

The release team for Koha 23.05.15 is


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
  - 22.11 -- Fridolin Somers

## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 23.05.15
<div style="column-count: 2;">

- Chetco Community Public Library
</div>

We thank the following individuals who contributed patches to Koha 23.05.15
<div style="column-count: 2;">

- Matt Blenkinsop (1)
- Nick Clemens (2)
- Jonathan Druart (1)
- Marion Durand (1)
- Katrin Fischer (3)
- Eric Garcia (1)
- Lucas Gass (1)
- Andreas Jonsson (1)
- Janusz Kaczmarek (1)
- Emily Lamancusa (1)
- Sam Lau (1)
- Laura_Escamilla (1)
- Brendan Lawlor (1)
- David Nind (1)
- Martin Renvoize (3)
- Phil Ringnalda (4)
- Marcel de Rooy (1)
- Hammat Wele (1)
- Wainui Witika-Park (2)
- Baptiste Wojtkowski (2)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 23.05.15
<div style="column-count: 2;">

- [BibLibre](https://www.biblibre.com) (2)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (3)
- [ByWater Solutions](https://bywatersolutions.com) (4)
- [Cape Libraries Automated Materials Sharing](https://info.clamsnet.org) (1)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha) (2)
- Chetco Community Public Library (4)
- David Nind (1)
- Independant Individuals (3)
- Koha Community Developers (1)
- Kreablo AB (1)
- laposte.net (1)
- [Montgomery County Public Libraries](montgomerycountymd.gov) (1)
- [PTFS Europe](https://ptfs-europe.com) (4)
- Rijksmuseum, Netherlands (1)
- [Solutions inLibro inc](https://inlibro.com) (1)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Pedro Amorim (1)
- Matt Blenkinsop (1)
- Nick Clemens (5)
- David Cook (6)
- Chris Cormack (1)
- Jonathan Druart (1)
- Katrin Fischer (9)
- Lucas Gass (17)
- Kyle M Hall (1)
- Emily Lamancusa (2)
- Owen Leonard (3)
- David Nind (5)
- Martin Renvoize (7)
- Phil Ringnalda (1)
- Marcel de Rooy (2)
- Fridolin Somers (15)
- wainuiwitikapark (25)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 23.05.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 02 Oct 2024 00:56:04.
