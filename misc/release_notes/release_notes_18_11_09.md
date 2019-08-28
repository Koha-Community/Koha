# RELEASE NOTES FOR KOHA 18.11.09
28 Aug 2019

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 18.11.09 can be downloaded from:

- [Download](http://download.koha-community.org/koha-18.11.09.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 18.11.09 is a bugfix/maintenance release.

It includes 10 enhancements, 46 bugfixes.




## Enhancements

### Architecture, internals, and plumbing

- [[23230]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23230) Make Koha::Plugins::Base::_version_compare OO

### Notices

- [[23278]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23278) Reopen last panel upon "Save and continue" in notices

### System Administration

- [[23179]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23179) Add 'Edit subfields' to framework management tag dropdown and clarify options

### Templates

- [[20650]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20650) Switch single-column templates to Bootstrap grid: Various, part 3
- [[22935]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22935) Improve style of Bootstrap pagination
- [[23183]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23183) Reindent cataloging.js
- [[23221]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23221) Reindent tools/manage-marc-import.tt
- [[23304]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23304) Reindent cataloguing/z3950_search.tt

### Test Suite

- [[23280]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23280) Warning in t/db_dependent/selenium/patrons_search.t

### Web services

- [[23156]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23156) Add pagination to checkouts in ILS-DI GetPatronInfo service


## Critical bugs fixed

### Acquisitions

- [[21316]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21316) Adding controlfields to the ACQ framework causes issues when adding to basket

### Cataloging

- [[23045]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23045) Advanced cataloging editor (rancor) throws a JS error on incomplete/blank lines

### Circulation

- [[23103]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23103) Cannot checkin items lost by deleted patrons with fines attached
- [[23145]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23145) Confirming transfer during checkin clears the table of previously checked-in items
- [[23405]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23405) Circulation autocomplete for patron lookup broken if cardnumber is empty

### Command-line Utilities

- [[22566]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22566) Stock rotation cronjob reporting has issues

### Course reserves

- [[22142]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22142) An item's current location changes to blank when it is removed from Course Reserves
- [[23083]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23083) Course reserve item edit fails if one does not set all values

### Fines and fees

- [[23143]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23143) [18.11] Filter paid transactions not working

### ILL

- [[23229]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23229) "Get all requests" API call fired when loading any ILL page

### Label/patron card printing

- [[23455]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23455) Patron card printing from Patron lists is broken

### OPAC

- [[23151]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23151) Patron self modification sends null dateofbirth
- [[23194]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23194) Public notes items in the OPAC should allow for HTML tags

> Since 18.11, item.itemnotes content is escaped so any HTML tag would appear broken. It is now allowed again, hyperlinks for example.


- [[23428]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23428) Self registration with a verification by email is broken
- [[23431]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23431) having Date of birth in PatronSelfModificationBorrowerUnwantedField causes DOB to be nullified

### Searching - Elasticsearch

- [[23322]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23322) Elasticsearch - Record matching fails when multiple keys exist

### Tools

- [[11642]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11642) Improve Batch patron deletion and anonymization GUI to make consequences clearer
- [[18707]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18707) Background jobs post disabled inputs


## Other bugs fixed

### Acquisitions

- [[23363]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23363) Clicking on shipping cost invoice link from spent.pl causes internal server error

### Circulation

- [[21027]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21027) Totals in statistics tab change when StatisticsFields is changed
- [[22617]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22617) Checkout notes pending dashboard link - error received even though manage_checkout_notes permission set

> This fixes an error that occurs when an account with full circulate permissions (but not super librarian permissions) clicks on 'Checkout notes pending' and is then automatically logged out with the message "Error: you do not have permission to view this page. Log in as a different user".


- [[23098]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23098) KOC upload process has misleading wording
- [[23192]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23192) Cancelling holds over returning to wrong tab on waitingreserves.pl
- [[23220]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23220) Cancelling transfer on returns.pl is subject to a race condition
- [[23255]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23255) HomeOrHoldingbranch system preference options are described wrong

### Command-line Utilities

- [[22128]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22128) koha-remove fails mysql ERROR 1133 (42000) at line 2: Can't find any matching row in the user table

### Fines and fees

- [[23115]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23115) Totals are unclear when a credit is involved on the OPAC 'Fines and charges' screen

### Hold requests

- [[22021]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22021) Item status not shown accurately on request.pl

### Lists

- [[23266]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23266) Add to cart fires twice on shelf page

### OPAC

- [[12537]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12537) Editions tab showing on bibs with more than one ISBN
- [[22949]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22949) Markup error in OPAC course reserves template
- [[22951]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22951) Markup error in OPAC holds template
- [[23078]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23078) Use Koha.Preference in OPAC global header include
- [[23308]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23308) Contents of "OpacMaintenanceNotice" HTML escaped on display

### Packaging

- [[21000]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21000) debian/build-git-snapshot script ignores -D

### Patrons

- [[23077]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23077) Can't import patrons without cardnumber
- [[23199]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23199) Koha::Patron->store and uppercasesurname syspref
- [[23218]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23218) Batch patron modification empty attribute causes improper handling of values

### Searching

- [[23132]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23132) Encoding issues in facets with show more link

### Searching - Elasticsearch

- [[21534]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21534) ElasticSearch - Wildcards not being analyzed

### Templates

- [[22710]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22710) [18.11] Return to the last advanced search link not filtering correctly
- [[22957]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22957) Remove type attribute from script tags: Staff client includes 1/2
- [[23227]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23227) Remove type attribute from script tags: Reports

### Test Suite

- [[23177]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23177) Rollback cleanup in Circulation.t
- [[23211]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23211) SIP/Transaction.t is failing randomly

### Tools

- [[19012]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19012) Note additional columns that are required during patron import



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

- [Koha Manual](http://koha-community.org/manual/18.11/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (98.2%)
- Armenian (100%)
- Basque (65.7%)
- Chinese (China) (63.8%)
- Chinese (Taiwan) (99.4%)
- Czech (93.4%)
- Danish (55.1%)
- English (New Zealand) (87.9%)
- English (USA)
- Finnish (84.1%)
- French (99.2%)
- French (Canada) (99.4%)
- German (100%)
- German (Switzerland) (91.4%)
- Greek (78.3%)
- Hindi (99.8%)
- Italian (93.5%)
- Norwegian Bokmål (94.5%)
- Occitan (post 1500) (59.3%)
- Polish (86.4%)
- Portuguese (99.9%)
- Portuguese (Brazil) (87.3%)
- Slovak (89.9%)
- Spanish (99.8%)
- Swedish (90.5%)
- Turkish (98.1%)
- Ukrainian (62.2%)
- Vietnamese (54.4%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 18.11.09 is

- Release Manager: Nick Clemens
- Release Manager assistants:
  - Tomás Cohen Arazi
  - Jonathan Druart
- QA Manager: Katrin Fischer
- QA Team:
  - Tomás Cohen Arazi
  - Alex Arnaud
  - Chris Cormack
  - Jonathan Druart
  - Kyle Hall
  - Julian Maurice
  - Josef Moravec
  - Martin Renvoize
  - Marcel de Rooy
- Topic Experts:
  - REST API -- Tomás Cohen Arazi
  - SIP2 -- Colin Campbell
  - EDI -- Colin Campbell
  - UI Design -- Owen Leonard
  - Elasticsearch -- Ere Maijala
- Bug Wranglers:
  - Indranil Das Gupta
  - Jon Knight
  - Luis Moises Rojas
- Packaging Manager: Mirko Tietgen
- Documentation Manager: Caroline Cyr-La-Rose
- Documentation Team:
  - David Nind
  - Lucy Vaux-Harvey

- Translation Managers: 
  - Indranil Das Gupta
  - Bernardo González Kriegel

- Wiki curators: 
  - Caroline Cyr-La-Rose
- Release Maintainers:
  - 18.05 -- Lucas Gass
  - 18.05 -- Jesse Maseto
  - 18.11 -- Martin Renvoize
  - 17.11 -- Fridolin Somers
- Release Maintainer assistants:
  - 18.05 -- Kyle Hall

## Credits

We thank the following individuals who contributed patches to Koha 18.11.09.

- Tomás Cohen Arazi (2)
- Rudolf Byker (1)
- Nick Clemens (19)
- Jonathan Druart (8)
- Katrin Fischer (2)
- Lucas Gass (4)
- Kyle Hall (3)
- Andrew Isherwood (2)
- Owen Leonard (19)
- Julian Maurice (1)
- Josef Moravec (1)
- Liz Rea (2)
- Martin Renvoize (8)
- Marcel de Rooy (2)
- Fridolin Somers (4)
- Arthur Suzuki (1)
- Mark Tompsett (6)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 18.11.09

- ACPL (19)
- BibLibre (6)
- BSZ BW (2)
- ByWater-Solutions (26)
- Independant Individuals (10)
- Koha Community Developers (8)
- PTFS-Europe (10)
- Rijks Museum (2)
- Theke Solutions (2)

We also especially thank the following individuals who tested patches
for Koha.

- Tomás Cohen Arazi (1)
- Arthur Bousquet (2)
- Frederik Chenier (2)
- frederik chenier (6)
- Nick Clemens (18)
- Chris Cormack (2)
- Michal Denar (2)
- Jason DeShaw (1)
- Jonathan Druart (4)
- Bouzid Fergani (1)
- Katrin Fischer (26)
- frederik (1)
- Lucas Gass (83)
- Claire Gravely (6)
- Kyle Hall (10)
- Ron Houk (1)
- Owen Leonard (3)
- Julian Maurice (1)
- Laurel Moran (1)
- Josef Moravec (6)
- Nadine Pierre (6)
- Liz Rea (2)
- Martin Renvoize (90)
- Marcel de Rooy (18)
- Maryse Simard (6)
- Fridolin Somers (77)
- Christian Stelzenmüller (1)
- Mark Tompsett (21)
- Ian Walls (1)
- Bin Wen (3)
- George Williams (1)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is rmain1811.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 28 Aug 2019 02:24:56.
