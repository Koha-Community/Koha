# RELEASE NOTES FOR KOHA 23.11.08
13 Aug 2024

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 23.11.08 can be downloaded from:

- [Download](http://download.koha-community.org/koha-23.11.08.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 23.11.08 is a bugfix/maintenance release.

It includes 2 enhancements, 3 bugfixes, and 6 security fixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).

#### Security bugs

- [37370](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37370) opac-export.pl can be used even if exporting disabled 
- [37508](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37508) SQL reports should not show patron password hash if queried
- [37466](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37466) Reflected Cross Site Scripting
- [37464](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37464) Remote Code Execution in barcode function leads to reverse shell
- [37488](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37488) Filepaths not validated in ZIP upload to picture-upload.pl 
- [37323](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37323) Remote-Code-Execution (RCE) in picture-upload.pl

## Bugfixes

### Acquisitions

#### Critical bugs fixed

- [37533](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37533) Invalid query when receiving an order

#### Other bugs fixed

- [36187](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36187) Cannot set suggestedby when adding/editing a suggestion from the staff interface

### Fines and fees

#### Critical bugs fixed

- [37255](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37255) Creating default waiting hold cancellation policy for all patron categories and itemtypes breaks Koha

  **Sponsored by** *Koha-Suomi Oy*

## Enhancements 

### Acquisitions

#### Enhancements

- [10758](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10758) Show bibliographic information of deleted records in acquisition baskets
  >This makes the title of a deleted bibliographic record visible in the basket summary page. Please note that this will only work on records, where the biblionumber of the deleted record has been stored. - A feature that was introduced with Koha 23.05.

### REST API

#### Enhancements

- [36480](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36480) Add GET /libraries/:library_id/desks
  >This enhancement adds an API endpoint for requesting a list of desks for a library. For example: http://127.0.0.1:8080/api/v1/libraries/cpl/desks

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Chinese (Traditional)](https://koha-community.org/manual/23.11/zh_Hant/html/) (75%)
- [English](https://koha-community.org/manual/23.11//html/) (100%)
- [English (USA)](https://koha-community.org/manual/23.11/en/html/)
- [French](https://koha-community.org/manual/23.11/fr/html/) (47%)
- [German](https://koha-community.org/manual/23.11/de/html/) (37%)
- [Greek](https://koha-community.org/manual/23.11//html/) (48%)
- [Hindi](https://koha-community.org/manual/23.11/hi/html/) (76%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (99%)
- Armenian (hy_ARMN) (99%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Traditional) (91%)
- Czech (70%)
- Dutch (78%)
- English (100%)
- English (New Zealand) (64%)
- English (USA)
- Finnish (99%)
- French (99%)
- French (Canada) (97%)
- German (99%)
- German (Switzerland) (52%)
- Greek (58%)
- Hindi (99%)
- Italian (84%)
- Norwegian Bokmål (76%)
- Persian (fa_ARAB) (95%)
- Polish (99%)
- Portuguese (Brazil) (96%)
- Portuguese (Portugal) (88%)
- Russian (93%)
- Slovak (61%)
- Spanish (99%)
- Swedish (87%)
- Telugu (70%)
- Turkish (82%)
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

The release team for Koha 23.11.08 is


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
new features in Koha 23.11.08
<div style="column-count: 2;">

- [Koha-Suomi Oy](https://koha-suomi.fi)
- Reserve Bank of New Zealand
</div>

We thank the following individuals who contributed patches to Koha 23.11.08
<div style="column-count: 2;">

- Aleisha Amohia (3)
- Tomás Cohen Arazi (3)
- Nick Clemens (1)
- David Cook (5)
- Chris Cormack (1)
- Lucas Gass (1)
- Amit Gupta (1)
- Andreas Jonsson (1)
- Martin Renvoize (1)
- Marcel de Rooy (3)
- Emmi Takkinen (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 23.11.08
<div style="column-count: 2;">

- BigBallOfWax (1)
- [ByWater Solutions](https://bywatersolutions.com) (2)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha) (2)
- Catalyst Open Source Academy (1)
- Informatics Publishing Ltd (1)
- [Koha-Suomi Oy](https://koha-suomi.fi) (1)
- Kreablo AB (1)
- [Prosentient Systems](https://www.prosentient.com.au) (5)
- [PTFS Europe](https://ptfs-europe.com) (1)
- Rijksmuseum, Netherlands (3)
- [Theke Solutions](https://theke.io) (3)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Aleisha Amohia (3)
- Pedro Amorim (1)
- Tomás Cohen Arazi (15)
- Nick Clemens (5)
- David Cook (6)
- Chris Cormack (2)
- Katrin Fischer (2)
- Andrew Fuerste-Henry (1)
- Lucas Gass (1)
- Victor Grousset (3)
- Amit Gupta (1)
- Emily Lamancusa (1)
- Marcel de Rooy (6)
- Michaela Sieber (1)
- Fridolin Somers (3)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is (HEAD detached at security-23.11.x-security).

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 13 Aug 2024 14:55:09.
