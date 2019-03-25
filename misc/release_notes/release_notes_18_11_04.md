# RELEASE NOTES FOR KOHA 18.11.04
25 Mar 2019

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 18.11.04 can be downloaded from:

- [Download](http://download.koha-community.org/koha-18.11.04.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 18.11.04 is a bugfix/maintenance release.

It includes 3 new features, 5 enhancements, 84 bugfixes.



## New features

### REST api

- [[16497]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16497) Add API routes for libraries
- [[22206]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22206) Add route to handle holds suspensions

### Serials

- [[21467]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21467) Allow several receipts for a given subscription

> Allows the user to set a quantity for a serial order, useful in the case where payments are made per receipt of individual issues. This development also allows for altering the total expected quantity for a serial in the case of a periodicity change.



## Enhancements

### Acquisitions

- [[18166]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18166) Show internal and vendor notes for received orders

> Prior to this patch, internal and vendor notes would not be visible for received orders, but only for pending orders.



### Patrons

- [[16276]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16276) When automatically deleting expired borrowers, make sure they didn't log in recently

> Correction to update statement, feature actually added in 16.11.



### REST api

- [[20006]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20006) Adapt /v1/holds to new naming guidelines

### Test Suite

- [[21798]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21798) We need t::lib::TestBuilder::build_sample_biblio
- [[21971]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21971) TestBuilder::build_sample_item


## Critical bugs fixed

### Acquisitions

- [[18736]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18736) Problems in order calculations (rounding errors)

> This patch introduces to new system preference to govern how rounding is applied to values in acquisitions. It defaults to the american practice of rounding to the nearest 'cent' but future options should become available as we start to understand how other nations round for accounting purposes.


- [[22296]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22296) Invoice adjustments are not populating to budget views
- [[22498]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22498) Can not select any funds for invoice adjustments
- [[22565]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22565) Partially receiving order and adding internal note on invoice updates note on every order on the system

### Architecture, internals, and plumbing

- [[22388]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22388) svc/split_callnumbers should have execute flag set

### Cataloging

- [[16251]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16251) Material type is not correctly set for Rancor 008 widget
- [[22140]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22140) More use of EasyAnalyticalRecords pref

### Command-line Utilities

- [[22396]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22396) koha-sip script does not start the server correctly

### Database

- [[13515]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13515) Table messages is missing FK constraints and is never cleaned up
- [[22476]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22476) MarkLostItemsAsReturned has wrong defaults for new installs

### Label/patron card printing

- [[22275]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22275) 18.06.00.060 DB update fails (incomplete/incorrect defaults)
- [[22429]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22429) Infinite loop in patron card printing

### OPAC

- [[22360]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22360) On order information missing in OPAC normal display

### Patrons

- [[22386]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22386) Importing using attributes as matchpoint broken

### Reports

- [[21560]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21560) Optimize ODS exports

### Searching

- [[22442]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22442) Item search CSV export broken

### Searching - Elasticsearch

- [[19575]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19575) Use canonical field names and resolve aliased fields

> Sponsored by Gothenburg University Library


> This patchset makes some changes to Elasticsearch mappings in the database. The changes alter existing indices and are intended to fix issues with the current mappings, however, if you have done customization of mappings you may want to back them up before upgrading.


- [[20535]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20535) ModZebra called with $record with items stripped in ModBiblioMarc

### System Administration

- [[22389]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22389) Classification splitting sources regex - cannot consistentlyadd/delete

### Web services

- [[21832]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21832) Restore is_expired in ILS-DI GetPatronInfo service


## Other bugs fixed

### About

- [[7143]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7143) Bug for tracking changes to the about page

### Acquisitions

- [[14850]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14850) Funds from inactive budgets appear in 'Funds' dropdown on acqui/invoice.pl
- [[20782]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20782) EDI: Clicking the 'Invoice' link on the 'EDI Messages' page does not take you directly to the corresponding invoice
- [[21427]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21427) Format prices on ordered/spent lists
- [[21966]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21966) Fix descriptions of acquisition permissions to be more clear (again)
- [[22171]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22171) Format shipping cost on invoice.pl with with 2 decimals

### Architecture, internals, and plumbing

- [[18584]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18584) Our legacy code contains trailing-spaces
- [[21622]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21622) Incorrect GROUP BY clause in acqui/ scripts
- [[21987]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21987) Local cover 'thumbnail' size is bigger than 'imagefile' size in biblioimages table
- [[22084]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22084) Plugin upgrade method and database plugin version storage will never be triggered for existing installs
- [[22219]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22219) C4::Biblio->GetItemsForInventory can return wrong count / duplicated items when skipping waiting holds
- [[22391]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22391) Incorrect GROUP BY in /acqui/ajax-getauthvaluedropbox.pl

### Circulation

- [[13763]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13763) Renew feature does not check for the BarcodeInputFilter option

> Sponsored by Catalyst IT

- [[17236]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17236) Add minute and hours to last checked out item display for hourly loans
- [[18957]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18957) Item renewed online does not show the time of renewal
- [[21030]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21030) Date widget on suspend modal not working correctly
- [[22130]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22130) Batch checkout: authorized value description is never shown with notforloan status
- [[22351]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22351) SCSS conversion broke style on last checked out information

### Command-line Utilities

- [[12488]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12488) Make bulkmarcimport.pl -d use DELETE instead of TRUNCATE
- [[22323]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22323) Cronjob runreport.pl has a CSV encoding issue
- [[22397]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22397) Wrong message in koha-sip --start

### Developer documentation

- [[20544]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20544) Wrong comment in database documentation for items.itemnotes

### Hold requests

- [[21765]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21765) AutoUnsuspendReserves manually sets holds fields instead of calling ->resume

### Installation and upgrade (command-line installer)

- [[17496]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17496) install-CPAN.pl documentation/removal
- [[20174]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20174) Remove xml_sax.pl target from Makefile.pl

### Installation and upgrade (web-based installer)

- [[21710]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21710) Fix typo atributes in some installer files

### OPAC

- [[10676]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10676) OpacHiddenItems not working for restricted on OPAC detail
- [[21335]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21335) Remove redundant includes of right-to-left.css
- [[21846]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21846) Using emoji as tags doesn't discriminate between emoji when calculating weights or searching

> Please note, this patch fixes issues going forward. It includes a maintenance script to allow you to fix any possible existing cases. Please see bugzilla for details.



### Patrons

- [[22067]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22067) Koha::Patron->can_see_patron_infos should return if no patron is passed

### Reports

- [[18393]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18393) Statistics wizard for acquisitions not filtering correctly by collection code
- [[22147]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22147) Hide 'Batch modify' button when printing reports
- [[22287]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22287) Correct new charts CSS

### SIP2

- [[19832]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19832) SIP checkout removes extra hold on same biblio
- [[21997]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21997) SIP patron information requests can lock patron out of account

### Searching

- [[20823]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20823) UNIMARC XSLT does not display 604$t

### Searching - Elasticsearch

- [[22228]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22228) Elasticsearch - standalone colons should be escaped when performing a search
- [[22246]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22246) Elasticsearch indexing needs a maximum length for `__sort` fields

### Self checkout

- [[22378]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22378) Fix sound alerts on SCO

### Serials

- [[13735]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13735) Item form in serials module doesn't respect max length set in the frameworks
- [[15149]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15149) Serials: Test prediction pattern does not consider Subscription start and end date
- [[21845]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21845) Sort of issues in OPAC subscription table
- [[22156]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22156) Subscription result list sorts on "checkbox" by default
- [[22239]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22239) JavaScript error on subscription detail page when there are no orders
- [[22404]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22404) Some labels in subscription add form has wrong parameter "for"

### Staff Client

- [[19046]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19046) IntranetCatalogSearchPulldown doesn't retain last selection
- [[21904]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21904) Patron search library dropdown should be limited  by group if "Hide patron info" is enabled for group
- [[22419]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22419) Removing multiple records from intranet cart causes browser timeout

### System Administration

- [[18143]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18143) Silence floody MARC framework export
- [[22170]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22170) Library group description input field should be longer

### Templates

- [[8387]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8387) Hide headings in tools when user has no permissions for any listed below
- [[20102]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20102) Remove attribute "text/css" for style element used in staff client templates
- [[20658]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20658) Move template JavaScript to the footer: Installer and onboarding
- [[21130]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21130) Detail XSLT produces translatable HTML class
- [[22080]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22080) Easier translation of ElasticSearch mappings page
- [[22300]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22300) Staff search results: Opt groups in 'sort' pull down are not well formatted
- [[22303]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22303) Wrong bottom in virtualshelves/addbybiblionumber.tt
- [[22422]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22422) improve item location display with class "shelvingloc"
- [[22466]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22466) TT methods must not be escaped
- [[22477]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22477) Missing DataTables configuration when searching patrons for holds

### Test Suite

- [[21692]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21692) Koha::Account->new has no tests
- [[22416]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22416) Search.t tests need adjustment for EasyAnalyticRecords syspref
- [[22493]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22493) DecreaseLoanHighHolds.t creates some items/patrons with set values

### Tools

- [[22411]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22411) Dates in log viewer not formatted correctly

## New sysprefs

- OrderPriceRounding

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

- [Koha Manual](http://koha-community.org/manual/18.11/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (99%)
- Armenian (99.8%)
- Basque (63.4%)
- Chinese (China) (64.2%)
- Chinese (Taiwan) (100%)
- Czech (93.4%)
- Danish (55.6%)
- English (New Zealand) (88.6%)
- English (USA)
- Finnish (84.1%)
- French (95.7%)
- French (Canada) (100%)
- German (99.9%)
- German (Switzerland) (92.2%)
- Greek (77.5%)
- Hindi (100%)
- Italian (94.2%)
- Norwegian Bokmål (95.3%)
- Occitan (post 1500) (59.8%)
- Polish (86.3%)
- Portuguese (100%)
- Portuguese (Brazil) (85.7%)
- Slovak (90.5%)
- Spanish (97.9%)
- Swedish (90.8%)
- Turkish (98.8%)
- Ukrainian (61.9%)
- Vietnamese (53.5%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 18.11.04 is

- Release Manager: [Nick Clemens](mailto:nick@bywatersolutions.com)
- Release Manager assistants:
  - [Jonathan Druart](mailto:jonathan.druart@bugs.koha-community.org)
  - [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
- QA Manager: [Katrin Fischer](mailto:Katrin.Fischer@bsz-bw.de)
- QA Team:
  - [Alex Arnaud](mailto:alex.arnaud@biblibre.com)
  - [Julian Maurice](mailto:julian.maurice@biblibre.com)
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
  - Josef Moravec
  - [Martin Renvoize](mailto:martin.renvoize@ptfs-europe.com)
  - [Jonathan Druart](mailto:jonathan.druart@bugs.koha-community.org)
  - [Marcel de Rooy](mailto:m.de.rooy@rijksmuseum.nl)
  - [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
  - [Chris Cormack](mailto:chrisc@catalyst.net.nz)
- Topic Experts:
  - SIP2 -- Colin Campbell
  - EDI -- Colin Campbell
  - Elasticsearch -- Ere Maijala
  - REST API -- Tomás Cohen Arazi
  - UI Design -- Owen Leonard
- Bug Wranglers:
  - Luis Moises Rojas
  - Jon Knight
  - [Indranil Das Gupta](mailto:indradg@l2c2.co.in)
- Packaging Manager: [Mirko Tietgen](mailto:mirko@abunchofthings.net)
- Documentation Manager: Caroline Cyr La Rose
- Documentation Team:
  - David Nind
  - Lucy Vaux-Harvey

- Translation Managers: 
  - [Indranil Das Gupta](mailto:indradg@l2c2.co.in)
  - [Bernardo Gonzalez Kriegel](mailto:bgkriegel@gmail.com)

- Wiki curators: 
  - Caroline Cyr La Rose
- Release Maintainers:
  - 18.11 -- [Martin Renvoize](mailto:martin.renvoize@ptfs-europe.com)
  - 18.05 -- Lucas Gass
  - 18.05 -- Jesse Maseto
  - 17.11 -- [Fridolin Somers](mailto:fridolin.somers@biblibre.com)
- Release Maintainer assistants:
  - 18.05 -- [Kyle Hall](mailto:kyle@bywatersolutions.com)

## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 18.11.04:

- Catalyst IT
- Gothenburg University Library

We thank the following individuals who contributed patches to Koha 18.11.04.

- Jasmine Amohia (2)
- Tomás Cohen Arazi (24)
- Alex Arnaud (2)
- Philippe Blouin (1)
- David Bourgault (1)
- Nick Clemens (31)
- David Cook (1)
- Jonathan Druart (32)
- Magnus Enger (1)
- Katrin Fischer (17)
- David Gustafsson (5)
- Kyle Hall (5)
- Jiří Kozlovský (1)
- Owen Leonard (11)
- Ere Maijala (2)
- Hayley Mapley (2)
- Julian Maurice (1)
- Josef Moravec (8)
- Martin Renvoize (14)
- Marcel de Rooy (5)
- Fridolin Somers (17)
- Pierre-Marc Thibault (1)
- Mark Tompsett (3)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 18.11.04

- ACPL (11)
- BibLibre (20)
- BSZ BW (17)
- ByWater-Solutions (36)
- Catalyst (2)
- f1ebe1bec408 (1)
- Göteborgs Universitet (4)
- Independant Individuals (12)
- jkozlovsky.cz (1)
- Koha Community Developers (32)
- Libriotech (1)
- Prosentient Systems (1)
- PTFS-Europe (14)
- Rijks Museum (5)
- Solutions inLibro inc (2)
- Theke Solutions (24)
- University of Helsinki (2)
- Wellington East Girls' College (2)

We also especially thank the following individuals who tested patches
for Koha.

- Jasmine Amohia (1)
- Tomás Cohen Arazi (20)
- Alex Arnaud (1)
- Oliver Behnke (1)
- Mikaël Olangcay Brisebois (5)
- Nick Clemens (185)
- Chris Cormack (1)
- Devlyn Courtier (2)
- Michal Denar (3)
- Jonathan Druart (10)
- Charles Farmer (3)
- Katrin Fischer (28)
- Lucas Gass (1)
- Claire Gravely (1)
- Kyle Hall (13)
- Jack Kelliher (1)
- Owen Leonard (13)
- Ere Maijala (1)
- Hayley Mapley (2)
- Julian Maurice (8)
- Janet McGowan (2)
- Jose-Mario Monteiro-Santos (3)
- Josef Moravec (66)
- David Nind (4)
- Björn Nylen (1)
- Séverine Queune (7)
- Martin Renvoize (243)
- Benjamin Rokseth (2)
- Marcel de Rooy (32)
- Maryse Simard (3)
- Pierre-Marc Thibault (12)
- Bin Wen (4)
- Nazlı Çetin (2)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 18.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 25 Mar 2019 17:15:20.
