# RELEASE NOTES FOR KOHA 20.05.03
31 Aug 2020

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 20.05.03 can be downloaded from:

- [Download](http://download.koha-community.org/koha-20.05.03.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 20.05.03 is a bugfix/maintenance release.

It includes 44 enhancements, 67 bugfixes.

### System requirements

Koha is continuously tested against the following configurations and as such these are the recommendations for 
deployment: 

- Debian Jessie with MySQL 5.5 (End of life)
- Debian Stretch with MariaDB 10.1
- Debian Buster with MariaDB 10.3
- Ubuntu Bionic with MariaDB 10.1 
- Debian Stretch with MySQL 8.0 (Experimental MySQL 8.0 support)

Additional notes:
    
- Perl 5.10 is required (5.24 is recommended)
- Zebra or Elasticsearch is required




## Enhancements

### Architecture, internals, and plumbing

- [[23070]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23070) Use Koha::Hold in C4::Reserves::RevertWaitingStatus
- [[25511]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25511) Add --force option to update_dbix_class_files.pl
- [[25723]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25723) Improve efficiency of holiday calculation
- [[25998]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25998) Add 'library' relation to Koha::Account::Line
- [[26133]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26133) Unneeded calls in detail.pl can be removed
- [[26141]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26141) Duplicated code in search.pl

### Circulation

- [[25717]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25717) Improve messages for automatic renewal errors

  >This change improves the wording and grammar for automatic renewal error messages.
- [[25907]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25907) When cancelling a waiting hold on returns.pl, looks for new hold to fill without rescanning barcode

### Command-line Utilities

- [[23696]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23696) build_oai_sets.pl should take biblios from deletedbiblio_metadata too

### Fines and fees

- [[8338]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8338) Add ability to decrease fines with dropbox mode
- [[26161]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26161) Confirm and cancel buttons should be underneath the right hand form on the POS page

### Hold requests

- [[23820]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23820) Club hold pickup locations should be able to default to patron's home library

  **Sponsored by** *South East Kansas Library System*

### I18N/L10N

- [[25443]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25443) Improve translation of "Select the host record to link%s to"
- [[25922]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25922) aria-labels are currently not translatable

### Notices

- [[24591]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24591) Add developer script to preview a letter

### OPAC

- [[23795]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23795) Convert OpacCredits system preference to news block
- [[23796]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23796) Convert OpacCustomSearch system preference to news block
- [[23797]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23797) Convert OpacLoginInstructions system preference to news block
- [[25155]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25155) Accessibility: The 'Login modal' contains semantically incorrect headings
- [[25237]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25237) Accessibility: The 'Author details' in the full record display contains semantically incorrect headings
- [[25244]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25244) Accessibility: Checkboxes on the search results page do not contain specific aria labels
- [[25984]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25984) Accessibility: Shelf browse lacks focus visibility when cover image is missing
- [[26008]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26008) Remove the use of jquery.checkboxes plugin from OPAC cart
- [[26094]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26094) "Suggest for Purchase" button missing unique CSS class

### Plugin architecture

- [[25961]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25961) Add hooks for plugins to inject variables to XSLT

### SIP2

- [[24165]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24165) Add ability to send any item field in a library chosen SIP field
- [[25344]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25344) Add support for circulation status 10 ( item in transit )
- [[25347]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25347) Add support for circulation status 11 ( claimed returned )
- [[25348]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25348) Add support for circulation status 12 ( lost )

### Staff Client

- [[26084]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26084) ConsiderOnSiteCheckoutsAsNormalCheckouts description is unclear

### System Administration

- [[25709]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25709) Rename systempreference from NotesBlacklist to NotesToHide

  >This patchset updates a syspref name to be clearer about what it does and to follow community guidelines on using inclusive language.
  >
  >https://wiki.koha-community.org/wiki/Coding_Guidelines#TERM3:_Inclusive_Language

### Templates

- [[23148]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23148) Replace Bridge icons with transparent PNG files
- [[24625]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24625) Phase out jquery.cookie.js:  showLastPatron
- [[25351]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25351) Move cart-related strings out of opac-bottom.inc and into basket.js
- [[25427]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25427) Make authority subfield management interface consistent with bibliographic subfield management view
- [[25968]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25968) Make logs sort by date descending as a default and add column configuration options
- [[26004]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26004) Remove unused jQuery plugin jquery.hoverIntent.minified.js from the OPAC
- [[26010]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26010) Remove the use of jquery.checkboxes plugin from staff interface cart
- [[26011]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26011) Remove unused jQuery plugin jquery.metadata.min.js from the OPAC
- [[26016]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26016) Capitalization: MARC Preview
- [[26085]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26085) Add the copy, print and export DataTables buttons to lost items report

### Tools

- [[5087]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=5087) Option to not show CSV profiles in OPAC

  **Sponsored by** *Catalyst*

  >This patch adds an option to show or not show a CSV profile in the OPAC cart and lists download formats list.
- [[22660]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22660) Allow use of CodeMirror for editing HTML in the news editor
- [[25845]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25845) Cannot limit system logs to 'api' interface


## Critical bugs fixed

### Acquisitions

- [[26134]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26134) Error when adding to basket from new/staged file when using MARCItemFieldsToOrder

### Architecture, internals, and plumbing

- [[25964]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25964) Data loss possible when items are modified
- [[26253]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26253) duplicated mana_config in etc/koha-conf.xml

### Circulation

- [[25566]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25566) Change in DecreaseLoanHighHolds behaviour
- [[25726]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25726) Holds to Pull made empty by pathological holds
- [[25850]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25850) CalcDateDue freezes with 'useDaysMode' set to 'Dayweek' and the due date lands on a Sunday

### Command-line Utilities

- [[25683]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25683) update_patron_categories.pl should recognize no fine history = 0 outstanding fines

### I18N/L10N

- [[26158]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26158) Z3950 search button broken for translations

### ILL

- [[26114]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26114) ILL should mark status=RET only if a return happened

### Installation and upgrade (command-line installer)

- [[26265]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26265) Makefile.PL is missing pos directory

### Label/patron card printing

- [[25852]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25852) If a layout is edited, the layout type will revert to barcode

### OPAC

- [[26005]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26005) OPAC cart display fails with error

  >This fixes a problem with the OPAC cart - it should now work correctly when opened, instead of generating an error message.
- [[26037]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26037) openlibrary.org is hit on every Koha requests

### Packaging

- [[25792]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25792) Rename 'ttf-dejavu' package to 'fonts-dejavu' for Debian 11
- [[25920]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25920) Add liblocale-codes-perl package to fix ubuntu-stable (focal)

### REST API

- [[25944]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25944) Bug in ill_requests patch schema
- [[26143]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26143) The API does not handle requesting all resources

### SIP2

- [[25992]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25992) SIP2 server doesn't start - Undefined subroutine set_logger

### Searching - Elasticsearch

- [[25882]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25882) Elasticsearch - Advanced search itemtype limits are being double quoted

### Searching - Zebra

- [[23086]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23086) Search for collection is broken

### Test Suite

- [[26033]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26033) framapic is closing

### Z39.50 / SRU / OpenSearch Servers

- [[23542]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23542) SRU import encoding issue


## Other bugs fixed

### Acquisitions

- [[21268]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21268) Can't add to basket from staged file if base-level allocated is zero
- [[25499]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25499) Fund code column is empty when closing a budget
- [[25887]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25887) Filtering funds by library resets to empty in library pull down

### Architecture, internals, and plumbing

- [[25950]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25950) REMOTE_ADDR set to null if client_ip in X-Forwarded-For matches a koha_trusted_proxies value

### Circulation

- [[25293]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25293) Don't call escapeHtml on null
- [[25724]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25724) Transferred item checked in to shelving cart has cart location removed when transfer is filled
- [[25868]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25868) Transfers page must show effective itemtype
- [[25890]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25890) Checkouts table not sorting on check out date correctly
- [[25940]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25940) Two separate print dialogs when checking in/transferring an item
- [[26012]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26012) Date in 'Paid for' information not formatted to Time/DateFormat system preferences
- [[26136]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26136) Prevent double submit of checkin form

### Command-line Utilities

- [[25853]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25853) update_patrons_category.pl has incorrect permissions in repo
- [[25955]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25955) compare_es_to_db.pl broken by drop of Catmandu dependency

### Database

- [[24379]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24379) Patron login attempts happen to be NULL instead of 0

### Installation and upgrade (web-based installer)

- [[25695]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25695) Missing logging of $@ in onboarding.pl after eval block

### Notices

- [[25629]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25629) Fix capitalization in sample notices

### OPAC

- [[24473]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24473) Syndetics content should be $raw filtered on opac-detail.tt

  >Syndetics provides enhanced content which is displayed in the OPAC under the tabs 'Title Notes', 'Excerpt', 'About the author', and 'Editions'. They provide this information as HTML but Koha currently displays the content with the HTML tags. This fixes this so that the enhanced content displays correctly.
- [[25869]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25869) Coce images not loading for lists (virtualshelves)
- [[25982]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25982) OPAC shelves RSS link output is HTML not XML
- [[26070]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26070) Google Transliterate API has been deprecated

  >The Google Transliterate API has been deprecated by Google in 2011. This removes the remaining code and GoogleIndicTransliteration system preference from Koha as this is no longer functional.
- [[26179]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26179) Remove redundant import of Google font

### Packaging

- [[25889]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25889) Increase performance of debian/list-deps script

### Patrons

- [[25336]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25336) Show checkouts/fines to guarantor is in the wrong section of the patron file
- [[26125]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26125) In 'Patron search' tab link should lead to patron details instead of checkout screen

### Plugin architecture

- [[25953]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25953) Add ID to installed plugins table to ease styling and DOM mods

### Reports

- [[26111]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26111) Serials module does not appear in reports dictionary
- [[26165]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26165) Duplicating large saved report leads to error due to length of URI

### Searching - Elasticsearch

- [[25873]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25873) Elasticsearch - Records with malformed data are not indexed
- [[26009]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26009) Elasticsearch homebranch and holdingbranch facets are limited to 10

### Self checkout

- [[26131]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26131) console errors when attempting to open SCO related system preferences

### System Administration

- [[25919]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25919) Desks link is available in left side menu even if UseCirculationDesks is disabled

### Templates

- [[25718]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25718) Correct typo in additem.tt
- [[25762]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25762) Typo in linkitem.tt
- [[25765]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25765) Replace LoginBranchname and LoginBranchcode with use of Branches template plugin
- [[25987]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25987) Radio buttons are misaligned in New label batches
- [[26098]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26098) JS error on the fund list view if no fund displayed

### Test Suite

- [[25729]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25729) Charges/Fees.t is failing on slow servers due to wrong date comparison
- [[26043]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26043) Holds.t is failing randomly
- [[26115]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26115) Remove leftover Carp::Always
- [[26162]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26162) Prevent Selenium's StaleElementReferenceException

### Tools

- [[25862]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25862) TinyMCE editor mangles  local url links  (relative_urls is true) in tools/koha-new.pl
- [[25893]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25893) Log viewer no longer searches using wildcards
- [[26017]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26017) Cashup registers never shows on tools page
- [[26121]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26121) When using CodeMirror in News Tool DatePicker is hard to see
- [[26124]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26124) Console errors on tools_koha-news when editing with TinyMCE
## New sysprefs

- NewsToolEditor
- NotesToHide

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://koha-community.org/manual/20.05/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (100%)
- Armenian (99.4%)
- Armenian (Classical) (99.7%)
- Chinese (Taiwan) (94%)
- Czech (81.4%)
- English (New Zealand) (67.8%)
- English (USA)
- Finnish (70.5%)
- French (82.1%)
- French (Canada) (96.1%)
- German (97.7%)
- German (Switzerland) (75.7%)
- Greek (60.7%)
- Hindi (100%)
- Italian (81.4%)
- Norwegian Bokmål (72.3%)
- Polish (73.9%)
- Portuguese (88.5%)
- Portuguese (Brazil) (99.4%)
- Slovak (84%)
- Spanish (100%)
- Swedish (78.7%)
- Telugu (91%)
- Turkish (93.2%)
- Ukrainian (65.4%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 20.05.03 is


- Release Manager: Martin Renvoize

- Release Manager assistants:
  - Tomás Cohen Arazi
  - Jonathan Druart

- QA Manager: Katrin Fischer

- QA Team:
  - Jonathan Druart
  - Marcel de Rooy
  - Joonas Kylmälä
  - Josef Moravec
  - Tomás Cohen Arazi
  - Nick Clemens
  - Kyle Hall

- Topic Experts:
  - SIP2 -- Colin Campbell
  - EDI -- Colin Campbell
  - Elasticsearch -- Fridolin Somers
  - REST API -- Tomás Cohen Arazi
  - ILS-DI -- Arthur Suzuki
  - UI Design -- Owen Leonard
  - ILL -- Andrew Isherwood

- Bug Wranglers:
  - Michal Denár
  - Cori Lynn Arnold
  - Lisette Scheer
  - Amit Gupta

- Packaging Manager: Mason James


- Documentation Managers:
  - Caroline Cyr La Rose
  - David Nind

- Documentation Team:
  - Donna Bachowski
  - Lucy Vaux-Harvey
  - Sugandha Bajaj

- Translation Manager: Bernardo González Kriegel


- Release Maintainers:
  - 19.11 -- Joy Nelson
  - 19.05 -- Lucas Gass
  - 18.11 -- Hayley Mapley

- Release Maintainer mentors:
  - 19.11 -- Martin Renvoize
  - 19.05 -- Nick Clemens
  - 18.11 -- Chris Cormack

## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 20.05.03:

- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)
- [South East Kansas Library System](http://www.sekls.org)

We thank the following individuals who contributed patches to Koha 20.05.03.

- Aleisha Amohia (1)
- Tomás Cohen Arazi (16)
- Nick Clemens (20)
- David Cook (3)
- Jonathan Druart (38)
- Katrin Fischer (8)
- Andrew Fuerste-Henry (2)
- Lucas Gass (22)
- Didier Gautheron (4)
- Kyle Hall (6)
- Mason James (3)
- Andreas Jonsson (1)
- Bernardo González Kriegel (1)
- Joonas Kylmälä (2)
- Owen Leonard (25)
- Hayley Mapley (1)
- Julian Maurice (5)
- Josef Moravec (2)
- Agustín Moyano (2)
- David Nind (1)
- Martin Renvoize (37)
- David Roberts (1)
- Marcel de Rooy (2)
- Caroline Cyr La Rose (1)
- Slava Shishkin (1)
- Fridolin Somers (4)
- Koha Translators (1)
- Timothy Alexis Vass (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 20.05.03

- Athens County Public Libraries (25)
- BibLibre (13)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (8)
- ByWater-Solutions (50)
- Catalyst (1)
- David Nind (1)
- Independant Individuals (4)
- Koha Community Developers (38)
- KohaAloha (3)
- Kreablo AB (1)
- Prosentient Systems (3)
- PTFS-Europe (38)
- Rijks Museum (2)
- Solutions inLibro inc (1)
- Theke Solutions (18)
- ub.lu.se (1)
- Universidad Nacional de Córdoba (1)
- University of Helsinki (2)

We also especially thank the following individuals who tested patches
for Koha.

- Tomás Cohen Arazi (27)
- Alex Arnaud (8)
- Donna Bachowski (1)
- Christopher Brannon (1)
- Nick Clemens (26)
- Rebecca Coert (1)
- Holly Cooper (1)
- Frédéric Demians (1)
- Michal Denar (2)
- Jonathan Druart (139)
- Magnus Enger (1)
- Katrin Fischer (60)
- Andrew Fuerste-Henry (6)
- Lucas Gass (194)
- Didier Gautheron (4)
- Victor Grousset (8)
- Amit Gupta (2)
- Kyle Hall (2)
- Stina Hallin (1)
- Sally Healey (22)
- Heather Hernandez (1)
- Abbey Holt (1)
- Barbara Johnson (1)
- Jill Kleven (1)
- Bernardo González Kriegel (2)
- Joonas Kylmälä (13)
- Owen Leonard (14)
- Ere Maijala (1)
- Julian Maurice (11)
- Kelly McElligott (2)
- Josef Moravec (5)
- David Nind (10)
- Emma Perks (8)
- Martin Renvoize (37)
- Jason Robb (4)
- Marcel de Rooy (15)
- Caroline Cyr La Rose (3)
- Lisette Scheer (4)
- Maryse Simard (1)
- Michael Springer (1)

We thank the following individuals who mentored new contributors to the Koha project.

- Andrew Nugged


We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is rmain2005.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 31 Aug 2020 21:01:34.
