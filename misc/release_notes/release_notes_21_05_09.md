# RELEASE NOTES FOR KOHA 21.05.09
31 Jan 2022

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 21.05.09 can be downloaded from:

- [Download](http://download.koha-community.org/koha-21.05.09.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 21.05.09 is a bugfix/maintenance release with security fixes.

It includes 9 security fixes, 26 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations


## Security bugs

### Koha

- [[26102]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26102) Javascript injection in intranet search
- [[28735]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28735) Self-checkout users can access opac-user.pl for sco user when not using AutoSelfCheckID
- [[29540]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29540) Accounts with just 'catalogue' permission can modify/delete holds
- [[29541]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29541) Patron images can be accessed with just 'catalogue' permission
- [[29542]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29542) User with 'catalogue' permission can view everybody's (private) virtualshelves
- [[29543]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29543) Self-checkout allows returning everybody's loans
- [[29544]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29544) A patron can set everybody's checkout notes
- [[29903]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29903) Message deletion possible from different branch
- [[29914]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29914) check_cookie_auth not strict enough




## Critical bugs fixed

### Acquisitions

- [[29464]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29464) GET /acquisitions/orders doesn't honour sorting

  **Sponsored by** *ByWater Solutions*

### Fines and fees

- [[29457]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29457) Fee Cancellation records the wrong manager_id

  >Prior to this patch inadvertently the field borrowers.userid was used to fill accountslines.manager_id. This should have been borrowernumber.
  >
  >This report fixes that and prints a generic warning.

### Hold requests

- [[29736]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29736) Error when placing a hold for a club without members

### Notices

- [[29381]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29381) Auto-renewal digest messages are sent on every cron run

  >This fixes an issue with automatic renewal digest messages - these were being sent on every cron run, even if there was nothing to renew or no renewal errors.
  >
  >(This error was caused by a regression in 21.05 from Bug 18532: Add individual issues to digest notice and hide auto_renewals messaging preference when not needed.)

### OPAC

- [[29696]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29696) "Suggest for purchase" missing biblio link

### REST API

- [[29018]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29018) Deleting patrons from REST API doesn't do any checks or move to deletedborrowers

  >These fixes the REST API route for deleting patrons so that it now checks for guarantees, debts, and current checkouts. If any of these checks fail, the patron is not deleted.


## Other bugs fixed

### Acquisitions

- [[24866]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24866) Display budget hierarchy in the budget dropdown menu used when placing a new order

  >This improves the display for selecting a fund when placing a new order in acquisitions. It now displays as a hierarchy instead of a list without any indentation, for example:
  >
  >  Budget 2021
  >  -- Book
  >  -- -- Adult fiction
- [[29419]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29419) Suggest for purchase clears item type, quantity, library and reason if bib exists

### Architecture, internals, and plumbing

- [[29702]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29702) all_libraries routine in library groups make a DB call per member of group
- [[29789]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29789) Unused $error in cataloguing/additem.pl

### Circulation

- [[29476]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29476) Earliest renewal date is displayed wrong in circ/renew.pl for issues with auto renewing

### Hold requests

- [[29553]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29553) Holds: Can't call method "notforloan" on an undefined value when placing a hold

### Notices

- [[29557]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29557) Auto renew notices should handle failed renewal due to patron expiration

  >This enhancement updates the default auto-renewal notices to tell patrons that their renewals have failed because their account has expired.

### OPAC

- [[17127]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17127) Can't hide MARC21 500 and others with NotesToHide

  >This fixes hiding notes fields (5XX in MARC21 and 3XX in UNIMARC) using NotesToHide. Before this you could hide one field and it worked. However, when hiding multiple fields one field would still always be visible. Now hiding notes fields works as expected.
- [[29604]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29604) Term highlighting adds unwanted pseudo element in the contentblock of OPAC details page
- [[29685]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29685) 'If all unavailable' state for 'on shelf holds' makes holds page very slow if there's a lot of items on opac

### Packaging

- [[28926]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28926) Update cpanfile for Mojolicious::Plugin::OpenAPI v2.16

### REST API

- [[29503]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29503) GET /patrons should use Koha::Patrons->search_limited
- [[29506]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29506) objects.search should call search_limited if present
- [[29508]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29508) GET /patrons/:patron_id should use Koha::Patrons->search_limited

### Reports

- [[29530]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29530) When NumSavedReports is set, show value in pull down of entries

  >This updates the way the NumSavedReports preference value is used on the saved reports page. For the "Show" dropwdown list:
  >- it now displays the number set in NumSavedReports (previously it showed 20)
  >- when expanded it now shows the number set in NumSavedReports sequentially (for example, if NumSavedReports is 78, the menu options should be "10, 20, 50, 78, 100, All"), and
  >- it now displays 'All' if NumSavedReports is blank.
  >
  >It also updates the description for the NumSavedReports preference to clarify that all reports are shown when no value is entered.
- [[29680]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29680) Reports menu 'Show SQL code' wrong border radius
- [[29729]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29729) If serials_stats.pl returns no results dataTables get angry

### Searching - Elasticsearch

- [[29436]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29436) Cannot reorder facets in staff interface elasticsearch configuration

### System Administration

- [[29591]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29591) Add autorenew_checkouts to BorrowerMandatory/Unwanted fields system preferences

### Templates

- [[29571]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29571) Mainpage : "All libraries" pending suggestions are visible only if the current library has suggestions

  >This fixes the display of pending suggestions in the staff interface so that it now shows pending suggestions for all libraries, for example: "Suggestions pending approval: Centerville: 0 / All libraries: 1.". Previously suggestions pending approval was only shown if there were suggestions for the user's current library.



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/21.05/ar/html/) (34.3%)
- [Chinese (Taiwan)](https://koha-community.org/manual/21.05/zh_TW/html/) (58.8%)
- [Czech](https://koha-community.org/manual/21.05/cs/html/) (27.6%)
- [English (USA)](https://koha-community.org/manual/21.05/en/html/)
- [French](https://koha-community.org/manual/21.05/fr/html/) (56.2%)
- [French (Canada)](https://koha-community.org/manual/21.05/fr_CA/html/) (25.5%)
- [German](https://koha-community.org/manual/21.05/de/html/) (73.5%)
- [Hindi](https://koha-community.org/manual/21.05/hi/html/) (100%)
- [Italian](https://koha-community.org/manual/21.05/it/html/) (48.1%)
- [Spanish](https://koha-community.org/manual/21.05/es/html/) (36.9%)
- [Turkish](https://koha-community.org/manual/21.05/tr/html/) (40.3%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (89.9%)
- Armenian (100%)
- Armenian (Classical) (89%)
- Chinese (Taiwan) (83%)
- Czech (71.4%)
- English (New Zealand) (61.5%)
- English (USA)
- Finnish (82.4%)
- French (92.8%)
- French (Canada) (94.7%)
- German (100%)
- German (Switzerland) (60.8%)
- Greek (54.9%)
- Hindi (100%)
- Italian (94.7%)
- Nederlands-Nederland (Dutch-The Netherlands) (61.7%)
- Norwegian Bokmål (65.9%)
- Polish (100%)
- Portuguese (91.4%)
- Portuguese (Brazil) (87.1%)
- Russian (86.6%)
- Slovak (72.7%)
- Spanish (99.9%)
- Swedish (77%)
- Telugu (99.7%)
- Turkish (99.7%)
- Ukrainian (75.2%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 21.05.09 is


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
new features in Koha 21.05.09

- [ByWater Solutions](https://bywatersolutions.com)

We thank the following individuals who contributed patches to Koha 21.05.09

- Tomás Cohen Arazi (16)
- Florian Bontemps (3)
- Nick Clemens (8)
- David Cook (1)
- Jonathan Druart (23)
- Katrin Fischer (1)
- Andrew Fuerste-Henry (6)
- Lucas Gass (2)
- Didier Gautheron (1)
- Mason James (1)
- Joonas Kylmälä (2)
- Owen Leonard (9)
- Martin Renvoize (2)
- Marcel de Rooy (3)
- Andreas Roussos (1)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 21.05.09

- Athens County Public Libraries (9)
- BibLibre (4)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (1)
- ByWater-Solutions (16)
- Dataly Tech (1)
- Independant Individuals (2)
- Koha Community Developers (23)
- KohaAloha (1)
- Prosentient Systems (1)
- PTFS-Europe (2)
- Rijksmuseum (3)
- Theke Solutions (16)

We also especially thank the following individuals who tested patches
for Koha

- Tomás Cohen Arazi (11)
- Florian Bontemps (1)
- Nick Clemens (23)
- Jonathan Druart (14)
- Katrin Fischer (34)
- Andrew Fuerste-Henry (73)
- Lucas Gass (4)
- Victor Grousset (20)
- Kyle M Hall (45)
- Joonas Kylmälä (1)
- Owen Leonard (1)
- David Nind (12)
- Martin Renvoize (9)
- Marcel de Rooy (4)
- Andreas Roussos (2)
- Sally (1)
- Fridolin Somers (37)
- ThibaudGLT (2)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is rmain2105.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 31 Jan 2022 17:38:56.
