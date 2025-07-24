# RELEASE NOTES FOR KOHA 24.05.12
24 Jul 2025

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 24.05.12 can be downloaded from:

- [Download](https://download.koha-community.org/koha-24.05.12.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 24.05.12 is a bugfix/maintenance release.

It includes 1 enhancements, 7 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


## Bugfixes

### Command-line Utilities

#### Other bugs fixed

- [39887](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39887) Improve documentation of overdue_notices.pl
  >This improves the help for the misc/cronjobs/overdue_notices.pl script.
  >
  >It tidies the text and clarifies some options, including:
  >- improving the descriptions for the help --test, --date, --email, and --frombranch options
  >- adding some more usage examples (shown when run with the --man option)

### OPAC

#### Other bugs fixed

- [38184](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38184) OpacTrustedCheckout module does not show due date
  >This fixes the self checkout pop-up window when using the OpacTrustedCheckout system preference - the due date is now shown in the due date column, previously it was not showing the due date.

  **Sponsored by** *Reserve Bank of New Zealand*

### Patrons

#### Critical bugs fixed

- [39331](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39331) Guarantor relationships not removed when changing patron category from memberentry.pl
  >This fixes changing a patron with guarantors from a patron category that allows guarantees to one that doesn't (for example, from Kid to a Patron). Currently, the guarantor relationships are kept (when they shouldn't be).

### Staff interface

#### Critical bugs fixed

- [39305](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39305) About page must warn if Plack is not running

#### Other bugs fixed

- [39987](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39987) Batch item deletion breadcrumb uses wrong link
  >This fixes the 'Batch item deletion' breadcrumb link when batch deleting items in cataloguing. If you clicked on the link, it would incorrectly take you to the 'Batch item modification' page.

### Templates

#### Other bugs fixed

- [38127](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38127) Missing column headings in 'Add user' pop-up modal
  >This fixes the "Add user" pop-up window when adding a user to a new order in acquisitions. The table now shows the column headings, such as card, name, category, and library.

  **Sponsored by** *Athens County Public Libraries*

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

- [Armenian (hy_ARMN)](https://koha-community.org/manual/24.05//html/) (100%)
- [Chinese (Traditional Han script)](https://koha-community.org/manual/24.05//html/) (98%)
- [English](https://koha-community.org/manual/24.05//html/) (100%)
- [English (USA)](https://koha-community.org/manual/24.05/en/html/)
- [Finnish](https://koha-community.org/manual/24.05//html/) (100%)
- [French](https://koha-community.org/manual/24.05/fr/html/) (73%)
- [German](https://koha-community.org/manual/24.05/de/html/) (97%)
- [Greek](https://koha-community.org/manual/24.05//html/) (99%)
- [Hindi](https://koha-community.org/manual/24.05/hi/html/) (70%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (97%)
- Armenian (hy_ARMN) (99%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified Han script) (88%)
- Chinese (Traditional Han script) (99%)
- Czech (69%)
- Dutch (88%)
- English (100%)
- English (New Zealand) (64%)
- English (USA)
- Finnish (100%)
- French (99%)
- French (Canada) (99%)
- German (99%)
- Greek (69%)
- Hindi (99%)
- Italian (83%)
- Norwegian Bokmål (75%)
- Persian (fa_ARAB) (97%)
- Polish (99%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (88%)
- Russian (95%)
- Slovak (62%)
- Spanish (99%)
- Swedish (87%)
- Telugu (69%)
- Tetum (53%)
- Turkish (85%)
- Ukrainian (74%)
- hyw_ARMN (generated) (hyw_ARMN) (63%)
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

The release team for Koha 24.05.12 is


- Release Manager: 

## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 24.05.12
<div style="column-count: 2;">

- Athens County Public Libraries
- Reserve Bank of New Zealand
</div>

We thank the following individuals who contributed patches to Koha 24.05.12
<div style="column-count: 2;">

- Aleisha Amohia (1)
- Nick Clemens (1)
- David Cook (1)
- Jonathan Druart (2)
- Lucas Gass (1)
- Owen Leonard (2)
- Jesse Maseto (1)
- Martin Renvoize (1)
- Tadeusz „tadzik” Sośnierz (2)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 24.05.12
<div style="column-count: 2;">

- Athens County Public Libraries (2)
- [ByWater Solutions](https://bywatersolutions.com) (3)
- Catalyst Open Source Academy (1)
- Koha Community Developers (2)
- openfifth.co.uk (1)
- [Prosentient Systems](https://www.prosentient.com.au) (1)
- sosnierz.com (2)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Roman Dolny (1)
- Owen Leonard (1)
- Jesse Maseto (11)
- Julian Maurice (2)
- David Nind (8)
- Martin Renvoize (2)
- Marcel de Rooy (1)
- Baptiste Wojtkowski (4)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 24.05.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 24 Jul 2025 13:59:41.
