# RELEASE NOTES FOR KOHA 19.05.10
22 Apr 2020

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 19.05.10 can be downloaded from:

- [Download](http://download.koha-community.org/koha-19.05.10.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 19.05.10 is a bugfix/maintenance release.

It includes 5 enhancements, 55 bugfixes.

### System requirements

Koha is continiously tested against the following configurations and as such these are the recommendations for 
deployment: 

- Debian Jessie with MySQL 5.5
- Debian Stretch with MariaDB 10.1 (MySQL 8.0 support is experimental)
- Ubuntu Bionic with MariaDB 10.1 (MariaDB 10.3 support is experimental) 

Additional notes:
    
- Perl 5.10 is required
- Zebra or Elasticsearch is required




## Enhancements

### Acquisitions

- [[24386]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24386) Prohibit Double Submit to happen when adding to a basket

### Architecture, internals, and plumbing

- [[24732]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24732) Make DumpTemplateVars more readable

### Cataloging

- [[7882]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7882) Add ability to move and reorder fields in MARC editor

### Command-line Utilities

- [[19008]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19008) More database cleanups

### Templates

- [[24875]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24875) Remove extra punctuation from tools home page


## Critical bugs fixed

### Acquisitions

- [[24294]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24294) Creating an order with ACQ framework using 00x fields doesn't work with default value

### Architecture, internals, and plumbing

- [[24552]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24552) Koha does not work with Search::Elasticsearch 6.00
- [[24719]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24719) C4::Context::set_remote_address() prevents file upload for non-Plack Koha
- [[24788]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24788) Koha::Object->store calls column names as methods, relying on AUTOLOAD, with possibly surprising results

### Cataloging

- [[25144]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25144) Callnumber browser is broken

### Command-line Utilities

- [[24527]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24527) misc/cronjobs/update_totalissues.pl problem with multiple items

### ILL

- [[24565]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24565) ILL requests do not display in patron profile in intranet

### OPAC

- [[24711]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24711) Can't log in to OPAC after logout if OpacPublic disabled
- [[24874]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24874) Printing is broken on opac-results.pl page

### Reports

- [[25000]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25000) SQL report not updated

### Staff Client

- [[24858]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24858) Incorrect labels on wording in ExcludeHolidaysFromMaxPickUpDelay system preference


## Other bugs fixed

### Acquisitions

- [[24733]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24733) Cannot search for duplicate orders using 'Basket created by' field

### Architecture, internals, and plumbing

- [[17532]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17532) koha-shell -c does not propagate the error code

  >Before this development, the koha-shell script would always return a successful error code, making it hard for the callers to notice there was a problem with the command being run inside the instance's shell.
  >
  >This development makes koha-shell propagate the running scripts' error code so the caller can take the required actions.
  >
  >Note: this implies a behaviour change (for good) but a warning should be added to the release notes.
  >
  >Right now it always returns
- [[22943]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22943) The in_ipset C4::Auth function name can be confusing

  **Sponsored by** *Catalyst*
- [[23384]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23384) Calling Koha::Article::Status::* without "use" in Patron.pm can cause breakage
- [[24114]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24114) Remove warn statements from Koha::Patrons
- [[24760]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24760) BackgroundJob tests fail with latest versions of YAML or YAML::Syck
- [[24809]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24809) OAI PMH can fail on fetching deleted records

### Cataloging

- [[5103]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=5103) Dates in MARC details not formatted correctly

  **Sponsored by** *Catalyst*

  >This fixes how dates are displayed for the list of items on the MARC view pages (in the OPAC and staff interface) and the add item page (staff interface) so that they use the 'dateformat' system preference.
- [[8595]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8595) Link to 'host item' confusing

  **Sponsored by** *Catalyst*
- [[21708]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21708) Editing a record moves field 999 to first in the marcxml
- [[24789]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24789) Remove 'ITS' macro format

  >During the initial Rancor (advanced cataloging editor) development an existing macro language was copied. As development continued a Rancor macro language was developed. The new language accomplished all needs of the prior language. The old macro language was intended to be removed before submission to community, but was missed. These patches remove the legacy support in favour of the Koha specific model.

### Circulation

- [[24456]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24456) previousIssuesDefaultSortOrder and todaysIssuesDefaultSortOrder sort incorrectly

### Command-line Utilities

- [[24324]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24324) delete_records_via_leader.pl cron error with item deletion

### Fines and fees

- [[21879]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21879) Code cleaning in printinvoice.pl

### Hold requests

- [[19288]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19288) Holds placed on a specific item after a next available hold will show varied results
- [[24688]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24688) Hold priority isn't adjusted correctly if checking out a middle priority hold

  **Sponsored by** *Chartered Accountants Australia and New Zealand*

### I18N/L10N

- [[24870]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24870) Translate installer data label

### ILL

- [[24518]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24518) Partner filtering does not work in IE11

### Installation and upgrade (command-line installer)

- [[17464]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17464) Order deny,allow / Deny from all was deprecated in Apache 2.4 and is now a hard error
- [[24851]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24851) No sample libraries for UNIMARC installations
- [[24856]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24856) invalid itemtypes.imageurl in fr-FR sample data

### Installation and upgrade (web-based installer)

- [[24872]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24872) Set languages system preferences after web install

### Label/patron card printing

- [[23488]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23488) Line wrapping doesn't always respect word order in Patron card creator
- [[23900]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23900) Label maker cannot concatenate database fields

### MARC Bibliographic data support

- [[22969]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22969) fix biblionumber on 001 in UNIMARC XSLT

### Notices

- [[23411]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23411) SMS messages sent as print should not fall back to 'email'

### OPAC

- [[23383]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23383) IdRef link appears even with syspref is off
- [[23968]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23968) OPACMySummaryNote does not work
- [[24605]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24605) Series link from 830 is not uri encoded
- [[24892]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24892) Resolve some warnings in opac-memberentry

### Reports

- [[24614]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24614) Can't edit reports if not using cache

### SIP2

- [[24250]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24250) SIP2 returns debarred comment twice in patron screen message AF field
- [[24566]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24566) UpdateItemLocationOnCheckin triggers SIP2 alert flag, even with checked_in_ok enabled

### Staff Client

- [[24747]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24747) Library Transfer Limit page incorrectly describes its behavior
- [[24838]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24838) Help link from patron categories should go to relevant manual page
- [[24848]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24848) Help link from label creator batch/layout/template points to card creator in manual

### System Administration

- [[24682]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24682) Clarify UsageStatsGeolocation syspref description and behaviour

### Templates

- [[23753]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23753) Add missing humanMsg library to pages using background job JavaScript
- [[24798]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24798) smart-rules.tt has erroneous comments

### Test Suite

- [[24200]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24200) Borrower_PrevCheckout.t failing randomly
- [[24756]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24756) Occasional failures for Koha/XSLT/Security.t
- [[24813]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24813) api/v1/holds.t is failing randomly

### Tools

- [[23236]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23236) Remove 'its items may still be processed' in action if no match is found
- [[25020]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25020) Extending due dates to a specified date should preserve time portion of original due date


## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://koha-community.org/manual/19.05/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (98.9%)
- Armenian (100%)
- Basque (59.4%)
- Chinese (China) (60%)
- Chinese (Taiwan) (99.7%)
- Czech (92.6%)
- Danish (52.3%)
- English (New Zealand) (83%)
- English (USA)
- Finnish (79.1%)
- French (98.7%)
- French (Canada) (99.4%)
- German (100%)
- German (Switzerland) (86%)
- Greek (73.7%)
- Hindi (100%)
- Italian (90.1%)
- Norwegian Bokmål (88.7%)
- Occitan (post 1500) (56.1%)
- Polish (82.8%)
- Portuguese (100%)
- Portuguese (Brazil) (94.1%)
- Slovak (86.8%)
- Spanish (100%)
- Swedish (88.2%)
- Turkish (99.8%)
- Ukrainian (73%)
- Vietnamese (51%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 19.05.10 is


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
new features in Koha 19.05.10:

- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)
- Chartered Accountants Australia and New Zealand

We thank the following individuals who contributed patches to Koha 19.05.10.

- Aleisha Amohia (5)
- Tomás Cohen Arazi (1)
- Nick Clemens (11)
- David Cook (2)
- Jonathan Druart (21)
- Magnus Enger (1)
- Katrin Fischer (4)
- Andrew Fuerste-Henry (2)
- Lucas Gass (6)
- David Gustafsson (1)
- Kyle Hall (1)
- Andrew Isherwood (2)
- Mason James (1)
- Bernardo González Kriegel (2)
- Owen Leonard (4)
- Hayley Mapley (1)
- Julian Maurice (2)
- Liz Rea (1)
- Martin Renvoize (1)
- Marcel de Rooy (10)
- Caroline Cyr La Rose (1)
- Maryse Simard (2)
- Fridolin Somers (11)
- Koha Translators (1)
- Nazlı Çetin (2)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 19.05.10

- ACPL (4)
- Andrews-MacBook-Pro.local (1)
- BibLibre (13)
- BSZ BW (4)
- ByWater-Solutions (19)
- Catalyst (1)
- Devinim (2)
- Göteborgs Universitet (1)
- Independant Individuals (6)
- Koha Community Developers (21)
- KohaAloha (1)
- Libriotech (1)
- Prosentient Systems (2)
- PTFS-Europe (3)
- Rijks Museum (10)
- Solutions inLibro inc (3)
- Theke Solutions (1)
- Universidad Nacional de Córdoba (2)

We also especially thank the following individuals who tested patches
for Koha.

- Tomás Cohen Arazi (3)
- Nick Clemens (3)
- Kevin Cook (1)
- Gabriel DeCarufel (1)
- Michal Denar (5)
- Jonathan Druart (31)
- Bouzid Fergani (3)
- Katrin Fischer (22)
- William Frazilien (1)
- Andrew Fuerste-Henry (4)
- Lucas Gass (94)
- Kyle Hall (19)
- Sally Healey (2)
- Jon Knight (1)
- Bernardo González Kriegel (11)
- Owen Leonard (5)
- Ere Maijala (1)
- Kelly McElligott (1)
- Joy Nelson (85)
- David Nind (8)
- Séverine Queune (1)
- Martin Renvoize (94)
- Marcel de Rooy (16)
- Maryse Simard (4)
- Emmi Takkinen (1)
- Mark Tompsett (6)
- George Williams (1)
- Mengü Yazıcıoğlu (1)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is rmain1905.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 22 Apr 2020 21:40:11.
