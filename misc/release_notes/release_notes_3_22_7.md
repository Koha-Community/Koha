# RELEASE NOTES FOR KOHA 3.22.7
25 May 2016

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 3.22.7 can be downloaded from:

- [Download](http://download.koha-community.org/koha-3.22.07.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 3.22.7 is a security release.

It includes 1 security fix, 71 bugfixes and 1 enhancement.


## Security bugs fixed

- [[16476]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16476) CGI->param('foo') in list context allows XSS (e.g. Javascript injection) in Koha


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[16505]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16505) rebuild_zebra.pl skips updates if -x is passed
- [[16539]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16539) Koha::Cache is incorrectly caching single holidays

### Cataloging

- [[16373]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16373) merge.pl reports success but files are not merged

### Circulation

- [[16356]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16356) [3.22] Error 500 when returning an item which itemtype is not defined in ItemTypes

### Installation and upgrade (web-based installer)

- [[13669]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13669) Web installer fails to load sample data on MySQL 5.6+
- [[16402]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16402) DB structure cannot be loaded in MySQL 5.7

### Lists

- [[16517]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16517) A server error is raised when creating a new list with an existing name

### Notices

- [[12752]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12752) OVERDUE notice mis-labeled as "Hold Available for Pickup"

### Staff Client

- [[15816]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15816) Timeout login redirects to home page

### Templates

- [[14632]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14632) Incorrect alert while deleting single item in batch

### Test Suite

- [[16561]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16561) Regression caused by 15877 - t/db_dependent/Barcodes.t deletes all items from a DB

### Tools

- [[16426]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16426) Import borrowers tool warns for blank and/or existing userids


## Other bugs fixed

### Acquisitions

- [[11203]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11203) Datatables in acqusitions do not ignore "stopwords" in titles
- [[13041]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13041) Can't add user as manager of basket if name includes a single quote
- [[16154]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16154) Replace CGI->param with CGI->multi_param in list context
- [[16253]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16253) Acq: Change "Delete order" to "Cancel order line" on basket summary and receive page
- [[16321]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16321) 'Show all details' checkbox triggers JS error after jQuery upgrade
- [[16325]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16325) Suggestions: Tab "Status unknown" contains all suggestions
- [[16384]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16384) When canceling 'edit basket', return to basket summary if you came from there

### Architecture, internals, and plumbing

- [[15086]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15086) Creators layout and template sql has warnings
- [[15877]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15877) C4::Barcodes  does not correctly calculate db_max for 'annual' barcodes
- [[15878]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15878) C4::Barcodes::hbyymmincr inccorectly calculates max and should warn when no branchcode present
- [[16104]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16104) Warnings "used only once: possible typo" should be removed
- [[16105]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16105) Cache::Memory is loaded even if memcache is used
- [[16259]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16259) More: Replace CGI->param with CGI->multi_param in list context
- [[16429]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16429) Going to circulation from notice triggers may change logged in branch
- [[16452]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16452) PatronLists.t raises a warning
- [[16499]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16499) circulation.pl logs warnings about Use of uninitialized value
- [[16550]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16550) Can't set opac news expiration date to NULL, it reverts to today

### Cataloging

- [[15682]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15682) Merging records from cataloguing search only allows to merge 2 records

### Circulation

- [[15919]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15919) Batch checkout should show due date in list of checked-out items

### Database

- [[16170]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16170) Pseudo foreign key in Items

### I18N/L10N

- [[16322]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16322) Translatability: "Unknown" in suggestion/suggestion.pl not translatable

### Lists

- [[16484]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16484) Virtualshelves: Using no XSLTResultsDisplay breaks content display in intranet (titles not showing in lists)

### MARC Authority data support

- [[14050]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14050) Default framework for authorities should not be deletable

### Notices

- [[1859]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=1859) Notice fields: can't select multiple fields at once
- [[16217]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16217) Notice' names may have diverged

### OPAC

- [[16220]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16220) The view tabs on opac-detail.pl are not responsive
- [[16233]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16233) Unclosed strong tag in the opac-facets.inc breaks some display
- [[16315]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16315) OPAC Shelfbrowser doesn't display the full title
- [[16340]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16340) JS variable in opac-bottom.inc is declared two times
- [[16478]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16478) Translation breaks display of Checkout history in tab Checkouts / On-site-checkouts
- [[16516]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16516) showListsUpdate JS function is not defined at the OPAC

### Patrons

- [[9393]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9393) Add note to circulation.pl if borrower has pending modifications
- [[12721]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12721) Prevent  software error if incorrect fieldnames given in sypref StatisticsFields
- [[15823]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15823) Can still access patron discharge slip without having the syspref on - Permissions breach
- [[16447]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16447) "Borrow Permission" should not be used anymore

### Reports

- [[16481]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16481) Report menu has unexpected issues

### SIP2

- [[13871]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13871) OverDrive message when user authentication fails

### Searching

- [[16041]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16041) StaffAuthorisedValueImages & AuthorisedValueImages preferences - impact on search performance
- [[16398]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16398) Keep expanded view after clearing the search form

### Self checkout

- [[12663]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12663) SCOUserCSS and SCOUserJS ignored on selfcheck login page

### Serials

- [[13877]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13877) seasonal predictions showing wrong in test

### Staff Client

- [[9387]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9387) Feedback message for FAILED check out items are not obvious for visually impaired
- [[16218]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16218) printfeercpt.tt (and others) does not include jQuery
- [[16270]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16270) Typo authentification vs authentication in 404

### System Administration

- [[15009]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15009) Planning dropdown button in aqbudget can have empty line

### Templates

- [[15194]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15194) Drop-down menu 'Actions' has problem in 'Saved reports' page with language bottom bar
- [[16159]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16159) guarantor section missing ID on patron add form
- [[16230]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16230) Show tooltip with menu item when fund cannot be deleted
- [[16369]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16369) Clean up and improve plugins template
- [[16381]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16381) Fix capitalization on tags review page
- [[16415]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16415) Layout problem on staff client detail page if local cover images are enabled
- [[16439]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16439) Allow styling to button for upload local cover images (Font Awesome Icons)
- [[16480]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16480) Unclosed tag span in shelves on intranet

### Test Suite

- [[14144]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14144) Silence warnings t/db_dependent/Auth_with_ldap.t
- [[14362]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14362) PEGI 15 Circulation/AgeRestrictionMarkers test fails
- [[16390]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16390) Accounts.t does not need MPL
- [[16407]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16407) Fix Koha_borrower_modifications.t
- [[16501]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16501) Remove some unneeded warns in Upload.t


## Enhancements

### Lists

- [[15403]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15403) Confirm messages in intranet lists interface strangely worded





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
- Armenian (100%)
- Chinese (China) (95%)
- Chinese (Taiwan) (100%)
- Czech (97%)
- Danish (78%)
- English (New Zealand) (91%)
- Finnish (98%)
- French (92%)
- French (Canada) (93%)
- German (100%)
- German (Switzerland) (100%)
- Greek (62%)
- Italian (100%)
- Korean (58%)
- Kurdish (55%)
- Norwegian Bokmål (65%)
- Persian (65%)
- Polish (100%)
- Portuguese (97%)
- Portuguese (Brazil) (96%)
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

The release team for Koha 3.22.7 is

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
new features in Koha 3.22.7:

- American Numismatic Society
- Catalyst IT

We thank the following individuals who contributed patches to Koha 3.22.7.

- Blou (1)
- Aleisha (3)
- Jacek Ablewicz (1)
- Alex Arnaud (2)
- Hector Castro (4)
- Nick Clemens (11)
- Tomás Cohen Arazi (4)
- Chris Cormack (1)
- Jonathan Druart (34)
- Charles Farmer (1)
- Katrin Fischer (2)
- Brendan Gallagher (1)
- Bernardo González Kriegel (2)
- Owen Leonard (11)
- Kyle M Hall (13)
- Julian Maurice (5)
- Sophie Meynieux (1)
- Mark Tompsett (6)
- Marc Véron (11)
- Jesse Weaver (1)
- Marcel de Rooy (7)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 3.22.7

- ACPL (11)
- BibLibre (8)
- biblos.pk.edu.pl (1)
- BSZ BW (2)
- bugs.koha-community.org (34)
- ByWater-Solutions (26)
- Catalyst (1)
- Marc Véron AG (11)
- Rijksmuseum (7)
- Solutions inLibro inc (2)
- Theke Solutions (4)
- unidentified (13)
- Universidad Nacional de Córdoba (2)

We also especially thank the following individuals who tested patches
for Koha.

- Aleisha (3)
- Brendan Gallagher (36)
- Chris Cormack (15)
- Heather Braum (2)
- Hector Castro (4)
- Jesse Weaver (1)
- Jonathan Druart (49)
- Julian Maurice (121)
- Katrin Fischer (42)
- Marc Veron (3)
- Marc Véron (20)
- Mark Tompsett (5)
- Mirko Tietgen (1)
- Nick Clemens (6)
- Owen Leonard (13)
- Srdjan (2)
- Tomas Cohen Arazi (5)
- Nicole C Engard (1)
- Brendan A Gallagher (2)
- Kyle M Hall (74)
- Bernardo Gonzalez Kriegel (12)
- Marcel de Rooy (13)
- Brendan Gallagher brendan@bywatersolutions.com (2)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 3.22.x.
The last Koha release was 3.22.6, which was released on April 26, 2016.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 25 May 2016 10:34:13.
