# RELEASE NOTES FOR KOHA 21.11.17
06 Mar 2023

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 21.11.17 can be downloaded from:

- [Download](http://download.koha-community.org/koha-21.11.17.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 21.11.17 is a bugfix/maintenance release.

It includes 1 enhancements, 30 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations




## Enhancements

### Templates

- [[31407]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31407) Set focus for cursor to Currency when adding a new currency


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[32656]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32656) Script delete_records_via_leader.pl no longer deletes items

### I18N/L10N

- [[32356]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32356) xx-XX installer dir /kohadevbox/koha/installer/data/mysql/xx-XX already exists.

### Plugin architecture

- [[32539]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32539) UI hooks can break the UI

### SIP2

- [[29755]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29755) SIP2 code does not correctly handle NoIssuesChargeGuarantees  or  NoIssuesChargeGuarantorsWithGuarantees

  >This fixes SIP2 so that it correctly determines if issues should be blocked for patrons when the NoIssuesChargeGuarantees and NoIssuesChargeGuarantorsWithGuarantees system preferences are set. Currently, it only checks the noissuescharge system preference as the limit for charges, and not the other 'No Issues charge' system preferences.


## Other bugs fixed

### Acquisitions

- [[32377]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32377) GetBudgetHierarchy slows down acqui/histsearch.pl

  **Sponsored by** *Koha-Suomi Oy*
- [[32406]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32406) Cannot search pending orders using non-latin-1 scripts
- [[32694]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32694) Keep current option for budgets in receiving broken

### Architecture, internals, and plumbing

- [[18247]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18247) Remove SQL queries from branch_transfer_limit.pl administrative script

  **Sponsored by** *Catalyst*
- [[28672]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28672) Improve EDI debug logging
- [[32573]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32573) background_jobs_worker.pl should ACK a message before it forks and runs the job

### Cataloging

- [[29173]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29173) Button "replace authority record via Z39/50/SRU" doesn't pre-fill

  >This fixes the behaviour of the replace an authority record via Z39.50/SRU buttons when editing an authority record. Both ways of doing this (Edit > Edit record > Replace record via Z39.50/SRU search and Edit > Replace record via Z39.50/SRU search) now pre-fill the search form with available data.
- [[30250]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30250) Configure when to apply framework defaults when cataloguing

  **Sponsored by** *Catalyst* and *Education Services Australia SCIS*

  >This patch adds a system preference ApplyFrameworkDefaults to configure when to apply framework defaults - when cataloguing a new record, when editing a record as new (duplicating), or when changing the framework while editing an existing record, or when importing a record. This applies to both bibliographic records and authority records.
- [[32321]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32321) 006 field not correctly prepopulated in Advanced cataloging editor

### Circulation

- [[29792]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29792) Transfers created from 'wrong transfer' checkin are not sent if modal is dismissed

### Notices

- [[32221]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32221) Password entry should be removed from placeholder list in notices editor

### OPAC

- [[8948]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8948) MARC21 field 787 doesn't display

### Patrons

- [[32655]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32655) Variables showing in patron messaging preferences

### REST API

- [[32409]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32409) Cannot search cashups using non-latin-1 scripts

  >This fixes the cashup history table so that filters can use non latin-1 characters (Point of sale > Cash summary for <library> > select register). Before this fix, the table was not filtered or refreshed if you entered non latin-1 characters.

### SIP2

- [[32624]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32624) Patrons fines are not accurate in SIP2 when NoIssuesChargeGuarantorsWithGuarantees or NoIssuesChargeGuarantees are enabled

### Searching - Zebra

- [[32416]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32416) arp - Accelerated reader point searches fail due to conflicting attribute

  >This fixes
- [[32741]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32741) Attribute codes should not be repeated in bib1.att

### Self checkout

- [[19188]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19188) Self checkout: Fine blocking checkout is missing currency symbol

### Staff interface

- [[28314]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28314) Spinning icon is not always going away for local covers in staff
- [[31768]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31768) Tags is a 'Tool' but doesn't include the tools nav sidebar
- [[32523]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32523) Shortcuts / Links to missing fields in MARC-Editor don't work as expected

  >This fixes the standard MARC editor so that the links for any errors go to the correct tab. Currently, the links only work if you are the correct tab.
- [[32644]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32644) Terminology: staff/intranet and biblio in plugins home page

  >This patch replaces some incorrect terminology in the plugins home page regarding enhanced content plugins.
- [[32797]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32797) Cannot save OAI set mapping rule for subfield 0

### Templates

- [[32290]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32290) ILL requests uses some wrong terminology
- [[32294]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32294) Capitalization: Enter your User ID...

### Tools

- [[26628]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26628) Clubs permissions should grant access to Tools page

## New system preferences
- ApplyFrameworkDefaults
- AutomaticWrongTransfer



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/21.11/ar/html/) (33.8%)
- [Chinese (Taiwan)](https://koha-community.org/manual/21.11/zh_TW/html/) (58.8%)
- [Czech](https://koha-community.org/manual/21.11/cs/html/) (27.2%)
- [English (USA)](https://koha-community.org/manual/21.11/en/html/)
- [French](https://koha-community.org/manual/21.11/fr/html/) (70.1%)
- [French (Canada)](https://koha-community.org/manual/21.11/fr_CA/html/) (25.6%)
- [German](https://koha-community.org/manual/21.11/de/html/) (73.3%)
- [Hindi](https://koha-community.org/manual/21.11/hi/html/) (100%)
- [Italian](https://koha-community.org/manual/21.11/it/html/) (48.2%)
- [Spanish](https://koha-community.org/manual/21.11/es/html/) (36.1%)
- [Turkish](https://koha-community.org/manual/21.11/tr/html/) (39.6%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (86.5%)
- Armenian (100%)
- Armenian (Classical) (89%)
- Bulgarian (99.8%)
- Chinese (Taiwan) (78.6%)
- Czech (76.9%)
- English (New Zealand) (60.1%)
- English (USA)
- Finnish (98.9%)
- French (95.6%)
- French (Canada) (91.9%)
- German (100%)
- German (Switzerland) (58.1%)
- Greek (61.1%)
- Hindi (100%)
- Italian (100%)
- Nederlands-Nederland (Dutch-The Netherlands) (86.3%)
- Norwegian Bokmål (62.5%)
- Polish (99.8%)
- Portuguese (90.9%)
- Portuguese (Brazil) (83.4%)
- Russian (84%)
- Slovak (74.7%)
- Spanish (100%)
- Swedish (81.5%)
- Telugu (94.1%)
- Turkish (100%)
- Ukrainian (75.2%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 21.11.17 is


- Release Manager: Jonathan Druart

- Release Manager assistants:
  - Martin Renvoize
  - Tomás Cohen Arazi

- QA Manager: Katrin Fischer

- QA Team:
  - Agustín Moyano
  - Andrew Nugged
  - David Cook
  - Joonas Kylmälä
  - Julian Maurice
  - Kyle M Hall
  - Marcel de Rooy
  - Martin Renvoize
  - Nick Clemens
  - Petro Vashchuk
  - Tomás Cohen Arazi
  - Victor Grousset

- Topic Experts:
  - UI Design -- Owen Leonard
  - REST API -- Tomás Cohen Arazi
  - Elasticsearch -- Fridolin Somers
  - Zebra -- Fridolin Somers
  - Accounts -- Martin Renvoize

- Bug Wranglers:
  - Sally Healey

- Packaging Manager: 


- Documentation Manager: David Nind


- Documentation Team:
  - David Nind
  - Lucy Vaux-Harvey

- Translation Managers: 
  - Bernardo González Kriegel

- Wiki curators: 
  - Thomas Dukleth

- Release Maintainers:
  - 21.05 -- Kyle M Hall
  - 20.11 -- Fridolin Somers
  - 20.05 -- Victor Grousset
  - 19.11 -- Wainui Witika-Park

- Release Maintainer assistants:
  - 21.05 -- Nick Clemens

- Release Maintainer mentors:
  - 19.11 -- Aleisha Amohia

## Credits
We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 21.11.17

- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)
- Education Services Australia SCIS
- Koha-Suomi Oy

We thank the following individuals who contributed patches to Koha 21.11.17

- Aleisha Amohia (4)
- Tomás Cohen Arazi (4)
- Matt Blenkinsop (1)
- Alex Buckley (1)
- Nick Clemens (13)
- David Cook (2)
- Jonathan Druart (3)
- Katrin Fischer (6)
- Lucas Gass (1)
- Thibaud Guillot (1)
- Kyle M Hall (3)
- Jan Kissig (1)
- Martin Renvoize (2)
- Caroline Cyr La Rose (1)
- Arthur Suzuki (4)
- Emmi Takkinen (1)
- Koha translators (1)
- Jenny Way (1)
- Hammat Wele (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 21.11.17

- BibLibre (5)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (6)
- ByWater-Solutions (17)
- Catalyst (1)
- Catalyst Open Source Academy (4)
- Independant Individuals (1)
- Koha Community Developers (3)
- Koha-Suomi (1)
- Prosentient Systems (2)
- PTFS-Europe (3)
- Solutions inLibro inc (2)
- th-wildau.de (1)
- Theke Solutions (4)

We also especially thank the following individuals who tested patches
for Koha

- Pedro Amorim (2)
- Tomás Cohen Arazi (42)
- Matt Blenkinsop (8)
- Frédéric Demians (1)
- Jonathan Druart (3)
- Katrin Fischer (12)
- Andrew Fuerste-Henry (7)
- Lucas Gass (44)
- Kyle M Hall (7)
- Owen Leonard (4)
- David Nind (23)
- Jacob O'Mara (23)
- Jacob Omara (1)
- Martin Renvoize (16)
- Marcel de Rooy (6)
- Fridolin Somers (2)
- Arthur Suzuki (46)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 21.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 06 Mar 2023 10:46:59.
