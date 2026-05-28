# RELEASE NOTES FOR KOHA 24.11.16
28 May 2026

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 24.11.16 can be downloaded from:

- [Download](https://download.koha-community.org/koha-24.11.16.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 24.11.16 is a bugfix/maintenance release with security patches.

It includes 1 enhancements, 34 bugfixes (4 security).

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [38414](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38414) Reports permissions not properly enforced
- [42136](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42136) User-entered Template::Toolkit allows information disclosure
- [42224](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42224) (Bug 40524 follow-up) [24.11.x] Fix XSS in columns_settings.inc
- [42361](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42361) SQL Injection in reports/catalogue_out.pl via Filter parameter (error-based, triggered when Criteria matches /branchcode/)

## Bugfixes

### Acquisitions

#### Other bugs fixed

- [41420](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41420) Syntax error in referrer in parcel.tt
  >This fixes the URL for the "Cancel order and catalog record" link when receiving an order for an invoice - the referrer section of the URL was missing.

### Architecture, internals, and plumbing

#### Critical bugs fixed

- [42071](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42071) Suggestion does not load when viewing the suggestion
  >This fixes suggestion details not showing when you click the title in the staff interface suggestions management table.
  >
  >(Related to changes made by Bug 41857 - Suggestions table actions broken (Update manager and Delete selected), added in Koha 26.05.)
- [42098](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42098) EDIFACT edi_cron.pl runs disabled plugins due to bug in Koha::Plugins::Handler::run
  >Closes a loophole in our plugin handler that meant that some plugin methods may have run even when the plugin was marked as disabled.

### Cataloging

#### Other bugs fixed

- [41417](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41417) 500 error when creating new authorized values from additem.pl
- [41475](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41475) 500 error when placing a hold on records with multiple 773 entries

### Circulation

#### Other bugs fixed

- [41055](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41055) Missing accesskey attribute for print button (shortcut P)

  **Sponsored by** *Koha-Suomi Oy*
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

- [40960](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40960) Only generate a notice for patrons about holds filled if they have set messaging preferences
  >Currently, if a patron has not set any messaging preferences for notifying them about holds filled, a print notice is still generated.
  >
  >With this change, a notice is now only generated for a patron if their messaging preferences for 'Hold filled' are set. This matches the behavor for overdue and hold reminder notices.

### OPAC

#### Other bugs fixed

- [41970](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41970) PA_CLASS does not show in fieldset ID on opac-memberentry.pl

### Patrons

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

- [41811](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41811) SIP server will inadvertently remove non-alphanumeric characters from the end of a message
- [41818](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41818) SIP2 message in AF field should be stripped of newlines and carriage returns

### Searching

#### Other bugs fixed

- [41444](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41444) Fetch transfers directly for search results
- [41496](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41496) Item search copy sharable link not working

  **Sponsored by** *Lund University Library*

### Staff interface

#### Other bugs fixed

- [41679](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41679) Stock rotation repatriation modal can conflict with holds modal
- [41958](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41958) Rename BibTex to BibTeX (with a capital X) for the staff interface cart and list download options (to match the OPAC)
  >This renames BibTex to BibTeX (with a capital X) for the staff interface cart and list download options (to match the OPAC).
- [41976](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41976) [Vue] LinkWrapper.vue isn't scoped properly
- [41989](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41989) addbook shows the translated interface
  >Fixes an issue with templates that meant incorrect translations could be shown on the addbook page.

### System Administration

#### Critical bugs fixed

- [41431](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41431) Circulation rule notes dropping when editing rule
  >This fixes editing circulation and fine rules with notes - notes are now correctly shown when editing, and are not lost when saving the rule.
  >
  >Previously, if you edited a rule with a note, it was not displayed in the edit field and was removed when the rule was saved.

  **Sponsored by** *Koha-Suomi Oy*

#### Other bugs fixed

- [19690](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19690) Smart rules: Term "If any unavailable" is confusing

### Templates

#### Other bugs fixed

- [40787](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40787) Plugins buttons misaligned when search box is enabled
- [41764](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41764) ISSN hidden input missing from Z39.50 search form navigation
  >This fixes the Acquisitions and Cataloging Z39.50 search forms so that the pagination works when searching using the ISSN input field.
  >
  >When you click the next page of results, or got to a specific result page, the search now works as expected - it remembers the ISSN you were searching for, with "You searched for: ISSN: XXXX" shown above the search results, and search results shown.
  >
  >Previously, the ISSN was not remembered, and "Nothing found. Try another search." was shown, and no further search results were shown.

  **Sponsored by** *Athens County Public Libraries*
- [42014](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42014) Patron lists tab shows blank content when no patron lists exist

### Test Suite

#### Critical bugs fixed

- [42090](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42090) Cypress tests are failing on 24.11

#### Other bugs fixed

- [41449](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41449) Reserves.t may fail when on shelf holds are restricted

## Enhancements 

### OPAC

#### Enhancements

- [41655](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41655) Local OPAC covers are not displayed in OPAC lists
  >This fixes a regression where the local cover images were no longer displayed in lists in the OPAC and staff interface. With this fix, the local cover images are back in the lists in both interfaces.

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [English (USA)](https://koha-community.org/manual/24.11/en/html/)
- [French](https://koha-community.org/manual/24.11/fr/html/) (80%)
- [German](https://koha-community.org/manual/24.11/de/html/) (88%)
- [Greek](https://koha-community.org/manual/24.11/el/html/) (92%)
- [Hindi](https://koha-community.org/manual/24.11/hi/html/) (62%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (95%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified Han script) (86%)
- Chinese (Traditional Han script) (99%)
- Czech (68%)
- Dutch (88%)
- English (100%)
- English (New Zealand) (63%)
- English (USA)
- Finnish (99%)
- French (99%)
- French (Canada) (99%)
- German (99%)
- Greek (68%)
- Hindi (97%)
- Italian (83%)
- Norwegian Bokmål (73%)
- Persian (fa_ARAB) (96%)
- Polish (100%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (88%)
- Russian (94%)
- Slovak (61%)
- Spanish (99%)
- Swedish (88%)
- Telugu (67%)
- Tetum (52%)
- Turkish (83%)
- Ukrainian (76%)
- Western Armenian (hyw_ARMN) (62%)
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

The release team for Koha 24.11.16 is


- Release Manager: Lucas Gass

- QA Manager: Martin Renvoize

- QA Team:
  - Andrew Fuerste-Henry
  - Andrii Nugged
  - Baptiste Wojtkowski
  - Brendan Lawlor
  - David Cook
  - Emily Lamancusa
  - Jonathan Druart
  - Julian Maurice
  - Kyle Hall
  - Laura Escamilla
  - Lisette Scheer
  - Marcel de Rooy
  - Nick Clemens
  - Paul Derscheid
  - Petro V
  - Tomás Cohen Arazi
  - Victor Grousset

- Documentation Manager: David Nind

- Documentation Team:
  - Aude Charillon
  - Caroline Cyr La Rose
  - Donna Bachowski
  - Heather Hernandez
  - Kristi Krueger
  - Philip Orr

- Translation Manager: Jonathan Druart


- Wiki curators: 
  - George Williams
  - Thomas Dukleth

- Release Maintainers:
  - 25.05 -- Paul Derscheid
  - 24.11 -- Fridolin Somers
  - 24.05 -- Jesse Maseto
  - 22.11 -- Catalyst IT (Wainui, Alex, Aleisha)

- Release Maintainer assistants:
  - 25.05 -- Martin Renvoize
  - 24.11 -- Baptiste Wojtkowski
  - 24.05 -- Laura Escamilla

## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 24.11.16
<div style="column-count: 2;">

- Athens County Public Libraries
- [Büchereizentrale Schleswig-Holstein](https://www.bz-sh.de)
- Ignatianum University in Cracow
- [Koha-Suomi Oy](https://koha-suomi.fi)
- Lund University Library
</div>

We thank the following individuals who contributed patches to Koha 24.11.16
<div style="column-count: 2;">

- Kevin Carnes (1)
- Nick Clemens (1)
- David Cook (4)
- Jake Deery (2)
- Paul Derscheid (3)
- Roman Dolny (2)
- Jonathan Druart (4)
- Lucas Gass (2)
- Kyle M Hall (3)
- Owen Leonard (1)
- David Nind (1)
- Martin Renvoize (3)
- Marcel de Rooy (3)
- Lisette Scheer (1)
- Slava Shishkin (2)
- Fridolin Somers (5)
- Emmi Takkinen (1)
- Hammat Wele (2)
- Baptiste Wojtkowski (6)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 24.11.16
<div style="column-count: 2;">

- Athens County Public Libraries (1)
- [BibLibre](https://www.biblibre.com) (11)
- [ByWater Solutions](https://bywatersolutions.com) (7)
- David Nind (1)
- Independant Individuals (2)
- [Jezuici](https://jezuici.pl/) (2)
- Koha Community Developers (4)
- [Koha-Suomi Oy](https://koha-suomi.fi) (1)
- [LMSCloud](https://www.lmscloud.de) (3)
- Lund University Library (1)
- [OpenFifth](https://openfifth.co.uk) (5)
- [Prosentient Systems](https://www.prosentient.com.au) (4)
- Rijksmuseum, Netherlands (3)
- [Solutions inLibro inc](https://inlibro.com) (2)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Pedro Amorim (1)
- Scott Barter (1)
- Nick Clemens (2)
- David Cook (3)
- Benjamin Daeuber (1)
- Roman Dolny (3)
- Jonathan Druart (5)
- Laura Escamilla (38)
- Katrin Fischer (3)
- Andrew Fuerste-Henry (4)
- Kyle M Hall (6)
- Emily Lamancusa (1)
- Brendan Lawlor (1)
- Owen Leonard (3)
- David Nind (15)
- Sanjar Tulkinov Anvar o'g'li (1)
- Martin Renvoize (3)
- Marcel de Rooy (4)
- Fridolin Somers (6)
- Emmi Takkinen (1)
- Baptiste Wojtkowski (30)
</div>





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

Autogenerated release notes updated last on 28 May 2026 10:18:09.
