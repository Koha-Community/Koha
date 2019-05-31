# RELEASE NOTES FOR KOHA 18.11.06
31 May 2019

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 18.11.06 can be downloaded from:

- [Download](http://download.koha-community.org/koha-18.11.06.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 18.11.06 is a bugfix/maintenance release.

It includes 50 bugfixes.

## Critical bugs fixed

### Acquisitions

- [[22713]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22713) Replacement price removed when receiving if using MarcItemFieldstoOrder
- [[22908]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22908) Modsuggestion will generate a notice even if the modification failed

### Authentication

- [[22717]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22717) Google OAuth auto registration error

### Circulation

- [[22896]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22896) Item to be transferred at checkin clears overridden due date

### Course reserves

- [[22899]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22899) Cannot view course details

### Fines and fees

- [[22724]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22724) Staff without writeoff permissions have access to 'Write off selected' button on Pay Fines tab

> Sponsored by Catalyst IT


### Hold requests

- [[22895]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22895) [18.11] cannot place item level holds

### OPAC

- [[11853]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11853) Cannot clear date of birth via OPAC patron update
- [[22420]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22420) Tag cloud feature broken
- [[22881]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22881) Trying to clear search history via the navbar X doesn't clear any searches

### Reports

- [[22357]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22357) Every run of runreport.pl with --store-results creates a new row in saved reports

### Searching - Elasticsearch

- [[22705]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22705) Change default value of Elasticsearch cxn_pool to 'Static'

### Serials

- [[22812]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22812) Cannot add new subscription with strict SQL modes turned on

### System Administration

- [[22847]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22847) Specific circ rule by patron category is displaying the default (or not displaying)

### Templates

- [[22904]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22904) Untranslatable strings in members-menu.js

### Test Suite

- [[22836]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22836) Tests catching XSS vulnerabilities in pagination are not correct


## Other bugs fixed

### Acquisitions

- [[22225]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22225) Tax hints and prices on orderreceive.pl may not match
- [[22791]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22791) Calculation differs on aqui-home/spent and ordered.pl
- [[22907]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22907) Cannot add new suggestion with strict SQL modes turned on

### Architecture, internals, and plumbing

- [[7862]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7862) Warns when creating a new notice

> Sponsored by Catalyst IT

- [[21036]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21036) Fix a bunch of older warnings
- [[22813]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22813) searchResults queries the Koha::Patron object inside two nested loops

### Cataloging

- [[21709]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21709) Addbiblio shows clickable tag editor icons which do nothing
- [[22886]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22886) Missing space between fields from Keyword to MARC mapping in cataloguing search

### Command-line Utilities

- [[20537]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20537) Warnings in overdue_notices.pl

> Sponsored by Catalyst IT

- [[22875]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22875) Documentation misleading for import_patrons command line script

### Database

- [[22782]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22782) Schema change for SocialData

### Installation and upgrade (web-based installer)

- [[21651]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21651) Force insert of notices related tables during the install process
- [[22527]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22527) Web installer links to wrong database manual when database user doesn't have required privileges

> Sponsored by Hypernova Oy


### Label/patron card printing

- [[22878]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22878) Cannot add a patron card layout with mysql strict mode on

### MARC Authority data support

- [[21450]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21450) link_bibs_to_authorities.pl is caching searches without the auth type

### OPAC

- [[22816]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22816) OPAC detail holdings table doesn't fill it's container

### Patrons

- [[20514]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20514) Searching for a patrons using the address option doesn't work with streetnumber
- [[22781]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22781) Fields on patron search results should be html/json filtered

### SIP2

- [[15221]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15221) SIP server always sets the alert flag when item not returned

### Searching

- [[22010]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22010) RecordedBooks and OverDrive should check preferences over passing variables
- [[22787]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22787) Mapping missing for ů to u in word-phrase-utf-chr
- [[22901]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22901) On item search authorised values select disappears on conditional change

### Staff Client

- [[17698]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17698) Make patron notes show up on staff dashboard

> RMNOTE - REMOVE FROM RELEASE NOTES - 18.11 FEATURE


- [[22914]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22914) Add holds column to batch item delete to fix show/hide columns behaviour

### System Administration

- [[22965]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22965) Typo in Classification Sources description on Admin homepage (admin-home.tt)

### Templates

- [[22800]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22800) No need to raw filter the mandatory fields var (OPAC suggestions)
- [[22932]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22932) GetLatestSerials should not return formatted date

### Test Suite

- [[21671]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21671) Koha/Patron/Modifications.t is failing randomly
- [[22433]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22433) SIP/Transaction.t is failing randomly
- [[22453]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22453) TestBuilder should generate now() using the current timezone
- [[22808]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22808) Move Cache.t to db_dependent
- [[22917]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22917) Circulation.t fails if tests are ran slowly
- [[22930]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22930) Make TestBuilder more strict about wrong arguments

### Tools

- [[21831]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21831) Marc modification templates move all action moves only one field



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

- Arabic (98.6%)
- Armenian (100%)
- Basque (63.6%)
- Chinese (China) (64%)
- Chinese (Taiwan) (99.8%)
- Czech (93.6%)
- Danish (55.4%)
- English (New Zealand) (88.3%)
- English (USA)
- Finnish (84.5%)
- French (98.3%)
- French (Canada) (99.7%)
- German (100%)
- German (Switzerland) (91.8%)
- Greek (78.7%)
- Hindi (100%)
- Italian (93.8%)
- Norwegian Bokmål (94.9%)
- Occitan (post 1500) (59.6%)
- Polish (86.8%)
- Portuguese (100%)
- Portuguese (Brazil) (87.5%)
- Slovak (90.3%)
- Spanish (100%)
- Swedish (90.9%)
- Turkish (98.4%)
- Ukrainian (62.2%)
- Vietnamese (54.7%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 18.11.06 is

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
We thank the following libraries who are known to have sponsored
new features in Koha 18.11.06:

- Catalyst IT
- Hypernova Oy
- Northeast Kansas Library System, NEKLS (http://nekls.org/)

We thank the following individuals who contributed patches to Koha 18.11.06.

- Aleisha Amohia (1)
- Tomás Cohen Arazi (3)
- Henry Bolshaw (1)
- Colin Campbell (1)
- Nick Clemens (16)
- David Cook (1)
- Jonathan Druart (40)
- Katrin Fischer (2)
- Lucas Gass (1)
- Owen Leonard (3)
- Hayley Mapley (2)
- Julian Maurice (1)
- Josef Moravec (1)
- Liz Rea (3)
- Martin Renvoize (9)
- Marcel de Rooy (5)
- Fridolin Somers (1)
- Mirko Tietgen (1)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 18.11.06

- abunchofthings.net (1)
- ACPL (3)
- BibLibre (2)
- BSZ BW (2)
- ByWater-Solutions (17)
- Catalyst (2)
- Independant Individuals (5)
- Koha Community Developers (40)
- parliament.uk (1)
- Prosentient Systems (1)
- PTFS-Europe (10)
- Rijks Museum (5)
- Theke Solutions (3)

We also especially thank the following individuals who tested patches
for Koha.

- Tomás Cohen Arazi (3)
- Arthur Bousquet (1)
- Claudio (1)
- Nick Clemens (84)
- Chris Cormack (7)
- Michal Denar (10)
- Jonathan Druart (11)
- Bouzid Fergani (1)
- Katrin Fischer (31)
- Kyle Hall (1)
- Frank Hansen (1)
- Jon Knight (1)
- Owen Leonard (2)
- Hayley Mapley (4)
- Josef Moravec (2)
- Liz Rea (32)
- Martin Renvoize (104)
- Marcel de Rooy (22)
- Lisette Scheer (1)
- Maryse Simard (4)
- Bin Wen (2)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 18.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 31 May 2019 06:51:51.
