# RELEASE NOTES FOR KOHA 19.05.01
27 juin 2019

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 19.05.01 can be downloaded from:

- [Download](http://download.koha-community.org/koha-19.05.01.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 19.05.01 is a bugfix/maintenance release.

It includes 47 bugfixes and 1 security bug.


## Security bugs fixed

- [[23058]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23058) Cross-site scripting in OPAC search

## Critical bugs fixed

### Architecture, internals, and plumbing

- [[23095]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23095) Circulation rules not displayed (empty vs null)

### Authentication

- [[22585]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22585) Fix remaining double-escaped CAS links

### Circulation

- [[22877]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22877) Returning a lost item not marked as returned can generate additional overdue fines

### Lists

- [[17526]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17526) OPAC lists sortfield breaks with a (

### MARC Authority data support

- [[23053]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23053) Local-Number cannot be used for authority matching due to non-existence of 'phrase' index

### Mana-kb

- [[22915]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22915) Cannot subscribe to Mana-KB

> This fix updates the Mana server URL in etc/koha-conf.xml so that it uses the correct URL - https://mana-kb.koha-community.org.



### Patrons

- [[23082]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23082) Fatal error editing a restricted patron

### System Administration

- [[23104]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23104) Regression (18925) in circ rules - unlimited vs 0

### Tools

- [[23093]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23093) Error during upgrade of OpacNavRight preference to Koha news


## Other bugs fixed

### About

- [[21662]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21662) Missing developers from history
- [[23037]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23037) Henry Bolshaw is missing from the contributors list

### Architecture, internals, and plumbing

- [[16750]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16750) Redirect from selectbranchprinter.pl to additem.pl causes software error
- [[23117]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23117) additem.pl crashes on nonexistent biblionumber

### Cataloging

- [[7890]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7890) Required fields in the MARC editor should be highlighted

> This bugfix modifies the basic MARC editor so that required fields have the standard "Required" label on them instead of a small red asterisk.


- [[21887]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21887) 856$u link problem in XSLT result lists and detail page

### Circulation

- [[13094]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13094) It should be easy to hide the 'Cancel all' button on the holds over report
- [[18344]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18344) Overdue fines 'cap at replacement price' and 'cap by amount' should work together
- [[22982]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22982) Paying lost fee does not always remove lost item from checkouts

### Database

- [[23022]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23022) Koha is not compatible with MySQL >= 8.0.11 because of NO_AUTO_CREATE_USER mode

### Developer documentation

- [[22358]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22358) Add POD to Koha::SharedContent

### Hold requests

- [[22633]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22633) Barcodes in the patrons 'holds' summary should link to the moredetail page

### ILL

- [[22099]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22099) "List requests" button displays when listing requests

> Sponsored by Catalyst IT


### Installation and upgrade (web-based installer)

- [[22770]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22770) Typo in German translation for Greek in language pull down

### Lists

- [[22941]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22941) Giving malformed sortfield to list results in Internal Server Error

### MARC Authority data support

- [[22919]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22919) Authorities MARC Structure not inserted with SQL strict modes

### MARC Bibliographic data support

- [[20986]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20986) MARC21 Supplement and Index Textual Holdings don't display

### OPAC

- [[22945]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22945) Markup error in OPAC search results around lists display
- [[22948]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22948) Markup error in OPAC bibliographic detail template
- [[22950]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22950) Markup error in OPAC recent comment template
- [[22952]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22952) Markup error in OPAC suggestions template
- [[22953]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22953) Markup warning in OPAC user summary template
- [[22954]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22954) Minor markup error in OPAC messaging template
- [[22955]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22955) Markup error in OPAC lists template
- [[23076]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23076) Include OpacUserJS on OPAC maintenance page

> This fix allows the OPAC maintenance page to use JavaScript included in the OPACUserJS system preference.



### Patrons

- [[22910]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22910) Unique attributes should not be copied when duplicating a patron

### SIP2

- [[19457]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19457) If CheckPrevCheckout is set to "Do", then checkouts are blocked at the SIPServer

### Searching

- [[14794]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14794) Searching patron by birthday returns no results if format incorrect

### Searching - Elasticsearch

- [[21534]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21534) ElasticSearch - Wildcards not being analyzed

### Serials

- [[10215]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10215) Increase the size of opacnote and librariannote for table subscriptionhistory
- [[11492]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11492) Receiving a serial item causes routing list notes to be lost

> Sponsored by Plant and Food Research Limited


### Staff Client

- [[22958]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22958) The Help link on SMS providers page should link to the correct chapter in the manual

### System Administration

- [[8558]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8558) Better confirmation message for importing frameworks

> Sponsored by Catalyst IT

- [[22947]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22947) Markup error in OPAC preferences file

### Templates

- [[22906]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22906) Minor corrections to plugins home page
- [[22960]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22960) Typo found in circulation.pref in UpdateItemLocationOnCheckin preference

### Test Suite

- [[23027]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23027) Suggestions.t is failing if no biblio in DB

### Tools

- [[23006]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23006) Can't use inventory tool with barcodes that contain regex relevant characters ($,...)



## System requirements

Important notes:
    
- Perl 5.10 is required
- Zebra is required

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://koha-community.org/manual/19.05/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (93%)
- Armenian (100%)
- Basque (60.2%)
- Chinese (China) (60.8%)
- Chinese (Taiwan) (98.3%)
- Czech (90.9%)
- Danish (52.8%)
- English (New Zealand) (83.9%)
- English (USA)
- Finnish (79.4%)
- French (93.3%)
- French (Canada) (96.3%)
- German (100%)
- German (Switzerland) (87.1%)
- Greek (74.4%)
- Hindi (100%)
- Italian (88.8%)
- Norwegian Bokmål (90.1%)
- Occitan (post 1500) (56.9%)
- Polish (81.4%)
- Portuguese (100%)
- Portuguese (Brazil) (92.3%)
- Slovak (85.4%)
- Spanish (100%)
- Swedish (89.5%)
- Turkish (92.8%)
- Ukrainian (58.6%)
- Vietnamese (50.8%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 19.05.01 is

- Release Manager: Martin Renvoize
- Release Manager assistants:
  - Tomás Cohen Arazi
  - Nick Clemens
- QA Manager: Katrin Fischer
- QA Team:
  - Tomás Cohen Arazi
  - Alex Arnaud
  - Nick Clemens
  - Jonathan Druart
  - Kyle Hall
  - Julian Maurice
  - Josef Moravec
  - Marcel de Rooy
- Topic Experts:
  - REST API -- Tomás Cohen Arazi
  - SIP2 -- Kyle Hall
  - UI Design -- Owen Leonard
  - Elasticsearch -- Alex Arnaud
  - ILS-DI -- Arthur Suzuki
  - Authentication -- Martin Renvoize
- Bug Wranglers:
  - Michal Denár
  - Indranil Das Gupta
  - Jon Knight
  - Lisette Scheer
  - Arthur Suzuki
- Packaging Manager: Mirko Tietgen
- Documentation Manager: David Nind
- Documentation Team:
  - Andy Boze
  - Caroline Cyr-La-Rose
  - Lucy Vaux-Harvey

- Translation Managers: 
  - Indranil Das Gupta
  - Bernardo González Kriegel
- Release Maintainers:
  - 19.05 -- Fridolin Somers
  - 18.11 -- Lucas Gass
  - 18.05 -- Liz Rea
## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 19.05.01:

- Catalyst IT
- Plant and Food Research Limited

We thank the following individuals who contributed patches to Koha 19.05.01.

- Aleisha Amohia (3)
- Alex Arnaud (3)
- Nick Clemens (7)
- Jonathan Druart (13)
- Katrin Fischer (7)
- Kyle Hall (7)
- Pasi Kallinen (1)
- Owen Leonard (12)
- Hayley Mapley (1)
- Joy Nelson (1)
- Liz Rea (1)
- Martin Renvoize (13)
- Justin Rittenhouse (1)
- Marcel de Rooy (1)
- Fridolin Somers (5)
- Mirko Tietgen (1)
- Mark Tompsett (2)
- Koha translators (1)
- Nazlı Çetin (2)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 19.05.01

- abunchofthings.net (1)
- ACPL (12)
- BibLibre (8)
- BSZ BW (7)
- ByWater-Solutions (15)
- Catalyst (1)
- Devinim (2)
- Independant Individuals (6)
- Koha Community Developers (13)
- koha-suomi.fi (1)
- nd.edu (1)
- PTFS-Europe (13)
- Rijks Museum (1)

We also especially thank the following individuals who tested patches
for Koha.

- Axel Amghar (1)
- Tomás Cohen Arazi (1)
- Arthur Bousquet (3)
- Nick Clemens (14)
- Chris Cormack (4)
- Michal Denar (1)
- Jonathan Druart (1)
- Magnus Enger (2)
- Katrin Fischer (34)
- Lucas Gass (1)
- Claire Gravely (1)
- Kyle Hall (1)
- Pasi Kallinen (1)
- David Kuhn (1)
- Owen Leonard (1)
- Nabila Love (1)
- Josef Moravec (4)
- David Nind (1)
- Nadine Pierre (5)
- Liz Rea (20)
- Martin Renvoize (84)
- Marcel de Rooy (11)
- Maryse Simard (9)
- Fridolin Somers (76)
- Mark Tompsett (9)
- Ed Veal (1)
- Marc Véron (1)
- Bin Wen (4)
- Nazlı Çetin (2)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 19.05.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 27 juin 2019 08:08:46.
