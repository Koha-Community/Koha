# RELEASE NOTES FOR KOHA 25.05.01
24 Jun 2025

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 25.05.01 can be downloaded from:

- [Download](https://download.koha-community.org/koha-25.05.01.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 25.05.01 is a bugfix/maintenance release.

It includes 8 enhancements, 46 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


## Bugfixes

### Accessibility

#### Other bugs fixed

- [39475](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39475) WCAG 2.1: 1.4.10 - Content reflow - OPAC header menus
  >This fixes some accessibility reflow issues in dropdown menus for the OPAC when larger text sizes are used (for example, 400%). It specifies the text-wrap behaviour, and by reducing line-height values in some places it makes dropdown items more distinguishable from each other. This includes:
  >- Lists: a list with a very long name now wraps, instead of staying on one line that goes off the screen.
  >- User menu (when logged in): the 'Clear' button next to 'Search history' now moves down to its own line.

### Acquisitions

#### Critical bugs fixed

- [40066](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40066) Cannot add order to basket from the baskets view
  >This fixes adding items to a basket - instead of getting the pop-up window to add to the basket, the message "You can't create any orders unless you first define a budget and a fund." was shown (Acquisitions > [vendor] > Baskets > Add to basket). 
  >
  >(This is related to Bug 38010 - Migrate vendors to Vue, added to Koha 25.05.)

#### Other bugs fixed

- [40036](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40036) Purchase suggestion status column no longer displays reason
  >This restores the display of suggestion accept or reject reasons (from the SUGGEST authorized values category) in the status column for the list of purchase suggestions. (This is related to Bug 33430 - Use REST API for suggestions tables, added in Koha 25.05.)
  >
  >It also adds classes for the SUGGEST authorized values, so that these can be styled.
- [40067](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40067) "Receive shipments" should not open in a new tab/window

### Architecture, internals, and plumbing

#### Critical bugs fixed

- [40033](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40033) The background jobs page calls GetPlugins incorrectly, resulting in a 500 error
  >This fixes the background jobs page (Koha administration > Jobs > Manage jobs) so that it doesn't generate a 500 error when a plugin does not have a background task (it currently calls GetPlugins incorrectly).

#### Other bugs fixed

- [39834](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39834) Tabs need to be replaced with spaces
  >This fixes several files by replacing tabs with spaces and makes the QA script happy!
- [39920](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39920) do_check_for_previous_checkout should us 'IN' over 'OR'
- [40003](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40003) Warning generated when creating a new bib record
- [40034](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40034) CheckReserves dies if itype doesn't exist
- [40087](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40087) Remove unused C4::Scrubber profiles "tag" and "staff"

### Cataloging

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

#### Other bugs fixed

- [39919](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39919) Overdues with fines report has incorrect title, breadcrumbs, etc.

  **Sponsored by** *Athens County Public Libraries*

### Command-line Utilities

#### Critical bugs fixed

- [31124](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31124) koha-remove fails to remove long_tasks queue daemon, so koha-create for same <instance> user fails
  >This development makes `koha-remove` stop all worker processes before attempting to remove the instance's UNIX user.

#### Other bugs fixed

- [39887](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39887) Improve documentation of overdue_notices.pl
- [39961](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39961) koha-create doesn't start all queues

### ERM

#### Critical bugs fixed

- [39823](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39823) SUSHI harvest fails to display error if the provider's response does not contain Severity

#### Other bugs fixed

- [38899](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38899) Allow the Vue toolbar to be sticky
  >This restores the sticky toolbar when adding a vendor in the acquisitions module (Acquisitions > + New vendor). This is related to bug 38010, which migrates vendors in the acquisitions module to using Vue - the sticky menu was not included in this.

### ILL

#### Critical bugs fixed

- [40057](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40057) Database update 24.12.00.017 fails if old ILL data points to non-existent borrowernumber
  >This fixes a database update related to ILL requests, for bug 32630 - Don't delete ILL requests when patron is deleted, added in Koha 25.05.
  >
  >Background: Some databases have very old ILL requests where 'borrowernumber' has a value of a borrowernumber that doesn't exist. We're not exactly how the data ended up this way, but it's happened at least twice now for one provider.

#### Other bugs fixed

- [39875](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39875) ILL - History check fails if unauthenticated request
- [40025](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40025) Standard ILL requests don't update form when changing type in edit item metadata
  >This fixes editing the item metadata for a standard ILL request. If the type (such as book or journal) is changed, the metadata is now updated for the selected type. Before this, matching metadata was not updated.

### Label/patron card printing

#### Other bugs fixed

- [40061](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40061) Cannot delete image from patron card creator

  **Sponsored by** *Athens County Public Libraries*

### MARC Authority data support

#### Other bugs fixed

- [40119](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40119) Merge should not leave empty 6XX subfield $2 (MARC 21)

  **Sponsored by** *Ignatianum University in Cracow*

### MARC Bibliographic data support

#### Other bugs fixed

- [39558](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39558) Timestamps on biblio biblioitems and biblio_metadata are not in sync

### OPAC

#### Critical bugs fixed

- [38974](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38974) Error when submitting patron update from the OPAC Can't call method "dateofbirthrequired" on an undefined value
  >This fixes updating personal details in the OPAC. A 500 error was shown if the "Patron category (categorycode)" was selected in the PatronSelfModificationBorrowerUnwantedField system preference and the date of birth field was changed or previously empty.

#### Other bugs fixed

- [40080](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40080) Course reserves details search appears offscreen
  >This fixes the alignment of the OPAC course reserves search box - it is now on the left above the table, instead of offscreen on the right-hand side.

### REST API

#### Other bugs fixed

- [39970](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39970) REST API - Creating a patron without mandatory attribute types does not error (it should)

### Reports

#### Other bugs fixed

- [39866](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39866) Acquisitions statistics fails when filling only the To date
- [39955](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39955) Report subgroup filter not cleared when changing tabs

  **Sponsored by** *Athens County Public Libraries*

### SIP2

#### Critical bugs fixed

- [39911](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39911) Fatal errors from SIP server are not logged

### Self checkout

#### Other bugs fixed

- [40108](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40108) Self-checkout print receipt option not working

  **Sponsored by** *Athens County Public Libraries*

### Staff interface

#### Critical bugs fixed

- [40002](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40002) Cannot filter patrons by "Browse by last name"

#### Other bugs fixed

- [39903](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39903) Catalog details page emits error if librarian cannot moderate comments on the record
- [39987](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39987) Batch item deletion breadcrumb uses wrong link
- [40166](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40166) Syspref description for ILS-DI:AuthorizedIPs is incorrect

### System Administration

#### Other bugs fixed

- [37439](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37439) ChildNeedsGuarantor description misleading

### Templates

#### Other bugs fixed

- [38127](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38127) Missing column headings in 'Add user' pop-up modal
  >This fixes the "Add user" pop-up window when adding a user to a new order in acquisitions. The table now shows the column headings, such as card, name, category, and library.

  **Sponsored by** *Athens County Public Libraries*
- [39499](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39499) Add some padding to the Save button in the sticky bar in cataloging

  **Sponsored by** *Athens County Public Libraries*
- [39947](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39947) Use bg-*-subtle in preference to bg-* Bootstrap classes
  >This fixes some Bootstrap color classes.
  >
  >It removes a few instances of the "bg-*" class from templates (used in a few places such as bg-info, bg-danger, etc.) as the styles don't really fit with the staff interface's color palette. Examples include the circulation and fine rules page and the patron import tool page.
  >
  >In the places where we don't want to use the corresponding alert classes, it adds some CSS so that we can safely use the ".bg-*-subtle" class to a div with ".page-section.".
  >
  >(This is related to Bug 39274 - HTML bg-* elements are low contrast, added to Koha 25.05, and Bug 35402 - Update the OPAC and staff interface to Bootstrap 5, added to Koha 24.11.)

  **Sponsored by** *Athens County Public Libraries*
- [40042](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40042) search_indexes.inc may have undefined index var

### Test Suite

#### Other bugs fixed

- [36625](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36625) t/db_dependent/Koha/Biblio.t leaves test data in the database
- [40018](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40018) Remove warning from Koha/Template/Plugin/Koha.t
- [40019](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40019) Koha/Auth/Client.t produces warnings
- [40020](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40020) Koha/AdditionalContents.t produces warnings
- [40021](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40021) Koha/Plugins/Recall_hooks.t produces warnings

## Enhancements 

### Accessibility

#### Enhancements

- [39434](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39434) The pages are missing semantic tags that identify the regions of the pages.

### Acquisitions

#### Enhancements

- [38298](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38298) EDIFACT breadcrumbs need to be permissions based

### Architecture, internals, and plumbing

#### Enhancements

- [40055](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40055) C4::Reserves::MoveReserve should be passed objects

### Lists

#### Enhancements

- [33440](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33440) A public list can be transferred to a staff member without list permissions

### Notices

#### Enhancements

- [36020](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36020) Port default recall notices to Template Toolkit
  >This enhancement adds recalls to the objects that can be called using Template Toolkit and updates the default notices for RETURN_RECALLED_ITEM, PICKUP_RECALLED_ITEM, and RECALL_REQUESTER_DET notices. 
  >
  >It uses [% INCLUDE 'biblio-title.inc' biblio=biblio link=0 %]  and [% INCLUDE 'patron-title.inc' patron => borrower, no_title => 1, no_html = 1 %] to pull in the title and patron information. 
  >
  >Existing installations will not see changes to their notices but they can be viewed using the "See default" button when editing the notice.

### OPAC

#### Enhancements

- [39925](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39925) Table columns missing headings for bibliographic search history in OPAC

  **Sponsored by** *Athens County Public Libraries*

### Reports

#### Enhancements

- [23978](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23978) Notes field in saved reports should allow for (scrubbed) HTML

### Templates

#### Enhancements

- [39948](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39948) Simplify unauthenticated ILL request detail in the OPAC
  >This enhancement simplifies the unauthenticated ILL submission detail page for the OPAC. It removes 'Unauthenticated ...' in front of the labels for the first name, last name, and email fields.

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [English (USA)](https://koha-community.org/manual/25.05/en/html/)
- [French](https://koha-community.org/manual/25.05/fr/html/) (73%)
- [German](https://koha-community.org/manual/25.05/de/html/) (98%)
- [Greek](https://koha-community.org/manual/25.05/el/html/) (100%)
- [Hindi](https://koha-community.org/manual/25.05/hi/html/) (70%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<!-- <div style="column-count: 2;"> -->

- Arabic (ar_ARAB) (93%)
- Armenian (hy_ARMN) (99%)
- Bulgarian (bg_CYRL) (99%)
- Chinese (Simplified Han script) (84%)
- Chinese (Traditional Han script) (98%)
- Czech (65%)
- Dutch (86%)
- English (100%)
- English (New Zealand) (62%)
- English (USA)
- Finnish (99%)
- French (99%)
- French (Canada) (95%)
- German (99%)
- Greek (65%)
- Hindi (95%)
- Italian (79%)
- Norwegian Bokmål (72%)
- Persian (fa_ARAB) (94%)
- Polish (100%)
- Portuguese (Brazil) (95%)
- Portuguese (Portugal) (87%)
- Russian (92%)
- Slovak (59%)
- Spanish (98%)
- Swedish (87%)
- Telugu (66%)
- Tetum (51%)
- Turkish (81%)
- Ukrainian (71%)
- Western Armenian (hyw_ARMN) (61%)
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

The release team for Koha 25.05.01 is


- Release Manager: 

## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 25.05.01
<!-- <div style="column-count: 2;"> -->

- Athens County Public Libraries
- Ignatianum University in Cracow
<!-- </div> -->

We thank the following individuals who contributed patches to Koha 25.05.01
<!-- <div style="column-count: 2;"> -->

- Pedro Amorim (10)
- Tomás Cohen Arazi (9)
- Matt Blenkinsop (9)
- Nick Clemens (6)
- David Cook (2)
- Jake Deery (1)
- Paul Derscheid (1)
- Jonathan Druart (16)
- Laura Escamilla (5)
- Lucas Gass (3)
- Kyle M Hall (4)
- Andreas Jonsson (1)
- Janusz Kaczmarek (2)
- Emily Lamancusa (1)
- Owen Leonard (10)
- Nina Martinez (1)
- Martin Renvoize (5)
- Adolfo Rodríguez (1)
- Marcel de Rooy (2)
- Lisette Scheer (1)
- Fridolin Somers (1)
- Tadeusz „tadzik” Sośnierz (1)
- Theodoros Theodoropoulos (1)
<!-- </div> -->

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 25.05.01
<!-- <div style="column-count: 2;"> -->

- Aristotle University Of Thessaloniki (Αριστοτέλειο Πανεπιστήμιο Θεσσαλονίκης) (1)
- Athens County Public Libraries (10)
- [BibLibre](https://www.biblibre.com) (2)
- [ByWater Solutions](https://bywatersolutions.com) (19)
- [HKS3](https://koha-support.eu) (1)
- Independant Individuals (2)
- Koha Community Developers (16)
- Kreablo AB (1)
- [LMSCloud](https://www.lmscloud.de) (1)
- [Montgomery County Public Libraries](https://montgomerycountymd.gov) (1)
- [Open Fifth](https://openfifth.co.uk/) (25)
- [Prosentient Systems](https://www.prosentient.com.au) (2)
- Rijksmuseum, Netherlands (2)
- [Theke Solutions](https://theke.io) (9)
- [Xercode](https://xebook.es) (1)
<!-- </div> -->

We also especially thank the following individuals who tested patches
for Koha
<!-- <div style="column-count: 2;"> -->

- Aleisha Amohia (1)
- Pedro Amorim (3)
- Tomás Cohen Arazi (2)
- Christopher (1)
- Nick Clemens (5)
- David Cook (4)
- Paul Derscheid (92)
- Roman Dolny (10)
- Jonathan Druart (10)
- Magnus Enger (6)
- Laura Escamilla (1)
- Katrin Fischer (2)
- David Flater (1)
- Brendan Gallagher (1)
- Lucas Gass (88)
- Claire Hernandez (1)
- Emily Lamancusa (3)
- Brendan Lawlor (1)
- Owen Leonard (4)
- Lin Wei Li (5)
- Julian Maurice (2)
- David Nind (33)
- Martin Renvoize (5)
- Marcel de Rooy (27)
- Caroline Cyr La Rose (2)
- Lisette Scheer (2)
- Michelle Spinney (1)
- Emmi Takkinen (1)
- Baptiste Wojtkowski (9)
- Anneli Österman (1)
<!-- </div> -->





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 25.05.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 24 Jun 2025 17:07:53.
