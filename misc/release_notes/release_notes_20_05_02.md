# RELEASE NOTES FOR KOHA 20.05.02
22 Jul 2020

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 20.05.02 can be downloaded from:

- [Download](http://download.koha-community.org/koha-20.05.02.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 20.05.02 is a bugfix/maintenance release.

It includes 17 enhancements, 25 bugfixes.

### System requirements

Koha is continuously tested against the following configurations and as such these are the recommendations for 
deployment: 

- Debian Jessie with MySQL 5.5 (End of life)
- Debian Stretch with MariaDB 10.1
- Debian Buster with MariaDB 10.3
- Ubuntu Bionic with MariaDB 10.1 
- Debian Stretch with MySQL 8.0 (Experimental MySQL 8.0 support)

Additional notes:
    
- Perl 5.10 is required (5.24 is recommended)
- Zebra or Elasticsearch is required




## Enhancements

### Architecture, internals, and plumbing

- [[21395]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21395) Make perlcritic happy

### Circulation

- [[25232]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25232) Add ability to skip trapping items with a given notforloan value
- [[25699]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25699) Add edition information to Holds to pull report

### Hold requests

- [[25789]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25789) New expiration date on placing a hold in staff interface can be set to a date in the past

  **Sponsored by** *Koha-Suomi Oy*

### Notices

- [[25097]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25097) Add option to message_queue to allow for only specific sending notices

### OPAC

- [[18911]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18911) Option to set preferred language in OPAC
- [[22807]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22807) Accessibility: Add 'Skip to main content' link
- [[25151]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25151) Accessibility: The 'Your cart' page does not contain a level-one header
- [[25154]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25154) Accessibility: The 'Search results' page does not use heading markup where content is introduced
- [[25236]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25236) Accessibility: The 'Refine your search' box contains semantically incorrect headings
- [[25238]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25238) Accessibility: Multiple 'H1' headings exist in the full record display
- [[25239]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25239) Accessibility: The 'Confirm hold page' contains semantically incorrect headings
- [[25402]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25402) Put OPAC cart download options into dropdown menu

  >This enhancement adds the OPAC cart download format options into the dropdown menu, rather than opening in a separate pop up window. (This also matches the behaviour in the staff interface.)

### Staff Client

- [[12093]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12093) Add CSS classes to item statuses in detail view

### Templates

- [[25471]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25471) Add DataTables to MARC subfield structure admin page for bibliographic frameworks
- [[25747]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25747) Don't display a comma when patron has no firstname

### Tools

- [[4985]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=4985) Copy a change on the calendar to all libraries

  **Sponsored by** *Koha-Suomi Oy*


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[24986]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24986) Maximum row size reached soon for borrowers and deletedborrowers

### Circulation

- [[25851]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25851) 19.11 upgrade creates holdallowed rule with empty value

### Command-line Utilities

- [[25752]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25752) Current directory not kept when using koha-shell

### OPAC

- [[22672]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22672) Replace <i> tags with <em> AND <b> tags with <strong> in the OPAC
- [[25769]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25769) Patron self modification triggers change request for date of birth to null

### Patrons

- [[25322]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25322) Adding a guarantor with no relationship defaults to first available relationship name
- [[25858]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25858) Borrower permissions are broken by update from bug 22868

### Searching - Elasticsearch

- [[25864]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25864) Case sensitivity breaks searching of some fields in ES5


## Other bugs fixed

### Acquisitions

- [[25611]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25611) Changing the vendor when creating the basket does not keep that new vendor

### Architecture, internals, and plumbing

- [[25875]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25875) Patron displayed multiple times in add user search if they have multiple sub permissions

### Cataloging

- [[25189]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25189) AutoCreateAuthorities can repeatedly generate authority records when using Default linker
- [[25553]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25553) Edit item date sort does not sort correctly

### Circulation

- [[25440]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25440) Remove undef and CGI warnings and fix template variables list in circulation rules
- [[25807]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25807) Version 3.008 of Template breaks smart-rules display

### Installation and upgrade (web-based installer)

- [[25491]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25491) Perl warning at the login page of installer

### OPAC

- [[11994]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11994) Fix OpenSearch discovery in the OPAC

  >OpenSearch (https://en.wikipedia.org/wiki/OpenSearch) allows you to search your library's catalog directly from the browser address bar or search box. This fixes the OpenSearch feature so that it now works correctly in Firefox. Note: make sure OPACBaseURL is correctly set.
- [[24352]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24352) Wrong labels displaying in result list with OpacItemLocation

  >This fixes the OPAC's MARC21 search results XSLT so that OPAC search result information is correctly labelled based on the OpacItemLocation preference.
  >
  >Previously, search results showed the label "Location(s)" whether the
  >setting was "collection code" or "location."
- [[25914]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25914) Relative's checkouts have empty title in OPAC

### Packaging

- [[25509]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25509) Remove useless libjs-jquery dependency

### REST API

- [[25570]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25570) Listing requests should be paginated by default

### SIP2

- [[25805]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25805) SIP will show hold patron name (DA) as something like C4::SIP::SIPServer=HASH(0x88175c8) if there is no patron

### Staff Client

- [[25756]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25756) Empty HTML table row after OPAC "Appearance" preferences
- [[25804]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25804) Remove HTML from title tag of bibliographic detail page

### Templates

- [[25447]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25447) Terminology: Fix button text "Edit biblio"

  >This updates the text on the cataloging main page so that in the menu for each search result the "Edit biblio" link is now "Edit record."

### Web services

- [[25793]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25793) OAI 'Set' and 'Metadata' dropdowns broken by OPAC jQuery upgrade
## New sysprefs

- SkipHoldTrapOnNotForLoanValue

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://koha-community.org/manual/20.05/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (84.6%)
- Armenian (99.9%)
- Armenian (Classical) (99.7%)
- Chinese (Taiwan) (91.3%)
- Czech (81.2%)
- English (New Zealand) (68%)
- English (USA)
- Finnish (70%)
- French (82%)
- French (Canada) (95.8%)
- German (97.7%)
- German (Switzerland) (75.9%)
- Greek (60.8%)
- Hindi (100%)
- Italian (81.7%)
- Norwegian Bokmål (72.5%)
- Polish (73.3%)
- Portuguese (86.3%)
- Portuguese (Brazil) (100%)
- Slovak (72.6%)
- Spanish (100%)
- Swedish (79%)
- Telugu (91.4%)
- Turkish (91.8%)
- Ukrainian (65.4%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 20.05.02 is


- Release Manager: Martin Renvoize

- Release Manager assistants:
  - Tomás Cohen Arazi
  - Jonathan Druart

- QA Manager: Katrin Fischer

- QA Team:
  - Jonathan Druart
  - Marcel de Rooy
  - Joonas Kylmälä
  - Josef Moravec
  - Tomás Cohen Arazi
  - Nick Clemens
  - Kyle Hall

- Topic Experts:
  - SIP2 -- Colin Campbell
  - EDI -- Colin Campbell
  - Elasticsearch -- Fridolin Somers
  - REST API -- Tomás Cohen Arazi
  - ILS-DI -- Arthur Suzuki
  - UI Design -- Owen Leonard
  - ILL -- Andrew Isherwood

- Bug Wranglers:
  - Michal Denár
  - Cori Lynn Arnold
  - Lisette Scheer
  - Amit Gupta

- Packaging Manager: Mason James


- Documentation Managers:
  - Caroline Cyr La Rose
  - David Nind

- Documentation Team:
  - Donna Bachowski
  - Lucy Vaux-Harvey
  - Sugandha Bajaj

- Translation Manager: Bernardo González Kriegel


- Release Maintainers:
  - 19.11 -- Joy Nelson
  - 19.05 -- Lucas Gass
  - 18.11 -- Hayley Mapley

- Release Maintainer mentors:
  - 19.11 -- Martin Renvoize
  - 19.05 -- Nick Clemens
  - 18.11 -- Chris Cormack

## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 20.05.02:

- Koha-Suomi Oy

We thank the following individuals who contributed patches to Koha 20.05.02.

- Tomás Cohen Arazi (4)
- Nick Clemens (7)
- David Cook (1)
- Jonathan Druart (8)
- Katrin Fischer (3)
- Lucas Gass (8)
- Kyle Hall (6)
- Owen Leonard (11)
- Hayley Mapley (1)
- Julian Maurice (7)
- Andrew Nugged (6)
- Martin Renvoize (12)
- David Roberts (1)
- Marcel de Rooy (1)
- Andreas Roussos (1)
- Slava Shishkin (1)
- Emmi Takkinen (3)
- Koha Translators (1)
- Petro Vashchuk (2)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 20.05.02

- Athens County Public Libraries (11)
- BibLibre (7)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (3)
- ByWater-Solutions (21)
- Catalyst (1)
- Dataly Tech (1)
- Independant Individuals (12)
- Koha Community Developers (8)
- Prosentient Systems (1)
- PTFS-Europe (13)
- Rijks Museum (1)
- Theke Solutions (4)

We also especially thank the following individuals who tested patches
for Koha.

- Tomás Cohen Arazi (4)
- Alex Arnaud (5)
- Alex Buckley (1)
- Jonathan Druart (73)
- Katrin Fischer (29)
- Andrew Fuerste-Henry (3)
- Lucas Gass (76)
- Didier Gautheron (1)
- Kyle Hall (1)
- Sally Healey (11)
- Heather Hernandez (1)
- Bernardo González Kriegel (2)
- Rhonda Kuiper (1)
- Owen Leonard (9)
- Hayley Mapley (5)
- Julian Maurice (5)
- David Nind (5)
- Martin Renvoize (29)
- Marcel de Rooy (1)
- Emmi Takkinen (1)
- Timothy Alexis Vass (1)
- Christofer Zorn (1)

We thank the following individuals who mentored new contributors to the Koha project.

- Andrew Nugged


We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is rmain2005.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 22 Jul 2020 21:03:08.
