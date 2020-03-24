# RELEASE NOTES FOR KOHA 19.11.04
24 Mar 2020

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 19.11.04 can be downloaded from:

- [Download](http://download.koha-community.org/koha-19.11.04.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 19.11.04 is a bugfix/maintenance release.

It includes 1 new features, 6 enhancements, 44 bugfixes.

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

## Enhancements

### Architecture, internals, and plumbing

- [[24642]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24642) Cache::Memcached::Fast::Safe must be marked as mandatory

### Cataloging

- [[18499]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18499) 'Call Number Browser' on edit items screen uses the default classification source rather than the item specific source

### I18N/L10N

- [[21156]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21156) Internationalization: plural forms, context, and more for JS files
- [[24664]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24664) Add missing *-messages-js.po

### Templates

- [[24619]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24619) Phase out jquery.cookie.js: MARC Frameworks
- [[24621]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24621) Phase out jquery.cookie.js: Basic MARC editor


## Critical bugs fixed

### Acquisitions

- [[24389]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24389) Claiming an order can display an invalid successful message

### Architecture, internals, and plumbing

- [[13193]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13193) Make Memcached usage fork safe

  **Sponsored by** *National Library of Finland*

  >*Important Note*: You will need to make sure you install `Cache::Memcached::Fast::Safe` to continue to use memcached after this.
- [[24727]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24727) Typo in circulation.js

### Authentication

- [[16719]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16719) LDAP: Using empty strings as 'failsafe' attribute mapping defeats database constraints

### Cataloging

- [[13420]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13420) Holdings table sorting on volume information incorrect

### Fines and fees

- [[24532]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24532) Some account types are converted to debits when they shouldn't be

### Hold requests

- [[21944]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21944) Fix waiting holds at wrong location bug
- [[24410]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24410) Multi holds broken

### OPAC

- [[17896]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17896) BakerTaylorEnabled is not plack safe in the OPAC

### SIP2

- [[23640]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23640) L1 cache too long in SIP Server

### Searching - Elasticsearch

- [[24269]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24269) Authority matching in Elasticsearch is broken when authority has subdivisions
- [[24506]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24506) Multibranch limit does not work with ElasticSearch


## Other bugs fixed

### Acquisitions

- [[5016]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=5016) Fix some terminology and wording issues on English PDF order templates

### Architecture, internals, and plumbing

- [[20882]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20882) URI column in the items table is limited to 255 characters
- [[24051]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24051) batchMod.pl: DBIx::Class::ResultSet::search_rs(): search( %condition ) is deprecated
- [[24388]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24388) Useless test in acqui/lateorders.tt
- [[24538]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24538) REMOTE_USER set to undef if koha_trusted_proxies contains invalid value
- [[24643]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24643) Koha::DateUtils::dt_from_string rfc3339 cannot handle high precision seconds
- [[24725]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24725) xgettext does not support (yet) ES template literals

### Cataloging

- [[13574]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13574) Repeatable item subfields don't show correctly in MARC view (OPAC and staff)

### Circulation

- [[24514]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24514) Holds Awaiting Pickup sorting by title before surname

### Database

- [[24640]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24640) quotes.timestamp should default to NULL

  >This fixes a problem with the QOTD tool - you can now add and edit quotes again.

### Documentation

- [[21633]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21633) Did finesMode = test ever send email?

### Fines and fees

- [[22359]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22359) Improve usability of 'change calculation' (bug 11373)

### I18N/L10N

- [[24661]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24661) Inclusion of locale-related javascript files is broken
- [[24734]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24734) LangInstaller is looking in wrong directory for js files

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
- [[24666]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24666) Non Koha Guarantors should be able to be seen from the Patron Detail page

### Serials

- [[24677]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24677) [19.11] Wrong year picked in serials

### Staff Client

- [[13305]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13305) Fix tab order in cataloguing/item editor
- [[24516]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24516) Column Configuration does not hide Return Date

  >This fixes an issue where hiding the return date column for the "Pay Fines" and "Account Fines" screens does not work.
- [[24549]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24549) Cookies for last patron link are always set - even if showLastPatron is turned off
- [[24649]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24649) Cloning item subfields misses a <li> tag

### Templates

- [[11281]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11281) Add column configuration to 'Holds awaiting pickup' tables allowing to print both tables separately
- [[24110]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24110) Template vars are incorrectly html filtered when dumped

### Test Suite

- [[22860]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22860) Selenium tests authentication.t does not remove all data it created
- [[24494]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24494) 00-valid-xml.t shouldn't check node_modules

### Tools

- [[22245]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22245) MARC modification templates does not allow move or copy control fields


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

- Arabic (99.2%)
- Armenian (99.9%)
- Basque (56.6%)
- Chinese (China) (57.2%)
- Chinese (Taiwan) (100%)
- Czech (91.9%)
- English (New Zealand) (79.5%)
- English (USA)
- Finnish (75.4%)
- French (95.4%)
- French (Canada) (95.1%)
- German (100%)
- German (Switzerland) (82%)
- Greek (71%)
- Hindi (100%)
- Italian (87%)
- Norwegian Bokmål (84.6%)
- Occitan (post 1500) (53.9%)
- Polish (78.8%)
- Portuguese (99.9%)
- Portuguese (Brazil) (90.1%)
- Slovak (80.6%)
- Spanish (100%)
- Swedish (85.9%)
- Turkish (99.6%)
- Ukrainian (71.7%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 19.11.04 is


- Release Manager: Martin Renvoize

- Release Manager assistants:
  - Jonathan Druart
  - Tomas Cohen Arazi

- QA Manager: Katrin Fischer

- QA Team:
  - Tomás Cohen Arazi
  - Nick Clemens
  - Joonas Kylmälä
  - Jonathan Druart
  - Kyle Hall
  - Josef Moravec
  - Marcel de Rooy

- Topic Experts:
  - REST API -- Tomás Cohen Arazi
  - SIP2 -- Colin Campbell
  - UI Design -- Owen Leonard
  - Elasticsearch -- Fridolin Somers
  - ILS-DI -- Arthur Suzuki

- Bug Wranglers:
  - Michal Denár
  - Lisette Scheer
  - Cori Lynn Arnold
  - Ami Gupta

- Packaging Manager: Mason James

- Documentation Manager: Caroline Cyr La Rose and David Nind

- Documentation Team:
  - Donna Bachowski
  - Caroline Cyr La Rose
  - Lucy Vaux-Harvey
  - Sugandha Bajaj
  - David Nind

- Translation Managers: 
  - Bernardo González Kriegel

- Release Maintainers:
  - 19.11 -- Joy Nelson
  - 19.05 -- Lucas Gass
  - 18.11 -- Hayley Mapley
## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 19.11.04:

- California College of the Arts
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)
- National Library of Finland

We thank the following individuals who contributed patches to Koha 19.11.04.

- Aleisha Amohia (1)
- Oliver Behnke (2)
- Christopher Brannon (2)
- Nick Clemens (11)
- David Cook (4)
- Jonathan Druart (28)
- Katrin Fischer (4)
- Victor Grouseet (1)
- Kyle Hall (1)
- Andrew Isherwood (2)
- Mason James (1)
- Andreas Jonsson (1)
- Bernardo González Kriegel (1)
- David Kuhn (1)
- Joonas Kylmälä (1)
- Owen Leonard (3)
- Julian Maurice (3)
- Josef Moravec (1)
- Joy Nelson (6)
- Eric Phetteplace (1)
- Martin Renvoize (8)
- Marcel de Rooy (5)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 19.11.04

- ACPL (3)
- aei.mpg.de (2)
- BibLibre (3)
- BSZ BW (4)
- ByWater-Solutions (18)
- Coeur D'Alene Public Library (2)
- Independant Individuals (4)
- Koha Community Developers (28)
- KohaAloha (1)
- Kreablo AB (1)
- Prosentient Systems (4)
- PTFS-Europe (10)
- Rijks Museum (5)
- tuxayo.net (1)
- Universidad Nacional de Córdoba (1)
- University of Helsinki (1)

We also especially thank the following individuals who tested patches
for Koha.

- Aleisha Amohia (2)
- Donna Bachowski (1)
- Nick Clemens (10)
- David Cook (2)
- Holly Cooper (1)
- Michal Denar (1)
- Jonathan Druart (15)
- Magnus Enger (2)
- Bouzid Fergani (2)
- Katrin Fischer (27)
- Andrew Fuerste-Henry (3)
- Kyle Hall (10)
- Sally Healey (1)
- Janusz Kaczmarek (1)
- Bernardo González Kriegel (8)
- Joonas Kylmälä (1)
- Owen Leonard (7)
- Hayley Mapley (2)
- Julian Maurice (3)
- Josef Moravec (3)
- Agustín Moyano (1)
- Joy Nelson (87)
- David Nind (10)
- Martin Renvoize (92)
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
line is 19.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 24 Mar 2020 18:44:56.
