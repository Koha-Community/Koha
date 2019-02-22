# RELEASE NOTES FOR KOHA 18.05.09
22 Feb 2019

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 18.05.09 can be downloaded from:

- [Download](http://download.koha-community.org/koha-18.05.09.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 18.05.09 is a bugfix/maintenance release.

It includes 1 new features, 3 enhancements, 62 bugfixes.



## New features

### REST api

- [[22132]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22132) Add Basic authentication to the REST API

> This adds http BASIC authentication as an optional auth method to the RESTful APIs. This greatly aids developers when developing against our APIs.



## Enhancements

### Architecture, internals, and plumbing

- [[21912]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21912) Koha::Objects->search lacks tests

### Circulation

- [[18816]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18816) Make CataloguingLog work in production by preventing circulation from spamming the log

### Templates

- [[20569]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20569) Improve description of CheckPrevCheckout system preference

> A simple string patch that clarifies the intention of the CheckPrevCheckout system preference options.




## Critical bugs fixed

### Acquisitions

- [[22282]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22282) Internal software error when exporting basket group as PDF

### Circulation

- [[21491]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21491) When 'Default lost item fee refund on return policy' is unset it says no but acts as if 'yes'

### Hold requests

- [[21495]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21495) Regression in hold override functionality

### OPAC

- [[22085]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22085) UNIMARC default XSLT broken by Bug 14716


## Other bugs fixed

### About

- [[21441]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21441) System information gives reference to a non-existant table

### Acquisitions

- [[20865]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20865) Remove space before : on order receive filters

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

### Developer documentation

- [[21290]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21290) POD of ModItem mentions MARC for items

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

### OPAC

- [[21192]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21192) Borrower Fields on OPAC's Personal Details Screen Use Self Register Field Options Incorrectly
- [[21808]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21808) Field 711 is not handled correctly in showAuthor XSLT for relator term or code
- [[22118]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22118) Format hold fee when placing holds in OPAC
- [[22207]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22207) Course reserves page does not have unique body id

### Patrons

- [[20165]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20165) Capitalization: Street Address should be Street address in patron search options
- [[21930]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21930) Typo in the manage_circ_rules_from_any_libraries description
- [[22149]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22149) Grammar fix in the manage_circ_rules_from_any_libraries description

### Reports

- [[20274]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20274) itemtypes.plugin report: not handling item-level_itypes syspref
- [[20679]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20679) Remove 'rows per page' from reports print layout
- [[22082]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22082) Ambiguous column in patron stats
- [[22278]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22278) Newly created report group is not selected after saving an SQL report

### Searching

- [[14716]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14716) Correctly URI-encode URLs in XSLT result lists and detail pages
- [[18909]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18909) Enable the maximum zebra records size to be specified per instance

### Serials

- [[16231]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16231) Correct permission handling in subscription edit menu

### System Administration

- [[7403]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7403) Remove warning from CataloguingLog system preference
- [[15110]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15110) Improve decreaseHighHolds system preference description
- [[21637]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21637) Capitalization: EasyAnalyticalRecords syspref option "Don't Display" should be "Don't display"
- [[21855]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21855) Remove mention of deprecated delete_unverified_opac_registrations.pl cronjob
- [[21926]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21926) Enhance OAI-PMH:archiveID system preference description

### Templates

- [[21840]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21840) Fix some typos in the templates
- [[21866]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21866) Rephrase "Warning: This *report* was written for an older version of Koha" to refer to plugins
- [[22113]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22113) Add price formatting on item lost report
- [[22236]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22236) Translation should generate tags with consistent attribute order

### Test Suite

- [[22107]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22107) Avoid deleting data in some tests
- [[22254]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22254) t/db_dependent/Koha/Patrons.t contains a DateTime math error

### Tools

- [[20634]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20634) Inventory form has 2 identical labels "Library:"
- [[22011]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22011) Typo in Item Batch Modification
- [[22036]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22036) Tidy up tags/review script
- [[22136]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22136) Import patrons notes hides a note because the syspref isn't referenced correctly



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

- Arabic (99.7%)
- Armenian (99.8%)
- Basque (72.5%)
- Chinese (China) (77%)
- Chinese (Taiwan) (98.7%)
- Czech (92.4%)
- Danish (63.6%)
- English (New Zealand) (95.5%)
- English (USA)
- Finnish (92.4%)
- French (98.7%)
- French (Canada) (94%)
- German (100%)
- German (Switzerland) (98.3%)
- Greek (80.5%)
- Hindi (99.8%)
- Italian (97.3%)
- Norwegian Bokmål (67.5%)
- Occitan (post 1500) (70.2%)
- Persian (52.9%)
- Polish (93.6%)
- Portuguese (99.8%)
- Portuguese (Brazil) (87.4%)
- Slovak (95.7%)
- Spanish (98.6%)
- Swedish (93.8%)
- Turkish (99.8%)
- Vietnamese (65.1%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 18.05.09 is

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

We thank the following individuals who contributed patches to Koha 18.05.09.

- Ethan Amohia (3)
- Jasmine Amohia (9)
- Tomás Cohen Arazi (15)
- Nick Clemens (4)
- Jonathan Druart (7)
- Katrin Fischer (7)
- Lucas Gass (10)
- Kyle Hall (4)
- helene hickey (6)
- Mackey Johnstone (1)
- Pasi Kallinen (1)
- Jack Kelliher (2)
- Owen Leonard (2)
- Olivia Lu (4)
- Jesse Maseto (1)
- Josef Moravec (2)
- Liz Rea (1)
- Martin Renvoize (2)
- Marcel de Rooy (2)
- Caroline Cyr La Rose (1)
- Fridolin Somers (5)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 18.05.09

- ACPL (2)
- BibLibre (5)
- BSZ BW (7)
- ByWater-Solutions (19)
- Catalyst (1)
- Independant Individuals (10)
- Koha Community Developers (7)
- PTFS-Europe (2)
- Rijks Museum (2)
- Solutions inLibro inc (1)
- stacmail.net (2)
- The City of Joensuu (1)
- Theke Solutions (15)
- Wellington East Girls' College (9)
- wgc.school.nz (6)

We also especially thank the following individuals who tested patches
for Koha.

- Hugo Agud (1)
- Jasmine Amohia (1)
- Tomás Cohen Arazi (16)
- Mika�l Olangcay Brisebois (1)
- Mikael Olangcay Brisebois (3)
- Nick Clemens (80)
- Frédéric Demians (1)
- Michal Denar (1)
- Devinim (2)
- Charles Farmer (1)
- Katrin Fischer (41)
- Lucas Gass (60)
- Kyle Hall (13)
- helene hickey (1)
- Pasi Kallinen (1)
- Jack Kelliher (1)
- Rhonda Kuiper (1)
- Owen Leonard (13)
- Olivia Lu (1)
- Jesse Maseto (26)
- Julian Maurice (2)
- Jose-Mario Monteiro-Santos (1)
- Josef Moravec (8)
- David Nind (16)
- Liz Rea (1)
- Martin Renvoize (92)
- Marcel de Rooy (1)
- Maryse Simard (3)
- Pierre-Marc Thibault (10)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is rmain1805.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 22 Feb 2019 12:43:27.
