# RELEASE NOTES FOR KOHA 20.05.13
24 Jun 2021

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 20.05.13 can be downloaded from:

- [Download](https://download.koha-community.org/koha-20.05.13.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 20.05.13 is a bugfix/maintenance release with security fixes.

It includes 1 security fixes, 3 enhancements, 11 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations


## Security bugs

### Koha

- [[28409]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28409) Category should be validated in opac-shelves.pl


## Enhancements

### Architecture, internals, and plumbing

- [[26394]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26394) .mailmap needs to be updated

  >The .mailmap file is used to map author and committer names and email addresses to canonical real names and email addresses. It has been improved to reflect the current project's history.
  >It helps to have a cleaner authors list and prevents duplicate
  >http://git.koha-community.org/stats/koha-master/authors.html
- [[26621]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26621) .mailmap adjustments
- [[28386]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28386) Replace dev_map.yaml from release_tools with .mailmap


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[28200]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28200) Net::Netmask 1.9104-2 requires constructor change for backwards compatibility

  >The code library Koha uses for working with IP addresses has dropped support for abbreviated values in recent releases.  This is to tighten up the default security of input value's and we have opted in Koha to follow this change through into our system preferences for the same reason.
  >
  >WARNING: `koha_trusted_proxies` and `ILS-DI:AuthorizedIPs` are both affected. Please check that you are not using abbreviated IP forms for either of these cases. Example: "10.10" is much less explicit than "10.10.0.0/16" and should be avoided.

### Circulation

- [[28538]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28538) Regression - Date of birth entered without correct format causes internal server error

### Fines and fees

- [[28482]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28482) Floating point math prevents items from being returned

### Hold requests

- [[28503]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28503) When ReservesControlBranch = "patron's home library" and Hold policy = "From home library" all holds are allowed

### I18N/L10N

- [[28419]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28419) Page addorderiso2709.pl is untranslatable

### Notices

- [[28487]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28487) Overdue_notices does not fall back to default language

  >Previously overdue notices exclusively used the default language, but bug 26420 changed this to the opposite - to exclusively use the language chosen by the patron.
  >
  >However, if there is no translation for the overdue notice for the language chosen by the patron then no message is sent.
  >
  >This fixes this so that if there is no translation of the overdue notice for the language chosen by the patron, then the default language notice is used.

### Packaging

- [[28364]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28364) koha-z3950-responder breaks because of log4perl.conf permissions

### REST API

- [[23653]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23653) Plack fails when http://swagger.io/v2/schema.json is unavailable and schema cache missing

### Searching

- [[28475]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28475) Searching all headings returns no results

  **Sponsored by** *Asociación Latinoamericana de Integración*


## Other bugs fixed

### About

- [[27495]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27495) The "Accessibility advocate" role is not yet listed in the about page.
- [[28442]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28442) Release team 21.11



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/20.05/ar/html/) (43.3%)
- [Chinese (Taiwan)](https://koha-community.org/manual/20.05/zh_TW/html/) (100%)
- [Czech](https://koha-community.org/manual/20.05/cs/html/) (33.1%)
- [English (USA)](https://koha-community.org/manual/20.05/en/html/)
- [French](https://koha-community.org/manual/20.05/fr/html/) (67.9%)
- [French (Canada)](https://koha-community.org/manual/20.05/fr_CA/html/) (31.2%)
- [German](https://koha-community.org/manual/20.05/de/html/) (72.3%)
- [Hindi](https://koha-community.org/manual/20.05/hi/html/) (100%)
- [Italian](https://koha-community.org/manual/20.05/it/html/) (78.9%)
- [Spanish](https://koha-community.org/manual/20.05/es/html/) (58.5%)
- [Turkish](https://koha-community.org/manual/20.05/tr/html/) (70.2%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (98.3%)
- Armenian (100%)
- Armenian (Classical) (99.7%)
- Chinese (Taiwan) (94%)
- Czech (80.5%)
- English (New Zealand) (66.5%)
- English (USA)
- Finnish (70.3%)
- French (86.2%)
- French (Canada) (96.9%)
- German (100%)
- German (Switzerland) (74.2%)
- Greek (62%)
- Hindi (100%)
- Italian (99.7%)
- Norwegian Bokmål (70.8%)
- Polish (79.3%)
- Portuguese (86.4%)
- Portuguese (Brazil) (97.7%)
- Russian (86.2%)
- Slovak (89.4%)
- Spanish (99.7%)
- Swedish (79.3%)
- Telugu (99.9%)
- Turkish (100%)
- Ukrainian (66.1%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](https://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](https://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](https://translate.koha-community.org/)

## Release Team

The release team for Koha 20.05.13 is


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
  - Josef Moravec
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

- Packaging Manager:
  - Mason James

- Documentation Manager: David Nind


- Documentation Team:
  - Lucy Vaux-Harvey
  - David Nind

- Translation Managers: 
  - Bernardo González Kriegel

- Release Maintainers:
  - 21.05 -- Kyle Hall
  - 20.11 -- Fridolin Somers
  - 20.05 -- Victor Grousset
  - 19.11 -- Wainui Witika-Park

## Credits
We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 20.05.13

- Asociación Latinoamericana de Integración

We thank the following individuals who contributed patches to Koha 20.05.13

- Tomás Cohen Arazi (4)
- Eden Bacani (1)
- Nick Clemens (5)
- David Cook (3)
- Jonathan Druart (27)
- Victor Grousset (5)
- Martin Renvoize (4)
- Fridolin Somers (1)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 20.05.13

- BibLibre (1)
- ByWater-Solutions (5)
- Independant Individuals (5)
- Koha Community Developers (28)
- Prosentient Systems (3)
- PTFS-Europe (4)
- Theke Solutions (4)

We also especially thank the following individuals who tested patches
for Koha

- Tomás Cohen Arazi (6)
- Nick Clemens (2)
- Alvaro Cornejo (1)
- Jonathan Druart (18)
- Katrin Fischer (3)
- Andrew Fuerste-Henry (1)
- Lucas Gass (1)
- Victor Grousset (50)
- Kyle M Hall (10)
- Ere Maijala (1)
- David Nind (3)
- Martin Renvoize (20)
- Marcel de Rooy (1)
- Fridolin Somers (36)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 20.05.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 24 Jun 2021 22:46:52.
