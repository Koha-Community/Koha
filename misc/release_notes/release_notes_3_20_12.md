# RELEASE NOTES FOR KOHA 3.20.12
22 Jun 2016

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 3.20.12 can be downloaded from:

- [Download](http://download.koha-community.org/koha-3.20.12.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 3.20.12 is a securty and bugfix/maintenance release.

It includes 16 bugfixes.




## Critical bugs fixed

### Notices

- [[12752]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12752) OVERDUE notice mis-labeled as "Hold Available for Pickup"

### Templates

- [[14632]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14632) Incorrect alert while deleting single item in batch

### Tools

- [[16426]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16426) Import borrowers tool warns for blank and/or existing userids


## Other bugs fixed

### Acquisitions

- [[13041]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13041) Can't add user as manager of basket if name includes a single quote

### Cataloging

- [[15682]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15682) Merging records from cataloguing search only allows to merge 2 records

### OPAC

- [[16220]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16220) The view tabs on opac-detail.pl are not responsive
- [[16315]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16315) OPAC Shelfbrowser doesn't display the full title
- [[16597]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16597) Reflected XSS in [opac-]shelves and [opac-]shareshelf
- [[16599]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16599) XSS found in opac-shareshelf.pl

### Patrons

- [[12721]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12721) Prevent  software error if incorrect fieldnames given in sypref StatisticsFields

### Serials

- [[13877]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13877) seasonal predictions showing wrong in test

### Staff Client

- [[16709]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16709) [3.20.x] Bug 11038 is not applied correctly

### Templates

- [[15194]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15194) Drop-down menu 'Actions' has problem in 'Saved reports' page with language bottom bar
- [[16159]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16159) guarantor section missing ID on patron add form

### Test Suite

- [[14362]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14362) PEGI 15 Circulation/AgeRestrictionMarkers test fails
- [[16407]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16407) Fix Koha_borrower_modifications.t



## System requirements

Important notes:
    
- Perl 5.10 is required
- Zebra is required

## Documentation

The Koha manual is maintained in DocBook.The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://manual.koha-community.org//en/)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](http://git.koha-community.org/gitweb/?p=kohadocs.git;a=summary)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- English (USA)
- Arabic (99%)
- Armenian (99%)
- Chinese (China) (98%)
- Chinese (Taiwan) (97%)
- Czech (98%)
- Danish (81%)
- English (New Zealand) (99%)
- Finnish (99%)
- French (94%)
- French (Canada) (94%)
- German (100%)
- German (Switzerland) (99%)
- Greek (85%)
- Italian (100%)
- Korean (62%)
- Kurdish (59%)
- Norwegian Bokmål (60%)
- Occitan (95%)
- Persian (68%)
- Polish (100%)
- Portuguese (98%)
- Portuguese (Brazil) (97%)
- Slovak (99%)
- Spanish (100%)
- Swedish (88%)
- Turkish (100%)
- Vietnamese (84%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

for information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 3.20.12 is

- Release Manager: [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
- QA Manager: [Katrin Fischer](mailto:Katrin.Fischer@bsz-bw.de)
- QA Team:
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
  - [Jonathan Druart](mailto:jonathan.druart@biblibre.com)
  - [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
  - [Marcel de Rooy](mailto:m.de.rooy@rijksmuseum.nl)
  - [Nick Clemens](mailto:nick@bywatersolutions.com)
  - [Jesse Weaver](mailto:jweaver@bywatersolutions.com)
- Bug Wranglers:
  - [Amit Gupta](mailto:amitddng135@gmail.com)
  - [Magnus Enger](mailto:magnus@enger.priv.no)
  - [Mirko Tietgen](mailto:mirko@abunchofthings.net)
  - [Indranil Das Gupta](mailto:indradg@l2c2.co.in)
  - [Zeno Tajoli](mailto:z.tajoli@cineca.it)
  - [Marc Véron](mailto:veron@veron.ch)
- Packaging Manager: [Mirko Tietgen](mailto:mirko@abunchofthings.net)
- Documentation Manager: [Nicole C. Engard](mailto:nengard@gmail.com)
- Translation Manager: [Bernardo Gonzalez Kriegel](mailto:bgkriegel@gmail.com)
- Wiki curators: 
  - [Brook](mailto:)
  - [Thomas Dukleth](mailto:kohadevel@agogme.com)
- Release Maintainers:
  - 16.05 -- [Frédéric Demians](mailto:f.demians@tamil.fr)
  - 3.22 -- [Julian Maurice](mailto:julian.maurice@biblibre.com)
  - 3.20 -- [Chris Cormack](mailto:chrisc@catalyst.net.nz)

## Credits

We thank the following libraries who are known to have sponsored
new features in Koha 3.20.12:


We thank the following individuals who contributed patches to Koha 3.20.12.

- Alex Arnaud (2)
- Nick Clemens (2)
- Chris Cormack (6)
- Marcel de Rooy (1)
- Jonathan Druart (7)
- Owen Leonard (4)
- Julian Maurice (2)
- Mark Tompsett (2)
- Marc Véron (3)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 3.20.12

- ACPL (4)
- BibLibre (4)
- bugs.koha-community.org (7)
- ByWater-Solutions (2)
- Catalyst (6)
- Marc Véron AG (3)
- Rijksmuseum (1)
- unidentified (2)

We also especially thank the following individuals who tested patches
for Koha.

- Aleisha (2)
- Brendan Gallagher (17)
- Chris Cormack (32)
- Frédéric Demians (1)
- Jonathan Druart (10)
- Julian Maurice (23)
- Katrin Fischer (9)
- Marc Véron (3)
- Nick Clemens (4)
- Kyle M Hall (5)
- Bernardo Gonzalez Kriegel (3)
- Marcel de Rooy (4)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 3.20.x.
The last Koha release was 3.16.9, which was released on March 29, 2015.  

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 22 Jun 2016 22:08:45.
