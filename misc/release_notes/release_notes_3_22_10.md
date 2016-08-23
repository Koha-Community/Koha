# RELEASE NOTES FOR KOHA 3.22.10
25 Aug 2016

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 3.22.10 can be downloaded from:

- [Download](http://download.koha-community.org/koha-3.22.10.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 3.22.10 is a security release.

It includes 12 security fixes, 85 bugfixes, and 11 enhancements.

## Security bugs fixed

- [[16878]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16878) Cross-Site Scripting opac-memberentry
- [[16958]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16958) opac-imageviewer.pl is vulnerable to XSS
- [[17021]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17021) returns.pl is vulnerable to XSS attacks
- [[17022]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17022) branchtransfers.pl is vulnerable to XSS attacks
- [[17023]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17023) z3950_search.pl are vulnerable to XSS attacks
- [[17024]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17024) viewlog.pl is vulnerable to XSS attacks
- [[17025]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17025) serials-search.pl is vulnerable to XSS attacks
- [[17026]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17026) checkexpiration.pl is vulnerable to XSS attacks
- [[17028]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17028) request.pl is vulnerable to XSS attacks
- [[17029]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17029) &#42;detail.pl are vulnerable to XSS attacks
- [[17036]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17036) circulation.pl is vulnerable to XSS attacks
- [[17038]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17038) search.pl is vulnerable to XSS attacks

## Critical bugs fixed

### Architecture, internals, and plumbing

- [[16716]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16716) Invalid SQL GROUP BY clauses in GetborCatFromCatType and GetAuthorisedValues

### Cataloging

- [[10148]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10148) 007 not filling in with existing values
- [[14844]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14844) Corrupted storable string. When adding/editing an Item, cookie LastCreatedItem might be corrupted.
- [[15974]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15974) Rancor - 942c is always displaying first in the list.

### Circulation

- [[16527]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16527) Sticky due date calendar unexpected behaviour
- [[16534]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16534) Error when checking out already checked out item (depending on AllowReturnToBranch)

### Hold requests

- [[16988]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16988) Suspending a hold with AutoResumeSuspendedHolds disabled results in error

### Installation and upgrade (web-based installer)

- [[16573]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16573) Web installer fails to load structure and sample data on MySQL 5.7

### OPAC

- [[7441]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7441) Search results showing wrong branch
- [[16593]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16593) Access Control - Malicious user can delete the search history of another user
- [[16996]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16996) Template process failed: undef error - Can't call method "description"

### Staff Client

- [[16955]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16955) Internal Server Error while populating new framework


## Other bugs fixed

### Acquisitions

- [[16736]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16736) Keep branch filter when changing suggestion
- [[16934]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16934) Cannot add notes to canceled and deleted order line

### Architecture, internals, and plumbing

- [[16644]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16644) Plack: Use to_app to remove warning about Plack::App::CGIBin instance
- [[16742]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16742) Remove unused template subject.tt
- [[16751]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16751) Fix sitemaper typo
- [[16848]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16848) Wrong warning "Invalid date ... passed to output_pref" can be carped
- [[16857]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16857) patron-attr-types.tt: Get rid of warnings "Argument "" isn't numeric"
- [[16971]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16971) Missing dependency for HTML::Entities
- [[17087]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17087) Set Test::WWW::Mechanize version to 1.42

### Authentication

- [[16818]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16818) CAS redirect broken under Plack

### Circulation

- [[16780]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16780) Specify due date always sets time as AM when using 12 hour time format
- [[16854]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16854) request.tt: Logic to display messages broken
- [[17001]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17001) filtering overdue report by due date can fail if TimeFormat is 12hr
- [[17055]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17055) Add classes to different note types to allow for styling on checkins page

### Command-line Utilities

- [[16974]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16974) koha-plack should check and fix log files permissions

### Hold requests

- [[14968]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14968) found shouldn't be set to null when cancelling holds

### I18N/L10N

- [[12509]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12509) Untranslatable "Restriction added by overdues process"
- [[16621]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16621) Translatability: Issues in opac-user.tt (sentence splitting)
- [[16697]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16697) Translatability: Fix problem with isolated "'s"in request.tt
- [[16701]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16701) Translatability: Fix problem with isolated ' in currency.tt
- [[16718]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16718) Translatability: Fix problems with sentence splitting by &lt;strong&gt; in about.tt
- [[16776]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16776) If language is set by external link language switcher does not work
- [[16871]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16871) Translatability: Avoid [%%-problem and fix related sentence splitting in catalogue/detail.tt

### Installation and upgrade (command-line installer)

- [[17044]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17044) Wrong destination for 'api' directory

### Koha

- [[16969]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16969) Vulnerability warning for opac/opac-memberentry.pl
- [[16975]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16975) DSA-3628-1 perl -- security update

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
- [[16806]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16806) "Too soon" renewal error generates no alert for user
- [[17068]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17068) empty list item in opac-reserves.tt
- [[17078]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17078) Format fines on opac-account.pl
- [[17103]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17103) Google API Loader jsapi called over http
- [[17117]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17117) Patron personal details not displayed unless branch update request is enabled

### Packaging

- [[16885]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16885) koha-stop-zebra should be more sure of stopping zebrasrv
- [[17065]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17065) Rename C4/Auth_cas_servers.yaml.orig

### Patrons

- [[15397]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15397) Pay selected does not works as expected
- [[16612]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16612) Cannot set "Until date" for "Enrollment period" for Patron Categories
- [[16779]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16779) Move road type after address in US style address formatting (main address)
- [[16894]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16894) re-show email on patron search results
- [[17052]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17052) Patron category description not displayed in the sidebar of paycollect
- [[17076]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17076) Format fines in patron search results table (staff client)
- [[17100]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17100) On summary print, "Account fines and payments" is displayed even if there is nothing to pay
- [[17106]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17106) DataTables patron search defaulting to 'starts_with' - doc

### Reports

- [[16760]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16760) Circulation Statistics wizard not populating itemtype correctly
- [[17053]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17053) Clearing search term in Reports

### SIP2

- [[15006]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15006) Need to distinguish client timeout from login timeout

### Searching

- [[16777]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16777) Correct intranet search alias
- [[17074]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17074) Fix links in result list of 'scan indexes' search and keep search term
- [[17107]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17107) Add ident and Identifier-standard to known indexes

### Serials

- [[12178]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12178) Serial claims: exporting late issues with the CSV profile doesn't set the issue claimed
- [[16705]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16705) Status missing in Opac, serials subscription history

### System Administration

- [[15929]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15929) typo in explanation for MaxSearchResultsItemsPerRecordStatusCheck
- [[16762]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16762) Record matching rules: Remove match check link removes too much
- [[16813]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16813) OPACBaseURL cannot be emptied
- [[17009]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17009) Duplicating frameworks is unnecessary slow

### Templates

- [[16774]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16774) Format date on 'Transfers to receive' page to dateformat system preference
- [[16803]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16803) Add Font Awesome Icons to "Select/Clear all" links to shelves.tt
- [[16888]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16888) Add Font Awesome Icons to Members
- [[16893]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16893) Missing closing tag disrupts patron detail page style
- [[16944]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16944) Add "email" and "url" classes when edit or create a vendor

### Test Suite

- [[16622]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16622) some tests triggered by prove t fail for unset KOHA_CONF
- [[16860]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16860) Catch warning t/db_dependent/ClassSource.t
- [[16864]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16864) Silence warnings in t/db_dependent/ILSDI_Services.t
- [[16869]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16869) Silence and catch warnings in t/db_dependent/SuggestionEngine_ExplodedTerms.t

### Tools

- [[11490]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11490) MaxItemsForBatch should be split into two new prefs
- [[16682]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16682) Fix display if Batch patron modification tool does not get any patrons
- [[16727]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16727) Upload tool needs better warning
- [[16855]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16855) Poor performance due to high overhead of SQL call in export.pl
- [[16859]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16859) Fix wrong item field name in export.pl


## Enhancements

### Architecture, internals, and plumbing

- [[16770]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16770) Remove wrong uses of Memoize::Memcached

### Circulation

- [[16531]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16531) Circ overdues report is showing an empty table if no overdues

### OPAC

- [[16651]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16651) Notes field blank for 952$z in opac-course-details.pl
- [[16805]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16805) Log in with database admin user breaks OPAC

### Patrons

- [[16730]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16730) Use member-display-address-style&#42;-includes in moremember-brief.tt

### SIP2

- [[13807]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13807) SIPServer Input loop not checking for closed connections reliably

### Templates

- [[16450]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16450) Remove the use of "onclick" from guarantor search template
- [[16677]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16677) Use abbr for authorities linked headings
- [[16772]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16772) Change label from 'For:' to 'Library:' to ease translation
- [[16801]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16801) Include Font Awesome Icons to check/unchek all in Administration > Library transfer limits

### Test Suite

- [[16866]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16866) Catch warning t/db_dependent/Languages.t



## New sysprefs

- MaxItemsToDisplayForBatchDel
- MaxItemsToProcessForBatchMod
- OPACResultsLibrary

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
- Chinese (China) (94%)
- Chinese (Taiwan) (98%)
- Czech (97%)
- Danish (78%)
- English (New Zealand) (99%)
- Finnish (97%)
- French (93%)
- French (Canada) (92%)
- German (100%)
- German (Switzerland) (100%)
- Greek (81%)
- Italian (100%)
- Korean (58%)
- Kurdish (55%)
- Norwegian Bokmål (64%)
- Persian (64%)
- Polish (100%)
- Portuguese (100%)
- Portuguese (Brazil) (95%)
- Slovak (99%)
- Spanish (100%)
- Swedish (83%)
- Turkish (99%)
- Vietnamese (79%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

for information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 3.22.10 is

- Release Manager: [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
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
new features in Koha 3.22.10:

- California College of the Arts
- Catalyst IT
- Tulong Aklatan

We thank the following individuals who contributed patches to Koha 3.22.10.

- Aleisha (1)
- NguyenDuyTinh (1)
- phette23 (1)
- Marc (2)
- Jacek Ablewicz (1)
- Morgane Alonso (1)
- Alex Arnaud (1)
- Colin Campbell (5)
- Hector Castro (6)
- Galen Charlton (2)
- Nick Clemens (2)
- Tomás Cohen Arazi (2)
- Chris Cormack (2)
- Indranil Das Gupta (L2C2 Technologies) (1)
- Frédéric Demians (5)
- Jonathan Druart (46)
- Nicole Engard (1)
- Bouzid Fergani (1)
- Katrin Fischer (4)
- Bernardo González Kriegel (3)
- Claire Gravely (1)
- Srdjan Jankovic (1)
- Olli-Antti Kivilahti (1)
- Owen Leonard (3)
- Kyle M Hall (8)
- Florent Mara (1)
- Julian Maurice (8)
- Eric Phetteplace (1)
- Fridolin Somers (5)
- Lyon3 Team (1)
- Mirko Tietgen (2)
- Mark Tompsett (9)
- Marc Véron (17)
- Jesse Weaver (2)
- Marcel de Rooy (8)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 3.22.10

- abunchofthings.net (2)
- ACPL (3)
- arts.ac.uk (1)
- BibLibre (16)
- biblos.pk.edu.pl (1)
- BSZ BW (4)
- bugs.koha-community.org (46)
- ByWater-Solutions (13)
- Catalyst (3)
- jns.fi (1)
- l2c2.co.in (1)
- Marc Véron AG (19)
- PTFS-Europe (5)
- Rijksmuseum (8)
- Solutions inLibro inc (1)
- Tamil (5)
- Theke Solutions (1)
- unidentified (21)
- Universidad Nacional de Córdoba (4)
- Université Jean Moulin Lyon 3 (1)

We also especially thank the following individuals who tested patches
for Koha.

- Andrew Brenza (1)
- Barbara Walters (1)
- Benjamin Rokseth (1)
- Brendan Gallagher (17)
- Brendon Ford (2)
- Broust (2)
- Chris Cormack (14)
- Christopher Brannon (1)
- Claire Gravely (3)
- Frédéric Demians (146)
- Galen Charlton (2)
- Hector Castro (15)
- Irma Birchall (1)
- JM Broust (1)
- Jacek Ablewicz (3)
- Jason Robb (2)
- Jesse Maseto (1)
- Jonathan Druart (54)
- Josef Moravec (1)
- Julian Maurice (150)
- Katrin Fischer (45)
- Laurence Rault (2)
- Liz Rea (1)
- Marc (7)
- Marc Véron (11)
- Mark Tompsett (11)
- Matthias Meusburger (1)
- Megan Wianecki (1)
- Mirko Tietgen (2)
- Nick Clemens (9)
- Owen Leonard (15)
- Srdjan (14)
- Tomas Cohen Arazi (6)
- Nicole C Engard (1)
- Kyle M Hall (142)
- Marcel de Rooy (13)
- Eivin Giske Skaaren (1)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 3.22.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 25 Aug 2016 08:31:38.
