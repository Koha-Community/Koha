# RELEASE NOTES FOR KOHA 21.05.17
26 Jul 2022

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 21.05.17 can be downloaded from:

- [Download](https://download.koha-community.org/koha-21.05.17.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 21.05.17 is a bugfix/maintenance release with security fixes.

It includes 1 security fixes, 6 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations


## Security bugs

### Koha

- [[30969]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30969) Cross site scripting (XSS) attack in OPAC authority search ( opac-authorities-home.pl )




## Critical bugs fixed

### Cataloging

- [[30234]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30234) Serial local covers don't appear in the staff interface for other libraries with SeparateHoldings

  >This fixes the display of item-specific local cover images in the staff interface. Before this, item images were not shown for holdings on the record's details view page.

### Circulation

- [[29504]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29504) Confirm item parts requires force_checkout permission (checkouts tab)

### Patrons

- [[31005]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31005) Cannot edit patrons in other categories if an extended attribute is mandatory and limited to a category

  >This fixes an error when a mandatory patron attribute limited to a specific patron category was causing a '500 error' when editing a patron not in that category.

### Reports

- [[30551]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30551) Cash register report shows wrong library when paying fees in two different libraries

### Searching - Elasticsearch

- [[30883]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30883) Authorities merge is limited to 100 biblio with Elasticsearch

  >This fixes the hard-coded limit of 100 when merging authorities (when Elasticsearch is the search engine). When merging authorities where the term is used over 100 times, only the first 100 authorities would be merged and the old term deleted, irrespective of the value set in the AuthorityMergeLimit system preference.

### Searching - Zebra

- [[29418]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29418) Error searching for analytics in detail view

  **Sponsored by** *Theke Solutions*





## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/21.05/ar/html/) (34.3%)
- [Chinese (Taiwan)](https://koha-community.org/manual/21.05/zh_TW/html/) (59.9%)
- [Czech](https://koha-community.org/manual/21.05/cs/html/) (27.6%)
- [English (USA)](https://koha-community.org/manual/21.05/en/html/)
- [French](https://koha-community.org/manual/21.05/fr/html/) (67.9%)
- [French (Canada)](https://koha-community.org/manual/21.05/fr_CA/html/) (25.5%)
- [German](https://koha-community.org/manual/21.05/de/html/) (74.8%)
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
- Finnish (82.1%)
- French (93.3%)
- French (Canada) (98.8%)
- German (100%)
- German (Switzerland) (60.5%)
- Greek (55.3%)
- Hindi (100%)
- Italian (100%)
- Nederlands-Nederland (Dutch-The Netherlands) (61.3%)
- Norwegian Bokmål (65.4%)
- Polish (100%)
- Portuguese (91.1%)
- Portuguese (Brazil) (86.6%)
- Russian (86%)
- Slovak (72.6%)
- Spanish (100%)
- Swedish (76.5%)
- Telugu (99%)
- Turkish (100%)
- Ukrainian (77.6%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](https://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](https://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](https://translate.koha-community.org/)

## Release Team

The release team for Koha 21.05.17 is


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
We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 21.05.17

- [Theke Solutions](https://theke.io)

We thank the following individuals who contributed patches to Koha 21.05.17

- Tomás Cohen Arazi (4)
- Nick Clemens (2)
- Jonathan Druart (1)
- Victor Grousset (4)
- Kyle M Hall (1)
- Martin Renvoize (2)
- Fridolin Somers (1)
- Koha translators (1)
- Shi Yao Wang (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 21.05.17

- BibLibre (1)
- ByWater-Solutions (3)
- Koha Community Developers (5)
- PTFS-Europe (2)
- Solutions inLibro inc (1)
- Theke Solutions (4)

We also especially thank the following individuals who tested patches
for Koha

- Tomás Cohen Arazi (6)
- Chris Cormack (1)
- Katrin Fischer (4)
- Lucas Gass (6)
- Victor Grousset (12)
- David Nind (10)
- Martin Renvoize (8)
- Fridolin Somers (1)
- Arthur Suzuki (7)



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

Autogenerated release notes updated last on 26 Jul 2022 01:21:21.
