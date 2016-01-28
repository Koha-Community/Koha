# RELEASE NOTES FOR KOHA 3.20.8
28 janv. 2016

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 3.20.8 can be downloaded from:

- [Download](http://download.koha-community.org/koha-3.20.08.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 3.20.8 is a bugfix/maintenance release.

It includes 4 enhancements, 59 bugfixes.


## Enhancements

### Documentation

- [[13136]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13136) No documentation for Home > Tools > Labels home > Manage label Layouts

### I18N/L10N

- [[15231]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15231) Import patrons: Remove string splitting by html tags to avoid weird translations

### Patrons

- [[14948]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14948) Display amounts right aligned in tables on patron pages

### translate.koha-community.org

- [[15080]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15080) ./translate-tool should tell if xgettext-executable is missing


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[15138]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15138) typo in reports/borrowers_out.pl - issues.timestamap
- [[15344]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15344) GetMemberDetails called unecessary
- [[15429]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15429) sub _parseletter should not change referenced values

### Cataloging

- [[15572]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15572) Authority creation fails when authid is linked to 001 field
- [[15579]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15579) records_batchmod permission doesn't allow access to batch modification

### Circulation

- [[15431]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15431) svc/checkouts dies due to undefined variable (13024 merge problem)

> This bug appears only in 3.20.7 version and is very visible and disturbing. It has been discussed on Koha mailing list: after a package upgrade, the check-out screen doesn't display anymore the checkout items table.


- [[15442]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15442) Checkouts table will not display due to javascript error
- [[15462]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15462) Unable to renew books via circ/renew.pl
- [[15560]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15560) Multiple holding branchs and locations not displaying in pending holds report
- [[15570]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15570) circ/renew.pl is broken

### Patrons

- [[15367]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15367) Batch patron modification: Data loss with multiple repeatable patron attributes

### Tools

- [[15332]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15332) ModMember not interpreting dates (Batch patron modification)
- [[15607]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15607) Batch patron modification: Data loss of 'dateenrolled' and 'expirydate' fields


## Other bugs fixed

### Acquisitions

- [[14853]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14853) Change "Fund" to "Shipping fund" where appropriate

### Architecture, internals, and plumbing

- [[15432]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15432) t/db_dependent/Letters.t depends on external data/configuration

### Authentication

- [[14034]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14034) User logged out on refresh after Shibboleth authentication

### Circulation

- [[15569]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15569) Automatic renewal should not be displayed if the patron cannot checkout

### Developer documentation

- [[14397]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14397) Typo 'foriegn' in table comments
- [[14538]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14538) POD for CalcFine is incomplete

### Documentation

- [[15220]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15220) typo in circ rules help

### I18N/L10N

- [[15233]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15233) Cataloging subfield editors: Clean up html and streamline text for better translatability
- [[15236]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15236) Better translatibility in "Connect biblio.biblionumber to a MARC subfield"
- [[15237]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15237) Quote of the day: Better translatibility for editor and help
- [[15238]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15238) Better translatability for Installer Step 1
- [[15300]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15300) Translatability: Replace ambiguous 'From' and 'To' in members-update.tt
- [[15304]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15304) Norwegian patron database: translatable strings added to all po files
- [[15340]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15340) Translatability: fix issue with 'or choose' splitted by <strong tag
- [[15345]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15345) Translatability: fix issue in facets (Availability')
- [[15346]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15346) Translatability: fix sentence splitting issue in memberentrygen.tt
- [[15362]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15362) Translatability: Fix issue on Administration 'Did you mean?'
- [[15363]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15363) Translatability: Fix issue with ambiguous 'all' on Administration > Set library checkin and transfer policy
- [[15365]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15365) Translatability: Fix issue on Administration > Circulation and fine rules
- [[15383]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15383) Opac: Authority details: Fix translation issues with tags

### Installation and upgrade (command-line installer)

- [[15405]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15405) XML paths to zebra libraries is wrong for 64-bit installs on non-Debian linux

### MARC Bibliographic data support

- [[15170]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15170) Add 264 field to MARC21*DC.xsl

### OPAC

- [[15210]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15210) Novelist js throws an error if no ISBN
- [[15373]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15373) Zip should be ZIP
- [[15382]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15382) 245$a visibility constraints not respected in opac-MARCdetail.pl
- [[15412]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15412) Dropdowns in suspend holds date selector do not function in Firefox
- [[15511]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15511) Tabbed fines display on OPAC patron summary page broken

### Patrons

- [[14193]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14193) Accessibility: Searching patrons using the alphabetic index doesn't work
- [[15252]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15252) Patron search on start with does not work with several terms

### Reports

- [[15366]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15366) Fix breadcrumbs and html page title in guided reports

### Searching

- [[13022]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13022) Hardcoded limit causes records with more than 20 items to show inaccurate statuses

> If a record has more than 20 items, all the items over 20 will show as available on results even if they are not! This is a hard coded limit in the Search module. This is made configurable with the new system preference MaxSearchResultsItemsPerRecordStatu


- [[15217]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15217) variables declared twice in in catalogue/search.pl
- [[15606]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15606) Spelling mistake in MARC21slim2OPACDetail.xsl

### Serials

- [[15171]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15171) Searching serials expiring after today should be allowed

### Staff Client

- [[14613]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14613) Send cart window is too small in staff and hides 'send' button

### System Administration

- [[14153]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14153) Noisy warns in admin/transport-cost-matrix.pl
- [[15101]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15101) Don't display system preference AllowPkiAuth under heading CAS Authentication
- [[15409]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15409) Plugins section missing from Admin menu sidebar
- [[15603]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15603) Accessibility: Can't tab to select link in budgets add user popup

### Templates

- [[15228]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15228) Patron card batches - Improve translatability
- [[15229]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15229) Tiny typo: This patrons is ...
- [[15327]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15327) Minor tweaks to Bootstrap modal handling on Staged MARC management page
- [[15396]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15396) MARC21 Leader plugin label '1-4 Record size' is wrong

### Tools

- [[14636]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14636) Sorting and searching by publication year in item search doesn't work correctly
- [[15602]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15602) Accessibility: Can't tab to add link in patron card creator add patrons popup

### Web services

- [[14363]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14363) OAI-PMH should handle records without marcxml

> Sometimes, some biblioitems records have empty marcxml. In this case, OAI harvester fails with a software error: Can't call method &quot;as_xml&quot; on an undefined value at /home/koha/src/opac/oai.pl line 516. Instead, now, record is skipped, and a mess



## New sysprefs

- MaxSearchResultsItemsPerRecordStatusCheck

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
- Arabic (98%)
- Armenian (100%)
- Czech (96%)
- Danish (82%)
- Finnish (86%)
- French (93%)
- German (100%)
- Italian (99%)
- Korean (62%)
- Kurdish (59%)
- Persian (69%)
- Polish (99%)
- Portuguese (99%)
- Slovak (100%)
- Spanish (100%)
- Swedish (88%)
- Turkish (99%)
- Vietnamese (84%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

for information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 3.20.8 is

- Release Manager: [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
- QA Manager: [Katrin Fischer](mailto:Katrin.Fischer@bsz-bw.de)
- QA Team:
  - [Marcel de Rooy](mailto:m.de.rooy@rijksmuseum.nl)
  - [Jesse Weaver](mailto:jweaver@bywatersolutions.com)
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
  - [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
  - [Paul Poulain](mailto:paul.poulain@biblibre.com)
  - [Jonathan Druart](mailto:jonathan.druart@biblibre.com)
  - [Martin Renvoize](mailto:martin.renvoize@ptfs-europe.com)
- Bug Wranglers:
  - [Amit Gupta](mailto:amitddng135@gmail.com)
  - [Magnus Enger](mailto:magnus@enger.priv.no)
  - [Mirko Tietgen](mailto:mirko@abunchofthings.net)
  - [Indranil Das Gupta](mailto:indradg@l2c2.co.in)
  - [Zeno Tajoli](mailto:z.tajoli@cineca.it)
  - [Marc Véron](mailto:veron@veron.ch)
- Packaging Manager: [Galen Charlton](mailto:gmc@esilibrary.com)
- Documentation Manager: [Nicole C. Engard](mailto:nengard@gmail.com)
- Translation Manager: [Bernardo Gonzalez Kriegel](mailto:bgkriegel@gmail.com)
- Wiki curators: 
  - [Thomas Dukleth](mailto:kohadevel@agogme.com)
- Release Maintainers:
  - 3.22 -- [Julian Maurice](mailto:julian.maurice@biblibre.com)
  - 3.20 -- [Frédéric Demians](mailto:f.demians@tamil.fr)
  - 3.18 -- [Liz Rea](mailto:liz@catalyst.net.nz)
  - 3.16 -- [Mason James](mailto:mtj@kohaaloha.com)
  - 3.14 -- [Fridolin Somers](mailto:fridolin.somers@biblibre.com)

## Credits

We thank the following libraries who are known to have sponsored
new features in Koha 3.20.8:


We thank the following individuals who contributed patches to Koha 3.20.8.

- Chloe (1)
- Gus (1)
- Nick (1)
- Aleisha (3)
- Natasha (3)
- Colin Campbell (1)
- Hector Castro (2)
- Nicole C. Engard (2)
- Tomás Cohen Arazi (1)
- Frédéric Demians (10)
- Jonathan Druart (16)
- Magnus Enger (1)
- Katrin Fischer (8)
- Brendan Gallagher (1)
- Olli-Antti Kivilahti (1)
- Owen Leonard (2)
- Julian Maurice (2)
- Kyle M Hall (6)
- Martin Renvoize (1)
- Fridolin Somers (3)
- Mirko Tietgen (1)
- Mark Tompsett (1)
- Nicholas van Oudtshoorn (1)
- Marc Véron (21)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 3.20.8

- abunchofthings.net (1)
- ACPL (2)
- BibLibre (5)
- BSZ BW (8)
- bugs.koha-community.org (16)
- ByWater-Solutions (10)
- jns.fi (1)
- Libriotech (1)
- Marc Véron AG (21)
- PTFS-Europe (2)
- stacmail.net (1)
- Tamil (10)
- Theke Solutions (1)
- unidentified (11)

We also especially thank the following individuals who tested patches
for Koha.

- Aleisha (4)
- Alex (1)
- Barry Cannon (1)
- Briana (1)
- Chris Cormack (3)
- Frederic Demians (1)
- Frédéric Demians (85)
- Fridolin Somers (4)
- Hector Castro (20)
- Jesse Weaver (11)
- Jonathan Druart (51)
- Julian Maurice (77)
- Karam Qubsi (1)
- Katrin Fischer (15)
- Marc Véron (11)
- Mark Tompsett (4)
- Mirko Tietgen (1)
- Natasha (1)
- Nick Clemens (2)
- Nicole Engard (1)
- Owen Leonard (5)
- Thomas Misilo (1)
- Bob Ewart bob-ewart@bobsown.com (1)
- Brendan Gallagher brendan@bywatersolutions.com (13)
- Brendan A Gallagher (33)
- Kyle M Hall (29)
- Bernardo Gonzalez Kriegel (3)
- Andreas Hedström Mace (1)
- Marcel de Rooy (5)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 3.20.8.
The last Koha release was 3.16.9, which was released on March 29, 2015.  

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 28 janv. 2016 09:31:48.
