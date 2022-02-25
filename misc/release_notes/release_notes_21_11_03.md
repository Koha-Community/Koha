# RELEASE NOTES FOR KOHA 21.11.03
25 Feb 2022

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 21.11.03 can be downloaded from:

- [Download](http://download.koha-community.org/koha-21.11.03.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 21.11.03 is a bugfix/maintenance release with security fixes.

It includes 2 security fixes, 4 enhancements, 80 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations


## Security bugs

### Koha

- [[29931]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29931) Script plugins-enable.pl should check the cookie status before running plugins
- [[29956]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29956) Cookie can contain plain text password


## Enhancements

### Architecture, internals, and plumbing

- [[29397]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29397) Add a select2 wrapper for the API

### Circulation

- [[29519]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29519) One should be able to resolve a return claim at checkin

### I18N/L10N

- [[29596]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29596) Add Yiddish language

  **Sponsored by** *Universidad Nacional de San Martín*

  >This enhancement adds the Yiddish (יידיש) language to Koha. Yiddish now appears as an option for refining search results in the staff interface advanced search (Search > Advanced search > More options > Language and Language of original) and the OPAC (Advanced search > More options > Language).

### Web services

- [[28238]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28238) Add itemcallnumber to ILS-DI GetAvailability output

  **Sponsored by** *University Lyon 3*

  >This enhancement adds the item call number to the ILS-DI GetAvailability output. This is useful for libraries that use discovery tools as patrons often don't check further for the call number, and then they don't have it when they look for the item.


## Critical bugs fixed

### Acquisitions

- [[29464]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29464) GET /acquisitions/orders doesn't honour sorting

  **Sponsored by** *ByWater Solutions*
- [[29570]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29570) Unable to sort summary column of pending_orders table on parcel.pl by summary column

### Architecture, internals, and plumbing

- [[29804]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29804) Koha::Hold->is_pickup_location_valid explodes if empty list of pickup locations

### Cataloging

- [[29690]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29690) Software error in details.pl when invalid MARCXML

### Circulation

- [[29495]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29495) Issue link is lost in return claims when using 'MarkLostItemsAsReturned'
- [[30099]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30099) Error when accessing circulation.pl without patron parameter

### Database

- [[29605]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29605) DB structure may not be synced with kohastructure.sql

### Fines and fees

- [[29385]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29385) Add missing cash register support to SIP2

### Hold requests

- [[29906]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29906) When changing hold parameters over API (PUT) it forcibly gets to "suspended" state

  >The PATCH/PUT /api/v1/holds/{hold_id} API endpoint allows for partial updates of Holds.  Priority and Pickup Location are both available to change (though it is preferred to use the routes specifically added for manipulating them).
  >
  >Suspend_until can also be added/updated to add or lengthen an existing suspension, but the field cannot be set to null to remove the suspension at present.
  >
  >This patch restores the suspen_until function to ensure suspensions are not triggered by unrelated pickup location or priority changes.
- [[29969]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29969) Cannot update hold list after holds cancelled in bulk

### ILL

- [[28932]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28932) Backend overriding status_graph element causes duplicate actions

### OPAC

- [[29803]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29803) Local cover images don't show in detail page, but only in results
- [[30045]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30045) SCO print slip is broken

### Packaging

- [[29881]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29881) Remove SQLite2 dependency

### Patrons

- [[28943]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28943) Lower the risk of accidental patron deletion by cleanup_database.pl

  >If you use self registration but you do not use a temporary self registration patron category,
  >you should actually clear the preference
  >PatronSelfRegistrationExpireTemporaryAccountsDelay.

### REST API

- [[30133]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30133) Pagination broken on pickup_locations routes when AllowHoldPolicyOverride=1

### Reports

- [[29786]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29786) Holds to pull report shows incorrect item for item level holds

  >This patch corrects an issue with the Holds to Pull report in which an incorrect barcode number could be shown for an item-level hold. The correct barcode will now be shown.

### SIP2

- [[29754]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29754) Patron fines counted twice for SIP when NoIssuesChargeGuarantorsWithGuarantees is enabled

### Test Suite

- [[29779]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29779) selenium/regressions.t fails if Selenium lib is not installed

### Tools

- [[29808]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29808) Stock rotation fails to advance when an item is checked out from the branch that is the next stage


## Other bugs fixed

### Acquisitions

- [[29895]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29895) Button [Add multiple items] stops responding when it's pressed and some multiple items added to basket

### Architecture, internals, and plumbing

- [[18320]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18320) patroncards/edit-layout.pl raises warnings
- [[18540]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18540) koha-indexdefs-to-zebra.xsl introduces MARC21 stuff into UNIMARC xslts
- [[29336]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29336) Some authorised_value FKs are too short

  >This fixes the length of the field definitions in the database for several authorised_value and authorised_value_category columns as they are too short. It changes the value to varchar(32).
- [[29498]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29498) Remove usage of deprecated Mojolicious::Routes::Route::detour
- [[29625]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29625) Wrong var name in Koha::BiblioUtils get_all_biblios_iterator
- [[29646]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29646) Bad or repeated opac-password-recovery attempt crashes on wrong borrowernumber
- [[29758]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29758) CGI::param in list context in boraccount.pl warning

  >This removes the cause of warning messages ([WARN] CGI::param called in list context from...) in the plack-intranet-error.log when accessing the accounting transactions tab for a patron.
- [[29764]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29764) EmbedItems RecordProcessor filter POD incorrect
- [[29785]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29785) Koha::Object->messages must be renamed
- [[29806]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29806) ->pickup_locations should always be called in scalar context

  >The Koha::Biblio->pickup_locations and Koha::Item->pickup_location methods don't always honour list context. Because of this, when used, they should assume scalar context. If list context was required, the developer needs to explicitly chain a ->as_list call.
  >
  >This patch tracks the uses of this methods and adjusts accordingly.
- [[29809]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29809) StockRotationItems->itemnumber is poorly named
- [[29812]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29812) C4::Context not included, but used in Koha::Token
- [[29865]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29865) Wrong includes in circ/returns.pl
- [[29966]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29966) SCO Help page passes flags while not needing authentication
- [[30115]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30115) Uninitialized value warning in C4/Output.pm

### Browser compatibility

- [[22671]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22671) Warn the user in offline circulation if applicationCache isn't supported

### Cataloging

- [[29511]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29511) While editing MARC records, blank subfields appear in varying order
- [[29962]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29962) Table of items on item edit page missing columns button

### Circulation

- [[11750]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11750) Overdue report does not limit patron attributes
- [[29820]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29820) Print summary just show 20 items
- [[29889]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29889) Incorrect library check in patron message deletion logic

  >This fixes the logic controlling whether a patron message on the circulation or patron details page has a "Delete" link. An error in the logic prevented messages from being removed by staff who should have been authorized to do so.

### Command-line Utilities

- [[29054]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29054) Stop warns from advance_notices.pl if not running in verbose mode

  **Sponsored by** *Catalyst*

### Fines and fees

- [[29952]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29952) Filter Paid Transactions Broken on Transactions tab in Staff

  >This fixes the "Filter paid transactions" link in the staff interface on the Patron account > Accounting > Transactions tab. It now correctly filters the list of transactions - only transactions with an outstanding amount greater than zero are shown ("Show all transactions" clears the filter). Before this fix, clicking on the link didn't do anything and didn't filter any of the transactions as expected.

### Hold requests

- [[21652]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21652) reserves.waitingdate is set to current date by printing new hold slip
- [[29043]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29043) Items are processed but not displayed on request.pl before a patron is selected
- [[29474]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29474) Automatic renewals cronjob is slow on systems with large numbers of reserves
- [[29704]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29704) Holds reminder emails should allow configuration for a specific number of days

### I18N/L10N

- [[29585]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29585) "Go to field" in cataloguing alerts is not translatable

  >This fixes the 'Go to field' and 'Errors' strings in the basic MARC editor to make them translatable. (This is a follow-up to bug 28694 that changed the way validation error messages are displayed when using the basic MARC editor in cataloging.)

### Installation and upgrade (web-based installer)

- [[29837]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29837) JS error during installer

### Notices

- [[29230]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29230) Patron's messages not accessible from template notices
- [[29943]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29943) Fix typo in notices yaml file

### OPAC

- [[29320]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29320) Use OverDrive availability API V2
- [[29481]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29481) Terminology: Collection code
- [[29482]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29482) Terminology: This item belongs to another branch.

  >This replaces the word "branch" with the word "library" for a self-checkout message, as per the terminology guidelines.  ("This item belongs to another branch." changed to "This item belongs to another library".)
- [[29686]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29686) Adapt OverDrive for new fulfillment API
- [[29706]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29706) When placing a request on the opac, the user is shown titles they cannot place a hold on
- [[29795]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29795) If branch is mandatory on patron self registration form, the pull down should default to empty

  >Creates an empty value and defaults to it when PatronSelfRegistrationBorrowerMandatoryField includes branchcode. This forces self registering users to make a choice for the library.
- [[29840]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29840) opac-reserve explodes if invalid biblionumber is passed

### Patrons

- [[28576]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28576) Add patron image in patron detail section does not specify image size limit

  >This updates the add patron image screen to specify that the maximum image size is 2 MB. If it is larger, the patron image is not added.
- [[30090]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30090) Don't export action buttons from patron results

### Reports

- [[28977]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28977) Most-circulated items (cat_issues_top.pl) is failing with SQL Mode ONLY_FULL_GROUP_BY

  >This fixes an error that causes the most circulated items report to fail when run on a database with SQL mode ONLY_FULL_GROUP_BY and in strict SQL mode.
- [[30129]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30129) 500 error when search reports by date

### Searching - Elasticsearch

- [[27770]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27770) ES: Deprecated aggregation order key [_term] used, replaced by [_key]

  **Sponsored by** *Lund University Library*

### System Administration

- [[29875]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29875) Update text on MaxReserves system preference to describe functionality.

### Templates

- [[29735]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29735) Remove flatpickr instantiations from .js files
- [[29807]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29807) Branches template plugin doesn't handle empty lists correctly

  >The Branches TT plugin had wrong logic in it, that made it crash, or display wrong pickup locations when the item/biblio didn't have any valid pickup location.
- [[29853]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29853) Text needs HTML filter before KohaSpan filter
- [[29932]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29932) Phase out jquery.cookie.js: bibs_selected (Browse selected records)
- [[29933]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29933) Fix stray usage of jquery.cookie.js plugin
- [[29967]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29967) Increase size of description fields for authorized values in templates

  >Extends the length of the description and OPAC description fields on authorised_values.tt making it easier to see and edit text that has longer descriptions.
- [[30082]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30082) Bibliographic details tab missing when user can't add local cover image

### Test Suite

- [[29838]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29838) No string interpolation when expected in t/db_dependent/ImportBatch.t
- [[29862]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29862) TestBuilder.t fails with ES enabled
- [[29884]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29884) Missing test in api/v1/patrons.t

### Tools

- [[29156]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29156) File missing warning in Koha::UploadedFile should be for permanent files only

  >This removes the warning from the log files when temporarily uploaded files are deleted and the file no longer exists (for example, when the temporary files are in /tmp directory and the system is rebooted they are deleted).
- [[29722]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29722) Add some diversity to sample quotes

  **Sponsored by** *Catalyst*

  >This patch adds sample quotes from women, women of colour, trans women, Black and Indigenous women, and people who weren't US Presidents!
- [[29761]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29761) Patron batch modification tool - duplicated information on the listing page
- [[29797]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29797) Background job detail for batch delete items not listing the itemnumbers

### Z39.50 / SRU / OpenSearch Servers

- [[19865]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19865) Side scroll bar in z39.50 MARC view

  >Makes the horizontal scroll bar of the MARC preview modal on  cataloguing/z3950_search.tt always visible for an easier user experience.



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)



The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (87.2%)
- Armenian (100%)
- Armenian (Classical) (89%)
- Bulgarian (91.9%)
- Chinese (Taiwan) (78.8%)
- Czech (68.9%)
- English (New Zealand) (59%)
- English (USA)
- Finnish (84.7%)
- French (94.2%)
- French (Canada) (91.9%)
- German (100%)
- German (Switzerland) (58.6%)
- Greek (55.6%)
- Hindi (100%)
- Italian (91.2%)
- Nederlands-Nederland (Dutch-The Netherlands) (69%)
- Norwegian Bokmål (63.2%)
- Polish (98.3%)
- Portuguese (91.2%)
- Portuguese (Brazil) (83.5%)
- Russian (84.9%)
- Slovak (69.7%)
- Spanish (99.7%)
- Swedish (81.9%)
- Telugu (95.2%)
- Turkish (96.6%)
- Ukrainian (74.9%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 21.11.03 is


- Release Manager: Fridolin Somers

- Release Manager assistants:
  - Jonathan Druart
  - Martin Renvoize
  - Tomás Cohen Arazi

- QA Manager: Katrin Fischer

- QA Team:
  - Andrew Nugged
  - Jonathan Druart
  - Joonas Kylmälä
  - Kyle M Hall
  - Marcel de Rooy
  - Martin Renvoize
  - Nick Clemens
  - Petro Vashchuk
  - Tomás Cohen Arazi
  - Victor Grousset

- Topic Experts:
  - UI Design -- Owen Leonard
  - REST API -- Tomás Cohen Arazi
  - Zebra -- Fridolin Somers
  - Accounts -- Martin Renvoize

- Bug Wranglers:
  - Indranil Das Gupta
  - Erica Rohlfs

- Packaging Manager: 


- Documentation Manager: David Nind


- Documentation Team:
  - Aude Charillon
  - Caroline Cyr La Rose
  - Kelly McElligott
  - Lucy Vaux-Harvey
  - Martin Renvoize
  - Rocio Lopez

- Translation Managers: 
  - Bernardo González Kriegel

- Wiki curators: 
  - Thomas Dukleth

- Release Maintainers:
  - 21.11 -- Kyle M Hall
  - 21.05 -- Andrew Fuerste-Henry
  - 20.11 -- Victor Grousset
  - 19.11 -- Wainui Witika-Park

## Credits
We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 21.11.03

- [ByWater Solutions](https://bywatersolutions.com)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)
- Lund University Library
- Universidad Nacional de San Martín
- University Lyon 3

We thank the following individuals who contributed patches to Koha 21.11.03

- Salman Ali (1)
- Aleisha Amohia (1)
- Tomás Cohen Arazi (26)
- Philippe Blouin (1)
- Alex Buckley (1)
- Kevin Carnes (1)
- Nick Clemens (18)
- Jonathan Druart (39)
- Marion Durand (2)
- Katrin Fischer (2)
- Andrew Fuerste-Henry (1)
- Lucas Gass (4)
- Michael Hafen (1)
- Kyle M Hall (11)
- Andrew Isherwood (2)
- Mason James (1)
- Joonas Kylmälä (2)
- Owen Leonard (9)
- The Minh Luong (1)
- Julian Maurice (1)
- Hayley Pelham (1)
- Martin Renvoize (13)
- Marcel de Rooy (10)
- Fridolin Somers (9)
- Lyon 3 Team (1)
- Koha translators (1)
- Petro Vashchuk (2)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 21.11.03

- Athens County Public Libraries (9)
- BibLibre (12)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (2)
- ByWater-Solutions (34)
- Catalyst (2)
- Catalyst Open Source Academy (1)
- Independant Individuals (4)
- Koha Community Developers (39)
- KohaAloha (1)
- PTFS-Europe (15)
- Rijksmuseum (10)
- Solutions inLibro inc (3)
- Theke Solutions (26)
- ub.lu.se (1)
- Université Jean Moulin Lyon 3 (1)
- washk12.org (1)

We also especially thank the following individuals who tested patches
for Koha

- Tomás Cohen Arazi (37)
- Nick Clemens (19)
- David Cook (1)
- Michal Denar (1)
- Solène Desvaux (1)
- Jonathan Druart (58)
- Katrin Fischer (20)
- Andrew Fuerste-Henry (15)
- Lucas Gass (7)
- Victor Grousset (1)
- Kyle M Hall (139)
- Stina Hallin (1)
- Sally Healey (1)
- Samu Heiskanen (1)
- Barbara Johnson (2)
- Joonas Kylmälä (1)
- Owen Leonard (8)
- The Minh Luong (2)
- David Nind (24)
- Hayley Pelham (2)
- Martin Renvoize (26)
- Marcel de Rooy (9)
- Fridolin Somers (138)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 21.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 25 Feb 2022 18:30:17.
