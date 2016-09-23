# RELEASE NOTES FOR KOHA 3.22.11
23 Sep 2016

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 3.22.11 can be downloaded from:

- [Download](http://download.koha-community.org/koha-3.22.11.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 3.22.11 is a security release.

It includes 2 security fixes, 32 bugfixes and 2 enhancements.

## Security fixes

- [[16587]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16587) Reflected XSS in [opac-]sendbasket and [opac-]sendshelf
- [[17114]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17114) picture-upload.pl is vulnerable to XSS attacks


## Enhancements

### OPAC

- [[17220]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17220) Improve clarity when placing a hold by changing button text from "Place hold" to "Confirm hold"

### Serials

- [[16950]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16950) Serials subscriptions advanced search shows '0 found' pre-search


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[16556]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16556) KohaToMarcMapped columns sharing same field with biblio(item)number are removed.

### Cataloging

- [[17072]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17072) 006 not filling in with existing values

### Circulation

- [[14390]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14390) Fine not updated from 'FU' to 'F' on renewal

### Command-line Utilities

- [[11144]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11144) Fix sequence of cronjobs: automatic renewal - fines - overdue notices

### Hold requests

- [[17010]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17010) Canceling a hold awaiting pickup no longer alerts librarian about next hold

### Installation and upgrade (web-based installer)

- [[16554]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16554) Web installer fails to load i18n sample data on MySQL 5.6+


### Packaging

- [[17262]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17262) Plack on packages is not having memcached set properly


## Other bugs fixed

### Architecture, internals, and plumbing

- [[17128]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17128) summary-print.pl is not plack safe
- [[17157]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17157) Middle click on dropdown menu in header may cause software error
- [[17223]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17223) Add Cache::Memcached to PerlDependencies

### Cataloging

- [[12629]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12629) Software error when trying to merge records from different frameworks
- [[17152]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17152) Duplicating a subfield should not copy the data

### Command-line Utilities

- [[16822]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16822) koha-common init.d script should run koha-plack without quiet


### Label/patron card printing

- [[17175]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17175) Typo in patron card images error message

### Lists

- [[17185]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17185) Staff client shows "Lists that include this title:" even if item is not in a list

### MARC Bibliographic data support

- [[17281]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17281) Warning when saving subfield structure

### MARC Bibliographic record staging/import

- [[6852]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=6852) Staged import reports wrong success for items with false branchcode

### OPAC

- [[14434]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14434) OPAC should indicate to patrons that auto renewal will not work because hold has been placed
- [[16311]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16311) Advanced search language limit typo for Romanian
- [[16464]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16464) If a patron has been discharged, show a message in the OPAC

### Packaging

- [[17228]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17228) Make two versions of SIPconfig.xml identical
- [[17266]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17266) Update man page for koha-remove with -p
- [[17267]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17267) Document koha-create --adminuser

### Staff Client

- [[16809]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16809) Silence CGI param warnings from C4::Biblio::TransformHtmlToMarc

### System Administration

- [[11019]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11019) Require some fields when adding authorized value category

### Templates

- [[13921]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13921) XSLT Literary Formats Not Showing
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
- Armenian (99%)
- Chinese (China) (94%)
- Chinese (Taiwan) (98%)
- Czech (98%)
- Danish (77%)
- English (New Zealand) (98%)
- Finnish (97%)
- French (92%)
- French (Canada) (92%)
- German (99%)
- German (Switzerland) (99%)
- Greek (80%)
- Hindi (100%)
- Italian (99%)
- Korean (57%)
- Kurdish (55%)
- Norwegian Bokmål (63%)
- Persian (64%)
- Polish (100%)
- Portuguese (100%)
- Portuguese (Brazil) (95%)
- Slovak (99%)
- Spanish (100%)
- Swedish (82%)
- Turkish (99%)
- Vietnamese (79%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

for information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 3.22.11 is

- Release Manager: [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
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
new features in Koha 3.22.11:

- ByWater Solutions
- Catalyst IT
- Hochschule für Gesundheit (hsg), Germany

We thank the following individuals who contributed patches to Koha 3.22.11.

- Aleisha (1)
- Jacek Ablewicz (1)
- Aleisha Amohia (1)
- Hector Castro (1)
- Tomás Cohen Arazi (2)
- Chris Cormack (2)
- Frédéric Demians (2)
- Jonathan Druart (7)
- Magnus Enger (4)
- Katrin Fischer (1)
- Bernardo González Kriegel (8)
- Lee Jamison (1)
- Olli-Antti Kivilahti (1)
- Owen Leonard (6)
- Kyle M Hall (7)
- Julian Maurice (2)
- Holger Meißner (1)
- Andreas Roussos (2)
- Mirko Tietgen (2)
- Mark Tompsett (1)
- Marcel de Rooy (4)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 3.22.11

- abunchofthings.net (2)
- ACPL (6)
- BibLibre (2)
- biblos.pk.edu.pl (1)
- BigBallOfWax (2)
- BSZ BW (1)
- bugs.koha-community.org (7)
- ByWater-Solutions (7)
- Hochschule für Gesundheit (hsg), Germany (1)
- jns.fi (1)
- Libriotech (4)
- marywood.edu (1)
- Rijksmuseum (4)
- Tamil (2)
- Theke Solutions (2)
- unidentified (6)
- Universidad Nacional de Córdoba (8)

We also especially thank the following individuals who tested patches
for Koha.

- Aleisha Amohia (3)
- Brendan Gallagher (3)
- Chris Cormack (3)
- Claire Gravely (5)
- Colin Campbell (1)
- Frédéric Demians (49)
- Hector Castro (2)
- Jacek Ablewicz (1)
- Jonathan Druart (26)
- Julian Maurice (54)
- Katrin Fischer (1)
- Liz Rea (4)
- Marc (1)
- Marc Véron (3)
- Mark Tompsett (8)
- Mirko Tietgen (1)
- Nick Clemens (6)
- Owen Leonard (3)
- Sean Minkel (1)
- Katrin Fischer  (11)
- Kyle M Hall (53)
- Marcel de Rooy (13)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 3.22.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 23 Sep 2016 06:59:11.
