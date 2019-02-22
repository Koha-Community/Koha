# RELEASE NOTES FOR KOHA 18.11.03
22 Feb 2019

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 18.11.03 can be downloaded from:

- [Download](http://download.koha-community.org/koha-18.11.03.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 18.11.03 is a bugfix/maintenance release.

It includes 2 new features, 8 enhancements, 80 bugfixes.



## New features

### REST api

- [[17006]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17006) Add route to change patron's password

> Sponsored by Municipal Libray Ceska Trebova

- [[22132]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22132) Add Basic authentication to the REST API

> This adds http BASIC authentication as an optional auth method to the RESTful APIs. This greatly aids developers when developing against our APIs.



## Enhancements

### Architecture, internals, and plumbing

- [[21993]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21993) Be userfriendly when the CSRF token is wrong
- [[22047]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22047) set_password should have a 'skip_validation' param
- [[22051]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22051) Make Koha::Object->store translate 'Incorrect <type> value' exceptions

### Circulation

- [[18816]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18816) Make CataloguingLog work in production by preventing circulation from spamming the log

### Command-line Utilities

- [[18562]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18562) Add koha-sip script to handle SIP servers for instances

> To ease multi-tenant sites maintenance, several handy scripts were introduced. For handling SIP servers, 3 scripts were introduced: koha-start-sip, koha-stop-sip and koha-enable-sip.  
This patch introduces a new script, koha-sip, that unifies those actions regarding SIP servers on a per instance base, through the use of option switches.  
18.11 Note: The introduction of this script does NOT remove the koha-%-sip versions at this time and the scripts can be used interchangeably until one upgrades to 19.05 where the koha-%-sip versions are officially removed.



### Installation and upgrade (web-based installer)

- [[20000]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20000) use Modern::Perl in installer perl scripts

> Sponsored by Catalyst IT

> Code cleanup which improves the readability, and therefore reliability, of Koha.



### OPAC

- [[22029]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22029) Remove Google+ from social links on OPAC detail

> Google revealed that Google Plus accounts will be shut down on April 2, 2019.



### Templates

- [[20569]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20569) Improve description of CheckPrevCheckout system preference

> A simple string patch that clarifies the intention of the CheckPrevCheckout system preference options.




## Critical bugs fixed

### Acquisitions

- [[18723]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18723) Dot not recognized as decimal separator on receive
- [[21989]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21989) JS error in "Add orders from MARC file" - addorderiso2709.pl
- [[22282]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22282) Internal software error when exporting basket group as PDF

### Architecture, internals, and plumbing

- [[21610]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21610) Koha::Object->store needs to handle incorrect values

### Circulation

- [[21491]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21491) When 'Default lost item fee refund on return policy' is unset it says no but acts as if 'yes'

### Hold requests

- [[21495]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21495) Regression in hold override functionality

### OPAC

- [[22085]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22085) UNIMARC default XSLT broken by Bug 14716


## Other bugs fixed

### About

- [[7143]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7143) Bug for tracking changes to the about page
- [[21441]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21441) System information gives reference to a non-existant table

### Acquisitions

- [[20865]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20865) Remove space before : on order receive filters
- [[21089]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21089) Overlapping elements in ordering information on acqui/supplier.pl
- [[22110]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22110) Editing adjustments doesn't work for Currencyformat != US

### Architecture, internals, and plumbing

- [[19816]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19816) output_pref must implement 'dateonly' for dateformat => rfc3339
- [[19920]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19920) changepassword is exported from C4::Members but has been removed
- [[21170]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21170) Warnings in MARCdetail.pl - isn't numeric in numeric eq (==)
- [[21478]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21478) Koha::Hold->suspend_hold allows suspending in transit holds
- [[21907]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21907) Error from mainpage when Article requests enabled and either IndependentBranches or IndependentBranchesPatronModifications is enabled
- [[22006]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22006) Koha::Account::Line->item should return undef if no item linked
- [[22097]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22097) CataloguingLog should be suppressed for item branch transfers
- [[22124]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22124) Update cataloguing plugin system to not generate type parameter in script tag
- [[22125]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22125) branches.pickup_location should be flagged as boolean

### Cataloging

- [[20491]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20491) Use "Date due" in table header of item table
- [[22122]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22122) Make sequence of Z39.50 search options match in acq and cataloguing
- [[22242]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22242) Javascript error in value builder cased by Select2

### Circulation

- [[17347]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17347) 'Renew' tab should ignore whitespace at begining and end of barcode
- [[21877]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21877) Show authorized value description for withdrawn in checkout
- [[22054]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22054) Display a nicer error message when trying to renew an on-site checkout from renew page
- [[22083]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22083) Typo in circulation_batch_checkouts.tt
- [[22111]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22111) Correctly format fines when placing holds (maxoutstanding warning)
- [[22119]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22119) Add price formatting in circulation
- [[22120]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22120) Add price formatting to patron summary print
- [[22203]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22203) Holds modal no longer links to patron

### Command-line Utilities

- [[22235]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22235) Make maintenance scripts use koha-sip instead of koha-%-sip

### Developer documentation

- [[21290]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21290) POD of ModItem mentions MARC for items

### Fines and fees

- [[22066]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22066) branchcode should be recorded for manual credits
- [[22138]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22138) members/paycollect.pl has not been updated to have the new tab names

### Hold requests

- [[7614]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7614) Use branch transfer limits for determining available opac holds pickup locations

### Holidays

- [[21885]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21885) Improve date selection on calendar for selecting the end date on a range

### ILL

- [[22101]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22101) ILL requests missing in menu on advanced search page

### Installation and upgrade (web-based installer)

- [[11922]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11922) Add SHOW_BCODE patron attribute for Norwegian web installer
- [[22095]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22095) Dead link in web installer

### MARC Authority data support

- [[19994]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19994) use Modern::Perl in Authorities perl scripts

### Notices

- [[21829]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21829) Date displays as a datetime in notices
- [[22002]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22002) Each message_transport_type in the letters table is showing as a separate notice in Tools > Notices and slips

### OPAC

- [[21192]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21192) Borrower Fields on OPAC's Personal Details Screen Use Self Register Field Options Incorrectly
- [[21808]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21808) Field 711 is not handled correctly in showAuthor XSLT for relator term or code
- [[22058]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22058) OPAC holdings table shows &nbsp; instead of blank
- [[22118]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22118) Format hold fee when placing holds in OPAC
- [[22207]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22207) Course reserves page does not have unique body id

### Patrons

- [[19818]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19818) Add id into tag html from moremember.tt
- [[20165]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20165) Capitalization: Street Address should be Street address in patron search options
- [[21930]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21930) Typo in the manage_circ_rules_from_any_libraries description
- [[22149]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22149) Grammar fix in the manage_circ_rules_from_any_libraries description

### Reports

- [[20274]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20274) itemtypes.plugin report: not handling item-level_itypes syspref
- [[20679]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20679) Remove 'rows per page' from reports print layout
- [[22082]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22082) Ambiguous column in patron stats
- [[22168]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22168) Improve styling of new chart settings for reports
- [[22278]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22278) Newly created report group is not selected after saving an SQL report

### Searching

- [[14716]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14716) Correctly URI-encode URLs in XSLT result lists and detail pages
- [[18909]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18909) Enable the maximum zebra records size to be specified per instance

### Searching - Elasticsearch

- [[21084]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21084) Searching for authorities with 'contains' gives no results if search terms include punctuation

### Serials

- [[16231]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16231) Correct permission handling in subscription edit menu

### System Administration

- [[7403]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7403) Remove warning from CataloguingLog system preference
- [[15110]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15110) Improve decreaseHighHolds system preference description
- [[21637]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21637) Capitalization: EasyAnalyticalRecords syspref option "Don't Display" should be "Don't display"
- [[21855]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21855) Remove mention of deprecated delete_unverified_opac_registrations.pl cronjob
- [[21926]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21926) Enhance OAI-PMH:archiveID system preference description
- [[22009]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22009) Fix error messages for classification sources and filing rules

### Templates

- [[10562]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10562) Improve Leader06 Type Labels in MARC21slim2OPACResults.xsl
- [[21840]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21840) Fix some typos in the templates
- [[21866]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21866) Rephrase "Warning: This *report* was written for an older version of Koha" to refer to plugins
- [[22113]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22113) Add price formatting on item lost report
- [[22116]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22116) Add price formatting to rental charge and replacement price on items tab in staff
- [[22236]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22236) Translation should generate tags with consistent attribute order

### Test Suite

- [[22254]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22254) t/db_dependent/Koha/Patrons.t contains a DateTime math error

### Tools

- [[19915]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19915) Inventory tool doesn't use cn_sort for callnumber ranges

> This patch brings the inventory tool inline with other pages displaying data sorted by callnumbers by also adopting the use of cn_sort for sorting.


- [[20634]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20634) Inventory form has 2 identical labels "Library:"
- [[22011]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22011) Typo in Item Batch Modification
- [[22036]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22036) Tidy up tags/review script
- [[22136]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22136) Import patrons notes hides a note because the syspref isn't referenced correctly

## New sysprefs

- RESTBasicAuth

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

- Arabic (99.4%)
- Armenian (99.4%)
- Basque (63.7%)
- Chinese (China) (64.4%)
- Chinese (Taiwan) (99.4%)
- Czech (92.3%)
- Danish (55.9%)
- English (New Zealand) (89%)
- English (USA)
- Finnish (84.4%)
- French (95.7%)
- French (Canada) (98.4%)
- German (100%)
- German (Switzerland) (92.5%)
- Greek (76.7%)
- Hindi (99.4%)
- Italian (94.6%)
- Norwegian Bokmål (95.6%)
- Occitan (post 1500) (59.9%)
- Polish (85.9%)
- Portuguese (99.4%)
- Portuguese (Brazil) (85.9%)
- Slovak (91%)
- Spanish (93.4%)
- Swedish (91.2%)
- Turkish (99.2%)
- Ukrainian (61.2%)
- Vietnamese (53.7%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 18.11.03 is

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
new features in Koha 18.11.03:

- Catalyst IT
- Municipal Libray Ceska Trebova

We thank the following individuals who contributed patches to Koha 18.11.03.

- Ethan Amohia (3)
- Jasmine Amohia (10)
- Aleisha Amohia (1)
- Tomás Cohen Arazi (26)
- Nick Clemens (12)
- Jonathan Druart (13)
- Katrin Fischer (12)
- Lucas Gass (1)
- Kyle Hall (9)
- Helene Hickey (8)
- Mackey Johnstone (1)
- Pasi Kallinen (1)
- Jack Kelliher (2)
- Olli-Antti Kivilahti (1)
- Owen Leonard (6)
- Olivia Lu (4)
- Ere Maijala (1)
- Jose-Mario Monteiro-Santos (1)
- Josef Moravec (2)
- Liz Rea (1)
- Martin Renvoize (6)
- Marcel de Rooy (5)
- Caroline Cyr La Rose (1)
- Fridolin Somers (5)
- Lari Taskula (4)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 18.11.03

- ACPL (6)
- BibLibre (5)
- BSZ BW (12)
- ByWater-Solutions (22)
- Catalyst (1)
- Independant Individuals (11)
- jns.fi (5)
- Koha Community Developers (13)
- PTFS-Europe (6)
- Rijks Museum (5)
- Solutions inLibro inc (2)
- stacmail.net (2)
- The City of Joensuu (1)
- Theke Solutions (26)
- University of Helsinki (1)
- Wellington East Girls' College (10)
- wgc.school.nz (8)

We also especially thank the following individuals who tested patches
for Koha.

- Hugo Agud (1)
- Jasmine Amohia (1)
- Tomás Cohen Arazi (25)
- Bob Bennhoff (7)
- Anne-Claire Bernaudin (2)
- Mikaël Olangcay Brisebois (5)
- Barton Chittenden (1)
- Nick Clemens (136)
- David Cook (1)
- Frédéric Demians (1)
- Michal Denar (1)
- Devinim (2)
- Jonathan Druart (1)
- Charles Farmer (5)
- Katrin Fischer (58)
- Victor Grousset (1)
- Kyle Hall (37)
- Helene Hickey (1)
- Mackey Johnstone (1)
- Pasi Kallinen (1)
- Jack Kelliher (2)
- Rhonda Kuiper (1)
- Owen Leonard (20)
- Olivia Lu (1)
- Julian Maurice (2)
- Jose-Mario Monteiro-Santos (1)
- Josef Moravec (18)
- David Nind (18)
- Liz Rea (1)
- Martin Renvoize (154)
- Marcel de Rooy (7)
- Maryse Simard (5)
- Pierre-Marc Thibault (11)



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

Autogenerated release notes updated last on 22 Feb 2019 12:45:11.
