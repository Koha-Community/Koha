# RELEASE NOTES FOR KOHA 19.05.17
23 Nov 2020

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 19.05.17 can be downloaded from:

- [Download](https://download.koha-community.org/koha-19.05.17.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 19.05.17 is a bugfix/maintenance release with security fixes.

It includes 1 security fixes, 15 bugfixes.

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


## Security bugs

### Koha

- [[26904]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26904) OPAC password recovery allows regexp in email




## Critical bugs fixed

### Acquisitions

- [[26496]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26496) Budget plan save button doesn't save plans

### Architecture, internals, and plumbing

- [[26639]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26639) Turn auto_savepoint ON

### Cataloging

- [[18051]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18051) Advanced Editor - Rancor - encoding issues with some sources

### Database

- [[18050]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18050) Missing constraint on aqbudgets.budget_period_id in aqbudgets

### Serials

- [[26604]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26604) "Generate next" button gives error on serials-collection.pl


## Other bugs fixed

### Architecture, internals, and plumbing

- [[26260]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26260) elasticsearch>cnx_pool missing in koha-conf-site.xml.in
- [[26569]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26569) Use gender-neutral pronouns in systempreference explanation field in DB

### Cataloging

- [[24780]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24780) 952$i stocknumber does not display in batch item modification
- [[26613]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26613) In the unimarc_framework.sql file in the it-IT translation there are wrong value fields for 995 r record

### Circulation

- [[26224]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26224) Prevent double submit of header checkin form

### Command-line Utilities

- [[26601]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26601) Add utf8 output to text output of overdue_notices.pl

  **Sponsored by** *Styrian State Library*

### Installation and upgrade (web-based installer)

- [[26612]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26612) Error during web install for it-IT translation

### MARC Authority data support

- [[26606]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26606) Correctly URI-encode query string in URL loaded after deleting an authority record

### Test Suite

- [[25665]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25665) test t/db_dependent/Circulation.t fails on a specific date
- [[26589]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26589) t/db_dependent/OAI/Sets.t unit test fails due to OAI-PMH:AutoUpdateSets syspref


## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha 
documentation is 

- [Koha Documentation](https://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](https://koha-community.org/manual/19.05/en/html/)


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
- Chinese (Taiwan) (99.3%)
- Czech (92.8%)
- Danish (52%)
- English (New Zealand) (82.7%)
- English (USA)
- Finnish (79%)
- French (99.1%)
- French (Canada) (98.9%)
- German (100%)
- German (Switzerland) (85.7%)
- Greek (73.7%)
- Hindi (100%)
- Italian (90.2%)
- Norwegian Bokmål (88.3%)
- Occitan (post 1500) (55.9%)
- Polish (82.7%)
- Portuguese (99.8%)
- Portuguese (Brazil) (94.1%)
- Slovak (86.5%)
- Spanish (99.9%)
- Swedish (87.8%)
- Turkish (100%)
- Ukrainian (73.7%)
- Vietnamese (50.8%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](https://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](https://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](https://translate.koha-community.org/)

## Release Team

The release team for Koha 19.05.17 is


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
We thank the following libraries who are known to have sponsored
new features in Koha 19.05.17:

- Styrian State Library

We thank the following individuals who contributed patches to Koha 19.05.17.

- Aleisha Amohia (2)
- Alex Buckley (1)
- Nick Clemens (2)
- David Cook (1)
- Jonathan Druart (2)
- John Fawcett (2)
- Katrin Fischer (4)
- Andrew Fuerste-Henry (1)
- Victor Grousset (3)
- Kyle M Hall (1)
- Mark Hofstetter (1)
- Mason James (1)
- Agustín Moyano (1)
- Martin Renvoize (2)
- Phil Ringnalda (1)
- Fridolin Somers (1)
- Koha Translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 19.05.17

- BibLibre (1)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (4)
- ByWater-Solutions (4)
- Catalyst (1)
- Chetco Community Public Library (1)
- hofstetter.at (1)
- Independant Individuals (2)
- Koha Community Developers (5)
- KohaAloha (1)
- Prosentient Systems (1)
- PTFS-Europe (2)
- Theke Solutions (1)
- voipsupport.it (2)

We also especially thank the following individuals who tested patches
for Koha.

- Aleisha Amohia (18)
- Tomás Cohen Arazi (1)
- Nick Clemens (1)
- Jonathan Druart (15)
- Katrin Fischer (11)
- Andrew Fuerste-Henry (2)
- Lucas Gass (18)
- Didier Gautheron (1)
- Victor Grousset (23)
- Sally Healey (1)
- Barbara Johnson (2)
- Julian Maurice (3)
- Kelly McElligott (1)
- David Nind (1)
- Martin Renvoize (7)
- Marcel de Rooy (1)



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

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 23 Nov 2020 15:09:23.
