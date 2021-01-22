# RELEASE NOTES FOR KOHA 20.11.02
22 janv. 2021

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 20.11.02 can be downloaded from:

- [Download](http://download.koha-community.org/koha-20.11.02.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 20.11.02 is a bugfix/maintenance release.

It includes 10 enhancements, 49 bugfixes.

### System requirements

Koha is continuously tested against the following configurations and as such these are the recommendations for 
deployment:

Operating system:

- Debian 10
- Debian 9
- Ubuntu 20.04
- Ubuntu 18.04
- Ubuntu 16.04
- Ubuntu 20.10 (experimental)
- Debian 11 (experimental)

Database:

- MariaDB 10.3
- MariaDB 10.1

Search engine:

- ElasticSearch 6
- Zebra

Perl:

- Perl >= 5.14 is required and 5.24, 5.26, 5.28 or 5.30 are recommended. These are the versions of the recommended operating systems.




## Enhancements

### Architecture, internals, and plumbing

- [[24254]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24254) Add Koha::Items->filter_by_visible_in_opac

  >This patch introduces an efficient way of filtering Koha::Items result sets, to hide items that that shouldn't be exposed on public interfaces.
  >
  >Filtering is governed by the following system preferences. A helper method is added to handle lost items:
  >- hidelostitems: Koha::Items->filter_out_lost is added to handle this.
  >
  >Some patrons have exceptions so OpacHiddenItems is not enforced on them. That's why the new method [1] has an optional parameter that expects the logged in patron to be passed in the call.
  >
  >[1] Koha::Items->filter_by_visible_in_opac

### Circulation

- [[27306]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27306) Add subtitle to return claims table

### Command-line Utilities

- [[24541]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24541) Database cleanups, purge messages

### Label/patron card printing

- [[26875]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26875) Allow printing of just one barcode
- [[26962]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26962) Koha notice/slips/receipts should print in true black (#000000)

  >Almost black color in CSS rules (like #000066) are now replaced by true black color #000000

### OPAC

- [[26847]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26847) Make borrower category code accessible in all pages of the OPAC

### Reports

- [[26713]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26713) Add pagination to bottom of saved SQL reports table

  >This enhancement adds a second pagination menu to the bottom of saved SQL reports tables.

### Searching - Elasticsearch

- [[24863]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24863) QueryFuzzy syspref says it requires Zebra but Elasticsearch has some support
- [[25054]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25054) Display search field aliases in search engine configuration

  >This adds a new column aliases to the search fields tabs of the search engine configuration table. The aliases table shows the abbreviated and alternative index names available for each defined index.

### Staff Client

- [[25462]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25462) Shelving location should be on a new line in holdings table

  >In the holdings table, the shelving location is now displayed on a new line after the 'Home library'.


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[27252]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27252) ES5 no longer supported (since 20.11.00)

  >This prepares Koha to officially no longer support Elasticsearch 5.X.
  >
  >It adds a new system preference 'ElasticsearchCrossFields' to allow users to choose whether or not to enable this feature.

### Command-line Utilities

- [[27245]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27245) bulkmarcimport.pl error 'Already in a transaction'

### OPAC

- [[15448]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15448) Placing hold on specific items doesn't enforce OpacHiddenItems

### Patrons

- [[27420]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27420) A mistake in bug 5161 leads to some patron attributes appearing without a fieldset


## Other bugs fixed

### Acquisitions

- [[24470]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24470) Set import_status when file used to populate basket in acquisitions

### Architecture, internals, and plumbing

- [[25292]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25292) L1 cache too long in Z3950 server (z3950-responder)
- [[26848]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26848) Fix Readonly dependency in cpanfile
- [[27345]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27345) C4::Auth::get_template_and_user is missing some permissions for superlibrarian

### Cataloging

- [[20971]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20971) Corrupted storable string breaks SubfieldsToUseWhenPrefill functionality
- [[27130]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27130) Adding local cover image at item level shows 'File type' section
- [[27135]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27135) Viewing local cover images at item level shows a link to upload image at record level
- [[27164]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27164) Fix item search CSV export
- [[27308]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27308) Advanced editor should skip blank lines when inserting new fields

### Circulation

- [[26953]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26953) Phone & SMS transports always displayed in overdue status triggers

### Command-line Utilities

- [[17429]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17429) Document the --plack option for koha-list
- [[26851]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26851) Overdue notices should not send a report to the library if there is no content
- [[27085]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27085) Corrections in overdue_notices.pl help text

  **Sponsored by** *Lund University Library*

### Fines and fees

- [[26593]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26593) Rental discounts are applied in wrong precedence order
- [[27180]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27180) Fines cronjob does not update fines on holidays when finesCalendar is set to ignore

### Hold requests

- [[26367]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26367) Warn in HoldsQueue if request itemtype set but request is not item specific

### MARC Bibliographic record staging/import

- [[26171]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26171) Show biblionumber in Koha::Exceptions::Metadata::Invalid

### OPAC

- [[27047]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27047) Purchase suggestions search filter is broken
- [[27090]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27090) In the location column of an OPAC cart the 'In transit from' and 'to' fields are empty
- [[27168]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27168) Most popular doesn't always sort correctly
- [[27178]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27178) OPAC results and lists pages contain invalid attributes (xmlns:str="http://exslt.org/strings")
- [[27297]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27297) When itemtype is marked as required in OpacSuggestion MandatoryFields the field is not required

### Patrons

- [[26417]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26417) Remove warn in Koha::Patron is_valid_age
- [[26797]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26797) Error when trying to access Relative Checkouts between Professional and Organizational patron categories

### Searching

- [[26957]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26957) Find duplicate removes operators from the middle of search terms

### Searching - Elasticsearch

- [[26996]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26996) Elasticsearch: Multiprocess reindexing sometimes doesn't reindex all records

  **Sponsored by** *Lund University Library*
- [[27043]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27043) Add to number_of_replicas and number_of_shards  to index config

  >Elasticsearch 6 server has default value 5 for "number_of_shards" but warn about Elasticsearch 7 having default value 1.
  >So its is better to set this value in configuration file.
  >Patch also sets number_of_replicas to 1.
  >If you have only one Elasticsearch node, you have to set this value to 0.
- [[27307]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27307) "Keyword as phrase" option in search dropdown doesn't work with Elastic

### Searching - Zebra

- [[27299]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27299) Zebra phrase register is incorrectly tokenized when using ICU

  >Previously, Zebra indexing in ICU mode was incorrectly tokenizing text for the "p" register. This meant that particular phrase searches were not working as expected. With this change, phrase searching works the same in ICU and CHR modes.

### Staff Client

- [[27336]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27336) JS error in Administration - System preferences page

### System Administration

- [[27280]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27280) Explanation for "Days mode" is not consistent
- [[27310]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27310) Wrong CSS float on 'Visibility' in framework edition

  >This fixes the display of the 'Visibility' label when editing subfields for a framework. The label is now aligned correctly with the other labels.
- [[27349]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27349) Mana system preference wrong type YesNo
- [[27351]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27351) UsageStatsCountry system preference wrong type YesNo

### Task Scheduler

- [[27109]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27109) Better labels for background job details

### Templates

- [[25954]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25954) Header search forms should be labeled
- [[27031]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27031) Koha.Preference() should be used more often in header.inc and js_includes.inc
- [[27292]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27292) TablesSettings.GetColumns() returning nothing creates unexpected Javascript on request.tt
- [[27356]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27356) Don't hide the SMTP servers table when last displayed is deleted

### Test Suite

- [[26364]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26364) XISBN.t makes a bad assumption about return values

### Tools

- [[26894]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26894) Marc Modification Templates treat subfield 0 as no subfield set when moving fields
- [[26983]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26983) Selecting ALL Items in Inventory- only selects 20
- [[27413]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27413) Cannot add debarment with batch patron modification tool

### Web services

- [[21301]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21301) Restriction of the informations given by GetRecords ILS-DI service

  >For privacy protection, ILS-DI webservice GetRecords will not give patron information anymore. Also old issues are not given anymore.
  >This removes method C4::Circulation::GetBiblioIssues().

### Z39.50 / SRU / OpenSearch Servers

- [[27149]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27149) Z3950Responder removes itemnumber when adding item statuses
## New sysprefs

- ElasticsearchCrossFields

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

- Arabic (90.2%)
- Armenian (100%)
- Armenian (Classical) (89%)
- Chinese (Taiwan) (86.2%)
- Czech (73.4%)
- English (New Zealand) (59.9%)
- English (USA)
- Finnish (78.6%)
- French (73.9%)
- French (Canada) (91.7%)
- German (100%)
- German (Switzerland) (67.3%)
- Greek (60.8%)
- Hindi (95.6%)
- Italian (100%)
- Norwegian Bokmål (63.8%)
- Polish (71.2%)
- Portuguese (77.7%)
- Portuguese (Brazil) (89.2%)
- Russian (50.8%)
- Slovak (81.1%)
- Spanish (94.6%)
- Swedish (75%)
- Telugu (80.1%)
- Turkish (88.3%)
- Ukrainian (63%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 20.11.02 is


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
We thank the following libraries who are known to have sponsored
new features in Koha 20.11.02:

- Lund University Library

We thank the following individuals who contributed patches to Koha 20.11.02.

- Tomás Cohen Arazi (8)
- Nick Clemens (24)
- David Cook (3)
- Christophe Croullebois (1)
- Jonathan Druart (27)
- Katrin Fischer (2)
- Andrew Fuerste-Henry (1)
- Lucas Gass (3)
- Didier Gautheron (1)
- Victor Grousset (3)
- Pasi Kallinen (1)
- Owen Leonard (5)
- Julian Maurice (2)
- Josef Moravec (1)
- Björn Nylén (1)
- Martin Renvoize (5)
- David Roberts (1)
- Marcel de Rooy (1)
- Andreas Roussos (1)
- Lisette Scheer (1)
- Fridolin Somers (14)
- Koha Translators (1)
- Timothy Alexis Vass (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 20.11.02

- Athens County Public Libraries (5)
- BibLibre (18)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (2)
- ByWater-Solutions (28)
- Dataly Tech (1)
- Independant Individuals (1)
- Koha Community Developers (30)
- Latah County Library District (1)
- Prosentient Systems (3)
- PTFS-Europe (6)
- Rijks Museum (1)
- The City of Joensuu (1)
- Theke Solutions (8)
- ub.lu.se (2)

We also especially thank the following individuals who tested patches
for Koha.

- Tomás Cohen Arazi (1)
- Nick Clemens (26)
- David Cook (2)
- Jonathan Druart (81)
- Katrin Fischer (23)
- Andrew Fuerste-Henry (4)
- Lucas Gass (6)
- Victor Grousset (18)
- Kyle M Hall (9)
- Mason James (1)
- Barbara Johnson (3)
- Mazen Khallaf (1)
- Joonas Kylmälä (2)
- Owen Leonard (4)
- Julian Maurice (3)
- Kelly McElligott (2)
- Josef Moravec (2)
- David Nind (17)
- James O'Keeffe (1)
- Séverine Queune (2)
- Martin Renvoize (29)
- Caroline Cyr La Rose (1)
- Fridolin Somers (105)



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

Autogenerated release notes updated last on 22 janv. 2021 14:08:52.
