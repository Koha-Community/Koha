# RELEASE NOTES FOR KOHA 18.05.04
24 Sep 2018

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 18.05.04 can be downloaded from:

- [Download](http://download.koha-community.org/koha-18.05.04.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 18.05.04 is a bugfix/maintenance release.

It includes 1 new features, 3 enhancements, 27 bugfixes.



## New features

### REST api

- [[21116]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21116) Add API routes through plugins

## Enhancements

### Architecture, internals, and plumbing

- [[21202]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21202) C4::Items - Remove GetItemsByBiblioitemnumber

### REST api

- [[21334]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21334) Add bibliographic content type definitions

### Staff Client

- [[13406]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13406) Authority MARC display impossible to style via CSS


## Critical bugs fixed

### Circulation

- [[21231]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21231) BlockReturnofLostItems does not prevent lost items being found

### Patrons

- [[21068]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21068) Remove NorwegianPatronDB related code

### Templates

- [[13692]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13692) Series link is only using 800a instead of 800t

### Web services

- [[21199]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21199) Patron's attributes are displayed on GetPatronInfo's ILSDI output regardless opac_display


## Other bugs fixed

### About

- [[7143]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7143) Bug for tracking changes to the about page

### Acquisitions

- [[21288]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21288) Slowness in acquisition caused by GetInvoices
- [[21356]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21356) Missing space in parcel.tt

### Architecture, internals, and plumbing

- [[19991]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19991) use Modern::Perl in OPAC perl scripts
- [[21207]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21207) C4::Overdues::GetItems is not used

### Authentication

- [[13779]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13779) sessionID declared twice in C4::Auth::checkauth()

### Circulation

- [[21168]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21168) Error on circ/returns.pl after deleting checked-in item

### Database

- [[20777]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20777) Remove unused field accountlines.dispute

### Label/patron card printing

- [[20765]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20765) Search for items by acqdate does not work in label batch

### OPAC

- [[20994]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20994) Fix capitalization on OPAC result list "Save to Lists"
- [[21127]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21127) Remove jqTransform jQuery plugin from the OPAC

### Packaging

- [[21267]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21267) X_FORWARDED_PROTO header should be set in apache

### Patrons

- [[21096]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21096) Garbled username on intranet login page

### Staff Client

- [[21248]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21248) Fix COinS carp in MARC details page on unknown record

### System Administration

- [[19179]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19179) Email option for SMSSendDriver is not documented as a valid setting

### Templates

- [[21139]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21139) The floating toolbars have some issues
- [[21285]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21285) Select2 broken on high dpi screens

### Test Suite

- [[20776]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20776) Add Selenium::Remote::Driver to dependencies
- [[21262]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21262) Do not format numbers for editing if too big
- [[21355]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21355) GetDailyQuotes.t is fragile
- [[21360]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21360) IssueSlip.t is failing if run at 23:59

### Tools

- [[20564]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20564) Error 500 displays when uploading patron images with a zipped file

### Web services

- [[21235]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21235) Remove services_throttle if not required for ThingISBN



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

- [Koha Manual](http://koha-community.org/manual/18.05/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (100%)
- Armenian (100%)
- Basque (73.4%)
- Chinese (China) (77.9%)
- Chinese (Taiwan) (100%)
- Czech (93.3%)
- Danish (64.3%)
- English (New Zealand) (96.8%)
- English (USA)
- Finnish (93.6%)
- French (99.9%)
- French (Canada) (94.8%)
- German (100%)
- German (Switzerland) (99.7%)
- Greek (80.8%)
- Hindi (100%)
- Italian (98.1%)
- Norwegian Bokmål (66.4%)
- Occitan (post 1500) (71.1%)
- Persian (53.4%)
- Polish (94.8%)
- Portuguese (100%)
- Portuguese (Brazil) (83.8%)
- Slovak (95.6%)
- Spanish (100%)
- Swedish (94.9%)
- Turkish (100%)
- Vietnamese (65.8%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 18.05.04 is

- Release Manager: [Nick Clemens](mailto:nick@bywatersolutions.com)
- Release Manager assistants:
  - [Brendan Gallagher](mailto:brendan@bywatersolutions.com)
  - [Jonathan Druart](mailto:jonathan.druart@bugs.koha-community.org)
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
  - [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)

- Module Maintainers:
  - REST API -- [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
  - Elasticsearch -- [Nick Clemens](mailto:nick@bywatersolutions.com)
- QA Manager: [Katrin Fischer](mailto:Katrin.Fischer@bsz-bw.de)

- QA Team:
  - [Julian Maurice](mailto:julian.maurice@biblibre.com)
  - [Marcel de Rooy](mailto:m.de.rooy@rijksmuseum.nl)
  - Josef Moravec
  - [Alex Arnaud](mailto:alex.arnaud@biblibre.com)
  - [Martin Renvoize](mailto:martin.renvoize@ptfs-europe.com)
  - [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
  - [Jonathan Druart](mailto:jonathan.druart@bugs.koha-community.org)
  - [Chris Cormack](mailto:chrisc@catalyst.net.nz)
- Bug Wranglers:
  - Claire Gravely
  - Jon Knight
  - [Indranil Das Gupta](mailto:indradg@l2c2.co.inc)
  - [Amit Gupta](mailto:amitddng135@gmail.com)
- Packaging Manager: [Mirko Tietgen](mailto:mirko@abunchofthings.net)
- Documentation Team:
  - Lee Jamison
  - David Nind
  - Caroline Cyr La Rose
- Translation Manager: [Bernardo Gonzalez Kriegel](mailto:bgkriegel@gmail.com)
- Release Maintainers:
  - 18.05 -- [Martin Renvoize](mailto:martin.renvoize@ptfs-europe.com)
  - 17.11 -- [Fridolin Somers](mailto:fridolin.somers@biblibre.com)
  - 17.05 -- [Fridolin Somers](mailto:fridolin.somers@biblibre.com)

## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 18.05.04:


We thank the following individuals who contributed patches to Koha 18.05.04.

- Nick Clemens (7)
- Tomás Cohen Arazi (10)
- David Cook (1)
- Charlotte Cordwell (2)
- Caroline Cyr La Rose (1)
- Marcel de Rooy (2)
- Jonathan Druart (9)
- Katrin Fischer (1)
- Pasi Kallinen (2)
- Owen Leonard (2)
- Kyle M Hall (2)
- Martin Renvoize (9)
- Jane Sandberg (2)
- Fridolin Somers (1)
- Koha translators (2)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 18.05.04

- ACPL (2)
- BibLibre (2)
- BSZ BW (1)
- bugs.koha-community.org (9)
- ByWater-Solutions (7)
- bywatersolutiosn.com (2)
- joensuu.fi (2)
- linnbenton.edu (2)
- Prosentient Systems (1)
- PTFS-Europe (9)
- Rijksmuseum (2)
- Solutions inLibro inc (1)
- Theke Solutions (10)
- unidentified (2)

We also especially thank the following individuals who tested patches
for Koha.

- Alex Arnaud (2)
- 's avatarMarcel de Rooy (1)
- Christopher Brannon (1)
- Nick Clemens (43)
- Tomas Cohen Arazi (12)
- Chris Cormack (2)
- Michal Denar (1)
- Michal Denar (2)
- Marcel de Rooy (8)
- Jonathan Druart (12)
- Katrin Fischer (6)
- Brendan Gallagher (1)
- Pasi Kallinen (1)
- Ulrich Kleiber (1)
- Owen Leonard (2)
- Jesse Maseto (1)
- Kyle M Hall (1)
- Josef Moravec (4)
- Josef Moravec's avatarJosef Moravec (1)
- Wm. Nick Clemens's avatarNick Clemens (1)
- Martin Renvoize (55)
- Benjamin Rokseth (1)
- Jane Sandberg (2)
- Maryse Simard (2)
- Fridolin Somers (1)
- John Sterbenz (1)
- Mark Tompsett (8)
- George Williams (1)


We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 18.05.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 24 Sep 2018 13:10:19.
