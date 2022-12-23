# RELEASE NOTES FOR KOHA 21.05.22
23 Dec 2022

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 21.05.22 can be downloaded from:

- [Download](http://download.koha-community.org/koha-21.05.22.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 21.05.22 is a security release.

It includes 2 security fixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha [here](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).

## Security bugs

### Koha

- [[31908]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31908) New login fails while having cookie from previous session

  >This patch introduces more thorough cleanup of user sessions when logging after a privilege escalation request.
- [[32208]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32208) Relogin without enough permissions needs attention

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/21.05/ar/html/) (34.3%)
- [Chinese (Taiwan)](https://koha-community.org/manual/21.05/zh_TW/html/) (59.9%)
- [Czech](https://koha-community.org/manual/21.05/cs/html/) (27.6%)
- [English (USA)](https://koha-community.org/manual/21.05/en/html/)
- [French](https://koha-community.org/manual/21.05/fr/html/) (68.4%)
- [French (Canada)](https://koha-community.org/manual/21.05/fr_CA/html/) (26.1%)
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
- Chinese (Taiwan) (94%)
- Czech (70.9%)
- English (New Zealand) (61.1%)
- English (USA)
- Finnish (82%)
- French (94.1%)
- French (Canada) (98.8%)
- German (100%)
- German (Switzerland) (60.5%)
- Greek (55.6%)
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
- Swedish (76.7%)
- Telugu (99%)
- Turkish (100%)
- Ukrainian (83%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 21.05.22 is


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
  - Martin Renvoize
  - Marcel de Rooy
  - Fridolin Somers

- Topic Experts:
  - UI Design -- Owen Leonard
  - Zebra -- Fridolin Somers
  - REST API -- Martin Renvoize

- Bug Wranglers:
  - Aleisha Amohia
  - Indranil Das Gupta

- Packaging Manager: Mason James


- Documentation Manager: Caroline Cyr La Rose


- Documentation Team:
  - Aude Charillon
  - David Nind
  - Lucy Vaux-Harvey

- Translation Manager: Bernardo González Kriegel


- Wiki curators: 
  - Thomas Dukleth
  - Katrin Fischer

- Release Maintainers:
  - 22.11 -- PTFS Europe (Martin Renvoize, Matt Blenkinsop, Jacob O'Mara)
  - 22.05 -- Lucas Gass
  - 21.11 -- Arthur Suzuki
  - 21.05 -- Wainui Witika-Park

## Credits

We thank the following individuals who contributed patches to Koha 21.05.22

- Tomás Cohen Arazi (1)
- Nick Clemens (2)
- Jonathan Druart (1)
- Isobel Graham (1)
- Kyle M Hall (2)
- Owen Leonard (1)
- Marcel de Rooy (7)
- Christophe Torin (1)
- Koha translators (1)
- Shi Yao Wang (1)
- Wainui Witika-Park (3)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 21.05.22

- Athens County Public Libraries (1)
- ByWater-Solutions (4)
- Catalyst (3)
- Independant Individuals (1)
- Koha Community Developers (1)
- Rijksmuseum (7)
- Solutions inLibro inc (1)
- Theke Solutions (1)
- Université Rennes 2 (1)

We also especially thank the following individuals who tested patches
for Koha

- Tomás Cohen Arazi (11)
- Emmanuel Bétemps (1)
- Catrina (1)
- Nick Clemens (3)
- David Cook (4)
- Chris Cormack (2)
- Katrin Fischer (9)
- Lucas Gass (12)
- Géraud (1)
- Joonas Kylmälä (2)
- Owen Leonard (1)
- David Nind (1)
- Martin Renvoize (6)
- Marcel de Rooy (1)
- Arthur Suzuki (11)
- Wainui Witika-Park (17)



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

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 20 Dec 2022 20:56:35.
