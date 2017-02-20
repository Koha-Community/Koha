# RELEASE NOTES FOR KOHA 3.22.17
20 Feb 2017

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 3.22.17 can be downloaded from:

- [Download](http://download.koha-community.org/koha-3.22.17.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 3.22.17 is a bugfix/maintenance release.

It includes 23 bugfixes.




## Critical bugs fixed

### Authentication

- [[17775]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17775) Add new user with LDAP not works under Plack

### Cataloging

- [[17922]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17922) Default value substitution for month and day should be fixed length

### Circulation

- [[8361]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8361) Issuing rule if no rule is defined
- [[16387]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16387) Incorrect loan period calculation when using  decreaseLoanHighHolds feature

### Label/patron card printing

- [[18044]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18044) Label Batches not displaying

### Patrons

- [[17782]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17782) Patron updated_on field should be set to current timestamp when borrower is deleted

### Serials

- [[15030]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15030) Certain values in serials' items are lost on next edit

### Z39.50 / SRU / OpenSearch Servers

- [[17871]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17871) Can't retrieve facets (or zebra::snippet) from Zebra with YAZ 5.8.1


## Other bugs fixed

### Architecture, internals, and plumbing

- [[18136]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18136) Content of ExportRemoveFields is not picked to pre-fill field list

### Cataloging

- [[17512]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17512) Improve handling dates in C4::Items

### Hold requests

- [[11450]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11450) Hold Request Confirm Deletion

### MARC Authority data support

- [[17909]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17909) Add unit tests for authority merge
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
- [[17838]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17838) Availability limit broken until an item has been checked out
- [[18047]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18047) JavaScript error on item search form unless LOC defined

### Staff Client

- [[18026]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18026) URL to database columns link in system preferences is incorrect

### Test Suite

- [[18009]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18009) IssueSlip.t test fails if launched between 00:00 and 00:59

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
- Arabic (98%)
- Armenian (99%)
- Chinese (China) (93%)
- Chinese (Taiwan) (97%)
- Czech (97%)
- Danish (77%)
- English (New Zealand) (98%)
- Finnish (99%)
- French (99%)
- French (Canada) (91%)
- German (100%)
- German (Switzerland) (99%)
- Greek (80%)
- Hindi (100%)
- Italian (99%)
- Korean (57%)
- Kurdish (54%)
- Norwegian Bokmål (63%)
- Occitan (94%)
- Persian (64%)
- Polish (99%)
- Portuguese (99%)
- Portuguese (Brazil) (94%)
- Slovak (99%)
- Spanish (100%)
- Swedish (95%)
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

The release team for Koha 3.22.17 is

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
new features in Koha 3.22.17:


We thank the following individuals who contributed patches to Koha 3.22.17.

- Blou (2)
- radiuscz (2)
- Maxime Beaulieu (1)
- Nick Clemens (2)
- Tomás Cohen Arazi (2)
- David Cook (1)
- Frédéric Demians (1)
- Jonathan Druart (5)
- Magnus Enger (1)
- Luke Honiss (1)
- Mason James (2)
- Karen Jen (1)
- Julian Maurice (6)
- Josef Moravec (1)
- Chris Nighswonger (1)
- Dobrica Pavlinusic (1)
- Adrien Saurat (1)
- Zoe Schoeler (1)
- Lari Taskula (1)
- Marcel de Rooy (5)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 3.22.17

- BibLibre (7)
- bugs.koha-community.org (5)
- ByWater-Solutions (2)
- centrum.cz (2)
- Foundations (1)
- jns.fi (1)
- KohaAloha (2)
- Libriotech (1)
- Prosentient Systems (1)
- Rijksmuseum (5)
- rot13.org (1)
- Solutions inLibro inc (3)
- Tamil (1)
- Theke Solutions (2)
- unidentified (3)
- wegc.school.nz (1)

We also especially thank the following individuals who tested patches
for Koha.

- Baptiste Wojtkowski (1)
- Christopher Brannon (1)
- Colin Campbell (1)
- Grace McKenzie (1)
- Hugo Agud (1)
- Jonathan Druart (13)
- Josef Moravec (15)
- Julian Maurice (40)
- Katrin Fischer (27)
- Liz Rea (1)
- Mark Tompsett (5)
- Mason James (7)
- Nick Clemens (6)
- Owen Leonard (1)
- Tomas Cohen Arazi (2)
- Kyle M Hall (26)
- Bernardo Gonzalez Kriegel (1)
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

Autogenerated release notes updated last on 20 Feb 2017 11:15:57.
