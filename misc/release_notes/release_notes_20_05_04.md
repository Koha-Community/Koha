# RELEASE NOTES FOR KOHA 20.05.04
22 Sep 2020

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 20.05.04 can be downloaded from:

- [Download](http://download.koha-community.org/koha-20.05.04.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 20.05.04 is a bugfix/maintenance release.

It includes 23 enhancements, 40 bugfixes.

### System requirements

Koha is continuously tested against the following configurations and as such these are the recommendations for 
deployment: 

- Debian Jessie with MySQL 5.5 (End of life)
- Debian Stretch with MariaDB 10.1
- Debian Buster with MariaDB 10.3
- Ubuntu Bionic with MariaDB 10.1 
- Debian Stretch with MySQL 8.0 (Experimental MySQL 8.0 support)

Additional notes:
    
- Perl 5.10 is required (5.24 is recommended)
- Zebra or Elasticsearch is required




## Enhancements

### Architecture, internals, and plumbing

- [[23632]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23632) Remove C4::Logs::GetLogs
- [[26251]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26251) Remove unused routines from svc/split_callnumbers

### Cataloging

- [[16314]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16314) Show upload link for upload plugin in basic MARC editor

### Command-line Utilities

- [[26175]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26175) Remove warn if undefined barcode in misc/export_records.pl

### Installation and upgrade (web-based installer)

- [[25129]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25129) Update German (de-DE) web installer files for 20.05

### Notices

- [[25639]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25639) Add search queries to HTML so queries can be retrieved via JS

### OPAC

- [[26041]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26041) Accessibility: The date picker calendar is not keyboard accessible

### Reports

- [[25605]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25605) Exporting report as a tab delimited file can produce a lot of warnings

### Staff Client

- [[26007]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26007) Warning/reminder for changes to Koha to MARC mapping

  >In current versions of Koha you can no longer change the Koha to MARC mappings from the frameworks, but only from the Koha to MARC mapping page in administration. This patch cleans up the hints on the framework page and adds a well visible note on the Koha to MARC mapping page. Any changes to the mappings require that you run the batchRebuildBiblioTables script to fully take effect.
- [[26182]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26182) Clearly pair UpdateItemWhenLostFromHoldList and CanMarkHoldsToPullAsLost system preferences

### System Administration

- [[25945]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25945) Description of AuthoritySeparator is misleading

### Templates

- [[26149]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26149) Remove jquery.checkboxes plugin from problem reports page
- [[26150]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26150) Remove the use of jquery.checkboxes plugin from inventory page
- [[26153]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26153) Remove the use of jquery.checkboxes plugin from items lost report
- [[26159]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26159) Remove the use of jquery.checkboxes plugin from batch record delete page
- [[26201]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26201) Remove the use of jquery.checkboxes plugin from batch extend due dates page
- [[26202]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26202) Remove the use of jquery.checkboxes plugin from batch record modification page
- [[26204]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26204) Remove the use of jquery.checkboxes plugin from staff interface lists
- [[26212]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26212) Remove the use of jquery.checkboxes plugin from pending offline circulations
- [[26214]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26214) Remove the use of jquery.checkboxes plugin on late orders page
- [[26215]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26215) Remove the use of jquery.checkboxes plugin from Z39.50 search pages
- [[26216]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26216) Remove the use of jquery.checkboxes plugin from catalog search results

### Tools

- [[26013]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26013) Date on 'manage staged MARC records' is not formatted correctly


## Critical bugs fixed

### Acquisitions

- [[25750]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25750) Fallback to ecost_tax_included, ecost_tax_excluded not happening when no 'Actual cost' entered

  **Sponsored by** *Horowhenua District Council*
- [[26082]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26082) Follow up to bug 23463 - need to call Koha::Item store to get itemnumber

### Circulation

- [[26078]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26078) "Item returns to issuing library" creates infinite transfer loop

### Fines and fees

- [[26023]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26023) Incorrect permissions handling for cashup actions on the library level registers summary page

### Hold requests

- [[24683]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24683) Holds on biblios with different item types: rules for holds allowed are not applied correctly if any item type is available

### Installation and upgrade (command-line installer)

- [[26265]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26265) Makefile.PL is missing pos directory

### OPAC

- [[26069]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26069) Twitter share button leaks information to Twitter

### Reports

- [[26090]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26090) Catalog by itemtype report fails if SQL strict mode is on

### Searching - Elasticsearch

- [[26309]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26309) Elasticsearch cxn_pool must be configurable (again)


## Other bugs fixed

### Acquisitions

- [[25751]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25751) When an ORDERED suggestion is edited, the status resets to "No status"

### Architecture, internals, and plumbing

- [[21539]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21539) addorderiso2709.pl forces librarian to select a ccode and notforloan code when using MarcItemFieldsToOrder
- [[26228]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26228) Update gulpfile to work with Node.js v12
- [[26270]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26270) XISBN.t is failing since today
- [[26331]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26331) svc/letters/preview is not executable which prevents CGI functioning

### Cataloging

- [[26233]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26233) Edit item date sort still does not sort correctly
- [[26289]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26289) Deleting biblio in labeled MARC view doesn't work

### Circulation

- [[25584]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25584) When a 'return claim' is added, the button disappears, but the claim date doesn't show up
- [[25958]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25958) Allow LongOverdue cron to exclude specified lost values
- [[26076]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26076) Paying selected accountlines in full may result in the error "You must pay a value less than or equal to $x"
- [[26361]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26361) JS error on returns.tt in 20.05
- [[26362]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26362) Overdue report shows incorrect branches for patron, holdingbranch, and homebranch

### Fines and fees

- [[26189]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26189) Table options on points of sale misaligned

### I18N/L10N

- [[25626]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25626) Translation issues with OPAC problem reports (status and 'sent to')

### Installation and upgrade (web-based installer)

- [[25448]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25448) Update German (de-DE) framework files

### OPAC

- [[26119]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26119) Patron attribute option to display in OPAC is not compatible with PatronSelfRegistrationVerifyByEmail
- [[26127]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26127) When reporting an Error from the OPAC, the URL does not display
- [[26388]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26388) Renew all and Renew selected buttons should account for items that can't be renewed

### Packaging

- [[25778]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25778) koha-plack puts duplicate entries into PERL5LIB when multiple instances named

### REST API

- [[25662]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25662) Create hold route does not check maxreserves syspref
- [[26271]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26271) Call to /api/v1/patrons/<patron_id>/account returns 500 error if manager_id is NULL

### Reports

- [[17801]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17801) 'Top Most-circulated items' gives wrong results when filtering by checkout date

### SIP2

- [[25903]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25903) Sending a SIP patron information request with a summary field flag in indexes 6-9 will crash server

### Searching

- [[17661]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17661) Differences in field ending (whitespace, punctuation) cause duplicate facets

### Searching - Elasticsearch

- [[25872]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25872) Advanced search on OPAC with limiter but no search term fails when re-sorted
- [[26313]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26313) "Show analytics" and "Show volumes" links don't work with Elasticsearch and UseControlNumber

### Self checkout

- [[25791]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25791) SCO print dialog pops up twice

### Templates

- [[26213]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26213) Remove the use of jquery.checkboxes plugin when adding orders from MARC file
- [[26324]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26324) Spelling error resizeable vs resizable

### Test Suite

- [[24147]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24147) Objects.t is failing randomly

### Tools

- [[26236]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26236) log viewer does not translate the interface properly
## New sysprefs

- DefaultLongOverdueSkipLostStatuses

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://koha-community.org/manual/20.05/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (100%)
- Armenian (100%)
- Armenian (Classical) (99.7%)
- Chinese (Taiwan) (94.1%)
- Czech (81.5%)
- English (New Zealand) (67.7%)
- English (USA)
- Finnish (70.4%)
- French (82.1%)
- French (Canada) (96%)
- German (97.7%)
- German (Switzerland) (75.5%)
- Greek (60.6%)
- Hindi (100%)
- Italian (81.4%)
- Norwegian Bokmål (72.2%)
- Polish (74%)
- Portuguese (88.3%)
- Portuguese (Brazil) (99.4%)
- Slovak (89.1%)
- Spanish (100%)
- Swedish (78.5%)
- Telugu (90.9%)
- Turkish (93.5%)
- Ukrainian (65.9%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 20.05.04 is


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

- Packaging Manager: Mason James


- Documentation Managers:
  - Caroline Cyr La Rose
  - David Nind

- Documentation Team:
  - Donna Bachowski
  - Lucy Vaux-Harvey
  - Sugandha Bajaj

- Translation Manager: Bernardo González Kriegel


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
new features in Koha 20.05.04:

- Horowhenua District Council

We thank the following individuals who contributed patches to Koha 20.05.04.

- Tomás Cohen Arazi (8)
- Alex Buckley (1)
- Colin Campbell (1)
- Nick Clemens (12)
- David Cook (3)
- Jonathan Druart (14)
- Katrin Fischer (6)
- Andrew Fuerste-Henry (2)
- Lucas Gass (8)
- Didier Gautheron (1)
- Kyle Hall (7)
- Joonas Kylmälä (2)
- Owen Leonard (14)
- Andrew Nugged (5)
- Martin Renvoize (4)
- Marcel de Rooy (4)
- Caroline Cyr La Rose (1)
- Fridolin Somers (1)
- Koha Translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 20.05.04

- Athens County Public Libraries (14)
- BibLibre (2)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (6)
- ByWater-Solutions (29)
- Catalyst (1)
- Independant Individuals (5)
- Koha Community Developers (14)
- Prosentient Systems (3)
- PTFS-Europe (5)
- Rijks Museum (4)
- Solutions inLibro inc (1)
- Theke Solutions (8)
- University of Helsinki (2)

We also especially thank the following individuals who tested patches
for Koha.

- Marco Abi-Ramia (1)
- Tomás Cohen Arazi (4)
- Nick Clemens (5)
- Rebecca Coert (1)
- Holly Cooper (2)
- Sarah Cornell (1)
- Jonathan Druart (76)
- Katrin Fischer (47)
- Andrew Fuerste-Henry (2)
- Daniel Gaghan (1)
- Jeff Gaines (1)
- Lucas Gass (86)
- Didier Gautheron (1)
- Amit Gupta (12)
- Kyle Hall (6)
- Sally Healey (4)
- Brandon Jimenez (2)
- Joonas Kylmälä (3)
- Owen Leonard (7)
- Kelly McElligott (4)
- Josef Moravec (1)
- Agustín Moyano (5)
- David Nind (1)
- Martin Renvoize (20)
- Marcel de Rooy (2)
- Lisette Scheer (4)
- Fridolin Somers (8)
- Emmi Takkinen (1)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is new-security-release-20.05.04.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 22 Sep 2020 18:14:38.
