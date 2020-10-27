# RELEASE NOTES FOR KOHA 20.05.05
27 Oct 2020

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 20.05.05 can be downloaded from:

- [Download](http://download.koha-community.org/koha-20.05.05.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 20.05.05 is a bugfix/maintenance release.

It includes 30 enhancements, 31 bugfixes.

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

- [[16357]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16357) Plack error logs are not time stamped

### Cataloging

- [[15933]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15933) Add cataloguing plugin to search for existing publishers in other records
- [[19322]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19322) Typo in UNIMARC field 140 plugin

### Circulation

- [[26424]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26424) Better performance of svc/checkouts

### Command-line Utilities

- [[25624]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25624) Update patrons category script should allow finding null and not null and wildcards
- [[26451]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26451) Small typo in bulkmarcimport.pl

### I18N/L10N

- [[26118]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26118) Move translatable strings out of tags/review.tt and into tags-review.js
- [[26217]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26217) Move translatable strings out of templates into acq.js
- [[26225]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26225) Move translatable strings out of audio_alerts.tt and into audio_alerts.js
- [[26230]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26230) Move translatable strings out of item_search_fields.tt and into item_search_fields.js
- [[26240]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26240) Move translatable strings out of sms_providers.tt and into sms_providers.js
- [[26242]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26242) Move translatable strings out of results.tt and into results.js
- [[26243]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26243) Move translatable strings out of templates and into circulation.js
- [[26256]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26256) Move translatable strings out of templates and into serials-toolbar.js

### OPAC

- [[25242]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25242) Accessibility: The 'Holdings' table partially obscures navigation links at 200% zoom

### Searching - Elasticsearch

- [[24807]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24807) Add "year" type to improve sorting by publication date

### Staff Client

- [[26435]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26435) AutoSelfCheckID syspref description should warn it blocks OPAC access

### Templates

- [[25317]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25317) Move translatable strings out of additem.js.inc
- [[25320]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25320) Move translatable strings out of merge-record-strings.inc into merge-record.js
- [[25321]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25321) Move translatable strings out of strings.inc into the corresponding JavaScript
- [[26120]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26120) Remove the use of jquery.checkboxes plugin from tags review template
- [[26151]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26151) Remove the use of jquery.checkboxes plugin from suggestions management page
- [[26245]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26245) Remove unused functions from members.js
- [[26261]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26261) Split calendar.inc into include file and JavaScript file
- [[26291]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26291) Move translatable strings out of z3950_search.inc into z3950_search.js
- [[26334]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26334) Move translatable strings out of members-menu.inc into members-menu.js
- [[26339]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26339) Move translatable strings out of addorderiso2709.tt into addorderiso2709.js
- [[26504]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26504) Remove the use of jquery.checkboxes plugin from checkout notes page

### Test Suite

- [[26157]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26157) Redirect expected DBI warnings

### Tools

- [[26431]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26431) Use split button to offer choice of WYSIWYG or code editor for news


## Critical bugs fixed

### Acquisitions

- [[26438]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26438) Follow up to bug 23463 - return from Koha::Item overwrites existing variable

### Architecture, internals, and plumbing

- [[26341]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26341) Database update for bug 21443 is not idempotent and will destroy settings
- [[26434]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26434) Plugin dirs duplicates in @INC with plack

### Circulation

- [[26510]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26510) Transport Cost Matrix editor doesn't show all data when HoldsQueueSkipClosed is enabled

### Hold requests

- [[18958]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18958) If patron has multiple record level holds on one record transferring first hold causes next hold to become item level

### Installation and upgrade (web-based installer)

- [[26548]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26548) [20.05] Update for 20.05.03.001 has wrong SQL

### MARC Authority data support

- [[25273]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25273) Elasticsearch Authority matching is returning too many results

### MARC Bibliographic record staging/import

- [[26231]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26231) bulkmarcimport.pl does not import authority if it already has a 001 field

### Notices

- [[26420]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26420) Overdue notices script does not care about borrower's language, always takes default template

### Patrons

- [[26556]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26556) Cities autocomplete broken in patron edition

### Searching - Elasticsearch

- [[25265]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25265) Elasticsearch - Batch editing items on a biblio can lead to incorrect index
- [[26507]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26507) New items not indexed


## Other bugs fixed

### Acquisitions

- [[10921]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10921) You can edit an order even when it is in a closed basket
- [[26497]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26497) "Hide all columns" throws Javascript error on aqplan.pl

### Architecture, internals, and plumbing

- [[26260]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26260) elasticsearch>cnx_pool missing in koha-conf-site.xml.in
- [[26464]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26464) Code correction in opac-main when news_id passed

### Cataloging

- [[19327]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19327) Typo in UNIMARC field 128a plugin
- [[24780]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24780) 952$i stocknumber does not display in batch item modification

### Circulation

- [[26224]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26224) Prevent double submit of header checkin form

### Command-line Utilities

- [[26407]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26407) fix query in 'title exists' in `search_for_data_inconsistencies.pl`
- [[26448]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26448) koha-elasticsearch --commit parameter is not used

### Fines and fees

- [[26541]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26541) Apply discount button misleading
- [[26785]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26785) JS errors in pos/pay.tt in 20.05.x

### Hold requests

- [[23485]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23485) Holds to pull (pendingreserves.pl) should list barcodes
- [[26460]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26460) Wrong line ending (semicolon vs comma) in request.tt

### Lists

- [[25913]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25913) Internal server error when calling get_coins on record with no title (245) but with 880 linked to 245

### OPAC

- [[26512]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26512) Display issue with buttons for OPAC checkout note

### Searching - Elasticsearch

- [[25957]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25957) Elasticsearch 5.X - empty subfields cause error on suggestible fields

### Staff Client

- [[26249]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26249) keep_text class not set inconsistently in cat-search.inc

### Templates

- [[26049]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26049) Replace li with span class results_summary in UNIMARC intranet XSLT

### Tools

- [[26414]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26414) Unable to export Withdrawn status using CSV profile

  >This patch fixes the export of MARC records and the withdrawn status when using CSV profiles. Before this fix the full 952 field was exported, rather than just the withdrawn status.


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

- Arabic (99.3%)
- Armenian (100%)
- Armenian (Classical) (99.7%)
- Chinese (Taiwan) (94.5%)
- Czech (81%)
- English (New Zealand) (67.1%)
- English (USA)
- Finnish (70%)
- French (82.1%)
- French (Canada) (95.5%)
- German (99.2%)
- German (Switzerland) (74.9%)
- Greek (61.9%)
- Hindi (100%)
- Italian (89.6%)
- Norwegian Bokmål (71.6%)
- Polish (73.5%)
- Portuguese (87.6%)
- Portuguese (Brazil) (98.6%)
- Slovak (89.5%)
- Spanish (99.2%)
- Swedish (78%)
- Telugu (90.1%)
- Turkish (94.9%)
- Ukrainian (66.6%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 20.05.05 is


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

We thank the following individuals who contributed patches to Koha 20.05.05.

- Colin Campbell (1)
- Nick Clemens (12)
- David Cook (5)
- Jonathan Druart (14)
- Katrin Fischer (6)
- Andrew Fuerste-Henry (3)
- Lucas Gass (11)
- David Gustafsson (1)
- Kyle Hall (2)
- Mason James (1)
- Joonas Kylmälä (3)
- Owen Leonard (28)
- Martin Renvoize (1)
- Alexis Ripetti (1)
- Marcel de Rooy (1)
- Andreas Roussos (1)
- Fridolin Somers (5)
- Koha Translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 20.05.05

- Athens County Public Libraries (28)
- BibLibre (5)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (6)
- ByWater-Solutions (28)
- Dataly Tech (1)
- Göteborgs Universitet (1)
- Koha Community Developers (14)
- KohaAloha (1)
- Prosentient Systems (5)
- PTFS-Europe (2)
- Rijks Museum (1)
- Solutions inLibro inc (1)
- University of Helsinki (3)

We also especially thank the following individuals who tested patches
for Koha.

- Bob Bennhoff (6)
- Henry Bolshaw (2)
- Nick Clemens (11)
- Chris Cormack (1)
- Michal Denar (1)
- Jonathan Druart (82)
- Bouzid Fergani (1)
- Katrin Fischer (52)
- Andrew Fuerste-Henry (5)
- Bonnie Gardner (1)
- Lucas Gass (87)
- Didier Gautheron (1)
- Victor Grousset (1)
- Kyle Hall (4)
- Sally Healey (1)
- Heather Hernandez (1)
- Brandon Jimenez (2)
- Joonas Kylmälä (4)
- Owen Leonard (1)
- Julian Maurice (3)
- David Nind (22)
- Martin Renvoize (16)
- Alexis Ripetti (4)
- Marcel de Rooy (13)
- Lisette Scheer (2)
- Fridolin Somers (1)
- Arthur Suzuki (5)
- Timothy Alexis Vass (1)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is new-security-release-20.05.05.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 27 Oct 2020 20:41:22.
