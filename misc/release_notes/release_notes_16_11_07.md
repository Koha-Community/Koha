# RELEASE NOTES FOR KOHA 16.11.07
22 Apr 2017

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 16.11.07 can be downloaded from:

- [Download](http://download.koha-community.org/koha-16.11.07.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 16.11.07 is a bugfix/maintenance release.

It includes 38 bugfixes.






## Critical bugs fixed

### Architecture, internals, and plumbing

- [[18242]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18242) Remove primary key on old_issues.issue_id
- [[18364]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18364) LOCK and UNLOCK are not transaction-safe
- [[18373]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18373) `make upgrade` is broken

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
- [[17872]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17872) Fix small error in GetBudgetHierarchy and one of its calls
- [[18429]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18429) Receiving an item should update the datelastseen

### Architecture, internals, and plumbing

- [[17814]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17814) koha-plack --stop should make sure that Plack really stop
- [[18443]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18443) Get rid of warning 'uninitialized value $user' in C4/Auth.pm

### Circulation

- [[12972]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12972) Transfer slip and transfer message (blue box) can conflict
- [[17309]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17309) Renewing and HomeOrHoldingBranch syspref
- [[18321]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18321) One more checkouts possible than allowed by rules
- [[18335]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18335) Check in: Make patron info in hold messages obey syspref AddressFormat

### Command-line Utilities

- [[18058]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18058) 'borrowers-force-messaging-defaults --doit --truncate ' gives DBI error

### Installation and upgrade (command-line installer)

- [[17911]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17911) Message and timeout mismatch at the end of the install process

### Installation and upgrade (web-based installer)

- [[12930]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12930) Web installer does not show login errors

### Label/patron card printing

- [[18209]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18209) Patron's card manage.pl page is not fully translatable
- [[18244]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18244) Patron card creator does not take in account fields with underscore (B_address etc.)

### Notices

- [[17995]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17995) HOLDPLACED notice should have access to the reserves table

### OPAC

- [[17945]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17945) Breadcrumbs broken on opac-serial-issues.pl
- [[18307]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18307) Branchname is no longer displayed in subscription tab view

### Patrons

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
- Arabic (100%)
- Armenian (97%)
- Chinese (China) (86%)
- Chinese (Taiwan) (100%)
- Czech (96%)
- Danish (71%)
- English (New Zealand) (94%)
- Finnish (99%)
- French (99%)
- French (Canada) (94%)
- German (100%)
- German (Switzerland) (100%)
- Greek (78%)
- Hindi (99%)
- Italian (100%)
- Korean (52%)
- Norwegian Bokmål (57%)
- Occitan (79%)
- Persian (59%)
- Polish (100%)
- Portuguese (99%)
- Portuguese (Brazil) (87%)
- Slovak (92%)
- Spanish (100%)
- Swedish (99%)
- Turkish (100%)
- Vietnamese (72%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

for information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 16.11.07 is

- Release Managers:
  - [Brendan Gallagher](mailto:brendan@bywatersolutions.com)
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
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
  - [Brooke Johnson](mailto:abesottedphoenix@yahoo.com)
  - [Thomas Dukleth](mailto:kohadevel@agogme.com)
- Release Maintainers:
  - 16.11 -- [Katrin Fischer](mailto:katrin.fischer.83@web.de)
  - 16.05 -- [Mason James](mailto:mtj@kohaaloha.com)
  - 3.22 -- [Julian Maurice](mailto:julian.maurice@biblibre.com)

## Credits

We thank the following libraries who are known to have sponsored
new features in Koha 16.11.07:


We thank the following individuals who contributed patches to Koha 16.11.07.

- Blou (1)
- pongtawat (1)
- root (1)
- Christopher Brannon (1)
- Alex Buckley (1)
- Nick Clemens (9)
- Tomás Cohen Arazi (1)
- Marcel de Rooy (10)
- Jonathan Druart (19)
- Katrin Fischer (1)
- Luke Honiss (1)
- Olli-Antti Kivilahti (1)
- David Kuhn (1)
- Owen Leonard (1)
- Julian Maurice (1)
- Grace McKenzie (1)
- Kyle M Hall (2)
- Paul Poulain (2)
- Benjamin Rokseth (2)
- Fridolin Somers (3)
- Mark Tompsett (1)
- Marc Véron (5)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 16.11.07

- ACPL (1)
- BibLibre (6)
- BSZ BW (1)
- bugs.koha-community.org (19)
- ByWater-Solutions (11)
- Catalyst (1)
- cdalibrary.org (1)
- jns.fi (1)
- Marc Véron AG (5)
- Oslo Public Library (2)
- punsarn.asia (1)
- Rijksmuseum (10)
- Solutions inLibro inc (1)
- Theke Solutions (1)
- translate.koha-community.org (1)
- unidentified (4)

We also especially thank the following individuals who tested patches
for Koha.

- Alex Buckley (1)
- beroud (1)
- Cédric Vita (2)
- Chris Cormack (2)
- Christopher Brannon (2)
- Claire Gravely (1)
- Colin Campbell (1)
- Jesse Maseto (1)
- Joel Sasse (1)
- Jonathan Druart (31)
- Josef Moravec (2)
- Julian Maurice (3)
- Katrin Fischer (61)
- Lari Taskula (1)
- Marc Véron (16)
- Mark Tompsett (1)
- Martin Renvoize (1)
- Mirko Tietgen (1)
- Nick Clemens (14)
- Owen Leonard (3)
- Paul POULAIN (1)
- Sonia BOUIS (1)
- Srdjan (3)
- Brendan A Gallagher (3)
- Kyle M Hall (60)
- Marcel de Rooy (23)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 16.11.x.
The last Koha release was 16.11.06, which was released on March 27, 2017.  

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 22 Apr 2017 05:29:51.
