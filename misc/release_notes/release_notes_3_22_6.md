# RELEASE NOTES FOR KOHA 3.22.6
25 Apr 2016

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 3.22.6 can be downloaded from:

- [Download](http://download.koha-community.org/koha-3.22.06.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 3.22.6 is a security release.

It includes 1 security fix and 61 bugfixes.


## Security bugs fixed

- [[15111]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15111) Koha is vulnerable to Cross-Frame Scripting (XFS) attacks

## Critical bugs fixed

### Architecture, internals, and plumbing

- [[16068]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16068) System preference override feature (OVERRIDE_SYSPREF_* = ) is not reliable for some cache systems
- [[16084]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16084) log4perl.conf not properly set on packages
- [[16138]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16138) Restart plack when rotating logfiles

### Authentication

- [[15889]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15889) Login with LDAP deletes extended attributes

### Circulation

- [[15757]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15757) Hard coded due loan/renewal period of 21 days if no circ rule found in C4::Circulation::GetLoanLength
- [[16082]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16082) Empty patron detail page is displayed if the patron does not exist - circulation.pl
- [[16240]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16240) Regression: Bug 16082 causes message to be displayed even when no borrowernumber is passed

### Hold requests

- [[16151]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16151) can't place holds from lists

### Notices

- [[15967]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15967) Print notices are not generated if the patron cannot be notified

### OPAC

- [[14614]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14614) Multiple URLs (856) in cart/list email are broken
- [[16210]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16210) Bug 15111 breaks the OPAC if JavaScript is disabled
- [[16317]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16317) Attempt to share private list results in error

### Packaging

- [[14633]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14633) apache2-mpm-itk depencency makes Koha uninstallable on Debian Stretch
- [[15713]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15713) Restart zebra when rotating logfiles

### Tools

- [[16040]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16040) Quote deletion never ending processing

### Web services

- [[16222]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16222) Add REST API folder to Makefile.PL


## Other bugs fixed

### Acquisitions

- [[15962]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15962) Currency deletion doesn't correctly identify currencies in use
- [[16055]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16055) Deleting a basket group containing baskets fails silently
- [[16146]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16146) [3.22] ACQ: Previewed records in Z39.50 search results are wrong

### Architecture, internals, and plumbing

- [[15809]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15809) versions of CGI < 4.08 do not have multi_param
- [[15930]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15930) DataTables patron search defaulting to 'starts_with' and not getting correct parameters to parse multiple word searches
- [[16104]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16104) Warnings "used only once: possible typo" should be removed

### Cataloging

- [[15682]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15682) Merging records from cataloguing search only allows to merge 2 records
- [[16171]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16171) Show many media (856) in html5media tab

### Circulation

- [[15741]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15741) Incorrect rounding in total fines calculations
- [[15832]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15832) Pending reserves: duplicates branches in datatable filter

### Command-line Utilities

- [[15113]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15113) koha-rebuild-zebra should check USE_INDEXER_DAEMON and skip if enabled

### I18N/L10N

- [[15861]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15861) No chance to correctly translate an isolated word "The"
- [[16133]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16133) Translatability of database administrator account warning

### MARC Bibliographic record staging/import

- [[15745]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15745) C4::Matcher gets CCL parsing error if term contains ? (question mark)

### OPAC

- [[14076]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14076) Noisy warns in opac-authorities-home.pl
- [[14441]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14441) TrackClicks cuts off/breaks URLs
- [[15888]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15888) Syndetics Reviews preference should not enable LibraryThing reviews
- [[16143]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16143) Wrong icon PATH on virtualshelves
- [[16179]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16179) Clicking Rate me button in OPAC without selecting rating produces error
- [[16296]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16296) Virtualshelves: Using no OPACXSLTResultsDisplay breaks content display

### Patrons

- [[15722]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15722) Patron search cannot deal with hidden characters ( tabs ) in fields
- [[15928]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15928) Show unlinked guarantor
- [[16214]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16214) Surname not displayed in serials patron search results

### Reports

- [[1750]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=1750) Report bor_issues_top erroneous and truncated results
- [[15421]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15421) Show all available actions in reports toolbar
- [[16184]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16184) Report bor_issues_top shows incorrect number of rows
- [[16185]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16185) t/db_dependent/Reports_Guided.t is failing

### SIP2

- [[13871]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13871) OverDrive message when user authentication fails

### Searching

- [[14816]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14816) Item search returns no results with multiple values selected for one field

### Self checkout

- [[11498]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11498) Prevent bypassing sco timeout with print dialog

### Serials

- [[15838]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15838) syspref SubscriptionDuplicateDroppedInput does not work for all fields

### System Administration

- [[15773]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15773) Checkboxes do not work correctly when creating a new subfield for an authority framework
- [[16047]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16047) Software error on deleting a group with no category code

### Templates

- [[15984]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15984) Correct templates which use the phrase "issuing rules"
- [[16023]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16023) Use Font Awesome icons on audio alerts page
- [[16025]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16025) Use Font Awesome icons on item types localization page
- [[16027]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16027) Use Font Awesome icons in the professional cataloging interface
- [[16029]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16029) Do not show patron toolbar when showing the "patron does not exist" message

### Test Suite

- [[14158]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14158) t/db_dependent/www/search_utf8.t hangs if error is returned
- [[15323]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15323) ./t/Prices.t fails without a valid database
- [[16134]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16134) t::lib::Mocks::mock_preference should be case-insensitive
- [[16191]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16191) t/Ris.t is noisy
- [[16224]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16224) Random failure for t/db_dependent/Reports_Guided.t

### Tools

- [[15866]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15866) No warning when deleting a rotating collection using the toolbar button
- [[15868]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15868) Ask for confirmation before deleting MARC modification template action



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
- Armenian (99%)
- Chinese (China) (95%)
- Chinese (Taiwan) (99%)
- Czech (97%)
- Danish (78%)
- English (New Zealand) (90%)
- Finnish (98%)
- French (91%)
- French (Canada) (92%)
- German (100%)
- German (Switzerland) (100%)
- Italian (100%)
- Korean (58%)
- Kurdish (55%)
- Norwegian Bokmål (65%)
- Persian (65%)
- Polish (100%)
- Portuguese (97%)
- Portuguese (Brazil) (96%)
- Slovak (100%)
- Spanish (100%)
- Swedish (83%)
- Turkish (100%)
- Vietnamese (80%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

for information about translating Koha, and join the koha-translate
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 3.22.6 is

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
new features in Koha 3.22.6:

- American Numismatic Society
- Catalyst IT

We thank the following individuals who contributed patches to Koha 3.22.6.

- Aleisha (5)
- Alex Arnaud (5)
- Nick Clemens (4)
- Tomás Cohen Arazi (6)
- David Cook (1)
- Jonathan Druart (27)
- Mason James (5)
- Owen Leonard (6)
- Kyle M Hall (2)
- Julian Maurice (8)
- Benjamin Rokseth (1)
- John Seymour (1)
- Mark Tompsett (2)
- Marc Véron (3)
- Marcel de Rooy (6)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 3.22.6

- ACPL (6)
- BibLibre (13)
- bugs.koha-community.org (27)
- ByWater-Solutions (6)
- KohaAloha (5)
- Marc Véron AG (3)
- nal.gov.au (1)
- Oslo Public Library (1)
- Prosentient Systems (1)
- Rijksmuseum (6)
- Theke Solutions (4)
- unidentified (7)
- Universidad Nacional de Córdoba (2)

We also especially thank the following individuals who tested patches
for Koha.

- Brendan Gallagher (18)
- Chris (1)
- Chris Cormack (9)
- Hector Castro (2)
- Jacek Ablewicz (1)
- Jesse Weaver (2)
- Jonathan Druart (20)
- Julian Maurice (80)
- Katrin Fischer (36)
- Marc Véron (16)
- Mark Tompsett (11)
- Martin Renvoize (2)
- Mason James (1)
- Mirko Tietgen (3)
- Nick Clemens (3)
- Olli-Antti Kivilahti (1)
- Owen Leonard (7)
- Philippe Blouin (1)
- Sally Healey (1)
- Tomas Cohen Arazi (10)
- Brendan A Gallagher (33)
- Kyle M Hall (9)
- Bernardo Gonzalez Kriegel (4)
- Your Full Name (1)
- Marcel de Rooy (13)
- Brendan Gallagher brendan@bywatersolutions.com (17)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 3.22.x.
The last Koha release was 3.22.5, which was released on March 23, 2016.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 25 Apr 2016 12:32:35.
