# RELEASE NOTES FOR KOHA 16.11.01
22 Dec 2016

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 16.11.01 can be downloaded from:

- [Download](http://download.koha-community.org/koha-16.11.01.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 16.11.01 is a bugfix/maintenance release.

It includes 34 bugfixes.






## Critical bugs fixed

### Acquisitions

- [[14541]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14541) Tax rate should not be forced to an arbitrary precision
- [[17668]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17668) typo in parcel.pl listinct vs listincgst
- [[17692]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17692) Can't add library EAN under Plack

### Architecture, internals, and plumbing

- [[17676]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17676) Default COLLATE for marc_subfield_structure is not set
- [[17720]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17720) CSRF token is not generated correctly

### Circulation

- [[16376]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16376) Koha::Calendar->is_holiday date truncation creates fatal errors for TZ America/Santiago
- [[17709]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17709) Article request broken

### I18N/L10N

- [[16914]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16914) Export csv in item search, exports all items in one line

### Installation and upgrade (command-line installer)

- [[17292]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17292) Use of DBIx in updatedatabase.pl broke upgrade (from bug 12375)

### Patrons

- [[17344]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17344) Can't set guarantor in quick add brief form

### Searching

- [[15822]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15822) STAFF Advanced search error date utils
- [[16951]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16951) Item search sorting not working properly for most columns
- [[17743]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17743) Item search: indexes build on MARC do not work in item's search

### Web services

- [[17744]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17744) OAI: oai_dc has no element named dcCollection


## Other bugs fixed

### Architecture, internals, and plumbing

- [[17666]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17666) .perl atomic update does not work under kohadevbox
- [[17681]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17681) Existing typos might thow some fees when recieved
- [[17713]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17713) Members.t is failing randomly
- [[17733]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17733) Members.t is still failing randomly

### Circulation

- [[17395]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17395) exporting checkouts in CSV generates a file with wrong extension
- [[17761]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17761) Renewing or returning item via the checkouts table causes lost and damaged statuses to disappear

### Hold requests

- [[17749]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17749) Missing l in '.pl' in link on waitingreserves.tt

### Installation and upgrade (web-based installer)

- [[17577]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17577) Improve sample notices for article requests

### MARC Bibliographic data support

- [[17547]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17547) (MARC21) Chronological term link subfield 648$9 not indexed

### Notices

- [[11274]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11274) Sent Notices Tab Not Working Correctly

### OPAC

- [[17652]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17652) opac-account.pl does not include login branchcode
- [[17696]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17696) Two missing periods in opac-suggestions.tt

### Searching

- [[14699]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14699) Intranet search history issues due to DataTables pagination

### Self checkout

- [[16873]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16873) Renewal error message not specific enough on self check.

### Staff Client

- [[17670]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17670) Grammar mistakes - 'effect' vs. 'affect'

### Test Suite

- [[17714]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17714) Remove itemtype-related t/db_dependent/Members/* warnings
- [[17715]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17715) Remove itemtype-related t/db_dependent/Holds/RevertWaitingStatus.t warnings
- [[17716]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17716) Remove itemtype-related t/db_dependent/CourseReserves.t warnings
- [[17722]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17722) t/db_dependent/PatronLists.t doesn't run inside a transaction
- [[17759]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17759) Fixing theoretical problems with guarantorid in Members.t



## System requirements

Important notes:
    
- Perl 5.10 is required
- Zebra is required

## Documentation

The Koha manual is maintained in DocBook. The home page for Koha 
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
- Arabic (100%)
- Armenian (92%)
- Chinese (China) (86%)
- Chinese (Taiwan) (100%)
- Czech (96%)
- Danish (71%)
- English (New Zealand) (94%)
- Finnish (99%)
- French (99%)
- French (Canada) (92%)
- German (100%)
- German (Switzerland) (100%)
- Greek (78%)
- Hindi (99%)
- Italian (100%)
- Korean (52%)
- Kurdish (51%)
- Norwegian Bokmål (57%)
- Occitan (79%)
- Persian (59%)
- Polish (100%)
- Portuguese (99%)
- Portuguese (Brazil) (87%)
- Slovak (93%)
- Spanish (100%)
- Swedish (99%)
- Turkish (100%)
- Vietnamese (73%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

for information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 16.11.01 is

- Release Managers:
  - [Brendan Gallagher](mailto:brendan@bywatersolutions.com)
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
- QA Manager: [Katrin Fischer](mailto:Katrin.Fischer@bsz-bw.de)
- QA Team:
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
  - [Jonathan Druart](mailto:jonathan.druart@biblibre.com)
  - [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
  - [Marcel de Rooy](mailto:m.de.rooy@rijksmuseum.nl)
  - [Nick Clemens](mailto:nick@bywatersolutions.com)
  - [Jesse Weaver](mailto:jweaver@bywatersolutions.com)
- Bug Wranglers:
  - [Amit Gupta](mailto:amitddng135@gmail.com)
  - [Magnus Enger](mailto:magnus@enger.priv.no)
  - [Mirko Tietgen](mailto:mirko@abunchofthings.net)
  - [Indranil Das Gupta](mailto:indradg@l2c2.co.in)
  - [Zeno Tajoli](mailto:z.tajoli@cineca.it)
  - [Marc Véron](mailto:veron@veron.ch)
- Packaging Manager: [Mirko Tietgen](mailto:mirko@abunchofthings.net)
- Documentation Manager: [Nicole C. Engard](mailto:nengard@gmail.com)
- Translation Manager: [Bernardo Gonzalez Kriegel](mailto:bgkriegel@gmail.com)
- Wiki curators: 
  - [Brooke Johnson](mailto:abesottedphoenix@yahoo.com)
  - [Thomas Dukleth](mailto:kohadevel@agogme.com)
- Release Maintainers:
  - 16.11 -- [Katrin Fischer](mailto:katrin.fischer.83@web.de)
  - 16.05 -- [Mason James](mailto:mtj@kohaaloha.com)
  - 3.22 -- [Julian Maurice](mailto:julian.maurice@biblibre.com)

## Credits

We thank the following libraries who are known to have sponsored
new features in Koha 16.11.01:

- Catalyst IT
- Universidad Nacional de Cordoba

We thank the following individuals who contributed patches to Koha 16.11.01.

- phette23 (1)
- Aleisha Amohia (1)
- Nick Clemens (4)
- Tomás Cohen Arazi (9)
- David Cook (1)
- Frédéric Demians (1)
- Marcel de Rooy (3)
- Jonathan Druart (13)
- Katrin Fischer (2)
- Bernardo González Kriegel (1)
- Chris Kirby (1)
- Owen Leonard (1)
- Julian Maurice (4)
- Kyle M Hall (3)
- Fridolin Somers (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 16.11.01

- ACPL (1)
- BibLibre (5)
- BSZ BW (2)
- bugs.koha-community.org (13)
- ByWater-Solutions (6)
- ilsleypubliclibrary.org (1)
- kylehall.info (1)
- Prosentient Systems (1)
- Rijksmuseum (3)
- Tamil (1)
- Theke Solutions (9)
- unidentified (2)
- Universidad Nacional de Córdoba (1)

We also especially thank the following individuals who tested patches
for Koha.

- Alex Buckley (4)
- Benjamin Rokseth (1)
- Chris Cormack (1)
- Dani Elder (1)
- Edie Discher (1)
- Frédéric Demians (1)
- Hugo Agud (1)
- Jonathan Druart (23)
- Josef Moravec (9)
- Katrin Fischer (50)
- Marc Véron (2)
- Mark Tompsett (5)
- Mirko Tietgen (1)
- Nick Clemens (9)
- Owen Leonard (4)
- Katrin Fischer  (1)
- Tomas Cohen Arazi (6)
- Brendan A Gallagher (2)
- Kyle M Hall (43)
- Marcel de Rooy (8)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 16.11.x.

The last Koha release was 16.11, which was released on November 22, 2016.   

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 22 Dec 2016 21:58:10.
