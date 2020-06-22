# RELEASE NOTES FOR KOHA 19.11.07
22 Jun 2020

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 19.11.07 can be downloaded from:

- [Download](http://download.koha-community.org/koha-19.11.07.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 19.11.07 is a bugfix/maintenance release.

It includes 2 enhancements, 48 bugfixes.

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

### Architecture, internals, and plumbing

- [[25045]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25045) Add a way to restrict anonymous access to public routes (OpacPublic behaviour)

  >This enhancement allows libraries to distinctly disable the OPAC but allow the public facing API's to be enabled.
  >
  >**New system preference**: `RESTPublicAnonymousRequests` defaults to enabled.

### REST API

- [[24909]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24909) Add unprivileged route to get a bibliographic record


## Critical bugs fixed

### Acquisitions

- [[14543]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14543) Order lines updated that have a tax rate not in gist will have tax rate set to 0!
- [[25473]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25473) Can't add order from MARC file, save button does nothing
- [[25563]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25563) Cannot submit "add order from MARC file" form after alert
- [[25677]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25677) Checkbox options for EDI accounts cannot be enabled

### Architecture, internals, and plumbing

- [[22522]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22522) API authentication breaks with updated Mojolicious version
- [[25567]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25567) borrower_attribute_types.category_code must be set to undef if not set
- [[25634]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25634) koha-foreach exits too early if any command has non-zero status
- [[25707]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25707) Mappings update in bug 11529 causes incorrect MARC to DB data flow

### Command-line Utilities

- [[25538]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25538) koha-shell should pass --login to sudo if no command

### Fines and fees

- [[25526]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25526) Using Write Off Selected will not allow for a different amount to be written off

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

### REST API

- [[24003]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24003) REST API should set C4::Context->userenv
- [[25411]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25411) Plugin routes cannot have anonymous access

  **Sponsored by** *ByWater Solutions*

### System Administration

- [[25601]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25601) Error when unsetting default checkout, hold and return policy for a specific library
- [[25617]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25617) Error on about page when TimeFormat preference is set to 12hr

### Tools

- [[25557]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25557) Column config table in acquisitions order does not match the acq table in baskets


## Other bugs fixed

### About

- [[25506]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25506) Perl undef warning on the "About Koha" page

### Acquisitions

- [[25507]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25507) PDF order print for German 2-pages is broken
- [[25545]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25545) Invoice page - Adjustments are not included in the Total + adjustments + shipment cost (Column tax. inc.)

### Circulation

- [[24413]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24413) MarkLostItemsAsReturned functionality does not lift restrictions caused by long overdues
- [[25587]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25587) JavaScript issue - "clear" button doesn't reset some dropdowns

### Command-line Utilities

- [[22470]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22470) Missing the table name on misc/migration_tools/switch_marc21_series_info.pl

### Documentation

- [[25576]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25576) ILL requests Help does not take you to the correct place in the manual

### I18N/L10N

- [[25517]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25517) Koha.mo not found on package installations / Translations not working

### MARC Authority data support

- [[25428]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25428) Escaped HTML shows in authority detail view when subfield is a link

### MARC Bibliographic data support

- [[25701]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25701) Facets display in random order

### Notices

- [[24612]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24612) expirationdate blank if patron has more than one item from bib on hold

### OPAC

- [[23276]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23276) Don't show tags on tag cloud when tagging is disabled
- [[25597]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25597) Javascript errors in self-checkout printslip.pl preventing printing

### Packaging

- [[25618]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25618) Upgrading Koha to packages made of latest master version breaks Z3950

### Patrons

- [[23808]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23808) Creating Child Guarantee doesn't populate Guarantor Information

  **Sponsored by** *South Taranaki District Council*
- [[25452]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25452) Alternate email contact not displayed

### REST API

- [[24862]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24862) Wrong behaviour on anonymous sessions

  **Sponsored by** *ByWater Solutions*
- [[25327]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25327) Cannot access API spec

### Serials

- [[25696]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25696) Test prediction pattern button is invalid HTML

### Staff Client

- [[25521]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25521) NewItemsDefaultLocation description should not mention cart_to_shelf.pl
- [[25537]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25537) Page reload at branchtransfers.pl loses destination branch

### System Administration

- [[25394]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25394) Cronjob path in the AuthorityMergeLimit syspref description is wrong
- [[25675]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25675) System preference PatronSelfRegistration incorrectly described

### Templates

- [[25615]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25615) Empty select in "Holds to pull" filters

### Test Suite

- [[24229]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24229) /items API tests fail on Ubuntu 18.04
- [[25623]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25623) Some tests in oauth.t do not roll back
## New sysprefs

- RESTPublicAnonymousRequests

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

- Arabic (98.4%)
- Armenian (100%)
- Armenian (Classical) (100%)
- Basque (56.1%)
- Chinese (China) (57.4%)
- Chinese (Taiwan) (99.2%)
- Czech (91.3%)
- English (New Zealand) (78.9%)
- English (USA)
- Finnish (74.8%)
- French (95.5%)
- French (Canada) (94.4%)
- German (100%)
- German (Switzerland) (81.4%)
- Greek (70.8%)
- Hindi (100%)
- Italian (86.4%)
- Norwegian Bokmål (84%)
- Occitan (post 1500) (53.5%)
- Polish (79%)
- Portuguese (100%)
- Portuguese (Brazil) (100%)
- Slovak (83.6%)
- Spanish (99.9%)
- Swedish (85.7%)
- Telugu (93.9%)
- Turkish (99.3%)
- Ukrainian (74.9%)
- Vietnamese (50.9%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 19.11.07 is


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
new features in Koha 19.11.07:

- [ByWater Solutions](https://bywatersolutions.com/)
- South Taranaki District Council

We thank the following individuals who contributed patches to Koha 19.11.07.

- Aleisha Amohia (4)
- Tomás Cohen Arazi (21)
- Alex Buckley (1)
- Nick Clemens (4)
- David Cook (4)
- Jonathan Druart (24)
- Katrin Fischer (2)
- Andrew Fuerste-Henry (2)
- Lucas Gass (1)
- Kyle Hall (4)
- Mason James (5)
- Owen Leonard (3)
- Ere Maijala (2)
- Julian Maurice (1)
- Martin Renvoize (4)
- David Roberts (1)
- Caroline Cyr La Rose (1)
- Slava Shishkin (1)
- Koha Translators (1)
- Petro Vashchuk (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 19.11.07

- Athens County Public Libraries (3)
- BibLibre (1)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (2)
- ByWater-Solutions (11)
- Catalyst (1)
- Independant Individuals (6)
- Koha Community Developers (24)
- KohaAloha (5)
- Prosentient Systems (4)
- PTFS-Europe (5)
- Solutions inLibro inc (1)
- Theke Solutions (21)
- University of Helsinki (2)

We also especially thank the following individuals who tested patches
for Koha.

- Aleisha Amohia (76)
- Tomás Cohen Arazi (7)
- Alex Arnaud (3)
- Donna Bachowski (1)
- Nick Clemens (10)
- David Cook (1)
- Holly Cooper (1)
- Jonathan Druart (43)
- Katrin Fischer (26)
- Andrew Fuerste-Henry (3)
- Lucas Gass (36)
- Claire Gravely (1)
- Victor Grousset (14)
- Kyle Hall (13)
- Bernardo González Kriegel (1)
- Joonas Kylmälä (1)
- Owen Leonard (1)
- Julian Maurice (7)
- David Nind (11)
- Martin Renvoize (40)
- Andreas Roussos (4)
- George Veranis (1)

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
line is 19.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 22 Jun 2020 21:54:15.
