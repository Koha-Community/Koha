# RELEASE NOTES FOR KOHA 18.05.03
24 Aug 2018

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 18.05.03 can be downloaded from:

- [Download](http://download.koha-community.org/koha-18.05.03.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 18.05.03 is a bugfix/maintenance release.

It includes 1 new features, 16 enhancements, 64 bugfixes.

## New features

### REST api

- [[20942]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20942) Add route to get patron's account balance

> Introduces API endpoints for dealing with patron accounts, a highly requested feature for third-party integrations.



## Enhancements

### Architecture, internals, and plumbing

- [[20079]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20079) Display stack trace for development installations
- [[20509]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20509) Data consistency - authority types
- [[20661]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20661) Implement blocking errors for circulation scripts
- [[20990]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20990) Add Koha::Account::outstanding_credits
- [[21150]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21150) Data inconsistencies - item types
- [[21221]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21221) Implement blocking errors for members/memberentry.pl

### Command-line Utilities

- [[20795]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20795) koha-rebuild-zebra should pass through increased verbosity
- [[21011]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21011) Data inconsistencies - items.holdingbranch | items.homebranch

### Installation and upgrade (web-based installer)

- [[20683]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20683) Update German web installer for 18.05

### Patrons

- [[18635]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18635) Koha::Patron->guarantees() should return results alphabetically

### Searching - Elasticsearch

- [[19604]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19604) Elasticsearch Fixes for build_authorities_query for auth searching

### Staff Client

- [[20647]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20647) When ILL is enabled the hover effect on the ILL requests button is wrong.

### Templates

- [[20984]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20984) MARC21 subfield 300f - Type of Unit  does not display
- [[21112]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21112) Re-indent staff client cart template
- [[21125]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21125) Shortcut moredetail.pl on nonexistent biblionumber

### Test Suite

- [[20757]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20757) Capture a screenshot on selenium errors


## Critical bugs fixed

### Security

- 21199 Patron's attributes are displayed on GetPatronInfo's ILSDI output regardless opac_display

This security/data confidentiality bugfix alters functionality. The GetPatronInfo request in ILSDI will now only ever return public information and not any staff only attributes.

### Acquisitions

- [[20014]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20014) When adding to basket from a staged file item budgets are selected by matching on code, not id

### Authentication

- [[18947]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18947) Unexpected Active Directory LDAP authentication failure mode

> This corrects an



### Cataloging

- [[14662]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14662) Allow blank values in pull downs in cataloguing forms when subfield is mandatory

### Command-line Utilities

- [[20811]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20811) Fix wrong usage of ModBiblio in bulkmarcimport.pl
- [[21122]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21122) Make check-url-quick.pl handle utf8 characters in urls gracefuly

### Database

- [[20773]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20773) bug 20724 follow-up - Database cleanup

### Label/patron card printing

- [[8604]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8604) Patron cards made for patrons which don't have patron images use preceding card's image

### OPAC

- [[21018]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21018) OPAC Resource URL Broken if Tracklinks is enabled

### Patrons

- [[21208]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21208) Housebound deliverer/chooser have wrong name when creating a visit

### Searching - Elasticsearch

- [[21032]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21032) Refining a search made on a specific index fail

### System Administration

- [[21151]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21151) SRU search fields mapping pop-up comes up empty

### Web services

- [[21203]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21203) ILS-DI - GetRecords crashes on non-existent records


## Other bugs fixed

### Acquisitions

- [[15408]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15408) Timestamp on funds not updated when you duplicate a budget
- [[21033]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21033) Remove few warns in acqui/basket.pl
- [[21048]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21048) suggest_status not behaving properly
- [[21097]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21097) Missing optgroup closing tag in orderreceive.tt

### Architecture, internals, and plumbing

- [[20631]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20631) C4::Acounts claims to use ReturnLostItem but doesn't
- [[20980]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20980) Manual credit offsets are stored as debits

> This change may affect existing reports. Credits will no longer be recorded as 'debits' but rather get their own 'Manual Credit' type.


- [[21056]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21056) Changing the logged in library can fail sporadically
- [[21154]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21154) Remove unused subs from C4::Serials
- [[21182]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21182) acqui/check_duplicate_barcode_ajax.pl is not longer in use
- [[21238]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21238) TemplateToolkit.t is failing on slow server

### Cataloging

- [[21053]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21053) Editing 008 field with a hash overwrites data
- [[21064]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21064) Advanced cataloging editor - rancor - check for changes should return 'undefined' instead of 'undef'

### Circulation

- [[20487]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20487) AddReturn should clear items.onloan for unissued items
- [[20660]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20660) AddReturn should use return date override for debarments

### Command-line Utilities

- [[21035]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21035) runreport.pl prints only a newline when printing a row that has a field that contains an embedded newline

### Developer documentation

- [[21077]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21077) Fix comment for statistics.type in installer/data/mysql/kohastructure.sql

### Hold requests

- [[21075]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21075) AutoUnsuspendHolds should unsuspend holds <= today
- [[21076]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21076) Javascript error on article requests page

### I18N/L10N

- [[19500]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19500) Make module names on letters overview page translatable

### Label/patron card printing

- [[6647]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=6647) Label item search should use standard pagination routine

### OPAC

- [[16575]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16575) Irregular behaviour using window.print() followed by window.location.href=
- [[19291]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19291) Make breadcrumbs for OPAC search history consistent with other patron account pages
- [[21094]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21094) Syndetics: always use https instead of http

### Patrons

- [[7996]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7996) Patron modification log requires parameters permission
- [[20806]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20806) Item type in holds history table should be written as description, not code
- [[21041]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21041) "Merge patrons" button remains disabled with "Select all" option

### REST api

- [[21031]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21031) Apache Rewrite rules don't work for API when using anything but Debian package Plack configuration

### Searching

- [[19390]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19390) OPAC view link in staff results should open in a new tab

### Searching - Elasticsearch

- [[20273]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20273) Elasticsearch: Auth-finder.pl autocomplete must use search_auth_compat

### Staff Client

- [[17625]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17625) 245f and 245g are not displayed in XSLT
- [[20504]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20504) Language attribute in html tag is empty in system preference editor

### System Administration

- [[21131]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21131) Changing and restoring a WYSIWYG preference can result in unexpected behaviour
- [[21144]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21144) ROADTYPE missing from authorised value categories list

### Templates

- [[19511]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19511) Local cover images not centered in table column in staff client search results
- [[20828]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20828) Step 4 of moremember is used for Housebound and additional attributes
- [[20974]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20974) Remove files left behind after removing Solr
- [[21038]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21038) Reserves should be holds
- [[21099]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21099) Floating toolbars reposition too late
- [[21139]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21139) The floating toolbars have some issues
- [[21145]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21145) The "Column visibility" button should not be displayed at the OPAC
- [[21148]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21148) Dropdowns styled by the Select2 plugin do not highlight missing required fields
- [[21164]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21164) Fix alignment on new basket form in acquisitions
- [[21185]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21185) Incorrect title tag on tags review page
- [[21243]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21243) Regression: SRU mapping popup for bibliographic records is unstyled

### Test Suite

- [[21134]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21134) Wrong error handling in Koha/Patron/Modification.pm hides a bug
- [[21188]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21188) t/db_dependent/Circulation/issue.t is failing
- [[21213]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21213) Circulation.t needs diagnostics
- [[21230]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21230) Reserves.t is failing randomly

### Tools

- [[21141]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21141) Batch item modification tool throws error 500 when an itemnumber is invalid
- [[21142]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21142) Batch item/record modification/deletion tools does not open uploaded files in utf-8

### Web services

- [[21226]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21226) Remove use of retired OCLC xISBN service

> OCLC has now discontinued support for the xisbn service.  One can continue to use the functionality that this service provided to Koha by switching on the ThingISBN preferences as an alternative.





## System requirements

Important notes:
    
- Perl 5.10 is required
- Zebra is required

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://koha-community.org/manual/18.05/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (100%)
- Armenian (99.9%)
- Basque (73.4%)
- Chinese (China) (77.8%)
- Chinese (Taiwan) (100%)
- Czech (93.3%)
- Danish (64.3%)
- English (New Zealand) (96.8%)
- English (USA)
- Finnish (92.9%)
- French (99.9%)
- French (Canada) (93%)
- German (100%)
- German (Switzerland) (99.7%)
- Greek (80.6%)
- Hindi (99.9%)
- Italian (98.1%)
- Norwegian Bokmål (65.8%)
- Occitan (post 1500) (71.1%)
- Persian (53.5%)
- Polish (94.9%)
- Portuguese (99.9%)
- Portuguese (Brazil) (82.9%)
- Slovak (95.2%)
- Spanish (99.7%)
- Swedish (94.9%)
- Turkish (99.8%)
- Vietnamese (65.8%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 18.05.03 is

- Release Manager: [Nick Clemens](mailto:nick@bywatersolutions.com)
- Release Manager assistants:
  - [Brendan Gallagher](mailto:brendan@bywatersolutions.com)
  - [Jonathan Druart](mailto:jonathan.druart@bugs.koha-community.org)
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
  - [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)

- Module Maintainers:
  - REST API -- [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
  - Elasticsearch -- [Nick Clemens](mailto:nick@bywatersolutions.com)
- QA Manager: [Katrin Fischer](mailto:Katrin.Fischer@bsz-bw.de)

- QA Team:
  - [Julian Maurice](mailto:julian.maurice@biblibre.com)
  - [Marcel de Rooy](mailto:m.de.rooy@rijksmuseum.nl)
  - Josef Moravec
  - [Alex Arnaud](mailto:alex.arnaud@biblibre.com)
  - [Martin Renvoize](mailto:martin.renvoize@ptfs-europe.com)
  - [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
  - [Jonathan Druart](mailto:jonathan.druart@bugs.koha-community.org)
  - [Chris Cormack](mailto:chrisc@catalyst.net.nz)
- Bug Wranglers:
  - Claire Gravely
  - Jon Knight
  - [Indranil Das Gupta](mailto:indradg@l2c2.co.inc)
  - [Amit Gupta](mailto:amitddng135@gmail.com)
- Packaging Manager: [Mirko Tietgen](mailto:mirko@abunchofthings.net)
- Documentation Team:
  - Lee Jamison
  - David Nind
  - Caroline Cyr La Rose
- Translation Manager: [Bernardo Gonzalez Kriegel](mailto:bgkriegel@gmail.com)
- Release Maintainers:
  - 18.05 -- [Martin Renvoize](mailto:martin.renvoize@ptfs-europe.com)
  - 17.11 -- [Fridolin Somers](mailto:fridolin.somers@biblibre.com)
  - 17.05 -- [Fridolin Somers](mailto:fridolin.somers@biblibre.com)

## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 18.05.03:


We thank the following individuals who contributed patches to Koha 18.05.03.

- Alex Arnaud (2)
- David Bourgault (2)
- Nick Clemens (21)
- Tomás Cohen Arazi (18)
- David Cook (3)
- Marcel de Rooy (8)
- Jonathan Druart (40)
- Katrin Fischer (14)
- Andrew Isherwood (1)
- Owen Leonard (14)
- Kyle M Hall (2)
- Josef Moravec (5)
- Joy Nelson (2)
- Chris Nighswonger (1)
- Liz Rea (1)
- Martin Renvoize (8)
- Koha translators (1)
- Baptiste Wojtkowski (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 18.05.03

- ACPL (14)
- BibLibre (3)
- BSZ BW (14)
- bugs.koha-community.org (40)
- ByWater-Solutions (25)
- Catalyst (1)
- Foundations (1)
- Prosentient Systems (3)
- PTFS-Europe (17)
- Rijksmuseum (8)
- Theke Solutions (18)
- unidentified (7)

We also especially thank the following individuals who tested patches
for Koha.

- DEVINIM (1)
- Brendan A Gallagher (1)
- Nick Clemens (130)
- Tomas Cohen Arazi (16)
- Chris Cormack (3)
- Marcel de Rooy (17)
- John Doe (1)
- Jonathan Druart (30)
- Charles Farmer (1)
- Katrin Fischer (47)
- Claire Gravely (2)
- Victor Grousset (2)
- Dilan Johnpullé (1)
- Pierre-Luc Lapointe (6)
- Nicolas Legrand (2)
- Owen Leonard (18)
- Ere Maijala (1)
- Julian Maurice (2)
- Kyle M Hall (22)
- Josef Moravec (27)
- Joy Nelson (1)
- Chris Nighswonger (1)
- Séverine QUEUNE (3)
- Martin Renvoize (158)
- Lisette Scheer (1)
- Maryse Simard (9)
- Christian Stelzenmüller (1)
- Mirko Tietgen (1)
- Mark Tompsett (3)
- Marc Véron (2)
- Cab Vinton (2)


We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 18.05.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 24 Aug 2018 14:31:47.
