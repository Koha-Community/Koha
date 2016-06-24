# RELEASE NOTES FOR KOHA 16.5.1
24 juin 2016

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 16.5.1 can be downloaded from:

- [Download](http://download.koha-community.org/koha-16.05.01.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 16.5.1 is a bugfix/maintenance release.

It includes 20 enhancements, 67 bugfixes.


## Enhancements

### Acquisitions

- [[16511]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16511) Making contracts actions buttons
- [[16525]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16525) Have cancel button when adding new aq budget

### Architecture, internals, and plumbing

- [[16693]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16693) reserve/renewscript.pl is not used and should be removed

### Documentation

- [[16537]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16537) Overdue and Status triggers grammar

### Hold requests

- [[16336]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16336) UX of holds patron search with long lists of results

### Packaging

- [[16647]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16647) Update debian/control for 16.*

### Patrons

- [[12402]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12402) Show more on pending patron modification requests
- [[16729]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16729) Use member-display-address-style*-includes when printing user summary

### Reports

- [[16388]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16388) Move option to download report into reports toolbar

### Searching

- [[16524]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16524) Use floating toolbar on item search

### System Administration

- [[16165]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16165) Include link to ILS-DI documentation page in ILS-DI system preference

### Templates

- [[16005]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16005) Standardize use of icons for delete and cancel operations
- [[16127]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16127) Add discharge menu item to patron toolbar
- [[16437]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16437) Automatic item modifications by age needs prettying
- [[16450]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16450) Remove the use of "onclick" from guarantor search template
- [[16456]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16456) Add Font Awesome icons to some buttons in Tools module, section Patrons and circulation
- [[16541]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16541) Make edit and delete links styled buttons in cities administration
- [[16543]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16543) Make edit and delete links styled buttons in patron attribute types administration
- [[16592]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16592) Use Bootstrap modal for MARC and Card preview on acquisitions receipt summary page

### Tools

- [[15213]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15213) Fix tools sidebar to highlight Patron lists when in that module


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[16443]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16443) C4::Members::Statistics is not plack safe
- [[16518]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16518) opac-addbybiblionumber is not plack safe

### Circulation

- [[16570]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16570) All checked-in items are said to be part of a rotating collection

### Installation and upgrade (web-based installer)

- [[16619]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16619) Installer stuck in infinite loop
- [[16678]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16678) updatedatabase.pl 3.23.00.006 DB upgrade crashes if subscription_numberpatterns.numberingmethod contains parentheses

### Label/patron card printing

- [[16747]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16747) Fix regression in patron card creator (patron image)

### Packaging

- [[16617]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16617) debian/control is broken

### Patrons

- [[16504]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16504) All borrower attribute values for a given code deleted if that attribute has branch limits

### SIP2

- [[16492]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16492) Checkouts ( and possibly checkins and other actions ) will use the patron home branch as the logged in library
- [[16610]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16610) Regression in SIP2 user password handling


## Other bugs fixed

### About

- [[7143]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7143) Bug for tracking changes to the about page

### Architecture, internals, and plumbing

- [[13074]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13074) C4::Items::_build_default_values_for_mod_marc should use Koha::Cache
- [[16088]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16088) Excessive CGI->new() calls hurting cache performace under plack
- [[16428]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16428) The framework is not checked to know if a field is mapped
- [[16441]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16441) C4::Letters::getletter is not plack safe
- [[16442]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16442) C4::Ris is not plack safe
- [[16444]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16444) C4::Tags is not plack safe
- [[16455]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16455) TagsExternalDictionary does not work under Plack
- [[16502]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16502) Table koha_plugin_com_bywatersolutions_kitchensink_mytable not always dropped after running Plugin.t
- [[16565]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16565) additional_fields and additional_field_values are not dropped in kohastructure.sql
- [[16578]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16578) Wide character warning in opac-export.pl when utf8 chosen
- [[16667]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16667) Unused variable and function call in circulation.pl
- [[16670]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16670) CGI->param used in list context
- [[16720]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16720) DBIx ActionLogs.pm should be removed

### Cataloging

- [[14897]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14897) Header name mismatch in ./modules/catalogue/detail.tt
- [[16613]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16613) MARC 09X Field Help Links are Broken

### Circulation

- [[16200]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16200) 'Hold waiting too long' fee has a translation problem
- [[16569]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16569) Message box for "too many checked out" is empty if AllowTooManyOverride is not enabled
- [[16596]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16596) branchcode and categorycode are displayed instead of their description on patron search result

### Database

- [[10459]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10459) borrowers should have a timestamp

### I18N/L10N

- [[15676]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15676) Actions in pending offline circulation actions are not translatable
- [[16540]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16540) Translatability in opac-auth.tt (tag-splitted sentences)
- [[16560]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16560) Translatability: Issues in opac-memberentry.tt
- [[16563]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16563) Translatability: Issues in opac-account.tt (sentence splitting)
- [[16620]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16620) Translatability: Fix problem with isolated word "please" in auth.tt
- [[16633]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16633) Translatability: Issues in tags/review.tt (sentence splitting)
- [[16634]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16634) Translatability: Fix issue in memberentrygen.tt

### OPAC

- [[16465]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16465) OPAC discharge page has no title tag
- [[16597]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16597) Reflected XSS in [opac-]shelves and [opac-]shareshelf
- [[16599]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16599) XSS found in opac-shareshelf.pl

### Packaging

- [[16695]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16695) Exception::Class 1.39 is not packaged for Jessie

### Patrons

- [[14605]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14605) The description on pay/write off individual fine is wrong
- [[16458]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16458) Setting to guarantor: JavaScript error form.branchcode is undefined
- [[16508]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16508) User permission "parameters_remaining_permissions Remaining system parameters permissions" does not allow saving systempreferences.

### Serials

- [[12748]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12748) Serials - two issues with status of "Expected"
- [[16692]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16692) Error "No method update!" when creating new serial issue

### System Administration

- [[15641]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15641) Typo in explanation for MembershipExpiryDaysNotice
- [[16532]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16532) Libraries and groups showing empty tables if nothing defined

### Templates

- [[16001]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16001) Use standard message dialog when there are no cities to list
- [[16529]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16529) Clean up and improve upload template
- [[16594]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16594) Orders by fund report has wrong link to css and other issues
- [[16608]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16608) Missing entity nbsp in some XML files
- [[16642]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16642) Fix capitalisation for upload patron image

### Test Suite

- [[16500]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16500) Catch two warns in TestBuilder.t with warning_like
- [[16582]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16582) t/Price.t test should pass if Test::DBIx::Class is not available
- [[16607]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16607) Remove CPL/MPL from two unit tests
- [[16609]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16609) Catch warning from Koha::Hold in Hold.t
- [[16618]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16618) 00-load.t prematurely stops all testing
- [[16635]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16635) t/00-load.t warning from C4/Barcodes/hbyymmincr.pm
- [[16636]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16636) t/00-load.t warning from C4/External/BakerTaylor.pm
- [[16637]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16637) Dependency for C4::Tags not listed
- [[16649]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16649) OpenLibrarySearch.t fails when building packages
- [[16668]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16668) Fix t/Ris.t (follow-up for 16442)
- [[16675]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16675) fix breakage of t/Languages.t
- [[16717]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16717) Remove hardcoded category from Holds.t

### Tools

- [[16548]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16548) All libraries selected on Tools -> Export Data screen
- [[16589]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16589) Quote of the day: Fix upload with csv files associated to LibreOffice Calc



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
- Armenian (97%)
- Chinese (China) (90%)
- Chinese (Taiwan) (100%)
- Czech (96%)
- Danish (75%)
- English (New Zealand) (99%)
- Finnish (94%)
- French (90%)
- French (Canada) (90%)
- German (100%)
- German (Switzerland) (99%)
- Greek (79%)
- Italian (99%)
- Korean (55%)
- Kurdish (53%)
- Norwegian Bokmål (61%)
- Persian (62%)
- Polish (100%)
- Portuguese (93%)
- Portuguese (Brazil) (92%)
- Slovak (95%)
- Spanish (100%)
- Swedish (80%)
- Turkish (99%)
- Vietnamese (76%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

for information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 16.5.1 is

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
new features in Koha 16.5.1:

- Catalyst IT

We thank the following individuals who contributed patches to Koha 16.5.1.

- Blou (1)
- Liz (1)
- phette23 (1)
- remi (2)
- Aleisha (6)
- Jacek Ablewicz (1)
- Dimitris Antonakis (1)
- Hector Castro (2)
- Galen Charlton (2)
- Tomás Cohen Arazi (4)
- Chris Cormack (5)
- Frédéric Demians (2)
- Marcel de Rooy (17)
- Rocio Dressler (1)
- Jonathan Druart (39)
- Brendan Gallagher (2)
- Claire Gravely (2)
- Owen Leonard (12)
- Julian Maurice (1)
- Kyle M Hall (6)
- Aliki Pavlidou (1)
- Liz Rea (1)
- Robin Sheat (1)
- Fridolin Somers (2)
- Lari Taskula (2)
- Mark Tompsett (6)
- Marc Véron (9)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 16.5.1

- ACPL (12)
- arts.ac.uk (2)
- BibLibre (3)
- biblos.pk.edu.pl (1)
- BigBallOfWax (3)
- bugs.koha-community.org (39)
- bwstest.bywatersolutions.com (1)
- ByWater-Solutions (8)
- Catalyst (4)
- inLibro.com (2)
- kallisti.net.nz (1)
- Marc Véron AG (9)
- Rijksmuseum (17)
- Solutions inLibro inc (1)
- student.uef.fi (2)
- Tamil (2)
- Theke Solutions (4)
- unidentified (19)

We also especially thank the following individuals who tested patches
for Koha.

- Aleisha (1)
- Brendan Gallagher (49)
- Chris Cormack (13)
- Florent Mara (1)
- Frédéric Demians (125)
- Galen Charlton (4)
- Hector Castro (1)
- Jacek Ablewicz (5)
- Jan Kissig (1)
- Jesse Weaver (3)
- Jonathan Druart (67)
- Joy Nelson (4)
- Katrin Fischer (2)
- Liz Rea (1)
- Marc Veron (2)
- Marc Véron (12)
- Mark Tompsett (4)
- mehdi (1)
- Mirko Tietgen (3)
- Nick Clemens (8)
- Nicolas Legrand (1)
- Olli-Antti Kivilahti (2)
- Owen Leonard (10)
- rainer (1)
- Rocio Dressler (3)
- Sabine Liebmann (1)
- Sinziana (1)
- Sofia (1)
- Srdjan (20)
- Trent Roby (1)
- Katrin Fischer  (3)
- Tomas Cohen Arazi (3)
- Nicole C Engard (1)
- Kyle M Hall (86)
- Bernardo Gonzalez Kriegel (8)
- Marcel de Rooy (44)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 16.05_juin24.
The last Koha release was 3.20.7.1, which was released on December 26, 2015.  

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 24 juin 2016 06:00:07.
