# RELEASE NOTES FOR KOHA 19.11.16
23 Mar 2021

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 19.11.16 can be downloaded from:

- [Download](https://download.koha-community.org/koha-19.11.16.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 19.11.16 is a bugfix/maintenance release.

It includes 10 bugfixes.

### System requirements

You can learn about the system components (like OS and database) for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations






## Critical bugs fixed

### Acquisitions

- [[26997]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26997) Database Mysql Version 8.0.22 failed to Update During Upgrade

### Architecture, internals, and plumbing

- [[27821]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27821) sanitize_zero_date does not handle datetime

### Circulation

- [[26457]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26457) DB DeadLock when renewing checkout items

### OPAC

- [[24398]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24398) Error when viewing single news item and NewsAuthorDisplay pref set to OPAC
- [[27626]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27626) Patron self-registration breaks if categorycode and password are hidden

### Patrons

- [[27933]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27933) Order patron search broken (dateofbirth, cardnumber, expirationdate)

### Searching - Elasticsearch

- [[27784]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27784) Unknown authority types break elasticsearch authorities indexing

  >This patch fixes Elasticsearch indexing failures caused by 'SUBDIV' type authority records in Koha. It skips the step of parsing the authorities into the linking form if the type contains '_SUBD'. 
  >
  >Notes: 
  >- Koha currently doesn't have support for 'SUBDIV' type authority records.
  >- They can be added to the authority types in the staff interface, however, values are hard coded in various modules and Koha has no concept of how to link a subfield heading to a record, as we only deal in whole fields.

### System Administration

- [[27569]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27569) marc-framework import function doesn't accept LibreOffice csv/ods file formats

### Tools

- [[26592]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26592) XSS vulnerability when ysearch is used


## Other bugs fixed

### System Administration

- [[27798]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27798) Independent branches should have a warning


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

- Arabic (98%)
- Armenian (100%)
- Armenian (Classical) (100%)
- Basque (55.7%)
- Catalan; Valencian (50.6%)
- Chinese (China) (56.9%)
- Chinese (Taiwan) (98.6%)
- Czech (90.8%)
- English (New Zealand) (78.3%)
- English (USA)
- Finnish (74.2%)
- French (97.1%)
- French (Canada) (93.8%)
- German (100%)
- German (Switzerland) (80.8%)
- Greek (71.2%)
- Hindi (100%)
- Italian (87.1%)
- Nederlands-Nederland (Dutch-The Netherlands) (84.2%)
- Norwegian Bokmål (83.3%)
- Occitan (post 1500) (53%)
- Polish (79.5%)
- Portuguese (99.4%)
- Portuguese (Brazil) (100%)
- Slovak (83.1%)
- Spanish (99.7%)
- Swedish (85%)
- Telugu (96.7%)
- Turkish (100%)
- Ukrainian (74.4%)
- Vietnamese (51.5%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](https://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](https://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](https://translate.koha-community.org/)

## Release Team

The release team for Koha 19.11.16 is


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

We thank the following individuals who contributed patches to Koha 19.11.16.

- Nick Clemens (4)
- Jonathan Druart (14)
- Lucas Gass (1)
- Victor Grousset (3)
- Kyle M Hall (1)
- Martin Renvoize (1)
- Koha Translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 19.11.16

- ByWater-Solutions (6)
- Koha Community Developers (17)
- PTFS-Europe (1)

We also especially thank the following individuals who tested patches
for Koha.

- Nick Clemens (1)
- Jonathan Druart (5)
- Katrin Fischer (7)
- Andrew Fuerste-Henry (19)
- Lucas Gass (1)
- Victor Grousset (22)
- Ron Houk (7)
- Owen Leonard (2)
- David Nind (5)
- Martin Renvoize (7)
- Marcel de Rooy (4)
- Fridolin Somers (19)



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

Autogenerated release notes updated last on 23 Mar 2021 23:51:49.
