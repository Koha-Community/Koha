# RELEASE NOTES FOR KOHA 16.5.3
23 août 2016

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 16.5.3 can be downloaded from:

- [Download](http://download.koha-community.org/koha-16.05.03.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 16.5.3 is a bugfix/maintenance release.

It includes 6 enhancements, 72 bugfixes.


## Enhancements

### Architecture, internals, and plumbing

- [[16436]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16436) Allow action logs to be logged to the koha log file

### Cataloging

- [[6499]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=6499) MARC21 035 -- Other-control-number --  Indexing & Matching

### Packaging

- [[17013]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17013) build-git-snapshot: add basetgz parameter and update master version number
- [[17019]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17019) debian/changelog update
- [[17030]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17030) Configure the REST api on packages install

### System Administration

- [[16310]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16310) Remove the use of "onclick" from audio alerts template


## Critical bugs fixed

### Cataloging

- [[10148]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10148) 007 not filling in with existing values
- [[14844]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14844) Corrupted storable string. When adding/editing an Item, cookie LastCreatedItem might be corrupted.

### Hold requests

- [[16988]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16988) Suspending a hold with AutoResumeSuspendedHolds disabled results in error

### Installation and upgrade (web-based installer)

- [[16573]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16573) Web installer fails to load structure and sample data on MySQL 5.7

### Koha

- [[16878]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16878) Cross-Site Scripting opac-memberentry
- [[17021]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17021) returns.pl is vulnerable to XSS attacks
- [[17022]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17022) branchtransfers.pl is vulnerable to XSS attacks
- [[17023]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17023) z3950_search.pl are vulnerable to XSS attacks
- [[17024]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17024) viewlog.pl is vulnerable to XSS attacks
- [[17025]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17025) serials-search.pl is vulnerable to XSS attacks
- [[17026]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17026) checkexpiration.pl is vulnerable to XSS attacks
- [[17028]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17028) request.pl is vulnerable to XSS attacks
- [[17029]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17029) *detail.pl are vulnerable to XSS attacks
- [[17036]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17036) circulation.pl is vulnerable to XSS attacks
- [[17038]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17038) search.pl is vulnerable to XSS attacks

### OPAC

- [[7441]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7441) Search results showing wrong branch
- [[16996]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16996) Template process failed: undef error - Can't call method "description"

### Staff Client

- [[16955]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16955) Internal Server Error while populating new framework

### Tools

- [[16917]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16917) Error when importing patrons, Column 'checkprevcheckout' cannot be null


## Other bugs fixed

### Acquisitions

- [[16953]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16953) Acquisitions home: Remove trailing &rsaquo; from breadcrumbs
- [[17081]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17081) Incorrect comparison operator used in edifactmsgs.pl

### Architecture, internals, and plumbing

- [[16741]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16741) Remove dead code "sub itemissues" from C4/Circulation.pm
- [[16848]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16848) Wrong warning "Invalid date ... passed to output_pref" can be carped
- [[16971]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16971) Missing dependency for HTML::Entities
- [[17020]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17020) findborrower is not used in circulation.tt
- [[17087]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17087) Set Test::WWW::Mechanize version to 1.42
- [[17124]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17124) DecreaseLoanHighHolds.t does not pass

### Authentication

- [[16818]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16818) CAS redirect broken under Plack

### Circulation

- [[17001]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17001) filtering overdue report by due date can fail if TimeFormat is 12hr
- [[17055]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17055) Add classes to different note types to allow for styling on checkins page

### Command-line Utilities

- [[16830]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16830) koha-indexer still uses the deprecated -x option switch
- [[16974]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16974) koha-plack should check and fix log files permissions

### I18N/L10N

- [[16585]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16585) Update Italian installer sample files for 16.05

> With this patch all sample/defintions .sql files are translated into Italian (if you select italian during web installation).


- [[16776]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16776) If language is set by external link language switcher does not work
- [[16871]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16871) Translatability: Avoid [%%-problem and fix related sentence splitting in catalogue/detail.tt
- [[17040]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17040) Context menu when editing items is not translated
- [[17064]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17064) Delete backup marc21_framework_DEFAULT.sql~ file
- [[17082]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17082) Translatability: Fix sentence splitting in member.tt

### Installation and upgrade (command-line installer)

- [[17044]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17044) Wrong destination for 'api' directory

### Koha

- [[16969]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16969) Vulnerability warning for opac/opac-memberentry.pl
- [[16975]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16975) DSA-3628-1 perl -- security update

### OPAC

- [[16615]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16615) OpenLibrary: always use SSL when referencing external resources
- [[16806]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16806) "Too soon" renewal error generates no alert for user
- [[17068]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17068) empty list item in opac-reserves.tt
- [[17078]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17078) Format fines on opac-account.pl
- [[17103]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17103) Google API Loader jsapi called over http
- [[17117]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17117) Patron personal details not displayed unless branch update request is enabled

### Packaging

- [[16885]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16885) koha-stop-zebra should be more sure of stopping zebrasrv
- [[17017]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17017) Dependency fixes for 16.05
- [[17043]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17043) debian/list-deps fixes, master edition
- [[17063]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17063) debian/control.in update: change maintainer & add libhtml-parser-perl for 16.05.x
- [[17065]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17065) Rename C4/Auth_cas_servers.yaml.orig

### Patrons

- [[15397]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15397) Pay selected does not works as expected
- [[16894]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16894) re-show email on patron search results
- [[17052]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17052) Patron category description not displayed in the sidebar of paycollect
- [[17076]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17076) Format fines in patron search results table (staff client)
- [[17100]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17100) On summary print, "Account fines and payments" is displayed even if there is nothing to pay
- [[17106]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17106) DataTables patron search defaulting to 'starts_with' - doc

### Reports

- [[17053]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17053) Clearing search term in Reports

### Searching

- [[17074]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17074) Fix links in result list of 'scan indexes' search and keep search term
- [[17107]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17107) Add ident and Identifier-standard to known indexes

### Staff Client

- [[16989]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16989) Advanced search form does not display translated itemtype

### System Administration

- [[17009]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17009) Duplicating frameworks is unnecessary slow

### Templates

- [[16793]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16793) Use Font Awesome for arrows instead of images in audio_alerts.tt
- [[16944]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16944) Add "email" and "url" classes when edit or create a vendor
- [[16964]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16964) Fix capitalization for "Report Plugins" in reports-home.tt

### Test Suite

- [[16622]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16622) some tests triggered by prove t fail for unset KOHA_CONF
- [[16864]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16864) Silence warnings in t/db_dependent/ILSDI_Services.t
- [[16868]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16868) Silence error t/db_dependent/Linker_FirstMatch.t

### Tools

- [[11490]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11490) MaxItemsForBatch should be split into two new prefs
- [[16727]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16727) Upload tool needs better warning

### Web services

- [[17042]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17042) Fix missing properties in Swagger definition for Hold

## New sysprefs

- MaxItemsToDisplayForBatchDel
- MaxItemsToProcessForBatchMod
- OPACResultsLibrary

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
- Armenian (96%)
- Chinese (China) (90%)
- Chinese (Taiwan) (99%)
- Czech (95%)
- Danish (74%)
- English (New Zealand) (99%)
- Finnish (93%)
- French (95%)
- French (Canada) (89%)
- German (100%)
- German (Switzerland) (100%)
- Greek (78%)
- Italian (99%)
- Korean (55%)
- Kurdish (53%)
- Norwegian Bokmål (60%)
- Persian (62%)
- Polish (99%)
- Portuguese (100%)
- Portuguese (Brazil) (91%)
- Slovak (96%)
- Spanish (100%)
- Swedish (79%)
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

The release team for Koha 16.5.3 is

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
new features in Koha 16.5.3:

- California College of the Arts
- Tulong Aklatan

We thank the following individuals who contributed patches to Koha 16.5.3.

- phette23 (1)
- Marc (5)
- Jacek Ablewicz (1)
- Oliver Bock (1)
- Colin Campbell (1)
- Hector Castro (2)
- Galen Charlton (1)
- Barton Chittenden (1)
- Tomás Cohen Arazi (6)
- Chris Cormack (2)
- Indranil Das Gupta (L2C2 Technologies) (1)
- Frédéric Demians (6)
- Marcel de Rooy (2)
- Jonathan Druart (30)
- Nicole Engard (1)
- Katrin Fischer (3)
- Bernardo González Kriegel (3)
- Olli-Antti Kivilahti (1)
- Owen Leonard (1)
- Kyle M Hall (6)
- Eric Phetteplace (1)
- Fridolin Somers (2)
- Zeno Tajoli (1)
- Lari Taskula (1)
- Mirko Tietgen (9)
- Mark Tompsett (6)
- Marc Véron (3)
- Jesse Weaver (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 16.5.3

- abunchofthings.net (9)
- ACPL (1)
- aei.mpg.de (1)
- BibLibre (2)
- biblos.pk.edu.pl (1)
- BSZ BW (3)
- bugs.koha-community.org (30)
- ByWater-Solutions (9)
- Catalyst (2)
- Cineca (1)
- jns.fi (1)
- l2c2.co.in (1)
- Marc Véron AG (8)
- PTFS-Europe (1)
- Rijksmuseum (2)
- student.uef.fi (1)
- Tamil (6)
- Theke Solutions (5)
- unidentified (11)
- Universidad Nacional de Córdoba (4)

We also especially thank the following individuals who tested patches
for Koha.

- Barbara Walters (1)
- Benjamin Rokseth (4)
- Brendan Gallagher (22)
- Brendon Ford (2)
- Chris Cormack (12)
- Christopher Brannon (1)
- Claire Gravely (5)
- Frédéric Demians (101)
- Galen Charlton (1)
- Hector Castro (2)
- Irma Birchall (1)
- Jason Robb (2)
- Jesse Maseto (1)
- Jonathan Druart (38)
- Josef Moravec (1)
- Katrin Fischer (36)
- Laurence Rault (2)
- Liz Rea (1)
- Marc (10)
- Marc Véron (2)
- Mark Tompsett (11)
- Matthias Meusburger (1)
- Megan Wianecki (1)
- Mirko Tietgen (1)
- Nick Clemens (8)
- Oliver Bock (1)
- Owen Leonard (12)
- Srdjan (2)
- Tomas Cohen Arazi (4)
- Kyle M Hall (71)
- Bernardo Gonzalez Kriegel (1)
- Marcel de Rooy (6)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 16.05.x.
The last Koha release was 3.22.8, which was released on June 24, 2016.  

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 23 août 2016 11:12:33.
