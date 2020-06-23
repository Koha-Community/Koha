# RELEASE NOTES FOR KOHA 19.05.12
22 Jun 2020

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 19.05.12 can be downloaded from:

- [Download](http://download.koha-community.org/koha-19.05.12.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 19.05.12 is a bugfix/maintenance release.

It includes 1 enhancements, 30 bugfixes.

### System requirements

- **Debian 8 (Jessie) is not supported anymore**
- **MySQL 5.5 is not supported anymore**

Koha is tested against the following configurations and as such these are the recommendations for 
deployment: 

- Debian 9 (Stretch) with MariaDB 10.1 (MariaDB 10.3 support is experimental)
- Ubuntu 18.04 (Bionic) with MariaDB 10.1

Additional notes:
    
- Perl 5.24 or 5.26 are required
- Zebra or Elasticsearch is required




## Enhancements

### Test Suite

- [[23994]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23994) AdditionalFields.t is failing randomly (U18)


## Critical bugs fixed

### Acquisitions

- [[25473]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25473) Can't add order from MARC file, save button does nothing
- [[25563]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25563) Cannot submit "add order from MARC file" form after alert
- [[25677]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25677) Checkbox options for EDI accounts cannot be enabled

### Architecture, internals, and plumbing

- [[25634]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25634) koha-foreach exits too early if any command has non-zero status

### Circulation

- [[25184]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25184) Items with a negative notforloan status should not be captured for holds

  >**New system preference**: `TrapHoldsOnOrder` defaults to enabled.
- [[25531]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25531) Patron may not be debarred if backdated return

### Command-line Utilities

- [[25538]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25538) koha-shell should pass --login to sudo if no command

### Fines and fees

- [[25526]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25526) Using Write Off Selected will not allow for a different amount to be written off

### MARC Authority data support

- [[25653]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25653) Authorities search does not retain selection

### OPAC

- [[17842]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17842) Broken diacritics on records exported as MARC from cart
- [[25492]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25492) Your Account Menu button does nothing on mobile devices

### SIP2

- [[23403]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23403) SIP2 lends to wrong patron if cardnumber is missing

### Searching

- [[24458]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24458) Search results don't use Koha::Filter::MARC::ViewPolicy

### System Administration

- [[25617]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25617) Error on about page when TimeFormat preference is set to 12hr

### Tools

- [[25557]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25557) Column config table in acquisitions order does not match the acq table in baskets


## Other bugs fixed

### About

- [[25506]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25506) Perl undef warning on the "About Koha" page

### Acquisitions

- [[25507]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25507) PDF order print for German 2-pages is broken
- [[25545]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25545) Invoice page - Adjustments are not included in the Total + adjustments + shipment cost (Column tax. inc.)

### Architecture, internals, and plumbing

- [[25535]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25535) Hold API mapping maps cancellationdate to cancelation_date, but it should be cancellation_date

### Circulation

- [[24413]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24413) MarkLostItemsAsReturned functionality does not lift restrictions caused by long overdues

### I18N/L10N

- [[25517]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25517) Koha.mo not found on package installations / Translations not working

### MARC Authority data support

- [[25428]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25428) Escaped HTML shows in authority detail view when subfield is a link

### MARC Bibliographic data support

- [[25701]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25701) Facets display in random order

### OPAC

- [[24854]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24854) Remove IDreamBooks integration
- [[25597]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25597) Javascript errors in self-checkout printslip.pl preventing printing

### Patrons

- [[25452]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25452) Alternate email contact not displayed

### Staff Client

- [[25521]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25521) NewItemsDefaultLocation description should not mention cart_to_shelf.pl

### Test Suite

- [[23825]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23825) Object.t is failing - Exception not caught
- [[24062]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24062) Circulation tests fail randomly if patron category type is 'X'
- [[24881]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24881) Circulation.t still fails if tests are ran slowly


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

- Arabic (98.7%)
- Armenian (100%)
- Armenian (Classical) (99.9%)
- Basque (59.3%)
- Chinese (China) (59.8%)
- Chinese (Taiwan) (99.5%)
- Czech (92.8%)
- Danish (52.1%)
- English (New Zealand) (82.8%)
- English (USA)
- Finnish (79.1%)
- French (98.5%)
- French (Canada) (99.2%)
- German (100%)
- German (Switzerland) (85.8%)
- Greek (73.6%)
- Hindi (100%)
- Italian (90.2%)
- Norwegian Bokmål (88.5%)
- Occitan (post 1500) (56%)
- Polish (82.8%)
- Portuguese (99.9%)
- Portuguese (Brazil) (94.2%)
- Slovak (86.7%)
- Spanish (99.9%)
- Swedish (88%)
- Turkish (99.7%)
- Ukrainian (73.8%)
- Vietnamese (50.8%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 19.05.12 is


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

We thank the following individuals who contributed patches to Koha 19.05.12.

- Tomás Cohen Arazi (2)
- Nick Clemens (5)
- David Cook (3)
- Jonathan Druart (22)
- Katrin Fischer (2)
- Andrew Fuerste-Henry (1)
- Lucas Gass (2)
- Victor Grousset (3)
- Kyle Hall (3)
- Owen Leonard (3)
- Julian Maurice (1)
- Joy Nelson (1)
- Martin Renvoize (1)
- Marcel de Rooy (2)
- Slava Shishkin (1)
- Koha Translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 19.05.12

- Athens County Public Libraries (3)
- BibLibre (1)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (2)
- ByWater-Solutions (12)
- Independant Individuals (1)
- Koha Community Developers (25)
- Prosentient Systems (3)
- PTFS-Europe (1)
- Rijks Museum (2)
- Theke Solutions (2)

We also especially thank the following individuals who tested patches
for Koha.

- Aleisha Amohia (27)
- Tomás Cohen Arazi (3)
- Alex Arnaud (3)
- Nick Clemens (9)
- Holly Cooper (1)
- Jonathan Druart (14)
- Bouzid Fergani (1)
- Katrin Fischer (16)
- Andrew Fuerste-Henry (1)
- Lucas Gass (17)
- Claire Gravely (1)
- Victor Grousset (60)
- Kyle Hall (2)
- Bernardo González Kriegel (1)
- Julian Maurice (5)
- Joy Nelson (11)
- David Nind (4)
- Martin Renvoize (30)
- Marcel de Rooy (4)
- Andreas Roussos (1)



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

Autogenerated release notes updated last on 22 Jun 2020 23:44:46.
