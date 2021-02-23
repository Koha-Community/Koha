# RELEASE NOTES FOR KOHA 19.11.15
23 Feb 2021

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 19.11.15 can be downloaded from:

- [Download](https://download.koha-community.org/koha-19.11.15.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 19.11.15 is a bugfix/maintenance release with security fixes.

It includes 2 security fixes, 1 new features, 9 enhancements, 30 bugfixes.

### System requirements

You can learn about the system components (like OS and database) for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations


## Security bugs

### Koha

- [[27604]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27604) PatronSelfRegistrationLibraryList can be bypassed
- [[27715]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27715) Possibly SQL injection in virtualshelves

## New features

### Staff Client

- [[14004]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14004) Add ability to temporarily disable added CSS and Javascript in OPAC and interface

  >This allows to temporarily disable any of OPACUserCSS, OPACUserJS, OpacAdditionalStylesheet, opaclayoutstylesheet, IntranetUserCSS, IntranetUserJS, intranetcolorstylesheet, and intranetstylesheet system preference via an URL parameter.
  >
  >Alter the URL in OPAC or staff interface by adding an additional parameter DISABLE_SYSPREF_<system preference name>=1. 
  >
  >Example:
  >/cgi-bin/koha/mainpage.pl?DISABLE_SYSPREF_IntranetUserCSS=1

## Enhancements

### Architecture, internals, and plumbing

- [[24254]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24254) Add Koha::Items->filter_by_visible_in_opac

  >This patch introduces an efficient way of filtering Koha::Items result sets, to hide items that that shouldn't be exposed on public interfaces.
  >
  >Filtering is governed by the following system preferences. A helper method is added to handle lost items:
  >- hidelostitems: Koha::Items->filter_out_lost is added to handle this.
  >
  >Some patrons have exceptions so OpacHiddenItems is not enforced on them. That's why the new method [1] has an optional parameter that expects the logged in patron to be passed in the call.
  >
  >[1] Koha::Items->filter_by_visible_in_opac

### Cataloging

- [[27422]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27422) HTML5Media is http by default but Youtube is https only

  **Sponsored by** *Banco Central de la República Argentina*

### Command-line Utilities

- [[24272]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24272) Add a command line script to compare the syspref cache to the database

  >This script checks the value of the system preferences in the database against those in the cache. Generally differences will only exist if changes have been made directly to the DB or the cache has become corrupted.

### Reports

- [[26713]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26713) Add pagination to bottom of saved SQL reports table

  >This enhancement adds a second pagination menu to the bottom of saved SQL reports tables.

### Searching - Elasticsearch

- [[24863]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24863) QueryFuzzy syspref says it requires Zebra but Elasticsearch has some support

### System Administration

- [[27395]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27395) Add warning to PatronSelfRegistrationDefaultCategory to avoid accidental patron deletion

  >This patch adds a warning to the PatronSelfRegistrationDefaultCategory system
  >preference to not use a regular patron category for self registration.
  >
  >If a regular patron category code is used and the cleanup_database cronjob is setup
  >to delete unverified and unfinished OPAC self registrations, it permanently and
  >and unrecoverably deletes all patrons that have registered more than
  >PatronSelfRegistrationExpireTemporaryAccountsDelay days ago.
  >
  >It also removes unnecessary apostrophes at the end of two self registration
  >and modification system preference descriptions.

### Templates

- [[26958]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26958) Move Elasticsearch mapping template JS to the footer
- [[27192]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27192) Set focus for cursor to item type input box when creating new item types
- [[27210]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27210) Typo in patron-attr-types.tt


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[27580]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27580) NULL values not correctly handled in Koha::Items->filter_by_visible_in_opac
- [[27586]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27586) Import patrons script has a confirm switch that doesn't do anything

  >This fixes the misc/import_patrons.pl script so that patrons are not imported unless the --confirm option is used. Currently, if the script is run without "--confirm" option it reports that it is "Running in dry-run mode, provide --confirm to apply the changes", however it imports the patrons anyway.
- [[27676]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27676) finesMode=off not correctly handled

### Circulation

- [[27707]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27707) Renewing doesn't work when renewal notices are enabled

### OPAC

- [[15448]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15448) Placing hold on specific items doesn't enforce OpacHiddenItems

### SIP2

- [[27196]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27196) Waiting title level hold checked in at wrong location via SIP leaves hold in a broken state and drops connection


## Other bugs fixed

### About

- [[7143]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7143) Bug for tracking changes to the about page

### Acquisitions

- [[27547]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27547) Typo in parcel.tt

### Architecture, internals, and plumbing

- [[27179]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27179) Misspelling of Method in REST API files

  >This fixes the misspelling of Method (Mehtod to Method) in REST API files.
- [[27327]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27327) Indirect object notation in Koha::Club::Hold
- [[27333]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27333) Wrong exception thrown in Koha::Club::Hold::add

### Cataloging

- [[27308]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27308) Advanced editor should skip blank lines when inserting new fields

### Circulation

- [[27011]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27011) Warnings in returns.pl

  >This patch removes a variable ($name) that is no longer used in Circulation > Check in (/cgi-bin/koha/circ/returns.pl), and the resulting warnings (..[WARN] Use of uninitialized value in concatenation (.) or string at..) that were recorded in the error log.
- [[27548]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27548) Warnings "use of uninitialized value" on branchoverdues.pl

  >This fixes the cause of unnecessary "use of uninitialized value" warnings in the log files generated by Circulation > Overdues with fines (/cgi-bin/koha/circ/branchoverdues.pl).
  >
  >This was caused by not taking into account that the "location" parameter for this form is initially empty.
- [[27549]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27549) Warning "use of uninitialized value" on renew.pl

  >This fixes the cause of unnecessary "use of uninitialized value" warnings in the log files generated by Circulation > Renew (/cgi-bin/koha/circ/renew.pl).
  >
  >This was caused by not taking into account that the "barcode" parameter for this form is initially empty.

### Command-line Utilities

- [[11344]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11344) Perldoc issues in misc/cronjobs/advance_notices.pl
- [[17429]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17429) Document the --plack option for koha-list

### Fines and fees

- [[20527]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20527) <label> linked to the wrong <input> (wrong "for" attribute) in paycollect.tt

  >This fixes the HTML <label for=""> element for the Writeoff amount field on the Accounting > Make a payment form for a patron - changes "paid" to "amountwrittenoff".

### I18N/L10N

- [[27416]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27416) String 'Modify tag' in breadcrumb is untranslatable

### Installation and upgrade (web-based installer)

- [[24810]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24810) French SQL files for "news" contain "Welcome into Koha 3!"

  >This removes the Koha version number from the sample news items for the French language installer files (fr-FR and fr-CA).
- [[24811]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24811) French SQL files for "news" contain broken link to the wiki

  >This fixes a broken link in the sample news items for the French language installer files (fr-FR and fr-CA).

### Notices

- [[24447]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24447) POD of C4::Members::Messaging::GetMessagingPreferences() is misleading

### OPAC

- [[27450]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27450) Making password required for patron registration breaks patron modification

### Searching - Zebra

- [[27299]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27299) Zebra phrase register is incorrectly tokenized when using ICU

  >Previously, Zebra indexing in ICU mode was incorrectly tokenizing text for the "p" register. This meant that particular phrase searches were not working as expected. With this change, phrase searching works the same in ICU and CHR modes.

### Templates

- [[20238]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20238) Show description of ITEMTYPECAT instead of code in itemtypes summary table

  >This enhancement changes the item types page (Koha administration > Basic parameters > Item types) so that the search category column displays the ITEMTYPECAT authorized value's description, instead of the authorized value code. (This makes it consistent with the edit form where it displays the descriptions for authorized values.)
- [[27457]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27457) Set focus for cursor to Debit type code field when creating new debit type
- [[27531]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27531) Remove type attribute from script tags: Cataloging plugins

### Test Suite

- [[27554]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27554) Clarify and add tests for Koha::Patrons->update_category_to child to adult

### Tools

- [[26298]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26298) If MaxItemsToProcessForBatchMod is set to 1000, the max is actually 999
- [[27576]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27576) Don't show import records table when cleaning a batch


## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha 
documentation is 

- [Koha Documentation](https://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](https://koha-community.org/manual/19.11/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (98%)
- Armenian (99.9%)
- Armenian (Classical) (100%)
- Basque (55.7%)
- Catalan; Valencian (50.6%)
- Chinese (China) (56.9%)
- Chinese (Taiwan) (98.6%)
- Czech (90.8%)
- English (New Zealand) (78.3%)
- English (USA)
- Finnish (74.3%)
- French (96.9%)
- French (Canada) (93.8%)
- German (100%)
- German (Switzerland) (80.8%)
- Greek (71.2%)
- Hindi (100%)
- Italian (87.1%)
- Nederlands-Nederland (Dutch-The Netherlands) (79.9%)
- Norwegian Bokmål (83.4%)
- Occitan (post 1500) (53%)
- Polish (78.5%)
- Portuguese (99.4%)
- Portuguese (Brazil) (99.4%)
- Slovak (83.1%)
- Spanish (99.8%)
- Swedish (85%)
- Telugu (95.6%)
- Turkish (100%)
- Ukrainian (74.5%)
- Vietnamese (51.5%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](https://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](https://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](https://translate.koha-community.org/)

## Release Team

The release team for Koha 19.11.15 is


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
  - Kyle Hall
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
We thank the following libraries who are known to have sponsored
new features in Koha 19.11.15:

- Banco Central de la República Argentina

We thank the following individuals who contributed patches to Koha 19.11.15.

- Tomás Cohen Arazi (14)
- Eden Bacani (3)
- Nick Clemens (7)
- David Cook (1)
- Jonathan Druart (18)
- Victor Grousset (2)
- Kyle M Hall (2)
- Mazen Khallaf (2)
- Amy King (2)
- Joonas Kylmälä (1)
- Owen Leonard (3)
- Ava Li (2)
- Catherine Ma (1)
- James O'Keeffe (1)
- Martin Renvoize (1)
- Marcel de Rooy (2)
- Caroline Cyr La Rose (1)
- Andreas Roussos (2)
- Lisette Scheer (1)
- Fridolin Somers (2)
- Koha Translators (1)
- Petro Vashchuk (2)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 19.11.15

- Athens County Public Libraries (3)
- BibLibre (2)
- ByWater-Solutions (9)
- Dataly Tech (2)
- gamil.com (2)
- Independant Individuals (11)
- Koha Community Developers (20)
- Latah County Library District (1)
- Prosentient Systems (1)
- PTFS-Europe (1)
- Rijks Museum (2)
- Solutions inLibro inc (1)
- Theke Solutions (14)
- University of Helsinki (1)

We also especially thank the following individuals who tested patches
for Koha.

- Nick Clemens (9)
- David Cook (2)
- Jonathan Druart (42)
- Katrin Fischer (22)
- Andrew Fuerste-Henry (62)
- Lucas Gass (2)
- Victor Grousset (63)
- Kyle M Hall (12)
- Sally Healey (1)
- Barbara Johnson (4)
- Mazen Khallaf (1)
- Joonas Kylmälä (6)
- Owen Leonard (4)
- Kelly McElligott (1)
- David Nind (11)
- Andrew Nugged (1)
- Martin Renvoize (23)
- Marcel de Rooy (8)
- Fridolin Somers (56)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 19.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 23 Feb 2021 21:16:25.
