# RELEASE NOTES FOR KOHA 17.11.02
23 Jan 2018

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 17.11.02 can be downloaded from:

- [Download](http://download.koha-community.org/koha-17.11.02.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 17.11.02 is a bugfix/maintenance release.

It includes 60 bugfixes and 9 enhancements.

## Enhancements

### Cataloguing

 - [[18417]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18417) Advanced Editor - Rancor - add shortcuts for copyright symbols (C) (P)

### Circulation

 - [[11210]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11210) Allow partial writeoff

### Architecture, internals, plumbing

 - [[19830]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19830) Add the Koha::Patron->old_checkout method

### OPAC

 - [[11976]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11976) Add column settings + new column "Publication date" to the subscription table
 - [[19573]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19573) Link to make a new list in masthead in OPAC only appears / works if no other list already exists
 - [[19338]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19338) Dates sorting incorrectly in opac-account.tt

### Reports

 - [[16782]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16782) Display report URL in staff client report interface

### System Administration

 - [[16764]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16764) Update printers administration page

### Templates

 - [[19860]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19860) Make staff client home page responsive

## Bugs fixed

### Acquisitions

 - [[19694]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19694) Edited shipping cost in invoice doesn't save
 - [[19429]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19429) No confirm message when deleting an invoice from invoice search
 - [[19401]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19401) No confirm message when deleting an invoice from invoice detail page
 - [[19200]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19200) Warns when exporting a basket
 - [[19813]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19813) MarcItemFieldsToOrder cannot handle a tag not existing
 - [[18183]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18183) jQuery append error related to script tags in cloneItemBlock

### Architecture, internals, plumbing

 - [[19599]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19599) anonymise_issue_history can be very slow on large systems
 - [[19756]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19756) Encoding issues when update DB is run from the interface
 - [[19760]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19760) Die instead of warn if koha-conf is not accessible
 - [[19839]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19839) invoice.pl warns about bad variable scope
 - [[15770]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15770) Number::Format issues with large numbers

### Cataloging

 - [[19968]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19968) Undefined subroutine &Date::Calc::Today
 - [[20063]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20063) $9 is lost when cataloguing authority records

### Circulation

 - [[19444]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19444) Automatic renewal script should not auto-renew if a patron's record has expired
 - [[19840]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19840) Patron note is not displayed on checkin
 - [[19798]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19798) Returns.pl doesn't define itemnumber for transfer-slip
 - [[19899]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19899) The float items feature is broken - cannot checkin
 - [[19771]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19771) Pending offline circulation actions page will crash on unknown barcode or on payment action
 - [[16603]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16603) Hide option to apply directly when processing uploaded offline circulation file
 - [[19825]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19825) List of pending offline operations does not links to biblio

### Command-line Utilities

 - [[17467]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17467) Introduce a single koha-zebra script to handle Zebra daemons for instances

### I18N/L10N

 - [[18754]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18754) Translatability: Get rid of exposed tt directives in opac-detail.tt

### ILL

 - [[20001]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20001) ILL: Adding a 'new request' from OPAC is not possible

### Installation and upgrade (web-based installer)

 - [[19514]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19514) No Password restrictions in onboarding tool patron creation

### MARC Authority data support

 - [[18458]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18458) Merging authority record incorrectly orders subfields

### Patrons

 - [[19510]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19510) edi_manage permission has no description
 - [[19621]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19621) Routing lists tab not present when viewing 'Holds history' tab for a patron
 - [[19921]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19921) Error when updating child to adult patron on system with only one adult patron category

### Reports

 - [[19669]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19669) Remove deprecated checkouts by patron category report

### OPAC

 - [[19845]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19845) Patron password is ignored during self-registration if PatronSelfRegistrationVerifyByEmail is enabled
 - [[19450]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19450) OverDrive integration failing on missing method
 - [[19702]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19702) Basket not displaying correctly on home page
 - [[19913]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19913) Embedded HTML5 videos are broken
 - [[19911]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19911) Passwords displayed to user during self-registration are not HTML-encoded
 - [[18915]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18915) Creating a checkout note (patron note) sends an incomplete email message
 - [[17682]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17682) Change URL for Google Scholar in OPACSearchForTitleIn

### Packaging

 - [[18696]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18696) Change debian/source/format to quilt 

### Searching

 - [[19807]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19807) IntranetCatalogSearchPulldown doesn't honor IntranetNumbersPreferPhrase
 - [[19971]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19971) typo in the comments of parseQuery routine

### Searching - Elasticsearch

 - [[19580]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19580) Elasticsearch: QueryAutoTruncate exclude period as splitting character in autotruncation

### Staff client

 - [[19857]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19857) Optionally hide SMS provider field in patron modification screen
 - [[19221]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19221) Onboarding tool says user needs to be made superlibrarian

### System Administration

 - [[19788]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19788) Case sensitivity is not preserved when creating local system preferences
 - [[19977]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19977) Local Use tab in systempreferences tries to open text editor's temporary files, and die
 - [[19987]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19987) If no z39.50/SRU servers, the z39.50/SRU buttons should not show

### Templates

 - [[19851]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19851) Improve responsive layout handling of staff client menu bar
 - [[19918]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19918) span tag not closed in opac-registration-confirmation.tt
 - [[19677]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19677) Angle brackets in enumchron do not display in opac or staff side

### Test Suite

 - [[17770]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17770) t/db_dependent/Sitemapper.t fails when date changes during test run
 - [[19867]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19867) HouseboundRoles.t is failing randomly
 - [[19914]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19914) Cannot locate the "Delete" in the library list table
 - [[19483]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19483) t/db_dependent/www/* crashes test harness due to misconfigured test plan
 - [[19937]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19937) Silence warnings t/db_dependent/www/batch.t
 - [[20042]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20042) 00-load.t fails when Elasticsearch is not installed
 - [[19783]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19783) Move check_kohastructure.t to db_dependent

### Tools

 - [[18201]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18201) Export data -Fix "Remove non-local items" option and add "Removes non-local records" option for existing functionality

### Web services

 - [[19725]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19725) OAI-PMH ListRecords and ListIdentifiers should use biblio_metadata.timestamp

## Security bugs fixed

 - [[19847]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19847) tracklinks.pl accepts any url from a parameter for proxying
 - [[19881]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19881) authorities-list.pl can be executed by anybody
 - [[19738]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19738) XSS in serials module

## System requirements

Important notes:
    
- Perl 5.10 is required
- Zebra is required

## Documentation

The Koha manual is maintained in DocBook.The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://manual.koha-community.org//en/)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](http://git.koha-community.org/gitweb/?p=kohadocs.git;a=summary)



Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

for information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 17.11.02 is

- Release Manager: [Jonathan Druart](mailto:jonathan.druart@bugs.koha-community.org)
- Release Manager assistant: [Nick Clemens](mailto:nick@bywatersolutions.com)
- QA Team:
  - [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
  - [Brendan Gallagher](mailto:brendan@bywatersolutions.com)
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
  - [Julian Maurice](mailto:julian.maurice@biblibre.com)
  - [Marcel de Rooy](mailto:m.de.rooy@rijksmuseum.nl)
- Bug Wranglers:
  - [Amit Gupta](mailto:amitddng135@gmail.com)
  - Claire Gravely
  - Josef Moravec
  - [Marc Véron](mailto:veron@veron.ch)
- Packaging Manager: [Mirko Tietgen](mailto:mirko@abunchofthings.net)
- Documentation Team:
  - [Chris Cormack](mailto:chrisc@catalyst.net.nz)
  - [Katrin Fischer](mailto:Katrin.Fischer@bsz-bw.de)
- Translation Manager: [Bernardo Gonzalez Kriegel](mailto:bgkriegel@gmail.com)
- Release Maintainers:
  - 17.05 -- [Fridolin Somers](mailto:fridolin.somers@biblibre.com)
  - 16.11 -- [Katrin Fischer](mailto:Katrin.Fischer@bsz-bw.de)
  - 16.05 -- [Mason James](mailto:mtj@kohaaloha.com)

## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 17.11.02:

- Catalyst IT

We thank the following individuals who contributed patches to Koha 17.11.02.

- Aleisha Amohia (6)
- David Bourgault (2)
- Alex Buckley (1)
- Nick Clemens (18)
- Tomás Cohen Arazi (1)
- Charlotte Cordwell (2)
- Olivier Crouzet (1)
- Frédéric Demians (1)
- Marcel de Rooy (5)
- Jonathan Druart (36)
- Victor Grousset (1)
- Srdjan Jankovic (1)
- Janusz Kaczmarek (1)
- Olli-Antti Kivilahti (1)
- Owen Leonard (7)
- Julian Maurice (6)
- Kyle M Hall (2)
- Josef Moravec (4)
- Te Rauhina Jackson (1)
- Liz Rea (2)
- Grace Smyth (2)
- Lari Taskula (1)
- Mirko Tietgen (3)
- Mark Tompsett (5)
- Koha translators (1)
- Jesse Weaver (1)
- Chris Weeks (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 17.11.02

-  (0)
- abunchofthings.net (3)
- ACPL (7)
- BibLibre (7)
- bugs.koha-community.org (36)
- ByWater-Solutions (20)
- Catalyst (5)
- jns.fi (2)
- Rijksmuseum (5)
- Solutions inLibro inc (2)
- Tamil (1)
- Theke Solutions (1)
- unidentified (22)
- Université Jean Moulin Lyon 3 (1)

We also especially thank the following individuals who tested patches
for Koha.

- Alex Arnaud (2)
- Arturo (3)
- Björn Nylén (2)
- Charlotte Cordwell (2)
- Claire Gravely (4)
- David Bourgault (6)
- Dilan Johnpullé (3)
- Dominic Pichette (3)
- George Williams (1)
- Grace Smyth (1)
- Jonathan Druart (104)
- Jon Knight (8)
- Josef Moravec (21)
- Julian Maurice (7)
- Katrin Fischer (17)
- Lee Jamison (1)
- Liz Rea (1)
- Marci Chen (1)
- Marc Véron (1)
- Marjorie Barry-Vila (2)
- Marjorie Vila (3)
- Mark Tompsett (10)
- Nick Clemens (122)
- Owen Leonard (12)
- Scott Kehoe (2)
- Simon Pouchol (2)
- Tomas Cohen Arazi (1)
- Kyle M Hall (22)
- Signed-off-by Owen Leonard (1)
- Your Full Name (2)
- Marcel de Rooy (21)
- Mohd Hafiz Yusoff (1)


We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 17.11.X.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 23 Jan 2018 11:37:23.
