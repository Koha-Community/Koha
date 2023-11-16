# RELEASE NOTES FOR KOHA 21.11.25
01 Nov 2023

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 21.11.25 can be downloaded from:

- [Download](http://download.koha-community.org/koha-21.11.25.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 21.11.25 is a bugfix/maintenance release.

It includes 1 enhancements, 4 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


## Bugfixes

### Architecture, internals, and plumbing

#### Critical bugs fixed

- [34959](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34959) Translator tool generates too many changes

#### Other bugs fixed

- [35024](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35024) Do not wrap PO files

### Installation and upgrade (command-line installer)

#### Critical bugs fixed

- [35146](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35146) Missing db_revs file for Koha 21.11.24

### Tools

#### Critical bugs fixed

- [35009](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35009) [21.11] tools/scheduler.pl contains merge markers

  **Sponsored by** *Catalyst*

## Enhancements 

### Architecture, internals, and plumbing

#### Enhancements

- [35043](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35043) Handling of \t in PO files is confusing

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (86.3%)
- Armenian (100%)
- Armenian (Classical) (76%)
- Bulgarian (100%)
- Chinese (Taiwan) (78.5%)
- Czech (77.3%)
- English (New Zealand) (60%)
- English (USA)
- Finnish (98.8%)
- French (100%)
- French (Canada) (91.6%)
- German (100%)
- German (Switzerland) (58.1%)
- Greek (61.8%)
- Hindi (100%)
- Italian (99.9%)
- Nederlands-Nederland (Dutch-The Netherlands) (87%)
- Norwegian Bokmål (62.4%)
- Polish (100%)
- Portuguese (91.1%)
- Portuguese (Brazil) (83.4%)
- Russian (83.9%)
- Slovak (74.8%)
- Spanish (100%)
- Swedish (87.2%)
- Telugu (93.9%)
- Turkish (100%)
- Ukrainian (75%)
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

The release team for Koha 21.11.25 is


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
new features in Koha 21.11.25
<div style="column-count: 2;">

- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)
</div>

We thank the following individuals who contributed patches to Koha 21.11.25
<div style="column-count: 2;">

- Aleisha Amohia (1)
- Tomás Cohen Arazi (1)
- danyonsewell (1)
- Jonathan Druart (6)
- Danyon Sewell (2)
- Koha translators (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 21.11.25
<div style="column-count: 2;">

- Catalyst (3)
- Catalyst Open Source Academy (1)
- Koha Community Developers (6)
- Theke Solutions (1)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- danyonsewell (5)
- Jonathan Druart (1)
- Katrin Fischer (1)
- Kyle M Hall (2)
- Owen Leonard (2)
- David Nind (3)
- Martin Renvoize (1)
- Marcel de Rooy (2)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 21.11.x-rmaint.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 01 Nov 2023 04:09:36.
