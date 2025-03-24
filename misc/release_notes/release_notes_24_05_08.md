# RELEASE NOTES FOR KOHA 24.05.08
24 Mar 2025

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 24.05.08 can be downloaded from:

- [Download](https://download.koha-community.org/koha-24.05.08.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 24.05.08 is a bugfix/maintenance release.

It includes 2 enhancements, 14 bugfixes and 2 security fixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [31165](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31165) "Public note" field in course reserve should restrict HTML usage
- [37784](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37784) Patron password hash can be fetched using report dictionary

  **Sponsored by** *Reserve Bank of New Zealand*

## Bugfixes

### Authentication

#### Critical bugs fixed

- [38826](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38826) C4::Auth::check_api_auth sometimes returns $session and sometimes returns $sessionID
  >This fixes authentication checking so that the $sessionID is consistently returned (sometimes it was returning the session object). (Note: $sessionID is returned on a successful login, while $session is returned when there is a cookie for an authenticated session.)

### Circulation

#### Other bugs fixed

- [38246](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38246) If using automatic return claim resolution on checkout, each checkout will overwrite the previous resolution

### Command-line Utilities

#### Other bugs fixed

- [38382](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38382) Need a fresh connection when CSRF has expired for connexion daemon
  >This fixes the OCLC Connexion import daemon (misc/bin/connexion_import_daemon.pl) - the connection was failing after the CSRF token expired (after 8 hours). It now generates a new user agent when reauthenticating when the CSRF token for the session has expired. (This is related to the CSRF changes added in Koha 24.05 to improve form security.)

### I18N/L10N

#### Other bugs fixed

- [38707](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38707) Patron restriction types from installer files not translatable
  >This fixes installer files so that the default patron restriction types are now translatable.

### Installation and upgrade (command-line installer)

#### Critical bugs fixed

- [38750](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38750) Installer process not terminating when nothing to do
  >This fixes the installation process - instead of getting "Try again" when there is nothing left to do (after updating the database structure) and not being able to finish, you now get "Everything went okay. Update done."

### MARC Bibliographic data support

#### Critical bugs fixed

- [32722](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32722) UNIMARC: Remove mandatory flag from some subfields and field in default bibliographic framework
  >This updates the default UNIMARC bibliographic record framework to remove the mandatory flag from some subfields and fields. 
  >
  >For UNIMARC, several subfields are only mandatory if the field is actually used (MARC21 does not have this requirement). 
  >
  >A change made to the default framework by bug 30373 in Koha 22.05 meant that if the mandatory subfield was empty, and the field itself was optional (not mandatory), you couldn't save the record.
  >
  >For example, if field 410 (Series) is used (this is an optional field), then subfield $t (Title) is required. However, the way the default framework was set up (subfield $t was marked as mandatory) you couldn't save the record - as subfield $t was mandatory, even though the 410 is optional.
  >
  >As Koha is not currently able to manage both the UNIMARC and MARC21 requirements without significant changes, a practical decision was made to configure the otherwise mandatory subfields as not mandatory. 
  >
  >Important note: This only affects NEW UNIMARC installations. Existing installations should edit their default UNIMARC framework to make these changes (although, it is likely that they have already done so).

### Packaging

#### Other bugs fixed

- [33018](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33018) Debian package tidy-up
  >This removes unneeded Debian package dependencies. Previously we provided them in the Koha Debian repository, but we no longer need to as they are now available in the standard repositories.

### REST API

#### Other bugs fixed

- [38678](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38678) GET /deleted/biblios cannot be filtered on `deleted_on`

### SIP2

#### Other bugs fixed

- [38486](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38486) No block checkouts are still blocked by fines, checkouts, and blocked item types
  >This fixes SIP so that it allows noblock checkouts, regardless of normal patron checkout blocks.
  >
  >Explanation: The purpose of no block checkouts in SIP is to indicate that the SIP machine has made an offline ("store and forward") transaction. The patron already has the item. As such, the item must be checked out to the patron or the library risks losing the item due to lack of tracking. As such, no block checkouts should not be blocked under any circumstances.

### Tools

#### Critical bugs fixed

- [31450](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31450) HTML customizations and news will not display on OPAC without a publication date
  >This fixes the display of news, HTML customizations, and pages on the OPAC - a publication date is now required for all types of additional content. Previously, news items and HTML customizations were not shown if they didn't have a publication date (this behavour was not obvious from the forms).

  **Sponsored by** *Athens County Public Libraries*

#### Other bugs fixed

- [38452](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38452) Inventory tool barcodes should not be case sensitive
  >This fixes the inventory tool so that it ignores case sensitivity for barcodes, similar to other areas of Koha such as checking in and checking out items (for example, ABC123 and abc123 are treated the same).
- [38531](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38531) Include action_logs.diff when reverting hold
  >This fixes the holds log so that the diff now includes the changes when reverting a hold. (This was missed when the diff in JSON format feature was added to Koha 24.05 by bug 25159.).

## Enhancements 

### Architecture, internals, and plumbing

#### Enhancements

- [36662](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36662) ILL - t/db_dependent/Illrequest should not exist
  >This enhancement moves the ILL test files to the correct folder structure - t/db_dependent/Koha/ILL/.
- [38483](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38483) C4::Heading::preferred_authorities is not used
  >This removes an unused method 'preferred_authorities' (Return a list of authority records for headings that are a preferred form of the heading).

  **Sponsored by** *Ignatianum University in Cracow*

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Armenian (hy_ARMN)](https://koha-community.org/manual/24.05//html/) (100%)
- [Chinese (Traditional)](https://koha-community.org/manual/24.05/zh_Hant/html/) (99%)
- [English](https://koha-community.org/manual/24.05//html/) (100%)
- [English (USA)](https://koha-community.org/manual/24.05/en/html/)
- [French](https://koha-community.org/manual/24.05/fr/html/) (63%)
- [German](https://koha-community.org/manual/24.05/de/html/) (99%)
- [Greek](https://koha-community.org/manual/24.05//html/) (97%)
- [Hindi](https://koha-community.org/manual/24.05/hi/html/) (71%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<!--<div style="column-count: 2;">-->

- Arabic (ar_ARAB) (97%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified) (88%)
- Chinese (Traditional) (99%)
- Czech (68%)
- Dutch (88%)
- English (100%)
- English (New Zealand) (63%)
- English (USA)
- Finnish (99%)
- French (100%)
- French (Canada) (99%)
- German (100%)
- Greek (68%)
- Hindi (99%)
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
- Ukrainian (73%)
- hyw_ARMN (generated) (hyw_ARMN) (63%)
<!--</div>-->

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](https://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](https://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](https://translate.koha-community.org/)

## Release Team

The release team for Koha 24.05.08 is


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
new features in Koha 24.05.08
<!--<div style="column-count: 2;">-->

- Athens County Public Libraries
- Ignatianum University in Cracow
- Reserve Bank of New Zealand
<!--</div>-->

We thank the following individuals who contributed patches to Koha 24.05.08
<!--<div style="column-count: 2;">-->

- Aleisha Amohia (1)
- Pedro Amorim (1)
- Tomás Cohen Arazi (2)
- Alex Buckley (2)
- Nick Clemens (1)
- David Cook (2)
- Jonathan Druart (1)
- Lucas Gass (1)
- Kyle M Hall (2)
- Andrew Fuerste Henry (1)
- Mason James (2)
- Janusz Kaczmarek (1)
- Emily Lamancusa (1)
- Owen Leonard (1)
- Marcel de Rooy (2)
- Caroline Cyr La Rose (1)
- Mathieu Saby (1)
<!--</div>-->

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 24.05.08
<!--<div style="column-count: 2;">-->

- Athens County Public Libraries (1)
- [ByWater Solutions](https://bywatersolutions.com) (5)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha) (2)
- Catalyst Open Source Academy (1)
- Independant Individuals (2)
- Koha Community Developers (1)
- KohaAloha (2)
- [Montgomery County Public Libraries](montgomerycountymd.gov) (1)
- [Prosentient Systems](https://www.prosentient.com.au) (2)
- [PTFS Europe](https://ptfs-europe.com) (1)
- Rijksmuseum, Netherlands (2)
- [Solutions inLibro inc](https://inlibro.com) (1)
- [Theke Solutions](https://theke.io) (2)
<!--</div>-->

We also especially thank the following individuals who tested patches
for Koha
<!--<div style="column-count: 2;">-->

- Matt Blenkinsop (2)
- Alex Buckley (21)
- Nick Clemens (1)
- David Cook (3)
- Paul Derscheid (14)
- Magnus Enger (1)
- Katrin Fischer (14)
- Victor Grousset (1)
- Jan Kissig (1)
- Emily Lamancusa (2)
- Brendan Lawlor (3)
- David Nind (7)
- Martin Renvoize (9)
- Phil Ringnalda (2)
- Marcel de Rooy (5)
- Sam Sowanick (1)
<!--</div>-->





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

Autogenerated release notes updated last on 24 Mar 2025 08:05:00.
