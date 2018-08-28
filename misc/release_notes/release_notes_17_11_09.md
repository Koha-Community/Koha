# RELEASE NOTES FOR KOHA 17.11.09
28 ao�t 2018

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 17.11.09 can be downloaded from:

- [Download](http://download.koha-community.org/koha-17.11.09.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 17.11.09 is a bugfix/maintenance release.

It includes 1 enhancements, 26 bugfixes.




## Enhancements

### MARC Bibliographic data support

- [[20710]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20710) Update MARC21 frameworks to Update 26 (April 2018)
    

## Critical bugs fixed

### Security

- 21199 Patron's attributes are displayed on GetPatronInfo's ILSDI output regardless opac_display

This security/data confidentiality bugfix alters functionality. The GetPatronInfo request in ILSDI will now only ever return public information and not any staff only attributes.

### Acquisitions

- [[20014]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20014) When adding to basket from a staged file item budgets are selected by matching on code, not id

### Authentication

- [[18947]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18947) Unexpected Active Directory LDAP authentication failure mode

### Cataloging

- [[14662]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14662) Allow blank values in pull downs in cataloguing forms when subfield is mandatory

### Command-line Utilities

- [[20811]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20811) Fix wrong usage of ModBiblio in bulkmarcimport.pl
- [[21122]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21122) Make check-url-quick.pl handle utf8 characters in urls gracefuly

### Database

- [[20773]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20773) bug 20724 follow-up - Database cleanup

### Hold requests

- [[20724]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20724) ReservesNeedReturns syspref breaks "Holds awaiting pickup"

### Label/patron card printing

- [[8604]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8604) Patron cards made for patrons which don't have patron images use preceding card's image

### OPAC

- [[21018]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21018) OPAC Resource URL Broken if Tracklinks is enabled

### Searching - Elasticsearch

- [[21032]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21032) Refining a search made on a specific index fail


## Other bugs fixed

### Acquisitions

- [[20623]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20623) PDF export of a basket group fails when an item has an itemtype that is not in the itemtype table

### Architecture, internals, and plumbing

- [[12001]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12001) GetMemberAccountRecords slows down display of patron details and checkout pages

### Cataloging

- [[18822]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18822) Advanced editor - Rancor - searching broken under Elasticsearch
- [[21009]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21009) Max length of inputs on editing/adding items is broken

### I18N/L10N

- [[20332]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20332) Untranslatable strings in grouped OPAC results

### OPAC

- [[20090]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20090) Missing Script Statement for Novelist Select on Some Record Displays in OPAC
- [[20953]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20953) Discharge can be requested several times on OPAC

### Packaging

- [[20949]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20949) Koha depends on Clone

### Patrons

- [[21025]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21025) Koha::Patron::Discharge is missing use C4::Letters

### Searching - Elasticsearch

- [[19502]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19502) Result sets limited to 10000

### Staff Client

- [[20919]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20919) A Zebra query is done for each item when opening a record detail page

### System Administration

- [[14446]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14446) Resolve "Use of uninitialized value in goto" in admin/preferences.pl

### Templates

- [[20698]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20698) Remove obsolete template: transfer-slip.tt

### Test Suite

- [[20900]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20900) Yet another test assumes that CPL is present
- [[21023]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21023) Remove warning in t/db_dependent/Circulation/Chargelostitem.t



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

- [Koha Manual](http://koha-community.org/manual/17.11/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (99.5%)
- Armenian (100%)
- Basque (75.4%)
- Chinese (China) (79.8%)
- Chinese (Taiwan) (99.8%)
- Czech (93.9%)
- Danish (65.8%)
- English (New Zealand) (99.5%)
- English (USA)
- Finnish (95.7%)
- French (98.9%)
- French (Canada) (92.1%)
- German (100%)
- German (Switzerland) (99.5%)
- Greek (81.8%)
- Hindi (99.9%)
- Italian (99.9%)
- Norwegian Bokmål (54.6%)
- Occitan (post 1500) (72.9%)
- Persian (54.9%)
- Polish (97.5%)
- Portuguese (100%)
- Portuguese (Brazil) (84.5%)
- Slovak (96.7%)
- Spanish (99.9%)
- Swedish (91.7%)
- Turkish (100%)
- Vietnamese (67.5%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 17.11.09 is

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
new features in Koha 17.11.09:


We thank the following individuals who contributed patches to Koha 17.11.09.

- Alex Arnaud (1)
- Nick Clemens (10)
- Tomás Cohen Arazi (1)
- Marcel de Rooy (8)
- Jonathan Druart (8)
- Charles Farmer (1)
- Katrin Fischer (2)
- Bernardo González Kriegel (1)
- Victor Grousset (2)
- Pasi Kallinen (1)
- David Kuhn (1)
- Owen Leonard (1)
- Julian Maurice (3)
- Kyle M Hall (1)
- Chris Nighswonger (1)
- Liz Rea (1)
- Martin Renvoize (1)
- Fridolin Somers (4)
- Mirko Tietgen (2)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 17.11.09

- abunchofthings.net (4)
- ACPL (1)
- BibLibre (10)
- BSZ BW (2)
- bugs.koha-community.org (8)
- ByWater-Solutions (10)
- bywatetsolutions.com (1)
- Catalyst (1)
- Foundations (1)
- inLibro.com (1)
- joensuu.fi (1)
- PTFS-Europe (1)
- Rijksmuseum (8)
- Theke Solutions (1)
- unidentified (1)
- Universidad Nacional de Córdoba (1)

We also especially thank the following individuals who tested patches
for Koha.

- Brendan A Gallagher (1)
- Hugo Agud (1)
- Aleisha Amohia (1)
- Alex Arnaud (5)
- Nick Clemens (40)
- Tomas Cohen Arazi (3)
- Chris Cormack (6)
- Marcel de Rooy (18)
- Jonathan Druart (12)
- Charles Farmer (1)
- Katrin Fischer (21)
- Victor Grousset (5)
- Pasi Kallinen (1)
- Pierre-Luc Lapointe (1)
- Owen Leonard (4)
- Josef Moravec (1)
- Chris Nighswonger (1)
- Séverine QUEUNE (2)
- Martin Renvoize (44)
- Fridolin Somers (47)
- Christian Stelzenmüller (1)
- Mirko Tietgen (2)


We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is sec_171109.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 28 ao�t 2018 13:56:55.
