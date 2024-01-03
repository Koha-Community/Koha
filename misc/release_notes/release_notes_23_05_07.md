# RELEASE NOTES FOR KOHA 23.05.07
03 Jan 2024

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 23.05.07 can be downloaded from:

- [Download](http://download.koha-community.org/koha-23.05.07.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 23.05.07 is a bugfix/maintenance release.

It includes 11 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


## Bugfixes

### Cataloging

#### Other bugs fixed

- [35414](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35414) Silence warn related to number_of_copies
- [35441](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35441) Typo 'UniqueItemsFields' system preference

### Command-line Utilities

#### Other bugs fixed

- [34091](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34091) Typo in help for cleanupdatabase.pl: --log-modules  needs to be --log-module

### ERM

#### Other bugs fixed

- [35408](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35408) ERM > Titles > Import from a list gives an invalid link to the import job

### Installation and upgrade (command-line installer)

#### Critical bugs fixed

- [34516](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34516) Upgrade database fails for 22.11.07.003, points to web installer

### OPAC

#### Other bugs fixed

- [35436](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35436) Copy is not translatable in OPAC search history

### Patrons

#### Other bugs fixed

- [35344](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35344) Patron image upload does not warn about missing cardnumber
- [35352](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35352) Cannot hide SMSalertnumber via BorrowerUnwantedField

### Searching

#### Other bugs fixed

- [35410](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35410) 856 label is inconsistent between detail page and search results in XSLTs
  >This updates the default staff interface and OPAC XSLT files so that "Online resources" is used as the label in search results for field 856 - Electronic Location and Access, instead of "Online access". This matches the label used in the detail page for a record.
  >
  >It also adjusts the CSS class so OPAC and staff interface both use online_resources.

### Templates

#### Other bugs fixed

- [35327](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35327) Fix capitalization of language name
  >This fixes the capitalization of English (english -> English) in the ILS_DI GetAvailability information page (<domainname>:<port>/cgi-bin/koha/ilsdi.pl?service=Describe&verb=GetAvailability).
- [35453](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35453) Wrong 'Laserdisc)' string on 007 builder (MARC21)

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

The release team for Koha 23.05.07 is


- Release Manager: Katrin Fischer

- Release Manager assistants:
  - Tomás Cohen Arazi
  - Martin Renvoize
  - Jonathan Druart

- QA Manager: Marcel de Rooy

- QA Team:
  - Marcel de Rooy
  - Julian Maurice
  - Lucas Gass
  - Victor Grousset
  - Kyle M Hall
  - Nick Clemens
  - Martin Renvoize
  - Tomás Cohen Arazi
  - Aleisha Amohia
  - Emily Lamancusa
  - David Cook
  - Jonathan Druart
  - Pedor Amorim

- Topic Experts:
  - UI Design -- Owen Leonard
  - Zebra -- Fridolin Somers
  - REST API -- Tomás Cohen Arazi
  - ERM -- Matt Blenkinsop
  - ILL -- Pedro Amorim
  - SIP2 -- Matthias Meusburger
  - CAS -- Matthias Meusburger

- Bug Wranglers:
  - Aleisha Amohia
  - Indranil Das Gupta

- Packaging Managers:
  - Mason James
  - Indranil Das Gupta
  - Tomás Cohen Arazi

- Documentation Manager: Aude Charillon

- Documentation Team:
  - Caroline Cyr La Rose
  - Kelly McElligott
  - Philip Orr
  - Marie-Luce Laflamme
  - Lucy Vaux-Harvey

- Translation Manager: Jonathan Druart


- Wiki curators: 
  - Thomas Dukleth
  - Katrin Fischer

- Release Maintainers:
  - 23.11 -- Fridolin Somers
  - 23.05 -- Lucas Gass
  - 22.11 -- Frédéric Demians
  - 22.05 -- Danyon Sewell

- Release Maintainer assistants:
  - 22.05 -- Wainui Witika-Park

## Credits



We thank the following individuals who contributed patches to Koha 23.05.07
<div style="column-count: 2;">

- Tomás Cohen Arazi (1)
- Kevin Carnes (1)
- David Cook (1)
- Jonathan Druart (1)
- Magnus Enger (1)
- Lucas Gass (2)
- David Nind (1)
- Adolfo Rodríguez (1)
- Fridolin Somers (2)
- Lari Taskula (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 23.05.07
<div style="column-count: 2;">

- BibLibre (2)
- ByWater-Solutions (2)
- David Nind (1)
- Hypernova Oy (1)
- Koha Community Developers (1)
- Libriotech (1)
- Prosentient Systems (1)
- Theke Solutions (1)
- ub.lu.se (1)
- Xercode (1)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Matt Blenkinsop (1)
- David Cook (1)
- Katrin Fischer (11)
- Andrew Fuerste-Henry (1)
- Lucas Gass (12)
- Victor Grousset (6)
- Emily Lamancusa (1)
- Owen Leonard (3)
- David Nind (5)
- Marcel de Rooy (2)
- Fridolin Somers (9)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is rmain2305.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 03 Jan 2024 14:54:58.
