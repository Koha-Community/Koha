# RELEASE NOTES FOR KOHA 20.11.09
25 août 2021

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 20.11.09 can be downloaded from:

- [Download](http://download.koha-community.org/koha-20.11.09.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 20.11.09 is a bugfix/maintenance release with security fixes.

It includes 1 security fixes, 1 enhancements, 46 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations


## Security bugs

### Koha

- [[28784]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28784) DoS in opac-search.pl causes OOM situation and 100% CPU (doesn't require login!)


## Enhancements

### Web services

- [[28630]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28630) ILSDI::AuthenticatePatron should set borrowers.lastseen


## Critical bugs fixed

### Hold requests

- [[28057]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28057) Confusion of biblionumber and biblioitemnumber in request.pl

### OPAC

- [[28462]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28462) TT tag on several lines break the translator tool
- [[28631]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28631) Holds History title link returns "not found" error
- [[28679]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28679) Unable to click "Log in to your account" when  GoogleOpenIDConnect  is enabled

  >This fixes the login link in the OPAC when GoogleOpenIDConnect is enabled. It removes modal-related markup which was causing the link to fail.

### Tools

- [[28675]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28675) QOTD broken in 20.11 and below


## Other bugs fixed

### Acquisitions

- [[28408]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28408) Last modification date for suggestions is wrong

### Architecture, internals, and plumbing

- [[28561]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28561) Order_by triggers a DBIx warning Unable to properly collapse has_many results
- [[28570]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28570) bor_issues_top.pl using a /tmp file to log debug
- [[28620]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28620) Remove trailing space when logging with log4perl

### Cataloging

- [[28533]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28533) Requesting whole field in 'itemcallnumber' system preference causes internal server error
- [[28611]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28611) Incorrect Select2 width
- [[28727]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28727) "Edit item" button on moredetail should be enabled with edit_items permission
- [[28828]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28828) Bug 22399 breaks unimarc_field_4XX.tt and marc21_linking_section.tt value builders

### Circulation

- [[27847]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27847) Don't obscure page when checkin modal is non-blocking
- [[28455]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28455) If TrackLastPatronActivity is enabled we should update 'lastseen' field on checkouts

  >This updates the 'lastseen' date for a patron when items are checked out (when TrackLastPatronActivity is enabled). (The last seen date is displayed on the patron details page.)

### Command-line Utilities

- [[28399]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28399) batchRebuildItemsTables.pl error 'Already in a transaction'

### Hold requests

- [[27885]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27885) Populate biblionumbers parameter when placing hold on single title
- [[28644]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28644) Can't call method "borrowernumber" on an undefined value at C4/Reserves.pm line 607
- [[28754]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28754) C4::Reserves::FixPriority creates many warns when holds have lowestPriority set
- [[28779]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28779) Calling request.pl with non-existent biblionumber gives internal server error

### OPAC

- [[28469]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28469) Move "Skip to main content" link to top of page
- [[28569]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28569) In opac-suggestions.pl user library is not preselected
- [[28764]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28764) Sorting not correct in pagination on OPAC lists
- [[28868]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28868) Masthead.inc is missing class name

  >This patch adds back the class 'mastheadsearch' which was lost during the upgrade to Bootstrap 4 in Bug 20168.

### REST API

- [[28480]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28480) GET /patrons missing q parameters on the spec
- [[28604]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28604) Bad encoding when using marc-in-json
- [[28632]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28632) patrons.t fragile on slow boxes

### Reports

- [[28264]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28264) Transaction type is empty in cash register statistics wizard report

### SIP2

- [[27600]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27600) SIP2: renew_all shouldn't perform a password check
- [[27906]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27906) Add support for circulation status 9 ( waiting to be re-shelved )
- [[27907]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27907) Add support for circulation status 2 ( on order )
- [[27908]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27908) Add support for circulation status 1 ( other ) for damaged items

### Searching - Elasticsearch

- [[22801]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22801) Advance search yr uses copydate instead of date-of-publication

  >This fixes the advanced search form in the OPAC and staff interface so that the publication date (and range) uses the value(s) in 008 instead of 260$c when using Elasticsearch.

### Searching - Zebra

- [[27348]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27348) Error defining INDEXER_PARAMS in /etc/default/koha-common

### Staff Client

- [[28598]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28598) Changing date or time format on a production server will NOT create duplicate fines and we should remove the syspref warnings
- [[28728]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28728) Holds ratio page links to itself pointlessly
- [[28747]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28747) Clarify wording on RestrictionBlockRenewing syspref

  >This clarifies the wording for the RestrictionBlockRenewing system preference to make it clear that when set to Allow, it only allows renewal using the staff interface.
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

### Test Suite

- [[28516]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28516) Koha/Patrons/Import.t is failing randomly

### Tools

- [[28336]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28336) Cannot change matching rules for authorities
- [[28418]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28418) Show template_id of MARC modification templates
- [[28835]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28835) Ability to pass list contents to batch record modification broken



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/20.11/ar/html/) (27%)
- [Chinese (Taiwan)](https://koha-community.org/manual/20.11/zh_TW/html/) (61.4%)
- [English (USA)](https://koha-community.org/manual/20.11/en/html/)
- [French](https://koha-community.org/manual/20.11/fr/html/) (51.1%)
- [French (Canada)](https://koha-community.org/manual/20.11/fr_CA/html/) (26%)
- [German](https://koha-community.org/manual/20.11/de/html/) (68.3%)
- [Hindi](https://koha-community.org/manual/20.11/hi/html/) (99.9%)
- [Italian](https://koha-community.org/manual/20.11/it/html/) (50%)
- [Spanish](https://koha-community.org/manual/20.11/es/html/) (36.4%)
- [Turkish](https://koha-community.org/manual/20.11/tr/html/) (41.9%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (99.1%)
- Armenian (99.9%)
- Armenian (Classical) (89%)
- Bulgarian (91.3%)
- Catalan; Valencian (55.2%)
- Chinese (Taiwan) (93%)
- Czech (72.8%)
- English (New Zealand) (59.5%)
- English (USA)
- Finnish (79.3%)
- French (90.9%)
- French (Canada) (92.1%)
- German (100%)
- German (Switzerland) (66.8%)
- Greek (60.6%)
- Hindi (100%)
- Italian (99.9%)
- Nederlands-Nederland (Dutch-The Netherlands) (77.7%)
- Norwegian Bokmål (63.7%)
- Polish (100%)
- Portuguese (88.4%)
- Portuguese (Brazil) (95.7%)
- Russian (93.7%)
- Slovak (80.5%)
- Spanish (99.1%)
- Swedish (74.8%)
- Telugu (99.9%)
- Turkish (100%)
- Ukrainian (68%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 20.11.09 is


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

We thank the following individuals who contributed patches to Koha 20.11.09

- Tomás Cohen Arazi (3)
- Nick Clemens (17)
- David Cook (2)
- Jonathan Druart (16)
- Ivan Dziuba (1)
- Katrin Fischer (2)
- Andrew Fuerste-Henry (5)
- Lucas Gass (1)
- Victor Grousset (1)
- Kyle M Hall (6)
- Joonas Kylmälä (1)
- Owen Leonard (7)
- Martin Renvoize (7)
- Marcel de Rooy (5)
- Fridolin Somers (8)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 20.11.09

- Athens County Public Libraries (7)
- BibLibre (8)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (2)
- ByWater-Solutions (29)
- Koha Community Developers (17)
- Prosentient Systems (2)
- PTFS-Europe (7)
- Rijks Museum (5)
- Solutions inLibro inc (1)
- Theke Solutions (3)
- University of Helsinki (1)

We also especially thank the following individuals who tested patches
for Koha

- Salman Ali (1)
- Tomás Cohen Arazi (3)
- Nick Clemens (18)
- Christopher Kellermeyer - Altadena Library District (6)
- Jonathan Druart (59)
- Katrin Fischer (18)
- Andrew Fuerste-Henry (3)
- Lucas Gass (6)
- Victor Grousset (3)
- Kyle M Hall (76)
- Barbara Johnson (2)
- Kelly (1)
- Joonas Kylmälä (3)
- Owen Leonard (8)
- David Nind (16)
- Martin Renvoize (12)
- Marcel de Rooy (10)
- Sally (1)
- Fridolin Somers (72)
- Emmi Takkinen (2)
- Petro Vashchuk (3)
- Wainui Witika-Park (1)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 20.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 25 août 2021 02:19:13.
