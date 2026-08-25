# RELEASE NOTES FOR KOHA 25.11.08
25 Aug 2026

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 25.11.08 can be downloaded from:

- [Download](https://download.koha-community.org/koha-25.11.08.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 25.11.08 is a bugfix/maintenance release with security patches.

It includes 1 enhancements, 25 bugfixes (3 security).

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [42736](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42736) SQL Injection in reports/cat_issues_top.pl via Criteria / Filter request parameters (unvalidated string context, no placeholders)
- [42800](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42800) Potential XSS in shelf list in the erm module
- [42904](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42904) Prevent XSS in patron restriction comments

## Bugfixes

### Acquisitions

#### Other bugs fixed

- [41070](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41070) No warning when filling no fund while importing in a basket from a file
  >This fixes an issue when adding an order to a basket using the "From a new file" option.
  >
  >When adding an order from the staged file there was no warning if you didn't select the fund in either the "Select to import" or "Default accounting details" tabs.
  >
  >Now there is a warning if you don't select a fund: "Some funds are not defined in item records".

### Cataloging

#### Other bugs fixed

- [40225](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40225) The --send-all option in the stockrotation job fails if there are no items to rotate at all
- [42531](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42531) Repeatable field values with long text do not wrap on staff record detail page
- [42846](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42846) Koha::Database::DataInconsistency typo for biblioitemnumber in MARC

### Circulation

#### Other bugs fixed

- [42659](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42659) Multiple numbers and parts shown incorrectly on checkin screen
- [42930](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42930) Overdues (circ/overdue.pl) incorrectly shows bibliographic record title in patron column instead of the patron's title (salutation)
  >This fixes the information shown in the overdues report patron column (Circulation > Overdues > Overdues). The bibliographic record title was shown before the patron's name, instead of the patron's title (salutation).
  >
  >(Related to bug 41343 - Overdue report is too intensive on systems with many overdues, added to Koha 26.05 and 25.11.)

### ILL

#### Other bugs fixed

- [42582](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42582) Uncaught TypeError on Place request with partner libraries when no z39.50 service is set

### Installation and upgrade (command-line installer)

#### Critical bugs fixed

- [42795](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42795) Bug 40658 breaks CLI for 25.11
- [42886](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42886) CSS files not installed

#### Other bugs fixed

- [42850](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42850) ILL requests stylesheet is not installed

### OPAC

#### Other bugs fixed

- [42202](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42202) IndependentBranches shouldn't filter public libaries in OPAC search, news, and most popular
  >This fixes the OPAC library location filtering for logged in patrons when IndependentBranches is used.
  >
  >Logged in patrons now see the same options for library locations as unauthenticated patrons, for example:
  >- Library pulldown for "All libraries" for the main search (OpacAddMastheadLibraryPulldown system preference)
  >- Advanced search "Location and availability" option 
  >- Most popular from filter (OpacTopissue system preference)
  >- News selector (OpacNewsLibrarySelect system preference)
  >
  >Previously, the library location options were not shown when a patron was logged in. This made no sense, as unauthenticated user can see all the libraries. (A logged in patron could also do a search and then filter by any library location.)

### Point of Sale

#### Other bugs fixed

- [43155](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43155) POS breaks on modal if change required
  >This fixes an issue when using the point of sale system where change is required for a transaction. Clicking "Yes" in the pop-up window to confirm did nothing, and the transaction could not be completed.

### REST API

#### Other bugs fixed

- [42739](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42739) OPAC ratings.js: Add CSRF-TOKEN header to fetch call

### Reports

#### Other bugs fixed

- [8127](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8127) Most-circulated items report doesn't work when limited by library
  >This fixes some of the filters for the "Most-circulated items" report so that using limits (the Limits section with "Limit to" and "By") now works.
  >
  >Previously some options for "By" (such as Library and Week) generated an error message or there were no results (when results were expected).
- [12757](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12757) Integers in saved SQL report ODT export prepended with single quote

  **Sponsored by** *OpenFifth*
- [42803](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42803) Regression in Reports > Items with no checkouts (reports/catalogue_out.pl)

### Staff interface

#### Other bugs fixed

- [42116](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42116) e.preventDefault is a function, needs parentheses
- [42535](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42535) Remove useless "news_delete" javascript in staff interface
- [42666](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42666) Next button in Item types and Patron categories does not work

### System Administration

#### Other bugs fixed

- [42141](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42141) Design pattern introduced in 40191 does not work in staff SIP configuration
- [42641](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42641) JavaScript errors on patron attribute types admin page
  >This fixes the "Patron attribute types" page (Administration > Patrons and circulation > Patron attribute types). The standard table was not showing correctly because of JavaScript errors. The table was not showing the standard navigation and other table elements:
  >  . "Showing X to X of X entries" (above and below the table)
  >  . Search filter
  >  . Export options
  >  . Sorting controls for the columns

### Templates

#### Other bugs fixed

- [42707](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42707) Malformed Bootstrap dropdown in reports output
  >This fixes the formatting of the patron card number (cardnumber) column in reports. It now uses the "dropdown-item" class and is formatted the same as other dropdown lists, such as borrowernumber.

  **Sponsored by** *Athens County Public Libraries*

## Enhancements 

### SIP2

#### Enhancements

- [42002](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42002) SIP screen msg regexp can't be empty

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [English (USA)](https://koha-community.org/manual/25.11/en/html/)
- [French](https://koha-community.org/manual/25.11/fr/html/) (83%)
- [German](https://koha-community.org/manual/25.11/de/html/) (84%)
- [Greek](https://koha-community.org/manual/25.11/el/html/) (91%)
- [Hindi](https://koha-community.org/manual/25.11/hi/html/) (62%)
- [Portuguese (Brazil)](https://koha-community.org/manual/25.11/pt_BR/html/) (28%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (89%)
- Armenian (hy_ARMN) (100%)
- Azerbaijani (64%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified Han script) (81%)
- Chinese (Traditional Han script) (94%)
- Czech (65%)
- Dutch (89%)
- English (100%)
- English (New Zealand) (60%)
- English (USA)
- Finnish (99%)
- French (100%)
- French (Canada) (97%)
- German (100%)
- Greek (64%)
- Hindi (92%)
- Italian (80%)
- Khmer (Central) (58%)
- Norwegian Bokmål (69%)
- Persian (fa_ARAB) (90%)
- Polish (100%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (88%)
- Russian (91%)
- Slovak (58%)
- Spanish (96%)
- Swedish (88%)
- Telugu (63%)
- Turkish (78%)
- Ukrainian (73%)
- Uzbek (54%)
- Western Armenian (hyw_ARMN) (58%)
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

The release team for Koha 25.11.08 is


- Release Manager: Pedro Amorim

- QA Manager: Lisette Scheer

- QA Team:
  - Marcel de Rooy
  - Martin Renvoize
  - Jonathan Druart
  - Laura Escamilla
  - Lucas Gass
  - Tomás Cohen Arazi
  - Lisette Scheer
  - Nick Clemens
  - Paul Derscheid
  - Emily Lamancusa
  - David Cook
  - Matt Blenkinsop
  - Andrew Fuerste-Henry
  - Brendan Lawlor
  - Pedro Amorim
  - Kyle M Hall
  - Aleisha Amohia
  - David Nind
  - Baptiste Wojtkowski
  - Jan Kissig
  - Katrin Fischer
  - Thomas Klausner
  - Julian Maurice
  - Owen Leonard
  - Lucas Gass

- Documentation Manager: Aude Charillon

- Documentation Team:
  - Philip Orr
  - Caroline Cyr La Rose
  - David Nind
  - Marion Durand

- Translation Manager: Jonathan Druart


- Wiki curators:
  - George Williams
  - Thomas Dukleth

- Release Maintainers:
  - 26.05 -- Lucas Gass
  - 25.11 -- Baptiste Wojtkowski
  - 25.05 -- Wainui Witika-Park
  - 24.11 -- Fridolin Somers

- Release Maintainer assistants:
  - 26.05 --Jacob O'Mara
  - 25.05 -- Alex Buckley & Aleisha Amohia



## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 25.11.08
<div style="column-count: 2;">

- Athens County Public Libraries
- [OpenFifth](https://openfifth.co.uk)
</div>

We thank the following individuals who contributed patches to Koha 25.11.08
<div style="column-count: 2;">

- Pedro Amorim (2)
- Tomás Cohen Arazi (1)
- Nick Clemens (1)
- David Cook (3)
- Jonathan Druart (8)
- Laura Escamilla (1)
- Lucas Gass (3)
- Amit Gupta (1)
- Jan Kissig (2)
- Owen Leonard (2)
- Chris Mathevet (1)
- Andrew Nugged (1)
- Sanjar Tulkinov Anvar o'g'li (1)
- Eric Phetteplace (1)
- Martin Renvoize (2)
- Olivia Reynolds (1)
- Lisette Scheer (1)
- Fridolin Somers (1)
- Baptiste Wojtkowski (6)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 25.11.08
<div style="column-count: 2;">

- Athens County Public Libraries (2)
- [BibLibre](https://www.biblibre.com) (7)
- [ByWater Solutions](https://bywatersolutions.com) (6)
- Independant Individuals (3)
- informaticsglobal.ai (1)
- Koha Community Developers (8)
- [OpenFifth](https://openfifth.co.uk) (5)
- [Prosentient Systems](https://www.prosentient.com.au) (3)
- [Solutions inLibro inc](https://inlibro.com) (1)
- [Theke Solutions](https://theke.io) (1)
- Wildau University of Technology (2)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Aleisha Amohia (1)
- David Cook (4)
- Paul Derscheid (1)
- Jonathan Druart (8)
- Marion Durand (1)
- Laura Escamilla (3)
- Andrew Fuerste-Henry (1)
- Eric Garcia (1)
- Lucas Gass (29)
- Jan Kissig (1)
- Owen Leonard (1)
- David Nind (21)
- Lawrence O'Regan-Lloyd (1)
- Martin Renvoize (2)
- Baptiste Wojtkowski (28)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 25.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 25 Aug 2026 15:26:07.
