# RELEASE NOTES FOR KOHA 21.11.12
03 Oct 2022

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 21.11.12 can be downloaded from:

- [Download](http://download.koha-community.org/koha-21.11.12.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 21.11.12 is a bugfix/maintenance release.

It includes 10 enhancements, 37 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations




## Enhancements

### Fines and fees

- [[31121]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31121) Format date range on top of cashup summary page

  >This fixes the formatting of dates on the cashup summary modal (it uses the existing $datetime JS include).
- [[31163]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31163) Sort cashup history so that newest entries are first

### Hold requests

- [[30878]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30878) Canceling holds from 'Holds awaiting pickup' should not reset the selected tab

### Lists

- [[29114]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29114) Can not add barcodes with whitespaces at the beginning to the list

  >This fixes an issue where barcodes with white spaces at the beginning could not be added to a list.

### Notices

- [[26689]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26689) Monetary accounts notices should be definable at the credit_type/debit_type level

  >This enhancement allows end users to define their account notices (print receipt and print invoice for example) at the debit type and credit type level.
  >
  >Simply add a new notice with code 'DEBIT_your_debit_type_code' or 'CREDIT_your_credit_type_code' to the notices and we will pick that over the existing default 'ACCOUNT_DEBIT' and 'ACCOUNT_CREDIT' notices.

### OPAC

- [[29922]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29922) Group of libraries are now displayed in alphabetical order

  >This fixes the display of library groups in the advanced search (Groups of libraries) for the OPAC and staff interface so that they correctly sort in alphabetical order. Before this:
  >- OPAC: were sorted in the order library groups were added, group names with diacritics and umlauts (such as Ä or À) came last (after something starting with Z)
  >- Staff interface: were sorted correctly, but had the same issue as the OPAC for group names with diacritics and umlauts

### Patrons

- [[7660]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7660) Enhanced messaging preferences are not set when creating a child patron from the adult
- [[20439]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20439) SMS provider sorting

### Searching

- [[31213]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31213) When performing a basic search with no results, repeat the search with term quoted

  >This enhancement adds a second, automatic, search with the search terms between quotation marks when a search returns no results.
  >
  >For example, searches with special characters don't work with Elasticsearch.
  >A search for Ivy + Bean will return no results. But a search for "Ivy + Bean" will return results.
  >
  >With this enhancement, if a user searches for Ivy + Bean without quotation marks and gets no results, Koha will automatically search for "Ivy + Bean" and return those results.
  >
  >This targets both Zebra and Elasticsearch, but is more relevant for Elasticsearch.

### Searching - Elasticsearch

- [[27667]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27667) Display the number of non-indexed records

  >This enhancement adds information about non-indexed records when using the Elasticsearch search engine on the About Koha > System information page.
  >
  >For example:
  >
  >Records are not indexed in Elasticsearch
  >- Warning 1 record(s) missing on a total of 435 in index koha_kohadev_biblios.record(s).
  >- Warning 1 record(s) missing on a total of 1705 in index koha_kohadev_authorities.


## Critical bugs fixed

### Acquisitions

- [[14680]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14680) When creating orders from a staged file discounts supplied in the form are added

### Cataloging

- [[30909]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30909) Regression, Permanent shelving location is always updated when editing location VIA ADDITEM.PL if both are mapped to MARC fields

### Circulation

- [[29051]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29051) Seen renewal methods incorrectly blocked

### Command-line Utilities

- [[30308]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30308) bulkmarcimport.pl broken by OAI-PMH:AutoUpdateSets(EmbedItemData)

### Staff Client

- [[31138]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31138) DataTables is not raising error to the end user


## Other bugs fixed

### Acquisitions

- [[23202]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23202) Problems when adding multiple items to an order in acquisitions
- [[30268]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30268) When creating an order from a staged file, mandatory item subfields that are empty do not block form submission
- [[30658]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30658) (Bug 29496 follow-up) CheckMandatorySubfields don't  work properly with select field in serials-edit.tt for Supplemental issue
- [[31054]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31054) Manual importing for EDIFACT invoices fails with a 500 error page
- [[31144]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31144) When modifying an order we should not load the vendor default discount

### Architecture, internals, and plumbing

- [[31145]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31145) Add some defaults for acquisitions in TestBuilder

### Cataloging

- [[27683]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27683) Bind results of GetAnalyticsCount to the EasyAnalyticalRecords pref

### Circulation

- [[30447]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30447) pendingreserves.pl is checking too many transfers
- [[31120]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31120) Items will renew for zero ( 0 ) days if renewalperiod is blank/empty value
- [[31129]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31129) Number of restrictions is always "0" on the "Check out" tab

### Fines and fees

- [[30458]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30458) Librarian ( manager_id ) not included in accountline when using "Payout amount" button
- [[31036]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31036) Cash management doesn't take SIP00 (Cash via SIP2) transactions into account

  >This fix adds the last missing piece for cash management when involving transactions via a SIP client.
  >
  >We now understand that a SIP00 coded transaction is equal to 'CASH' in other register environments. This means we treat it as such in the cashup system and also that we now require a register for cash transactions.
  >
  >WARNING: This makes register a required configuration field for SIP devices when cash registers are enabled on the system.

### Hold requests

- [[30935]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30935) Holds to pull shows wrong first patron
- [[31086]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31086) Do not allow hold requests with no branchcode

### Label/patron card printing

- [[31137]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31137) Error editing label template

### MARC Authority data support

- [[29333]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29333) Importing UNIMARC authorities in MARCXML UTF-8 breaks the encoding

### Notices

- [[30838]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30838) to_address is misleading for SMS transports

### OPAC

- [[31186]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31186) Search result numbering in OPAC got suppressed

### REST API

- [[29105]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29105) Add effective_item_type_id to the API items responses

### Reports

- [[21982]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21982) Circulation statistics wizard does not count deleted items

  >This patch corrects a bug in the Circulation statistics wizard. Previously, the wizard only looked at existing items to calculate statistics. It now includes transactions made on items that are now deleted.
- [[27045]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27045) Exports using CSV profiles with tab as separator don't work correctly

### SIP2

- [[31202]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31202) Koha removes optional SIP fields with a value of "0"

### Searching - Elasticsearch

- [[25669]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25669) ElasticSearch 6: [types removal] Specifying types in put mapping requests is deprecated (incompatible with 7)
- [[30882]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30882) Add max_result_window to index config

  >This updates the number of results set by default in Elasticsearch for the setting "index.max-result-window" from  10,000 to 1,000,000. This can be useful for really large catalogs.

### Staff Client

- [[30471]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30471) Typo in circulation rules - lost item fee refund policy
- [[31039]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31039) Rebase issues lead to duplicate JS for cash summary modal printing

  >This fixes a duplicate print dialogue box appearing when printing the cashup summary for cash registers - ins some circumstances when cancelling the print dialogue, it reappeared instead of closing.

### System Administration

- [[31020]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31020) PassItemMarcToXSLT only applies on results pages

  >This fixes the note about the PassItemMarcToXSLT system preference so that it is only shown for the OPACXSLTResultsDisplay and XSLTResultsDisplay system preferences - it was appearing in all XSLT system preferences, when it only applies for results pages. (The note is removed from OPACXSLTListsDisplay, XSLTListsDisplay, OPACXSLTDetailsDisplay, and XSLTDetailsDisplay system preferences.)

### Templates

- [[31141]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31141) We can remove 'select_column' from waiting_holds.inc

### Test Suite

- [[31139]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31139) basic_workflow.t is failing
- [[31201]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31201) Pseudonymization.t failing if selenium/patrons_search.t failed before

### Tools

- [[31204]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31204) Edit dropdown on results.tt should indicate it is record modification
- [[31455]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31455) Batch modification tool orders found items by itemnumber



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

- Arabic (87.1%)
- Armenian (100%)
- Armenian (Classical) (89%)
- Bulgarian (100%)
- Chinese (Taiwan) (79.2%)
- Czech (77%)
- English (New Zealand) (58.9%)
- English (USA)
- Finnish (99.3%)
- French (95.6%)
- French (Canada) (92.5%)
- German (100%)
- German (Switzerland) (58.6%)
- Greek (60.6%)
- Hindi (100%)
- Italian (100%)
- Nederlands-Nederland (Dutch-The Netherlands) (87%)
- Norwegian Bokmål (63%)
- Polish (100%)
- Portuguese (91%)
- Portuguese (Brazil) (83.4%)
- Russian (84.6%)
- Slovak (74.9%)
- Spanish (100%)
- Swedish (81.9%)
- Telugu (94.8%)
- Turkish (99.4%)
- Ukrainian (75.5%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 21.11.12 is


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

We thank the following individuals who contributed patches to Koha 21.11.12

- Tomás Cohen Arazi (3)
- Jérémy Breuillard (1)
- Kevin Carnes (1)
- Nick Clemens (13)
- Frédéric Demians (1)
- Jonathan Druart (6)
- Katrin Fischer (2)
- Lucas Gass (2)
- Kyle M Hall (6)
- Janusz Kaczmarek (1)
- Joonas Kylmälä (1)
- Owen Leonard (1)
- Julian Maurice (2)
- Johanna Raisa (1)
- Martin Renvoize (21)
- Adolfo Rodríguez (1)
- Marcel de Rooy (1)
- Fridolin Somers (6)
- Arthur Suzuki (4)
- Lari Taskula (1)
- Koha translators (1)
- Michal Urban (1)
- Andrii Veremeienko (1)
- Shi Yao Wang (3)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 21.11.12

- Athens County Public Libraries (1)
- BibLibre (13)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (2)
- ByWater-Solutions (21)
- Hypernova Oy (1)
- Independant Individuals (4)
- jabra.com (1)
- Koha Community Developers (6)
- PTFS-Europe (21)
- Rijksmuseum (1)
- Solutions inLibro inc (3)
- Tamil (1)
- Theke Solutions (3)
- ub.lu.se (1)
- Xercode (1)

We also especially thank the following individuals who tested patches
for Koha

- andrew (1)
- Tomás Cohen Arazi (73)
- Caroline (2)
- Nick Clemens (7)
- Jonathan Druart (3)
- Katrin Fischer (21)
- Lucas Gass (73)
- Victor Grousset (4)
- Kyle M Hall (9)
- Sally Healey (11)
- Thibault Kero (1)
- Joonas Kylmälä (5)
- Owen Leonard (2)
- Julian Maurice (2)
- Kelly McElligott (2)
- David Nind (16)
- Martin Renvoize (22)
- Marcel de Rooy (2)
- Arthur Suzuki (76)
- Michal Urban (1)
- <George Williams (1)



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

Autogenerated release notes updated last on 03 Oct 2022 21:04:59.
