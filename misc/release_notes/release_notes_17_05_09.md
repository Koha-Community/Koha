# RELEASE NOTES FOR KOHA 17.05.09
23 févr. 2018

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 17.05.09 can be downloaded from:

- [Download](http://download.koha-community.org/koha-17.05.09.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 17.05.09 is a bugfix/maintenance release.

It includes 2 enhancements, 38 bugfixes.




## Enhancements

### Cataloging

- [[18417]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18417) Advanced Editor - Rancor - add shortcuts for copyright symbols (C) (P)

### Test Suite

- [[19483]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19483) t/db_dependent/www/* crashes test harness due to misconfigured test plan


## Critical bugs fixed

### Acquisitions

- [[19596]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19596) Internal server error if open order with deleted biblio / null biblionumber

### Architecture, internals, and plumbing

- [[15770]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15770) Number::Format issues with large numbers
- [[19847]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19847) tracklinks.pl accepts any url from a parameter for proxying
- [[20126]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20126) Saving a biblio does no longer update MARC field lengths

### Cataloging

- [[19968]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19968) Undefined subroutine &Date::Calc::Today

### Command-line Utilities

- [[19730]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19730) misc/export_records.pl should use biblio_metadata.timestamp

### Notices

- [[18477]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18477) AR_PENDING notice does not populate values from article_requests table

### OPAC

- [[18915]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18915) Creating a checkout note (patron note) sends an incomplete email message
- [[19911]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19911) Passwords displayed to user during self-registration are not HTML-encoded
- [[19975]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19975) Tag cloud searching does not working

### Patrons

- [[19921]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19921) Error when updating child to adult patron on system with only one adult patron category

### Searching - Elasticsearch

- [[19559]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19559) Elasticsearch QueryAutoTruncate truncate field names with hyphens if data is quoted


## Other bugs fixed

### Acquisitions

- [[19401]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19401) No confirm message when deleting an invoice from invoice detail page
- [[19429]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19429) No confirm message when deleting an invoice from invoice search

### Architecture, internals, and plumbing

- [[19839]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19839) invoice.pl warns about bad variable scope
- [[19985]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19985) TestBuilder.t fails if default circ rule exists

### Circulation

- [[16603]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16603) Hide option to apply directly when processing uploaded offline circulation file
- [[19825]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19825) List of pending offline operations does not links to biblio

### Database

- [[19422]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19422) kohastructure.sql missing DROP TABLES

### Installation and upgrade (web-based installer)

- [[19973]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19973) SQL syntax error in uk-UA/mandatory/sample_notices.sql

### OPAC

- [[17682]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17682) Change URL for Google Scholar in OPACSearchForTitleIn

### Packaging

- [[18696]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18696) Change debian/source/format to quilt
- [[20072]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20072) Fix build-git-snapshot for Debian source format quilt

### Patrons

- [[19443]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19443) Error while attempting to duplicate a patron

### Reports

- [[19669]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19669) Remove deprecated checkouts by patron category report

### Searching

- [[19971]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19971) typo in the comments of parseQuery routine

### Searching - Elasticsearch

- [[19580]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19580) Elasticsearch: QueryAutoTruncate exclude period as splitting character in autotruncation

### Staff Client

- [[19221]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19221) Onboarding tool says user needs to be made superlibrarian

### System Administration

- [[19560]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19560) Unable to delete library when branchcode contains special characters
- [[19977]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19977) Local Use tab in systempreferences tries to open text editor's temporary files, and die
- [[19987]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19987) If no z39.50/SRU servers, the z39.50/SRU buttons should not show

### Templates

- [[19677]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19677) Angle brackets in enumchron do not display in opac or staff side

### Test Suite

- [[19455]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19455) Circulation/SwitchOnSiteCheckouts.t is failing randomly
- [[19705]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19705) DecreaseLoanHighHolds.t is still failing randomly
- [[19783]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19783) Move check_kohastructure.t to db_dependent
- [[19914]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19914) Cannot locate the "Delete" in the library list table
- [[19937]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19937) Silence warnings t/db_dependent/www/batch.t
- [[20042]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20042) 00-load.t fails when Elasticsearch is not installed



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

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- English (USA)
- Arabic (99%)
- Armenian (99%)
- Basque (79%)
- Chinese (China) (83%)
- Chinese (Taiwan) (99%)
- Czech (94%)
- Danish (69%)
- English (New Zealand) (91%)
- Finnish (99%)
- French (96%)
- French (Canada) (94%)
- German (99%)
- German (Switzerland) (99%)
- Greek (79%)
- Hindi (99%)
- Italian (99%)
- Norwegian Bokmål (57%)
- Occitan (76%)
- Persian (57%)
- Polish (99%)
- Portuguese (99%)
- Portuguese (Brazil) (84%)
- Slovak (90%)
- Spanish (100%)
- Swedish (96%)
- Turkish (99%)
- Vietnamese (71%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

for information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 17.05.09 is

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
  - 16.11 -- [Chris Cormack](mailto:chris@bigballofwax.co.nz)

## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 17.05.09:

- Catalyst IT

We thank the following individuals who contributed patches to Koha 17.05.09.

- Aleisha Amohia (5)
- Alex Arnaud (2)
- David Bourgault (1)
- Nick Clemens (8)
- Charlotte Cordwell (2)
- Olivier Crouzet (1)
- Marcel de Rooy (3)
- Jonathan Druart (17)
- Olli-Antti Kivilahti (1)
- Owen Leonard (1)
- Julian Maurice (2)
- Kyle M Hall (1)
- Josef Moravec (1)
- Te Rauhina Jackson (1)
- Grace Smyth (2)
- Fridolin Somers (5)
- Mirko Tietgen (5)
- Mark Tompsett (1)
- Koha translators (1)
- Jesse Weaver (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 17.05.09

- abunchofthings.net (5)
- ACPL (1)
- BibLibre (9)
- bugs.koha-community.org (17)
- ByWater-Solutions (9)
- jns.fi (1)
- Rijksmuseum (3)
- Solutions inLibro inc (1)
- unidentified (13)
- Université Jean Moulin Lyon 3 (1)

We also especially thank the following individuals who tested patches
for Koha.

- Arturo (2)
- Charlotte Cordwell (2)
- Claire Gravely (2)
- David Bourgault (4)
- Dilan Johnpullé (1)
- Eric Phetteplace (1)
- Fridolin Somers (55)
- Grace Smyth (1)
- Jonathan Druart (52)
- Josef Moravec (4)
- Julian Maurice (3)
- Katrin Fischer (4)
- Lee Jamison (1)
- Marjorie Barry-Vila (2)
- Marjorie Vila (3)
- Mark Tompsett (11)
- Mirko Tietgen (2)
- Nick Clemens (56)
- Owen Leonard (8)
- Kyle M Hall (4)
- Marcel de Rooy (16)


We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 17.05.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 23 févr. 2018 09:24:40.
