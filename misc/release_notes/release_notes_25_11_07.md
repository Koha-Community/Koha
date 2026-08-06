# RELEASE NOTES FOR KOHA 25.11.07
06 Aug 2026

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 25.11.07 can be downloaded from:

- [Download](https://download.koha-community.org/koha-25.11.07.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 25.11.07 is a bugfix/maintenance release with security patches.

It includes 27 bugfixes (7 security).

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [30233](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30233) Remote code execution in user-supplied regex
  >This change refactors the regular expression handling for Batch Item Modification, MARC Modification templates, and Callnumber splitting. It moves from Perl's traditional compile-time regular expression handling to a more dynamic (but restrictive) run-time regular expression handling more similar to Python's "sub" regex method. This functions to reduce vulnerabilities to code injection into Koha's Perl backend.
- [42471](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42471) /cgi-bin/koha/suggestion/suggestion.pl Multiple Parameters Stored Cross-Site Scripting
- [42746](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42746) Stored SQL injection via unvalidated 'agefield' in automatic_item_modification_by_age (C4::Items::ToggleNewStatus)
- [42747](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42747) Stored SQL injection via patroncard layout image_name (patroncards/edit-layout.pl -> create-pdf.pl)
- [42749](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42749) SQL injection in acqui/parcels.pl via the orderby parameter (ORDER BY direction) reaching C4::Acquisition::GetInvoices
- [42847](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42847) SIP authentication ignored after initial successful connection
- [42866](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42866) SQL Injection in Koha/AdditionalContents.pm search_for_display via the patron lang value (stored / second-order, executed on issue-slip print, unvalidated string context, no placeholder)
- [43019](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43019) OPAC pages limited to library are readable by unauthenticated users

## Bugfixes

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

### Acquisitions

#### Other bugs fixed

- [42919](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42919) Suggestion duplicate warning erases suggestion info

### Cataloging

#### Other bugs fixed

- [41829](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41829) Tag editor button has wrong id on copied MARC field when value builder plugin is used

  **Sponsored by** *Koha-Suomi Oy*
- [42178](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42178) The Close button submits the remove from bundle form

  **Sponsored by** *Lund University Library*
- [42972](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42972) [25.11.x] Cannot add, edit, or delete MARC overlay rules

### Circulation

#### Other bugs fixed

- [41992](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41992) Checkout History remembering Last Page

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

### Patrons

#### Other bugs fixed

- [42245](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42245) Patron search for guarantors is preselecting borrower sort values from the borrower record
  >This fixes the "Add guarantor" pop-up window when adding a guarantor for a patron.
  >
  >The form was populating the "Sort 2" field with the value from the patron you are adding the guarantor to (if they had values stored for the Sort 1 and Sort 2 fields in the library management section).
- [42781](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42781) Declare 'name' before using it in patron-format.js

### Searching - Elasticsearch

#### Critical bugs fixed

- [42485](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42485) Elasticsearch dynamic mapping date detection causes indexing failures with ARRAY MARC format

### Serials

#### Other bugs fixed

- [42844](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42844) Subscription search breaks when using additional field and no search result is returned

### Templates

#### Other bugs fixed

- [42518](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42518) Capitalization: Refund Payout Receipt
  >This fixes the capitalization (title case to sentence case) for a heading in the "Point of sale payout receipt (PAYOUT)" print notice template: Refund Payout Receipt --> Refund payout receipt.
  >
  >Note: This only affects new Koha installations. Existing installations need to either manually update the notice or replace the existing notice with the default notice text.
- [42695](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42695) Minor language and markup corrections to reports error messages
  >This fixes the HTML markup for some report error messages, along with some minor text changes:
  >- Uses an H1 for the heading
  >- Uses p for paragraphs

  **Sponsored by** *Athens County Public Libraries*

### Test Suite

#### Other bugs fixed

- [42705](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42705) OPAC/SCO_spec.ts  is failing
- [42783](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42783) Tools/ManageMarcImport_spec.ts is still flaky

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [English (USA)](https://koha-community.org/manual/25.11/en/html/)
- [French](https://koha-community.org/manual/25.11/fr/html/) (80%)
- [German](https://koha-community.org/manual/25.11/de/html/) (85%)
- [Greek](https://koha-community.org/manual/25.11/el/html/) (91%)
- [Hindi](https://koha-community.org/manual/25.11/hi/html/) (61%)

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
- German (99%)
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
- Slovak (57%)
- Spanish (96%)
- Swedish (88%)
- Telugu (63%)
- Turkish (78%)
- Ukrainian (73%)
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

The release team for Koha 25.11.07 is

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
new features in Koha 25.11.07
<div style="column-count: 2;">

- Athens County Public Libraries
- [Koha-Suomi Oy](https://koha-suomi.fi)
- Lund University Library
</div>

We thank the following individuals who contributed patches to Koha 25.11.07
<div style="column-count: 2;">

- Pedro Amorim (4)
- Tomás Cohen Arazi (1)
- Kevin Carnes (1)
- Nick Clemens (1)
- David Cook (4)
- Jonathan Druart (8)
- Magnus Enger (1)
- Laura Escamilla (7)
- Lucas Gass (1)
- Kyle M Hall (2)
- Jan Kissig (1)
- Owen Leonard (4)
- David Nind (1)
- Sanjar Tulkinov Anvar o'g'li (3)
- Martin Renvoize (8)
- Johanna Räisä (1)
- Emmi Takkinen (1)
- Baptiste Wojtkowski (2)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 25.11.07
<div style="column-count: 2;">

- Athens County Public Libraries (4)
- [BibLibre](https://www.biblibre.com) (2)
- [ByWater Solutions](https://bywatersolutions.com) (11)
- David Nind (1)
- Independant Individuals (4)
- Koha Community Developers (8)
- [Koha-Suomi Oy](https://koha-suomi.fi) (1)
- [Libriotech](https://libriotech.no) (1)
- Lund University Library (1)
- [OpenFifth](https://openfifth.co.uk) (12)
- [Prosentient Systems](https://www.prosentient.com.au) (4)
- [Theke Solutions](https://theke.io) (1)
- Wildau University of Technology (1)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Aleisha Amohia (1)
- Nick Clemens (2)
- David Cook (5)
- Jonathan Druart (7)
- Laura Escamilla (6)
- Andrew Fuerste-Henry (1)
- Lucas Gass (23)
- Jan Kissig (2)
- Brendan Lawlor (2)
- Owen Leonard (2)
- David Nind (9)
- Sanjar Tulkinov Anvar o'g'li (5)
- Eric Phetteplace (1)
- Martin Renvoize (12)
- Phil Ringnalda (1)
- Marcel de Rooy (4)
- Michaela Sieber (1)
- Baptiste Wojtkowski (30)
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

Autogenerated release notes updated last on 06 Aug 2026 14:57:11.
