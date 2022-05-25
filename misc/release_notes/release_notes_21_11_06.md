# RELEASE NOTES FOR KOHA 21.11.06
25 May 2022

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 21.11.06 can be downloaded from:

- [Download](http://download.koha-community.org/koha-21.11.06.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 21.11.06 is a bugfix/maintenance release.

It includes 2 enhancements, 35 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations




## Enhancements

### Circulation

- [[18392]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18392) Allow exporting circulation conditions as CSV or spreadsheet

### Plugin architecture

- [[30072]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30072) Add more holds hooks

  >This development adds plugin hooks for several holds actions. The hook is called *after_hold_action* and has two parameters
  >
  >* **action**: containing a string that represents the _action_, possible values: _fill_, _cancel_, _suspend_ and _resume_.
  >* **payload**: A hashref containing a _hold_ key, which points to the Koha::Hold object.


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[30540]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30540) Double processing invalid dates can lead to ISE

### Fines and fees

- [[30346]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30346) Editing circ rule with Overdue fines cap (amount) results in data loss and extra fines

### Hold requests

- [[30630]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30630) Checking in a waiting hold at another branch when HoldsAutoFill is enabled causes errors

### Label/patron card printing

- [[24001]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24001) Cannot edit card template

  >This fixes errors that caused creating and editing patron card templates and printer profiles to fail.

### Notices

- [[30354]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30354) AUTO_RENEWALS_DGST notices are not generated if patron set to receive notice via SMS and no SMS notice defined

  >If an SMS notice is not defined for AUTO_RENEWALS_DGST and a patron has selected to receive a digest notification by SMS when items are automatically renewed, it doesn't generate a notice (even though the item(s) is renewed). This fixes the issue so that an email message is generated.

### REST API

- [[30663]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30663) POST /api/v1/suggestions won't honor suggestions limits

### Staff Client

- [[30610]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30610) The 'Print receipt' button on cash management registers page fails on second datatables page

### Tools

- [[30461]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30461) Batch authority tool is broken
- [[30518]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30518) StockRotationItems crossing DST boundary throw invalid local time exception
- [[30628]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30628) Batch borrower modifications only affect the current page

  >This fixes the batch patron modification tool (Tools > Patrons and circulation > Batch patron modification) so that the changes for all selected patrons are modified. Before this, only the patrons listed on the current page were modified.


## Other bugs fixed

### Acquisitions

- [[30599]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30599) Allow archiving multiple suggestions

### Architecture, internals, and plumbing

- [[27253]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27253) borrowers.updated_on cannot be null on fresh install, but can be null with upgrade
- [[29483]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29483) AllowRenewalIfOtherItemsAvailable has poor performance for records with many items
- [[30143]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30143) OAI-PMH provider may end up in an eternal loop due to missing sort

### Cataloging

- [[30224]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30224) Wrong important field shown in cataloguing validation

  **Sponsored by** *Education Services Australia SCIS*

  >This patch fxes the cataloguing validation messages to show the correct tag, when the whole field is important (not just a subfield).
- [[30482]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30482) Potential for bad string concatenation in cataloging validation error message

### Circulation

- [[29537]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29537) Simplify auto-renewal code in CanBookBeRenewed

### Command-line Utilities

- [[10517]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10517) koha-restore fails to create mysqluser@mysql_hostname so zebra update fails

  **Sponsored by** *Reformational Study Centre*

### Database

- [[30449]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30449) Missing FK constraint on borrower_attribute_types
- [[30565]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30565) Field stockrotationrotas.description should be NOT NULL, title UNIQUE
- [[30572]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30572) Field search_marc_to_field.sort needs syncing too
- [[30620]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30620) Add a warning close to /*!VERSION lines in kohastructure.sql

### Installation and upgrade (command-line installer)

- [[30366]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30366) Warn when running automatic_item_modification_by_age.pl

### Installation and upgrade (web-based installer)

- [[20449]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20449) Noise triggered by Archive::Extract during installation

### Notices

- [[30509]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30509) Accordion on letter.tt is broken

### OPAC

- [[30191]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30191) Authority search result list in the OPAC should use 'record' instead of 'biblios'

### Patrons

- [[30405]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30405) Style of address in patron search result are 110%

### REST API

- [[30534]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30534) borrowers.guarantorid not present on database

### Searching - Elasticsearch

- [[29077]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29077) Warns when searching blank index

### Staff Client

- [[29092]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29092) Table settings for account_fines table is missing Updated on column and hides the wrong things

  **Sponsored by** *Koha-Suomi Oy*

### System Administration

- [[30597]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30597) Update wording of RestrictionBlockRenewing to include auto-renew

### Templates

- [[30587]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30587) Incorrect translations in some templates

### Test Suite

- [[30531]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30531) Search.t needs update for Recalls
- [[30595]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30595) update_child_to_adult.t is failing randomly

### Web services

- [[22379]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22379) ILS-DI Method "CancelHold" don't check CanReserveBeCanceledFromOpac



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)



The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (87.4%)
- Armenian (100%)
- Armenian (Classical) (89%)
- Bulgarian (92.5%)
- Chinese (Taiwan) (79.4%)
- Czech (75.2%)
- English (New Zealand) (59.1%)
- English (USA)
- Finnish (92.3%)
- French (95.3%)
- French (Canada) (93.1%)
- German (100%)
- German (Switzerland) (58.8%)
- Greek (60.4%)
- Hindi (100%)
- Italian (100%)
- Nederlands-Nederland (Dutch-The Netherlands) (79.9%)
- Norwegian Bokmål (63.4%)
- Polish (99.2%)
- Portuguese (91.2%)
- Portuguese (Brazil) (83.8%)
- Russian (85.3%)
- Slovak (70.6%)
- Spanish (100%)
- Swedish (82.6%)
- Telugu (95.5%)
- Turkish (100%)
- Ukrainian (75.5%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 21.11.06 is


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
new features in Koha 21.11.06

- Education Services Australia SCIS
- Koha-Suomi Oy
- Reformational Study Centre

We thank the following individuals who contributed patches to Koha 21.11.06

- Tomás Cohen Arazi (8)
- Philippe Blouin (1)
- Rudolf Byker (1)
- Nick Clemens (10)
- Jonathan Druart (5)
- Andrew Fuerste-Henry (1)
- Lucas Gass (1)
- Kyle M Hall (8)
- Owen Leonard (3)
- Ere Maijala (1)
- Julian Maurice (1)
- Martin Renvoize (6)
- Marcel de Rooy (10)
- Fridolin Somers (4)
- Adam Styles (1)
- Arthur Suzuki (2)
- Emmi Takkinen (1)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 21.11.06

- Athens County Public Libraries (3)
- BibLibre (7)
- ByWater-Solutions (20)
- esa.edu.au (1)
- Independant Individuals (1)
- Koha Community Developers (5)
- Koha-Suomi (1)
- PTFS-Europe (6)
- Rijksmuseum (10)
- Solutions inLibro inc (1)
- Theke Solutions (8)
- University of Helsinki (1)

We also especially thank the following individuals who tested patches
for Koha

- Aleisha Amohia (1)
- Tomás Cohen Arazi (6)
- Felicity Brown (1)
- Nick Clemens (6)
- Jonathan Druart (3)
- Katrin Fischer (9)
- Andrew Fuerste-Henry (5)
- Lucas Gass (6)
- Kyle M Hall (55)
- Joonas Kylmälä (3)
- Owen Leonard (8)
- David Nind (8)
- Laurence Rault (1)
- Martin Renvoize (22)
- Alexis Ripetti (1)
- Marcel de Rooy (9)
- Fridolin Somers (45)
- Petro Vashchuk (1)



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

Autogenerated release notes updated last on 25 May 2022 15:56:22.
