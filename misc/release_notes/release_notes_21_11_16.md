# RELEASE NOTES FOR KOHA 21.11.16
27 Jan 2023

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 21.11.16 can be downloaded from:

- [Download](http://download.koha-community.org/koha-21.11.16.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 21.11.16 is a bugfix/maintenance release with security fixes.

It includes 2 security fixes, 3 enhancements, 23 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations


## Security bugs

### Koha

- [[31908]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31908) New login fails while having cookie from previous session

  >This patch introduces more thorough cleanup of user sessions when logging after a privilege escalation request.
- [[32208]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32208) Relogin without enough permissions needs attention


## Enhancements

### OPAC

- [[31064]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31064) Local login is difficult to style using CSS

### Self checkout

- [[32115]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32115) Add ID to check-out default help message dialog to allow customization

### Templates

- [[29458]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29458) Show login button consistently in relation to login instructions, reset and register links


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[32481]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32481) Rabbit times out when too many jobs are queued and the response takes too long


## Other bugs fixed

### Acquisitions

- [[32016]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32016) Fix 'clear filter' button behavior on datatable saving their state

### Architecture, internals, and plumbing

- [[31675]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31675) Remove packages from debian/control that are no longer used
- [[31873]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31873) Can't call method "safe_delete" on an undefined value at cataloguing/additem.pl
- [[32330]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32330) Table background_jobs is missing indexes
- [[32457]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32457) CGI::param called in list context from acqui/addorder.pl line 182

### Cataloging

- [[31881]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31881) Link in MARC view does not work

### Circulation

- [[28975]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28975) Holds queue lists can show holds from all libraries even with IndependentBranches

### Fines and fees

- [[22042]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22042) BlockReturnofWithdrawn Items does not block refund generation when item is withdrawn and lost

### Hold requests

- [[31086]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31086) Do not allow hold requests with no branchcode

### Lists

- [[32302]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32302) "ISBN" label shows when no ISBN data present when sending list

  >This fixes email messages sent when sending lists so that if there are no ISBNs for a record, an empty label is not shown.

### Patrons

- [[31166]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31166) Digest option is not selectable for phone when PhoneNotification is enabled
- [[31492]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31492) Patron image upload fails on first attempt with CSRF failure

### Searching

- [[20596]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20596) Authority record matching rule causes staging failure when MARC record contains multiple tag values for a match point

### Staff interface

- [[31244]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31244) Logout when not logged in raise a 500
- [[32355]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32355) Add class url to all URL syspref

### System Administration

- [[30694]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30694) Impossible to delete line in circulation and fine rules

  **Sponsored by** *Koha-Suomi Oy*
- [[32291]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32291) "library category" messages should be removed (not used)

### Templates

- [[32348]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32348) Library public is missing from columns settings

### Test Suite

- [[32349]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32349) Remove TEST_QA
- [[32622]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32622) Auth.t failing on D10

### Tools

- [[32037]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32037) Circulation module in action logs has bad links for deleted items
- [[32255]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32255) Cannot use file upload in batch record modification



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/21.11/ar/html/) (33.8%)
- [Chinese (Taiwan)](https://koha-community.org/manual/21.11/zh_TW/html/) (58.8%)
- [Czech](https://koha-community.org/manual/21.11/cs/html/) (27.2%)
- [English (USA)](https://koha-community.org/manual/21.11/en/html/)
- [French](https://koha-community.org/manual/21.11/fr/html/) (69%)
- [French (Canada)](https://koha-community.org/manual/21.11/fr_CA/html/) (25.6%)
- [German](https://koha-community.org/manual/21.11/de/html/) (73.3%)
- [Hindi](https://koha-community.org/manual/21.11/hi/html/) (100%)
- [Italian](https://koha-community.org/manual/21.11/it/html/) (48.2%)
- [Spanish](https://koha-community.org/manual/21.11/es/html/) (36.1%)
- [Turkish](https://koha-community.org/manual/21.11/tr/html/) (39.6%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (86.6%)
- Armenian (100%)
- Armenian (Classical) (89%)
- Bulgarian (100%)
- Chinese (Taiwan) (78.8%)
- Czech (76.9%)
- English (New Zealand) (60.3%)
- English (USA)
- Finnish (98.8%)
- French (95.6%)
- French (Canada) (92%)
- German (100%)
- German (Switzerland) (58.3%)
- Greek (60.4%)
- Hindi (100%)
- Italian (100%)
- Nederlands-Nederland (Dutch-The Netherlands) (86.5%)
- Norwegian Bokmål (62.7%)
- Polish (100%)
- Portuguese (91.1%)
- Portuguese (Brazil) (83%)
- Russian (84.2%)
- Slovak (74.8%)
- Spanish (100%)
- Swedish (81.6%)
- Telugu (94.3%)
- Turkish (100%)
- Ukrainian (75.4%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 21.11.16 is


- Release Manager: Jonathan Druart

- Release Manager assistants:
  - Martin Renvoize
  - Tomás Cohen Arazi

- QA Manager: Katrin Fischer

- QA Team:
  - Agustín Moyano
  - Andrew Nugged
  - David Cook
  - Joonas Kylmälä
  - Julian Maurice
  - Kyle M Hall
  - Marcel de Rooy
  - Martin Renvoize
  - Nick Clemens
  - Petro Vashchuk
  - Tomás Cohen Arazi
  - Victor Grousset

- Topic Experts:
  - UI Design -- Owen Leonard
  - REST API -- Tomás Cohen Arazi
  - Elasticsearch -- Fridolin Somers
  - Zebra -- Fridolin Somers
  - Accounts -- Martin Renvoize

- Bug Wranglers:
  - Sally Healey

- Packaging Manager: 


- Documentation Manager: David Nind


- Documentation Team:
  - David Nind
  - Lucy Vaux-Harvey

- Translation Managers: 
  - Bernardo González Kriegel

- Wiki curators: 
  - Thomas Dukleth

- Release Maintainers:
  - 21.05 -- Kyle M Hall
  - 20.11 -- Fridolin Somers
  - 20.05 -- Victor Grousset
  - 19.11 -- Wainui Witika-Park

- Release Maintainer assistants:
  - 21.05 -- Nick Clemens

- Release Maintainer mentors:
  - 19.11 -- Aleisha Amohia

## Credits
We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 21.11.16

- Koha-Suomi Oy

We thank the following individuals who contributed patches to Koha 21.11.16

- Tomás Cohen Arazi (5)
- Nick Clemens (2)
- David Cook (4)
- Jonathan Druart (8)
- Géraud Frappier (1)
- Lucas Gass (1)
- Didier Gautheron (1)
- Thibaud Guillot (2)
- Kyle M Hall (3)
- The Minh Luong (1)
- David Nind (1)
- Mona Panchaud (1)
- Martin Renvoize (2)
- Marcel de Rooy (15)
- Fridolin Somers (4)
- Arthur Suzuki (13)
- Emmi Takkinen (1)
- Koha translators (2)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 21.11.16

- BibLibre (20)
- ByWater-Solutions (6)
- David Nind (1)
- Koha Community Developers (8)
- Koha-Suomi (1)
- mpan.ch (1)
- Prosentient Systems (4)
- PTFS-Europe (2)
- Rijksmuseum (15)
- Solutions inLibro inc (2)
- Theke Solutions (5)

We also especially thank the following individuals who tested patches
for Koha

- Tomás Cohen Arazi (27)
- Matt Blenkinsop (3)
- Nick Clemens (7)
- David Cook (9)
- Chris Cormack (4)
- Jonathan Druart (1)
- Katrin Fischer (10)
- Andrew Fuerste-Henry (1)
- Lucas Gass (42)
- Victor Grousset (1)
- Kyle M Hall (5)
- Evelyn Hartline (1)
- Sally Healey (1)
- Mason James (1)
- Jan Kissig (2)
- Owen Leonard (1)
- David Nind (7)
- Jacob O'Mara (9)
- Martin Renvoize (16)
- Marcel de Rooy (6)
- Danyon Sewell (1)
- Fridolin Somers (3)
- Arthur Suzuki (32)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 21.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 27 Jan 2023 13:41:51.
