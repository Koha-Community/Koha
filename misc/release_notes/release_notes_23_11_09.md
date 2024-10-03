# RELEASE NOTES FOR KOHA 23.11.09
03 Oct 2024

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 23.11.09 can be downloaded from:

- [Download](http://download.koha-community.org/koha-23.11.09.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 23.11.09 is a bugfix/maintenance release.

It includes 1 enhancements, 27 bugfixes and 5 security fixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [13342](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13342) Not logged in user can place a review/comment as a deleted patron
- [37654](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37654) XSS in Batch record import for the Citation column

  **Sponsored by** *Chetco Community Public Library*
- [37655](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37655) XSS vulnerability in basic editor handling of title
- [37656](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37656) XSS in Advanced editor for Z39.50 search results

  **Sponsored by** *Chetco Community Public Library*
- [37720](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37720) XSS (and bustage) in label creator

## Bugfixes

### Acquisitions

#### Other bugs fixed

- [37337](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37337) Submitting a similar suggestion results in a blank page
- [37411](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37411) Exporting budget planning gives 500 error

### Architecture, internals, and plumbing

#### Other bugs fixed

- [36362](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36362) Only call Koha::Libraries->search() if necessary in Item::pickup_locations

  **Sponsored by** *Gothenburg University Library*
- [37400](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37400) On checkin don't search for a patron unless needed

### Circulation

#### Other bugs fixed

- [36196](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36196) Handling NULL data in ajax calls for cities
- [37552](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37552) Automatic renewals cronjob can die when an item scheduled for renewal is checked in

### ERM

#### Critical bugs fixed

- [37288](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37288) Edit data provider form does not show the name
  >This fixes the editing form for eUsage data providers (ERM > eUsage > Data providers):
  >- It delays the page display until the information from the counter registry is received. Previously, the data provider name was empty until the data from the registry was received.
  >- It removes the 'Create manually' button when editing a data provider that was created from the registry.

### Fines and fees

#### Other bugs fixed

- [37254](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37254) Dropdown values not cleared after pressing clear in circulation rules

  **Sponsored by** *Koha-Suomi Oy*

### Hold requests

#### Critical bugs fixed

- [29087](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29087) Holds to pull list can crash with a SQL::Abstract puke
  >This fixes the cause of an error (SQL::Abstract::puke():...) that can occur on the holds to pull list (Circulation > Holds > Holds to pull).
- [37351](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37351) Checkboxes on waiting holds report are not kept when switching to another page

### Lists

#### Other bugs fixed

- [37285](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37285) Printing lists only prints the ten first results

### MARC Authority data support

#### Other bugs fixed

- [37226](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37226) Authority hierarchy tree broken when a child (narrower) term appears under more than one parent (greater) term

### OPAC

#### Other bugs fixed

- [36566](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36566) Correct ESLlint errors in OPAC enhanced content JS
  >This fixes various ESLint errors in enhanced content JavaScript files:
  >- Consistent indentation
  >- Remove variables which are declared but not used
  >- Add missing semicolons
  >- Add missing "var" declarations

### Patrons

#### Critical bugs fixed

- [37378](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37378) Patron searches can fail when library groups are set to 'Limit patron data access by group'

#### Other bugs fixed

- [37435](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37435) Cannot renew patron from details page in patron account without circulate permissions

### Point of Sale

#### Other bugs fixed

- [36998](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36998) 'Issue refund' modal on cash register transactions page can mistakenly display amount from previously clicked on transaction

### REST API

#### Other bugs fixed

- [29509](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29509) GET /patrons* routes permissions excessive

### Searching - Elasticsearch

#### Other bugs fixed

- [36879](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36879) Spurious warnings in QueryBuilder
  >This fixes the cause of a warning message in the log files. Changing the sort order for search results in the staff interface (for example, from Relevance to Author (A-Z)) would generate an unnecessary warning message in plack-intranet-error.log: [WARN] Use of uninitialized value $f in hash element at /kohadevbox/koha/Koha/SearchEngine/Elasticsearch/QueryBuilder.pm line 72    5.

### Staff interface

#### Other bugs fixed

- [33453](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33453) Confirmation button for 'Record cashup' should be yellow
  >This fixes the style of the "Confirm" button in the pop-up window when recording a cashup (Tools > Transaction history for > Record cashup). The button was changed from the default button style (with a white background) to the yellow primary action button.
- [33455](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33455) Heading on 'update password' page is too big
  >This fixes the heading for the patron change password page in the staff interface (Patrons > search for a patron > Change password). It was previously part of the form area with the white background, when it should have been above it like other page headings.
- [36129](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36129) Check in "Hide all columns" doesn't persist on item batch modification/deletion
  >This fixes the item batch modification/deletion tool, so that if the "Hide all columns" checkbox is selected and then the page is reloaded, the checkbox is still shown as selected. Before this, the columns remained hidden as expected, but the checkbox wasn't selected.

  **Sponsored by** *Koha-Suomi Oy*
- [37425](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37425) Deletion of bibliographic record can cause search errors

### Templates

#### Other bugs fixed

- [35235](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35235) Mismatched label on notice edit form
- [35236](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35236) Mismatched label on patron card batch edit form
  >This fixes the "Batch description" label when editing a patron card batch (Tools > Patrons and circulation > Patron card creator > Manage > Card batches > Edit). When you click on the batch description label, the input field is now selected and you can enter the batch description. Before this, you had to click in the field to add the description.
- [36885](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36885) Missing tooltip on budget planning page
  >This fixes the "Budget locked" tooltip for budget fund planning pages (Administration > Budgets > select a budget that is locked > Funds > Planning > any planning option). The tooltip was not styled correctly for fund names - it now has white text on a black background.
- [37030](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37030) Use template wrapper for breadcrumbs: Cash register stats

### Test Suite

#### Other bugs fixed

- [37607](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37607) t/cypress/integration/ERM/DataProviders_spec.ts fails

## Enhancements 

### REST API

#### Enhancements

- [36481](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36481) Add GET /libraries/:library_id/cash_registers
  >This enhancement adds an API endpoint for requesting a list of cash registers for a library. For example: http://127.0.0.1:8080/api/v1/libraries/cpl/cash_registers

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Chinese (Traditional)](https://koha-community.org/manual/23.11/zh_Hant/html/) (78%)
- [English](https://koha-community.org/manual/23.11//html/) (100%)
- [English (USA)](https://koha-community.org/manual/23.11/en/html/)
- [French](https://koha-community.org/manual/23.11/fr/html/) (49%)
- [German](https://koha-community.org/manual/23.11/de/html/) (39%)
- [Greek](https://koha-community.org/manual/23.11//html/) (73%)
- [Hindi](https://koha-community.org/manual/23.11/hi/html/) (75%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (99%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified) (90%)
- Chinese (Traditional) (91%)
- Czech (70%)
- Dutch (85%)
- English (100%)
- English (New Zealand) (64%)
- English (USA)
- Finnish (99%)
- French (99%)
- French (Canada) (99%)
- German (100%)
- German (Switzerland) (52%)
- Greek (58%)
- Hindi (99%)
- Italian (84%)
- Norwegian Bokmål (76%)
- Persian (fa_ARAB) (95%)
- Polish (100%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (88%)
- Russian (94%)
- Slovak (62%)
- Spanish (100%)
- Swedish (87%)
- Telugu (70%)
- Turkish (83%)
- Ukrainian (74%)
- hyw_ARMN (generated) (hyw_ARMN) (65%)
</div>

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 23.11.09 is


- Release Manager: Katrin Fischer

- Release Manager assistants:
  - Tomás Cohen Arazi
  - Martin Renvoize
  - Jonathan Druart

- QA Manager: Martin Renvoize

- QA Team:
  - Marcel de Rooy
  - Kyle M Hall
  - Emily Lamancusa
  - Nick Clemens
  - Lucas Gass
  - Tomás Cohen Arazi
  - Julian Maurice
  - Victor Grousset
  - Aleisha Amohia
  - David Cook
  - Laura Escamilla
  - Jonathan Druart
  - Pedro Amorim
  - Matt Blenkinsop
  - Thomas Klausner

- Topic Experts:
  - UI Design -- Owen Leonard
  - Zebra -- Fridolin Somers
  - ERM -- Matt Blenkinsop
  - ILL -- Pedro Amorim
  - SIP2 -- Matthias Meusburger
  - CAS -- Matthias Meusburger

- Bug Wranglers:
  - Aleisha Amohia
  - Jacob O'Mara

- Packaging Managers:
  - Mason James
  - Tomás Cohen Arazi

- Documentation Manager: Philip Orr

- Documentation Team:
  - Aude Charillon
  - Caroline Cyr La Rose
  - Lucy Vaux-Harvey
  - Emmanuel Bétemps
  - Marie-Luce Laflamme
  - Kelly McElligott
  - Rasa Šatinskienė
  - Heather Hernandez

- Wiki curators: 
  - Thomas Dukleth
  - George Williams

- Release Maintainers:
  - 24.05 -- Lucas Gass
  - 23.11 -- Fridolin Somers
  - 23.05 -- Wainui Witika-Park
  - 22.11 -- Fridolin Somers

## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 23.11.09
<div style="column-count: 2;">

- Chetco Community Public Library
- Gothenburg University Library
- [Koha-Suomi Oy](https://koha-suomi.fi)
</div>

We thank the following individuals who contributed patches to Koha 23.11.09
<div style="column-count: 2;">

- Matt Blenkinsop (5)
- Nick Clemens (4)
- Jonathan Druart (2)
- Katrin Fischer (2)
- Eric Garcia (3)
- Lucas Gass (5)
- Thibaud Guillot (1)
- David Gustafsson (1)
- Kyle M Hall (3)
- Andreas Jonsson (1)
- Sam Lau (1)
- Laura_Escamilla (1)
- Owen Leonard (3)
- Vicki McKay (1)
- Martin Renvoize (3)
- Phil Ringnalda (3)
- Andreas Roussos (1)
- Fridolin Somers (2)
- Catalyst Bug Squasher (2)
- Jennifer Sutton (1)
- Emmi Takkinen (2)
- Hammat Wele (1)
- Baptiste Wojtkowski (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 23.11.09
<div style="column-count: 2;">

- Athens County Public Libraries (3)
- [BibLibre](https://www.biblibre.com) (3)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (2)
- [ByWater Solutions](https://bywatersolutions.com) (13)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha) (4)
- Chetco Community Public Library (3)
- [Dataly Tech](https://dataly.gr) (1)
- Göteborgs Universitet (1)
- Independant Individuals (4)
- Koha Community Developers (2)
- [Koha-Suomi Oy](https://koha-suomi.fi) (2)
- Kreablo AB (1)
- laposte.net (1)
- [PTFS Europe](https://ptfs-europe.com) (8)
- [Solutions inLibro inc](https://inlibro.com) (1)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Matt Blenkinsop (2)
- Nick Clemens (1)
- David Cook (6)
- Chris Cormack (1)
- Jake Deery (1)
- Paul Derscheid (1)
- Roman Dolny (5)
- Katrin Fischer (11)
- Lucas Gass (40)
- Victor Grousset (1)
- Kyle M Hall (5)
- Barbara Johnson (1)
- Jan Kissig (1)
- Emily Lamancusa (1)
- Sam Lau (1)
- Laura_Escamilla (1)
- Brendan Lawlor (3)
- Owen Leonard (1)
- Julian Maurice (1)
- David Nind (13)
- Martin Renvoize (31)
- Phil Ringnalda (1)
- Marcel de Rooy (10)
- Fridolin Somers (44)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 23.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 03 Oct 2024 10:12:54.
