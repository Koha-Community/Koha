# RELEASE NOTES FOR KOHA 21.11.05
26 Apr 2022

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 21.11.05 can be downloaded from:

- [Download](http://download.koha-community.org/koha-21.11.05.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 21.11.05 is a bugfix/maintenance release.

It includes 5 enhancements, 57 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations




## Enhancements

### Hold requests

- [[29517]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29517) CanItemBeReserved fetches biblio for agerestriction check if feature not enabled

### I18N/L10N

- [[22038]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22038) When exporting account table to excel, decimal is lost
- [[29596]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29596) Add Yiddish language

  >This enhancement adds the Yiddish (יידיש) language to Koha. Yiddish now appears as an option for refining search results in the staff interface advanced search (Search > Advanced search > More options > Language and Language of original) and the OPAC (Advanced search > More options > Language).

### Plugin architecture

- [[29787]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29787) Add plugin version to plugin search results

### Templates

- [[30212]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30212) Make Select2 available for ILL backend developers


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[29684]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29684) Warning File not found: js/locale_data.js
- [[30004]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30004) Prevent TooMany from executing too many SQL queries
- [[30172]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30172) Background jobs failing due to race condition

### Circulation

- [[30114]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30114) Koha offline circulation will always cancel the next hold when issuing item to a patron
- [[30222]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30222) Auto_renew_digest still sends every day when renewals are not allowed
- [[30251]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30251) With IndependentBranches non-superlibrarians do not get autocomplete list in circulation module

### Fines and fees

- [[30003]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30003) Register entries doubled up if form fails validation on first submission

### Hold requests

- [[30266]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30266) Holds marked waiting with a holdingbranch that does not match can cause loss of pickup locations
- [[30432]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30432) get_items_that_can_fill needs to specify table for biblionumbers
- [[30583]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30583) Hold system broken for translated template

### ILL

- [[30183]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30183) ILL table search filtering broken

### Patrons

- [[30325]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30325) (Bug 30098 follow-up) Broken patron search redirect when one result

### REST API

- [[30165]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30165) Several q parameters break the filters

### Reports

- [[30532]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30532) guided_reports.pl has a problem

### Searching - Elasticsearch

- [[28610]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28610) Elasticsearch 7 - hits.total is now an object

  **Sponsored by** *Lund University Library*

  >This is one of the changes to have Koha compatible with ElasticSearch 7. This one also causes the full end of compatibility with ElasticSearch 5. Users are advised to upgrade as soon as possible to ElasticSearch 7 since version 5 and 6 are not supported anymore by their developers.
- [[29893]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29893) ElasticSearch Config UI deletes mappings
- [[30584]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30584) Cannot add field mappings to Elasticsearch configuration

### Self checkout

- [[30199]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30199) self checkout login by cardnumber is broken if you input a non-existent cardnumber

### Templates

- [[30525]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30525) Items batch modification broken

### Test Suite

- [[19169]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19169) Add a test to detect unneeded 'atomicupdate' files

### Tools

- [[30402]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30402) Authority import hanging when replacing matched record

  **Sponsored by** *Educational Services Australia SCIS*


## Other bugs fixed

### Architecture, internals, and plumbing

- [[29957]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29957) Cookies not removed after logout

  >This patch adds a new config variable to koha-conf.xml called do_not_remove_cookie.
  >By default, all cookies are cleared now. But you could uncomment the KohaOpacLanguage entry to preserve it.
- [[30008]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30008) Software error in details.pl when invalid MARCXML and showing component records
- [[30110]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30110) Potential bug source: plenty of "my" declarations with conditional assignments
- [[30161]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30161) Remove duplicate z3950_search include lines
- [[30253]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30253) Double mana_success line is no success
- [[30377]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30377) Fix two CGI::param called in list context-warnings
- [[30393]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30393) datatables wrapper should handle searching for %, _ and \
- [[30406]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30406) Our DT tables not filtering on the correct column if hidden by default

### Cataloging

- [[25251]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25251) When a record has no items click delete all does not need an alert
- [[26328]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26328) incremental barcode generation fails when incorrectly converting strings to numbers
- [[30159]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30159) Fix display of validation of important fields when biblio cataloguing

  **Sponsored by** *Education Services Australia SCIS*

  >This patch adds a check for both mandatory and important fields when validating bibliographic records during cataloguing.
- [[30376]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30376) Unable to save item if field date acquired is set mandatory

### Circulation

- [[30155]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30155) We shouldn't calculate get_items_that_can_fill when we don't have any holds

### Command-line Utilities

- [[29501]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29501) gather_print_notices.pl does not use SMTP servers

### Database

- [[30481]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30481) Drop unique constraint deleteditemsstocknumberidx for deleteditems
- [[30498]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30498) Enum search_field.type should contain year in kohastructure

### Hold requests

- [[29103]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29103) reserves.desk_id for desk of waiting hold only updates when printing new hold slip

### Notices

- [[17648]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17648) ACCTDETAILS notice doesn't show in the notices tab in staff

### OPAC

- [[29802]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29802) biblionumber in OPACHiddenItems breaks opac lists
- [[30220]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30220) Purchase suggestion defaults to first library
- [[30244]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30244) Hide lost items not respected in OPAC results XSLT
- [[30426]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30426) suggestion service missing Auth and Output imports

### Packaging

- [[26685]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26685) Move Starman out of debian/control.in and into cpanfile
- [[30252]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30252) lower version of 'Locale::XGettext::TT2' to 0.6

### Patrons

- [[27812]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27812) Remove the ability to transmit a patron's plain text password over email

  >This bugfix/enhancement improves the default security of Koha by removing the pass of the plain text password to the ACCTDETAILS notice on patron creation.
  >
  >WARNING: You will need to update your notice template if you were relying on `<<borrowers.password>>` in this notice.
- [[29576]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29576) Add street type to fields which can be copied from guarantor to guarantee
- [[30175]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30175) Digest options not enabled when populating messaging preferences for a selected category during patron entry
- [[30177]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30177) When changing patron categories of existing accounts it should not reset message prefs without warning
- [[30214]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30214) Send ACCTDETAILS notice for new patrons added via self registration

### Plugin architecture

- [[25285]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25285) Wrong message when plugin required Koha version isn't met

### Reports

- [[26669]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26669) Last Run column not updated when report is run publicly (via CoverFlow or elsewhere)
- [[30282]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30282) Overdues report does not display subtitle and other information

### SIP2

- [[30118]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30118) holds_block_checkin behavior is different in Koha and in SIP

### Searching - Elasticsearch

- [[30142]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30142) ElasticSearch MARC mappings should not accept whitespaces

  **Sponsored by** *Steiermärkische Landesbibliothek*

### System Administration

- [[30107]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30107) When editing a desk, the currently logged in library is selected

  >Corrects a problem on the administration page for circulation desks where the default library was always being set to the logged in library instead of the library of the desk.

### Templates

- [[29940]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29940) Phase out jquery.cookie.js in the OPAC



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
- Bulgarian (92.2%)
- Chinese (Taiwan) (79.5%)
- Czech (69.1%)
- English (New Zealand) (59.1%)
- English (USA)
- Finnish (92.3%)
- French (94.7%)
- French (Canada) (93.2%)
- German (100%)
- German (Switzerland) (58.8%)
- Greek (60%)
- Hindi (99.9%)
- Italian (100%)
- Nederlands-Nederland (Dutch-The Netherlands) (77.2%)
- Norwegian Bokmål (63.4%)
- Polish (99.3%)
- Portuguese (91.1%)
- Portuguese (Brazil) (83.8%)
- Russian (85.4%)
- Slovak (69.9%)
- Spanish (100%)
- Swedish (82.1%)
- Telugu (95.5%)
- Turkish (98.2%)
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

The release team for Koha 21.11.05 is


- Release Manager: Fridolin Somers

- Release Manager assistants:
  - Jonathan Druart
  - Martin Renvoize
  - Tomás Cohen Arazi

- QA Manager: Katrin Fischer

- QA Team:
  - Andrew Nugged
  - Jonathan Druart
  - Joonas Kylmälä
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
  - Zebra -- Fridolin Somers
  - Accounts -- Martin Renvoize

- Bug Wranglers:
  - Indranil Das Gupta
  - Erica Rohlfs

- Packaging Manager: 
  - Mason James


- Documentation Manager: David Nind


- Documentation Team:
  - Aude Charillon
  - Caroline Cyr La Rose
  - Kelly McElligott
  - Lucy Vaux-Harvey
  - Martin Renvoize
  - Rocio Lopez

- Translation Managers: 
  - Bernardo González Kriegel

- Wiki curators: 
  - Thomas Dukleth

- Release Maintainers:
  - 21.11 -- Kyle M Hall
  - 21.05 -- Andrew Fuerste-Henry
  - 20.11 -- Victor Grousset
  - 19.11 -- Wainui Witika-Park

## Credits
We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 21.11.05

- Education Services Australia SCIS
- Educational Services Australia SCIS
- Lund University Library
- Steiermärkische Landesbibliothek

We thank the following individuals who contributed patches to Koha 21.11.05

- Aleisha Amohia (1)
- Tomás Cohen Arazi (12)
- Philippe Blouin (1)
- Kevin Carnes (1)
- Nick Clemens (17)
- David Cook (3)
- Jake Deery (1)
- Jonathan Druart (18)
- Katrin Fischer (3)
- Lucas Gass (2)
- Didier Gautheron (2)
- Kyle M Hall (14)
- Mason James (3)
- Janusz Kaczmarek (1)
- Thomas Klausner (1)
- Nicolas Legrand (1)
- Owen Leonard (3)
- Julian Maurice (2)
- Matthias Meusburger (1)
- Andrew Nugged (3)
- Martin Renvoize (6)
- Marcel de Rooy (12)
- Fridolin Somers (3)
- Adam Styles (2)
- Koha translators (1)
- Petro Vashchuk (3)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 21.11.05

- Athens County Public Libraries (3)
- BibLibre (8)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (3)
- Bibliothèque Universitaire des Langues et Civilisations (BULAC) (1)
- ByWater-Solutions (33)
- Catalyst Open Source Academy (1)
- esa.edu.au (2)
- Independant Individuals (8)
- Koha Community Developers (18)
- KohaAloha (3)
- Prosentient Systems (3)
- PTFS-Europe (7)
- Rijksmuseum (12)
- Solutions inLibro inc (1)
- Theke Solutions (12)
- ub.lu.se (1)

We also especially thank the following individuals who tested patches
for Koha

- Tomás Cohen Arazi (12)
- Florian Bontemps (1)
- Sonia Bouis (1)
- Nick Clemens (24)
- Jonathan Druart (40)
- Katrin Fischer (13)
- Andrew Fuerste-Henry (6)
- Lucas Gass (6)
- Victor Grousset (2)
- Amit Gupta (1)
- hakam (1)
- Kyle M Hall (100)
- Sally Healey (1)
- Mason James (1)
- Joonas Kylmälä (1)
- Owen Leonard (12)
- The Minh Luong (1)
- Marjorie (1)
- Julian Maurice (1)
- David Nind (4)
- Séverine Queune (7)
- Johanna Raisa (1)
- Martin Renvoize (36)
- Marcel de Rooy (5)
- Fridolin Somers (103)



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

Autogenerated release notes updated last on 26 Apr 2022 17:52:56.
