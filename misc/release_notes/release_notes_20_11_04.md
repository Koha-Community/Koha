# RELEASE NOTES FOR KOHA 20.11.04
24 mars 2021

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 20.11.04 can be downloaded from:

- [Download](http://download.koha-community.org/koha-20.11.04.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 20.11.04 is a bugfix/maintenance release.

It includes 9 enhancements, 53 bugfixes.

### System requirements

These are the [recommendations for deployment](https://wiki.koha-community.org/wiki/Release_maintenance#System_requirements_and_recommendations).




## Enhancements

### Acquisitions

- [[27794]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27794) Add link to biblio in lateorders page

  >This patch modifies the display of bibliographic records in the acquisitions report of late orders so that the title of the record is a link to the corresponding bibliographic details page.

### Architecture, internals, and plumbing

- [[27930]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27930) Move _escape_* functions from acq/parcel.tt to be re-usable

### Authentication

- [[18506]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18506) SSO - Shibboleth Only Mode

  >This enhancement adds a system preference to allow libraries to enable shibboleth to work as the only authentication method available for their library and as such practice fully devolved authentication.
  >
  >When combined with the OpacPublic preference, this can be used to enable seamless Single Sign On, where the user simply browses to the OPAC in their web browser and if already logged in on their domain they will automatically be logged in in koha too.

### Command-line Utilities

- [[27048]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27048) Add timestamps to verbose output of rebuild_zebra.pl

### Hold requests

- [[24359]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24359) Remove items from Holds Queue when checked in

  >This development makes Koha trigger an update on the holds queue when items are checked in. This way, the holds queue will be updated faster than the default 1 hour frequency (cronjob).
  >
  >Note: this doesn't trigger the more expensive task of recalculating the whole queue, which remains a cronjob-based task.

### MARC Bibliographic record staging/import

- [[26199]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26199) Record matching rule match check should include Leader/LDR

  >This patch extends the functionality of the existing record matching rules by allowing comparisons based on the fixed-length MARC leader. To reference the leader in a matching rule, enter "LDR" for the MARC tag in your matching rule setup. The offset and length values can be used to further refine your match.

### REST API

- [[27366]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27366) Add GET /patrons/:patron_id/holds

  >This enhancements adds the `GET /patrons/{patron_id}/holds` endpoint to the REST API.

### SIP2

- [[26591]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26591) Add a choice to prevent the checkout or warn the user if CheckPrevCheckout is used via SIP2

  >Some libraries would like patrons to be able to check out items with prior checkouts via SIP even if the CheckPrevIssue preference is enabled.
  >
  >This feature is enabled by adding the flag prevcheckout_block_checkout to an account in the SIP configuration file, and setting the value of it to "0".

### Templates

- [[27792]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27792) Improve jEditable configuration for point of sale fields

  >This patch improves interactions with inline-editable fields in the Point of Sale interface to prevent jumpy table re-draws and to enforce the required currenty/number input types.


## Critical bugs fixed

### Acquisitions

- [[26997]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26997) Database Mysql Version 8.0.22 failed to Update During Upgrade
- [[27828]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27828) New order from staged file is broken

### Architecture, internals, and plumbing

- [[26363]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26363) Provide a systemd unit file for background_jobs_worker
- [[27534]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27534) koha upgrade throws SQL error while applying Bug 25333 - Change message transport type for Talking Tech from "phone" to "itiva"
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

### MARC Authority data support

- [[27737]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27737) Tag editor for authority lookup broken in authority editor

  >This patch changes the markup structure for the authorities editor so that it better matches that of the basic bibliographic record editor. This allows the authority-linking JavaScript to correctly target fields on both pages.

### OPAC

- [[27626]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27626) Patron self-registration breaks if categorycode and password are hidden
- [[27860]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27860) Bad KohaAdminEmailAddress breaks patron self registration and password reset feature

### Patrons

- [[27933]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27933) Order patron search broken (dateofbirth, cardnumber, expirationdate)

### Plugin architecture

- [[27820]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27820) plugins_nightly.pl script missing use

### Searching - Elasticsearch

- [[27597]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27597) Searching "kw:term" does not work with Elasticsearch
- [[27784]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27784) Unknown authority types break elasticsearch authorities indexing

  >This patch fixes Elasticsearch indexing failures caused by 'SUBDIV' type authority records in Koha. It skips the step of parsing the authorities into the linking form if the type contains '_SUBD'. 
  >
  >Notes: 
  >- Koha currently doesn't have support for 'SUBDIV' type authority records.
  >- They can be added to the authority types in the staff interface, however, values are hard coded in various modules and Koha has no concept of how to link a subfield heading to a record, as we only deal in whole fields.


## Other bugs fixed

### About

- [[27661]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27661) Clarify error for message broker

### Acquisitions

- [[23675]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23675) UseACQFrameworkForBiblioRecords default framework is missing LDR breaking encoding
- [[23929]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23929) Invoice adjustments should filter inactive funds
- [[27813]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27813) Purchase suggestions should sort by suggesteddate rather than title

  >This changes the list of purchase suggestions so that the oldest suggestions are shown first, rather than by title. (This was the behaviour before Koha 20.05).

### Architecture, internals, and plumbing

- [[26742]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26742) Add configuration for message broker
- [[27680]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27680) API DataTables Wrapper fails for ordering on multi-data-field columns
- [[27714]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27714) Koha::NewsItem->author explodes if the author has been removed

  >This fixes the cause of errors occurring for the display of news items where the author of no longer exists in Koha.

### Cataloging

- [[25777]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25777) Datatables on z3950_search.pl show incorrect number of entries
- [[26964]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26964) Advanced editor no longer selects newly created macros

  >This patch fixes the behaviour for saving of new macros using the advanced editor. Before this fix the newly created macro wasn't selected and the automatic save (there isn't a save option) had nothing to save.
- [[27578]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27578) Searchid not initialized when adding a new record

### Circulation

- [[25690]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25690) SIP should not allow to check out an item in transfer because of a hold to another patron

  >- Proper warning messages are added in staff interface when trying to initiate transfer to an attached hold.
  >
  >- Checking out someone else's hold that is in transit is prevented
- [[27058]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27058) Cannot place hold to ordered item when on shelf holds are not allowed

### Database

- [[7806]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7806) Don't use 0000-00-00 to signal a non-existing date

### Hold requests

- [[27729]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27729) Code around SkipHoldTrapOnNotForLoanValue contains two perl bugs

### I18N/L10N

- [[27815]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27815) "Remove" in point of sale untranslatable
- [[27816]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27816) "Click to edit" in Point of sale is untranslatable

### OPAC

- [[27650]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27650) Wrong variable passed to the template in opac-main

### Patrons

- [[27717]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27717) Date of birth fails to display for babies under 1 year
- [[27822]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27822) Wrong systempreference for AddressFormat (es-ES)

### REST API

- [[27330]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27330) Wrong return status when no enrollments in club holds
- [[27593]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27593) Inconsistent return status on club holds routes

### SIP2

- [[27014]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27014) SIP2 cannot find patrons at checkin

### Searching

- [[27745]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27745) Use of uninitialized value in hash element error at C4/Search.pm

### Searching - Elasticsearch

- [[26051]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26051) Elasticsearch uses the wrong field for callnumber sorting

  >This fixes the sorting of search results by call number when using Elasticsearch. Currently it does not sort correctly (uses local-classification instead of cn-sort) and may also cause error messages "No results found" and "Error: Unable to perform your search. Please try again.". This also matches the behaviour used by Zebra.
- [[27316]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27316) In mappings use yes/no for sortable

### Searching - Zebra

- [[8426]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8426) Map  ︡a to a and t︠ to t for searching (Non-ICU)

### Serials

- [[27332]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27332) When renewing a serial subscription, show note and library only if RenewSerialAddsSuggestion is used

### Staff Client

- [[27776]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27776) Point of Sale 'This sale' table should not be sorted by default
- [[27777]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27777) Improve tables on Point of Sale page for low screen resolutions

### System Administration

- [[27703]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27703) Can't navigate in Authorized values

  >This fixes an issue when navigating authorized value categories - if you selected an authorized value category from the drop down list it wouldn't change to the selected category.
- [[27713]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27713) Duplicate search field IDs in MARC framework administration template
- [[27716]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27716) Insufficient access control for printer profiles

  >This change moves the label creator pages, including the printer profiles management, under the 'lable_creator' permission under tools. This gives a more refined access permission for this area of functionality.
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

As of the date of these release notes, the Koha manual is available in the following languages:

- [English](http://koha-community.org/manual/20.11/en/html/)
- [Arabic](http://koha-community.org/manual/20.11/ar/html/)
- [Chinese - Taiwan](http://koha-community.org/manual/20.11/zh_TW/html/)
- [Czech](http://koha-community.org/manual/20.11/cs/html/)
- [French](http://koha-community.org/manual/20.11/fr/html/)
- [French (Canada)](http://koha-community.org/manual/20.11/fr_CA/html/)
- [German](http://koha-community.org/manual/20.11/de/html/)
- [Hindi](http://koha-community.org/manual/20.11/hi/html/)
- [Italian](http://koha-community.org/manual/20.11/it/html/)
- [Portuguese - Brazil](http://koha-community.org/manual/20.11/pt_BR/html/)
- [Spanish](http://koha-community.org/manual/20.11/es/html/)
- [Turkish](http://koha-community.org/manual/20.11/tr/html/)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (99.8%)
- Armenian (100%)
- Armenian (Classical) (89%)
- Catalan; Valencian (50.1%)
- Chinese (Taiwan) (88.5%)
- Czech (73.1%)
- English (New Zealand) (59.6%)
- English (USA)
- Finnish (78.3%)
- French (78.9%)
- French (Canada) (91.4%)
- German (100%)
- German (Switzerland) (67%)
- Greek (60.8%)
- Hindi (100%)
- Italian (100%)
- Norwegian Bokmål (63.5%)
- Polish (71.3%)
- Portuguese (77.3%)
- Portuguese (Brazil) (88.8%)
- Russian (93.6%)
- Slovak (80.7%)
- Spanish (98.8%)
- Swedish (74.6%)
- Telugu (79.7%)
- Turkish (94.8%)
- Ukrainian (64.1%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 20.11.04 is


- Release Manager: Jonathan Druart

- Release Manager assistants:
  - Martin Renvoize
  - Tomás Cohen Arazi

- QA Manager: Katrin Fischer

- QA Team:
  - David Cook
  - Agustín Moyano
  - Martin Renvoize
  - Marcel de Rooy
  - Joonas Kylmälä
  - Julian Maurice
  - Tomás Cohen Arazi
  - Josef Moravec
  - Nick Clemens
  - Kyle Hall
  - Victor Grousset

- Topic Experts:
  - UI Design -- Owen Leonard
  - REST API -- Tomás Cohen Arazi
  - Zebra -- Fridolin Somers
  - Accounts -- Martin Renvoize

- Bug Wranglers:
  - Amit Gupta
  - Mengü Yazıcıoğlu
  - Indranil Das Gupta

- Packaging Managers:
  - David Cook
  - Mason James
  - Agustín Moyano

- Documentation Manager: Caroline Cyr La Rose


- Documentation Team:
  - Marie-Luce Laflamme
  - Lucy Vaux-Harvey
  - Henry Bolshaw
  - David Nind

- Translation Managers: 
  - Indranil Das Gupta
  - Bernardo González Kriegel

- Release Maintainers:
  - 20.11 -- Fridolin Somers
  - 20.05 -- Andrew Fuerste-Henry
  - 19.11 -- Victor Grousset

## Credits

We thank the following individuals who contributed patches to Koha 20.11.04.

- Tomás Cohen Arazi (18)
- Philippe Blouin (1)
- Nick Clemens (11)
- David Cook (6)
- Jonathan Druart (36)
- Katrin Fischer (1)
- Kyle M Hall (5)
- Mason James (1)
- Joonas Kylmälä (11)
- Owen Leonard (11)
- Matthias Meusburger (1)
- Agustín Moyano (2)
- Martin Renvoize (19)
- Phil Ringnalda (2)
- Marcel de Rooy (2)
- Samir Shah (1)
- Fridolin Somers (7)
- Koha Translators (1)
- Petro Vashchuk (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 20.11.04

- Athens County Public Libraries (11)
- BibLibre (8)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (1)
- ByWater-Solutions (16)
- Chetco Community Public Library (2)
- Independant Individuals (1)
- Koha Community Developers (36)
- KohaAloha (1)
- Prosentient Systems (6)
- PTFS-Europe (19)
- regulusweb.com (1)
- Rijks Museum (2)
- Solutions inLibro inc (1)
- Theke Solutions (20)
- University of Helsinki (11)

We also especially thank the following individuals who tested patches
for Koha.

- Tomás Cohen Arazi (15)
- Sonia Bouis (1)
- Nick Clemens (13)
- Michal Denar (1)
- Jonathan Druart (101)
- Katrin Fischer (25)
- Martha Fuerst (2)
- Andrew Fuerste-Henry (3)
- Lucas Gass (3)
- Didier Gautheron (1)
- Victor Grousset (3)
- Kyle M Hall (16)
- Sally Healey (1)
- Barbara Johnson (1)
- Joonas Kylmälä (1)
- Owen Leonard (6)
- Kelly McElligott (1)
- Matthias Meusburger (1)
- David Nind (23)
- Séverine Queune (1)
- Martin Renvoize (66)
- Phil Ringnalda (2)
- Marcel de Rooy (20)
- Lisette Scheer (2)
- Fridolin Somers (135)
- Petro Vashchuk (1)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/Koha-community/Koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 20.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 24 mars 2021 11:25:38.
