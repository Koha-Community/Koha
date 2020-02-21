# RELEASE NOTES FOR KOHA 18.11.14
21 Feb 2020

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 18.11.14 can be downloaded from:

- [Download](http://download.koha-community.org/koha-18.11.14.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 18.11.14 is a bugfix/maintenance release.

It includes 21 bugfixes.

### System requirements

Koha is continiously tested against the following configurations and as such these are the recommendations for 
deployment: 

- Debian Jessie with MySQL 5.5
- Debian Stretch with MariaDB 10.1 (MySQL 8.0 support is experimental)
- Ubuntu Bionic with MariaDB 10.1 (MariaDB 10.3 support is experimental) 

Additional notes:
    
- Perl 5.10 is required
- Zebra or Elasticsearch is required






## Critical bugs fixed

### Acquisitions

- [[17667]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17667) Standing orders - cancelling a receipt increase the original quantity
- [[22868]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22868) Circulation staff with suggestions_manage can have access to acquisition data
- [[24277]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24277) Date Received in acquisitions cannot be changed

### Patrons

- [[14759]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14759) Replacement for Text::Unaccent


## Other bugs fixed

### Acquisitions

- [[9993]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9993) On editing basket group delivery place resets to logged in library

### Architecture, internals, and plumbing

- [[23896]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23896) logaction should pass the correct interface to Koha::Logger
- [[24016]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24016) manager_id in Koha::Patron::Message->store should not depend on userenv alone

  **Sponsored by** *Koha-Suomi Oy*

  >Using `userenv` within Koha::* object classes is deprecated in favour of passing parameters.
- [[24213]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24213) Koha::Object->get_from_storage should return undef if the object has been deleted
- [[24313]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24313) XSLT errors should show in the logs

### Cataloging

- [[24323]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24323) Advanced editor - Invalid 008 with helper silently fails to save
- [[24423]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24423) Broken link to return to record after batch item modification or deletion

### OPAC

- [[22302]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22302) ITEMTYPECAT description doesn't fall back to description if OPAC description is empty
- [[23528]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23528) Show 'log in to add tags' link on all search result entries
- [[24061]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24061) Print List (opac-shelves.pl) broken in Chrome
- [[24371]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24371) OPAC 'Showing only available items/Show all items' is double encoded

### Staff Client

- [[23987]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23987) batchMod.pl provides a link back to the record after the record is deleted

### Templates

- [[23113]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23113) members/pay.tt account_grp is not longer used

  >This patch removes markup that is no longer required in the pay.tt template (this template is used in the accounting section for patrons).
- [[24054]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24054) Typo in ClaimReturnedWarningThreshold system preference

### Tools

- [[24330]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24330) When importing patrons from CSV, automatically strip BOM from file if it exists
- [[24484]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24484) Add explanatory text to batch patron deletion
- [[24497]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24497) CodeMirror indentation problems


## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://koha-community.org/manual/18.11/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (97.8%)
- Armenian (100%)
- Basque (65.8%)
- Chinese (China) (63.7%)
- Chinese (Taiwan) (99%)
- Czech (93.7%)
- Danish (55.1%)
- English (New Zealand) (87.9%)
- English (USA)
- Finnish (84.1%)
- French (99.8%)
- French (Canada) (98.8%)
- German (100%)
- German (Switzerland) (91.4%)
- Greek (78.6%)
- Hindi (99.8%)
- Italian (93.5%)
- Norwegian Bokmål (94.2%)
- Occitan (post 1500) (59.3%)
- Polish (86.3%)
- Portuguese (100%)
- Portuguese (Brazil) (87.1%)
- Slovak (89.5%)
- Spanish (100%)
- Swedish (90%)
- Tetun (53.6%)
- Turkish (97.9%)
- Ukrainian (61.8%)
- Vietnamese (54.4%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 18.11.14 is


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

- Packaging Managers:
  - Mirko Tietgen
  - Mason James

- Documentation Managers:
  - Caroline Cyr La Rose
  - David Nind

- Documentation Team:
  - Donna Bachowski
  - Lucy Vaux-Harvey
  - Sugandha Bajaj

- Translation Managers: 
  - Bernardo González Kriegel

- Release Maintainers:
  - 19.11 -- Joy Nelson
  - 19.05 -- Lucas Gass
  - 18.11 -- Hayley Mapley

- Release Maintainer mentors:
  - 19.11 -- Martin Renvoize
  - 19.05 -- Nick Clemens
  - 18.11 -- Chris Cormack

## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 18.11.14:

- Koha-Suomi Oy

We thank the following individuals who contributed patches to Koha 18.11.14.

- Tomás Cohen Arazi (1)
- Cori Lynn Arnold (1)
- Nick Clemens (4)
- Jonathan Druart (12)
- Lucas Gass (2)
- Kyle Hall (1)
- Bernardo González Kriegel (1)
- Joonas Kylmälä (1)
- Owen Leonard (3)
- Hayley Mapley (4)
- Martin Renvoize (1)
- David Roberts (1)
- Marcel de Rooy (1)
- Lari Taskula (2)
- Koha Translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 18.11.14

- ACPL (3)
- ByWater-Solutions (7)
- Catalyst (4)
- hypernova.fi (2)
- Koha Community Developers (12)
- koha-ptfs.co.uk (1)
- PTFS-Europe (1)
- Rijks Museum (1)
- The Donohue Group (1)
- Theke Solutions (1)
- Universidad Nacional de Córdoba (1)
- University of Helsinki (1)

We also especially thank the following individuals who tested patches
for Koha.

- Tomás Cohen Arazi (2)
- Christopher Brannon (1)
- Nick Clemens (1)
- Gabriel DeCarufel (1)
- Jonathan Druart (8)
- Katrin Fischer (14)
- Andrew Fuerste-Henry (4)
- Lucas Gass (32)
- Rhonda Kuiper (1)
- Joonas Kylmälä (3)
- Hayley Mapley (33)
- Kelly McElligott (1)
- Joy Nelson (30)
- David Nind (4)
- Martin Renvoize (34)
- Marcel de Rooy (8)
- Maryse Simard (2)
- George Williams (2)
- Maggie Wong (1)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 18.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 21 Feb 2020 00:57:18.
