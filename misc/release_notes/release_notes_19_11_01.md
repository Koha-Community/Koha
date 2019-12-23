# RELEASE NOTES FOR KOHA 19.11.01
23 Dec 2019

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 19.11.01 can be downloaded from:

- [Download](http://download.koha-community.org/koha-19.11.01.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 19.11.01 is a bugfix/maintenance release.

It includes 30 bugfixes.

### System requirements

Koha is continiously tested against the following configurations and as such these are the recommendations for 
deployment: 

- Debian Jessie with MySQL 5.5
- Debian Stretch with MariaDB 10.1 (MySQL 8.0 support is experimental)
- Ubuntu Bionic with MariaDB 10.1 (MariaDB 10.3 support is experimental) 

Additional notes:
    
- Perl 5.10 is required
- Zebra or Elasticsearch is required






## Critical bugs fixed

### Architecture, internals, and plumbing

- [[24243]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24243) Bad characters in MARC cause internal server error when searching catalog

### Circulation

- [[24138]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24138) suspension miscalculated when Suspension charging interval bigger than 1 and Max. suspension duration  is defined

### Command-line Utilities

- [[24164]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24164) Patron emailer cronjob is not generating unique content for notices

### Fines and fees

- [[24177]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24177) Internal Server error when clicking cash register (Report)

### Hold requests

- [[24168]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24168) Errors with use of CanItemBeReserved return value

### Notices

- [[24268]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24268) advance_notices.pl dies on undefined letter

### REST API

- [[24191]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24191) Sorting doesn't use to_model

  **Sponsored by** *ByWater Solutions*

### SIP2

- [[24175]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24175) Cannot cancel holds - wrong parameter passed for itemnumber

### Searching

- [[23970]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23970) itemsearch - publication date not taken into account if not used in the first field


## Other bugs fixed

### About

- [[24136]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24136) Add libraries (sponsors) to the about page

### Acquisitions

- [[24033]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24033) Fix column labelling on basket summary page (ecost)

### Architecture, internals, and plumbing

- [[24106]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24106) In returns.pl, don't search for item if no barcode is provided

### Cataloging

- [[23800]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23800) Batch modification tool orders items by barcode incremental by default (regression to 17.11)
- [[24090]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24090) Subfield text in red when mandatory in record edition

### MARC Bibliographic data support

- [[17831]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17831) Remove non-existing bibliosubject.subject mapping from frameworks

### OPAC

- [[23785]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23785) Software error Can't call method "get_coins" on an undefined value at /usr/share/koha/opac/cgi-bin/opac/opac-search.pl line 692.

### Reports

- [[13806]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13806) No input sanitization where creating Reports subgroup

### Searching - Elasticsearch

- [[24128]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24128) Add alias for biblionumber => local-number

### Staff Client

- [[23246]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23246) Record detail page jumps into the 'images' tab if no holdings

  **Sponsored by** *American Numismatics Society*
- [[23987]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23987) batchMod.pl provides a link back to the record after the record is deleted

### System Administration

- [[24170]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24170) sysprefs search result does not have a consistent order

### Templates

- [[24053]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24053) Typo in FinePaymentAutoPopup description
- [[24056]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24056) Capitalization: Cash Register ID on cash register management page
- [[24057]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24057) Hea is not an acronym
- [[24126]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24126) Article requests tab appears twice on patron's checkout screen
- [[24230]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24230) intranet_js plugin hook is after body end tag

### Test Suite

- [[24144]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24144) regressions.t tests have not been updated after bug 23836
- [[24145]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24145) Auth.t is failing because of wrong mocked ->param
- [[24199]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24199) t/Auth_with_shibboleth.t is failing randomly

### Tools

- [[24124]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24124) Cannot select authorities in batch deletion tool in Chrome


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

- Arabic (100%)
- Armenian (100%)
- Basque (57%)
- Chinese (China) (57.5%)
- Chinese (Taiwan) (99.8%)
- Czech (92%)
- Danish (50.1%)
- English (New Zealand) (80%)
- English (USA)
- Finnish (75.9%)
- French (94.9%)
- French (Canada) (95.4%)
- German (100%)
- German (Switzerland) (82.5%)
- Greek (70.6%)
- Hindi (100%)
- Italian (86.7%)
- Norwegian Bokmål (85.2%)
- Occitan (post 1500) (54.3%)
- Polish (79.3%)
- Portuguese (100%)
- Portuguese (Brazil) (90%)
- Slovak (80.8%)
- Spanish (98.2%)
- Swedish (85.2%)
- Turkish (93.4%)
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

The release team for Koha 19.11.01 is


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
  - Caroline Cyr La Rose
  - Lucy Vaux-Harvey

- Translation Managers: 
  - Indranil Das Gupta
  - Bernardo González Kriegel

- Release Maintainers:
  - 19.05 -- Fridolin Somers
  - 18.11 -- Lucas Gass
  - 18.05 -- Liz Rea
## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 19.11.01:

- American Numismatics Society
- [ByWater Solutions](https://bywatersolutions.com/)

We thank the following individuals who contributed patches to Koha 19.11.01.

- Tomás Cohen Arazi (6)
- Nick Clemens (8)
- Jonathan Druart (15)
- Katrin Fischer (1)
- Kyle Hall (1)
- Owen Leonard (4)
- Josef Moravec (1)
- Joy Nelson (2)
- Martin Renvoize (2)
- Marcel de Rooy (2)
- Lisette Scheer (3)
- Fridolin Somers (2)
- Koha Translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 19.11.01

- ACPL (4)
- BibLibre (2)
- BSZ BW (1)
- ByWater-Solutions (11)
- Independant Individuals (4)
- Koha Community Developers (15)
- PTFS-Europe (2)
- Rijks Museum (2)
- Theke Solutions (6)

We also especially thank the following individuals who tested patches
for Koha.

- Hugo Agud (2)
- Tomás Cohen Arazi (3)
- Cori Lynn Arnold (1)
- Bob Bennhoff (1)
- Jonathan Druart (15)
- Katrin Fischer (8)
- Andrew Fuerste-Henry (1)
- Lucas Gass (1)
- Kyle Hall (1)
- Joonas Kylmälä (5)
- Nicolas Legrand (1)
- Owen Leonard (3)
- Kelly McElligott (1)
- Josef Moravec (3)
- Joy Nelson (45)
- Séverine Queune (3)
- Liz Rea (4)
- Martin Renvoize (44)
- Marcel de Rooy (15)
- Maryse Simard (2)
- George Williams (3)
- Jessica Zairo (1)



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

Autogenerated release notes updated last on 23 Dec 2019 20:10:00.
