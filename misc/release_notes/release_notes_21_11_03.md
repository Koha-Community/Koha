# RELEASE NOTES FOR KOHA 21.11.03
24 Mar 2022

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 21.11.03 can be downloaded from:

- [Download](http://download.koha-community.org/koha-21.11.03.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 21.11.03 is a bugfix/maintenance release.

It includes 2 enhancements, 24 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations




## Enhancements

### Architecture, internals, and plumbing

- [[29886]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29886) Add Koha::Suggestions->search_limited

### Plugin architecture

- [[30072]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30072) Add more holds hooks

  >This development adds plugin hooks for several holds actions. The hook is called *after_hold_action* and has two parameters
  >
  >* **action**: containing a string that represents the _action_, possible values: _fill_, _cancel_, _suspend_ and _resume_.
  >* **payload**: A hashref containing a _hold_ key, which points to the Koha::Hold object.


## Critical bugs fixed

### Cataloging

- [[30178]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30178) Every librarian can edit every item with IndependentBranches on

### OPAC

- [[30147]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30147) OpacBrowseResults causing error on detail page

### Packaging

- [[30084]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30084) Remove dependency of liblocale-codes-perl

### REST API

- [[29877]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29877) MaxReserves should be enforced consistently between staff interface and API


## Other bugs fixed

### Acquisitions

- [[29287]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29287) Display of funds on acquisitions home is not consistent with display on funds page

### Architecture, internals, and plumbing

- [[29687]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29687) Get rid of an uninitialized warning in XSLT.pm
- [[29771]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29771) Get rid of CGI::param in list context warnings
- [[30185]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30185) Missing return in db rev 210600003.pl

### Circulation

- [[29220]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29220) Minor fixes and improved code readability in circulation.pl

  **Sponsored by** *Gothenburg University Library*

### Database

- [[30128]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30128) language_subtag_registry.description is too short

### Fines and fees

- [[28663]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28663) One should not be able to apply a discount to a VOID accountline

  >This removes the display of the 'Apply discount' button for VOID transactions.
- [[30132]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30132) overdue_notices.pl POD is incorrect regarding passing options

### Hold requests

- [[29338]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29338) Reprinting holds slip with updated expiration date

  >This patch adds a "Print hold/transfer" button to request.tt so staff can reprint hold/transfer slips without re-checking an item.

### I18N/L10N

- [[29589]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29589) Translation issue with formatting in MARC overlay rules page

### Patrons

- [[22993]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22993) Messaging preferences not set for patrons imported through API
- [[30098]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30098) Patron search redirects when one result on any page of results

### Reports

- [[26269]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26269) Overdues: Download file doesn't match result in staff interface when due date filters or 'show any available items currently checked out' are used

### Searching - Elasticsearch

- [[25616]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25616) Uppercase hard coded lower case boolean operators for Elasticsearch
- [[30153]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30153) FindDuplicate ElasticSearch should not use lowercase 'and'

  **Sponsored by** *Steiermärkische Landesbibliothek*

### Serials

- [[30035]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30035) Wrong month name in numbering pattern

  **Sponsored by** *Orex Digital*

  >Sponsored-by: Orex Digital

### Staff Client

- [[30164]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30164) Header filter not taken into account on the cities view

### Templates

- [[29989]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29989) Improve headings in MARC staging template

### Test Suite

- [[29826]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29826) Manage call of Template Plugin Branches GetName() with null or empty branchcode
- [[30203]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30203) Prevent data loss when running Circulation.t without prove



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)



The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (87.5%)
- Armenian (100%)
- Armenian (Classical) (89%)
- Bulgarian (92.3%)
- Chinese (Taiwan) (79.1%)
- Czech (69.1%)
- English (New Zealand) (59.1%)
- English (USA)
- Finnish (92.3%)
- French (94.6%)
- French (Canada) (93.1%)
- German (100%)
- German (Switzerland) (58.9%)
- Greek (59.6%)
- Hindi (100%)
- Italian (91.4%)
- Nederlands-Nederland (Dutch-The Netherlands) (70.5%)
- Norwegian Bokmål (63.4%)
- Polish (99.4%)
- Portuguese (90.8%)
- Portuguese (Brazil) (83.9%)
- Russian (85.1%)
- Slovak (70%)
- Spanish (99.5%)
- Swedish (82.1%)
- Telugu (95.6%)
- Turkish (97.5%)
- Ukrainian (75.1%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 21.11.03 is


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
We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 21.11.03

- Gothenburg University Library
- Orex Digital
- Steiermärkische Landesbibliothek

We thank the following individuals who contributed patches to Koha 21.11.03

- Tomás Cohen Arazi (9)
- Nick Clemens (4)
- Jonathan Druart (4)
- Marion Durand (1)
- Katrin Fischer (1)
- Lucas Gass (2)
- David Gustafsson (2)
- Kyle M Hall (4)
- Mason James (2)
- Janusz Kaczmarek (1)
- Thomas Klausner (1)
- Owen Leonard (1)
- Martin Renvoize (3)
- Marcel de Rooy (2)
- David Schmidt (1)
- Fridolin Somers (7)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 21.11.03

- Athens County Public Libraries (1)
- BibLibre (8)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (1)
- ByWater-Solutions (10)
- gmx.at (1)
- Independant Individuals (3)
- Koha Community Developers (4)
- KohaAloha (2)
- plix.at (1)
- PTFS-Europe (3)
- Rijksmuseum (2)
- Theke Solutions (9)

We also especially thank the following individuals who tested patches
for Koha

- Tomás Cohen Arazi (3)
- Emmanuel Bétemps (1)
- Nick Clemens (4)
- Michal Denar (1)
- Jonathan Druart (6)
- Katrin Fischer (12)
- Andrew Fuerste-Henry (4)
- Kyle M Hall (39)
- Sally Healey (2)
- Barbara Johnson (1)
- David Nind (4)
- Martin Renvoize (20)
- Fridolin Somers (28)
- Michael Sutherland (1)
- Theodoros Theodoropoulos (1)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 21.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 24 Mar 2022 18:02:35.
