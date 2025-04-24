# RELEASE NOTES FOR KOHA 24.05.09
24 Apr 2025

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 24.05.09 can be downloaded from:

- [Download](https://download.koha-community.org/koha-24.05.09.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 24.05.09 is a bugfix/maintenance release.

It includes 8 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [36867](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36867) ILS-DI AuthorizedIPs should deny explicitly except those listed
  >This patch updates the ILS-DI authorized IPs preference to deny all IPs not listed in the preference.
  >
  >Previously if no text was entered the ILS-DI service was accessible by all IPs, now it requires explicitly defining the IPs that can access the service.
  >
  >Upgrading libraries using ILS-DI should check that they have the necessary IPs defined in the system preference.
- [38969](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38969) Reflected XSS vulnerability in tags

## Bugfixes

### Acquisitions

#### Other bugs fixed

- [38155](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38155) Can't close invoices using checkboxes from invoices.pl
  >This fixes closing and reopening of invoices (Acquisitions > [Vendor] > Invoices). Previously, the invoices you selected weren't closed or reopened when clicking on the "Close/Reopen selected invoices" button - all that happened was that one of the selected invoices was displayed instead. (This is related to the CSRF changes added in Koha 24.05 to improve form security.)

### Architecture, internals, and plumbing

#### Other bugs fixed

- [38653](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38653) Obsolete call on system preference 'OPACLocalCoverImagesPriority'
  >This fixes the OPAC search results page by removing a call to system preference OPACLocalCoverImagesPriority - this system preference no longer exists. (There is no visible difference to the OPAC search results page.)

### Circulation

#### Other bugs fixed

- [38512](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38512) Item table status column display is wrong when record has recalls
  >This fixes the display of recalls in the holdings table - the "Recalled by [patron] on [date]" message now only shows for item-level recalls. Previously, the message was displayed for all items when a record-level recall was made.

### ERM

#### Other bugs fixed

- [38782](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38782) ERM eUsage related tests are failing
  >This fixes failing ERM usage tests.

### Patrons

#### Other bugs fixed

- [38772](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38772) Typo 'minPasswordPreference' system preference
  >This fixes a typo in the code for OPAC password recovery - 'minPasswordPreference' to 'minPasswordLength' (the correct system preference name). It has no noticeable effect on resetting an account password from the OPAC.

### Templates

#### Critical bugs fixed

- [38268](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38268) Callers of confirmModal need to remove the modal as the first step in their callback function
  >This fixes confirm dialog boxes in the OPAC to prevent unintended actions being taken, such as accidentally deleting a list. This specifically fixes lists, and makes a technical change to prevent this happening in the future for other areas of the OPAC (such as suggestions, tags, and self-checkout).
  >
  >Example of issue fixed for lists: 
  >1. Create a list with several items.
  >2. From the new list, select a couple of the items.
  >3. Click "Delete list" and then select "No, do not delete".
  >4. Then select "Remove from list", and confirm by clicking "Yes, remove from list".
  >5. Result: Instead of removing the items selected, the whole list was incorrectly deleted!

  **Sponsored by** *Chetco Community Public Library*

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Armenian (hy_ARMN)](https://koha-community.org/manual/24.05//html/) (100%)
- [Chinese (Traditional)](https://koha-community.org/manual/24.05/zh_Hant/html/) (99%)
- [English](https://koha-community.org/manual/24.05//html/) (100%)
- [English (USA)](https://koha-community.org/manual/24.05/en/html/)
- [French](https://koha-community.org/manual/24.05/fr/html/) (71%)
- [German](https://koha-community.org/manual/24.05/de/html/) (99%)
- [Greek](https://koha-community.org/manual/24.05//html/) (96%)
- [Hindi](https://koha-community.org/manual/24.05/hi/html/) (71%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (97%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified) (88%)
- Chinese (Traditional) (99%)
- Czech (68%)
- Dutch (88%)
- English (100%)
- English (New Zealand) (62%)
- English (USA)
- Finnish (99%)
- French (99%)
- French (Canada) (99%)
- German (99%)
- Greek (68%)
- Hindi (98%)
- Italian (82%)
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

The release team for Koha 24.05.09 is

- Release Manager: Katrin Fischer

- Release Manager assistants:
  - Tomás Cohen Arazi
  - Martin Renvoize
  - Jonathan Druart

- QA Manager: Martin Renvoize

- QA Team:
  - Victor Grousset
  - Lisette Scheer
  - Emily Lamancusa
  - David Cook
  - Jonathan Druart
  - Julian Maurice
  - Baptiste Wojtowski
  - Paul Derscheid
  - Aleisha Amohia
  - Laura Escamilla
  - Tomás Cohen Arazi
  - Kyle M Hall
  - Nick Clemens
  - Lucas Gass
  - Marcel de Rooy
  - Matt Blenkinsop
  - Pedro Amorim
  - Brendan Lawlor
  - Thomas Klausner

- Security Manager: Tomás Cohen Arazi

- Topic Experts:
  - UI Design -- Owen Leonard
  - REST API -- Tomás Cohen Arazi
  - Zebra -- Fridolin Somers

- Bug Wranglers:
  - Michaela Sieber
  - Jacob O'Mara
  - Jake Deery

- Packaging Manager: Mason James

- Documentation Manager: Philip Orr

- Documentation Team:
  - Aude Charillon
  - David Nind
  - Caroline Cyr La Rose

- Wiki curators: 
  - George Williams
  - Thomas Dukleth
  - Jonathan Druart
  - Martin Renvoize

- Release Maintainers:
  - 24.11 -- Paul Derscheid
  - 24.05 -- Wainui Witika-Park
  - 23.11 -- Fridolin Somers
  - 22.11 -- Laura Escamilla

## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 24.05.09
<div style="column-count: 2;">

- Chetco Community Public Library
</div>

We thank the following individuals who contributed patches to Koha 24.05.09
<div style="column-count: 2;">

- Pedro Amorim (4)
- Matt Blenkinsop (1)
- Nick Clemens (2)
- Roman Dolny (1)
- Jonathan Druart (1)
- Lucas Gass (1)
- Emily Lamancusa (1)
- Brendan Lawlor (2)
- Phil Ringnalda (1)
- Fridolin Somers (1)
- Wainui Witika-Park (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 24.05.09
<div style="column-count: 2;">

- [BibLibre](https://www.biblibre.com) (1)
- [ByWater Solutions](https://bywatersolutions.com) (3)
- [Cape Libraries Automated Materials Sharing](https://info.clamsnet.org) (2)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha) (1)
- Chetco Community Public Library (1)
- jezuici.pl (1)
- Koha Community Developers (1)
- [Montgomery County Public Libraries](montgomerycountymd.gov) (1)
- [PTFS Europe](https://ptfs-europe.com) (5)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Tomás Cohen Arazi (3)
- David Cook (1)
- Paul Derscheid (12)
- Katrin Fischer (12)
- Victor Grousset (1)
- Andrew Fuerste Henry (2)
- Emily Lamancusa (2)
- Owen Leonard (3)
- David Nind (1)
- Martin Renvoize (5)
- Marcel de Rooy (1)
- Emmi Takkinen (1)
- wainuiwitikapark (15)
- Baptiste Wojtkowski (1)
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

Autogenerated release notes updated last on 24 Apr 2025 05:00:21.
