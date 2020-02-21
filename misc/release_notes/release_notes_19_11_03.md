# RELEASE NOTES FOR KOHA 19.11.03
21 Feb 2020

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 19.11.03 can be downloaded from:

- [Download](http://download.koha-community.org/koha-19.11.03.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 19.11.03 is a bugfix/maintenance release.

It includes 7 enhancements, 78 bugfixes.

### System requirements

Koha is continiously tested against the following configurations and as such these are the recommendations for 
deployment: 

- Debian Jessie with MySQL 5.5
- Debian Stretch with MariaDB 10.1 (MySQL 8.0 support is experimental)
- Ubuntu Bionic with MariaDB 10.1 (MariaDB 10.3 support is experimental) 

Additional notes:
    
- Perl 5.10 is required
- Zebra or Elasticsearch is required




## Enhancements

### Architecture, internals, and plumbing

- [[19809]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19809) Koha::Objects::find calls do not need to be forbidden in list context

### Cataloging

- [[24452]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24452) Advanced editor - show multiple spaces visually

### Course reserves

- [[23784]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23784) Show subtitle, number and parts in course reserves list of items in OPAC

### I18N/L10N

- [[23790]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23790) fr-CA translation of ACCOUNT_DEBIT and ACCOUNT_CREDIT notices

### Searching - Elasticsearch

- [[22831]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22831) Elasticsearch - add a maintenance script for checking DB vs index counts

### Templates

- [[23944]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23944) Phase out use of jquery.cookie.js in favor of js.cookie.js
- [[23947]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23947) Phase out jquery.cookie.js: Authority merge


## Critical bugs fixed

### Acquisitions

- [[17667]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17667) Standing orders - cancelling a receipt increase the original quantity
- [[22868]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22868) Circulation staff with suggestions_manage can have access to acquisition data

### Circulation

- [[24441]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24441) Error when checking in an item with BranchTansferLimitsType set to itemtype
- [[24542]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24542) Checkout page - Can't locate object method "search" via package "Koha::Account::DebitTypes"

### Database

- [[24377]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24377) Record branch in statistics for auto-renewal

### Fines and fees

- [[23443]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23443) Paying off a lost fee will return the item, even if it is checked out to a different patron
- [[24146]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24146) Paying Accruing Fines prior to return causes another accruing fine when returned
- [[24338]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24338) CASH is missing from the default payment_types

  >This fix adds CASH as an authorized value for PAYMENT_TYPES. This is required for the new cash register feature.

### Hold requests

- [[20567]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20567) "Holds per record (count)" limit is not enforced after item is captured for hold
- [[24485]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24485) AllowHoldPolicyOverride should allow Staff to override the Holds Per Record Rule

### MARC Authority data support

- [[24421]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24421) Generated authorities are missing subfields

### MARC Bibliographic record staging/import

- [[24348]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24348) Record matching rules: required match checks does not work

### Patrons

- [[14759]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14759) Replacement for Text::Unaccent

### Searching - Elasticsearch

- [[23676]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23676) Elasticsearch - 0 is not a valid boolean for suppress
- [[24123]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24123) bulkmarcimport.pl doesn't support UTF-8 encoded MARCXML records
- [[24286]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24286) FindDuplicateAuthority does not escape forward slash in 'GENRE/FORM'


## Other bugs fixed

### Acquisitions

- [[9993]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9993) On editing basket group delivery place resets to logged in library
- [[24404]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24404) Add missing space on invoices page

### Architecture, internals, and plumbing

- [[22220]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22220) Error in ReWriteRule for 'bib' in apache-shared-intranet.conf
- [[23407]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23407) XSLT Details pages don't use items, we shouldn't pass them
- [[23896]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23896) logaction should pass the correct interface to Koha::Logger
- [[23974]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23974) hours_between and days_between lack tests
- [[24213]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24213) Koha::Object->get_from_storage should return undef if the object has been deleted
- [[24313]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24313) XSLT errors should show in the logs

### Cataloging

- [[9156]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9156) System preference itemcallnumber not pulling more than 2 subfields
- [[16683]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16683) Help links to fields 59X in cataloguing form are broken

  >This fix updates the help links for 09x, 59x, and 69x fields in the basic and advanced MARC21 editor. The links now go to the correct Library of Congress documentation pages.
- [[23844]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23844) Noisy warns in addbiblio.pl when importing from Z3950
- [[24236]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24236) Using quotes in a cataloging search, resulting in multiple pages, will not allow you to advance page
- [[24305]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24305) Batch Item modification via item number in reports does not work with CONCAT in report
- [[24323]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24323) Advanced editor - Invalid 008 with helper silently fails to save
- [[24420]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24420) Cataloging search results Location column should account for waiting on hold items
- [[24423]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24423) Broken link to return to record after batch item modification or deletion
- [[24503]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24503) Missing use in value builder barcode_manual.pl

### Circulation

- [[24171]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24171) Cannot do automatic renewal with itemBarcodeFallbackSearch
- [[24214]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24214) Due date displayed in ISO format (when sticky)

### Command-line Utilities

- [[24105]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24105) Longoverdue gives error message when --itemtypes are specified
- [[24397]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24397) populate_db.pl is out of sync and must be removed
- [[24511]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24511) Patron emailer report not using specified email column

### Database

- [[24289]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24289) Deleting branch will not delete entry in special or repeatable holidays

### Hold requests

- [[20708]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20708) Withdrawn status should show when placing a request in staff client
- [[21296]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21296) Suspend hold ignores system preference on intranet
- [[23934]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23934) Item level holds not checked for LocalHoldsPriority in Holds Queue

### OPAC

- [[17697]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17697) Improve NotesBlacklist system preference description to make clear where it will apply
- [[22302]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22302) ITEMTYPECAT description doesn't fall back to description if OPAC description is empty
- [[24061]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24061) Print List (opac-shelves.pl) broken in Chrome
- [[24206]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24206) Change URLs for default options in OPACSearchForTitleIn

  >Updates URLs for the default entries (sites now use https, and an update to the Open Library's URL search pattern).
- [[24371]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24371) OPAC 'Showing only available items/Show all items' is double encoded
- [[24486]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24486) Account Wording Information is duplicated in Patron's Fines Tab on OPAC
- [[24523]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24523) Fix opac-password-recovery markup mistake
- [[24560]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24560) Don't show "Public Lists" in OPAC List menu if no public lists exist

### SIP2

- [[24449]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24449) SIP2 - too_many_overdue flag is not implemented

### Searching

- [[10879]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10879) OverDrive should check for OverDriveLibraryID before performing search
- [[15142]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15142) Titles facet does not work in UNIMARC
- [[24443]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24443) Consider NULL as 0 for issues in items search

### Searching - Elasticsearch

- [[17885]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17885) Koha::SearchEngine::Elasticsearch->reset_elasticsearch_mappings throws DBD::mysql Duplicate entry exceptions
- [[22426]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22426) Elasticsearch - Index location is missing in advanced search

### Serials

- [[23064]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23064) Cannot edit subscription with strict SQL modes turned on

### Staff Client

- [[24515]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24515) Column Configuration for pay-fines-table does not hide Account Type properly

### System Administration

- [[24025]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24025) Make CodeMirror content searchable
- [[24394]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24394) Typo when adding a new cash register
- [[24395]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24395) Floats in cash registers have 6 decimals

### Templates

- [[23113]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23113) members/pay.tt account_grp is not longer used

  >This patch removes markup that is no longer required in the pay.tt template (this template is used in the accounting section for patrons).
- [[24373]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24373) Correct basic cataloging editor CSS
- [[24391]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24391) Remove event attributes from patron clubs edit template

### Test Suite

- [[23274]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23274) t/db_dependent/XISBN.t fails with Elasticsearch
- [[24200]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24200) Borrower_PrevCheckout.t failing randomly
- [[24396]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24396) Suggestions.t is failing with MySQL 8
- [[24408]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24408) Comparing floats in tests should not care about precision
- [[24507]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24507) Checkouts/ReturnClaim.t is failing on MySQL 8
- [[24543]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24543) Wrong test in api/v1/checkouts.t
- [[24546]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24546) Club/Hold.t has a wrong call to build_sample_item
- [[24590]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24590) Koha/Object.t is failing on MySQL 8

### Tools

- [[10352]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10352) Cataloguing log search mixing itemnumber/bibnumber
- [[23377]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23377) bulkmarcimport.pl disables syspref caching
- [[24275]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24275) Inventory table should be sortable by title without leading articles (allow for title sort with anti-the)
- [[24330]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24330) When importing patrons from CSV, automatically strip BOM from file if it exists
- [[24484]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24484) Add explanatory text to batch patron deletion
- [[24497]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24497) CodeMirror indentation problems


## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://koha-community.org/manual/19.11/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (99.3%)
- Armenian (100%)
- Basque (56.6%)
- Chinese (China) (57.2%)
- Chinese (Taiwan) (99.9%)
- Czech (91.9%)
- English (New Zealand) (79.5%)
- English (USA)
- Finnish (75.4%)
- French (95.3%)
- French (Canada) (95.2%)
- German (100%)
- German (Switzerland) (82%)
- Greek (71.1%)
- Hindi (99.7%)
- Italian (87.1%)
- Norwegian Bokmål (84.7%)
- Occitan (post 1500) (53.9%)
- Polish (78.9%)
- Portuguese (100%)
- Portuguese (Brazil) (89.8%)
- Slovak (80.3%)
- Spanish (100%)
- Swedish (85.3%)
- Turkish (92.8%)
- Ukrainian (71.3%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 19.11.03 is


- Release Manager: Martin Renvoize

- Release Manager assistants:
  - Jonathan Druart
  - Tomas Cohen Arazi

- QA Manager: Katrin Fischer

- QA Team:
  - Tomás Cohen Arazi
  - Nick Clemens
  - Joonas Kylmälä
  - Jonathan Druart
  - Kyle Hall
  - Josef Moravec
  - Marcel de Rooy

- Topic Experts:
  - REST API -- Tomás Cohen Arazi
  - SIP2 -- Colin Campbell
  - UI Design -- Owen Leonard
  - Elasticsearch -- Fridolin Somers
  - ILS-DI -- Arthur Suzuki

- Bug Wranglers:
  - Michal Denár
  - Lisette Scheer
  - Cori Lynn Arnold
  - Amit Gupta

- Packaging Manager: Mirko Tietgen and Mason James

- Documentation Manager: Caroline Cyr La Rose and David Nind

- Documentation Team:
  - Donna Bachowski
  - Caroline Cyr La Rose
  - Lucy Vaux-Harvey
  - Sugandha Bajaj
  - David Nind

- Translation Managers: 
  - Bernardo González Kriegel

- Release Maintainers:
  - 19.11 -- Joy Nelson
  - 19.05 -- Lucas Gass
  - 18.11 -- Hayley Mapley
## Credits

We thank the following individuals who contributed patches to Koha 19.11.03.

- Cori Lynn Arnold (1)
- Nick Clemens (27)
- Jonathan Druart (42)
- Katrin Fischer (7)
- Lucas Gass (6)
- Kyle Hall (4)
- Andreas Jonsson (1)
- Joonas Kylmälä (1)
- Owen Leonard (13)
- Julian Maurice (1)
- Joy Nelson (7)
- Liz Rea (1)
- Martin Renvoize (14)
- David ROberts (1)
- Marcel de Rooy (8)
- Caroline Cyr La Rose (2)
- Fridolin Somers (6)
- Koha Translators (1)
- Ian Walls (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 19.11.03

- ACPL (13)
- BibLibre (7)
- BSZ BW (7)
- ByWater-Solutions (46)
- Koha Community Developers (42)
- koha-ptfs.co.uk (1)
- Kreablo AB (1)
- PTFS-Europe (14)
- Rijks Museum (8)
- Solutions inLibro inc (2)
- The Donohue Group (1)
- University of Helsinki (1)

We also especially thank the following individuals who tested patches
for Koha.

- Tomás Cohen Arazi (12)
- Cori Lynn Arnold (2)
- Christopher Brannon (1)
- Nick Clemens (10)
- Holly Cooper (2)
- Gabriel DeCarufel (1)
- Michal Denar (3)
- Jonathan Druart (56)
- Bouzid Fergani (6)
- Katrin Fischer (42)
- Andrew Fuerste-Henry (12)
- Brendan Gallagher (1)
- Lucas Gass (3)
- Kyle Hall (3)
- Barbara Johnson (2)
- Bernardo González Kriegel (1)
- Rhonda Kuiper (1)
- Joonas Kylmälä (1)
- Owen Leonard (2)
- Ere Maijala (2)
- Hayley Mapley (3)
- Kelly McElligott (6)
- Joy Nelson (137)
- David Nind (18)
- Hans Palsson (2)
- Guillaume Paquet (1)
- Séverine Queune (1)
- Johanna Raisa (1)
- Martin Renvoize (142)
- David Roberts (2)
- Marcel de Rooy (28)
- Caroline Cyr La Rose (1)
- Maribeth Shafer (1)
- Maryse Simard (2)
- Deb Stephen (1)
- Myka Kennedy Stephens (4)
- Ed Veal (1)
- George Williams (1)
- Maggie Wong (1)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 19.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 21 Feb 2020 18:17:27.
