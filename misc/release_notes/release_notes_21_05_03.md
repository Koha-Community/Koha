# RELEASE NOTES FOR KOHA 21.05.03
24 Aug 2021

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 21.05.03 can be downloaded from:

- [Download](http://download.koha-community.org/koha-21.05.03.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 21.05.03 is a bugfix/maintenance release.

It includes 1 enhancement, 44 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations

## Security fixes

- [[28784]](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28784) DoS in opac-search.pl causes OOM situation and 100% CPU (doesn't require login!)

## Enhancements

### Web services

- [[28630]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28630) ILSDI::AuthenticatePatron should set borrowers.lastseen


## Critical bugs fixed

### Acquisitions

- [[28773]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28773) Aquisitions from external source not working for non english language

### Hold requests

- [[28057]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28057) Confusion of biblionumber and biblioitemnumber in request.pl

### OPAC

- [[28631]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28631) Holds History title link returns "not found" error
- [[28679]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28679) Unable to click "Log in to your account" when  GoogleOpenIDConnect  is enabled

  >This fixes the login link in the OPAC when GoogleOpenIDConnect is enabled. It removes modal-related markup which was causing the link to fail.

### Reports

- [[28804]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28804) 500 Error when running report with bad syntax

### Staff Client

- [[28872]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28872) AcquisitionLog, NewsLog, NoticesLog should use 1/0 for their values

### Tools

- [[28745]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28745) Batch item modifications no longer displayed modified items


## Other bugs fixed

### Acquisitions

- [[28408]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28408) Last modification date for suggestions is wrong

### Architecture, internals, and plumbing

- [[28620]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28620) Remove trailing space when logging with log4perl
- [[28622]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28622) Selected branchcode incorrectly passed to adv search
- [[28776]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28776) Warns from GetItemsInfo when biblio marked as serial

### Cataloging

- [[28533]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28533) Requesting whole field in 'itemcallnumber' system preference causes internal server error
- [[28727]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28727) "Edit item" button on moredetail should be enabled with edit_items permission
- [[28828]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28828) Bug 22399 breaks unimarc_field_4XX.tt and marc21_linking_section.tt value builders

### Circulation

- [[27847]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27847) Don't obscure page when checkin modal is non-blocking

### Command-line Utilities

- [[28749]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28749) All backups behave as if --without-db-name is passed

### Hold requests

- [[27885]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27885) Populate biblionumbers parameter when placing hold on single title
- [[28754]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28754) C4::Reserves::FixPriority creates many warns when holds have lowestPriority set
- [[28779]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28779) Calling request.pl with non-existent biblionumber gives internal server error

### MARC Bibliographic data support

- [[26852]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26852) Add missing X11$e and remove relator term subfields from MARC21 headings

### Notices

- [[28813]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28813) Fix recording and display of delivery errors for patron notices

### OPAC

- [[28469]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28469) Move "Skip to main content" link to top of page
- [[28569]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28569) In opac-suggestions.pl user library is not preselected
- [[28662]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28662) Not possible to log out of patron account in OPAC with JavaScript disabled
- [[28741]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28741) OAI ListSets does not correctly build resumption token
- [[28764]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28764) Sorting not correct in pagination on OPAC lists
- [[28861]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28861) Item type column always hidden in holds history
- [[28868]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28868) Masthead.inc is missing class name

  >This patch adds back the class 'mastheadsearch' which was lost during the upgrade to Bootstrap 4 in Bug 20168.

### REST API

- [[28632]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28632) patrons.t fragile on slow boxes

### Searching - Elasticsearch

- [[22801]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22801) Advance search yr uses copydate instead of date-of-publication

  >This fixes the advanced search form in the OPAC and staff interface so that the publication date (and range) uses the value(s) in 008 instead of 260$c when using Elasticsearch.

### Staff Client

- [[28728]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28728) Holds ratio page links to itself pointlessly
- [[28747]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28747) Clarify wording on RestrictionBlockRenewing syspref

  >This clarifies the wording for the RestrictionBlockRenewing system preference to make it clear that when set to Allow, it only allows renewal using the staff interface.
- [[28802]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28802) Untranslatable strings in browser.js
- [[28834]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28834) Improve wording biblios/authorities on tools home page

### System Administration

- [[28567]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28567) Pick-up location is not saved correctly when creating a new library

  >This fixes an issue when adding a new library - the pick-up location was always saving as "Yes", even when no was selected.
- [[28704]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28704) Library MARCOrgCode field needs maxlength attribute

  >This fixes an error that occurs when you enter a "MARC organization code" in the form for adding and editing libraries. With this change the input field is limited to 16 characters.

### Templates

- [[28689]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28689) Extra %s in alert message when saving an item

  >This removes an unnecessary %s in the alert message when there are errors in the cataloging add item form (for example when mandatory fields are not entered).
- [[28733]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28733) Desks link is in "Patrons and circ" section on admin homepage but in "Basic parameters" on the sidebar
- [[28825]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28825) Can't edit local cover image for item from details page

### Test Suite

- [[28509]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28509) Koha/Acquisition/Orders.t is failing randomly
- [[28873]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28873) Incorrect age displayed in db_dependent/Koha/Patrons.t

  >This fixes age tests in t/db_dependent/Koha/Patrons.t so that  the correct ages are calculated and displayed. It also adds the category code 'AGE_5_10' in messages to display age limits.

### Tools

- [[28336]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28336) Cannot change matching rules for authorities
- [[28525]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28525) TinyMCE for system prefs does some automatic code clean up
- [[28835]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28835) Ability to pass list contents to batch record modification broken



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/21.05/ar/html/) (34.3%)
- [Chinese (Taiwan)](https://koha-community.org/manual/21.05/zh_TW/html/) (58.7%)
- [Czech](https://koha-community.org/manual/21.05/cs/html/) (27.6%)
- [English (USA)](https://koha-community.org/manual/21.05/en/html/)
- [French](https://koha-community.org/manual/21.05/fr/html/) (49.2%)
- [French (Canada)](https://koha-community.org/manual/21.05/fr_CA/html/) (25.2%)
- [German](https://koha-community.org/manual/21.05/de/html/) (71.7%)
- [Hindi](https://koha-community.org/manual/21.05/hi/html/) (100%)
- [Italian](https://koha-community.org/manual/21.05/it/html/) (47.8%)
- [Spanish](https://koha-community.org/manual/21.05/es/html/) (34.8%)
- [Turkish](https://koha-community.org/manual/21.05/tr/html/) (40.3%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (91%)
- Armenian (99.9%)
- Armenian (Classical) (89%)
- Chinese (Taiwan) (81.6%)
- Czech (70.1%)
- English (New Zealand) (62.2%)
- English (USA)
- Finnish (80.9%)
- French (86%)
- French (Canada) (84.1%)
- German (100%)
- German (Switzerland) (61.4%)
- Greek (54.9%)
- Hindi (100%)
- Italian (92.7%)
- Nederlands-Nederland (Dutch-The Netherlands) (62.3%)
- Norwegian Bokmål (60.5%)
- Polish (95.7%)
- Portuguese (91.2%)
- Portuguese (Brazil) (87.7%)
- Russian (87.5%)
- Slovak (73.5%)
- Spanish (91.5%)
- Swedish (77.2%)
- Telugu (99.9%)
- Turkish (100%)
- Ukrainian (63.1%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 21.05.03 is


- Release Manager: Jonathan Druart

- Release Manager assistants:
  - Martin Renvoize
  - Tomás Cohen Arazi

- QA Manager: Katrin Fischer

- QA Team:
  - David Cook
  - Agustín Moyano
  - Martin Renvoize
  - Marcel de Rooy
  - Joonas Kylmälä
  - Julian Maurice
  - Tomás Cohen Arazi
  - Josef Moravec
  - Nick Clemens
  - Kyle M Hall
  - Victor Grousset

- Topic Experts:
  - UI Design -- Owen Leonard
  - REST API -- Tomás Cohen Arazi
  - Zebra -- Fridolin Somers
  - Accounts -- Martin Renvoize

- Bug Wranglers:
  - Amit Gupta
  - Mengü Yazıcıoğlu
  - Indranil Das Gupta

- Packaging Managers:
  - David Cook
  - Mason James
  - Agustín Moyano

- Documentation Manager: Caroline Cyr La Rose


- Documentation Team:
  - Marie-Luce Laflamme
  - Lucy Vaux-Harvey
  - Henry Bolshaw
  - David Nind

- Translation Managers: 
  - Indranil Das Gupta
  - Bernardo González Kriegel

- Release Maintainers:
  - 20.11 -- Fridolin Somers
  - 20.05 -- Andrew Fuerste-Henry
  - 19.11 -- Victor Grousset

## Credits

We thank the following individuals who contributed patches to Koha 21.05.03

- Tomás Cohen Arazi (3)
- Jason Boyer (1)
- Nick Clemens (17)
- David Cook (1)
- Jonathan Druart (14)
- Katrin Fischer (2)
- Andrew Fuerste-Henry (5)
- Lucas Gass (2)
- Kyle M Hall (10)
- Janusz Kaczmarek (1)
- Joonas Kylmälä (1)
- Owen Leonard (8)
- Martin Renvoize (7)
- Marcel de Rooy (4)
- Fridolin Somers (6)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 21.05.03

- Athens County Public Libraries (8)
- BibLibre (6)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (2)
- ByWater-Solutions (34)
- equinoxOLI.org (1)
- Independant Individuals (1)
- Koha Community Developers (14)
- Prosentient Systems (1)
- PTFS-Europe (7)
- Rijks Museum (4)
- Theke Solutions (3)
- University of Helsinki (1)

We also especially thank the following individuals who tested patches
for Koha

- Salman Ali (1)
- Tomás Cohen Arazi (5)
- Sara Brown (1)
- Nick Clemens (9)
- Jonathan Druart (56)
- Katrin Fischer (26)
- Andrew Fuerste-Henry (2)
- Lucas Gass (5)
- Kyle M Hall (76)
- Mark Hofstetter (1)
- Barbara Johnson (2)
- Kelly (2)
- Joonas Kylmälä (3)
- Owen Leonard (10)
- David Nind (19)
- Marcel de Rooy (12)
- Sally (1)
- Fridolin Somers (1)
- Petro Vashchuk (3)
- Wainui Witika-Park (1)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 21.05.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 24 Aug 2021 14:52:25.
