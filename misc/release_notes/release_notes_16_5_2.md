# RELEASE NOTES FOR KOHA 16.5.2
01 août 2016

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 16.5.2 can be downloaded from:

- [Download](http://download.koha-community.org/koha-16.05.02.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 16.5.2 is a bugfix/maintenance release.

It includes 41 enhancements, 71 bugfixes.


## Enhancements

### Architecture, internals, and plumbing

- [[16166]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16166) Improve L1 cache performance and safety
- [[16770]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16770) Remove wrong uses of Memoize::Memcached
- [[16819]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16819) C4::Members::DelMember should use Koha::Holds to delete holds
- [[16847]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16847) Remove C4::Members::GetTitles

### Cataloging

- [[9259]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9259) Delete marc batches from staged marc management

### Circulation

- [[15172]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15172) Serial enumchron/sequence not visible when returning/checking in Items
- [[16531]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16531) Circ overdues report is showing an empty table if no overdues
- [[16566]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16566) 'Print slip' button formatting inconsistent

### Course reserves

- [[15853]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15853) Add author and link columns to opac course reserves table

### I18N/L10N

- [[16601]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16601) Update MARC21 it-IT frameworks to Update 22 (April 2016)

### Installation and upgrade (web-based installer)

- [[16472]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16472) Update MARC21 de-DE frameworks to Update 22 (April 2016)

### OPAC

- [[16651]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16651) Notes field blank for 952$z in opac-course-details.pl
- [[16805]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16805) Log in with database admin user breaks OPAC
- [[16876]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16876) Remove Full heading column in OPAC Authority search

### Patrons

- [[10760]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10760) Use Street Number and Street type in Alternate Address section
- [[16730]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16730) Use member-display-address-style*-includes in moremember-brief.tt

### SIP2

- [[13807]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13807) SIPServer Input loop not checking for closed connections reliably

### Serials

- [[16745]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16745) Add edit catalog and edit items links to serials toolbar

### Staff Client

- [[14790]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14790) Link to OPAC view from within subscriptions, search and item editor
- [[16324]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16324) Move item search into header

### System Administration

- [[16945]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16945) Syspref PatronSelfRegistration: Add note about setting PatronSelfRegistrationDefaultCategory

### Templates

- [[16400]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16400) Proposal to uniform the placement of submit buttons
- [[16469]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16469) Remove the use of "onclick" from some catalog pages
- [[16477]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16477) Improve staff client cart JavaScript and template
- [[16490]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16490) Add an "add to cart" link for each search results in the staff client
- [[16494]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16494) Remove the use of "onclick" from some patron pages
- [[16538]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16538) Improve the style of progress bars
- [[16549]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16549) Remove the use of "onclick" from header search forms
- [[16557]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16557) Remove the use of "onclick" from several include files
- [[16602]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16602) Remove the use of "onclick" from several templates
- [[16677]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16677) Use abbr for authorities linked headings
- [[16772]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16772) Change label from 'For:' to 'Library:' to ease translation
- [[16778]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16778) Use Bootstrap modal for card printing on patron lists page
- [[16801]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16801) Include Font Awesome Icons to check/unchek all in Administration > Library transfer limits
- [[16906]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16906) Add DataTables pagination and filter to top of saved SQL reports table

### Test Suite

- [[13691]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13691) Add some selenium scripts
- [[16866]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16866) Catch warning t/db_dependent/Languages.t

### Tools

- [[16468]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16468) Remove last "onclick" from the stage MARC records template
- [[16513]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16513) Improvements and fixes for quote upload process
- [[16681]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16681) Allow update of opacnote via batch patron modification tool

### Web services

- [[16271]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16271) Allow more filters on /api/v1/holds


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[16716]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16716) Invalid SQL GROUP BY clauses in GetborCatFromCatType and GetAuthorisedValues

### Cataloging

- [[15974]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15974) Rancor - 942c is always displaying first in the list.

### Circulation

- [[16527]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16527) Sticky due date calendar unexpected behaviour
- [[16534]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16534) Error when checking out already checked out item (depending on AllowReturnToBranch)

### Koha

- [[16593]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16593) Access Control - Malicious user can delete the search history of another user
- [[16958]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16958) opac-imageviewer.pl is vulnerable to XSS

### OPAC

- [[16680]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16680) Library name are not displayed for holds in transit
- [[16707]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16707) Software Error in OPAC password recovery when leaving form fields empty

### Staff Client

- [[16947]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16947) Can not modify patron messaging preferences

### Tools

- [[16917]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16917) Error when importing patrons, Column 'checkprevcheckout' cannot be null


## Other bugs fixed

### About

- [[7143]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7143) Bug for tracking changes to the about page

### Acquisitions

- [[16736]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16736) Keep branch filter when changing suggestion
- [[16737]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16737) Error when deleting EDIFACT message
- [[16934]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16934) Cannot add notes to canceled and deleted order line

### Architecture, internals, and plumbing

- [[16431]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16431) Marc subfield structure should be cached using Koha::Cache
- [[16644]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16644) Plack: Use to_app to remove warning about Plack::App::CGIBin instance
- [[16671]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16671) Wrong itemtype picked in HoldsQueue.t
- [[16708]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16708) ElasticSearch - Fix authority reindexing
- [[16724]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16724) Link from online help to manual broken (as of version 16.05)
- [[16731]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16731) Use INSERT IGNORE when inserting a syspref
- [[16742]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16742) Remove unused template subject.tt
- [[16751]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16751) Fix sitemaper typo
- [[16844]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16844) 1 occurrence of GetMemberRelatives has not been removed
- [[16857]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16857) patron-attr-types.tt: Get rid of warnings "Argument "" isn't numeric"

### Authentication

- [[16845]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16845) C4::Members::ModPrivacy is not used

### Cataloging

- [[16807]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16807) Frameworks unordered  in dropdown when adding/editing a biblio

### Circulation

- [[16462]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16462) Change default sorting of circulation patron search results to patron name
- [[16780]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16780) Specify due date always sets time as AM when using 12 hour time format
- [[16854]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16854) request.tt: Logic to display messages broken

### Hold requests

- [[14968]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14968) found shouldn't be set to null when cancelling holds

### I18N/L10N

- [[12509]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12509) Untranslatable "Restriction added by overdues process"
- [[16562]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16562) Translatability: Issue in opac-user.tt (separated word 'item')
- [[16621]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16621) Translatability: Issues in opac-user.tt (sentence splitting)

> Fix translatability issues due to sentence splitting in
koha-tmpl/opac-tmpl/bootstrap/en/modules/opac-user.tt


- [[16697]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16697) Translatability: Fix problem with isolated "'s"in request.tt
- [[16701]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16701) Translatability: Fix problem with isolated ' in currency.tt
- [[16718]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16718) Translatability: Fix problems with sentence splitting by <strong> in about.tt

### Label/patron card printing

- [[14138]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14138) Patroncard: Warn user if PDF creation fails
- [[16459]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16459) Adding patrons to a patron card label batch requires 'routing' permission

### Lists

- [[16897]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16897) Re-focus on "Add item" in Lists

### Notices

- [[16624]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16624) Times are formatted incorrectly in slips ( AM PM ) due to double processing

### OPAC

- [[2735]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=2735) Authority search in OPAC stops at 15 pages
- [[15636]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15636) DataTables Warning: Requested unknown parameter from opac-detail.tt

### Packaging

- [[16823]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16823) Comment out koha-rebuild-zebra in debian/koha-common.cron.d

### Patrons

- [[16612]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16612) Cannot set "Until date" for "Enrollment period" for Patron Categories
- [[16779]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16779) Move road type after address in US style address formatting (main address)
- [[16795]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16795) Patron categories: Accept integers only for enrolment period and age limits
- [[16810]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16810) Fines note not showing on checkout

### Reports

- [[16760]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16760) Circulation Statistics wizard not populating itemtype correctly

### SIP2

- [[15006]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15006) Need to distinguish client timeout from login timeout

### Searching

- [[16777]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16777) Correct intranet search alias

### Serials

- [[12178]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12178) Serial claims: exporting late issues with the CSV profile doesn't set the issue claimed
- [[16705]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16705) Status missing in Opac, serials subscription history

### System Administration

- [[15929]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15929) typo in explanation for MaxSearchResultsItemsPerRecordStatusCheck
- [[16762]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16762) Record matching rules: Remove match check link removes too much
- [[16813]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16813) OPACBaseURL cannot be emptied

### Templates

- [[16600]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16600) Remove some obsolete references to Greybox in some templates
- [[16774]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16774) Format date on 'Transfers to receive' page to dateformat system preference
- [[16781]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16781) Add Font Awesome Icons to "Select/Clear all" links to modborrows.tt and result.tt
- [[16793]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16793) Use Font Awesome for arrows instead of images in audio_alerts.tt
- [[16794]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16794) Revise layout for Admistration > Patron categories
- [[16803]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16803) Add Font Awesome Icons to "Select/Clear all" links to shelves.tt
- [[16812]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16812) Revise JS script for z3950_search.tts and remove onclick events
- [[16888]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16888) Add Font Awesome Icons to Members
- [[16893]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16893) Missing closing tag disrupts patron detail page style
- [[16900]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16900) Hold suspend button incorrectly styled in patron holds list

### Test Suite

- [[16860]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16860) Catch warning t/db_dependent/ClassSource.t
- [[16869]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16869) Silence and catch warnings in t/db_dependent/SuggestionEngine_ExplodedTerms.t
- [[16890]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16890) TestBuilder always generate datetime for dates

### Tools

- [[16682]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16682) Fix display if Batch patron modification tool does not get any patrons
- [[16855]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16855) Poor performance due to high overhead of SQL call in export.pl
- [[16859]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16859) Fix wrong item field name in export.pl



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
- Armenian (97%)
- Chinese (China) (90%)
- Chinese (Taiwan) (99%)
- Czech (96%)
- Danish (75%)
- English (New Zealand) (99%)
- Finnish (94%)
- French (90%)
- French (Canada) (90%)
- German (100%)
- German (Switzerland) (99%)
- Greek (79%)
- Italian (100%)
- Korean (55%)
- Kurdish (53%)
- Norwegian Bokmål (61%)
- Persian (62%)
- Polish (100%)
- Portuguese (100%)
- Portuguese (Brazil) (92%)
- Slovak (96%)
- Spanish (100%)
- Swedish (80%)
- Turkish (100%)
- Vietnamese (76%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

for information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 16.5.2 is

- Release Manager: [Brendan Gallagher](mailto:brendan@bywatersolutions.com)
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
  - [Brook](mailto:)
  - [Thomas Dukleth](mailto:kohadevel@agogme.com)
- Release Maintainers:
  - 16.05 -- [Frédéric Demians](mailto:f.demians@tamil.fr)
  - 3.22 -- [Julian Maurice](mailto:julian.maurice@biblibre.com)
  - 3.20 -- [Chris Cormack](mailto:chrisc@catalyst.net.nz)

## Credits

We thank the following libraries who are known to have sponsored
new features in Koha 16.5.2:

- Catalyst IT
- NEKLS
- Universidad de El Salvador

We thank the following individuals who contributed patches to Koha 16.5.2.

- NguyenDuyTinh (1)
- Marc (2)
- Aleisha (4)
- Jacek Ablewicz (2)
- Morgane Alonso (1)
- Alex Arnaud (1)
- Colin Campbell (5)
- Hector Castro (11)
- Galen Charlton (1)
- Nick Clemens (7)
- Tomás Cohen Arazi (2)
- Chris Cormack (2)
- Frédéric Demians (1)
- Marcel de Rooy (10)
- Jonathan Druart (47)
- Magnus Enger (1)
- Bouzid Fergani (1)
- Katrin Fischer (2)
- Claire Gravely (1)
- Srdjan Jankovic (1)
- Olli-Antti Kivilahti (1)
- Owen Leonard (19)
- Florent Mara (1)
- Julian Maurice (1)
- Kyle M Hall (11)
- Fridolin Somers (3)
- Zeno Tajoli (1)
- Lyon3 Team (1)
- Mark Tompsett (5)
- Marc Véron (21)
- Jesse Weaver (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 16.5.2

- ACPL (19)
- arts.ac.uk (1)
- BibLibre (9)
- biblos.pk.edu.pl (2)
- BSZ BW (2)
- bugs.koha-community.org (45)
- ByWater-Solutions (19)
- Catalyst (3)
- Cineca (1)
- jns.fi (1)
- Libriotech (1)
- Marc Véron AG (23)
- PTFS-Europe (5)
- Rijksmuseum (10)
- Solutions inLibro inc (1)
- Tamil (1)
- Theke Solutions (2)
- unidentified (22)
- Université Jean Moulin Lyon 3 (1)

We also especially thank the following individuals who tested patches
for Koha.

- Andrew Brenza (1)
- Arslan Farooq (1)
- Benjamin Rokseth (1)
- Brendan Gallagher (3)
- Broust (2)
- Chris Cormack (5)
- Claire Gravely (7)
- FILIPPOS KOLOVOS (1)
- Frédéric Demians (170)
- Galen Charlton (1)
- Hector Castro (22)
- Jacek Ablewicz (3)
- Jesse Weaver (2)
- JM Broust (1)
- Jonathan Druart (70)
- Katrin Fischer (30)
- Liz Rea (1)
- Marc Véron (27)
- Mark Tompsett (10)
- Mirko Tietgen (2)
- Nick Clemens (11)
- Owen Leonard (24)
- Srdjan (15)
- Nikos Chatzakis, Afrodite Malliari (1)
- Tomas Cohen Arazi (10)
- Alain et Aurélie (2)
- Nicole C Engard (2)
- Kyle M Hall (193)
- Bernardo Gonzalez Kriegel (2)
- Marcel de Rooy (16)
- Eivin Giske Skaaren (1)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 16.05.x.
The last Koha release was 3.22.8, which was released on June 24, 2016.  

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 01 août 2016 11:49:12.
