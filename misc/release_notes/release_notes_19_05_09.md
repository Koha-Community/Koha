# RELEASE NOTES FOR KOHA 19.05.09
25 Mar 2020

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 19.05.09 can be downloaded from:

- [Download](http://download.koha-community.org/koha-19.05.09.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 19.05.09 is a bugfix/maintenance release.

It includes 2 new features, 4 enhancements, 33 bugfixes.

### System requirements

Koha is continiously tested against the following configurations and as such these are the recommendations for 
deployment: 

- Debian Jessie with MySQL 5.5
- Debian Stretch with MariaDB 10.1 (MySQL 8.0 support is experimental)
- Ubuntu Bionic with MariaDB 10.1 (MariaDB 10.3 support is experimental) 

Additional notes:
    
- Perl 5.10 is required
- Zebra or Elasticsearch is required



## New features

### Circulation

- [[24846]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24846) Add a tool to bulk edit due dates

### REST API

- [[24260]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24260) REST Self Registration

## Enhancements

### Cataloging

- [[18499]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18499) 'Call Number Browser' on edit items screen uses the default classification source rather than the item specific source

### I18N/L10N

- [[24664]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24664) Add missing *-messages-js.po

### Templates

- [[24619]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24619) Phase out jquery.cookie.js: MARC Frameworks
- [[24621]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24621) Phase out jquery.cookie.js: Basic MARC editor


## Critical bugs fixed

### Acquisitions

- [[24389]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24389) Claiming an order can display an invalid successful message

### Authentication

- [[16719]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16719) LDAP: Using empty strings as 'failsafe' attribute mapping defeats database constraints

### Cataloging

- [[13420]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13420) Holdings table sorting on volume information incorrect

### SIP2

- [[23640]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23640) L1 cache too long in SIP Server

### Searching - Elasticsearch

- [[23719]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23719) Record matching for authorities using defined fields is broken under ES
- [[24506]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24506) Multibranch limit does not work with ElasticSearch

### Templates

- [[21663]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21663) Incorrect filter prevents predefined notes from being added to patron acccounts


## Other bugs fixed

### Architecture, internals, and plumbing

- [[20882]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20882) URI column in the items table is limited to 255 characters
- [[24051]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24051) batchMod.pl: DBIx::Class::ResultSet::search_rs(): search( %condition ) is deprecated
- [[24388]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24388) Useless test in acqui/lateorders.tt
- [[24643]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24643) Koha::DateUtils::dt_from_string rfc3339 cannot handle high precision seconds

### Cataloging

- [[13574]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13574) Repeatable item subfields don't show correctly in MARC view (OPAC and staff)

### Circulation

- [[24514]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24514) Holds Awaiting Pickup sorting by title before surname

### Database

- [[24640]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24640) quotes.timestamp should default to NULL

  >This fixes a problem with the QOTD tool - you can now add and edit quotes again.

### Documentation

- [[21633]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21633) Did finesMode = test ever send email?

### MARC Authority data support

- [[24094]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24094) Authority punctuation mismatch prevents linking to correct records

### OPAC

- [[17221]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17221) Orphan comma in shelf browser

  **Sponsored by** *California College of the Arts*
- [[18933]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18933) Unable to set SMS number in OPAC messaging preferences to empty

  **Sponsored by** *Catalyst*
- [[23527]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23527) BakerTaylorBookstoreURL is converted to escaped characters by template, rendering it invalid
- [[24654]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24654) Trailing double-quote in RDA 264 subfield b on OPAC XSLT
- [[24676]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24676) opac-auth.tt contains trivial HTML error

### Patrons

- [[19791]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19791) Patron Modification log redirects to circulation page

### SIP2

- [[24449]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24449) SIP2 - too_many_overdue flag is not implemented

### Staff Client

- [[13305]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13305) Fix tab order in cataloguing/item editor
- [[24516]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24516) Column Configuration does not hide Return Date

  >This fixes an issue where hiding the return date column for the "Pay Fines" and "Account Fines" screens does not work.
- [[24649]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24649) Cloning item subfields misses a <li> tag

### Templates

- [[11281]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11281) Add column configuration to 'Holds awaiting pickup' tables allowing to print both tables separately
- [[24110]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24110) Template vars are incorrectly html filtered when dumped

### Test Suite

- [[22860]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22860) Selenium tests authentication.t does not remove all data it created
- [[24494]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24494) 00-valid-xml.t shouldn't check node_modules
- [[24590]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24590) Koha/Object.t is failing on MySQL 8
- [[24881]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24881) Circulation.t still fails if tests are ran slowly

### Tools

- [[22245]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22245) MARC modification templates does not allow move or copy control fields


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

- Arabic (99.2%)
- Armenian (100%)
- Basque (59.6%)
- Chinese (China) (60.2%)
- Chinese (Taiwan) (100%)
- Czech (92.8%)
- Danish (52.4%)
- English (New Zealand) (83.2%)
- English (USA)
- Finnish (79.4%)
- French (98.8%)
- French (Canada) (99.6%)
- German (99.9%)
- German (Switzerland) (86.2%)
- Greek (73.9%)
- Hindi (100%)
- Italian (90.4%)
- Norwegian Bokmål (89%)
- Occitan (post 1500) (56.3%)
- Polish (83.1%)
- Portuguese (99.9%)
- Portuguese (Brazil) (94.4%)
- Slovak (85.2%)
- Spanish (100%)
- Swedish (88.5%)
- Turkish (98.9%)
- Ukrainian (73.2%)
- Vietnamese (51.1%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 19.05.09 is


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

- Packaging Managers:
  - Mirko Tietgen
  - Mason James

- Documentation Managers:
  - Caroline Cyr La Rose
  - David Nind

- Documentation Team:
  - Donna Bachowski
  - Lucy Vaux-Harvey
  - Sugandha Bajaj

- Translation Managers: 
  - Bernardo González Kriegel

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
new features in Koha 19.05.09:

- California College of the Arts
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)

We thank the following individuals who contributed patches to Koha 19.05.09.

- Aleisha Amohia (1)
- Oliver Behnke (2)
- Nick Clemens (11)
- David Cook (2)
- Jonathan Druart (22)
- Katrin Fischer (2)
- Lucas Gass (5)
- Victor Grousset (1)
- Andrew Isherwood (2)
- Andreas Jonsson (1)
- Bernardo González Kriegel (1)
- David Kuhn (1)
- Owen Leonard (3)
- Josef Moravec (1)
- Eric Phetteplace (1)
- Marcel de Rooy (5)
- Koha Translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 19.05.09

- ACPL (3)
- aei.mpg.de (2)
- BSZ BW (2)
- ByWater-Solutions (16)
- Independant Individuals (4)
- Koha Community Developers (22)
- Kreablo AB (1)
- Prosentient Systems (2)
- PTFS-Europe (2)
- Rijks Museum (5)
- tuxayo.net (1)
- Universidad Nacional de Córdoba (1)

We also especially thank the following individuals who tested patches
for Koha.

- Aleisha Amohia (2)
- Donna Bachowski (1)
- Nick Clemens (8)
- David Cook (1)
- Holly Cooper (1)
- Jonathan Druart (12)
- Magnus Enger (2)
- Bouzid Fergani (1)
- Katrin Fischer (22)
- Andrew Fuerste-Henry (2)
- Lucas Gass (59)
- Sally Healey (1)
- Bernardo González Kriegel (6)
- Joonas Kylmälä (1)
- Owen Leonard (6)
- Hayley Mapley (2)
- Julian Maurice (1)
- Josef Moravec (3)
- Joy Nelson (54)
- David Nind (10)
- Martin Renvoize (56)
- Marcel de Rooy (5)
- Myka Kennedy Stephens (3)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is rmain1905.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 25 Mar 2020 16:04:04.
