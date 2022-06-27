# RELEASE NOTES FOR KOHA 21.05.16
27 Jun 2022

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 21.05.16 can be downloaded from:

- [Download](https://download.koha-community.org/koha-21.05.16.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 21.05.16 is a bugfix/maintenance release.

It includes 8 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations






## Critical bugs fixed

### Hold requests

- [[30630]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30630) Checking in a waiting hold at another branch when HoldsAutoFill is enabled causes errors

### Label/patron card printing

- [[24001]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24001) Cannot edit card template

  >This fixes errors that caused creating and editing patron card templates and printer profiles to fail.

### Notices

- [[30354]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30354) AUTO_RENEWALS_DGST notices are not generated if patron set to receive notice via SMS and no SMS notice defined

  >If an SMS notice is not defined for AUTO_RENEWALS_DGST and a patron has selected to receive a digest notification by SMS when items are automatically renewed, it doesn't generate a notice (even though the item(s) is renewed). This fixes the issue so that an email message is generated.

### REST API

- [[30663]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30663) POST /api/v1/suggestions won't honor suggestions limits

### Staff Client

- [[30610]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30610) The 'Print receipt' button on cash management registers page fails on second datatables page

### Tools

- [[30628]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30628) Batch borrower modifications only affect the current page

  >This fixes the batch patron modification tool (Tools > Patrons and circulation > Batch patron modification) so that the changes for all selected patrons are modified. Before this, only the patrons listed on the current page were modified.


## Other bugs fixed

### About

- [[30808]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30808) Release team 22.11

### Command-line Utilities

- [[30781]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30781) Use of uninitialized value $val in substitution iterator at /usr/share/koha/lib/C4/Letters.pm line 665.



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/21.05/ar/html/) (34.3%)
- [Chinese (Taiwan)](https://koha-community.org/manual/21.05/zh_TW/html/) (59.3%)
- [Czech](https://koha-community.org/manual/21.05/cs/html/) (27.6%)
- [English (USA)](https://koha-community.org/manual/21.05/en/html/)
- [French](https://koha-community.org/manual/21.05/fr/html/) (65.1%)
- [French (Canada)](https://koha-community.org/manual/21.05/fr_CA/html/) (25.5%)
- [German](https://koha-community.org/manual/21.05/de/html/) (73.5%)
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
- Chinese (Taiwan) (87.5%)
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
- Nederlands-Nederland (Dutch-The Netherlands) (61.4%)
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

The release team for Koha 21.05.16 is


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

We thank the following individuals who contributed patches to Koha 21.05.16

- Tomás Cohen Arazi (3)
- Philippe Blouin (1)
- Nick Clemens (2)
- Jonathan Druart (2)
- Victor Grousset (3)
- Martin Renvoize (2)
- Fridolin Somers (3)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 21.05.16

- BibLibre (3)
- ByWater-Solutions (2)
- Koha Community Developers (5)
- PTFS-Europe (2)
- Solutions inLibro inc (1)
- Theke Solutions (3)

We also especially thank the following individuals who tested patches
for Koha

- Tomás Cohen Arazi (2)
- Nick Clemens (2)
- Katrin Fischer (4)
- Lucas Gass (5)
- Victor Grousset (13)
- Kyle M Hall (9)
- Joonas Kylmälä (1)
- Owen Leonard (1)
- David Nind (6)
- Martin Renvoize (5)
- Alexis Ripetti (1)
- Fridolin Somers (7)
- Arthur Suzuki (3)



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

Autogenerated release notes updated last on 27 Jun 2022 23:23:00.
