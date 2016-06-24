# RELEASE NOTES FOR KOHA 3.22.8
24 Jun 2016

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 3.22.8 can be downloaded from:

- [Download](http://download.koha-community.org/koha-3.22.08.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 3.22.8 is a security release.

It includes 2 security fixes, 49 bugfixes and 7 enhancements.

## Security bugs fixed

- [[16597]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16597) Reflected XSS in [opac-]shelves and [opac-]shareshelf
- [[16599]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16599) XSS found in opac-shareshelf.pl

## Critical bugs fixed

### Architecture, internals, and plumbing

- [[16229]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16229) Koha::Cache should be on the safe side
- [[16443]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16443) C4::Members::Statistics is not plack safe
- [[16518]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16518) opac-addbybiblionumber is not plack safe

### Installation and upgrade (web-based installer)

- [[13669]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13669) Web installer fails to load sample data on MySQL 5.6+

### Packaging

- [[16617]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16617) debian/control is broken

### Patrons

- [[16504]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16504) All borrower attribute values for a given code deleted if that attribute has branch limits

### SIP2

- [[16492]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16492) Checkouts ( and possibly checkins and other actions ) will use the patron home branch as the logged in library
- [[16610]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16610) Regression in SIP2 user password handling


## Other bugs fixed

### Acquisitions

- [[16385]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16385) Fix breadcrumbs when ordering from subscription

### Architecture, internals, and plumbing

- [[15333]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15333) Use Koha::Cache for caching all holidays
- [[16088]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16088) Excessive CGI->new() calls hurting cache performace under plack
- [[16412]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16412) Cache undef in L1 only
- [[16428]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16428) The framework is not checked to know if a field is mapped
- [[16441]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16441) C4::Letters::getletter is not plack safe
- [[16442]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16442) C4::Ris is not plack safe
- [[16444]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16444) C4::Tags is not plack safe
- [[16455]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16455) TagsExternalDictionary does not work under Plack
- [[16565]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16565) additional_fields and additional_field_values are not dropped in kohastructure.sql
- [[16578]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16578) Wide character warning in opac-export.pl when utf8 chosen
- [[16667]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16667) Unused variable and function call in circulation.pl

### Cataloging

- [[14897]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14897) Header name mismatch in ./modules/catalogue/detail.tt
- [[16613]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16613) MARC 09X Field Help Links are Broken

### Circulation

- [[16200]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16200) 'Hold waiting too long' fee has a translation problem
- [[16569]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16569) Message box for "too many checked out" is empty if AllowTooManyOverride is not enabled

### I18N/L10N

- [[15676]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15676) Actions in pending offline circulation actions are not translatable
- [[16540]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16540) Translatability in opac-auth.tt (tag-splitted sentences)
- [[16620]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16620) Translatability: Fix problem with isolated word "please" in auth.tt
- [[16633]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16633) Translatability: Issues in tags/review.tt (sentence splitting)
- [[16634]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16634) Translatability: Fix issue in memberentrygen.tt

### OPAC

- [[16343]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16343) 7XX XSLT subfields displaying out of order
- [[16465]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16465) OPAC discharge page has no title tag

### Packaging

- [[16695]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16695) Exception::Class 1.39 is not packaged for Jessie

### Patrons

- [[14605]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14605) The description on pay/write off individual fine is wrong
- [[16458]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16458) Setting to guarantor: JavaScript error form.branchcode is undefined
- [[16508]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16508) User permission "parameters_remaining_permissions Remaining system parameters permissions" does not allow saving systempreferences.

### System Administration

- [[15641]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15641) Typo in explanation for MembershipExpiryDaysNotice

### Templates

- [[16001]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16001) Use standard message dialog when there are no cities to list
- [[16454]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16454) Use "inventory" instead of "inventory/stocktaking"
- [[16608]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16608) Missing entity nbsp in some XML files
- [[16642]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16642) Fix capitalisation for upload patron image

### Test Suite

- [[16216]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16216) Circulation_Branch.t doesn't set itemtype for test data
- [[16582]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16582) t/Price.t test should pass if Test::DBIx::Class is not available
- [[16635]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16635) t/00-load.t warning from C4/Barcodes/hbyymmincr.pm
- [[16636]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16636) t/00-load.t warning from C4/External/BakerTaylor.pm
- [[16637]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16637) Dependency for C4::Tags not listed
- [[16668]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16668) Fix t/Ris.t (follow-up for 16442)
- [[16675]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16675) fix breakage of t/Languages.t

### Tools

- [[16548]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16548) All libraries selected on Tools -> Export Data screen
- [[16589]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16589) Quote of the day: Fix upload with csv files associated to LibreOffice Calc

## Enhancements

### Acquisitions

- [[16511]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16511) Making contracts actions buttons
- [[16525]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16525) Have cancel button when adding new aq budget

### Architecture, internals, and plumbing

- [[16044]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16044) Define a L1 cache for all objects set in cache
- [[16199]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16199) C4::Ris::charconv is one of the less useful subroutines ever written
- [[16221]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16221) Use Storable::dclone() instead of Clone::clone() for L1 cache deep-copying mode

### Documentation

- [[16537]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16537) Overdue and Status triggers grammar

### System Administration

- [[16165]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16165) Include link to ILS-DI documentation page in ILS-DI system preference



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
- Armenian (100%)
- Chinese (China) (95%)
- Chinese (Taiwan) (99%)
- Czech (97%)
- Danish (78%)
- English (New Zealand) (99%)
- Finnish (98%)
- French (92%)
- French (Canada) (93%)
- German (100%)
- German (Switzerland) (99%)
- Greek (81%)
- Italian (100%)
- Korean (58%)
- Kurdish (55%)
- Norwegian Bokmål (64%)
- Persian (65%)
- Polish (100%)
- Portuguese (96%)
- Portuguese (Brazil) (96%)
- Slovak (99%)
- Spanish (100%)
- Swedish (83%)
- Turkish (99%)
- Vietnamese (79%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

for information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 3.22.8 is

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
new features in Koha 3.22.8:

- Catalyst IT

We thank the following individuals who contributed patches to Koha 3.22.8.

- Blou (1)
- phette23 (1)
- Aleisha (3)
- Jacek Ablewicz (1)
- Dimitris Antonakis (1)
- Hector Castro (1)
- Galen Charlton (1)
- Tomás Cohen Arazi (4)
- Chris Cormack (2)
- Rocio Dressler (1)
- Jonathan Druart (38)
- Katrin Fischer (1)
- Brendan Gallagher (1)
- Bernardo González Kriegel (1)
- Claire Gravely (2)
- Owen Leonard (3)
- Kyle M Hall (4)
- Julian Maurice (1)
- Aliki Pavlidou (1)
- Robin Sheat (1)
- Fridolin Somers (2)
- Lari Taskula (2)
- Mark Tompsett (4)
- Marc Véron (5)
- Marcel de Rooy (8)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 3.22.8

- ACPL (3)
- arts.ac.uk (2)
- BibLibre (3)
- biblos.pk.edu.pl (1)
- BSZ BW (1)
- bugs.koha-community.org (38)
- bwstest.bywatersolutions.com (1)
- ByWater-Solutions (5)
- Catalyst (2)
- kallisti.net.nz (1)
- Marc Véron AG (5)
- Rijksmuseum (8)
- Solutions inLibro inc (1)
- student.uef.fi (2)
- Theke Solutions (2)
- unidentified (12)
- Universidad Nacional de Córdoba (3)

We also especially thank the following individuals who tested patches
for Koha.

- Brendan Gallagher (36)
- Chris Cormack (12)
- Dani Elder (1)
- Florent Mara (1)
- Frédéric Demians (59)
- Galen Charlton (1)
- Hector Castro (1)
- Jacek Ablewicz (6)
- Jesse Weaver (10)
- Jonathan Druart (28)
- Joy Nelson (1)
- Julian Maurice (89)
- Katrin Fischer (6)
- Marc Veron (1)
- Marc Véron (5)
- Mark Tompsett (2)
- Mirko Tietgen (2)
- Nick Clemens (4)
- Nicolas Legrand (1)
- Olli-Antti Kivilahti (2)
- Owen Leonard (5)
- Rocio Dressler (2)
- Sabine Liebmann (1)
- Sofia (1)
- Srdjan (12)
- Trent Roby (1)
- Katrin Fischer  (3)
- Tomas Cohen Arazi (13)
- Nicole C Engard (1)
- Brendan A Gallagher (6)
- Kyle M Hall (45)
- Bernardo Gonzalez Kriegel (4)
- Marcel de Rooy (34)
- Brendan Gallagher brendan@bywatersolutions.com (1)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 3.22.x.
The last Koha 3.22.x release was 3.22.7, which was released on May 25, 2016.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 24 Jun 2016 10:01:38.
