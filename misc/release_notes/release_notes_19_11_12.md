# RELEASE NOTES FOR KOHA 19.11.12
24 Nov 2020

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 19.11.12 can be downloaded from:

- [Download](http://download.koha-community.org/koha-19.11.12.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 19.11.12 is a security and bugfix/maintenance release.

It includes 1 security fixes, 1 enhancements, 22 bugfixes.

### System requirements

Koha is continuously tested against the following configurations and as such these are the recommendations for 
deployment: 

- Debian Jessie with MySQL 5.5 (End of life)
- Debian Stretch with MariaDB 10.1
- Debian Buster with MariaDB 10.3
- Ubuntu Bionic with MariaDB 10.1 
- Debian Stretch with MySQL 8.0 (Experimental MySQL 8.0 support)

Additional notes:
    
- Perl 5.10 is required (5.24 is recommended)
- Zebra or Elasticsearch is required

## Koha security

- [[26904]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26904) OPAC password recovery allows regexp in email

## Enhancements

### OPAC

- [[25242]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25242) Accessibility: The 'Holdings' table partially obscures navigation links at 200% zoom


## Critical bugs fixed

### Acquisitions

- [[26496]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26496) Budget plan save button doesn't save plans

### Architecture, internals, and plumbing

- [[26639]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26639) Turn auto_savepoint ON

### Cataloging

- [[18051]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18051) Advanced Editor - Rancor - encoding issues with some sources

### Circulation

- [[25758]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25758) Items scheduled for automatic renewal do not show that they will not renew due to a hold

  >Bug 19014 prioritized the 'too soon' message for renewals to prevent sending too many notifications. When displaying information about the hold elsewhere it is desired to see the 'on hold' status even when the renewal is too soon.
  >
  >This patch add a switch to the CanBookBeRenewed routine to decide which status has priority (i.e. whether we are checking from the renewal cron or elsewhere)

### Database

- [[18050]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18050) Missing constraint on aqbudgets.budget_period_id in aqbudgets

### Hold requests

- [[26429]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26429) If a waiting hold has expired the expiration date on the holds page shows for tomorrow

### OPAC

- [[26973]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26973) extendedPatronAttributes not showing during selfregistration

### Plugin architecture

- [[25549]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25549) Broken plugins should not break Koha (Install plugin script/method should highlight broken plugins)

### Serials

- [[26604]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26604) "Generate next" button gives error on serials-collection.pl


## Other bugs fixed

### Acquisitions

- [[26190]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26190) Cannot close baskets when all lines have been cancelled
- [[26497]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26497) "Hide all columns" throws Javascript error on aqplan.pl

### Architecture, internals, and plumbing

- [[26569]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26569) Use gender-neutral pronouns in systempreference explanation field in DB

### Authentication

- [[26191]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26191) Relocate track_login call in Auth.pm (see 22543)

### Cataloging

- [[26605]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26605) Correctly URI-encode query string in call number browse plugin
- [[26613]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26613) In the unimarc_framework.sql file in the it-IT translation there are wrong value fields for 995 r record

### Command-line Utilities

- [[26601]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26601) Add utf8 output to text output of overdue_notices.pl

  **Sponsored by** *Styrian State Library*

### Installation and upgrade (web-based installer)

- [[26612]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26612) Error during web install for it-IT translation

### MARC Authority data support

- [[26606]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26606) Correctly URI-encode query string in URL loaded after deleting an authority record

### System Administration

- [[20804]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20804) Sanitize input of timeout syspref

### Templates

- [[26727]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26727) Fix <p/> appearing in the templates

### Test Suite

- [[26589]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26589) t/db_dependent/OAI/Sets.t unit test fails due to OAI-PMH:AutoUpdateSets syspref

### Tools

- [[8437]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8437) Large database backups and large exports from export.pl fail under plack


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

- Arabic (98.3%)
- Armenian (100%)
- Armenian (Classical) (100%)
- Basque (55.9%)
- Catalan; Valencian (50.7%)
- Chinese (China) (57.1%)
- Chinese (Taiwan) (98.8%)
- Czech (91%)
- English (New Zealand) (78.6%)
- English (USA)
- Finnish (74.5%)
- French (97.1%)
- French (Canada) (94.1%)
- German (100%)
- German (Switzerland) (81.1%)
- Greek (71.4%)
- Hindi (100%)
- Italian (87.3%)
- Nederlands-Nederland (Dutch-The Netherlands) (71.4%)
- Norwegian Bokmål (83.6%)
- Occitan (post 1500) (53.2%)
- Polish (78.7%)
- Portuguese (99.7%)
- Portuguese (Brazil) (99.7%)
- Slovak (83.3%)
- Spanish (100%)
- Swedish (85.3%)
- Telugu (93.5%)
- Turkish (100%)
- Ukrainian (74.7%)
- Vietnamese (51.7%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 19.11.12 is


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
new features in Koha 19.11.12:

- Styrian State Library

We thank the following individuals who contributed patches to Koha 19.11.12.

- Aleisha Amohia (6)
- Alex Buckley (1)
- Nick Clemens (4)
- David Cook (1)
- Jonathan Druart (4)
- John Fawcett (2)
- Katrin Fischer (5)
- Andrew Fuerste-Henry (1)
- Kyle Hall (1)
- Mark Hofstetter (1)
- Mason James (1)
- Owen Leonard (2)
- Agustín Moyano (1)
- Martin Renvoize (2)
- Phil Ringnalda (2)
- Marcel de Rooy (1)
- Fridolin Somers (1)
- Emmi Takkinen (1)
- Koha Translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 19.11.12

- Athens County Public Libraries (2)
- BibLibre (1)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (5)
- ByWater-Solutions (6)
- Catalyst (1)
- Chetco Community Public Library (2)
- hofstetter.at (1)
- Independant Individuals (7)
- Koha Community Developers (4)
- KohaAloha (1)
- Prosentient Systems (1)
- PTFS-Europe (2)
- Rijks Museum (1)
- Theke Solutions (1)
- voipsupport.it (2)

We also especially thank the following individuals who tested patches
for Koha.

- Aleisha Amohia (31)
- Tomás Cohen Arazi (1)
- Henry Bolshaw (1)
- Nick Clemens (2)
- David Cook (1)
- Chris Cormack (1)
- Jonathan Druart (25)
- Katrin Fischer (20)
- Lucas Gass (30)
- Didier Gautheron (1)
- Sally Healey (1)
- Barbara Johnson (2)
- Owen Leonard (1)
- Julian Maurice (3)
- Kelly McElligott (1)
- David Nind (3)
- Séverine Queune (1)
- Martin Renvoize (13)
- Alexis Ripetti (1)
- Marcel de Rooy (1)
- Timothy Alexis Vass (1)



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

Autogenerated release notes updated last on 24 Nov 2020 00:48:13.
