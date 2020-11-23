# RELEASE NOTES FOR KOHA 20.05.06
23 Nov 2020

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 20.05.06 can be downloaded from:

- [Download](http://download.koha-community.org/koha-20.05.06.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 20.05.06 is a bugfix/maintenance release.

It includes 3 enhancements, 73 bugfixes.

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




## Enhancements

### Architecture, internals, and plumbing

- [[26600]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26600) Missing module in Indexer.pm

### Fines and fees

- [[26506]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26506) Koha::Account::pay will fail if $userenv is not set

### Plugin architecture

- [[24633]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24633) Add support for gitlab searching of plugins

  **Sponsored by** *Theke Solutions*

  >The enhancement allows setting Gitlab targets for retrieving plugins.


## Critical bugs fixed

### Acquisitions

- [[26496]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26496) Budget plan save button doesn't save plans
- [[26738]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26738) Unable to change manager of purchase suggestion
- [[26908]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26908) EDI vendor accounts edit no longer allows plugins to be selected for an account

### Architecture, internals, and plumbing

- [[26639]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26639) Turn auto_savepoint ON
- [[26911]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26911) Update for 18936 can cause data loss if constraints are violated
- [[26963]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26963) Improve Koha::Item::pickup_locations performance

  >Koha::Item::pickup_locations is very inefficient, causing timeouts on records with large numbers of holds/items.
  >
  >This development refactors the underlying implementation, and also makes the method return a resultset, to delay as much as possible the DB access, and thus allowing for further filtering  on the callers, through chaining.

### Cataloging

- [[18051]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18051) Advanced Editor - Rancor - encoding issues with some sources
- [[26750]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26750) Deleted items are not removed from index

### Circulation

- [[25758]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25758) Items scheduled for automatic renewal do not show that they will not renew due to a hold

  >Bug 19014 prioritized the 'too soon' message for renewals to prevent sending too many notifications. When displaying information about the hold elsewhere it is desired to see the 'on hold' status even when the renewal is too soon.
  >
  >This patch add a switch to the CanBookBeRenewed routine to decide which status has priority (i.e. whether we are checking from the renewal cron or elsewhere)
- [[26232]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26232) undefined fine grace period kills koha

### Database

- [[18050]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18050) Missing constraint on aqbudgets.budget_period_id in aqbudgets

### Fines and fees

- [[26915]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26915) Koha explodes when writing off a fee with FinePaymentAutoPopup

### Hold requests

- [[26429]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26429) If a waiting hold has expired the expiration date on the holds page shows for tomorrow
- [[26900]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26900) Fixes Koka::Libraries typo in C4/Reserves.pm
- [[26990]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26990) No feedback if holds override is disabled and hold fails

### MARC Bibliographic record staging/import

- [[26853]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26853) Data lost due to "Data too long for column" errors during MARC import

### OPAC

- [[26973]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26973) extendedPatronAttributes not showing during selfregistration

### Plugin architecture

- [[25549]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25549) Broken plugins should not break Koha (Install plugin script/method should highlight broken plugins)
- [[26751]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26751) Fatal exception if only one repo defined

### Searching - Elasticsearch

- [[23828]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23828) Elasticsearch - ES - Authority record results not ordered correctly

### Searching - Zebra

- [[26581]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26581) Elasticsearch - Records can be indexed multiple times during returns

### Serials

- [[26604]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26604) "Generate next" button gives error on serials-collection.pl
- [[26987]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26987) No property notforloan for Koha::Serial::Item

### Staff Client

- [[23432]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23432) Stock rotation: cancelled transfer result in stockrotation failures

### Tools

- [[26557]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26557) Batch import fails when incoming records contain itemnumber


## Other bugs fixed

### Acquisitions

- [[26190]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26190) Cannot close baskets when all lines have been cancelled

### Architecture, internals, and plumbing

- [[26569]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26569) Use gender-neutral pronouns in systempreference explanation field in DB
- [[26673]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26673) Remove Perl shebangs from Perl modules

### Authentication

- [[26191]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26191) Relocate track_login call in Auth.pm (see 22543)

### Cataloging

- [[11460]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11460) Correction to default itemcallnumber system preference in UNIMARC
- [[17515]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17515) Advanced Editor - Rancor - Z39 sources not sorted properly
- [[25353]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25353) Correct eslint errors in additems.js
- [[26605]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26605) Correctly URI-encode query string in call number browse plugin
- [[26613]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26613) In the unimarc_framework.sql file in the it-IT translation there are wrong value fields for 995 r record

### Circulation

- [[26583]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26583) Unnecessary code in AddIssue
- [[26627]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26627) Print and confirming a hold can cause an infinite loop
- [[26675]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26675) Typo in line 341 of process_koc.pl

### Command-line Utilities

- [[26601]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26601) Add utf8 output to text output of overdue_notices.pl

  **Sponsored by** *Styrian State Library*

### Hold requests

- [[26762]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26762) OPAC hold template markup error

### Installation and upgrade (web-based installer)

- [[26612]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26612) Error during web install for it-IT translation

### MARC Authority data support

- [[26606]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26606) Correctly URI-encode query string in URL loaded after deleting an authority record

### MARC Bibliographic data support

- [[26018]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26018) Not all subfields for the following tags are in the same tab (or marked 'ignored')

### OPAC

- [[26184]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26184) Wrap 'items available for pick-up' note when placing a hold in the OPAC in a div element
- [[26389]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26389) OPAC renewal failure due to automatic renewal does not have a failure message
- [[26526]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26526) Use of checkout notes not clear in OPAC
- [[26619]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26619) Cart - The "Print" button is only translated when you are in "More details" mode
- [[26647]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26647) Add translation context to cancel hold button in OPAC
- [[26766]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26766) Don't show star rating in dialog when saving a checkout note

### Patrons

- [[26594]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26594) Patrons merge problem with restriction
- [[26686]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26686) Sorting for "Updated on" broken on patron's "Notices" tab

### Searching - Elasticsearch

- [[26487]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26487) Add all MARC flavours for not-onloan-count search field
- [[26832]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26832) Elasticsearch mappings export should use UTF-8

### Searching - Zebra

- [[26599]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26599) Unused parameter name in POD of ModZebra

### Staff Client

- [[26137]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26137) Warn on malformed param on log viewer (viewlog.pl)
- [[26445]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26445) Search results browser in staff has broken link back to results

### System Administration

- [[20804]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20804) Sanitize input of timeout syspref

### Templates

- [[26449]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26449) Small typo in web installer template
- [[26450]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26450) Typo in UNIMARC field 105 plugin template
- [[26538]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26538) Display cities list before input text
- [[26551]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26551) When importing a framework, the modal heading is too long and runs outside of the dialog
- [[26696]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26696) Make payment table has a display issue when credits exist
- [[26723]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26723) Improve link text on OverDriveAuthName system preference
- [[26725]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26725) Improve link text on Patron attributes administration page
- [[26726]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26726) Improve link text on Transport cost matrix page
- [[26727]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26727) Fix <p/> appearing in the templates
- [[26756]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26756) Fix quotes showing behind some system preference descriptions
- [[26816]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26816) Remove extra space before comma in staff results item list

### Test Suite

- [[26589]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26589) t/db_dependent/OAI/Sets.t unit test fails due to OAI-PMH:AutoUpdateSets syspref

### Tools

- [[8437]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8437) Large database backups and large exports from export.pl fail under plack
- [[9118]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9118) Show only sensible options when editing a unique holiday
- [[25167]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25167) Fix not for loan filter in inventory tool
- [[26781]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26781) Marc Modification Templates treat subfield 0 and no subfield set
- [[26784]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26784) Editing a MARC modification template is noisy


## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://koha-community.org/manual/20.05/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (99.1%)
- Armenian (100%)
- Armenian (Classical) (99.7%)
- Chinese (Taiwan) (94.2%)
- Czech (80.9%)
- English (New Zealand) (67%)
- English (USA)
- Finnish (70.8%)
- French (81.9%)
- French (Canada) (95.5%)
- German (100%)
- German (Switzerland) (74.8%)
- Greek (62.3%)
- Hindi (99.7%)
- Italian (100%)
- Norwegian Bokmål (71.4%)
- Polish (73.8%)
- Portuguese (87.3%)
- Portuguese (Brazil) (98.4%)
- Russian (57.7%)
- Slovak (90.1%)
- Spanish (99.9%)
- Swedish (77.8%)
- Telugu (89.9%)
- Turkish (96.7%)
- Ukrainian (66.4%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 20.05.06 is


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

- Packaging Manager: Mason James


- Documentation Managers:
  - Caroline Cyr La Rose
  - David Nind

- Documentation Team:
  - Donna Bachowski
  - Lucy Vaux-Harvey
  - Sugandha Bajaj

- Translation Manager: Bernardo González Kriegel


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
new features in Koha 20.05.06:

- Styrian State Library
- [Theke Solutions](https://theke.io/)

We thank the following individuals who contributed patches to Koha 20.05.06.

- Tomás Cohen Arazi (3)
- Blou (1)
- Alex Buckley (1)
- Nick Clemens (19)
- David Cook (4)
- Jonathan Druart (15)
- John Fawcett (2)
- Katrin Fischer (11)
- Andrew Fuerste-Henry (1)
- Lucas Gass (9)
- Didier Gautheron (3)
- Kyle Hall (5)
- Mark Hofstetter (1)
- Mason James (1)
- Owen Leonard (8)
- Matthias Meusburger (1)
- Agustín Moyano (1)
- Björn Nylen (1)
- Martin Renvoize (5)
- Phil Ringnalda (2)
- Tal Rogoff (3)
- Marcel de Rooy (3)
- Andreas Roussos (2)
- Lisette Scheer (1)
- Fridolin Somers (6)
- Emmi Takkinen (2)
- Koha Translators (1)
- Timothy Alexis Vass (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 20.05.06

- Athens County Public Libraries (8)
- BibLibre (10)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (11)
- ByWater-Solutions (34)
- cass.govt.nz (3)
- Catalyst (1)
- Chetco Community Public Library (2)
- Dataly Tech (2)
- hofstetter.at (1)
- Independant Individuals (2)
- Koha Community Developers (15)
- KohaAloha (1)
- Latah County Library District (1)
- Prosentient Systems (4)
- PTFS-Europe (5)
- Rijks Museum (3)
- Solutions inLibro inc (1)
- Theke Solutions (4)
- ub.lu.se (2)
- voipsupport.it (2)

We also especially thank the following individuals who tested patches
for Koha.

- Tomás Cohen Arazi (12)
- Bob Bennhoff (1)
- Christoper Brannon (2)
- Nick Clemens (16)
- David Cook (2)
- Chris Cormack (9)
- Jonathan Druart (85)
- Magnus Enger (2)
- Katrin Fischer (43)
- Andrew Fuerste-Henry (3)
- Lucas Gass (101)
- Didier Gautheron (1)
- Victor Grousset (1)
- Kyle Hall (6)
- Sally Healey (1)
- Heather Hernandez (2)
- B Johnson (1)
- Barbara Johnson (4)
- Joonas Kylmälä (4)
- Owen Leonard (5)
- Julian Maurice (5)
- kelly mcelligott (1)
- David Nind (25)
- Séverine Queune (6)
- Martin Renvoize (41)
- Marcel de Rooy (1)
- Fridolin Somers (1)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is rmain2005.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 23 Nov 2020 23:29:55.
