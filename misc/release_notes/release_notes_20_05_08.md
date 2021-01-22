# RELEASE NOTES FOR KOHA 20.05.08
22 Jan 2021

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 20.05.08 can be downloaded from:

- [Download](http://download.koha-community.org/koha-20.05.08.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 20.05.08 is a bugfix/maintenance release.

It includes 4 enhancements, 35 bugfixes.

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

### Hold requests

- [[22284]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22284) Add ability to define groups of locations for hold pickup

  >Adds the ability to define groups of libraries for use in holds policy.

### Label/patron card printing

- [[26875]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26875) Allow printing of just one barcode

### Searching - Elasticsearch

- [[24863]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24863) QueryFuzzy syspref says it requires Zebra but Elasticsearch has some support

### Staff Client

- [[25462]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25462) Shelving location should be on a new line in holdings table

  >In the holdings table, the shelving location is now displayed on a new line after the 'Home library'.


## Critical bugs fixed

### Cataloging

- [[27509]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27509) cn_sort value is lost when editing an item without changing cn_source or itemcallnumber

### Command-line Utilities

- [[27245]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27245) bulkmarcimport.pl error 'Already in a transaction'

### Database

- [[25826]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25826) Hiding biblionumber in the frameworks breaks links in result list
- [[27003]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27003) action_logs table error when adding an item

### Patrons

- [[27420]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27420) A mistake in bug 5161 leads to some patron attributes appearing without a fieldset

### SIP2

- [[27196]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27196) Waiting title level hold checked in at wrong location via SIP leaves hold in a broken state and drops connection


## Other bugs fixed

### Acquisitions

- [[24470]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24470) Set import_status when file used to populate basket in acquisitions

### Architecture, internals, and plumbing

- [[25292]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25292) L1 cache too long in Z3950 server (z3950-responder)
- [[26848]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26848) Fix Readonly dependency in cpanfile
- [[27345]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27345) C4::Auth::get_template_and_user is missing some permissions for superlibrarian

### Cataloging

- [[26330]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26330) jQueryUI tabs don't work with non-Latin-1 characters
- [[27137]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27137) Move item doesn't show the title of the target record

  **Sponsored by** *Toi Ohomai Institute of Technology*

  >This patch fixes a small bug to ensure that the title of the target bibliographic record shows as expected upon successfully attaching an item.
- [[27164]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27164) Fix item search CSV export

### Command-line Utilities

- [[26851]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26851) Overdue notices should not send a report to the library if there is no content
- [[27085]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27085) Corrections in overdue_notices.pl help text

  **Sponsored by** *Lund University Library*

### Fines and fees

- [[26593]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26593) Rental discounts are applied in wrong precedence order
- [[27180]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27180) Fines cronjob does not update fines on holidays when finesCalendar is set to ignore

### Hold requests

- [[26698]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26698) Hold can show as waiting and in transit at the same time

### MARC Bibliographic record staging/import

- [[26171]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26171) Show biblionumber in Koha::Exceptions::Metadata::Invalid

### OPAC

- [[26397]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26397) opac.scss calls non-existent image

  >This patch removes some obsolete CSS from the OPAC which calls a non-existent image.
- [[27090]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27090) In the location column of an OPAC cart the 'In transit from' and 'to' fields are empty
- [[27178]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27178) OPAC results and lists pages contain invalid attributes (xmlns:str="http://exslt.org/strings")

### Patrons

- [[26417]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26417) Remove warn in Koha::Patron is_valid_age

### Searching - Elasticsearch

- [[26996]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26996) Elasticsearch: Multiprocess reindexing sometimes doesn't reindex all records

  **Sponsored by** *Lund University Library*
- [[27043]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27043) Add to number_of_replicas and number_of_shards  to index config

  >Elasticsearch 6 server has default value 5 for "number_of_shards" but warn about Elasticsearch 7 having default value 1.
  >So its is better to set this value in configuration file.
  >Patch also sets number_of_replicas to 1.
  >If you have only one Elasticsearch node, you have to set this value to 0.

### System Administration

- [[27280]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27280) Explanation for "Days mode" is not consistent
- [[27349]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27349) Mana system preference wrong type YesNo
- [[27351]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27351) UsageStatsCountry system preference wrong type YesNo

### Templates

- [[25954]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25954) Header search forms should be labeled

### Test Suite

- [[26364]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26364) XISBN.t makes a bad assumption about return values

### Tools

- [[26894]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26894) Marc Modification Templates treat subfield 0 as no subfield set when moving fields
- [[26983]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26983) Selecting ALL Items in Inventory- only selects 20
- [[27413]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27413) Cannot add debarment with batch patron modification tool

### Web services

- [[21301]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21301) Restriction of the informations given by GetRecords ILS-DI service

  >For privacy protection, ILS-DI webservice GetRecords will not give patron information anymore. Also old issues are not given anymore.
  >This removes method C4::Circulation::GetBiblioIssues().

### Z39.50 / SRU / OpenSearch Servers

- [[27149]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27149) Z3950Responder removes itemnumber when adding item statuses


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

- Arabic (98.9%)
- Armenian (100%)
- Armenian (Classical) (99.7%)
- Chinese (Taiwan) (94.4%)
- Czech (80.8%)
- English (New Zealand) (66.8%)
- English (USA)
- Finnish (70.6%)
- French (81.8%)
- French (Canada) (96.8%)
- German (100%)
- German (Switzerland) (74.6%)
- Greek (62.2%)
- Hindi (99.7%)
- Italian (99.8%)
- Norwegian Bokmål (71.2%)
- Polish (73.6%)
- Portuguese (87%)
- Portuguese (Brazil) (98.1%)
- Russian (86.8%)
- Slovak (89.9%)
- Spanish (100%)
- Swedish (79.8%)
- Telugu (89.7%)
- Turkish (100%)
- Ukrainian (66.5%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 20.05.08 is


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
new features in Koha 20.05.08:

- Lund University Library
- Toi Ohomai Institute of Technology

We thank the following individuals who contributed patches to Koha 20.05.08.

- Aleisha Amohia (1)
- Tomás Cohen Arazi (1)
- Nick Clemens (18)
- Christophe Croullebois (1)
- Jonathan Druart (14)
- Andrew Fuerste-Henry (8)
- Victor Grousset (2)
- Owen Leonard (6)
- Julian Maurice (1)
- Josef Moravec (1)
- Björn Nylén (1)
- Martin Renvoize (2)
- David Roberts (1)
- Marcel de Rooy (1)
- Lisette Scheer (1)
- Fridolin Somers (11)
- Koha Translators (1)
- Timothy Alexis Vass (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 20.05.08

- Athens County Public Libraries (6)
- BibLibre (13)
- ByWater-Solutions (26)
- Independant Individuals (2)
- Koha Community Developers (16)
- Latah County Library District (1)
- PTFS-Europe (3)
- Rijks Museum (1)
- Theke Solutions (1)
- ub.lu.se (2)

We also especially thank the following individuals who tested patches
for Koha.

- Tomás Cohen Arazi (3)
- Nick Clemens (28)
- David Cook (2)
- Jonathan Druart (43)
- Magnus Enger (1)
- Katrin Fischer (9)
- Andrew Fuerste-Henry (65)
- Victor Grousset (12)
- Mason James (1)
- Barbara Johnson (1)
- Joonas Kylmälä (2)
- Owen Leonard (3)
- Julian Maurice (3)
- Josef Moravec (2)
- David Nind (13)
- Martin Renvoize (15)
- Caroline Cyr La Rose (1)
- Fridolin Somers (48)



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

Autogenerated release notes updated last on 22 Jan 2021 22:04:36.
