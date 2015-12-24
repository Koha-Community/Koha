# RELEASE NOTES FOR KOHA 3.20.7
24 déc. 2015

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 3.20.7 can be downloaded from:

- [Download](http://download.koha-community.org/koha-3.20.07.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 3.20.7 is a bugfix/maintenance release.

It includes 20 bugfixes.

The Koha community dedicates its version 3.20.7 to the memory of 31-year old
Santu Mandal, Santu Mandal, an Indian who was a committed Koha user, as well
as a Koha translator into Bengali, passed away on December 15th. Our warmest
support goes to his fiancée, and to his parents.


## Critical bugs fixed

### Authentication

- [[5371]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=5371) Back-button in OPAC shows previous user's details, after logout

### Cataloging

- [[15256]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15256) Items table on detail page can be broken

### Circulation

- [[13024]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13024) Nonpublic note not appearing in the staff client

### Reports

- [[15250]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15250) Software error: Can't locate object method "field" via package "aqorders.datereceived" in reports/acquisitions_stats.pl
- [[15290]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15290) SQL reports encoding problem


## Other bugs fixed

### Acquisitions

- [[9184]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9184) Ordering from staged file in acq should not offer authority records
- [[15202]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15202) Fix date display when transferring an order

### Architecture, internals, and plumbing

- [[14978]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14978) issues.itemnumber should be a unique key
- [[15193]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15193) Perl scripts missing exec permission
- [[15270]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15270) Koha::Objects->find can exploded if searching for nonexistent record

### Circulation

- [[13838]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13838) Redirect to 'expired holds' tab after cancelling a hold
- [[14846]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14846) Items with no holdingbranch causes user's holds display to freeze
- [[15244]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15244) t/db_dependent/Reserves.t depends on external data/configuration

### OPAC

- [[11602]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11602) Fix localcover display
- [[14971]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14971) RIS only outputs the first 10 characters for either ISBN10 or ISBN13

### Patrons

- [[14599]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14599) Saved auth login and password are used in patron creation from

### Staff Client

- [[14349]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14349) Checkouts and Fines tabs missing category description on the left

### Templates

- [[11038]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11038) Enable use of IntranetUserCSS and intranetcolorstylesheet on staff client login page
- [[12152]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12152) Holds to pull report should show library and itype description instead of their codes
- [[15216]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15216) Display Branch names and itemtype descriptions on the returns page



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
- Armenian (100%)
- Czech (98%)
- Danish (83%)
- Finnish (87%)
- French (94%)
- German (100%)
- Italian (100%)
- Korean (63%)
- Kurdish (60%)
- Persian (70%)
- Polish (100%)
- Portuguese (99%)
- Slovak (100%)
- Spanish (99%)
- Swedish (89%)
- Turkish (100%)
- Vietnamese (85%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

for information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 3.20.7 is

- Release Manager: [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
- QA Manager: [Katrin Fischer](mailto:Katrin.Fischer@bsz-bw.de)
- QA Team:
  - [Marcel de Rooy](mailto:m.de.rooy@rijksmuseum.nl)
  - [Jesse Weaver](mailto:jweaver@bywatersolutions.com)
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
  - [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
  - [Paul Poulain](mailto:paul.poulain@biblibre.com)
  - [Jonathan Druart](mailto:jonathan.druart@biblibre.com)
- Bug Wranglers:
  - [Amit Gupta](mailto:amitddng135@gmail.com)
  - [Magnus Enger](mailto:magnus@enger.priv.no)
  - [Mirko Tietgen](mailto:mirko@abunchofthings.net)
  - [Indranil Das Gupta](mailto:indradg@l2c2.co.in)
  - [Zeno Tajoli](mailto:z.tajoli@cineca.it)
  - [Marc Véron](mailto:veron@veron.ch)
- Packaging Manager: [Galen Charlton](mailto:gmc@esilibrary.com)
- Documentation Manager: [Nicole C. Engard](mailto:nengard@gmail.com)
- Translation Manager: [Bernardo Gonzalez Kriegel](mailto:bgkriegel@gmail.com)
- Wiki curators: 
  - [Thomas Dukleth](mailto:kohadevel@agogme.com)
- Release Maintainers:
  - 3.22 -- [Julian Maurice](mailto:julian.maurice@biblibre.com)
  - 3.20 -- [Frédéric Demians](mailto:f.demians@tamil.fr)
  - 3.18 -- [Liz Rea](mailto:liz@catalyst.net.nz)
  - 3.16 -- [Mason James](mailto:mtj@kohaaloha.com)
  - 3.14 -- [Fridolin Somers](mailto:fridolin.somers@biblibre.com)

## Credits

We thank the following libraries who are known to have sponsored
new features in Koha 3.20.7:


We thank the following individuals who contributed patches to Koha 3.20.7.

- Blou (1)
- Hector Castro (1)
- Galen Charlton (1)
- Tomás Cohen Arazi (2)
- Frédéric Demians (3)
- Jonathan Druart (7)
- Katrin Fischer (7)
- Bernardo González Kriegel (2)
- Kyle M Hall (3)
- Fridolin Somers (2)
- Nicholas van Oudtshoorn (1)
- Marc Véron (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 3.20.7

- BibLibre (2)
- BSZ BW (7)
- bugs.koha-community.org (7)
- ByWater-Solutions (3)
- Marc Véron AG (1)
- Solutions inLibro inc (1)
- Tamil (3)
- Theke Solutions (2)
- unidentified (3)
- Universidad Nacional de Córdoba (2)

We also especially thank the following individuals who tested patches
for Koha.

- Brendan Gallagher (1)
- David Cook (1)
- Frédéric Demians (33)
- Galen Charlton (2)
- Hector Castro (3)
- Jonathan Druart (17)
- Julian Maurice (21)
- jvr (1)
- Katrin Fischer (9)
- Magnus Enger (2)
- Marc Véron (7)
- Nick Clemens (2)
- Owen Leonard (1)
- Tom Misilo (1)
- Tomas Cohen Arazi (4)
- Kyle M Hall (17)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 3.20.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

