# RELEASE NOTES FOR KOHA 24.11.06
25 Jun 2025

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 24.11.06 can be downloaded from:

- [Download](https://download.koha-community.org/koha-24.11.06.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 24.11.06 is a bugfix/maintenance release.

It includes 1 enhancements, 25 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


## Bugfixes

### Acquisitions

#### Critical bugs fixed

- [38411](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38411) When adding multiple items on receive, mandatory fields are not checked

### Architecture, internals, and plumbing

#### Critical bugs fixed

- [40033](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40033) The background jobs page calls GetPlugins incorrectly, resulting in a 500 error
  >This fixes the background jobs page (Koha administration > Jobs > Manage jobs) so that it doesn't generate a 500 error when a plugin does not have a background task (it currently calls GetPlugins incorrectly).

#### Other bugs fixed

- [39920](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39920) do_check_for_previous_checkout should us 'IN' over 'OR'

### Cataloging

#### Critical bugs fixed

- [39462](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39462) (bug 37870 follow-up) Default values from framework are inserted into existing record while editing

  **Sponsored by** *Pontificia Università di San Tommaso d'Aquino (Angelicum)*

#### Other bugs fixed

- [37364](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37364) Improve creation of 773 fields for item bundles regarding MARC21 245 and 264

  **Sponsored by** *PTFS Europe*
- [39991](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39991) Record comparison in vendor file - results no longer side by side

### Circulation

#### Critical bugs fixed

- [38477](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38477) Regression: new overdue fine applied incorrectly when using "Refund lost item charge and charge new overdue fine" option in circ rules
  >Under certain circumstances, the existence of a lost charge for a patron that previously borrowed an item (which was later found) could lead to creating a new fine for a patron that borrowed and returned the item with no issues - if the item was lost and found again after they had returned it.
  >
  >This adds tests to cover this edge case, and fixes this edge case to ensure that a new fine is only charged if the patron charged the lost fine matches the patron who most recently returned the item.
- [39750](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39750) Wrong transfer breaking check in when using library transfer limits

### Command-line Utilities

#### Other bugs fixed

- [39887](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39887) Improve documentation of overdue_notices.pl

### ERM

#### Critical bugs fixed

- [39823](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39823) SUSHI harvest fails to display error if the provider's response does not contain Severity

#### Other bugs fixed

- [37934](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37934) Extend length of API key, requestor ID and customer ID for data providers

### OPAC

#### Critical bugs fixed

- [38981](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38981) Local cover images failing to load in OPAC search results
  >This patchset fixes a problem where local cover images were not properly loading on the OPAC results page. With this fix local covers now load correctly.
- [39095](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39095) Clicking 'Cancel' for article requests in the OPAC patron account does not respond

  **Sponsored by** *Athens County Public Libraries*
- [39313](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39313) OpacTrustedCheckout self-checkout modal not checking out valid barcode

  **Sponsored by** *Reserve Bank of New Zealand*

#### Other bugs fixed

- [38184](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38184) OpacTrustedCheckout module does not show due date
  >This fixes the self checkout pop-up window when using the OpacTrustedCheckout system preference - the due date is now shown in the due date column, previously it was not showing the due date.

  **Sponsored by** *Reserve Bank of New Zealand*

### Patrons

#### Critical bugs fixed

- [38892](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38892) Patron category 'can be a guarantee' means that same category cannot be a guarantor (again)
- [39331](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39331) Guarantor relationships not removed when changing patron category from memberentry.pl
  >This fixes changing a patron with guarantors from a patron category that allows guarantees to one that doesn't (for example, from Kid to a Patron). Currently, the guarantor relationships are kept (when they shouldn't be).

#### Other bugs fixed

- [38847](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38847) Renewing an expired child patron without a guarantor and with ChildNeedsGuarantor set results in an internal server error
  >This fixes an internal server error when renewing an expired child patron without a guarantor, when the ChildNeedsGuarantor system preference is set to "must have". It now displays a standard error message with "This patron could not be renewed: they need a guarantor."

### Reports

#### Other bugs fixed

- [39955](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39955) Report subgroup filter not cleared when changing tabs

  **Sponsored by** *Athens County Public Libraries*

### Staff interface

#### Critical bugs fixed

- [39305](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39305) About page must warn if Plack is not running

#### Other bugs fixed

- [39987](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39987) Batch item deletion breadcrumb uses wrong link

### Templates

#### Other bugs fixed

- [38127](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38127) Missing column headings in 'Add user' pop-up modal
  >This fixes the "Add user" pop-up window when adding a user to a new order in acquisitions. The table now shows the column headings, such as card, name, category, and library.

  **Sponsored by** *Athens County Public Libraries*

### Test Suite

#### Critical bugs fixed

- [39304](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39304) Jenkins not failing when git command fails

#### Other bugs fixed

- [36625](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36625) t/db_dependent/Koha/Biblio.t leaves test data in the database

### Tools

#### Critical bugs fixed

- [39295](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39295) Patron card creator infinite loop during line wrapping in template/layout incompatibility

## Enhancements 

### Architecture, internals, and plumbing

#### Enhancements

- [39772](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39772) Background jobs page lists unknown job types for jobs implemented by plugins

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [English (USA)](https://koha-community.org/manual/24.11/en/html/)
- [French](https://koha-community.org/manual/24.11/fr/html/) (73%)
- [German](https://koha-community.org/manual/24.11/de/html/) (98%)
- [Greek](https://koha-community.org/manual/24.11/el/html/) (100%)
- [Hindi](https://koha-community.org/manual/24.11/hi/html/) (70%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<!-- <div style="column-count: 2;"> -->

- Arabic (ar_ARAB) (95%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified Han script) (86%)
- Chinese (Traditional Han script) (99%)
- Czech (67%)
- Dutch (88%)
- English (100%)
- English (New Zealand) (63%)
- English (USA)
- Finnish (99%)
- French (99%)
- French (Canada) (98%)
- German (99%)
- Greek (67%)
- Hindi (97%)
- Italian (81%)
- Norwegian Bokmål (74%)
- Persian (fa_ARAB) (97%)
- Polish (100%)
- Portuguese (Brazil) (98%)
- Portuguese (Portugal) (87%)
- Russian (94%)
- Slovak (61%)
- Spanish (100%)
- Swedish (87%)
- Telugu (68%)
- Tetum (52%)
- Turkish (83%)
- Ukrainian (73%)
- Western Armenian (hyw_ARMN) (62%)
<!-- </div> -->

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](https://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](https://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](https://translate.koha-community.org/)

## Release Team

The release team for Koha 24.11.06 is


- Release Manager: 

## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 24.11.06
<!-- <div style="column-count: 2;"> -->

- Athens County Public Libraries
- Pontificia Università di San Tommaso d'Aquino (Angelicum)
- Reserve Bank of New Zealand
<!-- </div> -->

We thank the following individuals who contributed patches to Koha 24.11.06
<!-- <div style="column-count: 2;"> -->

- Aleisha Amohia (3)
- Pedro Amorim (3)
- Tomás Cohen Arazi (1)
- Nick Clemens (5)
- David Cook (1)
- Jonathan Druart (5)
- Katrin Fischer (3)
- Lucas Gass (3)
- Janusz Kaczmarek (2)
- Owen Leonard (5)
- Martin Renvoize (3)
- Adolfo Rodríguez (1)
- Fridolin Somers (1)
- Tadeusz „tadzik” Sośnierz (3)
- Hammat Wele (1)
- Baptiste Wojtkowski (1)
<!-- </div> -->

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 24.11.06
<!-- <div style="column-count: 2;"> -->

- Athens County Public Libraries (5)
- [BibLibre](https://www.biblibre.com) (2)
- [Bibliotheksservice-Zentrum Baden-Württemberg (BSZ)](https://bsz-bw.de) (3)
- [ByWater Solutions](https://bywatersolutions.com) (8)
- Catalyst Open Source Academy (3)
- [HKS3](https://koha-support.eu) (3)
- Independant Individuals (2)
- Koha Community Developers (5)
- [Open Fifth](https://openfifth.co.uk/) (6)
- [Prosentient Systems](https://www.prosentient.com.au) (1)
- [Solutions inLibro inc](https://inlibro.com) (1)
- [Theke Solutions](https://theke.io) (1)
- [Xercode](https://xebook.es) (1)
<!-- </div> -->

We also especially thank the following individuals who tested patches
for Koha
<!-- <div style="column-count: 2;"> -->

- Pedro Amorim (2)
- Tomás Cohen Arazi (1)
- Nick Clemens (5)
- David Cook (1)
- Paul Derscheid (17)
- Roman Dolny (4)
- Magnus Enger (1)
- Katrin Fischer (20)
- Lucas Gass (18)
- Emily Lamancusa (2)
- Laurence (1)
- Owen Leonard (2)
- Lin Wei Li (2)
- Jesse Maseto (1)
- Julian Maurice (2)
- David Nind (20)
- Martin Renvoize (9)
- Marcel de Rooy (5)
- Fridolin Somers (40)
- Baptiste Wojtkowski (4)
- Anneli Österman (1)
<!-- </div> -->





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 24.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 25 Jun 2025 08:56:02.
