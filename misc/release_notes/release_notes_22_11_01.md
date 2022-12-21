# RELEASE NOTES FOR KOHA 22.11.01
22 Dec 2022

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 22.11.01 can be downloaded from:

- [Download](http://download.koha-community.org/koha-22.11.01.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 22.11.01 is a bugfix/maintenance release with security fixes.

It includes 2 security fixes, 2 enhancements, 43 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha [here](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


## Security bugs

### Koha

- [[31908]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31908) New login fails while having cookie from previous session

  >This patch introduces more thorough cleanup of user sessions when logging after a privilege escalation request.
- [[32208]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32208) Relogin without enough permissions needs attention


## Enhancements

### Circulation

- [[32134]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32134) Show the bundle size when checked out

### Self checkout

- [[32115]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32115) Add ID to check-out default help message dialog to allow customization


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[32394]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32394) Long tasks queue is never used
- [[32422]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32422) Hardcoded paths in _common.scss prevent using external node_modules

### Authentication

- [[32354]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32354) Handle session_state param given by OAuth identity provider

  **Sponsored by** *The New Zealand Institute for Plant and Food Research Limited*

  >This patch ensures Koha doesn't throw an error if the IdP hands back a session_state parameter.

### ERM

- [[32468]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32468) Vendors select only allows selecting from first 20 vendors by default

### Hold requests

- [[32470]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32470) (Bug 14783 follow-up) Fix mysql error in db_rev for 22.06.000.064

### Installation and upgrade (web-based installer)

- [[32399]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32399) Database update for bug 30483 is failing

### REST API

- [[31381]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31381) Searching patrons by letter broken when using non-mandatory extended attributes

### Searching

- [[32126]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32126) Adding item search fields is broken - can't add more than one field


## Other bugs fixed

### Acquisitions

- [[31984]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31984) TaxRate system preference - add note about updating vendor tax rates where required

  >This enhancement adds a note to the TaxRates system preference about updating vendors tax rates when the TaxRates system preference values are changed or removed. (Vendors retain the original value entered, and this is used to calculate the tax rate for orders.)
- [[32417]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32417) Cannot insert order: Mandatory parameter biblionumber is missing

### Architecture, internals, and plumbing

- [[31675]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31675) Remove packages from debian/control that are no longer used
- [[32330]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32330) Table background_jobs is missing indexes
- [[32457]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32457) CGI::param called in list context from acqui/addorder.pl line 182

### Circulation

- [[28975]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28975) Holds queue lists can show holds from all libraries even with IndependentBranches

### Hold requests

- [[32247]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32247) HoldsQueue does not need to check items if there are no holds

### Lists

- [[32302]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32302) "ISBN" label shows when no ISBN data present when sending list

  >This fixes email messages sent when sending lists so that if there are no ISBNs for a record, an empty label is not shown.

### Patrons

- [[31166]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31166) Digest option is not selectable for phone when PhoneNotification is enabled

### REST API

- [[31160]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31160) Required fields in the Patrons API are a bit random

### Searching

- [[20596]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20596) Authority record matching rule causes staging failure when MARC record contains multiple tag values for a match point

### Staff interface

- [[32194]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32194) "Can be guarantee" value should show uppercase "No"

  >This fixes the display of the patron categories "Can be guarantee" column so that "No" values have a capital "N". Previously, "no" values were shown with a lowercase "n".
- [[32236]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32236) Batch item modification - alignment of tick box for 'Use default values'
- [[32257]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32257) Label for patron attributes misaligned on patron batch mod
- [[32261]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32261) Insufficient user feedback when selecting patron in autocomplete
- [[32355]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32355) Add class url to all URL syspref
- [[32368]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32368) Add page-section to saved report results

### System Administration

- [[32291]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32291) "library category" messages should be removed (not used)

### Templates

- [[28235]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28235) Custom cover images are very large in staff search results and OPAC details
- [[32061]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32061) <span> in the title of z39.50 servers page
- [[32074]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32074) Edit vendor has a floating toolbar, but still an additional save button at the bottom
- [[32200]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32200) Add page-section checkout notes page (circ)
- [[32213]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32213) Reindent item search fields template
- [[32282]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32282) Capitalization: User id
- [[32283]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32283) Capitalization: opac users of this domain to login with this identity provider
- [[32300]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32300) Add page-section to cataloguing plugins (cat)
- [[32320]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32320) Remove text-shadow from header menu links
- [[32323]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32323) Correct focus state of some DataTables controls
- [[32378]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32378) Incorrect label for in identity provider domains

### Test Suite

- [[29274]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29274) z_reset.t is wrong
- [[32350]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32350) We should die if TestBuilder is passed a column we're not expecting
- [[32351]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32351) Fix all TestBuilder calls failing due to wrong column names
- [[32352]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32352) xt/check_makefile.t failing on node_modules
- [[32366]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32366) BatchDeleteBiblio task should have tests to prove indexing all takes place in one step

### Tools

- [[32389]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32389) Syndetics links are built wrong on the staff results page



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)



The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (73.6%)
- Armenian (100%)
- Bulgarian (92.8%)
- Chinese (Taiwan) (83.9%)
- Czech (59.2%)
- English (New Zealand) (60%)
- English (USA)
- Finnish (96.1%)
- French (93.9%)
- French (Canada) (94.6%)
- German (100%)
- German (Switzerland) (51.1%)
- Greek (50.8%)
- Hindi (100%)
- Italian (94.3%)
- Nederlands-Nederland (Dutch-The Netherlands) (77.9%)
- Norwegian Bokmål (53%)
- Persian (58.7%)
- Polish (93.7%)
- Portuguese (74.5%)
- Portuguese (Brazil) (72.4%)
- Russian (73.8%)
- Slovak (60.1%)
- Spanish (100%)
- Swedish (76.9%)
- Telugu (79.6%)
- Turkish (86.6%)
- Ukrainian (71.7%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 22.11.01 is


- Release Manager: Tomás Cohen Arazi

- Release Manager assistants:
  - Jonathan Druart
  - Martin Renvoize

- QA Manager: Katrin Fischer

- QA Team:
  - Aleisha Amohia
  - Nick Clemens
  - David Cook
  - Jonathan Druart
  - Lucas Gass
  - Victor Grousset
  - Kyle M Hall
  - Martin Renvoize
  - Marcel de Rooy
  - Fridolin Somers

- Topic Experts:
  - UI Design -- Owen Leonard
  - Zebra -- Fridolin Somers
  - REST API -- Martin Renvoize

- Bug Wranglers:
  - Aleisha Amohia
  - Indranil Das Gupta

- Packaging Manager: Mason James


- Documentation Manager: Caroline Cyr La Rose


- Documentation Team:
  - Aude Charillon
  - David Nind
  - Lucy Vaux-Harvey

- Translation Manager: Bernardo González Kriegel


- Wiki curators: 
  - Thomas Dukleth
  - Katrin Fischer

- Release Maintainers:
  - 22.11 -- PTFS Europe (Martin Renvoize, Matt Blenkinsop, Jacob O'Mara)
  - 22.05 -- Lucas Gass
  - 21.11 -- Arthur Suzuki
  - 21.05 -- Wainui Witika-Park

## Credits
We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 22.11.01

- [The New Zealand Institute for Plant and Food Research Limited](https://www.plantandfood.com/en-nz/)

We thank the following individuals who contributed patches to Koha 22.11.01

- Aleisha Amohia (1)
- Tomás Cohen Arazi (11)
- Andrew Auld (3)
- Matt Blenkinsop (6)
- Nick Clemens (2)
- David Cook (3)
- Jonathan Druart (20)
- Katrin Fischer (5)
- Lucas Gass (1)
- Didier Gautheron (1)
- Michael Hafen (1)
- Kyle M Hall (3)
- Owen Leonard (5)
- The Minh Luong (1)
- Julian Maurice (1)
- David Nind (4)
- Mona Panchaud (1)
- Martin Renvoize (2)
- Marcel de Rooy (12)
- Fridolin Somers (2)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 22.11.01

- Athens County Public Libraries (5)
- BibLibre (4)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (5)
- ByWater-Solutions (6)
- Catalyst Open Source Academy (1)
- David Nind (4)
- Independant Individuals (1)
- Koha Community Developers (20)
- mpan.ch (1)
- Prosentient Systems (3)
- PTFS-Europe (11)
- Rijksmuseum (12)
- Solutions inLibro inc (1)
- Theke Solutions (11)

We also especially thank the following individuals who tested patches
for Koha

- Tomás Cohen Arazi (66)
- Matt Blenkinsop (5)
- Nick Clemens (4)
- David Cook (5)
- Chris Cormack (2)
- David (2)
- Katrin Fischer (18)
- Lucas Gass (8)
- Amit Gupta (1)
- Kyle M Hall (3)
- Evelyn Hartline (1)
- Jan Kissig (2)
- Owen Leonard (5)
- David Nind (15)
- Jacob O'Mara (24)
- Martin Renvoize (63)
- Marcel de Rooy (5)
- Danyon Sewell (1)
- Fridolin Somers (2)
- Hammat Wele (1)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 22.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 22 Dec 2022 15:28:12.
