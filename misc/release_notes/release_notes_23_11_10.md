# RELEASE NOTES FOR KOHA 23.11.10
07 Nov 2024

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 23.11.10 can be downloaded from:

- [Download](http://download.koha-community.org/koha-23.11.10.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 23.11.10 is a bugfix/maintenance release.

It includes 12 bugfixes and 4 security fixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [33339](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33339) Formula injection (CSV Injection) in export functionality
- [37724](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37724) Remove Koha version number from public generator metadata
- [37737](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37737) Users with 'execute_reports' permission can create reports 23.11 and lower
- [37861](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37861) Fix XSS vulnerability in barcode append function

  **Sponsored by** *KillerRabbitAos*

## Bugfixes

### Accessibility

#### Other bugs fixed

- [37586](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37586) Improve accessibility of top navigation in the OPAC with aria-labels

### Architecture, internals, and plumbing

#### Other bugs fixed

- [36474](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36474) updatetotalissues.pl  should not modify the record when the total issues has not changed
  >This updates the misc/cronjobs/update_totalissues.pl script so that records are only modified if the number of issues changes. Previously, every record was modified - even if the number of issues did not change.
  >
  >In addition, with CataloguingLog enabled, this previously added one entry to the log viewer for every record - as all the records were modified even if the number of issues did not change. Now, only records where the number of issues have changed are included in the log viewer, significantly reducing the number of entries.

### Cataloging

#### Other bugs fixed

- [37591](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37591) Moredetail.tt page is opening very slowly
  >This improves the loading time of a record's items page in the staff item when there are many items and check-outs.

  **Sponsored by** *Koha-Suomi Oy*

### Circulation

#### Other bugs fixed

- [32696](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32696) Recalls can inadvertently extend the due date

  **Sponsored by** *Ignatianum University in Cracow*
- [37413](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37413) Updating an item level hold on an item with no barcode to a next available hold also modifies the other holds on the record
  >This fixes updating existing item level holds for an item without a barcode. When updating an existing item level hold from "Only item No barcode" (Holds for a record > Existing holds > Details column) to "Next available", it would incorrectly change any other item level holds to "Next available".

### Command-line Utilities

#### Critical bugs fixed

- [37775](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37775) update_totalissues.pl uses $dbh->commit but does not use transactions

### Database

#### Other bugs fixed

- [37593](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37593) Fix typo in schema description for items.bookable

### ERM

#### Critical bugs fixed

- [37308](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37308) Add user-agent to SUSHI outgoing requests

### Hold requests

#### Critical bugs fixed

- [38148](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38148) Check value of holdallowed circ rule properly (Bug 29087 follow-up)

  **Sponsored by** *Whanganui District Council*

### OPAC

#### Other bugs fixed

- [37339](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37339) Default messaging preferences are not applied when self registering in OPAC
  >This fixes a regression in Koha 24.05, 23.11, and 23.05 (caused by Bug 30318). Default messaging preferences for the self registraton patron category were not set for patron's self-registering using the OPAC.

### System Administration

#### Other bugs fixed

- [36907](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36907) OAI set mapping form field maxlength should match table column sizes
  >This fixes the OIA set mappings form so that you can't enter more characters than the maximum length for the input fields (Field (3), Subfield (1), and Value (80)). Previously, you could enter more characters - however, when you saved the form it generated an error.

### Test Suite

#### Other bugs fixed

- [37623](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37623) t/db_dependent/Letters.t tests fails to consider EmailFieldPrimary system preference

  **Sponsored by** *Pymble Ladies' College*

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Armenian (hy_ARMN)](https://koha-community.org/manual/23.11//html/) (58%)
- [Bulgarian (bg_CYRL)](https://koha-community.org/manual/23.11//html/) (98%)
- [Chinese (Traditional)](https://koha-community.org/manual/23.11/zh_Hant/html/) (77%)
- [English](https://koha-community.org/manual/23.11//html/) (100%)
- [English (USA)](https://koha-community.org/manual/23.11/en/html/)
- [French](https://koha-community.org/manual/23.11/fr/html/) (49%)
- [German](https://koha-community.org/manual/23.11/de/html/) (38%)
- [Greek](https://koha-community.org/manual/23.11//html/) (72%)
- [Hindi](https://koha-community.org/manual/23.11/hi/html/) (72%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (99%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified) (90%)
- Chinese (Traditional) (91%)
- Czech (70%)
- Dutch (88%)
- English (100%)
- English (New Zealand) (64%)
- English (USA)
- Finnish (99%)
- French (99%)
- French (Canada) (99%)
- German (100%)
- German (Switzerland) (52%)
- Greek (59%)
- Hindi (99%)
- Italian (84%)
- Norwegian Bokmål (76%)
- Persian (fa_ARAB) (97%)
- Polish (99%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (88%)
- Russian (95%)
- Slovak (62%)
- Spanish (100%)
- Swedish (87%)
- Telugu (70%)
- Turkish (83%)
- Ukrainian (74%)
- hyw_ARMN (generated) (hyw_ARMN) (65%)
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

The release team for Koha 23.11.10 is


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
new features in Koha 23.11.10
<div style="column-count: 2;">

- Ignatianum University in Cracow
- KillerRabbitAos
- [Koha-Suomi Oy](https://koha-suomi.fi)
- Pymble Ladies' College
- Whanganui District Council
</div>

We thank the following individuals who contributed patches to Koha 23.11.10
<div style="column-count: 2;">

- Aleisha Amohia (2)
- Pedro Amorim (3)
- Artur (1)
- Nick Clemens (7)
- David Cook (1)
- Magnus Enger (1)
- Kyle M Hall (2)
- Janusz Kaczmarek (2)
- Laura_Escamilla (2)
- Owen Leonard (1)
- PerplexedTheta (1)
- Johanna Räisä (1)
- Lisette Scheer (1)
- Fridolin Somers (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 23.11.10
<div style="column-count: 2;">

- Athens County Public Libraries (1)
- [BibLibre](https://www.biblibre.com) (1)
- [ByWater Solutions](https://bywatersolutions.com) (12)
- Catalyst Open Source Academy (2)
- Independant Individuals (4)
- [Libriotech](https://libriotech.no) (1)
- llownd.net (1)
- [Prosentient Systems](https://www.prosentient.com.au) (1)
- [PTFS Europe](https://ptfs-europe.com) (3)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Belal Ahmadi (1)
- andrewa (2)
- Nick Clemens (3)
- Chris Cormack (3)
- Ray Delahunty (2)
- Paul Derscheid (1)
- Roman Dolny (2)
- Magnus Enger (1)
- Katrin Fischer (16)
- Lucas Gass (26)
- Victor Grousset (1)
- Bo Gustavsson (1)
- Kyle M Hall (3)
- Emily Lamancusa (1)
- Sam Lau (1)
- Brendan Lawlor (3)
- David Nind (4)
- Martin Renvoize (7)
- Marcel de Rooy (6)
- Fridolin Somers (24)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 23.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 07 Nov 2024 13:34:53.
