# RELEASE NOTES FOR KOHA 17.11.03
22 Feb 2018

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 17.11.03 can be downloaded from:

- [Download](http://download.koha-community.org/koha-17.11.03.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 17.11.03 is a bugfix/maintenance release.

It includes 1 enhancements, 42 bugfixes.




## Enhancements

### Acquisitions

- [[10032]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10032) Uncertain prices hide 'close basket' without explanation


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[20126]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20126) Saving a biblio does no longer update MARC field lengths

### Circulation

- [[4319]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=4319) waiting and in transit items cannot be reserved

### Command-line Utilities

- [[19730]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19730) misc/export_records.pl should use biblio_metadata.timestamp

### Notices

- [[18477]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18477) AR_PENDING notice does not populate values from article_requests table

### OPAC

- [[18975]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18975) Wrong CSRF token when emailing cart contents
- [[19975]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19975) Tag cloud searching does not working
- [[19978]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19978) Fix ITEMTYPECAT feature for grouping item types for search

### Templates

- [[20135]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20135) Staff client language choose pop-up can appear off-screen


## Other bugs fixed

### Acquisitions

- [[19928]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19928) Acquisitions' CSV exports should honor syspref "delimiter"
- [[20110]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20110) Don't allow adding same user multiple times to same budget fund

### Architecture, internals, and plumbing

- [[19827]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19827) checkuniquemember is exported from C4::Members but has been removed
- [[19985]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19985) TestBuilder.t fails if default circ rule exists
- [[20031]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20031) CGI param in list context warn in guided_reports.pl
- [[20056]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20056) Uninitialized warn in cmp_sysprefs.pl
- [[20060]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20060) Uninitialized warn from Koha::Template::Plugin::Branches
- [[20088]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20088) Use of uninitialized value in array element in svc/holds

### Circulation

- [[19530]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19530) Prevent multiple transfers from existing for one item
- [[20003]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20003) Result summary of remaining checkouts items not displaying.

### Course reserves

- [[19230]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19230) Warn when deleting a course in course reserves

### Fines and fees

- [[19750]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19750) Overdues without a fine rule add warnings to log

### I18N/L10N

- [[11827]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11827) Untranslatable "Cancel Rating" in jQuery rating plugin
- [[20109]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20109) Allow translating "Remove" in Add Fund
- [[20124]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20124) Allow translating did you mean config save message
- [[20166]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20166) Untranslatable course reserves delete prompt

### ILL

- [[20041]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20041) ILL module missing from more menu in staff when activated

### Installation and upgrade (web-based installer)

- [[12932]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12932) Web installer's Perl version check will not raise errors if all modules are installed

### OPAC

- [[20054]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20054) Remove attribute "text/css" for <style> element used in the OPAC templates

> Prevents warnings about type attribute being generated for <style> elements when testing the OPAC pages using W3C Validator for HTML5.


- [[20068]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20068) Warn on OPAC homepage if not logged in due to OPAC dashboard

### Packaging

- [[17108]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17108) Automatic debian/control updates (stable)
- [[20072]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20072) Fix build-git-snapshot for Debian source format quilt

### REST api

- [[20134]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20134) Remove /api/v1/app.pl from the generated URLs

### Reports

- [[18497]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18497) Downloading a report passes the constructed SQL as a parameter
- [[19669]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19669) Remove deprecated checkouts by patron category report
- [[19671]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19671) Circulation wizard / issues_stats.pl does not populate itemtype descriptions correctly

### Staff Client

- [[20227]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20227) admin/smart-rules.pl should pass categorycode instead of branchcode

### System Administration

- [[20091]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20091) FailedLoginAttempts is not part of NorwegianPatronDatabase pref group

### Templates

- [[20051]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20051) Invalid markup in staff client's header.inc
- [[20156]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20156) Staff client header language menu doesn't show check mark for current language

### Test Suite

- [[19705]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19705) DecreaseLoanHighHolds.t is still failing randomly

### Tools

- [[20098]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20098) Inventory: CSV export: itemlost column is always empty

### Web services

- [[13990]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13990) ILS-DI LookupPatron Requries ID Type

### Z39.50 / SRU / OpenSearch Servers

- [[19986]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19986) 'Server name' doesn't appear as required when creating new z39.50/sru server



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
- Basque (76%)
- Chinese (China) (80%)
- Chinese (Taiwan) (100%)
- Czech (94%)
- Danish (66%)
- English (New Zealand) (99%)
- Finnish (95%)
- French (97%)
- French (Canada) (92%)
- German (99%)
- German (Switzerland) (99%)
- Greek (78%)
- Hindi (99%)
- Italian (99%)
- Norwegian Bokmål (55%)
- Occitan (73%)
- Persian (55%)
- Polish (97%)
- Portuguese (99%)
- Portuguese (Brazil) (81%)
- Slovak (93%)
- Spanish (100%)
- Swedish (91%)
- Turkish (99%)
- Vietnamese (68%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

for information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 17.11.03 is

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
new features in Koha 17.11.03:

- Catalyst IT

We thank the following individuals who contributed patches to Koha 17.11.03.

- Aleisha Amohia (2)
- Alex Arnaud (2)
- Zoe Bennett (1)
- Nick Clemens (5)
- Tomás Cohen Arazi (1)
- Indranil Das Gupta (L2C2 Technologies) (1)
- Marcel de Rooy (9)
- Jonathan Druart (11)
- Victor Grousset (2)
- Pasi Kallinen (5)
- Jon Knight (2)
- Owen Leonard (4)
- Julian Maurice (1)
- Kyle M Hall (4)
- Josef Moravec (1)
- Liz Rea (1)
- Grace Smyth (1)
- Mirko Tietgen (2)
- Mark Tompsett (5)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 17.11.03

-  (0)
- abunchofthings.net (2)
- ACPL (4)
- BibLibre (5)
- bugs.koha-community.org (11)
- ByWater-Solutions (8)
- bywatetsolutions.com (1)
- Catalyst (1)
- joensuu.fi (5)
- l2c2.co.in (1)
- Loughborough University (2)
- Rijksmuseum (9)
- Theke Solutions (1)
- unidentified (10)

We also especially thank the following individuals who tested patches
for Koha.

- Charles Farmer (1)
- Charlotte Cordwell (2)
- Claire Gravely (5)
- Dilan Johnpullé (1)
- Eric Phetteplace (1)
- Jonathan Druart (53)
- Jon Knight (2)
- Josef Moravec (3)
- Julian Maurice (7)
- Katrin Fischer (12)
- maksim (1)
- Maksim Sen (2)
- Mark Tompsett (19)
- Mirko Tietgen (2)
- Nick Clemens (60)
- Owen Leonard (4)
- Pasi Kallinen (5)
- Roch D'Amour (6)
- Kyle M Hall (2)
- Marcel de Rooy (12)


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

Autogenerated release notes updated last on 22 Feb 2018 11:04:09.
