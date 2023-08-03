# RELEASE NOTES FOR KOHA 22.05.15
03 Aug 2023

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 22.05.15 can be downloaded from:

- [Download](http://download.koha-community.org/koha-22.05.15.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 22.05.15 is a bugfix/maintenance release.

It includes 5 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [22990](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22990) Add CSRF protection to boraccount, pay, suggestions and virtualshelves on staff
- [30524](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30524) Add base framework for dealing with CSRF in Koha
- [34023](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34023) HTML injection in "back to results" link from search page
- [34368](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34368) Add CSRF protection to Content Management pages

## Bugfixes

### Command-line Utilities

#### Other bugs fixed

- [33717](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33717) Typo in search_for_data_inconsistencies.pl

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Arabic](https://koha-community.org/manual/22.05/ar/html/) (28.2%)
- [Chinese (Taiwan)](https://koha-community.org/manual/22.05/zh_TW/html/) (95.5%)
- [English (USA)](https://koha-community.org/manual/22.05/en/html/)
- [French](https://koha-community.org/manual/22.05/fr/html/) (66.7%)
- [German](https://koha-community.org/manual/22.05/de/html/) (69.5%)
- [Hindi](https://koha-community.org/manual/22.05/hi/html/) (100%)
- [Italian](https://koha-community.org/manual/22.05/it/html/) (41.2%)
- [Spanish](https://koha-community.org/manual/22.05/es/html/) (29.9%)
- [Turkish](https://koha-community.org/manual/22.05/tr/html/) (33.5%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (77.7%)
- Armenian (100%)
- Armenian (Classical) (69.7%)
- Bulgarian (85.5%)
- Chinese (Taiwan) (96.1%)
- Czech (62.2%)
- English (New Zealand) (68.4%)
- English (USA)
- Finnish (94.8%)
- French (100%)
- French (Canada) (99.5%)
- German (100%)
- German (Switzerland) (54%)
- Greek (56.1%)
- Hindi (100%)
- Italian (99.8%)
- Nederlands-Nederland (Dutch-The Netherlands) (85.2%)
- Norwegian Bokmål (55.8%)
- Persian (58.7%)
- Polish (99.8%)
- Portuguese (87.1%)
- Portuguese (Brazil) (78.3%)
- Russian (78.2%)
- Slovak (64%)
- Spanish (99.8%)
- Swedish (81.8%)
- Telugu (84.3%)
- Turkish (95.8%)
- Ukrainian (74%)
</div>

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 22.05.15 is


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

- Packaging Manager: Mason James

- Documentation Manager: David Nind

- Documentation Team:
  - Aude Charillon
  - Caroline Cyr La Rose
  - Kelly McElligott
  - Lucy Vaux-Harvey
  - Martin Renvoize
  - Rocio Lopez

- Translation Manager: Bernardo González Kriegel


- Wiki curators: 
  - Thomas Dukleth

- Release Maintainers:
  - 21.11 -- Kyle M Hall
  - 21.05 -- Andrew Fuerste-Henry
  - 20.11 -- Victor Grousset
  - 19.11 -- Wainui Witika-Park

## Credits

We thank the following individuals who contributed patches to Koha 22.05.15

- Tomás Cohen Arazi (1)
- Lucas Gass (2)
- Amit Gupta (1)
- Michał Górny (1)
- Martin Renvoize (1)
- Caroline Cyr La Rose (1)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 22.05.15

- ByWater-Solutions (2)
- gentoo.org (1)
- Informatics Publishing Ltd (1)
- PTFS-Europe (1)
- Solutions inLibro inc (1)
- Theke Solutions (1)

We also especially thank the following individuals who tested patches
for Koha

- Pedro Amorim (1)
- Tomás Cohen Arazi (5)
- David Cook (4)
- Jonathan Druart (1)
- Katrin Fischer (1)
- Lucas Gass (1)
- Kyle M Hall (2)
- Marcel de Rooy (8)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 22.05.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 03 Aug 2023 19:33:41.
