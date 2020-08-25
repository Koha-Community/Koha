# RELEASE NOTES FOR KOHA 19.05.14
25 Aug 2020

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 19.05.14 can be downloaded from:

- [Download](https://download.koha-community.org/koha-19.05.14.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 19.05.14 is a bugfix/maintenance release with security fixes.

It includes 3 security fixes, 6 enhancements, 11 bugfixes.

### System requirements

- Debian 8 (Jessie) is not supported anymore
- MySQL 5.5 is not supported anymore

Koha is continuously tested against the following configurations and as such these are the recommendations for 
deployment: 

- Debian 9 (Stretch) with MariaDB 10.1 (and experimental MariaDB 10.3 support)
- Ubuntu 18.04 (Bionic) with MariaDB 10.1

Additional notes:
    
- Perl >= 5.14 is required and 5.24 or 5.26 are recommended
- Zebra or Elasticsearch is required


## Security bugs

### Koha

- [[23634]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23634) Privilege escalation vulnerability for staff users with 'edit_borrowers' permission and 'OpacResetPassword' enabled
- [[24663]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24663) OPACPublic must be tested for all opac scripts
- [[25360]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25360) Use secure flag for CGISESSID cookie


## Enhancements

### OPAC

- [[25151]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25151) Accessibility: The 'Your cart' page does not contain a level-one header
- [[25154]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25154) Accessibility: The 'Search results' page does not use heading markup where content is introduced
- [[25236]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25236) Accessibility: The 'Refine your search' box contains semantically incorrect headings
- [[25238]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25238) Accessibility: Multiple 'H1' headings exist in the full record display
- [[25239]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25239) Accessibility: The 'Confirm hold page' contains semantically incorrect headings

### Tools

- [[4985]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=4985) Copy a change on the calendar to all libraries

  **Sponsored by** *Koha-Suomi Oy*




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


## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://koha-community.org/manual/19.05/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (98.6%)
- Armenian (99.9%)
- Armenian (Classical) (99.9%)
- Basque (59.2%)
- Chinese (China) (59.7%)
- Chinese (Taiwan) (99.4%)
- Czech (92.8%)
- Danish (52%)
- English (New Zealand) (82.7%)
- English (USA)
- Finnish (79%)
- French (98.3%)
- French (Canada) (99%)
- German (100%)
- German (Switzerland) (85.7%)
- Greek (73.5%)
- Hindi (100%)
- Italian (90.2%)
- Norwegian Bokmål (88.4%)
- Occitan (post 1500) (55.9%)
- Polish (82.7%)
- Portuguese (99.9%)
- Portuguese (Brazil) (94.2%)
- Slovak (86.5%)
- Spanish (100%)
- Swedish (87.9%)
- Turkish (99.9%)
- Ukrainian (73.7%)
- Vietnamese (50.7%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 19.05.14 is


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
new features in Koha 19.05.14:

- Koha-Suomi Oy

We thank the following individuals who contributed patches to Koha 19.05.14.

- Tomás Cohen Arazi (7)
- Nick Clemens (2)
- David Cook (3)
- Jonathan Druart (7)
- Katrin Fischer (2)
- Victor Grousset (3)
- Kyle Hall (1)
- Owen Leonard (3)
- Hayley Mapley (1)
- Martin Renvoize (10)
- Marcel de Rooy (1)
- Andreas Roussos (1)
- Slava Shishkin (1)
- Emmi Takkinen (2)
- Koha Translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 19.05.14

- Athens County Public Libraries (3)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (2)
- ByWater-Solutions (3)
- Catalyst (1)
- Dataly Tech (1)
- Independant Individuals (3)
- Koha Community Developers (10)
- Prosentient Systems (3)
- PTFS-Europe (10)
- Rijks Museum (1)
- Theke Solutions (7)

We also especially thank the following individuals who tested patches
for Koha.

- Aleisha Amohia (36)
- Tomás Cohen Arazi (9)
- Jonathan Druart (31)
- Katrin Fischer (15)
- Lucas Gass (27)
- Victor Grousset (40)
- Sally Healey (7)
- Rhonda Kuiper (1)
- Owen Leonard (4)
- Julian Maurice (1)
- David Nind (5)
- Martin Renvoize (22)
- Marcel de Rooy (8)
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
line is 19.05.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 25 Aug 2020 11:37:52.
