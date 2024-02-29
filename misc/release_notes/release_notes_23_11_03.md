# RELEASE NOTES FOR KOHA 23.11.03
29 Feb 2024

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 23.11.03 can be downloaded from:

- [Download](http://download.koha-community.org/koha-23.11.03.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 23.11.03 is a bugfix/maintenance release with security fixes.

It includes 7 security bugfixes, 80 other bugfixes and 14 enhancement.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [29510](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29510) objects.find should call search_limited if present
- [34623](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34623) Update jQuery-validate plugin to 1.20.0
- [35890](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35890) AutoLocation system preference + setting the library IP field - can still login and unexpected results
- [35918](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35918) Incorrect library used when AutoLocation configured using the same IP
- [35941](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35941) OPAC user can guess clubs of other users
- [35942](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35942) OPAC user can enroll several times to the same club
- [36072](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36072) Can request articles even if ArticleRequests is off

## Bugfixes

### Accessibility

#### Other bugs fixed

- [34647](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34647) name attribute is obsolete in anchor tag
- [35894](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35894) Duplicate link in booksellers.tt

### Acquisitions

#### Critical bugs fixed

- [35912](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35912) Item prices not populating order form when adding to a basket from a staged file

#### Other bugs fixed

- [33457](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33457) Improve display of fund users when the patron has no firstname
- [34853](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34853) Move EDI link to new line in invoice column of acquisition details display
- [35514](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35514) New order line form: Total prices not updated when adding multiple items

### Architecture, internals, and plumbing

#### Critical bugs fixed

- [35843](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35843) No such thing as Koha::Exceptions::Exception

#### Other bugs fixed

- [34913](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34913) Upgrade DataTables from 1.10.18 to 1.13.6
- [35277](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35277) Pseudonymization should be done in a background job
- [35701](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35701) Cannot use i18n.inc from memberentrygen
- [35833](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35833) Fix few noisy warnings from C4/Koha and search
- [35835](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35835) Fix shebang for cataloguing/ysearch.pl
- [36092](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36092) sessionID not passed to the template on auth.tt

### Authentication

#### Critical bugs fixed

- [36034](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36034) cas_ticket is set to serialized patron object in session

#### Other bugs fixed

- [29930](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29930) 'cardnumber' overwritten with userid when not mapped (LDAP auth)

### Cataloging

#### Other bugs fixed

- [35695](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35695) Remove useless item group code from cataloging_additem.js
- [35774](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35774) add_item_to_item_group additem.pl should be $item->itemnumber instead of biblioitemnumber

### Circulation

#### Critical bugs fixed

- [35518](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35518) Call to C4::Context->userenv happens before it's gets populated breaks code logic in circulation

#### Other bugs fixed

- [30230](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30230) Search for patrons in checkout should not require edit_borrowers permission
- [35360](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35360) Inconsistent use/look of 'Cancel hold(s)' button on circ/waitingreserves.pl
- [35483](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35483) Restore item level to record level hold switch in hold table
- [35535](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35535) Cancel hold -button does not work in pop-up (Hold found, item is already waiting)

### Command-line Utilities

#### Other bugs fixed

- [30627](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30627) koha-run-backups delete the backup files after finished its job without caring days option
- [35373](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35373) Remove comment about bug 8000 in gather_print_notices.pl
- [35596](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35596) Error in writeoff_debts documentation

### Documentation

#### Other bugs fixed

- [35354](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35354) Update emailLibrarianWhenHoldisPlaced system preference description

### Installation and upgrade (command-line installer)

#### Other bugs fixed

- [34979](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34979) System preferences missing from sysprefs.sql

### OPAC

#### Other bugs fixed

- [35578](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35578) Validate "Where" in OPAC Authority search
- [35795](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35795) Missing closing tag in OPAC course details template
- [35841](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35841) Update text of 'Cancel' hold button on OPAC

### Patrons

#### Critical bugs fixed

- [34479](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34479) Clear saved patron search selections after certain actions
  >This fixes issues with patron search, and remembering the patrons selected after performing an action (such as Add to patron list, Merge selected patrons, Batch patron modification). Remembering selected patrons was introduced in Koha 22.11, bug 29971.
  >
  >Previously, the patrons selected after running an action were kept, and this either caused confusion, or could result in data loss if other actions were taken with new searches.
  >
  >Now, after performing a search and taking one of the actions available, you are now prompted with "Keep patrons selected for a new operation". When you return to the patron search:
  >- If the patrons are kept: those patrons should still be selected
  >- If the patrons aren't kept: the patron selection history is empty and no patrons are selected

#### Other bugs fixed

- [35445](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35445) OPAC registration verification triggered by email URL scanners
- [35743](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35743) The "category" filter is not selected in the column filter dropdown

### Plugin architecture

#### Critical bugs fixed

- [35930](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35930) ILL module broken if plugins disabled

### REST API

#### Other bugs fixed

- [35368](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35368) "Add a checkout" shows up twice in online documentation

### Reports

#### Other bugs fixed

- [35936](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35936) Cannot save existing report with incorrect AV category

### SIP2

#### Other bugs fixed

- [35461](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35461) Renew All 66 SIP server response messages produce HASH content in replies

### Staff interface

#### Other bugs fixed

- [33464](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33464) Report "Orders by fund" is missing page-section class on results
- [34298](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34298) Duplicate existing orders is missing page section on order list
- [34872](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34872) Cart pop-up is missing page section
- [35300](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35300) Add page-section to table of invoice files
- [35396](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35396) Replace Datatables' column filters throttling with input timeout
- [35742](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35742) Cannot remove new user added to fund
- [35745](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35745) Setting suggester on the suggestion edit form does not show library and category
- [35753](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35753) Checkbox() function in additional-contents not necessary
- [35800](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35800) edit_any_item permission required to see patron name in detail page
- [35865](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35865) Missing hint about permissions when adding managers to a basket

### System Administration

#### Other bugs fixed

- [35530](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35530) Can't tell if UserCSS and UserJS in libraries are for staff interface or OPAC
- [35831](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35831) Move UpdateItemLocationOnCheckout to Checkout policy section

### Templates

#### Other bugs fixed

- [35323](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35323) Terminology: Add additional elements to the "More Searches" bar...
- [35349](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35349) Reindent label item search template
- [35350](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35350) Update label creator pop-up windows with consistent footer markup
- [35406](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35406) Typo in holds queue viewer template
- [35407](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35407) Terminology: Show fewer collection codes
- [35820](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35820) Table on Hold ratios page at circ/reserveratios.pl has wrong id
- [35893](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35893) Missing closing </li> in opac.pref
- [35951](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35951) We don't need category-out-of-age-limit.inc

### Test Suite

#### Critical bugs fixed

- [35922](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35922) t/db_dependent/www/batch.t is failing

#### Other bugs fixed

- [35904](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35904) C4::Auth::checkauth cannot be tested easily
- [35940](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35940) Cypress tests for the Preservation module are failing
- [35962](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35962) t/db_dependent/Koha/BackgroundJob.t failing on D10

### Tools

#### Other bugs fixed

- [35817](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35817) Wrong hint on patron's category when batch update patron

## Enhancements 

### Architecture, internals, and plumbing

#### Enhancements

- [35490](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35490) Remove GetMarcItem from C4::Biblio

### Command-line Utilities

#### Enhancements

- [35479](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35479) Nightly cronjob for plugins should log the plugins that are being run

### Database

#### Enhancements

- [26831](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26831) Enable librarians to control when unaccepted private list share invites are removed by the cleanup_database.pl cronjob
  >The new PurgeListShareInvitesOlderThan system preference enables librarians to control when unaccepted private list share invites are removed from the database.
  >
  >Unaccepted private list share invites will now be removed based on the following prioritised options:
  >
  >- Priority 1. Use DAYS value when the cleanup_database.pl cronjob is run with a --list-invites DAYS parameter specified.
  >
  >- Priority 2. Use the PurgeListShareInvitesOlderThan system preference value.
  >
  >- Priority 3. Use a default of 14 days, if the cleanup_database.pl cronjob is run with a --list-invites parameter missing the DAYS value, AND the PurgeListShareInvitesOlderThan system preference is empty.
  >
  >- Priority 4. Don't remove any unaccepted private list share invites if the cleanup_database.pl cronjob is run without the --list-invites parameter and the PurgeListShareInvitesOlderThan syspref is empty.

  **Sponsored by** *Catalyst*

### ILL

#### Enhancements

- [34282](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34282) ILL batches - availability checking has issues

  **Sponsored by** *UKHSA (UK Health Security Agency)*

### Notices

#### Enhancements

- [18397](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18397) Add recipient/sender information to notices tab in staff interface
  >Display `from`, `to` and `cc` addresses under 'Delivery details' in the notices table once the notice has been sent.
- [34854](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34854) Add ability to skip Talking Tech Itiva notifications for a patron if a given field matches a given value

### OPAC

#### Enhancements

- [35663](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35663) Wording on OPAC privacy page is misleading

### Patrons

#### Enhancements

- [35356](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35356) SMS number field shows on moremember.pl even when null

### REST API

#### Enhancements

- [35744](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35744) Implement +strings for GET /patrons/:patron_id

### Staff interface

#### Enhancements

- [35389](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35389) Hide 'Transfers to send' on circulation home page when stock rotation is disabled
  >Currently, Transfers to send (on circulation) is only relevant when you enable StockRotation. To lower confusion, we hide the option if you did not enable that pref.

### Templates

#### Enhancements

- [34862](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34862) blocking_errors.inc not included everywhere
- [35260](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35260) Review batch checkout page
- [35379](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35379) 'searchfield' parameter name misleading when translating
- [35419](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35419) Update page title for bookings

## New system preferences

- AutoApprovePatronProfileSettings
- EmailSMSSendDriverFromAddress
- HidePersonalPatronDetailOnCirculation
- ILLCheckAvailability
- IntranetReadingHistoryHolds
- ManaToken
- OAI-PMH:AutoUpdateSetsEmbedItemData
- OPACDetailQRCode
- OPACPopupAuthorsSearch
- OPACPrivacy
- OPACShibOnly
- OPACSuggestionMandatoryFields
- OverDriveAuthName
- OverDriveWebsiteID
- PurgeListShareInvitesOlderThan
- RecordStaffUserOnCheckout
- ReplytoDefault
- staffShibOnly

## Deleted system preferences

- IllCheckAvailability
- OAI-PMH:AutoUpdateSetEmbedItemData
- OpacPrivacy
- ReplyToDefault

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Chinese (Traditional)](https://koha-community.org/manual/23.11//html/) (61%)
- [English](https://koha-community.org/manual/23.11//html/) (100%)
- [English (USA)](https://koha-community.org/manual/23.11/en/html/)
- [French](https://koha-community.org/manual/23.11/fr/html/) (40%)
- [German](https://koha-community.org/manual/23.11/de/html/) (40%)
- [Hindi](https://koha-community.org/manual/23.11/hi/html/) (75%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (69%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Traditional) (91%)
- Czech (65%)
- Dutch (76%)
- English (100%)
- English (New Zealand) (64%)
- English (USA)
- Finnish (99%)
- French (99%)
- French (Canada) (96%)
- German (99%)
- German (Switzerland) (52%)
- Greek (52%)
- Hindi (100%)
- Italian (84%)
- Norwegian Bokmål (76%)
- Persian (fa_ARAB) (91%)
- Polish (93%)
- Portuguese (Brazil) (92%)
- Portuguese (Portugal) (88%)
- Russian (89%)
- Slovak (62%)
- Spanish (99%)
- Swedish (86%)
- Telugu (71%)
- Turkish (80%)
- Ukrainian (74%)
- hyw_ARMN (generated) (hyw_ARMN) (65%)
</div>

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 23.11.03 is


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
new features in Koha 23.11.03
<div style="column-count: 2;">

- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)
- UKHSA (UK Health Security Agency)
</div>

We thank the following individuals who contributed patches to Koha 23.11.03
<div style="column-count: 2;">

- Pedro Amorim (2)
- Tomás Cohen Arazi (9)
- Matt Blenkinsop (6)
- Alex Buckley (3)
- Nick Clemens (7)
- David Cook (3)
- Jonathan Druart (28)
- Katrin Fischer (20)
- Lucas Gass (8)
- Victor Grousset (1)
- Thibaud Guillot (4)
- Kyle M Hall (9)
- Janik Hilser (1)
- Andreas Jonsson (3)
- Owen Leonard (15)
- lmstrand (1)
- David Nind (1)
- Martin Renvoize (9)
- Marcel de Rooy (9)
- Caroline Cyr La Rose (2)
- Fridolin Somers (2)
- Lari Taskula (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 23.11.03
<div style="column-count: 2;">

- Athens County Public Libraries (15)
- BibLibre (6)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (20)
- ByWater-Solutions (24)
- Catalyst (3)
- David Nind (1)
- Hypernova Oy (1)
- Independant Individuals (2)
- Koha Community Developers (29)
- Kreablo AB (3)
- Prosentient Systems (3)
- PTFS-Europe (17)
- Rijksmuseum (9)
- Solutions inLibro inc (2)
- Theke Solutions (9)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Michael Adamyk (1)
- Aleisha Amohia (1)
- Pedro Amorim (3)
- Tomás Cohen Arazi (11)
- Aude (1)
- Matt Blenkinsop (6)
- David Cook (2)
- Chris Cormack (1)
- Jonathan Druart (13)
- Michał Dudzik (1)
- Sharon Dugdale (2)
- Magnus Enger (3)
- Katrin Fischer (112)
- Andrew Fuerste-Henry (1)
- Lucas Gass (6)
- Victor Grousset (13)
- Kyle M Hall (18)
- Andrew Fuerste Henry (1)
- Barbara Johnson (3)
- Emily Lamancusa (2)
- Brendan Lawlor (1)
- Owen Leonard (14)
- lmstrand (1)
- Julian Maurice (1)
- David Nind (24)
- Philip Orr (1)
- Hans Pålsson (1)
- Martin Renvoize (54)
- Phil Ringnalda (2)
- Marcel de Rooy (22)
- Caroline Cyr La Rose (1)
- Fridolin Somers (142)
- Edith Speller (1)
- Michelle Spinney (1)
- Emmi Takkinen (1)
- Loïc Vassaux--Artur (1)
- Alexander Wagner (3)
- Anneli Österman (3)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 23.11.x-security.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 29 Feb 2024 10:23:03.
