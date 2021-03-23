# RELEASE NOTES FOR KOHA 20.05.10
23 Mar 2021

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 20.05.10 can be downloaded from:

- [Download](http://download.koha-community.org/koha-20.05.10.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 20.05.10 is a bugfix/maintenance release.

It includes 1 enhancements, 40 bugfixes.

### System requirements

Koha is continuously tested against the following configurations and as such these are the recommendations for 
deployment: 

- Debian Jessie with MySQL 5.5 (End of life)
- Debian Stretch with MariaDB 10.1
- Debian Buster with MariaDB 10.3
- Ubuntu Bionic with MariaDB 10.1 
- Debian Stretch with MySQL 8.0 (Experimental MySQL 8.0 support)

Additional notes:
    
- Perl 5.10 is required (5.24 is recommended)
- Zebra or Elasticsearch is required




## Enhancements

### Acquisitions

- [[27794]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27794) Add link to biblio in lateorders page

  >This patch modifies the display of bibliographic records in the acquisitions report of late orders so that the title of the record is a link to the corresponding bibliographic details page.


## Critical bugs fixed

### Acquisitions

- [[26997]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26997) Database Mysql Version 8.0.22 failed to Update During Upgrade
- [[27828]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27828) New order from staged file is broken

### Architecture, internals, and plumbing

- [[27821]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27821) sanitize_zero_date does not handle datetime

### Circulation

- [[26208]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26208) Overdues restrictions not consistently removed when renewing multiple items at once
- [[26457]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26457) DB DeadLock when renewing checkout items
- [[27808]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27808) Item's onloan column remains unset if a checked out item is issued to another patron without being returned first

### Hold requests

- [[27071]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27071) Hold pickup library match not enforced correctly on intranet when using hold groups

  >When using library groups, the rules for placing holds did not always work as expected. This fixes these rules so that when patrons are part of a library in a group, they can only place a hold for items held in that library group. It also improves the error messages.
  >
  >Example:
  >- There are two library groups with distinct libraries in each (Group A and B).
  >- Default rules for all libraries are: Hold Policy = "From local hold group" and Hold pickup library match to "Patron's hold group", AllowHoldPolicyOverride is Don't allow.
  >- You can place a hold for a patron that belongs to one of the Group A libraries, for an item only held in a Group A library.
  >- You can't place a hold for that item for a patron from a Group B library.

### Holidays

- [[27835]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27835) Closed days offsets with one day

### OPAC

- [[24398]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24398) Error when viewing single news item and NewsAuthorDisplay pref set to OPAC
- [[27626]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27626) Patron self-registration breaks if categorycode and password are hidden

### Patrons

- [[27933]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27933) Order patron search broken (dateofbirth, cardnumber, expirationdate)

### Searching - Elasticsearch

- [[27597]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27597) Searching "kw:term" does not work with Elasticsearch
- [[27784]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27784) Unknown authority types break elasticsearch authorities indexing

  >This patch fixes Elasticsearch indexing failures caused by 'SUBDIV' type authority records in Koha. It skips the step of parsing the authorities into the linking form if the type contains '_SUBD'. 
  >
  >Notes: 
  >- Koha currently doesn't have support for 'SUBDIV' type authority records.
  >- They can be added to the authority types in the staff interface, however, values are hard coded in various modules and Koha has no concept of how to link a subfield heading to a record, as we only deal in whole fields.


## Other bugs fixed

### Acquisitions

- [[23675]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23675) UseACQFrameworkForBiblioRecords default framework is missing LDR breaking encoding
- [[23929]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23929) Invoice adjustments should filter inactive funds
- [[27813]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27813) Purchase suggestions should sort by suggesteddate rather than title

  >This changes the list of purchase suggestions so that the oldest suggestions are shown first, rather than by title. (This was the behaviour before Koha 20.05).

### Architecture, internals, and plumbing

- [[27680]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27680) API DataTables Wrapper fails for ordering on multi-data-field columns
- [[27714]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27714) Koha::NewsItem->author explodes if the author has been removed

  >This fixes the cause of errors occurring for the display of news items where the author of no longer exists in Koha.

### Cataloging

- [[25777]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25777) Datatables on z3950_search.pl show incorrect number of entries
- [[26964]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26964) Advanced editor no longer selects newly created macros

  >This patch fixes the behaviour for saving of new macros using the advanced editor. Before this fix the newly created macro wasn't selected and the automatic save (there isn't a save option) had nothing to save.
- [[27578]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27578) Searchid not initialized when adding a new record

### Database

- [[7806]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7806) Don't use 0000-00-00 to signal a non-existing date

### Hold requests

- [[27729]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27729) Code around SkipHoldTrapOnNotForLoanValue contains two perl bugs

### I18N/L10N

- [[27815]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27815) "Remove" in point of sale untranslatable

### OPAC

- [[27650]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27650) Wrong variable passed to the template in opac-main

### REST API

- [[27330]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27330) Wrong return status when no enrollments in club holds
- [[27593]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27593) Inconsistent return status on club holds routes

### SIP2

- [[27014]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27014) SIP2 cannot find patrons at checkin

### Searching

- [[27745]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27745) Use of uninitialized value in hash element error at C4/Search.pm

### Searching - Elasticsearch

- [[24567]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24567) Elasticsearch: CCL syntax does not allow for multiple indexes to be searched at once
- [[26051]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26051) Elasticsearch uses the wrong field for callnumber sorting

  >This fixes the sorting of search results by call number when using Elasticsearch. Currently it does not sort correctly (uses local-classification instead of cn-sort) and may also cause error messages "No results found" and "Error: Unable to perform your search. Please try again.". This also matches the behaviour used by Zebra.

### Searching - Zebra

- [[8426]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8426) Map  ︡a to a and t︠ to t for searching (Non-ICU)

### Serials

- [[27332]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27332) When renewing a serial subscription, show note and library only if RenewSerialAddsSuggestion is used

### Staff Client

- [[27776]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27776) Point of Sale 'This sale' table should not be sorted by default

### System Administration

- [[27703]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27703) Can't navigate in Authorized values

  >This fixes an issue when navigating authorized value categories - if you selected an authorized value category from the drop down list it wouldn't change to the selected category.
- [[27713]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27713) Duplicate search field IDs in MARC framework administration template
- [[27798]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27798) Independent branches should have a warning

### Templates

- [[27752]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27752) Correct ESLint errors in batchMod.js

  >This patch makes minor changes to batchMod.js used in Tools > Batch item modification. This addresses errors raised by ESLint, including white space changes, to make sure it meets coding guideline JS8: Follow guidelines set by ESLint.
- [[27754]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27754) Correct eslint errors in basket.js

  >This patch makes minor changes to basket.js in the staff interface templates to remove ESLint warnings. Besides whitespace changes, most changes are to correct undeclared or unnecessarily declared variables.
- [[27795]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27795) Misalignment of TOTAL value in lateorders page
## New sysprefs

- ChargeFinesOnClosedDays

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://koha-community.org/manual/20.05/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (98.7%)
- Armenian (100%)
- Armenian (Classical) (99.7%)
- Chinese (Taiwan) (94.1%)
- Czech (80.7%)
- English (New Zealand) (66.7%)
- English (USA)
- Finnish (70.4%)
- French (82.1%)
- French (Canada) (97.4%)
- German (100%)
- German (Switzerland) (74.4%)
- Greek (62.2%)
- Hindi (100%)
- Italian (100%)
- Norwegian Bokmål (71.1%)
- Polish (73.5%)
- Portuguese (86.8%)
- Portuguese (Brazil) (97.9%)
- Russian (86.6%)
- Slovak (89.7%)
- Spanish (99.8%)
- Swedish (79.5%)
- Telugu (89.5%)
- Turkish (100%)
- Ukrainian (66.4%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 20.05.10 is


- Release Manager: Jonathan Druart

- Release Manager assistants:
  - Martin Renvoize
  - Tomás Cohen Arazi

- QA Manager: Katrin Fischer

- QA Team:
  - Marcel de Rooy
  - Joonas Kylmälä
  - Josef Moravec
  - Tomás Cohen Arazi
  - Nick Clemens
  - Kyle Hall
  - Martin Renvoize
  - Alex Arnaud
  - Julian Maurice
  - Matthias Meusburger

- Topic Experts:
  - Elasticsearch -- Frédéric Demians
  - REST API -- Tomás Cohen Arazi
  - UI Design -- Owen Leonard
  - Zebra -- Fridolin Somers
  - Accounts -- Martin Renvoize
  - CAS/Shibboleth -- Matthias Meusburger

- Bug Wranglers:
  - Michal Denár
  - Holly Cooper
  - Henry Bolshaw
  - Lisette Scheer
  - Mengü Yazıcıoğlu

- Packaging Manager: Mason James


- Documentation Managers:
  - Caroline Cyr La Rose
  - David Nind

- Documentation Team:
  - Martin Renvoize
  - Donna Bachowski
  - Lucy Vaux-Harvey
  - Kelly McElligott
  - Jessica Zairo
  - Chris Cormack
  - Henry Bolshaw
  - Jon Drucker

- Translation Manager: Bernardo González Kriegel


- Release Maintainers:
  - 20.05 -- Lucas Gass
  - 19.11 -- Aleisha Amohia
  - 19.05 -- Victor Grousset

- Release Maintainer mentors:
  - 19.11 -- Hayley Mapley
  - 19.05 -- Martin Renvoize

## Credits

We thank the following individuals who contributed patches to Koha 20.05.10.

- Tomás Cohen Arazi (14)
- Philippe Blouin (1)
- Nick Clemens (9)
- David Cook (1)
- Jonathan Druart (24)
- Andrew Fuerste-Henry (8)
- Kyle M Hall (5)
- Joonas Kylmälä (1)
- Owen Leonard (7)
- Martin Renvoize (8)
- Phil Ringnalda (1)
- Marcel de Rooy (1)
- Fridolin Somers (1)
- Koha Translators (1)
- Petro Vashchuk (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 20.05.10

- Athens County Public Libraries (7)
- BibLibre (1)
- ByWater-Solutions (22)
- Chetco Community Public Library (1)
- Independant Individuals (1)
- Koha Community Developers (24)
- Prosentient Systems (1)
- PTFS-Europe (8)
- Rijks Museum (1)
- Solutions inLibro inc (1)
- Theke Solutions (14)
- University of Helsinki (1)

We also especially thank the following individuals who tested patches
for Koha.

- Tomás Cohen Arazi (13)
- Sonia Bouis (1)
- Nick Clemens (5)
- Jonathan Druart (52)
- Katrin Fischer (16)
- Martha Fuerst (2)
- Andrew Fuerste-Henry (75)
- Lucas Gass (1)
- Didier Gautheron (1)
- Victor Grousset (1)
- Kyle M Hall (3)
- Sally Healey (1)
- Joonas Kylmälä (2)
- Owen Leonard (3)
- Kelly McElligott (1)
- David Nind (20)
- Séverine Queune (2)
- Martin Renvoize (38)
- Phil Ringnalda (2)
- Marcel de Rooy (10)
- Lisette Scheer (2)
- Fridolin Somers (71)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is rmain2005.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 23 Mar 2021 20:43:00.
