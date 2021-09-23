# RELEASE NOTES FOR KOHA 21.05.04
23 Sep 2021

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 21.05.04 can be downloaded from:

- [Download](http://download.koha-community.org/koha-21.05.04.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 21.05.04 is a bugfix/maintenance release with security fixes.

It includes 6 security fixes, 1 enhancements, 20 bugfixes.

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


## Enhancements

### Web services

- [[26195]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26195) Add a way to specify authorised values should be expanded [OAI]

  >This enhancement adds a new option to the OAI configuration file, to tell it to expand authorised values.


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[28881]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28881) Suggestion not displayed on the order receive page

### Cataloging

- [[28812]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28812) Authority tag editor only copies $a from record to search form

### OPAC

- [[28885]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28885) OpacBrowseResults can cause errors with bad search indexes


## Other bugs fixed

### Architecture, internals, and plumbing

- [[28373]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28373) Items fields not used in default XSLT

  >When processing records for display we loop through each field in the record and translate authorized values into descriptions. Item fields in the record contain many authorised values, and the lookups can cause a delay in displaying the record. If using the default XSLT these fields are not displayed as they exist in the record, so parsing them is not necessary and can save time. This bug adds a system preference that disables sending these fields for processing and thus saving time. Enabling the system preference will allow users to pass the items to custom style sheets if needed.
- [[28744]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28744) Class with empty/no to_api_mapping should generate an empty from_api_mapping

### Circulation

- [[25619]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25619) Updating an expiration date for a waiting hold won't save
- [[28774]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28774) Warnings from GetIssuingCharge when rental discount is not set

  >This fixes the cause of warning messages in the log files when the rental discount in the circulation rules has a blank value. 
  >
  >Before this fix, multiple warning messages "[2021/07/28 12:11:25] [WARN] Argument "" isn't numeric in subtraction (-) at /kohadevbox/koha/C4/Circulation.pm line 3385." appeared in the log files. These warnings occurred for items checked out where they had rental charges and the rental discount value in the circulation rules was blank.
- [[28891]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28891) RecordStaffUserOnCheckout display a new column but default sort column isn't changed

### Hold requests

- [[7703]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7703) Don't block bulk hold action on search results if some items can't be placed on hold

### MARC Bibliographic data support

- [[10265]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10265) 8xx serial added entries need spaces and punctuation in XSLT display

### OPAC

- [[26223]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26223) The OPAC ISBD view does not display item information

### Patrons

- [[21794]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21794) Incomplete address displayed on patron details page when City field is empty
- [[28392]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28392) streettype and B_streettype cannot be hidden via BorrowerUnwantedField
- [[28882]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28882) Incorrect permissions check client-side

### Searching

- [[28554]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28554) In itemsearch sort filters by description

  >For item search in the staff interface the shelving location and item type values are now sorted by the description, rather than the authorized value code.

### Staff Client

- [[20529]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20529) Return to results link is truncated when the search contains a double quote
- [[28722]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28722) tools/batchMod.pl needs to import C4::Auth::haspermission
- [[28912]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28912) Pseudonymization should display a nice error message when brcypt_settings are not defined

### System Administration

- [[28936]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28936) Sort1 and Sort2 should be included in BorrowerUnwantedField and related sysprefs

### Templates

- [[28149]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28149) Improve internationalization and formatting on background jobs page

## New system preferences
- PassItemMarcToXSLT



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/21.05/ar/html/) (34.3%)
- [Chinese (Taiwan)](https://koha-community.org/manual/21.05/zh_TW/html/) (58.7%)
- [Czech](https://koha-community.org/manual/21.05/cs/html/) (27.6%)
- [English (USA)](https://koha-community.org/manual/21.05/en/html/)
- [French](https://koha-community.org/manual/21.05/fr/html/) (49.2%)
- [French (Canada)](https://koha-community.org/manual/21.05/fr_CA/html/) (25.2%)
- [German](https://koha-community.org/manual/21.05/de/html/) (72.7%)
- [Hindi](https://koha-community.org/manual/21.05/hi/html/) (100%)
- [Italian](https://koha-community.org/manual/21.05/it/html/) (47.8%)
- [Spanish](https://koha-community.org/manual/21.05/es/html/) (34.8%)
- [Turkish](https://koha-community.org/manual/21.05/tr/html/) (40.3%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (90.6%)
- Armenian (100%)
- Armenian (Classical) (89%)
- Chinese (Taiwan) (81.6%)
- Czech (71.3%)
- English (New Zealand) (62%)
- English (USA)
- Finnish (82.8%)
- French (85.7%)
- French (Canada) (84.7%)
- German (100%)
- German (Switzerland) (61.3%)
- Greek (54.9%)
- Hindi (100%)
- Italian (92.3%)
- Nederlands-Nederland (Dutch-The Netherlands) (62.1%)
- Norwegian Bokmål (65.2%)
- Polish (100%)
- Portuguese (91.4%)
- Portuguese (Brazil) (87.8%)
- Russian (87.1%)
- Slovak (73.3%)
- Spanish (91.2%)
- Swedish (77.6%)
- Telugu (99.9%)
- Turkish (99.6%)
- Ukrainian (63.2%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 21.05.04 is


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
  - 21.05 -- Kyle M Hall
  - 20.11 -- Fridolin Somers
  - 20.05 -- Victor Grousset
  - 19.11 -- Wainui Witika-Park (with support from Aleisha Amohia) 

## Credits

We thank the following individuals who contributed patches to Koha 21.05.04

- Tomás Cohen Arazi (14)
- Nick Clemens (4)
- Jonathan Druart (16)
- Katrin Fischer (2)
- Lucas Gass (2)
- Didier Gautheron (2)
- Victor Grousset (2)
- Kyle M Hall (12)
- Joonas Kylmälä (2)
- Owen Leonard (3)
- Marcel de Rooy (2)
- Andreas Roussos (1)
- Fridolin Somers (3)
- Koha translators (1)
- Petro Vashchuk (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 21.05.04

- Athens County Public Libraries (3)
- BibLibre (6)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (2)
- ByWater-Solutions (18)
- Dataly Tech (1)
- Independant Individuals (3)
- Koha Community Developers (17)
- Rijks Museum (2)
- Theke Solutions (14)

We also especially thank the following individuals who tested patches
for Koha

- Tomás Cohen Arazi (2)
- Nick Clemens (14)
- Jonathan Druart (29)
- Katrin Fischer (18)
- Andrew Fuerste-Henry (3)
- Kyle M Hall (55)
- Abbey Holt (2)
- Joonas Kylmälä (10)
- Owen Leonard (3)
- Julian Maurice (1)
- David Nind (10)
- Hayley Pelham (4)
- Séverine Queune (1)
- Martin Renvoize (6)
- Marcel de Rooy (19)
- Sally (3)
- Fridolin Somers (3)
- Emmi Takkinen (4)
- George Veranis (1)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is (HEAD detached from c373fda8931).

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 23 Sep 2021 14:41:32.
