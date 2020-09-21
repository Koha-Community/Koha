# RELEASE NOTES FOR KOHA 19.11.10
21 Sep 2020

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 19.11.10 can be downloaded from:

- [Download](http://download.koha-community.org/koha-19.11.10.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 19.11.10 is a security and bugfix/maintenance release.

It includes 1 security fixes, 1 enhancements, 35 bugfixes.

### System requirements

Koha is continiously tested against the following configurations and as such these are the recommendations for 
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

- [[26322]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26322) REST API plugin authorization is not checked anymore

## Enhancements

### OPAC

- [[26041]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26041) Accessibility: The date picker calendar is not keyboard accessible


## Critical bugs fixed

### Acquisitions

- [[25750]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25750) Fallback to ecost_tax_included, ecost_tax_excluded not happening when no 'Actual cost' entered

  **Sponsored by** *Horowhenua District Council, NZ*

### Architecture, internals, and plumbing

- [[26253]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26253) duplicated mana_config in etc/koha-conf.xml

### Circulation

- [[25783]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25783) Holds Queue treating item-level holds as bib-level
- [[26078]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26078) "Item returns to issuing library" creates infinite transfer loop

### Hold requests

- [[25786]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25786) Holds Queue building may target the wrong item for item level requests that match holds queue priority

### OPAC

- [[26069]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26069) Twitter share button leaks information to Twitter

### Packaging

- [[25792]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25792) Rename 'ttf-dejavu' package to 'fonts-dejavu' for Debian 11

### Reports

- [[26090]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26090) Catalog by itemtype report fails if SQL strict mode is on


## Other bugs fixed

### Acquisitions

- [[25751]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25751) When an ORDERED suggestion is edited, the status resets to "No status"

### Architecture, internals, and plumbing

- [[21539]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21539) addorderiso2709.pl forces librarian to select a ccode and notforloan code when using MarcItemFieldsToOrder
- [[26228]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26228) Update gulpfile to work with Node.js v12
- [[26270]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26270) XISBN.t is failing since today
- [[26331]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26331) svc/letters/preview is not executable which prevents CGI functioning

### Cataloging

- [[26233]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26233) Edit item date sort still does not sort correctly

### Circulation

- [[25584]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25584) When a 'return claim' is added, the button disappears, but the claim date doesn't show up
- [[25958]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25958) Allow LongOverdue cron to exclude specified lost values
- [[26076]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26076) Paying selected accountlines in full may result in the error "You must pay a value less than or equal to $x"
- [[26136]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26136) Prevent double submit of checkin form
- [[26361]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26361) JS error on returns.tt in 20.05
- [[26362]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26362) Overdue report shows incorrect branches for patron, holdingbranch, and homebranch

### Installation and upgrade (web-based installer)

- [[25448]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25448) Update German (de-DE) framework files

### OPAC

- [[26119]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26119) Patron attribute option to display in OPAC is not compatible with PatronSelfRegistrationVerifyByEmail
- [[26388]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26388) Renew all and Renew selected buttons should account for items that can't be renewed

### Packaging

- [[25778]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25778) koha-plack puts duplicate entries into PERL5LIB when multiple instances named

### REST API

- [[26271]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26271) Call to /api/v1/patrons/<patron_id>/account returns 500 error if manager_id is NULL

### Reports

- [[17801]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17801) 'Top Most-circulated items' gives wrong results when filtering by checkout date

### SIP2

- [[25903]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25903) Sending a SIP patron information request with a summary field flag in indexes 6-9 will crash server

### Searching

- [[17661]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17661) Differences in field ending (whitespace, punctuation) cause duplicate facets

### Searching - Elasticsearch

- [[26313]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26313) "Show analytics" and "Show volumes" links don't work with Elasticsearch and UseControlNumber

### Self checkout

- [[25791]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25791) SCO print dialog pops up twice

### System Administration

- [[25005]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25005) Admin Rights issue for Suggestion to Purchase

### Templates

- [[26213]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26213) Remove the use of jquery.checkboxes plugin when adding orders from MARC file
- [[26324]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26324) Spelling error resizeable vs resizable

### Test Suite

- [[24147]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24147) Objects.t is failing randomly

### Tools

- [[26236]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26236) log viewer does not translate the interface properly
## New sysprefs

- DefaultLongOverdueSkipLostStatuses

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
- French (95.3%)
- French (Canada) (94%)
- German (100%)
- German (Switzerland) (81.1%)
- Greek (70.5%)
- Hindi (100%)
- Italian (86.2%)
- Nederlands-Nederland (Dutch-The Netherlands) (53.5%)
- Norwegian Bokmål (83.6%)
- Occitan (post 1500) (53.2%)
- Polish (78.7%)
- Portuguese (99.7%)
- Portuguese (Brazil) (99.7%)
- Slovak (83.3%)
- Spanish (99.9%)
- Swedish (85.3%)
- Telugu (93.5%)
- Turkish (99.9%)
- Ukrainian (74.7%)
- Vietnamese (51.4%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 19.11.10 is


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
new features in Koha 19.11.10:

- Horowhenua District Council, NZ

We thank the following individuals who contributed patches to Koha 19.11.10.

- Aleisha Amohia (4)
- Tomás Cohen Arazi (6)
- Alex Buckley (1)
- Nick Clemens (8)
- David Cook (3)
- Jonathan Druart (11)
- Katrin Fischer (3)
- Andrew Fuerste-Henry (1)
- Lucas Gass (2)
- Kyle Hall (10)
- Mason James (1)
- Joonas Kylmälä (2)
- Owen Leonard (1)
- Martin Renvoize (1)
- Koha Translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 19.11.10

- Athens County Public Libraries (1)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (3)
- ByWater-Solutions (21)
- Catalyst (1)
- Independant Individuals (4)
- Koha Community Developers (11)
- KohaAloha (1)
- Prosentient Systems (3)
- PTFS-Europe (1)
- Theke Solutions (6)
- University of Helsinki (2)

We also especially thank the following individuals who tested patches
for Koha.

- Aleisha Amohia (50)
- Tomás Cohen Arazi (7)
- Nick Clemens (3)
- Rebecca Coert (1)
- Holly Cooper (1)
- Sarah Cornell (1)
- Jonathan Druart (38)
- Katrin Fischer (18)
- Andrew Fuerste-Henry (2)
- Daniel Gaghan (1)
- Jeff Gaines (1)
- Lucas Gass (39)
- Didier Gautheron (1)
- Amit Gupta (3)
- Kyle Hall (2)
- Sally Healey (3)
- Brandon J (1)
- Joonas Kylmälä (2)
- Owen Leonard (5)
- Kelly McElligott (3)
- Josef Moravec (1)
- Kim Peine (3)
- Martin Renvoize (13)
- David Roberts (1)
- Marcel de Rooy (1)
- Lisette Scheer (1)
- Fridolin Somers (6)
- Emmi Takkinen (1)



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

Autogenerated release notes updated last on 21 Sep 2020 23:08:52.
