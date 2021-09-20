# RELEASE NOTES FOR KOHA 19.11.22
20 Sep 2021

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 19.11.22 can be downloaded from:

- [Download](http://download.koha-community.org/koha-19.11.22.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 19.11.22 is a bugfix/maintenance release with security fixes.

It includes 6 security fixes, 7 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations


## Security bugs

### Koha

- [[28759]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28759) Users with pretty basic staff interface permissions can see/add/remove API keys of any other user
- [[28772]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28772) Any user that can work with reports can see API keys of any other user
- [[28929]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28929) No filtering on borrowers.flags on member entry pages (OPAC, self registration, staff interface)
- [[28935]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28935) No filtering on patron's data on member entry pages (OPAC, self registration, staff interface)
- [[28941]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28941) No filtering on suggestion at the OPAC
- [[28947]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28947) OPAC user can create new users




## Critical bugs fixed

### Architecture, internals, and plumbing

- [[28200]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28200) Net::Netmask 1.9104-2 requires constructor change for backwards compatibility

  >The code library Koha uses for working with IP addresses has dropped support for abbreviated values in recent releases.  This is to tighten up the default security of input value's and we have opted in Koha to follow this change through into our system preferences for the same reason.
  >
  >WARNING: `koha_trusted_proxies` and `ILS-DI:AuthorizedIPs` are both affected. Please check that you are not using abbreviated IP forms for either of these cases. Example: "10.10" is much less explicit than "10.10.0.0/16" and should be avoided.

### OPAC

- [[28462]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28462) TT tag on several lines break the translator tool


## Other bugs fixed

### Hold requests

- [[28644]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28644) Can't call method "borrowernumber" on an undefined value at C4/Reserves.pm line 607

### REST API

- [[28604]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28604) Bad encoding when using marc-in-json
- [[28632]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28632) patrons.t fragile on slow boxes

### Staff Client

- [[28722]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28722) tools/batchMod.pl needs to import C4::Auth::haspermission
- [[28802]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28802) Untranslatable strings in browser.js



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/19.11/ar/html/) (42.4%)
- [Chinese (Taiwan)](https://koha-community.org/manual/19.11/zh_TW/html/) (90.1%)
- [Czech](https://koha-community.org/manual/19.11/cs/html/) (33.4%)
- [English (USA)](https://koha-community.org/manual/19.11/en/html/)
- [French](https://koha-community.org/manual/19.11/fr/html/) (69.1%)
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

- Arabic (98%)
- Armenian (100%)
- Armenian (Classical) (100%)
- Basque (55.7%)
- Catalan; Valencian (50.6%)
- Chinese (China) (57%)
- Chinese (Taiwan) (98.6%)
- Czech (90.8%)
- English (New Zealand) (78.4%)
- English (USA)
- Finnish (74.3%)
- French (99.4%)
- French (Canada) (93.8%)
- German (100%)
- German (Switzerland) (80.9%)
- Greek (71.2%)
- Hindi (100%)
- Italian (87.2%)
- Nederlands-Nederland (Dutch-The Netherlands) (85.4%)
- Norwegian Bokmål (83.4%)
- Occitan (post 1500) (53.1%)
- Polish (85.7%)
- Portuguese (100%)
- Portuguese (Brazil) (100%)
- Slovak (83.2%)
- Spanish (99.9%)
- Swedish (85.1%)
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

The release team for Koha 19.11.22 is


- Release Manager: Jonathan Druart

- Release Manager assistants:
  - Martin Renvoize
  - Tomás Cohen Arazi

- QA Manager: Katrin Fischer

- QA Team:
  - David Cook
  - Agustín Moyano
  - Martin Renvoize
  - Marcel de Rooy
  - Joonas Kylmälä
  - Julian Maurice
  - Tomás Cohen Arazi
  - Nick Clemens
  - Kyle M Hall
  - Victor Grousset
  - Andrew Nugged
  - Petro Vashchuk

- Topic Experts:
  - UI Design -- Owen Leonard
  - REST API -- Tomás Cohen Arazi
  - Elasticsearch -- Fridolin Somers
  - Zebra -- Fridolin Somers
  - Accounts -- Martin Renvoize

- Bug Wranglers:
  - Sally Healey

- Packaging Manager: Mason James


- Documentation Manager: David Nind


- Documentation Team:
  - Lucy Vaux-Harvey
  - David Nind

- Translation Managers: 
  - Bernardo González Kriegel

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

We thank the following individuals who contributed patches to Koha 19.11.22

- Tomás Cohen Arazi (12)
- Nick Clemens (1)
- David Cook (1)
- Jonathan Druart (12)
- Marcel de Rooy (4)
- Fridolin Somers (1)
- Koha translators (1)
- Petro Vashchuk (1)
- Wainui Witika-Park (10)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 19.11.22

- BibLibre (1)
- ByWater-Solutions (1)
- Catalyst (10)
- Independant Individuals (1)
- Koha Community Developers (12)
- Prosentient Systems (1)
- Rijks Museum (4)
- Theke Solutions (12)

We also especially thank the following individuals who tested patches
for Koha

- Tomás Cohen Arazi (2)
- Nick Clemens (7)
- Alvaro Cornejo (1)
- Jonathan Druart (3)
- Katrin Fischer (2)
- Lucas Gass (2)
- Victor Grousset (12)
- Kyle M Hall (10)
- Owen Leonard (2)
- Julian Maurice (1)
- Martin Renvoize (9)
- Marcel de Rooy (14)
- Fridolin Somers (6)
- Wainui Witika-Park (32)



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

Autogenerated release notes updated last on 20 Sep 2021 12:15:22.
