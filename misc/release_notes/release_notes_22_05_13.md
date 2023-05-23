# RELEASE NOTES FOR KOHA 22.05.13
23 May 2023

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 22.05.13 can be downloaded from:

- [Download](http://download.koha-community.org/koha-22.05.13.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 22.05.13 is a bugfix/maintenance release.

It includes 1 enhancements, 32 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha [here](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).




## Enhancements

### Templates

- [[33077]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33077) Improve ease of translating template title tags


## Critical bugs fixed

### Acquisitions

- [[33262]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33262) When an ordered record is deleted, we lose all information on what was ordered

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

### Tools

- [[33156]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33156) Batch patron modification tool is missing search bar and other attributes

### Web services

- [[33504]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33504) ILS-DI does not record renewer_id for renewals creating issue with renewal history view


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

### Circulation

- [[18398]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18398) CHECKIN/CHECKOUT/RENEWAL don't use AutoEmailPrimaryAddress but first valid e-mail

  >This enhancement applies the EmailFieldPrimary (formerly AutoEmailPrimaryAddress) system preference choice to the CHECKIN, CHECKOUT, RENEWAL and various RECALL notices.

### Hold requests

- [[33210]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33210) (Bug 31963 follow-up) No hold fee message on OPAC should be displayed when there is no fee

### I18N/L10N

- [[33323]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33323) Select button in patron search modal is not translatable

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

- [[32127]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32127) Sort patron categories by description in templates
- [[32642]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32642) Loading spinner always visible when cover image is short (OPAC)
- [[33579]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33579) Typo: record record
- [[33597]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33597) Get rid of few SameSite warnings

### Tools

- [[32041]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32041) OPAC and staff client results page do not honor SyndeticsCoverImageSize



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/22.05/ar/html/) (28.2%)
- [Chinese (Taiwan)](https://koha-community.org/manual/22.05/zh_TW/html/) (93.9%)
- [English (USA)](https://koha-community.org/manual/22.05/en/html/)
- [French](https://koha-community.org/manual/22.05/fr/html/) (66.1%)
- [German](https://koha-community.org/manual/22.05/de/html/) (68.5%)
- [Hindi](https://koha-community.org/manual/22.05/hi/html/) (100%)
- [Italian](https://koha-community.org/manual/22.05/it/html/) (41.2%)
- [Spanish](https://koha-community.org/manual/22.05/es/html/) (29.9%)
- [Turkish](https://koha-community.org/manual/22.05/tr/html/) (33.5%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (77.8%)
- Armenian (100%)
- Armenian (Classical) (69.8%)
- Bulgarian (85.5%)
- Chinese (Taiwan) (95.5%)
- Czech (62.3%)
- English (New Zealand) (68.5%)
- English (USA)
- Finnish (95%)
- French (100%)
- French (Canada) (99.7%)
- German (100%)
- German (Switzerland) (54.1%)
- Greek (55.6%)
- Hindi (100%)
- Italian (100%)
- Nederlands-Nederland (Dutch-The Netherlands) (85.3%)
- Norwegian Bokmål (55.9%)
- Persian (58.7%)
- Polish (100%)
- Portuguese (87.3%)
- Portuguese (Brazil) (77.9%)
- Russian (78.3%)
- Slovak (64%)
- Spanish (100%)
- Swedish (78.4%)
- Telugu (84.5%)
- Turkish (95.3%)
- Ukrainian (74.1%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 22.05.13 is


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
  - 22.11 -- PTFS Europe (Martin Renvoize, Matt Blenkinsop, Jacob O'Mara, Pedro Amorim)
  - 22.05 -- Lucas Gass
  - 21.11 -- Arthur Suzuki
  - 21.05 -- Wainui Witika-Park

## Credits

We thank the following individuals who contributed patches to Koha 22.05.13

- Jérémy Breuillard (1)
- Galen Charlton (1)
- Nick Clemens (3)
- David Cook (1)
- Jonathan Druart (2)
- Magnus Enger (2)
- Katrin Fischer (11)
- Lucas Gass (10)
- Kyle M Hall (2)
- Mason James (1)
- Janusz Kaczmarek (3)
- Owen Leonard (2)
- Philip Orr (1)
- Martin Renvoize (3)
- Marcel de Rooy (7)
- Fridolin Somers (5)
- Koha translators (1)
- Hammat Wele (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 22.05.13

- Athens County Public Libraries (2)
- BibLibre (6)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (11)
- ByWater-Solutions (15)
- Equinox Open Library Initiative (1)
- Independant Individuals (3)
- Koha Community Developers (2)
- KohaAloha (1)
- Libriotech (2)
- lmscloud.de (1)
- Prosentient Systems (1)
- PTFS-Europe (3)
- Rijksmuseum (7)
- Solutions inLibro inc (1)

We also especially thank the following individuals who tested patches
for Koha

- Aleisha Amohia (1)
- Tomás Cohen Arazi (45)
- Matt Blenkinsop (13)
- Kevin Carnes (1)
- Nick Clemens (15)
- Jonathan Druart (6)
- Magnus Enger (1)
- Laura Escamilla (1)
- Katrin Fischer (13)
- Brendan Gallagher (1)
- Lucas Gass (50)
- Victor Grousset (1)
- Kyle M Hall (1)
- Sally Healey (1)
- Barbara Johnson (2)
- Owen Leonard (2)
- Marius Mandrescu (1)
- David Nind (18)
- Jacob O'Mara (15)
- Séverine Queune (1)
- Martin Renvoize (20)
- Phil Ringnalda (1)
- Marcel de Rooy (8)
- Caroline Cyr La Rose (2)
- Michaela Sieber (1)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is security-22.05.x-security.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 23 May 2023 16:24:35.
