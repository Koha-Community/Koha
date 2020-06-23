# RELEASE NOTES FOR KOHA 20.05.01
23 Jun 2020

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 20.05.01 can be downloaded from:

- [Download](http://download.koha-community.org/koha-20.05.01.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 20.05.01 is a bugfix/maintenance release.

It includes 11 enhancements, 48 bugfixes.

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




## Enhancements

### Acquisitions

- [[25599]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25599) Allow use of cataloguing placeholders when ACQ framework is used creating new record (UseACQFrameworkForBiblioRecords)

### Architecture, internals, and plumbing

- [[25070]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25070) Include files to display address and contact must be refactored

### Command-line Utilities

- [[21591]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21591) Data inconsistencies - Item types and biblio level

### Hold requests

- [[25555]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25555) Holds Queue sorts patrons by firstname

### OPAC

- [[24405]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24405) Links in facets are styled differently than other links on the results page in OPAC

### Patrons

- [[10910]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10910) Add a warn when deleting a patron with pending suggestions

### Staff Client

- [[12093]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12093) Add CSS classes to item statuses in detail view

### Templates

- [[25363]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25363) Merge common.js with staff-global.js
- [[25593]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25593) Terminology: Fix "There is no order for this biblio." on catalog detail page
- [[25627]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25627) Move OPAC problem reports from administration to tools
- [[25687]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25687) Switch Y/N in EDI accounts table for Yes and No for better translatability


## Critical bugs fixed

### Acquisitions

- [[14543]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14543) Order lines updated that have a tax rate not in gist will have tax rate set to 0!
- [[25677]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25677) Checkbox options for EDI accounts cannot be enabled

### Architecture, internals, and plumbing

- [[25634]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25634) koha-foreach exits too early if any command has non-zero status
- [[25707]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25707) Mappings update in bug 11529 causes incorrect MARC to DB data flow

### Circulation

- [[25783]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25783) Holds Queue treating item-level holds as bib-level

### Command-line Utilities

- [[25538]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25538) koha-shell should pass --login to sudo if no command

### Fines and fees

- [[25526]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25526) Using Write Off Selected will not allow for a different amount to be written off

### Hold requests

- [[25786]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25786) Holds Queue building may target the wrong item for item level requests that match holds queue priority

### MARC Authority data support

- [[25653]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25653) Authorities search does not retain selection

### OPAC

- [[17842]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17842) Broken diacritics on records exported as MARC from cart
- [[25492]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25492) Your Account Menu button does nothing on mobile devices

### Packaging

- [[17084]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17084) Automatic debian/control updates (master)
- [[25591]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25591) Update list-deps for Debian 10 and Ubuntu 20.04
- [[25633]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25633) Update debian/control.ini file for 20.05 release cycle
- [[25693]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25693) Correct permissions must be set on logdir after an upgrade
- [[25828]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25828) Update cpanfile for 20.05 release cycle

### REST API

- [[24003]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24003) REST API should set C4::Context->userenv
- [[25774]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25774) REST API searches don't handle correctly utf8 characters

### System Administration

- [[25651]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25651) Modifying an authorised value make it disappear

### Templates

- [[25839]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25839) Typo patron.streetype in member-main-address-style.inc
- [[25842]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25842) Typo "streetype" in member-main-address-style.inc

### Tools

- [[25557]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25557) Column config table in acquisitions order does not match the acq table in baskets


## Other bugs fixed

### About

- [[25642]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25642) Technical notes are missing from the release

### Acquisitions

- [[25266]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25266) Not all vendors are listed in the filters on the late order claims page
- [[25507]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25507) PDF order print for German 2-pages is broken
- [[25545]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25545) Invoice page - Adjustments are not included in the Total + adjustments + shipment cost (Column tax. inc.)

### Circulation

- [[25587]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25587) JavaScript issue - "clear" button doesn't reset some dropdowns
- [[25658]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25658) Print icon sometimes obscures patron barcode

### Command-line Utilities

- [[22470]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22470) Missing the table name on misc/migration_tools/switch_marc21_series_info.pl

### Documentation

- [[25576]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25576) ILL requests Help does not take you to the correct place in the manual

### I18N/L10N

- [[25346]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25346) Only show warn about existing directory on installing translations when verbose is used

### MARC Bibliographic data support

- [[25701]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25701) Facets display in random order

### OPAC

- [[20783]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20783) Cannot embed some YouTube videos due to 403 errors
- [[23276]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23276) Don't show tags on tag cloud when tagging is disabled
- [[25434]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25434) When viewing cart on small screen sizes selections-toolbar is hidden
- [[25597]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25597) Javascript errors in self-checkout printslip.pl preventing printing

### Self checkout

- [[25349]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25349) Enter in the username field submits the login, instead of moving focus to the password field

### Serials

- [[25696]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25696) Test prediction pattern button is invalid HTML

### Staff Client

- [[25521]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25521) NewItemsDefaultLocation description should not mention cart_to_shelf.pl
- [[25537]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25537) Page reload at branchtransfers.pl loses destination branch

### System Administration

- [[25394]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25394) Cronjob path in the AuthorityMergeLimit syspref description is wrong
- [[25675]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25675) System preference PatronSelfRegistration incorrectly described

### Templates

- [[25582]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25582) Don't show OPAC problems entry on dashboard when there are no reports
- [[25615]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25615) Empty select in "Holds to pull" filters

### Test Suite

- [[25623]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25623) Some tests in oauth.t do not roll back
- [[25638]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25638) API related tests failing on comparing floats
- [[25641]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25641) Koha/XSLT/Base.t is failing on U20

### Z39.50 / SRU / OpenSearch Servers

- [[25702]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25702) Actions button on Search results from Z39.50 is displayed incorrectly


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

- Arabic (84.7%)
- Armenian (100%)
- Armenian (Classical) (99.7%)
- Chinese (Taiwan) (88.8%)
- Czech (81.3%)
- English (New Zealand) (68.1%)
- English (USA)
- Finnish (70.1%)
- French (90.2%)
- French (Canada) (100%)
- German (100%)
- German (Switzerland) (76%)
- Greek (60.9%)
- Hindi (100%)
- Italian (82.8%)
- Norwegian Bokmål (79.8%)
- Polish (78%)
- Portuguese (86.4%)
- Portuguese (Brazil) (100%)
- Slovak (72.5%)
- Spanish (99.9%)
- Swedish (79.1%)
- Telugu (91.2%)
- Turkish (91.4%)
- Ukrainian (71.6%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 20.05.01 is


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

We thank the following individuals who contributed patches to Koha 20.05.01.

- Tomás Cohen Arazi (9)
- Nick Clemens (4)
- David Cook (4)
- Jonathan Druart (34)
- Katrin Fischer (6)
- Andrew Fuerste-Henry (2)
- Lucas Gass (7)
- Kyle Hall (6)
- Mason James (5)
- Bernardo González Kriegel (1)
- Owen Leonard (9)
- Julian Maurice (2)
- Martin Renvoize (3)
- David Roberts (2)
- Caroline Cyr La Rose (1)
- Fridolin Somers (2)
- Koha Translators (1)
- Petro Vashchuk (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 20.05.01

- Athens County Public Libraries (9)
- BibLibre (4)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (6)
- ByWater-Solutions (19)
- Independant Individuals (1)
- Koha Community Developers (34)
- KohaAloha (5)
- Prosentient Systems (4)
- PTFS-Europe (5)
- Solutions inLibro inc (1)
- Theke Solutions (9)
- Universidad Nacional de Córdoba (1)

We also especially thank the following individuals who tested patches
for Koha.

- Tomás Cohen Arazi (13)
- Alex Arnaud (7)
- Donna Bachowski (2)
- Nick Clemens (3)
- David Cook (1)
- Holly Cooper (1)
- Jonathan Druart (64)
- Katrin Fischer (43)
- Andrew Fuerste-Henry (2)
- Lucas Gass (81)
- Claire Gravely (1)
- Victor Grousset (7)
- Kyle Hall (7)
- Sally Healey (1)
- Bernardo González Kriegel (1)
- Owen Leonard (2)
- Julian Maurice (5)
- Kelly McElligott (4)
- David Nind (13)
- Kim Peine (3)
- Martin Renvoize (21)
- Andreas Roussos (1)
- Jessica Zairo (1)

We thank the following individuals who mentored new contributors to the Koha project.

- Andrew Nugged


We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 20.05.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 23 Jun 2020 14:33:49.
