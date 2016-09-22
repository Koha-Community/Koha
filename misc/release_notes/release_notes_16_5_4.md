# RELEASE NOTES FOR KOHA 16.5.4
22 sept. 2016

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 16.5.4 can be downloaded from:

- [Download](http://download.koha-community.org/koha-16.05.04.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 16.5.4 is a bugfix/maintenance release.

It includes 17 enhancements, 44 bugfixes.




## Enhancements

### Acquisitions

- [[16738]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16738) Improve EDIFACT messages template
- [[16843]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16843) Help for EDIFACT messages
- [[16981]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16981) Add EDI admin links to acq menu

### Label/patron card printing

- [[16576]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16576) Remove the use of "onclick" from label templates

### OPAC

- [[5456]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=5456) Create a link to opac-ics.pl
- [[16507]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16507) show play media tab first
- [[16875]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16875) OPAC:  Removing link to records if authority is not used by any records
- [[17210]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17210) Remove use of onclick from biblio detail sidebar in OPAC
- [[17220]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17220) Improve clarity when placing a hold by changing button text from "Place hold" to "Confirm hold"
- [[17222]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17222) Remove use of onclick from OPAC member entry page

### Packaging

- [[17030]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17030) Configure the REST api on packages install

### Serials

- [[16950]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16950) Serials subscriptions advanced search shows '0 found' pre-search

### System Administration

- [[16841]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16841) Help for Library EANs
- [[16842]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16842) Help for EDI accounts

### Templates

- [[17011]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17011) Remove "onblur" event attribute from some templates

### Tools

- [[16937]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16937) Remove the use of "onclick" from the manage staged MARC records template
- [[17161]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17161) Making 'preview MARC' links show as buttons in batch record mod


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[16556]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16556) KohaToMarcMapped columns sharing same field with biblio(item)number are removed.
- [[17048]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17048) Authority search result list page scrolling not working properly

### Cataloging

- [[17072]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17072) 006 not filling in with existing values

### Circulation

- [[14390]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14390) Fine not updated from 'FU' to 'F' on renewal
- [[17135]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17135) Fine for the previous overdue may get overwritten by the next one

### Command-line Utilities

- [[11144]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11144) Fix sequence of cronjobs: automatic renewal - fines - overdue notices

### Hold requests

- [[17010]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17010) Canceling a hold awaiting pickup no longer alerts librarian about next hold

### Installation and upgrade (web-based installer)

- [[16554]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16554) Web installer fails to load i18n sample data on MySQL 5.6+

### OPAC

- [[16686]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16686) Fix "Item in transit from since" in Holds tab
- [[16996]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16996) Template process failed: undef error - Can't call method "description"

### Packaging

- [[17262]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17262) Plack on packages is not having memcached set properly


## Other bugs fixed

### Acquisitions

- [[17141]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17141) Incorrect method called in edi_cron to get logdir

### Architecture, internals, and plumbing

- [[16449]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16449) unimarc_field_4XX raises a warning
- [[17128]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17128) summary-print.pl is not plack safe
- [[17157]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17157) Middle click on dropdown menu in header may cause software error
- [[17223]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17223) Add Cache::Memcached to PerlDependencies
- [[17231]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17231) HTML5MediaYouTube should recognize youtu.be links from youtube as well at the full links

### Cataloging

- [[12629]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12629) Software error when trying to merge records from different frameworks
- [[17152]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17152) Duplicating a subfield should not copy the data
- [[17194]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17194) When edit record, Button "Z39.50/SRU search" not work
- [[17201]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17201) Remaining calls to C4::Context->marcfromkohafield
- [[17206]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17206) Can't switch to default framework

### Command-line Utilities

- [[16822]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16822) koha-common init.d script should run koha-plack without quiet

### Label/patron card printing

- [[17175]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17175) Typo in patron card images error message

### Lists

- [[17185]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17185) Staff client shows "Lists that include this title:" even if item is not in a list

### MARC Authority data support

- [[17118]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17118) Regression: Bug 15381 triggers error when trying to clear a linked authority

### MARC Bibliographic data support

- [[17281]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17281) Warning when saving subfield structure

### MARC Bibliographic record staging/import

- [[6852]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=6852) Staged import reports wrong success for items with false branchcode

### OPAC

- [[14434]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14434) OPAC should indicate to patrons that auto renewal will not work because hold has been placed
- [[16311]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16311) Advanced search language limit typo for Romanian
- [[16464]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16464) If a patron has been discharged, show a message in the OPAC
- [[17142]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17142) Don't show library group selection in advanced search if groups are not defined

### Packaging

- [[17228]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17228) Make two versions of SIPconfig.xml identical
- [[17266]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17266) Update man page for koha-remove with -p
- [[17267]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17267) Document koha-create --adminuser

### Staff Client

- [[16809]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16809) Silence CGI param warnings from C4::Biblio::TransformHtmlToMarc
- [[17149]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17149) EDI accounts: Add missing '>' to breadcrumb

### System Administration

- [[11019]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11019) Require some fields when adding authorized value category

### Templates

- [[13921]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13921) XSLT Literary Formats Not Showing
- [[16903]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16903) Multiple class attributes on catalog search tab
- [[16990]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16990) Show branch name instead of branch code when managing patron modification requests
- [[17200]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17200) Badly formatted "hold for" patron name on catalog detail page

### Tools

- [[14612]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14612) Overdue notice triggers should show branchname instead of branchcode
- [[16886]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16886) 'Upload patron images' tool is not plack safe



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
- Chinese (Taiwan) (100%)
- Czech (96%)
- Danish (74%)
- English (New Zealand) (98%)
- Finnish (93%)
- French (94%)
- French (Canada) (91%)
- German (100%)
- German (Switzerland) (100%)
- Greek (78%)
- Hindi (100%)
- Italian (100%)
- Korean (55%)
- Kurdish (52%)
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

The release team for Koha 16.5.4 is

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
new features in Koha 16.5.4:

- ByWater Solutions
- Catalyst IT
- Hochschule für Gesundheit (hsg), Germany

We thank the following individuals who contributed patches to Koha 16.5.4.

- Aleisha (6)
- Jacek Ablewicz (5)
- Aleisha Amohia (4)
- Colin Campbell (1)
- Hector Castro (1)
- Nick Clemens (2)
- Tomás Cohen Arazi (2)
- Frédéric Demians (8)
- Marcel de Rooy (7)
- Jonathan Druart (20)
- Nicole Engard (1)
- Magnus Enger (5)
- Katrin Fischer (1)
- Bernardo González Kriegel (9)
- Lee Jamison (1)
- Olli-Antti Kivilahti (1)
- Owen Leonard (12)
- Holger Meißner (1)
- Kyle M Hall (7)
- Andreas Roussos (2)
- Mirko Tietgen (1)
- Mark Tompsett (1)
- Marc Véron (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 16.5.4

- abunchofthings.net (1)
- ACPL (12)
- biblos.pk.edu.pl (5)
- BSZ BW (1)
- bugs.koha-community.org (20)
- ByWater-Solutions (10)
- Hochschule für Gesundheit (hsg), Germany (1)
- jns.fi (1)
- Libriotech (5)
- Marc Véron AG (1)
- marywood.edu (1)
- PTFS-Europe (1)
- Rijksmuseum (7)
- Tamil (8)
- Theke Solutions (2)
- unidentified (14)
- Universidad Nacional de Córdoba (9)

We also especially thank the following individuals who tested patches
for Koha.

- Aleisha Amohia (8)
- Andreas Roussos (1)
- Chris Cormack (6)
- Claire Gravely (8)
- Colin Campbell (1)
- Frédéric Demians (94)
- Hector Castro (4)
- Jacek Ablewicz (1)
- Jonathan Druart (41)
- Katrin Fischer (7)
- Liz Rea (5)
- Marc (7)
- Marc Véron (11)
- Mark Tompsett (10)
- Mirko Tietgen (1)
- Nick Clemens (12)
- Owen Leonard (6)
- Sean Minkel (1)
- Katrin Fischer  (18)
- Nicole C Engard (1)
- Kyle M Hall (92)
- Marcel de Rooy (20)

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

Autogenerated release notes updated last on 22 sept. 2016 12:45:40.
