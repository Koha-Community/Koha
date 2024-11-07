# RELEASE NOTES FOR KOHA 24.05.05
07 Nov 2024

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 24.05.05 can be downloaded from:

- [Download](http://download.koha-community.org/koha-24.05.05.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 24.05.05 is a bugfix/maintenance release.

It includes 1 enhancements, 28 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).

#### Security bugs

- [37786](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37786) members/cancel-charge.pl needs CSRF protection
- [33339](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33339) Formula injection (CSV Injection) in export functionality
- [37724](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37724) Remove Koha version number from public generator metadata
- [37861](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37861) Fix XSS vulnerability in barcode append function

## Bugfixes

### Acquisitions

#### Critical bugs fixed

- [38183](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38183) Can't set suggestion manager when there are multiple tabs

### Cataloging

#### Critical bugs fixed

- [35125](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35125) AutoCreateAuthorities creates separate authorities when thesaurus differs, even with LinkerConsiderThesaurus set to Don't
- [37536](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37536) Cataloging add item js needs to update conditional that checks op
- [37947](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37947) Import from Z39.50 doesn't open the record in editor
- [38076](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38076) Librarians with only fast add permission can no longer edit or create fast add records
- [38094](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38094) Librarians with only fast add permission can no longer edit existing fast add records
- [38211](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38211) New bibliographic record in non-default framework opens in default on first edit

### Circulation

#### Critical bugs fixed

- [37290](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37290) Deleting circulation rule for a specific library deletes for All libraries instead

#### Other bugs fixed

- [37055](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37055) WaitingNotifyAtCheckout should only trigger on patrons with waiting holds
- [38199](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38199) Printing transfer slips from circ/returns.pl doesn't set focus properly ( 24.05.x and below )

### Fines and fees

#### Other bugs fixed

- [34585](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34585) "When to charge" columns value not copied when editing circulation rule

  **Sponsored by** *Koha-Suomi Oy*

### Hold requests

#### Critical bugs fixed

- [38126](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38126) Holds queue is allocating holds twice when using TransportCostMatrix and LocalHoldsPriority
- [38148](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38148) Check value of holdallowed circ rule properly (Bug 29087 follow-up)

  **Sponsored by** *Whanganui District Council*

#### Other bugs fixed

- [37587](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37587) Wrong priority when placing multiple item-level holds

### I18N/L10N

#### Critical bugs fixed

- [38164](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38164) Translation process is broken

### MARC Authority data support

#### Other bugs fixed

- [38056](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38056) Search term after deleting an authority shouldn't be URI encoded

  **Sponsored by** *Chetco Community Public Library*

### Notices

#### Other bugs fixed

- [37891](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37891) Editing a notice's name having SMSSendDriver disabled causes notice to be listed twice

### OPAC

#### Critical bugs fixed

- [37150](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37150) Can't delete single title from a list using the "Remove from list" link

  **Sponsored by** *Athens County Public Libraries*

#### Other bugs fixed

- [37339](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37339) Default messaging preferences are not applied when self registering in OPAC
  >This fixes a regression in Koha 24.05, 23.11, and 23.05 (caused by Bug 30318). Default messaging preferences for the self registraton patron category were not set for patron's self-registering using the OPAC.

### Patrons

#### Other bugs fixed

- [32530](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32530) When duplicating child card, guarantor is not saved

### Reports

#### Critical bugs fixed

- [37197](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37197) Batch patron modification from reports fails by using GET instead of POST
- [37270](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37270) Deleting a report from the actions menu on a list of saved reports does not work

  **Sponsored by** *Athens County Public Libraries*

### Searching

#### Other bugs fixed

- [37801](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37801) Search results with limits create URLs that cause XML errors in RSS2 output

  **Sponsored by** *Chetco Community Public Library*
- [37979](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37979) typo in PQF index : index.koha.classification-soruce

  **Sponsored by** *Chetco Community Public Library*

### Searching - Elasticsearch

#### Other bugs fixed

- [37953](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37953) Incorrect handling of DisplayLibraryFacets in previous database update 23.12.000.36

### Staff interface

#### Critical bugs fixed

- [37375](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37375) Holdings table not loading if MARC framework is missing certain 952 subfields
  >This fixes the loading of the holdings table for a record in the staff interface, where the framework for a MARC21 instance is missing certain 952 subfields (8, a, b, c, or y). The holdings table will still now load, before it would display as "Processing" and not display any holding details.

### Tools

#### Critical bugs fixed

- [37483](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37483) Batch extend due dates tool not working
- [37961](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37961) Inventory followup fails by POSTing without an op or csrf_token

  **Sponsored by** *Chetco Community Public Library*

## Enhancements 

### Staff interface

#### Enhancements

- [35191](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35191) Make entries per page configurable for items table on staff detail page

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Armenian (hy_ARMN)](https://koha-community.org/manual/24.05//html/) (58%)
- [Bulgarian (bg_CYRL)](https://koha-community.org/manual/24.05//html/) (98%)
- [Chinese (Traditional)](https://koha-community.org/manual/24.05/zh_Hant/html/) (77%)
- [English](https://koha-community.org/manual/24.05//html/) (100%)
- [English (USA)](https://koha-community.org/manual/24.05/en/html/)
- [French](https://koha-community.org/manual/24.05/fr/html/) (49%)
- [German](https://koha-community.org/manual/24.05/de/html/) (38%)
- [Greek](https://koha-community.org/manual/24.05//html/) (72%)
- [Hindi](https://koha-community.org/manual/24.05/hi/html/) (72%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (98%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified) (88%)
- Chinese (Traditional) (90%)
- Czech (69%)
- Dutch (87%)
- English (100%)
- English (New Zealand) (63%)
- English (USA)
- Finnish (99%)
- French (99%)
- French (Canada) (99%)
- German (99%)
- German (Switzerland) (51%)
- Greek (58%)
- Hindi (99%)
- Italian (83%)
- Norwegian Bokmål (76%)
- Persian (fa_ARAB) (96%)
- Polish (99%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (88%)
- Russian (94%)
- Slovak (61%)
- Spanish (99%)
- Swedish (87%)
- Telugu (69%)
- Turkish (82%)
- Ukrainian (73%)
- hyw_ARMN (generated) (hyw_ARMN) (64%)
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

The release team for Koha 24.05.05 is


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
new features in Koha 24.05.05
<div style="column-count: 2;">

- Athens County Public Libraries
- Chetco Community Public Library
- KillerRabbitAos
- [Koha-Suomi Oy](https://koha-suomi.fi)
- Whanganui District Council
</div>

We thank the following individuals who contributed patches to Koha 24.05.05
<div style="column-count: 2;">

- Aleisha Amohia (1)
- Pedro Amorim (3)
- Tomás Cohen Arazi (4)
- Artur (1)
- Nick Clemens (8)
- David Cook (1)
- Paul Derscheid (1)
- Jonathan Druart (4)
- Magnus Enger (1)
- Lucas Gass (4)
- Kyle M Hall (4)
- Janusz Kaczmarek (1)
- Emily Lamancusa (1)
- Brendan Lawlor (1)
- Owen Leonard (3)
- Phil Ringnalda (6)
- Emmi Takkinen (1)
- Lari Taskula (1)
- Baptiste Wojtkowski (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 24.05.05
<div style="column-count: 2;">

- Athens County Public Libraries (3)
- [ByWater Solutions](https://bywatersolutions.com) (16)
- [Cape Libraries Automated Materials Sharing](https://info.clamsnet.org) (1)
- Catalyst Open Source Academy (1)
- Chetco Community Public Library (6)
- [Hypernova Oy](https://www.hypernova.fi) (1)
- Independant Individuals (2)
- Koha Community Developers (4)
- [Koha-Suomi Oy](https://koha-suomi.fi) (1)
- laposte.net (1)
- [Libriotech](https://libriotech.no) (1)
- [LMSCloud](lmscloud.de) (1)
- [Montgomery County Public Libraries](montgomerycountymd.gov) (1)
- [Prosentient Systems](https://www.prosentient.com.au) (1)
- [PTFS Europe](https://ptfs-europe.com) (3)
- [Theke Solutions](https://theke.io) (4)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Aleisha Amohia (2)
- Pedro Amorim (1)
- andrewa (2)
- Tomás Cohen Arazi (2)
- Sukhmandeep Benipal (1)
- Matt Blenkinsop (2)
- Sonia Bouis (1)
- Nick Clemens (3)
- Chris Cormack (3)
- Ray Delahunty (2)
- Paul Derscheid (1)
- Roman Dolny (1)
- Jonathan Druart (9)
- Magnus Enger (1)
- Katrin Fischer (32)
- Eric Garcia (1)
- Lucas Gass (44)
- Victor Grousset (4)
- Bo Gustavsson (1)
- Kyle M Hall (3)
- Janusz Kaczmarek (1)
- Jan Kissig (1)
- Emily Lamancusa (4)
- Brendan Lawlor (5)
- Julian Maurice (1)
- David Nind (6)
- Martin Renvoize (10)
- Phil Ringnalda (4)
- Jason Robb (1)
- Marcel de Rooy (5)
- Emmi Takkinen (2)
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

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 07 Nov 2024 23:14:30.
