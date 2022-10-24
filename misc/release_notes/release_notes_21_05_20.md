# RELEASE NOTES FOR KOHA 21.05.20
24 Oct 2022

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 21.05.20 can be downloaded from:

- [Download](https://download.koha-community.org/koha-21.05.20.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 21.05.20 is a bugfix/maintenance release with security fixes.

It includes 1 security fixes, 2 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations


## Security bugs

### Koha

- [[31219]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31219) Patron attribute types not cleaned/checked




## Critical bugs fixed

### Command-line Utilities

- [[29325]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29325) commit_file.pl error 'Already in a transaction'

  >This fixes the command line script misc/commit_file.pl and manage staged MARC records tool in the staff interface so that imported records are processed.
  >
  >The error message from The command line script was failing with this error message "DBIx::Class::Storage::DBI::_exec_txn_begin(): DBI Exception: DBD::mysql::db begin_work failed: Already in a transaction at /kohadevbox/koha/C4/Biblio.pm line 303". In the staff interface, the processing of staged records would fail without any error messages.


## Other bugs fixed

### Packaging

- [[30252]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30252) lower version of 'Locale::XGettext::TT2' to 0.6



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/21.05/ar/html/) (34.3%)
- [Chinese (Taiwan)](https://koha-community.org/manual/21.05/zh_TW/html/) (59.9%)
- [Czech](https://koha-community.org/manual/21.05/cs/html/) (27.6%)
- [English (USA)](https://koha-community.org/manual/21.05/en/html/)
- [French](https://koha-community.org/manual/21.05/fr/html/) (68.3%)
- [French (Canada)](https://koha-community.org/manual/21.05/fr_CA/html/) (26%)
- [German](https://koha-community.org/manual/21.05/de/html/) (75%)
- [Hindi](https://koha-community.org/manual/21.05/hi/html/) (100%)
- [Italian](https://koha-community.org/manual/21.05/it/html/) (48.9%)
- [Spanish](https://koha-community.org/manual/21.05/es/html/) (37%)
- [Turkish](https://koha-community.org/manual/21.05/tr/html/) (40.3%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (89.3%)
- Armenian (100%)
- Armenian (Classical) (89%)
- Chinese (Taiwan) (91.1%)
- Czech (70.9%)
- English (New Zealand) (61.1%)
- English (USA)
- Finnish (82%)
- French (93.4%)
- French (Canada) (98.8%)
- German (100%)
- German (Switzerland) (60.5%)
- Greek (55.5%)
- Hindi (100%)
- Italian (100%)
- Nederlands-Nederland (Dutch-The Netherlands) (61.3%)
- Norwegian Bokmål (65.4%)
- Polish (100%)
- Portuguese (91.2%)
- Portuguese (Brazil) (86.6%)
- Russian (86%)
- Slovak (72.7%)
- Spanish (100%)
- Swedish (76.4%)
- Telugu (99%)
- Turkish (100%)
- Ukrainian (80%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](https://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](https://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](https://translate.koha-community.org/)

## Release Team

The release team for Koha 21.05.20 is


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
  - David Cook

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

We thank the following individuals who contributed patches to Koha 21.05.20

- Tomás Cohen Arazi (1)
- Jonathan Druart (1)
- Victor Grousset (2)
- Mason James (1)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 21.05.20

- Koha Community Developers (3)
- KohaAloha (1)
- Theke Solutions (1)

We also especially thank the following individuals who tested patches
for Koha

- Tomás Cohen Arazi (1)
- Nick Clemens (5)
- Katrin Fischer (1)
- Lucas Gass (1)
- Victor Grousset (3)
- Kyle M Hall (1)
- Mark Hofstetter (1)
- Martin Renvoize (6)
- Marcel de Rooy (2)
- Fridolin Somers (1)
- Arthur Suzuki (1)



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

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 24 Oct 2022 16:10:24.
