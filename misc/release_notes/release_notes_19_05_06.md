# RELEASE NOTES FOR KOHA 19.05.06
23 Dec 2019

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 19.05.06 can be downloaded from:

- [Download](http://download.koha-community.org/koha-19.05.06.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 19.05.06 is a bugfix/maintenance release.

It includes 2 enhancements, 34 bugfixes.

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

### Reports

- [[23389]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23389) Add 'All' option to report value dropdowns

  >This enhancement adds the ability to optionally include an `all` option in report placeholders allowing for an 'All' option to be displayed in filter select lists.
  >
  >**Usage**: `WHERE branchcode LIKE <<Branch|branches:all>>`

### Web services

- [[22677]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22677) Include hint on OAI-PMH URL for Koha in system preference


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[24243]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24243) Bad characters in MARC cause internal server error when searching catalog

### Circulation

- [[13958]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13958) Add a suspensionsCalendar syspref

  **Sponsored by** *Universidad Nacional de Córdoba*

  >Before 18.05, suspension expiry date calculation didn't take the calendar into account. This behaviour changed with bug 19204, and some libraries miss the old behaviour. 
  >
  >These patches decouple overdue days calculation configuration (`finesCalendar`) from how the expiry date is calculated for the suspension through a new system preference: `SuspensionsCalendar`, that has the exact same options but only applies to suspensions. On upgrade, the new preference is populated with the value from `finesCalendar`, thus respecting the current configuration.
- [[24075]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24075) Backdating a return to the exact due date and time results in the fine not being refunded
- [[24138]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24138) suspension miscalculated when Suspension charging interval bigger than 1 and Max. suspension duration  is defined

### Command-line Utilities

- [[24164]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24164) Patron emailer cronjob is not generating unique content for notices

### Hold requests

- [[24168]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24168) Errors with use of CanItemBeReserved return value

### Notices

- [[24064]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24064) DUEDGST typoed as DUEGST
- [[24072]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24072) Typos in advance_notices.pl causes DUEDGST not to be sent
- [[24268]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24268) advance_notices.pl dies on undefined letter

### Searching

- [[23970]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23970) itemsearch - publication date not taken into account if not used in the first field

### Searching - Elasticsearch

- [[23089]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23089) Elasticsearch - cannot sort on non-text fields


## Other bugs fixed

### About

- [[24136]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24136) Add libraries (sponsors) to the about page

### Architecture, internals, and plumbing

- [[24106]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24106) In returns.pl, don't search for item if no barcode is provided

### Circulation

- [[23427]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23427) Better sorting of previous checkouts
- [[24024]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24024) Holds Awaiting Pickup (Both Active and Expired) Sorts by Firstname

### Course reserves

- [[23952]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23952) Fix body id on OPAC course details page

### Fines and fees

- [[23483]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23483) When writing off a fine, the title of the patron is shown as description

### I18N/L10N

- [[13749]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13749) On loading holds in patron account 'processing' is not translatable

### MARC Bibliographic data support

- [[17831]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17831) Remove non-existing bibliosubject.subject mapping from frameworks

### OPAC

- [[23506]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23506) Sound material type displays wrong icon in OPAC/Staff details
- [[23785]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23785) Software error Can't call method "get_coins" on an undefined value at /usr/share/koha/opac/cgi-bin/opac/opac-search.pl line 692.

### Patrons

- [[21939]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21939) Permission for holds history tab is too strict

### Searching

- [[23768]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23768) ISBN search in IntranetCatalogPulldown searches nothing if passed an invalid ISBN and using SearchWithISBNVariations
- [[24120]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24120) Search terms in search dropdown must be URI filtered

### Searching - Elasticsearch

- [[24128]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24128) Add alias for biblionumber => local-number

### Staff Client

- [[23246]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23246) Record detail page jumps into the 'images' tab if no holdings

  **Sponsored by** *American Numismatics Society*
- [[23987]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23987) batchMod.pl provides a link back to the record after the record is deleted

### System Administration

- [[23751]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23751) Description of staffaccess permission should be improved
- [[24170]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24170) sysprefs search result does not have a consistent order

### Templates

- [[23954]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23954) Format notes in suggestion management

### Test Suite

- [[24144]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24144) regressions.t tests have not been updated after bug 23836
- [[24145]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24145) Auth.t is failing because of wrong mocked ->param
- [[24199]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24199) t/Auth_with_shibboleth.t is failing randomly

### Tools

- [[24124]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24124) Cannot select authorities in batch deletion tool in Chrome
## New sysprefs

- SuspensionsCalendar

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

- Arabic (99.8%)
- Armenian (100%)
- Basque (59.9%)
- Chinese (China) (60.5%)
- Chinese (Taiwan) (99.8%)
- Czech (92.7%)
- Danish (52.7%)
- English (New Zealand) (83.6%)
- English (USA)
- Finnish (79.8%)
- French (99.3%)
- French (Canada) (100%)
- German (100%)
- German (Switzerland) (86.7%)
- Greek (74.2%)
- Hindi (100%)
- Italian (90.9%)
- Norwegian Bokmål (89.5%)
- Occitan (post 1500) (56.6%)
- Polish (83.5%)
- Portuguese (100%)
- Portuguese (Brazil) (94.9%)
- Slovak (85%)
- Spanish (100%)
- Swedish (88.9%)
- Turkish (98.3%)
- Ukrainian (72.8%)
- Vietnamese (51.4%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 19.05.06 is


- Release Manager: Martin Renvoize

- Release Manager assistants:
  - Tomás Cohen Arazi
  - Nick Clemens

- QA Manager: Katrin Fischer

- QA Team:
  - Tomás Cohen Arazi
  - Alex Arnaud
  - Nick Clemens
  - Jonathan Druart
  - Kyle Hall
  - Julian Maurice
  - Josef Moravec
  - Marcel de Rooy

- Topic Experts:
  - REST API -- Tomás Cohen Arazi
  - SIP2 -- Kyle Hall
  - UI Design -- Owen Leonard
  - Elasticsearch -- Alex Arnaud
  - ILS-DI -- Arthur Suzuki
  - Authentication -- Martin Renvoize

- Bug Wranglers:
  - Michal Denár
  - Indranil Das Gupta
  - Jon Knight
  - Lisette Scheer
  - Arthur Suzuki

- Packaging Manager: Mirko Tietgen

- Documentation Manager: David Nind

- Documentation Team:
  - Andy Boze
  - Caroline Cyr La Rose
  - Lucy Vaux-Harvey

- Translation Managers: 
  - Indranil Das Gupta
  - Bernardo González Kriegel

- Release Maintainers:
  - 19.05 -- Fridolin Somers
  - 18.11 -- Lucas Gass
  - 18.05 -- Liz Rea
## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 19.05.06:

- American Numismatics Society
- Universidad Nacional de Córdoba

We thank the following individuals who contributed patches to Koha 19.05.06.

- Tomás Cohen Arazi (4)
- Nick Clemens (14)
- Jonathan Druart (14)
- Magnus Enger (2)
- Katrin Fischer (6)
- Lucas Gass (4)
- Kyle Hall (2)
- Owen Leonard (3)
- Ere Maijala (1)
- Martin Renvoize (4)
- Fridolin Somers (3)
- Koha Translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 19.05.06

- ACPL (3)
- BibLibre (3)
- BSZ BW (6)
- ByWater-Solutions (20)
- Koha Community Developers (14)
- Libriotech (2)
- PTFS-Europe (4)
- Theke Solutions (4)
- University of Helsinki (1)

We also especially thank the following individuals who tested patches
for Koha.

- Hugo Agud (2)
- Tomás Cohen Arazi (5)
- Cori Lynn Arnold (1)
- Bob Bennhoff (2)
- Nick Clemens (1)
- Michal Denar (4)
- Jonathan Druart (22)
- Katrin Fischer (9)
- Lucas Gass (50)
- Kyle Hall (1)
- Rhonda Kuiper (1)
- Joonas Kylmälä (1)
- Ere Maijala (2)
- Kelly McElligott (1)
- Joy Nelson (24)
- David Nind (1)
- Séverine Queune (5)
- Liz Rea (4)
- Martin Renvoize (51)
- Marcel de Rooy (10)
- Lisette Scheer (1)
- Maryse Simard (2)
- Fridolin Somers (2)
- George Williams (2)
- Jessica Zairo (1)



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

Autogenerated release notes updated last on 23 Dec 2019 20:05:32.
