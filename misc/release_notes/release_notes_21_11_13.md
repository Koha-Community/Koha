# RELEASE NOTES FOR KOHA 21.11.13
22 Oct 2022

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 21.11.13 can be downloaded from:

- [Download](http://download.koha-community.org/koha-21.11.13.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 21.11.13 is a bugfix/maintenance release.

It includes 9 enhancements, 35 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations




## Enhancements

### Command-line Utilities

- [[31155]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31155) Document --since option in help of borrowers-force-messaging-defaults.pl

  >This enhancement adds a brief explanation of the --since option for borrowers-force-messaging-defaults.pl.

### I18N/L10N

- [[30028]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30028) Patron message delete confirmation untranslatable

  >This fixes the patron delete messages dialogue box to make the message shown translatable.

### OPAC

- [[31217]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31217) Fix Coce JavaScript to hide single-pixel cover images in the OPAC lightbox gallery

  **Sponsored by** *Toi Ohomai Institute of Technology, New Zealand*
- [[31294]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31294) Article requests: Mandatory subfields in OPAC don't show they are required

### Searching

- [[22605]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22605) Adding the option to modify/edit searches on the staff interface

### Staff Client

- [[28864]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28864) The patron search results in the patron card creator doesn't seem to use PatronsPerPage syspref

### System Administration

- [[31289]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31289) Hide Article requests column in circulation rules when ArticleRequests syspref is disabled

### Templates

- [[31228]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31228) Fix Coce JavaScript to hide single-pixel cover images in both the staff client detail and results pages

  **Sponsored by** *Catalyst IT, New Zealand*
- [[31425]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31425) Minor correction to patron categories admin title


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[31245]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31245) Job detail view for batch mod explode if job not started

### Circulation

- [[29012]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29012) Some rules are not saved when left blank while editing a 'rule' line in smart-rules.pl

### Command-line Utilities

- [[29325]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29325) commit_file.pl error 'Already in a transaction'

  >This fixes the command line script misc/commit_file.pl and manage staged MARC records tool in the staff interface so that imported records are processed.
  >
  >The error message from The command line script was failing with this error message "DBIx::Class::Storage::DBI::_exec_txn_begin(): DBI Exception: DBD::mysql::db begin_work failed: Already in a transaction at /kohadevbox/koha/C4/Biblio.pm line 303". In the staff interface, the processing of staged records would fail without any error messages.

### Installation and upgrade (command-line installer)

- [[31673]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31673) DB update of bug 31086 fails: Cannot change column 'branchcode': used in a foreign key constraint

### OPAC

- [[29782]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29782) Additional contents: Fix handling records without title or content

### Searching - Elasticsearch

- [[31076]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31076) Bug 22605 breaks date of publication range search

  >This fixes the date of publication range searching in the staff interface when using Elasticsearch. It was working in the OPAC, but not the staff interface - caused by a regression from Bug 22605 introduced in Koha 22.05. For example: a search for 2005-2010 in the staff interface advanced search will now display the same results as the OPAC.


## Other bugs fixed

### Architecture, internals, and plumbing

- [[27849]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27849) Koha::Token may access undefined C4::Context->userenv
- [[30468]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30468) koha-mysql does not honor Koha's timezone setting
- [[30984]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30984) Action logs should log the cronjob script name that generated the given log
- [[31222]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31222) DBIC queries for batch mod can be very large
- [[31390]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31390) Remove noisy warns in C4::Templates
- [[31473]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31473) Test about bad OpacHiddenItems conf fragile

### Cataloging

- [[30797]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30797) Subfields linked to the dateaccessioned.pl value builder on addbiblio.pl throw a JS error

  **Sponsored by** *Chartered Accountants Australia and New Zealand*
- [[30976]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30976) Cover images for biblio should be displayed first

### Command-line Utilities

- [[31282]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31282) Broken characters in patron_emailer.pl verbose mode

  >This fixes the patron_emailer.pl script (misc/cronjobs/patron_emailer.pl) so that non-ASCII characters in notices display correctly.
- [[31325]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31325) Fix koha-preferences get

### Hold requests

- [[19540]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19540) opac-reserve does not correctly warn of too_much reserves

### I18N/L10N

- [[28707]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28707) Missing strings in translation of sample data
- [[31292]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31292) Untranslatable string in sample_notices.yaml

### Label/patron card printing

- [[31352]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31352) Terminology: Borrower name

  **Sponsored by** *Catalyst IT, New Zealand*

  >This updates the table heading name from "Borrower name" to "Patron name" when adding a new batch in the patron card creator.

### MARC Authority data support

- [[29434]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29434) In UNIMARC instances, the authority finder uses MARC21 relationship codes

  >This fixes the values displayed for the relationship codes in the authority finder 'Special relationships' drop down list in UNIMARC catalogs - UNIMARC values are now displayed, instead of MARC21 values.

### MARC Bibliographic record staging/import

- [[26632]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26632) BatchStageMarcRecords passes a random number to AddBiblioToBatch / AddAuthToBatch

### Notices

- [[31281]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31281) Overdue notices reply-to email address of a branch not respected

### OPAC

- [[31272]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31272) Show library name not code when placing item level holds in OPAC
- [[31346]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31346) On the OPAC detail page some Syndetics links are wrong
- [[31387]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31387) Marking othernames as required via PatronSelfRegistrationBorrowerMandatoryField does not display required label

  >This fixes the patron self-registration form so that the 'Other names' (othernames) field correctly displays the text 'Required' when this is set as required (using the PatronSelfRegistrationBorrowerMandatoryField system preference). Currently, this text is not displayed (however, an error message is displayed when submitting the form).

### Packaging

- [[31348]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31348) Plack stop should be graceful

### Reports

- [[31276]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31276) Report results are limited to 999,999 no matter the actual number of results

### SIP2

- [[31033]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31033) SIP2 configuration does not correctly handle multiple simultaneous connections by default

### Staff Client

- [[30499]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30499) Keyboard shortcuts broken on several pages
- [[31251]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31251) "Clear" patron attribute link does not work

### System Administration

- [[31249]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31249) update_patrons_category.pl cron does not log to action_logs

### Templates

- [[31302]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31302) Spelling: You can download the scanned materials via the following url(s):

  **Sponsored by** *Catalyst IT, New Zealand*

### Tools

- [[28327]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28327) System preference CSVdelimiter special case for tabulation

  >This fixes the CSV export so that data is correctly exported with a tab (\t) as the separator when this format is selected. This was incorrectly using the word 'tabulation' as the separator. (The default export format is set using the CSVdelimiter system preference.) In addition, the code where this is used was simplified (including several of the default reports, item search export, and the log viewer), and the default for CSVdelimiter was set to the comma separator.
- [[30779]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30779) Do not need to remove items from import biblios marc



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/21.11/ar/html/) (33.8%)
- [Chinese (Taiwan)](https://koha-community.org/manual/21.11/zh_TW/html/) (58.8%)
- [Czech](https://koha-community.org/manual/21.11/cs/html/) (27.2%)
- [English (USA)](https://koha-community.org/manual/21.11/en/html/)
- [French](https://koha-community.org/manual/21.11/fr/html/) (68.8%)
- [French (Canada)](https://koha-community.org/manual/21.11/fr_CA/html/) (25.6%)
- [German](https://koha-community.org/manual/21.11/de/html/) (73.3%)
- [Hindi](https://koha-community.org/manual/21.11/hi/html/) (100%)
- [Italian](https://koha-community.org/manual/21.11/it/html/) (48.2%)
- [Spanish](https://koha-community.org/manual/21.11/es/html/) (36.1%)
- [Turkish](https://koha-community.org/manual/21.11/tr/html/) (39.6%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (86.7%)
- Armenian (100%)
- Armenian (Classical) (89%)
- Bulgarian (100%)
- Chinese (Taiwan) (78.9%)
- Czech (76.7%)
- English (New Zealand) (58.7%)
- English (USA)
- Finnish (98.9%)
- French (95.2%)
- French (Canada) (92.2%)
- German (100%)
- German (Switzerland) (58.3%)
- Greek (60.4%)
- Hindi (100%)
- Italian (100%)
- Nederlands-Nederland (Dutch-The Netherlands) (86.6%)
- Norwegian Bokmål (62.7%)
- Polish (100%)
- Portuguese (91.1%)
- Portuguese (Brazil) (83.1%)
- Russian (84.2%)
- Slovak (74.6%)
- Spanish (99.6%)
- Swedish (81.6%)
- Telugu (94.4%)
- Turkish (99%)
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

The release team for Koha 21.11.13 is


- Release Manager: Jonathan Druart

- Release Manager assistants:
  - Martin Renvoize
  - Tomás Cohen Arazi

- QA Manager: Katrin Fischer

- QA Team:
  - Agustín Moyano
  - Andrew Nugged
  - David Cook
  - Joonas Kylmälä
  - Julian Maurice
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
  - Elasticsearch -- Fridolin Somers
  - Zebra -- Fridolin Somers
  - Accounts -- Martin Renvoize

- Bug Wranglers:
  - Sally Healey

- Packaging Manager: 


- Documentation Manager: David Nind


- Documentation Team:
  - David Nind
  - Lucy Vaux-Harvey

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
We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 21.11.13

- [Catalyst IT, New Zealand](https://www.catalyst.net.nz/products/library-management-koha)
- Chartered Accountants Australia and New Zealand
- Toi Ohomai Institute of Technology, New Zealand

We thank the following individuals who contributed patches to Koha 21.11.13

- Tomás Cohen Arazi (7)
- Alex Buckley (5)
- Kevin Carnes (1)
- Nick Clemens (11)
- David Cook (4)
- Jonathan Druart (3)
- Magnus Enger (1)
- Katrin Fischer (3)
- Lucas Gass (5)
- Michael Hafen (1)
- Kyle M Hall (5)
- Bernardo González Kriegel (2)
- Owen Leonard (2)
- Tim McMahon (1)
- MJ Ray (1)
- Marcel de Rooy (3)
- Caroline Cyr La Rose (2)
- Andreas Roussos (1)
- Fridolin Somers (4)
- Arthur Suzuki (5)
- Koha translators (1)
- Shi Yao Wang (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 21.11.13

- Athens County Public Libraries (2)
- BibLibre (9)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (3)
- ByWater-Solutions (21)
- Catalyst (5)
- Dataly Tech (1)
- Independant Individuals (1)
- Koha Community Developers (3)
- Libriotech (1)
- Prosentient Systems (4)
- Rijksmuseum (3)
- Software.coop (1)
- Solutions inLibro inc (3)
- Theke Solutions (7)
- ub.lu.se (1)
- Universidad Nacional de Córdoba (2)
- wlpl.org (1)

We also especially thank the following individuals who tested patches
for Koha

- Andrew (4)
- Tomás Cohen Arazi (46)
- Nason Bimbe (1)
- Nick Clemens (5)
- Paul Derscheid (2)
- Jonathan Druart (8)
- Katrin Fischer (16)
- Andrew Fuerste-Henry (3)
- Lucas Gass (45)
- Kyle M Hall (10)
- Sally Healey (1)
- Barbara Johnson (1)
- Joonas Kylmälä (1)
- Rachael Laritz (2)
- Owen Leonard (7)
- David Nind (12)
- Liz Rea (1)
- Martin Renvoize (15)
- Marcel de Rooy (6)
- Caroline Cyr La Rose (2)
- Fridolin Somers (11)
- Arthur Suzuki (63)
- Michal Urban (1)



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

Autogenerated release notes updated last on 22 Oct 2022 18:07:51.
