# RELEASE NOTES FOR KOHA 18.11.13
21 Jan 2020

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 18.11.13 can be downloaded from:

- [Download](http://download.koha-community.org/koha-18.11.13.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 18.11.13 is a bugfix/maintenance release.

It includes 1 enhancements, 16 bugfixes.

### System requirements

Koha is continiously tested against the following configurations and as such these are the recommendations for 
deployment: 

- Debian Jessie with MySQL 5.5
- Debian Stretch with MariaDB 10.1 (MySQL 8.0 support is experimental)
- Ubuntu Bionic with MariaDB 10.1 (MariaDB 10.3 support is experimental) 

Additional notes:
    
- Perl 5.10 is required
- Zebra or Elasticsearch is required




## Enhancements

### MARC Bibliographic data support

- [[23731]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23731) Display LC call number in OPAC and staff detail pages

  >This enhancement enables the display of the LOC classification number in the OPAC an staff client.


## Critical bugs fixed

### Hold requests

- [[20948]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20948) Item-level hold info displayed regardless its priority (detail.pl)

### Notices

- [[23181]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23181) Unable to use payment library in ACCOUNT_PAYMENT or ACCOUNT_WRITEOFF notices

### REST API

- [[24191]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24191) Sorting doesn't use to_model

  **Sponsored by** *ByWater Solutions*

### Searching

- [[23970]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23970) itemsearch - publication date not taken into account if not used in the first field


## Other bugs fixed

### Acquisitions

- [[5365]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=5365) It should be more clear how to reopen a basket in a basket group

### Cataloging

- [[24090]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24090) Subfield text in red when mandatory in record edition

### Circulation

- [[24166]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24166) Barcode removal breaks circulation.pl/moremember.pl

### I18N/L10N

- [[18688]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18688) Warnings about UTF-8 charset when creating a new language
- [[24046]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24046) 'Activate filters' untranslatable

### ILL

- [[21270]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21270) "Not finding what you're looking" display needs to be fixed

### OPAC

- [[24240]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24240) List on opac missing close form tag under some conditions
- [[24245]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24245) opac-registration-confirmation.tt has incorrect HTML body id

### Reports

- [[13806]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13806) No input sanitization where creating Reports subgroup

### Searching

- [[24121]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24121) Item types icons in intra search results are requesting icons from opac images path

  **Sponsored by** *Governo Regional dos Açores*

### Templates

- [[24104]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24104) Item search - dropdown buttons overflow
- [[24230]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24230) intranet_js plugin hook is after body end tag


## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://koha-community.org/manual/18.11/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (98%)
- Armenian (99.9%)
- Basque (65.8%)
- Chinese (China) (63.9%)
- Chinese (Taiwan) (99.1%)
- Czech (93.6%)
- Danish (55.2%)
- English (New Zealand) (88.1%)
- English (USA)
- Finnish (84.2%)
- French (99.9%)
- French (Canada) (98.9%)
- German (100%)
- German (Switzerland) (91.5%)
- Greek (78.6%)
- Hindi (100%)
- Italian (93.6%)
- Norwegian Bokmål (94.4%)
- Occitan (post 1500) (59.4%)
- Polish (86.4%)
- Portuguese (100%)
- Portuguese (Brazil) (87.2%)
- Slovak (89.7%)
- Spanish (99.9%)
- Swedish (90.1%)
- Tetun (53.7%)
- Turkish (98%)
- Ukrainian (61.9%)
- Vietnamese (54.5%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 18.11.13 is


- Release Manager: Martin Renvoize

- Release Manager assistants:
  - Tomás Cohen Arazi
  - Jonathan Druart

- QA Manager: Katrin Fischer

- QA Team:
  - Jonathan Druart
  - Marcel de Rooy
  - Joonas Kylmälä
  - Josef Moravec
  - Tomás Cohen Arazi
  - Nick Clemens
  - Kyle Hall

- Topic Experts:
  - SIP2 -- Colin Campbell
  - EDI -- Colin Campbell
  - Elasticsearch -- Fridolin Somers
  - REST API -- Tomás Cohen Arazi
  - ILS-DI -- Arthur Suzuki
  - UI Design -- Owen Leonard
  - ILL -- Andrew Isherwood

- Bug Wranglers:
  - Michal Denár
  - Cori Lynn Arnold
  - Lisette Scheer
  - Amit Gupta

- Packaging Managers:
  - Mirko Tietgen
  - Mason James

- Documentation Managers:
  - Caroline Cyr La Rose
  - David Nind

- Documentation Team:
  - Donna Bachowski
  - Lucy Vaux-Harvey
  - Sugandha Bajaj

- Translation Managers: 
  - Bernardo González Kriegel

- Release Maintainers:
  - 19.11 -- Joy Nelson
  - 19.05 -- Lucas Gass
  - 18.11 -- Hayley Mapley

- Release Maintainer mentors:
  - 19.11 -- Martin Renvoize
  - 19.05 -- Nick Clemens
  - 18.11 -- Chris Cormack

## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 18.11.13:

- [ByWater Solutions](https://bywatersolutions.com/)
- Governo Regional dos Açores

We thank the following individuals who contributed patches to Koha 18.11.13.

- Pedro Amorim (1)
- Tomás Cohen Arazi (3)
- Philippe Blouin (1)
- Nick Clemens (1)
- Jonathan Druart (8)
- Katrin Fischer (1)
- Lucas Gass (2)
- Kyle Hall (1)
- Bernardo González Kriegel (1)
- Owen Leonard (1)
- Hayley Mapley (1)
- Maryse Simard (1)
- Fridolin Somers (2)
- Koha Translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 18.11.13

- ACPL (1)
- BibLibre (2)
- BSZ BW (1)
- ByWater-Solutions (4)
- Catalyst (1)
- Independant Individuals (1)
- Koha Community Developers (8)
- Solutions inLibro inc (2)
- Theke Solutions (3)
- Universidad Nacional de Córdoba (1)

We also especially thank the following individuals who tested patches
for Koha.

- Jonathan Druart (5)
- Katrin Fischer (6)
- Lucas Gass (22)
- Andrew Isherwood (1)
- Dilan Johnpullé (1)
- Joonas Kylmälä (1)
- Nicolas Legrand (1)
- Owen Leonard (7)
- Hayley Mapley (23)
- Kelly McElligott (1)
- Josef Moravec (5)
- Joy Nelson (19)
- Séverine Queune (1)
- Martin Renvoize (22)
- Marcel de Rooy (8)
- Lisette Scheer (2)
- Fridolin Somers (2)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 18.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 21 Jan 2020 01:08:03.
