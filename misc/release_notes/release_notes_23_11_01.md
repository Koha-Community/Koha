# RELEASE NOTES FOR KOHA 23.11.01
02 Jan 2024

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 23.11.01 can be downloaded from:

- [Download](http://download.koha-community.org/koha-23.11.01.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 23.11.01 is a bugfix/maintenance release.

It includes 25 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


## Bugfixes

### Accessibility

#### Other bugs fixed

- [35157](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35157) The searchfieldstype select element produces invalid HTML

### Cataloging

#### Other bugs fixed

- [35383](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35383) Dragging and dropping subfield of repeated tags doesn't work
- [35414](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35414) Silence warn related to number_of_copies
- [35425](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35425) Sortable prevents mouse selection of text inside child input/textarea elements
- [35441](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35441) Typo 'UniqueItemsFields' system preference

### Command-line Utilities

#### Other bugs fixed

- [34091](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34091) Typo in help for cleanupdatabase.pl: --log-modules  needs to be --log-module

### ERM

#### Other bugs fixed

- [35408](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35408) ERM > Titles > Import from a list gives an invalid link to the import job

### I18N/L10N

#### Other bugs fixed

- [35376](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35376) Rephrase: Be careful removing attribute to this processing, the items using it will be impacted as well!

### Installation and upgrade (command-line installer)

#### Critical bugs fixed

- [34516](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34516) Upgrade database fails for 22.11.07.003, points to web installer

### OPAC

#### Other bugs fixed

- [33244](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33244) Do not show lists in OPAC if OpacPublic is disabled
- [35436](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35436) Copy is not translatable in OPAC search history

### Patrons

#### Other bugs fixed

- [35344](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35344) Patron image upload does not warn about missing cardnumber
- [35352](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35352) Cannot hide SMSalertnumber via BorrowerUnwantedField

### Preservation

#### Other bugs fixed

- [35387](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35387) Capitalization: Labels in preservation module are not capitalized
  >This fixes the capitalization of some label names in the Preservation module (name -> Name, and barcode -> Barcode).

### Searching

#### Other bugs fixed

- [35410](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35410) 856 label is inconsistent between detail page and search results in XSLTs
  >This updates the default staff interface and OPAC XSLT files so that "Online resources" is used as the label in search results for field 856 - Electronic Location and Access, instead of "Online access". This matches the label used in the detail page for a record.
  >
  >It also adjusts the CSS class so OPAC and staff interface both use online_resources.

### System Administration

#### Critical bugs fixed

- [35460](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35460) Unable to add or edit hold rules in circulation rules table

  **Sponsored by** *Koha-Suomi Oy*

### Templates

#### Other bugs fixed

- [34398](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34398) Inconsistencies in Record matching rules page titles, breadcrumbs, and header
- [35327](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35327) Fix capitalization of language name
  >This fixes the capitalization of English (english -> English) in the ILS_DI GetAvailability information page (<domainname>:<port>/cgi-bin/koha/ilsdi.pl?service=Describe&verb=GetAvailability).
- [35378](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35378) 'This authority type is used {count} times' missing dot
- [35404](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35404) Wrong copy and paste in string (ILL batches)
- [35412](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35412) Capitalization: Toggle Dropdown
- [35415](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35415) Rephrase: Some patrons have requested a privacy ...
- [35449](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35449) Accessibility: No links on "here"
- [35450](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35450) Preservation system preferences should be authorised value pull downs
- [35453](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35453) Wrong 'Laserdisc)' string on 007 builder (MARC21)

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Chinese (Traditional)](https://koha-community.org/manual/23.11//html/) (51%)
- [English](https://koha-community.org/manual/23.11//html/) (100%)
- [English (USA)](https://koha-community.org/manual/23.11/en/html/)
- [French](https://koha-community.org/manual/23.11/fr/html/) (39%)
- [German](https://koha-community.org/manual/23.11/de/html/) (41%)
- [Hindi](https://koha-community.org/manual/23.11/hi/html/) (68%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (69%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (99%)
- Chinese (Traditional) (92%)
- Czech (58%)
- Dutch (75%)
- English (100%)
- English (New Zealand) (64%)
- English (USA)
- Finnish (99%)
- French (93%)
- French (Canada) (97%)
- German (100%)
- German (Switzerland) (52%)
- Hindi (94%)
- Italian (84%)
- Norwegian Bokmål (73%)
- Persian (fa_ARAB) (92%)
- Polish (92%)
- Portuguese (Brazil) (93%)
- Portuguese (Portugal) (88%)
- Russian (89%)
- Slovak (62%)
- Spanish (100%)
- Swedish (82%)
- Telugu (71%)
- Turkish (81%)
- Ukrainian (74%)
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

The release team for Koha 23.11.01 is


- Release Manager: Katrin Fischer

- Release Manager assistants:
  - Tomás Cohen Arazi
  - Martin Renvoize
  - Jonathan Druart

- QA Manager: Marcel de Rooy

- QA Team:
  - Marcel de Rooy
  - Julian Maurice
  - Lucas Gass
  - Victor Grousset
  - Kyle M Hall
  - Nick Clemens
  - Martin Renvoize
  - Tomás Cohen Arazi
  - Aleisha Amohia
  - Emily Lamancusa
  - David Cook
  - Jonathan Druart
  - Pedor Amorim

- Topic Experts:
  - UI Design -- Owen Leonard
  - Zebra -- Fridolin Somers
  - REST API -- Tomás Cohen Arazi
  - ERM -- Matt Blenkinsop
  - ILL -- Pedro Amorim
  - SIP2 -- Matthias Meusburger
  - CAS -- Matthias Meusburger

- Bug Wranglers:
  - Aleisha Amohia
  - Indranil Das Gupta

- Packaging Managers:
  - Mason James
  - Indranil Das Gupta
  - Tomás Cohen Arazi

- Documentation Manager: Aude Charillon

- Documentation Team:
  - Caroline Cyr La Rose
  - Kelly McElligott
  - Philip Orr
  - Marie-Luce Laflamme
  - Lucy Vaux-Harvey

- Translation Manager: Jonathan Druart


- Wiki curators: 
  - Thomas Dukleth
  - Katrin Fischer

- Release Maintainers:
  - 23.11 -- Fridolin Somers
  - 23.05 -- Lucas Gass
  - 22.11 -- Frédéric Demians
  - 22.05 -- Danyon Sewell

- Release Maintainer assistants:
  - 22.05 -- Wainui Witika-Park

## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 23.11.01
<div style="column-count: 2;">

- [Koha-Suomi Oy](https://koha-suomi.fi)
</div>

We thank the following individuals who contributed patches to Koha 23.11.01
<div style="column-count: 2;">

- Tomás Cohen Arazi (5)
- Kevin Carnes (1)
- David Cook (1)
- Jonathan Druart (2)
- Magnus Enger (1)
- Lucas Gass (2)
- Victor Grousset (1)
- Owen Leonard (6)
- David Nind (1)
- Andrii Nugged (1)
- Adolfo Rodríguez (1)
- Slava Shishkin (1)
- Fridolin Somers (4)
- Emmi Takkinen (1)
- Lari Taskula (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 23.11.01
<div style="column-count: 2;">

- Athens County Public Libraries (6)
- BibLibre (4)
- ByWater-Solutions (2)
- David Nind (1)
- Hypernova Oy (1)
- Independant Individuals (2)
- Koha Community Developers (3)
- Koha-Suomi (1)
- Libriotech (1)
- Prosentient Systems (1)
- Theke Solutions (5)
- ub.lu.se (1)
- Xercode (1)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Pedro Amorim (1)
- Matt Blenkinsop (1)
- David Cook (2)
- Jonathan Druart (3)
- Katrin Fischer (27)
- Andrew Fuerste-Henry (1)
- Lucas Gass (2)
- Victor Grousset (13)
- Kyle M Hall (1)
- Barbara Johnson (2)
- Emily Lamancusa (2)
- Brendan Lawlor (1)
- Owen Leonard (3)
- David Nind (11)
- Phil Ringnalda (2)
- Marcel de Rooy (5)
- Fridolin Somers (25)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 23.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 02 Jan 2024 10:31:47.
