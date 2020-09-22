# RELEASE NOTES FOR KOHA 19.05.15
22 Sep 2020

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 19.05.15 can be downloaded from:

- [Download](https://download.koha-community.org/koha-19.05.15.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 19.05.15 is a bugfix/maintenance release.

It includes 4 enhancements, 26 bugfixes.

### System requirements

- Debian 8 (Jessie) is not supported anymore
- MySQL 5.5 is not supported anymore

Koha is continuously tested against the following configurations and as such these are the recommendations for 
deployment: 

- Debian 9 (Stretch) with MariaDB 10.1 (and experimental MariaDB 10.3 support)
- Ubuntu 18.04 (Bionic) with MariaDB 10.1

Additional notes:
    
- Perl >= 5.14 is required and 5.24 or 5.26 are recommended
- Zebra or Elasticsearch is required




## Enhancements

### OPAC

- [[25155]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25155) Accessibility: The 'Login modal' contains semantically incorrect headings
- [[25244]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25244) Accessibility: Checkboxes on the search results page do not contain specific aria labels
- [[26041]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26041) Accessibility: The date picker calendar is not keyboard accessible

### System Administration

- [[25709]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25709) Rename systempreference from NotesBlacklist to NotesToHide

  >This patchset updates a syspref name to be clearer about what it does and to follow community guidelines on using inclusive language.
  >
  >https://wiki.koha-community.org/wiki/Coding_Guidelines#TERM3:_Inclusive_Language


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[26000]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26000) Holiday exceptions are incorrectly cached for an individual branch
- [[26253]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26253) duplicated mana_config in etc/koha-conf.xml

### Circulation

- [[25566]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25566) Change in DecreaseLoanHighHolds behaviour
- [[25726]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25726) Holds to Pull made empty by pathological holds

### Database

- [[24379]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24379) Patron login attempts happen to be NULL instead of 0

### Label/patron card printing

- [[25852]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25852) If a layout is edited, the layout type will revert to barcode

### OPAC

- [[26069]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26069) Twitter share button leaks information to Twitter

### Packaging

- [[17084]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17084) Automatic debian/control updates (master)
- [[25591]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25591) Update list-deps for Debian 10 and Ubuntu 20.04
- [[25792]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25792) Rename 'ttf-dejavu' package to 'fonts-dejavu' for Debian 11

### REST API

- [[25944]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25944) Bug in ill_requests patch schema

### Reports

- [[26090]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26090) Catalog by itemtype report fails if SQL strict mode is on

### Searching - Zebra

- [[23086]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23086) Search for collection is broken

### Test Suite

- [[26033]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26033) framapic is closing

### Z39.50 / SRU / OpenSearch Servers

- [[23542]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23542) SRU import encoding issue


## Other bugs fixed

### Architecture, internals, and plumbing

- [[26270]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26270) XISBN.t is failing since today

### Cataloging

- [[26233]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26233) Edit item date sort still does not sort correctly

### OPAC

- [[25982]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25982) OPAC shelves RSS link output is HTML not XML

### Searching - Elasticsearch

- [[25873]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25873) Elasticsearch - Records with malformed data are not indexed

### System Administration

- [[25005]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25005) Admin Rights issue for Suggestion to Purchase

### Templates

- [[25762]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25762) Typo in linkitem.tt

### Test Suite

- [[24147]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24147) Objects.t is failing randomly
- [[25641]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25641) Koha/XSLT/Base.t is failing on U20
- [[25729]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25729) Charges/Fees.t is failing on slow servers due to wrong date comparison
- [[26043]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26043) Holds.t is failing randomly
- [[26162]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26162) Prevent Selenium's StaleElementReferenceException
## New sysprefs

- NotesToHide

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

- Arabic (98.6%)
- Armenian (100%)
- Armenian (Classical) (99.9%)
- Basque (59.2%)
- Chinese (China) (59.7%)
- Chinese (Taiwan) (99.4%)
- Czech (92.8%)
- Danish (52%)
- English (New Zealand) (82.7%)
- English (USA)
- Finnish (79%)
- French (98.5%)
- French (Canada) (99%)
- German (100%)
- German (Switzerland) (85.7%)
- Greek (73.5%)
- Hindi (100%)
- Italian (90.2%)
- Norwegian Bokmål (88.4%)
- Occitan (post 1500) (55.9%)
- Polish (82.7%)
- Portuguese (99.9%)
- Portuguese (Brazil) (94.2%)
- Slovak (86.5%)
- Spanish (100%)
- Swedish (87.9%)
- Turkish (100%)
- Ukrainian (73.7%)
- Vietnamese (50.7%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 19.05.15 is


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

We thank the following individuals who contributed patches to Koha 19.05.15.

- Aleisha Amohia (2)
- Nick Clemens (6)
- Jonathan Druart (18)
- Andrew Fuerste-Henry (1)
- Didier Gautheron (1)
- Victor Grousset (4)
- Kyle Hall (1)
- Mason James (3)
- Owen Leonard (1)
- Hayley Mapley (1)
- Julian Maurice (1)
- Martin Renvoize (5)
- Fridolin Somers (1)
- Koha Translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 19.05.15

- Athens County Public Libraries (1)
- BibLibre (3)
- ByWater-Solutions (8)
- Catalyst (1)
- Independant Individuals (2)
- Koha Community Developers (22)
- KohaAloha (3)
- PTFS-Europe (5)

We also especially thank the following individuals who tested patches
for Koha.

- Aleisha Amohia (39)
- Tomás Cohen Arazi (5)
- Alex Arnaud (2)
- Donna Bachowski (1)
- Christopher Brannon (1)
- Nick Clemens (4)
- Jonathan Druart (17)
- Magnus Enger (1)
- Katrin Fischer (13)
- Lucas Gass (33)
- Didier Gautheron (1)
- Victor Grousset (41)
- Amit Gupta (2)
- Kyle Hall (1)
- Sally Healey (5)
- Brandon Jimenez (1)
- Owen Leonard (4)
- Julian Maurice (2)
- Kelly McElligott (2)
- Martin Renvoize (9)
- David Roberts (1)
- Marcel de Rooy (3)



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

Autogenerated release notes updated last on 22 Sep 2020 13:41:51.
