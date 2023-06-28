# RELEASE NOTES FOR KOHA 22.05.14
28 Jun 2023

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 22.05.14 can be downloaded from:

- [Download](http://download.koha-community.org/koha-22.05.14.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 22.05.14 is a bugfix/maintenance release.

It includes 27 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha [here](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).






## Critical bugs fixed

### Hold requests

- [[30687]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30687) Unable to override hold policy if no pickup locations are available


## Other bugs fixed

### Architecture, internals, and plumbing

- [[32990]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32990) Possible deadlock in C4::ImportBatch::_update_batch_record_counts

### Circulation

- [[32129]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32129) Use patron categorycode of most relevant recall when checking if item can be a waiting recall

  **Sponsored by** *Auckland University of Technology*

  >This patch uses the patron category of the patron who requested the most relevant recall to check for more specific circulation rules relating to recalls. This ensures that patrons who are allowed to place recalls are able to fill their recalls, especially when recalls are not  generally available for all patron categories.

### Command-line Utilities

- [[33626]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33626) compare_es_to_db.pl does not work with Search::Elasticsearch 7.0
- [[33645]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33645) koha-foreach always returns 1 if --chdir not specified
- [[33677]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33677) Remove --verbose from koha-worker manpage

### Hold requests

- [[32627]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32627) Reprinting holds slips should not reset the expiration date
- [[32993]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32993) Holds priority changed incorrectly with dropdown selector
- [[33302]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33302) Placing item level holds in OPAC allows to pick forbidden pick-up locations, but then places no hold

### OPAC

- [[32412]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32412) OPACShelfBrowser controls add extra Coce images to biblio-cover-slider
- [[32701]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32701) Self checkout help page lacks required I18N JavaScript
- [[32995]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32995) Koha agent string not sent for OverDrive fulfillment requests
- [[33233]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33233) OPAC advanced search inputs stay disabled when using browser's back button

### Patrons

- [[32232]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32232) Koha crashes if dateofbirth is 1947-04-27, 1948-04-25, or 1949-04-24
- [[33684]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33684) Able to save patron with empty mandatory date fields

### Plugin architecture

- [[30367]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30367) Plugins: Search explodes in error when searching for specific keywords

### REST API

- [[33470]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33470) Don't calculate overridden values when placing a hold via the REST API

### Searching - Elasticsearch

- [[33206]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33206) Bad title__sort made of multisubfield 245

### Searching - Zebra

- [[32937]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32937) Zebra: Ignore copyright symbol when searching

### Serials

- [[33512]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33512) Labels/buttons are confusing on serials-edit page

### Staff interface

- [[28315]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28315) PopupMARCFieldDoc is defined twice in addbiblio.tt
- [[33642]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33642) Typo: No log found .

### System Administration

- [[33196]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33196) Terminology: rephrase Pseudonymization system preference to be more general
- [[33335]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33335) MARC overlay rules broken because of "categorycode.categorycode " which contains "-"
- [[33586]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33586) Library and category are switched in table configuration for patron search results table settings

### Templates

- [[31405]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31405) Set focus for cursor to setSpec input when adding a new OAI set
- [[31410]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31410) Set focus for cursor to Server name when adding a new Z39.50 or SRU server



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/22.05/ar/html/) (28.2%)
- [Chinese (Taiwan)](https://koha-community.org/manual/22.05/zh_TW/html/) (95.5%)
- [English (USA)](https://koha-community.org/manual/22.05/en/html/)
- [French](https://koha-community.org/manual/22.05/fr/html/) (66.3%)
- [German](https://koha-community.org/manual/22.05/de/html/) (69.5%)
- [Hindi](https://koha-community.org/manual/22.05/hi/html/) (100%)
- [Italian](https://koha-community.org/manual/22.05/it/html/) (41.2%)
- [Spanish](https://koha-community.org/manual/22.05/es/html/) (29.9%)
- [Turkish](https://koha-community.org/manual/22.05/tr/html/) (33.5%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (77.8%)
- Armenian (100%)
- Armenian (Classical) (69.8%)
- Bulgarian (85.6%)
- Chinese (Taiwan) (96%)
- Czech (62.3%)
- English (New Zealand) (68.5%)
- English (USA)
- Finnish (95%)
- French (100%)
- French (Canada) (99.7%)
- German (100%)
- German (Switzerland) (54.1%)
- Greek (56.2%)
- Hindi (100%)
- Italian (100%)
- Nederlands-Nederland (Dutch-The Netherlands) (85.3%)
- Norwegian Bokmål (55.9%)
- Persian (58.7%)
- Polish (100%)
- Portuguese (87.3%)
- Portuguese (Brazil) (78.4%)
- Russian (78.3%)
- Slovak (64.1%)
- Spanish (100%)
- Swedish (79%)
- Telugu (84.5%)
- Turkish (96%)
- Ukrainian (74.1%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 22.05.14 is


- Release Manager: 

## Credits
We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 22.05.14

- Auckland University of Technology

We thank the following individuals who contributed patches to Koha 22.05.14

- Aleisha Amohia (1)
- Nick Clemens (8)
- David Cook (2)
- Jonathan Druart (5)
- emlam (1)
- Katrin Fischer (8)
- Lucas Gass (5)
- Kyle M Hall (1)
- Janusz Kaczmarek (1)
- Marius Mandrescu (1)
- Philip Orr (1)
- Marcel de Rooy (2)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 22.05.14

- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (8)
- ByWater-Solutions (14)
- Catalyst Open Source Academy (1)
- Independant Individuals (1)
- Koha Community Developers (5)
- lmscloud.de (1)
- montgomerycountymd.gov (1)
- Prosentient Systems (2)
- Rijksmuseum (2)
- Solutions inLibro inc (1)

We also especially thank the following individuals who tested patches
for Koha

- Aleisha Amohia (1)
- Tomás Cohen Arazi (35)
- Andrew Auld (3)
- Matt Blenkinsop (22)
- Nick Clemens (7)
- Jonathan Druart (8)
- Magnus Enger (2)
- Laura Escamilla (1)
- Katrin Fischer (7)
- Lucas Gass (34)
- Victor Grousset (1)
- Kyle M Hall (2)
- Barbara Johnson (1)
- Emily Lamancusa (1)
- Owen Leonard (3)
- Marius Mandrescu (1)
- Julian Maurice (1)
- David Nind (10)
- Martin Renvoize (13)
- Marcel de Rooy (6)
- Lisette Scheer (1)
- Michaela Sieber (1)
- Emmi Takkinen (2)
- Hinemoea Viault (1)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is rmain2205.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 28 Jun 2023 14:46:56.
