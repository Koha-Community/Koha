# RELEASE NOTES FOR KOHA 18.11.05
29 Apr 2019

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 18.11.05 can be downloaded from:

- [Download](http://download.koha-community.org/koha-18.11.05.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 18.11.05 is a bugfix/maintenance release with security fixes.

It includes 4 security fixes, 2 new features, 4 enhancements, 94 bugfixes.


## Security bugs

### Koha

- [[22068]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22068) Canceling article request should verify the request belongs to the borrower
- [[22478]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22478) Cross-site scripting vulnerability in paginations
- [[22542]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22542) Back browser should not allow to see other patrons details (see bug 5371)
- [[22692]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22692) Logging in via cardnumber circumvents account logout

## New features

### REST api

- [[13895]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13895) Add routes for checkouts retrieval and renewal
- [[19661]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19661) Add routes for funds

## Enhancements

### Acquisitions

- [[22541]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22541) Invoice adjustments should show invoice number and include link on ordered.pl and spent.pl

### Architecture, internals, and plumbing

- [[21998]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21998) Add pattern parameter in Koha::Token

### MARC Bibliographic data support

- [[21899]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21899) Update MARC21 frameworks to Update 27 (November 2018)

### Templates

- [[21948]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21948) Clean up style of item detail page


## Critical bugs fixed

### Acquisitions

- [[20830]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20830) Make sure a fund is selected when ordering from staged file
- [[22390]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22390) When duplicating existing order lines new items are not created
- [[22611]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22611) Typo introduced into Koha::EDI by bug 15685

### Architecture, internals, and plumbing

- [[22618]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22618) Tests in t/Acquisition.t are actually context dependent
- [[22723]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22723) Syntax error on confess call in Koha/MetadataRecord/Authority.pm

### Authentication

- [[22461]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22461) Regression in #20287: LDAP user replication broken with mapped extended patron attributes

### Cataloging

- [[16232]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16232) Edit as new (duplicate) doesn't work correctly with Rancor

> Sponsored by Carnegie

- [[21049]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21049) Rancor 007 field does not retain value
- [[22288]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22288) Barcode file does not work in modifying items in batch

### Circulation

- [[21346]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21346) Clean up dialogs in returns.pl
- [[22648]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22648) Typo in SQL in smart-rules.pl

### Course reserves

- [[22652]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22652) Editing Course reserves is broken

### Database

- [[22642]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22642) DB upgrade 18.06.00.005 can fail

### Hold requests

- [[17978]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17978) Include 'Next available'/title level holds in holds count when placing holds (opac and staff)
- [[22753]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22753) Move hold to top button doesn't work if waiting holds exist

### Notices

- [[22139]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22139) Fields of ACCTDETAILS not working properly

### OPAC

- [[21589]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21589) Series link formed from 830 field is incorrect
- [[22735]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22735) Broken MARC and ISBD views

### Patrons

- [[22715]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22715) Searching for patrons with "" in the circulation note hangs patron search

### Searching - Elasticsearch

- [[21974]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21974) cxn_pool must be configurable

### Self checkout

- [[22641]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22641) Incorrect filter on SCO printslip

### Serials

- [[22621]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22621) Filters on subscription result list search the wrong column

### Templates

- [[13692]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13692) Series link is only using 800a instead of 800t


## Other bugs fixed

### Acquisitions

- [[21659]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21659) Link to basket groups from order receive page are broken
- [[22444]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22444) currencies_manage permission doesn't provide link to manage currencies when selected alone
- [[22762]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22762) Collection codes not displayed on receiving

### Architecture, internals, and plumbing

- [[18584]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18584) Our legacy code contains trailing-spaces
- [[21172]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21172) Warning in addbiblio.pl - Argument "01e" isn't numeric in numeric ne (!=)
- [[21622]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21622) Incorrect GROUP BY clause in acqui/ scripts
- [[22044]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22044) NoRenewalBeforePrecision should be set by default for new installations
- [[22451]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22451) Asset plugin is using the version from the DB
- [[22472]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22472) Should column_exists explode if the table does not exist?
- [[22607]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22607) Default value in issues.renewals should be '0' not null

### Cataloging

- [[10345]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10345) Copy number should be incremented when adding multiple items at once
- [[21937]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21937) Syspref autoBarcode annual doesn't increment properly barcode in some cases

### Circulation

- [[21013]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21013) Missing itemtype for checkut makes patron summary print explode
- [[22536]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22536) Display problem in Holds to Pull report

### Command-line Utilities

- [[17746]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17746) koha-reset-passwd should use Koha::Patron->set_password
- [[20692]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20692) koha-plack doesn't check for Include *-plack.conf line in /etc/apache2/sites-available/$INSTANCE.conf
- [[21975]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21975) Unnecessary substitutions in automatic item modification by age

### Course reserves

- [[21003]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21003) Don't show warning when editing a reserve item

### Database

- [[22634]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22634) Standardize table creation for stockrotation* tables in kohacstructure.sql

### Documentation

- [[19747]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19747) No help page linked for article requests
- [[22174]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22174) Add link to help page for API key management
- [[22687]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22687) Typo in Koha::Manual breaks Portuguese links

### Fines and fees

- [[22626]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22626) 'Filter paid transactions' broken on Transactions tab in staff

### Hold requests

- [[15505]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15505) Mark Hold Items 'On hold' instead of 'Available'

> Corrects the display of status for items on hold in the OPAC.


- [[21263]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21263) Pickup library not set correctly when using Default holds policy by item type
- [[22650]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22650) Can place multiple item level holds on a single item
- [[22688]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22688) TT plugin for pickup locations code wrong

### I18N/L10N

- [[19497]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19497) Translatability: Get rid of "Edit [% field.name |html %] field"

> Sponsored by Catalyst IT


### ILL

- [[22121]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22121) Display 'Price paid' on ILL requests according to CurrencyFormat pref
- [[22464]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22464) Copyright notice does not pass forward request properties

### Installation and upgrade (web-based installer)

- [[21545]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21545) Update German web Installer for 18.11

### Lists

- [[20891]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20891) Lists in staff don't load when \ was used in the description

### MARC Authority data support

- [[21957]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21957) LinkBibHeadingsToAuthorities can be called twice when running link_bibs_to_authorities

### MARC Bibliographic data support

- [[19648]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19648) Repeated positions and some options missing in cataloguing plugin 007 (XML file)

### Notices

- [[14358]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14358) Changing the module refreshes the page and resets library choice
- [[20937]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20937) PrintNoticesMaxLines is not effective for overdue notices with a print type specified where a patron has an email

### OPAC

- [[13629]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13629) SingleBranchMode removes both library and availability search from advanced search
- [[19241]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19241) Items with status of hold show as available in cart
- [[22075]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22075) Encoding problem with RIS export
- [[22501]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22501) OPAC course reserves notes should allow html links
- [[22550]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22550) OPAC suggestion form doesn't require mandatory fields
- [[22551]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22551) Stray "//" appears at bottom of opac-detail.tt
- [[22560]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22560) Forgotten password "token expired" page still shows boxes to reset password
- [[22561]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22561) Forgotten password requirements hint doesn't list all rules for new passwords
- [[22620]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22620) OPAC description for collection in opac-reserve.tt
- [[22624]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22624) Show OPAC description for authorised values in OPAC
- [[22680]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22680) OPAC language footer not positioned correctly
- [[22743]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22743) OverDrive results page is missing overdrive-login include

### Patrons

- [[22646]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22646) Fix use of PrivacyPolicyURL

### Reports

- [[22090]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22090) Cash register report missing data in CSV export

### Searching

- [[12441]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12441) search.pl has incorrect reference to OPACdefaultSortField and OPACdefaultSortOrder

> Sponsored by Catalyst IT

- [[22154]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22154) Subtype search for Format - Braille doesn't look for the right codes
- [[22595]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22595) Items search is mixing inputs
- [[22596]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22596) html TT filter is breaking items search with custom field

### Searching - Elasticsearch

- [[19670]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19670) search_marc_map.marc_field should have COLLATE= utf8mb4_bin
- [[22295]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22295) Elasticsearch - Advanced search should group terms entered in a single input
- [[22339]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22339) Elasticsearch - fixed field mappings should match MARC ranges
- [[22413]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22413) Elasticsearch - Search settings are lost after sorting, faceting or paging
- [[22474]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22474) Authority and biblio field mapping improperly shared
- [[22495]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22495) Restore su-geo field in Elasticsearch mappings

### Self checkout

- [[18387]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18387) 404 errors on page causes SCO user to be logged out
- [[22739]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22739) Self check in module JS breaks if  SelfCheckInTimeout  is unset

### System Administration

- [[18011]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18011) Enrollment period date on patron category can be set in the past without any error/warning messages
- [[22575]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22575) Item type administration uses invalid error class for dialog

### Templates

- [[22475]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22475) Shelving location doesn't appear on tags list view
- [[22586]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22586) IntranetReportsHomeHTML no longer renders as HTML on reports-home.pl
- [[22702]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22702) Circulation note on patron page should allow for HTML tags
- [[22716]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22716) Use gender-neutral pronouns in system preference descriptions

### Tools

- [[22069]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22069) Log viewer not displaying item renewals
- [[22365]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22365) Warn on Log Viewer

> Sponsored by Catalyst IT


### Web services

- [[22597]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22597) Remove "more_subfields_xml" from GetPatronInfo response (xml broken)

## New sysprefs

- NoRenewalBeforePrecision

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

- Arabic (98.8%)
- Armenian (100%)
- Basque (63.3%)
- Chinese (China) (64.2%)
- Chinese (Taiwan) (100%)
- Czech (93.7%)
- Danish (55.6%)
- English (New Zealand) (88.5%)
- English (USA)
- Finnish (84.7%)
- French (97%)
- French (Canada) (99.9%)
- German (100%)
- German (Switzerland) (92%)
- Greek (77.9%)
- Hindi (99.9%)
- Italian (94.1%)
- Norwegian Bokmål (95.2%)
- Occitan (post 1500) (59.7%)
- Polish (87%)
- Portuguese (99.9%)
- Portuguese (Brazil) (87.6%)
- Slovak (90.5%)
- Spanish (100%)
- Swedish (91.1%)
- Turkish (98.7%)
- Ukrainian (62.3%)
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

The release team for Koha 18.11.05 is

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
- Documentation Manager: Caroline Cyr-La-Rose
- Documentation Team:
  - David Nind
  - Lucy Vaux-Harvey

- Translation Managers: 
  - [Indranil Das Gupta](mailto:indradg@l2c2.co.in)
  - [Bernardo González Kriegel](mailto:bgkriegel@gmail.com)

- Wiki curators: 
  - Caroline Cyr-La-Rose
- Release Maintainers:
  - 18.11 -- [Martin Renvoize](mailto:martin.renvoize@ptfs-europe.com)
  - 18.05 -- Lucas Gass
  - 18.05 -- Jesse Maseto
  - 17.11 -- [Fridolin Somers](mailto:fridolin.somers@biblibre.com)
- Release Maintainer assistants:
  - 18.05 -- [Kyle Hall](mailto:kyle@bywatersolutions.com)

## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 18.11.05:

- Carnegie
- Catalyst IT

We thank the following individuals who contributed patches to Koha 18.11.05.

- Aleisha Amohia (1)
- Tomás Cohen Arazi (9)
- Christopher Brannon (4)
- Colin Campbell (1)
- Nick Clemens (28)
- Olivier Crouzet (1)
- Frédéric Demians (2)
- Jonathan Druart (16)
- Magnus Enger (1)
- Katrin Fischer (18)
- Lucas Gass (3)
- Kyle Hall (5)
- Andrew Isherwood (1)
- Bernardo González Kriegel (1)
- Owen Leonard (15)
- Thatcher Leonard (1)
- Ere Maijala (7)
- Hayley Mapley (4)
- Julian Maurice (3)
- Matthias Meusburger (3)
- Josef Moravec (14)
- Agustín Moyano (1)
- Björn Nylen (1)
- Eric Phetteplace (1)
- Liz Rea (2)
- Martin Renvoize (10)
- Marcel de Rooy (3)
- Maryse Simard (1)
- Kris Sinnaeve (1)
- Fridolin Somers (7)
- Arthur Suzuki (1)
- Lyon 3 Team (1)
- Mark Tompsett (1)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 18.11.05

- ACPL (15)
- BibLibre (14)
- BSZ BW (18)
- ByWater-Solutions (36)
- Catalyst (4)
- Coeur D'Alene Public Library (4)
- etf.edu (1)
- Independant Individuals (20)
- Koha Community Developers (16)
- Libriotech (1)
- PTFS-Europe (12)
- Rijks Museum (3)
- Solutions inLibro inc (1)
- Tamil (2)
- Theke Solutions (10)
- ub.lu.se (1)
- Universidad Nacional de Córdoba (1)
- University of Helsinki (7)
- Université Jean Moulin Lyon 3 (2)

We also especially thank the following individuals who tested patches
for Koha.

- Ethan Amohia (1)
- Tomás Cohen Arazi (15)
- Alex Arnaud (3)
- Marjorie Barry-Vila (1)
- David Bourgault (1)
- Mikaël Olangcay Brisebois (3)
- Nick Clemens (154)
- Chris Cormack (10)
- Frédéric Demians (1)
- Michal Denar (14)
- Devinim (1)
- Jonathan Druart (1)
- Katrin Fischer (54)
- Claire Gravely (2)
- Kyle Hall (12)
- Owen Leonard (3)
- Ere Maijala (1)
- Hayley Mapley (13)
- Jose-Mario Monteiro-Santos (2)
- Josef Moravec (22)
- Agustin Moyano (2)
- Björn Nylen (2)
- Séverine Queune (2)
- Liz Rea (39)
- Martin Renvoize (222)
- David Roberts (1)
- Benjamin Rokseth (1)
- Marcel de Rooy (16)
- Lisette Scheer (4)
- Jogiraju Tallapragada (2)
- Lari Taskula (1)
- Pierre-Marc Thibault (5)
- Bin Wen (5)
- George Williams (1)

We thank the following individuals who mentored new contributors to the Koha project.

- Owen Leonard


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

Autogenerated release notes updated last on 29 Apr 2019 11:30:00.
