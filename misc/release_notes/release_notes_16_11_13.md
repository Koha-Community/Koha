# RELEASE NOTES FOR KOHA 16.11.13
22 Oct 2017

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 16.11.13 can be downloaded from:

- [Download](http://download.koha-community.org/koha-16.11.13.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 16.11.13 is a bugfix/maintenance release.

It includes 4 enhancements, 57 bugfixes.

## Security bugs fixed

- [[18956]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18956) Possibleprivacy breach with OPAC password recovery
- [[19117]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19117) paycollect.pl is vulnerable for CSRF attacks
- [[19333]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19333) XSS vulnerability in opac-shelves

## Enhancements

### Acquisitions

- [[19257]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19257) Warn when reopening a basket

### Hold requests

- [[14353]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14353) Show 'damaged' and other status on the 'place holds' page in staff

### OPAC

- [[17834]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17834) Change library news text for single-branch libraries

### Tools

- [[18871]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18871) It is unclear how to view a patron list


## Critical bugs fixed

### Acquisitions

- [[18351]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18351) No warning when deleting budgets that have funds attached
- [[19120]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19120) Order cancelled status is reset on basket open
- [[19372]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19372) Selecting MARC framework doesn't work when adding to basket from an external source

### Cataloging

- [[19350]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19350) Holds without link in 773 trigger SQL::Abstract::puke

### Hold requests

- [[19116]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19116) Holds not set to waiting when "Confirm" is used

### Lists

- [[19343]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19343) Private lists displayed in search results list

### OPAC

- [[19366]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19366) PatronSelfRegistrationEmailMustBeUnique pref makes it impossible to submit updates via OPAC

### Patrons

- [[19418]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19418) Patron search is broken

### SIP2

- [[18996]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18996) SIP sets ok flag to true for refused checkin for data corruption

### Serials

- [[19323]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19323) subscription edit permission issue


## Other bugs fixed

### Acquisitions

- [[18941]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18941) C4::Budgets GetBudgetByCode should return active budgets over inactive budgets
- [[19024]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19024) Order cancelled status is reset on basket close
- [[19118]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19118) Due to wrong variable name passed vendor name is  not coming in browser title bar
- [[19165]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19165) [16.11.x] When adding from a staged file order discounts are not passed into C4::Acquisitions::populate_order_with_prices

### Architecture, internals, and plumbing

- [[13012]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13012) suggestion.suggesteddate should be set to NOW if not defined
- [[17699]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17699) DateTime durations are not correctly subtracted
- [[18794]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18794) OAI/Server.t fails on slow servers
- [[19055]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19055) GetReservesToBranch is not used

### Circulation

- [[19007]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19007) Allow paypal payments via debit or credit card again
- [[19027]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19027) Circulation rules: Better wording for standard rules for all libraries

### Course reserves

- [[19228]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19228) Confirm delete doesn't show when deleting an item from course
- [[19229]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19229) Clicking Cancel when editing course doesn't take you back to the course

### Hold requests

- [[18469]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18469) Suspend all holds when specifying a date to resume hold does not keep date

### I18N/L10N

- [[18687]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18687) Translatability: abbr tag should not contain lang attribute
- [[18754]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18754) Translatability: Get rid of exposed tt directives in opac-detail.tt
- [[18776]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18776) Translatability: Get rid of exposed tt directives in opac-advsearch.tt
- [[18777]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18777) Translatability: Get rid of exposed tt directives in opac-memberentry.tt
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

- [[18897]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18897) Elastic related tests do not skip when ES modules are not installed
- [[19004]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19004) Koha/Patrons.t fails when item-level_itypes is not set
- [[19013]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19013) sample_data.sql inserts patrons with guarantorid that do not exist
- [[19042]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19042) Silence warnings t/db_dependent/Letters.t
- [[19047]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19047) Fix AddBiblio call in Reserves.t
- [[19071]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19071) Fix Circulation/issue.t and Members/IssueSlip.t
- [[19126]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19126) Fix Members.t with IndependentBranches set
- [[19227]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19227) 00-merge-conflict-markers.t launches too many tests
- [[19335]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19335) 00-merge-markers.t fails
- [[19385]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19385) t/Calendar.t is failing randomly
- [[19391]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19391) auth_values_input_www.t  is failing because of bug 19128
- [[19440]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19440) XISBN tests should skip if XISBN returns overlimit error

### Tools

- [[14316]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14316) Clarify meaning of record number in Batch record deletion tool
- [[19081]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19081) Plack preventing uninstalled plugins from being removed on the plugins list
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
- Arabic (99%)
- Armenian (95%)
- Chinese (China) (85%)
- Chinese (Taiwan) (99%)
- Czech (95%)
- Danish (70%)
- English (New Zealand) (93%)
- Finnish (99%)
- French (99%)
- French (Canada) (93%)
- German (100%)
- German (Switzerland) (99%)
- Greek (83%)
- Hindi (98%)
- Italian (99%)
- Korean (51%)
- Norwegian Bokmål (56%)
- Occitan (78%)
- Persian (59%)
- Polish (100%)
- Portuguese (100%)
- Portuguese (Brazil) (86%)
- Slovak (92%)
- Spanish (99%)
- Swedish (98%)
- Turkish (100%)
- Vietnamese (72%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

for information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 16.11.13 is

- Release Managers:
  - [Brendan Gallagher](mailto:brendan@bywatersolutions.com)
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
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
  - [Brooke Johnson](mailto:abesottedphoenix@yahoo.com)
  - [Thomas Dukleth](mailto:kohadevel@agogme.com)
- Release Maintainers:
  - 16.11 -- [Katrin Fischer](mailto:katrin.fischer.83@web.de)
  - 16.05 -- [Mason James](mailto:mtj@kohaaloha.com)
  - 3.22 -- [Julian Maurice](mailto:julian.maurice@biblibre.com)

## Credits

We thank the following libraries who are known to have sponsored
new features in Koha 16.11.13:

- Catalyst IT

We thank the following individuals who contributed patches to Koha 16.11.13.

- root (1)
- Aleisha Amohia (6)
- Alex Arnaud (1)
- Alex Buckley (1)
- Colin Campbell (2)
- Nick Clemens (6)
- Tomás Cohen Arazi (4)
- Christophe Croullebois (1)
- Marcel de Rooy (10)
- Jonathan Druart (26)
- Katrin Fischer (6)
- Amit Gupta (1)
- Lee Jamison (2)
- Kyle M Hall (3)
- Josef Moravec (2)
- Dobrica Pavlinusic (1)
- Karam Qubsi (1)
- Fridolin Somers (3)
- Lari Taskula (1)
- Mark Tompsett (10)
- Marc Véron (11)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 16.11.13

- BibLibre (5)
- BSZ BW (6)
- bugs.koha-community.org (26)
- ByWater-Solutions (9)
- Catalyst (1)
- informaticsglobal.com (1)
- jns.fi (1)
- Marc Véron AG (11)
- marywood.edu (2)
- PTFS-Europe (2)
- Rijksmuseum (10)
- rot13.org (1)
- Theke Solutions (4)
- translate.koha-community.org (1)
- unidentified (19)

We also especially thank the following individuals who tested patches
for Koha.

- Aleisha Amohia (1)
- Alex Buckley (7)
- anafe (1)
- Chris Kirby (1)
- Claire Gravely (2)
- Dilan Johnpullé (1)
- Felix Hemme (1)
- Frédéric Demians (1)
- Fridolin Somers (80)
- George Williams (1)
- Hugo Agud (1)
- iflora (1)
- Jonathan Druart (95)
- Josef Moravec (3)
- Julian Maurice (6)
- Katrin Fischer (98)
- Laurence Rault (1)
- Lee Jamison (7)
- Magnus Enger (1)
- Marc Veron (1)
- Marc Véron (3)
- maricris (1)
- Marijana Glavica (2)
- Mark Tompsett (16)
- Nick Clemens (4)
- Owen Leonard (16)
- Your Name (1)
- Tomas Cohen Arazi (15)
- Michael Andrew Cabus (2)
- Kyle M Hall (24)
- Caroline Cyr La Rose (1)
- Marcel de Rooy (21)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 16.11.x.
The last Koha release was 16.11.12, which was released on September 21, 2017.  

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 22 Oct 2017 22:47:35.
