# RELEASE NOTES FOR KOHA 16.5.10
23 Feb 2017

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 16.5.10 can be downloaded from:

- [Download](http://download.koha-community.org/koha-16.05.10.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 16.5.10 is a bugfix/maintenance release.

It includes 1 enhancements, 32 bugfixes.




## Enhancements

### Installation and upgrade (command-line installer)

- [[7533]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7533) Add template_cache_dir to the koha-conf.xml file


## Critical bugs fixed

### Authentication

- [[17775]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17775) Add new user with LDAP not works under Plack

### Cataloging

- [[17922]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17922) Default value substitution for month and day should be fixed length

### Circulation

- [[8361]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8361) Issuing rule if no rule is defined

### Hold requests

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
- [[18089]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18089) All XSLT testing singleBranchMode = 0 fails to show even if install has only 1 branch
- [[18136]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18136) Content of ExportRemoveFields is not picked to pre-fill field list

### Cataloging

- [[17512]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17512) Improve handling dates in C4::Items
- [[17780]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17780) When choose an author in authority results new window shows a blank screen
- [[17988]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17988) Select2 prevents correct tag expand/minimize functionality

### Hold requests

- [[11450]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11450) Hold Request Confirm Deletion

### Lists

- [[15584]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15584) Staff client list errors are incorrectly styled
- [[17852]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17852) Multiple URLs (856) in list email are broken

### MARC Authority data support

- [[17913]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17913) Merge three authority merge fixes

### MARC Bibliographic data support

- [[17788]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17788) (MARC21) $9 fields not indexed in authority-linked fields

### OPAC

- [[17823]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17823) XSLT: Add label for MARC 583 - Action note

### Reports

- [[8306]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8306) Patron stats, patron activity : no active doesn't work

### Searching

- [[16115]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16115) JavaScript error on item search form unless NOT_LOAN defined
- [[17838]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17838) Availability limit broken until an item has been checked out
- [[18047]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18047) JavaScript error on item search form unless LOC defined
- [[18068]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18068) ES: Location and (home|holding)branch facets mixed

### Serials

- [[17865]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17865) If a subscription has no history end date, it shows as expired today in OPAC

### Staff Client

- [[18026]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18026) URL to database columns link in system preferences is incorrect

### Tools

- [[18095]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18095) Batch item modification: Better message if no item is modified

### Z39.50 / SRU / OpenSearch Servers

- [[17487]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17487) Improper placement of select/clear all in Z39.50/SRU search dialog



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
- Armenian (95%)
- Chinese (China) (89%)
- Chinese (Taiwan) (99%)
- Czech (97%)
- Danish (73%)
- English (New Zealand) (97%)
- Finnish (99%)
- French (99%)
- French (Canada) (94%)
- German (100%)
- German (Switzerland) (100%)
- Greek (84%)
- Hindi (100%)
- Italian (100%)
- Korean (54%)
- Kurdish (52%)
- Norwegian Bokmål (60%)
- Occitan (81%)
- Persian (61%)
- Polish (100%)
- Portuguese (99%)
- Portuguese (Brazil) (90%)
- Slovak (95%)
- Spanish (100%)
- Swedish (92%)
- Turkish (100%)
- Vietnamese (75%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

for information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 16.5.10 is

- Release Manager: [Brendan Gallagher](mailto:brendan@bywatersolutions.com)
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
new features in Koha 16.5.10:


We thank the following individuals who contributed patches to Koha 16.5.10.

- Chloe (1)
- Blou (2)
- radiuscz (2)
- Nick Clemens (2)
- Tomás Cohen Arazi (3)
- David Cook (1)
- Marcel de Rooy (3)
- Jonathan Druart (16)
- Caitlin Goodger (2)
- Luke Honiss (2)
- Mason James (4)
- Karen Jen (1)
- Julian Maurice (2)
- Kyle M Hall (2)
- Josef Moravec (1)
- Chris Nighswonger (1)
- Dobrica Pavlinusic (1)
- Liz Rea (1)
- Adrien Saurat (1)
- Zoe Schoeler (1)
- Mirko Tietgen (1)
- Mark Tompsett (1)
- Oleg Vasylenko (3)
- Marc Véron (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 16.5.10

- abunchofthings.net (1)
- BibLibre (3)
- bugs.koha-community.org (16)
- ByWater-Solutions (4)
- Catalyst (1)
- centrum.cz (2)
- Foundations (1)
- KohaAloha (4)
- Marc Véron AG (1)
- Prosentient Systems (1)
- Rijksmuseum (3)
- rot13.org (1)
- Solutions inLibro inc (2)
- Theke Solutions (3)
- unidentified (9)
- wegc.school.nz (3)

We also especially thank the following individuals who tested patches
for Koha.

- Baptiste Wojtkowski (1)
- Christopher Brannon (1)
- Claire Gravely (2)
- Colin Campbell (1)
- Hugo Agud (1)
- Jenny Schmidt (2)
- Jonathan Druart (29)
- Josef Moravec (14)
- Katrin Fischer (18)
- Liz Rea (3)
- Magnus Enger (2)
- Marc Véron (1)
- Mark Tompsett (4)
- Mason James (33)
- Mirko Tietgen (1)
- Nick Clemens (10)
- Owen Leonard (4)
- Tomas Cohen Arazi (4)
- Kyle M Hall (18)
- Marcel de Rooy (4)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 16.05.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 23 Feb 2017 21:36:13.
