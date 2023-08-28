# RELEASE NOTES FOR KOHA 22.11.09
28 ago 2023

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 22.11.09 can be downloaded from:

- [Download](http://download.koha-community.org/koha-22.11.09.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 22.11.09 is a bugfix/maintenance release.

It includes 3 enhancements, 40 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [30524](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30524) Add base framework for dealing with CSRF in Koha
- [33881](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33881) SCO/SCI user leaving the module doesn't clear session (ie JWT)

## Bugfixes

### Acquisitions

#### Critical bugs fixed

- [34469](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34469) Modifying an order line of a standing order will delete linked invoice ID

#### Other bugs fixed

- [34305](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34305) If actual cost is negative, wrong price will display in the acq details tab
- [34452](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34452) Button 'Update adjustments' is hidden

### Architecture, internals, and plumbing

#### Critical bugs fixed

- [34193](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34193) Default HTTPS template has outdated SSLProtocol value

#### Other bugs fixed

- [34056](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34056) authorised-values API client file is missing -api-client suffix

  **Sponsored by** *Bibliothèque Universitaire des Langues et Civilisations (BULAC)*
- [34316](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34316) account->add_credit does not rethrow exception
- [34354](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34354) Job progress typo
- [34470](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34470) Real Time Holds Queue - make random numbers play nice with forked processes

### Authentication

#### Critical bugs fixed

- [34028](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34028) Two factor authentication (2FA) shows the wrong values for manual entry
  >This fixes the details displayed for manually entering two-factor authentication (2FA) details into a 2FA application (when enabling 2FA). Currently, the wrong information is displayed - so you can't successfully add the account manually to your 2FA application.

### Cataloging

#### Other bugs fixed

- [33755](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33755) Profile used is not saved when importing records

### Circulation

#### Critical bugs fixed

- [34279](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34279) overduefinescap of 0 is ignored, but overduefinescap of 0.00 is enforced

#### Other bugs fixed

- [33992](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33992) Only consider the date when labelling a waiting recall as problematic

  **Sponsored by** *Auckland University of Technology*
- [34289](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34289) UI issue on checkin page when checking the forgive fines checkbox

### ERM

#### Other bugs fixed

- [34447](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34447) "Actions" columns are exported

  **Sponsored by** *Bibliothèque Universitaire des Langues et Civilisations (BULAC)*

### Fines and fees

#### Critical bugs fixed

- [32271](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32271) Overdue fines cap (amount) set to 0.00 when editing rule
- [33028](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33028) Wrongly formatted monetary amounts in circulation rules break scripts and calculations

#### Other bugs fixed

- [34332](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34332) Syntax error in point of sale email template

### Hold requests

#### Other bugs fixed

- [30846](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30846) "If any unavailable" doesn't consider negative notforloan values as unavailable

### I18N/L10N

#### Other bugs fixed

- [34334](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34334) 'Item(s)' in MARC detail view untranslatable

### ILL

#### Other bugs fixed

- [34133](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34133) ILL table should be sorted by request id descending by default

### Installation and upgrade (web-based installer)

#### Critical bugs fixed

- [34337](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34337) Web installer doesn't install patrons when select all is used

### MARC Authority data support

#### Other bugs fixed

- [33978](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33978) Adding authority from automatic linker closes imported record

### Notices

#### Other bugs fixed

- [34059](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34059) advance_notices.pl -c --digest-per-branch does not work as intended

### OPAC

#### Critical bugs fixed

- [34155](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34155) OPAC item level holds "force" option broken

#### Other bugs fixed

- [33848](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33848) Enabling Coce in the OPAC breaks cover images on bibliographic detail page

### Patrons

#### Other bugs fixed

- [33117](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33117) Patron checkout search not working if searching with second surname
- [34117](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34117) Duplicate patron sets dateenrolled incorrectly
- [34435](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34435) get_password_expiry_date should not modify its parameter

### REST API

#### Critical bugs fixed

- [34024](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34024) REST API should not allow changing the pickup location on found holds

#### Other bugs fixed

- [34365](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34365) Hold cancellation request workflow cannot be triggered on API
- [34387](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34387) API docs tags missing descriptions

### Searching

#### Other bugs fixed

- [33140](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33140) Use facet label value in mouseover title attribute of facet removal link

### Serials

#### Critical bugs fixed

- [30451](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30451) Delete a subscription deletes the linked order

### System Administration

#### Critical bugs fixed

- [34269](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34269) Regression in circulation rules for 'similar' patron categories

### Templates

#### Other bugs fixed

- [31667](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31667) Merge 'tip' and 'hint' classes
- [34343](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34343) Z39.50 search background not updated
- [34493](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34493) Bad indenting in search_indexes.inc

### Tools

#### Critical bugs fixed

- [34181](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34181) Batch patron modification tool missing checkboxes to clear field values

## Enhancements 

### Command-line Utilities

#### Enhancements

- [34213](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34213) False POD for matchpoint option in import_patrons.pl

### Packaging

#### Enhancements

- [28493](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28493) Make koha-passwd display the username

### REST API

#### Enhancements

- [32739](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32739) REST API: Extend endpoint /auth/password/validation for cardnumber
  >This development adds a new attribute for identifying the patron for password validation: `identifier`. It expects to be passed a `userid` or a `cardnumber` in it. It the `identifier` doesn't match a `userid`, then Koha will try matching a `cardnumber`.

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Chinese (Taiwan)](https://koha-community.org/manual/22.11/zh_TW/html/) (71.5%)
- [English (USA)](https://koha-community.org/manual/22.11/en/html/)
- [French](https://koha-community.org/manual/22.11/fr/html/) (58.4%)
- [German](https://koha-community.org/manual/22.11/de/html/) (55.7%)
- [Hindi](https://koha-community.org/manual/22.11/hi/html/) (80.9%)
- [Italian](https://koha-community.org/manual/22.11/it/html/) (32.2%)
- [Turkish](https://koha-community.org/manual/22.11/tr/html/) (26.2%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (71.8%)
- Armenian (100%)
- Armenian (Classical) (64.6%)
- Bulgarian (90.9%)
- Chinese (Taiwan) (81.4%)
- Czech (62.2%)
- English (New Zealand) (68.2%)
- English (USA)
- English (United Kingdom) (99.7%)
- Finnish (96.7%)
- French (100%)
- French (Canada) (95.5%)
- German (100%)
- German (Switzerland) (50.2%)
- Greek (51.6%)
- Hindi (100%)
- Italian (91.7%)
- Nederlands-Nederland (Dutch-The Netherlands) (90.3%)
- Norwegian Bokmål (65.3%)
- Persian (70.2%)
- Polish (100%)
- Portuguese (89.6%)
- Portuguese (Brazil) (100%)
- Russian (93.4%)
- Slovak (61.8%)
- Spanish (99.7%)
- Swedish (79.5%)
- Telugu (77%)
- Turkish (87.1%)
- Ukrainian (77.8%)
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

The release team for Koha 22.11.09 is


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
new features in Koha 22.11.09
<div style="column-count: 2;">

- Auckland University of Technology
- [Bibliothèque Universitaire des Langues et Civilisations (BULAC)](http://www.bulac.fr)
</div>

We thank the following individuals who contributed patches to Koha 22.11.09
<div style="column-count: 2;">

- Aleisha Amohia (1)
- Pedro Amorim (5)
- Tomás Cohen Arazi (14)
- Matt Blenkinsop (1)
- David Cook (3)
- Jonathan Druart (6)
- Laura Escamilla (1)
- Katrin Fischer (11)
- Géraud Frappier (1)
- Thibaud Guillot (1)
- Kyle M Hall (3)
- Mason James (1)
- Andreas Jonsson (1)
- Emily Lamancusa (5)
- Owen Leonard (5)
- Julian Maurice (1)
- Martin Renvoize (14)
- Marcel de Rooy (1)
- Fridolin Somers (2)
- Koha translators (1)
- Hammat Wele (3)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 22.11.09
<div style="column-count: 2;">

- Athens County Public Libraries (5)
- BibLibre (4)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (11)
- ByWater-Solutions (4)
- Catalyst Open Source Academy (1)
- Koha Community Developers (6)
- KohaAloha (1)
- Kreablo AB (1)
- montgomerycountymd.gov (5)
- Prosentient Systems (3)
- PTFS-Europe (20)
- Rijksmuseum (1)
- Solutions inLibro inc (4)
- Theke Solutions (14)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Pedro Amorim (73)
- Tomás Cohen Arazi (62)
- Matt Blenkinsop (3)
- Emmanuel Bétemps (1)
- Nick Clemens (5)
- Jonathan Druart (5)
- Magnus Enger (1)
- Laura Escamilla (1)
- Katrin Fischer (29)
- Andrew Fuerste-Henry (2)
- Lucas Gass (2)
- Amaury GAU (1)
- Stephen Graham (1)
- Victor Grousset (2)
- Kyle M Hall (2)
- Emily Lamancusa (2)
- Sam Lau (12)
- Owen Leonard (3)
- David Nind (4)
- Martin Renvoize (17)
- Phil Ringnalda (1)
- Marcel de Rooy (5)
- Caroline Cyr La Rose (3)
- Lisette Scheer (1)
- Michaela Sieber (3)
- Fridolin Somers (71)
- Anneli Österman (1)
</div>





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

Autogenerated release notes updated last on 28 ago 2023 13:09:57.
