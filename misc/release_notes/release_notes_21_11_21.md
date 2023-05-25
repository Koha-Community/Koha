# RELEASE NOTES FOR KOHA 21.11.21
25 May 2023

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 21.11.21 can be downloaded from:

- [Download](http://download.koha-community.org/koha-21.11.21.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 21.11.21 is a bugfix/maintenance release with security fixes.

It includes 1 security fixes, 1 enhancements, 23 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations


## Security bugs

### Koha

- [[33702]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33702) Patrons should only see their own ILLs in the OPAC


## Enhancements

### Templates

- [[33077]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33077) Improve ease of translating template title tags


## Critical bugs fixed

### Cataloging

- [[33375]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33375) Advanced editor crashes when using MySQL 8 due to reserved rank keyword

### Command-line Utilities

- [[33603]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33603) misc/maintenance/search_for_data_inconsistencies.pl fails if biblio.biblionumber on control field

### I18N/L10N

- [[30352]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30352) "Not for loan" in result list doesn't translate in OPAC

### Packaging

- [[33629]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33629) allow pbuilder to use network via build-git-snapshot

### SIP2

- [[33216]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33216) SIP fee paid messages explode if payment registers are enabled and the SIP account has no register


## Other bugs fixed

### Acquisitions

- [[33238]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33238) Error adding suggestion to basket as non-superlibrarian (Bug 29886 follow-up)

### Architecture, internals, and plumbing

- [[32716]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32716) update NGINX config examples to increase proxy_buffer_size

  >Set proxy_buffer_size in the example NGINX configuration to reduce chances that REST API responses that use pagination get dropped by NGINX
- [[33088]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33088) background-job-progressbar.js no longer needed in batch_record_modification.tt
- [[33367]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33367) tmp/modified_authorities/README.txt seems useless

### Cataloging

- [[32253]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32253) Advanced cataloging editor doesn't load every line initially

### MARC Bibliographic data support

- [[31432]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31432) MARC21: Make 245 n and p subfields visible in frameworks by default

### OPAC

- [[29311]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29311) Do not allow editing of bibliographic information when entering suggestion from existing bibs

### Reports

- [[27513]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27513) Add description to reports page

### Searching

- [[33506]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33506) Series has wrong index name on scan index page and search option selection is not retained

### Searching - Elasticsearch

- [[31695]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31695) Type standard number is missing field ci_raw in field_config.yaml

### Self checkout

- [[32921]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32921) SelfCheckTimeout doesn't logout if SelfCheckReceiptPrompt modal is open

### Serials

- [[33040]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33040) Add "Date published (text)" to serials tab on record view (detail.pl)

### Staff interface

- [[32301]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32301) Show correct defaultSortField in staff interface advanced search
- [[33505]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33505) Improve styling of scan index page

### System Administration

- [[33509]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33509) Staff search result list shows "other holdings" with AlternateHoldingsField when there are no alternate holdings
- [[33634]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33634) Sidebar navigation links in system preferences not taking user to the clicked section

### Templates

- [[32642]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32642) Loading spinner always visible when cover image is short (OPAC)
- [[33597]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33597) Get rid of few SameSite warnings



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/21.11/ar/html/) (33.8%)
- [Chinese (Taiwan)](https://koha-community.org/manual/21.11/zh_TW/html/) (58.8%)
- [Czech](https://koha-community.org/manual/21.11/cs/html/) (27.2%)
- [English (USA)](https://koha-community.org/manual/21.11/en/html/)
- [French](https://koha-community.org/manual/21.11/fr/html/) (70.9%)
- [French (Canada)](https://koha-community.org/manual/21.11/fr_CA/html/) (25.6%)
- [German](https://koha-community.org/manual/21.11/de/html/) (73.3%)
- [Hindi](https://koha-community.org/manual/21.11/hi/html/) (100%)
- [Italian](https://koha-community.org/manual/21.11/it/html/) (48.2%)
- [Spanish](https://koha-community.org/manual/21.11/es/html/) (36.2%)
- [Turkish](https://koha-community.org/manual/21.11/tr/html/) (39.6%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (86.3%)
- Armenian (100%)
- Armenian (Classical) (76%)
- Bulgarian (100%)
- Chinese (Taiwan) (78.5%)
- Czech (76.9%)
- English (New Zealand) (60.1%)
- English (USA)
- Finnish (98.9%)
- French (100%)
- French (Canada) (91.7%)
- German (100%)
- German (Switzerland) (58.1%)
- Greek (61.1%)
- Hindi (100%)
- Italian (99.9%)
- Nederlands-Nederland (Dutch-The Netherlands) (86.2%)
- Norwegian Bokmål (62.4%)
- Polish (100%)
- Portuguese (91.1%)
- Portuguese (Brazil) (83.4%)
- Russian (83.9%)
- Slovak (74.8%)
- Spanish (100%)
- Swedish (81.3%)
- Telugu (94%)
- Turkish (99.8%)
- Ukrainian (75.1%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 21.11.21 is


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

- Packaging Manager: 


- Documentation Manager: David Nind


- Documentation Team:
  - David Nind
  - Lucy Vaux-Harvey

- Translation Managers: 
  - Bernardo González Kriegel

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

We thank the following individuals who contributed patches to Koha 21.11.21

- jeremy breuillard (1)
- Galen Charlton (1)
- Nick Clemens (3)
- David Cook (1)
- Jonathan Druart (2)
- Magnus Enger (1)
- Katrin Fischer (6)
- Lucas Gass (3)
- Kyle M Hall (2)
- Mason James (3)
- Janusz Kaczmarek (1)
- Owen Leonard (1)
- Philip Orr (1)
- Marcel de Rooy (7)
- Fridolin Somers (3)
- Arthur Suzuki (2)
- Koha translators (1)
- Hammat Wele (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 21.11.21

- Athens County Public Libraries (1)
- BibLibre (6)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (6)
- ByWater-Solutions (8)
- Equinox Open Library Initiative (1)
- Independant Individuals (1)
- Koha Community Developers (2)
- KohaAloha (3)
- Libriotech (1)
- lmscloud.de (1)
- Prosentient Systems (1)
- Rijksmuseum (7)
- Solutions inLibro inc (1)

We also especially thank the following individuals who tested patches
for Koha

- Aleisha Amohia (1)
- Tomás Cohen Arazi (30)
- Matt Blenkinsop (10)
- Kevin Carnes (1)
- Nick Clemens (7)
- Jonathan Druart (5)
- Laura Escamilla (1)
- Katrin Fischer (7)
- Brendan Gallagher (1)
- Lucas Gass (30)
- Victor Grousset (1)
- Kyle M Hall (1)
- Barbara Johnson (1)
- Owen Leonard (1)
- Marius Mandrescu (1)
- David Nind (10)
- Jacob O'Mara (11)
- Séverine Queune (1)
- Martin Renvoize (13)
- Phil Ringnalda (1)
- Marcel de Rooy (8)
- Caroline Cyr La Rose (1)
- Michaela Sieber (1)
- Arthur Suzuki (32)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 21.11.x-security.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 25 May 2023 13:50:45.
