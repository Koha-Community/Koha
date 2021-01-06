# RELEASE NOTES FOR KOHA 20.11.01
06 janv. 2021

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 20.11.01 can be downloaded from:

- [Download](http://download.koha-community.org/koha-20.11.01.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 20.11.01 is a bugfix/maintenance release.

It includes 45 bugfixes.

### System requirements

Koha is continuously tested against the following configurations and as such these are the recommendations for 
deployment: 

Operating system:
- Debian 10
- Debian 9
- Ubuntu 20.04
- Ubuntu 18.04
- Ubuntu 16.04
- Ubuntu 20.10 (experimental)
- Debian 11 (experimental)

Database:
- MariaDB 10.3
- MariaDB 10.1

Search engine:
- ElasticSearch 6
- Zebra

Perl:
- Perl >= 5.14 is required and 5.24, 5.26, 5.28 or 5.30 are recommended. These are the versions of the recommended operating systems.






## Critical bugs fixed

### Command-line Utilities

- [[27276]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27276) borrowers-force-messaging-defaults throws Incorrect DATE value: '0000-00-00' even though sql strict mode is dissabled

### Database

- [[24658]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24658) Deleting items with fines does not update itemnumber in accountlines to NULL causing ISE
- [[27003]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27003) action_logs table error when adding an item

### Hold requests

- [[26634]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26634) Hold rules applied incorrectly when All Libraries rules are more specific than branch rules
- [[27205]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27205) Hold routes are not dealing with invalid pickup locations

### OPAC

- [[24398]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24398) Error when viewing single news item and NewsAuthorDisplay pref set to OPAC
- [[27148]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27148) Internal Server Error during self registration 20.11

  >This fixes a bug when using self registration and there is no patron category available for selection in the registration form.
- [[27200]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27200) "Browse search" is broken

### Patrons

- [[27004]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27004) Deleting a staff account who have created claims returned causes problem in the return_claims table because of a NULL value in return_claims.created_by.
- [[27144]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27144) Cannot delete any patrons

### Reports

- [[27142]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27142) Patron batch update from report module - no patrons loaded into view

  >This fixes an error when batch modifying patrons using the reports module. After running a report (such as SELECT * FROM borrowers LIMIT 50) and selecting batch modification an error was displayed: "Warning, the following cardnumbers were not found:", and you were not able to modify any patrons.

### SIP2

- [[27166]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27166) SIP2 Connection is killed when an item that was not issued is checked in and generates a transfer
- [[27196]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27196) Waiting title level hold checked in at wrong location via SIP leaves hold in a broken state and drops connection

### Searching - Zebra

- [[12430]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12430) Relevance ranking should also be used without QueryWeightFields system preference

### Staff Client

- [[27256]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27256) "Add" button on point of sale page fails on table paging

### Templates

- [[27124]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27124) JS error "select2Width is not defined"

### Test Suite

- [[27055]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27055) Update Firefox version used in Selenium GUI tests

### Web services

- [[26665]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26665) OAI 'Set' and 'Metadata' dropdowns broken

  >With OAI-PMH enabled, if you clicked on Sets or Metadata in the search results no additional information was displayed (example query: <OPACBaseURL>/cgi-bin/koha/oai.pl?verb=ListRecords&metadataPrefix=marc21). This patch fixes this so that the additional information for Sets and Metadata is now correctly displayed.


## Other bugs fixed

### Acquisitions

- [[26905]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26905) Purchase suggestion button hidden for users with suggestion permission but not acq permission

### Architecture, internals, and plumbing

- [[16067]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16067) Koha::Cache, fastmmap caching system is broken
- [[26849]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26849) Fix Array::Utils dependency in cpanfile
- [[27030]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27030) The new "Processing" hold status is missing in C4::Reserves module documentation
- [[27209]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27209) Add Koha::Hold->set_pickup_location
- [[27331]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27331) fr-FR/1-Obligatoire/authorised_values.sql is invalid

### Cataloging

- [[22243]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22243) Advanced Cataloguer editor fails if the target contains an apostrophe in the name
- [[26921]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26921) Create cover image even when there is no record identificator

  **Sponsored by** *Orex Digital*
- [[27128]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27128) Follow-up to bug 25728 - Don't prefill av's code

### Circulation

- [[25583]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25583) When ClaimReturnedLostValue is not set, the claim returned tab doesn't appear
- [[27133]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27133) Header missing for "Copy no" on the relative's checkouts table

### Command-line Utilities

- [[14564]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14564) Incorrect permissions prevent web download of configuration backups

### Database

- [[17809]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17809) Correct some authorised values in fr-FR

### Fines and fees

- [[24519]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24519) Change calculation and validation in Point of Sale should match Paycollect

### Hold requests

- [[26976]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26976) When renewalsallowed is empty the UI is not correct
- [[27117]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27117) Staff without modify_holds_priority permission can't update hold pick-up from biblio

### MARC Bibliographic record staging/import

- [[27099]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27099) Stage for import button not showing up

### OPAC

- [[26941]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26941) Missing OPAC password recovery error messages
- [[27230]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27230) purchase suggestion authorized value opac_sug doesn't show opac description

### Patrons

- [[26956]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26956) Allow "Show checkouts/fines to guarantor" to be set without a guarantor saved

### Staff Client

- [[23475]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23475) Search context is lost when simple search leads to a single record
- [[26946]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26946) Limit size of cash register's name on the UI

### System Administration

- [[27250]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27250) DELETE calls are stacked on the SMTP servers admin page

### Task Scheduler

- [[27127]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27127) Wrong display of messages if there was only 1 record modified

### Test Suite

- [[27317]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27317) (Bug 27127 follow-up) fix t/db_dependent/Koha/BackgroundJobs.t

### Tools

- [[26336]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26336) Cannot import items if items ignored when staging
- [[27247]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27247) Missing highlighting in Quote of the day


## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:

- [English](http://koha-community.org/manual/20.11/en/html/)
- [Arabic](http://koha-community.org/manual/20.11/ar/html/)
- [Chinese - Taiwan](http://koha-community.org/manual/20.11/zh_TW/html/)
- [Czech](http://koha-community.org/manual/20.11/cs/html/)
- [French](http://koha-community.org/manual/20.11/fr/html/)
- [French (Canada)](http://koha-community.org/manual/20.11/fr_CA/html/)
- [German](http://koha-community.org/manual/20.11/de/html/)
- [Hindi](http://koha-community.org/manual/20.11/hi/html/)
- [Italian](http://koha-community.org/manual/20.11/it/html/)
- [Portuguese - Brazil](http://koha-community.org/manual/20.11/pt_BR/html/)
- [Spanish](http://koha-community.org/manual/20.11/es/html/)
- [Turkish](http://koha-community.org/manual/20.11/tr/html/)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (89.2%)
- Armenian (100%)
- Armenian (Classical) (89%)
- Chinese (Taiwan) (85.7%)
- Czech (73.6%)
- English (New Zealand) (60%)
- English (USA)
- Finnish (78.9%)
- French (73.5%)
- French (Canada) (91.4%)
- German (100%)
- German (Switzerland) (67.4%)
- Greek (61%)
- Hindi (95.8%)
- Italian (100%)
- Norwegian Bokmål (63.9%)
- Polish (70.8%)
- Portuguese (77.9%)
- Portuguese (Brazil) (88.7%)
- Slovak (81.2%)
- Spanish (94.9%)
- Swedish (75.3%)
- Telugu (80.3%)
- Turkish (87.8%)
- Ukrainian (61.9%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 20.11.01 is


- Release Manager: Jonathan Druart

- Release Manager assistants:
  - Martin Renvoize
  - Tomás Cohen Arazi

- QA Manager: Katrin Fischer

- QA Team:
  - David Cook
  - Agustín Moyano
  - Martin Renvoize
  - Marcel de Rooy
  - Joonas Kylmälä
  - Julian Maurice
  - Tomás Cohen Arazi
  - Josef Moravec
  - Nick Clemens
  - Kyle Hall
  - Victor Grousset

- Topic Experts:
  - UI Design -- Owen Leonard
  - REST API -- Tomás Cohen Arazi
  - Zebra -- Fridolin Somers
  - Accounts -- Martin Renvoize

- Bug Wranglers:
  - Amit Gupta
  - Mengü Yazıcıoğlu
  - Indranil Das Gupta

- Packaging Managers:
  - David Cook
  - Mason James
  - Agustín Moyano

- Documentation Manager: Caroline Cyr La Rose


- Documentation Team:
  - Marie-Luce Laflamme
  - Lucy Vaux-Harvey
  - Henry Bolshaw
  - David Nind

- Translation Managers: 
  - Indranil Das Gupta
  - Bernardo González Kriegel

- Release Maintainers:
  - 20.11 -- Fridolin Somers
  - 20.05 -- Andrew Fuerste-Henry
  - 19.11 -- Victor Grousset

## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 20.11.01:

- Orex Digital

We thank the following individuals who contributed patches to Koha 20.11.01.

- Tomás Cohen Arazi (7)
- Nick Clemens (9)
- David Cook (2)
- Jonathan Druart (27)
- Victor Grousset (2)
- Kyle M Hall (1)
- Andrew Isherwood (1)
- Joonas Kylmälä (1)
- Owen Leonard (4)
- Julian Maurice (1)
- Josef Moravec (1)
- Agustín Moyano (2)
- Martin Renvoize (3)
- Fridolin Somers (5)
- Mirko Tietgen (1)
- Mark Tompsett (1)
- Koha Translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 20.11.01

- Athens County Public Libraries (4)
- BibLibre (6)
- ByWater-Solutions (10)
- Independant Individuals (2)
- Koha Community Developers (29)
- Mirko Tietgen (1)
- Prosentient Systems (2)
- PTFS-Europe (4)
- Theke Solutions (9)
- University of Helsinki (1)

We also especially thank the following individuals who tested patches
for Koha.

- Tomás Cohen Arazi (5)
- Nick Clemens (9)
- David Cook (2)
- Chris Cormack (1)
- Jonathan Druart (40)
- Katrin Fischer (3)
- Andrew Fuerste-Henry (1)
- Brendan Gallagher (2)
- Lucas Gass (8)
- Victor Grousset (26)
- Kyle M Hall (11)
- Sally Healey (2)
- Luke Honiss (1)
- Mason James (2)
- Joonas Kylmälä (1)
- Owen Leonard (1)
- Julian Maurice (3)
- Kelly McElligott (2)
- Josef Moravec (9)
- David Nind (7)
- Martin Renvoize (10)
- Fridolin Somers (58)
- Mark Tompsett (1)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/Koha-community/Koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 20.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 06 janv. 2021 16:24:16.
