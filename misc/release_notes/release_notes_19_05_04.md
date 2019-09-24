# RELEASE NOTES FOR KOHA 19.05.04
24 sept. 2019

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 19.05.04 can be downloaded from:

- [Download](http://download.koha-community.org/koha-19.05.04.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 19.05.04 is a bugfix/maintenance release.

It includes 9 enhancements, 37 bugfixes.




## Enhancements

### Architecture, internals, and plumbing

- [[21180]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21180) Allow Talking Tech outbound script to limit based on patron home library branchcode

### Command-line Utilities

- [[16219]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16219) Runreport.pl should allow SQL parameters to be passed on the command line

### OPAC

- [[23537]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23537) Overdrive won't show complete results if the Overdrive object doesn't have a primaryCreator

### Patrons

- [[21390]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21390) Send self registration verification emails immediately

### REST api

- [[16825]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16825) Add API route for getting an item

> Sponsored by Koha-Suomi Oy


### Templates

- [[21058]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21058) Missing class for results_summary spans
- [[23438]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23438) Use Font Awesome icons in intranet search results browser

### Tools

- [[22272]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22272) Calendar: When entering date ranges grey out dates in the past from the start date
- [[23385]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23385) Hide default value fields by default on patron import


## Critical bugs fixed

### Acquisitions

- [[23397]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23397) Order lines can be duplicated in acqui scripts spent.pl and ordered.pl

### Authentication

- [[23526]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23526) Shibboleth login url with query has double encoded '?' %3F

### Circulation

- [[23079]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23079) Checkouts page broken because of problems with date calculation (TZAmerica/Sao_Paulo)
- [[23404]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23404) Circulation::TooMany error on itemtype when at biblio level
- [[23518]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23518) Problem with borrower search  autocomplete

### Database

- [[23265]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23265) Update to DB revision 16.12.00.032 fails: Unknown column 'me.item_level_hold'

### Installation and upgrade (web-based installer)

- [[23353]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23353) ACQ framework makes fr-CA web installer explode

### Label/patron card printing

- [[23289]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23289) Label Template - Creation not working (MariaDB >= 10.2.4)

### OPAC

- [[23530]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23530) Opac-basket.pl script accidentally displays 'hidden' items

### REST api

- [[23597]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23597) Holds API is missing reserved parameters on the GET spec

### Searching

- [[11677]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11677) Limit to Only items currently available for loan or reference not working
- [[23425]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23425) Search explodes with "invalid data, cannot decode object"

### Searching - Elasticsearch

- [[23004]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23004) Missing authtype filter in auth_finder.pl

### System Administration

- [[23309]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23309) Can't add new subfields to bibliographic frameworks in strict mode


## Other bugs fixed

### Acquisitions

- [[22786]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22786) Can create new funds for locked budgets
- [[23294]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23294) Restore actual cost input field on order page
- [[23319]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23319) Reloading page when adding to basket from existing order can cause internal server error
- [[23338]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23338) Cannot specify replacement price when ordering from file if not using fields to order

### Architecture, internals, and plumbing

- [[23539]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23539) accountlines.accounttype should match authorised_values.authorised_value in size

### Cataloging

- [[22830]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22830) correct for loop in value_builder/unimarc_field_4XX.pl value_builder
- [[23436]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23436) Save to 'undefined' showing in Advanced cataloging editor

### Circulation

- [[23273]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23273) Downloading from overdues.pl doesn't use set filters
- [[23408]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23408) Relatives' checkout table columns are not configured properly

### Hold requests

- [[23502]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23502) Staff client "revert status" buttons should not depend on SuspendHoldsIntranet preference

### MARC Authority data support

- [[23437]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23437) When UseAuthoritiesForTracing is 'Use' we should use series authorities

### MARC Bibliographic record staging/import

- [[23324]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23324) Need an ISBN normalization routine

### Notices

- [[22744]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22744) Remove confusing 'Do not notify' checkboxes from messaging preferences

### OPAC

- [[16111]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16111) RSS feed for OPAC search results has wrong content type
- [[23210]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23210) login4tags should be a link

### SIP2

- [[22037]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22037) regression: guarantor no longer blocked (debarred) if child is over limit, when checking out via SIP.

### Self checkout

- [[22929]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22929) Enabling the GDPR_Policy will affect libraries using the SCO module in Koha

### Serials

- [[23416]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23416) When a note to a specific issue upon receiving a serial, this note will appear in next issue received

### System Administration

- [[23445]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23445) Loan period unit in circulation rules is untranslatable causing problems when editing rules

### Templates

- [[23446]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23446) Fix display issue with serials navigation
- [[23575]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23575) Template error causes item search to be submitted multiple times

### Tools

- [[22799]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22799) Batch item modification is case sensitive

> Sponsored by South Taranaki District Council


### Z39.50 / SRU / OpenSearch Servers

- [[23242]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23242) Error when adding new Z39.50/SRU server in DB strict mode

## New sysprefs

- PreserveSerialNotes

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

- Arabic (99.3%)
- Armenian (100%)
- Basque (60.1%)
- Chinese (China) (60.7%)
- Chinese (Taiwan) (100%)
- Czech (91%)
- Danish (52.7%)
- English (New Zealand) (83.8%)
- English (USA)
- Finnish (80.1%)
- French (94.6%)
- French (Canada) (98.6%)
- German (100%)
- German (Switzerland) (86.9%)
- Greek (74%)
- Hindi (100%)
- Italian (89.5%)
- Norwegian Bokmål (89.7%)
- Occitan (post 1500) (56.8%)
- Polish (83.8%)
- Portuguese (100%)
- Portuguese (Brazil) (93.5%)
- Slovak (85.1%)
- Spanish (99.9%)
- Swedish (89.2%)
- Turkish (98.6%)
- Ukrainian (71.6%)
- Vietnamese (51%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 19.05.04 is

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
new features in Koha 19.05.04:

- Koha-Suomi Oy
- South Taranaki District Council

We thank the following individuals who contributed patches to Koha 19.05.04.

- Aleisha Amohia (1)
- Tomás Cohen Arazi (4)
- Alex Arnaud (1)
- David Bourgault (2)
- Nick Clemens (16)
- Chris Cormack (1)
- Jonathan Druart (16)
- Katrin Fischer (3)
- Martha Fuerst (1)
- Lucas Gass (1)
- Kyle Hall (2)
- Mason James (1)
- Owen Leonard (5)
- Liz Rea (2)
- Martin Renvoize (9)
- Marcel de Rooy (7)
- Caroline Cyr La Rose (1)
- Fridolin Somers (11)
- Emmi Takkinen (1)
- Lari Taskula (1)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 19.05.04

- ACPL (5)
- BibLibre (12)
- BSZ BW (3)
- ByWater-Solutions (19)
- Catalyst (1)
- hmcpl.org (1)
- Independant Individuals (5)
- Koha Community Developers (16)
- KohaAloha (1)
- outlook.com (1)
- PTFS-Europe (9)
- Rijks Museum (7)
- Solutions inLibro inc (1)
- student.uef.fi (1)
- Theke Solutions (4)

We also especially thank the following individuals who tested patches
for Koha.

- Tomás Cohen Arazi (17)
- Cori Lynn Arnold (1)
- Donna Bachowski (1)
- Christopher Brannon (1)
- Nick Clemens (6)
- Michal Denar (4)
- Bouzid Fergani (1)
- Katrin Fischer (27)
- Lucas Gass (2)
- Claire Gravely (1)
- Victor Grousset (1)
- Kyle Hall (12)
- Ron Houk (2)
- Owen Leonard (12)
- Hayley Mapley (2)
- Julian Maurice (1)
- Matthias Meusburger (1)
- Josef Moravec (1)
- Nadine Pierre (2)
- Johanna Raisa (1)
- Liz Rea (3)
- Martin Renvoize (82)
- Marcel de Rooy (29)
- Maryse Simard (8)
- Fridolin Somers (83)
- George Williams (2)



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

Autogenerated release notes updated last on 24 sept. 2019 07:35:29.
