# RELEASE NOTES FOR KOHA 22.05.02
27 Jun 2022

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 22.05.02 can be downloaded from:

- [Download](http://download.koha-community.org/koha-22.05.02.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 22.05.02 is a bugfix/maintenance release.

It includes 5 enhancements, 48 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations




## Enhancements

### Architecture, internals, and plumbing

- [[29883]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29883) Uninitialized value warning when GetAuthorisedValues gets called with no parameters
- [[30830]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30830) Add Koha Objects  for Koha Import Items

### I18N/L10N

- [[30733]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30733) Simplify translatable strings

  >Cleanup of translatable text done by guiding the string extractor to make it do simpler strings for translators instead of large concatenation of long strings in the code with a lot of unnecessary %s placeholders.

### Templates

- [[30523]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30523) Quiet console warning about missing shortcut-buttons map file
- [[30786]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30786) Capitalization in (Opac)AdvancedSearchTypes

  >This fixes the descriptions for the AdvancedSearchTypes and OpacAdvancedSearchTypes system preferences - sentence case is now used for "..Shelving location..".


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[30876]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30876) recalls/recalls_to_pull.pl introduces an incorrect use of ->search in list context

### Cataloging

- [[30234]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30234) Serial local covers don't appear in the staff interface for other libraries with SeparateHoldings

  >This fixes the display of item-specific local cover images in the staff interface. Before this, item images were not shown for holdings on the record's details view page.

### Circulation

- [[30885]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30885) Recall - detail page explosion

  **Sponsored by** *Catalyst*
- [[30886]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30886) Recall status cannot be correct on OPAC detail page

  **Sponsored by** *Catalyst*
- [[30907]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30907) Remaining incorrect uses of Koha::Recall->item_level_recall
- [[30971]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30971) Recalls - log viewer error

  >This fixes an error that occurred when viewing recalls log entries. The error was caused by the renaming of itemnumber, biblionumber, and branchcode attributes.

### Command-line Utilities

- [[29325]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29325) commit_file.pl error 'Already in a transaction'

  >This fixes the command line script misc/commit_file.pl and manage staged MARC records tool in the staff interface so that imported records are processed.
  >
  >The error message from The command line script was failing with this error message "DBIx::Class::Storage::DBI::_exec_txn_begin(): DBI Exception: DBD::mysql::db begin_work failed: Already in a transaction at /kohadevbox/koha/C4/Biblio.pm line 303". In the staff interface, the processing of staged records would fail without any error messages.

### Database

- [[30899]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30899) Upgrade sometimes fails at "Upgrade to 21.11.05.004"

  >This database revision fixes the one from bug 30449 for table borrower_attribute_types.
- [[30912]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30912) Database update fails for 21.12.00.016 Bug 30060

### Hold requests

- [[30742]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30742) Confusion when placing hold on record with no items available because of not for loan
- [[30892]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30892) Holds not getting placed
- [[30960]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30960) Koha lets you place item-level holds without a pick-up place

### Patrons

- [[30868]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30868) Modifying a patron - page not found error after fixing validation errors where the message is displayed at the top of the page

  >This fixes a page not found error message generated after fixing validation errors when editing a patron (where the validation/error message is shown at the top of the page - below the patron name, but before the Save and Cancel buttons). (This was introduced by bug 29684: Fix warn about js/locale_data.js in 22.05.)
- [[31005]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31005) Cannot edit patrons in other categories if an extended attribute is mandatory and limited to a category

  >This fixes an error when a mandatory patron attribute limited to a specific patron category was causing a '500 error' when editing a patron not in that category.

### Searching - Elasticsearch

- [[30883]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30883) Authorities merge is limited to 100 biblio with Elasticsearch

  >This fixes the hard-coded limit of 100 when merging authorities (when Elasticsearch is the search engine). When merging authorities where the term is used over 100 times, only the first 100 authorities would be merged and the old term deleted, irrespective of the value set in the AuthorityMergeLimit system preference.

### Tools

- [[29828]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29828) If no content is added to default, but a translation, news/additional content entries don't show in list
- [[30831]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30831) Add unit test for BatchCommitItems
- [[30884]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30884) Incomplete replace of jQuery UI tabs in batch patron modification breaks the form sending
- [[30972]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30972) "Replace existing covers" checkbox replaces ALL local covers for a biblio, not only the specific item's covers


## Other bugs fixed

### Acquisitions

- [[29961]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29961) Horizontal scroll bar in acquisition z39.50 search should always show

### Architecture, internals, and plumbing

- [[30731]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30731) Noise from about script coming from Test::MockTime (or other CPAN modules)

### Authentication

- [[30842]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30842) Two-factor  authentication code should be valid longer

  >This extends the time a two-factor authentication code is valid for, in case it is not entered quickly enough. (Example: wait for the code to change, then enter the previous code - this should still work, but will not work when the code changes again.)

### Circulation

- [[30337]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30337) Holds to Pull ( pendingreserves.pl ) ignores holds if priority 1 hold is suspended

### Command-line Utilities

- [[30781]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30781) Use of uninitialized value $val in substitution iterator at /usr/share/koha/lib/C4/Letters.pm line 665.
- [[30788]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30788) Argument "" isn't numeric in multiplication (*) at /usr/share/koha/lib/C4/Overdues.pm
- [[30893]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30893) Typo: update_patrons_category.pl fine(s)

  >This updates the help text for the update patrons category cronjob script (misc/cronjobs/update_patrons_category.pl). It changes the full option names and associated information for -fo (--fineover to --finesover) and -fu (--fineunder to --finesunder), as well as some minor formatting and text tidy ups.

### Course reserves

- [[30840]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30840) Add support for barcode filters to course reserves

### Hold requests

- [[23659]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23659) Allow hold pickup location to default to item home branch for item-level holds

  >This patch adds a new system preference 'DefaultHoldPickupLocation'
  >
  >This preference will allow the library to determine which library is the default for pickup location dropdowns while placing holds in the staff client. The options are logged in library, homebranch, or holdingbranch
  >
  >Previously the behavior was inconsistent, and varied between versions. Libraries may need to adjust this preference after upgrade to mirror their expected workflow
- [[28529]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28529) Item type-constrained biblio-level holds should honour max_holds as item-level do
- [[30828]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30828) Remove unused variable in placerequest.pl

### OPAC

- [[30746]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30746) JS error on 'your personal details' in OPAC
- [[30844]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30844) The OPAC detail page's browser is limited to the current page of results when using Elasticsearch

  **Sponsored by** *Lund University Library*

### REST API

- [[30853]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30853) Missing description for 'baskets' in swagger.yaml
- [[30854]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30854) Missing description for 'import_record_matches' in swagger.yaml
- [[30855]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30855) Rename /import => /import_batches

### Searching

- [[27697]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27697) Opening bibliographic record page prepopulates search bar text

### Searching - Zebra

- [[30528]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30528) Limits are not correctly parsed when query contains CCL

### Staff Client

- [[28723]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28723) Holds table not displayed when it contains a biblio without title

### System Administration

- [[30862]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30862) Typo: langues

### Templates

- [[30629]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30629) <span> in title of patron card creator template needs to be removed

  >This removes <span> tags incorrectly displaying in browser page titles for some pages in the staff interface (Tools > Patron card creator > Layouts; Tools > Label creator > Manage > Label batches; Administration > Budgets administration > select a budget > Plan by ...).
- [[30726]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30726) Flatpickr's "yesterday" shortcut doesn't work if entry is limited to past dates
- [[30761]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30761) Typo: PLease
- [[30772]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30772) Terminology: Replace instances of "reserve" with "hold"
- [[30774]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30774) Typo: i %sEdit %sReserve %s

### Test Suite

- [[29860]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29860) Useless warnings in regressions.t
- [[30756]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30756) Get skip block out of Koha_Authority.t and add TestBuilder
- [[30870]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30870) Don't skip tests if Test::Deep is not installed

### Tools

- [[28152]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28152) Hidden error when importing an item with an existing itemnumber

## New system preferences
- DefaultHoldPickupLocation



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)



The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (78.7%)
- Armenian (100%)
- Armenian (Classical) (71.6%)
- Bulgarian (82.7%)
- Chinese (Taiwan) (79.9%)
- Czech (62.6%)
- English (New Zealand) (56.7%)
- English (USA)
- Finnish (95.7%)
- French (96.4%)
- French (Canada) (86.2%)
- German (100%)
- German (Switzerland) (54.7%)
- Greek (53.5%)
- Hindi (90.9%)
- Italian (91.7%)
- Nederlands-Nederland (Dutch-The Netherlands) (79.5%)
- Norwegian Bokmål (56%)
- Polish (87.9%)
- Portuguese (80.1%)
- Portuguese (Brazil) (76.9%)
- Russian (78.2%)
- Slovak (64.3%)
- Spanish (98.3%)
- Swedish (77%)
- Telugu (85.6%)
- Turkish (90.3%)
- Ukrainian (68.5%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 22.05.02 is

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

- Packaging Manager: Mason James


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
new features in Koha 22.05.02

- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)
- Lund University Library

We thank the following individuals who contributed patches to Koha 22.05.02

- Aleisha Amohia (2)
- Tomás Cohen Arazi (17)
- Kevin Carnes (2)
- Nick Clemens (14)
- Jonathan Druart (12)
- Katrin Fischer (2)
- Lucas Gass (3)
- Victor Grousset (2)
- Kyle M Hall (1)
- Joonas Kylmälä (1)
- Owen Leonard (4)
- Julian Maurice (2)
- David Nind (2)
- Marcel de Rooy (7)
- Caroline Cyr La Rose (1)
- Slava Shishkin (1)
- Fridolin Somers (3)
- Koha translators (1)
- Petro Vashchuk (2)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 22.05.02

- Athens County Public Libraries (4)
- BibLibre (5)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (2)
- ByWater-Solutions (18)
- Catalyst Open Source Academy (2)
- David Nind (2)
- Independant Individuals (4)
- Koha Community Developers (14)
- Rijksmuseum (7)
- Solutions inLibro inc (1)
- Theke Solutions (17)
- ub.lu.se (2)

We also especially thank the following individuals who tested patches
for Koha

- Tomás Cohen Arazi (58)
- Nick Clemens (10)
- Paul Derscheid (1)
- Jonathan Druart (13)
- Katrin Fischer (16)
- Andrew Fuerste-Henry (1)
- Lucas Gass (78)
- Victor Grousset (5)
- Sally Healey (1)
- Joonas Kylmälä (8)
- David Nind (45)
- Martin Renvoize (29)
- Jason Robb (1)
- Marcel de Rooy (6)
- Caroline Cyr La Rose (1)
- Fridolin Somers (2)



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

Autogenerated release notes updated last on 27 Jun 2022 15:28:28.
