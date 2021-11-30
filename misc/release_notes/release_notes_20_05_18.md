# RELEASE NOTES FOR KOHA 20.05.18
30 Nov 2021

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 20.05.18 can be downloaded from:

- [Download](https://download.koha-community.org/koha-20.05.18.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 20.05.18 is a bugfix/maintenance release.

It includes 11 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations






## Critical bugs fixed

### Acquisitions

- [[14999]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14999) Adding to basket orders from staged files mixes up the prices between different orders

### Architecture, internals, and plumbing

- [[26374]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26374) Update for 19974 is not idempotent

### Circulation

- [[29255]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29255) Built-in offline circulation broken with SQL error

### OPAC

- [[29416]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29416) Regression: information from existing bib no longer populating on suggest for purchase

  >This restores the behaviour for purchase suggestions for an existing title, so that the suggestion form is pre-filled with the details from the existing record.

### Patrons

- [[29524]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29524) Cannot set a new value for privacy_guarantor_checkouts in memberentry.pl

### Reports

- [[29204]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29204) Error 500 when execute Circulation report with date period

### SIP2

- [[26871]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26871) L1 cache still too long in SIP Server

  >This fixes SIP connections so that when system preference and configuration changes are made (for example: enabling or disabling logging of issues and returns) they are picked up automatically with the next message, rather than requiring the SIP connection to be closed and reopened.
  >
  >SIP connections typically tend to be long lived - weeks if not months. Basically the connection per SIP machine is initiated once when the SIP machine boots and then never closed until maintenance is required. Therefore we need to reset Koha's caches on every SIP request to get the latest system preference and configuration changes from the memcached cache that is shared between all the Koha programs (staff interface, OPAC, SIP, cronjobs, etc).
- [[29264]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29264) SIP config allows use of non-branchcode institution ids causes workers to die without responding

  >This adds a warning to the logs where a SIP login uses an institution id that is *not* a valid library code.
  >
  >If a SIP login uses an institution with an id that doesn't match a valid branchcode, everything will appear to work, but the SIP worker will die anywhere that Koha gets the branch from the userenv and assumes it is valid.
  >
  >The repercussions of this are that actions such as the checkout message simply die and do not return a response message to the requestor.
- [[29564]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29564) Use List::MoreUtils so SIP U16/Xenial does not break


## Other bugs fixed

### About

- [[28904]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28904) Update information on Newsletter editor on about page

### SIP2

- [[29452]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29452) Unnecessary warns in sip logs



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/20.05/ar/html/) (43.3%)
- [Chinese (Taiwan)](https://koha-community.org/manual/20.05/zh_TW/html/) (100%)
- [Czech](https://koha-community.org/manual/20.05/cs/html/) (33.1%)
- [English (USA)](https://koha-community.org/manual/20.05/en/html/)
- [French](https://koha-community.org/manual/20.05/fr/html/) (70.6%)
- [French (Canada)](https://koha-community.org/manual/20.05/fr_CA/html/) (31.2%)
- [German](https://koha-community.org/manual/20.05/de/html/) (72.4%)
- [Hindi](https://koha-community.org/manual/20.05/hi/html/) (100%)
- [Italian](https://koha-community.org/manual/20.05/it/html/) (78.9%)
- [Spanish](https://koha-community.org/manual/20.05/es/html/) (58.5%)
- [Turkish](https://koha-community.org/manual/20.05/tr/html/) (70.2%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (89.1%)
- Armenian (100%)
- Armenian (Classical) (99.7%)
- Chinese (Taiwan) (94.3%)
- Czech (80.6%)
- English (New Zealand) (66.5%)
- English (USA)
- Finnish (70.3%)
- French (87%)
- French (Canada) (96.9%)
- German (100%)
- German (Switzerland) (74.3%)
- Greek (62.6%)
- Hindi (100%)
- Italian (100%)
- Norwegian Bokmål (70.9%)
- Polish (79.5%)
- Portuguese (87.7%)
- Portuguese (Brazil) (97.7%)
- Russian (86.1%)
- Slovak (89.3%)
- Spanish (100%)
- Swedish (79.2%)
- Telugu (100%)
- Turkish (100%)
- Ukrainian (66.1%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](https://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](https://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](https://translate.koha-community.org/)

## Release Team

The release team for Koha 20.05.18 is


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

We thank the following individuals who contributed patches to Koha 20.05.18

- Nick Clemens (1)
- Christophe Croullebois (1)
- Jonathan Druart (3)
- Victor Grousset (4)
- Kyle M Hall (1)
- Mason James (1)
- Joonas Kylmälä (3)
- Owen Leonard (1)
- Martin Renvoize (4)
- Koha translators (2)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 20.05.18

- Athens County Public Libraries (1)
- BibLibre (1)
- ByWater-Solutions (2)
- Independant Individuals (3)
- Koha Community Developers (7)
- KohaAloha (1)
- PTFS-Europe (4)

We also especially thank the following individuals who tested patches
for Koha

- Nick Clemens (1)
- Jonathan Druart (12)
- Katrin Fischer (3)
- Victor Grousset (16)
- Kyle M Hall (14)
- Joonas Kylmälä (3)
- Owen Leonard (1)
- David Nind (6)
- Martin Renvoize (7)
- Marcel de Rooy (2)
- Fridolin Somers (14)
- Emmi Takkinen (1)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 20.05.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 30 Nov 2021 23:51:05.
