# RELEASE NOTES FOR KOHA 20.11.11
28 oct. 2021

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 20.11.11 can be downloaded from:

- [Download](http://download.koha-community.org/koha-20.11.11.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 20.11.11 is a bugfix/maintenance release.

It includes 46 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations






## Critical bugs fixed

### Acquisitions

- [[28960]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28960) EDI transfer_items uses a relationship where it's looking for a field

### Architecture, internals, and plumbing

- [[29134]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29134) Patron search has poor performance when ExtendedAttributes enabled and many attributes match

### Cataloging

- [[28676]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28676) AutoCreateAuthorities can repeatedly generate authority records when using Default linker and heading is cached
- [[29137]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29137) Unwanted authorised values are too easily created via the cataloging module

### Command-line Utilities

- [[29076]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29076) cleanup_database.pl dies of passed zebraqueue and not confirm

### OPAC

- [[28845]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28845) OpacAddMastheadLibraryPulldown does not respect multibranchlimit in OPAC_SEARCH_LIMIT

### REST API

- [[29032]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29032) ILL route unusable (slow)

### Staff Client

- [[28986]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28986) Parent itemtype not selected when editing circ rules


## Other bugs fixed

### Acquisitions

- [[28956]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28956) Acquisitions: select correct default tax rate when receiving orders

  **Sponsored by** *Catalyst*

### Architecture, internals, and plumbing

- [[28992]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28992) Resolve warning from undefined BIG_LOOP
- [[29175]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29175) finishreceive: Replace , by ;

### Authentication

- [[28914]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28914) Wrong wording in authentication forms

### Cataloging

- [[27461]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27461) Fix field 008 length below 40 positions in cataloguing plugin
- [[28829]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28829) Useless single quote escaping in value_builder/unimarc_field_4XX.pl

### Circulation

- [[21093]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21093) Specified due date incorrectly retained when using fast add
- [[28653]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28653) Sorting loans by due date doesn't work after renewing

  **Sponsored by** *Koha-Suomi Oy*
- [[28985]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28985) Negative rental amounts can be saved but not enforced
- [[29026]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29026) Behavior change when an empty barcode field is submitted in circulation

### Command-line Utilities

- [[28352]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28352) Errors in search_for_data_inconsistencies.pl relating to authorised values and frameworks
- [[29078]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29078) Division by zero in touch_all scripts
- [[29216]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29216) Correct --where documentation in update_patrons_category.pl

### Hold requests

- [[28510]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28510) Skip processing holds queue items from closed libraries when HoldsQueueSkipClosed is enabled

### Label/patron card printing

- [[28940]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28940) IntranetUserJS is called twice on spinelable-print.tt

### MARC Authority data support

- [[24698]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24698) UNIMARC authorities leader plugin

### OPAC

- [[20277]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20277) Link to host item doesn't work in analytical records if 773$a is present
- [[28930]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28930) Cardnumber is lost if an invalid self registration form is submitted to the server, and the server side form validation fails
- [[29091]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29091) Correct display of lists and tags on search results
- [[29172]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29172) Can't use controlfiels with CustomCoverImagesURL

### Patrons

- [[18747]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18747) Select All in Add Patron Option in Patron Lists only selects the first 20 entries
- [[29025]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29025) Saved auth login and password are pre-filled in patron creation form
- [[29215]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29215) In patron form collapsing "Patron guarantor" display errors

### Plugin architecture

- [[28303]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28303) Having multiple pluginsdir causes plugin_upload to try to write to the opac-tmpl folder

### REST API

- [[29157]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29157) Cannot set date/date-time attributes to NULL

### Reports

- [[29225]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29225) Report subgroup does not appear consistently
- [[29279]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29279) Holds ratio report not sorting correctly

### SIP2

- [[28464]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28464) Cancelling a waiting hold via SIP returns a failed response even when cancellation succeeds

### Searching

- [[28826]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28826) Facet sort order differs between search engines

### Searching - Elasticsearch

- [[25030]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25030) IncludeSeeFromInSearches not honoured in Elasticsearch

  >Feature enabled by system preference IncludeSeeFromInSearches was implemented in Zebra search engine but not in Elasticsearch.
  >This feature allows in bibliographic searches to match also on authorities see from (non-preferred form) headings.

### Staff Client

- [[28472]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28472) UpdateItemLocationOnCheckin not updating items where location is null
- [[29131]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29131) Row striping breaks color coding on item circulation alerts
- [[29244]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29244) alert/error and message dialogues should have the same width

### System Administration

- [[29056]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29056) Remove demo functionality remnants
- [[29298]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29298) "Managing library" missing from histsearch table settings

### Templates

- [[28927]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28927) Id opacmainuserblock used twice in OPAC

  >This patch removes redundant div with id 'opacmainuserblock' and 'opacheader' since there is already this id generated by HTML customization.
- [[29133]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29133) Wrong string format in select2.inc

### Test Suite

- [[27155]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27155) Include identifier test in Biblio_and_Items_plugin_hooks.t

## New system preferences
- CreateAVFromCataloguing
- FacetOrder



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/20.11/ar/html/) (27%)
- [Chinese (Taiwan)](https://koha-community.org/manual/20.11/zh_TW/html/) (61.4%)
- [English (USA)](https://koha-community.org/manual/20.11/en/html/)
- [French](https://koha-community.org/manual/20.11/fr/html/) (52.6%)
- [French (Canada)](https://koha-community.org/manual/20.11/fr_CA/html/) (26%)
- [German](https://koha-community.org/manual/20.11/de/html/) (71.2%)
- [Hindi](https://koha-community.org/manual/20.11/hi/html/) (99.9%)
- [Italian](https://koha-community.org/manual/20.11/it/html/) (50%)
- [Spanish](https://koha-community.org/manual/20.11/es/html/) (36.4%)
- [Turkish](https://koha-community.org/manual/20.11/tr/html/) (41.9%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (99.1%)
- Armenian (100%)
- Armenian (Classical) (89%)
- Bulgarian (91.3%)
- Catalan; Valencian (57.2%)
- Chinese (Taiwan) (93%)
- Czech (73.2%)
- English (New Zealand) (59.5%)
- English (USA)
- Finnish (79.3%)
- French (91.4%)
- French (Canada) (92.1%)
- German (100%)
- German (Switzerland) (66.8%)
- Greek (60.6%)
- Hindi (100%)
- Italian (99.9%)
- Nederlands-Nederland (Dutch-The Netherlands) (81.2%)
- Norwegian Bokmål (63.7%)
- Polish (100%)
- Portuguese (88.4%)
- Portuguese (Brazil) (96.6%)
- Russian (93.6%)
- Slovak (80.4%)
- Spanish (99%)
- Swedish (74.9%)
- Telugu (100%)
- Turkish (100%)
- Ukrainian (69.3%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 20.11.11 is


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
  - Kyle M Hall
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
We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 20.11.11

- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)
- Koha-Suomi Oy

We thank the following individuals who contributed patches to Koha 20.11.11

- Tomás Cohen Arazi (3)
- Nick Clemens (15)
- Jonathan Druart (6)
- Katrin Fischer (2)
- Lucas Gass (2)
- Didier Gautheron (1)
- Victor Grousset (1)
- Michael Hafen (1)
- Kyle M Hall (6)
- Andreas Jonsson (1)
- Joonas Kylmälä (2)
- Owen Leonard (3)
- Julian Maurice (1)
- Martin Renvoize (3)
- Marcel de Rooy (7)
- Caroline Cyr La Rose (1)
- Andreas Roussos (2)
- Fridolin Somers (10)
- Emmi Takkinen (1)
- Koha translators (1)
- Petro Vashchuk (1)
- George Veranis (1)
- Wainui Witika-Park (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 20.11.11

- Athens County Public Libraries (3)
- BibLibre (12)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (2)
- ByWater-Solutions (23)
- Catalyst (1)
- Dataly Tech (3)
- Independant Individuals (3)
- Koha Community Developers (7)
- Koha-Suomi (1)
- Kreablo AB (1)
- PTFS-Europe (3)
- Rijksmuseum (7)
- Solutions inLibro inc (1)
- Theke Solutions (3)
- washk12.org (1)

We also especially thank the following individuals who tested patches
for Koha

- Tomás Cohen Arazi (3)
- Donna Bachowski (1)
- Nick Clemens (4)
- Jonathan Druart (57)
- Esther (1)
- Katrin Fischer (12)
- Andrew Fuerste-Henry (11)
- Kyle M Hall (58)
- kelly (1)
- Joonas Kylmälä (24)
- Owen Leonard (8)
- David Nind (14)
- Eric Phetteplace (2)
- Séverine Queune (1)
- Martin Renvoize (13)
- Phil Ringnalda (5)
- Marcel de Rooy (5)
- Sally (1)
- Julien Sicot (1)
- Fridolin Somers (62)
- Lucy Vaux-Harvey (1)
- George Veranis (11)

We thank the following individuals who mentored new contributors to the Koha project

- Andreas Roussos



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 20.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 28 oct. 2021 20:30:25.
