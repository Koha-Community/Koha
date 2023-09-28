# RELEASE NOTES FOR KOHA 22.05.16
28 Sep 2023

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 22.05.16 can be downloaded from:

- [Download](http://download.koha-community.org/koha-22.05.16.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 22.05.16 is a bugfix/maintenance release.

It includes 3 enhancements, 12 bugfixes, and 3 security fixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).

#### Security bugs

- [34349](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34349) Validate inputs for task scheduler
- [34369](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34369) Add CSRF protection to system preferences
- [34513](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34513) Authenticated users can bypass permissions and view some privileged pages

## Bugfixes

### Acquisitions

#### Other bugs fixed

- [33939](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33939) JavaScript needs to distinguish between order budgets and default budgets when adding to staged file form a basket

### Architecture, internals, and plumbing

#### Other bugs fixed

- [34243](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34243) Too many cities are created (at least in comments)
- [34303](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34303) t/00-testcritic.t should only test files part of git repo
- [34316](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34316) account->add_credit does not rethrow exception

### Cataloging

#### Other bugs fixed

- [34097](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34097) Using the three ellipses to set the date accessioned for an item repositions the screen to the top
- [34182](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34182) AddBiblio shouldn't set biblio.serial based on biblio.seriestitle

### Circulation

#### Critical bugs fixed

- [34279](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34279) overduefinescap of 0 is ignored, but overduefinescap of 0.00 is enforced
- [34601](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34601) Cannot manage suggestions without CSRF error

#### Other bugs fixed

- [33992](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33992) Only consider the date when labelling a waiting recall as problematic

  **Sponsored by** *Auckland University of Technology*

### Patrons

#### Other bugs fixed

- [33132](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33132) Searching by DOB still broken in 22.05.x

### Templates

#### Other bugs fixed

- [34184](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34184) "Document type" in suggestions form should have an empty entry

### Test Suite

#### Other bugs fixed

- [33727](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33727) Merge Calendar tests

## Enhancements 

### Command-line Utilities

#### Enhancements

- [34213](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34213) False POD for matchpoint option in import_patrons.pl

### OPAC

#### Enhancements

- [33808](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33808) Accessibility: Non-descriptive links

### Packaging

#### Enhancements

- [28493](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28493) Make koha-passwd display the username

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Arabic](https://koha-community.org/manual/22.05/ar/html/) (28.2%)
- [Chinese (Taiwan)](https://koha-community.org/manual/22.05/zh_TW/html/) (98.6%)
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
- Chinese (Taiwan) (96%)
- Czech (62.2%)
- English (New Zealand) (68.4%)
- English (USA)
- Finnish (94.9%)
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
- Polish (100%)
- Portuguese (87.3%)
- Portuguese (Brazil) (81.1%)
- Russian (78.2%)
- Slovak (64%)
- Spanish (100%)
- Swedish (83.5%)
- Telugu (84.3%)
- Turkish (98.1%)
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

The release team for Koha 22.05.16 is


- Release Manager: Tomás Cohen Arazi

- Release Manager assistants:
  - Jonathan Druart
  - Martin Renvoize

- QA Manager: Katrin Fischer

- QA Team:
  - Aleisha Amohia
  - Nick Clemens
  - David Cook
  - Jonathan Druart
  - Lucas Gass
  - Victor Grousset
  - Kyle M Hall
  - Andrii Nugged
  - Martin Renvoize
  - Marcel de Rooy
  - Petro Vashchuk

- Topic Experts:
  - UI Design -- Owen Leonard
  - Zebra -- Fridolin Somers
  - REST API -- Martin Renvoize
  - ERM -- Pedro Amorim
  - ILL -- Pedro Amorim

- Bug Wranglers:
  - Aleisha Amohia

- Packaging Manager: Mason James

- Documentation Manager: Aude Charillon

- Documentation Team:
  - Caroline Cyr La Rose
  - Lucy Vaux-Harvey

- Translation Manager: Bernardo González Kriegel


- Wiki curators: 
  - Thomas Dukleth
  - Katrin Fischer

- Release Maintainers:
  - 23.05 -- Fridolin Somers
  - 22.11 -- PTFS Europe (Matt Blenkinsop, Pedro Amorim)
  - 22.05 -- Lucas Gass
  - 21.11 -- Danyon Sewell

- Release Maintainer assistants:
  - 21.11 -- Wainui Witika-Park

## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 22.05.16
<div style="column-count: 2;">

- Auckland University of Technology
</div>

We thank the following individuals who contributed patches to Koha 22.05.16
<div style="column-count: 2;">

- Aleisha Amohia (1)
- Matt Blenkinsop (1)
- Nick Clemens (2)
- David Cook (5)
- Jonathan Druart (4)
- Lucas Gass (2)
- Kyle M Hall (2)
- Mason James (1)
- Phil Ringnalda (2)
- Marcel de Rooy (6)
- Koha translators (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 22.05.16
<div style="column-count: 2;">

- ByWater-Solutions (6)
- Catalyst Open Source Academy (1)
- Chetco Community Public Library (2)
- Koha Community Developers (4)
- KohaAloha (1)
- Prosentient Systems (5)
- PTFS-Europe (1)
- Rijksmuseum (6)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Pedro Amorim (6)
- Tomás Cohen Arazi (16)
- Matt Blenkinsop (9)
- Nick Clemens (3)
- Jonathan Druart (4)
- Katrin Fischer (9)
- Andrew Fuerste-Henry (1)
- Lucas Gass (24)
- Kyle M Hall (1)
- Sam Lau (1)
- Owen Leonard (2)
- David Nind (2)
- Martin Renvoize (13)
- Marcel de Rooy (8)
- Fridolin Somers (6)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 22.05.x-security.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 28 Sep 2023 16:36:33.
