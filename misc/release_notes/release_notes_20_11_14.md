# RELEASE NOTES FOR KOHA 20.11.14
31 Jan 2022

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 20.11.14 can be downloaded from:

- [Download](https://download.koha-community.org/koha-20.11.14.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 20.11.14 is a bugfix/maintenance release with security fixes.

It includes 9 security fixes, 5 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations


## Security bugs

### Koha

- [[26102]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26102) Javascript injection in intranet search
- [[28735]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28735) Self-checkout users can access opac-user.pl for sco user when not using AutoSelfCheckID
- [[29540]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29540) Accounts with just 'catalogue' permission can modify/delete holds
- [[29541]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29541) Patron images can be accessed with just 'catalogue' permission
- [[29542]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29542) User with 'catalogue' permission can view everybody's (private) virtualshelves
- [[29543]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29543) Self-checkout allows returning everybody's loans
- [[29544]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29544) A patron can set everybody's checkout notes
- [[29903]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29903) Message deletion possible from different branch
- [[29914]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29914) check_cookie_auth not strict enough




## Critical bugs fixed

### OPAC

- [[28698]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28698) News for all displays in all locations

  >This corrects the display of news items in the OPAC - if a location was not selected when creating a news item it was displaying in all locations (news, header, right, and so on). It also now displays in the right location for any language.

### Searching - Elasticsearch

- [[29284]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29284) Koha dies when an analytics search fails in Elasticsearch


## Other bugs fixed

### Cataloging

- [[29319]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29319) Errors when doing a cataloging search which starts with a number + letter

  >This fixes an error that occurs in cataloging search when entering a search term with ten characters (like "7th Heaven" or "2nd editio") - Koha thinks you are entering an ISBN10 number, gets confused and delivers an error page. Searching now works as expected for ISBN13/ISBN10 (without the '-'s), title and author searches.
- [[29437]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29437) 500 error when performing a catalog search for an ISBN13 with no valid ISBN10

### Searching - Elasticsearch

- [[28316]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28316) Fix ES crashes related to various punctuation characters



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/20.11/ar/html/) (27%)
- [Chinese (Taiwan)](https://koha-community.org/manual/20.11/zh_TW/html/) (61.5%)
- [English (USA)](https://koha-community.org/manual/20.11/en/html/)
- [French](https://koha-community.org/manual/20.11/fr/html/) (57.6%)
- [French (Canada)](https://koha-community.org/manual/20.11/fr_CA/html/) (26%)
- [German](https://koha-community.org/manual/20.11/de/html/) (71.2%)
- [Hindi](https://koha-community.org/manual/20.11/hi/html/) (99.9%)
- [Italian](https://koha-community.org/manual/20.11/it/html/) (50.1%)
- [Spanish](https://koha-community.org/manual/20.11/es/html/) (36.5%)
- [Turkish](https://koha-community.org/manual/20.11/tr/html/) (41.9%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (99%)
- Armenian (100%)
- Armenian (Classical) (89%)
- Bulgarian (91.7%)
- Catalan; Valencian (57.6%)
- Chinese (Taiwan) (93%)
- Czech (73.2%)
- English (New Zealand) (59.4%)
- English (USA)
- Finnish (79.2%)
- French (92.4%)
- French (Canada) (91.9%)
- German (100%)
- German (Switzerland) (66.7%)
- Greek (60.8%)
- Hindi (100%)
- Italian (100%)
- Nederlands-Nederland (Dutch-The Netherlands) (94.4%)
- Norwegian Bokmål (63.6%)
- Polish (100%)
- Portuguese (91.4%)
- Portuguese (Brazil) (96.5%)
- Russian (93.5%)
- Slovak (80.3%)
- Spanish (100%)
- Swedish (75%)
- Telugu (99.9%)
- Turkish (99.9%)
- Ukrainian (70.7%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](https://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](https://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](https://translate.koha-community.org/)

## Release Team

The release team for Koha 20.11.14 is


- Release Manager: Fridolin Somers

- Release Manager assistants:
  - Jonathan Druart
  - Martin Renvoize
  - Tomás Cohen Arazi

- QA Manager: Katrin Fischer

- QA Team:
  - Andrew Nugged
  - Jonathan Druart
  - Joonas Kylmälä
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
  - Zebra -- Fridolin Somers
  - Accounts -- Martin Renvoize

- Bug Wranglers:
  - Indranil Das Gupta
  - Erica Rohlfs

- Packaging Manager: 


- Documentation Manager: David Nind


- Documentation Team:
  - Aude Charillon
  - Caroline Cyr La Rose
  - Kelly McElligott
  - Lucy Vaux-Harvey
  - Martin Renvoize
  - Rocio Lopez

- Translation Managers: 
  - Bernardo González Kriegel

- Wiki curators: 
  - Thomas Dukleth

- Release Maintainers:
  - 21.11 -- Kyle M Hall
  - 21.05 -- Andrew Fuerste-Henry
  - 20.11 -- Victor Grousset
  - 19.11 -- Wainui Witika-Park

## Credits

We thank the following individuals who contributed patches to Koha 20.11.14

- Tomás Cohen Arazi (1)
- Nick Clemens (11)
- David Cook (1)
- Jonathan Druart (15)
- Lucas Gass (1)
- Victor Grousset (2)
- Owen Leonard (7)
- Martin Renvoize (1)
- Marcel de Rooy (4)
- Fridolin Somers (1)
- Koha translators (1)
- Petro Vashchuk (6)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 20.11.14

- Athens County Public Libraries (7)
- BibLibre (1)
- ByWater-Solutions (12)
- Independant Individuals (6)
- Koha Community Developers (17)
- Prosentient Systems (1)
- PTFS-Europe (1)
- Rijksmuseum (4)
- Theke Solutions (1)

We also especially thank the following individuals who tested patches
for Koha

- Tomás Cohen Arazi (6)
- Alex Buckley (6)
- Nick Clemens (13)
- Jonathan Druart (18)
- Katrin Fischer (23)
- Andrew Fuerste-Henry (1)
- Victor Grousset (53)
- Kyle M Hall (39)
- David Nind (4)
- Martin Renvoize (14)
- Marcel de Rooy (2)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 20.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 31 Jan 2022 19:39:35.
