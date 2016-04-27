# RELEASE NOTES FOR KOHA 3.20.11
27 avril 2016

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 3.20.11 can be downloaded from:

- [Download](http://download.koha-community.org/koha-3.20.11.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 3.20.11 is a bugfix/maintenance release.

It includes 37 bugfixes.




## Critical bugs fixed

### Notices

- [[15967]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15967) Print notices are not generated if the patron cannot be notified

### OPAC

- [[14614]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14614) Multiple URLs (856) in cart/list email are broken
- [[16210]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16210) Bug 15111 breaks the OPAC if JavaScript is disabled

### Packaging

- [[14633]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14633) apache2-mpm-itk depencency makes Koha uninstallable on Debian Stretch
- [[15713]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15713) Restart zebra when rotating logfiles

### Tools

- [[16040]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16040) Quote deletion never ending processing


## Other bugs fixed

### Acquisitions

- [[15962]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15962) Currency deletion doesn't correctly identify currencies in use

### Architecture, internals, and plumbing

- [[15809]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15809) versions of CGI < 4.08 do not have multi_param
- [[15930]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15930) DataTables patron search defaulting to 'starts_with' and not getting correct parameters to parse multiple word searches

### Cataloging

- [[16171]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16171) Show many media (856) in html5media tab

### Circulation

- [[14841]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14841) Columns settings on checkouts table have 2 bugs
- [[15741]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15741) Incorrect rounding in total fines calculations
- [[15832]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15832) Pending reserves: duplicates branches in datatable filter

### Command-line Utilities

- [[15113]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15113) koha-rebuild-zebra should check USE_INDEXER_DAEMON and skip if enabled

### I18N/L10N

- [[16133]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16133) Translatability of database administrator account warning

### MARC Bibliographic record staging/import

- [[15745]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15745) C4::Matcher gets CCL parsing error if term contains ? (question mark)

### OPAC

- [[14076]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14076) Noisy warns in opac-authorities-home.pl
- [[14441]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14441) TrackClicks cuts off/breaks URLs
- [[15888]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15888) Syndetics Reviews preference should not enable LibraryThing reviews
- [[16179]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16179) Clicking Rate me button in OPAC without selecting rating produces error

### Patrons

- [[15722]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15722) Patron search cannot deal with hidden characters ( tabs ) in fields
- [[15928]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15928) Show unlinked guarantor
- [[16214]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16214) Surname not displayed in serials patron search results

### Reports

- [[1750]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=1750) Report bor_issues_top erroneous and truncated results
- [[16184]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16184) Report bor_issues_top shows incorrect number of rows

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
- [[16029]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16029) Do not show patron toolbar when showing the "patron does not exist" message

### Test Suite

- [[14158]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14158) t/db_dependent/www/search_utf8.t hangs if error is returned
- [[15323]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15323) ./t/Prices.t fails without a valid database
- [[16191]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16191) t/Ris.t is noisy

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
- Arabic (97%)
- Armenian (99%)
- Chinese (China) (86%)
- Chinese (Taiwan) (99%)
- Czech (96%)
- Danish (81%)
- English (New Zealand) (95%)
- Finnish (86%)
- French (93%)
- French (Canada) (89%)
- German (100%)
- German (Switzerland) (100%)
- Italian (100%)
- Korean (62%)
- Kurdish (59%)
- Norwegian Bokmål (60%)
- Occitan (95%)
- Persian (69%)
- Polish (100%)
- Portuguese (98%)
- Portuguese (Brazil) (91%)
- Slovak (100%)
- Spanish (100%)
- Swedish (88%)
- Turkish (100%)
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

The release team for Koha 3.20.11 is

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
new features in Koha 3.20.11:

- Catalyst IT

We thank the following individuals who contributed patches to Koha 3.20.11.

- Aleisha (3)
- Alex Arnaud (3)
- Nick Clemens (2)
- Tomás Cohen Arazi (1)
- David Cook (1)
- Marcel de Rooy (1)
- Jonathan Druart (19)
- Mason James (3)
- Owen Leonard (2)
- Julian Maurice (5)
- Kyle M Hall (1)
- John Seymour (1)
- Mark Tompsett (1)
- Marc Véron (3)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 3.20.11

- ACPL (2)
- BibLibre (8)
- bugs.koha-community.org (19)
- ByWater-Solutions (3)
- KohaAloha (3)
- Marc Véron AG (3)
- nal.gov.au (1)
- Prosentient Systems (1)
- Rijksmuseum (1)
- unidentified (4)
- Universidad Nacional de Córdoba (1)

We also especially thank the following individuals who tested patches
for Koha.

- Brendan Gallagher (8)
- Chris Cormack (6)
- Frédéric Demians (45)
- Hector Castro (2)
- Jesse Weaver (1)
- Jonathan Druart (13)
- Joonas Kylmälä (2)
- Julian Maurice (44)
- Katrin Fischer (23)
- Marc Véron (10)
- Mark Tompsett (6)
- Mason James (1)
- Mirko Tietgen (2)
- Nick Clemens (2)
- Olli-Antti Kivilahti (1)
- Owen Leonard (5)
- Sally Healey (1)
- Tomas Cohen Arazi (8)
- Brendan Gallagher brendan@bywatersolutions.com (10)
- Brendan A Gallagher (18)
- Kyle M Hall (5)
- Your Full Name (1)
- Marcel de Rooy (3)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 3.20.x.
The last Koha release was 3.16.9, which was released on March 29, 2015.  

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 27 avril 2016 15:29:40.
