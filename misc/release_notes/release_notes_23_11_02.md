# RELEASE NOTES FOR KOHA 23.11.02
29 Jan 2024

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 23.11.02 can be downloaded from:

- [Download](http://download.koha-community.org/koha-23.11.02.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 23.11.02 is a bugfix/maintenance release with security fixes.

It includes 2 security bugfixes, 87 other bugfixes and 1 enhancement.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [34893](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34893) ILS-DI can return the wrong patron for AuthenticatePatron
- [34913](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34913) Upgrade DataTables from 1.10.18 to 1.13.6

## Bugfixes

### About

#### Critical bugs fixed

- [35504](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35504) Release team 24.05

#### Other bugs fixed

- [35584](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35584) Missing licenses in about page

### Acquisitions

#### Critical bugs fixed

- [35634](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35634) Permissions mismatch for vendor issues

### Architecture, internals, and plumbing

#### Critical bugs fixed

- [35687](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35687) Upgrade to 23.06.00.013 may fail

#### Other bugs fixed

- [34999](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34999) REST API: Public routes should respect OPACMaintenance
  >This report ensures that if OPACMaintenance is set, public API calls are blocked with an UnderMaintenance exception.
- [35309](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35309) Remove DT's fnSetFilteringDelay
- [35405](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35405) MarcAuthorities: Use of uninitialized value $tag in hash element at MARC/Record.pm line 202.
- [35491](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35491) Reverting waiting status for holds is not logged
- [35629](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35629) Redundant code in includes/patron-search.inc
- [35702](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35702) Reduce DB calls when performing authorities merge

### Cataloging

#### Other bugs fixed

- [33639](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33639) Adding item to item group from 'Add item' screen doesn't work
  >This fixes adding a new item to an item group (when using the item groups feature - EnableItemGroups system preference). before this fix, even if you selected an item group, it was not added to it.
- [35651](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35651) Toggle for advanced editor should not show to staff without advanced_editor permissions
  >This fixes the display of the button to access the advanced editor. It now only displays when the staff patron has the correct permissions ("Use the advanced cataloging editor (requires edit_catalogue)").

### Circulation

#### Critical bugs fixed

- [33847](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33847) Database update replaces undefined rules with defaults rather than the value that would be used
- [35341](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35341) Circulation rule dates are being overwritten
- [35468](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35468) Bookings permission mismatch

#### Other bugs fixed

- [18139](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18139) 'Too many checked out' can confuse librarians
- [35216](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35216) Use return variable names from CanBookBeIssued in circulation.pl for consistency
- [35310](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35310) Current renewals 'view' link doesnt work if renewals correspond to an item no longer checked out
  >This fixes the current renewals information (shown under the statuses section) on the item page for records in the staff interface so that:
  >1. The current renewals row is only now shown if there are current renewals for the item (previously it was shown for all items, even if they had no renewals).
  >2. It only shows the number of current renewals for the current check out (previously the number shown would include all renewals, including for previous check-outs).
- [35587](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35587) Items lose their lost status when check-in triggers a transfer even though BlockReturnOfLostItems is enabled

  **Sponsored by** *Pymble Ladies' College*
- [35600](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35600) Prevent checkouts table to flicker

### ERM

#### Other bugs fixed

- [35757](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35757) Sushi service and counter registry tests are failing

### Hold requests

#### Critical bugs fixed

- [35322](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35322) AllowItemsOnHoldCheckoutSCO and AllowItemsOnHoldCheckoutSIP do not work
- [35489](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35489) Holds on items with no barcode are missing an input for itemnumber

### I18N/L10N

#### Other bugs fixed

- [34900](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34900) The translation of the string "The " should depend on context
- [35475](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35475) Untranslatable strings in booking modal and JS
- [35476](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35476) Submit button for adding new processings is not translatable
  >This fixes some submit buttons in the ERM and Preservation modules so that are now translatable.
- [35567](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35567) Host-item in "Show analytics" link can be translated

### Installation and upgrade (command-line installer)

#### Other bugs fixed

- [35698](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35698) Wrong bug number in db_revs/220600084.pl

### Installation and upgrade (web-based installer)

#### Other bugs fixed

- [35686](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35686) Case missing from installer step 3 template title
  >This fixes a web browser page title for the web installer - from " > Web installer > Koha" to "Updating database structure  > Web installer > Koha".

### Lists

#### Other bugs fixed

- [35547](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35547) When using "Add to a list" button with more than 10 lists, "staff only" does not show up

### Notices

#### Other bugs fixed

- [30287](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30287) Notices using HTML render differently in notices.pl
  >This fixes notice previews for patrons in the staff interface (Patrons > [Patron account] > Notices), where HTML is used in the email notices. For example, previously if <br>s were used then the preview would match the email sent, however, using <p>s would add extra lines in the preview.

### OPAC

#### Other bugs fixed

- [35488](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35488) Placing a hold on the OPAC takes the user to their account page, but does not activate the holds tab
- [35492](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35492) Suspending/unsuspending a hold on the OPAC takes the user to their account page, but does not activate the holds tab
- [35495](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35495) Cancelling a hold on the OPAC takes the user to their account page, but does not activate the holds tab
- [35496](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35496) Placing an article request on the OPAC takes the user to their account page, but does not activate the article request tab
- [35676](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35676) OPAC search results - link for "Check for suggestions" generates a blank page

### Packaging

#### Other bugs fixed

- [25691](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25691) Debian packages point to /usr/share/doc/koha/README.Debian which does not exist
- [35713](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35713) Remove debian/docs/LEEME.Debian

### Patrons

#### Other bugs fixed

- [25835](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25835) Include overdue report (under circulation module) as a staff permission
- [35493](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35493) Housebound roles show as a collapsed field option when checked in CollapseFieldsPatronAddForm, even if housebound is off
- [35756](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35756) Wrong use of encodeURIComponent in patron-search.inc

### Plugin architecture

#### Other bugs fixed

- [35070](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35070) Koha plugins implementing "background_jobs" hook can't provide view template

### Preservation

#### Critical bugs fixed

- [35759](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35759) Preservation module home yields a blank page

#### Other bugs fixed

- [35463](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35463) Link preservation module help to the manual
  >This patch links the various pages of the preservation module to each specific section of the preservation module chapter in the manual.
- [35477](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35477) Adding non-existent items to the waiting list should display a warning

### REST API

#### Critical bugs fixed

- [35204](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35204) REST API: POST endpoint /auth/password/validation dies on patron with expired password
- [35658](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35658) Typo in /patrons/:patron_id/holds

#### Other bugs fixed

- [32551](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32551) API requests don't carry language related information

### Reports

#### Other bugs fixed

- [35498](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35498) SQL auto-complete should not prevent use of tab for spacing

### Searching - Elasticsearch

#### Other bugs fixed

- [35086](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35086) Koha::SearchEngine::Elasticsearch::Indexer->update_index needs to commit in batches
  >This enables breaking large Elasticsearch or Open Search indexing requests into smaller chunks (for example, when updating many records using batch modifications).
  >
  >This means that instead of sending a single background request for indexing, which could exceed the limits of the search server or take up too many resources, it limits index update requests to a more manageable size.
  >
  >The default chunk size is 5,000. To configure a different chunk size, add a <chunk_size> directive to the elasticsearch section of the instance's koha-conf.xml (for example: <chunk_size>2000</chunk_size>).
  >
  >NOTE: This doesn't change the command line indexing script, as this already allows passing a commit size defining how many records to send.
- [35265](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35265) Remove drag and drop in Elasticsearch mappings
  >This removes the ability to drag and drop the order of the bibliographic and authorities search fields (Administration > Catalog > Search engine configuration (Elasticsearch)). This was removed as the feature has no effect on the search results when using Elasticsearch or OpenSearch as the search engine.
- [35618](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35618) catalogue/showelastic.pl uses deprecated/removed parameter "type"
  >This fixes the display when clicking on "Show" for the "Elasticsearch record" entry for a record in the staff interface. Before this fix, a page not found (404) was displayed when viewing a record using Elasticsearch 7 or 8, or Open Search 1 ord 2. (Note that Elasticsearch 6 is no longer supported.)

### Searching - Zebra

#### Other bugs fixed

- [35455](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35455) ICU does not strip = when indexing/searching
  >This change fixes an issue with Zebra ICU searching where titles with colons aren't properly searchable, especially when used with Analytics.
  >
  >A full re-index of Zebra is needed for this change to take effect.

### Serials

#### Other bugs fixed

- [28012](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28012) Error on saving new numbering pattern
  >This fixes the serials new numbering pattern input form so that the name and numbering formula fields are marked as required. Before this, there was no indication that these fields were required and error trace messages were displayed if these were not completed - saving a new pattern or editing an existing pattern would also silently fail.
  >
  >NOTE: Making the description field optional will be fixed in bug 31297. Until this is done, a value needs to be entered into this field - even though it doesn't indicate that it is required.
- [31297](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31297) Cannot add new subscription patterns from edit subscription page

### Staff interface

#### Other bugs fixed

- [32477](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32477) Hiding batch item modification columns isn't remembered correctly
  >This fixes showing and hiding columns when batch item editing (Cataloging > Batch editing > Batch item modification). When using the show/hide column options, the correct columns and updating the show/hide selections were not correctly displayed, including when the page was refreshed (for example: selecting the Collection column hid the holds column instead, and the shown/hide option for Collection was not selected).

  **Sponsored by** *Koha-Suomi Oy*
- [35574](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35574) Bookings page should require only manage_bookings permissions
- [35592](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35592) Missing closing div tag in bookings alert in circulation.tt
- [35619](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35619) Change password form in patron account has misaligned validation errors
- [35772](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35772) Double escaping of patron fields in bookings modal

### System Administration

#### Other bugs fixed

- [31694](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31694) MARC overlay rules presets don't change anything if presets are translated
- [34644](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34644) Add clarifying text to sysprefs to indicate that MarcFieldsToOrder is a fallback to MarcItemFieldsToOrder
  >This updates the descriptions for system preferences MarcFieldsToOrder and MarcItemFieldsToOrder.
- [35293](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35293) Regression: Bug 33390 (QA follow-up) patch overwrote the template changes to bug 25560

  **Sponsored by** *Catalyst*
- [35395](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35395) Update description of DefaultPatronSearchMethod
- [35510](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35510) Non-patron guarantor missing from CollapseFieldsPatronAddForm  options
  >This adds Non-patron guarantor as an option to the CollapseFieldsPatronAddForm system preference - this section can now be collapsed on the patron form.

### Templates

#### Other bugs fixed

- [35413](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35413) Terminology: differentiate issues for vendor issues and serials
- [35417](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35417) Update breadcrumbs and page titles for vendor issues
- [35517](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35517) Choose correct default header search tab according to permissions
  >This fixes the display of the header search form on the staff interface home page so that staff patrons with different permissions will see the correct tab in the header search form. Previously, the default was to display the check out search - if they didn't have circulation permissions, the search tabs were initially hidden.
- [35523](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35523) Fix doubled up quotes in cash register deletion confirmation message
- [35524](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35524) Terminology: Bookseller in basket group CSV export
- [35525](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35525) Spelling: SMS is an abbreviation
- [35526](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35526) Terminology: Id, sushi and counter are abbreviations
- [35528](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35528) Avoid 'click' for links in system preferences
- [35529](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35529) Avoid 'click' for links in library administration
- [35557](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35557) LoadResultsCovers is not used (staff)
- [35602](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35602) Typo: AutoMemberNum
- [35650](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35650) 'Check the logs' string dot-inconsistent
  >This makes 'Check the logs..' messages more consistent across Koha, including the use of full stops. It also fixes up other related inconsistencies. These changes should make translations easier as well.

### Test Suite

#### Other bugs fixed

- [35507](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35507) Fix handling plugins in unit tests causing random failures on Jenkins
- [35556](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35556) selenium/administration_tasks.t failing if too many patron categories
- [35598](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35598) selenium/authentication_2fa.t is still failing randomly

### Tools

#### Critical bugs fixed

- [35696](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35696) Transit status not properly updated for items advanced in Stock Rotation tool

#### Other bugs fixed

- [35438](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35438) Importing records can create too large transactions
- [35579](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35579) marcrecord2csv searches authorised values inefficiently
  >This significantly improves the speed of downloading large lists in CSV format. (It adds a get_descriptions_by_marc_field" method which caches AuthorisedValue descriptions when searched by MARC field, which is used when exporting MARC to CSV.)
- [35588](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35588) marcrecord2csv retrieves authorised values incorrectly for fields
  >This fixes the CSV export of records so that authorized values are exported correctly. It ensures that the authorized value descriptions looked up are for the correct field/subfield designated in the CSV profile. Example: If the 942$s (Serial record flag) for a record has a value of "1", it was previously exported as "Yes" even though it wasn't an authorized value.
- [35641](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35641) Reduce DB calls when performing inventory on a list of barcodes

### Web services

#### Other bugs fixed

- [34950](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34950) ILS DI Availability is not accurate for items on holds shelf or in transit

### translate.koha-community.org

#### Critical bugs fixed

- [35428](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35428) gulp po tasks do not clean temporary files

## Enhancements 

### Templates

#### Enhancements

- [35474](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35474) Add icon for protected patrons

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Chinese (Traditional)](https://koha-community.org/manual/23.11//html/) (50%)
- [English](https://koha-community.org/manual/23.11//html/) (100%)
- [English (USA)](https://koha-community.org/manual/23.11/en/html/)
- [French](https://koha-community.org/manual/23.11/fr/html/) (39%)
- [German](https://koha-community.org/manual/23.11/de/html/) (41%)
- [Hindi](https://koha-community.org/manual/23.11/hi/html/) (68%)

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
- Czech (59%)
- Dutch (76%)
- English (100%)
- English (New Zealand) (64%)
- English (USA)
- Finnish (98%)
- French (95%)
- French (Canada) (97%)
- German (100%)
- German (Switzerland) (52%)
- Greek (52%)
- Hindi (100%)
- Italian (83%)
- Norwegian Bokmål (74%)
- Persian (fa_ARAB) (91%)
- Polish (92%)
- Portuguese (Brazil) (92%)
- Portuguese (Portugal) (88%)
- Russian (89%)
- Slovak (62%)
- Spanish (100%)
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

The release team for Koha 23.11.02 is


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
new features in Koha 23.11.02
<div style="column-count: 2;">

- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)
- [Koha-Suomi Oy](https://koha-suomi.fi)
- Pymble Ladies' College
</div>

We thank the following individuals who contributed patches to Koha 23.11.02
<div style="column-count: 2;">

- Aleisha Amohia (1)
- Pedro Amorim (7)
- Tomás Cohen Arazi (9)
- Matt Blenkinsop (5)
- Alex Buckley (2)
- Kevin Carnes (2)
- Nick Clemens (22)
- David Cook (6)
- Jonathan Druart (20)
- Laura Escamilla (1)
- Katrin Fischer (21)
- Lucas Gass (7)
- Victor Grousset (1)
- Kyle M Hall (18)
- Andrew Fuerste Henry (1)
- Michał Kula (1)
- Joonas Kylmälä (2)
- Emily Lamancusa (1)
- Owen Leonard (16)
- Julian Maurice (6)
- David Nind (3)
- Martin Renvoize (18)
- Marcel de Rooy (6)
- Caroline Cyr La Rose (5)
- Fridolin Somers (4)
- Emmi Takkinen (2)
- Shi Yao Wang (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 23.11.02
<div style="column-count: 2;">

- Athens County Public Libraries (16)
- BibLibre (10)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (21)
- ByWater-Solutions (48)
- Catalyst (2)
- Catalyst Open Source Academy (1)
- David Nind (3)
- dubcolib.org (1)
- Independant Individuals (2)
- Koha Community Developers (21)
- Koha-Suomi (2)
- montgomerycountymd.gov (1)
- Prosentient Systems (6)
- PTFS-Europe (30)
- Rijksmuseum (6)
- Solutions inLibro inc (6)
- Theke Solutions (9)
- ub.lu.se (2)
- users.noreply.github.com (1)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Pedro Amorim (3)
- Tomás Cohen Arazi (37)
- Matt Blenkinsop (1)
- Kevin Carnes (1)
- Nick Clemens (15)
- Jonathan Druart (24)
- Esther (1)
- Katrin Fischer (163)
- Andrew Fuerste-Henry (5)
- Lucas Gass (15)
- Eric Gosselin (2)
- Victor Grousset (20)
- Kyle M Hall (8)
- Jan Kissig (4)
- Emily Lamancusa (6)
- Brendan Lawlor (3)
- Owen Leonard (4)
- Mikko Liimatainen (1)
- Julian Maurice (11)
- Kelly McElligott (2)
- David Nind (71)
- Philip Orr (4)
- Barbara Petritsch (1)
- Martin Renvoize (42)
- Marcel de Rooy (11)
- sabrina (1)
- Fridolin Somers (184)
- Marc Véron (2)
- Anneli Österman (2)
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

Autogenerated release notes updated last on 29 Jan 2024 09:17:15.
