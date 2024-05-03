# RELEASE NOTES FOR KOHA 23.11.05
03 May 2024

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 23.11.05 can be downloaded from:

- [Download](http://download.koha-community.org/koha-23.11.05.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 23.11.05 is a bugfix/maintenance release with security fixes.

It includes 4 security bugfixes, 11 bugfixes and 1 enhancement.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [19613](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19613) Scrub borrowers fields: borrowernotes opacnote
- [36149](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36149) userenv stored in plack worker's memory and survive from one request to another
- [36382](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36382) XSS in showLastPatron dropdown
- [36532](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36532) Any authenticated OPAC user can run opac-dismiss-message.pl for any user/any message

## Bugfixes

### Acquisitions

#### Critical bugs fixed

- [36035](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36035) Form is broken in addorderiso2709.pl
- [36053](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36053) Replacement prices not populating when supplied from MarcItemFieldsToOrder

#### Other bugs fixed

- [36036](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36036) Fix location field when ordering from staged files

### Cataloging

#### Critical bugs fixed

- [36511](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36511) Some scripts missing a dependency following Bug 24879

### Circulation

#### Critical bugs fixed

- [35944](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35944) Bookings is not taken into account in CanBookBeRenewed
- [36331](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36331) Items that cannot be held are prevented renewal when there are holds on the record

#### Other bugs fixed

- [36139](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36139) Bug 35518 follow-up: fix AutoSwitchPatron
  >This fixes an issue when the AutoSwitchPatron system preference is enabled (the issue was caused by bug 35518 - added to Koha 24.05.00, 23.11.03, and 23.05.09).
  >
  >If you went to check out an item to a patron, and then entered another patron's card number in the item bar code, it was correctly:
  >- switching to that patron 
  >- showing a message to say that the patron was switched.
  >
  >However, it was also incorrectly showing a "Barcode not found" message - this is now fixed, and is no longer displayed.

### OPAC

#### Critical bugs fixed

- [34886](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34886) Regression in when hold button appears

### Patrons

#### Critical bugs fixed

- [35980](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35980) Add message to patron needs permission check

### Staff interface

#### Critical bugs fixed

- [36447](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36447) Circ rules slow to load when many itemtypes and categories

### Tools

#### Critical bugs fixed

- [36159](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36159) Patron imports record a change for non-text columns that are not in the import file

## Enhancements 

### Architecture, internals, and plumbing

#### Enhancements

- [36328](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36328) C4::Scrubber should allow more HTML tags

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Chinese (Traditional)](https://koha-community.org/manual/23.11//html/) (68%)
- [English](https://koha-community.org/manual/23.11//html/) (100%)
- [English (USA)](https://koha-community.org/manual/23.11/en/html/)
- [French](https://koha-community.org/manual/23.11/fr/html/) (41%)
- [German](https://koha-community.org/manual/23.11/de/html/) (40%)
- [Hindi](https://koha-community.org/manual/23.11/hi/html/) (81%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (89%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Traditional) (91%)
- Czech (69%)
- Dutch (77%)
- English (100%)
- English (New Zealand) (64%)
- English (USA)
- Finnish (99%)
- French (99%)
- French (Canada) (96%)
- German (99%)
- German (Switzerland) (52%)
- Greek (52%)
- Hindi (100%)
- Italian (84%)
- Norwegian Bokmål (76%)
- Persian (fa_ARAB) (92%)
- Polish (98%)
- Portuguese (Brazil) (92%)
- Portuguese (Portugal) (88%)
- Russian (91%)
- Slovak (62%)
- Spanish (100%)
- Swedish (87%)
- Telugu (71%)
- Turkish (80%)
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

The release team for Koha 23.11.05 is


- Release Manager: Katrin Fischer

- Release Manager assistants:
  - Tomás Cohen Arazi
  - Martin Renvoize
  - Jonathan Druart

- QA Manager: Marcel de Rooy

- QA Team:
  - Marcel de Rooy
  - Julian Maurice
  - Lucas Gass
  - Victor Grousset
  - Kyle M Hall
  - Nick Clemens
  - Martin Renvoize
  - Tomás Cohen Arazi
  - Aleisha Amohia
  - Emily Lamancusa
  - David Cook
  - Jonathan Druart
  - Pedor Amorim

- Topic Experts:
  - UI Design -- Owen Leonard
  - Zebra -- Fridolin Somers
  - REST API -- Tomás Cohen Arazi
  - ERM -- Matt Blenkinsop
  - ILL -- Pedro Amorim
  - SIP2 -- Matthias Meusburger
  - CAS -- Matthias Meusburger

- Bug Wranglers:
  - Aleisha Amohia
  - Indranil Das Gupta

- Packaging Managers:
  - Mason James
  - Indranil Das Gupta
  - Tomás Cohen Arazi

- Documentation Manager: Aude Charillon

- Documentation Team:
  - Caroline Cyr La Rose
  - Kelly McElligott
  - Philip Orr
  - Marie-Luce Laflamme
  - Lucy Vaux-Harvey

- Translation Manager: Jonathan Druart


- Wiki curators: 
  - Thomas Dukleth
  - Katrin Fischer

- Release Maintainers:
  - 23.11 -- Fridolin Somers
  - 23.05 -- Lucas Gass
  - 22.11 -- Frédéric Demians
  - 22.05 -- Danyon Sewell

- Release Maintainer assistants:
  - 22.05 -- Wainui Witika-Park

## Credits



We thank the following individuals who contributed patches to Koha 23.11.05
<div style="column-count: 2;">

- Pedro Amorim (2)
- Matt Blenkinsop (1)
- Nick Clemens (9)
- Jonathan Druart (7)
- Michael Hafen (1)
- Kyle M Hall (7)
- Brendan Lawlor (3)
- Owen Leonard (2)
- Julian Maurice (1)
- Martin Renvoize (4)
- Marcel de Rooy (1)
- Fridolin Somers (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 23.11.05
<div style="column-count: 2;">

- Athens County Public Libraries (2)
- BibLibre (2)
- ByWater-Solutions (16)
- clamsnet.org (3)
- Independant Individuals (1)
- Koha Community Developers (7)
- PTFS-Europe (7)
- Rijksmuseum (1)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Tomás Cohen Arazi (1)
- Matt Blenkinsop (1)
- Nick Clemens (6)
- David Cook (6)
- danyonsewell (1)
- Jonathan Druart (1)
- Esther (2)
- Katrin Fischer (26)
- Lucas Gass (1)
- Kyle M Hall (3)
- Andrew Fuerste Henry (1)
- Barbara Johnson (1)
- Brendan Lawlor (2)
- Owen Leonard (3)
- Julian Maurice (3)
- David Nind (5)
- Marcel de Rooy (11)
- Fridolin Somers (36)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 23.11.x-security.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 03 May 2024 13:10:30.
