# RELEASE NOTES FOR KOHA 17.11.14
22 janv. 2019

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 17.11.14 can be downloaded from:

- [Download](http://download.koha-community.org/koha-17.11.14.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 17.11.14 is a bugfix/maintenance release.

It includes 14 bugfixes.






## Critical bugs fixed

### Acquisitions

- [[21605]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21605) Cannot create EDI account

### Architecture, internals, and plumbing

- [[22052]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22052) DeleteExpiredOpacRegistrations should skip bad borrowers

### Cataloging

- [[21986]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21986) Quotation marks are wrongly escaped in several places

### Database

- [[21931]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21931) Upgrade from 3.22 fails when running updatedatabase.pl script

### MARC Authority data support

- [[21962]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21962) The `searching entire record` option in authority searches is currently failing

### Patrons

- [[21778]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21778) Sorting is inconsistent on patron search based on permissions


## Other bugs fixed

### Architecture, internals, and plumbing

- [[21848]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21848) Resolve unac_string warning from Circulation.t

### Command-line Utilities

- [[21908]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21908) biblio_metadata is missing from the rebuild_zebra.pl tables list

### Fines and fees

- [[21849]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21849) Offsets not stored correctly in _FixOverduesOnReturn

### MARC Bibliographic data support

- [[22034]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22034) Viewing record with Default framework doesn't work on MARC tab

### Notices

- [[21571]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21571) Translate notices fail on ACCTDETAILS

### Searching - Zebra

- [[22073]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22073) Diacritics Ž and ž not being mapped for searching (Non-ICU)

### Templates

- [[21990]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21990) No background color for div.error, must be .alert

### Test Suite

- [[14334]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14334) DBI fighting DBIx over Autocommit in tests



## System requirements

Important notes:
    
- Perl 5.10 is required
- Zebra is required

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://koha-community.org/manual/17.11/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (99.2%)
- Armenian (100%)
- Basque (75.1%)
- Chinese (China) (79.5%)
- Chinese (Taiwan) (99.4%)
- Czech (93.8%)
- Danish (65.5%)
- English (New Zealand) (99.1%)
- English (USA)
- Finnish (95.3%)
- French (98.6%)
- French (Canada) (91.8%)
- German (100%)
- German (Switzerland) (99.1%)
- Greek (82.8%)
- Hindi (100%)
- Italian (100%)
- Norwegian Bokmål (54.3%)
- Occitan (post 1500) (72.6%)
- Persian (54.7%)
- Polish (97.2%)
- Portuguese (100%)
- Portuguese (Brazil) (84.2%)
- Slovak (96.3%)
- Spanish (99.7%)
- Swedish (91.4%)
- Turkish (100%)
- Vietnamese (67.2%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 17.11.14 is

- Release Manager: [Nick Clemens](mailto:nick@bywatersolutions.com)
- Release Manager assistants:
  - [Jonathan Druart](mailto:jonathan.druart@bugs.koha-community.org)
  - [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
- QA Manager: [Katrin Fischer](mailto:Katrin.Fischer@bsz-bw.de)
- QA Team:
  - [Alex Arnaud](mailto:alex.arnaud@biblibre.com)
  - [Julian Maurice](mailto:julian.maurice@biblibre.com)
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
  - Josef Moravec
  - [Martin Renvoize](mailto:martin.renvoize@ptfs-europe.com)
  - [Jonathan Druart](mailto:jonathan.druart@bugs.koha-community.org)
  - [Marcel de Rooy](mailto:m.de.rooy@rijksmuseum.nl)
  - [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
  - [Chris Cormack](mailto:chrisc@catalyst.net.nz)
- Topic Experts:
  - SIP2 -- Colin Campbell
  - EDI -- Colin Campbell
  - Elasticsearch -- Ere Maijala
  - REST API -- Tomás Cohen Arazi
  - UI Design -- Owen Leonard
- Bug Wranglers:
  - Luis Moises Rojas
  - Jon Knight
  - [Indranil Das Gupta](mailto:indradg@l2c2.co.in)
- Packaging Manager: [Mirko Tietgen](mailto:mirko@abunchofthings.net)
- Documentation Manager: Caroline Cyr La Rose
- Documentation Team:
  - David Nind
  - Lucy Vaux-Harvey

- Translation Managers: 
  - [Indranil Das Gupta](mailto:indradg@l2c2.co.in)
  - [Bernardo Gonzalez Kriegel](mailto:bgkriegel@gmail.com)

- Wiki curators: 
  - Caroline Cyr La Rose
- Release Maintainers:
  - 18.11 -- [Martin Renvoize](mailto:martin.renvoize@ptfs-europe.com)
  - 18.05 -- Lucas Gass
  - 18.05 -- Jesse Maseto
  - 17.11 -- [Fridolin Somers](mailto:fridolin.somers@biblibre.com)
- Release Maintainer assistants:
  - 18.05 -- [Kyle Hall](mailto:kyle@bywatersolutions.com)

## Credits

We thank the following individuals who contributed patches to Koha 17.11.14.

- Colin Campbell (1)
- Nick Clemens (6)
- Jonathan Druart (6)
- Kyle Hall (2)
- Jesse Maseto (1)
- Julian Maurice (1)
- Marcel de Rooy (3)
- Fridolin Somers (6)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 17.11.14

- BibLibre (7)
- ByWater-Solutions (9)
- Koha Community Developers (6)
- PTFS-Europe (1)
- Rijks Museum (3)

We also especially thank the following individuals who tested patches
for Koha.

- Hugo Agud (1)
- Tomás Cohen Arazi (2)
- Alex Arnaud (2)
- Nick Clemens (21)
- Devinim (1)
- Jonathan Druart (4)
- Charles Farmer (2)
- Katrin Fischer (2)
- Lucas Gass (13)
- Kyle Hall (1)
- Jesse Maseto (7)
- Julian Maurice (3)
- Josef Moravec (3)
- Eric Phetteplace (1)
- Martin Renvoize (25)
- Marcel de Rooy (9)
- Fridolin Somers (22)
- Pierre-Marc Thibault (5)
- Nazlı Çetin (1)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 17.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 22 janv. 2019 09:44:01.
