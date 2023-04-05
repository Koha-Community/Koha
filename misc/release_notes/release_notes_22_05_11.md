# RELEASE NOTES FOR KOHA 22.05.11
05 Apr 2023

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 22.05.11 can be downloaded from:

- [Download](http://download.koha-community.org/koha-22.05.11.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 22.05.11 is a bugfix/maintenance release.

It includes 1 enhancements, 52 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha [here](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).




## Enhancements

### Test Suite

- [[32375]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32375) 22.05.07 failing t/AuthoritiesMarc_MARC21.t

  **Sponsored by** *Catalyst*


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[32558]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32558) Allow background_jobs_worker.pl to process multiple jobs simultaneously up to a limit
- [[33044]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33044) BackgroundJob enqueue does not return the job id if rabbit is unreachable

### SIP2

- [[33055]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33055) SIP2 adding incorrect fines blocked message


## Other bugs fixed

### Architecture, internals, and plumbing

- [[32460]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32460) Columns missing from table configuration for patron categories
- [[32678]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32678) Add new line in authorized values tests in search_for_data_inconsistencies.pl
- [[32811]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32811) Remove unused indexer.log

### Cataloging

- [[32812]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32812) Fix cataloguing/value_builder/barcode_manual.pl
- [[32813]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32813) Fix cataloguing/value_builder/barcode.pl
- [[32814]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32814) Fix cataloguing/value_builder/callnumber-KU.pl
- [[32815]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32815) Fix cataloguing/value_builder/callnumber.pl
- [[32816]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32816) Fix cataloguing/value_builder/cn_browser.pl
- [[32819]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32819) Fix cataloguing/value_builder/stocknumberam123.pl
- [[32820]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32820) Fix cataloguing/value_builder/stocknumberAV.pl
- [[32821]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32821) Fix cataloguing/value_builder/stocknumber.pl
- [[32822]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32822) Fix cataloguing/value_builder/unimarc_field_010.pl
- [[32823]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32823) Fix cataloguing/value_builder/unimarc_field_100_authorities.pl
- [[32824]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32824) Fix cataloguing/value_builder/unimarc_field_100.pl
- [[32825]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32825) Fix cataloguing/value_builder/unimarc_field_105.pl
- [[32826]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32826) Fix cataloguing/value_builder/unimarc_field_106.pl
- [[32827]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32827) Fix cataloguing/value_builder/unimarc_field_110.pl
- [[32828]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32828) Fix cataloguing/value_builder/unimarc_field_115a.pl
- [[32829]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32829) Fix cataloguing/value_builder/unimarc_field_115b.pl
- [[32835]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32835) Fix cataloguing/value_builder/unimarc_field_122.pl
- [[33173]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33173) Save and continue button in standard cataloging module broken

### Circulation

- [[31209]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31209) Add a span with class around serial enumeration/chronology data in list of checkouts for better styling

### I18N/L10N

- [[30993]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30993) Translation: Unbreak sentence in upload.tt
- [[31957]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31957) Translation: Ability to change the sentence structure on library administration page

### ILL

- [[22693]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22693) ILL "Price paid" column does not appear in column configuration

  >This adds the "Price paid" column to the inter-library loan requests table.  This column is also configurable using the Columns button and in the table settings (Administration > Additional parameters > Table settings > Interlibrary loans > ill-requests).
- [[32525]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32525) Standardize labels between ILL request list and detail page
- [[32566]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32566) Don't show 'ILL request logs' button, when IllLog is turned off

### OPAC

- [[31248]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31248) Fix responsive table style in the OPAC after switch to Bootstrap tabs
- [[32492]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32492) Improve mark-up of OPAC messaging table to ease customization
- [[32663]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32663) Street number should not allow for entering more than 10 characters in OPAC
- [[32679]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32679) CSS class article-request-title is doubled up in article requests list in staff patron account
- [[32999]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32999) Click handler to show QR code in OPAC lacks preventDefault

### Patrons

- [[32675]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32675) Cannot add a guarantor when there is a single quote in the guarantor attributes
- [[32770]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32770) Patron search field groups no longer exist
- [[33155]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33155) Category and library filters from header patron search not taken into account

### Plugin architecture

- [[33189]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33189) Plugin upload should prompt for .kpz files

### Searching

- [[32639]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32639) OpenSearch description format document generates search errors

### Searching - Elasticsearch

- [[31471]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31471) Duplicate check in cataloguing fails with Elasticsearch for records with multiple ISBN

### Staff interface

- [[32909]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32909) Item type icons broken when placing an item-level hold
- [[32982]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32982) 'Add/Edit group' modals in library groups is missing it's primary button
- [[33032]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33032) Alternate holdings broken in staff interface search results

### Templates

- [[31413]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31413) Set focus for cursor to Selector when adding a new audio alert
- [[32205]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32205) Unnecessary sysprefs used in template params for masthead during failed OPAC auth
- [[32307]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32307) Chocolat image viewer broken in the staff interface when Coce is enabled
- [[32926]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32926) Cannot expand or collapse some System preference sections after a search
- [[32933]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32933) Use val() instead of attr("value") when getting field values with jQuery
- [[33048]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33048) Empty email link on error page when opac login not allowed

### Test Suite

- [[32979]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32979) Add Test::Exception to Logger.t

### Tools

- [[32685]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32685) Display incorrect when matching authority records during import



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/22.05/ar/html/) (28.2%)
- [Chinese (Taiwan)](https://koha-community.org/manual/22.05/zh_TW/html/) (84.6%)
- [English (USA)](https://koha-community.org/manual/22.05/en/html/)
- [French](https://koha-community.org/manual/22.05/fr/html/) (63.7%)
- [German](https://koha-community.org/manual/22.05/de/html/) (67.2%)
- [Hindi](https://koha-community.org/manual/22.05/hi/html/) (100%)
- [Italian](https://koha-community.org/manual/22.05/it/html/) (41.2%)
- [Spanish](https://koha-community.org/manual/22.05/es/html/) (29.8%)
- [Turkish](https://koha-community.org/manual/22.05/tr/html/) (33.5%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (77.8%)
- Armenian (100%)
- Armenian (Classical) (71.6%)
- Bulgarian (85.4%)
- Chinese (Taiwan) (95%)
- Czech (62.3%)
- English (New Zealand) (68.5%)
- English (USA)
- Finnish (94.7%)
- French (100%)
- French (Canada) (99.7%)
- German (100%)
- German (Switzerland) (54.1%)
- Greek (55.5%)
- Hindi (100%)
- Italian (100%)
- Nederlands-Nederland (Dutch-The Netherlands) (85.3%)
- Norwegian Bokmål (55.9%)
- Persian (58.7%)
- Polish (99.8%)
- Portuguese (87.3%)
- Portuguese (Brazil) (77%)
- Russian (78.3%)
- Slovak (63.8%)
- Spanish (99.8%)
- Swedish (78.4%)
- Telugu (84.5%)
- Turkish (93.3%)
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

The release team for Koha 22.05.11 is


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
  - 22.11 -- PTFS Europe (Martin Renvoize, Matt Blenkinsop, Jacob O'Mara, Pedro Amorim)
  - 22.05 -- Lucas Gass
  - 21.11 -- Arthur Suzuki
  - 21.05 -- Wainui Witika-Park

## Credits
We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 22.05.11

- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)

We thank the following individuals who contributed patches to Koha 22.05.11

- Tomás Cohen Arazi (2)
- Nick Clemens (8)
- David Cook (5)
- Jonathan Druart (7)
- Katrin Fischer (9)
- Lucas Gass (3)
- Kyle M Hall (2)
- Owen Leonard (4)
- Julian Maurice (17)
- Jacob O'Mara (1)
- Martin Renvoize (1)
- Marcel de Rooy (4)
- Andreas Roussos (3)
- Danyon Sewell (1)
- Fridolin Somers (2)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 22.05.11

- Athens County Public Libraries (4)
- BibLibre (19)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (9)
- ByWater-Solutions (13)
- Catalyst (1)
- Dataly Tech (3)
- Koha Community Developers (7)
- Prosentient Systems (5)
- PTFS-Europe (2)
- Rijksmuseum (4)
- Theke Solutions (2)

We also especially thank the following individuals who tested patches
for Koha

- Pedro Amorim (7)
- Tomás Cohen Arazi (63)
- Matt Blenkinsop (37)
- Christopher Brannon (1)
- Alex Buckley (1)
- Nick Clemens (17)
- Jonathan Druart (14)
- emlam (1)
- Laura Escamilla (2)
- Katrin Fischer (6)
- Andrew Fuerste-Henry (1)
- Lucas Gass (71)
- Victor Grousset (1)
- Kyle M Hall (11)
- Sally Healey (2)
- Owen Leonard (8)
- Solene Ngamga (2)
- David Nind (22)
- Jacob O'Mara (9)
- Martin Renvoize (15)
- Marcel de Rooy (6)
- Caroline Cyr La Rose (3)
- Michaela Sieber (1)
- Fridolin Somers (3)



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

Autogenerated release notes updated last on 05 Apr 2023 21:11:33.
