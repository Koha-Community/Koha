# RELEASE NOTES FOR KOHA 18.05.06
26 Nov 2018

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 18.05.06 can be downloaded from:

- [Download](http://download.koha-community.org/koha-18.05.06.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 18.05.06 is a bugfix/maintenance release.

It includes 10 enhancements, 78 bugfixes.




## Enhancements

### Architecture, internals, and plumbing

- [[20521]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20521) dev installations should run with problematic SQL modes

> To aid in catching possible SQL issue's early in development, this patch allows enabling the strictest of SQL modes for development (and makes it the default for continuous integration) environments.


- [[20968]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20968) Plugins: Add hooks to enable plugin integration into catalogue

> Sponsored by PTFS Europe


- [[21719]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21719) Fix typos in codebase

### Authentication

- [[3511]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=3511) Integration with Moodle

### Cataloging

- [[3509]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=3509) Batch item edit
- [[9701]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9701) Configure default indicators

> This adds default indicators to bibliographic frameworks. The table marc_tag_structure is adjusted. In order to make effective use of this enhancement, you may want to add values in your MARC frameworks administration.



### Circulation

- [[3510]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=3510) Allow staff to change checkin date and time

### Patrons

- [[12258]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12258) Datatable in Patrons Account Fines

### Searching

- [[20758]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20758) Typo in BrowseResultSelection syspref description

### Staff Client

- [[21158]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21158) Add cronjob references to the system preference descriptions if a cronjob is required


## Critical bugs fixed

### Acquisitions

- [[21282]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21282) Ordered/spent lists should use prices including tax for calculations

> Corrects the prices shown on the ordered/spent lists for each fund in acquisitions to show the price with taxes included. This will make the total shown on these pages match the total shown in the table on the acq start and fund pages.


- [[21587]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21587) Patrons to notify on receiving doesn't work on new order creation, only on modification

### Architecture, internals, and plumbing

- [[21593]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21593) Remove Group by clause in GetAuthValueDropbox
- [[21598]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21598) budget_parent_id isn't in GROUP BY - GetBudgetHierarchy
- [[21599]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21599) Incorrect decimal value: '' for column 'defaultreplacecost' - Cannot create item type
- [[21604]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21604) Cannot add/edit funds, cannot add budgets
- [[21612]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21612) Incorrect GROUP BY in Koha::Virtualshelves
- [[21635]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21635) Incorrect GROUP BY clause in batchMod.pl

### Authentication

- [[21311]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21311) Remove locked message from opac-auth.tt

> It is good security practice to not provide details which could confirm or deny the existence of an account. Previously, the simple "This account has been locked!" confirmed its existence which would only encourage more attacks by hackers.  
To prevent aiding malicious attacks, the message has been changed to something that does not expressly state the account has been locked. It only mentions that accounts will be locked after a number of failed attempts, instead of saying whether it is locked or not.  
So while a successful attempt will seem to have an invalid username or password suggestion after the account is locked, users should be reminded that they can always reset their password or contact library staff for help.



### Cataloging

- [[21742]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21742) Incorrect count of youtube videos

### Circulation

- [[21641]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21641) Software error when checking out an item with a charge associated with it
- [[21777]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21777) Checkouts table in circulation is out of alignment

### Course reserves

- [[21603]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21603) Incorrect GROUP BY clause in SearchCourses

### Database

- [[21617]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21617) statistics.ccode is not long enough (see also dbrev 18.06.00.032)

### Fines and fees

- [[21702]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21702) mancredit.pl incorrectly passes user_id instead of the patron id

### MARC Bibliographic data support

- [[21749]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21749) Importing MARC frameworks from pre-9701 fails

### OPAC

- [[21476]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21476) Incorrect filter prevents HTML5 media from playing in the OPAC
- [[21771]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21771) Password recovery is broken (see 20023)

### SIP2

- [[21486]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21486) SIP does not return  checked out (charged) items on patron_information request

### Serials

- [[21554]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21554) Using Subscription Batch Edit produces Software Error

### Staff Client

- [[21766]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21766) Default sounds broken in 18.05 - wrong filter/link

### Test Suite

- [[21597]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21597) Test suite is still failing with new default SQL modes
- [[21600]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21600) t/db_dependent/api/v1/patrons.t is failing with new SQL modes


## Other bugs fixed

### About

- [[7143]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7143) Bug for tracking changes to the about page
- [[17597]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17597) Outdated translation credits
- [[20720]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20720) Add libraries (sponsors) to the about page

### Acquisitions

- [[16754]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16754) Use validation plugin in budgets, planning, and contracts
- [[21387]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21387) Receive items from - form should include tax hints the same as the ordering form
- [[21619]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21619) Tax hints should not be abbreviated
- [[21725]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21725) Incorrect HAVING in group by in Acquisitions.pm

### Architecture, internals, and plumbing

- [[18584]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18584) Our legacy code contains trailing-spaces
- [[18720]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18720) Get rid of "die" in favor of exceptions in C4::Acquisition::GetBasketAsCsv
- [[21082]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21082) OverDrive authentication method no longer supported
- [[21621]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21621) Incorrect GROUP BY in tools/letter.pl
- [[21639]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21639) Phone notice transports do not exist for new installs
- [[21680]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21680) Remove dead code C4::Accounts::fixaccounts

### Cataloging

- [[20592]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20592) updateitem.pl causes database errors when empty non-public item notes updated
- [[21556]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21556) Deleting same record twice leads to fatal software error
- [[21666]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21666) Advanced editor search- error is given for 'Unsupported Use attribute' when searching on title + author

### Circulation

- [[21562]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21562) Sorting on checkout date is broken

### Command-line Utilities

- [[21640]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21640) Itivia outbound script doesn't print to STDOUT
- [[21698]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21698) FIX POD of cancel_unfilled_holds.pl

### Course reserves

- [[21349]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21349) Instructors with special characters (e.g. $, ., :) in their cardnumber cannot be removed from course reserves

### Database

- [[21015]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21015) Members.pm slow because it loads twice Koha::Schema

### I18N/L10N

- [[21351]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21351) Traditional Chinese Language pack should have file name "zh-Hant-TW" not "zh-Hans-TW"
- [[21490]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21490) Disambiguation of "Order"

### ILL

- [[21497]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21497) Dates should be correctly formatted for ILL requests in OPAC
- [[21585]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21585) Missing firstnames should be gracefully ignored in ILL requests table

### Installation and upgrade (command-line installer)

- [[21654]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21654) Installer is loading a non-existent file

### Lists

- [[21629]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21629) List sort on call number does not use cn_sort

> With this patch lists sorted on call number will now use the machine sortable form of the callnumber from items.cn_sort for better results.



### MARC Authority data support

- [[21581]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21581) Matching rules for authorities do not respect 'Search index' setting

### Notices

- [[21277]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21277) fr-CA translation for notices in sample_notices.sql

### OPAC

- [[21590]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21590) "send list" email uses the term "virtual shelf", this should be "list".

### Patrons

- [[21080]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21080) patron attribute classes break patron's edit view
- [[21634]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21634) "Circulation" option is lost when viewing patron's logs

### Reports

- [[21005]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21005) Missing row/column defaults cause unexpected results in report wizards

### Searching

- [[14716]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14716) Correctly URI-encode URLs in XSLT result lists and detail pages

### Serials

- [[20351]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20351) Implement blocking errors for serials scripts
- [[21505]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21505) Box around 'Additional fields' does not contain the fields
- [[21552]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21552) RoutingListNote should use raw filter and display HTML unescaped

### Staff Client

- [[21456]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21456) The 'New authority' button lists authority types inconsistently
- [[21583]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21583) Novelist Select staff client not working in staff client - ns2init.js not loading
- [[21606]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21606) Issues with matching rules

### System Administration

- [[21625]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21625) Fix wording and typo in SMSSendDriver system preference description

### Templates

- [[10442]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10442) Remove references to non-standard "error" class
- [[14786]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14786) Use text "MARC file" instead of "ISO2709" everywhere
- [[21186]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21186) Incorrect Bootstrap modal event name in multiple templates
- [[21513]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21513) Add a 'Cancel' button to the authority editor and remove duplicate 'Save' button
- [[21531]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21531) Subscription "New fields" button should read "New field"
- [[21740]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21740) Fixed-length fields show _ instead of @ when editing subfields

### Test Suite

- [[18959]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18959) Text_CSV_Various.t must skip if Text::CSV::Unicode is not installed
- [[21155]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21155) SwitchOnSiteCheckouts.t is failing randomly
- [[21717]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21717) TestBuilder.t is failing randomly
- [[21775]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21775) Lack of tests for audio alerts
- [[21787]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21787) GetHardDueDate.t has a silly test

### Tools

- [[21242]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21242) Modification log redirects you to circulation with no borrower if 'Object' field is not populated with borrowernumber
- [[21579]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21579) showdiffmarc tool during manage staged batches always looks for biblios even when matching authorities

### Web services

- [[21542]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21542) OverDrive password submission should use a password field to mask input

## New sysprefs

- OverDrivePasswordRequired

## System requirements

Important notes:
    
- Perl 5.10 is required
- Zebra is required

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://koha-community.org/manual/18.05/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (98.9%)
- Armenian (98.9%)
- Basque (72.7%)
- Chinese (China) (77.2%)
- Chinese (Taiwan) (98.9%)
- Czech (92.6%)
- Danish (63.7%)
- English (New Zealand) (95.7%)
- English (USA)
- Finnish (92.6%)
- French (98.9%)
- French (Canada) (93.7%)
- German (100%)
- German (Switzerland) (98.6%)
- Greek (80.3%)
- Hindi (98.9%)
- Italian (97.5%)
- Norwegian Bokmål (67.8%)
- Occitan (post 1500) (70.4%)
- Persian (53.1%)
- Polish (93.8%)
- Portuguese (100%)
- Portuguese (Brazil) (87.7%)
- Slovak (94.5%)
- Spanish (98.9%)
- Swedish (94%)
- Turkish (98.9%)
- Vietnamese (65.3%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 18.05.06 is

- Release Manager: [Nick Clemens](mailto:nick@bywatersolutions.com)
- Release Manager assistants:
  - [Brendan Gallagher](mailto:brendan@bywatersolutions.com)
  - [Jonathan Druart](mailto:jonathan.druart@bugs.koha-community.org)
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
  - [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)

- Module Maintainers:
  - REST API -- [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
  - Elasticsearch -- [Nick Clemens](mailto:nick@bywatersolutions.com)
- QA Manager: [Katrin Fischer](mailto:Katrin.Fischer@bsz-bw.de)

- QA Team:
  - [Julian Maurice](mailto:julian.maurice@biblibre.com)
  - [Marcel de Rooy](mailto:m.de.rooy@rijksmuseum.nl)
  - Josef Moravec
  - [Alex Arnaud](mailto:alex.arnaud@biblibre.com)
  - [Martin Renvoize](mailto:martin.renvoize@ptfs-europe.com)
  - [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
  - [Jonathan Druart](mailto:jonathan.druart@bugs.koha-community.org)
  - [Chris Cormack](mailto:chrisc@catalyst.net.nz)
- Bug Wranglers:
  - Claire Gravely
  - Jon Knight
  - [Indranil Das Gupta](mailto:indradg@l2c2.co.inc)
  - [Amit Gupta](mailto:amitddng135@gmail.com)
- Packaging Manager: [Mirko Tietgen](mailto:mirko@abunchofthings.net)
- Documentation Team:
  - Lee Jamison
  - David Nind
  - Caroline Cyr La Rose
- Translation Manager: [Bernardo Gonzalez Kriegel](mailto:bgkriegel@gmail.com)
- Release Maintainers:
  - 18.05 -- [Martin Renvoize](mailto:martin.renvoize@ptfs-europe.com)
  - 17.11 -- [Fridolin Somers](mailto:fridolin.somers@biblibre.com)
  - 17.05 -- [Fridolin Somers](mailto:fridolin.somers@biblibre.com)

## Credits

We thank the following individuals who contributed patches to Koha 18.05.06.

- Dimitris Antonakis (1)
- Tomás Cohen Arazi (6)
- Alex Buckley (1)
- Barton Chittenden (1)
- Nick Clemens (23)
- David Cook (3)
- Jonathan Druart (37)
- Magnus Enger (2)
- Katrin Fischer (5)
- Isobel Graham (1)
- Victor Grousset (1)
- Kyle Hall (2)
- Andrew Isherwood (5)
- Joonas Kylmälä (1)
- Thatcher Leonard (1)
- Owen Leonard (7)
- Ere Maijala (4)
- Josef Moravec (5)
- Martin Renvoize (16)
- Marcel de Rooy (5)
- Caroline Cyr La Rose (4)
- Andreas Roussos (2)
- Mark Tompsett (3)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 18.05.06

-  (0)
- ACPL (7)
- BibLibre (1)
- BSZ BW (5)
- bugs.koha-community.org (37)
- ByWater-Solutions (26)
- Catalyst (1)
- debian.diman (1)
- Libriotech (2)
- Prosentient Systems (3)
- PTFS-Europe (21)
- Rijks Museum (5)
- Solutions inLibro inc (4)
- Theke Solutions (6)
- unidentified (13)
- University of Helsinki (4)

We also especially thank the following individuals who tested patches
for Koha.

- Sandy Allgood (3)
- Tomás Cohen Arazi (13)
- Cori Lynn Arnold (4)
- Marjorie Barry-Vila (1)
- Alex Buckley (8)
- Colin Campbell (2)
- Nick Clemens (128)
- Chris Cormack (6)
- Michal Denar (7)
- Devinim (2)
- Jonathan Druart (31)
- Magnus Enger (1)
- Charles Farmer (1)
- Katrin Fischer (32)
- Stephen Graham (5)
- Claire Gravely (3)
- Kyle Hall (6)
- Andrew Isherwood (9)
- Owen Leonard (5)
- Julian Maurice (3)
- Josef Moravec (12)
- Séverine Queune (2)
- Martin Renvoize (158)
- Marcel de Rooy (17)
- Caroline Cyr La Rose (2)
- Andreas Roussos (2)
- Myka Kennedy Stephens (1)
- Pierre-Marc Thibault (6)
- Mark Tompsett (11)
- George Williams (1)

We thank the following individuals who mentored new contributors to the Koha project.

- Owen Leonard
- Martin Renvoize


We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 18.05.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 26 Nov 2018 12:10:26.
