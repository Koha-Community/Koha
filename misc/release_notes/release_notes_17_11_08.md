# RELEASE NOTES FOR KOHA 17.11.08
26 juil. 2018

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 17.11.08 can be downloaded from:

- [Download](http://download.koha-community.org/koha-17.11.08.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 17.11.08 is a bugfix/maintenance release.

It includes 3 enhancements, 41 bugfixes.




## Enhancements

### I18N/L10N

- [[20709]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20709) Update GERMAN MARC frameworks to Updates 23-26 (Nov 2016, May and Apr 2018)

### MARC Bibliographic data support

- [[19835]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19835) Update MARC frameworks to Updates 23+24+25 (Nov 2016, May and Dec 2017)

### OPAC

- [[20876]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20876) The form_serialized_itype cookie is not used and should be removed


## Critical bugs fixed

### Acquisitions

- [[20972]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20972) If ISBN has 10 numbers only the first 9 numbers are used
- [[20979]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20979) Error message when deleting bib attached to order

### Authentication

- [[20879]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20879) Shibboleth in combination with LDAP as an alternative no longer works

### Installation and upgrade (web-based installer)

- [[20745]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20745) indexing/searching not active at end of installation

### Packaging

- [[20693]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20693) Plack fails, because 'libcgi-emulate-psgi-perl' package is not installed

### Patrons

- [[20903]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20903) Print payment receipt on child patron could end with server error
- [[20951]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20951) Koha::Patron::Discharge is missing use Koha::Patron::Debarments

### SIP2

- [[21020]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21020) Return branch not set for transfer when using SIP

### Self checkout

- [[21054]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21054) Extra closing body tag in sco-main.tt prevents slip printing

### Staff Client

- [[20998]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20998) Non superlibrarians cannot search for patrons using the quicksearch at the top

### System Administration

- [[20216]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20216) Editing itemtypes does not pull existing values correctly

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

### Circulation

- [[20793]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20793) Don't show holds link in result list when staff user doesn't have place_holds permission
- [[20794]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20794) Don't show holds tab when user doesn't have circulate_remaining_permissions
- [[21019]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21019) [17.11] Borrower address not shown on reserve pop-up on returns.pl

### Command-line Utilities

- [[20893]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20893) batchRebuildItemsTables.pl has incorrect parameter

### I18N/L10N

- [[21029]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21029) "Suspend until" in modal in staff patron account is not translatable

### Lists

- [[17886]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17886) Don't show option to add to existing list if there are no lists in staff

### MARC Bibliographic data support

- [[20700]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20700) Update MARC21 leader/007/008 codes

### OPAC

- [[17869]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17869) Don't show pick-up library for list of holds in OPAC account when there is only one branch
- [[18856]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18856) Cancel Waiting Hold in OPAC does not give useful message
- [[19849]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19849) Rebase of bug 16621 partially reverted bug 12509
- [[20507]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20507) Shelf browser does not update image sources when paging

### Packaging

- [[20920]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20920) Plack timeout because of missing CGI::Compile Perl dependency

### Patrons

- [[20008]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20008) Restrictions added from memberentry.pl have expiration date ignored if TimeFormat is 12hr
- [[20991]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20991) Error will reset category when editing a patron

### Reports

- [[16653]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16653) reports/cat_issues_top.pl does not export "Count of checkouts" column as CSV
- [[20945]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20945) Report params not escaped when downloading

### Searching

- [[19873]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19873) Make it possible to search on value 0

### Searching - Elasticsearch

- [[17373]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17373) Elasticsearch - Authority mappings for UNIMARC

### Searching - Zebra

- [[20697]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20697) Remove some Host-Item-Number noise from zebra-output.log when EasyAnalyticalRecords is not used

### Serials

- [[7136]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7136) Correct description of Grace period for subscriptions

### Staff Client

- [[18521]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18521) Renew and search hotkeys are swapped on returns page.

### Templates

- [[20559]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20559) Occurrences of loading-small.gif still exist
- [[20881]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20881) Order receiving: Price filter missing on_editing
- [[20999]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20999) Remove invalid 'style="block"' from OPAC templates

### Test Suite

- [[20175]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20175) Set a correct default value for club_enrollments.date_created



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

- [Koha Manual](http://koha-community.org/manual/17.11/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (99.5%)
- Armenian (100%)
- Basque (75.5%)
- Chinese (China) (79.8%)
- Chinese (Taiwan) (99.9%)
- Czech (93.9%)
- Danish (65.8%)
- English (New Zealand) (99.5%)
- English (USA)
- Finnish (95.7%)
- French (98.4%)
- French (Canada) (92.1%)
- German (100%)
- German (Switzerland) (99.5%)
- Greek (81%)
- Hindi (100%)
- Italian (99.9%)
- Norwegian Bokmål (54.6%)
- Occitan (post 1500) (72.9%)
- Persian (54.9%)
- Polish (97.6%)
- Portuguese (100%)
- Portuguese (Brazil) (84.5%)
- Slovak (96.7%)
- Spanish (99.9%)
- Swedish (91.8%)
- Turkish (100%)
- Vietnamese (67.5%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 17.11.08 is

- Release Manager: [Jonathan Druart](mailto:jonathan.druart@bugs.koha-community.org)
- Release Manager assistant: [Nick Clemens](mailto:nick@bywatersolutions.com)

- QA Team:
  - [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
  - [Brendan Gallagher](mailto:brendan@bywatersolutions.com)
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
  - [Julian Maurice](mailto:julian.maurice@biblibre.com)
  - [Marcel de Rooy](mailto:m.de.rooy@rijksmuseum.nl)
- Bug Wranglers:
  - [Amit Gupta](mailto:amitddng135@gmail.com)
  - Claire Gravely
  - Josef Moravec
  - [Marc Véron](mailto:veron@veron.ch)
- Packaging Manager: [Mirko Tietgen](mailto:mirko@abunchofthings.net)
- Documentation Team:
  - [Chris Cormack](mailto:chrisc@catalyst.net.nz)
  - [Katrin Fischer](mailto:Katrin.Fischer@bsz-bw.de)
- Translation Manager: [Bernardo Gonzalez Kriegel](mailto:bgkriegel@gmail.com)
- Release Maintainers:
  - 17.05 -- [Fridolin Somers](mailto:fridolin.somers@biblibre.com)

## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 17.11.08:

- ByWater Solutions
- Gothenburg University Library

We thank the following individuals who contributed patches to Koha 17.11.08.

- xljoha (1)
- Alex Arnaud (4)
- Alex Buckley (1)
- Colin Campbell (1)
- Jérôme Charaoui (1)
- Nick Clemens (5)
- Tomás Cohen Arazi (1)
- Marcel de Rooy (3)
- Jonathan Druart (12)
- Katrin Fischer (6)
- Bernardo González Kriegel (4)
- Caitlin Goodger (1)
- Victor Grousset (3)
- Pasi Kallinen (1)
- Owen Leonard (6)
- Julian Maurice (2)
- Kyle M Hall (3)
- Josef Moravec (1)
- Martin Renvoize (4)
- Fridolin Somers (3)
- Mirko Tietgen (3)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 17.11.08

- abunchofthings.net (6)
- ACPL (6)
- BibLibre (12)
- BSZ BW (6)
- bugs.koha-community.org (12)
- ByWater-Solutions (5)
- bywatetsolutions.com (3)
- Catalyst (1)
- cmaisonneuve.qc.ca (1)
- Göteborgs universitet (1)
- joensuu.fi (1)
- PTFS-Europe (5)
- Rijksmuseum (3)
- Theke Solutions (1)
- unidentified (1)
- Universidad Nacional de Córdoba (4)
- wegc.school.nz (1)

We also especially thank the following individuals who tested patches
for Koha.

- Colin Campbell (1)
- Nick Clemens (51)
- Tomas Cohen Arazi (9)
- Chris Cormack (1)
- Roch D'Amour (1)
- Marcel de Rooy (12)
- Jonathan Druart (25)
- Charles Farmer (2)
- Katrin Fischer (25)
- Brendan Gallagher (2)
- Bernardo Gonzalez Kriegel (2)
- Amit Gupta (1)
- Pasi Kallinen (1)
- Pierre-Luc Lapointe (2)
- Nicolas Legrand (2)
- Owen Leonard (6)
- Julian Maurice (8)
- Kyle M Hall (3)
- Josef Moravec (9)
- Martin Renvoize (52)
- Maryse Simard (3)
- Fridolin Somers (63)
- Mirko Tietgen (4)
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
line is 17.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 26 juil. 2018 08:24:57.
