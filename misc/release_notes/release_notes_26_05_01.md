# RELEASE NOTES FOR KOHA 26.05.01
01 Jul 2026

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 26.05.01 can be downloaded from:

- [Download](https://download.koha-community.org/koha-26.05.01.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 26.05.01 is a bugfix/maintenance release.

It includes 2 enhancements, 56 bugfixes.

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
  >Updates changes to the 25.11 release team, and adds the details of people in the 26.05 release team. (More > About Koha > Koha team.)

### Accessibility

#### Other bugs fixed

- [42229](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42229) Form label used on non-form elements on opac-memberentry.tt pages
- [42232](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42232) Fieldset with missing legend on OPAC account messaging settings page (opac-messaging.tt)
  >This fixes an accessibility issue on the patron's OPAC account messaging preferences form: Missing legend for the fieldset with submit changes and cancel buttons.
  >
  >It adds a legend tag "visible" for screen reader patrons so that it is clear for the group of buttons what they are being asked to do.
- [42233](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42233) OPAC suggestions table header contains no text
- [42234](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42234) OPAC checkout history page table header contains no text
  >This fixes the patron checkout history table in the OPAC. It adds a title to the cover image column ("Cover image").
- [42299](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42299) OPAC detail page: star ratings has no associated label
  >This fixes an accessibility issue for star ratings on the OPAC record details page - it adds a label for screen reader patrons.
- [42498](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42498) Accessibility - Page tabs/pagination on results in opac produces accessibility error  "Aria state or property has invalid value"

  **Sponsored by** *Athens County Public Libraries*

### Acquisitions

#### Critical bugs fixed

- [42723](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42723) Purchase suggestion 500 page error when EmailPurchaseSuggestions is set to "email address of library"
  >This fixes a 500 page error[1] when creating a suggestion in the staff interface if:
  >- the EmailPurchaseSuggestions system preference is set to "email address of library", and
  >- the library for acquisition information is set to "Any".
  >
  >[1] Can't call method "inbound_email_address" on an undefined value at /kohadevbox/koha/Koha/Suggestion.pm line 107

#### Other bugs fixed

- [32938](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32938) Acquisitions EDI - ORDRSP messages are loaded as invoices

  **Sponsored by** *OpenFifth*
- [41998](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41998) Some templates in suggestion.pl are computed even through a redirection
- [42710](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42710) Purchase suggestion creation form (staff interface) no longer defaults to logged-in library
  >This fixes entering suggestions using the staff interface. When making a suggestion the default library selected was "Any". The default library is now the current library you are logged in as.
- [42740](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42740) Suggestion status is not kept when editing a suggestion
- [42750](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42750) Purchase suggestions made from members/purchase-suggestions.pl no longer redirect back
  >This fixes the redirect when making a suggestion for a patron (Patrons > [Selected patron] > Purchase suggestions).
  >
  >After creating a suggestion, the staff patron is now redirected back to the patron's purchase suggestion page. Previously, they stayed on the list of suggestions on the suggestion management page in acquisitions.
  >
  >(This fixes an error introduced by Bug 39721 - Remove GetSuggestion from C4/Suggestions.pm, added to Koha 26.05 and 25.11.)
- [42757](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42757) Suggester is not passed by purchase-suggestions.pl
  >This fixes "Suggested by" when making a suggestion for a patron from Patrons > [Selected patron] > Purchase suggestions.
  >
  >"Suggested by" was being recorded as the logged in librarian, instead of the patron that made the suggestion.

### Cataloging

#### Other bugs fixed

- [41829](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41829) Tag editor button has wrong id on copied MARC field when value builder plugin is used

  **Sponsored by** *Koha-Suomi Oy*
- [41987](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41987) addbooks.tt has duplicate IDs searchresult-breeding
- [42178](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42178) The Close button submits the remove from bundle form

  **Sponsored by** *Lund University Library*
- [42612](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42612) "Import this batch into the catalog" button has useless class
- [42701](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42701) Ability to click anywhere in item row for edit and delete options is missing

### Circulation

#### Other bugs fixed

- [41705](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41705) Popup blockers may be triggered by options to automatically display payment receipt for printing after making a payments

  **Sponsored by** *OpenFifth*
- [41992](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41992) Checkout History remembering Last Page
- [42454](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42454) Terminology: Use "and" instead of "&" for curbside pickups "Staged & ready (0)" tab
  >This fixes the "Staged & ready (0)" tab for curbside pickups (Circulation > Holds and bookings > Curbside pickup) so that it uses "and" instead of "&" in the table title, as per the terminology guidelines (when CurbsidePickup is enabled).

### ERM

#### Other bugs fixed

- [42130](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42130) Holdings created in ERM with a linked bibliographic record does not index the record
  >This fixes indexing of records, so that when a new title is added in the ERM module (ERM > eHoldings > Local > Titles) and 'Create bibliographic record' is selected, the new record can be found when searching.

### Hold requests

#### Other bugs fixed

- [42395](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42395) Missing translations for the existing holds table (load_patron_holds_table) for a record in the staff interface
  >This fixes the translatability of strings for the existing holds table in the staff interface for a record (Staff interface > [details page for a record] > Holds > Existing holds).
  >
  >These strings were not previously translated:
  >- Priority column: In transit, Waiting, and In processing
  >- Change priority column: tooltip text for arrows:
  >  . Move hold up
  >  . Move hold to top
  >  . Move hold to bottom
  >  . Move hold down

  **Sponsored by** *Koha-Suomi Oy*

### I18N/L10N

#### Other bugs fixed

- [42741](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42741) Plural strings don't apply in list content column

### Installation and upgrade (command-line installer)

#### Critical bugs fixed

- [42795](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42795) Bug 40658 breaks CLI for 25.11

### Mana-kb

#### Other bugs fixed

- [42194](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42194) Sharing a report to Mana does not give feedback

### OPAC

#### Critical bugs fixed

- [42555](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42555) (Bug 25314 follow-up) ID incorrectly used for facet label for customized facets in the OPAC
  >This fixes the labels for facets in the OPAC. Customized facets generated from mappings.yaml were displayed with the technical type_id instead of the proper label.
  >
  >For example, for a facet defined as "su-gen" with a label of "Genre/Form", "su-gen" was used as the label instead of "Genre/Form".
  >
  >(This is related to Bug 25314 - Make OPAC facets collapse, added to Koha 26.05.00,25.11.04.)

#### Other bugs fixed

- [34973](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34973) Update Font Awesome for the OPAC to fix JavaScript warning in the console for Firefox: "Glyph bbox was incorrect"
  >This fixes browser console JavaScript errors about Font Awesome fonts for the OPAC when using Firefox. The version of Font Awesome used was upgraded from 6.3 to 7.2 as part of fixing this.

  **Sponsored by** *Athens County Public Libraries*
- [42193](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42193) The "Suspend hold" modal in the OPAC sometimes tries to resume hold

### Patrons

#### Other bugs fixed

- [42245](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42245) Patron search for guarantors is preselecting borrower sort values from the borrower record
  >This fixes the "Add guarantor" pop-up window when adding a guarantor for a patron.
  >
  >The form was populating the "Sort 2" field with the value from the patron you are adding the guarantor to (if they had values stored for the Sort 1 and Sort 2 fields in the library management section).
- [42781](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42781) Declare 'name' before using it in patron-format.js

### Reports

#### Critical bugs fixed

- [42361](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42361) [CVE-2026-6428] SQL Injection in reports/catalogue_out.pl via Filter parameter (error-based, triggered when Criteria matches /branchcode/)

### Searching - Elasticsearch

#### Critical bugs fixed

- [42485](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42485) Elasticsearch dynamic mapping date detection causes indexing failures with ARRAY MARC format

### Serials

#### Other bugs fixed

- [42844](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42844) Subscription search breaks when using additional field and no search result is returned

### Staff interface

#### Other bugs fixed

- [42084](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42084) Incorrect interface shown in log viewer for system preference changes
- [42133](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42133) Cataloguing plugins are broken on the batch item mod tool (again)
- [42708](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42708) Itemtype images no longer displayed on the holdings table
  >This fixes showing item type images in the staff interface holdings table.
  >
  >Item type images weren't showing where noItemTypeImages was set to "Show", and were showing when it was set to "Don't show" (the opposite of what it should be).
  >
  >The correct behavour for the noItemTypeImages system preference is now restored:
  >- If set to "Show", the item type image is shown.
  >- If set to "Don't show", the item type image is not shown.
  >
  >(This was a regression from bug 41566 - Tidy kohaTable block - catalogue, added to Koha 26.05.)

### Templates

#### Other bugs fixed

- [42154](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42154) Bug 38714 hid the "New match check" link in record matching rules

  **Sponsored by** *Athens County Public Libraries*
- [42441](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42441) Remove event attributes from authority merge template

  **Sponsored by** *Athens County Public Libraries*
- [42475](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42475) Terminology: OPAC is an abbreviation
  >Changes opac to OPAC for these system preference descriptions:
  >- NovelistSelectProfile
  >- item-level_itypes
  >- OpacSuppressionByIPRange
- [42518](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42518) Capitalization: Refund Payout Receipt
  >This fixes the capitalization (title case to sentence case) for a heading in the "Point of sale payout receipt (PAYOUT)" print notice template: Refund Payout Receipt --> Refund payout receipt.
  >
  >Note: This only affects new Koha installations. Existing installations need to either manually update the notice or replace the existing notice with the default notice text.
- [42684](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42684) Capitalization: No Barcode and several other occurrences where title case is used instead of sentence case
  >This fixes the capitalization (title case used instead of sentence case) in several modules:
  >- Acquisitions:
  >  . Processing Errors --> Processing errors
  >- Reports:
  >  . Reports Dictionary --> Reports dictionary
  >  . Saved Reports --> Saved reports 
  >- Interlibrary loans (ILL):
  >  . Home Library --> Home library
  >  . Holding Library --> Holding library
  >  . No Barcode --> No barcode
  >  . Supplying Agency Request ID --> Supplying agency request ID
  >  . Requesting Agency --> Requesting agency
  >  . Visit ILL requests (previously ILL Module) --> Visit ILL requests (previously ILL module)
  >  . ILL Requests --> ILL requests
  >  . visit the ILL requests (previously ILL Module) --> visit the ILL requests (previously ILL module)
  >- ERM and ILL dashboards:
  >   . Open Widget Picker --> Open widget picker
  >- View-based modules:
  >  . Invalid Date --> Invalid date
  >- OPAC authentication:
  >  . Koha Administrator --> Koha administrator
  >- About Koha:
  >  . Not Installed --> Not installed
- [42691](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42691) Typo: automaticaly
  >Fixes a spelling error in the AutomaticRenewalPeriodBase system preference - automaticaly -> automatically.
- [42692](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42692) Typo: regarless
  >Fixes a spelling error in the AllNoticeStylesheet system preference - regarless -> regardless.
- [42695](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42695) Minor language and markup corrections to reports error messages
  >This fixes the HTML markup for some report error messages, along with some minor text changes:
  >- Uses an H1 for the heading
  >- Uses p for paragraphs

  **Sponsored by** *Athens County Public Libraries*

### Test Suite

#### Critical bugs fixed

- [42764](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42764) codespell.t fails after container OS upgrade due to newer codespell dictionary

#### Other bugs fixed

- [42705](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42705) OPAC/SCO_spec.ts  is failing
- [42733](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42733) Tools/ManageMarcImport_spec.ts is failing (again)
- [42783](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42783) Tools/ManageMarcImport_spec.ts is still flaky
- [42862](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42862) bookingsModalDatePicker_spec.ts is failing

## Enhancements 

### Architecture, internals, and plumbing

#### Enhancements

- [41605](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41605) Fix incorrect default value keys in Vue

### System Administration

#### Enhancements

- [29587](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29587) Test mail option in SMTP servers
  >This enhancement adds a "Send test email" action on the SMTP servers administration page.
  >
  >It sends a test message to the address in the KohaAdminEmailAddress system preference and reports success or failure.

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [English (USA)](https://koha-community.org/manual/26.05/en/html/)
- [French](https://koha-community.org/manual/26.05/fr/html/) (80%)
- [German](https://koha-community.org/manual/26.05/de/html/) (87%)
- [Greek](https://koha-community.org/manual/26.05/el/html/) (92%)
- [Hindi](https://koha-community.org/manual/26.05/hi/html/) (62%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (87%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified Han script) (79%)
- Chinese (Traditional Han script) (92%)
- Czech (64%)
- Dutch (85%)
- English (100%)
- English (New Zealand) (58%)
- English (USA)
- Finnish (99%)
- French (99%)
- French (Canada) (94%)
- German (100%)
- Greek (63%)
- Hindi (90%)
- Italian (78%)
- Norwegian Bokmål (67%)
- Persian (fa_ARAB) (88%)
- Polish (99%)
- Portuguese (Brazil) (98%)
- Portuguese (Portugal) (88%)
- Russian (88%)
- Slovak (56%)
- Spanish (94%)
- Swedish (88%)
- Telugu (62%)
- Turkish (76%)
- Ukrainian (71%)
- Western Armenian (hyw_ARMN) (57%)
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

The release team for Koha 26.05.01 is


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
new features in Koha 26.05.01
<div style="column-count: 2;">

- Athens County Public Libraries
- [Koha-Suomi Oy](https://koha-suomi.fi)
- Lund University Library
- [OpenFifth](https://openfifth.co.uk)
</div>

We thank the following individuals who contributed patches to Koha 26.05.01
<div style="column-count: 2;">

- Saiful Amin (1)
- Pedro Amorim (10)
- Tomás Cohen Arazi (1)
- Matt Blenkinsop (1)
- Kevin Carnes (1)
- Nick Clemens (1)
- David Cook (7)
- Jonathan Druart (12)
- Magnus Enger (1)
- Laura Escamilla (5)
- Lucas Gass (11)
- Kyle M Hall (1)
- Janusz Kaczmarek (1)
- Jan Kissig (1)
- Emily Lamancusa (1)
- Owen Leonard (14)
- Julian Maurice (2)
- Artur Mickiewicz (1)
- David Nind (2)
- Eric Phetteplace (1)
- Martin Renvoize (13)
- Marcel de Rooy (1)
- Johanna Räisä (1)
- Maryse Simard (1)
- Emmi Takkinen (1)
- Hammat Wele (1)
- Baptiste Wojtkowski (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 26.05.01
<div style="column-count: 2;">

- Athens County Public Libraries (14)
- [BibLibre](https://www.biblibre.com) (3)
- [ByWater Solutions](https://bywatersolutions.com) (18)
- David Nind (2)
- Independant Individuals (3)
- Koha Community Developers (12)
- [Koha-Suomi Oy](https://koha-suomi.fi) (1)
- [Libriotech](https://libriotech.no) (1)
- Lund University Library (1)
- mail.com (1)
- [Montgomery County Public Libraries](https://montgomerycountymd.gov) (1)
- [OpenFifth](https://openfifth.co.uk) (24)
- [Prosentient Systems](https://www.prosentient.com.au) (7)
- Rijksmuseum, Netherlands (1)
- semanticconsulting.com (1)
- [Solutions inLibro inc](https://inlibro.com) (2)
- [Theke Solutions](https://theke.io) (1)
- Wildau University of Technology (1)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Alex Carver [Acerock7] (1)
- Tomás Cohen Arazi (1)
- Emmanuel Bétemps (1)
- Nick Clemens (1)
- Roman Dolny (1)
- Jonathan Druart (18)
- Hannah Dunne-Howrie (2)
- Laura Escamilla (15)
- Andrew Fuerste-Henry (3)
- Lucas Gass (83)
- Barbara Johnson (1)
- Jan Kissig (2)
- Brendan Lawlor (4)
- Owen Leonard (5)
- David Nind (30)
- Sanjar Tulkinov Anvar o'g'li (7)
- Martin Renvoize (7)
- Phil Ringnalda (1)
- Marcel de Rooy (10)
- Michaela Sieber (1)
- Emmi Takkinen (1)
- Baptiste Wojtkowski (2)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 26.05.x-security.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 01 Jul 2026 21:53:01.
