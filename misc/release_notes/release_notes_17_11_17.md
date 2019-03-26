# RELEASE NOTES FOR KOHA 17.11.17
26 mars 2019

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 17.11.17 can be downloaded from:

- [Download](http://download.koha-community.org/koha-17.11.17.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 17.11.17 is a bugfix/maintenance release.

It includes 7 bugfixes.






## Critical bugs fixed

### Acquisitions

- [[18723]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18723) Dot not recognized as decimal separator on receive
- [[21587]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21587) Patrons to notify on receiving doesn't work on new order creation, only on modification

### Cataloging

- [[16251]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16251) Material type is not correctly set for Rancor 008 widget

### Label/patron card printing

- [[22429]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22429) Infinite loop in patron card printing

### Reports

- [[21560]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21560) Optimize ODS exports


## Other bugs fixed

### Command-line Utilities

- [[22323]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22323) Cronjob runreport.pl has a CSV encoding issue

### System Administration

- [[18143]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18143) Silence floody MARC framework export



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
- Chinese (China) (79.4%)
- Chinese (Taiwan) (99.4%)
- Czech (93.7%)
- Danish (65.4%)
- English (New Zealand) (99.1%)
- English (USA)
- Finnish (95.2%)
- French (99%)
- French (Canada) (91.7%)
- German (100%)
- German (Switzerland) (99%)
- Greek (82.9%)
- Hindi (100%)
- Italian (99.9%)
- Norwegian Bokmål (54.2%)
- Occitan (post 1500) (72.5%)
- Persian (54.6%)
- Polish (97.1%)
- Portuguese (100%)
- Portuguese (Brazil) (84.2%)
- Slovak (96.2%)
- Spanish (99.6%)
- Swedish (91.3%)
- Turkish (99.9%)
- Vietnamese (67.1%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 17.11.17 is

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

We thank the following individuals who contributed patches to Koha 17.11.17.

- David Cook (1)
- Julian Maurice (1)
- Jose-Mario Monteiro-Santos (1)
- Fridolin Somers (10)
- Mark Tompsett (2)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 17.11.17

- BibLibre (11)
- Independant Individuals (2)
- Prosentient Systems (1)
- Solutions inLibro inc (1)

We also especially thank the following individuals who tested patches
for Koha.

- Mikaël Olangcay Brisebois (1)
- Nick Clemens (11)
- Chris Cormack (1)
- Michal Denar (1)
- Katrin Fischer (2)
- Lucas Gass (11)
- Victor Grousset (1)
- Kyle Hall (2)
- Josef Moravec (1)
- David Nind (3)
- Martin Renvoize (17)
- Fridolin Somers (12)
- Pierre-Marc Thibault (2)



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

Autogenerated release notes updated last on 26 mars 2019 06:46:08.
