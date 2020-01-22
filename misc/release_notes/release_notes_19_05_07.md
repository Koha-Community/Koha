# RELEASE NOTES FOR KOHA 19.05.07
22 Jan 2020

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 19.05.07 can be downloaded from:

- [Download](http://download.koha-community.org/koha-19.05.07.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 19.05.07 is a bugfix/maintenance release.

It includes 8 enhancements, 42 bugfixes.

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

### Cataloging

- [[24173]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24173) Advanced Editor: Show subtitle & published date on the search page

  >This enhancement adds Subtitle (all parts) and date published to the results that come up for the Advanced Editor Search.

### Circulation

- [[24308]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24308) Suggestions table on suggestions.pl should have separate columns for dates

### I18N/L10N

- [[24063]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24063) Add Sami language characters to Zebra

  >This patch adds some additional characters to the default zebra mappings for Sami languages to aid in searching on systems with such data present.

### Installation and upgrade (web-based installer)

- [[24314]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24314) Update de-DE MARC21 frameworks for updates 28+29 (May and November 2019)

### MARC Bibliographic data support

- [[23731]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23731) Display LC call number in OPAC and staff detail pages

  >This enhancement enables the display of the LOC classification number in the OPAC an staff client.
- [[24312]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24312) Update MARC21 frameworks to Updates 28+29 (May and November 2019)

### Templates

- [[10469]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10469) Display more when editing subfields in frameworks
- [[23889]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23889) Improve style of menu header in advanced cataloging editor

  >This enhancement updates the styling of dropdown menu headers to make them apply more consistently across the system.


## Critical bugs fixed

### Acquisitions

- [[24242]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24242) Funds with no library assigned do not appear on edit suggestions page
- [[24244]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24244) Cannot create suggestion with branch set to 'Any'

### Circulation

- [[23382]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23382) Issuing rules failing after bug 20912
- [[24259]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24259) Circulation fails if no circ rule defined but checkout override confirmed

### Hold requests

- [[20948]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20948) Item-level hold info displayed regardless its priority (detail.pl)

### Installation and upgrade (web-based installer)

- [[24137]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24137) Marc21 bibliographic fails to install for ru-Ru and uk-UA

### Notices

- [[24235]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24235) /misc/cronjobs/advance_notices.pl DUEDGST does NOT send sms, just e-mail

### REST API

- [[24191]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24191) Sorting doesn't use to_model

  **Sponsored by** *ByWater Solutions*

### Searching - Elasticsearch

- [[24264]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24264) Elasticsearch - Cannot search for genre/form authorities

### Serials

- [[21232]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21232) Problems when linking a subscription to a non-existing biblionumber


## Other bugs fixed

### Acquisitions

- [[5365]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=5365) It should be more clear how to reopen a basket in a basket group

### Architecture, internals, and plumbing

- [[23997]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23997) sample_z3950_servers.sql is failing on MySQL 8

### Cataloging

- [[11500]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11500) Use dateformat syspref and datepicker on additems.pl (and other item cataloguing pages)
- [[24090]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24090) Subfield text in red when mandatory in record edition
- [[24232]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24232) Fix permissions for deleting a bib record after attaching the last item to another bib

### Circulation

- [[24166]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24166) Barcode removal breaks circulation.pl/moremember.pl
- [[24335]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24335) Cannot mark checkout notes seen/not seen in bulk
- [[24337]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24337) Checkout note cannot be marked seen if more than 20 exist

### Command-line Utilities

- [[19465]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19465) Allow choosing Elasticsearch server on instance creation

### Course reserves

- [[24283]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24283) Missing close parens and closing strong tag in course reserves

### Database

- [[23995]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23995) Check constraints are supported differently by MySQL and MariaDB so we should remove them for now.

### I18N/L10N

- [[18688]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18688) Warnings about UTF-8 charset when creating a new language
- [[24046]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24046) 'Activate filters' untranslatable
- [[24358]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24358) "Bibliographic record does not exist!" is not translatable

### ILL

- [[21270]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21270) "Not finding what you're looking" display needs to be fixed

### Installation and upgrade (command-line installer)

- [[24328]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24328) Bibliographic frameworks fail to install

### MARC Authority data support

- [[24267]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24267) C4::Breeding::ImportBreedingAuth is ineffective

### MARC Bibliographic data support

- [[24274]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24274) New installations should not contain field 01e Coded field error (RLIN)
- [[24281]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24281) Fix the list of types of visual materials

### OPAC

- [[24212]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24212) OPAC send list dialog opens too small in IE

  **Sponsored by** *Toi Ohomai Institute of Technology*
- [[24240]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24240) List on opac missing close form tag under some conditions
- [[24245]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24245) opac-registration-confirmation.tt has incorrect HTML body id

### Reports

- [[13806]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13806) No input sanitization where creating Reports subgroup

### Searching

- [[14419]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14419) Expanding facets (Show more) performs a new search
- [[24121]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24121) Item types icons in intra search results are requesting icons from opac images path

  **Sponsored by** *Governo Regional dos Açores*

### Staff Client

- [[22381]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22381) Wording on Calendar-related system preferences not standardized

### System Administration

- [[24184]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24184) Reword FallbackToSMSIfNoEmail syspref text

### Templates

- [[23956]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23956) Replace famfamfam calendar icon in staff client with CSS data-url
- [[24054]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24054) Typo in ClaimReturnedWarningThreshold system preference
- [[24104]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24104) Item search - dropdown buttons overflow
- [[24230]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24230) intranet_js plugin hook is after body end tag
- [[24282]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24282) SCSS conversion broke style in search results item status


## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://koha-community.org/manual/19.05/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (99.5%)
- Armenian (100%)
- Basque (59.8%)
- Chinese (China) (60.4%)
- Chinese (Taiwan) (99.5%)
- Czech (92.5%)
- Danish (52.6%)
- English (New Zealand) (83.4%)
- English (USA)
- Finnish (79.6%)
- French (99%)
- French (Canada) (99.9%)
- German (100%)
- German (Switzerland) (86.4%)
- Greek (74.1%)
- Hindi (100%)
- Italian (90.6%)
- Norwegian Bokmål (89.2%)
- Occitan (post 1500) (56.5%)
- Polish (83.3%)
- Portuguese (100%)
- Portuguese (Brazil) (94.6%)
- Slovak (84.7%)
- Spanish (99.7%)
- Swedish (88.7%)
- Turkish (98%)
- Ukrainian (73.3%)
- Vietnamese (51.3%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 19.05.07 is


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
new features in Koha 19.05.07:

- [ByWater Solutions](https://bywatersolutions.com/)
- Governo Regional dos Açores
- Toi Ohomai Institute of Technology

We thank the following individuals who contributed patches to Koha 19.05.07.

- Aleisha Amohia (1)
- Pedro Amorim (1)
- Tomás Cohen Arazi (7)
- Cori Lynn Arnold (1)
- Philippe Blouin (1)
- Nick Clemens (7)
- Jonathan Druart (20)
- Katrin Fischer (1)
- Lucas Gass (16)
- Pasi Kallinen (1)
- Bernardo González Kriegel (3)
- Owen Leonard (7)
- Martin Renvoize (13)
- Marcel de Rooy (2)
- Maryse Simard (2)
- Fridolin Somers (3)
- Koha Translators (1)
- Radek Šiman (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 19.05.07

- ACPL (7)
- BibLibre (3)
- BSZ BW (1)
- ByWater-Solutions (23)
- Independant Individuals (2)
- Koha Community Developers (20)
- koha-suomi.fi (1)
- PTFS-Europe (13)
- rbit.cz (1)
- Rijks Museum (2)
- Solutions inLibro inc (3)
- The Donohue Group (1)
- Theke Solutions (7)
- Universidad Nacional de Córdoba (3)

We also especially thank the following individuals who tested patches
for Koha.

- Tomás Cohen Arazi (3)
- Nick Clemens (13)
- Holly Cooper (3)
- Michal Denar (2)
- Jonathan Druart (37)
- Bouzid Fergani (1)
- Katrin Fischer (21)
- Andrew Fuerste-Henry (3)
- Lucas Gass (83)
- Andrew Isherwood (1)
- Dilan Johnpullé (1)
- Pasi Kallinen (1)
- Bernardo González Kriegel (7)
- Joonas Kylmälä (4)
- Nicolas Legrand (1)
- Owen Leonard (10)
- Kelly McElligott (3)
- Josef Moravec (5)
- Joy Nelson (57)
- Séverine Queune (1)
- Martin Renvoize (74)
- Marcel de Rooy (13)
- Lisette Scheer (2)
- Maryse Simard (1)
- Fridolin Somers (1)
- Myka Kennedy Stephens (1)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is rmain1905.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 22 Jan 2020 21:42:40.
