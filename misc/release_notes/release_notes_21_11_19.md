# RELEASE NOTES FOR KOHA 21.11.19
03 Apr 2023

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 21.11.19 can be downloaded from:

- [Download](http://download.koha-community.org/koha-21.11.19.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 21.11.19 is a bugfix/maintenance release.

It includes 1 enhancements, 45 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations




## Enhancements

### Test Suite

- [[32375]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32375) 22.05.07 failing t/AuthoritiesMarc_MARC21.t

  **Sponsored by** *Catalyst*


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[33044]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33044) BackgroundJob enqueue does not return the job id if rabbit is unreachable

### SIP2

- [[33055]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33055) SIP2 adding incorrect fines blocked message


## Other bugs fixed

### Architecture, internals, and plumbing

- [[32678]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32678) Add new line in authorized values tests in search_for_data_inconsistencies.pl
- [[32811]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32811) Remove unused indexer.log

### Cataloging

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

- [[32492]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32492) Improve mark-up of OPAC messaging table to ease customization
- [[32663]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32663) Street number should not allow for entering more than 10 characters in OPAC
- [[32679]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32679) CSS class article-request-title is doubled up in article requests list in staff patron account
- [[32999]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32999) Click handler to show QR code in OPAC lacks preventDefault

### Patrons

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



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/21.11/ar/html/) (33.8%)
- [Chinese (Taiwan)](https://koha-community.org/manual/21.11/zh_TW/html/) (58.8%)
- [Czech](https://koha-community.org/manual/21.11/cs/html/) (27.2%)
- [English (USA)](https://koha-community.org/manual/21.11/en/html/)
- [French](https://koha-community.org/manual/21.11/fr/html/) (70.3%)
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

- Arabic (86.4%)
- Armenian (100%)
- Armenian (Classical) (89%)
- Bulgarian (99.8%)
- Chinese (Taiwan) (78.6%)
- Czech (76.8%)
- English (New Zealand) (60.1%)
- English (USA)
- Finnish (98.8%)
- French (100%)
- French (Canada) (91.9%)
- German (100%)
- German (Switzerland) (58.1%)
- Greek (61.1%)
- Hindi (100%)
- Italian (100%)
- Nederlands-Nederland (Dutch-The Netherlands) (86.3%)
- Norwegian Bokmål (62.5%)
- Polish (99.8%)
- Portuguese (91.1%)
- Portuguese (Brazil) (83.4%)
- Russian (84%)
- Slovak (74.6%)
- Spanish (100%)
- Swedish (81.4%)
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

The release team for Koha 21.11.19 is


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
new features in Koha 21.11.19

- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)

We thank the following individuals who contributed patches to Koha 21.11.19

- Tomás Cohen Arazi (2)
- Nick Clemens (6)
- David Cook (5)
- Jonathan Druart (6)
- Katrin Fischer (8)
- Kyle M Hall (1)
- Owen Leonard (4)
- Julian Maurice (16)
- Jacob O'Mara (1)
- Martin Renvoize (1)
- Marcel de Rooy (2)
- Andreas Roussos (3)
- Danyon Sewell (1)
- Fridolin Somers (2)
- Arthur Suzuki (2)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 21.11.19

- Athens County Public Libraries (4)
- BibLibre (20)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (8)
- ByWater-Solutions (7)
- Catalyst (1)
- Dataly Tech (3)
- Koha Community Developers (6)
- Prosentient Systems (5)
- PTFS-Europe (2)
- Rijksmuseum (2)
- Theke Solutions (2)

We also especially thank the following individuals who tested patches
for Koha

- Pedro Amorim (7)
- Tomás Cohen Arazi (54)
- Matt Blenkinsop (31)
- Alex Buckley (1)
- Nick Clemens (16)
- Jonathan Druart (10)
- Laura Escamilla (1)
- Katrin Fischer (6)
- Lucas Gass (62)
- Victor Grousset (1)
- Kyle M Hall (10)
- Sally Healey (2)
- Owen Leonard (7)
- Solene Ngamga (2)
- David Nind (21)
- Jacob O'Mara (6)
- Martin Renvoize (13)
- Marcel de Rooy (4)
- Caroline Cyr La Rose (3)
- Michaela Sieber (1)
- Fridolin Somers (3)
- Arthur Suzuki (58)



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

Autogenerated release notes updated last on 03 Apr 2023 11:50:40.
