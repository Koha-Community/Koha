# RELEASE NOTES FOR KOHA 22.05.08
22 Dec 2022

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 22.05.08 can be downloaded from:

- [Download](http://download.koha-community.org/koha-22.05.08.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 22.05.08 is a bugfix/maintenance release.

It includes 5 enhancements, 50 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha [here](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).




## Enhancements

### Acquisitions

- [[31459]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31459) Make order receive page faster on systems with many budgets

### Architecture, internals, and plumbing

- [[31776]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31776) Typo in cleanup_database.pl cron's help/usage

### Notices

- [[27265]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27265) process_message_queue.pl cron should be able to take multiple types as a parameter

  >This patch adds the ability to specify several types or letter codes when running the process_message_queue script. This allows libraries to consolidate calls when some message types or letter codes are scheduled differently than others

### Templates

- [[31677]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31677) Convert basic MARC editor tabs to Bootstrap
- [[31678]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31678) Convert authority editor tabs to Bootstrap


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[31785]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31785) Adding or editing library does not respect public flag
- [[32242]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32242) The job has not been sent to the message broker: (Wide character in syswrite ... )

### Circulation

- [[30944]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30944) Fix single cancel recall button in recalls tab in staff interface and correctly handle cancellations with branch transfers

  **Sponsored by** *Catalyst*

  >This fixes the 'cancel' recall button in several places so that it now works as expected (including the recalls tab in a patron's details section, the recalls section for a record, and the circulation recalls queue and recalls to pull pages). It also ensures a correct cancellation reason is logged when cancelling a recall in transit.

### Command-line Utilities

- [[32012]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32012) runreport.pl should use binmode UTF-8

### MARC Bibliographic data support

- [[31869]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31869) Unable to save thesaurus value to frameworks subfields

### OPAC

- [[32114]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32114) Template error in OPAC search results RSS

### Packaging

- [[31588]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31588) Update cpanfile for new OpenAPI versions


## Other bugs fixed

### Acquisitions

- [[29554]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29554) neworderempty.pl may create records with biblioitems.itemtype NULL
- [[31587]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31587) Basket not accessible from ACQORDER notice

  >This makes sure that the basket object is passed to the ACQORDER notice in order to allow adding information about the basket and the order lines within it.
- [[31649]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31649) Acquisition basket CSV export fails if biblio does not exist

### Architecture, internals, and plumbing

- [[20457]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20457) Overdue and pre-overdue cronjobs not skipping phone notices
- [[26648]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26648) Prevent internal server error if item attached to old checkout has been removed
- [[31196]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31196) Key "default_value_for_mod_marc-" cleared from cache but not set anymore
- [[31441]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31441) Koha::Item::as_marc_field ignores subfields where kohafield is an empty string
- [[31469]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31469) log4perl.conf: Plack logfiles need %n in conversionpattern
- [[31920]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31920) Unit test t/db_dependent/Holds.t leaves behind database cruft

### Cataloging

- [[31643]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31643) Link authorities automatically requires ALL cataloging and authorities permissions
- [[31682]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31682) Silence warn when using automatic linker in biblio editor

  **Sponsored by** *Catalyst*

### Circulation

- [[31903]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31903) Article requests: Edit URLs link missing in the New tab

### Documentation

- [[27315]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27315) The man pages for the command line utilities do not display properly

### Fines and fees

- [[29987]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29987) Manual credits are not recorded for a register

  >This fixes the recording of manual credits for patrons so that these transactions are now included in the cash summary report for a library. When adding a manual credit, there are now fields for choosing the transaction type and cash register.

### Hold requests

- [[31540]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31540) Holds reminder cronjob should consider expiration date of holds, and not send notices if hold expired
- [[31575]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31575) Missing warning for holds where AllowHoldPolicyOverride can be used to force a hold to be placed

### I18N/L10N

- [[30517]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30517) Translation breaks editing parent type circulation rule
- [[31738]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31738) Unstranslatable string in checkouts.js for recalls

### MARC Authority data support

- [[19693]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19693) Update of an authority record creates inconsistency when the heading tag is changed
- [[31660]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31660) MARC preview for authority search results comes up empty

### OPAC

- [[31685]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31685) Article request count in table caption of opac-user missing

### Patrons

- [[31739]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31739) Password reset from staff fails if previous expired reset-entry exists

  **Sponsored by** *Lund University Library, Sweden*

### Plugin architecture

- [[31684]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31684) Plugin versions starting with a "v" cause unnecessary warnings

### Reports

- [[28967]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28967) Patrons with no checkouts report shows patrons from other libraries with IndependentBranches
- [[31594]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31594) Report results count of shown can be incorrect on last page

### SIP2

- [[31552]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31552) SIP2 option format_due_date not honored for AH field in item information response

### Searching

- [[15048]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15048) Genre/Form (655) searches fail on searches with $x 'General subdivision' subfield values

### Searching - Elasticsearch

- [[29048]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29048) Incorrect search for linked authority records from authority search result list in OPAC
- [[29561]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29561) Remove blank facet for languages

  >This removes blank facets from search results when using Elasticsearch. Currently, this only seems to affect language fields, but could affect any facetable field that contains blank values.

### Searching - Zebra

- [[31532]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31532) Zebra search results including 880 with original script incorrect because of Bug 15187

### Staff interface

- [[18556]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18556) Message "Patron's address in doubt" is confusing

### System Administration

- [[31619]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31619) Cannot select title when setting non-default value for OPACSuggestionMandatoryFields

  >This fixes the OPACSuggestionMandatoryFields system preference so that the title field is visible and marked as mandatory (in red).
- [[31976]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31976) Incorrect default category selected by authorized values page

### Templates

- [[29671]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29671) Dropbox mode is unchecked after check in confirm on item with Materials specified
- [[31412]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31412) Set focus for cursor to Name when adding a new SMTP server
- [[31420]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31420) Managing funds: Labels of statistic fields overlap with pull downs
- [[31559]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31559) Staff results page doesn't always use up full available screen width
- [[31653]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31653) jQuery upgrade broke search button hover effect

### Test Suite

- [[31593]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31593) Remove Test::DBIx::Class from Context.t
- [[31883]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31883) Filter trim causes false warnings

### Tools

- [[31595]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31595) Import patrons tool should not process extended attributes if no attributes are being imported
- [[31609]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31609) JavaScript error on Additional contents main page
- [[31644]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31644) MARCModification template fails to copy to/from subfield 0



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/22.05/ar/html/) (28.2%)
- [Chinese (Taiwan)](https://koha-community.org/manual/22.05/zh_TW/html/) (49.2%)
- [English (USA)](https://koha-community.org/manual/22.05/en/html/)
- [French](https://koha-community.org/manual/22.05/fr/html/) (58.4%)
- [German](https://koha-community.org/manual/22.05/de/html/) (61.3%)
- [Hindi](https://koha-community.org/manual/22.05/hi/html/) (100%)
- [Italian](https://koha-community.org/manual/22.05/it/html/) (41.2%)
- [Spanish](https://koha-community.org/manual/22.05/es/html/) (29.7%)
- [Turkish](https://koha-community.org/manual/22.05/tr/html/) (33.5%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (77.9%)
- Armenian (100%)
- Armenian (Classical) (71.6%)
- Bulgarian (85.6%)
- Chinese (Taiwan) (90.4%)
- Czech (62.3%)
- English (New Zealand) (56.5%)
- English (USA)
- Finnish (94.8%)
- French (97.1%)
- French (Canada) (99.9%)
- German (100%)
- German (Switzerland) (54.1%)
- Greek (54.3%)
- Hindi (100%)
- Italian (100%)
- Nederlands-Nederland (Dutch-The Netherlands) (84.2%)
- Norwegian Bokmål (56%)
- Persian (58.7%)
- Polish (100%)
- Portuguese (79.3%)
- Portuguese (Brazil) (76.8%)
- Russian (78.4%)
- Slovak (63.9%)
- Spanish (100%)
- Swedish (78.6%)
- Telugu (84.6%)
- Turkish (92%)
- Ukrainian (74.2%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 22.05.08 is


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
  - Martin Renvoize
  - Marcel de Rooy
  - Fridolin Somers

- Topic Experts:
  - UI Design -- Owen Leonard
  - Zebra -- Fridolin Somers
  - REST API -- Martin Renvoize

- Bug Wranglers:
  - Aleisha Amohia
  - Indranil Das Gupta

- Packaging Manager: 


- Documentation Manager: Caroline Cyr La Rose


- Documentation Team:
  - Aude Charillon
  - David Nind
  - Lucy Vaux-Harvey

- Translation Managers: 
  - Bernardo González Kriegel

- Wiki curators: 
  - Thomas Dukleth
  - Katrin Fischer

- Release Maintainers:
  - 22.11 -- PTFS Europe
  - 22.05 -- Lucas Gass
  - 21.11 -- Arthur Suzuki
  - 21.05 -- Wainui Witika-Park

## Credits
We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 22.05.08

- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)
- Lund University Library, Sweden

We thank the following individuals who contributed patches to Koha 22.05.08

- Aleisha Amohia (2)
- Tomás Cohen Arazi (1)
- Kevin Carnes (1)
- Galen Charlton (1)
- Nick Clemens (17)
- David Cook (1)
- Jonathan Druart (3)
- Katrin Fischer (4)
- Lucas Gass (7)
- Isobel Graham (1)
- Kyle M Hall (9)
- Mason James (2)
- Janusz Kaczmarek (2)
- Owen Leonard (8)
- The Minh Luong (1)
- Julian Maurice (1)
- Björn Nylén (1)
- Martin Renvoize (5)
- Marcel de Rooy (15)
- Andreas Roussos (1)
- Fridolin Somers (4)
- Christophe Torin (1)
- Koha translators (1)
- Petro Vashchuk (1)
- Shi Yao Wang (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 22.05.08

- Athens County Public Libraries (8)
- BibLibre (5)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (4)
- ByWater-Solutions (33)
- Catalyst Open Source Academy (2)
- Dataly Tech (1)
- Equinox Open Library Initiative (1)
- Independant Individuals (4)
- Koha Community Developers (3)
- KohaAloha (2)
- Prosentient Systems (1)
- PTFS-Europe (5)
- Rijksmuseum (15)
- Solutions inLibro inc (2)
- Theke Solutions (1)
- ub.lu.se (2)
- Université Rennes 2 (1)

We also especially thank the following individuals who tested patches
for Koha

- Tomás Cohen Arazi (77)
- Emmanuel Bétemps (1)
- Catrina (1)
- Nick Clemens (3)
- David Cook (4)
- Chris Cormack (3)
- Katrin Fischer (37)
- Andrew Fuerste-Henry (1)
- Lucas Gass (86)
- Géraud (1)
- Kyle M Hall (5)
- Barbara Johnson (3)
- Joonas Kylmälä (3)
- Owen Leonard (3)
- David Nind (35)
- Martin Renvoize (12)
- Marcel de Rooy (19)
- Caroline Cyr La Rose (2)
- Cab Vinton (1)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is security-22.05.x-security.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 22 Dec 2022 18:15:12.
