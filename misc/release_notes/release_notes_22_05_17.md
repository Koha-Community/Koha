# RELEASE NOTES FOR KOHA 22.05.17
28 Nov 2023

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 22.05.17 can be downloaded from:

- [Download](http://download.koha-community.org/koha-22.05.17.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 22.05.17 is a bugfix/maintenance release.

It includes 4 enhancements, 6 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).

#### Security bugs

- [35290](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35290) SQL Injection vulnerability in ysearch.pl
- [35291](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35291) File Upload vulnerability in upload-cover-image.pl

## Bugfixes

### Architecture, internals, and plumbing

#### Critical bugs fixed

- [34959](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34959) Translator tool generates too many changes

#### Other bugs fixed

- [32978](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32978) 'npm install' fails in ktd on aarch64, giving unsupported architecture error for node-sass
- [35024](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35024) Do not wrap PO files

### MARC Authority data support

#### Critical bugs fixed

- [33404](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33404) Authorities imported from Z39.50 in encodings other than UTF-8 are corrupted

### OPAC

#### Other bugs fixed

- [33848](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33848) Enabling Coce in the OPAC breaks cover images on bibliographic detail page

### Tools

#### Critical bugs fixed

- [26611](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26611) Required match checks don't work for authority records

  **Sponsored by** *Waikato Institute of Technology*
  >This fixes match checking for authorities when importing records, so that the required match checks are correctly applied. Previously, match checks for authority records did not work.

## Enhancements 

### Architecture, internals, and plumbing

#### Enhancements

- [35043](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35043) Handling of \t in PO files is confusing
- [35079](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35079) Add option to gulp tasks po:update and po:create to control if POT should be built
- [35103](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35103) Add option to gulp tasks to pass a list of tasks
- [35174](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35174) Remove .po files from the codebase

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 22.05.17 is


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
new features in Koha 22.05.17
<div style="column-count: 2;">

- Waikato Institute of Technology
</div>

We thank the following individuals who contributed patches to Koha 22.05.17
<div style="column-count: 2;">

- Aleisha Amohia (2)
- David Cook (3)
- Jonathan Druart (14)
- Lucas Gass (1)
- Mason James (1)
- Owen Leonard (3)
- Julian Maurice (2)
- Marcel de Rooy (3)
- Koha translators (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 22.05.17
<div style="column-count: 2;">

- Athens County Public Libraries (3)
- BibLibre (2)
- ByWater-Solutions (1)
- Catalyst Open Source Academy (2)
- Koha Community Developers (14)
- KohaAloha (1)
- Prosentient Systems (3)
- Rijksmuseum (3)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Aleisha Amohia (3)
- Pedro Amorim (2)
- Tomás Cohen Arazi (12)
- Matt Blenkinsop (4)
- Nick Clemens (10)
- David Cook (1)
- Paul Derscheid (1)
- Jonathan Druart (5)
- Katrin Fischer (2)
- Lucas Gass (11)
- Kyle M Hall (2)
- Owen Leonard (3)
- David Nind (4)
- Martin Renvoize (5)
- Marcel de Rooy (2)
- Fridolin Somers (2)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 22.05.x-security.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 28 Nov 2023 16:00:35.
