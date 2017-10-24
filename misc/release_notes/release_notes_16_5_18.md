# RELEASE NOTES FOR KOHA 16.05.18
24 Oct 2017

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 16.05.18 can be downloaded from:

- [Download](http://download.koha-community.org/koha-16.05.18.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 16.05.18 is a bugfix/maintenance release.

It includes 3 enhancements, 44 bugfixes.

## Security bugs fixed

- [[18956]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18956) Possible privacy breach with OPAC password recovery
- [[19117]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19117) paycollect.pl is vulnerable for CSRF attacks
- [[19333]](href="http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19333) XSS vulnerability in opac-shelves

## Enhancements

### Acquisitions

- [[19257]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19257) Warn when reopening a basket

### OPAC

- [[17834]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17834) Change library news text for single-branch libraries

### Tools

- [[18871]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18871) It is unclear how to view a patron list


## Critical bugs fixed

### Acquisitions

- [[18351]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18351) No warning when deleting budgets that have funds attached
- [[19120]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19120) Order cancelled status is reset on basket open

### Cataloging

- [[19350]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19350) Holds without link in 773 trigger SQL::Abstract::puke

### Lists

- [[19343]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19343) Private lists displayed in search results list

### Patrons

- [[19418]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19418) Patron search is broken

### SIP2

- [[18996]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18996) SIP sets ok flag to true for refused checkin for data corruption

### Serials

- [[19323]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19323) subscription edit permission issue

### Test Suite

- [[19441]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19441) Several tests are failing on 16.05.x


## Other bugs fixed

### Acquisitions

- [[18941]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18941) C4::Budgets GetBudgetByCode should return active budgets over inactive budgets
- [[19024]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19024) Order cancelled status is reset on basket close
- [[19118]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19118) Due to wrong variable name passed vendor name is  not coming in browser title bar
- [[19165]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19165) [16.11.x] When adding from a staged file order discounts are not passed into C4::Acquisitions::populate_order_with_prices

### Architecture, internals, and plumbing

- [[18794]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18794) OAI/Server.t fails on slow servers

### Circulation

- [[19007]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19007) Allow paypal payments via debit or credit card again
- [[19027]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19027) Circulation rules: Better wording for standard rules for all libraries

### Course reserves

- [[19229]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19229) Clicking Cancel when editing course doesn't take you back to the course

### Hold requests

- [[18469]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18469) Suspend all holds when specifying a date to resume hold does not keep date

### I18N/L10N

- [[18687]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18687) Translatability: abbr tag should not contain lang attribute
- [[18754]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18754) Translatability: Get rid of exposed tt directives in opac-detail.tt
- [[18776]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18776) Translatability: Get rid of exposed tt directives in opac-advsearch.tt
- [[18779]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18779) Translatability: Get rid of exposed tt directives in authorities-search-results.inc (OPAC)
- [[18780]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18780) Translatability: Get rid of exposed tt directive in masthead-langmenu.inc
- [[18781]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18781) Translatability: Get rid of exposed tt directives in openlibrary-readapi.inc

### Installation and upgrade (command-line installer)

- [[9409]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9409) koha-create --request-db should be able to accept a dbhost option

### Lists

- [[15924]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15924) Coce not enabled on lists

### OPAC

- [[9857]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9857) Did you mean? from authorities uses incorrect punctuation
- [[18692]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18692) When SMS is enabled the OPAC messaging table is misaligned
- [[18946]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18946) Change language from external web fails

### Patrons

- [[18621]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18621) After duplicate message system picks category expiry date rather than manual defined
- [[18636]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18636) Can not save new patron on fresh install (Conflict between autoMemberNum and BorrowerMandatoryField)

### SIP2

- [[18812]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18812) SIP Patron status does not respect OverduesBlockCirc

### Searching

- [[16485]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16485) Collection column in Item search is always empty

### Test Suite

- [[19013]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19013) sample_data.sql inserts patrons with guarantorid that do not exist
- [[19047]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19047) Fix AddBiblio call in Reserves.t
- [[19071]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19071) Fix Circulation/issue.t and Members/IssueSlip.t
- [[19126]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19126) Fix Members.t with IndependentBranches set
- [[19227]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19227) 00-merge-conflict-markers.t launches too many tests
- [[19335]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19335) 00-merge-markers.t fails
- [[19440]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19440) XISBN tests should skip if XISBN returns overlimit error

### Tools

- [[14316]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14316) Clarify meaning of record number in Batch record deletion tool
- [[19088]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19088) plugins-upload.pl causes uninitialized value noise



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
- Armenian (93%)
- Basque (77%)
- Chinese (China) (88%)
- Chinese (Taiwan) (98%)
- Czech (96%)
- Danish (72%)
- English (New Zealand) (96%)
- Finnish (98%)
- French (98%)
- French (Canada) (92%)
- German (99%)
- German (Switzerland) (99%)
- Greek (85%)
- Hindi (99%)
- Italian (99%)
- Korean (53%)
- Kurdish (51%)
- Norwegian Bokmål (59%)
- Occitan (80%)
- Persian (60%)
- Polish (100%)
- Portuguese (100%)
- Portuguese (Brazil) (89%)
- Slovak (94%)
- Spanish (99%)
- Swedish (91%)
- Turkish (100%)
- Vietnamese (74%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

for information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 16.05.18 is

- Release Manager: [Brendan Gallagher](mailto:brendan@bywatersolutions.com)
- QA Manager: [Katrin Fischer](mailto:Katrin.Fischer@bsz-bw.de)
- QA Team:
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
  - [Jonathan Druart](mailto:jonathan.druart@bugs.koha-community.org)
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
new features in Koha 16.05.18:

- Catalyst IT

We thank the following individuals who contributed patches to Koha 16.05.18.

- Aleisha Amohia (5)
- Alex Arnaud (1)
- Alex Buckley (1)
- Colin Campbell (2)
- Nick Clemens (6)
- Tomás Cohen Arazi (4)
- Christophe Croullebois (1)
- Marcel de Rooy (7)
- Jonathan Druart (20)
- Katrin Fischer (4)
- Amit Gupta (1)
- Mason James (3)
- Lee Jamison (1)
- Kyle M Hall (2)
- Dobrica Pavlinusic (1)
- Karam Qubsi (1)
- Fridolin Somers (3)
- Lari Taskula (1)
- Mark Tompsett (5)
- Marc Véron (9)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 16.05.18

- BibLibre (5)
- BSZ BW (4)
- bugs.koha-community.org (20)
- ByWater-Solutions (8)
- Catalyst (1)
- informaticsglobal.com (1)
- jns.fi (1)
- KohaAloha (3)
- Marc Véron AG (9)
- marywood.edu (1)
- PTFS-Europe (2)
- Rijksmuseum (7)
- rot13.org (1)
- Theke Solutions (4)
- unidentified (11)

We also especially thank the following individuals who tested patches
for Koha.

- Aleisha Amohia (1)
- Alex Buckley (6)
- anafe (1)
- Chris Kirby (1)
- Claire Gravely (1)
- Dilan Johnpullé (1)
- Felix Hemme (1)
- Frédéric Demians (1)
- Fridolin Somers (22)
- George Williams (1)
- Hugo Agud (1)
- iflora (1)
- Jonathan Druart (37)
- Josef Moravec (3)
- Julian Maurice (5)
- Katrin Fischer (28)
- Laurence Rault (1)
- Lee Jamison (2)
- Magnus Enger (1)
- Marc Veron (1)
- Marc Véron (1)
- maricris (1)
- Mark Tompsett (11)
- Mason James (46)
- Nick Clemens (4)
- Owen Leonard (12)
- Your Name (1)
- Tomas Cohen Arazi (7)
- Michael Andrew Cabus (2)
- Kyle M Hall (15)
- Caroline Cyr La Rose (1)
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

Autogenerated release notes updated last on 24 Oct 2017 08:23:03.
