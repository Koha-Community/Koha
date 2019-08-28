# RELEASE NOTES FOR KOHA 19.05.03
28 août 2019

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 19.05.03 can be downloaded from:

- [Download](http://download.koha-community.org/koha-19.05.03.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 19.05.03 is a bugfix/maintenance release.

It includes 15 enhancements, 65 bugfixes.




## Enhancements

### Architecture, internals, and plumbing

- [[23230]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23230) Make Koha::Plugins::Base::_version_compare OO
- [[23237]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23237) Plugin allow [% INCLUDE %] from template

### Notices

- [[23278]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23278) Reopen last panel upon "Save and continue" in notices

### OPAC

- [[23099]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23099) OPAC Search result sorting "go" button flashes on page load

### REST api

- [[17003]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17003) REST API: add route to get checkout's renewability

### Searching - Elasticsearch

- [[20607]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20607) Elasticsearch - ability to add a relevancy weight in mappings.yaml file

### Templates

- [[22935]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22935) Improve style of Bootstrap pagination
- [[23159]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23159) Reindent addbiblio.tt
- [[23183]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23183) Reindent cataloging.js
- [[23196]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23196) Reindent tools/batch_record_modification.tt
- [[23221]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23221) Reindent tools/manage-marc-import.tt
- [[23304]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23304) Reindent cataloguing/z3950_search.tt

### Test Suite

- [[23280]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23280) Warning in t/db_dependent/selenium/patrons_search.t

### Web services

- [[23154]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23154) Add pagination to /api/v1/checkouts
- [[23156]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23156) Add pagination to checkouts in ILS-DI GetPatronInfo service


## Critical bugs fixed

### Acquisitions

- [[21316]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21316) Adding controlfields to the ACQ framework causes issues when adding to basket

### Architecture, internals, and plumbing

- [[23316]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23316) GetFine needs updating for bug 22521

### Cataloging

- [[23045]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23045) Advanced cataloging editor (rancor) throws a JS error on incomplete/blank lines

### Circulation

- [[23018]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23018) Refunding a lost item fee may trigger error if any fee has been written off related to that item
- [[23145]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23145) Confirming transfer during checkin clears the table of previously checked-in items
- [[23405]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23405) Circulation autocomplete for patron lookup broken if cardnumber is empty

### Command-line Utilities

- [[22566]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22566) Stock rotation cronjob reporting has issues

### Course reserves

- [[22142]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22142) An item's current location changes to blank when it is removed from Course Reserves
- [[23083]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23083) Course reserve item edit fails if one does not set all values

### Hold requests

- [[14549]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14549) Hold not removed when item is checked out to patron who is not next in priority list

### ILL

- [[23229]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23229) "Get all requests" API call fired when loading any ILL page

### Installation and upgrade (web-based installer)

- [[23396]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23396) Rancor fails to load: insert_copyright is not defined

### Label/patron card printing

- [[23455]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23455) Patron card printing from Patron lists is broken

### OPAC

- [[23194]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23194) Public notes items in the OPAC should allow for HTML tags

> Since 18.11, item.itemnotes content is escaped so any HTML tag would appear broken. It is now allowed again, hyperlinks for example.


- [[23225]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23225) OPAC ISBD view returns 404 when no item attached
- [[23253]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23253) OpacNavRight does not display correctly for opacuserlogin disabled or self registration
- [[23428]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23428) Self registration with a verification by email is broken
- [[23431]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23431) having Date of birth in PatronSelfModificationBorrowerUnwantedField causes DOB to be nullified

### Searching - Elasticsearch

- [[23322]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23322) Elasticsearch - Record matching fails when multiple keys exist

### Staff Client

- [[23315]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23315) Some system preferences are no longer editable

### Tools

- [[11642]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11642) Improve Batch patron deletion and anonymization GUI to make consequences clearer
- [[18707]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18707) Background jobs post disabled inputs

### Web services

- [[22249]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22249) Error when submitting Mana comment


## Other bugs fixed

### About

- [[22862]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22862) It should be possible to paste formatted phone numbers into the SMS messaging number field

> This bugfix improves the likelihood of pasted patron phone numbers passing validation as we will now attempt to normalise out illegal characters often used to human-friendly formatting.



### Acquisitions

- [[23251]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23251) EDI Order line incorrectly terminated when it ends with a quoted apostrophe
- [[23363]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23363) Clicking on shipping cost invoice link from spent.pl causes internal server error

### Cataloging

- [[21518]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21518) Material type "three-dimensional artifact" displays as "visual material"

### Circulation

- [[21027]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21027) Totals in statistics tab change when StatisticsFields is changed
- [[23098]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23098) KOC upload process has misleading wording
- [[23158]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23158) on-site checkout missing when using itemBarcodeFallbackSearch
- [[23192]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23192) Cancelling holds over returning to wrong tab on waitingreserves.pl
- [[23220]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23220) Cancelling transfer on returns.pl is subject to a race condition
- [[23255]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23255) HomeOrHoldingbranch system preference options are described wrong

### Command-line Utilities

- [[22128]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22128) koha-remove fails mysql ERROR 1133 (42000) at line 2: Can't find any matching row in the user table
- [[23193]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23193) Make set_password.pl use Koha::Script
- [[23345]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23345) Wrong parameter name in koha-dump usage statement

### Fines and fees

- [[23106]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23106) Totals are unclear when a credit is involved on the 'Pay fines' screen
- [[23115]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23115) Totals are unclear when a credit is involved on the OPAC 'Fines and charges' screen

### Hold requests

- [[22021]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22021) Item status not shown accurately on request.pl
- [[23048]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23048) Hide non-pickup branches from hold modification select

### I18N/L10N

- [[10492]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10492) Translation problems with TT directives in po files

### Lists

- [[23266]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23266) Add to cart fires twice on shelf page

### OPAC

- [[12537]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12537) Editions tab showing on bibs with more than one ISBN
- [[22949]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22949) Markup error in OPAC course reserves template
- [[22951]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22951) Markup error in OPAC holds template
- [[23078]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23078) Use Koha.Preference in OPAC global header include
- [[23126]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23126) Multiline entries in subscription history display with <br/> in OPAC
- [[23248]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23248) opac-ISBDdetail.pl dies on invalid biblionumber
- [[23308]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23308) Contents of "OpacMaintenanceNotice" HTML escaped on display

### Packaging

- [[21000]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21000) debian/build-git-snapshot script ignores -D

### Patrons

- [[22741]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22741) Koha::Patron->store must not log updated_on changes (random failure of test BorrowerLogs and TrackLastPatronActivity)
- [[23077]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23077) Can't import patrons without cardnumber
- [[23199]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23199) Koha::Patron->store and uppercasesurname syspref
- [[23217]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23217) Batch patron modification shows database errors when no Attribute provided
- [[23218]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23218) Batch patron modification empty attribute causes improper handling of values

### Searching

- [[15704]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15704) The 264 index should be split by subfield to match how 260 is indexed

### Searching - Elasticsearch

- [[22524]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22524) Elasticsearch - Date range in advanced search

### Staff Client

- [[21716]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21716) Item Search hangs when \ exists in MARC fields

### Templates

- [[13597]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13597) Amazon 'no image' element needs a 'no-image' class, in the staff client
- [[22768]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22768) Global search forms' keyboard navigation broken
- [[22957]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22957) Remove type attribute from script tags: Staff client includes 1/2
- [[23226]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23226) Remove type attribute from script tags: Cataloging
- [[23227]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23227) Remove type attribute from script tags: Reports

### Test Suite

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

- [Koha Manual](http://koha-community.org/manual/19.05/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (99.4%)
- Armenian (100%)
- Basque (60.2%)
- Chinese (China) (60.8%)
- Chinese (Taiwan) (100%)
- Czech (90.8%)
- Danish (52.7%)
- English (New Zealand) (83.9%)
- English (USA)
- Finnish (80.2%)
- French (93.8%)
- French (Canada) (98.7%)
- German (100%)
- German (Switzerland) (87.1%)
- Greek (74.1%)
- Hindi (99.5%)
- Italian (89.4%)
- Norwegian Bokmål (89.9%)
- Occitan (post 1500) (56.8%)
- Polish (83.9%)
- Portuguese (100%)
- Portuguese (Brazil) (93.6%)
- Slovak (85.2%)
- Spanish (99.3%)
- Swedish (89%)
- Turkish (98.8%)
- Ukrainian (71.3%)
- Vietnamese (50.8%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 19.05.03 is

- Release Manager: Martin Renvoize
- Release Manager assistants:
  - Tomás Cohen Arazi
  - Nick Clemens
- QA Manager: Katrin Fischer
- QA Team:
  - Tomás Cohen Arazi
  - Alex Arnaud
  - Nick Clemens
  - Jonathan Druart
  - Kyle Hall
  - Julian Maurice
  - Josef Moravec
  - Marcel de Rooy
- Topic Experts:
  - REST API -- Tomás Cohen Arazi
  - SIP2 -- Kyle Hall
  - UI Design -- Owen Leonard
  - Elasticsearch -- Alex Arnaud
  - ILS-DI -- Arthur Suzuki
  - Authentication -- Martin Renvoize
- Bug Wranglers:
  - Michal Denár
  - Indranil Das Gupta
  - Jon Knight
  - Lisette Scheer
  - Arthur Suzuki
- Packaging Manager: Mirko Tietgen
- Documentation Manager: David Nind
- Documentation Team:
  - Andy Boze
  - Caroline Cyr-La-Rose
  - Lucy Vaux-Harvey

- Translation Managers: 
  - Indranil Das Gupta
  - Bernardo González Kriegel
- Release Maintainers:
  - 19.05 -- Fridolin Somers
  - 18.11 -- Lucas Gass
  - 18.05 -- Liz Rea
## Credits

We thank the following individuals who contributed patches to Koha 19.05.03.

- Tomás Cohen Arazi (5)
- Alex Arnaud (2)
- Rudolf Byker (1)
- Colin Campbell (1)
- Nick Clemens (28)
- Chris Cormack (1)
- Frédéric Demians (1)
- Jonathan Druart (16)
- Katrin Fischer (4)
- Kyle Hall (5)
- Andrew Isherwood (2)
- Pasi Kallinen (1)
- Bernardo González Kriegel (1)
- Owen Leonard (26)
- Ere Maijala (2)
- Julian Maurice (2)
- Josef Moravec (3)
- Liz Rea (3)
- Martin Renvoize (14)
- Marcel de Rooy (3)
- Fridolin Somers (7)
- Arthur Suzuki (1)
- Lari Taskula (1)
- Mark Tompsett (7)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 19.05.03

- ACPL (26)
- BibLibre (11)
- BSZ BW (4)
- ByWater-Solutions (33)
- Catalyst (1)
- Independant Individuals (15)
- Koha Community Developers (16)
- koha-suomi.fi (1)
- PTFS-Europe (17)
- Rijks Museum (3)
- student.uef.fi (1)
- Tamil (1)
- Theke Solutions (5)
- Universidad Nacional de Córdoba (1)
- University of Helsinki (2)

We also especially thank the following individuals who tested patches
for Koha.

- Tomás Cohen Arazi (13)
- Arthur Bousquet (3)
- Frederik Chenier (2)
- Frédérik Chénier (8)
- Nick Clemens (32)
- Chris Cormack (7)
- Michal Denar (3)
- Jason DeShaw (1)
- Jonathan Druart (9)
- Bouzid Fergani (1)
- Katrin Fischer (35)
- Lucas Gass (2)
- Claire Gravely (7)
- Kyle Hall (17)
- Ron Houk (1)
- Pasi Kallinen (1)
- Nicolas Legrand (1)
- Owen Leonard (8)
- Luis F. Lopez (2)
- Hayley Mapley (3)
- Felicia Martin (1)
- Laurel Moran (1)
- Josef Moravec (6)
- David Nind (2)
- Nadine Pierre (10)
- Johanna Raisa (3)
- Liz Rea (5)
- Martin Renvoize (143)
- Marcel de Rooy (22)
- Maryse Simard (10)
- Fridolin Somers (136)
- Christian Stelzenmüller (1)
- Mark Tompsett (27)
- Ian Walls (1)
- Bin Wen (2)
- George Williams (1)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 19.05.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 28 août 2019 13:34:42.
