# RELEASE NOTES FOR KOHA 24.11.05
26 May 2025

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 24.11.05 can be downloaded from:

- [Download](https://download.koha-community.org/koha-24.11.05.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 24.11.05 is a bugfix/maintenance and security release.

It includes 5 enhancements, 21 bugfixes, one of which is a security fix.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [39184](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39184) Server-side template injection leading to remote code execution

## Bugfixes

### Acquisitions

#### Other bugs fixed

- [39620](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39620) Price not populating from 020$c when creating a basket
  >This patch fixes an error in Koha/MarcOrder.pm where price was not correctly defaulting to the 020$c if it exists.

### Architecture, internals, and plumbing

#### Critical bugs fixed

- [37020](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37020) bulkmarcimport gets killed when inserting large files

### Cataloging

#### Other bugs fixed

- [39633](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39633) Inventory tool DataTable doesn't properly load

### Circulation

#### Other bugs fixed

- [39361](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39361) Hold found modal does not display from circulation / transfer
- [39414](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39414) Item type not retained when editing a booking
- [39588](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39588) Bookings to collect report won't load when the search returns currently checked out bookings

### Hold requests

#### Other bugs fixed

- [38650](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38650) We should only fill title level or specific item holds when a patron checks out an item

### MARC Authority data support

#### Other bugs fixed

- [39415](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39415) Add subfield g to Geographic name authority fields

### OPAC

#### Critical bugs fixed

- [39857](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39857) OAI expanded_avs option broken

#### Other bugs fixed

- [39276](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39276) OPACShowHoldQueueDetails datatable warning

### Patrons

#### Other bugs fixed

- [38395](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38395) Title is not displayed in hold history when bibliographic record is deleted
- [39644](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39644) Too many borrower_relationships causes patron page to not load
- [39710](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39710) Cannot load holds history if there are deleted biblios

### Self checkout

#### Other bugs fixed

- [36586](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36586) Self-checkouts will get CSRF errors if left inactive for 8 hours
- [38641](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38641) Javascript error generated in SCI if item not checked out

### Serials

#### Other bugs fixed

- [35202](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35202) Table settings should apply to multiple subscriptions in the OPAC
  >This fixes the display of columns shown for the subscription detail tables in the OPAC, where there are multiple subscriptions for a record. Any changes to the columns were only applied to the first subscription, for all the other subscriptions all the columns were shown (including columns that should have been hidden). (Columns for the subscription tables for the OPAC record details are configured under Administration > Additional parameters > Table settings > OPAC > subscriptionst.)

  **Sponsored by** *Athens County Public Libraries*
- [39406](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39406) Issues on serial collection page sort from old to new now
  >This fixes the serial collection table so that issues now sort in descending order based on the date published column (the latest issue at the top).

  **Sponsored by** *Pymble Ladies' College*
- [39915](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39915) Late issues export exports empty rows in CSV

### Staff interface

#### Other bugs fixed

- [36867](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36867) ILS-DI AuthorizedIPs should deny explicitly except those listed
  >This patch updates the ILS-DI authorized IPs preference to deny all IPs not listed in the preference.
  >
  >Previously if no text was entered the ILS-DI service was accessible by all IPs, now it requires explicitly defining the IPs that can access the service.
  >
  >Upgrading libraries using ILS-DI should check that they have the necessary IPs defined in the system preference.

### Templates

#### Other bugs fixed

- [39464](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39464) Z39.50 Search results not highlighting grey rows in yellow when previewing

## Enhancements 

### Hold requests

#### Enhancements

- [17338](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17338) 'Holds awaiting pickup' should keep you on the same tab when cancelling a hold
  >When cancelling hold requests that haven't been picked up, it would jump back to the first tab after saving. Now Koha will display the correct tab after saving.
- [35560](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35560) Use the REST API for holds history
  >This enhancement to a patron's hold history section in the staff interface:
  >- Uses the REST API to generate the holds history page.
  >- Separates the holds history into two tables: "Current holds" and "Past holds".
  >- Adds filters for each table, such as Show all, Pending, Waiting, Fulfilled.

### Templates

#### Enhancements

- [38714](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38714) Adjust templates for prettier
- [39886](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39886) [24.11] Identifier typed as Identifierr

### Test Suite

#### Enhancements

- [38461](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38461) Table features needs to be covered by e2e tests using Cypress

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Chinese (Traditional)](https://koha-community.org/manual/24.11/zh_Hant/html/) (98%)
- [English (USA)](https://koha-community.org/manual/24.11/en/html/)
- [French](https://koha-community.org/manual/24.11/fr/html/) (72%)
- [German](https://koha-community.org/manual/24.11/de/html/) (98%)
- [Greek](https://koha-community.org/manual/24.11/el/html/) (96%)
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
- Chinese (Simplified) (86%)
- Chinese (Traditional) (99%)
- Czech (67%)
- Dutch (88%)
- English (100%)
- English (New Zealand) (63%)
- English (USA)
- Finnish (100%)
- French (99%)
- French (Canada) (98%)
- German (100%)
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
- Telugu (67%)
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

The release team for Koha 24.11.05 is


- Release Manager: Katrin Fischer

- Release Manager assistants:
  - Tomás Cohen Arazi
  - Martin Renvoize
  - Jonathan Druart

- QA Manager: Martin Renvoize

- QA Team:
  - Martin Renvoize
  - Marcel de Rooy
  - Jonathan Druart
  - Lucas Gass
  - Nick Clemens
  - Baptiste Wojtkowski
  - Emily Lamancusa
  - Matt Blenkinsop
  - Tomás Cohen Arazi
  - Lisette Scheer
  - David Cook
  - Paul Derscheid
  - Pedro Amorim
  - Thomas Klausner
  - Brendan Lawlor
  - Julian Maurice
  - Kyle M Hall
  - Victor Grousset
  - Owen Leonard
  - Wainui Witika-Park
  - Laura Escamilla
  - Magnus Enger
  - David Nind

- Topic Experts:
  - UI Design -- Owen Leonard
  - Zebra -- Fridolin Somers
  - REST API -- Tomás Cohen Arazi

- Bug Wranglers:
  - Michaela Sieber
  - Jacob O'Mara
  - Jake Deery

- Packaging Manager: Mason James

- Documentation Manager: Philip Orr

- Documentation Team:
  - Aude Charillon
  - Caroline Cyr la Rose
  - David Nind

- Wiki curators: 
  - Thomas Dukleth
  - George Williams
  - Jonathan Druart

- Release Maintainers:
  - 24.11 -- Paul Derscheid
  - 24.05 -- Catalyst (Wainui Witika-Park, Alex Buckley, Aleisha Amoha)
  - 23.11 -- Fridolin Somers
  - 22.11 -- Jesse Maseto

## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 24.11.05
<!-- <div style="column-count: 2;"> -->

- Athens County Public Libraries
- Pymble Ladies' College
<!-- </div> -->

We thank the following individuals who contributed patches to Koha 24.11.05
<!-- <div style="column-count: 2;"> -->

- Aleisha Amohia (1)
- Tomás Cohen Arazi (2)
- Matt Blenkinsop (1)
- Nick Clemens (10)
- David Cook (2)
- Paul Derscheid (3)
- Jonathan Druart (4)
- Lucas Gass (8)
- David Gustafsson (1)
- Thomas Klausner (2)
- Owen Leonard (4)
- Phil Ringnalda (1)
<!-- </div> -->

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 24.11.05
<!-- <div style="column-count: 2;"> -->

- Athens County Public Libraries (4)
- [ByWater Solutions](https://bywatersolutions.com) (18)
- Catalyst Open Source Academy (1)
- Chetco Community Public Library (1)
- Gothenburg University Library (1)
- Independant Individuals (2)
- Koha Community Developers (4)
- [LMSCloud](lmscloud.de) (3)
- [Open Fifth](https://openfifth.co.uk/) (1)
- [Prosentient Systems](https://www.prosentient.com.au) (2)
- [Theke Solutions](https://theke.io) (2)
<!-- </div> -->

We also especially thank the following individuals who tested patches
for Koha
<!-- <div style="column-count: 2;"> -->

- Pedro Amorim (2)
- Tomás Cohen Arazi (1)
- Andrew Auld (1)
- Matt Blenkinsop (6)
- Nick Clemens (1)
- Ray Delahunty (1)
- Paul Derscheid (23)
- Roman Dolny (6)
- Jonathan Druart (1)
- Magnus Enger (2)
- Katrin Fischer (33)
- Lucas Gass (5)
- Andrew Fuerste Henry (1)
- Jan Kissig (2)
- Thomas Klausner (1)
- Kristi Krueger (1)
- Brendan Lawlor (1)
- Owen Leonard (3)
- David Nind (11)
- Stephanie Petruso (2)
- Martin Renvoize (9)
- Phil Ringnalda (2)
- Marcel de Rooy (3)
- Caroline Cyr La Rose (1)
- Sam (1)
- Baptiste Wojtkowski (5)
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

Autogenerated release notes updated last on 26 May 2025 18:55:30.
