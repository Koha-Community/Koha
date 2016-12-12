# RELEASE NOTES FOR KOHA 16.5.6
12 Dec 2016

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 16.5.6 can be downloaded from:

- [Download](http://download.koha-community.org/koha-16.05.06.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 16.5.6 is a bugfix/maintenance release.

It includes 4 enhancements, 58 bugfixes.




## Enhancements

### Acquisitions

- [[7039]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7039) Link to existing record from result list in acquisition search

> When creating orders from existing records in acquisiton, the result list now links to the existing records, so that it's possible to check for existing items.



### Command-line Utilities

- [[17459]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17459) Add a script to create a superlibrarian user

### I18N/L10N

- [[16687]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16687) Translatability: Fix issues with sentence splitting in Administration preferences
- [[16952]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16952) Add sorting rules for Czech language to Zebra


## Critical bugs fixed

### Acquisitions

- [[16493]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16493) acq matching on title and author

### Architecture, internals, and plumbing

- [[17494]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17494) Koha generating duplicate self registration tokens
- [[17644]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17644) t/db_dependent/Exporter/Record.t fails

### Authentication

- [[17481]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17481) Cas Logout: bug 11048 has been incorrectly merged

### Circulation

- [[14598]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14598) itemtype is not set on statistics by C4::Circulation::AddReturn
- [[17524]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17524) Datepicker on checkout fails when dateformat = iso

### Command-line Utilities

- [[17376]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17376) rebuild_zebra.pl in daemon mode no database access kills the process

### OPAC

- [[17484]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17484) Searching with date range limit (lower and upper) does not work

### Reports

- [[17495]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17495) reports/issues_stats.pl is broken

### Searching

- [[17278]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17278) Limit to available items returns 0 results
- [[17377]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17377) ES - control fields are not taken into account

### System Administration

- [[17582]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17582) Cannot edit an authority framework

### Tools

- [[17420]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17420) record export fails when itemtype on biblio


## Other bugs fixed

### Architecture, internals, and plumbing

- [[15690]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15690) Unconstrained CardnumberLength preference conflicts with table column limit of 16
- [[17513]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17513) koha-create does not set GRANTS correctly
- [[17544]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17544) populate_db.pl should not require t::lib::Mocks
- [[17564]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17564) Acquisition/OrderUsers.t is broken
- [[17589]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17589) Improper method type in Koha::ItemType(s)
- [[17637]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17637) Auth_with_ldap.t is failing
- [[17638]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17638) t/db_dependent/Search.t is failing
- [[17641]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17641) t/Biblio/Isbd.t is failing

### Cataloging

- [[17204]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17204) Rancor Z39.50 search fails under plack
- [[17545]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17545) Make "Add biblio" not hidden by language chooser
- [[17660]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17660) Any $t subfields not editable in any framework

### Circulation

- [[14736]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14736) AllowRenewalIfOtherItemsAvailable slows circulation down in case of a record with many items and many holds
- [[17394]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17394) exporting checkouts with items selects without items in combo-box

### Command-line Utilities

- [[16935]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16935) launch export_records.pl with deleted_barcodes param fails

### Developer documentation

- [[17626]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17626) INSTALL files are outdated

### I18N/L10N

- [[17518]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17518) Displayed language name for Czech is wrong

### Installation and upgrade (web-based installer)

- [[17504]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17504) Installer shows PostgreSQL info when wrong DB permissions

### OPAC

- [[17435]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17435) Gives ability to display stocknumber in the search results

### Packaging

- [[4880]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=4880) koha-remove sometimes fails because user is logged in
- [[17084]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17084) Automatic debian/control updates (master)

### Patrons

- [[17419]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17419) Fix more confusion between smsalertnumber and mobile
- [[17434]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17434) Moremember displaying primary and secondary phone number twice
- [[17559]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17559) Invalid ID of element B_streetnumber in member edit form

### Reports

- [[17590]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17590) Exporting reports as CSV with 'delimiter' SysPref set to 'tabulation' creates files with 't' as separator

### Searching

- [[17132]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17132) Availability search broken when using Elastic

### Staff Client

- [[17375]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17375) Prevent internal software error when searching patron with invalid birth date

### System Administration

- [[17657]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17657) Item type's images could not be displayed correctly on the item types admin page

### Templates

- [[12359]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12359) hidepatronname doesn't hide on the holds queue
- [[16792]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16792) Add Font Awesome Icon and mini button to Keyword to MARC mapping section
- [[16991]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16991) Add subtitle to holds to pull report
- [[17417]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17417) Correct invalid markup around news on the staff client home page
- [[17645]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17645) Remove obsolete interface customization images

### Test Suite

- [[17476]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17476) Failed test 'Create DateTime with dt_from_string() for 2100-01-01 with TZ in less than 2s'
- [[17572]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17572) Remove issue.t warnings
- [[17573]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17573) Remove DecreaseLoanHighHolds.t warnings
- [[17574]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17574) Remove LocalholdsPriority.t warnings
- [[17575]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17575) Remove Circulation.t warnings
- [[17587]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17587) Remove itemtype-related IsItemIssued.t warnings
- [[17592]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17592) Remove itemtype-related maxsuspensiondays.t warnings
- [[17603]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17603) Remove itemtype-related Borrower_Discharge.t warnings
- [[17636]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17636) Remove itemtype-related GetIssues.t warnings
- [[17646]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17646) Remove itemtype-related IssueSlip.t warnings
- [[17647]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17647) Remove itemtype-related CancelReceipt.t warnings
- [[17653]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17653) Remove itemtype-related t/db_dependent/Circulation* warnings

### Tools

- [[17663]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17663) Forgotten userpermissions from bug 14686



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
- Chinese (China) (89%)
- Chinese (Taiwan) (99%)
- Czech (97%)
- Danish (74%)
- English (New Zealand) (98%)
- Finnish (99%)
- French (99%)
- French (Canada) (93%)
- German (99%)
- German (Switzerland) (99%)
- Greek (78%)
- Hindi (100%)
- Italian (100%)
- Korean (54%)
- Kurdish (52%)
- Norwegian Bokmål (60%)
- Occitan (81%)
- Persian (61%)
- Polish (100%)
- Portuguese (100%)
- Portuguese (Brazil) (90%)
- Slovak (95%)
- Spanish (100%)
- Swedish (92%)
- Turkish (100%)
- Vietnamese (75%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

for information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 16.5.6 is

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
  - 16.05 -- [Mason James](mailto:mtj@kohaaloha.com)
  - 3.22 -- [Julian Maurice](mailto:julian.maurice@biblibre.com)
  - 3.20 -- [Chris Cormack](mailto:chrisc@catalyst.net.nz)

## Credits

We thank the following libraries who are known to have sponsored
new features in Koha 16.5.6:

- ByWater Solutions
- Universidad Empresarial Siglo 21

We thank the following individuals who contributed patches to Koha 16.5.6.

- kohamaster (1)
- Brendan A Gallagher (1)
- Nightly Build Bot (1)
- Hector Castro (1)
- Nick Clemens (3)
- Tomás Cohen Arazi (24)
- Chris Cormack (1)
- Frédéric Demians (2)
- Marcel de Rooy (3)
- Jonathan Druart (23)
- Katrin Fischer (1)
- Mason James (1)
- Owen Leonard (4)
- Matthias Meusburger (1)
- Kyle M Hall (14)
- Josef Moravec (3)
- Andreas Roussos (1)
- Radek Šiman (1)
- Fridolin Somers (5)
- Lari Taskula (1)
- Koha Team Lyon 3 (1)
- Mark Tompsett (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 16.5.6

- abunchofthings.net (1)
- ACPL (4)
- BibLibre (6)
- BSZ BW (1)
- bugs.koha-community.org (23)
- ByWater-Solutions (18)
- Catalyst (1)
- jns.fi (1)
- KohaAloha (1)
- kohaVM (1)
- rbit.cz (1)
- Rijksmuseum (3)
- Tamil (2)
- Theke Solutions (22)
- unidentified (6)
- Universidad Nacional de Córdoba (2)
- Université Jean Moulin Lyon 3 (1)

We also especially thank the following individuals who tested patches
for Koha.

- Barbara Fondren (2)
- Chris Cormack (1)
- Chris Kirby (1)
- Frédéric Demians (15)
- Hector Castro (6)
- Jacek Ablewicz (1)
- Jennifer Schmidt (1)
- Jesse Maseto (2)
- Jonathan Druart (22)
- Josef Moravec (21)
- Katrin Fischer (2)
- Lucio Moraes (3)
- Magnus Enger (1)
- Marc (4)
- Marc Véron (5)
- Mark Tompsett (3)
- Martin Renvoize (10)
- Mason James (75)
- Mirko Tietgen (3)
- Nick Clemens (8)
- Nicolas Legrand (1)
- Owen Leonard (1)
- radiuscz (2)
- Katrin Fischer  (12)
- Tomas Cohen Arazi (31)
- Nicole C Engard (2)
- Kyle M Hall (27)
- Bernardo Gonzalez Kriegel (4)
- Marcel de Rooy (28)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 16.05.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 12 Dec 2016 03:08:21.
