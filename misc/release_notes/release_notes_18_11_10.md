# RELEASE NOTES FOR KOHA 18.11.10
21 Sep 2019

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 18.11.10 can be downloaded from:

- [Download](http://download.koha-community.org/koha-18.11.10.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 18.11.10 is a bugfix/maintenance release.

It includes 1 enhancements, 28 bugfixes.




## Enhancements

### Architecture, internals, and plumbing

- [[23237]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23237) Plugin allow [% INCLUDE %] from template


## Critical bugs fixed

### Circulation

- [[23518]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23518) Problem with borrower search  autocomplete

### Database

- [[23265]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23265) Update to DB revision 16.12.00.032 fails: Unknown column 'me.item_level_hold'

### OPAC

- [[23151]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23151) Patron self modification sends null dateofbirth
- [[23530]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23530) Opac-basket.pl script accidentally displays 'hidden' items

### Searching

- [[11677]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11677) Limit to Only items currently available for loan or reference not working

### System Administration

- [[23309]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23309) Can't add new subfields to bibliographic frameworks in strict mode


## Other bugs fixed

### Acquisitions

- [[22786]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22786) Can create new funds for locked budgets
- [[23251]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23251) EDI Order line incorrectly terminated when it ends with a quoted apostrophe
- [[23294]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23294) Restore actual cost input field on order page
- [[23338]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23338) Cannot specify replacement price when ordering from file if not using fields to order

### Cataloging

- [[21518]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21518) Material type "three-dimensional artifact" displays as "visual material"
- [[22830]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22830) correct for loop in value_builder/unimarc_field_4XX.pl value_builder
- [[23436]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23436) Save to 'undefined' showing in Advanced cataloging editor

### Circulation

- [[23273]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23273) Downloading from overdues.pl doesn't use set filters
- [[23408]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23408) Relatives' checkout table columns are not configured properly

### Command-line Utilities

- [[23345]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23345) Wrong parameter name in koha-dump usage statement

### Hold requests

- [[23502]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23502) Staff client "revert status" buttons should not depend on SuspendHoldsIntranet preference

### I18N/L10N

- [[10492]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10492) Translation problems with TT directives in po files

### MARC Authority data support

- [[23437]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23437) When UseAuthoritiesForTracing is 'Use' we should use series authorities

### MARC Bibliographic record staging/import

- [[23324]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23324) Need an ISBN normalization routine

### OPAC

- [[23099]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23099) OPAC Search result sorting "go" button flashes on page load
- [[23210]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23210) login4tags should be a link

### Searching - Elasticsearch

- [[22524]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22524) Elasticsearch - Date range in advanced search

### Staff Client

- [[21716]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21716) Item Search hangs when \ exists in MARC fields

### Templates

- [[23226]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23226) Remove type attribute from script tags: Cataloging
- [[23446]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23446) Fix display issue with serials navigation

### Tools

- [[22799]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22799) Batch item modification is case sensitive

> Sponsored by South Taranaki District Council


### Z39.50 / SRU / OpenSearch Servers

- [[23242]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23242) Error when adding new Z39.50/SRU server in DB strict mode



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

- [Koha Manual](http://koha-community.org/manual/18.11/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (98%)
- Armenian (100%)
- Basque (65.9%)
- Chinese (China) (64%)
- Chinese (Taiwan) (99.2%)
- Czech (93.3%)
- Danish (55.3%)
- English (New Zealand) (88.2%)
- English (USA)
- Finnish (84.4%)
- French (98.9%)
- French (Canada) (99.1%)
- German (100%)
- German (Switzerland) (91.7%)
- Greek (78.3%)
- Hindi (100%)
- Italian (93.8%)
- Norwegian Bokmål (94.6%)
- Occitan (post 1500) (59.5%)
- Polish (86.6%)
- Portuguese (100%)
- Portuguese (Brazil) (87.4%)
- Slovak (89.9%)
- Spanish (99.8%)
- Swedish (90.3%)
- Turkish (98.2%)
- Ukrainian (62%)
- Vietnamese (54.6%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 18.11.10 is

- Release Manager: Nick Clemens
- Release Manager assistants:
  - Tomás Cohen Arazi
  - Jonathan Druart
- QA Manager: Katrin Fischer
- QA Team:
  - Tomás Cohen Arazi
  - Alex Arnaud
  - Chris Cormack
  - Jonathan Druart
  - Kyle Hall
  - Julian Maurice
  - Josef Moravec
  - Martin Renvoize
  - Marcel de Rooy
- Topic Experts:
  - REST API -- Tomás Cohen Arazi
  - SIP2 -- Colin Campbell
  - EDI -- Colin Campbell
  - UI Design -- Owen Leonard
  - Elasticsearch -- Ere Maijala
- Bug Wranglers:
  - Indranil Das Gupta
  - Jon Knight
  - Luis Moises Rojas
- Packaging Manager: Mirko Tietgen
- Documentation Manager: Caroline Cyr-La-Rose
- Documentation Team:
  - David Nind
  - Lucy Vaux-Harvey

- Translation Managers: 
  - Indranil Das Gupta
  - Bernardo González Kriegel

- Wiki curators: 
  - Caroline Cyr-La-Rose
- Release Maintainers:
  - 18.05 -- Lucas Gass
  - 18.05 -- Jesse Maseto
  - 18.11 -- Martin Renvoize
  - 17.11 -- Fridolin Somers
- Release Maintainer assistants:
  - 18.05 -- Kyle Hall

## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 18.11.10:

- South Taranaki District Council

We thank the following individuals who contributed patches to Koha 18.11.10.

- Aleisha Amohia (1)
- Tomás Cohen Arazi (1)
- Alex Arnaud (1)
- Colin Campbell (1)
- Nick Clemens (7)
- Frédéric Demians (1)
- Jonathan Druart (7)
- Katrin Fischer (1)
- Lucas Gass (12)
- Mason James (1)
- Bernardo González Kriegel (1)
- Owen Leonard (6)
- Ere Maijala (2)
- Liz Rea (1)
- Martin Renvoize (2)
- Marcel de Rooy (2)
- Fridolin Somers (1)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 18.11.10

- ACPL (6)
- BibLibre (2)
- BSZ BW (1)
- ByWater-Solutions (19)
- Independant Individuals (2)
- Koha Community Developers (7)
- KohaAloha (1)
- PTFS-Europe (3)
- Rijks Museum (2)
- Tamil (1)
- Theke Solutions (1)
- Universidad Nacional de Córdoba (1)
- University of Helsinki (2)

We also especially thank the following individuals who tested patches
for Koha.

- Tomás Cohen Arazi (3)
- Donna Bachowski (1)
- frederik chenier (1)
- Nick Clemens (14)
- cori (1)
- Michal Denar (3)
- Katrin Fischer (13)
- Lucas Gass (45)
- Victor Grousset (1)
- Kyle Hall (2)
- Ron Houk (2)
- Owen Leonard (6)
- Hayley Mapley (4)
- Liz Rea (2)
- Martin Renvoize (37)
- Marcel de Rooy (9)
- Maryse Simard (5)
- Fridolin Somers (37)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is rmain1811.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 21 Sep 2019 18:41:24.
