# RELEASE NOTES FOR KOHA 21.05.14
26 Apr 2022

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 21.05.14 can be downloaded from:

- [Download](http://download.koha-community.org/koha-21.05.14.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 21.05.14 is a bugfix/maintenance release.

It includes 18 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations






## Critical bugs fixed

### Architecture, internals, and plumbing

- [[30172]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30172) Background jobs failing due to race condition

### Circulation

- [[30222]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30222) Auto_renew_digest still sends every day when renewals are not allowed

### Hold requests

- [[30583]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30583) Hold system broken for translated template

### Patrons

- [[28943]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28943) Lower the risk of accidental patron deletion by cleanup_database.pl

  >If you use self registration but you do not use a temporary self registration patron category,
  >you should actually clear the preference
  >PatronSelfRegistrationExpireTemporaryAccountsDelay.

### Test Suite

- [[19169]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19169) Add a test to detect unneeded 'atomicupdate' files


## Other bugs fixed

### Architecture, internals, and plumbing

- [[29771]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29771) Get rid of CGI::param in list context warnings
- [[30406]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30406) Our DT tables not filtering on the correct column if hidden by default

### Cataloging

- [[26328]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26328) incremental barcode generation fails when incorrectly converting strings to numbers

### Circulation

- [[30541]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30541) Resolve return claim works but "hangs" if MarkLostItemsAsReturned is set for return claims

### Hold requests

- [[29338]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29338) Reprinting holds slip with updated expiration date

  >This patch adds a "Print hold/transfer" button to request.tt so staff can reprint hold/transfer slips without re-checking an item.
- [[29704]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29704) Holds reminder emails should allow configuration for a specific number of days

### OPAC

- [[29482]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29482) Terminology: This item belongs to another branch.

  >This replaces the word "branch" with the word "library" for a self-checkout message, as per the terminology guidelines.  ("This item belongs to another branch." changed to "This item belongs to another library".)
- [[30220]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30220) Purchase suggestion defaults to first library

### SIP2

- [[30118]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30118) holds_block_checkin behavior is different in Koha and in SIP

### Searching - Elasticsearch

- [[30142]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30142) ElasticSearch MARC mappings should not accept whitespaces

  **Sponsored by** *Steiermärkische Landesbibliothek*

### Serials

- [[30035]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30035) Wrong month name in numbering pattern

  **Sponsored by** *Orex Digital*

  >Sponsored-by: Orex Digital

### System Administration

- [[29020]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29020) Missing Background jobs link in admin-home
- [[29875]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29875) Update text on MaxReserves system preference to describe functionality.



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/21.05/ar/html/) (34.3%)
- [Chinese (Taiwan)](https://koha-community.org/manual/21.05/zh_TW/html/) (59%)
- [Czech](https://koha-community.org/manual/21.05/cs/html/) (27.6%)
- [English (USA)](https://koha-community.org/manual/21.05/en/html/)
- [French](https://koha-community.org/manual/21.05/fr/html/) (62.9%)
- [French (Canada)](https://koha-community.org/manual/21.05/fr_CA/html/) (25.5%)
- [German](https://koha-community.org/manual/21.05/de/html/) (73.5%)
- [Hindi](https://koha-community.org/manual/21.05/hi/html/) (100%)
- [Italian](https://koha-community.org/manual/21.05/it/html/) (48.5%)
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
- Chinese (Taiwan) (83.3%)
- Czech (70.9%)
- English (New Zealand) (61.1%)
- English (USA)
- Finnish (82%)
- French (92.6%)
- French (Canada) (98.5%)
- German (100%)
- German (Switzerland) (60.5%)
- Greek (55.2%)
- Hindi (99.7%)
- Italian (100%)
- Nederlands-Nederland (Dutch-The Netherlands) (61.4%)
- Norwegian Bokmål (65.4%)
- Polish (99.7%)
- Portuguese (90.9%)
- Portuguese (Brazil) (86.6%)
- Russian (86.1%)
- Slovak (72.4%)
- Spanish (99.5%)
- Swedish (76.5%)
- Telugu (99%)
- Turkish (100%)
- Ukrainian (77%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 21.05.14 is


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
new features in Koha 21.05.14

- Orex Digital
- Steiermärkische Landesbibliothek

We thank the following individuals who contributed patches to Koha 21.05.14

- Tomás Cohen Arazi (2)
- Nick Clemens (4)
- David Cook (1)
- Jonathan Druart (9)
- Andrew Fuerste-Henry (3)
- Lucas Gass (2)
- Kyle M Hall (2)
- Mason James (1)
- Thomas Klausner (1)
- Owen Leonard (2)
- Julian Maurice (1)
- Matthias Meusburger (1)
- Marcel de Rooy (1)
- Fridolin Somers (2)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 21.05.14

- Athens County Public Libraries (2)
- BibLibre (4)
- ByWater-Solutions (11)
- Independant Individuals (1)
- Koha Community Developers (9)
- KohaAloha (1)
- Prosentient Systems (1)
- Rijksmuseum (1)
- Theke Solutions (2)

We also especially thank the following individuals who tested patches
for Koha

- Tomás Cohen Arazi (7)
- Sonia Bouis (1)
- Nick Clemens (6)
- Jonathan Druart (9)
- Katrin Fischer (4)
- Andrew Fuerste-Henry (36)
- Lucas Gass (2)
- Kyle M Hall (24)
- Christine Lee (1)
- Marjorie (1)
- David Nind (2)
- Séverine Queune (1)
- Martin Renvoize (6)
- Marcel de Rooy (1)
- Caroline Cyr La Rose (1)
- Sally (2)
- Fridolin Somers (21)



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

Autogenerated release notes updated last on 26 Apr 2022 12:57:39.
