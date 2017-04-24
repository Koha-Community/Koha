# RELEASE NOTES FOR KOHA 3.22.20
24 Apr 2017

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 3.22.20 can be downloaded from:

- [Download](http://download.koha-community.org/koha-3.22.20.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 3.22.20 is a bugfix/maintenance release with security fixes.

It includes 1 security fixes, 15 bugfixes.


## Security bugs

### Koha

- [[18349]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18349) Possibility to checkout/renew bypassing the circ rules using SCO




## Critical bugs fixed

### Circulation

- [[18022]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18022) Empty barcode causes internal server error
- [[18266]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18266) Internal Server Error when paying fine for lost item

### Tools

- [[12913]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12913) Fix wrong inventory results


## Other bugs fixed

### Acquisitions

- [[14535]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14535) Late orders does not show orders with price = 0
- [[17872]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17872) Fix small error in GetBudgetHierarchy and one of its calls

### Circulation

- [[12972]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12972) Transfer slip and transfer message (blue box) can conflict
- [[17309]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17309) Renewing and HomeOrHoldingBranch syspref

### Command-line Utilities

- [[18058]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18058) 'borrowers-force-messaging-defaults --doit --truncate ' gives DBI error

### Installation and upgrade (web-based installer)

- [[12930]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12930) Web installer does not show login errors

### Label/patron card printing

- [[18209]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18209) Patron's card manage.pl page is not fully translatable
- [[18244]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18244) Patron card creator does not take in account fields with underscore (B_address etc.)

### Notices

- [[17995]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17995) HOLDPLACED notice should have access to the reserves table

### OPAC

- [[17945]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17945) Breadcrumbs broken on opac-serial-issues.pl

### Patrons

- [[18263]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18263) Make use of syspref 'CurrencyFormat' for Account and Pay fines tables

### Serials

- [[7728]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7728) Fixing subscription endddate inconsistency: should be empty when the subscription is running



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
- Arabic (98%)
- Armenian (99%)
- Chinese (China) (93%)
- Chinese (Taiwan) (97%)
- Czech (97%)
- Danish (76%)
- English (New Zealand) (97%)
- Finnish (99%)
- French (99%)
- French (Canada) (91%)
- German (100%)
- German (Switzerland) (99%)
- Greek (80%)
- Hindi (99%)
- Italian (100%)
- Korean (57%)
- Kurdish (54%)
- Norwegian Bokmål (63%)
- Occitan (94%)
- Persian (64%)
- Polish (100%)
- Portuguese (99%)
- Portuguese (Brazil) (94%)
- Slovak (99%)
- Spanish (100%)
- Swedish (94%)
- Turkish (100%)
- Vietnamese (78%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

for information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 3.22.20 is

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
new features in Koha 3.22.20:


We thank the following individuals who contributed patches to Koha 3.22.20.

- Blou (1)
- Alex Buckley (1)
- Nick Clemens (2)
- Jonathan Druart (8)
- Luke Honiss (1)
- David Kuhn (1)
- Paul Poulain (1)
- Fridolin Somers (1)
- Marc Véron (2)
- Marcel de Rooy (6)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 3.22.20

- BibLibre (2)
- bugs.koha-community.org (8)
- ByWater-Solutions (2)
- Catalyst (1)
- Marc Véron AG (2)
- Rijksmuseum (6)
- Solutions inLibro inc (1)
- unidentified (2)

We also especially thank the following individuals who tested patches
for Koha.

- Christopher Brannon (1)
- Cédric Vita (1)
- Jonathan Druart (10)
- Josef Moravec (1)
- Julian Maurice (24)
- Katrin Fischer (22)
- Marc Véron (5)
- Mark Tompsett (1)
- Mirko Tietgen (1)
- Nick Clemens (6)
- Sonia BOUIS (1)
- Srdjan (2)
- beroud (1)
- Brendan A Gallagher (1)
- Kyle M Hall (21)
- Marcel de Rooy (9)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 3.22.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 24 Apr 2017 07:22:04.
