# RELEASE NOTES FOR KOHA 22.11.28
25 Jun 2025

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 22.11.28 can be downloaded from:

- [Download](https://download.koha-community.org/koha-22.11.28.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 22.11.28 is a bugfix/maintenance release.

It includes 1 enhancements, 10 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


## Bugfixes

### Architecture, internals, and plumbing

#### Other bugs fixed

- [35629](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35629) Redundant code in includes/patron-search.inc
- [35702](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35702) Reduce DB calls when performing authorities merge

### Cataloging

#### Other bugs fixed

- [24424](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24424) Advanced editor - interface hangs as "Loading" when given an invalid bib number

  **Sponsored by** *Ignatianum University in Cracow*

### Command-line Utilities

#### Other bugs fixed

- [34091](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34091) Typo in help for cleanupdatabase.pl: --log-modules  needs to be --log-module

### Hold requests

#### Critical bugs fixed

- [35489](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35489) Holds on items with no barcode are missing an input for itemnumber

### Notices

#### Critical bugs fixed

- [39184](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39184) Server-side template injection leading to remote code execution

### Patrons

#### Other bugs fixed

- [25835](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25835) Include overdue report (under circulation module) as a staff permission
- [38772](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38772) Typo 'minPasswordPreference' system preference
  >This fixes a typo in the code for OPAC password recovery - 'minPasswordPreference' to 'minPasswordLength' (the correct system preference name). It has no noticeable effect on resetting an account password from the OPAC.

### REST API

#### Other bugs fixed

- [32551](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32551) API requests don't carry language related information

### Tools

#### Other bugs fixed

- [35438](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35438) Importing records can create too large transactions

## Enhancements 

### Database

#### Enhancements

- [31143](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31143) We should attempt to fix/identify all cases where '0000-00-00' may still remain in the database
  >This enhancement:
  >
  >1. Updates the misc/maintenance/search_for_data_inconsistencies.pl script so that it identifies any date fields that have 0000-00-00 values.
  >
  >2. Adds a new script misc/maintenance/fix_invalid_dates.pl that fixes any date fields that have '0000-00-00' values (for example: dateofbirth) by updating them to 'NULL'. 
  >
  >Patron, item, and other date fields with a value of '000-00-00' can cause errors. This includes:
  >- API errors
  >- stopping the patron autocomplete search working
  >- generating a 500 internal server error:
  >  . for normal patron searching
  >  . when displaying item data in the holdings table

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [English (USA)](https://koha-community.org/manual/22.11/en/html/)
- [French](https://koha-community.org/manual/22.11/fr/html/) (73%)
- [German](https://koha-community.org/manual/22.11/de/html/) (98%)
- [Greek](https://koha-community.org/manual/22.11/el/html/) (100%)
- [Hindi](https://koha-community.org/manual/22.11/hi/html/) (70%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (90%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified Han script) (96%)
- Chinese (Traditional Han script) (83%)
- Czech (72%)
- Dutch (89%)
- English (100%)
- English (New Zealand) (70%)
- English (USA)
- English (United Kingdom) (99%)
- Finnish (96%)
- French (100%)
- French (Canada) (96%)
- German (100%)
- German (Switzerland) (56%)
- Greek (72%)
- Hindi (99%)
- Italian (92%)
- Norwegian Bokmål (69%)
- Persian (fa_ARAB) (77%)
- Polish (100%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (88%)
- Russian (94%)
- Slovak (68%)
- Spanish (100%)
- Swedish (88%)
- Telugu (78%)
- Tetum (54%)
- Turkish (91%)
- Ukrainian (79%)
- Western Armenian (hyw_ARMN) (70%)
</div>

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](https://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](https://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](https://translate.koha-community.org/)

## Release Team

The release team for Koha 22.11.28 is


- Release Manager: 

## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 22.11.28
<div style="column-count: 2;">

- Ignatianum University in Cracow
</div>

We thank the following individuals who contributed patches to Koha 22.11.28
<div style="column-count: 2;">

- Pedro Amorim (2)
- Tomás Cohen Arazi (2)
- Nick Clemens (5)
- David Cook (1)
- Paul Derscheid (2)
- Roman Dolny (1)
- Kyle M Hall (2)
- Andrew Fuerste Henry (1)
- Janusz Kaczmarek (1)
- Fridolin Somers (1)
- wainuiwitikapark (2)
- Wainui Witika-Park (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 22.11.28
<div style="column-count: 2;">

- [BibLibre](https://www.biblibre.com) (1)
- [ByWater Solutions](https://bywatersolutions.com) (7)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha) (3)
- Dubuque County Library District (1)
- Independant Individuals (1)
- [Jezuici, Poland](https://jezuici.pl/) (1)
- [LMSCloud](https://www.lmscloud.de) (2)
- [Open Fifth](https://openfifth.co.uk/) (2)
- [Prosentient Systems](https://www.prosentient.com.au) (1)
- [Theke Solutions](https://theke.io) (2)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Nick Clemens (6)
- Paul Derscheid (1)
- Jonathan Druart (2)
- Magnus Enger (1)
- Andrew Fuerste-Henry (1)
- Lucas Gass (1)
- Victor Grousset (2)
- Owen Leonard (1)
- Jesse Maseto (1)
- David Nind (8)
- Martin Renvoize (1)
- Marcel de Rooy (3)
- wainuiwitikapark (15)
- Shi Yao Wang (2)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 22.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 25 Jun 2025 07:33:34.
