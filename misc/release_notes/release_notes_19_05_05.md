# RELEASE NOTES FOR KOHA 19.05.05
28 Nov 2019

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 19.05.05 can be downloaded from:

- [Download](http://download.koha-community.org/koha-19.05.05.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 19.05.05 is a bugfix/maintenance release with security fixes.

It includes 5 security fixes, 1 enhancements, 59 bugfixes.

### System requirements

Koha is continiously tested against the following configurations and as such these are the recommendations for 
deployment: 

- Debian Jessie with MySQL 5.5
- Debian Stretch with MariaDB 10.1 (MySQL 8.0 support is experimental)
- Ubuntu Bionic with MariaDB 10.1 (MariaDB 10.3 support is experimental) 

Additional notes:
    
- Perl 5.10 is required
- Zebra or Elasticsearch is required


## Security bugs

### Koha

- [[22543]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22543) Patron might be logged in again using browser back button
- [[23042]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23042) Local login attempt populates shibboleth url with userid and password in plain text
- [[23329]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23329) tracklinks.pl accepts any url from a parameter for proxying if not tracking
- [[23451]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23451) Reflected XSS in opac-imageviewer.pl
- [[23836]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23836) tracklinks.pl should not forward if TrackClicks is disabled


## Enhancements

### I18N/L10N

- [[23631]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23631) fr-CA translation of NEW_SUGGESTION notice


## Critical bugs fixed

### Acquisitions

- [[18743]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18743) Filter suggestion lists correctly for IndependentBranches

  **Sponsored by** *BULAC*
- [[23854]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23854) Cannot edit a suggestion
- [[23855]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23855) Cannot mark the selected suggestion as "pending"
- [[23863]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23863) Editing a basket clears create_items value

### Architecture, internals, and plumbing

- [[22857]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22857) Entries missing in koha-conf.xml
- [[23723]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23723) Using exit inside eval to stop sending output to the browser doesn't work under Plack
- [[23867]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23867) 18.12.00.051 fails with "Truncated incorrect DOUBLE value"

### Authentication

- [[23526]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23526) Shibboleth login url with query has double encoded '?' %3F
- [[23771]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23771) CAS/Shib Authentication can fail when multiple users with no userid/cardnumber defined and one of them is locked

### Cataloging

- [[23252]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23252) Pressing enter should not submit form in item editor
- [[23851]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23851) Auto generate accession number format <branchcode>yymm0001 fails to add branchcode prefix(branchcode) for multiple item addition

### Circulation

- [[23551]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23551) Problem with renewal period when using the renewal tab
- [[23774]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23774) When placing a hold editing using Inspect Element allows addition to the code of non listed library
- [[23938]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23938) Title missing from Checked out box
- [[23985]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23985) The method Koha::Item-> is not covered by tests!
- [[24075]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24075) Backdating a return to the exact due date and time results in the fine not being refunded

### Command-line Utilities

- [[23933]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23933) commit_file.pl Can't call method "get_effective_marcorgcode" on an undefined value at /usr/share/koha/lib/C4/AuthoritiesMarc.pm line 578.

### Database

- [[23579]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23579) error during web install: 'changed_fields' can't have a default value
- [[23809]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23809) Update to DB revision 16.12.00.032 fails

### Fines and fees

- [[23826]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23826) Manual Invoice does not use new accounttype and status for fines

### Hold requests

- [[23484]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23484) Holds to pull (pendingreserves.pl) uses removed default_branch_item_rules table

### I18N/L10N

- [[23713]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23713) Subscription add form broken for translations

### ILL

- [[23529]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23529) Interlibrary loan javascript is broken

### Installation and upgrade (command-line installer)

- [[23813]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23813) DB error on 18.12.00.020

### MARC Bibliographic record staging/import

- [[23846]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23846) Handle records with broken MARCXML on the bibliographic detail view

### Notices

- [[23181]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23181) Unable to use payment library in ACCOUNT_PAYMENT or ACCOUNT_WRITEOFF notices
- [[23765]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23765) After TranslateNotices is set to 'Don't allow', email settings still show multiple languages

### OPAC

- [[23467]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23467) Duplicated screen if error in opac-reserve.pl

### Patrons

- [[17140]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17140) Incorrect rounding in total fines calculations, part 2
- [[23822]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23822) Regression: As of 19.05.04 deletion of patrons with outstanding credits is silently blocked

### Reports

- [[23626]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23626) Add a system preference to limit the number of rows of data used when charting or exporting report results
- [[23827]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23827) [19.05] Cash register statistics uses old accounttype values

### Searching - Elasticsearch

- [[22997]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22997) Searching gives no results in auth_finder.pl
- [[23630]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23630) Elasticsearch indexing is removing field 999

  >In Koha::SearchEngine::Elasticsearch::Indexer::update_index() first arg record ids is now mandatory
- [[23986]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23986) Batch Record Deletion does not remove records from Elasticsearch search index

### System Administration

- [[23398]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23398) Exporting/Reimporting frameworks in XML format will give incomplete results
- [[24026]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24026) Wrong parameters in Koha/Templates/Plugin/CirculationRules.pm and smart-rules.tt

### Test Suite

- [[21985]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21985) Test t/db_dependent/Circulation.t fails if SearchEngine is set to elasticsearch
- [[23234]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23234) Circulation.t failing when comparing dates that seem identical

### Tools

- [[17359]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17359) Patron import results use wrong encoding
- [[18710]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18710) Wrong subfield modified in batch item modification
- [[23963]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23963) Visible reduction in image quality


## Other bugs fixed

### Acquisitions

- [[23101]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23101) Contracts permissions for staff patron

### Architecture, internals, and plumbing

- [[23627]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23627) Koha::Biblio->get_coins too noisy if no 245$b

### Circulation

- [[23679]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23679) Software error when trying to transfer an unknown barcode

### ILL

- [[22280]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22280) The ILL module assumes every status needs a next/previous status

### OPAC

- [[22602]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22602) OverDrive circulation integration is broken when user is referred to Koha from another site
- [[22804]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22804) OPAC Overdrive JavaScript contains untranslatable strings
- [[23625]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23625) ArticleRequestsMandatoryFields* only affects field labels, does not make inputs required

  **Sponsored by** *California College of the Arts*
- [[23683]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23683) Course reserves public notes on specific items should allow for HTML

### Patrons

- [[23589]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23589) Discharge notice does not show non-latin characters
- [[23688]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23688) System preference uppercasesurnames broken by typo

### REST API

- [[23607]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23607) Make /patrons/:patron_id/account privileged user only

### Reports

- [[23624]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23624) Count rows in report without (potentially) consuming all memory

  **Sponsored by** *Fenway Libraries Online* and *Higher Education Libraries of Massachusetts*

### Staff Client

- [[23651]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23651) RestrictedPage system preferences should include the address of the page in the description
- [[23680]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23680) Can't open 'Edit items' or 'Add item' links in new tab - tab is closed immediately

  **Sponsored by** *Gothenburg University Library*

  >This fixes a problem where the pop-up window or tab immediately closes when attempting to edit or add a bibliographic item.
- [[23689]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23689) Terminology: Branches limitations should be libraries limitations - Authorised Values
- [[24060]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24060) [19.05] Can't load patron clubs tab on patron details page

### Templates

- [[23605]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23605) Terminology: Branches limitations should be libraries limitations
## New sysprefs

- RoundFinesAtPayment

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

- Arabic (99.9%)
- Armenian (99.9%)
- Basque (59.9%)
- Chinese (China) (60.5%)
- Chinese (Taiwan) (99.9%)
- Czech (92.8%)
- Danish (52.7%)
- English (New Zealand) (83.7%)
- English (USA)
- Finnish (79.9%)
- French (99.3%)
- French (Canada) (100%)
- German (100%)
- German (Switzerland) (86.7%)
- Greek (74.3%)
- Hindi (100%)
- Italian (90.9%)
- Norwegian Bokmål (89.5%)
- Occitan (post 1500) (56.6%)
- Polish (83.6%)
- Portuguese (100%)
- Portuguese (Brazil) (94.9%)
- Slovak (85%)
- Spanish (100%)
- Swedish (89%)
- Turkish (98.4%)
- Ukrainian (72.9%)
- Vietnamese (51.4%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 19.05.05 is


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
  - Caroline Cyr La Rose
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
new features in Koha 19.05.05:

- [BULAC](http://www.bulac.fr/)
- California College of the Arts
- Fenway Libraries Online
- Gothenburg University Library
- Higher Education Libraries of Massachusetts

We thank the following individuals who contributed patches to Koha 19.05.05.

- Tomás Cohen Arazi (7)
- Philippe Blouin (1)
- Nick Clemens (16)
- Christophe Croullebois (1)
- Jonathan Druart (31)
- Magnus Enger (2)
- Katrin Fischer (6)
- Lucas Gass (1)
- David Gustafsson (1)
- Kyle Hall (8)
- Paul Hoffman (1)
- Andrew Isherwood (2)
- Owen Leonard (2)
- Dobrica Pavlinušić (2)
- Eric Phetteplace (1)
- Martin Renvoize (18)
- Marcel de Rooy (4)
- Caroline Cyr La Rose (1)
- Fridolin Somers (17)
- Lari Taskula (1)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 19.05.05

- ACPL (2)
- BibLibre (18)
- BSZ BW (6)
- ByWater-Solutions (25)
- flo.org (1)
- Göteborgs Universitet (1)
- hypernova.fi (1)
- Independant Individuals (1)
- Koha Community Developers (31)
- Libriotech (2)
- PTFS-Europe (20)
- Rijks Museum (4)
- rot13.org (2)
- Solutions inLibro inc (2)
- Theke Solutions (7)

We also especially thank the following individuals who tested patches
for Koha.

- Tomás Cohen Arazi (19)
- Nick Clemens (26)
- Holly Cooper (1)
- Sarah Cornell (1)
- Jonathan Druart (7)
- Bouzid Fergani (3)
- Katrin Fischer (15)
- Andrew Fuerste-Henry (3)
- Kyle Hall (22)
- Andrew Isherwood (1)
- Owen Leonard (6)
- Hayley Mapley (1)
- Jesse Maseto (4)
- Julian Maurice (2)
- Josef Moravec (5)
- David Nind (1)
- Séverine Queune (5)
- Elizabeth Quinn (1)
- Liz Rea (6)
- Martin Renvoize (129)
- Marcel de Rooy (30)
- Lisette Scheer (2)
- Maryse Simard (1)
- Fridolin Somers (97)
- Mike Somers (1)
- Myka Kennedy Stephens (1)
- Theodoros Theodoropoulos (2)
- Mark Tompsett (1)
- Bin Wen (3)



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

Autogenerated release notes updated last on 28 Nov 2019 19:00:35.
