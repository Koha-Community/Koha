# RELEASE NOTES FOR KOHA 22.05.05
26 Sep 2022

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 22.05.05 can be downloaded from:

- [Download](http://download.koha-community.org/koha-22.05.05.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 22.05.05 is a bugfix/maintenance release.

It includes 15 enhancements, 48 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations




## Enhancements

### Circulation

- [[30905]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30905) Show waiting recalls in patron account on checkouts tab

  **Sponsored by** *Catalyst*

  >This enhancement shows recalls ready for pick-up on the patron's account so they can't be missed.

### Fines and fees

- [[31121]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31121) Format date range on top of cashup summary page

  >This fixes the formatting of dates on the cashup summary modal (it uses the existing $datetime JS include).
- [[31163]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31163) Sort cashup history so that newest entries are first

### Hold requests

- [[30878]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30878) Canceling holds from 'Holds awaiting pickup' should not reset the selected tab

### I18N/L10N

- [[31068]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31068) Context for translation: Print (verb) vs. Print (noun)

  >This enhancement adds context for translation purposes to the term 'Print' for notices and slips message transport types (email, print, SMS). (In English, the word "print" is the same whether it is a verb (to print something) or a noun (a print of something), however, for other languages different words may be used. When the word is in a sentence, it's not too difficult to translate, but in cases where the string to translate is simply "Print", it is often used in different cases (noun or verb). For example: in French there are two different spellings, "Imprimer" or "Imprimé".)

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

### Serials

- [[26377]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26377) Clearly label parts of subscription-add.pl that relate to optional item records
- [[30039]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30039) Add publication date column to serial claims table

### Templates

- [[30570]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30570) Replace the use of jQueryUI tabs in OPAC templates


## Critical bugs fixed

### Acquisitions

- [[14680]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14680) When creating orders from a staged file discounts supplied in the form are added
- [[31134]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31134) t/Ediorder.t tests failing on 22.05.02

### Cataloging

- [[30909]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30909) Regression, Permanent shelving location is always updated when editing location VIA ADDITEM.PL if both are mapped to MARC fields
- [[31223]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31223) Batch edit items explodes if plugins disabled

### Circulation

- [[29051]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29051) Seen renewal methods incorrectly blocked

### Command-line Utilities

- [[30308]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30308) bulkmarcimport.pl broken by OAI-PMH:AutoUpdateSets(EmbedItemData)

### MARC Bibliographic data support

- [[29001]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29001) Subfields attributes are not preserved when order is changed in framework

### Packaging

- [[31499]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31499) Add libhttp-tiny-perl 0.076 dependency for ES7

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

- [[31069]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31069) Did you mean? in the OPAC - links have <span> tags

  >This removes <span> tags incorrectly displayed around the links for options available when 'Did you mean?' is enabled (for example, 'Search also for related subjects').
- [[31146]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31146) Minor UI problem in recalls history in OPAC
- [[31186]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31186) Search result numbering in OPAC got suppressed

### Patrons

- [[31153]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31153) Search bar not visible on recalls history page

### REST API

- [[29105]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29105) Add effective_item_type_id to the API items responses

### Reports

- [[21982]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21982) Circulation statistics wizard does not count deleted items

  >This patch corrects a bug in the Circulation statistics wizard. Previously, the wizard only looked at existing items to calculate statistics. It now includes transactions made on items that are now deleted.
- [[27045]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27045) Exports using CSV profiles with tab as separator don't work correctly

### SIP2

- [[29094]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29094) Placing holds via SIP2 does not check if a patron can hold the given item

  >This fixes holds placed using SIP2 to check that the patron can actually place a hold for the item.
- [[31202]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31202) Koha removes optional SIP fields with a value of "0"

### Searching

- [[15187]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15187) Adding 880 Fields to index-list in order to Increase Search for ALL non-latin Scripts

  >This fixes the Zebra search engine when using ICU* so that 880 fields are rewritten as their linked fields and the alternate graphic representation of fields are indexed, in the same way that it works for Elasticsearch. 
  >
  >Example: add 245-01 to 880$6 and 教牧書信 to 880$a - the Chinese characters are now indexed into the title index using the 245 rules.
  >
  >* ICU is a feature of the Zebra search engine that can be configured to make searching with non-latin languages (such as Chinese and Arabic) work correctly.

### Searching - Elasticsearch

- [[29632]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29632) Callnumber sorting is incorrect in Elasticsearch

  >This fixes the sorting of call numbers when using Elasticsearch. Sorting will now work correctly for non-numeric call numbers, for example, E45 will now sort before E7.
- [[30882]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30882) Add max_result_window to index config

  >This updates the number of results set by default in Elasticsearch for the setting "index.max-result-window" from  10,000 to 1,000,000. This can be useful for really large catalogs.

### Staff Client

- [[30471]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30471) Typo in circulation rules - lost item fee refund policy
- [[31039]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31039) Rebase issues lead to duplicate JS for cash summary modal printing

  >This fixes a duplicate print dialogue box appearing when printing the cashup summary for cash registers - ins some circumstances when cancelling the print dialogue, it reappeared instead of closing.
- [[31244]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31244) Logout when not logged in raise a 500

### System Administration

- [[31020]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31020) PassItemMarcToXSLT only applies on results pages

  >This fixes the note about the PassItemMarcToXSLT system preference so that it is only shown for the OPACXSLTResultsDisplay and XSLTResultsDisplay system preferences - it was appearing in all XSLT system preferences, when it only applies for results pages. (The note is removed from OPACXSLTListsDisplay, XSLTListsDisplay, OPACXSLTDetailsDisplay, and XSLTDetailsDisplay system preferences.)

### Templates

- [[31141]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31141) We can remove 'select_column' from waiting_holds.inc
- [[31246]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31246) <span> displayed in 'Additional fields' section

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


- [Arabic](https://koha-community.org/manual/22.05/ar/html/) (28.2%)
- [Chinese (Taiwan)](https://koha-community.org/manual/22.05/zh_TW/html/) (49.2%)
- [English (USA)](https://koha-community.org/manual/22.05/en/html/)
- [French](https://koha-community.org/manual/22.05/fr/html/) (58.3%)
- [German](https://koha-community.org/manual/22.05/de/html/) (61.3%)
- [Hindi](https://koha-community.org/manual/22.05/hi/html/) (83.6%)
- [Italian](https://koha-community.org/manual/22.05/it/html/) (40.8%)
- [Spanish](https://koha-community.org/manual/22.05/es/html/) (29.6%)
- [Turkish](https://koha-community.org/manual/22.05/tr/html/) (33.5%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (78.4%)
- Armenian (100%)
- Armenian (Classical) (71.6%)
- Bulgarian (85%)
- Chinese (Taiwan) (84%)
- Czech (62.3%)
- English (New Zealand) (56.4%)
- English (USA)
- Finnish (95.4%)
- French (97.1%)
- French (Canada) (99.5%)
- German (100%)
- German (Switzerland) (54.4%)
- Greek (53.2%)
- Hindi (100%)
- Italian (96.7%)
- Nederlands-Nederland (Dutch-The Netherlands) (82.8%)
- Norwegian Bokmål (56.3%)
- Persian (51.5%)
- Polish (87.6%)
- Portuguese (79.7%)
- Portuguese (Brazil) (77.2%)
- Russian (78%)
- Slovak (64.1%)
- Spanish (98.2%)
- Swedish (77.2%)
- Telugu (85.1%)
- Turkish (92.4%)
- Ukrainian (70%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 22.05.05 is


- Release Manager: Tomás Cohen Arazi

- Release Manager assistants:
  - Jonathan Druart
  - Martin Renvoize

- QA Manager: Katrin Fischer

- QA Team:
  - Aleisha Amohia
  - Nick Clemens
  - Jonathan Druart
  - Lucas Gass
  - Victor Grousset
  - Kyle M Hall
  - Joonas Kylmälä
  - Andrew Nugged
  - Martin Renvoize
  - Marcel de Rooy
  - Fridolin Somers
  - Petro Vashchuk

- Topic Experts:
  - UI Design -- Owen Leonard
  - Zebra -- Fridolin Somers

- Bug Wranglers:
  - Aleisha Amohia
  - Jake Deery
  - Lucas Gass
  - Séverine Queune

- Packaging Manager: 


- Documentation Manager: David Nind


- Documentation Team:
  - Donna Bachowski
  - Aude Charillon
  - Martin Renvoize
  - Lucy Vaux-Harvey

- Translation Managers: 
  - Bernardo González Kriegel

- Wiki curators: 
  - Thomas Dukleth
  - Katrin Fischer

- Release Maintainers:
  - 22.05 -- Lucas Gass
  - 21.11 -- Arthur Suzuki
  - 21.05 -- Victor Grousset

## Credits
We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 22.05.05

- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)

We thank the following individuals who contributed patches to Koha 22.05.05

- Aleisha Amohia (1)
- Tomás Cohen Arazi (10)
- Jérémy Breuillard (1)
- Nick Clemens (15)
- David Cook (1)
- Frédéric Demians (1)
- Jonathan Druart (11)
- Katrin Fischer (3)
- Lucas Gass (12)
- Victor Grousset (1)
- Kyle M Hall (7)
- Mason James (1)
- Janusz Kaczmarek (1)
- Joonas Kylmälä (2)
- Owen Leonard (3)
- Julian Maurice (2)
- Johanna Raisa (1)
- Martin Renvoize (23)
- Adolfo Rodríguez (1)
- Marcel de Rooy (1)
- Caroline Cyr La Rose (1)
- Fridolin Somers (6)
- Lari Taskula (1)
- Koha translators (1)
- Michal Urban (1)
- Andrii Veremeienko (1)
- Shi Yao Wang (3)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 22.05.05

- Athens County Public Libraries (3)
- BibLibre (9)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (3)
- ByWater-Solutions (34)
- Catalyst Open Source Academy (1)
- Hypernova Oy (1)
- Independant Individuals (5)
- jabra.com (1)
- Koha Community Developers (12)
- KohaAloha (1)
- Prosentient Systems (1)
- PTFS-Europe (23)
- Rijksmuseum (1)
- Solutions inLibro inc (4)
- Tamil (1)
- Theke Solutions (10)
- Xercode (1)

We also especially thank the following individuals who tested patches
for Koha

- andrew (1)
- Tomás Cohen Arazi (94)
- Emmanuel Bétemps (1)
- Caroline (2)
- Nick Clemens (7)
- Jonathan Druart (6)
- Katrin Fischer (24)
- Lucas Gass (96)
- Victor Grousset (6)
- Kyle M Hall (12)
- Sally Healey (12)
- Mark Hofstetter (1)
- Thibault Kero (2)
- Joonas Kylmälä (9)
- Owen Leonard (7)
- Kelly McElligott (2)
- David Nind (23)
- Martin Renvoize (29)
- Marcel de Rooy (2)
- Caroline Cyr La Rose (2)
- Michal Urban (2)
- <George Williams (1)



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

Autogenerated release notes updated last on 26 Sep 2022 14:32:01.
