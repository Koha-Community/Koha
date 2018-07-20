# RELEASE NOTES FOR KOHA 18.05.02
23 Jul 2018

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 18.05.02 can be downloaded from:

- [Download](http://download.koha-community.org/koha-18.05.02.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 18.05.02 is a bugfix/maintenance release.

It includes 7 enhancements, 57 bugfixes.




## Enhancements

### Architecture, internals, and plumbing

- [[20456]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20456) Remove the C4::Serials::GetSubscriptionsFromBorrower

### I18N/L10N

- [[20709]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20709) Update GERMAN MARC frameworks to Updates 23-26 (Nov 2016, May and Apr 2018)

### MARC Bibliographic data support

- [[19835]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19835) Update MARC frameworks to Updates 23+24+25 (Nov 2016, May and Dec 2017)
- [[20710]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20710) Update MARC21 frameworks to Update 26 (April 2018)

### OPAC

- [[20876]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20876) The form_serialized_itype cookie is not used and should be removed

### Patrons

- [[20867]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20867) Ability to show membership renewal date on moremember.pl page

### Templates

- [[20520]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20520) Re-indent moremember.tt


## Critical bugs fixed

### Acquisitions

- [[20972]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20972) If ISBN has 10 numbers only the first 9 numbers are used
- [[20979]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20979) Error message when deleting bib attached to order

### Authentication

- [[20879]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20879) Shibboleth in combination with LDAP as an alternative no longer works

### Cataloging

- [[20928]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20928) Checkout status not showing patron

### Circulation

- [[20934]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20934) Biblio checkout history shows only current checkout

### Fines and fees

- [[20946]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20946) Cannot pay fines for patrons with credits

### Patrons

- [[13655]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13655) Can't save organisation type patron without entering userid/password
- [[20903]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20903) Print payment receipt on child patron could end with server error
- [[20951]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20951) Koha::Patron::Discharge is missing use Koha::Patron::Debarments

### SIP2

- [[21020]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21020) Return branch not set for transfer when using SIP

### Self checkout

- [[21054]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21054) Extra closing body tag in sco-main.tt prevents slip printing

### Staff Client

- [[20998]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20998) Non superlibrarians cannot search for patrons using the quicksearch at the top

### Templates

- [[20977]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20977) Javascript vars used in confirm_deletion in catalog.js do not match strings in catalog-strings.inc

### Test Suite

- [[20906]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20906) Fix Debian 9 Test Failures

### Tools

- [[20084]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20084) Patron card creator: layouts Industrial2of5 and COOP2of5 broken with error "Invalid Characters"

### Web services

- [[21046]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21046) ILSDI - AuthenticatePatron returns a wrong borrowernumber if cardnumber is empty


## Other bugs fixed

### Architecture, internals, and plumbing

- [[20702]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20702) Bind results of GetHostItemsInfo to the EasyAnalyticalRecords pref
- [[21008]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21008) pay.pl and paycollect.pl raise warning
- [[21022]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21022) Exceptions should skip stringifying if message manually passed

### Cataloging

- [[15360]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15360) Incorrect or mislabeled behavior on Authorities "New from Z39.50" Button
- [[18822]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18822) Advanced editor - Rancor - searching broken under Elasticsearch
- [[21009]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21009) Max length of inputs on editing/adding items is broken

### Circulation

- [[20793]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20793) Don't show holds link in result list when staff user doesn't have place_holds permission
- [[20794]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20794) Don't show holds tab when user doesn't have circulate_remaining_permissions

### Command-line Utilities

- [[20893]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20893) batchRebuildItemsTables.pl has incorrect parameter

### I18N/L10N

- [[20332]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20332) Untranslatable strings in grouped OPAC results
- [[21029]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21029) "Suspend until" in modal in staff patron account is not translatable

### Label/patron card printing

- [[6647]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=6647) Label item search should use standard pagination routine

### Lists

- [[17886]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17886) Don't show option to add to existing list if there are no lists in staff

### OPAC

- [[17869]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17869) Don't show pick-up library for list of holds in OPAC account when there is only one branch
- [[19849]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19849) Rebase of bug 16621 partially reverted bug 12509
- [[20090]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20090) Missing Script Statement for Novelist Select on Some Record Displays in OPAC
- [[20507]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20507) Shelf browser does not update image sources when paging
- [[20953]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20953) Discharge can be requested several times on OPAC

### Packaging

- [[18250]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18250) koha-common should start after memcached
- [[20920]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20920) Plack timeout because of missing CGI::Compile Perl dependency
- [[20949]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20949) Koha depends on Clone

### Patrons

- [[20991]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20991) Error will reset category when editing a patron
- [[21025]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21025) Koha::Patron::Discharge is missing use C4::Letters

### Reports

- [[16653]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16653) reports/cat_issues_top.pl does not export "Count of checkouts" column as CSV
- [[20945]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20945) Report params not escaped when downloading

### Searching

- [[20864]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20864) Only set bibs_selected cookie when BrowseResultSelection is activated

### Searching - Elasticsearch

- [[19502]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19502) Result sets limited to 10000

### Searching - Zebra

- [[20697]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20697) Remove some Host-Item-Number noise from zebra-output.log when EasyAnalyticalRecords is not used

### Serials

- [[7136]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7136) Correct description of Grace period for subscriptions

### Staff Client

- [[18521]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18521) Renew and search hotkeys are swapped on returns page.
- [[20919]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20919) A Zebra query is done for each item when opening a record detail page

### System Administration

- [[14446]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14446) Resolve "Use of uninitialized value in goto" in admin/preferences.pl

### Templates

- [[20559]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20559) Occurrences of loading-small.gif still exist
- [[20698]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20698) Remove obsolete template: transfer-slip.tt
- [[20805]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20805) Update child to adult patron process broken on several patron-related pages
- [[20814]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20814) Display issue with 'Saved reports' tabs when memcached is off
- [[20881]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20881) Order receiving: Price filter missing on_editing
- [[20931]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20931) JS error "ReferenceError: $ is not defined" when CircSidebar is turned on
- [[20999]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20999) Remove invalid 'style="block"' from OPAC templates

### Test Suite

- [[20900]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20900) Yet another test assumes that CPL is present
- [[21023]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21023) Remove warning in t/db_dependent/Circulation/Chargelostitem.t



## System requirements

Important notes:
    
- Perl 5.10 is required
- Zebra is required

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://koha-community.org/manual/18.05/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (100%)
- Armenian (99.9%)
- Basque (73.5%)
- Chinese (China) (77.9%)
- Chinese (Taiwan) (100%)
- Czech (92.6%)
- Danish (64.4%)
- English (New Zealand) (96.8%)
- English (USA)
- Finnish (93%)
- French (100%)
- French (Canada) (89.6%)
- German (100%)
- German (Switzerland) (99.8%)
- Greek (79.9%)
- Hindi (99.9%)
- Italian (98.2%)
- Norwegian Bokmål (65.8%)
- Occitan (post 1500) (71.2%)
- Persian (53.5%)
- Polish (94.9%)
- Portuguese (100%)
- Portuguese (Brazil) (83%)
- Slovak (95.3%)
- Spanish (99.8%)
- Swedish (95%)
- Turkish (99.9%)
- Vietnamese (65.9%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 18.05.02 is

- Release Manager: [Nick Clemens](mailto:nick@bywatersolutions.com)
- Release Manager assistants:
  - [Brendan Gallagher](mailto:brendan@bywatersolutions.com)
  - [Jonathan Druart](mailto:jonathan.druart@bugs.koha-community.org)
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
  - [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)

- Module Maintainers:
  - REST API -- [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
  - Elasticsearch -- [Nick Clemens](mailto:nick@bywatersolutions.com)
- QA Manager: [Katrin Fischer](mailto:Katrin.Fischer@bsz-bw.de)

- QA Team:
  - [Julian Maurice](mailto:julian.maurice@biblibre.com)
  - [Marcel de Rooy](mailto:m.de.rooy@rijksmuseum.nl)
  - Josef Moravec
  - [Alex Arnaud](mailto:alex.arnaud@biblibre.com)
  - [Martin Renvoize](mailto:martin.renvoize@ptfs-europe.com)
  - [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
  - [Jonathan Druart](mailto:jonathan.druart@bugs.koha-community.org)
  - [Chris Cormack](mailto:chrisc@catalyst.net.nz)
- Bug Wranglers:
  - Claire Gravely
  - Jon Knight
  - [Indranil Das Gupta](mailto:indradg@l2c2.co.inc)
  - [Amit Gupta](mailto:amitddng135@gmail.com)
- Packaging Manager: [Mirko Tietgen](mailto:mirko@abunchofthings.net)
- Documentation Team:
  - Lee Jamison
  - David Nind
  - Caroline Cyr La Rose
- Translation Manager: [Bernardo Gonzalez Kriegel](mailto:bgkriegel@gmail.com)
- Release Maintainers:
  - 18.05 -- [Martin Renvoize](mailto:martin.renvoize@ptfs-europe.com)
  - 17.11 -- [Fridolin Somers](mailto:fridolin.somers@biblibre.com)
  - 17.05 -- [Fridolin Somers](mailto:fridolin.somers@biblibre.com)

## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 18.05.02:

- Gothenburg University Library

We thank the following individuals who contributed patches to Koha 18.05.02.

- xljoha (1)
- Alex Arnaud (1)
- Alex Buckley (1)
- Colin Campbell (1)
- Jérôme Charaoui (1)
- Nick Clemens (11)
- Tomás Cohen Arazi (8)
- Marcel de Rooy (8)
- Jonathan Druart (14)
- Charles Farmer (1)
- Katrin Fischer (9)
- Bernardo González Kriegel (4)
- Caitlin Goodger (1)
- Victor Grousset (3)
- Amit Gupta (1)
- Pasi Kallinen (2)
- David Kuhn (1)
- Owen Leonard (15)
- Julian Maurice (4)
- Kyle M Hall (3)
- Josef Moravec (3)
- Martin Renvoize (7)
- Fridolin Somers (2)
- Mirko Tietgen (3)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 18.05.02

- abunchofthings.net (3)
- ACPL (15)
- BibLibre (10)
- BSZ BW (9)
- bugs.koha-community.org (14)
- ByWater-Solutions (13)
- bywatetsolutions.com (1)
- Catalyst (1)
- cmaisonneuve.qc.ca (1)
- Göteborgs universitet (1)
- informaticsglobal.com (1)
- inLibro.com (1)
- joensuu.fi (2)
- PTFS-Europe (8)
- Rijksmuseum (8)
- Theke Solutions (8)
- unidentified (4)
- Universidad Nacional de Córdoba (4)
- wegc.school.nz (1)

We also especially thank the following individuals who tested patches
for Koha.

- Hugo Agud (1)
- Aleisha Amohia (1)
- Alex Arnaud (5)
- Colin Campbell (1)
- Nick Clemens (109)
- Tomas Cohen Arazi (10)
- Chris Cormack (6)
- Marcel de Rooy (19)
- Jonathan Druart (19)
- Charles Farmer (5)
- Katrin Fischer (50)
- Bernardo Gonzalez Kriegel (2)
- Amit Gupta (1)
- Pasi Kallinen (2)
- Pierre-Luc Lapointe (3)
- Owen Leonard (5)
- Julian Maurice (3)
- Kyle M Hall (4)
- Josef Moravec (17)
- Séverine QUEUNE (4)
- Martin Renvoize (114)
- Maryse Simard (7)
- Mirko Tietgen (6)
- Mark Tompsett (3)
- Cab Vinton (1)


We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 18.05.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 20 Jul 2018 14:56:19.
