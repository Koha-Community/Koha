# RELEASE NOTES FOR KOHA 19.11.13
06 Jan 2021

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 19.11.13 can be downloaded from:

- [Download](https://download.koha-community.org/koha-19.11.13.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 19.11.13 is a bugfix/maintenance release.

It includes 15 bugfixes.

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

### Acquisitions

- [[18267]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18267) Update price and tax fields in EDI to reflect DB changes
- [[27082]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27082) Problem when a basket has more of 20 orders with uncertain price

### Cataloging

- [[26518]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26518) Adding a record can succeed even if adding the biblioitem fails

### Command-line Utilities

- [[25752]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25752) Current directory not kept when using koha-shell

### Fines and fees

- [[27079]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27079) UpdateFine adds refunds for fines paid off before return

### MARC Bibliographic record staging/import

- [[26854]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26854) stage-marc-import.pl does not properly fork

### SIP2

- [[27166]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27166) SIP2 Connection is killed when an item that was not issued is checked in and generates a transfer

### Searching - Zebra

- [[12430]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12430) Relevance ranking should also be used without QueryWeightFields system preference

### Tools

- [[26516]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26516) Importing records with unexpected format of copyrightdate fails


## Other bugs fixed

### About

- [[27108]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27108) Update team for 21.05 cycle

### Architecture, internals, and plumbing

- [[27092]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27092) Remove note about "synced mirror" from the README.md

### Cataloging

- [[25189]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25189) AutoCreateAuthorities can repeatedly generate authority records when using Default linker

### Command-line Utilities

- [[14564]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14564) Incorrect permissions prevent web download of configuration backups

### Packaging

- [[25548]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25548) Package install Apache performs unnecessary redirects

### Test Suite

- [[26986]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26986) Second try to prevent Selenium's StaleElementReferenceException


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

- Arabic (98.2%)
- Armenian (100%)
- Armenian (Classical) (100%)
- Basque (55.9%)
- Catalan; Valencian (50.7%)
- Chinese (China) (57.1%)
- Chinese (Taiwan) (98.8%)
- Czech (91.1%)
- English (New Zealand) (78.6%)
- English (USA)
- Finnish (74.5%)
- French (97.1%)
- French (Canada) (94.1%)
- German (100%)
- German (Switzerland) (81.1%)
- Greek (71.4%)
- Hindi (100%)
- Italian (87.3%)
- Nederlands-Nederland (Dutch-The Netherlands) (72.9%)
- Norwegian Bokmål (83.6%)
- Occitan (post 1500) (53.2%)
- Polish (78.7%)
- Portuguese (99.6%)
- Portuguese (Brazil) (99.6%)
- Slovak (83.3%)
- Spanish (100%)
- Swedish (85.3%)
- Telugu (95.7%)
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

The release team for Koha 19.11.13 is


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

We thank the following individuals who contributed patches to Koha 19.11.13.

- Philippe Blouin (1)
- Colin Campbell (1)
- Nick Clemens (6)
- David Cook (4)
- Jonathan Druart (10)
- Victor Grousset (6)
- Martin Renvoize (3)
- Fridolin Somers (1)
- Mirko Tietgen (1)
- Koha Translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 19.11.13

- BibLibre (1)
- ByWater-Solutions (6)
- Koha Community Developers (16)
- Mirko Tietgen (1)
- Prosentient Systems (4)
- PTFS-Europe (4)
- Solutions inLibro inc (1)

We also especially thank the following individuals who tested patches
for Koha.

- Tomás Cohen Arazi (1)
- Nick Clemens (5)
- David Cook (1)
- Jonathan Druart (18)
- Katrin Fischer (1)
- Andrew Fuerste-Henry (26)
- Lucas Gass (3)
- Victor Grousset (38)
- Kyle M Hall (1)
- Julian Maurice (2)
- Josef Moravec (4)
- David Nind (2)
- Martin Renvoize (10)
- Fridolin Somers (6)



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

Autogenerated release notes updated last on 06 Jan 2021 17:35:55.
