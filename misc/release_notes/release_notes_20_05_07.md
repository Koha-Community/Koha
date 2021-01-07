# RELEASE NOTES FOR KOHA 20.05.07
07 Jan 2021

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 20.05.07 can be downloaded from:

- [Download](http://download.koha-community.org/koha-20.05.07.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 20.05.07 is a bugfix/maintenance release.

It includes 2 enhancements, 53 bugfixes.

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

- [[27002]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27002) Make Koha::Biblio->pickup_locations return a Koha::Libraries resultset

### MARC Authority data support

- [[25313]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25313) Add optional skip_merge parameter to ModAuthority


## Critical bugs fixed

### Acquisitions

- [[18267]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18267) Update price and tax fields in EDI to reflect DB changes
- [[27082]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27082) Problem when a basket has more of 20 orders with uncertain price

### Architecture, internals, and plumbing

- [[27252]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27252) ES5 no longer supported (since 20.11.00)

  >This prepares Koha to officially no longer support Elasticsearch 5.X.
  >
  >It adds a new system preference 'ElasticsearchCrossFields' to allow users to choose whether or not to enable this feature.

### Cataloging

- [[26518]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26518) Adding a record can succeed even if adding the biblioitem fails

### Command-line Utilities

- [[27276]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27276) borrowers-force-messaging-defaults throws Incorrect DATE value: '0000-00-00' even though sql strict mode is dissabled

### Fines and fees

- [[26536]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26536) "Writeoff/Pay selected" deducts from old unpaid debts first
- [[27079]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27079) UpdateFine adds refunds for fines paid off before return

### Hold requests

- [[27205]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27205) Hold routes are not dealing with invalid pickup locations

### MARC Bibliographic record staging/import

- [[26854]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26854) stage-marc-import.pl does not properly fork

### Patrons

- [[27004]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27004) Deleting a staff account who have created claims returned causes problem in the return_claims table because of a NULL value in return_claims.created_by.
- [[27144]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27144) Cannot delete any patrons

### Reports

- [[25942]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25942) Batch biblio and borrower operations on report results should not concatenate biblio/cardnumbers into a single string
- [[27142]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27142) Patron batch update from report module - no patrons loaded into view

  >This fixes an error when batch modifying patrons using the reports module. After running a report (such as SELECT * FROM borrowers LIMIT 50) and selecting batch modification an error was displayed: "Warning, the following cardnumbers were not found:", and you were not able to modify any patrons.

### SIP2

- [[27166]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27166) SIP2 Connection is killed when an item that was not issued is checked in and generates a transfer

### Searching

- [[7607]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7607) Advanced search: Index and search term don't match when leaving fields empty

### Searching - Elasticsearch

- [[26903]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26903) Authority records not being indexed in Elasticsearch
- [[27070]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27070) Elasticsearch - with Elasticsearch 6 searches failing unless all terms are in the same field

### Searching - Zebra

- [[12430]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12430) Relevance ranking should also be used without QueryWeightFields system preference

### Serials

- [[26992]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26992) On serial collection page, impossible to delete issues and related items

### Staff Client

- [[27256]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27256) "Add" button on point of sale page fails on table paging

### Test Suite

- [[27055]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27055) Update Firefox version used in Selenium GUI tests

### Tools

- [[26516]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26516) Importing records with unexpected format of copyrightdate fails


## Other bugs fixed

### About

- [[27108]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27108) Update team for 21.05 cycle

### Acquisitions

- [[26905]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26905) Purchase suggestion button hidden for users with suggestion permission but not acq permission

### Architecture, internals, and plumbing

- [[16067]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16067) Koha::Cache, fastmmap caching system is broken
- [[26849]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26849) Fix Array::Utils dependency in cpanfile
- [[27021]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27021) Chaining on Koha::Objects->empty should always return an empty resultset
- [[27092]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27092) Remove note about "synced mirror" from the README.md
- [[27209]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27209) Add Koha::Hold->set_pickup_location

### Cataloging

- [[22243]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22243) Advanced Cataloguer editor fails if the target contains an apostrophe in the name

### Circulation

- [[25583]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25583) When ClaimReturnedLostValue is not set, the claim returned tab doesn't appear

### Command-line Utilities

- [[14564]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14564) Incorrect permissions prevent web download of configuration backups
- [[26337]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26337) Remove unused authorities script should skip merge

### Fines and fees

- [[24519]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24519) Change calculation and validation in Point of Sale should match Paycollect

### Hold requests

- [[26976]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26976) When renewalsallowed is empty the UI is not correct
- [[26988]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26988) Defer loading the hold pickup locations until the dropdown is selected
- [[27117]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27117) Staff without modify_holds_priority permission can't update hold pick-up from biblio

### MARC Bibliographic record staging/import

- [[27099]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27099) Stage for import button not showing up

### OPAC

- [[27230]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27230) purchase suggestion authorized value opac_sug doesn't show opac description

### Packaging

- [[25548]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25548) Package install Apache performs unnecessary redirects

### Patrons

- [[14708]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14708) The patron set as the anonymous patron should not be deletable
- [[26956]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26956) Allow "Show checkouts/fines to guarantor" to be set without a guarantor saved

### Serials

- [[26846]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26846) serial-collections page should select the expected and late serials automatically

### Staff Client

- [[23475]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23475) Search context is lost when simple search leads to a single record
- [[26938]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26938) Prevent flash of unstyled content on sales table
- [[26944]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26944) Help link from automatic item modification by age should go to the relevant part of the manual
- [[26946]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26946) Limit size of cash register's name on the UI

### Test Suite

- [[25514]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25514) REST/Plugin/Objects.t is failing randomly
- [[26984]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26984) Tests are failing if AnonymousPatron is configured
- [[26986]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26986) Second try to prevent Selenium's StaleElementReferenceException
- [[27007]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27007) GetMarcSubfieldStructure called with "unsafe" in tests

### Tools

- [[26336]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26336) Cannot import items if items ignored when staging
- [[27247]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27247) Missing highlighting in Quote of the day
## New sysprefs

- ElasticsearchCrossFields

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

- Arabic (99.1%)
- Armenian (100%)
- Armenian (Classical) (99.7%)
- Chinese (Taiwan) (94.5%)
- Czech (81%)
- English (New Zealand) (67%)
- English (USA)
- Finnish (70.8%)
- French (81.9%)
- French (Canada) (96.8%)
- German (100%)
- German (Switzerland) (74.7%)
- Greek (62.3%)
- Hindi (100%)
- Italian (100%)
- Norwegian Bokmål (71.4%)
- Polish (73.8%)
- Portuguese (87.2%)
- Portuguese (Brazil) (98.4%)
- Russian (80%)
- Slovak (90.1%)
- Spanish (100%)
- Swedish (80%)
- Telugu (90%)
- Turkish (100%)
- Ukrainian (66.6%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 20.05.07 is


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

We thank the following individuals who contributed patches to Koha 20.05.07.

- Tomás Cohen Arazi (14)
- Philippe Blouin (1)
- Colin Campbell (1)
- Nick Clemens (23)
- David Cook (4)
- Frédéric Demians (1)
- Jonathan Druart (26)
- Andrew Fuerste-Henry (5)
- Victor Grousset (2)
- Kyle M Hall (9)
- Andrew Isherwood (1)
- Joonas Kylmälä (1)
- Owen Leonard (2)
- Julian Maurice (1)
- Agustín Moyano (1)
- Martin Renvoize (12)
- Marcel de Rooy (1)
- Fridolin Somers (1)
- Mirko Tietgen (1)
- Koha Translators (2)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 20.05.07

- Athens County Public Libraries (2)
- BibLibre (2)
- ByWater-Solutions (37)
- Koha Community Developers (28)
- Mirko Tietgen (1)
- Prosentient Systems (4)
- PTFS-Europe (14)
- Rijks Museum (1)
- Solutions inLibro inc (1)
- Tamil (1)
- Theke Solutions (15)
- University of Helsinki (1)

We also especially thank the following individuals who tested patches
for Koha.

- Tomás Cohen Arazi (15)
- Bob Bennhoff (1)
- Nick Clemens (10)
- David Cook (2)
- Chris Cormack (1)
- Jonathan Druart (73)
- Katrin Fischer (10)
- Andrew Fuerste-Henry (103)
- Lucas Gass (4)
- Victor Grousset (32)
- Kyle M Hall (8)
- Sally Healey (6)
- Mason James (2)
- Joonas Kylmälä (1)
- Owen Leonard (1)
- Julian Maurice (3)
- Kelly McElligott (1)
- Josef Moravec (15)
- David Nind (17)
- Martin Renvoize (19)
- Phil Ringnalda (1)
- Fridolin Somers (36)
- Timothy Alexis Vass (1)
- Mengü Yazıcıoğlu (1)



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

Autogenerated release notes updated last on 07 Jan 2021 20:19:20.
