# RELEASE NOTES FOR KOHA 19.11.05
22 Apr 2020

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 19.11.05 can be downloaded from:

- [Download](http://download.koha-community.org/koha-19.11.05.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 19.11.05 is a bugfix/maintenance release.

It includes 15 enhancements, 77 bugfixes.

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

### Security

- [[25142]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25142) Staff can access patrons' info from outside of their group
- [[16922]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16922) Add RewriteRule to apache-shared-intranet for dev package installs
- [[25009]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25009) opac-showmarc.pl allows fetching data directly from import batches
   
### Acquisitions

- [[24386]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24386) Prohibit Double Submit to happen when adding to a basket

### Architecture, internals, and plumbing

- [[24103]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24103) Add option to dump built search query to templates

  >This enhancement allows you to view the search query used by Zebra or Elastic Search, to help with troubleshooting. To use, enable the new system preference DumpSearchQueryTemplate, enable DumpTemplateVarsIntranet and DumpTemplateVarsOpac, and then search the page source in the staff interface or OPAC for 'search_query'.
- [[24732]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24732) Make DumpTemplateVars more readable

### Cataloging

- [[7882]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7882) Add ability to move and reorder fields in MARC editor

### Command-line Utilities

- [[19008]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19008) More database cleanups

### OPAC

- [[7611]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7611) Show the NOT_LOAN authorised values for item status in XSLT OPAC search results
- [[15775]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15775) Show message on OPAC summary if holds are blocked due to fines

  **Sponsored by** *Catalyst*

### Patrons

- [[23409]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23409) Show circulation note and OPAC note with line feeds

### Searching

- [[24847]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24847) Select AND by default in items search

### Searching - Elasticsearch

- [[22771]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22771) Elasticsearch - Sort by title do not considerate second indicator of field 245 (marc21)

  >This Elasticsearch enhancement strips the initial characters from search fields in accordance with nonfiling character indicators.

### Serials

- [[24877]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24877) Add link from vendor to linked subscriptions

### System Administration

- [[24844]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24844) Focus on the system preferences searchbar when going to admin home

  **Sponsored by** *Catalyst*

### Templates

- [[23268]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23268) "Suspend all holds" calendar allows to select past date
- [[24875]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24875) Remove extra punctuation from tools home page

### Test Suite

- [[24901]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24901) C4::Circulation::transferbook lacks tests


## Critical bugs fixed

### Acquisitions

- [[24294]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24294) Creating an order with ACQ framework using 00x fields doesn't work with default value

### Architecture, internals, and plumbing

- [[24552]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24552) Koha does not work with Search::Elasticsearch 6.00
- [[24719]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24719) C4::Context::set_remote_address() prevents file upload for non-Plack Koha
- [[24788]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24788) Koha::Object->store calls column names as methods, relying on AUTOLOAD, with possibly surprising results

### Circulation

- [[24765]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24765) Updated on date in Claims returned starts off as 01/01/1970
- [[24802]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24802) Updating holds can cause suspensions to apply to wrong hold

### Command-line Utilities

- [[24527]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24527) misc/cronjobs/update_totalissues.pl problem with multiple items

### ILL

- [[24565]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24565) ILL requests do not display in patron profile in intranet

### OPAC

- [[24711]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24711) Can't log in to OPAC after logout if OpacPublic disabled
- [[24803]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24803) Clicking "Log in to your account" throws fatal Javascript error
- [[24874]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24874) Printing is broken on opac-results.pl page

### REST API

- [[24487]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24487) build_query_params helper builds path parameter with matching criteria

### Reports

- [[25000]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25000) SQL report not updated

### Staff Client

- [[24858]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24858) Incorrect labels on wording in ExcludeHolidaysFromMaxPickUpDelay system preference


## Other bugs fixed

### About

- [[24402]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24402) Some roles missing from about page

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
- [[24767]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24767) "Claim returned" feature cannot be turned off
- [[24829]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24829) ClaimReturnedWarningThreshold is always triggered if patron has one or more claims
- [[24839]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24839) branchtransfers does not deal with holds

### Command-line Utilities

- [[22025]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22025) Argument "" isn't numeric in numeric eq (==) at /usr/share/perl5/DBIx/Class/Row.pm line 1018 for /usr/share/koha/bin/import_patrons.pl
- [[24324]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24324) delete_records_via_leader.pl cron error with item deletion

### Database

- [[22273]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22273) Column article_requests.created_on should not be updated

### Fines and fees

- [[21879]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21879) Code cleaning in printinvoice.pl

### Hold requests

- [[19288]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19288) Holds placed on a specific item after a next available hold will show varied results
- [[24510]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24510) When placing a hold, cursor doesn't focus on patron name
- [[24688]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24688) Hold priority isn't adjusted correctly if checking out a middle priority hold

  **Sponsored by** *Chartered Accountants Australia and New Zealand*
- [[24736]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24736) "Enrollments" not correctly disabled when nobody is enrolled to a club yet

### I18N/L10N

- [[24870]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24870) Translate installer data label

### ILL

- [[24518]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24518) Partner filtering does not work in IE11

### Installation and upgrade (command-line installer)

- [[17464]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17464) Order deny,allow / Deny from all was deprecated in Apache 2.4 and is now a hard error
- [[24851]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24851) No sample libraries for UNIMARC installations
- [[24856]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24856) invalid itemtypes.imageurl in fr-FR sample data
- [[24905]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24905) log4perl-site.conf.in missing entries for the z39.50 server

### Installation and upgrade (web-based installer)

- [[24872]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24872) Set languages system preferences after web install

### Label/patron card printing

- [[23488]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23488) Line wrapping doesn't always respect word order in Patron card creator
- [[23900]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23900) Label maker cannot concatenate database fields

### MARC Bibliographic data support

- [[22969]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22969) fix biblionumber on 001 in UNIMARC XSLT

### MARC Bibliographic record staging/import

- [[24827]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24827) MARC preview fails when staged record contains items with UTF-8 characters

### Notices

- [[23411]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23411) SMS messages sent as print should not fall back to 'email'

### OPAC

- [[23383]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23383) IdRef link appears even with syspref is off
- [[24605]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24605) Series link from 830 is not uri encoded
- [[24892]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24892) Resolve some warnings in opac-memberentry

### Reports

- [[24614]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24614) Can't edit reports if not using cache

### SIP2

- [[24250]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24250) SIP2 returns debarred comment twice in patron screen message AF field
- [[24553]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24553) Cancelling hold via SIP returns a failed response even when cancellation succeeds
- [[24566]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24566) UpdateItemLocationOnCheckin triggers SIP2 alert flag, even with checked_in_ok enabled
- [[24705]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24705) Holds placed via SIP will be given first priority

### Searching

- [[19279]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19279) Performance of linked items in search

### Searching - Elasticsearch

- [[23521]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23521) ES 6 - limit terms with many words can make the search inaccurate
- [[24902]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24902) Elasticsearch - different limits are joined with OR instead of AND

### Staff Client

- [[24747]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24747) Library Transfer Limit page incorrectly describes its behavior
- [[24838]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24838) Help link from patron categories should go to relevant manual page
- [[24848]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24848) Help link from label creator batch/layout/template points to card creator in manual

### System Administration

- [[24682]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24682) Clarify UsageStatsGeolocation syspref description and behaviour

### Templates

- [[23753]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23753) Add missing humanMsg library to pages using background job JavaScript
- [[24627]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24627) Correct style of clubs search results during hold process
- [[24777]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24777) Use patron.is_debarred instead of patron.debarred in return.tt
- [[24798]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24798) smart-rules.tt has erroneous comments
- [[24876]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24876) Fix capitalization on patron search for holds

### Test Suite

- [[24200]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24200) Borrower_PrevCheckout.t failing randomly
- [[24739]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24739) Buster ships with Net::Netmask 1.9104 which supports IPv6
- [[24753]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24753) Typo in filepath for test t/Koha/Middlware/RealIP.t
- [[24756]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24756) Occasional failures for Koha/XSLT/Security.t
- [[24813]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24813) api/v1/holds.t is failing randomly

### Tools

- [[23236]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23236) Remove 'its items may still be processed' in action if no match is found
- [[25020]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25020) Extending due dates to a specified date should preserve time portion of original due date
## New sysprefs

- DumpSearchQueryTemplate

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://koha-community.org/manual/19.11/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (98.9%)
- Armenian (100%)
- Basque (56.4%)
- Chinese (China) (57.2%)
- Chinese (Taiwan) (99.6%)
- Czech (91.7%)
- English (New Zealand) (79.2%)
- English (USA)
- Finnish (75.1%)
- French (95.7%)
- French (Canada) (94.8%)
- German (100%)
- German (Switzerland) (81.7%)
- Greek (70.8%)
- Hindi (100%)
- Italian (86.7%)
- Norwegian Bokmål (84.3%)
- Occitan (post 1500) (53.7%)
- Polish (78.5%)
- Portuguese (100%)
- Portuguese (Brazil) (89.7%)
- Slovak (82.8%)
- Spanish (100%)
- Swedish (85.8%)
- Turkish (99.8%)
- Ukrainian (72.8%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 19.11.05 is


- Release Manager: Martin Renvoize

- Release Manager assistants:
  - Tomás Cohen Arazi
  - Jonathon Druart

- QA Manager: Katrin Fischer

- QA Team:
  - Tomás Cohen Arazi
  - Joonas Kylmälä
  - Jonathan Druart
  - Nick Clemens
  - Kyle Hall
  - Josef Moravec
  - Marcel de Rooy

- Topic Experts:
  - REST API -- Tomás Cohen Arazi
  - SIP2 -- Colin Campbell
  - UI Design -- Owen Leonard
  - Elasticsearch -- Fridolin Somers
  - ILS-DI -- Arthur Suzuki

- Bug Wranglers:
  - Michal Denár
  - Lisette Scheer
  - Cori Lynn Arnold
  - Ami Gupta

- Packaging Manager: Mason James

- Documentation Manager: Caroline Cyr La Rose and David Nind

- Documentation Team:
  - Donna Bachowski
  - Caroline Cyr La Rose
  - Lucy Vaux-Harvey
  - Sugandha Bajaj
  - David Nind

- Translation Managers: 
  - Bernardo González Kriegel

- Release Maintainers:
  - 19.11 -- Joy Nelson
  - 19.05 -- Lucas Gass
  - 18.11 -- Hayley Mapley 
## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 19.11.05:

- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)
- Chartered Accountants Australia and New Zealand

We thank the following individuals who contributed patches to Koha 19.11.05.

- Aleisha Amohia (7)
- Tomás Cohen Arazi (3)
- Alex Arnaud (2)
- Nick Clemens (22)
- David Cook (4)
- Jonathan Druart (33)
- Magnus Enger (1)
- Katrin Fischer (9)
- Andrew Fuerste-Henry (2)
- Lucas Gass (3)
- David Gustafsson (3)
- Kyle Hall (6)
- Mehdi Hamidi (1)
- Andrew Isherwood (2)
- Mason James (1)
- Bernardo González Kriegel (2)
- Owen Leonard (7)
- Hayley Mapley (1)
- Julian Maurice (3)
- Agustín Moyano (2)
- Joy Nelson (7)
- Liz Rea (1)
- Martin Renvoize (8)
- Marcel de Rooy (13)
- Caroline Cyr La Rose (1)
- Andreas Roussos (2)
- Maryse Simard (2)
- Fridolin Somers (12)
- Emmi Takkinen (1)
- Nazlı Çetin (2)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 19.11.05

- ACPL (7)
- Andrews-MacBook-Pro.local (1)
- BibLibre (17)
- BSZ BW (9)
- ByWater-Solutions (39)
- Catalyst (1)
- dataly.gr (2)
- Devinim (2)
- Göteborgs Universitet (3)
- Independant Individuals (9)
- Koha Community Developers (33)
- KohaAloha (1)
- Libriotech (1)
- Prosentient Systems (4)
- PTFS-Europe (10)
- Rijks Museum (13)
- Solutions inLibro inc (4)
- Theke Solutions (5)
- Universidad Nacional de Córdoba (2)

We also especially thank the following individuals who tested patches
for Koha.

- Hugo Agud (1)
- Tomás Cohen Arazi (8)
- Nick Clemens (12)
- Kevin Cook (1)
- David Cook (2)
- Gabriel DeCarufel (1)
- Michal Denar (6)
- Jonathan Druart (50)
- Magnus Enger (2)
- Bouzid Fergani (3)
- Katrin Fischer (41)
- William Frazilien (1)
- Andrew Fuerste-Henry (7)
- Lucas Gass (2)
- Kyle Hall (27)
- Jon Knight (1)
- Bernardo González Kriegel (18)
- Owen Leonard (9)
- Ere Maijala (3)
- Kelly McElligott (2)
- Joy Nelson (153)
- David Nind (17)
- Séverine Queune (3)
- Martin Renvoize (152)
- David Roberts (1)
- Marcel de Rooy (22)
- Sally (7)
- Maryse Simard (4)
- Emmi Takkinen (1)
- Mark Tompsett (6)
- George Williams (1)
- Mengü Yazıcıoğlu (1)
- Jessica Zairo (1)
- Christofer Zorn (1)
- Nazlı Çetin (2)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 19.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 22 Apr 2020 16:57:46.
