# RELEASE NOTES FOR KOHA 20.11.10
22 sept. 2021

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 20.11.10 can be downloaded from:

- [Download](http://download.koha-community.org/koha-20.11.10.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 20.11.10 is a bugfix/maintenance release with security fixes.

It includes 6 security fixes, 22 bugfixes.

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

- [[28881]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28881) Suggestion not displayed on the order receive page

### Cataloging

- [[28812]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28812) Authority tag editor only copies $a from record to search form

### OPAC

- [[28885]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28885) OpacBrowseResults can cause errors with bad search indexes


## Other bugs fixed

### Architecture, internals, and plumbing

- [[28744]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28744) Class with empty/no to_api_mapping should generate an empty from_api_mapping
- [[28776]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28776) Warns from GetItemsInfo when biblio marked as serial

### Circulation

- [[25619]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25619) Updating an expiration date for a waiting hold won't save
- [[28774]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28774) Warnings from GetIssuingCharge when rental discount is not set

  >This fixes the cause of warning messages in the log files when the rental discount in the circulation rules has a blank value. 
  >
  >Before this fix, multiple warning messages "[2021/07/28 12:11:25] [WARN] Argument "" isn't numeric in subtraction (-) at /kohadevbox/koha/C4/Circulation.pm line 3385." appeared in the log files. These warnings occurred for items checked out where they had rental charges and the rental discount value in the circulation rules was blank.
- [[28891]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28891) RecordStaffUserOnCheckout display a new column but default sort column isn't changed

### MARC Bibliographic data support

- [[10265]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10265) 8xx serial added entries need spaces and punctuation in XSLT display
- [[26852]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26852) Add missing X11$e and remove relator term subfields from MARC21 headings

### OPAC

- [[26223]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26223) The OPAC ISBD view does not display item information
- [[28861]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28861) Item type column always hidden in holds history

### Patrons

- [[21794]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21794) Incomplete address displayed on patron details page when City field is empty
- [[28392]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28392) streettype and B_streettype cannot be hidden via BorrowerUnwantedField

### Searching

- [[28554]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28554) In itemsearch sort filters by description

  >For item search in the staff interface the shelving location and item type values are now sorted by the description, rather than the authorized value code.

### Staff Client

- [[20529]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20529) Return to results link is truncated when the search contains a double quote
- [[28722]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28722) tools/batchMod.pl needs to import C4::Auth::haspermission
- [[28802]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28802) Untranslatable strings in browser.js
- [[28912]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28912) Pseudonymization should display a nice error message when brcypt_settings are not defined

### System Administration

- [[28936]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28936) Sort1 and Sort2 should be included in BorrowerUnwantedField and related sysprefs

### Test Suite

- [[28873]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28873) Incorrect age displayed in db_dependent/Koha/Patrons.t

  >This fixes age tests in t/db_dependent/Koha/Patrons.t so that  the correct ages are calculated and displayed. It also adds the category code 'AGE_5_10' in messages to display age limits.

### Tools

- [[28525]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28525) TinyMCE for system prefs does some automatic code clean up



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/20.11/ar/html/) (27%)
- [Chinese (Taiwan)](https://koha-community.org/manual/20.11/zh_TW/html/) (61.4%)
- [English (USA)](https://koha-community.org/manual/20.11/en/html/)
- [French](https://koha-community.org/manual/20.11/fr/html/) (51.1%)
- [French (Canada)](https://koha-community.org/manual/20.11/fr_CA/html/) (26%)
- [German](https://koha-community.org/manual/20.11/de/html/) (71.2%)
- [Hindi](https://koha-community.org/manual/20.11/hi/html/) (99.9%)
- [Italian](https://koha-community.org/manual/20.11/it/html/) (50%)
- [Spanish](https://koha-community.org/manual/20.11/es/html/) (36.4%)
- [Turkish](https://koha-community.org/manual/20.11/tr/html/) (41.9%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (99.1%)
- Armenian (100%)
- Armenian (Classical) (89%)
- Bulgarian (91.3%)
- Catalan; Valencian (56.6%)
- Chinese (Taiwan) (93%)
- Czech (73.3%)
- English (New Zealand) (59.5%)
- English (USA)
- Finnish (79.3%)
- French (91%)
- French (Canada) (92.1%)
- German (100%)
- German (Switzerland) (66.8%)
- Greek (60.6%)
- Hindi (100%)
- Italian (99.9%)
- Nederlands-Nederland (Dutch-The Netherlands) (79.2%)
- Norwegian Bokmål (63.7%)
- Polish (100%)
- Portuguese (88.4%)
- Portuguese (Brazil) (95.6%)
- Russian (93.6%)
- Slovak (80.4%)
- Spanish (99%)
- Swedish (74.9%)
- Telugu (100%)
- Turkish (100%)
- Ukrainian (68.2%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 20.11.10 is


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

- Topic Experts:
  - UI Design -- Owen Leonard
  - REST API -- Tomás Cohen Arazi
  - Zebra -- Fridolin Somers
  - Accounts -- Martin Renvoize

- Bug Wranglers:
  - Amit Gupta
  - Mengü Yazıcıoğlu
  - Indranil Das Gupta

- Packaging Managers:
  - David Cook
  - Mason James
  - Agustín Moyano

- Documentation Manager: Caroline Cyr La Rose


- Documentation Team:
  - Marie-Luce Laflamme
  - Lucy Vaux-Harvey
  - Henry Bolshaw
  - David Nind

- Translation Managers: 
  - Indranil Das Gupta
  - Bernardo González Kriegel

- Release Maintainers:
  - 20.11 -- Fridolin Somers
  - 20.05 -- Andrew Fuerste-Henry
  - 19.11 -- Victor Grousset

## Credits

We thank the following individuals who contributed patches to Koha 20.11.10

- Tomás Cohen Arazi (12)
- Nick Clemens (4)
- Jonathan Druart (14)
- Katrin Fischer (2)
- Lucas Gass (3)
- Didier Gautheron (2)
- Victor Grousset (3)
- Kyle M Hall (5)
- Janusz Kaczmarek (1)
- Joonas Kylmälä (2)
- Marcel de Rooy (2)
- Andreas Roussos (1)
- Fridolin Somers (7)
- Koha translators (1)
- Petro Vashchuk (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 20.11.10

- BibLibre (10)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (2)
- ByWater-Solutions (12)
- Dataly Tech (1)
- Independant Individuals (4)
- Koha Community Developers (16)
- Rijks Museum (2)
- Theke Solutions (12)

We also especially thank the following individuals who tested patches
for Koha

- Tomás Cohen Arazi (4)
- Sara Brown (1)
- Nick Clemens (13)
- Jonathan Druart (29)
- Katrin Fischer (14)
- Andrew Fuerste-Henry (3)
- Kyle M Hall (33)
- Abbey Holt (2)
- Barbara Johnson (1)
- Joonas Kylmälä (8)
- Owen Leonard (2)
- Julian Maurice (1)
- David Nind (12)
- Hayley Pelham (2)
- Séverine Queune (1)
- Martin Renvoize (5)
- Marcel de Rooy (15)
- Fridolin Somers (33)
- Emmi Takkinen (1)
- George Veranis (1)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 20.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 22 sept. 2021 20:46:29.
