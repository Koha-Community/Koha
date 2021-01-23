# RELEASE NOTES FOR KOHA 19.11.14
22 Jan 2021

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 19.11.14 can be downloaded from:

- [Download](https://download.koha-community.org/koha-19.11.14.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 19.11.14 is a bugfix/maintenance release.

It includes 12 bugfixes.

### System requirements

Koha is continuously tested against the following configurations and as such these are the recommendations for 
deployment: 

Operating system:

- Debian 10
- Debian 9
- Ubuntu 20.04
- Ubuntu 18.04
- Ubuntu 16.04

Database:

- MariaDB 10.3
- MariaDB 10.1

Search engine:

- ElasticSearch 6
- Zebra

Perl:

- Perl >= 5.14 is required and 5.24, 5.26, 5.28 or 5.30 are recommended. These are the versions of the recommended operating systems.






## Critical bugs fixed

### Architecture, internals, and plumbing

- [[27252]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27252) ES5 no longer supported (since 20.11.00)

  >This prepares Koha to officially no longer support Elasticsearch 5.X.
  >
  >It adds a new system preference 'ElasticsearchCrossFields' to allow users to choose whether or not to enable this feature.

### Command-line Utilities

- [[27245]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27245) bulkmarcimport.pl error 'Already in a transaction'
- [[27276]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27276) borrowers-force-messaging-defaults throws Incorrect DATE value: '0000-00-00' even though sql strict mode is dissabled

### Database

- [[25826]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25826) Hiding biblionumber in the frameworks breaks links in result list

### Patrons

- [[27004]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27004) Deleting a staff account who have created claims returned causes problem in the return_claims table because of a NULL value in return_claims.created_by.

### Searching - Elasticsearch

- [[27070]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27070) Elasticsearch - with Elasticsearch 6 searches failing unless all terms are in the same field

### Test Suite

- [[27055]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27055) Update Firefox version used in Selenium GUI tests


## Other bugs fixed

### Cataloging

- [[27137]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27137) Move item doesn't show the title of the target record

  **Sponsored by** *Toi Ohomai Institute of Technology*

  >This patch fixes a small bug to ensure that the title of the target bibliographic record shows as expected upon successfully attaching an item.

### Command-line Utilities

- [[27085]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27085) Corrections in overdue_notices.pl help text

  **Sponsored by** *Lund University Library*

### MARC Bibliographic record staging/import

- [[27099]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27099) Stage for import button not showing up

### OPAC

- [[27090]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27090) In the location column of an OPAC cart the 'In transit from' and 'to' fields are empty

### Searching - Elasticsearch

- [[27043]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27043) Add to number_of_replicas and number_of_shards  to index config

  >Elasticsearch 6 server has default value 5 for "number_of_shards" but warn about Elasticsearch 7 having default value 1.
  >So its is better to set this value in configuration file.
  >Patch also sets number_of_replicas to 1.
  >If you have only one Elasticsearch node, you have to set this value to 0.
## New sysprefs

- ElasticsearchCrossFields

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha 
documentation is 

- [Koha Documentation](https://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](https://koha-community.org/manual/19.11/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (98.1%)
- Armenian (100%)
- Armenian (Classical) (100%)
- Basque (55.9%)
- Catalan; Valencian (50.7%)
- Chinese (China) (57.1%)
- Chinese (Taiwan) (98.8%)
- Czech (91%)
- English (New Zealand) (78.5%)
- English (USA)
- Finnish (74.4%)
- French (97.1%)
- French (Canada) (94%)
- German (100%)
- German (Switzerland) (81%)
- Greek (71.4%)
- Hindi (99.9%)
- Italian (87.2%)
- Nederlands-Nederland (Dutch-The Netherlands) (77.9%)
- Norwegian Bokmål (83.5%)
- Occitan (post 1500) (53.2%)
- Polish (78.7%)
- Portuguese (99.6%)
- Portuguese (Brazil) (99.6%)
- Slovak (83.3%)
- Spanish (99.9%)
- Swedish (85.2%)
- Telugu (95.8%)
- Turkish (100%)
- Ukrainian (74.6%)
- Vietnamese (51.7%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](https://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](https://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](https://translate.koha-community.org/)

## Release Team

The release team for Koha 19.11.14 is


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
new features in Koha 19.11.14:

- Lund University Library
- Toi Ohomai Institute of Technology

We thank the following individuals who contributed patches to Koha 19.11.14.

- Aleisha Amohia (1)
- Tomás Cohen Arazi (2)
- Nick Clemens (4)
- Christophe Croullebois (1)
- Jonathan Druart (6)
- Andrew Fuerste-Henry (1)
- Victor Grousset (4)
- Kyle M Hall (1)
- Owen Leonard (1)
- Fridolin Somers (1)
- Koha Translators (1)
- Timothy Alexis Vass (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 19.11.14

- Athens County Public Libraries (1)
- BibLibre (2)
- ByWater-Solutions (6)
- Independant Individuals (1)
- Koha Community Developers (10)
- Theke Solutions (2)
- ub.lu.se (1)

We also especially thank the following individuals who tested patches
for Koha.

- Tomás Cohen Arazi (7)
- Nick Clemens (9)
- David Cook (1)
- Chris Cormack (1)
- Jonathan Druart (7)
- Andrew Fuerste-Henry (18)
- Lucas Gass (1)
- Victor Grousset (25)
- Kyle M Hall (1)
- Mason James (1)
- Joonas Kylmälä (1)
- Owen Leonard (1)
- Fridolin Somers (11)



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

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 22 Jan 2021 23:18:44.
