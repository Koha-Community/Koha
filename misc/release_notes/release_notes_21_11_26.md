# RELEASE NOTES FOR KOHA 21.11.26
01 déc. 2023

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 21.11.26 can be downloaded from:

- [Download](http://download.koha-community.org/koha-21.11.26.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 21.11.26 is a bugfix/maintenance release.

It includes 6 enhancements, 2 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [35290](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35290) SQL Injection vulnerability in ysearch.pl
- [35291](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35291) File Upload vulnerability in upload-cover-image.pl

## Bugfixes

### Architecture, internals, and plumbing

#### Other bugs fixed

- [32978](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32978) 'npm install' fails in ktd on aarch64, giving unsupported architecture error for node-sass

## Enhancements 

### Architecture, internals, and plumbing

#### Enhancements

- [35079](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35079) Add option to gulp tasks po:update and po:create to control if POT should be built
- [35103](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35103) Add option to gulp tasks to pass a list of tasks
- [35174](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35174) Remove .po files from the codebase

### I18N/L10N

#### Enhancements

- [30373](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30373) Rewrite UNIMARC installer data to YAML
- [30476](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30476) Remove NORMARC translation files

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Chinese (Traditional)](https://koha-community.org/manual/21.11//html/) (53%)
- [English](https://koha-community.org/manual/21.11//html/) (100%)
- [English (USA)](https://koha-community.org/manual/21.11/en/html/)
- [French](https://koha-community.org/manual/21.11/fr/html/) (41%)
- [German](https://koha-community.org/manual/21.11/de/html/) (42%)
- [Hindi](https://koha-community.org/manual/21.11/hi/html/) (70%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (88%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Dutch (100%)
- English (100%)
- English (New Zealand) (99%)
- English (USA)
- Finnish (94%)
- French (100%)
- French (Canada) (89%)
- German (100%)
- Hindi (100%)
- Italian (100%)
- Polish (100%)
- Portuguese (Brazil) (90%)
- Spanish (100%)
- Telugu (89%)
- Turkish (100%)
- hyw_ARMN (generated) (hyw_ARMN) (82%)
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

The release team for Koha 21.11.26 is


- Release Manager: Jonathan Druart

- Release Manager assistants:
  - Martin Renvoize
  - Tomás Cohen Arazi

- QA Manager: Katrin Fischer

- QA Team:
  - Agustín Moyano
  - Andrew Nugged
  - David Cook
  - Joonas Kylmälä
  - Julian Maurice
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
  - Elasticsearch -- Fridolin Somers
  - Zebra -- Fridolin Somers
  - Accounts -- Martin Renvoize

- Bug Wranglers:
  - Sally Healey

- Packaging Manager: Mason James

- Documentation Manager: David Nind

- Documentation Team:
  - David Nind
  - Lucy Vaux-Harvey

- Translation Manager: Bernardo González Kriegel


- Wiki curators: 
  - Thomas Dukleth

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



We thank the following individuals who contributed patches to Koha 21.11.26
<div style="column-count: 2;">

- Aleisha Amohia (1)
- David Cook (3)
- Jonathan Druart (9)
- Mason James (1)
- Bernardo González Kriegel (2)
- Owen Leonard (2)
- Julian Maurice (2)
- Danyon Sewell (4)
- Koha translators (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 21.11.26
<div style="column-count: 2;">

- Athens County Public Libraries (2)
- BibLibre (2)
- Catalyst (4)
- Catalyst Open Source Academy (1)
- Koha Community Developers (9)
- KohaAloha (1)
- Prosentient Systems (3)
- Universidad Nacional de Córdoba (2)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Aleisha Amohia (3)
- Tomás Cohen Arazi (6)
- Nick Clemens (5)
- David Cook (1)
- Paul Derscheid (1)
- Jonathan Druart (9)
- Owen Leonard (1)
- Martin Renvoize (1)
- Fridolin Somers (2)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 21.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 01 déc. 2023 07:07:27.
