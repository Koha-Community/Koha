# RELEASE NOTES FOR KOHA 21.11.10
22 Jul 2022

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 21.11.10 can be downloaded from:

- [Download](http://download.koha-community.org/koha-21.11.10.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 21.11.10 is a bugfix/maintenance release.

It includes 2 enhancements, 13 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations

## Enhancements

### Cataloging

- [[30997]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30997) "CGI::param called in list context" warning in detail.pl flooding error log

  >This fixes the cause of "CGI::param called in list context from" warning messages that appear in the log files when viewing record detail pages in the staff interface.

### Templates

- [[30786]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30786) Capitalization in (Opac)AdvancedSearchTypes

  >This fixes the descriptions for the AdvancedSearchTypes and OpacAdvancedSearchTypes system preferences - sentence case is now used for "..Shelving location..".


## Critical bugs fixed

### Cataloging

- [[30234]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30234) Serial local covers don't appear in the staff interface for other libraries with SeparateHoldings

  >This fixes the display of item-specific local cover images in the staff interface. Before this, item images were not shown for holdings on the record's details view page.

### Circulation

- [[29504]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29504) Confirm item parts requires force_checkout permission (checkouts tab)

### Lists

- [[30925]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30925) Creating public list by adding items to new list creates a private list

### Patrons

- [[31005]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31005) Cannot edit patrons in other categories if an extended attribute is mandatory and limited to a category

  >This fixes an error when a mandatory patron attribute limited to a specific patron category was causing a '500 error' when editing a patron not in that category.

### REST API

- [[30677]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30677) Unknown column 'biblioitem.title' in 'where clause' 500 error in API /api/v1/acquisitions/orders

### Searching - Elasticsearch

- [[30883]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30883) Authorities merge is limited to 100 biblio with Elasticsearch

  >This fixes the hard-coded limit of 100 when merging authorities (when Elasticsearch is the search engine). When merging authorities where the term is used over 100 times, only the first 100 authorities would be merged and the old term deleted, irrespective of the value set in the AuthorityMergeLimit system preference.


## Other bugs fixed

### Hold requests

- [[12630]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12630) Prioritizing "Hold starts on date" -holds causes all other holds to be prioritized as well!
- [[28529]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28529) Item type-constrained biblio-level holds should honour max_holds as item-level do
- [[30207]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30207) Librarians with only "place_holds" permission can no longer update hold pickup locations

### I18N/L10N

- [[30958]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30958) OPAC Overdrive search result page broken for translations

  **Sponsored by** *Melbourne Athenaeum Library, Australia*

### Notices

- [[28355]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28355) Add warning note about Email SMS driver option for SMSSendDriver

  >This updates the text for the SMSSendDriver system preference. The Email SMS driver option is no longer recommended unless you use a dedicated SMS to Email gateway. Many mobile providers offer inconsistent support for the email to SMS gateway (sometimes it works, and sometimes it doesn't), which can cause frustration for patrons.

### OPAC

- [[30989]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30989) Tags with some special characters are not encoded right

  >This fixes tags with special characters (such as +) so that the searching returns results when the tag is selected (from the record detail view in the OPAC and staff interface, and from the search results, tag cloud, and list pages in the OPAC).

### Staff Client

- [[30970]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30970) holdst columns don't match actual columns in 'Holds waiting'



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)



The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (87.4%)
- Armenian (100%)
- Armenian (Classical) (89%)
- Bulgarian (92.3%)
- Chinese (Taiwan) (79.5%)
- Czech (76.4%)
- English (New Zealand) (59.1%)
- English (USA)
- Finnish (92.3%)
- French (95.1%)
- French (Canada) (92.9%)
- German (100%)
- German (Switzerland) (58.8%)
- Greek (60.3%)
- Hindi (99.9%)
- Italian (100%)
- Nederlands-Nederland (Dutch-The Netherlands) (86.9%)
- Norwegian Bokmål (63.3%)
- Polish (99.2%)
- Portuguese (91.1%)
- Portuguese (Brazil) (83.8%)
- Russian (84.9%)
- Slovak (73.2%)
- Spanish (100%)
- Swedish (82.3%)
- Telugu (95.3%)
- Turkish (99.6%)
- Ukrainian (75.9%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 21.11.10 is


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
We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 21.11.10

- Melbourne Athenaeum Library, Australia

We thank the following individuals who contributed patches to Koha 21.11.10

- Tomás Cohen Arazi (2)
- Alex Buckley (1)
- Nick Clemens (4)
- Jonathan Druart (3)
- Katrin Fischer (3)
- Lucas Gass (1)
- Kyle M Hall (3)
- Olli-Antti Kivilahti (1)
- David Nind (1)
- Martin Renvoize (5)
- Marcel de Rooy (1)
- Fridolin Somers (1)
- Arthur Suzuki (3)
- Koha translators (1)
- Petro Vashchuk (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 21.11.10

- BibLibre (5)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (3)
- ByWater-Solutions (8)
- Catalyst (1)
- David Nind (1)
- Independant Individuals (1)
- Koha Community Developers (3)
- PTFS-Europe (5)
- Rijksmuseum (1)
- Theke Solutions (2)

We also especially thank the following individuals who tested patches
for Koha

- Tomás Cohen Arazi (22)
- Christopher Brannon (1)
- Jonathan Druart (3)
- Katrin Fischer (8)
- Lucas Gass (21)
- Victor Grousset (2)
- Kyle M Hall (1)
- Lucy Harrison (1)
- Sally Healey (1)
- Owen Leonard (1)
- David Nind (12)
- Martin Renvoize (6)
- Marcel de Rooy (3)
- Fridolin Somers (2)
- Arthur Suzuki (25)



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

Autogenerated release notes updated last on 22 Jul 2022 11:46:22.
