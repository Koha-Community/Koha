# RELEASE NOTES FOR KOHA 19.11.19
27 Jun 2021

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 19.11.19 can be downloaded from:

- [Download](http://download.koha-community.org/koha-19.11.19.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 19.11.19 is a bugfix/maintenance release with security fixes.

It includes 1 security fixes, 2 enhancements, 4 bugfixes.

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


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[28302]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28302) Koha does not work with CGI::Compile 0.24

### I18N/L10N

- [[28419]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28419) Page addorderiso2709.pl is untranslatable

### Packaging

- [[28364]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28364) koha-z3950-responder breaks because of log4perl.conf permissions


## Other bugs fixed

### Architecture, internals, and plumbing

- [[28367]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28367) Wrong plack condition in C4/Auth_with_shibboleth.pm



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/19.11/ar/html/) (42.4%)
- [Chinese (Taiwan)](https://koha-community.org/manual/19.11/zh_TW/html/) (90%)
- [Czech](https://koha-community.org/manual/19.11/cs/html/) (33.4%)
- [English (USA)](https://koha-community.org/manual/19.11/en/html/)
- [French](https://koha-community.org/manual/19.11/fr/html/) (68.5%)
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
- Catalan; Valencian (50.5%)
- Chinese (China) (56.9%)
- Chinese (Taiwan) (98.6%)
- Czech (90.8%)
- English (New Zealand) (78.3%)
- English (USA)
- Finnish (74.2%)
- French (99.5%)
- French (Canada) (93.8%)
- German (100%)
- German (Switzerland) (80.8%)
- Greek (71.2%)
- Hindi (100%)
- Italian (87%)
- Nederlands-Nederland (Dutch-The Netherlands) (85.5%)
- Norwegian Bokmål (83.3%)
- Occitan (post 1500) (53%)
- Polish (85.6%)
- Portuguese (99.4%)
- Portuguese (Brazil) (100%)
- Slovak (83.1%)
- Spanish (100%)
- Swedish (85.1%)
- Telugu (100%)
- Turkish (100%)
- Ukrainian (75.1%)
- Vietnamese (51.5%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 19.11.19 is


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

- Packaging Managers:
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

We thank the following individuals who contributed patches to Koha 19.11.19

- Tomás Cohen Arazi (1)
- David Cook (1)
- Jonathan Druart (8)
- Mason James (1)
- Koha translators (1)
- Wainui Witika-Park (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 19.11.19

- Catalyst (1)
- Koha Community Developers (8)
- KohaAloha (1)
- Prosentient Systems (1)
- Theke Solutions (1)

We also especially thank the following individuals who tested patches
for Koha

- Jonathan Druart (1)
- Katrin Fischer (1)
- Andrew Fuerste-Henry (2)
- Victor Grousset (13)
- Kyle M Hall (2)
- Ere Maijala (1)
- Martin Renvoize (5)
- Marcel de Rooy (1)
- Fridolin Somers (5)
- Wainui Witika-Park (8)



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

Autogenerated release notes updated last on 27 Jun 2021 06:07:32.
