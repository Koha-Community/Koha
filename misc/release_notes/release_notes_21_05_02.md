# RELEASE NOTES FOR KOHA 21.05.02
26 Jul 2021

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 21.05.02 can be downloaded from:

- [Download](http://download.koha-community.org/koha-21.05.02.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 21.05.02 is a bugfix/maintenance release.

It includes 1 enhancements, 51 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations




## Enhancements

### Searching

- [[28384]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28384) Add 'no_items' option to TransformMarcToKoha


## Critical bugs fixed

### OPAC

- [[28299]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28299) OpacHiddenItems not working in OPAC lists

  >This fixes an issue where items that should be hidden from display in the OPAC (using the rules in OpacHiddenItems, for example: damaged) were displayed under availability in OPAC lists.
- [[28462]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28462) TT tag on several lines break the translator tool
- [[28660]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28660) Self checkout is not automatically logging in

### Reports

- [[28523]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28523) Patrons with the most checkouts (bor_issues_top.pl) is failing with MySQL 8
- [[28524]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28524) Most-circulated items (cat_issues_top.pl) is failing with MySQL 8


## Other bugs fixed

### About

- [[28476]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28476) Update info in docs/teams.yaml file

### Architecture, internals, and plumbing

- [[28561]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28561) Order_by triggers a DBIx warning Unable to properly collapse has_many results
- [[28570]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28570) bor_issues_top.pl using a /tmp file to log debug
- [[28571]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28571) C4::Auth::_session_log is not used and must be removed

### Cataloging

- [[28513]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28513) Analytic search links formed incorrectly
- [[28542]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28542) Move new authority from Z39.50/SRU to a button

  >This makes the layout for creating new authorities consistent with creating new records - there is now a separate button 'New from Z39.50/SRU' (rather than being part of the drop-down list).
- [[28611]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28611) Incorrect Select2 width

### Circulation

- [[28455]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28455) If TrackLastPatronActivity is enabled we should update 'lastseen' field on checkouts

  >This updates the 'lastseen' date for a patron when items are checked out (when TrackLastPatronActivity is enabled). (The last seen date is displayed on the patron details page.)

### Command-line Utilities

- [[28399]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28399) batchRebuildItemsTables.pl error 'Already in a transaction'

### Fines and fees

- [[26760]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26760) Redirect to paycollect.pl when clicking on "Save and pay"
- [[28344]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28344) One should be able to issue refunds against payments that have already been cashed up.

### Hold requests

- [[28644]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28644) Can't call method "borrowernumber" on an undefined value at C4/Reserves.pm line 607

### Notices

- [[28581]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28581) Patron's queue_notice uses inbound_email_address incorrectly
- [[28582]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28582) Can't enqueue letter HASH(0x55edf1806850) at /usr/share/koha/Koha/ArticleRequest.pm line 123.

### OPAC

- [[28242]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28242) Accessibility: OPAC - add captions and legends to tables and forms

  **Sponsored by** *Catalyst*
- [[28313]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28313) Add street type to alternate address in OPAC
- [[28388]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28388) Search result set is lost when viewing the MARC plain view (opac-showmarc.pl)
- [[28422]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28422) OPAC MARC detail view doesn't correctly evaluate holdability

  >In the normal and ISBD detail views for a record in the OPAC the 'Place hold' link only appears if a hold can actually be placed. This change fixes the MARC detail view so that it is consistent with the normal and ISBD detail views. (Before this, a 'Place hold' link would appear for the MARC detail, even if a hold couldn't be placed, for example if an item was recorded as not for loan.)
- [[28511]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28511) Road types in OPAC should prefer OPAC description if one exists
- [[28545]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28545) Noisy uninitialized warn at opac-MARCdetail.pl line 313

  >This removes "..Use of uninitialized value in concatenation (.) or string at.." warning messages from the plack-opac-error.log when accessing the MARC view page for a record in the OPAC.
- [[28597]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28597) OPAC suggestions do not display news for logged in branch

### REST API

- [[28480]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28480) GET /patrons missing q parameters on the spec
- [[28604]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28604) Bad encoding when using marc-in-json

### Reports

- [[28264]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28264) Transaction type is empty in cash register statistics wizard report

### SIP2

- [[27600]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27600) SIP2: renew_all shouldn't perform a password check
- [[27906]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27906) Add support for circulation status 9 ( waiting to be re-shelved )
- [[27907]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27907) Add support for circulation status 2 ( on order )
- [[27908]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27908) Add support for circulation status 1 ( other ) for damaged items

### Searching - Zebra

- [[21286]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21286) Advanced search for Corporate-name creates Zebra errors

  >This fixes the advanced search in the staff interface so that searching using the 'Corporate name' index now works correctly when the QueryAutoTruncate system preference is not enabled. Before this a search (using Zebra) for a name such as 'House plants' would not return any results and generate error messages in the log files.
- [[27348]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27348) Error defining INDEXER_PARAMS in /etc/default/koha-common

### Staff Client

- [[28598]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28598) Changing date or time format on a production server will NOT create duplicate fines and we should remove the syspref warnings
- [[28601]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28601) Wrong breadcrumb for 'Home' on circulation-home

  >This fixes the breadcrumb link to the the staff interface home page from the circulation area - it now links correctly to the staff interface home page, rather than the circulation page.

### Templates

- [[27498]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27498) Add a link for the hold ratios to acquisitions home page

  >This enhancement adds a link to the hold ratios report in the Acquisitions sidebar menu under the reports heading.
- [[28280]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28280) Item types configuration page doesn't use Price filter for default replacement cost and processing fee

  >This fixes the display of 'Default replacement cost' and a
  >'Processing fee (when lost)' when adding item types so that amounts use two decimals instead of six.
- [[28423]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28423) JavaScript error on MARC modifications page

  >This patch makes a minor change to the MARC modifications template (Staff interface > Administration > MARC modification templates) so that the "mmtas" variable isn't defined if there is no JSON to be assigned as its value.
- [[28427]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28427) Terminology: Shelf should be list
- [[28428]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28428) Capitalization: Password Updated
- [[28443]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28443) Terminology: Issuing should be Checking out
- [[28522]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28522) Correct eslint errors in staff-global.js

### Test Suite

- [[28479]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28479) TestBuilder.pm uses incorrect method for checking if objects to be created exists
- [[28483]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28483) Warnings from Search.t must be removed
- [[28516]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28516) Koha/Patrons/Import.t is failing randomly

### Tools

- [[26205]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26205) News changes aren't logged
- [[27929]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27929) Regex option in item batch modification is hidden for itemcallnumber if 952$o linked to cn_browser plugin
- [[28191]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28191) Update wording on batch patron deletion to reflect changes from bug 26517
- [[28418]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28418) Show template_id of MARC modification templates

## New system preferences
- NewsLog



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://koha-community.org/manual/21.05/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (91%)
- Armenian (100%)
- Armenian (Classical) (89%)
- Chinese (Taiwan) (81.6%)
- Czech (70.2%)
- English (New Zealand) (62.2%)
- English (USA)
- Finnish (80.9%)
- French (86%)
- French (Canada) (84%)
- German (100%)
- German (Switzerland) (61.5%)
- Greek (54.8%)
- Hindi (100%)
- Italian (92.8%)
- Nederlands-Nederland (Dutch-The Netherlands) (62.4%)
- Norwegian Bokmål (58.2%)
- Polish (93%)
- Portuguese (79.9%)
- Portuguese (Brazil) (87.7%)
- Russian (87.3%)
- Slovak (73.5%)
- Spanish (91.5%)
- Swedish (77.3%)
- Telugu (99.9%)
- Turkish (94.3%)
- Ukrainian (62.7%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 21.05.02 is


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

- Packaging Manager:
  - Mason James

- Documentation Manager: David Nind


- Documentation Team:
  - Lucy Vaux-Harvey
  - David Nind

- Translation Managers:
  - Bernardo González Kriegel

- Release Maintainers:
  - 21.05 -- Kyle Hall
  - 20.11 -- Fridolin Somers
  - 20.05 -- Victor Grousset
  - 19.11 -- Wainui Witika-Park

## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 21.05.02:

- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)

We thank the following individuals who contributed patches to Koha 21.05.02.

- Tomás Cohen Arazi (6)
- Nick Clemens (7)
- David Cook (1)
- Jonathan Druart (17)
- Ivan Dziuba (1)
- Katrin Fischer (5)
- Andrew Fuerste-Henry (2)
- Lucas Gass (2)
- Didier Gautheron (1)
- Kyle M Hall (10)
- Mason James (1)
- Joonas Kylmälä (2)
- Owen Leonard (9)
- Julian Maurice (2)
- Martin Renvoize (10)
- Marcel de Rooy (6)
- Fridolin Somers (1)
- Wainui Witika-Park (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 21.05.02

- Athens County Public Libraries (9)
- BibLibre (4)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (5)
- ByWater-Solutions (21)
- Catalyst (1)
- Koha Community Developers (17)
- KohaAloha (1)
- Prosentient Systems (1)
- PTFS-Europe (10)
- Rijks Museum (6)
- Solutions inLibro inc (1)
- Theke Solutions (6)
- University of Helsinki (2)

We also especially thank the following individuals who tested patches
for Koha.

- Tomás Cohen Arazi (2)
- Nick Clemens (27)
- David Cook (1)
- Christopher Kellermeyer - Altadena Library District (6)
- Jonathan Druart (63)
- Magnus Enger (1)
- Katrin Fischer (18)
- Andrew Fuerste-Henry (3)
- Lucas Gass (3)
- Victor Grousset (4)
- Amit Gupta (2)
- Kyle M Hall (69)
- Barbara Johnson (1)
- Owen Leonard (5)
- David Nind (28)
- Martin Renvoize (14)
- Marcel de Rooy (13)
- Sally (1)
- Lisette Scheer (1)
- Emmi Takkinen (2)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is (HEAD detached from 694665050c).

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 26 Jul 2021 13:33:45.
