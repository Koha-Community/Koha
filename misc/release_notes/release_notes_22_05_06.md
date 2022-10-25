# RELEASE NOTES FOR KOHA 22.05.06
25 Oct 2022

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 22.05.06 can be downloaded from:

- [Download](http://download.koha-community.org/koha-22.05.06.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 22.05.06 is a bugfix/maintenance release.

It includes 8 enhancements, 42 bugfixes.

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

### Staff Client

- [[28864]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28864) The patron search results in the patron card creator doesn't seem to use PatronsPerPage syspref

### System Administration

- [[31289]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31289) Hide Article requests column in circulation rules when ArticleRequests syspref is disabled

### Templates

- [[31228]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31228) Fix Coce JavaScript to hide single-pixel cover images in both the staff client detail and results pages

  **Sponsored by** *Catalyst*
- [[31425]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31425) Minor correction to patron categories admin title


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[31245]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31245) Job detail view for batch mod explode if job not started
- [[31274]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31274) OPACSuggestionAutoFill must be 1 or 0
- [[31351]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31351) Worker dies on reindex job when operator last name/first name/branch name contains non-ASCII chars

### Authentication

- [[31247]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31247) Staff interface 2FA blocks logging into the OPAC
- [[31382]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31382) Cannot reach password reset page when password expired

### Circulation

- [[29012]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29012) Some rules are not saved when left blank while editing a 'rule' line in smart-rules.pl

### Hold requests

- [[31355]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31355) Specific item holds table on OPAC only showing 10 items

### Installation and upgrade (command-line installer)

- [[31673]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31673) DB update of bug 31086 fails: Cannot change column 'branchcode': used in a foreign key constraint

### MARC Bibliographic data support

- [[31238]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31238) Unable to save authorised value to frameworks subfields

  **Sponsored by** *Koha-Suomi Oy*

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

### Command-line Utilities

- [[31282]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31282) Broken characters in patron_emailer.pl verbose mode

  >This fixes the patron_emailer.pl script (misc/cronjobs/patron_emailer.pl) so that non-ASCII characters in notices display correctly.
- [[31325]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31325) Fix koha-preferences get

### Hold requests

- [[19540]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19540) opac-reserve does not correctly warn of too_much reserves

### I18N/L10N

- [[28707]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28707) Missing strings in translation of sample data
- [[30992]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30992) Hard to translate single word strings
- [[31292]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31292) Untranslatable string in sample_notices.yaml

### Label/patron card printing

- [[31352]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31352) Terminology: Borrower name

  **Sponsored by** *Catalyst*

  >This updates the table heading name from "Borrower name" to "Patron name" when adding a new batch in the patron card creator.

### MARC Authority data support

- [[29434]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29434) In UNIMARC instances, the authority finder uses MARC21 relationship codes

  >This fixes the values displayed for the relationship codes in the authority finder 'Special relationships' drop down list in UNIMARC catalogs - UNIMARC values are now displayed, instead of MARC21 values.

### MARC Bibliographic record staging/import

- [[26632]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26632) BatchStageMarcRecords passes a random number to AddBiblioToBatch / AddAuthToBatch
- [[31269]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31269) DataTables error when managing staged MARC records

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

- [[12225]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12225) SIP does not respect the "no block" flag
- [[31033]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31033) SIP2 configuration does not correctly handle multiple simultaneous connections by default

### Searching - Zebra

- [[30879]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30879) Add option to sort components by biblionumber

### Staff Client

- [[30499]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30499) Keyboard shortcuts broken on several pages
- [[31251]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31251) "Clear" patron attribute link does not work

### System Administration

- [[31249]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31249) update_patrons_category.pl cron does not log to action_logs

### Templates

- [[31302]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31302) Spelling: You can download the scanned materials via the following url(s):

  **Sponsored by** *Catalyst*

### Tools

- [[28327]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28327) System preference CSVdelimiter special case for tabulation

  >This fixes the CSV export so that data is correctly exported with a tab (\t) as the separator when this format is selected. This was incorrectly using the word 'tabulation' as the separator. (The default export format is set using the CSVdelimiter system preference.) In addition, the code where this is used was simplified (including several of the default reports, item search export, and the log viewer), and the default for CSVdelimiter was set to the comma separator.
- [[30779]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30779) Do not need to remove items from import biblios marc



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/22.05/ar/html/) (28.2%)
- [Chinese (Taiwan)](https://koha-community.org/manual/22.05/zh_TW/html/) (49.2%)
- [English (USA)](https://koha-community.org/manual/22.05/en/html/)
- [French](https://koha-community.org/manual/22.05/fr/html/) (58.3%)
- [German](https://koha-community.org/manual/22.05/de/html/) (61.3%)
- [Hindi](https://koha-community.org/manual/22.05/hi/html/) (86.3%)
- [Italian](https://koha-community.org/manual/22.05/it/html/) (41%)
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
- Bulgarian (85.1%)
- Chinese (Taiwan) (87.8%)
- Czech (62%)
- English (New Zealand) (56.2%)
- English (USA)
- Finnish (95%)
- French (96.7%)
- French (Canada) (100%)
- German (100%)
- German (Switzerland) (54.2%)
- Greek (53.9%)
- Hindi (100%)
- Italian (100%)
- Nederlands-Nederland (Dutch-The Netherlands) (83.2%)
- Norwegian Bokmål (56.1%)
- Persian (58.5%)
- Polish (96%)
- Portuguese (79.4%)
- Portuguese (Brazil) (76.9%)
- Russian (77.7%)
- Slovak (63.8%)
- Spanish (97.7%)
- Swedish (76.9%)
- Telugu (84.7%)
- Turkish (92%)
- Ukrainian (71.6%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 22.05.06 is


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
new features in Koha 22.05.06

- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)
- Koha-Suomi Oy
- Toi Ohomai Institute of Technology, New Zealand

We thank the following individuals who contributed patches to Koha 22.05.06

- Tomás Cohen Arazi (8)
- Alex Buckley (4)
- Kevin Carnes (1)
- Nick Clemens (13)
- David Cook (4)
- Jonathan Druart (8)
- Magnus Enger (1)
- Katrin Fischer (3)
- Lucas Gass (16)
- Michael Hafen (1)
- Kyle M Hall (9)
- Bernardo González Kriegel (2)
- Joonas Kylmälä (1)
- Owen Leonard (1)
- Tim McMahon (1)
- MJ Ray (1)
- Marcel de Rooy (6)
- Caroline Cyr La Rose (2)
- Andreas Roussos (1)
- Fridolin Somers (3)
- Emmi Takkinen (1)
- Koha translators (1)
- Shi Yao Wang (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 22.05.06

- Athens County Public Libraries (1)
- BibLibre (3)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (3)
- ByWater-Solutions (38)
- Catalyst (4)
- Dataly Tech (1)
- Independant Individuals (2)
- Koha Community Developers (8)
- Koha-Suomi (1)
- Libriotech (1)
- Prosentient Systems (4)
- Rijksmuseum (6)
- Software.coop (1)
- Solutions inLibro inc (3)
- Theke Solutions (8)
- ub.lu.se (1)
- Universidad Nacional de Córdoba (2)
- wlpl.org (1)

We also especially thank the following individuals who tested patches
for Koha

- Aleisha Amohia (1)
- Andrew (4)
- Tomás Cohen Arazi (67)
- Nason Bimbe (1)
- Emmanuel Bétemps (1)
- Paul Derscheid (2)
- Jonathan Druart (10)
- Katrin Fischer (22)
- Andrew Fuerste-Henry (3)
- Lucas Gass (69)
- Victor Grousset (3)
- Kyle M Hall (10)
- Sally Healey (1)
- Mark Hofstetter (1)
- Barbara Johnson (2)
- Joonas Kylmälä (1)
- Rachael Laritz (2)
- Owen Leonard (7)
- David Nind (15)
- Liz Rea (1)
- Martin Renvoize (19)
- Marcel de Rooy (4)
- Caroline Cyr La Rose (4)
- Fridolin Somers (6)
- Michal Urban (1)



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

Autogenerated release notes updated last on 25 Oct 2022 18:03:02.
