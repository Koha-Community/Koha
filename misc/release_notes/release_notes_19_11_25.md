# RELEASE NOTES FOR KOHA 19.11.25
31 Jan 2022

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 19.11.25 can be downloaded from:

- [Download](http://download.koha-community.org/koha-19.11.25.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 19.11.25 is a bugfix/maintenance release with security fixes.

It includes 9 security fixes,  bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations


## Security bugs

### Koha

- [[26102]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26102) Javascript injection in intranet search
- [[28735]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28735) Self-checkout users can access opac-user.pl for sco user when not using AutoSelfCheckID
- [[29540]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29540) Accounts with just 'catalogue' permission can modify/delete holds
- [[29541]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29541) Patron images can be accessed with just 'catalogue' permission
- [[29542]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29542) User with 'catalogue' permission can view everybody's (private) virtualshelves
- [[29543]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29543) Self-checkout allows returning everybody's loans
- [[29544]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29544) A patron can set everybody's checkout notes
- [[29903]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29903) Message deletion possible from different branch
- [[29914]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29914) check_cookie_auth not strict enough









## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/19.11/ar/html/) (42.4%)
- [Chinese (Taiwan)](https://koha-community.org/manual/19.11/zh_TW/html/) (90.1%)
- [Czech](https://koha-community.org/manual/19.11/cs/html/) (33.4%)
- [English (USA)](https://koha-community.org/manual/19.11/en/html/)
- [French](https://koha-community.org/manual/19.11/fr/html/) (71.6%)
- [French (Canada)](https://koha-community.org/manual/19.11/fr_CA/html/) (29.2%)
- [German](https://koha-community.org/manual/19.11/de/html/) (49.5%)
- [Hindi](https://koha-community.org/manual/19.11/hi/html/) (100%)
- [Italian](https://koha-community.org/manual/19.11/it/html/) (67.7%)
- [Spanish](https://koha-community.org/manual/19.11/es/html/) (46.4%)
- [Turkish](https://koha-community.org/manual/19.11/tr/html/) (71.3%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (97.9%)
- Armenian (100%)
- Armenian (Classical) (100%)
- Basque (55.7%)
- Catalan; Valencian (50.6%)
- Chinese (China) (57%)
- Chinese (Taiwan) (98.8%)
- Czech (90.8%)
- English (New Zealand) (78.4%)
- English (USA)
- Finnish (74.3%)
- French (100%)
- French (Canada) (93.8%)
- German (100%)
- German (Switzerland) (80.9%)
- Greek (72.9%)
- Hindi (100%)
- Italian (87.2%)
- Nederlands-Nederland (Dutch-The Netherlands) (85.3%)
- Norwegian Bokmål (83.4%)
- Occitan (post 1500) (53.1%)
- Persian (55.7%)
- Polish (85.8%)
- Portuguese (100%)
- Portuguese (Brazil) (100%)
- Slovak (83.2%)
- Spanish (100%)
- Swedish (85.4%)
- Telugu (100%)
- Tetun (52.9%)
- Turkish (100%)
- Ukrainian (75%)
- Vietnamese (51.6%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 19.11.25 is


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

We thank the following individuals who contributed patches to Koha 19.11.25

- Tomás Cohen Arazi (1)
- Nick Clemens (2)
- David Cook (1)
- Jonathan Druart (10)
- Owen Leonard (7)
- Marcel de Rooy (2)
- Koha translators (1)
- Wainui Witika-Park (3)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 19.11.25

- Athens County Public Libraries (7)
- ByWater-Solutions (2)
- Catalyst (3)
- Koha Community Developers (10)
- Prosentient Systems (1)
- Rijksmuseum (2)
- Theke Solutions (1)

We also especially thank the following individuals who tested patches
for Koha

- Tomás Cohen Arazi (5)
- Nick Clemens (14)
- Jonathan Druart (1)
- Katrin Fischer (14)
- Victor Grousset (22)
- Kyle M Hall (13)
- Wainui Witika-Park (23)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 19.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 31 Jan 2022 03:23:19.
