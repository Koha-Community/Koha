# RELEASE NOTES FOR KOHA 23.11.14
24 Apr 2025

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 23.11.14 can be downloaded from:

- [Download](https://download.koha-community.org/koha-23.11.14.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 23.11.14 is a bugfix/maintenance release.

It includes 3 bugfixes and 2 security fixes.

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

### Architecture, internals, and plumbing

#### Other bugs fixed

- [38653](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38653) Obsolete call on system preference 'OPACLocalCoverImagesPriority'
  >This fixes the OPAC search results page by removing a call to system preference OPACLocalCoverImagesPriority - this system preference no longer exists. (There is no visible difference to the OPAC search results page.)

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

- [Armenian (hy_ARMN)](https://koha-community.org/manual/23.11//html/) (100%)
- [Chinese (Traditional)](https://koha-community.org/manual/23.11/zh_Hant/html/) (99%)
- [English](https://koha-community.org/manual/23.11//html/) (100%)
- [English (USA)](https://koha-community.org/manual/23.11/en/html/)
- [French](https://koha-community.org/manual/23.11/fr/html/) (71%)
- [German](https://koha-community.org/manual/23.11/de/html/) (99%)
- [Greek](https://koha-community.org/manual/23.11//html/) (96%)
- [Hindi](https://koha-community.org/manual/23.11/hi/html/) (71%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (99%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified) (89%)
- Chinese (Traditional) (99%)
- Czech (70%)
- Dutch (88%)
- English (100%)
- English (New Zealand) (64%)
- English (USA)
- Finnish (99%)
- French (99%)
- French (Canada) (99%)
- German (100%)
- German (Switzerland) (52%)
- Greek (69%)
- Hindi (99%)
- Italian (84%)
- Norwegian Bokmål (76%)
- Persian (fa_ARAB) (98%)
- Polish (100%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (88%)
- Russian (96%)
- Slovak (63%)
- Spanish (100%)
- Swedish (87%)
- Telugu (70%)
- Tetum (53%)
- Turkish (86%)
- Ukrainian (75%)
- hyw_ARMN (generated) (hyw_ARMN) (65%)
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

The release team for Koha 23.11.14 is


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
new features in Koha 23.11.14
<div style="column-count: 2;">

- Chetco Community Public Library
</div>

We thank the following individuals who contributed patches to Koha 23.11.14
<div style="column-count: 2;">

- Matt Blenkinsop (1)
- Nick Clemens (2)
- Roman Dolny (1)
- Jonathan Druart (1)
- Phil Ringnalda (1)
- Fridolin Somers (2)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 23.11.14
<div style="column-count: 2;">

- [BibLibre](https://www.biblibre.com) (2)
- [ByWater Solutions](https://bywatersolutions.com) (2)
- Chetco Community Public Library (1)
- jezuici.pl (1)
- Koha Community Developers (1)
- [PTFS Europe](https://ptfs-europe.com) (1)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- David Cook (1)
- Paul Derscheid (4)
- Katrin Fischer (4)
- Victor Grousset (1)
- Owen Leonard (3)
- David Nind (1)
- Martin Renvoize (4)
- Marcel de Rooy (1)
- Fridolin Somers (6)
- wainuiwitikapark (7)
- Baptiste Wojtkowski (1)
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

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 24 Apr 2025 12:24:46.
