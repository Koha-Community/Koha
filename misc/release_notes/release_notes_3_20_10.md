# RELEASE NOTES FOR KOHA 3.20.10
23 mars 2016

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 3.20.10 can be downloaded from:

- [Download](http://download.koha-community.org/koha-3.20.10.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 3.20.10 is a bugfix/maintenance release.

It includes 37 bugfixes.




## Critical bugs fixed

### Circulation

- [[15736]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15736) Add a preference to control whether all items should be shown in checked-in items list

### Database

- [[15840]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15840) Import borrowers tool explodes if userid already exists

### Hold requests

- [[15998]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15998) software error in svc/holds in 3.20.x

### Koha

- [[16095]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16095) Security issue with the use of target="_blank" or window.open()


## Other bugs fixed

### About

- [[15721]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15721) About page does not display Apache version

### Architecture, internals, and plumbing

- [[15968]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15968) Unnecessary loop in C4::Templates
- [[16054]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16054) Plack - variable scope error in paycollect.pl

### Cataloging

- [[15955]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15955) Tuning function 'New child record' for Unimarc

### Circulation

- [[14244]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14244) viewing a bib item's circ history requires circulation permissions
- [[15833]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15833) Bad variable value in renewal template confirmation dialog

### Course reserves

- [[15699]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15699) Opac: Course reserves instructors should be in form "Surname, Firstname" for sorting purposes

### Documentation

- [[15926]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15926) Item search fields admin missing help file

### Hold requests

- [[15997]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15997) Hold Ratios for ordered items doesn't count orders where AcqCreateItem is set to 'receiving'

### I18N/L10N

- [[13474]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13474) Untranslatable log actions
- [[15674]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15674) 'Show/hide columns' is not translatable

### Installation and upgrade (web-based installer)

- [[15719]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15719) Silence warning in C4/Language.pm during web install

### OPAC

- [[15697]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15697) Unnecessary comma between title and subtitle on opac-detail.pl

### Serials

- [[15605]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15605) Accessibility: Can't tab to add link in serials routing list add user popup
- [[15981]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15981) Serials frequencies can be deleted without warning
- [[15982]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15982) Serials numbering patterns can be deleted without warning

### Staff Client

- [[15119]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15119) Hide search header text boxes on render
- [[15808]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15808) Remove "Return to where you were before" from sysprefs

### System Administration

- [[15790]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15790) Don't delete a MARC framework if existing records use that framework
- [[16013]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16013) Classification sources are not deletable
- [[16014]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16014) OAI sets can be deleted without warning

### Templates

- [[15667]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15667) Messages in patron account display dates wrongly formatted
- [[15691]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15691) Show card number minimum and maximum in visible hint when adding a patron
- [[15784]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15784) Library deletion warning is incorrectly styled
- [[15804]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15804) Use standard dialog style for confirmation of MARC subfield deletion
- [[15880]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15880) Serials new frequency link should be a toolbar button
- [[15881]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15881) Serials new numbering pattern link should be a toolbar button
- [[15884]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15884) Vendor contract deletion warning is incorrectly styled
- [[15940]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15940) Remove unused JavaScript from authorities MARC subfield structure
- [[15941]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15941) The template for cloning circulation and fine rules says "issuing rules"

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
- Arabic (97%)
- Armenian (100%)
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
- Occitan (96%)
- Persian (69%)
- Polish (99%)
- Portuguese (98%)
- Portuguese (Brazil) (91%)
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

The release team for Koha 3.20.10 is

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
new features in Koha 3.20.10:


We thank the following individuals who contributed patches to Koha 3.20.10.

- Aleisha (1)
- Natasha (1)
- Nick Clemens (4)
- Tomás Cohen Arazi (1)
- Frédéric Demians (2)
- Jonathan Druart (12)
- Nicole Engard (1)
- Owen Leonard (12)
- Julian Maurice (1)
- Kyle M Hall (2)
- Thomas Misilo (1)
- Zeno Tajoli (2)
- Mark Tompsett (2)
- Marc Véron (5)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 3.20.10

- ACPL (12)
- BibLibre (1)
- bugs.koha-community.org (12)
- ByWater-Solutions (7)
- Cineca (2)
- fit.edu (1)
- Marc Véron AG (5)
- Tamil (2)
- unidentified (4)
- Universidad Nacional de Córdoba (1)

We also especially thank the following individuals who tested patches
for Koha.

- Aleisha (2)
- Chris (1)
- Christopher Brannon (1)
- Frédéric Demians (50)
- Hector Castro (8)
- Jesse Weaver (1)
- Jonathan Druart (22)
- Julian Maurice (43)
- Katrin Fischer (4)
- Marc Véron (8)
- Mark Tompsett (1)
- Nick Clemens (1)
- Nicole Engard (1)
- Owen Leonard (2)
- Srdjan (3)
- Tomas Cohen Arazi (4)
- Brendan Gallagher brendan@bywatersolutions.com (28)
- Nicole C Engard (2)
- Brendan A Gallagher (8)
- Kyle M Hall (8)
- Marcel de Rooy (3)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 3.20_20160323.
The last Koha release was 3.16.9, which was released on March 29, 2015.  

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 23 mars 2016 15:10:39.
