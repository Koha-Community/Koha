# RELEASE NOTES FOR KOHA 16.11.04
22 Feb 2017

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 16.11.04 can be downloaded from:

- [Download](http://download.koha-community.org/koha-16.11.04.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 16.11.04 is a bugfix/maintenance release.

It includes 3 enhancements, 41 bugfixes.




## Enhancements

### Architecture, internals, and plumbing

- [[17461]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17461) Make plugins-home.pl complain about plugins that can not be loaded

### Installation and upgrade (command-line installer)

- [[7533]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7533) Add template_cache_dir to the koha-conf.xml file

### Test Suite

- [[17950]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17950) Small improvements for Merge.t


## Critical bugs fixed

### Authentication

- [[17775]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17775) Add new user with LDAP not works under Plack

### Cataloging

- [[17922]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17922) Default value substitution for month and day should be fixed length

### Circulation

- [[8361]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8361) Issuing rule if no rule is defined
- [[16387]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16387) Incorrect loan period calculation when using  decreaseLoanHighHolds feature

### Hold requests

- [[17940]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17940) Holds not going to waiting state after having been transferred
- [[18015]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18015) On shelf holds allowed > "If all unavailable" ignores notforloan

### Label/patron card printing

- [[18044]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18044) Label Batches not displaying

### OPAC

- [[18025]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18025) Expired password recovery links cause sql crash

### Patrons

- [[17782]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17782) Patron updated_on field should be set to current timestamp when borrower is deleted

### Serials

- [[15030]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15030) Certain values in serials' items are lost on next edit

### System Administration

- [[18111]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18111) Import default framework is broken

### Z39.50 / SRU / OpenSearch Servers

- [[17871]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17871) Can't retrieve facets (or zebra::snippet) from Zebra with YAZ 5.8.1


## Other bugs fixed

### Acquisitions

- [[16984]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16984) Standing orders - when ordering a JS error is raised

### Architecture, internals, and plumbing

- [[17726]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17726) TestBuilder's refactoring removed default values
- [[17731]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17731) Remove the noxml option from rebuild_zebra.pl
- [[18089]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18089) All XSLT testing singleBranchMode = 0 fails to show even if install has only 1 branch
- [[18136]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18136) Content of ExportRemoveFields is not picked to pre-fill field list

### Cataloging

- [[17512]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17512) Improve handling dates in C4::Items
- [[17780]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17780) When choose an author in authority results new window shows a blank screen
- [[17988]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17988) Select2 prevents correct tag expand/minimize functionality
- [[18119]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18119) Bug 17988 broke cataloging javascript functionality

### Hold requests

- [[11450]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11450) Hold Request Confirm Deletion
- [[18076]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18076) Error when placing a hold and holds per record is set to 999

### Lists

- [[15584]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15584) Staff client list errors are incorrectly styled
- [[17852]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17852) Multiple URLs (856) in list email are broken

### MARC Authority data support

- [[17913]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17913) Merge three authority merge fixes

### MARC Bibliographic data support

- [[4126]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=4126) bulkmarcimport.pl allows -b and -a to be specified simultaneously
- [[17788]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17788) (MARC21) $9 fields not indexed in authority-linked fields

### OPAC

- [[17823]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17823) XSLT: Add label for MARC 583 - Action note

### Reports

- [[8306]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8306) Patron stats, patron activity : no active doesn't work

### Searching

- [[16115]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16115) JavaScript error on item search form unless NOT_LOAN defined
- [[17134]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17134) Facet's area shows itemtypes' code instead of item's description
- [[17838]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17838) Availability limit broken until an item has been checked out
- [[18047]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18047) JavaScript error on item search form unless LOC defined
- [[18068]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18068) ES: Location and (home|holding)branch facets mixed

### Serials

- [[17865]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17865) If a subscription has no history end date, it shows as expired today in OPAC

### Staff Client

- [[18026]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18026) URL to database columns link in system preferences is incorrect

### Test Suite

- [[18009]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18009) IssueSlip.t test fails if launched between 00:00 and 00:59
- [[18045]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18045) Reserves.t can fail because of caching issues

### Tools

- [[18095]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18095) Batch item modification: Better message if no item is modified

### Z39.50 / SRU / OpenSearch Servers

- [[17487]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17487) Improper placement of select/clear all in Z39.50/SRU search dialog

## New sysprefs

- AuthorityMergeMode

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
- Armenian (93%)
- Chinese (China) (86%)
- Chinese (Taiwan) (100%)
- Czech (96%)
- Danish (72%)
- English (New Zealand) (94%)
- Finnish (100%)
- French (98%)
- French (Canada) (92%)
- German (100%)
- German (Switzerland) (100%)
- Greek (78%)
- Hindi (100%)
- Italian (99%)
- Korean (52%)
- Kurdish (51%)
- Norwegian Bokmål (57%)
- Occitan (79%)
- Persian (59%)
- Polish (99%)
- Portuguese (99%)
- Portuguese (Brazil) (87%)
- Slovak (93%)
- Spanish (100%)
- Swedish (99%)
- Turkish (100%)
- Vietnamese (73%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

for information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 16.11.04 is

- Release Managers:
  - [Brendan Gallagher](mailto:brendan@bywatersolutions.com)
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
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
  - [Brooke Johnson](mailto:abesottedphoenix@yahoo.com)
  - [Thomas Dukleth](mailto:kohadevel@agogme.com)
- Release Maintainers:
  - 16.11 -- [Katrin Fischer](mailto:katrin.fischer.83@web.de)
  - 16.05 -- [Mason James](mailto:mtj@kohaaloha.com)
  - 3.22 -- [Julian Maurice](mailto:julian.maurice@biblibre.com)

## Credits

We thank the following libraries who are known to have sponsored
new features in Koha 16.11.04:


We thank the following individuals who contributed patches to Koha 16.11.04.

- Chloe (1)
- Emma (1)
- Blou (2)
- radiuscz (2)
- root (2)
- Nick Clemens (4)
- Tomás Cohen Arazi (3)
- David Cook (1)
- Marcel de Rooy (5)
- Jonathan Druart (20)
- Magnus Enger (2)
- Katrin Fischer (4)
- Caitlin Goodger (2)
- Luke Honiss (2)
- Mason James (2)
- Karen Jen (1)
- Julian Maurice (1)
- Kyle M Hall (2)
- Josef Moravec (2)
- Chris Nighswonger (1)
- Dobrica Pavlinusic (1)
- Liz Rea (1)
- Adrien Saurat (1)
- Zoe Schoeler (1)
- Lari Taskula (1)
- Mirko Tietgen (1)
- Mark Tompsett (1)
- Oleg Vasylenko (2)
- Marc Véron (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 16.11.04

- abunchofthings.net (1)
- BibLibre (2)
- BSZ BW (4)
- bugs.koha-community.org (20)
- ByWater-Solutions (6)
- Catalyst (1)
- centrum.cz (2)
- Foundations (1)
- jns.fi (1)
- KohaAloha (2)
- Libriotech (2)
- Marc Véron AG (1)
- master.rijkskoha.nl (1)
- Prosentient Systems (1)
- Rijksmuseum (5)
- rot13.org (1)
- Solutions inLibro inc (2)
- Theke Solutions (3)
- translate.koha-community.org (1)
- unidentified (10)
- wegc.school.nz (3)

We also especially thank the following individuals who tested patches
for Koha.

- Baptiste Wojtkowski (1)
- Christopher Brannon (2)
- Claire Gravely (3)
- Colin Campbell (1)
- Emma Smith (1)
- Grace McKenzie (1)
- Hugo Agud (1)
- Jenny Schmidt (2)
- Jonathan Druart (35)
- Josef Moravec (14)
- Julian Maurice (2)
- Katrin Fischer (64)
- Liz Rea (4)
- Magnus Enger (2)
- Marc Véron (1)
- Mark Tompsett (8)
- Mirko Tietgen (1)
- Nick Clemens (13)
- Owen Leonard (5)
- Tomas Cohen Arazi (5)
- Kyle M Hall (62)
- Marcel de Rooy (7)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 16.11.x.
The last Koha release was 16.11.03, which was released on January 22, 2017.  

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 21 Feb 2017 22:45:22.
