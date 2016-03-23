# RELEASE NOTES FOR KOHA 3.22.5
23 Mar 2016

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 3.22.5 can be downloaded from:

- [Download](http://download.koha-community.org/koha-3.22.05.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 3.22.5 is a security release.

It includes 1 security fix and 63 bugfixes.


## Security bugs fixed

- [[16095]](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16095) Security issue with the use of target="_blank" or window.open()

## Critical bugs fixed

### Architecture, internals, and plumbing

- [[11998]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11998) Syspref caching issues
- [[15446]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15446) Koha::Object[s]->type should be renamed to _type to avoid conflict with column name

### Circulation

- [[15736]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15736) Add a preference to control whether all items should be shown in checked-in items list
- [[16009]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16009) crash displaying pending offline circulations

### Command-line Utilities

- [[15923]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15923) Export records by id list impossible in export_records.pl

### Database

- [[15840]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15840) Import borrowers tool explodes if userid already exists

### Patrons

- [[15163]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15163) Patron attributes with branch limiits are not saved when invisible


## Other bugs fixed

### About

- [[15721]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15721) About page does not display Apache version

### Architecture, internals, and plumbing

- [[12920]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12920) Remove AllowRenewalLimitOverride from pl scripts, use Koha.Preference instead
- [[15735]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15735) Audio Alerts editor broken by use of of single quotes in editor
- [[15871]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15871) Improve perl critic of t/RecordProcessor.t
- [[15939]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15939) modification logs view now silently defaults to only current day's actions
- [[15968]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15968) Unnecessary loop in C4::Templates
- [[16054]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16054) Plack - variable scope error in paycollect.pl

### Cataloging

- [[15872]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15872) Rancor: Ctrl-Shift-X has incorrect description in "Keyboard shortcuts"
- [[15955]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15955) Tuning function 'New child record' for Unimarc

### Circulation

- [[14244]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14244) viewing a bib item's circ history requires circulation permissions
- [[15706]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15706) Templates require circulate permissions to show circ related tabs when they should only require circulate_remaining_permissions
- [[15833]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15833) Bad variable value in renewal template confirmation dialog

### Command-line Utilities

- [[16031]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16031) sitemap.pl shouldn't append protocol to OPACBaseURL

### Course reserves

- [[15699]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15699) Opac: Course reserves instructors should be in form "Surname, Firstname" for sorting purposes

### Database

- [[15526]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15526) Drop nozebra database table

### Developer documentation

- [[16106]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16106) minor spelling correction to comment

### Documentation

- [[15926]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15926) Item search fields admin missing help file

### Hold requests

- [[15997]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15997) Hold Ratios for ordered items doesn't count orders where AcqCreateItem is set to 'receiving'

### I18N/L10N

- [[13474]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13474) Untranslatable log actions
- [[15674]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15674) 'Show/hide columns' is not translatable

### Installation and upgrade (web-based installer)

- [[15719]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15719) Silence warning in C4/Language.pm during web install

### Label/patron card printing

- [[15663]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15663) Can't delete label from checkbox

### OPAC

- [[15697]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15697) Unnecessary comma between title and subtitle on opac-detail.pl

### Searching

- [[15694]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15694) Date/time-last-modified not searchable

### Serials

- [[15605]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15605) Accessibility: Can't tab to add link in serials routing list add user popup
- [[15981]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15981) Serials frequencies can be deleted without warning
- [[15982]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15982) Serials numbering patterns can be deleted without warning

### Staff Client

- [[15119]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15119) Hide search header text boxes on render
- [[15808]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15808) Remove "Return to where you were before" from sysprefs

### System Administration

- [[15755]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15755) Default item type is not marked as "All" in circulation rules
- [[15790]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15790) Don't delete a MARC framework if existing records use that framework
- [[16013]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16013) Classification sources are not deletable
- [[16014]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16014) OAI sets can be deleted without warning

### Templates

- [[15306]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15306) Don't show translate link for item types if only one language is installed
- [[15667]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15667) Messages in patron account display dates wrongly formatted
- [[15670]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15670) Rename "Cancel" to "Cancel hold" when checking in a waiting item
- [[15691]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15691) Show card number minimum and maximum in visible hint when adding a patron
- [[15693]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15693) Unnecessary punctuation mark when check-in an item in a library other than the home branch
- [[15784]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15784) Library deletion warning is incorrectly styled
- [[15804]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15804) Use standard dialog style for confirmation of MARC subfield deletion
- [[15880]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15880) Serials new frequency link should be a toolbar button
- [[15881]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15881) Serials new numbering pattern link should be a toolbar button
- [[15884]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15884) Vendor contract deletion warning is incorrectly styled
- [[15920]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15920) Clean up and fix errors in batch checkout template
- [[15925]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15925) Correct some markup issues with patron lists pages
- [[15927]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15927) Remove use of <tr class="highlight"> for alternating row colors.
- [[15940]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15940) Remove unused JavaScript from authorities MARC subfield structure
- [[15941]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15941) The template for cloning circulation and fine rules says "issuing rules"
- [[16024]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16024) Use Font Awesome icons on item types administration page
- [[16026]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16026) Use Font Awesome icons on cataloging home page

### Test Suite

- [[14097]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14097) Add unit tests to C4::UsageStats
- [[15445]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15445) DateUtils.t fails on Jenkins due to server sluggishness
- [[15947]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15947) SIPILS.t should be moved to t/db_dependent

### Tools

- [[15658]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15658) Browse system logs: Add more actions to action filter list
- [[16033]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16033) Quotes upload preview broken for 973 days

### Web services

- [[15946]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15946) Broken link to LoC in MARCXML declaration for OAI-PMH ListMetadataFormats

## New sysprefs

- ShowAllCheckins

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
- Armenian (100%)
- Chinese (China) (96%)
- Chinese (Taiwan) (100%)
- Czech (98%)
- Danish (78%)
- English (New Zealand) (90%)
- Finnish (99%)
- French (90%)
- French (Canada) (90%)
- German (100%)
- German (Switzerland) (99%)
- Italian (100%)
- Korean (59%)
- Kurdish (56%)
- Norwegian Bokmål (65%)
- Persian (65%)
- Polish (97%)
- Portuguese (97%)
- Portuguese (Brazil) (96%)
- Slovak (100%)
- Spanish (100%)
- Swedish (84%)
- Turkish (99%)
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

The release team for Koha 3.22.5 is

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
new features in Koha 3.22.5:


We thank the following individuals who contributed patches to Koha 3.22.5.

- Natasha (2)
- Aleisha (3)
- Colin Campbell (1)
- Hector Castro (1)
- Galen Charlton (2)
- Nick Clemens (4)
- Tomás Cohen Arazi (3)
- Frédéric Demians (1)
- Jonathan Druart (31)
- Nicole Engard (2)
- Julian FIOL (6)
- Owen Leonard (18)
- Kyle M Hall (4)
- Julian Maurice (4)
- Thomas Misilo (1)
- Zeno Tajoli (2)
- Mark Tompsett (5)
- Marc Véron (5)
- Jesse Weaver (2)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 3.22.5

- ACPL (18)
- BibLibre (10)
- bugs.koha-community.org (31)
- ByWater-Solutions (12)
- Cineca (2)
- fit.edu (1)
- Marc Véron AG (5)
- PTFS-Europe (1)
- Tamil (1)
- Theke Solutions (2)
- unidentified (13)
- Universidad Nacional de Córdoba (1)

We also especially thank the following individuals who tested patches
for Koha.

- Aleisha (3)
- Chris (2)
- Chris Cormack (1)
- Christopher Brannon (1)
- Frédéric Demians (8)
- Galen Charlton (3)
- Hector Castro (14)
- Jacek Ablewicz (9)
- Jesse Maseto (1)
- Jesse Weaver (5)
- Jonathan Druart (43)
- Josef Moravec (3)
- Julian Maurice (93)
- Katrin Fischer (13)
- Marc Veron (1)
- Marc Véron (12)
- Mark Tompsett (5)
- Mirko Tietgen (1)
- Nick Clemens (2)
- Nicole Engard (1)
- Owen Leonard (2)
- Srdjan (4)
- Tomas Cohen Arazi (14)
- Nicole C Engard (3)
- Brendan A Gallagher (19)
- Indranil Das Gupta (L2C2 Technologies) (4)
- Kyle M Hall (13)
- Bernardo Gonzalez Kriegel (4)
- Marcel de Rooy (5)
- Brendan Gallagher brendan@bywatersolutions.com (59)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 3.22.x.
The last Koha release was 3.22.4, which was released on February 27, 2016.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 23 Mar 2016 15:52:57.
