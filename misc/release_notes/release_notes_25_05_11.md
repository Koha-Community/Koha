# RELEASE NOTES FOR KOHA 25.05.11
02 Jun 2026

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 25.05.11 can be downloaded from:

- [Download](https://download.koha-community.org/koha-25.05.11.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 25.05.11 is a bugfix/maintenance release.

It includes 1 enhancements, 34 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [38414](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38414) Reports permissions not properly enforced
- [42361](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42361) SQL Injection in reports/catalogue_out.pl via Filter parameter (error-based, triggered when Criteria matches /branchcode/)

## Bugfixes

### Architecture, internals, and plumbing

#### Critical bugs fixed

- [41328](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41328) All KohaTable tables broken in Vue components
- [42071](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42071) Suggestion does not load when viewing the suggestion
  >This fixes suggestion details not showing when you click the title in the staff interface suggestions management table.
  >
  >(Related to changes made by Bug 41857 - Suggestions table actions broken (Update manager and Delete selected), added in Koha 26.05.)
- [42098](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42098) EDIFACT edi_cron.pl runs disabled plugins due to bug in Koha::Plugins::Handler::run
  >Closes a loophole in our plugin handler that meant that some plugin methods may have run even when the plugin was marked as disabled.

### Cataloging

#### Other bugs fixed

- [41417](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41417) 500 error when creating new authorized values from additem.pl

### Circulation

#### Critical bugs fixed

- [34000](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34000) Don't allow auto-generated cardnumbers to be re-used, it may give access of services to the next patron created

#### Other bugs fixed

- [41518](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41518) "Scheduled for automatic renewal" displays even if patron does not allow automatic renewals
  >This change makes the "Scheduled for automatic renewal" text only appear in the renew column of checkouts table in the staff interface and OPAC when the item will actually be considered for automatic renewal.
  >
  >The text was showing, even if the item would not automatically be renewed due to automatic renewals being disallowed at the patron level.
  >
  >This now matches the criteria that misc/cronjobs/automatic_renewals.pl uses for processing automatic renewals.
- [41886](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41886) Biblio::check_booking counts checkouts on non-bookable items causing false clashes

  **Sponsored by** *Büchereizentrale Schleswig-Holstein*

### Fines and fees

#### Critical bugs fixed

- [29923](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29923) Do not generate overpayment refund from writeoff of fine

### Notices

#### Other bugs fixed

- [41393](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41393) Advance notices should set the reply to address

### OPAC

#### Other bugs fixed

- [41558](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41558) Broken links to tab on opac-user
  >This fixes and standardizes links to tabs for the patron summary section in the OPAC (such as Checked out, Overdue, Charges, Holds, and so on).
  >
  >In the past, we have used several different ways (some that work, some that don't) to construct the links to the tabs.
  >
  >Now, to directly link to a tab in the summary section, add ?tab=opac-user-* to the URL when you are in the summary section (where * = tab name from the anchor when you hover over the tab, for example checkouts (for Checked out), overdues (for Overdue), fines (for Overdue), recalls (for Recalls)).
- [41970](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41970) PA_CLASS does not show in fieldset ID on opac-memberentry.pl

### Patrons

#### Critical bugs fixed

- [42423](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42423) Submit button in patron search from header never submits
  >This fixes the patron search in the staff interface header. 
  >
  >If the search you enter didn't show any autocomplete results, clicking the arrow to search didn't do anything.
  >
  >Now, it will use the search you entered and show any results.

#### Other bugs fixed

- [41675](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41675) Username value is ignored in Patron quick-add form
- [41904](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41904) "Use of uninitialized value..." warning in del_message.pl

  **Sponsored by** *Ignatianum University in Cracow*
- [41986](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41986) Names in "Contact information" need more clarity
  >This changes the "Contact information" section on the patron details page (moremember.pl) to:
  >- show the "Middle name" field (where it exists)
  >- show the "Preferred name" field at the top (where it differs from the "First name").

### Reports

#### Other bugs fixed

- [41715](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41715) Argument "YYYY-MM-DD" isn't numeric in numeric lt (<)... warnings in issues_stats.pl
  >Removes the cause of "[WARN] Argument "YYYY-MM-DD" isn't numeric in numeric lt (<) at /kohadevbox/koha/reports/issues_stats.pl line 224." warnings from the plack-intranet-error.log when using the from and to date filter in the circulation statistics report in the staff interface.
  >
  >This was happening because a numerical comparison was used to compare the dates, instead of a string comparison.

  **Sponsored by** *Ignatianum University in Cracow*

### SIP2

#### Other bugs fixed

- [36752](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36752) Remove TODO about missing summary info in the SIP2 code
- [41811](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41811) SIP server will inadvertently remove non-alphanumeric characters from the end of a message
- [41818](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41818) SIP2 message in AF field should be stripped of newlines and carriage returns

### Searching

#### Other bugs fixed

- [41444](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41444) Fetch transfers directly for search results
- [41496](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41496) Item search copy sharable link not working

  **Sponsored by** *Lund University Library*

### Staff interface

#### Other bugs fixed

- [41958](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41958) Rename BibTex to BibTeX (with a capital X) for the staff interface cart and list download options (to match the OPAC)
  >This renames BibTex to BibTeX (with a capital X) for the staff interface cart and list download options (to match the OPAC).
- [41976](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41976) [Vue] LinkWrapper.vue isn't scoped properly
- [41989](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41989) addbook shows the translated interface
  >Fixes an issue with templates that meant incorrect translations could be shown on the addbook page.

### System Administration

#### Other bugs fixed

- [41360](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41360) Transport cost matrix assumes all transfers are disabled upon first use
  >This adds three new toolbar buttons to make batch modifications to the transport cost matrix table easier (when UseTransportCostMatrix is enabeld):
  >
  >* Enable all cells
  >* Disable empty cells
  >* Populate empty cells, with selectable values from 0 to 100

### Templates

#### Other bugs fixed

- [40787](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40787) Plugins buttons misaligned when search box is enabled
- [41838](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41838) Fix automatic tab selection on MARC subfield edit pages

  **Sponsored by** *Athens County Public Libraries*
- [42014](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42014) Patron lists tab shows blank content when no patron lists exist

### Test Suite

#### Other bugs fixed

- [41830](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41830) Acquisitions/Vendors_spec.ts is failing randomly

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [English (USA)](https://koha-community.org/manual/25.05/en/html/)
- [French](https://koha-community.org/manual/25.05/fr/html/) (80%)
- [German](https://koha-community.org/manual/25.05/de/html/) (88%)
- [Greek](https://koha-community.org/manual/25.05/el/html/) (92%)
- [Hindi](https://koha-community.org/manual/25.05/hi/html/) (62%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (92%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified Han script) (83%)
- Chinese (Traditional Han script) (97%)
- Czech (67%)
- Dutch (87%)
- English (100%)
- English (New Zealand) (61%)
- English (USA)
- Finnish (99%)
- French (99%)
- French (Canada) (99%)
- German (100%)
- Greek (66%)
- Hindi (94%)
- Italian (81%)
- Norwegian Bokmål (71%)
- Persian (fa_ARAB) (93%)
- Polish (100%)
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

The release team for Koha 25.05.11 is


- Release Manager: Lucas Gass

- QA Manager: Martin Renvoize

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

- Documentation Manager: David Nind

- Documentation Team:
  - Philip Orr
  - Aude Charillon
  - Caroline Cyr La Rose

- Translation Manager: Jonathan Druart


- Wiki curators: 
  - George Williams
  - Thomas Dukleth

- Release Maintainers:
  - 25.11 -- Jacob O'Mara
  - 25.05 -- Laura Escamilla
  - 24.11 -- Fridolin Somers
  - 22.11 -- Wainui Witika-Park (Catalyst IT)

- Release Maintainer assistants:
  - 25.11 -- Chloé Zermatten
  - 24.11 -- Baptiste Wojtkowski
  - 22.11 -- Alex Buckley & Aleisha Amohia

## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 25.05.11
<div style="column-count: 2;">

- Athens County Public Libraries
- [Büchereizentrale Schleswig-Holstein](https://www.bz-sh.de)
- Ignatianum University in Cracow
- Lund University Library
</div>

We thank the following individuals who contributed patches to Koha 25.05.11
<div style="column-count: 2;">

- Kevin Carnes (1)
- Nick Clemens (3)
- David Cook (9)
- Jake Deery (2)
- Paul Derscheid (3)
- Roman Dolny (2)
- Jonathan Druart (9)
- Lucas Gass (11)
- Kyle M Hall (4)
- Owen Leonard (1)
- David Nind (1)
- Martin Renvoize (5)
- Marcel de Rooy (3)
- Lisette Scheer (1)
- Slava Shishkin (1)
- Hammat Wele (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 25.05.11
<div style="column-count: 2;">

- Athens County Public Libraries (1)
- [ByWater Solutions](https://bywatersolutions.com) (19)
- David Nind (1)
- Independant Individuals (1)
- [Jezuici](https://jezuici.pl/) (2)
- Koha Community Developers (9)
- [LMSCloud](https://www.lmscloud.de) (3)
- Lund University Library (1)
- [OpenFifth](https://openfifth.co.uk) (7)
- [Prosentient Systems](https://www.prosentient.com.au) (9)
- Rijksmuseum, Netherlands (3)
- [Solutions inLibro inc](https://inlibro.com) (1)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Pedro Amorim (1)
- Scott Barter (1)
- Matt Blenkinsop (1)
- Nick Clemens (2)
- David Cook (6)
- Benjamin Daeuber (1)
- Paul Derscheid (1)
- Roman Dolny (3)
- Jonathan Druart (7)
- Laura Escamilla (32)
- Katrin Fischer (3)
- Andrew Fuerste-Henry (6)
- Lucas Gass (46)
- Kyle M Hall (2)
- Emily Lamancusa (1)
- Brendan Lawlor (2)
- Owen Leonard (3)
- David Nind (11)
- Sanjar Tulkinov Anvar o'g'li (1)
- Jacob O'Mara (3)
- Nic Olsson (1)
- Martin Renvoize (3)
- Phil Ringnalda (2)
- Marcel de Rooy (9)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 25.05.x-security.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 02 Jun 2026 21:03:46.
