# RELEASE NOTES FOR KOHA 19.11.09
18 Aug 2020

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 19.11.09 can be downloaded from:

- [Download](http://download.koha-community.org/koha-19.11.09.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 19.11.09 is a security and bugfix/maintenance release.

It includes 3 security fixes, 8 enhancements, 45 bugfixes.

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

## Koha security

- [[23634]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23634) Privilege escalation vulnerability for staff users with 'edit_borrowers' permission and 'OpacResetPassword' enabled
- [[25360]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25360) Use secure flag for CGISESSID cookie
- [[24663]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24663) OPACPublic must be tested for all opac scripts

## Enhancements

### I18N/L10N

- [[25443]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25443) Improve translation of "Select the host record to link%s to"
- [[25922]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25922) aria-labels are currently not translatable

### OPAC

- [[25155]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25155) Accessibility: The 'Login modal' contains semantically incorrect headings
- [[25237]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25237) Accessibility: The 'Author details' in the full record display contains semantically incorrect headings
- [[25244]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25244) Accessibility: Checkboxes on the search results page do not contain specific aria labels
- [[25984]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25984) Accessibility: Shelf browse lacks focus visibility when cover image is missing

### System Administration

- [[25709]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25709) Rename systempreference from NotesBlacklist to NotesToHide

  >This patchset updates a syspref name to be clearer about what it does and to follow community guidelines on using inclusive language.
  >
  >https://wiki.koha-community.org/wiki/Coding_Guidelines#TERM3:_Inclusive_Language

### Templates

- [[25351]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25351) Move cart-related strings out of opac-bottom.inc and into basket.js


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[26000]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26000) Holiday exceptions are incorrectly cached for an individual branch

### Circulation

- [[25566]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25566) Change in DecreaseLoanHighHolds behaviour
- [[25726]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25726) Holds to Pull made empty by pathological holds
- [[25850]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25850) CalcDateDue freezes with 'useDaysMode' set to 'Dayweek' and the due date lands on a Sunday

### Command-line Utilities

- [[25683]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25683) update_patron_categories.pl should recognize no fine history = 0 outstanding fines

### Label/patron card printing

- [[25852]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25852) If a layout is edited, the layout type will revert to barcode

### Packaging

- [[25920]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25920) Add liblocale-codes-perl package to fix ubuntu-stable (focal)

### REST API

- [[25944]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25944) Bug in ill_requests patch schema
- [[26143]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26143) The API does not handle requesting all resources

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

- [[25499]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25499) Fund code column is empty when closing a budget
- [[25599]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25599) Allow use of cataloguing placeholders when ACQ framework is used creating new record (UseACQFrameworkForBiblioRecords)
- [[25887]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25887) Filtering funds by library resets to empty in library pull down

### Architecture, internals, and plumbing

- [[20882]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20882) URI column in the items table is limited to 255 characters
- [[25950]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25950) REMOTE_ADDR set to null if client_ip in X-Forwarded-For matches a koha_trusted_proxies value

### Circulation

- [[25293]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25293) Don't call escapeHtml on null
- [[25724]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25724) Transferred item checked in to shelving cart has cart location removed when transfer is filled
- [[25868]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25868) Transfers page must show effective itemtype
- [[25890]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25890) Checkouts table not sorting on check out date correctly
- [[25940]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25940) Two separate print dialogs when checking in/transferring an item
- [[26012]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26012) Date in 'Paid for' information not formatted to Time/DateFormat system preferences

### Command-line Utilities

- [[25853]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25853) update_patrons_category.pl has incorrect permissions in repo

### Database

- [[24379]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24379) Patron login attempts happen to be NULL instead of 0
- [[24640]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24640) quotes.timestamp should default to NULL

  >This fixes a problem with the QOTD tool - you can now add and edit quotes again.

### OPAC

- [[24473]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24473) Syndetics content should be $raw filtered on opac-detail.tt

  >Syndetics provides enhanced content which is displayed in the OPAC under the tabs 'Title Notes', 'Excerpt', 'About the author', and 'Editions'. They provide this information as HTML but Koha currently displays the content with the HTML tags. This fixes this so that the enhanced content displays correctly.
- [[25869]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25869) Coce images not loading for lists (virtualshelves)
- [[25914]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25914) Relative's checkouts have empty title in OPAC
- [[25982]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25982) OPAC shelves RSS link output is HTML not XML
- [[26070]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26070) Google Transliterate API has been deprecated

  >The Google Transliterate API has been deprecated by Google in 2011. This removes the remaining code and GoogleIndicTransliteration system preference from Koha as this is no longer functional.

### Patrons

- [[25336]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25336) Show checkouts/fines to guarantor is in the wrong section of the patron file

### Reports

- [[26111]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26111) Serials module does not appear in reports dictionary
- [[26165]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26165) Duplicating large saved report leads to error due to length of URI

### Searching - Elasticsearch

- [[25873]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25873) Elasticsearch - Records with malformed data are not indexed
- [[26009]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26009) Elasticsearch homebranch and holdingbranch facets are limited to 10

### Templates

- [[25762]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25762) Typo in linkitem.tt
- [[26098]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26098) JS error on the fund list view if no fund displayed

### Test Suite

- [[25641]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25641) Koha/XSLT/Base.t is failing on U20
- [[25729]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25729) Charges/Fees.t is failing on slow servers due to wrong date comparison
- [[26043]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26043) Holds.t is failing randomly
- [[26162]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26162) Prevent Selenium's StaleElementReferenceException

### Tools

- [[25862]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25862) TinyMCE editor mangles  local url links  (relative_urls is true) in tools/koha-new.pl
- [[25893]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25893) Log viewer no longer searches using wildcards
## New sysprefs

- NotesToHide

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

- Arabic (98.3%)
- Armenian (99.8%)
- Armenian (Classical) (100%)
- Basque (55.9%)
- Catalan; Valencian (50.8%)
- Chinese (China) (57.2%)
- Chinese (Taiwan) (98.9%)
- Czech (91.1%)
- English (New Zealand) (78.6%)
- English (USA)
- Finnish (74.6%)
- French (95.2%)
- French (Canada) (94.1%)
- German (100%)
- German (Switzerland) (81.2%)
- Greek (70.5%)
- Hindi (100%)
- Italian (86.1%)
- Norwegian Bokmål (83.7%)
- Occitan (post 1500) (53.2%)
- Polish (78.8%)
- Portuguese (99.8%)
- Portuguese (Brazil) (99.8%)
- Slovak (83.3%)
- Spanish (100%)
- Swedish (85.4%)
- Telugu (93.6%)
- Turkish (99.8%)
- Ukrainian (74.8%)
- Vietnamese (51.4%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 19.11.09 is


- Release Manager: Jonathan Druart

- Release Manager assistants:
  - Martin Renvoize
  - Tomás Cohen Arazi

- QA Manager: Katrin Fischer

- QA Team:
  - Marcel de Rooy
  - Joonas Kylmälä
  - Josef Moravec
  - Tomás Cohen Arazi
  - Nick Clemens
  - Kyle Hall
  - Martin Renvoize
  - Alex Arnaud
  - Julian Maurice
  - Matthias Meusburger

- Topic Experts:
  - Elasticsearch -- Frédéric Demians
  - REST API -- Tomás Cohen Arazi
  - UI Design -- Owen Leonard
  - Zebra -- Fridolin Somers
  - Accounts -- Martin Renvoize
  - CAS/Shibboleth -- Matthias Meusburger

- Bug Wranglers:
  - Michal Denár
  - Holly Cooper
  - Henry Bolshaw
  - Lisette Scheer
  - Mengü Yazıcıoğlu

- Packaging Manager: Mason James


- Documentation Managers:
  - Caroline Cyr La Rose
  - David Nind

- Documentation Team:
  - Martin Renvoize
  - Donna Bachowski
  - Lucy Vaux-Harvey
  - Kelly McElligott
  - Jessica Zairo
  - Chris Cormack
  - Henry Bolshaw
  - Jon Drucker

- Translation Manager: Bernardo González Kriegel


- Release Maintainers:
  - 20.05 -- Lucas Gass
  - 19.11 -- Aleisha Amohia
  - 19.05 -- Victor Grousset

- Release Maintainer mentors:
  - 19.11 -- Hayley Mapley
  - 19.05 -- Martin Renvoize

## Credits

We thank the following individuals who contributed patches to Koha 19.11.09.

- Aleisha Amohia (12)
- Tomás Cohen Arazi (6)
- Nick Clemens (19)
- David Cook (2)
- Jonathan Druart (22)
- Katrin Fischer (3)
- Andrew Fuerste-Henry (1)
- Lucas Gass (2)
- Didier Gautheron (3)
- Kyle Hall (2)
- Mason James (1)
- Andreas Jonsson (1)
- Bernardo González Kriegel (1)
- Owen Leonard (4)
- Hayley Mapley (1)
- Julian Maurice (2)
- Josef Moravec (1)
- Martin Renvoize (13)
- David Roberts (1)
- Marcel de Rooy (1)
- Fridolin Somers (2)
- Koha Translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 19.11.09

- Athens County Public Libraries (4)
- BibLibre (7)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (3)
- ByWater-Solutions (24)
- Catalyst (1)
- Independant Individuals (13)
- Koha Community Developers (22)
- KohaAloha (1)
- Kreablo AB (1)
- Prosentient Systems (2)
- PTFS-Europe (14)
- Rijks Museum (1)
- Theke Solutions (6)
- Universidad Nacional de Córdoba (1)

We also especially thank the following individuals who tested patches
for Koha.

- Aleisha Amohia (88)
- Tomás Cohen Arazi (15)
- Alex Arnaud (5)
- Donna Bachowski (1)
- Christopher Brannon (1)
- Nick Clemens (9)
- Holly Cooper (1)
- Jonathan Druart (47)
- Magnus Enger (1)
- Katrin Fischer (29)
- Andrew Fuerste-Henry (2)
- Lucas Gass (69)
- Didier Gautheron (2)
- Victor Grousset (1)
- Amit Gupta (2)
- Kyle Hall (1)
- Stina Hallin (1)
- Sally Healey (8)
- Abbey Holt (1)
- Bernardo González Kriegel (1)
- Joonas Kylmälä (2)
- Owen Leonard (7)
- Julian Maurice (5)
- Kelly McElligott (2)
- Josef Moravec (1)
- David Nind (3)
- Martin Renvoize (25)
- Jason Robb (3)
- Marcel de Rooy (11)
- Caroline Cyr La Rose (1)
- Lisette Scheer (1)
- Michael Springer (1)



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

Autogenerated release notes updated last on 18 Aug 2020 21:10:02.
