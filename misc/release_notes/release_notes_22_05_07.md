# RELEASE NOTES FOR KOHA 22.05.07
23 Nov 2022

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 22.05.07 can be downloaded from:

- [Download](http://download.koha-community.org/koha-22.05.07.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 22.05.07 is a bugfix/maintenance release.

It includes 8 enhancements, 54 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations




## Enhancements

### Architecture, internals, and plumbing

- [[29955]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29955) Move C4::Acquisition::populate_order_with_prices to Koha::Acquisition::Order
- [[30042]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30042) Remove Date::Calc use
- [[30982]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30982) Use the REST API for background job list view

### Cataloging

- [[31250]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31250) Don't remove advanced/basic cataloging editor cookie on logout

### Command-line Utilities

- [[31342]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31342) process_message_queue can run over the top of itself causing double-up emails

  **Sponsored by** *ByWater Solutions*

### OPAC

- [[31605]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31605) Improve style of OPAC suggestions search form

### SIP2

- [[31296]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31296) Add ability to disable demagnetizing items via SIP2 based on itemtypes

### System Administration

- [[30462]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30462) Should the background job list view hide index tasks by default?


## Critical bugs fixed

### Acquisitions

- [[32167]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32167) When adding an order from a a staged file without item fields we only add price if there is a vendor discount

### Architecture, internals, and plumbing

- [[32011]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32011) 2FA - Problem with qr_code generation

### Cataloging

- [[31234]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31234) SubfieldsToAllowForRestrictedEditing : data from drop-down menu not stored
- [[31818]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31818) Advanced editor doesn't show keyboard shortcuts

### Circulation

- [[28553]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28553) Patrons can be set to receive auto_renew notices as SMS, but Koha does not generate them

### Installation and upgrade (command-line installer)

- [[32110]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32110) Duplicated additional content entries on DBRev 210600016

### Patrons

- [[31421]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31421) Library limitation on patron category breaks patron search
- [[31497]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31497) Quick add: mandatory fields save as empty when not filled in before first save attempt

### System Administration

- [[31364]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31364) Saving multi-select system preference don't save when all checks are removed

### Templates

- [[31558]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31558) Upgrade of TinyMCE broke image drag and drop

### Tools

- [[31154]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31154) Batch item modification fails when "Use default values" is checked

  **Sponsored by** *Koha-Suomi Oy*


## Other bugs fixed

### Acquisitions

- [[27550]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27550) "Duplicate budget" does not keep users associated with the funds

  >Users linked to funds in acquisitions will now be kept when a budget and fund structure is duplicated.
- [[29658]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29658) Crash on cancelling cancelled order
- [[30359]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30359) GetBudgetHierarchy is slow on order receive page

  **Sponsored by** *Koha-Suomi Oy*
- [[31367]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31367) Display of sub-funds does not include totals of sub-sub-funds on acquisitions home page

### Architecture, internals, and plumbing

- [[28167]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28167) A warning when setting which library to use in intranet and UseCashRegisters is disabled
- [[30262]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30262) opac/tracklinks.pl inconsistent with GetMarcUrls for whitespace
- [[31177]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31177) Misplaced import in C4::ILSDI::Services

### Cataloging

- [[31646]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31646) Focus input by default when clicking on a dropdown field in the cataloguing editor
- [[31863]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31863) Advanced cataloging editor no longer auto-resizes

### Circulation

- [[26626]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26626) When checking in a hold that is not found the X option is 'ignore' and when hold is found it is 'cancel'

### Command-line Utilities

- [[31239]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31239) search_for_data_inconsistencies.pl fails for Koha to MARC mapping using biblio table
- [[31299]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31299) Duplicate output in search_for_data_inconsistencies.pl
- [[31356]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31356) Itiva outbound script doesn't respect calendar when calculating expiration date for holds

### Database

- [[30483]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30483) Do not allow NULL in issues.borrowernumber and issues.itemnumber

### Documentation

- [[31465]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31465) Link system preference tabs to correct manual pages

### Fines and fees

- [[31513]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31513) NaN errors when using refund and payout with CurrencyFormat = FR

### Hold requests

- [[31112]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31112) Able to renew checkout when the number of holds exceeds available number of items

  >When AllowRenewalIfOtherItemsAvailable is set to Allow it now correctly takes into account all the holds instead of just one per patron.
- [[31518]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31518) Hidden items count not displayed on hold request page

### ILL

- [[30890]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30890) ILL breadcrumbs are wrong

### Notices

- [[29409]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29409) Update for bug 25333 can fail due to bad data or constraints

### OPAC

- [[30231]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30231) Don't display (rejected) forms of series entry in search results
- [[31483]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31483) Minor UI problem in opac-reset-password.pl
- [[31527]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31527) Breadcrumbs for anonymous suggestions are not correct
- [[31531]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31531) Some modules loaded twice in opac-memberentry.pl

### Patrons

- [[31486]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31486) Deleting a message from checkouts tab redirects to detail tab in patron account

  >This patch corrects a problem where message deletion was improperly redirecting to the patron delete page when a message is deleted on the circulation page.
- [[31516]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31516) Missing error handling for accessing deleted/non-existent club enrollment

  >This adds an error message when viewing enrollments for a non-existent club. Previously, a page with an empty title and table were displayed.
- [[31525]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31525) Street number not being accessed correctly on patron search results page

  **Sponsored by** *Catalyst*
- [[31562]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31562) Patron 'flags' don't respect unwanted fields

### Searching - Elasticsearch

- [[25375]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25375) Elasticsearch: Limit on available items does not work
- [[31023]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31023) Cannot create new GENRE/FORM authorities when  QueryRegexEscapeOptions  set to 'Unescape escaped'

### Self checkout

- [[31488]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31488) Rephrase "You have checked out too many items" to be friendlier

### Serials

- [[29608]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29608) Editing numbering patterns does require full serials permission

### Staff interface

- [[31565]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31565) Patron search filter by category code with special character returns no results

### System Administration

- [[31401]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31401) Update administration sidebar to match entries on administration start page
- [[31489]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31489) Typo in EnableExpiredPasswordReset description
- [[31995]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31995) build_holds_queue.pl should check to see if the RealTime syspref is on

### Templates

- [[31379]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31379) Change results per page text for default
- [[31530]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31530) HTML tags in TT comments in patron-search.inc
- [[31542]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31542) Home page links wrong font-family

### Test Suite

- [[31598]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31598) Fix random failure on Jenkins for t/db_dependent/Upload.t

### Tools

- [[28290]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28290) Record matching rules with no subfields cause ISE
- [[31482]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31482) Label creator does not call barcodedecode
- [[31564]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31564) Pass start label when exporting single label as PDF



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/22.05/ar/html/) (28.2%)
- [Chinese (Taiwan)](https://koha-community.org/manual/22.05/zh_TW/html/) (49.2%)
- [English (USA)](https://koha-community.org/manual/22.05/en/html/)
- [French](https://koha-community.org/manual/22.05/fr/html/) (58.4%)
- [German](https://koha-community.org/manual/22.05/de/html/) (61.3%)
- [Hindi](https://koha-community.org/manual/22.05/hi/html/) (100%)
- [Italian](https://koha-community.org/manual/22.05/it/html/) (41.2%)
- [Spanish](https://koha-community.org/manual/22.05/es/html/) (29.6%)
- [Turkish](https://koha-community.org/manual/22.05/tr/html/) (33.5%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (78%)
- Armenian (100%)
- Armenian (Classical) (71.6%)
- Bulgarian (85.6%)
- Chinese (Taiwan) (90.5%)
- Czech (62.4%)
- English (New Zealand) (56.1%)
- English (USA)
- Finnish (94.9%)
- French (97.1%)
- French (Canada) (99.9%)
- German (100%)
- German (Switzerland) (54.2%)
- Greek (54.2%)
- Hindi (100%)
- Italian (100%)
- Nederlands-Nederland (Dutch-The Netherlands) (83.2%)
- Norwegian Bokmål (56%)
- Persian (58.7%)
- Polish (100%)
- Portuguese (79.3%)
- Portuguese (Brazil) (76.8%)
- Russian (78.3%)
- Slovak (63.8%)
- Spanish (98%)
- Swedish (77%)
- Telugu (84.7%)
- Turkish (91.9%)
- Ukrainian (72.7%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 22.05.07 is


- Release Manager: Tomás Cohen Arazi

- Release Manager assistants:
  - Jonathan Druart
  - Martin Renvoize

- QA Manager: Katrin Fischer

- QA Team:
  - Aleisha Amohia
  - Nick Clemens
  - Jonathan Druart
  - Lucas Gass
  - Victor Grousset
  - Kyle M Hall
  - Joonas Kylmälä
  - Andrew Nugged
  - Martin Renvoize
  - Marcel de Rooy
  - Fridolin Somers
  - Petro Vashchuk

- Topic Experts:
  - UI Design -- Owen Leonard
  - Zebra -- Fridolin Somers

- Bug Wranglers:
  - Aleisha Amohia
  - Jake Deery
  - Lucas Gass
  - Séverine Queune

- Packaging Manager: 


- Documentation Manager: David Nind


- Documentation Team:
  - Donna Bachowski
  - Aude Charillon
  - Martin Renvoize
  - Lucy Vaux-Harvey

- Translation Managers: 
  - Bernardo González Kriegel

- Wiki curators: 
  - Thomas Dukleth
  - Katrin Fischer

- Release Maintainers:
  - 22.05 -- Lucas Gass
  - 21.11 -- Arthur Suzuki
  - 21.05 -- Victor Grousset

## Credits
We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 22.05.07

- [ByWater Solutions](https://bywatersolutions.com)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)
- Koha-Suomi Oy

We thank the following individuals who contributed patches to Koha 22.05.07

- Tomás Cohen Arazi (7)
- Philippe Blouin (1)
- Jérémy Breuillard (1)
- Nick Clemens (24)
- David Cook (3)
- Jonathan Druart (6)
- Katrin Fischer (2)
- Lucas Gass (8)
- Isobel Graham (3)
- Kyle M Hall (6)
- Janusz Kaczmarek (1)
- Joonas Kylmälä (9)
- Owen Leonard (3)
- Julian Maurice (5)
- Johanna Raisa (1)
- Martin Renvoize (4)
- Marcel de Rooy (8)
- Caroline Cyr La Rose (1)
- Fridolin Somers (6)
- Emmi Takkinen (1)
- Lari Taskula (1)
- Koha translators (1)
- Wainui Witika-Park (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 22.05.07

- Athens County Public Libraries (3)
- BibLibre (12)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (2)
- ByWater-Solutions (38)
- Catalyst (1)
- Hypernova Oy (1)
- Independant Individuals (14)
- Koha Community Developers (6)
- Koha-Suomi (1)
- Prosentient Systems (3)
- PTFS-Europe (4)
- Rijksmuseum (8)
- Solutions inLibro inc (2)
- Theke Solutions (7)

We also especially thank the following individuals who tested patches
for Koha

- Aleisha Amohia (1)
- Tomás Cohen Arazi (93)
- Philippe Blouin (1)
- Nick Clemens (12)
- David Cook (1)
- Chris Cormack (2)
- Jonathan Druart (6)
- Magnus Enger (1)
- Katrin Fischer (21)
- Andrew Fuerste-Henry (6)
- Lucas Gass (98)
- Kyle M Hall (19)
- Sally Healey (2)
- Samu Heiskanen (1)
- Barbara Johnson (2)
- Joonas Kylmälä (22)
- Owen Leonard (6)
- David Nind (23)
- Liz Rea (1)
- Martin Renvoize (25)
- Marcel de Rooy (20)
- Caroline Cyr La Rose (1)
- Michaela Sieber (2)
- Fridolin Somers (1)
- George Williams (1)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is rmain2205.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 23 Nov 2022 17:01:23.
