# RELEASE NOTES FOR KOHA 23.05.01
28 Jun 2023

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 23.05.01 can be downloaded from:

- [Download](http://download.koha-community.org/koha-23.05.01.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 23.05.01 is a bugfix/maintenance release.

It includes 6 enhancements, 35 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


## Bugfixes

### About

#### Other bugs fixed

- [33877](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33877) Fix teams.yaml

### Acquisitions

#### Critical bugs fixed

- [33885](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33885) Get HTTP 500 when retrieving orders created by a non-existent (deleted) user
  >This fixes an issue that prevents the receiving of items where the user who created the order has been deleted. When clicking on 'Receive' for an item, this error was displayed:
  >"Something went wrong when loading the table.
  >500: Internal Server Error."
- [34022](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34022) Adding items on receive is broken

#### Other bugs fixed

- [33748](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33748) UI issue on addorderiso2709.pl page

### Architecture, internals, and plumbing

#### Critical bugs fixed

- [33934](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33934) 'No encryption_key in koha-conf.xml' needs more detail
  >This fixes an issue that can cause upgrades to Koha 23.05 to fail with an error message that includes 'No encryption_key in koha-conf.xml'. It also requires the configuration entry in the instance koha-conf.xml to be something other than __ENCRYPTION_KEY__.
  >It is recommended that the key is generated using pwgen 32

#### Other bugs fixed

- [32060](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32060) Improve performance of Koha::Item->columns_to_str

  **Sponsored by** *Gothenburg University Library*
- [32464](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32464) Koha::Item->as_marc_field obsolete option mss
- [33803](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33803) Some scripts contain info about tab width
- [33844](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33844) item->is_denied_renewal should check column from associated pref

### Authentication

#### Critical bugs fixed

- [33904](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33904) 2FA registration fails if library name has non-latin characters
- [34028](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34028) Two factor authentication (2FA) shows the wrong values for manual entry
  >This fixes the details displayed for manually entering two-factor authentication (2FA) details into a 2FA application (when enabling 2FA). Currently, the wrong information is displayed - so you can't successfully add the account manually to your 2FA application.

### Cataloging

#### Other bugs fixed

- [33247](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33247) Deleted authority still on results list

### Circulation

#### Critical bugs fixed

- [33888](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33888) Overdues with fines report displays error 500
  >This fixes the 'Circulation > Overdues > Overdues with fines' listing so that it lists overdue items where there are fines, instead of generating an error.

### Fines and fees

#### Other bugs fixed

- [33789](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33789) Checkout information is missing when adding a credit

### ILL

#### Critical bugs fixed

- [21983](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21983) Better handling of deleted biblios on ILL requests
- [33786](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33786) ILL requests table pagination in patron ILL history is transposing for different patrons
- [33873](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33873) ILL requests with linked biblio_id that no longer exists causes table to not render

#### Other bugs fixed

- [22440](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22440) Improve ILL page performance by moving to server side filtering

### Installation and upgrade (web-based installer)

#### Other bugs fixed

- [33935](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33935) Installer list deleted files which shows warning in the logs

### MARC Bibliographic data support

#### Other bugs fixed

- [33865](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33865) JS error when importing a staged MARC record file

### OPAC

#### Critical bugs fixed

- [34093](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34093) jQuery not loading on OAI XSLT pages

#### Other bugs fixed

- [33697](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33697) Remove deprecated RecordedBooks (rbdigital) integration
- [33813](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33813) Accessibility: Lists button is not clearly identified
  >This enhancement adds an aria-label to the Lists button in the OPAC masthead. It is currently not descriptive enough and doesn't identify what is displayed when clicking the button.
- [33902](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33902) On opac-detail.tt the libraryInfoModal is outside of HTML tags
  >This moves the HTML for the pop-up window with the information for a library (where it exists) on the OPAC detail page inside the 'html' tag so that it validates correctly. There is no change to the appearance or behavior of the page.

### Packaging

#### Other bugs fixed

- [33371](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33371) Add 'koha-common.service' systemd service

### Patrons

#### Other bugs fixed

- [33875](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33875) Missing closing tag a in API key management page
- [33882](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33882) member.tt Date of birth column makes it difficult to hide the age hint

### Reports

#### Critical bugs fixed

- [33966](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33966) "Update and run SQL" for non-English templates

### SIP2

#### Other bugs fixed

- [33411](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33411) SIP2 includes other guarantees with the same guarantor when calculating against NoIssuesChargeGuarantees

### Templates

#### Other bugs fixed

- [33343](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33343) Password fields should have auto-completion off
- [33779](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33779) Terminology: biblio record
- [33859](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33859) Use the phrase 'Identity providers' instead of 'Authentication providers'
- [33883](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33883) "Make sure to copy your API secret" message overlaps text
- [33891](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33891) Use template wrapper for tabs: OPAC advanced search
- [33892](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33892) Use template wrapper for tabs: OPAC authority detail

## Enhancements 

### Architecture, internals, and plumbing

#### Enhancements

- [32478](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32478) Remove Koha::Config::SysPref->find since bypasses cache

  **Sponsored by** *Gothenburg University Library*
- [33236](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33236) Move C4::Suggestions::NewSuggestion to Koha namespace

### Circulation

#### Enhancements

- [33725](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33725) Add item's collection code to search results location column in staff interface

### ERM

#### Enhancements

- [32932](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32932) Re-structure Vue router-links to use "name" instead of urls

### Templates

#### Enhancements

- [33524](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33524) Use template wrapper for tabs: Authority editor
- [33525](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33525) Use template wrapper for tabs: Basic MARC editor

## Deleted system preferences

- RecordedBooksClientSecret
- RecordedBooksDomain
- RecordedBooksLibraryID

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (71.2%)
- Armenian (100%)
- Armenian (Classical) (64%)
- Bulgarian (92.1%)
- Chinese (Taiwan) (82.7%)
- Czech (58.2%)
- English (New Zealand) (67.4%)
- English (USA)
- Finnish (95.8%)
- French (98.3%)
- French (Canada) (97.4%)
- German (100%)
- Hindi (100%)
- Italian (91.2%)
- Nederlands-Nederland (Dutch-The Netherlands) (80.8%)
- Norwegian Bokmål (70.9%)
- Persian (77.9%)
- Polish (91.8%)
- Portuguese (89.5%)
- Portuguese (Brazil) (100%)
- Russian (95.3%)
- Slovak (61.2%)
- Spanish (100%)
- Swedish (81.7%)
- Telugu (76.3%)
- Turkish (86.2%)
- Ukrainian (77.1%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 23.05.01 is


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
  - Andrii Nugged
  - Martin Renvoize
  - Marcel de Rooy
  - Petro Vashchuk

- Topic Experts:
  - UI Design -- Owen Leonard
  - Zebra -- Fridolin Somers
  - REST API -- Martin Renvoize
  - ERM -- Pedro Amorim
  - ILL -- Pedro Amorim

- Bug Wranglers:
  - Aleisha Amohia

- Packaging Manager: Mason James

- Documentation Manager: Aude Charillon

- Documentation Team:
  - Caroline Cyr La Rose
  - Lucy Vaux-Harvey

- Translation Manager: Bernardo González Kriegel


- Wiki curators: 
  - Thomas Dukleth
  - Katrin Fischer

- Release Maintainers:
  - 23.05 -- Fridolin Somers
  - 22.11 -- PTFS Europe (Matt Blenkinsop, Pedro Amorim)
  - 22.05 -- Lucas Gass
  - 21.11 -- Danyon Sewell

- Release Maintainer assistants:
  - 21.11 -- Wainui Witika-Park

## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 23.05.01

- Gothenburg University Library

We thank the following individuals who contributed patches to Koha 23.05.01

- Pedro Amorim (2)
- Tomás Cohen Arazi (13)
- Matt Blenkinsop (2)
- Nick Clemens (10)
- David Cook (1)
- Jonathan Druart (14)
- Lucas Gass (7)
- David Gustafsson (4)
- Mason James (1)
- Owen Leonard (7)
- Martin Renvoize (1)
- Marcel de Rooy (6)
- Fridolin Somers (4)
- Koha translators (1)
- Hammat Wele (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 23.05.01

- Athens County Public Libraries (7)
- BibLibre (4)
- ByWater-Solutions (17)
- Göteborgs Universitet (4)
- Koha Community Developers (14)
- KohaAloha (1)
- Prosentient Systems (1)
- PTFS-Europe (5)
- Rijksmuseum (6)
- Solutions inLibro inc (1)
- Theke Solutions (13)

We also especially thank the following individuals who tested patches
for Koha

- Tomás Cohen Arazi (62)
- Andrew Auld (1)
- Matt Blenkinsop (1)
- Nick Clemens (8)
- David Cook (7)
- Jonathan Druart (6)
- Laura Escamilla (1)
- Katrin Fischer (13)
- Andrew Fuerste-Henry (1)
- Lucas Gass (4)
- Kyle M Hall (6)
- Barbara Johnson (1)
- Sam Lau (6)
- Owen Leonard (3)
- Agustín Moyano (1)
- David Nind (10)
- Andrew Nugged (1)
- Andrii Nugged (1)
- Martin Renvoize (13)
- Marcel de Rooy (14)
- Michaela Sieber (1)
- Fridolin Somers (9)





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 23.05.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 28 Jun 2023 13:14:18.
