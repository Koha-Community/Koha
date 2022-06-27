# RELEASE NOTES FOR KOHA 21.11.09
27 Jun 2022

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 21.11.09 can be downloaded from:

- [Download](http://download.koha-community.org/koha-21.11.09.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 21.11.09 is a bugfix/maintenance release.

It includes 3 enhancements, 29 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations




## Enhancements

### Architecture, internals, and plumbing

- [[29883]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29883) Uninitialized value warning when GetAuthorisedValues gets called with no parameters
- [[30830]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30830) Add Koha Objects  for Koha Import Items

### Templates

- [[30523]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30523) Quiet console warning about missing shortcut-buttons map file


## Critical bugs fixed

### Cataloging

- [[30717]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30717) Dates displayed in ISO format when editing items

### Hold requests

- [[30742]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30742) Confusion when placing hold on record with no items available because of not for loan

### OPAC

- [[28955]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28955) Add option to set default branch from Apache

  >Add support for OPAC_BRANCH_DEFAULT as an environment option.
  >It allows setting a default branch for the anonymous OPAC session such that you can display the right OPAC content blocks prior to login if you have set up per branch website.

### Patrons

- [[30868]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30868) Modifying a patron - page not found error after fixing validation errors where the message is displayed at the top of the page

  >This fixes a page not found error message generated after fixing validation errors when editing a patron (where the validation/error message is shown at the top of the page - below the patron name, but before the Save and Cancel buttons). (This was introduced by bug 29684: Fix warn about js/locale_data.js in 22.05.)

### Reports

- [[30551]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30551) Cash register report shows wrong library when paying fees in two different libraries

### Tools

- [[29828]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29828) If no content is added to default, but a translation, news/additional content entries don't show in list
- [[30831]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30831) Add unit test for BatchCommitItems

## Other bugs fixed

### Acquisitions

- [[29961]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29961) Horizontal scroll bar in acquisition z39.50 search should always show

### Architecture, internals, and plumbing

- [[30731]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30731) Noise from about script coming from Test::MockTime (or other CPAN modules)

### Circulation

- [[30337]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30337) Holds to Pull ( pendingreserves.pl ) ignores holds if priority 1 hold is suspended

### Command-line Utilities

- [[30781]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30781) Use of uninitialized value $val in substitution iterator at /usr/share/koha/lib/C4/Letters.pm line 665.
- [[30893]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30893) Typo: update_patrons_category.pl fine(s)

  >This updates the help text for the update patrons category cronjob script (misc/cronjobs/update_patrons_category.pl). It changes the full option names and associated information for -fo (--fineover to --finesover) and -fu (--fineunder to --finesunder), as well as some minor formatting and text tidy ups.

### Course reserves

- [[30840]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30840) Add support for barcode filters to course reserves

### Hold requests

- [[30828]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30828) Remove unused variable in placerequest.pl

### OPAC

- [[30746]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30746) JS error on 'your personal details' in OPAC
- [[30844]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30844) The OPAC detail page's browser is limited to the current page of results when using Elasticsearch

  **Sponsored by** *Lund University Library*

### Patrons

- [[29617]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29617) BorrowerUnwantedField should exclude the ability to hide categorycode

### Searching

- [[27697]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27697) Opening bibliographic record page prepopulates search bar text

### Searching - Zebra

- [[30528]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30528) Limits are not correctly parsed when query contains CCL

### Serials

- [[30204]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30204) Add subtitle to serial subscription search

  >Adds the biblio.subtitle to the 'Title' column on serial-search.pl.

### Staff Client

- [[28723]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28723) Holds table not displayed when it contains a biblio without title

### System Administration

- [[30862]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30862) Typo: langues

### Templates

- [[30721]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30721) Markup error in detail page's component parts tab

  >This fixes the display of the component parts tab on the bibliographic detail page in the staff interface. A missing </div> was causing content from later tabs to be incorrectly displayed at the end of the component parts tab.
- [[30726]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30726) Flatpickr's "yesterday" shortcut doesn't work if entry is limited to past dates

### Test Suite

- [[29860]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29860) Useless warnings in regressions.t
- [[30756]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30756) Get skip block out of Koha_Authority.t and add TestBuilder
- [[30870]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30870) Don't skip tests if Test::Deep is not installed

### Tools

- [[28152]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28152) Hidden error when importing an item with an existing itemnumber



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)



The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (87.4%)
- Armenian (100%)
- Armenian (Classical) (89%)
- Bulgarian (92.4%)
- Chinese (Taiwan) (79.5%)
- Czech (76.5%)
- English (New Zealand) (59.1%)
- English (USA)
- Finnish (92.4%)
- French (95.1%)
- French (Canada) (93%)
- German (100%)
- German (Switzerland) (58.8%)
- Greek (60.4%)
- Hindi (100%)
- Italian (100%)
- Nederlands-Nederland (Dutch-The Netherlands) (83.5%)
- Norwegian Bokmål (63.4%)
- Polish (99.2%)
- Portuguese (91.2%)
- Portuguese (Brazil) (83.8%)
- Russian (85%)
- Slovak (72.1%)
- Spanish (100%)
- Swedish (82.4%)
- Telugu (95.4%)
- Turkish (99.7%)
- Ukrainian (75.8%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 21.11.09 is


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
We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 21.11.09

- Lund University Library

We thank the following individuals who contributed patches to Koha 21.11.09

- Tomás Cohen Arazi (2)
- Kevin Carnes (2)
- Nick Clemens (8)
- Jonathan Druart (10)
- Lucas Gass (3)
- Kyle M Hall (2)
- Joonas Kylmälä (1)
- Owen Leonard (2)
- Julian Maurice (2)
- Martin Renvoize (2)
- Marcel de Rooy (7)
- Caroline Cyr La Rose (1)
- Slava Shishkin (1)
- Fridolin Somers (2)
- Arthur Suzuki (5)
- Koha translators (1)
- Petro Vashchuk (1)
- Shi Yao Wang (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 21.11.09

- Athens County Public Libraries (2)
- BibLibre (9)
- ByWater-Solutions (13)
- Independant Individuals (3)
- Koha Community Developers (10)
- PTFS-Europe (2)
- Rijksmuseum (7)
- Solutions inLibro inc (2)
- Theke Solutions (2)
- ub.lu.se (2)

We also especially thank the following individuals who tested patches
for Koha

- Tomás Cohen Arazi (34)
- Emmanuel Bétemps (1)
- Nick Clemens (3)
- Jonathan Druart (11)
- Katrin Fischer (14)
- Lucas Gass (38)
- Victor Grousset (4)
- Kyle M Hall (2)
- Joonas Kylmälä (6)
- David Nind (27)
- Martin Renvoize (7)
- Jason Robb (1)
- Marcel de Rooy (4)
- Caroline Cyr La Rose (1)
- shiyao (1)
- Fridolin Somers (4)
- Arthur Suzuki (44)



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

Autogenerated release notes updated last on 27 Jun 2022 12:55:34.
