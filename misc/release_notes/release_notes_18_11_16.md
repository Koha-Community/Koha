# RELEASE NOTES FOR KOHA 18.11.16
22 Apr 2020

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 18.11.16 can be downloaded from:

- [Download](http://download.koha-community.org/koha-18.11.16.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 18.11.16 is a bugfix/maintenance release.

It includes 1 new features, 16 bugfixes.

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



## Critical bugs fixed

### Authentication

- [[24673]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24673) CSRF vulnerability in opac-messaging.pl

### Command-line Utilities

- [[24527]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24527) misc/cronjobs/update_totalissues.pl problem with multiple items

### OPAC

- [[24711]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24711) Can't log in to OPAC after logout if OpacPublic disabled


## Other bugs fixed

### Acquisitions

- [[24733]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24733) Cannot search for duplicate orders using 'Basket created by' field

### Architecture, internals, and plumbing

- [[24809]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24809) OAI PMH can fail on fetching deleted records

### Command-line Utilities

- [[24324]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24324) delete_records_via_leader.pl cron error with item deletion

### Hold requests

- [[24688]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24688) Hold priority isn't adjusted correctly if checking out a middle priority hold

  **Sponsored by** *Chartered Accountants Australia and New Zealand*

### I18N/L10N

- [[24870]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24870) Translate installer data label

### Installation and upgrade (command-line installer)

- [[17464]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17464) Order deny,allow / Deny from all was deprecated in Apache 2.4 and is now a hard error

### OPAC

- [[23968]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23968) OPACMySummaryNote does not work
- [[24605]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24605) Series link from 830 is not uri encoded

### Staff Client

- [[24747]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24747) Library Transfer Limit page incorrectly describes its behavior
- [[24838]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24838) Help link from patron categories should go to relevant manual page

### Templates

- [[24798]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24798) smart-rules.tt has erroneous comments

### Test Suite

- [[24813]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24813) api/v1/holds.t is failing randomly

### Tools

- [[25020]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25020) Extending due dates to a specified date should preserve time portion of original due date


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

- Arabic (97.7%)
- Armenian (100%)
- Basque (65.8%)
- Chinese (China) (63.7%)
- Chinese (Taiwan) (98.9%)
- Czech (93.6%)
- Danish (55.1%)
- English (New Zealand) (87.8%)
- English (USA)
- Finnish (84%)
- French (99.8%)
- French (Canada) (98.6%)
- German (100%)
- German (Switzerland) (91.3%)
- Greek (78.5%)
- Hindi (100%)
- Italian (93.4%)
- Norwegian Bokmål (94.1%)
- Occitan (post 1500) (59.3%)
- Polish (86.2%)
- Portuguese (100%)
- Portuguese (Brazil) (87.1%)
- Slovak (91.4%)
- Spanish (100%)
- Swedish (89.9%)
- Tetun (53.6%)
- Turkish (100%)
- Ukrainian (61.8%)
- Vietnamese (54.3%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 18.11.16 is


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
new features in Koha 18.11.16:

- Chartered Accountants Australia and New Zealand

We thank the following individuals who contributed patches to Koha 18.11.16.

- Aleisha Amohia (1)
- Tomás Cohen Arazi (1)
- Nick Clemens (4)
- David Cook (1)
- Jonathan Druart (7)
- Katrin Fischer (1)
- Andrew Fuerste-Henry (2)
- Bernardo González Kriegel (1)
- Owen Leonard (1)
- Hayley Mapley (3)
- Liz Rea (1)
- Marcel de Rooy (2)
- Fridolin Somers (3)
- Koha Translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 18.11.16

- ACPL (1)
- Andrews-MacBook-Pro.local (1)
- BibLibre (3)
- BSZ BW (1)
- ByWater-Solutions (5)
- Catalyst (3)
- Independant Individuals (2)
- Koha Community Developers (7)
- Prosentient Systems (1)
- Rijks Museum (2)
- Theke Solutions (1)
- Universidad Nacional de Córdoba (1)

We also especially thank the following individuals who tested patches
for Koha.

- Tomás Cohen Arazi (2)
- Donna Bachowski (1)
- Michal Denar (1)
- Jonathan Druart (5)
- Katrin Fischer (10)
- Lucas Gass (21)
- Kyle Hall (2)
- Sally Healey (1)
- Bernardo González Kriegel (7)
- Hayley Mapley (24)
- Kelly McElligott (1)
- Joy Nelson (21)
- David Nind (4)
- Martin Renvoize (23)
- Marcel de Rooy (4)
- Emmi Takkinen (1)



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

Autogenerated release notes updated last on 22 Apr 2020 01:01:16.
