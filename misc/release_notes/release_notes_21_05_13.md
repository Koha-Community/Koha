# RELEASE NOTES FOR KOHA 21.05.13
24 Mar 2022

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 21.05.13 can be downloaded from:

- [Download](http://download.koha-community.org/koha-21.05.13.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 21.05.13 is a bugfix/maintenance release.

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

### I18N/L10N

- [[29596]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29596) Add Yiddish language

  **Sponsored by** *Universidad Nacional de San Martín*

  >This enhancement adds the Yiddish (יידיש) language to Koha. Yiddish now appears as an option for refining search results in the staff interface advanced search (Search > Advanced search > More options > Language and Language of original) and the OPAC (Advanced search > More options > Language).

### Packaging

- [[30084]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30084) Remove dependency of liblocale-codes-perl

### REST API

- [[29877]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29877) MaxReserves should be enforced consistently between staff interface and API
- [[30133]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30133) Pagination broken on pickup_locations routes when AllowHoldPolicyOverride=1

### Searching - Elasticsearch

- [[27770]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27770) ES: Deprecated aggregation order key [_term] used, replaced by [_key]

  **Sponsored by** *Lund University Library*


## Other bugs fixed

### Acquisitions

- [[29287]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29287) Display of funds on acquisitions home is not consistent with display on funds page

### Architecture, internals, and plumbing

- [[29625]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29625) Wrong var name in Koha::BiblioUtils get_all_biblios_iterator
- [[29687]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29687) Get rid of an uninitialized warning in XSLT.pm
- [[30115]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30115) Uninitialized value warning in C4/Output.pm

### Browser compatibility

- [[22671]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22671) Warn the user in offline circulation if applicationCache isn't supported

### Circulation

- [[29220]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29220) Minor fixes and improved code readability in circulation.pl

  **Sponsored by** *Gothenburg University Library*

### Fines and fees

- [[28663]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28663) One should not be able to apply a discount to a VOID accountline

  >This removes the display of the 'Apply discount' button for VOID transactions.
- [[30132]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30132) overdue_notices.pl POD is incorrect regarding passing options

### OPAC

- [[29706]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29706) When placing a request on the opac, the user is shown titles they cannot place a hold on
- [[29795]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29795) If branch is mandatory on patron self registration form, the pull down should default to empty

  >Creates an empty value and defaults to it when PatronSelfRegistrationBorrowerMandatoryField includes branchcode. This forces self registering users to make a choice for the library.

### Patrons

- [[22993]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22993) Messaging preferences not set for patrons imported through API
- [[28576]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28576) Add patron image in patron detail section does not specify image size limit

  >This updates the add patron image screen to specify that the maximum image size is 2 MB. If it is larger, the patron image is not added.
- [[30098]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30098) Patron search redirects when one result on any page of results

### Reports

- [[26269]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26269) Overdues: Download file doesn't match result in staff interface when due date filters or 'show any available items currently checked out' are used
- [[30129]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30129) 500 error when search reports by date

### Searching - Elasticsearch

- [[30153]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30153) FindDuplicate ElasticSearch should not use lowercase 'and'

  **Sponsored by** *Steiermärkische Landesbibliothek*

### Staff Client

- [[30164]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30164) Header filter not taken into account on the cities view

### Templates

- [[29853]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29853) Text needs HTML filter before KohaSpan filter

### Test Suite

- [[30203]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30203) Prevent data loss when running Circulation.t without prove



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/21.05/ar/html/) (34.3%)
- [Chinese (Taiwan)](https://koha-community.org/manual/21.05/zh_TW/html/) (58.8%)
- [Czech](https://koha-community.org/manual/21.05/cs/html/) (27.6%)
- [English (USA)](https://koha-community.org/manual/21.05/en/html/)
- [French](https://koha-community.org/manual/21.05/fr/html/) (60.9%)
- [French (Canada)](https://koha-community.org/manual/21.05/fr_CA/html/) (25.5%)
- [German](https://koha-community.org/manual/21.05/de/html/) (73.5%)
- [Hindi](https://koha-community.org/manual/21.05/hi/html/) (100%)
- [Italian](https://koha-community.org/manual/21.05/it/html/) (48.1%)
- [Spanish](https://koha-community.org/manual/21.05/es/html/) (37%)
- [Turkish](https://koha-community.org/manual/21.05/tr/html/) (40.3%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (89.6%)
- Armenian (100%)
- Armenian (Classical) (89%)
- Chinese (Taiwan) (83.1%)
- Czech (71.1%)
- English (New Zealand) (61.3%)
- English (USA)
- Finnish (82.2%)
- French (92.7%)
- French (Canada) (98.8%)
- German (100%)
- German (Switzerland) (60.5%)
- Greek (55.4%)
- Hindi (100%)
- Italian (94.3%)
- Nederlands-Nederland (Dutch-The Netherlands) (61.5%)
- Norwegian Bokmål (65.6%)
- Polish (100%)
- Portuguese (91.1%)
- Portuguese (Brazil) (86.8%)
- Russian (86.3%)
- Slovak (72.6%)
- Spanish (99.7%)
- Swedish (76.7%)
- Telugu (99.3%)
- Turkish (100%)
- Ukrainian (77.1%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 21.05.13 is


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
new features in Koha 21.05.13

- Gothenburg University Library
- Lund University Library
- Steiermärkische Landesbibliothek
- Universidad Nacional de San Martín

We thank the following individuals who contributed patches to Koha 21.05.13

- Salman Ali (1)
- Tomás Cohen Arazi (12)
- Philippe Blouin (1)
- Kevin Carnes (1)
- Nick Clemens (8)
- Jonathan Druart (3)
- Marion Durand (1)
- Andrew Fuerste-Henry (7)
- Lucas Gass (1)
- David Gustafsson (1)
- Mason James (2)
- Thomas Klausner (1)
- Owen Leonard (1)
- The Minh Luong (1)
- Martin Renvoize (2)
- Marcel de Rooy (2)
- David Schmidt (1)
- Fridolin Somers (2)
- Koha translators (1)
- Petro Vashchuk (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 21.05.13

- Athens County Public Libraries (1)
- BibLibre (3)
- ByWater-Solutions (16)
- gmx.at (1)
- Independant Individuals (2)
- Koha Community Developers (3)
- KohaAloha (2)
- plix.at (1)
- PTFS-Europe (2)
- Rijksmuseum (2)
- Solutions inLibro inc (3)
- Theke Solutions (12)
- ub.lu.se (1)

We also especially thank the following individuals who tested patches
for Koha

- Tomás Cohen Arazi (4)
- Emmanuel Bétemps (1)
- Nick Clemens (1)
- Michal Denar (2)
- Solène Desvaux (1)
- Jonathan Druart (17)
- Katrin Fischer (6)
- Andrew Fuerste-Henry (49)
- Victor Grousset (1)
- Kyle M Hall (40)
- Barbara Johnson (1)
- Owen Leonard (1)
- The Minh Luong (1)
- David Nind (6)
- Martin Renvoize (13)
- Marcel de Rooy (1)
- Sally (1)
- Fridolin Somers (36)
- Michael Sutherland (1)
- Theodoros Theodoropoulos (1)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is rmain2105.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 24 Mar 2022 18:55:06.
