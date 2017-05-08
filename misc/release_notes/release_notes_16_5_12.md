# RELEASE NOTES FOR KOHA 16.5.12
08 May 2017

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 16.5.12 can be downloaded from:

- [Download](http://download.koha-community.org/koha-16.05.12.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 16.5.12 is a bugfix/maintenance release.

It includes 3 enhancements, 46 bugfixes.




## Enhancements

### Architecture, internals, and plumbing

- [[15451]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15451) Move the CSV related code to Koha::CsvProfile[s]
- [[17110]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17110) Lower CSRF expiry in Koha::Token

### OPAC

- [[17109]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17109) sendbasket: Remove second authentication, add CSRF token


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[18242]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18242) Remove primary key on old_issues.issue_id
- [[18364]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18364) LOCK and UNLOCK are not transaction-safe
- [[18373]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18373) `make upgrade` is broken

### Cataloging

- [[18305]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18305) jquery.fixFloat.js breaks advanced MARC editor for some browsers

### Circulation

- [[18022]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18022) Empty barcode causes internal server error
- [[18266]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18266) Internal Server Error when paying fine for lost item
- [[18372]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18372) transits are not created at check in despite user responsing Yes to the prompt

### Hold requests

- [[18001]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18001) LocalHoldsPriority can cause multiple holds queue lines for same hold request

### Notices

- [[18439]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18439) Resend button for notices being hidden by CSS and never unhidden

### SIP2

- [[17758]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17758) SIP checkin does not handle holds correctly

### Tools

- [[12913]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12913) Fix wrong inventory results
- [[18312]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18312) Export is broken unless a file is supplied
- [[18329]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18329) Batch record deletion broken


## Other bugs fixed

### Acquisitions

- [[14535]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14535) Late orders does not show orders with price = 0
- [[17605]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17605) EDI should set currency in order record on creation
- [[17872]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17872) Fix small error in GetBudgetHierarchy and one of its calls
- [[18429]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18429) Receiving an item should update the datelastseen

### Architecture, internals, and plumbing

- [[17814]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17814) koha-plack --stop should make sure that Plack really stop
- [[18028]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18028) install_misc directory is outdated and must be removed
- [[18069]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18069) koha-rebuild-zebra still calls rebuild_zebra with -x
- [[18443]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18443) Get rid of warning 'uninitialized value $user' in C4/Auth.pm

### Circulation

- [[12972]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12972) Transfer slip and transfer message (blue box) can conflict
- [[17309]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17309) Renewing and HomeOrHoldingBranch syspref
- [[18335]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18335) Check in: Make patron info in hold messages obey syspref AddressFormat

### Command-line Utilities

- [[18058]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18058) 'borrowers-force-messaging-defaults --doit --truncate ' gives DBI error

### Installation and upgrade (command-line installer)

- [[17911]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17911) Message and timeout mismatch at the end of the install process

### Installation and upgrade (web-based installer)

- [[12930]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12930) Web installer does not show login errors

### Label/patron card printing

- [[8603]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8603) Patron card creator - 'Barcode Type' doesn't stick in layouts
- [[18209]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18209) Patron's card manage.pl page is not fully translatable
- [[18244]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18244) Patron card creator does not take in account fields with underscore (B_address etc.)
- [[18246]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18246) Patron card creator: Units not always display properly in layouts

### Notices

- [[15854]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15854) Race condition for sending renewal/check-in notices
- [[17995]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17995) HOLDPLACED notice should have access to the reserves table

### OPAC

- [[17945]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17945) Breadcrumbs broken on opac-serial-issues.pl
- [[18307]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18307) Branchname is no longer displayed in subscription tab view

### Patrons

- [[18094]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18094) Patron search filters are broken by searchable attributes
- [[18263]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18263) Make use of syspref 'CurrencyFormat' for Account and Pay fines tables
- [[18423]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18423) Add child button not always appearing - problem in template variable

### SIP2

- [[12021]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12021) SIP2 checkin should alert on transfer and use CT for return branch

### Searching

- [[17821]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17821) due date in intranet search results should use TT date plugin

### Serials

- [[7728]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7728) Fixing subscription endddate inconsistency: should be empty when the subscription is running
- [[14932]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14932) serials/serials-collection.pl-page is very slow. GetFullSubscription* checks permission for each serial!

### System Administration

- [[17346]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17346) Enable the check in option in Columns settings

### Templates

- [[17290]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17290) Standardize on "Patron categories" when referring to patron category

### Test Suite

- [[18460]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18460) Remove itemtype-related Serials.t warnings

### Tools

- [[18087]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18087) Clarification on File type when using file of biblionumbers to export data



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
- Armenian (94%)
- Chinese (China) (89%)
- Chinese (Taiwan) (99%)
- Czech (97%)
- Danish (73%)
- English (New Zealand) (97%)
- Finnish (99%)
- French (99%)
- French (Canada) (93%)
- German (100%)
- German (Switzerland) (100%)
- Greek (85%)
- Hindi (99%)
- Italian (100%)
- Korean (54%)
- Kurdish (52%)
- Norwegian Bokmål (59%)
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

The release team for Koha 16.5.12 is

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
new features in Koha 16.5.12:


We thank the following individuals who contributed patches to Koha 16.5.12.

- Blou (1)
- pongtawat (1)
- Christopher Brannon (1)
- Alex Buckley (1)
- Colin Campbell (1)
- Nick Clemens (9)
- Tomás Cohen Arazi (1)
- Marcel de Rooy (19)
- Jonathan Druart (42)
- Bernardo González Kriegel (1)
- David Gustafsson (1)
- Luke Honiss (1)
- Mason James (14)
- Olli-Antti Kivilahti (1)
- David Kuhn (1)
- Owen Leonard (1)
- Julian Maurice (1)
- Grace McKenzie (1)
- Kyle M Hall (2)
- Joy Nelson (1)
- Paul Poulain (2)
- Benjamin Rokseth (2)
- Fridolin Somers (4)
- Mark Tompsett (1)
- Marc Véron (7)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 16.5.12

- ACPL (1)
- BibLibre (7)
- bugs.koha-community.org (42)
- ByWater-Solutions (12)
- Catalyst (1)
- cdalibrary.org (1)
- jns.fi (1)
- KohaAloha (14)
- Marc Véron AG (7)
- Oslo Public Library (2)
- PTFS-Europe (1)
- punsarn.asia (1)
- Rijksmuseum (19)
- Solutions inLibro inc (1)
- Theke Solutions (1)
- ub.gu.se (1)
- unidentified (4)
- Universidad Nacional de Córdoba (1)

We also especially thank the following individuals who tested patches
for Koha.

- Alex Buckley (2)
- beroud (1)
- Cédric Vita (2)
- Chris Cormack (6)
- Christopher Brannon (2)
- Claire Gravely (2)
- Colin Campbell (1)
- Jesse Maseto (2)
- Joel Sasse (1)
- Jonathan Druart (42)
- Josef Moravec (2)
- Joy Nelson (2)
- Julian Maurice (3)
- Katrin Fischer (38)
- Lari Taskula (1)
- Marc Véron (25)
- Mark Tompsett (2)
- Martin Renvoize (4)
- Mason James (51)
- Mirko Tietgen (2)
- Nick Clemens (15)
- Owen Leonard (3)
- Paul POULAIN (1)
- Sonia BOUIS (1)
- Srdjan (3)
- Brendan A Gallagher (12)
- Kyle M Hall (28)
- Bernardo Gonzalez Kriegel (8)
- Marcel de Rooy (49)

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

Autogenerated release notes updated last on 08 May 2017 04:02:30.
