27 Mar 2024

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 23.05.10 can be downloaded from:

- [Download](http://download.koha-community.org/koha-23.05.10.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 23.05.10 is a bugfix/maintenance release.

It includes 5 security fiexes, 2 enhancements, and 52 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).

#### Security bugs

- [24879](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24879) Add missing authentication checks
- [35960](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35960) XSS in staff login form
- [36244](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36244) Template toolkit syntax not escaped in letter templates
- [36322](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36322) Can run docs/**/*.pl from the UI
- [36323](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36323) koha_perl_deps.pl can be run from the UI

## Bugfixes

### About

#### Other bugs fixed

- [36134](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36134) Elasticsearch authentication using userinfo parameter crashes about.pl

### Accessibility

#### Other bugs fixed

- [36140](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36140) Wrong for attribute on Invoice number: label in invoice.tt

### Acquisitions

#### Critical bugs fixed

- [35892](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35892) Fallback to GetMarcPrice in addorderiso2907 no longer works
- [36047](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36047) Apostrophe in suggestion status reason blocks order receipt
- [36233](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36233) Cannot search invoices if too many vendors

#### Other bugs fixed

- [35398](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35398) EDI: Fix support for LRP (Library Rotation Plan) for Koha with Stock Rotation enabled
- [35911](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35911) Archived suggestions show in patron's account
  >This fixes an unintended change introduced in Koha 22.11. Archived suggestions are now no longer shown on the patron's account page in the staff interface.
- [35916](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35916) Purchase suggestions bibliographic filter should be a "contains" search

### Architecture, internals, and plumbing

#### Critical bugs fixed

- [35819](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35819) "No job found" error for BatchUpdateBiblioHoldsQueue (race condition)

#### Other bugs fixed

- [33898](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33898) background_jobs_worker.pl may leave defunct children processes for extended periods of time
- [34913](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34913) Upgrade DataTables from 1.10.18 to 1.13.6
- [36000](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36000) Fix CGI::param called in list context from catalogue/search.pl
- [36056](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36056) Clarify subpermissions check behavior in C4::Auth
- [36088](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36088) Remove useless code form opac-account-pay.pl
- [36170](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36170) Wrong warning in memberentry
- [36176](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36176) [23.11 and below] We need tests to check for 'cud-' operations in stable branches (pre-24.05)
- [36212](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36212) transferbook should not look for items without barcode

### Authentication

#### Critical bugs fixed

- [34755](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34755) Error authenticating to external OpenID Connect (OIDC) identity provider : wrong_csrf_token

#### Other bugs fixed

- [36098](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36098) Create Koha::Session module

### Cataloging

#### Other bugs fixed

- [29522](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29522) Bib record not correctly updated when merging identical authorities with LinkerModule set to First Match
- [32029](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32029) Automatic item modifications by age missing biblio table
- [34234](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34234) Item groups dropdown in detail page modal does not respect display order
- [35554](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35554) Authority search popup is only 700px
- [35963](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35963) Problem using some filters in the bundled items table

### Circulation

#### Other bugs fixed

- [35983](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35983) Library specific refund lost item replacement fee cannot be 'refund_unpaid'

### Command-line Utilities

#### Other bugs fixed

- [36009](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36009) Document koha-worker --queue elastic_index

### Hold requests

#### Other bugs fixed

- [36103](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36103) Remove the "Cancel hold" link for item level holds

### OPAC

#### Critical bugs fixed

- [35941](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35941) OPAC user can guess clubs of other users

#### Other bugs fixed

- [35538](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35538) List of libraries on OPAC self registration form should sort by branchname rather than branchcode
- [35952](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35952) Removed unnecessary  line in opac-blocked.pl
- [36004](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36004) Typo in "Your concern was successfully submitted" OPAC text
- [36032](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36032) The "Next" pagination button has a double instead of a single angle

  **Sponsored by** *Karlsruhe Institute of Technology (KIT)*
- [36359](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36359) Broken OPAC mainpage layouts in 23.05.09
  >23.05.09

### Patrons

#### Critical bugs fixed

- [35796](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35796) Patron password expiration date lost when patron edited by superlibrarian

#### Other bugs fixed

- [36076](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36076) paycollect.tt is missing permission checks for manual credit and invoice
- [36292](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36292) 'See all charges' hyperlink to view guarantee fees is not linked correctly
- [36298](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36298) In patrons search road type authorized value code displayed in patron address

### REST API

#### Other bugs fixed

- [36066](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36066) REST API: We should only allow deleting cancelled order lines

### Reports

#### Critical bugs fixed

- [31988](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31988) manager.pl is only user for "Catalog by item type" report

#### Other bugs fixed

- [35949](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35949) Useless code pointing to branchreserves.pl in request.tt

### Staff interface

#### Critical bugs fixed

- [35935](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35935) Wrong branch picked after an incorrect login

#### Other bugs fixed

- [35800](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35800) edit_any_item permission required to see patron name in detail page
- [36005](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36005) Typo in "Your concern was successfully submitted" in staff interface
- [36099](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36099) JS error in console on non-existent biblio record

### Templates

#### Critical bugs fixed

- [36332](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36332) JS error on moremember

#### Other bugs fixed

- [35351](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35351) Adjust basket details template to avoid showing empty page-section
  >This removes the empty white section in acquisitions for a basket with no orders.
- [35934](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35934) Items in transit show as both in-transit and Available on holdings list
- [36224](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36224) It looks like spsuggest functionality was removed years ago, but the templates still refer to it

### Test Suite

#### Critical bugs fixed

- [35922](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35922) t/db_dependent/www/batch.t is failing

#### Other bugs fixed

- [32671](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32671) basic_workflow.t is failing on slow servers
- [36010](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36010) Items/AutomaticItemModificationByAge.t is failing
- [36277](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36277) t/db_dependent/api/v1/transfer_limits.t  is failing

## Enhancements 

### Architecture, internals, and plumbing

#### Enhancements

- [35955](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35955) New CSRF token generated everytime we need one

### Cataloging

#### Enhancements

- [36156](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36156) Duplicate selected value when a field or subfield is cloned

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 23.05.10 is

- Release Manager: Katrin Fischer

- Release Manager assistants:
  - Tomás Cohen Arazi
  - Martin Renvoize
  - Jonathan Druart

- QA Manager: Marcel de Rooy

- QA Team:
  - Marcel de Rooy
  - Julian Maurice
  - Lucas Gass
  - Victor Grousset
  - Kyle M Hall
  - Nick Clemens
  - Martin Renvoize
  - Tomás Cohen Arazi
  - Aleisha Amohia
  - Emily Lamancusa
  - David Cook
  - Jonathan Druart
  - Pedor Amorim

- Topic Experts:
  - UI Design -- Owen Leonard
  - Zebra -- Fridolin Somers
  - REST API -- Tomás Cohen Arazi
  - ERM -- Matt Blenkinsop
  - ILL -- Pedro Amorim
  - SIP2 -- Matthias Meusburger
  - CAS -- Matthias Meusburger

- Bug Wranglers:
  - Aleisha Amohia
  - Indranil Das Gupta

- Packaging Managers:
  - Mason James
  - Indranil Das Gupta
  - Tomás Cohen Arazi

- Documentation Manager: Aude Charillon

- Documentation Team:
  - Caroline Cyr La Rose
  - Kelly McElligott
  - Philip Orr
  - Marie-Luce Laflamme
  - Lucy Vaux-Harvey

- Translation Manager: Jonathan Druart


- Wiki curators: 
  - Thomas Dukleth
  - Katrin Fischer

- Release Maintainers:
  - 23.11 -- Fridolin Somers
  - 23.05 -- Lucas Gass
  - 22.11 -- Frédéric Demians
  - 22.05 -- Danyon Sewell

- Release Maintainer assistants:
  - 22.05 -- Wainui Witika-Park

## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 23.05.10
<div style="column-count: 2;">

- Karlsruhe Institute of Technology (KIT)
</div>

We thank the following individuals who contributed patches to Koha 23.05.10
<div style="column-count: 2;">

- Pedro Amorim (1)
- Tomás Cohen Arazi (4)
- Nick Clemens (6)
- David Cook (6)
- Jonathan Druart (30)
- Magnus Enger (1)
- Laura Escamilla (3)
- Lucas Gass (15)
- Victor Grousset (1)
- Thibaud Guillot (1)
- Kyle M Hall (6)
- Andreas Jonsson (2)
- Emily Lamancusa (1)
- Owen Leonard (5)
- Julian Maurice (5)
- Martin Renvoize (4)
- Marcel de Rooy (8)
- Fridolin Somers (7)
- Raphael Straub (1)
- Lari Taskula (1)
- Shi Yao Wang (2)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 23.05.10
<div style="column-count: 2;">

- Athens County Public Libraries (5)
- BibLibre (13)
- ByWater-Solutions (30)
- Hypernova Oy (1)
- kit.edu (1)
- Koha Community Developers (31)
- Kreablo AB (2)
- Libriotech (1)
- montgomerycountymd.gov (1)
- Prosentient Systems (6)
- PTFS-Europe (5)
- Rijksmuseum (8)
- Solutions inLibro inc (2)
- Theke Solutions (4)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Pedro Amorim (5)
- Tomás Cohen Arazi (8)
- Nick Clemens (1)
- David Cook (1)
- Jonathan Druart (16)
- Magnus Enger (1)
- Katrin Fischer (64)
- Andrew Fuerste-Henry (2)
- matthias le gac (1)
- Lucas Gass (96)
- Victor Grousset (14)
- Sophie Halden (1)
- Kyle M Hall (7)
- Andrew Fuerste Henry (1)
- Olivier Hubert (1)
- Barbara Johnson (1)
- Emily Lamancusa (4)
- Brendan Lawlor (1)
- Owen Leonard (5)
- Julian Maurice (6)
- David Nind (15)
- Philip Orr (1)
- Barbara Petritsch (1)
- Martin Renvoize (29)
- Marcel de Rooy (18)
- Caroline Cyr La Rose (1)
- Lisette Scheer (1)
- Fridolin Somers (81)
- Anneli Österman (1)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 23.05.x-security.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 27 Mar 2024 16:31:27.
