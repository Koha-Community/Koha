# RELEASE NOTES FOR KOHA 25.05.12

02 Jul 2026

Koha is the first free and open source software library automation package (ILS). Development is sponsored by libraries of varying types and sizes, volunteers, and support companies from around the world. The website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 25.05.12 can be downloaded from:

- [Download](https://download.koha-community.org/koha-25.05.12.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 25.05.12 is a bugfix/maintenance and security release.

It includes 4 enhancements, 19 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).

#### Security bugs

- [42360](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42360) SQL Injection in reports/acquisitions_stats.pl via Filter parameter
- [42363](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42363) SQL Injection in reports/catalogue_stats.pl via the Line request parameter
- [42368](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42368) SQL Injection in reports/issues_avg_stats.pl via the Filter request parameter (unvalidated string context, no placeholders)
- [42369](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42369) SQL Injection in reports/bor_issues_top.pl via the Filter request parameter (unvalidated string context, no placeholders)
- [42735](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42735) SQL Injection in reports/issues_stats.pl via PeriodTypeSel / PeriodDaySel / PeriodMonthSel / Filter parameters (unvalidated string context, no placeholders)

## Bugfixes

### About

#### Other bugs fixed

- [42726](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42726) Release team 26.11

  > Updates changes to the 25.11 release team, and adds the details of people in the 26.05 release team. (More \> About Koha \> Koha team.)

### Acquisitions

#### Critical bugs fixed

- [41546](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41546) Cannot unarchive suggestions

  > This restores the 'Unarchive' action for archived suggestions.
  >
  > To restore an archived suggestion:
  > 1. Go to Acquisitions \> Suggestions
  > 2. To show archived suggestions: 2.1 From the sidebar 'Filter by section', select 'Include archived' 2.2 Click the 'Go' button in the 'Organize by section'
  > 3. For an archived suggestion ('Archived' shown under the suggestion title): 3.1 Select the dropdown list by the 'Edit' button on the far right 3.2 Select the 'Unarchive' action.
- [42723](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42723) Purchase suggestion 500 page error when EmailPurchaseSuggestions is set to "email address of library"

  > This fixes a 500 page error\[1\] when creating a suggestion in the staff interface if:
  > - the EmailPurchaseSuggestions system preference is set to "email address of library", and
  > - the library for acquisition information is set to "Any".
  >
  > \[1\] Can't call method "inbound_email_address" on an undefined value at /kohadevbox/koha/Koha/Suggestion.pm line 107

#### Other bugs fixed

- [39514](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39514) If one basket has uncertain prices, all baskets are displayed in red

  > This fixes the display of baskets in acquisitions so that only baskets with uncertain prices are shown in red. Previously, if one basket had an uncertain price, all the baskets in the page were shown in red, even those without uncertain prices, making it hard to know where to go to fix the price.

### Circulation

#### Other bugs fixed

- [41352](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41352) Bookings to Collect Help does not take you to the correct place in the manual

  > This fixes the link to the help for the Circulation \> Holds and bookings \> Bookings to collect page - it now links to the correct place in the documentation, instead of the documentation home page.

### ERM

#### Other bugs fixed

- [42130](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42130) Holdings created in ERM with a linked bibliographic record does not index the record

  > This fixes indexing of records, so that when a new title is added in the ERM module (ERM \> eHoldings \> Local \> Titles) and 'Create bibliographic record' is selected, the new record can be found when searching.

### Installation and upgrade (command-line installer)

#### Critical bugs fixed

- [42412](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42412) Upgrade to 25.11.02.004 using MySQL fails with Exception: Incorrect DATE value: value: '0000-00-00'

### Patrons

#### Critical bugs fixed

- [41045](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41045) Suggestions manage permissions added to patrons who previously had no permissions in that category

#### Other bugs fixed

- [37143](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37143) Patron registration allows for saving required fields with a single space instead of information

  > This changes the OPAC self-registration form validation so that required fields need actual information, and not just spaces.
  >
  > Before this, spaces could be entered into most required fields and the form would successfully submit. Now, when submitting, a warning is generated to fill in all missing fields for required fields with just spaces.

### REST API

#### Critical bugs fixed

- [41614](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41614) additional_contents REST endpoint broke the display location filter

  > This fixes a regression that resulted in an empty list in the "Display location" filter in the sidebar for Tools \> Additional tools \> HTML customizations. Only All, OPAC, and Staff Interface options were shown in the dropdown list, instead of the full list of display locations.
  >
  > (Regression caused by Bug 39900 - Add public REST endpoint for additional_contents, in Koha 25.11 and 25.05.)

### Self checkout

#### Critical bugs fixed

- [41646](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41646) Self-checkin displaying too much whitespace due to incorrect HTML

  > This removes a large section of white space between the page header and the actual form on the OPAC self check-in page, which was positioned near the bottom of the page.

### Staff interface

#### Other bugs fixed

- [41427](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41427) Terminology: branch should be library in FilterSearchResultsByLoggedInBranch

  > This fixes the terminology and improves the description for the FilterSearchResultsByLoggedInBranch system preference - branch should be library.

### Test Suite

#### Other bugs fixed

- [42733](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42733) Tools/ManageMarcImport_spec.ts is failing (again)
- [42783](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42783) Tools/ManageMarcImport_spec.ts is still flaky

## Enhancements

### Continuous Integration

#### Enhancements

- [41368](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41368) Tools/ManageMarcImport_spec.ts is failing

### Reports

#### Enhancements

- [39164](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39164) Add max_statement_time to SQL report queries

  > This patchset adds the abilty to set a maximum execution time in seconds for SQL report queries. Reports exceeding this limit will be automatically terminated. This is configured in the koha-conf.xml file by setting the report_sql_max_statement_time_seconds parameter. By default this is turned off.

### Serials

#### Enhancements

- [38009](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38009) Add a generate next button in serials receive page

  > This enhancement adds a "Generate next" button to the receive page for a serial, similar to the one on the serial collection page (Serials \> \[subscription page\] \> Receive).

  **Sponsored by** _Pymble Ladies' College_

### Staff interface

#### Enhancements

- [40288](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40288) patron details in patron sidebar overflow the sidebar

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha documentation is

- [Koha Documentation](https://koha-community.org/documentation/) As of the date of these release notes, the Koha manual is available in the following languages:
- [English (USA)](https://koha-community.org/manual/25.05/en/html/)
- [French](https://koha-community.org/manual/25.05/fr/html/) (80%)
- [German](https://koha-community.org/manual/25.05/de/html/) (87%)
- [Greek](https://koha-community.org/manual/25.05/el/html/) (92%)
- [Hindi](https://koha-community.org/manual/25.05/hi/html/) (62%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff interface are available in this release for the following languages:

- Arabic (ar_ARAB) (92%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified Han script) (83%)
- Chinese (Traditional Han script) (97%)
- Czech (67%)
- Dutch (88%)
- English (100%)
- English (New Zealand) (61%)
- English (USA)
- Finnish (100%)
- French (100%)
- French (Canada) (99%)
- German (100%)
- Greek (66%)
- Hindi (94%)
- Italian (81%)
- Norwegian Bokmål (71%)
- Persian (fa_ARAB) (93%)
- Polish (99%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (88%)
- Russian (93%)
- Slovak (59%)
- Spanish (98%)
- Swedish (89%)
- Telugu (65%)
- Turkish (80%)
- Ukrainian (74%)
- Western Armenian (hyw_ARMN) (60%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](https://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate list to volunteer:

- [Koha Translate List](https://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](https://translate.koha-community.org/)

## Release Team

The release team for Koha 25.05.12 is

- Release Manager:

## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored new features in Koha 25.05.12

- Pymble Ladies' College

We thank the following individuals who contributed patches to Koha 25.05.12

- Pedro Amorim (4)
- Nick Clemens (1)
- David Cook (7)
- Paul Derscheid (1)
- Jonathan Druart (7)
- Lucas Gass (2)
- Michael Hafen (2)
- Kyle M Hall (1)
- Mark Hofstetter (1)
- Jan Kissig (1)
- David Nind (1)
- Eric Phetteplace (1)
- Martin Renvoize (2)
- Caroline Cyr La Rose (1)
- Wainui Witika-Park (2)

We thank the following libraries, companies, and other institutions who contributed patches to Koha 25.05.12

- [ByWater Solutions](https://bywatersolutions.com) (4)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha) (2)
- David Nind (1)
- hofstetter.at (1)
- Independant Individuals (3)
- Koha Community Developers (7)
- [LMSCloud](https://www.lmscloud.de) (1)
- [OpenFifth](https://openfifth.co.uk) (6)
- [Prosentient Systems](https://www.prosentient.com.au) (7)
- [Solutions inLibro inc](https://inlibro.com) (1)
- Wildau University of Technology (1)

We also especially thank the following individuals who tested patches for Koha

- Nick Clemens (3)
- Jonathan Druart (7)
- Laura Escamilla (4)
- Katrin Fischer (1)
- Andrew Fuerste-Henry (1)
- Brendan Gallagher (1)
- Lucas Gass (14)
- George (1)
- Kyle M Hall (1)
- Emily Lamancusa (1)
- Owen Leonard (4)
- Esther Melander (1)
- David Nind (11)
- Sanjar Tulkinov Anvar o'g'li (6)
- Jacob O'Mara (9)
- Martin Renvoize (5)
- Marcel de Rooy (2)
- Samuel (1)
- Emmi Takkinen (1)
- Wainui Witika-Park (32)
- Baptiste Wojtkowski (5)
- Chloe Zermatten (1)

We regret any omissions. If a contributor has been inadvertently missed, please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control. The current development version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release line is 25.05.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug tracker at:

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai. (Many hands finish the work)

Autogenerated release notes updated last on 02 Jul 2026 03:03:05.
