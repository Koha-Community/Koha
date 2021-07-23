# RELEASE NOTES FOR KOHA 20.11.08
23 Jul 2021

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 20.11.08 can be downloaded from:

- [Download](https://download.koha-community.org/koha-20.11.08.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 20.11.08 is a bugfix/maintenance release.

It includes 19 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations






## Critical bugs fixed

### REST API

- [[28586]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28586) Cannot resolve a claim

  >This fixes an issue with the 'Returned claims' feature (enabled by setting a value for ClaimReturnedLostValue)- resolving returned claims now works as expected.
  >
  >Before this fix, an attempt to resolve a claim resulted in the page hanging and the claim not being able to be resolved.

### Reports

- [[28523]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28523) Patrons with the most checkouts (bor_issues_top.pl) is failing with MySQL 8
- [[28524]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28524) Most-circulated items (cat_issues_top.pl) is failing with MySQL 8


## Other bugs fixed

### About

- [[28476]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28476) Update info in docs/teams.yaml file

### Cataloging

- [[28513]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28513) Analytic search links formed incorrectly
- [[28542]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28542) Move new authority from Z39.50/SRU to a button

  >This makes the layout for creating new authorities consistent with creating new records - there is now a separate button 'New from Z39.50/SRU' (rather than being part of the drop-down list).

### Fines and fees

- [[28344]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28344) One should be able to issue refunds against payments that have already been cashed up.

### Notices

- [[28582]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28582) Can't enqueue letter HASH(0x55edf1806850) at /usr/share/koha/Koha/ArticleRequest.pm line 123.

### OPAC

- [[28388]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28388) Search result set is lost when viewing the MARC plain view (opac-showmarc.pl)
- [[28422]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28422) OPAC MARC detail view doesn't correctly evaluate holdability

  >In the normal and ISBD detail views for a record in the OPAC the 'Place hold' link only appears if a hold can actually be placed. This change fixes the MARC detail view so that it is consistent with the normal and ISBD detail views. (Before this, a 'Place hold' link would appear for the MARC detail, even if a hold couldn't be placed, for example if an item was recorded as not for loan.)
- [[28545]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28545) Noisy uninitialized warn at opac-MARCdetail.pl line 313

  >This removes "..Use of uninitialized value in concatenation (.) or string at.." warning messages from the plack-opac-error.log when accessing the MARC view page for a record in the OPAC.

### Searching - Zebra

- [[21286]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21286) Advanced search for Corporate-name creates Zebra errors

  >This fixes the advanced search in the staff interface so that searching using the 'Corporate name' index now works correctly when the QueryAutoTruncate system preference is not enabled. Before this a search (using Zebra) for a name such as 'House plants' would not return any results and generate error messages in the log files.

### Templates

- [[28280]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28280) Item types configuration page doesn't use Price filter for default replacement cost and processing fee

  >This fixes the display of 'Default replacement cost' and a
  >'Processing fee (when lost)' when adding item types so that amounts use two decimals instead of six.
- [[28423]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28423) JavaScript error on MARC modifications page

  >This patch makes a minor change to the MARC modifications template (Staff interface > Administration > MARC modification templates) so that the "mmtas" variable isn't defined if there is no JSON to be assigned as its value.
- [[28427]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28427) Terminology: Shelf should be list
- [[28522]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28522) Correct eslint errors in staff-global.js

### Test Suite

- [[28479]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28479) TestBuilder.pm uses incorrect method for checking if objects to be created exists

### Tools

- [[27929]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27929) Regex option in item batch modification is hidden for itemcallnumber if 952$o linked to cn_browser plugin
- [[28191]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28191) Update wording on batch patron deletion to reflect changes from bug 26517



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/20.11/ar/html/) (27%)
- [Chinese (Taiwan)](https://koha-community.org/manual/20.11/zh_TW/html/) (61.4%)
- [English (USA)](https://koha-community.org/manual/20.11/en/html/)
- [French](https://koha-community.org/manual/20.11/fr/html/) (50.8%)
- [French (Canada)](https://koha-community.org/manual/20.11/fr_CA/html/) (25.9%)
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

- Arabic (99.2%)
- Armenian (100%)
- Armenian (Classical) (89%)
- Bulgarian (91.2%)
- Catalan; Valencian (54.7%)
- Chinese (Taiwan) (92.9%)
- Czech (72.8%)
- English (New Zealand) (59.4%)
- English (USA)
- Finnish (79.2%)
- French (90.9%)
- French (Canada) (90.8%)
- German (100%)
- German (Switzerland) (66.7%)
- Greek (60.6%)
- Hindi (100%)
- Italian (99.9%)
- Nederlands-Nederland (Dutch-The Netherlands) (75.3%)
- Norwegian Bokmål (63.6%)
- Polish (100%)
- Portuguese (88.2%)
- Portuguese (Brazil) (95.6%)
- Russian (93.7%)
- Slovak (80.5%)
- Spanish (99.1%)
- Swedish (74.7%)
- Telugu (100%)
- Turkish (99.9%)
- Ukrainian (67.8%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](https://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](https://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](https://translate.koha-community.org/)

## Release Team

The release team for Koha 20.11.08 is


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
  - Nick Clemens
  - Kyle M Hall
  - Victor Grousset
  - Andrew Nugged
  - Petro Vashchuk

- Topic Experts:
  - UI Design -- Owen Leonard
  - REST API -- Tomás Cohen Arazi
  - Elasticsearch -- Fridolin Somers
  - Zebra -- Fridolin Somers
  - Accounts -- Martin Renvoize

- Bug Wranglers:
  - Sally Healey

- Packaging Manager: Mason James


- Documentation Manager: David Nind


- Documentation Team:
  - Lucy Vaux-Harvey
  - David Nind

- Translation Managers: 
  - Bernardo González Kriegel

- Wiki curators: 
  - Thomas Dukleth

- Release Maintainers:
  - 21.05 -- Kyle M Hall
  - 20.11 -- Fridolin Somers
  - 20.05 -- Victor Grousset
  - 19.11 -- Wainui Witika-Park

- Release Maintainer assistants:
  - 21.05 -- Nick Clemens

- Release Maintainer mentors:
  - 19.11 -- Aleisha Amohia

## Credits

We thank the following individuals who contributed patches to Koha 20.11.08

- Tomás Cohen Arazi (2)
- Nick Clemens (2)
- Jonathan Druart (4)
- Katrin Fischer (1)
- Didier Gautheron (1)
- Victor Grousset (2)
- Mason James (1)
- Joonas Kylmälä (2)
- Owen Leonard (4)
- Martin Renvoize (1)
- Marcel de Rooy (2)
- Fridolin Somers (1)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 20.11.08

- Athens County Public Libraries (4)
- BibLibre (2)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (1)
- ByWater-Solutions (2)
- Koha Community Developers (6)
- KohaAloha (1)
- PTFS-Europe (1)
- Rijks Museum (2)
- Theke Solutions (2)
- University of Helsinki (2)

We also especially thank the following individuals who tested patches
for Koha

- Nick Clemens (9)
- Jonathan Druart (15)
- Magnus Enger (1)
- Katrin Fischer (5)
- Andrew Fuerste-Henry (4)
- Victor Grousset (2)
- Kyle M Hall (23)
- Owen Leonard (3)
- David Nind (13)
- Martin Renvoize (1)
- Marcel de Rooy (2)
- Sally (1)
- Fridolin Somers (18)



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

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 23 Jul 2021 11:35:40.
