# RELEASE NOTES FOR KOHA 16.5.5
22 oct. 2016

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 16.5.5 can be downloaded from:

- [Download](http://download.koha-community.org/koha-16.05.05.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 16.5.5 is a bugfix/maintenance release with security fixes.

It includes 3 security fixes, 8 enhancements, 51 bugfixes.


## Security bugs

### Koha

- [[16800]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16800) Stored Cross-site Scripting vulnerability in addbiblio.pl
- [[17035]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17035) Koha allows system-wide 'read' access to all Koha zebra databases, by default
- [[17365]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17365) SQL Injection & XSS attack in memberentry.pl


## Enhancements

### Acquisitions

- [[9896]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9896) Show vendor in subscription search when creating an order for a subscription

### Circulation

- [[17331]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17331) Show holding branch in holds awaiting pickup report

### Command-line Utilities

- [[10337]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10337) Add a script to insert all sample data automatically
- [[17444]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17444) Export by date and time in export_record.pl

### OPAC

- [[15388]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15388) Show Syndetics covers by UPC in search results

### Patrons

- [[17154]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17154) Note column is missing on account lines receipt

### Templates

- [[17056]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17056) Remove event attributes from various templates

### Test Suite

- [[17304]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17304) C4::Matcher::_get_match_keys is not tested


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[17342]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17342) Plack does not work after upgrading to 3.22.11 and 16.05.04

### Cataloging

- [[17477]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17477) Duplicating a subfield yields an empty subfield tag

### Installation and upgrade (command-line installer)

- [[17292]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17292) Use of DBIx in updatedatabase.pl broke upgrade (from bug 12375)

### Installation and upgrade (web-based installer)

- [[16573]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16573) Web installer fails to load structure and sample data on MySQL 5.7
- [[17324]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17324) branchcode is NULL in letter triggers red upgrade message

### OPAC

- [[17392]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17392) opac/svc/overdrive_proxy is not plack safe
- [[17393]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17393) selfreg - Patron's info are not correctly inserted if contain non-Latin characters

### Patrons

- [[11217]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11217) The # in accountlines descriptions makes them un-writeoffable
- [[17403]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17403) Internal Server Error while deleting patron

### Searching

- [[16838]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16838) Elasticsearch - mapping tables are not populated on new installs

### System Administration

- [[17389]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17389) Exporting framework always export the default framework


## Other bugs fixed

### About

- [[7143]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7143) Bug for tracking changes to the about page
- [[13405]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13405) System information has misleading information about indexing mode

### Architecture, internals, and plumbing

- [[14060]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14060) Remove readonly on date inputs
- [[14707]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14707) Change UsageStatsCountry from free text to a dropdown list
- [[17294]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17294) reserves_stats.pl is not plack safe
- [[17368]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17368) plugins tests are broken - KitchenSinkPlugin
- [[17372]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17372) Elasticsearch paths need to be standardized
- [[17411]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17411) Change exit 1 to exit 0 in acqui/basket.pl to prevent Internal Server Error
- [[17426]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17426) AutoCommit should not be set in tests
- [[17446]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17446) Remove some seleted typos

### Cataloging

- [[7045]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7045) Default-value substitution inconsistent
- [[16245]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16245) RIS export file type incorrect
- [[16358]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16358) Rancor - Deleting records when Rancor is enabled just opens them
- [[17405]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17405) Edit record uses Default framework

### Circulation

- [[10768]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10768) Improve the interface related to itemBarcodeFallbackSearch
- [[17310]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17310) Broken URLs in 'Item renewed' / 'Cannot renew' messages
- [[17352]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17352) Patron search type is hard coded to 'contain' in circ/circulation.pl

### Command-line Utilities

- [[2389]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=2389) overdue_notices.pl needs a test mode
- [[17088]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17088) Bad MARC XML can halt export_records.pl

### Hold requests

- [[14514]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14514) LocalHoldsPriority and the HoldsQueue conflict with each other

### I18N/L10N

- [[16687]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16687) Translatability: Fix issues with sentence splitting in Administration preferences
- [[17245]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17245) Untranslatable abbreviated names of seasons
- [[17322]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17322) Translation breaks opac-ics.tt

### Installation and upgrade (web-based installer)

- [[17357]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17357) WTHDRAWN is still used in installer files
- [[17358]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17358) Authorised values: COU>COUNTRY | LAN>LANG

### Lists

- [[17315]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17315) Can't add entry to lists using link in result list
- [[17316]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17316) Possible to see name of lists you don't own

### OPAC

- [[17296]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17296) Failed to correctly configure AnonymousPatron with AnonSuggestions should display a warning in about
- [[17367]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17367) Showing all items must keep show holdings tab in OPAC details

### Packaging

- [[17085]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17085) Specify libmojolicious-perl min version

### Patrons

- [[17404]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17404) Patron deletion page: Fix title and breadcrumb
- [[17423]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17423) patronimage.pl permission is too restrictive

### Reports

- [[16816]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16816) Duplicate button on report results copies parameters used

### Serials

- [[17300]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17300) Serials search does not return any results

### Staff Client

- [[17144]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17144) Fix variable scope issue in edi_accounts.pl (Internal server error with plack)

### System Administration

- [[16035]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16035) MARC framework Export misbehaving

### Templates

- [[17289]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17289) Holds awaiting pickup shows date unformatted
- [[17312]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17312) Typo in members-toolbar.inc / moremember-brief.tt / moremember.tt

### Test Suite

- [[17430]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17430) MarkIssueReturned.t should create its own data
- [[17441]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17441) t/db_dependent/Letters.t fails on Jenkins



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
- Chinese (Taiwan) (100%)
- Czech (96%)
- Danish (74%)
- English (New Zealand) (98%)
- Finnish (92%)
- French (96%)
- French (Canada) (92%)
- German (99%)
- German (Switzerland) (99%)
- Greek (77%)
- Hindi (100%)
- Italian (100%)
- Korean (54%)
- Kurdish (52%)
- Norwegian Bokmål (60%)
- Occitan (94%)
- Persian (61%)
- Polish (99%)
- Portuguese (99%)
- Portuguese (Brazil) (90%)
- Slovak (95%)
- Spanish (99%)
- Swedish (79%)
- Turkish (99%)
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

The release team for Koha 16.5.5 is

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
new features in Koha 16.5.5:

- Catalyst IT
- Universidad de El Salvador

We thank the following individuals who contributed patches to Koha 16.5.5.

- Marc (4)
- Aleisha Amohia (1)
- Hector Castro (2)
- Nick Clemens (4)
- Tomás Cohen Arazi (6)
- Frédéric Demians (5)
- Marcel de Rooy (5)
- Jonathan Druart (38)
- Julian FIOL (1)
- Katrin Fischer (1)
- Mason James (1)
- Andreas Jonsson (1)
- Rafal Kopaczka (1)
- Owen Leonard (1)
- Jesse Maseto (1)
- Sophie Meynieux (1)
- Kyle M Hall (5)
- Josef Moravec (1)
- Andreas Roussos (5)
- Rodrigo Santellan (1)
- Fridolin Somers (2)
- Zeno Tajoli (1)
- Mirko Tietgen (1)
- Mark Tompsett (2)
- Marc Véron (3)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 16.5.5

- abunchofthings.net (1)
- ACPL (1)
- BibLibre (7)
- BSZ BW (1)
- bugs.koha-community.org (35)
- ByWater-Solutions (10)
- Cineca (1)
- KohaAloha (1)
- kreablo.se (1)
- Marc Véron AG (7)
- poczta.onet.pl (1)
- Rijksmuseum (5)
- Tamil (5)
- Theke Solutions (6)
- unidentified (12)

We also especially thank the following individuals who tested patches
for Koha.

- Aleisha Amohia (2)
- Andreas Roussos (2)
- Barbara.Johnson@bedfordtx.gov (1)
- Barton Chittenden (2)
- Brendan Gallagher (29)
- Chris Cormack (16)
- Claire Gravely (3)
- Dani Elder (2)
- David Cook (1)
- Frédéric Demians (87)
- Hector Castro (5)
- Jonathan Druart (20)
- Josef Moravec (2)
- Juliette (1)
- Katrin Fischer (1)
- Magnus Enger (1)
- Marc (3)
- Marc Véron (9)
- Mark Tompsett (4)
- Martin Renvoize (2)
- Michael Kuhn (1)
- Mirko Tietgen (1)
- Nick Clemens (17)
- Owen Leonard (11)
- radiuscz (1)
- remy (1)
- Katrin Fischer  (37)
- Tomas Cohen Arazi (5)
- Barton Chittenden barton@bywatersolutions.com (1)
- Kyle M Hall (62)
- Bernardo Gonzalez Kriegel (2)
- Marcel de Rooy (13)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 16.05.x.
The last Koha release was 3.22.8, which was released on June 24, 2016.  

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 22 oct. 2016 13:37:22.
