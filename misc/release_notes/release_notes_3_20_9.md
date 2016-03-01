# RELEASE NOTES FOR KOHA 3.20.9
01 mars 2016

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 3.20.9 can be downloaded from:

- [Download](http://download.koha-community.org/koha-3.20.09.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 3.20.9 is a bugfix/maintenance release.

It includes 6 enhancements, 63 bugfixes.


## Enhancements

### Architecture, internals, and plumbing

- [[15628]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15628) Remove get_branchinfos_of vestiges

### Circulation

- [[15571]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15571) reserveforothers permission does not remove Search to hold button from patron account

### OPAC

- [[15574]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15574) Better wording for error message when adding tags

### Patrons

- [[14406]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14406) When adding messages in patron account, only first name is shown in pull down

### Staff Client

- [[15638]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15638) spelling mistake in ~/Koha/reserve/placerequest.pl:4: writen  ==> written

### System Administration

- [[15552]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15552) Better wording of intranetreadinghistory syspref


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[15680]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15680) Fresh install of Koha cannot find any dependencies
- [[15687]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15687) Syntax errors in misc/translator/xgettext.pl

### Circulation

- [[12045]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12045) Transfer impossible if barcode includes spaces

### Course reserves

- [[15530]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15530) Editing a course item via a disabled course disables it even if it is on other enabled courses

### Koha

- [[15760]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15760) sql injection in opac-shelves.pl

### MARC Authority data support

- [[15188]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15188) remove_unused_authorities.pl will delete all authorities if zebra is not running

### OPAC

- [[13534]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13534) Deleting staff patron will delete tags approved by this patron

### Searching

- [[15818]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15818) OPAC search with utf-8 characters and without results generates encoding error

### Tools

- [[15240]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15240) Performance issue running overdue_notices.pl
- [[15684]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15684) Fix encoding issues with quote upload


## Other bugs fixed

### Acquisitions

- [[15624]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15624) Spelling mistake in suggestion.pl

### Architecture, internals, and plumbing

- [[6679]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=6679) Fixing code so it passes basic Perl::Critic tests
- [[15517]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15517) Tables borrowers and deletedborrowers differ again
- [[15742]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15742) Unnecessary loop in j2a cronjob
- [[15743]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15743) Allow plugins to embed Perl modules

### Authentication

- [[14507]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14507) SIP Authentication broken when LDAP Auth Enabled
- [[15553]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15553) cgisess_ files polluting the /tmp directory

### Cataloging

- [[15411]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15411) "Non fiction" is incorrect

### Circulation

- [[14930]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14930) Leaving OpacFineNoRenewals blank blocks renewals, but should disable feature
- [[15472]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15472) Do not display links to circulation.pl if remaining_permissions is not set

### Command-line Utilities

- [[14624]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14624) <<items.content>> for advance_notices.pl wrongly documented

### Hold requests

- [[15357]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15357) Deleting all items on a record with title level holds creates orphaned/ghost holds
- [[15652]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15652) Allow current date in datepicker on opac-reserve

### I18N/L10N

- [[15375]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15375) Translatability: Fix issues on OPAC page 'Placing a hold'

### Installation and upgrade (command-line installer)

- [[12549]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12549) Hard coded font Paths (  DejaVu ) cause problems for non-Debian systems

### Lists

- [[6322]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=6322) It's possible to view lists/virtualshelves even when virtualshelves is off
- [[15476]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15476) Listname not always displayed in shelves.pl

### MARC Bibliographic data support

- [[15209]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15209) C4::Koha routines  expecting a MARC::Record object should check it is defined
- [[15444]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15444) MARC21: Repeated 508 not correctly formatted (missing separator)

### Notices

- [[14133]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14133) Print notices generated in special case do not use print template

### OPAC

- [[14555]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14555) Warns in opac-search.pl
- [[15577]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15577) Link in OPAC doesn't redirect anywhere
- [[15589]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15589) OPAC Lists "his" string fix

### Packaging

- [[9754]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9754) koha-remove optionally includes var/lib and var/spool

### Patrons

- [[14480]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14480) Warns when modifying patron
- [[15353]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15353) patron image disappears when on fines tab
- [[15619]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15619) Spelling mistake in memberentry.pl
- [[15621]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15621) Spelling mistake in printinvoice
- [[15622]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15622) Spelling mistake in printfreercpt.pl
- [[15623]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15623) Spelling mistake in boraccount.pl
- [[15746]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15746) A random library is used to record an individual payment
- [[15795]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15795) C4/Members.pm is floody (Norwegian Patron DB)

### Reports

- [[2669]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=2669) Radio Buttons where there should be checkboxes on Dictionary
- [[15299]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15299) Add delete confirmation for deleting saved reports
- [[15416]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15416) Warns on Guided Reports page

### SIP2

- [[15479]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15479) SIPserver rejects renewals for patrons with alphanumeric cardnumbers

### Searching

- [[15468]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15468) Search links on callnumbers with parentheses fails on OPAC results page
- [[15613]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15613) Spelling mistake: paramter vs parameter

### Serials

- [[14641]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14641) Warns in subscription-add.pl

### Staff Client

- [[11569]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11569) Typo in userpermissions.sql
- [[15592]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15592) spelling mistake in ~/Koha/koha-tmpl/intranet-tmpl/p./plugins/plugins-upload.tt
- [[15609]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15609) spelling mistake in :692: writen  ==> written
- [[15611]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15611) Spelling mistake: implimented
- [[15614]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15614) Spelling mistake in circ/pendingreserves.tt: Fullfilled

### Templates

- [[11937]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11937) opac link doesn't open in new window
- [[15597]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15597) Typo in opac-auth-detail.tt
- [[15598]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15598) Typo in subscription-add.tt

### Test Suite

- [[15391]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15391) HoldsQueue.t does not handle for loan itemtypes correctly

### Tools

- [[12636]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12636) Batch patron modification should not update with unique patron attributes
- [[14810]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14810) Improve messages in patron anonymizing tool
- [[15398]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15398) Batch patron deletion/anonymization issue page: Restricted dropdown menu

### Web services

- [[15190]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15190) Bad utf8 decode to unapi and fixing code status 200

### Z39.50 / SRU / OpenSearch Servers

- [[15298]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15298) z39.50 admin setup, options column suggested changes



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
- English (United Kingdom) (52%)
- Finnish (86%)
- French (93%)
- French (Canada) (89%)
- German (100%)
- German (Switzerland) (99%)
- Italian (100%)
- Korean (62%)
- Kurdish (59%)
- Norwegian Bokmål (61%)
- Occitan (92%)
- Persian (69%)
- Polish (100%)
- Portuguese (99%)
- Portuguese (Brazil) (91%)
- Slovak (99%)
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

The release team for Koha 3.20.9 is

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
new features in Koha 3.20.9:

- Regionbibliotek Halland / County library of Halland

We thank the following individuals who contributed patches to Koha 3.20.9.

- Blou (1)
- Natasha (1)
- Briana (3)
- Gus (7)
- Aleisha (9)
- Chloe (9)
- Alex Arnaud (1)
- Colin Campbell (4)
- Hector Castro (3)
- Tomás Cohen Arazi (1)
- Frédéric Demians (3)
- Marcel de Rooy (4)
- Jonathan Druart (23)
- Brendan Gallagher (2)
- Mason James (3)
- Owen Leonard (1)
- Julian Maurice (3)
- Kyle M Hall (12)
- Dobrica Pavlinusic (1)
- Winona Salesky (1)
- Juan Sieira (1)
- Martin Stenberg (1)
- Mark Tompsett (1)
- Nicholas van Oudtshoorn (1)
- Marc Véron (4)
- Jesse Weaver (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 3.20.9

- ACPL (1)
- BibLibre (5)
- bugs.koha-community.org (22)
- ByWater-Solutions (15)
- KohaAloha (3)
- Marc Véron AG (4)
- PTFS-Europe (4)
- Rijksmuseum (4)
- rot13.org (1)
- Solutions inLibro inc (1)
- stacmail.net (7)
- Tamil (3)
- unidentified (28)
- Universidad Nacional de Córdoba (1)
- Xercode (1)
- xinxidi.net (1)

We also especially thank the following individuals who tested patches
for Koha.

- Aleisha (5)
- Briana (3)
- Chris (1)
- Chris Cormack (3)
- Frédéric Demians (94)
- Hector Castro (17)
- Jesse Weaver (2)
- Jonathan Druart (32)
- Julian Maurice (98)
- Katrin Fischer (16)
- Liz Rea (2)
- Magnus Enger (2)
- Marc Veron (2)
- Marc Véron (5)
- Margaret Holt (2)
- Mark Tompsett (13)
- Mirko Tietgen (3)
- Nick Clemens (1)
- Owen Leonard (11)
- Philippe Blouin (1)
- Tomas Cohen Arazi (2)
- Brendan Gallagher brendan@bywatersolutions.com (27)
- Brendan A Gallagher (60)
- Kyle M Hall (45)
- Bernardo Gonzalez Kriegel (3)
- Marcel de Rooy (10)
- Juan Romay Sieira (1)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 3.20_20160301.
The last Koha release was 3.16.9, which was released on March 29, 2015.  

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 01 mars 2016 17:02:18.
