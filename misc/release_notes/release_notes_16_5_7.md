# RELEASE NOTES FOR KOHA 16.5.7
03 Jan 2017

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 16.5.7 can be downloaded from:

- [Download](http://download.koha-community.org/koha-16.05.07.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 16.5.7 is a bugfix/maintenance release.

It includes 23 bugfixes.






## Critical bugs fixed

### Acquisitions

- [[14541]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14541) Tax rate should not be forced to an arbitrary precision

### Architecture, internals, and plumbing

- [[17494]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17494) Koha generating duplicate self registration tokens

### Circulation

- [[14598]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14598) itemtype is not set on statistics by C4::Circulation::AddReturn
- [[16376]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16376) Koha::Calendar->is_holiday date truncation creates fatal errors for TZ America/Santiago

### I18N/L10N

- [[16914]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16914) Export csv in item search, exports all items in one line

### Searching

- [[15822]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15822) STAFF Advanced search error date utils
- [[16951]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16951) Item search sorting not working properly for most columns
- [[17278]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17278) Limit to available items returns 0 results
- [[17323]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17323) MySQL 5.7 - Column search_history.time cannot be null
- [[17743]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17743) Item search: indexes build on MARC do not work in item's search

### Web services

- [[17744]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17744) OAI: oai_dc has no element named dcCollection


## Other bugs fixed

### Architecture, internals, and plumbing

- [[17564]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17564) Acquisition/OrderUsers.t is broken
- [[17638]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17638) t/db_dependent/Search.t is failing
- [[17641]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17641) t/Biblio/Isbd.t is failing
- [[17681]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17681) Existing typos might thow some fees when recieved

### Circulation

- [[17761]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17761) Renewing or returning item via the checkouts table causes lost and damaged statuses to disappear

### Hold requests

- [[17749]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17749) Missing l in '.pl' in link on waitingreserves.tt

### MARC Bibliographic data support

- [[17547]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17547) (MARC21) Chronological term link subfield 648$9 not indexed

### Notices

- [[11274]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11274) Sent Notices Tab Not Working Correctly

### OPAC

- [[17652]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17652) opac-account.pl does not include login branchcode

### Test Suite

- [[15200]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15200) t/Creators.t fails when using build-git-snapshot

### Tools

- [[15415]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15415) Warn when creating new printer profile for patron card creator
- [[17663]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17663) Forgotten userpermissions from bug 14686



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
- Danish (74%)
- English (New Zealand) (98%)
- Finnish (99%)
- French (99%)
- French (Canada) (93%)
- German (100%)
- German (Switzerland) (100%)
- Greek (81%)
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
- Spanish (99%)
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

The release team for Koha 16.5.7 is

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
  - 16.05 -- [Mason James](mailto:mtj@kohaaloha.com)
  - 3.22 -- [Julian Maurice](mailto:julian.maurice@biblibre.com)
  - 3.20 -- [Chris Cormack](mailto:chrisc@catalyst.net.nz)

## Credits

We thank the following libraries who are known to have sponsored
new features in Koha 16.5.7:

- Catalyst IT
- Universidad Nacional de Cordoba

We thank the following individuals who contributed patches to Koha 16.5.7.

- Aleisha Amohia (1)
- Nick Clemens (2)
- Tomás Cohen Arazi (4)
- David Cook (1)
- Marcel de Rooy (1)
- Jonathan Druart (6)
- Mason James (22)
- Chris Kirby (1)
- Owen Leonard (1)
- Julian Maurice (1)
- Kyle M Hall (2)
- Mirko Tietgen (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 16.5.7

- abunchofthings.net (1)
- ACPL (1)
- BibLibre (1)
- bugs.koha-community.org (6)
- ByWater-Solutions (3)
- ilsleypubliclibrary.org (1)
- KohaAloha (22)
- kylehall.info (1)
- Prosentient Systems (1)
- Rijksmuseum (1)
- Theke Solutions (4)
- unidentified (1)

We also especially thank the following individuals who tested patches
for Koha.

- Alex Buckley (3)
- Benjamin Rokseth (1)
- Chris Cormack (2)
- Edie Discher (1)
- Hugo Agud (1)
- Jonathan Druart (8)
- Josef Moravec (3)
- Julian Maurice (16)
- Katrin Fischer (19)
- Marc Véron (1)
- Mason James (7)
- Nick Clemens (8)
- Tomas Cohen Arazi (4)
- Brendan A Gallagher (2)
- Kyle M Hall (15)
- Marcel de Rooy (3)

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

Autogenerated release notes updated last on 03 Jan 2017 02:08:39.
