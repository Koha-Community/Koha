# RELEASE NOTES FOR KOHA 22.11.26
24 Apr 2025

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 22.11.26 can be downloaded from:

- [Download](https://download.koha-community.org/koha-22.11.26.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 22.11.26 is a bugfix/maintenance release.

It includes 17 bugfixes.

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

- [36049](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36049) Rounding prices sometimes leads to incorrect results
  >This fixes the values and totals shown for orders when rounding prices using the OrderPriceRounding system preference. Example: vendor price for an item is 18.90 and the discount is 5%, the total would show as 17.95 instead of 17.96.

  **Sponsored by** *Karlsruhe Institute of Technology (KIT)*

### Architecture, internals, and plumbing

#### Critical bugs fixed

- [38035](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38035) "sound" listed as an installed language

### Authentication

#### Critical bugs fixed

- [38826](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38826) C4::Auth::check_api_auth sometimes returns $session and sometimes returns $sessionID
  >This fixes authentication checking so that the $sessionID is consistently returned (sometimes it was returning the session object). (Note: $sessionID is returned on a successful login, while $session is returned when there is a cookie for an authenticated session.)

### Cataloging

#### Critical bugs fixed

- [37655](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37655) XSS vulnerability in basic editor handling of title
- [37656](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37656) XSS in Advanced editor for Z39.50 search results

  **Sponsored by** *Chetco Community Public Library*

#### Other bugs fixed

- [35441](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35441) Typo 'UniqueItemsFields' system preference

### Circulation

#### Other bugs fixed

- [37983](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37983) "Search a patron" box no longer has auto focus

### Holidays

#### Critical bugs fixed

- [38357](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38357) When adding new holidays Koha sometimes copies same holidays to other librarys

### Label/patron card printing

#### Critical bugs fixed

- [37720](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37720) XSS (and bustage) in label creator

### Patrons

#### Other bugs fixed

- [34610](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34610) ProtectSuperlibrarianPrivileges, not ProtectSuperlibrarian
  >This fixes the hover message when attempting to grant the `superlibrarian` permission (Access to all librarian functions) to a patron. It changes the message to use the correct system preference name "The system preference ProtectSuperlibrarianPrivileges is enabled", instead of "..ProtectSuperlibrarian...". 
  >
  >(The message appears over the tick box next to the permission name if the patron attempting to set the permissions is not a super librarian, and the ProtectSuperlibrarianPrivileges is set to "Allow only superlibrarians" - only super librarians can give other staff patrons superlibrarian access.)
- [36816](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36816) OPAC - Patron 'submit update request' does not work for clearing patron attribute types

### Searching

#### Other bugs fixed

- [37369](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37369) Item search column filtering can't use descriptions

  **Sponsored by** *Koha-Suomi Oy*

### Tools

#### Critical bugs fixed

- [31450](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31450) HTML customizations and news will not display on OPAC without a publication date
  >This fixes the display of news, HTML customizations, and pages on the OPAC - a publication date is now required for all types of additional content. Previously, news items and HTML customizations were not shown if they didn't have a publication date (this behavour was not obvious from the forms).

  **Sponsored by** *Athens County Public Libraries*
- [37654](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37654) XSS in batch record import for the citation column

  **Sponsored by** *Chetco Community Public Library*

#### Other bugs fixed

- [37730](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37730) Batch patron modification table horizontal scroll causes headers to mismatch
  >This fixes the table for the batch patron modification tool (Tools > Patrons and circulation > Batch patron modification). When you scrolled down the page so that table header rows are "sticky", and then scrolled to the right, the table header columns were fixed instead of changing to match the column contents.

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Armenian (hy_ARMN)](https://koha-community.org/manual/22.11//html/) (100%)
- [Chinese (Traditional)](https://koha-community.org/manual/22.11/zh_Hant/html/) (99%)
- [English](https://koha-community.org/manual/22.11//html/) (100%)
- [English (USA)](https://koha-community.org/manual/22.11/en/html/)
- [French](https://koha-community.org/manual/22.11/fr/html/) (71%)
- [German](https://koha-community.org/manual/22.11/de/html/) (99%)
- [Greek](https://koha-community.org/manual/22.11//html/) (96%)
- [Hindi](https://koha-community.org/manual/22.11/hi/html/) (71%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (90%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified) (96%)
- Chinese (Traditional) (82%)
- Czech (72%)
- Dutch (89%)
- English (100%)
- English (New Zealand) (69%)
- English (USA)
- English (United Kingdom) (99%)
- Finnish (96%)
- French (99%)
- French (Canada) (96%)
- German (100%)
- German (Switzerland) (56%)
- Greek (71%)
- Hindi (99%)
- Italian (92%)
- Norwegian Bokmål (69%)
- Persian (fa_ARAB) (77%)
- Polish (100%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (88%)
- Russian (94%)
- Slovak (68%)
- Spanish (99%)
- Swedish (88%)
- Telugu (77%)
- Tetum (54%)
- Turkish (91%)
- Ukrainian (79%)
- hyw_ARMN (generated) (hyw_ARMN) (70%)
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

The release team for Koha 22.11.26 is


- Release Manager: 

## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 22.11.26
<div style="column-count: 2;">

- Athens County Public Libraries
- Chetco Community Public Library
- Karlsruhe Institute of Technology (KIT)
- [Koha-Suomi Oy](https://koha-suomi.fi)
</div>

We thank the following individuals who contributed patches to Koha 22.11.26
<div style="column-count: 2;">

- Noémie Ariste (1)
- Nick Clemens (2)
- David Cook (1)
- Paul Derscheid (2)
- Jonathan Druart (7)
- Lucas Gass (1)
- Owen Leonard (1)
- Jesse Maseto (1)
- Phil Ringnalda (3)
- Fridolin Somers (1)
- Raphael Straub (2)
- Emmi Takkinen (1)
- Chloe Zermatten (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 22.11.26
<div style="column-count: 2;">

- Athens County Public Libraries (1)
- [BibLibre](https://www.biblibre.com) (1)
- [ByWater Solutions](https://bywatersolutions.com) (4)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha) (1)
- Chetco Community Public Library (3)
- Karlsruhe Institute of Technology (KIT) (2)
- Koha Community Developers (7)
- [Koha-Suomi Oy](https://koha-suomi.fi) (1)
- [LMSCloud](lmscloud.de) (2)
- [Prosentient Systems](https://www.prosentient.com.au) (1)
- [PTFS Europe](https://ptfs-europe.com) (1)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Pedro Amorim (2)
- Tomás Cohen Arazi (1)
- Nick Clemens (3)
- David Cook (5)
- Lucas Gass (3)
- Victor Grousset (2)
- Olivier Hubert (1)
- Jan Kissig (1)
- Emily Lamancusa (2)
- Brendan Lawlor (1)
- Owen Leonard (1)
- Jesse Maseto (15)
- David Nind (3)
- Martin Renvoize (5)
- Phil Ringnalda (2)
- Marcel de Rooy (2)
- Emmi Takkinen (1)
- wainuiwitikapark (1)
- Baptiste Wojtkowski (1)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 22.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 24 Apr 2025 16:57:53.
