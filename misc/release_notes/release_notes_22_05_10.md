# RELEASE NOTES FOR KOHA 22.05.10
27 Feb 2023

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 22.05.10 can be downloaded from:

- [Download](http://download.koha-community.org/koha-22.05.10.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 22.05.10 is a bugfix/maintenance release.

It includes 2 enhancements, 46 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha [here](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).




## Enhancements

### Templates

- [[31407]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31407) Set focus for cursor to Currency when adding a new currency
- [[32688]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32688) Convert recalls awaiting pickup tabs to Bootstrap


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[32393]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32393) background job worker explodes if JSON is incorrect
- [[32394]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32394) Long tasks queue is never used
- [[32561]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32561) background job worker is still running with all the modules in RAM
- [[32612]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32612) Koha background worker should log to worker-error/output.log
- [[32656]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32656) Script delete_records_via_leader.pl no longer deletes items

### Fines and fees

- [[30254]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30254) New overdue fine applied to incorrectly when using "Refund lost item charge and charge new overdue fine" option in circ rules

### I18N/L10N

- [[32356]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32356) xx-XX installer dir /kohadevbox/koha/installer/data/mysql/xx-XX already exists.

### Plugin architecture

- [[32539]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32539) UI hooks can break the UI

### SIP2

- [[32515]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32515) SIP2 no block flag on checkin calls routine that does not exist


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
- [[31893]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31893) Some pages load about.tt template to check authentication rather than using checkauth
- [[32573]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32573) background_jobs_worker.pl should ACK a message before it forks and runs the job

### Cataloging

- [[29173]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29173) Button "replace authority record via Z39/50/SRU" doesn't pre-fill

  >This fixes the behaviour of the replace an authority record via Z39.50/SRU buttons when editing an authority record. Both ways of doing this (Edit > Edit record > Replace record via Z39.50/SRU search and Edit > Replace record via Z39.50/SRU search) now pre-fill the search form with available data.
- [[30250]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30250) Configure when to apply framework defaults when cataloguing

  **Sponsored by** *Catalyst* and *Education Services Australia SCIS*

  >This patch adds a system preference ApplyFrameworkDefaults to configure when to apply framework defaults - when cataloguing a new record, when editing a record as new (duplicating), or when changing the framework while editing an existing record, or when importing a record. This applies to both bibliographic records and authority records.
- [[32321]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32321) 006 field not correctly prepopulated in Advanced cataloging editor
- [[32692]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32692) Terminology: MARC framework tag subfield editor uses intranet instead of staff interface

### Circulation

- [[29021]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29021) Automatic renewal due to RenewAccruingItemWhenPaid should not be considered Seen
- [[29792]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29792) Transfers created from 'wrong transfer' checkin are not sent if modal is dismissed

### Lists

- [[32237]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32237) Batch delete records "no record IDs defined"

### Notices

- [[32221]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32221) Password entry should be removed from placeholder list in notices editor

### OPAC

- [[8948]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8948) MARC21 field 787 doesn't display

### Patrons

- [[32570]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32570) City is duplicated in patron search if the patron has both city and state
- [[32574]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32574) memberresultst table cannot be column configured in 22.05.x

  >This fixes an issue with configuring the columns for patron search results in Koha 22.05 - this should now work as expected. The columns are now configurable using the Columns button in the search results and in the table settings (Administration > Additional parameters > Table settings > Patrons > member > memberresultst).
- [[32655]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32655) Variables showing in patron messaging preferences

### REST API

- [[32409]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32409) Cannot search cashups using non-latin-1 scripts

  >This fixes the cashup history table so that filters can use non latin-1 characters (Point of sale > Cash summary for <library> > select register). Before this fix, the table was not filtered or refreshed if you entered non latin-1 characters.

### SIP2

- [[32408]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32408) If a fine can be overridden on checkout in Koha, what should the SIP client do?
- [[32537]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32537) Add 'no_block' option to sip_cli_emulator

  >This enhanced adds the no-block option to the SIP emulator for optional use in checkout/checkin/renew messages.
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

- [[32289]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32289) Punctuation: Delete desk "...?"
- [[32290]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32290) ILL requests uses some wrong terminology
- [[32294]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32294) Capitalization: Enter your User ID...
- [[32295]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32295) Punctuation: Filters :
- [[32672]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32672) Incorrect CSS path to jquery-ui

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


- [Arabic](https://koha-community.org/manual/22.05/ar/html/) (28.2%)
- [Chinese (Taiwan)](https://koha-community.org/manual/22.05/zh_TW/html/) (65.8%)
- [English (USA)](https://koha-community.org/manual/22.05/en/html/)
- [French](https://koha-community.org/manual/22.05/fr/html/) (62.6%)
- [German](https://koha-community.org/manual/22.05/de/html/) (66.7%)
- [Hindi](https://koha-community.org/manual/22.05/hi/html/) (100%)
- [Italian](https://koha-community.org/manual/22.05/it/html/) (41.2%)
- [Spanish](https://koha-community.org/manual/22.05/es/html/) (29.8%)
- [Turkish](https://koha-community.org/manual/22.05/tr/html/) (33.5%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (77.9%)
- Armenian (100%)
- Armenian (Classical) (71.6%)
- Bulgarian (85.5%)
- Chinese (Taiwan) (94.8%)
- Czech (62.3%)
- English (New Zealand) (58.4%)
- English (USA)
- Finnish (94.7%)
- French (97%)
- French (Canada) (99.8%)
- German (100%)
- German (Switzerland) (54.1%)
- Greek (55.5%)
- Hindi (99.9%)
- Italian (99.9%)
- Nederlands-Nederland (Dutch-The Netherlands) (84.7%)
- Norwegian Bokmål (56%)
- Persian (58.7%)
- Polish (99.9%)
- Portuguese (85.9%)
- Portuguese (Brazil) (76.7%)
- Russian (78.4%)
- Slovak (63.9%)
- Spanish (99.9%)
- Swedish (78.5%)
- Telugu (84.6%)
- Turkish (91.9%)
- Ukrainian (74.2%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 22.05.10 is


- Release Manager: Tomás Cohen Arazi

- Release Manager assistants:
  - Jonathan Druart
  - Martin Renvoize

- QA Manager: Katrin Fischer

- QA Team:
  - Aleisha Amohia
  - Nick Clemens
  - David Cook
  - Jonathan Druart
  - Lucas Gass
  - Victor Grousset
  - Kyle M Hall
  - Martin Renvoize
  - Marcel de Rooy
  - Fridolin Somers

- Topic Experts:
  - UI Design -- Owen Leonard
  - Zebra -- Fridolin Somers
  - REST API -- Martin Renvoize

- Bug Wranglers:
  - Aleisha Amohia
  - Indranil Das Gupta

- Packaging Manager: Mason James


- Documentation Manager: Caroline Cyr La Rose


- Documentation Team:
  - Aude Charillon
  - David Nind
  - Lucy Vaux-Harvey

- Translation Manager: Bernardo González Kriegel


- Wiki curators: 
  - Thomas Dukleth
  - Katrin Fischer

- Release Maintainers:
  - 22.11 -- PTFS Europe (Martin Renvoize, Matt Blenkinsop, Jacob O'Mara)
  - 22.05 -- Lucas Gass
  - 21.11 -- Arthur Suzuki
  - 21.05 -- Wainui Witika-Park

## Credits
We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 22.05.10

- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)
- Education Services Australia SCIS
- [Koha-Suomi Oy](https://koha-suomi.fi)

We thank the following individuals who contributed patches to Koha 22.05.10

- Aleisha Amohia (4)
- Tomás Cohen Arazi (7)
- Matt Blenkinsop (1)
- Alex Buckley (1)
- Nick Clemens (16)
- David Cook (2)
- Jonathan Druart (9)
- Katrin Fischer (8)
- Géraud Frappier (1)
- Lucas Gass (11)
- Thibaud Guillot (1)
- Kyle M Hall (9)
- Mason James (2)
- Jan Kissig (1)
- Owen Leonard (2)
- Matthias Meusburger (1)
- David Nind (1)
- Martin Renvoize (3)
- Marcel de Rooy (4)
- Caroline Cyr La Rose (1)
- Emmi Takkinen (1)
- Koha translators (1)
- Jenny Way (1)
- Hammat Wele (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 22.05.10

- Athens County Public Libraries (2)
- BibLibre (2)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (8)
- ByWater-Solutions (36)
- Catalyst (1)
- Catalyst Open Source Academy (4)
- David Nind (1)
- Independant Individuals (1)
- Koha Community Developers (9)
- Koha-Suomi (1)
- KohaAloha (2)
- Prosentient Systems (2)
- PTFS-Europe (4)
- Rijksmuseum (4)
- Solutions inLibro inc (3)
- th-wildau.de (1)
- Theke Solutions (7)

We also especially thank the following individuals who tested patches
for Koha

- Pedro Amorim (3)
- Tomás Cohen Arazi (71)
- Matt Blenkinsop (19)
- Philippe Blouin (1)
- Nick Clemens (2)
- Frédéric Demians (1)
- Jonathan Druart (3)
- Katrin Fischer (15)
- Andrew Fuerste-Henry (7)
- Lucas Gass (78)
- Amaury GAU (1)
- Kyle M Hall (13)
- Owen Leonard (6)
- David Nind (31)
- Jacob O'Mara (39)
- Jacob Omara (1)
- Martin Renvoize (26)
- Marcel de Rooy (15)
- Caroline Cyr La Rose (1)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is rmain2205.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 27 Feb 2023 20:18:40.
