# RELEASE NOTES FOR KOHA 19.11.08
22 Jul 2020

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 19.11.08 can be downloaded from:

- [Download](http://download.koha-community.org/koha-19.11.08.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 19.11.08 is a bugfix/maintenance release.

It includes 8 enhancements, 18 bugfixes.

### System requirements

Koha is continiously tested against the following configurations and as such these are the recommendations for 
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

### Hold requests

- [[25789]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25789) New expiration date on placing a hold in staff interface can be set to a date in the past

  **Sponsored by** *Koha-Suomi Oy*

### OPAC

- [[22807]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22807) Accessibility: Add 'Skip to main content' link
- [[25151]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25151) Accessibility: The 'Your cart' page does not contain a level-one header
- [[25154]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25154) Accessibility: The 'Search results' page does not use heading markup where content is introduced
- [[25236]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25236) Accessibility: The 'Refine your search' box contains semantically incorrect headings
- [[25238]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25238) Accessibility: Multiple 'H1' headings exist in the full record display
- [[25239]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25239) Accessibility: The 'Confirm hold page' contains semantically incorrect headings

### Tools

- [[4985]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=4985) Copy a change on the calendar to all libraries

  **Sponsored by** *Koha-Suomi Oy*


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[24986]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24986) Maximum row size reached soon for borrowers and deletedborrowers

### MARC Bibliographic record staging/import

- [[25861]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25861) [19.11] Cannot copy MARC frameworks

  **Sponsored by** *Catalyst*

  >Bug 17232 updated some SQL queries used when adding new MARC bibliographic frameworks. When backported to 19.11.x, it referenced a column `important` that does not exist in the marc_tag_structure table or marc_subfield_structure table in 19.11.x. This patch removes the references to `important` so that adding new bibliographic frameworks works again.

### OPAC

- [[22672]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22672) Replace &lt;i&gt; tags with &lt;em&gt; AND &lt;b&gt; tags with &lt;strong&gt; in the OPAC
- [[25769]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25769) Patron self modification triggers change request for date of birth to null

### Searching - Elasticsearch

- [[25864]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25864) Case sensitivity breaks searching of some fields in ES5


## Other bugs fixed

### Acquisitions

- [[25611]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25611) Changing the vendor when creating the basket does not keep that new vendor

### Architecture, internals, and plumbing

- [[25875]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25875) Patron displayed multiple times in add user search if they have multiple sub permissions

### Cataloging

- [[25553]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25553) Edit item date sort does not sort correctly

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
- [[25434]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25434) When viewing cart on small screen sizes selections-toolbar is hidden

### Packaging

- [[25509]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25509) Remove useless libjs-jquery dependency

### REST API

- [[25570]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25570) Listing requests should be paginated by default

### SIP2

- [[25805]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25805) SIP will show hold patron name (DA) as something like C4::SIP::SIPServer=HASH(0x88175c8) if there is no patron

### Staff Client

- [[25756]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25756) Empty HTML table row after OPAC "Appearance" preferences

### Templates

- [[25447]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25447) Terminology: Fix button text "Edit biblio"

  >This updates the text on the cataloging main page so that in the menu for each search result the "Edit biblio" link is now "Edit record."

### Web services

- [[25793]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25793) OAI 'Set' and 'Metadata' dropdowns broken by OPAC jQuery upgrade


## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://koha-community.org/manual/19.11/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (98.2%)
- Armenian (99.8%)
- Armenian (Classical) (100%)
- Basque (56%)
- Catalan; Valencian (50.9%)
- Chinese (China) (57.3%)
- Chinese (Taiwan) (99%)
- Czech (91.1%)
- English (New Zealand) (78.8%)
- English (USA)
- Finnish (74.7%)
- French (95.3%)
- French (Canada) (94.2%)
- German (100%)
- German (Switzerland) (81.3%)
- Greek (70.6%)
- Hindi (100%)
- Italian (86.2%)
- Norwegian Bokmål (83.8%)
- Occitan (post 1500) (53.4%)
- Polish (78.8%)
- Portuguese (100%)
- Portuguese (Brazil) (99.8%)
- Slovak (83.5%)
- Spanish (100%)
- Swedish (85.5%)
- Telugu (93.7%)
- Turkish (100%)
- Ukrainian (74.8%)
- Vietnamese (51.5%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 19.11.08 is


- Release Manager: Jonathan Druart

- Release Manager assistants:
  - Martin Renvoize
  - Tomás Cohen Arazi

- QA Manager: Katrin Fischer

- QA Team:
  - Marcel de Rooy
  - Joonas Kylmälä
  - Josef Moravec
  - Tomás Cohen Arazi
  - Nick Clemens
  - Kyle Hall
  - Martin Renvoize
  - Alex Arnaud
  - Julian Maurice
  - Matthias Meusburger

- Topic Experts:
  - Elasticsearch -- Frédéric Demians
  - REST API -- Tomás Cohen Arazi
  - UI Design -- Owen Leonard
  - Zebra -- Fridolin Somers
  - Accounts -- Martin Renvoize
  - CAS/Shibboleth -- Matthias Meusburger

- Bug Wranglers:
  - Michal Denár
  - Holly Cooper
  - Henry Bolshaw
  - Lisette Scheer
  - Mengü Yazıcıoğlu

- Packaging Manager: Mason James


- Documentation Managers:
  - Caroline Cyr La Rose
  - David Nind

- Documentation Team:
  - Martin Renvoize
  - Donna Bachowski
  - Lucy Vaux-Harvey
  - Kelly McElligott
  - Jessica Zairo
  - Chris Cormack
  - Henry Bolshaw
  - Jon Drucker

- Translation Manager: Bernardo González Kriegel


- Release Maintainers:
  - 20.05 -- Lucas Gass
  - 19.11 -- Aleisha Amohia
  - 19.05 -- Victor Grousset

- Release Maintainer mentors:
  - 19.11 -- Hayley Mapley
  - 19.05 -- Martin Renvoize

## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 19.11.08:

- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)
- Koha-Suomi Oy

We thank the following individuals who contributed patches to Koha 19.11.08.

- Aleisha Amohia (7)
- Tomás Cohen Arazi (4)
- Nick Clemens (4)
- David Cook (1)
- Jonathan Druart (4)
- Katrin Fischer (2)
- Lucas Gass (3)
- Kyle Hall (2)
- Owen Leonard (5)
- Hayley Mapley (1)
- Martin Renvoize (9)
- Andreas Roussos (1)
- Slava Shishkin (1)
- Emmi Takkinen (3)
- Koha Translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 19.11.08

- Athens County Public Libraries (5)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (2)
- ByWater-Solutions (9)
- Catalyst (1)
- Dataly Tech (1)
- Independant Individuals (11)
- Koha Community Developers (4)
- Prosentient Systems (1)
- PTFS-Europe (9)
- Theke Solutions (4)

We also especially thank the following individuals who tested patches
for Koha.

- Aleisha Amohia (40)
- Tomás Cohen Arazi (2)
- Alex Arnaud (2)
- Alex Buckley (1)
- Jonathan Druart (39)
- Katrin Fischer (22)
- Lucas Gass (38)
- Sally Healey (7)
- Heather Hernandez (1)
- Rhonda Kuiper (1)
- Owen Leonard (5)
- Hayley Mapley (4)
- Julian Maurice (4)
- David Nind (5)
- Martin Renvoize (14)
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
line is 19.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 22 Jul 2020 00:57:05.
