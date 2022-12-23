# RELEASE NOTES FOR KOHA 21.11.15
23 Dec 2022

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 21.11.15 can be downloaded from:

- [Download](http://download.koha-community.org/koha-21.11.15.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 21.11.15 is a bugfix/maintenance release.

It includes 3 enhancements, 38 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations




## Enhancements

### Acquisitions

- [[31459]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31459) Make order receive page faster on systems with many budgets

### Architecture, internals, and plumbing

- [[31776]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31776) Typo in cleanup_database.pl cron's help/usage

### Notices

- [[27265]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27265) process_message_queue.pl cron should be able to take multiple types as a parameter

  >This patch adds the ability to specify several types or letter codes when running the process_message_queue script. This allows libraries to consolidate calls when some message types or letter codes are scheduled differently than others


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[31785]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31785) Adding or editing library does not respect public flag

### OPAC

- [[32114]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32114) Template error in OPAC search results RSS

### Packaging

- [[31588]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31588) Update cpanfile for new OpenAPI versions


## Other bugs fixed

### Acquisitions

- [[29554]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29554) neworderempty.pl may create records with biblioitems.itemtype NULL
- [[30359]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30359) GetBudgetHierarchy is slow on order receive page

  **Sponsored by** *Koha-Suomi Oy*
- [[31587]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31587) Basket not accessible from ACQORDER notice

  >This makes sure that the basket object is passed to the ACQORDER notice in order to allow adding information about the basket and the order lines within it.
- [[31649]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31649) Acquisition basket CSV export fails if biblio does not exist

### Architecture, internals, and plumbing

- [[20457]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20457) Overdue and pre-overdue cronjobs not skipping phone notices
- [[31196]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31196) Key "default_value_for_mod_marc-" cleared from cache but not set anymore
- [[31441]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31441) Koha::Item::as_marc_field ignores subfields where kohafield is an empty string
- [[31469]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31469) log4perl.conf: Plack logfiles need %n in conversionpattern
- [[31920]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31920) Unit test t/db_dependent/Holds.t leaves behind database cruft

### Cataloging

- [[31643]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31643) Link authorities automatically requires ALL cataloging and authorities permissions
- [[31682]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31682) Silence warn when using automatic linker in biblio editor

  **Sponsored by** *Catalyst*

### Circulation

- [[31903]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31903) Article requests: Edit URLs link missing in the New tab

### Documentation

- [[27315]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27315) The man pages for the command line utilities do not display properly

### Fines and fees

- [[29987]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29987) Manual credits are not recorded for a register

  >This fixes the recording of manual credits for patrons so that these transactions are now included in the cash summary report for a library. When adding a manual credit, there are now fields for choosing the transaction type and cash register.

### Hold requests

- [[31540]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31540) Holds reminder cronjob should consider expiration date of holds, and not send notices if hold expired
- [[31575]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31575) Missing warning for holds where AllowHoldPolicyOverride can be used to force a hold to be placed

### I18N/L10N

- [[30517]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30517) Translation breaks editing parent type circulation rule

### MARC Authority data support

- [[19693]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19693) Update of an authority record creates inconsistency when the heading tag is changed

### OPAC

- [[31685]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31685) Article request count in table caption of opac-user missing

### Plugin architecture

- [[31684]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31684) Plugin versions starting with a "v" cause unnecessary warnings

### Reports

- [[28967]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28967) Patrons with no checkouts report shows patrons from other libraries with IndependentBranches

### SIP2

- [[31552]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31552) SIP2 option format_due_date not honored for AH field in item information response

### Searching

- [[15048]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15048) Genre/Form (655) searches fail on searches with $x 'General subdivision' subfield values

### Searching - Elasticsearch

- [[29561]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29561) Remove blank facet for languages

  >This removes blank facets from search results when using Elasticsearch. Currently, this only seems to affect language fields, but could affect any facetable field that contains blank values.

### Searching - Zebra

- [[31532]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31532) Zebra search results including 880 with original script incorrect because of Bug 15187

### Staff interface

- [[18556]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18556) Message "Patron's address in doubt" is confusing

### System Administration

- [[31976]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31976) Incorrect default category selected by authorized values page

### Templates

- [[29671]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29671) Dropbox mode is unchecked after check in confirm on item with Materials specified
- [[31412]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31412) Set focus for cursor to Name when adding a new SMTP server
- [[31420]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31420) Managing funds: Labels of statistic fields overlap with pull downs
- [[31559]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31559) Staff results page doesn't always use up full available screen width

### Test Suite

- [[31593]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31593) Remove Test::DBIx::Class from Context.t
- [[31883]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31883) Filter trim causes false warnings

### Tools

- [[31595]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31595) Import patrons tool should not process extended attributes if no attributes are being imported
- [[31644]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31644) MARCModification template fails to copy to/from subfield 0



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/21.11/ar/html/) (33.8%)
- [Chinese (Taiwan)](https://koha-community.org/manual/21.11/zh_TW/html/) (58.8%)
- [Czech](https://koha-community.org/manual/21.11/cs/html/) (27.2%)
- [English (USA)](https://koha-community.org/manual/21.11/en/html/)
- [French](https://koha-community.org/manual/21.11/fr/html/) (68.8%)
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

- Arabic (86.6%)
- Armenian (100%)
- Armenian (Classical) (89%)
- Bulgarian (100%)
- Chinese (Taiwan) (78.8%)
- Czech (76.8%)
- English (New Zealand) (60.3%)
- English (USA)
- Finnish (98.8%)
- French (95.5%)
- French (Canada) (92%)
- German (100%)
- German (Switzerland) (58.3%)
- Greek (60.4%)
- Hindi (100%)
- Italian (100%)
- Nederlands-Nederland (Dutch-The Netherlands) (86.5%)
- Norwegian Bokmål (62.7%)
- Polish (100%)
- Portuguese (91%)
- Portuguese (Brazil) (83%)
- Russian (84.2%)
- Slovak (74.7%)
- Spanish (100%)
- Swedish (81.6%)
- Telugu (94.3%)
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

The release team for Koha 21.11.15 is


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
new features in Koha 21.11.15

- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)
- Koha-Suomi Oy

We thank the following individuals who contributed patches to Koha 21.11.15

- Aleisha Amohia (1)
- Tomás Cohen Arazi (1)
- Nick Clemens (15)
- David Cook (1)
- Jonathan Druart (1)
- Katrin Fischer (1)
- Isobel Graham (1)
- Kyle M Hall (9)
- Mason James (1)
- Janusz Kaczmarek (2)
- Owen Leonard (4)
- The Minh Luong (1)
- Julian Maurice (1)
- Johanna Raisa (1)
- Martin Renvoize (4)
- Marcel de Rooy (9)
- Andreas Roussos (1)
- Fridolin Somers (3)
- Arthur Suzuki (3)
- Christophe Torin (1)
- Koha translators (1)
- Petro Vashchuk (1)
- Shi Yao Wang (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 21.11.15

- Athens County Public Libraries (4)
- BibLibre (7)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (1)
- ByWater-Solutions (24)
- Catalyst Open Source Academy (1)
- Dataly Tech (1)
- Independant Individuals (5)
- Koha Community Developers (1)
- KohaAloha (1)
- Prosentient Systems (1)
- PTFS-Europe (4)
- Rijksmuseum (9)
- Solutions inLibro inc (2)
- Theke Solutions (1)
- Université Rennes 2 (1)

We also especially thank the following individuals who tested patches
for Koha

- Tomás Cohen Arazi (60)
- Emmanuel Bétemps (1)
- Catrina (1)
- Nick Clemens (1)
- Chris Cormack (1)
- Katrin Fischer (30)
- Andrew Fuerste-Henry (1)
- Lucas Gass (61)
- Géraud (1)
- Kyle M Hall (4)
- Barbara Johnson (1)
- Joonas Kylmälä (4)
- Owen Leonard (1)
- David Nind (25)
- Martin Renvoize (8)
- Marcel de Rooy (16)
- Caroline Cyr La Rose (1)
- Arthur Suzuki (60)



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

Autogenerated release notes updated last on 23 Dec 2022 12:07:24.
