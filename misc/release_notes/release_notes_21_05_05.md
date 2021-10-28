# RELEASE NOTES FOR KOHA 21.05.05
28 Oct 2021

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 21.05.05 can be downloaded from:

- [Download](http://download.koha-community.org/koha-21.05.05.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 21.05.05 is a bugfix/maintenance release.

It includes 77 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations

## Critical bugs fixed

### Acquisitions

- [[28946]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28946) 500 error when choosing patron for purchase suggestion
- [[28960]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28960) EDI transfer_items uses a relationship where it's looking for a field

### Architecture, internals, and plumbing

- [[29134]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29134) Patron search has poor performance when ExtendedAttributes enabled and many attributes match
- [[29135]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29135) OAI should not include biblionumbers from deleteditems when determining deletedbiblios

  **Sponsored by** *National Library of Finland*
- [[29139]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29139) Paying gives ISE if UseEmailReceipts is enabled
- [[29243]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29243) PrepareItemrecordDisplay should not be called with empty string in defaultvalues

### Cataloging

- [[28676]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28676) AutoCreateAuthorities can repeatedly generate authority records when using Default linker and heading is cached
- [[29137]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29137) Unwanted authorised values are too easily created via the cataloging module

### Command-line Utilities

- [[29076]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29076) cleanup_database.pl dies of passed zebraqueue and not confirm

### Hold requests

- [[28748]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28748) When hold is overridden cannot select a pickup location
- [[29073]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29073) Hold expiration added to new holds when DefaultHoldExpirationdate turned off
- [[29148]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29148) Holds to Pull doesn't reflect item-level holds

### OPAC

- [[28845]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28845) OpacAddMastheadLibraryPulldown does not respect multibranchlimit in OPAC_SEARCH_LIMIT

### REST API

- [[29032]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29032) ILL route unusable (slow)

### Staff Client

- [[28986]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28986) Parent itemtype not selected when editing circ rules
- [[29193]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29193) DataTables only showing 20 results on checkout search and patrons search on request.pl


## Other bugs fixed

### Acquisitions

- [[28956]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28956) Acquisitions: select correct default tax rate when receiving orders

  **Sponsored by** *Catalyst*

### Architecture, internals, and plumbing

- [[28373]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28373) Items fields not used in default XSLT

  >When processing records for display we loop through each field in the record and translate authorized values into descriptions. Item fields in the record contain many authorised values, and the lookups can cause a delay in displaying the record. If using the default XSLT these fields are not displayed as they exist in the record, so parsing them is not necessary and can save time. This bug adds a system preference that disables sending these fields for processing and thus saving time. Enabling the system preference will allow users to pass the items to custom style sheets if needed.
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
- [[29049]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29049) Holds page shows too many priority options in pulldown

### Label/patron card printing

- [[28940]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28940) IntranetUserJS is called twice on spinelable-print.tt

### MARC Authority data support

- [[24698]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24698) UNIMARC authorities leader plugin

### OPAC

- [[20277]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20277) Link to host item doesn't work in analytical records if 773$a is present
- [[28930]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28930) Cardnumber is lost if an invalid self registration form is submitted to the server, and the server side form validation fails
- [[28934]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28934) OPAC registration form design is not consistent
- [[29034]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29034) Accessibility: OPAC nav-links don't have sufficient contrast ratio
- [[29035]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29035) Accessibility: OPAC masthead_search label doesn't have sufficient contrast ratio
- [[29037]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29037) Accessibility: OPAC links don't have sufficient contrast
- [[29038]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29038) Accessibility: OPACUserSummary heading doesn't have sufficient contrast
- [[29064]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29064) OPAC duplicate "Most popular titles" in 'title' tag
- [[29065]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29065) Accessibility: OPAC clear search history link has insufficient contrast
- [[29067]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29067) Remove duplicate conditional statement from OPAC messaging settings title
- [[29068]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29068) Accessibility: OPAC search results summary text has insufficient contrast
- [[29070]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29070) Accessibility: OPAC Purchase Suggestions on search results page has insufficient contrast
- [[29091]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29091) Correct display of lists and tags on search results
- [[29128]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29128) Trailing whitespace in Browse shelf link on opac-detail.tt
- [[29172]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29172) Can't use controlfiels with CustomCoverImagesURL

### Patrons

- [[18747]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18747) Select All in Add Patron Option in Patron Lists only selects the first 20 entries
- [[29025]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29025) Saved auth login and password are pre-filled in patron creation form
- [[29215]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29215) In patron form collapsing "Patron guarantor" display errors

### Plugin architecture

- [[28228]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28228) Warns from plugins when metadata value not defined for key
- [[28303]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28303) Having multiple pluginsdir causes plugin_upload to try to write to the opac-tmpl folder

### REST API

- [[29072]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29072) Move reference route /cities spec to YAML
- [[29157]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29157) Cannot set date/date-time attributes to NULL

### Reports

- [[29225]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29225) Report subgroup does not appear consistently
- [[29271]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29271) Cash register report not displaying or exporting correctly
- [[29279]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29279) Holds ratio report not sorting correctly

### SIP2

- [[28464]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28464) Cancelling a waiting hold via SIP returns a failed response even when cancellation succeeds

### Searching

- [[28826]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28826) Facet sort order differs between search engines

### Searching - Elasticsearch

- [[25030]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25030) IncludeSeeFromInSearches not honoured in Elasticsearch

  >Feature enabled by system preference IncludeSeeFromInSearches was implemented in Zebra search engine but not in Elasticsearch.
  >This feature allows in bibliographic searches to match also on authorities see from (non-preferred form) headings.
- [[28316]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28316) Fix ES crashes related to various punctuation characters
- [[28484]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28484) Elasticsearch fails to parse query if exclamation point is in 245$a

### Staff Client

- [[28472]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28472) UpdateItemLocationOnCheckin not updating items where location is null
- [[29062]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29062) Patron check-in slip repeats data
- [[29131]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29131) Row striping breaks color coding on item circulation alerts
- [[29244]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29244) alert/error and message dialogues should have the same width

### System Administration

- [[29004]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29004) Update GoogleOpenIDConnect preference to make it clear that it is OPAC-only

  >This improves the description of the GoogleOpenIDConnect and related preferences to make it clear that GoogleOpenIDConnect affects OPAC logins and that the preferences are related.
- [[29056]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29056) Remove demo functionality remnants
- [[29298]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29298) "Managing library" missing from histsearch table settings

### Templates

- [[28438]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28438) Capitalization: Various corrections
- [[28470]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28470) Typo: Are you sure you with to chart this report?
- [[28579]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28579) Typo: No record have been imported because they all match an existing record in your catalog.
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


- [Arabic](https://koha-community.org/manual/21.05/ar/html/) (34.3%)
- [Chinese (Taiwan)](https://koha-community.org/manual/21.05/zh_TW/html/) (58.7%)
- [Czech](https://koha-community.org/manual/21.05/cs/html/) (27.6%)
- [English (USA)](https://koha-community.org/manual/21.05/en/html/)
- [French](https://koha-community.org/manual/21.05/fr/html/) (51.7%)
- [French (Canada)](https://koha-community.org/manual/21.05/fr_CA/html/) (25.2%)
- [German](https://koha-community.org/manual/21.05/de/html/) (73.3%)
- [Hindi](https://koha-community.org/manual/21.05/hi/html/) (100%)
- [Italian](https://koha-community.org/manual/21.05/it/html/) (47.8%)
- [Spanish](https://koha-community.org/manual/21.05/es/html/) (34.8%)
- [Turkish](https://koha-community.org/manual/21.05/tr/html/) (40.3%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (90.1%)
- Armenian (100%)
- Armenian (Classical) (89%)
- Chinese (Taiwan) (81.7%)
- Czech (71.5%)
- English (New Zealand) (61.6%)
- English (USA)
- Finnish (82.4%)
- French (87.9%)
- French (Canada) (87.6%)
- German (100%)
- German (Switzerland) (60.9%)
- Greek (55.1%)
- Hindi (100%)
- Italian (92.1%)
- Nederlands-Nederland (Dutch-The Netherlands) (61.8%)
- Norwegian Bokmål (66%)
- Polish (100%)
- Portuguese (90.8%)
- Portuguese (Brazil) (87.3%)
- Russian (86.6%)
- Slovak (72.9%)
- Spanish (90.7%)
- Swedish (77.2%)
- Telugu (100%)
- Turkish (99.5%)
- Ukrainian (64.4%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 21.05.05 is


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
  - 21.05 -- Kyle Hall
  - 20.11 -- Fridolin Somers
  - 20.05 -- Andrew Fuerste-Henry
  - 19.11 -- Victor Grousset

## Credits
We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 21.05.05

- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)
- Koha-Suomi Oy
- National Library of Finland

We thank the following individuals who contributed patches to Koha 21.05.05

- Tomás Cohen Arazi (7)
- Alex Arnaud (1)
- Henry Bolshaw (7)
- Jérémy Breuillard (1)
- Nick Clemens (29)
- Jonathan Druart (9)
- Katrin Fischer (3)
- Lucas Gass (4)
- Didier Gautheron (1)
- Michael Hafen (1)
- Kyle M Hall (19)
- Andreas Jonsson (1)
- Joonas Kylmälä (5)
- Owen Leonard (7)
- Ere Maijala (1)
- Julian Maurice (1)
- David Nind (1)
- Martin Renvoize (6)
- Marcel de Rooy (8)
- Caroline Cyr La Rose (1)
- Andreas Roussos (2)
- Fridolin Somers (5)
- Emmi Takkinen (1)
- Lari Taskula (2)
- Koha translators (1)
- Petro Vashchuk (7)
- George Veranis (1)
- Wainui Witika-Park (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 21.05.05

- Athens County Public Libraries (7)
- BibLibre (9)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (3)
- ByWater-Solutions (52)
- Catalyst (1)
- Dataly Tech (3)
- David Nind (1)
- Hypernova Oy (2)
- Independant Individuals (12)
- Koha Community Developers (9)
- Koha-Suomi (1)
- Kreablo AB (1)
- PTFS-Europe (6)
- Rijks Museum (8)
- Solutions inLibro inc (1)
- Theke Solutions (7)
- UK Parliament (7)
- University of Helsinki (1)
- washk12.org (1)

We also especially thank the following individuals who tested patches
for Koha

- Tomás Cohen Arazi (6)
- Azucena (1)
- Donna Bachowski (1)
- Alex Buckley (7)
- Nick Clemens (7)
- Jonathan Druart (104)
- Esther (1)
- Katrin Fischer (24)
- Andrew Fuerste-Henry (22)
- Lucas Gass (1)
- Victor Grousset (4)
- Kyle M Hall (111)
- kelly (1)
- Joonas Kylmälä (30)
- Owen Leonard (18)
- David Nind (21)
- Hayley Pelham (1)
- Eric Phetteplace (2)
- Séverine Queune (1)
- Martin Renvoize (39)
- Phil Ringnalda (5)
- Marcel de Rooy (9)
- Sally (1)
- Julien Sicot (1)
- Fridolin Somers (3)
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
line is 21.05.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 28 Oct 2021 13:16:37.
